require 'RMagick'
require 'open-uri'
require 'net/http'
require 'ostruct'

class Picture < ActiveRecord::Base
  #after_create :write_data_to_cache
  after_create :wipe_cache_entry

  belongs_to :binary_file
  has_many :picture_list_entries

  def self.from_file_data(data)
    p = new
    p.name = data.original_filename
    p.content_type = data.content_type
    p.file_size = data.size
    p.binary_file = BinaryFile.new(:data => data.read)
    p
  end

  def self.from_url url
    response = Net::HTTP.get_response(URI.parse(url))
    raise ::BadImageURL if response.code.to_s != '200'

    fd = OpenStruct.new
    fd.original_filename = url.split('/').last
    fd.content_type = response['Content-type']
    fd.size = response.body.size
    fd.read = response.body
    from_file_data fd
  end

  def data(dimensions = nil, private_recursive = nil)
    dimensions = dimensions.to_s if dimensions.is_a? Symbol

    return cached_file_data[dimensions] if cached_file_data[dimensions]

    cached_file_data[dimensions] = self.class.read_data_from_cache(b32id, dimensions)

    if !cached_file_data[dimensions]
      raise "something wrong with picture cache" if private_recursive
      write_data_to_cache(dimensions)
      data(dimensions, true)
    end
    cached_file_data[dimensions]
  end

  def cached_file_data
    @cached_file_data ||= {}
  end

  def extension
    File.extname(name)
  end

  def self.read_data_from_cache b32id, dimensions = nil
    data = nil

    if File.exists?(full_cached_file_path(b32id, dimensions))
      File.open(full_cached_file_path(b32id, dimensions), 'rb') do |f|
        data = f.read
      end
    end

    data
  end

  def b32id
    binary_file_id.to_i.to_s(32)
  end

  def cache_path(dimensions = nil)
    @cache_path ||= self.class.cache_path(b32id, dimensions)
  end

  def self.cache_path(b32id, dimensions = nil)
    level1 = /([[:alnum:]_-])[[:alnum:]_-]$/.match(b32id)
    level1 = level1[1] if level1
    level1 = "nil" unless level1

    level2 = /([[:alnum:]_-])[[:alnum:]_-]{2}$/.match(b32id)
    level2 = level2[1] if level2
    level2 = "nil" unless level2

    cp = File.join [cache_base_path, level2, level1, dimensions].compact
    FileUtils.mkdir_p cp
    cp
  end

  def self.cache_base_path
    File.join Rails.root, "bintmp", Rails.env
  end

  def full_cached_file_path dimensions = nil
    self.class.full_cached_file_path(b32id, dimensions)
  end

  def self.full_cached_file_path b32id, dimensions = nil
    File.join cache_path(b32id, dimensions), b32id;
  end

  def write_data_to_cache dimensions = nil
    FileUtils.mkdir_p cache_path

    if !File.exists? full_cached_file_path
      File.open(full_cached_file_path, "wb") do |f|
        f.write(binary_file.data)
      end
    end

    data = self.class.read_data_from_cache b32id

    if dimensions
      FileUtils.mkdir_p cache_path(dimensions)

      image = Magick::Image.from_blob(data).first

      image = image.change_geometry(dimensions) do |cols, rows, img|
        img.resize!(cols, rows)
      end

      #On windows, we cannot write to a path with C: in the front, because it will think we
      #are specifying a prefix, which would need to look like png:C:\....

      #by changing to the target dir first, we avoid having to have C: in the filename
      #passed to write()
      dir = full_cached_file_path(dimensions)
      filename = File.basename(dir)
      dir = File.dirname(dir)

      Dir.chdir dir do
        image.write(filename) do |ii|
          ii.format = image.format
        end
      end
    end
  end

  def == other
    return true if other.id == id

    exclude = [:id, :created_at, :updated_at]

    me = attributes.dup
    exclude.each do |att|
      me.delete att
      me.delete att.to_s
    end

    them = other.attributes.dup

    exclude.each do |att|
      them.delete att
      them.delete att.to_s
    end

    me == them
  end

  def self.clear_cache
    if File.exists? cache_base_path
      FileUtils.remove_entry_secure(cache_base_path)
    end
  end

  def wipe_cache_entry
    Find.find cache_path do |f|
      if File.file?(f) && File.basename(f).strip == b32id
        FileUtils.rm f
      end
    end
  end

  def src(width = nil, height = nil)
    if width.is_a? Hash
      options = width
      width = nil
    end

    if height.is_a? Hash
      options = height
      height = width
    end

    height ||= width

    src = "/pictures/#{id}"

    options ||= {}

    if width
      size = "#{width}x#{height}"
      src += "/#{size}"
    end

    src
  end

end

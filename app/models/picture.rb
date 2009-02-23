require 'RMagick'

class Picture < ActiveRecord::Base
  #after_create :write_data_to_cache
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

  def self.find_by_b64id(b64id)
    raise "don't call this!?!?!!!"
    Picture.find(Integer.from_b64(b64id))
  end

  def data(dimensions = nil, private_recursive = nil)
    dimensions = dimensions.to_s if dimensions.is_a? Symbol

    return cached_file_data[dimensions] if cached_file_data[dimensions]

    cached_file_data[dimensions] = self.class.read_data_from_cache(binary_file_id.to_b64, dimensions)

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

  def self.read_data_from_cache b64id, dimensions = nil
    data = nil

    data_path = cache_path(b64id)

    data_path += "/#{dimensions}" if dimensions

    if File.exists?("#{data_path}/#{b64id}")
      File.open("#{data_path}/#{b64id}", 'rb') do |f|
        data = f.read
      end
    end

    data
  end


  def b64id
    raise "don't call this!!!"
    @b64id ||= id.to_b64
  end

  def cache_path
    @cache_path ||= self.class.cache_path(binary_file_id.to_b64)
  end

  def self.cache_path(b64id)
    level1 = /([[:alnum:]_-])[[:alnum:]_-]$/.match(b64id)
    level1 = level1[1] if level1
    level1 = "nil" unless level1

    level2 = /([[:alnum:]_-])[[:alnum:]_-]{2}$/.match(b64id)
    level2 = level2[1] if level2
    level2 = "nil" unless level2

    cp = "#{RAILS_ROOT}/bintmp/#{RAILS_ENV}/#{level2}/#{level1}"
    FileUtils.mkdir_p cp
    cp
  end

  def write_data_to_cache dimensions = nil
    data_path = cache_path

    FileUtils.mkdir_p data_path

    if !File.exists?"#{data_path}/#{binary_file_id.to_b64}"
      File.open("#{data_path}/#{binary_file_id.to_b64}", "wb") do |f|
        f.write(binary_file.data)
      end
    end

    data = self.class.read_data_from_cache binary_file_id.to_b64

    if dimensions
      data_path += "/#{dimensions}" if dimensions

      FileUtils.mkdir_p data_path

      image = Magick::Image.from_blob(data).first

      image = image.change_geometry(dimensions) do |cols, rows, img|
        img.resize!(cols, rows)
      end

      image.write("#{data_path}/#{binary_file_id.to_b64}") {|ii| ii.format = image.format}
    end
  end

  #  def dup
  #    retval = nil
  #    self.class.new do |resource|
  #      resource.attributes     = @attributes
  #      retval = resource
  #    end
  #
  #    retval
  #  end

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
end


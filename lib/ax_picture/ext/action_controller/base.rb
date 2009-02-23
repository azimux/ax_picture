require 'open-uri'
require 'net/http'
require 'ostruct'

module Azimux
  module Picture
    module ActionController
      module Base
        def pictures_to_process? pic_list
          uploaded_photos = params[:upload_photos]

          if uploaded_photos
            uploaded_photos.each_pair do |key,value|
              if !key.blank? && (!value['file_data'].blank? || !value['url'].blank?)
                return true
              end
            end
          end

          photos_to_be_deleted = params[:photos_to_be_deleted]

          if photos_to_be_deleted
            return true unless photos_to_be_deleted.values.grep(/\d+/).empty?
          end

          return true unless params[:move_photo_to_top].blank?

          photo_captions = params[:photo_captions]
          captions_hash = {}
          if photo_captions
            photo_captions.each_pair do |key,value|
              if !key.blank?
                captions_hash[key.to_i] = value
              end
            end

            if captions_hash.keys.size > 0
              return true unless pic_list
            end

            captions_hash.keys.sort.each do |key|
              ple = pic_list.picture_list_entries.find(key)
              return true if ple.picture.caption != captions_hash[key]
            end
          end

          return false
        end

        def process_pictures_for_list pic_list, map_from_list = nil
          ple_map = (map_from_list || pic_list).build_ple_map(pic_list)

          photos_to_be_deleted = params[:photos_to_be_deleted]

          if photos_to_be_deleted
            photos_to_be_deleted = photos_to_be_deleted.values.grep(/\d+/).map(&:to_i)
            photos_to_be_deleted.map! {|ple_id| ple_map[ple_id]}
          else
            photos_to_be_deleted = []
          end

          if !photos_to_be_deleted.empty?
            photos_to_be_deleted.each do |pic_list_entry_id|
              pe = pic_list.picture_list_entries.find(pic_list_entry_id)

              picture = pe.picture
              bin_id = picture.binary_file_id
              pe.destroy
              picture.destroy
              ::BinaryFile.find(bin_id).destroy if ::Picture.find_all_by_binary_file_id(bin_id).empty?
            end
          end

          uploaded_photos = params[:upload_photos]

          if uploaded_photos
            fds = {}

            uploaded_photos.each_pair do |key,value|
              if !key.blank?
                if !value['url'].blank?
                  url = value['url']
                  #fetch the data from a url
                  response = Net::HTTP.get_response(URI.parse(url))
                  raise ::BadImageURL if response.code.to_s != '200'

                fd = OpenStruct.new
                  fd.original_filename = url.split('/').last
                  fd.content_type = response['Content-type']
                  fd.size = response.body.size
                  fd.read = response.body
                  value['file_data'] = fd
                end

                if !value['file_data'].blank?
                  fds[key.to_i] = value['file_data']
                end
              end
            end

            fds.keys.sort.each do |key|
              pic = ::Picture.from_file_data(fds[key])
              pic.save!
              ple = ::PictureListEntry.new(:picture_id => pic.id)

              pic_list.picture_list_entries << ple
              ple.save!
              pic_list.reload.picture_list_entries.reload
            end
          end

          move_photo_to_top = params[:move_photo_to_top]
          if !move_photo_to_top.blank? && !photos_to_be_deleted.index(move_photo_to_top.to_i)
            pic_list.picture_list_entries.find(ple_map[move_photo_to_top.to_i]).move_to_top
          end

          photo_captions = params[:photo_captions]
          captions_hash = {}
          if photo_captions
            photo_captions.each_pair do |key,value|
              if !key.blank? && !photos_to_be_deleted.index(ple_map[key.to_i])
                captions_hash[ple_map[key.to_i]] = value
              end
            end

            captions_hash.keys.sort.each do |key|
              ple = pic_list.picture_list_entries.find(key)
              if ple.picture.caption != captions_hash[key]
                ple.picture.caption = captions_hash[key]
                ple.picture.save!
              end
            end
          end
        end
      end
    end
  end
end

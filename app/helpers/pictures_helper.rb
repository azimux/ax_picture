module PicturesHelper
  def picture_img_tag_in_div(picture, width, height = nil, options = {})
    if height.is_a? Hash
      options = height
      height = width
    end

    content_tag(:div,
      :style => "width:#{width}px;height:#{height || width}px"
    ) do
      picture_img_tag(picture,width,height)
    end
  end

  def picture_img_tag_in_table(picture, width, height = nil, options = {})
    caption_text = ''

    if height.is_a? Hash
      options = height
      height = width
    end

    if options[:caption]
      if options[:caption].is_a?(String)
        caption_text = options[:caption]
      else
        caption_text = picture.caption
      end

      caption_text = content_tag(:caption, :align => "bottom") do
        h(caption_text)
      end.html_safe
      options.delete :caption
    end

    style = "width:#{width}px;height:#{height || width}px;margin:0;padding:0;"

    style += options.delete :style  if options[:style]

    img_tag = picture_img_tag(picture, width, height, options)

    content_tag(:table, :style => style) do
      safe_join([
          caption_text,
          content_tag(:tr) do
            content_tag(:td) do
              img_tag
            end
          end
        ])
    end
  end

  def picture_img_tag(picture, width = nil, height = nil, options = {})
    return '' unless picture

    if width.is_a? Hash
      options = width
      width = nil
    end

    if  height.is_a? Hash
      options = height
      height = width
    end

    include_link = options.delete :include_link

    src = "/pictures/#{picture.id}"

    options ||= {}
    options.merge({:alt => picture.name})

    if width
      if height
        size = "#{width}x#{height}"
      else
        size = "#{width}x#{width}"
      end
      src += "/#{size}"
    end

    retval = image_tag(src, options)

    if include_link
      if include_link.is_a? String
        retval = link_to(retval, include_link)
      else
        retval = link_to(retval, "/pictures/#{picture.id}")
      end
    end

    retval
  end

  def picture_sub_form pic_list
    ple = pic_list.picture_list_entries if pic_list
    ple ||= []

    render :partial => "pictures/picture_sub_form", :locals => {
      :picture_list_entries => ple
    }
  end

  def show_picture_list pic_list, options
    ple = pic_list.picture_list_entries if pic_list
    ple ||= []

    render :partial => "picture_lists/show", :locals => {
      :picture_list => pic_list, :caption => options[:caption]
    }
  end

end

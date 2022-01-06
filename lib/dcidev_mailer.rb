module DcidevMailer
  class << self
    def format_image_from_html(html)

      images = []
      body_html = Nokogiri::HTML(html)
      temp = body_html
      if ENV["USE_MANDRILL_MAILER"].to_i == 1
        temp.search("img").each_with_index do |img, i|
          cid = "body_image_#{i}"
          images.push({content: nil, encoded_content: DcidevUtility.base64_encoded_string(img["src"]), type: DcidevUtility.base64_extension(img["src"]), name: cid})
          body_html.search("img")[i]["src"] = 'cid:' + cid
        end
      end
      [body_html.search("body")[0].children.to_html, images]
    end

    def format_attachments(attachments)
      formatted = []
      attachments.each do |a|
        begin
          filetype = MimeMagic.by_magic(a[:file]).type.to_s
          content = a[:file].read
          name = "#{a[:filename]}.#{filetype.split("/")[1]}"
          att = {
            content: content,
            name: name,
          }

          att[:type] = filetype if ENV["USE_MANDRILL_MAILER"].to_i == 0
          formatted << att
        rescue => _

        end
      end
      formatted
    end

    def format_header_footer(header_url: "", footer_url: "", locals: {}, images: {})
      [{name: "header", url: header_url}, {name: "footer", url: footer_url}].each do |i|
        return if i[:url].nil?
        begin
          extension, encoded, _ = DcidevUtility.file_url_to_base64(i[:url])
          locals[i[:name].to_sym] = "cid:#{i[:name]}"
          images.push({content: encoded, encoded_content: encoded, type: extension, name: i[:name]})
        rescue => _

        end
      end
      return [locals, images]
    end

  end

end


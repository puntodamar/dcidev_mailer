require 'mail'

module DcidevMailer
    class Rails < ApplicationMailer
        default from: ENV['DEFAULT_EMAIL_SENDER']

        class << self
            def email(html_body: "", header_url: "", footer_url: "", file_attachments: nil, to: "", from: nil, subject: "")
                wording, images = DcidevMailer.format_image_from_html(html_body)
                locals = {wording: wording, header: nil, footer: nil}
                locals, images = DcidevMailer.format_header_footer(header_url: header_url, footer_url: footer_url, locals: locals, images: images) if header_url.present? && footer_url.present?

                if file_attachments.present?
                    file_attachments.each do |a|
                      attachments[a[:name].to_s] = a[:content] unless a[:content].nil?
                    end
                end

                attachments.inline['header'] = File.read(Utility.download_to_file(header_url)) rescue nil if header_url.present?
                attachments.inline['footer'] = File.read(Utility.download_to_file(footer_url)) rescue nil if footer_url.present?
          
                mail(to: to, subject: subject, format: "text/html", from: from) do |format|
                    format.html {
                      render locals: locals
                    }
            end
        end
    end
end
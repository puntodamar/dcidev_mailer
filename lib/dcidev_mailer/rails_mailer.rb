# require 'mail'
require 'action_mailer'
require 'action_view'
require 'mail'
require 'dcidev_mailer/errors/invalid_recipients'
require 'dcidev_mailer/errors/invalid_body'
require 'dcidev_mailer/errors/invalid_template'

module DcidevMailer
  class RailsMailer < ActionMailer::Base

    def email(html_body: "", header_url: "", footer_url: "", file_attachments: nil, to: nil, cc: nil, bcc: nil, from: nil, subject: "", template_path: "")
      raise DcidevMailer::Errors::InvalidRecipients unless to.present?
      raise DcidevMailer::Errors::InvalidBody unless html_body.present? && html_body.is_a?(String)
      raise DcidevMailer::Errors::InvalidTemplate unless template_path.present?
      wording, images = DcidevMailer.format_image_from_html(html_body)

      locals = { wording: wording, header: nil, footer: nil }
      locals, _ = DcidevMailer.format_header_footer(header_url: header_url, footer_url: footer_url, locals: locals, images: images) if header_url.present? || footer_url.present?
      
      file_attachments = DcidevMailer.format_attachments(file_attachments) if file_attachments.present?
      if file_attachments.present?
        file_attachments.each do |a|
          attachments[a[:name].to_s] = a[:content] unless a[:content].nil?
        end
      end

      begin
        header_file = File.read(DcidevUtility.download_to_file(header_url))
        header_mime = MimeMagic.by_magic(header_file)
        attachments.inline['header'] = header_file
        attachments.inline['header']['content-type'] = header_mime
        attachments.inline['header']['content-id'] = '<header>'
      rescue => _
      end

      begin
        footer_file = File.read(DcidevUtility.download_to_file(footer_url))
        footer_mime = MimeMagic.by_magic(footer_file)
        attachments.inline['footer'] = footer_file
        attachments.inline['footer']['content-type'] = footer_mime
        attachments.inline['footer']['content-id'] = '<footer>'
      rescue => _
      end

      mail(
        to: to,
        cc: cc,
        bcc: bcc,
        subject: subject,
        format: "text/html",
        from: from,
        # template_path: "dcidev_mailer/rails_mailer",
        # template_name: 'a',
      ) do |format|
        format.html {
          render locals: locals, html: ActionController::Base.new.render_to_string(template: template_path, locals: locals)

        }
      end
    end
  end
end

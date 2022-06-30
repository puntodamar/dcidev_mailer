require 'mandrill'

module DcidevMailer
    class MandrillTemplate < MandrillMailer::TemplateMailer
        default from: ENV['DEFAULT_EMAIL_SENDER']

        class << self
            def send_email(subject: '', to: nil, cc: nil, bcc: nil, from: nil, from_name: nil, attachments: nil, vars: nil, template_name: nil, images: nil, preserve_recipients: false)
                raise DcidevMailer::Errors::InvalidTemplate unless template_name.present?
                images = DcidevMailer.format_images(images) if images.present?
                attachments = DcidevMailer.format_attachments(attachments) if attachments.present?
                self.send_mail(subject, to, cc, bcc, attachments, images, from, from_name, template_name, vars, preserve_recipients).deliver_now
            end

            def send_mail(subject, to, cc, bcc, attachments = nil, images = nil, from = nil, from_name = nil, template_name = nil, vars = nil, preserve_recipients)
                mandrill_mail subject: subject,
                              from: from,
                              from_name: from_name,
                              to: to,
                              cc: cc,
                              bcc: bcc,
                              important: true,
                              inline_css: true,
                              attachments: attachments,
                              images: images,
                              template_name: template_name,
                              vars: vars,
                              preserve_recipients: cc.present? || preserve_recipients
            end
        end
    end
end
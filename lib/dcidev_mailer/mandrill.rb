require 'mandrill'

module DcidevMailer
    class Mandrill < MandrillMailer::MessageMailer
        default from: ENV['DEFAULT_EMAIL_SENDER']

        class << self
            def send_email(subject: '', html_body: '', to: nil, cc: nil, bcc: nil, from: nil, from_name: nil, attachments: nil, email_template_path: '', header_url: '', footer_url: '', preserve_recipients: false)
                ac = ActionController::Base.new
                wording, images = DcidevMailer.format_image_from_html(html_body)
                locals = { wording: wording, header: nil, footer: nil }
                locals, images = DcidevMailer.format_header_footer(header_url: header_url, footer_url: footer_url, locals: locals, images: images) if header_url.present? || footer_url.present?
                html_body = ac.render_to_string(template: email_template_path, locals: locals)
                attachments = DcidevMailer.format_attachments(attachments) if attachments.present?
                self.send_mail(subject, to, cc, bcc, html_body, attachments, images, from, from_name, preserve_recipients).deliver_now
            end

            def send_mail(subject, to, cc, bcc, html, attachments = nil, images = nil, from = nil, from_name = nil, preserve_recipients)
                mandrill_mail subject: subject,
                              from: from,
                              from_name: from_name,
                              # to: "dev.puntodamar@gmail.com",
                              to: to,
                              cc: cc,
                              bcc: bcc,
                              # to: { email: invitation.email, name: 'Honored Guest' },
                              html: html,
                              view_content_link: true,
                              important: true,
                              inline_css: true,
                              attachments: attachments,
                              images: images,
                              preserve_recipients: cc.present? || preserve_recipients
            end
        end
    end
end

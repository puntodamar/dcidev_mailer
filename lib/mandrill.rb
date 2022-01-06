require "mandrill"

module DcidevMailer
    class DcidevMandrill < MandrillMailer::MessageMailer
        default from: ENV['DEFAULT_EMAIL_SENDER']

        class << self
            def send_email(subject: "", html_body: "", to: nil, attachments: nil, email: "", email_template_path: "")
                ac = ActionController::Base.new
                locals, images = DcidevMailer.format_image_from_html(html_body)
                html_body = ac.render_to_string(template: email_template_path, locals: locals)
                attachments = DcidevMailer.format_attachments(attachments) if attachments.present?
                response = self.send_mail(subject, to, html_body, attachments, images).deliver_now
            end

            def send_mail(subject, to, html, attachments = nil, images = nil)
                mandrill_mail subject: subject,
                              # to: "dev.puntodamar@gmail.com",
                              to: to,
                              # to: { email: invitation.email, name: 'Honored Guest' },
                              html: html,
                              view_content_link: true,
                              important: true,
                              inline_css: true,
                              attachments: attachments,
                              images: images
            end
        end
    end
end
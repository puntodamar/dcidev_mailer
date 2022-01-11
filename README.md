# Tldr
This gem uses both Mandrill API and ActionMailer to send email.

# Setup

Add this to your `.env`
```env
BASE_URL_FE=
DEFAULT_EMAIL_SENDER= 
USE_MANDRILL_MAILER= 
MANDRILL_SMTP_ADDRESS=
MANDRILL_SMTP_DOMAIN= 
MANDRILL_SMTP_PASSWORD= 
MANDRILL_SMTP_USERNAME= 
MANDRILL_SMTP_PORT= 
MANDRILL_SMTP_AUTO_TLS= 
MANDRILL_SMTP_TLS=

MAILER_SMTP_ADDRESS=
MAILER_SMTP_DOMAIN= 
MAILER_SMTP_PASSWORD= 
MAILER_SMTP_USERNAME= 
MAILER_SMTP_PORT= 
MAILER_SMTP_AUTO_TLS= 
MAILER_SMTP_TLS=
 ```

Add this to `config/initializer/mailer.rb`
```ruby
ActionMailer::Base.delivery_method = :smtp  

# change it to your helper class name
ActionMailer::Base.add_delivery_method :mandrill_mailer, MandrillMailer  
  
# uncomment if neccessary
smtp_settings = {  
  address: ENV["USE_MANDRILL_MAILER"].to_i == 1 ?  ENV['MANDRILL_SMTP_ADDRESS'] : ENV["MAILER_SMTP_ADDRESS"],  
  # authentication: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? 'plain' : nil,  
  domain:  ENV["USE_MANDRILL_MAILER"].to_i == 1 ?  ENV['MANDRILL_SMTP_DOMAIN'] : ENV["MAILER_SMTP_DOMAIN"],  
  enable_starttls_auto:  ENV["USE_MANDRILL_MAILER"].to_i == 1 ? true : false,  
  tls: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? true : false,  
  # password:  ENV["USE_MANDRILL_MAILER"].to_i == 1 ?  ENV['MANDRILL_SMTP_PASSWORD'] : ENV["MAILER_SMTP_PASSWORD"],  
  port:  ENV["USE_MANDRILL_MAILER"].to_i == 1 ?  ENV['MANDRILL_SMTP_PORT'] : ENV["MAILER_SMTP_PORT"],  
  # user_name:  ENV["USE_MANDRILL_MAILER"].to_i == 1 ?  ENV['MANDRILL_SMTP_USERNAME'] : ENV["MAILER_SMTP_USERNAME"],  
 # openssl_verify_mode: "none",}  
  
if ENV["USE_MANDRILL_MAILER"].to_i == 1  
 smtp_settings[:authentication] = 'plain'  
  smtp_settings[:password] = ENV['MANDRILL_SMTP_PASSWORD']  
  smtp_settings[:user_name] = ENV['MANDRILL_SMTP_USERNAME']  
end  
  
ActionMailer::Base.smtp_settings = smtp_settings  
  
ActionMailer::Base.default_url_options = { :host => ENV["BASE_URL_FE"] }  
ActionMailer::Base.register_preview_interceptor(ActionMailer::InlinePreviewInterceptor)  
  
# Don't care if the mailer can't send.  
ActionMailer::Base.raise_delivery_errors = true  
ActionMailer::Base.perform_deliveries = true  
ActionMailer::Base.perform_caching = false  
  
MandrillMailer.configure do |config|  
  config.api_key = ENV["MANDRILL_SMTP_PASSWORD"]  
  config.deliver_later_queue_name = :default  
end
```
 

 # How to Use 

### Mandrill Example


```ruby
class MandrillMailer  
  class << self  
 def send_email(customer: nil, email_template: nil, attachments: nil, description: nil)  
      raise "invalid customer" if customer.nil?  
      raise "invalid template" if email_template.nil?  
      begin  
  response = ::DcidevMailer::Mandrill.send_email(  
          subject: email_template.subject,  
          html_body: MailerHelper.format_wording(email_template.wording, customer),  
          header_url: email_template.header.try(:url),  
          footer_url: email_template.footer.try(:url),  
          to: customer.email,  
          cc: nil,
          bcc: nil,
          from: ENV['DEFAULT_EMAIL_SENDER'],  
          attachments: attachments,  
          email_template_path: "mail/blast.html.erb" # specify template file location
  )  
      rescue => e  
 error_message = "[SEND EMAIL] " + e.try(:to_s)  
      ensure  
  EmailHistory.create(application: customer.application, template: email_template, status: response[0]["status"] == "sent" ? :sent : :failed, mail_provider_id: response[0]["_id"], form_cetak_attachment: attachments.present?, error_message: response[0]["reject_reason"]) if response.present?  
          ApplicationHistory.log(description: error_message || description, application: customer.application)  
      end  
 end endend
```

### Action Mailer Example
```ruby
class MortgageMailer  
  class << self  
 def email(customer: nil, template: nil, file_attachments: nil, description: nil)  
      begin  
  raise "invalid customer" if customer.nil?  
        raise "invalid template" if template.nil?  
        raise "email is empty" if customer.email.nil?  
 
        wording, _ = DcidevMailer.format_image_from_html(template.wording)  
        wording = MailerHelper.format_wording(wording,customer)  
  
        DcidevMailer::RailsMailer.email(  
          html_body: wording,  
          header_url: template.header.try(:url),  
          footer_url: template.footer.try(:url),  
          file_attachments: file_attachments,  
          to: customer.email,  
          cc: nil,
          bcc: nil,
          subject: template.subject,  
          from: ENV['DEFAULT_EMAIL_SENDER'],  
          template_path: "mail/blast.html.erb"  # specify template file location
  )  
      rescue => e  
 error_message = "[SEND EMAIL] " + e.try(:to_s)  
      ensure  
		  EmailHistory.create(status: error_message.present? ? :failed : :sent, error_message: error_message, application: customer.application, template: template, form_cetak_attachment: file_attachments.present?)  
	      ApplicationHistory.log(description: error_message || description, application: customer.application)  
      end  
 end end  
end
```

### Helpers
```ruby
# convert all image URL in <img src="url"> to <img src="cid:xxxx">
DcidevMailer::format_image_from_html(html)

# format array of attachment files
DcidevMailer::format_attachments(attachments)

# format email header & footer url to be embedded to html body
# refer to class DcidevMailer::Mandrill or DcidevMailer::Rails to understand more of this method
DcidevMailer::format_header_footer(header_url: "", footer_url: "", locals: {}, images: {})
```

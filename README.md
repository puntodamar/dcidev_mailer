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
    address: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? ENV['MANDRILL_SMTP_ADDRESS'] : ENV["MAILER_SMTP_ADDRESS"],
    # authentication: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? 'plain' : nil,
    domain: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? ENV['MANDRILL_SMTP_DOMAIN'] : ENV["MAILER_SMTP_DOMAIN"],
    enable_starttls_auto: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? true : false,
    tls: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? true : false,
    # password: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? ENV['MANDRILL_SMTP_PASSWORD'] : ENV["MAILER_SMTP_PASSWORD"],
    port: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? ENV['MANDRILL_SMTP_PORT'] : ENV["MAILER_SMTP_PORT"],
    # user_name: ENV["USE_MANDRILL_MAILER"].to_i == 1 ? ENV['MANDRILL_SMTP_USERNAME'] : ENV["MAILER_SMTP_USERNAME"],
    # openssl_verify_mode: "none",
}

if ENV["USE_MANDRILL_MAILER"].to_i == 1
 smtp_settings[:authentication] = 'plain'
 smtp_settings[:password] = ENV['MANDRILL_SMTP_PASSWORD']
 smtp_settings[:user_name] = ENV['MANDRILL_SMTP_USERNAME']
end

ActionMailer::Base.smtp_settings = smtp_settings

ActionMailer::Base.default_url_options = {
    host: ENV["BASE_URL_FE"]
}
ActionMailer::Base.register_preview_interceptor(ActionMailer::InlinePreviewInterceptor)

# Don 't care if the mailer can't send.
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.perform_caching = false

MandrillMailer.configure do |config|
    config.api_key = ENV["MANDRILL_SMTP_PASSWORD"]
    config.deliver_later_queue_name :default
end
```
 

 # How to Use 

### Mandrill Example


```ruby
require 'dcidev_mailer/mandrill'

class MandrillMailer
  class << self
    def send_email(customer: nil, email_template: nil, attachments: nil, description: nil)
        raise "invalid customer"if customer.nil?
        raise "invalid template" if email_template.nil?
        begin
            response = ::DcidevMailer::Mandrill.send_email(
                subject: email_template.subject,
                html_body: MailerHelper.format_wording(email_template.wording, customer),
                header_url: email_template.header.try(:url),
                footer_url: email_template.footer.try(:url),
                # to: customer.email / can also accept string
                to: [{name: "Punto Damar P", type: "to", email: "punto@privyid.tech"}],
                cc: nil, # can be a string / array
                bcc: nil, # can be a string / array
                from: ENV['DEFAULT_EMAIL_SENDER'],
                from_name: ENV['DEFAULT_EMAIL_SENDER_NAME'],
                attachments: attachments,
                email_template_path: "mail/blast.html.erb"
                # specify template file location
            )
        rescue => e
            error_message = "[SEND EMAIL] " + e.try(:to_s)
        ensure
             EmailHistory.create(application: customer.application, template: email_template, status: response[0]["status"] == "sent" ? :sent : :failed, mail_provider_id: response[0]["_id"], form_cetak_attachment: attachments.present?, error_message: response[0]["reject_reason"]) if response.present?
             ApplicationHistory.log(description: error_message || description, application: customer.application)
      end
  end 
end
```


### Mandrill Template Example
```ruby
require 'dcidev_mailer/mandrill_template'

class MandrillMailer
  class << self
    def send_email(customer: nil, email_template: nil, attachments: nil, description: nil)
        raise "invalid customer"if customer.nil?
        raise "invalid template" if email_template.nil?
        begin
            response = ::DcidevMailer::MandrillTemplate.send_email(
                subject: email_template.subject,
                header_url: email_template.header.try(:url),
                footer_url: email_template.footer.try(:url),
                template_name: 'customer blast',
                to: [{name: "Punto Damar P", type: "to", email: "punto@privyid.tech"}],
                vars: {customer_name: "Punto Damar P", bank_name: "Bang Jago"}, # template variable name configurable from mandrill dashboard
                cc: nil, # can be a string / array
                bcc: nil, # can be a string / array
                from: ENV['DEFAULT_EMAIL_SENDER'],
                from_name: ENV['DEFAULT_EMAIL_SENDER_NAME'],
                attachments: attachments,
            )
        rescue => e
            error_message = "[SEND EMAIL] " + e.try(:to_s)
        ensure
             EmailHistory.create(application: customer.application, template: email_template, status: response[0]["status"] == "sent" ? :sent : :failed, mail_provider_id: response[0]["_id"], form_cetak_attachment: attachments.present? , error_message : response[0]["reject_reason"]) if response.present?
             ApplicationHistory.log(description: error_message || description, application: customer.application)
      end
  end 
end
```

### Action Mailer Example
```ruby
require 'dcidev_mailer/rails_mailer'

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
                    to: "#{customer.name} <#{customer.email}>",  
                    cc: nil, # can be a string / array
                    bcc: ["John Doe <john.doe@gmail.com>", "Michael <michael@gmail.com>"], # can be a string / array
                    subject: template.subject,  
                    from: "#{ENV['DEFAULT_EMAIL_SENDER_NAME']} <#{ENV['DEFAULT_EMAIL_SENDER']}>",  
                    template_path: "mail/blast.html.erb"  # specify template file location
                ).deliver_now!  
            rescue => e  
                error_message = "[SEND EMAIL] " + e.try(:to_s)  
            ensure  
                EmailHistory.create(status: error_message.present? ? :failed : :sent, error_message: error_message, application: customer.application, template: template, form_cetak_attachment: file_attachments.present?)  
                ApplicationHistory.log(description: error_message || description, application: customer.application)  
            end  
        end 
    end  
end
```

### Sending Attachments
The attachment is an array of hashes containing attachment file and filename
```ruby
attachments = [{file: DcidevUtility.download_to_file(self.ktp.url), filename: self.reference_number}]
```

### Inline Images
The gem currently only supports header & footer for the email body. Since gmail do not support link-based image, you have to format the images as inline attachments and use CID (Content-ID) to display each of them. The gem automatically take care of the programming. You only have to specify a valid link as the parameter.

The example to set the image in the template is shown below. This method works for both `RailsMailer` and `MandrillMailer`.
```html
          <%
            header = attachments['header'].try(:url) || header
            footer = attachments['footer'].try(:url) || footer
          %>

          <% if header.present? %>
            <div id="header-section-img">

              <img
                src="<%= header %>"
                alt="Header Image"
                style="border-radius: 10px"
                width="100%"
                />

            </div>
          <% end %>
```

### Helpers
```ruby
# convert all image URL in <img src="url"> to <img src="cid:xxxx">
DcidevMailer::format_image_from_html(html)

# format array of attachment files
DcidevMailer::format_attachments(attachments)

# format email header & footer url to be embedded to html body
# refer to class DcidevMailer::Mandrill or DcidevMailer::Rails for more details about the usage
DcidevMailer::format_header_footer(header_url: "", footer_url: "", locals: {}, images: {})
```

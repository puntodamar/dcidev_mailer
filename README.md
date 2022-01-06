
ENV : 
```
DEFAULT_EMAIL_SENDER 
USE_MANDRILL_MAILER 
[EMAIL_PROVIDER]_SMTP_ADDRESS
 [EMAIL_PROVIDER]_SMTP_DOMAIN 
 [EMAIL_PROVIDER]_SMTP_PASSWORD 
 [EMAIL_PROVIDER]_SMTP_USERNAME 
 [EMAIL_PROVIDER]_SMTP_PORT 
 [EMAIL_PROVIDER]_SMTP_AUTO_TLS 
 [EMAIL_PROVIDER]_SMTP_TLS
 ```
 
 mandril 

```
response = ::DcidevMailer::Mandrill.send_email(  
  subject: email_template.subject,  
  html_body: email_template.wording,  
  header_url: email_template.header.try(:url),  
  footer_url: email_template.footer.try(:url),  
  to: customer.email,  
  # from: "from@gmail.com",  
  attachments: attachments,  
  email_template_path: "cimb_mailer/email.html.erb"  
)
```

action mailer
```
          DcidevMailer::Rails.email(
    html_body: template.wording,
    header_url: template.header.try(:url),
    footer_url: template.footer.try(:url),
    file_attachments: file_attachments,
    to: customer.email,
    subject: template.subject
  )
```

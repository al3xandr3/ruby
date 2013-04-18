
module Gmail
  require 'time'
  require 'net/smtp'
  extend self  
  def send(mail)
    msg = "Subject: #{mail[:subject]}\n\n#{mail[:body]}"
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start('gmail.com', mail[:from], mail[:password], :login) do
      smtp.send_message(msg, mail[:from], mail[:to])
    end
  end
end

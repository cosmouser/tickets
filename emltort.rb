require 'mail'
require 'net/smtp'


# Change this to the RT queue that you wish to create a ticket in
rt_queue = "queue@rt.host.domain"

def forward_to_rt(message, rt_queue)

  # Load the email using the mail gem
  mail = Mail.read(message)

  # Create the message
  msgstr = <<END_OF_MESSAGE
From: <#{mail.from.first}>
To: <#{rt_queue}>
Subject: #{mail.subject}
Date: #{mail.date.to_s}
Message-Id: <#{mail.message_id}>
#{mail.multipart? ? mail.parts.first.decoded : mail.body.encoded}
END_OF_MESSAGE

  # Send the ticket to RT using net/smtp
  Net::SMTP.start('rt.host.domain', 25) do |smtp|
    smtp.send_message	msgstr,
			mail.from.first,
			rt_queue
    smtp.finish
  end
end

if ARGV.first.nil?
  puts 'Please specify an email to forward to RT, ie ruby emltort.rb message.eml'
else
  forward_to_rt(ARGV.first, rt_queue)
end

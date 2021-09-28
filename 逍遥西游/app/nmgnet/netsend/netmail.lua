local netmail = {}
function netmail.getall()
  NetSend({}, S2C_Mail, "P1")
end
function netmail.read(mailId)
  NetSend({i_mid = mailId}, S2C_Mail, "P2")
end
function netmail.accept(mailId)
  NetSend({i_mid = mailId}, S2C_Mail, "P3")
end
return netmail

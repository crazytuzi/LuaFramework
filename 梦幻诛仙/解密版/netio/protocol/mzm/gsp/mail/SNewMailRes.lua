local MailData = require("netio.protocol.mzm.gsp.mail.MailData")
local SNewMailRes = class("SNewMailRes")
SNewMailRes.TYPEID = 12592904
function SNewMailRes:ctor(mailData)
  self.id = 12592904
  self.mailData = mailData or MailData.new()
end
function SNewMailRes:marshal(os)
  self.mailData:marshal(os)
end
function SNewMailRes:unmarshal(os)
  self.mailData = MailData.new()
  self.mailData:unmarshal(os)
end
function SNewMailRes:sizepolicy(size)
  return size <= 65535
end
return SNewMailRes

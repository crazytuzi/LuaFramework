local NoticeInfo = require("netio.protocol.mzm.gsp.idip.NoticeInfo")
local SSyncNotice = class("SSyncNotice")
SSyncNotice.TYPEID = 12601100
function SSyncNotice:ctor(notice)
  self.id = 12601100
  self.notice = notice or NoticeInfo.new()
end
function SSyncNotice:marshal(os)
  self.notice:marshal(os)
end
function SSyncNotice:unmarshal(os)
  self.notice = NoticeInfo.new()
  self.notice:unmarshal(os)
end
function SSyncNotice:sizepolicy(size)
  return size <= 65535
end
return SSyncNotice

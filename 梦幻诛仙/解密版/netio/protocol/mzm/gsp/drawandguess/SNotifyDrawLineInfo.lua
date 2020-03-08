local DrawLineInfo = require("netio.protocol.mzm.gsp.drawandguess.DrawLineInfo")
local SNotifyDrawLineInfo = class("SNotifyDrawLineInfo")
SNotifyDrawLineInfo.TYPEID = 12617239
function SNotifyDrawLineInfo:ctor(drawLineInfo)
  self.id = 12617239
  self.drawLineInfo = drawLineInfo or DrawLineInfo.new()
end
function SNotifyDrawLineInfo:marshal(os)
  self.drawLineInfo:marshal(os)
end
function SNotifyDrawLineInfo:unmarshal(os)
  self.drawLineInfo = DrawLineInfo.new()
  self.drawLineInfo:unmarshal(os)
end
function SNotifyDrawLineInfo:sizepolicy(size)
  return size <= 65535
end
return SNotifyDrawLineInfo

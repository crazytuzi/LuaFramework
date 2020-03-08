local WingInfo = require("netio.protocol.mzm.gsp.wing.WingInfo")
local SResetWing = class("SResetWing")
SResetWing.TYPEID = 12596505
function SResetWing:ctor(index, wingInfo)
  self.id = 12596505
  self.index = index or nil
  self.wingInfo = wingInfo or WingInfo.new()
end
function SResetWing:marshal(os)
  os:marshalInt32(self.index)
  self.wingInfo:marshal(os)
end
function SResetWing:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.wingInfo = WingInfo.new()
  self.wingInfo:unmarshal(os)
end
function SResetWing:sizepolicy(size)
  return size <= 65535
end
return SResetWing

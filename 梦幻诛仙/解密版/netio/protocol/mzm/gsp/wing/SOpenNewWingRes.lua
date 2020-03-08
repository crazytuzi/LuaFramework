local WingInfo = require("netio.protocol.mzm.gsp.wing.WingInfo")
local SOpenNewWingRes = class("SOpenNewWingRes")
SOpenNewWingRes.TYPEID = 12596484
function SOpenNewWingRes:ctor(curIndex, openIndex, newWingInfo)
  self.id = 12596484
  self.curIndex = curIndex or nil
  self.openIndex = openIndex or nil
  self.newWingInfo = newWingInfo or WingInfo.new()
end
function SOpenNewWingRes:marshal(os)
  os:marshalInt32(self.curIndex)
  os:marshalInt32(self.openIndex)
  self.newWingInfo:marshal(os)
end
function SOpenNewWingRes:unmarshal(os)
  self.curIndex = os:unmarshalInt32()
  self.openIndex = os:unmarshalInt32()
  self.newWingInfo = WingInfo.new()
  self.newWingInfo:unmarshal(os)
end
function SOpenNewWingRes:sizepolicy(size)
  return size <= 65535
end
return SOpenNewWingRes

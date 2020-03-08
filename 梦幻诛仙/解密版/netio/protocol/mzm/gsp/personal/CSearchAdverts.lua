local ConditionInfo = require("netio.protocol.mzm.gsp.personal.ConditionInfo")
local CSearchAdverts = class("CSearchAdverts")
CSearchAdverts.TYPEID = 12603664
function CSearchAdverts:ctor(advertType, page, refresh, condition)
  self.id = 12603664
  self.advertType = advertType or nil
  self.page = page or nil
  self.refresh = refresh or nil
  self.condition = condition or ConditionInfo.new()
end
function CSearchAdverts:marshal(os)
  os:marshalInt32(self.advertType)
  os:marshalInt32(self.page)
  os:marshalInt32(self.refresh)
  self.condition:marshal(os)
end
function CSearchAdverts:unmarshal(os)
  self.advertType = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
  self.refresh = os:unmarshalInt32()
  self.condition = ConditionInfo.new()
  self.condition:unmarshal(os)
end
function CSearchAdverts:sizepolicy(size)
  return size <= 65535
end
return CSearchAdverts

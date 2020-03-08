local SGetGangSimpleInfo = class("SGetGangSimpleInfo")
SGetGangSimpleInfo.TYPEID = 12589851
function SGetGangSimpleInfo:ctor(gangId, gangName)
  self.id = 12589851
  self.gangId = gangId or nil
  self.gangName = gangName or nil
end
function SGetGangSimpleInfo:marshal(os)
  os:marshalInt64(self.gangId)
  os:marshalString(self.gangName)
end
function SGetGangSimpleInfo:unmarshal(os)
  self.gangId = os:unmarshalInt64()
  self.gangName = os:unmarshalString()
end
function SGetGangSimpleInfo:sizepolicy(size)
  return size <= 65535
end
return SGetGangSimpleInfo

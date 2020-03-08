local SChangeTitleOrAppellationReq = class("SChangeTitleOrAppellationReq")
SChangeTitleOrAppellationReq.TYPEID = 12593928
function SChangeTitleOrAppellationReq:ctor(changeId, changeType)
  self.id = 12593928
  self.changeId = changeId or nil
  self.changeType = changeType or nil
end
function SChangeTitleOrAppellationReq:marshal(os)
  os:marshalInt32(self.changeId)
  os:marshalInt32(self.changeType)
end
function SChangeTitleOrAppellationReq:unmarshal(os)
  self.changeId = os:unmarshalInt32()
  self.changeType = os:unmarshalInt32()
end
function SChangeTitleOrAppellationReq:sizepolicy(size)
  return size <= 65535
end
return SChangeTitleOrAppellationReq

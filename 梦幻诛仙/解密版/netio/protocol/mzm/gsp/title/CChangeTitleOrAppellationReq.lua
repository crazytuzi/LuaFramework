local CChangeTitleOrAppellationReq = class("CChangeTitleOrAppellationReq")
CChangeTitleOrAppellationReq.TYPEID = 12593927
function CChangeTitleOrAppellationReq:ctor(changeId, changeType)
  self.id = 12593927
  self.changeId = changeId or nil
  self.changeType = changeType or nil
end
function CChangeTitleOrAppellationReq:marshal(os)
  os:marshalInt32(self.changeId)
  os:marshalInt32(self.changeType)
end
function CChangeTitleOrAppellationReq:unmarshal(os)
  self.changeId = os:unmarshalInt32()
  self.changeType = os:unmarshalInt32()
end
function CChangeTitleOrAppellationReq:sizepolicy(size)
  return size <= 65535
end
return CChangeTitleOrAppellationReq

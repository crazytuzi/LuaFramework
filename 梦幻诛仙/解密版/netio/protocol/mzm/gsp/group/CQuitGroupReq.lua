local CQuitGroupReq = class("CQuitGroupReq")
CQuitGroupReq.TYPEID = 12605200
function CQuitGroupReq:ctor(groupid)
  self.id = 12605200
  self.groupid = groupid or nil
end
function CQuitGroupReq:marshal(os)
  os:marshalInt64(self.groupid)
end
function CQuitGroupReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
end
function CQuitGroupReq:sizepolicy(size)
  return size <= 65535
end
return CQuitGroupReq

local CGetSingleGroupInfoReq = class("CGetSingleGroupInfoReq")
CGetSingleGroupInfoReq.TYPEID = 12605213
function CGetSingleGroupInfoReq:ctor(groupid, info_version)
  self.id = 12605213
  self.groupid = groupid or nil
  self.info_version = info_version or nil
end
function CGetSingleGroupInfoReq:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt64(self.info_version)
end
function CGetSingleGroupInfoReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.info_version = os:unmarshalInt64()
end
function CGetSingleGroupInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetSingleGroupInfoReq

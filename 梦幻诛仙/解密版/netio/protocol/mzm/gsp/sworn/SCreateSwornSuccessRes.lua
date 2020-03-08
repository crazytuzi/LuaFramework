local SCreateSwornSuccessRes = class("SCreateSwornSuccessRes")
SCreateSwornSuccessRes.TYPEID = 12597768
function SCreateSwornSuccessRes:ctor(swornid)
  self.id = 12597768
  self.swornid = swornid or nil
end
function SCreateSwornSuccessRes:marshal(os)
  os:marshalInt64(self.swornid)
end
function SCreateSwornSuccessRes:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function SCreateSwornSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SCreateSwornSuccessRes

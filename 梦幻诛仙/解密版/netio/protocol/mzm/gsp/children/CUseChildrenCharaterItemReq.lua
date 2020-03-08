local CUseChildrenCharaterItemReq = class("CUseChildrenCharaterItemReq")
CUseChildrenCharaterItemReq.TYPEID = 12609408
function CUseChildrenCharaterItemReq:ctor(childrenid, itemKey)
  self.id = 12609408
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
end
function CUseChildrenCharaterItemReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
end
function CUseChildrenCharaterItemReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CUseChildrenCharaterItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseChildrenCharaterItemReq

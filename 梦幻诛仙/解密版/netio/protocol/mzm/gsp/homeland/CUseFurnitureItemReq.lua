local CUseFurnitureItemReq = class("CUseFurnitureItemReq")
CUseFurnitureItemReq.TYPEID = 12605485
function CUseFurnitureItemReq:ctor(uuid)
  self.id = 12605485
  self.uuid = uuid or nil
end
function CUseFurnitureItemReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseFurnitureItemReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseFurnitureItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseFurnitureItemReq

local CUseItemReq = class("CUseItemReq")
CUseItemReq.TYPEID = 12590640
CUseItemReq.ADD_EXP_ACTION = 0
CUseItemReq.ADD_LIFE_ACTION = 1
CUseItemReq.ADD_GROW_ACTION = 2
function CUseItemReq:ctor(petId, itemKey, actionType)
  self.id = 12590640
  self.petId = petId or nil
  self.itemKey = itemKey or nil
  self.actionType = actionType or nil
end
function CUseItemReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.actionType)
end
function CUseItemReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
  self.actionType = os:unmarshalInt32()
end
function CUseItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseItemReq

local SKitchenLevelUpRes = class("SKitchenLevelUpRes")
SKitchenLevelUpRes.TYPEID = 12605489
function SKitchenLevelUpRes:ctor(kitchenLevel)
  self.id = 12605489
  self.kitchenLevel = kitchenLevel or nil
end
function SKitchenLevelUpRes:marshal(os)
  os:marshalInt32(self.kitchenLevel)
end
function SKitchenLevelUpRes:unmarshal(os)
  self.kitchenLevel = os:unmarshalInt32()
end
function SKitchenLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SKitchenLevelUpRes

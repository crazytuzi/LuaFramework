local CPetMarkUpgradeWithMarkReq = class("CPetMarkUpgradeWithMarkReq")
CPetMarkUpgradeWithMarkReq.TYPEID = 12628505
function CPetMarkUpgradeWithMarkReq:ctor(main_pet_mark_id, cost_pet_mark_id)
  self.id = 12628505
  self.main_pet_mark_id = main_pet_mark_id or nil
  self.cost_pet_mark_id = cost_pet_mark_id or nil
end
function CPetMarkUpgradeWithMarkReq:marshal(os)
  os:marshalInt64(self.main_pet_mark_id)
  os:marshalInt64(self.cost_pet_mark_id)
end
function CPetMarkUpgradeWithMarkReq:unmarshal(os)
  self.main_pet_mark_id = os:unmarshalInt64()
  self.cost_pet_mark_id = os:unmarshalInt64()
end
function CPetMarkUpgradeWithMarkReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkUpgradeWithMarkReq

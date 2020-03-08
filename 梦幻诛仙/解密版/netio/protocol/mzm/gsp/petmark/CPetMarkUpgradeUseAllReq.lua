local CPetMarkUpgradeUseAllReq = class("CPetMarkUpgradeUseAllReq")
CPetMarkUpgradeUseAllReq.TYPEID = 12628485
function CPetMarkUpgradeUseAllReq:ctor(main_pet_mark_id)
  self.id = 12628485
  self.main_pet_mark_id = main_pet_mark_id or nil
end
function CPetMarkUpgradeUseAllReq:marshal(os)
  os:marshalInt64(self.main_pet_mark_id)
end
function CPetMarkUpgradeUseAllReq:unmarshal(os)
  self.main_pet_mark_id = os:unmarshalInt64()
end
function CPetMarkUpgradeUseAllReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkUpgradeUseAllReq

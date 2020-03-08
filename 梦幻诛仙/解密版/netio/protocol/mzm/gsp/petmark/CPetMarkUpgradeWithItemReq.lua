local CPetMarkUpgradeWithItemReq = class("CPetMarkUpgradeWithItemReq")
CPetMarkUpgradeWithItemReq.TYPEID = 12628493
function CPetMarkUpgradeWithItemReq:ctor(main_pet_mark_id, cost_item_cfg_id, use_all)
  self.id = 12628493
  self.main_pet_mark_id = main_pet_mark_id or nil
  self.cost_item_cfg_id = cost_item_cfg_id or nil
  self.use_all = use_all or nil
end
function CPetMarkUpgradeWithItemReq:marshal(os)
  os:marshalInt64(self.main_pet_mark_id)
  os:marshalInt32(self.cost_item_cfg_id)
  os:marshalUInt8(self.use_all)
end
function CPetMarkUpgradeWithItemReq:unmarshal(os)
  self.main_pet_mark_id = os:unmarshalInt64()
  self.cost_item_cfg_id = os:unmarshalInt32()
  self.use_all = os:unmarshalUInt8()
end
function CPetMarkUpgradeWithItemReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkUpgradeWithItemReq

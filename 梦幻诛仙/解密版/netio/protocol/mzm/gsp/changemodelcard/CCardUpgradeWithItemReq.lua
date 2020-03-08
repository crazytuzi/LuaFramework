local CCardUpgradeWithItemReq = class("CCardUpgradeWithItemReq")
CCardUpgradeWithItemReq.TYPEID = 12624390
function CCardUpgradeWithItemReq:ctor(main_card_id, cost_item_cfg_id, use_all)
  self.id = 12624390
  self.main_card_id = main_card_id or nil
  self.cost_item_cfg_id = cost_item_cfg_id or nil
  self.use_all = use_all or nil
end
function CCardUpgradeWithItemReq:marshal(os)
  os:marshalInt64(self.main_card_id)
  os:marshalInt32(self.cost_item_cfg_id)
  os:marshalUInt8(self.use_all)
end
function CCardUpgradeWithItemReq:unmarshal(os)
  self.main_card_id = os:unmarshalInt64()
  self.cost_item_cfg_id = os:unmarshalInt32()
  self.use_all = os:unmarshalUInt8()
end
function CCardUpgradeWithItemReq:sizepolicy(size)
  return size <= 65535
end
return CCardUpgradeWithItemReq

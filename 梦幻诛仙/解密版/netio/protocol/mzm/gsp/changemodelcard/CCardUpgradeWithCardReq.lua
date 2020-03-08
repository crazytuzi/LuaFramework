local CCardUpgradeWithCardReq = class("CCardUpgradeWithCardReq")
CCardUpgradeWithCardReq.TYPEID = 12624404
function CCardUpgradeWithCardReq:ctor(main_card_id, cost_card_id)
  self.id = 12624404
  self.main_card_id = main_card_id or nil
  self.cost_card_id = cost_card_id or nil
end
function CCardUpgradeWithCardReq:marshal(os)
  os:marshalInt64(self.main_card_id)
  os:marshalInt64(self.cost_card_id)
end
function CCardUpgradeWithCardReq:unmarshal(os)
  self.main_card_id = os:unmarshalInt64()
  self.cost_card_id = os:unmarshalInt64()
end
function CCardUpgradeWithCardReq:sizepolicy(size)
  return size <= 65535
end
return CCardUpgradeWithCardReq

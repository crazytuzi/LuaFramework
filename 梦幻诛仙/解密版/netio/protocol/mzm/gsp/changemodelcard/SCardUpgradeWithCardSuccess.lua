local SCardUpgradeWithCardSuccess = class("SCardUpgradeWithCardSuccess")
SCardUpgradeWithCardSuccess.TYPEID = 12624393
function SCardUpgradeWithCardSuccess:ctor(main_card_id, now_level, now_exp, add_exp)
  self.id = 12624393
  self.main_card_id = main_card_id or nil
  self.now_level = now_level or nil
  self.now_exp = now_exp or nil
  self.add_exp = add_exp or nil
end
function SCardUpgradeWithCardSuccess:marshal(os)
  os:marshalInt64(self.main_card_id)
  os:marshalInt32(self.now_level)
  os:marshalInt32(self.now_exp)
  os:marshalInt32(self.add_exp)
end
function SCardUpgradeWithCardSuccess:unmarshal(os)
  self.main_card_id = os:unmarshalInt64()
  self.now_level = os:unmarshalInt32()
  self.now_exp = os:unmarshalInt32()
  self.add_exp = os:unmarshalInt32()
end
function SCardUpgradeWithCardSuccess:sizepolicy(size)
  return size <= 65535
end
return SCardUpgradeWithCardSuccess

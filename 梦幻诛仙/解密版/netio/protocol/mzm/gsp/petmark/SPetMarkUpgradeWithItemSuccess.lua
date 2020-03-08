local SPetMarkUpgradeWithItemSuccess = class("SPetMarkUpgradeWithItemSuccess")
SPetMarkUpgradeWithItemSuccess.TYPEID = 12628509
function SPetMarkUpgradeWithItemSuccess:ctor(main_pet_mark_id, now_level, now_exp, add_exp)
  self.id = 12628509
  self.main_pet_mark_id = main_pet_mark_id or nil
  self.now_level = now_level or nil
  self.now_exp = now_exp or nil
  self.add_exp = add_exp or nil
end
function SPetMarkUpgradeWithItemSuccess:marshal(os)
  os:marshalInt64(self.main_pet_mark_id)
  os:marshalInt32(self.now_level)
  os:marshalInt32(self.now_exp)
  os:marshalInt32(self.add_exp)
end
function SPetMarkUpgradeWithItemSuccess:unmarshal(os)
  self.main_pet_mark_id = os:unmarshalInt64()
  self.now_level = os:unmarshalInt32()
  self.now_exp = os:unmarshalInt32()
  self.add_exp = os:unmarshalInt32()
end
function SPetMarkUpgradeWithItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetMarkUpgradeWithItemSuccess

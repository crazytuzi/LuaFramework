local SGangHelpAddItemSuc = class("SGangHelpAddItemSuc")
SGangHelpAddItemSuc.TYPEID = 12584463
function SGangHelpAddItemSuc:ctor(roleNameOfferHelp, roleNameSeekHelp, itemCfgId, itemNum)
  self.id = 12584463
  self.roleNameOfferHelp = roleNameOfferHelp or nil
  self.roleNameSeekHelp = roleNameSeekHelp or nil
  self.itemCfgId = itemCfgId or nil
  self.itemNum = itemNum or nil
end
function SGangHelpAddItemSuc:marshal(os)
  os:marshalString(self.roleNameOfferHelp)
  os:marshalString(self.roleNameSeekHelp)
  os:marshalInt32(self.itemCfgId)
  os:marshalInt32(self.itemNum)
end
function SGangHelpAddItemSuc:unmarshal(os)
  self.roleNameOfferHelp = os:unmarshalString()
  self.roleNameSeekHelp = os:unmarshalString()
  self.itemCfgId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
function SGangHelpAddItemSuc:sizepolicy(size)
  return size <= 65535
end
return SGangHelpAddItemSuc

local SCrossBattleSelectionPanelInfo = class("SCrossBattleSelectionPanelInfo")
SCrossBattleSelectionPanelInfo.TYPEID = 12616996
function SCrossBattleSelectionPanelInfo:ctor(is_five_role_team, is_in_one_corps, is_can_take_part_in_selection, is_role_same_with_sign_up)
  self.id = 12616996
  self.is_five_role_team = is_five_role_team or nil
  self.is_in_one_corps = is_in_one_corps or nil
  self.is_can_take_part_in_selection = is_can_take_part_in_selection or nil
  self.is_role_same_with_sign_up = is_role_same_with_sign_up or nil
end
function SCrossBattleSelectionPanelInfo:marshal(os)
  os:marshalUInt8(self.is_five_role_team)
  os:marshalUInt8(self.is_in_one_corps)
  os:marshalUInt8(self.is_can_take_part_in_selection)
  os:marshalUInt8(self.is_role_same_with_sign_up)
end
function SCrossBattleSelectionPanelInfo:unmarshal(os)
  self.is_five_role_team = os:unmarshalUInt8()
  self.is_in_one_corps = os:unmarshalUInt8()
  self.is_can_take_part_in_selection = os:unmarshalUInt8()
  self.is_role_same_with_sign_up = os:unmarshalUInt8()
end
function SCrossBattleSelectionPanelInfo:sizepolicy(size)
  return size <= 65535
end
return SCrossBattleSelectionPanelInfo

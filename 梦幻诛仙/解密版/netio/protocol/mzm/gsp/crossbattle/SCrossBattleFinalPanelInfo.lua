local SCrossBattleFinalPanelInfo = class("SCrossBattleFinalPanelInfo")
SCrossBattleFinalPanelInfo.TYPEID = 12617053
function SCrossBattleFinalPanelInfo:ctor(is_five_role_team, is_in_one_corps, is_can_take_part_in_Final, is_role_same_with_sign_up)
  self.id = 12617053
  self.is_five_role_team = is_five_role_team or nil
  self.is_in_one_corps = is_in_one_corps or nil
  self.is_can_take_part_in_Final = is_can_take_part_in_Final or nil
  self.is_role_same_with_sign_up = is_role_same_with_sign_up or nil
end
function SCrossBattleFinalPanelInfo:marshal(os)
  os:marshalUInt8(self.is_five_role_team)
  os:marshalUInt8(self.is_in_one_corps)
  os:marshalUInt8(self.is_can_take_part_in_Final)
  os:marshalUInt8(self.is_role_same_with_sign_up)
end
function SCrossBattleFinalPanelInfo:unmarshal(os)
  self.is_five_role_team = os:unmarshalUInt8()
  self.is_in_one_corps = os:unmarshalUInt8()
  self.is_can_take_part_in_Final = os:unmarshalUInt8()
  self.is_role_same_with_sign_up = os:unmarshalUInt8()
end
function SCrossBattleFinalPanelInfo:sizepolicy(size)
  return size <= 65535
end
return SCrossBattleFinalPanelInfo

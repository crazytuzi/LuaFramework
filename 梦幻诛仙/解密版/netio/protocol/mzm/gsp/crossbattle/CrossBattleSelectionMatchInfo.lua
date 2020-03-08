local OctetsStream = require("netio.OctetsStream")
local CrossBattleSelectionMatchInfo = class("CrossBattleSelectionMatchInfo")
function CrossBattleSelectionMatchInfo:ctor(corps_id, corps_name, corps_icon, corps_zone_id, match_role_list)
  self.corps_id = corps_id or nil
  self.corps_name = corps_name or nil
  self.corps_icon = corps_icon or nil
  self.corps_zone_id = corps_zone_id or nil
  self.match_role_list = match_role_list or {}
end
function CrossBattleSelectionMatchInfo:marshal(os)
  os:marshalInt64(self.corps_id)
  os:marshalOctets(self.corps_name)
  os:marshalInt32(self.corps_icon)
  os:marshalInt32(self.corps_zone_id)
  os:marshalCompactUInt32(table.getn(self.match_role_list))
  for _, v in ipairs(self.match_role_list) do
    v:marshal(os)
  end
end
function CrossBattleSelectionMatchInfo:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
  self.corps_name = os:unmarshalOctets()
  self.corps_icon = os:unmarshalInt32()
  self.corps_zone_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleSelectionMatchRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.match_role_list, v)
  end
end
return CrossBattleSelectionMatchInfo

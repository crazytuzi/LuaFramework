local SSyncRoleCompete = class("SSyncRoleCompete")
SSyncRoleCompete.TYPEID = 12616740
function SSyncRoleCompete:ctor(action_point, factionid, designed_titleid, compete_index)
  self.id = 12616740
  self.action_point = action_point or nil
  self.factionid = factionid or nil
  self.designed_titleid = designed_titleid or nil
  self.compete_index = compete_index or nil
end
function SSyncRoleCompete:marshal(os)
  os:marshalInt32(self.action_point)
  os:marshalInt64(self.factionid)
  os:marshalInt32(self.designed_titleid)
  os:marshalInt32(self.compete_index)
end
function SSyncRoleCompete:unmarshal(os)
  self.action_point = os:unmarshalInt32()
  self.factionid = os:unmarshalInt64()
  self.designed_titleid = os:unmarshalInt32()
  self.compete_index = os:unmarshalInt32()
end
function SSyncRoleCompete:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleCompete

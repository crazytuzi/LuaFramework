local SSynCakeHistory = class("SSynCakeHistory")
SSynCakeHistory.TYPEID = 12627722
function SSynCakeHistory:ctor(activityId, factionId, roleId, history)
  self.id = 12627722
  self.activityId = activityId or nil
  self.factionId = factionId or nil
  self.roleId = roleId or nil
  self.history = history or {}
end
function SSynCakeHistory:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt64(self.factionId)
  os:marshalInt64(self.roleId)
  os:marshalCompactUInt32(table.getn(self.history))
  for _, v in ipairs(self.history) do
    v:marshal(os)
  end
end
function SSynCakeHistory:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.factionId = os:unmarshalInt64()
  self.roleId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.cake.CakeHistory")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.history, v)
  end
end
function SSynCakeHistory:sizepolicy(size)
  return size <= 65535
end
return SSynCakeHistory

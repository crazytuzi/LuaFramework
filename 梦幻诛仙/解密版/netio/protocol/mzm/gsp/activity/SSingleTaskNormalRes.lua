local SSingleTaskNormalRes = class("SSingleTaskNormalRes")
SSingleTaskNormalRes.TYPEID = 12587605
SSingleTaskNormalRes.SINGLE_ROLE_TEAM = 1
SSingleTaskNormalRes.ACTIVITY_IN_FORCE_CLOSE = 2
SSingleTaskNormalRes.ACTIVITY_IN_PAUSE = 3
SSingleTaskNormalRes.ACTIVITY_COUNT_TO_MAX = 4
SSingleTaskNormalRes.NOT_NEAR_NPC = 5
SSingleTaskNormalRes.ALREADY_OWN_GRAPH = 6
function SSingleTaskNormalRes:ctor(result, args)
  self.id = 12587605
  self.result = result or nil
  self.args = args or {}
end
function SSingleTaskNormalRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SSingleTaskNormalRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SSingleTaskNormalRes:sizepolicy(size)
  return size <= 65535
end
return SSingleTaskNormalRes

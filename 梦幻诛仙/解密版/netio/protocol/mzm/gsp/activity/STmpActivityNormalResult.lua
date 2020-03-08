local STmpActivityNormalResult = class("STmpActivityNormalResult")
STmpActivityNormalResult.TYPEID = 12587596
STmpActivityNormalResult.JOIN_ACTIVITY_ERROR__ALREADY_DONE = 1
STmpActivityNormalResult.JOIN_ACTIVITY_ERROR__NOT_NEAR_NPC = 2
STmpActivityNormalResult.JOIN_ACTIVITY_ERROR__ALREADY_ACCEPT = 3
STmpActivityNormalResult.JOIN_ACTIVITY_ERROR__BAN = 4
STmpActivityNormalResult.JOIN_ACTIVITY_ERROR__OPEN_CLOSE = 5
function STmpActivityNormalResult:ctor(result, args)
  self.id = 12587596
  self.result = result or nil
  self.args = args or {}
end
function STmpActivityNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function STmpActivityNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function STmpActivityNormalResult:sizepolicy(size)
  return size <= 65535
end
return STmpActivityNormalResult

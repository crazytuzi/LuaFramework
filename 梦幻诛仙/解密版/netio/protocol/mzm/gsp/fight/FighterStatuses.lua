local OctetsStream = require("netio.OctetsStream")
local FighterStatuses = class("FighterStatuses")
function FighterStatuses:ctor(statuses)
  self.statuses = statuses or {}
end
function FighterStatuses:marshal(os)
  os:marshalCompactUInt32(table.getn(self.statuses))
  for _, v in ipairs(self.statuses) do
    v:marshal(os)
  end
end
function FighterStatuses:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatus")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.statuses, v)
  end
end
return FighterStatuses

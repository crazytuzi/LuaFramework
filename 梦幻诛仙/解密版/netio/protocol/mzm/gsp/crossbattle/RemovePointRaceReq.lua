local OctetsStream = require("netio.OctetsStream")
local RemovePointRaceReq = class("RemovePointRaceReq")
function RemovePointRaceReq:ctor(corpsids, fight_num)
  self.corpsids = corpsids or {}
  self.fight_num = fight_num or nil
end
function RemovePointRaceReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.corpsids))
  for _, v in ipairs(self.corpsids) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.fight_num)
end
function RemovePointRaceReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.corpsids, v)
  end
  self.fight_num = os:unmarshalInt32()
end
return RemovePointRaceReq

local OctetsStream = require("netio.OctetsStream")
local GetPointRaceResultReq = class("GetPointRaceResultReq")
function GetPointRaceResultReq:ctor(corpsids, time_points)
  self.corpsids = corpsids or {}
  self.time_points = time_points or {}
end
function GetPointRaceResultReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.corpsids))
  for _, v in ipairs(self.corpsids) do
    os:marshalInt64(v)
  end
  os:marshalCompactUInt32(table.getn(self.time_points))
  for _, v in ipairs(self.time_points) do
    os:marshalInt32(v)
  end
end
function GetPointRaceResultReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.corpsids, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.time_points, v)
  end
end
return GetPointRaceResultReq

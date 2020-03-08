local OctetsStream = require("netio.OctetsStream")
local GetPointRaceDataReq = class("GetPointRaceDataReq")
function GetPointRaceDataReq:ctor(roleid, from, to, index, time_points)
  self.roleid = roleid or nil
  self.from = from or nil
  self.to = to or nil
  self.index = index or nil
  self.time_points = time_points or {}
end
function GetPointRaceDataReq:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
  os:marshalInt32(self.index)
  os:marshalCompactUInt32(table.getn(self.time_points))
  for _, v in ipairs(self.time_points) do
    os:marshalInt32(v)
  end
end
function GetPointRaceDataReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.time_points, v)
  end
end
return GetPointRaceDataReq

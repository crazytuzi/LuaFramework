local OctetsStream = require("netio.OctetsStream")
local PointRaceRankData = class("PointRaceRankData")
function PointRaceRankData:ctor(zoneid, corps_name, icon, rank, point)
  self.zoneid = zoneid or nil
  self.corps_name = corps_name or nil
  self.icon = icon or nil
  self.rank = rank or nil
  self.point = point or nil
end
function PointRaceRankData:marshal(os)
  os:marshalInt32(self.zoneid)
  os:marshalOctets(self.corps_name)
  os:marshalInt32(self.icon)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.point)
end
function PointRaceRankData:unmarshal(os)
  self.zoneid = os:unmarshalInt32()
  self.corps_name = os:unmarshalOctets()
  self.icon = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
end
return PointRaceRankData

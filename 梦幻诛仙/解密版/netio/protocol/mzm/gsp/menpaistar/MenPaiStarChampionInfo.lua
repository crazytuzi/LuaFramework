local OctetsStream = require("netio.OctetsStream")
local MenPaiStarChampionInfo = class("MenPaiStarChampionInfo")
function MenPaiStarChampionInfo:ctor(roleid, role_name, occupationid, point)
  self.roleid = roleid or nil
  self.role_name = role_name or nil
  self.occupationid = occupationid or nil
  self.point = point or nil
end
function MenPaiStarChampionInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.occupationid)
  os:marshalInt32(self.point)
end
function MenPaiStarChampionInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.occupationid = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
end
return MenPaiStarChampionInfo

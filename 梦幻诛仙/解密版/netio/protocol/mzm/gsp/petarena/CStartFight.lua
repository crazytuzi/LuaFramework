local CStartFight = class("CStartFight")
CStartFight.TYPEID = 12628226
function CStartFight:ctor(target_roleid, rank, teamid, serial)
  self.id = 12628226
  self.target_roleid = target_roleid or nil
  self.rank = rank or nil
  self.teamid = teamid or nil
  self.serial = serial or nil
end
function CStartFight:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.teamid)
  os:marshalInt32(self.serial)
end
function CStartFight:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.teamid = os:unmarshalInt32()
  self.serial = os:unmarshalInt32()
end
function CStartFight:sizepolicy(size)
  return size <= 65535
end
return CStartFight

local SKillRelatedMonsterBrd = class("SKillRelatedMonsterBrd")
SKillRelatedMonsterBrd.TYPEID = 12613649
function SKillRelatedMonsterBrd:ctor(leader_name, related_monster, bossid)
  self.id = 12613649
  self.leader_name = leader_name or nil
  self.related_monster = related_monster or nil
  self.bossid = bossid or nil
end
function SKillRelatedMonsterBrd:marshal(os)
  os:marshalString(self.leader_name)
  os:marshalInt32(self.related_monster)
  os:marshalInt32(self.bossid)
end
function SKillRelatedMonsterBrd:unmarshal(os)
  self.leader_name = os:unmarshalString()
  self.related_monster = os:unmarshalInt32()
  self.bossid = os:unmarshalInt32()
end
function SKillRelatedMonsterBrd:sizepolicy(size)
  return size <= 65535
end
return SKillRelatedMonsterBrd

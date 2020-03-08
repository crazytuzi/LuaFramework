local CSwitchOccupationReq = class("CSwitchOccupationReq")
CSwitchOccupationReq.TYPEID = 12606977
function CSwitchOccupationReq:ctor(new_occupation, old_occupation, current_gold, npcid)
  self.id = 12606977
  self.new_occupation = new_occupation or nil
  self.old_occupation = old_occupation or nil
  self.current_gold = current_gold or nil
  self.npcid = npcid or nil
end
function CSwitchOccupationReq:marshal(os)
  os:marshalInt32(self.new_occupation)
  os:marshalInt32(self.old_occupation)
  os:marshalInt64(self.current_gold)
  os:marshalInt32(self.npcid)
end
function CSwitchOccupationReq:unmarshal(os)
  self.new_occupation = os:unmarshalInt32()
  self.old_occupation = os:unmarshalInt32()
  self.current_gold = os:unmarshalInt64()
  self.npcid = os:unmarshalInt32()
end
function CSwitchOccupationReq:sizepolicy(size)
  return size <= 65535
end
return CSwitchOccupationReq

local CActiveNewOccupationReq = class("CActiveNewOccupationReq")
CActiveNewOccupationReq.TYPEID = 12606979
function CActiveNewOccupationReq:ctor(new_occupation, old_occupation, current_currency, npcid)
  self.id = 12606979
  self.new_occupation = new_occupation or nil
  self.old_occupation = old_occupation or nil
  self.current_currency = current_currency or nil
  self.npcid = npcid or nil
end
function CActiveNewOccupationReq:marshal(os)
  os:marshalInt32(self.new_occupation)
  os:marshalInt32(self.old_occupation)
  os:marshalInt64(self.current_currency)
  os:marshalInt32(self.npcid)
end
function CActiveNewOccupationReq:unmarshal(os)
  self.new_occupation = os:unmarshalInt32()
  self.old_occupation = os:unmarshalInt32()
  self.current_currency = os:unmarshalInt64()
  self.npcid = os:unmarshalInt32()
end
function CActiveNewOccupationReq:sizepolicy(size)
  return size <= 65535
end
return CActiveNewOccupationReq

local SRenameOccupationPlanNameRep = class("SRenameOccupationPlanNameRep")
SRenameOccupationPlanNameRep.TYPEID = 12596549
SRenameOccupationPlanNameRep.RES_SUC = 1
SRenameOccupationPlanNameRep.RES_ERR__NOT_OPEN_THIS_OCCUPATION = 2
SRenameOccupationPlanNameRep.RES_ERR__NAME_ILLEGAL = 3
function SRenameOccupationPlanNameRep:ctor(occupationId, newName, result, args)
  self.id = 12596549
  self.occupationId = occupationId or nil
  self.newName = newName or nil
  self.result = result or nil
  self.args = args or {}
end
function SRenameOccupationPlanNameRep:marshal(os)
  os:marshalInt32(self.occupationId)
  os:marshalOctets(self.newName)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SRenameOccupationPlanNameRep:unmarshal(os)
  self.occupationId = os:unmarshalInt32()
  self.newName = os:unmarshalOctets()
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SRenameOccupationPlanNameRep:sizepolicy(size)
  return size <= 65535
end
return SRenameOccupationPlanNameRep

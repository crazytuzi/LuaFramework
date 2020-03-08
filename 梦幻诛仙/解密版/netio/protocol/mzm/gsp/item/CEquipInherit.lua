local CEquipInherit = class("CEquipInherit")
CEquipInherit.TYPEID = 12584760
function CEquipInherit:ctor(srceEquipKey, desEquipBagid, desEquipKey, isInheritHun, clientSilverNum, cliStrengthLevel)
  self.id = 12584760
  self.srceEquipKey = srceEquipKey or nil
  self.desEquipBagid = desEquipBagid or nil
  self.desEquipKey = desEquipKey or nil
  self.isInheritHun = isInheritHun or nil
  self.clientSilverNum = clientSilverNum or nil
  self.cliStrengthLevel = cliStrengthLevel or nil
end
function CEquipInherit:marshal(os)
  os:marshalInt32(self.srceEquipKey)
  os:marshalInt32(self.desEquipBagid)
  os:marshalInt32(self.desEquipKey)
  os:marshalInt32(self.isInheritHun)
  os:marshalInt64(self.clientSilverNum)
  os:marshalInt32(self.cliStrengthLevel)
end
function CEquipInherit:unmarshal(os)
  self.srceEquipKey = os:unmarshalInt32()
  self.desEquipBagid = os:unmarshalInt32()
  self.desEquipKey = os:unmarshalInt32()
  self.isInheritHun = os:unmarshalInt32()
  self.clientSilverNum = os:unmarshalInt64()
  self.cliStrengthLevel = os:unmarshalInt32()
end
function CEquipInherit:sizepolicy(size)
  return size <= 65535
end
return CEquipInherit

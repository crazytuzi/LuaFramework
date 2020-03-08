local SAddWingExpRep = class("SAddWingExpRep")
SAddWingExpRep.TYPEID = 12596537
function SAddWingExpRep:ctor(curExp, oldLv, newLv, addExp)
  self.id = 12596537
  self.curExp = curExp or nil
  self.oldLv = oldLv or nil
  self.newLv = newLv or nil
  self.addExp = addExp or nil
end
function SAddWingExpRep:marshal(os)
  os:marshalInt32(self.curExp)
  os:marshalInt32(self.oldLv)
  os:marshalInt32(self.newLv)
  os:marshalInt32(self.addExp)
end
function SAddWingExpRep:unmarshal(os)
  self.curExp = os:unmarshalInt32()
  self.oldLv = os:unmarshalInt32()
  self.newLv = os:unmarshalInt32()
  self.addExp = os:unmarshalInt32()
end
function SAddWingExpRep:sizepolicy(size)
  return size <= 65535
end
return SAddWingExpRep

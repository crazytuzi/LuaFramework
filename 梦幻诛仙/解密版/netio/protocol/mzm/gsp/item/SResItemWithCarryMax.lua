local SResItemWithCarryMax = class("SResItemWithCarryMax")
SResItemWithCarryMax.TYPEID = 12584766
function SResItemWithCarryMax:ctor(itemid, carrymax, addnum)
  self.id = 12584766
  self.itemid = itemid or nil
  self.carrymax = carrymax or nil
  self.addnum = addnum or nil
end
function SResItemWithCarryMax:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.carrymax)
  os:marshalInt32(self.addnum)
end
function SResItemWithCarryMax:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.carrymax = os:unmarshalInt32()
  self.addnum = os:unmarshalInt32()
end
function SResItemWithCarryMax:sizepolicy(size)
  return size <= 65535
end
return SResItemWithCarryMax

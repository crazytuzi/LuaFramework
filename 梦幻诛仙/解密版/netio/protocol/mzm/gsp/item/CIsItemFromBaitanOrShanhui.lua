local CIsItemFromBaitanOrShanhui = class("CIsItemFromBaitanOrShanhui")
CIsItemFromBaitanOrShanhui.TYPEID = 12584831
function CIsItemFromBaitanOrShanhui:ctor(itemorsiftcfgid)
  self.id = 12584831
  self.itemorsiftcfgid = itemorsiftcfgid or nil
end
function CIsItemFromBaitanOrShanhui:marshal(os)
  os:marshalInt32(self.itemorsiftcfgid)
end
function CIsItemFromBaitanOrShanhui:unmarshal(os)
  self.itemorsiftcfgid = os:unmarshalInt32()
end
function CIsItemFromBaitanOrShanhui:sizepolicy(size)
  return size <= 65535
end
return CIsItemFromBaitanOrShanhui

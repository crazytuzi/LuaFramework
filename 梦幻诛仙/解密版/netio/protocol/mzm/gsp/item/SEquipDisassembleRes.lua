local SEquipDisassembleRes = class("SEquipDisassembleRes")
SEquipDisassembleRes.TYPEID = 12584860
function SEquipDisassembleRes:ctor(itemid, itemnum)
  self.id = 12584860
  self.itemid = itemid or nil
  self.itemnum = itemnum or nil
end
function SEquipDisassembleRes:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemnum)
end
function SEquipDisassembleRes:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.itemnum = os:unmarshalInt32()
end
function SEquipDisassembleRes:sizepolicy(size)
  return size <= 65535
end
return SEquipDisassembleRes

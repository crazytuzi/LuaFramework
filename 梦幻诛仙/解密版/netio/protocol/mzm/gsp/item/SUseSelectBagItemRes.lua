local SUseSelectBagItemRes = class("SUseSelectBagItemRes")
SUseSelectBagItemRes.TYPEID = 12584828
function SUseSelectBagItemRes:ctor(itemid, num)
  self.id = 12584828
  self.itemid = itemid or nil
  self.num = num or nil
end
function SUseSelectBagItemRes:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.num)
end
function SUseSelectBagItemRes:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function SUseSelectBagItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseSelectBagItemRes

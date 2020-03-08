local SUseShapeShiftItemSuccess = class("SUseShapeShiftItemSuccess")
SUseShapeShiftItemSuccess.TYPEID = 12584874
function SUseShapeShiftItemSuccess:ctor(item_cfgid, used_num)
  self.id = 12584874
  self.item_cfgid = item_cfgid or nil
  self.used_num = used_num or nil
end
function SUseShapeShiftItemSuccess:marshal(os)
  os:marshalInt32(self.item_cfgid)
  os:marshalInt32(self.used_num)
end
function SUseShapeShiftItemSuccess:unmarshal(os)
  self.item_cfgid = os:unmarshalInt32()
  self.used_num = os:unmarshalInt32()
end
function SUseShapeShiftItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseShapeShiftItemSuccess

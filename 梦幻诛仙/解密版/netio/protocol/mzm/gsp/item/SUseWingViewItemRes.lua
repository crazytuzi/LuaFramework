local SUseWingViewItemRes = class("SUseWingViewItemRes")
SUseWingViewItemRes.TYPEID = 12584786
function SUseWingViewItemRes:ctor(modelid)
  self.id = 12584786
  self.modelid = modelid or nil
end
function SUseWingViewItemRes:marshal(os)
  os:marshalInt32(self.modelid)
end
function SUseWingViewItemRes:unmarshal(os)
  self.modelid = os:unmarshalInt32()
end
function SUseWingViewItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseWingViewItemRes

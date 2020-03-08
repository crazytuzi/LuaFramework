local CUseWingViewItem = class("CUseWingViewItem")
CUseWingViewItem.TYPEID = 12584785
function CUseWingViewItem:ctor(uuid)
  self.id = 12584785
  self.uuid = uuid or nil
end
function CUseWingViewItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseWingViewItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseWingViewItem:sizepolicy(size)
  return size <= 65535
end
return CUseWingViewItem

local CChildShow = class("CChildShow")
CChildShow.TYPEID = 12609321
function CChildShow:ctor(child_id, child_period)
  self.id = 12609321
  self.child_id = child_id or nil
  self.child_period = child_period or nil
end
function CChildShow:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt32(self.child_period)
end
function CChildShow:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_period = os:unmarshalInt32()
end
function CChildShow:sizepolicy(size)
  return size <= 65535
end
return CChildShow

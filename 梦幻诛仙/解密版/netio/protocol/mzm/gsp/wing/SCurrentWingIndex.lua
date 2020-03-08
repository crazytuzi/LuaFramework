local SCurrentWingIndex = class("SCurrentWingIndex")
SCurrentWingIndex.TYPEID = 12596486
function SCurrentWingIndex:ctor(curIndex)
  self.id = 12596486
  self.curIndex = curIndex or nil
end
function SCurrentWingIndex:marshal(os)
  os:marshalInt32(self.curIndex)
end
function SCurrentWingIndex:unmarshal(os)
  self.curIndex = os:unmarshalInt32()
end
function SCurrentWingIndex:sizepolicy(size)
  return size <= 65535
end
return SCurrentWingIndex

local SLongjingUpLevelRes = class("SLongjingUpLevelRes")
SLongjingUpLevelRes.TYPEID = 12596016
function SLongjingUpLevelRes:ctor(curItemid, nextItemid)
  self.id = 12596016
  self.curItemid = curItemid or nil
  self.nextItemid = nextItemid or nil
end
function SLongjingUpLevelRes:marshal(os)
  os:marshalInt32(self.curItemid)
  os:marshalInt32(self.nextItemid)
end
function SLongjingUpLevelRes:unmarshal(os)
  self.curItemid = os:unmarshalInt32()
  self.nextItemid = os:unmarshalInt32()
end
function SLongjingUpLevelRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingUpLevelRes

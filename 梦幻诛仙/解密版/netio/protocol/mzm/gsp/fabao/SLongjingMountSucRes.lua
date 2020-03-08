local SLongjingMountSucRes = class("SLongjingMountSucRes")
SLongjingMountSucRes.TYPEID = 12596010
function SLongjingMountSucRes:ctor(itemid, pos)
  self.id = 12596010
  self.itemid = itemid or nil
  self.pos = pos or nil
end
function SLongjingMountSucRes:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.pos)
end
function SLongjingMountSucRes:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.pos = os:unmarshalInt32()
end
function SLongjingMountSucRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingMountSucRes

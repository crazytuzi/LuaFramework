local SItemNumChangeInfo = class("SItemNumChangeInfo")
SItemNumChangeInfo.TYPEID = 12585477
function SItemNumChangeInfo:ctor(malltype, itemid, count)
  self.id = 12585477
  self.malltype = malltype or nil
  self.itemid = itemid or nil
  self.count = count or nil
end
function SItemNumChangeInfo:marshal(os)
  os:marshalInt32(self.malltype)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
end
function SItemNumChangeInfo:unmarshal(os)
  self.malltype = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function SItemNumChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SItemNumChangeInfo

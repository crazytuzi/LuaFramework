local CAdjustDisposition = class("CAdjustDisposition")
CAdjustDisposition.TYPEID = 12588324
function CAdjustDisposition:ctor(srcpos, dstpos)
  self.id = 12588324
  self.srcpos = srcpos or nil
  self.dstpos = dstpos or nil
end
function CAdjustDisposition:marshal(os)
  os:marshalInt32(self.srcpos)
  os:marshalInt32(self.dstpos)
end
function CAdjustDisposition:unmarshal(os)
  self.srcpos = os:unmarshalInt32()
  self.dstpos = os:unmarshalInt32()
end
function CAdjustDisposition:sizepolicy(size)
  return size <= 65535
end
return CAdjustDisposition

local SSynQingSingleProgress = class("SSynQingSingleProgress")
SSynQingSingleProgress.TYPEID = 12590339
function SSynQingSingleProgress:ctor(outPostType, chapter, section)
  self.id = 12590339
  self.outPostType = outPostType or nil
  self.chapter = chapter or nil
  self.section = section or nil
end
function SSynQingSingleProgress:marshal(os)
  os:marshalInt32(self.outPostType)
  os:marshalInt32(self.chapter)
  os:marshalInt32(self.section)
end
function SSynQingSingleProgress:unmarshal(os)
  self.outPostType = os:unmarshalInt32()
  self.chapter = os:unmarshalInt32()
  self.section = os:unmarshalInt32()
end
function SSynQingSingleProgress:sizepolicy(size)
  return size <= 65535
end
return SSynQingSingleProgress

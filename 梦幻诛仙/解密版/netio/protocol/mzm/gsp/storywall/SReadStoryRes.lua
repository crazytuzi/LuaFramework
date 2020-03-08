local SReadStoryRes = class("SReadStoryRes")
SReadStoryRes.TYPEID = 12606466
SReadStoryRes.SUCCESS = 0
SReadStoryRes.ERROR_UNKNOWN = 1
SReadStoryRes.ERROR_EXPIRE = 2
SReadStoryRes.ERROR_STORYID = 3
function SReadStoryRes:ctor(resultcode)
  self.id = 12606466
  self.resultcode = resultcode or nil
end
function SReadStoryRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SReadStoryRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SReadStoryRes:sizepolicy(size)
  return size <= 65535
end
return SReadStoryRes

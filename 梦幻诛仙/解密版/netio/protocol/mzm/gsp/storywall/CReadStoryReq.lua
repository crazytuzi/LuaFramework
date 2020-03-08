local CReadStoryReq = class("CReadStoryReq")
CReadStoryReq.TYPEID = 12606465
function CReadStoryReq:ctor(storyid)
  self.id = 12606465
  self.storyid = storyid or nil
end
function CReadStoryReq:marshal(os)
  os:marshalInt32(self.storyid)
end
function CReadStoryReq:unmarshal(os)
  self.storyid = os:unmarshalInt32()
end
function CReadStoryReq:sizepolicy(size)
  return size <= 65535
end
return CReadStoryReq

local CChallengeQing = class("CChallengeQing")
CChallengeQing.TYPEID = 12590341
function CChallengeQing:ctor(outPostType, chapter, section)
  self.id = 12590341
  self.outPostType = outPostType or nil
  self.chapter = chapter or nil
  self.section = section or nil
end
function CChallengeQing:marshal(os)
  os:marshalInt32(self.outPostType)
  os:marshalInt32(self.chapter)
  os:marshalInt32(self.section)
end
function CChallengeQing:unmarshal(os)
  self.outPostType = os:unmarshalInt32()
  self.chapter = os:unmarshalInt32()
  self.section = os:unmarshalInt32()
end
function CChallengeQing:sizepolicy(size)
  return size <= 65535
end
return CChallengeQing

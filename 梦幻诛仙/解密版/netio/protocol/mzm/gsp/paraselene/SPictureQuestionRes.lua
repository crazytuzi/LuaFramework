local SPictureQuestionRes = class("SPictureQuestionRes")
SPictureQuestionRes.TYPEID = 12598289
function SPictureQuestionRes:ctor(issuccess, seconds, pictureQuestionRes)
  self.id = 12598289
  self.issuccess = issuccess or nil
  self.seconds = seconds or nil
  self.pictureQuestionRes = pictureQuestionRes or {}
end
function SPictureQuestionRes:marshal(os)
  os:marshalInt32(self.issuccess)
  os:marshalInt32(self.seconds)
  os:marshalCompactUInt32(table.getn(self.pictureQuestionRes))
  for _, v in ipairs(self.pictureQuestionRes) do
    v:marshal(os)
  end
end
function SPictureQuestionRes:unmarshal(os)
  self.issuccess = os:unmarshalInt32()
  self.seconds = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.paraselene.PictureQuestionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.pictureQuestionRes, v)
  end
end
function SPictureQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SPictureQuestionRes

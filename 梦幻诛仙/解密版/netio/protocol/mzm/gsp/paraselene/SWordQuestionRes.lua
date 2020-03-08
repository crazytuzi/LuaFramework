local SWordQuestionRes = class("SWordQuestionRes")
SWordQuestionRes.TYPEID = 12598290
function SWordQuestionRes:ctor(issuccess, seconds, wordQuestionRes)
  self.id = 12598290
  self.issuccess = issuccess or nil
  self.seconds = seconds or nil
  self.wordQuestionRes = wordQuestionRes or {}
end
function SWordQuestionRes:marshal(os)
  os:marshalInt32(self.issuccess)
  os:marshalInt32(self.seconds)
  os:marshalCompactUInt32(table.getn(self.wordQuestionRes))
  for _, v in ipairs(self.wordQuestionRes) do
    v:marshal(os)
  end
end
function SWordQuestionRes:unmarshal(os)
  self.issuccess = os:unmarshalInt32()
  self.seconds = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.paraselene.WordQuestionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.wordQuestionRes, v)
  end
end
function SWordQuestionRes:sizepolicy(size)
  return size <= 65535
end
return SWordQuestionRes

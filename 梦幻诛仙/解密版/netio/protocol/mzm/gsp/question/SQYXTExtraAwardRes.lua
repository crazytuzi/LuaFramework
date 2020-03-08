local SQYXTExtraAwardRes = class("SQYXTExtraAwardRes")
SQYXTExtraAwardRes.TYPEID = 12594749
function SQYXTExtraAwardRes:ctor(item2countList)
  self.id = 12594749
  self.item2countList = item2countList or {}
end
function SQYXTExtraAwardRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.item2countList))
  for _, v in ipairs(self.item2countList) do
    v:marshal(os)
  end
end
function SQYXTExtraAwardRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.question.Item2Count")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.item2countList, v)
  end
end
function SQYXTExtraAwardRes:sizepolicy(size)
  return size <= 65535
end
return SQYXTExtraAwardRes

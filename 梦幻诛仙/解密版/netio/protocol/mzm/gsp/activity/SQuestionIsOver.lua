local SQuestionIsOver = class("SQuestionIsOver")
SQuestionIsOver.TYPEID = 12587581
function SQuestionIsOver:ctor(nbAwardInfo, normalAwardInfo)
  self.id = 12587581
  self.nbAwardInfo = nbAwardInfo or {}
  self.normalAwardInfo = normalAwardInfo or {}
end
function SQuestionIsOver:marshal(os)
  os:marshalCompactUInt32(table.getn(self.nbAwardInfo))
  for _, v in ipairs(self.nbAwardInfo) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.normalAwardInfo))
  for _, v in ipairs(self.normalAwardInfo) do
    v:marshal(os)
  end
end
function SQuestionIsOver:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.activity.RoleAwardData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.nbAwardInfo, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.activity.RoleAwardData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.normalAwardInfo, v)
  end
end
function SQuestionIsOver:sizepolicy(size)
  return size <= 65535
end
return SQuestionIsOver

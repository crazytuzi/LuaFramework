local SSynAnswerInfoList = class("SSynAnswerInfoList")
SSynAnswerInfoList.TYPEID = 12617252
function SSynAnswerInfoList:ctor(answerInfo_list)
  self.id = 12617252
  self.answerInfo_list = answerInfo_list or {}
end
function SSynAnswerInfoList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.answerInfo_list))
  for _, v in ipairs(self.answerInfo_list) do
    v:marshal(os)
  end
end
function SSynAnswerInfoList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.AnswerInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.answerInfo_list, v)
  end
end
function SSynAnswerInfoList:sizepolicy(size)
  return size <= 65535
end
return SSynAnswerInfoList

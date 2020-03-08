local SSynDrawAndGuessQuestionInfo = class("SSynDrawAndGuessQuestionInfo")
SSynDrawAndGuessQuestionInfo.TYPEID = 12617242
function SSynDrawAndGuessQuestionInfo:ctor(drawerId, roleId_list, questionCfgId, timeStamp, sessionId, jifen_list, sendType)
  self.id = 12617242
  self.drawerId = drawerId or nil
  self.roleId_list = roleId_list or {}
  self.questionCfgId = questionCfgId or nil
  self.timeStamp = timeStamp or nil
  self.sessionId = sessionId or nil
  self.jifen_list = jifen_list or {}
  self.sendType = sendType or nil
end
function SSynDrawAndGuessQuestionInfo:marshal(os)
  os:marshalInt64(self.drawerId)
  os:marshalCompactUInt32(table.getn(self.roleId_list))
  for _, v in ipairs(self.roleId_list) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.questionCfgId)
  os:marshalInt64(self.timeStamp)
  os:marshalInt64(self.sessionId)
  os:marshalCompactUInt32(table.getn(self.jifen_list))
  for _, v in ipairs(self.jifen_list) do
    v:marshal(os)
  end
  os:marshalInt32(self.sendType)
end
function SSynDrawAndGuessQuestionInfo:unmarshal(os)
  self.drawerId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleId_list, v)
  end
  self.questionCfgId = os:unmarshalInt32()
  self.timeStamp = os:unmarshalInt64()
  self.sessionId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.drawandguess.RoleGetJifenInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.jifen_list, v)
  end
  self.sendType = os:unmarshalInt32()
end
function SSynDrawAndGuessQuestionInfo:sizepolicy(size)
  return size <= 65535
end
return SSynDrawAndGuessQuestionInfo

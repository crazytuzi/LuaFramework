local CQYXTSeekGangHelpReq = class("CQYXTSeekGangHelpReq")
CQYXTSeekGangHelpReq.TYPEID = 12594753
function CQYXTSeekGangHelpReq:ctor(questionCfgId)
  self.id = 12594753
  self.questionCfgId = questionCfgId or nil
end
function CQYXTSeekGangHelpReq:marshal(os)
  os:marshalInt32(self.questionCfgId)
end
function CQYXTSeekGangHelpReq:unmarshal(os)
  self.questionCfgId = os:unmarshalInt32()
end
function CQYXTSeekGangHelpReq:sizepolicy(size)
  return size <= 65535
end
return CQYXTSeekGangHelpReq

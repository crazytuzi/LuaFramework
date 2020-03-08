local CGetQuestionVoiceReq = class("CGetQuestionVoiceReq")
CGetQuestionVoiceReq.TYPEID = 12620801
function CGetQuestionVoiceReq:ctor(activity_id, npc_id)
  self.id = 12620801
  self.activity_id = activity_id or nil
  self.npc_id = npc_id or nil
end
function CGetQuestionVoiceReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.npc_id)
end
function CGetQuestionVoiceReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.npc_id = os:unmarshalInt32()
end
function CGetQuestionVoiceReq:sizepolicy(size)
  return size <= 65535
end
return CGetQuestionVoiceReq

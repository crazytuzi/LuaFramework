local CGetLastQuestionVoiceReq = class("CGetLastQuestionVoiceReq")
CGetLastQuestionVoiceReq.TYPEID = 12620809
function CGetLastQuestionVoiceReq:ctor(activity_id, npc_id)
  self.id = 12620809
  self.activity_id = activity_id or nil
  self.npc_id = npc_id or nil
end
function CGetLastQuestionVoiceReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.npc_id)
end
function CGetLastQuestionVoiceReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.npc_id = os:unmarshalInt32()
end
function CGetLastQuestionVoiceReq:sizepolicy(size)
  return size <= 65535
end
return CGetLastQuestionVoiceReq

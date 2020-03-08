local CCombineGangApplyRep = class("CCombineGangApplyRep")
CCombineGangApplyRep.TYPEID = 12589974
CCombineGangApplyRep.REPLY_AGREE = 0
CCombineGangApplyRep.REPLY_REFUSE = 1
function CCombineGangApplyRep:ctor(targetid, reply)
  self.id = 12589974
  self.targetid = targetid or nil
  self.reply = reply or nil
end
function CCombineGangApplyRep:marshal(os)
  os:marshalInt64(self.targetid)
  os:marshalInt32(self.reply)
end
function CCombineGangApplyRep:unmarshal(os)
  self.targetid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CCombineGangApplyRep:sizepolicy(size)
  return size <= 65535
end
return CCombineGangApplyRep

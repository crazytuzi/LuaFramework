local CJoinGangTeamRep = class("CJoinGangTeamRep")
CJoinGangTeamRep.TYPEID = 12589998
CJoinGangTeamRep.REPLY_AGREE = 0
CJoinGangTeamRep.REPLY_REFUSE = 1
function CJoinGangTeamRep:ctor(applicantid, reply)
  self.id = 12589998
  self.applicantid = applicantid or nil
  self.reply = reply or nil
end
function CJoinGangTeamRep:marshal(os)
  os:marshalInt64(self.applicantid)
  os:marshalInt32(self.reply)
end
function CJoinGangTeamRep:unmarshal(os)
  self.applicantid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CJoinGangTeamRep:sizepolicy(size)
  return size <= 65535
end
return CJoinGangTeamRep

local SJoinChessSuccessRep = class("SJoinChessSuccessRep")
SJoinChessSuccessRep.TYPEID = 12619028
function SJoinChessSuccessRep:ctor(activity_id)
  self.id = 12619028
  self.activity_id = activity_id or nil
end
function SJoinChessSuccessRep:marshal(os)
  os:marshalInt32(self.activity_id)
end
function SJoinChessSuccessRep:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function SJoinChessSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SJoinChessSuccessRep

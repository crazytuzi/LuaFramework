local CAttendLadderReq = class("CAttendLadderReq")
CAttendLadderReq.TYPEID = 12607244
function CAttendLadderReq:ctor()
  self.id = 12607244
end
function CAttendLadderReq:marshal(os)
end
function CAttendLadderReq:unmarshal(os)
end
function CAttendLadderReq:sizepolicy(size)
  return size <= 65535
end
return CAttendLadderReq

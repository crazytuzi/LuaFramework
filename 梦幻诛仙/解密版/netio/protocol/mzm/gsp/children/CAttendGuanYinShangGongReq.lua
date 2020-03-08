local CAttendGuanYinShangGongReq = class("CAttendGuanYinShangGongReq")
CAttendGuanYinShangGongReq.TYPEID = 12609350
function CAttendGuanYinShangGongReq:ctor()
  self.id = 12609350
end
function CAttendGuanYinShangGongReq:marshal(os)
end
function CAttendGuanYinShangGongReq:unmarshal(os)
end
function CAttendGuanYinShangGongReq:sizepolicy(size)
  return size <= 65535
end
return CAttendGuanYinShangGongReq

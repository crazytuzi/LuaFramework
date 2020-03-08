local CAttendMoneyTreeReq = class("CAttendMoneyTreeReq")
CAttendMoneyTreeReq.TYPEID = 12611329
function CAttendMoneyTreeReq:ctor()
  self.id = 12611329
end
function CAttendMoneyTreeReq:marshal(os)
end
function CAttendMoneyTreeReq:unmarshal(os)
end
function CAttendMoneyTreeReq:sizepolicy(size)
  return size <= 65535
end
return CAttendMoneyTreeReq

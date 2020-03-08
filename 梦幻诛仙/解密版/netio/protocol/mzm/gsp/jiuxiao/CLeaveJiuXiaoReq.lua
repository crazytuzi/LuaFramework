local CLeaveJiuXiaoReq = class("CLeaveJiuXiaoReq")
CLeaveJiuXiaoReq.TYPEID = 12595468
function CLeaveJiuXiaoReq:ctor()
  self.id = 12595468
end
function CLeaveJiuXiaoReq:marshal(os)
end
function CLeaveJiuXiaoReq:unmarshal(os)
end
function CLeaveJiuXiaoReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveJiuXiaoReq

local CLeaveAfterWinnerAwardReq = class("CLeaveAfterWinnerAwardReq")
CLeaveAfterWinnerAwardReq.TYPEID = 12596751
function CLeaveAfterWinnerAwardReq:ctor()
  self.id = 12596751
end
function CLeaveAfterWinnerAwardReq:marshal(os)
end
function CLeaveAfterWinnerAwardReq:unmarshal(os)
end
function CLeaveAfterWinnerAwardReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveAfterWinnerAwardReq

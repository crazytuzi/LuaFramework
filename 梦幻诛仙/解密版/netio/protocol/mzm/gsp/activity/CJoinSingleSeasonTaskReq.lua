local CJoinSingleSeasonTaskReq = class("CJoinSingleSeasonTaskReq")
CJoinSingleSeasonTaskReq.TYPEID = 12587573
function CJoinSingleSeasonTaskReq:ctor()
  self.id = 12587573
end
function CJoinSingleSeasonTaskReq:marshal(os)
end
function CJoinSingleSeasonTaskReq:unmarshal(os)
end
function CJoinSingleSeasonTaskReq:sizepolicy(size)
  return size <= 65535
end
return CJoinSingleSeasonTaskReq

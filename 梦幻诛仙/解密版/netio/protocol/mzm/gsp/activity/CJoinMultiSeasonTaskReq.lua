local CJoinMultiSeasonTaskReq = class("CJoinMultiSeasonTaskReq")
CJoinMultiSeasonTaskReq.TYPEID = 12587572
function CJoinMultiSeasonTaskReq:ctor()
  self.id = 12587572
end
function CJoinMultiSeasonTaskReq:marshal(os)
end
function CJoinMultiSeasonTaskReq:unmarshal(os)
end
function CJoinMultiSeasonTaskReq:sizepolicy(size)
  return size <= 65535
end
return CJoinMultiSeasonTaskReq

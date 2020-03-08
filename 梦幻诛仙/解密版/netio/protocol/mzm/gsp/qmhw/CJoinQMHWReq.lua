local CJoinQMHWReq = class("CJoinQMHWReq")
CJoinQMHWReq.TYPEID = 12601862
function CJoinQMHWReq:ctor()
  self.id = 12601862
end
function CJoinQMHWReq:marshal(os)
end
function CJoinQMHWReq:unmarshal(os)
end
function CJoinQMHWReq:sizepolicy(size)
  return size <= 65535
end
return CJoinQMHWReq

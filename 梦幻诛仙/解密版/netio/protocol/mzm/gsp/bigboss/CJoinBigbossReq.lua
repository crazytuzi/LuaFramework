local CJoinBigbossReq = class("CJoinBigbossReq")
CJoinBigbossReq.TYPEID = 12598019
function CJoinBigbossReq:ctor()
  self.id = 12598019
end
function CJoinBigbossReq:marshal(os)
end
function CJoinBigbossReq:unmarshal(os)
end
function CJoinBigbossReq:sizepolicy(size)
  return size <= 65535
end
return CJoinBigbossReq

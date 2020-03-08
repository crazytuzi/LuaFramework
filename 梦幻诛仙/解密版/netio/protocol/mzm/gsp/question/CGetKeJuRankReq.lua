local CGetKeJuRankReq = class("CGetKeJuRankReq")
CGetKeJuRankReq.TYPEID = 12594727
function CGetKeJuRankReq:ctor()
  self.id = 12594727
end
function CGetKeJuRankReq:marshal(os)
end
function CGetKeJuRankReq:unmarshal(os)
end
function CGetKeJuRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetKeJuRankReq

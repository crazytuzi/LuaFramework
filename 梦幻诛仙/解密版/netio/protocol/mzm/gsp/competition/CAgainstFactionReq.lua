local CAgainstFactionReq = class("CAgainstFactionReq")
CAgainstFactionReq.TYPEID = 12598544
function CAgainstFactionReq:ctor()
  self.id = 12598544
end
function CAgainstFactionReq:marshal(os)
end
function CAgainstFactionReq:unmarshal(os)
end
function CAgainstFactionReq:sizepolicy(size)
  return size <= 65535
end
return CAgainstFactionReq

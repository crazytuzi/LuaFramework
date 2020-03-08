local CGetFactionWorshipReq = class("CGetFactionWorshipReq")
CGetFactionWorshipReq.TYPEID = 12612612
function CGetFactionWorshipReq:ctor()
  self.id = 12612612
end
function CGetFactionWorshipReq:marshal(os)
end
function CGetFactionWorshipReq:unmarshal(os)
end
function CGetFactionWorshipReq:sizepolicy(size)
  return size <= 65535
end
return CGetFactionWorshipReq

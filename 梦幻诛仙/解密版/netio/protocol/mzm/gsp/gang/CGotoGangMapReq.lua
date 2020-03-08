local CGotoGangMapReq = class("CGotoGangMapReq")
CGotoGangMapReq.TYPEID = 12589871
function CGotoGangMapReq:ctor()
  self.id = 12589871
end
function CGotoGangMapReq:marshal(os)
end
function CGotoGangMapReq:unmarshal(os)
end
function CGotoGangMapReq:sizepolicy(size)
  return size <= 65535
end
return CGotoGangMapReq

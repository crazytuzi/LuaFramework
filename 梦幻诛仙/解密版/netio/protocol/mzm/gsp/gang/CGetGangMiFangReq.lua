local CGetGangMiFangReq = class("CGetGangMiFangReq")
CGetGangMiFangReq.TYPEID = 12589921
function CGetGangMiFangReq:ctor()
  self.id = 12589921
end
function CGetGangMiFangReq:marshal(os)
end
function CGetGangMiFangReq:unmarshal(os)
end
function CGetGangMiFangReq:sizepolicy(size)
  return size <= 65535
end
return CGetGangMiFangReq

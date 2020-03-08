local CUnmountReq = class("CUnmountReq")
CUnmountReq.TYPEID = 797956
function CUnmountReq:ctor()
  self.id = 797956
end
function CUnmountReq:marshal(os)
end
function CUnmountReq:unmarshal(os)
end
function CUnmountReq:sizepolicy(size)
  return size <= 65535
end
return CUnmountReq

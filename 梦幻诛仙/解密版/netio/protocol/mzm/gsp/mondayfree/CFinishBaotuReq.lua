local CFinishBaotuReq = class("CFinishBaotuReq")
CFinishBaotuReq.TYPEID = 12626179
function CFinishBaotuReq:ctor()
  self.id = 12626179
end
function CFinishBaotuReq:marshal(os)
end
function CFinishBaotuReq:unmarshal(os)
end
function CFinishBaotuReq:sizepolicy(size)
  return size <= 65535
end
return CFinishBaotuReq

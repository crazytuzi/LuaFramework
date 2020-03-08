local CGetOffWingReq = class("CGetOffWingReq")
CGetOffWingReq.TYPEID = 12596526
function CGetOffWingReq:ctor()
  self.id = 12596526
end
function CGetOffWingReq:marshal(os)
end
function CGetOffWingReq:unmarshal(os)
end
function CGetOffWingReq:sizepolicy(size)
  return size <= 65535
end
return CGetOffWingReq

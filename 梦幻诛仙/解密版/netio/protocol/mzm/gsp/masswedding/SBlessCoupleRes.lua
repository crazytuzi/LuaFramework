local SBlessCoupleRes = class("SBlessCoupleRes")
SBlessCoupleRes.TYPEID = 12604942
function SBlessCoupleRes:ctor()
  self.id = 12604942
end
function SBlessCoupleRes:marshal(os)
end
function SBlessCoupleRes:unmarshal(os)
end
function SBlessCoupleRes:sizepolicy(size)
  return size <= 65535
end
return SBlessCoupleRes

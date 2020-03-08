local SFixAllEquipmentsRes = class("SFixAllEquipmentsRes")
SFixAllEquipmentsRes.TYPEID = 12584752
function SFixAllEquipmentsRes:ctor()
  self.id = 12584752
end
function SFixAllEquipmentsRes:marshal(os)
end
function SFixAllEquipmentsRes:unmarshal(os)
end
function SFixAllEquipmentsRes:sizepolicy(size)
  return size <= 65535
end
return SFixAllEquipmentsRes

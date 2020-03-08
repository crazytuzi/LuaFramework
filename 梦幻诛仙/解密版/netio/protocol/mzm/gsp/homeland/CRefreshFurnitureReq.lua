local CRefreshFurnitureReq = class("CRefreshFurnitureReq")
CRefreshFurnitureReq.TYPEID = 12605475
function CRefreshFurnitureReq:ctor()
  self.id = 12605475
end
function CRefreshFurnitureReq:marshal(os)
end
function CRefreshFurnitureReq:unmarshal(os)
end
function CRefreshFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshFurnitureReq

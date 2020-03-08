local CQueryFurnitureReq = class("CQueryFurnitureReq")
CQueryFurnitureReq.TYPEID = 12605488
function CQueryFurnitureReq:ctor()
  self.id = 12605488
end
function CQueryFurnitureReq:marshal(os)
end
function CQueryFurnitureReq:unmarshal(os)
end
function CQueryFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CQueryFurnitureReq

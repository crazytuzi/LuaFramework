local CGetAxeActivityItemReq = class("CGetAxeActivityItemReq")
CGetAxeActivityItemReq.TYPEID = 12614916
function CGetAxeActivityItemReq:ctor()
  self.id = 12614916
end
function CGetAxeActivityItemReq:marshal(os)
end
function CGetAxeActivityItemReq:unmarshal(os)
end
function CGetAxeActivityItemReq:sizepolicy(size)
  return size <= 65535
end
return CGetAxeActivityItemReq

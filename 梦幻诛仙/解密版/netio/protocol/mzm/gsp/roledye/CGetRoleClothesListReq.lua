local CGetRoleClothesListReq = class("CGetRoleClothesListReq")
CGetRoleClothesListReq.TYPEID = 12597254
function CGetRoleClothesListReq:ctor()
  self.id = 12597254
end
function CGetRoleClothesListReq:marshal(os)
end
function CGetRoleClothesListReq:unmarshal(os)
end
function CGetRoleClothesListReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleClothesListReq

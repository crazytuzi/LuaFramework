local CMakeQingYuanRelation = class("CMakeQingYuanRelation")
CMakeQingYuanRelation.TYPEID = 12602884
function CMakeQingYuanRelation:ctor()
  self.id = 12602884
end
function CMakeQingYuanRelation:marshal(os)
end
function CMakeQingYuanRelation:unmarshal(os)
end
function CMakeQingYuanRelation:sizepolicy(size)
  return size <= 65535
end
return CMakeQingYuanRelation

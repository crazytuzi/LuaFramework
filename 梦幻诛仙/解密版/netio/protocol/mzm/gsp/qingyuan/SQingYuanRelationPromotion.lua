local SQingYuanRelationPromotion = class("SQingYuanRelationPromotion")
SQingYuanRelationPromotion.TYPEID = 12602891
function SQingYuanRelationPromotion:ctor(role_id_a, role_id_b)
  self.id = 12602891
  self.role_id_a = role_id_a or nil
  self.role_id_b = role_id_b or nil
end
function SQingYuanRelationPromotion:marshal(os)
  os:marshalInt64(self.role_id_a)
  os:marshalInt64(self.role_id_b)
end
function SQingYuanRelationPromotion:unmarshal(os)
  self.role_id_a = os:unmarshalInt64()
  self.role_id_b = os:unmarshalInt64()
end
function SQingYuanRelationPromotion:sizepolicy(size)
  return size <= 65535
end
return SQingYuanRelationPromotion

local CRelieveQingYuanRelation = class("CRelieveQingYuanRelation")
CRelieveQingYuanRelation.TYPEID = 12602892
function CRelieveQingYuanRelation:ctor(passive_role_id)
  self.id = 12602892
  self.passive_role_id = passive_role_id or nil
end
function CRelieveQingYuanRelation:marshal(os)
  os:marshalInt64(self.passive_role_id)
end
function CRelieveQingYuanRelation:unmarshal(os)
  self.passive_role_id = os:unmarshalInt64()
end
function CRelieveQingYuanRelation:sizepolicy(size)
  return size <= 65535
end
return CRelieveQingYuanRelation

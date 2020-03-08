local SRelieveQingYuanSuccess = class("SRelieveQingYuanSuccess")
SRelieveQingYuanSuccess.TYPEID = 12602882
function SRelieveQingYuanSuccess:ctor(active_role_id, passive_role_id)
  self.id = 12602882
  self.active_role_id = active_role_id or nil
  self.passive_role_id = passive_role_id or nil
end
function SRelieveQingYuanSuccess:marshal(os)
  os:marshalInt64(self.active_role_id)
  os:marshalInt64(self.passive_role_id)
end
function SRelieveQingYuanSuccess:unmarshal(os)
  self.active_role_id = os:unmarshalInt64()
  self.passive_role_id = os:unmarshalInt64()
end
function SRelieveQingYuanSuccess:sizepolicy(size)
  return size <= 65535
end
return SRelieveQingYuanSuccess

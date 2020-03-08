local CRecallChild = class("CRecallChild")
CRecallChild.TYPEID = 12609442
function CRecallChild:ctor(child_id, client_currency_num)
  self.id = 12609442
  self.child_id = child_id or nil
  self.client_currency_num = client_currency_num or nil
end
function CRecallChild:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt64(self.client_currency_num)
end
function CRecallChild:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.client_currency_num = os:unmarshalInt64()
end
function CRecallChild:sizepolicy(size)
  return size <= 65535
end
return CRecallChild

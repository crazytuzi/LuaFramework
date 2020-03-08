local CMoveChildHome = class("CMoveChildHome")
CMoveChildHome.TYPEID = 12609287
function CMoveChildHome:ctor(child_id)
  self.id = 12609287
  self.child_id = child_id or nil
end
function CMoveChildHome:marshal(os)
  os:marshalInt64(self.child_id)
end
function CMoveChildHome:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function CMoveChildHome:sizepolicy(size)
  return size <= 65535
end
return CMoveChildHome

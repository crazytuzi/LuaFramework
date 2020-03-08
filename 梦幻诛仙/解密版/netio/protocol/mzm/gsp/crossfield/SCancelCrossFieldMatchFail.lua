local SCancelCrossFieldMatchFail = class("SCancelCrossFieldMatchFail")
SCancelCrossFieldMatchFail.TYPEID = 12619523
function SCancelCrossFieldMatchFail:ctor(res)
  self.id = 12619523
  self.res = res or nil
end
function SCancelCrossFieldMatchFail:marshal(os)
  os:marshalInt32(self.res)
end
function SCancelCrossFieldMatchFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SCancelCrossFieldMatchFail:sizepolicy(size)
  return size <= 65535
end
return SCancelCrossFieldMatchFail

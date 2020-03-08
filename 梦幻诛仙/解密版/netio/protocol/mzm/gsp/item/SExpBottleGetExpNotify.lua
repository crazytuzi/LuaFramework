local SExpBottleGetExpNotify = class("SExpBottleGetExpNotify")
SExpBottleGetExpNotify.TYPEID = 12584863
function SExpBottleGetExpNotify:ctor(get_exp)
  self.id = 12584863
  self.get_exp = get_exp or nil
end
function SExpBottleGetExpNotify:marshal(os)
  os:marshalInt32(self.get_exp)
end
function SExpBottleGetExpNotify:unmarshal(os)
  self.get_exp = os:unmarshalInt32()
end
function SExpBottleGetExpNotify:sizepolicy(size)
  return size <= 65535
end
return SExpBottleGetExpNotify

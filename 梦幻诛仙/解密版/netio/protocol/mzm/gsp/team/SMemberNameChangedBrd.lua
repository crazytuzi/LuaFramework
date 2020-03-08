local SMemberNameChangedBrd = class("SMemberNameChangedBrd")
SMemberNameChangedBrd.TYPEID = 12588335
function SMemberNameChangedBrd:ctor(roleid, name)
  self.id = 12588335
  self.roleid = roleid or nil
  self.name = name or nil
end
function SMemberNameChangedBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
end
function SMemberNameChangedBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
end
function SMemberNameChangedBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberNameChangedBrd

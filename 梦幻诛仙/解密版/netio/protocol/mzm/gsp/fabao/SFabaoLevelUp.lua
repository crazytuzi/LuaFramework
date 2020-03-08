local SFabaoLevelUp = class("SFabaoLevelUp")
SFabaoLevelUp.TYPEID = 12595987
function SFabaoLevelUp:ctor(fabaoid, fabaoOriginallv, fabaolv)
  self.id = 12595987
  self.fabaoid = fabaoid or nil
  self.fabaoOriginallv = fabaoOriginallv or nil
  self.fabaolv = fabaolv or nil
end
function SFabaoLevelUp:marshal(os)
  os:marshalInt32(self.fabaoid)
  os:marshalInt32(self.fabaoOriginallv)
  os:marshalInt32(self.fabaolv)
end
function SFabaoLevelUp:unmarshal(os)
  self.fabaoid = os:unmarshalInt32()
  self.fabaoOriginallv = os:unmarshalInt32()
  self.fabaolv = os:unmarshalInt32()
end
function SFabaoLevelUp:sizepolicy(size)
  return size <= 65535
end
return SFabaoLevelUp

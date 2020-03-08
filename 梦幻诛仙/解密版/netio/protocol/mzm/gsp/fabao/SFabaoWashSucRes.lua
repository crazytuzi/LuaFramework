local SFabaoWashSucRes = class("SFabaoWashSucRes")
SFabaoWashSucRes.TYPEID = 12596008
function SFabaoWashSucRes:ctor(equiped, fabaouuid, skillid)
  self.id = 12596008
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.skillid = skillid or nil
end
function SFabaoWashSucRes:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.skillid)
end
function SFabaoWashSucRes:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.skillid = os:unmarshalInt32()
end
function SFabaoWashSucRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoWashSucRes

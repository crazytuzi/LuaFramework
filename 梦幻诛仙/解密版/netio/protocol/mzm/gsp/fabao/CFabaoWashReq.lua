local CFabaoWashReq = class("CFabaoWashReq")
CFabaoWashReq.TYPEID = 12595974
function CFabaoWashReq:ctor(equiped, fabaouuid, useyuanbao)
  self.id = 12595974
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.useyuanbao = useyuanbao or nil
end
function CFabaoWashReq:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.useyuanbao)
end
function CFabaoWashReq:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.useyuanbao = os:unmarshalInt32()
end
function CFabaoWashReq:sizepolicy(size)
  return size <= 65535
end
return CFabaoWashReq

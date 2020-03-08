local SSyncGangMapCreate = class("SSyncGangMapCreate")
SSyncGangMapCreate.TYPEID = 12589913
function SSyncGangMapCreate:ctor(sceneId)
  self.id = 12589913
  self.sceneId = sceneId or nil
end
function SSyncGangMapCreate:marshal(os)
  os:marshalInt32(self.sceneId)
end
function SSyncGangMapCreate:unmarshal(os)
  self.sceneId = os:unmarshalInt32()
end
function SSyncGangMapCreate:sizepolicy(size)
  return size <= 65535
end
return SSyncGangMapCreate

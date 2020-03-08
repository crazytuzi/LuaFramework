local CGetMonsterLocationReq = class("CGetMonsterLocationReq")
CGetMonsterLocationReq.TYPEID = 12590860
function CGetMonsterLocationReq:ctor(monsterCfgId, targetMapId)
  self.id = 12590860
  self.monsterCfgId = monsterCfgId or nil
  self.targetMapId = targetMapId or nil
end
function CGetMonsterLocationReq:marshal(os)
  os:marshalInt32(self.monsterCfgId)
  os:marshalInt32(self.targetMapId)
end
function CGetMonsterLocationReq:unmarshal(os)
  self.monsterCfgId = os:unmarshalInt32()
  self.targetMapId = os:unmarshalInt32()
end
function CGetMonsterLocationReq:sizepolicy(size)
  return size <= 65535
end
return CGetMonsterLocationReq

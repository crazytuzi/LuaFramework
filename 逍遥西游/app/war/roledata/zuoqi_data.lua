if not CZuoqiData then
  CZuoqiData = class("CZuoqiData", CRoleData)
end
function CZuoqiData:ctor(playerId, objId, lTypeId, copyProperties)
  CZuoqiData.super.ctor(self, playerId, objId, lTypeId, copyProperties)
end
function CZuoqiData:CalculateProperty()
  for i, v in pairs({PROPERTY_NAME, PROPERTY_SHAPE}) do
    self:setProperty(v, data_getRoleProFromData(self.m_LtypeId, v))
  end
  local petList = self:getProperty(PROPERTY_ZUOQI_PETLIST)
  if petList ~= nil and petList ~= 0 then
    local player = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
    for _, petId in pairs(petList) do
      local petIns = player:getObjById(petId)
      if petIns and WAR_CODE_IS_SERVER ~= true then
        petIns:CalculateProperty()
      else
      end
    end
  end
end

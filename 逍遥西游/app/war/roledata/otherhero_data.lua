if not COtherHeroData then
  COtherHeroData = class("COtherHeroData", CRoleData)
end
function COtherHeroData:ctor(playerId, objId, lTypeId, copyProperties)
  COtherHeroData.super.ctor(self, playerId, objId, lTypeId, copyProperties, false)
end
function COtherHeroData:CalculateProperty()
  for i, v in pairs({
    PROPERTY_GENDER,
    PROPERTY_RACE,
    PROPERTY_SHAPE
  }) do
    self:setProperty(v, data_getRoleProFromData(self.m_LtypeId, v))
  end
end
function COtherHeroData:UpdateLogicTypeId(lTypeId)
  self.m_LtypeId = lTypeId
  self:CalculateProperty()
end
function COtherHeroData:getBSFShapeId()
  local shape = self:getProperty(PROPERTY_SHAPE)
  local bsType = self:getProperty(PROPERTY_BIANSHENFUTYPE)
  if bsType == nil or bsType == 0 then
    return shape
  else
    return bsType
  end
end
function COtherHeroData:getBSFRace()
  local shape = self:getProperty(PROPERTY_SHAPE)
  local bsType = self:getProperty(PROPERTY_BIANSHENFUTYPE)
  if bsType == nil or bsType == 0 then
    return self:getProperty(PROPERTY_RACE)
  else
    return data_getRoleRace(bsType)
  end
end

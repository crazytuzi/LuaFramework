if not CRoleData then
  CRoleData = class("CRoleData", CBaseData)
end
function CRoleData:ctor(playerId, objId, lTypeId, copyProperties, extendFlag)
  CRoleData.super.ctor(self, playerId, objId, lTypeId)
  self.m_PropertyChangedListener = nil
  Properties.extend(self)
  if extendFlag == false then
  else
    SkillAbility.extend(self)
    ZhuangBeiData.extend(self)
    RandomKangData.extend(self)
    PetSkillExtend.extend(self)
  end
  if copyProperties then
    self:setProSerialization(copyProperties)
  else
  end
end
function CRoleData:CalculateProperty()
  printLogDebug("role_data", "ERROR:没有实现接口：CalculateProperty重新计算所有属性。roledata才需要计算，ai是不需要计算的。self.__cname是%s", self.__cname)
end
function CRoleData:getKangPro(skillAttr)
  local kangProType = EFFECTTYPE_2_PROPERTY_KANG[skillAttr]
  if kangProType == nil then
    printLogDebug("role_data", "找不到效果ID对应(%s)的抗性属性", tostring(skillAttr))
    return 0
  end
  return self:getProperty(kangProType)
end
function CRoleData:getFkangPro(skillAttr)
  local kangProType = EFFECTTYPE_2_PROPERTY_FKANG[skillAttr]
  if kangProType == nil then
    printLogDebug("role_data", "找不到效果ID对应(%s)的 反 抗性属性", tostring(skillAttr))
    return 0
  end
  return self:getProperty(kangProType)
end
function CRoleData:getTempKangPro(skillAttr)
  local kangProType = EFFECTTYPE_2_PROPERTY_KANG[skillAttr]
  if kangProType == nil then
    printLogDebug("role_data", "找不到效果ID对应(%s)的抗性属性", tostring(skillAttr))
    return nil
  end
  return self:getTempProperty(kangProType)
end
function CRoleData:setTempKangPro(skillAttr, value)
  local kangProType = EFFECTTYPE_2_PROPERTY_KANG[skillAttr]
  if kangProType == nil then
    printLogDebug("role_data", "找不到效果ID对应(%s)的抗性属性", tostring(skillAttr))
    return false
  end
  self:setTempProperty(kangProType, value)
  return true
end
function CRoleData:getProSerialization()
  local pro = self:getOwnPropertyValueDict()
  local sklPro = self:getSkillSerialization()
  local zbPro = self:getZhuangBeiSerialization()
  local petSPro = self:getPetSkillSerialization()
  local randomKangPro = self:getRandomKangSerialization()
  return {
    pro = pro,
    sklPro = sklPro,
    zbPro = zbPro,
    petSPro = petSPro,
    attrPro = attrPro,
    lvPro = lvPro,
    randomKangPro = randomKangPro
  }
end
function CRoleData:setProSerialization(proSerialization)
  if proSerialization.pro then
    for k, v in pairs(proSerialization.pro) do
      local curV = v[1]
      if curV ~= nil then
        self:setProperty(k, curV)
      end
      local maxV = v[2]
      if maxV ~= nil then
        self:setMaxProperty(k, maxV)
      end
    end
  end
  self:setSkillSerialization(proSerialization.sklPro, false)
  self:setZhuangBeiSerialization(proSerialization.zbPro, false)
  self:setPetSkillSerialization(proSerialization.petSPro)
  self:setRandomKangSerialization(proSerialization.randomKangPro, false)
end

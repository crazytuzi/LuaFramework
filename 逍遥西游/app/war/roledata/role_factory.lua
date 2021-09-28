if not CRoleFactory then
  CRoleFactory = class("CRoleFactory")
end
function CRoleFactory:ctor(classesExt)
  if WAR_CODE_IS_SERVER ~= true then
    self.m_Classes = {
      [tostring(LOGICTYPE_PET)] = CPetData,
      [tostring(LOGICTYPE_HERO)] = CHeroData,
      [tostring(LOGICTYPE_MONSTER)] = CMonsterData,
      [tostring(LOGICTYPE_ZUOQI)] = CZuoqiData
    }
  else
    self.m_Classes = {
      [tostring(LOGICTYPE_PET)] = CWarPetData,
      [tostring(LOGICTYPE_HERO)] = CWarHeroData,
      [tostring(LOGICTYPE_MONSTER)] = CWarMonsterData,
      [tostring(LOGICTYPE_ZUOQI)] = CWarZuoqiData
    }
  end
  if classesExt and type(classesExt) == "table" then
    for k, v in pairs(classesExt) do
      self.m_Classes[k] = v
    end
  end
end
function CRoleFactory:newObject(playerId, objId, lTypeId, copyProperties, warID)
  local lType = GetRoleObjType(lTypeId)
  local cls = self.m_Classes[tostring(lType)]
  if cls == nil then
    printLogDebug("role_factory", "创建类型[%s]的对象出错：找不到该类型的类", tostring(lType))
    return nil
  end
  local obj = cls.new(playerId, objId, lTypeId, copyProperties, warID)
  return obj
end

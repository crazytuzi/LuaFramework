LIFESKILL_NO = 0
LIFESKILL_MAKEDRUG = 1
LIFESKILL_MAKEFU = 2
LIFESKILL_MAKEFOOD = 3
LIFESKILL_CATCH = 4
LIFESKILL_MAX_LV = 260
LIFESKILL_MAX_BSD = 9999
LifeSkillExtend = {}
function LifeSkillExtend.extend(object)
  object.m_LifeSkill = 0
  object.m_LifeSkillLv = 0
  object.m_LS_BSD = 0
  object.m_LS_Fu_DATA = {}
  object.m_LS_Wine_DATA = {}
  object.m_FuwenTimer = nil
  function object:setBaseLifeSkill(lsType, lsLv)
    if lsType ~= nil then
      object.m_LifeSkill = lsType
      if lsType ~= 0 then
        g_MissionMgr:GuideIdComplete(GuideId_ShengHuoJiNeng)
      end
    end
    if lsLv ~= nil then
      object.m_LifeSkillLv = lsLv
    end
    SendMessage(MsgID_LifeSkillUpdate)
  end
  function object:getBaseLifeSkill()
    return object.m_LifeSkill, object.m_LifeSkillLv
  end
  function object:getCatchPetSkillLv()
    if object.m_LifeSkill == LIFESKILL_CATCH then
      return object.m_LifeSkillLv
    else
      return 0
    end
  end
  function object:setLifeSkillBSD(bsd)
    object.m_LS_BSD = bsd or 0
    SendMessage(MsgID_LifeSkillBSDUpdate)
  end
  function object:getLifeSkillBSD()
    return object.m_LS_BSD
  end
  function object:setLifeSkillWineData(wineId, warNum)
    object.m_LS_Wine_DATA.wid = wineId
    object.m_LS_Wine_DATA.v = warNum
    SendMessage(MsgID_LifeSkillWineUpdate)
    local mainHero = object:getMainHero()
    if mainHero then
      mainHero:CalculateProperty()
    end
  end
  function object:getLifeSkillWineData()
    return object.m_LS_Wine_DATA
  end
  function object:setLifeSkillFuData(fuId, value, tType)
    if (value == nil or value == 0) and (fuId == ITEM_DEF_FU_SXF or fuId == ITEM_DEF_FU_SXF) then
      if object.m_LS_Fu_DATA.fid == fuId then
        fuId = 0
      else
        return
      end
    end
    if fuId == ITEM_DEF_FU_SXF then
      object.m_LS_Fu_DATA.fid = fuId
      object.m_LS_Fu_DATA.v = value
      object.m_LS_Fu_DATA.time = g_DataMgr:getServerTime()
      object.m_LS_Fu_DATA.t = nil
    elseif fuId == ITEM_DEF_FU_BSF then
      object.m_LS_Fu_DATA.fid = fuId
      object.m_LS_Fu_DATA.v = value
      object.m_LS_Fu_DATA.time = g_DataMgr:getServerTime()
      object.m_LS_Fu_DATA.t = tType
    else
      object.m_LS_Fu_DATA.fid = fuId
      object.m_LS_Fu_DATA.v = value
      object.m_LS_Fu_DATA.time = nil
      object.m_LS_Fu_DATA.t = nil
    end
    SendMessage(MsgID_LifeSkillFuUpdate)
    local mainHero = object:getMainHero()
    if mainHero then
      mainHero:CalculateProperty()
    end
    if object.m_LS_Fu_DATA.time == nil then
      object.DelFuWenTimer()
    else
      object.StartFuWenTimer()
    end
  end
  function object:getLifeSkillFuData()
    return object.m_LS_Fu_DATA
  end
  function object:getAddSpeedNum()
    if object.m_LS_Fu_DATA.fid == ITEM_DEF_FU_SXF and object.m_LS_Fu_DATA.time ~= nil and object.m_LS_Fu_DATA.v ~= nil and g_DataMgr:getServerTime() < object.m_LS_Fu_DATA.time + object.m_LS_Fu_DATA.v then
      return JSFSpeedNum
    end
    return NormalSpeedNum
  end
  function object:getBianShenFuType()
    if object.m_LS_Fu_DATA.fid == ITEM_DEF_FU_BSF and object.m_LS_Fu_DATA.time ~= nil and object.m_LS_Fu_DATA.v ~= nil and g_DataMgr:getServerTime() < object.m_LS_Fu_DATA.time + object.m_LS_Fu_DATA.v then
      return object.m_LS_Fu_DATA.t or 0
    end
    return 0
  end
  function object:StartFuWenTimer()
    if object.m_FuwenTimer then
      scheduler.unscheduleGlobal(object.m_FuwenTimer)
    end
    object.m_FuwenTimer = scheduler.scheduleGlobal(function()
      if object.CheckFuwenUpdate then
        object:CheckFuwenUpdate()
      end
    end, 1)
  end
  function object:DelFuWenTimer()
    if object.m_FuwenTimer then
      scheduler.unscheduleGlobal(object.m_FuwenTimer)
      object.m_FuwenTimer = nil
    end
  end
  function object:CheckFuwenUpdate()
    if object.m_LS_Fu_DATA.fid == ITEM_DEF_FU_SXF then
      if object.m_LS_Fu_DATA.time ~= nil and object.m_LS_Fu_DATA.v ~= nil and g_DataMgr:getServerTime() > object.m_LS_Fu_DATA.time + object.m_LS_Fu_DATA.v then
        object:setLifeSkillFuData(0, 0)
        netsend.netlifeskill.checkLifeSkillBuffById(ITEM_DEF_FU_SXF)
      end
    elseif object.m_LS_Fu_DATA.fid == ITEM_DEF_FU_BSF and object.m_LS_Fu_DATA.time ~= nil and object.m_LS_Fu_DATA.v ~= nil and g_DataMgr:getServerTime() > object.m_LS_Fu_DATA.time + object.m_LS_Fu_DATA.v then
      object:setLifeSkillFuData(0, 0)
      netsend.netlifeskill.checkLifeSkillBuffById(ITEM_DEF_FU_BSF)
    end
  end
  function object:GetJiaSuFuwenRestTime()
    if object.m_LS_Fu_DATA.fid == ITEM_DEF_FU_SXF then
      if object.m_LS_Fu_DATA.time ~= nil and object.m_LS_Fu_DATA.v ~= nil then
        return math.max(object.m_LS_Fu_DATA.time + object.m_LS_Fu_DATA.v - g_DataMgr:getServerTime(), 0)
      else
        return 0
      end
    else
      return 0
    end
  end
  function object:GetBianShenFuwenRestTime()
    if object.m_LS_Fu_DATA.fid == ITEM_DEF_FU_BSF then
      if object.m_LS_Fu_DATA.time ~= nil and object.m_LS_Fu_DATA.v ~= nil then
        return math.max(object.m_LS_Fu_DATA.time + object.m_LS_Fu_DATA.v - g_DataMgr:getServerTime(), 0)
      else
        return 0
      end
    else
      return 0
    end
  end
end
return LifeSkillExtend

Player = class("Player", CRoleFactory)
local lfs = require("lfs")
local playerArchivePath = device.writablePath .. "rdata/"
lfs.mkdir(playerArchivePath)
local syncHeroPros = {
  [PROPERTY_EXP] = 1,
  [PROPERTY_ROLELEVEL] = 1,
  [PROPERTY_ZHUANSHENG] = 1
}
function Player:ctor(iroleId, isLocal)
  Player.super.ctor(self)
  self.m_RoleId = iroleId
  self.m_IsLocal = isLocal
  self.m_Account = nil
  self.m_Pwd = nil
  self.m_RoleType = nil
  self.m_RoleName = nil
  self.m_ExtraPetLimitNum = 0
  self.m_Roles = {}
  self.m_ObjectIds = {}
  for k, v in pairs(self.m_Classes) do
    self.m_ObjectIds[k] = {}
  end
  self.m_CacheSyncData = {}
  self.m_CacheSyncDstData = {}
  self.m_MapId = -1
  self.m_IsHide = false
  self.m_LastSyncTime = 0
  self.m_UpdateSkillProficiency = false
  self.m_SkillProficiency = {}
  for i = 1, 15 do
    self.m_SkillProficiency[i] = 0
  end
  self.m_SkillProficiency[3] = 1
  self.m_SkillProficiency[8] = 1
  self.m_SkillProficiency[13] = 1
  self.m_ChangeWuxingNum = 0
  self.m_MainHeroId = nil
  self._roleproperty = {}
  self._WarUISetting = {}
  self.m_RecentEmote = {}
  self._SysSetting = {}
  self.m_WarSetting = {}
  self.m_DrugSetting = {}
  self._RecentPrivateChatInfo = {}
  self._ClientVoiceId = 0
  self.m_RecentChat = {}
  self._SelChannel = {}
  self._RemindHuodongData = {}
  self._canGetHuoBanShowList = {}
  local saveKeys = {
    "_roleproperty",
    "_WarUISetting",
    "m_RecentEmote",
    "_SysSetting",
    "_RecentPrivateChatInfo",
    "_ClientVoiceId",
    "m_RecentChat",
    "_SelChannel",
    "_RemindHuodongData",
    "_canGetHuoBanShowList"
  }
  if self.m_IsLocal then
    self:InitArchive(saveKeys)
    ResExtend.extend(self)
    FubenExtend.extend(self)
    VIPExtend.extend(self)
    PackageExtend.extend(self)
    ZuoqiExtend.extend(self)
    BoxExtend.extend(self)
    JiuguanExtend.extend(self)
    DoubleExpExtend.extend(self)
    RechargeExtend.extend(self)
    GuajiExtend.extend(self)
    LifeSkillExtend.extend(self)
    ShopXianGouExtend.extend(self)
    ExtraExpExtend.extend(self)
    JiaYiWanExtend.extend(self)
    SafetylockExtend.extend(self)
    ZhuaGuaExtend(self)
    GuiWangExtend(self)
    BangPaiTotemExtend(self)
    BangPaiTaskToken(self)
    XiuLuoExtend(self)
  end
  ChengweiExtend.extend(self)
end
function Player:getPlayerId()
  return self.m_RoleId
end
function Player:isLocal()
  return self.m_IsLocal
end
function Player:setCacheSyncData(data)
  self.m_CacheSyncData = data
end
function Player:getCacheSyncData()
  return self.m_CacheSyncData
end
function Player:setCacheSyncDstData(data)
  self.m_CacheSyncDstData = data
end
function Player:getCacheSyncDstData()
  return self.m_CacheSyncDstData
end
function Player:setMainHeroId(mainId)
  self.m_MainHeroId = mainId
end
function Player:getMainHeroId()
  return self.m_MainHeroId
end
function Player:getMainHero()
  if self.m_MainHeroId == nil then
    return nil
  end
  return self.m_Roles[tostring(self.m_MainHeroId)]
end
function Player:setSvrproToHero(hero, svrPro, isSetSkillProficiency)
  local isSyncOtherHero = false
  local isMainHero = hero:getObjId() == self.m_MainHeroId
  local proTable = {}
  for k, v in pairs(svrPro) do
    local pro = SVRKEY_PROPERTIES[k]
    if pro then
      if pro == PROPERTY_GenGu then
        if hero:getProperty(PROPERTY_OGenGu) ~= v then
          hero:setProperty(PROPERTY_OGenGu, v)
          proTable[PROPERTY_OGenGu] = v
        end
      elseif pro == PROPERTY_Lingxing then
        if hero:getProperty(PROPERTY_OLingxing) ~= v then
          hero:setProperty(PROPERTY_OLingxing, v)
          proTable[PROPERTY_OLingxing] = v
        end
      elseif pro == PROPERTY_LiLiang then
        if hero:getProperty(PROPERTY_OLiLiang) ~= v then
          hero:setProperty(PROPERTY_OLiLiang, v)
          proTable[PROPERTY_OLiLiang] = v
        end
      elseif pro == PROPERTY_MinJie and hero:getProperty(PROPERTY_OMinJie) ~= v then
        hero:setProperty(PROPERTY_OMinJie, v)
        proTable[PROPERTY_OMinJie] = v
      end
      if hero:getProperty(pro) ~= v then
        hero:setProperty(pro, v)
        proTable[pro] = v
      end
    end
    if isMainHero and isSyncOtherHero == false and syncHeroPros[pro] == 1 then
      isSyncOtherHero = true
    end
  end
  if table_is_empty(proTable) == false then
    hero:CalculateProperty()
    if isSetSkillProficiency == true and self.m_UpdateSkillProficiency == true then
      self:setHeroSkillProficiency(hero)
    end
    SendMessage(MsgID_HeroUpdate, {
      pid = self.m_RoleId,
      heroId = hero:getObjId(),
      pro = proTable
    })
    if isSyncOtherHero then
      local proChanged = {}
      for k, v in pairs(syncHeroPros) do
        if proTable[k] ~= nil then
          proChanged[k] = hero:getProperty(k)
        end
      end
      local heroIds = self:getAllRoleIds(LOGICTYPE_HERO) or {}
      for i, hid in pairs(heroIds) do
        local heroIns = self:getObjById(hid)
        if heroIns then
          for kk, vv in pairs(proChanged) do
            heroIns:setProperty(kk, vv)
          end
          SendMessage(MsgID_HeroUpdate, {
            pid = self.m_RoleId,
            heroId = heroIns:getObjId(),
            pro = proChanged
          })
        end
      end
    end
  end
end
function Player:SetRoleInitHpAndMp(roleId, hp, mp)
  local role = self:getObjById(roleId)
  if role == nil then
    return
  end
  local proTable = {}
  local changeFlag = false
  if role:getProperty(PROPERTY_INIT_HP) ~= hp then
    changeFlag = true
  end
  if role:getProperty(PROPERTY_INIT_MP) ~= mp then
    changeFlag = true
  end
  if changeFlag then
    local maxHp = role:getMaxProperty(PROPERTY_HP)
    if hp and hp > maxHp then
      hp = maxHp
    end
    hp = hp or 0
    role:setProperty(PROPERTY_INIT_HP, hp)
    proTable[PROPERTY_INIT_HP] = hp
    local maxMp = role:getMaxProperty(PROPERTY_MP)
    if mp and mp > maxMp then
      mp = maxMp
    end
    mp = mp or 0
    role:setProperty(PROPERTY_INIT_MP, mp)
    proTable[PROPERTY_INIT_MP] = mp
    role:CalculateProperty()
    local roleType = role:getType()
    if roleType == LOGICTYPE_HERO then
      SendMessage(MsgID_HeroUpdate, {
        pid = self.m_RoleId,
        heroId = role:getObjId(),
        pro = proTable
      })
    elseif roleType == LOGICTYPE_PET then
      SendMessage(MsgID_PetUpdate, {
        pid = self.m_RoleId,
        petId = role:getObjId(),
        pro = proTable
      })
    end
  end
end
function Player:updateSkillProficiency(svrSkillProficiency)
  print("=====>>>updateSkillProficiency")
  local tempChangeData = {}
  for _, tempData in pairs(svrSkillProficiency) do
    local oldValue = self.m_SkillProficiency[tempData.i_snum]
    self.m_SkillProficiency[tempData.i_snum] = tempData.i_pnum
    tempChangeData[tempData.i_snum] = {
      oldValue,
      tempData.i_pnum
    }
  end
  self.m_UpdateSkillProficiency = true
  local heroIds = self:getAllRoleIds(LOGICTYPE_HERO) or {}
  for _, heroId in ipairs(heroIds) do
    local heroObj = self:getObjById(heroId)
    self:setHeroSkillProficiency(heroObj)
  end
  for skillNo, data in pairs(tempChangeData) do
    SendMessage(MsgID_HeroSkillExpChange, {
      pid = self.m_RoleId,
      skillNo = skillNo,
      oldSkillExp = data[1],
      newSkillExp = data[2]
    })
  end
end
function Player:updateMarrySkillProficiency(svrSkillProficiency)
  if svrSkillProficiency == nil then
    return
  end
  print("=====>>>updateMarrySkillProficiency")
  local mainHeroIns = self:getMainHero()
  if mainHeroIns then
    for _, data in pairs(svrSkillProficiency) do
      local no = data.i_snum or 0
      local exp = data.i_pnum or 0
      local skillId = ACTIVE_MARRYSKILLLIST[no]
      if skillId ~= nil then
        mainHeroIns:setProficiency(skillId, exp)
        SendMessage(MsgID_HeroMarrySkillExpChange, {skillId = skillId, exp = exp})
      end
    end
  end
end
function Player:setHeroSkillProficiency(heroObj)
  local heroId = heroObj:getObjId()
  local lv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  local starPoint = heroObj:getProperty(PROPERTY_STARPOINT)
  local starNum = data_getHeroStarNum(starPoint)
  local skillTypeList = heroObj:getSkillTypeList()
  if heroId == self.m_MainHeroId then
    for i = 1, 3 do
      local skillList = data_getSkillListByAttr(skillTypeList[i])
      for j = 1, 5 do
        local skillId = skillList[j]
        if j == 1 then
          heroObj:setProficiency(skillId, 0)
        elseif j == 2 then
          heroObj:setProficiency(skillId, 0)
        else
          heroObj:setProficiency(skillId, self.m_SkillProficiency[(i - 1) * 5 + j])
        end
      end
    end
  else
    for _, skillAttr in pairs(skillTypeList) do
      if skillAttr ~= 0 then
        local skillList = data_getSkillListByAttr(skillAttr)
        for j = 1, 5 do
          local skillId = skillList[j]
          if j == 1 then
            heroObj:setProficiency(skillId, 0)
          elseif j == 2 then
            heroObj:setProficiency(skillId, 0)
          elseif j == 3 then
            if lv < Skill_HuobanSkill1OpenLv then
              heroObj:setProficiency(skillId, 0)
            else
              local s = math.floor((self.m_SkillProficiency[3] + self.m_SkillProficiency[8] + self.m_SkillProficiency[13]) / 3)
              heroObj:setProficiency(skillId, math.max(1, s))
            end
          elseif j == 4 then
            if lv < Skill_HuobanSkill2OpenLv then
              heroObj:setProficiency(skillId, 0)
            else
              local s = math.floor((self.m_SkillProficiency[4] + self.m_SkillProficiency[9] + self.m_SkillProficiency[14]) / 3)
              heroObj:setProficiency(skillId, math.max(1, s))
            end
          elseif j == 5 then
            if lv < Skill_HuobanSkill3OpenLv then
              heroObj:setProficiency(skillId, 0)
            else
              local s = math.floor((self.m_SkillProficiency[5] + self.m_SkillProficiency[10] + self.m_SkillProficiency[15]) / 3)
              heroObj:setProficiency(skillId, math.max(1, s))
            end
          end
        end
      end
    end
  end
end
function Player:getShimenNpcId()
  local mainHeroIns = self:getMainHero()
  if mainHeroIns then
    return getShimenNpcIdByTypeId(mainHeroIns:getTypeId())
  end
end
function Player:setSvrproToPet(pet, svrPro)
  print([[

=====Player:setSvrproToPet====]])
  local proTable = {}
  for k, v in pairs(svrPro) do
    local pro = SVRKEY_PROPERTIES[k]
    if pro then
      if pro == PROPERTY_ZJSKILLSEXP then
        local newValue = {}
        if type(v) ~= "table" then
          v = {}
        end
        for skillId, expData in pairs(v) do
          skillId = tonumber(skillId)
          if type(expData) == "table" then
            if expData[1] < expData[2] then
              newValue[skillId] = expData
            end
          elseif expData < data_getSkillNeedXiuLianDu(skillId) then
            newValue[skillId] = {
              expData,
              data_getSkillNeedXiuLianDu(skillId)
            }
          end
        end
        local oldValue = pet:getProperty(pro)
        local needUpdateFlag = false
        if type(oldValue) ~= "table" then
          needUpdateFlag = true
        else
          for zjsExpKey, zjsExpData in pairs(oldValue) do
            local tempExpData = newValue[zjsExpKey]
            if tempExpData == nil or type(tempExpData) ~= "table" or type(zjsExpData) ~= "table" or #tempExpData ~= #zjsExpData or tempExpData[1] ~= zjsExpData[1] or tempExpData[2] ~= zjsExpData[2] then
              needUpdateFlag = true
              break
            end
          end
          for zjsExpKey, zjsExpData in pairs(newValue) do
            local tempExpData = oldValue[zjsExpKey]
            if tempExpData == nil or type(tempExpData) ~= "table" or type(zjsExpData) ~= "table" or #tempExpData ~= #zjsExpData or tempExpData[1] ~= zjsExpData[1] or tempExpData[2] ~= zjsExpData[2] then
              needUpdateFlag = true
              break
            end
          end
        end
        if needUpdateFlag then
          pet:setProperty(pro, newValue)
          proTable[pro] = newValue
        end
      else
        if pro == PROPERTY_GenGu then
          if pet:getProperty(PROPERTY_OGenGu) ~= v then
            pet:setProperty(PROPERTY_OGenGu, v)
            proTable[PROPERTY_OGenGu] = v
          end
        elseif pro == PROPERTY_Lingxing then
          if pet:getProperty(PROPERTY_OLingxing) ~= v then
            pet:setProperty(PROPERTY_OLingxing, v)
            proTable[PROPERTY_OLingxing] = v
          end
        elseif pro == PROPERTY_LiLiang then
          if pet:getProperty(PROPERTY_OLiLiang) ~= v then
            pet:setProperty(PROPERTY_OLiLiang, v)
            proTable[PROPERTY_OLiLiang] = v
          end
        elseif pro == PROPERTY_MinJie and pet:getProperty(PROPERTY_OMinJie) ~= v then
          pet:setProperty(PROPERTY_OMinJie, v)
          proTable[PROPERTY_OMinJie] = v
        end
        if pet:getProperty(pro) ~= v then
          pet:setProperty(pro, v)
          proTable[pro] = v
        end
      end
    end
  end
  local randomKangChange = false
  for i, svrKangKey in ipairs({"i_defrate1", "i_defrate2"}) do
    local knum = svrPro[svrKangKey]
    print("=====knum", svrKangKey, knum)
    if knum then
      local kangPro = PROPERTIES_RANDOM_KANG[knum]
      print("=====kangPro", kangPro)
      if kangPro then
        local oldRandomKang = pet:getRandomKang()
        if oldRandomKang[kangPro] ~= PetRandomKangValue then
          pet:setRandomKang(kangPro, PetRandomKangValue, i)
          randomKangChange = true
          proTable[kangPro] = PetRandomKangValue
        end
      end
    end
  end
  if table_is_empty(proTable) == false then
    if randomKangChange then
      SendMessage(MsgID_PetRandomKangUpdate, {
        pid = self.m_RoleId,
        petId = pet:getObjId()
      })
    end
    pet:CalculateProperty()
    SendMessage(MsgID_PetUpdate, {
      pid = self.m_RoleId,
      petId = pet:getObjId(),
      pro = proTable
    })
  end
end
function Player:AddObject(objId, objIns)
  self.m_Roles[tostring(objId)] = objIns
  local ids = self.m_ObjectIds[tostring(objIns:getType())]
  local idx
  for i, v in ipairs(ids) do
    if v == objId then
      idx = i
      break
    end
  end
  if idx == nil then
    ids[#ids + 1] = objId
  end
  local roleData = self._roleproperty[tostring(objId)]
  if roleData then
    for k, v in pairs(roleData) do
      objIns:setProperty(k, v)
    end
  end
end
function Player:getObjById(objId)
  return self.m_Roles[tostring(objId)]
end
function Player:getObjProperty(objId, proName)
  local obj = self:getObjById(objId)
  if obj == nil then
    return 0
  else
    return obj:getProperty(proName)
  end
end
function Player:getAllRoleIds(objectType)
  return self.m_ObjectIds[tostring(objectType)]
end
function Player:newObject(objId, lTypeId, copyProperties)
  local playerId = self.m_RoleId
  local obj
  if self.m_IsLocal then
    obj = Player.super.newObject(self, playerId, objId, lTypeId, copyProperties)
  else
    obj = COtherHeroData.new(playerId, objId, lTypeId, copyProperties)
  end
  if self.m_IsLocal and obj then
    obj:CalculateProperty()
    obj:setPropertyChanagedListener(handler(self, self.ObjectPropertyChanged))
  elseif obj then
    obj:CalculateProperty()
  end
  self:AddObject(objId, obj)
  return obj
end
function Player:DeleteRole(objId)
  local strObjId = tostring(objId)
  local objIns = self.m_Roles[strObjId]
  if objIns == nil then
    return
  end
  self.m_Roles[strObjId] = nil
  local ids = self.m_ObjectIds[tostring(objIns:getType())]
  for i, v in ipairs(ids) do
    if v == objId then
      table.remove(ids, i)
      return
    end
  end
end
function Player:DeleteHero(objId)
  self:DeleteRole(objId)
  if self == g_LocalPlayer then
    SendMessage(MsgID_DeleteHero, objId)
  end
end
function Player:DeletePet(objId)
  self:DeleteRole(objId)
  if self == g_LocalPlayer then
    SendMessage(MsgID_DeletePet, objId)
  end
end
function Player:newHeroWithServerPro(objId, lTypeId, svrPro, isNewHeroFlag)
  local playerId = self.m_RoleId
  local obj = Player.super.newObject(self, playerId, objId, lTypeId)
  if obj then
    self:setSvrproToHero(obj, svrPro, true)
    local mainHero = self:getMainHero()
    if mainHero and obj ~= mainHero then
      for k, v in pairs(syncHeroPros) do
        obj:setProperty(k, mainHero:getProperty(k))
      end
    end
    if self.m_IsLocal then
      obj:setPropertyChanagedListener(handler(self, self.ObjectPropertyChanged))
    end
    self:AddObject(objId, obj)
    if isNewHeroFlag == true and self == g_LocalPlayer then
      SendMessage(MsgID_AddHero, self.m_RoleId, objId)
      ShowNewHuobanAnimation(objId, lTypeId)
    end
  end
  return obj
end
function Player:newPetWithServerPro(objId, lTypeId, svrPro, isNewPetFlag)
  local playerId = self.m_RoleId
  local obj = Player.super.newObject(self, playerId, objId, lTypeId)
  if obj then
    self:setSvrproToPet(obj, svrPro)
    if self.m_IsLocal then
      obj:setPropertyChanagedListener(handler(self, self.ObjectPropertyChanged))
    end
    self:AddObject(objId, obj)
    if isNewPetFlag == true and self == g_LocalPlayer then
      SendMessage(MsgID_AddPet, self.m_RoleId, objId, lTypeId)
    end
  end
  return obj
end
function Player:ObjectPropertyChanged(obj, propertyType, changedType, value_new, value_old)
  if propertyType == PROPERTY_FREEPOINT and value_new < value_old then
    g_MissionMgr:GuideIdComplete(GuideId_setHeroPro)
  end
end
function Player:InitArchive(saveKeys)
  local fileName = crypto.md5(tostring(self.m_RoleId), false)
  local savePath = playerArchivePath .. fileName
  print("===>>self.m_PlayerArchivePath:", savePath)
  ArchiveExtend.extend(self, savePath, saveKeys, "lk>-=45L")
  self:LoadArchive()
end
function Player:SaveRoleProperty(roleId, proName, proValue, isSave)
  if self.m_IsLocal ~= true then
    return
  end
  local k = tostring(roleId)
  local roleData = self._roleproperty[k]
  if roleData == nil then
    roleData = {}
    self._roleproperty[k] = roleData
  end
  roleData[proName] = proValue
  if isSave == true then
    self:SaveArchive()
  end
end
function Player:SaveWarUISetting(warUISetting)
  if warUISetting ~= nil then
    self._WarUISetting = {}
    for k, v in pairs(warUISetting) do
      self._WarUISetting[k] = v
    end
    self:SaveArchive()
  end
end
function Player:setMapPosInfo(mapId, isHide, pPos, posType, isNewPlayer)
  if isHide == true then
    self.m_MapId = -1
    self.m_InMapPos = {0, 0}
    if self.m_IsHide == false and isNewPlayer ~= true then
      print("))))))))) deleteTeamInfoWhenPlayerHide-1", self.m_RoleId)
      g_TeamMgr:deleteTeamInfoWhenPlayerHide(self.m_RoleId)
    end
    self.m_IsHide = true
    self.m_InMapPosType = MapPosType_PixelPos
  else
    if self.m_IsHide == true and isNewPlayer ~= true then
      print("))))))))) checkPlayerInfoExistWhenCaptainShow-1", self.m_RoleId)
      g_TeamMgr:checkPlayerInfoExistWhenCaptainShow(self.m_RoleId)
    end
    self.m_IsHide = false
    if pPos ~= nil then
      self.m_InMapPos = {
        pPos[1],
        pPos[2]
      }
    end
    self.m_MapId = mapId
    self.m_InMapPosType = posType
  end
  self.m_LastSyncTime = g_DataMgr:getServerTime()
end
function Player:getMapPosInfo()
  return self.m_MapId, self.m_IsHide, self.m_InMapPos, self.m_InMapPosType, self.m_LastSyncTime
end
function Player:getLastSyncMapPosTime()
  return self.m_LastSyncTime
end
function Player:getHide()
  return self.m_IsHide
end
function Player:setNormalTeamer(flag)
  self.m_IsNormalTeamer = flag
  if self.m_IsLocal then
    SendMessage(MsgID_Team_LocalIsTeamer, self.m_IsNormalTeamer)
  end
end
function Player:getNormalTeamer()
  return self.m_IsNormalTeamer
end
function Player:reflushNormalTeamerFlag()
  local flag = false
  local teamId = g_TeamMgr:getPlayerTeamId(self.m_RoleId)
  if teamId and teamId > 0 then
    local captainPid = g_TeamMgr:getTeamCaptain(teamId)
    if captainPid ~= self.m_RoleId then
      local status = g_TeamMgr:getPlayerTeamState(self.m_RoleId)
      if status == TEAMSTATE_FOLLOW then
        flag = true
      end
    end
  end
  self:setNormalTeamer(flag)
end
function Player:getIsFollowTeam()
  if g_TeamMgr:getLocalPlayerTeamId() ~= 0 and g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
    if g_TeamMgr:localPlayerIsCaptain() then
      return 1
    else
      return 0
    end
  end
  return -1
end
function Player:getIsFollowTeamCommon()
  if g_TeamMgr:getPlayerTeamId(self.m_RoleId) ~= 0 and self:getObjProperty(1, PROPERTY_TEAMSTATE) == TEAMSTATE_FOLLOW then
    if g_TeamMgr:getPlayerIsCaptain(self.m_RoleId) then
      return 1
    else
      return 0
    end
  end
  return -1
end
function Player:getTeamId()
  return self:getObjProperty(1, PROPERTY_TEAMID)
end
function Player:getPlayerIsInTeam()
  if self.m_RoleId == nil then
    return false
  end
  if g_TeamMgr:getPlayerTeamId(self.m_RoleId) ~= 0 then
    return true
  end
  return false
end
function Player:getPlayerInTeamAndIsCaptain()
  if self.m_RoleId == nil then
    return false
  end
  if g_TeamMgr:getPlayerTeamId(self.m_RoleId) ~= 0 and g_TeamMgr:getPlayerIsCaptain(self.m_RoleId) then
    return true
  end
  return false
end
function Player:getPlayerCanJumpToNpc()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    return "你正在进行婚礼巡游,无法进行此项操作"
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    return "帮战地图无法使用此功能"
  end
  if not activity.yzdd:canJumpMap() then
    return ""
  end
  if not g_DuleMgr:canJumpMap() then
    return ""
  end
  if JudgeIsInWar() then
    return "处于战斗中，不能跳转"
  end
  if self:getNormalTeamer() == true then
    return "你已跟随队长中，不能跳转"
  end
  return true
end
function Player:isFunctionUnlock(funcId)
  local data = data_FunctionUnlock[funcId]
  if data == nil then
    return true
  end
  local mainHero = self:getMainHero()
  if mainHero == nil then
    return false
  end
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local zs_r = data.zs
  local lv_r = data.lv
  local alwaysJudgeLvFlag_r = data.AlwaysJudgeLvFlag
  local openFlag = data_judgeFuncOpen(zs, lv, zs_r, lv_r, alwaysJudgeLvFlag_r)
  return openFlag, data.type, data.param
end
function Player:isNpcOptionUnlock(npcFuncId)
  local data = data_NpcTypeInfo[npcFuncId]
  if data == nil then
    return true
  end
  local mainHero = self:getMainHero()
  if mainHero == nil then
    return false
  end
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local zs_r = data.zs
  local lv_r = data.lv
  local alwaysJudgeLvFlag_r = data.AlwaysJudgeLvFlag
  local openFlag = data_judgeFuncOpen(zs, lv, zs_r, lv_r, alwaysJudgeLvFlag_r)
  return openFlag
end
function Player:getObjNumById(objId, includeRole)
  if objId == nil then
    return 0
  end
  objId = tonumber(objId)
  local funcName = REST_GET_NUM_FUNC_NAME[objId]
  if funcName then
    local f = self[funcName]
    if f then
      return f()
    end
  elseif includeRole == true then
    return self:GetItemNum(objId)
  else
    return self:GetItemNumNotIncludeRole(objId)
  end
  return 0
end
function Player:SetExtraPetLimitNum(num)
  self.m_ExtraPetLimitNum = num
  SendMessage(MsgID_ExtraPetLimitNum, num)
end
function Player:GetPetLimitNum()
  return self.m_ExtraPetLimitNum
end
function Player:SetExpandPackageGird(num)
  self.m_ExpandPackgeGridNum = num
  SendMessage(MsgID_ItemInfo_ExpandPackageGird, num)
end
function Player:GetExpandPackageGird()
  return self.m_ExpandPackgeGridNum
end
function Player:SetExpandCangkuGird(num)
  self.m_ExpandCangkuGridNum = num
  SendMessage(MsgID_ItemInfo_ExpandCangkuGird, num)
end
function Player:GetExpandCangkuGird()
  return self.m_ExpandCangkuGridNum
end
function Player:setWarSetting(settingInfo)
  self.m_WarSetting = settingInfo
  SendMessage(MsgID_WarSetting_Change, {
    pid = self.m_RoleId,
    setting = settingInfo
  })
end
function Player:getWarSetting()
  return self.m_WarSetting
end
function Player:setAIUseDrugSetting(drugSetting)
  if self.m_IsLocal ~= true then
    return
  end
  if drugSetting ~= nil then
    self.m_DrugSetting = {}
    for k, v in pairs(drugSetting) do
      self.m_DrugSetting[k] = v
    end
    self:SaveArchive()
  end
end
function Player:getAIUseDrugSetting()
  local result = {}
  for k, v in pairs(self.m_DrugSetting) do
    result[k] = v
  end
  return result
end
function Player:getWarUISetting()
  local result = {}
  for k, v in pairs(self._WarUISetting) do
    result[k] = v
  end
  return result
end
function Player:recordRecentEmote(emoteId)
  for index, eId in pairs(self.m_RecentEmote) do
    if eId == emoteId then
      if index == 1 then
        return
      else
        table.remove(self.m_RecentEmote, index)
      end
    end
  end
  table.insert(self.m_RecentEmote, 1, emoteId)
  if #self.m_RecentEmote >= 10 then
    table.remove(self.m_RecentEmote, 10)
  end
end
function Player:getRecentEmote()
  return DeepCopyTable(self.m_RecentEmote)
end
function Player:recordRecentChat(chatmsg)
  for index, msg in pairs(self.m_RecentChat) do
    if msg == chatmsg then
      if index == 1 then
        return
      else
        table.remove(self.m_RecentChat, index)
      end
    end
  end
  table.insert(self.m_RecentChat, 1, chatmsg)
  if #self.m_RecentChat >= 9 then
    table.remove(self.m_RecentChat, 9)
  end
end
function Player:getRecentChat()
  return DeepCopyTable(self.m_RecentChat)
end
function Player:recordPushSetting(tb)
  self._SysSetting.bpvoice = tb.bpvoice
  self._SysSetting.teamvoice = tb.teamvoice
  self._SysSetting.worldvoice = tb.worldvoice
  self._SysSetting.localvoice = tb.localvoice
  self._SysSetting.fbfriend = tb.fbfriend
  self._SysSetting.curplayernun = tb.curplayernun
  self._SysSetting.tili = tb.tili
  self._SysSetting.tilifull = tb.tilifull
  self._SysSetting.flushshop = tb.flushshop
  self._SysSetting.openactivity = tb.openactivity
end
function Player:getSysSetting()
  return DeepCopyTable(self._SysSetting)
end
function Player:recordPrivateChatTimeInfo(pid)
  self._RecentPrivateChatInfo[tostring(pid)] = g_DataMgr:getServerTime()
end
function Player:deletePrivateChatTimeInfo(pid)
  self._RecentPrivateChatInfo[tostring(pid)] = nil
end
function Player:getPrivateChatTime(pid)
  return self._RecentPrivateChatInfo[tostring(pid)]
end
function Player:savePrivateChatTimeInfo()
  self:SaveArchive()
end
function Player:saveCanGetHuoBanShowList(list)
  if self.m_IsLocal ~= true then
    return
  end
  if list ~= nil then
    self._canGetHuoBanShowList = {}
    for k, v in pairs(list) do
      self._canGetHuoBanShowList[k] = v
    end
    self:SaveArchive()
  end
end
function Player:getCanGetHuoBanShowList()
  local tempList = {}
  for k, v in pairs(self._canGetHuoBanShowList) do
    tempList[k] = v
  end
  return tempList
end
function Player:saveRemindHuodongData(data)
  if self.m_IsLocal ~= true then
    return
  end
  if data ~= nil then
    self._RemindHuodongData = data
    self:SaveArchive()
  end
end
function Player:getRemindHuodongData()
  local remindHD = {}
  local t
  for index, value in pairs(self._RemindHuodongData) do
    if index == 1 then
      t = value
    else
      local hdID = value
      remindHD[hdID] = true
    end
  end
  return t, remindHD
end
function Player:getUniqueVoiceId()
  self._ClientVoiceId = self._ClientVoiceId + 1
  return self._ClientVoiceId
end
function Player:selectChannel(data)
  self._SelChannel = data
end
function Player:getSelectChannel(data)
  return self._SelChannel or {}
end
function Player:Clean()
end
return Player

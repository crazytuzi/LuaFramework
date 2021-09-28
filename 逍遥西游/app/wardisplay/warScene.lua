DefineZOrder_Bg = -100
DefineZOrder_Role = -20
DefineZOrder_Ani = -10
DefineZOrder_Ani_Bottom = -25
Define_LoseData = 0
Define_DaPingData = -1
g_WarScene = nil
function StartSingleWar(warID, fbWarID, warType, warTypeData)
  local posTable = {}
  local mainRolePos
  local mainHeroId = g_LocalPlayer:getMainHeroId()
  local warsettingInfo = g_LocalPlayer:getWarSetting()
  for pos, roleId in pairs(warsettingInfo) do
    local roleObj = g_LocalPlayer:getObjById(roleId)
    if roleObj then
      posTable[pos] = roleId
      local petId = roleObj:getProperty(PROPERTY_PETID)
      if petId ~= nil and petId ~= 0 and g_LocalPlayer:getObjById(petId) then
        local petPos = getRelativePetPos(pos)
        posTable[petPos] = petId
      end
      if mainHeroId == roleId then
        mainRolePos = pos
      end
    end
  end
  if mainRolePos == nil then
    posTable = {}
    mainRolePos = 3
    posTable[mainRolePos] = mainHeroId
    local mainHero = g_LocalPlayer:getMainHero()
    local petId = mainHero:getProperty(PROPERTY_PETID)
    if petId ~= nil and petId ~= 0 then
      local petPos = getRelativePetPos(mainRolePos)
      posTable[petPos] = petId
    end
  end
  if mainRolePos and fbWarID ~= nil then
    local playerId = g_LocalPlayer:getPlayerId()
    StartOneSingleWar(warID, warType, warTypeData, playerId, fbWarID, posTable)
  end
end
function JudgeIsInWar()
  if g_WarScene == nil then
    return false
  end
  if g_WarScene:getIsWatching() then
    return false
  end
  if g_WarScene:getIsReview() then
    return false
  end
  return true
end
function StartWarWithBaseInfo(warID, warType, baseWarInfo, attackList, defendList, warTime, chasing, watchPlayerId)
  print("--->>>StartWarWithBaseInfo")
  g_MemoryDetect:DetectRelease()
  ShowCutScreenAni()
  if g_WarScene ~= nil then
    print("--->>关闭旧的战场")
    g_WarScene:CloseCurrWarScene()
    g_WarScene = nil
  end
  g_WarScene = warScene.new(warID, warType, baseWarInfo, attackList, defendList, warTime, chasing, false, watchPlayerId)
  getCurSceneView():addSubView({
    subView = g_WarScene,
    zOrder = MainUISceneZOrder.warScene
  })
  g_WarScene:setWarBaseInfo(baseWarInfo, warTime, chasing, watchPlayerId)
  if CMainUIScene.Ins then
    if g_LocalPlayer:getNormalTeamer() == true then
      CMainUIScene.Ins:reOrderAllViewWhenEnterWar()
    elseif g_WarScene:getIsWatching() == true then
      CMainUIScene.Ins:reOrderAllViewWhenEnterWar()
    elseif warType == WARTYPE_GuaJi then
      CMainUIScene.Ins:reOrderAllViewWhenEnterWar()
    else
      CMainUIScene.Ins:closeSomePopDlgWhenEnterWar()
    end
    CMainUIScene.Ins:updateSubViewsCoverFlags()
  end
end
function StartWarWithBaseInfo_Review(warInfo)
  print("--->>>StartWarWithBaseInfo_Review")
  g_MemoryDetect:DetectRelease()
  ShowCutScreenAni()
  if g_WarScene ~= nil then
    g_WarScene:CloseCurrWarScene()
    g_WarScene = nil
  end
  local warID = warInfo.i_w
  local warType = warInfo.baseData.warType or WARTYPE_BIWU
  local attackList = warInfo.attackList
  local defendList = warInfo.defendList
  local baseWarInfo = warInfo.baseData
  local warTime = warInfo.time
  local watchPlayerId
  g_WarScene = warScene.new(warID, warType, baseWarInfo, attackList, defendList, warTime, false, true, watchPlayerId)
  getCurSceneView():addSubView({
    subView = g_WarScene,
    zOrder = MainUISceneZOrder.warScene
  })
  g_WarScene:setWarBaseInfo(baseWarInfo, warTime, chasing, watchPlayerId)
  if CMainUIScene.Ins then
    CMainUIScene.Ins:closeSomePopDlgWhenEnterWar()
    CMainUIScene.Ins:updateSubViewsCoverFlags()
  end
end
function RevertWarWithLocalData(warInfo)
  print("--->>> RevertWarWithLocalData")
  g_MemoryDetect:DetectRelease()
  if g_WarScene ~= nil then
    g_WarScene:CloseCurrWarScene()
    g_WarScene = nil
  end
  local chasing = true
  local historyRdCnt = 0
  if warInfo.WarSeq ~= nil then
    historyRdCnt = #warInfo.WarSeq
  end
  local warID = warInfo.warID
  local warType = warInfo.warType
  local attackList = warInfo.attackList
  local defendList = warInfo.defendList
  local baseWarInfo = warInfo.BaseInfo
  baseWarInfo.historyRdCnt = historyRdCnt
  local warTime = warInfo.warTime
  local watchPlayerId = warInfo.watchPlayerId
  g_WarScene = warScene.new(warID, warType, baseWarInfo, attackList, defendList, warTime, chasing, false, watchPlayerId)
  getCurSceneView():addSubView({
    subView = g_WarScene,
    zOrder = MainUISceneZOrder.warScene
  })
  g_WarScene:setWarBaseInfo(baseWarInfo, warTime, chasing, watchPlayerId)
  if CMainUIScene.Ins then
    if g_LocalPlayer:getNormalTeamer() == true then
      CMainUIScene.Ins:reOrderAllViewWhenEnterWar()
    elseif g_WarScene:getIsWatching() == true then
      CMainUIScene.Ins:reOrderAllViewWhenEnterWar()
    elseif warType == WARTYPE_GuaJi then
      CMainUIScene.Ins:reOrderAllViewWhenEnterWar()
    else
      CMainUIScene.Ins:closeSomePopDlgWhenEnterWar()
    end
    CMainUIScene.Ins:updateSubViewsCoverFlags()
  end
  if warInfo.WarSeq ~= nil then
    for round, data in ipairs(warInfo.WarSeq) do
      endWarData = data.endWarData
      warSeqList = data.warSeqList
      warTime = data.warTime
      setRoundWarSeqList(warID, round, warSeqList, endWarData, warTime, chasing)
    end
    if warInfo.WarResult ~= nil then
      local resultData = warInfo.WarResult
      if resultData == Define_LoseData then
        SetWarFailed_Server(warID)
      elseif resultData == Define_DaPingData then
        SetWarDaPing_Server(warID)
      else
        SetWarResultData_Server(warID, resultData)
      end
    end
  end
  ShowCutScreenAni()
end
function setRoundWarSeqList(warId, round, warSeqList, endWarData, warTime, chasing)
  print("--->>>setRoundWarSeqList", warId, round, chasing)
  if g_WarScene then
    g_WarScene:setRoundWarSeqList(warId, round, warSeqList, endWarData, warTime, chasing)
  end
end
function setStartOneRound(warId, round, opData)
  print("--->>>setStartOneRound", warId, round, opData)
  if g_WarScene then
    g_WarScene:setStartOneRound(warId, round, opData)
  end
end
function setWarRoleState(warId, pos, state)
  print("--->>>setWarRoleState", warId, pos, state)
  if g_WarScene then
    g_WarScene:setWarRoleState(warId, pos, state)
  end
end
function OnOnePlayerEnterWatchWar(warID, watcherData)
  if g_WarScene then
    g_WarScene:createWatcher(warID, watcherData)
  end
end
function OnOnePlayerQuitWatchWar(warID, watcherId)
  if g_WarScene then
    g_WarScene:deleteWatcher(warID, watcherId)
  end
end
function QuitWarSceneAndBackToPreScene()
  if g_WarScene then
    local warId = g_WarScene:getWarID()
    local warType = g_WarScene:getWarType()
    local isWatch = g_WarScene:getIsWatching()
    local isReview = g_WarScene:getIsReview()
    local warResult = g_WarScene.m_WarResult
    g_WarScene:QuitWarScene()
    g_WarScene = nil
    SendMessage(MsgID_Scene_War_Exit, warId, warType, isWatch, isReview, warResult)
    g_MemoryDetect:DetectRelease()
  end
end
function setMainRoleHp(hp, maxHp)
  print("--->>>setMainRoleHp")
  if g_WarScene and g_WarScene.m_WaruiObj then
    g_WarScene.m_WaruiObj:SetHPBar(hp, maxHp)
  end
end
function setMainRoleMp(mp, maxMp)
  print("--->>>setMainRoleMp")
  if g_WarScene and g_WarScene.m_WaruiObj then
    g_WarScene.m_WaruiObj:SetMPBar(mp, maxMp)
  end
end
function setMainPetHp(hp, maxHp)
  print("--->>>setMainPetHp")
  if g_WarScene and g_WarScene.m_WaruiObj then
    g_WarScene.m_WaruiObj:SetPetHPBar(hp, maxHp)
  end
end
function setMainPetMp(mp, maxMp)
  print("--->>>setMainPetMp")
  if g_WarScene and g_WarScene.m_WaruiObj then
    g_WarScene.m_WaruiObj:SetPetMPBar(mp, maxMp)
  end
end
function SubmitWarResult(warId, starNum, onlyPlayerWarPet, onlyPlayerWarSkillPDict, onlyPlayerPetClose, warUseTime)
  if g_WarScene then
    g_WarScene:SubmitWarResult(warId, starNum, onlyPlayerWarPet, onlyPlayerWarSkillPDict, onlyPlayerPetClose, warUseTime)
  end
end
function SetWarResultData_Server(warID, warResultData)
  if g_WarScene then
    g_WarScene:SetWarResultData_Server(warID, warResultData)
  end
end
function SetWarFailed_Server(warID)
  if g_WarScene then
    g_WarScene:SetWarFailed_Server(warID)
  end
end
function SetWarDaPing_Server(warID)
  if g_WarScene then
    g_WarScene:SetWarDaPing_Server(warID)
  end
end
local warScene = class("warScene", CcsSubView)
function warScene:ctor(warID, warType, baseWarInfo, attackList, defendList, warTime, chasing, isReview, watchPlayerId)
  warScene.super.ctor(self, "views/war_scene.json")
  self.m_AttackPlayerList = attackList
  self.m_DefendPlayerList = defendList
  if watchPlayerId ~= nil then
    self.m_LocalTeamFlag = TEAM_ATTACK
    for _, tempPlayerId in pairs(defendList) do
      if tempPlayerId == watchPlayerId then
        self.m_LocalTeamFlag = TEAM_DEFEND
        break
      end
    end
  else
    self.m_LocalTeamFlag = TEAM_ATTACK
    local myPlayerId = g_LocalPlayer:getPlayerId()
    for _, tempPlayerId in pairs(defendList) do
      if tempPlayerId == myPlayerId then
        self.m_LocalTeamFlag = TEAM_DEFEND
        break
      end
    end
  end
  self.m_IsWatching = false
  if watchPlayerId ~= nil then
    self.m_IsWatching = true
    self.m_IsWatchPlayerId = watchPlayerId
  end
  self.m_IsReview = isReview
  self.m_WarResult = WARRESULT_NONE
  self.m_ResultStars = 0
  self.m_WarRoleObj = {}
  self.m_WarRoleObjBak = {}
  self.m_DirtyObjList = {}
  self.m_WatcherObj = {}
  self.m_WatcherData = {}
  self.m_MainHeroPos = nil
  self.m_IsShowSkillBackground = false
  self.m_ShowEnemyHpMp = false
  self.m_HasBeenClosed = false
  self.m_MaxWatcherNum = 7
  self.m_HasInWarPetList = {}
  self.m_WarDrugList = {}
  self.m_InitWarPetList = {}
  self.m_MaxPetNum = 0
  self.m_InitMainHeroSkillList = {}
  self.m_InitHeroCatchPetLvList = {}
  self.m_InitHuoDongData = {}
  self.m_LocalOpData = {}
  self.m_WarDataCache = {}
  self.m_RoleNode = Widget:create()
  self.m_UINode:addChild(self.m_RoleNode, DefineZOrder_Role)
  self.m_AniNode = Widget:create()
  self.m_UINode:addChild(self.m_AniNode, DefineZOrder_Ani)
  self.m_AniNode_Bottom = Widget:create()
  self.m_UINode:addChild(self.m_AniNode_Bottom, DefineZOrder_Ani_Bottom)
  self:InitXYByAllPos()
  self.m_PauseAIRound = nil
  self.m_PauseAISetRoleRound = {}
  self.m_WaitSubmitWarResult = nil
  self:ListenMessage(MsgID_WarScene)
  self:ListenMessage(MsgID_ReConnect)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_MapScene)
  seqAnalyze.extend(self)
  seqAnimation.extend(self)
  warchase.extend(self)
  self.m_UpdateHandler = scheduler.scheduleUpdateGlobal(handler(self, self.update))
  local p1 = self:getRoleXYByPos(105)
  local p2 = self:getRoleXYByPos(10105)
  local p4 = self:getRoleXYByPos(10102)
  self.m_SkillAniPos = ccp(p1.x, (p1.y + p2.y) / 2)
  self.m_SkillAniPos_Enemy = ccp(p4.x, self.m_SkillAniPos.y)
  self.m_UINode:ignoreContentAdaptWithSize(false)
  self.m_UINode:setSize(CCSize(display.width, display.height))
end
function warScene:QuitWarScene()
  if self:getIsWatching() then
    netsend.netteamwar.quitWatchWar(self:getWarID())
  end
  self.m_HasBeenClosed = true
  self:CloseSelf()
  soundManager.playSceneMusic()
  if CMainUIScene.Ins then
    if g_FubenHandler ~= nil then
      CMainUIScene.Ins:reOrderAllViewWhenEndWarEnterFuben()
    end
    CMainUIScene.Ins:updateSubViewsCoverFlags()
  end
  if self.m_WarType == WARTYPE_BIWU then
    SendMessage(MsgID_Pvp_WarCompleted)
  end
end
function warScene:CloseCurrWarScene()
  if self:getIsWatching() then
    netsend.netteamwar.quitWatchWar(self:getWarID())
  end
  self.m_HasBeenClosed = true
  self:CloseSelf()
  if CMainUIScene.Ins then
    if g_FubenHandler ~= nil then
      CMainUIScene.Ins:reOrderAllViewWhenEndWarEnterFuben()
    end
    CMainUIScene.Ins:updateSubViewsCoverFlags()
  end
end
function warScene:getIsReview()
  return self.m_IsReview
end
function warScene:getIsWatching()
  return self.m_IsWatching
end
function warScene:getWatchPlayerId()
  return self.m_IsWatchPlayerId
end
function warScene:getMyRoleHpMpData(roleId)
  if self:getIsReview() then
    return nil, nil, nil, nil
  elseif self:getIsWatching() then
    return nil, nil, nil, nil
  end
  for _, role in pairs(self.m_WarRoleObj) do
    if role ~= nil then
      local roleData = role:getShowData() or {}
      if roleId == roleData.objId and g_LocalPlayer:getPlayerId() == roleData.playerId then
        return roleData.hp, roleData.maxHp, roleData.mp, roleData.maxMp
      end
    end
  end
  return nil, nil, nil, nil
end
function warScene:getMainHeroAndPetDataAfterCreateWarUI()
  print("@@getMainHeroAndPetDataAfterCreateWarUI")
  local mainHeroShowData, mainPetShowData
  if self.m_MainHeroPos then
    local mainHero = self.m_WarRoleObj[self.m_MainHeroPos]
    if mainHero ~= nil then
      mainHeroShowData = mainHero:getShowData()
    end
    local mainPet = self.m_WarRoleObj[self.m_MainHeroPos + DefineRelativePetAddPos]
    if mainPet ~= nil then
      mainPetShowData = mainPet:getShowData()
    end
  end
  return mainHeroShowData, mainPetShowData
end
function warScene:createWarUI()
  print("@@createWarUI")
  if self.m_IsWatching == true then
    self.m_WaruiObj = warui_watch.new(self)
    self.m_WaruiObj:addTo(self.m_UINode)
  elseif self.m_IsReview then
    self.m_WaruiObj = warui_replay.new(self)
    self.m_WaruiObj:addTo(self.m_UINode)
  else
    self.m_WaruiObj = createNewWarUI()
    self.m_WaruiObj:addTo(self.m_UINode)
    self.m_WaruiObj:ReloadWarUi(self)
  end
  local talkID = self:getInitTalkID()
  if g_TeamMgr:getLocalPlayerTeamId() ~= 0 and g_TeamMgr:getPlayerTeamState() == TEAMSTATE_FOLLOW then
    talkID = nil
  end
  if self.m_IsWatching ~= true and self.m_ChasingFlag ~= true and not self.m_IsReview and talkID ~= nil then
    getCurSceneView():ShowTalkView(talkID, function()
      if self.m_HasBeenClosed == false then
        self:createFightStartAni()
      end
    end)
  else
    self:createFightStartAni()
  end
  if self.m_ChasingFlag ~= true and not self.m_IsReview then
    for _, role in pairs(self.m_WarRoleObj) do
      role:SetDisplayingFlag(false)
    end
  end
end
function warScene:createFightStartAni()
  if self.m_ChasingFlag then
    self:analyzeWarBeginSeqList()
    self.m_WaruiObj:InitShow()
  elseif self.m_CurrRound > 0 then
    print("---->> 如果执行到这里说明，对话回调时战斗已经开始了，所以不用在播放开始的动画了")
    self.m_WaruiObj:InitShow()
  else
    self.m_TempSwallowLayer = CreateFullSwallowLayer(false)
    local act1 = CCDelayTime:create(0.3)
    local act2 = CCCallFunc:create(function()
      self:_createFightStartAni()
    end)
    local act3 = CCDelayTime:create(2)
    local act4 = CCCallFunc:create(function()
      netsend.netpvp.watchBWCHistoryRoundData(self:getWarID(), 1)
    end)
    if self:getIsReview() then
      self:runAction(transition.sequence({
        act1,
        act2,
        act3,
        act4
      }))
    else
      self:runAction(transition.sequence({act1, act2}))
    end
  end
end
function warScene:_createFightStartAni()
  local pic_fight_bg = display.newSprite("views/warui/pic_fight_bg.png")
  self:addNode(pic_fight_bg, DefineZOrder_Ani)
  local ex, ey = display.width / 2 + 60, display.height / 2 + 15
  local sx, sy = ex + 300, ey
  pic_fight_bg:setPosition(sx, sy)
  local dt = 0.1
  local temp = {}
  for index, info in ipairs({
    {15, 60},
    {83, 35},
    {172, 58},
    {248, 48}
  }) do
    local ex, ey = info[1], info[2]
    local sx, sy = ex, ey + 240
    local pic_fight = display.newSprite(string.format("views/warui/pic_fight_%d.png", index))
    pic_fight_bg:addChild(pic_fight, 1)
    pic_fight:setPosition(sx, sy)
    pic_fight:setVisible(false)
    pic_fight:runAction(transition.sequence({
      CCDelayTime:create(dt + (index - 1) * 0.05),
      CCShow:create(),
      CCMoveTo:create(0.07, ccp(ex, ey))
    }))
    temp[#temp + 1] = pic_fight
  end
  pic_fight_bg:runAction(transition.sequence({
    CCMoveTo:create(dt, ccp(ex, ey)),
    CCDelayTime:create(0.8),
    CCCallFunc:create(function()
      pic_fight_bg:runAction(CCFadeOut:create(dt))
      for _, obj in pairs(temp) do
        obj:runAction(CCFadeOut:create(dt))
      end
    end),
    CCMoveBy:create(dt, ccp(-display.width / 2 - 300, 0)),
    CCCallFunc:create(function()
      self:analyzeWarBeginSeqList()
      self.m_WaruiObj:InitShow()
      self.m_WaruiObj:StartOneRoundFightSetting(1)
      if self.m_TempSwallowLayer then
        self.m_TempSwallowLayer:removeFromParentAndCleanup(true)
        self.m_TempSwallowLayer = nil
      end
      pic_fight_bg:removeFromParentAndCleanup(true)
    end)
  }))
end
function warScene:getWarID()
  return self.m_WarID
end
function warScene:getWarType()
  return self.m_WarType
end
function warScene:getSingleWarFlag()
  return self.m_SingleWarFlag
end
function warScene:getResultStars()
  return self.m_ResultStars
end
function warScene:getInitTalkID()
  local paramTable = self.m_WarTypeData.paramTable
  if paramTable and type(paramTable) == "table" then
    return paramTable.talkID
  end
  return nil
end
function warScene:getCompleteTalkID()
  local paramTable = self.m_WarTypeData.paramTable
  if paramTable and type(paramTable) == "table" then
    return paramTable.warCompleteTalkId
  end
  return nil
end
function warScene:InitWarScene()
  local mapName = "pic_warbg_1.jpg"
  if self.m_WarType == WARTYPE_FUBEN then
    local mapId = data_getCatchGotoMapId(self.m_WarTypeData.mapID, self.m_WarTypeData.catchID)
    local mapNum = data_getSceneWarMap(mapId)
    mapName = string.format("pic_warbg_%d.jpg", mapNum)
  elseif self.m_WarType == WARTYPE_GuaJi then
    local mapId = g_MapMgr:getCurMapId() or 1
    if self.m_WarFightID then
      print("warScene:--->>> 挂机地图根据战斗id找地图id", self.m_WarFightID)
      local temp = data_getGuajiMapIdByFightId(self.m_WarFightID)
      if temp ~= nil then
        mapId = temp
      end
    else
      print("warScene:--->>> 挂机地图没有战斗id,用当前场景id")
    end
    local mapNum = data_getSceneWarMap(mapId)
    mapName = string.format("pic_warbg_%d.jpg", mapNum)
  elseif self.m_WarType == WARTYPE_BIWU or self.m_WarType == WARTYPE_QIECUO or self.m_WarType == WARTYPE_LEITAI or self.m_WarType == WARTYPE_YIZHANDAODI_HUODONG or self.m_WarType == WARTYPE_XueZhanShaChang or self.m_WarType == WARTYPE_HUANGGONG then
    mapName = "pic_warbg_pvp.jpg"
  elseif self.m_WarType == WARTYPE_BpWAR then
    mapName = "pic_warbg_13.jpg"
  else
    local mapId = g_MapMgr:getCurMapId() or 1
    print("warScene:--->>> InitWarScene mapId", mapId, g_MapMgr:getCurMapId())
    local mapNum = data_getSceneWarMap(mapId)
    mapName = string.format("pic_warbg_%d.jpg", mapNum)
  end
  setDefaultAlphaPixelFormat(PixelFormat_WarBg)
  self.m_WarBg = display.newSprite(string.format("xiyou/pic/%s", mapName))
  resetDefaultAlphaPixelFormat()
  self.m_WarBg:setAnchorPoint(ccp(0, 0))
  self:addNode(self.m_WarBg, DefineZOrder_Bg)
  local size = self.m_WarBg:getContentSize()
  self.m_WarBg:setPosition((display.width - size.width) / 2, (display.height - size.height) / 2)
  local blackBgPath = "xiyou/pic/pic_war_skill_black.png"
  addDynamicLoadTexture(blackBgPath, function(handlerName, texture)
    if self.m_WarScene ~= nil and self.m_WarScene.m_HasBeenClosed ~= true and self.m_IsDirty ~= true and self.addNode ~= nil then
      self:createBlackBg()
    end
  end, {})
  if self.m_WarType == WARTYPE_FUBEN then
    g_FbInterface.CloseFueben()
  elseif self.m_WarType == WARTYPE_CangbaotuWAR then
    g_FbInterface.CloseFueben()
  end
  if self.m_WarType == WARTYPE_BIWU or self.m_WarType == WARTYPE_QIECUO or self.m_WarType == WARTYPE_TestDuoRen or self.m_WarType == WARTYPE_LEITAI then
    soundManager.playBattleMusic_PVP()
  else
    soundManager.playBattleMusic_PVE()
  end
  if not self.m_IsReview then
    SendMessage(MsgID_Scene_War_Enter)
  end
end
function warScene:createBlackBg()
  if self.m_SkillBlackBg ~= nil then
    return
  end
  setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  self.m_SkillBlackBg = display.newSprite("xiyou/pic/pic_war_skill_black.png")
  self.m_SkillBlackBg:setAnchorPoint(ccp(0, 0))
  self:addNode(self.m_SkillBlackBg, DefineZOrder_Bg)
  resetDefaultAlphaPixelFormat()
  local size = self.m_SkillBlackBg:getContentSize()
  self.m_SkillBlackBg:setPosition((display.width - size.width) / 2, (display.height - size.height) / 2)
  self.m_SkillBlackBg:setVisible(false)
end
function warScene:showSkillBackground()
  if self.m_IsShowSkillBackground then
    return
  end
  self.m_IsShowSkillBackground = true
  if self.m_SkillBlackBg == nil then
    self:createBlackBg()
  end
  local act1 = CCShow:create()
  local act2 = CCFadeIn:create(0.5)
  self.m_SkillBlackBg:stopAllActions()
  self.m_SkillBlackBg:runAction(transition.sequence({act1, act2}))
end
function warScene:hideSkillBackground()
  if not self.m_IsShowSkillBackground then
    return false
  end
  self.m_IsShowSkillBackground = false
  if self.m_SkillBlackBg == nil then
    self:createBlackBg()
  end
  local act1 = CCFadeOut:create(0.5)
  local act2 = CCHide:create()
  self.m_SkillBlackBg:stopAllActions()
  self.m_SkillBlackBg:runAction(transition.sequence({act1, act2}))
  return true
end
function warScene:hideAllRoles()
  self.m_RoleNode:setVisible(false)
end
function warScene:setRound(round)
  if self.m_WaruiObj then
    self.m_WaruiObj:SetRoundNum(round)
  end
end
function warScene:StartRunAction()
  print("@@StartRunAction")
  if self.m_WaruiObj then
    self.m_WaruiObj:UIStartRunAction()
  end
  for _, role in pairs(self.m_WarRoleObj) do
    role:SetDisplayingFlag(true)
  end
end
function warScene:getMainHeroPos()
  return self.m_MainHeroPos
end
function warScene:createHero(pos, heroData)
  self:deleteRoleViewAtPos(pos)
  local hero = CHeroView.new(pos, heroData, self)
  hero:setGuard()
  self.m_WarRoleObj[pos] = hero
  local posInfo = self:getXYByPos(pos)
  local zOrder = 0
  if posInfo ~= nil then
    hero:setPosition(ccp(posInfo.x, posInfo.y))
    zOrder = -posInfo.y
  end
  self.m_RoleNode:addChild(hero, zOrder)
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero and mainHero:getObjId() == heroData.objId and g_LocalPlayer:getPlayerId() == heroData.playerId and not self.m_IsWatching then
    self.m_MainHeroPos = pos
    if self.m_WaruiObj and self.m_WaruiObj.updateHeadData then
      self.m_WaruiObj:updateHeadData()
    end
  end
end
function warScene:createPet(pos, petData)
  self:deleteRoleViewAtPos(pos)
  local pet = CPetView.new(pos, petData, self)
  pet:setGuard()
  self.m_WarRoleObj[pos] = pet
  if petData.playerId == g_LocalPlayer:getPlayerId() and self.m_HasInWarPetList[objId] ~= nil then
    self.m_HasInWarPetList[objId] = nil
  end
  local posInfo = self:getXYByPos(pos)
  local zOrder = 0
  if posInfo ~= nil then
    pet:setPosition(ccp(posInfo.x, posInfo.y))
    zOrder = -posInfo.y
  end
  self.m_RoleNode:addChild(pet, zOrder)
  if self.m_MainHeroPos == pos - DefineRelativePetAddPos and self.m_WaruiObj and self.m_WaruiObj.updateHeadData then
    self.m_WaruiObj:updateHeadData()
  end
  return pet
end
function warScene:createNewPet(pos, petData)
  pos = tonumber(pos)
  local pet = self:createPet(pos, petData)
  if self.m_MainHeroPos and pos == self.m_MainHeroPos + DefineRelativePetAddPos and self.m_WaruiObj and self.m_WaruiObj.SetDefaultSettingData then
    local petId = petData.objId
    local petObj = g_LocalPlayer:getObjById(petId)
    local opData = {}
    if petObj ~= nil then
      local autoData = petObj:getProperty(PROPERTY_WARAUTOSKILL) or 0
      if autoData == 0 then
        opData = {}
      elseif autoData == 10 then
        opData = {
          aiActionType = AI_ACTION_TYPE_NORMALATTACK,
          targetPos = 0,
          skillId = SKILLTYPE_NORMALATTACK
        }
      elseif autoData == 20 then
        opData = {aiActionType = AI_ACTION_TYPE_DEFEND}
      else
        local skillId = math.floor(autoData / 10)
        if 0 < petObj:getProficiency(skillId) then
          local caFlagNum = autoData % 10
          local caFlag = false
          if caFlagNum == 1 then
            caFlag = true
          end
          opData = {
            aiActionType = AI_ACTION_TYPE_USESKILL,
            targetPos = 0,
            skillId = skillId,
            caFlag = caFlag
          }
        else
          opData = {
            aiActionType = AI_ACTION_TYPE_NORMALATTACK,
            targetPos = 0,
            skillId = SKILLTYPE_NORMALATTACK
          }
        end
      end
    end
    self.m_WaruiObj:SetDefaultSettingData(pos, opData, true)
  end
  return pet
end
function warScene:petIsInWar(petID)
  for pos, roleObj in pairs(self.m_WarRoleObj) do
    local showData = roleObj:getShowData()
    local playerId = showData.playerId
    local objId = showData.objId
    if petID == objId and playerId == g_LocalPlayer:getPlayerId() then
      return true
    end
  end
  return false
end
function warScene:petIsDead(petID)
  for tempPetID, petData in pairs(self.m_HasInWarPetList) do
    if petID == tempPetID and petData.hp == 0 then
      return true
    end
  end
  return false
end
function warScene:petIsHasInWar(petID)
  for tempPetID, petData in pairs(self.m_HasInWarPetList) do
    if petID == tempPetID then
      return true
    end
  end
  return false
end
function warScene:getRealCurPetData(petID)
  for pos, roleObj in pairs(self.m_WarRoleObj) do
    local showData = roleObj:getShowData()
    local playerId = showData.playerId
    local objId = showData.objId
    if petID == objId and playerId == g_LocalPlayer:getPlayerId() then
      return {
        hp = showData.hp,
        mp = showData.mp,
        maxHp = showData.maxHp,
        maxMp = showData.maxMp
      }
    end
  end
  for tempPetID, petData in pairs(self.m_HasInWarPetList) do
    if petID == tempPetID then
      return {
        hp = petData.hp,
        mp = petData.mp,
        maxHp = petData.maxHp,
        maxMp = petData.maxMp
      }
    end
  end
  local petObj = g_LocalPlayer:getObjById(petID)
  if petObj == nil then
    return {
      hp = 0,
      maxHp = 0,
      mp = 0,
      maxMp = 0
    }
  else
    return {
      hp = petObj:getProperty(PROPERTY_HP),
      maxHp = petObj:getMaxProperty(PROPERTY_HP),
      mp = petObj:getProperty(PROPERTY_MP),
      maxMp = petObj:getMaxProperty(PROPERTY_MP)
    }
  end
end
function warScene:getRealCurHeroData(heroID)
  for pos, roleObj in pairs(self.m_WarRoleObj) do
    local showData = roleObj:getShowData()
    local playerId = showData.playerId
    local objId = showData.objId
    if heroID == objId and playerId == g_LocalPlayer:getPlayerId() then
      return {
        hp = showData.hp,
        mp = showData.mp,
        maxHp = showData.maxHp,
        maxMp = showData.maxMp
      }
    end
  end
  local heroObj = g_LocalPlayer:getObjById(heroID)
  if heroObj == nil then
    return {
      hp = 0,
      maxHp = 0,
      mp = 0,
      maxMp = 0
    }
  else
    return {
      hp = heroObj:getProperty(PROPERTY_HP),
      maxHp = heroObj:getMaxProperty(PROPERTY_HP),
      mp = heroObj:getProperty(PROPERTY_MP),
      maxMp = heroObj:getMaxProperty(PROPERTY_MP)
    }
  end
end
function warScene:getCatchPetSuccedHuoliValue(lTypeId)
  local needHl = _getCatchPetNeedHuoLi_Succeed(lTypeId, self.m_InitHuoDongData.event51 == 1)
  return needHl
end
function warScene:getCatchPetFailedHuoliValue(lTypeId)
  local needHl = _getCatchPetNeedHuoLi_Failed(lTypeId, self.m_InitHuoDongData.event51 == 1)
  return needHl
end
function warScene:roleCanCatchPetCheckNum()
  local maxPetNum = self.m_MaxPetNum
  local curPetIdList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  if maxPetNum <= #curPetIdList then
    return false
  end
  return true
end
function warScene:roleCanCatchPetCheckLifeSkill(pos, targetPos)
  local roleShowData = self:getRoleDataObjByPos(pos)
  if roleShowData == nil then
    return false
  end
  local petShowData = self:getRoleDataObjByPos(targetPos)
  if petShowData == nil then
    return false
  end
  local pId = roleShowData.playerId
  local lTypeId = data_getPetIdByShape(data_getRoleShape(petShowData.typeId))
  if data_getPetTypeIsGaoJiShouHu(lTypeId) then
    local cLv = self.m_InitHeroCatchPetLvList[pId] or 0
    if cLv < 0 then
      ShowNotifyTips("习得捉宠技能后，才能捕捉高级守护")
      return false
    end
  end
  return true
end
function warScene:roleCanCatchPetCheckHuoLi(targetPos)
  local petShowData = self:getRoleDataObjByPos(targetPos)
  if petShowData == nil then
    return false
  end
  local lTypeId = data_getPetIdByShape(data_getRoleShape(petShowData.typeId))
  local curHlValue = g_LocalPlayer:getHuoli()
  local needHl = _getCatchPetNeedHuoLi_Succeed(lTypeId, self.m_InitHuoDongData.event51 == 1)
  if curHlValue < needHl then
    return string.format("活力值不足%d，无法捕捉", needHl)
  end
  return true
end
function warScene:roleCanCatchPetCheckMp(pos, targetPos)
  local petShowData = self:getRoleDataObjByPos(targetPos)
  if petShowData == nil then
    return false
  end
  local roleShowData = self:getRoleDataObjByPos(pos)
  if roleShowData == nil then
    return false
  end
  local pId = roleShowData.playerId
  local cRate, cMp = data_getNpcCatchData(petShowData.typeId)
  local cLv = self.m_InitHeroCatchPetLvList[pId] or 0
  local needMp = (cMp + petShowData.lv) * (1 - math.pow(cLv, 0.7) / 100)
  if needMp > roleShowData.mp then
    return false
  end
  return true
end
function warScene:roleCanCatchPetCheckLV(pos, targetPos)
  local petShowData = self:getRoleDataObjByPos(targetPos)
  if petShowData == nil then
    return "目标不存在"
  end
  local roleShowData = self:getRoleDataObjByPos(pos)
  if roleShowData == nil then
    return "角色不存在"
  end
  local curZs = roleShowData.zs
  local curLv = roleShowData.lv
  local petTypeId = petShowData.typeId
  local petsid = data_getPetIdByShape(data_getRoleShape(petTypeId))
  local petData = data_Pet[petsid] or {}
  local openLv = petData.OPENLV or 0
  if curLv < openLv and curZs <= 0 then
    return string.format("%d级才能捕捉", openLv)
  end
  return true
end
function warScene:roleSkillIsYiWang(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return false
  end
  local roleShowData = warRole:getShowData()
  local roleId = roleShowData.objId
  if roleId == nil then
    return false
  end
  if self.m_LocalOpData[roleId] == nil then
    return false
  end
  if self.m_LocalOpData[roleId][skillID] == nil then
    return false
  end
  return self.m_LocalOpData[roleId][skillID].yw == 1
end
function warScene:roleSkillCanGetMarryTarget(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return true
  end
  local roleShowData = warRole:getShowData()
  local roleId = roleShowData.objId
  if roleId == nil then
    return true
  end
  if self.m_LocalOpData[roleId] == nil then
    return true
  end
  if self.m_LocalOpData[roleId][skillID] == nil then
    return true
  end
  if GetObjType(skillID) ~= LOGICTYPE_MARRYSKILL then
    return true
  end
  local noTarget = self.m_LocalOpData[roleId][skillID].jh or 0
  if noTarget == 0 then
    return true
  end
  return false
end
function warScene:roleSkillCanUseOfMinRound(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return true
  end
  local roleShowData = warRole:getShowData()
  local roleId = roleShowData.objId
  if roleId == nil then
    return true
  end
  if self.m_LocalOpData[roleId] == nil then
    return true
  end
  if self.m_LocalOpData[roleId][skillID] == nil then
    return true
  end
  local minRound = self.m_LocalOpData[roleId][skillID].mr or 0
  if minRound <= self.m_CurrRound then
    return true
  else
    return minRound
  end
end
function warScene:roleSkillMpEnough(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return false
  end
  local roleShowData = warRole:getShowData()
  local localObjData = self:getLocalRoleDataObjByPos(pos)
  if localObjData == nil then
    return false
  end
  local myPlayerId = g_LocalPlayer:getPlayerId()
  local myRoleId = localObjData:getObjId()
  local isPetFlag = true
  if myRoleId == g_LocalPlayer:getMainHeroId() then
    isPetFlag = false
  end
  if not isPetFlag then
    if self.m_InitMainHeroSkillList == nil then
      return false
    end
    local skillExp = self.m_InitMainHeroSkillList[skillID]
    if skillExp == nil or skillExp <= 0 then
      return false
    end
    if self.m_LocalOpData[myRoleId] == nil then
      return true
    end
    if self.m_LocalOpData[myRoleId][skillID] == nil then
      return true
    end
    local mpEnough = self.m_LocalOpData[myRoleId][skillID].mp or 0
    if mpEnough == 1 then
      return false
    else
      return true
    end
  else
    if self.m_InitWarPetList[myRoleId] == nil then
      return false
    end
    local stFlag = false
    local stList = self:roleStolenSkillList(pos)
    for _, tId in pairs(stList) do
      if tId == skillID then
        stFlag = true
        break
      end
    end
    if not stFlag then
      local skillExp = self.m_InitWarPetList[myRoleId][skillID]
      if skillExp == nil or skillExp <= 0 then
        return false
      end
    end
    if self.m_LocalOpData[myRoleId] == nil then
      return true
    end
    if self.m_LocalOpData[myRoleId][skillID] == nil then
      return true
    end
    local mpEnough = self.m_LocalOpData[myRoleId][skillID].mp or 0
    if mpEnough == 1 then
      return false
    else
      return true
    end
  end
  return true
end
function warScene:roleSkillHpEnough(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return false
  end
  local roleShowData = warRole:getShowData()
  local localObjData = self:getLocalRoleDataObjByPos(pos)
  if localObjData == nil then
    return false
  end
  local myPlayerId = g_LocalPlayer:getPlayerId()
  local myRoleId = localObjData:getObjId()
  local isPetFlag = true
  if myRoleId == g_LocalPlayer:getMainHeroId() then
    isPetFlag = false
  end
  if not isPetFlag then
    return true
  else
    if self.m_InitWarPetList[myRoleId] == nil then
      return false
    end
    local stFlag = false
    local stList = self:roleStolenSkillList(pos)
    for _, tId in pairs(stList) do
      if tId == skillID then
        stFlag = true
        break
      end
    end
    if not stFlag then
      local skillExp = self.m_InitWarPetList[myRoleId][skillID]
      if skillExp == nil or skillExp <= 0 then
        return false
      end
    end
    if self.m_LocalOpData[myRoleId] == nil then
      return true
    end
    if self.m_LocalOpData[myRoleId][skillID] == nil then
      return true
    end
    local hpEnough = self.m_LocalOpData[myRoleId][skillID].hp or 0
    if hpEnough == 1 then
      return false
    else
      return true
    end
  end
  return true
end
function warScene:roleSkillProEnough(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return true
  end
  local roleShowData = warRole:getShowData()
  local roleId = roleShowData.objId
  if roleId == nil then
    return true
  end
  if self.m_LocalOpData[roleId] == nil then
    return true
  end
  if self.m_LocalOpData[roleId][skillID] == nil then
    return true
  end
  local proNum = self.m_LocalOpData[roleId][skillID].pro or 0
  if proNum == 0 then
    return true
  elseif proNum == SIXING_LACK_LILIANG then
    return "ll"
  elseif proNum == SIXING_LACK_GENGU then
    return "gg"
  elseif proNum == SIXING_LACK_LINGXING then
    return "lx"
  elseif proNum == SIXING_LACK_MINJIE then
    return "mj"
  elseif proNum == WUXING_LACK_JIN then
    return "jin"
  elseif proNum == WUXING_LACK_MU then
    return "mu"
  elseif proNum == WUXING_LACK_SHUI then
    return "shui"
  elseif proNum == WUXING_LACK_HUO then
    return "huo"
  elseif proNum == WUXING_LACK_TU then
    return "tu"
  end
  return true
end
function warScene:roleSkillCDEnough(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return true
  end
  local roleShowData = warRole:getShowData()
  local roleId = roleShowData.objId
  if roleId == nil then
    return true
  end
  if self.m_LocalOpData[roleId] == nil then
    return true
  end
  if self.m_LocalOpData[roleId][skillID] == nil then
    return true
  end
  local cdNum = self.m_LocalOpData[roleId][skillID].cd or 0
  if cdNum == 0 then
    return true
  else
    return cdNum
  end
  return true
end
function warScene:roleSkillHasUse(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return false
  end
  local roleShowData = warRole:getShowData()
  local roleId = roleShowData.objId
  if roleId == nil then
    return false
  end
  if self.m_LocalOpData[roleId] == nil then
    return false
  end
  if self.m_LocalOpData[roleId][skillID] == nil then
    return false
  end
  local use = self.m_LocalOpData[roleId][skillID].u or 0
  if use == 0 then
    return false
  else
    return true
  end
  return false
end
function warScene:roleStolenSkillList(pos)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return {}
  end
  local roleShowData = warRole:getShowData()
  local roleId = roleShowData.objId
  if roleId == nil then
    return {}
  end
  if self.m_LocalOpData[roleId] == nil then
    return {}
  end
  local sList = {}
  for tempSID, tData in pairs(self.m_LocalOpData[roleId]) do
    if tData.st == nil or tData.st == 0 then
    else
      sList[#sList + 1] = tempSID
    end
  end
  return sList
end
function warScene:roleCanOpenSkill(pos, skillID)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return false
  end
  local roleShowData = warRole:getShowData()
  local localObjData = self:getLocalRoleDataObjByPos(pos)
  if localObjData == nil then
    return false
  end
  local myPlayerId = g_LocalPlayer:getPlayerId()
  local myRoleId = localObjData:getObjId()
  local isPetFlag = true
  if myRoleId == g_LocalPlayer:getMainHeroId() then
    isPetFlag = false
  end
  if not isPetFlag then
    if self.m_InitMainHeroSkillList == nil then
      return false
    end
    local skillExp = self.m_InitMainHeroSkillList[skillID]
    if skillExp == nil or skillExp <= 0 then
      return false
    end
    return true
  else
    if self.m_InitWarPetList[myRoleId] == nil then
      return false
    end
    local stList = self:roleStolenSkillList(pos)
    for _, tId in pairs(stList) do
      if tId == skillID then
        return true
      end
    end
    local skillExp = self.m_InitWarPetList[myRoleId][skillID]
    if skillExp == nil or skillExp <= 0 then
      return false
    end
    return true
  end
  return true
end
function warScene:getMarryObjWarPos(pos)
  return self.m_InitMarryPosList[pos]
end
function warScene:getPetIsHasSkill(pos)
  local warRole = self.m_WarRoleObj[pos]
  if warRole == nil then
    return false
  end
  local roleShowData = warRole:getShowData()
  local localObjData = self:getLocalRoleDataObjByPos(pos)
  if localObjData == nil then
    return false
  end
  local myPlayerId = g_LocalPlayer:getPlayerId()
  local myRoleId = localObjData:getObjId()
  local isPetFlag = true
  if myRoleId == g_LocalPlayer:getMainHeroId() then
    isPetFlag = false
  end
  if not isPetFlag then
    return false
  else
    if self.m_InitWarPetList[myRoleId] == nil then
      return false
    end
    for skillID, p in pairs(self.m_InitWarPetList[myRoleId]) do
      if p >= 0 then
        return true
      end
    end
  end
  local stList = self:roleStolenSkillList(pos)
  for _, tId in pairs(stList) do
    return true
  end
  return false
end
function warScene:getWarPosByRoleID(roleID)
  for _, pos in pairs({
    1,
    2,
    3,
    4,
    5,
    101,
    102,
    103,
    104,
    105,
    10001,
    10002,
    10003,
    10004,
    10005,
    10101,
    10102,
    10103,
    10104,
    10105
  }) do
    local roleObj = self.m_WarRoleObj[pos]
    if roleObj ~= nil then
      local showData = roleObj:getShowData()
      if showData.objId == roleID and showData.playerId == g_LocalPlayer:getPlayerId() then
        return pos
      end
    end
  end
  return nil
end
function warScene:createMonster(pos, monsterData)
  self:deleteRoleViewAtPos(pos)
  local monster = CMonsterView.new(pos, monsterData, self)
  monster:setGuard()
  self.m_WarRoleObj[pos] = monster
  local posInfo = self:getXYByPos(pos)
  local zOrder = 0
  if posInfo ~= nil then
    monster:setPosition(ccp(posInfo.x, posInfo.y))
    zOrder = -posInfo.y
  end
  self.m_RoleNode:addChild(monster, zOrder)
  return monster
end
function warScene:createNewMonster(pos, monsterData)
  pos = tonumber(pos)
  local monster = self:createMonster(pos, monsterData)
  return monster
end
function warScene:createWatcher(warId, info)
  if self.m_WarID ~= warId then
    return
  end
  local playerId = info.playerId
  if playerId == nil or self.m_WatcherData[playerId] ~= nil then
    return
  end
  self.m_WatcherData[playerId] = info
  self:createWatcherAtSomePos(playerId, info)
end
function warScene:createWatcherAtSomePos(playerId, info)
  local pos
  for p = 1, self.m_MaxWatcherNum do
    if self.m_WatcherObj[p] == nil then
      pos = p
      break
    end
  end
  if pos == nil then
    print("没有位置可以观战")
    return
  end
  self:createOneWatcherAtPos(pos, playerId, info)
end
function warScene:createOneWatcherAtPos(pos, playerId, info)
  local posObj = self:getNode(string.format("pos_watch_%d", pos))
  if posObj == nil then
    return
  end
  self:deleteWatcherAtPos(pos)
  info._isWatching = true
  local x, y = posObj:getPosition()
  local size = posObj:getContentSize()
  x = x + size.width / 2
  y = y + size.height / 2
  local watcher = CWatcherView.new(pos, playerId, info, self)
  local zOrder = -y
  self.m_RoleNode:addChild(watcher, zOrder)
  watcher:setPosition(ccp(x, y))
  self.m_WatcherObj[pos] = watcher
end
function warScene:deleteWatcher(warId, playerId)
  if self.m_WarID ~= warId then
    return
  end
  self.m_WatcherData[playerId] = nil
  local posBak
  for p = 1, self.m_MaxWatcherNum do
    local watcher = self.m_WatcherObj[p]
    if watcher and watcher:getPlayerId() == playerId then
      self:deleteWatcherAtPos(p)
      posBak = p
      break
    end
  end
  if posBak ~= nil then
    for playerId, info in pairs(self.m_WatcherData) do
      if info._isWatching ~= true then
        self:createOneWatcherAtPos(posBak, playerId, info)
        break
      end
    end
  end
end
function warScene:deleteWatcherAtPos(pos)
  local watcherObj = self.m_WatcherObj[pos]
  if watcherObj == nil then
    return
  end
  watcherObj:removeFromParent()
  self.m_WatcherObj[pos] = nil
end
function warScene:deleteRoleViewAtPos(pos)
  local dirtyObj = self.m_WarRoleObj[pos]
  if dirtyObj then
    dirtyObj:setRoleLeaveBattleNow()
  end
end
function warScene:deleteRoleViewAtPosWhenEscape(pos)
  local dirtyObj = self.m_WarRoleObj[pos]
  if dirtyObj then
    dirtyObj:setRoleEscape()
  end
end
function warScene:RoleViewAtPosRunAway(pos)
  local dirtyObj = self.m_WarRoleObj[pos]
  if dirtyObj then
    local showData = dirtyObj:getShowData()
    local playerId = showData.playerId
    if playerId == g_LocalPlayer:getPlayerId() and not self:getIsWatching() and self.m_IsReview ~= true then
      self.m_IsRunAway = true
    end
  end
  self:deleteRoleViewAtPosWhenEscape(pos)
end
function warScene:deleteRoleAtPos(pos)
  local dirtyObj = self.m_WarRoleObj[pos]
  if dirtyObj == nil then
    return
  end
  local showData = dirtyObj:getShowData()
  local playerId = showData.playerId
  local objId = showData.objId
  local hp = showData.hp
  local maxHp = showData.maxHp
  local mp = showData.mp
  local maxMp = showData.maxMp
  local typeId = showData.typeId
  if GetRoleObjType(typeId) == LOGICTYPE_PET and playerId == g_LocalPlayer:getPlayerId() then
    self.m_HasInWarPetList[objId] = {
      hp = hp,
      mp = mp,
      maxHp = maxHp,
      maxMp = maxMp
    }
  end
  self.m_DirtyObjList[#self.m_DirtyObjList + 1] = dirtyObj
  self.m_WarRoleObjBak[pos] = dirtyObj
  self.m_WarRoleObj[pos] = nil
end
function warScene:reliveRoleAtPos(pos, objId, obj)
  self.m_HasInWarPetList[objId] = nil
  self.m_WarRoleObj[pos] = obj
end
function warScene:getViewObjByPos(pos)
  return self.m_WarRoleObj[pos]
end
function warScene:getBakViewObjByPos(pos)
  return self.m_WarRoleObjBak[pos]
end
function warScene:ConvertWarPosOfDefend(pos)
  if self.m_LocalTeamFlag == TEAM_ATTACK then
    return pos
  else
    if pos > DefineDefendPosNumberBase then
      pos = pos - DefineDefendPosNumberBase
    else
      pos = pos + DefineDefendPosNumberBase
    end
    return pos
  end
end
function warScene:InitXYByAllPos()
  local offx = (display.width - 960) / 2
  local offy = (display.height - 640) / 2
  self.m_AllPosInfo = {}
  for _, pos in pairs({
    1,
    2,
    3,
    4,
    5,
    101,
    102,
    103,
    104,
    105,
    10001,
    10002,
    10003,
    10004,
    10005,
    10101,
    10102,
    10103,
    10104,
    10105
  }) do
    local p = self:ConvertWarPosOfDefend(pos)
    local posLayer = self:getNode(string.format("pos%d", p))
    if posLayer then
      local x, y = posLayer:getPosition()
      local size = posLayer:getContentSize()
      self.m_AllPosInfo[pos] = ccp(x + size.width / 2 + offx, y + size.height / 2 + offy)
      posLayer:setEnabled(false)
    end
  end
  for i = 1, self.m_MaxWatcherNum do
    local posObj = self:getNode(string.format("pos_watch_%d", i))
    if posObj then
      posObj:setEnabled(false)
      local x, y = posObj:getPosition()
      posObj:setPosition(ccp(x + offx, y + offy))
    end
  end
end
function warScene:getXYByPos(pos)
  local posInfo = self.m_AllPosInfo[pos]
  if posInfo then
    return ccp(posInfo.x, posInfo.y)
  else
    print("【warScene error】目标 @%d 不存在，无法对其进行技能或者普通攻击 !", pos)
    return ccp(0, 0)
  end
end
function warScene:getAttackXYByDirection(pos, shape)
  local roleObj = self.m_WarRoleObj[pos]
  if roleObj == nil then
    return self:getAttackXYByPos(pos)
  else
    local direction = roleObj:getDirection()
    local x, y = roleObj:getPosition()
    if direction == DIRECTIOIN_LEFTUP then
      if shape == SHAPEID_SHENLONG then
        x = x - 210
        y = y + 55
      else
        x = x - 90
        y = y + 50
      end
    elseif shape == SHAPEID_SHENLONG then
      x = x + 200
      y = y - 45
    else
      x = x + 90
      y = y - 50
    end
    return ccp(x, y)
  end
end
function warScene:getAttackXYByPos(pos)
  local xy = self:getRoleXYByPos(pos)
  if self:ConvertWarPosOfDefend(pos) < DefineDefendPosNumberBase then
    xy.x = xy.x - 100
    xy.y = xy.y + 40
  else
    xy.x = xy.x + 100
    xy.y = xy.y - 40
  end
  return ccp(xy.x, xy.y)
end
function warScene:getProtectXYByPos(pos)
  local xy = self:getRoleXYByPos(pos)
  if self:ConvertWarPosOfDefend(pos) < DefineDefendPosNumberBase then
    xy.x = xy.x - 35
    xy.y = xy.y + 14
  else
    xy.x = xy.x + 35
    xy.y = xy.y - 14
  end
  return ccp(xy.x, xy.y)
end
function warScene:getDaZhaoAniPos(pos, tobody)
  if tobody == Define_Tobody_GroupFront then
    if pos < DefineDefendPosNumberBase then
      return self:getAttackXYByPos(103)
    else
      return self:getAttackXYByPos(10103)
    end
  elseif tobody == Define_Tobody_BattleMiddle or tobody == Define_Tobody_BattleMiddle_Bottom then
    local p1 = self:getRoleXYByPos(103)
    local p2 = self:getRoleXYByPos(10103)
    return ccp((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
  elseif pos < DefineDefendPosNumberBase then
    local p1 = self:getRoleXYByPos(3)
    local p2 = self:getRoleXYByPos(103)
    return ccp((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
  else
    local p1 = self:getRoleXYByPos(10003)
    local p2 = self:getRoleXYByPos(10103)
    return ccp((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
  end
end
function warScene:getXuanRenAniOfTeam(team)
  if team == TEAM_ATTACK then
    local pos = self:getXYByPos(10003)
    local pos2 = self:getXYByPos(10103)
    return ccp((pos.x + pos2.x) / 2, (pos.y + pos2.y) / 2 + 310)
  else
    local pos = self:getXYByPos(3)
    local pos2 = self:getXYByPos(103)
    return ccp((pos.x + pos2.x) / 2, (pos.y + pos2.y) / 2 + 320)
  end
end
function warScene:getXuanRenAniOfPos(pos)
  local pos = self:getXYByPos(pos)
  return ccp(pos.x, pos.y + 320)
end
function warScene:getYiHuanAniOfTeam(team)
  if team == TEAM_ATTACK then
    local pos = self:getXYByPos(10003)
    local pos2 = self:getXYByPos(10103)
    return ccp((pos.x + pos2.x) / 2, (pos.y + pos2.y) / 2 + 180)
  else
    local pos = self:getXYByPos(3)
    local pos2 = self:getXYByPos(103)
    return ccp((pos.x + pos2.x) / 2, (pos.y + pos2.y) / 2 + 200)
  end
end
function warScene:getYiHuanAniOfPos(pos)
  local pos = self:getXYByPos(pos)
  return ccp(pos.x, pos.y + 180)
end
function warScene:getRoleXYByPos(pos)
  local roleObj = self.m_WarRoleObj[pos]
  if roleObj == nil then
    return self:getXYByPos(pos)
  else
    local x, y = roleObj:getPosition()
    return ccp(x, y)
  end
end
function warScene:getRoleViewByPos(pos)
  return self.m_WarRoleObj[pos]
end
function warScene:getRoleViewIsAliveByPos(pos)
  local roleView = self.m_WarRoleObj[pos]
  if roleView == nil then
    return false
  else
    return not roleView:isDead()
  end
end
function warScene:getLocalRoleDataObjByPos(pos)
  local roleView = self.m_WarRoleObj[pos]
  if roleView == nil then
    return nil
  end
  local showData = roleView:getShowData()
  local playerId = showData.playerId
  local objId = showData.objId
  local player = g_DataMgr:getPlayer(playerId)
  if player == nil then
    return nil
  end
  return player:getObjById(objId)
end
function warScene:getRoleDataObjByPos(pos)
  local roleView = self.m_WarRoleObj[pos]
  if roleView == nil then
    return nil
  end
  return roleView:getShowData()
end
function warScene:showRightDownSelect(flag, canSelectDeadPeople, extraParam)
  for _, pos in ipairs({
    1,
    2,
    3,
    4,
    5,
    101,
    102,
    103,
    104,
    105
  }) do
    local role = self.m_WarRoleObj[pos]
    if role ~= nil then
      role:showSelectCircle(flag, canSelectDeadPeople, extraParam)
    end
  end
end
function warScene:showLeftUpSelect(flag, canSelectDeadPeople, extraParam)
  for _, pos in ipairs({
    10001,
    10002,
    10003,
    10004,
    10005,
    10101,
    10102,
    10103,
    10104,
    10105
  }) do
    local role = self.m_WarRoleObj[pos]
    if role ~= nil then
      role:showSelectCircle(flag, canSelectDeadPeople, extraParam)
    end
  end
end
function warScene:showSelectPos(pos, flag, canSelectDeadPeople)
  local role = self.m_WarRoleObj[pos]
  if role ~= nil then
    role:showSelectCircle(flag, canSelectDeadPeople)
  end
end
function warScene:showMySelectArrow(movePos)
end
function warScene:delOneDrug(drugShapeId, usePos)
  if self.m_MainHeroPos == nil then
    return
  end
  if (usePos == self.m_MainHeroPos or usePos == self.m_MainHeroPos + DefineRelativePetAddPos) and self.m_WarDrugList[drugShapeId] ~= nil then
    self.m_WarDrugList[drugShapeId] = self.m_WarDrugList[drugShapeId] - 1
    if self.m_WarDrugList[drugShapeId] <= 0 then
      self.m_WarDrugList[drugShapeId] = nil
    end
  end
end
function warScene:getWarDrugList()
  return self.m_WarDrugList
end
function warScene:getInitWarPetList()
  return self.m_InitWarPetList
end
function warScene:getInitMainHeroSkillList()
  return self.m_InitMainHeroSkillList
end
function warScene:getLocalTeamFlag()
  return self.m_LocalTeamFlag
end
function warScene:readyToShowWarResult()
  print("--->>> readyToShowWarResults")
  if self:getIsWatching() then
    print("--->>> 观看的时候，直接结束。")
    local act1 = CCDelayTime:create(1)
    local act2 = CCCallFunc:create(function()
      local autoGoBackFlag = false
      if g_WarScene and g_WarScene:getIsWatching() then
        local wPId = g_WarScene:getWatchPlayerId()
        local teamId = g_TeamMgr:getLocalPlayerTeamId()
        local cPId = g_TeamMgr:getTeamCaptain(teamId)
        if wPId == cPId and wPId ~= nil and g_TeamMgr:getPlayerTeamState(g_LocalPlayer:getPlayerId()) == TEAMSTATE_LEAVE then
          autoGoBackFlag = true
        end
      end
      QuitWarSceneAndBackToPreScene()
      if autoGoBackFlag then
        g_TeamMgr:send_ComebackTeam()
      end
    end)
    self:runAction(transition.sequence({act1, act2}))
    return
  elseif self.m_IsReview then
    local act1 = CCDelayTime:create(1)
    local act2 = CCCallFunc:create(function()
      QuitWarSceneAndBackToPreScene()
    end)
    self:runAction(transition.sequence({act1, act2}))
    return
  else
    if self.m_WarDataCache.WarResult == nil then
      return
    end
    if self.m_WarResult == WARRESULT_ATTACK_WIN then
      if self.m_LocalTeamFlag == TEAM_ATTACK then
        self:ShowWarResult_Win(self.m_WarDataCache.WarResult)
      else
        self:ShowWarResult_Lose()
      end
    elseif self.m_WarResult == WARRESULT_ATTACK_LOSE then
      if self.m_LocalTeamFlag == TEAM_ATTACK then
        self:ShowWarResult_Lose()
      else
        self:ShowWarResult_Win(self.m_WarDataCache.WarResult)
      end
    elseif self.m_WarResult == WARRESULT_DaPing then
      if self.m_LocalTeamFlag == TEAM_ATTACK then
        self:ShowWarResult_Lose()
      else
        self:ShowWarResult_Win(self.m_WarDataCache.WarResult)
      end
    end
  end
end
function warScene:pauseWarAndShowWarResult()
  self:pauseWarAnalyze()
  self:readyToShowWarResult()
end
function warScene:setWarBaseInfo(warBaseInfo, warTime, chasing, watchPlayerId)
  self.m_WarDataCache.BaseInfo = DeepCopyTable(warBaseInfo)
  self.m_WarDataCache.warID = warBaseInfo.warID
  self.m_WarDataCache.warType = warBaseInfo.warType
  self.m_WarDataCache.attackList = self.m_AttackPlayerList
  self.m_WarDataCache.defendList = self.m_DefendPlayerList
  self.m_WarDataCache.warTime = warTime
  self.m_WarDataCache.watchPlayerId = watchPlayerId
  self.m_InitMarryPosList = {}
  if warBaseInfo.hdData ~= nil then
    self.m_InitHuoDongData = warBaseInfo.hdData
  end
  if warBaseInfo.pList ~= nil then
    local tempPList = ChangeTableKeyToNum(warBaseInfo.pList)
    self.m_InitWarPetList = tempPList[g_LocalPlayer:getPlayerId()] or {}
  end
  if warBaseInfo.mList ~= nil then
    local tempMList = ChangeTableKeyToNum(warBaseInfo.mList)
    self.m_InitMarryPosList = tempMList or {}
  end
  if warBaseInfo.nList ~= nil then
    local petNumLimitList = ChangeTableKeyToNum(warBaseInfo.nList)
    self.m_MaxPetNum = petNumLimitList[g_LocalPlayer:getPlayerId()] or 0
  end
  if warBaseInfo.sList ~= nil then
    local tempSList = ChangeTableKeyToNum(warBaseInfo.sList)
    self.m_InitMainHeroSkillList = tempSList[g_LocalPlayer:getPlayerId()] or {}
  end
  if warBaseInfo.cpList ~= nil then
    self.m_InitHeroCatchPetLvList = ChangeTableKeyToNum(warBaseInfo.cpList) or {}
  end
  self.m_WarID = warBaseInfo.warID
  self.m_WarType = warBaseInfo.warType
  self.m_SingleWarFlag = warBaseInfo.singleWarFlag
  self.m_WarTypeData = warBaseInfo.warTypeData
  self.m_ChasingFlag = chasing
  self.m_ChasingRound = warBaseInfo.historyRdCnt or 0
  self.m_ChasingTime = g_DataMgr:getServerTime() - warTime - 1
  self.m_WarBeginSeq = warBaseInfo.sq
  self.m_WarFightID = warBaseInfo.warFightID
  local rolesInfo = warBaseInfo.roles
  for pos, data in pairs(rolesInfo) do
    pos = tonumber(pos)
    local typeId = data.typeId
    local objType = GetRoleObjType(typeId)
    if objType == LOGICTYPE_HERO then
      self:createHero(pos, data)
    elseif objType == LOGICTYPE_PET then
      self:createPet(pos, data)
    elseif objType == LOGICTYPE_MONSTER then
      self:createMonster(pos, data)
    end
  end
  self.m_WarTypeData.paramTable = g_MissionMgr:getMissionParamForWarWithId(self.m_WarFightID)
  if self.m_WarType == WARTYPE_FUBEN then
    if self.m_WarTypeData.paramTable == nil then
      local param = g_MissionMgr:getMissionParamForWar(self.m_WarTypeData.mapID, self.m_WarTypeData.catchID, self.m_WarTypeData.isSuper)
      if param ~= nil then
        self.m_WarTypeData.paramTable = param
      end
    end
    local star = g_LocalPlayer:getCatchStars(self.m_WarTypeData.mapID, self.m_WarTypeData.catchID, self.m_WarTypeData.isSuper)
    if star == nil or star == 0 then
      self.m_WarTypeData.jumpToNextIfWin = true
    else
      self.m_WarTypeData.jumpToNextIfWin = false
    end
  end
  local drugList = g_LocalPlayer:GetItemTypeList(ITEM_LARGE_TYPE_DRUG)
  for _, drugObjId in pairs(drugList) do
    local drugObj = g_LocalPlayer:GetOneItem(drugObjId)
    if drugObj and 0 < drugObj:getProperty(ITEM_PRO_NUM) then
      local drugShapeId = drugObj:getTypeId()
      if self.m_WarDrugList[drugShapeId] == nil then
        self.m_WarDrugList[drugShapeId] = drugObj:getProperty(ITEM_PRO_NUM)
      else
        self.m_WarDrugList[drugShapeId] = self.m_WarDrugList[drugShapeId] + drugObj:getProperty(ITEM_PRO_NUM)
      end
    end
  end
  local drugList = g_LocalPlayer:GetItemTypeList(ITEM_LARGE_TYPE_LIFEITEM)
  for _, newDrugObjId in pairs(drugList) do
    local newDrugObj = g_LocalPlayer:GetOneItem(newDrugObjId)
    local drugType = newDrugObj:getTypeId()
    if data_getLifeSkillType(drugType) == IETM_DEF_LIFESKILL_DRUG and newDrugObj then
      local num = newDrugObj:getProperty(ITEM_PRO_NUM)
      if self.m_WarDrugList[drugType] == nil then
        self.m_WarDrugList[drugType] = num
      else
        self.m_WarDrugList[drugType] = self.m_WarDrugList[drugType] + num
      end
    end
  end
  self:InitWarScene()
  self:createWarUI()
  if warBaseInfo.xrA == 1 then
    self:createAttackXuanRenAni()
  end
  if warBaseInfo.xrD == 1 then
    self:createDefendXuanRenAni()
  end
  if warBaseInfo.yhA == 1 then
    self:createAttackYiHuanAni()
  end
  if warBaseInfo.yhD == 1 then
    self:createDefendYiHuanAni()
  end
  if warBaseInfo.sHpMp_att ~= nil then
    self:setShowEnenmyHpMp(TEAM_ATTACK, warBaseInfo.sHpMp_att)
  end
  if warBaseInfo.sHpMp_def ~= nil then
    self:setShowEnenmyHpMp(TEAM_DEFEND, warBaseInfo.sHpMp_def)
  end
  if self.m_ChasingFlag == true and 0 >= self.m_ChasingRound then
    self:startChasing()
  end
end
function warScene:setRoundWarSeqList(warId, round, warSeqList, endWarData, warTime, chasing)
  if warId ~= self.m_WarID then
    print("战斗ID对不上，直接无视", warId, self.m_WarID)
    return
  end
  local warSeq = self.m_WarDataCache.WarSeq
  if warSeq == nil then
    warSeq = {}
    self.m_WarDataCache.WarSeq = warSeq
  end
  warSeq[round] = {
    endWarData = endWarData,
    warSeqList = DeepCopyTable(warSeqList),
    warTime = warTime
  }
  print("setRoundWarSeqList的战斗结果", endWarData.warResult, self.m_LastRoundAnalyzeFinish)
  self.m_WarResult = endWarData.warResult
  self.m_ResultStars = endWarData.starNum
  if self.m_ChasingFlag == true and round > self.m_ChasingRound then
    print("===========>>>>> 如果追赶过程中来了新的回合数据，并且新的回合比当前要追赶的最大回合更大，则更新追赶最大回合数", round, self.m_ChasingRound)
    self.m_ChasingRound = round
  end
  if self.m_SingleWarFlag then
    self:analyzeRoundWarSeqList(round, warSeqList, warTime, chasing)
  elseif self:getIsReview() then
    self:analyzeRoundWarSeqList(round, warSeqList, warTime, chasing)
  else
    self:analyzeRoundWarSeqList(round, warSeqList, warTime, chasing)
  end
end
function warScene:setStartOneRound(warId, round, opData)
  print("@@setStartOneRound", warId, round, opData)
  if warId ~= self.m_WarID then
    return
  end
  self.m_LocalOpData = ChangeTableKeyToNum(opData) or {}
  for pId, pData in pairs(self.m_InitWarPetList) do
    if self.m_LocalOpData[pId] then
      for skillID, sData in pairs(self.m_LocalOpData[pId]) do
        if sData.p ~= nil and sData.p > 0 then
          self.m_InitWarPetList[pId][skillID] = sData.p
        end
      end
    end
  end
  self.m_WaruiObj:StartOneRoundFightSetting(round)
  for _, role in pairs(self.m_WarRoleObj) do
    role:SetDisplayingFlag(false)
  end
end
function warScene:setWarRoleState(warId, pos, state)
  print("@@setWarRoleState")
  if warId ~= self.m_WarID then
    return
  end
  local role = self.m_WarRoleObj[pos]
  if role ~= nil then
    role:SetStateInWar(state)
  end
end
function warScene:SetWarResultData_Server(warID, warResultData)
  if self.m_WarID == warID then
    self.m_WaitSubmitWarResult = nil
    self.m_WarDataCache.WarResult = DeepCopyTable(warResultData)
    if self.m_WarAnalyzeFinish then
      self:ShowWarResult_Win(warResultData)
    else
      print("收到服务器返回【战斗奖励】，表现未结束")
    end
  else
    print("---->>不是本场战斗的胜利结果", self.m_WarID, warID)
  end
end
function warScene:ShowWarResult_Win(warResultData, delay)
  local dt = 1
  if delay == false then
    dt = 0
  end
  local act1 = CCDelayTime:create(dt)
  local act2 = CCCallFunc:create(function()
    local talkID = self:getCompleteTalkID()
    if g_LocalPlayer:getNormalTeamer() == true then
      talkID = nil
    end
    if talkID ~= nil then
      getCurSceneView():ShowTalkView(talkID, function()
        if self.m_HasBeenClosed == false then
          self:ShowWarResult_Win_Do(warResultData)
        end
      end)
    else
      self:ShowWarResult_Win_Do(warResultData)
    end
  end)
  self:runAction(transition.sequence({act1, act2}))
  self.m_WaruiObj:EndWarUnShowWarUI()
end
function warScene:ShowWarResult_Win_Do(warResultData)
  if type(warResultData) ~= "table" then
    print("~~~异常,warResultData应该是一个字典")
    warResultData = {}
  end
  local itemData = warResultData.itemData
  local heroaddexp = warResultData.heroaddexp
  local heroinfo = warResultData.heroinfo
  local petaddexp = warResultData.petaddexp
  local petinfo = warResultData.petinfo
  local moneyaward = warResultData.moneyaward
  self.m_WarResultDlg = ShowWarResult_Win(self.m_WarID, itemData, heroaddexp, heroinfo, petaddexp, petinfo, moneyaward, self.m_WarType, self.m_WarTypeData)
  ShowAddBSDAfterWar(self.m_WarType)
end
function warScene:SetWarFailed_Server(warID)
  if self.m_WarID == warID then
    self.m_WaitSubmitWarResult = nil
    self.m_WarDataCache.WarResult = Define_LoseData
    if self.m_WarAnalyzeFinish then
      ShowWarResult_Lose(self.m_WarID, self.m_WarType)
      ShowAddBSDAfterWar(self.m_WarType)
    else
      print("收到服务器返回【战斗失败】，表现未结束")
    end
  else
    print("---->>不是本场战斗的失败结果", self.m_WarID, warID)
  end
end
function warScene:SetWarDaPing_Server(warID)
  if self.m_WarID == warID then
    self.m_WaitSubmitWarResult = nil
    self.m_WarDataCache.WarResult = Define_DaPingData
    if self.m_WarAnalyzeFinish then
      ShowWarResult_Lose(self.m_WarID, self.m_WarType)
      ShowAddBSDAfterWar(self.m_WarType)
    else
      print("收到服务器返回【战斗打平】，表现未结束")
    end
  else
    print("---->>不是本场战斗的打平结果", self.m_WarID, warID)
  end
end
function warScene:ShowWarResult_Lose(delay)
  if delay == false then
    self.m_WarResultDlg = ShowWarResult_Lose(self.m_WarID, self.m_WarType, self.m_WarTypeData)
    ShowAddBSDAfterWar(self.m_WarType)
  else
    local act1 = CCDelayTime:create(1)
    local act2 = CCCallFunc:create(function()
      self.m_WarResultDlg = ShowWarResult_Lose(self.m_WarID, self.m_WarType, self.m_WarTypeData)
      ShowAddBSDAfterWar(self.m_WarType)
    end)
    self:runAction(transition.sequence({act1, act2}))
  end
  self.m_WaruiObj:EndWarUnShowWarUI()
end
function warScene:SendOneRoundAnalyzeFinishToAI(warId, singleFlag, roundNum)
  if warId ~= self.m_WarID then
    return
  end
  print("--->>>SendOneRoundAnalyzeFinishToAI", warId, singleFlag, roundNum)
  if singleFlag == true then
    if g_NetConnectMgr:getIsDealingWithReconnect() then
      local playerId = g_LocalPlayer:getPlayerId()
      print("--->>>重连中,暂停执行本地战斗ai逻辑", warId, roundNum, playerId)
      self.m_PauseAIRound = {
        warId,
        roundNum,
        playerId
      }
    else
      local playerId = g_LocalPlayer:getPlayerId()
      AISetOnePlayerFinishPlayOneRound(warId, roundNum, playerId)
    end
  else
    if self.m_WaruiObj then
      self.m_WaruiObj:SetWaittextShow(true)
    end
    if self.m_IsWatching then
      self:setStartOneRound(warId, roundNum + 1)
    else
      netsend.netteamwar.oneRoundFinishPlay(warId, roundNum)
    end
  end
end
function warScene:SendActionToAI(warId, singleFlag, roundNum, playerId, roleId, pos, actionDict)
  if warId ~= self.m_WarID then
    return
  end
  printLog("warui", "SendActionToAI %d, %d, %d ", warId, roundNum, playerId)
  if singleFlag == true then
    if g_NetConnectMgr:getIsDealingWithReconnect() then
      print("--->>>重连中,暂停执行本地战斗ui设置逻辑", warId, roundNum, playerId, roleId, pos)
      self.m_PauseAISetRoleRound[#self.m_PauseAISetRoleRound + 1] = {
        warId,
        roundNum,
        playerId,
        roleId,
        pos,
        actionDict
      }
    else
      AISetOneRoleAction(warId, roundNum, playerId, roleId, pos, actionDict)
    end
  elseif self.m_IsWatching then
  else
    netsend.netteamwar.oneRoundAction(warId, playerId, roundNum, roleId, pos, actionDict)
  end
end
function warScene:SubmitWarResult(warId, starNum, onlyPlayerWarPet, onlyPlayerWarSkillPDict, onlyPlayerPetClose, warUseTime)
  if warId == self.m_WarID then
    self.m_WaitSubmitWarResult = {
      warId,
      starNum,
      onlyPlayerWarPet,
      onlyPlayerWarSkillPDict,
      onlyPlayerPetClose,
      warUseTime
    }
    netsend.netwar.submitWarResult(warId, starNum, onlyPlayerWarPet, onlyPlayerWarSkillPDict, onlyPlayerPetClose, warUseTime)
  end
end
function warScene:setShowEnenmyHpMp(team, flag)
  local mainHero = self.m_WarRoleObj[self.m_MainHeroPos]
  if mainHero == nil then
    return
  end
  local localTeam = mainHero:getTeam()
  if team == localTeam then
    self.m_ShowEnemyHpMp = flag == 1
    for _, roleObj in pairs(self.m_WarRoleObj) do
      roleObj:checkShowEnenmyHpMp()
    end
  end
end
function warScene:getShowEnemyHpMp()
  return self.m_ShowEnemyHpMp
end
function warScene:update(dt)
  for _, roleObj in pairs(self.m_WarRoleObj) do
    local x, y = roleObj:getPosition()
    if roleObj:isDead() then
      self.m_RoleNode:reorderChild(roleObj, -y - 20)
    else
      self.m_RoleNode:reorderChild(roleObj, -y)
    end
  end
end
function warScene:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_WarScene_HpChanged then
    self:displayAniAtPosOfHp(arg[1], arg[2], arg[3], arg[4])
  elseif msgSID == MsgID_WarScene_MpChanged then
    self:displayAniAtPosOfMp(arg[1], arg[2], arg[3], arg[4])
  elseif msgSID == MsgID_ReConnect_PingSuccess then
    if self.m_SingleWarFlag then
      print("warScene:--->>>单人战斗。后台回来能ping通服务器，本地继续战斗")
      self:checkContinueFight()
    else
      print("warScene:--->>>多人战斗。后台回来能ping通服务器，本地重启战斗")
      self:revertLocalWar()
    end
  elseif msgSID == MsgID_Connect_SendFinished then
    if self:getIsReview() then
      QuitWarSceneAndBackToPreScene()
      return
    end
    if self.m_SingleWarFlag then
      local udid = g_DataMgr:getLastLoginUDID()
      if udid == device.getOpenUDID() then
        print("warScene:--->>>单人战斗。重新自动登陆成功，并且没有被顶过号，继续未完成的战斗", udid, device.getOpenUDID())
        self:checkContinueFight()
      else
        print("warScene:--->>>单人战斗。重新自动登陆成功，被顶过号，关闭当前战场", udid, device.getOpenUDID())
        QuitWarSceneAndBackToPreScene()
      end
    else
      print("warScene:--->>>多人战斗。重新自动登陆成功")
      if self.m_IsDirtyFlag == true then
        print("warScene:--->>>多人战斗。重新自动登陆成功，关闭失效的战场")
        QuitWarSceneAndBackToPreScene()
      end
    end
  elseif msgSID == MsgID_ReConnect_Ready_ReLogin then
    if self:getIsReview() then
      QuitWarSceneAndBackToPreScene()
      return
    end
    if self.m_SingleWarFlag then
      print("warScene:--->>>单人战斗。准备自动重新登陆，不处理")
    else
      print("warScene:--->>>多人战斗。准备自动重新登陆，战场设置dirty标志位")
      self.m_IsDirtyFlag = true
    end
  elseif msgSID == MsgID_MapScene_AutoRoute then
  end
end
function warScene:checkContinueFight()
  if self.m_PauseAIRound ~= nil then
    local warId = self.m_PauseAIRound[1]
    local roundNum = self.m_PauseAIRound[2]
    local playerId = self.m_PauseAIRound[3]
    self.m_PauseAIRound = nil
    print("warScene:--->>>继续执行本地战斗ai逻辑", warId, roundNum, playerId)
    AISetOnePlayerFinishPlayOneRound(warId, roundNum, playerId)
  elseif #self.m_PauseAISetRoleRound > 0 then
    for _, pauseData in pairs(self.m_PauseAISetRoleRound) do
      local warId = pauseData[1]
      local roundNum = pauseData[2]
      local playerId = pauseData[3]
      local roleId = pauseData[4]
      local pos = pauseData[5]
      local actionDict = pauseData[6]
      AISetOneRoleAction(warId, roundNum, playerId, roleId, pos, actionDict)
      print("warScene:--->>>继续执行本地战斗UI设置逻辑", warId)
    end
    self.m_PauseAISetRoleRound = {}
  elseif self.m_WaitSubmitWarResult ~= nil then
    local warId = self.m_WaitSubmitWarResult[1]
    local starNum = self.m_WaitSubmitWarResult[2]
    local onlyPlayerWarPet = self.m_WaitSubmitWarResult[3]
    local onlyPlayerWarSkillPDict = self.m_WaitSubmitWarResult[4]
    local onlyPlayerPetClose = self.m_WaitSubmitWarResult[5]
    local warUseTime = self.m_WaitSubmitWarResult[6]
    self.m_WaitSubmitWarResult = nil
    print("warScene:--->>>重新提交尚未发送成功的结果", warId)
    self:SubmitWarResult(warId, starNum, onlyPlayerWarPet, onlyPlayerWarSkillPDict, onlyPlayerPetClose, warUseTime)
  end
end
function warScene:getWarDataCache()
  return self.m_WarDataCache
end
function warScene:ClearWarResult(obj)
  if self.m_WarResultDlg == obj then
    self.m_WarResultDlg = nil
  end
end
function warScene:Clear()
  print("warScene  clear  ")
  self.m_WaruiObj = nil
  if self.m_UpdateHandler then
    scheduler.unscheduleGlobal(self.m_UpdateHandler)
    self.m_UpdateHandler = nil
  end
  if g_WarScene == self then
    g_WarScene = nil
  end
  if self.m_TempSwallowLayer then
    self.m_TempSwallowLayer:removeFromParentAndCleanup(true)
    self.m_TempSwallowLayer = nil
  end
  if self.m_WarResultDlg then
    self.m_WarResultDlg:CloseSelf()
    self.m_WarResultDlg = nil
  end
end
return warScene

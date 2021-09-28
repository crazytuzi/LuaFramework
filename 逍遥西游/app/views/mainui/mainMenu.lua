CMainMenu = class("CMainMenu", CcsSubView)
g_CMainMenuHandler = nil
g_SocialityDlg = nil
g_FriendsDlg = nil
local BtnActionPos = 200
local BtnActionTime = 0.2
local BtnHideTime = 60
local NewBtnActionMoveTime = 0.8
local NewBtnActionFadeTime = 0.3
local NewBtnActionScaleTime = 1
local NewBtnActionCircleEff = 5
function CMainMenu:ctor()
  CMainMenu.super.ctor(self, "views/main_menu.json")
  local btnBatchListener = {
    btn_menu_pet = {
      listener = handler(self, self.OnBtn_Menu_Pet),
      variName = "btn_menu_pet",
      param = {2}
    },
    btn_menu_shop = {
      listener = handler(self, self.OnBtn_Menu_Shop),
      variName = "btn_menu_shop",
      param = {2}
    },
    btn_menu_market = {
      listener = handler(self, self.OnBtn_Menu_Market),
      variName = "btn_menu_market",
      param = {2}
    },
    btn_menu_guanqia = {
      listener = handler(self, self.OnBtn_Menu_Gate),
      variName = "btn_menu_guanqia"
    },
    btn_menu_biwu = {
      listener = handler(self, self.OnBtn_Menu_BiWu),
      variName = "btn_menu_biwu",
      param = {2}
    },
    btn_menu_huodong = {
      listener = handler(self, self.OnBtn_Menu_Huodong),
      variName = "btn_menu_huodong",
      param = {2}
    },
    btn_menu_rank = {
      listener = handler(self, self.OnBtn_Menu_Rank),
      variName = "btn_menu_rank",
      param = {2}
    },
    btn_tt_exit = {
      listener = handler(self, self.OnBtn_Menu_Exit),
      variName = "btn_tt_exit"
    },
    btn_menu_guild = {
      listener = handler(self, self.OnBtn_Menu_Guild),
      variName = "btn_menu_guild",
      param = {2}
    },
    btn_menu_eqptupgrade = {
      listener = handler(self, self.OnBtn_Menu_EqptUpgrade),
      variName = "btn_menu_eqptupgrade",
      param = {2}
    },
    btn_menu_huoban = {
      listener = handler(self, self.OnBtn_Menu_HuoBan),
      variName = "btn_menu_huoban",
      param = {2}
    },
    btn_menu_zuoqi = {
      listener = handler(self, self.OnBtn_Menu_Zuoqi),
      variName = "btn_menu_zuoqi",
      param = {2}
    },
    btn_menu_mission = {
      listener = handler(self, self.OnBtn_Menu_Mission),
      variName = "btn_menu_mission",
      param = {2}
    },
    btn_menu_team = {
      listener = handler(self, self.OnBtn_Menu_Team),
      variName = "btn_menu_team",
      param = {2}
    },
    btn_menu_friend = {
      listener = handler(self, self.OnBtn_Menu_Friend),
      variName = "btn_menu_friend",
      param = {2}
    },
    btn_menu_sociality = {
      listener = handler(self, self.OnBtn_Menu_Sociality),
      variName = "btn_menu_sociality",
      param = {2}
    },
    btn_menu_dailyword = {
      listener = handler(self, self.OnBtn_Menu_DailyWord),
      variName = "btn_menu_dailyword",
      param = {2}
    },
    btn_createteam = {
      listener = handler(self, self.OnBtn_Menu_CreateTeam),
      variName = "btn_createteam",
      param = {2}
    },
    btn_findteam = {
      listener = handler(self, self.OnBtn_Menu_FindTeam),
      variName = "btn_findteam",
      param = {2}
    },
    btn_menu_tisheng = {
      listener = handler(self, self.OnBtn_Menu_Upgrade),
      variName = "btn_menu_tisheng",
      param = {2}
    },
    btn_menu_doubleexp = {
      listener = handler(self, self.OnBtn_Menu_Doubleexp),
      variName = "btn_menu_doubleexp",
      param = {2}
    },
    btn_menu_gm = {
      listener = handler(self, self.OnBtn_Menu_GM),
      variName = "btn_menu_gm",
      param = {2}
    },
    btn_menu_skill = {
      listener = handler(self, self.OnBtn_Menu_Skill),
      variName = "btn_menu_skill",
      param = {2}
    },
    btn_menu_tool = {
      listener = handler(self, self.OnBtn_Menu_Tool),
      variName = "btn_menu_tool",
      param = {2}
    },
    btn_freshgift = {
      listener = handler(self, self.OnBtn_FreshGift),
      variName = "btn_freshgift",
      param = {2}
    },
    btn_buygift1 = {
      listener = handler(self, self.OnBtn_BuyGift1),
      variName = "btn_buygift1",
      param = {2}
    },
    btn_menu_add = {
      listener = handler(self, self.OnBtn_Menu_Add),
      variName = "btn_menu_add"
    },
    btn_playerOfMap = {
      listener = handler(self, self.OnBtn_PlayerOfMap),
      variName = "btn_playerOfMap",
      param = {2}
    },
    btns_layout9 = {
      listener = handler(self, self.OnBtn_Menu_ShowMiniMap),
      variName = "btns_layout9",
      param = {2}
    },
    btn_worldmap = {
      listener = handler(self, self.OnBtn_Menu_ShowWorldMap),
      variName = "btn_worldmap",
      param = {2}
    },
    btn_lifeskill = {
      listener = handler(self, self.OnBtn_Menu_LifeSkill),
      variName = "btn_lifeskill",
      param = {2}
    },
    btn_jiayiitem = {
      listener = handler(self, self.OnBtn_Menu_JiaYiItem),
      variName = "btn_jiayiitem",
      param = {2}
    },
    btn_yzdd = {
      listener = handler(self, self.OnBtn_Menu_YZDD),
      variName = "btn_yzdd"
    },
    btn_dule = {
      listener = handler(self, self.OnBtn_Menu_Dule),
      variName = "btn_dule"
    },
    btn_satang = {
      listener = handler(self, self.OnBtn_Menu_SaTang),
      variName = "btn_satang"
    },
    btn_extraexp = {
      listener = handler(self, self.OnBtn_Menu_ExtraExp),
      variName = "btn_extraexp",
      param = {2}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:adjustClickSize(self.btn_menu_add, 105, 105)
  self:initBtnsPosWithMsgBoxMode()
  self.btn_voice_team = self:getNode("btn_voice_team")
  self.btn_voice_bp = self:getNode("btn_voice_bp")
  self.btn_voice_world = self:getNode("btn_voice_world")
  VoiceRecordBtnExtend.extend(self.btn_voice_team, CHANNEL_TEAM)
  VoiceRecordBtnExtend.extend(self.btn_voice_bp, CHANNEL_BP_MSG)
  VoiceRecordBtnExtend.extend(self.btn_voice_world, CHANNEL_WOLRD)
  self.m_BtnNotOpenFlagDict = {}
  self.m_NotShowRightBottomFlag = true
  self.m_RightBottomOpenFunc = {}
  self.pic_tt_expbg = self:getNode("pic_tt_expbg")
  self.txt_tt_exp = self:getNode("txt_tt_exp")
  self.m_ShowTTBtnFlag = false
  self.m_TTCurShowExp = 0
  self.m_UpdateTimer = 0
  self.m_UpdateTimer_2 = 0
  self.m_ShowLevelBtnFlag = false
  self.m_IsDayantaShowBtn = false
  self.m_IsTiantingShowBtn = false
  self.m_IsTianDiQiShuShowBtn = false
  self.m_ShowExpBgFlag = false
  if CMainUIScene.Ins then
    CMainUIScene.Ins:setToolBtn(self.btn_menu_tool)
  end
  self.m_SimpleFlag = false
  self.m_TopSimpleFlag = false
  self.m_Btn_ActionBtnNameDict = {
    "btn_menu_tool",
    "btn_menu_skill",
    "btn_menu_zuoqi",
    "btn_menu_huoban",
    "btn_menu_eqptupgrade",
    "btn_menu_guild"
  }
  self.m_Btn_ActionTopBtnNameDict = {
    "btn_menu_rank",
    "btn_menu_huodong",
    "btn_menu_biwu",
    "btn_menu_guanqia",
    "btn_menu_market",
    "btn_menu_shop"
  }
  self.m_Btn_AllSetPosBtnNameDict = {
    "btn_menu_tool",
    "btn_menu_skill",
    "btn_menu_pet",
    "btn_menu_zuoqi",
    "btn_menu_huoban",
    "btn_menu_eqptupgrade",
    "btn_menu_guild",
    "btn_menu_friend",
    "btn_menu_sociality",
    "btn_voice_world",
    "btn_menu_dailyword",
    "btn_voice_team",
    "btn_voice_bp",
    "btn_menu_doubleexp",
    "btn_menu_tisheng",
    "btn_menu_gm",
    "btn_menu_rank",
    "btn_menu_huodong",
    "btn_menu_biwu",
    "btn_menu_guanqia",
    "btn_menu_market",
    "btn_menu_shop"
  }
  self.m_IsNewBtnAction = false
  self.m_Btn_ActionBtnOldPosDict = {}
  self.m_Btn_ActionBtnPosDict = {}
  local x, y = self.btn_menu_add:getPosition()
  self.m_Btn_ActionBtnHidePos = ccp(x, y)
  for _, btnName in pairs(self.m_Btn_AllSetPosBtnNameDict) do
    local x, y = self[btnName]:getPosition()
    self.m_Btn_ActionBtnOldPosDict[btnName] = ccp(x, y)
  end
  self:ShowBtnRedIcon(self.btn_menu_zuoqi, CanGetZuoQi())
  self:ShowBtnRedIcon(self.btn_menu_huodong, activity.event:canReciveEvent())
  local newBpTip = g_BpMgr:getBpNewTip()
  self:ShowBtnRedIcon(self.btn_menu_guild, newBpTip)
  self:ShowPackageBtnFullIcon(0 >= g_LocalPlayer:GetPackageEmpty())
  self:SetJGLightCircle()
  self:setDoubleExpTxt()
  local marketFlag = g_BaitanDataMgr:GetRedIconFlag()
  self:ShowBtnRedIcon(self.btn_menu_market, marketFlag)
  self:checkFubenCanGetAward()
  self:InitExpBar()
  self:setLifeSkillState()
  self:setJiaYiWanState()
  self:updateExp()
  self:updateLv()
  self:updateMapName()
  self:updateMapPos()
  self:updateHeadImg()
  self:updateVIP()
  self:updatePetLvBg()
  self:SetStoreBtnRedIcon()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_MapScene)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Mail)
  self:ListenMessage(MsgID_WarSetting)
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Device)
  self:ListenMessage(MsgID_BPWar)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_OtherPlayer)
  self:ListenMessage(MsgID_Stall)
  self:ListenMessage(MsgID_FubenInfo)
  self:ListenMessage(MsgID_ChongZhi)
  self:ListenMessage(MsgID_MapLoading)
  self:ListenMessage(MsgID_Marry)
  self:InitMissionShow()
  self:InitTeamShow()
  self:checkIsInBp()
  self:ShowMissionBoard()
  self:InitMsgBox()
  self:setGuajiState()
  self:setActivityButton()
  self:SetSimpleFlag(true)
  self:updateBtnOpenFlagDict()
  self:setIsShowTianting(false)
  self:ShowSaTangBtn()
  self.m_ShowTishengBtn = false
  self:UpdateTishengBoard()
  self.pos_playerofmap = self:getNode("pos_playerofmap")
  self.m_OnSelectPlayerOfMap = nil
  self.btn_playerOfMap:setEnabled(false)
  self:ClearPlayerInfoOfMap()
  self:InitOnlineReward()
  self:InitQuickUseBoard()
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self:scheduleUpdate()
  self.pic_tipnew_friend = self:getNode("pic_tipnew_friend")
  self.unread_friend = self:getNode("unread_friend")
  self:ShowFriendTip(0)
  self:CheckShowNewMailTip()
  BpwarEntrance.extend(self)
  BpwarStateInfo.extend(self, self:getNode("layer_bpwar"), true)
  scheduler.performWithDelayGlobal(handler(self, self.InitSociality), 0.5)
  g_CMainMenuHandler = self
  activity.tianting:flushIsInMap()
  self.m_WifiIcon = self:getNode("wifi")
  self.m_MobIcon = self:getNode("mob")
  self.m_NoSignalIcon = self:getNode("nosignal")
  self.time_bg = self:getNode("time_bg")
  for _, obj in pairs({
    self.m_WifiIcon,
    self.m_MobIcon,
    self.m_NoSignalIcon,
    self.time_bg
  }) do
    local x, y = obj:getPosition()
    obj.__initPos = ccp(x, y)
  end
  local size = self.time_bg:getSize()
  self.time_bg.__initSize = CCSize(size.width, size.height)
  self:checkTimeAndWifi()
  self:checkBtterty()
  self:checkExtraExpFlag()
end
function CMainMenu:frameUpdate(dt)
  if g_LocalPlayer ~= nil then
    self:OnlineRewardUpdate(dt)
    self:UpdateRemindEventList()
    self:FreshRewardUpdate()
  end
  if self.m_IsNeedReflushMission then
    self:ReflushAllMission()
  end
  self.m_UpdateTimer = self.m_UpdateTimer + dt
  if self.m_UpdateTimer >= 1 then
    self.m_UpdateTimer = self.m_UpdateTimer - math.floor(self.m_UpdateTimer)
    self:checkTimeAndWifi()
    self:checkTeamItemOfTeamList()
    self:UpdateSaTangBtnText()
  end
  self.m_UpdateTimer_2 = self.m_UpdateTimer_2 + dt
  if self.m_UpdateTimer_2 > 30 then
    self.m_UpdateTimer_2 = self.m_UpdateTimer_2 - math.floor(self.m_UpdateTimer_2)
    self:checkBtterty()
  end
end
function CMainMenu:checkTimeAndWifi()
  self:getNode("txt_time"):setText(os.date("%H:%M"))
  local netstatus = getNetworkStatus()
  if netstatus == NetStatus_WIFI then
    self.m_WifiIcon:setVisible(true)
    self.m_MobIcon:setVisible(false)
    self.m_NoSignalIcon:setVisible(false)
  elseif netstatus == NetStatus_3G then
    self.m_WifiIcon:setVisible(false)
    self.m_MobIcon:setVisible(true)
    self.m_NoSignalIcon:setVisible(false)
  else
    self.m_WifiIcon:setVisible(false)
    self.m_MobIcon:setVisible(false)
    self.m_NoSignalIcon:setVisible(true)
  end
end
function CMainMenu:checkBtterty()
  local blevel, btype = SyNative.getBatteryInfo()
  if blevel == -1 then
    local offx = 25
    self:getNode("battery"):setVisible(false)
    self:getNode("battery_bg"):setVisible(false)
    for _, obj in pairs({
      self.m_WifiIcon,
      self.m_MobIcon,
      self.m_NoSignalIcon
    }) do
      local p = obj.__initPos
      obj:setPosition(ccp(p.x - offx, p.y))
    end
    local size = self.time_bg.__initSize
    self.time_bg:setSize(CCSize(size.width - offx, size.height))
    local p = self.time_bg.__initPos
    self.time_bg:setPosition(ccp(p.x - offx / 2, p.y))
  else
    self:getNode("battery"):setVisible(true)
    self:getNode("battery_bg"):setVisible(true)
    for _, obj in pairs({
      self.m_WifiIcon,
      self.m_MobIcon,
      self.m_NoSignalIcon,
      self.time_bg
    }) do
      local p = obj.__initPos
      obj:setPosition(p)
    end
    local size = self.time_bg.__initSize
    self.time_bg:setSize(CCSize(size.width, size.height))
    local bs = blevel or 0
    if bs < 0 then
      bs = 0
    elseif bs > 1 then
      bs = 1
    end
    self:getNode("battery"):setScaleX(bs)
  end
end
function CMainMenu:checkExtraExpFlag()
  if g_LocalPlayer then
    local hasExtraExpFlag = g_LocalPlayer:IsHasExtraExp()
    self.btn_extraexp:setEnabled(hasExtraExpFlag and not self.m_ShowLevelBtnFlag and not self.__BpWarStateInfoDlgIsShow)
  else
    self.btn_extraexp:setEnabled(false)
  end
end
function CMainMenu:ShowExtraExpView(flag)
  if flag then
    if self.m_ExtraExpHelpDlg == nil then
      local x, y = self.btn_extraexp:getPosition()
      x = x + 40
      y = y - 60
      local parent = self.btn_extraexp:getParent()
      local pos = parent:convertToWorldSpace(ccp(x, y))
      local size = self.btn_extraexp:getSize()
      local helpDlg = CExtraExpView.new(pos, size)
      self.m_ExtraExpHelpDlg = helpDlg
    end
    self.m_ExtraExpHelpDlg:stopAllActions()
    self.m_ExtraExpHelpDlg:runAction(transition.sequence({
      CCDelayTime:create(3),
      CCCallFunc:create(function()
        self:ShowExtraExpView(false)
      end)
    }))
  elseif self.m_ExtraExpHelpDlg then
    self.m_ExtraExpHelpDlg:removeFromParentAndCleanup(true)
    self.m_ExtraExpHelpDlg = nil
  end
end
function CMainMenu:ShowJiaYiView(flag)
  if flag then
    if self.m_JiaYiHelpDlg == nil then
      local x, y = self.btn_extraexp:getPosition()
      x = x + 40
      y = y - 60
      local parent = self.btn_extraexp:getParent()
      local pos = parent:convertToWorldSpace(ccp(x, y))
      local size = self.btn_extraexp:getSize()
      local helpDlg = CJiaYiExpView.new(pos, size)
      self.m_JiaYiHelpDlg = helpDlg
    end
    self.m_JiaYiHelpDlg:stopAllActions()
    self.m_JiaYiHelpDlg:runAction(transition.sequence({
      CCDelayTime:create(3),
      CCCallFunc:create(function()
        self:ShowJiaYiView(false)
      end)
    }))
  elseif self.m_JiaYiHelpDlg then
    self.m_JiaYiHelpDlg:removeFromParentAndCleanup(true)
    self.m_JiaYiHelpDlg = nil
  end
end
function CMainMenu:onEnterEvent()
  if self.m_MissionBoardPos1 == nil or self.m_MissionBoardPos2 == nil then
    self:InitMissionBoardPos()
  end
end
function CMainMenu:InitExpBar()
  local exp = display.newSprite("views/mainviews/pic_exp.png")
  exp:setAnchorPoint(ccp(0, 0))
  self:addNode(exp, 1)
  self.m_ExpTextW = exp:getContentSize().width
  self.m_ExpOldCurExp = 0
  self.m_ExpOldMaxExp = 100
  local perW = (display.width - self.m_ExpTextW) / 10
  for i = 1, 10 do
    local mark = display.newSprite("views/mainviews/pic_expbarmark.png")
    mark:setAnchorPoint(ccp(0, 0))
    mark:setPosition(ccp(self.m_ExpTextW + (i - 1) * perW, 0))
    self:addNode(mark, 1)
  end
  self.m_ExpBar = ProgressClip.new("views/mainviews/expbar.png", "views/mainviews/expbarbg.png", 0, 100, true)
  local oldW = self.m_ExpBar:getContentSize().width
  self.m_ExpBar:setPosition(ccp(self.m_ExpTextW, 0))
  self.m_ExpBar:setScaleX((display.width - self.m_ExpTextW) / oldW)
  self:addChild(self.m_ExpBar)
end
function CMainMenu:updateExp()
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    printLog("ERROR", "找不到主英雄1")
    return
  end
  local zsNum = mainRole:getProperty(PROPERTY_ZHUANSHENG)
  local lvNum = mainRole:getProperty(PROPERTY_ROLELEVEL)
  local curExp = mainRole:getProperty(PROPERTY_EXP)
  local maxExp = CalculateHeroLevelupExp(lvNum, zsNum)
  if self.m_ExpOldCurExp <= self.m_ExpOldMaxExp then
    if curExp > maxExp then
      self.m_ExpBar:removeFromParent()
      self.m_ExpBar = ProgressClip.new("views/mainviews/pic_expbar_orange.png", "views/mainviews/expbarbg.png", 0, 100, true)
      local oldW = self.m_ExpBar:getContentSize().width
      self.m_ExpBar:setPosition(ccp(self.m_ExpTextW, 0))
      self.m_ExpBar:setScaleX((display.width - self.m_ExpTextW) / oldW)
      self:addChild(self.m_ExpBar)
    end
  elseif curExp <= maxExp then
    self.m_ExpBar:removeFromParent()
    self.m_ExpBar = ProgressClip.new("views/mainviews/expbar.png", "views/mainviews/expbarbg.png", 0, 100, true)
    local oldW = self.m_ExpBar:getContentSize().width
    self.m_ExpBar:setPosition(ccp(self.m_ExpTextW, 0))
    self.m_ExpBar:setScaleX((display.width - self.m_ExpTextW) / oldW)
    self:addChild(self.m_ExpBar)
  end
  self.m_ExpBar:progressTo(curExp, nil, maxExp)
  self.m_ExpOldCurExp = curExp
  self.m_ExpOldMaxExp = maxExp
end
function CMainMenu:updateLv()
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    printLog("ERROR", "找不到主英雄2")
    return
  end
  local zsNum = mainRole:getProperty(PROPERTY_ZHUANSHENG)
  local lvNum = mainRole:getProperty(PROPERTY_ROLELEVEL)
  self.m_RoleLevel = lvNum
  self:getNode("txt_level"):setText(string.format("%d转%d", zsNum, lvNum))
  local hp = mainRole:getProperty(PROPERTY_HP)
  local maxHp = mainRole:getMaxProperty(PROPERTY_HP)
  local mp = mainRole:getProperty(PROPERTY_MP)
  local maxMp = mainRole:getMaxProperty(PROPERTY_MP)
  self:getNode("pic_hero_hp"):setPercent(hp / maxHp * 100)
  self:getNode("pic_hero_mp"):setPercent(mp / maxMp * 100)
end
function CMainMenu:updateMapName(mapName)
  if mapName == nil then
    mapName = ""
  end
  local mapNameObj = self:getNode("txt_mapName")
  mapNameObj:setScale(1)
  mapNameObj:setText(mapName)
  AutoLimitObjSize(mapNameObj, 85)
end
function CMainMenu:updateMapPos(oldGX, oldGY, gx, gy)
  if self.m_RoleGX == gx and self.m_RoleGY == gy then
    return
  end
  self.m_RoleGX = gx
  self.m_RoleGY = gy
  self:getNode("txt_mapPos"):setText(string.format("%d,%d", gx, gy))
end
function CMainMenu:updateHeadImg()
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    printLog("ERROR", "找不到主英雄3")
    return
  end
  if self.m_HeadImg then
    self.m_HeadImg:removeFromParent()
  end
  local heroType = mainRole:getTypeId()
  self.m_HeadImg = createClickHead({
    roleTypeId = heroType,
    clickListener = handler(self, self.OnTouch_HeadIcon),
    clickSoundType = 2
  })
  self.pic_headiconbg = self:getNode("pic_headiconbg")
  self.pic_headiconbg:setOpacity(0)
  self.pic_headiconbg:addChild(self.m_HeadImg, 0)
  local size = self.pic_headiconbg:getContentSize()
  self.m_HeadImg:setPosition(ccp(-size.width / 2, -size.height / 2))
end
function CMainMenu:updateVIP()
  local player = g_DataMgr:getPlayer()
  local vipLv = player:getVipLv()
  self:getNode("txt_vip"):setText(string.format("%d", vipLv))
end
function CMainMenu:detectLevelUpAni(lv)
  if self.m_RoleLevel == nil then
    return
  end
  if lv > self.m_RoleLevel then
    self.m_RoleLevel = lv
    if self.m_LevelUpAniNode ~= nil then
      self.m_LevelUpAniNode:removeFromParentAndCleanup(true)
      self.m_LevelUpAniNode = nil
    end
    self.m_LevelUpAniNode = display.newNode()
    addNodeToTopLayer(self.m_LevelUpAniNode, TopLayerZ_LevelUpAni)
    self.m_LevelUpAniNode:setVisible(false)
    self.m_LevelUpAniNode:setPosition(display.width / 2, display.height * 0.6)
    if g_WarScene == nil then
      self:ShowLevelUpAni()
    end
    local pid = g_LocalPlayer:getPlayerId()
    local serverId = g_DataMgr:getCacheServerData().m_ChoosedLoginServerId
    local serverName = g_DataMgr:getLoginServerName() or "未知服务器"
    local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
    local roleName = g_LocalPlayer:getObjProperty(1, PROPERTY_NAME)
    local bpid = g_BpMgr:getLocalBpName()
    if bpid == nil or bpid == 0 or bpid == "" then
      bpid = "无帮派"
    end
    local player = g_DataMgr:getPlayer()
    local mbalance = 0
    local vipLv = 1
    local mbalance = 0
    if player then
      vipLv = player:getVipLv()
      mbalance = player:getGold()
    end
    local data = {
      serverId = serverId,
      serverName = serverName,
      roleId = pid,
      roleName = roleName,
      roleLv = lv,
      bpName = bpid,
      balance = mbalance,
      viplv = vipLv
    }
    g_ChannelMgr:RoleLevelUp(data)
  end
end
function CMainMenu:ShowLevelUpAni(dt)
  if self.m_LevelUpAniNode then
    dt = dt or 0.5
    local a1 = CCDelayTime:create(dt)
    local a2 = CCCallFunc:create(function()
      self:doShowLevelUpAni()
    end)
    self.m_LevelUpAniNode:runAction(transition.sequence({a1, a2}))
  end
end
function CMainMenu:doShowLevelUpAni()
  if g_WarScene ~= nil then
    return
  end
  local actList = {}
  local aniLayer_1, aniLayer_2, aniLayer_3, aniLayer_4, aniLayer_5, numAni
  actList[#actList + 1] = CCCallFunc:create(function()
    self.m_LevelUpAniNode:setVisible(true)
    aniLayer_1 = display.newSprite("xiyou/pic/pic_levelup_1.png")
    self.m_LevelUpAniNode:addChild(aniLayer_1, 1)
    aniLayer_1:setOpacity(127.5)
    aniLayer_2 = display.newSprite("xiyou/pic/pic_levelup_2.png")
    self.m_LevelUpAniNode:addChild(aniLayer_2, 2)
    aniLayer_2:setPosition(0, 10)
    aniLayer_2:runAction(CCRepeatForever:create(CCRotateBy:create(1.5, -360)))
    local dt = 0.12
    aniLayer_3 = display.newSprite("xiyou/pic/pic_levelup_3.png")
    self.m_LevelUpAniNode:addChild(aniLayer_3, 3)
    aniLayer_3:setAnchorPoint(ccp(0, 0.4))
    aniLayer_3:setPosition(ccp(50, -15))
    aniLayer_3:setRotation(-50)
    aniLayer_3:setOpacity(0)
    aniLayer_3:runAction(transition.sequence({
      CCSpawn:createWithTwoActions(CCFadeIn:create(dt), CCRotateTo:create(dt, 20)),
      CCRotateTo:create(dt, 0)
    }))
    aniLayer_33 = display.newSprite("xiyou/pic/pic_levelup_3.png")
    self.m_LevelUpAniNode:addChild(aniLayer_33, 3)
    aniLayer_33:setAnchorPoint(ccp(0, 0.4))
    aniLayer_33:setPosition(ccp(-50, -15))
    aniLayer_33:setScaleX(-1)
    aniLayer_33:setRotation(50)
    aniLayer_33:runAction(transition.sequence({
      CCSpawn:createWithTwoActions(CCFadeIn:create(dt), CCRotateTo:create(dt, -20)),
      CCRotateTo:create(dt, 0)
    }))
    aniLayer_4 = display.newSprite("xiyou/pic/pic_levelup_4.png")
    self.m_LevelUpAniNode:addChild(aniLayer_4, 4)
    aniLayer_5 = display.newSprite("xiyou/pic/pic_levelup_5.png")
    self.m_LevelUpAniNode:addChild(aniLayer_5, 5)
    aniLayer_5:setOpacity(51)
    aniLayer_5:runAction(CCFadeTo:create(0.5, 255))
    numAni = CCLabelBMFont:create(tostring(self.m_RoleLevel), "xiyou/fnt/fnt_levelup.fnt")
    numAni:setAnchorPoint(ccp(0.5, 0.5))
    numAni:setPosition(ccp(0, 10))
    self.m_LevelUpAniNode:addChild(numAni, 6)
    numAni:setScale(0.2)
    numAni:setOpacity(51)
    numAni:runAction(transition.sequence({
      CCSpawn:createWithTwoActions(CCFadeTo:create(dt, 255), CCScaleTo:create(dt, 1.3)),
      CCScaleTo:create(dt, 1)
    }))
  end)
  actList[#actList + 1] = CCDelayTime:create(1)
  local dt = 0.5
  actList[#actList + 1] = CCCallFunc:create(function()
    aniLayer_1:runAction(CCFadeTo:create(dt, 0))
    aniLayer_2:runAction(CCFadeTo:create(dt, 0))
    aniLayer_3:runAction(CCFadeTo:create(dt, 0))
    aniLayer_33:runAction(CCFadeTo:create(dt, 0))
    aniLayer_4:runAction(CCFadeTo:create(dt, 0))
    aniLayer_5:runAction(CCFadeTo:create(dt, 0))
    numAni:runAction(CCFadeTo:create(dt, 0))
  end)
  actList[#actList + 1] = CCDelayTime:create(dt)
  actList[#actList + 1] = CCCallFunc:create(function()
    if self.m_LevelUpAniNode then
      self.m_LevelUpAniNode:removeFromParentAndCleanup(true)
      self.m_LevelUpAniNode = nil
    end
    self:ShowQuickUseBoard()
  end)
  self.m_LevelUpAniNode:runAction(transition.sequence(actList))
end
function CMainMenu:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  local fid = self:GetFIDWithSID(msgSID)
  if fid == MsgID_Mission then
    self:MissionMessage(msgSID, arg)
  elseif msgSID == MsgID_HeroUpdate then
    local playerId = arg[1].pid
    local heroId = arg[1].heroId
    local player = g_DataMgr:getPlayer(playerId)
    if playerId ~= g_LocalPlayer:getPlayerId() then
      return
    end
    if player == nil or heroId == nil then
      return
    end
    local petId = arg[1].pro[PROPERTY_PETID]
    if petId ~= nil and petId ~= 0 then
      self:delItemFromQuickUseBoard(BoxOpenType_Pet, petId)
    end
    if heroId ~= player:getMainHeroId() then
      return
    end
    local lv = arg[1].pro[PROPERTY_ROLELEVEL]
    local zs = arg[1].pro[PROPERTY_ZHUANSHENG]
    local exp = arg[1].pro[PROPERTY_EXP]
    local shape = arg[1].pro[PROPERTY_SHAPE]
    if lv ~= nil then
      self:detectLevelUpAni(lv)
    end
    self:updateLv()
    if lv ~= nil or zs ~= nil or exp ~= nil then
      self:updateExp()
    end
    if lv ~= nil or zs ~= nil then
      self:updateBtnOpenFlagDict()
      self:SetJGLightCircle()
    end
    if zs ~= nil then
      self:reflushQuickUseBoard()
    end
    if shape ~= nil then
      self:updateHeadImg()
    end
    self:ShowBtnRedIcon(self.btn_menu_zuoqi, CanGetZuoQi())
    self:ShowBtnRedIcon(self.btn_menu_huodong, activity.event:canReciveEvent())
    self:updatePetLvBg()
  elseif msgSID == MsgID_PetUpdate then
    self:updatePetLvBg()
  elseif msgSID == MsgID_VIPUpdate then
    self:updateVIP()
  elseif msgSID == MsgID_Team_NewTeam then
    self:onReceiveNewTeam(arg[1])
  elseif msgSID == MsgID_Team_PlayerJoinTeam then
    self:onReceiveNewTeamPlayer(arg[1], arg[2])
  elseif msgSID == MsgID_Team_PlayerLeaveTeam then
    self:onReceivePlayerLeaveTeam(arg[1], arg[2])
  elseif msgSID == MsgID_Team_TeamState then
    self:onReceiveTeamState(arg[1], arg[2])
  elseif msgSID == MsgID_Team_SetCaptain then
    self:onReceiveCaptainChanged(arg[1], arg[3])
  elseif msgSID == MsgID_Team_AddJoinRequest then
    self:onReceiveAddJoinRequest()
  elseif msgSID == MsgID_Team_ClearJoinRequest then
    self:onReceiveClearJoinRequest()
  elseif msgSID == MsgID_Team_HasCheckJoinRequest then
    self:onReceiveHasCheckJoinRequest()
  elseif msgSID == MsgID_Team_DelJoinRequest then
    self:onReceiveDelJoinRequest(arg[1])
  elseif msgSID == MsgID_Team_IsAutoMatching then
    self:checkIsAutoMathing()
  elseif msgSID == MsgID_MapScene_TouchRole then
    self:onSelectPlayerOfMap(arg[1])
  elseif msgSID == MsgID_MapScene_TouchMapBegan then
    self:onTouchMapBegan()
  elseif msgSID == MsgID_MapScene_ChangedMap then
    self:onSelectPlayerOfMap(nil)
  elseif msgSID == MsgID_MapLoading_Finished then
    self:checkBpWarStateForBtn()
    self:checkBpWarStateInfo()
    self:setActivityButton()
  elseif msgSID == MsgID_Gift_FreshGiftUpdate then
    self:FreshRewardUpdate()
  elseif msgSID == MsgID_ChongZhi_ItemListUpdate then
    self:FreshRewardUpdate()
  elseif msgSID == MsgID_Gift_OnlineRewardUpdate then
    self:reflushOnlineReward()
  elseif msgSID == MsgID_Scene_Open_PrivateChat then
    self:OpenPrivateChat(arg[1])
  elseif msgSID == MsgID_Scene_NewFriendTip then
    self:ShowFriendTip(arg[1])
  elseif msgSID == MsgID_Scene_War_Exit then
    if self.m_LevelUpAniNode ~= nil then
      self:ShowLevelUpAni(0.5)
    end
    self:clearTeamPlayerBoard()
    local warType = arg[2]
    local isWatch = arg[3]
    local isReview = arg[4]
    local warResult = arg[5]
    self:SetEventRemindInWar(warType, isWatch, isReview, warResult)
  elseif msgSID == MsgID_Scene_War_Enter then
    self:clearTeamPlayerBoard()
  elseif msgSID == MsgID_AddPet then
    local objId = arg[2]
    self:addItemToQuickUseBoard(BoxOpenType_Pet, objId)
    self:updatePetLvBg()
  elseif msgSID == MsgID_DeletePet then
    local objId = arg[1]
    self:reflushQuickUseBoard()
    self:updatePetLvBg()
  elseif msgSID == MsgID_AddHero then
    local objId = arg[2]
    self:addItemToQuickUseBoard(BoxOpenType_Hero, objId)
  elseif msgSID == MsgID_DeleteHero then
    local objId = arg[1]
    self:delItemFromQuickUseBoard(BoxOpenType_Hero, objId)
  elseif msgSID == MsgID_WarSetting_Change then
    local para = arg[1]
    local settingData = para.setting
    for pos, roleId in pairs(settingData) do
      self:delItemFromQuickUseBoard(BoxOpenType_Hero, roleId)
    end
    self:reflushQuickUseBoard()
  elseif msgSID == MsgID_HeroSkillExpChange then
    self:reflushQuickUseBoard()
  elseif msgSID == MsgID_ItemInfo_AddItem then
    local objId = arg[1]
    self:addItemToQuickUseBoard(BoxOpenType_Item, objId)
    self:ShowPackageBtnFullIcon(0 >= g_LocalPlayer:GetPackageEmpty())
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local objId = arg[1]
    self:delItemFromQuickUseBoard(BoxOpenType_Item, objId)
    self:ShowPackageBtnFullIcon(0 >= g_LocalPlayer:GetPackageEmpty())
  elseif msgSID == MsgID_ItemInfo_ExpandPackageGird then
    self:ShowPackageBtnFullIcon(0 >= g_LocalPlayer:GetPackageEmpty())
  elseif msgSID == MsgID_ItemInfo_TakeEquip then
    local objId = arg[2]
    self:reflushQuickUseBoard()
    self:ShowPackageBtnFullIcon(0 >= g_LocalPlayer:GetPackageEmpty())
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    self:ShowPackageBtnFullIcon(0 >= g_LocalPlayer:GetPackageEmpty())
  elseif msgSID == MsgID_ItemInfo_ItemUpdate then
    local para = arg[1]
    local objId = para.itemId
    local newNum = para.pro[ITEM_PRO_NUM]
    if newNum ~= nil then
      local oldNum = para.oldPro[ITEM_PRO_NUM]
      if oldNum == nil then
        oldNum = 0
      end
      if newNum > oldNum then
        self:addItemToQuickUseBoard(BoxOpenType_Item, objId)
      end
    end
  elseif msgSID == MsgID_ItemInfo_JiaYiWanDataUpdate then
    self:setJiaYiWanState()
    self:ShowJiaYiView(false)
  elseif msgSID == MsgID_Mail_AllMailLoaded then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_Mail_MailUpdated then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_Mail_MailDeleteed then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_Mail_MailHasNewMail then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_DoubleExpUpdate then
    self:setDoubleExpTxt()
  elseif msgSID == MsgID_NewZuoqi then
    self:ShowBtnRedIcon(self.btn_menu_zuoqi, CanGetZuoQi())
  elseif msgSID == MsgID_Activity_Updated then
    self:ShowBtnRedIcon(self.btn_menu_huodong, activity.event:canReciveEvent())
  elseif msgSID == MsgID_Activity_YZDDStatus then
    self:setActivityButton()
  elseif msgSID == MsgID_Activity_XZSCStatus then
    self:setActivityButton()
  elseif msgSID == MsgID_Activity_DuelStatus then
    self:setActivityButton()
  elseif msgSID == MsgID_BPWar_State then
    self:checkBpWarStateForBtn()
  elseif msgSID == MsgID_BP_LocalInfo then
    self:checkIsInBp()
    self:checkBpWarStateForBtn()
  elseif msgSID == MsgID_BP_NewBpJoinRequest or msgSID == MsgID_BP_BpWarJoinTip then
    local newBpTip = g_BpMgr:getBpNewTip()
    self:ShowBtnRedIcon(self.btn_menu_guild, newBpTip)
  elseif msgSID == MsgID_EnterBackground then
    self:onSelectPlayerOfMap(nil)
    self.m_RecordTishengData = nil
    startClientService()
    print("退到后台 ******************************************** ")
  elseif msgSID == MsgID_EnterForeground then
    self:UpdateTishengBoard()
  elseif msgSID == MsgID_LoginOut then
    startClientService()
  elseif msgSID == MsgID_Connect_SendFinished then
    self:ShowBtnRedIcon(self.btn_menu_huodong, activity.event:canReciveEvent())
    startClientService()
  elseif msgSID == MsgID_GuajiUpdate then
    self:setGuajiState()
  elseif msgSID == MsgID_Team_LocalIsTeamer then
    self:setGuajiState()
  elseif msgSID == MsgID_LifeSkillBSDUpdate then
    self:setLifeSkillState()
  elseif msgSID == MsgID_LifeSkillWineUpdate then
    self:setLifeSkillState()
  elseif msgSID == MsgID_LifeSkillFuUpdate then
    self:setLifeSkillState()
    self:updateHeadImg()
  elseif msgSID == MsgID_ServerTime then
    activity.keju:checkIsShowDianshiReadyBtn()
  elseif msgSID == MsgID_OtherPlayer_UpdatePlayer then
    local pId = arg[1]
    if pId == self.m_OnSelectPlayerOfMap then
      self:onSelectPlayerOfMap(nil)
    end
  elseif msgSID == MsgID_Stall_GoodsChange then
    local flag = g_BaitanDataMgr:GetRedIconFlag()
    self:ShowBtnRedIcon(self.btn_menu_market, flag)
  elseif msgSID == MsgID_Scene_MsgBoxSmallMode then
    self:setBtnsPosWithMsgBoxMode(arg[1], arg[2])
  elseif msgSID == MsgID_FubenInfo_CatchInfo then
    self:checkFubenCanGetAward()
  elseif msgSID == MsgID_FubenInfo_UpdateAward then
    self:checkFubenCanGetAward()
  elseif msgSID == MsgID_ChongZhiFanli_Update then
    self:SetStoreBtnRedIcon()
  elseif msgSID == MsgID_ServerDailyClean then
    self:ResetEventRemindList()
  elseif msgSID == MsgID_ExtraExpFlag then
    self:checkExtraExpFlag()
    self:ShowExtraExpView(false)
  elseif msgSID == MsgID_ExtraExpItemChange then
    self:checkExtraExpFlag()
    self:ShowExtraExpView(false)
  elseif msgSID == MsgID_Marry_HuaCheDataUpdate then
    self:ShowSaTangBtn()
  elseif msgSID == MsgID_ItemInfo_UseChengZhangDan then
    local params = arg[1]
    if params ~= nil then
      local id = params.id
      local petObj = g_LocalPlayer:getObjById(id)
      local cnt = params.cnt
      local data = params.effect
      local petTypeId = petObj:getTypeId()
      local petName = data_getPetName(petTypeId)
      local dec = string.format("你的召唤兽#<Y>%s#服用成长丹剩余:#<R>%d#次，本次增加效果：", petName, cnt)
      local chengzhandanView = CUseChengZhangDan.new({title = " 提示", dec = dec}, data)
    end
  end
end
function CMainMenu:initBtnsPosWithMsgBoxMode()
  for _, btnName in pairs({
    "btn_menu_friend",
    "btn_menu_sociality",
    "btn_voice_world",
    "btn_voice_bp",
    "btn_voice_team",
    "btn_menu_dailyword",
    "btn_menu_gm"
  }) do
    local temp = self:getNode(btnName)
    if temp then
      local x, y = temp:getPosition()
      temp.__initPos = ccp(x, y)
    end
  end
end
function CMainMenu:setBtnsPosWithMsgBoxMode(isSmall, off)
  for _, btnName in pairs({
    "btn_menu_friend",
    "btn_menu_sociality",
    "btn_voice_world",
    "btn_voice_bp",
    "btn_voice_team",
    "btn_menu_dailyword",
    "btn_menu_gm"
  }) do
    local temp = self:getNode(btnName)
    if temp then
      if isSmall then
        temp:setPosition(temp.__initPos)
      else
        temp:setPosition(ccp(temp.__initPos.x, temp.__initPos.y + off))
      end
      local btnPos = self.m_Btn_ActionBtnPosDict[btnName]
      if btnPos then
        local _, y = temp:getPosition()
        self.m_Btn_ActionBtnPosDict[btnName] = ccp(btnPos.x, y)
      end
      local btnOldPos = self.m_Btn_ActionBtnOldPosDict[btnName]
      if btnOldPos then
        local _, y = temp:getPosition()
        self.m_Btn_ActionBtnOldPosDict[btnName] = ccp(btnOldPos.x, y)
      end
    end
  end
  self:SetBtnPos()
end
function CMainMenu:InitMissionShow()
  self:ListenMessage(MsgID_Mission)
  self.oldMisArray = {}
  local btnBatchListener = {
    btn_mission_close = {
      listener = handler(self, self.OnBtn_Menu_CloseMission),
      variName = "btn_mission_close"
    },
    btn_mission_open = {
      listener = handler(self, self.OnBtn_Menu_OpenMission),
      variName = "btn_mission_open"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.layer_mission_open = self:getNode("layer_mission_open")
  self.layer_mission_close = self:getNode("layer_mission_close")
  self.layer_mission_close:setVisible(false)
  self.btn_mission_open:setTouchEnabled(false)
  self.btn_mission_close:setTouchEnabled(true)
  self.list_mission = self:getNode("list_mission")
  self.list_mission:addTouchItemListenerListView(handler(self, self.ListSelector), handler(self, self.ListEventListener))
  local s = self.list_mission:getSize()
  self.m_MissionListOrgSize = CCSize(s.width, s.height)
  local x, y = self.list_mission:getPosition()
  self.m_MissionListOrgPos = ccp(x, y)
  self.m_TouchStartItem = nil
  self.m_MissionItem = {}
  self.m_IsNeedReflushMission = false
  self:ReflushAllMission()
end
function CMainMenu:MissionMessage(msgId, ...)
  self.m_IsNeedReflushMission = true
  local arg = {
    ...
  }
  if msgId == MsgID_Mission_Common and arg[1] ~= nil then
    self:ShowMissionBoard()
  end
end
function CMainMenu:MissionClear()
  self.m_TouchStartItem = nil
end
function CMainMenu:NeedFlushMission()
  self.m_IsNeedReflushMission = true
end
function CMainMenu:ReflushAllMission()
  self.m_IsNeedReflushMission = false
  local width = self.list_mission:getSize().width
  local missionIds, hasMainMission = g_MissionMgr:getCanTraceMission()
  local h = 0
  local canAcceptedBranchIds = g_MissionMgr:getCanAcceptMission({
    MissionKind_Main,
    MissionKind_Branch,
    MissionKind_Jingying,
    MissionKind_Shilian
  }) or {}
  for i, v in ipairs(canAcceptedBranchIds) do
    missionIds[#missionIds + 1] = v
  end
  local curMapId = g_MapMgr:getCurMapId()
  if activity.dayanta:isDayantaMapId(curMapId) then
    local newMissionIds = {}
    for i, mid in ipairs(missionIds) do
      if activity.dayanta:getLastMissionId() == mid then
        newMissionIds[#newMissionIds + 1] = mid
      end
    end
    hasMainMission = true
    missionIds = newMissionIds
  elseif activity.tianting:isMap(curMapId) then
    local newMissionIds = {}
    for i, mid in ipairs(missionIds) do
      if activity.tianting:isMission(mid) then
        newMissionIds[#newMissionIds + 1] = mid
      end
    end
    hasMainMission = true
    missionIds = newMissionIds
  elseif activity.tiandiqishu:isMap(curMapId) then
    local newMissionIds = {}
    for i, mid in ipairs(missionIds) do
      if activity.tiandiqishu:isMission(mid) then
        newMissionIds[#newMissionIds + 1] = mid
      end
    end
    hasMainMission = true
    missionIds = newMissionIds
  end
  local lenght_old = #self.oldMisArray
  local lenght_new = #missionIds
  for i = 1, #missionIds do
    local newID = missionIds[i]
    for v = 1, #self.oldMisArray do
      local oldID = self.oldMisArray[v]
      if newID == oldID then
        break
      end
      if newID ~= oldID and v == #self.oldMisArray then
        self.newMissionID = newID
        local missionKind = getMissionKind(self.newMissionID)
      end
    end
  end
  local curItems = {}
  local createItems = {}
  local count = self.list_mission:getCount()
  for i = 0, count - 1 do
    local item = self.list_mission:getItem(i)
    item:retain()
    local mid = item:getMissionId()
    createItems[mid] = {item = item, used = false}
  end
  self.list_mission:removeAllItems()
  if hasMainMission == false then
    missionIds[#missionIds + 1] = -1
  end
  for i, mId in ipairs(missionIds) do
    local isCreate = true
    local isZhuaGui = mId == ZhuaGui_MissionId
    if isZhuaGui and g_LocalPlayer._zg_endTime < g_DataMgr:getServerTime() then
      isCreate = false
    end
    local isXiuluo = mId == XiuLuo_MissionId
    if isXiuluo and g_LocalPlayer._xl_endTime < g_DataMgr:getServerTime() then
      isCreate = false
    end
    if isCreate then
      local itemData = createItems[mId]
      local needInsert = false
      if itemData == nil then
        local item = CMissionItemInMainView.new(width, mId)
        item:retain()
        local mid = item:getMissionId()
        itemData = {item = item, used = false}
        createItems[mId] = itemData
      end
      curItems[#curItems + 1] = itemData.item
      createItems[mId].item:reFresh()
      createItems[mId].used = true
    end
  end
  for k, v in pairs(createItems) do
    if v.used ~= true then
      v.item:release()
    end
  end
  table.sort(curItems, handler(self, self.sortMissionItemCompare))
  for i, item in ipairs(curItems) do
    self.list_mission:pushBackCustomItem(item)
    item:release()
    h = h + item:getSize().height
  end
  h = h * 1.2
  if h > self.m_MissionListOrgSize.height then
    h = self.m_MissionListOrgSize.height
  end
  self.list_mission:setSize(CCSize(self.m_MissionListOrgSize.width, h))
  self.list_mission:setPosition(ccp(self.m_MissionListOrgPos.x, self.m_MissionListOrgPos.y + self.m_MissionListOrgSize.height - h))
  self.oldMisArray = missionIds
  if self.list_myteam and self.list_myteam:isEnabled() then
    self:ShowTeamBoard()
  end
end
function CMainMenu:getTypeForSortMissionItem(missionId)
  local missionKind = getMissionKind(missionId)
  for k, v in pairs(GuideData_Mission) do
    if missionId == k then
      return 5
    end
  end
  if g_MissionMgr:isTiantingMissionId(missionId) or g_MissionMgr:isDayantaMissionId(missionId) or g_MissionMgr:isTianDiQiShuMissionId(missionId) then
    return 10
  end
  if missionKind == MissionKind_Jieqi or missionKind == MissionKind_Jiehun then
    return 1
  end
  if missionKind == MissionKind_Main then
    if missionId == self.newMissionID then
      return 20
    else
      return 30
    end
  elseif missionKind == MissionKind_Guide then
    return 40
  elseif missionKind == MissionKind_Shimen then
    if missionId == self.newMissionID then
      return 20
    else
      return 50
    end
  elseif missionKind == MissionKind_Activity then
    if missionId == self.newMissionID then
      return 20
    else
      return 50
    end
  elseif missionKind == MissionKind_SanJieLiLian then
    if missionId == self.newMissionID then
      return 20
    else
      return 50
    end
  elseif missionKind == MissionKind_Faction then
    if missionId == Business_MissionId then
      if missionId == self.newMissionID then
        return 20
      else
        return 60
      end
    elseif missionId == BangPaiAnZhan_MissionId then
      if missionId == self.newMissionID then
        return 20
      else
        return 60
      end
    elseif missionId == BangPaiChuMo_MissionId then
      if missionId == self.newMissionID then
        return 20
      else
        return 60
      end
    else
      return 60
    end
  elseif missionKind == MissionKind_Jingying then
    if missionId == self.newMissionID then
      return 20
    else
      return 70
    end
  elseif missionKind == MissionKind_Branch then
    if missionId == self.newMissionID then
      return 20
    else
      return 80
    end
  elseif missionKind == MissionKind_Shilian then
    if missionId == self.newMissionID then
      return 20
    else
      return 90
    end
  end
  return 999999999
end
function CMainMenu:sortMissionItemCompare(item1, item2)
  if item1 == nil or item2 == nil then
    return false
  end
  local mid1 = item1:getMissionId()
  local mid2 = item2:getMissionId()
  function isForceGuideId(mid)
    for k, v in pairs(GuideData_Mission) do
      if mid == k then
        return true
      end
    end
    return false
  end
  if isForceGuideId(mid1) == true and isForceGuideId(mid2) == false then
    return true
  elseif isForceGuideId(mid1) == false and isForceGuideId(mid2) == true then
    return false
  end
  local pro1, param1, complete1 = g_MissionMgr:getMissionProgress(mid1)
  local pro2, param2, complete2 = g_MissionMgr:getMissionProgress(mid2)
  if complete1 == true and complete2 == true then
    return mid1 < mid2
  elseif complete1 == true then
    return true
  elseif complete2 == true then
    return false
  end
  local t1 = self:getTypeForSortMissionItem(mid1)
  local t2 = self:getTypeForSortMissionItem(mid2)
  if t1 ~= t2 then
    return t1 < t2
  end
  return mid1 < mid2
end
function CMainMenu:testMissionList()
  local curItems = {}
  local count = self.list_mission:getCount()
  for i = 0, count - 1 do
    local item = self.list_mission:getItem(i)
    curItems[i + 1] = item
    item:retain()
  end
  self.list_mission:removeAllItems()
  for i = #curItems, 1, -1 do
    local item = curItems[i]
    self.list_mission:pushBackCustomItem(item)
    item:release()
  end
end
function CMainMenu:compareMissionId(mid1, mid2)
end
function CMainMenu:InitMissionBoardPos()
  local s1 = self.layer_mission_open:getSize()
  local x1, y1 = self.layer_mission_open:getPosition()
  local parent = self.layer_mission_open:getParent()
  local wPos = parent:convertToNodeSpace(ccp(display.width, 0))
  self.m_MissionBoardPos1 = ccp(wPos.x + 20, y1)
  self.m_MissionBoardPos2 = ccp(x1, y1)
end
function CMainMenu:HideMissionView()
  self.m_MissionViewIsShow = false
  local hideTime = 0.3
  if self.m_MissionBoardPos1 == nil then
    self:InitMissionBoardPos()
  end
  self.layer_mission_open:stopAllActions()
  self.layer_mission_open:runAction(transition.sequence({
    cc.MoveTo:create(hideTime, self.m_MissionBoardPos1),
    CCDelayTime:create(0.01),
    CCCallFunc:create(function()
      self.layer_mission_close:setVisible(true)
      self.layer_mission_open:setVisible(false)
      self.btn_mission_open:setTouchEnabled(true)
      self.btn_mission_close:setTouchEnabled(false)
    end)
  }))
end
function CMainMenu:ShowMissionView()
  self.m_MissionViewIsShow = true
  local hideTime = 0.3
  if self.m_MissionBoardPos2 == nil then
    self:InitMissionBoardPos()
  end
  self.layer_mission_close:setVisible(false)
  self.layer_mission_open:setVisible(true)
  self.btn_mission_open:setTouchEnabled(false)
  self.btn_mission_close:setTouchEnabled(true)
  self.layer_mission_open:stopAllActions()
  self.layer_mission_open:runAction(cc.MoveTo:create(hideTime, self.m_MissionBoardPos2))
end
function CMainMenu:ListSelector(item, index, listObj)
  print("====>> 滚动列表选中:", item:getMissionId())
  if self.m_IsDealingMissionSelector ~= true and g_MapMgr:getIsMapLoading() == false then
    self.m_IsDealingMissionSelector = true
    local missionId = item:getMissionId()
    g_MissionMgr:TraceMission(missionId)
    scheduler.performWithDelayGlobal(function()
      self.m_IsDealingMissionSelector = false
    end, 1)
  end
end
function CMainMenu:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    item:setTouchStatus(true)
    self.m_TouchStartItem = item
  elseif status == LISTVIEW_ONSELECTEDITEM_END and self.m_TouchStartItem then
    item:setTouchStatus(false)
    self.m_TouchStartItem = nil
  end
end
function CMainMenu:ShowMissionBoard()
  self.list_mission:setEnabled(true)
  self.list_mission:setVisible(true)
  self.list_myteam:setEnabled(false)
  self.btn_menu_mission:loadTextureNormal("views/mainviews/btn_misson_s.png")
  local openFlag = false
  if g_LocalPlayer then
    openFlag = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
  end
  if openFlag == false then
    self.btn_menu_team:loadTextureNormal("views/mainviews/btn_team_gray.png")
  else
    self.btn_menu_team:loadTextureNormal("views/mainviews/btn_team.png")
  end
end
function CMainMenu:OnBtn_Menu_CloseMission(btnObj, touchType)
  print("CMainMenu:OnBtn_Menu_CloseMission")
  self:HideMissionView()
end
function CMainMenu:OnBtn_Menu_OpenMission(btnObj, touchType)
  print("CMainMenu:OnBtn_Menu_OpenMission")
  self:ShowMissionView()
end
function CMainMenu:InitTeamShow()
  self:ListenMessage(MsgID_Team)
  self:ShowBtnLightCircle(self.btn_menu_team, false)
  self.noteam_bg = self:getNode("noteam_bg")
  self.icon_automatch = self:getNode("icon_automatch")
  self.txt_jointip = self:getNode("txt_jointip")
  self.list_myteam = self:getNode("list_myteam")
  self.list_myteamlist = self:getNode("list_myteamlist")
  self.list_myteamlist:ignoreContentAdaptWithSize(false)
  self.list_myteamlist:addTouchItemListenerListView(function(item, index, listObj)
    self:OnSelectTeamItem(item)
  end, handler(self, self.ListTeamEventListener))
  self.m_LocalTeamId = 0
  self.m_TouchStartTeamItem = nil
  self.m_TeamPlayerBoard = nil
  self:ReflushMyTeam()
end
function CMainMenu:ReflushMyTeam()
  self.list_myteamlist:removeAllItems()
  self.m_SelectTeamPlayer = nil
  self:clearTeamPlayerBoard()
  local teamId, teamInfo = g_TeamMgr:getLocalPlayerTeamInfo()
  if teamId == nil or teamId == 0 or teamInfo == nil or #teamInfo <= 0 then
    self.m_LocalTeamId = 0
    self.list_myteamlist:setTouchEnabled(false)
    self.btn_menu_dailyword:setVisible(false)
    self.btn_menu_dailyword:setTouchEnabled(false)
    self.btn_createteam:setVisible(true)
    self.btn_createteam:setTouchEnabled(true)
    self.btn_findteam:setVisible(true)
    self.btn_findteam:setTouchEnabled(true)
    self.noteam_bg:setVisible(true)
    self:checkIsAutoMathing()
    self.btn_voice_team:setVisible(false)
    self.btn_voice_team:setTouchEnabled(false)
    self.m_BtnNotOpenFlagDict.btn_menu_dailyword = true
    self.m_BtnNotOpenFlagDict.btn_voice_team = true
  else
    self.m_LocalTeamId = teamId
    self:SetTeamInfo(teamInfo, teamId)
    self.list_myteamlist:setTouchEnabled(true)
    self.btn_menu_dailyword:setVisible(true)
    self.btn_menu_dailyword:setTouchEnabled(true)
    self.btn_createteam:setVisible(false)
    self.btn_createteam:setTouchEnabled(false)
    self.btn_findteam:setVisible(false)
    self.btn_findteam:setTouchEnabled(false)
    self.noteam_bg:setVisible(false)
    self.btn_voice_team:setVisible(true)
    self.btn_voice_team:setTouchEnabled(true)
    self.m_BtnNotOpenFlagDict.btn_menu_dailyword = false
    self.m_BtnNotOpenFlagDict.btn_voice_team = false
  end
  self:SetBtnPos()
end
function CMainMenu:checkIsAutoMathing()
  if g_TeamMgr:GetIsAutoMatching() then
    self.icon_automatch:setVisible(true)
    self.txt_jointip:setText("自动匹配队伍中")
    self.txt_jointip:setAnchorPoint(ccp(0, 0.5))
    local x, _ = self.icon_automatch:getPosition()
    local size = self.icon_automatch:getContentSize()
    local _, y = self.txt_jointip:getPosition()
    self.txt_jointip:setPosition(ccp(x + size.width / 2, y))
  else
    self.icon_automatch:setVisible(false)
    self.txt_jointip:setText("创建或加入队伍")
    self.txt_jointip:setAnchorPoint(ccp(0.5, 0.5))
    local _, y = self.txt_jointip:getPosition()
    self.txt_jointip:setPosition(ccp(0, y))
  end
end
function CMainMenu:SetTeamInfo(teamInfo, teamId)
  table.sort(teamInfo, _TeamSortFunc)
  local okFlag = true
  local h = 0
  for index, pid in ipairs(teamInfo) do
    local item = CTeamItemInMainView.new(index, self.m_LocalTeamId, pid)
    if item:InitSuccess() then
      self.list_myteamlist:pushBackCustomItem(item:getUINode())
      local size = item:getContentSize()
      h = h + size.height
    else
      okFlag = false
    end
  end
  if not okFlag then
    print("------->>>组队信息发生异常，队伍成员找不到角色信息:", teamId, #teamInfo)
    netsend.netteam.requestVerifyTeamInfo(teamId)
  end
  local listSize = self.list_myteamlist:getContentSize()
  self.list_myteamlist:setSize(CCSize(listSize.width, h))
  local layerSize = self.list_myteam:getContentSize()
  local listY = layerSize.height - h
  self.list_myteamlist:setPosition(ccp(0, listY))
  if self.list_mission and self.list_mission:isEnabled() then
    self:ShowMissionBoard()
  end
end
function CMainMenu:ShowTeamBoard()
  self.list_myteam:setEnabled(true)
  self.list_mission:setEnabled(false)
  self.list_mission:setVisible(false)
  self.btn_menu_mission:loadTextureNormal("views/mainviews/btn_misson.png")
  self.btn_menu_team:loadTextureNormal("views/mainviews/btn_team_s.png")
end
function CMainMenu:ListTeamEventListener(item, index, listObj, status)
  if item then
    local obj = item.m_UIViewParent
    if obj then
      if status == LISTVIEW_ONSELECTEDITEM_START then
        obj:setTouchStatus(true)
        self.m_TouchStartTeamItem = obj
      elseif status == LISTVIEW_ONSELECTEDITEM_END and self.m_TouchStartTeamItem then
        obj:setTouchStatus(false)
        self.m_TouchStartTeamItem = nil
      end
    end
  end
end
function CMainMenu:onReceiveNewTeam(teamId)
  if self.m_LocalTeamId == 0 then
    local localPlayerId = g_LocalPlayer:getPlayerId()
    if g_TeamMgr:IsPlayerOfTeam(localPlayerId, teamId) then
      self:ReflushMyTeam()
      self:ShowTeamBoard()
    end
  elseif self.m_LocalTeamId == teamId then
    self:ReflushMyTeam()
  end
end
function CMainMenu:onReceiveNewTeamPlayer(teamId, pid)
  if self.m_LocalTeamId == 0 then
    if pid == g_LocalPlayer:getPlayerId() then
      self:ReflushMyTeam()
      self:ShowTeamBoard()
    end
  elseif self.m_LocalTeamId == teamId then
    self:ReflushMyTeam()
  end
end
function CMainMenu:onReceivePlayerLeaveTeam(teamId, pid)
  if self.m_LocalTeamId ~= 0 and self.m_LocalTeamId == teamId then
    self:ReflushMyTeam()
  end
end
function CMainMenu:onReceiveTeamState(teamId, pid)
  if g_LocalPlayer and pid == g_LocalPlayer:getPlayerId() then
    self:clearTeamPlayerBoard()
  end
end
function CMainMenu:onReceiveCaptainChanged(teamId, isCaptain)
  if self.m_LocalTeamId ~= 0 and self.m_LocalTeamId == teamId and isCaptain == TEAMCAPTAIN_YES then
    self:ReflushMyTeam()
  end
end
function CMainMenu:onReceiveAddJoinRequest()
  if g_MakeTeamDlg and g_MakeTeamDlg:IsCheckingJoinRequest() then
    self:ShowBtnLightCircle(self.btn_menu_team, false)
  else
    self:ShowBtnLightCircle(self.btn_menu_team, true)
  end
end
function CMainMenu:onReceiveClearJoinRequest()
  self:ShowBtnLightCircle(self.btn_menu_team, false)
end
function CMainMenu:onReceiveHasCheckJoinRequest()
  self:ShowBtnLightCircle(self.btn_menu_team, false)
end
function CMainMenu:onReceiveDelJoinRequest(pid)
  local joinRequest = g_TeamMgr:getJoinRequest()
  if #joinRequest <= 0 then
    self:ShowBtnLightCircle(self.btn_menu_team, false)
  end
end
function CMainMenu:checkTeamItemOfTeamList()
  if self.m_LocalTeamId == 0 then
    return
  end
  local cnt = self.list_myteamlist:getCount()
  if cnt > 0 then
    local teamId = g_TeamMgr:getLocalPlayerTeamId()
    local targetId = g_TeamMgr:getTeamTarget(teamId)
    local numLimit = GetTeamPlayerNumLimit(targetId)
    if cnt > numLimit then
      print("----->>>检测异常：组队人数超过人数上限，需要重新刷新", teamId, targetId, cnt, numLimit)
      netsend.netteam.requestVerifyTeamInfo(teamId)
      self:ReflushMyTeam()
    else
      local item = self.list_myteamlist:getItem(0)
      item = item.m_UIViewParent
      if item and iskindof(item, "CTeamItemInMainView") and not item:isCaptainItem() then
        print("----->>>检测异常：组队第一个不是队长，需要重新刷新")
        self:ReflushMyTeam()
      end
    end
  end
end
function CMainMenu:OnSelectTeamItem(item)
  if item == nil then
    return
  end
  item = item.m_UIViewParent
  if item == nil then
    return
  end
  if item.m_UINode == nil then
    return
  end
  self.m_SelectTeamPlayer = item
  if self.m_SelectTeamPlayer ~= nil then
    if item:getPlayerId() == g_LocalPlayer:getPlayerId() then
      self.m_TeamPlayerBoard = CTeamSelfBoard.new(handler(self, self.onTeamPlayerBoardClosed))
    else
      self.m_TeamPlayerBoard = CTeamPlayerBoard.new(self.m_SelectTeamPlayer:getPlayerId(), handler(self, self.onTeamPlayerBoardClosed))
    end
    local parent = getCurSceneView():getUINode()
    parent:addChild(self.m_TeamPlayerBoard:getUINode(), 999)
    local size = item:getContentSize()
    local wpos = item:getUINode():convertToWorldSpace(ccp(0, size.height / 2))
    local pos = parent:convertToNodeSpace(wpos)
    local bSize = self.m_TeamPlayerBoard:getContentSize()
    self.m_TeamPlayerBoard:setPosition(ccp(pos.x - bSize.width - 10, pos.y - bSize.height / 2))
    self.m_TeamPlayerBoard:adjustPos()
  end
end
function CMainMenu:onTeamPlayerBoardClosed()
  self.m_SelectTeamPlayer = nil
  self.m_TeamPlayerBoard = nil
end
function CMainMenu:clearTeamPlayerBoard()
  if self.m_TeamPlayerBoard then
    self.m_TeamPlayerBoard:CloseSelf()
    self.m_TeamPlayerBoard = nil
  end
end
function CMainMenu:OnBtn_Menu_QuitTeam(btnObj, touchType)
  if self.m_LocalTeamId == 0 then
    print("没有组队，怎么退出?")
    self:ReflushMyTeam()
    return
  end
  g_TeamMgr:send_QuitTeam()
end
function CMainMenu:OnBtn_Menu_Leave(btnObj, touchType)
  if self.m_LocalTeamId == 0 then
    print("没有组队，怎么退出?")
    self:ReflushMyTeam()
    return
  end
  if g_TeamMgr:localPlayerIsCaptain() then
    local callList = {}
    for i = 0, self.list_myteamlist:getCount() do
      local item = self.list_myteamlist:getItem(i)
      item = item.m_UIViewParent
      if item then
        local pid = item:getPlayerId()
        local teamState = g_TeamMgr:getPlayerTeamState(pid)
        if teamState == TEAMSTATE_LEAVE then
          callList[#callList + 1] = pid
        end
      end
    end
    if #callList > 0 then
      g_TeamMgr:send_CallBackTeamPlayer(callList)
    else
      ShowNotifyTips("没有需要召回的队友", true)
    end
  else
    local state = g_TeamMgr:getPlayerTeamState(g_LocalPlayer:getPlayerId())
    if state == TEAMSTATE_LEAVE then
      g_TeamMgr:send_ComebackTeam()
    else
      g_TeamMgr:send_TempLeaveTeam()
    end
  end
end
function CMainMenu:OnBtn_Menu_CreateTeam(btnObj, touchType)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  if g_TeamMgr:send_CreateTeam() == true then
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CMainMenu:OnBtn_Menu_FindTeam(btnObj, touchType)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CMakeTeam.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:TeamClear()
  self.m_TouchStartTeamItem = nil
end
function CMainMenu:checkIsInBp()
  if g_BpMgr:localPlayerHasBangPai() then
    self.btn_voice_bp:setVisible(true)
    self.btn_voice_bp:setTouchEnabled(true)
    self.m_BtnNotOpenFlagDict.btn_voice_bp = false
  else
    self.btn_voice_bp:setVisible(false)
    self.btn_voice_bp:setTouchEnabled(false)
    self.m_BtnNotOpenFlagDict.btn_voice_bp = true
  end
  self:SetBtnPos()
end
function CMainMenu:setGuajiState()
  print("setGuajiState", g_LocalPlayer:getGuajiState())
  local teamerFlag = g_LocalPlayer:getPlayerIsInTeam() and g_LocalPlayer:getPlayerInTeamAndIsCaptain() == false
  local btnPath = "views/mainviews/btn_doubleexp.png"
  if teamerFlag == true then
    btnPath = "views/mainviews/btn_doubleexp.png"
  elseif g_LocalPlayer:getGuajiState() ~= GUAJI_STATE_OFF then
    btnPath = "views/mainviews/btn_cancelguaji.png"
  end
  self.btn_menu_doubleexp:loadTextureNormal(btnPath)
end
function CMainMenu:onSelectPlayerOfMap(pid)
  if pid == nil or pid == g_LocalPlayer:getPlayerId() or g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START and self:IsTheSameBpWithLocalPlayer(pid) then
    self.m_OnSelectPlayerOfMap = nil
    self.btn_playerOfMap:setEnabled(false)
    self:ClearPlayerInfoOfMap()
  elseif self.m_OnSelectPlayerOfMap ~= pid then
    self.m_OnSelectPlayerOfMap = pid
    if self.btn_playerOfMap._headIcon ~= nil then
      self.btn_playerOfMap._headIcon:removeFromParentAndCleanup(true)
      self.btn_playerOfMap._headIcon = nil
    end
    local mainHero = g_TeamMgr:getPlayerMainHero(pid)
    if mainHero then
      local shapeId = mainHero:getBSFShapeId()
      headIcon = createHeadIconByShape(shapeId)
      self.btn_playerOfMap:getVirtualRenderer():addChild(headIcon)
      local size = self.btn_playerOfMap:getContentSize()
      headIcon:setPosition(ccp(size.width / 2, size.height / 2 + 7))
      self.btn_playerOfMap._headIcon = headIcon
    end
    self.btn_playerOfMap:setEnabled(true)
  end
end
function CMainMenu:onCancelSelectPlayerOfMap(pid)
  if self.m_OnSelectPlayerOfMap == pid then
    self.m_OnSelectPlayerOfMap = nil
    self.btn_playerOfMap:setEnabled(false)
    self:ClearPlayerInfoOfMap()
  end
end
function CMainMenu:setActivityButton()
  print("======>>> setActivityButton")
  if g_MapMgr and (g_MapMgr:IsInYiZhanDaoDiMap() and activity.yzdd:getStatus() ~= 2 or g_MapMgr:IsInXueZhanShaChangMap() and activity.xzsc:getStatus() ~= 2) then
    print("======>>> setActivityButton show:", g_MapMgr:IsInYiZhanDaoDiMap(), g_MapMgr:IsInXueZhanShaChangMap(), g_MapMgr:getCurMapId())
    self.btn_yzdd:setVisible(true)
    self.btn_yzdd:setTouchEnabled(true)
    self:addEntranceBtnAction(self.btn_yzdd, true)
  else
    print("======>>> setActivityButton hide")
    self.btn_yzdd:setVisible(false)
    self.btn_yzdd:setTouchEnabled(false)
    self:addEntranceBtnAction(self.btn_yzdd, false)
  end
  if g_DuleMgr and g_DuleMgr:isWaitingForDule() then
    self.btn_dule:setVisible(true)
    self.btn_dule:setTouchEnabled(true)
    self:addEntranceBtnAction(self.btn_dule, true)
  else
    self.btn_dule:setVisible(false)
    self.btn_dule:setTouchEnabled(false)
    self:addEntranceBtnAction(self.btn_dule, false)
  end
  self:checkBtnEntrancePos()
end
function CMainMenu:addEntranceBtnAction(entranceBtn, flag)
  if entranceBtn == nil then
    return
  end
  if flag then
    if entranceBtn._action == nil then
      entranceBtn._action = CCRepeatForever:create(transition.sequence({
        CCDelayTime:create(3),
        CCScaleTo:create(0.12, 1.1),
        CCScaleTo:create(0.12, 1),
        CCScaleTo:create(0.1, 1.15),
        CCScaleTo:create(0.1, 1)
      }))
      entranceBtn:runAction(entranceBtn._action)
    end
  elseif entranceBtn._action ~= nil then
    entranceBtn:stopAction(entranceBtn._action)
    entranceBtn._action = nil
  end
end
function CMainMenu:onTouchMapBegan()
  self:ShowExtraExpView(false)
  self:ShowJiaYiView(false)
end
function CMainMenu:InitSociality()
  if g_CMainMenuHandler == nil then
    return
  end
  if g_SocialityDlg == nil then
    g_SocialityDlg = getCurSceneView():addSubView({
      subView = socialityDlg.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
  if g_FriendsDlg == nil then
    g_FriendsDlg = getCurSceneView():addSubView({
      subView = FriendsDlg.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CMainMenu:setLifeSkillState()
  if self.m_LifeSkillBSDImg ~= nil then
    self.m_LifeSkillBSDImg:removeFromParent()
    self.m_LifeSkillBSDImg = nil
  end
  if self.m_LifeSkillWineImg ~= nil then
    self.m_LifeSkillWineImg:removeFromParent()
    self.m_LifeSkillWineImg = nil
  end
  if self.m_LifeSkillFuwenImg ~= nil then
    self.m_LifeSkillFuwenImg:removeFromParent()
    self.m_LifeSkillFuwenImg = nil
  end
  if g_LocalPlayer == nil then
    return
  end
  local bsFlag = g_LocalPlayer:getLifeSkillBSD() > 0
  if bsFlag then
    self.m_LifeSkillBSDImg = display.newSprite("views/lifeskill/lifeskill_bsd.png")
    self.m_LifeSkillBSDImg:setAnchorPoint(ccp(0, 0))
  else
    self.m_LifeSkillBSDImg = display.newSprite("views/lifeskill/lifeskill_bsd_gray.png")
    self.m_LifeSkillBSDImg:setAnchorPoint(ccp(0, 0))
  end
  local wineData = g_LocalPlayer:getLifeSkillWineData()
  local wineFlag = true
  if wineData.wid == nil or wineData.wid == 0 or wineData.v == nil or wineData.v == 0 then
    wineFlag = false
  end
  if wineFlag then
    self.m_LifeSkillWineImg = display.newSprite("views/lifeskill/lifeskill_wine.png")
    self.m_LifeSkillWineImg:setAnchorPoint(ccp(0, 0))
  else
  end
  local fuwenData = g_LocalPlayer:getLifeSkillFuData()
  local fuwenFlag = true
  if fuwenData.fid == nil or fuwenData.fid == 0 or fuwenData.v == nil or fuwenData.v == 0 then
    fuwenFlag = false
  end
  if fuwenFlag then
    self.m_LifeSkillFuwenImg = display.newSprite("views/lifeskill/lifeskill_fw.png")
    self.m_LifeSkillFuwenImg:setAnchorPoint(ccp(0, 0))
  else
  end
  if self.m_LifeSkillBSDImg then
    self:getNode("pos_lifeskillpos1"):addNode(self.m_LifeSkillBSDImg)
  end
  local index = 2
  if self.m_LifeSkillFuwenImg then
    self:getNode("pos_lifeskillpos2"):addNode(self.m_LifeSkillFuwenImg)
    index = index + 1
  end
  if self.m_LifeSkillWineImg then
    self:getNode(string.format("pos_lifeskillpos%d", index)):addNode(self.m_LifeSkillWineImg)
  end
end
function CMainMenu:setJiaYiWanState()
  if self.m_JiaYiWanImg ~= nil then
    self.m_JiaYiWanImg:removeFromParent()
    self.m_JiaYiWanImg = nil
  end
  self.btn_jiayiitem:setEnabled(false)
  self.btn_jiayiitem:setVisible(false)
  self.btn_jiayiitem:setTouchEnabled(false)
  if g_LocalPlayer == nil then
    return
  end
  if g_LocalPlayer:GetJiaYiWanPetId() ~= nil then
    self.m_JiaYiWanImg = display.newSprite("views/pic/pic_jiayiwanicon.png")
    self.m_JiaYiWanImg:setAnchorPoint(ccp(0, 0))
    local size = self:getNode("pos_jiayiitempos"):getContentSize()
    local mSize = self.m_JiaYiWanImg:getContentSize()
    self.m_JiaYiWanImg:setScale(size.height / mSize.height)
  end
  if self.m_JiaYiWanImg then
    self.btn_jiayiitem:setEnabled(true)
    self.btn_jiayiitem:setVisible(true)
    self.btn_jiayiitem:setTouchEnabled(true)
    self:getNode("pos_jiayiitempos"):addNode(self.m_JiaYiWanImg)
  end
end
function CMainMenu:OnTouch_HeadIcon(btnObj, touchType)
  getCurSceneView():addSubView({
    subView = settingDlg.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Setting(btnObj, touchType)
end
function CMainMenu:OnBtn_Menu_Shop(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Shop")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shangcheng)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  if g_LocalPlayer:getCanGetFanliAward() then
    local tempView = CStoreShow.new({InitStoreShow = StoreShow_FanLiView})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_StoreSMSDFlag then
    local tempView = CStoreShow.new({InitStoreShow = StoreShow_ShopView, initPage = Shop_Smsd_Page})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  else
    local tempView = CStoreShow.new({InitStoreShow = StoreShow_ShopView})
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CMainMenu:OnBtn_Menu_Market(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Market")
  if g_BaitanDataMgr:GetRedIconFlag() == true then
    enterMarket({initViewType = MarketShow_InitShow_CoinView, initBaitanType = BaitanShow_InitShow_StallView})
  else
    enterMarket()
  end
end
function CMainMenu:OnBtn_Menu_Gate(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Gate")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Guanqia)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  g_MapMgr:AutoRouteFB()
end
function CMainMenu:OnBtn_Menu_BiWu(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_BiWu")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Biwu)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  ShowBattlePvpDlg()
end
function CMainMenu:OnBtn_Menu_Huodong(btnObj, touchType)
  print("CMainMenu:OnBtn_Menu_Huodong")
  local tempView = CHuodongShow.new({InitHuodongShow = HuodongShow_EventView})
  getCurSceneView():addSubView({
    subView = tempView,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Rank(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Rank")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Rank)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CPHBView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Exit(btnObj, touchType)
  g_MapMgr:touchExitMapButtom()
end
function CMainMenu:OnBtn_Menu_Guild(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Guild")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_BangPai)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  ShowBangPaiDlg()
end
function CMainMenu:OnBtn_Menu_EqptUpgrade(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_EqptUpgrade")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_EqptUpgrade)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CCreateZhuangbei.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Skill(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Skill")
  if not self.m_SimpleFlag then
    self:setAutoHideBtns(BtnHideTime)
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shaofa)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CSkillShow.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_HuoBan(btnObj, touchType)
  self:SetJGLightCircle()
  print("CMainMenu:OnBtn_Menu_HuoBan")
  if not self.m_SimpleFlag then
    self:setAutoHideBtns(BtnHideTime)
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Jiuguan)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  if self.btn_menu_huoban.lightCircle == nil then
    getCurSceneView():addSubView({
      subView = CHuobanShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    getCurSceneView():addSubView({
      subView = CHuobanShow.new({viewNum = HuobanShow_GetHuobanView}),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CMainMenu:OnBtn_Menu_Zuoqi(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Zuoqi")
  if not self.m_SimpleFlag then
    self:setAutoHideBtns(BtnHideTime)
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zuoqi)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CZuoqiShow.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Pet(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Pet")
  if not self.m_SimpleFlag then
    self:setAutoHideBtns(BtnHideTime)
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhaohuanshou)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CPetList.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Mission(btnObj, touchType)
  print("CMainMenu:OnBtn_Menu_Mission")
  if self.list_mission:isEnabled() then
    getCurSceneView():addSubView({
      subView = CMissionView.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    self:ShowMissionBoard()
  end
end
function CMainMenu:OnBtn_Menu_Friend(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Friend")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Friend)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  if g_FriendsDlg then
    g_FriendsDlg:ShowOrHideDlg()
  end
end
function CMainMenu:OnBtn_Menu_Sociality(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Sociality")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shejiao)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  if g_SocialityDlg then
    g_SocialityDlg:ShowOrHideDlg()
  end
end
function CMainMenu:OnBtn_Menu_DailyWord(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shejiao)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  local dlg = getCurSceneView():addSubView({
    subView = CMainDailyWord.new(),
    zOrder = MainUISceneZOrder.menuView
  })
  local x, y = self.btn_menu_dailyword:getPosition()
  local size = self.btn_menu_dailyword:getContentSize()
  local px = x + size.width / 2 + 5
  local py = 40
  dlg:setPosition(ccp(px, py))
end
function CMainMenu:OpenPrivateChat(pid)
  if g_FriendsDlg then
    g_FriendsDlg:OpenPrivateChat(pid)
  end
end
function CMainMenu:OnBtn_Menu_Team(btnObj, touchType)
  print("CMainMenu:OnBtn_Menu_Team")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  if self.list_myteam:isEnabled() then
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_LocalTeamId == 0 or self.btn_menu_team.lightCircle then
    self:ShowTeamBoard()
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    self:ShowTeamBoard()
  end
end
function CMainMenu:OnBtn_Menu_Upgrade(btnObj, touchType)
  print("CMainMenu:OnBtn_Menu_Upgrade")
  self:ShowTishengBoard()
end
function CMainMenu:OnBtn_Menu_GM(btnObj, touchType)
  if channel.showGM == false then
    return
  end
  print("CMainMenu:OnBtn_Menu_GM")
  getCurSceneView():addSubView({
    subView = GmView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Doubleexp(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Doubleexp")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_DoubleExp)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  local teamerFlag = g_LocalPlayer:getNormalTeamer()
  if teamerFlag ~= true and g_LocalPlayer:getGuajiState() ~= GUAJI_STATE_OFF then
    TellSerToStopGuaji()
    return
  end
  ShowGuajiMenu()
end
function CMainMenu:OnBtn_Menu_Tool(btnObj, touchType)
  self:ShowBtnLightCircle(btnObj, false)
  print("CMainMenu:OnBtn_Menu_Tool")
  if not self.m_SimpleFlag then
    self:setAutoHideBtns(BtnHideTime)
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Beibao)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CMainRoleView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainMenu:OnBtn_Menu_Add(btnObj, touchType)
  if self.m_IsBtnAction or self.m_IsNewBtnAction then
    return
  end
  self:Action_MoveBtns(function()
    self:SetSimpleFlag(not self.m_SimpleFlag)
  end)
end
function CMainMenu:OnBtn_Menu_TopAdd(btnObj, touchType)
end
function CMainMenu:OnBtn_Menu_ShowWorldMap(btnObj, touchType)
  if not activity.yzdd:canJumpMap() then
    return false
  elseif not g_DuleMgr:canJumpMap() then
    return false
  elseif not activity.tiandiqishu:canJumpMap() then
    return false
  else
    getCurSceneView():addSubView({
      subView = CWorldMap.new(),
      zOrder = MainUISceneZOrder.menuView
    })
    return true
  end
end
function CMainMenu:OnBtn_Menu_LifeSkill(btnObj, touchType)
  ShowLifeSkillDetail()
end
function CMainMenu:OnBtn_Menu_JiaYiItem(btnObj, touchType)
  if g_LocalPlayer == nil then
    return
  end
  if g_LocalPlayer:GetJiaYiWanPetId() ~= nil then
    if self.m_JiaYiHelpDlg then
      self:ShowJiaYiView(false)
    else
      self:ShowJiaYiView(true)
    end
    return
  end
end
function CMainMenu:OnBtn_Menu_YZDD(btnObj, touchType)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr then
    if g_MapMgr:IsInYiZhanDaoDiMap() and activity.yzdd:getStatus() ~= 2 then
      ShowYiZhanDaoDiDlg()
    elseif g_MapMgr:IsInXueZhanShaChangMap() and activity.xzsc:getStatus() ~= 2 then
      ShowXueZhanShaChangDlg()
    end
  end
end
function CMainMenu:OnBtn_Menu_Dule()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr then
    local curTime = cc.net.SocketTCP.getTime()
    if self.m_LastClickDuleTime ~= nil and curTime - self.m_LastClickDuleTime < 1 then
      return
    end
    self.m_LastClickDuleTime = curTime
    if g_MapMgr:IsInDuelMap() then
      netsend.netactivity.getDuelMatchInfo()
    else
      netsend.netactivity.enterDuelScene()
    end
  end
end
function CMainMenu:checkBtnEntrancePos()
  local needAdjustBtns = {}
  for _, btn in ipairs({
    self.btn_yzdd,
    self.btn_dule,
    self.btn_bpwar,
    self.btn_satang
  }) do
    if btn ~= nil and btn:isVisible() and btn:isEnabled() then
      needAdjustBtns[#needAdjustBtns + 1] = btn
    end
  end
  if #needAdjustBtns > 0 then
    local l = 0
    for _, btn in pairs(needAdjustBtns) do
      local size = btn:getContentSize()
      l = l + size.width
    end
    local offx = 15
    local psize = self:getNode("layer_btn_entrance"):getSize()
    local x = psize.width / 2
    local y = 0
    l = l + (#needAdjustBtns - 1) * offx
    for _, btn in pairs(needAdjustBtns) do
      local size = btn:getContentSize()
      btn:setPosition(ccp(x + size.width / 2 - l / 2, y))
      x = x + size.width + offx
    end
  end
end
function CMainMenu:OnBtn_Menu_SaTang()
  local canSaTang = false
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    local txt = ""
    if self.m_SatangTime ~= nil then
      local curTime = cc.net.SocketTCP.getTime()
      local restTime = math.floor(3 - (curTime - self.m_SatangTime))
      if restTime <= 0 then
        canSaTang = true
      end
    else
      canSaTang = true
    end
  end
  if 0 >= g_HunyinMgr:GetXiTangRestTime() then
    canSaTang = true
  end
  if canSaTang then
    g_HunyinMgr:SaXiTang()
    self.m_SatangTime = cc.net.SocketTCP.getTime()
  end
end
function CMainMenu:OnBtn_Menu_ExtraExp()
  if self.m_ExtraExpHelpDlg then
    self:ShowExtraExpView(false)
  else
    self:ShowExtraExpView(true)
  end
end
function CMainMenu:OnBtn_Menu_ShowMiniMap(btnObj, touchType)
  local mapId = g_MapMgr:getCurMapId()
  if mapId ~= nil then
    local data = data_MapInfo[mapId]
    if data ~= nil then
      local miniMapfile = string.format("xiyou/mapbg/minicity/mini_%s.jpg", data.mapfile)
      local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(miniMapfile)
      if os.exists(fullPath) then
        getCurSceneView():addSubView({
          subView = CMiniMap.new(mapId, data),
          zOrder = MainUISceneZOrder.menuView
        })
        return true
      end
    end
  end
  return false
end
function CMainMenu:OnBtn_FreshGift(btnObj, touchType)
  ShowFreshGiftView()
end
function CMainMenu:OnBtn_BuyGift1(btnObj, touchType)
  if g_LocalPlayer then
    if g_LocalPlayer:JudgeCanPlayerGetXQSP() then
      ShowPopBuyGiftPopView(POP_Show_XIANQISUIPIAN)
    elseif g_LocalPlayer:JudgeCanGetPaiMaiShenShou() then
      ShowPopBuyGiftPopView(POP_Show_PAIMAITSSS)
    elseif g_LocalPlayer:JudgeCanGetChongZhiFanli() then
      ShowPopBuyGiftPopView(POP_Show_CHONGZHIFANLI)
    elseif g_LocalPlayer:JudgeCanGetXiaoFeiFanLi() then
      ShowPopBuyGiftPopView(POP_Show_XIAOFEIFANLI)
    elseif g_LocalPlayer:JudgeCanGetXianQiSuiPian() then
      ShowPopBuyGiftPopView(POP_Show_XIANQISUIPIAN)
    elseif g_LocalPlayer:JudgeCanGetBenZhouTeMai() then
      ShowPopBuyGiftPopView(POP_Show_CUXIAO)
    end
  end
end
function CMainMenu:OnBtn_PlayerOfMap(btnObj, touchType)
  if self.m_OnSelectPlayerOfMap == nil then
    self.btn_playerOfMap:setEnabled(false)
    self:ClearPlayerInfoOfMap()
    return
  end
  self:ClearPlayerInfoOfMap()
  if g_MapMgr:IsInBangPaiWarMap() then
    if self:IsTheSameBpWithLocalPlayer(self.m_OnSelectPlayerOfMap) then
      if g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
        return
      end
    else
      if g_TeamMgr:localPlayerIsCaptain() then
        g_BpWarMgr:send_launchBpFight(self.m_OnSelectPlayerOfMap)
        self:onSelectPlayerOfMap(nil)
      else
        ShowNotifyTips("只有队长才能发起战斗")
      end
      return
    end
  end
  self.m_PlayerInfoOfMap = CPlayerInfoOfMap.new(self.m_OnSelectPlayerOfMap, handler(self, self.OnPlayerOfMapClosed))
  self.pos_playerofmap:addChild(self.m_PlayerInfoOfMap:getUINode())
  local iSize = self.m_PlayerInfoOfMap:getContentSize()
  local size = self.pos_playerofmap:getContentSize()
  self.m_PlayerInfoOfMap:setPosition(ccp(size.width - iSize.width, size.height - iSize.height))
  self.m_PlayerInfoOfMap:adjustPos()
end
function CMainMenu:IsTheSameBpWithLocalPlayer(pid)
  local mapView = g_MapMgr:getMapViewIns()
  if mapView then
    local playerIns = mapView:getRole(pid)
    if playerIns then
      local bpId = playerIns:getBpId()
      if bpId ~= g_BpMgr:getLocalPlayerBpId() and not g_TeamMgr:IsPlayerOfLocalPlayerTeam(pid) then
        return false
      else
        return true
      end
    else
      return false
    end
  else
    return false
  end
end
function CMainMenu:OnPlayerOfMapClosed(obj)
  if self.m_PlayerInfoOfMap == obj then
    self.m_PlayerInfoOfMap = nil
  end
end
function CMainMenu:ClearPlayerInfoOfMap()
  if self.m_PlayerInfoOfMap then
    self.m_PlayerInfoOfMap:CloseSelf()
    self.m_PlayerInfoOfMap = nil
  end
end
function CMainMenu:SetSimpleFlag(simpleFlag)
  self.m_SimpleFlag = simpleFlag
  local btnPath = "views/mainviews/btn_menu_del.png"
  if simpleFlag == true then
    btnPath = "views/mainviews/btn_menu_add.png"
    self:ShowBtnRedIcon(self.btn_menu_add, true)
  else
    self:ShowBtnRedIcon(self.btn_menu_add, false)
  end
  self.btn_menu_add:loadTextureNormal(btnPath)
  self:SetBtnShow()
  if not self.m_SimpleFlag then
    self:setAutoHideBtns(BtnHideTime)
  else
    self:cancelAutoHideBtns()
  end
end
function CMainMenu:SetBtnShow()
  self.btn_menu_gm:setEnabled(channel.showGM ~= false)
  self.m_ShowLevelBtnFlag = self.m_IsDayantaShowBtn == true or self.m_IsTiantingShowBtn == true or self.m_IsTianDiQiShuShowBtn == true
  self.m_ShowExpBgFlag = self.m_ShowTTBtnFlag == true or self.m_IsTianDiQiShuShowBtn == true
  self.btn_menu_pet:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_pet and true)
  self.btn_menu_eqptupgrade:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_eqptupgrade and not self.m_SimpleFlag)
  self.btn_menu_guild:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_guild and not self.m_SimpleFlag)
  self.btn_menu_huoban:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_huoban and true)
  self.btn_menu_zuoqi:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_zuoqi and not self.m_SimpleFlag)
  self.btn_menu_skill:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_skill and not self.m_SimpleFlag)
  self.btn_menu_tool:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_tool and true)
  self.btn_menu_friend:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_friend and true)
  self.btn_menu_sociality:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_sociality and true)
  self.btn_menu_team:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_team and true)
  self.btn_menu_rank:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_rank and not self.m_ShowLevelBtnFlag and not self.m_TopSimpleFlag and not self.__BpWarStateInfoDlgIsShow)
  self.btn_menu_shop:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_shop and not self.m_TopSimpleFlag)
  self.btn_menu_market:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_market and not self.m_TopSimpleFlag)
  self.btn_menu_guanqia:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_guanqia and not self.m_ShowLevelBtnFlag and not self.m_TopSimpleFlag and not self.__BpWarStateInfoDlgIsShow)
  self.btn_menu_biwu:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_biwu and not self.m_ShowLevelBtnFlag and not self.m_TopSimpleFlag and not self.__BpWarStateInfoDlgIsShow)
  self.btn_menu_huodong:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_huodong and not self.m_ShowLevelBtnFlag and not self.m_TopSimpleFlag and not self.__BpWarStateInfoDlgIsShow)
  self:checkExtraExpFlag()
  self.pic_tt_expbg:setEnabled(self.m_ShowExpBgFlag)
  self.txt_tt_exp:setEnabled(self.m_ShowExpBgFlag)
  self.btn_tt_exit:setEnabled(self.m_ShowLevelBtnFlag)
  self.btn_menu_add:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_skill and true or not self.m_BtnNotOpenFlagDict.btn_menu_huoban and true or not self.m_BtnNotOpenFlagDict.btn_menu_zuoqi and true or not self.m_BtnNotOpenFlagDict.btn_menu_pet and true or not self.m_BtnNotOpenFlagDict.btn_menu_guild and true or not self.m_BtnNotOpenFlagDict.btn_menu_tool and true or not self.m_BtnNotOpenFlagDict.btn_menu_eqptupgrade and true)
  self.btn_menu_doubleexp:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_doubleexp and true)
  self.btn_menu_tisheng:setEnabled(self.m_ShowTishengBtn)
end
function CMainMenu:SetBtnPos()
  local tempDict = {
    {
      "btn_menu_shop",
      "btn_menu_market",
      "btn_menu_guanqia",
      "btn_menu_biwu",
      "btn_menu_rank",
      "btn_menu_huodong"
    },
    {
      "btn_menu_tisheng",
      "btn_menu_doubleexp"
    },
    {
      "btn_menu_friend",
      "btn_menu_sociality",
      "btn_voice_world",
      "btn_voice_bp",
      "btn_voice_team",
      "btn_menu_dailyword",
      "btn_menu_gm"
    },
    {
      "btn_menu_skill",
      "btn_menu_huoban",
      "btn_menu_zuoqi",
      "btn_menu_eqptupgrade",
      "btn_menu_guild"
    },
    {
      "btn_menu_tool"
    }
  }
  for _, btnList in ipairs(tempDict) do
    local posFlag = {}
    for _, btnName in ipairs(btnList) do
      if self.m_BtnNotOpenFlagDict[btnName] then
        local cp = self.m_Btn_ActionBtnOldPosDict[btnName]
        self.m_Btn_ActionBtnPosDict[btnName] = ccp(cp.x, cp.y)
      else
        for _, posBtnName in ipairs(btnList) do
          if posFlag[posBtnName] ~= true then
            local cp = self.m_Btn_ActionBtnOldPosDict[posBtnName]
            self.m_Btn_ActionBtnPosDict[btnName] = ccp(cp.x, cp.y)
            posFlag[posBtnName] = true
            break
          end
        end
      end
      local cp = self.m_Btn_ActionBtnPosDict[btnName]
      self[btnName]:setPosition(ccp(cp.x, cp.y))
    end
  end
  if self.m_SimpleFlag then
    local cp = self.m_Btn_ActionBtnOldPosDict.btn_menu_skill
    self.btn_menu_huoban:setPosition(ccp(cp.x, cp.y))
    local cp = self.m_Btn_ActionBtnOldPosDict.btn_menu_tool
    self.btn_menu_tool:setPosition(ccp(cp.x, cp.y))
  end
end
function CMainMenu:GetNewBtnPos()
  local returnDict = {}
  local tempDict = {
    {
      "btn_menu_pet"
    },
    {
      "btn_menu_shop",
      "btn_menu_market",
      "btn_menu_guanqia",
      "btn_menu_biwu",
      "btn_menu_rank",
      "btn_menu_huodong"
    },
    {
      "btn_menu_tisheng",
      "btn_menu_doubleexp"
    },
    {
      "btn_menu_friend",
      "btn_menu_sociality",
      "btn_voice_world",
      "btn_voice_bp",
      "btn_voice_team",
      "btn_menu_dailyword",
      "btn_menu_gm"
    },
    {
      "btn_menu_skill",
      "btn_menu_huoban",
      "btn_menu_zuoqi",
      "btn_menu_eqptupgrade",
      "btn_menu_guild"
    },
    {
      "btn_menu_tool"
    }
  }
  for _, btnList in ipairs(tempDict) do
    local posFlag = {}
    for _, btnName in ipairs(btnList) do
      local cp
      if self.m_BtnNotOpenFlagDict[btnName] then
        cp = self.m_Btn_ActionBtnOldPosDict[btnName]
      else
        for _, posBtnName in ipairs(btnList) do
          if posFlag[posBtnName] ~= true then
            cp = self.m_Btn_ActionBtnOldPosDict[posBtnName]
            posFlag[posBtnName] = true
            break
          end
        end
      end
      returnDict[btnName] = cp
    end
  end
  if self.m_SimpleFlag then
    local cp = self.m_Btn_ActionBtnOldPosDict.btn_menu_skill
    returnDict.btn_menu_huoban = cp
    local cp = self.m_Btn_ActionBtnOldPosDict.btn_menu_tool
    returnDict.btn_menu_tool = cp
  end
  return returnDict
end
function CMainMenu:Action_MoveBtns(callback1, callback2)
  self:stopAllActions()
  local delTime = BtnActionTime
  local delPos = BtnActionPos
  self.m_IsBtnAction = true
  for _, btnName in pairs(self.m_Btn_ActionBtnNameDict) do
    do
      local btn = self[btnName]
      btn:stopAllActions()
      local posOut = self.m_Btn_ActionBtnHidePos
      local posIn = self.m_Btn_ActionBtnPosDict[btnName]
      local actOut
      if self.m_SimpleFlag then
        if btnName == "btn_menu_huoban" then
          posIn = self.m_Btn_ActionBtnPosDict.btn_menu_skill
        end
        if btnName == "btn_menu_tool" then
          actOut = CCMoveTo:create(delTime, ccp(posIn.x + delPos, posIn.y))
        else
          actOut = CCMoveTo:create(delTime, ccp(posIn.x, posIn.y - delPos))
        end
      else
        actOut = CCMoveTo:create(delTime, posOut)
      end
      local actSetPos
      if self.m_SimpleFlag then
        actSetPos = CCCallFunc:create(function()
          btn:setPosition(ccp(posOut.x, posOut.y))
        end)
      else
        if btnName == "btn_menu_huoban" then
          posIn = self.m_Btn_ActionBtnPosDict.btn_menu_skill
        end
        actSetPos = CCCallFunc:create(function()
          if btnName == "btn_menu_tool" then
            btn:setPosition(ccp(posIn.x + delPos, posIn.y))
          else
            btn:setPosition(ccp(posIn.x, posIn.y - delPos))
          end
        end)
      end
      posIn = self.m_Btn_ActionBtnPosDict[btnName]
      if btnName == "btn_menu_huoban" then
        if self.m_SimpleFlag then
          posIn = self.m_Btn_ActionBtnPosDict.btn_menu_huoban
        else
          posIn = self.m_Btn_ActionBtnPosDict.btn_menu_skill
        end
      end
      local actIn = CCMoveTo:create(delTime, posIn)
      btn:runAction(transition.sequence({
        actOut,
        actSetPos,
        actIn
      }))
    end
  end
  local act1 = CCDelayTime:create(delTime)
  local act2
  if callback1 == nil then
    act2 = CCDelayTime:create(0)
  else
    act2 = CCCallFunc:create(callback1)
  end
  local act3 = CCDelayTime:create(delTime)
  local act4 = CCCallFunc:create(function()
    self.m_IsBtnAction = false
  end)
  local act5
  if callback2 == nil then
    act5 = CCDelayTime:create(0)
  else
    act5 = CCCallFunc:create(callback2)
  end
  self:runAction(transition.sequence({
    act1,
    act2,
    act3,
    act4,
    act5
  }))
end
function CMainMenu:Clear()
  self:MissionClear()
  self:TeamClear()
  self:QuickUseBoardClear()
  if g_CMainMenuHandler == self then
    g_CMainMenuHandler = nil
  end
  self:cancelAutoHideBtns()
end
function CMainMenu:InitOnlineReward()
  self.txt_giftCountDown = self:getNode("txt_giftCountDown")
  self.pic_giftCountDownBg = self:getNode("pic_giftCountDownBg")
  self.txt_freshGiftTime = self:getNode("txt_freshgifttime")
  self.txt_BuyGift1Time = self:getNode("txt_buygift1time")
  self.m_CdTime = -1
  self:reflushOnlineReward()
  self:FreshRewardUpdate()
  self:ListenMessage(MsgID_Gift)
end
function CMainMenu:reflushOnlineReward()
  local rId = gift.online:getRewardId()
  if data_GiftOfOnline[rId] == nil then
    self.txt_giftCountDown:setText("")
    self.pic_giftCountDownBg:setVisible(false)
    return
  end
  local nextCmpTime = gift.online:getNextCmpTime()
  local svrTime = g_DataMgr:getServerTime()
  self.m_CdTime = nextCmpTime - svrTime
  if self.m_CdTime < 0 or nextCmpTime < 0 or svrTime < 0 then
    self.txt_giftCountDown:setVisible(true)
    self.pic_giftCountDownBg:setVisible(true)
    self.txt_giftCountDown:setText("可领取")
    return
  end
  self.m_CdLastShowTime = -1
  self.txt_giftCountDown:setVisible(true)
  self.pic_giftCountDownBg:setVisible(true)
  self:reflushOnlineRewardTime()
end
function CMainMenu:reflushOnlineRewardTime()
  if self.m_CdTime <= 0 then
    self.txt_giftCountDown:setVisible(false)
    self.pic_giftCountDownBg:setVisible(false)
    SendMessage(MsgID_Gift_OnlineRewardTimesUp)
  else
    self.pic_giftCountDownBg:setVisible(true)
    local ct = checkint(self.m_CdTime)
    if ct ~= self.m_CdLastShowTime then
      self.m_CdLastShowTime = ct
      local h, m, s = getHMSWithSeconds(ct)
      if h > 0 then
        self.txt_giftCountDown:setText(string.format("%02d:%02d:%02d", h, m, s))
      else
        self.txt_giftCountDown:setText(string.format("%02d:%02d", m, s))
      end
    end
  end
end
function CMainMenu:OnlineRewardUpdate(dt)
  local oldCD = self.m_CdTime
  if self.m_CdTime >= 0 then
    self.m_CdTime = self.m_CdTime - dt
    self:reflushOnlineRewardTime()
  end
  if oldCD >= 0 and self.m_CdTime <= 0 then
    self:reflushOnlineReward()
  end
end
function CMainMenu:FreshRewardUpdate(dt)
  local showFreshBtnFlag = true
  if gift.special:hasGetFreshGift() then
    showFreshBtnFlag = false
  end
  local showCuXiaoFlag = false
  local inMomoFanLiTimeFlag = false
  local canBuyWeeklyItemFlag = false
  local paiMaiTSSSFlag = false
  local xiaoFeiFanLiTimeFlag = false
  local getXQSPFlag = false
  if g_LocalPlayer then
    inMomoFanLiTimeFlag = g_LocalPlayer:JudgeCanGetChongZhiFanli()
    canBuyWeeklyItemFlag = g_LocalPlayer:JudgeCanGetBenZhouTeMai()
    paiMaiTSSSFlag = g_LocalPlayer:JudgeCanGetPaiMaiShenShou()
    xiaoFeiFanLiTimeFlag = g_LocalPlayer:JudgeCanGetXiaoFeiFanLi()
    getXQSPFlag = g_LocalPlayer:JudgeCanGetXianQiSuiPian()
  end
  showCuXiaoFlag = canBuyWeeklyItemFlag or inMomoFanLiTimeFlag or paiMaiTSSSFlag or xiaoFeiFanLiTimeFlag or getXQSPFlag
  if showFreshBtnFlag == false then
    local x, y = self.btn_freshgift:getPosition()
    self.btn_buygift1:setPosition(ccp(x, y))
  end
  local btn = self.btn_buygift1
  if showCuXiaoFlag and btn:isEnabled() == false then
    btn:setEnabled(true)
  elseif showCuXiaoFlag == false and btn:isEnabled() == true then
    btn:setEnabled(false)
  end
  local cuxiaoLightFlag = false
  if g_LocalPlayer then
    cuxiaoLightFlag = g_LocalPlayer:JudgeCanPlayerGetXQSP()
  end
  self:ShowBtnLightCircle(btn, cuxiaoLightFlag)
  if showCuXiaoFlag then
    if not data_Shop_ChongZhi[WEEKLY_SHOP_ITEM_LIST[1]].clientEndTime then
      local endTimeList = {
        1970,
        1,
        1,
        0,
        0,
        0
      }
    end
    local bztmEndTime = os.time({
      year = endTimeList[1],
      month = endTimeList[2],
      day = endTimeList[3],
      hour = endTimeList[4],
      min = endTimeList[5],
      sec = endTimeList[6]
    })
    local _, czflEndTime = g_LocalPlayer:getMoMoChongZhiFanliTime()
    local _, pmssEndTime = g_LocalPlayer:getPaiMaiShenShouTime()
    local _, xfflEndTime = g_LocalPlayer:getXiaoFeiFanLiTime()
    local _, getXQSPEndTime = g_LocalPlayer:getGetXianQiSuiPianTime()
    local curTime = g_DataMgr:getServerTime()
    local endTime
    if canBuyWeeklyItemFlag and bztmEndTime ~= nil then
      if endTime == nil then
        endTime = bztmEndTime
      elseif bztmEndTime < endTime then
        endTime = bztmEndTime
      end
    end
    if inMomoFanLiTimeFlag and czflEndTime ~= nil then
      if endTime == nil then
        endTime = czflEndTime
      elseif czflEndTime < endTime then
        endTime = czflEndTime
      end
    end
    if paiMaiTSSSFlag and pmssEndTime ~= nil then
      if endTime == nil then
        endTime = pmssEndTime
      elseif pmssEndTime < endTime then
        endTime = pmssEndTime
      end
    end
    if xiaoFeiFanLiTimeFlag and xfflEndTime ~= nil then
      if endTime == nil then
        endTime = xfflEndTime
      elseif xfflEndTime < endTime then
        endTime = xfflEndTime
      end
    end
    if getXQSPFlag and getXQSPEndTime ~= nil then
      if endTime == nil then
        endTime = getXQSPEndTime
      elseif getXQSPEndTime < endTime then
        endTime = getXQSPEndTime
      end
    end
    if endTime ~= nil then
      local restTime = endTime - curTime
      if restTime < 0 then
        restTime = 0
      end
      local d = math.floor(restTime / 3600 / 24)
      local h = math.floor(restTime / 3600 % 24)
      local m = math.floor(restTime % 3600 / 60)
      local s = math.floor(restTime % 60)
      if d > 0 then
        self.txt_BuyGift1Time:setText(string.format("%d天", d))
      elseif h > 0 then
        self.txt_BuyGift1Time:setText(string.format("%02d:%02d:%02d", h, m, s))
      else
        self.txt_BuyGift1Time:setText(string.format("%02d:%02d", m, s))
      end
    end
  end
  local btn = self.btn_freshgift
  if showFreshBtnFlag and btn:isEnabled() == false then
    btn:setEnabled(true)
  elseif showFreshBtnFlag == false and btn:isEnabled() == true then
    btn:setEnabled(false)
  end
  if showFreshBtnFlag then
    if gift.special:canGetFreshGift() == true then
      self.txt_freshGiftTime:setText("可领取")
      if btn.lightCircle == nil then
        self:ShowBtnLightCircle(btn, true)
      end
    else
      if btn.lightCircle ~= nil then
        self:ShowBtnLightCircle(btn, false)
      end
      local ct = gift.special:getFreshGiftRestTime()
      local h, m, s = getHMSWithSeconds(ct)
      if h > 0 then
        self.txt_freshGiftTime:setText(string.format("%02d:%02d:%02d", h, m, s))
      else
        self.txt_freshGiftTime:setText(string.format("%02d:%02d", m, s))
      end
    end
  end
end
function CMainMenu:InitQuickUseBoard()
  self.m_QuickUseBoard = nil
  self.m_QuickUseList = {}
end
function CMainMenu:QuickUseBoardClear()
  if self.m_QuickUseBoard ~= nil then
    self.m_QuickUseBoard:removeFromParent()
  end
  self.m_QuickUseBoard = nil
end
function CMainMenu:reflushQuickUseBoardZOrder()
  if self.m_QuickUseBoard ~= nil then
    local z
    if g_FubenHandler ~= nil then
      z = MainUISceneZOrder.fubenQuickUseView
    else
      z = MainUISceneZOrder.mainmenuQuickUseView
    end
    getCurSceneView():ReOrderSubView(self.m_QuickUseBoard, z)
  end
end
function CMainMenu:setTaskAndTeamBoardAddToMainMenu()
end
function CMainMenu:setTaskAndTeamBoardAddToWarUi()
end
function CMainMenu:canUseItemOnQuickUseBoard(objType, objId)
  local canUseFlag = true
  if g_LocalPlayer == nil then
    return false
  end
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    return false
  end
  if objType == BoxOpenType_Item then
    canUseFlag = false
    local obj = g_LocalPlayer:GetOneItem(objId)
    if obj ~= nil then
      local itemType = obj:getType()
      local itemTypeId = obj:getTypeId()
      if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI then
        if g_LocalPlayer:GetRoleIdFromItem(objId) == nil then
          local eqptType = obj:getProperty(ITEM_PRO_EQPT_TYPE)
          local eqptPos = EPQT_TYPE_2_EQPT_POS[eqptType]
          local tempHero = g_LocalPlayer:getMainHero()
          local msg = tempHero:CanAddItem(objId)
          local oldObj = tempHero:GetEqptByPos(eqptPos)
          if msg == true then
            if oldObj == nil then
              canUseFlag = true
            else
              local oldType = oldObj:getType()
              local oldLv = oldObj:getProperty(ITEM_PRO_LV)
              local newType = obj:getType()
              local newLv = obj:getProperty(ITEM_PRO_LV)
              if oldType < newType then
                canUseFlag = true
              elseif newType == oldType and oldLv < newLv then
                canUseFlag = true
              end
            end
          end
        end
      elseif itemType == ITEM_LARGE_TYPE_GIFT then
        canUseFlag = true
      elseif itemTypeId == ITEM_DEF_OTHER_SBD then
        local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_DoubleExp)
        canUseFlag = openFlag
      elseif itemTypeId == ITEM_DEF_OTHER_XPT or itemTypeId == ITEM_DEF_OTHER_PT or itemTypeId == ITEM_DEF_OTHER_PTW then
        local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
        local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
        canUseFlag = false
        for _, skillType in pairs(mainRole:getSkillTypeList()) do
          local skillList = data_getSkillListByAttr(skillType)
          for j = 1, 5 do
            local skillID = skillList[j]
            if j >= 3 then
              local skillExp = mainRole:getProficiency(skillID)
              local pLimit = data_getSkillExpLimitByZsAndLv(zs, lv)
              if pLimit == nil then
                pLimit = CalculateSkillProficiency(zs)
              end
              if skillExp < pLimit then
                canUseFlag = true
              end
            end
          end
        end
      elseif itemTypeId == ITEM_DEF_OTHER_RS or itemTypeId == ITEM_DEF_OTHER_RSG or itemTypeId == ITEM_DEF_OTHER_RSGW then
        local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
        local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
        canUseFlag = data_getItemCanUseJudgeLevel(itemTypeId, zs, lv)
      else
        for _, tempId in pairs(QuickUseItemList) do
          if tempId == itemTypeId then
            canUseFlag = true
            break
          end
        end
        if canUseFlag == false then
          local hasPetFlag = false
          local petId = mainRole:getProperty(PROPERTY_PETID)
          if petId ~= nil and petId ~= 0 then
            hasPetFlag = true
          end
          if hasPetFlag then
            for _, tempId in pairs(QuickUseItemList_Pet) do
              if tempId == itemTypeId then
                canUseFlag = true
                break
              end
            end
          end
        end
      end
    end
  elseif objType == BoxOpenType_Pet then
    local petId = mainRole:getProperty(PROPERTY_PETID)
    if petId ~= nil and petId ~= 0 then
      canUseFlag = false
    end
    local tempPetIns = g_LocalPlayer:getObjById(objId)
    if tempPetIns == nil then
      canUseFlag = false
    end
  elseif objType == BoxOpenType_Hero then
    local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
    local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
    local warsetting = g_LocalPlayer:getWarSetting()
    local warNum = 0
    for _, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      if warsetting[pos] ~= nil then
        warNum = warNum + 1
      end
    end
    if warNum >= data_getWarNumLimit(zs, lv) + 1 then
      canUseFlag = false
    end
  end
  return canUseFlag
end
function CMainMenu:addItemToQuickUseBoard(objType, objId)
  print("addItemToQuickUseBoard")
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    printLog("ERROR", "刷新快速使用面板的时候，找不到主英雄1")
    return
  end
  for i, data in pairs(self.m_QuickUseList) do
    if data.objType == objType and data.objId == objId then
      return
    end
  end
  if not self:canUseItemOnQuickUseBoard(objType, objId) then
    return
  end
  self.m_QuickUseList[#self.m_QuickUseList + 1] = {objType = objType, objId = objId}
  self:reflushQuickUseBoard()
end
function CMainMenu:delItemFromQuickUseBoard(objType, objId)
  print("delItemFromQuickUseBoard")
  local delFlag = false
  for i, data in pairs(self.m_QuickUseList) do
    if data.objType == objType and data.objId == objId then
      table.remove(self.m_QuickUseList, i)
      delFlag = true
      break
    end
  end
  if delFlag then
    self:reflushQuickUseBoard()
  end
end
function CMainMenu:reflushQuickUseBoard()
  print("reflushQuickUseBoard")
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    printLog("ERROR", "刷新快速使用面板的时候，找不到主英雄3")
    if self.m_QuickUseBoard then
      self.m_QuickUseBoard:removeFromParent()
      self.m_QuickUseBoard = nil
    end
    self:InitQuickUseBoard()
    return
  end
  local delList = {}
  for i, data in pairs(self.m_QuickUseList) do
    if not self:canUseItemOnQuickUseBoard(data.objType, data.objId) then
      delList[#delList + 1] = {
        objType = data.objType,
        objId = data.objId
      }
    end
  end
  for _, delData in pairs(delList) do
    for i, data in pairs(self.m_QuickUseList) do
      if data.objType == delData.objType and data.objId == delData.objId then
        table.remove(self.m_QuickUseList, i)
        break
      end
    end
  end
  local compareQuickUseItem = function(p1, p2)
    if p1 == nil or p2 == nil then
      return false
    end
    local objType1 = p1.objType
    local objId1 = p1.objId
    local objType2 = p2.objType
    local objId2 = p2.objId
    local TempDict = {
      [BoxOpenType_Item] = 1,
      [BoxOpenType_Pet] = 2,
      [BoxOpenType_Hero] = 3
    }
    local typeNum1 = TempDict[objType1] or 0
    local typeNum2 = TempDict[objType2] or 0
    if typeNum1 ~= typeNum2 then
      return typeNum1 > typeNum2
    elseif objType1 == BoxOpenType_Pet then
      local pet1 = g_LocalPlayer:getObjById(objId1)
      local pet2 = g_LocalPlayer:getObjById(objId2)
      if pet1 == nil then
        return false
      end
      if pet2 == nil then
        return true
      end
      local petLv1 = data_getPetLevelType(pet1:getTypeId())
      local petLv2 = data_getPetLevelType(pet2:getTypeId())
      return petLv1 > petLv2
    elseif objType1 == BoxOpenType_Item then
      local item1 = g_LocalPlayer:GetOneItem(objId1)
      local item2 = g_LocalPlayer:GetOneItem(objId2)
      local itemType1 = item1:getType()
      local itemType2 = item2:getType()
      local tempDict = {
        [ITEM_LARGE_TYPE_SHENBING] = 10,
        [ITEM_LARGE_TYPE_XIANQI] = 9,
        [ITEM_LARGE_TYPE_SENIOREQPT] = 8,
        [ITEM_LARGE_TYPE_EQPT] = 7,
        [ITEM_LARGE_TYPE_GIFT] = 6
      }
      local v1 = tempDict[itemType1] or 0
      local v2 = tempDict[itemType2] or 0
      if v1 == v2 then
        local l1 = item1:getProperty(ITEM_PRO_LV)
        local l2 = item2:getProperty(ITEM_PRO_LV)
        if l1 == l2 then
          local itemTypeId1 = item1:getTypeId()
          local itemTypeId2 = item2:getTypeId()
          return itemTypeId1 > itemTypeId2
        else
          return l1 > l2
        end
      else
        return v1 > v2
      end
    elseif objType1 == BoxOpenType_Hero then
      local hero_1 = g_LocalPlayer:getObjById(objId1)
      local hero_2 = g_LocalPlayer:getObjById(objId2)
      local openindex_1 = -1
      local openindex_2 = -1
      local mainHero = g_LocalPlayer:getMainHero()
      local zsList = mainHero:getProperty(PROPERTY_ZSTYPELIST)
      if type(zsList) ~= "table" then
        zsList = {}
      end
      local mainHeroType = zsList[1] or 0
      if mainHeroType == 0 then
        mainHeroType = mainHero:getTypeId()
      end
      local shapeList = data_getAllJiuguanRole(mainHeroType)
      for index, shape in ipairs(shapeList) do
        if shape == hero_1:getTypeId() then
          openindex_1 = index
        end
        if shape == hero_2:getTypeId() then
          openindex_2 = index
        end
      end
      if openindex_1 ~= openindex_2 then
        return openindex_1 > openindex_2
      end
      return objId1 < objId2
    else
      return false
    end
  end
  table.sort(self.m_QuickUseList, compareQuickUseItem)
  local firstItemData = self.m_QuickUseList[1]
  if firstItemData == nil then
    if self.m_QuickUseBoard then
      self.m_QuickUseBoard:removeFromParent()
    end
    self.m_QuickUseBoard = nil
  elseif self.m_QuickUseBoard then
    self.m_QuickUseBoard:reSetData(firstItemData.objType, firstItemData.objId)
  else
    self.m_QuickUseBoard = CQuickUseBoard.new(firstItemData.objType, firstItemData.objId)
    local x, y = self:getNode("pos_quickuseitem"):getPosition()
    local z
    if g_FubenHandler ~= nil then
      z = MainUISceneZOrder.fubenQuickUseView
    else
      z = MainUISceneZOrder.mainmenuQuickUseView
    end
    getCurSceneView():addSubView({
      subView = self.m_QuickUseBoard,
      zOrder = z
    })
    self.m_QuickUseBoard:setPosition(ccp(x, y))
    self:ShowQuickUseBoard()
  end
end
function CMainMenu:ShowQuickUseBoard()
  local showFlag = true
  if self.m_LevelUpAniNode ~= nil then
    showFlag = false
  end
  if g_CBTView then
    showFlag = false
  end
  if g_GoldBoxView then
    showFlag = false
  end
  if self.m_QuickUseBoard then
    self.m_QuickUseBoard:setEnabled(showFlag)
  end
end
function CMainMenu:updatePetLvBg()
  if self.m_IsNewBtnAction then
    return
  end
  local showFlag = true
  local hasPetFlag = false
  local mainRole = g_LocalPlayer:getMainHero()
  local petId
  if mainRole ~= nil then
    petId = mainRole:getProperty(PROPERTY_PETID)
    if petId ~= nil and petId ~= 0 then
      hasPetFlag = true
    end
  else
    showFlag = false
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhaohuanshou)
  if openFlag == false then
    showFlag = false
  end
  self:getNode("pic_levelbg_pet"):setVisible(showFlag)
  self:getNode("txt_level_pet"):setVisible(showFlag)
  if hasPetFlag then
    self:getNode("pic_pet_hp"):setVisible(true)
    self:getNode("pic_pet_mp"):setVisible(true)
    self:getNode("txt_level_pet"):setVisible(showFlag)
    local petIns = g_LocalPlayer:getObjById(petId)
    if petIns ~= nil then
      local heroZs = zs
      local petZs = petIns:getProperty(PROPERTY_ZHUANSHENG)
      local petLv = petIns:getProperty(PROPERTY_ROLELEVEL)
      self:getNode("txt_level_pet"):setText(string.format("%d转%d", petZs, petLv))
      local hp = petIns:getProperty(PROPERTY_HP)
      local maxHp = petIns:getMaxProperty(PROPERTY_HP)
      local mp = petIns:getProperty(PROPERTY_MP)
      local maxMp = petIns:getMaxProperty(PROPERTY_MP)
      self:getNode("pic_pet_hp"):setPercent(hp / maxHp * 100)
      self:getNode("pic_pet_mp"):setPercent(mp / maxMp * 100)
    end
    if self.m_AddPetIconSprite then
      self.m_AddPetIconSprite:removeFromParent()
      self.m_AddPetIconSprite = nil
    end
    if self.m_AddPetHeadSprite ~= nil then
      self.m_AddPetHeadSprite:removeFromParent()
      self.m_AddPetHeadSprite = nil
    end
    if petIns ~= nil then
      local typeId = petIns:getTypeId()
      local head = createHeadIconByRoleTypeID(typeId)
      local temp = self.btn_menu_pet:getVirtualRenderer()
      local size = temp:getContentSize()
      temp:addChild(head)
      head:setPosition(ccp(size.width / 2, size.height / 2 + 8))
      head:setScale(0.8)
      self.m_AddPetHeadSprite = head
    end
  else
    self:getNode("pic_pet_hp"):setVisible(false)
    self:getNode("pic_pet_mp"):setVisible(false)
    self:getNode("txt_level_pet"):setVisible(false)
    if self.m_AddPetHeadSprite then
      self.m_AddPetHeadSprite:removeFromParent()
      self.m_AddPetHeadSprite = nil
    end
    if self.m_AddPetIconSprite == nil then
      local icon = display.newSprite("views/rolelist/equipcanadd.png")
      local temp = self.btn_menu_pet:getVirtualRenderer()
      local size = temp:getContentSize()
      temp:addChild(icon)
      icon:setPosition(ccp(size.width / 2, size.height / 2))
      self.m_AddPetIconSprite = icon
    end
  end
end
function CMainMenu:updateBtnOpenFlagDict()
  print("updateBtnOpenFlagDict", self.m_IsNewBtnAction)
  if self.m_IsNewBtnAction then
    return
  end
  local tempDict = {
    [OPEN_Func_EqptUpgrade] = {
      "btn_menu_eqptupgrade",
      "views/mainviews/btn_eqptupgrade.png",
      "views/mainviews/btn_eqptupgrade_gray.png"
    },
    [OPEN_Func_Shaofa] = {
      "btn_menu_skill",
      "views/mainviews/btn_skill.png",
      "views/mainviews/btn_skill_gray.png"
    },
    [OPEN_Func_Zhaohuanshou] = {
      "btn_menu_pet",
      "views/mainviews/btn_pet.png",
      "views/mainviews/btn_pet_gray.png"
    },
    [OPEN_Func_Jiuguan] = {
      "btn_menu_huoban",
      "views/mainviews/btn_huoban.png",
      "views/mainviews/btn_huoban_gray.png"
    },
    [OPEN_Func_Beibao] = {
      "btn_menu_tool",
      "views/mainviews/btn_tool.png",
      "views/mainviews/btn_tool_gray.png"
    },
    [OPEN_Func_Zuoqi] = {
      "btn_menu_zuoqi",
      "views/mainviews/btn_zuoqi.png",
      "views/mainviews/btn_zuoqi_gray.png"
    },
    [OPEN_Func_BangPai] = {
      "btn_menu_guild",
      "views/mainviews/btn_guild.png",
      "views/mainviews/btn_guild_gray.png"
    },
    [OPEN_Func_Rank] = {
      "btn_menu_rank",
      "views/mainviews/btn_rank.png",
      "views/mainviews/btn_rank_gray.png"
    },
    [OPEN_Func_Friend] = {
      "btn_menu_friend",
      "views/mainviews/btn_friend.png",
      "views/mainviews/btn_friend_gray.png"
    },
    [OPEN_Func_Shejiao] = {
      "btn_menu_sociality",
      "views/mainviews/btn_shejiao.png",
      "views/mainviews/btn_shejiao_gray.png"
    },
    [OPEN_Func_Duiwu] = {
      "btn_menu_team",
      "views/mainviews/btn_team.png",
      "views/mainviews/btn_team_gray.png"
    },
    [OPEN_Func_Biwu] = {
      "btn_menu_biwu",
      "views/mainviews/btn_biwu.png",
      "views/mainviews/btn_biwu_gray.png"
    },
    [OPEN_Func_Shangcheng] = {
      "btn_menu_shop",
      "views/mainviews/btn_shangcheng.png",
      "views/mainviews/btn_shangcheng_gray.png"
    },
    [OPEN_Func_Guanqia] = {
      "btn_menu_guanqia",
      "views/mainviews/btn_guanqia.png",
      "views/mainviews/btn_guanqia_gray.png"
    },
    [OPEN_Func_Market] = {
      "btn_menu_market",
      "views/mainviews/btn_market.png",
      "views/mainviews/btn_market_gray.png"
    },
    [OPEN_Func_DoubleExp] = {
      "btn_menu_doubleexp",
      "views/mainviews/btn_doubleexp.png",
      "views/mainviews/btn_doubleexp_gray.png"
    }
  }
  local needToMoveBtns = false
  local needToMoveTopBtns = false
  local newAddBtnList = {}
  for funcId, data in pairs(tempDict) do
    local btnName = data[1]
    local nPath = data[2]
    local gPath = data[3]
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(funcId)
    local btn = self[btnName]
    local isRightDownBtnFlag = false
    for _, tempName in pairs(self.m_Btn_ActionBtnNameDict) do
      if btnName == tempName then
        isRightDownBtnFlag = true
        break
      end
    end
    local isTopBtnFlag = false
    for _, tempName in pairs(self.m_Btn_ActionTopBtnNameDict) do
      if btnName == tempName then
        isTopBtnFlag = true
        break
      end
    end
    local isNeedSetPosBtnFlag = false
    for _, tempName in pairs(self.m_Btn_AllSetPosBtnNameDict) do
      if btnName == tempName then
        isNeedSetPosBtnFlag = true
        break
      end
    end
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Hide then
        self.m_BtnNotOpenFlagDict[btnName] = true
      elseif noOpenType == OPEN_FUNC_Type_Gray then
        btn:loadTextureNormal(gPath)
      end
    elseif noOpenType == OPEN_FUNC_Type_Hide then
      if self.m_BtnNotOpenFlagDict[btnName] ~= false then
        if isRightDownBtnFlag then
          needToMoveBtns = true
        end
        if isTopBtnFlag then
          needToMoveTopBtns = true
        end
        if isNeedSetPosBtnFlag then
          newAddBtnList[#newAddBtnList + 1] = btnName
          if self.m_NotShowRightBottomFlag ~= true then
            self:ShowBtnLightCircle(self[btnName], true)
          end
        end
      end
      self.m_BtnNotOpenFlagDict[btnName] = false
    elseif noOpenType == OPEN_FUNC_Type_Gray then
      btn:loadTextureNormal(nPath)
    end
  end
  self:ShowNewBtnAction(newAddBtnList, needToMoveBtns, needToMoveTopBtns)
end
function CMainMenu:ShowNewBtnAction(newAddBtnList, needToMoveBtns, needToMoveTopBtns)
  if self.m_NotShowRightBottomFlag == true then
    self:SetFlagAfterNewBtnAction()
    return
  end
  if #newAddBtnList == 0 then
    self:SetFlagAfterNewBtnAction()
    return
  end
  self:SwallowMessageForNewBtnAction(true)
  if needToMoveBtns then
    self:SetSimpleFlag(false)
    local cp = self.m_Btn_ActionBtnPosDict.btn_menu_tool
    self.btn_menu_tool:setPosition(ccp(cp.x, cp.y))
    local cp = self.m_Btn_ActionBtnPosDict.btn_menu_huoban
    self.btn_menu_huoban:setPosition(ccp(cp.x, cp.y))
  end
  self:SetBtnShow()
  local actionTime = NewBtnActionMoveTime
  local fadeInTime = NewBtnActionFadeTime
  local scaleTime = NewBtnActionScaleTime
  local lvupAniTime = 3
  local newPosDict = self:GetNewBtnPos()
  local index = 1
  for _, newBtnName in pairs(self.m_Btn_AllSetPosBtnNameDict) do
    do
      local btn = self[newBtnName]
      btn:stopAllActions()
      local ActionList = {}
      local isNewAddBtn = false
      for _, temp in pairs(newAddBtnList) do
        if temp == newBtnName then
          isNewAddBtn = true
          break
        end
      end
      if isNewAddBtn then
        btn:setPosition(ccp(9999999, 9999999))
        do
          local initDelay = CCDelayTime:create(lvupAniTime)
          local fadeOut = CCFadeOut:create(0)
          local tempIndex = index
          local setP = CCCallFunc:create(function()
            local delX, delY = self:GetNewBtnDelPos(tempIndex, #newAddBtnList)
            local worldPos = self:getUINode():convertToWorldSpace(ccp(display.width / 2 + delX, display.height / 2 + delY))
            local p = btn:getParent()
            local cp = p:convertToNodeSpace(worldPos)
            btn:setPosition(ccp(cp.x, cp.y))
          end)
          btn:setScale(0)
          local fadeIn = CCFadeIn:create(fadeInTime)
          local num = 5
          local scale1 = CCScaleTo:create(scaleTime / num, 1.5)
          local scale2 = CCScaleTo:create(scaleTime / num, 1)
          local wait = CCDelayTime:create(scaleTime / num * (num - 2))
          ActionList = {
            initDelay,
            fadeOut,
            setP,
            fadeIn,
            scale1,
            scale2,
            wait
          }
          index = index + 1
        end
      else
        local action = CCDelayTime:create(fadeInTime + scaleTime)
        ActionList[#ActionList + 1] = action
      end
      local x, y = btn:getPosition()
      local newCp = newPosDict[newBtnName]
      if newCp ~= nil and (newCp.x ~= x or newCp.y ~= y) then
        local action = CCEaseOut:create(CCMoveTo:create(actionTime, ccp(newCp.x, newCp.y)), 2.5)
        ActionList[#ActionList + 1] = action
      end
      if #ActionList ~= 0 then
        if isNewAddBtn then
          local wait = CCDelayTime:create(NewBtnActionCircleEff)
          ActionList[#ActionList + 1] = wait
          local action_cb = CCCallFunc:create(function()
            self:ShowBtnLightCircle(btn, false)
          end)
          ActionList[#ActionList + 1] = action_cb
        end
        btn:runAction(transition.sequence(ActionList))
      end
    end
  end
  local newOpenImg = display.newSprite("xiyou/pic/pic_opennewfunc.png")
  self:getUINode():addNode(newOpenImg)
  newOpenImg:setPosition(ccp(9999999, 9999999))
  newOpenImg:setScale(0)
  local initDelay = CCDelayTime:create(lvupAniTime)
  local fadeOut = CCFadeOut:create(0)
  local setP = CCCallFunc:create(function()
    local delX, delY = self:GetNewBtnOpenFuncDelPos(#newAddBtnList)
    local worldPos = self:getUINode():convertToWorldSpace(ccp(display.width / 2 + delX, display.height / 2 + delY))
    local p = newOpenImg:getParent()
    local cp = p:convertToNodeSpace(worldPos)
    newOpenImg:setPosition(ccp(cp.x, cp.y))
  end)
  local fadeIn = CCFadeIn:create(fadeInTime)
  local num = 5
  local scale1 = CCScaleTo:create(scaleTime / num, 1.5)
  local scale2 = CCScaleTo:create(scaleTime / num, 1)
  local wait = CCDelayTime:create(scaleTime / num * (num - 2) + actionTime)
  local delNewOpenImg = CCCallFunc:create(function()
    newOpenImg:removeFromParentAndCleanup(true)
  end)
  ActionList = {
    initDelay,
    fadeOut,
    setP,
    fadeIn,
    scale1,
    scale2,
    wait,
    delNewOpenImg
  }
  newOpenImg:runAction(transition.sequence(ActionList))
  local delay = CCDelayTime:create(lvupAniTime + actionTime + fadeInTime + scaleTime)
  local call = CCCallFunc:create(function()
    self:SwallowMessageForNewBtnAction(false)
    self:updateBtnOpenFlagDict()
    self:updatePetLvBg()
  end)
  self:stopAllActions()
  self:runAction(transition.sequence({delay, call}))
end
function CMainMenu:SwallowMessageForNewBtnAction(flag)
  self.m_IsNewBtnAction = flag
end
function CMainMenu:GetNewBtnDelPos(index, sumNum)
  local DelOneW = 100
  local DelOneH = 100
  local PerLineNum = 5
  if index > 15 or sumNum < index or index <= 0 then
    return 0, 0
  end
  function getX(i, s)
    if s % 2 == 0 then
      local mid = s / 2
      return (i - mid) * DelOneW - DelOneW / 2
    else
      local mid = math.floor(s / 2 + 1)
      return (i - mid) * DelOneW
    end
  end
  function getY(i, s)
    if s % 2 == 0 then
      local mid = s / 2
      return -((i - mid) * DelOneH - DelOneH / 2)
    else
      local mid = math.floor(s / 2 + 1)
      return -((i - mid) * DelOneH)
    end
  end
  local sumLineNum = math.floor((sumNum - 1) / PerLineNum + 1)
  local lineNum = math.floor((index - 1) / PerLineNum + 1)
  local delY = getY(lineNum, sumLineNum)
  local sumINum = PerLineNum
  if lineNum == sumLineNum then
    sumINum = sumNum % PerLineNum
    if sumINum == 0 then
      sumINum = PerLineNum
    end
  end
  local iNum = index % PerLineNum
  if iNum == 0 then
    iNum = PerLineNum
  end
  local delX = getX(iNum, sumINum)
  return delX, delY
end
function CMainMenu:GetNewBtnOpenFuncDelPos(sumNum)
  local PerLineNum = 5
  local sumLineNum = math.floor((sumNum - 1) / PerLineNum + 1)
  return 0, -(50 * sumLineNum) - 30
end
function CMainMenu:SetFlagAfterNewBtnAction()
  print("SetFlagAfterNewBtnAction")
  self:SetBtnShow()
  self:SetBtnPos()
  self.m_NotShowRightBottomFlag = false
  self:SwallowMessageForNewBtnAction(false)
end
function CMainMenu:setAutoHideBtns(seconds)
end
function CMainMenu:cancelAutoHideBtns()
  if self.m_AutoHideBtnHandler then
    scheduler.unscheduleGlobal(self.m_AutoHideBtnHandler)
    self.m_AutoHideBtnHandler = nil
  end
end
function CMainMenu:AutoSetBtnSimpleFlag(flag)
  if self.m_SimpleFlag == flag then
    self:SetSimpleFlag(flag)
  else
    self:Action_MoveBtns(function()
      self:SetSimpleFlag(flag)
    end)
  end
end
function CMainMenu:ShowTishengBoard()
  self:ShowBtnLightCircle(self.btn_menu_tisheng, false)
  local tishengList = GetTishengList()
  if #tishengList == 0 then
    if self.m_TishengBoard then
      self:CloseTishengBoard()
    end
    ShowNotifyTips("暂时没有可以提升的地方")
    return
  elseif self.m_TishengBoard then
    self.m_TishengBoard:SetTishengBtns(tishengList)
  else
    local dlg = CTiShengBoard.new()
    local x, y = self:getNode("pos_tishengboard"):getPosition()
    dlg:setPosition(ccp(x, y))
    self:addChild(dlg:getUINode())
    self.m_TishengBoard = dlg
  end
end
function CMainMenu:UpdateTishengBoard()
  local tishengList = GetTishengList()
  if self.m_TishengBoard then
    if #tishengList == 0 then
      self:CloseTishengBoard()
    else
      self.m_TishengBoard:SetTishengBtns(tishengList)
    end
  end
  local newShowTishengFlag = false
  if #tishengList == 0 then
    newShowTishengFlag = false
  else
    newShowTishengFlag = true
  end
  if self.m_ShowTishengBtn ~= newShowTishengFlag then
    self.m_ShowTishengBtn = newShowTishengFlag
    self:SetBtnShow()
  end
  local tishengN = false
  local libaoN = false
  local biwuN = false
  local heroN = false
  local petN = false
  local huobanN = false
  local zqN = false
  for _, tsType in pairs(tishengList) do
    tishengN = true
    if tsType == DEF_TISHENG_LevelGift or tsType == DEF_TISHENG_LoginGift or tsType == DEF_TISHENG_OnLineGift then
      libaoN = true
    elseif tsType == DEF_TISHENG_FreeBiwu then
      biwuN = true
    elseif tsType == DEF_TISHENG_RoleAttrPoint then
      heroN = true
    elseif tsType == DEF_TISHENG_PetAttrPoint then
      petN = true
    elseif tsType == DEF_TISHENG_HuobanAttrPoint then
      huobanN = true
    elseif tsType == DEF_TISHENG_ZuoQiSkill or tsType == DEF_TISHENG_GetZuoQi then
      zqN = true
    end
  end
  if #tishengList == 1 and tishengList[1] == DEF_TISHENG_ChengZhangBD then
    tishengN = false
  end
  local hasNewFlag = false
  if self.m_RecordTishengData ~= nil then
    for _, i in pairs(tishengList) do
      local inFlag = false
      for _, j in pairs(self.m_RecordTishengData) do
        if j == i then
          inFlag = true
          break
        end
      end
      if inFlag == false then
        hasNewFlag = true
        break
      end
    end
  else
    hasNewFlag = true
  end
  if not hasNewFlag then
    tishengN = false
  end
  self:ShowBtnLightCircle(self.btn_menu_tisheng, tishengN)
  local hdN = libaoN or gift.festival:getFestivalId() or self:JudgeNeedRemindEventList() or gift.newTermCheckIn:IsCanNewTermCheckInToday() or gift.guoQingCheckIn:IsCanGuoQingCheckInToday()
  self:ShowBtnLightCircle(self.btn_menu_huodong, hdN)
  self:ShowBtnRedIcon(self.m_HeadImg, heroN)
  self:ShowBtnRedIcon(self.btn_menu_pet, petN)
  self:ShowBtnRedIcon(self.btn_menu_huoban, huobanN)
  self:ShowBtnRedIcon(self.btn_menu_zuoqi, zqN)
end
function CMainMenu:CloseTishengBoard()
  if self.m_TishengBoard then
    self.m_TishengBoard:CloseSelf()
    self.m_TishengBoard = nil
  end
  self.m_RecordTishengData = GetTishengList()
  self:ShowBtnLightCircle(self.btn_menu_tisheng, false)
end
function CMainMenu:setIsShowTianting(isShow)
  self.m_ShowTTBtnFlag = isShow
  self.m_IsDayantaShowBtn = isShow
  self:SetBtnShow()
  self.m_TTCurShowExp = 0
end
function CMainMenu:setTiantingExp(exp)
  self.txt_tt_exp:stopAllActions()
  if exp ~= self.m_TTCurShowExp then
    self.txt_tt_exp:setText(string.format("累积经验:%d", self.m_TTCurShowExp))
    local action1 = CCScaleTo:create(0.2, 1.3)
    local action2 = CCCallFunc:create(function()
      self.txt_tt_exp:setText(string.format("累积经验:%d", exp))
    end)
    local action3 = CCScaleTo:create(0.2, 1)
    self.txt_tt_exp:runAction(transition.sequence({
      action1,
      action2,
      action3
    }))
  else
    self.txt_tt_exp:setText(string.format("累积经验:%d", exp))
  end
  self.m_TTCurShowExp = exp
end
function CMainMenu:setIsShowDayanta(isShow)
  self.m_IsTiantingShowBtn = isShow
  self:SetBtnShow()
end
function CMainMenu:setIsShowTianDiQiShu(isShow)
  self.m_IsTiantingShowBtn = isShow
  self.m_IsTianDiQiShuShowBtn = isShow
  self:SetBtnShow()
end
function CMainMenu:setTianDiQiShuTxt(txt)
  self.txt_tt_exp:setText(txt)
end
function CMainMenu:InitMsgBox()
  self.chatbox = self:getNode("chatbox")
  self.chatbox:setOpacity(0)
  self.m_Msgbox = CMsgBox.new()
  self.chatbox:addChild(self.m_Msgbox:getUINode())
  g_MessageMgr:OnLoginTipMessage()
end
function CMainMenu:getMsgbox()
  return self.m_Msgbox
end
function CMainMenu:setDoubleExpTxt()
  local doubleExpData = g_LocalPlayer:getDoubleExpData()
  local deP = doubleExpData.deP or 0
  self:getNode("txt_doubleexp"):setText(tostring(deP) .. "点")
end
function CMainMenu:ShowBtnLightCircle(btn, flag)
  if btn == nil then
    return
  end
  if flag then
    if btn.lightCircle == nil then
      local eff = CreateSeqAnimation("xiyou/ani/btn_circle.plist", -1)
      if eff then
        eff:setPosition(ccp(0, 3))
        if btn == self.btn_menu_team then
          eff:setPosition(ccp(0, 32))
        elseif btn == self.btn_menu_friend or btn == self.btn_mission_open or btn == self.btn_menu_sociality then
          eff:setScale(0.7)
        end
        btn:addNode(eff, 1)
        btn.lightCircle = eff
      end
    end
  elseif btn.lightCircle then
    btn.lightCircle:removeFromParent()
    btn.lightCircle = nil
  end
  if btn ~= self.btn_menu_add then
    self:ShowBtnRedIcon(self.btn_menu_add)
  end
  local needUpdateBtnName
  for _, btnName in pairs({
    "btn_menu_eqptupgrade",
    "btn_menu_skill",
    "btn_menu_huoban",
    "btn_menu_zuoqi",
    "btn_menu_tool",
    "btn_menu_shop",
    "btn_menu_market",
    "btn_menu_guild",
    "btn_menu_team",
    "btn_menu_rank",
    "btn_menu_huodong",
    "btn_menu_doubleexp",
    "btn_menu_biwu",
    "btn_menu_mission"
  }) do
    local tempBtn = self[btnName]
    if btn == tempBtn then
      needUpdateBtnName = btnName
      break
    end
  end
  if g_WarScene then
    local waruiIns = g_WarScene.m_WaruiObj
    if waruiIns then
      local waruiBtn = waruiIns[needUpdateBtnName]
      waruiIns:ShowBtnLightCircle(waruiBtn, flag)
    end
  end
  if btn == self.btn_menu_team then
    self:ShowBtnLightCircle(self.btn_mission_open, flag)
  end
end
function CMainMenu:ShowBtnRedIcon(btn, flag)
  if btn == nil then
    return
  end
  if flag then
    if btn.redIcon == nil then
      local redIcon = display.newSprite("views/pic/pic_tipnew.png")
      btn:addNode(redIcon, 0)
      if btn == self.btn_menu_friend or btn == self.btn_menu_sociality then
        redIcon:setPosition(ccp(20, 20))
      elseif btn == self.m_HeadImg then
        redIcon:setPosition(ccp(80, 80))
      else
        redIcon:setPosition(ccp(25, 25))
      end
      btn.redIcon = redIcon
    end
  elseif btn.redIcon then
    btn.redIcon:removeFromParent()
    btn.redIcon = nil
  end
  if btn == self.btn_menu_add then
    local addFlag = false
    for _, tempBtnName in pairs({
      "btn_menu_eqptupgrade",
      "btn_menu_skill",
      "btn_menu_zuoqi",
      "btn_menu_guild"
    }) do
      local tempBtn = self[tempBtnName]
      if tempBtn ~= nil and (tempBtn.redIcon ~= nil or tempBtn.lightCircle ~= nil) and (self.m_BtnNotOpenFlagDict[tempBtnName] == false or self.m_BtnNotOpenFlagDict[tempBtnName] == nil) then
        addFlag = true
        break
      end
    end
    addFlag = addFlag and flag ~= false and self.m_SimpleFlag
    if addFlag then
      if btn.redIcon == nil then
        local redIcon = display.newSprite("views/pic/pic_tipnew.png")
        btn:addNode(redIcon, 0)
        redIcon:setPosition(ccp(25, 25))
        btn.redIcon = redIcon
      end
    elseif btn.redIcon then
      btn.redIcon:removeFromParent()
      btn.redIcon = nil
    end
  else
    self:ShowBtnRedIcon(self.btn_menu_add)
  end
  local needUpdateBtnName
  for _, btnName in pairs({
    "btn_menu_eqptupgrade",
    "btn_menu_skill",
    "btn_menu_huoban",
    "btn_menu_zuoqi",
    "btn_menu_tool",
    "btn_menu_shop",
    "btn_menu_market",
    "btn_menu_guild",
    "btn_menu_team",
    "btn_menu_rank",
    "btn_menu_huodong",
    "btn_menu_doubleexp",
    "btn_menu_biwu",
    "btn_menu_mission"
  }) do
    local tempBtn = self[btnName]
    if btn == tempBtn then
      needUpdateBtnName = btnName
      break
    end
  end
  if g_WarScene then
    local waruiIns = g_WarScene.m_WaruiObj
    if waruiIns then
      local waruiBtn = waruiIns[needUpdateBtnName]
      waruiIns:ShowBtnRedIcon(waruiBtn, flag)
    end
  end
end
function CMainMenu:ShowPackageBtnFullIcon(flag)
  local btn = self.btn_menu_tool
  if btn == nil then
    return
  end
  if flag then
    if btn.fullIcon == nil then
      local fullIcon = display.newSprite("views/pic/pic_packagefull.png")
      local dt = 0.5
      local act1 = CCScaleTo:create(dt, 1.2)
      local act2 = CCScaleTo:create(dt, 0.9)
      fullIcon:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
      fullIcon:setPosition(ccp(-28, 25))
      btn:addNode(fullIcon, 0)
      btn.fullIcon = fullIcon
    end
  elseif btn.fullIcon then
    btn.fullIcon:removeFromParent()
    btn.fullIcon = nil
  end
  if g_WarScene then
    local waruiIns = g_WarScene.m_WaruiObj
    if waruiIns then
      waruiIns:ShowPackageBtnFullIcon(flag)
    end
  end
end
function CMainMenu:SetJGShowHuobanList(list)
  self.m_CanGetHuoBanShowList = list
  g_LocalPlayer:saveCanGetHuoBanShowList(list)
end
function CMainMenu:SetJGLightCircle()
  self:ShowBtnLightCircle(self.btn_menu_huoban, false)
  local newHuoBan = false
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local openList = g_LocalPlayer:getJiuguanOpenList()
  for i = 1, MAX_JIUGUAN_FRIEND_HERO_NUM do
    local needZs, needLv, alwaysJudgeLvFlag = data_getJiuguanNeedZsLvData(i)
    local lvEnough = data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
    local isOpen = false
    for _, temp in pairs(openList) do
      if temp == i then
        isOpen = true
        break
      end
    end
    local showFlag = false
    if self.m_CanGetHuoBanShowList == nil then
      self.m_CanGetHuoBanShowList = g_LocalPlayer:getCanGetHuoBanShowList()
    end
    if self.m_CanGetHuoBanShowList == nil then
      self.m_CanGetHuoBanShowList = {}
    end
    for _, temp in pairs(self.m_CanGetHuoBanShowList) do
      if temp == i then
        showFlag = true
        break
      end
    end
    if lvEnough and not isOpen and not showFlag then
      newHuoBan = true
    end
  end
  if newHuoBan then
    self:ShowBtnLightCircle(self.btn_menu_huoban, true)
  end
end
function CMainMenu:checkFubenCanGetAward()
  local minFbId
  for tFbId, _ in pairs(data_Catch) do
    if g_LocalPlayer:getFubenCanGetAward(tFbId) and (minFbId == nil or tFbId < minFbId) then
      minFbId = tFbId
    end
  end
  self:ShowBtnRedIcon(self.btn_menu_guanqia, minFbId ~= nil)
end
function CMainMenu:ShowFriendTip(num)
  if num > 99 then
    num = 99
  end
  self.pic_tipnew_friend:setVisible(num > 0)
  self.unread_friend:setText(tostring(num))
end
function CMainMenu:CheckShowNewMailTip()
  local newMailFlag = g_MailMgr:getIsHasNewMail()
  self:ShowBtnRedIcon(self.btn_menu_friend, newMailFlag)
end
function CMainMenu:getMisssionListPos()
  return self.list_mission
end
function CMainMenu:checkShowBpWarStateInfoDlg()
  self:SetBtnShow()
end
function CMainMenu:SetSMSDFlag(flag)
  self.m_StoreSMSDFlag = flag
  self:SetStoreBtnRedIcon()
end
function CMainMenu:SetStoreBtnRedIcon()
  local flag = self.m_StoreSMSDFlag or g_LocalPlayer:getCanGetFanliAward()
  self:ShowBtnRedIcon(self.btn_menu_shop, flag)
end
function CMainMenu:SetHuodongRemindData()
  if self.m_EventHasRemindList == nil and g_LocalPlayer then
    local t, tmpList = g_LocalPlayer:getRemindHuodongData()
    local curTime = g_DataMgr:getServerTime()
    if t == nil then
      self.m_EventHasRemindList = {}
    elseif t > curTime then
      self.m_EventHasRemindList = {}
    else
      local curTime = g_DataMgr:getServerTime()
      local oldTimeTable = os.date("*t", checkint(t))
      local hour = oldTimeTable.hour
      local next5Time = os.time({
        year = oldTimeTable.year,
        month = oldTimeTable.month,
        day = oldTimeTable.day,
        hour = 5,
        min = 0,
        sec = 0,
        isdst = oldTimeTable.isdst
      })
      if oldTimeTable.hour >= 5 then
        next5Time = next5Time + 86400
      end
      if curTime > next5Time then
        self.m_EventHasRemindList = {}
      else
        self.m_EventHasRemindList = tmpList
      end
    end
  end
end
function CMainMenu:JudgeEventNeedRemind(eventId)
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local zs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  local data = data_DailyHuodongAward[eventId]
  if data and data_judgeFuncOpen(zs, lv, data.OpenZs, data.OpenLv, data.AlwaysJudgeLvFlag) == false then
    return false
  end
  self:SetHuodongRemindData()
  if self.m_EventHasShowRemindList == nil then
    self.m_EventHasShowRemindList = {}
  end
  if self.m_EventHasRemindList[eventId] == true then
    return false
  end
  local events = activity.event:getAllEvent()
  local proData = events[eventId] or {}
  local statu = proData.state
  if statu ~= activity.event.Status_CannotRecive then
    return false
  end
  local curTime = g_DataMgr:getServerTime()
  local curH = tonumber(os.date("%H", curTime))
  local curM = tonumber(os.date("%M", curTime))
  if eventId == 10013 then
    local kjData = data_KeJuControl[1]
    local startTime = kjData.StartTime
    local endTime = kjData.EndTime
    if (curH > startTime[1] or curH == startTime[1] and curM > startTime[2]) and (curH < endTime[1] or curH == endTime[1] and curM < endTime[2]) then
      return true
    end
  end
  if eventId == 11003 and activity.tbsj:GetTBSJCircleNum() > TBSJ_MaxCircle then
    return false
  end
  if data_Huodong[eventId] then
    local hdData = data_Huodong[eventId]
    local StartTipsTime = hdData.StartTipsTime
    local EndTipsTime = hdData.EndTipsTime
    local inTimeFlag = false
    if StartTipsTime ~= nil and EndTipsTime ~= nil and (curH > StartTipsTime[1] or curH == StartTipsTime[1] and curM > StartTipsTime[2]) and (curH < EndTipsTime[1] or curH == EndTipsTime[1] and curM < EndTipsTime[2]) then
      inTimeFlag = true
    end
    if inTimeFlag then
      return true
    end
  end
  return false
end
function CMainMenu:JudgeNeedRemindEventList()
  if self:JudgeEventNeedRemind(10013) and self.m_EventHasShowRemindList[10013] ~= true then
    return true
  end
  for eventId, _ in pairs(data_Huodong) do
    if self:JudgeEventNeedRemind(eventId) and self.m_EventHasShowRemindList[eventId] ~= true then
      return true
    end
  end
  return false
end
function CMainMenu:UpdateRemindEventList()
  self:SetHuodongRemindData()
  if self.m_EventHasRemindTimeNum == nil then
    self.m_EventHasRemindTimeNum = 0
  else
    self.m_EventHasRemindTimeNum = (self.m_EventHasRemindTimeNum + 1) % 30
  end
  if self.m_EventHasRemindTimeNum % 30 ~= 0 then
    return
  end
  local oldFlag = self.m_EventHasRemindFlag
  self.m_EventHasRemindFlag = self:JudgeNeedRemindEventList()
  if oldFlag ~= self.m_EventHasRemindFlag then
    SendMessage(MsgID_Gift_EventRemindUpdate)
  end
end
function CMainMenu:ResetEventRemindList()
  self.m_EventHasRemindList = {}
  self.m_EventHasShowRemindList = {}
end
function CMainMenu:SetEventRemind(eventId)
  self.m_EventHasRemindList[eventId] = true
  if g_LocalPlayer and g_DataMgr then
    local data = {}
    data[1] = g_DataMgr:getServerTime()
    for eventId, flag in pairs(self.m_EventHasRemindList) do
      if flag then
        data[#data + 1] = eventId
      end
    end
    g_LocalPlayer:saveRemindHuodongData(data)
  end
end
function CMainMenu:SetEventHasShowRemind(eventId)
  self.m_EventHasShowRemindList[eventId] = true
end
function CMainMenu:SetEventRemindInWar(warType, isWatch, isReview, warResult)
  if isWatch then
    return
  end
  if isReview then
    return
  end
  if warResult ~= WARRESULT_ATTACK_WIN then
    return
  end
  local eventId
  if warType == WARTYPE_TONGTIAN then
    eventId = 11002
  elseif warType == WARTYPE_TianBingShenJiang then
    eventId = 11003
  end
  if eventId and self:JudgeEventNeedRemind(eventId) then
    self:SetEventRemind(eventId)
  end
end
function CMainMenu:ShowSaTangBtn()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    self.btn_satang:setEnabled(true)
    self:getNode("txt_satangtime"):setVisible(true)
    self:addEntranceBtnAction(self.btn_satang, true)
  else
    self.btn_satang:setEnabled(false)
    self:getNode("txt_satangtime"):setVisible(false)
    self:addEntranceBtnAction(self.btn_satang, false)
  end
  self:checkBtnEntrancePos()
end
function CMainMenu:UpdateSaTangBtnText()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    local txt = ""
    if self.m_SatangTime ~= nil then
      local curTime = cc.net.SocketTCP.getTime()
      local restTime = math.floor(3 - (curTime - self.m_SatangTime))
      if restTime > 0 then
        txt = string.format("%ds", restTime)
      end
    end
    local restTime = g_HunyinMgr:GetXiTangRestTime()
    if restTime <= 0 then
      txt = ""
    end
    self:getNode("txt_satangtime"):setText(txt)
    self:getNode("txt_satangnum"):setText(string.format("%d/5次", restTime))
  end
end

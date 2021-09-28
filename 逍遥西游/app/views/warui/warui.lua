warui = class("warui", CcsSubView)
PerRoundTime = 20
local BTN_SKILLIMG_TAG = 9999
local BTN_ADD_TAG = 9998
local BTN_HERO_SKILLIMG_TAG = 9999
local BTN_PET_SKILLIMG_TAG = 9998
local BtnActionPos = 200
local BtnActionTime = 0.2
local DelayTimeForAutoFight = 2
local SceneChangeTime = 1
local g_PublicWarUI
function preLoadWarUI()
  if g_PublicWarUI == nil then
    print("===================>>> 预加载warui对象")
    g_PublicWarUI = warui.new()
    g_PublicWarUI:setUIConfigViewClear(false)
    g_PublicWarUI.m_UINode:retain()
  end
end
function createNewWarUI()
  if g_PublicWarUI == nil then
    print("===================>>> 异常:获取warui对象时，居然找不到")
    preLoadWarUI()
  end
  if g_PublicWarUI:getParent() ~= nil then
    g_PublicWarUI:removeFromParent()
  end
  return g_PublicWarUI
end
gamereset.registerResetFunc(function()
  if g_PublicWarUI ~= nil then
    g_PublicWarUI:clearWhenDelete()
    g_PublicWarUI.m_UINode:release()
    g_PublicWarUI:doCcsUIConfigViewClear()
    g_PublicWarUI = nil
  end
end)
function warui:ctor()
  if g_JiehunJieqiRelease then
    warui.super.ctor(self, "views/war_ui.json")
  else
    warui.super.ctor(self, "views/war_ui_old.json")
  end
  local btnBatchListener = {
    btn_menu_top_open = {
      listener = handler(self, self.OnBtn_Menu_TopAdd),
      variName = "btn_menu_top_open",
      param = {2}
    },
    btn_menu_top_close = {
      listener = handler(self, self.OnBtn_Menu_TopClose),
      variName = "btn_menu_top_close",
      param = {2}
    },
    btn_auto = {
      listener = handler(self, self.Btn_Auto),
      variName = "m_Btn_Auto"
    },
    btn_attack = {
      listener = handler(self, self.Btn_Attack),
      variName = "m_Btn_Attack"
    },
    btn_skill1 = {
      listener = handler(self, self.Btn_Skill1),
      variName = "m_Btn_Skill1"
    },
    btn_skill2 = {
      listener = handler(self, self.Btn_Skill2),
      variName = "m_Btn_Skill2"
    },
    btn_call = {
      listener = handler(self, self.Btn_Call),
      variName = "m_Btn_Call"
    },
    btn_defence = {
      listener = handler(self, self.Btn_Defence),
      variName = "m_Btn_Defence"
    },
    btn_drug = {
      listener = handler(self, self.Btn_Drug),
      variName = "m_Btn_Drug"
    },
    btn_magic = {
      listener = handler(self, self.Btn_Magic),
      variName = "m_Btn_Magic"
    },
    btn_runaway = {
      listener = handler(self, self.Btn_RunAway),
      variName = "m_Btn_RunAway"
    },
    btn_protect = {
      listener = handler(self, self.Btn_Protect),
      variName = "m_Btn_Protect"
    },
    btn_catch = {
      listener = handler(self, self.Btn_Catch),
      variName = "m_Btn_Catch"
    },
    btn_menu_friend = {
      listener = handler(self, self.OnBtn_Menu_Friend),
      variName = "btn_menu_friend"
    },
    btn_menu_sociality = {
      listener = handler(self, self.OnBtn_Menu_Sociality),
      variName = "btn_menu_sociality"
    },
    btn_menu_dailyword = {
      listener = handler(self, self.OnBtn_Menu_DailyWord),
      variName = "btn_menu_dailyword"
    },
    btn_setdefault = {
      listener = handler(self, self.Btn_default),
      variName = "btn_setdefault"
    },
    btn_back = {
      listener = handler(self, self.Btn_Back),
      variName = "m_Btn_Back"
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
    btn_menu_rank = {
      listener = handler(self, self.OnBtn_Menu_Rank),
      variName = "btn_menu_rank",
      param = {2}
    },
    btn_menu_huodong = {
      listener = handler(self, self.OnBtn_Menu_Huodong),
      variName = "btn_menu_huodong",
      param = {2}
    },
    btn_menu_team = {
      listener = handler(self, self.OnBtn_Menu_Team),
      variName = "btn_menu_team",
      param = {2}
    },
    btn_menu_doubleexp = {
      listener = handler(self, self.OnBtn_Menu_Doubleexp),
      variName = "btn_menu_doubleexp",
      param = {2}
    },
    btn_menu_biwu = {
      listener = handler(self, self.OnBtn_Menu_BiWu),
      variName = "btn_menu_biwu",
      param = {2}
    },
    btn_menu_mission = {
      listener = handler(self, self.OnBtn_Menu_Mission),
      variName = "btn_menu_mission",
      param = {2}
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
    btn_menu_pet = {
      listener = handler(self, self.OnBtn_Menu_Pet),
      variName = "btn_menu_pet",
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
    }
  }
  if g_JiehunJieqiRelease then
    btnBatchListener.btn_teji = {
      listener = handler(self, self.Btn_TeJi),
      variName = "m_Btn_TeJi"
    }
  end
  self:addBatchBtnListener(btnBatchListener)
  BpwarStateInfo.extend(self, self:getNode("layer_bpwar"))
  self.btn_voice_team = self:getNode("btn_voice_team")
  self.btn_voice_bp = self:getNode("btn_voice_bp")
  self.btn_voice_world = self:getNode("btn_voice_world")
  VoiceRecordBtnExtend.extend(self.btn_voice_team, CHANNEL_TEAM)
  VoiceRecordBtnExtend.extend(self.btn_voice_bp, CHANNEL_BP_MSG)
  VoiceRecordBtnExtend.extend(self.btn_voice_world, CHANNEL_WOLRD)
  self.m_TimeText = self:getNode("timeNum")
  self.m_WaitText = self:getNode("waittext")
  self.m_Btn_ActionBtnNameDict = {
    "m_Btn_Skill1",
    "m_Btn_Skill2",
    "m_Btn_Call",
    "m_Btn_Defence",
    "m_Btn_Drug",
    "m_Btn_Magic",
    "m_Btn_RunAway",
    "m_Btn_Attack",
    "m_Btn_Protect",
    "m_Btn_Catch"
  }
  if g_JiehunJieqiRelease then
    self.m_Btn_ActionBtnNameDict = {
      "m_Btn_Skill1",
      "m_Btn_Skill2",
      "m_Btn_TeJi",
      "m_Btn_Call",
      "m_Btn_Defence",
      "m_Btn_Drug",
      "m_Btn_Magic",
      "m_Btn_RunAway",
      "m_Btn_Attack",
      "m_Btn_Protect",
      "m_Btn_Catch"
    }
  end
  self.m_Btn_ActionTopBtnNameDict = {
    "btn_menu_shop",
    "btn_menu_market",
    "btn_menu_rank",
    "btn_menu_huodong",
    "btn_menu_team",
    "btn_menu_doubleexp",
    "btn_menu_biwu",
    "btn_menu_mission"
  }
  self.m_MenuBtn_AllSetPosBtnNameDict = {
    "btn_menu_friend",
    "btn_menu_sociality",
    "btn_voice_world",
    "btn_voice_bp",
    "btn_voice_team",
    "btn_menu_dailyword",
    "btn_menu_shop",
    "btn_menu_market",
    "btn_menu_rank",
    "btn_menu_huodong",
    "btn_menu_team",
    "btn_menu_doubleexp",
    "btn_menu_biwu",
    "btn_menu_mission",
    "btn_menu_tool",
    "btn_menu_skill",
    "btn_menu_pet",
    "btn_menu_zuoqi",
    "btn_menu_huoban",
    "btn_menu_eqptupgrade",
    "btn_menu_guild"
  }
  self.m_MenuBtn_ActionBtnNameDict = {
    "btn_menu_tool",
    "btn_menu_skill",
    "btn_menu_zuoqi",
    "btn_menu_huoban",
    "btn_menu_eqptupgrade",
    "btn_menu_guild"
  }
  self.m_Btn_CheckCircle = {
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
  }
  local x, y = self.m_Btn_Auto:getPosition()
  self.m_Btn_ActionBtnHidePos = ccp(x, y)
  local x, y = self.m_Btn_RunAway:getPosition()
  self.m_HeroRunBtnPos = ccp(x, y)
  local x, y = self.m_Btn_Call:getPosition()
  self.m_PetRunBtnPos = ccp(x, y)
  self.m_MenuBtn_ActionBtnOldPosDict = {}
  local x, y = self.m_Btn_Auto:getPosition()
  self.m_MenuBtn_ActionBtnHidePos = ccp(x, y)
  for _, btnName in pairs(self.m_MenuBtn_AllSetPosBtnNameDict) do
    local x, y = self[btnName]:getPosition()
    self.m_MenuBtn_ActionBtnOldPosDict[btnName] = ccp(x, y)
    print("oldPos===>>>", btnName, x, y)
  end
  self.m_Btn_ActionBtnPosDict = {}
  for _, btnName in pairs(self.m_Btn_ActionBtnNameDict) do
    local x, y = self[btnName]:getPosition()
    self.m_Btn_ActionBtnPosDict[btnName] = ccp(x, y)
  end
  self.chatbox = self:getNode("chatbox")
  self.chatbox:setOpacity(0)
  self.m_Msgbox = CMsgBox.new()
  self.chatbox:addChild(self.m_Msgbox:getUINode())
  self.m_Msgbox._execNodeEvent = false
  self:initBtnsPosWithMsgBoxMode()
  self:InitExpBar()
  self:setHuoliIcon()
  self.pic_tipnew_friend = self:getNode("pic_tipnew_friend")
  self.unread_friend = self:getNode("unread_friend")
  self:ClearWarUi()
  self:getUINode():setSize(CCSize(display.width, display.height))
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Mail)
end
function warui:init(warScene)
  self.m_WarScene = warScene
  local tempData = g_LocalPlayer:getWarUISetting()
  local autoFlag = tempData.autoFlag or false
  local simpleFlag = tempData.simpleFlag or false
  local defaultData = tempData.defaultData or {}
  self.m_RoundNum = 0
  self.m_AutoFightFlag = autoFlag
  self.m_SimpleFlag = false
  self.m_TopSimpleFlag = true
  self.m_SelectFlag = false
  self.m_IsShowFighting = false
  self.m_CanSettingDataFlag = false
  self.m_HasStartWarFlag = false
  self.m_WaitingAutoDelay = false
  self.m_SettingData = {}
  self.m_SettingRolePosList = {}
  self.m_SettingRoleFlagList = {}
  self.m_CurSettingPos = 0
  self.m_CurSettingData = {}
  self.m_SelectView = nil
  self.m_DefaultSettingData = {}
  self.m_HeroPos = self.m_WarScene:getMainHeroPos()
  self.m_PetPos = self.m_WarScene:getMainHeroPos() + DefineRelativePetAddPos
  self:SetDefaultSettingData(self.m_HeroPos, defaultData.heroPos)
  local _, petData = self.m_WarScene:getMainHeroAndPetDataAfterCreateWarUI()
  if petData ~= nil and petData.objId ~= nil then
    local petObj = g_LocalPlayer:getObjById(petData.objId)
    local tempPetOp = {}
    if petObj ~= nil then
      local autoData = petObj:getProperty(PROPERTY_WARAUTOSKILL) or 0
      if autoData == 0 then
        tempPetOp = {}
      elseif autoData == 10 then
        tempPetOp = {
          aiActionType = AI_ACTION_TYPE_NORMALATTACK,
          targetPos = 0,
          skillId = SKILLTYPE_NORMALATTACK
        }
      elseif autoData == 20 then
        tempPetOp = {aiActionType = AI_ACTION_TYPE_DEFEND}
      else
        local skillId = math.floor(autoData / 10)
        if 0 < petObj:getProficiency(skillId) then
          local caFlagNum = autoData % 10
          local caFlag = false
          if caFlagNum == 1 then
            caFlag = true
          end
          tempPetOp = {
            aiActionType = AI_ACTION_TYPE_USESKILL,
            targetPos = 0,
            skillId = skillId,
            caFlag = caFlag
          }
        else
          tempPetOp = {
            aiActionType = AI_ACTION_TYPE_NORMALATTACK,
            targetPos = 0,
            skillId = SKILLTYPE_NORMALATTACK
          }
        end
      end
    end
    self:SetDefaultSettingData(self.m_PetPos, tempPetOp)
  end
  self.m_CanUseDrugList = {}
  self:getNode("huiheText"):setVisible(false)
  self:ShowStartOpTips("")
  self.m_TimeNum = 0
  self.m_CurTimeNum = nil
  self.m_SettingTimeMaxNum = PerRoundTime
  self.m_RunningFlag = false
  self:SetWaittextShow(false)
  self:ShowOpTips(false)
  self.m_Btn_Back:setEnabled(false)
  self:InitMsgBoxAndSociality()
  self:SetMenuViewBtns()
  self.m_Btn_ActionTopBtnPosDict = {}
  for _, btnName in pairs(self.m_Btn_ActionTopBtnNameDict) do
    local x, y = self[btnName]:getPosition()
    self.m_Btn_ActionTopBtnPosDict[btnName] = ccp(x, y)
  end
  local mainMsgBox = g_CMainMenuHandler:getMsgbox()
  if mainMsgBox and self.m_Msgbox then
    local isSmallMode = mainMsgBox:getIsSmallMode()
    self.m_Msgbox:SetSmallModeAdjust(isSmallMode, false)
    local off = self.m_Msgbox:getAddHeight()
    self:setBtnsPosWithMsgBoxMode(isSmallMode, off)
  end
  self:updatePetLvBg()
  self:updateHeadData()
  self:updateExp()
  self:SetHuoLi()
  self:SetSimpleFlag(self.m_SimpleFlag)
  self:SetAutoFlag(self.m_AutoFightFlag)
  self:SetTopSimpleFlag(true)
  if g_SocialityDlg and g_SocialityDlg.m_UINode and g_LocalPlayer:getNormalTeamer() ~= true and CMainUIScene.Ins then
    CMainUIScene.Ins:ReOrderSubView(g_SocialityDlg, MainUISceneZOrder.warScene)
  end
  if g_FriendsDlg and g_FriendsDlg.m_UINode then
    if g_LocalPlayer:getNormalTeamer() ~= true and CMainUIScene.Ins then
      CMainUIScene.Ins:ReOrderSubView(g_FriendsDlg, MainUISceneZOrder.warScene)
    end
    local temp = g_FriendsDlg:getSocialityTipNum()
    self:ShowFriendTip(temp)
  else
    self:ShowFriendTip(0)
  end
  if g_MainDailyWord and g_MainDailyWord.m_UINode and CMainUIScene.Ins then
    CMainUIScene.Ins:ReOrderSubView(g_MainDailyWord, MainUISceneZOrder.menuView)
  end
  self:setVisible(false)
end
function warui:ClearWarUi()
  if self.m_Msgbox then
    self.m_Msgbox:ClearBox()
  end
  self:removePackageBtnFullIcon()
  self:removeAllBtnLightCircle()
  self:clearBpWarStateInfo()
  if self.m_AddPetHeadSprite ~= nil then
    self.m_AddPetHeadSprite:removeFromParent()
    self.m_AddPetHeadSprite = nil
  end
  self.m_MsgsysEnabled = false
end
function warui:ReloadWarUi(warScene)
  if self.m_Msgbox then
    self.m_Msgbox:reloadBox()
  end
  self.m_MsgsysEnabled = true
  self:init(warScene)
  self:checkBpWarStateInfo()
  self:setVisible(false)
end
function warui:clearWhenDelete()
  if self.m_Msgbox and self.m_Msgbox.m_UINode then
    self.m_Msgbox._execNodeEvent = true
    self.m_Msgbox:execEventCleanup()
  end
end
function warui:checkShowBpWarStateInfoDlg()
  if self.__BpWarStateInfoDlg then
    self.__BpWarStateInfoDlg:setUIConfigViewClear(false)
  end
end
function warui:InitShow()
  if self.m_UpdateHandler == nil then
    self.m_UpdateHandler = scheduler.scheduleUpdateGlobal(handler(self, self.TimeUpdate))
  end
  self:setVisible(true)
end
function warui:InitExpBar()
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
function warui:updateExp()
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    printLog("ERROR", "找不到主英雄1")
    return
  end
  local zsNum = mainRole:getProperty(PROPERTY_ZHUANSHENG)
  local lvNum = mainRole:getProperty(PROPERTY_ROLELEVEL)
  local curExp = mainRole:getProperty(PROPERTY_EXP)
  local maxExp = CalculateHeroLevelupExp(lvNum, zsNum)
  self:getNode("txt_level"):setText(string.format("%d转%d", zsNum, lvNum))
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
function warui:InitMsgBoxAndSociality()
  local showFlag = true
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shejiao)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Hide then
      showFlag = false
      self.btn_menu_sociality:setVisible(false)
      self.btn_menu_sociality:setTouchEnabled(false)
    elseif noOpenType == OPEN_FUNC_Type_Gray then
      self.btn_menu_sociality:loadTextureNormal("views/mainviews/btn_shejiao_gray.png")
    end
  elseif noOpenType == OPEN_FUNC_Type_Hide then
    showFlag = true
    self.btn_menu_sociality:setVisible(true)
    self.btn_menu_sociality:setTouchEnabled(true)
  elseif noOpenType == OPEN_FUNC_Type_Gray then
    self.btn_menu_sociality:loadTextureNormal("views/mainviews/btn_shejiao.png")
  end
  if g_TeamMgr:getLocalPlayerTeamId() == 0 then
    self.btn_menu_dailyword:setVisible(false and showFlag)
    self.btn_menu_dailyword:setTouchEnabled(false and showFlag)
    self.btn_voice_team:setVisible(false and showFlag)
    self.btn_voice_team:setTouchEnabled(false and showFlag)
  else
    self.btn_menu_dailyword:setVisible(showFlag)
    self.btn_menu_dailyword:setTouchEnabled(showFlag)
    self.btn_voice_team:setVisible(showFlag)
    self.btn_voice_team:setTouchEnabled(showFlag)
  end
  if g_CMainMenuHandler then
    local mainMsgBox = g_CMainMenuHandler:getMsgbox()
    if mainMsgBox and self.m_Msgbox then
      local content = mainMsgBox:GetContent()
      self.m_Msgbox:SetContent(content)
    end
  end
  self:ShowBtnRedIcon(self.btn_menu_sociality, false)
  self:CheckShowNewMailTip()
end
function warui:checkIsInBp()
  if g_BpMgr:localPlayerHasBangPai() then
    self.btn_voice_bp:setVisible(true)
    self.btn_voice_bp:setTouchEnabled(true)
    self.m_BtnNotOpenFlagDict.btn_voice_bp = false
  else
    self.btn_voice_bp:setVisible(false)
    self.btn_voice_bp:setTouchEnabled(false)
    self.m_BtnNotOpenFlagDict.btn_voice_bp = true
  end
end
function warui:OnBtn_Menu_Friend(btnObj, touchType)
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
function warui:OnBtn_Menu_Sociality(obj, t)
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
function warui:OnBtn_Menu_DailyWord(obj, t)
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
function warui:OnMessage(msgSID, ...)
  if self.m_MsgsysEnabled ~= true then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_Scene_NewFriendTip then
    self:ShowFriendTip(arg[1])
  elseif msgSID == MsgID_BP_LocalInfo then
    self:checkIsInBp()
    self:SetMenuBtnPos()
  elseif msgSID == MsgID_HeroUpdate then
    local d = arg[1]
    local lv = d.pro[PROPERTY_ROLELEVEL]
    local zs = d.pro[PROPERTY_ZHUANSHENG]
    local exp = d.pro[PROPERTY_EXP]
    if lv ~= nil or zs ~= nil or exp ~= nil then
      self:updateExp()
    end
  elseif msgSID == MsgID_Mail_AllMailLoaded then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_Mail_MailUpdated then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_Mail_MailDeleteed then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_Mail_MailHasNewMail then
    self:CheckShowNewMailTip()
  elseif msgSID == MsgID_Scene_MsgBoxSmallMode then
    self:setBtnsPosWithMsgBoxMode(arg[1], arg[2])
  elseif msgSID == MsgID_Team_AddJoinRequest then
    self:onReceiveAddJoinRequest()
  elseif msgSID == MsgID_Team_ClearJoinRequest then
    self:onReceiveClearJoinRequest()
  elseif msgSID == MsgID_Team_HasCheckJoinRequest then
    self:onReceiveHasCheckJoinRequest()
  elseif msgSID == MsgID_Team_DelJoinRequest then
    self:onReceiveDelJoinRequest(arg[1])
  end
end
function warui:onReceiveAddJoinRequest()
  if g_MakeTeamDlg and g_MakeTeamDlg:IsCheckingJoinRequest() then
    self:ShowBtnLightCircle(self.btn_menu_team, false)
  else
    self:ShowBtnLightCircle(self.btn_menu_team, true)
  end
end
function warui:onReceiveClearJoinRequest()
  self:ShowBtnLightCircle(self.btn_menu_team, false)
end
function warui:onReceiveHasCheckJoinRequest()
  self:ShowBtnLightCircle(self.btn_menu_team, false)
end
function warui:onReceiveDelJoinRequest(pid)
  local joinRequest = g_TeamMgr:getJoinRequest()
  if #joinRequest <= 0 then
    self:ShowBtnLightCircle(self.btn_menu_team, false)
  end
end
function warui:SetSettingRolePosList()
  local mainRolePos = self.m_WarScene:getMainHeroPos()
  if mainRolePos == nil then
    printLog("warui", "异常，战斗没有主角")
    self.m_SettingRolePosList = {}
    self.m_SettingRoleFlagList = {}
  else
    self.m_SettingRolePosList = {
      mainRolePos,
      mainRolePos + DefineRelativePetAddPos
    }
    self.m_SettingRoleFlagList = {}
    for _, pos in pairs(self.m_SettingRolePosList) do
      self.m_SettingRoleFlagList[pos] = false
    end
  end
end
function warui:StartNextRoleFight()
  printLog("warui", "StartNextRoleFight")
  self:DelSelectView()
  self.m_CurSettingData = {}
  if self.m_AutoFightFlag then
    if self.m_RoundNum == 1 then
      self.m_WaitingAutoDelay = true
    else
      self:EndOneRoundFightSetting()
    end
  else
    self.m_WaitingAutoDelay = false
    local nextPos
    for _, pos in pairs(self.m_SettingRolePosList) do
      local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
      if self.m_SettingRoleFlagList[pos] == false and tempRole ~= nil then
        if pos == self.m_HeroPos then
          nextPos = pos
          break
        elseif self.m_WarScene:getRoleViewIsAliveByPos(pos) then
          nextPos = pos
          break
        end
      end
    end
    if nextPos == nil then
      printLog("warui", "全部需要设置的角色都设置完了")
      self:EndOneRoundFightSetting()
    else
      self.m_SettingRoleFlagList[nextPos] = true
      self:StartOneRoleSetting(nextPos)
    end
  end
end
function warui:StartOneRoleSetting(pos)
  printLog("warui", "StartOneRoleSetting,设置一个角色的行动pos%d", pos)
  if math.floor(pos / 100) % 10 == 0 then
    self:ShowStartOpTips("请下达人物指令")
  else
    self:ShowStartOpTips("请下达召唤兽指令")
  end
  self.m_WarScene:showRightDownSelect(false)
  self.m_WarScene:showLeftUpSelect(false)
  self.m_CurSettingPos = pos
  self.m_WarScene:showMySelectArrow(pos)
  self:SetSkillBtnImage()
  self:Action_FadeInBtns()
  self:SetBtnShow()
end
function warui:EndOneRoleSetting(pos, actionDict, fadeOutFlag)
  self:ShowStartOpTips("")
  if not self.m_CanSettingDataFlag then
    printLog("warui", "m_CanSettingDataFlag为false  不能设置EndOneRoleSetting %d", pos)
    return
  end
  printLog("warui", "EndOneRoleSetting %d,", pos)
  self.m_SettingData[pos] = actionDict
  if actionDict.aiActionType == AI_ACTION_TYPE_USESKILL then
    local tempSkillId = actionDict.skillId
    if pos == self.m_HeroPos or pos == self.m_PetPos then
      local role = self.m_WarScene:getLocalRoleDataObjByPos(pos)
      if role then
        local tempSkillList = role:getUseSkillList()
        if tempSkillList == 0 or tempSkillList == nil then
          tempSkillList = {}
        end
        local inFlag = false
        for _, sid in pairs(tempSkillList) do
          if sid == tempSkillId then
            inFlag = true
          end
        end
        if not inFlag then
          if tempSkillList[1] == 0 or tempSkillList[1] == nil then
            tempSkillList[1] = tempSkillId
          elseif tempSkillList[2] == 0 or tempSkillList[2] == nil then
            tempSkillList[2] = tempSkillId
          else
            tempSkillList[1] = tempSkillList[2]
            tempSkillList[2] = tempSkillId
          end
          role:setProperty(PROPERTY_USESKILLLIST, tempSkillList)
          g_LocalPlayer:SaveRoleProperty(role:getObjId(), PROPERTY_USESKILLLIST, tempSkillList, true)
        end
      end
    end
  end
  self.m_WarScene:showMySelectArrow(nil)
  self:SetSelectFlag(false)
  if fadeOutFlag == false then
    self:StartNextRoleFight()
    local nextPos
    for _, pos in pairs(self.m_SettingRolePosList) do
      local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
      if self.m_SettingData[pos] == nil and tempRole ~= nil then
        nextPos = pos
        break
      end
    end
    if nextPos == nil then
      self:SetWaittextShow(true)
    end
    local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
    if tempRole ~= nil then
      local curPlayerId = tempRole:getPlayerId()
      local curRoleId = tempRole:getObjId()
      self.m_WarScene:SendActionToAI(self.m_WarScene:getWarID(), self.m_WarScene:getSingleWarFlag(), self.m_RoundNum, curPlayerId, curRoleId, pos, self.m_SettingData[pos])
    end
  else
    self:Action_FadeOutBtns(function()
      self:StartNextRoleFight()
      local nextPos
      for _, pos in pairs(self.m_SettingRolePosList) do
        local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
        if self.m_SettingData[pos] == nil and tempRole ~= nil then
          nextPos = pos
          break
        end
      end
      if nextPos == nil then
        self:SetWaittextShow(true)
      end
      local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
      if tempRole ~= nil then
        local curPlayerId = tempRole:getPlayerId()
        local curRoleId = tempRole:getObjId()
        self.m_WarScene:SendActionToAI(self.m_WarScene:getWarID(), self.m_WarScene:getSingleWarFlag(), self.m_RoundNum, curPlayerId, curRoleId, pos, self.m_SettingData[pos])
      end
    end)
  end
end
function warui:SetDefaultSettingData(pos, actionData, setIconUseActionFlag)
  printLog("warui", "SetDefaultSettingData", pos)
  if actionData ~= nil then
    self.m_DefaultSettingData[pos] = actionData
    if pos == self.m_PetPos then
      local heroData, petData = self.m_WarScene:getMainHeroAndPetDataAfterCreateWarUI()
      if petData ~= nil and petData.objId ~= nil then
        actionData.oid = petData.objId
        self.m_SavePetAutoSettingData = actionData
      end
    end
  end
  if setIconUseActionFlag == true then
    self:SetDefaultSettingIcon(pos, actionData)
  else
    self:SetDefaultSettingIcon(pos)
  end
end
function warui:SetDefaultSettingIcon(pos, opData)
  printLog("warui", "SetDefaultSettingIcon", pos)
  if pos == self.m_HeroPos then
    if self.m_Btn_hero_defaultImg then
      self.m_Btn_hero_defaultImg:removeFromParent()
      self.m_Btn_hero_defaultImg = nil
    end
  elseif self.m_Btn_pet_defaultImg then
    self.m_Btn_pet_defaultImg:removeFromParent()
    self.m_Btn_pet_defaultImg = nil
  end
  function _clickheroskill()
    if self then
      self:ShowSelectAutoView(false)
    end
  end
  function _clickpetskill()
    if self then
      self:ShowSelectAutoView(true)
    end
  end
  local noGrayFlag = false
  if opData ~= nil then
    noGrayFlag = true
  else
    opData = self:GetAutoFightDataByPos(pos)
  end
  local normalPath = "views/warui/btn_attack_s.png"
  local grayFlag = false
  if opData.aiActionType == AI_ACTION_TYPE_NORMALATTACK then
    normalPath = "views/warui/btn_attack_s.png"
    grayFlag = false
  elseif opData.aiActionType == AI_ACTION_TYPE_DEFEND then
    normalPath = "views/warui/btn_defence_s.png"
    grayFlag = false
  elseif opData.aiActionType == AI_ACTION_TYPE_USESKILL then
    local tempSkillId = opData.skillId
    normalPath = data_getSkillShapePath(tempSkillId)
    grayFlag = false
    local minRoundFlag = self.m_WarScene:roleSkillCanUseOfMinRound(pos, tempSkillId)
    local cdFlag = self.m_WarScene:roleSkillCDEnough(pos, tempSkillId)
    local proFlag = self.m_WarScene:roleSkillProEnough(pos, tempSkillId)
    local hasUseFlag = g_WarScene:roleSkillHasUse(pos, tempSkillId)
    if minRoundFlag ~= true then
      grayFlag = true
    elseif hasUseFlag == true then
      grayFlag = true
    elseif cdFlag ~= true then
      grayFlag = true
    elseif proFlag ~= true then
      grayFlag = true
    elseif not self.m_WarScene:roleSkillMpEnough(pos, tempSkillId) then
      grayFlag = true
    elseif not self.m_WarScene:roleSkillHpEnough(pos, tempSkillId) then
      grayFlag = true
    elseif self.m_WarScene:roleSkillIsYiWang(pos, tempSkillId) then
      grayFlag = true
    end
  end
  grayFlag = grayFlag and not noGrayFlag
  local btn = self.btn_setdefault
  local tempSprite
  if pos == self.m_HeroPos then
    tempSprite = createClickButton(normalPath, nil, _clickheroskill, nil, nil, true, grayFlag)
  else
    tempSprite = createClickButton(normalPath, nil, _clickpetskill, nil, nil, true, grayFlag)
  end
  btn:addChild(tempSprite, 1)
  local btnSize = btn:getContentSize()
  if pos == self.m_HeroPos then
    local size = tempSprite:getContentSize()
    tempSprite:setPosition(ccp(btnSize.width / 2 - size.width + 20, -size.height / 2 + 8))
    tempSprite:setScale(0.8)
    local icon = display.newSprite("views/warui/pic_heroskill.png")
    icon:setAnchorPoint(ccp(1, 0))
    tempSprite:addNode(icon)
    icon:setPosition(ccp(size.width - 1, 0))
    self.m_Btn_hero_defaultImg = tempSprite
  else
    local size = tempSprite:getContentSize()
    tempSprite:setPosition(ccp(15 - size.width / 2, -size.height / 2 + 8))
    tempSprite:setScale(0.8)
    local icon = display.newSprite("views/warui/pic_petskill.png")
    icon:setAnchorPoint(ccp(1, 0))
    tempSprite:addNode(icon)
    icon:setPosition(ccp(size.width - 1, 0))
    self.m_Btn_pet_defaultImg = tempSprite
  end
end
function warui:UpdateDefaultSettingIcons()
  self:SetDefaultSettingData(self.m_HeroPos)
  self:SetDefaultSettingData(self.m_PetPos)
  local heroData, petData = self.m_WarScene:getMainHeroAndPetDataAfterCreateWarUI()
  local hasPetFlag = true
  if petData == nil then
    hasPetFlag = false
  end
  if self.m_Btn_pet_defaultImg then
    self.m_Btn_pet_defaultImg:setVisible(self.m_AutoFightFlag and hasPetFlag)
    self.m_Btn_pet_defaultImg:setButtonEnabled(self.m_AutoFightFlag and hasPetFlag)
  end
  if self.m_Btn_hero_defaultImg then
    self.m_Btn_hero_defaultImg:setVisible(self.m_AutoFightFlag)
    self.m_Btn_hero_defaultImg:setButtonEnabled(self.m_AutoFightFlag)
  end
end
function warui:GetAutoFightDataByPos(pos)
  local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
  local opData
  if self.m_DefaultSettingData[pos] ~= nil then
    local oldOpData = self.m_DefaultSettingData[pos]
    if oldOpData.aiActionType == AI_ACTION_TYPE_NORMALATTACK then
      opData = {
        aiActionType = AI_ACTION_TYPE_NORMALATTACK,
        targetPos = 0,
        skillId = SKILLTYPE_NORMALATTACK,
        caFlag = oldOpData.caFlag
      }
    elseif oldOpData.aiActionType == AI_ACTION_TYPE_DEFEND then
      opData = {
        aiActionType = AI_ACTION_TYPE_DEFEND,
        caFlag = oldOpData.caFlag
      }
    elseif oldOpData.aiActionType == AI_ACTION_TYPE_USESKILL then
      local skillId = oldOpData.skillId
      if self.m_WarScene:roleCanOpenSkill(pos, skillId) then
        opData = {
          aiActionType = AI_ACTION_TYPE_USESKILL,
          targetPos = 0,
          skillId = skillId,
          caFlag = oldOpData.caFlag
        }
      end
    end
  end
  if opData == nil then
    if tempRole == nil then
      return {}
    end
    opData = GetDefaultOperation(tempRole:getTypeId(), tempRole:getProperty(PROPERTY_GENDER), tempRole:getProperty(PROPERTY_RACE))
  end
  return opData
end
function warui:StartOneRoundFightSetting(round, passtime)
  printLog("warui", "StartOneRoundFightSetting")
  self:SetWaittextShow(false)
  self:SetHuoLi()
  self:SetRoundNum(round)
  self.m_SettingData = {}
  self:SetSettingRolePosList()
  self:SetFightingFlag(false)
  self:StartTimer(passtime)
  self:StartNextRoleFight()
  self.m_HasStartWarFlag = true
  self.m_CanUseDrugList = DeepCopyTable(self.m_WarScene:getWarDrugList())
  if self.m_AutoSelectView ~= nil then
    self.m_AutoSelectView:ReSetAutoSelectView()
  end
  self:SetSkillBtnImage()
end
function warui:SetRoundNum(num)
  self.m_RoundNum = num
  self:getNode("huiheText"):setVisible(true)
  self:getNode("huiheText"):setText(string.format("%d", num))
end
function warui:EndOneRoundFightSetting(timesupFlag)
  if timesupFlag == true then
    printLog("warui", "EndOneRoundFightSetting,时间到")
  else
    printLog("warui", "EndOneRoundFightSetting,时间没有到，可能是手动设置结束，或者是自动战斗")
  end
  self:CancelAction()
  self:StopTimer()
  self:SetWaittextShow(true)
  if timesupFlag == true then
    for _, pos in pairs(self.m_SettingRolePosList) do
      local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
      if tempRole ~= nil and self.m_SettingData[pos] == nil then
        self.m_SettingData[pos] = {
          aiActionType = AI_ACTION_TYPE_NORMALATTACK,
          targetPos = 0,
          skillId = SKILLTYPE_NORMALATTACK
        }
        self.m_SettingData[pos].timesupFlag = true
        local curPlayerId = tempRole:getPlayerId()
        local curRoleId = tempRole:getObjId()
        local actionData = self.m_SettingData[pos]
        if pos ~= self.m_HeroPos and self.m_WarScene:getRoleViewIsAliveByPos(pos) == false then
          actionData = {}
        end
        self.m_WarScene:SendActionToAI(self.m_WarScene:getWarID(), self.m_WarScene:getSingleWarFlag(), self.m_RoundNum, curPlayerId, curRoleId, pos, actionData)
      end
    end
  else
    for _, pos in pairs(self.m_SettingRolePosList) do
      local tempRole = self.m_WarScene:getLocalRoleDataObjByPos(pos)
      if tempRole ~= nil and self.m_SettingData[pos] == nil then
        self.m_SettingData[pos] = self:GetAutoFightDataByPos(pos)
        self.m_SettingData[pos].autoFlag = true
        local curPlayerId = tempRole:getPlayerId()
        local curRoleId = tempRole:getObjId()
        local actionData = self.m_SettingData[pos]
        if pos ~= self.m_HeroPos and self.m_WarScene:getRoleViewIsAliveByPos(pos) == false then
          actionData = {}
        end
        self.m_WarScene:SendActionToAI(self.m_WarScene:getWarID(), self.m_WarScene:getSingleWarFlag(), self.m_RoundNum, curPlayerId, curRoleId, pos, actionData)
      end
    end
  end
  self:SetFightingFlag(true)
  self.m_WarScene:showMySelectArrow(nil)
end
function warui:UIStartRunAction()
  self:CancelAction()
  self:StopTimer()
  self:SetWaittextShow(false)
  self:SetFightingFlag(true)
  self.m_WarScene:showMySelectArrow(nil)
  self:ShowStartOpTips("")
end
function warui:SetAutoFlag(autoFlag)
  if self.m_WarScene == nil then
    return
  end
  self.m_AutoFightFlag = autoFlag
  print("SetAutoFlag", autoFlag)
  if autoFlag and not self.m_IsShowFighting and self.m_HasStartWarFlag then
    self:EndOneRoundFightSetting()
  end
  if not autoFlag and self.m_IsShowFighting then
    ShowNotifyTips("下一回合取消自动战斗")
  end
  if not autoFlag and self.m_WaitingAutoDelay then
    self:StartNextRoleFight()
  end
  local btnPath = "views/warui/btn_auto.png"
  if autoFlag == true then
    btnPath = "views/warui/btn_cancelauto.png"
  end
  if self.m_Btn_Auto.__btnPath == nil or self.m_Btn_Auto.__btnPath ~= btnPath then
    self.m_Btn_Auto:loadTextureNormal(btnPath)
    self.m_Btn_Auto.__btnPath = btnPath
  end
  self:SetBtnShow()
  self:getNode("btn_setdefault"):setEnabled(autoFlag)
  if self.m_Btn_hero_defaultImg then
    self.m_Btn_hero_defaultImg:setButtonEnabled(self.m_AutoFightFlag)
  end
  if self.m_Btn_pet_defaultImg then
    self.m_Btn_pet_defaultImg:setButtonEnabled(self.m_AutoFightFlag)
  end
  self:ShowMenuViewBtns()
  if self.m_AutoFightFlag == true then
    self:ShowStartOpTips("")
  end
end
function warui:SetSimpleFlag(simpleFlag)
  self.m_SimpleFlag = false
  self:SetBtnShow()
end
function warui:SetTopSimpleFlag(topSimpleFlag)
  self.m_TopSimpleFlag = topSimpleFlag
  if topSimpleFlag == true then
    self:ShowBtnRedIcon(self.btn_menu_top_open, true)
    self.btn_menu_top_open:setScaleX(-1)
  else
    self:ShowBtnRedIcon(self.btn_menu_top_open, false)
    self.btn_menu_top_open:setScaleX(1)
  end
  self:ShowMenuViewBtns()
end
function warui:SetSelectFlag(selectFlag)
  self.m_SelectFlag = selectFlag
  self:SetBtnShow()
end
function warui:SetFightingFlag(fightingFlag)
  self.m_IsShowFighting = fightingFlag
  self:SetBtnShow()
end
function warui:GetIsShowFighting()
  return self.m_IsShowFighting
end
function warui:SetBtnShow()
  if self.m_WarScene == nil then
    return
  end
  local isPetFlag = false
  local canCatch = self.m_WarScene:getWarType() == WARTYPE_GuaJi
  local settingRole = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if settingRole ~= nil and settingRole:getType() == LOGICTYPE_PET then
    isPetFlag = true
  end
  local hasViewShow = false
  if self.m_SelectView ~= nil and self.m_SelectView:isEnabled() == true then
    hasViewShow = true
  end
  self:ShowOpTips(self.m_SelectFlag and not hasViewShow)
  self.m_Btn_Back:setEnabled(self.m_SelectFlag and not hasViewShow)
  self.m_Btn_Auto:setEnabled(true)
  self.m_Btn_Attack:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag)
  if g_JiehunJieqiRelease then
    self.m_Btn_TeJi:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag)
  end
  self.m_Btn_Skill1:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag)
  self.m_Btn_Skill2:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag)
  self.m_Btn_Call:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag and not self.m_SimpleFlag and not isPetFlag)
  self.m_Btn_Defence:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag and not self.m_SimpleFlag)
  self.m_Btn_Drug:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag)
  self.m_Btn_Magic:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag and not self.m_SimpleFlag)
  self.m_Btn_RunAway:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag and not self.m_SimpleFlag and not isPetFlag)
  self.m_Btn_Protect:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag and not self.m_SimpleFlag)
  self.m_Btn_Catch:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag and not self.m_SimpleFlag and not isPetFlag and canCatch)
  self:UpdateDefaultSettingIcons()
  self:SetSkillBtnShow()
  self:getNode("layer_huoli"):setVisible(canCatch)
end
function warui:SetWaittextShow(flag)
  self.m_WaitText:setVisible(flag)
end
function warui:SetSkillBtnShow()
  local roleDataObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  local skillList = {0, 0}
  if roleDataObj ~= nil then
    skillList = roleDataObj:getUseSkillList()
  end
  local showNextBtnFlag = true
  for i = 1, 2 do
    local tempSkillId = skillList[i] or 0
    local btn = self[string.format("m_Btn_Skill%d", i)]
    btn:setEnabled(not self.m_SelectFlag and not self.m_IsShowFighting and not self.m_AutoFightFlag and showNextBtnFlag)
    if tempSkillId == 0 then
      showNextBtnFlag = false
    end
  end
end
function warui:SetSkillBtnImage()
  local roleDataObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  local skillList = {0, 0}
  if roleDataObj ~= nil then
    skillList = roleDataObj:getUseSkillList()
  end
  for i = 1, 2 do
    local tempSkillId = skillList[i] or 0
    local btn = self[string.format("m_Btn_Skill%d", i)]
    local tag = BTN_SKILLIMG_TAG
    local oldChild = btn:getVirtualRenderer():getChildByTag(tag)
    if oldChild ~= nil then
      btn:getVirtualRenderer():removeChild(oldChild)
    end
    local addTag = BTN_ADD_TAG
    local oldAddChild = btn:getVirtualRenderer():getChildByTag(addTag)
    if oldAddChild == nil then
      local addImg = display.newSprite("views/rolelist/equipcanadd.png")
      local btnSize = btn:getContentSize()
      addImg:setPosition(ccp(btnSize.width / 2, btnSize.height / 2))
      btn:getVirtualRenderer():addChild(addImg, 1, addTag)
    end
    if tempSkillId ~= 0 then
      local path = data_getSkillShapePath(tempSkillId)
      local tempSprite
      local minRoundFlag = self.m_WarScene:roleSkillCanUseOfMinRound(self.m_CurSettingPos, tempSkillId)
      local cdFlag = self.m_WarScene:roleSkillCDEnough(self.m_CurSettingPos, tempSkillId)
      local proFlag = self.m_WarScene:roleSkillProEnough(self.m_CurSettingPos, tempSkillId)
      local hasUseFlag = g_WarScene:roleSkillHasUse(self.m_CurSettingPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_CurSettingPos, tempSkillId)
      local addText = ""
      if minRoundFlag ~= true then
        tempSprite = display.newGraySprite(path)
      elseif hasUseFlag == true then
        tempSprite = display.newGraySprite(path)
      elseif yiwangFlag == true then
        tempSprite = display.newGraySprite(path)
        addText = "遗忘"
      elseif cdFlag ~= true then
        tempSprite = display.newGraySprite(path)
        addText = string.format("冷却\n(%d)", cdFlag)
      elseif proFlag ~= true then
        tempSprite = display.newGraySprite(path)
        if proFlag == "ll" then
          addText = "力量\n不足"
        elseif proFlag == "gg" then
          addText = "根骨\n不足"
        elseif proFlag == "lx" then
          addText = "灵性\n不足"
        elseif proFlag == "mj" then
          addText = "敏捷\n不足"
        elseif proFlag == "jin" then
          addText = "五行金\n不足"
        elseif proFlag == "mu" then
          addText = "五行木\n不足"
        elseif proFlag == "shui" then
          addText = "五行水\n不足"
        elseif proFlag == "huo" then
          addText = "五行火\n不足"
        elseif proFlag == "tu" then
          addText = "五行土\n不足"
        end
      elseif not self.m_WarScene:roleSkillMpEnough(self.m_CurSettingPos, tempSkillId) then
        tempSprite = display.newGraySprite(path)
        addText = "魔法\n不足"
      elseif not self.m_WarScene:roleSkillHpEnough(self.m_CurSettingPos, tempSkillId) then
        tempSprite = display.newGraySprite(path)
        addText = "气血\n不足"
      else
        tempSprite = display.newSprite(path)
      end
      btn:getVirtualRenderer():addChild(tempSprite, 1, tag)
      local size = btn:getVirtualRenderer():getContentSize()
      tempSprite:setPosition(ccp(size.width / 2, size.height / 2))
      local jie = data_getSkillStep(tempSkillId)
      if jie ~= nil and jie > 2 and jie <= 5 then
        local jieImg = display.newSprite(string.format("views/warui/pic_jie%d.png", jie - 2))
        jieImg:setAnchorPoint(ccp(1, 0))
        tempSprite:addChild(jieImg)
        jieImg:setPosition(ccp(size.width, -2))
      end
      if addText ~= "" then
        local txtObj = ui.newTTFLabel({
          text = addText,
          font = KANG_TTF_FONT,
          size = 20,
          color = ccc3(255, 0, 0)
        })
        txtObj:setAnchorPoint(ccp(0.5, 0.5))
        local tSize = tempSprite:getContentSize()
        txtObj:setPosition(ccp(tSize.width / 2, tSize.height / 2))
        tempSprite:addChild(txtObj)
      end
    end
  end
end
function warui:Btn_Auto(obj, t)
  self:SetAutoFlag(not self.m_AutoFightFlag)
end
function warui:Btn_Open(obj, t)
  self:Action_MoveBtns(function()
    self:SetSimpleFlag(not self.m_SimpleFlag)
  end)
end
function warui:Btn_Defence(obj, t)
  self:EndOneRoleSetting(self.m_CurSettingPos, {aiActionType = AI_ACTION_TYPE_DEFEND, skillId = SKILLTYPE_DEFEND})
end
function warui:Btn_RunAway(obj, t)
  local warningTitle = "撤退"
  local text = "撤退后战斗将判定为#<R>失败#,确定要撤退吗?"
  if g_WarScene:getWarType() == WARTYPE_BpWAR then
    local isCaptain = true
    if g_LocalPlayer == nil then
      isCaptain = false
    elseif g_TeamMgr == nil then
      isCaptain = false
    else
      isCaptain = g_TeamMgr:getPlayerIsCaptain(g_LocalPlayer:getPlayerId())
    end
    if isCaptain == false then
      ShowNotifyTips("帮战中只有队长才能进行此操作")
      return
    end
    warningTitle = "帮战撤退"
    text = "帮战中队长撤退会使全队脱离战斗,并判定为战斗#<R>失败#。确定要撤退吗?"
  end
  if self.m_RunAwayPopView ~= nil then
    self.m_RunAwayPopView:OnClose()
  end
  self.m_RunAwayPopView = CPopWarning.new({
    title = warningTitle,
    text = text,
    align = CRichText_AlignType_Left,
    confirmFunc = function()
      self:EndOneRoleSetting(self.m_CurSettingPos, {aiActionType = AI_ACTION_TYPE_RUNAWAY, skillId = SKILLTYPE_RUNAWAY})
    end,
    clearFunc = function()
      if self.m_RunAwayPopView ~= nil then
        self.m_RunAwayPopView:OnClose()
        self.m_RunAwayPopView = nil
      end
    end
  })
  self.m_RunAwayPopView:ShowCloseBtn(false)
end
function warui:Btn_Skill1(obj, t)
  self:Btn_SkillByNum(1)
end
function warui:Btn_Skill2(obj, t)
  self:Btn_SkillByNum(2)
end
function warui:Btn_Attack(obj, t)
  local role = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if role == nil then
    printLog("warui", "Btn_Attack 异常，没有对象")
    return
  end
  self:SelectForAttack()
  self:SetSelectFlag(true)
end
function warui:Btn_SkillByNum(num)
  local role = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if role == nil then
    printLog("warui", "Btn_Skill(%d) 异常，没有对象", num)
    return
  end
  local skillList = role:getUseSkillList()
  local skillId = skillList[num] or 0
  if skillId == 0 then
    self:Btn_Magic()
    return
  end
  if not self.m_WarScene:roleCanOpenSkill(self.m_CurSettingPos, skillId) then
    printLog("warui", "Btn_Skill(%d) 异常，技能还没有开启", num)
    ShowNotifyTips("技能还没有开放")
    return
  end
  if self.m_WarScene:roleSkillCanGetMarryTarget(self.m_CurSettingPos, skillId) == false then
    local banlvName = "伴侣"
    if g_FriendsMgr then
      local _, blID = g_FriendsMgr:getBanlvInfo()
      if blID then
        blInfo = g_FriendsMgr:getPlayerInfo(blID)
        banlvName = blInfo and (blInfo.name or "伴侣")
      end
    end
    local skillName = data_getSkillName(skillId)
    ShowNotifyTips(string.format("你与%s不在同一战斗中，无法释放#<Y>%s#", banlvName, skillName))
    return
  end
  local hasUsed = self.m_WarScene:roleSkillHasUse(self.m_CurSettingPos, skillId)
  if hasUsed then
    ShowNotifyTips("该技能全场只能使用一次")
    return
  end
  local minRound = self.m_WarScene:roleSkillCanUseOfMinRound(self.m_CurSettingPos, skillId)
  if minRound ~= true and minRound > self.m_RoundNum then
    ShowNotifyTips(string.format("该技能前%d回合不能使用", minRound - 1))
    return
  end
  self:SelectSkill(skillId)
  self:SetSelectFlag(true)
end
function warui:Btn_Call(obj, t)
  local selectPetView = selectPet.new(self)
  getCurSceneView():addSubView({
    subView = selectPetView,
    zOrder = MainUISceneZOrder.menuView
  })
  self.m_SelectView = selectPetView
  self:SetSelectFlag(true)
end
function warui:Btn_Drug(obj, t)
  if g_WarScene:getWarType() == WARTYPE_BIWU then
    ShowNotifyTips("比武场中,不能使用道具")
    return
  end
  local hasDrugFlag = false
  for drugShapeId, drugNum in pairs(self.m_CanUseDrugList) do
    if drugNum > 0 then
      hasDrugFlag = true
      break
    end
  end
  if hasDrugFlag then
    local selectDrugView = selectDrug.new(self, self.m_CanUseDrugList)
    getCurSceneView():addSubView({
      subView = selectDrugView,
      zOrder = MainUISceneZOrder.menuView
    })
    self.m_SelectView = selectDrugView
    self:SetSelectFlag(true)
  else
    ShowNotifyTips("背包里面没有药品")
  end
end
function warui:Btn_TeJi(obj, t)
  local tempHeroObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if tempHeroObj == nil then
    return
  end
  if self.m_CurSettingPos == self.m_WarScene:getMainHeroPos() then
    local hasTeJiFlag = false
    for _, tempSkillID in ipairs(ACTIVE_MARRYSKILLLIST) do
      if self.m_WarScene:roleCanOpenSkill(self.m_CurSettingPos, tempSkillID) then
        hasTeJiFlag = true
        break
      end
    end
    if hasTeJiFlag then
      local selectSkillView = selectTejiSkill.new(self, tempHeroObj, self.m_CurSettingPos)
      getCurSceneView():addSubView({
        subView = selectSkillView,
        zOrder = MainUISceneZOrder.menuView
      })
      self.m_SelectView = selectSkillView
      self:SetSelectFlag(true)
      return
    else
      ShowNotifyTips("没有任何特技")
    end
  else
    ShowNotifyTips("召唤兽没有任何特技")
  end
end
function warui:Btn_Magic(obj, t)
  local selectSkillView
  local tempHeroObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if tempHeroObj == nil then
    return
  end
  if self.m_CurSettingPos == self.m_WarScene:getMainHeroPos() then
    selectSkillView = selectHeroSkill.new(self, tempHeroObj, self.m_CurSettingPos)
  else
    local hasSkillFlag = g_WarScene:getPetIsHasSkill(self.m_CurSettingPos)
    if hasSkillFlag then
      selectSkillView = selectPetSkill.new(self, tempHeroObj, self.m_CurSettingPos)
    end
  end
  if selectSkillView ~= nil then
    getCurSceneView():addSubView({
      subView = selectSkillView,
      zOrder = MainUISceneZOrder.menuView
    })
    self.m_SelectView = selectSkillView
    self:SetSelectFlag(true)
  else
    ShowNotifyTips("召唤兽没有学会任何法术")
  end
end
function warui:Btn_Protect(btnObj, touchType)
  local role = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if role == nil then
    printLog("warui", "Btn_Protect 异常，没有对象")
    return
  end
  self:SelectForProtect()
  self:SetSelectFlag(true)
end
function warui:Btn_Catch(btnObj, touchType)
  local role = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if role == nil then
    printLog("warui", "Btn_Catch 异常，没有对象")
    return
  end
  local numNotFullFlag = self.m_WarScene:roleCanCatchPetCheckNum()
  if not numNotFullFlag then
    ShowNotifyTips("身上召唤兽已满，不能捕捉")
    return
  end
  self:SelectForCatch()
  self:SetSelectFlag(true)
end
function warui:Btn_default(btnObj, touchType)
  self:ShowSelectAutoView(false)
end
function warui:Btn_Back(obj, t)
  self.m_CurSettingData = {}
  if self.m_SelectView ~= nil then
    self.m_SelectView:ShowWarSelectView(true)
  else
    self:CancelAction()
  end
  self:SetBtnShow()
  self.m_WarScene:showRightDownSelect(false)
  self.m_WarScene:showLeftUpSelect(false)
end
function warui:CancelAction()
  self.m_CurSettingData = {}
  self:SetSelectFlag(false)
  self:DelSelectView()
  self.m_WarScene:showRightDownSelect(false)
  self.m_WarScene:showLeftUpSelect(false)
end
function warui:SelectTarget(targetPos, deadFlag)
  if self.m_IsShowFighting or self.m_AutoFightFlag then
    return
  end
  printLog("warui", "点中目标%d", targetPos)
  local actionType = self.m_CurSettingData.aiActionType
  if actionType == nil then
    local sameSide = self.m_CurSettingPos > DefineDefendPosNumberBase == (targetPos > DefineDefendPosNumberBase)
    if sameSide == false then
      if deadFlag == true then
        ShowNotifyTips("目标已经死亡")
        return
      end
      if self.m_CurSettingPos ~= targetPos then
        self:EndOneRoleSetting(self.m_CurSettingPos, {
          aiActionType = AI_ACTION_TYPE_NORMALATTACK,
          targetPos = targetPos,
          skillId = SKILLTYPE_NORMALATTACK
        })
      end
    end
  elseif actionType == AI_ACTION_TYPE_NORMALATTACK then
    if deadFlag == true then
      ShowNotifyTips("目标已经死亡")
      return
    end
    if self.m_CurSettingPos ~= targetPos then
      self:EndOneRoleSetting(self.m_CurSettingPos, {
        aiActionType = AI_ACTION_TYPE_NORMALATTACK,
        targetPos = targetPos,
        skillId = SKILLTYPE_NORMALATTACK
      })
    end
  elseif actionType == AI_ACTION_TYPE_CATCH then
    local canCatchFlag = self.m_WarScene:roleCanCatchPetCheckLifeSkill(self.m_CurSettingPos, targetPos)
    if canCatchFlag ~= true then
      return
    end
    local numNotFullFlag = self.m_WarScene:roleCanCatchPetCheckNum()
    if not numNotFullFlag then
      ShowNotifyTips("身上召唤兽已满，不能捕捉")
      return
    end
    local huoliResult = self.m_WarScene:roleCanCatchPetCheckHuoLi(targetPos)
    if huoliResult ~= true then
      ShowNotifyTips(huoliResult)
      return
    end
    local mpEnoughFlag = self.m_WarScene:roleCanCatchPetCheckMp(self.m_CurSettingPos, targetPos)
    if mpEnoughFlag == false then
      ShowNotifyTips("法力值不足，无法捕捉")
      return
    end
    local result = self.m_WarScene:roleCanCatchPetCheckLV(self.m_CurSettingPos, targetPos)
    if result ~= true then
      ShowNotifyTips(result)
      return
    end
    if deadFlag == true then
      ShowNotifyTips("目标已经死亡")
      return
    end
    if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK and targetPos >= DefineDefendPosNumberBase then
      local actionPara = DeepCopyTable(self.m_CurSettingData)
      actionPara.targetPos = targetPos
      self:EndOneRoleSetting(self.m_CurSettingPos, actionPara, false)
    end
  elseif actionType == AI_ACTION_TYPE_PROTECT then
    if deadFlag == true then
      ShowNotifyTips("目标已经死亡")
      return
    end
    if self.m_CurSettingPos == targetPos then
    elseif self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK then
      if targetPos < DefineDefendPosNumberBase then
        local actionPara = DeepCopyTable(self.m_CurSettingData)
        actionPara.targetPos = targetPos
        self:EndOneRoleSetting(self.m_CurSettingPos, actionPara, false)
      end
    elseif targetPos >= DefineDefendPosNumberBase then
      local actionPara = DeepCopyTable(self.m_CurSettingData)
      actionPara.targetPos = targetPos
      self:EndOneRoleSetting(self.m_CurSettingPos, actionPara, false)
    end
  elseif actionType == AI_ACTION_TYPE_USEDRUG then
    if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK then
      if targetPos < DefineDefendPosNumberBase then
        local actionPara = DeepCopyTable(self.m_CurSettingData)
        actionPara.targetPos = targetPos
        self:EndOneRoleSetting(self.m_CurSettingPos, actionPara, false)
        local drugShapeId = actionPara.useDrugTypeId
        if self.m_CanUseDrugList[drugShapeId] ~= nil then
          self.m_CanUseDrugList[drugShapeId] = self.m_CanUseDrugList[drugShapeId] - 1
          if self.m_CanUseDrugList[drugShapeId] <= 0 then
            self.m_CanUseDrugList[drugShapeId] = nil
          end
        end
      end
    elseif targetPos >= DefineDefendPosNumberBase then
      local actionPara = DeepCopyTable(self.m_CurSettingData)
      actionPara.targetPos = targetPos
      self:EndOneRoleSetting(self.m_CurSettingPos, actionPara, false)
      local drugShapeId = actionPara.useDrugTypeId
      if self.m_CanUseDrugList[drugShapeId] ~= nil then
        self.m_CanUseDrugList[drugShapeId] = self.m_CanUseDrugList[drugShapeId] - 1
        if self.m_CanUseDrugList[drugShapeId] <= 0 then
          self.m_CanUseDrugList[drugShapeId] = nil
        end
      end
    end
  elseif actionType == AI_ACTION_TYPE_USESKILL then
    local skillId = self.m_CurSettingData.skillId
    if GetObjType(skillId) == LOGICTYPE_MARRYSKILL then
      local marryPos = self.m_WarScene:getMarryObjWarPos(self.m_CurSettingPos)
      if marryPos == targetPos then
        if skillId == MARRYSKILL_QINMIWUJIAN then
        elseif deadFlag == true then
          ShowNotifyTips("目标已经死亡")
          return
        end
      else
        ShowNotifyTips("只能对伴侣使用")
        return
      end
      local actionPara = DeepCopyTable(self.m_CurSettingData)
      actionPara.targetPos = targetPos
      self:EndOneRoleSetting(self.m_CurSettingPos, actionPara, false)
      return
    end
    if deadFlag == true and skillId ~= PETSKILL_HUIGEHUIRI and skillId ~= PETSKILL_JUEJINGFENGSHENG and skillId ~= PETSKILL_DUOHUNSUOMING and skillId ~= PETSKILL_TIESHUKAIHUA then
      ShowNotifyTips("目标已经死亡")
      return
    end
    local skillForEnemy = true
    local extraParam = {}
    local targetType = data_getSkillTargetType(skillId)
    if targetType == TARGETTYPE_ENEMYSIDE then
      skillForEnemy = true
    elseif targetType == TARGETTYPE_MYSIDE then
      skillForEnemy = false
    elseif targetType == TARGETTYPE_TEAMMATE then
      skillForEnemy = false
      extraParam.exceptSelf = true
    elseif targetType == TARGETTYPE_SELF then
      skillForEnemy = false
      extraParam.onlySelf = true
    elseif targetType == TARGETTYPE_ENEMYPET then
      skillForEnemy = true
      extraParam.onlyPet = true
    elseif targetType == TARGETTYPE_MYSIDEPET then
      skillForEnemy = false
      extraParam.onlyPet = true
    elseif targetType == TARGETTYPE_ENEMYDEAD then
      skillForEnemy = true
      extraParam.onlyDead = true
    elseif targetType == TARGETTYPE_MYSIDEDEAD then
      skillForEnemy = false
      extraParam.onlyDead = true
    end
    if skillForEnemy == true then
      if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK and targetPos < DefineDefendPosNumberBase then
        return
      elseif self.m_WarScene:getLocalTeamFlag() == TEAM_DEFEND and targetPos >= DefineDefendPosNumberBase then
        return
      end
    elseif self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK and targetPos >= DefineDefendPosNumberBase then
      return
    elseif self.m_WarScene:getLocalTeamFlag() == TEAM_DEFEND and targetPos < DefineDefendPosNumberBase then
      return
    end
    if extraParam.exceptSelf == true and self.m_CurSettingPos == targetPos then
      return
    end
    if extraParam.onlySelf == true and self.m_CurSettingPos ~= targetPos then
      return
    end
    if extraParam.onlyPet == true then
      local roleObj = self.m_WarScene:getViewObjByPos(targetPos)
      if roleObj and roleObj:getType() ~= LOGICTYPE_PET then
        return
      end
    end
    if extraParam.onlyDead == true then
      local roleObj = self.m_WarScene:getViewObjByPos(targetPos)
      if roleObj and (not roleObj:isDead() or g_WarScene:getRoleViewByPos(targetPos) == nil) then
        return
      end
    end
    local actionPara = DeepCopyTable(self.m_CurSettingData)
    actionPara.targetPos = targetPos
    self:EndOneRoleSetting(self.m_CurSettingPos, actionPara, false)
  end
end
function warui:SelectPet(petId)
  printLog("warui", "选择召唤兽%d", petId)
  self:EndOneRoleSetting(self.m_CurSettingPos, {aiActionType = AI_ACTION_TYPE_BABYPET, petId = petId}, false)
end
function warui:SelectDrug(drugType)
  self.m_CurSettingData = {aiActionType = AI_ACTION_TYPE_USEDRUG, useDrugTypeId = drugType}
  self:SetBtnShow()
  local skillForEnemy = false
  if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK then
  else
    skillForEnemy = not skillForEnemy
  end
  self.m_WarScene:showRightDownSelect(not skillForEnemy, true)
  self.m_WarScene:showLeftUpSelect(skillForEnemy, true)
end
function warui:SelectSkill(skillId)
  self.m_CurSettingData = {aiActionType = AI_ACTION_TYPE_USESKILL, skillId = skillId}
  self:SetBtnShow()
  if GetObjType(skillId) == LOGICTYPE_MARRYSKILL then
    local marryPos = self.m_WarScene:getMarryObjWarPos(self.m_CurSettingPos)
    for _, pos in pairs(AllWarPosList) do
      self.m_WarScene:showSelectPos(pos, false)
    end
    if skillId == MARRYSKILL_QINMIWUJIAN then
      self.m_WarScene:showSelectPos(marryPos, true, true)
    else
      self.m_WarScene:showSelectPos(marryPos, true, false)
    end
    return
  end
  local skillForEnemy = true
  local extraParam = {}
  extraParam.settingPos = self.m_CurSettingPos
  local targetType = data_getSkillTargetType(skillId)
  if targetType == TARGETTYPE_ENEMYSIDE then
    skillForEnemy = true
  elseif targetType == TARGETTYPE_MYSIDE then
    skillForEnemy = false
  elseif targetType == TARGETTYPE_TEAMMATE then
    skillForEnemy = false
    extraParam.exceptSelf = true
  elseif targetType == TARGETTYPE_SELF then
    skillForEnemy = false
    extraParam.onlySelf = true
  elseif targetType == TARGETTYPE_ENEMYPET then
    skillForEnemy = true
    extraParam.onlyPet = true
  elseif targetType == TARGETTYPE_MYSIDEPET then
    skillForEnemy = false
    extraParam.onlyPet = true
  elseif targetType == TARGETTYPE_ENEMYDEAD then
    skillForEnemy = true
    extraParam.onlyDead = true
  elseif targetType == TARGETTYPE_MYSIDEDEAD then
    skillForEnemy = false
    extraParam.onlyDead = true
  end
  if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK then
  else
    skillForEnemy = not skillForEnemy
  end
  local canSelectDeadPeople
  if skillId == PETSKILL_HUIGEHUIRI or skillId == PETSKILL_JUEJINGFENGSHENG or skillId == PETSKILL_DUOHUNSUOMING or skillId == PETSKILL_TIESHUKAIHUA then
    canSelectDeadPeople = true
  end
  self.m_WarScene:showRightDownSelect(not skillForEnemy, canSelectDeadPeople, extraParam)
  self.m_WarScene:showLeftUpSelect(skillForEnemy, canSelectDeadPeople, extraParam)
end
function warui:SelectForAttack()
  self.m_CurSettingData = {aiActionType = AI_ACTION_TYPE_NORMALATTACK}
  self:SetBtnShow()
  local skillForEnemy = true
  if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK then
  else
    skillForEnemy = not skillForEnemy
  end
  self.m_WarScene:showRightDownSelect(true)
  self.m_WarScene:showLeftUpSelect(true)
  self.m_WarScene:showSelectPos(self.m_CurSettingPos, false)
end
function warui:SelectForCatch()
  self.m_CurSettingData = {aiActionType = AI_ACTION_TYPE_CATCH}
  self:SetBtnShow()
  local skillForEnemy = true
  if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK then
  else
    skillForEnemy = not skillForEnemy
  end
  self.m_WarScene:showRightDownSelect(not skillForEnemy)
  self.m_WarScene:showLeftUpSelect(skillForEnemy)
end
function warui:SelectForProtect()
  self.m_CurSettingData = {aiActionType = AI_ACTION_TYPE_PROTECT}
  self:SetBtnShow()
  local skillForEnemy = false
  if self.m_WarScene:getLocalTeamFlag() == TEAM_ATTACK then
  else
    skillForEnemy = not skillForEnemy
  end
  self.m_WarScene:showRightDownSelect(not skillForEnemy)
  self.m_WarScene:showLeftUpSelect(skillForEnemy)
  self.m_WarScene:showSelectPos(self.m_CurSettingPos, false)
end
function warui:SetHPBar(hp, maxHp)
  self:getNode("hpbar"):setPercent(hp / maxHp * 100)
end
function warui:SetMPBar(mp, maxMp)
  self:getNode("mpbar"):setPercent(mp / maxMp * 100)
end
function warui:SetHuoLi()
  local huoli = g_LocalPlayer:getHuoli()
  self:getNode("txt_huoli"):setText(huoli)
end
function warui:setHuoliIcon()
  local picPath = data_getResPathByResID(RESTYPE_HUOLI)
  local huoliSprite = display.newSprite(picPath)
  local posNode = self:getNode("huoliPos")
  local x, y = posNode:getPosition()
  local size = posNode:getContentSize()
  huoliSprite:setPosition(ccp(x, y - 10))
  huoliSprite:setScale(0.7)
  huoliSprite:setAnchorPoint(ccp(0, 0))
  posNode:addNode(huoliSprite, MainUISceneZOrder.menuView)
end
function warui:SetMainRoleHead(typeId, zs, lv)
  if self.m_MainRoleImg ~= nil then
    self.m_MainRoleImg:removeFromParentAndCleanup(true)
  end
  self.m_MainRoleImg = createClickHead({
    roleTypeId = typeId,
    clickListener = handler(self, self.OnTouch_HeadIcon),
    clickSoundType = 2
  })
  self.pic_headiconbg = self:getNode("headbg")
  self.pic_headiconbg:setOpacity(0)
  self.pic_headiconbg:addChild(self.m_MainRoleImg, 0)
  local size = self.pic_headiconbg:getContentSize()
  self.m_MainRoleImg:setPosition(ccp(-size.width / 2, -size.height / 2))
  self:getNode("txt_level"):setText(string.format("%d转%d", zs, lv))
end
function warui:SetPetHPBar(hp, maxHp)
  self:getNode("hpbar_pet"):setPercent(hp / maxHp * 100)
  if hp <= 0 then
    if self.m_AddPetHeadSprite and not self.m_AddPetHeadSprite._gray then
      local heroData, petData = self.m_WarScene:getMainHeroAndPetDataAfterCreateWarUI()
      if petData ~= nil then
        self:SetPetHead(petData.typeId or 0, petData.zs or 0, petData.lv or 0, true)
      end
    end
  elseif self.m_AddPetHeadSprite and self.m_AddPetHeadSprite._gray then
    local heroData, petData = self.m_WarScene:getMainHeroAndPetDataAfterCreateWarUI()
    if petData ~= nil then
      self:SetPetHead(petData.typeId or 0, petData.zs or 0, petData.lv or 0, false)
    end
  end
end
function warui:SetPetMPBar(mp, maxMp)
  self:getNode("mpbar_pet"):setPercent(mp / maxMp * 100)
end
function warui:SetPetHead(typeId, zs, lv, gray)
  self:getNode("hpbar_pet"):setVisible(true)
  self:getNode("mpbar_pet"):setVisible(true)
  self:getNode("txt_level_pet"):setVisible(true)
  if self.m_AddPetHeadSprite ~= nil then
    self.m_AddPetHeadSprite:removeFromParent()
    self.m_AddPetHeadSprite = nil
  end
  local head = createHeadIconByRoleTypeID(typeId, nil, gray)
  local temp = self.btn_menu_pet:getVirtualRenderer()
  local size = temp:getContentSize()
  temp:addChild(head)
  head:setPosition(ccp(size.width / 2, size.height / 2 + 8))
  head:setScale(0.8)
  self.m_AddPetHeadSprite = head
  self.m_AddPetHeadSprite._gray = gray
  self:getNode("txt_level_pet"):setText(string.format("%d转%d", zs, lv))
end
function warui:updatePetLvBg()
  local showFlag = true
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhaohuanshou)
  if openFlag == false then
    showFlag = false
  end
  self:getNode("pic_levelbg_pet"):setVisible(showFlag)
  self:getNode("hpbar_pet"):setVisible(false)
  self:getNode("mpbar_pet"):setVisible(false)
  self:getNode("txt_level_pet"):setVisible(false)
end
function warui:updateHeadData()
  print("warui:updateHeadData")
  if self.m_WarScene then
    local heroData, petData = self.m_WarScene:getMainHeroAndPetDataAfterCreateWarUI()
    if heroData ~= nil then
      self:SetHPBar(heroData.hp or 0, heroData.maxHp or 0)
      self:SetMPBar(heroData.mp or 0, heroData.maxMp or 0)
      self:SetMainRoleHead(heroData.typeId or 0, heroData.zs or 0, heroData.lv or 0)
    end
    if petData ~= nil then
      self:SetPetHPBar(petData.hp or 0, petData.maxHp or 0)
      self:SetPetMPBar(petData.mp or 0, petData.maxMp or 0)
      self:SetPetHead(petData.typeId or 0, petData.zs or 0, petData.lv or 0)
    end
  end
  self:UpdateDefaultSettingIcons()
end
function warui:DelSelectView()
  if self.m_SelectView ~= nil then
    self.m_SelectView:CloseSelf()
    self.m_SelectView = nil
  end
  if self.m_RunAwayPopView ~= nil then
    self.m_RunAwayPopView:OnClose()
    self.m_RunAwayPopView = nil
  end
end
function warui:ShowSelectAutoView(initPetPage)
  if self.m_WarScene == nil then
    return
  end
  self:DelAutoSelectView()
  local heroPos = self.m_HeroPos
  local petPos = self.m_PetPos
  local heroObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_HeroPos)
  local petObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_PetPos)
  if heroObj == nil then
    return
  end
  local selectAutoSkillView = selectAutoSkill.new(self, heroObj, heroPos, petObj, petPos, initPetPage)
  if selectAutoSkillView ~= nil then
    getCurSceneView():addSubView({
      subView = selectAutoSkillView,
      zOrder = MainUISceneZOrder.menuView
    })
    self.m_AutoSelectView = selectAutoSkillView
  end
end
function warui:DelAutoSelectView()
  if self.m_AutoSelectView ~= nil then
    self.m_AutoSelectView:CloseSelf()
    self.m_AutoSelectView = nil
  end
end
function warui:Action_MoveBtns(callback)
  self:stopAllActions()
  local delTime = BtnActionTime
  local delPos = BtnActionPos
  for _, btnName in pairs(self.m_Btn_ActionBtnNameDict) do
    do
      local btn = self[btnName]
      btn:setTouchEnabled(false)
      btn:stopAllActions()
      local posOut = self.m_Btn_ActionBtnHidePos
      local posIn = self.m_Btn_ActionBtnPosDict[btnName]
      local actOut
      if self.m_SimpleFlag then
        if btnName == "m_Btn_Skill1" or btnName == "m_Btn_Skill2" or btnName == "m_Btn_TeJi" or btnName == "m_Btn_Attack" or btnName == "m_Btn_Magic" then
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
        actSetPos = CCCallFunc:create(function()
          if btnName == "m_Btn_Skill1" or btnName == "m_Btn_Skill2" or btnName == "m_Btn_TeJi" or btnName == "m_Btn_Attack" or btnName == "m_Btn_Magic" then
            btn:setPosition(ccp(posIn.x + delPos, posIn.y))
          else
            btn:setPosition(ccp(posIn.x, posIn.y - delPos))
          end
        end)
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
  local act2 = CCCallFunc:create(callback)
  local act3 = CCDelayTime:create(delTime)
  local act4 = CCCallFunc:create(function()
    for _, btnName in pairs(self.m_Btn_ActionBtnNameDict) do
      local btn = self[btnName]
      btn:setTouchEnabled(true)
    end
  end)
  self:runAction(transition.sequence({
    act1,
    act2,
    act3,
    act4
  }))
end
function warui:Action_FadeOutBtns(callback)
  self.m_CanSettingDataFlag = false
  local delTime = BtnActionTime
  self:stopAllActions()
  for _, btnName in pairs(self.m_Btn_ActionBtnNameDict) do
    local btn = self[btnName]
    btn:stopAllActions()
    btn:setTouchEnabled(false)
    if btnName == "m_Btn_Skill1" or btnName == "m_Btn_Skill2" then
      local skillImg = btn:getVirtualRenderer():getChildByTag(BTN_SKILLIMG_TAG)
      if skillImg ~= nil then
        btn:getVirtualRenderer():removeChild(skillImg)
      end
      local addImg = btn:getVirtualRenderer():getChildByTag(BTN_ADD_TAG)
      if addImg ~= nil then
        btn:getVirtualRenderer():removeChild(addImg)
      end
    end
    btn:runAction(CCFadeOut:create(delTime))
  end
  local act1 = CCDelayTime:create(delTime * 2)
  local act2 = CCCallFunc:create(callback)
  self:runAction(transition.sequence({act1, act2}))
end
function warui:Action_FadeInBtns(callback)
  self.m_CanSettingDataFlag = true
  local isPetFlag = false
  local settingRole = self.m_WarScene:getLocalRoleDataObjByPos(self.m_CurSettingPos)
  if settingRole ~= nil and settingRole:getType() == LOGICTYPE_PET then
    isPetFlag = true
  end
  if isPetFlag then
    self.m_Btn_ActionBtnPosDict.m_Btn_RunAway = self.m_PetRunBtnPos
  else
    self.m_Btn_ActionBtnPosDict.m_Btn_RunAway = self.m_HeroRunBtnPos
  end
  local delTime = BtnActionTime
  self:stopAllActions()
  for _, btnName in pairs(self.m_Btn_ActionBtnNameDict) do
    local btn = self[btnName]
    btn:stopAllActions()
    btn:setPosition(self.m_Btn_ActionBtnPosDict[btnName])
    btn:setTouchEnabled(true)
    btn:runAction(CCFadeIn:create(delTime))
  end
  if callback == nil then
    return
  end
  local act1 = CCDelayTime:create(delTime)
  local act2 = CCCallFunc:create(callback)
  self:runAction(transition.sequence({act1, act2}))
end
function warui:ShowOpTips(flag)
  self:getNode("txt_tips1"):setVisible(flag)
  self:getNode("txt_tips2"):setVisible(not flag)
  self:getNode("txt_tipsbg"):setVisible(true)
  if flag and self:getNode("txt_tips1"):getOpacity() == 0 then
    self:getNode("txt_tipsbg"):setVisible(false)
  elseif flag == false and self:getNode("txt_tips2"):getOpacity() == 0 then
    self:getNode("txt_tipsbg"):setVisible(false)
  end
  self:getNode("txt_tips_skillname"):setVisible(flag)
  if flag then
    self:getNode("txt_tips_skillname"):setText("")
    local actionType = self.m_CurSettingData.aiActionType
    if actionType == AI_ACTION_TYPE_NORMALATTACK then
      self:getNode("txt_tips_skillname"):setText("攻击")
    elseif actionType == AI_ACTION_TYPE_CATCH then
      self:getNode("txt_tips_skillname"):setText("抓捕")
    elseif actionType == AI_ACTION_TYPE_PROTECT then
      self:getNode("txt_tips_skillname"):setText("保护")
    elseif actionType == AI_ACTION_TYPE_USEDRUG then
      local drugShapeId = self.m_CurSettingData.useDrugTypeId
      local drugName = data_getItemName(drugShapeId)
      if drugName then
        self:getNode("txt_tips_skillname"):setText(drugName)
      else
        self:getNode("txt_tips_skillname"):setText("用药")
      end
    elseif actionType == AI_ACTION_TYPE_USESKILL then
      local skillId = self.m_CurSettingData.skillId
      local skillName = data_getSkillName(skillId)
      if skillName then
        self:getNode("txt_tips_skillname"):setText(skillName)
      else
        self:getNode("txt_tips_skillname"):setText("法术")
      end
    end
  end
end
function warui:ShowStartOpTips(text)
  if text == "" then
    self:getNode("txt_tips2"):setOpacity(0)
    self:getNode("txt_tipsbg"):setVisible(false)
  else
    self:getNode("txt_tips2"):setOpacity(255)
    self:getNode("txt_tips2"):setText(text)
    self:getNode("txt_tipsbg"):setVisible(true)
  end
end
function warui:StartTimer(passtime)
  printLog("warui", "StartTimer")
  passtime = passtime or 0
  self.m_CurTimeNum = nil
  self.m_TimeNum = 0
  self.m_RunningFlag = true
  self.m_TimeText:setVisible(true)
  self:SetTimeText(passtime)
end
function warui:StopTimer()
  printLog("warui", "StopTimer")
  self.m_RunningFlag = false
  self.m_TimeText:setVisible(false)
end
function warui:TimerTimesUp()
  printLog("warui", "设置时间到")
  self:StopTimer()
  self:SetAutoFlag(true)
end
function warui:SetTimeText(passTime)
  self.m_TimeNum = passTime
  local allTime = self.m_SettingTimeMaxNum
  local num = allTime - self.m_TimeNum
  self.m_TimeText:setText(string.format("%d", num))
  if self.m_AutoFightFlag and num <= PerRoundTime - DelayTimeForAutoFight then
    printLog("warui", "自动战斗缓冲时间到")
    self.m_WaitingAutoDelay = false
    self:EndOneRoundFightSetting()
    return
  end
  if num <= 0 then
    self:TimerTimesUp()
  end
end
function warui:TimeUpdate(dt)
  if self.m_RunningFlag == false then
    return
  end
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_CurTimeNum == nil then
    self.m_CurTimeNum = curTime
    return
  end
  if curTime <= self.m_CurTimeNum then
    return
  end
  local delTime = curTime - self.m_CurTimeNum
  self:SetTimeText(self.m_TimeNum + delTime)
  self.m_CurTimeNum = curTime
end
function warui:SaveWaruiSetting()
  if g_LocalPlayer == nil then
    return
  end
  if self.m_WarScene == nil then
    return
  end
  local warUISetting = {}
  warUISetting.autoFlag = self.m_AutoFightFlag
  warUISetting.simpleFlag = self.m_SimpleFlag
  local defaultData = {}
  local heroObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_HeroPos)
  local petObj = self.m_WarScene:getLocalRoleDataObjByPos(self.m_PetPos)
  for pos, data in pairs(self.m_DefaultSettingData) do
    if pos == self.m_HeroPos then
      defaultData.heroPos = data
    end
  end
  warUISetting.defaultData = defaultData
  g_LocalPlayer:SaveWarUISetting(warUISetting)
end
function warui:SaveFightSettingToSer()
  if g_LocalPlayer == nil then
    return
  end
  if self.m_WarScene == nil then
    return
  end
  local t_h = {}
  local t_p = {}
  for pos, data in pairs(self.m_DefaultSettingData) do
    if pos == self.m_HeroPos then
      t_h = DeepCopyTable(data)
      t_h.oid = 1
    elseif pos == self.m_PetPos then
      if self.m_SavePetAutoSettingData then
        t_p = DeepCopyTable(self.m_SavePetAutoSettingData)
      end
      local pId = t_p.oid
      local autoData = 0
      local aiActionType = self.m_SavePetAutoSettingData.aiActionType
      if aiActionType == AI_ACTION_TYPE_NORMALATTACK then
        autoData = 10
      elseif aiActionType == AI_ACTION_TYPE_DEFEND then
        autoData = 20
      elseif aiActionType == AI_ACTION_TYPE_USESKILL then
        local caFlag = self.m_SavePetAutoSettingData.caFlag
        local skillId = self.m_SavePetAutoSettingData.skillId
        if caFlag == nil or caFlag == true then
          autoData = skillId * 10 + 1
        else
          autoData = skillId * 10 + 0
        end
      end
      netsend.netbaseptc.requestSetPetAutoFightData(pId, autoData)
    end
  end
  netsend.netteamwar.setAutoFightSetting(t_h, t_p)
end
function warui:ShowFriendTip(num)
  if num > 99 then
    num = 99
  end
  self.pic_tipnew_friend:setVisible(num > 0)
  self.unread_friend:setText(tostring(num))
end
function warui:CheckShowNewMailTip()
  local newMailFlag = g_MailMgr:getIsHasNewMail()
  self:ShowBtnRedIcon(self.btn_menu_friend, newMailFlag)
end
function warui:SetMenuViewBtns()
  self.m_MenuSimpleFlag = false
  self:setMenuBtnShowPara()
  self:ShowMenuViewBtns()
  self:checkIsInBp()
  self:SetMenuBtnPos()
  self:SetMenuSimpleFlag(self.m_MenuSimpleFlag)
  for _, btnName in pairs(self.m_Btn_CheckCircle) do
    local btn = self[btnName]
    if btn and g_CMainMenuHandler then
      local asBtn = g_CMainMenuHandler[btnName]
      if asBtn then
        local flag = asBtn.redIcon ~= nil
        self:ShowBtnRedIcon(btn, flag)
        flag = asBtn.lightCircle ~= nil
        self:ShowBtnLightCircle(btn, flag)
        if btnName == "btn_menu_tool" then
          flag = asBtn.fullIcon ~= nil
          self:ShowPackageBtnFullIcon(flag)
        end
      end
    end
  end
end
function warui:SetMenuSimpleFlag(simpleFlag)
  self.m_MenuSimpleFlag = false
  self:ShowMenuViewBtns()
end
function warui:Action_MoveMenuBtns(callback1, callback2)
  self:stopAllActions()
  local delTime = BtnActionTime
  local delPos = BtnActionPos
  self.m_IsMenuBtnAction = true
  for _, btnName in pairs(self.m_MenuBtn_ActionBtnNameDict) do
    do
      local btn = self[btnName]
      btn:stopAllActions()
      local posOut = self.m_MenuBtn_ActionBtnHidePos
      local posIn = self.m_MenuBtn_ActionBtnPosDict[btnName]
      local actOut
      if self.m_MenuSimpleFlag then
        if btnName == "btn_menu_huoban" then
          posIn = self.m_MenuBtn_ActionBtnPosDict.btn_menu_skill
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
      if self.m_MenuSimpleFlag then
        actSetPos = CCCallFunc:create(function()
          btn:setPosition(ccp(posOut.x, posOut.y))
        end)
      else
        if btnName == "btn_menu_huoban" then
          posIn = self.m_MenuBtn_ActionBtnPosDict.btn_menu_skill
        end
        actSetPos = CCCallFunc:create(function()
          if btnName == "btn_menu_tool" then
            btn:setPosition(ccp(posIn.x + delPos, posIn.y))
          else
            btn:setPosition(ccp(posIn.x, posIn.y - delPos))
          end
        end)
      end
      posIn = self.m_MenuBtn_ActionBtnPosDict[btnName]
      if btnName == "btn_menu_huoban" then
        if self.m_MenuSimpleFlag then
          posIn = self.m_MenuBtn_ActionBtnPosDict.btn_menu_huoban
        else
          posIn = self.m_MenuBtn_ActionBtnPosDict.btn_menu_skill
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
    self.m_IsMenuBtnAction = false
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
function warui:Action_MoveTopBtns(callback1, callback2)
  self:stopAllActions()
  local delTime = BtnActionTime
  local delPos = BtnActionPos
  self.m_IsMenuTopBtnAction = true
  for _, btnName in pairs(self.m_Btn_ActionTopBtnNameDict) do
    local btn = self[btnName]
    btn:stopAllActions()
    local x, y = self.btn_menu_top_open:getPosition()
    local posOut = ccp(x, y)
    local posIn = self.m_Btn_ActionTopBtnPosDict[btnName]
    local act
    if self.m_TopSimpleFlag then
      btn:setPosition(ccp(posOut.x, posOut.y))
      act = CCMoveTo:create(delTime, posIn)
    else
      btn:setPosition(ccp(posIn.x, posIn.y))
      act = CCMoveTo:create(delTime, posOut)
    end
    btn:runAction(act)
  end
  if self.m_TopSimpleFlag then
    local act1 = CCDelayTime:create(0)
    local act2
    if callback1 == nil then
      act2 = CCDelayTime:create(0)
    else
      act2 = CCCallFunc:create(callback1)
    end
    local act3 = CCDelayTime:create(delTime)
    local act4 = CCCallFunc:create(function()
      self.m_IsMenuTopBtnAction = false
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
  else
    local act1 = CCDelayTime:create(delTime)
    local act2
    if callback1 == nil then
      act2 = CCDelayTime:create(0)
    else
      act2 = CCCallFunc:create(callback1)
    end
    local act3 = CCDelayTime:create(0)
    local act4 = CCCallFunc:create(function()
      self.m_IsMenuTopBtnAction = false
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
end
function warui:setMenuBtnShowPara()
  self.m_BtnNotOpenFlagDict = {}
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
    [OPEN_Func_Shangcheng] = {
      "btn_menu_shop",
      "views/mainviews/btn_shangcheng.png",
      "views/mainviews/btn_shangcheng_gray.png"
    },
    [OPEN_Func_Market] = {
      "btn_menu_market",
      "views/mainviews/btn_market.png",
      "views/mainviews/btn_market_gray.png"
    },
    [OPEN_Func_Rank] = {
      "btn_menu_rank",
      "views/mainviews/btn_rank.png",
      "views/mainviews/btn_rank_gray.png"
    },
    [OPEN_Func_Duiwu] = {
      "btn_menu_team",
      "views/mainviews/btn_team_war.png",
      "views/mainviews/btn_team_war_gray.png"
    },
    [OPEN_Func_DoubleExp] = {
      "btn_menu_doubleexp",
      "views/mainviews/btn_doubleexp_war.png",
      "views/mainviews/btn_doubleexp_war_gray.png"
    },
    [OPEN_Func_Biwu] = {
      "btn_menu_biwu",
      "views/mainviews/btn_biwu.png",
      "views/mainviews/btn_biwu_gray.png"
    }
  }
  for funcId, data in pairs(tempDict) do
    local btnName = data[1]
    local nPath = data[2]
    local gPath = data[3]
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(funcId)
    local btn = self[btnName]
    if openFlag == false then
      self.m_BtnNotOpenFlagDict[btnName] = true
    elseif noOpenType == OPEN_FUNC_Type_Hide then
      self.m_BtnNotOpenFlagDict[btnName] = false
    end
  end
  if g_TeamMgr:getLocalPlayerTeamId() == 0 then
    self.m_BtnNotOpenFlagDict.btn_menu_dailyword = true
    self.m_BtnNotOpenFlagDict.btn_voice_team = true
  else
    self.m_BtnNotOpenFlagDict.btn_menu_dailyword = false
    self.m_BtnNotOpenFlagDict.btn_voice_team = false
  end
  self.m_MenuBtn_ActionBtnPosDict = {}
end
function warui:ShowMenuViewBtns()
  self.btn_menu_top_open:setEnabled(self.m_TopSimpleFlag)
  self.btn_menu_top_close:setEnabled(not self.m_TopSimpleFlag)
  self.btn_menu_shop:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_shop and not self.m_TopSimpleFlag)
  self.btn_menu_market:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_market and not self.m_TopSimpleFlag)
  self.btn_menu_rank:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_rank and not self.m_TopSimpleFlag)
  self.btn_menu_huodong:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_huodong and not self.m_TopSimpleFlag)
  self.btn_menu_team:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_team and not self.m_TopSimpleFlag)
  self.btn_menu_doubleexp:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_doubleexp and not self.m_TopSimpleFlag)
  self.btn_menu_biwu:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_biwu and not self.m_TopSimpleFlag)
  self.btn_menu_mission:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_mission and not self.m_TopSimpleFlag)
  self.btn_menu_eqptupgrade:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_eqptupgrade and self.m_AutoFightFlag and not self.m_MenuSimpleFlag)
  self.btn_menu_skill:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_skill and self.m_AutoFightFlag and not self.m_MenuSimpleFlag)
  self.btn_menu_huoban:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_huoban and self.m_AutoFightFlag)
  self.btn_menu_zuoqi:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_zuoqi and self.m_AutoFightFlag and not self.m_MenuSimpleFlag)
  self.btn_menu_pet:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_pet and true)
  self.btn_menu_guild:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_guild and self.m_AutoFightFlag and not self.m_MenuSimpleFlag)
  self.btn_menu_tool:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_tool and self.m_AutoFightFlag)
  self:getNode("pic_topbg"):setVisible(not self.m_TopSimpleFlag)
  local topShowBtnNum = 0
  for _, btnName in pairs(self.m_Btn_ActionTopBtnNameDict) do
    if self.m_BtnNotOpenFlagDict[btnName] == true then
    else
      topShowBtnNum = topShowBtnNum + 1
    end
  end
  local lineNum = math.floor(topShowBtnNum / 3)
  if topShowBtnNum % 3 == 0 then
  else
    lineNum = lineNum + 1
  end
  local width = self:getNode("pic_topbg"):getSize().width
  local height = 270
  if lineNum == 1 then
    height = 90
  elseif lineNum == 2 then
    height = 180
  else
    height = 270
  end
  self:getNode("pic_topbg"):setSize(CCSize(width, height))
end
function warui:SetMenuBtnPos()
  local tempDict = {
    {
      "btn_menu_shop",
      "btn_menu_market",
      "btn_menu_rank",
      "btn_menu_huodong",
      "btn_menu_team",
      "btn_menu_doubleexp",
      "btn_menu_biwu",
      "btn_menu_mission"
    },
    {
      "btn_menu_friend",
      "btn_menu_sociality",
      "btn_voice_world",
      "btn_voice_bp",
      "btn_voice_team",
      "btn_menu_dailyword"
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
        print("--->>>hhh 没有开启:", btnName)
        local cp = self.m_MenuBtn_ActionBtnOldPosDict[btnName]
        self.m_MenuBtn_ActionBtnPosDict[btnName] = ccp(cp.x, cp.y)
      else
        print("--->>>ooo 开启:", btnName)
        for _, posBtnName in ipairs(btnList) do
          if posFlag[posBtnName] ~= true then
            local cp = self.m_MenuBtn_ActionBtnOldPosDict[posBtnName]
            self.m_MenuBtn_ActionBtnPosDict[btnName] = ccp(cp.x, cp.y)
            posFlag[posBtnName] = true
            print("--->>>ooo 调整:", btnName, posBtnName, cp.x, cp.y)
            break
          end
        end
      end
      local cp = self.m_MenuBtn_ActionBtnPosDict[btnName]
      self[btnName]:setPosition(ccp(cp.x, cp.y))
    end
  end
  if self.m_MenuSimpleFlag then
    local cp = self.m_MenuBtn_ActionBtnOldPosDict.btn_menu_skill
    self.btn_menu_huoban:setPosition(ccp(cp.x, cp.y))
    local cp = self.m_MenuBtn_ActionBtnOldPosDict.btn_menu_tool
    self.btn_menu_tool:setPosition(ccp(cp.x, cp.y))
  end
end
function warui:initBtnsPosWithMsgBoxMode()
  for _, btnName in pairs({
    "btn_menu_friend",
    "btn_menu_sociality",
    "btn_voice_world",
    "btn_voice_bp",
    "btn_voice_team",
    "btn_menu_dailyword"
  }) do
    local temp = self:getNode(btnName)
    if temp then
      local _, y = temp:getPosition()
      temp.__initY = y
    end
  end
end
function warui:setBtnsPosWithMsgBoxMode(isSmall, off)
  for _, btnName in pairs({
    "btn_menu_friend",
    "btn_menu_sociality",
    "btn_voice_world",
    "btn_voice_bp",
    "btn_voice_team",
    "btn_menu_dailyword"
  }) do
    local temp = self:getNode(btnName)
    local btnPos = self.m_MenuBtn_ActionBtnPosDict[btnName]
    if temp and btnPos then
      if isSmall then
        temp:setPosition(ccp(btnPos.x, temp.__initY))
      else
        temp:setPosition(ccp(btnPos.x, temp.__initY + off))
      end
      if self.m_MenuBtn_ActionBtnPosDict ~= nil then
        local _, y = temp:getPosition()
        self.m_MenuBtn_ActionBtnPosDict[btnName] = ccp(btnPos.x, y)
      end
      if self.m_MenuBtn_ActionBtnOldPosDict ~= nil then
        local btnOldPos = self.m_MenuBtn_ActionBtnOldPosDict[btnName]
        if btnOldPos then
          local _, y = temp:getPosition()
          self.m_MenuBtn_ActionBtnOldPosDict[btnName] = ccp(btnOldPos.x, y)
        end
      end
    end
  end
end
function warui:OnBtn_Menu_Add(btnObj, touchType)
  print("warui:OnBtn_Menu_Add")
  if self.m_IsMenuBtnAction then
    return
  end
  self:Action_MoveMenuBtns(function()
    self:SetMenuSimpleFlag(not self.m_MenuSimpleFlag)
  end)
end
function warui:OnBtn_Menu_TopAdd(btnObj, touchType)
  print("warui:OnBtn_Menu_TopAdd")
  self:SetTopSimpleFlag(false)
end
function warui:OnBtn_Menu_TopClose(btnObj, touchType)
  print("warui:OnBtn_Menu_TopClose")
  self:SetTopSimpleFlag(true)
end
function warui:OnBtn_Menu_Shop(btnObj, touchType)
  if g_CMainMenuHandler then
    g_CMainMenuHandler:OnBtn_Menu_Shop()
  end
end
function warui:OnBtn_Menu_Market(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_market"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Market")
  if self.btn_menu_market.redIcon ~= nil then
    enterMarket({initViewType = MarketShow_InitShow_CoinView, initBaitanType = BaitanShow_InitShow_StallView})
  else
    enterMarket()
  end
end
function warui:OnBtn_Menu_Rank(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_rank"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Rank")
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
function warui:OnBtn_Menu_Huodong(btnObj, touchType)
  print("warui:OnBtn_Menu_Huodong")
  local tempView = CHuodongShow.new({InitHuodongShow = HuodongShow_EventView})
  getCurSceneView():addSubView({
    subView = tempView,
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui:OnBtn_Menu_Doubleexp(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_doubleexp"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Doubleexp")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_DoubleExp)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CDoubleExpView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui:OnBtn_Menu_BiWu(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_biwu"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_BiWu")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Biwu)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  ShowBattlePvpDlg()
end
function warui:OnBtn_Menu_Mission(btnObj, touchType)
  print("warui:OnBtn_Menu_Mission")
  getCurSceneView():addSubView({
    subView = CMissionView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui:OnBtn_Menu_Team()
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
function warui:OnBtn_Menu_Guild(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_guild"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Guild")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_BangPai)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  ShowBangPaiDlg()
end
function warui:OnBtn_Menu_EqptUpgrade(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_eqptupgrade"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_EqptUpgrade")
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
function warui:OnBtn_Menu_Skill(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_skill"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Skill")
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
function warui:OnBtn_Menu_HuoBan(btnObj, touchType)
  print("warui:OnBtn_Menu_HuoBan")
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
function warui:OnBtn_Menu_Zuoqi(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_zuoqi"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Zuoqi")
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
function warui:OnBtn_Menu_Pet(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_pet"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Pet")
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
function warui:OnBtn_Menu_Tool(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_tool"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui:OnBtn_Menu_Tool")
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
function warui:OnTouch_HeadIcon(btnObj, touchType)
  getCurSceneView():addSubView({
    subView = settingDlg.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui:ShowBtnRedIcon(btn, flag)
  if btn == nil then
    return
  end
  if flag then
    if btn.redIcon == nil then
      local redIcon = display.newSprite("views/pic/pic_tipnew.png")
      btn:addNode(redIcon, 0)
      if btn == self.btn_menu_friend or btn == self.btn_menu_sociality then
        redIcon:setPosition(ccp(15, 15))
      elseif btn == self.btn_menu_top_open then
        redIcon:setPosition(ccp(-15, 15))
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
      "btn_menu_pet",
      "btn_menu_guild"
    }) do
      local tempBtn = self[tempBtnName]
      if tempBtn ~= nil and (tempBtn.redIcon ~= nil or tempBtn.lightCircle ~= nil) and (self.m_BtnNotOpenFlagDict[tempBtnName] == false or self.m_BtnNotOpenFlagDict[tempBtnName] == nil) then
        addFlag = true
        break
      end
    end
    addFlag = addFlag and flag ~= false and self.m_MenuSimpleFlag
    if addFlag then
      if btn.redIcon == nil then
        local redIcon = display.newSprite("views/pic/pic_tipnew.png")
        btn:addNode(redIcon, 0)
        redIcon:setPosition(ccp(-25, -25))
        btn.redIcon = redIcon
      end
    elseif btn.redIcon then
      btn.redIcon:removeFromParent()
      btn.redIcon = nil
    end
  elseif btn == self.btn_menu_top_open then
    local addFlag = false
    for _, tempBtnName in pairs({
      "btn_menu_shop",
      "btn_menu_market",
      "btn_menu_rank",
      "btn_menu_huodong",
      "btn_menu_team",
      "btn_menu_doubleexp",
      "btn_menu_biwu",
      "btn_menu_mission"
    }) do
      local tempBtn = self[tempBtnName]
      if tempBtn ~= nil and (tempBtn.redIcon ~= nil or tempBtn.lightCircle ~= nil) and (self.m_BtnNotOpenFlagDict[tempBtnName] == false or self.m_BtnNotOpenFlagDict[tempBtnName] == nil) then
        addFlag = true
        break
      end
    end
    addFlag = addFlag and flag ~= false and self.m_TopSimpleFlag
    if addFlag then
      if btn.redIcon == nil then
        local redIcon = display.newSprite("views/pic/pic_tipnew.png")
        btn:addNode(redIcon, 0)
        redIcon:setPosition(ccp(-15, 15))
        btn.redIcon = redIcon
      end
    elseif btn.redIcon then
      btn.redIcon:removeFromParent()
      btn.redIcon = nil
    end
  else
    self:ShowBtnRedIcon(self.btn_menu_add)
    self:ShowBtnRedIcon(self.btn_menu_top_open)
  end
end
function warui:ShowBtnLightCircle(btn, flag)
  if btn == nil then
    return
  end
  if flag then
    if btn.lightCircle == nil then
      local eff = CreateSeqAnimation("xiyou/ani/btn_circle.plist", -1)
      if eff then
        eff:setPosition(ccp(0, 3))
        if btn == self.btn_menu_friend or btn == self.btn_menu_sociality then
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
end
function warui:removeAllBtnLightCircle()
  for _, btnName in pairs(self.m_Btn_CheckCircle) do
    local btn = self[btnName]
    if btn and btn.lightCircle then
      btn.lightCircle:removeFromParent()
      btn.lightCircle = nil
    end
  end
end
function warui:ShowPackageBtnFullIcon(flag)
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
end
function warui:removePackageBtnFullIcon()
  if self.btn_menu_tool and self.btn_menu_tool.fullIcon ~= nil then
    self.btn_menu_tool.fullIcon:removeFromParent()
    self.btn_menu_tool.fullIcon = nil
  end
end
function warui:EndWarUnShowWarUI()
end
function warui:Clear()
  print("------->>> warui Clear!!")
  self:ClearWarUi()
  self:SaveWaruiSetting()
  self:SaveFightSettingToSer()
  self.m_WarScene = nil
  self:DelSelectView()
  self:DelAutoSelectView()
  if self.m_UpdateHandler then
    scheduler.unscheduleGlobal(self.m_UpdateHandler)
    self.m_UpdateHandler = nil
  end
end
return warui

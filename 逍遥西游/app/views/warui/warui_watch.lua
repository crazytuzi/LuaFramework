warui_watch = class("warui_watch", CcsSubView)
local BtnActionPos = 200
local BtnActionTime = 0.2
function warui_watch:ctor(warScene)
  warui_watch.super.ctor(self, "views/war_ui.json")
  self.m_WarScene = warScene
  self:getNode("btns_layout"):setEnabled(false)
  self:getNode("timeNum"):setVisible(false)
  self:getNode("waittext"):setVisible(false)
  self:getNode("btn_setdefault"):setEnabled(false)
  self:getNode("btn_back"):setEnabled(false)
  self:getNode("txt_tips_skillname"):setVisible(false)
  self:getNode("txt_tips1"):setVisible(false)
  self:getNode("txt_tips2"):setVisible(false)
  self:getNode("txt_tipsbg"):setVisible(false)
  self:getNode("layer_huoli"):setVisible(false)
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
      listener = handler(self, self.Btn_Quit),
      variName = "m_Btn_Quit"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_RoundNum = 0
  self.m_TopSimpleFlag = true
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
  self.m_Btn_ActionTopBtnPosDict = {}
  self.m_Btn_Quit:loadTextureNormal("views/warui/btn_quitwatch.png")
  self:SetMainRoleHead(g_LocalPlayer:getMainHero():getTypeId())
  self:InitMsgBoxAndSociality()
  self:SetMenuViewBtns()
  for _, btnName in pairs(self.m_Btn_ActionTopBtnNameDict) do
    local x, y = self[btnName]:getPosition()
    self.m_Btn_ActionTopBtnPosDict[btnName] = ccp(x, y)
  end
  self:initBtnsPosWithMsgBoxMode()
  local mainMsgBox = g_CMainMenuHandler:getMsgbox()
  if mainMsgBox then
    local isSmallMode = mainMsgBox:getIsSmallMode()
    self.m_Msgbox:SetSmallModeAdjust(isSmallMode, false)
    local off = self.m_Msgbox:getAddHeight()
    self:setBtnsPosWithMsgBoxMode(isSmallMode, off)
  end
  self:updatePetLvBg()
  self:InitExpBar()
  self:updateExp()
  self:SetTopSimpleFlag(true)
  self:getUINode():setSize(CCSize(display.width, display.height))
  self.pic_tipnew_friend = self:getNode("pic_tipnew_friend")
  self.unread_friend = self:getNode("unread_friend")
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
  BpwarStateInfo.extend(self, self:getNode("layer_bpwar"))
  self:setVisible(false)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_Team)
end
function warui_watch:InitShow()
  self:setVisible(true)
end
function warui_watch:InitExpBar()
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
function warui_watch:updateExp()
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
function warui_watch:GetIsShowFighting()
  return true
end
function warui_watch:UIStartRunAction()
end
function warui_watch:SetWaittextShow()
end
function warui_watch:SetRoundNum(num)
  self.m_RoundNum = num
  self:getNode("huiheText"):setVisible(true)
  self:getNode("huiheText"):setText(string.format("%d", num))
end
function warui_watch:StartOneRoundFightSetting(round, passtime)
  printLog("warui_watch", "StartOneRoundFightSetting")
  self:SetRoundNum(round)
end
function warui_watch:EndOneRoundFightSetting(timesupFlag)
end
function warui_watch:SetMainRoleHead(typeId)
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
  local heroIns = g_LocalPlayer:getMainHero()
  if heroIns then
    local zs = heroIns:getProperty(PROPERTY_ZHUANSHENG)
    local lv = heroIns:getProperty(PROPERTY_ROLELEVEL)
    self:getNode("txt_level"):setText(string.format("%d转%d", zs, lv))
  end
end
function warui_watch:updatePetLvBg()
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
  if hasPetFlag then
    self:getNode("hpbar_pet"):setVisible(true)
    self:getNode("mpbar_pet"):setVisible(true)
    self:getNode("txt_level_pet"):setVisible(true)
    local petIns = g_LocalPlayer:getObjById(petId)
    if petIns ~= nil then
      local heroZs = zs
      local petZs = petIns:getProperty(PROPERTY_ZHUANSHENG)
      local petLv = petIns:getProperty(PROPERTY_ROLELEVEL)
      self:getNode("txt_level_pet"):setText(string.format("%d转%d", petZs, petLv))
    end
    if self.m_AddPetIconSprite then
      self.m_AddPetIconSprite:removeFromParent()
      self.m_AddPetIconSprite = nil
    end
    if self.m_AddPetHeadSprite ~= nil then
      self.m_AddPetHeadSprite:removeFromParent()
    end
    local typeId = petIns:getTypeId()
    local head = createHeadIconByRoleTypeID(typeId)
    local temp = self.btn_menu_pet:getVirtualRenderer()
    local size = temp:getContentSize()
    temp:addChild(head)
    head:setPosition(ccp(size.width / 2, size.height / 2 + 8))
    head:setScale(0.8)
    self.m_AddPetHeadSprite = head
  else
    self:getNode("hpbar_pet"):setVisible(false)
    self:getNode("mpbar_pet"):setVisible(false)
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
function warui_watch:Btn_Quit(btnObj, touchType)
  if self.m_WarScene then
    local wid = self.m_WarScene:getWarID()
    if wid ~= nil then
      netsend.netteamwar.requestQuitWatchWar(wid)
    end
  end
end
function warui_watch:InitMsgBoxAndSociality()
  local btnBatchListener = {
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
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_voice_team = self:getNode("btn_voice_team")
  self.btn_voice_bp = self:getNode("btn_voice_bp")
  self.btn_voice_world = self:getNode("btn_voice_world")
  VoiceRecordBtnExtend.extend(self.btn_voice_team, CHANNEL_TEAM)
  VoiceRecordBtnExtend.extend(self.btn_voice_bp, CHANNEL_BP_MSG)
  VoiceRecordBtnExtend.extend(self.btn_voice_world, CHANNEL_WOLRD)
  self.chatbox = self:getNode("chatbox")
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
  self.chatbox:setOpacity(0)
  self.m_Msgbox = CMsgBox.new()
  self.chatbox:addChild(self.m_Msgbox:getUINode())
  local mainMsgBox = g_CMainMenuHandler:getMsgbox()
  if mainMsgBox then
    local content = mainMsgBox:GetContent()
    self.m_Msgbox:SetContent(content)
  end
  self:ShowBtnRedIcon(self.btn_menu_sociality, false)
  self:CheckShowNewMailTip()
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Mail)
end
function warui_watch:checkIsInBp()
  if g_BpMgr:localPlayerHasBangPai() then
    self.btn_voice_bp:setVisible(true)
    self.btn_voice_bp:setTouchEnabled(true)
    self.m_BtnNotOpenFlagDict.btn_voice_bp = false
  else
    self.btn_voice_bp:setVisible(false)
    self.btn_voice_bp:setTouchEnabled(false)
    self.m_BtnNotOpenFlagDict.btn_voice_bp = true
  end
  self:SetMenuBtnPos()
end
function warui_watch:OnBtn_Menu_Friend(btnObj, touchType)
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
function warui_watch:OnBtn_Menu_Sociality(obj, t)
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
function warui_watch:OnBtn_Menu_DailyWord(obj, t)
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
function warui_watch:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Scene_NewFriendTip then
    self:ShowFriendTip(arg[1])
  elseif msgSID == MsgID_BP_LocalInfo then
    self:checkIsInBp()
  elseif msgSID == MsgID_HeroUpdate then
    self:updatePetLvBg()
    local d = arg[1]
    local lv = d.pro[PROPERTY_ROLELEVEL]
    local zs = d.pro[PROPERTY_ZHUANSHENG]
    local exp = d.pro[PROPERTY_EXP]
    if lv ~= nil or zs ~= nil or exp ~= nil then
      self:updateExp()
    end
  elseif msgSID == MsgID_PetUpdate then
    self:updatePetLvBg()
  elseif msgSID == MsgID_AddPet then
    self:updatePetLvBg()
  elseif msgSID == MsgID_DeletePet then
    self:updatePetLvBg()
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
function warui_watch:onReceiveAddJoinRequest()
  if g_MakeTeamDlg and g_MakeTeamDlg:IsCheckingJoinRequest() then
    self:ShowBtnLightCircle(self.btn_menu_team, false)
  else
    self:ShowBtnLightCircle(self.btn_menu_team, true)
  end
end
function warui_watch:onReceiveClearJoinRequest()
  self:ShowBtnLightCircle(self.btn_menu_team, false)
end
function warui_watch:onReceiveHasCheckJoinRequest()
  self:ShowBtnLightCircle(self.btn_menu_team, false)
end
function warui_watch:onReceiveDelJoinRequest(pid)
  local joinRequest = g_TeamMgr:getJoinRequest()
  if #joinRequest <= 0 then
    self:ShowBtnLightCircle(self.btn_menu_team, false)
  end
end
function warui_watch:ShowFriendTip(num)
  if num > 99 then
    num = 99
  end
  self.pic_tipnew_friend:setVisible(num > 0)
  self.unread_friend:setText(tostring(num))
end
function warui_watch:CheckShowNewMailTip()
  local newMailFlag = g_MailMgr:getIsHasNewMail()
  self:ShowBtnRedIcon(self.btn_menu_friend, newMailFlag)
end
function warui_watch:SetMenuViewBtns()
  local btnBatchListener = {
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
  self:addBatchBtnListener(btnBatchListener)
  self.m_MenuSimpleFlag = false
  self:setMenuBtnShowPara()
  self:ShowMenuViewBtns()
  self:checkIsInBp()
  self:SetMenuBtnPos()
  self:SetMenuSimpleFlag(self.m_MenuSimpleFlag)
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
function warui_watch:SetMenuSimpleFlag(simpleFlag)
  self.m_MenuSimpleFlag = false
  self:ShowMenuViewBtns()
end
function warui_watch:SetTopSimpleFlag(topSimpleFlag)
  self.m_TopSimpleFlag = topSimpleFlag
  if topSimpleFlag == true then
    self:ShowBtnRedIcon(self.btn_menu_top_open, true)
    self.btn_menu_top_open:setScaleX(-1)
  else
    self:ShowBtnRedIcon(self.btn_menu_top_open, false)
    self.btn_menu_top_open:setScaleX(-1)
  end
  self:ShowMenuViewBtns()
end
function warui_watch:Action_MoveMenuBtns(callback1, callback2)
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
          posIn = self.m_MenuBtn_ActionBtnPosDict.btn_menu_skill
        else
          posIn = self.m_MenuBtn_ActionBtnPosDict.btn_menu_zuoqi
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
function warui_watch:Action_MoveTopBtns(callback1, callback2)
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
function warui_watch:setMenuBtnShowPara()
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
    elseif noOpenType == OPEN_FUNC_Type_Gray then
      btn:loadTextureNormal(nPath)
    end
  end
  if g_TeamMgr:getLocalPlayerTeamId() == 0 then
    self.m_BtnNotOpenFlagDict.btn_menu_dailyword = true
    self.m_BtnNotOpenFlagDict.btn_voice_team = true
  else
    self.m_BtnNotOpenFlagDict.btn_menu_dailyword = false
    self.m_BtnNotOpenFlagDict.btn_voice_team = false
  end
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
  self.m_MenuBtn_ActionBtnPosDict = {}
  self.m_MenuBtn_ActionBtnOldPosDict = {}
  local x, y = self.m_Btn_Quit:getPosition()
  self.m_MenuBtn_ActionBtnHidePos = ccp(x, y)
  for _, btnName in pairs(self.m_MenuBtn_AllSetPosBtnNameDict) do
    local x, y = self[btnName]:getPosition()
    self.m_MenuBtn_ActionBtnOldPosDict[btnName] = ccp(x, y)
  end
end
function warui_watch:ShowMenuViewBtns()
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
  self.btn_menu_eqptupgrade:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_eqptupgrade and not self.m_MenuSimpleFlag)
  self.btn_menu_skill:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_skill and not self.m_MenuSimpleFlag)
  self.btn_menu_huoban:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_huoban and true)
  self.btn_menu_zuoqi:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_zuoqi and not self.m_MenuSimpleFlag)
  self.btn_menu_pet:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_pet and true)
  self.btn_menu_guild:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_guild and not self.m_MenuSimpleFlag)
  self.btn_menu_tool:setEnabled(not self.m_BtnNotOpenFlagDict.btn_menu_tool and true)
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
function warui_watch:SetMenuBtnPos()
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
        local cp = self.m_MenuBtn_ActionBtnOldPosDict[btnName]
        self.m_MenuBtn_ActionBtnPosDict[btnName] = ccp(cp.x, cp.y)
      else
        for _, posBtnName in ipairs(btnList) do
          if posFlag[posBtnName] ~= true then
            local cp = self.m_MenuBtn_ActionBtnOldPosDict[posBtnName]
            self.m_MenuBtn_ActionBtnPosDict[btnName] = ccp(cp.x, cp.y)
            posFlag[posBtnName] = true
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
function warui_watch:initBtnsPosWithMsgBoxMode()
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
      local x, y = temp:getPosition()
      temp.__initPos = ccp(x, y)
    end
  end
end
function warui_watch:setBtnsPosWithMsgBoxMode(isSmall, off)
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
      if isSmall then
        temp:setPosition(temp.__initPos)
      else
        temp:setPosition(ccp(temp.__initPos.x, temp.__initPos.y + off))
      end
      if self.m_MenuBtn_ActionBtnPosDict ~= nil then
        local btnPos = self.m_MenuBtn_ActionBtnPosDict[btnName]
        if btnPos then
          local _, y = temp:getPosition()
          self.m_MenuBtn_ActionBtnPosDict[btnName] = ccp(btnPos.x, y)
        end
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
function warui_watch:OnBtn_Menu_Add(btnObj, touchType)
  print("warui_watch:OnBtn_Menu_Add")
  if self.m_IsMenuBtnAction then
    return
  end
  self:Action_MoveMenuBtns(function()
    self:SetMenuSimpleFlag(not self.m_MenuSimpleFlag)
  end)
end
function warui_watch:OnBtn_Menu_TopAdd(btnObj, touchType)
  print("warui_watch:OnBtn_Menu_TopAdd")
  self:SetTopSimpleFlag(false)
end
function warui_watch:OnBtn_Menu_TopClose(btnObj, touchType)
  print("warui_watch:OnBtn_Menu_TopClose")
  self:SetTopSimpleFlag(true)
end
function warui_watch:OnBtn_Menu_Shop(btnObj, touchType)
  if g_CMainMenuHandler then
    g_CMainMenuHandler:OnBtn_Menu_Shop()
  end
end
function warui_watch:OnBtn_Menu_Market(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_market"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Market")
  if self.btn_menu_market.redIcon ~= nil then
    enterMarket({initViewType = MarketShow_InitShow_CoinView, initBaitanType = BaitanShow_InitShow_StallView})
  else
    enterMarket()
  end
end
function warui_watch:OnBtn_Menu_Rank(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_rank"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Rank")
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
function warui_watch:OnBtn_Menu_Huodong(btnObj, touchType)
  print("warui_watch:OnBtn_Menu_Huodong")
  local tempView = CHuodongShow.new({InitHuodongShow = HuodongShow_EventView})
  getCurSceneView():addSubView({
    subView = tempView,
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui_watch:OnBtn_Menu_Doubleexp(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_doubleexp"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Doubleexp")
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
function warui_watch:OnBtn_Menu_BiWu(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_biwu"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_BiWu")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Biwu)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  ShowBattlePvpDlg()
end
function warui_watch:OnBtn_Menu_Mission(btnObj, touchType)
  print("warui_watch:OnBtn_Menu_Mission")
  getCurSceneView():addSubView({
    subView = CMissionView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui_watch:OnBtn_Menu_Team()
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
function warui_watch:OnBtn_Menu_Guild(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_guild"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Guild")
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_BangPai)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  ShowBangPaiDlg()
end
function warui_watch:OnBtn_Menu_EqptUpgrade(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_eqptupgrade"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_EqptUpgrade")
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
function warui_watch:OnBtn_Menu_Skill(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_skill"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Skill")
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
function warui_watch:OnBtn_Menu_HuoBan(btnObj, touchType)
  print("warui_watch:OnBtn_Menu_HuoBan")
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
function warui_watch:OnBtn_Menu_Zuoqi(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_zuoqi"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Zuoqi")
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
function warui_watch:OnBtn_Menu_Pet(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_pet"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Pet")
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
function warui_watch:OnBtn_Menu_Tool(btnObj, touchType)
  if g_CMainMenuHandler then
    local btnName = "btn_menu_tool"
    local asBtn = g_CMainMenuHandler[btnName]
    if asBtn then
      g_CMainMenuHandler:ShowBtnLightCircle(asBtn, false)
    end
  end
  print("warui_watch:OnBtn_Menu_Tool")
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
function warui_watch:OnTouch_HeadIcon(btnObj, touchType)
  getCurSceneView():addSubView({
    subView = settingDlg.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui_watch:ShowBtnRedIcon(btn, flag)
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
        redIcon:setPosition(ccp(25, 25))
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
function warui_watch:ShowBtnLightCircle(btn, flag)
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
function warui_watch:ShowPackageBtnFullIcon(flag)
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
function warui_watch:Clear()
  self.m_WarScene = nil
end
return warui_watch

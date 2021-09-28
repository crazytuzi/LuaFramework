warui_replay = class("warui_replay", CcsSubView)
function warui_replay:ctor(warScene)
  warui_replay.super.ctor(self, "views/war_ui.json")
  self.m_WarScene = warScene
  self:getNode("btns_layout"):setEnabled(false)
  self:getNode("btns_layout1"):setEnabled(false)
  self:getNode("btns_layout2"):setEnabled(false)
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
    btn_auto = {
      listener = handler(self, self.Btn_Quit),
      variName = "m_Btn_Quit"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_RoundNum = 0
  self.m_Btn_Quit:loadTextureNormal("views/warui/btn_quitwatch.png")
  self:updatePetLvBg()
  self:updateHeadData()
  self:InitMsgBoxAndSociality()
  self:SetMenuViewBtns()
  self:initBtnsPosWithMsgBoxMode()
  local mainMsgBox = g_CMainMenuHandler:getMsgbox()
  if mainMsgBox then
    local isSmallMode = mainMsgBox:getIsSmallMode()
    self.m_Msgbox:SetSmallModeAdjust(isSmallMode, false)
    local off = self.m_Msgbox:getAddHeight()
    self:setBtnsPosWithMsgBoxMode(isSmallMode, off)
  end
  self:InitExpBar()
  self:updateExp()
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
end
function warui_replay:SetHPBar(hp, maxHp)
  self:getNode("hpbar"):setPercent(hp / maxHp * 100)
end
function warui_replay:SetMPBar(mp, maxMp)
  self:getNode("mpbar"):setPercent(mp / maxMp * 100)
end
function warui_replay:SetMainRoleHead(typeId, zs, lv)
  if self.m_MainRoleImg ~= nil then
    self.m_MainRoleImg:removeFromParentAndCleanup(true)
  end
  self.m_MainRoleImg = createClickHead({
    roleTypeId = typeId,
    clickListener = nil,
    clickSoundType = 2
  })
  self.pic_headiconbg = self:getNode("headbg")
  self.pic_headiconbg:setOpacity(0)
  self.pic_headiconbg:addChild(self.m_MainRoleImg, 0)
  local size = self.pic_headiconbg:getContentSize()
  self.m_MainRoleImg:setPosition(ccp(-size.width / 2, -size.height / 2))
  self:getNode("txt_level"):setText(string.format("%d转%d", zs, lv))
end
function warui_replay:SetPetHPBar(hp, maxHp)
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
function warui_replay:SetPetMPBar(mp, maxMp)
  self:getNode("mpbar_pet"):setPercent(mp / maxMp * 100)
end
function warui_replay:SetPetHead(typeId, zs, lv, gray)
  self:getNode("hpbar_pet"):setVisible(true)
  self:getNode("mpbar_pet"):setVisible(true)
  self:getNode("txt_level_pet"):setVisible(true)
  if self.m_AddPetHeadSprite ~= nil then
    self.m_AddPetHeadSprite:removeFromParent()
  end
  local head = createHeadIconByRoleTypeID(typeId, nil, gray)
  local temp = self:getNode("btn_menu_pet"):getVirtualRenderer()
  local size = temp:getContentSize()
  temp:addChild(head)
  head:setPosition(ccp(size.width / 2, size.height / 2 + 8))
  head:setScale(0.8)
  self.m_AddPetHeadSprite = head
  self.m_AddPetHeadSprite._gray = gray
  self:getNode("txt_level_pet"):setText(string.format("%d转%d", zs, lv))
end
function warui_replay:updatePetLvBg()
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
function warui_replay:updateHeadData()
  print("warui_replay:updateHeadData")
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
end
function warui_replay:Btn_Quit(btnObj, touchType)
  QuitWarSceneAndBackToPreScene()
end
function warui_replay:SetMenuViewBtns()
  self:setMenuBtnShowPara()
  self:ShowMenuViewBtns()
  self:checkIsInBp()
  self:SetMenuBtnPos()
end
function warui_replay:setMenuBtnShowPara()
  self.m_BtnNotOpenFlagDict = {}
  local tempDict = {
    [OPEN_Func_Friend] = {
      "btn_menu_friend",
      "views/mainviews/btn_friend.png",
      "views/mainviews/btn_friend_gray.png"
    },
    [OPEN_Func_Shejiao] = {
      "btn_menu_sociality",
      "views/mainviews/btn_shejiao.png",
      "views/mainviews/btn_shejiao_gray.png"
    }
  }
  for funcId, data in pairs(tempDict) do
    local btnName = data[1]
    local nPath = data[2]
    local gPath = data[3]
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(funcId)
    local btn = self[btnName]
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Hide then
        self.m_BtnNotOpenFlagDict[btnName] = true
      elseif noOpenType == OPEN_FUNC_Type_Gray then
        btn:loadTextureNormal(gPath)
      end
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
    "btn_menu_dailyword"
  }
  self.m_MenuBtn_ActionBtnPosDict = {}
  self.m_MenuBtn_ActionBtnOldPosDict = {}
  for _, btnName in pairs(self.m_MenuBtn_AllSetPosBtnNameDict) do
    local x, y = self[btnName]:getPosition()
    self.m_MenuBtn_ActionBtnOldPosDict[btnName] = ccp(x, y)
  end
end
function warui_replay:ShowMenuViewBtns()
end
function warui_replay:checkIsInBp()
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
function warui_replay:SetMenuBtnPos()
  local tempDict = {
    {
      "btn_menu_friend",
      "btn_menu_sociality",
      "btn_voice_world",
      "btn_voice_bp",
      "btn_voice_team",
      "btn_menu_dailyword"
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
end
function warui_replay:initBtnsPosWithMsgBoxMode()
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
function warui_replay:setBtnsPosWithMsgBoxMode(isSmall, off)
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
function warui_replay:InitMsgBoxAndSociality()
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
    local isSmallMode = mainMsgBox:getIsSmallMode()
    self.m_Msgbox:SetSmallModeAdjust(isSmallMode, false)
  end
  self:ShowBtnRedIcon(self.btn_menu_sociality, false)
  self:CheckShowNewMailTip()
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Mail)
end
function warui_replay:InitShow()
  self:setVisible(true)
end
function warui_replay:InitExpBar()
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
function warui_replay:updateExp()
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
function warui_replay:SetRoundNum(num)
  self.m_RoundNum = num
  self:getNode("huiheText"):setVisible(true)
  self:getNode("huiheText"):setText(string.format("%d", num))
end
function warui_replay:StartOneRoundFightSetting(round, passtime)
  printLog("warui_replay", "StartOneRoundFightSetting")
  self:SetRoundNum(round)
end
function warui_replay:OnTouch_HeadIcon(btnObj, touchType)
  getCurSceneView():addSubView({
    subView = settingDlg.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function warui_replay:ShowBtnRedIcon(btn, flag)
  if btn == nil then
    return
  end
  if flag then
    if btn.redIcon == nil then
      local redIcon = display.newSprite("views/pic/pic_tipnew.png")
      btn:addNode(redIcon, 0)
      if btn == self.btn_menu_friend or btn == self.btn_menu_sociality then
        redIcon:setPosition(ccp(15, 15))
      else
        redIcon:setPosition(ccp(25, 25))
      end
      btn.redIcon = redIcon
    end
  elseif btn.redIcon then
    btn.redIcon:removeFromParent()
    btn.redIcon = nil
  end
  if btn ~= self.btn_menu_add then
    self:ShowBtnRedIcon(self.btn_menu_add)
  else
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
    addFlag = addFlag and flag ~= false
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
  end
end
function warui_replay:ShowBtnLightCircle(btn, flag)
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
        elseif btn == self.btn_menu_friend or btn == self.btn_menu_sociality then
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
function warui_replay:ShowFriendTip(num)
  if num > 99 then
    num = 99
  end
  self.pic_tipnew_friend:setVisible(num > 0)
  self.unread_friend:setText(tostring(num))
end
function warui_replay:CheckShowNewMailTip()
  local newMailFlag = g_MailMgr:getIsHasNewMail()
  self:ShowBtnRedIcon(self.btn_menu_friend, newMailFlag)
end
function warui_replay:OnBtn_Menu_Friend(btnObj, touchType)
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
function warui_replay:OnBtn_Menu_Sociality(obj, t)
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
function warui_replay:OnBtn_Menu_DailyWord(obj, t)
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
function warui_replay:GetIsShowFighting()
  return true
end
function warui_replay:UIStartRunAction()
  return
end
function warui_replay:Clear()
  self.m_WarScene = nil
end
function warui_replay:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Scene_NewFriendTip then
    self:ShowFriendTip(arg[1])
  elseif msgSID == MsgID_BP_LocalInfo then
    self:checkIsInBp()
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
  end
end
return warui_replay

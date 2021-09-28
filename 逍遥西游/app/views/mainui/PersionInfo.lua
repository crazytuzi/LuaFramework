persioninfoDlg = class("persioninfoDlg", CcsSubView)
function persioninfoDlg:ctor(param, closeFunc)
  persioninfoDlg.super.ctor(self, "views/person_info.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_rename = {
      listener = handler(self, self.OnBtn_ReName),
      variName = "btn_rename"
    },
    btn_recw = {
      listener = handler(self, self.OnBtn_ReCW),
      variName = "btn_recw"
    },
    btn_bind = {
      listener = handler(self, self.OnBtn_Bind),
      variName = "btn_bind"
    },
    btn_usehl = {
      listener = handler(self, self.OnBtn_HuoLi),
      variName = "btn_usehl"
    },
    btn_kangxingview = {
      listener = handler(self, self.OnBtn_Kang),
      variName = "btn_kangxingview"
    },
    btn_setpoint = {
      listener = handler(self, self.OnBtn_SetPoint),
      variName = "btn_setpoint"
    },
    btn_changerole = {
      listener = handler(self, self.OnBtn_ChangeRole),
      variName = "btn_changerole"
    },
    btn_loginout = {
      listener = handler(self, self.OnBtn_LoginOut),
      variName = "btn_loginout"
    },
    btn_kaji = {
      listener = handler(self, self.OnBtn_KaJi),
      variName = "btn_kaji"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_Param = param
  local pid = g_LocalPlayer:getPlayerId()
  local txt_id_num = self:getNode("txt_id_num")
  txt_id_num:setText(tostring(pid))
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  self:setRoleShape(mainHero)
  self:SetChiBangInfo(mainHero)
  self.txt_heroname = self:getNode("txt_heroname")
  local _, heroName = data_getRoleShapeAndName(mainHero:getTypeId())
  self.txt_heroname:setText(heroName)
  self.txt_cw = self:getNode("txt_cw")
  local txt_storeexp_num = self:getNode("txt_storeexp_num")
  local storeExp = g_LocalPlayer:getStoreExp()
  txt_storeexp_num:setText(tostring(storeExp))
  AutoLimitObjSize(txt_storeexp_num, 110)
  self:setBangPai()
  self:setHuoLi()
  self:SetHeroProData()
  self.btn_help_pos = self:getNode("btn_help_pos")
  self.btn_help_pos:setVisible(false)
  local parent = self.btn_help_pos:getParent()
  local x, y = self.btn_help_pos:getPosition()
  local z = self.btn_help_pos:getZOrder()
  local size = self.btn_help_pos:getContentSize()
  self.m_HelpDlg = nil
  local function ClickListener()
    if self.m_HelpDlg == nil then
      self.m_HelpDlg = self:createHelpDlg()
    end
    self.m_HelpDlg:stopAllActions()
    self.m_HelpDlg:runAction(transition.sequence({
      CCDelayTime:create(3),
      CCCallFunc:create(function()
        if self.m_HelpDlg then
          self.m_HelpDlg:removeFromParentAndCleanup(true)
          self.m_HelpDlg = nil
        end
      end)
    }))
  end
  local function LongPressListener()
    if self.m_HelpDlg == nil then
      self.m_HelpDlg = self:createHelpDlg()
    else
      self.m_HelpDlg:stopAllActions()
    end
  end
  local function LongPressEndListner()
    if self.m_HelpDlg ~= nil then
      self.m_HelpDlg:removeFromParentAndCleanup(true)
      self.m_HelpDlg = nil
    end
  end
  local helpBtn = createOneClickObj({
    path = "views/common/btn/btn_help.png",
    bgPath = nil,
    autoSize = nil,
    clickDel = nil,
    LongPressTime = 0.01,
    clickListener = ClickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = nil,
    grayFlag = nil
  })
  parent:addChild(helpBtn, z)
  helpBtn:ignoreContentAdaptWithSize(false)
  local w, h = 80, 80
  helpBtn:setSize(CCSize(w, h))
  local iSize = helpBtn._Icon:getContentSize()
  helpBtn._Icon:setPosition(ccp((w - iSize.width) / 2, (h - iSize.height) / 2))
  helpBtn:setPosition(ccp(x - w / 2, y - h / 2))
  self.m_HeldBtn = helpBtn
  self:flushLocalPlayerChengwei()
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
end
function persioninfoDlg:SetAttrTips()
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_HP"), PROPERTY_HP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_hp"), PROPERTY_HP, self:getNode("txt_des_HP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_MP"), PROPERTY_MP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_mp"), PROPERTY_MP, self:getNode("txt_des_MP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_AP"), PROPERTY_AP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_ap"), PROPERTY_AP, self:getNode("txt_des_AP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_SP"), PROPERTY_SP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_sp"), PROPERTY_SP, self:getNode("txt_des_SP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_gg_name"), PROPERTY_GenGu, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_gg"), PROPERTY_GenGu, self:getNode("txt_gg_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lx_name"), PROPERTY_Lingxing, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_lx"), PROPERTY_Lingxing, self:getNode("txt_lx_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_ll_name"), PROPERTY_LiLiang, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_ll"), PROPERTY_LiLiang, self:getNode("txt_ll_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_mj_name"), PROPERTY_MinJie, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_mj"), PROPERTY_MinJie, self:getNode("txt_mj_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_hl"), "reshuoli")
  self:attrclick_check_withWidgetObj(self:getNode("bg_hl"), "reshuoli", self:getNode("txt_hl"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_bp"), "bpdesc_0")
  self:attrclick_check_withWidgetObj(self:getNode("bg_bp"), "bpdesc_0", self:getNode("txt_bp"))
end
function persioninfoDlg:getRoleRace()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return RACE_REN
  else
    return mainHero:getProperty(PROPERTY_RACE)
  end
end
function persioninfoDlg:setLevel()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local txt_level_num = self:getNode("txt_level_num")
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  txt_level_num:setText(string.format("%d转%d级", zs, lv))
end
function persioninfoDlg:setRoleShape(mainHero)
  local race = mainHero:getProperty(PROPERTY_RACE)
  local shape = mainHero:getProperty(PROPERTY_SHAPE)
  self.role_aureole = self:getNode("role_aureole")
  self.poslayer_race = self:getNode("poslayer_race")
  self.role_aureole:setVisible(false)
  self.poslayer_race:setVisible(false)
  local x, y = self.role_aureole:getPosition()
  local parent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  local offx, offy = 0, 0
  local colorList = mainHero:getProperty(PROPERTY_RANCOLOR)
  if colorList == nil or colorList == 0 or type(colorList) == "table" and #colorList == 0 then
    colorList = {
      0,
      0,
      0
    }
  end
  self.m_RoleAni, offx, offy = createBodyByShapeForDlg(shape, colorList)
  parent:addNode(self.m_RoleAni, z + 10)
  self.m_RoleAni:setPosition(x + offx, y + offy)
  self:addclickAniForHeroAni(self.m_RoleAni, self.role_aureole, nil, nil, nil, handler(self, self.onRoleAniSetVisible))
  self.m_RoleAni:setVisible(false)
  if self.m_ChibangAni then
    self.m_ChibangAni:SetActAndDir("stand", 4)
    self.m_ChibangAni:setVisible(false)
  end
  local act1 = CCDelayTime:create(0.01)
  local act2 = CCCallFunc:create(function()
    self.m_RoleAni:setVisible(true)
    if self.m_ChibangAni then
      self.m_ChibangAni:setVisible(true)
    end
  end)
  self.m_RoleAni:runAction(transition.sequence({act1, act2}))
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    parent:addNode(self.m_RoleAureole, z + 9)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    parent:addNode(self.m_RoleShadow, z + 9)
    self.m_RoleShadow:setPosition(x, y)
  end
  if race ~= self.m_LastRaceShow then
    if self.m_RaceImage ~= nil then
      self.m_RaceImage:removeFromParentAndCleanup(true)
      self.m_RaceImage = nil
    end
    if self.m_RaceBg ~= nil then
      self.m_RaceBg:removeFromParentAndCleanup(true)
      self.m_RaceBg = nil
    end
    self.m_LastRaceShow = race
    local raceTxt = Def_Race_Res_Para_Dict[race] or Def_Race_Res_Para_Dict[RACE_REN]
    self.m_RaceImage = display.newSprite(string.format("views/rolelist/pic_roleicon_%s_unselect.png", raceTxt))
    self.m_RaceImage:setAnchorPoint(ccp(1, 0.5))
    self.m_RaceImage:setScale(0.7)
    local x, y = self.poslayer_race:getPosition()
    local size = self.poslayer_race:getContentSize()
    parent:addNode(self.m_RaceImage)
    self.m_RaceImage:setPosition(x + size.width + 5, y + size.height / 2 - 5)
  end
end
function persioninfoDlg:onRoleAniSetVisible(v)
  if self.m_ChibangAni then
    self.m_ChibangAni:setVisible(v)
  end
end
function persioninfoDlg:addChibangAni(typeId)
  if self.m_ChibangAni ~= nil and self.m_ChibangAni.__typeId == typeId then
    return
  end
  self:removeChibangAni()
  if self.m_RoleAni then
    local p = self.m_RoleAni:getParent()
    local z = self.m_RoleAni:getZOrder()
    local x, y = self.role_aureole:getPosition()
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.m_ChibangAni = CChiBang.new(self.m_RoleAni._shape, 10001, self.m_RoleAni)
    resetDefaultAlphaPixelFormat()
    self.m_ChibangAni.__typeId = typeId
    local v = self.m_RoleAni:isVisible()
    self.m_ChibangAni:setVisible(v)
    self.m_ChibangAni:SetActAndDir("stand", 4)
    local off = data_getChiBangOffInfo(self.m_RoleAni._shape, "stand_4")
    self.m_ChibangAni:setPosition(ccp(x + off[1], y + off[2]))
    self.m_RoleAni:playAniFromStart(-1)
    local color = data_getWingColor(typeId)
    self.m_ChibangAni:setColor(color)
  end
end
function persioninfoDlg:removeChibangAni()
  if self.m_ChibangAni ~= nil then
    self.m_ChibangAni:Clear()
    self.m_ChibangAni = nil
  end
end
function persioninfoDlg:SetChiBangInfo(mainHero)
  local itemIns = mainHero:GetEqptByPos(ITEM_DEF_EQPT_POS_CHIBANG)
  if itemIns == nil then
    self:removeChibangAni()
  else
    local itemTypeId = itemIns:getTypeId()
    self:addChibangAni(itemTypeId)
  end
end
function persioninfoDlg:SetHeroProData()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  self.txt_rolename = self:getNode("txt_rolename")
  local roleName = mainHero:getProperty(PROPERTY_NAME)
  self.txt_rolename:setText(roleName)
  AutoLimitObjSize(self.txt_rolename, 132)
  local txt_level_num = self:getNode("txt_level_num")
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  txt_level_num:setText(string.format("%d转%d级", zs, lv))
  local curExp = mainHero:getProperty(PROPERTY_EXP)
  local maxExp = CalculateHeroLevelupExp(lv, zs)
  if maxExp == nil or maxExp == 0 then
    if curExp == 0 then
      maxExp = 1
    else
      maxExp = curExp
    end
  end
  local p = math.round(curExp / maxExp * 100)
  if p < 0 then
    p = 0
  elseif p > 100 then
    p = 100
  end
  local pro_exp = self:getNode("pro_exp")
  pro_exp:setPercent(p)
  local txt_exp_num = self:getNode("txt_exp_num")
  txt_exp_num:setText(string.format("%d/%d", curExp, maxExp))
  if lv >= data_getMaxHeroLevel(zs) and curExp >= 0 then
    txt_exp_num:setText("(满)")
    pro_exp:setPercent(100)
  end
  local size = pro_exp:getContentSize()
  AutoLimitObjSize(txt_exp_num, size.width - 20)
  local max_hp = mainHero:getMaxProperty(PROPERTY_HP)
  local cur_hp = mainHero:getProperty(PROPERTY_HP)
  self:getNode("txt_value_HP"):setText(string.format("%d/%d", cur_hp, max_hp))
  local tempHpLimit = self:getNode("pro_bg_hp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_HP"), tempHpLimit - 10)
  local max_mp = mainHero:getMaxProperty(PROPERTY_MP)
  local cur_mp = mainHero:getProperty(PROPERTY_MP)
  self:getNode("txt_value_MP"):setText(string.format("%d/%d", cur_mp, max_mp))
  local tempMpLimit = self:getNode("pro_bg_mp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_MP"), tempMpLimit - 10)
  local cur_ap = mainHero:getProperty(PROPERTY_AP)
  self:getNode("txt_value_AP"):setText(string.format("%d", cur_ap))
  local tempApLimit = self:getNode("pro_bg_ap"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_AP"), tempApLimit - 10)
  local cur_sp = mainHero:getProperty(PROPERTY_SP)
  self:getNode("txt_value_SP"):setText(string.format("%d", cur_sp))
  local tempSpLimit = self:getNode("pro_bg_sp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_SP"), tempSpLimit - 10)
  local tempPointTextObj = {
    [PROPERTY_GenGu] = self:getNode("txt_gg_point"),
    [PROPERTY_LiLiang] = self:getNode("txt_ll_point"),
    [PROPERTY_MinJie] = self:getNode("txt_mj_point"),
    [PROPERTY_Lingxing] = self:getNode("txt_lx_point")
  }
  local tempAddTextObj = {
    [PROPERTY_GenGu] = self:getNode("txt_gg_point_add"),
    [PROPERTY_LiLiang] = self:getNode("txt_ll_point_add"),
    [PROPERTY_MinJie] = self:getNode("txt_mj_point_add"),
    [PROPERTY_Lingxing] = self:getNode("txt_lx_point_add")
  }
  local tempOProName = {
    [PROPERTY_GenGu] = PROPERTY_OGenGu,
    [PROPERTY_LiLiang] = PROPERTY_OLiLiang,
    [PROPERTY_MinJie] = PROPERTY_OMinJie,
    [PROPERTY_Lingxing] = PROPERTY_OLingxing
  }
  for i, proType in ipairs({
    PROPERTY_GenGu,
    PROPERTY_Lingxing,
    PROPERTY_LiLiang,
    PROPERTY_MinJie
  }) do
    local points = mainHero:getProperty(tempOProName[proType])
    local addNum = mainHero:getProperty(proType) - points
    local txtIns = tempPointTextObj[proType]
    local addObj = tempAddTextObj[proType]
    txtIns:setText(string.format("%d", points))
    local tempX, _ = self:getNode("addpro_bg_gg"):getPosition()
    local _, tempY = txtIns:getPosition()
    if addNum == 0 then
      txtIns:setPosition(ccp(tempX, tempY))
      addObj:setVisible(false)
      txtIns:setScale(1)
      addObj:setScale(1)
    else
      if addNum > 0 then
        addNum = math.floor(math.abs(addNum))
        addObj:setText(string.format("+%d", addNum))
        addObj:setColor(VIEW_DEF_PGREEN_COLOR)
      else
        addNum = math.floor(math.abs(addNum))
        addObj:setText(string.format("-%d", addNum))
        addObj:setColor(VIEW_DEF_WARNING_COLOR)
      end
      addObj:setVisible(true)
      local vSize = txtIns:getContentSize()
      local aSize = addObj:getContentSize()
      local vW = vSize.width
      local aW = aSize.width
      local sumW = vW + aW
      local scale = 1
      if sumW > 80 then
        scale = 80 / sumW
      end
      txtIns:setScale(scale)
      addObj:setScale(scale)
      txtIns:setPosition(ccp(tempX + (-sumW / 2 + vW / 2) * scale, tempY))
      addObj:setPosition(ccp(tempX + (sumW / 2 - aW / 2) * scale, tempY))
    end
  end
  local freeP = mainHero:getProperty(PROPERTY_FREEPOINT)
  self:getNode("txt_point"):setText(tostring(freeP))
  if freeP > 0 then
    self:getNode("freepoint_tip"):setVisible(true)
  else
    self:getNode("freepoint_tip"):setVisible(false)
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:ReSetHeroData(mainHero:getObjId())
  end
end
function persioninfoDlg:setVisible(v)
  self.m_UINode:setVisible(v)
  if not v then
    self:CloseHelpDlg()
  end
end
function persioninfoDlg:setHuoLi()
  local huoli = g_LocalPlayer:getHuoli()
  self:getNode("txt_hl_num"):setText(tostring(huoli))
end
function persioninfoDlg:setBangPai()
  self.txt_bpname = self:getNode("txt_bpname")
  self.txt_bpname:setText(g_BpMgr:getLocalBpName())
end
function persioninfoDlg:OnBtn_ReName(obj, t)
  getCurSceneView():addSubView({
    subView = settingDlg_ReName.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function persioninfoDlg:OnBtn_ReCW(obj, t)
  getCurSceneView():addSubView({
    subView = settingDlg_CW.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function persioninfoDlg:OnBtn_Bind(obj, t)
  ShowNotifyTips("绑定功能暂未开放")
end
function persioninfoDlg:OnBtn_HuoLi()
  if g_LocalPlayer then
    local openFlag, noOpenType, tips = g_LocalPlayer:isNpcOptionUnlock(OPEN_Func_HuoLi)
    if openFlag then
      openUseEnergyView()
    else
      ShowNotifyTips(tips)
    end
  end
end
function persioninfoDlg:OnBtn_Kang()
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local midPos = self:getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  local function closeFunc()
    self.m_KangXingViewObj = nil
  end
  local tempView = CHuobanKangView.new({closeFunc = closeFunc})
  local bSize = tempView:getBoxSize()
  getCurSceneView():addSubView({
    subView = tempView,
    zOrder = MainUISceneZOrder.popView
  })
  local bSize = tempView:getBoxSize()
  tempView:setPosition(ccp(display.width / 2 - bSize.width / 2, display.height / 2 - bSize.height / 2))
  tempView:ReSetHeroData(mainHero:getObjId())
  self.m_KangXingViewObj = tempView
end
function persioninfoDlg:OnBtn_SetPoint()
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
  end
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_RolePoint)
  if not openFlag then
    ShowNotifyTips(tips)
    return
  end
  local spId
  if self.m_Param ~= nil then
    spId = self.m_Param.spId
    self.m_Param = nil
  end
  self.m_AddPointDlg = CAddPoint.new(handler(self, self.OnAddPointClose), spId)
  getCurSceneView():addSubView({
    subView = self.m_AddPointDlg,
    zOrder = MainUISceneZOrder.popView
  })
  local bSize = self.m_AddPointDlg:getContentSize()
  self.m_AddPointDlg:setPosition(ccp(display.width / 2 - bSize.width / 2, display.height / 2 - bSize.height / 2))
  self.m_AddPointDlg:LoadProperties(mainHero)
  if spId ~= nil then
    self.m_AddPointDlg:OnBtn_Auto()
    self.m_AddPointDlg:setAppointLable(spId)
  end
end
function persioninfoDlg:OnAddPointClose()
  self.m_AddPointDlg = nil
end
function persioninfoDlg:OnBtn_ChangeRole(obj, t)
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中无法此操作")
    return
  end
  g_DataMgr:LogoutAndShowServerRoleListView()
end
function persioninfoDlg:OnBtn_LoginOut(obj, t)
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中无法此操作")
    return
  end
  if not g_DataMgr:IsInGame() then
    return
  end
  local confirmBoxDlg = CPopWarning.new({
    text = "确定要退出游戏，切换账号?",
    confirmFunc = function()
      if g_DataMgr:IsInGame() then
        g_ChannelMgr:Logout()
        g_DataMgr:returnToLoginView()
      end
    end,
    cancelText = "取消",
    confirmText = "确定"
  })
  confirmBoxDlg:ShowCloseBtn(false)
end
function persioninfoDlg:OnBtn_KaJi(obj, t)
  local warId
  if JudgeIsInWar() then
    warId = g_WarScene:getWarID()
  end
  netsend.netwar.tellSerToKillWar(warId)
end
function persioninfoDlg:createHelpDlg()
  local x, y = self.m_HeldBtn:getPosition()
  local parent = self.m_HeldBtn:getParent()
  local pos = parent:convertToWorldSpace(ccp(x - 100, y))
  local size = self.m_HeldBtn:getSize()
  local helpDlg = settingDlg_HelpContent.new(self, pos, size)
  if self.m_SvrOpenLevelInfo ~= nil then
    helpDlg:setOpenInfo(self.m_SvrOpenLevelInfo[1], self.m_SvrOpenLevelInfo[2])
  else
    netsend.netbaseptc.requestSvrOpenLevelInfo()
  end
  return helpDlg
end
function persioninfoDlg:CloseHelpDlg()
  if self.m_HelpDlg then
    self.m_HelpDlg:removeFromParentAndCleanup(true)
    self.m_HelpDlg = nil
  end
end
function persioninfoDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_HeroUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.heroId == g_LocalPlayer:getMainHeroId() then
      self:SetHeroProData()
    end
  elseif msgSID == MsgID_HouliUpdate then
    self:setHuoLi()
  elseif msgSID == MsgID_SvrOpenLevelInfo then
    local arg = {
      ...
    }
    local openLevel = arg[1]
    local openTime = arg[2]
    self.m_SvrOpenLevelInfo = {openLevel, openTime}
    if self.m_HelpDlg then
      self.m_HelpDlg:setOpenInfo(openLevel, openTime)
    end
  elseif msgSID == MsgID_ChengWeiChanged then
    local arg = {
      ...
    }
    print("---->> MsgID_ChengWeiChanged msg:", arg[1], g_LocalPlayer:getPlayerId())
    if arg[1] == g_LocalPlayer:getPlayerId() then
      self:flushLocalPlayerChengwei()
    end
  elseif msgSID == MsgID_LocalBpAndJob then
    self:setBangPai()
  end
end
function persioninfoDlg:flushLocalPlayerChengwei()
  local curId, endTime, isHide = g_LocalPlayer:getCurChengwei()
  print("flushLocalPlayerChengwei:", curId, endTime, isHide)
  local curShowTxt = "暂无称谓"
  if curId ~= 0 and isHide ~= true and (endTime == nil or endTime > g_DataMgr:getServerTime()) then
    local d = data_Title[curId]
    if d then
      curShowTxt = d.Title
    end
  end
  self.txt_cw:setText(curShowTxt)
end
function persioninfoDlg:ShowSetPoint()
  self:OnBtn_SetPoint()
end
function persioninfoDlg:OnBtn_Close()
  self:CloseSelf()
end
function persioninfoDlg:Clear()
  if self.m_HelpDlg ~= nil then
    self.m_HelpDlg:removeFromParentAndCleanup(true)
    self.m_HelpDlg = nil
  end
end

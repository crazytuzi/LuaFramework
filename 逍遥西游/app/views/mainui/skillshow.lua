g_SkillViewObj = nil
CSkillShow = class("CSkillShow", CcsSubView)
function CSkillShow:ctor(para)
  CSkillShow.super.ctor(self, "views/skill.json", {isAutoCenter = true, opacityBg = 100})
  para = para or {}
  self.m_ViewPara = para
  self.m_InitSkillShow = para.InitSkillShow or SkillShow_ShiMenView
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_LifeSkill)
  if openFlag == false then
    self.m_InitSkillShow = SkillShow_ShiMenView
  end
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_shimen = {
      listener = handler(self, self.OnBtn_Shimen),
      variName = "btn_shimen"
    },
    btn_shenghuo = {
      listener = handler(self, self.OnBtn_Shenghuo),
      variName = "btn_shenghuo"
    },
    btn_closeskill = {
      listener = handler(self, self.OnBtn_Qinmi),
      variName = "btn_closeskill"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_shimen,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_shenghuo,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_closeskill,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_shimen:setTitleText("师\n门\n技\n能")
  self.btn_shenghuo:setTitleText("生\n活\n技\n能")
  self.btn_closeskill:setTitleText("亲\n密\n技\n能")
  local size = self.btn_shimen:getContentSize()
  self:adjustClickSize(self.btn_shimen, size.width + 30, size.height, true)
  local size = self.btn_shenghuo:getContentSize()
  self:adjustClickSize(self.btn_shenghuo, size.width + 30, size.height, true)
  local size = self.btn_closeskill:getContentSize()
  self:adjustClickSize(self.btn_closeskill, size.width + 30, size.height, true)
  self.title_p1 = self:getNode("title_p1")
  self.title_p2 = self:getNode("title_p2")
  self:setGroupAllNotSelected(self.btn_shimen)
  self.m_CurViewNum = nil
  self.m_ShimenView = nil
  self.m_LifeSkillView = nil
  self:SelectView(self.m_InitSkillShow)
  self:ListenMessage(MsgID_PlayerInfo)
  g_SkillViewObj = self
  if g_JiehunJieqiRelease == false then
    self.btn_closeskill:setEnabled(false)
    self.btn_closeskill:setTouchEnabled(false)
  end
end
function CSkillShow:CreateView(viewNum)
  local tempViewNameDict = {
    [SkillShow_LifeView] = "m_LifeSkillView",
    [SkillShow_ShiMenView] = "m_ShimenView",
    [SkillShow_CloseView] = "m_QinmiView"
  }
  local viewObj = self[tempViewNameDict[i]]
  if viewObj == nil then
    local tempView
    if viewNum == SkillShow_LifeView then
      tempView = CLifeSkill.new(self.m_ViewPara)
      self.m_LifeSkillView = tempView
    elseif viewNum == SkillShow_ShiMenView then
      tempView = CShiMenSkill.new(self.m_ViewPara)
      self.m_ShimenView = tempView
    elseif viewNum == SkillShow_CloseView then
      tempView = CQinMiSkill.new(self.m_ViewPara)
      self.m_QinmiView = tempView
    end
    if tempView ~= nil then
      self:addChild(tempView.m_UINode, 1)
      local x, y = self:getNode("bg"):getPosition()
      local size = self:getNode("bg"):getContentSize()
      tempView:setPosition(ccp(x - size.width / 2, y - size.height / 2))
    end
  end
end
function CSkillShow:SelectView(viewNum)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_LifeSkill)
  if openFlag == false and viewNum == SkillShow_LifeView then
    viewNum = SkillShow_ShiMenView
    ShowNotifyTips(tips)
  end
  if g_JiehunJieqiRelease == false and viewNum == SkillShow_CloseView then
    viewNum = SkillShow_ShiMenView
  end
  local viewNumList = {
    SkillShow_LifeView,
    SkillShow_ShiMenView,
    SkillShow_CloseView
  }
  local tempViewNameDict = {
    [SkillShow_LifeView] = "m_LifeSkillView",
    [SkillShow_ShiMenView] = "m_ShimenView",
    [SkillShow_CloseView] = "m_QinmiView"
  }
  local tempBtnNameDict = {
    [SkillShow_LifeView] = self.btn_shenghuo,
    [SkillShow_ShiMenView] = self.btn_shimen,
    [SkillShow_CloseView] = self.btn_closeskill
  }
  local viewObj = self[tempViewNameDict[viewNum]]
  if viewObj == nil then
    self:CreateView(viewNum)
  end
  for _, i in pairs(viewNumList) do
    local viewObj = self[tempViewNameDict[i]]
    if viewObj ~= nil then
      viewObj:setVisible(i == viewNum)
      viewObj:setEnabled(i == viewNum)
      if viewObj.SetTouchStateForSkillBar then
        viewObj:SetTouchStateForSkillBar(i == viewNum)
      end
    end
  end
  if viewNum == SkillShow_LifeView then
    self.m_LifeSkillView:reflushAll()
  elseif viewNum == SkillShow_ShiMenView then
    self.m_ShimenView:reflushAll()
  elseif viewNum == SkillShow_CloseView then
    self.m_QinmiView:reflushAll()
  end
  self:setGroupBtnSelected(tempBtnNameDict[viewNum])
  self.btn_close:getParent():reorderChild(self.btn_close, 99999)
  self.m_CurViewNum = viewNum
  if viewNum == SkillShow_LifeView then
    self.title_p1:setText("生活")
    self.title_p2:setText("技能")
  elseif viewNum == SkillShow_ShiMenView then
    self.title_p1:setText("师门")
    self.title_p2:setText("技能")
  elseif viewNum == SkillShow_CloseView then
    self.title_p1:setText("亲密")
    self.title_p2:setText("技能")
  end
end
function CSkillShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CSkillShow:OnBtn_Shimen(btnObj, touchType)
  self:SelectView(SkillShow_ShiMenView)
end
function CSkillShow:OnBtn_Shenghuo(btnObj, touchType)
  self:SelectView(SkillShow_LifeView)
end
function CSkillShow:OnBtn_Qinmi(btnObj, touchType)
  self:SelectView(SkillShow_CloseView)
end
function CSkillShow:OnMessage(msgSID, ...)
  if msgSID == MsgID_LifeSkillUpdate then
    if self.m_LifeSkillView ~= nil then
      self.m_LifeSkillView:removeFromParent()
      self.m_LifeSkillView = nil
    end
    if self.m_CurViewNum == SkillShow_LifeView then
      self:SelectView(SkillShow_LifeView)
    end
  end
end
function CSkillShow:ShowSelf()
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function CSkillShow:HideSelf()
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function CSkillShow:Clear()
  if g_SkillViewObj == self then
    g_SkillViewObj = nil
  end
end
CShiMenSkill = class("CShiMenSkill", CcsSubView)
function CShiMenSkill:ctor(para)
  para = para or {}
  self.m_OpenSkillAttr = para.InitSkillAttr or 1
  CShiMenSkill.super.ctor(self, "views/shimenskill.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_skilltype1 = {
      listener = handler(self, self.OnBtn_SkillType1),
      variName = "btn_skilltype1"
    },
    btn_skilltype2 = {
      listener = handler(self, self.OnBtn_SkillType2),
      variName = "btn_skilltype2"
    },
    btn_skilltype3 = {
      listener = handler(self, self.OnBtn_SkillType3),
      variName = "btn_skilltype3"
    },
    btn_addcoin = {
      listener = handler(self, self.OnBtn_AddCoin),
      variName = "btn_addcoin"
    },
    btn_upgrade = {
      listener = handler(self, self.OnBtn_Upgrade),
      variName = "btn_upgrade"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_skilltype1,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    },
    {
      self.btn_skilltype2,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    },
    {
      self.btn_skilltype3,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    }
  })
  self:CreateSkillBars()
  self:SetMoney()
  self:SwitchSkillType(self.m_OpenSkillAttr)
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CShiMenSkill:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinBg_cur"), "rescoin")
end
function CShiMenSkill:CreateSkillBars()
  self.m_SkillItems_All = {}
  self.m_SkillIdList_All = {}
  local skillTypeList = g_LocalPlayer:getMainHero():getSkillTypeList()
  for i, _ in ipairs(skillTypeList) do
    local items = {}
    self.m_SkillItems_All[i] = items
    local skillAttr = skillTypeList[i]
    local skillList = data_getSkillListByAttr(skillAttr)
    for j = 1, 3 do
      local item = MainUISkillBar.new(j, nil, handler(self, self.OnAddSkillExp), i)
      local x, y = self:getNode(string.format("layer_skillpos%d", j)):getPosition()
      item:setPosition(ccp(x, y))
      item:setSkillIconEnabled(false)
      self:addChild(item:getUINode())
      items[j] = item
      local tempSkillId = skillList[j + 2]
      self.m_SkillIdList_All[#self.m_SkillIdList_All + 1] = tempSkillId
    end
  end
  self.btn_skilltype1:setTitleText(SKILLATTR_NAME_DICT[skillTypeList[1]])
  self.btn_skilltype2:setTitleText(SKILLATTR_NAME_DICT[skillTypeList[2]])
  self.btn_skilltype3:setTitleText(SKILLATTR_NAME_DICT[skillTypeList[3]])
end
function CShiMenSkill:SetTouchStateForSkillBar(flag)
  if flag == false then
    for _, items in pairs(self.m_SkillItems_All) do
      for _, bar in pairs(items) do
        bar:setSkillIconEnabled(false)
      end
    end
  else
    self:SwitchSkillType(self.m_SelectType)
  end
end
function CShiMenSkill:reflushAll()
end
function CShiMenSkill:SetMoney()
  self:getNode("txt_cost_0"):setText("拥有")
  local x, y = self:getNode("box_coin_cur"):getPosition()
  local z = self:getNode("box_coin_cur"):getZOrder()
  local size = self:getNode("box_coin_cur"):getSize()
  self:getNode("box_coin_cur"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:updateGoldNum()
end
function CShiMenSkill:updateGoldNum()
  local player = g_DataMgr:getPlayer()
  self:getNode("txt_coin_cur"):setText(string.format("%d", player:getCoin()))
end
function CShiMenSkill:SwitchSkillType(t)
  for i = 1, 3 do
    local temp = self.m_SkillItems_All[i]
    if temp then
      for _, item in pairs(temp) do
        item:setSkillIconEnabled(false)
      end
    end
  end
  local heroId = g_LocalPlayer:getMainHero():getObjId()
  local skillTypeList = g_LocalPlayer:getMainHero():getSkillTypeList()
  for set = 1, 3 do
    if #skillTypeList > 0 then
      local tempSkillId = self.m_SkillIdList_All[(t - 1) * 3 + set]
      self.m_SkillItems_All[t][set]:Reflush(heroId, tempSkillId)
      self.m_SkillItems_All[t][set]:setSkillIconEnabled(true)
    end
  end
  for index = 1, 3 do
    local btn = self[string.format("btn_skilltype%d", index)]
    if btn then
      btn:setTouchEnabled(index <= #skillTypeList)
      btn:setVisible(index <= #skillTypeList)
      if index == t then
        self:setGroupBtnSelected(btn)
        btn:setTouchEnabled(false)
      end
    end
  end
  self.m_SelectType = t
end
function CShiMenSkill:OnBtn_SkillType1(btnObj, touchType)
  self:SwitchSkillType(1)
end
function CShiMenSkill:OnBtn_SkillType2(btnObj, touchType)
  self:SwitchSkillType(2)
end
function CShiMenSkill:OnBtn_SkillType3(btnObj, touchType)
  self:SwitchSkillType(3)
end
function CShiMenSkill:OnBtn_AddCoin()
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CShiMenSkill:OnBtn_Upgrade()
  netsend.netbaseptc.UpgradeOneKindSkill(self.m_SelectType, Skill_AddSkill_Normal)
end
function CShiMenSkill:OnAddSkillExp(skillItem, skillId)
  print("增加技能熟练度", skillId)
  local openFlag = skillItem:getOpenFlag()
  if openFlag == false then
    ShowNotifyTips("技能还未开启")
    skillItem:stopLongPressClick()
    return
  end
  local roleIns = g_LocalPlayer:getMainHero()
  if roleIns:getObjId() ~= g_LocalPlayer:getMainHeroId() then
    ShowNotifyTips("主角才能手动升级法术")
    skillItem:stopLongPressClick()
    return
  end
  local zsNum = roleIns:getProperty(PROPERTY_ZHUANSHENG)
  local lvNum = roleIns:getProperty(PROPERTY_ROLELEVEL)
  local pLimit = data_getSkillExpLimitByZsAndLv(zsNum, lvNum)
  if pLimit == nil then
    pLimit = CalculateSkillProficiency(zsNum)
  end
  if pLimit <= (roleIns:getProficiency(skillId) or 0) then
    ShowNotifyTips("该技能熟练度已满")
    skillItem:stopLongPressClick()
    return
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shaofa)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Hide then
      skillItem:stopLongPressClick()
      return
    elseif noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
      skillItem:stopLongPressClick()
      return
    end
  end
  local skillTypeList = roleIns:getSkillTypeList()
  local skillAttr = data_getSkillAttrStyle(skillId)
  local skillStep = data_getSkillStep(skillId)
  local skillAttrNum = 0
  if skillTypeList[1] == skillAttr then
    skillAttrNum = 1
  end
  if skillTypeList[2] == skillAttr then
    skillAttrNum = 2
  end
  if skillTypeList[3] == skillAttr then
    skillAttrNum = 3
  end
  local i_skillNo = (skillAttrNum - 1) * 5 + skillStep
  for _, legalNo in pairs({
    3,
    4,
    5,
    8,
    9,
    10,
    13,
    14,
    15
  }) do
    if i_skillNo == legalNo then
      netsend.netbaseptc.requestAddSkillExp(i_skillNo, Skill_AddSkill_Normal)
      ShowWarningInWar()
      return
    end
  end
end
function CShiMenSkill:Clear()
end
function CShiMenSkill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:updateGoldNum()
  end
end

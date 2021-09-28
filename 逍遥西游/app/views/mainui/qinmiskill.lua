CQinMiSkill = class("CQinMiSkill", CcsSubView)
function CQinMiSkill:ctor(para)
  CQinMiSkill.super.ctor(self, "views/closeskill.json", {isAutoCenter = true, opacityBg = 100})
  para = para or {}
  local initIndex = para.InitCloseSkillIndex or SkillShow_CloseIndex_ZhuDong
  self.m_CurIndex = nil
  self.m_ZhuDongSkillObjs = {}
  self.m_BeiDongSkillObjs = {}
  local btnBatchListener = {
    btn_skilltype1 = {
      listener = handler(self, self.OnBtn_ZhuDong),
      variName = "btn_skilltype1"
    },
    btn_skilltype2 = {
      listener = handler(self, self.OnBtn_BeiDong),
      variName = "btn_skilltype2"
    },
    btn_addcoin = {
      listener = handler(self, self.OnBtn_AddCoin),
      variName = "btn_addcoin"
    },
    btn_addclose = {
      listener = handler(self, self.OnBtn_AddClose),
      variName = "btn_addclose"
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
    }
  })
  self:CreateZhuDongSkill()
  self:CreateBeiDongSkill()
  self:SetSkillMode(initIndex)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_Friends)
end
function CQinMiSkill:OnBtn_AddCoin()
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CQinMiSkill:SetSkillMode(index)
  self.m_CurIndex = index
  self:SetSkillView()
  self:SetFriendValueView()
  self:SetCostMoneyView()
  self:SetTipsView()
  self:SetBtnView()
  self:SetSkillTextView()
end
function CQinMiSkill:CreateZhuDongSkill()
  for j = 1, 3 do
    local skillId = ACTIVE_MARRYSKILLLIST[j]
    local item = QinMiSkillBar.new(skillId, handler(self, self.OnAddSkillExp))
    local x, y = self:getNode(string.format("layer_skillpos%d", j)):getPosition()
    item:setPosition(ccp(x, y))
    self:addChild(item:getUINode())
    self.m_ZhuDongSkillObjs[#self.m_ZhuDongSkillObjs + 1] = item
  end
end
function CQinMiSkill:CreateBeiDongSkill()
  for _, clickImg in pairs(self.m_BeiDongSkillObjs) do
    clickImg:removeFromParent()
  end
  self.m_BeiDongSkillObjs = {}
  local yhdValue = 0
  if g_FriendsMgr then
    local banLvID = g_FriendsMgr:getBanLvId()
    if banLvID ~= nil then
      yhdValue = g_FriendsMgr:getFriendValue(banLvID) or 0
    end
  end
  for j = 1, 5 do
    do
      local x, y = self:getNode(string.format("beidong_skill%d", j)):getPosition()
      local size = self:getNode(string.format("beidong_skill%d", j)):getContentSize()
      local skillId = PASSIVE_MARRYSKILLLIST[j]
      local openFlag = false
      if yhdValue >= (data_MarrySkill[skillId].yhd or 0) then
        openFlag = true
      end
      local clickImg = createClickSkill({
        roleID = g_LocalPlayer:getMainHeroId(),
        skillID = skillId,
        autoSize = nil,
        LongPressTime = nil,
        clickListener = function()
          self:SetSkillTextView(skillId)
        end,
        LongPressListener = nil,
        LongPressEndListner = nil,
        clickDel = nil,
        grayFlag = openFlag == false
      })
      clickImg:setPosition(ccp(x + 3, y + 1))
      self:addChild(clickImg)
      self.m_BeiDongSkillObjs[#self.m_BeiDongSkillObjs + 1] = clickImg
    end
  end
end
function CQinMiSkill:SetFriendValueView()
  local banLvID = g_FriendsMgr:getBanLvId()
  local hasBLFlag = banLvID ~= nil
  if banLvID ~= nil then
    local fValue = g_FriendsMgr:getFriendValue(banLvID) or 0
    self:getNode("txt_close"):setText(string.format("%d", fValue))
  end
  self:getNode("closeBg"):setVisible(hasBLFlag)
  self:getNode("txt_close"):setVisible(hasBLFlag)
  self:getNode("txt_cost_close"):setVisible(hasBLFlag)
  self:getNode("btn_addclose"):setVisible(hasBLFlag)
  if self.btn_addclose then
    self.btn_addclose:setVisible(hasBLFlag)
    self.btn_addclose:setTouchEnabled(hasBLFlag)
  end
end
function CQinMiSkill:SetCostMoneyView()
  local showFlag = true
  self:getNode("txt_cost"):setText("拥有")
  local banLvID = g_FriendsMgr:getBanLvId()
  local hasBLFlag = banLvID ~= nil
  if banLvID ~= nil and not g_FriendsMgr:getFriendValue(banLvID) then
    local fValue = 0
  end
  if hasBLFlag == false or self.m_CurIndex == SkillShow_CloseIndex_BeiDong then
    showFlag = false
  end
  if self.m_CoinImg == nil then
    local x, y = self:getNode("box_coin_cur"):getPosition()
    local z = self:getNode("box_coin_cur"):getZOrder()
    local size = self:getNode("box_coin_cur"):getContentSize()
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_CoinImg = tempImg
  end
  self:getNode("txt_coin_cur"):setText(string.format("%d", g_LocalPlayer:getCoin()))
  self:getNode("coinBg_cur"):setVisible(showFlag)
  self:getNode("txt_cost"):setVisible(showFlag)
  self:getNode("txt_coin_cur"):setVisible(showFlag)
  if self.btn_addcoin then
    self.btn_addcoin:setVisible(showFlag)
    self.btn_addcoin:setTouchEnabled(showFlag)
  end
  if self.m_CoinImg then
    self.m_CoinImg:setVisible(showFlag)
  end
end
function CQinMiSkill:SetSkillView()
  local beidongObjNameDict = {
    "beidong_bg1",
    "beidong_bg2",
    "beidong_bg3",
    "beidong_name",
    "beidong_eff",
    "beidong_txt_name"
  }
  if self.m_CurIndex == SkillShow_CloseIndex_ZhuDong then
    for _, obj in pairs(self.m_ZhuDongSkillObjs) do
      obj:setSkillIconEnabled(true)
    end
    for _, obj in pairs(self.m_BeiDongSkillObjs) do
      obj:setEnabled(false)
      obj:setTouchEnabled(false)
      obj:setVisible(false)
    end
    for _, tempName in pairs(beidongObjNameDict) do
      self:getNode(tempName):setVisible(false)
    end
    if self.m_SelectSkillFrame then
      self.m_SelectSkillFrame:setVisible(false)
    end
  elseif self.m_CurIndex == SkillShow_CloseIndex_BeiDong then
    for _, obj in pairs(self.m_ZhuDongSkillObjs) do
      obj:setSkillIconEnabled(false)
    end
    for _, obj in pairs(self.m_BeiDongSkillObjs) do
      obj:setEnabled(true)
      obj:setTouchEnabled(true)
      obj:setVisible(true)
    end
    for _, tempName in pairs(beidongObjNameDict) do
      self:getNode(tempName):setVisible(true)
    end
    if self.m_SelectSkillFrame then
      self.m_SelectSkillFrame:setVisible(true)
    end
  end
end
function CQinMiSkill:SetTipsView()
  local tipsText = ""
  local banLvID = g_FriendsMgr:getBanLvId()
  local hasBLFlag = banLvID ~= nil
  if hasBLFlag == true and self.m_CurIndex == SkillShow_CloseIndex_ZhuDong then
    tipsText = ""
  elseif self.m_CurIndex == SkillShow_CloseIndex_BeiDong then
    tipsText = "#<IRP>#友好度达到技能要求自动激活\n被动技能只对怪物有效，PVP无效"
  else
    tipsText = "#<IRP>#结婚(结契)后自动开启技能"
  end
  local x, y = self:getNode("beidong_tipsbox"):getPosition()
  local size = self:getNode("beidong_tipsbox"):getContentSize()
  if self.m_TipsText == nil then
    self.m_TipsText = CRichText.new({
      width = size.width,
      fontSize = 16,
      color = ccc3(94, 211, 207),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_TipsText)
  end
  self.m_TipsText:clearAll()
  self.m_TipsText:addRichText(tipsText)
  local h = self.m_TipsText:getContentSize().height
  self.m_TipsText:setPosition(ccp(x, y + (size.height - h) / 2))
end
function CQinMiSkill:SetSkillTextView(skillId)
  if skillId == nil then
    skillId = PASSIVE_MARRYSKILLLIST[1]
    local yhdValue = 0
    if g_FriendsMgr then
      local banLvID = g_FriendsMgr:getBanLvId()
      if banLvID ~= nil then
        yhdValue = g_FriendsMgr:getFriendValue(banLvID) or 0
      end
    end
    for j = 1, 5 do
      local sId = PASSIVE_MARRYSKILLLIST[j]
      if yhdValue >= (data_MarrySkill[sId].yhd or 0) then
        skillId = sId
      end
    end
  end
  if self.m_SelectSkillFrame == nil then
    self.m_SelectSkillFrame = display.newSprite("views/rolelist/pic_role_selected.png")
    self:addNode(self.m_SelectSkillFrame, 999)
    self.m_SelectSkillFrame:setScale(0.8)
    self.m_SelectSkillFrame:setAnchorPoint(ccp(0, 0))
  end
  local skillIndex = 1
  for j = 1, 5 do
    local sId = PASSIVE_MARRYSKILLLIST[j]
    if skillId == sId then
      skillIndex = j
    end
  end
  local x, y = self:getNode(string.format("beidong_skill%d", skillIndex)):getPosition()
  self.m_SelectSkillFrame:setPosition(ccp(x - 2, y))
  self.m_SelectSkillFrame:setVisible(self.m_CurIndex == SkillShow_CloseIndex_BeiDong)
  local skillText = ""
  local banLvID = g_FriendsMgr:getBanLvId()
  local hasBLFlag = banLvID ~= nil
  if self.m_CurIndex == SkillShow_CloseIndex_ZhuDong then
    skillText = ""
  elseif self.m_CurIndex == SkillShow_CloseIndex_BeiDong then
    if skillId == nil then
      skillText = ""
      self:getNode("beidong_txt_name"):setText("")
    else
      local name = data_getSkillName(skillId)
      self:getNode("beidong_txt_name"):setText(name)
      local skillDes = data_getSkillDesc(skillId)
      skillText = string.format("%s", skillDes)
    end
  end
  local x, y = self:getNode("beidong_txtbox"):getPosition()
  local size = self:getNode("beidong_txtbox"):getContentSize()
  if self.m_SkillText == nil then
    self.m_SkillText = CRichText.new({
      width = size.width,
      fontSize = 20,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_SkillText)
  end
  self.m_SkillText:clearAll()
  self.m_SkillText:addRichText(skillText)
  local h = self.m_SkillText:getContentSize().height
  self.m_SkillText:setPosition(ccp(x + 2, y + size.height - h - 10))
end
function CQinMiSkill:SetBtnView()
  local banLvID = g_FriendsMgr:getBanLvId()
  local hasBLFlag = banLvID ~= nil
  self.btn_upgrade:setVisible(true)
  self.btn_upgrade:setTouchEnabled(true)
  if self.m_CurIndex == SkillShow_CloseIndex_ZhuDong then
    if hasBLFlag then
      self.btn_upgrade:setTitleText("一键升级")
    else
      self.btn_upgrade:setTitleText("前往开启")
    end
  elseif self.m_CurIndex == SkillShow_CloseIndex_BeiDong then
    if hasBLFlag then
      self.btn_upgrade:setVisible(false)
      self.btn_upgrade:setTouchEnabled(false)
    else
      self.btn_upgrade:setTitleText("前往开启")
    end
  end
end
function CQinMiSkill:OnBtn_ZhuDong()
  self:SetSkillMode(SkillShow_CloseIndex_ZhuDong)
end
function CQinMiSkill:OnBtn_BeiDong()
  self:SetSkillMode(SkillShow_CloseIndex_BeiDong)
end
function CQinMiSkill:OnBtn_AddClose()
  local banLvID = g_FriendsMgr:getBanLvId()
  if g_SkillViewObj then
    g_SkillViewObj:HideSelf()
  end
  local callback = function()
    if g_SkillViewObj then
      g_SkillViewObj:ShowSelf()
    end
  end
  ShowYouHaoDuView({fID = banLvID, cbFunc = callback})
end
function CQinMiSkill:OnBtn_Upgrade()
  local banLvID = g_FriendsMgr:getBanLvId()
  local hasBLFlag = banLvID ~= nil
  if hasBLFlag == false then
    if g_MapMgr then
      g_MapMgr:AutoRouteToNpc(NPC_HongNiang_ID, function(isSucceed)
        if isSucceed and CMainUIScene.Ins and isSucceed then
          CMainUIScene.Ins:ShowNormalNpcViewById(NPC_HongNiang_ID)
        end
      end)
      if g_SkillViewObj then
        g_SkillViewObj:CloseSelf()
      end
      return
    end
  elseif self.m_CurIndex == SkillShow_CloseIndex_ZhuDong then
    netsend.netbaseptc.UpgradeOneKindSkill(1, Skill_AddSkill_Marry)
    return
  elseif self.m_CurIndex == SkillShow_CloseIndex_BeiDong then
    return
  end
end
function CQinMiSkill:OnAddSkillExp(skillItem, skillId)
  print("增加技能熟练度", skillId)
  local yhdValue = 0
  if g_FriendsMgr then
    local banLvID = g_FriendsMgr:getBanLvId()
    if banLvID ~= nil then
      yhdValue = g_FriendsMgr:getFriendValue(banLvID) or 0
    end
  end
  local roleIns = g_LocalPlayer:getMainHero()
  if yhdValue <= (roleIns:getProficiency(skillId) or 0) then
    ShowNotifyTips("该技能熟练度已满")
    skillItem:stopLongPressClick()
    return
  end
  local step = 3
  if skillId == ACTIVE_MARRYSKILLLIST[1] then
    step = 1
  elseif skillId == ACTIVE_MARRYSKILLLIST[2] then
    step = 2
  elseif skillId == ACTIVE_MARRYSKILLLIST[3] then
    step = 3
  else
    return
  end
  netsend.netbaseptc.requestAddSkillExp(step, Skill_AddSkill_Marry)
  ShowWarningInWar()
end
function CQinMiSkill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:SetCostMoneyView()
  elseif msgSID == MsgID_Friends_FlushBanLv then
    self:CreateBeiDongSkill()
    self:SetSkillMode(self.m_CurIndex)
  elseif msgSID == MsgID_Friends_UpdateFirend then
    local pid = arg[1]
    if pid == g_FriendsMgr:getBanLvId() then
      self:CreateBeiDongSkill()
      self:SetSkillMode(self.m_CurIndex)
    end
  end
end
function CQinMiSkill:SetTouchStateForSkillBar(flag)
  if flag == false then
    for _, obj in pairs(self.m_ZhuDongSkillObjs) do
      obj:setSkillIconEnabled(false)
    end
  else
    self:SetSkillMode(self.m_CurIndex)
  end
end
function CQinMiSkill:reflushAll()
end
function CQinMiSkill:Clear()
end

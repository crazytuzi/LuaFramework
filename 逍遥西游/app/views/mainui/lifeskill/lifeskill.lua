CLifeSkill = class("CLifeSkill", CcsSubView)
function CLifeSkill:ctor(para)
  self.m_NPCID = 90027
  self.m_LifeSkillID = LIFESKILL_NO
  self.m_LifeSkillLV = 0
  if g_LocalPlayer then
    self.m_LifeSkillID, self.m_LifeSkillLV = g_LocalPlayer:getBaseLifeSkill()
  end
  if self.m_LifeSkillID == LIFESKILL_NO then
    CLifeSkill.super.ctor(self, "views/createlifeskill.json", {isAutoCenter = true, opacityBg = 100})
    self:SetCreateView()
  else
    CLifeSkill.super.ctor(self, "views/upgradelifeskill.json", {isAutoCenter = true, opacityBg = 100})
    self:SetUpgradeView()
    self:SetAttrTips()
  end
end
function CLifeSkill:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("hlBg_cur"), "reshuoli")
  self:attrclick_check_withWidgetObj(self:getNode("achBg"), "resachive")
  self:attrclick_check_withWidgetObj(self:getNode("coinBg"), "rescoin")
  self:attrclick_check_withWidgetObj(self:getNode("achBg_cur"), "resachive")
  self:attrclick_check_withWidgetObj(self:getNode("coinBg_cur"), "rescoin")
end
function CLifeSkill:SetCreateView()
  self.bg1 = self:getNode("bg1")
  local btnBatchListener = {
    btn_learn = {
      listener = handler(self, self.OnBtn_Learn),
      variName = "btn_learn"
    },
    btn_skilldetail = {
      listener = handler(self, self.OnBtn_skilldetail),
      variName = "btn_skilldetail"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_SelectIDList = {
    LIFESKILL_MAKEDRUG,
    LIFESKILL_MAKEFU,
    LIFESKILL_MAKEFOOD,
    LIFESKILL_CATCH
  }
  self:SetSkillList(self.m_SelectIDList)
  self.m_SelectLifeSkillID = nil
  self.m_SelectObjList = nil
  local Random = math.random(1, 4)
  self:SelectSkill(self.m_SelectIDList[Random], Random)
end
function CLifeSkill:SetSkillList(list)
  for index, skID in ipairs(list) do
    do
      local x, y = self:getNode(string.format("box_item_%d", index)):getPosition()
      local tempBtn = createClickButton(data_getLifeSkillIconPath(skID), nil, function()
        self:SelectSkill(skID, index)
      end, nil, nil, true)
      tempBtn:setPosition(ccp(x, y))
      self:addChild(tempBtn)
    end
  end
end
function CLifeSkill:SelectSkill(skID, index)
  local skillName = data_getLifeSkillName(skID)
  self:getNode("txt_name"):setText(skillName)
  if self.m_SkillDesc ~= nil then
    self.m_SkillDesc:removeFromParent()
  end
  local x, y = self:getNode("box_des"):getPosition()
  local descSize = self:getNode("box_des"):getSize()
  local tempDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  self:addChild(tempDesc)
  tempDesc:addRichText(data_getLifeSkillDesc(skID))
  local richSize = tempDesc:getContentSize()
  tempDesc:setPosition(ccp(x, y + descSize.height - richSize.height))
  self.m_SkillDesc = tempDesc
  local temp1, temp2, temp3, temp4
  local x, y = self:getNode(string.format("box_item_%d", index)):getPosition()
  local del = 15
  local temp = display.newSprite(data_getLifeSkillIconPath(1))
  local bgSize = temp:getContentSize()
  if self.m_SelectObjList then
    temp1 = self.m_SelectObjList[1]
    temp2 = self.m_SelectObjList[2]
    temp3 = self.m_SelectObjList[3]
    temp4 = self.m_SelectObjList[4]
  else
    temp1 = display.newSprite("views/pic/pic_selectcorner.png")
    temp2 = display.newSprite("views/pic/pic_selectcorner.png")
    temp3 = display.newSprite("views/pic/pic_selectcorner.png")
    temp4 = display.newSprite("views/pic/pic_selectcorner.png")
    self.m_SelectObjList = {
      temp1,
      temp2,
      temp3,
      temp4
    }
    self:addNode(temp1)
    self:addNode(temp2)
    self:addNode(temp3)
    self:addNode(temp4)
  end
  temp1:setPosition(ccp(x - del, y - del))
  temp1:setAnchorPoint(ccp(0, 1))
  temp1:setScaleY(-1)
  temp2:setPosition(ccp(x - del, y + bgSize.height + del))
  temp2:setAnchorPoint(ccp(0, 1))
  temp3:setPosition(ccp(x + bgSize.width + del, y - del))
  temp3:setAnchorPoint(ccp(0, 1))
  temp3:setScaleX(-1)
  temp3:setScaleY(-1)
  temp4:setPosition(ccp(x + bgSize.width + del, y + bgSize.height + del))
  temp4:setAnchorPoint(ccp(0, 1))
  temp4:setScaleX(-1)
  self.m_SelectLifeSkillID = skID
end
function CLifeSkill:OnBtn_Learn(obj, t)
  if self.m_SelectLifeSkillID == nil then
    ShowNotifyTips("请先选择技能")
    return
  end
  local skillName = data_getLifeSkillName(self.m_SelectLifeSkillID)
  local temp = CPopWarning.new({
    title = "提示",
    text = string.format("确定要选择#<Y>%s#作为生活技能吗？确认后必须花费铜钱重修其它技能。", skillName),
    confirmText = "确定",
    cancelText = "取消",
    confirmFunc = handler(self, self._learnLifeSkill),
    align = CRichText_AlignType_Left
  })
  temp:ShowCloseBtn(false)
end
function CLifeSkill:OnBtn_skilldetail()
  g_SkillViewObj:HideSelf()
  local callback = function()
    if g_SkillViewObj then
      g_SkillViewObj:ShowSelf()
    end
  end
  if self.m_SelectLifeSkillID == LIFESKILL_CATCH then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_pet.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_SelectLifeSkillID == LIFESKILL_MAKEFOOD then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_cook.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_SelectLifeSkillID == LIFESKILL_MAKEFU then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_fuwen.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_SelectLifeSkillID == LIFESKILL_MAKEDRUG then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_drug.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    g_SkillViewObj:ShowSelf()
  end
end
function CLifeSkill:_learnLifeSkill()
  netsend.netlifeskill.setLifeSkill(self.m_SelectLifeSkillID)
  g_MissionMgr:GuideIdComplete(GuideId_ShengHuoJiNeng)
end
function CLifeSkill:SetUpgradeView()
  local btnBatchListener = {
    btn_makeitem = {
      listener = handler(self, self.OnBtn_MakeItem),
      variName = "btn_makeitem"
    },
    btn_upgrade1 = {
      listener = handler(self, self.OnBtn_Upgrade1),
      variName = "btn_upgrade1"
    },
    btn_upgrade2 = {
      listener = handler(self, self.OnBtn_Upgrade2),
      variName = "btn_upgrade2"
    },
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    },
    btn_addcoin = {
      listener = handler(self, self.OnBtn_AddCoin),
      variName = "btn_addcoin"
    },
    btn_addach = {
      listener = handler(self, self.OnBtn_AddAch),
      variName = "btn_addach"
    },
    btn_resetskill = {
      listener = handler(self, self.OnBtn_ResetSkill),
      variName = "btn_resetskill"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetSkillLv()
  self:SetResData()
  self:UpdateResData()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CLifeSkill:SetResData()
  local x, y = self:getNode("box_coin"):getPosition()
  local z = self:getNode("box_coin"):getZOrder()
  local size = self:getNode("box_coin"):getSize()
  self:getNode("box_coin"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  local x, y = self:getNode("box_ach"):getPosition()
  local z = self:getNode("box_ach"):getZOrder()
  local size = self:getNode("box_ach"):getSize()
  self:getNode("box_ach"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_CHENGJIU))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  local x, y = self:getNode("box_coin_cur"):getPosition()
  local z = self:getNode("box_coin_cur"):getZOrder()
  local size = self:getNode("box_coin_cur"):getSize()
  self:getNode("box_coin_cur"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  local x, y = self:getNode("box_ach_cur"):getPosition()
  local z = self:getNode("box_ach_cur"):getZOrder()
  local size = self:getNode("box_ach_cur"):getSize()
  self:getNode("box_ach_cur"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_CHENGJIU))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  local x, y = self:getNode("box_hl_cur"):getPosition()
  local z = self:getNode("box_hl_cur"):getZOrder()
  local size = self:getNode("box_hl_cur"):getSize()
  self:getNode("box_hl_cur"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_HUOLI))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  local temp = display.newSprite(data_getLifeSkillIconPath(self.m_LifeSkillID))
  temp:setAnchorPoint(ccp(0, 0))
  self:addNode(temp)
  local x, y = self:getNode("box_item"):getPosition()
  temp:setPosition(ccp(x, y))
end
function CLifeSkill:OnBtn_ResetSkill()
  local NpcId = self.m_NPCID
  if NpcId then
    if g_SkillViewObj then
      g_SkillViewObj:CloseSelf()
    end
    g_MapMgr:AutoRouteToNpc(NpcId, function(isSucceed)
      if isSucceed and CMainUIScene.Ins then
        CMainUIScene.Ins:ShowNormalNpcViewById(NpcId)
      end
    end)
  end
end
function CLifeSkill:UpdateResData()
  local player = g_DataMgr:getPlayer()
  local limit = data_Variables.Player_Max_Huoli_Value or 1000
  self:getNode("txt_coin_cur"):setText(string.format("%d", player:getCoin()))
  self:getNode("txt_ach_cur"):setText(string.format("%d", player:getArch()))
  self:getNode("txt_hl_cur"):setText(string.format("%d/%d", player:getHuoli(), limit))
  local needCoin = data_getLifeSkillUpgradeNeedCoin(self.m_LifeSkillLV + 1)
  local needArch = data_getLifeSkillUpgradeNeedArch(self.m_LifeSkillLV + 1)
  self:getNode("txt_ach"):setText(string.format("%d", needArch))
  if needArch > player:getArch() then
    self:getNode("txt_ach"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("txt_ach"):setColor(ccc3(255, 255, 255))
  end
  self:getNode("txt_coin"):setText(string.format("%d", needCoin))
  if needCoin > player:getCoin() then
    self:getNode("txt_coin"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  end
end
function CLifeSkill:SetSkillLv()
  if g_LocalPlayer then
    self.m_LifeSkillID, self.m_LifeSkillLV = g_LocalPlayer:getBaseLifeSkill()
  end
  self:getNode("txt_lifeskillname"):setText(data_getLifeSkillName(self.m_LifeSkillID))
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  self:getNode("txt_lifeskilllv"):setText(string.format("%d/%d", self.m_LifeSkillLV, lv))
  if self.m_LifeSkillID == LIFESKILL_MAKEDRUG then
    self.btn_makeitem:setTitleText("炼制药物")
  elseif self.m_LifeSkillID == LIFESKILL_MAKEFU then
    self.btn_makeitem:setTitleText("炼制符文")
  elseif self.m_LifeSkillID == LIFESKILL_MAKEFOOD then
    self.btn_makeitem:setTitleText("烹饪食物")
  elseif self.m_LifeSkillID == LIFESKILL_CATCH then
    self.btn_makeitem:setTitleText("捕捉宠物")
  end
end
function CLifeSkill:OnBtn_MakeItem(obj, t)
  local skID = self.m_LifeSkillID
  if skID == LIFESKILL_MAKEFOOD or skID == LIFESKILL_MAKEFU or skID == LIFESKILL_MAKEDRUG then
    g_SkillViewObj:HideSelf()
    local callback = function()
      if g_SkillViewObj then
        g_SkillViewObj:ShowSelf()
      end
    end
    ShowMakeLifeItem(self.m_LifeSkillID, callback)
  else
    g_SkillViewObj:HideSelf()
    local callback = function()
      if g_SkillViewObj then
        g_SkillViewObj:ShowSelf()
      end
    end
    ShowCatchPetView({callback = callback})
  end
end
function CLifeSkill:OnBtn_Upgrade2(obj, t)
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  if self.m_LifeSkillLV >= math.min(lv, LIFESKILL_MAX_LV) then
    ShowNotifyTips("生活技能等级不能高于角色等级")
    return
  end
  local needArch = data_getUpgradeLifeSkillNeedArch(self.m_LifeSkillLV, math.min(lv, LIFESKILL_MAX_LV))
  local arch = g_LocalPlayer:getArch()
  if needArch <= arch then
    netsend.netlifeskill.upgradeLifeSkill(0)
    ShowWarningInWar()
  else
    local warningText = string.format("帮派成就不足\n是否使用#<IR1>#%d换取？", (needArch - arch) * data_Variables.Exchange_Arch2Money)
    local tempPop = CPopWarning.new({
      title = "提示",
      text = warningText,
      confirmFunc = handler(self, self._Upgrade2),
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
    tempPop:ShowCloseBtn(false)
  end
end
function CLifeSkill:OnBtn_Upgrade1(obj, t)
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  if self.m_LifeSkillLV >= math.min(lv, LIFESKILL_MAX_LV) then
    ShowNotifyTips("生活技能等级不能高于角色等级")
    return
  end
  local needArch = data_getUpgradeLifeSkillNeedArch(self.m_LifeSkillLV, self.m_LifeSkillLV + 1)
  local arch = g_LocalPlayer:getArch()
  if needArch <= arch then
    netsend.netlifeskill.upgradeLifeSkill(1)
    ShowWarningInWar()
  else
    local warningText = string.format("帮派成就不足\n是否使用#<IR1>#%d换取？", (needArch - arch) * data_Variables.Exchange_Arch2Money)
    local tempPop = CPopWarning.new({
      title = "提示",
      text = warningText,
      confirmFunc = handler(self, self._Upgrade1),
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
    tempPop:ShowCloseBtn(false)
  end
end
function CLifeSkill:_Upgrade1()
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  if self.m_LifeSkillLV >= math.min(lv, LIFESKILL_MAX_LV) then
    ShowNotifyTips("生活技能等级不能高于角色等级")
    return
  end
  netsend.netlifeskill.upgradeLifeSkill(1)
  ShowWarningInWar()
end
function CLifeSkill:_Upgrade2()
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  if self.m_LifeSkillLV >= math.min(lv, LIFESKILL_MAX_LV) then
    ShowNotifyTips("生活技能等级不能高于角色等级")
    return
  end
  netsend.netlifeskill.upgradeLifeSkill(0)
  ShowWarningInWar()
end
function CLifeSkill:OnBtn_Help(obj, t)
  local title = "升级效果"
  local text = data_getLifeSkillUpgradeDesc(self.m_LifeSkillID)
  if text ~= nil then
    local temp = CPopWarning.new({
      title = title,
      text = text,
      confirmText = "确定",
      align = CRichText_AlignType_Left
    })
    temp:ShowCloseBtn(false)
    temp:OnlyShowConfirmBtn()
  end
end
function CLifeSkill:OnBtn_AddCoin(obj, t)
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CLifeSkill:OnBtn_AddAch(obj, t)
  if g_BpMgr:localPlayerHasBangPai() ~= true then
    ShowNotifyTips("加入帮派才能获得帮派成就")
  else
    if g_SkillViewObj then
      g_SkillViewObj:CloseSelf()
    end
    local bpinfo = CBpInfo.new()
    if bpinfo then
      getCurSceneView():addSubView({
        subView = bpinfo,
        zOrder = MainUISceneZOrder.menuView
      })
      bpinfo:OnBtn_Page_Fuli()
      bpinfo:setGroupBtnSelected(bpinfo.btn_page_fuli)
    end
  end
end
function CLifeSkill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:UpdateResData()
  elseif msgSID == MsgID_ArchUpdate then
    self:UpdateResData()
  elseif msgSID == MsgID_HouliUpdate then
    self:UpdateResData()
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
    if heroId ~= player:getMainHeroId() then
      return
    end
    local lv = arg[1].pro[PROPERTY_ROLELEVEL]
    if lv ~= nil then
      self:SetSkillLv()
    end
  end
end
function CLifeSkill:reflushAll()
end
function CLifeSkill:Clear()
end

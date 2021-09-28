MARKET_PET_BUY_VIEW = 1
MARKET_PET_SELF_SELL_VIEW = 2
MARKET_PET_PACKAGE_VIEW = 3
MARKET_PET_PACKAGE_ISBANGDING = 1
CMarketPetView = class("CMarketPetView", CcsSubView)
function CMarketPetView:ctor(petId, playerId, paramTable, isOtherPlayer, ViewTag, goodsState, price)
  CMarketPetView.super.ctor(self, "views/chatdetail_pet.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_petattr = {
      listener = handler(self, self.OnBtn_ShowPetVBaseAttr),
      variName = "btn_petattr"
    },
    btn_petzizhi = {
      listener = handler(self, self.OnBtn_ShowPetZiZhi),
      variName = "btn_petzizhi"
    },
    btn_petkangxing = {
      listener = handler(self, self.OnBtn_ShowPetKangXing),
      variName = "btn_petkangxing"
    },
    btn_petskill = {
      listener = handler(self, self.OnBtn_ShowPetSkill),
      variName = "btn_petskill"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_petattr,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petzizhi,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petkangxing,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petskill,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.goodsState = goodsState
  self.btn_petattr:setTitleText("基\n础\n属\n性")
  self.btn_petzizhi:setTitleText("属\n性\n资\n质")
  self.btn_petkangxing:setTitleText("抗\n性")
  self.btn_petskill:setTitleText("技\n能")
  self.list_detail = self:getNode("list_detail")
  self.m_needLV = self:getNode("need_lv")
  self.btn_petskill:setTouchEnabled(true)
  self.ViewTag = ViewTag
  self.m_PetId = petId
  self.m_PlayerId = playerId
  self.isOtherPlayer = isOtherPlayer
  if paramTable ~= nil then
    self.m_UINode:setAnchorPoint(ccp(0.5, 0.5))
    local bg_x = paramTable.bg_x or 0
    local bg_y = paramTable.bg_y or 0
    local bgSize = paramTable.bgSize or 0
    local m_size = self:getContentSize()
    if self.ViewTag == MARKET_SCROLL_SELL_VIEW then
      self:setPosition(ccp(bg_x + m_size.width / 2 - 30, bg_y))
    elseif self.ViewTag == MARKET_SCROLL_BUY_VIEW then
      self:setPosition(ccp(bg_x + bgSize.width / 2 - m_size.width / 2 + 8, bg_y))
    else
      self:setPosition(ccp(bg_x - m_size.width / 2, bg_y))
    end
  end
  if self.isOtherPlayer then
    self.m_Player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
  else
    self.m_Player = g_DataMgr:getPlayer(self.m_PlayerId)
  end
  if self.m_PetId == nil or self.m_PlayerId == nil then
    self:CloseSelf()
    return
  end
  if self.isOtherPlayer then
    self.m_petObj = g_BaitanDataMgr:GetOneGood(self.m_PetId)
  else
    self.m_petObj = self.m_Player:getObjById(self.m_PetId)
  end
  if self.m_petObj == nil then
    return
  end
  self.BastAttrPanel = CMarketPetBaseAttr.new(self.m_PetId, self.m_petObj, paramTable, self.isOtherPlayer, self.m_PlayerId, self.goodsState, self.ViewTag, price, self)
  self.SkillPanel = CChatDetail_Skill.new(self.m_PlayerId, self.m_PetId, self.isOtherPlayer)
  self.KangxingPanel = CMarketPetBase_KangXing.new(self.m_PlayerId, self.m_PetId, self.isOtherPlayer)
  self:addPanelToShow(self.BastAttrPanel, self.list_detail)
  self:addPanelToShow(self.SkillPanel, self.list_detail)
  self:addPanelToShow(self.KangxingPanel, self.list_detail)
  self:OnBtn_ShowPetVBaseAttr()
  if self.ViewTag == MARKET_PET_BUY_VIEW then
    self.BastAttrPanel:setIsShoppingView()
    self.m_needLV:setVisible(true)
    local petTypeId = self.m_petObj:getTypeId()
    local petData = data_Pet[petTypeId]
    local openlv = petData.OPENLV
    self.m_needLV:setText(string.format("等级要求:%d", openlv))
  else
    self.m_needLV:setVisible(false)
  end
  self:enableCloseWhenTouchOutside(self:getNode("touch_layer"), true)
end
function CMarketPetView:OnBtn_Close()
  self:CloseSelf()
end
function CMarketPetView:OnBtn_ShowPetVBaseAttr()
  if self.BastAttrPanel then
    self.RightBth = self.BastAttrPanel:getRightBtn()
    self.LeftBtn = self.BastAttrPanel:getLeftBtn()
    self.coinIcon_1 = self.BastAttrPanel:getCoinIcon_1()
    if self.RightBth then
      self.RightBth:setVisible(true)
      self.RightBth:setTouchEnabled(true)
    end
    if self.LeftBtn then
      self.LeftBtn:setTouchEnabled(true)
    end
    self.BastAttrPanel:setVisible(true)
    if self.ViewTag == MARKET_PET_BUY_VIEW then
      self.coinIcon_1:setVisible(true)
    else
      self.coinIcon_1:setVisible(false)
    end
    if self.ViewTag == MARKET_PET_BUY_VIEW then
      self.m_needLV:setVisible(true)
    else
      self.m_needLV:setVisible(false)
    end
    self.BastAttrPanel:getLeftBtn():setVisible(true)
    self.SkillPanel:setVisible(false)
    self.SkillPanel:setEnabled(false)
    self.KangxingPanel:setVisible(false)
    self.KangxingPanel:setEnabled(false)
    self.BastAttrPanel:showPanel("BaseAttr")
  end
end
function CMarketPetView:OnBtn_ShowPetZiZhi()
  if self.BastAttrPanel then
    self.BastAttrPanel:setVisible(true)
    self.SkillPanel:setVisible(false)
    self.SkillPanel:setEnabled(false)
    self.KangxingPanel:setVisible(false)
    self.KangxingPanel:setEnabled(false)
    self.BastAttrPanel:showPanel("potential")
    self.BastAttrPanel:getLeftBtn():setVisible(false)
    self.coinIcon_1:setVisible(false)
    if self.RightBth then
      self.RightBth:setVisible(false)
      self.RightBth:setTouchEnabled(false)
    end
    if self.LeftBtn then
      self.LeftBtn:setTouchEnabled(false)
    end
  end
end
function CMarketPetView:OnBtn_ShowPetKangXing()
  if self.KangxingPanel then
    self.BastAttrPanel:setVisible(false)
    self.SkillPanel:setVisible(false)
    self.SkillPanel:setEnabled(false)
    self.KangxingPanel:setVisible(true)
    self.KangxingPanel:setEnabled(true)
    self.BastAttrPanel:getLeftBtn():setVisible(false)
    self.coinIcon_1:setVisible(false)
    if self.RightBth then
      self.RightBth:setVisible(false)
      self.RightBth:setTouchEnabled(false)
    end
    if self.LeftBtn then
      self.LeftBtn:setTouchEnabled(false)
    end
    self.m_needLV:setVisible(false)
  end
end
function CMarketPetView:OnBtn_ShowPetSkill()
  if self.BastAttrPanel then
    self.BastAttrPanel:setVisible(false)
    self.BastAttrPanel:getLeftBtn():setVisible(false)
  end
  if self.KangxingPanel then
    self.KangxingPanel:setVisible(false)
    self.KangxingPanel:setEnabled(false)
  end
  if self.SkillPanel then
    self.m_needLV:setVisible(false)
    self.SkillPanel:setEnabled(true)
    self.SkillPanel:setVisible(true)
  end
end
function CMarketPetView:addPanelToShow(obj, listObj)
  local x, y = listObj:getPosition()
  local zOrder = listObj:getZOrder()
  local parent = listObj:getParent()
  parent:addChild(obj.m_UINode, zOrder)
  obj:setPosition(ccp(x, y))
  if self.BastAttrPanel:isVisible() then
    parent:reorderChild(self.BastAttrPanel.m_UINode, zOrder + 10)
    self.SkillPanel:setEnabled(false)
  else
    parent:reorderChild(self.BastAttrPanel.m_UINode, zOrder)
  end
  if self.SkillPanel:isVisible() then
    parent:reorderChild(self.SkillPanel.m_UINode, zOrder + 10)
  else
    parent:reorderChild(self.SkillPanel.m_UINode, zOrder)
  end
  if self.KangxingPanel:isVisible() then
    parent:reorderChild(self.KangxingPanel.m_UINode, zOrder + 10)
  else
    parent:reorderChild(self.KangxingPanel.m_UINode, zOrder)
  end
end
CMarketPetBaseAttr = class("CMarketPetBaseAttr", CcsSubView)
function CMarketPetBaseAttr:ctor(petId, petObj, paramTable, isOtherPlayer, PlayerId, goodsState, ViewTag, price, baseView)
  CMarketPetBaseAttr.super.ctor(self, "views/market_petview.json")
  local btnBatchListener = {
    btn_left = {
      listener = handler(self, self.OnBtn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.OnBtn_Right),
      variName = "btn_right"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.goodsState = goodsState
  self.ViewTag = ViewTag
  self.baseView = baseView
  self.panel_attr = self:getNode("panel_attr")
  self.panel_potential = self:getNode("panel_potential")
  self.coinIcon = self:getNode("coinIcon")
  self.coinIcon_1 = self:getNode("coinIcon_1")
  self.coinIcon_1:setVisible(false)
  self.txt_price = self:getNode("txt_price")
  self.txt_tax = self:getNode("txt_tax")
  self.txt_petent = self:getNode("txt_petent")
  self.pet_lv_ZS = self:getNode("txt_level")
  self.txt_price:setText("0")
  self.isOtherPlayer = isOtherPlayer
  self.m_PlayerId = PlayerId
  self.m_petId = petId
  self.m_petObj = petObj
  self.m_price = price
  if self.m_petObj then
    local petTypeId = self.m_petObj:getTypeId()
    self.origPrice = data_Pet[petTypeId].price
    if self.ViewTag == MARKET_PET_PACKAGE_VIEW then
      self.m_petPrice = data_Pet[petTypeId].price
    else
      if self.ViewTag == MARKET_PET_BUY_VIEW then
        self.pet_lv_ZS:setVisible(false)
      end
      self.m_petPrice = self.m_price
    end
    if data_Stall[petTypeId] then
      self.petMinPriceRatio = data_Stall[petTypeId].MinPriceRatio
      self.petMaxPriceRatio = data_Stall[petTypeId].MaxPriceRatio
      self.petRevenueRatio = data_Stall[petTypeId].RevenueRatio
    else
      self.petMinPriceRatio = 0.5
      self.petMaxPriceRatio = 1.5
      self.petRevenueRatio = 0.03
    end
    self.lowPrice = self.origPrice * self.petMinPriceRatio
    self.hightPrice = self.origPrice * self.petMaxPriceRatio
    self.petRvenue = self.m_petPrice * self.petRevenueRatio
    self.txt_price:setText(tostring(self.m_petPrice))
    self.txt_tax:setText(Value2Str(self.petRvenue, 0))
    self.percent = Value2Str(self.m_petPrice / self.origPrice, 2) * 100
    self.txt_petent:setText(tostring(self.percent .. "%"))
  end
  local addpro_bg_DJ = self:getNode("infobg_1")
  local x, y = addpro_bg_DJ:getPosition()
  local p = addpro_bg_DJ:getParent()
  self.btn_DJ_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.Btn_Addpro))
  self.btn_Max = createClickButton("views/rolelist/btn_max.png", "views/rolelist/btn_maxpro_gray.png", handler(self, self.Btn_Max_DJ))
  p:addChild(self.btn_DJ_addpoint, 1)
  p:addChild(self.btn_Max, 1)
  self.btn_DJ_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_Max:setPosition(ccp(x + 95, y - 26))
  self.btn_DJ_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.Btn_Subpro))
  p:addChild(self.btn_DJ_subpoint, 1)
  self.btn_DJ_subpoint:setPosition(ccp(x - 88, y - 26))
  self:setCoinIcon()
  self:setCoinIconPrice()
  self.btn_left:setVisible(true)
  self.txt_pro_czl = self:getNode("txt_pro_czl")
  self.pro_pro_czl = self:getNode("pro_pro_czl")
  self.txt_pro_qx = self:getNode("txt_pro_qx")
  self.pro_pro_qx = self:getNode("pro_pro_qx")
  self.txt_pro_fl = self:getNode("txt_pro_fl")
  self.pro_pro_fl = self:getNode("pro_pro_fl")
  self.txt_pro_gj = self:getNode("txt_pro_gj")
  self.pro_pro_gj = self:getNode("pro_pro_gj")
  self.txt_pro_sd = self:getNode("txt_pro_sd")
  self.pro_pro_sd = self:getNode("pro_pro_sd")
  self.layer_compare = self:getNode("layer_compare")
  self:LoadPet()
  self:bangDingIsvisible()
  self:ListenMessage(MsgID_PlayerInfo)
  if paramTable.leftBtnFontSize ~= nil then
    self.btn_left:setTitleFontSize(paramTable.leftBtnFontSize)
  end
  if paramTable.rightBtnFontSize ~= nil then
    self.btn_right:setTitleFontSize(paramTable.rightBtnFontSize)
  end
  local lx, ly = self.btn_left:getPosition()
  self.m_LeftBtnOldPosition = {lx, ly}
  local rx, ry = self.btn_right:getPosition()
  self.m_RightBtnOldPosition = {rx, ry}
  self.m_MidBtnPos = ccp((lx + rx) / 2, (ly + ry) / 2)
  local paramLeft = paramTable.leftBtn
  if paramLeft == nil or type(paramLeft) ~= "table" then
    self.btn_left:setEnabled(false)
  else
    local txt = paramLeft.btnText or ""
    self.btn_left:setTitleText(txt)
    self.m_LeftBtnListener = paramLeft.listener
  end
  local paramRight = paramTable.rightBtn
  if paramRight == nil or type(paramRight) ~= "table" then
    self.btn_right:setEnabled(false)
  else
    local txt = paramRight.btnText or ""
    self.btn_right:setTitleText(txt)
    self.m_RightBtnListener = paramRight.listener
  end
  self:LoadPetIcon()
  self:SetButtonsPos()
  if self.m_petPrice <= self.lowPrice then
    self.btn_DJ_addpoint:setButtonDisableState(true)
    self.btn_Max:setButtonDisableState(true)
    self.btn_DJ_subpoint:setButtonDisableState(false)
  elseif self.m_petPrice >= self.hightPrice then
    self.btn_DJ_addpoint:setButtonDisableState(false)
    self.btn_DJ_subpoint:setButtonDisableState(true)
    self.btn_Max:setButtonDisableState(false)
  end
  self:UpdateBtnStateForReShangjia()
end
function CMarketPetBaseAttr:setIsShoppingView()
  local x, y = self:getNode("lable_tax"):getPosition()
  self:getNode("lable_tax"):setPosition(ccp(x, y))
  self:getNode("lable_tax"):setVisible(false)
  self.btn_DJ_addpoint:setVisible(false)
  self.btn_DJ_addpoint:setEnabled(false)
  self.btn_DJ_subpoint:setVisible(false)
  self.btn_DJ_subpoint:setEnabled(false)
  self.btn_Max:setVisible(false)
  self.txt_petent:setVisible(false)
  self.coinIcon:setVisible(false)
  self.coinIcon_1:setVisible(true)
end
function CMarketPetBaseAttr:bangDingIsvisible()
  local isBangding = self.m_petObj:getProperty(PROPERTY_ISBANGDING)
  if self.ViewTag == MARKET_PET_PACKAGE_VIEW and isBangding == MARKET_PET_PACKAGE_ISBANGDING then
    local lable_bd = ui.newTTFLabel({
      text = "【绑定】",
      size = 20,
      font = KANG_TTF_FONT,
      color = ccc3(255, 0, 0)
    })
    local x, y = self.pet_lv_ZS:getPosition()
    local size = self.pet_lv_ZS:getContentSize()
    lable_bd:setPosition(ccp(x + size.width, y))
    self:addNode(lable_bd)
  end
end
function CMarketPetBaseAttr:getLeftBtn()
  return self.btn_left
end
function CMarketPetBaseAttr:getRightBtn()
  return self.btn_right
end
function CMarketPetBaseAttr:getCoinIcon_1()
  return self.coinIcon_1
end
function CMarketPetBaseAttr:setCoinIcon()
  local bgSize = self:getNode("infobg"):getContentSize()
  local parent = self.coinIcon:getParent()
  local x, y = self:getNode("lable_tax"):getPosition()
  local z = parent:getZOrder()
  local size = self.coinIcon:getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x - bgSize.width / 3 + 5, y - bgSize.height * 2 + 18))
  self.coinIcon:addNode(tempImg, z + 1)
end
function CMarketPetBaseAttr:setCoinIconPrice()
  local bgSize = self:getNode("infobg_1"):getContentSize()
  local parent = self.coinIcon_1:getParent()
  local x, y = parent:getPosition()
  local z = parent:getZOrder()
  local size = self.coinIcon_1:getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x - bgSize.width / 2 + 30, y - bgSize.height * 2 - 35))
  self.coinIcon_1:addNode(tempImg, z + 1)
end
function CMarketPetBaseAttr:SetButtonsPos()
  if self.btn_left:isEnabled() and not self.btn_right:isEnabled() then
    self.btn_left:setPosition(self.m_MidBtnPos)
  elseif not self.btn_left:isEnabled() and self.btn_right:isEnabled() then
    self.btn_right:setPosition(self.m_MidBtnPos)
  end
end
function CMarketPetBaseAttr:Btn_Addpro()
  local oncePirce = self.origPrice * 0.05
  if self.m_petPrice < self.hightPrice then
    self.m_petPrice = self.m_petPrice + Value2Str(oncePirce, 0)
    self.petRvenue = self.m_petPrice * self.petRevenueRatio
    self.txt_price:setText(tostring(self.m_petPrice))
    self.txt_tax:setText(tostring(Value2Str(self.petRvenue, 0)))
    if self.m_petPrice < self.hightPrice then
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_subpoint:setButtonDisableState(true)
      self.btn_Max:setButtonDisableState(true)
    else
      self.btn_DJ_addpoint:setButtonDisableState(false)
      self.btn_DJ_subpoint:setButtonDisableState(true)
      self.btn_Max:setButtonDisableState(false)
    end
  else
    self.m_petPrice = self.hightPrice
    self.petRvenue = self.m_petPrice * self.petRevenueRatio
    self.txt_tax:setText(tostring(Value2Str(self.petRvenue, 0)))
    self.txt_price:setText(tostring(self.m_petPrice))
    ShowNotifyTips("价格已到达最高，不能再高了")
  end
  self.percent = self.m_petPrice / self.origPrice * 100
  self.txt_petent:setText(tostring(Value2Str(self.percent, 0) .. "%"))
  self:UpdateBtnStateForReShangjia()
end
function CMarketPetBaseAttr:Btn_Max_DJ()
  if self.m_petPrice < self.hightPrice then
    self.m_petPrice = self.hightPrice
    self.percent = self.m_petPrice / self.origPrice * 100
    self.txt_petent:setText(tostring(Value2Str(self.percent, 0) .. "%"))
    self.petRvenue = self.m_petPrice * self.petRevenueRatio
    self.txt_tax:setText(tostring(Value2Str(self.petRvenue, 0)))
    self.txt_price:setText(tostring(self.m_petPrice))
    self.btn_Max:setButtonDisableState(true)
    self.btn_DJ_addpoint:setButtonDisableState(true)
    if self.m_petPrice >= self.hightPrice then
      self.btn_Max:setButtonDisableState(false)
      self.btn_DJ_addpoint:setButtonDisableState(false)
      self.btn_DJ_subpoint:setButtonDisableState(true)
    end
  else
    self.m_petPrice = self.hightPrice
    self.petRvenue = self.m_petPrice * self.petRevenueRatio
    self.percent = self.m_petPrice / self.origPrice * 100
    self.txt_petent:setText(tostring(Value2Str(self.percent, 0) .. "%"))
    self.txt_tax:setText(tostring(Value2Str(self.petRvenue, 0)))
    self.txt_price:setText(tostring(self.m_petPrice))
    ShowNotifyTips("价格已到达最高，不能再高了")
  end
end
function CMarketPetBaseAttr:Btn_Subpro()
  local oncePirce = self.origPrice * 0.05
  if self.m_petPrice > self.lowPrice then
    self.m_petPrice = self.m_petPrice - Value2Str(oncePirce, 0)
    self.petRvenue = self.m_petPrice * self.petRevenueRatio
    self.txt_tax:setText(tostring(Value2Str(self.petRvenue, 0)))
    self.txt_price:setText(tostring(self.m_petPrice))
    if self.m_petPrice > self.lowPrice then
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_subpoint:setButtonDisableState(true)
      self.btn_Max:setButtonDisableState(true)
    else
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_subpoint:setButtonDisableState(false)
      self.btn_Max:setButtonDisableState(true)
    end
  else
    self.m_petPrice = self.lowPrice
    self.petRvenue = self.m_petPrice * self.petRevenueRatio
    self.txt_tax:setText(tostring(Value2Str(self.petRvenue, 0)))
    self.txt_price:setText(tostring(self.m_petPrice))
    ShowNotifyTips("价格已到达最低，不能再低了")
  end
  self.percent = self.m_petPrice / self.origPrice * 100
  self.txt_petent:setText(tostring(Value2Str(self.percent, 0) .. "%"))
  self:UpdateBtnStateForReShangjia()
end
function CMarketPetBaseAttr:UpdateBtnStateForReShangjia()
  if self.ViewTag == MARKET_PET_SELF_SELL_VIEW then
    local curGoodData = g_BaitanDataMgr:GetOneGoodSellingData(self.m_petId) or {}
    local ShowReShangjiaFlag = true
    if curGoodData.p == self.m_petPrice and curGoodData.s == MARKET_SCROLL_ITEM_STATE_CANSELL then
      ShowReShangjiaFlag = false
    end
    if ShowReShangjiaFlag then
      self.btn_left:setPosition(ccp(self.m_LeftBtnOldPosition[1], self.m_LeftBtnOldPosition[2]))
      self.btn_right:setPosition(ccp(self.m_RightBtnOldPosition[1], self.m_RightBtnOldPosition[2]))
      self.btn_left:setEnabled(true)
      self.btn_right:setEnabled(true)
    else
      self.btn_left:setPosition(ccp((self.m_LeftBtnOldPosition[1] + self.m_RightBtnOldPosition[1]) / 2, (self.m_LeftBtnOldPosition[2] + self.m_RightBtnOldPosition[2]) / 2))
      self.btn_left:setEnabled(true)
      self.btn_right:setEnabled(false)
    end
  end
end
function CMarketPetBaseAttr:OnBtn_Left()
  if self.m_LeftBtnListener then
    self.m_LeftBtnListener(self.m_petId, self.m_petPrice)
  end
  if self.ViewTag == MARKET_PET_PACKAGE_VIEW then
    local petTypeId = self.m_petObj:getTypeId()
    local isCanSell = data_Stall[petTypeId].CanSell
    if isCanSell == 1 then
      netsend.netstall.addedGoods(self.m_petId, 1, self.m_petPrice, 1)
    else
      ShowNotifyTips("该宠物不能上架")
    end
    self.baseView:CloseSelf()
  elseif self.ViewTag == MARKET_PET_SELF_SELL_VIEW then
    netsend.netstall.offShelfProducts(self.m_petId)
    self.baseView:CloseSelf()
  elseif self.ViewTag == MARKET_PET_BUY_VIEW then
    self.baseView:CloseSelf()
  end
end
function CMarketPetBaseAttr:OnBtn_Right()
  if self.m_RightBtnListener then
    self.m_RightBtnListener(self.m_petId, self.m_petPrice)
  end
  if self.ViewTag == MARKET_PET_PACKAGE_VIEW then
  elseif self.ViewTag == MARKET_PET_SELF_SELL_VIEW then
    local curGoodData = g_BaitanDataMgr:GetOneGoodSellingData(self.m_petId) or {}
    if curGoodData.p == self.m_petPrice and curGoodData.s == MARKET_SCROLL_ITEM_STATE_CANSELL then
      ShowNotifyTips("价格没有改变不能重新上架")
      return
    end
    netsend.netstall.backShelves(self.m_petId, self.m_petPrice)
    self.baseView:CloseSelf()
  elseif self.ViewTag == MARKET_PET_BUY_VIEW then
    netsend.netstall.buyCommodity(self.m_petId, 1)
    self.baseView:CloseSelf()
  end
end
function CMarketPetBaseAttr:LoadPetIcon()
  clickArea_check.extend(self)
  if self.m_petObj then
    self.imagepos = self:getNode("imagepos")
    self.imagepos:setVisible(false)
    local p = self.imagepos:getParent()
    local x, y = self.imagepos:getPosition()
    local z = self.imagepos:getZOrder()
    local shapeId = self.m_petObj:getProperty(PROPERTY_SHAPE)
    local roleAni, offx, offy = createWarBodyByShape(shapeId)
    roleAni:playAniWithName("guard_4", -1)
    p:addNode(roleAni, z + 2)
    roleAni:setPosition(ccp(x + offx, y + offy))
    self:addclickAniForPetAni(roleAni, self.imagepos)
    local roleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    p:addNode(roleShadow, z + 1)
    roleShadow:setPosition(x, y)
    local iconPath = data_getPetIconPath(self.m_petObj:getTypeId())
    local iconImg = display.newSprite(iconPath)
    local pet_quality = self:getNode("pet_quality")
    pet_quality:setVisible(false)
    local p = pet_quality:getParent()
    local x, y = pet_quality:getPosition()
    local z = pet_quality:getZOrder()
    local size = pet_quality:getContentSize()
    p:addNode(iconImg, z + 10)
    iconImg:setAnchorPoint(ccp(0, 1))
    iconImg:setPosition(ccp(x, y + size.height))
    self.pet_name = self:getNode("txt_name")
    local petname = ""
    if self.ViewTag == MARKET_PET_BUY_VIEW then
      petname = data_Stall[self.m_petObj:getTypeId()].Name
    else
      petname = self.m_petObj:getProperty(PROPERTY_NAME)
    end
    local pet_lv = self.m_petObj:getProperty(PROPERTY_ROLELEVEL)
    local pet_ZS = self.m_petObj:getProperty(PROPERTY_ZHUANSHENG)
    local lvAndZs = string.format("%d转%d级", pet_ZS, pet_lv)
    self.pet_name:setText(petname)
    self.pet_lv_ZS:setText(lvAndZs)
  end
end
function CMarketPetBaseAttr:showPanel(panel)
  self.panel_attr:setVisible(panel == "BaseAttr")
  self.panel_potential:setVisible(panel == "potential")
end
function CMarketPetBaseAttr:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("txt_czl"), PROPERTY_GROWUP)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_czl"), PROPERTY_GROWUP, self:getNode("txt_czl"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_qx"), PROPERTY_RANDOM_HPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_qx"), PROPERTY_RANDOM_HPBASE, self:getNode("txt_qx"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_fl"), PROPERTY_RANDOM_MPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_fl"), PROPERTY_RANDOM_MPBASE, self:getNode("txt_fl"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_gj"), PROPERTY_RANDOM_APBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_gj"), PROPERTY_RANDOM_APBASE, self:getNode("txt_gj"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_sd"), PROPERTY_RANDOM_SPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_sd"), PROPERTY_RANDOM_SPBASE, self:getNode("txt_sd"))
end
function CMarketPetBaseAttr:LoadPet()
  if self.isOtherPlayer then
    self.m_Player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
    self.m_PetIns = g_BaitanDataMgr:GetOneGood(self.m_petId)
  else
    self.m_Player = g_DataMgr:getPlayer(self.m_PlayerId)
    self.m_PetIns = self.m_Player:getObjById(self.m_petId)
  end
  self:SetBasePotential()
end
function CMarketPetBaseAttr:SetBasePotential()
  if self.m_PetIns == nil then
    return
  end
  local petTypeId = self.m_PetIns:getTypeId()
  local petData = data_Pet[petTypeId] or {}
  if petData == nil then
    return
  end
  local czl = self.m_PetIns:getProperty(PROPERTY_GROWUP)
  local addCzl = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG) * 0.1 + self.m_PetIns:getProperty(PROPERTY_LONGGU_NUM) * 0.01
  local hjNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_NUM)
  if hjNum == 1 then
    addCzl = addCzl + data_Variables.SS_HuaJing1_AddCZL or 0.05
  elseif hjNum == 2 then
    addCzl = addCzl + (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
  elseif hjNum == 3 then
    addCzl = addCzl + (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
  end
  local hlNum = self.m_PetIns:getProperty(PROPERTY_HUALING_NUM)
  for huaLingIndex = 1, LINGSHOU_HUALING_MAX_NUM do
    if huaLingIndex <= hlNum then
      addCzl = addCzl + data_LingShouHuaLing[huaLingIndex].addCZL
    end
  end
  local czl_max = petData.GROWUP * 1.02 + addCzl
  local czl_min = petData.GROWUP * 0.98 + addCzl
  self.txt_pro_czl:setText(string.format("%s/%s", Value2Str(czl, 3), Value2Str(czl_max, 3)))
  self.pro_pro_czl:setPercent(math.min((czl - czl_min) / (czl_max - czl_min) * 100, 100))
  if czl >= czl_max and czl > 0 then
    self:showTipTxt("text_czl", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_czl")
  end
  local addqx = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDHP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDHP)
  local qx = self.m_PetIns:getProperty(PROPERTY_RANDOM_HPBASE) + addqx
  local qx_max = math.floor(petData.HP * 1.2 + 1.0E-8 + addqx)
  local qx_min = math.floor(petData.HP * 0.8 + 1.0E-8 + addqx)
  self.txt_pro_qx:setText(string.format("%d/%d", qx, qx_max))
  self.pro_pro_qx:setPercent(math.min((qx - qx_min) / (qx_max - qx_min) * 100, 100))
  if qx >= qx_max and addqx < qx then
    self:showTipTxt("text_qx", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_qx")
  end
  local addfl = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDMP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDMP)
  local fl = self.m_PetIns:getProperty(PROPERTY_RANDOM_MPBASE) + addfl
  local fl_max = math.floor(petData.MP * 1.2 + 1.0E-8 + addfl)
  local fl_min = math.floor(petData.MP * 0.8 + 1.0E-8 + addfl)
  self.txt_pro_fl:setText(string.format("%d/%d", fl, fl_max))
  self.pro_pro_fl:setPercent(math.min((fl - fl_min) / (fl_max - fl_min) * 100, 100))
  if fl >= fl_max and addfl < fl then
    self:showTipTxt("text_fl", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_fl")
  end
  local addgj = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDAP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDAP)
  local gj = self.m_PetIns:getProperty(PROPERTY_RANDOM_APBASE) + addgj
  local gj_max = math.floor(petData.AP * 1.2 + 1.0E-8 + addgj)
  local gj_min = math.floor(petData.AP * 0.8 + 1.0E-8 + addgj)
  self.txt_pro_gj:setText(string.format("%d/%d", gj, gj_max))
  self.pro_pro_gj:setPercent(math.min((gj - gj_min) / (gj_max - gj_min) * 100, 100))
  if gj >= gj_max and addgj < gj then
    self:showTipTxt("text_gj", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_gj")
  end
  local addsd = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDSP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDSP)
  local sd = self.m_PetIns:getProperty(PROPERTY_RANDOM_SPBASE) + addsd
  local sd_max = math.floor(petData.SP * 1.2 + 1.0E-8 + addsd)
  local sd_min = math.floor(petData.SP * 0.8 + 1.0E-8 + addsd)
  self.txt_pro_sd:setText(string.format("%d/%d", sd, sd_max))
  self.pro_pro_sd:setPercent(math.min((sd - sd_min) / (sd_max - sd_min) * 100, 100))
  if sd >= sd_max and addsd < sd then
    self:showTipTxt("text_sd", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_sd")
  end
end
function CMarketPetBaseAttr:showTipTxt(txtname, txtvalue, txtcolor)
  local txt_1 = self:getNode(string.format("%s_%d", txtname, 1))
  local txt_2 = self:getNode(string.format("%s_%d", txtname, 2))
  local txt_3 = self:getNode(string.format("%s_%d", txtname, 3))
  txt_1:setVisible(true)
  txt_2:setVisible(true)
  txt_3:setVisible(true)
  txt_2:setText(txtvalue)
  txt_2:setColor(txtcolor)
  local x, y = txt_1:getPosition()
  local size = txt_1:getContentSize()
  x = x + size.width
  txt_2:setPosition(ccp(x, y))
  local size = txt_2:getContentSize()
  x = x + size.width
  txt_3:setPosition(ccp(x, y))
end
function CMarketPetBaseAttr:hideTipTxt(txtname)
  local txt_1 = self:getNode(string.format("%s_%d", txtname, 1))
  local txt_2 = self:getNode(string.format("%s_%d", txtname, 2))
  local txt_3 = self:getNode(string.format("%s_%d", txtname, 3))
  txt_1:setVisible(false)
  txt_2:setVisible(false)
  txt_3:setVisible(false)
end
function CMarketPetBaseAttr:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self.m_PetId then
      self:SetBasePotential()
    end
  end
end
function CMarketPetBaseAttr:Clear()
  self.m_LeftBtnListener = nil
  self.m_RightBtnListener = nil
  self.m_PetIns = nil
  self.baseView = nil
end
local CMarketPetBase_KangXingItem = class("CChatKangXing_item", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CMarketPetBase_KangXingItem:ctor(params)
  local w = params.w
  local h = params.h
  local kx_name = params.name
  local kx_value = params.value
  kx_value = Value2Str(kx_value)
  self:setSize(CCSize(w, h))
  local lable_name = CCLabelTTF:create(kx_name, ITEM_NUM_FONT, 22)
  local lable_value = CCLabelTTF:create(kx_value, ITEM_NUM_FONT, 22)
  lable_name:setAnchorPoint(ccp(0, 0))
  lable_value:setAnchorPoint(ccp(0, 0))
  lable_name:setColor(ccc3(211, 139, 29))
  self:addNode(lable_name)
  self:addNode(lable_value)
  local size = lable_name:getContentSize()
  lable_name:setPosition(ccp(25, 0))
  lable_value:setPosition(ccp(w - 35, 0))
end
CMarketPetBase_KangXing = class("CMarketPetBase_KangXing", CcsSubView)
function CMarketPetBase_KangXing:ctor(playerId, petId, isOtherPlayer)
  CMarketPetBase_KangXing.super.ctor(self, "views/marketpetview_kangxing.csb")
  if playerId == nil then
    self.m_Player = g_LocalPlayer
  elseif isOtherPlayer == true then
    self.m_Player = g_BaitanDataMgr:getPlayer(playerId)
  else
    self.m_Player = g_DataMgr:getPlayer(playerId)
  end
  self.m_petObj = self.m_Player:getObjById(petId)
  if self.m_petObj == nil then
    self:CloseSelf()
    return
  end
  self.m_oriPos = self
  self.m_listView = self:getNode("ListView")
  print("===========================:抗性界面", tostring(self.m_Player:getPlayerId()), tostring(petId))
  self:setKXAttr()
  self:SetWuxing()
end
function CMarketPetBase_KangXing:setKXAttr()
  local size = self:getContentSize()
  local size_list = self.m_listView:getContentSize()
  if self.m_petObj == nil then
    return
  end
  local count = 1
  for key, proName in pairs({
    [PROPERTY_PDEFEND] = "物理吸收：",
    [PROPERTY_KHUO] = "抗火：",
    [PROPERTY_KSHUI] = "抗水：",
    [PROPERTY_KLEI] = "抗雷：",
    [PROPERTY_KFENG] = "抗风：",
    [PROPERTY_KHUNLUAN] = "抗混乱：",
    [PROPERTY_KHUNSHUI] = "抗昏睡：",
    [PROPERTY_KZHONGDU] = "抗中毒：",
    [PROPERTY_KFENGYIN] = "抗封印：",
    [PROPERTY_KZHENSHE] = "抗虹吸：",
    [PROPERTY_KAIHAO] = "抗哀嚎：",
    [PROPERTY_KYIWANG] = "抗遗忘：",
    [PROPERTY_KXIXUE] = "抗吸血："
  }) do
    local value = data_getRoleProFromData(self.m_petObj:getTypeId(), key) + self.m_petObj:GetRandomKangByName(key)
    if value ~= 0 then
      local params = {
        name = proName,
        value = value * 100,
        w = size.width - 50,
        h = 30
      }
      local item = CMarketPetBase_KangXingItem.new(params)
      self.m_listView:pushBackCustomItem(item)
      count = count + 1
    end
  end
  self.m_KXShowCount = count
end
function CMarketPetBase_KangXing:SetWuxing()
  if self.m_petObj == nil then
    return
  end
  local petTypeId = self.m_petObj:getTypeId()
  local petData = data_Pet[petTypeId] or {}
  self:getNode("v_jin"):setText(string.format("%d%%", petData.WXJIN * 100))
  self:getNode("v_mu"):setText(string.format("%d%%", petData.WXMU * 100))
  self:getNode("v_shui"):setText(string.format("%d%%", petData.WXSHUI * 100))
  self:getNode("v_huo"):setText(string.format("%d%%", petData.WXHUO * 100))
  self:getNode("v_tu"):setText(string.format("%d%%", petData.WXTU * 100))
end

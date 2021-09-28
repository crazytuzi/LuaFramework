CAddClose = class("CAddClose", CcsSubView)
function CAddClose:ctor(closeListener)
  CAddClose.super.ctor(self, "views/addclose.json")
  self.m_CloseListener = closeListener
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_addclose1 = {
      listener = handler(self, self.OnBtn_AddClose1),
      variName = "btn_addclose1"
    },
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_addclose1:setTitleText("驯养十次")
  local x, y = self:getNode("pos_btn"):getPosition()
  local size = self:getNode("pos_btn"):getSize()
  self.btn_addclose2 = createClickButton("views/common/btn/btn_4words.png", "views/common/btn/btn_4words.png", handler(self, self.OnBtn_AddClose2), 0.5)
  self:addChild(self.btn_addclose2)
  self.btn_addclose2:setPosition(ccp(x, y))
  self.btn_addclose2:setTouchEnabled(true)
  self.m_BtnText = ui.newTTFLabel({
    text = "驯养",
    font = KANG_TTF_FONT,
    size = 22,
    color = ccc3(0, 0, 0)
  })
  self.m_BtnText:setAnchorPoint(ccp(0.5, 0.5))
  self.m_BtnText:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(self.m_BtnText, 1)
  self:setArch()
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CAddClose:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("bg2"), "resachive")
end
function CAddClose:setArch()
  local arch = g_LocalPlayer:getArch()
  self:getNode("text_cj"):setText(tostring(arch))
  local needCJForUpgradeLv = data_Variables.CostArcForPet
  self:getNode("text_needcj"):setText(tostring(needCJForUpgradeLv))
  if arch >= needCJForUpgradeLv then
    self:getNode("text_needcj"):setColor(ccc3(255, 255, 255))
  else
    self:getNode("text_needcj"):setColor(ccc3(255, 0, 0))
  end
  if self.m_CJIcon == nil then
    local x, y = self:getNode("cjicon"):getPosition()
    local z = self:getNode("cjicon"):getZOrder()
    local size = self:getNode("cjicon"):getSize()
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_CHENGJIU))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_CJIcon = tempImg
  end
end
function CAddClose:setCloseValue()
  if self.m_CurRoleIns == nil then
    return
  end
  local petClose = self.m_CurRoleIns:getProperty(PROPERTY_CLOSEVALUE)
  local maxNum = #data_PetClose
  local curIndex = maxNum
  local addLJRate = 0
  local addLJTimes = 0
  local addZMRate = 0
  for i = maxNum, 1, -1 do
    local closeData = data_PetClose[i]
    if closeData ~= nil and petClose >= closeData.closeValue then
      addLJRate = closeData.addLJRate
      addLJTimes = closeData.addLJTimes
      addZMRate = closeData.addZMRate
      curIndex = i
      break
    end
  end
  if self.m_CloseTips ~= nil then
    self.m_CloseTips:removeFromParent()
  end
  local tipsW = self:getNode("tips"):getContentSize().width
  self.m_CloseTips = CRichText.new({
    width = nameW,
    fontSize = 20,
    color = ccc3(255, 255, 0)
  })
  self:addChild(self.m_CloseTips)
  self.m_CloseTips:addRichText(string.format("增加连击率%s%%\n", Value2Str(math.abs(addLJRate) * 100, 1)))
  self.m_CloseTips:addRichText(string.format("增加连击次数%d\n", math.floor(addLJTimes)))
  self.m_CloseTips:addRichText(string.format("增加致命几率%s%%\n", Value2Str(math.abs(addZMRate) * 100, 1)))
  local x, y = self:getNode("tips"):getPosition()
  local h = self.m_CloseTips:getContentSize().height
  self.m_CloseTips:setPosition(ccp(x, y - h + self:getNode("tips"):getContentSize().height))
  local isfullFlag = false
  curIndex = curIndex + 1
  if maxNum < curIndex then
    isfullFlag = true
    curIndex = maxNum
  end
  local maxClose = data_PetClose[curIndex].closeValue or data_PetClose[1].closeValue
  local p = math.round(petClose / maxClose * 100)
  if p < 0 then
    p = 0
  elseif p > 100 then
    p = 100
  end
  self:getNode("close_bar"):setPercent(p)
  self:getNode("close_value"):setText(string.format("%d/%d", checkint(petClose), checkint(maxClose)))
  local size = self:getNode("close_bg"):getContentSize()
  AutoLimitObjSize(self:getNode("close_value"), size.width - 20)
  if isfullFlag then
    self.btn_addclose1:setVisible(false)
    self.btn_addclose1:setTouchEnabled(false)
    self.btn_addclose2:setVisible(false)
    self.btn_addclose2:setTouchEnabled(false)
    self:getNode("text_needcj"):setVisible(false)
    self:getNode("text_cj"):setVisible(false)
    self:getNode("bg2"):setVisible(false)
    self:getNode("text1"):setVisible(false)
    self:getNode("text2"):setText("亲密度已满，无需驯养")
    if self.m_CJIcon then
      self.m_CJIcon:setVisible(false)
    end
    if self.m_BtnText then
      self.m_BtnText:setVisible(false)
    end
  else
    self.btn_addclose1:setVisible(true)
    self.btn_addclose1:setTouchEnabled(true)
    self.btn_addclose2:setVisible(true)
    self.btn_addclose2:setTouchEnabled(true)
    self:getNode("text_needcj"):setVisible(true)
    self:getNode("text_cj"):setVisible(true)
    self:getNode("bg2"):setVisible(true)
    self:getNode("text1"):setVisible(true)
    self:getNode("text2"):setText("驯养费用")
    if self.m_CJIcon then
      self.m_CJIcon:setVisible(true)
    end
    if self.m_BtnText then
      self.m_BtnText:setVisible(true)
    end
  end
end
function CAddClose:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ArchUpdate then
    self:setArch()
  elseif msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if self.m_CurRoleIns and self.m_CurRoleIns:getObjId() == d.petId then
      self:LoadProperties(self.m_CurRoleIns)
    end
  end
end
function CAddClose:LoadProperties(roleIns)
  self.m_CurRoleIns = roleIns
  self:setCloseValue()
end
function CAddClose:OnBtn_Close()
  self:CloseSelf()
end
function CAddClose:OnBtn_AddClose1()
  if self.m_CurRoleIns == nil then
    return
  end
  local pId = self.m_CurRoleIns:getObjId()
  if pId == nil then
    return
  end
  local petClose = self.m_CurRoleIns:getProperty(PROPERTY_CLOSEVALUE)
  local maxNum = #data_PetClose
  local maxValue = data_PetClose[maxNum].closeValue
  for i = maxNum, 1, -1 do
    local closeData = data_PetClose[i]
    if closeData ~= nil and petClose >= closeData.closeValue then
      local nextData = data_PetClose[i + 1]
      if nextData then
        maxValue = nextData.closeValue
        break
      end
    end
  end
  if petClose >= maxValue then
    return
  end
  local arch = g_LocalPlayer:getArch()
  local needArch = 10 * data_Variables.CostArcForPet
  if arch >= needArch then
    netsend.netbaseptc.requestAddPetCloseForOneLevel(pId)
  else
    local warningText = string.format("帮派成就不足\n是否使用#<IR1>#%d换取？", (needArch - arch) * data_Variables.Exchange_Arch2Money)
    local tempPop = CPopWarning.new({
      title = "提示",
      text = warningText,
      confirmFunc = handler(self, self.ConfirmUseMoneyAddClose1),
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
    tempPop:ShowCloseBtn(false)
  end
end
function CAddClose:OnBtn_Help()
  getCurSceneView():addSubView({
    subView = CAddCloseRule.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CAddClose:OnBtn_AddClose2()
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil and curTime - self.m_LastClickTime < 0.3 then
    return
  end
  self.m_LastClickTime = curTime
  if self.m_CurRoleIns == nil then
    self.btn_addclose2:stopLongPressClick()
    return
  end
  local pId = self.m_CurRoleIns:getObjId()
  if pId == nil then
    self.btn_addclose2:stopLongPressClick()
    return
  end
  local arch = g_LocalPlayer:getArch()
  if arch >= data_Variables.CostArcForPet then
    netsend.netbaseptc.requestAddPetCloseOnce(pId)
  else
    local warningText = string.format("帮派成就不足\n是否使用#<IR1>#%d换取？", (data_Variables.CostArcForPet - arch) * data_Variables.Exchange_Arch2Money)
    local tempPop = CPopWarning.new({
      title = "提示",
      text = warningText,
      confirmFunc = handler(self, self.ConfirmUseMoneyAddClose2),
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
    tempPop:ShowCloseBtn(false)
    self.btn_addclose2:stopLongPressClick()
  end
end
function CAddClose:ConfirmUseMoneyAddClose1()
  if self.m_CurRoleIns == nil then
    return
  end
  local pId = self.m_CurRoleIns:getObjId()
  if pId == nil then
    return
  end
  netsend.netbaseptc.requestAddPetCloseForOneLevel(pId)
end
function CAddClose:ConfirmUseMoneyAddClose2()
  if self.m_CurRoleIns == nil then
    return
  end
  local pId = self.m_CurRoleIns:getObjId()
  if pId == nil then
    return
  end
  netsend.netbaseptc.requestAddPetCloseOnce(pId)
end
function CAddClose:Clear()
  if self.m_CloseListener then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
end
CAddCloseRule = class("CAddCloseRule", CcsSubView)
function CAddCloseRule:ctor()
  CAddCloseRule.super.ctor(self, "views/addcloserule.json", {isAutoCenter = true, opacityBg = 0})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetText()
end
function CAddCloseRule:SetText()
  local size = self:getNode("list_text"):getContentSize()
  self.m_TextBox = CRichText.new({
    width = size.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255),
    align = CRichText_AlignType_Left
  })
  self.m_TextBox:addRichText("1.每次驯养将花费帮派成就点1000点。\n2.帮派成就点不足，可以通过铜钱、元宝进行兑换。\n3.每次驯养增加亲密度范围为500-650之间。\n4.召唤兽亲密度为0时，连击率为0.1%、连击次数为\n  2、致命几率为0.1%\n5.当亲密度达到一定阶段时，当前召唤兽的能力随\n  之增加，具体如下：\n  亲密度达到500，连击率为0.3%、连击次数为2、\n  致命几率为0.3%\n  亲密度达到1000，连击率为0.5%、连击次数为2、\n  致命几率为0.5%\n  亲密度达到2000，连击率为0.8%、连击次数为2、\n  致命几率为0.8%\n  亲密度达到5000，连击率为1.2%、连击次数为3、\n  致命几率为1.2%\n  亲密度达到10000，连击率为1.6%、连击次数为3\n  、致命几率为1.6%\n  亲密度达到20000，连击率为3%、连击次数为3、\n  致命几率为2%\n  亲密度达到50000，连击率为5%、连击次数为4、\n  致命几率为5%\n  亲密度达到100000，连击率为7%、连击次数为5、\n  致命几率为6%\n  亲密度达到200000，连击率为9%、连击次数为6、\n  致命几率为7%\n  亲密度达到500000，连击率为12%、连击次数为7\n  、致命几率为8%")
  self:getNode("list_text"):pushBackCustomItem(self.m_TextBox)
end
function CAddCloseRule:Btn_Close(obj, t)
  self:CloseSelf()
end
function CAddCloseRule:Clear()
end

function ShowChangeWXPro()
  getCurSceneView():addSubView({
    subView = CChangeWXPro.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CChangeWXPro = class("CChangeWXPro", CcsSubView)
function CChangeWXPro:ctor(para)
  CChangeWXPro.super.ctor(self, "views/wxzh_view.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_addcoin = {
      listener = handler(self, self.OnBtn_AddMoney),
      variName = "btn_addcoin"
    },
    btn_zhwx = {
      listener = handler(self, self.OnBtn_ZHWX),
      variName = "btn_zhwx"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  for i = 1, 5 do
    local btnName = string.format("btn_sub_%d", i)
    local funcName = string.format("OnBtn_SUB%d", i)
    btnBatchListener[btnName] = {
      listener = handler(self, self[funcName]),
      variName = btnName
    }
    local btnName = string.format("btn_add_%d", i)
    local funcName = string.format("OnBtn_ADD%d", i)
    btnBatchListener[btnName] = {
      listener = handler(self, self[funcName]),
      variName = btnName
    }
  end
  self:addBatchBtnListener(btnBatchListener)
  self:InitData()
  self:InitWXData()
  self:SetWXProData()
  self:SetCost()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CChangeWXPro:InitData()
  self.m_IconDict = {
    {},
    {},
    {},
    {},
    {}
  }
  local x, y = self:getNode("richtextbox"):getPosition()
  local size = self:getNode("richtextbox"):getContentSize()
  self.m_DetailText = CRichText.new({
    width = size.width,
    fontSize = 16,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Left
  })
  self:addChild(self.m_DetailText)
  self.m_DetailText:addRichText("#<IRP,CTP>五行属性会影响所有伤害效果。\n  五行相互克制，没有优劣之分。#")
  local h = self.m_DetailText:getContentSize().height
  self.m_DetailText:setPosition(ccp(x, y + size.height - h))
end
function CChangeWXPro:InitWXData()
  self.m_WXProNum = {}
  for index, proName in ipairs(PROPERTY_LEVEL_WUXING) do
    local num = math.floor(g_LocalPlayer:getObjProperty(1, proName) * 10)
    self.m_WXProNum[index] = num
  end
end
function CChangeWXPro:SetWXProData()
  local startX = 30
  local perX = 10
  for index, proName in ipairs(PROPERTY_LEVEL_WUXING) do
    local num = self.m_WXProNum[index]
    for i = 1, 10 do
      local pathStr = "views/pic/pic_holebg.png"
      if i <= num then
        pathStr = "views/pic/pic_bs_green.png"
      end
      local iconData = self.m_IconDict[index][i]
      local newIcon
      if iconData == nil then
        newIcon = display.newSprite(pathStr)
      else
        local icon = iconData[1]
        if i <= num ~= iconData[2] then
          newIcon = display.newSprite(pathStr)
          icon:removeFromParent()
        end
      end
      if newIcon ~= nil then
        local x, y = self:getNode(string.format("btn_sub_%d", index)):getPosition()
        newIcon:setPosition(ccp(x + startX + (i - 1) * perX, y))
        self:addNode(newIcon)
        self.m_IconDict[index][i] = {
          newIcon,
          i <= num
        }
      end
    end
  end
  local restNum = 10
  for index, tNum in pairs(self.m_WXProNum) do
    restNum = restNum - tNum
    local btnName = string.format("btn_sub_%d", index)
    self[btnName]:setBright(tNum ~= 0)
    self[btnName]:setTouchEnabled(tNum ~= 0)
  end
  if restNum < 0 then
    restNum = 0
  end
  for i = 1, 5 do
    local btnName = string.format("btn_add_%d", i)
    self[btnName]:setBright(restNum > 0)
    self[btnName]:setTouchEnabled(restNum > 0)
  end
  self:getNode("txt_fenpei"):setText(string.format("可分配五行比例:%d%%", restNum * 10))
end
function CChangeWXPro:SetCost(price)
  local changeWuxingNum = g_LocalPlayer.m_ChangeWuxingNum
  local price = 0
  if changeWuxingNum ~= 0 then
    price = data_Variables.ChangeWuXingCost
  end
  if self.m_CoinIcon == nil then
    local x, y = self:getNode("box_coin_cur"):getPosition()
    local z = self:getNode("box_coin_cur"):getZOrder()
    local size = self:getNode("box_coin_cur"):getSize()
    self:getNode("box_coin_cur"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_CoinIcon = tempImg
  end
  if price == 0 then
    self:getNode("txt_coin_cur"):setText("首次免费")
    self.btn_addcoin:setEnabled(false)
  else
    self:getNode("txt_coin_cur"):setText(string.format("%d", price))
    self.btn_addcoin:setEnabled(true)
  end
  AutoLimitObjSize(self:getNode("txt_coin_cur"), 100)
  local player = g_DataMgr:getPlayer()
  if price > player:getCoin() then
    self:getNode("txt_coin_cur"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("txt_coin_cur"):setColor(ccc3(255, 255, 255))
  end
end
function CChangeWXPro:OnBtn_ZHWX(obj, t)
  print_lua_table(self.m_WXProNum)
  local changeFlag = false
  for index, proName in ipairs(PROPERTY_LEVEL_WUXING) do
    local num = math.floor(g_LocalPlayer:getObjProperty(1, proName) * 10)
    if num ~= self.m_WXProNum[index] then
      changeFlag = true
      break
    end
  end
  if changeFlag == false then
    ShowNotifyTips("五行没有更改，不需要转换")
    return
  end
  local restNum = 10
  for index, tNum in pairs(self.m_WXProNum) do
    restNum = restNum - tNum
  end
  if restNum > 0 then
    ShowNotifyTips("仍有可分配的五行比例")
    return
  end
  local changeWuxingNum = g_LocalPlayer.m_ChangeWuxingNum
  local price = 0
  if changeWuxingNum ~= 0 then
    price = data_Variables.ChangeWuXingCost
  end
  local tips = ""
  if price == 0 then
    tips = "你确定要转换五行吗？"
  else
    tips = string.format("你确定要花费%d#<IR1>#\n转换五行吗？", price)
  end
  local dlg = CPopWarning.new({
    title = "提示",
    text = tips,
    confirmFunc = function()
      local tempWXList = {}
      for _, v in ipairs(self.m_WXProNum) do
        tempWXList[#tempWXList + 1] = v * 10
      end
      netsend.netbaseptc.ChangeWuXingPro(tempWXList)
    end,
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  dlg:ShowCloseBtn(false)
end
function CChangeWXPro:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CChangeWXPro:OnBtn_AddMoney()
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CChangeWXPro:SubProNum(index)
  self.m_WXProNum[index] = math.max(0, self.m_WXProNum[index] - 1)
  self:SetWXProData()
end
function CChangeWXPro:AddProNum(index)
  local restNum = 10
  for _, tNum in pairs(self.m_WXProNum) do
    restNum = restNum - tNum
  end
  if restNum <= 0 then
    return
  end
  self.m_WXProNum[index] = math.min(10, self.m_WXProNum[index] + 1)
  self:SetWXProData()
end
function CChangeWXPro:OnBtn_SUB1()
  self:SubProNum(1)
end
function CChangeWXPro:OnBtn_SUB2()
  self:SubProNum(2)
end
function CChangeWXPro:OnBtn_SUB3()
  self:SubProNum(3)
end
function CChangeWXPro:OnBtn_SUB4()
  self:SubProNum(4)
end
function CChangeWXPro:OnBtn_SUB5()
  self:SubProNum(5)
end
function CChangeWXPro:OnBtn_ADD1()
  self:AddProNum(1)
end
function CChangeWXPro:OnBtn_ADD2()
  self:AddProNum(2)
end
function CChangeWXPro:OnBtn_ADD3()
  self:AddProNum(3)
end
function CChangeWXPro:OnBtn_ADD4()
  self:AddProNum(4)
end
function CChangeWXPro:OnBtn_ADD5()
  self:AddProNum(5)
end
function CChangeWXPro:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ChangeWuxingNum then
    self:InitWXData()
    self:SetWXProData()
    self:SetCost()
  end
end
function CChangeWXPro:Clear()
end

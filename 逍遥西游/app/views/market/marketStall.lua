BAITAN_INIT_POSNUM = 8
BAITAN_SPEND_MONEY = 20
MARKET_STALL_SHOWING_PET = 1
MARKET_STALL_SHOWING_ITEM = 2
CMarketStall = class("CMarketStall", CcsSubView)
function CMarketStall:ctor(para)
  para = para or {}
  local initViewType = para.initViewType or MARKET_STALL_SHOWING_ITEM
  CMarketStall.super.ctor(self, "views/market_stall.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_shopping = {
      listener = handler(self, self.Btn_Shopping),
      variName = "btn_shopping"
    },
    btn_baitan = {
      listener = handler(self, self.Btn_baitan),
      variName = "btn_baitan"
    },
    btn_close = {
      listener = handler(self, self.Btn_close),
      variName = "btn_close"
    },
    btn_equipview = {
      listener = handler(self, self.Btn_EquipView),
      variName = "btn_equipview"
    },
    btn_petview = {
      listener = handler(self, self.Btn_petView),
      variName = "btn_petview"
    },
    btn_addCoin = {
      listener = handler(self, self.Btn_AddCoin),
      variName = "btn_addCoin"
    },
    btn_addtanwei = {
      listener = handler(self, self.Btn_AddTanWei),
      variName = "btn_addtanwei"
    },
    btn_tidy = {
      listener = handler(self, self.Btn_Tidy),
      variName = "btn_tidy"
    },
    btn_getallmoney = {
      listener = handler(self, self.Btn_GetAllMoney),
      variName = "btn_getallmoney"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_baitan,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    },
    {
      self.btn_shopping,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    }
  })
  self:addBtnSigleSelectGroup({
    {
      self.btn_equipview,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petview,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.objItemList = self:getNode("subviewPos")
  self.objItemList:setEnabled(true)
  self:ListenMessage(MsgID_Stall)
  self:ListenMessage(MsgID_PlayerInfo)
  self:CreateMyStallBoard()
  self:setBaitanBaseData()
  self:setCoinIcon()
  self:SetAttrTips()
  if initViewType == MARKET_STALL_SHOWING_ITEM then
    self:Btn_EquipView()
  else
    self:Btn_petView()
  end
  netsend.netstall.openStallDir(0, true)
end
function CMarketStall:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinbg"), "rescoin")
end
function CMarketStall:CreateMyStallBoard()
  local bgNode = self:getNode("pic_itemlist")
  if self.marketBoard ~= nil then
    self.marketBoard:removeFromParent()
  end
  self.marketBoard = marketShoppingBoard.new(MARKET_SCROLL_SELL_VIEW, 0, {bgNode = bgNode})
  local ctrObj = self:getNode("goods_list")
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  self:addChild(self.marketBoard, zOrder)
  self.marketBoard:setPosition(ccp(x, y))
end
function CMarketStall:CreatePackageView()
  local bgNode = self:getNode("pic_itemlist")
  if self.m_PackageView then
    self.m_PackageView:removeFromParent()
    self.m_PackageView = nil
  end
  local tempView = CMarketPackageView.new({bgNode = bgNode})
  self.m_PackageView = tempView
  self:addChild(tempView.m_UINode)
  local x, y = self.objItemList:getPosition()
  tempView:setPosition(ccp(x - 10, y - 15))
end
function CMarketStall:CreatePetListView()
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:removeFromParent()
    self.m_PetListBoard_Normal = nil
  end
  local lTypeList = {}
  local petObjIdList = {}
  local petIdList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  for k, id in pairs(petIdList) do
    local petIns = g_LocalPlayer:getObjById(id)
    if petIns then
      local petTypeId = petIns:getTypeId()
      for i, data in pairs(data_Stall) do
        if petTypeId == i and data.isitem == 0 then
          lTypeList[#lTypeList + 1] = petTypeId
          petObjIdList[#petObjIdList + 1] = id
        end
      end
    end
  end
  self.m_PetListBoard_Normal = CDisplayPetBoard.new({
    petTypeList = lTypeList,
    petObjIdList = petObjIdList,
    clickListener = handler(self, self.OnSelectPet),
    xySpace = ccp(32, 20),
    headSize = CCSize(75, 75),
    initType = nil,
    pageLines = 4,
    oneLineNum = 2
  }, true)
  local ctrObj = self.objItemList
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  self:addChild(self.m_PetListBoard_Normal, zOrder)
  self.m_PetListBoard_Normal:setPosition(ccp(x + 20, y - 15))
end
function CMarketStall:OnSelectPet(petTypeId, petObjId)
  local bgNode = self:getNode("pic_itemlist")
  local x, y = bgNode:getPosition()
  local bgSize = bgNode:getContentSize()
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:ClearSelectItem()
  end
  if petTypeId and petObjId then
    local tempView = CMarketPetView.new(petObjId, g_LocalPlayer:getPlayerId(), {
      leftBtn = {btnText = " 上架", listener = nil},
      bg_x = x,
      bg_y = y,
      bgSize = bgSize
    }, false, MARKET_PET_PACKAGE_VIEW, nil, nil)
    bgNode:getParent():addChild(tempView.m_UINode, MainUISceneZOrder.menuView)
  end
end
function CMarketStall:frushPetView()
  self:CreatePetListView()
  if self.m_ShowingView == MARKET_STALL_SHOWING_PET then
    self:Btn_petView()
  else
    self:Btn_EquipView()
  end
end
function CMarketStall:setCoinIcon()
  local x, y = self:getNode("box_coin"):getPosition()
  local z = self:getNode("box_coin"):getZOrder()
  local size = self:getNode("box_coin"):getSize()
  self:getNode("box_coin"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:setPlayerTotalCoin()
end
function CMarketStall:setPlayerTotalCoin()
  local totalCoin = g_LocalPlayer:getCoin()
  local text_coin = self:getNode("text_coin")
  text_coin:setText(tostring(totalCoin))
  AutoLimitObjSize(text_coin, 92)
end
function CMarketStall:setBaitanBaseData()
  local btBaseData = g_BaitanDataMgr:GetBaseData()
  if btBaseData == nil then
    return
  end
  local curExpandNum = btBaseData.expandnum or 0
  local curShangJiaNum = btBaseData.num or 0
  local curTanWeiNum = BAITAN_INIT_POSNUM + curExpandNum
  local spMoney = BAITAN_SPEND_MONEY
  if curExpandNum <= 0 then
    spMoney = BAITAN_SPEND_MONEY
  else
    spMoney = BAITAN_SPEND_MONEY * (curExpandNum + 1)
  end
  self:getNode("txt_tanwei"):setText(string.format("%d/%d", curShangJiaNum, curTanWeiNum))
end
function CMarketStall:Btn_Shopping(obj, objType)
  if g_Market then
    g_Market:ShowCoinMarket(BaitanShow_InitShow_ShoppingView)
  end
end
function CMarketStall:Btn_baitan(obj, objType)
end
function CMarketStall:Btn_close(obj, objType)
  if g_Market ~= nil then
    g_Market:CloseSelf()
    netsend.netstall.colseView()
  end
end
function CMarketStall:Btn_Tidy(obj, objType)
  local curTime = cc.net.SocketTCP.getTime()
  local temp = 6
  if self.m_LastZhengliTime ~= nil then
    temp = curTime - self.m_LastZhengliTime
  end
  local temp = math.floor(temp)
  if temp < 5 then
    local tips = string.format("你刚刚已经进行过整理，请隔%d秒再试", 5 - temp)
    ShowNotifyTips(tips)
    return
  else
    self.m_LastZhengliTime = curTime
    netsend.netitem.requestZhengliPackage()
  end
end
function CMarketStall:Btn_AddCoin(obj, objType)
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CMarketStall:Btn_AddTanWei(obj, objType)
  local spMoney = BAITAN_SPEND_MONEY
  local btBaseData = g_BaitanDataMgr:GetBaseData()
  if btBaseData ~= nil then
    local curExpandNum = btBaseData.expandnum or 0
    if curExpandNum <= 0 then
      spMoney = BAITAN_SPEND_MONEY
    else
      spMoney = BAITAN_SPEND_MONEY * (curExpandNum + 1)
    end
  end
  local pView = CPopWarning.new({
    title = "提示",
    text = string.format("是否需要花费%d#<IR2>#开启一个摊位", spMoney),
    confirmText = "确定",
    cancelText = "取消",
    confirmCloseFlag = true,
    confirmFunc = function()
      netsend.netstall.expandStalls()
    end,
    cancelFunc = nil,
    align = CRichText_AlignType_Left
  })
  pView:ShowCloseBtn(false)
end
function CMarketStall:Btn_GetAllMoney()
  netsend.netstall.getAllMoney()
end
function CMarketStall:Btn_petView()
  if self.m_PackageView then
    self.m_PackageView:setVisible(false)
    self.m_PackageView:setEnabled(false)
  end
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:setVisible(true)
    self.m_PetListBoard_Normal:setEnabled(true)
  else
    self:CreatePetListView()
  end
  self.m_ShowingView = MARKET_STALL_SHOWING_PET
  self:setGroupBtnSelected(self.btn_petview)
  self.btn_tidy:setEnabled(false)
end
function CMarketStall:Btn_EquipView(obj, objType)
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:setVisible(false)
    self.m_PetListBoard_Normal:setEnabled(false)
  end
  if self.m_PackageView then
    self.m_PackageView:setVisible(true)
    self.m_PackageView:setEnabled(true)
  else
    self:CreatePackageView()
  end
  self.m_ShowingView = MARKET_STALL_SHOWING_ITEM
  self:setGroupBtnSelected(self.btn_equipview)
  self.btn_tidy:setEnabled(true)
end
function CMarketStall:OnMessage(msgSID, ...)
  if msgSID == MsgID_Stall_UpdateBaseData then
    self:setBaitanBaseData()
  elseif msgSID == MsgID_DeletePet then
    self:frushPetView()
  elseif msgSID == MsgID_AddPet then
    self:frushPetView()
  elseif msgSID == MsgID_MoneyUpdate then
    self:setPlayerTotalCoin()
  end
end
function CMarketStall:Clear()
end
CMarketPackageView = class("CMarketPackageView", CcsSubView)
function CMarketPackageView:ctor(paramTable)
  self.m_bgNode = paramTable.bgNode
  local x, y = self.m_bgNode:getPosition()
  self.m_bg_x = x
  self.m_bg_y = y
  self.m_bgSize = self.m_bgNode:getContentSize()
  CMarketPackageView.super.ctor(self, "views/huoban_package.json")
  self.layer_itemlist = self:getNode("layer_itemlist")
  self.layer_itemlist:setVisible(false)
  local x, y = self.layer_itemlist:getPosition()
  local z = self.layer_itemlist:getZOrder()
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(90, 94),
    pageLines = 4,
    oneLineNum = 3,
    pageIconOffY = -20
  }
  local tempSelectFunc = function(itemObj)
    local itemId = itemObj:getObjId()
    local itemType = itemObj:getTypeId()
    local itemLargeType = itemObj:getType()
    if data_Stall[itemType] == nil then
      return false
    end
    if data_Stall[itemType].isitem ~= 1 then
      return false
    end
    return true
  end
  self.m_PackageFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_ALL, function(itemObjId)
    self:ShowPackageDetail(itemObjId, nil)
  end, nil, param, tempSelectFunc, nil, nil, nil, ExPackageGetCanNotUseFunc)
  self:addChild(self.m_PackageFrame, z + 100)
  self.m_PackageFrame:setPosition(ccp(x, y))
end
function CMarketPackageView:ShowPackageDetail(itemObjId)
  local midPos = self:getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  if packageItemIns == nil then
    return
  end
  local temp = CMarketStallBuyView.new(itemObjId, {
    leftBtn = {btnText = "上架"},
    closeListener = handler(self, self.OnItemDetailClosed),
    bg_x = self.m_bg_x,
    bg_y = self.m_bg_y,
    bgSize = self.m_bgSize
  })
  self.m_bgNode:getParent():addChild(temp.m_UINode, MainUISceneZOrder.menuView)
  temp:ShowCloseBtn()
end
function CMarketPackageView:OnItemDetailClosed()
  if self and self.m_PackageFrame then
    self.m_PackageFrame:ClearSelectItem()
  end
end

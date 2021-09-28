CPacakgeZBShow = class("CPacakgeZBShow", CcsSubView)
g_PackageZBView = nil
function PutItemToUpgradePackageZhuangbei(itemId, playActionFlag)
  if g_PackageZBView ~= nil then
    if itemId == nil then
      g_PackageZBView:SetItemDetail(g_PackageZBView.m_OldItemId)
    else
      g_PackageZBView:SetItemDetail(itemId)
    end
    g_PackageZBView:SetItemUpgradeType(g_PackageZBView.m_UpgradeType)
    if playActionFlag == true then
      g_PackageZBView:SetUpgradeAction()
      ShowWarningInWar()
    end
  end
end
function CPacakgeZBShow:ctor(para)
  CPacakgeZBShow.super.ctor(self, "views/pzb_view.json", {isAutoCenter = true, opacityBg = 100})
  para = para or {}
  local initRoleItem = para.InitRoleItem or 0
  local initItemId = para.InitItemId or 0
  local initRoleId = para.InitRoleId
  local initUpgradeType = para.InitUpgradeType or 0
  self.m_CloseFunc = para.closeListener
  self.m_SellItemListener = para.sellItemListener
  self.m_TakeonItemListener = para.takeonItemListener
  self.m_ItemIdOnRole = initRoleItem
  self.m_ItemIdOnPackage = initItemId
  self.m_RoleId = initRoleId
  self.m_BtnDelX = 0
  self:InitBtns()
  self:InitBoards()
  self:SetBtnsShow()
  initUpgradeType = self:GetNewUpgradeType(initUpgradeType)
  self:SetItemUpgradeType(initUpgradeType)
  g_PackageZBView = self
end
function CPacakgeZBShow:onEnterEvent()
  if self._auto_create_opacity_bg_ins and self.m_BlackBgEnableFlag ~= nil then
    self._auto_create_opacity_bg_ins:setEnabled(self.m_BlackBgEnableFlag)
  end
end
function CPacakgeZBShow:InitBtns()
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_base = {
      listener = handler(self, self.OnBtn_Base),
      variName = "btn_base"
    },
    btn_qianghua = {
      listener = handler(self, self.OnBtn_Qianghua),
      variName = "btn_qianghua"
    },
    btn_lianhua = {
      listener = handler(self, self.OnBtn_Lianhua),
      variName = "btn_lianhua"
    },
    btn_chongzhu = {
      listener = handler(self, self.OnBtn_Chongzhu),
      variName = "btn_chongzhu"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_base,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_qianghua,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_lianhua,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_chongzhu,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_base:setTitleText("装\n备\n属\n性")
  self.btn_qianghua:setTitleText("强\n化\n装\n备")
  self.btn_lianhua:setTitleText("炼\n化\n装\n备")
  self.btn_chongzhu:setTitleText("重\n铸\n装\n备")
  local size = self.btn_base:getContentSize()
  self:adjustClickSize(self.btn_base, size.width + 30, size.height, true)
  local size = self.btn_qianghua:getContentSize()
  self:adjustClickSize(self.btn_qianghua, size.width + 30, size.height, true)
  local size = self.btn_lianhua:getContentSize()
  self:adjustClickSize(self.btn_lianhua, size.width + 30, size.height, true)
  local size = self.btn_chongzhu:getContentSize()
  self:adjustClickSize(self.btn_chongzhu, size.width + 30, size.height, true)
  self:setGroupAllNotSelected(self.btn_qianghua)
  self.m_BtnPosList = {}
  for _, btnName in ipairs({
    "btn_base",
    "btn_qianghua",
    "btn_lianhua",
    "btn_chongzhu"
  }) do
    local x, y = self[btnName]:getPosition()
    self.m_BtnPosList[#self.m_BtnPosList + 1] = ccp(x, y)
  end
  local x, y = self.btn_close:getPosition()
  self.m_OldCloseBtnPos = ccp(x, y)
end
function CPacakgeZBShow:SetItemDetail(itemId)
  self.m_ItemIdOnPackage = itemId
  self.m_OldItemId = self.m_ItemIdOnPackage
end
function CPacakgeZBShow:SetUpgradeAction()
  if self.m_StuffBoard then
    self.m_StuffBoard:SetUpgradeAction()
  end
end
function CPacakgeZBShow:InitBoards()
  self.m_ItemBoardOnRole = nil
  if self.m_ItemIdOnRole ~= nil and self.m_ItemIdOnRole ~= 0 then
    self.m_ItemBoardOnRole = CPacakgeZBItemBoard.new({
      itemId = self.m_ItemIdOnRole,
      hId = self.m_RoleId,
      isOnRoleFlag = true
    })
    self:addSubView({
      subView = self.m_ItemBoardOnRole
    })
    local x, y = self:getNode("box_bgpos1"):getPosition()
    self.m_ItemBoardOnRole:setPosition(ccp(x, y))
    self.m_ItemBoardOnRole:setEnabled(false)
  end
  self.m_ItemBoardOnPackage = CPacakgeZBItemBoard.new({
    itemId = self.m_ItemIdOnPackage,
    hId = self.m_RoleId,
    isOnRoleFlag = false,
    sellFunc = self.m_SellItemListener,
    takeOnFunc = self.m_TakeonItemListener
  })
  self:addSubView({
    subView = self.m_ItemBoardOnPackage
  })
  local x, y = self:getNode("box_bgpos2"):getPosition()
  self.m_ItemBoardOnPackage:setPosition(ccp(x, y))
  self.m_ItemBoardOnPackage:setEnabled(false)
  self.m_StuffBoard = CPacakgeZBStuffBoard.new()
  self:addSubView({
    subView = self.m_StuffBoard
  })
  local x, y = self:getNode("box_bgpos2"):getPosition()
  self.m_StuffBoard:setPosition(ccp(x, y))
  self.m_StuffBoard:setEnabled(false)
  self.m_OldItemId = self.m_ItemIdOnPackage
end
function CPacakgeZBShow:SetBtnsShow()
  self.m_ShowBtnsFlag = {}
  if self.m_ItemIdOnPackage == nil then
    self.m_ShowBtnsFlag = {
      [0] = false,
      [Eqpt_Upgrade_LianhuaType] = false,
      [Eqpt_Upgrade_ChonglianType] = false,
      [Eqpt_Upgrade_QianghuaType] = false
    }
  else
    local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemIdOnPackage)
    if itemIns == nil then
      self.m_ShowBtnsFlag = {
        [0] = false,
        [Eqpt_Upgrade_LianhuaType] = false,
        [Eqpt_Upgrade_ChonglianType] = false,
        [Eqpt_Upgrade_QianghuaType] = false
      }
    else
      local mainHero = g_LocalPlayer:getMainHero()
      local mainHeroType = mainHero:getTypeId()
      local largeType = itemIns:getType()
      local lv = itemIns:getProperty(ITEM_PRO_LV)
      if largeType == ITEM_LARGE_TYPE_EQPT then
        self.m_ShowBtnsFlag[Eqpt_Upgrade_ChonglianType] = false
      end
      local holeNum = itemIns:getProperty(ITME_PRO_EQPT_HOLENUM)
      local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
      if holeNum <= 0 then
        self.m_ShowBtnsFlag[Eqpt_Upgrade_QianghuaType] = false
      elseif holeNum <= bsNum then
        self.m_ShowBtnsFlag[Eqpt_Upgrade_QianghuaType] = false
      end
    end
  end
  local tempBtnDict = {
    [0] = self.btn_base,
    [Eqpt_Upgrade_LianhuaType] = self.btn_lianhua,
    [Eqpt_Upgrade_ChonglianType] = self.btn_chongzhu,
    [Eqpt_Upgrade_QianghuaType] = self.btn_qianghua
  }
  local index = 1
  local newUpgradeType
  for _, uType in pairs({
    0,
    Eqpt_Upgrade_QianghuaType,
    Eqpt_Upgrade_LianhuaType,
    Eqpt_Upgrade_ChonglianType
  }) do
    local btn = tempBtnDict[uType]
    if self.m_ShowBtnsFlag[uType] ~= false then
      local tccp = self.m_BtnPosList[index]
      local x = tccp.x + self.m_BtnDelX
      self:setGroupBtnPosition(btn, ccp(x, tccp.y))
      index = index + 1
      btn:setEnabled(true)
      btn:setTouchEnabled(true)
      if newUpgradeType == nil then
        newUpgradeType = uType
      end
    else
      btn:setEnabled(false)
      btn:setTouchEnabled(false)
    end
  end
  local tccp = self.m_OldCloseBtnPos
  local x = tccp.x + self.m_BtnDelX
  self.btn_close:setPosition(ccp(x, tccp.y))
  self.btn_close:setEnabled(true)
  self.btn_close:setTouchEnabled(true)
end
function CPacakgeZBShow:GetNewUpgradeType(tempUpgradeType)
  local newUpgradeType
  for _, uType in pairs({
    0,
    Eqpt_Upgrade_QianghuaType,
    Eqpt_Upgrade_LianhuaType,
    Eqpt_Upgrade_ChonglianType
  }) do
    if self.m_ShowBtnsFlag[uType] ~= false and newUpgradeType == nil then
      newUpgradeType = uType
    end
  end
  if self.m_ShowBtnsFlag[tempUpgradeType] == false then
    tempUpgradeType = newUpgradeType or 0
  end
  return tempUpgradeType
end
function CPacakgeZBShow:SetItemUpgradeType(upgradeType)
  if self.m_ItemIdOnPackage == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemIdOnPackage)
  if itemIns == nil then
    return
  end
  if upgradeType == nil then
    return
  end
  if self.m_UpgradeType ~= nil then
    if self.m_UpgradeType > 0 and upgradeType > 0 or self.m_UpgradeType == 0 and upgradeType == 0 then
      self.m_UpgradeType = upgradeType
      self:AfterAction()
    else
      if self.m_ItemBoardOnRole ~= nil then
        self.m_ItemBoardOnRole:setEnabled(false)
      end
      self.m_StuffBoard:setEnabled(false)
      self.m_ItemBoardOnPackage:setEnabled(true)
      self.m_ItemBoardOnPackage:SetCanOp(false)
      for _, btnName in pairs({
        "btn_close",
        "btn_base",
        "btn_lianhua",
        "btn_chongzhu",
        "btn_qianghua"
      }) do
        local btn = self[btnName]
        if btn then
          btn:setEnabled(false)
          btn:setTouchEnabled(false)
        end
      end
      local x, y = self:getNode("box_bgpos1"):getPosition()
      local delTime = 0.38
      if self.m_ItemBoardOnRole == nil then
        delTime = 0.2
      end
      if upgradeType > 0 then
        x, _ = self:getNode("box_bgpos1"):getPosition()
      elseif self.m_ItemBoardOnRole == nil then
        local x1, _ = self:getNode("box_bgpos1"):getPosition()
        local x2, _ = self:getNode("box_bgpos2"):getPosition()
        x = (x1 + x2) / 2
      else
        x, _ = self:getNode("box_bgpos2"):getPosition()
      end
      self.m_ItemBoardOnPackage:stopAllActions()
      local moveAct = CCMoveTo:create(delTime, ccp(x, y))
      local afterFunc = CCCallFunc:create(function()
        self:AfterAction()
      end)
      self.m_ItemBoardOnPackage:runAction(transition.sequence({moveAct, afterFunc}))
      self.m_UpgradeType = upgradeType
    end
  else
    self.m_UpgradeType = upgradeType
    self:AfterAction()
  end
end
function CPacakgeZBShow:AfterAction()
  if self.m_UpgradeType == 0 then
    if self.m_ItemBoardOnRole == nil then
      local x1, y = self:getNode("box_bgpos1"):getPosition()
      local x2, _ = self:getNode("box_bgpos2"):getPosition()
      self.m_ItemBoardOnPackage:setPosition(ccp((x1 + x2) / 2, y))
      self.m_StuffBoard:setEnabled(false)
      self.m_ItemBoardOnPackage:setEnabled(true)
      self:setMsgThrough(true)
    else
      self.m_StuffBoard:setEnabled(false)
      self.m_ItemBoardOnRole:setEnabled(true)
      self.m_ItemBoardOnPackage:setEnabled(true)
      self:setMsgThrough(false)
    end
  else
    self.m_StuffBoard:setEnabled(true)
    if self.m_ItemBoardOnRole ~= nil then
      self.m_ItemBoardOnRole:setEnabled(false)
    end
    self.m_ItemBoardOnPackage:setEnabled(true)
    self:setMsgThrough(false)
  end
  self.m_ItemBoardOnPackage:SetCanOp(true)
  local tempBtnDict = {
    [0] = self.btn_base,
    [Eqpt_Upgrade_LianhuaType] = self.btn_lianhua,
    [Eqpt_Upgrade_ChonglianType] = self.btn_chongzhu,
    [Eqpt_Upgrade_QianghuaType] = self.btn_qianghua
  }
  self:setGroupBtnSelected(tempBtnDict[self.m_UpgradeType])
  self.m_ItemBoardOnPackage:SetItemData()
  self.m_StuffBoard:setStuffData(self.m_ItemIdOnPackage, self.m_UpgradeType)
end
function CPacakgeZBShow:setMsgThrough(flag)
  self.m_BlackBgEnableFlag = not flag
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setEnabled(not flag)
  end
  local oldBtnDelX = self.m_BtnDelX
  if flag == true then
    local x1, y = self:getNode("box_bgpos1"):getPosition()
    local x2, _ = self:getNode("box_bgpos2"):getPosition()
    local bgSize = self:getNode("box_bgpos2"):getContentSize()
    local btnW = 70
    local wp1 = self:getUINode():convertToWorldSpace(ccp((x1 + x2) / 2, y))
    local wp2 = self:getUINode():convertToWorldSpace(ccp((x1 + x2) / 2 + bgSize.width + btnW, y + bgSize.height))
    self:enableCloseWhenTouchOutsideBySize(CCRect(wp1.x, wp1.y, wp2.x - wp1.x, wp2.y - wp1.y))
    self:getNode("rootlayer"):setTouchEnabled(false)
    self.m_BtnDelX = -bgSize.width / 2
  else
    self:disableCloseWhenTouchOut()
    self:getNode("rootlayer"):setTouchEnabled(true)
    self.m_BtnDelX = 0
  end
  self:SetBtnsShow()
end
function CPacakgeZBShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CPacakgeZBShow:OnBtn_Base(btnObj, touchType)
  self:SetItemUpgradeType(0)
end
function CPacakgeZBShow:OnBtn_Qianghua(btnObj, touchType)
  self:SetItemUpgradeType(Eqpt_Upgrade_QianghuaType)
end
function CPacakgeZBShow:OnBtn_Lianhua(btnObj, touchType)
  self:SetItemUpgradeType(Eqpt_Upgrade_LianhuaType)
end
function CPacakgeZBShow:OnBtn_Chongzhu(btnObj, touchType)
  self:SetItemUpgradeType(Eqpt_Upgrade_ChonglianType)
end
function CPacakgeZBShow:Clear()
  print("CPacakgeZBShow:Clear")
  if self.m_CloseFunc ~= nil then
    self.m_CloseFunc(self)
  end
  self.m_CloseFunc = nil
  self.m_SellItemListener = nil
  self.m_TakeonItemListener = nil
  if g_PackageZBView == self then
    g_PackageZBView = nil
  end
end
CPacakgeZBItemBoard = class("CPacakgeZBItemBoard", CcsSubView)
function CPacakgeZBItemBoard:ctor(para)
  CPacakgeZBItemBoard.super.ctor(self, "views/pzb_view_board1.json")
  para = para or {}
  self.m_ItemId = para.itemId
  self.m_RoleId = para.hId
  self.m_OnRoleFlag = para.isOnRoleFlag
  self.m_SellItemFunc = para.sellFunc
  self.m_TakeOnItemFunc = para.takeOnFunc
  if self.m_OnRoleFlag ~= true then
    local btnBatchListener = {
      btn_sell = {
        listener = handler(self, self.OnBtn_Sell),
        variName = "btn_sell"
      },
      btn_takeon = {
        listener = handler(self, self.OnBtn_TakeOn),
        variName = "btn_takeon"
      }
    }
    self:addBatchBtnListener(btnBatchListener)
  else
    self:getNode("btn_sell"):setVisible(false)
    self:getNode("btn_takeon"):setVisible(false)
    self:getNode("btn_sell"):setTouchEnabled(false)
    self:getNode("btn_takeon"):setTouchEnabled(false)
  end
  self:SetItemData()
end
function CPacakgeZBItemBoard:SetItemData()
  self.list_detail = self:getNode("list_detail")
  if self.m_ItemDetailText == nil and self.m_OnRoleFlag == true then
    local x, y = self.list_detail:getPosition()
    local lSize = self.list_detail:getContentSize()
    local offy = 70
    self.list_detail:ignoreContentAdaptWithSize(false)
    self.list_detail:setPosition(ccp(x, y - offy))
    self.list_detail:setSize(CCSize(lSize.width, lSize.height + offy))
  end
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  self.list_detail:removeAllItems()
  self.m_ItemDetailText = CItemDetailText.new(self.m_ItemId, {
    width = lSize.width - 5
  }, nil, self.m_RoleId)
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5
  })
  self:addChild(self.m_ItemDetailHead)
  local roleIns = g_LocalPlayer:getObjById(self.m_RoleId)
  if roleIns ~= nil and roleIns:getType() == LOGICTYPE_HERO and self.m_RoleId ~= g_LocalPlayer:getMainHeroId() and self.m_OnRoleFlag == true then
    self.m_ItemDetailHead:ShowItemDetail(self.m_ItemId, nil, self.m_RoleId, nil, self.m_OnRoleFlag, true)
  else
    self.m_ItemDetailHead:ShowItemDetail(self.m_ItemId, nil, self.m_RoleId, nil, self.m_OnRoleFlag, false)
  end
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
end
function CPacakgeZBItemBoard:SetCanOp(flag)
  if self.m_OnRoleFlag ~= true then
    if self.btn_sell then
      self.btn_sell:setTouchEnabled(flag)
    end
    if self.btn_takeon then
      self.btn_takeon:setTouchEnabled(flag)
    end
  end
end
function CPacakgeZBItemBoard:OnBtn_Sell(btnObj, touchType)
  if self.m_SellItemFunc then
    self.m_SellItemFunc(self.m_ItemId)
  end
end
function CPacakgeZBItemBoard:OnBtn_TakeOn(btnObj, touchType)
  if self.m_TakeOnItemFunc then
    self.m_TakeOnItemFunc(self.m_ItemId)
  end
end
function CPacakgeZBItemBoard:Clear()
  print("CPacakgeZBItemBoard:Clear")
end
CPacakgeZBStuffBoard = class("CPacakgeZBStuffBoard", CcsSubView)
function CPacakgeZBStuffBoard:ctor()
  CPacakgeZBStuffBoard.super.ctor(self, "views/pzb_view_board2.json")
  self.m_ItemId = nil
  self.m_UpgradeType = nil
  local btnBatchListener = {
    btn_upgrade = {
      listener = handler(self, self.OnBtn_Upgrade),
      variName = "btn_upgrade"
    },
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    },
    btn_saveneed = {
      listener = handler(self, self.OnBtn_SaveNeed),
      variName = "btn_saveneed"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetAttrTips()
  self:setChongzhuSaveNeedFlag(true)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
end
function CPacakgeZBStuffBoard:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinBg"), "rescoin")
end
function CPacakgeZBStuffBoard:setStuffData(itemId, upgradeType)
  self.m_ItemId = itemId
  self.m_UpgradeType = upgradeType
  if self.m_ItemId == nil or self.m_UpgradeType == nil then
    return
  end
  local tempTxtDict = {
    [0] = "",
    [Eqpt_Upgrade_LianhuaType] = "炼化",
    [Eqpt_Upgrade_ChonglianType] = "重铸",
    [Eqpt_Upgrade_QianghuaType] = "强化"
  }
  self.btn_upgrade:setTitleText(tempTxtDict[self.m_UpgradeType])
  self:getNode("upgrade_title"):setText(tempTxtDict[self.m_UpgradeType] .. "装备")
  self:SetUpgradeItemImg()
  self:SetUpgradeTips()
  self:SetUpgradeCost()
  if self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    if self.m_ChongzhuSaveNeedFlag == nil then
      self.m_ChongzhuSaveNeedFlag = true
    end
    self:setChongzhuSaveNeedFlag(self.m_ChongzhuSaveNeedFlag)
  end
end
function CPacakgeZBStuffBoard:SetUpgradeItemImg()
  if self.m_IconList == nil then
    self.m_IconList = {}
  end
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local mainHeroType = mainHero:getTypeId()
  local largeType = itemIns:getType()
  local itemTypeId = itemIns:getTypeId()
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  for i = 1, 6 do
    local tempPos = self:getNode(string.format("itempos%d", i))
    if tempPos then
      tempPos:setVisible(false)
      if tempPos._posNum ~= nil then
        tempPos._posNum:removeFromParent()
        tempPos._posNum = nil
      end
    end
  end
  for _, icon in pairs(self.m_IconList) do
    icon:removeFromParent()
  end
  self.m_IconList = {}
  local tempDict = {
    {
      itemIns:getTypeId(),
      1
    }
  }
  if self.m_UpgradeType == Eqpt_Upgrade_LianhuaType then
    local tList = data_getUpgradeItemList(itemTypeId, lv, Eqpt_Upgrade_LianhuaType)
    for tType, tNum in pairs(tList) do
      tempDict[#tempDict + 1] = {tType, tNum}
    end
  elseif self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    local tList = data_getUpgradeItemList(itemTypeId, lv, Eqpt_Upgrade_ChonglianType)
    for tType, tNum in pairs(tList) do
      tempDict[#tempDict + 1] = {tType, tNum}
    end
  elseif self.m_UpgradeType == Eqpt_Upgrade_QianghuaType then
    local holeNum = itemIns:getProperty(ITME_PRO_EQPT_HOLENUM)
    local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    if holeNum > 0 and holeNum > bsNum then
      local tType = data_getInsertGemType(bsNum + 1)
      local qhf = data_getEnhanceEquipNeedQHF(mainHeroType, tType)
      if qhf ~= nil then
        tempDict[#tempDict + 1] = {qhf, 1}
      end
      tempDict[#tempDict + 1] = {tType, 1}
    end
  end
  for index, data in ipairs(tempDict) do
    local itemTypeId = data[1]
    local itemNeedNum = data[2]
    if index ~= 1 and self.m_UpgradeType == Eqpt_Upgrade_ChonglianType and self.m_ChongzhuSaveNeedFlag == false then
      itemNeedNum = itemNeedNum * 2
    end
    local pos = self:getNode(string.format("itempos%d", index))
    local icon = self:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
    self.m_IconList[#self.m_IconList + 1] = icon
  end
end
function CPacakgeZBStuffBoard:SetUpgradeTips()
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  local largeType = itemIns:getType()
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  if self.m_UpgradeTips ~= nil then
    self.m_UpgradeTips:removeFromParent()
  end
  local tipsW = self:getNode("box_tips"):getContentSize().width
  self.m_UpgradeTips = CRichText.new({
    width = nameW,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  self:addChild(self.m_UpgradeTips)
  if self.m_UpgradeType == Eqpt_Upgrade_LianhuaType then
    local lineNum = 0
    for _, para in ipairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
      local proName = para[1]
      local str = para[2]
      local tempType = para[3]
      local tempNum = itemIns:getProperty(proName)
      local addFlag = "+"
      if tempNum ~= 0 then
        if tempNum < 0 then
          addFlag = "-"
        end
        if tempType == Pro_Value_NUM_TYPE then
          self.m_UpgradeTips:addRichText(string.format("#<CLH>%s %s%d#\n", str, addFlag, math.floor(math.abs(tempNum))))
          lineNum = lineNum + 1
        elseif tempType == Pro_Value_PERCENT_TYPE then
          self.m_UpgradeTips:addRichText(string.format("#<CLH>%s %s%s%%#\n", str, addFlag, Value2Str(math.abs(tempNum) * 100, 1)))
          lineNum = lineNum + 1
        end
      end
    end
    local lvlimit = itemIns:getProperty(ITEM_PRO_EQPT_LH_LVLIMIT)
    if lvlimit ~= 0 then
      self.m_UpgradeTips:addRichText(string.format("#<CLH>装备等级需求 -%d#\n", math.abs(lvlimit)))
      lineNum = lineNum + 1
    end
    local prolimit = itemIns:getProperty(ITEM_PRO_EQPT_LH_PROLIMIT)
    if prolimit ~= 0 then
      self.m_UpgradeTips:addRichText(string.format("#<CLH>装备属性需求 -%d%%#\n", math.abs(prolimit) * 100))
      lineNum = lineNum + 1
    end
    for i = 1, 10 - lineNum do
      self.m_UpgradeTips:addRichText("\n")
    end
    self.m_UpgradeTips:addRichText("#<IRP,CTP>提示:最多可炼化出5个属性#")
  elseif self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    local lineNum = 0
    local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    for _, para in ipairs(ITEM_PRO_SHOW_BASE_DICT) do
      local proName = para[1]
      local str = para[2]
      local tempType = para[3]
      local tempNum = itemIns:getProperty(proName)
      if bsNum > 0 and ZB_PRO_BASE_DICT[proName] == true then
        tempNum = tempNum * (1 + 0.02 * bsNum)
      end
      local addFlag = "+"
      if tempNum ~= 0 then
        if tempNum < 0 then
          addFlag = "-"
        end
        if tempType == Pro_Value_NUM_TYPE then
          self.m_UpgradeTips:addRichText(string.format("#<CBA>%s %s%d#", str, addFlag, math.floor(math.abs(tempNum))))
          lineNum = lineNum + 1
        elseif tempType == Pro_Value_PERCENT_TYPE then
          self.m_UpgradeTips:addRichText(string.format("#<CBA>%s %s%s%%#", str, addFlag, Value2Str(math.abs(tempNum) * 100, 1)))
          lineNum = lineNum + 1
        end
        if g_LocalPlayer:GetItemBaseProValueIsMax(self.m_ItemId, proName) then
          self.m_UpgradeTips:addRichText("#<G>(最高)#\n")
        else
          self.m_UpgradeTips:addRichText("\n")
        end
      end
    end
    for i = 1, 10 - lineNum do
      self.m_UpgradeTips:addRichText("\n")
    end
    if largeType == ITEM_LARGE_TYPE_EQPT then
      self.m_UpgradeTips:addRichText("#<IRP,CTP>提示:此装备不能重铸#")
    end
  elseif self.m_UpgradeType == Eqpt_Upgrade_QianghuaType then
    local holeNum = itemIns:getProperty(ITME_PRO_EQPT_HOLENUM)
    local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    if holeNum < bsNum then
      bsNum = holeNum
    end
    if holeNum <= 0 then
      self.m_UpgradeTips:addRichText("#<IRP,CTP>提示:此装备不能强化#")
    else
      local dict = {}
      dict[#dict + 1] = "#<CQH>强化值#"
      for i = 1, math.min(bsNum, 5) do
        dict[#dict + 1] = "#<IBSB>#"
      end
      for i = 1, math.min(bsNum - 5, 5) do
        dict[#dict + 1] = "#<IBSG>#"
      end
      for i = 1, math.min(bsNum - 10, 5) do
        dict[#dict + 1] = "#<IBSY>#"
      end
      for i = 1, math.min(bsNum - 15, 5) do
        dict[#dict + 1] = "#<IBSR>#"
      end
      for i = 1, math.min(bsNum - 20, 5) do
        dict[#dict + 1] = "#<IBSP>#"
      end
      for i = 1, holeNum - bsNum do
        dict[#dict + 1] = "#<IBSG>#"
      end
      dict[#dict + 1] = "\n"
      local text = table.concat(dict)
      self.m_UpgradeTips:addRichText(text)
      if bsNum > 0 then
        self.m_UpgradeTips:addRichText(string.format("#<CBA>基础属性+%d%%\n\n\n\n\n#", bsNum * 2))
      else
        self.m_UpgradeTips:addRichText([[






]])
      end
      if holeNum <= bsNum then
        self.m_UpgradeTips:addRichText("#<IRP,CTP>提示:已达到最大强化值#")
      else
        local rate = data_getInsertGemRate(bsNum + 1)
        if rate >= 100 then
          self.m_UpgradeTips:addRichText("#<IRP,CTP>提示:本次强化一定成功#")
        else
          self.m_UpgradeTips:addRichText("#<IRP,CTP>提示:本次强化有一定成功率#")
        end
      end
    end
  end
  local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  if eqptType == ITEM_DEF_EQPT_WEAPON_CHIBANG and self.m_UpgradeType ~= Eqpt_Upgrade_LianhuaType then
    self.m_UpgradeTips:addRichText("#<IRP,CTP>提示:翅膀只能炼化#")
  end
  local x, y = self:getNode("box_tips"):getPosition()
  local h = self.m_UpgradeTips:getContentSize().height
  self.m_UpgradeTips:setPosition(ccp(x, y))
end
function CPacakgeZBStuffBoard:SetUpgradeCost()
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  local showLevelFlag = true
  local largeType = itemIns:getType()
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  if self.m_UpgradeType == Eqpt_Upgrade_CreateType then
    showLevelFlag = true
    if largeType == ITEM_LARGE_TYPE_EQPT then
      showLevelFlag = false
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if lv >= ITEM_LARGE_TYPE_SENIOREQPT_MaxLv then
        showLevelFlag = false
      else
        showLevelFlag = true
      end
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      if lv >= ITEM_LARGE_TYPE_XIANQI_MaxLv then
        showLevelFlag = false
      else
        showLevelFlag = true
      end
    end
  else
    showLevelFlag = false
  end
  if showLevelFlag then
    self:getNode("txt_needLevel"):setVisible(true)
    self:getNode("txt_level"):setVisible(true)
    self:getNode("needlvBg"):setVisible(true)
    local shape = itemIns:getTypeId()
    local nextShape = shape + 1
    local roleIns = g_LocalPlayer:getObjById(self.m_RoleId)
    if roleIns ~= nil then
      local zs = roleIns:getProperty(PROPERTY_ZHUANSHENG)
      local lv = roleIns:getProperty(PROPERTY_ROLELEVEL)
      local nextLv = data_getItemLvLimit(nextShape)
      local nextZs = data_getItemZsLimit(nextShape)
      if nextZs == 0 then
        self:getNode("txt_level"):setText(string.format("%d级", nextLv))
      else
        self:getNode("txt_level"):setText(string.format("%d转%d级", nextZs, nextLv))
      end
      if zs < nextZs or nextZs == zs and lv < nextLv then
        self:getNode("txt_level"):setColor(ccc3(255, 0, 0))
      else
        self:getNode("txt_level"):setColor(ccc3(255, 255, 255))
      end
    end
  else
    self:getNode("txt_needLevel"):setVisible(false)
    self:getNode("txt_level"):setVisible(false)
    self:getNode("needlvBg"):setVisible(false)
  end
  local itemNeedText = {
    [ITEM_DEF_EQPT_PROTYPE_LingXing] = "灵性要求",
    [ITEM_DEF_EQPT_PROTYPE_LiLiang] = "力量要求",
    [ITEM_DEF_EQPT_PROTYPE_Gengu] = "根骨要求",
    [ITEM_DEF_EQPT_PROTYPE_MinJie] = "敏捷要求",
    [ITEM_DEF_EQPT_PROTYPE_Qixue_N] = "加强气血",
    [ITEM_DEF_EQPT_PROTYPE_Speed_N] = "加倍道兼行度",
    [ITEM_DEF_EQPT_PROTYPE_Wuli_N] = "加强物理",
    [ITEM_DEF_EQPT_PROTYPE_AddSpeed_S] = "加倍道兼行度",
    [ITEM_DEF_EQPT_PROTYPE_SubSpeed_S] = "加强负速度"
  }
  local tempProType = itemIns:getProperty(ITEM_PRO_EQPT_PROTYPE)
  local tempText = itemNeedText[tempProType] or ""
  self:getNode("txt_saveneed"):setText(string.format("保留%s", tempText))
  local showChongZhuSaveFlag = true
  if self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    local largeType = itemIns:getType()
    local midType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
    showChongZhuSaveFlag = true
    if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if midType == ITEM_DEF_EQPT_WEAPON_XIEZI then
        showChongZhuSaveFlag = false
      elseif midType == ITEM_DEF_EQPT_WEAPON_XIANGLIAN then
        showChongZhuSaveFlag = false
      end
    elseif largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      showChongZhuSaveFlag = false
    end
  else
    showChongZhuSaveFlag = false
  end
  if showChongZhuSaveFlag then
    self:getNode("txt_saveneed"):setVisible(true)
    self.btn_saveneed:setEnabled(true)
  else
    self:getNode("txt_saveneed"):setVisible(false)
    self.btn_saveneed:setEnabled(false)
  end
  if self.m_MoneyIcon == nil then
    local x, y = self:getNode("box_coin"):getPosition()
    local z = self:getNode("box_coin"):getZOrder()
    local size = self:getNode("box_coin"):getSize()
    self:getNode("box_coin"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_MoneyIcon = tempImg
  end
  local showMoneyFlag = true
  local needMoney = 0
  local largeType = itemIns:getType()
  local itemTypeId = itemIns:getTypeId()
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  if self.m_UpgradeType == Eqpt_Upgrade_LianhuaType then
    needMoney = data_getUpgradeItemMoney(itemTypeId, lv, Eqpt_Upgrade_LianhuaType)
  elseif self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    if largeType == ITEM_LARGE_TYPE_EQPT then
      showMoneyFlag = false
    else
      needMoney = data_getUpgradeItemMoney(itemTypeId, lv, Eqpt_Upgrade_ChonglianType)
    end
  elseif self.m_UpgradeType == Eqpt_Upgrade_QianghuaType then
    local holeNum = itemIns:getProperty(ITME_PRO_EQPT_HOLENUM)
    local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    if holeNum <= 0 then
      showMoneyFlag = false
    elseif holeNum <= bsNum then
      showMoneyFlag = false
    else
      needMoney = data_getInsertGemMoney(bsNum + 1)
    end
  else
    showMoneyFlag = false
  end
  local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  if eqptType == ITEM_DEF_EQPT_WEAPON_CHIBANG and self.m_UpgradeType ~= Eqpt_Upgrade_LianhuaType then
    showMoneyFlag = false
  end
  if showChongZhuSaveFlag and self.m_ChongzhuSaveNeedFlag == false then
    needMoney = needMoney * 2
  end
  self:getNode("txt_coin"):setText(string.format("%d", needMoney))
  if needMoney > g_LocalPlayer:getCoin() then
    self:getNode("txt_coin"):setColor(VIEW_DEF_WARNING_COLOR)
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  end
  self:getNode("txt_coin"):setEnabled(showMoneyFlag)
  self:getNode("txt_cost"):setEnabled(showMoneyFlag)
  self:getNode("coinBg"):setEnabled(showMoneyFlag)
  if self.m_MoneyIcon then
    self.m_MoneyIcon:setVisible(showMoneyFlag)
  end
  self.btn_upgrade:setEnabled(showMoneyFlag)
  self.btn_upgrade:setTouchEnabled(showMoneyFlag)
end
function CPacakgeZBStuffBoard:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
  local s = pos:getContentSize()
  local clickListener = handler(self, self.ShowStuffDetail)
  if index == 1 then
    function clickListener()
    end
  end
  icon = createClickItem({
    itemID = itemTypeId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = clickListener,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = true
  })
  local size = icon:getContentSize()
  icon:setPosition(ccp(-size.width / 2, -size.height / 2))
  pos:addChild(icon)
  icon.eqptupgradeItemTypePara = itemTypeId
  icon.eqptupgradeItemNeedNumPara = itemNeedNum or 1
  icon.eqptupgradeItemPosPara = index
  pos:setVisible(true)
  if index ~= 1 then
    local curNum = g_LocalPlayer:GetItemNum(itemTypeId)
    local numLabel = CCLabelTTF:create(string.format("%s/%s", curNum, itemNeedNum), ITEM_NUM_FONT, 22)
    local size = icon:getContentSize()
    numLabel:setAnchorPoint(ccp(1, 0))
    numLabel:setPosition(ccp(s.width / 2 - 5, -s.height / 2 + 5))
    if itemNeedNum <= curNum then
      numLabel:setColor(VIEW_DEF_PGREEN_COLOR)
    else
      numLabel:setColor(VIEW_DEF_WARNING_COLOR)
    end
    pos:addNode(numLabel)
    AutoLimitObjSize(numLabel, 70)
    pos._posNum = numLabel
  end
  return icon
end
function CPacakgeZBStuffBoard:ShowStuffDetail(obj, t)
  self.m_PopStuffDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseStuffDetail),
    itemType = obj.eqptupgradeItemTypePara
  })
  self:addSubView({
    subView = self.m_PopStuffDetail,
    zOrder = 9999
  })
  self:SelectStuffItem(obj.eqptupgradeItemPosPara)
  local x, y = self:getNode("bg2"):getPosition()
  local iSize = self:getNode("bg2"):getContentSize()
  local bSize = self.m_PopStuffDetail:getBoxSize()
  self.m_PopStuffDetail:setPosition(ccp(x - iSize.width * 3 / 2, y - bSize.height / 2))
  self.m_PopStuffDetail:ShowCloseBtn()
end
function CPacakgeZBStuffBoard:SelectStuffItem(index)
  local selectImgTag = 9999
  for i = 1, 6 do
    local obj = self:getNode(string.format("itempos%d", i))
    if obj ~= nil then
      local oldImg = obj:getVirtualRenderer():getChildByTag(selectImgTag)
      if i == index then
        if oldImg == nil then
          local img = display.newSprite("xiyou/item/selecteditem.png")
          obj:getVirtualRenderer():addChild(img, 10, selectImgTag)
          local size = obj:getContentSize()
          img:setPosition(ccp(size.width / 2, size.height / 2))
        end
      elseif oldImg ~= nil then
        obj:getVirtualRenderer():removeChild(oldImg)
      end
    end
  end
end
function CPacakgeZBStuffBoard:setChongzhuSaveNeedFlag(flag)
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns ~= nil and self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    local largeType = itemIns:getType()
    local midType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
    if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      if midType == ITEM_DEF_EQPT_WEAPON_XIEZI then
        flag = true
      elseif midType == ITEM_DEF_EQPT_WEAPON_XIANGLIAN then
        flag = true
      end
    end
  end
  self.m_ChongzhuSaveNeedFlag = flag
  local btn = self.btn_saveneed
  if btn then
    if flag == true then
      if btn._SelectFlag then
        btn._SelectFlag:setVisible(true)
      else
        local tempSprite = display.newSprite("views/common/btn/selected.png")
        tempSprite:setAnchorPoint(ccp(0.3, 0.3))
        btn:addNode(tempSprite, 1)
        btn._SelectFlag = tempSprite
      end
    elseif btn._SelectFlag then
      btn._SelectFlag:setVisible(false)
    end
  end
  self:SetUpgradeItemImg()
  self:SetUpgradeCost()
end
function CPacakgeZBStuffBoard:CloseStuffDetail()
  if self.m_PopStuffDetail then
    self:SelectStuffItem()
    local tempObj = self.m_PopStuffDetail
    self.m_PopStuffDetail = nil
    tempObj:CloseSelf()
  end
end
function CPacakgeZBStuffBoard:OnBtn_Upgrade(btnObj, touchType)
  if self.m_ItemId == nil then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns == nil then
    return
  end
  if self.m_UpgradeType == nil then
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local mainHeroType = mainHero:getTypeId()
  local largeType = itemIns:getType()
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  if self.m_UpgradeType == Eqpt_Upgrade_LianhuaType then
    ShowLianhuaZhuangBeiView({
      itemId = self.m_ItemId
    })
    if g_PackageZBView then
      g_PackageZBView:CloseSelf()
    end
  elseif self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    if largeType == ITEM_LARGE_TYPE_EQPT then
      ShowNotifyTips("普通装备不能重铸")
      return
    elseif self.m_ChongzhuSaveNeedFlag then
      netsend.netitem.requestChongzhuItem(self.m_ItemId, nil, 1)
    else
      netsend.netitem.requestChongzhuItem(self.m_ItemId, nil, 0)
    end
  elseif self.m_UpgradeType == Eqpt_Upgrade_QianghuaType then
    local holeNum = itemIns:getProperty(ITME_PRO_EQPT_HOLENUM)
    local bsNum = itemIns:getProperty(ITME_PRO_EQPT_BAOSHINUM)
    if holeNum <= 0 then
      ShowNotifyTips("装备没有宝石孔,不能强化")
      return
    elseif holeNum <= bsNum then
      ShowNotifyTips("装备宝石孔已经满,不能强化")
      return
    else
      netsend.netitem.requestQianghuaItem(self.m_ItemId)
    end
  end
  self.m_ItemId = nil
end
function CPacakgeZBStuffBoard:OnBtn_Help(btnObj, touchType)
  local title, text
  if self.m_UpgradeType == Eqpt_Upgrade_LianhuaType then
    title = "炼化装备的说明"
    text = "炼化可赋予装备额外属性(绿字显示)，炼化时需要消耗灵珠；越高级的装备炼化的价值越大：普通装备<高级装备<仙器。"
  elseif self.m_UpgradeType == Eqpt_Upgrade_ChonglianType then
    title = "重铸装备的说明"
    text = "重铸时装备部位不变，重铸后将保留原装备的炼化属性和强化值；重铸后属性及数值重新随机。要是不勾选【保留属性要求】则会重铸出随机属性要求的装备，例如:要求力量的装备有可能重铸成要求敏捷。"
  elseif self.m_UpgradeType == Eqpt_Upgrade_QianghuaType then
    title = "强化装备的说明"
    text = "每成功镶嵌一颗宝石可增加装备基础属性的#<G,>2%#。蓝宝石可镶嵌1-5格，绿宝石可镶嵌6-10格，黄宝石可镶嵌11-15格，红宝石可镶嵌16-20格；镶嵌成功后强化值#<G,>+1#。主角的种族和性别决定了需要的对应强化符(如人族男性主角,无论强化任何一件装备都需要#<G,>蓝/绿/黄/红色 强化符(男人)#),忽视抗物理程度属性数值将不会受到强化值的加成。"
  end
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
function CPacakgeZBStuffBoard:OnBtn_SaveNeed(btnObj, touchType)
  if self.m_ChongzhuSaveNeedFlag == true then
    self:setChongzhuSaveNeedFlag(false)
  else
    self:setChongzhuSaveNeedFlag(true)
  end
end
function CPacakgeZBStuffBoard:SetUpgradeAction()
  local plistpath = "xiyou/ani/zhuangbeiupgrade.plist"
  local times = 1
  local eff = CreateSeqAnimation(plistpath, times, nil, nil, false)
  if eff then
    local x, y = self:getNode("itempos1"):getPosition()
    eff:setPosition(ccp(x, y))
    self:addNode(eff, 999)
  end
end
function CPacakgeZBStuffBoard:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:SetUpgradeCost()
  elseif msgSID == MsgID_ItemInfo_AddItem then
    self:SetUpgradeItemImg()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    self:SetUpgradeItemImg()
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    self:SetUpgradeItemImg()
  elseif msgSID == MsgID_ItemSource_Jump then
    self:CloseStuffDetail()
  end
end
function CPacakgeZBStuffBoard:Clear()
  print("CPacakgeZBStuffBoard:Clear")
  self:CloseStuffDetail()
end

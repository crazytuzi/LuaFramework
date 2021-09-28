function ShowUseLifeItem(lifeItemType)
  getCurSceneView():addSubView({
    subView = CUseLifeItemView.new(lifeItemType),
    zOrder = MainUISceneZOrder.menuView
  })
end
CUseLifeItemView = class("CUseLifeItemView", CcsSubView)
function CUseLifeItemView:ctor(lifeItemType)
  self.m_LifeItemType = lifeItemType
  CUseLifeItemView.super.ctor(self, "views/uselifeitem.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_makeitem = {
      listener = handler(self, self.OnBtn_MakeItem),
      variName = "btn_makeitem"
    },
    btn_buyitem = {
      listener = handler(self, self.OnBtn_BuyItem),
      variName = "btn_buyitem"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetData()
  self:SetPackage()
end
function CUseLifeItemView:SetData()
  local path = "views/lifeskill/lifeskill_wine.png"
  if self.m_LifeItemType == IETM_DEF_LIFESKILL_WINE then
    path = "views/lifeskill/lifeskill_wine.png"
    self:getNode("txt_title"):setText("使用酒")
    self:getNode("btn_makeitem_txt"):setText("生活技能--烹饪")
    self:getNode("btn_buyitem_txt"):setText("铜钱货摊")
  elseif self.m_LifeItemType == IETM_DEF_LIFESKILL_FUWEN then
    path = "views/lifeskill/lifeskill_fw.png"
    self:getNode("txt_title"):setText("使用符文")
    self:getNode("btn_makeitem_txt"):setText("生活技能--制符")
    self:getNode("btn_buyitem_txt"):setText("铜钱货摊")
  end
  self.m_LifeSkillTempImg = display.newSprite(path)
  self:addNode(self.m_LifeSkillTempImg)
  local x, y = self:getNode("box_icon"):getPosition()
  local size = self:getNode("box_icon"):getContentSize()
  self.m_LifeSkillTempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
end
function CUseLifeItemView:SetPackage()
  self.layer_itemlist = self:getNode("layer_itemlist")
  self.layer_itemlist:setVisible(false)
  local x, y = self.layer_itemlist:getPosition()
  local z = self.layer_itemlist:getZOrder()
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(90, 94),
    pageLines = 3,
    oneLineNum = 3,
    pageIconOffY = -10
  }
  local function tempSelectFunc(itemObj)
    local itemType = itemObj:getTypeId()
    if self.m_LifeItemType == IETM_DEF_LIFESKILL_WINE and (itemType == ITEM_DEF_OTHER_CHONGYANGGAO or itemType == ITEM_DEF_OTHER_JUHUAJIU) then
      return true
    end
    if GetItemTypeByItemTypeId(itemType) ~= ITEM_LARGE_TYPE_LIFEITEM then
      return false
    end
    if data_getLifeSkillType(itemType) ~= self.m_LifeItemType then
      return false
    end
    return true
  end
  self.m_PackageFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_LIFEITEM, function(itemObjId)
    if self then
      self:UseItem(itemObjId)
    end
  end, nil, param, tempSelectFunc)
  self.m_PackageFrame:setPosition(ccp(x, y - 60))
  self:addChild(self.m_PackageFrame, z + 100)
end
function CUseLifeItemView:UseItem(itemObjId)
  self:CloseEquipDetail()
  local midPos = self:getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  if packageItemIns == nil then
    return
  end
  self.m_EquipDetail = CEquipDetail.new(itemObjId, {
    rightBtn = {
      btnText = "使用",
      listener = handler(self, self.OnUseItem)
    },
    closeListener = handler(self, self.CloseEquipDetail),
    fromPackageFlag = true,
    enableTouchDetect = false,
    opacityBg = 0
  })
  getCurSceneView():addSubView({
    subView = self.m_EquipDetail,
    zOrder = MainUISceneZOrder.menuView
  })
  local pos = self:getUINode():convertToWorldSpace(ccp(0, 0))
  pos = getCurSceneView():convertToNodeSpace(ccp(pos.x, pos.y))
  pos.y = pos.y + 115
  self.m_EquipDetail:setPosition(pos)
end
function CUseLifeItemView:OnUseItem(itemId)
  netsend.netitem.requestUseItem(itemId)
  self:CloseEquipDetail()
end
function CUseLifeItemView:CloseEquipDetail()
  if self.m_EquipDetail then
    self.m_EquipDetail:CloseSelf()
  end
end
function CUseLifeItemView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CUseLifeItemView:OnBtn_MakeItem(obj, t)
  local curLifeSkillID, _ = g_LocalPlayer:getBaseLifeSkill()
  if self.m_LifeItemType == IETM_DEF_LIFESKILL_WINE then
    if curLifeSkillID == LIFESKILL_MAKEFOOD then
      ShowMakeLifeItem(curLifeSkillID)
    else
      ShowNotifyTips("没有学会烹饪")
    end
    return
  elseif self.m_LifeItemType == IETM_DEF_LIFESKILL_FUWEN then
    if curLifeSkillID == LIFESKILL_MAKEFU then
      ShowMakeLifeItem(curLifeSkillID)
    else
      ShowNotifyTips("没有学会制符")
    end
    return
  end
end
function CUseLifeItemView:OnBtn_BuyItem(obj, t)
  if self.m_LifeItemType == IETM_DEF_LIFESKILL_FUWEN then
    enterMarket({
      initViewType = MarketShow_InitShow_CoinView,
      initBaitanType = BaitanShow_InitShow_ShoppingView,
      initBaitanMainType = 5,
      initBaitanSubType = 1
    })
  elseif self.m_LifeItemType == IETM_DEF_LIFESKILL_WINE then
    enterMarket({
      initViewType = MarketShow_InitShow_CoinView,
      initBaitanType = BaitanShow_InitShow_ShoppingView,
      initBaitanMainType = 6,
      initBaitanSubType = 2
    })
  end
end
function CUseLifeItemView:Clear()
  self:CloseEquipDetail()
end

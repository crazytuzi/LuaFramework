local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TurnedCardDecomposePanel = Lplus.Extend(ECPanelBase, "TurnedCardDecomposePanel")
local ItemData = require("Main.Item.ItemData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local QualityEnum = require("consts.mzm.gsp.changemodelcard.confbean.QualityEnum")
local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
local def = TurnedCardDecomposePanel.define
local TabId = {TurnedCard = 1, TurnedCardBag = 2}
local TabDefines = {
  [TabId.TurnedCard] = {tabName = "Btn_MyCard"},
  [TabId.TurnedCardBag] = {
    tabName = "Btn_CardBag"
  }
}
local instance
def.field("number").curSelectedTabId = TabId.TurnedCard
def.field("table").curCardList = nil
def.field("table").decomposeCardList = nil
def.field("number").curPoint = 0
def.field("table").decomposeCardItemList = nil
def.const("number").minGridNum = 20
def.const("table").TabId = TabId
def.static("=>", TurnedCardDecomposePanel).Instance = function()
  if instance == nil then
    instance = TurnedCardDecomposePanel()
  end
  return instance
end
def.method("number").ShowPanelByTabId = function(self, tabId)
  self.curSelectedTabId = tabId
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SHAPESHIFT_Resolve, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:initUI()
  else
    self.curCardList = nil
    self.decomposeCardList = nil
    self.curPoint = 0
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Decompose_Turned_Card_Success, TurnedCardDecomposePanel.OnDecomposeSuccess)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Decompose_Turned_Card_Item_Success, TurnedCardDecomposePanel.OnDecomposeSuccess)
end
def.override().OnDestroy = function(self)
  self.curSelectedTabId = TabId.TurnedCard
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Decompose_Turned_Card_Success, TurnedCardDecomposePanel.OnDecomposeSuccess)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Decompose_Turned_Card_Item_Success, TurnedCardDecomposePanel.OnDecomposeSuccess)
end
def.static("table", "table").OnDecomposeSuccess = function(p1, p2)
  if instance and instance:IsShow() then
    instance.decomposeCardList = {}
    instance:setLeftCardList()
    instance.curPoint = 0
    instance:setPoint()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------TurnedCardDecomposePanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_MyCard" then
    self.curSelectedTabId = TabId.TurnedCard
    self:setSelectedList()
    self:resetPositionCardList()
  elseif id == "Btn_CardBag" then
    self.curSelectedTabId = TabId.TurnedCardBag
    self:setSelectedList()
    self:resetPositionCardList()
  elseif id == "Img_Card" then
    if self.curSelectedTabId == TabId.TurnedCard then
      for i, v in pairs(self.curCardList) do
        local cfgId = v:getCardCfgId()
        local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
        if cardCfg and cardCfg.quality >= QualityEnum.B then
          self:addDecomposeInfo(i)
        end
      end
    end
  elseif id == "Btn_Confirm" then
    self:confirmDecompose()
  elseif strs[1] == "Img" and strs[2] == "Cancel" then
    local idx = tonumber(strs[3])
    if idx then
      self:removeDecomposeInfo(idx)
    end
  elseif strs[1] == "Item" and strs[2] == "Bag" then
    local idx = tonumber(strs[3])
    if idx then
      local info = self.curCardList[idx]
      if info == nil then
        return
      end
      local itemId
      self:showTips(info, true)
    end
  elseif strs[1] == "Item" then
    local idx = tonumber(strs[2])
    if idx then
      local decomposeList = self.decomposeCardList[self.curSelectedTabId] or {}
      local info = decomposeList[idx]
      if info then
        self:showTips(info.info, false)
      end
    end
  end
end
def.method("table", "boolean").showTips = function(self, info, isRight)
  if info == nil then
    return
  end
  local itemId
  if self.curSelectedTabId == TabId.TurnedCardBag then
    itemId = info.id
  else
    local level = info:getCardLevel()
    local cfgId = info:getCardCfgId()
    local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(cfgId)
    if cardLevelCfg then
      local curLevelCfg = cardLevelCfg.cardLevels[level]
      if curLevelCfg then
        itemId = curLevelCfg.unlockItemId
      end
    end
  end
  if itemId then
    local obj
    if isRight then
      obj = self.m_panel:FindDirect("Img_Bg/Group_Right/Img_Right")
    else
      obj = self.m_panel:FindDirect("Img_Bg/Group_Left/Img_Left")
    end
    local position = obj:get_position()
    local sprite = obj:GetComponent("UISprite")
    local screenPos = WorldPosToScreen(position.x, position.y)
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height() / 2 - 200, 0, false)
  end
end
def.method("string").onDoubleClick = function(self, id)
  warn("-----TurnedCardDecomposePanel onDoubleClick:", id)
  local strs = string.split(id, "_")
  if strs[1] == "Item" and strs[2] == "Bag" then
    local idx = tonumber(strs[3])
    if idx then
      self:addDecomposeInfo(idx)
    end
  elseif strs[1] == "Item" then
    local idx = tonumber(strs[2])
    if idx then
      self:removeDecomposeInfo(idx)
    end
  end
end
def.method().confirmDecompose = function(self)
  local decomposeList = self.decomposeCardList[self.curSelectedTabId] or {}
  if decomposeList == nil or #decomposeList == 0 then
    Toast(textRes.TurnedCard[14])
    return
  end
  local uuids = {}
  local isBag = self.curSelectedTabId == TabId.TurnedCardBag
  local isOwnPurple = false
  local PurpleLv = TurnedCardUtils.PurpleLevel
  for i, v in pairs(decomposeList) do
    local info = v.info
    if isBag then
      table.insert(uuids, info.uuid[1])
      if not isOwnPurple and TurnedCardUtils.IsPurpleCardItem(info.id) then
        isOwnPurple = true
      end
    else
      if not isOwnPurple then
        local cardLv = info:getCardLevel()
        if PurpleLv <= cardLv then
          isOwnPurple = true
        end
      end
      table.insert(uuids, info:getUUID())
    end
  end
  local function callback(id)
    if id == 1 then
      if isBag then
        local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardItemDecomposeReq").new(uuids, 0)
        gmodule.network.sendProtocol(p)
        warn("--------CCardItemDecomposeReq:", #uuids)
      else
        local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardDecomposeReq").new(uuids)
        gmodule.network.sendProtocol(p)
        warn("--------CCardDecomposeReq:", #uuids)
      end
    end
  end
  if isOwnPurple then
    CaptchaConfirmDlg.ShowConfirm(textRes.TurnedCard[32], "", textRes.TurnedCard[33], nil, callback, nil)
  else
    callback(1)
  end
end
def.method("number").addDecomposeInfo = function(self, idx)
  local info = self.curCardList[idx]
  if info then
    local t = {idx = idx, info = info}
    local decomposeList = self.decomposeCardList[self.curSelectedTabId] or {}
    table.insert(decomposeList, t)
    self.decomposeCardList[self.curSelectedTabId] = decomposeList
    self.curCardList[idx] = nil
    self:doubleClickRefresh(t, true)
  end
end
def.method("number").removeDecomposeInfo = function(self, idx)
  local decomposeList = self.decomposeCardList[self.curSelectedTabId] or {}
  local info = decomposeList[idx]
  if info then
    self.curCardList[info.idx] = info.info
    local decomposeList = self.decomposeCardList[self.curSelectedTabId] or {}
    table.remove(decomposeList, idx)
    self.decomposeCardList[self.curSelectedTabId] = decomposeList
    self:doubleClickRefresh(info, false)
  end
end
def.method("table", "boolean").doubleClickRefresh = function(self, info, isAdd)
  local idx = info.idx
  local List_Item = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Move/Scroll View_Item/List_Item")
  local Item_Bag = List_Item:FindDirect("Item_Bag_" .. idx)
  if self.curSelectedTabId == TabId.TurnedCardBag then
    self:setRightCardItemInfo(Item_Bag, idx)
  else
    self:setRightCardInfo(Item_Bag, idx)
  end
  local socre = 0
  local isBag = self.curSelectedTabId == TabId.TurnedCardBag
  if isBag then
    local itemInfo = info.info
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    if itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM then
      local cfg = TurnedCardUtils.GetChangeModelCardItemCfg(itemInfo.id)
      socre = cfg.sellScore * itemInfo.number
    elseif itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT then
      local cfg = TurnedCardUtils.GetChangeModelCardFragmentCfg(itemInfo.id)
      socre = cfg.sellScore * itemInfo.number
    end
  else
    local card = info.info
    local cfgId = card:getCardCfgId()
    local level = card:getCardLevel()
    local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(cfgId)
    local levelCfg = cardLevelCfg.cardLevels[level]
    if levelCfg then
      socre = levelCfg.sellScore
    end
  end
  if isAdd then
    self.curPoint = self.curPoint + socre
  else
    self.curPoint = self.curPoint - socre
  end
  self:setPoint()
  self:setLeftCardList()
end
def.method().initUI = function(self)
  self.decomposeCardList = {}
  self.curPoint = 0
  local Group_Btn = self.m_panel:FindDirect("Img_Bg/Group_Btn")
  for i, v in pairs(TabDefines) do
    local tab = Group_Btn:FindDirect(v.tabName)
    local toggle = tab:GetComponent("UIToggle")
    if i == self.curSelectedTabId then
      toggle.value = true
    else
      toggle.value = false
    end
  end
  self:setPoint()
  self:setSelectedList()
end
def.method().setPoint = function(self)
  local Label_Points = self.m_panel:FindDirect("Img_Bg/Group_Label/Label_Points")
  Label_Points:GetComponent("UILabel"):set_text(self.curPoint)
end
def.method().setSelectedList = function(self)
  local list = {}
  self.curPoint = 0
  self:setPoint()
  local Img_Card = self.m_panel:FindDirect("Img_Bg/Img_Card")
  if self.curSelectedTabId == TabId.TurnedCard then
    list = TurnedCardInterface.Instance():getTurnedCardList(0)
    Img_Card:SetActive(true)
  elseif self.curSelectedTabId == TabId.TurnedCardBag then
    Img_Card:SetActive(false)
    local items = ItemData.Instance():GetBag(ItemModule.CHANGE_MODEL_CARD_BAG)
    for i, v in pairs(items) do
      table.insert(list, v)
    end
  else
    warn("!!!!!no exit curSelectedTabId:", self.curSelectedTabId)
  end
  self.curCardList = list
  self:setRightCardList()
  local decomposeList = self.decomposeCardList[self.curSelectedTabId]
  self.decomposeCardList[self.curSelectedTabId] = {}
  self:setLeftCardList()
  if decomposeList then
    for i, v in ipairs(decomposeList) do
      self:addDecomposeInfo(v.idx)
    end
  end
  self:setLeftCardList()
end
def.method().resetPositionCardList = function(self)
  local Scrollview = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Move/Scroll View_Item")
  GameUtil.AddGlobalTimer(0, true, function()
    if _G.IsNil(self.m_panel) then
      return
    end
    Scrollview:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().setRightCardList = function(self)
  local List_Item = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Move/Scroll View_Item/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local num = TurnedCardDecomposePanel.minGridNum
  if num < #self.curCardList then
    num = #self.curCardList
  end
  uiList.itemCount = num
  uiList:Resize()
  local isBag = self.curSelectedTabId == TabId.TurnedCardBag
  for i = 1, num do
    local Item_Bag = List_Item:FindDirect("Item_Bag_" .. i)
    if isBag then
      self:setRightCardItemInfo(Item_Bag, i)
    else
      self:setRightCardInfo(Item_Bag, i)
    end
  end
end
def.method().setLeftCardList = function(self)
  local List_Item = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Move/Scroll View_Item/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local num = TurnedCardDecomposePanel.minGridNum
  local decomposeList = self.decomposeCardList[self.curSelectedTabId]
  if decomposeList and num < #decomposeList then
    num = #decomposeList
  end
  uiList.itemCount = num
  uiList:Resize()
  local isBag = self.curSelectedTabId == TabId.TurnedCardBag
  for i = 1, num do
    local Item = List_Item:FindDirect("Item_" .. i)
    if isBag then
      self:setLeftCardItemInfo(Item, i)
    else
      self:setLeftCardInfo(Item, i)
    end
  end
end
def.method("userdata", "number").clearRightIcon = function(self, obj, idx)
  local Img_Bg = obj:FindDirect("Img_Bg_" .. idx)
  local Img_Icon = obj:FindDirect("Img_Icon_" .. idx)
  local Img_Tpye = obj:FindDirect("Img_Tpye_" .. idx)
  local Label_Num = obj:FindDirect("Label_Num_" .. idx)
  local Img_Cancel = obj:FindDirect("Img_Cancel_" .. idx)
  Img_Bg:GetComponent("UISprite"):set_spriteName(TurnedCardUtils.TurnedCardLevelFrame[0])
  Img_Icon:SetActive(false)
  Img_Tpye:SetActive(false)
  Label_Num:GetComponent("UILabel"):set_text("")
  if Img_Cancel then
    Img_Cancel:SetActive(false)
  end
end
def.method("userdata", "number").setRightCardInfo = function(self, obj, idx)
  local card = self.curCardList[idx]
  if card then
    local Img_Bg = obj:FindDirect("Img_Bg_" .. idx)
    local Img_Icon = obj:FindDirect("Img_Icon_" .. idx)
    local Img_Tpye = obj:FindDirect("Img_Tpye_" .. idx)
    local Label_Num = obj:FindDirect("Label_Num_" .. idx)
    local cfgId = card:getCardCfgId()
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
    local level = card:getCardLevel()
    Img_Icon:SetActive(true)
    Img_Tpye:SetActive(true)
    Img_Bg:GetComponent("UISprite"):set_spriteName(TurnedCardUtils.TurnedCardLevelFrame[level])
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), cardCfg.iconId)
    local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
    GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
    Label_Num:GetComponent("UILabel"):set_text("")
  else
    self:clearRightIcon(obj, idx)
  end
end
def.method("userdata", "number").setRightCardItemInfo = function(self, obj, idx)
  local itemInfo = self.curCardList[idx]
  if itemInfo then
    local Img_Bg = obj:FindDirect("Img_Bg_" .. idx)
    local Img_Icon = obj:FindDirect("Img_Icon_" .. idx)
    local Img_Tpye = obj:FindDirect("Img_Tpye_" .. idx)
    local Label_Num = obj:FindDirect("Label_Num_" .. idx)
    Img_Icon:SetActive(true)
    Img_Tpye:SetActive(false)
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), itemBase.icon)
    GUIUtils.SetSprite(Img_Bg, ItemUtils.GetItemFrame(itemInfo, itemBase))
    if itemInfo.number > 1 then
      Label_Num:GetComponent("UILabel"):set_text(itemInfo.number)
    else
      Label_Num:GetComponent("UILabel"):set_text("")
    end
  else
    self:clearRightIcon(obj, idx)
  end
end
def.method("userdata", "number").setLeftCardInfo = function(self, obj, idx)
  local decomposeList = self.decomposeCardList[self.curSelectedTabId] or {}
  local info = decomposeList[idx]
  if info then
    local card = info.info
    local Img_Bg = obj:FindDirect("Img_Bg_" .. idx)
    local Img_Icon = obj:FindDirect("Img_Icon_" .. idx)
    local Img_Tpye = obj:FindDirect("Img_Tpye_" .. idx)
    local Label_Num = obj:FindDirect("Label_Num_" .. idx)
    local Img_Cancel = obj:FindDirect("Img_Cancel_" .. idx)
    Img_Cancel:SetActive(true)
    local cfgId = card:getCardCfgId()
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
    local level = card:getCardLevel()
    Img_Icon:SetActive(true)
    Img_Tpye:SetActive(true)
    Img_Bg:GetComponent("UISprite"):set_spriteName(TurnedCardUtils.TurnedCardLevelFrame[level])
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), cardCfg.iconId)
    local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
    GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
    Label_Num:GetComponent("UILabel"):set_text("")
  else
    self:clearRightIcon(obj, idx)
  end
end
def.method("userdata", "number").setLeftCardItemInfo = function(self, obj, idx)
  local decomposeList = self.decomposeCardList[self.curSelectedTabId] or {}
  local info = decomposeList[idx]
  if info then
    local itemInfo = info.info
    local Img_Bg = obj:FindDirect("Img_Bg_" .. idx)
    local Img_Icon = obj:FindDirect("Img_Icon_" .. idx)
    local Img_Tpye = obj:FindDirect("Img_Tpye_" .. idx)
    local Label_Num = obj:FindDirect("Label_Num_" .. idx)
    local Img_Cancel = obj:FindDirect("Img_Cancel_" .. idx)
    Img_Cancel:SetActive(true)
    Img_Icon:SetActive(true)
    Img_Tpye:SetActive(false)
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), itemBase.icon)
    GUIUtils.SetSprite(Img_Bg, ItemUtils.GetItemFrame(itemInfo, itemBase))
    if itemInfo.number > 1 then
      Label_Num:GetComponent("UILabel"):set_text(itemInfo.number)
    else
      Label_Num:GetComponent("UILabel"):set_text("")
    end
  else
    self:clearRightIcon(obj, idx)
  end
end
TurnedCardDecomposePanel.Commit()
return TurnedCardDecomposePanel

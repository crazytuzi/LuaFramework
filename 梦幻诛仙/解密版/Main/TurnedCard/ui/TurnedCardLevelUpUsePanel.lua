local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TurnedCardLevelUpUsePanel = Lplus.Extend(ECPanelBase, "TurnedCardLevelUpUsePanel")
local ItemData = require("Main.Item.ItemData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local TurnedCard = require("Main.TurnedCard.TurnedCard")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = TurnedCardLevelUpUsePanel.define
local instance
def.field("userdata").curUUID = nil
def.field("table").infoList = nil
def.field("number").selectedIdx = 0
def.field("number").useNum = 0
def.static("=>", TurnedCardLevelUpUsePanel).Instance = function()
  if instance == nil then
    instance = TurnedCardLevelUpUsePanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, uuid)
  if self:IsShow() then
    return
  end
  self.curUUID = uuid
  self:CreatePanel(RESPATH.PANEL_QUICKUSE, 2)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:initUI()
  else
    self.useNum = 0
    self.infoList = nil
    self.selectedIdx = 0
    self.curUUID = nil
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TurnedCardLevelUpUsePanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Remove_Turned_Card, TurnedCardLevelUpUsePanel.OnRemoveTurnedCard)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TurnedCardLevelUpUsePanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Remove_Turned_Card, TurnedCardLevelUpUsePanel.OnRemoveTurnedCard)
end
def.static("table", "table").OnRemoveTurnedCard = function(p1, p2)
  if instance and instance:IsShow() then
    instance:refreshList()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance and instance:IsShow() and p1.bagId == ItemModule.CHANGE_MODEL_CARD_BAG then
    instance:refreshList()
  end
end
def.method().refreshList = function(self)
  self:setCanUseList()
  local info = self.infoList[self.selectedIdx]
  if info == nil then
    local nextInfo = self.infoList[self.selectedIdx + 1]
    if nextInfo then
      self.selectedIdx = self.selectedIdx + 1
    else
      local lastInfo = self.infoList[self.selectedIdx - 1]
      if lastInfo then
        self.selectedIdx = self.selectedIdx - 1
      end
    end
    self.useNum = 0
  end
  self:setShowList()
  self:setSelectedInfo(self.infoList[self.selectedIdx])
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------TurnedCardLevelUpUsePanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Use" then
    self:clickUse()
  elseif id == "Btn_Get" then
    local info = self.infoList[self.selectedIdx]
    if info and info.isItem then
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(info.info.itemId, clickObj, 0, true)
    end
  elseif string.find(id, "Item_") then
    local idx = tonumber(string.sub(id, #"item_" + 1))
    warn("----------item idx:", idx)
    if idx then
      self.useNum = 0
      self.selectedIdx = idx
      self:setSelectedInfo(self.infoList[idx])
    end
  end
end
def.method().clickUse = function(self)
  local info = self.infoList[self.selectedIdx]
  if info == nil then
    return
  end
  if info.isItem then
    do
      local itemId = info.info.itemId
      local num = ItemModule.Instance():GetNumberByItemId(ItemModule.CHANGE_MODEL_CARD_BAG, itemId)
      if self.useNum >= 3 then
        local function callback(id)
          if id == 1 then
            local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardUpgradeWithItemReq").new(self.curUUID, itemId, 1)
            gmodule.network.sendProtocol(p)
          end
          self.useNum = 0
        end
        CommonConfirmDlg.ShowConfirm("", textRes.TurnedCard[18], callback, nil)
        return
      end
      local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardUpgradeWithItemReq").new(self.curUUID, info.info.itemId, 0)
      gmodule.network.sendProtocol(p)
      self.useNum = self.useNum + 1
    end
  else
    local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardUpgradeWithCardReq").new(self.curUUID, info.info:getUUID())
    gmodule.network.sendProtocol(p)
  end
end
def.method().initUI = function(self)
  local Group_Right = self.m_panel:FindDirect("Img_Bg/Group_Right")
  Group_Right:SetActive(false)
  self:setCanUseList()
  self:setShowList()
  local Title = self.m_panel:FindDirect("Img_Bg/Title")
  Title:GetComponent("UILabel"):set_text(textRes.TurnedCard[19])
end
def.method().setCanUseList = function(self)
  local listInfo = {}
  local curCard = TurnedCardInterface.Instance():getTurnedCardById(self.curUUID)
  if curCard == nil then
    return
  end
  local level = curCard:getCardLevel()
  local cfgId = curCard:getCardCfgId()
  local itemList = TurnedCardUtils.GetChangeModelCardItemCfgList()
  for i, v in ipairs(itemList) do
    if v.cardCfgId == cfgId and v.provideExp > 0 and level >= v.cardLevel then
      local t = {isItem = true, info = v}
      table.insert(listInfo, t)
    end
  end
  local fragmentList = TurnedCardUtils.GetChangeModelCardFragmentCfgList()
  for i, v in ipairs(fragmentList) do
    if v.cardCfgId == cfgId and v.provideExp > 0 then
      local t = {isItem = true, info = v}
      table.insert(listInfo, t)
    end
  end
  local cardList = TurnedCardInterface.Instance():getTurnedCardList(0)
  for i, v in ipairs(cardList) do
    if not self.curUUID:eq(v:getUUID()) then
      local id = v:getCardCfgId()
      local lv = v:getCardLevel()
      if id == cfgId and level >= lv then
        local cfg = TurnedCardUtils.GetCardLevelCfg(id)
        if cfg and cfg.cardLevels[lv] and 0 < cfg.cardLevels[lv].provideExp then
          local t = {isItem = false, info = v}
          table.insert(listInfo, t)
        end
      end
    end
  end
  self.infoList = listInfo
end
def.method().setShowList = function(self)
  local listInfo = self.infoList
  local ScrollView = self.m_panel:FindDirect("Img_Bg/Group_Left/Scroll View")
  local List = ScrollView:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #listInfo
  uiList:Resize()
  for i, v in ipairs(listInfo) do
    local item = List:FindDirect("Item_" .. i)
    local toggle = item:GetComponent("UIToggle")
    toggle.value = i == self.selectedIdx
    if v.isItem then
      self:setItemInfo(item, i, v.info)
    else
      self:setCardInfo(item, i, v.info)
    end
  end
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
end
def.method("userdata", "number", "table").setItemInfo = function(self, obj, idx, cardItemCfg)
  local Img_Icon = obj:FindDirect("Img_Icon_" .. idx)
  local Number = obj:FindDirect("Number_" .. idx)
  local itemId = cardItemCfg.itemId
  local itemBase = ItemUtils.GetItemBase(itemId)
  GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), itemBase.icon)
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.CHANGE_MODEL_CARD_BAG, itemId)
  Number:GetComponent("UILabel"):set_text(num)
end
def.method("userdata", "number", TurnedCard).setCardInfo = function(self, obj, idx, card)
  local Img_Icon = obj:FindDirect("Img_Icon_" .. idx)
  local Number = obj:FindDirect("Number_" .. idx)
  local cfgId = card:getCardCfgId()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
  GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), cardCfg.iconId)
  Number:GetComponent("UILabel"):set_text(1)
end
def.method("table").setSelectedInfo = function(self, info)
  local Group_Right = self.m_panel:FindDirect("Img_Bg/Group_Right")
  if info == nil then
    Group_Right:SetActive(false)
    return
  end
  Group_Right:SetActive(true)
  local Item = Group_Right:FindDirect("Item")
  local Img_Icon = Item:FindDirect("Img_Icon")
  local Label_Name = Group_Right:FindDirect("Label_Name")
  local Label_Describe = Group_Right:FindDirect("Label_Describe")
  local Btn_Use = Group_Right:FindDirect("Btn_Use")
  local Btn_Get = Group_Right:FindDirect("Btn_Get")
  if info.isItem then
    local cardItemCfg = info.info
    local itemId = cardItemCfg.itemId
    local itemBase = ItemUtils.GetItemBase(itemId)
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), itemBase.icon)
    Label_Name:GetComponent("UILabel"):set_text(itemBase.name)
    local html = ItemTipsMgr.Instance():GetSimpleDescription(itemBase)
    html = string.gsub(html, "ffffff", "8f3d21")
    Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(html)
    local num = ItemModule.Instance():GetNumberByItemId(ItemModule.CHANGE_MODEL_CARD_BAG, itemId)
    if num > 0 then
      Btn_Use:SetActive(true)
      Btn_Get:SetActive(false)
    else
      Btn_Use:SetActive(false)
      Btn_Get:SetActive(true)
    end
  else
    local card = info.info
    local cfgId = card:getCardCfgId()
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
    local levelCfg = TurnedCardUtils.GetCardLevelCfg(cfgId)
    local level = card:getCardLevel()
    local addExp = levelCfg.cardLevels[level].provideExp
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), cardCfg.iconId)
    Label_Name:GetComponent("UILabel"):set_text(cardCfg.cardName)
    Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.TurnedCard[17], level, cardCfg.cardName, addExp))
    Btn_Use:SetActive(true)
    Btn_Get:SetActive(false)
  end
end
TurnedCardLevelUpUsePanel.Commit()
return TurnedCardLevelUpUsePanel

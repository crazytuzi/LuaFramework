local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemYuanBaoTipPanel = Lplus.Extend(ECPanelBase, "ItemYuanBaoTipPanel")
local def = ItemYuanBaoTipPanel.define
def.field("string").mTitle = ""
def.field("string").mDesc = ""
def.field("number").mNeedItemId = 0
def.field("number").mNeedItemNum = 0
def.field("function").mCallBack = nil
def.field("table").mExtInfo = nil
def.field("table").mUIObjs = nil
def.field("boolean").mIsWaitingYuanBaoPrice = false
def.field("boolean").mNeedYuanBaoReplace = false
def.field("table").mYuanBaoPriceMap = nil
def.field("number").mNeedYuanBaoNum = 0
local instance
def.static("=>", ItemYuanBaoTipPanel).Instance = function()
  if nil == instance then
    instance = ItemYuanBaoTipPanel()
  end
  return instance
end
def.method("string", "string", "number", "number", "function", "table").ShowItemYuanBaoPanel = function(self, title, desc, itemId, itemNum, cb, tag)
  if self:IsShow() then
    return
  end
  self.mTitle = title
  self.mDesc = desc
  self.mNeedItemId = itemId
  self.mNeedItemNum = itemNum
  self.mCallBack = cb
  self.mExtInfo = tag
  self.mUIObjs = {}
  self.mIsWaitingYuanBaoPrice = false
  self.mNeedYuanBaoReplace = false
  self.mYuanBaoPriceMap = nil
  self.mNeedYuanBaoNum = 0
  self:CreatePanel(RESPATH.PREFAB_ITEM_YUANBAO_TIP_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ItemYuanBaoTipPanel.OnBagInfoSyncronized)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemYuanbaoPriceWithId", ItemYuanBaoTipPanel.OnAskItemPriceRes)
  self:InitUI()
  self:UpdateData()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ItemYuanBaoTipPanel.OnBagInfoSyncronized)
  self.mTitle = ""
  self.mDesc = ""
  self.mNeedItemId = 0
  self.mNeedItemNum = 0
  self.mCallBack = nil
  self.mExtInfo = nil
  self.mUIObjs = nil
  self.mIsWaitingYuanBaoPrice = false
  self.mNeedYuanBaoReplace = false
  self.mYuanBaoPriceMap = nil
  self.mNeedYuanBaoNum = 0
end
def.static("table", "table").OnBagInfoSyncronized = function(p1, p2)
  local self = ItemYuanBaoTipPanel.Instance()
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  self:UpdateNeedItemView()
  self:UpdateComfirmBtnState()
  self:UpdateDesc()
end
def.static("table").OnAskItemPriceRes = function(p)
  local self = ItemYuanBaoTipPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and self.mIsWaitingYuanBaoPrice then
    self.mIsWaitingYuanBaoPrice = false
    local uid = p.uid
    local itemid2yuanbao = p.itemid2yuanbao
    if uid and itemid2yuanbao and uid == self.mNeedItemId then
      if nil == self.mYuanBaoPriceMap then
        self.mYuanBaoPriceMap = {}
      end
      self.mYuanBaoPriceMap[self.mNeedItemId] = itemid2yuanbao[self.mNeedItemId]
      if self.mYuanBaoPriceMap[self.mNeedItemId] then
        self.mNeedYuanBaoReplace = true
        local haveItemNum = ItemModule.Instance():GetItemCountById(self.mNeedItemId)
        self.mNeedYuanBaoNum = self.mYuanBaoPriceMap[self.mNeedItemId] * (self.mNeedItemNum - haveItemNum)
      end
    end
    self:UpdateDesc()
    self:UpdateComfirmBtnState()
  end
end
def.method().InitUI = function(self)
  self.mUIObjs.titleLabel = self.m_panel:FindDirect("Img_Bg0/Img_BgTitle/Label_Title")
  self.mUIObjs.itemTexture = self.m_panel:FindDirect("Img_Bg0/Img_IconBg/Img_ItemIcon")
  self.mUIObjs.itemNumLabel = self.m_panel:FindDirect("Img_Bg0/Img_IconBg/Label_ItemNumber")
  self.mUIObjs.itemNameLabel = self.m_panel:FindDirect("Img_Bg0/Img_IconBg/Label_ItemName")
  self.mUIObjs.toggleBtn = self.m_panel:FindDirect("Img_Bg0/Group_UseYuanbao/Btn_UseGold")
  self.mUIObjs.yuanbaoLabel = self.m_panel:FindDirect("2D Sprite/Btn_Confirm/Label_UseGold")
  self.mUIObjs.btnLabel = self.m_panel:FindDirect("2D Sprite/Btn_Confirm/Label_Confirm")
  self.mUIObjs.ConfirmLabel = self.m_panel:FindDirect("Label_Confirm")
  self.mUIObjs.toggleBtn:GetComponent("UIToggle").value = false
end
def.method().UpdateData = function(self)
end
def.method().UpdateUI = function(self)
  local itemBase = ItemUtils.GetItemBase(self.mNeedItemId)
  if not itemBase then
    return
  end
  self.mUIObjs.titleLabel:GetComponent("UILabel"):set_text(self.mTitle)
  self:UpdateNeedItemView()
  self:UpdateComfirmBtnState()
  self:UpdateDesc()
end
def.method().UpdateDesc = function(self)
  local itemBase = ItemUtils.GetItemBase(self.mNeedItemId)
  local description = string.format(textRes.Item[9503], self.mNeedItemNum, itemBase.name, self.mDesc)
  if self.mNeedYuanBaoReplace and self.mNeedYuanBaoNum > 0 then
    description = string.format(textRes.Item[9505], self.mNeedYuanBaoNum, self.mDesc)
  end
  self.mUIObjs.ConfirmLabel:GetComponent("UILabel"):set_text(description)
end
def.method().UpdateNeedItemView = function(self)
  local itemBase = ItemUtils.GetItemBase(self.mNeedItemId)
  local itemName = itemBase.name
  local haveItemNum = ItemModule.Instance():GetItemCountById(self.mNeedItemId)
  self.mUIObjs.itemNameLabel:GetComponent("UILabel"):set_text(itemName)
  local numStr = string.format("%d/%d", self.mNeedItemNum, haveItemNum)
  self.mUIObjs.itemNumLabel:GetComponent("UILabel"):set_text(numStr)
  if haveItemNum >= self.mNeedItemNum then
    self.mUIObjs.itemNumLabel:GetComponent("UILabel"):set_color(Color.green)
  else
    self.mUIObjs.itemNumLabel:GetComponent("UILabel"):set_color(Color.red)
  end
  GUIUtils.FillIcon(self.mUIObjs.itemTexture:GetComponent("UITexture"), itemBase.icon)
end
def.method().UpdateComfirmBtnState = function(self)
  local uiToggle = self.mUIObjs.toggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  local haveItemNum = ItemModule.Instance():GetItemCountById(self.mNeedItemId)
  if curValue and self.mNeedYuanBaoReplace and self.mYuanBaoPriceMap and self.mYuanBaoPriceMap[self.mNeedItemId] then
    if haveItemNum >= self.mNeedItemNum then
      uiToggle.value = false
      self.mUIObjs.yuanbaoLabel:SetActive(false)
      self.mUIObjs.btnLabel:SetActive(true)
      self.mIsWaitingYuanBaoPrice = false
      self.mNeedYuanBaoReplace = false
      self.mYuanBaoPriceMap = nil
      self.mNeedYuanBaoNum = 0
      return
    end
    self.mUIObjs.yuanbaoLabel:SetActive(true)
    self.mUIObjs.btnLabel:SetActive(false)
    local uiLabel = self.mUIObjs.yuanbaoLabel:GetComponent("UILabel")
    local itemPrice = self.mYuanBaoPriceMap[self.mNeedItemId]
    local needYuanBaoNum = itemPrice * (self.mNeedItemNum - haveItemNum)
    self.mNeedYuanBaoNum = needYuanBaoNum
    uiLabel:set_text(tostring(self.mNeedYuanBaoNum))
  else
    self.mUIObjs.yuanbaoLabel:SetActive(false)
    self.mUIObjs.btnLabel:SetActive(true)
    self.mIsWaitingYuanBaoPrice = false
    self.mNeedYuanBaoReplace = false
    self.mYuanBaoPriceMap = nil
    self.mNeedYuanBaoNum = 0
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Cancel" then
    self:DestroyPanel()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickCallBack()
    self:DestroyPanel()
  elseif id == "Btn_UseGold" then
    self:OnClickToggleBtn()
  elseif id == "Img_IconBg" then
    self:ShowGetItemTips(clickObj, "UISprite", self.mNeedItemId)
  end
end
def.method("userdata", "string", "number").ShowGetItemTips = function(self, obj, comName, itemid)
  local position = obj.position
  local screenPosition = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent(comName)
  local width = sprite:get_width()
  local height = sprite:get_height()
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTips(itemid, screenPosition.x, screenPosition.y, width, height, 0, true)
end
def.method().OnClickCallBack = function(self)
  if self.mIsWaitingYuanBaoPrice then
    return
  end
  if self.mNeedYuanBaoReplace and self.mNeedYuanBaoNum > 0 then
    local allYuanBao = ItemModule.Instance():GetAllYuanBao()
    if allYuanBao:lt(self.mNeedYuanBaoNum) then
      Toast(textRes.Common[15])
    elseif self.mCallBack ~= nil then
      self.mCallBack(self.mNeedYuanBaoNum, self.mExtInfo)
    end
  else
    local haveItemNum = ItemModule.Instance():GetItemCountById(self.mNeedItemId)
    if haveItemNum >= self.mNeedItemNum then
      if self.mCallBack ~= nil then
        self.mCallBack(0, self.mExtInfo)
      end
    else
      local itemBase = ItemUtils.GetItemBase(self.mNeedItemId)
      local itemName = itemBase.name
      Toast(string.format(textRes.Item[9506], itemName))
    end
  end
end
def.method().OnClickToggleBtn = function(self)
  local uiToggle = self.mUIObjs.toggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    local haveItemNum = ItemModule.Instance():GetItemCountById(self.mNeedItemId)
    if haveItemNum >= self.mNeedItemNum then
      uiToggle.value = false
      Toast(textRes.Item[9504])
      self:UpdateComfirmBtnState()
      return
    end
    self.mIsWaitingYuanBaoPrice = true
    self.mNeedYuanBaoReplace = false
    self.mYuanBaoPriceMap = nil
    self.mNeedYuanBaoNum = 0
    local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self.mNeedItemId, {
      self.mNeedItemId
    })
    gmodule.network.sendProtocol(p)
  else
    self.mIsWaitingYuanBaoPrice = false
    self.mNeedYuanBaoReplace = false
    self.mNeedYuanBaoNum = 0
    self.mYuanBaoPriceMap = nil
    self:UpdateDesc()
    self:UpdateComfirmBtnState()
  end
end
ItemYuanBaoTipPanel.Commit()
return ItemYuanBaoTipPanel

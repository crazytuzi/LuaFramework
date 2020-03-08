local Lplus = require("Lplus")
local TabSonNode = require("Main.CommerceAndPitch.ui.TabSonNode")
local CommercePitchPanel = Lplus.ForwardDeclare("CommercePitchPanel")
local PitchSellNode = Lplus.Extend(TabSonNode, "PitchSellNode")
local def = PitchSellNode.define
local PitchData = require("Main.CommerceAndPitch.data.PitchData")
local MyShoppingItem = require("netio.protocol.mzm.gsp.baitan.MyShoppingItem")
local ItemUtils = require("Main.Item.ItemUtils")
local PitchItemOnShelfPanel = require("Main.CommerceAndPitch.ui.OnShelf.PitchItemOnShelfPanel")
local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
local SCommonResultRes = require("netio.protocol.mzm.gsp.baitan.SCommonResultRes")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemOnShelfAgainPanel = require("Main.CommerceAndPitch.ui.OnShelf.ItemOnShelfAgainPanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
def.field(PitchData).data = nil
def.field("table").uiTbl = nil
def.field("number").lastSellListNum = 0
def.override(CommercePitchPanel, "userdata").Init = function(self, base, node)
  TabSonNode.Init(self, base, node)
  self.data = PitchData.Instance()
  self.uiTbl = CommercePitchUtils.FillPitchSellNodeUI(self.uiTbl, self.m_node)
end
def.override().OnShow = function(self)
  self:FillSellPanel()
end
def.override().OnHide = function(self)
end
def.method().UpdateSilverMoney = function(self)
  self.uiTbl.Label_MoneyNum:GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
end
def.method().FillSellPanel = function(self)
  self:UpdateItemObjects()
  self:FillSellList()
  self:UpdateSilverMoney()
end
def.method().UpdatePitchSellList = function(self)
  self:UpdateItemObjects()
  self:FillSellList()
end
def.method("number").OnCommonResultRes = function(self, res)
end
def.method().UpdateItemObjects = function(self)
  local itemDVal = self.data:GetSellGridNum() + 1 - self.lastSellListNum
  if self.data:GetSellGridNum() + 1 > CommercePitchUtils.GetStallMax() then
    itemDVal = self.data:GetSellGridNum() - self.lastSellListNum
  end
  local itemGridTemplate = self.uiTbl.Grid_SellItem
  local itemTemplate = self.uiTbl.Img_BgSellItem01
  if itemDVal > 0 then
    for i = 1, itemDVal do
      self.lastSellListNum = self.lastSellListNum + 1
      CommercePitchUtils.AddLastGroup(self.lastSellListNum, "Img_BgSellItem0%d", itemGridTemplate, itemTemplate)
    end
  elseif itemDVal < 0 then
    local num = math.abs(itemDVal)
    for i = 1, num do
      CommercePitchUtils.DeleteLastGroup(self.lastSellListNum, "Img_BgSellItem01", itemGridTemplate, itemTemplate)
      self.lastSellListNum = self.lastSellListNum - 1
    end
  end
  local uiGrid = itemGridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self.m_base.m_msgHandler:Touch(itemGridTemplate)
end
def.method().FillSellList = function(self)
  local sellList = self.data:GetSellList()
  local sellGridNum = self.data:GetSellGridNum()
  local gridShowNum = sellGridNum + 1
  if gridShowNum >= CommercePitchUtils.GetStallMax() then
    gridShowNum = CommercePitchUtils.GetStallMax()
  end
  local gridTemplate = self.uiTbl.Grid_SellItem
  local sellTemplate = self.uiTbl.Img_BgSellItem01
  for i = 1, gridShowNum do
    local groupNew = gridTemplate:GetChild(i - 1)
    self:FillSellInfo(sellList, sellGridNum, gridShowNum, i, groupNew)
  end
  self.lastSellListNum = gridShowNum
end
def.method("table", "number", "number", "number", "userdata").FillSellInfo = function(self, list, gridNum, showNum, index, sellItem)
  local Group_SellItem = sellItem:FindDirect("Group_SellItem")
  local Group_Empty = sellItem:FindDirect("Group_Empty")
  local Group_Lock = sellItem:FindDirect("Group_Lock")
  if index <= #list then
    if list[index].bNeedUpdate then
      Group_SellItem:SetActive(false)
      Group_Empty:SetActive(true)
      Group_Lock:SetActive(false)
    else
      Group_SellItem:SetActive(true)
      Group_Empty:SetActive(false)
      Group_Lock:SetActive(false)
      self:FillItemInfo(list[index], Group_SellItem)
    end
  elseif index > #list and index <= gridNum then
    Group_SellItem:SetActive(false)
    Group_Empty:SetActive(true)
    Group_Lock:SetActive(false)
  elseif gridNum < index and index <= showNum and showNum <= CommercePitchUtils.GetStallMax() then
    Group_SellItem:SetActive(false)
    Group_Empty:SetActive(false)
    Group_Lock:SetActive(true)
    Group_Lock:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(CommercePitchUtils.GetExpendStallCostYuanBao())
  end
  sellItem:GetComponent("UIToggle"):set_isChecked(false)
end
def.method("table", "userdata").FillItemInfo = function(self, itemInfo, item)
  if item == nil then
    return
  end
  local Img_Sign = item:FindDirect("Img_Sign")
  local Label_Price = item:FindDirect("Label_Price")
  local Label_ItemName = item:FindDirect("Label_ItemName")
  local Img_BgItem = item:FindDirect("Img_BgItem")
  local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon"):GetComponent("UITexture")
  local Label = Img_BgItem:FindDirect("Label")
  local itemId = itemInfo.item.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  Label_ItemName:GetComponent("UILabel"):set_text(itemBase.name)
  GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
  Label:GetComponent("UILabel"):set_text(itemInfo.item.number)
  local priceText = CommercePitchUtils.GetPitchColoredPriceText(itemInfo.price)
  Label_Price:GetComponent("UILabel"):set_text(priceText)
  GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
  if MyShoppingItem.STATE_SELL == itemInfo.state then
    Img_Sign:SetActive(false)
    GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
  elseif MyShoppingItem.STATE_SELLED == itemInfo.state then
    Img_Sign:SetActive(true)
    if 0 == itemInfo.item.number then
      CommercePitchUtils.FillIcon("Img_Sell", Img_Sign:GetComponent("UISprite"), 0)
      GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
    else
      CommercePitchUtils.FillIcon("Img_Get", Img_Sign:GetComponent("UISprite"), 0)
      GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
    end
  elseif MyShoppingItem.STATE_EXPIRE == itemInfo.state then
    Img_Sign:SetActive(true)
    CommercePitchUtils.FillIcon("Img_Overdue", Img_Sign:GetComponent("UISprite"), 0)
    GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
  end
  if nil ~= CommercePitchPanel.Instance().requirementsItemTbl[itemId] or nil ~= CommercePitchPanel.Instance().requirementsCondItemId[itemId] then
    Img_Sign:SetActive(true)
    CommercePitchUtils.FillIcon("Img_Need", Img_Sign:GetComponent("UISprite"), 0)
  end
end
def.method().OnOnShelfClick = function(self)
  local sellListNum = #self.data:GetSellList()
  local sellGridNum = self.data:GetSellGridNum()
  local canUseNum = sellGridNum - sellListNum
  local callback
  local tag = {id = self, canUseNum = canUseNum}
  PitchItemOnShelfPanel.ShowItemOnShelf(callback, tag, 0, 0)
end
def.method().OnGetMoneyClick = function(self)
  if false == self.data:IfHaveMoneyToGetMoney() then
    Toast(textRes.Pitch[8])
    return
  end
  CommercePitchProtocol.CAutoGetMoneyReq()
end
def.static("number", "table").ExtendGridCallback = function(i, tag)
  if 1 == i then
    CommercePitchProtocol.CUnlockGridReq()
  elseif 0 == i then
    return
  end
end
def.method("userdata").OnShelfItemClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, string.len("Img_BgSellItem0") + 1))
  local sellListNum = #self.data:GetSellList()
  local sellGridNum = self.data:GetSellGridNum()
  local gridShowNum = sellGridNum + 1
  if index <= sellListNum then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      self:OnItemOnShelfClick(index)
    end
  elseif index > sellListNum and index <= sellGridNum then
    local canUseNum = sellGridNum - sellListNum
    local callback
    local tag = {id = self, canUseNum = canUseNum}
    PitchItemOnShelfPanel.ShowItemOnShelf(callback, tag, 0, 0)
  elseif index > sellGridNum and index <= gridShowNum then
    CommonConfirmDlg.ShowConfirm(textRes.Pitch[9], string.format(textRes.Pitch[10], CommercePitchUtils.GetExpendStallCostYuanBao()), PitchSellNode.ExtendGridCallback, nil)
  end
end
def.method("number", "number").SellToPitch = function(self, itemKey, itemId)
  local sellListNum = #self.data:GetSellList()
  local sellGridNum = self.data:GetSellGridNum()
  local gridShowNum = sellGridNum + 1
  local index = 0
  if sellListNum < sellGridNum then
    index = sellListNum + 1
  end
  if index > 0 then
    local canUseNum = sellGridNum - sellListNum
    local callback
    local tag = {id = self, canUseNum = canUseNum}
    PitchItemOnShelfPanel.ShowItemOnShelf(callback, tag, itemId, itemKey)
  else
    Toast(textRes.Pitch[24])
  end
end
def.method("number").OnItemOnShelfClick = function(self, index)
  local sellList = self.data:GetSellList()
  local itemInfo = sellList[index]
  if MyShoppingItem.STATE_SELL == itemInfo.state then
    local callback
    local tag = {id = self}
    ItemOnShelfAgainPanel.ShowItemOnShelfAgain(callback, tag, itemInfo)
  elseif MyShoppingItem.STATE_SELLED == itemInfo.state then
    self:GetSoldItemMoney(itemInfo)
  elseif MyShoppingItem.STATE_EXPIRE == itemInfo.state then
    local callback
    local tag = {id = self}
    ItemOnShelfAgainPanel.ShowItemOnShelfAgain(callback, tag, itemInfo)
  end
end
def.method("table").GetSoldItemMoney = function(self, itemInfo)
  CommercePitchProtocol.CGetMoneyReq(itemInfo.shoppingid, itemInfo.item.id)
end
def.method().ShowTaxTips = function(self)
  local tipsId = CommercePitchUtils.GetPitchTaxTipsId()
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Sell" == id then
    self:OnOnShelfClick()
  elseif "Btn_Get" == id then
    self:OnGetMoneyClick()
  elseif string.find(id, "Img_BgSellItem0") then
    self:OnShelfItemClick(clickobj)
  elseif "Img_Add" == id then
    local parent = clickobj.parent.parent
    self:OnShelfItemClick(parent)
  elseif "Img_BgItem" == id then
    local position = clickobj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickobj:GetComponent("UISprite")
    local index = tonumber(string.sub(clickobj.parent.parent.name, string.len("Img_BgSellItem0") + 1))
    local sellList = self.data:GetSellList()
    if sellList[index] and sellList[index].item then
      ItemTipsMgr.Instance():ShowTips(sellList[index].item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
    end
  elseif "Btn_SellTips" == id then
    self:ShowTaxTips()
  end
end
def.method().UpdateRequirementsCondTbl = function(self)
  self:FillSellList()
end
PitchSellNode.Commit()
return PitchSellNode

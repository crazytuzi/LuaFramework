local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GiftTipsPanel = Lplus.Extend(ECPanelBase, "GiftTipsPanel")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local TmpTipsPanel = require("Main.Item.ui.TmpTipsPanel")
local def = GiftTipsPanel.define
local dlg
def.field("table").moneyList = nil
def.field("table").expList = nil
def.field("table").itemList = nil
def.field("number").appellationId = 0
def.field("number").titleId = 0
def.field("number").itemId = 0
def.field("userdata").uuid = nil
def.const("table").TypeConst = {
  Money = 1,
  Exp = 2,
  Item = 3,
  Appellation = 4,
  Tittle = 5
}
def.static("=>", GiftTipsPanel).Instance = function(self)
  if nil == dlg then
    dlg = GiftTipsPanel()
  end
  return dlg
end
def.static("table", "table", "table", "number", "number", "number", "userdata").ShowPreviewGifts = function(moneyList, expList, itemList, appellationId, titleId, itemId, uuid)
  local tip = GiftTipsPanel.Instance()
  tip.moneyList = moneyList
  tip.expList = expList
  tip.itemList = itemList
  tip.appellationId = appellationId
  tip.titleId = titleId
  tip.itemId = itemId
  tip.uuid = uuid
  tip:CreatePanel(RESPATH.PREFAB_GIFT_TIP_PANEL, 0)
  tip:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:UpdateGifts()
  self:UpdateButton()
end
def.method().UpdateTitle = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label = Img_Bg:FindDirect("Img_Title/Label"):GetComponent("UILabel")
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  Label:set_text(itemBase.name)
end
def.method().UpdateGifts = function(self)
  local Img_BgItem = self.m_panel:FindDirect("Img_Bg/Img_BgItem")
  local ScrollView = Img_BgItem:FindDirect("Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local num = 0
  local moneyGiftNum = 0
  local expGiftNum = 0
  local itemGiftNum = 0
  local appellationNum = 0
  local titleNum = 0
  if self.moneyList ~= nil and 0 < #self.moneyList then
    moneyGiftNum = #self.moneyList
  end
  if self.expList ~= nil and 0 < #self.expList then
    expGiftNum = #self.expList
  end
  if self.itemList ~= nil and 0 < #self.itemList then
    itemGiftNum = #self.itemList
  end
  if self.appellationId ~= 0 then
    appellationNum = 1
  end
  if self.titleId ~= 0 then
    titleNum = 1
  end
  num = moneyGiftNum + expGiftNum + itemGiftNum + appellationNum + titleNum
  local uiList = Grid:GetComponent("UIList")
  uiList:set_itemCount(num)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local giftsUI = uiList:get_children()
  for i = 1, moneyGiftNum do
    local index = i
    local giftUI = giftsUI[index]
    local moneyGiftInfo = self.moneyList[i]
    self:FillMoneyGiftInfo(giftUI, index, moneyGiftInfo, i)
  end
  for i = 1, expGiftNum do
    local index = i + moneyGiftNum
    local giftUI = giftsUI[index]
    local expGiftInfo = self.expList[i]
    self:FillExpGiftInfo(giftUI, index, expGiftInfo, i)
  end
  for i = 1, itemGiftNum do
    local index = i + moneyGiftNum + expGiftNum
    local giftUI = giftsUI[index]
    local itemGiftInfo = self.itemList[i]
    self:FillItemGiftInfo(giftUI, index, itemGiftInfo, i)
  end
  for i = 1, appellationNum do
    local index = i + moneyGiftNum + expGiftNum + itemGiftNum
    local giftUI = giftsUI[index]
    local appellationGiftInfo = self.appellationId
    self:FillAppellationGiftInfo(giftUI, index, appellationGiftInfo, i)
  end
  for i = 1, titleNum do
    local index = i + moneyGiftNum + expGiftNum + itemGiftNum + appellationNum
    local giftUI = giftsUI[index]
    local titleGiftInfo = self.titleId
    self:FillTitleGiftInfo(giftUI, index, titleGiftInfo, i)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table", "number").FillMoneyGiftInfo = function(self, giftUI, i, moneyGiftInfo, index)
  local Texture = giftUI:FindDirect(string.format("Texture_%d", i)):GetComponent("UITexture")
  local Label = giftUI:FindDirect(string.format("Label_%d", i))
  local Label_Type = giftUI:FindDirect(string.format("Label_Type_%d", i))
  local Label_Index = giftUI:FindDirect(string.format("Label_Index_%d", i))
  Label_Type:SetActive(false)
  Label_Index:SetActive(false)
  Label_Type:GetComponent("UILabel"):set_text(GiftTipsPanel.TypeConst.Money)
  Label_Index:GetComponent("UILabel"):set_text(index)
  local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
  if moneyGiftInfo.bigType == AllMoneyType.TYPE_MONEY then
    local cfgInfo = ItemUtils.GetMoneyCfg(moneyGiftInfo.littleType)
    GUIUtils.FillIcon(Texture, cfgInfo.iconTex)
    if Int64.gt(moneyGiftInfo.num, 1) then
      Label:SetActive(true)
      Label:GetComponent("UILabel"):set_text(moneyGiftInfo.num)
    else
      Label:SetActive(false)
    end
  elseif moneyGiftInfo.bigType == AllMoneyType.TYPE_TOKEN then
    local cfgInfo = ItemUtils.GetMoneyCfg(moneyGiftInfo.littleType)
    GUIUtils.FillIcon(Texture, cfgInfo.iconTex)
    if Int64.gt(moneyGiftInfo.num, 1) then
      Label:SetActive(true)
      Label:GetComponent("UILabel"):set_text(moneyGiftInfo.num)
    else
      Label:SetActive(false)
    end
  end
end
def.method("userdata", "number", "table", "number").FillExpGiftInfo = function(self, giftUI, i, expGiftInfo, index)
  local Texture = giftUI:FindDirect(string.format("Texture_%d", i)):GetComponent("UITexture")
  local Label = giftUI:FindDirect(string.format("Label_%d", i)):GetComponent("UILabel")
  local Label_Type = giftUI:FindDirect(string.format("Label_Type_%d", i))
  local Label_Index = giftUI:FindDirect(string.format("Label_Index_%d", i))
  Label_Type:SetActive(false)
  Label_Index:SetActive(false)
  Label_Type:GetComponent("UILabel"):set_text(GiftTipsPanel.TypeConst.Exp)
  Label_Index:GetComponent("UILabel"):set_text(index)
end
def.method("userdata", "number", "table", "number").FillItemGiftInfo = function(self, giftUI, i, itemGiftInfo, index)
  local Texture = giftUI:FindDirect(string.format("Texture_%d", i)):GetComponent("UITexture")
  local Label = giftUI:FindDirect(string.format("Label_%d", i))
  local Label_Type = giftUI:FindDirect(string.format("Label_Type_%d", i))
  local Label_Index = giftUI:FindDirect(string.format("Label_Index_%d", i))
  Label_Type:SetActive(false)
  Label_Index:SetActive(false)
  Label_Type:GetComponent("UILabel"):set_text(GiftTipsPanel.TypeConst.Item)
  Label_Index:GetComponent("UILabel"):set_text(index)
  local itemBase = ItemUtils.GetItemBase(itemGiftInfo.itemId)
  GUIUtils.FillIcon(Texture, itemBase.icon)
  if itemGiftInfo.num > 1 then
    Label:SetActive(true)
    Label:GetComponent("UILabel"):set_text(itemGiftInfo.num)
  else
    Label:SetActive(false)
  end
end
def.method("userdata", "number", "number", "number").FillAppellationGiftInfo = function(self, giftUI, i, appellationGiftInfo, index)
  local Texture = giftUI:FindDirect(string.format("Texture_%d", i)):GetComponent("UITexture")
  local Label = giftUI:FindDirect(string.format("Label_%d", i))
  local Label_Type = giftUI:FindDirect(string.format("Label_Type_%d", i))
  local Label_Index = giftUI:FindDirect(string.format("Label_Index_%d", i))
  Label_Type:SetActive(false)
  Label_Index:SetActive(false)
  Label_Type:GetComponent("UILabel"):set_text(GiftTipsPanel.TypeConst.Appellation)
  Label_Index:GetComponent("UILabel"):set_text(index)
  local iconId = ItemUtils.GetTitleConst("APPELLATION_ICON_ID")
  GUIUtils.FillIcon(Texture, iconId)
  Label:SetActive(false)
end
def.method("userdata", "number", "number", "number").FillTitleGiftInfo = function(self, giftUI, i, titleGiftInfo, index)
  local Texture = giftUI:FindDirect(string.format("Texture_%d", i)):GetComponent("UITexture")
  local Label = giftUI:FindDirect(string.format("Label_%d", i))
  local Label_Type = giftUI:FindDirect(string.format("Label_Type_%d", i))
  local Label_Index = giftUI:FindDirect(string.format("Label_Index_%d", i))
  Label_Type:SetActive(false)
  Label_Index:SetActive(false)
  Label_Type:GetComponent("UILabel"):set_text(GiftTipsPanel.TypeConst.Tittle)
  Label_Index:GetComponent("UILabel"):set_text(index)
  local iconId = ItemUtils.GetTitleConst("TITLE_ICON_ID")
  GUIUtils.FillIcon(Texture, iconId)
  Label:SetActive(false)
end
def.method().UpdateButton = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Btn_CostGet = Img_Bg:FindDirect("Btn_CostGet")
  local Btn_CommonGet = Img_Bg:FindDirect("Btn_CommonGet")
  local itemCfg = ItemUtils.GetGiftBasicCfg(self.itemId)
  if itemCfg.moneyNum > 0 then
    Btn_CostGet:SetActive(true)
    Btn_CommonGet:SetActive(false)
    Btn_CostGet:FindDirect("Group/Label_Num"):GetComponent("UILabel"):set_text(itemCfg.moneyNum)
  else
    Btn_CostGet:SetActive(false)
    Btn_CommonGet:SetActive(true)
  end
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if 1 == i then
  end
end
def.static("number", "table").BuyGoldCallback = function(i, tag)
  if 1 == i then
  end
end
def.static("number", "table").BuySilverCallback = function(i, tag)
  if 1 == i then
  end
end
def.method().OnUseClick = function(self)
  local itemCfg = ItemUtils.GetGiftBasicCfg(self.itemId)
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.level < itemBase.useLevel or heroProp.level > itemCfg.maxUseLevel then
    Toast(string.format(textRes.Item[133], itemCfg.useLevel, itemCfg.maxUseLevel))
    return
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local ItemModule = require("Main.Item.ItemModule")
  if itemCfg.moneyType == MoneyType.YUANBAO then
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanbao, itemCfg.moneyNum) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[132], itemCfg.moneyNum), GiftTipsPanel.BuyYuanbaoCallback, nil)
      return
    end
  elseif itemCfg.moneyType == MoneyType.GOLD then
    local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if Int64.lt(gold, itemCfg.moneyNum) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[134], itemCfg.moneyNum), GiftTipsPanel.BuyGoldCallback, nil)
      return
    end
  elseif itemCfg.moneyType == MoneyType.SILVER then
    local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if Int64.lt(silver, itemCfg.moneyNum) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[135], itemCfg.moneyNum), GiftTipsPanel.BuySilverCallback, nil)
      return
    end
  elseif itemCfg.moneyType == MoneyType.GANGCONTRIBUTE then
    local GangModule = require("Main.Gang.GangModule")
    local bHasGang = GangModule.Instance():HasGang()
    if bHasGang == false then
      Toast(textRes.Item[136])
      return
    else
      local bangGong = GangModule.Instance():GetHeroCurBanggong()
      if bangGong < itemCfg.moneyNum then
        Toast(textRes.Item[137])
        return
      end
    end
  end
  local useItem = require("netio.protocol.mzm.gsp.item.CUseGiftBagItem").new(self.uuid, 0)
  gmodule.network.sendProtocol(useItem)
  self:DestroyPanel()
  self = nil
end
def.method("number", "userdata").ShowMoneyTips = function(self, index, clickobj)
  local obj = clickobj
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
  local pos = {
    auto = true,
    sourceX = screenPos.x,
    sourceY = screenPos.y,
    sourceW = sprite:get_width(),
    sourceH = sprite:get_height(),
    prefer = 0
  }
  if self.moneyList[index].bigType == AllMoneyType.TYPE_MONEY then
    local cfgInfo = ItemUtils.GetMoneyCfg(self.moneyList[index].littleType)
    local iconId = cfgInfo.iconTex
    local name = cfgInfo.name
    local numStr = string.format("%s X %s", name, self.moneyList[index].num)
    local strTable = {}
    table.insert(strTable, string.format("<p align=left valign=middle><font size=22 color=#%s>", "ffffff"))
    table.insert(strTable, numStr)
    table.insert(strTable, "<br/>")
    table.insert(strTable, "</font></p>")
    local desc = table.concat(strTable)
    TmpTipsPanel.ShowTip(pos, iconId, desc, name, "")
  elseif self.moneyList[index].bigType == AllMoneyType.TYPE_TOKEN then
    local cfgInfo = ItemUtils.GetMoneyCfg(self.moneyList[index].littleType)
    local iconId = cfgInfo.iconTex
    local name = cfgInfo.name
    local numStr = string.format("%s X %s", name, self.moneyList[index].num)
    local strTable = {}
    table.insert(strTable, string.format("<p align=left valign=middle><font size=22 color=#%s>", "ffffff"))
    table.insert(strTable, numStr)
    table.insert(strTable, "<br/>")
    table.insert(strTable, "</font></p>")
    local desc = table.concat(strTable)
    TmpTipsPanel.ShowTip(pos, iconId, desc, name, "")
  end
end
def.method("number", "userdata").ShowExpTips = function(self, index, clickobj)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local obj = clickobj
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  local pos = {
    auto = true,
    sourceX = screenPos.x,
    sourceY = screenPos.y,
    sourceW = sprite:get_width(),
    sourceH = sprite:get_height(),
    prefer = 0
  }
end
def.method("number", "userdata").ShowItemTips = function(self, index, clickobj)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local obj = clickobj
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(self.itemList[index].itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method("number", "userdata").ShowAppellationTips = function(self, index, clickobj)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local obj = clickobj
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  local pos = {
    auto = true,
    sourceX = screenPos.x,
    sourceY = screenPos.y,
    sourceW = sprite:get_width(),
    sourceH = sprite:get_height(),
    prefer = 0
  }
  local iconId = ItemUtils.GetTitleConst("APPELLATION_ICON_ID")
  local TitleInterface = require("Main.title.TitleInterface")
  local appellationCfg = TitleInterface.GetAppellationCfg(self.appellationId)
  local name = appellationCfg.appellationName
  local description = appellationCfg.description
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle><font size=22 color=#%s>", "ffffff"))
  table.insert(strTable, description)
  table.insert(strTable, "<br/>")
  table.insert(strTable, "</font></p>")
  local desc = table.concat(strTable)
  TmpTipsPanel.ShowTip(pos, iconId, desc, name, textRes.Item[11001])
end
def.method("number", "userdata").ShowTittleTips = function(self, index, clickobj)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local obj = clickobj
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  local pos = {
    auto = true,
    sourceX = screenPos.x,
    sourceY = screenPos.y,
    sourceW = sprite:get_width(),
    sourceH = sprite:get_height(),
    prefer = 0
  }
  local iconId = ItemUtils.GetTitleConst("TITLE_ICON_ID")
  local TitleInterface = require("Main.title.TitleInterface")
  local titleCfg = TitleInterface.GetTitleCfg(self.titleId)
  local name = titleCfg.titleName
  local description = titleCfg.description
  local strTable = {}
  table.insert(strTable, string.format("<p align=left valign=middle><font size=22 color=#%s>", "ffffff"))
  table.insert(strTable, description)
  table.insert(strTable, "<br/>")
  table.insert(strTable, "</font></p>")
  local desc = table.concat(strTable)
  TmpTipsPanel.ShowTip(pos, iconId, desc, name, textRes.Item[11002])
end
def.method("userdata").OnGiftClick = function(self, clickobj)
  local id = clickobj.name
  local i = tonumber(string.sub(id, #"Img_Item_" + 1, -1))
  local Label_Type = clickobj:FindDirect(string.format("Label_Type_%d", i)):GetComponent("UILabel"):get_text()
  local Label_Index = clickobj:FindDirect(string.format("Label_Index_%d", i)):GetComponent("UILabel"):get_text()
  local type = tonumber(Label_Type)
  local index = tonumber(Label_Index)
  if GiftTipsPanel.TypeConst.Money == type then
    self:ShowMoneyTips(index, clickobj)
  elseif GiftTipsPanel.TypeConst.Exp == type then
    self:ShowExpTips(index, clickobj)
  elseif GiftTipsPanel.TypeConst.Item == type then
    self:ShowItemTips(index, clickobj)
  elseif GiftTipsPanel.TypeConst.Appellation == type then
    self:ShowAppellationTips(index, clickobj)
  elseif GiftTipsPanel.TypeConst.Tittle == type then
    self:ShowTittleTips(index, clickobj)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_CostGet" == id then
    self:OnUseClick()
  elseif "Btn_CommonGet" == id then
    self:OnUseClick()
  elseif "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif string.sub(id, 1, #"Img_Item_") == "Img_Item_" then
    self:OnGiftClick(clickobj)
  end
end
GiftTipsPanel.Commit()
return GiftTipsPanel

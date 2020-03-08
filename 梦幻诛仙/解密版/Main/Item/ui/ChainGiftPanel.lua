local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChainGiftPanel = Lplus.Extend(ECPanelBase, "ChainGiftPanel")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = ChainGiftPanel.define
local dlg
def.field("number").itemId = 0
def.field("userdata").uuid = nil
def.field("number").leftTime = 0
def.field("table").itemList = nil
def.field("number").timerId = 0
def.static("=>", ChainGiftPanel).Instance = function(self)
  if nil == dlg then
    dlg = ChainGiftPanel()
  end
  return dlg
end
def.static("number", "userdata", "number").ShowGiftsPreview = function(itemId, uuid, leftTime)
  local tip = ChainGiftPanel.Instance()
  tip.itemId = itemId
  tip.uuid = uuid
  tip.leftTime = leftTime
  tip:CreatePanel(RESPATH.PREFAB_CHAIN_GIFT_PANEL, 2)
  tip:SetModal(true)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self.itemList = ItemUtils.GetItemsInChainGiftBag(self.itemId)
  self:UpdateInfo()
  self:StartTimer()
end
def.override().OnDestroy = function(self)
  self:StopTimer()
  self.itemId = 0
  self.uuid = nil
  self.leftTime = 0
  self.itemList = nil
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:UpdateGifts()
  self:UpdateGiftState()
end
def.method().UpdateTitle = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label = Img_Bg:FindDirect("Img_Title/Label")
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  local itemName = itemBase and itemBase.name or ""
  GUIUtils.SetText(Label, itemName)
end
def.method().UpdateGifts = function(self)
  local Img_BgItem = self.m_panel:FindDirect("Img_Bg/Img_BgItem")
  local ScrollView = Img_BgItem:FindDirect("Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local itemGiftNum = #self.itemList
  local num = itemGiftNum
  local uiList = Grid:GetComponent("UIList")
  uiList:set_itemCount(num)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local giftsUI = uiList:get_children()
  for i = 1, itemGiftNum do
    local index = i
    local giftUI = giftsUI[index]
    local itemGiftInfo = self.itemList[i]
    self:FillItemGiftInfo(giftUI, index, itemGiftInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillItemGiftInfo = function(self, giftUI, index, itemGiftInfo)
  local Texture = giftUI:FindDirect(string.format("Texture_%d", index))
  local Label_Num = giftUI:FindDirect(string.format("Label_Nun_%d", index))
  local Label_Name = giftUI:FindDirect(string.format("Label_Name_%d", index))
  local itemBase = ItemUtils.GetItemBase(itemGiftInfo.itemId)
  local iconId = itemBase and itemBase.icon or 0
  local itemName = itemBase and itemBase.name or ""
  local itemNum = itemGiftInfo.itemNum
  GUIUtils.SetTexture(Texture, iconId)
  GUIUtils.SetText(Label_Name, itemName)
  GUIUtils.SetText(Label_Num, itemNum)
end
def.method().UpdateGiftState = function(self)
  local Btn_Get = self.m_panel:FindDirect("Img_Bg/Btn_Get")
  local Label_Time = self.m_panel:FindDirect("Img_Bg/Label_Time")
  if self.leftTime > 0 then
    GUIUtils.SetActive(Btn_Get, false)
    GUIUtils.SetActive(Label_Time, true)
    GUIUtils.SetText(Label_Time, string.format(textRes.Item[12004], _G.SeondsToTimeText(self.leftTime)))
  else
    GUIUtils.SetActive(Btn_Get, true)
    GUIUtils.SetActive(Label_Time, false)
  end
end
def.method().StartTimer = function(self)
  if self.timerId == 0 and 0 < self.leftTime then
    self.timerId = GameUtil.AddGlobalTimer(1, false, function()
      if self.leftTime <= 0 then
        self:StopTimer()
        return
      end
      self.leftTime = self.leftTime - 1
      self:UpdateGiftState()
    end)
  end
end
def.method().StopTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method().OnGetBtnClick = function(self)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CHAINED_GIFT_BAG) then
    Toast(textRes.Item[12005])
    return
  end
  local itemCfg = ItemUtils.GetGiftBasicCfg(self.itemId)
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.level < itemBase.useLevel or heroProp.level > itemCfg.maxUseLevel then
    Toast(string.format(textRes.Item[133], itemCfg.useLevel, itemCfg.maxUseLevel))
    return
  end
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local ItemModule = require("Main.Item.ItemModule")
  if itemCfg.moneyType == MoneyType.YUANBAO then
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanbao, itemCfg.moneyNum) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[132], itemCfg.moneyNum), ChainGiftPanel.BuyYuanbaoCallback, nil)
      return
    end
  elseif itemCfg.moneyType == MoneyType.GOLD then
    local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if Int64.lt(gold, itemCfg.moneyNum) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[134], itemCfg.moneyNum), ChainGiftPanel.BuyGoldCallback, nil)
      return
    end
  elseif itemCfg.moneyType == MoneyType.SILVER then
    local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if Int64.lt(silver, itemCfg.moneyNum) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[135], itemCfg.moneyNum), ChainGiftPanel.BuySilverCallback, nil)
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
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if 1 == i then
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  end
end
def.static("number", "table").BuyGoldCallback = function(i, tag)
  if 1 == i then
    _G.GoToBuyGold()
  end
end
def.static("number", "table").BuySilverCallback = function(i, tag)
  if 1 == i then
    _G.GoToBuySilver()
  end
end
def.method("number", "userdata").ShowItemTips = function(self, index, clickobj)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local obj = clickobj
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(self.itemList[index].itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method("userdata").OnGiftClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, #"Img_Item_" + 1, -1))
  self:ShowItemTips(index, clickobj)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif id == "Btn_Get" then
    self:OnGetBtnClick()
  elseif string.sub(id, 1, #"Img_Item_") == "Img_Item_" then
    self:OnGiftClick(clickobj)
  end
end
def.static("table", "table").OnUseItemRes = function(params, context)
  local itemId = params[1]
  local num = params[2]
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.GetItemMsg(itemId, num)
  dlg:DestroyPanel()
end
ChainGiftPanel.Commit()
return ChainGiftPanel

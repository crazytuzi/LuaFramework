local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local MallBatchBuyPanel = Lplus.Extend(ECPanelBase, "MallBatchBuyPanel")
local def = MallBatchBuyPanel.define
local instance
def.field("number").selectBuyItemId = 0
def.field("number").buyNum = 1
def.field("number").canBuyNum = 0
def.field("number").timerId = 0
def.static("=>", MallBatchBuyPanel).Instance = function()
  if instance == nil then
    instance = MallBatchBuyPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
end
def.method("number").ShowPanel = function(self, selectBuyItemId)
  if self:IsShow() then
    return
  end
  self.selectBuyItemId = selectBuyItemId
  self:SetModal(true)
  self:CreatePanel(RESPATH.PERFAB_MALL_BATCH_BUY_PANEL, 0)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_CALC_ITEM_PRICE_INFO, MallBatchBuyPanel.OnCalcPriceInfo)
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_BUY_SUCCESS, MallBatchBuyPanel.OnBuySuccess)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, MallBatchBuyPanel.OnMoneyChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MallBatchBuyPanel.OnBagChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_CALC_ITEM_PRICE_INFO, MallBatchBuyPanel.OnCalcPriceInfo)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_BUY_SUCCESS, MallBatchBuyPanel.OnBuySuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, MallBatchBuyPanel.OnMoneyChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MallBatchBuyPanel.OnBagChange)
end
def.static("table", "table").OnBagChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setBuyItemInfo()
  end
end
def.static("table", "table").OnMoneyChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setBuyInfo()
  end
end
def.static("table", "table").OnCalcPriceInfo = function(p1, p2)
  if instance and instance:IsShow() and instance.selectBuyItemId == p1.itemId then
    instance:setBuyInfo()
  end
end
def.static("table", "table").OnBuySuccess = function(p1, p2)
  if instance and instance:IsShow() and instance.selectBuyItemId == p1.itemId then
    local Btn_Yes = instance.m_panel:FindDirect("Img_Bg/Btn_Yes")
    Btn_Yes:GetComponent("UIButton").isEnabled = true
    GameUtil.RemoveGlobalTimer(instance.timerId)
    instance.timerId = 0
    local calcInfo = CommerceData.Instance():GetCalcItemPriceInfo(instance.selectBuyItemId)
    if calcInfo and instance.buyNum > calcInfo.canBuyNum then
      instance.buyNum = calcInfo.canBuyNum
      if instance.buyNum < 1 then
        instance.buyNum = 1
      end
    end
    instance:setBuyItemInfo()
    instance:setBuyInfo()
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setBuyItemInfo()
    self:setBuyInfo()
  else
    self.buyNum = 1
    self.canBuyNum = 0
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  warn("MallBatchBuyPanel onClickObj: " .. id)
  if "Btn_Close" == id then
    self:Hide()
  elseif id == "Btn_Plus" then
    if self.buyNum < self.canBuyNum then
      self.buyNum = self.buyNum + 1
      self:setBuyInfo()
    else
      Toast(textRes.Commerce[27])
    end
  elseif id == "Btn_Reduce" then
    if self.buyNum > 1 then
      self.buyNum = self.buyNum - 1
      self:setBuyInfo()
    else
    end
  elseif id == "Btn_Max" then
    if self.canBuyNum <= 0 then
      return
    end
    self.buyNum = self.canBuyNum
    self:setBuyInfo()
  elseif id == "Label_Num" then
    local pName = clickobj.parent.name
    if pName == "Group_BuyNum" then
      do
        local NumberPad = require("GUI.CommonDigitalKeyboard")
        NumberPad.Instance():ShowPanelEx(-1, function(num)
          if self:IsShow() then
            if num == self.buyNum then
              return
            end
            if num > self.canBuyNum then
              NumberPad.Instance():SetEnteredValue(self.buyNum)
              Toast(string.format(textRes.NPCStore[22], self.canBuyNum))
              return
            end
            if num < 1 then
              NumberPad.Instance():SetEnteredValue(0)
              num = 1
            else
              NumberPad.Instance():SetEnteredValue(num)
            end
            self.buyNum = num
            self:setBuyInfo()
          end
        end, {self = self})
        NumberPad.Instance():SetPos(260, 0)
      end
    end
  elseif id == "Btn_Yes" then
    local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    local p = require("netio.protocol.mzm.gsp.shanghui.CBuyItemReq").new(gold, self.selectBuyItemId, self.buyNum)
    gmodule.network.sendProtocol(p)
    clickobj:GetComponent("UIButton").isEnabled = false
    if self.timerId == 0 then
      self.timerId = GameUtil.AddGlobalTimer(3, true, function()
        if _G.IsNil(self.m_panel) or _G.IsNil(clickobj) then
          return
        end
        clickobj:GetComponent("UIButton").isEnabled = true
        self.timerId = 0
      end)
    end
  elseif id == "Texture_RightIcon" then
    local position = clickobj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickobj:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(self.selectBuyItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  elseif id == "Btn_MoneyPlus" then
    GoToBuyGold(false)
  elseif id == "Btn_Help" then
    require("GUI.GUIUtils").ShowHoverTip(701610004, 0, 0)
  end
end
def.method().setBuyItemInfo = function(self)
  local itemBase = ItemUtils.GetItemBase(self.selectBuyItemId)
  local Group_Item = self.m_panel:FindDirect("Img_Bg/Group_Item")
  local Texture_RightIcon = Group_Item:FindDirect("Img_Item/Texture_RightIcon")
  local Label_ItemNum = Group_Item:FindDirect("Img_Item/Label_ItemNum")
  local Label_Name = Group_Item:FindDirect("Label_Name")
  local Label_Num = Group_Item:FindDirect("Label_Num")
  local Group_UpDown = Group_Item:FindDirect("Group_UpDown")
  local Img_Arrow = Group_UpDown:FindDirect("Img_Arrow")
  local Label_Percent = Group_UpDown:FindDirect("Label_Percent")
  local Img_Equal = Group_UpDown:FindDirect("Img_Equal")
  GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), itemBase.icon)
  Label_Name:GetComponent("UILabel"):set_text(itemBase.name)
  local itemInfo = CommerceData.Instance():GetItemInfo(self.selectBuyItemId)
  Label_Num:GetComponent("UILabel"):set_text(itemInfo.price)
  local ownNum = ItemModule.Instance():GetItemCountById(self.selectBuyItemId)
  Label_ItemNum:GetComponent("UILabel"):set_text(ownNum)
  local extent = itemInfo.rise / 10000 * 100
  extent = tonumber(string.format("%0.2f", extent))
  if extent > 0 then
    Img_Equal:SetActive(false)
    Label_Percent:SetActive(true)
    Img_Arrow:SetActive(true)
    Label_Percent:GetComponent("UILabel"):set_text(math.abs(extent) .. "%")
  elseif extent < 0 then
    Img_Equal:SetActive(false)
    Label_Percent:SetActive(true)
    Img_Arrow:SetActive(true)
    Label_Percent:GetComponent("UILabel"):set_text(math.abs(extent) .. "%")
  elseif extent == 0 then
    Img_Equal:SetActive(true)
    Label_Percent:SetActive(false)
    Img_Arrow:SetActive(false)
  end
end
def.method().setBuyInfo = function(self)
  local calcInfo = CommerceData.Instance():GetCalcItemPriceInfo(self.selectBuyItemId)
  if calcInfo then
    self.canBuyNum = calcInfo.canBuyNum or 0
  end
  local Group_Info = self.m_panel:FindDirect("Img_Bg/Group_Info")
  local Label_Num = Group_Info:FindDirect("Group_BuyNum/Label_Num")
  local Label_Cost = Group_Info:FindDirect("Group_CostNum/Label_Num")
  local Label_Own = Group_Info:FindDirect("Group_CurNum/Label_Num")
  local Label_RestNum = Group_Info:FindDirect("Group_BuyNum/Label_RestNum")
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  Label_Num:GetComponent("UILabel"):set_text(self.buyNum)
  Label_RestNum:GetComponent("UILabel"):set_text(self.canBuyNum)
  Label_Own:GetComponent("UILabel"):set_text(tostring(gold))
  local itemInfo = CommerceData.Instance():GetItemInfo(self.selectBuyItemId)
  local totalPrice = 0
  local price = itemInfo.price
  local rise = itemInfo.rise
  local itemId = self.selectBuyItemId
  local commerceItem = CommercePitchUtils.GetCommerceItemInfo(itemId)
  if commerceItem and commerceItem.isPriceFlow then
    for i = 1, self.buyNum do
      price, rise = CommercePitchUtils.CalcCommerceItemPrice(itemId, price, rise)
      totalPrice = totalPrice + price
    end
  else
    totalPrice = price * self.buyNum
  end
  warn("-------totalPrice----:", totalPrice)
  Label_Cost:GetComponent("UILabel"):set_text(totalPrice)
end
return MallBatchBuyPanel.Commit()

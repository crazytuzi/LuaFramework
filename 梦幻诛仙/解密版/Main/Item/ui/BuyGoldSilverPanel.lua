local EC = require("Types.Vector3")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local BuyGoldSilverPanel = Lplus.Extend(ECPanelBase, "BuyGoldSilverPanel")
local def = BuyGoldSilverPanel.define
def.const("number").ITEMNUM = 6
local exchangType = {
  YUANBAO2SILVER = 1,
  YUANBAO2GOLD = 2,
  YUANBAO2INGOT = 3,
  INGOT2GOLD = 4
}
local typeToName = {
  [exchangType.YUANBAO2SILVER] = {
    MoneyName = textRes.Item.MoneyName[3],
    SourceMoneyName = textRes.Item.MoneyName[1],
    LabelSpriteName = "Label_YB",
    IconSpriteName = "Icon_Sliver",
    SourceSpriteName = "Img_Money",
    SourceMoneyType = MoneyType.YUANBAO,
    TargetMoneyType = MoneyType.SILVER
  },
  [exchangType.YUANBAO2GOLD] = {
    MoneyName = textRes.Item.MoneyName[2],
    SourceMoneyName = textRes.Item.MoneyName[1],
    LabelSpriteName = "Label_JB",
    IconSpriteName = "Icon_Gold",
    SourceSpriteName = "Img_Money",
    SourceMoneyType = MoneyType.YUANBAO,
    TargetMoneyType = MoneyType.GOLD
  },
  [exchangType.YUANBAO2INGOT] = {
    MoneyName = textRes.Item.MoneyName[5],
    SourceMoneyName = textRes.Item.MoneyName[1],
    LabelSpriteName = "Label_JD",
    IconSpriteName = "Img_JinDing",
    SourceSpriteName = "Img_Money",
    SourceMoneyType = MoneyType.YUANBAO,
    TargetMoneyType = MoneyType.GOLD_INGOT
  },
  [exchangType.INGOT2GOLD] = {
    MoneyName = textRes.Item.MoneyName[2],
    SourceMoneyName = textRes.Item.MoneyName[5],
    LabelSpriteName = "Label_JB",
    IconSpriteName = "Icon_Gold",
    SourceSpriteName = "Img_JinDing",
    SourceMoneyType = MoneyType.GOLD_INGOT,
    TargetMoneyType = MoneyType.GOLD
  }
}
def.const("table").TypeToName = typeToName
def.const("table").ExchangType = exchangType
def.const("string").YuanbaoSpriteName = "Img_Money"
def.field("table").priceData = nil
def.field("table").uiNodes = nil
def.field("number").exType = 0
local instance
def.static("=>", BuyGoldSilverPanel).Instance = function()
  if instance == nil then
    instance = BuyGoldSilverPanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, exchangType)
  if self:IsShow() and exchangType == self.exType then
    return
  end
  self.exType = exchangType
  self.priceData = nil
  if self:IsShow() then
    self:UpdateContent()
  else
    self:CreatePanel(RESPATH.PREFAB_BUY_GOLD_SILVER_PANEL, 1)
    self:SetModal(true)
  end
end
def.method().UpdateContent = function(self)
  self:GetPriceData()
  self:UpdateUI()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateContent()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, BuyGoldSilverPanel.OnWalletChanged)
end
def.override().OnDestroy = function(self)
  self:ClearUp()
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, BuyGoldSilverPanel.OnWalletChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, BuyGoldSilverPanel.OnWalletChanged)
end
def.method().ClearUp = function(self)
  self.exType = 0
  self.priceData = nil
  self.uiNodes = nil
end
def.method().InitUI = function(self)
  self.uiNodes = {}
  self.uiNodes.title = self.m_panel:FindDirect("Img_Bg1/Label_Title")
  self.uiNodes.grpItem = self.m_panel:FindDirect("Group_Content/Group_Item")
  self.uiNodes.grpBuy = self.m_panel:FindDirect("Group_Buy")
  self.uiNodes.btnBuy = self.uiNodes.grpBuy:FindDirect("Btn_Buy")
  self.uiNodes.items = {}
  for i = 1, BuyGoldSilverPanel.ITEMNUM do
    local item = self.uiNodes.grpItem:FindDirect(string.format("Group_Item%d/Img_BgItem", i))
    table.insert(self.uiNodes.items, item)
  end
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateTab()
  self:UpdatePrices()
  self:UpdateWallet()
end
def.method().UpdateTab = function(self)
  local Btn_GoldSwitch = self.m_panel:FindDirect("Group_Buy/Btn_GoldSwitch")
  if self.exType == BuyGoldSilverPanel.ExchangType.YUANBAO2SILVER then
    Btn_GoldSwitch:SetActive(false)
    local tab = self.m_panel:FindDirect("Img_Bg1/Tap_Sliver")
    tab:GetComponent("UIToggle"):set_value(true)
  elseif self.exType == BuyGoldSilverPanel.ExchangType.YUANBAO2GOLD then
    Btn_GoldSwitch:SetActive(true)
    local label = Btn_GoldSwitch:FindDirect("Label_Recycle")
    label:GetComponent("UILabel"):set_text(textRes.GetMoney[7])
    local tab = self.m_panel:FindDirect("Img_Bg1/Tap_Gold")
    tab:GetComponent("UIToggle"):set_value(true)
  elseif self.exType == BuyGoldSilverPanel.ExchangType.YUANBAO2INGOT then
    Btn_GoldSwitch:SetActive(false)
    local tab = self.m_panel:FindDirect("Img_Bg1/Tap_JinDing")
    tab:GetComponent("UIToggle"):set_value(true)
  elseif self.exType == BuyGoldSilverPanel.ExchangType.INGOT2GOLD then
    Btn_GoldSwitch:SetActive(true)
    local label = Btn_GoldSwitch:FindDirect("Label_Recycle")
    label:GetComponent("UILabel"):set_text(textRes.GetMoney[8])
    local tab = self.m_panel:FindDirect("Img_Bg1/Tap_Gold")
    tab:GetComponent("UIToggle"):set_value(true)
  end
end
def.method().UpdateTitle = function(self)
  local uilabelTitle = self.uiNodes.title:GetComponent("UILabel")
  uilabelTitle.text = BuyGoldSilverPanel.TypeToName[self.exType].MoneyName .. textRes.GetMoney[3]
end
def.method().UpdatePrices = function(self)
  if not self.priceData then
    return
  end
  if BuyGoldSilverPanel.ITEMNUM > #self.priceData then
    return
  end
  local tarSpriteName = BuyGoldSilverPanel.TypeToName[self.exType].LabelSpriteName
  local SourceSpriteName = BuyGoldSilverPanel.TypeToName[self.exType].SourceSpriteName
  for i = 1, BuyGoldSilverPanel.ITEMNUM do
    local uiItem = self.uiNodes.items[i]
    local dataItem = self.priceData[i]
    local uiTexture = uiItem:FindDirect("Texture"):GetComponent("UITexture")
    local iconId = dataItem.iconId
    GUIUtils.FillIcon(uiTexture, iconId)
    local uiLabelNum = uiItem:FindDirect("Group_Num/Label_Num"):GetComponent("UILabel")
    uiLabelNum.text = dataItem.targetNum
    local uiSpriteNum = uiItem:FindDirect("Group_Num/Img_Icon"):GetComponent("UISprite")
    uiSpriteNum:UpdateAnchors()
    uiSpriteNum.spriteName = tarSpriteName
    local uiLabelPrice = uiItem:FindDirect("Group_Price/Label_PriceNum"):GetComponent("UILabel")
    uiLabelPrice.text = dataItem.sourceNum
    local uiSpritePrice = uiItem:FindDirect("Group_Price/Img_PriceIcom"):GetComponent("UISprite")
    uiSpritePrice.spriteName = SourceSpriteName
  end
end
def.method().UpdateWallet = function(self)
  local tarMoneyInWallet
  if self.exType == exchangType.YUANBAO2GOLD or self.exType == exchangType.INGOT2GOLD then
    tarMoneyInWallet = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  elseif self.exType == exchangType.YUANBAO2SILVER then
    tarMoneyInWallet = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  elseif self.exType == exchangType.YUANBAO2INGOT then
    tarMoneyInWallet = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT)
  end
  local uiLabelMoneyNum = self.uiNodes.grpBuy:FindDirect("Group_Have1/Label_HaveNum"):GetComponent("UILabel")
  uiLabelMoneyNum.text = Int64.tostring(tarMoneyInWallet)
  local uiSpriteMoney = self.uiNodes.grpBuy:FindDirect("Group_Have1/Img_HaveIcom"):GetComponent("UISprite")
  uiSpriteMoney.spriteName = BuyGoldSilverPanel.TypeToName[self.exType].IconSpriteName
  local yuanbaoInWallet = 0
  if self.exType == exchangType.YUANBAO2INGOT then
    yuanbaoInWallet = ItemModule.Instance():getCashYuanBao()
    self.m_panel:FindDirect("Group_Buy/Label"):SetActive(true)
    self.m_panel:FindDirect("Group_Buy/Btn_Tips"):SetActive(true)
  elseif self.exType == exchangType.INGOT2GOLD then
    yuanbaoInWallet = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT)
    self.m_panel:FindDirect("Group_Buy/Label"):SetActive(false)
    self.m_panel:FindDirect("Group_Buy/Btn_Tips"):SetActive(false)
  else
    yuanbaoInWallet = ItemModule.Instance():GetAllYuanBao()
    self.m_panel:FindDirect("Group_Buy/Label"):SetActive(false)
    self.m_panel:FindDirect("Group_Buy/Btn_Tips"):SetActive(false)
  end
  local uiLabelYuanbaoNum = self.uiNodes.grpBuy:FindDirect("Group_Have2/Label_HaveNum"):GetComponent("UILabel")
  uiLabelYuanbaoNum.text = tostring(yuanbaoInWallet)
  local uiSpriteYuanbao = self.uiNodes.grpBuy:FindDirect("Group_Have2/Img_HaveIcom"):GetComponent("UISprite")
  uiSpriteYuanbao.spriteName = BuyGoldSilverPanel.TypeToName[self.exType].SourceSpriteName
end
def.method().GetPriceData = function(self)
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local serverLevel = serverLevelData.level
  local tarMoneyType = BuyGoldSilverPanel.TypeToName[self.exType].TargetMoneyType
  local yuanbaoRangecfg = ItemUtils.GetYuanbaoNumRangeCFG(serverLevel, tarMoneyType)
  if not yuanbaoRangecfg then
    return
  end
  self.priceData = {}
  local numList = yuanbaoRangecfg.yuanbaoNumList
  for i = 1, #numList do
    local exchangData
    if self.exType == exchangType.INGOT2GOLD then
      local key = string.format("%d_%d_%d", tarMoneyType, numList[i], serverLevel)
      local data = ItemUtils.GetGoldSilverPriceData(key)
      if not data then
        break
      end
      local factor = DynamicData.GetRecord(CFG_PATH.DATA_MONEYEXCHANGE_CFG, "INGOT_TO_GOLD_NUM"):GetFloatValue("value") or 1
      local goldNum = math.floor(data.moneyNum * factor)
      exchangData = {
        sourceNum = data.moneyNum,
        targetNum = data.moneyNum,
        iconId = data.iconId
      }
    else
      local key = string.format("%d_%d_%d", tarMoneyType, numList[i], serverLevel)
      local data = ItemUtils.GetGoldSilverPriceData(key)
      if not data then
        break
      end
      exchangData = {
        sourceNum = data.yuanbaoNum,
        targetNum = data.moneyNum,
        iconId = data.iconId
      }
    end
    if exchangData == nil then
      self.priceData = nil
      return
    end
    table.insert(self.priceData, exchangData)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Buy" then
  elseif id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif string.find(id, "Group_Item") == 1 then
    local idx = tonumber(string.sub(id, 11))
    self:OnSelectMoney(idx)
  elseif id == "Btn_Tips" then
    local tip = require("Main.Common.TipsHelper").GetHoverTip(701600503)
    if tip and tip ~= "" then
      require("GUI.CommonUITipsDlg").ShowCommonTip(tip, {x = 0, y = 0})
    end
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif id == "Tap_Gold" then
    if self.exType ~= BuyGoldSilverPanel.ExchangType.YUANBAO2GOLD and self.exType ~= BuyGoldSilverPanel.ExchangType.INGOT2GOLD then
      self:ShowPanel(BuyGoldSilverPanel.ExchangType.YUANBAO2GOLD)
    end
  elseif id == "Tap_Sliver" then
    self:ShowPanel(BuyGoldSilverPanel.ExchangType.YUANBAO2SILVER)
  elseif id == "Tap_JinDing" then
    self:ShowPanel(BuyGoldSilverPanel.ExchangType.YUANBAO2INGOT)
  elseif id == "Btn_GoldSwitch" then
    if self.exType == BuyGoldSilverPanel.ExchangType.YUANBAO2GOLD then
      self:ShowPanel(BuyGoldSilverPanel.ExchangType.INGOT2GOLD)
    elseif self.exType == BuyGoldSilverPanel.ExchangType.INGOT2GOLD then
      self:ShowPanel(BuyGoldSilverPanel.ExchangType.YUANBAO2GOLD)
    end
  elseif id == "Img_HaveIcom" then
    require("Main.Item.ItemModule").Instance():ShowYuanbaoDetail(1)
  end
end
def.method("number").OnSelectMoney = function(self, idx)
  if not self.priceData then
    return
  end
  local sourceNum = self.priceData[idx].sourceNum
  local numInWallet = 0
  if self.exType == exchangType.YUANBAO2INGOT then
    numInWallet = Int64.ToNumber(ItemModule.Instance():getCashYuanBao())
  elseif self.exType == exchangType.INGOT2GOLD then
    numInWallet = Int64.ToNumber(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT))
  else
    numInWallet = Int64.ToNumber(ItemModule.Instance():GetAllYuanBao())
  end
  if sourceNum > numInWallet then
    Toast(textRes.GetMoney[5])
    if self.exType == BuyGoldSilverPanel.ExchangType.INGOT2GOLD then
      self:ShowPanel(BuyGoldSilverPanel.ExchangType.YUANBAO2INGOT)
    else
      local MallPanel = require("Main.Mall.ui.MallPanel")
      MallPanel.Instance():Hide()
      require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
    end
    return
  end
  local targetNum = self.priceData[idx].targetNum
  local title = BuyGoldSilverPanel.TypeToName[self.exType].MoneyName .. textRes.GetMoney[3]
  local content = string.format(textRes.GetMoney[4], sourceNum, BuyGoldSilverPanel.TypeToName[self.exType].SourceMoneyName, targetNum, BuyGoldSilverPanel.TypeToName[self.exType].MoneyName)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(title, content, function(id, tag)
    if id == 1 then
      self:InformServer(sourceNum)
    end
  end, nil)
end
def.method("number").InformServer = function(self, exchangeNum)
  if self.exType == exchangType.INGOT2GOLD then
    local ingotInWallet = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT)
    local p = require("netio.protocol.mzm.gsp.item.CBuyGoldUseInGotReq").new(exchangeNum, ingotInWallet)
    gmodule.network.sendProtocol(p)
  elseif self.exType == exchangType.YUANBAO2INGOT then
    local yuanbaoInWallet = ItemModule.Instance():getCashYuanBao()
    local p = require("netio.protocol.mzm.gsp.item.CBuyGoldIngotReq").new(exchangeNum, yuanbaoInWallet)
    gmodule.network.sendProtocol(p)
  else
    local yuanbaoInWallet = ItemModule.Instance():GetAllYuanBao()
    local p = require("netio.protocol.mzm.gsp.item.CBuyGoldSilver").new(exchangeNum, BuyGoldSilverPanel.TypeToName[self.exType].TargetMoneyType, yuanbaoInWallet)
    gmodule.network.sendProtocol(p)
  end
end
def.static("table", "table").OnWalletChanged = function(p1, p2)
  instance:UpdateWallet()
end
return BuyGoldSilverPanel.Commit()

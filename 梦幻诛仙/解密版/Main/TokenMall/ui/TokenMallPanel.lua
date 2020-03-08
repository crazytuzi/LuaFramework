local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TokenMallPanel = Lplus.Extend(ECPanelBase, "TokenMallPanel")
local GUIUtils = require("GUI.GUIUtils")
local TokenMallUtils = require("Main.TokenMall.TokenMallUtils")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local TokenMallMgr = require("Main.TokenMall.mgr.TokenMallMgr")
local TokenMallDataMgr = require("Main.TokenMall.mgr.TokenMallDataMgr")
local TokenMallData = require("Main.TokenMall.data.TokenMallData")
local ExchangeType = require("consts.mzm.gsp.activitypointexchange.confbean.ExchangeType")
local def = TokenMallPanel.define
def.field("table").uiObjs = nil
def.field("number").mallCfgId = 0
def.field("table").tokenMallCfg = nil
def.field("table").tokenMallItems = nil
def.field("table").showMallItems = nil
def.field(TokenMallData).mallData = nil
def.field("number").initNodeId = 0
def.field("number").curNodeId = 0
def.field("table").nodes = nil
def.field("number").mallResetTimer = 0
def.field("number").mallRefreshTimer = 0
local instance
def.static("=>", TokenMallPanel).Instance = function()
  if instance == nil then
    instance = TokenMallPanel()
  end
  return instance
end
def.method("number").ShowTokenMallPanel = function(self, mallCfgId)
  if not _G.IsNil(self.m_panel) then
    return
  end
  self.mallCfgId = mallCfgId
  self:SetModal(true)
  local theme = TokenMallUtils.GetTokenMallTheme(mallCfgId)
  if theme ~= 0 then
    local panelPath = _G.GetIconPath(theme)
    self:CreatePanel(panelPath, 1)
  else
    self:CreatePanel(RESPATH.PREFAB_TOKEN_MALL_PANEL, 1)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitData()
  self:InitBasicInfo()
  self:UpdateManualRefreshStatus()
  self:UpdateTokenData()
  self:InitTab()
  self:SwitchToNode(self.initNodeId)
  self:StartMallResetTimer()
  self:StartMallRefreshTimer()
  Event.RegisterEvent(ModuleId.TOKEN_MALL, gmodule.notifyId.TokenMall.MALL_INFO_DATA_CHANGE, TokenMallPanel.OnMallInfoDataChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, TokenMallPanel.OnCreditChange)
end
def.override().OnDestroy = function(self)
  self:StopMallResetTimer()
  self:StopMallRefreshTimer()
  self.uiObjs = nil
  self.mallCfgId = 0
  self.tokenMallCfg = nil
  self.tokenMallItems = nil
  self.showMallItems = nil
  self.mallData = nil
  self.initNodeId = 0
  self.curNodeId = 0
  self.nodes = nil
  Event.UnregisterEvent(ModuleId.TOKEN_MALL, gmodule.notifyId.TokenMall.MALL_INFO_DATA_CHANGE, TokenMallPanel.OnMallInfoDataChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, TokenMallPanel.OnCreditChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Title = self.uiObjs.Img_Bg0:FindDirect("Img_Title/Label_Title")
  self.uiObjs.Group_Info = self.uiObjs.Img_Bg0:FindDirect("Group_Info")
  self.uiObjs.Label_Intro = self.uiObjs.Group_Info:FindDirect("Label_Intro")
  self.uiObjs.Group_Date = self.uiObjs.Group_Info:FindDirect("Group_Date")
  self.uiObjs.Group_Money = self.uiObjs.Group_Info:FindDirect("Group_Money")
  self.uiObjs.Btn_Fresh = self.uiObjs.Group_Info:FindDirect("Btn_Fresh")
  self.uiObjs.Tap_Limit = self.uiObjs.Img_Bg0:FindDirect("Tap_Limit")
  self.uiObjs.Tap_Forever = self.uiObjs.Img_Bg0:FindDirect("Tap_Forever")
  self.uiObjs.Group_Item = self.uiObjs.Img_Bg0:FindDirect("Group_Item")
end
def.method().InitData = function(self)
  self.tokenMallCfg = TokenMallUtils.GetTokenMallCfg(self.mallCfgId)
  self.tokenMallItems = {}
  self.tokenMallItems[ExchangeType.LIMITED_TIME] = {}
  self.tokenMallItems[ExchangeType.FOREVER] = {}
  local items = TokenMallUtils.GetTokenMallItems(self.tokenMallCfg.goodsCfgTypeId)
  for i = 1, #items do
    if items[i].exchangeType == ExchangeType.LIMITED_TIME then
      table.insert(self.tokenMallItems[ExchangeType.LIMITED_TIME], items[i])
    elseif items[i].exchangeType == ExchangeType.FOREVER then
      table.insert(self.tokenMallItems[ExchangeType.FOREVER], items[i])
    end
  end
  self.mallData = TokenMallDataMgr.Instance():GetTokenMallData(self.mallCfgId)
end
def.method().InitBasicInfo = function(self)
  local Label_Name = self.uiObjs.Group_Date:FindDirect("Label_Name")
  local Label_Time = self.uiObjs.Group_Date:FindDirect("Label_Time")
  if self.tokenMallCfg.mallLimitTimeId == 0 then
    GUIUtils.SetActive(Label_Name, false)
    GUIUtils.SetActive(Label_Time, false)
  else
    GUIUtils.SetActive(Label_Name, true)
    GUIUtils.SetActive(Label_Time, true)
    if self.tokenMallCfg.isShowMallTime == 0 then
      GUIUtils.SetActive(self.uiObjs.Group_Date, false)
    else
      GUIUtils.SetActive(self.uiObjs.Group_Date, true)
      local timeCfg = TimeCfgUtils.GetTimeLimitCommonCfg(self.tokenMallCfg.mallLimitTimeId)
      local timeStr = string.format(textRes.TokenMall[4], timeCfg.startYear, timeCfg.startMonth, timeCfg.startDay, timeCfg.endYear, timeCfg.endMonth, timeCfg.endDay)
      GUIUtils.SetText(Label_Time, timeStr)
    end
  end
  GUIUtils.SetText(self.uiObjs.Label_Title, self.tokenMallCfg.mallName)
  GUIUtils.SetText(self.uiObjs.Label_Intro, require("Main.Common.TipsHelper").GetHoverTip(self.tokenMallCfg.exchangeTipId))
end
def.method().UpdateTokenData = function(self)
  local Btn_Add = self.uiObjs.Group_Money:FindDirect("Btn_Add")
  GUIUtils.SetActive(Btn_Add, false)
  local tokenCfg = ItemUtils.GetTokenCfg(self.tokenMallCfg.tokenType)
  local value = ItemModule.Instance():GetCredits(self.tokenMallCfg.tokenType) or Int64.new(0)
  local Label_CostNum = self.uiObjs.Group_Money:FindDirect("Label_CostNum")
  local Img_MoneyIcon = self.uiObjs.Group_Money:FindDirect("Img_MoneyIcon")
  GUIUtils.SetSprite(Img_MoneyIcon, tokenCfg.icon)
  GUIUtils.SetText(Label_CostNum, value:tostring())
end
def.method().UpdateManualRefreshStatus = function(self)
  local canRefresh = self.tokenMallCfg.exchangeCountManualRefreshMaxCount ~= 0
  local refreshUseOut = false
  if self.tokenMallCfg.exchangeCountManualRefreshMaxCount > 0 then
    refreshUseOut = self.tokenMallCfg.exchangeCountManualRefreshMaxCount <= self.mallData:GetManualRefreshCount()
  end
  if not canRefresh then
    GUIUtils.SetActive(self.uiObjs.Btn_Fresh, false)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Fresh, true)
    local Label_Name = self.uiObjs.Btn_Fresh:FindDirect("Label_Name")
    local Group_Money = self.uiObjs.Btn_Fresh:FindDirect("Group_Money")
    local Img_Money = Group_Money:FindDirect("Img_Money")
    local Label_Money = Group_Money:FindDirect("Label_Money")
    if refreshUseOut then
      GUIUtils.SetActive(Label_Name, true)
      GUIUtils.SetActive(Group_Money, false)
      self.uiObjs.Btn_Fresh:GetComponent("UIButton"):set_isEnabled(false)
    else
      self.uiObjs.Btn_Fresh:GetComponent("UIButton"):set_isEnabled(true)
      local cost = TokenMallUtils.GetTokenMallRefreshCost(self.tokenMallCfg.manualRefreshCostTypeId, self.mallData:GetManualRefreshCount() + 1)
      if cost and cost.moneyType ~= 0 and cost.moneyCount ~= 0 then
        GUIUtils.SetActive(Label_Name, false)
        GUIUtils.SetActive(Group_Money, true)
        local CurrencyFactory = require("Main.Currency.CurrencyFactory")
        local moneyData = CurrencyFactory.Create(cost.moneyType)
        GUIUtils.SetSprite(Img_Money, moneyData:GetSpriteName())
        GUIUtils.SetText(Label_Money, string.format(textRes.TokenMall[14], cost.moneyCount))
      else
        GUIUtils.SetActive(Label_Name, true)
        GUIUtils.SetActive(Group_Money, false)
      end
    end
  end
end
def.method().InitTab = function(self)
  if #self.tokenMallItems[ExchangeType.LIMITED_TIME] == 0 then
    GUIUtils.SetActive(self.uiObjs.Tap_Limit, false)
    GUIUtils.SetActive(self.uiObjs.Tap_Forever, false)
    self.initNodeId = ExchangeType.FOREVER
  elseif #self.tokenMallItems[ExchangeType.FOREVER] == 0 then
    GUIUtils.SetActive(self.uiObjs.Tap_Limit, false)
    GUIUtils.SetActive(self.uiObjs.Tap_Forever, false)
    self.initNodeId = ExchangeType.LIMITED_TIME
  else
    GUIUtils.SetActive(self.uiObjs.Tap_Limit, true)
    GUIUtils.SetActive(self.uiObjs.Tap_Forever, true)
    self.initNodeId = ExchangeType.LIMITED_TIME
  end
  self.nodes = {}
  self.nodes[ExchangeType.LIMITED_TIME] = self.uiObjs.Tap_Limit
  self.nodes[ExchangeType.FOREVER] = self.uiObjs.Tap_Forever
end
def.method("number").SwitchToNode = function(self, nodeId)
  if self.curNodeId == nodeId then
    return
  end
  self.curNodeId = nodeId
  self:UpdateNodeView()
end
def.method().UpdateNodeView = function(self)
  if self.nodes[self.curNodeId] == nil then
    return
  end
  self.nodes[self.curNodeId]:GetComponent("UIToggle").value = true
  self:UpdateMallItemsData()
  local Scrollview = self.uiObjs.Group_Item:FindDirect("Scrollview")
  Scrollview:GetComponent("UIScrollView"):ResetPosition()
end
def.method().UpdateMallItemsData = function(self)
  self.showMallItems = {}
  for i = 1, #self.tokenMallItems[self.curNodeId] do
    local itemData = self.tokenMallItems[self.curNodeId][i]
    if not self.mallData:IsMallItemBanned(itemData.id) then
      table.insert(self.showMallItems, itemData)
    end
  end
  local Scrollview = self.uiObjs.Group_Item:FindDirect("Scrollview")
  local List = Scrollview:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #self.showMallItems
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local itemData = self.showMallItems[i]
    self:FillMallItemInfo(i, uiItem, itemData)
  end
end
def.method("number", "userdata", "table").FillMallItemInfo = function(self, idx, item, itemData)
  local Img_Icon = item:FindDirect("Img_BgIcon/Img_Icon")
  local Label_Num = item:FindDirect("Img_BgIcon/Label")
  local Label_Name = item:FindDirect("Label_Name")
  local Label_Price = item:FindDirect("Img_BgPrice/Label_Price")
  local Img_MoneyIcon = item:FindDirect("Img_BgPrice/Img_MoneyIcon")
  local Label_Exchange = item:FindDirect("Group_Exchange/Label_Num")
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(itemData.fixAwardId)
  if awardCfg and #awardCfg.itemList > 0 then
    local itemId = awardCfg.itemList[1].itemId
    local itemNum = awardCfg.itemList[1].num
    local itemBase = ItemUtils.GetItemBase(itemId)
    local uiTexture = Img_Icon:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    GUIUtils.SetText(Label_Name, itemBase.name)
    GUIUtils.SetText(Label_Num, itemNum)
  end
  local tokenCfg = ItemUtils.GetTokenCfg(self.tokenMallCfg.tokenType)
  GUIUtils.SetText(Label_Price, itemData.tokenCount)
  if tokenCfg then
    GUIUtils.SetSprite(Img_MoneyIcon, tokenCfg.icon)
  end
  if itemData.exchangeMaxCount == -1 then
    GUIUtils.SetText(Label_Exchange, textRes.TokenMall[5])
  else
    local canBuyCount = self.mallData:GetItemCanBuyCount(itemData.id)
    if not (canBuyCount >= 0) or not canBuyCount then
      canBuyCount = itemData.exchangeMaxCount
    end
    GUIUtils.SetText(Label_Exchange, string.format(textRes.TokenMall[6], itemData.exchangeMaxCount - canBuyCount, itemData.exchangeMaxCount))
  end
end
def.method().StartMallResetTimer = function(self)
  if self.mallResetTimer == 0 then
    self.mallResetTimer = GameUtil.AddGlobalTimer(1, false, function()
      if self.uiObjs == nil then
        return
      end
      if self.mallData:NeedResetExchangeCount() then
        self.mallData:ResetExchangeCount()
        self:UpdateMallItemsData()
      end
    end)
  end
end
def.method().StopMallResetTimer = function(self)
  if self.mallResetTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.mallResetTimer)
    self.mallResetTimer = 0
  end
end
def.method().StartMallRefreshTimer = function(self)
  if self.mallRefreshTimer == 0 and self.tokenMallCfg.exchangeCountManualRefreshMaxCount ~= 0 then
    self.mallRefreshTimer = GameUtil.AddGlobalTimer(1, false, function()
      if self.uiObjs == nil then
        return
      end
      local leftTime = self.mallData:GetMaualRefreshLeftTime()
      if leftTime == 0 then
        self.mallData:ResetManualRefreshData()
        self:UpdateManualRefreshStatus()
      end
    end)
  end
end
def.method().StopMallRefreshTimer = function(self)
  if self.mallRefreshTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.mallRefreshTimer)
    self.mallRefreshTimer = 0
  end
end
def.method("userdata").onClickObj = function(self, obj)
  if obj.name == "Img_ItemBg" then
    local parent = obj.parent
    local idx = tonumber(string.sub(parent.name, #"item_" + 1))
    if idx ~= nil then
      self:OnClickItem(idx, parent:FindDirect("Img_BgIcon"))
    end
  elseif obj.name == "Btn_Exchange" then
    local parent = obj.parent
    local idx = tonumber(string.sub(parent.name, #"item_" + 1))
    if idx ~= nil then
      self:OnBuyItem(idx)
    end
  else
    self:onClick(obj.name)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tap_Limit" then
    self:SwitchToNode(ExchangeType.LIMITED_TIME)
  elseif id == "Tap_Forever" then
    self:SwitchToNode(ExchangeType.FOREVER)
  elseif id == "Btn_Fresh" then
    self:OnClickBtnRefresh()
  elseif id == "Btn_Tips" then
    self:OnClickBtnTips()
  end
end
def.method("number", "userdata").OnClickItem = function(self, idx, source)
  local itemData = self.showMallItems[idx]
  if itemData == nil then
    return
  end
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(itemData.fixAwardId)
  if awardCfg and #awardCfg.itemList > 0 then
    local itemId = awardCfg.itemList[1].itemId
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, source, 0, false)
  end
end
def.method("number").OnBuyItem = function(self, idx)
  local itemData = self.showMallItems[idx]
  if itemData == nil then
    return
  end
  local itemId = 0
  local itemNum = 0
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(itemData.fixAwardId)
  if awardCfg and 0 < #awardCfg.itemList then
    itemId = awardCfg.itemList[1].itemId
    itemNum = awardCfg.itemList[1].num
  end
  if itemId == 0 then
    return
  end
  local canBuyCount = -1
  if itemData.exchangeMaxCount ~= -1 then
    canBuyCount = self.mallData:GetItemCanBuyCount(itemData.id)
    if not (canBuyCount >= 0) or not canBuyCount then
      canBuyCount = itemData.exchangeMaxCount
    end
    if canBuyCount <= 0 then
      Toast(textRes.TokenMall[10])
      return
    end
  end
  local full = ItemModule.Instance():IsBagFullForItemId(itemId)
  if full > 0 then
    ItemModule.Instance():ToastBagFull(full)
    return
  end
  require("Main.TokenMall.ui.TokenMallExchangePanel").Instance():ShowBuyConfirmPanel(itemId, itemNum, self.tokenMallCfg.tokenType, itemData.tokenCount, canBuyCount, function(num)
    if num < 0 then
      Toast(textRes.TokenMall[21])
      return false
    end
    local value = ItemModule.Instance():GetCredits(self.tokenMallCfg.tokenType) or Int64.new(0)
    if Int64.lt(value, itemData.tokenCount * num) then
      Toast(textRes.TokenMall[7])
      return false
    end
    TokenMallMgr.Instance():ExchangeItem(self.mallData:GetRelatedActivityId(), itemData.id, num)
  end)
end
def.method().OnClickBtnRefresh = function(self)
  if self.tokenMallCfg.exchangeCountManualRefreshMaxCount == 0 then
    Toast(textRes.TokenMall[11])
    return
  end
  if self.tokenMallCfg.exchangeCountManualRefreshMaxCount > 0 and self.mallData:GetManualRefreshCount() >= self.tokenMallCfg.exchangeCountManualRefreshMaxCount then
    Toast(textRes.TokenMall[12])
    return
  end
  local leftTimeStr = ""
  if self.tokenMallCfg.exchangeCountManualRefreshMaxCount > 0 then
    leftTimeStr = string.format(textRes.TokenMall[15], self.tokenMallCfg.exchangeCountManualRefreshMaxCount - self.mallData:GetManualRefreshCount())
  end
  local function refreshReq()
    TokenMallMgr.Instance():ManualRefreshMallInfo(self.mallData:GetRelatedActivityId(), self.mallData:GetManualRefreshCount())
  end
  local cost = TokenMallUtils.GetTokenMallRefreshCost(self.tokenMallCfg.manualRefreshCostTypeId, self.mallData:GetManualRefreshCount() + 1)
  if not cost or cost.moneyType == 0 or cost.moneyCount == 0 then
    local costStr = textRes.TokenMall[16]
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.TokenMall[18], leftTimeStr .. costStr, function(selection, tag)
      if self.uiObjs == nil then
        return
      end
      if selection == 1 then
        refreshReq()
      end
    end, nil)
  else
    do
      local CurrencyFactory = require("Main.Currency.CurrencyFactory")
      local moneyData = CurrencyFactory.Create(cost.moneyType)
      local costStr = string.format(textRes.TokenMall[17], cost.moneyCount, moneyData:GetName())
      require("GUI.CommonConfirmDlg").ShowConfirm(textRes.TokenMall[18], leftTimeStr .. costStr, function(selection, tag)
        if self.uiObjs == nil then
          return
        end
        if selection == 1 then
          local haveNum = moneyData:GetHaveNum()
          if Int64.lt(haveNum, cost.moneyCount) then
            moneyData:AcquireWithQuery()
          else
            refreshReq()
          end
        end
      end, nil)
    end
  end
end
def.method().OnClickBtnTips = function(self)
  GUIUtils.ShowHoverTip(self.tokenMallCfg.mallHelpTipId)
end
def.static("table", "table").OnMallInfoDataChange = function(params, context)
  local self = instance
  if params.activityId == self.mallData:GetRelatedActivityId() and params.mallCfgId == self.mallCfgId then
    self:UpdateManualRefreshStatus()
    self:UpdateMallItemsData()
  end
end
def.static("table", "table").OnCreditChange = function(params, context)
  local self = instance
  self:UpdateTokenData()
end
return TokenMallPanel.Commit()

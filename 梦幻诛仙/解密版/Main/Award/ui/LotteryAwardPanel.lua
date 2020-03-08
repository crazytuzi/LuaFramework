local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LotteryAwardPanel = Lplus.Extend(ECPanelBase, "LotteryAwardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local LotteryAwardMgr = require("Main.Award.mgr.LotteryAwardMgr")
local MibaoCurrencyFactory = require("Main.Currency.MibaoCurrencyFactory")
local def = LotteryAwardPanel.define
local DRAW_COUNT_NONE = 0
local DRAW_COUNT_ONE = 1
local DRAW_COUNT_TEN = 10
def.field("table").uiObjs = nil
def.field("table").m_prevItems = nil
def.field("table").m_getItems = nil
def.field("table").m_lotteryItemInfo = nil
def.field("boolean").m_buyBtnEnabled = true
def.field("table").m_currencyData = nil
local instance
def.static("=>", LotteryAwardPanel).Instance = function()
  if instance == nil then
    instance = LotteryAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  LotteryAwardMgr.Instance():CheckInfoData()
  self.m_TryIncLoadSpeed = true
  self.m_SyncLoad = true
  self:CreatePanel(RESPATH.PREFAB_LOTTERY_AWARD_PANEL, 0)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateUI()
  self:ShowPrizePreviewPage()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, LotteryAwardPanel.OnLotteryAwardUpdate)
end
def.method().UpdateUI = function(self)
  self:InitData()
  self:SetLotteryItemInfo()
  self:UpdateCurrencyInfo()
  self:UpdateCreditScore()
  self:UpdateLuckyPoint()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, LotteryAwardPanel.OnLotteryAwardUpdate)
  self.uiObjs = nil
  self.m_buyBtnEnabled = true
  ItemModule.Instance():BlockItemGetEffect(false)
  self.m_currencyData:UnregisterCurrencyChangedEvent(LotteryAwardPanel.OnCurrencyChanged)
  self.m_prevItems = nil
  self.m_lotteryItemInfo = nil
  self.m_getItems = nil
  self.m_currencyData = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Tab_AllPrize" then
    self:ShowPrizePreviewPage()
  elseif id == "Tab_PrizeGet" then
    self:OnClickPrizeGetTab()
  elseif string.find(id, "Texture_Icon") then
    self:OnItemBgObjClicked(obj)
  elseif id == "Btn_BuyOne" then
    self:OnBuyBtnClick()
  elseif id == "Btn_GoldBuy" then
    self:OnBuyBtnClick()
  elseif id == "Btn_BuyTen" then
    self:OnBuyTenTimesBtnClick()
  elseif id == "Btn_Add" then
    self:OnAddBtnClick()
  elseif id == "Btn_Exchange" then
    self:OnExchangeBtnClick()
  end
end
def.method("userdata").OnItemBgObjClicked = function(self, obj)
  local id = obj.parent.name
  local parent = obj.parent.parent
  local index = tonumber(string.sub(id, #"Img_BgIcon" + 1, -1))
  local itemInfo
  if parent.name == "Group_Items" then
    itemInfo = self.m_prevItems[index]
  elseif parent.name == "Group_Ten" then
    itemInfo = self.m_getItems[index]
  elseif parent.name == "Group_One" then
    itemInfo = self.m_getItems[1]
  elseif parent.name == "Group_Buy" then
    itemInfo = self.m_lotteryItemInfo
  end
  if itemInfo and itemInfo.id then
    local itemId = itemInfo.id
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, obj, 0, false)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_RandomPrize = self.m_panel:FindDirect("Group_RandomPrize")
  self.uiObjs.Label_Luck_Num = self.uiObjs.Group_RandomPrize:FindDirect("Label_Luck/Label_Num")
  self.uiObjs.Label_Credits_Num = self.uiObjs.Group_RandomPrize:FindDirect("Label_Credits/Label_Num")
  self.uiObjs.Tab_AllPrize = self.uiObjs.Group_RandomPrize:FindDirect("Tab_AllPrize")
  self.uiObjs.Tab_PrizeGet = self.uiObjs.Group_RandomPrize:FindDirect("Tab_PrizeGet")
  self.uiObjs.Group_Buy = self.uiObjs.Group_RandomPrize:FindDirect("Group_Buy")
  self.uiObjs.Group_Items = self.uiObjs.Group_RandomPrize:FindDirect("Group_Items")
  self.uiObjs.Group_ItemsGet = self.uiObjs.Group_RandomPrize:FindDirect("Group_ItemsGet")
  self.uiObjs.Group_Ten = self.uiObjs.Group_ItemsGet:FindDirect("Group_Ten")
  self.uiObjs.Group_One = self.uiObjs.Group_ItemsGet:FindDirect("Group_One")
  self.uiObjs.Group_No = self.uiObjs.Group_ItemsGet:FindDirect("Group_No")
end
def.method().InitData = function(self)
  local info = LotteryAwardMgr.Instance():GetLotteryInfo()
  self.m_prevItems = info.randomItems
  self.m_lotteryItemInfo = info.lotteryItemInfo
  if self.m_currencyData then
    self.m_currencyData:UnregisterCurrencyChangedEvent(LotteryAwardPanel.OnCurrencyChanged)
  end
  self.m_currencyData = MibaoCurrencyFactory.Create(self.m_lotteryItemInfo.costCurrencyType)
  self.m_currencyData:RegisterCurrencyChangedEvent(LotteryAwardPanel.OnCurrencyChanged)
end
def.method().OnClickPrizeGetTab = function(self)
  self:ShowItemsGetPage({drawCount = 0})
end
def.method().ShowPrizePreviewPage = function(self)
  GUIUtils.Toggle(self.uiObjs.Tab_AllPrize, true)
  local PREVIEW_AWARD_ITEM_NUM = 9
  for i = 1, PREVIEW_AWARD_ITEM_NUM do
    local itemInfo = self.m_prevItems[i]
    self:SetPreviewAwardItemInfo(i, itemInfo)
  end
  self.m_getItems = nil
end
def.method("number", "table").SetPreviewAwardItemInfo = function(self, index, itemInfo)
  local itemObj = self.uiObjs.Group_Items:FindDirect("Img_BgIcon" .. index)
  if itemObj == nil then
    warn(string.format("SetPreviewAwardItemInfo failed: GameObject Img_BgIcon%d not found!", index))
    return
  end
  self:SetItemInfo(itemObj, itemInfo, {})
end
def.method("userdata", "table", "table").SetItemInfo = function(self, itemObj, itemInfo, params)
  if itemInfo == nil or itemInfo.id == 0 then
    GUIUtils.SetActive(itemObj, false)
    return
  else
    GUIUtils.SetActive(itemObj, true)
  end
  local itemId = itemInfo and itemInfo.id or 0
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemName = ""
  local namecolor = 0
  local iconId = 0
  local itemNum = itemInfo and itemInfo.num or ""
  if itemNum == -1 then
    itemNum = ""
  end
  if itemBase then
    itemName = itemBase.name
    namecolor = itemBase.namecolor
    iconId = itemBase.icon
  end
  local Texture_Icon = itemObj:FindDirect("Texture_Icon")
  local Label_Num = itemObj:FindDirect("Label_Num")
  local Label = itemObj:FindDirect("Label")
  GUIUtils.SetTexture(Texture_Icon, iconId)
  GUIUtils.SetText(Label_Num, itemNum)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local color = HtmlHelper.NameColor[namecolor]
  if not params.disable_name_color and color then
    itemName = string.format("[%s]%s[-]", color, itemName)
  end
  GUIUtils.SetText(Label, itemName)
  if not params.disable_name_color then
    GUIUtils.SetItemCellSprite(itemObj, namecolor)
  end
end
def.method("table").ShowItemsGetPage = function(self, params)
  GUIUtils.Toggle(self.uiObjs.Tab_PrizeGet, true)
  local drawCount = params and params.drawCount or 0
  self:ActivateGroupByDrawCount(drawCount)
  if drawCount == DRAW_COUNT_ONE then
    self:ShowOneItemGetView()
  else
    if drawCount == DRAW_COUNT_TEN then
      self:ShowMultiItemsGetView()
    else
    end
  end
end
def.method("number").ActivateGroupByDrawCount = function(self, drawCount)
  GUIUtils.SetActive(self.uiObjs.Group_Ten, drawCount == DRAW_COUNT_TEN)
  GUIUtils.SetActive(self.uiObjs.Group_One, drawCount == DRAW_COUNT_ONE)
  GUIUtils.SetActive(self.uiObjs.Group_No, drawCount == DRAW_COUNT_NONE)
end
def.method().ShowOneItemGetView = function(self)
  if self.m_getItems == nil then
    if GUIUtils.IsToggle(instance.uiObjs.Tab_AllPrize) then
      self:ActivateGroupByDrawCount(DRAW_COUNT_NONE)
    end
    return
  end
  local itemObj = self.uiObjs.Group_One:FindDirect("Img_BgIcon")
  local itemInfo
  if self.m_getItems then
    itemInfo = self.m_getItems[DRAW_COUNT_ONE]
  end
  self:SetItemInfo(itemObj, itemInfo, {})
  local Effect_One = self.uiObjs.Group_One:FindDirect("Effect_One")
  GUIUtils.SetActive(Effect_One, false)
  GUIUtils.SetActive(Effect_One, true)
end
def.method().ShowMultiItemsGetView = function(self)
  if self.m_getItems == nil then
    if GUIUtils.IsToggle(instance.uiObjs.Tab_AllPrize) then
      self:ActivateGroupByDrawCount(DRAW_COUNT_NONE)
    end
    return
  end
  for i = 1, DRAW_COUNT_TEN do
    local itemInfo
    if self.m_getItems then
      itemInfo = self.m_getItems[i]
    end
    local itemObj = self.uiObjs.Group_Ten:FindDirect("Img_BgIcon" .. i)
    self:SetItemInfo(itemObj, itemInfo, {})
  end
  local Effect_Ten = self.uiObjs.Group_Ten:FindDirect("Effect_Ten")
  GUIUtils.SetActive(Effect_Ten, false)
  GUIUtils.SetActive(Effect_Ten, true)
end
def.method().OnBuyBtnClick = function(self)
  if self:CheckBagCapacity() == false then
    return
  end
  if self:CheckInfoDataOk() == false then
    return
  end
  if self:CheckCurrencyEnough(DRAW_COUNT_ONE) == false then
    return
  end
  if self:CheckBuyFinished() == false then
    return
  end
  self:EnableBuyBtns(false)
  self.m_getItems = nil
  self:ShowItemsGetPage({drawCount = DRAW_COUNT_ONE})
  local haveNum = self.m_currencyData:GetHaveNum()
  LotteryAwardMgr.Instance():BuyLotterys(haveNum, DRAW_COUNT_ONE)
end
def.method().OnBuyTenTimesBtnClick = function(self)
  if self:CheckBagCapacity() == false then
    return
  end
  if self:CheckInfoDataOk() == false then
    return
  end
  if self:CheckCurrencyEnough(DRAW_COUNT_TEN) == false then
    return
  end
  if self:CheckBuyFinished() == false then
    return
  end
  self:EnableBuyBtns(false)
  self.m_getItems = nil
  self:ShowItemsGetPage({drawCount = DRAW_COUNT_TEN})
  local haveNum = self.m_currencyData:GetHaveNum()
  LotteryAwardMgr.Instance():BuyLotterys(haveNum, DRAW_COUNT_TEN)
end
def.method("=>", "boolean").CheckInfoDataOk = function(self)
  if LotteryAwardMgr.Instance():HaveInfoData() then
    return true
  end
  Toast(textRes.Mibao[5])
  return false
end
def.method("number", "=>", "boolean").CheckCurrencyEnough = function(self, buyNum)
  local haveNum = self.m_currencyData:GetHaveNum()
  local needNum = Int64.new(self.m_lotteryItemInfo.costCurrencyNum) * Int64.new(buyNum)
  if haveNum < needNum then
    self.m_currencyData:AcquireWithQuery()
    return false
  end
  return true
end
def.method("=>", "boolean").CheckBuyFinished = function(self)
  if self.m_buyBtnEnabled then
    return true
  end
  Toast(textRes.Mibao[4])
  return false
end
def.method("=>", "boolean").CheckBagCapacity = function(self)
  return true
end
def.method("boolean").EnableBuyBtns = function(self, isEnable)
  self.m_buyBtnEnabled = isEnable
end
def.method().SetLotteryItemInfo = function(self)
  local itemObj = self.uiObjs.Group_Buy:FindDirect("Img_BgIcon")
  self:SetItemInfo(itemObj, self.m_lotteryItemInfo, {disable_name_color = true})
  local multiBtn = false
  if LotteryAwardMgr.Instance():CanBuyMultiLotterys() then
    multiBtn = true
  end
  self.uiObjs.Group_Buy:FindDirect("Btn_GoldBuy"):SetActive(not multiBtn)
  self.uiObjs.Group_Buy:FindDirect("Btn_BuyOne"):SetActive(multiBtn)
  self.uiObjs.Group_Buy:FindDirect("Btn_BuyTen"):SetActive(multiBtn)
end
def.method().UpdateCurrencyInfo = function(self)
  local spriteName = self.m_currencyData:GetSpriteName()
  local haveNum = self.m_currencyData:GetHaveNum()
  local needNum = Int64.new(self.m_lotteryItemInfo.costCurrencyNum)
  local Label_Cost = self.uiObjs.Group_Buy:FindDirect("Label_Cost")
  local Label_Num = Label_Cost:FindDirect("Img_BgCost/Label_CostNum")
  local Img_MoneyIcon = Label_Cost:FindDirect("Img_BgCost/Img_MoneyIcon")
  GUIUtils.SetSprite(Img_MoneyIcon, spriteName)
  local Label_Have = self.uiObjs.Group_Buy:FindDirect("Label_Have")
  local Label_HaveNum = Label_Have:FindDirect("Img_BgHave/Label_HaveNum")
  local Img_MoneyIcon = Label_Have:FindDirect("Img_BgHave/Img_MoneyIcon")
  GUIUtils.SetSprite(Img_MoneyIcon, spriteName)
  local text = tostring(needNum)
  GUIUtils.SetText(Label_Num, text)
  GUIUtils.SetText(Label_HaveNum, tostring(haveNum))
end
def.method().UpdateCreditScore = function(self)
  local val = LotteryAwardMgr.Instance():GetCreditScore()
  GUIUtils.SetText(self.uiObjs.Label_Credits_Num, val)
end
def.method().UpdateLuckyPoint = function(self)
  local val = LotteryAwardMgr.Instance():GetLuckyPoint()
  GUIUtils.SetText(self.uiObjs.Label_Luck_Num, val)
end
def.method().OnAddBtnClick = function(self)
  self.m_currencyData:Acquire()
end
def.method().OnExchangeBtnClick = function(self)
  require("Main.Award.ui.LotteryCreditExchangePanel").Instance():ShowPanel()
end
def.static("table", "table").OnCurrencyChanged = function()
  instance:UpdateCurrencyInfo()
end
def.static("table", "table").OnLotteryAwardUpdate = function(params)
  instance:UpdateUI()
  if params and params.random_item_list then
    local items = {}
    for i, itemId in ipairs(params.random_item_list) do
      local itemInfo = {id = itemId, num = 1}
      table.insert(items, itemInfo)
    end
    instance.m_buyBtnEnabled = true
    instance.m_getItems = items
    local drawCount = #items
    instance:ShowItemsGetPage({drawCount = drawCount})
  elseif GUIUtils.IsToggle(instance.uiObjs.Tab_AllPrize) then
    instance:ShowPrizePreviewPage()
  end
end
return LotteryAwardPanel.Commit()

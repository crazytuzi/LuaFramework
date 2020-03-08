local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BaoKuAwardGetPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local LotteryAwardMgr = require("Main.Award.mgr.LotteryAwardMgr")
local MibaoCurrencyFactory = require("Main.Currency.MibaoCurrencyFactory")
local ActivityInterface = require("Main.activity.ActivityInterface")
local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
local def = BaoKuAwardGetPanel.define
local DRAW_COUNT_ONE = 1
local DRAW_COUNT_TEN = 10
local PENDING_WAIT_SECONDS = 1
local FORCE_USE_ITEM_EXCHANGE = LotteryAwardMgr.Instance():IsForceUseExchangeItem()
def.field("table").uiObjs = nil
def.field("table").m_getItems = nil
def.field("boolean").m_buyBtnEnabled = true
def.field("table").m_currencyData = nil
def.field("table").m_currencyDataTen = nil
def.field("table").m_lotteryItemInfo = nil
def.field("table").m_ybLotteryItemInfo = nil
def.field("table").m_exchangeItemInfo = nil
def.field("function").onBuyAgainBtnClick = nil
def.field("number").m_pendingTimer = 0
local instance
def.static("=>", BaoKuAwardGetPanel).Instance = function()
  if instance == nil then
    instance = BaoKuAwardGetPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, getItems)
  self.m_getItems = getItems
  if self.m_panel and not self.m_panel.isnil then
    self:OnReady()
    return
  end
  self.m_TryIncLoadSpeed = true
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_LOTTERY_TIAN_DI_BAO_KU_GET_PANEL, 2)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BaoKuAwardGetPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_MIBAO_FAILED, BaoKuAwardGetPanel.OnDrawAwardFailed)
  self:InitUI()
  self:OnReady()
end
def.method().OnReady = function(self)
  self:UpdateUI()
  LotteryAwardMgr.Instance():CMiBaoAwardFinish()
  ItemModule.Instance():BlockItemGetEffect(false)
  self:RemovePendingTimer()
end
def.method().UpdateUI = function(self)
  self:InitData()
  self:UpdateCurrencyInfo()
  local drawCount = #self.m_getItems
  instance:ShowItemsGetPage({drawCount = drawCount})
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BaoKuAwardGetPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_MIBAO_FAILED, BaoKuAwardGetPanel.OnDrawAwardFailed)
  self.uiObjs = nil
  self.m_buyBtnEnabled = true
  self.m_getItems = nil
  self.m_currencyData = nil
  self.m_currencyDataTen = nil
  self.m_lotteryItemInfo = nil
  self.m_ybLotteryItemInfo = nil
  self.m_exchangeItemInfo = nil
  self:RemovePendingTimer()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Conform" or id == "Modal" then
    self:DestroyPanel()
  elseif string.find(id, "Texture_Icon") then
    self:OnItemBgObjClicked(obj)
  elseif id == "Texture" then
    self:OnItemTexureObjClicked(obj)
  elseif id == "Btn_BuyAgain" then
    self:OnBuyAgainBtnClick()
  end
end
def.method("userdata").OnItemTexureObjClicked = function(self, obj)
  local id = obj.parent.name
  local index = tonumber(string.sub(id, #"Img_Item" + 1, -1))
  if index == nil then
    return
  end
  local itemInfo = self.m_prevItems[index]
  if itemInfo and itemInfo.id then
    local itemId = itemInfo.id
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, obj.parent, 0, false)
  end
end
def.method("userdata").OnItemBgObjClicked = function(self, obj)
  local id = obj.parent.name
  local parent = obj.parent.parent
  local index = tonumber(string.sub(id, #"Img_BgIcon" + 1, -1))
  local itemInfo
  if parent.name == "Group_Items" then
    itemInfo = self.m_getItems[index]
  elseif parent.name == "Group_One" then
    itemInfo = self.m_getItems[1]
  end
  if itemInfo and itemInfo.id then
    local itemId = itemInfo.id
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, obj, 0, false)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Ten = self.uiObjs.Img_Bg0:FindDirect("Group_Ten")
  self.uiObjs.Group_One = self.uiObjs.Img_Bg0:FindDirect("Group_One")
  self.uiObjs.Group_XuYuan = self.uiObjs.Img_Bg0:FindDirect("Group_XuYuan")
end
def.method().InitData = function(self)
  local info = LotteryAwardMgr.Instance():GetLotteryInfo()
  self.m_lotteryItemInfo = info.lotteryItemInfo
  self.m_currencyData = MibaoCurrencyFactory.Create(self.m_lotteryItemInfo.costCurrencyType)
  self.m_exchangeItemInfo = LotteryAwardMgr.Instance():GetExchangeLotteryInfo().lotteryItemInfo
  if not FORCE_USE_ITEM_EXCHANGE then
    local info = LotteryAwardMgr.Instance():GetYuanBaoLotteryInfo()
    self.m_ybLotteryItemInfo = info.lotteryItemInfo
  end
  local ybCurrencyType = CurrencyType.YUAN_BAO
  self.m_currencyDataTen = MibaoCurrencyFactory.Create(ybCurrencyType)
end
def.method("userdata", "table", "table").SetItemInfo = function(self, itemObj, itemInfo, params)
  if itemInfo == nil or itemInfo.id == 0 then
    GUIUtils.SetActive(itemObj, false)
    return
  end
  GUIUtils.SetActive(itemObj, true)
  local Texture_Icon = itemObj:FindDirect("Texture_Icon")
  local Label_Num = itemObj:FindDirect("Label_Num")
  local Label
  if params.ItemLabelName then
    Label = itemObj:FindDirect(params.ItemLabelName)
  else
    Label = itemObj:FindDirect("Label_Name")
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
  local drawCount = params and params.drawCount or 0
  self:ActivateGroupByDrawCount(drawCount)
  if drawCount == DRAW_COUNT_ONE then
    self:ShowOneItemGetView()
  else
    self:ShowMultiItemsGetView()
  end
end
def.method("number").ActivateGroupByDrawCount = function(self, drawCount)
  GUIUtils.SetActive(self.uiObjs.Group_Ten, drawCount ~= DRAW_COUNT_ONE)
  GUIUtils.SetActive(self.uiObjs.Group_One, drawCount == DRAW_COUNT_ONE)
end
def.method().ShowOneItemGetView = function(self)
  if self.m_getItems == nil then
    return
  end
  local itemObj = self.uiObjs.Group_One:FindDirect("Img_BgIcon")
  local itemInfo
  if self.m_getItems then
    itemInfo = self.m_getItems[DRAW_COUNT_ONE]
  end
  self:SetItemInfo(itemObj, itemInfo, {ItemLabelName = "Label_Name"})
  local Effect_One = self.uiObjs.Group_One:FindDirect("Effect_One")
  GUIUtils.SetActive(Effect_One, false)
  GUIUtils.SetActive(Effect_One, true)
end
def.method().ShowMultiItemsGetView = function(self)
  if self.m_getItems == nil then
    return
  end
  local Group_Items = self.uiObjs.Group_Ten:FindDirect("Group_Items")
  for i = 1, DRAW_COUNT_TEN do
    local itemInfo
    if self.m_getItems then
      itemInfo = self.m_getItems[i]
    end
    local itemObj = Group_Items:FindDirect("Img_BgIcon" .. i)
    self:SetItemInfo(itemObj, itemInfo, {})
  end
  local Effect_Ten = self.uiObjs.Group_Ten:FindDirect("Effect_Ten")
  GUIUtils.SetActive(Effect_Ten, false)
  GUIUtils.SetActive(Effect_Ten, true)
end
def.method().UpdateCurrencyInfo = function(self)
  local spriteName = ""
  local discount = 1
  local drawCount = 1
  local GroupGO
  local needNum = 0
  local isExchange = false
  local isFree = false
  if #self.m_getItems == DRAW_COUNT_ONE then
    GroupGO = self.uiObjs.Group_One
    isFree = self.m_lotteryItemInfo.costCurrencyType == CurrencyType.FREE
    if isFree then
      needNum = 0
    else
      isExchange = FORCE_USE_ITEM_EXCHANGE or LotteryAwardMgr.Instance():CheckExchangeItemEnough(DRAW_COUNT_ONE)
      if isExchange then
        needNum = self.m_exchangeItemInfo.costCurrencyNum
      else
        needNum = self.m_lotteryItemInfo.costCurrencyNum
        spriteName = self.m_currencyData:GetSpriteName()
        if spriteName == "" then
          spriteName = "nil"
        end
      end
    end
  else
    GroupGO = self.uiObjs.Group_Ten
    isExchange = FORCE_USE_ITEM_EXCHANGE or LotteryAwardMgr.Instance():CheckExchangeItemEnough(DRAW_COUNT_TEN)
    if isExchange then
      needNum = self.m_exchangeItemInfo.costCurrencyNum
    else
      needNum = self.m_ybLotteryItemInfo.costCurrencyNum
    end
    discount = LotteryAwardMgr.Instance():GetBaoKuDiscount()
    drawCount = DRAW_COUNT_TEN
    spriteName = self.m_currencyDataTen:GetSpriteName()
  end
  local Btn_BuyAgain = GroupGO:FindDirect("Btn_BuyAgain")
  local Img_Icon = Btn_BuyAgain:FindDirect("Img_Icon")
  local Icon_Exchange = Btn_BuyAgain:FindDirect("Icon_Exchange")
  local Label_Num = Btn_BuyAgain:FindDirect("Label_Num")
  local totalNeedNum = require("Common.MathHelper").Floor(needNum * drawCount * discount)
  if totalNeedNum == 0 then
    totalNeedNum = ""
  end
  Img_Icon:SetActive(not isFree and not isExchange)
  if not isFree and not isExchange then
    GUIUtils.SetSprite(Img_Icon, spriteName)
  end
  Icon_Exchange:SetActive(isExchange)
  if isExchange then
    local itemBase = ItemUtils.GetItemBase(LotteryAwardMgr.Instance():GetExchangeItemId())
    GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), itemBase.icon)
  end
  GUIUtils.SetText(Label_Num, totalNeedNum)
end
def.method().OnAddBtnClick = function(self)
  self.m_currencyData:Acquire()
end
def.method().OnBuyAgainBtnClick = function(self)
  local buyNum = #self.m_getItems
  local ret = false
  if self.onBuyAgainBtnClick then
    ret = self.onBuyAgainBtnClick(buyNum)
  end
  if ret == true then
    self:AddPendingTimer()
  end
end
def.method().AddPendingTimer = function(self)
  self:RemovePendingTimer()
  self.m_pendingTimer = GameUtil.AddGlobalTimer(PENDING_WAIT_SECONDS, true, function()
    self:OnPending()
  end)
end
def.method().RemovePendingTimer = function(self)
  if self.m_pendingTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_pendingTimer)
    self.m_pendingTimer = 0
  end
  if self.uiObjs then
    GUIUtils.SetActive(self.uiObjs.Group_XuYuan, false)
  end
end
def.method().OnPending = function(self)
  if self.uiObjs == nil then
    return
  end
  GUIUtils.SetActive(self.uiObjs.Group_XuYuan, true)
end
def.static("table", "table").OnBagInfoSynchronized = function()
  instance:UpdateCurrencyInfo()
end
def.static("table", "table").OnDrawAwardFailed = function()
  instance:RemovePendingTimer()
end
return BaoKuAwardGetPanel.Commit()

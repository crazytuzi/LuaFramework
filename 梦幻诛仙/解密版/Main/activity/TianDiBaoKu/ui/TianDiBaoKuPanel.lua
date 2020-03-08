local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TianDiBaoKuPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local LotteryAwardMgr = require("Main.Award.mgr.LotteryAwardMgr")
local MibaoCurrencyFactory = require("Main.Currency.MibaoCurrencyFactory")
local ActivityInterface = require("Main.activity.ActivityInterface")
local CellColorType = require("consts.mzm.gsp.mibao.confbean.CellColorType")
local CellItemState = require("consts.mzm.gsp.mibao.confbean.CellItemState")
local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
local ECSoundMan = require("Sound.ECSoundMan")
local DynamicText = require("Utility.DynamicText")
local def = TianDiBaoKuPanel.define
local ColorTypeToSpriteName = {
  [CellColorType.GREEN] = "UI_ChouJiang_100X100_Green",
  [CellColorType.BLUE] = "UI_ChouJiang_100X100_Blue",
  [CellColorType.PURPLE] = "UI_ChouJiang_100X100_Purple",
  [CellColorType.ORANGE] = "UI_ChouJiang_100X100_Orange"
}
local DRAW_COUNT_NONE = 0
local DRAW_COUNT_ONE = 1
local DRAW_COUNT_TEN = 10
local PREVIEW_AWARD_ITEM_NUM = 12
local PENDING_WAIT_SECONDS = 1
local FORCE_USE_ITEM_EXCHANGE = LotteryAwardMgr.Instance():IsForceUseExchangeItem()
local PRICE_UNKONW = -1
def.field("table").uiObjs = nil
def.field("table").m_prevItems = nil
def.field("table").m_getItems = nil
def.field("table").m_lotteryItemInfo = nil
def.field("table").m_ybLotteryItemInfo = nil
def.field("table").m_exchangeItemInfo = nil
def.field("boolean").m_buyBtnEnabled = true
def.field("table").m_currencyData = nil
def.field("table").m_currencyDataTen = nil
def.field("number").m_countdownTimeId1 = 0
def.field("number").m_countdownTimeId2 = 0
def.field("function").onUIReady = nil
def.field("table").m_aniState = nil
def.field("boolean").m_drawingClose = false
def.field("boolean").m_skipAni = true
def.field("number").m_pendingTimer = 0
def.field("boolean").m_autoBuy = true
def.field("table").m_dynamicTextEnv = nil
def.field("number").m_exchangeItemPrice = PRICE_UNKONW
def.field("boolean").m_priceReqing = false
def.field("table").m_lastBuyInfo = nil
local instance
def.static("=>", TianDiBaoKuPanel).Instance = function()
  if instance == nil then
    instance = TianDiBaoKuPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, TianDiBaoKuPanel.OnLotteryAwardUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_MIBAO_FAILED, TianDiBaoKuPanel.OnDrawAwardFailed)
end
def.method().ShowPanel = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  LotteryAwardMgr.Instance():CheckInfoData()
  self:PreQuery()
  self.m_TryIncLoadSpeed = true
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_LOTTERY_TIAN_DI_BAO_KU_PANEL, 1)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateUI()
  self:ShowPrizePreviewPage()
  local isEnd = self:UpdateActivityCloseCountDown()
  if isEnd then
    return
  end
  self:UpdateFreeLotteryCountDown()
  self:StartCountDownTimer()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TianDiBaoKuPanel.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TianDiBaoKuPanel.OnBagInfoSynchronized)
end
def.override().AfterCreate = function(self)
  if LotteryAwardMgr.Instance():IsActivityOpen() == false then
    self:DestroyPanel()
    return
  end
  if self.onUIReady then
    self.onUIReady()
  end
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:DestroyDrawingFX()
  end
end
def.method().DestroyDrawingFX = function(self)
  for i = 1, PREVIEW_AWARD_ITEM_NUM do
    local Img_Item = self.uiObjs.Group_Items:FindDirect("Img_Item" .. i)
    if Img_Item then
      local DrawingFX = Img_Item:FindDirect("DrawingFX")
      if DrawingFX then
        GameObject.DestroyImmediate(DrawingFX)
      end
    end
  end
end
def.method().StartCountDownTimer = function(self)
end
def.method().StopCountDownTimer = function(self)
  if self.m_countdownTimeId1 ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_countdownTimeId1)
    self.m_countdownTimeId1 = 0
  end
  if self.m_countdownTimeId2 ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_countdownTimeId2)
    self.m_countdownTimeId2 = 0
  end
end
def.method().UpdateUI = function(self)
  self:InitData()
  self:UpdateCurrencyInfo()
  self:UpdateCreditScore()
  self:UpdateAutoBuyGroup()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TianDiBaoKuPanel.OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TianDiBaoKuPanel.OnBagInfoSynchronized)
  self.uiObjs = nil
  self.m_buyBtnEnabled = true
  ItemModule.Instance():BlockItemGetEffect(false)
  if self.m_currencyDataTen then
    self.m_currencyDataTen:UnregisterCurrencyChangedEvent(TianDiBaoKuPanel.OnCurrencyChanged)
  end
  self.m_currencyDataTen = nil
  self.m_prevItems = nil
  self.m_lotteryItemInfo = nil
  self.m_ybLotteryItemInfo = nil
  self.m_exchangeItemInfo = nil
  self.m_getItems = nil
  self.m_currencyData = nil
  self.onUIReady = nil
  self:FinishDrawingAnimation()
  self:StopCountDownTimer()
  self.m_drawingClose = false
  self:RemovePendingTimer()
  self.m_exchangeItemPrice = PRICE_UNKONW
  self.m_priceReqing = false
  self.m_dynamicTextEnv = nil
  self.m_lastBuyInfo = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tab_AllPrize" then
    self:ShowPrizePreviewPage()
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
  elseif id == "Texture" then
    self:OnItemTexureObjClicked(obj)
  elseif id == "Btn_Tip" then
    self:OnBtnTipClick()
  elseif id == "Img_UseGold" then
    self:OnAutoBuyToggleClick()
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
  self.uiObjs.Group_Top = self.uiObjs.Group_RandomPrize:FindDirect("Group_Top")
  self.uiObjs.Group_Items = self.uiObjs.Group_RandomPrize:FindDirect("Group_Items")
  self.uiObjs.Group_Center = self.uiObjs.Group_RandomPrize:FindDirect("Group_Center")
  self.uiObjs.Group_Bottom = self.uiObjs.Group_RandomPrize:FindDirect("Group_Bottom")
  self.uiObjs.Group_End = self.uiObjs.Group_RandomPrize:FindDirect("Group_End")
  self.uiObjs.Group_Btn = self.uiObjs.Group_RandomPrize:FindDirect("Group_Btn")
  self.uiObjs.Group_Title = self.uiObjs.Group_RandomPrize:FindDirect("Group_Title")
  self.uiObjs.Group_XuYuan = self.m_panel:FindDirect("Group_XuYuan")
  self.uiObjs.Group_AutoBuy = self.uiObjs.Group_RandomPrize:FindDirect("Group_AutoBuy")
  self.uiObjs.Label_LeftTimeName = self.uiObjs.Group_Top:FindDirect("Label")
  self.uiObjs.Label_Credits_Num = self.uiObjs.Group_Top:FindDirect("Label_Credits/Label_Num")
  self.uiObjs.Widget_Effect = self.m_panel:FindDirect("Widget_Effect")
  self.uiObjs.Widget_Effects = {}
  for i, v in ipairs(ColorTypeToSpriteName) do
    local widget_Effect = self.uiObjs.Widget_Effect:FindDirect(v)
    self.uiObjs.Widget_Effects[i] = widget_Effect
  end
  GUIUtils.SetActive(self.uiObjs.Widget_Effect, false)
end
def.method().InitData = function(self)
  local info = LotteryAwardMgr.Instance():GetLotteryInfo()
  self.m_prevItems = info.randomItems
  self.m_lotteryItemInfo = info.lotteryItemInfo
  if not FORCE_USE_ITEM_EXCHANGE then
    self.m_ybLotteryItemInfo = LotteryAwardMgr.Instance():GetYuanBaoLotteryInfo().lotteryItemInfo
  end
  self.m_exchangeItemInfo = LotteryAwardMgr.Instance():GetExchangeLotteryInfo().lotteryItemInfo
  local currencyType = self.m_lotteryItemInfo.costCurrencyType
  self.m_currencyData = MibaoCurrencyFactory.Create(currencyType)
  if self.m_currencyDataTen == nil then
    local currencyType = CurrencyType.YUAN_BAO
    if not FORCE_USE_ITEM_EXCHANGE then
      currencyType = self.m_ybLotteryItemInfo.costCurrencyType
    end
    self.m_currencyDataTen = MibaoCurrencyFactory.Create(currencyType)
    self.m_currencyDataTen:RegisterCurrencyChangedEvent(TianDiBaoKuPanel.OnCurrencyChanged)
  end
end
def.method().ShowPrizePreviewPage = function(self)
  for i = 1, PREVIEW_AWARD_ITEM_NUM do
    local itemInfo = self.m_prevItems[i]
    self:SetPreviewAwardItemInfo(i, itemInfo)
  end
  self.m_getItems = nil
end
def.method("number", "table").SetPreviewAwardItemInfo = function(self, index, itemInfo)
  local itemObj = self.uiObjs.Group_Items:FindDirect("Img_Item" .. index)
  if itemObj == nil then
    warn(string.format("SetPreviewAwardItemInfo failed: GameObject Img_Item%d not found!", index))
    return
  end
  self:SetItemInfo(itemObj, itemInfo, {})
end
def.method("userdata", "table", "table").SetItemInfo = function(self, itemObj, itemInfo, params)
  local Texture_Icon = itemObj:FindDirect("Texture")
  local Label_Num = itemObj:FindDirect("Label_Num")
  local Label = itemObj:FindDirect("Label")
  local Bg_Item = itemObj:FindDirect("Bg_Item")
  if itemInfo == nil or itemInfo.id == 0 then
    GUIUtils.SetActive(Texture_Icon, false)
    GUIUtils.SetActive(Label, false)
    GUIUtils.SetActive(Bg_Item, false)
    return
  end
  GUIUtils.SetActive(Texture_Icon, true)
  GUIUtils.SetActive(Label, false)
  GUIUtils.SetActive(Bg_Item, true)
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
  if not params.disable_name_color then
    GUIUtils.SetItemCellSprite(Bg_Item, namecolor)
  end
  local function createEffectGO(Effect_Cell, colorType)
    local template = self.uiObjs.Widget_Effects[colorType] or nil
    local EffectGO
    if template then
      EffectGO = GameObject.Instantiate(template)
    else
      EffectGO = GameObject.GameObject()
      EffectGO:SetLayer(ClientDef_Layer.UI)
    end
    EffectGO.parent = Effect_Cell
    EffectGO.localPosition = Vector.Vector3.zero
    EffectGO.localScale = Vector.Vector3.one
    EffectGO.name = tostring(itemInfo.color)
    EffectGO:SetActive(true)
    local uiParticle = Effect_Cell:GetComponent("UIParticle")
    uiParticle:set_modelGameObject(EffectGO)
  end
  local Effect_Cell = itemObj:FindDirect("Effect_Cell")
  if Effect_Cell == nil then
    local Effect_Cell = GameObject.GameObject("Effect_Cell")
    Effect_Cell:SetLayer(ClientDef_Layer.UI)
    Effect_Cell.parent = itemObj
    Effect_Cell.localPosition = Vector.Vector3.zero
    Effect_Cell.localScale = Vector.Vector3.new(1.2, 1.2, 1)
    local uiParticle = Effect_Cell:AddComponent("UIParticle")
    local depth = itemObj:GetComponent("UIWidget").depth
    uiParticle:set_depth(depth + 1)
    uiParticle:set_width(2)
    uiParticle:set_height(2)
    uiParticle:SetCliping(true)
    createEffectGO(Effect_Cell, itemInfo.color)
  else
    local EffectGO = Effect_Cell:GetChild(0)
    if EffectGO.name ~= tostring(itemInfo.color) then
      GameObject.DestroyImmediate(EffectGO)
      createEffectGO(Effect_Cell, itemInfo.color)
    end
  end
  local function isRare(itemState)
    return itemState == CellItemState.RARE
  end
  local Img_Rare = itemObj:FindDirect("Img_Rare")
  GUIUtils.SetActive(Img_Rare, isRare(itemInfo.state))
end
def.method("=>", "boolean").OnBuyBtnClick = function(self)
  if self:CheckBuyFinished() == false then
    return false
  end
  if self:CheckBagCapacity(DRAW_COUNT_ONE) == false then
    return false
  end
  if self:CheckInfoDataOk() == false then
    return false
  end
  if self:CheckCurrencyEnough(DRAW_COUNT_ONE) == false then
    return false
  end
  self:PlayDrawingAnimation()
  self:EnableBuyBtns(false)
  self.m_getItems = nil
  local haveNum = self.m_currencyData:GetHaveNum()
  local useType = self:GetBuyLotteryUseType()
  LotteryAwardMgr.Instance():BuyLotterysEx(haveNum, DRAW_COUNT_ONE, {
    useType = useType,
    item_price = self.m_exchangeItemPrice
  })
  return true
end
def.method("=>", "boolean").OnBuyTenTimesBtnClick = function(self)
  if self:CheckBuyFinished() == false then
    return false
  end
  if self:CheckBagCapacity(DRAW_COUNT_TEN) == false then
    return false
  end
  if self:CheckInfoDataOk() == false then
    return false
  end
  if self:CheckCurrencyEnough(DRAW_COUNT_TEN) == false then
    return false
  end
  self:PlayDrawingAnimation()
  self:EnableBuyBtns(false)
  self.m_getItems = nil
  local haveNum = self.m_currencyDataTen:GetHaveNum()
  local useType = self:GetBuyLotteryUseType()
  LotteryAwardMgr.Instance():BuyLotterysEx(haveNum, DRAW_COUNT_TEN, {
    useType = useType,
    item_price = self.m_exchangeItemPrice
  })
  return true
end
def.method("=>", "number").GetBuyLotteryUseType = function(self)
  if self.m_autoBuy then
    return LotteryAwardMgr.USE_YUAN_BAO
  else
    return LotteryAwardMgr.NOT_USE_YUAN_BAO
  end
end
local maxInterval = 0.08
local slowDownThrehold = 1
local stopThreholdInterval = 0.08
local intervalStep = 0.005
def.method().PlayDrawingAnimation = function(self, callback)
  if self.m_skipAni then
    return
  end
  if self.m_aniState then
    return
  end
  self.m_aniState = {
    timerId = 0,
    stopIndex = nil,
    finishcallback = nil
  }
  local jumpInterval = 0.01
  local index = 1
  local timeCount = 0
  local startTime = GameUtil.GetTickCount()
  local function run(...)
    if self.m_aniState == nil then
      return
    end
    self.m_aniState.timerId = GameUtil.AddGlobalTimer(jumpInterval, true, function(...)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      if self.m_aniState == nil then
        return
      end
      local go = self.uiObjs.Group_Items:FindDirect("Img_Item" .. index)
      if go == nil then
        index = 1
        go = self.uiObjs.Group_Items:FindDirect("Img_Item" .. index)
      end
      if go then
        local objname = "DrawingFX"
        local fx = require("Fx.GUIFxMan").Instance():PlayAsChildLayer(go, RESPATH.WABAO_EFFECT, objname, -8, 20, 1, 1, -1, false)
        ECSoundMan.Instance():Play2DSound(RESPATH.SOUND_ROUND)
        local curTime = GameUtil.GetTickCount()
        timeCount = (curTime - startTime) / 1000
        if timeCount > slowDownThrehold then
          jumpInterval = jumpInterval + intervalStep
          if jumpInterval >= maxInterval then
            jumpInterval = maxInterval
          end
          if index == self.m_aniState.stopIndex and jumpInterval >= stopThreholdInterval then
            self:FinishDrawingAnimation()
            return
          end
        end
        index = index + 1
        run()
      end
    end)
  end
  run()
end
def.method("number", "function").FinishDrawingAnimationInPos = function(self, index, callback)
  if self.m_aniState == nil then
    callback()
    return
  end
  self.m_aniState.stopIndex = index
  self.m_aniState.finishcallback = callback
end
def.method().FinishDrawingAnimation = function(self)
  local finishcallback
  if self.m_aniState then
    finishcallback = self.m_aniState.finishcallback
    local timerId = self.m_aniState.timerId
    if timerId and timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(timerId)
    end
  end
  self.m_aniState = nil
  if finishcallback then
    finishcallback()
  end
end
def.method().AbortDrawingAnimation = function(self)
  if self.m_aniState then
    local timerId = self.m_aniState.timerId
    if timerId and timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(timerId)
    end
  end
  self.m_aniState = nil
end
def.method("=>", "boolean").CheckInfoDataOk = function(self)
  if LotteryAwardMgr.Instance():HaveInfoData() and self.m_exchangeItemPrice ~= PRICE_UNKONW then
    return true
  end
  Toast(textRes.Mibao[5])
  return false
end
def.method("number", "=>", "boolean").CheckCurrencyEnough = function(self, buyNum)
  if buyNum == DRAW_COUNT_ONE and self.m_lotteryItemInfo.costCurrencyType == CurrencyType.FREE then
    self.m_lastBuyInfo = nil
    return true
  end
  local inst = LotteryAwardMgr.Instance()
  local needNum = inst:GetNeededExchangeItemNum(buyNum)
  if inst:CheckExchangeItemEnough(buyNum) then
    self.m_lastBuyInfo = {useItemNum = needNum, useYuanbaoNum = 0}
    return true
  end
  if self.m_autoBuy then
    do
      local haveNum = inst:GetExchangeItemCount()
      local lackNum = math.max(0, needNum - haveNum)
      local needYuanbao = lackNum * self.m_exchangeItemPrice
      local currencyData = self.m_currencyDataTen
      local haveYuanbao = currencyData:GetHaveNum()
      if haveYuanbao:ge(needYuanbao) then
        self.m_lastBuyInfo = {
          useItemNum = needNum,
          useYuanbaoNum = needYuanbao,
          buyItemNum = lackNum
        }
        return true
      end
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local desc = self:GetDynamicText(textRes.Mibao[23])
      desc = desc:format(lackNum, needYuanbao)
      CommonConfirmDlg.ShowConfirm(textRes.Common[8], desc, function(s)
        if self.m_panel == nil or self.m_panel.isnil then
          return
        end
        if s == 1 then
          currencyData:Acquire()
        end
      end, nil)
      return false
    end
  else
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local desc = self:GetDynamicText(textRes.Mibao[20])
    CommonConfirmDlg.ShowConfirm(textRes.Mibao[21], desc, function(s)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      if s == 1 then
        self:SetAutoBuy(true)
      end
    end, nil)
    return false
  end
end
def.method("=>", "boolean").CheckBuyFinished = function(self)
  if self.m_buyBtnEnabled then
    return true
  end
  Toast(textRes.Mibao[4])
  return false
end
def.method("number", "=>", "boolean").CheckBagCapacity = function(self, drawCount)
  return true
end
def.method("boolean").EnableBuyBtns = function(self, isEnable)
  self.m_buyBtnEnabled = isEnable
  if isEnable then
    self:RemovePendingTimer()
  else
    self:AddPendingTimer()
  end
end
def.method().UpdateCurrencyInfo = function(self)
  local needNum = self.m_lotteryItemInfo.costCurrencyNum
  local Group_Gold = self.uiObjs.Group_Btn:FindDirect("Group_Gold")
  local Btn_BuyOne = self.uiObjs.Group_Btn:FindDirect("Btn_BuyOne")
  local Btn_BuyTen = self.uiObjs.Group_Btn:FindDirect("Btn_BuyTen")
  local isFree = false
  if self.m_lotteryItemInfo.costCurrencyType == CurrencyType.FREE then
    isFree = true
  end
  local isExchange = false
  local itemCount = LotteryAwardMgr.Instance():GetExchangeItemCount()
  if itemCount >= self.m_exchangeItemInfo.costCurrencyNum then
    isExchange = true
  end
  if FORCE_USE_ITEM_EXCHANGE then
    isExchange = true
  end
  GUIUtils.SetActive(Group_Gold, isFree)
  GUIUtils.SetActive(Btn_BuyOne, not isFree)
  if isFree then
    local Btn_GoldBuy = Group_Gold:FindDirect("Btn_GoldBuy")
    GUIUtils.SetLightEffect(Btn_GoldBuy, GUIUtils.Light.Square)
    local Label_Num = Group_Gold:FindDirect("Label_Left/Label_Num")
    local leftTimes = LotteryAwardMgr.Instance():GetLeftFreeTimes()
    GUIUtils.SetText(Label_Num, leftTimes)
  elseif isExchange then
    local Img_Icon = Btn_BuyOne:FindDirect("Img_Icon")
    local Icon_Exchange = Btn_BuyOne:FindDirect("Icon_Exchange")
    local Label_Num = Btn_BuyOne:FindDirect("Label_Num")
    GUIUtils.SetActive(Img_Icon, false)
    GUIUtils.SetActive(Icon_Exchange, true)
    local itemBase = ItemUtils.GetItemBase(LotteryAwardMgr.Instance():GetExchangeItemId())
    GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), itemBase.icon)
    local needNum = self.m_exchangeItemInfo.costCurrencyNum
    GUIUtils.SetText(Label_Num, needNum)
  else
    local Img_Icon = Btn_BuyOne:FindDirect("Img_Icon")
    local Icon_Exchange = Btn_BuyOne:FindDirect("Icon_Exchange")
    local Label_Num = Btn_BuyOne:FindDirect("Label_Num")
    GUIUtils.SetActive(Img_Icon, true)
    GUIUtils.SetActive(Icon_Exchange, false)
    local spriteName = self.m_currencyData:GetSpriteName()
    GUIUtils.SetSprite(Img_Icon, spriteName)
    GUIUtils.SetText(Label_Num, needNum)
  end
  local Img_BgHave = self.uiObjs.Group_Bottom:FindDirect("Img_BgHave")
  if FORCE_USE_ITEM_EXCHANGE then
    Img_BgHave:SetActive(false)
  else
    Img_BgHave:SetActive(true)
    local Label_HaveNum = Img_BgHave:FindDirect("Label_HaveNum")
    local Img_MoneyIcon = Img_BgHave:FindDirect("Img_MoneyIcon")
    local spriteName = self.m_currencyDataTen:GetSpriteName()
    local haveNum = self.m_currencyDataTen:GetHaveNum()
    GUIUtils.SetSprite(Img_MoneyIcon, spriteName)
    GUIUtils.SetText(Label_HaveNum, tostring(haveNum))
  end
  local Img_ExchangeHave = self.uiObjs.Group_Bottom:FindDirect("Img_ExchangeHave")
  GUIUtils.SetActive(Img_ExchangeHave, isExchange)
  if isExchange then
    local Label_HaveNum = Img_ExchangeHave:FindDirect("Label_HaveNum")
    local Icon_Exchange = Img_ExchangeHave:FindDirect("Icon_Exchange")
    local num = itemCount
    GUIUtils.SetText(Label_HaveNum, num)
    local itemBase = ItemUtils.GetItemBase(LotteryAwardMgr.Instance():GetExchangeItemId())
    local icon = itemBase and itemBase.icon or 0
    GUIUtils.SetTexture(Icon_Exchange, icon)
  end
  local Img_Icon = Btn_BuyTen:FindDirect("Img_Icon")
  local Label_Num = Btn_BuyTen:FindDirect("Label_Num")
  local Icon_Exchange = Btn_BuyTen:FindDirect("Icon_Exchange")
  local DISCOUNT = LotteryAwardMgr.Instance():GetBaoKuDiscount()
  local totalNeedNum = self.m_exchangeItemInfo.costCurrencyNum * DRAW_COUNT_TEN * DISCOUNT
  if itemCount >= totalNeedNum or FORCE_USE_ITEM_EXCHANGE then
    GUIUtils.SetActive(Img_Icon, false)
    GUIUtils.SetActive(Icon_Exchange, true)
    local itemBase = ItemUtils.GetItemBase(LotteryAwardMgr.Instance():GetExchangeItemId())
    GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), itemBase.icon)
  else
    totalNeedNum = self.m_ybLotteryItemInfo.costCurrencyNum * DRAW_COUNT_TEN * DISCOUNT
    GUIUtils.SetActive(Img_Icon, true)
    GUIUtils.SetActive(Icon_Exchange, false)
    local spriteName = self.m_currencyDataTen:GetSpriteName()
    GUIUtils.SetSprite(Img_Icon, spriteName)
  end
  totalNeedNum = require("Common.MathHelper").Floor(totalNeedNum)
  GUIUtils.SetText(Label_Num, totalNeedNum)
  local Img_JiuZhe = Btn_BuyTen:FindDirect("Img_JiuZhe")
  if DISCOUNT < 1 then
    GUIUtils.SetActive(Img_JiuZhe, true)
  else
    GUIUtils.SetActive(Img_JiuZhe, false)
  end
end
def.method().UpdateCreditScore = function(self)
  local val = LotteryAwardMgr.Instance():GetCreditScore()
  GUIUtils.SetText(self.uiObjs.Label_Credits_Num, val)
end
def.method("=>", "boolean").UpdateActivityCloseCountDown = function(self)
  local LabelCountDown = self.uiObjs.Group_Top:FindDirect("Label/Label")
  local activityId = LotteryAwardMgr.Instance():GetTianDiBaoKuActivityId()
  local beginTime, _, endTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  local ONE_DAY_SECONDS = 86400
  local aheadEndSeconds = LotteryAwardMgr.Instance():GetBaoKuAheadEndDays() * ONE_DAY_SECONDS
  local aheadEndTime = endTime - aheadEndSeconds
  local curTime = _G.GetServerTime()
  local leftTime = aheadEndTime - curTime
  leftTime = math.max(0, leftTime)
  if leftTime == 0 then
    self:SetCloseState(true)
    leftTime = endTime - curTime
    leftTime = math.max(0, leftTime)
  else
    self:SetCloseState(false)
  end
  local text = _G.SeondsToTimeText(leftTime)
  GUIUtils.SetText(LabelCountDown, text)
  local tickInterval = 0
  if leftTime > 120 then
    tickInterval = 60
  elseif leftTime > 0 then
    tickInterval = 1
  end
  if leftTime == 0 then
    Toast(textRes.Mibao[10])
    self:DestroyExchangePanel()
    self:DestroyPanel()
    return true
  end
  self.m_countdownTimeId1 = GameUtil.AddGlobalTimer(tickInterval, true, function()
    if self.uiObjs == nil then
      return
    end
    self:UpdateActivityCloseCountDown()
  end)
  return false
end
def.method().UpdateFreeLotteryCountDown = function(self)
  if self.m_drawingClose then
    return
  end
  local LabelCountDown = self.uiObjs.Group_Btn:FindDirect("Btn_BuyOne/Label")
  local leftTime = _G.GetTodayRemainSeconds()
  leftTime = math.max(0, leftTime)
  local text = _G.SeondsToTimeText(leftTime)
  text = string.format(textRes.Mibao[7], text)
  GUIUtils.SetText(LabelCountDown, text)
  local activityId = LotteryAwardMgr.Instance():GetTianDiBaoKuActivityId()
  local endTime = ActivityInterface.GetActivityEndingTime(activityId)
  local remainTime = endTime - _G.GetServerTime()
  local tickInterval = 1
  if leftTime > 120 then
    tickInterval = 60
  end
  self.m_countdownTimeId2 = GameUtil.AddGlobalTimer(tickInterval, true, function()
    if self.uiObjs == nil then
      return
    end
    self:UpdateFreeLotteryCountDown()
  end)
end
def.method("boolean").SetCloseState = function(self, isClose)
  GUIUtils.SetActive(self.uiObjs.Group_End, isClose)
  GUIUtils.SetActive(self.uiObjs.Group_Btn, not isClose)
  local leftTimeName = textRes.Mibao[8]
  if isClose then
    leftTimeName = textRes.Mibao[9]
  end
  GUIUtils.SetText(self.uiObjs.Label_LeftTimeName, leftTimeName)
  self.m_drawingClose = isClose
end
def.method().OnAddBtnClick = function(self)
  if FORCE_USE_ITEM_EXCHANGE then
    local itemId = LotteryAwardMgr.Instance():GetExchangeItemId()
    local MallPanel = require("Main.Mall.ui.MallPanel")
    local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Treasure, itemId, MallType.PRECIOUS_MALL)
  else
    self.m_currencyDataTen:Acquire()
  end
end
def.method().OnExchangeBtnClick = function(self)
  require("Main.Award.ui.LotteryCreditExchangePanel").Instance():ShowPanel()
end
def.method().DestroyExchangePanel = function(self)
  require("Main.Award.ui.LotteryCreditExchangePanel").Instance():DestroyPanel()
end
def.method().OnBtnTipClick = function(self)
  local tipId = _G.constant.BaoKuConsts.describeTipsId1 or 0
  GUIUtils.ShowHoverTip(tipId, 0, 0)
end
def.method().OnAutoBuyToggleClick = function(self)
  if self:CheckInfoDataOk() == false then
    return
  end
  local Img_UseGold = self.uiObjs.Group_AutoBuy:FindDirect("Img_UseGold")
  GUIUtils.Toggle(Img_UseGold, self.m_autoBuy)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  if not self.m_autoBuy then
    local desc = self:GetDynamicText(textRes.Mibao[15])
    CommonConfirmDlg.ShowConfirm(textRes.Mibao[21], desc, function(s)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      if s == 1 then
        self:SetAutoBuy(true)
      end
    end, nil)
  else
    self:SetAutoBuy(false)
  end
end
def.method("boolean").SetAutoBuy = function(self, isSet)
  local function toggle(isChecked)
    local Img_UseGold = self.uiObjs.Group_AutoBuy:FindDirect("Img_UseGold")
    GUIUtils.Toggle(Img_UseGold, isChecked)
    self.m_autoBuy = isChecked
  end
  toggle(isSet)
  local text
  if isSet then
    text = self:GetDynamicText(textRes.Mibao[16])
  else
    text = self:GetDynamicText(textRes.Mibao[17])
  end
  Toast(text)
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
def.method().UpdateAutoBuyGroup = function(self)
  local canShow = self.m_exchangeItemPrice ~= PRICE_UNKONW
  GUIUtils.SetActive(self.uiObjs.Group_AutoBuy, canShow)
  if not canShow then
    return
  end
  local Img_UseGold = self.uiObjs.Group_AutoBuy:FindDirect("Img_UseGold")
  GUIUtils.Toggle(Img_UseGold, self.m_autoBuy)
  local Label_Tip2 = self.uiObjs.Group_AutoBuy:FindDirect("Label_Tip2")
  GUIUtils.SetText(Label_Tip2, self:GetDynamicText(textRes.Mibao[22]))
end
def.method("string", "=>", "string").GetDynamicText = function(self, formatText)
  if self.m_dynamicTextEnv == nil then
    self:InitDynamicTextEnv()
  end
  local textFunc = DynamicText.compile(formatText, self.m_dynamicTextEnv)
  return textFunc()
end
def.method().InitDynamicTextEnv = function(self)
  self.m_dynamicTextEnv = {}
  local itemId = LotteryAwardMgr.Instance():GetExchangeItemId()
  local itemBase = ItemUtils.GetItemBase(itemId)
  if not itemBase or not itemBase.name then
  end
  self.m_dynamicTextEnv.exchange_item_name = tostring(itemId)
  self.m_dynamicTextEnv.exchange_item_price = self.m_exchangeItemPrice
end
def.method().PreQuery = function(self)
  if FORCE_USE_ITEM_EXCHANGE then
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    local itemId = LotteryAwardMgr.Instance():GetExchangeItemId()
    self.m_priceReqing = true
    ItemConsumeHelper.Instance():GetItemYuanBaoPrice(itemId, function(price)
      if self.m_priceReqing then
        self.m_exchangeItemPrice = price
      end
      if self.m_dynamicTextEnv ~= nil then
        self:InitDynamicTextEnv()
      end
      if self.m_panel then
        self:UpdateAutoBuyGroup()
      end
    end)
  end
end
def.static("table", "table").OnCurrencyChanged = function()
  instance:UpdateCurrencyInfo()
end
def.static("table", "table").OnBagInfoSynchronized = function()
  instance:UpdateCurrencyInfo()
end
def.static("table", "table").OnDrawAwardFailed = function(params)
  instance.m_lastBuyInfo = nil
  if instance.m_panel and not instance.m_panel.isnil then
    instance:AbortDrawingAnimation()
    instance:EnableBuyBtns(true)
  end
end
def.static("table", "table").OnLotteryAwardUpdate = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateUI()
  end
  if params and params.random_item_list then
    do
      local function showResult(items)
        instance:EnableBuyBtns(true)
        local panel = require("Main.activity.TianDiBaoKu.ui.BaoKuAwardGetPanel").Instance()
        panel:ShowPanel(items)
        panel.onBuyAgainBtnClick = TianDiBaoKuPanel.OnBuyAgainBtnClick
      end
      local isEqual = function(litem, ritem)
        if litem == nil or ritem == nil then
          return true
        end
        if litem.itemid == ritem.itemid then
          return true
        end
        if litem.name == ritem.name then
          return true
        end
        return false
      end
      local items = params.random_item_list
      if instance.m_prevItems then
        local _, stopItem = next(items)
        local stopItemBase = ItemUtils.GetItemBase(stopItem.id)
        local index = 1
        for i, v in ipairs(instance.m_prevItems) do
          local itemBase = ItemUtils.GetItemBase(v.id)
          if isEqual(stopItemBase, itemBase) then
            index = i
            break
          end
        end
        instance:FinishDrawingAnimationInPos(index, function(...)
          showResult(items)
        end)
      else
        showResult(items)
      end
      local lastBuyInfo = instance.m_lastBuyInfo
      if lastBuyInfo then
        local text
        if lastBuyInfo.useYuanbaoNum > 0 then
          text = instance:GetDynamicText(textRes.Mibao[19])
          text = text:format(lastBuyInfo.useItemNum, lastBuyInfo.useYuanbaoNum, lastBuyInfo.buyItemNum)
        else
          text = instance:GetDynamicText(textRes.Mibao[18])
          text = text:format(lastBuyInfo.useItemNum)
        end
        Toast(text)
        instance.m_lastBuyInfo = nil
      end
    end
  end
end
def.static("number", "=>", "boolean").OnBuyAgainBtnClick = function(buyNum)
  if instance == nil then
    return false
  end
  local self = instance
  local function buy(...)
    if buyNum == DRAW_COUNT_ONE then
      return self:OnBuyBtnClick()
    elseif buyNum == DRAW_COUNT_TEN then
      return self:OnBuyTenTimesBtnClick()
    end
    return false
  end
  if self.m_panel == nil or self.m_panel.isnil then
    self.onUIReady = buy
    self:ShowPanel()
    return false
  else
    return buy()
  end
end
def.static("table", "table").OnFunctionOpenChange = function()
  if LotteryAwardMgr.Instance():IsActivityOpen() == false then
    instance:DestroyPanel()
  end
end
return TianDiBaoKuPanel.Commit()

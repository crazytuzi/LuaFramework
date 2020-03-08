local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TimeLimitedGiftPanel = Lplus.Extend(ECPanelBase, "TimeLimitedGiftPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GiftActivityMgr = require("Main.CustomActivity.GiftActivityMgr")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local def = TimeLimitedGiftPanel.define
def.field("table").uiObjs = nil
def.field("table").m_giftBags = nil
def.field("table").m_currencyData = nil
def.field("table").m_freeGiftBag = nil
def.field("table").m_activityTime = nil
def.field("number").m_activityId = 0
def.field("table").m_viewData = nil
local instance
def.static("=>", TimeLimitedGiftPanel).Instance = function()
  if instance == nil then
    instance = TimeLimitedGiftPanel()
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method("string").ShowPanel = function(self, tabName)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_SyncLoad = true
  self:CreatePanel(RESPATH.PREFAB_PRIZE_LIMIT_GIFT_BAG, 0)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, TimeLimitedGiftPanel.OnGetAwardSuccess)
end
def.method().UpdateUI = function(self)
  self:UpdateGiftBagList()
  self:UpdateMoneyNum()
  self:UpdateFreeGiftBag()
  self:UpdateActivityTime()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.m_giftBags = nil
  self.m_freeGiftBag = nil
  if self.m_currencyData then
    self.m_currencyData:UnregisterCurrencyChangedEvent(TimeLimitedGiftPanel.OnMoneyUpdate)
  end
  self.m_currencyData = nil
  self.m_activityTime = nil
  self.m_activityId = 0
  self.m_viewData = nil
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, TimeLimitedGiftPanel.OnGetAwardSuccess)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "Img_BgIcon") then
    self:OnImgBgIconClick(obj)
  elseif id == "Btn_Get" then
    self:OnPurchaseBtnClick(obj)
  elseif id == "Btn_Add3" then
    self:OnAddMoneyBtnClick()
  elseif id == "Btn_Give" then
    self:onClickBtnGive(obj)
  end
  warn("onClickObj----------------------------", id)
end
def.method("userdata").OnImgBgIconClick = function(self, obj)
  local id = obj.name
  local giftIndex = tonumber(string.sub(id, #"Img_BgIcon" + 1, -1))
  if giftIndex == nil then
    return
  end
  local itemObj = obj.parent.parent
  local giftBagIndex = tonumber(string.sub(itemObj.name, #"item_" + 1, -1))
  if giftBagIndex == nil then
    return
  end
  local giftBag = self.m_giftBags[giftBagIndex]
  local gift = giftBag.gifts[giftIndex]
  local itemId = gift.itemId
  if itemId == nil then
    return
  end
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, obj, 0, false)
end
def.method("userdata").OnPurchaseBtnClick = function(self, obj)
  local itemObj = obj.parent
  local id = itemObj.name
  if id == "Group_FreeGet" then
    self:OnFreeGetBtnClick()
    return
  end
  local giftBagIndex = tonumber(string.sub(id, #"item_" + 1, -1))
  local giftBag = self.m_giftBags[giftBagIndex]
  if self:CheckRemainPurchaseTimes(giftBag) == false then
    return
  end
  require("Main.CustomActivity.ui.TimeLimitedGiftExchangePanel").Instance():ShowGiftBuyPanel(giftBag, function(num)
    local price = giftBag.currentPrice
    local totcalCost = price * num
    if Int64.lt(self.m_currencyData:GetHaveNum(), totcalCost) then
      _G.GotoBuyYuanbao()
      return false
    else
      GiftActivityMgr.Instance():GetGiftAwardReq(giftBag.activityId, giftBag.id, num)
      return true
    end
  end)
end
def.method("userdata").onClickBtnGive = function(self, clickObj)
  if not GiftActivityMgr.IsGiftGivingFeatureOpen() then
    Toast(textRes.customActivity[313])
    return
  end
  local itemObj = clickObj.parent
  local id = itemObj.name
  if id == "Group_FreeGet" then
    self:OnFreeGetBtnClick()
    return
  end
  local giftBagIndex = tonumber(string.sub(id, #"item_" + 1, -1))
  local giftBag = self.m_giftBags[giftBagIndex]
  require("Main.CustomActivity.ui.UITimeLimitGiftGiving").Instance():ShowPanel(giftBag)
end
def.method().OnFreeGetBtnClick = function(self)
  if self.m_freeGiftBag == nil then
    return
  end
  local activityId = self.m_freeGiftBag.activityId
  local giftBagId = self.m_freeGiftBag.id
  GiftActivityMgr.Instance():GetGiftAwardReq(activityId, giftBagId, 1)
end
def.method().OnAddMoneyBtnClick = function(self)
  if self.m_currencyData then
    self.m_currencyData:Acquire()
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Gift = self.m_panel:FindDirect("Group_LeiDeng")
  self.uiObjs.ScrollView_Gift = self.uiObjs.Group_Gift:FindDirect("Scroll View_LeiDeng")
  self.uiObjs.List_Gift = self.uiObjs.ScrollView_Gift:FindDirect("List_Gift")
  self.uiObjs.Group_YuanBao = self.uiObjs.Group_Gift:FindDirect("Group_YuanBao")
  self.uiObjs.Group_FreeGet = self.uiObjs.Group_Gift:FindDirect("Group_FreeGet")
  local lblTime = self.uiObjs.Group_Gift:FindDirect("Label_Time")
  self.uiObjs.Label_Time = lblTime:FindDirect("Label")
  local bIsGiveFeatureOpen = GiftActivityMgr.IsGiftGivingFeatureOpen()
  lblTime:SetActive(not bIsGiveFeatureOpen)
  lblTime = self.uiObjs.Group_Gift:FindDirect("Label_Time1")
  lblTime:SetActive(bIsGiveFeatureOpen)
  if bIsGiveFeatureOpen then
    self.uiObjs.Label_Time = lblTime:FindDirect("Label")
    local lblTimeTips = lblTime:FindDirect("Label_Tips")
    GUIUtils.SetText(lblTimeTips, textRes.customActivity[323])
  end
end
def.method().UpdateMoneyNum = function(self)
  local num = self.m_currencyData:GetHaveNum()
  local Label_Coin = self.uiObjs.Group_YuanBao:FindDirect("Label_Coin")
  GUIUtils.SetText(Label_Coin, tostring(num))
  local Img_Coin = self.uiObjs.Group_YuanBao:FindDirect("Img_Coin3")
  local spriteName = self.m_currencyData:GetSpriteName()
  GUIUtils.SetSprite(Img_Coin, spriteName)
end
def.method().UpdateGiftBagList = function(self)
  local viewdatas = self:GetViewDatas()
  self.m_viewData = viewdatas
  self.m_giftBags = viewdatas.giftBags
  if self.m_currencyData then
    self.m_currencyData:UnregisterCurrencyChangedEvent(TimeLimitedGiftPanel.OnMoneyUpdate)
  end
  self.m_currencyData = viewdatas.currencyData
  self.m_currencyData:RegisterCurrencyChangedEvent(TimeLimitedGiftPanel.OnMoneyUpdate)
  self.m_freeGiftBag = viewdatas.freeGiftBag
  self.m_activityTime = viewdatas.activityTime
  self.m_activityId = viewdatas.activityId
  self:SetGiftBagList(self.m_giftBags)
end
def.method("table").SetGiftBagList = function(self, giftBagList)
  local count = #giftBagList
  local uiList = self.uiObjs.List_Gift:GetComponent("UIList")
  uiList.itemCount = count
  uiList:Resize()
  uiList:Reposition()
  local itemObjs = uiList.children
  self.m_msgHandler:Touch(self.uiObjs.List_Gift)
  local bIsGiveFeatureOpen = GiftActivityMgr.IsGiftGivingFeatureOpen()
  for i = 1, count do
    local itemObj = itemObjs[i]
    local giftBag = giftBagList[i]
    local params = {}
    self:SetGiftBagInfo(itemObj, giftBag, params)
    itemObj:FindDirect("Btn_Give"):SetActive(bIsGiveFeatureOpen and giftBag.bCan2Give)
  end
end
def.method("userdata", "table", "table").SetGiftBagInfo = function(self, giftBagObj, giftBag, params)
  local Img_Ti_Label = giftBagObj:FindDirect("Img_Ti/Label")
  local Label_Tip = giftBagObj:FindDirect("Label_Tip")
  local Img_YuanBaoOld = giftBagObj:FindDirect("Img_YuanBaoOld")
  local Label_YuanBaoOldNum = Img_YuanBaoOld:FindDirect("Label_Num")
  local Img_Cost = giftBagObj:FindDirect("Img_Cost")
  local Label_CostNum = Img_Cost:FindDirect("Label_Num")
  local Label_CiShu = giftBagObj:FindDirect("Label_CiShu/Label_Num")
  local currencySpriteName = self.m_currencyData:GetSpriteName()
  GUIUtils.SetSprite(Img_YuanBaoOld, currencySpriteName)
  GUIUtils.SetSprite(Img_Cost, currencySpriteName)
  GUIUtils.SetText(Img_Ti_Label, giftBag.name)
  local tipText = string.format(textRes.customActivity[102], giftBag.currentPrice, giftBag.originalPrice)
  GUIUtils.SetText(Label_Tip, tipText)
  GUIUtils.SetText(Label_YuanBaoOldNum, giftBag.originalPrice)
  GUIUtils.SetText(Label_CostNum, giftBag.currentPrice)
  GUIUtils.SetText(Label_CiShu, giftBag.remainPurchaseTimes)
  local Group_Icon = giftBagObj:FindDirect("Group_Icon")
  local MAX_ICON_NUM = 4
  for i = 1, MAX_ICON_NUM do
    local giftObj = Group_Icon:FindDirect("Img_BgIcon" .. i)
    local giftInfo = giftBag.gifts[i]
    self:SetGiftInfo(giftObj, giftInfo, nil)
  end
end
def.method("userdata", "table", "table").SetGiftInfo = function(self, giftObj, giftInfo, params)
  if giftInfo == nil then
    GUIUtils.SetActive(giftObj, false)
    return
  end
  GUIUtils.SetActive(giftObj, true)
  local Texture_Icon = giftObj:FindDirect("Texture_Icon")
  local Label_Num = giftObj:FindDirect("Label_Num")
  GUIUtils.SetTexture(Texture_Icon, giftInfo.iconId)
  GUIUtils.SetText(Label_Num, giftInfo.num)
  local namecolor = 0
  local itemBase = ItemUtils.GetItemBase(giftInfo.itemId)
  if itemBase then
    namecolor = itemBase.namecolor
  end
  GUIUtils.SetItemCellSprite(giftObj, namecolor)
end
def.method().UpdateFreeGiftBag = function(self)
  if self.m_freeGiftBag and self.m_freeGiftBag.remainPurchaseTimes > 0 then
    local featureType = Feature.TYPE_TIME_LIMIT_GIFT_FREE
    local feature = FeatureOpenListModule.Instance()
    local isOpen = feature:CheckFeatureOpen(featureType)
    GUIUtils.SetActive(self.uiObjs.Group_FreeGet, isOpen)
    if isOpen then
      local path = "panel_prize2_limitgiftbag/Group_LeiDeng/Group_FreeGet/Btn_Get"
      GUIUtils.AddLightEffectToPanel(path, GUIUtils.Light.Square)
    end
  else
    GUIUtils.SetActive(self.uiObjs.Group_FreeGet, false)
  end
end
def.method().UpdateActivityTime = function(self)
  local text = self.m_viewData.timeDes
  GUIUtils.SetText(self.uiObjs.Label_Time, text)
end
def.method("table", "=>", "boolean").CheckRemainPurchaseTimes = function(self, giftBag)
  if giftBag.remainPurchaseTimes <= 0 then
    Toast(textRes.customActivity[104])
    return false
  end
  return true
end
def.method("table", "=>", "boolean").CheckCurrencyEnough = function(self, giftBag)
  local haveNum = self.m_currencyData:GetHaveNum()
  local needNum = Int64.new(giftBag.currentPrice)
  if haveNum < needNum then
    self.m_currencyData:AcquireWithQuery()
    return false
  end
  return true
end
def.static("table", "table").OnMoneyUpdate = function()
  instance:UpdateMoneyNum()
end
def.static("table", "table").OnGetAwardSuccess = function(params)
  local activityId = params.activityId
  local giftBagId = params.giftBagId
  local remainTimes = params.remainTimes
  local self = instance
  if activityId ~= self.m_activityId then
    return
  end
  if self.m_freeGiftBag and giftBagId == self.m_freeGiftBag.id then
    self.m_freeGiftBag.remainPurchaseTimes = remainTimes
    self:UpdateFreeGiftBag()
  else
    local index = 0
    local giftBag
    for i, v in ipairs(self.m_giftBags) do
      if giftBagId == v.id then
        index = i
        giftBag = v
        break
      end
    end
    if giftBag == nil then
      return
    end
    local itemObj = self.uiObjs.List_Gift:FindDirect("item_" .. index)
    if itemObj == nil then
      return
    end
    giftBag.remainPurchaseTimes = remainTimes
    self:SetGiftBagInfo(itemObj, giftBag, {})
  end
end
def.method("=>", "table").GetViewDatas = function(self)
  local giftActivityMgr = GiftActivityMgr.Instance()
  local GiftBagType = require("consts.mzm.gsp.qingfu.confbean.GiftBagType")
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityGiftInfos = giftActivityMgr:GetActivityGiftInfosByGiftBagType(GiftBagType.TYPE_TIME_LIMIT)
  local giftBagInfo = activityGiftInfos[1]
  local viewdata = {
    giftBags = {},
    freeGiftBag = nil,
    currencyData = CurrencyFactory.Create(-1),
    activityId = 0,
    timeDes = ""
  }
  if giftBagInfo == nil then
    warn("no activityGiftInfos found!!!")
    return viewdata
  end
  local moneyType = 0
  local activityId = 0
  local timestamp = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local t = AbsoluteTimer.GetServerTimeTable(timestamp)
  local WeekDay = AbsoluteTimer.GetServerTimeTable(timestamp)
  local WeekDay_NO_DAY = 0
  local wday = t.wday
  for k, v in pairs(giftBagInfo.giftBags) do
    local giftBagId = k
    local remainPurchaseTimes = v
    local giftBagCfg = CustomActivityInterface.GetTimeLimitedGiftBagCfg(giftBagId)
    local buyWeekDay = giftBagCfg.buyWeekDay
    if wday == buyWeekDay or buyWeekDay == WeekDay_NO_DAY then
      local giftBagViewData = {}
      giftBagViewData.id = giftBagCfg.id
      giftBagViewData.activityId = giftBagInfo.activityId
      giftBagViewData.name = giftBagCfg.desc
      giftBagViewData.originalPrice = giftBagCfg.originalPrice
      giftBagViewData.currentPrice = giftBagCfg.discountPrice
      giftBagViewData.remainPurchaseTimes = remainPurchaseTimes
      giftBagViewData.sort = giftBagCfg.sort
      giftBagViewData.bCan2Give = giftBagCfg.bCan2Give
      local awardId = giftBagCfg.rewardId
      local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
      local cfg = ItemUtils.GetGiftAwardCfg(key)
      giftBagViewData.gifts = ItemUtils.GetAwardItemsFromAwardCfg(cfg)
      if giftBagViewData.currentPrice == 0 then
        viewdata.freeGiftBag = giftBagViewData
      else
        table.insert(viewdata.giftBags, giftBagViewData)
      end
    end
    moneyType = giftBagCfg.moneytype
    activityId = giftBagInfo.activityId
  end
  table.sort(viewdata.giftBags, function(l, r)
    return l.sort < r.sort
  end)
  viewdata.currencyData = CurrencyFactory.Create(moneyType)
  viewdata.activityTime = {}
  local beginTime, _, endTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  viewdata.activityTime.beginTime = beginTime
  viewdata.activityTime.endTime = endTime
  viewdata.activityId = activityId
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  viewdata.timeDes = activityCfg and activityCfg.timeDes or "nil"
  return viewdata
end
return TimeLimitedGiftPanel.Commit()

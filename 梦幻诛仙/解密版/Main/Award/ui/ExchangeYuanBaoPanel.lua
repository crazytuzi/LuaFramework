local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ExchangeYuanBaoPanel = Lplus.Extend(ECPanelBase, "ExchangeYuanBaoPanel")
local def = ExchangeYuanBaoPanel.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ExchangeYuanBaoMgr = require("Main.Award.mgr.ExchangeYuanBaoMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local AwardUtils = require("Main.Award.AwardUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local MallUtility = require("Main.Mall.MallUtility")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local ActivityInterface = require("Main.activity.ActivityInterface")
local EC = require("Types.Vector3")
local GUIFxMan = require("Fx.GUIFxMan")
def.field("table")._uiGOs = nil
def.field("number")._actId = 0
def.field("number")._sortId = 0
def.field("number")._timer = 0
def.field("number")._CDTimer = 0
def.field("number")._leftSecs = 0
def.field("number")._day = 0
def.field("number")._hour = 0
def.field("number")._min = 0
def.field("number")._externYB = -1
def.field("number")._iLeftTimes = 0
def.field("boolean")._bLockOpera = false
def.field("table")._curAwardItems = nil
def.const("number").DST_AXES_NUM = 3
def.const("number").AXE_MONEY_TYPE = MoneyType.YUANBAO
def.const("number").UNLOCK_MONEY_TYPE = MoneyType.YUANBAO
local ENUM_COST_TYPE = require("consts.mzm.gsp.axe.confbean.UnlockAxeActivityCostType")
local ENUM_UNLOCK_COST_TYPE = {
  YUANBAO = 1,
  GOLD = 2,
  SILVER = 3
}
local itemAngle = {}
def.static("=>", ExchangeYuanBaoPanel).Instance = function()
  if instance == nil then
    instance = ExchangeYuanBaoPanel()
    local dstAxesNum = ExchangeYuanBaoPanel.DST_AXES_NUM
    local dtAngle = 180 / (dstAxesNum - 1)
    table.insert(itemAngle, 90)
    for i = 2, dstAxesNum do
      table.insert(itemAngle, 90 - dtAngle)
      dtAngle = dtAngle + dtAngle
    end
  end
  return instance
end
def.method().ShowPanel = function(self)
  self._actId = ExchangeYuanBaoMgr.GetCurActId()
  self._curAwardItems = {}
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  warn("ExchangeYuanBaoPanel create", os.clock())
  self:CreatePanel(RESPATH.PREFAB_PANEL_RIVERGOD, 0)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ATTEN_EXCHANGEYUANBAO_SUCCESS, ExchangeYuanBaoPanel.OnAttenSuccess)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ATTEN_EXCHANGEYUANBAO_FAIL, ExchangeYuanBaoPanel.OnAttenFail)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.UNLOCK_EXCHANGEYUANABO, ExchangeYuanBaoPanel.OnUnlockExchange)
  self._uiGOs = {}
end
def.method().InitUI = function(self)
  local groupRiver = self.m_panel:FindDirect("Group_RiverGod")
  self._uiGOs.btnConfirm = groupRiver:FindDirect("Btn_Confirm")
  self._uiGOs.groupThrow = groupRiver:FindDirect("Group_Open")
  self._uiGOs.groupMoneyThrow = groupRiver:FindDirect("Group_MoneyCome")
  self._uiGOs.lblTime = groupRiver:FindDirect("Group_Open/Group_Time/Label_Time")
  local groupBingo = groupRiver:FindDirect("Group_Bingo")
  local ctrlPtr = groupBingo:FindDirect("Img_Stop")
  self._uiGOs.tween = ctrlPtr:GetComponent("TweenRotation")
  self._uiGOs.tween.enabled = false
  self._uiGOs.axesItems = groupBingo:FindDirect("Group_Item")
  local itemNeed = groupRiver:FindDirect("Item_Need")
  itemNeed:SetActive(false)
  self._uiGOs.itemNeedWorth = itemNeed:FindDirect("Group_Price")
  self._uiGOs.itemNeed = itemNeed
  self._uiGOs.iconItem = itemNeed:FindDirect("Img_Icon")
  self._uiGOs.lblItemName = itemNeed:FindDirect("Label_Name")
  self._uiGOs.lblCost = itemNeed:FindDirect("Label_Cost")
  self._uiGOs.groupUnlock = groupRiver:FindDirect("Group_Close")
  self._uiGOs.fx = groupRiver:FindDirect("Fx")
  self:UpdateUIExpired()
  self:UpdateUIToggle(false)
  self:UpdateUI()
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:InitUI()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ATTEN_EXCHANGEYUANBAO_SUCCESS, ExchangeYuanBaoPanel.OnAttenSuccess)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ATTEN_EXCHANGEYUANBAO_FAIL, ExchangeYuanBaoPanel.OnAttenFail)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.UNLOCK_EXCHANGEYUANABO, ExchangeYuanBaoPanel.OnUnlockExchange)
  self._uiGOs = nil
  self._sortId = 0
  GameUtil.RemoveGlobalTimer(self._timer)
  self._timer = 0
  GameUtil.RemoveGlobalTimer(self._CDTimer)
  self._CDTimer = 0
  self._externYB = -1
  self._curAwardItems = nil
  if self._bLockOpera then
    ExchangeYuanBaoMgr.SendCGetAxeActivityItemReq()
  end
  self._bLockOpera = false
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  warn("click id = " .. id)
  if id == "Btn_Confirm" then
    self:OnBtnThrowClick()
  elseif id == "Btn_Come" then
    self:OnBtnUnlockClick()
  elseif id == "btn_throw_money" then
    self:OnBtnThrowMoneyClick()
  elseif id == "Btn_UseDep" then
    if GUIUtils.IsToggle(obj) then
      self:IsShowConfirmUseYB()
    else
      self:UpdateUIToggle(false)
      self:_changeBtnContent(-1, 0)
    end
  elseif id == "Item_Need" then
    self:OnItemClick(constant.CAxeItemConsts.WOOD_AXE_ITEM_CFG_ID, obj, true)
  elseif string.find(id, "Item_%d%d") ~= nil then
    local idx = tonumber(string.sub(id, string.find(id, "%d%d")))
    local itemId = self._curAwardItems[idx]
    if itemId == nil then
      return
    end
    self:OnItemClick(itemId, obj, false)
  end
end
def.method("number", "userdata", "boolean").OnItemClick = function(self, itemId, clickobj, needSource)
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:FindDirect("Img_Bg"):GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, needSource)
end
def.method().OnBtnThrowMoneyClick = function(self)
  if self._leftSecs < 0 then
    Toast(textRes.Award.ExchangeYuanBao[2])
    return
  end
  local curSectId = self:GetCurrentSection()
  local secCfgData = AwardUtils.GetAxeSectioInfoByActIdandSecIdx(self._actId, curSectId)
  local moneyType = MoneyType.SILVER
  if secCfgData.cost_type == ENUM_COST_TYPE.SILVER then
    moneyType = MoneyType.SILVER
  elseif secCfgData.cost_type == ENUM_COST_TYPE.GOLD then
    moneyType = MoneyType.GOLD
  elseif secCfgData.cost_type == ENUM_COST_TYPE.YUAN_BAO then
    moneyType = MoneyType.YUANBAO
  end
  local ownedMoney = self:GetMoneyNumByType(moneyType)
  if Int64.lt(ownedMoney, secCfgData.cost_num) then
    self:GotoBuyMoney(moneyType, true)
  elseif self._bLockOpera then
    Toast(textRes.Award.ExchangeYuanBao[8])
  else
    ExchangeYuanBaoMgr.SendCAttendAxeActivityReq(self._actId)
    GUIUtils.EnableButton(self._uiGOs.groupMoneyThrow:FindDirect("btn_throw_money"), false)
    self._bLockOpera = true
  end
end
def.method().OnBtnThrowClick = function(self)
  if self._leftSecs < 0 then
    Toast(textRes.Award.ExchangeYuanBao[2])
    return
  end
  local toggle = self._uiGOs.groupThrow:FindDirect("Group_UseDep/Btn_UseDep")
  if not GUIUtils.IsToggle(toggle) and self:IsShowConfirmUseYB() then
    return
  end
  self:OnBtnThrowUseYBClick()
end
def.method().OnBtnThrowUseYBClick = function(self)
  if self._leftSecs < 0 then
    Toast(textRes.Award.ExchangeYuanBao[2])
    return
  end
  local ownedMoney = self:GetMoneyNumByType(ExchangeYuanBaoPanel.AXE_MONEY_TYPE)
  if Int64.lt(ownedMoney, self._externYB) then
    _G.GotoBuyYuanbao()
  elseif self._bLockOpera then
    Toast(textRes.Award.ExchangeYuanBao[8])
  else
    self:UpdateUIThrowBtn(true)
    ExchangeYuanBaoMgr.SendCAttendAxeActivityReq(self._actId)
    self:UpdateUIToggle(false)
    self._bLockOpera = true
    GUIUtils.EnableButton(self._uiGOs.groupThrow:FindDirect("Btn_Confirm"), false)
  end
end
def.method("boolean").UpdateUIThrowBtn = function(self, bShow)
  local groupMoney = self._uiGOs.groupThrow:FindDirect("Btn_Confirm/Group_Money")
  local lblName = self._uiGOs.groupThrow:FindDirect("Btn_Confirm/Label_Name")
  groupMoney:SetActive(not bShow)
  lblName:SetActive(bShow)
end
def.method("number", "=>", "userdata").GetMoneyNumByType = function(self, mtype)
  if mtype == MoneyType.YUANBAO then
    return ItemModule.Instance():getCashYuanBao() or Int64.new(0)
  else
    if mtype == MoneyType.SILVER then
      mtype = ItemModule.MONEY_TYPE_SILVER
    elseif mtype == MoneyType.GOLD then
      mtype = ItemModule.MONEY_TYPE_GOLD
    elseif mtype == MoneyType.GOLD_INGOT then
      mtype = ItemModule.MONEY_TYPE_GOLD_INGOT
    end
    return ItemModule.Instance():GetMoney(mtype) or Int64.new(0)
  end
end
def.method("number", "boolean").GotoBuyMoney = function(self, mtype, bconfirm)
  if mtype == MoneyType.YUANBAO then
    _G.GotoBuyYuanbao()
  elseif mtype == MoneyType.GOLD then
    _G.GoToBuyGold(bconfirm)
  elseif mtype == MoneyType.SILVER then
    _G.GoToBuySilver(bconfirm)
  elseif mtype == MoneyType.GOLD_INGOT then
    _G.GoToBuyGoldIngot(bconfirm)
  end
end
def.method().OnBtnUnlockClick = function(self)
  local basicCfgData = AwardUtils.GetActBasicInfoByActId(self._actId)
  local unlockCostType = self:_getUnlockMoneyType(basicCfgData)
  local moneyData = CurrencyFactory.Create(unlockCostType)
  local content = textRes.Award.ExchangeYuanBao[3]:format(basicCfgData.unlock_cost_num, moneyData:GetName())
  CommonConfirmDlg.ShowConfirm("", content, function(select)
    if select == 1 then
      local ownedMoney = self:GetMoneyNumByType(unlockCostType)
      if Int64.lt(ownedMoney, basicCfgData.unlock_cost_num) then
        self:GotoBuyMoney(unlockCostType, true)
        return
      end
      ExchangeYuanBaoMgr.SendCUnlockAxeActivityReq(self._actId)
    end
  end, nil)
end
def.method("table", "=>", "number")._getUnlockMoneyType = function(self, basicCfgData)
  if basicCfgData == nil then
    return 0
  end
  local unlockCostType = 0
  if basicCfgData.unlock_cost_type == ENUM_UNLOCK_COST_TYPE.YUANBAO then
    unlockCostType = MoneyType.YUANBAO
  elseif basicCfgData.unlock_cost_type == ENUM_UNLOCK_COST_TYPE.GOLD then
    unlockCostType = MoneyType.GOLD
  elseif basicCfgData.unlock_cost_type == ENUM_UNLOCK_COST_TYPE.SILVER then
    unlockCostType = MoneyType.SILVER
  end
  return unlockCostType
end
def.method().StartLottery = function(self)
  GameUtil.RemoveGlobalTimer(self._timer)
  local tween = self._uiGOs.tween
  tween.enabled = true
  tween.style = 2
  tween.method = 2
  tween.tweenFactor = 0
  tween.from = EC.Vector3.new(0, 0, 90)
  tween.to = EC.Vector3.new(0, 0, -90)
  tween.duration = 1
  self._timer = GameUtil.AddGlobalTimer(2, true, function()
    local preSectId = self:GetCurrentSection() - 1
    local awardCfg = AwardUtils.GetAxeSectioInfoByActIdandSecIdx(self._actId, preSectId).results[self._sortId]
    local icon = 0
    local angleIdx = 1
    if awardCfg ~= nil then
      local itemBaseCfg = ItemUtils.GetItemBase(awardCfg.axe_item_cfg_id)
      angleIdx = self:GetAngleIdxByItemId(awardCfg.axe_item_cfg_id)
    end
    local function funcReport()
      ExchangeYuanBaoMgr.SendCGetAxeActivityItemReq()
      if self._bLockOpera then
        local effectCfg = GetEffectRes(constant.CAxeActivityConsts.EFFECT_ID)
        if nil == effectCfg then
          warn("Get HeShen fx failed ,no resource")
        else
          local fx = GUIFxMan.Instance():PlayAsChildLayer(self._uiGOs.fx, effectCfg.path, "HeShen", 0, 0, 1, 1, 0, false)
        end
      end
      GameUtil.AddGlobalTimer(1.2, true, function()
        if not self:IsShow() then
          return
        end
        self._bLockOpera = false
        self:UpdateUI()
      end)
      GUIUtils.EnableButton(self._uiGOs.groupThrow:FindDirect("Btn_Confirm"), true)
      GUIUtils.EnableButton(self._uiGOs.groupMoneyThrow:FindDirect("btn_throw_money"), true)
    end
    local function funcStop()
      self:StopLottery(angleIdx, 3)
      GameUtil.AddGlobalTimer(2.8, true, function()
        funcReport()
      end)
    end
    local quat = tween.rotation
    local diffAngle = math.abs(quat.eulerAngles.z - 90)
    if diffAngle < 30 and angleIdx == 1 then
      local duration = diffAngle / 90
      self:StopLottery(angleIdx, duration + 0.1)
      funcReport(duration)
    else
      funcStop()
    end
  end)
end
def.method("number", "number").StopLottery = function(self, angleIdx, duration)
  GameUtil.RemoveGlobalTimer(self._timer)
  local tween = self._uiGOs.tween
  local quat = tween.rotation
  tween.style = 0
  tween.method = 2
  tween.tweenFactor = 0
  tween.from = EC.Vector3.new(0, 0, quat.eulerAngles.z)
  tween.to = EC.Vector3.new(0, 0, itemAngle[angleIdx])
  tween.duration = duration
  tween:Play()
end
def.method("number", "=>", "number").GetAngleIdxByItemId = function(self, itemId)
  local consts = constant.CAxeItemConsts
  if itemId == consts.WOOD_AXE_ITEM_CFG_ID then
    return 1
  elseif itemId == consts.COPPER_AXE_ITEM_CFG_ID or itemId == consts.COPPER_AXE_GOLD_ITEM_CFG_ID then
    return 1
  elseif itemId == consts.SILVER_AXE_ITEM_CFG_ID or itemId == consts.SILVER_AXE_GOLD_ITEM_CFG_ID then
    return 2
  elseif itemId == consts.GOLD_AXE_ITEM_CFG_ID or itemId == consts.GOLD_AXE_GOLD_ITEM_CFG_ID then
    return 3
  end
  return 1
end
def.method("=>", "number").GetCurrentSection = function(self)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local activityInfo = activityInterface:GetActivityInfo(self._actId)
  if activityInfo == nil then
    return 1
  else
    return activityInfo.count + 1
  end
end
def.method("=>", "table")._getRequirements = function(self)
  return ExchangeYuanBaoMgr.GetRequirements(self._actId)
end
def.method().UpdateUIExpired = function(self)
  local bIsExpired = self:IsExpired()
  self._uiGOs.groupUnlock:SetActive(bIsExpired)
  self._uiGOs.groupThrow:SetActive(not bIsExpired)
  self._uiGOs.groupMoneyThrow:SetActive(not bIsExpired)
  if bIsExpired then
    self:UpdateUILock()
  else
    self:UpdateUILeftTime()
  end
end
def.method("=>", "boolean").IsExpired = function(self)
  local nowSec = _G.GetServerTime()
  local actStartSec = ExchangeYuanBaoMgr.GetTimeStampByActId(self._actId)
  local cfgData = AwardUtils.GetActBasicInfoByActId(self._actId)
  if actStartSec > 0 and nowSec - actStartSec > cfgData.lockTimeInDay * 86400 then
    return true
  else
    return false
  end
end
def.method().UpdateUILeftTime = function(self)
  local timeLimitCfg = self:_getRequirements()
  local nowSec = _G.GetServerTime()
  local iLastTimeStamp = ExchangeYuanBaoMgr.GetTimeStampByActId(self._actId)
  local baseCfgData = AwardUtils.GetActBasicInfoByActId(self._actId)
  if iLastTimeStamp == 0 then
    self._leftSecs = baseCfgData.lockTimeInDay * 86400
    ExchangeYuanBaoMgr.SetTimeStampByActId(self._actId, nowSec)
  else
    self._leftSecs = baseCfgData.lockTimeInDay * 86400 - (nowSec - iLastTimeStamp)
  end
  self:_minusSec(0)
  self:_setUILeftTime()
  GameUtil.RemoveGlobalTimer(self._CDTimer)
  self._CDTimer = GameUtil.AddGlobalTimer(1, false, function()
    self:_minusSec(1)
    self:_setUILeftTime()
    if self._leftSecs < 0 then
      self:UpdateUIExpired()
    end
  end)
end
def.method().UpdateUILock = function(self)
  local lblTips = self._uiGOs.groupUnlock:FindDirect("Label_Tips")
  local icon = self._uiGOs.groupUnlock:FindDirect("Img_Dep")
  local cfgData = AwardUtils.GetActBasicInfoByActId(self._actId)
  local unlockCostType = self:_getUnlockMoneyType(cfgData)
  local moneyData = CurrencyFactory.Create(unlockCostType)
  GUIUtils.SetText(lblTips, textRes.Award.ExchangeYuanBao[3]:format(cfgData.unlock_cost_num, moneyData:GetName()))
  GUIUtils.SetSprite(icon, moneyData:GetSpriteName())
end
def.method()._setUILeftTime = function(self)
  GUIUtils.SetText(self._uiGOs.lblTime, textRes.Award.ExchangeYuanBao[1]:format(self._day, self._hour, self._min))
end
def.method("number")._addMin = function(self, time)
end
def.method("number")._minusSec = function(self, time)
  self._leftSecs = self._leftSecs - time
  if self._leftSecs <= 0 then
    self._day = 0
    self._hour = 0
    self._min = 0
  else
    self._day = math.floor(self._leftSecs / 86400)
    self._hour = math.floor(self._leftSecs % 86400 / 3600)
    self._min = math.floor(self._leftSecs % 3600 / 60)
  end
end
def.method().UpdateUI = function(self)
  local curSectId = self:GetCurrentSection()
  local cfgMaxTimes = ActivityInterface.GetActivityCfgById(self._actId).limitCount
  if curSectId > cfgMaxTimes then
    ExchangeYuanBaoMgr.DispatchAwardNodeChange()
    return
  end
  local lblLeftTimes = self._uiGOs.groupThrow:FindDirect("Label_Num")
  local secCfgData
  secCfgData = AwardUtils.GetAxeSectioInfoByActIdandSecIdx(self._actId, curSectId)
  local moneyType = ExchangeYuanBaoPanel.AXE_MONEY_TYPE
  self:_toggleThrowCtrls(false)
  lblLeftTimes = self._uiGOs.groupMoneyThrow:FindDirect("Label_Num")
  local lblTips = self._uiGOs.groupMoneyThrow:FindDirect("Label_Tips")
  local btnLbl = self._uiGOs.groupMoneyThrow:FindDirect("btn_throw_money/Label_Name")
  local moneyData
  if secCfgData.cost_type == ENUM_COST_TYPE.SILVER then
    moneyType = MoneyType.SILVER
    moneyData = CurrencyFactory.Create(MoneyType.SILVER)
  elseif secCfgData.cost_type == ENUM_COST_TYPE.GOLD then
    moneyType = MoneyType.GOLD
    moneyData = CurrencyFactory.Create(MoneyType.GOLD)
  elseif secCfgData.cost_type == ENUM_COST_TYPE.YUAN_BAO then
    moneyType = MoneyType.YUANBAO
    moneyData = CurrencyFactory.Create(moneyType)
  end
  GUIUtils.SetText(btnLbl, textRes.Award.ExchangeYuanBao[7]:format(moneyData:GetName()))
  if moneyType == MoneyType.YUANBAO then
    GUIUtils.SetText(lblTips, textRes.Award.ExchangeYuanBao[14]:format(secCfgData.cost_num, moneyData:GetName()))
  else
    GUIUtils.SetText(lblTips, textRes.Award.ExchangeYuanBao[9]:format(secCfgData.cost_num, moneyData:GetName()))
  end
  GUIUtils.SetText(lblLeftTimes, textRes.Award.ExchangeYuanBao[6]:format(cfgMaxTimes - curSectId + 1))
  local dstAxesNum = ExchangeYuanBaoPanel.DST_AXES_NUM
  self._curAwardItems = {}
  for i = 1, dstAxesNum do
    local itemCfgInfo = secCfgData.results[i]
    local itemPosIdx = self:GetAngleIdxByItemId(itemCfgInfo.axe_item_cfg_id)
    local ctrlDstItem = self._uiGOs.axesItems:FindDirect(("Item_%02d"):format(itemPosIdx))
    local lblProb = ctrlDstItem:FindDirect("Label_Chance")
    local iconItem = ctrlDstItem:FindDirect("Img_Icon")
    local lblNum = ctrlDstItem:FindDirect("Label_Num")
    local ctrlWorth = ctrlDstItem:FindDirect("Group_Price")
    local itemBaseCfg = ItemUtils.GetItemBase(itemCfgInfo.axe_item_cfg_id)
    local price = 0
    local awardCfg = AwardUtils.GetFixAwardIdByItemId(itemCfgInfo.axe_item_cfg_id)
    local awardCfgData = ItemUtils.GetGiftAwardCfgByAwardId(awardCfg.fixAwardId)
    local moneyType = ExchangeYuanBaoPanel.AXE_MONEY_TYPE
    if awardCfgData ~= nil then
      local moneyInfo = awardCfgData.moneyList[1]
      price = moneyInfo.num
      moneyType = moneyInfo.littleType
    end
    table.insert(self._curAwardItems, itemCfgInfo.axe_item_cfg_id)
    GUIUtils.SetText(lblProb, string.format("%d%%", itemCfgInfo.display_probability or 0))
    GUIUtils.SetTexture(iconItem, itemBaseCfg.icon)
    GUIUtils.SetText(lblNum, textRes.Award.ExchangeYuanBao[10]:format(itemCfgInfo.axe_num))
    self:SetUIItemPrice(itemCfgInfo.axe_num, price, moneyType, ctrlWorth)
  end
end
def.method("boolean")._toggleThrowCtrls = function(self, bUseAxe)
  self._uiGOs.groupThrow:FindDirect("Label_Num"):SetActive(bUseAxe)
  self._uiGOs.groupThrow:FindDirect("Btn_Confirm"):SetActive(bUseAxe)
  self._uiGOs.groupThrow:FindDirect("Group_UseDep"):SetActive(bUseAxe)
  if self:IsExpired() then
    self._uiGOs.groupMoneyThrow:SetActive(false)
    self._uiGOs.itemNeed:SetActive(false)
    self._uiGOs.itemNeedWorth:SetActive(false)
    self._uiGOs.groupUnlock:SetActive(true)
  else
    self._uiGOs.groupMoneyThrow:SetActive(not bUseAxe)
    self._uiGOs.itemNeed:SetActive(false)
    self._uiGOs.itemNeedWorth:SetActive(bUseAxe)
    self._uiGOs.groupUnlock:SetActive(false)
  end
end
def.method("number", "number", "number", "userdata").SetUIItemPrice = function(self, count, price, moneyType, ctrlRoot)
  local icon = ctrlRoot:FindDirect("Img_Money")
  local lbl = ctrlRoot:FindDirect("Label_Price")
  local moneyData = CurrencyFactory.Create(moneyType)
  GUIUtils.SetSprite(icon, moneyData:GetSpriteName())
  GUIUtils.SetText(lbl, textRes.Award.ExchangeYuanBao[13]:format(price * count))
end
def.method("=>", "boolean").IsShowConfirmUseYB = function(self)
  local content = textRes.Award.ExchangeYuanBao[4]
  local throwAxeCfgItemId = constant.CAxeItemConsts.WOOD_AXE_ITEM_CFG_ID
  local ownThrowAxes = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, throwAxeCfgItemId)
  local curSectId = self:GetCurrentSection()
  local secCfgData = AwardUtils.GetAxeSectioInfoByActIdandSecIdx(self._actId, curSectId)
  if secCfgData == nil then
    return false
  end
  local needThrowAxes = secCfgData.cost_num
  if ownThrowAxes < needThrowAxes then
    CommonConfirmDlg.ShowConfirm("", content, function(select)
      if select == 1 then
        local price = MallUtility.GetPriceByItemId(throwAxeCfgItemId)
        local costYB = (needThrowAxes - ownThrowAxes) * price
        self._externYB = costYB
        self:UpdateUIToggle(true)
        self:_changeBtnContent(ExchangeYuanBaoPanel.AXE_MONEY_TYPE, costYB)
      else
        self:UpdateUIToggle(false)
        self:_changeBtnContent(-1, 0)
      end
    end, nil)
    return true
  end
  return false
end
def.method("boolean").UpdateUIToggle = function(self, bShow)
  local ctrlToggleRoot = self._uiGOs.groupThrow:FindDirect("Group_UseDep")
  ctrlToggleRoot:SetActive(false)
end
def.method("number", "number")._changeBtnContent = function(self, moneyType, num)
  local groupMoney = self._uiGOs.groupThrow:FindDirect("Btn_Confirm/Group_Money")
  local lblName = self._uiGOs.groupThrow:FindDirect("Btn_Confirm/Label_Name")
  if moneyType == -1 then
    self:UpdateUIThrowBtn(true)
    GUIUtils.SetText(lblName, textRes.Award.ExchangeYuanBao[7]:format(textRes.Award.ExchangeYuanBao[11]))
  else
    self:UpdateUIThrowBtn(false)
    local icon = groupMoney:FindDirect("Img_MonryIcon")
    local lblMoney = groupMoney:FindDirect("Label_Money")
    local moneyData = CurrencyFactory.Create(moneyType)
    GUIUtils.SetSprite(icon, moneyData:GetSpriteName())
    GUIUtils.SetText(lblMoney, num)
  end
end
def.static("table", "table").OnAttenSuccess = function(p, context)
  local self = ExchangeYuanBaoPanel.Instance()
  if self:IsShow() then
    self._actId = p.activity_cfg_id
    self._sortId = p.sortid
    self:StartLottery()
  end
end
def.static("table", "table").OnAttenFail = function(p, context)
  local self = ExchangeYuanBaoPanel.Instance()
  self._bLockOpera = false
  GUIUtils.EnableButton(self._uiGOs.groupThrow:FindDirect("Btn_Confirm"), true)
  GUIUtils.EnableButton(self._uiGOs.groupMoneyThrow:FindDirect("btn_throw_money"), true)
end
def.static("table", "table").OnUnlockExchange = function(p, context)
  local self = ExchangeYuanBaoPanel.Instance()
  if self:IsShow() then
    self:UpdateUIExpired()
    self:UpdateUI()
  end
end
return ExchangeYuanBaoPanel.Commit()

local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIGodMedicine = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIGodMedicine
local def = Cls.define
local instance
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local GodMedicineUtils = require("Main.Gang.GodMedicine.GodMedicineUtils")
local GUIUtils = require("GUI.GUIUtils")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local GodMedicineMgr = require("Main.Gang.GodMedicine.GodMedicineMgr")
local txtConst = textRes.Gang.GodMedicine
def.field("table")._uiStatus = nil
def.field("table")._actCfg = nil
def.field("table")._costCfg = nil
def.field("table")._uiGOs = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = UIGodMedicine()
  end
  return instance
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, Cls.OnCurrencyChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, Cls.OnCurrencyChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, Cls.OnCurrencyChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, Cls.OnCurrencyChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, Cls.OnCurrencyChg, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.MakeMedicineSuccess, Cls.OnMakeMedicineGood, self)
  Event.RegisterEventWithContext(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, Cls.OnVigorChg, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, Cls.OnCurrencyChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, Cls.OnCurrencyChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, Cls.OnCurrencyChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, Cls.OnCurrencyChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, Cls.OnCurrencyChg)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.MakeMedicineSuccess, Cls.OnMakeMedicineGood)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, Cls.OnVigorChg)
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  uiGOs.lblTime = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_OpenTime/Label_OpenTime")
  uiGOs.lblLeftTimes = self.m_panel:FindDirect("Img_Bg0/Group_Make/Label_MakeNum")
  uiGOs.spriteTitle = self.m_panel:FindDirect("Img_Bg0/Img_Title")
  uiGOs.texDecoration = self.m_panel:FindDirect("Img_Bg0/Group_Dec/Img_Dec01")
  uiGOs.texMidImg = self.m_panel:FindDirect("Img_Bg0/Group_Info/Img_Icon")
  uiGOs.uiList = self.m_panel:FindDirect("Img_Bg0/Group_TitleLabel/Group_List")
  uiGOs.groupCurrency = self.m_panel:FindDirect("Img_Bg0/Group_CostMoney")
  uiGOs.groupVigor = self.m_panel:FindDirect("Img_Bg0/Group_CostAct")
  uiGOs.fx = self.m_panel:FindDirect("Img_Bg0/Point_Effect")
  self:eventsRegister()
  self:_initUI()
end
def.override().OnDestroy = function(self)
  self:eventsUnregister()
  self._actCfg = nil
  self._uiGOs = nil
  if self._uiStatus.timer and self._uiStatus.timer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._uiStatus.timer)
    self._uiStatus.timer = 0
  end
end
def.method()._initUI = function(self)
  self:customeUI()
  self:updateUIAwardsList()
  local leftTime = self:GetLeftTime()
  self:leftTimeCD(leftTime)
  self:_updateUIBottom()
end
def.method().customeUI = function(self)
  local uiGOs = self._uiGOs
  GUIUtils.SetSprite(uiGOs.spriteTitle, self._actCfg.titleSpriteName)
  GUIUtils.SetTexture(uiGOs.texDecoration, self._actCfg.decorationImgId)
  GUIUtils.SetTexture(uiGOs.texMidImg, self._actCfg.midDecorationImgId)
end
def.method().updateUIAwardsList = function(self)
  local itemList = self:GetShowAwardsList()
  local ctrlUIList = self._uiGOs.uiList
  local ctrlItemList = GUIUtils.InitUIList(ctrlUIList, #itemList)
  local ItemUtils = require("Main.Item.ItemUtils")
  for i = 1, #itemList do
    local itemBase = ItemUtils.GetItemBase(itemList[i])
    self:fillAwardInfo(ctrlItemList[i], itemBase, i)
  end
end
def.method("userdata", "table", "number").fillAwardInfo = function(self, ctrl, itemBase, idx)
  local imgIcon = ctrl:FindDirect("Texture_Icon_" .. idx)
  local lblItemName = ctrl:FindDirect("Label_Name_" .. idx)
  imgIcon.name = "Texture_Icon_" .. itemBase.itemid
  GUIUtils.SetTexture(imgIcon, itemBase.icon)
  GUIUtils.SetText(lblItemName, itemBase.name)
end
def.method("number").leftTimeCD = function(self, ileftTime)
  GUIUtils.SetText(self._uiGOs.lblTime, self:formatTime(ileftTime))
  self._uiStatus.timer = _G.GameUtil.AddGlobalTimer(1, false, function()
    if ileftTime < 0 then
      _G.GameUtil.RemoveGlobalTimer(self._uiStatus.timer)
      self._uiStatus.timer = 0
      self:DestroyPanel()
      return
    end
    if self ~= nil then
      GUIUtils.SetText(self._uiGOs.lblTime, self:formatTime(ileftTime))
    end
    ileftTime = ileftTime - 1
  end)
end
def.method("number", "=>", "string").formatTime = function(self, sec)
  local hour = math.floor(sec / 3600)
  local min = math.floor(sec % 3600 / 60)
  local sec = sec % 60
  return string.format("%02d:%02d:%02d", hour, min, sec)
end
def.method()._updateUIBottom = function(self)
  local myVigor = _G.GetHeroProp().energy
  local needVigor = self:getCostVigor()
  self._uiStatus.myVigor = myVigor
  self._uiStatus.needVigor = needVigor
  self._costCfg = self:GetCostCfg()
  local currencyType = self._costCfg.costType
  local currencyNum = GodMedicineMgr.GetMoneyNumByType(currencyType)
  local needCurrencyNum = self._costCfg.costNum
  self._uiStatus.myCurrencyNum = currencyNum
  self._uiStatus.needCurrencyNum = needCurrencyNum
  local iLeftTimes = self:GetLeftTimes(self._actCfg.actId)
  self._uiStatus.iLeftTimes = iLeftTimes
  local uiGOs = self._uiGOs
  local spriteIconCurrency = uiGOs.groupCurrency:FindDirect("Img_BgUseMoney/Img_UseMoneyIcon")
  local lblNumCurrency = uiGOs.groupCurrency:FindDirect("Img_BgUseMoney/Label_UseMoneyNum")
  local moneyData = CurrencyFactory.Create(currencyType)
  GUIUtils.SetSprite(spriteIconCurrency, moneyData:GetSpriteName())
  GUIUtils.SetText(lblNumCurrency, needCurrencyNum)
  spriteIconCurrency = uiGOs.groupCurrency:FindDirect("Img_BgHaveMoney/Img_HaveMoneyIcon")
  lblNumCurrency = uiGOs.groupCurrency:FindDirect("Img_BgHaveMoney/Label_HaveMoneyNum")
  GUIUtils.SetSprite(spriteIconCurrency, moneyData:GetSpriteName())
  GUIUtils.SetText(lblNumCurrency, currencyNum:tostring())
  local lblVigor = uiGOs.groupVigor:FindDirect("Img_BgUseAct/Label_UseActNum")
  GUIUtils.SetText(lblVigor, needVigor)
  lblVigor = uiGOs.groupVigor:FindDirect("Img_BgHaveAct/Label_HaveActNum")
  GUIUtils.SetText(lblVigor, myVigor)
  GUIUtils.SetText(uiGOs.lblLeftTimes, iLeftTimes)
end
def.method("number").ShowPanel = function(self, actId)
  self._uiStatus = {}
  self._actCfg = GodMedicineUtils.GetActivityCfgById(actId)
  self._costCfg = GodMedicineMgr.GetCostCfg(actId)
  self:CreatePanel(RESPATH.PREFAB_GANG_MEDICINE_MAKE, 1)
  self:SetModal(true)
end
def.method("number", "boolean").GotoBuyCurrency = function(self, mtype, bconfirm)
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
def.method("number", "=>", "number").GetLeftTimes = function(self, actId)
  if self._costCfg == nil then
    self._costCfg = GodMedicineMgr.GetCostCfg(actId)
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local activityInfo = activityInterface:GetActivityInfo(actId)
  if activityInfo == nil then
    return self._costCfg.maxTimes
  else
    return self._costCfg.maxTimes - activityInfo.count
  end
end
def.method("=>", "number").getCostVigor = function(self)
  local lifeSkillId = self._actCfg.lifeSkillId
  local lv = self:GetMyLifeSkillLv()
  local costVigor = require("Main.Skill.LivingSkillUtility").GetCostVigor(self._costCfg.lifeSkillId, lv)
  return costVigor
end
def.method("=>", "number").GetLeftTime = function(self)
  local _, timeList, _ = require("Main.activity.ActivityInterface").Instance():getActivityStatusChangeTime(self._actCfg.actId)
  local nowSec = _G.GetServerTime()
  local leftTime = 10000
  for i = 1, #timeList do
    local timeRange = timeList[i]
    if nowSec >= timeRange.beginTime and nowSec <= timeRange.resetTime then
      leftTime = timeRange.resetTime - nowSec
      break
    end
  end
  return leftTime
end
def.method("=>", "table").GetCostCfg = function(self)
  local cfg = GodMedicineMgr.GetCostCfg(self._actCfg.actId)
  return cfg
end
def.method("=>", "table").GetShowAwardsList = function(self)
  local lifeSkillLv = self:GetMyLifeSkillLv()
  local cfg = GodMedicineUtils.GetShowItemsByActidAndLv(self._actCfg.actId, lifeSkillLv)
  return cfg and cfg.itemList or {}
end
def.method("=>", "number").GetMyLifeSkillLv = function(self)
  local skillBag = require("Main.Skill.data.LivingSkillData").Instance():GetSkillBagById(self._actCfg.lifeSkillId)
  return skillBag.level
end
def.method().displayFx = function(self)
  local GUIFxMan = require("Fx.GUIFxMan")
  if self._uiGOs.effectObj then
    GUIFxMan.Instance():RemoveFx(self._uiGOs.effectObj)
    self._uiGOs.effectObj = nil
  end
  local effectCfg = _G.GetEffectRes(self._actCfg.successEffectId)
  if effectCfg then
    local parent = self._uiGOs.fx
    self._uiGOs.effectObj = GUIFxMan.Instance():PlayAsChild(parent, effectCfg.path, 0, 0, -1, false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("id", id)
  if "Btn_Add" == id then
    self:GotoBuyCurrency(self._costCfg.costType, false)
  elseif "Btn_Help" == id then
    GUIUtils.ShowHoverTip(self._actCfg.hoverTipsId, 0, 0)
  elseif "Btn_Make" == id then
    self:OnClickMake()
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "Img_BgIcon_") then
    local child = clickObj:FindChildByPrefix("Texture_Icon_")
    local strs = string.split(child.name, "_")
    local itemId = tonumber(strs[3])
    self:OnClickAwardItem(clickObj, itemId)
  end
end
def.method().OnClickMake = function(self)
  local status = self._uiStatus
  local bCurrencyEnough = not status.myCurrencyNum:lt(status.needCurrencyNum)
  local bVigorEnough = status.needVigor <= status.myVigor
  local bLeftTimesEnough = status.iLeftTimes > 0
  if not bCurrencyEnough then
    local moneyData = CurrencyFactory.Create(1)
    Toast(txtConst[1]:format(moneyData:GetName()))
  elseif not bVigorEnough then
    Toast(txtConst[2])
  elseif not bLeftTimesEnough then
    Toast(txtConst[3])
  else
    GodMedicineMgr.CSendGetLifeSkillAwards(self._actCfg.actId)
  end
end
def.method("userdata", "number").OnClickAwardItem = function(self, clickObj, itemId)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, clickObj, 0, false)
end
def.method("table").OnCurrencyChg = function(self, p)
  self:_updateUIBottom()
end
def.method("table").OnMakeMedicineGood = function(self, p)
  if p.activityId == self._actCfg.actId then
    self:_updateUIBottom()
    self:displayFx()
  end
end
def.method("table").OnVigorChg = function(self, p)
  self:_updateUIBottom()
end
return Cls.Commit()

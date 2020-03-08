local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BabyCarePanel = Lplus.Extend(ECPanelBase, "BabyCarePanel")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local BabyOperatorEnum = require("consts.mzm.gsp.children.confbean.BabyOperatorEnum")
local BabyOperatorCostCurrencyEnum = require("consts.mzm.gsp.children.confbean.BabyOperatorCostCurrencyEnum")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local ChildrenOperation = require("Main.Children.ui.ChildrenOperation")
local Child = require("Main.Children.Child")
local ChildrenModule = require("Main.Children.ChildrenModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = BabyCarePanel.define
local instance
local const = constant.CChildrenConsts
def.field("table").uiObjs = nil
def.field("userdata").babyId = nil
def.field("number").selectedOperate = BabyOperatorEnum.SUCKLE
def.field(ChildrenOperation).childOpe = nil
def.field(Child).childModel = nil
def.field("boolean").isDrag = false
def.static("=>", BabyCarePanel).Instance = function()
  if instance == nil then
    instance = BabyCarePanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, babyId)
  if self.m_panel ~= nil then
    return
  end
  self.babyId = babyId
  self:CreatePanel(RESPATH.PREFAB_BABY_CARE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateName()
  self:UpdateChildTurnCardClassType()
  self:UpdateModel()
  self:UpdateCurrency()
  self:UpdateBabyState()
  self:UpdateBabyOperate()
  self:UpdateOperateTips()
  self.childOpe = ChildrenOperation.CreateNew(self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Menu/Group_ChooseType"), self.babyId)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BABY_DATA_CHANGE, BabyCarePanel.OnBabyDataChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Baby_Teen, BabyCarePanel.OnChildPromote)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, BabyCarePanel.OnNameChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, BabyCarePanel.OnHeroEnergyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, BabyCarePanel.OnSilverMoneyChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Featur_Openchange, BabyCarePanel.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, BabyCarePanel.OnChildUpdate)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, BabyCarePanel.OnChildrenFashionChange)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.HIRE_NANNY_SUCCESS, BabyCarePanel.OnHireNannySuccess)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.babyId = nil
  self.childOpe:Destroy()
  self.childOpe = nil
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
    self.childModel = nil
  end
  self.isDrag = false
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BABY_DATA_CHANGE, BabyCarePanel.OnBabyDataChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Baby_Teen, BabyCarePanel.OnChildPromote)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, BabyCarePanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, BabyCarePanel.OnHeroEnergyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, BabyCarePanel.OnSilverMoneyChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Featur_Openchange, BabyCarePanel.OnFeatureOpenChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, BabyCarePanel.OnChildUpdate)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, BabyCarePanel.OnChildrenFashionChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.HIRE_NANNY_SUCCESS, BabyCarePanel.OnHireNannySuccess)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Left = self.uiObjs.Img_Bg0:FindDirect("Group_Left")
  self.uiObjs.Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
end
def.method().UpdateName = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return
  end
  local nameLbl = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Menu/Img_Bg/Label_Current")
  local name = babyData:GetName()
  nameLbl:GetComponent("UILabel"):set_text(name)
end
def.method().UpdateChildTurnCardClassType = function(self)
  local Img_Tpye = self.m_panel:FindDirect("Img_Bg0/Group_Left/Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(constant.CChildrenConsts.cardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method().UpdateModel = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return
  end
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
  end
  local fashion = babyData:GetFashionByPhase(babyData:GetStatus())
  self.childModel = Child.CreateWithFashion(babyData:GetModelCfgId(), fashion and fashion.fashionId or 0)
  local uiModel = self.m_panel:FindDirect("Img_Bg0/Group_Left/Model_Baby"):GetComponent("UIModel")
  self.childModel:LoadUIModel(nil, function()
    uiModel.modelGameObject = self.childModel.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
end
def.method().UpdateCurrency = function(self)
  local Label_ActName = self.m_panel:FindDirect("Img_Bg0/Group_Left/Label_ActName")
  local Label_Money = self.m_panel:FindDirect("Img_Bg0/Group_Left/Label_Money")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local ItemModule = require("Main.Item.ItemModule")
  local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  GUIUtils.SetText(Label_ActName:FindDirect("Label_Num"), string.format("%d/%d", heroProp.energy, heroProp:GetMaxEnergy()))
  GUIUtils.SetText(Label_Money:FindDirect("Label_Num"), silver:tostring())
end
def.method().UpdateBabyState = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  local Group_State = self.uiObjs.Group_Right:FindDirect("Group_State")
  local stateSlider = {
    "Slider_Health",
    "Slider_Mood",
    "Slider_Clean",
    "Slider_Tired"
  }
  local curState = {
    babyData:GetBaoshiProperty(),
    babyData:GetMoodProperty(),
    babyData:GetCleanProperty(),
    babyData:GetTiredProperty()
  }
  local stateFullValue = {
    constant.CChildrenConsts.baby_max_bao_shi_value,
    constant.CChildrenConsts.baby_max_moood_value,
    constant.CChildrenConsts.baby_max_clean_value,
    constant.CChildrenConsts.baby_max_tired_value
  }
  local bHasNanny = babyData:IsHasNanny()
  local nannyAllStateVal = {
    const.baby_auto_bao_shi_value,
    const.baby_auto_mood_value,
    const.baby_auto_clean_value,
    const.baby_auto_tired_value
  }
  for i = 1, #stateSlider do
    local slider = Group_State:FindDirect(stateSlider[i])
    local Label_Slider = slider:FindDirect("Label_Slider")
    local curStateVal = curState[i]
    if bHasNanny then
      curStateVal = nannyAllStateVal[i]
    end
    GUIUtils.SetText(Label_Slider, string.format("%d/%d", curStateVal, stateFullValue[i]))
    slider:GetComponent("UISlider").value = curStateVal / stateFullValue[i]
  end
  local Slider_Health = self.uiObjs.Group_Left:FindDirect("Slider_Health")
  local Label_Slider = Slider_Health:FindDirect("Label_Slider")
  local progress = babyData:GetHealthScore() / constant.CChildrenConsts.baby_to_childhood_need_health_value
  Slider_Health:GetComponent("UISlider").value = progress
  GUIUtils.SetText(Label_Slider, string.format("%d/%d", babyData:GetHealthScore(), constant.CChildrenConsts.baby_to_childhood_need_health_value))
  local Btn_GrowUp = self.uiObjs.Group_Right:FindDirect("Btn_GrowUp")
  GUIUtils.SetActive(Btn_GrowUp, babyData:IsFullHealthScore())
end
def.method().UpdateBabyOperate = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  local Group_Btn = self.uiObjs.Group_Right:FindDirect("Group_Btn")
  local operateBtn = {
    [BabyOperatorEnum.SUCKLE] = "Btn_YangYu",
    [BabyOperatorEnum.CHANGE_DIAPER] = "Btn_DaoZhe",
    [BabyOperatorEnum.TICKLE] = "Btn_DouLe",
    [BabyOperatorEnum.SLEEP] = "Btn_XieDai"
  }
  local bHasNanny = babyData and babyData:IsHasNanny() or false
  local healthyVal = babyData and babyData:GetHealthScore() or 0
  local bHealthyFull = healthyVal >= const.baby_to_childhood_need_health_value
  for k, v in pairs(operateBtn) do
    local btn = Group_Btn:FindDirect(v)
    btn:GetComponent("UIToggle").value = false
    if bHasNanny and not bHealthyFull then
      btn:SetActive(false)
    else
      btn:SetActive(true)
    end
  end
  Group_Btn:FindDirect(operateBtn[self.selectedOperate]):GetComponent("UIToggle").value = true
end
def.method().UpdateOperateTips = function(self)
  local Group_Info = self.uiObjs.Group_Right:FindDirect("Group_Info")
  local Info_YangYu = Group_Info:FindDirect("Info_YangYu")
  local Info_Sleep = Group_Info:FindDirect("Info_Sleep")
  local Btn_Start = self.uiObjs.Group_Right:FindDirect("Btn_Start")
  local BtnBabySitter = self.uiObjs.Group_Right:FindDirect("Btn_Babysitter")
  local GroupBabysitter = self.uiObjs.Group_Right:FindDirect("Group_Babysitter")
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  local bNannyFeatureOpen = ChildrenModule.Instance():IsNannyFeatureOpen()
  local bHasNanny = babyData:IsHasNanny()
  local Label_State01 = Info_Sleep:FindDirect("Label_State01")
  local Label_State02 = Info_Sleep:FindDirect("Label_State02")
  local lblNannyInfo = Group_Info:FindDirect("Label_YueSaoTips")
  local needYB = self:HireNannyNeedYuanBao()
  local bHealthyFull = babyData:GetHealthScore() >= const.baby_to_childhood_need_health_value
  Btn_Start:SetActive(not bHasNanny)
  BtnBabySitter:SetActive(bNannyFeatureOpen and not bHasNanny and not bHealthyFull)
  local lblYB = BtnBabySitter:FindDirect("Group_Yuanbao/Label_Money")
  GUIUtils.SetText(lblYB, needYB:tostring())
  GroupBabysitter:SetActive(bHasNanny and not bHealthyFull)
  lblNannyInfo:SetActive(bHasNanny and not bHealthyFull)
  Label_State02:SetActive(not bHasNanny)
  if bHasNanny and not bHealthyFull then
    GUIUtils.SetActive(Info_YangYu, false)
    GUIUtils.SetActive(Info_Sleep, false)
    GUIUtils.SetText(lblNannyInfo, textRes.Children[1053] .. textRes.Children[1054])
  elseif self.selectedOperate == BabyOperatorEnum.SLEEP then
    GUIUtils.SetActive(Info_YangYu, false)
    GUIUtils.SetActive(Info_Sleep, true)
    if babyData:IsSleeping() then
      GUIUtils.SetText(Btn_Start:FindDirect("Label"), textRes.Children.BabyOperateName.Awake)
      GUIUtils.SetText(Label_State01, textRes.Children[1026])
      local str = ChildrenUtils.ConvertSecondToStr(babyData:GetRemainOperatorSeconds())
      GUIUtils.SetText(Label_State02, str)
    else
      GUIUtils.SetText(Btn_Start:FindDirect("Label"), textRes.Children.BabyOperateName.Sleep)
      GUIUtils.SetText(Label_State01, textRes.Children[1027])
      GUIUtils.SetText(Label_State02, textRes.Children[1028])
    end
  else
    GUIUtils.SetActive(Info_YangYu, true)
    GUIUtils.SetActive(Info_Sleep, false)
    local opName = textRes.Children.BabyOperateName[self.selectedOperate]
    GUIUtils.SetText(Btn_Start:FindDirect("Label"), opName)
    local Label_WeiNai = Info_YangYu:FindDirect("Label_WeiNai")
    GUIUtils.SetText(Label_WeiNai, opName)
    local operateCfg = ChildrenUtils.GetBabyOperateCfg(self.selectedOperate)
    if operateCfg == nil then
      warn("operateCfg is nil")
      return
    end
    local propertyLabel = {
      "Label_Clean",
      "Label_Tired"
    }
    local costLabel = {
      "Label_Energy",
      "Label_Money"
    }
    for i = 1, #propertyLabel do
      if operateCfg.property[i] == nil then
        GUIUtils.SetActive(Info_YangYu:FindDirect(propertyLabel[i]), false)
      else
        GUIUtils.SetActive(Info_YangYu:FindDirect(propertyLabel[i]), true)
        GUIUtils.SetText(Info_YangYu:FindDirect(propertyLabel[i]), textRes.Children.BabyPropertyName[operateCfg.property[i].propertyType])
        GUIUtils.SetText(Info_YangYu:FindDirect(propertyLabel[i] .. "/Label_Num"), string.format("+%d", operateCfg.property[i].value))
      end
    end
    for i = 1, #costLabel do
      if operateCfg.cost[i] == nil then
        GUIUtils.SetActive(Info_YangYu:FindDirect(costLabel[i]), false)
      else
        GUIUtils.SetActive(Info_YangYu:FindDirect(costLabel[i]), true)
        GUIUtils.SetText(Info_YangYu:FindDirect(costLabel[i]), textRes.Children.BabyOperatorCostCurrencyName[operateCfg.cost[i].currencyType])
        GUIUtils.SetText(Info_YangYu:FindDirect(costLabel[i] .. "/Label_Num"), string.format("%d", operateCfg.cost[i].value))
      end
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_YangYu" then
    self:OnClickSuckleBtn()
  elseif id == "Btn_DaoZhe" then
    self:OnClickChangeDiaperBtn()
  elseif id == "Btn_DouLe" then
    self:OnClickTickleBtn()
  elseif id == "Btn_XieDai" then
    self:OnClickSleepBtn()
  elseif id == "Btn_Start" then
    self:OnClickStartBtn()
  elseif id == "Btn_GrowUp" then
    self:OnClickGrowUpBtn()
  elseif id == "Btn_Stratagy" then
    self:OnClickTipsBtn()
  elseif self.childOpe and self.childOpe:onClick(id) then
  elseif id == "Btn_Babysitter" then
    self:OnClickHireNanny()
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if self:IsShow() and id == "Img_Bg" and self.childOpe then
    if active then
      self.childOpe:Show(nil)
    else
      self.childOpe:Hide()
    end
  end
end
def.method().OnClickSuckleBtn = function(self)
  self.selectedOperate = BabyOperatorEnum.SUCKLE
  self:UpdateBabyOperate()
  self:UpdateOperateTips()
end
def.method().OnClickChangeDiaperBtn = function(self)
  self.selectedOperate = BabyOperatorEnum.CHANGE_DIAPER
  self:UpdateBabyOperate()
  self:UpdateOperateTips()
end
def.method().OnClickTickleBtn = function(self)
  self.selectedOperate = BabyOperatorEnum.TICKLE
  self:UpdateBabyOperate()
  self:UpdateOperateTips()
end
def.method().OnClickSleepBtn = function(self)
  self.selectedOperate = BabyOperatorEnum.SLEEP
  self:UpdateBabyOperate()
  self:UpdateOperateTips()
end
def.method().OnClickStartBtn = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return
  end
  if self.selectedOperate == BabyOperatorEnum.SLEEP then
    if babyData:IsSleeping() then
      self:AwakeChild()
    else
      self:MakeChildSleep()
    end
  else
    self:BreedChild()
  end
end
def.method().AwakeChild = function(self)
  require("Main.Children.mgr.BabyMgr").Instance():WakeUpBabyChild(self.babyId)
end
def.method().MakeChildSleep = function(self)
  if not self:CheckAndToastSleep() then
    return
  end
  require("Main.Children.mgr.BabyMgr").Instance():StartBreedBabyChild(self.selectedOperate, self.babyId)
end
def.method().BreedChild = function(self)
  if not self:CheckAndToastSleep() then
    return
  end
  if not self:CheckAndToastTired() then
    return
  end
  if not self:CheckAndToastCost() then
    return
  end
  if not self:CheckAndToastProperty() then
    return
  end
  require("Main.Children.mgr.BabyMgr").Instance():StartBreedBabyChild(self.selectedOperate, self.babyId)
end
def.method("=>", "boolean").CheckAndToastSleep = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return true
  end
  if babyData:IsSleeping() then
    Toast(textRes.Children[1037])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckAndToastTired = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return false
  end
  if babyData:IsFullTired() then
    Toast(textRes.Children[1030])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckAndToastCost = function(self)
  local operateCfg = ChildrenUtils.GetBabyOperateCfg(self.selectedOperate)
  if operateCfg == nil then
    warn("operateCfg is nil")
    return false
  end
  local isMeetRequire = true
  local cost = {}
  for i = 1, #operateCfg.cost do
    if operateCfg.cost[i].currencyType == BabyOperatorCostCurrencyEnum.VIGOR then
      local curActive = require("Main.Hero.Interface").GetHeroProp().energy
      if curActive < operateCfg.cost[i].value then
        isMeetRequire = false
      end
    else
      local CurrencyFactory = require("Main.Currency.CurrencyFactory")
      local moneyData = CurrencyFactory.Create(operateCfg.cost[i].currencyType)
      if Int64.lt(moneyData:GetHaveNum(), operateCfg.cost[i].value) then
        moneyData:AcquireWithQuery()
        return false
      end
    end
    table.insert(cost, string.format("%d%s", operateCfg.cost[i].value, textRes.Children.BabyOperatorCostCurrencyName[operateCfg.cost[i].currencyType]))
  end
  if isMeetRequire then
    return true
  else
    Toast(string.format(textRes.Children[1029], table.concat(cost, "\239\188\140")))
    return false
  end
end
def.method("=>", "boolean").CheckAndToastProperty = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return false
  end
  if self.selectedOperate == BabyOperatorEnum.SUCKLE and babyData:IsFullBaoshiProperty() then
    Toast(textRes.Children[1047])
    return false
  elseif self.selectedOperate == BabyOperatorEnum.CHANGE_DIAPER and babyData:IsFullCleanProperty() then
    Toast(textRes.Children[1048])
    return false
  elseif self.selectedOperate == BabyOperatorEnum.TICKLE and babyData:IsFullMoodProperty() then
    Toast(textRes.Children[1049])
    return false
  end
  return true
end
def.method().OnClickGrowUpBtn = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return
  end
  if not babyData:IsFullHealthScore() then
    Toast(textRes.Children[1035])
    return
  end
  require("Main.Children.mgr.BabyMgr").Instance():BabyToChildHood(self.babyId)
end
def.method().OnClickTipsBtn = function(self)
  local bNannyFeatureOpen = ChildrenModule.Instance():IsNannyFeatureOpen()
  if bNannyFeatureOpen then
    GUIUtils.ShowHoverTip(const.auto_breed_tips)
  else
    GUIUtils.ShowHoverTip(constant.CChildrenConsts.baby_child_health_tips)
  end
end
def.method("=>", "userdata").HireNannyNeedYuanBao = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return Int64.new(0)
  end
  local NeedhealtyVal = const.baby_to_childhood_need_health_value - babyData:GetHealthScore()
  local needYB = Int64.new(NeedhealtyVal * const.auto_breed_cost_yuanbao_per_health_point)
  return needYB
end
def.method().OnClickHireNanny = function(self)
  local babyData = ChildrenDataMgr.Instance():GetChildById(self.babyId)
  if babyData == nil then
    return
  end
  if babyData:IsFullHealthScore() then
    Toast(textRes.Children[1057])
    return
  end
  local needYB = self:HireNannyNeedYuanBao()
  local title = textRes.Children[1055]
  local content = textRes.Children[1056]:format(needYB:tostring())
  CommonConfirmDlg.ShowConfirm(title, content, function(select)
    if select == 1 then
      local owndYB = require("Main.Item.ItemModule").Instance():GetAllYuanBao()
      if owndYB:lt(needYB) then
        Toast(textRes.Children.SChildNormalFail[61])
        return
      end
      require("Main.Children.mgr.BabyMgr").Instance():HireNannyReq(self.babyId, owndYB)
    end
  end, nil)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:ResetModelAnimation()
  end
end
def.method().ResetModelAnimation = function(self)
  if self.childModel and self.childModel:GetModel() then
    self.childModel:GetModel():Play("Stand_c")
  end
end
def.method("string").onDragStart = function(self, id)
  if self:IsShow() and id == "Model_Baby" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  if self:IsShow() and self.isDrag then
    self.isDrag = false
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self:IsShow() and self.isDrag == true and self.childModel and self.childModel:GetModel() then
    self.childModel:GetModel():SetDir(self.childModel:GetModel():GetDir() - dx / 2)
  end
end
def.static("table", "table").OnBabyDataChanged = function(params, context)
  local babyData = ChildrenDataMgr.Instance():GetChildById(instance.babyId)
  if babyData == nil then
    instance:DestroyPanel()
  elseif params ~= nil then
    for idx, childId in pairs(params) do
      if childId == instance.babyId then
        instance:UpdateBabyState()
        instance:UpdateBabyOperate()
        instance:UpdateOperateTips()
      end
    end
  end
end
def.static("table", "table").OnChildPromote = function(params, context)
  local childId = params[1]
  if childId == instance.babyId then
    instance:DestroyPanel()
  end
end
def.static("table", "table").OnNameChange = function(params, context)
  local childId = params[1]
  if instance.babyId == childId then
    instance:UpdateName()
  end
end
def.static("table", "table").OnHeroEnergyChanged = function(params, context)
  instance:UpdateCurrency()
end
def.static("table", "table").OnSilverMoneyChanged = function(params, context)
  instance:UpdateCurrency()
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local open = params.open
  if not open then
    instance:DestroyPanel()
    Toast(textRes.Children[1042])
  end
end
def.static("table", "table").OnChildUpdate = function(params, context)
  local childrenDataMgr = ChildrenDataMgr.Instance()
  local babyData = childrenDataMgr:GetChildById(instance.babyId)
  if babyData == nil then
    instance:DestroyPanel()
  end
end
def.static("table", "table").OnChildrenFashionChange = function(params, context)
  local childId = params[1]
  if instance.babyId == childId then
    instance:UpdateModel()
  end
end
def.static("table", "table").OnHireNannySuccess = function(p, c)
  if p.childId:eq(instance.babyId) then
    instance:UpdateBabyState()
    instance:UpdateBabyOperate()
    instance:UpdateOperateTips()
  end
end
BabyCarePanel.Commit()
return BabyCarePanel

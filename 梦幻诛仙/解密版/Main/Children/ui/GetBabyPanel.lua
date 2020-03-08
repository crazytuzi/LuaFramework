local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GetBabyPanel = Lplus.Extend(ECPanelBase, "GetBabyPanel")
local GUIUtils = require("GUI.GUIUtils")
local GetBabyPhaseData = require("Main.Children.data.GetBabyPhaseData")
local BreedStepEnum = require("consts.mzm.gsp.children.confbean.BreedStepEnum")
local BreedTypeEnum = require("consts.mzm.gsp.children.confbean.BreedTypeEnum")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local GetBabyActivityTips = require("Main.Children.ui.GetBabyActivityTips")
local TipsHelper = require("Main.Common.TipsHelper")
local def = GetBabyPanel.define
local instance
def.field("table").uiObjs = nil
def.static("=>", GetBabyPanel).Instance = function()
  if instance == nil then
    instance = GetBabyPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GET_BABY_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateGetBabyStatus()
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GET_BABY_PHASE_CHANGED, GetBabyPanel.OnGetBabyPhaseChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GIVE_BIRTH_CHILD_REMAIN_TIME_CHANGE, GetBabyPanel.OnGiveBirthChildRemainTimeChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, GetBabyPanel.OnLeaveHomeland)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Featur_Openchange, GetBabyPanel.OnFeatureOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GET_BABY_PHASE_CHANGED, GetBabyPanel.OnGetBabyPhaseChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GIVE_BIRTH_CHILD_REMAIN_TIME_CHANGE, GetBabyPanel.OnGiveBirthChildRemainTimeChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, GetBabyPanel.OnLeaveHomeland)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Featur_Openchange, GetBabyPanel.OnFeatureOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Left = self.uiObjs.Img_Bg0:FindDirect("Group_Left")
  self.uiObjs.Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
end
def.method().UpdateGetBabyStatus = function(self)
  self:UpdateCoupleStatus()
  self:UpdateSingleStatus()
end
def.method().UpdateCoupleStatus = function(self)
  local Group_State = self.uiObjs.Group_Left:FindDirect("Group_State")
  local Slider_QZ_EXP = self.uiObjs.Group_Left:FindDirect("Slider_QZ_EXP")
  local Btn_GiveUp = self.uiObjs.Group_Left:FindDirect("Btn_GiveUp")
  local Label_State = Slider_QZ_EXP:FindDirect("Label_State")
  local Label_QZ_SliderEXP = Slider_QZ_EXP:FindDirect("Label_QZ_SliderEXP")
  local Img_QZ_EXP = Slider_QZ_EXP:FindDirect("Img_QZ_EXP")
  local Label_State2 = self.uiObjs.Group_Left:FindDirect("Label_State")
  local breedData = GetBabyPhaseData.Instance()
  local curStep = breedData:GetCurrentBreedStep() > 0 and breedData:GetCurrentBreedStep() or 1
  local curScore = breedData:GetCurrentBreedScore()
  if breedData:IsCoupleBreeding() then
    if curStep == BreedStepEnum.GIVE_BIRTH then
      GUIUtils.SetActive(Slider_QZ_EXP, false)
      GUIUtils.SetActive(Btn_GiveUp, false)
      GUIUtils.SetActive(Label_State2, true)
      local str = ChildrenUtils.ConvertSecondToStr(breedData:GetRemainGiveBirthTime())
      GUIUtils.SetText(Label_State2, string.format(textRes.Children[1024], str))
    else
      GUIUtils.SetActive(Slider_QZ_EXP, true)
      GUIUtils.SetActive(Btn_GiveUp, true)
      GUIUtils.SetActive(Label_State2, false)
      GUIUtils.SetText(Label_State, string.format(textRes.Children[1001], textRes.Children.BreedPhaseName[curStep]))
      GUIUtils.SetText(Label_QZ_SliderEXP, string.format("%d/%d", curScore, GetBabyPhaseData.COUPLE_PHASE_SOCRE[curStep]))
      local process = curScore / GetBabyPhaseData.COUPLE_PHASE_SOCRE[curStep]
      Slider_QZ_EXP:GetComponent("UISlider").value = process
    end
  else
    GUIUtils.SetActive(Slider_QZ_EXP, false)
    GUIUtils.SetActive(Btn_GiveUp, false)
    GUIUtils.SetActive(Label_State2, false)
  end
  for i = 1, GetBabyPhaseData.COUPLE_PHASE_NUMBER do
    local stepState = Group_State:FindDirect(string.format("Img_State%d", i))
    local btnLock = stepState:FindDirect("Btn_Lock")
    local Img_Finish = stepState:FindDirect("Img_Finish")
    local Label_Name = stepState:FindDirect("Label_Name")
    GUIUtils.SetText(Label_Name, textRes.Children.BreedPhaseName[i])
    if curStep >= i then
      GUIUtils.SetActive(btnLock, false)
    else
      GUIUtils.SetActive(btnLock, true)
    end
    if curStep > i then
      GUIUtils.SetActive(Img_Finish, true)
    else
      GUIUtils.SetActive(Img_Finish, false)
    end
  end
end
def.method().UpdateSingleStatus = function(self)
  local Label_Details = self.uiObjs.Group_Right:FindDirect("Label_Details")
  GUIUtils.SetText(Label_Details, require("Main.Common.TipsHelper").GetHoverTip(constant.CChildrenConsts.signal_get_child_tips))
  local Slider_SX_EXP = self.uiObjs.Group_Right:FindDirect("Slider_SX_EXP")
  local Btn_GiveUp = self.uiObjs.Group_Right:FindDirect("Btn_GiveUp")
  local Label_State = Slider_SX_EXP:FindDirect("Label_State")
  local Label_SX_SliderEXP = Slider_SX_EXP:FindDirect("Label_SX_SliderEXP")
  local Img_SX_EXP = Slider_SX_EXP:FindDirect("Img_SX_EXP")
  local Img_State = self.uiObjs.Group_Right:FindDirect("Img_State")
  local Btn_Lock = Img_State:FindDirect("Btn_Lock")
  GUIUtils.SetActive(Btn_Lock, false)
  local breedData = GetBabyPhaseData.Instance()
  local curScore = breedData:GetCurrentBreedScore()
  if breedData:IsSingleBreeding() then
    GUIUtils.SetActive(Slider_SX_EXP, true)
    GUIUtils.SetActive(Btn_GiveUp, true)
    GUIUtils.SetText(Label_State, textRes.Children[1002])
    GUIUtils.SetText(Label_SX_SliderEXP, string.format("%d/%d", curScore, GetBabyPhaseData.SINGLE_PHASE_SCORE))
    local process = curScore / GetBabyPhaseData.SINGLE_PHASE_SCORE
    Slider_SX_EXP:GetComponent("UISlider").value = process
  else
    GUIUtils.SetActive(Slider_SX_EXP, false)
    GUIUtils.SetActive(Btn_GiveUp, false)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_State" then
    self:OnClickSingleBtn()
  elseif string.find(id, "Img_State") then
    local step = tonumber(string.sub(id, #"Img_State" + 1))
    if step ~= nil then
      self:OnClickCoupleStepBtn(step)
    end
  elseif id == "Btn_Lock" then
    local step = tonumber(string.sub(obj.parent.name, #"Img_State" + 1))
    if step ~= nil then
      self:OnClickCoupleStepBtn(step)
    end
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_GiveUp" then
    self:OnClickGiveUpBtn()
  end
end
def.method().OnClickSingleBtn = function(self)
  local breedCfg = ChildrenUtils.GetBreedStepCfg(BreedTypeEnum.SINGLE_BREED, BreedStepEnum.PREPARE_PREGNANT)
  local desc = breedCfg and TipsHelper.GetHoverTip(breedCfg.step_description_tips_id) or ""
  GetBabyActivityTips.Instance():ShowPanelWithCallback(desc, function()
    self:SingleGiveBirth()
  end)
end
def.method().SingleGiveBirth = function(self)
  local breedData = GetBabyPhaseData.Instance()
  if breedData:IsCoupleBreeding() then
    Toast(textRes.Children[1008])
    return
  end
  require("Main.Children.mgr.BabyMgr").Instance():SingleGiveBirth()
end
def.method("number").OnClickCoupleStepBtn = function(self, step)
  local stepProcessFunc = {
    self.InvitePreparePregnant,
    self.Pregnant,
    self.BabyEducate,
    self.GiveBirth
  }
  local breedData = GetBabyPhaseData.Instance()
  local curStep = breedData:GetCurrentBreedStep()
  local breedCfg = ChildrenUtils.GetBreedStepCfg(BreedTypeEnum.COUPLE_BREED, step)
  local desc = breedCfg and TipsHelper.GetHoverTip(breedCfg.step_description_tips_id) or ""
  if step == curStep then
    GetBabyActivityTips.Instance():ShowPanelWithCallback(desc, function()
      if breedData:IsSingleBreeding() then
        Toast(textRes.Children[1007])
        return
      end
      if stepProcessFunc[step] ~= nil then
        stepProcessFunc[step](self)
      end
    end)
  elseif step < curStep then
    GetBabyActivityTips.Instance():ShowPanelWithCondition(desc, textRes.Children[1005])
  else
    GetBabyActivityTips.Instance():ShowPanelWithCondition(desc, textRes.Children[1006])
  end
end
def.method().InvitePreparePregnant = function(self)
  require("Main.Children.mgr.BabyMgr").Instance():InvitePreparePregnant()
end
def.method().Pregnant = function(self)
  local babyMgr = require("Main.Children.mgr.BabyMgr").Instance()
  if not babyMgr:CanDoCoupleActivity() then
    Toast(textRes.Children[1000])
    return
  end
  require("Main.Children.ui.ChooseChildOwnerPanel").Instance():ShowPanel()
end
def.method().BabyEducate = function(self)
  require("Main.Children.mgr.BabyMgr").Instance():BabyEducate()
end
def.method().GiveBirth = function(self)
  require("Main.Children.mgr.BabyMgr").Instance():GiveBirth()
end
def.method().OnClickGiveUpBtn = function(self)
  self:GiveUpBreed()
end
def.method().GiveUpBreed = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", textRes.Children[1003], function(result)
    if result == 0 then
      return
    end
    require("Main.Children.mgr.BabyMgr").Instance():GiveUpBreed()
  end, nil)
end
def.static("table", "table").OnGetBabyPhaseChanged = function(params, context)
  instance:UpdateGetBabyStatus()
end
def.static("table", "table").OnGiveBirthChildRemainTimeChange = function(params, context)
  instance:UpdateCoupleStatus()
end
def.static("table", "table").OnLeaveHomeland = function(params, context)
  instance:DestroyPanel()
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local open = params.open
  if not open then
    instance:DestroyPanel()
    Toast(textRes.Children[1042])
  end
end
GetBabyPanel.Commit()
return GetBabyPanel

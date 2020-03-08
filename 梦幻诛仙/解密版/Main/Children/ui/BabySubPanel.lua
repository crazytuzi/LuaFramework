local Lplus = require("Lplus")
local SubPanel = require("Main.Children.ui.SubPanel")
local BabySubPanel = Lplus.Extend(SubPanel, "BabySubPanel")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenOperation = require("Main.Children.ui.ChildrenOperation")
local Child = require("Main.Children.Child")
local def = BabySubPanel.define
def.field(ChildrenOperation).childOpe = nil
def.field("table").babyData = nil
def.field(Child).childModel = nil
def.field("boolean").isDrag = false
def.override().Hide = function(self)
  if self.m_node and not self.m_node.isnil then
    self.m_node:SetActive(false)
    self:Clear()
  end
end
def.override().Destroy = function(self)
  self:Clear()
end
def.method().Clear = function(self)
  if self.childOpe ~= nil then
    self.childOpe:Destroy()
    self.childOpe = nil
  end
  self.babyData = nil
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
    self.childModel = nil
  end
  self.isDrag = false
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, BabySubPanel.OnNameChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, BabySubPanel.OnChildrenFashionChange)
end
def.override("table").Show = function(self, data)
  if self.m_node and not self.m_node.isnil then
    self.m_node:SetActive(true)
    self:UpdateUI(data)
    self.m_node:FindDirect("Group_Menu/Img_Bg"):GetComponent("UIToggleEx").value = false
    self.childOpe = ChildrenOperation.CreateNew(self.m_node:FindDirect("Group_Menu/Group_ChooseType"), data:GetId())
    Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, BabySubPanel.OnNameChange, self)
    Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, BabySubPanel.OnChildrenFashionChange, self)
  end
end
def.method("table").OnNameChange = function(self, param)
  local childId = param[1]
  if self.babyData:GetId() == childId then
    self:SetBabyName(self.babyData)
  end
end
def.method("table").OnChildrenFashionChange = function(self, params)
  local childId = params[1]
  if self.babyData:GetId() == childId then
    self:SetBabyModel(self.babyData)
  end
end
def.method("table").UpdateUI = function(self, babyData)
  self.babyData = babyData
  self:SetBabyName(babyData)
  self:SetChildTurnCardClassType()
  self:SetBabyModel(babyData)
  self:SetBabyStatus(babyData)
  self:SetBabyHealth(babyData)
end
def.method("table").SetBabyName = function(self, babyData)
  local Label_Current = self.m_node:FindDirect("Group_Menu/Img_Bg/Label_Current")
  GUIUtils.SetText(Label_Current, babyData:GetName())
end
def.method().SetChildTurnCardClassType = function(self)
  local Img_Tpye = self.m_node:FindDirect("Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(constant.CChildrenConsts.cardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method("table").SetBabyModel = function(self, babyData)
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
  end
  local fashion = babyData:GetFashionByPhase(babyData:GetStatus())
  self.childModel = Child.CreateWithFashion(babyData:GetModelCfgId(), fashion and fashion.fashionId or 0)
  local uiModel = self.m_node:FindDirect("Model_Baby"):GetComponent("UIModel")
  self.childModel:LoadUIModel(nil, function()
    uiModel.modelGameObject = self.childModel.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
end
def.method("table").SetBabyStatus = function(self, babyData)
  local Group_State = self.m_node:FindDirect("Group_State")
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
  for i = 1, #stateSlider do
    local slider = Group_State:FindDirect(stateSlider[i])
    local Label_Slider = slider:FindDirect("Label_Slider")
    GUIUtils.SetText(Label_Slider, string.format("%d/%d", curState[i], stateFullValue[i]))
    slider:GetComponent("UISlider").value = curState[i] / stateFullValue[i]
  end
end
def.method("table").SetBabyHealth = function(self, babyData)
  local Slider_Health = self.m_node:FindDirect("Img_Operate/Slider_Health")
  local Label_Slider = Slider_Health:FindDirect("Label_Slider")
  local progress = babyData:GetHealthScore() / constant.CChildrenConsts.baby_to_childhood_need_health_value
  Slider_Health:GetComponent("UISlider").value = progress
  GUIUtils.SetText(Label_Slider, string.format("%d/%d", babyData:GetHealthScore(), constant.CChildrenConsts.baby_to_childhood_need_health_value))
end
def.override("string", "=>", "boolean").onClick = function(self, id)
  if self:IsShow() then
    if self.childOpe and self.childOpe:onClick(id) then
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "boolean", "=>", "boolean").onToggle = function(self, id, active)
  if self:IsShow() then
    if id == "Img_Bg" then
      if self.childOpe then
        if active then
          self.childOpe:Show(nil)
        else
          self.childOpe:Hide()
        end
      end
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "=>", "boolean").onDragStart = function(self, id)
  if self:IsShow() then
    if id == "Model_Baby" then
      self.isDrag = true
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "=>", "boolean").onDragEnd = function(self, id)
  if self:IsShow() then
    if self.isDrag then
      self.isDrag = false
      return true
    end
    return false
  else
    return false
  end
end
def.override("string", "number", "number", "=>", "boolean").onDrag = function(self, id, dx, dy)
  if self:IsShow() then
    if self.isDrag == true and self.childModel and self.childModel:GetModel() then
      self.childModel:GetModel():SetDir(self.childModel:GetModel():GetDir() - dx / 2)
      return true
    end
    return false
  else
    return false
  end
end
BabySubPanel.Commit()
return BabySubPanel

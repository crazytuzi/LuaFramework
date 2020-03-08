local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BabyBreedProgressPanel = Lplus.Extend(ECPanelBase, "BabyBreedProgressPanel")
local GUIUtils = require("GUI.GUIUtils")
local BabyOperatorEnum = require("consts.mzm.gsp.children.confbean.BabyOperatorEnum")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = BabyBreedProgressPanel.define
local instance
def.field("table").uiObjs = nil
def.field("number").operator = 0
def.field("number").duration = 0
def.field("number").progress = 0
def.field("number").timerId = 0
def.static("=>", BabyBreedProgressPanel).Instance = function()
  if instance == nil then
    instance = BabyBreedProgressPanel()
  end
  return instance
end
def.method("number", "number").ShowPanel = function(self, operator, duration)
  if self.m_panel ~= nil then
    return
  end
  self.operator = operator
  self.duration = duration
  self.progress = 0
  self:CreatePanel(RESPATH.PREFAB_BABY_BREED_PROGRESS, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateProgress()
  self:StarProgressTimer()
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BREED_OPERATE_END, BabyBreedProgressPanel.OnBreedOperateEnd)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.operator = 0
  self.duration = 0
  self.progress = 0
  self:StopProgressTimer()
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BREED_OPERATE_END, BabyBreedProgressPanel.OnBreedOperateEnd)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Texture = self.uiObjs.Img_Bg:FindDirect("Texture")
  self.uiObjs.Label = self.uiObjs.Img_Bg:FindDirect("Label")
  self.uiObjs.Slider_Prograss = self.uiObjs.Img_Bg:FindDirect("Slider_Prograss")
  GUIUtils.SetText(self.uiObjs.Label, textRes.Children.BabyOperateName[self.operator])
  local operateCfg = ChildrenUtils.GetBabyOperateCfg(self.operator)
  if operateCfg == nil then
    GUIUtils.SetActive(self.uiObjs.Texture, false)
  else
    GUIUtils.FillIcon(self.uiObjs.Texture:GetComponent("UITexture"), operateCfg.iconId)
  end
end
def.method().StarProgressTimer = function(self)
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    self.progress = self.progress + 1
    self:UpdateProgress()
    if self.progress >= self.duration then
      self:StopProgressTimer()
    end
  end)
end
def.method().UpdateProgress = function(self)
  if self.uiObjs ~= nil then
    GUIUtils.SetText(self.uiObjs.Slider_Prograss:FindDirect("Label_DeYu_Slider"), string.format("%ds", self.duration - self.progress))
    self.uiObjs.Slider_Prograss:GetComponent("UISlider").value = (self.duration - self.progress) / self.duration
  end
end
def.method().StopProgressTimer = function(self)
  GameUtil.RemoveGlobalTimer(self.timerId)
  self.timerId = 0
end
def.method().HideProgress = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local operateCfg = ChildrenUtils.GetBabyOperateCfg(self.operator)
  if operateCfg ~= nil then
    local peroperty = {}
    for i = 1, #operateCfg.property do
      table.insert(peroperty, string.format("%s+%d", textRes.Children.BabyPropertyName[operateCfg.property[i].propertyType], operateCfg.property[i].value))
    end
    Toast(string.format(textRes.Children[1038], textRes.Children.BabyOperateName[self.operator], table.concat(peroperty, "\239\188\140")))
  end
  self:DestroyPanel()
end
def.static("table", "table").OnBreedOperateEnd = function(params, context)
  instance:HideProgress()
end
BabyBreedProgressPanel.Commit()
return BabyBreedProgressPanel

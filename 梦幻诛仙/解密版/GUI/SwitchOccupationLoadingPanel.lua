local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local SwitchOccupationLoadingPanel = Lplus.Extend(ECPanelBase, "SwitchOccupationLoadingPanel")
local Vector = require("Types.Vector")
local def = SwitchOccupationLoadingPanel.define
local instance
def.const("number").PROGRESS_DURATION_TIME = 1
def.field("number").lastProgress = 0
def.field("number").progress = 0
def.field("string").tip = ""
def.field("table").uiObjs = nil
def.field("function").afterCreateCallback = nil
def.field("string").anchorDir = "center"
def.field("string").bgPath = ""
def.static("=>", SwitchOccupationLoadingPanel).Instance = function()
  if instance == nil then
    instance = SwitchOccupationLoadingPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:SetDepth(GUIDEPTH.TOPMOST2)
  local resPath = RESPATH.PREFAB_LODING_SWITCH_OCP_PANEL_RES
  local prefab = GameUtil.SyncLoad(resPath)
  self.m_SyncLoad = true
  self:CreatePanel(resPath, -1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, SwitchOccupationLoadingPanel.OnLeaveWorldStage)
end
def.override().AfterCreate = function(self)
  if self.afterCreateCallback then
    self.afterCreateCallback()
    self.afterCreateCallback = nil
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Container = self.m_panel:FindDirect("Container")
  self.uiObjs.Group_Slider = self.uiObjs.Container:FindDirect("Group_Slider")
  self.uiObjs.Img_BgSlider = self.uiObjs.Group_Slider:FindDirect("Img_BgSlider")
  self.uiObjs.Texture_Bg1 = self.m_panel:FindDirect("Texture_Bg1")
  self:UpdateBackgroundImage()
end
def.method("string").SetBackgroundImage = function(self, bgPath)
  self.bgPath = bgPath
  if self.m_panel and self.m_panel.isnil == false then
    self:UpdateBackgroundImage()
  end
end
def.method().UpdateBackgroundImage = function(self)
  local imagePath = self.bgPath
  local tex
  if imagePath ~= "" then
    tex = GameUtil.SyncLoad(imagePath)
  end
  local Texture_Bg1 = self.uiObjs.Texture_Bg1
  if self.uiObjs.Texture_Bg1 and tex then
    Texture_Bg1:GetComponent("UITexture").mainTexture = tex
  end
  if self.anchorDir == "left" then
    local TmpGO = GameObject.GameObject()
    local uiTextureClone = TmpGO:AddComponent("UITexture")
    uiTextureClone:SetAnchor_3(nil, 0, 0, 0, 0)
    local noneAnchorPoint = uiTextureClone:get_leftAnchor()
    GameObject.Destroy(TmpGO)
    local uiTexture = Texture_Bg1:GetComponent("UITexture")
    uiTexture:SetAnchor_3(self.m_panel, 0, 0, 0, 0)
    uiTexture:set_rightAnchor(noneAnchorPoint)
    uiTexture:set_bottomAnchor(noneAnchorPoint)
    uiTexture:set_topAnchor(noneAnchorPoint)
    uiTexture:set_updateAnchors(0)
    uiTexture:ResetAnchors()
    uiTexture:UpdateAnchors()
  else
    Texture_Bg1:GetComponent("UITexture"):set_pivot(4)
    Texture_Bg1:set_localPosition(Vector.Vector3.zero)
    local uiTexture = Texture_Bg1:GetComponent("UITexture")
    uiTexture:SetAnchor_3(nil, 0, 0, 0, 0)
    uiTexture:ResetAnchors()
    uiTexture:UpdateAnchors()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdatePropgress()
  self:UpdateTip()
end
def.override().OnDestroy = function(self)
  self.lastProgress = 0
  self.progress = 0
  self.tip = ""
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, SwitchOccupationLoadingPanel.OnLeaveWorldStage)
end
def.method("string").onClick = function(self, id)
end
def.method("number").SetProgress = function(self, progress)
  self.lastProgress = self.progress
  self.progress = progress
  if progress < 0 then
    self.progress = 0
  elseif progress > 1 then
    self.progress = 1
  end
  if self:IsShow() then
    self:UpdatePropgress()
  end
end
def.method().UpdatePropgress = function(self)
  local time = self:GetCurrentDurationTime()
  local lastValue = self.lastProgress
  local value = self.progress
  local uiSlider = self.uiObjs.Img_BgSlider:GetComponent("UISlider")
  uiSlider:AutoProgress(true, lastValue, value, time)
end
def.method("=>", "number").GetCurrentDurationTime = function(self)
  return (self.progress - self.lastProgress) * SwitchOccupationLoadingPanel.PROGRESS_DURATION_TIME
end
def.method("string").SetTip = function(self, tip)
  self.tip = tip
  if self:IsShow() then
    self:UpdateTip()
  end
end
def.method().UpdateTip = function(self)
end
def.static("table", "table").OnLeaveWorldStage = function(p1, p2)
  instance:DestroyPanel()
end
return SwitchOccupationLoadingPanel.Commit()

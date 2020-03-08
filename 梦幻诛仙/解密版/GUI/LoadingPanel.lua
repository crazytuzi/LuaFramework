local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local LoadingPanel = Lplus.Extend(ECPanelBase, "LoadingPanel")
local Vector = require("Types.Vector")
local def = LoadingPanel.define
local instance
def.const("number").PROGRESS_DURATION_TIME = 1
def.field("number").lastProgress = 0
def.field("number").progress = 0
def.field("string").tip = ""
def.const("number").LOGO_IMG_COUNT = 5
def.field("table").uiObjs = nil
def.field("function").afterCreateCallback = nil
def.static("=>", LoadingPanel).Instance = function()
  if instance == nil then
    instance = LoadingPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:SetDepth(GUIDEPTH.TOPMOST2)
  self.m_SyncLoad = true
  self:CreatePanel(RESPATH.PREFAB_LODING_PANEL_RES, -1)
end
def.override().OnCreate = function(self)
  ECGUIMan.Instance():EnableUIFXCamera(false)
  self:InitUI()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LoadingPanel.OnLeaveWorld)
end
def.override().AfterCreate = function(self)
  if self.afterCreateCallback then
    self.afterCreateCallback()
    self.afterCreateCallback = nil
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_BgTips = self.m_panel:FindDirect("Img_BgTips")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg0:FindDirect("Label_Tips")
  self.uiObjs.Label_Percent = self.uiObjs.Img_Bg0:FindDirect("Label_Percent")
  self.uiObjs.Texture_Bg1 = self.m_panel:FindDirect("Texture_Bg1")
  self:RandomLogoImage()
end
def.method().RandomLogoImage = function(self)
  local index = math.random(LoadingPanel.LOGO_IMG_COUNT)
  if index then
    local file = string.format("Arts/Image/Icons/Loading/Loading_%02d.png.u3dext", index)
    local tex = GameUtil.SyncLoad(file)
    local Texture_Bg1 = self.uiObjs.Texture_Bg1
    if self.uiObjs.Texture_Bg1 and tex then
      Texture_Bg1:GetComponent("UITexture").mainTexture = tex
    end
    if index == 1 then
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
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdatePropgress()
  self:UpdateTip()
end
def.override().OnDestroy = function(self)
  ECGUIMan.Instance():EnableUIFXCamera(true)
  self.lastProgress = 0
  self.progress = 0
  self.tip = ""
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LoadingPanel.OnLeaveWorld)
end
def.method("string").onClick = function(self, id)
end
def.method("number").SetProgress = function(self, progress)
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
  local beginAlpha = 1
  local endAlpha = 0.39
  local alpha = beginAlpha - self.progress * (beginAlpha - endAlpha)
  local percent = string.format("%d%%", self.progress * 100)
  if self.uiObjs.Img_BgTips then
    TweenAlpha.Begin(self.uiObjs.Img_BgTips, time, alpha)
  end
  if self.uiObjs.Label_Percent then
    self.uiObjs.Label_Percent:GetComponent("UILabel").text = percent
  end
end
def.method("=>", "number").GetCurrentDurationTime = function(self)
  return (self.progress - self.lastProgress) * LoadingPanel.PROGRESS_DURATION_TIME
end
def.method("string").SetTip = function(self, tip)
  self.tip = tip
  if self:IsShow() then
    self:UpdateTip()
  end
end
def.method().UpdateTip = function(self)
  local text = string.format(textRes.Loading[1], self.tip)
  self.uiObjs.Label_Tips:GetComponent("UILabel").text = text
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance:DestroyPanel()
end
return LoadingPanel.Commit()

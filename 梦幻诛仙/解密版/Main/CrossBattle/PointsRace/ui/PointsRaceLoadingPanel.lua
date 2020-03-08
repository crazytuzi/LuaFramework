local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PointsRaceLoadingPanel = Lplus.Extend(ECPanelBase, "PointsRaceLoadingPanel")
local def = PointsRaceLoadingPanel.define
local instance
def.static("=>", PointsRaceLoadingPanel).Instance = function()
  if instance == nil then
    instance = PointsRaceLoadingPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.const("number").PROGRESS_DURATION_TIME = 1
def.const("number").LOGO_IMG_COUNT = 5
def.const("string").ENTER_BG_NAME = "Loading_FightCrossServer"
def.const("string").LEAVE_BG_NAME = "Loading_01"
def.field("boolean")._bEnter = true
def.field("number").lastProgress = 0
def.field("number").progress = 0
def.field("string").tip = ""
def.field("table").uiObjs = nil
def.field("function").afterCreateCallback = nil
def.method("boolean").ShowPanel = function(self, bEnter)
  self:SetDepth(GUIDEPTH.TOPMOST2)
  self.m_SyncLoad = true
  self._bEnter = bEnter
  self:CreatePanel(RESPATH.PREFAB_POINTS_RACE_LOADING_PANEL, -1)
end
def.override().OnCreate = function(self)
  self:InitUI()
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
  self.uiObjs.Img_BgTips_Sprite = self.uiObjs.Img_BgTips:GetComponent("UISprite")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg0:FindDirect("Label_Tips")
  self.uiObjs.Label_Percent = self.uiObjs.Img_Bg0:FindDirect("Label_Percent")
  self.uiObjs.Texture_Bg1 = self.m_panel:FindDirect("Texture_Bg1")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateBG()
    self:UpdatePropgress()
    self:UpdateTip()
  else
  end
end
def.method().UpdateBG = function(self)
  local file
  if not self._bEnter then
    file = string.format("Arts/Image/Icons/Loading/%s.png.u3dext", PointsRaceLoadingPanel.LEAVE_BG_NAME)
  else
    file = string.format("Arts/Image/Icons/Loading/%s.png.u3dext", PointsRaceLoadingPanel.ENTER_BG_NAME)
  end
  local tex = GameUtil.SyncLoad(file)
  local Texture_Bg1 = self.uiObjs.Texture_Bg1
  if self.uiObjs.Texture_Bg1 and tex then
    Texture_Bg1:GetComponent("UITexture").mainTexture = tex
  end
end
def.method().UpdatePropgress = function(self)
  GUIUtils.SetActive(self.uiObjs.Label_Percent, false)
  self.uiObjs.Img_BgTips_Sprite.alpha = 0.1
end
def.method().UpdateTip = function(self)
  if self._bEnter then
    self.uiObjs.Label_Tips:GetComponent("UILabel").text = textRes.PointsRace.ENTER_TIP
  else
    self.uiObjs.Label_Tips:GetComponent("UILabel").text = textRes.PointsRace.QUIT_TIP
  end
end
def.method("=>", "number").GetCurrentDurationTime = function(self)
  return (self.progress - self.lastProgress) * PointsRaceLoadingPanel.PROGRESS_DURATION_TIME
end
def.method("string").SetTip = function(self, tip)
  self.tip = tip
  if self:IsShow() then
    self:UpdateTip()
  end
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
def.override().OnDestroy = function(self)
  self.lastProgress = 0
  self.progress = 0
  self.tip = ""
  self.uiObjs = nil
end
def.method("string").onClick = function(self, id)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PointsRaceLoadingPanel.OnEnterWorld)
    eventFunc(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PointsRaceLoadingPanel.OnLeaveWorld)
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  warn("[PointsRaceLoadingPanel:OnEnterWorld] hide PointsRaceLoadingPanel OnEnterWorld!")
  instance:DestroyPanel()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
end
return PointsRaceLoadingPanel.Commit()

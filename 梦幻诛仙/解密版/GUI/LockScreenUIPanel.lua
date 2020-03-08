local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local LockScreenUIPanel = Lplus.Extend(ECPanelBase, "LockScreenUIPanel")
local def = LockScreenUIPanel.define
local instance
def.field("number").progress = 0
def.field("string").tip = ""
def.field("table").uiObjs = nil
def.field("userdata").tw = nil
def.field("boolean").isDrag = false
def.static("=>", LockScreenUIPanel).Instance = function()
  if instance == nil then
    instance = LockScreenUIPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:SetDepth(GUIDEPTH.TOPMOST2)
  self:CreatePanel(RESPATH.PREFAB_UI_LOCK_SCREEN, -1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.ScrollBar = self.m_panel:FindDirect("Img_Slider"):GetComponent("UIScrollBar")
  self.uiObjs.labelobj = self.m_panel:FindDirect("Img_Slider/Label")
  self.tw = nil
  self.uiObjs.ScrollBar.value = 0
end
def.method("string", "number").onScroll = function(self, id, value)
  if self.isDrag then
    self.progress = value
    warn(" ScrollBar val =", id, value)
  end
end
local duration = 0.3
def.method("string").onDragStart = function(self, id)
  self.isDrag = true
  if self.tw ~= nil then
    self.tw.enabled = false
  end
  self.uiObjs.ScrollBar.value = 0
  self.progress = 0
  self.uiObjs.labelobj:SetActive(false)
end
def.method("string").onDragEnd = function(self, id)
  if not self.isDrag then
    return
  end
  warn("onDragEnd progress =", self.progress)
  if self.progress >= 0.5 then
    self.tw = TweenScrollBar.Begin(self.uiObjs.ScrollBar, duration, 1)
    GameUtil.AddGlobalTimer(duration, true, function()
      self:DestroyPanel()
      self.tw = nil
      local ECSoundMan = require("Sound.ECSoundMan")
      ECSoundMan.Instance():Play2DSoundByID(720060005)
    end)
  else
    self.tw = TweenScrollBar.Begin(self.uiObjs.ScrollBar, duration, 0)
    GameUtil.AddGlobalTimer(duration, true, function()
      self.uiObjs.labelobj:SetActive(true)
      self.tw = nil
      self.progress = 0
    end)
  end
  self.isDrag = false
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
end
return LockScreenUIPanel.Commit()

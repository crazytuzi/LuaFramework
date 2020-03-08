local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local CollectSliderPanel = Lplus.Extend(ECPanelBase, "CollectSliderPanel")
local dlg
local def = CollectSliderPanel.define
def.field("string").title = ""
def.field("number").proTime = 0
def.field("function").callback = nil
def.field("function").interruptCallback = nil
def.field("table").tag = nil
def.field("table").uiObjs = nil
def.field("number").updateTime = 0
def.field("number").fakeUpdateProgress = 0
def.field("boolean").bFinished = false
def.field("boolean").auto = true
def.static("string", "number", "function", "function", "table").ShowCollectSliderPanel = function(title, proTime, interruptCallback, callback, tag)
  if dlg ~= nil then
    dlg:HidePanel()
    dlg = nil
  end
  dlg = CollectSliderPanel()
  dlg.title = title
  dlg.proTime = proTime
  dlg.interruptCallback = interruptCallback
  dlg.callback = callback
  dlg.tag = tag
  dlg.updateTime = 0
  dlg.fakeUpdateProgress = 0
  dlg.bFinished = false
  dlg.auto = true
  dlg:CreatePanel(RESPATH.PREFAB_COLLECT_SLIDER_PANEL, 0)
  dlg:SetDepth(4)
end
def.static("string", "number", "function", "function", "table", "=>", CollectSliderPanel).ShowCollectSliderPanelEx = function(title, proTime, interruptCallback, callback, tag)
  local dlg = CollectSliderPanel()
  dlg.title = title
  dlg.proTime = proTime
  dlg.interruptCallback = interruptCallback
  dlg.callback = callback
  dlg.tag = tag
  dlg.updateTime = 0
  dlg.fakeUpdateProgress = 0
  dlg.bFinished = false
  dlg.auto = false
  dlg:CreatePanel(RESPATH.PREFAB_COLLECT_SLIDER_PANEL, 0)
  dlg:SetDepth(4)
  return dlg
end
def.override().OnCreate = function(self)
  Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
  self:InitUI()
  self:SetUpdateProgress(0)
  self:SetTitle()
  if self.auto then
    Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE, CollectSliderPanel.OnHeroMove)
  end
end
def.override().OnDestroy = function(self)
  Timer:RemoveIrregularTimeListener(self.OnUpdate)
  if false == self.bFinished and self.interruptCallback then
    self.interruptCallback()
  end
  if self.auto then
    Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE, CollectSliderPanel.OnHeroMove)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Slider_Bg = self.uiObjs.Img_Bg0:FindDirect("Slider_Bg")
  self.uiObjs.Label_Title = self.uiObjs.Img_Bg0:FindDirect("Img_BgTitle/Label_Title")
end
def.method().SetTitle = function(self)
  self.uiObjs.Label_Title:GetComponent("UILabel"):set_text(self.title)
end
def.method("number").SetUpdateProgress = function(self, rate)
  self.uiObjs.Slider_Bg:GetComponent("UISlider"):set_sliderValue(rate)
end
def.method("number").OnUpdate = function(self, dt)
  self.updateTime = self.updateTime + dt
  local pro = dt / self.proTime
  if self.updateTime <= self.proTime + dt then
    self:OnTimer(pro)
  end
end
def.method("number").OnTimer = function(self, pro)
  self.fakeUpdateProgress = self.fakeUpdateProgress + pro
  self:SetUpdateProgress(self.fakeUpdateProgress)
  if self.fakeUpdateProgress >= 1 then
    self.bFinished = true
    Timer:RemoveIrregularTimeListener(self.OnUpdate)
    self:FinishUpdate()
  end
end
def.method().FinishUpdate = function(self)
  if self.callback then
    self.callback(self.tag)
  end
  if self.auto then
    self:HidePanel()
  end
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
  self = nil
end
def.static("table", "table").OnHeroMove = function(p1, p2)
  if dlg ~= nil then
    dlg:HidePanel()
    dlg = nil
  end
end
return CollectSliderPanel.Commit()

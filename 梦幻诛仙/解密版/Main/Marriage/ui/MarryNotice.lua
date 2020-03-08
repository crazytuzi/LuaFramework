local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MarryNotice = Lplus.Extend(ECPanelBase, "MarryNotice")
local GUIUtils = require("GUI.GUIUtils")
local def = MarryNotice.define
def.field("string").desc = ""
def.field("number").duration = 0
def.field("number").timer = 0
def.static("string", "number").ShowMarryNotice = function(desc, time)
  if time <= 0 then
    return
  end
  local dlg = MarryNotice()
  dlg.desc = desc
  dlg.duration = time
  dlg:CreatePanel(RESPATH.PREFAB_MARRY_ANNO, 0)
end
def.override().OnCreate = function(self)
  local descLabel = self.m_panel:FindDirect("Img_Bg/Label_Propose"):GetComponent("UILabel")
  descLabel:set_text(self.desc)
  self.timer = GameUtil.AddGlobalTimer(self.duration, true, function()
    if self then
      self:DestroyPanel()
      self.timer = 0
    end
  end)
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
end
MarryNotice.Commit()
return MarryNotice

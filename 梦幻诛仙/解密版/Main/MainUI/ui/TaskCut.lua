local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TaskCut = Lplus.Extend(ECPanelBase, "TaskCut")
local def = TaskCut.define
local instance
def.field("boolean")._isShow = false
def.field("number")._level = 0
def.static("=>", TaskCut).Instance = function()
  if instance == nil then
    instance = TaskCut()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number").ShowDlg = function(self, level)
  self._level = level
  if self._isShow == false then
    self:CreatePanel(RESPATH.PREFAB_UI_TASK_CUT, 1)
    self._isShow = true
  end
  if self:IsShow() == true then
    self:Fill()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ClearNewFlag, TaskCut.OnActivityClearNewFlag)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ClearNewFlag, TaskCut.OnActivityClearNewFlag)
  local ActivityMain = require("Main.activity.ui.ActivityMain")
  local activityMain = ActivityMain.Instance()
  activityMain._AllEnabledWithLightRound = false
  self._isShow = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_CUT_SHOW, nil)
  else
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_CUT_HIDE, nil)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
  end
end
def.method().Fill = function(self)
  if self:IsShow() == false then
    return
  end
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label = Img_Bg:FindDirect("Label")
  local txt = string.format(textRes.Task[162], self._level)
  Label:GetComponent("UILabel"):set_text(txt)
  local ActivityMain = require("Main.activity.ui.ActivityMain")
  local activityMain = ActivityMain.Instance()
  activityMain._AllEnabledWithLightRound = true
end
def.static("table", "table").OnActivityClearNewFlag = function(p1, p2)
  local self = instance
  self:HideDlg()
end
TaskCut.Commit()
return TaskCut

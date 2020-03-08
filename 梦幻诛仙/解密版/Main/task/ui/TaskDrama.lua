local Lplus = require("Lplus")
local TaskModule = Lplus.ForwardDeclare("TaskModule")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local ECModel = require("Model.ECModel")
local GUIUtils = require("GUI.GUIUtils")
local TaskDrama = Lplus.Extend(ECPanelBase, "TaskDrama")
local Vector = require("Types.Vector")
local def = TaskDrama.define
local inst
def.field("boolean").isshowing = false
def.static("=>", TaskDrama).Instance = function()
  if inst == nil then
    inst = TaskDrama()
    inst:Init()
  end
  return inst
end
def.field("boolean")._touchable = true
def.method().Init = function(self)
  self.m_TrigGC = true
  self:SetDepth(7)
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_TASK_DRAMA, -1)
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.method("boolean").SetTouchable = function(self, Touchable)
  self._touchable = Touchable
end
def.override().OnCreate = function(self)
  ECGUIMan.Instance():ShowAllUI(false)
end
def.override().OnDestroy = function(self)
  self._touchable = true
  ECGUIMan.Instance():ShowAllUI(true)
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, TaskDrama.OnDramaOver)
    Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TaskDrama.OnLeaveWorld)
  else
    Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, TaskDrama.OnDramaOver)
    Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TaskDrama.OnLeaveWorld)
  end
end
def.method("string").onClick = function(self, id)
  if self._touchable == false or self:IsShow() == false then
    return
  end
  if id == "Img_BgTop" and _G.CGPlay == true then
    local CG = require("CG.CG")
    local TaskInterface = require("Main.task.TaskInterface")
    local path = TaskInterface.Instance()._playingOpera
    CG.Instance():Stop(path)
  end
end
def.static("table", "table").OnDramaOver = function(p1, p2)
  local self = inst
  self:HideDlg()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = inst
  self:HideDlg()
end
TaskDrama.Commit()
return TaskDrama

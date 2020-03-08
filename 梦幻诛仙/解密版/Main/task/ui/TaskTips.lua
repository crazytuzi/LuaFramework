local Lplus = require("Lplus")
local TaskModule = Lplus.ForwardDeclare("TaskModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local TaskTips = Lplus.Extend(ECPanelBase, "TaskTips")
local def = TaskTips.define
local inst
local TaskInterface = require("Main.task.TaskInterface")
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
def.static("=>", TaskTips).Instance = function()
  if inst == nil then
    inst = TaskTips()
    inst:Init()
  end
  return inst
end
def.field("table")._taskCfg = nil
def.field("string")._dispName = ""
def.field("boolean").isshowing = false
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number", "=>", "boolean").ShowDlg = function(self, taskID)
  if taskID == nil then
    return false
  end
  self._taskCfg = TaskInterface.GetTaskCfg(taskID)
  if self._taskCfg == nil then
    self._dispName = ""
    return false
  end
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_TASK_TIPS, 1)
    self:SetOutTouchDisappear()
  end
  if self:IsShow() then
    self:_Fill()
  end
  return true
end
def.method("number", "=>", "boolean").ShowDlgAndName = function(self, taskID, dispName)
  self._dispName = dispName
  return self:ShowDlg(taskID)
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:_Fill()
  else
    self._taskCfg = nil
  end
end
def.method("string").onClick = function(self, id)
  self:HideDlg()
end
def.method()._Fill = function(self)
  if self._taskCfg == nil then
    return
  end
  local Group_Label = self.m_panel:FindDirect("Img_Bg0/Group_Label")
  local Label_1 = Group_Label:FindDirect("Label_1")
  if self._dispName ~= nil and string.len(self._dispName) > 0 then
    Label_1:GetComponent("UILabel"):set_text(self._dispName)
  else
    Label_1:GetComponent("UILabel"):set_text(self._taskCfg.taskName)
  end
  local Label_2 = Group_Label:FindDirect("Label_2")
  local dispTarget = self._taskCfg.taskTarget
  local TaskString = require("Main.task.TaskString")
  local taskString = TaskString.Instance()
  taskString:SetTargetTaskCfg(self._taskCfg)
  taskString:SetConditionData(nil)
  if self._taskCfg.taskTarget ~= nil and self._taskCfg.taskTarget ~= "" then
    dispTarget = string.gsub(self._taskCfg.taskTarget, "%$%((.-)%)%$", TaskString.DoReplace)
  else
    dispTarget = taskString:GeneratTaskFinishTarget(self._taskCfg, ";")
  end
  Label_2:GetComponent("UILabel"):set_text(dispTarget)
  local Label_3 = self.m_panel:FindDirect("Img_Bg0/Label_3")
  local dispDesc = string.gsub(self._taskCfg.taskDes, "%$%((.-)%)%$", TaskString.DoReplace)
  Label_3:GetComponent("UILabel"):set_text(dispDesc)
end
TaskTips.Commit()
return TaskTips

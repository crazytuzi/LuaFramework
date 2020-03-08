local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SimpleTaskList = Lplus.Extend(ECPanelBase, "SimpleTaskList")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local def = SimpleTaskList.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = SimpleTaskList()
  end
  return _instance
end
def.field("table").m_taskInfo = nil
def.static("table").ShowSimpleTaskList = function(taskInfo)
  local dlg = SimpleTaskList.Instance()
  dlg.m_taskInfo = taskInfo
  if dlg:IsShow() then
    dlg:UpdateTask()
  else
    dlg:SetDepth(GUIDEPTH.BOTTOMMOST)
    dlg:CreatePanel(RESPATH.PREFAB_SINGLEBATTLE_TASK, 0)
  end
end
def.static().Close = function()
  local dlg = SimpleTaskList.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, SimpleTaskList.OnEnterFight, self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, SimpleTaskList.OnLeaveFight, self)
  self:UpdateTask()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, SimpleTaskList.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, SimpleTaskList.OnLeaveFight)
  self.m_taskInfo = nil
end
def.method("table").OnEnterFight = function(self, param)
  local btn_left = self.m_panel:FindDirect("Img_Bg/Group_Open/Btn_Right")
  btn_left:GetComponent("UIPlayTween"):Play(true)
end
def.method("table").OnLeaveFight = function(self, param)
  local btn_right = self.m_panel:FindDirect("Img_Bg/Group_Close/Btn_Left")
  btn_right:GetComponent("UIPlayTween"):Play(true)
end
def.method().UpdateTask = function(self)
  local count = #self.m_taskInfo
  local scroll = self.m_panel:FindDirect("Img_Bg/Group_Open/Group_Task/Scroll View_Task")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not scroll.isnil then
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local task = self.m_taskInfo[i]
    self:FillTask(uiGo, task, i)
  end
end
def.method("userdata", "table", "number").FillTask = function(self, uiGo, task, index)
  local lbl = uiGo:FindDirect("Label_TaskDescribe_" .. index)
  local taskCfg = CaptureTheFlagUtils.GetMissionCfg(task.cfgId)
  local taskDesc = self:GetTaskDesc(task, taskCfg)
  lbl:GetComponent("UILabel"):set_text(taskDesc)
  local fin = uiGo:FindDirect("Img_sign_" .. index)
  if task.num >= taskCfg.needNum then
    fin:SetActive(true)
  else
    fin:SetActive(false)
  end
end
def.method("table", "table", "=>", "string").GetTaskDesc = function(self, task, taskCfg)
  local str = taskCfg.taskDesc .. string.format(":(%d/%d)", task.num, taskCfg.needNum)
  return str
end
SimpleTaskList.Commit()
return SimpleTaskList

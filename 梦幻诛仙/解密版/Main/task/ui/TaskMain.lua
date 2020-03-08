local Lplus = require("Lplus")
local TaskModule = Lplus.ForwardDeclare("TaskModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local TaskMain = Lplus.Extend(ECPanelBase, "TaskMain")
local def = TaskMain.define
local inst
local TaskInterface = require("Main.task.TaskInterface")
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local GUIUtils = require("GUI.GUIUtils")
local TaskTargetByGraph = require("Main.task.TaskTargetByGraph")
local taskTargetByGraph = TaskTargetByGraph.Instance()
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local TaskNode = require("Main.task.ui.TaskNode")
local SurpriseTaskNode = require("Main.task.ui.SurpriseTaskNode")
def.static("=>", TaskMain).Instance = function()
  if inst == nil then
    inst = TaskMain()
    inst:Init()
  end
  return inst
end
local NodeId = {Task = 1, SurpriseTask = 2}
local NodeDefines = {
  [NodeId.Task] = {
    tabName = "Tap_RenWu",
    rootName = "Img_BgTaskList",
    rootFunc = function(isShow)
      TaskMain.TaskRootFunc(isShow)
    end,
    node = TaskNode
  },
  [NodeId.SurpriseTask] = {
    tabName = "Tap_XianYuan",
    rootName = "Img_BgXianYuan",
    node = SurpriseTaskNode
  }
}
def.const("table").NodeIds = NodeId
def.field("boolean")._tabAccepted = false
def.field("boolean")._tabAcceptable = false
def.field("table").nodes = nil
def.field("number").curNode = NodeId.Task
def.method().Init = function(self)
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self:CreatePanel(RESPATH.PREFAB_UI_TASK_MAIN, 1)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  if self._tabAccepted == false and self._tabAcceptable == false then
    local Tap_Now = self.m_panel:FindDirect("Img_Bg0/Tap_Now")
    local Tap_Others = self.m_panel:FindDirect("Img_Bg0/Tap_Others")
    Tap_Others:GetComponent("UIToggle"):set_isChecked(false)
    Tap_Now:GetComponent("UIToggle"):set_isChecked(true)
    Tap_Others:SetActive(false)
    self._tabAccepted = Tap_Now:GetComponent("UIToggle"):get_isChecked()
    self._tabAcceptable = Tap_Others:GetComponent("UIToggle"):get_isChecked()
  end
  self:InitNode()
  self:InitTab()
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_New_Surprise_Task_Change, TaskMain.OnNewSurpriseTaskChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_New_Surprise_Task_Change, TaskMain.OnNewSurpriseTaskChange)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    local Tap_Now = self.m_panel:FindDirect("Img_Bg0/Tap_Now")
    local Tap_Others = self.m_panel:FindDirect("Img_Bg0/Tap_Others")
    Tap_Now:SetActive(false)
    Tap_Others:SetActive(false)
    Tap_Now:GetComponent("UIToggle"):set_isChecked(self._tabAccepted)
    Tap_Others:GetComponent("UIToggle"):set_isChecked(self._tabAcceptable)
    self.nodes[self.curNode]:Show()
  else
    self.nodes[self.curNode]:Hide()
    self.curNode = NodeId.Task
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("** TaskMain.onClick(", id, ")")
  local fnClick = {}
  fnClick.Btn_Close = TaskMain.OnBtnCloseClick
  fnClick.Modal = TaskMain.OnBtnCloseClick
  local fn = fnClick[id]
  if fn ~= nil then
    fn(self)
  elseif id == "Tap_RenWu" then
    self:switchNode(NodeId.Task)
  elseif id == "Tap_XianYuan" then
    self:switchNode(NodeId.SurpriseTask)
  else
    self.nodes[self.curNode]:onClickObj(clickObj)
  end
end
def.method().InitNode = function(self)
  self.nodes = {}
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = self.m_panel:FindDirect("Img_Bg0/" .. v.rootName)
    if v.rootFunc then
      if nodeId == self.curNode then
        v.rootFunc(true)
      else
        v.rootFunc(false)
      end
    elseif nodeRoot then
      if nodeId == self.curNode then
        nodeRoot:SetActive(true)
      else
        nodeRoot:SetActive(false)
      end
    end
    if v.node then
      self.nodes[nodeId] = v.node()
      self.nodes[nodeId]:Init(self, nodeRoot)
    end
  end
end
def.method().InitTab = function(self)
  if self.curNode == 0 then
    self.curNode = NodeId.Task
  end
  for nodeId, v in pairs(NodeDefines) do
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    local tab = Img_Bg0:FindDirect(v.tabName)
    if self.nodes[nodeId] and self.nodes[nodeId]:isOpen() then
      tab:SetActive(true)
      local Img_Red = tab:FindDirect("Img_Red")
      if Img_Red then
        local isNotify = self.nodes[nodeId]:isNotify()
        if isNotify then
          Img_Red:SetActive(true)
        else
          Img_Red:SetActive(false)
        end
      end
    else
      tab:SetActive(false)
    end
    tab:GetComponent("UIToggle").value = nodeId == self.curNode
  end
end
def.method().refreshNodeRedPoint = function(self)
  for nodeId, v in pairs(NodeDefines) do
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    local tab = Img_Bg0:FindDirect(v.tabName)
    if self.nodes[nodeId] and self.nodes[nodeId]:isOpen() then
      local Img_Red = tab:FindDirect("Img_Red")
      if Img_Red then
        local isNotify = self.nodes[nodeId]:isNotify()
        if isNotify then
          Img_Red:SetActive(true)
        else
          Img_Red:SetActive(false)
        end
      end
    end
  end
end
def.method("number").switchNode = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  local nodeInfo = NodeDefines[self.curNode]
  if nodeInfo then
    local nodeRoot = self.m_panel:FindDirect("Img_Bg0/" .. nodeInfo.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    warn("------rootFunc:", nodeInfo.rootFunc)
    if nodeInfo.rootFunc then
      nodeInfo.rootFunc(false)
    end
    self.nodes[self.curNode]:Hide()
  end
  local nextNode = NodeDefines[nodeId]
  local nodeRoot = self.m_panel:FindDirect("Img_Bg0/" .. nextNode.rootName)
  if nodeRoot then
    nodeRoot:SetActive(true)
  end
  if nextNode.rootFunc then
    nextNode.rootFunc(true)
  end
  self.curNode = nodeId
  self.nodes[nodeId]:Show()
end
def.static("boolean").TaskRootFunc = function(isShow)
  warn("------TaskRootFunc-----:", isShow)
  local self = inst
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_BgTaskList = Img_Bg0:FindDirect("Img_BgTaskList")
  local Img_BgTask = Img_Bg0:FindDirect("Img_BgTask")
  local Btn_GiveUp = Img_Bg0:FindDirect("Btn_GiveUp")
  local Btn_Deliver = Img_Bg0:FindDirect("Btn_Deliver")
  local Btn_RenXing = Img_Bg0:FindDirect("Btn_RenXing")
  Img_BgTaskList:SetActive(isShow)
  Img_BgTask:SetActive(isShow)
  Btn_GiveUp:SetActive(isShow)
  Btn_Deliver:SetActive(isShow)
  if not isShow and Btn_RenXing then
    Btn_RenXing:SetActive(false)
  end
end
def.static(TaskMain).OnBtnCloseClick = function(self)
  self:HideDlg()
end
def.static(TaskMain).OnTapClick = function(self)
  local Tap_Now = self.m_panel:FindDirect("Img_Bg0/Tap_Now")
  local Tap_Others = self.m_panel:FindDirect("Img_Bg0/Tap_Others")
  local tabAccepted = true
  local tabAcceptable = false
  if self._tabAccepted ~= tabAccepted or self._tabAcceptable ~= tabAcceptable then
    self._tabAccepted = tabAccepted
    self._tabAcceptable = tabAcceptable
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  local self = inst
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  Img_Bg0:FindDirect("Btn_Deliver"):GetComponent("UIButton"):set_isEnabled(false)
  Img_Bg0:FindDirect("Btn_GiveUp"):GetComponent("UIButton"):set_isEnabled(false)
  Img_Bg0:FindDirect("Btn_Get"):GetComponent("UIButton"):set_isEnabled(false)
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  local self = inst
  if self._selectedTask ~= nil then
    local graphCfg = TaskInterface.GetTaskGraphCfg(inst._selectedTask.graphId)
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    Img_Bg0:FindDirect("Btn_Deliver"):GetComponent("UIButton"):set_isEnabled(true)
    Img_Bg0:FindDirect("Btn_GiveUp"):GetComponent("UIButton"):set_isEnabled(graphCfg.canGiveUpTask)
    Img_Bg0:FindDirect("Btn_Get"):GetComponent("UIButton"):set_isEnabled(true)
  end
end
def.static("table", "table").OnGamePause = function(p1, p2)
  local self = inst
  self:HideDlg()
end
def.static("table", "table").OnNewSurpriseTaskChange = function(p1, p2)
  if inst and not _G.IsNil(inst.m_panel) then
    inst:refreshNodeRedPoint()
  end
end
TaskMain.Commit()
return TaskMain

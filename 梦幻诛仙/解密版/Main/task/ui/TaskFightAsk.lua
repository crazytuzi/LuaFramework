local Lplus = require("Lplus")
local TaskModule = Lplus.ForwardDeclare("TaskModule")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local GUIUtils = require("GUI.GUIUtils")
local TaskFightAsk = Lplus.Extend(ECPanelBase, "TaskFightAsk")
local TaskInterface = require("Main.task.TaskInterface")
local Vector = require("Types.Vector")
local def = TaskFightAsk.define
local instance
def.static("=>", TaskFightAsk).Instance = function()
  if instance == nil then
    instance = TaskFightAsk()
    instance:Init()
  end
  return instance
end
TaskFightAsk.DeltaTime = 0.1
def.field("table")._tableMemberState = nil
def.field("number")._remainTime = 0
def.field("number")._timerID = 0
def.field("boolean").isshowing = false
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_TASK_FIGHT_ASK, 1)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self._tableMemberState = {}
  if self._timerID <= 0 then
    self._remainTime = constant.TaskConsts.TaskFightWaitTime
    self._timerID = GameUtil.AddGlobalTimer(TaskFightAsk.DeltaTime, true, TaskFightAsk.OnTimer)
  end
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TaskFightAsk.OnEnterFight)
end
def.override().OnDestroy = function(self)
  self._tableMemberState = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TaskFightAsk.OnEnterFight)
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
    self._timerID = 0
  end
end
def.method("string").onClick = function(self, id)
end
def.method("userdata", "number").SetRoleRepones = function(self, roleId, repResult)
  self._tableMemberState[tostring(roleId)] = repResult
end
def.method().Fill = function(self)
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  if self:IsShow() == false or teamData:HasTeam() == false then
    return
  end
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Slider = Img_Bg:FindDirect("Slider")
  local List_Member = Img_Bg:FindDirect("List_Member")
  local idx = 2
  local ST_NORMAL = require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL
  for i = 1, 4 do
    local Member = List_Member:FindDirect(string.format("Member_%d", i))
    while true do
      local v = members[idx]
      idx = idx + 1
      if v ~= nil then
        if v.status == ST_NORMAL then
          Member:SetActive(true)
          local Icon_Head = Member:FindDirect("Icon_Head")
          local Img_Agree = Member:FindDirect("Img_Agree")
          local Label_PlayerName = Member:FindDirect("Label_PlayerName")
          local Label_Wait = Member:FindDirect("Label_Wait")
          local spriteName = GUIUtils.GetHeadSpriteName(v.menpai, v.gender)
          Icon_Head:GetComponent("UISprite").spriteName = spriteName
          local repResult = self._tableMemberState[tostring(v.roleid)]
          Img_Agree:SetActive(repResult == TaskConsts.JOIN_FIGHT_REP__YES)
          Label_Wait:SetActive(repResult == nil)
          Label_PlayerName:GetComponent("UILabel"):set_text(v.name)
          break
        else
          Member:SetActive(false)
        end
      else
        Member:SetActive(false)
        break
      end
    end
  end
  self:_FillRemainTime()
end
def.method()._FillRemainTime = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if self:IsShow() == false or teamData:HasTeam() == false then
    return
  end
  local Slider = self.m_panel:FindDirect("Img_Bg/Slider")
  local Label = Slider:FindDirect("Label")
  local uislider = Slider:GetComponent("UISlider")
  uislider:set_sliderValue(self._remainTime / constant.TaskConsts.TaskFightWaitTime)
  local uilabel = Label:GetComponentInChildren("UILabel")
  uilabel.text = string.format(textRes.Task[210], self._remainTime)
end
def.static().OnTimer = function()
  local self = instance
  if self:IsShow() == false then
    return
  end
  self._remainTime = self._remainTime - TaskFightAsk.DeltaTime
  if self._remainTime > 0 then
    self._timerID = GameUtil.AddGlobalTimer(TaskFightAsk.DeltaTime, true, TaskFightAsk.OnTimer)
  else
    self:HideDlg()
  end
  self:_FillRemainTime()
end
def.static("table", "table").OnEnterFight = function()
  local self = instance
  self:HideDlg()
end
TaskFightAsk.Commit()
return TaskFightAsk

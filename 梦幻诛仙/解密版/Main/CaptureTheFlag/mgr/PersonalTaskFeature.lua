local Lplus = require("Lplus")
local BattleFeature = require("Main.CaptureTheFlag.mgr.BattleFeature")
local PersonalTaskFeature = Lplus.Extend(BattleFeature, "PersonalTaskFeature")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local BattleFieldMgr = Lplus.ForwardDeclare("BattleFieldMgr")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local SimpleTaskList = require("Main.CaptureTheFlag.ui.SimpleTaskList")
local def = PersonalTaskFeature.define
local instance
def.final("=>", "table").Instance = function()
  if instance == nil then
    instance = PersonalTaskFeature()
    instance.playType = PlayType.SINGLE_TASK
  end
  return instance
end
def.field("table").m_taskInfo = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynRoleTaskInfo", PersonalTaskFeature.OnSSynRoleTaskInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynRoleTaskParam", PersonalTaskFeature.OnSSynRoleTaskParam)
end
def.override().Reset = function(self)
  self.m_taskInfo = nil
end
def.static("table").OnSSynRoleTaskInfo = function(p)
  local self = PersonalTaskFeature.Instance()
  self.m_taskInfo = {}
  for k, v in pairs(p.taskDatas) do
    local taskInfo = {
      cfgId = k,
      num = v.param
    }
    table.insert(self.m_taskInfo, taskInfo)
  end
  table.sort(self.m_taskInfo, function(a, b)
    return a.cfgId < b.cfgId
  end)
  self:ShowSimpleTaskList()
end
def.static("table").OnSSynRoleTaskParam = function(p)
  local self = PersonalTaskFeature.Instance()
  if self.m_taskInfo then
    for k, v in ipairs(self.m_taskInfo) do
      if v.cfgId == p.taskId then
        v.num = p.param
        break
      end
    end
  end
  self:ShowSimpleTaskList()
end
def.override().OnEnterBattle = function(self)
  self:ShowSimpleTaskList()
end
def.override("number").OnEnterStage = function(self, stage)
  if stage == require("netio.protocol.mzm.gsp.singlebattle.SSynBattleStage").STAGE_PLAY then
    self:ShowSimpleTaskList()
  end
end
def.override().OnQuitBattle = function(self)
  self.m_taskInfo = nil
  SimpleTaskList.Close()
end
def.method().ShowSimpleTaskList = function(self)
  local stage = BattleFieldMgr.Instance():GetStage()
  if stage >= require("netio.protocol.mzm.gsp.singlebattle.SSynBattleStage").STAGE_PLAY and self.m_taskInfo then
    SimpleTaskList.ShowSimpleTaskList(self.m_taskInfo)
  end
end
return PersonalTaskFeature.Commit()

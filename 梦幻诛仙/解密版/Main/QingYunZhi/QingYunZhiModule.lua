local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local QingYunZhiModule = Lplus.Extend(ModuleBase, "QingYunZhiModule")
require("Main.module.ModuleId")
local QingYunZhiData = require("Main.QingYunZhi.data.QingYunZhiData")
local QingYunZhiPanel = require("Main.QingYunZhi.ui.QingYunZhiPanel")
local QingYunZhiProtocol = require("Main.QingYunZhi.QingYunZhiProtocol")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local def = QingYunZhiModule.define
local instance
def.field(QingYunZhiPanel)._dlg = nil
def.field("number")._npcId = 0
def.field("table").data = nil
def.static("=>", QingYunZhiModule).Instance = function()
  if nil == instance then
    instance = QingYunZhiModule()
    instance._dlg = QingYunZhiPanel.Instance()
    instance.data = QingYunZhiData.Instance()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, QingYunZhiModule.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, QingYunZhiModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, QingYunZhiModule.onActivityTodo)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QingYunZhiModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, QingYunZhiModule.OnLeaveFight)
  self.data:InitData()
  QingYunZhiProtocol.Init()
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
end
def.method("=>", "number").GetNpcId = function(self)
  return self._npcId
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  local serviceId = tbl[1]
  if NPCServiceConst.QingYunZhi_Enter1 == serviceId then
    instance._npcId = tbl[2]
    instance:ShowMainPanel(QingYunZhiData.QINGYUNZHI_TYPE.NORMAL)
  end
  if NPCServiceConst.QingYunZhi_Enter2 == serviceId then
    instance._npcId = tbl[2]
    instance:ShowMainPanel(QingYunZhiData.QINGYUNZHI_TYPE.ELITE)
  end
  if NPCServiceConst.QingYunZhi_Enter3 == serviceId then
    instance._npcId = tbl[2]
    instance:ShowMainPanel(QingYunZhiData.QINGYUNZHI_TYPE.HERO)
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance.data:OnReset()
  instance._dlg:OnReset()
end
def.static("table", "table").onActivityTodo = function(p1, p2)
  local actId = p1[1]
  if actId == constant.CQingYunZhiConsts.ACTIVITYID or actId == constant.CQingYunZhiConsts.ELITE_ACTIVITYID or actId == constant.CQingYunZhiConsts.HERO_ACTIVITYID then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.CQingYunZhiConsts.QING_NPC_ID
    })
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if instance then
    instance._dlg:FightClosePanel()
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  local dlg = instance._dlg
  if dlg and dlg.uiStateInfo then
    dlg:ShowPanel(dlg.uiStateInfo.curType)
  end
end
def.method("number").ShowMainPanel = function(self, showType)
  if instance._dlg.m_panel == nil then
    instance._dlg.uiStateInfo = nil
    instance._dlg:ShowPanel(showType)
  else
    instance._dlg:DestroyPanel()
  end
end
def.method("number", "number", "number").synQingSingleProgress = function(self, outPostType, chapter, section)
  self.data:syncProgress(outPostType, chapter, section)
  if self._dlg then
    self._dlg:syncProgress(outPostType)
  end
end
QingYunZhiModule.Commit()
return QingYunZhiModule

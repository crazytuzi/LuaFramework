local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local NPCModule = Lplus.Extend(ModuleBase, "NPCModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local Space = require("consts.mzm.gsp.map.confbean.Space")
local def = NPCModule.define
local instance
def.static("=>", NPCModule).Instance = function()
  if instance == nil then
    instance = NPCModule()
    instance.m_moduleId = ModuleId.NPC
  end
  return instance
end
local NPCInterface = require("Main.npc.NPCInterface")
local npcInterface = NPCInterface.Instance()
local GangUtility = require("Main.Gang.GangUtility")
def.field("number")._TargetMonsterInstID = 0
def.field("number")._FindPathNPCCache = 0
def.field("table")._TargetService = nil
def.field("number")._targetTaskID = 0
def.field("number")._targetGraphID = 0
def.field("function")._npcServiceWaitReadyFunction = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.npc.SNPCNormalResult", NPCModule.OnSNPCNormalResult)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, NPCModule.OnTaskInfoChanged)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GotoNPC, NPCModule.OnTaskDoNPC)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_ImmediateDoNPC, NPCModule._DoInteractiveNPC)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_OnRefreshLibTryDoNPC, NPCModule._DoInteractiveNPC2)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, NPCModule.OnClickNpc)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, NPCModule.OnClickNpc)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_MONSTER, NPCModule.OnClickMonster)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, NPCModule.OnFindpathFinished)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, NPCModule.OnClickMapFindpath)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_CANCELED, NPCModule.OnFindpathCanceled)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.FIND_PATH_FAILED, NPCModule.OnFindPathFailed)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, NPCModule.OnHeroPropInit)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_GOTO_TARGET_SERVICE, NPCModule.OnNPCGotoTargetService)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.GO_TO_NPC_SHOP_BUY_ITEM, NPCModule.OnNPCGotoShop)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  NPCInterface.Instance():Reset()
end
def.method().OnEnterFight = function()
end
def.static("table", "table").OnFindpathFinished = function(p1, p2)
  local self = instance
  local targetNPC = npcInterface:GetTargetNPCID()
  if targetNPC ~= nil and targetNPC ~= 0 then
    local extraInfo = npcInterface:GetTargetNPCInfo()
    npcInterface:SetTargetNPCID(0)
    NPCModule.OnDoNPC({
      npcID = targetNPC,
      targetTaskID = instance._targetTaskID,
      targetGraphID = instance._targetGraphID,
      extraInfo = extraInfo
    }, nil)
    return
  end
  if self._TargetMonsterInstID ~= nil and self._TargetMonsterInstID ~= 0 then
    local iid = self._TargetMonsterInstID
    self._TargetMonsterInstID = 0
    NPCModule.OnClickMonster({iid}, nil)
    return
  end
end
def.static("table", "table").OnFindPathFailed = function(p1, p2)
  instance:ClearFindpath()
end
def.static("table", "table").OnClickMapFindpath = function(p1, p2)
  instance:ClearFindpath()
end
def.static("table", "table").OnFindpathCanceled = function(p1, p2)
  instance:ClearFindpath()
end
def.method().ClearFindpath = function(self)
  npcInterface:SetTargetNPCID(0)
  self._TargetMonsterInstID = 0
  local taskInterface = require("Main.task.TaskInterface").Instance()
  taskInterface:SetTaskPathFindParam(0, 0)
  self._TargetService = nil
end
def.static("table", "table").OnTryDoNPC = function(p1, p2)
  local npcID = p1[1]
  local npcCfg = npcInterface.GetNPCCfg(npcID)
  local HeroModule = require("Main.Hero.HeroModule").Instance()
  local heroPos = HeroModule.myRole:GetPos()
  if npcCfg ~= nil then
    local npcx = npcCfg.x
    local npcy = npcCfg.y
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    local theNPC = pubroleModule:GetNpc(npcID)
    if theNPC ~= nil then
      local npcPos = theNPC:GetPos()
      npcx = npcPos.x
      npcy = npcPos.y
    end
    local myx = heroPos.x
    local myy = heroPos.y
    local dx = (npcx - myx) * (npcx - myx)
    local dy = (npcy - myy) * (npcy - myy)
    local d = dx + dy
    local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
    local mapID = MapModule.Instance():GetMapId()
    if mapID ~= npcCfg.mapId or d > 65536 then
      return
    end
  end
  NPCModule._DoInteractiveNPC({npcID}, nil)
end
def.static("table", "table").OnClickNpc = function(p1, p2)
  NPCModule.OnDoNPC({
    npcID = p1[1],
    extraInfo = p1[2]
  }, nil)
end
def.static("table", "table").OnTaskDoNPC = function(p1, p2)
  p1.isGoHome = true
  NPCModule.OnDoNPC(p1, p2)
end
def.static("table", "table").OnDoNPC = function(p1, p2)
  if CGPlay == true then
    return
  end
  local isInFight = require("Main.Fight.FightMgr").Instance().isInFight
  if isInFight == true then
    warn("**********************\229\156\168\230\136\152\230\150\151\228\184\173 \232\175\183\230\177\130NPC\228\186\164\228\186\146\239\188\140\229\188\138\230\142\137\239\188\129")
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local myRoleID = heroModule:GetMyRoleId()
  if pubroleModule:IsInFollowState(heroModule.roleId) then
    Toast(textRes.NPC[22])
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE_IN_TEAM_FOLLOW, nil)
    return
  end
  if heroModule:IsInState(RoleState.ESCORT) then
    return
  end
  local npcID = p1.npcID
  local useFlySword = p1.useFlySword
  instance._targetTaskID = p1.targetTaskID or 0
  instance._targetGraphID = p1.targetGraphID or 0
  local extraInfo = p1.extraInfo or {}
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  if npcCfg == nil then
    warn("**********OnDoNPC(),npcCfg == nil")
  end
  local myRole = heroModule.myRole
  if myRole == nil then
    instance._FindPathNPCCache = npcID
    return
  end
  if heroModule:IsPatroling() == true then
    heroModule:StopPatroling()
  end
  local heroPos = heroModule.myRole:GetPos()
  if heroPos == nil then
    warn("---------------HeroPos is nil")
    return
  end
  local npcx = npcCfg.x
  local npcy = npcCfg.y
  local displayMapID = npcCfg.mapId
  local theNPC
  if extraInfo.npc then
    theNPC = extraInfo.npc
  else
    theNPC = pubroleModule:GetNpc(npcID)
  end
  if theNPC ~= nil then
    local npcPos = theNPC:GetPos()
    npcx = npcPos.x
    npcy = npcPos.y
    local mapId = theNPC:GetDisplayMapId()
    if mapId ~= 0 then
      displayMapID = mapId
    end
  end
  local myx = heroPos.x
  local myy = heroPos.y
  local dx = (npcx - myx) * (npcx - myx)
  local dy = (npcy - myy) * (npcy - myy)
  local d = dx + dy
  local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local mapID = MapModule:GetMapId()
  if mapID ~= displayMapID or d > 32768 or npcCfg.isInAir ~= heroModule.myRole:IsInState(RoleState.FLY) then
    npcInterface:SetTargetNPCID(npcID, extraInfo)
    heroModule.needShowAutoEffect = true
    if displayMapID == 0 or npcx == 0 or npcy == 0 then
      error("!!!!!!!!!!!!!!!!!!! npcID = " .. npcID .. " displayMapID == " .. displayMapID .. ",npcx =" .. npcx .. " npcy = " .. npcy)
    end
    if useFlySword then
      heroModule:MoveToPos(displayMapID, npcx, npcy, npcCfg.isInAir and Space.SKY or Space.GROUND, 5, MoveType.FLY, nil)
    elseif displayMapID == GangUtility.GetGangConsts("GANG_MAP") then
      local GangBattleMgr = require("Main.Gang.GangBattleMgr")
      GangBattleMgr.Instance():GotoGangMapNPC(npcID)
    else
      local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
      if p1.isGoHome and homelandModule:IsHomelandMap(displayMapID) and not homelandModule:IsInSelfCourtyard() then
        if homelandModule:HaveHome() then
          local isEnter = homelandModule:GotoHomelandNPC(displayMapID, npcID)
          if not isEnter then
            Toast(textRes.NPC[60])
          end
        else
          Toast(textRes.NPC[61])
        end
      else
        heroModule:MoveTo(displayMapID, npcx, npcy, npcCfg.isInAir and Space.SKY or Space.GROUND, 5, MoveType.AUTO, nil)
      end
    end
    return
  end
  local NPC_STATE = require("consts.mzm.gsp.npc.confbean.NPCState")
  if theNPC ~= nil and theNPC.stance ~= NPC_STATE.DEAD and npcCfg.isAutoTurning then
    theNPC:LookAtTarget(myRole)
    myRole:LookAtTarget(theNPC)
  end
  NPCModule._DoInteractiveNPC({npcID, extraInfo = extraInfo}, nil)
end
def.static("table", "table")._DoInteractiveNPC = function(p1, p2)
  local npcID = p1[1]
  local targetGraphID = p1.targetGraphID
  local extraInfo = p1.extraInfo
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  if npcCfg == nil then
    print("_DoInteractiveNPC(),npcCfg == nil")
  end
  npcInterface:SetLastInteractiveNPCID(npcID)
  if instance._TargetService ~= nil then
    local targetService = instance._TargetService
    instance._TargetService = nil
    for k, v in pairs(npcCfg.serviceCfgs) do
      if targetService.serviceType ~= nil and targetService.serviceType == v.serviceType then
        local serviceConditionCfg = NPCInterface.GetNpcServiceConditionCfg(v.conditionGroupId)
        if v.conditionGroupId == 0 or serviceConditionCfg ~= nil and NPCInterface.CheckNpcServiceConditon(serviceConditionCfg) == true then
          Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TARGET_SERVICE, {
            k,
            npcID,
            targetService.userParam
          })
          return
        end
      elseif targetService.serviceID ~= nil and targetService.serviceID == v.serviceID and (v.conditionGroupId == 0 or serviceConditionCfg ~= nil and NPCInterface.CheckNpcServiceConditon(serviceConditionCfg) == true) then
        Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE_WITH_REQUIREMENT, {
          k,
          npcID,
          targetService.userParam,
          -1
        })
        return
      end
    end
  end
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  local infos = taskInterface:GetTaskInfos()
  local taskPathFindTaskID = 0
  local taskPathFindGraphID = 0
  taskPathFindTaskID, taskPathFindGraphID = taskInterface:GetTaskPathFindParam()
  local taskInfo = taskInterface:GetTaskInfo(taskPathFindTaskID, taskPathFindGraphID)
  if taskInfo ~= nil and taskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT and taskPathFindTaskID ~= 0 and taskPathFindGraphID ~= 0 then
    local taskCfg = TaskInterface.GetTaskCfg(taskPathFindTaskID)
    local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_BAG)
    if conditionID > 0 then
      local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
      for k, v in pairs(npcCfg.serviceCfgs) do
        local serviceConditionCfg = NPCInterface.GetNpcServiceConditionCfg(v.conditionGroupId)
        if (v.serviceType == ServiceType.Sell or v.serviceType == ServiceType.BaiTan or v.serviceType == ServiceType.ClientItemSell) and (v.conditionGroupId == 0 or conditionGroupId ~= 0 and serviceConditionCfg ~= nil and NPCInterface.CheckNpcServiceConditon(serviceConditionCfg) == true) then
          taskInterface:_SetCurrTaskFindPathRequirement(taskPathFindTaskID, taskPathFindGraphID)
          local taskFindPathRequirementID, taskFindPathNeedCount = taskInterface:GetCurrTaskFindPathRequirement()
          Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE_WITH_REQUIREMENT, {
            k,
            npcID,
            taskFindPathRequirementID,
            taskFindPathNeedCount,
            targetGraphID = taskPathFindGraphID,
            targetTaskID = taskPathFindTaskID
          })
          local ECSoundMan = require("Sound.ECSoundMan")
          ECSoundMan.Instance():Play2DInterruptSoundByID(npcCfg.defaultAudioId)
          taskInterface:SetTaskPathFindParam(0, 0)
          return
        end
      end
    end
    local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_PET)
    if conditionID > 0 then
      local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
      local NPCServiceConst = require("Main.npc.NPCServiceConst")
      for k, v in pairs(npcCfg.serviceCfgs) do
        local serviceConditionCfg = NPCInterface.GetNpcServiceConditionCfg(v.conditionGroupId)
        if v.serviceID == NPCServiceConst.PET_SHOP_BUY and (v.conditionGroupId == 0 or conditionGroupId ~= 0 and serviceConditionCfg ~= nil and NPCInterface.CheckNpcServiceConditon(serviceConditionCfg) == true) then
          taskInterface:_SetCurrTaskFindPathPetRequirement(taskPathFindTaskID, taskPathFindGraphID)
          local taskFindPathRequirementID, taskFindPathNeedCount = taskInterface:GetCurrTaskFindPathRequirement()
          Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE_WITH_REQUIREMENT, {
            k,
            npcID,
            taskFindPathRequirementID,
            taskFindPathNeedCount,
            targetGraphID = taskPathFindGraphID,
            targetTaskID = taskPathFindTaskID
          })
          local ECSoundMan = require("Sound.ECSoundMan")
          ECSoundMan.Instance():Play2DInterruptSoundByID(npcCfg.defaultAudioId)
          taskInterface:SetTaskPathFindParam(0, 0)
          return
        end
      end
    end
    taskInterface:SetTaskPathFindParam(0, 0)
  end
  local dlg = require("Main.npc.ui.NPCDlg").Instance()
  if dlg:IsShow() == true then
    dlg:_ClearItems()
  end
  NPCModule._DoInteractiveNPC2({npcID, extraInfo = extraInfo}, nil)
end
def.static("table", "table")._DoInteractiveNPC2 = function(p1, p2)
  local npcID = p1[1]
  local extraInfo = p1.extraInfo
  local dlg = require("Main.npc.ui.NPCDlg").Instance()
  if dlg:IsShow() == true and dlg:GetTargetNPCID() == npcID then
    dlg:_SetNpcID()
  else
    do
      local taskCount = 0
      local serviceCount = 0
      local theOneTaskID = 0
      local theOneGraphID = 0
      local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
      local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
      local TaskInterface = require("Main.task.TaskInterface")
      local taskInterface = TaskInterface.Instance()
      local infos = taskInterface:GetTaskInfos()
      local npcCfg = NPCInterface.GetNPCCfg(npcID)
      for taskId, graphIdValue in pairs(infos) do
        local taskCfg = TaskInterface.GetTaskCfg(taskId)
        for graphId, info in pairs(graphIdValue) do
          if taskCfg.GetGiveTaskNPC() == npcID and info.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
            taskCount = taskCount + 1
            theOneTaskID = taskId
            theOneGraphID = graphId
          end
          if taskCfg.GetFinishTaskNPC() == npcID and info.state == TaskConsts.TASK_STATE_FINISH then
            taskCount = taskCount + 1
            theOneTaskID = taskId
            theOneGraphID = graphId
          end
          if info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
            for k, v in pairs(taskCfg.finishConIds) do
              local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
              if conditionID > 0 then
                local condCfg = TaskInterface.GetTaskConditionKillNpc(conditionID)
                if condCfg.fixNPCId == npcID then
                  local talkCfg = TaskInterface.GetTaskTalkCfg(taskId)
                  local dlgs = talkCfg.dlgs[TaskConsts.BEFORE_BATTLE_DIALOG]
                  if dlgs ~= nil and 0 < table.maxn(dlgs.content) then
                    taskCount = taskCount + 2
                  else
                    taskCount = taskCount + 1
                  end
                  theOneTaskID = taskId
                  theOneGraphID = graphId
                end
                break
              end
              conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_NPC_DLG)
              if conditionID > 0 then
                local condCfg = TaskInterface.GetTaskConditionNPCDialog(conditionID)
                if condCfg.NpcID == npcID then
                  taskCount = taskCount + 1
                  theOneTaskID = taskId
                  theOneGraphID = graphId
                  break
                end
              end
              break
            end
          end
        end
      end
      if taskCount <= 1 then
        for k, v in pairs(npcCfg.serviceCfgs) do
          local serviceConditionCfg = NPCInterface.GetNpcServiceConditionCfg(v.conditionGroupId)
          local serviceCondition = v.conditionGroupId == 0 or serviceConditionCfg ~= nil and NPCInterface.CheckNpcServiceConditon(serviceConditionCfg)
          local serviceCustom = npcInterface:CheckNPCCustomCondition(v.serviceID)
          if serviceCondition == true and serviceCustom == true then
            serviceCount = serviceCount + 1
          end
        end
      end
      if taskCount == 1 and serviceCount == 0 then
        Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SELECT_TASK, {theOneTaskID, theOneGraphID})
      elseif dlg:SetNpcID(npcID, true, extraInfo) == true then
        if 0 < instance._targetGraphID and 0 < instance._targetTaskID then
          dlg:SetTargetTask(instance._targetGraphID, instance._targetTaskID)
          instance._targetGraphID = 0
          instance._targetTaskID = 0
        end
        local function fn()
          dlg:ShowDlg()
          local ECSoundMan = require("Sound.ECSoundMan")
          ECSoundMan.Instance():Play2DInterruptSoundByID(npcCfg.defaultAudioId)
        end
        if NPCModule._CheckNPCServiceConditionNeedWait(npcCfg) == false then
          instance._npcServiceWaitReadyFunction = fn
        else
          instance._npcServiceWaitReadyFunction = nil
          fn()
        end
      end
    end
  end
end
def.static("table", "=>", "boolean")._CheckNPCServiceConditionNeedWait = function(npcCfg)
  local ret = true
  npcInterface._NPCServiceCustomConditionWaitStateTable = {}
  for k, v in pairs(npcCfg.serviceCfgs) do
    local fn = npcInterface._NPCServiceCustomConditionWaitTable[v.serviceID]
    if fn ~= nil then
      ret = false
      npcInterface._NPCServiceCustomConditionWaitStateTable[v.serviceID] = true
      fn(v.serviceID)
    end
  end
  return ret
end
def.static("table", "table").OnClickMonster = function(p1, p2)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myRoleID = heroModule:GetMyRoleId()
  local teamData = require("Main.Team.TeamData").Instance()
  local ret = teamData:HasTeam() == true and teamData:IsCaptain(myRoleID) == false
  if ret == true then
    local ST_NORMAL = require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL
    local isNormal = teamData:GetMemberStatus(myRoleID) == ST_NORMAL
    if isNormal == true then
      return
    end
  end
  if heroModule:IsInState(RoleState.ESCORT) then
    return
  end
  local monsterInstID = p1[1]
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local theMonster = pubroleModule:GetMonster(monsterInstID)
  if theMonster == nil then
    warn("[OnClickMonster]monster is nil for id: ", monsterInstID)
    return
  end
  if pubroleModule:GetMonsterCfg(theMonster.m_cfgId) == nil then
    return
  end
  if heroModule:IsPatroling() == true then
    heroModule:StopPatroling()
  end
  local heroPos = heroModule.myRole:GetPos()
  local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local mapID = MapModule:GetMapId()
  local monsterPos, isInAir = pubroleModule:GetMonsterPos(monsterInstID)
  local dx = (monsterPos.x - heroPos.x) * (monsterPos.x - heroPos.x)
  local dy = (monsterPos.y - heroPos.y) * (monsterPos.y - heroPos.y)
  local d = dx + dy
  if d > 32768 then
    instance._TargetMonsterInstID = monsterInstID
    heroModule.needShowAutoEffect = true
    heroModule:MoveTo(mapID, monsterPos.x, monsterPos.y, isInAir and 1 or 0, 5, MoveType.AUTO, nil)
    return
  end
  if theMonster ~= nil then
    if not theMonster:IsInState(RoleState.BATTLE) then
      theMonster:LookAtTarget(heroModule.myRole)
    end
    heroModule.myRole:LookAtTarget(theMonster)
  end
  local dlg = require("Main.npc.ui.NPCDlg").Instance()
  if dlg:SetMonsterID(monsterInstID) == true then
    dlg:ShowDlg()
  end
end
def.static("table", "table").OnTaskInfoChanged = function(p1, p2)
  require("Main.Common.FunctionQueue").Instance():Push(function()
    NPCModule.RefeshNPCTaskStatus()
  end)
end
def.static().RefeshNPCTaskStatus = function()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local taskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  local infos = taskInterface:GetTaskInfos()
  if infos == nil then
    return
  end
  local ttMAIN = {
    2,
    2,
    2,
    1,
    2,
    2
  }
  local ttBRANCH = {
    3,
    3,
    3,
    1,
    3,
    3
  }
  local ttINSTANCE = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local ttDAILY = {
    7,
    8,
    5,
    1,
    8,
    5
  }
  local ttNORMAL = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local ttACTIVITY = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local ttTRIAL = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local ttMASTER = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local ttMENPAITIAOZHAN = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local ttZHIYIN = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local ttNULL = {
    6,
    8,
    4,
    1,
    8,
    4
  }
  local NPCTaskStatusSortKey = {}
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_MAIN] = ttMAIN
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_BRANCH] = ttBRANCH
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_INSTANCE] = ttINSTANCE
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_DAILY] = ttDAILY
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_NORMAL] = ttNORMAL
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_ACTIVITY] = ttACTIVITY
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_TRIAL] = ttTRIAL
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_MASTER] = ttMASTER
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_MENPAITIAOZHAN] = ttMENPAITIAOZHAN
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_ZHIYIN] = ttZHIYIN
  NPCTaskStatusSortKey[taskConsts.TASK_TYPE_NULL] = ttNULL
  local SortKeyIdx = {}
  SortKeyIdx[taskConsts.TASK_STATE_CAN_ACCEPT] = 1
  SortKeyIdx[taskConsts.TASK_STATE_ALREADY_ACCEPT] = 2
  SortKeyIdx[taskConsts.TASK_STATE_FINISH] = 3
  SortKeyIdx[taskConsts.TASK_STATE_FAIL] = 5
  local oldNPCTaskStatus = npcInterface:GetNPCTaskStatus()
  local new_NPCTaskStatus = {}
  for taskId, graphIdValue in pairs(infos) do
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    for graphId, info in pairs(graphIdValue) do
      while true do
        local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
        if info.state == taskConsts.TASK_STATE_ALREADY_ACCEPT then
          local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
          if conditionID > 0 then
            local condCfg = TaskInterface.GetTaskConditionKillNpc(conditionID)
            new_NPCTaskStatus[condCfg.fixNPCId] = 1
            break
          end
        end
        local theNPCTaskStatus = 0
        local targetNPCID = 0
        if info.state == taskConsts.TASK_STATE_ALREADY_ACCEPT then
          local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_NPC_DLG)
          if conditionID > 0 then
            local condCfg = TaskInterface.GetTaskConditionNPCDialog(conditionID)
            theNPCTaskStatus = NPCTaskStatusSortKey[graphCfg.taskType][6]
            targetNPCID = condCfg.NpcID
          end
        end
        if info.state == taskConsts.TASK_STATE_CAN_ACCEPT then
          local sskeyTable = NPCTaskStatusSortKey[graphCfg.taskType]
          if sskeyTable ~= nil then
            local s = sskeyTable[info.state]
            if theNPCTaskStatus == 0 or theNPCTaskStatus > s then
              theNPCTaskStatus = s
              targetNPCID = taskCfg.GetGiveTaskNPC()
            end
          end
        end
        if info.state == taskConsts.TASK_STATE_FINISH then
          local sskeyTable = NPCTaskStatusSortKey[graphCfg.taskType]
          if sskeyTable ~= nil then
            local s = sskeyTable[info.state]
            if theNPCTaskStatus == 0 or theNPCTaskStatus > s then
              theNPCTaskStatus = s
              targetNPCID = taskCfg.GetFinishTaskNPC()
            end
          end
        end
        if info.state == taskConsts.TASK_STATE_FAIL then
          local sskeyTable = NPCTaskStatusSortKey[graphCfg.taskType]
          if sskeyTable ~= nil then
            local s = sskeyTable[info.state]
            if theNPCTaskStatus == 0 or theNPCTaskStatus > s then
              theNPCTaskStatus = s
              targetNPCID = taskCfg.GetFinishTaskNPC()
            end
          end
        end
        if targetNPCID ~= 0 then
          local status = new_NPCTaskStatus[targetNPCID] or 0
          if status == 0 or theNPCTaskStatus < status then
            new_NPCTaskStatus[targetNPCID] = theNPCTaskStatus
          end
        end
        break
      end
    end
  end
  local chged = {}
  for NPCID, newStatus in pairs(new_NPCTaskStatus) do
    local oldStatus = oldNPCTaskStatus[NPCID]
    if oldStatus ~= newStatus then
      chged[NPCID] = newStatus
    end
  end
  for NPCID, oldStatus in pairs(oldNPCTaskStatus) do
    local newStatus = new_NPCTaskStatus[NPCID]
    newStatus = newStatus or 0
    if oldStatus ~= newStatus then
      chged[NPCID] = newStatus
    end
  end
  npcInterface:SetNPCTaskStatus(new_NPCTaskStatus)
  for NPCID, newStatus in pairs(chged) do
    while true do
      if NPCID == 101 then
        break
      end
      local iconid = 0
      if NPCID == 100 then
        local activityInterface = require("Main.activity.ActivityInterface").Instance()
        local menpaiNPC = activityInterface:GetMenpaiNPCData(heroProp.occupation)
        NPCID = menpaiNPC.NPCID
      end
      local npcCfg = NPCInterface.GetNPCCfg(NPCID)
      if npcCfg and npcCfg.npcIconId ~= 0 then
        iconid = npcCfg.npcIconId
      else
        iconid = NPCInterface.GetFlagIcon(newStatus)
      end
      Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TASK_STATUS_CHANGED, {NPCID, iconid})
      break
    end
  end
end
def.static("table", "table").OnHeroPropInit = function(param1, param2)
  if instance._FindPathNPCCache > 0 then
    local targetNPC = instance._FindPathNPCCache
    instance._FindPathNPCCache = 0
    NPCModule.OnDoNPC({npcID = targetNPC}, nil)
  end
  NPCModule.RefeshNPCTaskStatus()
end
def.static("table", "table").OnNPCGotoTargetService = function(param1, param2)
  local npcID = param1[1]
  local serviceType = param1[2]
  local userParam = param1[3]
  instance._TargetService = {}
  instance._TargetService.serviceType = serviceType
  instance._TargetService.userParam = userParam
  NPCModule.OnDoNPC({npcID = npcID}, nil)
end
def.static("table", "table").OnNPCGotoShop = function(param1, param2)
  local serviceID = param1[1]
  local npcID = param1[2]
  local itemID = param1[3]
  instance._TargetService = {}
  instance._TargetService.serviceID = serviceID
  instance._TargetService.userParam = itemID
  NPCModule.OnDoNPC({npcID = npcID}, nil)
end
def.static("table").OnSNPCNormalResult = function(p)
  if p.result == p.NPC_SERVICE_BUFF_ALREADY_HAVE then
    Toast(textRes.NPC[50])
  elseif p.result == p.NPC_SERVICE_IS_FORBIDDEN then
    Toast(textRes.NPC[51])
  end
end
NPCModule.Commit()
return NPCModule

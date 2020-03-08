local Lplus = require("Lplus")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGUIMan = require("GUI.ECGUIMan")
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local Vector = require("Types.Vector")
local NPCInterface = require("Main.npc.NPCInterface")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local NpcDlg = Lplus.Extend(ECPanelBase, "NpcDlg")
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local def = NpcDlg.define
local inst
def.static("=>", NpcDlg).Instance = function()
  if inst == nil then
    inst = NpcDlg()
    inst:Init()
  end
  return inst
end
NpcDlg.ITEM_TASK = 1
NpcDlg.ITEM_FUNCTION = 2
def.field("table")._Param = nil
def.field("number")._TargetNPCID = 0
def.field("number")._TargetMonsterInstID = 0
def.field("table")._TargetExtraInfo = nil
def.field("boolean")._defaultContent = true
def.field("number")._customHeadID = 0
def.field("string")._customName = ""
def.field("string")._customDefaultText = ""
def.field(UIModelWrap)._UIModelWrap = nil
def.field("number")._targetTaskID = 0
def.field("number")._targetGraphID = 0
def.field("number")._curNPCID = 0
def.field("table")._lvTypeFn = nil
def.field("function")._customCallback = nil
def.method().Init = function(self)
  self.m_priority = 90
  self._lvTypeFn = {}
  self._lvTypeFn[TaskConsts.ROLE_LEVEL_TYPE] = NpcDlg.CheckRoleLevel
  self._lvTypeFn[TaskConsts.TEAM_LEADER_TYPE] = NpcDlg.CheckTeamLeader
  self._lvTypeFn[TaskConsts.TEAM_MAX_LEVEL] = NpcDlg.CheckTeamMaxLevel
  self._lvTypeFn[TaskConsts.TEAM_MIN_LEVEL] = NpcDlg.CheckTeamMinLevel
  self._lvTypeFn[TaskConsts.TEAM_AVG_LEVEL] = NpcDlg.CheckTeamAvgLevel
end
def.static("table", "boolean", "=>", "boolean").CheckRoleLevel = function(explicitMonsterCfg, msg)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local ret = heroProp.level >= explicitMonsterCfg.enterFightMinLevel
  if ret == false and msg == true then
    Toast(string.format(textRes.NPC[10], explicitMonsterCfg.enterFightMinLevel))
  end
  local ret2 = heroProp.level <= explicitMonsterCfg.enterFightMaxLevel
  if ret2 == false and msg == true then
    Toast(string.format(textRes.NPC[20], explicitMonsterCfg.enterFightMaxLevel))
  end
  return ret and ret2
end
def.static("table", "boolean", "=>", "boolean").CheckTeamLeader = function(explicitMonsterCfg, msg)
  local teamData = require("Main.Team.TeamData").Instance()
  local myRoleID = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local ret = teamData:HasTeam() and teamData:IsCaptain(myRoleID) and heroProp.level >= explicitMonsterCfg.enterFightMinLevel and heroProp.level <= explicitMonsterCfg.enterFightMaxLevel
  if ret == false and msg == true then
    Toast(string.format(textRes.NPC[11], explicitMonsterCfg.enterFightMinLevel, explicitMonsterCfg.enterFightMaxLevel))
  end
  return ret
end
def.static("table", "boolean", "=>", "boolean").CheckTeamMaxLevel = function(explicitMonsterCfg, msg)
  local teamData = require("Main.Team.TeamData").Instance()
  local ret = false
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if teamData:HasTeam() == true then
    local members = teamData:GetAllTeamMembers()
    local maxLevel = heroProp.level
    for k, v in pairs(members) do
      maxLevel = math.max(maxLevel, v.level)
    end
    ret = maxLevel <= explicitMonsterCfg.enterFightMaxLevel
    if ret == false and msg == true then
      Toast(string.format(textRes.NPC[12], explicitMonsterCfg.enterFightMaxLevel))
    end
  else
    ret = heroProp.level <= explicitMonsterCfg.enterFightMaxLevel
    if ret == false and msg == true then
      Toast(string.format(textRes.NPC[18], explicitMonsterCfg.enterFightMaxLevel))
    end
  end
  return ret
end
def.static("table", "boolean", "=>", "boolean").CheckTeamMinLevel = function(explicitMonsterCfg, msg)
  local teamData = require("Main.Team.TeamData").Instance()
  local ret = false
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if teamData:HasTeam() == true then
    local members = teamData:GetAllTeamMembers()
    local minLevel = heroProp.level
    for k, v in pairs(members) do
      minLevel = math.min(minLevel, v.level)
    end
    ret = minLevel >= explicitMonsterCfg.enterFightMinLevel
    if ret == false and msg == true then
      Toast(string.format(textRes.NPC[13], explicitMonsterCfg.enterFightMinLevel))
    end
  else
    ret = heroProp.level >= explicitMonsterCfg.enterFightMinLevel
    if ret == false and msg == true then
      Toast(string.format(textRes.NPC[17], explicitMonsterCfg.enterFightMinLevel))
    end
  end
  return ret
end
def.static("table", "boolean", "=>", "boolean").CheckTeamAvgLevel = function(explicitMonsterCfg, msg)
  local teamData = require("Main.Team.TeamData").Instance()
  local ret = false
  if teamData:HasTeam() == true then
    local members = teamData:GetAllTeamMembers()
    local sumLevel = 0
    local memberCount = 0
    for k, v in pairs(members) do
      memberCount = memberCount + 1
      sumLevel = sumLevel + v.level
    end
    local avgLevel = sumLevel / memberCount
    ret = avgLevel >= explicitMonsterCfg.enterFightMinLevel and avgLevel >= explicitMonsterCfg.enterFightMaxLevel
    if ret == false and msg == true then
      Toast(string.format(textRes.NPC[14], explicitMonsterCfg.enterFightMinLevel, explicitMonsterCfg.enterFightMaxLevel))
    end
  else
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    ret = heroProp.level >= explicitMonsterCfg.enterFightMinLevel and heroProp.level <= explicitMonsterCfg.enterFightMaxLevel
  end
  return ret
end
def.static("table", "boolean", "=>", "boolean").CheckTeamRoleNum = function(explicitMonsterCfg, msg)
  local ret = NPCInterface.CheckBattalTeamMemberCount(explicitMonsterCfg.enterFightMinRoleNum, explicitMonsterCfg.enterFightMaxRoleNum, msg)
  return ret
end
def.method("function").SetCustomCallback = function(self, callback)
  self._customCallback = callback
end
def.method("=>", "number").GetTargetNPCID = function(self)
  return self._TargetNPCID
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self:CreatePanel(RESPATH.PREFAB_UI_NPC_NPCDLG, 1)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, NpcDlg.OnEnterFight)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_PAUSE, NpcDlg.OnGamePause)
  local Model = self.m_panel:FindDirect("Img_Bg0/Container/Model")
  local uiModel = Model:GetComponent("UIModel")
  uiModel:set_orthographic(true)
  uiModel.mCanOverflow = true
  self._UIModelWrap = UIModelWrap.new(uiModel)
  self._UIModelWrap._bUncache = true
  if self._TargetNPCID ~= 0 then
    self:_SetNpcID()
  elseif self._TargetMonsterInstID ~= 0 then
    self:_SetMonsterID()
  else
    self:_SetHeadID()
  end
end
def.override().OnDestroy = function(self)
  self:_ClearItems()
  if self._UIModelWrap ~= nil then
    self._UIModelWrap:Destroy()
  end
  self._UIModelWrap = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, NpcDlg.OnEnterFight)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_PAUSE, NpcDlg.OnGamePause)
  self._targetTaskID = 0
  self._targetGraphID = 0
  self._TargetExtraInfo = nil
  self._curNPCID = 0
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  inst:HideDlg()
end
def.static("table", "table").OnGamePause = function(p1, p2)
  inst:HideDlg()
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_DLG_SHOWN, {
      self._curNPCID
    })
  else
    Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_DLG_HIDED, {
      self._curNPCID
    })
    self:_ClearItems()
    if self._UIModelWrap ~= nil then
      self._UIModelWrap:Destroy()
    end
  end
end
def.method("number", "number").SetTargetTask = function(self, targetGraphID, targetTaskID)
  self._targetTaskID = targetTaskID
  self._targetGraphID = targetGraphID
end
def.method("number", "boolean", "varlist", "=>", "boolean").SetNpcID = function(self, npcID, defaultContent, extraInfo)
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  if npcCfg == nil then
    print("NpcDlg.SetNpcID npcCfg == nil return false")
    return false
  end
  self._defaultContent = defaultContent
  self._TargetNPCID = npcID
  self._TargetExtraInfo = extraInfo
  self._curNPCID = npcID
  self._TargetMonsterInstID = 0
  if self:IsShow() then
    self:_SetNpcID()
  end
  return true
end
def.method()._SetNpcID = function(self)
  local npcID = self._TargetNPCID
  local extraInfo = self._TargetExtraInfo or {}
  self._TargetNPCID = 0
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  if npcCfg == nil then
    print("_SetNpcID() npcCfg == nil return")
    return
  end
  local panel = self.m_panel:FindDirect("Img_Bg0")
  local defaultTalkCount = #npcCfg.defaultTalk
  local customTalkTexts = extraInfo.customTalkTexts and extraInfo.customTalkTexts or {}
  if #customTalkTexts > 0 then
    local talkIdx = math.random(#customTalkTexts)
    local talkText = customTalkTexts[talkIdx]
    panel:FindDirect("Img_BgNpcTalk/Label_NpcTalk"):GetComponent("UILabel"):set_text(talkText)
  elseif defaultTalkCount > 0 then
    local defaultTalkIdx = math.random(defaultTalkCount)
    local defaultTalkText = npcCfg.defaultTalk[defaultTalkIdx]
    panel:FindDirect("Img_BgNpcTalk/Label_NpcTalk"):GetComponent("UILabel"):set_text(defaultTalkText)
  else
    panel:FindDirect("Img_BgNpcTalk/Label_NpcTalk"):GetComponent("UILabel"):set_text(textRes.NPC[100])
  end
  panel:FindDirect("Scroll View_Btn/Grid_Btn/Btn_01"):SetActive(false)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local theNPC
  if extraInfo and extraInfo.npc then
    theNPC = extraInfo.npc
  else
    theNPC = pubroleModule:GetNpc(npcID)
  end
  local changedModelId = 0
  local displayNpcName = npcCfg.npcName
  if theNPC ~= nil then
    changedModelId = theNPC:GetChangedModelId()
    local name = theNPC:GetName()
    if name and name ~= "" then
      displayNpcName = name
    end
  end
  panel:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(displayNpcName)
  if changedModelId == 0 then
    changedModelId = npcCfg.monsterModelTableId
  end
  local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, changedModelId)
  local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
  if headidx == 0 then
    headidx = 399
  end
  self:SetPortrait(headidx)
  if self._defaultContent == true then
    self._Param = {}
    self:_FillTaskItem(npcID)
    self:_FillServiceItem(npcCfg)
  else
    self:_FillCustomItems()
  end
end
def.method("table")._FillServiceItem = function(self, npcCfg)
  local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
  local npcInterface = NPCInterface.Instance()
  local tb = {}
  for k, v in pairs(npcCfg.serviceCfgs) do
    local serviceConditionCfg = NPCInterface.GetNpcServiceConditionCfg(v.conditionGroupId)
    local serviceCondition = v.conditionGroupId == 0 or serviceConditionCfg ~= nil and NPCInterface.CheckNpcServiceConditon(serviceConditionCfg)
    local serviceCustom = npcInterface:CheckNPCCustomCondition(v.serviceID)
    if serviceCondition == true and serviceCustom == true then
      table.insert(tb, v)
    end
  end
  table.sort(tb, function(l, r)
    return l.weight < r.weight
  end)
  for k, v in pairs(tb) do
    local index = table.maxn(self._Param) + 1
    self:_AddItem(v.GetChoiceName(), index, NpcDlg.ITEM_FUNCTION, false, v.serviceType == ServiceType.Sell, false, false, false)
    local serviceInfo = {}
    serviceInfo.itemType = v.serviceType
    serviceInfo.cfg = v
    table.insert(self._Param, serviceInfo)
  end
end
def.method("number")._FillTaskItem = function(self, npcID)
  local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
  local TaskInterface = require("Main.task.TaskInterface")
  local infos = TaskInterface.Instance():GetTaskInfos()
  local tableTaskTypeSortKey = {}
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_MAIN] = "2"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_BRANCH] = "3"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_INSTANCE] = "7"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_DAILY] = "6"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_NORMAL] = "5"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_ACTIVITY] = "4"
  local tableTaskStateSortKey = {}
  tableTaskStateSortKey[TaskConsts.TASK_STATE_FINISH] = "2"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_CAN_ACCEPT] = "3"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_ALREADY_ACCEPT] = "4"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_DELETE] = "4"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_FAIL] = "4"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_VISIABLE] = "5"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_UN_VISIABLE] = "6"
  local taskInfoList = {}
  local npcToTaskCfg = NPCInterface.GetNPCToTaskCfg(npcID)
  for taskId, graphIdValue in pairs(infos) do
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    for graphId, info in pairs(graphIdValue) do
      local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
      while true do
        if taskCfg.GetGiveTaskNPC() == npcID then
          if info.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
            local taskInfo = {}
            taskInfo.itemType = NPCInterface.NPC_TYPE_TASK
            taskInfo.state = info.state
            taskInfo.graphId = graphId
            taskInfo.cfg = taskCfg
            taskInfo.graphCfg = graphCfg
            local sskey = tableTaskStateSortKey[info.state] or "0"
            local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
            taskInfo.sortKey = tonumber(sskey .. tskey)
            table.insert(taskInfoList, taskInfo)
            break
          end
          if info.state == TaskConsts.TASK_STATE_VISIABLE then
            local taskInfo = {}
            taskInfo.itemType = NPCInterface.NPC_TYPE_TASK
            taskInfo.state = info.state
            taskInfo.graphId = graphId
            taskInfo.cfg = taskCfg
            taskInfo.graphCfg = graphCfg
            local sskey = tableTaskStateSortKey[info.state] or "0"
            local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
            taskInfo.sortKey = tonumber(sskey .. tskey)
            table.insert(taskInfoList, taskInfo)
            break
          end
        end
        if info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
          local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
          if conditionID > 0 then
            local condCfg = TaskInterface.GetTaskConditionKillNpc(conditionID)
            if condCfg.fixNPCId == npcID then
              local taskInfo = {}
              taskInfo.itemType = NPCInterface.NPC_TYPE_TASK
              taskInfo.state = info.state
              taskInfo.graphId = graphId
              taskInfo.cfg = taskCfg
              taskInfo.graphCfg = graphCfg
              local sskey = 1
              local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
              taskInfo.sortKey = tonumber(sskey .. tskey)
              table.insert(taskInfoList, taskInfo)
            end
            break
          end
          conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_NPC_DLG)
          if conditionID > 0 then
            local condCfg = TaskInterface.GetTaskConditionNPCDialog(conditionID)
            if condCfg.NpcID == npcID then
              local taskInfo = {}
              taskInfo.itemType = NPCInterface.NPC_TYPE_TASK
              taskInfo.state = info.state
              taskInfo.graphId = graphId
              taskInfo.cfg = taskCfg
              taskInfo.graphCfg = graphCfg
              local sskey = 1
              local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
              taskInfo.sortKey = tonumber(sskey .. tskey)
              table.insert(taskInfoList, taskInfo)
            end
            break
          end
          conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_QUESTION)
          if conditionID > 0 then
            local condCfg = TaskInterface.TaskConditionFinishQuestion(conditionID)
            if condCfg.npcId == npcID then
              local taskInfo = {}
              taskInfo.itemType = NPCInterface.NPC_TYPE_TASK
              taskInfo.state = info.state
              taskInfo.graphId = graphId
              taskInfo.cfg = taskCfg
              taskInfo.graphCfg = graphCfg
              local sskey = 1
              local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
              taskInfo.sortKey = tonumber(sskey .. tskey)
              table.insert(taskInfoList, taskInfo)
            end
            break
          end
        end
        if taskCfg.GetFinishTaskNPC() == npcID and (info.state == TaskConsts.TASK_STATE_FINISH or info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT) then
          local talkCfg = TaskInterface.GetTaskTalkCfg(taskId)
          local dlgs = talkCfg.dlgs[TaskConsts.NOT_FINISH_DIALOG]
          local hasDlg = dlgs ~= nil and 0 < table.maxn(dlgs.content)
          if taskCfg.autoFinish == true and hasDlg == true then
            break
          end
          local taskInfo = {}
          taskInfo.itemType = NPCInterface.NPC_TYPE_TASK
          taskInfo.state = info.state
          taskInfo.graphId = graphId
          taskInfo.cfg = taskCfg
          taskInfo.graphCfg = graphCfg
          local sskey = tableTaskStateSortKey[info.state] or "0"
          local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
          taskInfo.sortKey = tonumber(sskey .. tskey)
          table.insert(taskInfoList, taskInfo)
          break
        end
        break
      end
    end
  end
  local sortFn = function(l, r)
    return l.sortKey < r.sortKey
  end
  local dispTaskInfos = {}
  table.sort(taskInfoList, sortFn)
  local index = 1
  for k, v in pairs(taskInfoList) do
    local isOpen = true
    if v.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
      isOpen = TaskInterface.Instance():isOpenTaskGraph(v.graphId)
    end
    if isOpen then
      local str = TaskInterface.WarpTaskTypeStr(v.graphCfg.taskType, v.cfg.taskName)
      local battle = false
      local main = false
      local brance = false
      if v.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
        local conditionID = v.cfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
        battle = conditionID > 0
      end
      main = v.graphCfg.taskType == TaskConsts.TASK_TYPE_MAIN
      brance = v.graphCfg.taskType == TaskConsts.TASK_TYPE_BRANCH
      local targetTask = v.graphId == self._targetGraphID and v.cfg.taskID == self._targetTaskID
      if targetTask == false then
        targetTask = TaskInterface.GetTaskEffectCfg(v.graphId, v.cfg.taskID)
      end
      self:_AddItem(str, index, NpcDlg.ITEM_TASK, battle, false, main, brance, targetTask)
      index = index + 1
      table.insert(self._Param, v)
    end
  end
end
def.method()._FillCustomItems = function(self)
  for k, v in pairs(self._Param) do
    local taskInfo = v
    self:_AddItem(taskInfo.dispText, k, NpcDlg.ITEM_TASK, taskInfo.battle, false, false, false, false)
  end
end
def.method("number", "=>", "boolean").SetMonsterID = function(self, monsterInstID)
  self._TargetMonsterInstID = monsterInstID
  self._TargetNPCID = 0
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local monsterID = pubroleModule:GetMonsterCfgId(monsterInstID)
  local monsterCfg = pubroleModule:GetMonsterCfg(monsterID)
  if monsterCfg == nil then
    print("** End  ** NpcDlg.SetMonsterID (", monsterInstID, ") monsterCfg == nil return false")
    return false
  end
  if self:IsShow() then
    self:_SetMonsterID()
  end
  return true
end
def.method()._SetMonsterID = function(self)
  local pubRoleInterface = require("Main.Pubrole.PubroleInterface")
  local monsterInstID = self._TargetMonsterInstID
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local monsterID = pubroleModule:GetMonsterCfgId(monsterInstID)
  self._TargetMonsterInstID = 0
  local monsterCfg = pubroleModule:GetMonsterCfg(monsterID)
  if monsterCfg == nil then
    return
  end
  local panel = self.m_panel:FindDirect("Img_Bg0")
  panel:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(monsterCfg.name)
  panel:FindDirect("Img_BgNpcTalk/Label_NpcTalk"):GetComponent("UILabel"):set_text(monsterCfg.talk)
  local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, monsterCfg.modelId)
  local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
  if headidx == 0 then
    headidx = 399
  end
  self:SetPortrait(headidx)
  self._Param = {}
  local taskInfo = {}
  taskInfo.itemType = NPCInterface.NPC_TYPE_MONSTER
  taskInfo.monsterID = monsterID
  taskInfo.monsterInstID = monsterInstID
  table.insert(self._Param, taskInfo)
  self:_AddItem(monsterCfg.attackOptionTalk, 1, NpcDlg.ITEM_TASK, true, false, false, false, false)
  taskInfo = {}
  taskInfo.itemType = NPCInterface.NPC_TYPE_CLOSE
  table.insert(self._Param, taskInfo)
  self:_AddItem(monsterCfg.notAttackOptionTalk, 2, NpcDlg.ITEM_TASK, false, false, false, false, false)
  local mon = pubroleModule:GetMonster(monsterInstID)
  if mon and mon:IsInState(RoleState.BATTLE) then
    taskInfo = {}
    taskInfo.itemType = NPCInterface.NPC_TYPE_WATCH
    taskInfo.monsterInstID = monsterInstID
    table.insert(self._Param, taskInfo)
    self:_AddItem(textRes.NPC[30], 3, NpcDlg.ITEM_TASK, false, false, false, false, false)
  end
end
def.method("number", "string", "string").SetHeadID = function(self, headID, name, defaultText)
  self._TargetMonsterInstID = 0
  self._TargetNPCID = 0
  self._customHeadID = headID
  self._customName = name
  self._customDefaultText = defaultText
  self._defaultContent = false
  if self:IsShow() then
    self:_SetHeadID()
  end
end
def.method()._SetHeadID = function(self)
  local panel = self.m_panel:FindDirect("Img_Bg0")
  panel:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(self._customName)
  panel:FindDirect("Img_BgNpcTalk/Label_NpcTalk"):GetComponent("UILabel"):set_text(self._customDefaultText)
  self:SetPortrait(self._customHeadID)
  self:_FillCustomItems()
end
def.method("string", "number", "number", "boolean", "boolean", "boolean", "boolean", "boolean")._AddItem = function(self, text, index, itemType, battle, sell, main, brance, lightingRound)
  local panel = self.m_panel:FindDirect("Img_Bg0")
  local Grid_Btn = panel:FindDirect("Scroll View_Btn/Grid_Btn")
  local count = Grid_Btn:get_childCount()
  local grid = Grid_Btn:GetComponent("UIGrid")
  local btn1 = Grid_Btn:FindDirect("Btn_01")
  local parent = btn1.parent
  local btn = Grid_Btn:FindDirect(string.format("Btn_%02d", index))
  if btn ~= nil then
    btn:SetActive(true)
  else
    local newbtn = Object.Instantiate(btn1)
    btn = newbtn
    grid:AddChild(newbtn.transform)
    btn:set_name(string.format("Btn_%02d", index))
    btn.parent = parent
    btn:set_localScale(Vector.Vector3.one)
    grid:Reposition()
    self:TouchGameObject(self.m_panel, self.m_parent)
  end
  btn:FindDirect("Label_Btn01"):GetComponent("UILabel"):set_text(text)
  btn:FindDirect("Group_Task/Img_Sign"):SetActive(battle)
  btn:FindDirect("Group_Task/Img_SignZhu"):SetActive(battle == false and main == true)
  btn:FindDirect("Group_Task/Img_SignZhi"):SetActive(battle == false and brance == true)
  btn:FindDirect("Group_Function"):SetActive(sell == true)
  btn:FindDirect("FX_UI"):SetActive(lightingRound == true)
end
def.method("string", "table", "boolean").AddItem = function(self, text, itemParam, battle)
  local taskInfo = {}
  taskInfo.itemType = NPCInterface.NPC_TYPE_CUSTOM
  taskInfo.dispText = text
  taskInfo.itemParam = itemParam
  taskInfo.battle = battle
  self._Param = self._Param or {}
  table.insert(self._Param, taskInfo)
  if self:IsShow() == true then
    local idx = #self._Param + 1
    self:_AddItem(text, idx, NpcDlg.ITEM_TASK, battle, false, false, false, false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Img_Bg1" or id == "Sprite" then
    self:HideDlg()
    return
  end
  local strs = string.split(id, "_")
  local index = tonumber(strs[2])
  if strs[1] ~= "Btn" or index == nil then
    return
  end
  local selectedInfo = self._Param[index]
  local tableFn = {}
  tableFn[NPCInterface.NPC_TYPE_CLOSE] = self.OnCloseServiceSelected
  tableFn[NPCInterface.NPC_TYPE_NORMAL] = self.OnServiceSelected
  tableFn[NPCInterface.NPC_TYPE_TRADE] = self.OnServiceSelected
  tableFn[NPCInterface.NPC_TYPE_TRANSFER] = self.OnServiceSelected
  tableFn[NPCInterface.NPC_TYPE_STALL] = self.OnServiceSelected
  tableFn[NPCInterface.NPC_TYPE_FIGHT] = self.OnServiceSelected
  tableFn[NPCInterface.NPC_TYPE_BUFF] = self.OnServiceSelected
  tableFn[NPCInterface.NPC_TYPE_SONG] = self.OnServiceSelected
  tableFn[NPCInterface.NPC_TYPE_TASK] = self.OnTaskSelected
  tableFn[NPCInterface.NPC_TYPE_TASK_BATTLE] = self.OnTaskBattleSelected
  tableFn[NPCInterface.NPC_TYPE_MONSTER] = self.OnMonster
  tableFn[NPCInterface.NPC_TYPE_CUSTOM] = self.OnCustom
  tableFn[NPCInterface.NPC_TYPE_WATCH] = self.OnWatchBattle
  local fn = tableFn[selectedInfo.itemType]
  if fn ~= nil then
    fn(self, index, selectedInfo.itemType)
  end
end
def.method("number", "number").OnCloseServiceSelected = function(self, iIndex, itemType)
  self:HideDlg()
end
def.method("number", "number").OnWatchBattle = function(self, iIndex, itemType)
  local selectedTaskInfo = self._Param[iIndex]
  if selectedTaskInfo then
    local monsterInstID = selectedTaskInfo.monsterInstID
    if monsterInstID and monsterInstID > 0 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CObserveMapMonsterFight").new(monsterInstID))
    end
  end
end
def.method("number", "number").OnServiceSelected = function(self, iIndex, itemType)
  warn("**************NpcDlg.OnServiceSelected(", iIndex, itemType, ")")
  local selctedInfo = self._Param[iIndex]
  local serviceID = selctedInfo.cfg.serviceID
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  local extraInfo = self._TargetExtraInfo
  self:HideDlg()
  local serviceCfg = NPCInterface.GetNpcServiceCfg(serviceID)
  if serviceCfg.conditionGroupId ~= 0 then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_SERVICE_CONDITON_CFG, serviceCfg.conditionGroupId)
    if record ~= nil then
      local teamState = DynamicRecord.GetIntValue(record, "teamState")
      local teamNumMin = DynamicRecord.GetIntValue(record, "teamNumMin")
      local teamNumMax = DynamicRecord.GetIntValue(record, "teamNumMax")
      local levelMin = DynamicRecord.GetIntValue(record, "levelMin")
      local ThreeStateEnum = require("consts.mzm.gsp.npc.confbean.ThreeStateEnum")
      local teamData = require("Main.Team.TeamData").Instance()
      if teamState ~= ThreeStateEnum.Ignore then
        local ret = teamData:HasTeam()
        if teamState == ThreeStateEnum.Yes then
          local succeed = NPCInterface.CheckBattalTeamMemberCount(teamNumMin, teamNumMax, true)
          if succeed == false then
            return
          end
        elseif teamState == ThreeStateEnum.No and ret == true then
          Toast(string.format(textRes.NPC[21]))
          return
        end
      end
      local members = teamData:GetAllTeamMembers()
      if #members > 0 then
        local succeed = NPCInterface.CheckBattleTeamMemberLevel(levelMin)
        if not succeed then
          Toast(string.format(textRes.NPC[23], levelMin))
          return
        end
      end
    end
  end
  local tableFn = {}
  tableFn[NPCInterface.NPC_TYPE_NORMAL] = function(param)
    local serviceID = param[1]
    local npcID = param[2]
    Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, {
      serviceID,
      npcID,
      extraInfo
    })
  end
  tableFn[NPCInterface.NPC_TYPE_TRADE] = function(param)
    local serviceID = param[1]
    local npcID = param[2]
    Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TRADE, {
      serviceID,
      npcID,
      extraInfo
    })
  end
  tableFn[NPCInterface.NPC_TYPE_TRANSFER] = function(param)
    local serviceID = param[1]
    local npcID = param[2]
    local function transform()
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.npc.CNPCTransforService").new(npcID, serviceID))
    end
    local cfg = NPCInterface.GetNpcServiceTransferCfg(serviceID)
    local ACKAgainWords = cfg and cfg.ACKAgainWords or ""
    if ACKAgainWords ~= "" then
      local title = textRes.NPC[24]
      local desc = ACKAgainWords
      require("GUI.CommonConfirmDlg").ShowConfirm(title, desc, function(s)
        if s == 1 then
          transform()
        end
      end, nil)
    else
      transform()
    end
  end
  tableFn[NPCInterface.NPC_TYPE_STALL] = function(param)
    local serviceID = param[1]
    local npcID = param[2]
    Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TRADE, {
      serviceID,
      npcID,
      extraInfo
    })
  end
  tableFn[NPCInterface.NPC_TYPE_FIGHT] = function(param)
    local serviceID = param[1]
    local npcID = param[2]
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.npc.CNPCFightService").new(npcID, serviceID))
  end
  tableFn[NPCInterface.NPC_TYPE_BUFF] = function(param)
    local serviceID = param[1]
    local npcID = param[2]
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.npc.CNPCBuffService").new(npcID, serviceID))
  end
  tableFn[NPCInterface.NPC_TYPE_SONG] = function(param)
    local serviceID = param[1]
    local npcID = param[2]
    NPCInterface.Instance():ShowSong(serviceID)
  end
  local param = {serviceID, npcID}
  local fn = tableFn[itemType]
  if serviceCfg.dialogs ~= nil then
    local contents = {}
    for k, v in pairs(serviceCfg.dialogs) do
      local content = {}
      content.npcid = npcID
      local txt = string.gsub(v, "\\n", "\n")
      content.txt = string.gsub(txt, "\n", "<br>")
      table.insert(contents, content)
    end
    local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
    taskModule:ShowTaskTalkCustom(contents, param, fn)
  else
    fn(param)
  end
end
def.method("number", "number").OnNormalServiceSelected = function(self, iIndex, itemType)
  local selctedInfo = self._Param[iIndex]
  local serviceID = selctedInfo.cfg.serviceID
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  self:HideDlg()
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, {serviceID, npcID})
end
def.method("number", "number").OnTradeServiceSelected = function(self, iIndex, itemType)
  local selctedInfo = self._Param[iIndex]
  local serviceID = selctedInfo.cfg.serviceID
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  self:HideDlg()
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TRADE, {serviceID, npcID})
end
def.method("number", "number").OnTransferServiceSelected = function(self, iIndex, itemType)
  local selctedInfo = self._Param[iIndex]
  local serviceID = selctedInfo.cfg.serviceID
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  self:HideDlg()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.npc.CNPCTransforService").new(npcID, serviceID))
end
def.method("number", "number").OnStallServiceSelected = function(self, iIndex, itemType)
  local selectedInfo = self._Param[iIndex]
  local serviceID = selectedInfo.cfg.serviceID
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  self:HideDlg()
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TRADE, {serviceID, npcID})
end
def.method("number", "number").OnFightServiceSelected = function(self, iIndex, itemType)
  local selectedInfo = self._Param[iIndex]
  local serviceID = selectedInfo.cfg.serviceID
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  self:HideDlg()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.npc.CNPCFightService").new(npcID, serviceID))
end
def.method("number", "number").OnBuffServiceSelected = function(self, iIndex, itemType)
  local selectedInfo = self._Param[iIndex]
  local serviceID = selectedInfo.cfg.serviceID
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  self:HideDlg()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.npc.CNPCBuffService").new(npcID, serviceID))
end
def.method("number", "number").OnTaskSelected = function(self, iIndex, itemType)
  local selectedTaskInfo = self._Param[iIndex]
  local taskId = selectedTaskInfo.cfg.taskID
  local TaskInterface = require("Main.task.TaskInterface")
  local npcInterface = NPCInterface.Instance()
  local npcID = npcInterface:GetLastInteractiveNPCID()
  if selectedTaskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
  end
  self:HideDlg()
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SELECT_TASK, {
    taskId,
    selectedTaskInfo.graphId
  })
end
def.method("number", "number").OnTaskBattleSelected = function(self, iIndex, itemType)
  local selectedTaskInfo = self._Param[iIndex]
  local taskId = selectedTaskInfo.cfg.taskID
  self:HideDlg()
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SELECT_TASK, {
    taskId,
    selectedTaskInfo.graphId
  })
end
def.method("number", "number").OnMonster = function(self, iIndex, itemType)
  local selectedTaskInfo = self._Param[iIndex]
  local monsterID = selectedTaskInfo.monsterID
  local monsterInstID = selectedTaskInfo.monsterInstID
  local monsterCfg = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetMonsterCfg(monsterID)
  if monsterCfg == nil then
    self:HideDlg()
    return
  end
  local fn = self._lvTypeFn[monsterCfg.enterFightLevelType]
  if fn == nil then
    self:HideDlg()
    return
  end
  local res = fn(monsterCfg, true)
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() == true then
    local members = teamData:GetAllTeamMembers()
    local heroProp = _G.GetHeroProp()
    if members[1] and heroProp.id ~= members[1].roleid then
      Toast(textRes.NPC[25])
      return
    end
  end
  local checkRes = NPCInterface.CheckBattalTeamMemberCount(monsterCfg.enterFightMinRoleNum, monsterCfg.enterFightMaxRoleNum, true)
  if res == false or checkRes == false then
    local panel = self.m_panel:FindDirect("Img_Bg0")
    panel:FindDirect("Img_BgNpcTalk/Label_NpcTalk"):GetComponent("UILabel"):set_text(monsterCfg.canNotAttackOptionTalk)
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CMapMonsterStartFight").new(monsterInstID))
  self:HideDlg()
end
def.method("number", "number").OnCustom = function(self, iIndex, itemType)
  local selectedTaskInfo = self._Param[iIndex]
  if self._customCallback ~= nil then
    local ret = self._customCallback(selectedTaskInfo.itemParam)
    if ret == true then
      self:HideDlg()
    end
    self._customCallback = nil
    return
  end
  self:HideDlg()
end
def.method()._ClearItems = function(self)
  if self:IsShow() == false then
    return
  end
  local panel = self.m_panel:FindDirect("Img_Bg0")
  local Grid_Btn = panel:FindDirect("Scroll View_Btn/Grid_Btn")
  local count = Grid_Btn:get_childCount()
  local grid = Grid_Btn:GetComponent("UIGrid")
  for i = 1, count do
    local btn = Grid_Btn:FindDirect(string.format("Btn_%02d", i))
    btn:SetActive(false)
  end
end
def.method().Clear = function(self)
  self:_ClearItems()
  self._Param = {}
end
def.method("number").SetPortrait = function(self, headidx)
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, headidx)
  if iconRecord == nil then
    print("Icon res get nil record for id: ", headidx)
    return
  end
  local resourceType = iconRecord:GetIntValue("iconType")
  if resourceType == 1 then
    local resourcePath = iconRecord:GetStringValue("path")
    if resourcePath and resourcePath ~= "" then
      self._UIModelWrap:Load(resourcePath .. ".u3dext")
    else
      warn(" resourcePath == \"\" iconId = " .. headidx)
    end
    local Img_NPCPhoto = self.m_panel:FindDirect("Img_Bg0/Img_NPCPhoto")
    Img_NPCPhoto:SetActive(false)
  else
    self._UIModelWrap:Destroy()
    local Img_NPCPhoto = self.m_panel:FindDirect("Img_Bg0/Img_NPCPhoto")
    Img_NPCPhoto:SetActive(true)
    local uiTexture = Img_NPCPhoto:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, headidx)
  end
end
def.method("=>", "table").GetTargetExtraInfo = function(self)
  return self._TargetExtraInfo
end
NpcDlg.Commit()
return NpcDlg

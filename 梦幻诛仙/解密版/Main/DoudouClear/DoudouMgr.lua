local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local DoudouMgr = Lplus.Class(CUR_CLASS_NAME)
local def = DoudouMgr.define
local MathHelper = require("Common.MathHelper")
local Doudou = require("Main.DoudouClear.data.Doudou")
local DouDouClearUtils = require("Main.DoudouClear.DouDouClearUtils")
local ECFxMan = require("Fx.ECFxMan")
local instance
DoudouMgr.PHASE = {
  PREPARE = 1,
  MOVE = 2,
  KILL = 3,
  CLEAR = 4,
  END = 5
}
local EFFECTS
def.field("table").doudouList = nil
def.field("table").doudouMap = nil
def.field("table").pathNodes = nil
def.field("number").phase = DoudouMgr.PHASE.PREPARE
def.field("number").round = 0
def.field("function").onPrepare = nil
def.field("function").onKillEnd = nil
def.field("boolean").isInited = false
def.field("number").score = 0
def.field("table").sampleModels = nil
def.const("number").GEN_NUM_PER_ROUND = constant.CHulaCfgConsts.MONSTER_COUNT_EVERY_TURN
def.static("=>", DoudouMgr).Instance = function()
  if instance == nil then
    instance = DoudouMgr()
    instance:Init()
  end
  if not instance.isInited then
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.doudouList = {}
  self.doudouMap = {}
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_DOUDOU, DoudouMgr.OnTouchDoudou)
  self.pathNodes = DouDouClearUtils.GetAllPos()
  EFFECTS = {}
  EFFECTS[1] = _G.GetEffectRes(constant.CHulaCfgConsts.NORMAL_DELETE_EFFECTID)
  EFFECTS[2] = _G.GetEffectRes(constant.CHulaCfgConsts.DOUBLE_DELETE_EFFECTID)
  EFFECTS[3] = _G.GetEffectRes(constant.CHulaCfgConsts.TRIPLE_DELETE_EFFECTID)
  EFFECTS[4] = _G.GetEffectRes(constant.CHulaCfgConsts.FORTH_DELETE_EFFECTID)
  EFFECTS.spawn = _G.GetEffectRes(constant.CHulaCfgConsts.DOUDOU_COME_OUT_EFFECT)
  EFFECTS.disappear = _G.GetEffectRes(constant.CHulaCfgConsts.DOUDOU_DISAPPEAR_EFFECT)
  self.phase = DoudouMgr.PHASE.PREPARE
  Doudou.ResetInstanceId(1)
  self.isInited = true
  local allcfgs = DouDouClearUtils.GetAllDouDouCfg()
  if allcfgs then
    self.sampleModels = {}
    for k, v in pairs(allcfgs) do
      if self.sampleModels[v.modelId] == nil then
        do
          local modelId = v.modelId
          self.sampleModels[modelId] = GetModelPath(modelId)
          GameUtil.AsyncLoad(self.sampleModels[v.modelId], function(obj)
            if self.sampleModels then
              self.sampleModels[modelId] = obj
            end
          end)
        end
      end
    end
  end
end
def.method().Destroy = function(self)
  if self.doudouMap then
    for k, v in pairs(self.doudouMap) do
      v:Destroy()
    end
  end
  self.doudouList = nil
  self.doudouMap = nil
  self.pathNodes = nil
  self.onPrepare = nil
  self.onKillEnd = nil
  self.round = 0
  self.score = 0
  self.phase = DoudouMgr.PHASE.PREPARE
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_DOUDOU, DoudouMgr.OnTouchDoudou)
  if EFFECTS.spawn.fx then
    ECFxMan.Instance():Stop(EFFECTS.spawn.fx)
  end
  if EFFECTS.disappear.fx then
    ECFxMan.Instance():Stop(EFFECTS.disappear.fx)
  end
  EFFECTS = nil
  self.sampleModels = nil
  DouDouClearUtils.ClearCfgCache()
  self.isInited = false
end
def.method("=>", Doudou, Doudou).GetLastTwo = function(self)
  if self.doudouList == nil then
    return nil, nil
  end
  return self.doudouList[1], self.doudouList[2]
end
def.method().PlayMapEffect = function(self)
  local start_effpos = Map2DPosTo3D(self.pathNodes[1].x + 100, world_height - self.pathNodes[1].y)
  EFFECTS.spawn.fx = ECFxMan.Instance():Play(EFFECTS.spawn.path, start_effpos, Quaternion.identity, -1, false, -1)
  local disappear_effpos = Map2DPosTo3D(self.pathNodes[#self.pathNodes].x, world_height - self.pathNodes[#self.pathNodes].y)
  EFFECTS.disappear.fx = ECFxMan.Instance():Play(EFFECTS.disappear.path, disappear_effpos, Quaternion.identity, -1, false, -1)
end
def.method("number", "number", "table").CreateExistingDoudous = function(self, round, phase, doudouDataList)
  self.round = round
  local HulaActivityPhase = require("netio.protocol.mzm.gsp.hula.HulaActivityPhase")
  if phase == HulaActivityPhase.STAGE_DOUDOU_COMEONT then
    self.phase = DoudouMgr.PHASE.KILL
  elseif phase == HulaActivityPhase.STAGE_DOUDOU_DELETE then
    self.phase = DoudouMgr.PHASE.PREPARE
  end
  local len = #doudouDataList
  local MonsterState = require("netio.protocol.mzm.gsp.hula.MonsterState")
  for k, v in pairs(doudouDataList) do
    if v.state ~= MonsterState.STATE_DIE then
      local doudouCfg = DouDouClearUtils.GetDouDouCfg(v.monsterid)
      if doudouCfg then
        do
          local doudou = Doudou.Create(v.seq, doudouCfg.modelId, doudouCfg.dyeId, doudouCfg.name)
          doudou.cfgId = v.monsterid
          doudou.idx = len - k + 1
          doudou.state = v.state
          local mark = _G.GetStringFromOcts(v.content)
          local curpos = self.pathNodes[doudou.idx]
          doudou.model:AddOnLoadCallback("DoudouSetDir", function()
            local nextpos = self.pathNodes[doudou.idx + 1]
            if nextpos == nil then
              nextpos = self.pathNodes[#self.pathNodes]
            end
            local dir = Map2DPosTo3D(nextpos.x, world_height - nextpos.y) - Map2DPosTo3D(curpos.x, world_height - curpos.y)
            dir:Normalize()
            doudou.model:SetForward(dir)
            if mark then
              doudou:SetMark(mark)
            end
            doudou:SetState(doudou.state)
          end)
          doudou:Load(curpos)
          doudou.isClearable = doudouCfg.canDelete
          self.doudouMap[doudou.instanceId] = doudou
          self.doudouList[doudou.idx] = doudou
        end
      end
    end
  end
end
def.method("number", "table").StartNextRound = function(self, round, doudouList)
  if self.phase ~= DoudouMgr.PHASE.PREPARE then
    function self.onPrepare()
      self:StartNextRound(round, doudouList)
    end
    return
  end
  self.phase = DoudouMgr.PHASE.MOVE
  self.round = round
  local cur_num = #self.doudouList
  local readyCount = cur_num + DoudouMgr.GEN_NUM_PER_ROUND - 1
  local function OnReady(dou)
    if dou.idx >= #self.pathNodes then
      self:RemoveDoudou(dou.instanceId)
      self:SetScore(-constant.CHulaCfgConsts.KILL_POINT, 1)
    end
    readyCount = readyCount - 1
    if readyCount == 0 then
      self.phase = DoudouMgr.PHASE.KILL
    end
  end
  self.doudouList = {}
  for _, dd in pairs(self.doudouMap) do
    local curPos = dd.idx
    local tarPos = dd.idx + DoudouMgr.GEN_NUM_PER_ROUND
    dd.idx = tarPos
    local path = self:GetPathNodes(curPos, tarPos)
    if path then
      dd:RunPath(path, OnReady)
    end
    self.doudouList[dd.idx] = dd
  end
  local timerId = 0
  local count = 0
  local function SpawnDoudou()
    if not self.isInited then
      if timerId > 0 then
        GameUtil.RemoveGlobalTimer(timerId)
      end
      return
    end
    local doudouCfgId = doudouList[count + 1]
    if doudouCfgId then
      local doudouCfg = DouDouClearUtils.GetDouDouCfg(doudouCfgId)
      if doudouCfg then
        local doudou = Doudou.New(doudouCfg.modelId, doudouCfg.dyeId, doudouCfg.name)
        doudou.cfgId = doudouCfgId
        doudou:Load(self.pathNodes[1])
        doudou.idx = DoudouMgr.GEN_NUM_PER_ROUND - count
        doudou.isClearable = doudouCfg.canDelete
        local path = self:GetPathNodes(1, doudou.idx)
        if path then
          doudou:RunPath(path, OnReady)
        end
        self.doudouList[doudou.idx] = doudou
        self.doudouMap[doudou.instanceId] = doudou
      end
      count = count + 1
      if timerId > 0 and count >= DoudouMgr.GEN_NUM_PER_ROUND then
        GameUtil.RemoveGlobalTimer(timerId)
      end
    end
  end
  timerId = GameUtil.AddGlobalTimer(0.5, false, SpawnDoudou)
  Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.ROUND_START, {
    round = self.round
  })
end
def.method("number", "number", "=>", "table").GetPathNodes = function(self, from, to)
  if self.pathNodes == nil then
    return nil
  end
  if from == to then
    return nil
  end
  local path = {}
  local len = #self.pathNodes
  from = MathHelper.Clamp(from, 1, len)
  to = MathHelper.Clamp(to, 1, len)
  local flag = 1
  if from > to then
    flag = -1
  end
  for i = from, to, flag do
    table.insert(path, self.pathNodes[i])
  end
  return path
end
def.static("table", "table").OnTouchDoudou = function(p1, p2)
  local id = p1 and p1[1]
  if id == nil or instance.doudouMap == nil then
    return
  end
  local doudou = instance.doudouMap[id]
  if doudou == nil then
    return
  end
  instance:ShowTalkDlg(doudou.instanceId, doudou.cfgId)
end
def.method("=>", "table").GetClearResult = function(self)
  if self.doudouList == nil then
    return nil
  end
  local curIdx = 1
  local endIdx = #self.doudouList
  if curIdx >= endIdx then
    return nil
  end
  local result
  while curIdx < endIdx do
    local count = 1
    local color = self.doudouList[curIdx].color
    local modelId = self.doudouList[curIdx].modelId
    local from = curIdx
    for idx = curIdx + 1, endIdx do
      if self.doudouList[idx].isClearable and self.doudouList[idx].color == color and self.doudouList[idx].modelId == modelId then
        count = count + 1
        curIdx = idx
      else
        curIdx = idx
        break
      end
    end
    if count > 2 then
      if result == nil then
        result = {}
      end
      if result[count] == nil then
        result[count] = {}
      end
      local set = result[count]
      local count_ret = {}
      count_ret.from = from
      count_ret.to = from + count - 1
      table.insert(set, count_ret)
    end
  end
  return result
end
def.method("number").CheckReadyToClear = function(self, round)
  if round == self.round then
    self:StartClear()
  end
end
def.method().StartClear = function(self)
  Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.CLEAR_BEGIN, {
    round = self.round
  })
  self.phase = DoudouMgr.PHASE.CLEAR
  self:AdjustList(function()
    local allRoles = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE).rolesMap
    local actionMgr = require("Main.Chat.ui.DlgAction").Instance()
    local ActionType = require("consts.mzm.gsp.map.confbean.ExpressionActionType")
    for k, v in pairs(allRoles) do
      actionMgr:PlayRoleAction(v, ActionType.HYUN_DANCE)
    end
    self:Clear()
  end)
end
def.method("number", "number").SetDoudouState = function(self, id, state)
  local doudou = self.doudouMap[id]
  if doudou then
    local MonsterState = require("netio.protocol.mzm.gsp.hula.MonsterState")
    if state == MonsterState.STATE_DIE then
      self.doudouList[doudou.idx] = nil
      self.doudouMap[doudou.instanceId] = nil
      self:SetScore(constant.CHulaCfgConsts.KILL_POINT, 1)
    end
    doudou:SetState(state)
  end
end
def.method("number").RemoveDoudou = function(self, id)
  local doudou = self.doudouMap[id]
  if doudou then
    self.doudouList[doudou.idx] = nil
    doudou:Destroy()
  end
  self.doudouMap[id] = nil
end
def.method().Clear = function(self)
  local round = 0
  local function DoClear()
    if not self.isInited then
      return
    end
    local result = self:GetClearResult()
    if result ~= nil then
      round = round + 1
      do
        local delList = {}
        for k, v in pairs(result) do
          for i = 1, #v do
            for j = v[i].from, v[i].to do
              self.doudouList[j]:PlayEffect(EFFECTS[round] and EFFECTS[round].path or EFFECTS[4].path)
              delList[j] = self.doudouList[j]
            end
          end
        end
        GameUtil.AddGlobalTimer(0.5, true, function()
          if not self.isInited then
            return
          end
          local times = round
          if times > 3 then
            times = 3
          end
          local count = 0
          for idx, dd in pairs(delList) do
            self.doudouMap[self.doudouList[idx].instanceId] = nil
            self.doudouList[idx]:Destroy()
            self.doudouList[idx] = nil
            count = count + 1
          end
          local delta = count * times * constant.CHulaCfgConsts.KILL_POINT
          self:SetScore(delta, times)
          self:AdjustList(DoClear)
        end)
      end
    else
      Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.CLEAR_END, {
        round = self.round
      })
      self.phase = DoudouMgr.PHASE.PREPARE
      if self.onPrepare then
        local func = self.onPrepare
        self.onPrepare = nil
        func()
      end
    end
  end
  DoClear()
end
def.method("number", "number").SetScore = function(self, delta, times)
  self.score = self.score + delta
  Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.SCORE_UPDATE, {
    score = self.score,
    delta = delta,
    times = times
  })
end
def.method().ResortDoudouList = function(self)
  if self.doudouList == nil then
    return
  end
  local result = {}
  for k, d in pairs(self.doudouList) do
    if not d:IsDestroy() then
      d.last_idx = k
      table.insert(result, d)
    end
  end
  table.sort(result, function(a, b)
    return a.instanceId > b.instanceId
  end)
  self.doudouList = result
end
def.method("function").AdjustList = function(self, cb)
  if self.doudouList == nil then
    return
  end
  self:ResortDoudouList()
  local len = #self.doudouList
  local adjustNum = 0
  for k, doudou in pairs(self.doudouList) do
    doudou.idx = k
    do
      local path = self:GetPathNodes(doudou.last_idx, k)
      if path then
        adjustNum = adjustNum + 1
        doudou:RunPath(path, function()
          doudou:TurnRound()
          adjustNum = adjustNum - 1
          if adjustNum <= 0 then
            GameUtil.AddGlobalTimer(1, true, cb)
          end
        end)
      else
        warn("path is nil")
      end
    end
  end
  if adjustNum == 0 and cb then
    cb()
  end
end
def.method("=>", "number", "number", "number").GetCurrentState = function(self)
  local score = 0
  return self.round, self.phase, score
end
def.method("number", "number").ShowTalkDlg = function(self, instanceId, cfgId)
  local dlg = require("Main.npc.ui.NPCDlg").Instance()
  dlg:Clear()
  dlg:AddItem(textRes.Hula[11], {1}, false)
  dlg:AddItem(textRes.Hula[12], {2}, false)
  dlg:AddItem(textRes.Hula[19], {3}, false)
  dlg:AddItem(textRes.Hula[13], nil, false)
  dlg:SetCustomCallback(function(param)
    if param == nil then
    elseif param[1] == 1 then
      self:FightDouDou(instanceId)
    elseif param[1] == 2 then
      require("Main.DoudouClear.ui.DouDouTagDlg").ShowDouDouTagDlg(function(str)
        if str ~= "" then
          self:TagDouDou(instanceId, str)
        end
      end)
    elseif param[1] == 3 then
      self:TagDouDou(instanceId, "")
    end
    return true
  end)
  local doudouCfg = DouDouClearUtils.GetDouDouCfg(cfgId)
  if doudouCfg then
    dlg:SetHeadID(doudouCfg.headIcon, doudouCfg.name, doudouCfg.talk)
  end
  dlg:ShowDlg()
end
def.method("number").FightDouDou = function(self, instanceId)
  if self.phase == DoudouMgr.PHASE.END then
    Toast(textRes.Hula[101])
    return
  elseif self.phase ~= DoudouMgr.PHASE.KILL then
    Toast(textRes.Hula[100])
    return
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasTeam() and not teamData.Instance():MeIsCaptain() and teamData.Instance():GetStatus() ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
    Toast(textRes.Hula[9])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.hula.CStartFightReq").new(instanceId))
end
def.method("number", "string").TagDouDou = function(self, instanceId, tag)
  local tagOcts = require("netio.Octets").rawFromString(tag)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.hula.CMarkMonsterReq").new(instanceId, tagOcts))
end
def.method("number", "string").STagDouDou = function(self, instanceId, tag)
  if self.doudouMap == nil then
    return
  end
  local doudou = self.doudouMap[instanceId]
  if doudou == nil then
    return
  end
  doudou:SetMark(tag)
end
DoudouMgr.Commit()
return DoudouMgr

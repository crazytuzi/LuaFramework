local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SkillPlayHelper = Lplus.Class(MODULE_NAME)
local ECModel = require("Model.ECModel")
local MovePlayType = require("consts.mzm.gsp.skill.confbean.MovePlayType")
local EffectPosType = require("consts.mzm.gsp.skill.confbean.EffectPosType")
local AttachType = require("consts.mzm.gsp.skill.confbean.EffectGuaDian")
local FightUtils = require("Main.Fight.FightUtils")
local fightMgr = require("Main.Fight.FightMgr").Instance()
local Vector = require("Types.Vector")
local ECFxMan = require("Fx.ECFxMan")
local SkillSpecialAct = require("consts.mzm.gsp.skill.confbean.SkillSpecialAct")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = SkillPlayHelper.define
local instance
def.static("=>", SkillPlayHelper).Instance = function()
  if instance == nil then
    instance = SkillPlayHelper()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.static(ECModel, "number", "table", "function").PlaySkillInUIModel = function(model, skillId, params, onPlayEnd)
  if model == nil then
    return
  end
  if model.m_model == nil or model.m_model.isnil then
    return
  end
  local params = params or {}
  local gender = params.gender
  local modelId = model.mModelId
  local skillcfg = fightMgr:GetSkillCfg(skillId)
  if skillcfg == nil then
    print(string.format("no such active skill(%d)", skillId))
    return
  end
  local defaultActionName = ActionName.Stand
  local playcfg = FightUtils.GetSkillPlayCfg(skillcfg.skillPlayid)
  local actionCfg, actionPhaseCfg
  local actionSeqs = {}
  for i, v in ipairs(playcfg.phases) do
    local phaseId = v[1]
    if phaseId > 0 then
      local movePhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phaseId)
      if movePhaseCfg then
        local moveAction = FightUtils.GetMoveActionCfg(movePhaseCfg.action)
        if moveAction and moveAction.modelDisPlay == MovePlayType.DISAPPEAR_SLOWLY or moveAction.modelDisPlay == MovePlayType.APPEAR_SLOWLY then
          table.insert(actionSeqs, {moveAction = moveAction, movePhaseCfg = movePhaseCfg})
        end
      end
    end
    local phaseId = v[2]
    if phaseId > 0 then
      actionPhaseCfg = FightUtils.GetSkillPlayPhaseCfg(phaseId)
      if actionPhaseCfg then
        actionCfg = FightUtils.GetSkillActionCfg(modelId, actionPhaseCfg.action)
        table.insert(actionSeqs, {actionCfg = actionCfg, actionPhaseCfg = actionPhaseCfg})
      end
    end
  end
  local AddChildEffect = SkillPlayHelper.AddChildEffect
  local function PlayEffectOnFront(ecmodel, effectPath)
    SkillPlayHelper.PlayEffectOnFront(ecmodel, effectPath, 2)
  end
  local function PlayEffectToFront(ecmodel, effectPath, attachPoint, duration)
    SkillPlayHelper.PlayEffectToFront(ecmodel, effectPath, attachPoint, duration, 16)
  end
  local totalAction = 0
  for i, v in ipairs(actionSeqs) do
    if v.actionPhaseCfg and v.actionCfg then
      totalAction = totalAction + 1
    end
  end
  local actionCount = 0
  local await = false
  local co = coroutine.create(function(co)
    for i, v in ipairs(actionSeqs) do
      if v.movePhaseCfg then
        if v.moveAction then
          local actionName = v.moveAction.actionName
          model:CrossFade(actionName, 0)
          local startTime = GameUtil.GetTickCount()
          local curTime = startTime
          if v.moveAction.modelDisPlay == MovePlayType.DISAPPEAR_SLOWLY then
            local delta = math.abs(curTime - startTime) / 1000
            while delta < v.moveAction.duration do
              model:CloseAlpha()
              model:SetAlpha(1 - delta / v.moveAction.duration)
              coroutine.yield(0)
              curTime = GameUtil.GetTickCount()
              delta = math.abs(curTime - startTime) / 1000
            end
            model:CloseAlpha()
            model:SetAlpha(0)
          elseif v.moveAction.modelDisPlay == MovePlayType.APPEAR_SLOWLY then
            local delta = math.abs(curTime - startTime) / 1000
            while delta < v.moveAction.duration do
              model:CloseAlpha()
              model:SetAlpha(delta / v.moveAction.duration)
              coroutine.yield(0)
              curTime = GameUtil.GetTickCount()
              delta = math.abs(curTime - startTime) / 1000
            end
            model:CloseAlpha()
            model:SetAlpha(1)
          end
        end
      elseif v.actionPhaseCfg then
        local actionPhaseCfg = v.actionPhaseCfg
        local actionCfg = FightUtils.GetSkillActionCfg(modelId, actionPhaseCfg.action)
        local aniDuration
        if actionCfg then
          local actionName = actionCfg.actionName
          model:CrossFade(actionName, 0)
          actionCount = actionCount + 1
          if actionCount == totalAction then
            model:CrossFadeQueued(defaultActionName, 0.15)
          end
          aniDuration = model:GetAniDuration(actionName)
        end
        if actionPhaseCfg.specialAct and 0 < actionPhaseCfg.specialAct and actionPhaseCfg.specialAct == SkillSpecialAct.CHANGE_MODEL then
          await = true
          GameUtil.AddGlobalTimer(actionPhaseCfg.specialActTime, true, function()
            if model:IsDestroyed() then
              return
            end
            local changeModelCfg = SkillUtility.GetSkillChangeModelCfgByPlayId(playcfg.id, gender)
            if changeModelCfg == nil then
              await = false
              return
            end
            local newModelId = changeModelCfg.modelId
            if params.onChangeModel then
              params.onChangeModel(newModelId, function(newModel, exParams)
                modelId = newModelId
                model = newModel
                if exParams.defaultActionName then
                  defaultActionName = exParams.defaultActionName
                end
                await = false
                coroutine.resume(co, co)
              end)
            else
              await = false
            end
          end)
        end
        local attackEffectDuration = 0
        for i, effect in ipairs(actionPhaseCfg.effects or {}) do
          local effPlay = FightUtils.GetEffectPlayCfg(modelId, effect.effectId)
          local attackEffectId = effPlay.attackEffectId
          attackEffectDuration = effPlay.duration
          if gender == _G.GenderEnum.FEMALE and 0 < effPlay.femaleAttackEffectId then
            attackEffectId = effPlay.femaleAttackEffectId
          end
          if attackEffectId > 0 then
            local effres = GetEffectRes(attackEffectId)
            effres.delay = 0 <= effect.delay and effect.delay or actionCfg.effectDelays[i]
            effres.posType = effPlay.effectPosType
            effres.posDest = effPlay.effectPosDest
            effres.duration = effPlay.duration
            coroutine.yield(effres.delay, false)
            if effres.posType == EffectPosType.TARGET then
              PlayEffectOnFront(model, effres.path)
            elseif effres.posType == EffectPosType.RELESER then
              if effres.posDest == EffectPosType.RELESER then
                AddChildEffect(model, effres.path, effPlay.attachPoint)
              else
                PlayEffectToFront(model, effres.path, effPlay.attachPoint, effres.duration)
              end
            elseif effres.posType == EffectPosType.FRIEND_D then
              AddChildEffect(model, effres.path, effPlay.attachPoint)
            else
              PlayEffectOnFront(model, effres.path)
            end
            if 0 < effres.sound then
              fightMgr:PlaySoundEffect(effres.sound)
            end
          end
        end
        coroutine.yield(attackEffectDuration, false)
        if await then
          coroutine.yield(-1)
        end
      end
    end
  end)
  local function runActionSeq(delay, zeroDelay)
    delay = delay or 0
    zeroDelay = zeroDelay or true
    local function runActionSeqInner()
      if model:IsDestroyed() then
        return
      end
      if coroutine.status(co) ~= "dead" then
        local ret = {
          coroutine.resume(co, co)
        }
        if ret[1] then
          local delay = ret[2]
          local zeroDelay = ret[3]
          if delay ~= -1 then
            runActionSeq(delay, zeroDelay)
          end
        else
          local traceback = debug.traceback(co)
          warn(string.format([[
[Error] %s
%s]], ret[2], traceback))
        end
      else
        model:CrossFadeQueued(defaultActionName, 0.15)
        if onPlayEnd then
          onPlayEnd()
        end
      end
    end
    if delay > 0 or delay == 0 and zeroDelay then
      GameUtil.AddGlobalTimer(delay, true, function()
        runActionSeqInner()
      end)
    else
      runActionSeqInner()
    end
  end
  runActionSeq(0, false)
end
def.static(ECModel, "string", "number").AddChildEffect = function(ecmodel, effectPath, attachPoint)
  local model = ecmodel.m_model
  local pos = Vector.Vector3.new(0, 0, 0)
  local fx = ECFxMan.Instance():PlayAsChild(effectPath, model, pos, Quaternion.identity, -1, false, -1)
  if fx == nil then
    warn("can not request effect: " .. effectPath)
    return
  end
  fx:SetLayer(ClientDef_Layer.UI_Model1)
end
def.static(ECModel, "string", "number").PlayEffectOnFront = function(ecmodel, effectPath, distance)
  local model = ecmodel.m_model
  local pos = model.position
  local rot = model.rotation
  local angle = rot:get_eulerAngles()
  local halfpi = math.pi / 2
  local dx = distance * math.sin(halfpi * angle.y / 90)
  local dz = distance * math.cos(halfpi * angle.y / 90)
  local dest = {}
  dest.x = pos.x + dx
  dest.y = pos.y
  dest.z = pos.z + dz
  local localPos = Vector.Vector3.new(0, 0, distance)
  local fx = ECFxMan.Instance():PlayAsChild(effectPath, model, localPos, Quaternion.identity, -1, false, -1)
  if fx == nil then
    warn("can not request effect: " .. effectPath)
    return
  end
  fx:SetLayer(ClientDef_Layer.UI_Model1)
  ecmodel:ConnectToGO(fx)
end
def.static(ECModel, "string", "number", "number", "number").PlayEffectToFront = function(ecmodel, effectPath, attachPoint, duration, distance)
  local model = ecmodel.m_model
  if model == nil then
    return
  end
  local fx = GameUtil.RequestFx(effectPath, 1)
  if fx == nil then
    warn("can not request effect: " .. effectPath)
    return
  end
  fx:SetLayer(ClientDef_Layer.UI_Model1)
  local pelvis_root = model:FindDirect("Root/Bip01 Pelvis")
  if pelvis_root == nil then
    pelvis_root = model
  end
  local pelvis_pos = pelvis_root.position
  local pos = model.position
  local offsetY = 0
  if attachPoint == AttachType.FOOT then
    offsetY = -ecmodel:GetBoxHeight() / 2
  elseif attachPoint == AttachType.HEAD then
    offsetY = ecmodel:GetBoxHeight() / 2
  end
  local rot = model.rotation
  local angle = rot:get_eulerAngles()
  local halfpi = math.pi / 2
  local dx = distance * math.sin(halfpi * angle.y / 90)
  local dz = distance * math.cos(halfpi * angle.y / 90)
  local dest = Vector.Vector3.new(pos.x + dx, pos.y, pos.z + dz)
  local speed = distance / duration
  local go, fly
  local flyroot = ECFxMan.Instance().mFlyUnusedRoot
  if 0 < flyroot.childCount then
    go = flyroot:GetChild(0)
    go:SetActive(true)
    fly = go:GetComponent("LinearMotor")
  else
    go = GameObject.GameObject("fly")
    fly = go:AddComponent("LinearMotor")
  end
  go.parent = ECFxMan.Instance().mFlyRoot
  go.position = pelvis_pos
  go.localRotation = Quaternion.identity
  go.localScale = Vector.Vector3.one
  fx.parent = go
  fx.localPosition = Vector.Vector3.zero
  fx.localRotation = Quaternion.identity
  fx.localScale = Vector.Vector3.one
  local fxone = fx:GetComponent("FxOne")
  fxone:Play2(duration, true)
  local tolerance = 0.2
  fly:Fly(pelvis_pos, dest, speed, duration, tolerance, function(go, timeout)
    go.parent = flyroot
    go:SetActive(false)
    local fxone = fx:GetComponent("FxOne")
    if fxone then
      fxone:Stop()
    end
  end)
end
return SkillPlayHelper.Commit()

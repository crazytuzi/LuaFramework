--
-- Author: Zippo
-- Date: 2013-12-05 18:13:41
--
local fightRoleMgr = require("lua.logic.fight.FightRoleManager")

local FightRoundManager = class("FightRoundManager")

function FightRoundManager:ctor()
	self.nCurrRoundIndex = 0
	self.endActionCount = 0
	self.currAction = nil
	self.bOverTime = false
	self.permanentBufList = {}
	self.actionList = TFArray:new()
end

function FightRoundManager:dispose()
	TFDirector:removeTimer(self.updateTimerID)
	if self.currAction ~= nil then
		self.currAction:dispose()
		self.currAction = nil
	end
	self.nCurrRoundIndex = 0
	self.endActionCount = 0
	self.permanentBufList= {}
end

function FightRoundManager:ExecuteFirstRound()
	self.nCurrRoundIndex = 1
	self.bOverTime = false
	
	fightRoleMgr:OnRoundStart()

	fightRoleMgr:OnAddPermanentBuf()

	if self:ExecuteManualAction() then
		return
	end

	self:ExecuteNewAction()
end

function FightRoundManager:ExecuteNewRound()
	self.nCurrRoundIndex = self.nCurrRoundIndex + 1

	if self.nCurrRoundIndex > FightManager.maxRoundNum then
		self.bOverTime = true
		TFDirector:currentScene().fightUiLayer:PlayOverTimeEffect()
		return
	end

	TFDirector:currentScene().fightUiLayer:SetCurrRoundNum(self.nCurrRoundIndex)

	fightRoleMgr:OnRoundStart()
	self:ExecuteNewAction()
end

function FightRoundManager:ExecuteNewAction()
	fightRoleMgr:OnAddPermanentBuf()
	local attackRole = fightRoleMgr:GetNormalAttackRole()
	if attackRole == nil then
		print("ExecuteNewAction attackRole == nil")
		return
	end
	
	attackRole.haveAttack = true

	local newAction = {}
	newAction.bManualAction = false
	newAction.unExecute = true
	newAction.roundIndex = self.nCurrRoundIndex
	newAction.attackerpos = attackRole.logicInfo.posindex
	newAction.skillid = attackRole:GetNormalSkill()
	if FightManager.fightBeginInfo.bSkillShowFight then
		newAction.skillid = attackRole.skillID
	end

	newAction.targetlist = self:GetActionTargetInfo(attackRole, newAction.skillid)
	if newAction.targetlist == nil or #newAction.targetlist == 0 then
		local targetEnemy = not attackRole.logicInfo.bEnemyRole
		if fightRoleMgr:CleanFrozenBuffRole(targetEnemy) then
			newAction.targetlist = self:GetActionTargetInfo(attackRole, newAction.skillid)
		end

		if newAction.targetlist == nil or #newAction.targetlist == 0 then
			print("newAction.targetlist == nil")
			if fightRoleMgr:IsEnemyAllDie() then
				FightManager:EndFight(true)
			elseif fightRoleMgr:IsSelfAllDie() then
				FightManager:EndFight(false)
			end
			return
		end
	end

	self.actionList:pushBack(newAction)

	self:ExecuteAction(newAction)
end

function FightRoundManager:ExecuteAction(actionInfo)
	if actionInfo.bManualAction then
		fightRoleMgr:OnExecuteManualAction(actionInfo)
	end

	self:ChangeActionTarget(actionInfo)
	self:ChangeDefianceTarget(actionInfo)

	actionInfo.unExecute = false
	self.currAction = require("lua.logic.fight.FightAction"):new(actionInfo)

	if #self.permanentBufList > 0 then
		for i=1,#self.permanentBufList do
			if self.permanentBufList[i] then
				self.currAction:AddBuffInBeginToServer(self.permanentBufList[i])
			end
		end
		self.permanentBufList = {}
	end
	self.currAction:Execute()
end

function FightRoundManager:ExecuteManualAction()
	fightRoleMgr:OnAddPermanentBuf()
	local manualAction = self:GetManualAction()
	if manualAction ~= nil then
		local role = fightRoleMgr:GetRoleByGirdIndex(manualAction.attackerpos)
		manualAction.targetlist = self:GetActionTargetInfo(role, manualAction.skillid)

		if manualAction.targetlist == nil or #manualAction.targetlist == 0 then
			local targetEnemy = not role.logicInfo.bEnemyRole
			if fightRoleMgr:CleanFrozenBuffRole(targetEnemy) then
				manualAction.targetlist = self:GetActionTargetInfo(role, manualAction.skillid)
			end
		end

		if manualAction.targetlist ~= nil and #manualAction.targetlist > 0 then
			self:ExecuteAction(manualAction)
			return true
		else
			print("manualAction targetlist not find target" .. manualAction.skillid)
			self:RemoveManualAction(manualAction.attackerpos)
		end
	end

	return false
end

function FightRoundManager:OnActionEnd()
	TFDirector:currentScene().mapLayer:ChangeDark(false)

	if self.currAction ~= nil and self.currAction.bBackAttack ~= true then
		fightRoleMgr:OnActionEnd(self.currAction)
	end

	if FightManager.fightBeginInfo.bSkillShowFight then
		TFDirector:currentScene().fightUiLayer:OnSkillShowEnd()
		return
	end
	
	local endActionInfo = nil

	if self.currAction ~= nil then
		endActionInfo = self.currAction.actionInfo
		self.currAction:dispose()
		self.currAction = nil
	end

	if fightRoleMgr:IsEnemyAllDie() then
		FightManager:EndFight(true)
		return
	elseif fightRoleMgr:IsSelfAllDie() then
		FightManager:EndFight(false)
		return
	end
	if self:HaveBackAttackAction() then
		self:ExecuteBackAttackAction(endActionInfo)
		return
	end

	if FightManager.fightBeginInfo.bGuideFight then
		self.endActionCount = self.endActionCount or 0
		self.endActionCount = self.endActionCount + 1

		local fightGuideInfo = PlayerGuideManager:GetGuideFightInfo()
		for i=1,#fightGuideInfo.skill do
			local stepInfo = PlayerGuideStepData:objectByID(10000)
			local skillInfo = fightGuideInfo.skill[i]
			if skillInfo[2] == self.endActionCount then
				local beginTextShowEndCallBack = function(event)
					if FightManager.isFighting then
						stepInfo.widget_name = "roleskill"..skillInfo[1] .."|roleicon"
						print("stepInfo.widget_name = ",stepInfo.widget_name)
						PlayerGuideManager:showGuideLayerByStepId(10000)
						TFDirector:currentScene().fightUiLayer:SetGuideRoleSkillEnable(skillInfo[1])
					end
					
	       	 		TFDirector:removeMEGlobalListener("MissionTipLayer.EVENT_SHOW_BEGINTIP_COM")
	    		end
	    		TFDirector:addMEGlobalListener("MissionTipLayer.EVENT_SHOW_BEGINTIP_COM",  beginTextShowEndCallBack)
				MissionManager:showBeginTipForMission(skillInfo[3])
				return
			end
		end
	end

	-- if PlayerGuideManager:NextGuideIsSkill() then
	-- 	PlayerGuideManager:ShowNextGuideStep()
	-- 	return
	-- end

	if self:ExecuteManualAction() then
		return
	end

	local attackRole = fightRoleMgr:GetNormalAttackRole()
	if attackRole == nil then
		self:ExecuteNewRound()
	else
		self:ExecuteNewAction()
	end
end

--混乱目标转换
function FightRoundManager:ChangeActionTarget(actionInfo)
	local attackRole = fightRoleMgr:GetRoleByGirdIndex(actionInfo.attackerpos)
	if attackRole == nil or attackRole:IsLive() == false then
		return
	end

	if attackRole:GetBuffByType(33)then
		return
	end

	if attackRole:GetBuffByType(10) == nil then
		return
	end

	actionInfo.skillid.skillId = 0
	actionInfo.skillid.level = 0
	
	local targetRole = fightRoleMgr:GetCharmActionTarget(attackRole)
	if targetRole == nil then
		return
	end

	local frozenBuff = targetRole:GetBuffByType(14)
	if frozenBuff ~= nil then
		targetRole:RemoveFrozenBuff()
	end

	local targetList = {targetRole}
	actionInfo.targetlist = self:CaculateTargetHurt(attackRole, 0, targetList)
end

--挑衅buff目标转换
function FightRoundManager:ChangeDefianceTarget(actionInfo)
	local attackRole = fightRoleMgr:GetRoleByGirdIndex(actionInfo.attackerpos)
	if attackRole == nil or attackRole:IsLive() == false then
		return
	end
	
	if attackRole:GetBuffByType(33)then
		return
	end
	if attackRole:GetBuffByType(18) == nil then
		return
	end

	local targetRole = fightRoleMgr:GetDefianceTarget(attackRole)
	if targetRole == nil then
		attackRole:RemoveBuffByType(18)
		return
	end

	local targetList = {targetRole}
	actionInfo.targetlist = self:CaculateTargetHurt(attackRole, actionInfo.skillid, targetList)
end

function FightRoundManager:GetActionTargetInfo(attackRole, skillID)
	local targetList = {}
	local buSiBuXiu = attackRole:GetBuffByType(33)
	if buSiBuXiu then
		print("==================不死不休====================")
		local attackIsEnemy = attackRole.logicInfo.bEnemyRole
		local targetIsEnemy = not attackIsEnemy
		targetList = fightRoleMgr:GetBuffTarget(buSiBuXiu,targetIsEnemy)
		if #targetList > 0 then
			return self:CaculateTargetHurt(attackRole, skillID, targetList)
		end

	end
	if skillID.skillId == 0 then --普通技能打单体	
		targetList = fightRoleMgr:GetSingleTarget(attackRole)
	else
		local skillInfo = SkillLevelData:objectByID(skillID)
		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
		if skillInfo == nil or skillBaseInfo == nil then
			print("skill not find：" ,skillID)
		end

		local targetType = skillBaseInfo.target_type
		local targetNum = skillInfo.target_num
		if targetNum == nil or targetNum == 0 then
			targetNum = 1
		end

		local attackIsEnemy = attackRole.logicInfo.bEnemyRole
		local targetIsEnemy = not attackIsEnemy
		if skillInfo == nil or targetType == 1 then -- 单体技能
			targetList = fightRoleMgr:GetSingleTarget(attackRole)
		elseif targetType == 2 then -- 全屏技能
			targetList = fightRoleMgr:GetScreenTarget(targetIsEnemy)
		elseif targetType == 3 then -- 横排贯穿技能
			targetList = fightRoleMgr:GetRowTarget(attackRole)
		elseif targetType == 4 then -- 竖排穿刺技能
			targetList = fightRoleMgr:GetColumnTarget(attackRole)
		elseif targetType == 5 then -- 敌方随机
			targetList = fightRoleMgr:GetRandomTarget(targetIsEnemy, targetNum)
		elseif targetType == 6 then -- 敌方血最少
			targetList = fightRoleMgr:GetTargetByAttr(1, targetIsEnemy, false, targetNum)
		elseif targetType == 7 then -- 敌方防最少
			targetList = fightRoleMgr:GetTargetByAttr(3, targetIsEnemy, false, targetNum)
		elseif targetType == 8 then -- 我方随机
			targetList = fightRoleMgr:GetRandomTarget(attackIsEnemy, targetNum)
		elseif targetType == 9 then -- 我方血最少
			targetList = fightRoleMgr:GetTargetByAttr(1, attackIsEnemy, false, targetNum)
		elseif targetType == 10 then -- 我方全体
			targetList = fightRoleMgr:GetScreenTarget(attackIsEnemy)
		elseif targetType == 11 then -- 自己
			targetList = {attackRole}
		elseif targetType == 12 then -- 敌方防最高
			targetList = fightRoleMgr:GetTargetByAttr(3, targetIsEnemy, true, targetNum)
		else
			assert(false, skillID.."targetType error")
		end
	end

	if not targetList then
		return nil
	end

	if #targetList > 0 then
		return self:CaculateTargetHurt(attackRole, skillID, targetList)
	end
end

function FightRoundManager:CaculateTargetHurt(attackRole, skillID, targetList)
	local targetInfo = {}
	local targetNum = #targetList
	local bHaveTrigger = false
	if type(skillID) == "number" then
		skillID = { skillId = skillID,level = 0}
	end
	
	for i=1,targetNum do
		targetInfo[i] = {}
		local targetRole = targetList[i]
		targetInfo[i].targetpos = targetRole.logicInfo.posindex
		targetInfo[i].effect = self:CaculateHurtEffect(attackRole, skillID, targetRole)
		if targetInfo[i].effect == 3 then
			targetInfo[i].hurt = 0
		elseif targetInfo[i].effect == 6 then --斗转星移
			targetInfo[i].hurt = self:CaculateHurtNum(attackRole, skillID, targetRole, targetInfo[i].effect)
			targetInfo[i].hurt = -(targetInfo[i].hurt)
		elseif targetInfo[i].effect == 7 then --主动加buff
			targetInfo[i].hurt = 0
			--触发buffer
			local bufferID , bufferLevel = attackRole:GetTriggerBufferID(skillID, targetRole)
			if bufferID > 0 and SkillBufferData:objectByID(bufferID,bufferLevel) == nil then
				-- print("skill:"..skillID.."--------->buff_id:"..bufferID.."not find in SkillBufferData")
				bufferID = 0
				bufferLevel = 0
			end
			targetInfo[i].triggerBufferID = bufferID
			targetInfo[i].triggerBufferLevel = bufferLevel
		else
			local bHurtSkill = false
			if targetInfo[i].effect == 1 or targetInfo[i].effect == 2 then
				bHurtSkill = true
			end

			targetInfo[i].hurt = self:CaculateHurtNum(attackRole, skillID, targetRole, targetInfo[i].effect)

			if bHurtSkill then
				local frontRoleNum = fightRoleMgr:GetFrontRoleNum(targetRole, targetList)
				local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
				local decay = 1
				if skillBaseInfo ~= nil and skillBaseInfo.target_type == 2 then
					if frontRoleNum == 1 then
						decay = ConstantData:getValue("hurt.decay.screen.one") / 100
					elseif frontRoleNum == 2 then
						decay = ConstantData:getValue("hurt.decay.screen.two") / 100
					end
				elseif skillBaseInfo ~= nil and skillBaseInfo.target_type == 3 then
					if frontRoleNum == 1 then
						decay = ConstantData:getValue("hurt.decay.row.one") / 100
					elseif frontRoleNum == 2 then
						decay = ConstantData:getValue("hurt.decay.row.two") / 100
					end
				end
				targetInfo[i].hurt = targetInfo[i].hurt * decay
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
				targetInfo[i].hurt = math.max(10, targetInfo[i].hurt)
				if decay ~= 1 then
					print(attackRole.logicInfo.name.."技能攻击"..targetRole.logicInfo.name..",伤害衰减系数："..decay..",衰减到："..targetInfo[i].hurt)
				end

				targetInfo[i].hurt = -(targetInfo[i].hurt)
			end

			--触发buffer
			local bufferID , bufferLevel = attackRole:GetTriggerBufferID(skillID, targetRole)
			if bufferID > 0 and SkillBufferData:objectByID(bufferID,bufferLevel) == nil then
				-- print("skill:",skillID,"--------->buff_id:"..bufferID.."not find in SkillBufferData")
				bufferID = 0
				bufferLevel = 0
			end
			targetInfo[i].triggerBufferID = bufferID
			targetInfo[i].triggerBufferLevel = bufferLevel

			local effectValue = {}
			local temp_activeEffect = attackRole:TriggerBuffHurt(targetRole, skillID, effectValue)
			
			--加深效果跟activeEffect不冲突
			if temp_activeEffect and temp_activeEffect ~= 0 then
				-- targetInfo[i].activeEffect = temp_activeEffect + 100
				targetInfo[i].deepHurtType = temp_activeEffect
				targetInfo[i].hurt = targetInfo[i].hurt * (100+effectValue.value) / 100
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
				print("加深效果触发:",effectValue,targetInfo)
			end

			--是否触发主动效果:吸怒1 减敌怒2 增己怒3 吸血4 侧击8 净化10 致死11 重击14 七伤拳21
			if bHaveTrigger == false and attackRole:TriggerActiveEffect(skillID, 1, effectValue) then
				targetInfo[i].activeEffect = 1
				targetInfo[i].activeEffectValue = effectValue.value
				bHaveTrigger = true
			elseif bHaveTrigger == false and attackRole:TriggerActiveEffect(skillID, 2, effectValue) then
				targetInfo[i].activeEffect = 2
				targetInfo[i].activeEffectValue = effectValue.value
				bHaveTrigger = true
			elseif bHaveTrigger == false and attackRole:TriggerActiveEffect(skillID, 3, effectValue) then
				targetInfo[i].activeEffect = 3
				targetInfo[i].activeEffectValue = effectValue.value
				bHaveTrigger = true
			elseif bHurtSkill and attackRole:TriggerActiveEffect(skillID, 4, effectValue) then
				targetInfo[i].activeEffect = 4
				targetInfo[i].activeEffectValue = targetInfo[i].hurt * effectValue.value / 100
				targetInfo[i].activeEffectValue = math.floor(targetInfo[i].activeEffectValue)
				targetInfo[i].activeEffectValue = math.abs(targetInfo[i].activeEffectValue)
			elseif skillID.skillId == 0 and attackRole:IsSameRow(targetRole) == false and attackRole:TriggerActiveEffect(skillID, 8, effectValue) then
				targetInfo[i].activeEffect = 8
				targetInfo[i].hurt = targetInfo[i].hurt * (100+effectValue.value) / 100
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
			elseif skillID.skillId > 0 and attackRole:IsSameRow(targetRole) == false and attackRole:SkillTriggerActiveEffect(skillID, 8, effectValue) then
				targetInfo[i].activeEffect = 8
				targetInfo[i].hurt = targetInfo[i].hurt * (100+effectValue.value) / 100
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
			elseif attackRole:TriggerActiveEffect(skillID, 10) then
				targetInfo[i].activeEffect = 10
			elseif bHurtSkill and attackRole:TriggerActiveEffect(skillID, 11) then
				targetInfo[i].activeEffect = 11
				targetInfo[i].hurt = -targetRole.currHp
			elseif bHurtSkill and attackRole:TriggerActiveEffect(skillID, 14, effectValue) then
				targetInfo[i].activeEffect = 14
				targetInfo[i].hurt = targetInfo[i].hurt - effectValue.value*(targetRole.logicInfo.maxhp-targetRole.currHp)
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
			--加深效果不可以占用主动效果，新增处理显示问题,modify by wkdai
			-- elseif bHurtSkill and temp_activeEffect ~= 0 then
			-- 	targetInfo[i].activeEffect = temp_activeEffect + 100
			-- 	targetInfo[i].hurt = targetInfo[i].hurt * (100+effectValue.value) / 100
			-- 	targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
			-- 	print("加深效果触发:",effectValue,targetInfo)
			elseif attackRole:TriggerActiveEffect(skillID, 21, effectValue) then
				targetInfo[i].activeEffectValue = -math.floor(attackRole.currHp * effectValue.value / 100)
				targetInfo[i].hurt = targetInfo[i].hurt + targetInfo[i].activeEffectValue*2
				targetInfo[i].activeEffect = 21
			end


			--是否触发被动效果:反弹5 反击6 化解7 复活9 免疫12 受击加血50
			effectValue = {}
			if bHurtSkill then
				if targetRole:TriggerPassiveEffect(12) and targetInfo[i].triggerBufferID ~= 0 then
					targetInfo[i].passiveEffect = 12
					targetInfo[i].triggerBufferID = 0
				elseif targetRole:TriggerPassiveEffect(9, effectValue) then
					targetInfo[i].passiveEffect = 9
					effectValue.value = math.min(100, effectValue.value)
					targetInfo[i].passiveEffectValue = targetRole.logicInfo.maxhp * effectValue.value / 100
					targetInfo[i].passiveEffectValue = math.floor(targetInfo[i].passiveEffectValue)
				elseif targetRole:TriggerPassiveEffect(5, effectValue) and math.abs(targetInfo[i].hurt) < targetRole.currHp then
					targetInfo[i].passiveEffect = 5
					targetInfo[i].passiveEffectValue = math.abs(targetInfo[i].hurt) * effectValue.value / 100
					targetInfo[i].passiveEffectValue = math.floor(targetInfo[i].passiveEffectValue)
				elseif skillID.skillId == 0 and targetRole:TriggerPassiveEffect(6) then
					targetInfo[i].passiveEffect = 6
				elseif targetRole:TriggerPassiveEffect(7, effectValue) then
					targetInfo[i].passiveEffect = 7
					effectValue.value = math.min(100, effectValue.value)
					targetInfo[i].hurt = targetInfo[i].hurt * (100-effectValue.value) / 100
					targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
				end

				if targetRole:IsLive() then
					--血刀大法
					local xdBuff = targetRole:GetBuffByType(30)
					if xdBuff ~= nil then
						targetInfo[i].hurt = targetInfo[i].hurt * (100-xdBuff.config.value) / 100
						targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
						targetInfo[i].passiveEffect = 50
						targetInfo[i].passiveEffectValue = math.floor(targetRole:GetAttrNum(4)*xdBuff.config.params)
					end
					msBuff = targetRole:GetBuffByType(32)
					if msBuff ~= nil then
						targetInfo[i].hurt = targetInfo[i].hurt * (100-msBuff.config.value) / 100
						targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
						targetInfo[i].passiveEffect = 7
					end
				end
			end
		end
	end

	return targetInfo
end

function FightRoundManager:CaculateHurtEffect(attackRole, skillID, targetRole)
	--是否治疗技能
	local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
	if skillBaseInfo ~= nil then
		if skillBaseInfo.type == 2 then
			return 4 --治疗
		elseif skillBaseInfo.type == 3 then
			return 5 --净化
		elseif skillBaseInfo.type == 8 then
			return 7 --主动加buff
		end
	end

	if targetRole:HaveDzxyBuff() and attackRole:canTriggerDzxy()  then
		return 6 --斗转星移
	end

	--[[
	暴击率 = max(暴击值/2-目标等级*49),0)/(1+0.04)^目标等级 + 暴击值/ (4*(1+0.04)^自身等级+0.65*自身等级）；      最小为：0
	命中率 = max(命中值/2-目标等级*49),0)/(1+0.04)^目标等级 + 命中值/ (4*(1+0.04)^自身等级+0.65*自身等级）+100 ； 最小为：0 + 100
	闪避率 = max(闪避值/2-目标等级*49),0)/(1+0.04)^目标等级 + 闪避值/（4*(1+0.04)^自身等级+0.65*自身等级）；      最小为：0
	抗暴率 = max(闪避值/2-目标等级*49),0)/(1+0.04)^目标等级 + 抗暴值/（4*(1+0.04)^自身等级+0.65*自身等级）；      最小为：0
	实际暴击率 = （暴击率 - 抗暴率 ）/100
	实际命中率 = 基础命中率  +  自己命中率 – 敌方闪避率 + 自己命中率% – 敌方闪避率%附加
	]]

	local targetLevel = targetRole.logicInfo.level
	local attackLevel = attackRole.logicInfo.level
	local pow104 = math.pow(1.04,targetLevel)
	local pow104attack = math.pow(1.04,attackLevel)
	local hit = attackRole:GetAttrNum(14) / 2 - targetLevel * 49
	hit = math.max(0,hit)
	if hit ~= 0 then
		hit = hit/pow104
	end
	hit = hit + attackRole:GetAttrNum(14)/ (4*(1+0.04)^attackLevel + 0.65*attackLevel)+ 100 --	说明:基础命中率 = 1 ,即:玩家初始有90%的基础命中率

	local dodge = targetRole:GetAttrNum(15) / 2 - attackLevel * 49
	dodge = math.max(0,dodge)
	if dodge ~= 0 then
		dodge = dodge/pow104attack
	end
	--闪避率公式修改 添加修正值
	dodge = dodge + targetRole:GetAttrNum(15) / (4*pow104attack +0.65*attackLevel)
	print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
	print("被攻击者 = ",targetRole.logicInfo.name)
	print("闪避值 = ",targetRole:GetAttrNum(15),"闪避率 = ",dodge)

		
	local hitRate = (hit - dodge) / 100 + attackRole:GetAttrNum(17)/10000 - targetRole:GetAttrNum(EnumAttributeType.MissPercent)/10000

	print("攻击者 = ",attackRole.logicInfo.name)
	print("基础命中率 = ",hit)
	print("附加命中率 = ",attackRole:GetAttrNum(17))
	print("敌方附加闪避率 = ",targetRole:GetAttrNum(EnumAttributeType.MissPercent))
	print("实际命中率 = ",hitRate)

	hitRate = math.max(hitRate, 0.3)
	hitRate = math.min(hitRate, 1.0)

	local radomNumber = math.random(1, 10000)
	if radomNumber > hitRate*10000 then --miss
		return 3
	end
	
	local violent = attackRole:GetAttrNum(12) / 2 - targetLevel * 49
	violent = math.max(0,violent)
	if violent ~= 0 then
		violent = violent/pow104
	end
	-- 暴击修正值，暴击值对暴击者自身的加成
	violent = violent + attackRole:GetAttrNum(12) / (4*pow104attack +0.65*attackLevel)
	print("攻击者 = ",attackRole.logicInfo.name)
	print("暴击率 = ",attackRole:GetAttrNum(12),"暴击率 = ",violent)

	local resistViolent = targetRole:GetAttrNum(13) / 2 - attackLevel * 49
	resistViolent = math.max(0,resistViolent)
	if resistViolent ~= 0 then
		resistViolent = resistViolent/pow104
	end
	-- 抗暴修正值，抗暴值对抗暴者自身的加成
	resistViolent = resistViolent + targetRole:GetAttrNum(13) / (4*pow104attack +0.65*attackLevel)
	print("被攻击者 = ",targetRole.logicInfo.name)
	print("抗暴率 = ",targetRole:GetAttrNum(13),"抗暴率 = ",resistViolent)
	print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")

	local violentRate = (violent - resistViolent) / 100 + attackRole:GetAttrNum(16)/10000  - targetRole:GetAttrNum(EnumAttributeType.CritResistancePercent)/10000
	violentRate = math.max(violentRate, 0)
	violentRate = math.min(violentRate, 0.9)

	local radomNumber = math.random(1, 10000)
	if radomNumber < violentRate*10000 then --暴击
		return 2
	else
		return 1
	end
end

--普通攻击伤害 = 武力*武力/(武力+防御)*1.2
--技能攻击伤害 = (武力*武力系数+内力*内力系数)* (武力*武力系数+内力*内力系数)/( 武力*武力系数+内力*内力系数+防御)*1.2
--               +技能属性系数(冰火毒)*属性伤害(冰火毒)-属性抗性（冰火毒）+ 附加伤害
-- 最终伤害 = 基础伤害*暴击修正(1.5) 结果取整
function FightRoundManager:CaculateHurtNum(attackRole, skillID, targetRole, effect)
	local attackAttr = attackRole:GetAttrNum(2)
	local defAttr = targetRole:GetAttrNum(3)
	local neiliAttr = attackRole:GetAttrNum(4)

	if skillID.skillId == 0 then
		local hurt = 0
		if attackAttr+defAttr > 0 then
			hurt = 1.2*attackAttr*attackAttr/(attackAttr+defAttr)
		end

		if FightManager.fightBeginInfo.fighttype == 5 then
			local power_suppress = ClimbManager:getAtkSuppress( attackRole.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole  )
			hurt = math.floor(hurt * power_suppress)
		end
		--暴击加成
		if effect == 2 then
			hurt = 1.5 * hurt
		end
		hurt = math.floor(hurt)
		
		print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
		print(attackRole.logicInfo.name.."普通攻击"..targetRole.logicInfo.name..",造成伤害："..hurt)
		print("攻击方属性:武力--"..attackAttr..",命中--"..attackRole:GetAttrNum(14)..",暴击--"..attackRole:GetAttrNum(12))
		print("受击方属性:防御--"..defAttr..",闪避--"..targetRole:GetAttrNum(15)..",暴抗--"..targetRole:GetAttrNum(13))

		return hurt
	else
		local hurtParams = {1.0, 1.0, 1.0, 1.0, 1.0}
		local skillInfo = SkillLevelData:objectByID(skillID)
		if skillInfo ~= nil then
			hurtParams[1] = skillInfo.outside
			hurtParams[2] = skillInfo.inside
			hurtParams[3] = skillInfo.ice
			hurtParams[4] = skillInfo.fire
			hurtParams[5] = skillInfo.poison
		end

		--加血量 = 治疗者(武力*武力系数+内力*内力系数)+配置表附加值
		if effect == 4 then 
			local addHpNum = attackAttr*hurtParams[1]+neiliAttr*hurtParams[2]+skillInfo.effect_value
			local neiliAttr = targetRole:GetAttrNum(EnumAttributeType.BonusHealing)
			-- neiliAttr = math.max(neiliAttr,-100)
			addHpNum = addHpNum * neiliAttr/100
			return math.floor(addHpNum)
		end
		
		local baseAttr = attackAttr*hurtParams[1]+neiliAttr*hurtParams[2]
		local hurt = 0
		if baseAttr+defAttr > 0 then
		 	hurt = 	1.2*baseAttr*baseAttr/(baseAttr+defAttr) + 
					math.max(0, hurtParams[3]*attackRole:GetAttrNum(6) - targetRole:GetAttrNum(9)) +
					math.max(0, hurtParams[4]*attackRole:GetAttrNum(7) - targetRole:GetAttrNum(10)) +
					math.max(0, hurtParams[5]*attackRole:GetAttrNum(8) - targetRole:GetAttrNum(11)) +
					math.max(0, skillInfo.extra_hurt)
		end

		if FightManager.fightBeginInfo.fighttype == 5 then
			local power_suppress = ClimbManager:getAtkSuppress( attackRole.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole  )
			hurt = math.floor(hurt * power_suppress)
		end
		
		--暴击加成
		if effect == 2 then
			hurt = 1.5 * hurt
		end
		hurt = math.floor(hurt)

		print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
		print(attackRole.logicInfo.name.."技能攻击"..targetRole.logicInfo.name..",造成伤害："..hurt)
		print("攻击方属性:武力--"..attackAttr..",内力--"..neiliAttr)
		print("受击方属性:防御--"..defAttr)

		return hurt
	end
end

--插入主动技能
function FightRoundManager:AddManualAction(fightRole, bManualAdd)
	if not fightRole:CanReleaseManualSkill() then
		return false
	end

	local newAction = {}
	newAction.bManualAction = true
	newAction.unExecute = true
	newAction.roundIndex = math.max(1, self.nCurrRoundIndex)
	newAction.attackerpos = fightRole.logicInfo.posindex
	newAction.skillid = fightRole.skillID

	local bInsert = false
	local actionNum = self.actionList:length()
	for i=1,actionNum do
		local actionInfo = self.actionList:objectAt(i)
		local actionRole = fightRoleMgr:GetRoleByGirdIndex(actionInfo.attackerpos)
		if actionRole ~= nil and actionRole:IsLive() then
			if actionInfo.bManualAction and actionInfo.unExecute and fightRole:GetAttrNum(5) > actionRole:GetAttrNum(5) then
				self.actionList:insertAt(i, newAction)
				bInsert = true
			end
		end
	end

	if not bInsert then
		self.actionList:pushBack(newAction)
	end

	local skillAnger = fightRole:GetSkillAnger()
	fightRoleMgr:AddAnger(fightRole.logicInfo.bEnemyRole, -skillAnger)

	if FightManager.isAutoFight and fightRole.logicInfo.bEnemyRole == false and bManualAdd ~= true then
		TFDirector:currentScene().fightUiLayer:ReleaseSkillByAI(fightRole)
	end

	fightRole:AddBodyEffect("skill_yuyue", true, false, 0, 200)

	return true
end

function FightRoundManager:IsRoleHaveManualAction(fightRole)
	local actionNum = self.actionList:length()
	for i=1,actionNum do
		local actionInfo = self.actionList:objectAt(i)
		if actionInfo.bManualAction and actionInfo.unExecute and actionInfo.attackerpos == fightRole.logicInfo.posindex then
			return true
		end
	end
	return false
end

function FightRoundManager:GetManualAction(bEnemy)
	local manualAction = nil
	local actionNum = self.actionList:length()
	local actionIndex = nil
	for i=1,actionNum do
		local actionInfo = self.actionList:objectAt(i)
		local bEnemyAction = false
		if actionInfo.attackerpos >= 9 then
			bEnemyAction = true
		end

		if actionInfo.bManualAction and actionInfo.unExecute then
			if bEnemy == nil or bEnemyAction == bEnemy then
				manualAction = actionInfo
				actionIndex = i
				break
			end
		end
	end

	if manualAction ~= nil then
		local attackRole = fightRoleMgr:GetRoleByGirdIndex(manualAction.attackerpos)
		local canRelease = true
		if attackRole == nil or attackRole:IsLive() == false or attackRole:HaveForbidManualSkillBuff() then
			self:RemoveManualAction(manualAction.attackerpos)
			manualAction = nil
		end
	end
	return manualAction
end

function FightRoundManager:RemoveManualAction(rolePos)
	local actionNum = self.actionList:length()
	for i=1,actionNum do
		local actionInfo = self.actionList:objectAt(i)
		if actionInfo.bManualAction and actionInfo.unExecute and rolePos == actionInfo.attackerpos then
			self.actionList:removeObjectAt(i)
			fightRoleMgr:OnRemoveManualAction(actionInfo)
			return
		end
	end
end

--斗转星移反击action
function FightRoundManager:SetDzxyAttackAction(attackRole, targetRole, hurt)
	if FightManager.isReplayFight then
		return
	end

	if attackRole:IsLive() == false or targetRole:IsLive() == false then
		return
	end

	if self:HaveBackAttackAction() then
		return
	end

	local dzxyBuff = attackRole:GetBuffByType(27)
	if dzxyBuff == nil then
		return
	end

	self.backAttackAction = {}
	self.backAttackAction.bManualAction = false
	self.backAttackAction.unExecute = true
	self.backAttackAction.roundIndex = self.nCurrRoundIndex
	self.backAttackAction.attackerpos = attackRole.logicInfo.posindex
	self.backAttackAction.skillid = attackRole.skillID
	self.backAttackAction.bBackAttack = true
	self.backAttackAction.targetlist = {}
	self.backAttackAction.targetlist[1] = {}
	self.backAttackAction.targetlist[1].targetpos = targetRole.logicInfo.posindex
	self.backAttackAction.targetlist[1].effect = 1
	local neiliAttr = attackRole:GetAttrNum(4)
	self.backAttackAction.targetlist[1].hurt = math.floor(hurt*dzxyBuff.config.value/100 - neiliAttr*dzxyBuff.config.params)
end

--反击action
function FightRoundManager:SetBackAttackAction(attackRole, targetRole)
	if FightManager.isReplayFight then
		return
	end

	if attackRole:IsLive() == false or targetRole:IsLive() == false then
		return
	end

	if attackRole:HaveForbidBackAttackBuff() then
		return
	end

	if self:HaveBackAttackAction() then
		return
	end

	if fightRoleMgr:IsSameSide({attackRole, targetRole}) then
		return
	end

	self.backAttackAction = {}
	self.backAttackAction.bManualAction = false
	self.backAttackAction.unExecute = true
	self.backAttackAction.roundIndex = self.nCurrRoundIndex
	self.backAttackAction.attackerpos = attackRole.logicInfo.posindex
	self.backAttackAction.skillid = {skillId = 0 , level = 0}
	self.backAttackAction.bBackAttack = true

	local targetList = {}
	targetList[1] = targetRole
	self.backAttackAction.targetlist = self:CaculateTargetBackAttackHurt(attackRole,  targetList)
end

function FightRoundManager:HaveBackAttackAction()
	return self.backAttackAction ~= nil
end

function FightRoundManager:ExecuteBackAttackAction(endActionInfo)
	if self.backAttackAction == nil then
		return
	end

	local newAction = clone(self.backAttackAction)
	newAction.unExecute = false
	self.backAttackAction = nil

	local actionNum = self.actionList:length()
	for i=1,actionNum do
		local actionInfo = self.actionList:objectAt(i)
		if actionInfo == endActionInfo then
		print("actionList:insertAt 1111")
			self.actionList:insertAt(i+1, newAction)
			break
		end
	end
	print("newAction = ",newAction)
	self:ExecuteAction(newAction)
end

function FightRoundManager:AddReplayAction(replayList)
	self.actionList:clear()
	if replayList == nil then
		return
	end

	local actionNum = #replayList
	for i=1,actionNum do
		local replayAction = replayList[i]
		local action = {}
		action.bManualAction = replayAction.bManualAction
		action.bBackAttack = replayAction.bBackAttack
		action.unExecute = true
		action.roundIndex = replayAction.roundIndex

		action.attackerpos = replayAction.attackerpos
		if action.attackerpos < 9 then
			action.attackerpos = action.attackerpos + 9
		else
			action.attackerpos = action.attackerpos - 9
		end

		action.skillid = {skillId = replayAction.skillid ,level = replayAction.skillLevel}

		action.targetlist = replayAction.targetlist
		local nTargetCount = #action.targetlist
		for i=1,nTargetCount do
			local targetInfo = action.targetlist[i]
			if targetInfo.targetpos < 9 then
				targetInfo.targetpos = targetInfo.targetpos + 9
			else
				targetInfo.targetpos = targetInfo.targetpos - 9
			end
		end
		
		self.actionList:pushBack(action)
	end
end

function FightRoundManager:AddReplayActionNoChangPos(replayList)
	self.actionList:clear()
	if replayList == nil then
		return
	end

	local actionNum = #replayList
	for i=1,actionNum do
		local replayAction = replayList[i]
		local action = {}
		action.bManualAction = replayAction.bManualAction
		action.bBackAttack = replayAction.bBackAttack
		action.unExecute = true
		action.roundIndex = replayAction.roundIndex

		action.attackerpos = replayAction.attackerpos

		action.skillid = {skillId = replayAction.skillid ,level = replayAction.skillLevel}

		action.targetlist = replayAction.targetlist
		self.actionList:pushBack(action)
	end
end

function cmpAgilityFun(role1, role2)
	if role1:GetAttrNum(5) < role2:GetAttrNum(5) then
        return false
    else
        return true
    end
end

function FightRoundManager:GetAttackOrder()
	local maxNum = 5
	local orderList = {}

	if self.currAction ~= nil and self.currAction.actionInfo.bBackAttack ~= true then
		orderList[1] = {}
		orderList[1].fightRole = self.currAction.attackerRole
		orderList[1].bManualAction = self.currAction.actionInfo.bManualAction
	end

	local actionNum = self.actionList:length()
	for i=1,actionNum do
		local actionInfo = self.actionList:objectAt(i)
		if actionInfo.unExecute and actionInfo.bManualAction then
			local attackRole = fightRoleMgr:GetRoleByGirdIndex(actionInfo.attackerpos)
			local num = #orderList
			if attackRole ~= nil and attackRole:IsLive() and num < maxNum then
				orderList[num+1] = {}
				orderList[num+1].fightRole = attackRole
				orderList[num+1].bManualAction = true
			end
		end
	end

	if #orderList >= maxNum then
		return orderList
	end

	local unAttackList = TFArray:new()
	for k,role in pairs(fightRoleMgr.map) do
		if role:IsLive() and role:HaveForbidAttackBuff() == false and role.haveAttack == false then
			unAttackList:pushBack(role)
		end
	end

	local unAttackNum = unAttackList:length()
	if unAttackNum == 0 then
		return orderList
	end

	unAttackList:sort(cmpAgilityFun)
	for i=1,unAttackNum do
		local currNum = #orderList
		if currNum >= maxNum then
			break
		end
		orderList[currNum+1] = {}
		orderList[currNum+1].fightRole = unAttackList:objectAt(i)
		orderList[currNum+1].bManualAction = false
	end

	return orderList
end

function FightRoundManager:hasBuffByType(buff_type ,bEnemyRole )
	local targetIsEnemy = not bEnemyRole
	local liveList = fightRoleMgr:GetAllLiveRole(targetIsEnemy,false,false)
	local liveNum = liveList:length()
	for i=1,liveNum do
		local role = liveList:objectAt(i)
		if role:GetBuffByType(buff_type) then
			return true
		end
	end
	return false
end

function FightRoundManager:hasOrGiveBuff(triggerBuffID,buff ,attackRole )
	local attackIsEnemy = attackRole.logicInfo.bEnemyRole
	local targetIsEnemy = not attackIsEnemy
	local liveList = fightRoleMgr:GetAllLiveRole(targetIsEnemy,false,false)
	local liveNum = liveList:length()
	for i=1,liveNum do
		local role = liveList:objectAt(i)
		if role:GetBuffByType(buff.type) then
			return
		end
	end
	local targetList = {}
	local targetType = tonumber(buff.params)
	if targetType == 1 then -- 单体技能
		targetList = fightRoleMgr:GetSingleTarget(attackRole)
	elseif targetType == 2 then -- 全屏技能
		targetList = fightRoleMgr:GetScreenTarget(targetIsEnemy)
	elseif targetType == 3 then -- 横排贯穿技能
		targetList = fightRoleMgr:GetRowTarget(attackRole)
	elseif targetType == 4 then -- 竖排穿刺技能
		targetList = fightRoleMgr:GetColumnTarget(attackRole)
	elseif targetType == 5 then -- 敌方随机
		targetList = fightRoleMgr:GetRandomTarget(targetIsEnemy, 1)
	elseif targetType == 6 then -- 敌方血最少
		targetList = fightRoleMgr:GetTargetByAttr(1, targetIsEnemy, false, 1)
	elseif targetType == 7 then -- 敌方防最少
		targetList = fightRoleMgr:GetTargetByAttr(3, targetIsEnemy, false, 1)
	elseif targetType == 8 then -- 我方随机
		targetList = fightRoleMgr:GetRandomTarget(attackIsEnemy, 1)
	elseif targetType == 9 then -- 我方血最少
		targetList = fightRoleMgr:GetTargetByAttr(1, attackIsEnemy, false, 1)
	elseif targetType == 10 then -- 我方全体
		targetList = fightRoleMgr:GetScreenTarget(attackIsEnemy)
	elseif targetType == 11 then -- 自己
		targetList = {attackRole}
	elseif targetType == 12 then -- 敌方防最高
		targetList = fightRoleMgr:GetTargetByAttr(3, targetIsEnemy, true, 1)
	else
		assert(false, buff.id.."targetType error")
	end
	if not targetList then
		return
	end

	local targetNum = #targetList
	if targetNum > 0 then
		for i=1,targetNum do
			local targetRole = targetList[i]
			if targetRole:IsLive() then
				targetRole:AddBuff(buff.id, 1,0)
				self:AddPermanentBuf(attackRole, targetRole ,{skillid = 0, level = 0},buff.id, triggerBuffID)
			end

		end
	end
end

function FightRoundManager:AddPermanentBuf(fromRole, targetRole, skillInfo,bufferID, triggerBuffID )
	local buffInfo = {}
	buffInfo[1] = fromRole.logicInfo.posindex
	buffInfo[2] = targetRole.logicInfo.posindex
	buffInfo[3] = triggerBuffID
	buffInfo[4] = skillInfo.skillid
	buffInfo[5] = skillInfo.level
	buffInfo[6] = bufferID
	buffInfo[7] = 1

	local num = #self.permanentBufList
	self.permanentBufList[num+1] = buffInfo
end

function FightRoundManager:CaculateTargetBackAttackHurt(attackRole, targetList)
	print("-------反击-----------------------CaculateTargetBackAttackHurt")
	local targetInfo = {}
	local targetNum = #targetList
	local bHaveTrigger = false
	local skillID = { skillId = 0,level = 0}
	
	for i=1,targetNum do
		targetInfo[i] = {}
		local targetRole = targetList[i]
		targetInfo[i].targetpos = targetRole.logicInfo.posindex
		targetInfo[i].effect = self:CaculateHurtEffect(attackRole, skillID, targetRole)
		if targetInfo[i].effect == 3 then
			targetInfo[i].hurt = 0
		elseif targetInfo[i].effect == 6 then --斗转星移
			targetInfo[i].hurt = self:CaculateHurtNum(attackRole, skillID, targetRole, targetInfo[i].effect)
			targetInfo[i].hurt = -(targetInfo[i].hurt)
		elseif targetInfo[i].effect == 7 then --主动加buff
			targetInfo[i].hurt = 0
			--触发buffer
			local bufferID , bufferLevel = attackRole:GetTriggerBufferID(skillID, targetRole)
			if bufferID > 0 and SkillBufferData:objectByID(bufferID,bufferLevel) == nil then
				-- print("skill:"..skillID.."--------->buff_id:"..bufferID.."not find in SkillBufferData")
				bufferID = 0
				bufferLevel = 0
			end
			targetInfo[i].triggerBufferID = bufferID
			targetInfo[i].triggerBufferLevel = bufferLevel
		else
			local bHurtSkill = false
			if targetInfo[i].effect == 1 or targetInfo[i].effect == 2 then
				bHurtSkill = true
			end

			targetInfo[i].hurt = self:CaculateHurtNum(attackRole, skillID, targetRole, targetInfo[i].effect)

			if bHurtSkill then
				local frontRoleNum = fightRoleMgr:GetFrontRoleNum(targetRole, targetList)
				local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(skillID)
				local decay = 1
				if skillBaseInfo ~= nil and skillBaseInfo.target_type == 2 then
					if frontRoleNum == 1 then
						decay = ConstantData:getValue("hurt.decay.screen.one") / 100
					elseif frontRoleNum == 2 then
						decay = ConstantData:getValue("hurt.decay.screen.two") / 100
					end
				elseif skillBaseInfo ~= nil and skillBaseInfo.target_type == 3 then
					if frontRoleNum == 1 then
						decay = ConstantData:getValue("hurt.decay.row.one") / 100
					elseif frontRoleNum == 2 then
						decay = ConstantData:getValue("hurt.decay.row.two") / 100
					end
				end
				targetInfo[i].hurt = targetInfo[i].hurt * decay
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
				targetInfo[i].hurt = math.max(10, targetInfo[i].hurt)
				if decay ~= 1 then
					print(attackRole.logicInfo.name.."技能攻击"..targetRole.logicInfo.name..",伤害衰减系数："..decay..",衰减到："..targetInfo[i].hurt)
				end

				targetInfo[i].hurt = -(targetInfo[i].hurt)
			end

			--触发buffer
			local bufferID , bufferLevel = attackRole:GetTriggerBufferID(skillID, targetRole)
			if bufferID > 0 and SkillBufferData:objectByID(bufferID,bufferLevel) == nil then
				-- print("skill:",skillID,"--------->buff_id:"..bufferID.."not find in SkillBufferData")
				bufferID = 0
				bufferLevel = 0
			end
			targetInfo[i].triggerBufferID = bufferID
			targetInfo[i].triggerBufferLevel = bufferLevel

			local effectValue = {}
			local temp_activeEffect = attackRole:TriggerBuffHurtBackAttack(targetRole,  effectValue)
			
			--加深效果跟activeEffect不冲突
			if temp_activeEffect and temp_activeEffect ~= 0 then
				-- targetInfo[i].activeEffect = temp_activeEffect + 100
				targetInfo[i].deepHurtType = temp_activeEffect
				targetInfo[i].hurt = targetInfo[i].hurt * (100+effectValue.value) / 100
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
				print("加深效果触发:",effectValue,targetInfo)
			end

			--是否触发主动效果:吸怒1 减敌怒2 增己怒3 吸血4 侧击8 净化10 致死11 重击14 七伤拳21  额定血量15
			local testEffectValue = {}
			if attackRole:TriggerActiveEffect(skillID, 15, testEffectValue) then
				targetInfo[i].hurt = targetInfo[i].hurt +  effectValue.value*(targetRole.logicInfo.maxhp)
			end
			if attackRole:TriggerActiveEffect(skillID, 16, testEffectValue) then
				targetInfo[i].hurt = targetInfo[i].hurt +  effectValue.value*(targetRole.currHp)
			end

			if bHaveTrigger == false and attackRole:TriggerActiveEffect(skillID, 1, effectValue) then
				targetInfo[i].activeEffect = 1
				targetInfo[i].activeEffectValue = effectValue.value
				bHaveTrigger = true
			elseif bHaveTrigger == false and attackRole:TriggerActiveEffect(skillID, 2, effectValue) then
				targetInfo[i].activeEffect = 2
				targetInfo[i].activeEffectValue = effectValue.value
				bHaveTrigger = true
			elseif bHaveTrigger == false and attackRole:TriggerActiveEffect(skillID, 3, effectValue) then
				targetInfo[i].activeEffect = 3
				targetInfo[i].activeEffectValue = effectValue.value
				bHaveTrigger = true
			elseif bHurtSkill and attackRole:TriggerActiveEffect(skillID, 4, effectValue) then
				targetInfo[i].activeEffect = 4
				targetInfo[i].activeEffectValue = targetInfo[i].hurt * effectValue.value / 100
				targetInfo[i].activeEffectValue = math.floor(targetInfo[i].activeEffectValue)
				targetInfo[i].activeEffectValue = math.abs(targetInfo[i].activeEffectValue)
			elseif skillID.skillId == 0 and attackRole:IsSameRow(targetRole) == false and attackRole:TriggerActiveEffect(skillID, 8, effectValue) then
				targetInfo[i].activeEffect = 8
				targetInfo[i].hurt = targetInfo[i].hurt * (100+effectValue.value) / 100
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
			elseif attackRole:TriggerActiveEffect(skillID, 10) then
				targetInfo[i].activeEffect = 10
			elseif bHurtSkill and attackRole:TriggerActiveEffect(skillID, 11) then
				targetInfo[i].activeEffect = 11
				targetInfo[i].hurt = -targetRole.currHp
			elseif bHurtSkill and attackRole:TriggerActiveEffect(skillID, 14, effectValue) then
				targetInfo[i].activeEffect = 14
				targetInfo[i].hurt = targetInfo[i].hurt - effectValue.value*(targetRole.logicInfo.maxhp-targetRole.currHp)
				targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
			--加深效果不可以占用主动效果，新增处理显示问题,modify by wkdai
			-- elseif bHurtSkill and temp_activeEffect ~= 0 then
			-- 	targetInfo[i].activeEffect = temp_activeEffect + 100
			-- 	targetInfo[i].hurt = targetInfo[i].hurt * (100+effectValue.value) / 100
			-- 	targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
			-- 	print("加深效果触发:",effectValue,targetInfo)
			elseif attackRole:TriggerActiveEffect(skillID, 21, effectValue) then
				targetInfo[i].activeEffectValue = -math.floor(attackRole.currHp * effectValue.value / 100)
				targetInfo[i].hurt = targetInfo[i].hurt + targetInfo[i].activeEffectValue*2
				targetInfo[i].activeEffect = 21
			end


			--是否触发被动效果:反弹5 反击6 化解7 复活9 免疫12 受击加血50  25 死亡出buff
			effectValue = {}
			if bHurtSkill then
				if targetRole:TriggerPassiveEffect(12) and targetInfo[i].triggerBufferID ~= 0 then
					local buffInfo = SkillBufferData:objectByID(targetInfo[i].triggerBufferID)
					if buffInfo and buffInfo.good_buff == 0 then
						targetInfo[i].passiveEffect = 12
						targetInfo[i].triggerBufferID = 0
					end
				elseif targetRole:TriggerPassiveEffect(9, effectValue) then
					targetInfo[i].passiveEffect = 9
					effectValue.value = math.min(100, effectValue.value)
					targetInfo[i].passiveEffectValue = targetRole.logicInfo.maxhp * effectValue.value / 100
					targetInfo[i].passiveEffectValue = math.floor(targetInfo[i].passiveEffectValue)
				elseif targetRole:TriggerPassiveEffect(5, effectValue) and math.abs(targetInfo[i].hurt) < targetRole.currHp then
					targetInfo[i].passiveEffect = 5
					targetInfo[i].passiveEffectValue = math.abs(targetInfo[i].hurt) * effectValue.value / 100
					targetInfo[i].passiveEffectValue = math.floor(targetInfo[i].passiveEffectValue)
				elseif skillID.skillId == 0 and targetRole:TriggerPassiveEffect(6) then
					targetInfo[i].passiveEffect = 6
				elseif targetRole:TriggerPassiveEffect(7, effectValue) then
					targetInfo[i].passiveEffect = 7
					effectValue.value = math.min(100, effectValue.value)
					targetInfo[i].hurt = targetInfo[i].hurt * (100-effectValue.value) / 100
					targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
				end

				if targetRole:IsLive() then
					--血刀大法
					local xdBuff = targetRole:GetBuffByType(30)
					if xdBuff ~= nil then
						targetInfo[i].hurt = targetInfo[i].hurt * (100-xdBuff.config.value) / 100
						targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
						targetInfo[i].passiveEffect = 50
						targetInfo[i].passiveEffectValue = math.floor(targetRole:GetAttrNum(4)*xdBuff.config.params)
					end
					msBuff = targetRole:GetBuffByType(32)
					if msBuff ~= nil then
						targetInfo[i].hurt = targetInfo[i].hurt * (100-xdBuff.config.value) / 100
						targetInfo[i].hurt = math.floor(targetInfo[i].hurt)
						targetInfo[i].passiveEffect = 7
					end
				end
			end
		end
	end

	return targetInfo
end

function FightRoundManager:pause( ... )
	if self.currAction then
		self.currAction:pause()
	end
end

return FightRoundManager:new()
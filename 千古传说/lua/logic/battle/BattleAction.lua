--
-- Author: Zippo
-- Date: 2013-12-05 20:02:30
--

local battleRoleMgr  = require("lua.logic.battle.BattleRoleManager")
-- local fightRoundMgr  = require("lua.logic.fight.FightRoundManager")
local mapLayer  = require("lua.logic.battle.BattleMapLayer")

local BattleAction = class("BattleAction")



--[[
//战斗动作，角色行动
message BattleAction
{
	required int32 type = 1;					//动作类型：1、主动释放大招；2、普通攻击；3、反击；4、触发被动技能……
	required int32 fromPos = 2;  				//攻击者位置。0~17，左侧0~8，右侧9~17
	repeated ActionTargetInfo target = 3;				//收到影响的目标
	repeated NewStateInfo newState = 4;			//发起动作角色，获取的状态
	repeated LostStateInfo lostState = 5;		//发起动作角色，失去状态
	repeated StateCycleEffect stateCycle = 6;	//发起动作角色，状态周期性影响
	optional SkillInfo skill = 7;				//释放的技能，如果不是释放技能，此字段为null，不需要发送
}

//技能信息
message SkillInfo
{
	required int32 skillId = 1; 		//技能的id
	required int32 level = 2; 		//技能的等级
}

message ActionTargetInfo
{
	required int32 position = 1;  				//受击者位置
	required int32 effectType = 2;				//效果类型：1、普通攻击；2、暴击；3、躲避；4、治疗；5、净化；6、斗转星移；7、加状态
	required int32 effectValue = 3;				//产生的影响值，对HP直接影响，负数为扣血，正数为加血
	repeated TriggerEffect passiveEffect = 4;	//被动效果类型
	repeated TriggerEffect activeEffect = 5;	//主动效果类型
	repeated NewStateInfo newState = 6;			//新获得的状态
	repeated LostStateInfo lostState = 7;		//发起动作角色，失去状态
	repeated StateCycleEffect stateCycle = 8;	//发起动作角色，状态周期性影响
	optional DeepHurt deepHurt = 9;				//伤害加深，毒暴击等，如果没有加深效果不需要填写
}


//新增状态
message NewStateInfo
{
	required int32 fromPos = 1;					//状态由那个角色给与，0~17
	required bool stateTrigger = 2;				//是否为状态触发，如果true则表示triggerId为状态ID，否则为技能ID
	required int32 triggerId = 3;				//产生状态的来源ID，可能是状态ID，或者技能ID，始终是fromPos的角色身上的技能或者状态
	required int32 stateId = 6;					//角色获得的状态ID
	required int32 stateLevel = 7;				//状态等级
	optional int32 result = 8;					//给与状态结果，默认不需要填写，为了适配：1、抵抗；2、免疫等显示效果定义
}

]]
function BattleAction:ctor(actionInfo)
	if actionInfo.skill == nil then
		actionInfo.skill = {}
		actionInfo.skill[1] = { skillId = 0 ,level = 0}
	end
	self.actionInfo = actionInfo
	self.attackerRole = battleRoleMgr:GetRoleByGirdIndex(actionInfo.fromPos)
	assert(self.attackerRole, "fromPos" .. actionInfo.fromPos .. "not find")


	self:addBuffer( 1 )

	self.bNormalAttack = false
	local skillDisplayID = 0
	self.bRowAttack = false

	if actionInfo.type ~= 2 then
		self.bNormalAttack = true
	end

	if actionInfo.type == 2 or actionInfo.type == 4 then
		local skillInfo = BaseDataManager:GetSkillBaseInfo(actionInfo.skill[1])
		if skillInfo ~= nil and skillInfo.target_type == 3 then -- 横排技能
			self.bRowAttack = true
		end

		if skillInfo ~= nil then
			skillDisplayID = skillInfo.display_id
		end
	end

	if actionInfo.type == 3 and actionInfo.skill[1] ~= 0 then
		local skillInfo = BaseDataManager:GetSkillBaseInfo(actionInfo.skill[1])
		if skillInfo ~= nil and skillInfo.target_type == 3 then -- 横排技能
			self.bRowAttack = true
		end

		if skillInfo ~= nil then
			skillDisplayID = skillInfo.display_id
		end
	end

	self.skillDisplayInfo = SkillDisplayData:objectByID(skillDisplayID)
	if self.skillDisplayInfo == nil then
		-- print("playskill:skillDisplayID----------->"..skillDisplayID.."not find")
		local armatureID = self.attackerRole.armatureID
		if self.bNormalAttack then
			self.skillDisplayInfo = SkillDisplayData:objectByID(armatureID-10000)
		else
			self.skillDisplayInfo = SkillDisplayData:objectByID((armatureID-10000)*100+1)
		end

		if self.skillDisplayInfo == nil then
			self.skillDisplayInfo = SkillDisplayData:objectByID(9999)
		end
	end

	if self.skillDisplayInfo.needMoveSameRow == 1 then
		self.bRowAttack = true
	end

	-- print("playskill:----------->skillid:"..actionInfo.skillid.."---->displayid:"..self.skillDisplayInfo.id)

	self.hitEffTimerIDList = TFArray:new()
	self.extraEffTimerIDList = TFArray:new()
	-- self.bEnemyAllDie = self:IsEnemyAllDie()

	self.hasTrrigerBackAttack = actionInfo.hasTrrigerBackAttack or false
	
end

function BattleAction:dispose()
	if self.xuliEffTimerID then
		TFDirector:removeTimer(self.xuliEffTimerID)
		self.xuliEffTimerID = nil
	end
	if self.specilTimerID then
		TFDirector:removeTimer(self.specilTimerID)
		self.specilTimerID = nil
	end
	if self.attackEffTimerID then
		for k,v in pairs(self.attackEffTimerID) do
			TFDirector:removeTimer(v)
		end
		self.attackEffTimerID = nil
	end
	if self.hitTimerID then
		TFDirector:removeTimer(self.hitTimerID)
		self.hitTimerID = nil
	end
	if self.attackSoundTimerID then
		TFDirector:removeTimer(self.attackSoundTimerID)
		self.attackSoundTimerID = nil
	end
	if self.hitSoundTimerID then
		TFDirector:removeTimer(self.hitSoundTimerID)
		self.hitSoundTimerID = nil
	end
	if self.hitXuliEffTimerID  then
		TFDirector:removeTimer(self.hitXuliEffTimerID )
		self.hitXuliEffTimerID  = nil
	end


	local hitEffTimerNum = self.hitEffTimerIDList:length()
	for i=1,hitEffTimerNum do
		TFDirector:removeTimer(self.hitEffTimerIDList:objectAt(i))
	end
	self.hitEffTimerIDList:clear()
	local extraEffTimerNum = self.extraEffTimerIDList:length()
	for i=1,extraEffTimerNum do
		TFDirector:removeTimer(self.extraEffTimerIDList:objectAt(i))
	end
	self.extraEffTimerIDList:clear()
end


function BattleAction:Execute()
	if self.attackerRole == nil or self.attackerRole:IsLive() == false then
		FightManager:OnActionEnd()
		return
	end
	if self.actionInfo.target == nil then
		FightManager:OnActionEnd()
		return
	end
	local nTargetCount = #self.actionInfo.target
	if nTargetCount == 0 then
		FightManager:OnActionEnd()
		return
	end

	local targetRole = battleRoleMgr:GetRoleByGirdIndex(self.actionInfo.target[1].position)
	if targetRole == nil then
		FightManager:OnActionEnd()
		return
	end

	-- battleRoleMgr:OnActionStart()

	if self.bNormalAttack then
		self:BeginAttack()
	else
		self:ShowSkillNameEff()
	end
end

function BattleAction:ShowSkillNameEff()
	if not self.attackerRole.logicInfo.bEnemyRole then
		TFDirector:currentScene().mapLayer:ChangeDark(true)
	end
--SkillBaseData:objectByID(skillId.skillId)
	local skillInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skill[1] or {skillId = 0,level = 0})
	if skillInfo ~= nil and skillInfo.name ~= "" then
		TFDirector:currentScene().fightUiLayer:ShowSkillName(skillInfo.name, self.attackerRole.logicInfo.bEnemyRole)
	end
	TFAudio.playEffect("sound/effect/skill_ready.mp3", false)
	RoleSoundData:playFightSoundByIndex(self.attackerRole.logicInfo.roleId)
	self.attackerRole:PlaySkillNameEffect()
end

function BattleAction:AddAttackBuff()
	if self.actionInfo.newState == nil then
		return
	end
	local length = #self.actionInfo.newState
	if length <= 0 then
		return
	end
	for i=1,length do
		local state = self.actionInfo.newState[i]
		
	end
end

function BattleAction:BeginAttack()
	local targetRole = self:GetTargetRole(1)

	self:AddAttackBuff()

	if self.actionInfo.type == 3 then
		self:ShowAttackAnim()
	elseif self.skillDisplayInfo.remote == 0 then
		self.attackerRole:MoveToRole(targetRole, self.skillDisplayInfo.moveDistance, self.skillDisplayInfo.beforeMoveAnim)
	elseif self.bRowAttack and self.attackerRole:IsSameRow(targetRole) == false then
		local pos = mapLayer.GetRowAttackPos(targetRole.logicInfo.posindex)
		self.attackerRole:MoveToPosition(pos.x, pos.y)
	elseif self.skillDisplayInfo.needMoveCenter then
		self.attackerRole:MoveToPosition(GameConfig.WS.width/2, GameConfig.WS.height/2-100)
	else
		self:ShowAttackAnim()
	end
end

function BattleAction:ShowAttackAnim()
	self.attackerRole:PlayAttackAnim(self.bNormalAttack, self.skillDisplayInfo.attackAnim)
	
	self:ShowAttackerText()

	self:ShowXuliEff()

	self:ShowAttackEff()

	self:PlayAttackSound()

	self:ShowQianKunDaNuoYi()
	self:ShowAllHit()
	self:ShowSpecilEffect()

end

function BattleAction:isSkillAction()
	return self.actionInfo.skill[1].skillId ~= 0
end
function BattleAction:ShowAttackerText()
	if self.actionInfo.type == 3 and not self:isSkillAction() then
		self.attackerRole:ShowFightText("fanji", 0)
	elseif self.actionInfo.target[1].activeEffect and self.actionInfo.target[1].activeEffect[1].type == 8 then
		self.attackerRole:ShowFightText("ceji", 0)
	end
end

function BattleAction:ShowXuliEff()
	local skillDisplay = self.skillDisplayInfo
	local xuliEffID = skillDisplay.xuliEff
	if xuliEffID == nil or xuliEffID == 0 then
		return
	end

	local effStartTime = skillDisplay.xuliEffTime
	if effStartTime ~= nil and effStartTime > 0 then
		self.xuliEffTimerID = TFDirector:addTimer(effStartTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(self.xuliEffTimerID)
			self.xuliEffTimerID = nil
			self.attackerRole:PlaySkillEffect(xuliEffID, 0, skillDisplay.xuliEffOffsetX, skillDisplay.xuliEffOffsetY)
		end)
	else
		self.attackerRole:PlaySkillEffect(xuliEffID, 0, skillDisplay.xuliEffOffsetX, skillDisplay.xuliEffOffsetY)
	end
end

function BattleAction:ShowAttackEff()
	local skillDisplay = self.skillDisplayInfo
	local attackList = skillDisplay.attackEff
	if attackList == nil or #attackList == 0 then
		return
	end
	for i=1,#attackList do
		self:_ShowAttackEff(i)
	end
end

function BattleAction:_ShowAttackEff(index)
	local skillDisplay = self.skillDisplayInfo
	local attackEffID = skillDisplay.attackEff[index]
	if attackEffID == 0 then
		return
	end
	local effStartTime = 0--skillDisplay.attackEffTime[index] or skillDisplay.attackEffTime[1]
	if skillDisplay.attackEffTime then
		effStartTime = skillDisplay.attackEffTime[index] or skillDisplay.attackEffTime[1]
	end
	if effStartTime ~= nil and effStartTime > 0 then
		self.attackEffTimerID = self.attackEffTimerID or {}
		self.attackEffTimerID[index] = TFDirector:addTimer(effStartTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(self.attackEffTimerID[index])
			self.attackEffTimerID[index] = nil
			local nTargetCount = #self.actionInfo.target
			local attackEffType = skillDisplay.attackEffType[index] or skillDisplay.attackEffType[1]
			if attackEffType ~= 4 then
				nTargetCount = 1
			end

			
			local attackEffOffsetX = 0
			if skillDisplay.attackEffOffsetX then
				attackEffOffsetX = skillDisplay.attackEffOffsetX[index] or skillDisplay.attackEffOffsetX[1]
			end

			local attackEffOffsetY = 0
			if skillDisplay.attackEffOffsetY then
				attackEffOffsetY = skillDisplay.attackEffOffsetY[index] or skillDisplay.attackEffOffsetY[1]
			end

			local flyEffRotate = skillDisplay.flyEffRotate

			for i=1,nTargetCount do
				local targetInfo = self.actionInfo.target[i]
				local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)
				self.attackerRole:PlaySkillEffect(attackEffID, attackEffType,attackEffOffsetX, attackEffOffsetY,1,targetRole, flyEffRotate)
			end
		end)
	else
		local nTargetCount = #self.actionInfo.target
		local attackEffType = skillDisplay.attackEffType[index] or skillDisplay.attackEffType[1]
		if attackEffType ~= 4 then
			nTargetCount = 1
		end

		
		local attackEffOffsetX = 0
		if skillDisplay.attackEffOffsetX then
			attackEffOffsetX = skillDisplay.attackEffOffsetX[index] or skillDisplay.attackEffOffsetX[1]
		end

		local attackEffOffsetY = 0
		if skillDisplay.attackEffOffsetY then
			attackEffOffsetY = skillDisplay.attackEffOffsetY[index] or skillDisplay.attackEffOffsetY[1]
		end

		local flyEffRotate = skillDisplay.flyEffRotate
		
		for i=1,nTargetCount do
			local targetInfo = self.actionInfo.target[i]
			local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)
			self.attackerRole:PlaySkillEffect(attackEffID, attackEffType,attackEffOffsetX, attackEffOffsetY,1,targetRole, flyEffRotate)
		end
	end
end

function BattleAction:PlayAttackSound()
	local skillDisplay = self.skillDisplayInfo
	local attackSoundID = skillDisplay.attackSound
	if attackSoundID == nil or attackSoundID == 0 then
		return
	end

	local soundFile = "sound/skill/"..attackSoundID..".mp3"
	local soundStartTime = skillDisplay.attackSoundTime
	if soundStartTime ~= nil and soundStartTime > 0 then
		self.attackSoundTimerID = TFDirector:addTimer(soundStartTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(self.attackSoundTimerID)
			self.attackSoundTimerID = nil
			TFAudio.playEffect(soundFile, false)
		end)
	else
		TFAudio.playEffect(soundFile, false)
	end
end

function BattleAction:PlayHitSound(hitIndex)
	local skillDisplay = self.skillDisplayInfo
	local hitSoundID = skillDisplay.hitSound
	if hitSoundID == nil or hitSoundID == 0 then
		return
	end
	local dieSound = nil
	if self.bEnemyAllDie and hitIndex == self.hitCount then
		if hitSoundID >= 11 and hitSoundID <= 15 then
			dieSound = "sound/skill/1_die.mp3"
		elseif hitSoundID >= 21 and hitSoundID <= 23 then
			dieSound = "sound/skill/2_die.mp3"
		elseif hitSoundID >= 31 and hitSoundID <= 33 then
			dieSound = "sound/skill/3_die.mp3"
		elseif hitSoundID >= 41 and hitSoundID <= 43 then
			dieSound = "sound/skill/4_die.mp3"
		end
	end

	local soundFile = "sound/skill/"..hitSoundID..".mp3"
	local soundStartTime = skillDisplay.hitSoundTime
	if soundStartTime ~= nil and soundStartTime > 0 then
		self.hitSoundTimerID = TFDirector:addTimer(soundStartTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(self.hitSoundTimerID)
			self.hitSoundTimerID = nil
			TFAudio.playEffect(soundFile, false)
			if dieSound ~= nil then
				TFAudio.playEffect(dieSound, false)
			end
		end)
	else
		TFAudio.playEffect(soundFile, false)
		if dieSound ~= nil then
			TFAudio.playEffect(dieSound, false)
		end
	end
end




function BattleAction:showHitXuliEff()
	local skillDisplay = self.skillDisplayInfo
	local hitXuliEffID = skillDisplay.hitXuliEff
	if hitXuliEffID == nil or hitXuliEffID == 0 then
		self:ShowAllHit()
		return
	end

	local effStartTime = skillDisplay.hitXuliEffTimeDelay

	if effStartTime ~= nil and effStartTime > 0 then
		self.hitXuliEffTimerID = TFDirector:addTimer(effStartTime, 1, nil,
		function()
			TFDirector:removeTimer(self.hitXuliEffTimerID )
			self.hitXuliEffTimerID = nil
			self:_showHitXuliEff()
		end)
	else
		self:_showHitXuliEff()
	end
end
function BattleAction:_showHitXuliEff()

	local skillDisplay = self.skillDisplayInfo
	local hitXuliEffID = skillDisplay.hitXuliEff

	local hitXuliEffType = skillDisplay.hitXuliEffType or 0
	local effStartTime = skillDisplay.hitXuliEffTime


	 --0攻击者身上播放 1屏幕中心播放 2打横排 3直线飞行单体 4直线飞行竖排 5攻击者脚下播放 6我方阵容中心播放 7敌方阵容中心播放 8屏幕中心置顶 9我方阵容中心置顶播放 10敌方阵容中心置顶播放 
	if hitXuliEffType == 0 or hitXuliEffType == 5 then
		local nTargetCount = #self.actionInfo.targetlist
		for i=1,nTargetCount do
			local targetInfo = self.actionInfo.targetlist[i]
			local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)

			if targetRole ~= nil then
				targetRole:PlaySkillEffect(hitXuliEffID, hitXuliEffType, skillDisplay.hitXuliEffOffsetX, skillDisplay.hitXuliEffOffsetY)
			else
				assert(false, "targetpos" .. targetInfo.targetpos .. "not find")
			end
		end
	else
		local targetInfo = self.actionInfo.targetlist[1]
		local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
		if targetRole ~= nil then
			targetRole:PlaySkillEffect(hitXuliEffID, hitXuliEffType, skillDisplay.hitXuliEffOffsetX, skillDisplay.hitXuliEffOffsetY)
		else
			assert(false, "targetpos" .. targetInfo.targetpos .. "not find")
		end
	end
	self:ShowAllHit()
end



function BattleAction:ShowAllHit()
	self:GetHitNumber()

	-- for i=1, self.hitCount do
	-- 	local hitTime = self.skillDisplayInfo["hitAnimTime"..i]
	-- 	if hitTime ~= nil and hitTime >= 0 then
	-- 		if hitTime > 0 then
	-- 			local hitTimerID = TFDirector:addTimer(hitTime / FightManager.fightSpeed, 1, nil, 
	-- 			function()
	-- 				print("self:ShowHit(i) ====111")
	-- 				TFDirector:removeTimer(hitTimerID)
	-- 				hitTimerID = nil
	-- 				self:ShowHit(i)
	-- 				self:PlayHitSound(i)
	-- 			end)

	-- 			self.hitTimerIDList:push(hitTimerID)
	-- 		else
	-- 			print("self:ShowHit(i) ====222")
	-- 			self:ShowHit(i)
	-- 			self:PlayHitSound(i)
	-- 		end
	-- 	end
	-- end

	local temp_num = 1
	function showhitDisplay()
		if temp_num > self.hitCount then
			return
		end
		local oldtime = 0
		if temp_num ~= 1 then
			oldtime = self.skillDisplayInfo["hitAnimTime"..(temp_num-1)] or 0
		end
		local hitTime = self.skillDisplayInfo["hitAnimTime"..temp_num] or 0
		local  temp_time = hitTime - oldtime
		if temp_time ~= nil and temp_time >= 0 then
			if temp_time > 0 then
				self.hitTimerID = TFDirector:addTimer(temp_time / FightManager.fightSpeed, 1, nil,
				function()
					TFDirector:removeTimer(self.hitTimerID)
					if temp_num > self.hitCount then
						return
					end
					self.hitTimerID = nil
					self:ShowHit(temp_num)
					self:PlayHitSound(temp_num)
					temp_num = temp_num + 1
					showhitDisplay()
				end)
			else
				if temp_num > self.hitCount then
					return
				end
				self:ShowHit(temp_num)
				self:PlayHitSound(temp_num)
				temp_num = temp_num + 1
				showhitDisplay()
			end
		end
	end
	showhitDisplay()
end

function BattleAction:GetHitCount()
	self.hitCount = 0
	local nMaxHitCount = 10
	for i=1,nMaxHitCount do
		local hitTime = self.skillDisplayInfo["hitAnimTime"..i]
		if hitTime ~= nil and hitTime >= 0 then
			if i > 1 then
				local preTime = self.skillDisplayInfo["hitAnimTime"..i-1]
				if hitTime <= preTime then
					assert(false)
					break
				end
			end

			self.hitCount = self.hitCount + 1
		end
	end
	print("self.hitCount",self.hitCount)
end

function BattleAction:GetHitNumber()
	self:GetHitCount()

	local hurtCount = self.hitCount
	if hurtCount == 0 then
		assert(false)
		return
	end

	local nTargetCount = #self.actionInfo.target
	for i=1,nTargetCount do
		local totalHurt = self.actionInfo.target[i].effectValue
		local singleHurt = math.floor(totalHurt/hurtCount)

		self.actionInfo.target[i].hurtList = {}
		if hurtCount == 1 then
			self.actionInfo.target[i].hurtList[1] = totalHurt
		else
			local nHurtLeft = totalHurt
			for j=1,hurtCount-1 do
				self.actionInfo.target[i].hurtList[j] = math.floor(math.random(singleHurt*0.8, singleHurt))
				nHurtLeft = nHurtLeft - self.actionInfo.target[i].hurtList[j]
			end

			if totalHurt < 0 and nHurtLeft > 0 then
				nHurtLeft = 0 
			end

			self.actionInfo.target[i].hurtList[hurtCount] = nHurtLeft
		end
	end
end

function BattleAction:ShowHitEff(targetRole, targetIndex)
	if targetRole == nil then
		return
	end
	local hitEffList = self.skillDisplayInfo.hitEff
	if hitEffList == nil or #hitEffList == 0 then
		return
	end
	for i=1,#hitEffList do
		self:_ShowHitEff(targetRole,i)
	end
end

function BattleAction:_ShowHitEff(targetRole,index )
	local skillDisplay = self.skillDisplayInfo
	local hitEffID = skillDisplay.hitEff[index]
	if hitEffID == 0 then
		return
	end
	local effStartTime = 0
	if skillDisplay.hitEffTime then
		effStartTime = skillDisplay.hitEffTime[index] or skillDisplay.hitEffTime[1]
	end

	local hitEffType = 0
	if skillDisplay.hitEffType then
		hitEffType = skillDisplay.hitEffType[index] or skillDisplay.hitEffType[1]
	end
	local hitEffOffsetX = 0
	if skillDisplay.hitEffOffsetX then
		hitEffOffsetX = skillDisplay.hitEffOffsetX[index] or skillDisplay.hitEffOffsetX[1]
	end
	local hitEffOffsetY = 0
	if skillDisplay.hitEffOffsetY then
		hitEffOffsetY = skillDisplay.hitEffOffsetY[index] or skillDisplay.hitEffOffsetY[1]
	end

	local effectScale = 1
	if skillDisplay.effectScale then
		effectScale = skillDisplay.effectScale[targetIndex] or skillDisplay.effectScale[1]
	end
	if effStartTime ~= nil and effStartTime > 0 then
		local effTimerID = TFDirector:addTimer(effStartTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(effTimerID)
			effTimerID = nil

			targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)
		end)
		self.hitEffTimerIDList:push(effTimerID)
	else
		targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)
	end
end


function BattleAction:ShowHit(hitIndex)
	self.hitAnimCompleteRoleNum = 0

	local bLastHit = (hitIndex == self.hitCount)

	if self.bEnemyAllDie and bLastHit then
		if self.skillDisplayInfo.remote == 0 then
			TFDirector:currentScene():ZoomIn(self.attackerRole)
		end
		battleRoleMgr:SetAllRoleSpeed(0.5)
		TFDirector:currentScene().fightUiLayer:PlayFightEndEffect()
	end

	-- print("hitIndex",hitIndex)
	-- print("actionInfo",self.actionInfo)
	local nTargetCount = #self.actionInfo.target
	for i=1,nTargetCount do
		local targetInfo = self.actionInfo.target[i]
		local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)

		if targetInfo.effectType == 1 or targetInfo.effectType == 2 or targetInfo.effectType == 7 then --普通受击和暴击 7:主动加buff
			local fightText = ""
			if targetInfo.effectType == 2 then
				fightText = "baoji"
			end
			local bBezier = false
			if targetInfo.hurtList[hitIndex] < 0 and fightText ~= "baoji" then
				bBezier = true
			end
			targetRole:ShowFightText(fightText, targetInfo.hurtList[hitIndex], false, false, bBezier)
			
			if hitIndex > 1 and self.skillDisplayInfo.hitEffShowOnce then
			else
				self:ShowHitEff(targetRole, i)
			end
			if hitIndex == 1 and targetInfo.hurtList[hitIndex] < 0 then
				targetRole:RemoveFrozenBuff()
			end

			if bLastHit then
				if targetInfo.newState then
					for i=1,#targetInfo.newState do
						targetRole:AddBuff(targetInfo.newState[i].stateId,targetInfo.newState[i].stateLevel,0)
					end
				end
				self:targetRemoveBuffer(targetInfo)
				self:ShowPassiveEffect(targetInfo)
			end

			if hitIndex == 1 then
				self:ShowActiveEffect(targetInfo)

				if targetInfo.effectValue < 0 then
					targetRole:AddCommonAnger(ConstantData:getValue("Fight.HitAnger"))
					if i == 1 then
						if self.bNormalAttack then
							if targetRole:IsLive() then
								self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.AttackAnger"))
							else
								self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.AttackDieAnger"))
							end
						else
							if targetRole:IsLive() then
								self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.SkillAttackAnger"))
							else
								self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.SkillAttackDieAnger"))
							end
						end
					end
				end
			end

			if targetInfo.effectValue < 0 and not self.bNormalAttack and not self.attackerRole.logicInfo.bEnemyRole then
				if self.skillDisplayInfo.id == 2740100 then
					TFDirector:currentScene().mapLayer:Shake(10,10)
				else
					if self.skillDisplayInfo.remote == 0 then
						TFDirector:currentScene().mapLayer:Shake(6,6)
					else
						TFDirector:currentScene().mapLayer:Shake(3,3)
					end
				end
			end

			if targetInfo.hurtList[hitIndex] < 0 then
				targetRole:PlayHitAnim(bLastHit)
			else
				if bLastHit then
					self:OnRoleHitAnimComplete()
				end
			end

		elseif targetInfo.effectType == 3 then --闪避
			if hitIndex == 1 then
				targetRole:ShowFightText("shanbi", 0)
				if self.actionInfo.type ~= 3 then
					targetRole:DoAvoidAction()
				end
			end

			if bLastHit then
				self:targetRemoveBuffer(targetInfo)
				self:OnRoleHitAnimComplete()
			end

		elseif targetInfo.effectType == 4 then --治疗加血
			targetRole:ShowFightText("", math.abs(targetInfo.hurtList[hitIndex]))
			self:ShowHitEff(targetRole, i)

			if hitIndex == 1 then
				self:ShowActiveEffect(targetInfo)
			end

			if bLastHit then
				if targetInfo.newState then
					for i=1,#targetInfo.newState do
						targetRole:AddBuff(targetInfo.newState[i].stateId,targetInfo.newState[i].stateLevel,0)
					end
				end
				
				self:targetRemoveBuffer(targetInfo)
				self:OnRoleHitAnimComplete()
			end

		elseif targetInfo.effectType == 5 then --净化，去除目标所有减益buff
			self:ShowHitEff(targetRole, i)
			if hitIndex == 1 then
				targetRole:CleanBuff(self.attackerRole)
				self:ShowActiveEffect(targetInfo)
			end

			if bLastHit then
				self:targetRemoveBuffer(targetInfo)
				self:OnRoleHitAnimComplete()
			end

		elseif targetInfo.effectType == 6 then --斗转星移
			if hitIndex == 1 then
				targetRole:ShowFightText("shanbi", 0)
				targetRole:DoAvoidAction()
			end

			if bLastHit then
				self:targetRemoveBuffer(targetInfo)
				self:OnRoleHitAnimComplete()
			end
		elseif targetInfo.effectType == 8 then --斗转星移
			self:ShowExtraBuffEff(targetRole, i)
			if bLastHit then
				if targetInfo.newState then
					for i=1,#targetInfo.newState do
						targetRole:AddBuff(targetInfo.newState[i].stateId,targetInfo.newState[i].stateLevel,0)
					end
				end
				self:targetRemoveBuffer(targetInfo)
				self:OnRoleHitAnimComplete()
			end
		end
	end
end



function BattleAction:ShowExtraBuffEff(targetRole, targetIndex)
	if targetRole == nil then
		return
	end
	if self.skillDisplayInfo.extraShowHit then
		self:ShowHitEff(targetRole, targetIndex)
		return
	end

	local extraEffList = self.skillDisplayInfo.extraEff
	if extraEffList == nil or #extraEffList == 0 then
		return
	end
	for i=1,#extraEffList do
		self:_ShowExtraEff(targetRole,i)
	end
end

function BattleAction:_ShowExtraEff(targetRole,index )
	local skillDisplay = self.skillDisplayInfo
	local extraEffID = skillDisplay.extraEff[index]
	if extraEffID == 0 then
		return
	end
	local effStartTime = 0
	if skillDisplay.extraEffTime then
		effStartTime = skillDisplay.extraEffTime[index] or skillDisplay.extraEffTime[1]
	end

	local extraEffType = 0
	if skillDisplay.extraEffType then
		extraEffType = skillDisplay.extraEffType[index] or skillDisplay.extraEffType[1]
	end
	local extraEffOffsetX = 0
	if skillDisplay.extraEffOffsetX then
		extraEffOffsetX = skillDisplay.extraEffOffsetX[index] or skillDisplay.extraEffOffsetX[1]
	end
	local extraEffOffsetY = 0
	if skillDisplay.extraEffOffsetY then
		extraEffOffsetY = skillDisplay.extraEffOffsetY[index] or skillDisplay.extraEffOffsetY[1]
	end

	if effStartTime ~= nil and effStartTime > 0 then
		local effTimerID = TFDirector:addTimer(effStartTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(effTimerID)
			effTimerID = nil

			targetRole:PlaySkillEffect(extraEffID, extraEffType, extraEffOffsetX, extraEffOffsetY)
		end)
		self.extraEffTimerIDList:push(effTimerID)
	else
		targetRole:PlaySkillEffect(extraEffID, extraEffType, extraEffOffsetX, extraEffOffsetY)
	end
end




function BattleAction:targetRemoveBuffer(targetInfo )
	if targetInfo.lostState then
		for i=1,#targetInfo.lostState do
			local state = targetInfo.lostState[i]
			local target = battleRoleMgr:GetRoleByGirdIndex(state.position)
			if target and state.repeatNum == 0 then
				print(target.logicInfo.name.."移除buff"..state.stateId)
				target:RemoveBuffById(state.stateId)
			end
		end
	end
end

--被动效果:反弹5 反击6 化解7 复活9 免疫12 受击加血50 表现
function BattleAction:ShowPassiveEffect(targetInfo)
	local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)
	if targetRole == nil then
		return
	end
	if targetInfo.passiveEffect == nil then
		return
	end
	local effect = targetInfo.passiveEffect[1].type
	local effectValue = targetInfo.passiveEffect[1].value
	if effect == 5 then
		self.attackerRole:ShowFightText("", effectValue)
		self.attackerRole:ShowEffectName("fantan")
	elseif effect == 6 and self.actionInfo.skill[1].skillId == 0 then
		self.hasTrrigerBackAttack = true
	elseif effect == 7 then
		targetRole:ShowEffectName("huajie")
	elseif effect == 9 then 	
		--这里校验是否真的复活
		--modify by wkdai
		print("========================================你麻痹复活啊")
		targetRole:ReLive(effectValue)
	elseif effect == 12 then
		targetRole:ShowEffectName("mianyi")
	elseif effect == 50 then
		if targetRole:IsLive() then
			targetRole:ShowFightText("", effectValue)
		end
	end
end

--主动效果:吸怒1 减敌怒2 增己怒3 吸血4 侧击8 净化10 致死11 七伤拳21 表现
function BattleAction:ShowActiveEffect(targetInfo)
	local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)
	if targetRole == nil then
		return
	end
	if targetInfo.activeEffect == nil then
		return
	end
	local effect = targetInfo.activeEffect[1].type
	local effectValue = targetInfo.activeEffect[1].value
	if effect == 1 then
		battleRoleMgr:AddAnger(targetRole.logicInfo.bEnemyRole, -effectValue)
		battleRoleMgr:AddAnger(self.attackerRole.logicInfo.bEnemyRole, effectValue)
		self.attackerRole:ShowEffectName("xinu")
		if not self.attackerRole.logicInfo.bEnemyRole then
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(0)
		else
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(1)
		end
	elseif effect == 2 then
		battleRoleMgr:AddAnger(targetRole.logicInfo.bEnemyRole, -effectValue)
		targetRole:ShowEffectName("jiannu")
		if not self.attackerRole.logicInfo.bEnemyRole then
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(1)
		end
	elseif effect == 3 then
		battleRoleMgr:AddAnger(self.attackerRole.logicInfo.bEnemyRole, effectValue)
		self.attackerRole:ShowEffectName("jianu")
		if not self.attackerRole.logicInfo.bEnemyRole then
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(2)
		end
	elseif effect == 4 then
		self.attackerRole:ShowFightText("", effectValue)
		self.attackerRole:ShowEffectName("xixue")
	elseif effect == 10 then
	elseif effect == 11 then
		targetRole:ShowEffectName("zhisi")
	elseif effect == 14 then
		targetRole:ShowEffectName("zhongji")
	elseif effect == 21 then
		self.attackerRole:ShowFightText("", effectValue)
	end
	--伤害加深不可以占用主动效果，使用新增的deepHurtType字段判定
	-- elseif effect == 101 then
	-- 	targetRole:ShowEffectName("zhongdubaoji")
	-- elseif effect == 102 then
	-- 	targetRole:ShowEffectName("zhuoshaobaoji")
	-- elseif effect == 103 then
	-- 	targetRole:ShowEffectName("pozhanbaoji")
	-- elseif effect == 104 then
	-- 	targetRole:ShowEffectName("xuruobaoji")
	-- elseif effect == 105 then
	-- 	targetRole:ShowEffectName("zhongshangbaoji")
	-- elseif effect == 106 then
	-- 	targetRole:ShowEffectName("chihuanbaoji")
	-- elseif effect == 107 then
	-- 	targetRole:ShowEffectName("shimingbaoji")
	-- elseif effect == 110 then
	-- 	targetRole:ShowEffectName("hunluanbaoji")
	-- elseif effect == 111 then
	-- 	targetRole:ShowEffectName("sangongbaoji")
	-- elseif effect == 112 then
	-- 	targetRole:ShowEffectName("dianxunbaoji")
	-- elseif effect == 113 then
	-- 	targetRole:ShowEffectName("xuanyunbaoji")
	-- elseif effect == 115 then
	-- 	targetRole:ShowEffectName("hunshuibaoji")
	-- end
	local deepHurtType = targetInfo.deepHurt.type
	if deepHurtType then
		if deepHurtType == 1 then
			targetRole:ShowEffectName("zhongdubaoji")
		elseif deepHurtType == 2 then
			targetRole:ShowEffectName("zhuoshaobaoji")
		elseif deepHurtType == 3 then
			targetRole:ShowEffectName("pozhanbaoji")
		elseif deepHurtType == 4 then
			targetRole:ShowEffectName("xuruobaoji")
		elseif deepHurtType == 5 then
			targetRole:ShowEffectName("zhongshangbaoji")
		elseif deepHurtType == 6 then
			targetRole:ShowEffectName("chihuanbaoji")
		elseif deepHurtType == 7 then
			targetRole:ShowEffectName("shimingbaoji")
		elseif deepHurtType == 10 then
			targetRole:ShowEffectName("hunluanbaoji")
		elseif deepHurtType == 11 then
			targetRole:ShowEffectName("sangongbaoji")
		elseif deepHurtType == 12 then
			targetRole:ShowEffectName("dianxunbaoji")
		elseif deepHurtType == 13 then
			targetRole:ShowEffectName("xuanyunbaoji")
		elseif deepHurtType == 15 then
			targetRole:ShowEffectName("hunshuibaoji")
		elseif deepHurtType == 16 then
			targetRole:ShowEffectName("diluobaoji")
		elseif deepHurtType == 37 then
			targetRole:ShowEffectName("danqiebaoji")
		elseif deepHurtType == 34 then
			targetRole:ShowEffectName("suodingbaoji")
		elseif deepHurtType == 50 then
			targetRole:ShowEffectName("liuxuebaoji")
		end
	end
end

function BattleAction:OnRoleHitAnimComplete()
	if self.hitAnimCompleteRoleNum == nil then
		return
	end

	local targetNum = #self.actionInfo.target
	self.hitAnimCompleteRoleNum = self.hitAnimCompleteRoleNum + 1
	if self.hitAnimCompleteRoleNum == targetNum then
		self.hitAnimCompleteRoleNum = nil

		if self.actionInfo.type == 3 then
			local targetInfo = self.actionInfo.target[1]
			local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)
			print("=====谁要回去====")
			if self.attackerRole:IsLive() then
				self.attackerRole:_ReturnBack()
			end

			if targetRole ~= nil and targetRole:isNeedBack() then
				print(targetRole.logicInfo.name .."赶紧滚回去11")
				if targetRole:IsLive() then
					targetRole:ReturnBack()
				else
					FightManager:OnActionEnd()
				end
			-- elseif self.attackerRole:isNeedBack() then
			-- 	print(self.attackerRole.logicInfo.name .."赶紧滚回去222")
			-- 	if self.attackerRole:IsLive() then
			-- 		self.attackerRole:ReturnBack()
			-- 	else
			-- 		FightManager:OnActionEnd()
			-- 	end
			else
				FightManager:OnActionEnd()
			end
		else
			if self.attackerRole:IsLive() then
				if self.attackerRole.attackAnimEnd then
					self.attackerRole:ReturnBack()
				else
					self.attackerRole.needReturnBack = true
				end
			else
				FightManager:OnActionEnd()
			end
		end
	end
end

function BattleAction:AddBuffToTarget(targetRole, bufferID, level, hurt)
	if not targetRole:IsLive() then
		return 
	end

	if bufferID > 0 then
		targetRole:AddBuff(bufferID, level,hurt)
	end
end

function BattleAction:GetTargetRole(index)
	if self.actionInfo.target == nil then
		return nil
	end


	local targetInfo = self.actionInfo.target[index]
	if targetInfo == nil then
		return nil
	end

	local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)
	return targetRole
end

function BattleAction:ShowSpecilEffect()
end
function BattleAction:ShowQianKunDaNuoYi()
	local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skill[1])
	local skillInfo = SkillLevelData:objectByID(self.actionInfo.skill[1])
	if skillBaseInfo == nil or skillInfo == nil then
		return
	end

	if skillBaseInfo.effect == 20 then
		-- self.specilTimerID =  TFDirector:addTimer(3000 / FightManager.fightSpeed, 1, nil,
		-- function()
			local liveList = battleRoleMgr:GetAllLiveRole(self.attackerRole.logicInfo.bEnemyRole)
			local liveNum = liveList:length()
			for i=1,liveNum do
				local role = liveList:objectAt(i)
				role:ShowFightText("", skillInfo.effect_value)
			end
			-- TFDirector:removeTimer(self.specilTimerID)
			-- self.specilTimerID = nil
		-- end)
	end
end

function BattleAction:addBuffer( beforAction )
	if self.actionInfo.newState == nil then
		return
	end

	for i=1,#self.actionInfo.newState  do
		local state = self.actionInfo.newState[i]
		local buffInfo = SkillBufferData:objectByID(state.stateId)
		if buffInfo ~= nil and buffInfo.gain_type == beforAction then
			self.attackerRole:AddBuff(state.stateId,state.stateLevel,0)
		end
	end
end
function BattleAction:removeBuffer()
	if self.actionInfo.lostState == nil then
		return
	end

	for i=1,#self.actionInfo.lostState  do
		local state = self.actionInfo.lostState[i]
		local target = battleRoleMgr:GetRoleByGirdIndex(state.position)
		if target and state.repeatNum == 0 then
			target:RemoveBuffById(state.stateId)
		end
	end
end

function BattleAction:stateCycleUpdate()
	local showTable = {}

	if self.actionInfo.stateCycle then
		for i=1,#self.actionInfo.stateCycle do
			local stateCycleEffect = self.actionInfo.stateCycle[i]
			local targetRole = battleRoleMgr:GetRoleByGirdIndex(stateCycleEffect.position)
			if targetRole then
				local hurt = targetRole:ShowHpChangeBuff(stateCycleEffect)
				showTable[stateCycleEffect.position] = showTable[stateCycleEffect.position] or 0
				showTable[stateCycleEffect.position] = showTable[stateCycleEffect.position] + hurt
			end
		end
	end

	if self.actionInfo.target  then
		for i=1,#self.actionInfo.target  do
			local target = self.actionInfo.target[i]
			if target.stateCycle then
				for j=1,#target.stateCycle do
					local stateCycleEffect = target.stateCycle[j]
					local targetRole = battleRoleMgr:GetRoleByGirdIndex(stateCycleEffect.position)
					if targetRole then
						local hurt = targetRole:ShowHpChangeBuff(stateCycleEffect)
						showTable[stateCycleEffect.position] = showTable[stateCycleEffect.position] or 0
						showTable[stateCycleEffect.position] = showTable[stateCycleEffect.position] + hurt
					end
				end
			end
		end
	end
	for k,v in pairs(showTable) do
		local targetRole = battleRoleMgr:GetRoleByGirdIndex(k)
		if targetRole then
			targetRole:ShowFightText("", v)
		end
	end
end

function BattleAction:pause()
	if self.xuliEffTimerID then
		TFDirector:stopTimer(self.xuliEffTimerID)
	end
	if self.attackEffTimerID then
		for k,v in pairs(self.attackEffTimerID) do
			TFDirector:stopTimer(v)
		end
	end
	if self.hitTimerID then
		TFDirector:stopTimer(self.hitTimerID)
	end
	if self.attackSoundTimerID then
		TFDirector:stopTimer(self.attackSoundTimerID)
	end
	if self.hitSoundTimerID then
		TFDirector:stopTimer(self.hitSoundTimerID)
	end
	if self.hitSoundTimerID then
		TFDirector:stopTimer(self.hitSoundTimerID)
	end
	local hitEffTimerNum = self.hitEffTimerIDList:length()
	for i=1,hitEffTimerNum do
		if self.hitEffTimerIDList:objectAt(i) then
			TFDirector:stopTimer(self.hitEffTimerIDList:objectAt(i))
		end
	end
	local extraEffTimerNum = self.extraEffTimerIDList:length()
	for i=1,extraEffTimerNum do
		if self.extraEffTimerIDList:objectAt(i) then
			TFDirector:stopTimer(self.extraEffTimerIDList:objectAt(i))
		end
	end
end

function BattleAction:resume()
	if self.xuliEffTimerID then
		TFDirector:startTimer(self.xuliEffTimerID)
	end
	if self.attackEffTimerID then
		for k,v in pairs(self.attackEffTimerID) do
			TFDirector:startTimer(v)
		end
	end
	if self.hitTimerID then
		TFDirector:startTimer(self.hitTimerID)
	end
	if self.attackSoundTimerID then
		TFDirector:startTimer(self.attackSoundTimerID)
	end
	if self.hitSoundTimerID then
		TFDirector:startTimer(self.hitSoundTimerID)
	end
	local hitEffTimerNum = self.hitEffTimerIDList:length()
	for i=1,hitEffTimerNum do
		if self.hitEffTimerIDList:objectAt(i) then
			TFDirector:startTimer(self.hitEffTimerIDList:objectAt(i))
		end
	end
	local extraEffTimerNum = self.extraEffTimerIDList:length()
	for i=1,extraEffTimerNum do
		if self.extraEffTimerIDList:objectAt(i) then
			TFDirector:startTimer(self.extraEffTimerIDList:objectAt(i))
		end
	end
end

return BattleAction
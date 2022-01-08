--
-- Author: Zippo
-- Date: 2013-12-05 20:02:30
--

local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")
local fightRoundMgr  = require("lua.logic.fight.FightRoundManager")
local mapLayer  = require("lua.logic.fight.MapLayer")

local FightAction = class("FightAction")

function FightAction:ctor(actionInfo)
	self.actionInfo = actionInfo
	self.attackerRole = fightRoleMgr:GetRoleByGirdIndex(actionInfo.attackerpos)
	assert(self.attackerRole, "attackerpos" .. actionInfo.attackerpos .. "not find")

	self.triggerType = actionInfo.triggerType

	self.bNormalAttack = false
	local skillDisplayID = 0
	if actionInfo.skillid.skillId == 0 then -- 普通攻击
		skillDisplayID = self.attackerRole.normalAttackSkillID
		self.bNormalAttack = true
		local buffDisplayID = self:GetBuffDisplayId()
		if buffDisplayID ~= 0 then
			skillDisplayID = buffDisplayID
		end
	end

	local skillInfo = BaseDataManager:GetSkillBaseInfo(actionInfo.skillid)
	if skillInfo ~= nil and skillInfo.target_type == 3 then -- 横排技能
		self.bRowAttack = true
	else
		self.bRowAttack = false
	end

	if skillInfo ~= nil then
		skillDisplayID = skillInfo.display_id
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
	self.bEnemyAllDie = self:IsEnemyAllDie()
	if self.actionInfo.buffList and #self.actionInfo.buffList > 0 then
		for i=1,#self.actionInfo.buffList do
			local buff = self.actionInfo.buffList[i]
			local buffInfo = SkillBufferData:objectByID(buff[6])
			if buff  and buffInfo  and buffInfo.gain_type == 1 then
				local targetRole = fightRoleMgr:GetRoleByGirdIndex(buff[2])
				self:AddBuffToTarget(targetRole,targetRole,buff[6],buff[7],0)
			end
		end
	end
	self.actionInfo.buffList = {}
end

function FightAction:dispose()
	if self.xuliEffTimerID then
		TFDirector:removeTimer(self.xuliEffTimerID)
		self.xuliEffTimerID = nil
	end
	if self.specilTimerID then
		TFDirector:removeTimer(self.specilTimerID)
		self.specilTimerID = nil
	end
	-- if self.attackEffTimerID then
	-- 	TFDirector:removeTimer(self.attackEffTimerID)
	-- 	self.attackEffTimerID = nil
	-- end
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
	if self.hitXuliEffTimerID  then
		TFDirector:removeTimer(self.hitXuliEffTimerID )
		self.hitXuliEffTimerID  = nil
	end
	if self.attackSoundTimerID then
		TFDirector:removeTimer(self.attackSoundTimerID)
		self.attackSoundTimerID = nil
	end
	if self.hitSoundTimerID then
		TFDirector:removeTimer(self.hitSoundTimerID)
		self.hitSoundTimerID = nil
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

function FightAction:GetBuffDisplayId()
	if self.actionInfo.targetlist == nil or #self.actionInfo.targetlist == 0 then
		return 0
	end

	local targetInfo = self.actionInfo.targetlist[1]
	targetInfo.triggerBufferID = targetInfo.triggerBufferID or 0
	if targetInfo.triggerBufferID > 0 then
		local buffConfig = SkillLevelData:getBuffInfo( targetInfo.triggerBufferID , targetInfo.triggerBufferLevel)
		if buffConfig ~= nil then
			return buffConfig.skill_display
		end
	end

	return 0
end

function FightAction:IsEnemyAllDie()
	if self.attackerRole.logicInfo.bEnemyRole then
		return false
	end


	local liveEnemyList = fightRoleMgr:GetAllLiveRole(true)
	local liveEnemyNum = liveEnemyList:length()
	if self.actionInfo.targetlist == nil then
		return false
	end
	local dieEnemyNum = 0
	local nTargetCount = #self.actionInfo.targetlist
	for i=1,nTargetCount do
		local targetInfo = self.actionInfo.targetlist[i]
		local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
		if targetRole ~= nil and targetRole:IsLive() and  targetRole.logicInfo.bEnemyRole then
			if targetInfo.effect == 1 or targetInfo.effect == 2 then --普通受击和暴击
				local currHp = targetRole.currHp + targetInfo.hurt
				if currHp <= 0 and targetInfo.passiveEffect ~= 9 then
					dieEnemyNum = dieEnemyNum + 1
				end
			end
		end
	end

	if dieEnemyNum >= liveEnemyNum then
		return true
	else
		return false
	end
end

function FightAction:Execute()
	if self.attackerRole == nil or self.attackerRole:IsLive() == false then
		FightManager:OnActionEnd()
		return
	end

	if self.actionInfo.targetlist == nil then
		FightManager:OnActionEnd()
		return
	end

	local nTargetCount = #self.actionInfo.targetlist
	if nTargetCount == 0 then
		FightManager:OnActionEnd()
		return
	end

	local targetRole = fightRoleMgr:GetRoleByGirdIndex(self.actionInfo.targetlist[1].targetpos)
	if targetRole == nil then
		FightManager:OnActionEnd()
		return
	end

	fightRoleMgr:OnActionStart()

	self.attackerRole:OnAttackBuffTrigger()
	if self.bNormalAttack then
		self:BeginAttack()
	else
		self:ShowSkillNameEff()
	end
end

function FightAction:ShowSkillNameEff()
	if not self.attackerRole.logicInfo.bEnemyRole then
		TFDirector:currentScene().mapLayer:ChangeDark(true)
	end
	
	local skillInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skillid)
	if skillInfo ~= nil and skillInfo.name ~= "" then
		-- TFDirector:currentScene().fightUiLayer:ShowSkillName(skillInfo.name, self.attackerRole.logicInfo.bEnemyRole)
		TFDirector:currentScene().mapLayer:playSpellAnimation(skillInfo.name, self.attackerRole.profession)
	end
	TFAudio.playEffect("sound/effect/skill_ready.mp3", false)

	-- 技能反击不播声音(2闪避， 1被击打)
	if not self.triggerType then
		RoleSoundData:playFightSoundByIndex(self.attackerRole.soundRoleId)
	end
	self.attackerRole:PlaySkillNameEffect()
end

function FightAction:AddAttackBuff()
	if self.actionInfo.targetlist == nil then
		return
	end

	for i=1,#self.actionInfo.targetlist do
		local targetInfo = self.actionInfo.targetlist[i]
		local targetRole = self:GetTargetRole(i)
		targetInfo.triggerBufferID = targetInfo.triggerBufferID or 0
		if targetInfo.triggerBufferID > 0 then
			local buffConfig = SkillLevelData:getBuffInfo( targetInfo.triggerBufferID , targetInfo.triggerBufferLevel)
			if buffConfig ~= nil and buffConfig.good_buff == 1 and not fightRoleMgr:IsSameSide({self.attackerRole, targetRole}) then
				if buffConfig.type ~= 56 then
					if self:AddBuffToTarget(self.attackerRole,self.attackerRole, targetInfo.triggerBufferID,targetInfo.triggerBufferLevel) then
						self:AddBuffInfoToServer(self.attackerRole, self.attackerRole, targetInfo.triggerBufferID, 0)
						targetInfo.bHaveAddBuff = true
						break
					end
				end
			end
		end
	end
end

function FightAction:BeginAttack()
	local targetRole = self:GetTargetRole(1)
	self:AddAttackBuff()
	-- Add by zr 20170605 --[
	local movePathType = self.skillDisplayInfo.movePathType
    if movePathType == nil then
    	movePathType = 0
    end
    --]--
	if self.actionInfo.bBackAttack then
		self:ShowAttackAnim()
	elseif self.skillDisplayInfo.remote == 0 then
		self.attackerRole:MoveToRole(targetRole, self.skillDisplayInfo.moveDistance, self.skillDisplayInfo.beforeMoveAnim,movePathType)
	elseif self.bRowAttack then --and self.attackerRole:IsSameRow(targetRole) == false then
		local pos = mapLayer.GetRowAttackPos(targetRole.logicInfo.posindex)
		self.attackerRole:MoveToPosition(pos.x, pos.y,movePathType)
	elseif self.skillDisplayInfo.needMoveCenter then
		self.attackerRole:MoveToPosition(GameConfig.WS.width/2, GameConfig.WS.height/2-100,movePathType)
	else
		self:ShowAttackAnim()
	end
end

function FightAction:ShowAttackAnim()
	print("----------------------ShowAttackAnim->")
	self.attackerRole:PlayAttackAnim(self.bNormalAttack, self.skillDisplayInfo.attackAnim)
	self:skillTrigerAttack()

	self:ShowAttackerText()

	self:ShowXuliEff()

	self:ShowAttackEff()

	self:PlayAttackSound()

	-- self:ShowQianKunDaNuoYi()
	print("----------------------ShowAttackAnim->1111")
	self:showHitXuliEff()
	-- self:ShowAllHit()
	self:ShowSpecilEffect()

end

function FightAction:skillTrigerAttack()
	if not self:isSkillAction() then
		return
	end
	local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skillid)
	if skillBaseInfo == nil then
		return
	end
	if skillBaseInfo.effect_triger and skillBaseInfo.effect_triger ~= "" then
		effect_triger = GetAttrByString(skillBaseInfo.effect_triger)
		print("effect_triger --------------------->",effect_triger)
		if effect_triger then
			local hasTriggerBuf = false
			local nTargetCount = #self.actionInfo.targetlist
			for i=1,nTargetCount do
				if self.actionInfo.targetlist[i].triggerBufferID ~= 0 then
					hasTriggerBuf = true
				end
			end
			print("hasTriggerBuf = ",hasTriggerBuf)
			if effect_triger[3] and effect_triger[3] ~= 0 then
				if hasTriggerBuf ==true then
					fightRoundMgr:SetSkillTrgerSkillAction(self.attackerRole, {skillId = effect_triger[3],level = self.actionInfo.skillid.level},3)
				end
			end
			if effect_triger[4] and effect_triger[4] ~= 0 then
				if hasTriggerBuf == false then
					fightRoundMgr:SetSkillTrgerSkillAction(self.attackerRole, {skillId = effect_triger[4],level = self.actionInfo.skillid.level},4)
				end
			end
		end
	end
end
function FightAction:isSkillAction()
	return self.actionInfo.skillid.skillId ~= 0
end
function FightAction:ShowAttackerText()
	if self.actionInfo.bBackAttack and not self:isSkillAction() then
		self.attackerRole:ShowFightText("fanji", 0)
	elseif self.actionInfo.targetlist[1].activeEffect == 8 then
		self.attackerRole:ShowFightText("ceji", 0)
	end
end

function FightAction:ShowXuliEff()
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

function FightAction:ShowAttackEff()
	local skillDisplay = self.skillDisplayInfo
	local attackList = skillDisplay.attackEff
	if attackList == nil or #attackList == 0 then
		return
	end
	for i=1,#attackList do
		self:_ShowAttackEff(i)
	end
	-- local attackEffID = skillDisplay.attackEff[1]
	-- if attackEffID == 0 then
	-- 	return
	-- end

	-- local effStartTime = skillDisplay.attackEffTime
	-- if effStartTime ~= nil and effStartTime > 0 then
	-- 	self.attackEffTimerID = TFDirector:addTimer(effStartTime / FightManager.fightSpeed, 1, nil, 
	-- 	function() 
	-- 		TFDirector:removeTimer(self.attackEffTimerID)
	-- 		self.attackEffTimerID = nil
	-- 		local nTargetCount = #self.actionInfo.targetlist
	-- 		if skillDisplay.attackEffType ~= 4 then
	-- 			nTargetCount = 1
	-- 		end

	-- 		for i=1,nTargetCount do
	-- 			local targetInfo = self.actionInfo.targetlist[i]
	-- 			local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
	-- 			self.attackerRole:PlaySkillEffect(attackEffID, skillDisplay.attackEffType, 
	-- 											  skillDisplay.attackEffOffsetX, skillDisplay.attackEffOffsetY,
	-- 											  targetRole, skillDisplay.flyEffRotate)
	-- 		end
	-- 	end)
	-- else
	-- 	local nTargetCount = #self.actionInfo.targetlist
	-- 	if skillDisplay.attackEffType ~= 4 then
	-- 		nTargetCount = 1
	-- 	end

	-- 	for i=1,nTargetCount do
	-- 		local targetInfo = self.actionInfo.targetlist[i]
	-- 		local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
	-- 		self.attackerRole:PlaySkillEffect(attackEffID, skillDisplay.attackEffType, 
	-- 										  skillDisplay.attackEffOffsetX, skillDisplay.attackEffOffsetY, 
	-- 										  targetRole, skillDisplay.flyEffRotate)
	-- 	end
	-- end
end

function FightAction:_ShowAttackEff(index)
	local skillDisplay = self.skillDisplayInfo
	local attackEffID = skillDisplay.attackEff[index]
	if attackEffID == 0 then
		return
	end
	local effStartTime = 0
	if skillDisplay.attackEffTime then
		effStartTime = skillDisplay.attackEffTime[index] or skillDisplay.attackEffTime[1]
	end
	if effStartTime ~= nil and effStartTime > 0 then
		self.attackEffTimerID = self.attackEffTimerID or {}
		self.attackEffTimerID[index] = TFDirector:addTimer(effStartTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(self.attackEffTimerID[index])
			self.attackEffTimerID[index] = nil
			local nTargetCount = #self.actionInfo.targetlist
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
				local targetInfo = self.actionInfo.targetlist[i]
				local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
				self.attackerRole:PlaySkillEffect(attackEffID, attackEffType,attackEffOffsetX, attackEffOffsetY,1,targetRole, flyEffRotate)
			end
		end)
	else
		local nTargetCount = #self.actionInfo.targetlist
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
			local targetInfo = self.actionInfo.targetlist[i]
			local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
			self.attackerRole:PlaySkillEffect(attackEffID, attackEffType,attackEffOffsetX, attackEffOffsetY,1,targetRole, flyEffRotate)
		end
	end
end

function FightAction:PlayAttackSound()
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

function FightAction:DelayToPlayHitSound(hitIndex)
	local delayTime = self.skillDisplayInfo["textAnimTime"..hitIndex] or 0
	self.delaySoundTimerID = TFDirector:addTimer(delayTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(self.delaySoundTimerID)
			self.delaySoundTimerID = nil
			self:PlayHitSound(hitIndex)
		end)
end

function FightAction:PlayHitSound(hitIndex)
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

function FightAction:showHitXuliEff()
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
function FightAction:_showHitXuliEff()

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




function FightAction:ShowAllHit()
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
					self.hitTimerID = nil
					self:PlayHitEffect(temp_num)
					self:DelayToShowHit(temp_num)
					self:DelayToPlayHitSound(temp_num)
					temp_num = temp_num + 1
					showhitDisplay()
				end)
			else
				self:PlayHitEffect(temp_num)
				self:DelayToShowHit(temp_num)
				self:DelayToPlayHitSound(temp_num)
				temp_num = temp_num + 1
				showhitDisplay()
			end
		end
	end
	showhitDisplay()
end

function FightAction:GetHitCount()
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
end

function FightAction:GetHitNumber()
	self:GetHitCount()

	local hurtCount = self.hitCount
	if hurtCount == 0 then
		assert(false)
		return
	end

	local nTargetCount = #self.actionInfo.targetlist
	for i=1,nTargetCount do
		local totalHurt = self.actionInfo.targetlist[i].hurt
		local singleHurt = math.floor(totalHurt/hurtCount)

		self.actionInfo.targetlist[i].hurtList = {}
		if hurtCount == 1 then
			self.actionInfo.targetlist[i].hurtList[1] = totalHurt
		else
			local nHurtLeft = totalHurt
			for j=1,hurtCount-1 do
				self.actionInfo.targetlist[i].hurtList[j] = math.floor(math.random(singleHurt*0.8, singleHurt))
				nHurtLeft = nHurtLeft - self.actionInfo.targetlist[i].hurtList[j]
			end

			if totalHurt < 0 and nHurtLeft > 0 then
				nHurtLeft = 0 
			end

			self.actionInfo.targetlist[i].hurtList[hurtCount] = nHurtLeft
		end
	end
end

function FightAction:ShowHitEff(targetRole, targetIndex,targetEffect)
	if targetRole == nil then
		return
	end
	local hitEffList = self.skillDisplayInfo.hitEff
	local targetE = targetEffect
	if hitEffList == nil or #hitEffList == 0 then
		return
	end
	for i=1,#hitEffList do
		self:_ShowHitEff(targetRole,i,targetIndex,targetE)
	end
end

function FightAction:_ShowHitEff(targetRole,index,targetIndex,targetEffect )
	local targetE = targetEffect
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
         if targetE ~= 3 and targetE ~= 6  then
            	targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)
         elseif targetE == 3 and hitEffType == 12 then
            	targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)
         elseif targetE == 6 and hitEffType == 12 then
             	targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)   	
		 end
		end)
		self.hitEffTimerIDList:push(effTimerID)
	else
		 if targetE ~= 3 and targetE ~= 6  then
            	targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)
         elseif targetE == 3 and hitEffType == 12 then
            	targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)
         elseif targetE == 6 and hitEffType == 12 then
             	targetRole:PlaySkillEffect(hitEffID, hitEffType, hitEffOffsetX, hitEffOffsetY,effectScale)   	
		 end
	end
end

function FightAction:PlayHitEffect(hitIndex)
	local nTargetCount = #self.actionInfo.targetlist
	for i=1,nTargetCount do
		local targetInfo = self.actionInfo.targetlist[i]
		local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
		if targetInfo.effect == 1 or targetInfo.effect == 2 or targetInfo.effect == 7 then --普通受击和暴击 7:主动加buff
			if hitIndex > 1 and self.skillDisplayInfo.hitEffShowOnce then
			else
				self:ShowHitEff(targetRole, i)
			end
		elseif targetInfo.effect == 3 then --闪避
			self:ShowHitEff(targetRole, i, targetInfo.effect)--modify by ZR 闪避播放特殊类型受击，类型12,增加传递闪避参数，在最终播放处处理
		elseif targetInfo.effect == 4 then --治疗加血
			self:ShowHitEff(targetRole, i, targetInfo.effect)
		elseif targetInfo.effect == 5 then --净化，去除目标所有减益buff
			self:ShowHitEff(targetRole, i, targetInfo.effect)
		elseif targetInfo.effect == 6 then --斗转星移
			self:ShowHitEff(targetRole, i, targetInfo.effect)--modify by ZR 闪避播放特殊类型受击，类型12,增加传递闪避参数，在最终播放处处理
		elseif targetInfo.effect == 8 then --额外的加buff
			self:ShowExtraBuffEff(targetRole, i)
		end
	end
end

function FightAction:DelayToShowHit(hitIndex)
	local delayTime = self.skillDisplayInfo["textAnimTime"..hitIndex] or 0
	self.delayTimerID = TFDirector:addTimer(delayTime / FightManager.fightSpeed, 1, nil, 
		function() 
			TFDirector:removeTimer(self.delayTimerID)
			self.delayTimerID = nil
			self:ShowHit(hitIndex)
		end)
end

function FightAction:ShowHit(hitIndex)
	self.hitAnimCompleteRoleNum = 0

	local bLastHit = (hitIndex == self.hitCount)

	-- if self.bEnemyAllDie and bLastHit then
	-- 	if self.skillDisplayInfo.remote == 0 then
	-- 		TFDirector:currentScene():ZoomIn(self.attackerRole)
	-- 	end
	-- 	fightRoleMgr:SetAllRoleSpeed(0.5)
	-- 	TFDirector:currentScene().fightUiLayer:PlayFightEndEffect()
	-- end

	local attackAddEnger = 0

	local delayTime = self.skillDisplayInfo["textAnimTime"..hitIndex] or 0
	local nTargetCount = #self.actionInfo.targetlist
	for i=1,nTargetCount do
		local targetInfo = self.actionInfo.targetlist[i]
		local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)

		--受击昏睡buff解除
		if hitIndex == 1 then
			if targetInfo.hurt < 0  then
				targetRole:RemoveBuffByType(15)
			end
		end
		
		print("targetInfo.effect---------------->", targetInfo.effect)
		if targetInfo.effect == 1 or targetInfo.effect == 2 or targetInfo.effect == 7 then --普通受击和暴击 7:主动加buff
			
			if targetInfo.hurtList[hitIndex] == nil then 
				print("targetInfo.hurtList[hitIndex] is nil---->")
				return 
			end

			local fightText = ""
			if targetInfo.effect == 2 then
				fightText = "baoji"
			end

			local bBezier = false
			if targetInfo.hurtList[hitIndex] < 0 and fightText ~= "baoji" then
				bBezier = true
			end
			fightRoleMgr:addHurtReport(self.attackerRole.logicInfo.posindex ,targetInfo.hurtList[hitIndex])
			targetRole:ShowFightText(fightText, targetInfo.hurtList[hitIndex], false, false, bBezier)

			-- if hitIndex > 1 and self.skillDisplayInfo.hitEffShowOnce then
			-- else
			-- 	self:ShowHitEff(targetRole, i)
			-- end

			targetInfo.triggerBufferID = targetInfo.triggerBufferID or 0
			if targetInfo.triggerBufferID > 0 and targetInfo.bHaveAddBuff ~= true and bLastHit then
				local buffConfig = SkillLevelData:getBuffInfo( targetInfo.triggerBufferID , targetInfo.triggerBufferLevel)
				if buffConfig ~= nil then
					if self:AddBuffToTarget(self.attackerRole, targetRole, targetInfo.triggerBufferID, targetInfo.triggerBufferLevel,targetInfo.hurt) then
						self:AddBuffInfoToServer(self.attackerRole, targetRole, targetInfo.triggerBufferID, 0)
					end
				end
			end

			if bLastHit and targetInfo.hurt < 0 then
				local hitBuff = targetRole:GetBuffByType(28)
				if hitBuff == nil and self.bNormalAttack then
					hitBuff = targetRole:GetBuffByType(38)
				end
				if hitBuff == nil and self.bNormalAttack == false then
					hitBuff = targetRole:GetBuffByType(39)
				end
				if targetRole:IsLive() and hitBuff ~= nil then
					local buff_rate = self:CalculateInBufferTriggerRate(self.attackerRole,targetRole,hitBuff.config)
					local random = math.random(1, 10000)
					print("反制触发buff id== "..hitBuff.config.value.."buff_rate == "..buff_rate..",random == ",random)
					if random <= buff_rate then
						local _trigger = true
						local bufferInfo = SkillBufferData:objectByID(tonumber(hitBuff.config.value))
						if bufferInfo and self.attackerRole.immuneAttribute and self.attackerRole.immuneAttribute[bufferInfo.type] ~= nil then
							local _random = math.random(1, 10000)
							-- print("_random ".._random.." , self.attackerRole.immuneAttribute[bufferInfo.type] = "..self.attackerRole.immuneAttribute[bufferInfo.type])
							if _random <= self.attackerRole.immuneAttribute[bufferInfo.type] then
								_trigger = false
								self.attackerRole:ShowEffectName("mianyi")
							end
						end
						if _trigger == true then
							if self:AddBuffToTarget(targetRole,self.attackerRole, tonumber(hitBuff.config.value),hitBuff.config.buff_level) then
								self:AddBuffInfoToServer(targetRole, self.attackerRole, tonumber(hitBuff.config.value), hitBuff.config.id)
							end
						end
					end
					targetRole:OnBuffTrigger()
				end
			end

			if hitIndex == 1 then
				self:ShowActiveEffect(targetInfo)

				if targetInfo.hurt < 0 then
					targetRole:AddCommonAnger(ConstantData:getValue("Fight.HitAnger"))
					if self.bNormalAttack then
						if targetRole:IsLive() then
							attackAddEnger = math.max(attackAddEnger,ConstantData:getValue("Fight.AttackAnger"))
							-- self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.AttackAnger"))
						else
							attackAddEnger = math.max(attackAddEnger,ConstantData:getValue("Fight.AttackDieAnger"))
							-- self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.AttackDieAnger"))
						end
					else
						if targetRole:IsLive() then
							attackAddEnger = math.max(attackAddEnger,ConstantData:getValue("Fight.SkillAttackAnger"))
							-- self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.SkillAttackAnger"))
						else
							attackAddEnger = math.max(attackAddEnger,ConstantData:getValue("Fight.SkillAttackDieAnger"))
							-- self.attackerRole:AddCommonAnger(ConstantData:getValue("Fight.SkillAttackDieAnger"))
						end
					end
				end
			end

			if bLastHit then
				self:ShowPassiveEffect(targetInfo)
				self:showTriggerSkill(targetInfo)
			end

			if targetInfo.hurt < 0 and not self.bNormalAttack and not self.attackerRole.logicInfo.bEnemyRole then
				if self.skillDisplayInfo.shake ~= nil then
					local shake = self.skillDisplayInfo.shake
					TFDirector:currentScene().mapLayer:Shake(shake,shake)
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
		elseif targetInfo.effect == 3 then --闪避
			if hitIndex == 1 then
				targetRole:ShowFightText("shanbi", 0)
				if self.actionInfo.bBackAttack == nil or self.actionInfo.bBackAttack == false then
					targetRole:DoAvoidAction()
					self:showTriggerSkill(targetInfo)
				end
			end

			if bLastHit then
				self:OnRoleHitAnimComplete()
			end

		elseif targetInfo.effect == 4 then --治疗加血
			fightRoleMgr:addHurtReport(self.attackerRole.logicInfo.posindex ,targetInfo.hurtList[hitIndex])
			targetRole:ShowFightText("", math.abs(targetInfo.hurtList[hitIndex]))
			-- self:ShowHitEff(targetRole, i)

			if hitIndex == 1 then
				self:ShowActiveEffect(targetInfo)
			end

			if bLastHit then
				targetInfo.triggerBufferID = targetInfo.triggerBufferID or 0
				if targetInfo.triggerBufferID > 0 and targetInfo.bHaveAddBuff ~= true then
					local buffConfig = SkillLevelData:getBuffInfo( targetInfo.triggerBufferID , targetInfo.triggerBufferLevel)
					if buffConfig ~= nil then
						if self:AddBuffToTarget(self.attackerRole, targetRole, targetInfo.triggerBufferID, targetInfo.triggerBufferLevel,targetInfo.hurt) then
							self:AddBuffInfoToServer(self.attackerRole, targetRole, targetInfo.triggerBufferID, 0)
						end
					end
				end
				self:OnRoleHitAnimComplete()
			end

		elseif targetInfo.effect == 5 then --净化，去除目标所有减益buff
			-- self:ShowHitEff(targetRole, i)
			if hitIndex == 1 then
				targetRole:CleanBuff(self.attackerRole)
				self:ShowActiveEffect(targetInfo, delayTime)
			end

			if bLastHit then
				self:OnRoleHitAnimComplete()
			end

		elseif targetInfo.effect == 6 then --斗转星移
			if hitIndex == 1 then
				fightRoundMgr:SetDzxyAttackAction(targetRole, self.attackerRole, targetInfo.hurt)
				targetRole:ShowFightText("shanbi", 0)
				targetRole:DoAvoidAction()
				targetRole:OnBuffTrigger()
				targetInfo.hurt = 0
			end

			if bLastHit then
				self:OnRoleHitAnimComplete()
			end
		elseif targetInfo.effect == 8 then --额外的加buff
			-- self:ShowExtraBuffEff(targetRole, i)
			if bLastHit then
				targetInfo.triggerBufferID = targetInfo.triggerBufferID or 0
				if targetInfo.triggerBufferID > 0 and targetInfo.bHaveAddBuff ~= true and bLastHit then
					local buffConfig = SkillLevelData:getBuffInfo( targetInfo.triggerBufferID , targetInfo.triggerBufferLevel)
					if buffConfig ~= nil then
						if self:AddBuffToTarget(self.attackerRole, targetRole, targetInfo.triggerBufferID, targetInfo.triggerBufferLevel,targetInfo.hurt) then
							self:AddBuffInfoToServer(self.attackerRole, targetRole, targetInfo.triggerBufferID, 0)
						end
					end
				end
				self:OnRoleHitAnimComplete()
			end
		end
	end

	if hitIndex == 1 and attackAddEnger ~= 0 then
		self.attackerRole:AddCommonAnger(attackAddEnger)
	end
end



function FightAction:ShowExtraBuffEff(targetRole, targetIndex)
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

function FightAction:_ShowExtraEff(targetRole,index )
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



function FightAction:CalculateInBufferTriggerRate(attackerRole,targetRole,config)
	if config == nil then
		return
	end

	local bufferInfo = SkillBufferData:objectByID(tonumber(config.value))
	local bufRateSuppress = 0
	if bufferInfo.good_buff == 0 then
		if FightManager.fightBeginInfo.fighttype == 5 then
			bufRateSuppress = ClimbManager:getBufRateSuppress( attackerRole.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole )*100
			print("无量山战力压制 buff增加几率 = ",bufRateSuppress)
		elseif FightManager.fightBeginInfo.fighttype == 16 then
			bufRateSuppress = NorthClimbManager:getBufRateSuppress( attackerRole.logicInfo.bEnemyRole,targetRole.logicInfo.bEnemyRole )*100
			print("无量山战力压制 buff增加几率 = ",bufRateSuppress)
		end
	end


	local formula = config.buff_formula
	if formula == nil or formula == 0 then
		local result = config.buff_rate + bufRateSuppress
		print(" buff几率 = ",result)
		return result
	elseif formula == 1 then
		--[[
		角色技能：封印技能添加受技能等级影响的命中率计算规则。
		封印技能命中率 = （1-（目标等级- 技能等级）* 0.1） * 基础命中率（表格配置） 
		其中：7≥(目标等级 - 技能等级）≥-20
		命中率：从 30%-100% 之间波动
		]]
		local tmp = (targetRole.logicInfo.level - config.buff_level)
		tmp = math.min(7,tmp)
		tmp = math.max(-20,tmp)
		local result =(1 -  tmp * 0.1) * config.buff_rate + bufRateSuppress
			print(" buff几率 = ",result)
		return result
	end
end
--被动效果:反弹5 反击6 化解7 复活9 免疫12 受击加血50 表现
function FightAction:ShowPassiveEffect(targetInfo)
	local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
	if targetRole == nil then
		return
	end

	local effect = targetInfo.passiveEffect
	local effectValue = targetInfo.passiveEffectValue
	if effect == 5 then
		fightRoleMgr:addHurtReport(targetInfo.targetpos ,  -effectValue)
		self.attackerRole:ShowFightText("", -effectValue)
		self.attackerRole:ShowEffectName("fantan")
	elseif effect == 6 and self.actionInfo.skillid.skillId == 0 then
		fightRoundMgr:SetBackAttackAction(targetRole, self.attackerRole)
	elseif effect == 7 then
		targetRole:ShowEffectName("huajie")
		local msBuff = targetRole:GetBuffByType(32)
		if msBuff then
			targetRole:OnBuffTrigger()
		end
	elseif effect == 9 then 	
		--这里校验是否真的复活
		--modify by wkdai
		local reallyRelive = false
		if targetRole:IsLive() == false then
			reallyRelive = targetRole:ReLive(effectValue)
		end
		if not reallyRelive then
			targetInfo.passiveEffect = 0;
			targetInfo.passiveEffectValue = 0;
		end
	elseif effect == 12 then
		targetRole:ShowEffectName("mianyi")
	elseif effect == 50 then
		if targetRole:IsLive() then

			fightRoleMgr:addHurtReport(targetInfo.targetpos ,  effectValue)
			targetRole:ShowFightText("", effectValue)
			targetRole:OnBuffTrigger()
		end
	end
end

function FightAction:showTriggerSkill(targetInfo)
	local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
	if targetRole == nil then
		return
	end
	if targetInfo.triggerSkillType ==nil or targetInfo.triggerSkillType == 0 then
		return
	end
	print("targetInfo.triggerSkill = ",targetInfo.triggerSkill)
	targetRole:OnBuffTrigger()
	fightRoundMgr:SetBackAttackAction(targetRole, self.attackerRole,targetInfo.triggerSkill,targetInfo.triggerSkillType)
end

--主动效果:吸怒1 减敌怒2 增己怒3 吸血4 侧击8 净化10 致死11 七伤拳21 表现
function FightAction:ShowActiveEffect(targetInfo)
	local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
	if targetRole == nil then
		return
	end

	local effect = targetInfo.activeEffect
	local effectValue = targetInfo.activeEffectValue
	if effect == 1 then
		fightRoleMgr:AddAnger(targetRole.logicInfo.bEnemyRole, -effectValue)
		fightRoleMgr:AddAnger(self.attackerRole.logicInfo.bEnemyRole, effectValue)
		self.attackerRole:ShowEffectName("xinu")
		if not self.attackerRole.logicInfo.bEnemyRole then
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(0)
		else
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(1)
		end
	elseif effect == 2 then
		fightRoleMgr:AddAnger(targetRole.logicInfo.bEnemyRole, -effectValue)
		targetRole:ShowEffectName("jiannu")
		if not self.attackerRole.logicInfo.bEnemyRole then
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(1)
		end
	elseif effect == 3 then
		fightRoleMgr:AddAnger(self.attackerRole.logicInfo.bEnemyRole, effectValue)
		self.attackerRole:ShowEffectName("jianu")
		if not self.attackerRole.logicInfo.bEnemyRole then
			TFDirector:currentScene().fightUiLayer:AddAngerEffect(2)
		end
	elseif effect == 4 then

		fightRoleMgr:addHurtReport(self.attackerRole.logicInfo.posindex,  effectValue)
		self.attackerRole:ShowFightText("", effectValue)
		self.attackerRole:ShowEffectName("xixue")
	elseif effect == 10 then
		targetRole:CleanBuff(self.attackerRole)
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
	local deepHurtType = targetInfo.deepHurtType
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

function FightAction:HitAnimComplete()
	if self.actionInfo.bBackAttack then
		local targetInfo = self.actionInfo.targetlist[1]
		local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
		if targetRole ~= nil then
			if targetRole:IsLive() then
				targetRole:ReturnBack()
			else
				FightManager:OnActionEnd()
			end
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

function FightAction:OnRoleHitAnimComplete()
	if self.hitAnimCompleteRoleNum == nil then
		return
	end

	local targetNum = #self.actionInfo.targetlist
	self.hitAnimCompleteRoleNum = self.hitAnimCompleteRoleNum + 1
	if self.hitAnimCompleteRoleNum == targetNum then
		self.hitAnimCompleteRoleNum = nil

		local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skillid)
		local skillInfo = SkillLevelData:objectByID(self.actionInfo.skillid)
		if skillBaseInfo == nil or skillInfo == nil or skillBaseInfo.effect ~= 20 then
			self:HitAnimComplete()
		else
			--处理乾坤大挪移
			self.daNuoYiID = TFDirector:addTimer(0.3 / FightManager.fightSpeed, 1, nil, 
			function() 
				TFDirector:removeTimer(self.daNuoYiID)
				self.delayTimerID = nil
				self:ShowQianKunDaNuoYi()
				self:HitAnimComplete()
			end)
		end
	end	
end

function FightAction:AddBuffToTarget(attackRole,targetRole, bufferID, level, hurt)
	if not targetRole:IsLive() then
		return false
	end

	if bufferID > 0 then
		return targetRole:AddBuff(attackRole,bufferID, level,hurt)
	end
	return false
end

function FightAction:GetTargetRole(index)
	if self.actionInfo.targetlist == nil then
		return nil
	end


	local targetInfo = self.actionInfo.targetlist[index]
	if targetInfo == nil then
		return nil
	end

	local targetRole = fightRoleMgr:GetRoleByGirdIndex(targetInfo.targetpos)
	return targetRole
end

function FightAction:ShowSpecilEffect()
	self:ShowXiXinDaFaEffect()
	self:ShowXiXinDaFa_linghuchong_Effect()
end
function FightAction:ShowXiXinDaFaEffect()

	local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skillid)
	local skillInfo = SkillLevelData:objectByID(self.actionInfo.skillid)
	if skillBaseInfo == nil or skillInfo == nil then
		return
	end
	if skillBaseInfo.effect ~= 22 then
		return
	end

	local nTargetCount = #self.actionInfo.targetlist
	for i=1,nTargetCount do
		local targetInfo = self.actionInfo.targetlist[i]
		if targetInfo.activeEffect == 22 and targetInfo.triggerBufferID ~= 0 then
			self.specilTimerID =  TFDirector:addTimer(300 / FightManager.fightSpeed, 1, nil,
				function()
					if self:AddBuffToTarget(self.attackerRole,self.attackerRole, tonumber(skillInfo.effect_value),self.actionInfo.skillid.level) then
						self:AddBuffInfoToServer(self.attackerRole, self.attackerRole, tonumber(skillInfo.effect_value), 0)
					end
					TFDirector:removeTimer(self.specilTimerID)
					self.specilTimerID = nil
				end)
			return
		end
	end
end
function FightAction:ShowXiXinDaFa_linghuchong_Effect()
  
	local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skillid)
	local skillInfo = SkillLevelData:objectByID(self.actionInfo.skillid)
	if skillBaseInfo == nil or skillInfo == nil then
		return
	end
	if skillBaseInfo.effect ~= 23 then
		return
	end
	local nTargetCount = #self.actionInfo.targetlist
	for i=1,nTargetCount do
		local targetInfo = self.actionInfo.targetlist[i]
		if targetInfo.activeEffect == 23 and targetInfo.triggerBufferID ~= 0 then
			if self:AddBuffToTarget(self.attackerRole,self.attackerRole, tonumber(skillInfo.effect_value),self.actionInfo.skillid.level) then
				self:AddBuffInfoToServer(self.attackerRole, self.attackerRole, tonumber(skillInfo.effect_value), 0)
			end
			return
		end
	end
end


function FightAction:ShowQianKunDaNuoYi()
	-- local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skillid)
	-- local skillInfo = SkillLevelData:objectByID(self.actionInfo.skillid)
	-- if skillBaseInfo == nil or skillInfo == nil then
	-- 	return
	-- end

	-- if skillBaseInfo.effect == 20 then
	-- 	-- self.specilTimerID =  TFDirector:addTimer(3000 / FightManager.fightSpeed, 1, nil,
	-- 	-- function()
	-- 		local liveList = fightRoleMgr:GetAllLiveRole(self.attackerRole.logicInfo.bEnemyRole)
	-- 		local liveNum = liveList:length()
	-- 		for i=1,liveNum do
	-- 			local role = liveList:objectAt(i)
	-- 			--治疗修正
	-- 			local fightEffectValue = self.attackerRole:getEffectExtraAttrNum(EnumFightAttributeType.Effect_extra,EnumFightEffectType.FightEffectType_BonusHealing) +
	-- 				role:getEffectExtraAttrNum(EnumFightAttributeType.Be_effect_extra,EnumFightEffectType.FightEffectType_BonusHealing)
	-- 			fightEffectValue = fightEffectValue/10000+1
	-- 			fightEffectValue = math.max(0,fightEffectValue)

	-- 			fightRoleMgr:addHurtReport(self.attackerRole.logicInfo.posindex,  math.floor(skillInfo.effect_value * fightEffectValue))
	-- 			role:ShowFightText("",math.floor(skillInfo.effect_value * fightEffectValue))
	-- 		end
	-- 		-- TFDirector:removeTimer(self.specilTimerID)
	-- 		-- self.specilTimerID = nil
	-- 	-- end)
	-- end

	local skillBaseInfo = BaseDataManager:GetSkillBaseInfo(self.actionInfo.skillid)
	local skillInfo = SkillLevelData:objectByID(self.actionInfo.skillid)

	local liveList = fightRoleMgr:GetAllLiveRole(self.attackerRole.logicInfo.bEnemyRole)
	local liveNum = liveList:length()
	for i=1,liveNum do
		local role = liveList:objectAt(i)
		--治疗修正
		local fightEffectValue = self.attackerRole:getEffectExtraAttrNum(EnumFightAttributeType.Effect_extra,EnumFightEffectType.FightEffectType_BonusHealing) +
			role:getEffectExtraAttrNum(EnumFightAttributeType.Be_effect_extra,EnumFightEffectType.FightEffectType_BonusHealing)
		fightEffectValue = fightEffectValue/10000+1
		fightEffectValue = math.max(0,fightEffectValue)

		fightRoleMgr:addHurtReport(self.attackerRole.logicInfo.posindex,  math.floor(skillInfo.effect_value * fightEffectValue))
		role:ShowFightText("",math.floor(skillInfo.effect_value * fightEffectValue))
	end
end

function FightAction:AddBuffInfoToServer(fromRole, targetRole, bufferID, triggerBuffID)
	local buffInfo = {}
	buffInfo[1] = fromRole.logicInfo.posindex
	buffInfo[2] = targetRole.logicInfo.posindex
	buffInfo[3] = triggerBuffID
	buffInfo[4] = self.actionInfo.skillid.skillId
	buffInfo[5] = self.actionInfo.skillid.level
	buffInfo[6] = bufferID
	buffInfo[7] = self.actionInfo.skillid.level

	if self.actionInfo.skillid.skillId == 0 then
		local passiveSkillNum = #fromRole.passiveSkill
		for i=1,passiveSkillNum do
			local skillInfo = SkillLevelData:objectByID(fromRole.passiveSkill[i])
			if skillInfo ~= nil and skillInfo.buff_id == bufferID then
				buffInfo[4] = skillInfo.id
				buffInfo[5] = skillInfo.level
			end
		end
	else
		buffInfo[4] = self.actionInfo.skillid.skillId
		buffInfo[5] = self.actionInfo.skillid.level
	end

	local num = #self.actionInfo.buffList
	self.actionInfo.buffList[num+1] = buffInfo
end
function FightAction:AddBuffInBeginToServer(buffInfo)
	-- local buffInfo = {}
	-- buffInfo[1] = fromRole.logicInfo.posindex
	-- buffInfo[2] = targetRole.logicInfo.posindex
	-- buffInfo[3] = triggerBuffID
	-- buffInfo[4] = 0
	-- buffInfo[5] = 0
	-- buffInfo[6] = bufferID
	-- buffInfo[7] = 1

	local num = #self.actionInfo.buffList
	self.actionInfo.buffList[num+1] = buffInfo
end

function FightAction:pause()
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

function FightAction:resume()
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

return FightAction
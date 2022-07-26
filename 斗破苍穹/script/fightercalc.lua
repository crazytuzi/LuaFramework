
require "skillmanager"
require "fightbuffer"
require "fightpyros"

local Fighter = {}
Fighter.__index = Fighter

--攻击防御浮动百分比的上下限
local ATTACK_PERCENT_MIN = -0.5
local ATTACK_PERCENT_MAX =  0.6
local DEFENCE_PERCENT_MIN= -0.5
local DEFENCE_PERCENT_MAX=  1.0

--property
Fighter.cardID = nil
Fighter.round  = 0
Fighter.ready  = true
Fighter.hpMax  = 0
Fighter.hpLmt  = 0
Fighter.hp     = 0
Fighter.hit          = 0
Fighter.dodge        = 0
Fighter.hitRatio     = 0
Fighter.dodgeRatio   = 0
Fighter.crit         = 0
Fighter.renxing      = 0
Fighter.critRatio    = 0
Fighter.renxingRatio = 0
Fighter.critRatioDHAdd=0
Fighter.critRatioDHSub=0
Fighter.critPercentAdd=0
Fighter.critPercentSub=0
Fighter.bufBurnReduction = 0
Fighter.bufPoisonReduction=0
Fighter.bufCurseReduction =0
Fighter.counter= false
Fighter.originalPhscAttack = 0
Fighter.originalManaAttack = 0
Fighter.phscAttack = 0
Fighter.manaAttack = 0
Fighter.phscAttackRatio = 0
Fighter.manaAttackRatio = 0
Fighter.originalPhscDefence = 0
Fighter.originalManaDefence = 0
Fighter.phscDefence= 0
Fighter.manaDefence= 0
Fighter.phscDefenceRatio = 0
Fighter.manaDefenceRatio = 0
Fighter.sxzz = 10
Fighter.shjc = 0
Fighter.immunityPhscRatio = 0
Fighter.immunityManaRatio = 0
Fighter.attackEx = 0
Fighter.defenceEx= 0
Fighter.skills = nil
Fighter.bufferDatas     = nil
Fighter.tag = -1
Fighter.pyros  = nil
Fighter.pyroLimited = false
Fighter.immunityCount = nil
Fighter.reviveCount = nil
Fighter.hasThunder = nil
Fighter.hasWind    = nil
Fighter.hasLight   = nil
Fighter.hasDark    = nil

--ctor
function Fighter:create()
	local f  = setmetatable({},Fighter)
	--f.name   = name
	f.cardID = 0
	f.round  = 0
	f.ready  = true
	f.hpMax  = 0
	f.hpLmt  = 0
	f.hp     = 0
	f.hit          = 0
	f.dodge        = 0
	f.hitRatio     = 0
	f.dodgeRatio   = 0
	f.crit         = 0
	f.renxing      = 0
	f.critRatio    = 0
	f.renxingRatio = 0
	f.critRatioDHAdd=0
	f.critRatioDHSub=0
	f.critPercentAdd=0
	f.critPercentSub=0
	f.bufBurnReduction = 0
	f.bufPoisonReduction=0
	f.bufCurseReduction =0
	f.counter= false
	f.originalPhscAttack = 0
	f.originalManaAttack = 0
	f.phscAttack = 0
	f.manaAttack = 0
	f.phscAttackRatio = 0
	f.manaAttackRatio = 0
	f.originalPhscDefence = 0
	f.originalManaDefence = 0
	f.phscDefence= 0
	f.manaDefence= 0
	f.phscDefenceRatio = 0
	f.manaDefenceRatio = 0
	f.sxzz = 10
	f.shjc = 0
	f.immunityPhscRatio = 0
	f.immunityManaRatio = 0
	f.attackEx = 0
	f.defenceEx= 0
	f.skills = nil
	f.bufferDatas= {}
	f.tag = -1
	f.pyros  = nil
	f.pyroLimited = false
	f.immunityCount = {}
	f.reviveCount = nil
	f.hasThunder = nil
	f.hasWind    = nil
	f.hasLight   = nil
	f.hasDark    = nil
	
	return f
end

function Fighter:setTag(i)
	self.tag = tag
end

function Fighter:getTag()
	return self.tag
end

function Fighter:setCardID(cardID)
	self.cardID = cardID
end

function Fighter:getCardID()
	return self.cardID
end

function Fighter:setRound(round)
	self.round = round
end

function Fighter:getRound()
	return self.round
end

function Fighter:addRound()
	self:setRound(self.round + 1)
end

function Fighter:subRound()
	self:setRound(self.round - 1)
end

function Fighter:setReady(ready)
	self.ready = ready
end

function Fighter:isReady()
	return self.ready
end

function Fighter:setHPMax(hp)
	self.hpMax = hp
end

function Fighter:getHPMax()
	return self.hpMax
end

function Fighter:setHPLmt(hp)
	self.hpLmt = hp
end

function Fighter:getHPLmt()
	return self.hpLmt
end

function Fighter:setHP(hp)
	if hp > self.hpLmt then
		self.hp = self.hpLmt
	elseif hp < 0 then
		self.hp = 0
	else
		self.hp = hp
	end
end

function Fighter:getHP()
	return self.hp
end

function Fighter:addHP(hp)
	self:setHP(self.hp + hp)
end

function Fighter:subHP(hp,hpLmt)
	if hpLmt then
		self.hpLmt = self.hpLmt - hpLmt
		if self.hpLmt > self.hpMax then
			self.hpLmt = self.hpMax
		elseif self.hpLmt < 0 then
			self.hpLmt = 0
		end
	end
	self:setHP(self.hp - hp)
end

function Fighter:isDead()
	return self.hp <= 0
end

function Fighter:setHit(hit)
	self.hit = hit
end

function Fighter:getHit()
	return self.hit
end

function Fighter:setDodge(dodge)
	self.dodge = dodge
end

function Fighter:getDodge()
	return self.dodge
end

function Fighter:setHitRatio(hitRatio)
	self.hitRatio = hitRatio
end

function Fighter:getHitRatio()
	return self.hitRatio and self.hitRatio or 0
end

function Fighter:setDodgeRatio(dodgeRatio)
	self.dodgeRatio = dodgeRatio
end

function Fighter:getDodgeRatio()
	return self.dodgeRatio and self.dodgeRatio or 0
end

function Fighter:setCrit(crit)
	self.crit = crit
end

function Fighter:getCrit()
	return self.crit
end

function Fighter:setRenXing(renxing)
	self.renxing = renxing
end

function Fighter:getRenXing()
	return self.renxing
end

function Fighter:setCritRatio(critRatio)
	self.critRatio = critRatio
end

function Fighter:getCritRatio()
	return self.critRatio and self.critRatio or 0
end

function Fighter:setRenXingRatio(renxingRatio)
	self.renxingRatio = renxingRatio
end

function Fighter:getRenXingRatio()
	return self.renxingRatio and self.renxingRatio or 0
end

function Fighter:setCritRatioDH(critRatioDHAdd,critRatioDHSub)
	self.critRatioDHAdd = critRatioDHAdd
	self.critRatioDHSub = critRatioDHSub
end

function Fighter:getCritRatioDHAdd()
	return self.critRatioDHAdd and self.critRatioDHAdd or 0
end

function Fighter:getCritRatioDHSub()
	return self.critRatioDHSub and self.critRatioDHSub or 0
end

function Fighter:setCritPercentAdd(critPercentAdd)
	self.critPercentAdd = critPercentAdd
end

function Fighter:getCritPercentAdd()
	return self.critPercentAdd and self.critPercentAdd or 0
end

function Fighter:setCritPercentSub(critPercentSub)
	self.critPercentSub = critPercentSub
end

function Fighter:getCritPercentSub()
	return self.critPercentSub and self.critPercentSub or 0
end

function Fighter:setBufBurnReduction(bufBurnReduction)
	self.bufBurnReduction = bufBurnReduction
end

function Fighter:getBufBurnReduction()
	return self.bufBurnReduction and self.bufBurnReduction or 0
end

function Fighter:setBufPoisonReduction(bufPoisonReduction)
	self.bufPoisonReduction = bufPoisonReduction
end

function Fighter:getBufPoisonReduction()
	return self.bufPoisonReduction and self.bufPoisonReduction or 0
end

function Fighter:setBufCurseReduction(bufCurseReduction)
	self.bufCurseReduction = bufCurseReduction
end

function Fighter:getBufCurseReduction()
	return self.bufCurseReduction and self.bufCurseReduction or 0
end

function Fighter:setCounter(counter)
	self.counter = counter
end

function Fighter:isCounter()
	return self.counter
end

--Attack Ex
local function limitAttackEx(aex)
	return aex < ATTACK_PERCENT_MIN and ATTACK_PERCENT_MIN or (aex > ATTACK_PERCENT_MAX and ATTACK_PERCENT_MAX or aex)
end

function Fighter:setAttackEx(aex)    self.attackEx = aex  end
function Fighter:getAttackEx()       return self.attackEx end
function Fighter:addAttackEx(percent)self.attackEx = limitAttackEx(self.attackEx + percent) self:aniAttackEx(percent) end
function Fighter:subAttackEx(percent)self.attackEx = limitAttackEx(self.attackEx - percent) self:aniAttackEx(percent) end
function Fighter:aniAttackEx(percent)
end

--OriginalAttack
function Fighter:setOriginalAttacks(phscAtt,manaAtt)
	self.originalPhscAttack = phscAtt
	self.originalManaAttack = manaAtt
end

function Fighter:getOriginalAttack()
	return isMana and self.originalManaAttack or self.originalPhscAttack
end

--Attack
function Fighter:setAttacks(phscAtt,manaAtt) self.phscAttack = phscAtt;self.manaAttack = manaAtt; end
function Fighter:getAttack (isMana)          return isMana and self.manaAttack or self.phscAttack end

--AttackRatio
function Fighter:setAttacksRatio(phscAttRatio,manaAttRatio) self.phscAttackRatio = phscAttRatio;self.manaAttackRatio = manaAttRatio; end
function Fighter:getAttackRatio (isMana)                    return isMana and self.manaAttackRatio or self.phscAttackRatio           end

--Defence Ex
local function limitDefenceEx(dex)
	return dex < DEFENCE_PERCENT_MIN and DEFENCE_PERCENT_MIN or (dex > DEFENCE_PERCENT_MAX and DEFENCE_PERCENT_MAX or dex)
end

function Fighter:setDefenceEx(dex)    self.defenceEx = dex  end
function Fighter:getDefenceEx()       return self.defenceEx end
function Fighter:addDefenceEx(percent)self.defenceEx = limitDefenceEx(self.defenceEx + percent) self:aniDefenceEx(percent) end
function Fighter:subDefenceEx(percent)self.defenceEx = limitDefenceEx(self.defenceEx - percent) self:aniDefenceEx(percent) end
function Fighter:aniDefenceEx(percent)
end

--OriginalDefence
function Fighter:setOriginalDefences(phscDef,manaDef)
	self.originalPhscDefence = phscDef
	self.originalManaDefence = manaDef
end

function Fighter:getOriginalDefence(isMana)
	return isMana and self.originalManaDefence or self.originalPhscDefence
end

--Defence
function Fighter:setDefences(phscDef,manaDef) self.phscDefence = phscDef;self.manaDefence = manaDef; end
function Fighter:getDefence (isMana)          return isMana and self.manaDefence or self.phscDefence end

--DefenceRatio
function Fighter:setDefencesRatio(phscDefRatio,manaDefRatio) self.phscDefenceRatio = phscDefRatio;self.manaDefenceRatio = manaDefRatio; end
function Fighter:getDefenceRatio (isMana)                    return isMana and self.manaDefenceRatio or self.phscDefenceRatio           end

function Fighter:setSXZZ(sxzz)
	self.sxzz = sxzz
end

function Fighter:getSXZZ()
	return self.sxzz and self.sxzz or 10
end

function Fighter:setSHJC(shjc)
	self.shjc = shjc
end

function Fighter:getSHJC()
	return self.shjc and self.shjc or 0
end

function Fighter:setImmunityRatio(phscRatio,manaRatio)
	self.immunityPhscRatio = phscRatio
	self.immunityManaRatio = manaRatio
end

function Fighter:getImmunityPhscRatio()
	return self.immunityPhscRatio and self.immunityPhscRatio or 0
end

function Fighter:getImmunityManaRatio()
	return self.immunityManaRatio and self.immunityManaRatio or 0
end

function Fighter:setSkills(sks)
	self.skills = sks --todo 是否有必要深拷贝
end

--in     前一个skillID或nil
--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getRoundSkill(preSkillID)
	local skills = self.skills
	local pyroLV = self:getPyroGuLingLengHuo()
	local cdRoundMax = pyroLV > PYRO_STATE_NULL and PYRO_GuLingLengHuo.var[pyroLV] or 9999999999
	if preSkillID == nil then
		for i = 1,#skills do
			local skID = skills[i].id
			local cdRound = SkillManager[skID].type
			if cdRound > cdRoundMax then
				cdRound = cdRoundMax
			end
			if cdRound >= SkillManager_TYPE_ACTIVE_ROUND and self.round >= SkillManager[skID].start and ((self.round - SkillManager[skID].start) % (cdRound + 1)) == 0 then
				return skID,skills[i].lv
			end
		end
	else
		for i = 1,#skills do
			if preSkillID == skills[i].id then
				for j = i+1,#skills do
					local skID = skills[j].id
					local cdRound = SkillManager[skID].type
					if cdRound > cdRoundMax then
						cdRound = cdRoundMax
					end
					if cdRound >= SkillManager_TYPE_ACTIVE_ROUND and self.round >= SkillManager[skID].start and ((self.round - SkillManager[skID].start) % (cdRound + 1)) == 0 then
						return skID,skills[j].lv
					end
				end
			end
		end
	end
	return nil,nil
end

--todo optimize Fighter:get***Skill()
--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getEnterSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_ACTIVE_ENTER then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getExitSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_ACTIVE_EXIT then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getCounterSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_ACTIVE_COUNTER then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassivePROBSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_PROB then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveHPHPSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_HPHP then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveBUFFSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_BUFF then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveDEADSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_DEAD then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveTRANSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_TRAN then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveIMATSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_IMAT then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveREDUSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_REDU then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveSETASkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_SETA then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveSETPSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_SETP then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveIMBFSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_IMBF then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveREVIVESkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_REVIVE then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveFINISkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_FINI then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

--return 可以释放的skillID,skillLV或nil,nil
function Fighter:getPassiveREBOUNDSkill()
	local skills = self.skills
	for i = 1,#skills do
		local skID = skills[i].id
		if SkillManager[skID].type == SkillManager_TYPE_PASSIVE_REBOUND then
			return skID,skills[i].lv
		end
	end
	return nil,nil
end

function Fighter:clearBuffers()
	self.bufferDatas = {}
end

--bufferData
function Fighter:setBufferData(bufferType,bufferData)
	if self.bufferDatas[bufferType] == nil or bufferData == nil or bufferData.strength >= self.bufferDatas[bufferType].strength then
		self.bufferDatas[bufferType] = bufferData
	end
end

function Fighter:decBufferData(bufferType)
	if self.bufferDatas[bufferType].times == 1 then
		self.bufferDatas[bufferType] = nil
	else
		self.bufferDatas[bufferType].times = self.bufferDatas[bufferType].times - 1
	end
end

function Fighter:hasBufferData(bufferType)
	return self.bufferDatas[bufferType] ~= nil
end

--bufferDamage 外部处理是否有效
function Fighter:getBufferDamage(bufferType)
	return self.bufferDatas[bufferType].damage
end

--bufferAttackPercent 外部处理是否有效
function Fighter:getBufferAttackPercent(bufferType)
	return self.bufferDatas[bufferType].attackPercent
end

--bufferAttackPercent 外部处理是否有效
function Fighter:getBufferAttackNumber(bufferType)
	return self.bufferDatas[bufferType].attackNumber
end

--bufferAttackPercent 外部处理是否有效
function Fighter:getBufferDamagePercent(bufferType)
	return self.bufferDatas[bufferType].damagePercent
end

--bufferAttackPercent 外部处理是否有效
function Fighter:getBufferDamageNumber(bufferType)
	return self.bufferDatas[bufferType].damageNumber
end

--获取Buffer Types
function Fighter:getBufferTypes()
	local bufferTypes = {}
	for i = 1,BUFFER_TYPE_MAX do
		if self.bufferDatas[i] then
			bufferTypes[#bufferTypes + 1] = self.bufferDatas[i].type -- self.bufferDatas[i].type == i
		end
	end
	return bufferTypes
end

--异火
function Fighter:setPyros(pyros)
	self.pyros = pyros and pyros or {}
end

function Fighter:setPyroLimited(limited)
	self.pyroLimited = limited
end

function Fighter:getPyroLV(pyroID)
	local pyros = self.pyros
	for i = 1,#pyros do
		if pyros[i].id == pyroID then
			return self.pyroLimited and PYRO_STATE_VIGOROUS or pyros[i].lv
		end
	end
	return PYRO_STATE_NULL
end

function Fighter:getPyroDiYan()				return self:getPyroLV(PYRO_DiYan.id)			end --帝炎
function Fighter:getPyroXuWuTunYan()		return self:getPyroLV(PYRO_XuWuTunYan.id)		end --虚无吞炎
function Fighter:getPyroJingLianYaoHuo()	return self:getPyroLV(PYRO_JingLianYaoHuo.id)	end --净莲妖火
function Fighter:getPyroJinDiFenTianYan()	return self:getPyroLV(PYRO_JinDiFenTianYan.id)	end --金帝焚天炎
function Fighter:getPyroShengLingZhiYan()	return self:getPyroLV(PYRO_ShengLingZhiYan.id)	end --生灵之焱
function Fighter:getPyroJiuYouJinZuHuo()	return self:getPyroLV(PYRO_JiuYouJinZuHuo.id)	end --九幽金祖火
function Fighter:getPyroSanQianYanYanHuo()	return self:getPyroLV(PYRO_SanQianYanYanHuo.id)	end --三千焱炎火
function Fighter:getPyroGuLingLengHuo()		return self:getPyroLV(PYRO_GuLingLengHuo.id)	end --骨灵冷火
function Fighter:getPyroYunLuoXinYan()		return self:getPyroLV(PYRO_YunLuoXinYan.id)		end --陨落心炎
function Fighter:getPyroHaiXinYan()			return self:getPyroLV(PYRO_HaiXinYan.id)		end --海心焰
function Fighter:getPyroQingLianDiXinHuo()	return self:getPyroLV(PYRO_QingLianDiXinHuo.id)	end --青莲地心火
function Fighter:getPyroWanShouLingYan()	return self:getPyroLV(PYRO_WanShouLingYan.id)	end --万兽灵焱

function Fighter:setImmunityCount(isMana,count)
	self.immunityCount[isMana] = count
end

function Fighter:getImmunityCount(isMana)
	return self.immunityCount[isMana]
end

function Fighter:setReviveCount(count)
	self.reviveCount = count
end

function Fighter:getReviveCount()
	return self.reviveCount
end

--羁绊
function Fighter:setHasYokes(hasThunder,hasWind,hasLight,hasDark)
	self.hasThunder = hasThunder
	self.hasWind    = hasWind
	self.hasLight   = hasLight
	self.hasDark    = hasDark
end

function Fighter:hasYokeThunder()
	return self.hasThunder
end

function Fighter:hasYokeWind()
	return self.hasWind
end

function Fighter:hasYokeLight()
	return self.hasLight
end

function Fighter:hasYokeDark()
	return self.hasDark
end

return Fighter

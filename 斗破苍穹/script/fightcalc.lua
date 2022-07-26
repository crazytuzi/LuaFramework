
require "fightpyros"
require "fightyokes"
local Fighter = require"fightercalc"

--Boss战
local BOSS_POSITION = 12 --Boss的位置号定义

--最大回合数限制
local MAX_ROUND_LIMIT = 30

local FLOAT_DAMAGE_PERCENT     = 5 --伤害浮动百分系数
local FLOAT_DAMAGE_PERCENT_MIN = 100 - FLOAT_DAMAGE_PERCENT
local FLOAT_DAMAGE_PERCENT_MAX = 100 + FLOAT_DAMAGE_PERCENT
local CRIT_DAMAGE_MAX = 1.8 --暴击倍数上限
local CRIT_DAMAGE_X   = 1.5 --暴击倍数
local CRIT_DAMAGE_MIN = 1.2 --暴击倍数下限

local DAMAGE_TYPE_REGENERATION = 0
local DAMAGE_TYPE_GENERIC      = 1
local DAMAGE_TYPE_CRIT         = 2

local BUFFER_REDUCE_MAX = 0.4 --灼烧中毒诅咒Buffer的减伤百分比上限
local BUFFER_REDUCE_MIN = 0.0 --灼烧中毒诅咒Buffer的减伤百分比下限

local POWER_MAX = 0.90 --战力比上限
local POWER_MIN = 0.75 --战力比下限
local POWER_BASE= 0.05 --战力基础减伤
local POWER_HIGH= 0.20 --战力最高减伤

--队列中的动作类型
local ACT_ROUND  = 1
local ACT_ENTER  = 2
local ACT_EXIT   = 3
local ACT_COUNTER= 4
local ACT_MANUAL = 5
local ACT_STAND  = 6
local ACT_BURN   = 7
local ACT_POISON = 8
local ACT_CURSE  = 9
local ACT_MMMMMM = 10
local ACT_ENTER2 = 11
local ACT_EXIT2  = 12

local Fight = {}

--init in doInit()
Fight.isCalcOver = nil
Fight.initData = nil
Fight.randomseed = 0 --为了更随机
Fight.customPriorityMap = nil
Fight.fighters = nil
Fight.damages  = {}
Fight.fightersHP=nil
Fight.otherDamage = 0

--!!!修复播放录像时和原始战斗过程不一致的问题。
--原因是：多个并行骨骼动画的事件触发时间顺序会有所不同，导致随机数的获取顺序不一致。
--类似多线程的同步问题。
Fight.FIX_BUG_OF_GET_RANDOM = nil

--init in doFight
Fight.mySubstituteIdx    = 0
Fight.otherSubstituteIdx = 0
Fight.mySkillCardsOrder = nil
Fight.otherSkillCardsOrder = nil
Fight.myDeaths   = 0
Fight.otherDeaths= 0
Fight.fightIndex = 1
Fight.roundOrigin= 0 --每一小场战斗的回合数起点，用于修正脚本中的回合数。
Fight.roundIndex = 0
Fight.bigRound   = 0
Fight.scriptIndex= 1
Fight.actionIndex= 0
Fight.actionHead = nil
Fight.myPowerReduction    = nil
Fight.otherPowerReduction = nil

--init in doScript -> onScriptDone
Fight.isExtra  = false
Fight.isEnter  = false
Fight.isExit   = false
Fight.roundSrc = nil
Fight.roundSID = nil
Fight.roundDie = false
Fight.roundSkp = false
Fight.isBurnt  = false
Fight.isPoisoned=false
Fight.isCursed = false
Fight.act = nil
Fight.sid = nil
Fight.slv = nil
Fight.src = nil
Fight.tag = nil --for record
Fight.dst = {}
Fight.yokeDst = 0 --for yokeThunder
Fight.baseAtt = 0
Fight.pyroAtt = 0
Fight.permAtt = 0
Fight.bufAAtt = 0
Fight.bufDAtt = 0
Fight.incrAtt = 0
Fight.deadAtt = 0
Fight.hphpAtt = 0
Fight.buffAtt = 0

--{{SkillCard类
local SKILL_CARD_STATE_EMPTY  = 0
local SKILL_CARD_STATE_CDING  = 1
local SKILL_CARD_STATE_NORMAL = 2
local SKILL_CARD_STATE_PRESSED= 3
local SKILL_CARD_STATE_RELEASED=4

--My
local MySkillCard = {}
MySkillCard.__index = MySkillCard

function MySkillCard:setTag(t)       self.tag = t end
function MySkillCard:getTag() return self.tag     end

function MySkillCard:setState(s)       self.state = s end
function MySkillCard:getState() return self.state     end

function MySkillCard.create(i)
	local skillCard = setmetatable({},MySkillCard)
	skillCard:setTag(i)
	local scData = Fight.initData.myData.skillCards[i]
	local scsid  = scData.id
	if scsid then
		skillCard.cdCount = SkillManager[scsid].cd
		if skillCard.cdCount > 0 then
			skillCard:setState(SKILL_CARD_STATE_CDING)
		else
			skillCard:setState(SKILL_CARD_STATE_NORMAL)
		end
	else
		skillCard:setState(SKILL_CARD_STATE_EMPTY)
	end
	return skillCard
end

function MySkillCard:updateCD()
	if self.state == SKILL_CARD_STATE_CDING and self.cdCount > 0 then
		self.cdCount = self.cdCount - 1
		if self.cdCount == 0 then
			self:setState(SKILL_CARD_STATE_NORMAL)
		end
	end
end

--Other
local OtherSkillCard = {}
OtherSkillCard.__index = OtherSkillCard

function OtherSkillCard:setTag(t)       self.tag = t end
function OtherSkillCard:getTag() return self.tag     end

function OtherSkillCard:setState(s)       self.state = s end
function OtherSkillCard:getState() return self.state     end

function OtherSkillCard.create(i)
	local skillCard = setmetatable({},OtherSkillCard)
	skillCard:setTag(i)
	local scData = Fight.initData.otherData[1].skillCards[i]
	local scsid  = scData.id
	if scsid then
		skillCard.cdCount = SkillManager[scsid].cd
		if skillCard.cdCount > 0 then
			skillCard:setState(SKILL_CARD_STATE_CDING)
		else
			skillCard:setState(SKILL_CARD_STATE_NORMAL)
		end
	else
		skillCard:setState(SKILL_CARD_STATE_EMPTY)
	end
	return skillCard
end

function OtherSkillCard:updateCD()
	if self.state == SKILL_CARD_STATE_CDING and self.cdCount > 0 then
		self.cdCount = self.cdCount - 1
		if self.cdCount == 0 then
			self:setState(SKILL_CARD_STATE_NORMAL)
		end
	end
end

--设置Fighter属性
function Fight.setFighterProperties(pos,fst)
	local fer = Fight.fighters[pos]
	fer:setCardID(fst.cardID)
	fer:setRound(0)
	fer:setHPMax(fst.hp)
	fer:setHPLmt(fst.hp)
	fer:setHP(fst.hpCur and fst.hpCur or fst.hp,true)
	fer:setHit(fst.hit)
	fer:setDodge(fst.dodge)
	fer:setHitRatio(fst.hitRatio)
	fer:setDodgeRatio(fst.dodgeRatio)
	fer:setCrit(fst.crit)
	fer:setRenXing(fst.renxing)
	fer:setCritRatio(fst.critRatio)
	fer:setRenXingRatio(fst.renxingRatio)
	fer:setCritRatioDH(fst.critRatioDHAdd,fst.critRatioDHSub)
	fer:setCritPercentAdd(fst.critPercentAdd)
	fer:setCritPercentSub(fst.critPercentSub)
	fer:setBufBurnReduction(fst.bufBurnReduction)
	fer:setBufPoisonReduction(fst.bufPoisonReduction)
	fer:setBufCurseReduction(fst.bufCurseReduction)
	fer:setAttackEx(0)
	fer:setOriginalAttacks(fst.attPhsc,fst.attMana)
	fer:setAttacks(fst.attPhsc,fst.attMana)
	fer:setAttacksRatio(fst.attPhscRatio,fst.attManaRatio)
	fer:setDefenceEx(0)
	fer:setOriginalDefences(fst.defPhsc,fst.defMana)
	fer:setDefences(fst.defPhsc,fst.defMana)
	fer:setDefencesRatio(fst.defPhscRatio,fst.defManaRatio)
	fer:setSXZZ(fst.shuxingzengzhi)
	fer:setSHJC(fst.damageIncrease)
	fer:setImmunityRatio(fst.immunityPhscRatio,fst.immunityManaRatio)
	fer:setSkills(fst.sks)
	fer:setPyros(fst.pyros)
	fer:setHasYokes(
		fst.yokeEnable and fst.yokeID == YOKE_Thunder.id,
		fst.yokeEnable and fst.yokeID == YOKE_Wind.id,
		fst.yokeEnable and fst.yokeID == YOKE_Light.id,
		fst.yokeEnable and fst.yokeID == YOKE_Dark.id
	)
	fer:setPyroLimited(false)
	fer:clearBuffers()
	--设置免疫伤害次数值
	local pyroLV = fer:getPyroJiuYouJinZuHuo()
	fer:setImmunityCount(false,pyroLV > PYRO_STATE_NULL and PYRO_JiuYouJinZuHuo.var[pyroLV] or 0)
	local pyroLV = fer:getPyroSanQianYanYanHuo()
	fer:setImmunityCount(true ,pyroLV > PYRO_STATE_NULL and PYRO_SanQianYanYanHuo.var[pyroLV] or 0)
	--设置已经复活次数
	fer:setReviveCount(0)
end

--重置异火限制
function Fight.resetLimited()
	local limited7_12 = false
	for i = 1,6 do
		local fer = Fight.fighters[i]
		if not fer:isDead() and fer:getPyroDiYan() > PYRO_STATE_NULL then
			limited7_12 = true
			break
		end
	end
	for i = 7,12 do
		Fight.fighters[i]:setPyroLimited(limited7_12)
	end
	local limited1_6 = false
	for i = 7,12 do
		local fer = Fight.fighters[i]
		if not fer:isDead() and fer:getPyroDiYan() > PYRO_STATE_NULL then
			limited1_6 = true
			break
		end
	end
	for i = 1,6 do
		Fight.fighters[i]:setPyroLimited(limited1_6)
	end
end

--随机数算法，随机保证，保证序列正确
function Fight.random(...)
	local tag,min,max = ...
	Fight.randomseed = Fight.randomseed + os.time()
	math.randomseed(Fight.randomseed)
	--精度为0.001
	local ret = math.modf(math.random(select(2,...)) * 1000) / 1000
	Fight.initData.record.randomNum[#Fight.initData.record.randomNum + 1] = {ret,...}
	return ret
end

--设置出手扫描顺序
function Fight.resetPriorityMap()
	if Fight.initData.isSelfFirst then
		Fight.customPriorityMap = {4,7,5,8,6,9,1,10,2,11,3,12}
	else
		Fight.customPriorityMap = {7,4,8,5,9,6,10,1,11,2,12,3}
	end
end

function Fight.doInit(data,cb)
	if FLAG_FOR_SERVER then
		Fight.fightersHP = {}
	else
		reloadModule("skillmanager",SkillManager)
		Fight.fightersHP = require("EncryptLuaTable").new()
	end
	Fight.otherDamage = 0
	--setup data
	data.record = nil
	Fight.initData = data
	Fight.randomseed = 0
	--设置最大回合数
	if Fight.initData.maxBigRound and Fight.initData.maxBigRound > 0 then --不做上限限制
		MAX_ROUND_LIMIT = Fight.initData.maxBigRound
	else
		MAX_ROUND_LIMIT = 30
	end
	--纠正数据
	if not Fight.initData.isPVE then --!!! PVP永远只有一场战斗
		Fight.initData.otherData[2] = nil
		Fight.initData.otherData[3] = nil
	end
	if not Fight.initData.myData.substitute then
		Fight.initData.myData.substitute = {}
	end
	--if not Fight.initData.myData.skillCards then
		Fight.initData.myData.skillCards = {}
	--end
	for i = 1,#Fight.initData.otherData do
		if not Fight.initData.otherData[i].substitute then
			Fight.initData.otherData[i].substitute = {}
		end
		--if not Fight.initData.otherData[i].skillCards then
			Fight.initData.otherData[i].skillCards = {}
		--end
	end
	Fight.resetPriorityMap()
	--fighters
	Fight.fighters = {}
	for i = 1,12 do
		local fer = Fighter:create()
		fer:setTag(i)
		Fight.fighters[i] = fer
	end
	Fight.damages = {}
	Fight.FIX_BUG_OF_GET_RANDOM = {}

	Fight.fightIndex = 1
	Fight.doFight()
	Fight.isCalcOver = false
	repeat
		Fight.doScript()
	until Fight.isCalcOver
end

function Fight.doFree()
	--!!! Dtor order
	--init in doScript -> onScriptDone
	Fight.isExtra  = false
	Fight.isEnter  = false
	Fight.isExit   = false
	Fight.roundSrc = nil
	Fight.roundSID = nil
	Fight.roundDie = false
	Fight.roundSkp = false
	Fight.isBurnt  = false
	Fight.isPoisoned=false
	Fight.isCursed = false
	Fight.act = nil
	Fight.sid = nil
	Fight.slv = nil
	Fight.src = nil
	Fight.tag = nil
	Fight.dst = nil
	Fight.baseAtt = 0
	Fight.pyroAtt = 0
	Fight.permAtt = 0
	Fight.bufAAtt = 0
	Fight.bufDAtt = 0
	Fight.incrAtt = 0
	Fight.deadAtt = 0
	Fight.hphpAtt = 0
	Fight.buffAtt = 0
	--init in doFight
	Fight.mySubstituteIdx = 0
	Fight.otherSubstituteIdx = 0
	Fight.mySkillCardsOrder = nil
	Fight.otherSkillCardsOrder = nil
	Fight.myDeaths   = 0
	Fight.otherDeaths= 0
	Fight.fightIndex = 1
	Fight.roundOrigin= 0
	Fight.roundIndex = 0
	Fight.bigRound   = 0
	Fight.scriptIndex= 1
	Fight.actionIndex= 0
	Fight.actionHead = nil
	Fight.myPowerReduction    = nil
	Fight.otherPowerReduction = nil
	--init in doInit
	Fight.initData = nil
	Fight.randomseed = 0
	Fight.customPriorityMap = nil
	Fight.fighters = nil
	Fight.damages  = nil
	Fight.fightersHP=nil
	Fight.otherDamage=nil
	Fight.FIX_BUG_OF_GET_RANDOM = nil
end

function Fight.doFight()
	if Fight.fightIndex == 1 then --第一场战斗
		--己方
		for i = 1,6 do
			local pos = (i < 4) and (i + 3) or (i - 3)
			local fer = Fight.fighters[pos]
			local fst = Fight.initData.myData.mainForce[i]
			if fst then
				fer:setReady(true)
				Fight.setFighterProperties(pos,fst)
			else
				fer:setHPMax(0)
				fer:setHP(0)
			end
		end
		--敌方
		for i = 1,6 do
			local pos = i + 6
			local fer = Fight.fighters[pos]
			local fst = Fight.initData.otherData[Fight.fightIndex].mainForce[i]
			if fst then
				fer:setReady(true)
				Fight.setFighterProperties(pos,fst)
			else
				fer:setHPMax(0)
				fer:setHP(0)
			end
		end
		Fight.initData.record = {randomNum = {},manualAct = {},mmmmmmAct = {},swapPos = {{},{},{}}}
		Fight.mySubstituteIdx = 0
		Fight.otherSubstituteIdx = 0
		Fight.mySkillCardsOrder = {}
		for i = 1,#Fight.initData.myData.skillCards do
			Fight.mySkillCardsOrder[i] = MySkillCard.create(i)
		end
		if not Fight.initData.isPVE then
			Fight.otherSkillCardsOrder = {}
			for i = 1,#Fight.initData.otherData[1].skillCards do
				Fight.otherSkillCardsOrder[i] = OtherSkillCard.create(i)
			end
		end
		Fight.myDeaths    = 0
		Fight.otherDeaths = 0
		Fight.fightIndex  = 1
		Fight.roundOrigin = 0
		Fight.roundIndex  = 0
		Fight.bigRound    = 0
		Fight.scriptIndex = 1
		Fight.actionIndex = 0
		Fight.clearActions()
	else --非第一场战斗
		--己方
		for i = 1,6 do
			Fight.fighters[i]:setReady(true)
		end
		--敌方
		for i = 1,6 do
			local pos = i + 6
			local fer = Fight.fighters[pos]
			local fst = Fight.initData.otherData[Fight.fightIndex].mainForce[i]
			if fst then
				fer:setReady(true)
				Fight.setFighterProperties(pos,fst)
			else
				fer:setHPMax(0)
				fer:setHP(0)
			end
		end
		Fight.otherSubstituteIdx = 0
		Fight.roundOrigin = Fight.roundIndex
	end
	Fight.myPowerReduction = 0
	Fight.otherPowerReduction = 0
	if not Fight.initData.isPVE then
		local myPower = Fight.initData.myData.power
		local otherPower = Fight.initData.otherData[Fight.fightIndex].power
		if myPower and myPower>1000000 and otherPower and otherPower>1000000 then
			local percent
			if myPower > otherPower then
				percent = otherPower/myPower
				if percent < POWER_MIN then
					Fight.myPowerReduction = POWER_HIGH
				elseif percent < POWER_MAX then
					Fight.myPowerReduction = POWER_BASE+POWER_MAX-percent
				end
			else
				percent = myPower/otherPower
				if percent < POWER_MIN then
					Fight.otherPowerReduction = POWER_HIGH
				elseif percent < POWER_MAX then
					Fight.otherPowerReduction = POWER_BASE+POWER_MAX-percent
				end
			end
		end
	end
	Fight.resetLimited()
	Fight.isExtra = false
end

function Fight.onFightDone()
	local hpCur,hpMax = 0,0
	for i = 1,6 do
		local fer = Fight.fighters[i]
		if not fer:isDead() then
			hpCur = hpCur + fer:getHP()
			Fight.fightersHP[fer:getCardID()] = fer:getHP()
		end
	end
	local myData = Fight.initData.myData
	for i = Fight.mySubstituteIdx + 1,#myData.substitute do
		local fst = myData.substitute[i]
		if fst then
			hpCur = hpCur + fst.hp
			Fight.fightersHP[fst.cardID] = fst.hpCur and fst.hpCur or fst.hp
		end
	end
	for i = 1,6 do
		local fst = myData.mainForce[i]
		if fst then
			hpMax = hpMax + fst.hp
		end
	end
	for i = 1,#myData.substitute do
		local fst = myData.substitute[i]
		if fst then
			hpMax = hpMax + fst.hp
		end
	end
	--敌方总伤害，bossDamage未重构
	local otherData  = nil
	local otherHPCur = 0
	local otherHPMax = 0
	local bossDamage = 0
	for i = 1,Fight.fightIndex-1 do
		otherData = Fight.initData.otherData[i]
		for j = 1,6 do
			local fst = otherData.mainForce[j]
			if fst then
				bossDamage = bossDamage + (fst.hpCur and fst.hpCur or fst.hp)
			end
		end
		for j = 1,#otherData.substitute do
			local fst = otherData.substitute[j]
			if fst then
				bossDamage = bossDamage + (fst.hpCur and fst.hpCur or fst.hp)
			end
		end
	end
	for i = 7,12 do
		local fer = Fight.fighters[i]
		if not fer:isDead() then
			otherHPCur = otherHPCur + fer:getHP()
		end
	end
	local otherData = Fight.initData.otherData[Fight.fightIndex]
	for i = Fight.otherSubstituteIdx + 1,#otherData.substitute do
		local fst = otherData.substitute[i]
		if fst then
			otherHPCur = otherHPCur + (fst.hpCur and fst.hpCur or fst.hp)
		end
	end
	for i = 1,6 do
		local fst = otherData.mainForce[i]
		if fst then
			otherHPMax = otherHPMax + (fst.hpCur and fst.hpCur or fst.hp)
		end
	end
	for i = 1,#otherData.substitute do
		local fst = otherData.substitute[i]
		if fst then
			otherHPMax = otherHPMax + (fst.hpCur and fst.hpCur or fst.hp)
		end
	end
	bossDamage = math.floor(bossDamage + otherHPMax - otherHPCur)
	Fight.otherDamage = math.floor(Fight.otherDamage)
	--cclog("Fight Over~~~~" .. (Fight.isWin() and "Won" or "Lost"))
	--cclog("WhichFight:" .. Fight.fightIndex)
	--cclog("BigRound:  " .. Fight.bigRound)
	--cclog("MyDeaths:  " .. Fight.myDeaths)
	--cclog("HPPercent: " .. hpCur/hpMax)
	--cclog("每个血值:  ")
	--cclog("SkipFight: " .. (false and "true" or "false"))
	--cclog("bossDamage: " .. bossDamage)
	--cclog("otherDamage:" .. Fight.otherDamage)
	local isWin    = Fight.isWin()
	local hpPercent= hpCur/hpMax
	local hpReplace= tostring(hpPercent):gsub("%.","")
	if hpMax == 0 then --Fix 修复除零问题。
		hpPercent = 0
		hpReplace = 0
	elseif hpPercent < 0.001 then --Fix 修复数据过小时，Lua引擎使用科学计数法导致的Bug。
		hpPercent = 0.001
		hpReplace = 0001
	end
	Fight.initData.result = {
		isWin      = isWin,
		fightIndex = Fight.fightIndex,
		bigRound   = Fight.bigRound,
		myDeaths   = Fight.myDeaths,
		fightersHP = Fight.fightersHP,
		hpPercent  = hpPercent,
		bossDamage = bossDamage,
		otherDamage= Fight.otherDamage,
		hash = { --!!!防止战斗结果数据被修改。
			isWin      = Fight.encodeNumber(isWin and 23987239 or 314587676),
			fightIndex = Fight.encodeNumber(Fight.fightIndex),
			bigRound   = Fight.encodeNumber(Fight.bigRound),
			myDeaths   = Fight.encodeNumber(Fight.myDeaths),
			hpPercent  = Fight.encodeNumber(tonumber(hpReplace)),
			bossDamage = Fight.encodeNumber(bossDamage),
			otherDamage= Fight.encodeNumber(Fight.otherDamage),
		},
	}
	Fight.isCalcOver = true
end

--是否大回合结束
function Fight.isBigRoundOver()
	for i = 1,#Fight.customPriorityMap do
		local fer = Fight.fighters[Fight.customPriorityMap[i]]
		if not fer:isDead() and fer:isReady() then
			return false
		end
	end
	return true
end

--获取本回合主动方,存储于Fight.src变量
function Fight.getSrc()
	if Fight.isBigRoundOver() then
		for i = 1,12 do
			Fight.fighters[i]:setReady(true)
		end
	end
	for i = 1,#Fight.customPriorityMap do
		local src = Fight.fighters[Fight.customPriorityMap[i]]
		if not src:isDead() and src:isReady() then
			src:setReady(false)
			Fight.src = Fight.customPriorityMap[i]
			return
		end
	end
end

--获取本回合被动方,存储于Fight.dst变量
function Fight.getDst()
	Fight.dst = {}
	--从指定表中随机n个
	local function randomOfTable(teamAll,count)
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
		if #Fight.dst > count then --减少至指定个数
			repeat
				table.remove(Fight.dst,Fight.random(0,1,#Fight.dst))
			until #Fight.dst <= count
		end
	end
	--switch
	if SkillManager[Fight.sid].target == SkillManager_OWN_RANDOM_3 then --己方随机3个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,3)
		else
			randomOfTable({7,8,9,10,11,12}	,3)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_RANDOM_2 then --己方随机2个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,2)
		else
			randomOfTable({7,8,9,10,11,12}	,2)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_RANDOM_1 then --己方随机1个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,1)
		else
			randomOfTable({7,8,9,10,11,12}	,1)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_OTHER then --己方除自己
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_OWN_OTHER")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_OWN_OTHER")
		local teamAll
		if Fight.src < 7 then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		for i=1,6 do
			if teamAll[i] ~= Fight.src and not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_100 then --己方血量百分比最大
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local strongIndex = nil
		local strongPercent = 0
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent > strongPercent then
					strongIndex = i
					strongPercent = percent
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_0 then --己方血量百分比最小
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local weakIndex = nil
		local weakPercent = 2
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent < weakPercent then
					weakIndex = i
					weakPercent = percent
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_STRONG then --己方最强
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local strongIndex = nil
		local strongHP = 0
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() > strongHP then
					strongIndex = i
					strongHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_WEAK then --己方最弱
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {4,5,6,1,2,3}
		else
			teamAll = {7,8,9,10,11,12}
		end
		local weakIndex = nil
		local weakHP = 99999999999999999999999999999999
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() < weakHP then
					weakIndex = i
					weakHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_SELF then --己方自己
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_OWN_SELF")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_OWN_SELF")
		if not Fight.fighters[Fight.src]:isDead() then
			Fight.dst = {Fight.src}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_OWN_ALL then --己方所有((等同随机6个))
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({4,5,6,1,2,3}	,6)
		else
			randomOfTable({7,8,9,10,11,12}	,6)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_FRONT then --单体前排
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_SINGLE_FRONT")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_SINGLE_FRONT")
		local teamAll
		local col = math.floor((Fight.src-1)%3)+1
		if Fight.src < 7 then
				if col == 1 then teamAll = {7,8,9,10,11,12}
			elseif col == 2 then teamAll = {8,7,9,11,10,12}
			elseif col == 3 then teamAll = {9,8,7,12,11,10}
			end
		else
				if col == 1 then teamAll = {4,5,6,1,2,3}
			elseif col == 2 then teamAll = {5,4,6,2,1,3}
			elseif col == 3 then teamAll = {6,5,4,3,2,1}
			end
		end
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst = {teamAll[i]}
				break
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_BACK then --单体后排
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_SINGLE_BACK")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_SINGLE_BACK")
		local teamAll
		local col = math.floor((Fight.src-1)%3)+1
		if Fight.src < 7 then
				if col == 1 then teamAll = {10,11,12,7,8,9}
			elseif col == 2 then teamAll = {11,10,12,8,7,9}
			elseif col == 3 then teamAll = {12,11,10,9,8,7}
			end
		else
				if col == 1 then teamAll = {1,2,3,4,5,6}
			elseif col == 2 then teamAll = {2,1,3,5,4,6}
			elseif col == 3 then teamAll = {3,2,1,6,5,4}
			end
		end
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst = {teamAll[i]}
				break
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_WEAK then --单体最弱
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local weakIndex
		local weakHP = 99999999999999999999999999999999
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() < weakHP then
					weakIndex = i
					weakHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_STRONG then --单体最强
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local strongIndex
		local strongHP = 0
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				if Fight.fighters[teamAll[i]]:getHP() > strongHP then
					strongIndex = i
					strongHP = Fight.fighters[teamAll[i]]:getHP()
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_0 then --单体血量百分比最小
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local weakIndex
		local weakPercent = 2
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent < weakPercent then
					weakIndex = i
					weakPercent = percent
				end
			end
		end
		if weakIndex then
			Fight.dst = {teamAll[weakIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_100 then --单体血量百分比最大
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		local strongIndex
		local strongPercent = 0
		for i=1,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				local percent = Fight.fighters[teamAll[i]]:getHP()/Fight.fighters[teamAll[i]]:getHPMax()
				if percent > strongPercent then
					strongIndex = i
					strongPercent = percent
				end
			end
		end
		if strongIndex then
			Fight.dst = {teamAll[strongIndex]}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_SINGLE_COUNTER then --单体反击
		assert(Fight.act == ACT_COUNTER,"Only ACT_COUNTER can select target: SkillManager_SINGLE_COUNTER")
		if not Fight.fighters[Fight.roundSrc]:isDead() then
			Fight.dst = {Fight.roundSrc}
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_ROW_1 then --前排
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		for i=1,3 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
		if #Fight.dst == 0 then
			for i=4,6 do
				if not Fight.fighters[teamAll[i]]:isDead() then
					Fight.dst[#Fight.dst+1] = teamAll[i]
				end
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_ROW_2 then --后排
		local teamAll
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			teamAll = {7,8,9,10,11,12}
		else
			teamAll = {4,5,6,1,2,3}
		end
		for i=4,6 do
			if not Fight.fighters[teamAll[i]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[i]
			end
		end
		if #Fight.dst == 0 then
			for i=1,3 do
				if not Fight.fighters[teamAll[i]]:isDead() then
					Fight.dst[#Fight.dst+1] = teamAll[i]
				end
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_COLS  then --本列
		assert(Fight.act ~= ACT_MANUAL,"ACT_MANUAL can't select target: SkillManager_MULTI_COLS")
		assert(Fight.act ~= ACT_MMMMMM,"ACT_MMMMMM can't select target: SkillManager_MULTI_COLS")
		local teamAll
		local col = math.floor((Fight.src-1)%3)+1
		if Fight.src < 7 then
				if col == 1 then teamAll = {7,10,8,11,9,12}
			elseif col == 2 then teamAll = {8,11,7,10,9,12}
			elseif col == 3 then teamAll = {9,12,8,11,7,10}
			end
		else
				if col == 1 then teamAll = {4,1,5,2,6,3}
			elseif col == 2 then teamAll = {5,2,4,1,6,3}
			elseif col == 3 then teamAll = {6,3,5,2,4,1}
			end
		end
		for i=1,3 do
			if not Fight.fighters[teamAll[2*i-1]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[2*i-1]
			end
			if not Fight.fighters[teamAll[2*i-0]]:isDead() then
				Fight.dst[#Fight.dst+1] = teamAll[2*i-0]
			end
			if #Fight.dst ~= 0 then
				break
			end
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_1 then --随机1个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,1)
		else
			randomOfTable({4,5,6,1,2,3}	,1)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_2 then --随机2个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,2)
		else
			randomOfTable({4,5,6,1,2,3}	,2)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_3 then --随机3个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,3)
		else
			randomOfTable({4,5,6,1,2,3}	,3)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_4 then --随机4个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,4)
		else
			randomOfTable({4,5,6,1,2,3}	,4)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_RANDOM_5 then --随机5个
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,5)
		else
			randomOfTable({4,5,6,1,2,3}	,5)
		end
	elseif SkillManager[Fight.sid].target == SkillManager_MULTI_ALL then --全体(等同随机6个)
		if Fight.act == ACT_MANUAL or (Fight.act ~= ACT_MMMMMM and Fight.src < 7) then --己方释放技能
			randomOfTable({7,8,9,10,11,12}	,6)
		else
			randomOfTable({4,5,6,1,2,3}	,6)
		end
	end
end

--ScriptEnter开始
function Fight.doScriptEnter()
	local ent = Fight.initData.script[Fight.scriptIndex].enter
	local pos = ent.position
	local fst = ent.data
	local fer = Fight.fighters[pos]
	Fight.setFighterProperties(pos,fst)
	fer:setReady(true)
	Fight.resetLimited()
	Fight.doScriptNext()
end

--ScriptExit开始
function Fight.doScriptExit()
	local pos = Fight.initData.script[Fight.scriptIndex].exit.position
	local fer = Fight.fighters[pos]
	fer:setHP(0)
	Fight.resetLimited()
	Fight.doScriptNext()
end

--ScriptOrder开始
function Fight.doScriptOrder()
	local order = Fight.initData.script[Fight.scriptIndex].order
	if order.reset then
		for i = 1,12 do
			Fight.fighters[i]:setReady(true)
		end
	end
	if #order == 0 then
		Fight.resetPriorityMap()
	else
		Fight.customPriorityMap = order
	end
	Fight.doScriptNext()
end

--脚本(下一回合的脚本)开始
function Fight.doScript()
	-- fast forward for fightIndex
	if Fight.initData.script and Fight.scriptIndex <= #Fight.initData.script and Fight.fightIndex > Fight.initData.script[Fight.scriptIndex].fight then
		local found = false
		for i = Fight.scriptIndex+1,#Fight.initData.script do
			if Fight.fightIndex <= Fight.initData.script[i].fight then
				Fight.scriptIndex = i
				found = true
				break
			end
		end
		if not found then
			Fight.scriptIndex = #Fight.initData.script + 1
		end
	end
	local needIDX = Fight.isFightWin() and -1 or 0
	-- fast forward for zero round
	if Fight.initData.script and Fight.scriptIndex <= #Fight.initData.script and (Fight.isFightOver() or Fight.bigRound == MAX_ROUND_LIMIT) then
		for i = Fight.scriptIndex,#Fight.initData.script do
			Fight.scriptIndex = i
			if Fight.fightIndex ~= Fight.initData.script[i].fight or Fight.initData.script[i].round == needIDX then
				break
			end
		end
	end
	-- execute
	if Fight.initData.script and Fight.scriptIndex <= #Fight.initData.script and Fight.fightIndex == Fight.initData.script[Fight.scriptIndex].fight
			and
			( 	(Fight.isFightOver() or Fight.bigRound == MAX_ROUND_LIMIT) 
				and Fight.initData.script[Fight.scriptIndex].round == needIDX
				or Fight.roundIndex-Fight.roundOrigin+1 == Fight.initData.script[Fight.scriptIndex].round
			)
			then
		local sData = Fight.initData.script[Fight.scriptIndex]
		if sData.enter then
			Fight.doScriptEnter()
		elseif sData.exit then
			Fight.doScriptExit()
		elseif sData.order then
			Fight.doScriptOrder()
		else
			Fight.doScriptNext()
		end
	else
		Fight.onScriptDone()
	end
end

--脚本(下一回合的脚本)下一条
function Fight.doScriptNext()
	Fight.scriptIndex = Fight.scriptIndex + 1
	Fight.doScript() --loop next
end

--脚本(下一回合的脚本)完成
function Fight.onScriptDone()
	local function callOnFightDone()
		Fight.mySkillCardsOrder = nil
		Fight.otherSkillCardsOrder = nil
		Fight.onFightDone()
	end
	if Fight.bigRound == MAX_ROUND_LIMIT then
		callOnFightDone()
	elseif Fight.isFightOver() then
		if Fight.isSelfAlive() and Fight.fightIndex ~= #Fight.initData.otherData then
			Fight.fightIndex = Fight.fightIndex + 1
			Fight.doFight()
		else
			callOnFightDone()
		end
	else
		Fight.doRound()
	end
end

--回合开始
function Fight.doRound()
	Fight.roundIndex = Fight.roundIndex + 1
	--cclog("##################################################### " .. Fight.roundIndex)

	Fight.isEnter  = false
	Fight.isExit   = false
	Fight.getSrc()
	Fight.roundSrc = Fight.src
	Fight.roundDie = false
	Fight.isBurnt  = false
	Fight.isPoisoned=false
	Fight.isCursed = false
	local fer = Fight.fighters[Fight.roundSrc]
	fer:addRound()
	if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
		local pyroLV = fer:getPyroYunLuoXinYan()
		if pyroLV > PYRO_STATE_NULL and Fight.random(1) < PYRO_YunLuoXinYan.var[pyroLV] then
			fer:setHP(fer:getHPMax())
		end
	end
	if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
		local pyroLV = fer:getPyroShengLingZhiYan()
		if pyroLV > PYRO_STATE_NULL and Fight.random(2) < PYRO_ShengLingZhiYan.var[pyroLV] then
			fer:setBufferData(BUFFER_TYPE_FREEZE,nil)
			fer:setBufferData(BUFFER_TYPE_STUN,nil)
			fer:setBufferData(BUFFER_TYPE_SEAL,nil)
		end
	end
	if fer:hasBufferData(BUFFER_TYPE_REGE) then
		local damage = math.floor(fer:getBufferDamage(BUFFER_TYPE_REGE)/3) --!!!调整伤害公式所需的同步修改 /3
		fer:addHP(damage)
		fer:decBufferData(BUFFER_TYPE_REGE)
	end
	if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
		Fight.roundSID = nil
		Fight.roundSkp = true
		Fight.actionPushBack(ACT_STAND,nil,nil,Fight.roundSrc)
	else
		local sid,slv = fer:getRoundSkill(nil)
		assert(sid,"错误：" .. Fight.src .. "号位置第" .. fer:getRound() .. "回合没有可释放技能!")
		Fight.roundSID = sid
		Fight.roundSkp = false
		Fight.actionPushBack(ACT_ROUND,sid,slv,Fight.roundSrc)
	end
	Fight.doAction()
end

--回合完成
function Fight.onRoundDone()
	--回合结束类技能
	local fer = Fight.fighters[Fight.roundSrc]
	if not fer:isDead() then
		local passiveFINISkillID,passiveFINISkillLV = fer:getPassiveFINISkill()
		if passiveFINISkillID then
			local attPercent,defPercent,hpPercent = SkillManager[passiveFINISkillID].finishFunc(passiveFINISkillLV,Fight.random(3))
			fer:addAttackEx(attPercent)
			fer:addDefenceEx(defPercent)
			fer:addHP(math.floor(fer:getHPMax() * hpPercent))
		end
	end
	if Fight.isExtra then
		Fight.isExtra = false
	else
		local pyroLV = fer:getPyroJingLianYaoHuo()
		Fight.isExtra = pyroLV > PYRO_STATE_NULL and Fight.random(4) < PYRO_JingLianYaoHuo.var[pyroLV] or false
		fer:setReady(Fight.isExtra)
	end
	if Fight.isFightOver() then
		Fight.bigRound = Fight.bigRound + 1
		Fight.doManualUpdate()
	elseif Fight.isBigRoundOver() then
		Fight.bigRound = Fight.bigRound + 1
		Fight.doManualUpdate()
	else
		--Fight.doScript()
	end
end

function Fight.doManualUpdate()
	for i = 1,#Fight.mySkillCardsOrder do
		Fight.mySkillCardsOrder[i]:updateCD()
	end
	if not Fight.initData.isPVE then
		for i = 1,#Fight.otherSkillCardsOrder do
			Fight.otherSkillCardsOrder[i]:updateCD()
		end
	end
	--Fight.doScript()
end

-------------------------------------
--队列的一些操作函数

--清空队列
function Fight.clearActions()
	Fight.actionHead = nil
end

--队列中是否还有动作
function Fight.existActions()
	return Fight.actionHead ~= nil
end

--插入队列头
function Fight.actionPushFront(act,sid,slv,src,tag)
	if act ~= ACT_MANUAL and act ~= ACT_MMMMMM then--!!!只能是ACT_MANUAL or ACT_MMMMMM
		return
	end
	if Fight.actionHead == nil or (Fight.actionHead.act ~= ACT_MANUAL and Fight.actionHead.act ~= ACT_MMMMMM) then
		Fight.actionHead = {act = act,sid = sid,slv = slv,src = src,tag = tag,next = Fight.actionHead}
	else
		local pre = Fight.actionHead
		local cur = pre.next
		while cur and (cur.act == ACT_MANUAL or cur.act == ACT_MMMMMM) do
			pre = cur
			cur = cur.next
		end
		pre.next = {act = act,sid = sid,slv = slv,src = src,tag = tag,next = cur}
	end
end

--追加队列尾
function Fight.actionPushBack(act,sid,slv,src)
	local e = {act = act,sid = sid,slv = slv,src = src,next = nil}
	if Fight.actionHead == nil then
		Fight.actionHead = e
	else
		if act == ACT_EXIT then --!!!修正队列中的无效动作
			local i = Fight.actionHead
			while i.next do
				if i.next.src == src then
					i.next = i.next.next
				else
					i = i.next
				end
			end
			i.next = e
			if Fight.actionHead.src == src then
				Fight.actionHead = Fight.actionHead.next
			end
		else
			local i = Fight.actionHead
			while i.next do
				i = i.next
			end
			i.next = e
		end
	end
end

--移除队列头
function Fight.actionRemoveFront()
	Fight.actionHead = Fight.actionHead.next
end

--获取队列头
function Fight.actionPopFront()
	Fight.act = Fight.actionHead.act
	Fight.sid = Fight.actionHead.sid
	Fight.slv = Fight.actionHead.slv
	Fight.src = Fight.actionHead.src
	Fight.tag = Fight.actionHead.tag
	Fight.dst = {}
	Fight.actionHead = Fight.actionHead.next
end

--获取队列尾
--function Fight.actionPopBack()
--end

--打印队列
function Fight.debugPrintActions(isSingle)
	if Fight.actionHead ~= nil then
		--cclog("########")
		local name = {"普通","上场","下场","反击","手动","站立","掉血","中毒","诅咒","回血","敌手","异火入场","异火下场"}
		local curr = Fight.actionHead
		repeat
			--cclog(name[curr.act] .. " " .. ((curr.act == ACT_MANUAL or curr.act == ACT_MMMMMM) and curr.tag or curr.src))
			if isSingle then
				break
			end
			curr = curr.next
		until curr == nil
	end
end

--动作开始
function Fight.doAction()
	Fight.debugPrintActions(true)
	--pop
	Fight.actionPopFront()
	Fight.actionIndex = Fight.actionIndex + 1
	if Fight.act == ACT_MANUAL then
		Fight.initData.record.manualAct[#Fight.initData.record.manualAct + 1] = {index=Fight.actionIndex,tag = Fight.tag,rIndex=Fight.roundIndex}
	elseif Fight.act == ACT_MMMMMM then
		Fight.initData.record.mmmmmmAct[#Fight.initData.record.mmmmmmAct + 1] = {index=Fight.actionIndex,tag = Fight.tag,rIndex=Fight.roundIndex}
	end
	--do
	if Fight.act == ACT_ROUND or Fight.act == ACT_ENTER2 or Fight.act == ACT_EXIT2 then
		Fight.doSelectTarget()
	elseif Fight.act == ACT_ENTER then
		local fst = nil
		if Fight.src < 7 then
			if Fight.mySubstituteIdx >= #Fight.initData.myData.substitute then
				Fight.onActionDone()
				return
			end
			Fight.mySubstituteIdx = Fight.mySubstituteIdx + 1
			fst = Fight.initData.myData.substitute[Fight.mySubstituteIdx]
		else
			if Fight.otherSubstituteIdx >= #Fight.initData.otherData[Fight.fightIndex].substitute then
				Fight.onActionDone()
				return
			end
			Fight.otherSubstituteIdx = Fight.otherSubstituteIdx + 1
			fst = Fight.initData.otherData[Fight.fightIndex].substitute[Fight.otherSubstituteIdx]
		end
		Fight.setFighterProperties(Fight.src,fst)
		Fight.sid,Fight.slv = Fight.fighters[Fight.src]:getEnterSkill() --补充上场技能sid
		Fight.doEnter()
	elseif Fight.act == ACT_EXIT then
		if Fight.sid then
			Fight.doSelectTarget()
		else
			Fight.doRevive()
		end
	elseif Fight.act == ACT_COUNTER then
		Fight.doSelectTarget()
	elseif Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.doSelectTarget()
	elseif Fight.act == ACT_STAND then
		Fight.doStand()
	elseif Fight.act == ACT_BURN then
		Fight.doBurn()
	elseif Fight.act == ACT_POISON then
		Fight.doPoison()
	elseif Fight.act == ACT_CURSE then
		Fight.doCurse()
	end
end

--动作完成
function Fight.onActionDone()
	--debug status
	--cclog(string.format("-------------------------------------------------"))
	for i=10,1,-3 do
		local logstr = "|"
		for j=0,2 do
			local fer = Fight.fighters[i + j]
			if fer:isDead() then
				logstr = logstr .. "               |"
			else
				logstr = logstr .. string.format(" %4d %-8d |",fer:getRound(),fer:getHP())
			end
		end
		--cclog(logstr)
	end
	--cclog(string.format("-------------------------------------------------"))
	
	if Fight.act == ACT_MANUAL then
		Fight.mySkillCardsOrder[Fight.tag]:setState(SKILL_CARD_STATE_RELEASED)
	elseif Fight.act == ACT_MMMMMM then
		Fight.otherSkillCardsOrder[Fight.tag]:setState(SKILL_CARD_STATE_RELEASED)
	end
	--检查连锁反应
	--dst 反击
	if Fight.act == ACT_ROUND or Fight.act == ACT_ENTER2 or Fight.act == ACT_EXIT2 then
		for i=1,#Fight.dst do
			local dst = Fight.fighters[Fight.dst[i]]
			if not dst:isDead() and dst:isCounter() and not dst:hasBufferData(BUFFER_TYPE_FREEZE) and not dst:hasBufferData(BUFFER_TYPE_STUN) and not dst:hasBufferData(BUFFER_TYPE_SEAL) then --!!! 没有禁止行动Buffer时才可反击
				local sid,slv = dst:getCounterSkill()
				if sid then
					if SkillManager[sid].counterProbability > Fight.random(5) then
						Fight.actionPushBack(ACT_COUNTER,sid,slv,Fight.dst[i])
					end
				end
			end
		end
	end
	--dst 死亡
	for i=1,#Fight.dst do
		local pos = Fight.dst[i]
		local dst = Fight.fighters[pos]
		if dst:isDead() then
			if pos == Fight.roundSrc then
				Fight.roundDie = true
			end
			local sid,slv = dst:getExitSkill()
			Fight.actionPushBack(ACT_EXIT,sid,slv,pos)
			Fight.actionPushBack(ACT_ENTER,nil,nil,pos)
		end
	end
	--src 死亡
	if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM and Fight.act ~= ACT_ENTER and Fight.act ~= ACT_EXIT then --手动技和下场技不检测src死亡
		local pos = Fight.src
		local src = Fight.fighters[pos]
		if src:isDead() then --!!! 循环死亡的Bug.
			if pos == Fight.roundSrc then
				Fight.roundDie = true
			end
			local sid,slv = src:getExitSkill()
			Fight.actionPushBack(ACT_EXIT,sid,slv,pos)
			Fight.actionPushBack(ACT_ENTER,nil,nil,pos)
		end
	end
	--如果队列中还有动作
	if Fight.existActions() then
		Fight.doAction()
		return
	end
	--如果该角色死亡则结束其回合
	if Fight.roundDie then
		Fight.onRoundDone()
		return
	end
	--否则该角色继续其他技能
	if not Fight.roundSkp then
		local fer = Fight.fighters[Fight.roundSrc]
		if fer:hasBufferData(BUFFER_TYPE_FREEZE) or fer:hasBufferData(BUFFER_TYPE_STUN) or fer:hasBufferData(BUFFER_TYPE_SEAL) then
			Fight.roundSkp = true
		else
			local sid,slv = fer:getRoundSkill(Fight.roundSID)
			if sid then
				Fight.roundSID = sid
				Fight.actionPushBack(ACT_ROUND,sid,slv,Fight.roundSrc)
				Fight.doAction()
				return
			end
			--异火入场技
			if not Fight.isEnter then
				Fight.isEnter = true
				local sid,slv = fer:getEnterSkill()
				if sid then
					local pyroLV = fer:getPyroJinDiFenTianYan()
					if pyroLV > PYRO_STATE_NULL and Fight.random(6) < PYRO_JinDiFenTianYan.var[pyroLV] then
						Fight.actionPushBack(ACT_ENTER2,sid,slv,Fight.roundSrc)
						Fight.doAction()
						return
					end
				end
			end
			--异火下场技
			if not Fight.isExit then
				Fight.isExit = true
				local sid,slv = fer:getExitSkill()
				if sid then
					local pyroLV = fer:getPyroXuWuTunYan()
					if pyroLV > PYRO_STATE_NULL and Fight.random(7) < PYRO_XuWuTunYan.var[pyroLV] then
						Fight.actionPushBack(ACT_EXIT2,sid,slv,Fight.roundSrc)
						Fight.doAction()
						return
					end
				end
			end
		end
	end
	--所有该角色的主动操作完毕，检测其回合结束触发的Buffer
	local fer = Fight.fighters[Fight.roundSrc]
	if fer:hasBufferData(BUFFER_TYPE_BURN) and not Fight.isBurnt then
		Fight.isBurnt = true
		Fight.actionPushBack(ACT_BURN,nil,nil,Fight.roundSrc)
		Fight.doAction()
		return
	end
	if fer:hasBufferData(BUFFER_TYPE_POISON) and not Fight.isPoisoned then
		Fight.isPoisoned = true
		Fight.actionPushBack(ACT_POISON,nil,nil,Fight.roundSrc)
		Fight.doAction()
		return
	end
	if fer:hasBufferData(BUFFER_TYPE_CURSE) and not Fight.isCursed then
		Fight.isCursed = true
		Fight.actionPushBack(ACT_CURSE,nil,nil,Fight.roundSrc)
		Fight.doAction()
		return
	end
	--若是PVP则自动释放手动技能 --todo 谁先手
	--己方
	if Fight.isBigRoundOver() then
		for i = 1,#Fight.mySkillCardsOrder do
			if Fight.mySkillCardsOrder[i]:getState() == SKILL_CARD_STATE_NORMAL then
				Fight.mySkillCardsOrder[i]:setState(SKILL_CARD_STATE_PRESSED)
				local manualSkill = Fight.initData.myData.skillCards[i]
				Fight.actionPushFront(ACT_MANUAL,manualSkill.id,manualSkill.lv,nil,i)
				Fight.doAction()
				return
			end
		end
	end
	--敌方
	if not Fight.initData.isPVE and Fight.isBigRoundOver() then
		for i = 1,#Fight.otherSkillCardsOrder do
			if Fight.otherSkillCardsOrder[i]:getState() == SKILL_CARD_STATE_NORMAL then
				Fight.otherSkillCardsOrder[i]:setState(SKILL_CARD_STATE_PRESSED)
				local mmmmmmSkill = Fight.initData.otherData[1].skillCards[i]
				Fight.actionPushFront(ACT_MMMMMM,mmmmmmSkill.id,mmmmmmSkill.lv,nil,i)
				Fight.doAction()
				return
			end
		end
	end
	--回合结束
	Fight.onRoundDone()
end

--选择目标开始
function Fight.doSelectTarget()
	Fight.damages = {}
	Fight.getDst()
	if #Fight.dst > 0 then
		Fight.yokeDst = Fight.dst[Fight.random(25,1,#Fight.dst)]
	else
		Fight.yokeDst = 0 -- or nil
	end
	for i = 1,#Fight.dst do --重置反击参数
		Fight.fighters[Fight.dst[i]]:setCounter(false)
	end
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM or #Fight.dst ~= 0 then
		Fight.doBufferIncrease()
	elseif Fight.act == ACT_EXIT then
		Fight.doRevive()
	else
		Fight.onActionDone()
	end
end

--增幅Buffer开始
function Fight.doBufferIncrease()
	--base
	Fight.isMana  = SkillManager[Fight.sid].isMana
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--基础攻击
		Fight.baseAtt = 0
		--异火攻击加成
		Fight.pyroAtt = 0
		--攻击永久增幅
		Fight.permAtt = 0
	else
		local src = Fight.fighters[Fight.src]
		--基础攻击
		Fight.baseAtt = math.floor(src:getAttack(Fight.isMana))
		--增幅类技能:物攻转法攻or法攻转物攻
		local passiveTRANSkillID,passiveTRANSkillLV = src:getPassiveTRANSkill()
		if passiveTRANSkillID then
			Fight.baseAtt = Fight.baseAtt + math.floor(
				SkillManager[passiveTRANSkillID].addFunc(
					passiveTRANSkillLV,
					Fight.isMana,
					src:getAttack(false), --取消math.floor
					src:getAttack(true),  --取消math.floor
					Fight.random(27)
				)
			)
		end
		--异火攻击加成
		local pyroLV = src:getPyroQingLianDiXinHuo()
		if pyroLV > PYRO_STATE_NULL and src:getHP() == src:getHPMax() then
			Fight.pyroAtt = math.floor(PYRO_QingLianDiXinHuo.var[pyroLV] * Fight.baseAtt)
		else
			Fight.pyroAtt = 0
		end
		--攻击永久增幅
		Fight.permAtt = math.floor(src:getAttackEx() * Fight.baseAtt)
	end
	
	--do
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.bufAAtt = 0
	else
		local src = Fight.fighters[Fight.src]
		--攻击Buffer增幅
		if src:hasBufferData(BUFFER_TYPE_INCREASE) then
			Fight.bufAAtt = math.floor(src:getBufferAttackPercent(BUFFER_TYPE_INCREASE) * Fight.baseAtt + src:getBufferAttackNumber(BUFFER_TYPE_INCREASE))
			src:decBufferData(BUFFER_TYPE_INCREASE)
		else
			Fight.bufAAtt = 0
		end
	end
	Fight.doBufferDecrease()
end

--减幅Buffer开始
function Fight.doBufferDecrease()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		Fight.bufDAtt = 0
	else
		local src = Fight.fighters[Fight.src]
		--攻击Buffer减幅
		if src:hasBufferData(BUFFER_TYPE_DECREASE) then
			Fight.bufDAtt = math.floor(src:getBufferAttackPercent(BUFFER_TYPE_DECREASE) * Fight.baseAtt + src:getBufferAttackNumber(BUFFER_TYPE_DECREASE))
			src:decBufferData(BUFFER_TYPE_DECREASE)
		else
			Fight.bufDAtt = 0
		end
	end
	Fight.doAttack()
end

--攻击开始
function Fight.doAttack()
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--手动技能，攻击增幅类技能数值为0
		Fight.incrAtt = 0
		Fight.deadAtt = 0
	else
		local src = Fight.fighters[Fight.src]
		--攻击增幅类技能，概率判定
		Fight.incrAtt = 0
		local passivePROBSkillID,passivePROBSkillLV = src:getPassivePROBSkill()
		if passivePROBSkillID then
			Fight.incrAtt = math.floor(SkillManager[passivePROBSkillID].addFunc(passivePROBSkillLV,Fight.isMana,Fight.baseAtt,Fight.random(8)))
		end
		--攻击增幅类技能，死亡人数判定
		Fight.deadAtt = 0
		local passiveDEADSkillID,passiveDEADSkillLV = src:getPassiveDEADSkill()
		if passiveDEADSkillID then
			Fight.deadAtt = math.floor(
				SkillManager[passiveDEADSkillID].addFunc(
					passiveDEADSkillLV,
					Fight.baseAtt,
					Fight.src < 7 and Fight.myDeaths    or Fight.otherDeaths,
					Fight.src < 7 and Fight.otherDeaths or Fight.myDeaths
				)
			)
		end
	end
	for i=1,#Fight.dst do
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+0] = Fight.random(9)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+12] = Fight.random(10)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+24] = Fight.random(11)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+36] = Fight.random(12,FLOAT_DAMAGE_PERCENT_MIN,FLOAT_DAMAGE_PERCENT_MAX)/100
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+48] = Fight.random(13)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+60] = Fight.random(14)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+72] = Fight.random(15)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+84] = Fight.random(16)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+96] = Fight.random(17)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+108] = Fight.random(18)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+120] = Fight.random(19)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+132] = Fight.random(20)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+144] = Fight.random(21)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+156] = Fight.random(22)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+168] = Fight.random(23)
		Fight.FIX_BUG_OF_GET_RANDOM[Fight.dst[i]+192] = Fight.random(25)
	end
	--!!!不判断Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM，assert:Fight.dst不包含Fight.src
	Fight.FIX_BUG_OF_GET_RANDOM[Fight.src+180] = Fight.random(24)
	for i = 1,#Fight.dst do
		Fight.doEffect(Fight.dst[i])
	end
	Fight.doSetupBufferOfYokeLight()
end

--打击光效开始
function Fight.doEffect(pos)
	local dst = Fight.fighters[pos]
	--回复
	if SkillManager[Fight.sid].regeFunc then
		if dst:hasBufferData(BUFFER_TYPE_CURELESS) then
			Fight.doCureless(pos)
		else
			Fight.doRege(pos)
		end
	else
		if SkillManager[Fight.sid].clearFunc then
			Fight.doClear(pos)
		else
			--闪避
			local function isDodge()
				if SkillManager[Fight.sid].target > 0 and Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
					local src = Fight.fighters[Fight.src]
					--闪避率=0.4*敌方闪避/(敌方闪避+本方命中)+0.6*敌方闪避率*(1-4*本方命中率)
					local dodgeRatio = (0.4*dst:getDodge()/(dst:getDodge()+src:getHit()) + 0.6*dst:getDodgeRatio()*(1-4*src:getHitRatio()))
					dodgeRatio = dodgeRatio < 0.00 and 0.00 or dodgeRatio
					dodgeRatio = dodgeRatio > 0.15 and 0.15 or dodgeRatio
					if Fight.FIX_BUG_OF_GET_RANDOM[pos+0] < dodgeRatio then
						return true
					end
				end
				return false
			end
			local dodgable = true
			if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
				local src = Fight.fighters[Fight.src]
				local pyroLV = src:getPyroWanShouLingYan()
				if pyroLV > PYRO_STATE_NULL then
					dodgable = not PYRO_WanShouLingYan.var[pyroLV]
				end
			end
			if dodgable and isDodge() then
			else
				--免疫攻击
				local passiveIMATSkillID,passiveIMATSkillLV = dst:getPassiveIMATSkill()
				if SkillManager[Fight.sid].target > 0 and not SkillManager[Fight.sid].ignoreIMRE
					and (
							(passiveIMATSkillID and SkillManager[passiveIMATSkillID].immunityAttackFunc(passiveIMATSkillLV,Fight.isMana,Fight.FIX_BUG_OF_GET_RANDOM[pos+12]))
							or Fight.FIX_BUG_OF_GET_RANDOM[pos+168] < (Fight.isMana and dst:getImmunityManaRatio() or dst:getImmunityPhscRatio())
						)
					then
				else--承受
					if SkillManager[Fight.sid].attackFunc then
						Fight.doInjure(pos)
					else
						Fight.doSetupBufferOfSkill(pos)
					end
				end
			end
		end
	end
end

--无法被治疗开始
function Fight.doCureless(pos)
	local dst = Fight.fighters[pos]
	dst:decBufferData(BUFFER_TYPE_CURELESS)
	Fight.doClear(pos)
end

--回复开始
function Fight.doRege(pos)
	local dst = Fight.fighters[pos]
	local regeHP = math.floor(SkillManager[Fight.sid].regeFunc(Fight.slv,Fight.baseAtt + Fight.pyroAtt + Fight.permAtt + Fight.bufAAtt - Fight.bufDAtt)/3) --!!!调整伤害公式所需的同步修改 /3
	local pyroLV = Fight.fighters[Fight.src]:getPyroHaiXinYan()
	if pyroLV > PYRO_STATE_NULL then
		regeHP = dst:getHPMax()
		dst:addDefenceEx(PYRO_HaiXinYan.var[pyroLV])
	end
	dst:addHP(regeHP)
	Fight.doClear(pos)
end

--清除Buffer开始
function Fight.doClear(pos)
	if SkillManager[Fight.sid].clearFunc then
		local dst = Fight.fighters[pos]
		local bufferIDs = SkillManager[Fight.sid].clearFunc(Fight.slv)
		for i=1,#bufferIDs do
			dst:setBufferData(bufferIDs[i],nil)
		end
	end
end

--Buffer减伤开始
function Fight.doReduction(pos)
	local dst = Fight.fighters[pos]
	dst:decBufferData(BUFFER_TYPE_REDUCTION)
end

--受伤开始
function Fight.doInjure(pos)
	local dst = Fight.fighters[pos]
	local def = math.floor(dst:getDefence(Fight.isMana))
	def = def + math.floor(def * dst:getDefenceEx()) --防御永久增幅
	local damageType = DAMAGE_TYPE_GENERIC
	local skilAtt = 0
	if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
		--计算技能攻击值
		skilAtt = math.floor(SkillManager[Fight.sid].attackFunc(
			Fight.slv,
			Fight.baseAtt + Fight.pyroAtt + Fight.permAtt + Fight.bufAAtt - Fight.bufDAtt,
			Fight.isMana,
			0,
			0,
			dst:getHP(),
			dst:getHPMax(),
			Fight.act == ACT_MANUAL and Fight.myDeaths or Fight.otherDeaths,
			Fight.act == ACT_MMMMMM and Fight.myDeaths or Fight.otherDeaths,
			Fight.FIX_BUG_OF_GET_RANDOM[pos+108],
			{},
			dst:getBufferTypes(),
			Fight.initData.isBoss
		))
		--手动技能，攻击增幅类技能数值为0
		Fight.hphpAtt = 0 --攻击增幅类技能，血量对比判定
		Fight.buffAtt = 0 --攻击增幅类技能，目标Buff判定
	else
		local src = Fight.fighters[Fight.src]
		--计算技能攻击值
		skilAtt = math.floor(SkillManager[Fight.sid].attackFunc(
			Fight.slv,
			Fight.baseAtt + Fight.pyroAtt + Fight.permAtt + Fight.bufAAtt - Fight.bufDAtt,
			Fight.isMana,
			src:getHP(),
			src:getHPMax(),
			dst:getHP(),
			dst:getHPMax(),
			Fight.src < 7 and Fight.myDeaths    or Fight.otherDeaths,
			Fight.src < 7 and Fight.otherDeaths or Fight.myDeaths,
			Fight.FIX_BUG_OF_GET_RANDOM[pos+108],
			src:getBufferTypes(),
			dst:getBufferTypes(),
			Fight.initData.isBoss
		))
		--暴击
		local function isCrit()
			if dst:getRenXing() == 0 then
				return true
			end
			--暴击率=0.4*本方暴击/(本方暴击+敌方韧性)+0.6*本方暴击率*(1-4*敌方韧性率)+斗魂本方增暴击/2-敌方斗魂减暴击/2              韧性率==抗暴率
			local critRatio = 0.4*src:getCrit()/(src:getCrit()+dst:getRenXing()) + 0.6*src:getCritRatio()*(1-4*dst:getRenXingRatio()) + src:getCritRatioDHAdd()/2 - dst:getCritRatioDHSub()/2
			critRatio = critRatio < 0.0 and 0.0 or critRatio
			critRatio = critRatio > 0.3 and 0.3 or critRatio
			if Fight.FIX_BUG_OF_GET_RANDOM[pos+24] < critRatio then
				return true
			end
			return false
		end
		if isCrit() then
			damageType = DAMAGE_TYPE_CRIT
		end
		--攻击增幅类技能，血量对比判定
		Fight.hphpAtt = 0
		local passiveHPHPSkillID,passiveHPHPSkillLV = src:getPassiveHPHPSkill()
		if passiveHPHPSkillID then
			Fight.hphpAtt = math.floor(SkillManager[passiveHPHPSkillID].addFunc(passiveHPHPSkillLV,Fight.baseAtt,src:getHP(),dst:getHP()))
		end
		--攻击增幅类技能，目标Buff判定
		Fight.buffAtt = 0
		local passiveBUFFSkillID,passiveBUFFSkillLV = src:getPassiveBUFFSkill()
		if passiveBUFFSkillID then
			local bufferTypes = dst:getBufferTypes()
			Fight.buffAtt = math.floor(SkillManager[passiveBUFFSkillID].addFunc(passiveBUFFSkillLV,Fight.baseAtt,bufferTypes))
		end
	end
	--计算综合攻击值
	local att = skilAtt + Fight.incrAtt + Fight.hphpAtt + Fight.buffAtt + Fight.deadAtt
	--计算伤害值公式：伤害=攻击/3*(1-减伤比)	!!!!	减伤比=防御/(防御+属性增值*70)
	local reducePercent = def/(def+dst:getSXZZ()*70)
	reducePercent = math.min(reducePercent,0.3)
	reducePercent = math.max(reducePercent,0.0)
	local damageOri=math.floor(att/4*(1-reducePercent))
	if damageOri < 10 then
		damageOri = 10
	end
	damageOri = math.floor(damageOri * SkillManager[Fight.sid].damageRatio)
	damageOri = math.floor(damageOri * Fight.FIX_BUG_OF_GET_RANDOM[pos+36])
	local damageCur = damageOri
	--是否无视减伤
	local isIgnoreIMRE = false
	if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
		local src = Fight.fighters[Fight.src]
		local pyroLV = src:getPyroWanShouLingYan()
		isIgnoreIMRE = pyroLV > PYRO_STATE_NULL
	end
	if not isIgnoreIMRE and not SkillManager[Fight.sid].ignoreIMRE then
		--减伤类技能
		local passiveREDUSkillID,passiveREDUSkillLV = dst:getPassiveREDUSkill()
		if passiveREDUSkillID then
			damageCur = damageCur - math.floor(SkillManager[passiveREDUSkillID].reduceFunc(passiveREDUSkillLV,Fight.isMana,damageCur,Fight.FIX_BUG_OF_GET_RANDOM[pos+48]))
		end
		--减伤Buffer
		if dst:hasBufferData(BUFFER_TYPE_REDUCTION) then
			damageCur = damageCur - math.floor(dst:getBufferDamagePercent(BUFFER_TYPE_REDUCTION) * damageOri + dst:getBufferDamageNumber(BUFFER_TYPE_REDUCTION))
			Fight.doReduction(pos)
		end
	end
	--风系羁绊增加伤害
	if Fight.fighters[Fight.src]:hasYokeWind() then
		if Fight.FIX_BUG_OF_GET_RANDOM[pos+144] < YOKE_Wind.chance then
			damageCur = math.floor(damageCur * (1+YOKE_Wind.damageIncrease))
		end
	end
	--暴击
	if damageType == DAMAGE_TYPE_CRIT then
		local critDamageX = CRIT_DAMAGE_X
		if Fight.act ~= ACT_MANUAL or Fight.act ~= ACT_MMMMMM then
			local src = Fight.fighters[Fight.src]
			critDamageX = critDamageX + src:getCritPercentAdd() - dst:getCritPercentSub()
			critDamageX = math.min(critDamageX,CRIT_DAMAGE_MAX)
			critDamageX = math.max(critDamageX,CRIT_DAMAGE_MIN)
		end
		damageCur = math.floor(damageCur * critDamageX)
	end
	--修正最终伤害值
	if damageCur < 0 then
		damageCur = 0
	end
	damageCur = math.floor(damageCur * (1+Fight.fighters[Fight.src]:getSHJC()/100))
	--战力减伤
	if pos < 7 then
		damageCur = math.floor(damageCur * (1-Fight.myPowerReduction))
	else
		damageCur = math.floor(damageCur * (1-Fight.otherPowerReduction))
	end
	Fight.damages[pos] = damageCur
	local immunityCount = dst:getImmunityCount(Fight.isMana)
	if not Fight.initData.isBoss and immunityCount > 0 then
		dst:setImmunityCount(Fight.isMana,immunityCount - 1)
	else
		local hpLimit
		if SkillManager[Fight.sid].subHpLimit then
			if Fight.act == ACT_MANUAL or Fight.act == ACT_MMMMMM then
				hpLimit = math.floor(SkillManager[Fight.sid].subHpLimit(
					Fight.slv,
					damageCur,
					Fight.FIX_BUG_OF_GET_RANDOM[pos+192],
					0,
					0,
					dst:getHP(),
					dst:getHPMax(),
					Fight.act == ACT_MANUAL and Fight.myDeaths or Fight.otherDeaths,
					Fight.act == ACT_MMMMMM and Fight.myDeaths or Fight.otherDeaths,
					{},
					dst:getBufferTypes()
				))
			else
				local src = Fight.fighters[Fight.src]
				hpLimit = math.floor(SkillManager[Fight.sid].subHpLimit(
					Fight.slv,
					damageCur,
					Fight.FIX_BUG_OF_GET_RANDOM[pos+192],
					src:getHP(),
					src:getHPMax(),
					dst:getHP(),
					dst:getHPMax(),
					Fight.src < 7 and Fight.myDeaths    or Fight.otherDeaths,
					Fight.src < 7 and Fight.otherDeaths or Fight.myDeaths,
					src:getBufferTypes(),
					dst:getBufferTypes()
				))
			end
		end
		local dstLastHP = dst:getHP()
		dst:subHP(damageCur,hpLimit)
		if not Fight.initData.isBoss or Fight.src ~= BOSS_POSITION then
			local passiveREBOUNDSkillID,passiveREBOUNDSkillLV = dst:getPassiveREBOUNDSkill()
			if passiveREBOUNDSkillID then
				local reboundDamage = math.floor(SkillManager[passiveREBOUNDSkillID].reboundFunc(passiveREBOUNDSkillLV,damageCur,dst:getBufferTypes()))
				if reboundDamage and reboundDamage > 0 then
					local src = Fight.fighters[Fight.src]
					local srcLastHP = src:getHP()
					src:subHP(reboundDamage)
					if Fight.src > 6 then
						Fight.otherDamage = Fight.otherDamage + srcLastHP - src:getHP()
					end
				end
			end
		end
		if pos > 6 then
			Fight.otherDamage = Fight.otherDamage + dstLastHP - dst:getHP()
		end
		--暗系羁绊吸血
		if Fight.fighters[Fight.src]:hasYokeDark() then
			if Fight.FIX_BUG_OF_GET_RANDOM[pos+156] < YOKE_Dark.chance then
				Fight.fighters[Fight.src]:addHP(math.floor(damageCur * YOKE_Dark.lifeSteal))
			end
		end
		dst:setCounter(damageCur ~= 0) --!!! 伤害为0时不反击
	end
	--结算类技能
	if Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
		local src = Fight.fighters[Fight.src]
		if not src:isDead() then
			local passiveSETASkillID,passiveSETASkillLV = src:getPassiveSETASkill()  --主动方
			if passiveSETASkillID then
				local attPercent,defPercent,hpPercent = SkillManager[passiveSETASkillID].sattlementFunc(passiveSETASkillLV,Fight.FIX_BUG_OF_GET_RANDOM[pos+60])
				if attPercent >= 0 then --att
					src:addAttackEx(attPercent)
				else
					dst:addAttackEx(attPercent)
				end
				if defPercent >= 0 then --def
					src:addDefenceEx(defPercent)
				else
					dst:addDefenceEx(defPercent)
				end
				src:addHP(math.floor(damageCur * hpPercent)) --吸血
			end
		end
	end
	local passiveSETPSkillID,passiveSETPSkillLV = dst:getPassiveSETPSkill() --被动方
	if passiveSETPSkillID then
		local attPercent,defPercent = SkillManager[passiveSETPSkillID].sattlementFunc(passiveSETPSkillLV,Fight.FIX_BUG_OF_GET_RANDOM[pos+72])
		if attPercent >= 0 then --att
			dst:addAttackEx(attPercent)
		elseif Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
			Fight.fighters[Fight.src]:addAttackEx(attPercent)
		end
		if defPercent >= 0 then --def
			dst:addDefenceEx(defPercent)
		elseif Fight.act ~= ACT_MANUAL and Fight.act ~= ACT_MMMMMM then
			Fight.fighters[Fight.src]:addDefenceEx(defPercent)
		end
	end
	Fight.doSetupBufferOfSkill(pos)
end

--安装BufferOfSkill开始
function Fight.doSetupBufferOfSkill(pos)
	local fer = Fight.fighters[pos]
	if not fer:isDead() and SkillManager[Fight.sid].setupBuffer then --活着才安装
		local buffer = SkillManager[Fight.sid].setupBuffer(Fight.slv,Fight.baseAtt + Fight.permAtt,Fight.damages[pos],Fight.FIX_BUG_OF_GET_RANDOM[pos+84])
		if buffer then
			local passiveIMBFSkillID,passiveIMBFSkillLV = fer:getPassiveIMBFSkill()
			if not passiveIMBFSkillID or not SkillManager[passiveIMBFSkillID].immunityBufferFunc(passiveIMBFSkillLV,buffer.type,Fight.FIX_BUG_OF_GET_RANDOM[pos+96]) then
				fer:setBufferData(buffer.type,buffer)
			end
		end
	end
	Fight.doSetupBufferOfYokeThunder(pos)
end

--安装BufferOfYokeThunder开始
function Fight.doSetupBufferOfYokeThunder(pos)
	local fer = Fight.fighters[pos]
	if not fer:isDead() and Fight.fighters[Fight.src]:hasYokeThunder() and Fight.yokeDst == pos and SkillManager[Fight.sid].target > 0 then --活着才安装，!!!Fix且目标必须是对方
		--雷系羁绊产生眩晕Buffer
		if Fight.FIX_BUG_OF_GET_RANDOM[pos+120] < YOKE_Thunder.chance then
			local buffer = createBufferStun(YOKE_Thunder.bufStrength,YOKE_Thunder.bufTimes)
			local passiveIMBFSkillID,passiveIMBFSkillLV = fer:getPassiveIMBFSkill()
			if not passiveIMBFSkillID or not SkillManager[passiveIMBFSkillID].immunityBufferFunc(passiveIMBFSkillLV,buffer.type,Fight.FIX_BUG_OF_GET_RANDOM[pos+132]) then
				fer:setBufferData(buffer.type,buffer)
			end
		end
	end
end

--安装BufferOfYokeLight开始
function Fight.doSetupBufferOfYokeLight()
	local fer = Fight.fighters[Fight.src]
	if not fer:isDead() and fer:hasYokeLight() then --活着才安装
		--光系羁绊产生护盾Buffer
		if Fight.FIX_BUG_OF_GET_RANDOM[Fight.src+180] < YOKE_Light.chance then
			local buffer = createBufferReduction(YOKE_Light.bufStrength,YOKE_Light.bufTimes,YOKE_Light.bufPercent,YOKE_Light.bufNumber)
			fer:setBufferData(buffer.type,buffer)
		end
	end
	Fight.doRunBack()
end

--RunBack开始
function Fight.doRunBack()
	if Fight.act == ACT_EXIT then
		Fight.doRevive()
	else
		Fight.onActionDone()
	end
end

--上场开始
function Fight.doEnter()
	Fight.resetLimited()
	if Fight.sid then
		Fight.doSelectTarget()
	else
		Fight.onActionDone()
	end
end

--复活开始
function Fight.doRevive()
	--是否统计死亡次数
	local fer = Fight.fighters[Fight.src]
	local reviveCount = fer:getReviveCount()
	local passiveREVIVESkillID,passiveREVIVESkillLV = fer:getPassiveREVIVESkill()
	if passiveREVIVESkillID and SkillManager[passiveREVIVESkillID].reviveFunc(passiveREVIVESkillLV,reviveCount+1,Fight.random(26)) then
		fer:setReviveCount(reviveCount + 1)
		local hpLmt,hpCur,phscA,manaA,phscD,manaD = SkillManager[passiveREVIVESkillID].hpAttackDefence(
			passiveREVIVESkillLV,reviveCount + 1,
			fer:getHPMax(),fer:getHPLmt(),
			fer:getOriginalAttack(false),fer:getOriginalAttack(true),
			fer:getOriginalDefence(false),fer:getOriginalDefence(true)
		)
		fer:setHPLmt(math.floor(hpLmt))
		fer:setHP(math.floor(hpCur))
		fer:setAttacks(phscA,manaA)
		fer:setDefences(phscD,manaD)
		fer:clearBuffers()
		Fight.actionRemoveFront() --移除队列中下一条上场动作
		Fight.onActionDone()
	else
		Fight.doExit()
	end
end

--下场开始
function Fight.doExit()
	Fight.fighters[Fight.src]:setHP(0)
	if Fight.src < 7 then
		Fight.myDeaths = Fight.myDeaths + 1
		Fight.fightersHP[Fight.fighters[Fight.src]:getCardID()] = 0
	else
		Fight.otherDeaths = Fight.otherDeaths + 1
	end
	Fight.resetLimited()
	Fight.onActionDone()
end

--站立开始
function Fight.doStand()
	local src = Fight.fighters[Fight.src]
	local which = src:hasBufferData(BUFFER_TYPE_FREEZE) and BUFFER_TYPE_FREEZE
		or src:hasBufferData(BUFFER_TYPE_STUN) and BUFFER_TYPE_STUN
		or BUFFER_TYPE_SEAL
	src:decBufferData(which)
	Fight.onActionDone()
end

--Burn开始
function Fight.doBurn()
	local src = Fight.fighters[Fight.src]
	local bufferReduce = src:getBufBurnReduction()
	bufferReduce = math.min(bufferReduce,BUFFER_REDUCE_MAX)
	bufferReduce = math.max(bufferReduce,BUFFER_REDUCE_MIN)
	local damage = math.floor(src:getBufferDamage(BUFFER_TYPE_BURN) * (1-bufferReduce))
	if Fight.src > 6 then
		Fight.otherDamage = Fight.otherDamage + math.min(damage,src:getHP())
	end
	src:subHP(damage)
	src:decBufferData(BUFFER_TYPE_BURN)
	Fight.onActionDone()
end

--Poison开始
function Fight.doPoison()
	local src = Fight.fighters[Fight.src]
	local bufferReduce = src:getBufPoisonReduction()
	bufferReduce = math.min(bufferReduce,BUFFER_REDUCE_MAX)
	bufferReduce = math.max(bufferReduce,BUFFER_REDUCE_MIN)
	local damage = math.floor(src:getBufferDamage(BUFFER_TYPE_POISON) * (1-bufferReduce))
	if Fight.src > 6 then
		Fight.otherDamage = Fight.otherDamage + math.min(damage,src:getHP())
	end
	src:subHP(damage)
	src:decBufferData(BUFFER_TYPE_POISON)
	Fight.onActionDone()
end

--Curse开始
function Fight.doCurse()
	local src = Fight.fighters[Fight.src]
	local bufferReduce = src:getBufCurseReduction()
	bufferReduce = math.min(bufferReduce,BUFFER_REDUCE_MAX)
	bufferReduce = math.max(bufferReduce,BUFFER_REDUCE_MIN)
	local damage = math.floor(src:getBufferDamage(BUFFER_TYPE_CURSE) * (1-bufferReduce))
	if Fight.src > 6 then
		Fight.otherDamage = Fight.otherDamage + math.min(damage,src:getHP())
	end
	src:subHP(damage)
	src:decBufferData(BUFFER_TYPE_CURSE)
	Fight.onActionDone()
end

--检测己方是否还活着
function Fight.isSelfAlive()
	for i = 1,6 do
		local fer = Fight.fighters[i]
		if not fer:isDead() then
			return true
		end
	end
	return false
end

--检测敌方是否还活着
function Fight.isOtherAlive()
	for i = 7,12 do
		local fer = Fight.fighters[i]
		if not fer:isDead() then
			return true
		end
	end
	return false
end

--检测战斗是否结束
function Fight.isFightOver()
	return not (Fight.isSelfAlive() and Fight.isOtherAlive())
end

--检测本场战斗是否胜利
function Fight.isFightWin()
	if Fight.bigRound < MAX_ROUND_LIMIT then
		return Fight.isSelfAlive()
	elseif Fight.bigRound == MAX_ROUND_LIMIT then
		return not Fight.isOtherAlive()
	elseif Fight.bigRound > MAX_ROUND_LIMIT then
		return false
	end
end

--检测战斗是否胜利
function Fight.isWin()
	if Fight.bigRound < MAX_ROUND_LIMIT then
		return Fight.isSelfAlive()
	elseif Fight.bigRound == MAX_ROUND_LIMIT then
		if Fight.fightIndex ~= #Fight.initData.otherData then
			return false
		end
		return not Fight.isOtherAlive()
	elseif Fight.bigRound > MAX_ROUND_LIMIT then
		return false
	end
end

--伤害值编码
function Fight.encodeNumber(num)
	local temp = tostring(num)
	local aaaa = {'h','u','a','y','i','g','a','m','e','!',}
	local tttt = os.time()
	local hash = temp:gsub(".",function(c)
			tttt = tttt + tttt
			math.randomseed(tttt)
			return aaaa[(c:byte() - 0x30)%10 + 1] .. aaaa[math.random(1,10)]
		end
	)
	return hash
end

--伤害值编码后的字符串是否相等
function Fight.isEncodedNumberEqual(stra,strb)
	local isEqual = true
	if #stra == #strb then
		for i=1,#stra,2 do
			if stra:byte(i) ~= strb:byte(i) then
				isEqual = false
				break
			end
		end
	else
		isEqual = false
	end
	return isEqual
end

return Fight

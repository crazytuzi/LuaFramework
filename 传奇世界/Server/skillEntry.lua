--skillEntry.lua
require "base.base"

--------------------------------------------------------------------------------
-- 加载buff配置
function loadBuffConfig()
	local buffDatas = require "data.BuffDB"
	for _, record in pairs(buffDatas or {}) do		
		local buffdata = BuffConfig:new()
		buffdata.wID	= record.id
		buffdata.bType	= record.type or 0
		buffdata.dwGroupID = record.groupID or 0
		buffdata.cover = record.cover or 2
		buffdata.cover_level = record.cover_level or 0
		buffdata.dwLastTime	= record.lastTime or 0
		buffdata.specialEffect = record.special or 0
		buffdata.iAddHurt       = record.modifyHurt or 0
		buffdata.iPercentHurt   = record.modifyHurtPre or 0
		buffdata.mpHurt			= record.mpHurt or 0
		buffdata.dwOverType     = record.overType or 0
		buffdata.dwSpaceTime	= record.spaceTime or 0
		buffdata.deadClear		= record.deadClear or 0	
		buffdata.hurtParams		= record.Churt or 0			
		buffdata.effectType		= (tonumber(record.effectType) == 1) or false		
		buffdata:push_mianyi(record.mianyi or "")
		buffdata:push_mianyizu(record.mianyizu or "")
		buffdata:push_qingchu(record.qingchu or "")
		buffdata:push_qingchuzu(record.qingchuzu or "")
		buffdata:push_attrkey(record.changeAttrKey or "", record.changeAttrValue or "", record.changeAttrPercent or "")
		
		buffdata.triggerSkillId = record.triggerSkillId or 0
		buffdata.isShiDuBuff = 0
		if record.icon == 6 then
			buffdata.isShiDuBuff = 1
		end
		buffdata.zysh = record.zysh or 0
		buffdata.liuxuePercent = record.LiuxXuePercent or 0
		
		buffdata.AttrValueType = record.changeAttrValueType or 0
		buffdata.zhanli		= record.zhanli or 0	
		buffdata.bianshen	= record.bianshen and true or false

		buffdata.liuxuePercentMax = record.liuxuePercentMax or 0
		g_configMgr:addBuffConfig(record.id, buffdata)
		buffdata:delete()
	end     
end

-- 加载skill配置
function loadSkillConfig()
	local skillDatas = require "data.SkillDB"

	local skilldata = SkillConfig:new()
	for _, record in pairs(skillDatas or {}) do		
		skilldata.skillID  = record.skillID
		skilldata.name = record.name
		skilldata.useType = record.useType
		skilldata.learnLv = record.learnLv
		skilldata.learnBook	= record.learnBook
		skilldata.canUpgrade = record.canUpgrade
		skilldata.canRegister = record.canRegister
		skilldata.needJob	= record.job
		skilldata.useDistance   = record.useDistance		
		skilldata.tarType       = record.tarType
		skilldata.rangeType     = record.effectRangeType
		skilldata.centerPos	= record.effectCenterPos
		skilldata.maxTarCount = record.limitTarCount
		skilldata.comCDTime     = record.coolTimeShare
		skilldata.shareGroup     = record.shareGroup
		skilldata.mutexSkillID	= record.mutexSkillID
		skilldata.hurtType	= record.hurtType
		skilldata.hateValue     = record.hate
		skilldata.delayTime = record.delayTime
		skilldata.scriptID = record.script
		skilldata.skillType = record.jnfenlie
		skilldata.skillHurtType = record.skillHurtType
		skilldata.upSkill = record.jnjj
		skilldata.isRebound = record.isRebound or 0
		
		g_configMgr:addSkillConfig(skilldata.skillID, skilldata)
	end
	skilldata:delete()
end

-- 加载skill效果配置
function loadSkillEffect()
	local skillDatas = require "data.SkillEffectDB"

	local skilldata = SkillEffect:new()
	for _, record in pairs(skillDatas or {}) do		
		skilldata.useMP	        = record.useMP or 0
		skilldata.addBuffID     = record.addBuff or 0
		skilldata.addBuffPro    = record.addBuffPro or 0
		skilldata.skillHurtPre  = record.addHurtPre or 0
		skilldata.skillAddAtk   = record.addAtk or 0
		skilldata.needVital		= record.needVital or 0
		skilldata.cdTime		= record.coolTime or 0
		skilldata.hpLimit		= record.HpLimit or 0

		skilldata.atmin = record.wg2 or 0
		skilldata.atmax = record.wg21 or 0
		skilldata.mtmin = record.ml2 or 0
		skilldata.mtmax = record.ml21 or 0
		skilldata.dtmin = record.ds2 or 0
		skilldata.dtmax = record.ds21 or 0
		skilldata.dfmin = record.wf2 or 0
		skilldata.dfmax = record.wf21 or 0
		skilldata.mfmin = record.mf2 or 0
		skilldata.mfmax = record.mf21 or 0
		skilldata.hit = record.mz2 or 0
		skilldata.miss = record.sb2 or 0
		skilldata.hpmax = record.sms2 or 0
		skilldata.battle = record.jnzdl or 0
		skilldata.hurtAdd = record.AbHurt or 0
		
		skilldata.hs2 = record.hs2 or 0
		skilldata.hs21 = record.hs21 or 0
		skilldata.mb2 = record.mb2 or 0
		skilldata.mb21 = record.mb21 or 0

		skilldata.relyBuffID = record.qb or 0
		skilldata.skillUpExp = record.sld or 0
		skilldata.skillUpMoney = record.money or 0
		skilldata.skillUpItem = record.jjjn or 0
		skilldata.skillUpCount = record.jjxj or 0
		skilldata.clearBuffRate = record.pdjl or 0
		skilldata.upLevel = record.djxz	or 0
		
		skilldata.tdjl = record.tdjl or 0
		skilldata.tdgl = record.tdgl or 0
		skilldata.jdpd = record.jdpd or 0

		skilldata.hurtBuffId = record.hurtBuffId or 0;
		skilldata.hurtBuffAdd = record.hurtBuffAdd or 0;
		skilldata.hurtBuffAddPrecent = record.hurtBuffAddPrecent or 0;
		
		skilldata.starNum = record.skill_starNum or 0
		skilldata.starColor = record.skill_color or 0
		skilldata.starChangeColorNeedBookId = record.needbook_ID or 0
		skilldata.starChangeColorNeedBookNum = record.needbook_Num or 0
		
		skilldata.cxsj = record.cxsj or 0
		
		skilldata.PerTime = record.PerTime or 1
		skilldata.PerTime = tonumber(skilldata.PerTime) * 1000
		
		--技能效果
		skilldata.moveToTarget = record.moveToTarget or 0
		skilldata.igBlocked = record.igBlocked or 0
		skilldata.movePetToTarget = record.movePetToTarget or 0
		skilldata.selfAddBuffID = record.selfAddBuffID or 0
		skilldata.ridePetLvHurtPre  = record.ridePetLvHurtPre or 0

		local clearbuffs = unserialize(record.pdbf)
		for i, buffID in pairs(clearbuffs or {}) do
			skilldata:addClearBuff(buffID)
		end

		g_configMgr:addSkillEffect(record.skillID, skilldata)
	end
	skilldata:delete()
end

function loadP3v3Config()
	local p3v3Datas = require "data.P3V3DB"
	local p3v3Config = P3V3Config:new()

	p3v3Config.mapId = p3v3Datas.mapId
	p3v3Config.matchCnt = p3v3Datas.matchCnt
	p3v3Config.memberCnt = p3v3Datas.memberCnt

	p3v3Config.campIdA = p3v3Datas.campIdA
	p3v3Config.campIdB = p3v3Datas.campIdB
	p3v3Config.towerIdA = p3v3Datas.towerIdA
	p3v3Config.towerIdB = p3v3Datas.towerIdB

	p3v3Config.posLiveA.x = p3v3Datas.posLiveA.x
	p3v3Config.posLiveA.y = p3v3Datas.posLiveA.y
	p3v3Config.posLiveB.x = p3v3Datas.posLiveB.x
	p3v3Config.posLiveB.y = p3v3Datas.posLiveB.y
	p3v3Config.posTowerA.x = p3v3Datas.posTowerA.x
	p3v3Config.posTowerA.y = p3v3Datas.posTowerA.y
	p3v3Config.posTowerB.x = p3v3Datas.posTowerB.x
	p3v3Config.posTowerB.y = p3v3Datas.posTowerB.y
	p3v3Config.posCampA.x = p3v3Datas.posCampA.x
	p3v3Config.posCampA.y = p3v3Datas.posCampA.y
	p3v3Config.posCampB.x = p3v3Datas.posCampB.x
	p3v3Config.posCampB.y = p3v3Datas.posCampB.y	

	p3v3Config.matchTime = p3v3Datas.matchTime	
	p3v3Config.battleTime = p3v3Datas.battleTime

	p3v3Config.rewardWinner = p3v3Datas.rewardWinner
	p3v3Config.rewardNowin = p3v3Datas.rewardNowin
	p3v3Config.rewardLoser = p3v3Datas.rewardLoser

	for i = 1, 7 do
		if p3v3Datas.posFlag[i] then
			p3v3Config.posFlag[i-1].x = p3v3Datas.posFlag[i].x
			p3v3Config.posFlag[i-1].y = p3v3Datas.posFlag[i].y
		end
	end
	for win, reward in pairs(p3v3Datas.rankReward) do
		p3v3Config:addWinReward(win, reward)
	end	
	for tick, num in pairs(p3v3Datas.flagRefesh) do
		p3v3Config:addFlagRefesh(tick, num)
	end	
	for cnt, tick in pairs(p3v3Datas.reliveTime) do
		p3v3Config:addReliveTime(cnt, tick)
	end	
	g_configMgr:load3V3Config(p3v3Config)
end

function loadFightTeam3v3Config()
	local data = require "data.FightTeam3v3DB"
	local config = g_configMgr:getFightTeam3v3Config()

	config.season = data.season
	config.seasonName = data.seasonName
	config.mapID = data.mapID
	config.posLiveA.x = data.posLiveA.x
	config.posLiveA.y = data.posLiveA.y
	config.posLiveB.x = data.posLiveB.x
	config.posLiveB.y = data.posLiveB.y
	config.posWatch.x = data.posWatch.x
	config.posWatch.y = data.posWatch.y
	config.battleZhanshiBuff = data.battleZhanshiBuff
	config.battleFashiBuff = data.battleFashiBuff
	config.battleDaoshiBuff = data.battleDaoshiBuff
	
	config.zhanshiBuff = data.zhanshiBuff
	config.fashiBuff = data.fashiBuff
	config.daoshiBuff = data.daoshiBuff
	config.luoleiBuff = data.luoleiBuff
	config.watchBuff = data.watchBuff

	config.auditionStartDate = data.auditionStartDate
	config.auditionEndDate = data.auditionEndDate

	for i=1, FIGHT_TEAM_AUDITION_GAME_COUNT do
		config.auditionGameStartTime[i] = data.auditionGameStartTime[i]
	end
	config.enterTime = data.enterTime
	config.prepareTime = data.prepareTime
	config.fightTime = data.fightTime

	config.quarterDate = data.quarterDate
	config.quarterGameStartTime = data.quarterGameStartTime
	config.semifinalDate = data.semifinalDate
	config.semifinalGameStartTime = data.semifinalGameStartTime
	config.finalDate = data.finalDate
	config.finalGameStartTime = data.finalGameStartTime

	config.needLevel = data.needLevel
	config.clearWaitTime = data.clearWaitTime
	config.watchPlayerCount = data.watchPlayerCount

	for i = 1, #data.regulationReward do
		if data.regulationReward[i] then
			config.regulationReward[i] = data.regulationReward[i]
		end
	end
	config.regulationEmail = data.regulationEmail

	for i = 1, #data.rankReward do
		if data.rankReward[i] then
			config.rankReward[i].startRank = data.rankReward[i].startRank
			config.rankReward[i].endRank = data.rankReward[i].endRank
			config.rankReward[i].dropID = data.rankReward[i].dropID
		end
	end
	config.rankEmail = data.rankEmail

	config.auditionReward = data.auditionReward
	config.autidionRewardEmail = data.autidionRewardEmail

	config.consolationReward = data.consolationReward
	config.consolationRewardEmail = data.consolationRewardEmail

	config.rewardChampionText = data.rewardChampionText
	config.rewardNormalText = data.rewardNormalText
end




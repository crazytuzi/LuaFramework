-- if IsServerSide then
-- 	local QBattleLog = {}
-- 	local func = function(...) end
-- 	function QBattleLog.new()
-- 		local obj = {}
-- 		setmetatable(obj, {__index = function(t, k)
-- 			return func
-- 		end})
-- 		return obj
-- 	end
-- 	return QBattleLog
-- end

local QBattleLog = class("QBattleLog", {})

function QBattleLog:ctor(dungeonId)
    local log = {}

    -- 关卡ID
    log.dungeonId = dungeonId

    -- 关卡开始时间
    log.startTime = 0

    -- 关卡结束时间
    log.endTime = 0

    -- 关卡计时片段
    -- e.g. [in json style]
    --[[
		"timeFragment": {
			{
				"start_at": 123.45,
				"end_at": 123.456,
			}
		}
    --]]
    log.timeFragment = {}

    -- 关卡胜利
    -- e.g. true
    log.win = nil

    -- 战斗持续时间，单位秒
    -- e.g. 12.87
    log.duration = 0

    -- 魂师状态
    -- e.g. [in json style]
    --[[
		"heroState": {
			"blood_elf": {
				"actor_id": "blood_elf",
				"create_time": 123.456,
				"dead_time": 123.456
			}
		}
    --]]
    log.heroState = {}

    -- 怪物状态
    -- e.g. [in json style]
    --[[
		"monsterState": {
			"normal_deviate_guardian_1_3": {
				"actor_id": "normal_deviate_guardian_1",
				"create_time": 123.456,
				"dead_time": 123.456,
				"monsterIndex" : 1 or nil
			}
		}
    --]]
    log.monsterState = {}

    -- 死亡人数（魂师）
    -- e.g. [in json style]
    --[[
    	"heroDeath": {
	    	"blood_elf": {
	    		"actor_id": "blood_elf"
			},
	    	"orc_warlord": {
	    		"actor_id": "orc_warlord"
			},
    	}
	]]--
    log.heroDeath = {}

    -- NPC直到死亡前存活时间，单位秒
    -- e.g. [in json style]
    --[[
    	"monsterDeath": {
	    	"normal_deviate_guardian_1": {
	    		"actor_id": "normal_deviate_guardian_1",
	    		"life_span": 8.2
			},
	    	"normal_nightmare_ectoplasm_1": {
	    		"actor_id": "normal_nightmare_ectoplasm_1",
	    		"life_span": 6.8
			},
    	}
	]]--
    log.monsterDeath = {}

    -- 上阵的魂师 & 上阵的魂师的战斗力
    -- e.g. [in json style]
    --[[
    	"heroOnStage": {
	    	"blood_elf": {
	    		"actor_id": "blood_elf",
	    		"battle_force": 100
			},
	    	"orc_warlord": {
	    		"actor_id": "orc_warlord",
	    		"battle_force": 100
			},
			"mouse_cute": {
	    		"actor_id": "mouse_cute",
	    		"battle_force": 5
			}
    	}
	]]--
    log.heroOnStage = {}

    -- 技能名，次数（魂师）
    -- e.g. [in json style]
    --[[
    	"heroSkillCast": {
	    	"blood_elf": {
	    		"actor_id": "blood_elf",
	    		"skill_cast": {
	    			"flash_heal_1": {
	    				"skill_id": "flash_heal_1",
	    				"cast_number": 17
	    			}
	    		}
			},
	    	"orc_warlord": {
	    		"actor_id": "orc_warlord",
	    		"skill_cast": {
	    			"phyattack_chop_weapon_1": {
	    				"skill_id": "phyattack_chop_weapon_1",
	    				"cast_number": 8
	    			}
	    		}
			},
			"mouse_cute": {
	    		"actor_id": "mouse_cute",
	    		"skill_cast": {
	    			"袖手旁观": {
	    				"skill_id": "袖手旁观",
	    				"cast_number": 100
	    			},
	    			"打喷嚏": {
	    				"skill_id": "打喷嚏",
	    				"cast_number": 1
	    			}
	    		}
			}
    	}
	]]--

    -- 完成最后一击的魂师、宠物、技能
    -- e.g. [in json style]
    --[[
    	"lastHeroAttack": {
    		"actor_id": "mouse_cute",
    		"skill_id": "打喷嚏"
    	}
	]]--
    log.lastHeroAttack = {}

    log.heroStats = {}
    log.enemyHeroStats = {}

    log.damageDealtByHero = 0
    log.damageDealtByEnemy = 0

    self._log = log
end

function QBattleLog:getBattleLog()
    return self._log
end

function QBattleLog:getBattleLogForServer()
	local log = self._log
	local ret = {}
	local function _getSkillStat(skillStat, skillId)
		local obj = {}
		obj.skillId = skillId
		obj.damage = skillStat.damage
		obj.treat = skillStat.treat
		obj.cast = skillStat.cast
		obj.hit	= skillStat.hit
		return obj
	end
	local function _getHeroStat(heroStat, actorId)
		local obj = {}
		obj.actorId = actorId
		obj.damage = heroStat.damage
		obj.treat = heroStat.treat
		obj.show = heroStat.show
		obj.skill = {}
		for skillId, skillStat in pairs(heroStat.skill) do
			table.insert(obj.skill, _getSkillStat(skillStat, skillId))
		end
		return obj
	end
	ret.heroStats = {}
	for actorId, heroStat in pairs(log.heroStats) do
		table.insert(ret.heroStats, _getHeroStat(heroStat, actorId))
	end
	ret.enemyHeroStats = {}
	for actorId, heroStat in pairs(log.enemyHeroStats) do
		table.insert(ret.enemyHeroStats, _getHeroStat(heroStat, actorId))
	end
	ret.deadHeroIds = {}
	for actorId, _ in pairs(log.heroDeath) do
		table.insert(ret.deadHeroIds, actorId)
	end
	return ret
end

function QBattleLog:setBattleLogFromServer(log)
	local function _getSkillStat(skillStat)
		local obj = {}
		obj.damage = skillStat.damage or 0
		obj.treat = skillStat.treat or 0
		obj.cast = skillStat.cast or 0
		obj.hit	= skillStat.hit or 0
		return skillStat.skillId, obj
	end
	local function _getActor(actorId, heroes)
		local ret = nil
		for _, actor in ipairs(heroes) do
			if actor:getActorID(true) == actorId then
				ret = actor
				break
			end
		end
		return ret
	end
	local function _getGhostActor(actorId, ghosts)
		local ret = nil
		for _, ghost in ipairs(ghosts) do
			if ghost.actor:getActorID(true) == actorId then
				ret = ghost.actor
				break
			end
		end
		return ret
	end
	local function _getHeroStat(heroStat, isHero)
		local obj = {}
		obj.damage = heroStat.damage or 0
		obj.treat = heroStat.treat or 0
		obj.show = heroStat.show
		obj.skill = {}
		for _, skillStat in ipairs(heroStat.skill or {}) do
			local skillId, objSkill = _getSkillStat(skillStat)
			obj.skill[skillId] = objSkill
		end 
		if isHero then 
			obj.actor = 
			_getActor(heroStat.actorId, app.battle._heroes) or
		    _getActor(heroStat.actorId, app.battle._heroesWave1) or
		    _getActor(heroStat.actorId, app.battle._heroesWave2) or
		    _getActor(heroStat.actorId, app.battle._heroesWave3) or
    		_getActor(heroStat.actorId, app.battle._candidateHeroes) or
		    _getActor(heroStat.actorId, app.battle._supportHeroes) or
		    _getActor(heroStat.actorId, app.battle._supportHeroes2) or
		    _getActor(heroStat.actorId, app.battle._supportHeroes3) or
		    _getActor(heroStat.actorId, app.battle._deadHeroes) or
    		_getGhostActor(heroStat.actorId, app.battle._heroGhosts)
		else
			obj.actor = 
			_getActor(heroStat.actorId, app.battle._enemies) or
		    _getActor(heroStat.actorId, app.battle._enemiesWave1) or
		    _getActor(heroStat.actorId, app.battle._enemiesWave2) or
		    _getActor(heroStat.actorId, app.battle._enemiesWave3) or
    		_getActor(heroStat.actorId, app.battle._candidateEnemies) or
		    _getActor(heroStat.actorId, app.battle._supportEnemies) or
		    _getActor(heroStat.actorId, app.battle._supportEnemies2) or
		    _getActor(heroStat.actorId, app.battle._supportEnemies3) or
		    _getActor(heroStat.actorId, app.battle._deadEnemies) or
    		_getGhostActor(heroStat.actorId, app.battle._enemyGhosts)
		end

		return heroStat.actorId, obj
	end
	local heroStats = {}
	for _, heroStat in ipairs(log.heroStats) do
		local actorId, obj = _getHeroStat(heroStat, true)
		heroStats[actorId] = obj
	end
	local enemyHeroStats = {}
	for _, heroStat in ipairs(log.enemyHeroStats) do
		local actorId, obj = _getHeroStat(heroStat)
		enemyHeroStats[actorId] = obj
	end
	local heroDeath = {}
	for _, actorId in ipairs(log.deadHeroIds or {}) do
		heroDeath[actorId] = {actorId = actorId}
	end
	self._log.heroStats = heroStats
	self._log.enemyHeroStats = enemyHeroStats
	self._log.heroDeath = heroDeath
end

function QBattleLog:setStartTime(time)
	self._log.startTime = time
end

function QBattleLog:setEndTime(time)
	self._log.endTime = time
end

function QBattleLog:setStartCountDown(time)
	local length = #self._log.timeFragment
	if length > 0 then
		if self._log.timeFragment[length].end_at == nil then
			return 
		end
	end
	table.insert(self._log.timeFragment, {start_at = time})
end

function QBattleLog:setEndCountDown(time)
	local length = #self._log.timeFragment
	if length == 0 then
		return 
	end

	if self._log.timeFragment[length].end_at ~= nil then
		return 
	end

	self._log.timeFragment[length].end_at = time
end

function QBattleLog:setIsWin(win)
	self._log.win = win
end

function QBattleLog:setIsOvertime(overtime)
	self._log.overtime = overtime
end

function QBattleLog:setDuration(duration)
	self._log.duration = duration
end

function QBattleLog:addHeroDeath(hero_actor)
	local heroDeath = self._log.heroDeath

	local actor_id = hero_actor:getActorID()
	heroDeath[actor_id] = {actor_id = actor_id}
end

function QBattleLog:addMonsterLifeSpan(monster_actor, life_span)
	local monsterDeath = self._log.monsterDeath

	local actor_id = monster_actor:getActorID()
	monsterDeath[actor_id] = {actor_id = actor_id, life_span = life_span}
end

function QBattleLog:addHeroOnStage(hero_actor, battle_force)
	local heroOnStage = self._log.heroOnStage

	local actor_id = hero_actor:getActorID()
	heroOnStage[actor_id] = {actor_id = actor_id, battle_force = battle_force}
end

function QBattleLog:addHeroSkillCast(hero_actor, skill, show)
	local heroID = hero_actor._actor_id
	local stats = self._log.heroStats
	local obj = stats[heroID]
	if not stats[heroID] then
		if show == nil then
			show = true
		end
		obj = {damage = 0, treat = 0, actor = hero_actor, show = show, skill = {}}
		stats[heroID] = obj
	end

	if skill then
		q.safeAddValue(obj.skill, skill:getId(), "cast", 1)
	end
end

function QBattleLog:addEnemySkillCast(enemy_actor, skill, show)
	local heroID = enemy_actor._actor_id
	local stats = self._log.enemyHeroStats
	local obj = stats[heroID]
	if not stats[heroID] then
		if show == nil then
			show = true
		end
		obj = {damage = 0, treat = 0, actor = enemy_actor, show = show, skill = {}}
		stats[heroID] = obj
	end

	if skill then
		q.safeAddValue(obj.skill, skill:getId(), "cast", 1)
	end
end

function QBattleLog:setLastHeroAttack(hero_actor, skill)
	self._log.lastHeroAttack = {actor_id = hero_actor:getActorID(), skill_id = skill:getId()}
end

function QBattleLog:onHeroCreated(heroId, time)
	if heroId == nil then
		return
	end

	if self._log.heroState[heroId] == nil then
		self._log.heroState[heroId] = {}
	end

	self._log.heroState[heroId].actor_id = heroId
	self._log.heroState[heroId].create_time = time
end

function QBattleLog:onHeroDead(heroId, time)
	if heroId == nil then
		return
	end

	if self._log.heroState[heroId] == nil then
		self._log.heroState[heroId] = {}
	end

	self._log.heroState[heroId].actor_id = heroId
	self._log.heroState[heroId].dead_time = time
end

function QBattleLog:onMonsterCreated(monsterUDId, monsterId, monsterIndex, time)
	if monsterUDId == nil or monsterId == nil then
		return
	end

	if self._log.monsterState[monsterUDId] == nil then
		self._log.monsterState[monsterUDId] = {}
	end

	self._log.monsterState[monsterUDId].actor_id = monsterId
	self._log.monsterState[monsterUDId].create_time = time
	self._log.monsterState[monsterUDId].monsterIndex = monsterIndex
end

function QBattleLog:onMonsterDead(monsterUDId, monsterId, time)
	if monsterUDId == nil or monsterId == nil then
		return
	end

	if self._log.monsterState[monsterUDId] == nil then
		self._log.monsterState[monsterUDId] = {}
	end

	self._log.monsterState[monsterUDId].actor_id = monsterId
	self._log.monsterState[monsterUDId].dead_time = time
end

-- show为nil的时候表示true
function QBattleLog:onHeroDoDHP(heroID, dHP, actor, show, skill, ignoreDhp)
	heroID = actor:getActorID(true)

	local stats = self._log.heroStats
	local obj = stats[heroID]
	if not stats[heroID] then
		if show == nil then
			show = true
		end
		obj = {damage = 0, treat = 0, actor = actor, show = show, skill = {}, ignore_treate = 0, ignore_damage = 0}
		stats[heroID] = obj
	end

	if dHP > 0 then
		obj.treat = obj.treat + dHP
	elseif dHP < 0 then
		obj.damage = obj.damage - dHP
	end

	if ignoreDhp then
		if ignoreDhp > 0 then
			obj.ignore_treate = (obj.ignore_treate or 0) + ignoreDhp
		elseif ignoreDhp < 0 then
			obj.ignore_damage = (obj.ignore_damage or 0) - ignoreDhp
		end
	end

	if skill then
		if dHP > 0 then
			q.safeAddValue(obj.skill, skill:getId(), "treat", dHP)
		elseif dHP < 0 then
			q.safeAddValue(obj.skill, skill:getId(), "damage", -dHP)
			self._log.damageDealtByHero = self._log.damageDealtByHero + (-dHP)
		end
		-- if dHP ~= 0 then
		-- 	q.safeAddValue(obj.skill, skill:getId(), "hit", 1)
		-- end
		q.safeAddValue(obj.skill, skill:getId(), "hit", 1)
	end
end

-- show为nil的时候表示true
function QBattleLog:onEnemyHeroDoDHP(enemyHeroID, dHP, actor, show, skill, ignoreDhp)
	enemyHeroID = actor:getActorID(true)

	local stats = self._log.enemyHeroStats
	local obj = stats[enemyHeroID]
	if not stats[enemyHeroID] then
		if show == nil then
			show = true
		end
		obj = {damage = 0, treat = 0, actor = actor, show = show, skill = {}, ignore_treate = 0, ignore_damage = 0}
		stats[enemyHeroID] = obj
	end

	if dHP > 0 then
		obj.treat = obj.treat + dHP
	elseif dHP < 0 then
		obj.damage = obj.damage - dHP
	end

	if ignoreDhp then
		if ignoreDhp > 0 then
			obj.ignore_treate = (obj.ignore_treate or 0) + ignoreDhp
		elseif ignoreDhp < 0 then
			obj.ignore_damage = (obj.ignore_damage or 0) - ignoreDhp
		end
	end

	if skill then
		if dHP > 0 then
			q.safeAddValue(obj.skill, skill:getId(), "treat", dHP)
		elseif dHP < 0 then
			q.safeAddValue(obj.skill, skill:getId(), "damage", -dHP)
			self._log.damageDealtByEnemy = self._log.damageDealtByEnemy + (-dHP)
		end
		q.safeAddValue(obj.skill, skill:getId(), "hit", 1)
	end
end

function QBattleLog:onHeroDoAbsorb(heroID, absorb, actor, show, skill)
	heroID = actor:getActorID(true)
	local stats = self._log.heroStats
	local obj = stats[heroID]
	if not stats[heroID] then
		if show == nil then
			show = true
		end
		obj = {damage = 0, treat = 0, actor = actor, show = show, skill = {}, ignore_treate = 0, ignore_damage = 0}
		stats[heroID] = obj
	end
	if skill then
		q.safeAddValue(obj.skill, skill:getId(), "absorb", absorb or 0)
	end
end

function QBattleLog:onEnemyDoAbsorb(enemyHeroID, absorb, actor, show, skill)
	enemyHeroID = actor:getActorID(true)
	local stats = self._log.enemyHeroStats
	local obj = stats[enemyHeroID]
	if not stats[enemyHeroID] then
		if show == nil then
			show = true
		end
		obj = {damage = 0, treat = 0, actor = actor, show = show, skill = {}, ignore_treate = 0, ignore_damage = 0}
		stats[enemyHeroID] = obj
	end
	if skill then
		q.safeAddValue(obj.skill, skill:getId(), "absorb", absorb or 0)
	end
end

-- merge Stats
function QBattleLog:mergeStats(otherLog)
	local function merge(dst, src)
		for actorID, srcObj in pairs(src) do
			local dstObj = dst[actorID] or {}
			dst[actorID] = dstObj
			dstObj.treat = (dstObj.treat or 0) + (srcObj.treat or 0)
			dstObj.damage = (dstObj.damage or 0) + (srcObj.damage or 0)
			for skillID, srcSkillObj in pairs(srcObj.skill) do
				dstObj.skill = dstObj.skill or {}
				if srcSkillObj.treat then
					q.safeAddValue(dstObj.skill, skillID, "treat", srcSkillObj.treat)
				end
				if srcSkillObj.damage then
					q.safeAddValue(dstObj.skill, skillID, "damage", srcSkillObj.damage)
				end
				if srcSkillObj.hit then
					q.safeAddValue(dstObj.skill, skillID, "hit", srcSkillObj.hit)
				end
				if srcSkillObj.cast then
					q.safeAddValue(dstObj.skill, skillID, "cast", srcSkillObj.cast)
				end
			end
		end
	end
	merge(self._log.heroStats, otherLog._log.heroStats)
	merge(self._log.enemyHeroStats, otherLog._log.enemyHeroStats)
end

function QBattleLog:setSupportSkillHero(actor)
	self._log.supportSkillHero = actor
end

function QBattleLog:setSupportSkillHero2(actor)
	self._log.supportSkillHero2 = actor
end

function QBattleLog:setSupportSkillHero3(actor)
	self._log.supportSkillHero3 = actor
end

function QBattleLog:setSupportSkillEnemy(enemy)
	self._log.supportSkillEnemy = enemy
end

function QBattleLog:setSupportSkillEnemy2(enemy)
	self._log.supportSkillEnemy2 = enemy
end

function QBattleLog:setSupportSkillEnemy3(enemy)
	self._log.supportSkillEnemy3 = enemy
end

return QBattleLog

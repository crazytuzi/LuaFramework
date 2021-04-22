
local QSkeletonViewController = class("QSkeletonViewController")

local QStaticDatabase = import(".QStaticDatabase")
local QFileCache = import("..utils.QFileCache")
local QFcaSkeletonView = import("...lib.fca.QFcaSkeletonView")

local EFFECT_RGBA8888 = {
	acid_rain_7 = true,
	arcane_explosion_1_1 = true,
	blast_wave_1 = true,
	chronosphere_6_2 = true,
	combustion_4 = true,
	devouring_plague_1_3 = true,
	drunken_fist_1_1 = true,
	drunken_haze_1 = true,
	fire_blast_3 = true,
	ice_lance_2 = true,
	infect_4_1 = true,
	lure_3 = true,
	monster_born_3 = true,
	pain_suppression_4 = true,
	peaceful_3 = true,
	power_word_shield_3 = true,
	shadow_explosion_4 = true,
	shadow_step_1 = true,
	taunt_1 = true,
	toxicant_5 = true,
	toxicant_6 = true,
	unholy_3 = true,
	light_1 = true,
	jiansheng_1 = true,
	maoyou_1 = true,
	fashufx_1 = true,
	kaichangdonghua_1 = true,
	zhansha_1 = true,
	zhansha_2 = true,
	xuehua_1 = true,
	ice_hell_1 = true,
	ruiwendaier_zaozhe_3 = true,
}

if not TEXTURE_FORCE_RGBA4444 then
    function setTextureForceRGBA4444(...)

    end
end

local function _parseSkillID(skill_id)
    local id, level = nil
    if type(skill_id) == "number" then
        id = skill_id
        level = 1
    elseif type(skill_id) == "string" then
        if string.find(skill_id, ",") then
            local objs = string.split(skill_id, ",")
            id = tonumber(objs[1])
            level = tonumber(objs[2])
        elseif string.find(skill_id, ":") then
        	local objs = string.split(skill_id, ":")
        	id = tonumber(objs[1])
        	level = tonumber(objs[2])
        else
            id = tonumber(skill_id)
            level = 1
        end
    end

    if id == nil or level == nil then
        return nil, nil
    end

    local db = QStaticDatabase:sharedDatabase()
    if db:getSkillByID(id) and db:getSkillDataByIdAndLevel(id, level) then
        return id, level
    else
        return nil, nil
    end
end

function QSkeletonViewController:sharedSkeletonViewController()
	if app._skeletonViewController == nil then
        app._skeletonViewController = QSkeletonViewController.new()
    end
    return app._skeletonViewController
end

function QSkeletonViewController:ctor()
	self._skeletonDatas = {} -- cached 
	self._skeletonActors = {}
	self._skeletonEffects = {}
	self._skeletonActorsAttachedEffects = {}
	self._animationScale = 1.0
	self._externAnimationScale = 1.0
end

function QSkeletonViewController:getGlobalAnimationScale()
	return self._animationScale
end

function QSkeletonViewController:getExternAnimationScale()
	return self._externAnimationScale
end

function QSkeletonViewController:createSkeletonActorWithFile(file, isHero, needCache)
	local isResolutionHalf = isTextureResolutionHalf()
	setTextureResolutionHalf(BATTLE_TEXTURE_RESOLUTION_HALF)
	local isTexture16bit = isTextureForceRGBA4444()
	setTextureForceRGBA4444(true)

	isHero = isHero or false
	local skeletonActor = nil
	if string.find(file, "fca/", 1, true) then
		if QFcaSkeletonView_cpp ~= nil and ENABLE_FCA_CPP then
			skeletonActor = QFcaSkeletonView_cpp:createFcaSkeletonView(string.sub(file, string.find(file, "[^/]+$")), "actor", isHero)
		else
			skeletonActor = QFcaSkeletonView.createFcaSkeletonView(string.sub(file, string.find(file, "[^/]+$")), "actor")
		end
		skeletonActor.isFca = true
	else
		skeletonActor = QSkeletonActor:create(file)
		function skeletonActor:getNode() -- compatible with fca skeleton actor
			return self
		end
        skeletonActor.isFca = nil
	end

	if needCache == nil then needCache = true end
	
	if skeletonActor ~= nil and needCache then
		self:_addSkeletonView(skeletonActor, self._skeletonActors)
	end

	setTextureResolutionHalf(isResolutionHalf)
	setTextureForceRGBA4444(isTexture16bit)

	return skeletonActor
end

function QSkeletonViewController:createUISkeletonActorWithFile(file, needCache)
	if QSkeletonActor.createWithFileNames then
		local isResolutionHalf = isTextureResolutionHalf()
		setTextureResolutionHalf(BATTLE_TEXTURE_RESOLUTION_HALF)
		local isTexture16bit = isTextureForceRGBA4444()
		setTextureForceRGBA4444(true)

		local skeletonActor = QSkeletonActor:createWithFileNames(file, file .. ".ui")

		if needCache == nil then needCache = true end

		if skeletonActor ~= nil and needCache then
			self:_addSkeletonView(skeletonActor, self._skeletonActors)
		end

		setTextureResolutionHalf(isResolutionHalf)
		setTextureForceRGBA4444(isTexture16bit)

		return skeletonActor
	else
		return self:createSkeletonActorWithFile(file)
	end
end

function QSkeletonViewController:removeSkeletonActor(actor)
   self:_removeSkeletonView(actor, self._skeletonActors)
end

function QSkeletonViewController:createSkeletonEffectWithFile(file, actor, sizeRenderTexture, needCache)
	local isResolutionHalf = isTextureResolutionHalf()
	setTextureResolutionHalf(BATTLE_TEXTURE_RESOLUTION_HALF)
	local isTexture16bit = isTextureForceRGBA4444()
	if not EFFECT_RGBA8888[file] then
		setTextureForceRGBA4444(true)
	end
	
	local skeletonView

	if string.find(file, "fca/", 1, true) then
		if QFcaSkeletonView_cpp ~= nil and ENABLE_FCA_CPP then
			skeletonView = QFcaSkeletonView_cpp:createFcaSkeletonView(string.sub(file, string.find(file, "[^/]+$")), "effect", false)
		else
			skeletonView = QFcaSkeletonView.createFcaSkeletonView(string.sub(file, string.find(file, "[^/]+$")), "effect")
		end
		skeletonView.isFca = true
	else
		if sizeRenderTexture == nil then
			skeletonView = QSkeletonView:create(file)
		else
			skeletonView = QSkeletonView:create(file, sizeRenderTexture)
		end
        skeletonView.isFca = nil
		function skeletonView:getNode()
			return self
		end
	end

	if needCache == nil then needCache = true end

	if skeletonView ~= nil and needCache then
		self:_addSkeletonActorAttachedEffect(skeletonView, actor)
		self:_addSkeletonView(skeletonView, self._skeletonEffects)
	end

	setTextureResolutionHalf(isResolutionHalf)
	setTextureForceRGBA4444(isTexture16bit)

	return skeletonView
end

function QSkeletonViewController:removeSkeletonEffect(effect)
	self:_removeSkeletonActorAttachedEffect(effect)
   	self:_removeSkeletonView(effect, self._skeletonEffects)
end

function QSkeletonViewController:setAllEffectsAnimationScale(scale)
	if scale < 0 then
        return
    end

	for _, v in ipairs(self._skeletonEffects) do
		if v.getFollowActor and not v:getFollowActor() then
			v:setAnimationScale(scale)
		end
	end

	self._externAnimationScale = scale
end

function QSkeletonViewController:resetAllEffectsAnimationScale()
	for _, v in ipairs(self._skeletonEffects) do
		v:setAnimationScale(self._animationScale)
	end
end

function QSkeletonViewController:resetAllAnimationScale()
	for _, v in ipairs(self._skeletonActors) do
		v:setAnimationScale(self._animationScale)
	end
	for _, v in ipairs(self._skeletonEffects) do
		v:setAnimationScale(self._animationScale)
	end
end

function QSkeletonViewController:_addSkeletonView(skeletonView, viewArray)
	if skeletonView == nil or viewArray == nil then
		return
	end

	for _, v in ipairs(viewArray) do
		if v == skeletonView then
			return
		end
	end
	table.insert(viewArray, skeletonView)
	skeletonView:retain()
end

function QSkeletonViewController:_removeSkeletonView(skeletonView, viewArray)
	if skeletonView == nil or viewArray == nil then
		return
	end

	for i, v in ipairs(viewArray) do
		if v == skeletonView then
			table.remove(viewArray, i)
			skeletonView:release()
			break
		end
	end
end

function QSkeletonViewController:_addSkeletonActorAttachedEffect(effect, actor)
	if effect == nil or actor == nil then
		return 
	end

	local indexOfActor = 0 
	for i, actorAttachedEffects in ipairs(self._skeletonActorsAttachedEffects) do
		if actorAttachedEffects.actor == actor then
			for _, skeletonEffect in ipairs(actorAttachedEffects.effects) do
				if skeletonEffect == effect then
					return
				end
			end
			indexOfActor = i
			break
		end
	end

	if indexOfActor > 0 then
		table.insert(self._skeletonActorsAttachedEffects[indexOfActor].effects, effect)
	else
		table.insert(self._skeletonActorsAttachedEffects, {actor = actor, effects = {effect}})
	end
end

function QSkeletonViewController:_removeSkeletonActorAttachedEffect(effect)
	if effect == nil then
		return 
	end

	local indexOfActor = 0 
	local indexOfEffect = 0
	for i, actorAttachedEffects in ipairs(self._skeletonActorsAttachedEffects) do
		for j, skeletonEffect in ipairs(actorAttachedEffects.effects) do
			if skeletonEffect == effect then
				indexOfEffect = j
				break
			end
		end
		if indexOfEffect > 0 then
			indexOfActor = i
			break
		end
	end

	if indexOfActor > 0 and indexOfEffect > 0 then
		table.remove(self._skeletonActorsAttachedEffects[indexOfActor].effects, indexOfEffect)
		if table.nums(self._skeletonActorsAttachedEffects[indexOfActor].effects) == 0 then
			table.remove(self._skeletonActorsAttachedEffects, indexOfActor)
		end
	end

end

-- cache skeleton data 

function QSkeletonViewController:cacheSkeletonData(dungeonConfig, updateCallback, options)
	if options == nil then options = {} end
	self._updateCallback = updateCallback
	self:_loadSkeletonData(dungeonConfig, options)
end

function QSkeletonViewController:_loadSkeletonData(dungeonConfig, options)    
	if dungeonConfig.isTutorial == true or dungeonConfig.isEditor == true then
        return
    end

    self:removeSkeletonData()
    audio.unloadAllSound()

    local dataBase = QStaticDatabase.sharedDatabase()

    local charactorDisplayIds = {}
    local effectIds = {}
	local sounds = {}
    local hasIllidan = false
    
    -- hero actor

    -- hero actor
    local teamName = remote.teamManager.INSTANCE_TEAM
    if dungeonConfig.teamName ~= nil then
        teamName = dungeonConfig.teamName
    end
    if dungeonConfig.isReplay then
        for _, heroInfo in ipairs(dungeonConfig.heroInfos or {}) do
        	table.insert(charactorDisplayIds, heroInfo.actorId)
        end
    else
    	if remote.teamManager ~= nil then
    		local teamVO = remote.teamManager:getTeamByKey(teamName)
    		if teamVO ~= nil then
    			local actorIds = teamVO:getTeamActorsByIndex(1)
    			if actorIds ~= nil then
    				for _,actorId in ipairs(actorIds) do
    					local hero = remote.herosUtil:getHeroByID(actorId)
			            if hero~= nil then
			                local character = dataBase:getCharacterByID(hero.actorId)
			                if character ~= nil then
			                	table.insert(charactorDisplayIds, character.display_id)
			                end
			            end
    				end
    			end
    			local skill = teamVO:getTeamSkillByIndex(2)
    			if skill ~= nil then
    				for _,actorId in ipairs(skill) do
    					local hero = remote.herosUtil:getHeroByID(actorId)
			            if hero~= nil then
			                local character = dataBase:getCharacterByID(hero.actorId)
			                if character ~= nil then
			                	table.insert(charactorDisplayIds, character.display_id)
			                end
			            end
    				end
    			end
    		end
    	end
	end
	
    -- enemy actor
    local dungeon = nil
    if dungeonConfig.isPVPMode == true then
        for i, hero in ipairs(dungeonConfig.pvp_rivals or {}) do
            local character = dataBase:getCharacterByID(hero.actorId)
            if character ~= nil then
            	table.insert(charactorDisplayIds, character.display_id)
            end
        end
    else
        dungeon = dataBase:getMonstersById(dungeonConfig.monster_id)
        if dungeon ~= nil then
            for i, monsterInfo in ipairs(dungeon or {}) do
                local character = dataBase:getCharacterByID(app:getBattleRandomNpcID(dungeonConfig.monster_id, i, monsterInfo.npc_id))
                if character ~= nil then
                	table.insert(charactorDisplayIds, character.display_id)
                end
            end
        end
    end

    -- for illidan
    for _, id in ipairs(charactorDisplayIds) do
    	if id == 10023 then
    		hasIllidan = true
    		break
    	end
    end

    if options.isCacheSkillEffect == true then

	    local skillIds = {}
	    -- hero skill
	    -- TODO replay skill cache
	    if not dungeonConfig.isReplay then
    		local heros = {}
	    	if remote.teamManager ~= nil then
	    		local teamVO = remote.teamManager:getTeamByKey(teamName)
	    		if teamVO ~= nil then
	    			local actorIds = teamVO:getTeamActorsByIndex(1)
	    			if actorIds ~= nil then
	    				for _,actorId in ipairs(actorIds) do
	    					table.insert(heros, actorId)
	    				end
	    			end
	    			local skill = teamVO:getTeamSkillByIndex(2)
	    			if skill ~= nil then
	    				for _,actorId in ipairs(skill) do
	    					table.insert(heros, actorId)
	    				end
	    			end
	    		end
	    	end

	        for i, heroId in ipairs(heros) do
	            local hero = remote.herosUtil:getHeroByID(heroId)
	            if hero ~= nil then
	            	local character = dataBase:getCharacterByID(hero.actorId)
	            	if character ~= nil then
	            		if character.victory_skill ~= nil and string.len(character.victory_skill) > 0 then
		                    skillIds[character.victory_skill] = character.victory_skill
		                end
		                if character.dead_skill ~= nil and string.len(character.dead_skill) > 0 then
		                    skillIds[character.dead_skill] = character.dead_skill
		                end
	            	end
	            	if hero.skills then
		                for _, skillId in ipairs(hero.skills or {}) do
		                	local id, level = _parseSkillID(skillId)
		                	if id then
		                		skillIds[id] = id
		                	end
		                end
		            end
		            if hero.slots then
				        for _, slotInfo in ipairs(hero.slots or {}) do
				            local level = slotInfo.slotLevel
				            local skillId = dataBase:getSkillByActorAndSlot(hero.actorId, slotInfo.slotId)
				            if skillId and level then
				                skillIds[skillId] = skillId
				            end
				        end
		            end
		            -- for illidan
		            if hero.actorId == 10023 then
    					hasIllidan = true
		            end
	            end
	        end
		end

	    -- pvp rival skill
	    if dungeonConfig.isPVPMode == true then
	        for i, hero in ipairs(dungeonConfig.pvp_rivals or {}) do
	            local character = dataBase:getCharacterByID(hero.actorId)
	            if character ~= nil then
            		if character.victory_skill ~= nil and string.len(character.victory_skill) > 0 then
	                    skillIds[character.victory_skill] = character.victory_skill
	                end
	                if character.dead_skill ~= nil and string.len(character.dead_skill) > 0 then
	                    skillIds[character.dead_skill] = character.dead_skill
	                end
	            end
            	if hero.skills then
	                for _, skillId in ipairs(hero.skills or {}) do
	                	local id, level = _parseSkillID(skillId)
	                	if id then
	                		skillIds[id] = id
	                	end
	                end
	            end
	            if hero.slots then
			        for _, slotInfo in ipairs(hero.slots or {}) do
			            local level = slotInfo.slotLevel
			            local skillId = dataBase:getSkillByActorAndSlot(hero.actorId, slotInfo.slotId)
			            if skillId and level then
			                skillIds[skillId] = skillId
			            end
			        end
	            end
	            -- for illidan
	            if hero.actorId == 10023 then
					hasIllidan = true
	            end
	        end
		    if dungeonConfig.pvp_rivals3 then
		    	local hero = dungeonConfig.pvp_rivals3
	            local character = dataBase:getCharacterByID(hero.actorId)
	            if character ~= nil then
            		if character.victory_skill ~= nil and string.len(character.victory_skill) > 0 then
	                    skillIds[character.victory_skill] = character.victory_skill
	                end
	                if character.dead_skill ~= nil and string.len(character.dead_skill) > 0 then
	                    skillIds[character.dead_skill] = character.dead_skill
	                end
	            end
            	if hero.skills then
	                for _, skillId in ipairs(hero.skills or {}) do
	                	local id, level = _parseSkillID(skillId)
	                	if id then
	                		skillIds[id] = id
	                	end
	                end
	            end
	            if hero.slots then
			        for _, slotInfo in ipairs(hero.slots or {}) do
			            local level = slotInfo.slotLevel
			            local skillId = dataBase:getSkillByActorAndSlot(hero.actorId, slotInfo.slotId)
			            if skillId and level then
			                skillIds[skillId] = skillId
			            end
			        end
	            end
	            -- for illidan
	            if hero.actorId == 10023 then
					hasIllidan = true
	            end
		    end
	    end

	    if hasIllidan then
	    	table.insert(charactorDisplayIds, 10025)
	    	table.insert(charactorDisplayIds, 10026)
	    end

	    -- enemy skill
	    local function _getSkillIdWithAi(aiConfig, skillIds)
		    if aiConfig == nil or skillIds == nil then
		        return
		    end
		    if aiConfig.OPTIONS ~= nil and aiConfig.OPTIONS.skill_id ~= nil then
		    	if aiConfig.OPTIONS.level then
		    		table.insert(skillIds, tostring(aiConfig.OPTIONS.skill_id) .. "," .. tostring(aiConfig.OPTIONS.level))
		    	else
		        	table.insert(skillIds, aiConfig.OPTIONS.skill_id) 
		        end
		    end

		    if aiConfig.ARGS ~= nil then
		        for _, conf in pairs(aiConfig.ARGS) do
		            _getSkillIdWithAi(conf, skillIds)
		        end
		    end
		end

	    if dungeon ~= nil then
	        for i, monsterInfo in ipairs(dungeon) do
	            local character = dataBase:getCharacterByID(app:getBattleRandomNpcID(dungeonConfig.monster_id, i, monsterInfo.npc_id))
	            if character ~= nil then
	                if character.npc_skill ~= nil and string.len(character.npc_skill) > 0 then
	                    skillIds[character.npc_skill] = character.npc_skill
	                end
	                if character.npc_skill2 ~= nil and string.len(character.npc_skill2) > 0 then
	                    skillIds[character.npc_skill2] = character.npc_skill2
	                end
	                if character.victory_skill ~= nil and string.len(character.victory_skill) > 0 then
	                    skillIds[character.victory_skill] = character.victory_skill
	                end
	                if character.dead_skill ~= nil and string.len(character.dead_skill) > 0 then
	                    skillIds[character.dead_skill] = character.dead_skill
	                end
	                if character.npc_ai ~= nil then
	                    local config = QFileCache.sharedFileCache():getAIConfigByName(character.npc_ai)
	                    if config ~= nil then
	                        local skillIdsInAi = {}
	                        _getSkillIdWithAi(config, skillIdsInAi)
	                        for _, skillId in ipairs(skillIdsInAi) do
	                        	local id, level = _parseSkillID(skillId)
	                        	if id then
	                            	skillIds[id] = id
	                            end
	                        end
	                    end
	                end
	            end
	        end
	    end
	    if hasIllidan then
	    	local ids = {10025, 10026}
	        for _, id in ipairs(ids) do
	            local character = dataBase:getCharacterByID(id)
	            if character ~= nil then
	                if character.npc_skill ~= nil and string.len(character.npc_skill) > 0 then
	                    skillIds[character.npc_skill] = character.npc_skill
	                end
	                if character.npc_skill2 ~= nil and string.len(character.npc_skill2) > 0 then
	                    skillIds[character.npc_skill2] = character.npc_skill2
	                end
	                if character.victory_skill ~= nil and string.len(character.victory_skill) > 0 then
	                    skillIds[character.victory_skill] = character.victory_skill
	                end
	                if character.dead_skill ~= nil and string.len(character.dead_skill) > 0 then
	                    skillIds[character.dead_skill] = character.dead_skill
	                end
	                if character.npc_ai ~= nil then
	                    local config = QFileCache.sharedFileCache():getAIConfigByName(character.npc_ai)
	                    if config ~= nil then
	                        local skillIdsInAi = {}
	                        _getSkillIdWithAi(config, skillIdsInAi)
	                        for _, skillId in ipairs(skillIdsInAi) do
	                        	local id, level = _parseSkillID(skillId)
	                        	if id then
	                            	skillIds[id] = id
	                            end
	                        end
	                    end
	                end
	            end
	        end
	    end

	    local function _warmUpSkillBehaviorNode(config, skillId)
	        if config == nil or type(config) ~= "table" then
	            return
	        end

	        assert(config.CLASS ~= nil, " skill id: " .. tostring(skillId) .. " is invalid.")

	        QFileCache.sharedFileCache():getSkillClassByName(config.CLASS)

	        local args = config.ARGS
	        if args ~= nil then
	            for k, v in pairs(args) do
	                _warmUpSkillBehaviorNode(v, skillId)
	            end
	        end
	    end
	    for _, skillId in pairs(skillIds) do
	        local skillData = dataBase:getSkillByID(skillId)
	        if skillData.skill_behavior ~= nil then
	            local config = QFileCache.sharedFileCache():getSkillConfigByName(skillData.skill_behavior)
	            if config ~= nil then
	            	if config[1] then
	                	_warmUpSkillBehaviorNode(config[1], skillId)
	                	if config[2] then
	                		_warmUpSkillBehaviorNode(config[2], skillId)
	                	end
	                else
	                	_warmUpSkillBehaviorNode(config, skillId)
	                end
	            end
	        end
	    end

	    local function _getEffectIdWithSkill(skillConfig, effectIds)
		    if skillConfig == nil or effectIds == nil then
		        return
		    end
		    if skillConfig.OPTIONS ~= nil then
		    	if skillConfig.OPTIONS.effect_id ~= nil then
		        	table.insert(effectIds, skillConfig.OPTIONS.effect_id)
		        end
		    	if skillConfig.OPTIONS.hit_effect_id ~= nil then
		        	table.insert(effectIds, skillConfig.OPTIONS.hit_effect_id)
		        end
		    end

		    if skillConfig.ARGS ~= nil then
		        for _, conf in pairs(skillConfig.ARGS) do
		            _getEffectIdWithSkill(conf, effectIds)
		        end
		    end
		end

		local function _getBuffIdWithSkill(skillConfig, buffIds)
			if skillConfig == nil or buffIds == nil then
				return
			end
			if skillConfig.OPTIONS ~= nil then
				if skillConfig.OPTIONS.buff_id ~= nil then
					if type(skillConfig.OPTIONS.buff_id) == "table" then
						for i,id in ipairs(skillConfig.OPTIONS.buff_id) do
							table.insert(buffIds, id)
						end
					elseif type(skillConfig.OPTIONS.buff_id) == "string" then
						table.insert(buffIds, skillConfig.OPTIONS.buff_id)
					end
				end
			end

			if skillConfig.ARGS ~= nil then
				for _, conf in ipairs(skillConfig.ARGS) do
					_getBuffIdWithSkill(conf, buffIds)
				end
			end
		end

	    for _, skillId in pairs(skillIds) do
	        -- effect of skill
	        local skillData = dataBase:getSkillByID(skillId)
	        assert(skillData ~= nil, "can not find skill data with id:" .. skillId)
	        if skillData ~= nil then
	        	local buffIds = {}
	            if skillData.attack_effect ~= nil then
	                effectIds[skillData.attack_effect] = skillData.attack_effect
	            end
	            if skillData.bullet_effect ~= nil then
	                effectIds[skillData.bullet_effect] = skillData.bullet_effect
	            end
	            if skillData.hit_effect ~= nil then
	                effectIds[skillData.hit_effect] = skillData.hit_effect
	            end
	            if skillData.second_hit_effect ~= nil then
	                effectIds[skillData.second_hit_effect] = skillData.second_hit_effect
	            end
	            if skillData.skill_behavior ~= nil then
	                local config = QFileCache.sharedFileCache():getSkillConfigByName(skillData.skill_behavior)
	                if config ~= nil then
	                    local effectIdInSkill = {}
	                    _getEffectIdWithSkill(config, effectIdInSkill)
	                    for _, effectId in ipairs(effectIdInSkill) do
	                        effectIds[effectId] = effectId
	                    end
	                    _getBuffIdWithSkill(config, buffIds)
	                end
	            end

	            -- effect of buff
	            if skillData.buff_id_1 ~= nil then
	            	table.insert(buffIds, skillData.buff_id_1)
	            end
	            if skillData.buff_id_2 ~= nil then
	            	table.insert(buffIds, skillData.buff_id_2)
	            end
	            for _, buffId in ipairs(buffIds) do
	            	local id = buffId
	            	id = string.find(id, ",") and string.split(id, ",")[1] or (string.find(id, ";") and string.split(id, ";")[1] or id)
	                local buffData = dataBase:getBuffByID(id)
                	assert(buffData ~= nil, "can not find buff with id:" .. id)
	                if buffData.begin_effect_id ~= nil then
	                    effectIds[buffData.begin_effect_id] = buffData.begin_effect_id
	                end
	                if buffData.effect_id ~= nil then
	                    effectIds[buffData.effect_id] = buffData.effect_id
	                end
	                if buffData.finish_effect_id ~= nil then
	                    effectIds[buffData.finish_effect_id] = buffData.finish_effect_id
	                end
	                if buffData.replace_character ~= nil then
	                	local character = dataBase:getCharacterByID(buffData.replace_character)
			            if character ~= nil then
			            	table.insert(charactorDisplayIds, character.display_id)
			            end
	                end
	            end

	            -- effect of trap 
	            if skillData.trap_id ~= nil then
	                local trapData = dataBase:getTrapByID(skillData.trap_id)
	                if trapData.start_effect ~= nil then
	                    effectIds[trapData.start_effect] = trapData.start_effect
	                end
	                if trapData.execute_effect ~= nil then
	                    effectIds[trapData.execute_effect] = trapData.execute_effect
	                end
	                if trapData.area_effect ~= nil then
	                    effectIds[trapData.area_effect] = trapData.area_effect
	                end
	                if trapData.finish_effect ~= nil then
	                    effectIds[trapData.finish_effect] = trapData.finish_effect
	                end
	            end
	        end
	    end 

	end

	local skeletonFiles = {}
	for _, displayId in ipairs(charactorDisplayIds) do
    	local characterDisplay = dataBase:getCharacterDisplayByID(displayId)
        if characterDisplay ~= nil then
            local actorFile = characterDisplay.actor_file
            if string.find(actorFile, "fca/") == nil then
	            local skeletonFile = actorFile .. ".json"
	            local atlasFile = actorFile .. ".atlas"
	            -- table.insert(skeletonFiles, {actorFile})
	            table.insert(skeletonFiles, {skeletonFile, atlasFile})
	        end
            -- weapon
            if characterDisplay.weapon_file ~= nil then
                local weaponFile = characterDisplay.weapon_file
                if string.find(weaponFile, "fca/") == nil then
	                local weaponSkeletonFile = weaponFile .. ".json"
	                local weaponAtlasFile = weaponFile .. ".atlas"
	                -- table.insert(skeletonFiles, {weaponFile})
	                table.insert(skeletonFiles, {weaponSkeletonFile, weaponAtlasFile})
	            end
            end
            -- replace part
            if characterDisplay.replace_file ~= nil then
                local replaceFile = characterDisplay.replace_file
                if string.find(replaceFile, "fca/") == nil then
	                local replaceSkeletonFile = replaceFile .. ".json"
	                local replaceAtlasFile = replaceFile .. ".atlas"
	                -- table.insert(skeletonFiles, {replaceFile})
	                table.insert(skeletonFiles, {replaceSkeletonFile, replaceAtlasFile})
	            end
            end
            -- victor effect
            if characterDisplay.victory_effect ~= nil then
            	local effectId = characterDisplay.victory_effect
                effectIds[effectId] = effectId
            end
        end
    end

    effectIds["aid_buff_1"] = "aid_buff_1"
    effectIds["aid_buff_2"] = "aid_buff_2"
    effectIds["aid_buff_3"] = "aid_buff_3"
    effectIds["aid_buff_4"] = "aid_buff_4"
    effectIds["aid_buff_dun_1"] = "aid_buff_dun_1"
    effectIds["aid_buff_shu_1"] = "aid_buff_shu_1"
    effectIds["aid_buff_jian_1"] = "aid_buff_jian_1"
    effectIds["aid_buff_zhang_1"] = "aid_buff_zhang_1"
    effectIds["flash_out_1"] = "flash_out_1"

    local _effectIds = {}
    for _, v in pairs(effectIds) do
    	local subEffects = string.split(v, ";")
    	for _, v2 in ipairs(subEffects) do
    		_effectIds[v2] = v2
    	end
    end
    effectIds = _effectIds

    local effectFiles = {}
	for _, effectId in pairs(effectIds) do
        local frontFile, backFile = dataBase:getEffectFileByID(effectId)
        if frontFile ~= nil and string.find(frontFile, "fca/") == nil then
            local skeletonFile = frontFile .. ".json"
            local atlasFile = frontFile .. ".atlas"
            -- table.insert(effectFiles, {frontFile})
            table.insert(effectFiles, {skeletonFile, atlasFile})
        end
        if backFile ~= nil and string.find(backFile, "fca/") == nil then
            local skeletonFile = backFile .. ".json"
            local atlasFile = backFile .. ".atlas"
            -- table.insert(effectFiles, {backFile})
            table.insert(effectFiles, {skeletonFile, atlasFile})
        end
        local soundId = dataBase:getEffectSoundIdById(effectId)
        if soundId then
			local soundInfo = QStaticDatabase.sharedDatabase():getSoundById(soundId)
            if soundInfo ~= nil then
    			local sound = soundInfo.sound
    			local suffix = string.sub(sound, -4)
    			if suffix ~= ".mp3" then
    				if soundInfo.count == nil or soundInfo.count == 1 then
    					table.insert(sounds, sound .. ".mp3")
    				else
    		        	for index = 1, soundInfo.count do
    						table.insert(sounds, sound .. "_" .. tostring(index) .. ".mp3")
    		        	end
    				end
    			end
            end
        end
    end

    if DISABLE_LOAD_BATTLE_RESOURCES then
	    skeletonFiles = {}
	    effectFiles = {}
	    sounds = {}
	end
    
    local loadingSkeletonFiles = skeletonFiles
    local loadingSkeletonIndex = 1
    local loadingEffectFiles = effectFiles
    local loadingEffectIndex = 1
    local loadingSoundFiles = sounds
    local loadingSoundIndex = 1
    self._loadingSkeletonFrameId = scheduler.scheduleUpdateGlobal(function(dt)
		if loadingSkeletonIndex <= #loadingSkeletonFiles then
	    	local item = loadingSkeletonFiles[loadingSkeletonIndex]
		    if item[1] ~= nil and item[2] ~= nil then
				local isResolutionHalf = isTextureResolutionHalf()
				setTextureResolutionHalf(BATTLE_TEXTURE_RESOLUTION_HALF)
				local isTexture16bit = isTextureForceRGBA4444()
				setTextureForceRGBA4444(true)
		        local skeletonData = QSkeletonDataCache:sharedSkeletonDataCache():cacheSkeletonData(item[1], item[2])
		        setTextureResolutionHalf(isResolutionHalf)
		        setTextureForceRGBA4444(isTexture16bit)
		        if skeletonData ~= nil then
		            skeletonData:retain()
		            table.insert(self._skeletonDatas, skeletonData)
		        end
		    -- elseif item[1] ~= nil and item[2] == nil then
		    -- 	local fileUtils = CCFileUtils:sharedFileUtils()
		    -- 	local pvrFile = fileUtils:fullPathForFilename(item[1] .. ".pvr.ccz")
		    -- 	if fileUtils:isFileExist(pvrFile) == true then
		    -- 		CCTextureCache:sharedTextureCache():addImage(pvrFile)
		    -- 	else
		    -- 		local pngFile = fileUtils:fullPathForFilename(item[1] .. ".png")
		    -- 		if fileUtils:isFileExist(pngFile) == true then
		    -- 			CCTextureCache:sharedTextureCache():addImage(pngFile)
		    -- 		else
		    -- 			assert(false, "image file: " .. pvrFile .. " or " .. pngFile .. " is not exist")
		    -- 		end
		    -- 	end
		    end
		    loadingSkeletonIndex = loadingSkeletonIndex + 1

		elseif loadingEffectIndex <= #loadingEffectFiles then
			for i=1,4 do
				local item = loadingEffectFiles[loadingEffectIndex]
			    if item[1] ~= nil and item[2] ~= nil then
					local isResolutionHalf = isTextureResolutionHalf()
					setTextureResolutionHalf(BATTLE_TEXTURE_RESOLUTION_HALF)
					local isTexture16bit = isTextureForceRGBA4444()
					setTextureForceRGBA4444(true)
			        local skeletonData = QSkeletonDataCache:sharedSkeletonDataCache():cacheSkeletonData(item[1], item[2])
			        setTextureResolutionHalf(isResolutionHalf)
			        setTextureForceRGBA4444(isTexture16bit)
			        if skeletonData ~= nil then
			            skeletonData:retain()
			            table.insert(self._skeletonDatas, skeletonData)
			        end
			    -- elseif item[1] ~= nil and item[2] == nil then
			    -- 	local fileUtils = CCFileUtils:sharedFileUtils()
			    -- 	local pvrFile = fileUtils:fullPathForFilename(item[1] .. ".pvr.ccz")
			    -- 	if fileUtils:isFileExist(pvrFile) == true then
			    -- 		CCTextureCache:sharedTextureCache():addImage(pvrFile)
			    -- 	else
			    -- 		local pngFile = fileUtils:fullPathForFilename(item[1] .. ".png")
			    -- 		if fileUtils:isFileExist(pngFile) == true then
			    -- 			CCTextureCache:sharedTextureCache():addImage(pngFile)
			    -- 		else
			    -- 			assert(false, "image file: " .. pvrFile .. " or " .. pngFile .. " is not exist")
			    -- 		end
			    -- 	end
			    end
			    loadingEffectIndex = loadingEffectIndex + 1
			    if loadingEffectIndex > #loadingEffectFiles then
			    	break
			    end
			end
		elseif loadingSoundIndex <= #loadingSoundFiles then
			for i=1,10 do
				audio.preloadSound(loadingSoundFiles[loadingSoundIndex])
				loadingSoundIndex = loadingSoundIndex + 1
				if loadingSoundIndex > #loadingSoundFiles then
					break
				end
			end
		end
		
	    if loadingSkeletonIndex > #loadingSkeletonFiles 
	    	and loadingEffectIndex > #loadingEffectFiles 
	    	and loadingSoundIndex > #loadingSoundFiles then
	        scheduler.unscheduleGlobal(self._loadingSkeletonFrameId)
	        self._loadingSkeletonFrameId = nil
	        if self._updateCallback ~= nil then
	        	self._updateCallback(1)
	        	self._updateCallback = nil
	        end
	    else
	    	if self._updateCallback ~= nil then
	        	self._updateCallback((loadingSkeletonIndex + loadingEffectIndex + loadingSoundIndex - 3)/(#loadingSkeletonFiles + #loadingEffectFiles + #loadingSoundFiles))
	        end
	    end
    end, 0.0)
	
end

function QSkeletonViewController:removeSkeletonData()
    if self._loadingSkeletonFrameId ~= nil then
        scheduler.unscheduleGlobal(self._loadingSkeletonFrameId)
        self._loadingSkeletonFrameId = nil
        self._updateCallback = nil
    end

    if self._skeletonDatas == nil then
        self._skeletonDatas = {}
        return
    end

    if #self._skeletonDatas == 0 then
        return 
    end

    for _, skeletonData in ipairs(self._skeletonDatas) do
        skeletonData:release()
    end

    self._skeletonDatas = {}
end


return QSkeletonViewController

local QModelBase = import("...models.QModelBase")
local QBattleVCR = class("QBattleVCR", QModelBase)

local RECORD_INTERVAL = 0.1

function QBattleVCR:ctor()
    QBattleVCR.super.ctor(self)
end

function QBattleVCR:start()
	if self._schedule_id then
		return
	end

	self._frames = {}
    self._frames_by_cat = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
    self._key_frames_by_props_by_udid = {}
    self._maxhps = {}
    self._actor_ids = {}
	self._dungeon_duration = app.battle:getDungeonDuration()

    self._animation_dict = {}
    self._animation_array = {}

	self._schedule_id = scheduler.scheduleGlobal(handler(self, QBattleVCR.update), RECORD_INTERVAL)
	self._eventProxies = {}
	self._time = app.battle:getTime()
end

function QBattleVCR:stop()
	if not self._schedule_id then
		return
	end

	scheduler.unscheduleGlobal(self._schedule_id)
	self._schedule_id = nil

	for _, proxy in pairs(self._eventProxies) do
		proxy:removeAllEventListeners()
	end
	self._eventProxies = nil
end

function QBattleVCR:loadFromLastVCR()
	if self._schedule_id then
		return
	end

	local fileutil = CCFileUtils:sharedFileUtils()
	local filepath = fileutil:getWritablePath() .. "last.vcr"
	if not fileutil:isFileExist(filepath) then
		return
	end

	local content = fileutil:getFileData(filepath)
    local raw_table = json.decode(content)
	self._maxhps = raw_table._maxhps
	self._frames_by_cat = raw_table._frames_by_cat
	self._key_frames_by_props_by_udid = raw_table._key_frames_by_props_by_udid
	self._animation_dict = raw_table._animation_dict
	self._animation_array = raw_table._animation_array
	self._dungeon_duration = raw_table._dungeon_duration
	self._actor_ids = raw_table._actor_ids
    -- 展开cat = 1
    local frames_cat_1 = self._frames_by_cat[1]
    local key_frames_by_props_by_udid = self._key_frames_by_props_by_udid
    for udid, key_frames_by_props in pairs(key_frames_by_props_by_udid) do
    	for prop, key_frames in pairs(key_frames_by_props) do
    		for i, key_frame_index in ipairs(key_frames) do
    			local frame = frames_cat_1[key_frame_index]
    			key_frames[i] = {frame = frame, value = frame.objs[udid].props[prop], time = frame.time}
    		end
    	end
    end
end

function QBattleVCR:saveAsLastVCR()
    -- 压缩cat = 1
    local frames_cat_1 = self._frames_by_cat[1]
    local key_frames_by_props_by_udid = self._key_frames_by_props_by_udid
    for _, key_frames_by_props in pairs(key_frames_by_props_by_udid) do
    	for _, key_frames in pairs(key_frames_by_props) do
    		for _, key_frame in ipairs(key_frames) do
    			key_frame.frame._useful = true
    		end
    	end
    end
    local new_frames_cat_1 = {}
    for _, frame in ipairs(frames_cat_1) do
    	if frame._useful then
    		table.insert(new_frames_cat_1, frame)
    		frame._frame_index = #new_frames_cat_1
    	end
    	frame._useful = nil
    end
    local new_key_frames_by_props_by_udid = {}
    for udid, key_frames_by_props in pairs(key_frames_by_props_by_udid) do
    	local new_key_frames_by_props = {}
    	new_key_frames_by_props_by_udid[udid] = new_key_frames_by_props
    	for prop, key_frames in pairs(key_frames_by_props) do
    		local new_key_frames = {}
    		new_key_frames_by_props[prop] = new_key_frames
    		for i, key_frame in ipairs(key_frames) do
    			local new_key_frame = key_frame.frame._frame_index
    			new_key_frames[i] = new_key_frame
    		end
    	end
    end
    for _, frame in ipairs(frames_cat_1) do
    	frame._frame_index = nil
    end
    local new_frames_by_cat = {}
    for i, frames_cat in ipairs(self._frames_by_cat) do
    	new_frames_by_cat[i] = frames_cat
    end
    new_frames_by_cat[1] = new_frames_cat_1
    -- 组装save_table
    local save_table = {_maxhps = self._maxhps, 
						_frames_by_cat = new_frames_by_cat, 
						_key_frames_by_props_by_udid = new_key_frames_by_props_by_udid,
						_animation_dict = self._animation_dict,
						_animation_array = self._animation_array,
						_dungeon_duration = self._dungeon_duration,
						_actor_ids = self._actor_ids}

	local json_string = json.encode(save_table)
	if json_string then
		writeToFile("last.vcr", json_string)
    end
end

function QBattleVCR:update(dt)
	local battle = app.battle

	if battle:isPaused() then
		return
	end

	local scene = app.scene
	local frames = self._frames
	local frames_cat = self._frames_by_cat[1]
	local key_frames_by_props_by_udid = self._key_frames_by_props_by_udid
	local heroes = app.battle:getHeroes()
	local enemies = app.battle:getEnemies()
	local appear_actors = app.battle._appearActors
	local proxies = self._eventProxies
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	local actors = {}
	table.mergeForArray(actors, heroes)
	table.mergeForArray(actors, enemies)
	for _, actor in pairs(appear_actors) do
		table.insert(actors, actor)
	end
	for _, actor in ipairs(actors) do
		local view = scene:getActorViewFromModel(actor)
		local obj = {}
		local udid = actor:getUDID()
		obj.props = {}
		-- obj.props["hp"] = actor:getHp()
		obj.props["x"] = actor:getPosition().x
		obj.props["y"] = actor:getPosition().y
		if view then
			obj.props["flip"] = view:isFlipX()
			obj.props["scale"] = view:getScale()
		end
		frame.objs[udid] = obj

		local proxy = self._eventProxies[udid]
		if not proxy then
			local new_actor = actor
			proxy = cc.EventProxy.new(new_actor)
			proxy:addEventListener(actor.UNDER_ATTACK_EVENT, function(event) self:_onHit(event, new_actor) end)
    		proxy:addEventListener(actor.PLAY_SKILL_EFFECT, function(event) self:_onPlayEffectForSkill(event, new_actor) end)
    		proxy:addEventListener(actor.CANCEL_SKILL, function(event) self:_onSkillCancel(event, new_actor) end)
    		proxy:addEventListener(actor.STOP_SKILL_EFFECT, function(event) self:_onRemoveEffectForSkill(event, new_actor) end)
    		proxy:addEventListener(actor.BUFF_STARTED, function(event) self:_onBuffStarted(event, new_actor) end)
    		proxy:addEventListener(actor.BUFF_ENDED, function(event) self:_onBuffEnded(event, new_actor) end)
			self._eventProxies[udid] = proxy
		end

		local key_frames_by_props = key_frames_by_props_by_udid[udid]
		if not key_frames_by_props then
			key_frames_by_props = {}
			key_frames_by_props_by_udid[udid] = key_frames_by_props
		end

		for prop, value in pairs(obj.props) do
			local key_frames = key_frames_by_props[prop]
			if not key_frames then
				key_frames = {}
				key_frames_by_props[prop] = key_frames
			end

			local last_last_key_frame = key_frames[#key_frames - 1]
			local last_key_frame = key_frames[#key_frames]
			if not last_key_frame then
				key_frames[#key_frames + 1] = {value = value, frame = frame, time = time}
			elseif last_key_frame.value == value then
				if last_last_key_frame and last_last_key_frame.value == value then
					key_frames[#key_frames] = {value = value, frame = frame, time = time}
				else
					key_frames[#key_frames + 1] = {value = value, frame = frame, time = time}
				end
			else
				key_frames[#key_frames + 1] = {value = value, frame = frame, time = time}
			end 
		end

		self._maxhps[udid] = actor:getMaxHp()
		self._actor_ids[udid] = actor:getActorID()
	end
	frames[#frames + 1] = frame
	frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onHit(event, actor)
	if not self._schedule_id then
		return
	end

    if event.tip == "0" then return end

	local _event = {tip = event.tip, isTreat = event.isTreat, isCritical = event.isCritical}
    local frames = self._frames
	local frames_cat = self._frames_by_cat[2]
	local time = app.battle:getTime() - self._time

    local frame = {time = time, objs = {}}
    frame.objs[actor:getUDID()] = {hp = actor:getHp(), event = _event}
    frames[#frames + 1] = frame
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_getAnimationIndex(animation_name)
	local animation_dict = self._animation_dict
	local animation_array = self._animation_array
	local animation_index = animation_dict[animation_name]
	if not animation_index then
		animation_index = #animation_array + 1
		animation_array[animation_index] = animation_name
		animation_dict[animation_name] = animation_index
	end

	return animation_index
end

function QBattleVCR:_onChangeAnimation(actor, animation_queue, is_loop)
	if not self._schedule_id then
		return
	end

	local frames = self._frames
	local frames_cat = self._frames_by_cat[3]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	local animation_index_queue = {}
    for i, animation in ipairs(animation_queue) do
    	animation_index_queue[i] = self:_getAnimationIndex(animation)
    end
	frame.objs[actor:getUDID()] = {animation_index_queue = animation_index_queue, is_loop = is_loop}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onChangeAnimationScale(actor, scale)
	if not self._schedule_id then
		return
	end

	local frames = self._frames
	local frames_cat = self._frames_by_cat[4]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	frame.objs[actor:getUDID()] = {animation_scale = scale}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onPlayEffectForSkill(event, actor)
	if not self._schedule_id then
		return
	end

	local options = event.options
	local _event = {}
	_event.effectID = event.effectID
	_event.options = {rotateToPosition = options.rotateToPosition, externalRotate = options.externalRotate, time_scale = options.time_scale, 
					isRandomPosition = options.isRandomPosition, isFlipX = options.isFlipX, targetPosition = options.targetPosition, isLoop = options.isLoop, 
					isAttackEffect = options.isAttackEffect, skillId = options.skillId, followActorAnimation = options.followActorAnimation}

	local frames = self._frames
	local frames_cat = self._frames_by_cat[5]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	frame.objs[actor:getUDID()] = {event = _event}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onSkillCancel(event, actor)
	if not self._schedule_id then
		return
	end

	local options = event.options
	local _event = {}
	_event.skillId = event.skillId
	_event.options = {}

	local frames = self._frames
	local frames_cat = self._frames_by_cat[6]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	frame.objs[actor:getUDID()] = {event = _event}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onRemoveEffectForSkill(event, actor)
	if not self._schedule_id then
		return
	end

	local options = event.options
	local _event = {}
	_event.effectID = event.effectID
	_event.options = {}

	local frames = self._frames
	local frames_cat = self._frames_by_cat[7]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	frame.objs[actor:getUDID()] = { event = _event}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onBuffStarted(event, actor)
	if not self._schedule_id then
		return
	end

	local frames = self._frames
	local frames_cat = self._frames_by_cat[8]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	frame.objs[actor:getUDID()] = {buff_id = event.buff:getId()}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onBuffTrigger(event, actor)
	if not self._schedule_id then
		return
	end

	local frames = self._frames
	local frames_cat = self._frames_by_cat[9]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	frame.objs[actor:getUDID()] = {buff_id = event.buff:getId()}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onBuffEnded(event, actor)
	if not self._schedule_id then
		return
	end

	local frames = self._frames
	local frames_cat = self._frames_by_cat[10]
	local time = app.battle:getTime() - self._time

	local frame = {time = time, objs = {}}
	frame.objs[actor:getUDID()] = {buff_id = event.buff:getId()}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onBulletCreated(bullet)
	if not self._schedule_id then
		return
	end

	local frames = self._frames
	local frames_cat = self._frames_by_cat[11]
	local time = app.battle:getTime() - self._time

	local attacker_udid = bullet._attacker:getUDID()
	local targets_udid = {}
	for _, target in ipairs(bullet._targets) do
		table.insert(targets_udid, target:getUDID())
	end
	local bullet_effect_id = bullet._options.effect_id or bullet._skill:getBulletEffectID()
    local bullet_speed = bullet._options.speed or bullet._skill:getBulletSpeed()
    local options = bullet._options
    local _options =  {is_not_loop = options.is_not_loop, is_throw = options.is_throw, hit_duration = options.hit_duration, height_ratio = options.height_ratio, throw_speed = options.throw_speed,
    				at_position = options.at_position, from_target = options.from_target, is_random_position = options.is_random_position, scissor = options.scissor, 
    				start_position = options.start_position, end_position = options.end_position, disappear_position = options.disappear_position, size_render_texture = options.size_render_texture}

    if _options.size_render_texture then
    	_options.size_render_texture = {width = _options.size_render_texture.width, height = _options.size_render_texture.height}
    end

	local frame = {time = time, objs = {}}
	frame.objs[1] = {attacker_udid = attacker_udid, targets_udid = targets_udid, bullet_effect_id = bullet_effect_id, bullet_speed = bullet_speed, options = _options}
    frames_cat[#frames_cat + 1] = frame
end

function QBattleVCR:_onLaserCreated(laser)
	if not self._schedule_id then
		return
	end

	local frames = self._frames
	local frames_cat = self._frames_by_cat[12]
	local time = app.battle:getTime() - self._time

	local attacker_udid = laser._attacker:getUDID()
	local targets_udid = {}
	for _, target in ipairs(laser._targets) do
		table.insert(targets_udid, target:getUDID())
	end
	local bullet_effect_id = laser._options.effect_id or laser._skill:getBulletEffectID()
    local options = clone(laser._options)
    options.effect_id = nil

	local frame = {time = time, objs = {}}
	frame.objs[1] = {attacker_udid = attacker_udid, targets_udid = targets_udid, bullet_effect_id = bullet_effect_id, options = options}
    frames_cat[#frames_cat + 1] = frame
end

return QBattleVCR
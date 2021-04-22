
local QBaseScene = import("...scenes.QBaseScene")
local QBattleVCRScene = class("QBattleVCRScene", QBaseScene)

local QFileCache = import("...utils.QFileCache")
local QBaseActorView = import("...views.QBaseActorView")
local QTouchActorView = import("...views.QTouchActorView")
local QHeroActorView = import("...views.QHeroActorView")
local QNpcActorView = import("...views.QNpcActorView")
local QVCRActorView = import("...vcr.views.QVCRActorView")
local QDragLineController = import("...controllers.QDragLineController")
local QTouchController = import("...controllers.QTouchController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QBattleManager = import("...controllers.QBattleManager")
local QBattleVCRManager = import("...vcr.controllers.QBattleVCRManager")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QPositionDirector = import("...utils.QPositionDirector")
local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")
local QBuff = import("...models.QBuff")
local QVCRBullet = import("...vcr.models.QVCRBullet")
local QVCRLaser = import("...vcr.models.QVCRLaser")
local QHeroStatusView = import("...ui.battle.QHeroStatusView")
local QBattleDialog = import("...ui.battle.QBattleDialog")
local QBattleDialogGameRule = import("...ui.battle.QBattleDialogGameRule")
local QBattleDialogPause = import("...ui.battle.QBattleDialogPause")
local QBattleDialogAutoSkill = import("...ui.battle.QBattleDialogAutoSkill")
local QBattleDialogMissions = import("...ui.battle.QBattleDialogMissions")
local QBossHpView = import("...ui.battle.QBossHpView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QDialogTeamUp = import("...ui.battle.QDialogTeamUp")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetTutorialDialogue = import("...ui.widgets.QUIWidgetTutorialDialogue")
local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QUIWidgetItemsBox = import("...ui.widgets.QUIWidgetItemsBox")
local QBattleMissionTracer = import("...tracer.QBattleMissionTracer")
local QEntranceBase = import("...cutscenes.QEntranceBase")
local QKreshEntrance = import("...cutscenes.QKreshEntrance")
local QNavigationController = import("...controllers.QNavigationController")
local QMissionBase = import("...tracer.mission.QMissionBase")
local QFullCircleUiMask = import("...ui.battle.QFullCircleUiMask")

function QBattleVCRScene:ctor(vcr)
    local owner = {}
    QBattleVCRScene.super.ctor(self, {ccbi = "ccb/Battle_Scene.ccbi", owner = owner})
    self._backgroundImage = CCSprite:create("map/scarlet_monastery02.jpg")
    owner.node_background:addChild(self._backgroundImage)

    self._groundEffectView = {}
    self._effectViews = {}
    self._frontEffectView = {}

    local tip_cache = self.createTipCache()
    tip_cache.makeRoom("effects/Heal_number.ccbi", 8)
    tip_cache.makeRoom("effects/Attack_Ynumber.ccbi", 8)
    tip_cache.makeRoom("effects/Attack_number.ccbi", 8)
    tip_cache.makeRoom("effects/Attack_baoji.ccbi", 4)
    tip_cache.makeRoom("effects/Attack_Ybaoji.ccbi", 4)
    self._tip_cache = tip_cache

	self._vcr = vcr
	self._schedule_id = scheduler.scheduleUpdateGlobal(handler(self, QBattleVCRScene.update), 0)
	self._time = q.time()
	self._pawns = {}

	local frame_index_by_props_by_udid = {}
	for udid, key_frames_by_props in pairs(vcr._key_frames_by_props_by_udid) do
		local frame_index_by_props = {}
	    frame_index_by_props_by_udid[udid] = frame_index_by_props
	end
	self._frame_index_by_props_by_udid = frame_index_by_props_by_udid
	self._frame_index_by_cat = {}
end

function QBattleVCRScene:_updateActorZOrder()
    local allActorView = {}
    for _, pawn in pairs(self._pawns) do
        table.insert(allActorView, pawn.view)
    end
    local sortedActorView = q.sortNodeZOrder(allActorView, false)

    local layer = self:getBackgroundOverLayer()

    -- reset the z order
    local zOrder = 1
    for _, view in ipairs(self._groundEffectView) do
        view:setZOrder(zOrder)
        zOrder = zOrder + 1
    end
    for _, view in ipairs(sortedActorView) do
        view:setZOrder(zOrder)
        zOrder = zOrder + 1
    end

    if layer:isVisible() == true then
        for i, view in ipairs(self._frontEffectView) do
            view:setZOrder(zOrder)
            zOrder = zOrder + 1
        end
        
        layer:setZOrder(zOrder)
        zOrder = zOrder + 1
    else
        for i, view in ipairs(self._frontEffectView) do
            view:setZOrder(zOrder)
            zOrder = zOrder + 1
        end
    end

    return zOrder
end

function QBattleVCRScene:addEffectViews(effect, options)
    if effect == nil then
        return
    end

    options = options or {}
    if options.isFrontEffect == true then
        table.insert(self._frontEffectView, effect)
    elseif options.isGroundEffect == true then
        table.insert(self._groundEffectView, effect)
    else
        table.insert(self._effectViews, effect)
    end
    self:addSkeletonContainer(effect)
end

function QBattleVCRScene:removeEffectViews(effect)
    if effect == nil then
        return
    end

    for i, view in ipairs(self._effectViews) do
        if effect == view then
            effect:removeFromParent()
            table.remove(self._effectViews, i)
            return
        end
    end

    for i, view in ipairs(self._frontEffectView) do
        if effect == view then
            effect:removeFromParent()
            table.remove(self._frontEffectView, i)
            return
        end
    end

    for i, view in ipairs(self._groundEffectView) do
        if effect == view then
            effect:removeFromParent()
            table.remove(self._groundEffectView, i)
            return
        end
    end
end

function QBattleVCRScene:_onFrame(dt)
    local zOrder = self:_updateActorZOrder()
end

function QBattleVCRScene:onEnter()
    QBattleVCRScene.super.onEnter(self)

    app.scene = self
    app.battle = QBattleVCRManager.new()
    app.battle:start()

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QBattleVCRScene:onExit()
    app.battle:stop()
    app.battle = nil
    app.scene = nil

    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)

    for _, pawn in pairs(self._pawns) do
    	pawn.view:removeFromParent()
    	pawn.view = nil
    end

    for i, view in ipairs(self._groundEffectView) do
       view:removeFromParent()
    end
    self._groundEffectView = {}

    for i, view in ipairs(self._effectViews) do
       view:removeFromParent()
    end
    self._effectViews = {}

    for i, view in ipairs(self._frontEffectView) do
       view:removeFromParent()
    end
    self._frontEffectView = {}

    QBattleVCRScene.super.onExit(self)
end

function QBattleVCRScene:getTip(ccb_name)
    return self._tip_cache.getTip(ccb_name)
end

function QBattleVCRScene:returnTip(tip)
    self._tip_cache.returnTip(tip)
end

function QBattleVCRScene:getActorViewFromModel(actor)
	return self._pawns[actor:getUDID()].view
end

function QBattleVCRScene:update(dt)
	self:_updateKeyFrames()
	self:_updateOnHit()
	self:_updateAnimationChange()
	self:_updateAnimationScale()
	self:_updatePlayEffectForSkill()
	self:_updateSkillCancel()
	self:_updateRemoveEffectForSkill()
	self:_updateBuffStarted()
	self:_updateBuffTrigger()
	self:_updateBuffEnded()
	self:_updateBulletCreated()
	self:_updateLaserCreated()
end

function QBattleVCRScene:_updateKeyFrames()
	local vcr = self._vcr
	local frames = vcr._frames
	local frame_index_by_props_by_udid = self._frame_index_by_props_by_udid
	local pawns = self._pawns
	local time = q.time() - self._time

	for udid, key_frames_by_props in pairs(vcr._key_frames_by_props_by_udid) do
		local frame_index_by_props = frame_index_by_props_by_udid[udid]
		for prop, key_frames in pairs(key_frames_by_props) do
			local frame_index = frame_index_by_props[prop]
			local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(key_frames, frame_index, time)
			if left_frame_index and right_frame_index then
				local left_frame = key_frames[left_frame_index]
				local right_frame = key_frames[right_frame_index]
				local obj = left_frame.frame.objs[udid]
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view
				if prop == "hp" then
				elseif prop == "x" then
					local value = left_frame.time == right_frame.time and left_frame.value or math.sampler(left_frame.value, right_frame.value, (time - left_frame.time) / (right_frame.time - left_frame.time))
					-- view:setPositionX(value)
					local pos = actor:getPosition()
					pos.x = value
					actor:setActorPosition(pos)
				elseif prop == "y" then
					local value = left_frame.time == right_frame.time and left_frame.value or math.sampler(left_frame.value, right_frame.value, (time - left_frame.time) / (right_frame.time - left_frame.time))
					-- view:setPositionY(value)
					local pos = actor:getPosition()
					pos.y = value
					actor:setActorPosition(pos)
				elseif prop == "flip" then
					local value = left_frame.value
					if value ~= view:isFlipX() then
						view:_setFlipX()
					end
				elseif prop == "scale" then
					local value = left_frame.time == right_frame.time and left_frame.value or math.sampler(left_frame.value, right_frame.value, (time - left_frame.time) / (right_frame.time - left_frame.time))
					view:setScale(value)
				end
			end
			frame_index_by_props[prop] = left_frame_index
		end
	end
end

function QBattleVCRScene:_createPawn(udid)
	local pawns = self._pawns
	local vcr = self._vcr
	local actor_id = vcr._actor_ids[udid]

	local actor = app:createVCRNpc(actor_id, udid)
	actor:setMaxHp(vcr._maxhps[udid])
    local view = QVCRActorView.new(actor)
    self:addSkeletonContainer(view)
    view:retain()

    pawns[udid] = {actor = actor, view = view}
end

function QBattleVCRScene:_updateOnHit()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[2]
	local animation_array = vcr._animation_array
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[2]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view

				actor:setHp(obj.hp)
				if obj.hp == 0 then
					if not actor:isDead() then
						actor:setIsDead(true)
			            local array = CCArray:create()
			            array:addObject(CCDelayTime:create(global.npc_view_dead_delay))          -- after 2 seconds
			            array:addObject(CCBlink:create(global.npc_view_dead_blink_time, 3))           -- blink the npc 3 times in 1 second
			            array:addObject(CCRemoveSelf:create(true))      -- and then remove it from scene
			            view:runAction(CCSequence:create(array))
					end
				end
				view:_onHit(obj.event)
				view:_onHpChanged(obj.event)
			end
		end
	end

	frame_index_by_cat[2] = left_frame_index
end

function QBattleVCRScene:_updateAnimationChange()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[3]
	local animation_array = vcr._animation_array
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[3]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view
				local animation_index_queue = obj.animation_index_queue
			    for i, animation_index in ipairs(animation_index_queue) do
			    	local animation = animation_array[animation_index]
			        local isLoop = (obj.is_loop or animation == ANIMATION.STAND or animation == ANIMATION.WALK or animation == ANIMATION.REVERSEWALK)
			        if i == 1 then
			            view._skeletonActor:playAnimation(animation, isLoop)
			        else
			            view._skeletonActor:appendAnimation(animation, isLoop)
			        end
			    end
			end
		end
	end

	frame_index_by_cat[3] = left_frame_index
end

function QBattleVCRScene:_updateAnimationScale()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[4]
	local animation_array = vcr._animation_array
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[4]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view
				view._skeletonActor:setAnimationScale(obj.animation_scale)
			end
		end
	end

	frame_index_by_cat[4] = left_frame_index
end

function QBattleVCRScene:_updatePlayEffectForSkill()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[5]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[5]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view
				view:_onPlayEffectForSkill(obj.event)
			end
		end
	end

	frame_index_by_cat[5] = left_frame_index
end

function QBattleVCRScene:_updateSkillCancel()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[6]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[6]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view
				view:_onSkillCancel(obj.event)
			end
		end
	end

	frame_index_by_cat[6] = left_frame_index
end

function QBattleVCRScene:_updateRemoveEffectForSkill()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[7]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[7]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view
				view:_onRemoveEffectForSkill(obj.event)
			end
		end
	end

	frame_index_by_cat[7] = left_frame_index
end

function QBattleVCRScene:_updateBuffStarted()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[8]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[8]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view

    			local newBuff = QBuff.new(obj.buff_id, actor, nil)
    			table.insert(actor._buffs, newBuff)
				view:_onBuffStarted({buff = newBuff})
			end
		end
	end

	frame_index_by_cat[8] = left_frame_index
end

function QBattleVCRScene:_updateBuffTrigger()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[9]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[9]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view

				local buff_id = obj.buff_id
				for _, buff in ipairs(actor._buffs) do
					if buff:getId() == buff_id then
						view:_onBuffTrigger({buff = buff})
						break
					end
				end
			end
		end
	end

	frame_index_by_cat[9] = left_frame_index
end

function QBattleVCRScene:_updateBuffEnded()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[10]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[10]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for udid, obj in pairs(frame.objs) do
				if pawns[udid] == nil then
					self:_createPawn(udid)
				end
				local pawn = pawns[udid]
				local actor = pawn.actor
				local view = pawn.view

				local buff_id = obj.buff_id
				for index, buff in ipairs(actor._buffs) do
					if buff:getId() == buff_id then
						view:_onBuffEnded({buff = buff})
    					table.remove(actor._buffs, index)
						break
					end
				end
			end
		end
	end

	frame_index_by_cat[10] = left_frame_index
end

function QBattleVCRScene:_updateBulletCreated()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[11]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[11]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for _, obj in ipairs(frame.objs) do
				local attacker_udid = obj.attacker_udid
				local targets_udid = obj.targets_udid
				local attacker_pawn = pawns[attacker_udid]
				if attacker_pawn and not attacker_pawn.actor:isDead() then
					local targets = {}
					local quit = true
					for _, udid in ipairs(targets_udid) do
						local target_pawn = pawns[udid]
						if target_pawn and not target_pawn.actor:isDead() then
							table.insert(targets, target_pawn.actor)
							quit = false
						end
					end
					if not quit then
						if obj.options.size_render_texture then
							local size_render_texture = obj.options.size_render_texture
							size_render_texture = CCSize(size_render_texture.width, size_render_texture.height)
							obj.options.size_render_texture = size_render_texture
						end
					    local bullet = QVCRBullet.new(attacker_pawn.actor, targets, obj.bullet_effect_id, obj.bullet_speed, obj.options)
					    app.battle:addBullet(bullet)
					end
				end
			end
		end
	end

	frame_index_by_cat[11] = left_frame_index
end

function QBattleVCRScene:_updateLaserCreated()
	local pawns = self._pawns
	local vcr = self._vcr
	local frame_index_by_cat = self._frame_index_by_cat
	local frames = vcr._frames
	local frames_cat = vcr._frames_by_cat[12]
	local time = q.time() - self._time

	local frame_index = frame_index_by_cat[12]
	local left_frame_index, right_frame_index = self:_getLeftRightFrameIndex(frames_cat, frame_index, time)
	if left_frame_index then
		for frame_index = frame_index and frame_index + 1 or 1, left_frame_index do
			local frame = frames_cat[frame_index]
			for _, obj in ipairs(frame.objs) do
				local attacker_udid = obj.attacker_udid
				local targets_udid = obj.targets_udid
				local attacker_pawn = pawns[attacker_udid]
				if attacker_pawn and not attacker_pawn.actor:isDead() then
					local targets = {}
					local quit = true
					for _, udid in ipairs(targets_udid) do
						local target_pawn = pawns[udid]
						if target_pawn and not target_pawn.actor:isDead() then
							table.insert(targets, target_pawn.actor)
							quit = false
						end
					end
					if not quit then
					    local laser = QVCRLaser.new(attacker_pawn.actor, targets, obj.bullet_effect_id, obj.options)
					    app.battle:addLaser(laser)
					end
				end
			end
		end
	end

	frame_index_by_cat[12] = left_frame_index
end

function QBattleVCRScene:_getLeftRightFrameIndex(key_frames, frame_index, time)
	local left_frame_index = frame_index
	while true do
		local next_index = left_frame_index and left_frame_index + 1 or 1
		local frame = key_frames[next_index]
		if not frame or frame.time > time then
			break
		else
			left_frame_index = next_index
		end
	end
	local right_frame_index = left_frame_index
	local next_index = right_frame_index and right_frame_index + 1 or 1
	local frame = key_frames[next_index]
	if frame then
		right_frame_index = next_index
	end

	return left_frame_index, right_frame_index
end

return QBattleVCRScene
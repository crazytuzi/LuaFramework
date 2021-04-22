
local QEntranceBase = class("QEntranceBase")

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QSkeletonViewController = import("..controllers.QSkeletonViewController")

QEntranceBase.ANIMATION_FINISHED = "CUTSCENE_ANIMATION_FINISHED"

function QEntranceBase:ctor(name, options)
	self._name = name
	self._view = CCNode:create()

	self._skeletonView = {}
	self._sceneEffect = {}

	self._skeletonRoot = CCNode:create()
	self._sceneEffectRoot = CCNode:create()
	self._uiRoot = CCNode:create()

	self._view:addChild(self._sceneEffectRoot)
	self._view:addChild(self._skeletonRoot)
	self._view:addChild(self._uiRoot)

	self._frameHandler = scheduler.scheduleUpdateGlobal(handler(self, self._onFrame))
end

function QEntranceBase:_addSceneEffect(effect)
	if effect == nil then
		return 
	end

	table.insert(self._sceneEffect, effect)
	self._sceneEffectRoot:addChild(effect)
end

function QEntranceBase:_addSkeletonView(view)
	if view == nil then
		return 
	end

	table.insert(self._skeletonView, view)
	self._skeletonRoot:addChild(view)
end

function QEntranceBase:getName()
	return self._name
end

function QEntranceBase:getView()
	return self._view
end

function QEntranceBase:startAnimation()

end

function QEntranceBase:exit()
	if self._frameHandler then
		scheduler.unscheduleGlobal(self._frameHandler)
		self._frameHandler = nil
	end

	self._view:removeFromParent()
end

function QEntranceBase:_onFrame(dt)
	self:_updateAnimation(dt)
	self:_sortingEffect()
	self:_sortingSkeleton()
end

function QEntranceBase:_updateAnimation(dt)
	
end

function QEntranceBase:_sortingEffect()
	local views = {}
    for i, view in ipairs(self._sceneEffect) do
        table.insert(views, view)
    end

    local sortedViews = q.sortNodeZOrder(views, false)

    local zOrder = 1
    for _, view in ipairs(sortedViews) do
        view:setZOrder(zOrder)
        zOrder = zOrder + 1
    end
end

function QEntranceBase:_sortingSkeleton()
	local views = {}
    for i, view in ipairs(self._skeletonView) do
        table.insert(views, view)
    end

    local sortedViews = q.sortNodeZOrder(views, false)

    local zOrder = 1
    for _, view in ipairs(sortedViews) do
        view:setZOrder(zOrder)
        zOrder = zOrder + 1
    end
end

function QEntranceBase:_createActorView(displayId)
	if displayId == nil then
		assert(false, "QEntranceBase:_createActorView displayId is nil")
		return nil
	end

	local staticDatabase = QStaticDatabase.sharedDatabase()
	local skeletonController = QSkeletonViewController.sharedSkeletonViewController()

	local displayInfo = staticDatabase:getCharacterDisplayByID(displayId)
	if displayInfo == nil then
		assert(false, "QEntranceBase:_createActorView faild get display information from id:" .. displayId)
		return nil
	end

	-- create actor
	local actorView = skeletonController:createSkeletonActorWithFile(displayInfo.actor_file)
	actorView:setSkeletonScaleX(displayInfo.actor_scale)
	actorView:setSkeletonScaleY(displayInfo.actor_scale)
	-- change weapon
	if displayInfo.weapon_file ~= nil then
		local parentBone = actorView:getParentBoneName(DUMMY.WEAPON)
	    actorView:replaceSlotWithFile(displayInfo.weapon_file, parentBone, ROOT_BONE, EFFECT_ANIMATION)
	end

    local replaceBone = displayInfo.replace_bone
    local replaceFile = displayInfo.replace_file
    if replaceBone ~= nil and replaceFile ~= nil then
        actorView:replaceSlotWithFile(replaceFile, replaceBone, ROOT_BONE, EFFECT_ANIMATION)
    end

	actorView.actorInfo = displayInfo

	return actorView
end

function QEntranceBase:_removeActorView(displayId)
	if displayId == nil then
		return
	end
	
	QSkeletonViewController:sharedSkeletonViewController():removeSkeletonActor(displayId)
end

function QEntranceBase:_createEffectAndAttachToActor(effectId, actorView)
	if effectId == nil or actorView == nil then
		assert(false, "QEntranceBase:_createEffectAndAttachToActor effectId or actorView is nil")
		return nil
	end

	local staticDatabase = QStaticDatabase.sharedDatabase()
	local skeletonController = QSkeletonViewController.sharedSkeletonViewController()

	local frontEffectFile, backEffectFile = staticDatabase:getEffectFileByID(effectId)
	local scale = staticDatabase:getEffectScaleByID(effectId)
    local playSpeed = staticDatabase:getEffectPlaySpeedByID(effectId)
    local rotation = staticDatabase:getEffectRotationByID(effectId)

	local frontEffect = nil
	local backEffect = nil

	if frontEffectFile ~= nil then
		local effectView = skeletonController:createSkeletonEffectWithFile(frontEffectFile)
		effectView:setSkeletonScaleX(scale)
        effectView:setSkeletonScaleY(scale)
        effectView:setAnimationScaleOriginal(playSpeed)
        effectView:setPosition(staticDatabase:getEffectOffsetByID(effectId))
        effectView:setRotation(rotation)

        frontEffect = CCNode:create()
        frontEffect:addChild(effectView)
        frontEffect.view = effectView
	end
	if backEffectFile ~= nil then
		local effectView = skeletonController:createSkeletonEffectWithFile(backEffectFile)
		effectView:setSkeletonScaleX(scale)
        effectView:setSkeletonScaleY(scale)
        effectView:setAnimationScaleOriginal(playSpeed)
        effectView:setPosition(staticDatabase:getEffectOffsetByID(effectId))
        effectView:setRotation(rotation)

        backEffect = CCNode:create()
        backEffect:addChild(effectView)
        backEffect.view = effectView
	end

	local dummy = staticDatabase:getEffectDummyByID(effectId)
	if dummy == nil then
		local positionX, positionY = actorView:getPosition()
		if frontEffect ~= nil then
			frontEffect:setPosition(positionX, positionY - 0.1)
	    	self:_addSceneEffect(frontEffect)
	    end
	    if backEffect ~= nil then
	    	backEffect:setPosition(positionX, positionY + 0.1)
	    	self:_addSceneEffect(backEffect)
	    end
		
	else
		local isFlipWithActor = staticDatabase:getEffectIsFlipWithActorByID(effectId)
	    if frontEffect ~= nil then
	    	self:_attachEffectToActor(frontEffect, actorView, dummy, false, isFlipWithActor)
	    end
	    if backEffect ~= nil then
	    	self:_attachEffectToActor(backEffect, actorView, dummy, true, isFlipWithActor)
	    end
	end

	return {front = frontEffect, back = backEffect}
end

function QEntranceBase:_attachEffectToActor(effect, actor, dummy, isBackSide, isFlipWithActor)
	if effect == nil or actor == nil or dummy == nil then
		return
	end

	if dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER then
        actor:attachNodeToBone(nil, effect, isBackSide, isFlipWithActor)
        local actorScale = actor.actorInfo.actor_scale
        local skeletonPositionX, skeletonPositionY = effect.view:getPosition()
        if dummy == DUMMY.TOP then
        	if isFlipWithActor == true then
                skeletonPositionY = skeletonPositionY + actor.actorInfo.selected_rect_height
            else
                skeletonPositionY = skeletonPositionY + actor.actorInfo.selected_rect_height * actorScale
            end
        elseif dummy == DUMMY.CENTER then
            if isFlipWithActor == true then
                skeletonPositionY = skeletonPositionY + actor.actorInfo.selected_rect_height * 0.5
            else
                skeletonPositionY = skeletonPositionY + actor.actorInfo.selected_rect_height * actorScale * 0.5
            end
        end
        effect.view:setPosition(skeletonPositionX, skeletonPositionY)
    else
        if actor:isBoneExist(dummy) == false then
        	actor:attachNodeToBone(nil, effect, isBackSide, isFlipWithActor)
        else
        	actor:attachNodeToBone(dummy, effect, isBackSide, isFlipWithActor)
        end
        
    end
end

return QEntranceBase

-- fca skeleton actor
--[[
ccnode
	setSkeletonScaleX
	setSkeletonScaleY
	flipActor
	getNode
animation
	updateAnimation(time)
	isHitAnimationPlaying
	playHitAnimation
	stopHitAnimation
	resetActorWithAnimation
	playAnimation
	appendAnimation
	getAnimationScale
	setAnimationScale
	pauseAnimation
	resumeAnimation
	canPlayAnimation
	getAnimationFrameCount
event
	connectAnimationEventSignal
	connectAnimationUpdateEventSignal
	disconnectAnimationEventSignal
	disconnectAnimationUpdateEventSignal
bone & slot
	attachNodeToBone
	detachNodeToBone
	removeReplaceSkeleton
	replaceSlotWithFile
	replaceSlotWithSkeletonAnimation3
	getBonePosition
	getRootBonePosition
	setRootBonePosition
	getParentBoneName(boneName)
	isBoneExist
init & reset
	reloadWithFile
effects
	addCustomNode
	getRenderTextureSprite
]]

local function createFcaSkeletonView(file, cat)
	local fcaAnim = app.FcaActorCreate(file, cat)
	local fcaNode = fcaAnim.node
	local fcaRoot = fcaAnim.root
	local view = {}
	-- ccnode
	function view:setSkeletonScaleX(scaleX)
		if cat == "actor" then
			-- fcaRoot:setScaleX(scaleX * -0.15)
			fcaRoot:setScaleX(scaleX * -1)
		else
			fcaRoot:setScaleX(scaleX)
		end
	end
	function view:setSkeletonScaleY(scaleY)
		if cat == "actor" then
			-- fcaRoot:setScaleY(scaleY * 0.15)
			fcaRoot:setScaleY(scaleY * 1)
		else
			fcaRoot:setScaleY(scaleY)
		end
	end
	function view:flipActor()
		fcaRoot:setScaleX(-fcaRoot:getScaleX())
	end
	function view:getNode()
		return fcaNode
	end
	function view:getRootScale()
		return fcaNode:getScaleX() * fcaRoot:getScaleX()
	end
	-- animation
	function view:updateAnimation(time)
		fcaAnim:updateAnimation(time)
	end
	function view:isHitAnimationPlaying()
		-- fca does not support animation mix
		return false
	end
	function view:playHitAnimation()
		-- fca does not support animation mix
	end
	function view:stopHitAnimation()
		-- fca does not support animation mix
	end
	function view:resetActorWithAnimation(animation, loop)
		fcaAnim:setAction(animation, loop)
	end
	function view:playAnimation(animation, loop)
		fcaAnim:setAction(animation, loop)
	end
	function view:appendAnimation(animation, loop)
		fcaAnim:appendAction(animation, loop)
	end
	function view:getAnimationScale()
		return fcaAnim:getAnimationScale()
	end
	function view:setAnimationScale(animationScale)
		fcaAnim:setAnimationScale(animationScale)
	end
	function view:getAnimationScaleOriginal()
		return 1
	end
	function view:setAnimationScaleOriginal()
		-- todo
	end
	function view:pauseAnimation()
		fcaAnim:pauseAction()
	end
	function view:resumeAnimation()
		fcaAnim:resumeAction()
	end
	function view:stopAnimation()
		fcaAnim:stopAction()
	end
	function view:canPlayAnimation(animation)
		return fcaAnim:canPlayAction(animation)
	end
	function view:getAnimationFrameCount(animation)
		return fcaAnim:getActionFrameCount(animation)
	end
	-- event
	function view:connectAnimationEventSignal(handle)
		fcaAnim:setAnimationEvent(function(evt)
			if evt.t == 4 then
				handle(SP_ANIMATION_END, 0, evt.a, 0)
				handle(SP_ANIMATION_COMPLETE, 0, evt.a, 0)
			elseif evt.t == 5 then
				handle(SP_ANIMATION_START, 0, evt.a, 0)
			end
		end)
	end
	function view:connectAnimationUpdateEventSignal(handle)
		-- todo
	end
	function view:disconnectAnimationEventSignal()
		fcaAnim:setAnimationEvent(nil)
	end
	function view:disconnectAnimationUpdateEventSignal()
		-- todo
	end
	-- bone & slot
	function view:attachNodeToBone(boneName, node, isBackSide, isScaleWithActor)
		fcaAnim:attachNodeToBone(boneName, node, isBackSide, isScaleWithActor)
	end
	function view:detachNodeToBone(node)
		fcaAnim:detachNodeToBone(node)
	end
	function view:removeReplaceSkeleton(sourceBoneName)
		-- todo
	end
	function view:replaceSlotWithFile()
		-- todo
	end
	function view:replaceSlotWithSkeletonAnimation3()
		-- todo
	end
	function view:getBonePosition(boneName)
		return fcaAnim:getBonePosition(boneName)
	end
	function view:getRootBonePosition()
		return {x = fcaRoot:getPositionX(), y = fcaRoot:getPositionY()}
	end
	function view:setRootBonePosition(p)
		fcaRoot:setPosition(ccp(p.x, p.y))
	end
	function view:getParentBoneName(boneName)
		return boneName
	end
	function view:isBoneExist(boneName)
		return fcaAnim:isBoneExist(boneName)
	end
	-- init & reset
	function view:reloadWithFile(fileName)
		-- fca has no need to reload
	end
	-- effects
	function view:addCustomNode(node)
		-- todo
	end
	function view:getRenderTextureSprite()
		-- todo
		return fcaNode
	end
	function view:setScissorEnabled()
		-- todo
	end
	function view:setScissorRects()
		-- todo
	end
	function view:setScissorBlendFunc()
		-- todo
	end
	function view:setScissorColor()
		-- todo
	end
	function view:setScissorOpacity()
		-- todo
	end
	local fcaNode_functions = {}
	local __index = function(t,k)
		local func = fcaNode_functions[k]
		if func == nil and fcaNode[k] then
			func = function(_, ...)
				return fcaNode[k](fcaNode, ...)
			end
			fcaNode_functions[k] = func
		end
		return func
	end
	setmetatable(view, {__index = __index})
	return view
end

return
{
	createFcaSkeletonView = createFcaSkeletonView,
}






















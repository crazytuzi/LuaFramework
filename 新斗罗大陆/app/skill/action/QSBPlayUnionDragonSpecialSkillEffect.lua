local QSBAction = import(".QSBAction")
local QSBPlayUnionDragonSpecialSkillEffect = class("QSBPlayUnionDragonSpecialSkillEffect", QSBAction)
local QSkeletonViewController
if not IsServerSide then
	QSkeletonViewController = import("...controllers.QSkeletonViewController")
end

function QSBPlayUnionDragonSpecialSkillEffect:_execute(dt)
	if not IsServerSide then
		local actor = self._attacker
		local dragonId = app.battle:getUnionDragonWarBossId()
		local cfg = QStaticDatabase:sharedDatabase():getUnionDragonConfigById(dragonId)
		local view = app.scene:getActorViewFromModel(actor)
		local fca_file = cfg.fca
		if view and fca_file and QSkeletonViewController then
			local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
			view._backSoulAnim = skeletonViewController:createSkeletonActorWithFile(fca_file, false)
	        view._backSoulAnim:setVisible(false)
	        view._skeletonActor:attachNodeToBone(nil, view._backSoulAnim, true, true)
	        view._backSoulAnim:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
	            if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
	                view._backSoulAnim:disconnectAnimationEventSignal()
	                view._skeletonActor:detachNodeToBone(view._backSoulAnim)
                	skeletonViewController:removeSkeletonActor(view._backSoulAnim)
	                view._backSoulAnim = nil
	            end
	        end)
	        if view._backSoulAnim:canPlayAnimation("variant") then
	            view._backSoulAnim:setVisible(true)
	            view._backSoulAnim:playAnimation("variant", false)
	        else
	            view._backSoulAnim:disconnectAnimationEventSignal()
	            view._skeletonActor:detachNodeToBone(view._backSoulAnim)
            	skeletonViewController:removeSkeletonActor(view._backSoulAnim)
	            view._backSoulAnim = nil
	        end
		end
	end
    self:finished()
end

return QSBPlayUnionDragonSpecialSkillEffect
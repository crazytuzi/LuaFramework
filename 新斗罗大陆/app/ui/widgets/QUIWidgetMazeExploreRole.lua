




local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMazeExploreRole = class("QUIWidgetMazeExploreRole", QUIWidget)
local QUIMazeExploreMapController = import("..controllers.QUIMazeExploreMapController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QMazeExplore = import(".QMazeExplore")

function QUIWidgetMazeExploreRole:ctor(options)
	local ccbFile = "ccb/Widget_MazeExplore_Grid.ccbi"
	local callbacks = {
		{ccbCallbackName = "onTriggerTouchBox", callback = handler(self, self._onTriggerTouchBox)},
		-- {ccbCallbackName = "onTriggerBoxSilver", callback = handler(self, self._onTriggerBoxSilver)},
		-- {ccbCallbackName = "onTriggerBoxGold", callback = handler(self, self._onTriggerBoxGold)},
	}
	QUIWidgetMazeExploreRole.super.ctor(self, ccbFile, callbacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._isWalkAction = false
end

function QUIWidgetMazeExploreRole:onEnter()
	QUIWidgetMazeExploreRole.super.onEnter(self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QMazeExplore.FALL_ROCK_FAIL , self._showFallingRocksAction, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QMazeExplore.GRID_EVENT_USE_PORTAL , self._showPortalAction, self)
end

function QUIWidgetMazeExploreRole:onExit()
	QUIWidgetMazeExploreRole.super.onExit(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QMazeExplore.FALL_ROCK_FAIL , self._showFallingRocksAction, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QMazeExplore.GRID_EVENT_USE_PORTAL , self._showPortalAction, self)
	
end

function QUIWidgetMazeExploreRole:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_grid, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_grid, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_avatar, self._glLayerIndex)
end

function QUIWidgetMazeExploreRole:setInfo(info)
	self._info = info
	self:_creatActor()
end

function QUIWidgetMazeExploreRole:_creatActor()
	self._avatar = QUIWidgetActorDisplay.new(remote.user.defaultActorId,{heroInfo = {skinId = remote.user.defaultSkinId}})
	self._ccbOwner.node_avatar:addChild(self._avatar)
	-- self._avatar:setAutoStand(false)
	self._ccbOwner.node_avatar:setScale(0.8)
	-- self._fcaAnimation = QUIWidgetFcaAnimation.new("fca/yijiantouzhi_1", "res")
	-- self._fcaAnimation:playAnimation("animation", true)
	-- self._fcaAnimation:setPositionY(160)
	-- self._avatar:addChild(self._fcaAnimation)	
	-- self._fcaAnimation:setVisible(false)
	-- self._fcaAnimation:setScaleX(-math.abs(self._avatar:getScaleX()))
	self._avatar:setScaleX(-math.abs(self._avatar:getScaleX()))
end

function QUIWidgetMazeExploreRole:setActorWalk(left)
	if not self._isWalkAction then
		self._isWalkAction = true
		self._avatar:getActor():playAnimation(ANIMATION.WALK, true)
	end

	if left then
		self._avatar:setScaleX(math.abs(self._avatar:getScaleX()))
		-- self._fcaAnimation:setScaleX(math.abs(self._avatar:getScaleX()))	
	else
		self._avatar:setScaleX(-math.abs(self._avatar:getScaleX()))
		-- self._fcaAnimation:setScaleX(-math.abs(self._avatar:getScaleX()))
	end
end

function QUIWidgetMazeExploreRole:stopActorWalk()
	self._avatar:getActor():resetActor()
	self._isWalkAction = false
end

function QUIWidgetMazeExploreRole:_showFallingRocksAction(e)

	local isHurt = not e.isTrue
	if isHurt then
		local effect = QResPath("mazeExplore_FallingRocks_Role_action")
		local  fcaAnimation = QUIWidgetFcaAnimation.new(effect, "res")
		fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setPositionY(120)
		self._ccbOwner.node_avatar:addChild(fcaAnimation)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
		end)


		effect = QResPath("mazeExplore_FallingRocks_Hurt_Face_action")
		local  fcaAnimation2 = QUIWidgetFcaAnimation.new(effect, "res")
		fcaAnimation2:playAnimation("animation", false)
		fcaAnimation2:setPositionY(130)
		fcaAnimation2:setScale(0.6)
		self._ccbOwner.node_avatar:addChild(fcaAnimation2)
		fcaAnimation2:setEndCallback(function( )
			fcaAnimation2:removeFromParent()
		end)

	else

	  	local arr = CCArray:create()
	    arr:addObject(CCMoveBy:create(0.2, ccp(90, 0)))
	    arr:addObject(CCCallFunc:create(function()
			local effect = QResPath("mazeExplore_FallingRocks_Miss_Face_action")
			local  fcaAnimation = QUIWidgetFcaAnimation.new(effect, "res")
			fcaAnimation:setScale(0.6)
			fcaAnimation:setPositionY(130)
			fcaAnimation:playAnimation("animation", false)
			self._ccbOwner.node_avatar:addChild(fcaAnimation)
			fcaAnimation:setEndCallback(function( )
				fcaAnimation:removeFromParent()
			end)
	    end))
	    arr:addObject(CCDelayTime:create(0.2))
	    arr:addObject(CCMoveBy:create(0.2, ccp(-90, 0)))
	    self._ccbOwner.node_grid:runAction(CCSequence:create(arr))
	end


end

function QUIWidgetMazeExploreRole:_showPortalAction()
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0.2,0)

  	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCCallFunc:create(function()
 		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0.1,255) 
    end))
    self._ccbOwner.node_grid:runAction(CCSequence:create(arr))

end

return QUIWidgetMazeExploreRole
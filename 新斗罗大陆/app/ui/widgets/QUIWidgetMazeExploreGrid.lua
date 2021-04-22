



local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMazeExploreGrid = class("QUIWidgetMazeExploreGrid", QUIWidget)
local QUIMazeExploreMapController = import("..controllers.QUIMazeExploreMapController")
local QMazeExplore = import(".QMazeExplore")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")


function QUIWidgetMazeExploreGrid:ctor(options)
	local ccbFile = "ccb/Widget_MazeExplore_Grid.ccbi"
	local callbacks = {
		-- {ccbCallbackName = "onTriggerTouchBox", callback = handler(self, self._onTriggerTouchBox)},
		-- {ccbCallbackName = "onTriggerBoxSilver", callback = handler(self, self._onTriggerBoxSilver)},
		-- {ccbCallbackName = "onTriggerBoxGold", callback = handler(self, self._onTriggerBoxGold)},
	}
	QUIWidgetMazeExploreGrid.super.ctor(self, ccbFile, callbacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._ccbOwner.sp_grid:setVisible(false)

    self._info  = nil
    self._fcaAnimation = nil
    self._removeAction = false
    self._endCallback = nil

    self._eventNameOrHandle = ""
    self._eventHandle = nil

end

function QUIWidgetMazeExploreGrid:onEnter()
	QUIWidgetMazeExploreGrid.super.onEnter(self)
end

function QUIWidgetMazeExploreGrid:onExit()
	QUIWidgetMazeExploreGrid.super.onExit(self)
	self:removeNotification()
    self._info  = nil

end

function QUIWidgetMazeExploreGrid:removeNotification()
	if self._eventHandle ~= nil and self._eventNameOrHandle ~= "" then
		QNotificationCenter.sharedNotificationCenter():removeEventListener(self._eventNameOrHandle , self._eventHandle, self)
		self._eventNameOrHandle = ""
    	self._eventHandle = nil
	end
end

function QUIWidgetMazeExploreGrid:playDisappearActionAndRemoveSelf()
	if self._removeAction then
		return
	end
	self._removeAction = true
	local dur = 0.2

	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0.2,0)

  	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(dur))
    arr:addObject(CCCallFunc:create(function()
 		self:removeFromParent()    
    end))
    self._ccbOwner.node_grid:runAction(CCSequence:create(arr))

end


function QUIWidgetMazeExploreGrid:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_grid, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_grid, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_avatar, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_gridnum, self._glLayerIndex)
end

function QUIWidgetMazeExploreGrid:resetAll()

end

function QUIWidgetMazeExploreGrid:removeNpc(e)
	local res = QResPath("mazeExplore_grid_sp")[1]
	if self._info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
		res = QResPath("mazeExplore_grid_sp")[2]
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_grid, res)
	self:removeNotification()
end


function QUIWidgetMazeExploreGrid:appearAction(e)
	self:setVisible(true)
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0, 0  )
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0.5, 255  )
	self:removeNotification()

end

function QUIWidgetMazeExploreGrid:_changeBossAvatar(e)
	local visible = e.visible
	if visible then
		self._ccbOwner.node_avatar:setVisible(true)
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_avatar ,0.5, 255  )
	else
		self._ccbOwner.node_avatar:setVisible(true)
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_avatar ,0.5, 0  )
	end
end


function QUIWidgetMazeExploreGrid:setInfo(info, isInit)
	self:initGLLayer()
	self._isFirst = self._info == nil

	self._info = info
	self._ccbOwner.sp_grid:setVisible(true)
	local position = ccp(self._info.gridX * QUIMazeExploreMapController.PER_GRID_WIDTH , self._info.gridY * QUIMazeExploreMapController.PER_GRID_HEIGHT )
	self:setPosition(position)

	local res = QResPath("mazeExplore_grid_sp")[1]
	if info.isNpc then
		self:removeNotification()
		self._eventNameOrHandle = QUIMazeExploreMapController.PACE_UPDATE_REMOVE
		self._eventHandle = self.removeNpc
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)
		res = QResPath("mazeExplore_grid_sp")[10]		
	elseif info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
		res = QResPath("mazeExplore_grid_sp")[2]
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_grid, res)
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0, 0  )
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0.5, 255  )

	if QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE == tonumber(self._info.config.event_type) 
		and info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE and self._isFirst and not isInit then
		self:setVisible(false)
		self:removeNotification()
		self._eventNameOrHandle = QUIMazeExploreMapController.MAP_GRID_EVENT_SECRET_BE_SHOW
		self._eventHandle = self.appearAction
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)
	end

	if QUIMazeExploreMapController.NEED_OPEN_GRID_TEXT ~= 0 then
		self._ccbOwner.tf_gridnum:setVisible(true)
		self._ccbOwner.tf_gridnum:setString(self._info.id)
	end
end

function QUIWidgetMazeExploreGrid:setEventInfo(info, isInit)
	self:initGLLayer()
	self._isFirst = self._info == nil
	self._info = info
	if self._isFirst then
		self:_initEventInfo()
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0, 0  )
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_grid ,0.5, 255  )
	else
		self:_refreshEventInfo(self._info.config)
	end
end

function QUIWidgetMazeExploreGrid:_initEventInfo()
	local position = ccp(self._info.gridX * QUIMazeExploreMapController.PER_GRID_WIDTH , self._info.gridY * QUIMazeExploreMapController.PER_GRID_HEIGHT )
	self:setPosition(position)

	self:handleGridEventTypeByConfig(self._info.config)
end

function QUIWidgetMazeExploreGrid:playAction(actonRes)

end

function QUIWidgetMazeExploreGrid:displayIcon(event_type)
	self._ccbOwner.sp_grid:setVisible(true)
	local res , pos = self:getIconPathByEventType(event_type)

	if event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE then
		if self._info.isClose then
			res , pos = self:getIconPathByEventType(event_type , false)
		else
			res , pos = self:getIconPathByEventType(event_type , true)
		end
	elseif event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF then

		if self._info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
			local parma = string.split(self._info.config.parameter or "", ";")
			local initIsClose = tonumber(parma[1]) ~= 1 --初始状态1升2降
			res , pos = self:getIconPathByEventType(event_type , initIsClose)

		elseif self._info.state == QUIMazeExploreMapController.GRID_TYPE.DEFAULT then
			res , pos = self:getIconPathByEventType(event_type , true)
		else
			res , pos = self:getIconPathByEventType(event_type , false)
		end		
	else
		res , pos = self:getIconPathByEventType(event_type )
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_grid,res)
	self._ccbOwner.sp_grid:setPosition(pos)

end

function QUIWidgetMazeExploreGrid:getIconPathByEventType(event_type ,bParam)

	-- if self._info.config.pic and QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE ~= event_type then
	-- 	if QCheckFileIsExist(self._info.config.pic) then
	-- 		return self._info.config.pic , ccp(0,0)
	-- 	end
	-- end

	local res =   QResPath("mazeExplore_gridSprite")[1]
	local pos = ccp(0,30)

    if  QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL == event_type then
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FIXAWARDS == event_type then
    	if self._info.config.key_count then
    		res = QResPath("mazeExplore_gridSprite")[12]
    	else
       		res = QResPath("mazeExplore_gridSprite")[11]
    	end
		pos = ccp(0,17)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_RANDAWARDS == event_type then
        res = QResPath("mazeExplore_gridSprite")[11]
		pos = ccp(0,17)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_EVENTAWARDS == event_type then
        res = QResPath("mazeExplore_gridSprite")[25]
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_CHESTAWARDS == event_type then
        res = QResPath("mazeExplore_gridSprite")[10]
		pos = ccp(0,15)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ACTORSPECK == event_type then
        res = QResPath("mazeExplore_gridSprite")[16]
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TXTSPECK == event_type then
        res = QResPath("mazeExplore_gridSprite")[2]
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL == event_type then
        res = QResPath("mazeExplore_gridSprite")[15]
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_ONOFF == event_type then
		res = QResPath("mazeExplore_gridSprite")[7]
		pos = ccp(0,25)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE == event_type then
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE == event_type then
        res = QResPath("mazeExplore_gridSprite")[5]
		pos = ccp(-1,35)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ROCKS == event_type then
        -- res = QResPath("mazeExplore_gridSprite")[19]
		res = QResPath("mazeExplore_gridSprite")[24]
		if self._info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
			res = QResPath("mazeExplore_gridSprite")[23]
		end
		pos = ccp(0,0)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS == event_type then
        -- res = QResPath("mazeExplore_gridSprite")[13]
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE == event_type then
        res = self._info.config.pic
		pos = ccp(0,15)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE == event_type then
    	if bParam then
        	res = QResPath("mazeExplore_gridSprite")[3]	--off
        	pos = ccp(0,0)
    	else
        	res = QResPath("mazeExplore_gridSprite")[4] -- on
        	pos = ccp(0,25)
    	end
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF == event_type then
    	if bParam then
			res = QResPath("mazeExplore_gridSprite")[7]	--off
        	pos = ccp(0,25)
    	else
        	res = QResPath("mazeExplore_gridSprite")[6]	--on
        	pos = ccp(0,8)
    	end
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB == event_type then
        res = QResPath("mazeExplore_gridSprite")[9]
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME == event_type then
        res = QResPath("mazeExplore_gridSprite")[1]
		pos = ccp(0,-3)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_DICE == event_type then
        res = QResPath("mazeExplore_gridSprite")[17]
		pos = ccp(0,7)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS == event_type then
		res = QResPath("mazeExplore_gridSprite")[22]
		if self._info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
			res = QResPath("mazeExplore_gridSprite")[21]
		end
		pos = ccp(-8,5)
    elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT == event_type then
        res = QResPath("mazeExplore_gridSprite")[18]
		pos = ccp(0,30)
    end
    -- print("event_type"..event_type)
    return res , pos
end




function QUIWidgetMazeExploreGrid:playIconAction(actType)
	self._ccbOwner.sp_grid:stopAllActions()
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(1, ccp(0,50)))
    array:addObject(CCMoveTo:create(1,  ccp(0,20)))
	self._ccbOwner.sp_grid:runAction(CCRepeatForever:create(CCSequence:create(array)))
end

function QUIWidgetMazeExploreGrid:checkReversal()
	local number = tonumber(self._info.gridX) + tonumber(self._info.gridY) 
	if number % 2 == 0 then
		self._ccbOwner.sp_grid:setScaleX(1)
	else	
		self._ccbOwner.sp_grid:setScaleX(-1)
	end
end

-- ------------------------------event---------------------------------------------
-- --格子事件
-- QMazeExplore.ENUMERATE_GRID_EVENT = {	
-- 	GRID_EVENT_NORMAL = 0,                       	--普通格子
-- 	GRID_EVENT_FIXAWARDS = 1,                    	--固定奖励			关=1 无效=3						图片
-- 	GRID_EVENT_RANDAWARDS = 2,                   	--随机奖励			关=1 无效=3						图片
-- 	GRID_EVENT_EVENTAWARDS = 3,                  	--事件奖励			关=1 无效=3						动画 图片飘动
-- 	GRID_EVENT_CHESTAWARDS = 4,						--宝箱奖励			关=1 无效=3						图片
-- 	GRID_EVENT_ACTORSPECK = 5,						--半身像对话			关=1 无效=3						动画 图片飘动
-- 	GRID_EVENT_TXTSPECK	= 6,						--文本剧情			关=1 无效=3						动画 图片飘动
-- 	GRID_EVENT_PORTAL = 7,							--传送门				关=1 							动效
-- 	GRID_EVENT_SECRET_ONOFF = 8,					--暗格开/关			关=1 无效=3						图片  触发动画 消失
-- 	GRID_EVENT_SECRET_BE = 9,						--暗格对象			无效 = 3							
-- 	GRID_EVENT_LIGHTHOUSE = 10,						--灯塔				关 = 1 开 = 2 无效 = 3			图片（关闭）+ 动效（开启）消失（无效）
-- 	GRID_EVENT_ROCKS = 11,							--落石				关 = 1（杀端时上来重新触发） 无效=3	无图 触发时有动效
-- 	GRID_EVENT_SOLDIERS = 12,						--追兵												avatar动画（walk+stand）	
-- 	GRID_EVENT_REMOVE = 13,							--解除				关 = 1 开 = 2					图片  触发动画 消失 复用暗格							
-- 	GRID_EVENT_LIFTS_ONOFF = 14,					--升降台升/降			关 = 1 开 = 2					图片  触发动画 消失 复用暗格 不消失
-- 	GRID_EVENT_LIFTS_BE = 15,						--升降台对象											图片  2张	
-- 	GRID_EVENT_TOSTAB = 16,							--地刺               失效前端判断 关 = 1				动效
-- 	GRID_EVENT_FINGERGAME = 17,						--猜拳				关 = 1 无效 = 3					图片  触发动画 消失
-- 	GRID_EVENT_DICE = 18,							--掷骰子				关 = 1 无效 = 3					图片  触发动画 消失
-- 	GRID_EVENT_BOSS = 19,							--BOSS				关 = 1 							图片
-- }
-- --------------------------------------------------------------------------------

--gird type
function QUIWidgetMazeExploreGrid:handleGridEventTypeByConfig(config)

	local event_type = tonumber(config.event_type)
	if	QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FIXAWARDS == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_RANDAWARDS == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_EVENTAWARDS == event_type then
		self:displayIcon(event_type)
		self:playIconAction()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_CHESTAWARDS == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ACTORSPECK == event_type then
		self:displayIcon(event_type)
		self:playIconAction()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TXTSPECK == event_type then
		self:displayIcon(event_type)
		self:playIconAction()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL == event_type then
		self:_showPortalVisible()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_ONOFF == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE == event_type then
		self:_showLighthouse()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ROCKS == event_type then
		self:displayIcon(event_type)

		self._eventNameOrHandle = QMazeExplore.FALL_ROCK_FAIL
		self._eventHandle = self._showFallingRocksAction
		-- self:displayIcon(event_type)
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)
		-- self._endCallback =  CCCallFunc:create(function () 
		-- 	QNotificationCenter.sharedNotificationCenter():removeEventListener(QMazeExplore.FALL_ROCK_FAIL , self._showFallingRocksAction, self)
		-- end)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS == event_type then

		self._eventNameOrHandle = QUIMazeExploreMapController.PACE_UPDATE
		self._eventHandle = self._onHandleSoldierPaceUpdate
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)
		self:_onHandleSoldierPaceUpdate({paceCount = self._info.paceCount})
		
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE == event_type then
		self:displayIcon(event_type)
		self:checkReversal()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB == event_type then
		self._eventNameOrHandle = QUIMazeExploreMapController.TIMER_UPDATE
		self._eventHandle = self._onHandleTostabTimerCountDown
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)
		self:_createTostabAction()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_DICE == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS == event_type then
		self:displayIcon(event_type)
		self:_showBossAvatar()
		self._eventNameOrHandle = QUIMazeExploreMapController.MAP_GRID_EVENT_CHANGE_BOSS_VISIBLE
		self._eventHandle = self._changeBossAvatar
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)
		
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT == event_type then
		self:displayIcon(event_type)
		self:checkReversal()
	end
end


function QUIWidgetMazeExploreGrid:_refreshEventInfo(config)

	local event_type = tonumber(config.event_type)

	if	QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FIXAWARDS == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_RANDAWARDS == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_EVENTAWARDS == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_CHESTAWARDS == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ACTORSPECK == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TXTSPECK == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL == event_type then
		self:_showPortalVisible()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_ONOFF == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE == event_type then
		self:_showLighthouse()
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ROCKS == event_type then
		self:displayIcon(event_type)
		if self._info.state == QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT then
			self:removeNotification()
		end
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF == event_type then
		self:displayIcon(event_type)
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_DICE == event_type then
	elseif QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS == event_type then
		self:displayIcon(event_type)
	end
end

function QUIWidgetMazeExploreGrid:_showPortalVisible()
	local visible = self._info and self._info.state and self._info.state ~= QUIMazeExploreMapController.GRID_TYPE.NULL_EVENT
	print("_showPortalVisible")
	if visible or true then
		self._ccbOwner.sp_grid:setVisible(false)
		if not self._fcaAnimation then
			local effect = QResPath("mazeExplore_Portal_action")
			self._fcaAnimation = QUIWidgetFcaAnimation.new(effect, "res")
			self._fcaAnimation:playAnimation("animation", true)
			self._fcaAnimation:setPositionY(20)
			self._ccbOwner.node_avatar:addChild(self._fcaAnimation)
			self._ccbOwner.node_avatar:setVisible(true)	
		end
	else
		if self._fcaAnimation then
			self._ccbOwner.node_avatar:removeAllChildren()
			self._ccbOwner.node_avatar:setVisible(false)
		end
	end
end


function QUIWidgetMazeExploreGrid:_showBossAvatar()
	local charaterId = self._info.config.pic or  1001
	if not self._avatar then
		self._avatar = QUIWidgetActorDisplay.new(charaterId)
		self._ccbOwner.node_avatar:addChild(self._avatar)
		self._avatar:setScale(0.55)
	end
	self._ccbOwner.node_avatar:setPosition(ccp(120,0))

	if not self._starNode  then
		self._starNode = CCNode:create()
		self._ccbOwner.node_avatar:addChild(self._starNode)
		self._starNode:setPositionY(150)
		self._starNode:setScale(0.8)
	end
	self._starNode:removeAllChildren()
	local star = self._info.Star or 0
	for i=1,3 do
		local res = QResPath("sp_star_res")[1]
		if star >= i then
			res = QResPath("sp_star_res")[2]
		end
		local spStar =  CCSprite:create()
		QSetDisplayFrameByPath(spStar, res)
		spStar:setPositionX( (i - 2) * 30)
		spStar:setPositionY(i == 2 and 10 or 0)
		self._starNode:addChild(spStar)
	end
	if  self._info.isOnBoss then
		self._ccbOwner.node_avatar:setVisible(true)
	else
		self._ccbOwner.node_avatar:setVisible(false)
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_avatar ,0, 0  )
	end

end



function QUIWidgetMazeExploreGrid:_showLighthouse()
	print("_showLighthouse")
	self._ccbOwner.node_avatar:removeAllChildren()
	self._ccbOwner.node_avatar:setVisible(false)
	if self._info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE or self._info.state == QUIMazeExploreMapController.GRID_TYPE.DEFAULT  then
		self:displayIcon(QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE)
	else
		self._ccbOwner.sp_grid:setVisible(false)
		local effect = QResPath("mazeExplore_Lighthouse_action")
		self._fcaAnimation = QUIWidgetFcaAnimation.new(effect, "res")
		self._fcaAnimation:playAnimation("animation", true)
		self._fcaAnimation:setScale(0.24)
		self._ccbOwner.node_avatar:addChild(self._fcaAnimation)
		self._ccbOwner.node_avatar:setVisible(true)	
	end
end

--播放地格落石动画
function QUIWidgetMazeExploreGrid:_showFallingRocksAction(e)
	local id =  e.id
	if id ~= self._info.id then return end

	local isHurt =  not e.isTrue
	if not isHurt then
		-- self._removeAction = true
		local effect = QResPath("mazeExplore_FallingRocks_Grid_action")
		local  fcaAnimation = QUIWidgetFcaAnimation.new(effect, "res")
		fcaAnimation:playAnimation("animation", false)
		self._ccbOwner.node_avatar:addChild(fcaAnimation)
		fcaAnimation:setEndCallback(function( )
	 		if self._ccbOwner then
				fcaAnimation:removeFromParent()
				-- self._removeAction = false
				-- self:playDisappearActionAndRemoveSelf()
			end
		end)
	end

end

--地刺类陷阱需要根据时间轴来做表现
function QUIWidgetMazeExploreGrid:_onHandleTostabTimerCountDown(event)
	-- print("_onHandleTostabTimerCountDown")
	local timer = tonumber(event.timer)
	if not self._info or not self._info.config then return end

	local parameter = self._info.config.parameter
	local movementParts = string.split(parameter, ",")
	local timerRemain = timer - tonumber(movementParts[1]) or 0
	local isOn = (timerRemain %  (tonumber(movementParts[2]) or 2 )) == 0
	if isOn then
		--播放刺出动画
		self:_playTostabAction()
	end
end


function QUIWidgetMazeExploreGrid:_createTostabAction()
	if self._fcaAnimation == nil then
		local effect = QResPath("mazeExplore_Tostab_action")
		self._fcaAnimation = QUIWidgetFcaAnimation.new(effect, "res")
		self._fcaAnimation:setScale(0.25)
		self._fcaAnimation:setPositionY(2)
		self._fcaAnimation:setPositionX(5)
		self._ccbOwner.node_avatar:addChild(self._fcaAnimation)
		self._ccbOwner.node_avatar:setVisible(true)	
	end
	self._fcaAnimation:setVisible(true)
	self._fcaAnimation:playAnimation("animation1", false)
end 

--刺出
function QUIWidgetMazeExploreGrid:_playTostabAction()
	self._ccbOwner.sp_grid:setVisible(false)
	if self._fcaAnimation == nil then
		local effect = QResPath("mazeExplore_Tostab_action")
		self._fcaAnimation = QUIWidgetFcaAnimation.new(effect, "res")
		self._fcaAnimation:setScale(0.25)
		self._fcaAnimation:setPositionY(2)
		self._fcaAnimation:setPositionX(5)
		self._ccbOwner.node_avatar:addChild(self._fcaAnimation)
		self._ccbOwner.node_avatar:setVisible(true)	
	end
	self._fcaAnimation:setVisible(true)
	self._fcaAnimation:playAnimation("animation", false)
	self._fcaAnimation:setEndCallback(function( )
 		if self._ccbOwner then
 			self:_playTostabAction2()
 		end
	end)

end

--缩回
function QUIWidgetMazeExploreGrid:_playTostabAction2()

	-- self._ccbOwner.sp_grid:setVisible(true)
	-- local res = QResPath("mazeExplore_gridSprite")[9]
	-- self._ccbOwner.sp_grid:setPositionY(3)
	-- QSetDisplayFrameByPath(self._ccbOwner.sp_grid, res)

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.05))
	array:addObject(CCCallFunc:create(function()
 		if self._ccbOwner then
			self._ccbOwner.sp_grid:setVisible(false)
			self._fcaAnimation:playAnimation("animation1", false)
			self._fcaAnimation:setEndCallback(function( )
 			-- 	if self:safeCheck() then
				-- 	self._ccbOwner.sp_grid:setVisible(true)
				-- 	local res = QResPath("mazeExplore_gridSprite")[8]
				-- 	self._ccbOwner.sp_grid:setPositionY(3)
				-- 	QSetDisplayFrameByPath(self._ccbOwner.sp_grid, res)
				-- end
			end)
		end
	end))
	self._ccbOwner.node_avatar:stopAllActions()
	self._ccbOwner.node_avatar:runAction(CCSequence:create(array))
end


--步长刷新时的动画
function QUIWidgetMazeExploreGrid:_onHandleSoldierPaceUpdate(event)
	local paceCount = tonumber(event.paceCount)
	if not self._info or not self._info.config then return end
	if paceCount == -1 or not self._info.isNpc then
		self:resetSoldierMoveAction()
		self:removeNotification()
		return
	end 
	local isAction = false
	local parameter = self._info.config.parameter
	local movementParts = string.split(parameter, ";")
	for k,v in pairs(movementParts or {}) do
		local moveInfo =  string.split(v, ",")
		if #moveInfo >= 3 then
			local interval = tonumber(moveInfo[1])
			local key = tonumber(moveInfo[2])
			local targetGridId = tonumber(moveInfo[3])
			if (paceCount % interval) == key  then
				self:playSoldierMoveAction(self._info.config,targetGridId)
				isAction = true
			end
		end
	end

	if not isAction then
		self:resetSoldierMoveAction()
	end
end

function QUIWidgetMazeExploreGrid:playSoldierMoveAction(config , targetGridId )
	if not self._mazeExploreDataHandle then
		self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()
	end
	-- print("targetGridId	"..targetGridId)
	local targetConfig = self._mazeExploreDataHandle:getMazeExploreConfigsById(targetGridId)
	local coord = string.split(targetConfig.coordinate, ",")
	if not self._avatar then
		-- self._avatar = QUIWidgetActorDisplay.new(1001)
		-- self._avatar:setAutoStand(false)

    	self._avatar = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("zhuibing", nil, false)
    	self._avatar:playAnimation(ANIMATION.STAND, true)
		-- self._avatar:setAutoStand(false)
		self._ccbOwner.node_avatar:addChild(self._avatar)
		self._ccbOwner.node_avatar:setScale(0.7)
	end
	self._avatar:setVisible(true)

	local offGridx =   coord[1] - self._info.gridX
	local offGridy =   coord[2] - self._info.gridY
	-- QPrintTable(coord)

	local position1 = ccp(offGridx * QUIMazeExploreMapController.PER_GRID_WIDTH /0.7, offGridy * QUIMazeExploreMapController.PER_GRID_HEIGHT /0.7)
	self._avatar:setPosition(position1)


	local isLeft = offGridx > 0
	if isLeft then
		self._avatar:setScaleX(math.abs(self._avatar:getScaleX()))
	else
		self._avatar:setScaleX(-math.abs(self._avatar:getScaleX()))
	end
	self._avatar:playAnimation(ANIMATION.WALK, true)
  	local arr = CCArray:create()
    arr:addObject(CCMoveTo:create(QUIMazeExploreMapController.MOVE_PACE_DUR, ccp(0,0)))
    -- arr:addObject(CCDelayTime:create(QUIMazeExploreMapController.MOVE_PACE_DUR))
    arr:addObject(CCCallFunc:create(function()
 		-- self._avatar:setPosition(ccp(0,0))
 		-- self._avatar:setVisible(false)
 		self._avatar:playAnimation(ANIMATION.STAND, true)
    end))
	self._avatar:stopAllActions()
	self._avatar:runAction(CCSequence:create(arr))

end

function QUIWidgetMazeExploreGrid:resetSoldierMoveAction( )
	if self._avatar then
		self._avatar:setVisible(false)
	end
end


return QUIWidgetMazeExploreGrid


local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMazeExploreLine = class("QUIWidgetMazeExploreLine", QUIWidget)
local QUIMazeExploreMapController = import("..controllers.QUIMazeExploreMapController")
local QNotificationCenter = import("..controllers.QNotificationCenter")


function QUIWidgetMazeExploreLine:ctor(options)
	local ccbFile = "ccb/Widget_MazeExplore_Line.ccbi"
	local callbacks = {
		-- {ccbCallbackName = "onTriggerTouchBox", callback = handler(self, self._onTriggerTouchBox)},
		-- {ccbCallbackName = "onTriggerBoxSilver", callback = handler(self, self._onTriggerBoxSilver)},
		-- {ccbCallbackName = "onTriggerBoxGold", callback = handler(self, self._onTriggerBoxGold)},
	}
	QUIWidgetMazeExploreLine.super.ctor(self, ccbFile, callbacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._eventNameOrHandle = ""
    self._eventHandle = nil

end

function QUIWidgetMazeExploreLine:onEnter()
	QUIWidgetMazeExploreLine.super.onEnter(self)

end

function QUIWidgetMazeExploreLine:onExit()
	QUIWidgetMazeExploreLine.super.onExit(self)
	self:removeNotification()
    self._info  = nil

end

function QUIWidgetMazeExploreLine:removeNotification()
	if self._eventHandle ~= nil and self._eventNameOrHandle ~= "" then
		QNotificationCenter.sharedNotificationCenter():removeEventListener(self._eventNameOrHandle , self._eventHandle, self)
		self._eventNameOrHandle = ""
    	self._eventHandle = nil
	end
end

function QUIWidgetMazeExploreLine:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_scale, self._glLayerIndex)
end


function QUIWidgetMazeExploreLine:removeNpc(e)
	local res = QResPath("mazeExplore_grid_sp")[3]
	if self._info.state == QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
		res = QResPath("mazeExplore_grid_sp")[4]
	end
	for i=1,4 do
		QSetDisplayFrameByPath(self._ccbOwner["sp_line_"..i], res)
	end
	self:removeNotification()
end


function QUIWidgetMazeExploreLine:appearAction(e)
	self:setVisible(true)
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_scale ,0, 0  )
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_scale ,0.5, 255  )
	self:removeNotification()
end

function QUIWidgetMazeExploreLine:setInfo(info ,scale , isInit)
	self._isFirst = self._info == nil
	self._info = info

	local number = tonumber(info.gridX) + tonumber(info.gridY) 
	if number % 2 == 0 then	--右上
		self._ccbOwner.node_scale:setScaleX(scale)
	else	--右下
		self._ccbOwner.node_scale:setScaleX(-scale)
	end
	self._ccbOwner.node_scale:setScaleY(scale)

	local position = ccp((self._info.gridX - 0.5) * QUIMazeExploreMapController.PER_GRID_WIDTH * scale, (self._info.gridY - 0.5) * QUIMazeExploreMapController.PER_GRID_HEIGHT* scale )
	self:setPosition(position)

	local res = QResPath("mazeExplore_grid_sp")[3]
	self._ccbOwner.sp_lock:setVisible(false)
	if info.state ==  QUIMazeExploreMapController.GRID_TYPE.VISIBLE then
		res = QResPath("mazeExplore_grid_sp")[4]
		if info.isLock then
			self._ccbOwner.sp_lock:setVisible(true)
		end
	elseif info.isNpc then
		self:removeNotification()
		self._eventNameOrHandle = QUIMazeExploreMapController.PACE_UPDATE_REMOVE
		self._eventHandle = self.removeNpc
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)

		res = QResPath("mazeExplore_grid_sp")[11]
	end

	for i=1,4 do
		QSetDisplayFrameByPath(self._ccbOwner["sp_line_"..i], res)
	end

	if self._isFirst and self._info.isSecret and not isInit then
		self:setVisible(false)
		self:removeNotification()
		self._eventNameOrHandle = QUIMazeExploreMapController.MAP_GRID_EVENT_SECRET_BE_SHOW
		self._eventHandle = self.appearAction
		QNotificationCenter.sharedNotificationCenter():addEventListener(self._eventNameOrHandle, self._eventHandle, self)
	end



	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_scale ,0, 0  )
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_scale ,0.5, 255  )
end

return QUIWidgetMazeExploreLine
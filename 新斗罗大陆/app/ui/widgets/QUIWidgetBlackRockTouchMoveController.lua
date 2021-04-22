-- @Author: liaoxianbo
-- @Date:   2019-08-12 11:17:16
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-26 12:26:20
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBlackRockTouchMoveController = class("QUIWidgetBlackRockTouchMoveController", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")

function QUIWidgetBlackRockTouchMoveController:ctor(options)
	QUIWidgetBlackRockTouchMoveController.super.ctor(self,nil,nil,options)
	if options == nil then
		return
	end
	self._ccbOwner = options.ccbOwner --设置传入节点
	self._maxSize = options.maxSize --设置最大的滑动区域
	self._maxNum = options.maxNum  --章节总量
	self._moveTbls = {}
	self._originMove = {name = "root", defaultPos = ccp(0,0), speedRateX = 1, speedRateY = 1}
	self._originMove.currentPos = self._originMove.defaultPos
	local index = 1
	while true do
		local node = self._ccbOwner["node_size_"..index]
		if node ~= nil then
			local isFind = false
			local moveNode = node:getParent()
			if moveNode ~= nil then
				for _,cfg in ipairs(self._moveTbls) do
					if cfg.node == moveNode then
						isFind = true
						break
					end
				end
				if isFind == false then
					local size = node:getContentSize()
					size.width = size.width - display.width
					local tbl = {}
					tbl.name = "node_size_"..index
					tbl.moveNode = moveNode
					tbl.defaultPos = ccp(moveNode:getPosition())
					if self._maxSize.width ~= 0 then
						tbl.speedRateX = size.width/self._maxSize.width
					else
						tbl.speedRateX = 0
					end
					if self._maxSize.height ~= 0 then
						tbl.speedRateY = size.height/self._maxSize.height
					else
						tbl.speedRateY = 0
					end
					table.insert(self._moveTbls, tbl)
				end
			end
		else
			break
		end
		index = index + 1
	end
	self._isMoveing = false
end

function QUIWidgetBlackRockTouchMoveController:onExit()
	print("QUIWidgetBlackRockTouchMoveController:onExit")
	QUIWidgetBlackRockTouchMoveController.super.onExit(self)
	self._touchLayer:removeAllEventListeners()
	self._touchLayer:disable()
	self._touchLayer:detach()
	self._touchLayer = nil
end

function QUIWidgetBlackRockTouchMoveController:onEnter()
	print("QUIWidgetBlackRockTouchMoveController:onEnter")
	QUIWidgetBlackRockTouchMoveController.super.onEnter(self)
	if self._touchLayer == nil then
		self:initGestureRecognizer()
	end
	self._touchLayer:enable()
	self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouch))
end

--停止所有的action移动
function QUIWidgetBlackRockTouchMoveController:stopAllAction()
	for _,v in ipairs(self._moveTbls) do
		if v.actionHandler ~= nil then
			v.moveNode:stopAction(v.actionHandler)
			v.actionHandler = nil
		end
	end
end

--重置当前位置
function QUIWidgetBlackRockTouchMoveController:resetCurrentPos()
	self._originMove.currentPos = self._originMove.defaultPos
	self:moveByOffset(ccp(0, 0))
end

--获取是否在移动
function QUIWidgetBlackRockTouchMoveController:getIsMoveing()
	return self._isMoveing == true
end

function QUIWidgetBlackRockTouchMoveController:initGestureRecognizer()
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self:getView(), display.width, display.height, 0, 0, handler(self, self._onTouch))
end

function QUIWidgetBlackRockTouchMoveController:_onTouch(event)
	if event.name == "began" then
		self:stopAllAction()
		self._startPosX = event.x
		self._startPosY = event.y
		return true
	elseif event.name == "moved" then
		if self._isMoveing ~= true and (math.abs(event.x - self._startPosX) > 10 or math.abs(event.y - self._startPosY) > 10) then
			self._isMoveing = true
		end
		self:moveByOffset(ccp(event.x -self._startPosX, event.y - self._startPosY))
	elseif event.name == "ended" or event.name == "cancelled" then
		scheduler.performWithDelayGlobal(function ()
			self._isMoveing = false
		end, 0)
		self:moveToPos(ccp(self._originMove.currentPos.x + event.x - self._startPosX, self._originMove.currentPos.y + event.y - self._startPosY))
	elseif event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:moveToPos(ccp(self._originMove.currentPos.x + event.distance.x, self._originMove.currentPos.y + event.distance.y), true)
	end
end

--移动到指定坐标
function QUIWidgetBlackRockTouchMoveController:moveToPos(pos, isAnimation)
	if self._originMove ~= nil then
		local offsetPosX = pos.x - self._originMove.defaultPos.x 
		local offsetPosY = pos.y - self._originMove.defaultPos.y
		offsetPosX, offsetPosY = self:_checkOffset(offsetPosX, offsetPosY)
		pos.x = self._originMove.defaultPos.x + offsetPosX
		pos.y = self._originMove.defaultPos.y + offsetPosY
		self._originMove.currentPos = pos
		for _,v in ipairs(self._moveTbls) do
			self:_moveChildNodeByOffset(v, ccp(offsetPosX, offsetPosY), isAnimation)
		end
	end
end

--[[
	移动指定的位移距离
	注意：本方法在移动结束之后不会保存移动的坐标
		比如：
			x本来是0
			移动了10个像素到10
			如果不使用moveToPos，则下次移动还是从0开始
]]
function QUIWidgetBlackRockTouchMoveController:moveByOffset(pos, isAnimation)
	if self._originMove ~= nil then
		local offsetPosX = self._originMove.currentPos.x + pos.x
		local offsetPosY = self._originMove.currentPos.y + pos.y
		offsetPosX, offsetPosY = self:_checkOffset(offsetPosX, offsetPosY)
		for _,v in ipairs(self._moveTbls) do
			self:_moveChildNodeByOffset(v, ccp(offsetPosX, offsetPosY), isAnimation)
		end
	end
end

function QUIWidgetBlackRockTouchMoveController:_checkOffset(offsetPosX, offsetPosY)
	local maxOffsetX = 0
	if self._maxSize.width < 350*self._maxNum then
		local showWidth = self._maxSize.width
		if display.width >= UI_VIEW_MIN_WIDTH then
			showWidth = display.width
		else
			showWidth = self._maxSize.width
		end
		maxOffsetX = -self._maxSize.width - math.abs(350*self._maxNum - showWidth) - 300
	else
		maxOffsetX = -350*self._maxNum
	end
	if offsetPosX < maxOffsetX then
		offsetPosX = maxOffsetX
	elseif offsetPosX > self._maxSize.width/2 then
		offsetPosX = self._maxSize.width/2
	end
	if offsetPosY < -self._maxSize.height/2 then
		offsetPosY = -self._maxSize.height/2
	elseif offsetPosY > self._maxSize.height/2 then
		offsetPosY = self._maxSize.height/2
	end
	return offsetPosX, offsetPosY
end

function QUIWidgetBlackRockTouchMoveController:_moveChildNodeByOffset(childConfig, offsetPos, isAnimation)
	if self._originMove == nil then return end
	local offsetPosX = offsetPos.x * childConfig.speedRateX
	local offsetPosY = offsetPos.y * childConfig.speedRateY
	if isAnimation then
		self:_contentRunAction(childConfig, offsetPosX + childConfig.defaultPos.x, offsetPosY + childConfig.defaultPos.y)
	else
		childConfig.moveNode:setPositionX(offsetPosX + childConfig.defaultPos.x)
		childConfig.moveNode:setPositionY(offsetPosY + childConfig.defaultPos.y)
	end
end

function QUIWidgetBlackRockTouchMoveController:_contentRunAction(childConfig, posX, posY)
	local actionArrayIn = CCArray:create()
	local curveMove = CCMoveTo:create(1.3, ccp(posX,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
	actionArrayIn:addObject(CCCallFunc:create(function ()
		if childConfig.actionHandler ~= nil then
			childConfig.moveNode:stopAction(childConfig.actionHandler)
			childConfig.actionHandler = nil
		end
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	childConfig.actionHandler = childConfig.moveNode:runAction(ccsequence)
end

--获取制定层的移动速率
function QUIWidgetBlackRockTouchMoveController:getSpeedRateByIndex(index)
	local indexSpeedRateX = 1
	local indexSpeedRateY = 1
	for _,cfg in ipairs(self._moveTbls) do
		if cfg.name == "node_size_"..index then
			indexSpeedRateX = cfg.speedRateX
			indexSpeedRateY = cfg.speedRateY
			break
		end
	end

	return indexSpeedRateX, indexSpeedRateY
end

return QUIWidgetBlackRockTouchMoveController


-- FileName : CircleTableView.lua
-- Author   : BZX
-- Date     : 2016-01-14
-- Purpose  : 转盘

CircleTableView = class("CircleTableView", function ()
	return CCLayer:create()
end)

local Direction = {
	Clockwise        = 	1,      	-- 顺时针
	CounterClockwise = 	2, 			-- 逆时针
}

--[[
	@des 	: 构造
	@param 	: 
	@return : 
--]]
function CircleTableView:ctor( ... )
	self._cells                        = {}
	self._eventHandler                 = nil
	self._viewSize                     = nil           -- 控件的尺寸
	self._averageRadian                = nil           -- 根据cell的数量平分的角度
	self._centerX                      = nil           -- 中点x坐标
	self._centerY                      = nil           -- 中点y坐标
	self._radian                       = 0             -- 当前的角度
	self._beganRadian                  = 0             -- 触摸开始的角度
	self._rotationDirection            = nil           -- 旋转的方向
	self._rotationDirectionRadianDelta = 0             -- 当前方向上移动角度delta
	self._rotationRadianDelta          = 0             -- 移动角度delta
	self._touchBeganRadian             = nil           -- 触摸开始的与x正半轴逆时针方向的夹角
	self._touchMovedRadian             = nil           -- 移动的角度
	self._lastRadianDelta              = 0             -- 上一次移动的角度
	self._fixedRadianOffset            = 0             -- 固定角度偏移  默认是x轴正方向
	self._changeDirectionRadianDelta   = math.pi/36    -- 改变方向的delta角度
	self._maxScale                     = 1             -- 最大缩放系数
	self._minScale                     = 1             -- 最小缩放系数
	self._rotationAction               = nil
end

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function CircleTableView:init( eventHandler, viewSize )
	self._eventHandler = eventHandler
	self:setViewSize(viewSize)
end

--[[
	@des 	: 创建
	@param 	: viewSize:控件尺寸
	@return : 
--]]
function CircleTableView:create( eventHandler, viewSize )
	local ret = CircleTableView.new()
	ret:init(eventHandler, viewSize)
	local onNodeEvent = function ( event )
		ret:onNodeEvent(event)
	end
	ret:registerScriptHandler(onNodeEvent)
	ret:reloadData()
	return ret
end

--[[
	@des 	: 设置尺寸
	@param 	: 
	@return : 
--]]
function CircleTableView:setViewSize( viewSize )
	self._viewSize = viewSize
	self._a = viewSize.width * 0.5
	self._b = viewSize.height * 0.5
	self._centerX = self._a
	self._centerY = self._b
	self:setContentSize(self._viewSize)
end

--[[
	@des 	: reloadData
	@param 	: 
	@return : 
--]]
function CircleTableView:reloadData( ... )
	self._cells = {}
	local cellCount = self._eventHandler("numberOfCells", self)
	self._averageRadian = math.pi * 2 / cellCount
	local radian = 0
	-- 根据cell的数量设置cell的位置并存入表中
	for i = 1, cellCount do
		local cell = self._eventHandler("cellAtIndex", self, i);
		self:addChild(cell)
		cell:setAnchorPoint(ccp(0.5, 0.5))
		-- 根据偏移的角度设置位置
		cell:setPosition(self:getPositionByRadian(radian))
		table.insert(self._cells, cell )
		-- 下一个cell所偏移的角度
		radian = radian + self._averageRadian
	end
end

--[[
	@des 	: 设置最大缩放系数
	@param 	: 
	@return : 
--]]
function CircleTableView:setMaxScale( scale )
	self._maxScale = scale
end

--[[
	@des 	: 设置最小缩放系数
	@param 	: 
	@return : 
--]]
function CircleTableView:setMinScale( scale )
	self._minScale = scale
end

--[[
	@des 	: 设置固定的角度偏移  默认第一个cell的位置是x轴正方向
	@param 	: 
	@return : 
--]]
function CircleTableView:setFixedRadianOffset( fixedRadianOffset )
	self._fixedRadianOffset = fixedRadianOffset
	self:refreshPosition()
end

--[[
	@des 	: 通过角度得到位置
	@param 	: 
	@return : 
--]]
function CircleTableView:getPositionByRadian( radian )
	local x = self._a * math.cos(radian) + self._centerX
	local y = self._b * math.sin(radian) + self._centerY
	return ccp(x, y)
end

--[[
	@des 	: 将指定的cell转到最前面
	@param 	: 
	@return : 
--]]
function CircleTableView:showCell( index )
	local radian1 = (self:getCurIndex() - index) * self._averageRadian
	local radian2 = nil
	if radian1 > 0 then
		radian2 = - (math.pi * 2 - radian1)
	elseif radian1 < 0 then
		radian2 = math.pi * 2 + radian1
	end
	local radian = nil
	if math.abs(radian1) > math.abs(radian2) then
		radian = radian2
	else
		radian = radian1
	end
	self:rotationRadianWithAnimation(radian)
	-- self:setRadian(self._radian + (self:getCurIndex() - index) * self._averageRadian)
end

--[[
	@des 	: 复位
	@param 	: 
	@return : 
--]]
function CircleTableView:rotationRadianWithAnimation( radian )
	local radianTemp = 0
	-- 步进角度
	local radianStep = 0.1
	local rotationStartRadian = self._radian
	if math.abs(radian) < radianStep then
		return
	end
	self:setTouchEnabled(false)
	local updateCallback = function ( ... )
		if radian > 0 then
			radianTemp = radianTemp + radianStep
			if radianTemp > radian then
				radianTemp = radian
			end
		elseif radian < 0 then
			radianTemp = radianTemp - radianStep
			if radianTemp < radian then
				radianTemp = radian
			end
		end
		-- 设置当前的角度 从而改变其位置
		self:setRadian(rotationStartRadian + radianTemp)
		if radianTemp == radian then
			self:stopAction(self._rotationAction)
			self:setTouchEnabled(true)
		end
	end
	-- 每帧调用模拟运动轨迹
	self._rotationAction = schedule(self, updateCallback, 1 / 60)
end

function CircleTableView:onNodeEvent( event )
	if event == "enter" then
		local onTouchesHandler = function ( eventType, x, y )
			return self:onTouchesHandler(eventType, x, y)
		end
		self:registerScriptTouchHandler(onTouchesHandler, false, self:getTouchPriority(), false)
		self:setTouchEnabled(true)
	elseif event == "exit" then
		self:unregisterScriptTouchHandler()
	end
end

function CircleTableView:onTouchesHandler( eventType, x, y )
	-- 当前手指在Node上的位置
	local position = self:convertToNodeSpace(ccp(x, y))
	if eventType == "began" then
		-- 触摸区域
		local rect = CCRectMake(0, 0, self:getContentSize().width, self:getContentSize().height)
		if not rect:containsPoint(position) then
			return false
		end
		-- 触摸开始的与x正半轴逆时针方向的夹角
		self._touchBeganRadian = self:getRadianByPosition(position)
		self._beganRadian = self._radian
		self._totalRotationRadian = 0
		-- 旋转方向
		self._rotationDirection = nil
		self._touchMovedRadian = nil
		return true
	elseif eventType == "moved" then
		local touchMovedRadian = self:getRadianByPosition(position)
		if self._touchMovedRadian ~= nil then
			local radianDelta = touchMovedRadian - self._touchMovedRadian
			-- 根据方向得到当前的旋转角度delta
			if self._rotationDirection == Direction.CounterClockwise then
				-- 逆时针
				if radianDelta < 0 then
					self._rotationDirectionRadianDelta = self._rotationRadianDelta
					self._rotationRadianDelta = radianDelta
				else
					self._rotationRadianDelta = self._rotationRadianDelta + radianDelta
				end
			else
				-- 顺时针
				if radianDelta > 0 then
					self._rotationDirectionRadianDelta = self._rotationRadianDelta
					self._rotationRadianDelta  = radianDelta
				else
					self._rotationRadianDelta = self._rotationRadianDelta + radianDelta
				end
			end
			self._lastRadianDelta = radianDelta
			-- 根据旋转角度delta判断出旋转方向
			if self._rotationRadianDelta > self._changeDirectionRadianDelta then
				self._rotationDirection = Direction.CounterClockwise
			elseif self._rotationRadianDelta < -self._changeDirectionRadianDelta then
				self._rotationDirection = Direction.Clockwise
			end
		end
		self._touchMovedRadian = touchMovedRadian
		-- 移动的角度delta
		local deltaRadian = touchMovedRadian - self._touchBeganRadian
		if self._rotationDirection == nil then
			if deltaRadian >= 0 then
				self._rotationDirection = Direction.CounterClockwise
			else
				self._rotationDirection = Direction.Clockwise
			end
			self._rotationDirectionRadianDelta = deltaRadian
			self._lastRadianDelta = deltaRadian
			self._rotationRadianDelta = deltaRadian
		end

		self:setRadian(self._beganRadian + deltaRadian)
	elseif eventType == "ended" or eventType == "canceled" then
		-- TODO
		self:repairRadian()
		self._eventHandler("ended")
	end
end

--[[
	@des 	: 手指离开屏幕后校正当前角度
	@param 	: 
	@return : 
--]]
function CircleTableView:repairRadian( ... )
	-- 根据移动的角度校正当前的角度
	-- self._rotationDirectionRadianDelta 防止向一个方向滑动时 稍微向反方向移动 改变本该移动到的位置
	if math.abs(self._rotationDirectionRadianDelta) < self._changeDirectionRadianDelta and
	 	math.abs(self._rotationRadianDelta) < self._changeDirectionRadianDelta then
	 	-- 当前方向移动的角度小于设定的角度delta 则复位
		self:setRadian(self._beganRadian)
		return
	end
	local radian = 0
	-- 根据移动方向得到最终复位的角度
	if self._rotationDirection == Direction.CounterClockwise then
		-- 逆时针
		radian = self._averageRadian - self._radian % self._averageRadian
	elseif self._rotationDirection == Direction.Clockwise then
		-- 顺时针
		radian = -(self._radian % self._averageRadian)
	end
	self:setRadian(self._radian + radian)
end

--[[
	@des 	: 得到当前最靠前的index 
	@param 	: 
	@return : 
--]]
function CircleTableView:getCurIndex( ... )
	-- 通过获取y坐标最小的cell来确定index
	local minY = self._cells[1]:getPositionY()
	local curIndex = 1
	for i = 2, #self._cells do
		local cell = self._cells[i]
		if cell:getPositionY() < minY then
			minY = cell:getPositionY()
			curIndex = i
		end
	end
	return curIndex
end

--[[
	@des 	: 设置圆的当前角度
	@param 	: 
	@return : 
--]]
function CircleTableView:setRadian( radian )
	-- 设置当前角度
	self._radian = radian
	-- 刷新位置
	self:refreshPosition()
end

--[[
	@des 	: 刷新位置
	@param 	: 
	@return : 
--]]
function CircleTableView:refreshPosition( ... )
	-- 根据当前设置的角度刷新位置
	local radian = self._radian + self._fixedRadianOffset
	for i = 1, #self._cells do
		local cell = self._cells[i]
		cell:setPosition(self:getPositionByRadian(radian))
		radian = radian + self._averageRadian
		-- 近大远小
		cell:setScale(self._maxScale - (self._maxScale - self._minScale) * cell:getPositionY() / self:getContentSize().height)
	end
end

--[[
	@des 	: 通过位置得到与x正半轴逆时针方向的夹角
	@param 	: 
	@return : 
--]]
function CircleTableView:getRadianByPosition( position )
	local radian = 0
	local newX = position.x - self._centerX
	local newY = position.y - self._centerY
	if newX == 0 then
		if newY > 0 then
			radian = math.pi * 0.5
		else
			radian = math.pi * 1.5
		end
	else
		radian = math.atan(newY / newX)
		if newY < 0 then
			if newX > 0 then
				radian = radian + math.pi * 2
			else
				radian = radian + math.pi
			end
		else
			if newX < 0 then
				radian = radian + math.pi
			end
		end
	end
	return radian
end

local CrossPVPTurnFlagLayer = class("CrossPVPTurnFlagLayer", UFCCSNormalLayer)

local CrossPVPConst = require("app.const.CrossPVPConst")

local ITEM_X_PER = {0.5, 0.77, 0.5, 0.23}	-- percent of the layer width
local ITEM_ZOOM  = {1, 0.82, 0.64, 0.82}
local ITEM_MASK	 = {255, 102, 51, 102}

--@param boundpanel: it's the parent layer, and meanwhile defines the touch area of this layer
--@param itemClass: the base module of the items to create
function CrossPVPTurnFlagLayer.create(boundPanel, itemClass)
	local layer = CrossPVPTurnFlagLayer.new(nil, nil, boundPanel, itemClass)
	boundPanel:addNode(layer)
	return layer
end

function CrossPVPTurnFlagLayer:ctor(jsonFile, fun, boundPanel, itemClass)
	self._boundPanel= boundPanel
	self._itemClass = itemClass
	self._activeItem= nil	-- current item in most front, it's the only active item
	self._items 	= {}	-- items list
	self._fixedPos 	= {} 	-- 4 fixed original positions

	-- members for moving
	self._prePos 		= nil 	-- previous touched position
	self._isMoving		= false	-- whether touch is moving
	self._toLeft		= false	-- whether moving toward left
	self._isAutoMoving 	= false -- whether is auto moving
	self._isAutoFinish  = {}

	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPTurnFlagLayer:onLayerLoad()
	-- create items
	self:_createItems()
end

function CrossPVPTurnFlagLayer:onLayerEnter()
	self:registerTouchEvent(false, true, 0)

	-- set the first item as the active defautly
	self:_active(self._items[1])
	self:_deactive(self._items[2])
	self:_deactive(self._items[3])
	self:_deactive(self._items[4])
end

function CrossPVPTurnFlagLayer:onLayerExit()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function CrossPVPTurnFlagLayer:onTouchBegin(x, y)
	local touchPos = self:convertToNodeSpace(ccp(x,y))
	local isInArea = self:_isContainPos(touchPos)

	if isInArea then
		self._prePos = touchPos
		return true
	end

	return false
end

function CrossPVPTurnFlagLayer:onTouchMove(x, y)
	-- convert to position in node space
	local touchPos = self:convertToNodeSpace(ccp(x,y))

	-- deactive all items when begins to move
	if not self._isMoving then
		self:_deactiveAll()
	end

	-- moving toward left ?
	local toLeft = touchPos.x < self._prePos.x
	if not self._isMoving or self._toLeft ~= toLeft then
		self._toLeft = toLeft
		for i, v in ipairs(self._items) do
			self:_setNextTarget(v)
		end
	end

	self._isMoving	= true

	-- move
	self:_moveAllItems(touchPos.x - self._prePos.x)

	-- cover previous pos
	self._prePos = touchPos
end

function CrossPVPTurnFlagLayer:onTouchCancel(x, y)
	self:onTouchEnd(x,y)
end

function CrossPVPTurnFlagLayer:onTouchEnd(x, y)
	if self._isMoving then
		self:_beginAutoMove()
	else
		-- 没有移动过，判断一下触摸点相对于active item区域的方位，然后自动转动
		local dirToActive = self:_checkPosToActiveArea(self._prePos)
		if dirToActive ~= 0 then
			self._toLeft = dirToActive == -1
			for i, v in ipairs(self._items) do
				self:_setNextTarget(v)
			end

			self:_deactiveAll()
			self:_beginAutoMove()
		end
	end
	self._isMoving = false
end

function CrossPVPTurnFlagLayer:getItem(i)
	return self._items[i]
end

function CrossPVPTurnFlagLayer:_createItems()
	local layerWidth = self._boundPanel:getContentSize().width

	for i = 1, CrossPVPConst.BATTLE_FIELD_NUM do
		local item = self._itemClass.create(i)
		local scale = ITEM_ZOOM[i]

		-- set anchor point, scale, zorder
		item:setAnchorPoint(ccp(0, 0))
		item:setScale(scale)
		item:setZOrder(scale * 100)

		-- set position
		local itemSize = item:getRootWidget():getContentSize()
		local px = (layerWidth * ITEM_X_PER[i] - itemSize.width * scale / 2)
		local py = itemSize.height * (1 - scale) / 2 
		item:setPositionXY(px, py)
		
		self._fixedPos[i] = ccp(px, py)
		self:addChild(item)

		-- set color
		local c = ITEM_MASK[i]
		item:getRootWidget():setColor(ccc3(c, c, c))

		-- set the default logical index of the item
		item._logicalIndex = i
		item._targetIndex = i

		self._items[i] = item
	end
end

-- jump to a specified item
-- @param jumpIndex: the index of the item
function CrossPVPTurnFlagLayer:_jumpToItem(jumpIndex)
	if jumpIndex == 1 then
		return
	end

	-- change all items position
	for i = 1, CrossPVPConst.BATTLE_FIELD_NUM do
		local itemIndex = (jumpIndex + i - 1) % CrossPVPConst.BATTLE_FIELD_NUM
		if itemIndex == 0 then
			itemIndex = 4
		end

		local item = self._items[itemIndex]
		local pos  = self._fixedPos[i]
		item:setPositionXY(pos.x, pos.y)
		item._logicalIndex = i
		item._targetIndex = i

		self:_adjustItemByPos(item)
		
		if itemIndex == jumpIndex then
			self:_active(item)
		else
			self:_deactive(item)
		end
	end
end

function CrossPVPTurnFlagLayer:_isContainPos(p)
	local boundSize = self._boundPanel:getContentSize()
	return p.x >= 0 and p.x <= boundSize.width and p.y >= 0 and p.y <= boundSize.height
end

-- 检查一个点相对于活跃Item的方位
-- 在活跃item区域内则返回0，在左边则返回-1，在右边返回1
function CrossPVPTurnFlagLayer:_checkPosToActiveArea(p)
	if not self._activeItem then return 0 end

	local originX, _ = self._activeItem:getPosition()
	local activeSize = self._activeItem:getRootWidget():getContentSize()

	if p.x < originX then return -1
	elseif p.x > originX + activeSize.width then return 1
	else return 0 end
end

function CrossPVPTurnFlagLayer:_active(item)
	self._activeItem = item
	if item.onActive then
		item:onActive()
	end
end

function CrossPVPTurnFlagLayer:_deactive(item)
	if self._activeItem == item then
		self._activeItem = nil
	end

	if item.onDeactive then
		item:onDeactive()
	end
end

function CrossPVPTurnFlagLayer:_deactiveAll()
	for i, v in ipairs(self._items) do
		self:_deactive(v)
	end
end

function CrossPVPTurnFlagLayer:_moveAllItems(offsetX)
	local hasItemReach = false	-- 记录是否有item到达了目标位置
	local reachItem = 0			-- 首先到达目标位置的item

	for i, v in ipairs(self._items) do
		hasItemReach = self:_moveItem(v, math.abs(offsetX))

		-- 如果有item到达了目标位置，强制退出循环
		if hasItemReach then
			reachItem = i
			break
		end
	end

	-- 这里做一个同步措施：如果有Item先达到了目标位，就把其他item也强制拉到目标位
	if hasItemReach then
		for i, v in ipairs(self._items) do
			if i ~= reachItem then
				local targetPos  = self._fixedPos[v._targetIndex]
				v:setPositionXY(targetPos.x, targetPos.y)
				self:_adjustItemByPos(v)
				v._logicalIndex = v._targetIndex
				self:_setNextTarget(v)
			end
		end
	end
end

function CrossPVPTurnFlagLayer:_moveItem(item, absOffX)
	local originPos  = self._fixedPos[item._logicalIndex]
	local targetPos  = self._fixedPos[item._targetIndex]
	local curX, curY = item:getPosition()
	local isReachTarget = false

	-- 因为四个旗子不处于同一平面上，所以相互距离不统一，这里以第一到第二旗子的距离为基准，做百分比换算
	local percent = absOffX / (self._fixedPos[2].x - self._fixedPos[1].x)
	absOffX = math.abs((targetPos.x - originPos.x) * percent)

	while absOffX > 0 do
		local moveX = absOffX
		local reachTarget = false
		if (targetPos.x >= curX and curX + absOffX >= targetPos.x) or
		   (targetPos.x <= curX and curX - absOffX <= targetPos.x) then 
			moveX = targetPos.x - curX
			absOffX = absOffX - math.abs(moveX)
			reachTarget = true
		else
			moveX = targetPos.x > originPos.x and absOffX or -absOffX
			absOffX = 0
		end
		
		-- set position and adjust other attributes
		item:setPositionX(curX + moveX)
		item:setPositionY(curY + (targetPos.y - originPos.y) / (targetPos.x - originPos.x) * moveX )
		self:_adjustItemByPos(item)

		-- if the item reaches target pos, set its next target
		if reachTarget then
			item._logicalIndex = item._targetIndex
			self:_setNextTarget(item)

			originPos  = self._fixedPos[item._logicalIndex]
			targetPos  = self._fixedPos[item._targetIndex]
			curX, curY = item:getPosition()

			isReachTarget = true
			break
		end
	end

	return isReachTarget
end

function CrossPVPTurnFlagLayer:_adjustItemByPos(item)
	local originX = self._fixedPos[item._logicalIndex].x
	local targetX = self._fixedPos[item._targetIndex].x
	local curX    = item:getPositionX()
	local percent = 1

	if targetX ~= originX then
		percent = math.abs((curX - originX) / (targetX - originX))
	end

	-- scale
	local originS = ITEM_ZOOM[item._logicalIndex]
	local targetS = ITEM_ZOOM[item._targetIndex]
	local curS	  = originS + (targetS - originS) * percent
	item:setScale(curS)
	item:setZOrder(curS * 100)

	-- color
	local originC = ITEM_MASK[item._logicalIndex]
	local targetC = ITEM_MASK[item._targetIndex]
	local curC    = originC + (targetC - originC) * percent
	item:getRootWidget():setColor(ccc3(curC, curC, curC))
end

function CrossPVPTurnFlagLayer:_setNextTarget(item)
	local oldTarget = item._targetIndex
	item._targetIndex = item._targetIndex + (self._toLeft and -1 or 1)
	if item._targetIndex < 1 then
		item._targetIndex = CrossPVPConst.BATTLE_FIELD_NUM
	elseif item._targetIndex > CrossPVPConst.BATTLE_FIELD_NUM then
		item._targetIndex = 1
	end

	-- 这里是处理方向反转
	if item._logicalIndex == item._targetIndex then
		item._logicalIndex = oldTarget
	end
end

function CrossPVPTurnFlagLayer:_beginAutoMove()
	-- disable touch
	self:setTouchEnabled(false)

	-- reset finish flag
	self._isAutoFinish = {false, false, false, false}

	-- begin timer
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(0, handler(self, self._autoMoveUpdate))
	end
end

function CrossPVPTurnFlagLayer:_autoMoveUpdate(dt)
	for i, v in ipairs(self._items) do
		if v._logicalIndex == v._targetIndex then
			self._isAutoFinish[i] = true
		end

		if not self._isAutoFinish[i] then 
			local originPos  = self._fixedPos[v._logicalIndex]
			local targetPos  = self._fixedPos[v._targetIndex]
			local curX, curY = v:getPosition()

			-- move
			local absOffX = math.abs((targetPos.x - originPos.x) * dt)
			local moveX = absOffX
			if (targetPos.x >= curX and curX + absOffX >= targetPos.x) or
		   	   (targetPos.x <= curX and curX - absOffX <= targetPos.x) then 
				moveX = targetPos.x - curX
				self._isAutoFinish[i] = true
			else
				moveX = targetPos.x > originPos.x and absOffX or -absOffX
			end

			-- set position and adjust other attributes
			v:setPositionX(curX + moveX)
			v:setPositionY(curY + (targetPos.y - originPos.y) / (targetPos.x - originPos.x) * moveX )
			self:_adjustItemByPos(v)

			if self._isAutoFinish[i] then
				v._logicalIndex = v._targetIndex

				-- 这个item转到了最前面，就把他标记为活跃的
				if v._logicalIndex == 1 then
					self:_active(v)
				end
			end
		end
	end


	local isAllFinished = true
	for i, v in ipairs(self._isAutoFinish) do
		if v == false then
			isAllFinished = false
			break
		end
	end

	if isAllFinished then
		if self._timer then
			G_GlobalFunc.removeTimer(self._timer)
			self._timer = nil
		end

		self:setTouchEnabled(true)
	end
end

return CrossPVPTurnFlagLayer
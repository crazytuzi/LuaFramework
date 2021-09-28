--[[
    文件名：EllipseLayer.lua
    描述：把物体排列在椭圆上，可以滑动旋转旋转物体
    创建人：yanweicai
    创建时间：2015.05.07
-- ]]


local EllipseLayer = class("EllipseLayer", function()
    return display.newLayer()
end)


function EllipseLayer:ctor(parmas)
	self.config = {}
	-- 必须的参数
	self.config._longAxias = parmas.longAxias 		-- 椭圆的长轴
	self.config._totalItemNum = parmas.totalItemNum 		-- 总共需要显示的个数， 用于计算间隔
	self.config._itemContentCallback = parmas.itemContentCallback  -- 具体每个item显示内容的回调函数


	-- 可选的参数
	self.config._shortAxias = parmas.shortAxias or parmas.longAxias		-- 椭圆的短轴
	self.config._unlockItemNum = parmas.unlockItemNum or parmas.totalItemNum	-- 已解锁的item个数
	self.config._alignCallback = parmas.alignCallback or nil 		-- item居中显示后的回调


	-- 通过配置算出来的参数
	self.config._eachItemAngle = (360 / self.config._totalItemNum) 	-- 每一个item占的弧度
	-- 修正角度
	-- 3, 270	120
	-- 4, 180	90
	-- 5, 144	72
	-- 6, 90	60
	self.config._fixAngle = parmas.fixAngle or 0


	-- 用于存放每个item内容的node
	self._itemNodes = {}
	self._curRotationAngle = 0 		-- 记录当前旋转角度

	-- 是否需要改变缩放 默认需要改变
	self._isNeedChangeScale = true
	if parmas.isNeedChangeScale == false then
		self._isNeedChangeScale = false
	end

	self:initUI()
end


function EllipseLayer:getItemZorder(index)
	local posx, posy = self:getItemPosition(index)
	local zOrder = -posy

	local tmpy = posy + self.config._shortAxias
	local itemScale = 1 - (tmpy / (self.config._shortAxias * 5))

	local itemOpacity = (1 - (tmpy / (self.config._shortAxias * 2)) ) * 255

    return zOrder, itemScale, itemOpacity
end

-- 
function EllipseLayer:getItemPosition(index)
	local radians = (index - 1) * self.config._eachItemAngle - self._curRotationAngle + self.config._fixAngle

	local radians = (radians % 360) * 3.1415 / 180

	local posx = math.cos(radians ) * self.config._longAxias
	local posy = math.sin(radians ) * self.config._shortAxias

    return posx, posy
end

-- 
function EllipseLayer:getItemAngle(index)
	local angle = (index - 1) * self.config._eachItemAngle

	angle = angle + 720
	angle = angle % 360

	if angle == 0 then angle = 360 end

    return angle
end

function EllipseLayer:getItemScaleFromAngle(angle)
	-- print("angle: ", angle, math.sin(angle))
	return math.sin(angle)
end

function EllipseLayer:getItemIndexFromAngle(angle)
	local index = math.floor( (angle / self.config._eachItemAngle) + 0.5 )

	return (index) % self.config._totalItemNum + 1
end


-- 初始化
function EllipseLayer:initUI()
    for i = 1, self.config._totalItemNum do
    	local posx, posy = self:getItemPosition(i)
    	local itemZorder, itemScale, itemOpacity = self:getItemZorder(i)

    	local itemNode = display.newNode()
    	itemNode:setLocalZOrder(itemZorder)
    	itemNode:setPosition(cc.p(posx, posy))
    	if self._isNeedChangeScale then 
    		itemNode:setScale(itemScale)
    	end
    	
    	self:addChild(itemNode)


    	--test
    	-- local itemAngle = self:getItemAngle(i)
    	-- local itemIndex = self:getItemIndexFromAngle(itemAngle)
    	-- print("itemAngle: ", i, itemZorder, posx, posy)

    	-- 记录node
    	self._itemNodes[i] = itemNode

    	self.config._itemContentCallback(itemNode, i)

    	if itemNode.updateFunc then
    		itemNode.updateFunc(itemOpacity)
    	end
    end

end

-- 设置当前旋转度数
function EllipseLayer:setRadiansOffset(radiusOffset)
	self._curRotationAngle = self._curRotationAngle + radiusOffset
	self._curRotationAngle = self._curRotationAngle % 360

	self:updateAllItemPosition()
end

-- 更新所有item位置
function EllipseLayer:updateAllItemPosition()
    for i = 1, self.config._totalItemNum do
    	local posx, posy = self:getItemPosition(i)
    	local itemZorder, itemScale, itemOpacity = self:getItemZorder(i)

    	local itemNode = self._itemNodes[i]
    	itemNode:setPosition(cc.p(posx, posy))
    	itemNode:setLocalZOrder(itemZorder)
    	if self._isNeedChangeScale then 
    		itemNode:setScale(itemScale)
    	end

    	if itemNode.updateFunc then
    		itemNode.updateFunc(itemOpacity)
    	end
    end
end

-- 更新所有item位置
function EllipseLayer:debugAllItemPosition()
    for i = 1, self.config._totalItemNum do
    	local posx, posy = self:getItemPosition(i)
    	local itemZorder, itemScale, itemOpacity = self:getItemZorder(i)


    	--test
    	local itemAngle = self:getItemAngle(i)
    	local itemIndex = self:getItemIndexFromAngle(itemAngle)


    	print("itemOpacity:", itemOpacity)
    	print("itemAngle: ", i, itemZorder, itemScale)
    end
end

function EllipseLayer:getPreviousItemIndex(index)
	index = index - 1

	if index < 1 then index = self.config._totalItemNum end

	return index
end

function EllipseLayer:getNextItemIndex(index)
	index = index + 1

	if index > self.config._totalItemNum then index = 1 end

	return index
end


-- 前移一个
function EllipseLayer:moveToPreviousItem()
	-- print("moveToPreviousItem")
	local curAngle = self._curRotationAngle

	local curItemIndex = self:getItemIndexFromAngle(curAngle)
	local newItemIndex = self:getPreviousItemIndex( curItemIndex)

	-- 判断
	if newItemIndex > self.config._unlockItemNum then
		newItemIndex = curItemIndex
	end


	-- action
	self:moveToIndexItem(newItemIndex, true)
end

-- 后移动一个
function EllipseLayer:moveToNextItem()
	-- print("moveToNextItem")
	local curAngle = self._curRotationAngle

	local curItemIndex = self:getItemIndexFromAngle(curAngle)
	local newItemIndex = self:getNextItemIndex( curItemIndex)


	if newItemIndex > self.config._unlockItemNum then
		newItemIndex = curItemIndex
	end

	-- action
	self:moveToIndexItem(newItemIndex, true)
end


-- 移动到指定item
function EllipseLayer:moveToIndexItem(index, withAnimation)
	-- 判断是否锁定
	if index > self.config._unlockItemNum then
		return
	end

	-- 目标角度
	local newItemAngle = self:getItemAngle(index)
	local diffAngle = (newItemAngle - self._curRotationAngle)

	if math.abs(diffAngle) > 180 then
		if diffAngle < 0 then 
			diffAngle = diffAngle + 360 
		end

		if diffAngle > 0 then 
			diffAngle = diffAngle - 360 
		end
	end
-- print("self._curRotationAngle, newItemAngle, diffAngle: ", self._curRotationAngle, newItemAngle, diffAngle)

	diffAngle = (diffAngle) / 15

	if withAnimation == false or diffAngle == 0 then
		self._curRotationAngle = newItemAngle
		self:updateAllItemPosition()
		return
	end

	local diffTime = 0.2 / 15 --动画时间
	local actionArray = {}

	local function udpateItemOffset()
		self._curRotationAngle = self._curRotationAngle + diffAngle
		self:updateAllItemPosition()
	end

	for i = 1, 15 do
		table.insert(actionArray, cc.DelayTime:create(diffTime))
		table.insert(actionArray, cc.CallFunc:create(udpateItemOffset))
	end
	table.insert(actionArray, cc.CallFunc:create(handler(self, self.alignCallback)))

	self:runAction(cc.Sequence:create(actionArray))
end


-- 让layer居中显示到一个物品上
function EllipseLayer:alignTheLayer()
	local curAngle = self._curRotationAngle

	local itemIndex = self:getItemIndexFromAngle(curAngle)

	-- action
	self:moveToIndexItem(itemIndex, true)
end

function EllipseLayer:alignCallback()
	local curItemIndex = self:getCurrentItemIndex()

	self._curRotationAngle = self._curRotationAngle + 720
	self._curRotationAngle = self._curRotationAngle % 360


	-- 回调
	if self.config._alignCallback ~= nil then
		self.config._alignCallback(curItemIndex)
	end

	-- self:debugAllItemPosition()
end

-- 返回当前选中的item index
function EllipseLayer:getCurrentItemIndex()
	local curAngle = self._curRotationAngle
	local itemIndex = self:getItemIndexFromAngle(curAngle)

	return itemIndex
end

-- reloadLayer
function EllipseLayer:reloadLayer(index)
	if index ~= nil then
    	self._itemNodes[index]:removeAllChildrenWithCleanup(true)
    	self.config._itemContentCallback(self._itemNodes[index], index)
		return
	end

    for i = 1, self.config._totalItemNum do
    	self._itemNodes[i]:removeAllChildrenWithCleanup(true)
    	self.config._itemContentCallback(self._itemNodes[i], i)
    end
end

-- 返回指定的itemNode
function EllipseLayer:getItemNode(index)
	return self._itemNodes[index]
end

-- 返回当前旋转的角度 
function EllipseLayer:getRotationAngle()
	return self._curRotationAngle
end

return EllipseLayer
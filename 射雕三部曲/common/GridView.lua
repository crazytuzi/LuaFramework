--[[
文件名:GridView.lua
描述：格子列表空间，可以用于展示物品头像的列表，比如背包，人物等
创建人：liaoyuangang
创建时间：2016.05.16
--]]

local GridView = class("GridView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为:
	{
		viewSize: 控件的显示大小, 默认 cc.size(640, 500)
		colCount: 每行的的个数, 默认为 5 个
		celHeight: 格子的高度, 默认为格子的宽度（格子的宽度有 viewSize.width / colCount）
		selectIndex: 选中格子的index， 默认为nil
		needDelay: 格子是否需要延时加载, 默认为false

		getCountCb: 获取格子的总数的回调函数
		createColCb: 创建每个格子的回调函数 createColCb(itemParent, colIndex, isSelected)
	}
]]
function GridView:ctor(params)
	params = params or {}
	-- 控件的显示大小
	self.mViewSize = params.viewSize or cc.size(640, 500)
	-- 卡牌摆放区域大小
	self.mViewSize1 = params.viewSize or cc.size(634, 500)
	-- 每行的的个数
	self.mColCount = params.colCount or 5
	-- 格子的高度
	self.mCelHeight = params.celHeight
	self.mSelectIndex = params.selectIndex
	-- 获取格子的总数的回调函数
	self.getCountCb = params.getCountCb
	-- 创建每个格子的回调函数
	self.createColCb = params.createColCb
	-- 格子是否延时加载
	self.mNeedDelay = params.needDelay or false

	-- 
	self.mCellNodeList = {}

	-- 设置该layer的大小
	self:setContentSize(self.mViewSize)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setIgnoreAnchorPointForPosition(false)
	
	-- 创建显示信息的 ScrollView
    self.mScrollView = ccui.ScrollView:create()
    self.mScrollView:setContentSize(self.mViewSize)
    self.mScrollView:setDirection(ccui.ScrollViewDir.vertical);
    self.mScrollView:setPosition(0, 0);
    self:addChild(self.mScrollView)

    -- 格子真正的parent
    self.mCellParent = ccui.Layout:create()
    self.mCellParent:setPosition(cc.p(0, 0))
    self.mScrollView:addChild(self.mCellParent)

    -- 
    self:reloadData()
end

-- 设置选中的Item的Index
--[[
-- 参数
	selectIndex: 选中条目的Index，计数从1开始
]]
function GridView:setSelect(selectIndex)
	local oldSelectIndex = self.mSelectIndex
	self.mSelectIndex = selectIndex

	if self.mSelectIndex ~= oldSelectIndex then
		if oldSelectIndex then
			self:refreshCell(oldSelectIndex)
		end
		if self.mSelectIndex then
			self:refreshCell(self.mSelectIndex)
		end
	end 
end

-- 获取当前选中条目的Index
function GridView:getSelectIndex()
	return self.mSelectIndex
end

-- 刷新某一个格子
function GridView:refreshCell(cellIndex)
	local tempNode = self.mCellNodeList[cellIndex or 1]
	if not tempNode then
		return 
	end
	
	tempNode:removeAllChildren()
	self.createColCb(tempNode, cellIndex, self.mSelectIndex == cellIndex)
end

-- 获取某一个格子
function GridView:getCell(cellIndex)
	local tempNode = self.mCellNodeList[cellIndex or 1]
	if not tempNode then
		return 
	end
	return tempNode
end

-- 显示不全时，滑动某一个格子到最上
function GridView:setItemShow(cellIndex)
	local tempNode = self.mCellNodeList[cellIndex or 1]
	if not tempNode then
		return
	end

	local x, y = tempNode:getPosition()
	local nodeSize = tempNode:getContentSize()
	local containerPos = self.mScrollView:getInnerContainerPosition()
	local containerSize = self.mScrollView:getInnerContainerSize()
	local viewSize = self.mScrollView:getContentSize()
	local distance = y - viewSize.height + containerPos.y
	if distance > 0 or distance < -viewSize.height+nodeSize.height then
		local newContainerPosY = containerPos.y-distance
		if newContainerPosY > 0 then
			newContainerPosY = 0
		elseif newContainerPosY < -containerSize.height+viewSize.height then
			newContainerPosY = -containerSize.height+viewSize.height
		end
		self.mScrollView:setInnerContainerPosition(cc.p(0, newContainerPosY))
	end
end

-- 重新加载格子控件
function GridView:reloadData()
	local tempCount = self.getCountCb()
	local celWidth = self.mViewSize1.width / self.mColCount
	local celHeight = self.mCelHeight or celWidth
	local rowCount = math.ceil(tempCount / self.mColCount)
	self.mCellNodeList = {}

	local innerHeight = math.max(self.mViewSize.height, rowCount * celHeight)
	self.mScrollView:setInnerContainerSize(cc.size(self.mViewSize.width, innerHeight))
	self.mCellParent:removeAllChildren()
	for index = 1, tempCount do
		local tempPosX = math.mod(index - 1, self.mColCount) * celWidth
		local tempPosY = innerHeight - math.floor((index - 1) / self.mColCount) * celHeight

		local tempNode = ccui.Layout:create()
		tempNode:setContentSize(cc.size(celWidth, celHeight))
		tempNode:setAnchorPoint(cc.p(0, 1))
		tempNode:setIgnoreAnchorPointForPosition(false)
		tempNode:setPosition(tempPosX, tempPosY)
		self.mCellParent:addChild(tempNode)
		table.insert(self.mCellNodeList, tempNode)

		self.createColCb(tempNode, index, self.mSelectIndex == index)

		-- 延迟加载物品
		if self.mNeedDelay then
			tempNode:setVisible(false)
			Utility.performWithDelay(tempNode, function()
				tempNode:setVisible(true)
			end, 0.02*index)
		end
	end

    self.mScrollView:jumpToTop()
	self:setSelect(self.mSelectIndex)
end

return GridView
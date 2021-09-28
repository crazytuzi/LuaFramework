local UIBase = require "ui/common/UIBase"

local UIDefault = require "ui/common/DefaultValue"

local UIScrollList=class("UIScrollList", UIBase)

local ITEM_LAYOUT_ITEM = 0
local ITEM_LAYOUT_GRID = 1

local SCROLL_BAR_WIDTH = 5

g_UIScrollList_HORZ_ALIGN_LEFT = 0
g_UIScrollList_HORZ_ALIGN_CENTER = 1
g_UIScrollList_HORZ_ALIGN_RIGHT = 2
g_UIScrollList_HORZ_ALIGN_NARROW_CENTER = 3

function UIScrollList:ctor(ccNode, propConfig)
	UIScrollList.super.ctor(self, ccNode, propConfig)
	self.child = {}
	self.itemLayoutType = {}
	--[[
	self.itemLayoutType里面的table有可能有如下两种：
	当新加的item是单个item时：{index = 开始index, type = ITEM_LAYOUT_ITEM}
	当新加一组一行（列）多个item时：{index = 开始index, type = ITEM_LAYOUT_GRID, length = 一行（列）item个数}
	]]
	
	self.ccNode_:setBounceEnabled(true)
	self.ccNode_:setClippingType(1)
	self._enableBar = propConfig.showScrollBar == nil or propConfig.showScrollBar
	self._barImage = propConfig.scrollBarImage or UIDefault.DefScrollList.scrollBarImage
	self._ballImage = propConfig.scrollBallImage or UIDefault.DefScrollList.scrollBallImage
	
	self._horizontal = propConfig.horizontal
	
	self.direction = propConfig.horizontal and 2 or 1
	
	--self:AddScriptCallback("exit", function ()
		--self:removeAllChildren(false)
	--end)
end

--这个必须在添加第一个item之前调用，否则会有问题滴~~
function UIScrollList:setAlignMode(align)
	if self._horizontal then
		--之后横向滚动才有align
		self.align = align
	end
end

function UIScrollList:getInnerContainer()
	return self.ccNode_:getInnerContainer()
end

function UIScrollList:setClippingEnabled(enabled)
	self.ccNode_:setClippingEnabled(enabled)
end

function UIScrollList:setBounceEnabled(enabled)
	self.ccNode_:setBounceEnabled(enabled)
end

function UIScrollList:setDirection(direction)
	self.ccNode_:setDirection(direction)
end

function UIScrollList:getDirection()
	return self.ccNode_:getDirection()
end

function UIScrollList:setContainerSize(width, height)
	if width<self:getContentSize().width then
		width = self:getContentSize().width
	end
	if height<self:getContentSize().height then
		height = self:getContentSize().height
	end
	self.ccNode_:setInnerContainerSize(cc.size(width, height))
	self.needUpdateProgressVies = true;
	self:checkAddEventListener();
	self:createProgressView()
end

function UIScrollList:getContainerSize()
	return self.ccNode_:getInnerContainerSize()
end

function UIScrollList:jumpToListPercent(percent)
	if self._horizontal then
		self.ccNode_:jumpToPercentHorizontal(percent)
	else
		self.ccNode_:jumpToPercentVertical(percent)
	end
end

function UIScrollList:jumpToChildWithIndex(index)
	local totalCount = self:getChildrenCount()
	if totalCount == 0 then
		return
	end
	if index > totalCount then
		index = totalCount
	elseif index <= 0 then
		index = 1
	end
	local direct = self:getDirection()
	local innerContainer = self:getInnerContainer()
	local contentSize = self:getContentSize()
	local containerSize = self:getContainerSize()
	if direct==2 then
		local totalWidth = 0
		for i=1,index-2 do
			local child = self:getChildAtIndex(i)
			local childWidth = child.rootVar:getSizeInScroll(self).width
			totalWidth = totalWidth+childWidth
		end
		local innerPosX = 0
		local innerPosY = innerContainer:getPositionPercent().y
		local posX = innerPosX-totalWidth
		if posX>0 then
			posX = 0
		elseif posX<contentSize.width - containerSize.width then
			posX = contentSize.width - containerSize.width
		end
		innerContainer:setPositionPercent(cc.p(posX/contentSize.width, innerPosY))
	else
		local totalHeight = 0
		for i=1,index-2 do
			local child = self:getChildAtIndex(i)
			local childHeight = child.rootVar:getSizeInScroll(self).height
			totalHeight = totalHeight+childHeight
		end
		local innerPosX = innerContainer:getPositionPercent().x
		local innerPosY = contentSize.height - containerSize.height
		
		local posY = innerPosY+totalHeight
		if posY>0 then
			posY = 0
		end
		innerContainer:setPositionPercent(cc.p(innerPosX, posY/contentSize.height))
	end
end

function UIScrollList:getListPercent()
	local innerContainer = self:getInnerContainer()
	local contentSize = self:getContentSize()
	local containerSize = self:getContainerSize()
	local percent
	if self._horizontal then
		local innerPosX = innerContainer:getPositionPercent().x*contentSize.width
		
		local minX = contentSize.width - containerSize.width
		local betweenContainerAndContent = -minX
		
		local distanceToBottom = math.ceil(innerPosX+betweenContainerAndContent)
		
		percent = 1 - distanceToBottom/betweenContainerAndContent
	else
		local innerPosY = innerContainer:getPositionPercent().y*contentSize.height
		
		local minY = contentSize.height - containerSize.height
		local betweenContainerAndContent = -minY
		
		local distanceToBottom = math.ceil(innerPosY+betweenContainerAndContent)
		
		percent = betweenContainerAndContent~=0 and distanceToBottom/betweenContainerAndContent or 0
	end
	return percent*100
end

function UIScrollList:addChildWithCount(nodePath, length, totalCount, isClean)-----arg[1]是node的路径字符串，arg[2]每一行(列)添加几个控件，arg[3]是总共添加多少个
	self:removeAllChildren(isClean)
	return self:addItemAndChild(nodePath, length, totalCount)
end


function UIScrollList:addItemAndChild(nodePath, length, totalCount)-----arg[1]是node的路径字符串，arg[2]每一行(列)添加几个控件，arg[3]是总共添加多少个
	local rowItemCount = length or 1
	local itemCount = totalCount or 1

	if itemCount > 0 then
		if rowItemCount == 1 then
			if #self.itemLayoutType == 0 or self.itemLayoutType[#self.itemLayoutType].type == ITEM_LAYOUT_GRID then
				table.insert(self.itemLayoutType, {index = #self.child + 1, type = ITEM_LAYOUT_ITEM})
			end
		else
			table.insert(self.itemLayoutType, {index = #self.child + 1, type = ITEM_LAYOUT_GRID, length = rowItemCount})
		end
	end
	local horizontal = self._horizontal ~= nil and self._horizontal == true
	local children = {}
	local nodefunc = require(nodePath)
	local node = nodefunc()
	local nodeSize = node.rootVar:getSize()
	local nodeWidth = nodeSize.width
	local nodeHeight = nodeSize.height
	--这里的scrollContainerWidth “宽度”是指垂直于滚动方向的那个方向
	local scrollContainerWidth = 0
	local proportion = 0
	if horizontal then
		scrollContainerWidth = self:getContainerSize().height
		if self._enableBar then
			proportion = (scrollContainerWidth-SCROLL_BAR_WIDTH)/nodeHeight/rowItemCount
		else
			proportion = scrollContainerWidth/nodeHeight/rowItemCount
		end
	else
		scrollContainerWidth = self:getContainerSize().width
		if self._enableBar then
			scrollContainerWidth = scrollContainerWidth - SCROLL_BAR_WIDTH
		end
		proportion = scrollContainerWidth/nodeWidth/rowItemCount
	end
	
	for i = 0, itemCount - 1 do
		node = (node == nil) and nodefunc() or node
		node.rootVar:setSizeType(ccui.SizeType.absolute)
		node.rootVar:setContentSize(nodeWidth*proportion, nodeHeight*proportion)
		if horizontal then
			node.rootVar:setPositionInScroll(self, 
			0, scrollContainerWidth / ( 2 * rowItemCount ) * ( 2 * (rowItemCount - (i % rowItemCount)) - 1 ))--update的时候会设置x的
		else
			node.rootVar:setPositionInScroll(self, 
			scrollContainerWidth / ( 2 * rowItemCount ) * ( 2 * (i % rowItemCount) + 1 ), 0)--update的时候会设置y的
		end
		self:addChildAndAnis(node)
		table.insert(children, node)
		table.insert(self.child, node)
		node = nil
	end
	self:update()
	return children
end


function UIScrollList:addChild(node)
	node.rootVar:setSizeType(ccui.SizeType.absolute)
	self:addChildAndAnis(node)
end

function UIScrollList:addItem(node)
	local var = node.rootVar
	local nodeSize = var:getSize()
	local scrollContainerSize=self:getContainerSize()
	var:setSizeType(ccui.SizeType.absolute)
	if self._horizontal then
		self:setDirection(2)--设置横向滑动
		self:setBounceEnabled(false)
		local heightProportion = scrollContainerSize.height/nodeSize.height
		if self._enableBar then
			self._enableBar = false
		end
		var:setContentSize(nodeSize.width*heightProportion, nodeSize.height*heightProportion)
		var:setPositionInScroll(self, 0, scrollContainerSize.height/2)	--update的时候会设置x的
	else
		local widthProportion = 0
		if self._enableBar then
			scrollContainerSize.width = scrollContainerSize.width - SCROLL_BAR_WIDTH
		end
		widthProportion = scrollContainerSize.width / nodeSize.width
		var:setContentSize(nodeSize.width*widthProportion, nodeSize.height*widthProportion)
		var:setPositionInScroll(self, scrollContainerSize.width / 2, 0)	--update的时候会设置y的
	end
	
	self:addChildAndAnis(node)
	table.insert(self.child, node)
	if #self.itemLayoutType == 0 or self.itemLayoutType[#self.itemLayoutType].type == ITEM_LAYOUT_GRID then
		table.insert(self.itemLayoutType, {index = #self.child, type = ITEM_LAYOUT_ITEM})
	end
	self:update()
end

function UIScrollList:replaceItemAtIndex(node, index, isNotSet)
	assert( self._horizontal == nil or self._horizontal == false, "_horizontal could not replaceItemAtIndex")
	local totalCount = self:getChildrenCount()
	if index<0 or index>totalCount then
		return
	else
		local nodeSize = node.rootVar:getSize()
		local containerSize = self:getContainerSize()
		local widthProportion = containerSize.width/nodeSize.width
		local needNodeHeight = nodeSize.height*widthProportion
		local oldNodePos = self.child[index].rootVar:getPositionInScroll(self)
		self:removeChild(self.child[index].root, true)
		node.rootVar:setSizeType(ccui.SizeType.absolute)
		node.rootVar:setContentSize(nodeSize.width*widthProportion, needNodeHeight)
		node.rootVar:setPositionInScroll(self, oldNodePos.x, oldNodePos.y)
		self:addChildAndAnis(node)
		self.child[index] = node
		self:update()
		if not isNotSet then
			local pos = node.rootVar:getPositionInScroll(self)
			local innerContainer = self:getInnerContainer()
			local innerPosX, innerPosY = innerContainer:getPosition()
			if (pos.y - needNodeHeight / 2 < -innerPosY) then
				innerPosY = -(pos.y - needNodeHeight / 2)
			end
			innerContainer:setPosition(innerPosX, innerPosY)
		end
	end
end

function UIScrollList:removeAllChildren(isClean)
	self.ccNode_:removeAllChildren()
	self.child = {}
	self.itemLayoutType = {}
	if isClean then
		local scrollContentSize = self:getContentSize()
		self:setContainerSize(scrollContentSize.width, scrollContentSize.height)
	end
end

function UIScrollList:removeChild(node, isCleanup)
	self.ccNode_:removeChild(node, isCleanup)
end

function UIScrollList:insertChildToIndex(node, index)
	local total = self:getChildrenCount()
	assert( self._horizontal == nil or self._horizontal == false, "_horizontal could not insertChildToIndex")
	if index>0 and index<=total then
		local nodeSize=node.rootVar:getSize()
		local scrollContainerSize = self:getContainerSize()
		local widthProportion = scrollContainerSize.width/nodeSize.width
		
		node.rootVar:setSizeType(ccui.SizeType.absolute)
		node.rootVar:setContentSize(nodeSize.width*widthProportion, nodeSize.height*widthProportion)
		
		node.rootVar:setPositionInScroll(self, scrollContainerSize.width/2, 0)--这里只需要管x，y在update的时候会搞好的
		self:addChildAndAnis(node)
		table.insert(self.child, index, node)
		local insertPos = 0
		local needInsert = false
		local lastV = nil
		for i,v in ipairs(self.itemLayoutType) do
			if v.index == index then
				if v.type == ITEM_LAYOUT_GRID then
					if lastV == nil or lastV.type == ITEM_LAYOUT_GRID then
						needInsert = true
						insertPos = i
					end
					v.index = v.index + 1
				end
			elseif v.index > index then
				assert(lastV ~= nil, "insertChildToIndex(lastV ~= nil)")
				--v.index第一个肯定是1，如果插入第一行（列），那么就是v，那么就是v.index==index，如果不是第一行（列），那么肯定有lastV
				if lastV.index < index then
					assert(lastV.type == ITEM_LAYOUT_ITEM, "insertChildToIndex(lastV.t == 0)")
					--如果lastV.type是Grid，v.index>index，也就意味着这个item要插在一堆Grid中间
				end
				--v.a = v.a + 1
			end
			lastV = v
		end

		if needInsert then
			table.insert(self.itemLayoutType, insertPos, {index = index, type = ITEM_LAYOUT_ITEM})
		end
	else
		self:addItem(node)
	end
	self:update()
end

function UIScrollList:getChildAtIndex(index)
	if index>self:getChildrenCount() or index <= 0 then
		return
	else
		return self.child[index]
	end
end

function UIScrollList:removeChildAtIndex(index)
	local childCount = self:getChildrenCount()
	if index > childCount or index <= 0 then
		return
	end
	local indexSizeHeight = self.child[index].rootVar:getSizeInScroll(self).height
	self:removeChild(self.child[index].root, true)
	table.remove(self.child, index)
	if index ~= childCount then
		for i,v in pairs(self.child) do
			if i>=index then
				local posInScroll = v.rootVar:getPositionInScroll(self)
				v.rootVar:setPositionInScroll(self, posInScroll.x, posInScroll.y+indexSizeHeight)
			end
		end
	end
	local height = 0
	for i,v in ipairs(self.child) do
		height = height + v.rootVar:getSizeInScroll(self).height
	end
	local contentHeight = self:getContentSize().height
	self:setContainerSize(self:getContainerSize().width, height<contentHeight and contentHeight or height)
	
	for i,v in ipairs(self.itemLayoutType) do
		if v.index == index then
			--assert(v.type ~= 1, "")--先按照不能删除GRID来做
			--好吧，GRID也能删除，不过要注意，一定要整个GRID块都删除，如果删除单个，位置会有问题
			--其实之前的代码，GRID也可以删除单个（除了第一个），但是后面的item位置会有问题
			if self.itemLayoutType[i+1] ~= nil then
				if self.itemLayoutType[i+1].index == index + 1 then
					self.itemLayoutType[i+1].index = index
					table.remove(self.itemLayoutType, i)
				end
			else
				if #self.child < index then
					table.remove(self.itemLayoutType, i)
				end
			end
		elseif v.index > index then
			v.index = v.index - 1
		end
	end
	self:update()
end

function UIScrollList:getAllChildren()
	return self.child
end

function UIScrollList:getChildrenCount()
	return self.ccNode_:getChildrenCount()
end

function UIScrollList:addEventListener(cb)
	self.ccNode_:addEventListener(cb)
end

function UIScrollList:stateToNoSlip()
	self.direction = self:getDirection()~=0 and self:getDirection() or self.direction
	self:setDirection(0)
end

function UIScrollList:stateToSlip()
	if self.direction then
		self:setDirection(self.direction)
	end
end

function UIScrollList:startRollAction(nodePath, text)
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
	end
	self:removeAllChildren()
	local node = require(nodePath)()
	node.vars.text:setText(text)
	
	local width = self:getContainerSize().width
	local height = self:getContainerSize().height
	
	local nodeSize = node.rootVar:getSize()
	
	local pos1 = {x= nodeSize.width/2, y = height/2}
	local pos2 = {x= width+nodeSize.width/2, y = height/2}
	
	
	node.rootVar:setSizeType(ccui.SizeType.absolute)
	node.rootVar:setContentSize(nodeSize.width, nodeSize.height)
	node.rootVar:setPositionInScroll(self, pos1.x, pos1.y)
	
	table.insert(self.itemLayoutType, {index = 0, type = ITEM_LAYOUT_ITEM})
	self:addChild(node)
	
	local function roll(dTime)
		local nowPos = node.rootVar:getPositionInScroll(self)
		node.rootVar:setPositionInScroll(self, nowPos.x-3, nowPos.y)
		if nowPos.x<=pos1.x-nodeSize.width then
			node.rootVar:setPositionInScroll(self, pos2.x, pos2.y)
		end
	end
	self._sc=cc.Director:getInstance():getScheduler():scheduleScriptFunc(roll, 0, false)
end

function UIScrollList:stopRollAction()
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil;
	end
end

function UIScrollList:stopChildAnis(node)
	if node.anis then
		for _,t in pairs(node.anis) do
			if t.stop then
				t.stop()
			elseif t.quit then
				t.quit()
			end
		end
	end
end

function UIScrollList:addChildAndAnis(node)
	self.ccNode_:addChild(node.root, 1)
	if node.anis and node.anis.c_dakai then
		node.anis.c_dakai.play()
	end
end

function UIScrollList:update()
	if #self.child == 0 then
		return
	end
	local totalHeight = 0
	local totalWidth = 0
	
	local currentLayout = self.itemLayoutType[1]
	assert(currentLayout ~= nil, "update(currentLayout ~= nil)")
	self.nextLayoutTypeIndex = 2
	self.nextLayoutTypeChildIndex = 0
	
	function setNextLayout(scroll)
		if scroll.itemLayoutType[scroll.nextLayoutTypeIndex] == nil then
			scroll.nextLayoutTypeIndex = nil
			scroll.nextLayoutTypeChildIndex = #scroll.child + 1
		else
			scroll.nextLayoutTypeChildIndex = scroll.itemLayoutType[scroll.nextLayoutTypeIndex].index
		end
	end
	
	setNextLayout(self)
	
	local lineindex = 0
	--格子布局，默认为所有的格子大小一样
	for i,v in ipairs(self.child) do
		if i == self.nextLayoutTypeChildIndex then
			currentLayout = self.itemLayoutType[self.nextLayoutTypeIndex]
			self.nextLayoutTypeIndex = self.nextLayoutTypeIndex + 1
			lineindex = 0
			setNextLayout(self)
		end
		if currentLayout.type == ITEM_LAYOUT_GRID then
			lineindex = lineindex % currentLayout.length
			if lineindex == 0 then
				local nodeSize = v.rootVar:getContentSize()
				if self._horizontal then
					totalWidth = totalWidth + nodeSize.width
				else
					totalHeight = totalHeight + nodeSize.height
				end
			end
			lineindex = lineindex + 1
		else
			local nodeSize = v.rootVar:getContentSize()
			totalWidth = totalWidth + nodeSize.width
			totalHeight = totalHeight + nodeSize.height
		end
	end
	
	local scrollContainerSize = self:getContainerSize()
	if self._horizontal then
		scrollContainerSize.width = totalWidth
	else
		scrollContainerSize.height = totalHeight
	end
	self:setContainerSize(scrollContainerSize.width, scrollContainerSize.height)
	local containerSize = self:getContainerSize()
	
	totalHeight = containerSize.height	--这里不能用scrollContainerSize.height，也不能不改，因为有可能里面的内容没有填满
	local horizontalStep = 0
	local horizontalStepSign = 1
	if self._horizontal then
		if (self.align == nil or self.align == g_UIScrollList_HORZ_ALIGN_CENTER) then
			if totalWidth < containerSize.width then
				if #self.itemLayoutType == 1 then	--目前只支持非混合的Scroll面板支持水平滚动如果内容不宽则水平分布
					local itemPerLine = 1
					if self.itemLayoutType[1].type == ITEM_LAYOUT_GRID then
						itemPerLine = self.itemLayoutType[1].length
					end
					horizontalStep = containerSize.width / math.ceil(#self.child / itemPerLine)
					totalWidth = horizontalStep / 2 --这时候，totalWidth是以item的中间为锚点，557行的相关注释不准确了
				else
					totalWidth = (containerSize.width - totalWidth) / 2	
				end
			else
				totalWidth = 0
			end
		elseif self.align == g_UIScrollList_HORZ_ALIGN_RIGHT then
			horizontalStepSign = -1
			if totalWidth < containerSize.width then
				totalWidth = containerSize.width
			end
		elseif self.align == g_UIScrollList_HORZ_ALIGN_NARROW_CENTER then
			if totalWidth < containerSize.width then
				totalWidth = (containerSize.width - totalWidth) / 2
			else
				totalWidth = 0
			end
		else
			totalWidth = 0
		end
	end
	--往后totalHeight和totalWidth表示下一行（列）的位置，currentY和currentX表示当前行（列）的位置（以item的左下角为锚点）
	local currentY = totalHeight
	local currentX = totalWidth
	--currentX Y只在Grid模式下使用，因为totalWidth和totalHeight要在每行第一格的时候就计算好，防止一行不满的情况，但是当前行的位置不能变
	
	currentLayout = self.itemLayoutType[1]
	self.nextLayoutTypeIndex = 2
	setNextLayout(self)
	lineindex = 0
	
	for i,v in ipairs(self.child) do
		local var = v.rootVar
		local nodeSize = var:getContentSize()
		local width = nodeSize.width
		local height = nodeSize.height
		
		if i == self.nextLayoutTypeChildIndex then
			currentLayout = self.itemLayoutType[self.nextLayoutTypeIndex]
			self.nextLayoutTypeIndex = self.nextLayoutTypeIndex + 1
			lineindex = 0
			setNextLayout(self)
		end
		
		var:setSizeType(ccui.SizeType.absolute)
		var:setContentSize(width, height)
		
		local pos = var:getPosition()
		
		if currentLayout.type == ITEM_LAYOUT_GRID then
			lineindex = lineindex % currentLayout.length
			if lineindex == 0 then
				if self._horizontal then
					currentX = totalWidth
					totalWidth = totalWidth + (horizontalStep == 0 and width * horizontalStepSign or horizontalStep)
				else
					currentY = totalHeight
					totalHeight = totalHeight - height
				end
			end
			lineindex = lineindex + 1
			if self._horizontal then
				var:setPositionInScroll(self, currentX + (horizontalStep == 0 and width * horizontalStepSign / 2 or 0), pos.y)
			else
				var:setPositionInScroll(self, pos.x, currentY - height / 2)
			end
		else
			if self._horizontal then
				var:setPositionInScroll(self, totalWidth + (horizontalStep == 0 and width * horizontalStepSign / 2 or 0), pos.y)
				totalWidth = totalWidth + (horizontalStep == 0 and width * horizontalStepSign or horizontalStep)
			else
				var:setPositionInScroll(self, pos.x, totalHeight - height / 2)
				totalHeight = totalHeight - height
			end
		end
	end
	self.nextLayoutTypeChildIndex = nil
	self.nextLayoutTypeIndex = nil
end

function UIScrollList:createProgressView()
	if not self._enableBar then return end
	local containerSize = self:getContainerSize()
	local contentSize = self:getContentSize()
	if self._right == nil then
		self._right = ccui.ImageView:create(i3k_checkPList(self._barImage))
		self._right:setScale9Enabled(true)
		self._right:setAnchorPoint(0.5, 0.5)
		self._right:ignoreContentAdaptWithSize(false)
		self.ccNode_:addDirectChild(self._right)--addDirectChild将node加在layout上而不是innerContainer上
	end
	self._right:setContentSize(cc.size(SCROLL_BAR_WIDTH, contentSize.height-6))
	self._right:setPosition(cc.p(contentSize.width-SCROLL_BAR_WIDTH / 2, contentSize.height-self._right:getContentSize().height/2))
	if self._rightTopImage == nil then
		self._rightTopImage = ccui.ImageView:create(i3k_checkPList(self._ballImage))
		self._rightTopImage:setScale9Enabled(true)
		self._rightTopImage:setAnchorPoint(0.5, 0.5)
		self._rightTopImage:ignoreContentAdaptWithSize(false)
		self.ccNode_:addDirectChild(self._rightTopImage)
	end
	local rightHeight = self._right:getContentSize().height
	self._rightTopImage:setContentSize(cc.size(SCROLL_BAR_WIDTH, rightHeight*contentSize.height/containerSize.height))
	self._rightTopImage:setPosition(self._right:getPositionX(), self._right:getPositionY()+rightHeight/2-self._rightTopImage:getContentSize().height/2)
	self._rightTopImage:setOpacity(150)
	
	self:updateProgressView()
	
	local fadeout = cc.FadeOut:create(1)
	self._right:runAction(fadeout)
	local fadeout = cc.FadeOut:create(1)
	self._rightTopImage:runAction(fadeout)
	if containerSize.height <= contentSize.height then
		self._right:setVisible(false)
		self._rightTopImage:setVisible(false)
	else
		self._right:setVisible(true)
		self._rightTopImage:setVisible(true)
	end
	
end

function UIScrollList:updateProgressView()
	
	if self._right and self._rightTopImage then
		self._right:setOpacity(255)
		self._rightTopImage:setOpacity(255)
		
		local percent = self:getListPercent()
		local rightPosY = {}
		rightPosY.bottom = self._right:getPositionY()-self._right:getContentSize().height/2
		rightPosY.top = self._right:getPositionY()+self._right:getContentSize().height/2
		
		local rightTopImagePosY = {}
		rightTopImagePosY.max = rightPosY.top - self._rightTopImage:getContentSize().height/2
		rightTopImagePosY.min = rightPosY.bottom + self._rightTopImage:getContentSize().height/2
		
		local distanceBetweenMaxAndMin = rightTopImagePosY.max - rightTopImagePosY.min
		
		self._rightTopImage:setPosition(self._rightTopImage:getPositionX(), rightTopImagePosY.max-distanceBetweenMaxAndMin*percent/100)
		
		self._right:stopAllActions()
		self._rightTopImage:stopAllActions()
		
		local fadeout = cc.FadeOut:create(0.5)
		self._right:runAction(fadeout)
		local fadeout = cc.FadeOut:create(0.5)
		self._rightTopImage:runAction(fadeout)
		
	else
		
	end
end

--开始以为没有插入功能，所以目前只有上拉刷新
function UIScrollList:setLoadEvent(callback, path)
	self._loadEvent = callback
	self._updateEventPath = path
	self._setLoadEvent = true
	self:checkAddEventListener();
end

function UIScrollList:cancelLoadEvent()
	self._loadEvent = nil
	self._updateEventPath = nil
	self._setLoadEvent = nil
end

function UIScrollList:checkAddEventListener()
	if self._hasAddEventListener then
		return
	end
	self._hasAddEventListener = true
	self:addEventListener(function(sender, eventType)
		self:eventCallback(sender, eventType)
	end)
end

function UIScrollList:onScrollEvent(hoster, cb, arg)
	self._scrollEvent = { hoster = hoster, cb = cb, arg = arg}
	self:checkAddEventListener()
end

--[[
eventType有可能是如下值：
ccui.ScrollviewEventType.scrollToTop
ccui.ScrollviewEventType.scrollToBottom
ccui.ScrollviewEventType.scrollToLeft
ccui.ScrollviewEventType.scrollToRight
ccui.ScrollviewEventType.scrolling
ccui.ScrollviewEventType.bounceTop
ccui.ScrollviewEventType.bounceBottom
ccui.ScrollviewEventType.bounceLeft
ccui.ScrollviewEventType.bounceRight
]]

function UIScrollList:eventCallback(sender, eventType)
	if self.needUpdateProgressVies == true then
		self:updateProgressView()
	end
	
	if self._scrollEvent then
		self._scrollEvent.cb(self._scrollEvent.hoster, sender, eventType, self._scrollEvent.arg)
	end
	
	if not self._setLoadEvent or self._LoadEventCallbacking ~= nil then
		return
	end
	
	local scroll_to_bottom = false
	local bounce_bottom = false
	if self._horizontal then
		if eventType == ccui.ScrollviewEventType.scrollToRight then
			scroll_to_bottom = true
		elseif eventType == ccui.ScrollviewEventType.bounceRight then
			bounce_bottom = true
		end
	else
		if eventType == ccui.ScrollviewEventType.scrollToBottom then
			scroll_to_bottom = true
		elseif eventType == ccui.ScrollviewEventType.bounceBottom then
			bounce_bottom = true
		end
	end
	if scroll_to_bottom and not self._isShowingAdd then
		self._isShowingAdd = true
		if self._updateEventPath then
			local node = require(self._updateEventPath)()
			self:addItem(node)
			self._ShowingAddNodeIndex = #self.child
		end
	end
	if bounce_bottom and self._isShowingAdd then
		self._LoadEventCallbacking = true
		self._isShowingAdd = nil
		if self._ShowingAddNodeIndex then
			self:removeChildAtIndex(self._ShowingAddNodeIndex)
		end
		self._loadEvent()
		self._LoadEventCallbacking = nil
	end
end

return UIScrollList

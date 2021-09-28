local AutoScrollView = class("AutoScrollView",function() 
	-- return display.newNode()
	return Widget:create()
	end)

local DIR_LEFT = 1    ---1 表示向左滑,2表示向右滑
local DIR_RIGHT = 2
function AutoScrollView.create(size,listData,leftNode,middleNode,rightNode)
	local widget = AutoScrollView.new(listData,leftNode,middleNode,rightNode)
	widget:setContentSize(CCSizeMake(size.width,size.height))
	return widget
end


function AutoScrollView:ctor(listData,leftNode,middleNode,rightNode,...)
	self.leftNode = leftNode   --三个子控件
	self.middleNode = middleNode
	self.rightNode = rightNode

	self:addChild(leftNode)
	self:addChild(middleNode)
	self:addChild(rightNode)
	self.leftNode:updatePage(listData[1])
	self.middleNode:updatePage(listData[2])
	self.rightNode:updatePage(listData[3])

	self._contentSize = nil
	self.listData = listData  -- 数据
	self.length = #listData   --长度
	self.timer = nil
	self.currentX = self:getWidth()/2;   --记录当前位置
	self.currentIndex = 1;  --当前的child index
	self.direction = DIR_LEFT;  -- 滑动方向
	self.diffX = 4  --每一帧率划过的像素 
	self._isPause = false --是否暂停
	self:setChildPosition()

	self:start()
end



function AutoScrollView:getWidth()
	-- return self:getContentSize().width
	return 516
end

function AutoScrollView:getHeight()
	return 440
end

function AutoScrollView:start()
	self.timer = GlobalFunc.addTimer(1/45, handler(self,self.autoScroll))
end

function AutoScrollView:autoScroll()
	if self._isPause == ture then
		return
	end
	if self.direction == DIR_LEFT  then
		self:toleft()
	else
		self:toright()
	end
end
---  <<-------------------------
function AutoScrollView:toleft()
	self.currentX = self.currentX - self.diffX
	if self:checkRightEnd() then  --滑到头了
		self.direction = DIR_RIGHT    --改变方向
	elseif self:checkStartLoadRight() then
		self:loadRightNode()
	end
	self:setChildPosition()
end


---   ---------------------->>
function AutoScrollView:toright()
	self.currentX = self.currentX + self.diffX
	if self:checkLeftEnd()  then   --滑到头了
		self.direction = DIR_LEFT     --改变方向
	elseif self:checkStartLoadLeft() then
		--移除最右边的一个child,并开始load
		self:loadLeftNode()
	end
	self:setChildPosition()
end

function AutoScrollView:loadLeftNode()
	--最右边的节点移到最左边去
	local tempNode = self.rightNode
	self.rightNode = self.middleNode
	self.middleNode = self.leftNode
	self.leftNode = tempNode   --交换顺序
	self.currentIndex = self.currentIndex - 1
	--刷新左边一个
	if self.listData[self.currentIndex] ~= nil then
		self.leftNode:updatePage(self.listData[self.currentIndex])
	end
	self.currentX = self.currentX - self:getWidth()
end

function AutoScrollView:loadRightNode()
	--最左边的child移到最右边去
	local tempNode = self.leftNode
	self.leftNode = self.middleNode
	self.middleNode = self.rightNode
	self.rightNode = tempNode   --交换顺序
	self.currentIndex = self.currentIndex + 1
	--刷新最右边一个
	if self.listData[self.currentIndex+2] ~= nil then
		self.rightNode:updatePage( self.listData[self.currentIndex+2])

	end 
	self.currentX = self.currentX + self:getWidth()
end


--往右滑时是否话到最左边一个了
function AutoScrollView:checkLeftEnd()
	return self.currentX >= self:getWidth()/2 and self.currentIndex == 1 
end

function AutoScrollView:checkRightEnd()
	return self.currentX <= self:getWidth()/2 and self.currentIndex == #self.listData 
end

--检查是否可以加载了
function AutoScrollView:checkStartLoadLeft()   
	return self.currentX >= self:getWidth()/2 and self.currentIndex ~= 1
end

function AutoScrollView:checkStartLoadRight()
	return self.currentX <= -self:getWidth()/2 and self.currentIndex ~= #self.listData
end



function AutoScrollView:stop()
	if self.timer ~= nil then
		GlobalFunc.removeTimer(self.timer)
		self.timer = nil
	end
end

function AutoScrollView:pause()
	self._isPause = true
end

function AutoScrollView:restart()
	self._isPause = false
end

function AutoScrollView:setChildPosition()
	local width = self:getWidth()
	local height = self:getHeight()
	self.leftNode:setPosition(ccp(self.currentX,height/2))
	self.middleNode:setPosition(ccp(self.currentX+self:getWidth(),height/2))
	self.rightNode:setPosition(ccp(self.currentX+self:getWidth()*2,height/2))
end


return AutoScrollView
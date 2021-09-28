local scroll = class("an.scroll", function ()
	return display.newNode()
end)

table.merge(slot0, {
	scrollView,
	labelM
})

scroll.ctor = function (self, x, y, w, h, params)
	params = params or {}
	self.scrollView = cc.ui.UIScrollView.new({
		viewRect = cc.rect(0, 0, w, h),
		direction = params.dir or 1
	}):addScrollNode(display.newNode():anchor(0, 1))

	getmetatable(self).addChild(self, self.scrollView, 0, 0)
	self.pos(self, x, y):size(w, h)

	if params.labelM then
		local labelMParams = params.labelM.params or {}
		labelMParams.scroll = self
		self.labelM = an.newLabelM(w, params.labelM[1], params.labelM[2], labelMParams):addto(self)
	end

	self.setScrollSize(self, 0, 0)
	self.setScrollOffset(self, 0, 0)

	return 
end
scroll.addChild = function (self, child, zorder, tag)
	if self.scrollView.scrollNode then
		self.scrollView.scrollNode:add(child, zorder, tag)
	end

	return 
end
scroll.removeAllChildren = function (self)
	self.scrollView.scrollNode:removeAllChildren()

	return 
end
scroll.setScrollOffset = function (self, x, y)
	if not self.scrollView.scrollNode then
		return 
	end

	self.scrollView.scrollNode:pos(x, self.scrollView:getViewRect().height + y)

	return 
end
scroll.getScrollOffset = function (self)
	local x, y = self.scrollView.scrollNode:getPosition()

	return x, y - self.scrollView:getViewRect().height
end
scroll.setScrollSize = function (self, width, height)
	if not self.scrollView.scrollNode then
		return 
	end

	if width < self.scrollView:getViewRect().width then
		width = self.scrollView:getViewRect().width or width
	end

	if height < self.scrollView:getViewRect().height then
		height = self.scrollView:getViewRect().height or height
	end

	self.scrollView.scrollNode:size(width, height)

	return 
end
scroll.getScrollSize = function (self)
	if not self.scrollView.scrollNode then
		return cc.size(0, 0)
	end

	return self.scrollView.scrollNode:getContentSize()
end
scroll.enableTouch = function (self, isEnable)
	self.scrollView.scrollNode:setTouchEnabled(isEnable)
	self.scrollView.touchNode_:setTouchEnabled(isEnable)

	return self
end
scroll.setListenner = function (self, listener)
	self.scrollView:onScroll(listener)

	return 
end

return scroll

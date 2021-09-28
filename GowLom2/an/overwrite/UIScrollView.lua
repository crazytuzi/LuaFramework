local UIScrollView = cc.ui.UIScrollView
UIScrollView.new2 = function (rect, direction)
	direction = direction or cc.ui.UIScrollView.DIRECTION_VERTICAL
	local scroll = cc.ui.UIScrollView.new({
		viewRect = rect,
		direction = direction
	})

	scroll.addScrollNode(scroll, display.newNode():anchor(0, 1))
	scroll.setContentSize(scroll, 0, 0)

	return scroll
end
UIScrollView.setContentOffset = function (self, x, y)
	if not self.scrollNode then
		return 
	end

	self.scrollNode:pos(self.getViewRect(self).x - x, (self.getViewRect(self).y + self.getViewRect(self).height) - y)

	return 
end
UIScrollView.setContentSize = function (self, width, height)
	if not self.scrollNode then
		return 
	end

	if width < self.getViewRect(self).width then
		width = self.getViewRect(self).width or width
	end

	if height < self.getViewRect(self).height then
		height = self.getViewRect(self).height or height
	end

	self.scrollNode:size(width, height)
	self.setContentOffset(self, 0, 0)

	return 
end
UIScrollView.getContentSize = function (self)
	if not self.scrollNode then
		return cc.size(0, 0)
	end

	return self.scrollNode:getContentSize()
end
UIScrollView.view = function (self)
	return self.scrollNode
end

return 

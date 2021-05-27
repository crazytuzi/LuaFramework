ScrollTabbar = ScrollTabbar or BaseClass(Tabbar)
function ScrollTabbar:__init()
	self.off_y = 0
	self.off_x = 0
	self.end_select = true
	self.space_interval_V = 10
end

function ScrollTabbar:__delete()

end

function ScrollTabbar:CreateWithNameList(scroll_view, x, y, callback, name_list, is_vertical, def_path, font_size)
	scroll_view:getInnerContainer():addChild(self.view, 999, 999)
	self.scroll_view = scroll_view
	self.view:setPosition(x, y)
	self.off_x = x
	self.off_y = y
	self.font_size = font_size or self.font_size
	self.radio_button:SetSelectCallback(callback)
	self:SetNameList(name_list, is_vertical, def_path)
end

function ScrollTabbar:CreateWithPathList(scroll_view, x, y, callback, path_list, is_vertical)
	scroll_view:getInnerContainer():addChild(self.view, 999, 999)
	self.scroll_view = scroll_view
	self.view:setPosition(x, y)
	self.radio_button:SetSelectCallback(callback)
	self:SetPathList(path_list, is_vertical, def_path)
end

function ScrollTabbar:UpdatePosition()
	Tabbar.UpdatePosition(self)
	local visible_count = 0
	local btn_size = nil
	for k, v in ipairs(self.radio_button:GetToggleList()) do
		if nil == btn_size then
			btn_size = v:getContentSize()
		end
		if v:isVisible() then
			visible_count = visible_count + 1
		end
	end
	if self.scroll_view and btn_size then
		if self.is_vertical then
			local content_size = self.scroll_view:getContentSize()
			local height = visible_count * (btn_size.height + self.space_interval) - self.space_interval
			local inner_size = cc.size(content_size.width, height)
			self.scroll_view:setInnerContainerSize(inner_size)
			self.scroll_view:jumpToTop()
			local tabbar_y = height > content_size.height and height or content_size.height
			self.view:setPositionY(tabbar_y + self.off_y)
			self.scroll_view:jumpToTop()
		else
			local content_size = self.scroll_view:getContentSize()
			local width = visible_count * (btn_size.width + self.space_interval) - self.space_interval
			local inner_size = cc.size(width, content_size.height)
			self.scroll_view:setInnerContainerSize(inner_size)
			self.scroll_view:jumpToTop()
			self.view:setPositionX(0)
			self.scroll_view:jumpToLeft()
		end
	end
end
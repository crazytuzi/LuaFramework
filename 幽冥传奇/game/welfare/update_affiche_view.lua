-- 更新公告
local WelfareUpdateView = BaseClass(SubView)

function WelfareUpdateView:__init()
	self.texture_path_list = {
		'res/xui/welfare.png',
	}
	self.config_tab = {
		{"welfare_ui_cfg", 8, {0}},
	}
end

function WelfareUpdateView:__delete()
	-- body
end

function WelfareUpdateView:LoadCallBack(index, loaded_times)
	local scroll_node = self.node_t_list.scroll_text_content.node

	local rich_content = XUI.CreateRichText(30, 10, 660, 0, false)
	scroll_node:addChild(rich_content, 100, 100)
	HtmlTextUtil.SetString(rich_content, WelfareData.AfficheContent)
	rich_content:refreshView()


	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:jumpToTop()
end

function WelfareUpdateView:DeleteUpdateAfficheView()
end

function WelfareUpdateView:OnFlushUpdateAfficheView()
	
end

return WelfareUpdateView
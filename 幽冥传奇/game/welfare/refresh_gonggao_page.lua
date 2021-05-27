GongGaoPage = GongGaoPage or BaseClass()

function GongGaoPage:__init()
	self.view = nil
end

function GongGaoPage:__delete()
	self:RemoveEvent()
	
	self.view = nil
end

function GongGaoPage:InitPage(view)
	self.view = view
	self.view.node_t_list["txt_name"].node:setString(Language.Welfare.Title_name)
	local scroll_node = self.view.node_t_list["rich_content"].node
	local rich_content = XUI.CreateRichText(50, 0, 640, 0, false)
	scroll_node:addChild(rich_content, 100, 100)
	HtmlTextUtil.SetString(rich_content, Language.Welfare.Desc or "")
	rich_content:refreshView()
	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end

function GongGaoPage:InitEvent()
	
end

function GongGaoPage:RemoveEvent()

end


--更新视图界面
function GongGaoPage:UpdateData(data)
	
end	


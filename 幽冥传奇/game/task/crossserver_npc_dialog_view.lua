CrossserverNpcDialogView = CrossserverNpcDialogView or BaseClass(XuiBaseView)

local radio_height = 40

function CrossserverNpcDialogView:__init()
	self.is_any_click_close = true

	self.texture_path_list[1] = 'res/xui/npc_dialog.png'
	self.texture_path_list[2] = 'res/xui/charge.png'
	self.config_tab = {
		{"npc_dialog_ui_cfg", 3, {0}},
	}

	self.npc_obj_id = 0
	self.rich_content = nil
end

function CrossserverNpcDialogView:__delete()

end

function CrossserverNpcDialogView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self.node_t_list["text_title"].node:setString(Language.CrossServerMatch.NpcName)
		local scroll_node = self.node_t_list["rich_content"].node
		local rich_content = XUI.CreateRichText(50, 0, 640, 0, false)
		scroll_node:addChild(rich_content, 100, 100)
		rich_content:refreshView()
		RichTextUtil.ParseRichText(rich_content, Language.CrossServerMatch.Desc)
		local scroll_size = scroll_node:getContentSize()
		local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
		scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
		rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
		scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
	end
	-- local content = string.format(Language.WangChengZhengBa.Rule_Content[1])
	-- self.node_t_list.text_title.node:setString(Language.CrossServerMatch.NpcName)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_content.node, content)
end

function CrossserverNpcDialogView:ReleaseCallBack()
	
end

function CrossserverNpcDialogView:OnFlush()
	
end
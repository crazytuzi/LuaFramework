
StoryDialog = StoryDialog or BaseClass(XuiBaseView)

function StoryDialog:__init()
	if StoryDialog.Instance then
		ErrorLog("[StoryDialog] Attemp to create a singleton twice !")
	end
	StoryDialog.Instance = self
	self.texture_path_list[1] = 'res/xui/story.png'
	self.head_pic_right = true
	self.zorder = COMMON_CONSTS.ZORDER_GUIDE
end

function StoryDialog:__delete()
end

function StoryDialog:ReleaseCallBack()
	self.head_pic_right = true
	self.head_pic = nil
end

function StoryDialog:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.root_node:setContentSize(cc.size(screen_w, screen_h))
		self.root_node:setPosition(0, 0)
		self.root_node:setAnchorPoint(0,0)
		self.root_node:setTouchEnabled(true)
		XUI.AddClickEventListener(self.root_node, BindTool.Bind1(self.ClickHandler, self))

		self.head_pic = XUI.CreateImageView(screen_w / 6 * 5, 300, ResPath.GetNpcPic("1_0_1"), false)
		self.root_node:addChild(self.head_pic)

		local txt_bg = XUI.CreateImageViewScale9(screen_w / 2, 125, screen_w, 160, ResPath.GetStory("dialog_bg"), true, cc.rect(170, 13, 80, 30))
		self.root_node:addChild(txt_bg)

		self.story_content = RichTextUtil.ParseRichText(nil, "", 24, cc.c3b(0xcc, 0xbf, 0xae), screen_w / 6 * 1, 50, screen_w / 2 - 100, 120)
		self.story_content:setAnchorPoint(0, 0)
		self.root_node:addChild(self.story_content)

		self.layout_goon = XUI.CreateLayout(screen_w / 4 * 3, 80, 150, 100)
		self.root_node:addChild(self.layout_goon)

		local goon_txt = XUI.CreateText(0, 50, 120, 24, nil, Language.Common.ClickGoon, nil, 24, COLOR3B.GREEN)
		self.layout_goon:addChild(goon_txt)

		local goon_img = XUI.CreateImageView(100, 50, ResPath.GetStory("goon_btn"), true)
		self.layout_goon:addChild(goon_img)

		XUI.AddClickEventListener(self.layout_goon, BindTool.Bind1(self.ClickHandler, self))

		self.skip_btn = XUI.CreateButton(screen_w - 150, screen_h - 120, 0, 0, false, ResPath.GetStory("skip_btn"), "", "", true)
		self.root_node:addChild(self.skip_btn)
		self.skip_btn:addClickEventListener(BindTool.Bind1(self.SkipHandler, self))
		self.skip_btn:setVisible(false)

		local layout_bottom = XUI.CreateLayout(screen_w / 2, 25, screen_w, 50)
		layout_bottom:setBackGroundColor(COLOR3B.BLACK)
		self.root_node:addChild(layout_bottom)

		local layout_top = XUI.CreateLayout(screen_w / 2, screen_h - 25, screen_w, 50)
		layout_top:setBackGroundColor(COLOR3B.BLACK)
		self.root_node:addChild(layout_top)
	end
end

function StoryDialog:CloseCallBack()
	if nil ~= self.head_pic then
		self.head_pic:setVisible(false)
	end
	if nil ~= self.story_content then
		self.story_content:setVisible(false)
	end
end

function StoryDialog:OnFlush(param_t, index)
	RichTextUtil.ParseRichText(self.story_content, self.content, 24, cc.c3b(0xcc, 0xbf, 0xae))
	self.story_content:setVisible(true)
	local path = ResPath.GetNpcPic(self.actor_id)
	self.head_pic:setVisible(true)
	self.head_pic:loadTexture(path, false)
	local x, y = self.head_pic:getPosition()
	local screen_w = HandleRenderUnit:GetWidth()
	self.head_pic:setPosition(self.head_pic_right and screen_w / 6 * 5 or screen_w / 6 * 1, y)
end

function StoryDialog:SetSkipBtnVisible(is_visible)
	self.is_visible = is_visible
	self:Flush()
end

function StoryDialog:DoDialog(actor_id, content, dialog_end_callback, skip_call_back)
	self.actor_id = actor_id
	self:ParseDialogContent(content)
	self.dialog_end_callback = dialog_end_callback
	self.skip_call_back = skip_call_back
	if self.old_actor_id and self.old_actor_id ~= self.actor_id then
		self.head_pic_right = not self.head_pic_right
	end
	self.old_actor_id = self.actor_id
	self:Flush()
end

function StoryDialog:ParseDialogContent(content)
	local main_role_name = RoleData.Instance:GetAttr("name") or ""
	self.content = string.gsub(content, "main_role_name", main_role_name)
end

function StoryDialog:SkipHandler()
	self:Close()
	if self.skip_call_back ~= nil then
		self.skip_call_back()
	end
end

function StoryDialog:ClickHandler()
	self:Close()
	if self.dialog_end_callback ~= nil then
		self.dialog_end_callback()
	end
end
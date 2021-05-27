
HelpView = HelpView or BaseClass(BaseView)
function HelpView:__init()
	self.title_img_path = ResPath.GetWord("word_help")

	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.def_index = 1

	--self.texture_path_list[1] = "res/xui/activity.png"

	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"help_ui_cfg", 2, {0}},
		{"help_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
end

function HelpView:__delete()
end

function HelpView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	if self.help_list_view then
		self.help_list_view:DeleteMe()
		self.help_list_view = nil
	end
end

function HelpView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:InitTabbar()
		self:CreateHelpList()
		XUI.RichTextSetCenter(self.node_t_list.rich_gm_opentime.node)
	end
end

function HelpView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = ScrollTabbar.New()
		self.tabbar:SetSpaceInterval(6)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 8, -3,
			BindTool.Bind1(self.SelectTabCallback, self), HelpData.GetHelpNameList(), 
			true, ResPath.GetCommon("toggle_120"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	end
end

function HelpView:SelectTabCallback(index)
	self:ChangeToIndex(index)
end

--创建右边列表
function HelpView:CreateHelpList()
	local ph = self.ph_list.ph_list
	self.help_list_view = ListView.New()
	self.help_list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, HelpListItem, gravity, bounce, self.ph_list.ph_list_item)
	self.node_t_list["layout_help"].node:addChild(self.help_list_view:GetView(), 99)
	self.help_list_view:SetItemsInterval(2)
	self.help_list_view:SetMargin(2)
	self.help_list_view:SetJumpDirection(ListView.Top)
end

function HelpView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index)
	-- self.node_t_list.img_top_bg.node:loadTexture(ResPath.GetBigPainting("help_bg_" .. index), true)
	self:Flush(index)
end
	
function HelpView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HelpView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HelpView:OnFlush(param_t, index)
	local cur_index = self:GetShowIndex()
	local list = HelpData.GetHelpListByType(cur_index)
	self.help_list_view:SetDataList(list)
	local time_info = HelpData.Instance:GetOpenServerInfo()
	self.node_t_list.rich_gm_opentime.node:setVisible(false)--time_info.gm_level > 0)
	if time_info.gm_level > 0 then
		local str = os.date("%Y-%m-%d", time_info.open_server_time) .. " " .. os.date("%X", time_info.open_server_time)
		RichTextUtil.ParseRichText(self.node_t_list.rich_gm_opentime.node, str)
	end
end

--右边信息列表Item
HelpListItem = HelpListItem or BaseClass(BaseRender)
function HelpListItem:__init()

end

function HelpListItem:__delete()

end

function HelpListItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree["btn_go"].node:addClickEventListener(BindTool.Bind(self.OnClickGoHandler, self))
	self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	XUI.RichTextSetCenter(self.node_tree.rich_star.node)
end

function HelpListItem:OnFlush()
	if nil == self.data then return end	
	self.node_tree["lbl_name"].node:setString(self.data.title)
	self.node_tree["btn_go"].node:setTitleText(self.data.btn_name)
	RichTextUtil.ParseRichText(self.node_tree.rich_star.node, "{star;" .. self.data.star .. ";" .. self.data.star .. "}")
end

function HelpListItem:OnClickGoHandler()
	if self.data.open_view ~= "" then
		ViewManager.Instance:OpenViewByStr(self.data.open_view)
	else
		Scene.SendQuicklyTransportReq(self.data.fly_id)
	end
end
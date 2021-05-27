-- 添加成员
local GuildAddMemberView = GuildAddMemberView or BaseClass(SubView)

function GuildAddMemberView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 4, {0}},
		{"guild_ui_cfg", 9, {0}},
		{"guild_ui_cfg", 18, {0}},
	}
end

function GuildAddMemberView:LoadCallBack()
	self:CreateSearchMemberList()
	self.node_t_list["edit_search_role_name"].node:setPlaceHolder(Language.Society.EditBoxDefContent)
	self.node_t_list["edit_search_role_name"].node:setFontSize(22)
	self.node_t_list["edit_search_role_name"].node:setFontColor(COLOR3B.WHITE)
	XUI.AddClickEventListener(self.node_t_list.btn_search_member.node, BindTool.Bind1(self.OnClickSearchMember, self))
	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.SearchMemberListChange, BindTool.Bind(self.OnFlushAddMemberView, self))
end

function GuildAddMemberView:ReleaseCallBack()
	if self.search_list then
		self.search_list:DeleteMe()
		self.search_list = nil
	end
end

function GuildAddMemberView:ShowIndexCallBack()
	self:OnFlushAddMemberView()
end

function GuildAddMemberView:OnFlushAddMemberView()
	self:ShowSearchList()
end

function GuildAddMemberView:CreateSearchMemberList()
	if self.search_list ~= nil then return end

	local ph = self.ph_list.ph_search_member_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, nil, GuildSearchMemberItem, nil, nil, self.ph_list.ph_search_member_list_item)
	self.node_t_list.layout_guild_add_member.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(1)
	list:SetAutoSupply(true)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)

	self.search_list = list
end

function GuildAddMemberView:ShowSearchList()
	if self.search_list == nil then return end

	local search_list = GuildData.Instance:GetSearchMemberList()
	self.search_list:SetDataList(search_list)
end

function GuildAddMemberView:OnClickSearchMember()
	local search_str = self.node_t_list.edit_search_role_name.node:getText()
	if search_str ~= "" then
		GuildCtrl.SearchGuildQualifiedPlayer(search_str)
	end
end


----------------------------------------------------
-- GuildSearchMemberItem
----------------------------------------------------
GuildSearchMemberItem = GuildSearchMemberItem or BaseClass(BaseRender)

function GuildSearchMemberItem:__init()
end

function GuildSearchMemberItem:__delete()

end

function GuildSearchMemberItem:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_add.node, BindTool.Bind(self.OnClickAdd, self))
end

function GuildSearchMemberItem:OnFlush()
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if self.data == nil or next(self.data) == nil then 
		self.node_tree.lbl_name.node:setString("")
		self.node_tree.lbl_level.node:setString("")
		self.node_tree.lbl_prof.node:setString("")
		self.node_tree.btn_add.node:setVisible(false)
		return
	end
	self.node_tree.btn_add.node:setVisible(true)
	self.node_tree.lbl_name.node:setString(self.data.role_name)
	self.node_tree.lbl_level.node:setString(self.data.level)
	self.node_tree.lbl_prof.node:setString(RoleData.Instance:GetProfNameByType(self.data.prof))
end

function GuildSearchMemberItem:OnClickAdd()
	if self.data and self.data.role_name then
		GuildCtrl.InviteJoinGuildReq(self.data.role_name)
	end
end

function GuildSearchMemberItem:CreateSelectEffect()
	
end

return GuildAddMemberView
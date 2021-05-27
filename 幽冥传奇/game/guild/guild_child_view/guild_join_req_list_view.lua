-- 申请列表
local GuildJoinReqView = GuildJoinReqView or BaseClass(SubView)

function GuildJoinReqView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 4, {0}},
		{"guild_ui_cfg", 9, {0}},
		{"guild_ui_cfg", 17, {0}},
	}
end

function GuildJoinReqView:LoadCallBack()
	self:CreateJoinReqList()

	XUI.AddClickEventListener(self.node_t_list.btn_examine_one_key_add.node, BindTool.Bind2(self.OnClickJoinReqHandleAll, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_examine_one_key_del.node, BindTool.Bind2(self.OnClickJoinReqHandleAll, self, 0))
	XUI.AddClickEventListener(self.node_t_list.layout_guild_autoadd.node, BindTool.Bind(self.OnClickAutoJoinHook, self))
	self.node_t_list.btn_examine_one_key_add.node:setEnabled(false)
	self.node_t_list.btn_examine_one_key_del.node:setEnabled(false)
	self.event_proxy = EventProxy.New(GuildData.Instance, self)

	self.event_proxy:AddEventListener(GuildData.GuildInfoChange, BindTool.Bind(self.OnFlushJoinReqListView, self))
	self.event_proxy:AddEventListener(GuildData.JoinReqListChange, BindTool.Bind(self.OnFlushJoinReqListView, self))
end

function GuildJoinReqView:ReleaseCallBack()
	if self.join_req_list then
		self.join_req_list:DeleteMe()
		self.join_req_list = nil
	end
end

function GuildJoinReqView:ShowIndexCallBack()
	self:OnFlushJoinReqListView()
end

function GuildJoinReqView:OnFlushJoinReqListView()
	self:FlushJoinReqList()
end

function GuildJoinReqView:CreateJoinReqList()
	if self.join_req_list ~= nil then return end

	local ph = self.ph_list.ph_req_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, nil, GuildJoinReqListItem, nil, nil, self.ph_list.ph_req_list_item)
	self.node_t_list.layout_join_req_list.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(1)
	list:SetAutoSupply(true)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)

	self.join_req_list = list

	self.join_handle_result = GuildData.Instance:GetJoinHandleResult()
	self.node_t_list.layout_guild_autoadd.img_guild_hook.node:setVisible(1 == self.join_handle_result)
end

function GuildJoinReqView:FlushJoinReqList()
	if self.join_req_list == nil then return end
	local join_req_data = GuildData.Instance:GetJoinReqList()
	table.sort(join_req_data, SortTools.KeyLowerSorter('level'))

	local is_have_req = next(join_req_data) and true or false
	self.node_t_list.btn_examine_one_key_add.node:setEnabled(is_have_req)
	self.node_t_list.btn_examine_one_key_del.node:setEnabled(is_have_req)

	self.join_req_list:SetDataList(join_req_data)
end

function GuildJoinReqView:OnClickJoinReqHandleAll(result)
	local join_req_data = GuildData.Instance:GetJoinReqList()
	for k,v in ipairs(join_req_data) do
		GuildCtrl.SentGuildAuditingResult(v.obj_id, result, v.role_id)
	end
end

function GuildJoinReqView:OnClickAutoJoinHook()
	local img_hook = self.node_t_list.layout_guild_autoadd.img_guild_hook.node
	local flag = not img_hook:isVisible()
	img_hook:setVisible(flag)
	self.join_handle_result = flag and 1 or 0 
	GuildCtrl.SendJoinHandleResultChange(self.join_handle_result)
end
----------------------------------------------------
-- GuildJoinReqListItem
----------------------------------------------------
GuildJoinReqListItem = GuildJoinReqListItem or BaseClass(BaseRender)

function GuildJoinReqListItem:__init()
end

function GuildJoinReqListItem:__delete()
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
end

function GuildJoinReqListItem:CreateChild()
	BaseRender.CreateChild(self)

	self.layout_name = XUI.CreateLayout(78, 26.5, 156, 25)
	self.view:addChild(self.layout_name, 3)

	self.role_head = RoleHeadCell.New(false, false)
	XUI.AddClickEventListener(self.layout_name, BindTool.Bind1(self.OnClickRoleName, self))
	XUI.AddClickEventListener(self.node_tree.btn_add.node, BindTool.Bind2(self.OnClickHandel, self, 1))
	XUI.AddClickEventListener(self.node_tree.btn_canel.node, BindTool.Bind2(self.OnClickHandel, self, 0))
end

function GuildJoinReqListItem:OnFlush()
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if self.data == nil then 
		self.node_tree.lbl_name.node:setString("")
		self.node_tree.lbl_level.node:setString("")
		self.node_tree.lbl_prof.node:setString("")
		self.node_tree.btn_add.node:setVisible(false)
		self.node_tree.btn_canel.node:setVisible(false)
		return 
	end
	self.node_tree.btn_add.node:setVisible(true)
	self.node_tree.btn_canel.node:setVisible(true)
	self.node_tree.lbl_name.node:setString(self.data.role_name)
	self.node_tree.lbl_level.node:setString(self.data.level)
	self.node_tree.lbl_prof.node:setString(RoleData.Instance:GetProfNameByType(self.data.prof))
	self.role_head:SetRoleInfo(self.data.obj_id, self.data.role_name)
end

function GuildJoinReqListItem:OnClickRoleName()
	self.role_head:OpenMenu()
end

function GuildJoinReqListItem:OnClickHandel(result)
	if self.data ~= nil and next(self.data) then
		GuildCtrl.SentGuildAuditingResult(self.data.obj_id, result, self.data.role_id)
	end
end

function GuildJoinReqListItem:CreateSelectEffect()
	
end

return GuildJoinReqView
-- 行会成员
local GuildMemberView = GuildMemberView or BaseClass(SubView)

function GuildMemberView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 4, {0}},
		{"guild_ui_cfg", 10, {0}},
	}
end

function GuildMemberView:LoadCallBack()
	XUI.AddClickEventListener(self.node_t_list.btn_attack_city.node, BindTool.Bind1(self.ReqAttackCityEvent, self))
	XUI.AddClickEventListener(self.node_t_list.btn_add_member.node, BindTool.Bind1(self.AddMenberEvent, self))
	XUI.AddClickEventListener(self.node_t_list.btn_leave_guild.node, BindTool.Bind1(self.LeaveGuildEvent, self))
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind1(self.OnBtn, self))

	self:CreateCheckBox()

	self:CreateMemberList()
	local guild_data_event_proxy = EventProxy.New(GuildData.Instance, self)
	guild_data_event_proxy:AddEventListener(GuildData.MemberListChange, BindTool.Bind(self.OnFlushMemberView, self))
	guild_data_event_proxy:AddEventListener(GuildData.GUILD_IMPEACH, BindTool.Bind(self.OnGuildImpeach, self))
end

function GuildMemberView:CreateCheckBox()
	self.check_box = check_box or {}
	self.check_box.status = false
	self.check_box.node = XUI.CreateImageView(20, 20, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box.node:setVisible(self.check_box.status)
	self.node_t_list.layout_box_show_offline.node:addChild(self.check_box.node, 10)
	XUI.AddClickEventListener(self.node_t_list.layout_box_show_offline.node, BindTool.Bind(self.OnClickSelectBoxHandler, self), true)
end

function GuildMemberView:OnClickSelectBoxHandler()
	if self.check_box == nil then return end
	self.check_box.status = not self.check_box.status
	self.check_box.node:setVisible(self.check_box.status)
	self:OnFlushMemberView()
end

function GuildMemberView:ReleaseCallBack()
	if self.member_list then
		self.member_list:DeleteMe()
		self.member_list = nil
	end
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function GuildMemberView:ShowIndexCallBack()
	self:OnFlushMemberView()
	self:FlushGuildImpeachBtn()
end

function GuildMemberView:OnFlushMemberView()
	local data = GuildData.Instance:GetGuildMemberList()
	local member_list_data = {}
	for k,v in pairs(data) do
		if self.check_box.status == true then
			if v.is_online == 1 then
				table.insert(member_list_data, v)
			end
		else
			table.insert(member_list_data, v)
		end
	end
	self.member_list:SetDataList(member_list_data)

	if RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_LEADER) then
		self.node_t_list.btn_leave_guild.node:setTitleText(Language.Guild.DelGuild)
	else
		self.node_t_list.btn_leave_guild.node:setTitleText(Language.Guild.LeaveGuild)
	end
end

function GuildMemberView:ReqAttackCityEvent()
	ViewManager.Instance:OpenViewByDef(ViewDef.WangChengZhengBa)
end

function GuildMemberView:AddMenberEvent()
	self:GetViewManager():OpenViewByDef(ViewDef.Guild.GuildAddMember)
end

function GuildMemberView:LeaveGuildEvent()
	local guild_info = GuildData.Instance:GetGuildInfo()
	self.alert = self.alert or Alert.New()
	if RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_LEADER) then
		self.alert:SetLableString(Language.Guild.DelGuildAlert)
		self.alert:SetOkFunc(BindTool.Bind(function ()
			GuildCtrl.DeleteGuildReq()
		end, self))
	else
		self.alert:SetLableString(string.format(Language.Guild.LeaveGuildAlert, GuildData.GetGuildCfg().global.leftTimeLimit))
		self.alert:SetOkFunc(BindTool.Bind(function ()
			GuildCtrl.LeaveGuild()
		end, self))
	end
	self.alert:SetCancelString(Language.Common.Cancel)
	self.alert:SetOkString(Language.Common.Confirm)
	self.alert:Open()
end

function GuildMemberView:CreateMemberList()
	if self.member_list ~= nil then return end

	local ph = self.ph_list.ph_member_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.MemberListItem, nil, nil, self.ph_list.ph_member_list_item)
	self.node_t_list.layout_guild_member.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(1)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)

	self.member_list = list
end

-- "弹劾"按钮点击回调
function GuildMemberView:OnBtn()
	local impeach_left_time = GuildData.GetGuildImpeachLeftTimes()

	if impeach_left_time <= 0 then
		local alert = self.alert or Alert.New()
		alert:SetLableString(Language.Guild.ImpeachText6)
		alert:SetOkFunc(function()
			GuildCtrl.SendGuildImpeachReq()
		end)
		alert:SetCancelString(Language.Common.Cancel)
		alert:SetOkString(Language.Common.Confirm)
		alert:Open()
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.GuildImpeach)
	end
end

function GuildMemberView:OnGuildImpeach()
	self:FlushGuildImpeachBtn()
end

function GuildMemberView:FlushGuildImpeachBtn()
	local btn_title = GuildData.GetGuildImpeachLeftTimes() > 0 and "参于投票" or "发起弹劾"
	self.node_t_list["btn_1"].node:setTitleText(btn_title)
end

----------------------------------------------------
-- MemberListItem
----------------------------------------------------
GuildMemberView.MemberListItem = BaseClass(BaseRender)
local MemberListItem = GuildMemberView.MemberListItem

function MemberListItem:__init()
end

function MemberListItem:__delete()
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function MemberListItem:CreateChild()
	BaseRender.CreateChild(self)

	self.rich_state = self.node_tree.rich_state.node
	self.layout_name = XUI.CreateLayout(78, 26.5, 156, 25)
	self.view:addChild(self.layout_name, 3)
	XUI.RichTextSetCenter(self.node_tree.rich_name.node)
	XUI.AddClickEventListener(self.rich_state, BindTool.Bind1(self.OnClickCallMember, self))
	XUI.AddClickEventListener(self.layout_name, BindTool.Bind1(self.OnClickRoleName, self))
	self.rich_state:setTouchEnabled(false)
end

function MemberListItem:OnClickCallMember()
	if TimeCtrl.Instance:IsPassDayTimeNow() then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.OnPassDayTimeForbid)
		return
	end

	if self.data.obj_id and self.data.name then
		self.alert = self.alert or Alert.New()
		self.alert:SetLableString(string.format(Language.Guild.CallMemberAlert, self.data.name, GuildData.GetGuildCfg().global.zjYb))
		self.alert:SetOkFunc(BindTool.Bind1(function ()
			GuildCtrl.CallGuildMember(1, self.data.role_id, self.data.name)
		end, self))
		self.alert:SetCancelString(Language.Common.Cancel)
		self.alert:SetOkString(Language.Common.Confirm)
		self.alert:SetShowCheckBox(false)
		self.alert:Open()
	end
end

function MemberListItem:OnClickRoleName()
	local self_role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
	if self.data.obj_id and self.data.name and self_role_id ~= self.data.role_id then
		local menu_list = {
			{menu_index = 0},
			{menu_index = 3},
			{menu_index = 4},
			{menu_index = 5},
			{menu_index = 6},
		}
		if RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_LEADER) or 
			RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER) then
			table.insert(menu_list, {menu_index = 35})
			if self.data.position < SOCIAL_MASK_DEF.GUILD_LEADER then
				table.insert(menu_list, {menu_index = 36})
			end
		end
		UiInstanceMgr.Instance:OpenCustomMenu(menu_list, self.data)
	end
end

function MemberListItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	
	local server_time = TimeCtrl.Instance:GetServerTime()
	local offline = TimeUtil.Format2TableDHM(server_time - self.data.login_time)
	local content = ""
	local rich_color = COLOR3B.G_W
	local lbl_color = COLOR3B.G_W
	self.rich_state:setTouchEnabled(false)
	local self_role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
	if self.data.is_online == 1 then
		content = Language.Guild.Online
		if self.data.role_id ~= self_role_id then
			content = content .. " " .. Language.Guild.Call
			self.rich_state:setTouchEnabled(true)
		end
		rich_color = COLOR3B.GREEN
		lbl_color = COLOR3B.WHITE
	elseif offline.day > 0 then
		if offline.day > 7 then
			offline.day = 7
		end
		content = string.format(Language.Guild.OffLineTime, offline.day) .. Language.Guild.Day
	else
		if offline.hour > 0 then
			content = string.format(Language.Guild.OffLineTime, offline.hour) .. Language.Guild.Hour
		else
			content = Language.Guild.MinOffLineTime
		end
	end
	XUI.RichTextSetCenter(self.rich_state)
	RichTextUtil.ParseRichText(self.rich_state, content, 17, rich_color)
	local sex_symbol = SEX_COLOR[self.data.sex]
	content = "{" .. "wordcolor;" .. sex_symbol[2] .. ";" .. sex_symbol[1] .. "}" .. self.data.name
	RichTextUtil.ParseRichText(self.node_tree.rich_name.node, content, 17, lbl_color)
	self.node_tree.lbl_level.node:setString(self.data.level)
	self.node_tree.lbl_prof.node:setString(Language.Common.ProfName[self.data.prof])
	self.node_tree.lbl_contribution.node:setString(self.data.donate_degree or 0)
	self.node_tree.lbl_position.node:setString(GuildData.Instance:GetGuildPosition(self.data.position))
	self.node_tree.lbl_level.node:setColor(lbl_color)
	self.node_tree.lbl_prof.node:setColor(lbl_color)
	self.node_tree.lbl_contribution.node:setColor(lbl_color)
	self.node_tree.lbl_position.node:setColor(lbl_color)
end

return GuildMemberView
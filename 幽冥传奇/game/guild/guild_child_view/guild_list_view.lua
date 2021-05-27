-- 行会列表
local GuildListView = GuildListView or BaseClass(SubView)

function GuildListView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		-- {"guild_ui_cfg", 2, {0}},
		{"guild_ui_cfg", 9, {0}},
		{"guild_ui_cfg", 12, {0}},
	}
end

function GuildListView:LoadCallBack()
	self:CreateGuildList()

	local str = (GuildData.GetGuildCfg().global.warLastTime / 3600) .. Language.Guild.Hour
	self.node_t_list.lbl_proclaim_war_keep_time.node:setString(str)
	str = GuildData.GetGuildCfg().global.DeclareWarNeedCoin .. Language.Guild.Bankroll
	self.node_t_list.lbl_proclaim_war_cost.node:setString(str)
	self:UpdateWarTime(0)
	self.event_proxy = EventProxy.New(GuildData.Instance, self)
	self.event_proxy:AddEventListener(GuildData.GuildListChange, BindTool.Bind(self.OnFlushListView, self))
	self.event_proxy:AddEventListener(GuildData.UpdataGuildList, BindTool.Bind(self.OnFlushListView, self))
end

function GuildListView:ReleaseCallBack()
	if self.guild_list then
		self.guild_list:DeleteMe()
		self.guild_list = nil
	end

	if self.war_alert then
		self.war_alert:DeleteMe()
		self.war_alert = nil
	end

	self:DeleteWarTimer()	
end

function GuildListView:ShowIndexCallBack()
	self:OnFlushListView()
end

function GuildListView:OnFlushListView()
	local list = GuildData.Instance:GetGuildList()
	self.guild_list:SetDataList(list)
end

function GuildListView:CreateGuildList()
	if self.guild_list ~= nil then return end

	local ph = self.ph_list.ph_guild_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, nil, GuildListItem, nil, nil, self.ph_list.ph_guild_list_item)
	self.node_t_list.layout_guild_list.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(1)
	list:SetAutoSupply(true)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)

	self.guild_list = list
end

function GuildListView:UpdateWarTime(change_num)
	change_num = change_num or 0
	local is_in_war = GuildData.Instance:FlushWarTime(change_num)

	if is_in_war == true then
		self:CreateWarTimer()
		self:OnFlushListView()
	else
		self:Flush(self:GetShowIndex())
		self:DeleteWarTimer()
	end

end

function GuildListView:CreateWarTimer()
	if self.war_timer == nil then
		self.war_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.UpdateWarTime, self, -1), 1)
	end
end

function GuildListView:DeleteWarTimer()
	if self.war_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.war_timer)
		self.war_timer = nil
	end
end


----------------------------------------------------
-- GuildListItem
----------------------------------------------------
GuildListItem = GuildListItem or BaseClass(BaseRender)

function GuildListItem:__init()
end

function GuildListItem:__delete()

end

function GuildListItem:CreateChild()
	BaseRender.CreateChild(self)

	self.rich_time = self.node_tree.rich_time.node
	self.btn_union = self.node_tree.btn_union.node
	self.btn_proclaim_war = self.node_tree.btn_proclaim_war.node
	self.btn_canel_union = self.node_tree.btn_canel_union.node
	XUI.AddClickEventListener(self.btn_union, BindTool.Bind1(self.OnClickUnion, self))
	XUI.AddClickEventListener(self.btn_proclaim_war, BindTool.Bind1(self.OnClickProclaimWar, self))
	XUI.AddClickEventListener(self.btn_canel_union, BindTool.Bind1(self.OnClickCanelUnion, self))
	XUI.RichTextSetCenter(self.rich_time)
	self.rich_time:setVisible(false)
	self.btn_union:setVisible(false)
	self.btn_proclaim_war:setVisible(false)
	self.btn_canel_union:setVisible(false)
end

function GuildListItem:OnClickUnion()
	if self.data and self.data.guild_id then
		GuildCtrl.SetGuildRelationship(GUILD_RELATIONSHIP_OPT.UNION, self.data.guild_id)
	end
end

function GuildListItem:OnClickProclaimWar()
	if self.data and self.data.guild_id then
		local guild_cfg = GuildData.GetGuildCfg()
		self.war_alert = self.war_alert or Alert.New()
		self.war_alert:SetLableString(string.format(Language.Guild.ProclaimWarAlert, guild_cfg.global.DeclareWarNeedCoin, guild_cfg.global.warLastTime / 3600))
		self.war_alert:SetOkFunc(BindTool.Bind1(function ()
			GuildCtrl.GuildDeclarationWar(self.data.guild_id)
			GuildCtrl.GetGuildList()
		end, self))
		self.war_alert:SetCancelString(Language.Common.Cancel)
		self.war_alert:SetOkString(Language.Common.Confirm)
		self.war_alert:SetShowCheckBox(true)
		self.war_alert:Open()
	end
end

function GuildListItem:OnClickCanelUnion()
	if self.data and self.data.guild_id then
		GuildCtrl.SetGuildRelationship(GUILD_RELATIONSHIP_OPT.CANCEL_UNION, self.data.guild_id)
	end
end

function GuildListItem:OnFlush()
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if self.data == nil or next(self.data) == nil then
		self.node_tree.lbl_level.node:setString("")
		self.node_tree.lbl_guild_name.node:setString("")
		self.node_tree.lbl_chairman_name.node:setString("")
		self.node_tree.lbl_people_num.node:setString("")
		self.rich_time:setVisible(false)
		self.btn_union:setVisible(false)
		self.btn_proclaim_war:setVisible(false)
		self.btn_canel_union:setVisible(false)
		return
	end

	if GuildData.GetGuildLevelCfgBylevel(self.data.guild_level) == nil then
		return
	end

	self.node_tree.lbl_level.node:setString(self.data.guild_level)
	self.node_tree.lbl_guild_name.node:setString(self.data.guild_name)
	self.node_tree.lbl_chairman_name.node:setString(self.data.leader_name)
	self.node_tree.lbl_people_num.node:setString(self.data.guild_member_num .. "/" 
		.. GuildData.GetGuildLevelCfgBylevel(self.data.guild_level).maxMember)

	local relationship = self.data.relationship
	if GUILD_RELATIONSHIP.UNION == self.data.relationship then
		self.rich_time:setVisible(false)
		self.btn_union:setVisible(false)
		self.btn_proclaim_war:setVisible(false)
		self.btn_canel_union:setVisible(true)
		self.node_tree.lbl_relationship.node:setColor(COLOR3B.GREEN)
	elseif GUILD_RELATIONSHIP.ENEMY == self.data.relationship and self.data.war_left_time > 0 then
		self.rich_time:setVisible(true)
		self.btn_union:setVisible(false)
		self.btn_proclaim_war:setVisible(false)
		self.btn_canel_union:setVisible(false)

		local color = COLOR3B.RED
		local content = TimeUtil.FormatSecond(self.data.war_left_time, 3)
		RichTextUtil.ParseRichText(self.rich_time, content, 22, color)
		self.node_tree.lbl_relationship.node:setColor(COLOR3B.RED)
	else
		self.rich_time:setVisible(false)
		self.btn_union:setVisible(true)
		self.btn_proclaim_war:setVisible(true)
		self.btn_canel_union:setVisible(false)
		self.node_tree.lbl_relationship.node:setColor(COLOR3B.OLIVE)
		relationship = GUILD_RELATIONSHIP.NULL
	end
	self.node_tree.lbl_relationship.node:setString(GuildData.GetGuildRelationshipText(relationship))

	local is_self_guild = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) == self.data.guild_id and 1 or 0
	if is_self_guild == 1 then
		self.rich_time:setVisible(false)
		self.btn_union:setVisible(false)
		self.btn_proclaim_war:setVisible(false)
		self.btn_canel_union:setVisible(false)
	end
	self.node_tree.lbl_level.node:setColor(is_self_guild == 1 and COLOR3B.GRAY or COLOR3B.WHITE)
	self.node_tree.lbl_guild_name.node:setColor(is_self_guild == 1 and COLOR3B.GRAY or COLOR3B.WHITE)
	self.node_tree.lbl_chairman_name.node:setColor(is_self_guild == 1 and COLOR3B.GRAY or COLOR3B.WHITE)
	self.node_tree.lbl_people_num.node:setColor(is_self_guild == 1 and COLOR3B.GRAY or COLOR3B.WHITE)
	self.node_tree.lbl_relationship.node:setColor(is_self_guild == 1 and COLOR3B.GRAY or COLOR3B.WHITE)
end

return GuildListView
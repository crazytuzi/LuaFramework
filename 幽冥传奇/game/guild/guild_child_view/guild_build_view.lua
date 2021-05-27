-- 行会建设
GUILD_FLAG_INDEX = {
	ATTR = 1,
	FLAG = 2,
}

GUILD_DONATE_INDEX = {
	COIN = 1,
	GOLD = 2,
}

GUILD_TIMES_LIMIT = 5
GUILD_DONATE_ACTIVE_INDEX = 16

local GuildBuildView = GuildBuildView or BaseClass(SubView)

function GuildBuildView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.texture_path_list[2] = 'res/xui/wangchengzhengba.png'
	self.config_tab = {
		{"guild_ui_cfg", 8, {0}},
		{"guild_ui_cfg", 11, {0}},
	}
end

function GuildBuildView:LoadCallBack()
	self:InitBuildTabbar()

	self.pop_num_view = NumKeypad.New()
	self.pop_num_view:SetOkCallBack(BindTool.Bind1(self.OnOKCallBack, self))

	self.donate_times = 0
	self.can_donate_times = 0
	self:UpdateDonateInfo()
	self.guild_progressbar = ProgressBar.New()
	self.guild_progressbar:SetView(self.node_t_list.prog9_guild.node)
	self.guild_progressbar:SetTotalTime(0)
	self.guild_progressbar:SetTailEffect(991, nil, true)
	self.guild_progressbar:SetEffectOffsetX(-20)
	self.guild_progressbar:SetPercent(0)

	-- XUI.AddClickEventListener(self.node_t_list.btn_donate_max.node, BindTool.Bind(self.OnClickDonateMax, self))   --行会捐献最大值
	XUI.AddClickEventListener(self.node_t_list.btn_donate.node, BindTool.Bind1(self.OnClickDonateEvent, self))
	XUI.AddClickEventListener(self.node_t_list.btn_donate_minus.node, BindTool.Bind2(self.ChangeDonateTimes, self, -1))
	XUI.AddClickEventListener(self.node_t_list.btn_donate_plus.node, BindTool.Bind2(self.ChangeDonateTimes, self, 1))
	XUI.AddClickEventListener(self.node_t_list.img9_donate_num_bg.node, BindTool.Bind1(self.OnOpenPopNum, self), false)

	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.GuildInfoChange, BindTool.Bind(self.OnFlushBuildView, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))
end

function GuildBuildView:ReleaseCallBack()
	self.donate_times = 0
	self.flag_show_index = 1
	self.donate_show_index = 1

	if self.flag_tabbar then
		self.flag_tabbar:DeleteMe()
		self.flag_tabbar = nil
	end

	if self.donate_tabbar then
		self.donate_tabbar:DeleteMe()
		self.donate_tabbar = nil
	end

	-- if self.guild_flag_model then
	-- 	self.guild_flag_model:DeleteMe()
	-- 	self.guild_flag_model = nil
	-- end

	if nil ~= self.pop_num_view then
		self.pop_num_view:DeleteMe()
		self.pop_num_view = nil
	end

	if nil ~= self.guild_progressbar then
		self.guild_progressbar:DeleteMe()
		self.guild_progressbar = nil
	end
end

function GuildBuildView:ShowIndexCallBack()
	self:OnFlushBuildView()
end

function GuildBuildView:OnFlushBuildView()
	local guild_info = GuildData.Instance:GetGuildInfo()
	local guild_cfg = GuildData.GetGuildCfg()
	local next_level_need_exp = GuildData.Instance:GetGuildNextLevelNeedExp()
	-- local flag_level = GuildData.Instance:GetGuildFlagLevel()
	-- self.guild_flag_model:Show(GuildData.GetGuildFlagShowId(flag_level))

	self.node_t_list.lbl_cur_guild_level.node:setString(guild_info.cur_guild_level)
	self.node_t_list.lbl_cur_guild_bankroll.node:setString(guild_info.guild_bankroll)

	self.guild_progressbar:SetPercent(guild_info.guild_exp / next_level_need_exp * 100)
	self.node_t_list.lbl_guild_prog.node:setString(guild_info.guild_exp .. "/" .. next_level_need_exp)

	local cur_guild_level_cfg = GuildData.GetGuildLevelCfgBylevel(guild_info.cur_guild_level)
	local next_guild_level_cfg = GuildData.GetGuildLevelCfgBylevel(guild_info.cur_guild_level + 1)
	if nil == next_guild_level_cfg then
		next_guild_level_cfg = cur_guild_level_cfg
	end
	if cur_guild_level_cfg == nil or next_guild_level_cfg == nil then
		return
	end

	local cur_guild_attr_content = RoleData.FormatAttrContent(cur_guild_level_cfg.guildLevelWelfare)
	cur_guild_attr_content = cur_guild_attr_content 
		.. "\n" .. Language.Guild.MaxMemberStr[1] .. cur_guild_level_cfg.maxMember .. Language.Guild.MaxMemberStr[2]
		.. "\n" .. Language.Guild.MaxDepotBagCountStr[1] .. cur_guild_level_cfg.maxDepotBagCount .. Language.Guild.MaxDepotBagCountStr[2]
	local next_guild_attr_content = RoleData.FormatAttrContent(next_guild_level_cfg.guildLevelWelfare, {value_str_color = "1eff00"})
	local wordcolorStr = "{" .. "wordcolor;" .. "1eff00;"
	next_guild_attr_content = next_guild_attr_content
		.. "\n" .. Language.Guild.MaxMemberStr[1] .. wordcolorStr .. next_guild_level_cfg.maxMember .. Language.Guild.MaxMemberStr[2] .. "}"
		.. "\n" .. Language.Guild.MaxDepotBagCountStr[1] ..  wordcolorStr .. next_guild_level_cfg.maxDepotBagCount .. Language.Guild.MaxDepotBagCountStr[2] .. "}"
	local rich_1 = RichTextUtil.ParseRichText(self.node_t_list.rich_flag_cur_attr.node, cur_guild_attr_content, 17, COLOR3B.OLIVE)
	local rich_2 = RichTextUtil.ParseRichText(self.node_t_list.rich_flag_next_attr.node, next_guild_attr_content, 17, COLOR3B.OLIVE)
	rich_1:setVerticalSpace(25)
	rich_2:setVerticalSpace(25)
	local test = RoleData.FormatRoleAttrStr(next_guild_level_cfg.guildLevelWelfare)
	self:FlushSelfInfoInGuildBuildView()
	self:UpdateDonateInfo()

	local cur_guild_attr_list = {}
	local next_guild_attr_list = {}
end

-- 刷新-我的信息
function GuildBuildView:FlushSelfInfoInGuildBuildView()
	if self.node_t_list.layout_self_info ~= nil then
		local guild_data = GuildData.Instance:GetGuildInfo()
		local info_name_1 = Language.Guild.ContributionStr
		local info_name_2 = Language.Guild.DonateActStr
		info_val_1 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_CON)
		self.node_t_list.lbl_self_info_name_1.node:setString(info_name_1)
		self.node_t_list.lbl_self_info_name_2.node:setString(info_name_2)
		self.node_t_list.lbl_self_info_val_1.node:setString(info_val_1)
	end
end

function GuildBuildView:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_GUILD_CON and nil ~= self.node_t_list then
		self.node_t_list.lbl_self_info_val_1.node:setString(vo.value)
	end
end

function GuildBuildView:OnClickDonateEvent()
	if self.donate_show_index > 0 and self.donate_times > 0 then
		GuildCtrl.DonateGuildBankroll(self.donate_show_index, self.donate_times)
	end
	self:UpdateDonateInfo()
end

function GuildBuildView:OnOpenPopNum()
	if nil ~= self.pop_num_view then
		self.pop_num_view:Open()
		self.pop_num_view:SetText(self.donate_times)
		local guild_info = GuildData.Instance:GetGuildInfo()
		local guild_cfg = GuildData.GetGuildCfg()
		-- local max_val = math.floor((guild_cfg.global.donateTimes * guild_cfg.global.coinLimit - guild_info.today_donate_val) / guild_cfg.global.coinLimit)
		-- self.pop_num_view:SetMaxValue(max_val)
	end
end

function GuildBuildView:ChangeDonateTimes(change_num)
	local num = self.donate_times + change_num
	if num > 0 then
		local is_full_times = (self.donate_show_index == GUILD_DONATE_INDEX.COIN and num > self.can_donate_times)
		if not is_full_times then
			self.donate_times = num
		end
		self:UpdateDonateInfo()
		local guild_cfg = GuildData.Instance:GetGuildCfg()
		local own_money = self.donate_show_index == GUILD_DONATE_INDEX.COIN and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN) or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		local cost = self.donate_times * (self.donate_show_index == GUILD_DONATE_INDEX.COIN and guild_cfg.global.coinLimit or guild_cfg.global.ybLimit)
		local cost_unit = self.donate_show_index == GUILD_DONATE_INDEX.COIN and guild_cfg.global.coinLimit or guild_cfg.global.ybLimit
		if own_money - cost < cost_unit or own_money == 0 or is_full_times then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Guild.BuildMax)
		end
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Guild.BuildMin)
	end
end

function GuildBuildView:OnOKCallBack(num)
	if self.donate_show_index == GUILD_DONATE_INDEX.COIN and num > self.can_donate_times then
		self.donate_times = self.can_donate_times
	else
		self.donate_times = num
	end
	self:UpdateDonateInfo()
end

function GuildBuildView:InitBuildTabbar()
	if nil == self.donate_tabbar then
		self.donate_show_index = GUILD_DONATE_INDEX.COIN
		self.donate_tabbar = Tabbar.New()
		self.donate_tabbar:CreateWithNameList(self.node_t_list.layout_guild_build.node, 400, 485,
			function(index) self:ChangeDonateViewIndex(index) end,
			Language.Guild.DonateTabGroup,
			false, ResPath.GetCommon("toggle_121"))
		self.donate_tabbar:SetSpaceInterval(5)
		self.donate_tabbar:ChangeToIndex(self.donate_show_index)
	end
end

function GuildBuildView:ChangeFlagViewIndex(index)
	self.flag_show_index = index

	self.node_t_list.layout_flag_view.node:setVisible(index == GUILD_FLAG_INDEX.ATTR)
	self.guild_flag_model:SetVisible(index == GUILD_FLAG_INDEX.FLAG)
end

function GuildBuildView:ChangeDonateViewIndex(index)
	if self.donate_show_index ~= index then
		self.donate_times = 1
	end
	self.donate_show_index = index
	self:UpdateDonateInfo()
end

function GuildBuildView:UpdateDonateInfo()
	local guild_info = GuildData.Instance:GetGuildInfo()
	local guild_cfg = GuildData.Instance:GetGuildCfg()
	local own_money = self.donate_show_index == GUILD_DONATE_INDEX.COIN and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN) or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local cost = self.donate_times * (self.donate_show_index == GUILD_DONATE_INDEX.COIN and guild_cfg.global.coinLimit or guild_cfg.global.ybLimit)
	if own_money < cost then 
		self.donate_times = math.floor(own_money / (self.donate_show_index == GUILD_DONATE_INDEX.COIN and guild_cfg.global.coinLimit or guild_cfg.global.ybLimit))
	end
	if self.donate_show_index == GUILD_DONATE_INDEX.COIN then
		local can_donate_amount = guild_cfg.global.donateTimes * guild_cfg.global.coinLimit - guild_info.today_donate_val
		local now_cost = self.donate_show_index == GUILD_DONATE_INDEX.COIN and cost or cost * math.floor(guild_cfg.global.coinLimit / guild_cfg.global.ybLimit)
		self.can_donate_times = guild_cfg.global.donateTimes - guild_info.today_donate_val / guild_cfg.global.coinLimit
		if can_donate_amount < 0 then
			can_donate_amount = 0
		end
		--if can_donate_amount > 0 then
			--self.node_t_list.btn_donate.node:setEnabled(can_donate_amount - now_cost >= 0)
		--end
		if self.donate_times > self.can_donate_times then
			self.donate_times = self.can_donate_times
		end
		self.node_t_list.lbl_can_donate_num.node:setString(can_donate_amount)
		self.node_t_list.lbl_can_donate_num.node:setColor(can_donate_amount > 0 and COLOR3B.LIGHT_BROWN or COLOR3B.RED)
		self.node_t_list.lbl_already_donate_num.node:setString(guild_info.today_donate_val)
	else
		self.node_t_list.lbl_can_donate_num.node:setString(Language.Guild.DonateNoLimit)
		self.node_t_list.lbl_can_donate_num.node:setColor(COLOR3B.GREEN)
		self.node_t_list.lbl_already_donate_num.node:setString(guild_info.today_donate_ybval)
	end
	if self.donate_times <= 0 then
		self.donate_times = 1
	end
	cost = self.donate_times * (self.donate_show_index == GUILD_DONATE_INDEX.COIN and guild_cfg.global.coinLimit or guild_cfg.global.ybLimit)
	self.node_t_list.lbl_donate_num.node:setString(self.donate_times)
	self.node_t_list.lbl_bankroll_up_num.node:setString(self.donate_times * guild_cfg.GXAward.guildCion)
	self.node_t_list.lbl_exp_up_num.node:setString(self.donate_times * guild_cfg.GXAward.exp)
	self.node_t_list.lbl_contribution_up_num.node:setString(self.donate_times * guild_cfg.GXAward.gx)
	self.node_t_list.lbl_donate_need.node:setString(cost)
	local content = ""
	if self.donate_show_index == GUILD_DONATE_INDEX.COIN then
		content = string.format(Language.Guild.DonateOnceNeed, guild_cfg.global.coinLimit, Language.Common.Gold)
	else
		content = string.format(Language.Guild.DonateOnceNeed, guild_cfg.global.ybLimit, Language.Common.Diamond)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_donate_once_need.node, content, 20, COLOR3B.LIGHT_BROWN)
end

return GuildBuildView
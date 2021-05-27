-- 行会列表
local GuildJoinListView = GuildJoinListView or BaseClass(SubView)

function GuildJoinListView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.texture_path_list[2] = 'res/xui/bag.png'
	self.config_tab = {
		-- {"guild_ui_cfg", 2, {0}},
		-- {"guild_ui_cfg", 3, {0}},
		{"guild_ui_cfg", 5, {0}},
		-- {"guild_ui_cfg", 6, {0}},
		{"guild_ui_cfg", 19, {0}},
	}
end

function GuildJoinListView:LoadCallBack()
	self:CreateJoinList()
	self:InitJoinGuildCommon()
	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.GuildListChange, BindTool.Bind(self.OnFlushJoinListView, self))

	XUI.AddClickEventListener(self.node_t_list.btn_create_guild.node, BindTool.Bind(self.OnOpenCreate, self))
	XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind(self.OnClickNotShowCreat, self))
	XUI.AddClickEventListener(self.node_t_list.btn_not_show.node, BindTool.Bind(self.OnClickNotShowCreat, self))
	XUI.AddClickEventListener(self.node_t_list.btn_create.node, BindTool.Bind(self.OnClickCreateGuild, self))

	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local color = level >= GuildData.GetGuildCfg().global.levelLimit and "55ff00" or "ff0000"
	local rich_content = string.format(Language.Guild.CreatGuildLev, color, GuildData.GetGuildCfg().global.levelLimit)
	RichTextUtil.ParseRichText(self.node_t_list.rich_limit_lv.node, rich_content, 20, COLOR3B.G_Y)

	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	color = gold >= GuildData.GetGuildCfg().global.createNeedGold and "55ff00" or "ff0000"
	local rich_yb = string.format(Language.Guild.CreateNeedYb, color, GuildData.GetGuildCfg().global.createNeedGold)
	RichTextUtil.ParseRichText(self.node_t_list.rich_need_yb.node, rich_yb, 20, COLOR3B.G_Y)

	self.node_t_list.edit_create_guild.node:setPlaceHolder(Language.Guild.InputGuildName)
	-- self.layout_guild_auto_hook = self.node_t_list.layout_guild_join_list.layout_guild_create.layout_g_auto_hook
	-- self.layout_guild_auto_hook.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind1(self.OnClickWingAutoHook, self))
	-- self.layout_guild_auto_hook.img_hook.node:setVisible(false)

	self.node_t_list.layout_guild_create.node:setVisible(false)
	self.node_t_list.layout_guild_create.node:setLocalZOrder(110)
end

function GuildJoinListView:ReleaseCallBack()
	if self.join_list then
		self.join_list:DeleteMe()
		self.join_list = nil
	end
end

function GuildJoinListView:ShowIndexCallBack()
	self:OnFlushJoinListView()
	self.node_t_list.layout_join_guild_tips.node:setVisible(false)
end

function GuildJoinListView:OnFlushJoinListView()
	self:FlushJoinList()
end

function GuildJoinListView:CreateJoinList()
	if self.join_list ~= nil then return end

	local ph = self.ph_list.ph_req_guild_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, nil, JoinGuildListItem, nil, nil, self.ph_list.ph_req_guild_list_item)
	self.node_t_list.layout_guild_join_list.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(1)
	-- list:SetAutoSupply(true)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)

	self.join_list = list
end

function GuildJoinListView:FlushJoinList()
	if self.join_list == nil then return end

	local join_list = GuildData.Instance:GetGuildList()
	
	table.sort(join_list, SortTools.KeyLowerSorter('guild_rank'))
	self.join_list:SetDataList(join_list)
	self.node_t_list.lbl_not_guild.node:setVisible(#join_list == 0)
end

function GuildJoinListView:InitJoinGuildCommon()
	if self.node_t_list.layout_common_bg_1 ~= nil and not self.node_t_list.layout_common_bg_1.is_listener then
		self.node_t_list.layout_wczb.node:addTouchEventListener(BindTool.Bind2(self.OnBtnTouch, self, 1))
		self.node_t_list.layout_wczb.node:setTouchEnabled(true)
		self.node_t_list.layout_hhzb.node:addTouchEventListener(BindTool.Bind2(self.OnBtnTouch, self, 2))
		self.node_t_list.layout_hhzb.node:setTouchEnabled(true)
		self.node_t_list.layout_hhfl.node:addTouchEventListener(BindTool.Bind2(self.OnBtnTouch, self, 3))
		self.node_t_list.layout_hhfl.node:setTouchEnabled(true)
		-- self.node_t_list.layout_hhzq.node:addTouchEventListener(BindTool.Bind2(self.OnBtnTouch, self, 4))
		-- self.node_t_list.layout_hhzq.node:setTouchEnabled(true)
		self.node_t_list.layout_hhhd.node:addTouchEventListener(BindTool.Bind2(self.OnBtnTouch, self, 5))
		self.node_t_list.layout_hhhd.node:setTouchEnabled(true)

		self.node_t_list.layout_common_bg_1.is_listener = true
	end
end

-- 触摸tips处理
function GuildJoinListView:OnBtnTouch(key, sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		local cfg = Language.Guild.GuildBenifitTips[key]
		if cfg then
			local icon_path = "icon_" .. cfg.img_name
			local text_path = "word_" .. cfg.img_name
			self.node_t_list.img_benifit_coin.node:loadTexture(ResPath.GetGuild(icon_path))
			self.node_t_list.img_benifit_text.node:loadTexture(ResPath.GetGuild(text_path))
			RichTextUtil.ParseRichText(self.node_t_list.rich_guild_benifit.node, cfg.text, 22, COLOR3B.OLIVE)

			self.node_t_list.layout_join_guild_tips.node:setVisible(true)
		end
	elseif event_type == XuiTouchEventType.Moved then
	else
		self.node_t_list.layout_join_guild_tips.node:setVisible(false)
	end
end

function GuildJoinListView:OnOpenCreate()
	self.node_t_list.layout_guild_create.node:setVisible(true)
end

function GuildJoinListView:OnClickNotShowCreat()
	self.node_t_list.layout_guild_create.node:setVisible(false)
end

function GuildJoinListView:OnClickWingAutoHook()
	-- local vis = self.layout_guild_auto_hook.img_hook.node:isVisible()
	-- self.layout_guild_auto_hook.img_hook.node:setVisible(not vis)
	-- WingData.Instance:ChangeAboutFeatherData()
end

function GuildJoinListView:OnClickCreateGuild()
	-- local vis = self.layout_guild_auto_hook.img_hook.node:isVisible()
	
	local guild_name = self.node_t_list.edit_create_guild.node:getText()
	if guild_name ~= nil and guild_name ~= "" then
		GuildCtrl.CreateGuild(1, guild_name)
	end
end

----------------------------------------------------
-- JoinGuildListItem
----------------------------------------------------
JoinGuildListItem = JoinGuildListItem or BaseClass(BaseRender)

function JoinGuildListItem:__init()
end

function JoinGuildListItem:__delete()

end

function JoinGuildListItem:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_join_req.node, BindTool.Bind1(self.OnClickJoinReq, self))
end

function JoinGuildListItem:OnFlush()
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	-- self.node_tree.img9_bg.node:setVisible(self.index % 2 == 0)
	if self.data == nil or next(self.data) == nil then
		self.node_tree.lbl_rank_num.node:setString("")
		self.node_tree.lbl_guild_name.node:setString("")
		self.node_tree.lbl_chairman_name.node:setString("")
		self.node_tree.lbl_level.node:setString("")
		self.node_tree.lbl_people_num.node:setString("")
		self.node_tree.btn_join_req.node:setVisible(false)
		return
	end

	if GuildData.GetGuildLevelCfgBylevel(self.data.guild_level) == nil then
		return
	end
	
	self.node_tree.btn_join_req.node:setVisible(true)
	self.node_tree.lbl_rank_num.node:setString(self.data.guild_rank)
	self.node_tree.lbl_guild_name.node:setString(self.data.guild_name)
	self.node_tree.lbl_chairman_name.node:setString(self.data.leader_name)
	self.node_tree.lbl_level.node:setString(self.data.guild_level)
	local people_num_str = self.data.guild_member_num .. "/" .. GuildData.GetGuildLevelCfgBylevel(self.data.guild_level).maxMember
	self.node_tree.lbl_people_num.node:setString(people_num_str)
end

function JoinGuildListItem:OnClickJoinReq()
	if self.data and self.data.guild_id then
		GuildCtrl.SubmitJoinGuildReq(self.data.guild_id)
	end
end

function JoinGuildListItem:CreateSelectEffect()
	
end

return GuildJoinListView
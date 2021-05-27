-- 行会创建
local GuildCreateView = GuildCreateView or BaseClass(SubView)

function GuildCreateView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		-- {"guild_ui_cfg", 2, {0}},
		-- {"guild_ui_cfg", 3, {0}},
		{"guild_ui_cfg", 6, {0}},
		-- {"guild_ui_cfg", 19, {0}},
	}
end

function GuildCreateView:LoadCallBack()
	-- for i=1,5 do
	-- 	local rich_node = self.node_t_list["rich_create_guild_" .. i].node
	-- 	if rich_node then
	-- 		local rich_content = Language.Guild["CreateGuildProcess" .. i]
	-- 		if i == 1 then
	-- 			rich_content = string.format(rich_content, GuildData.GetGuildCfg().global.levelLimit)
	-- 		end
	-- 		RichTextUtil.ParseRichText(rich_node, rich_content, 20, COLOR3B.LIGHT_BROWN)
	-- 	end
	-- end
	self.node_t_list.edit_create_guild.node:setPlaceHolder(Language.Guild.InputGuildName)
	self:InitJoinGuildCommon()

	-- self:CreateCheckBox("auto_buy_stuff", self.node_t_list.layout_check_box_auto_buy.node)
	
	XUI.AddClickEventListener(self.node_t_list.btn_create_guild.node, BindTool.Bind(self.OnClickCreateGuild, self))
end

function GuildCreateView:ReleaseCallBack()
end

function GuildCreateView:OnFlushCreateView()
end

function GuildCreateView:ShowIndexCallBack()
	self.node_t_list.layout_join_guild_tips.node:setVisible(false)
end

function GuildCreateView:OnClickCreateGuild()
	local guild_name = self.node_t_list.edit_create_guild.node:getText()
	if guild_name ~= nil and guild_name ~= "" then
		GuildCtrl.CreateGuild(1, guild_name)
	end
end

function GuildCreateView:InitJoinGuildCommon()
	if self.node_t_list.layout_common_bg_1 ~= nil and not self.node_t_list.layout_common_bg_1.is_listener then
		self.node_t_list.layout_wczb.node:addTouchEventListener(BindTool.Bind(self.OnBtnTouch, self, 1))
		self.node_t_list.layout_wczb.node:setTouchEnabled(true)
		self.node_t_list.layout_hhzb.node:addTouchEventListener(BindTool.Bind(self.OnBtnTouch, self, 2))
		self.node_t_list.layout_hhzb.node:setTouchEnabled(true)
		self.node_t_list.layout_hhfl.node:addTouchEventListener(BindTool.Bind(self.OnBtnTouch, self, 3))
		self.node_t_list.layout_hhfl.node:setTouchEnabled(true)
		-- self.node_t_list.layout_hhzq.node:addTouchEventListener(BindTool.Bind(self.OnBtnTouch, self, 4))
		-- self.node_t_list.layout_hhzq.node:setTouchEnabled(true)
		self.node_t_list.layout_hhhd.node:addTouchEventListener(BindTool.Bind(self.OnBtnTouch, self, 5))
		self.node_t_list.layout_hhhd.node:setTouchEnabled(true)

		self.node_t_list.layout_common_bg_1.is_listener = true
	end
end

-- 触摸tips处理
function GuildCreateView:OnBtnTouch(key, sender, event_type, touch)
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

return GuildCreateView
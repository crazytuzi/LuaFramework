-- 行会信息
local GuildInfoView = GuildInfoView or BaseClass(SubView)
GuildInfoView.PUBLISH_WORD_SIZE = 360

function GuildInfoView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.texture_path_list[2] = 'res/xui/wangchengzhengba.png'
	self.config_tab = {
		{"guild_ui_cfg", 7, {0}},
		{"guild_ui_cfg", 8, {0}},
	}
end

function GuildInfoView:LoadCallBack()
	self.real_affiche_text = ""
	self.affiche_text_node = self.node_t_list.label_guild_affiche_text.node
	-- self:CreateEditBox() 

	-- self.node_t_list.lbl_guild_info_tip.node:addTouchEventListener(BindTool.Bind1(self.OnTouchGuildInfoTips, self))
	-- self.node_t_list.lbl_guild_info_tip.node:setTouchEnabled(true)
	-- XUI.AddClickEventListener(self.node_t_list.btn_affiche_confirm.node, BindTool.Bind1(self.OnClickEditAffiche, self))
	-- XUI.AddClickEventListener(self.node_t_list.lbl_guild_build.node, BindTool.Bind1(self.OnClickToBuild, self))
	-- XUI.AddClickEventListener(self.node_t_list.lbl_guild_info_bid.node, BindTool.Bind1(self.OnClickBit, self))

	self.event_proxy = EventProxy.New(GuildData.Instance, self)
	self.event_proxy:AddEventListener(GuildData.GuildInfoChange, BindTool.Bind(self.OnFlushInfoView, self))
	self.event_proxy:AddEventListener(GuildData.GuildListChange, BindTool.Bind(self.OnFlushInfoView, self))

	-- XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnTip, self))
	self.node_t_list["btn_tip"].node:setVisible(false)
end

function GuildInfoView:ReleaseCallBack()
	self.real_affiche_text = ""
	-- self.affiche_edit = nil

	if self.pop_alert then
		self.pop_alert:DeleteMe()
		self.pop_alert = nil
	end
end

function GuildInfoView:ShowIndexCallBack()
	self:OnFlushInfoView()
end

function GuildInfoView:OnFlushInfoView()
	local guild_info = GuildData.Instance:GetGuildInfo()

	local is_can_edit_affiche = GuildData.Instance:IsCanEditAffiche()
	local affiche_text = guild_info.private_affiche
	if affiche_text == "" then
		affiche_text = is_can_edit_affiche and Language.Guild.InputGuildAffiche or Language.Guild.Nothing
	end
	-- self.affiche_edit:setEnabled(is_can_edit_affiche)
	self.real_affiche_text = guild_info.private_affiche
	self.affiche_text_node:setString(affiche_text)
	self.node_t_list.btn_affiche_confirm.node:setVisible(false and is_can_edit_affiche)  -- 屏蔽公告修改
	self.node_t_list.lbl_guild_name.node:setString(guild_info.guild_name)
	self.node_t_list.lbl_guild_chairman.node:setString(guild_info.leader_name)
	self.node_t_list.lbl_guild_bankroll.node:setString(guild_info.guild_bankroll)
	self.node_t_list.lbl_guild_people_num.node:setString(guild_info.cur_member_num .. "/" .. guild_info.max_member_num)
	self.node_t_list.lbl_guild_level.node:setString(guild_info.cur_guild_level)
	self.node_t_list.lbl_guild_rank.node:setString(guild_info.guild_rank)
	
	self:FlushSelfInfoInInfoView()
end

-- 刷新-我的信息
function GuildInfoView:FlushSelfInfoInInfoView()
	if self.node_t_list.layout_self_info ~= nil then
		local guild_data = GuildData.Instance:GetGuildInfo()
		local info_name_1 = Language.Guild.PositionStr
		local info_name_2 = Language.Guild.ContributionStr
		info_val_1 = GuildData.Instance:GetGuildPosition(guild_data.self_position)
		info_val_2 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_CON)
		self.node_t_list.lbl_self_info_name_1.node:setString(info_name_1)
		self.node_t_list.lbl_self_info_name_2.node:setString(info_name_2)
		self.node_t_list.lbl_self_info_val_1.node:setString(info_val_1)
		self.node_t_list.lbl_self_info_val_2.node:setString(info_val_2)
	end
end

function GuildInfoView:OnClickEditAffiche()
	GuildCtrl.SetGuildAffiche(1, self.real_affiche_text)
end

function GuildInfoView:OnTip()
	local content = Language.DescTip.GuildInfoContent or ""
	local title = Language.DescTip.GuildInfoTitle or ""
	DescTip.Instance:SetContent(content, title)
end

-- function GuildInfoView:CreateEditBox()
-- 	if self.affiche_edit ~= nil then return end

-- 	local bg_path = ResPath.GetCommon("img9_transparent")
-- 	local ph = self.ph_list.ph_affiche_edit
-- 	self.affiche_edit = XUI.CreateEditBox(ph.x, ph.y, ph.w, ph.h, nil, 0, 3, bg_path, true)
-- 	self.affiche_edit:setFontSize(24)
-- 	self.affiche_edit:setPlaceholderFontSize(10)
-- 	self.affiche_edit:setMaxLength(ph.w - 10)
-- 	self.affiche_edit:registerScriptEditBoxHandler(BindTool.Bind(self.OnEditEvent, self))

-- 	self.node_t_list.layout_guild_info.node:addChild(self.affiche_edit, 10)

-- 	self.is_changed = false
-- 	self.old_str = ""
-- end

-- function GuildInfoView:OnEditEvent(event_type, sender)
-- 	if "began" == event_type then
-- 		self.is_changed = false
-- 		self.old_str = self.affiche_text_node:getString()
-- 		self.affiche_text_node:setString("")
-- 		sender:setText(self.old_str)
-- 	elseif "changed" == event_type then
-- 		self.is_changed = true

-- 		local str = sender:getText()
-- 		if AdapterToLua:utf8FontCount(str) > GuildInfoView.PUBLISH_WORD_SIZE then
-- 			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentToLong)
-- 			str = AdapterToLua:utf8TruncateByFontCount(str, GuildInfoView.PUBLISH_WORD_SIZE)
-- 			sender:setText(str)
-- 		end
-- 	elseif "ended" == event_type then
-- 		if self.is_changed then
-- 			self.affiche_text_node:setString(sender:getText())
-- 			self.real_affiche_text = sender:getText()
-- 		else
-- 			self.affiche_text_node:setString(self.old_str)
-- 		end
-- 		sender:setText("")
-- 	end
-- end

return GuildInfoView
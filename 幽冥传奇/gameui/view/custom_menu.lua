
CustomMenu = CustomMenu or BaseClass(XuiBaseView)

function CustomMenu:__init()
	self.zorder = 11
	self:SetModal(true)
	self.is_any_click_close = true

	self.param = nil
	self.close_callback_func = nil					-- 关闭回调

	self.config_tab = {
		{"itemtip_ui_cfg", 5, {0}},
	}

	self.close_view_func = BindTool.Bind(self.Close, self)
end

function CustomMenu:__delete()
end

function CustomMenu:ReleaseCallBack()
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end

	MenuItemRender.param = nil
	self.param = nil
	self.close_callback_func = nil
end

function CustomMenu:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		if not self.scroll_view then
			local ph = self.ph_list.ph_btn_list
			local grid_scroll = GridScroll.New()
			grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, 70, MenuItemRender, ScrollDir.Vertical, false)
			self.scroll_view = grid_scroll
			self.node_t_list.layout_custom_menu.node:addChild(grid_scroll:GetView(), 9)
			self.node_t_list.layout_tarce_pos.node:setVisible(false)
		end
	end
end

function CustomMenu:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CustomMenu:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if nil ~= self.close_callback_func then
		self.close_callback_func()
	end
	MenuItemRender.param = nil
	self.param = nil
	self.close_callback_func = nil
end

function CustomMenu:OnFlush(param_list, index)
	if not param_list then
		return
	end
	self.node_t_list.layout_tarce_pos.node:setVisible(false)
	if self.param then
		local name = self.param.name or self.param.role_name or self.param.guild_name
		self.node_t_list.label_role_name.node:setString(name)
		MenuItemRender.param = self.param
	end
	if not MenuItemRender.on_click_handler then
		MenuItemRender.on_click_handler = self.close_view_func
	end	
	--仇人追踪
	if self.param and self.param.type == SOCIETY_RELATION_TYPE.ENEMY then
		self.node_t_list.layout_tarce_pos.node:setVisible(true)
		self:FlushTarceInfo(SocietyData.Instance:GetTraceInfoData())
	end
	for k,v in pairs(param_list) do
		if k == "tarce_txt" then
			self:FlushTarceInfo(SocietyData.Instance:GetTraceInfoData())
		end
	end

	self.scroll_view:SetDataList(param_list.all) 
	self.scroll_view:JumpToTop()
end

function CustomMenu:GetView()
	return self.scroll_view
end

function CustomMenu:FlushTarceInfo(info)
	local color = COLOR3B.GREEN
	local data = nil
	for k,v in pairs(info) do
		if self.param.role_id == v.role_id then
			data = v
		end
	end
	if nil == data then
		color = COLOR3B.RED
	end
	local scene_name = data and data.scene_name or " ? "
	local pos_x = data and data.pos_x or " ? "
	local pos_y = data and data.pos_y or " ? "
	self.node_t_list.lbl_tarce_pos.node:setString(scene_name..pos_x..":"..pos_y)
	self.node_t_list.lbl_tarce_pos.node:setColor(color)
end

function CustomMenu:SetParam(param)
	self.param = param
end

function CustomMenu:BindCloseCallBack(callback_func)
	self.close_callback_func = callback_func
end

function CustomMenu:SetPosition(pos)
	if pos then
		self.root_node:setAnchorPoint(0, 1)
		self.root_node:setPosition(pos.x, pos.y)
	else
		self.root_node:setAnchorPoint(0.5, 0.5)
		self.root_node:setPosition(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2)
	end
end

----------------------------------------------------
-- MenuItemRender
----------------------------------------------------
MenuItemRender = MenuItemRender or BaseClass(BaseRender)

function MenuItemRender:__init()
end

function MenuItemRender:__delete()
	if self.find_alert then
		self.find_alert:DeleteMe()
	end
	self.find_alert = nil

	if self.menu_alert then
		self.menu_alert:DeleteMe()
	end
	self.menu_alert = nil
end

function MenuItemRender:CreateChild()
	BaseRender.CreateChild(self)

	self.btn = XUI.CreateButton(0, 0, 0, 0, false, ResPath.GetCommon("btn_103"), ResPath.GetCommon("btn_103"), "", true)
	self.btn:setTitleColor(COLOR3B.OLIVE)
	self.btn:setTitleFontName(COMMON_CONSTS.FONT)
	self.btn:setTitleFontSize(25)
	self.btn:setIsHittedScale(true)
	self.view:addChild(self.btn, 1)

	self.btn:addClickEventListener(BindTool.Bind(self.OnClickHandler, self))
end

function MenuItemRender:OnFlush()
	if self.data == nil then return end
	-- if self.data.menu_index >= 37 and self.data.menu_index <= 43 then
	-- 	if GuildData.GetSelfGuildPosition() == SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER then
	-- 		self.btn:setEnabled(MenuItemRender.param.position < GuildData.GetSelfGuildPosition())
	-- 		if self.data.menu_index == 37 then
	-- 			self.btn:setEnabled(false)
	-- 		end
	-- 	end
	-- else
	-- 	if not self.btn:isEnabled() then
	-- 		self.btn:setEnabled(true)
	-- 	end
	-- end
	self.btn:setTitleText(self.data.btn_text or Language.Common.CustomMenuList[self.data.menu_index])
end

function MenuItemRender:OnClickHandler()
	if not MenuItemRender.param or not self.data or not self.data.menu_index then return end

	local data = MenuItemRender.param
	local role_name = data.name or data.role_name
	local role_id = data.role_id or 0
	if self.data.menu_index == 0 then			-- 查看装备
		BrowseCtrl.Instance:BrowRoleInfo(role_name, role_id, function (info)
			ViewManager.Instance:OpenViewByDef(ViewDef.Browse)
		end)
	elseif self.data.menu_index == 1 then		-- 查看资料
	elseif self.data.menu_index == 2 then		-- 进行交易
		ExchangeCtrl.ApplyExchange(role_name)
	elseif self.data.menu_index == 3 then		-- 私    聊
		ChatCtrl.Instance:AddPrivateRequset(role_name, role_id)
	elseif self.data.menu_index == 4 then		-- 加为好友
		SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.ADD, SOCIETY_RELATION_TYPE.FRIEND, role_id, role_name)
	elseif self.data.menu_index == 5 then		-- 邀请组队
		TeamCtrl.SendInviteJoinTeam(role_name)
	elseif self.data.menu_index == 6 then		-- 申请组队
		TeamCtrl.SendApplyJoinTeam(role_name)
	elseif self.data.menu_index == 7 then		-- 复制名称
	elseif self.data.menu_index == 8 then		-- 邀请切磋
	elseif self.data.menu_index == 9 then		-- 查看摆摊
	elseif self.data.menu_index == 10 then		-- 邀请入会
		GuildCtrl.InviteJoinGuildReq(role_name)
	elseif self.data.menu_index == 11 then		-- 进行聊天
	elseif self.data.menu_index == 12 then		-- 收为徒弟
	elseif self.data.menu_index == 13 then		-- 赠送鲜花
	elseif self.data.menu_index == 14 then		-- 屏蔽发言
	elseif self.data.menu_index == 15 then		-- 逐出队伍
		TeamCtrl.SendRemoveTeammate(role_id)
	elseif self.data.menu_index == 16 then		-- 升为队长
		TeamCtrl.SendSetTeamLeader(role_id)
	elseif self.data.menu_index == 17 then		-- 删除好友
		SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.DEL, SOCIETY_RELATION_TYPE.FRIEND, role_id, role_name)
	elseif self.data.menu_index == 18 then		-- 移除黑名
		SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.DEL, SOCIETY_RELATION_TYPE.BLACKLIST, role_id, role_name)
	elseif self.data.menu_index == 19 then		-- 拉入黑名
		SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.ADD, SOCIETY_RELATION_TYPE.BLACKLIST, role_id, role_name)
	elseif self.data.menu_index == 20 then		-- 查看名片
	elseif self.data.menu_index == 21 then		-- 拜其为师
	elseif self.data.menu_index == 22 then		-- 收其为徒
	elseif self.data.menu_index == 23 then		-- 拥    吻
	elseif self.data.menu_index == 24 then		-- GM会话框
	elseif self.data.menu_index == 25 then		-- 召唤队友
	elseif self.data.menu_index == 26 then		-- 赠送鞭炮
	elseif self.data.menu_index == 27 then		-- 赠送红包
	elseif self.data.menu_index == 28 then		-- 踢出池外
	elseif self.data.menu_index == 29 then		-- 使用吉祥
	elseif self.data.menu_index == 30 then		-- 查看仇人
	elseif self.data.menu_index == 31 then		-- 追踪仇人
		if self.find_alert == nil then
			self.find_alert = Alert.New()
		end
		self.find_alert:SetShowCheckBox(true)
		self.find_alert:SetLableString(Language.Society.TraceTip1)
		self.find_alert:SetOkFunc(function ()
			SocietyCtrl.Instance.TraceOtherPlayerReq(role_name)
			self.find_alert:Close()
			end)
		self.find_alert:Open()
		MenuItemRender.on_click_handler = nil
	elseif self.data.menu_index == 32 then		-- 移除仇人
		SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.DEL, SOCIETY_RELATION_TYPE.ENEMY, role_id, role_name)
	elseif self.data.menu_index == 33 then		-- 索要鲜花
	elseif self.data.menu_index == 34 then		-- 索要红包
	elseif self.data.menu_index == 35 then		-- 逐出行会
		if role_id then
			self.menu_alert = self.menu_alert or Alert.New()
			self.menu_alert:SetLableString(string.format(Language.Guild.ExpelMemberAlert, role_name))
			self.menu_alert:SetOkFunc(BindTool.Bind1(function ()
				GuildCtrl.GuildExpelMember(role_id)
			end, self))
			self.menu_alert:SetCancelString(Language.Common.Cancel)
			self.menu_alert:SetOkString(Language.Common.Confirm)
			self.menu_alert:SetShowCheckBox(false)
			self.menu_alert:Open()
		end
	elseif self.data.menu_index == 36 then		-- 更改职位
		local menu_list = {
			{menu_index = 38},
			{menu_index = 39},
			{menu_index = 40},
			{menu_index = 41},
			{menu_index = 42},
			{menu_index = 43},
		}
		--会长才有权禅让会长职位
		if GuildData.GetSelfGuildPosition() == SOCIAL_MASK_DEF.GUILD_LEADER then
			table.insert(menu_list, 1, {menu_index = 37})
		end
		MenuItemRender.on_click_handler = nil
		UiInstanceMgr.Instance:OpenCustomMenu(menu_list, data)
	elseif self.data.menu_index == 37 then		-- 会    长
		GuildCtrl.GuildLeaderYield(role_id)
	elseif self.data.menu_index == 38 then		-- 副 会 长
		GuildCtrl.GuildPositionChange(role_id, SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER)
	elseif self.data.menu_index == 39 then		-- 青龙堂主
		GuildCtrl.GuildPositionChange(role_id, SOCIAL_MASK_DEF.GUILD_TANGZHU_FIR)
	elseif self.data.menu_index == 40 then		-- 白虎堂主
		GuildCtrl.GuildPositionChange(role_id, SOCIAL_MASK_DEF.GUILD_TANGZHU_THI)
	elseif self.data.menu_index == 41 then		-- 朱雀堂主
		GuildCtrl.GuildPositionChange(role_id, SOCIAL_MASK_DEF.GUILD_TANGZHU_SRC)
	elseif self.data.menu_index == 42 then		-- 玄武堂主
		GuildCtrl.GuildPositionChange(role_id, SOCIAL_MASK_DEF.GUILD_TANGZHU_FOU)
	elseif self.data.menu_index == 43 then		-- 行会成员
		GuildCtrl.GuildPositionChange(role_id, SOCIAL_MASK_DEF.GUILD_COMMON)
	end

	if self.data.callback_func then
		self.data.callback_func()
	end
	if MenuItemRender.on_click_handler then
		MenuItemRender.on_click_handler()
	end
end

function MenuItemRender:CreateSelectEffect()
end
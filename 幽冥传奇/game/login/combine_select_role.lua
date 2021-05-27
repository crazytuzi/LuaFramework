CombineSelectRoleView = CombineSelectRoleView or BaseClass(BaseView)
--创建角色
function CombineSelectRoleView:__init()
	self.close_mode = CloseMode.CloseDestroy
	self.zorder = COMMON_CONSTS.ZORDER_LOGIN
	self.texture_path_list[1] = 'res/xui/role_create.png'
	self.config_tab = {
		{"role_create_ui_cfg", 4, {0}},
		{"role_create_ui_cfg", 5, {0}},
		{"role_create_ui_cfg", 1, {0}},
	}

	self:SetIsAnyClickClose(false)
	self.role_select_view_is_show = false
	self.select_role_vo = nil
	self.role_data_list = {}
end

function CombineSelectRoleView:__delete()
end

function CombineSelectRoleView:ReleaseCallBack()
	if nil ~= self.role_selectlist_view then
		self.role_selectlist_view:DeleteMe()
		self.role_selectlist_view = nil
	end

	if self.limit_alert then
		self.limit_alert:DeleteMe()
		self.limit_alert = nil
	end	
	
	self.select_role_vo = nil
	self.bg = nil
end

function CombineSelectRoleView:LoadCallBack()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(screen_w, screen_h))

	self.layout_left = self.node_tree.layout_left
	self.layout_left.node:setAnchorPoint(0, 1)
	self.layout_left.node:setPosition(0, screen_h)
	self.layout_left.node:setLocalZOrder(10)

	self.layout_center = self.node_tree.layout_center
	self.layout_center.node:setAnchorPoint(0.5, 0)
	self.layout_center.node:setPosition(screen_w / 2 + 250, 5)
	self.layout_center.node:setLocalZOrder(9)

	self.layout_right = self.node_tree.layout_right
	self.layout_right.node:setAnchorPoint(1, 1)
	self.layout_right.node:setPosition(screen_w, screen_h)

	local btn_size = self.layout_center.layout_begin_btn.node:getContentSize()
	RenderUnit.CreateEffect(1138, self.layout_center.layout_begin_btn.node, 99, nil, nil, btn_size.width / 2+10, btn_size.height / 2+25)
	XUI.AddClickEventListener(self.layout_center.layout_return_btn.node, BindTool.Bind(self.ClickReturn, self), true)
	XUI.AddClickEventListener(self.layout_center.layout_begin_btn.node, BindTool.Bind(self.ClickEnter, self), true, 1)

	local param = self.ph_list["ph_role_list_view"]
	self.role_selectlist_view = ListView.New()
	self.role_selectlist_view:CreateView({x = param.x-50, y = param.y+50, width = param.w, height = param.h, direction = ScrollDir.Vertical,
	itemRender = CSRoleSelectItemRender, ui_config = self.ph_list.ph_role_select_item})
	self.layout_left.node:addChild(self.role_selectlist_view:GetView(), 300, 300)
	self.role_selectlist_view:GetView():setAnchorPoint(0, 0)
	self.role_selectlist_view:SetItemsInterval(12)
	self.role_selectlist_view:SetMargin(20)
	self.role_selectlist_view:SetSelectCallBack(BindTool.Bind(self.OnClickItem, self))
	-- self.role_selectlist_view:GetView():setClippingEnabled(false)

	self.painting = RenderUnit.CreateEffect(nil, self.layout_center.node, 0)
end

function CombineSelectRoleView:OpenCallBack()
	if self.bg == nil then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.bg = XUI.CreateImageView(screen_w / 2, screen_h / 2, ResPath.GetBigPainting("select_role_bg", true), true)
		self.bg:setScale(1)
		self.root_node:addChild(self.bg, -1)
	end
end

function CombineSelectRoleView:ShowIndexCallBack(index)
	self:UpdateRoleList()
end

function CombineSelectRoleView:UpdateRoleList()
	if nil == self.role_selectlist_view then return end
	local user_vo = GameVoManager.Instance:GetUserVo()
	self.role_data_list = user_vo.role_list
	local role_data_list = {}
	local count = math.max(#self.role_data_list, 3)
	for i = 1, count do
		role_data_list[i] = self.role_data_list[i] or {is_create = true}
	end
	self.role_selectlist_view:SetDataList(role_data_list)
	self.role_selectlist_view:JumpToTop(true)
	self.role_selectlist_view:SelectIndex(1)
end

--点击返回
function CombineSelectRoleView:ClickReturn()
	self.select_role_vo = nil
	self:SetRoleSelectVisible(false)
	self:Close()
	LoginController.Instance:CreateRoleViewReturnLogin()
end

function CombineSelectRoleView:OpenRoleSelect()
	self:SetRoleSelectVisible(true)
	self:UpdateRoleList()
end

function CombineSelectRoleView:SetRoleSelectVisible(is_show)
	self.role_select_view_is_show = is_show
	LoginController.Instance.loginview.node_tree.layout_bg.node:setVisible(not is_show)
	LoginController.Instance.loginview.node_tree.layout_bg.layout_select_sever_list.node:setVisible(not is_show)
	LoginController.Instance.loginview.node_tree.layout_bg.layout_server_recommend.node:setVisible(not is_show)
	LoginController.Instance.loginview.node_tree.layout_bg.layout_all.node:setVisible(not is_show)
	self.root_node:setVisible(is_show)
end

--点击进入游戏
function CombineSelectRoleView:ClickEnter()
	if self.select_role_vo then
		LoginController.Instance:TryEnterGameServer(self.select_role_vo)
		AdapterToLua:getInstance():setDataCache("LAST_SELECT_ROLE", tostring(self.select_role_vo.role_id))
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.SelectRole, true)
	end
end

--选择格子
function CombineSelectRoleView:OnClickItem(cell)
	if cell ~= nil and cell:GetData() ~= nil then
		local data = cell:GetData()
		if cell:GetData().is_create then
			if self:IsLimitCreateRoleWithSpid() then
				self.role_selectlist_view:CancelSelect()
				self.select_role_vo = nil
			else	
				LoginController.Instance:DoOpenCreateRoleView()
				self:Close()
			end
		else
			self.select_role_vo = data

			local screen_w = HandleRenderUnit:GetWidth()
			local screen_h = HandleRenderUnit:GetHeight()
			local painting_cfg = ROLE_MODEL_POS_SCALE_CFG[data.sex] and ROLE_MODEL_POS_SCALE_CFG[data.sex][data.prof] or {0, 0, 1}
			local painting_frametime = painting_cfg[4] or 0.18
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(ROLE_MODEL_SHOW_EFFECT[data.sex][data.prof])
			-- self.painting:setPosition((painting_cfg[1] or 0) + 825, (painting_cfg[2] or 0) + 380)
			self.painting:setPosition((painting_cfg[1] or 0) + (130), (painting_cfg[2] or 0) + (420))
			self.painting:setScale(painting_cfg[3] or 1)
			self.painting:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, painting_frametime, false)
		end
	else
	end
end

function CombineSelectRoleView:IsLimitCreateRoleWithSpid(spid)
	local user_vo = GameVoManager.Instance:GetUserVo()
	local limit_day = user_vo.create_role_limit_day
	if limit_day and limit_day > 0 then
		local now_server_time = GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - GLOBAL_CONFIG.client_time)
		if 0 < user_vo.open_time then
			local time_space = now_server_time - user_vo.open_time
			local compare_time = limit_day * 24 * 3600  --开服限制天以上
			if time_space > compare_time then 
				if user_vo:GetRoleCmpMaxLevel() < user_vo.create_role_limit_level then --最大等级角色的等级小于90级不能创角
					if nil == self.limit_alert then
						self.limit_alert = Alert.New("")
						self.limit_alert.zorder = COMMON_CONSTS.ZORDER_MAX
						self.limit_alert:SetModal(true)
						self.limit_alert:SetIsAnyClickClose(false)
						self.limit_alert:SetOkString(Language.Common.Confirm)
						self.limit_alert:SetCancelString(Language.Common.Cancel)
					end
					self.limit_alert:SetLableString(Language.Common.CreateRoleLimitTip)
					self.limit_alert:Open()
					self.limit_alert:NoCloseButton()
					return true
				end
			end	
		end	
	end	

	return false
end

----------------------------------------
-- 角色render
----------------------------------------
CSRoleSelectItemRender = CSRoleSelectItemRender or BaseClass(BaseRender)
function CSRoleSelectItemRender:__init()
	self:AddClickEventListener()
	self.need_create_select_eff = false
	self.root_x = 445 / 2
end

function CSRoleSelectItemRender:__delete()
	if self.del_alert then
		self.del_alert:DeleteMe()
		self.del_alert = nil
	end
end

function CSRoleSelectItemRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.RichTextSetCenter(self.node_tree.layout_root.rich_lv.node)

	-- self.rich_role_name = RichTextUtil.ParseRichText(nil, "")
	-- self.rich_role_name:setAnchorPoint(0, 0)
	-- self.rich_role_name:setVisible(false)
	-- XUI.RichTextSetCenter(self.rich_role_name)
	-- self.node_tree.layout_root.node:addChild(self.rich_role_name, 10)

	-- self.root_x = self.node_tree.layout_root.node:getPositionX()
	-- self.node_tree.layout_root.node:setPositionX(self.index % 2 == 0 and self.root_x + 80 or self.root_x)	
end

function CSRoleSelectItemRender:OnFlush()
	if nil == self.data then
		return
	end

	self.node_tree.layout_root.rich_lv.node:setVisible(not self.data.is_create)
	self.node_tree.layout_root.img_head_icon.node:setVisible(not self.data.is_create)

	if self.data.is_create then
		-- self.node_tree.layout_root.img_head_icon.node:loadTexture(ResPath.GetRoleCreate(string.format("select_role_%d", 0)))
		self.node_tree.layout_root.role_name.node:setString("")
	else
		-- local view_size = self.view:getContentSize()
		self.node_tree.layout_root.role_name.node:setString(self.data.role_name)
		local circle = self.data.cycle_level > 0 and "[" .. self.data.cycle_level .. "转]" or ""
		local content = circle .. string.format("{wordcolor;55ff00;Lv.%s}", self.data.level)
		RichTextUtil.ParseRichText(self.node_tree.layout_root.rich_lv.node, content, 18, COLOR3B.DEEP_R_Y)
		
		self.node_tree.layout_root.img_head_icon.node:loadTexture(ResPath.GetRoleCreate(string.format("img_head_%d", self.data.sex)))
	end
	-- local posx = self.node_tree.layout_root.img_head_icon.node:getPositionX()
	self.node_tree.layout_root.img_head_icon.node:setPositionX(self.data.sex == 0 and 50 or 36)
	self:ShowDelIcon(not self.data.is_create)
end

function CSRoleSelectItemRender:ShowDelIcon(show)
	if show and nil == self.del_stamp then
		local size = self.view:getContentSize()
		self.del_stamp = XUI.CreateImageView(290, 65, ResPath.GetRoleCreate("btn_del"))
		self.node_tree.layout_root.node:addChild(self.del_stamp, 1001)
		XUI.AddClickEventListener(self.del_stamp, BindTool.Bind(self.OnDelHandler, self), true)
	elseif self.del_stamp then
		self.del_stamp:setVisible(show)
	end
end

function CSRoleSelectItemRender:OnDelHandler()
	if self.del_alert == nil then
		self.del_alert = Alert.New()
		self.del_alert.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER * 10
	end
	if self.data.guild_name ~= "" then
		self.del_alert:SetLableString(Language.RoleCreate.DelGuildTip)
		self.del_alert:SetOkFunc(nil)
	else
		self.del_alert:SetLableString(Language.RoleCreate.DelTip)
		self.del_alert:SetOkFunc(BindTool.Bind(self.DelRole, self))
	end
	self.del_alert:Open()
end

function CSRoleSelectItemRender:DelRole()
	LoginController.Instance:SendDelRoleReq(self.data.role_id)
end

function CSRoleSelectItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	-- local x = self.index % 2 == 0 and self.root_x + 80 or self.root_x
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2-12, ResPath.GetRoleCreate("role_select_img"))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 0)
end

function CSRoleSelectItemRender:CanSelect()
	return true
end

-- function CSRoleSelectItemRender:SetRootOffY(value)
-- 	if self.node_tree.layout_root == nil then return end
-- 	self.node_tree.layout_root.node:setPositionX(self.root_x + value)
-- end

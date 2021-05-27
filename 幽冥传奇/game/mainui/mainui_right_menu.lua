----------------------------------------------------------
--主ui上的右侧游戏图标栏
--都是规则排列的，零碎的请在mainui_smallparts处理
--@hbf
----------------------------------------------------------

MainUiIconbar = MainUiIconbar or BaseClass()

local act_x = {177, 560}
function MainUiIconbar:InitRightMenu()
	-- create ui
	self.view_hadle = {}
	local ui_config = ConfigManager.Instance:GetUiConfig("main_ui_cfg")
	local ui_cfg = nil
	for k, v in pairs(ui_config) do
		if v.n == "layout_right" then
			ui_cfg = v
			break
		end
	end
	local ui_node_list, ui_ph_list = {}, {}
	HandleRenderUnit:AddUi(XUI.GeneratorUI(ui_cfg, nil, nil, ui_node_list, nil, ui_ph_list).node, COMMON_CONSTS.RIGHT_MENU_BAR, COMMON_CONSTS.RIGHT_MENU_BAR)
	local offest_x = cc.Director:getInstance():getOpenGLView():getFrameSize().width - 1380
	local right_top =  MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	ui_node_list.layout_right.node:setPositionX(right_top:getPositionX() - ui_node_list.layout_right.node:getContentSize().width / 2)
	ui_node_list.layout_right_menu.node:setTouchEnabled(true)
	ui_node_list.layout_right_menu.node:setPositionX(act_x[2])
	XUI.AddClickEventListener(ui_node_list.btn_close.node, function ()
		self:OnFlushShow()
	end)

	self.is_act = false
	self.view_hadle.is_show = false
	self.view_hadle.show = function (value)
		-- ui_node_list.layout_right_menu.node:setVisible(true)
		if self.is_act then
			return
		end
		self.is_act = true
		ui_node_list.layout_right_menu.node:stopAllActions()
		local y = ui_node_list.layout_right_menu.node:getPositionY()
		local x = value and act_x[1] or act_x[2]
		local action = cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(x, y)), cc.CallFunc:create(function ()
			self.is_act = false
		end))
		ui_node_list.layout_right_menu.node:runAction(action)
	end

	-- 图标列表
	if nil == self.right_bottom_icons or nil == self.right_center_icons or nil == self.right_top_icons then
		self.right_bottom_icons = self:CreateMenu(MenuUiRightBottomIcons, ui_ph_list.ph_bottom_list, ui_ph_list.ph_item, ui_node_list.layout_right_menu.node)
		self.right_center_icons = self:CreateMenu(MenuUiRightIcons, ui_ph_list.ph_center_list, ui_ph_list.ph_item, ui_node_list.layout_right_menu.node)
		self.right_top_icons = self:CreateMenu(MenuUiRightTopIcons, ui_ph_list.ph_list, ui_ph_list.ph_item, ui_node_list.layout_right_menu.node)
	end

	--右下菜单
	local root_size = self.mt_layout_root:getContentSize()
	-- self.mt_layout_right = MainuiMultiLayout.CreateMultiLayout(root_size.width- 36, root_size.height - 344, cc.p(1, 1), cc.size(0, 0), self.mt_layout_root, 0)
	-- self.mt_layout_right:setVisible(false)

	self.img_menu = XUI.CreateImageView(root_size.width - 36 - 15, root_size.height - 270, ResPath.GetMainui("img_menu"), true)
	self.mt_layout_root:TextureLayout():addChild(self.img_menu, 99)
	XUI.AddClickEventListener(self.img_menu, BindTool.Bind(self.OnFlushShow, self), true)
	local remind_bg_img = XUI.CreateImageView(47, 57, ResPath.GetMainui("remind_flag"))
	self.img_menu:addChild(remind_bg_img, 1, 1)
	self.img_menu:setVisible((not IS_ON_CROSSSERVER))

	-- self.right_icons = {}
	-- local cfg_list = MenuUiRightIcons

	-- local icon = nil
	-- for k, v in pairs(cfg_list) do
	-- 	icon = self:CreateMainuiIcon(self.mt_layout_right, v.res, v)
	-- 	table.insert(self.right_icons, icon)
	-- 	if v.remind then
	-- 		icon:SetRemindNum(1)
	-- 	end

	-- 	if v.remind_group then
	-- 		self.remind_icon_list[v.remind_group] = icon
	-- 	end

	-- 	if v.vis_cond then
	-- 		self.cond_list[v.vis_cond] = icon
	-- 	end

	-- 	icon:SetBottomContent(self:GetIconBottomContent(v.view_pos))
	-- 	icon:AddClickEventListener(BindTool.Bind(self.OnClickIcon, self, icon))
	-- end
end

function MainUiIconbar:CreateMenu(data, ph, ph_item, parent)
	local list = {}
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 3, ph_item.h + 1, ListMenuIcon, ScrollDir.Vertical, false, ph_item)
	grid_scroll:SetDataList(data)
	grid_scroll:JumpToTop()

	for i,v in ipairs(data) do
		local icon = grid_scroll:GetItems()[i]
		if v.remind then
			icon:SetRemindNum(1)
		end

		if v.remind_group then
			self.remind_icon_list[v.remind_group] = icon
		end

		if v.vis_cond then
			self.cond_list[v.vis_cond] = icon
		end
	end

	list.OnCondChange = function ()
		local icons = {}
		for k,v in ipairs(data) do
			if (nil == v.vis_cond) or (v.vis_cond and GameCondMgr.Instance:GetValue(v.vis_cond)) then
				table.insert(icons, v)
			end
		end
		grid_scroll:SetDataList(icons)
	end

	parent:addChild(grid_scroll:GetView(), 300)

	list.grid_scroll = grid_scroll
	return list
end

function MainUiIconbar:UpdateRightIconPos()
	-- self.right_center_icons.OnCondChange()
	-- local line_count = 5
	-- local size = MainUiIconbar.ICON_SIZE

	-- self:SetIconsVisAndSort(self.right_icons)

	-- local row, col, mod = 0, 0, 0
	-- local x_interval = 0
	-- local y_interval = 0
	-- local x_offset = -10
	-- local y_offset = -18
	-- for i, v in ipairs(self.right_icons) do
	-- 	if v:IsVisible() then
	-- 		mod = v.align_order % line_count
	-- 		row = math.floor(v.align_order / line_count) + (mod == 0 and 0 or 1)
	-- 		col = mod == 0 and line_count or mod
	-- 		y = x_offset - ((col - 1) * (size.width + x_interval))
	-- 		x = y_offset - ((row - 1) * (size.height + y_interval))
	-- 		v:SetPosition(x, y)
	-- 	end
	-- end
end

function MainUiIconbar:IntoFight()
	if self.mt_layout_right:isVisible() then
		self:OnClickRightMenu()
	end
end

function MainUiIconbar:OnFlushShow()
	--切换时首先显示菜单栏
	self.view_hadle.is_show = not self.view_hadle.is_show
	MainuiCtrl.Instance:GetView():GetSkillLaout():SetVisible(not self.view_hadle.is_show)
	MainuiCtrl.Instance:GetView():GetSmallPart():RightMenuChange(not self.view_hadle.is_show)
	self.view_hadle.show(self.view_hadle.is_show)
	self.right_center_icons.grid_scroll:JumpToTop()
end

ListMenuIcon = ListMenuIcon or BaseClass(BaseRender)
function ListMenuIcon:__init()
	
end

function ListMenuIcon:__delete()
end

function ListMenuIcon:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_remind.node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree.icon.node, function ()
		if ViewManager.Instance:CanOpen(self.data.view_pos) then
			ViewManager.Instance:OpenViewByDef(self.data.view_pos)	
		else
			local Tips = GameCond[self.data.vis_cond].Tip
			SysMsgCtrl.Instance:FloatingTopRightText(Tips)
		end
	end)
	-- self.view:setScale(0.9)
end

function ListMenuIcon:SetRemindNum(num)
	if self.node_tree.img_remind then
		self.node_tree.img_remind.node:setVisible(num > 0)
	end
end

function ListMenuIcon:OnFlush()
	if nil == self.data then return end
	self.node_tree.icon.node:loadTexture(ResPath.GetMainui(string.format("icon_%s_img", self.data.res)))
end

function ListMenuIcon:CreateSelectEffect()
end
MainUiIconbar = MainUiIconbar or BaseClass()

function MainUiIconbar:InitFixedMenu()
	local root_size = self.mt_layout_root:getContentSize()
	self.mt_layout_fixed = MainuiMultiLayout.CreateMultiLayout(root_size.width - 265, 738, cc.p(1, 1), cc.size(0, 0), self.mt_layout_root, 2)
	self.mt_layout_fixed:setVisible(false)

	self.fixed_icons = {}
	local cfg_list = MenuUiFixedIcons

	local icon = nil
	for k, v in pairs(cfg_list) do
		icon = self:CreateMainuiIcon(self.mt_layout_fixed, v.res, v)
		table.insert(self.fixed_icons, icon)
		-- if v.remind then
			icon:SetRemindNum(1)
		-- end

		-- if v.remind_group then
		-- 	self.remind_icon_list[v.remind_group] = icon
		-- end

		-- if v.vis_cond then
		-- 	self.cond_list[v.vis_cond] = icon
		-- end

		icon:SetBottomContent(self:GetIconBottomContent(v.view_pos))
		icon:AddClickEventListener(BindTool.Bind(self.OnClickIcon, self, icon))
	end
end

function MainUiIconbar:HideIconChangeFixed()
	self.mt_layout_fixed:setVisible(not self.icon_mt_layout:isVisible())
end

function MainUiIconbar:UpdateFixedIconPos()
	local line_count = 8
	local size = MainUiIconbar.ICON_SIZE

	self:SetIconsVisAndSort(self.fixed_icons)

	local row, col, mod = 0, 0, 0
	local x_interval = 0
	local y_interval = 0
	local x_offset = -10
	local y_offset = -18
	for i, v in ipairs(self.fixed_icons) do
		if v:IsVisible() then
			mod = v.align_order % line_count
			row = math.floor(v.align_order / line_count) + (mod == 0 and 0 or 1)
			col = mod == 0 and line_count or mod
			x = x_offset - ((col - 1) * (size.width + x_interval))
			y = y_offset - ((row - 1) * (size.height + y_interval))
			v:SetPosition(x, y)
		end
	end
end
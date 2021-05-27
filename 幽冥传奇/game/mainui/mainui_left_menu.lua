----------------------------------------------------------
--主ui上的右侧游戏图标栏
--都是规则排列的，零碎的请在mainui_smallparts处理
--@hbf
----------------------------------------------------------

MainUiIconbar = MainUiIconbar or BaseClass()

function MainUiIconbar:InitLeftMenu()
	local root_size = self.mt_layout_root:getContentSize()
	self.mt_layout_left = MainuiMultiLayout.CreateMultiLayout(80, 630, cc.p(1, 1), cc.size(0, 0), self.mt_layout_root, 0)
	-- self.mt_layout_left:setVisible(false)

	self.left_icons = {}
	local cfg_list = MenuUiLeftIcons

	local icon = nil
	for k, v in pairs(cfg_list) do
		icon = self:CreateMainuiIcon(self.mt_layout_left, v.res, v)
		table.insert(self.left_icons, icon)
		if v.remind then
			icon:SetRemindNum(1)
		end

		if v.remind_group then
			self.remind_icon_list[v.remind_group] = icon
		end

		if v.vis_cond then
			self.cond_list[v.vis_cond] = icon
		end

		icon:SetBottomContent(self:GetIconBottomContent(v.view_pos))
		icon:AddClickEventListener(BindTool.Bind(self.OnClickIcon, self, icon))
	end
end

function MainUiIconbar:UpdateLeftIconPos()
	local line_count = 5
	local size = cc.size(76, 80)

	self:SetIconsVisAndSort(self.left_icons)

	local row, col, mod = 0, 0, 0
	local x_interval = 0
	local y_interval = 0
	local x_offset = -30
	local y_offset = -18
	local x, y = nil, nil
	for i, v in ipairs(self.left_icons) do
		if v:IsVisible() then
			mod = v.align_order % line_count
			row = math.floor(v.align_order / line_count) + (mod == 0 and 0 or 1)
			col = mod == 0 and line_count or mod
			x = x_offset + ((col - 1) * (size.width + x_interval))
			y = y_offset - ((row - 1) * (size.height + y_interval))
			v:SetPosition(x, y)
		end
	end
end

-- function MainUiIconbar:OnClickRightMenu()
-- 	--切换时首先显示菜单栏
-- 	MainuiCtrl.Instance:GetView():GetSkillLaout():SetVisible(self.mt_layout_left:isVisible())
-- 	MainuiCtrl.Instance:GetView():GetSmallPart():RightMenuChange(self.mt_layout_left:isVisible())
-- 	-- self.mt_layout_left:setVisible(true)
-- 	self.mt_layout_left:stopAllActions()
-- 	local scale_to = cc.ScaleTo:create(0.1, 0)
-- 	local scale_to2 = cc.ScaleTo:create(0.1, 1)
-- 	local action = cc.Sequence:create(scale_to, scale_to2)
-- 	GlobalTimerQuest:AddDelayTimer(function()
-- 		self.mt_layout_left:setVisible(not self.mt_layout_left:isVisible())
-- 	end, 0.1)
-- 	self.mt_layout_left:runAction(action)
-- end
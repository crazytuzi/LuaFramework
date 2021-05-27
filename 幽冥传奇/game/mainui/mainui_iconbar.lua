----------------------------------------------------------
--主ui上的游戏图标栏，如底部和顶部那几排的图标
--都是规则排列的，零碎的请在mainui_smallparts处理
--@author bzw
----------------------------------------------------------

MainUiIconbar = MainUiIconbar or BaseClass()
MainUiIconbar.Size = cc.size(540, 200)
MainUiIconbar.ICON_SIZE = cc.size(90, 90)
MainUiIconbar.CHILD_LAYOUT_SIZE = cc.size(380, 186)
MainUiIconbar.CLICK_BOSS_ICON = "click_boss_icon"

require("scripts/game/mainui/mainui_right_menu") --右侧菜单
require("scripts/game/mainui/mainui_left_menu")  --左侧菜单
require("scripts/game/mainui/mainui_fixed_menu")  --固定菜单

function MainUiIconbar:__init(mainui_view)
	self.mainui_view = mainui_view

	self.img_arrow = nil
	self.is_arrow_up = true			-- 显示功能图标根布局
	self.is_active_hide = false		-- 是否主动隐藏

	self.mt_layout_root = nil		-- 功能图标根布局
	self.mt_layout_top1 = nil		-- 第一页图标布局
	self.mt_layout_top2 = nil		-- 第二页图标布局
	self.mt_layout_right = nil		-- 右侧菜单布局
	self.mt_layout_child = nil		-- 孩子图标根布局
	self.mt_layout_child_t = {}		-- 孩子图标子布局列表
	self.is_top1_visible = true		-- 显示第一页内容

	self.top1_icon_list = {}		-- 第一页图标列表
	self.top2_icon_list = {}		-- 第二页图标列表
	self.child_views = {}			-- 孩子视图列表（模拟界面打开）
	self.child_icon_list = {}		-- 孩子图标列表
	self.remind_icon_list = {}		-- 提醒图标列表
	self.cond_list = {}				-- 带有显示条件的图标列表

	self.boss_refurbish_icon = nil  -- boss刷新提示信息

	self.boss_is_show = true        --是否显示boss信息

	self.refresh_boss_info = {}    --本次刷新的boss信息

	self.refresh_boss_list ={}

	self.run_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnOneSecond, self), 1)
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.BOSS_DATA_REFRESH, BindTool.Bind(self.SetBossListInfo, self))
end

function MainUiIconbar:__delete()
	for k, v in pairs(self.child_views) do
		v:DeleteMe()
	end
	self.child_views = {}
end

function MainUiIconbar:RegisterAllEvents()
	GlobalEventSystem:Bind(OtherEventType.TARGET_HEAD_CHANGE, BindTool.Bind(self.OnPassiveChangeState, self))
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
	GlobalEventSystem:Bind(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.RemindGroupChange, self))
    GlobalEventSystem:Bind(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnPassDay, self))
    -- GlobalEventSystem:Bind(OtherEventType.FIRST_LOGIN, BindTool.Bind(self.OnFirstRemind, self))--当天首次登陆
    GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnFirstRemind, self))   --登陆提醒
end

function MainUiIconbar:GetAuditFunIconCfgList()
	return {}
end

-- 在 mainui_def.lua 定义图标数据
function MainUiIconbar:GetFunIconCfgList()
	return {}
end

function MainUiIconbar:OpenChildView(view_pos)
	self.mt_layout_child:setVisible(true)
	for k, v in pairs(self.mt_layout_child_t) do
		v:setVisible(false)
	end
	self.mt_layout_child_t[view_pos]:setVisible(true)
end

function MainUiIconbar:CloseAllChildView()
	for k, v in pairs(self.child_views) do
		v:CloseHelper()
	end
end

function MainUiIconbar:CloseChildView()
	self.mt_layout_child:setVisible(false)
end

function MainUiIconbar:SetIconVisible(vis)
	self.mt_layout_root:setVisible(vis)
end

function MainUiIconbar:Init(mt_layout_root)

	local root_size = mt_layout_root:getContentSize()
	self.mt_layout_root = MainuiMultiLayout.CreateMultiLayout(root_size.width, root_size.height, cc.p(1, 1), root_size, mt_layout_root, 1)
	-- self.mt_layout_root:SetBgColor(COLOR3B.RED)

	--其他菜单
	self:InitRightMenu(mt_layout_root)
	self:UpdateRightIconPos()
	self:InitLeftMenu(mt_layout_root)
	self:UpdateLeftIconPos()
	-- self:InitFixedMenu(mt_layout_root)
	-- self:UpdateFixedIconPos()

	self.img_arrow = XUI.CreateImageView(root_size.width - 210, root_size.height - 30, ResPath.GetMainui("img_arrow"), true)
	self.img_arrow:setRotation(0)
	self.mt_layout_root:TextureLayout():addChild(self.img_arrow, 99)
	XUI.AddClickEventListener(self.img_arrow, BindTool.Bind(self.OnClickArrow, self), true)


	self.icon_mt_layout = MainuiMultiLayout.CreateMultiLayout(root_size.width - 265, root_size.height - 30, cc.p(1, 1), cc.size(0, 0), self.mt_layout_root, 0)
	self.mt_layout_top1 = MainuiMultiLayout.CreateMultiLayout(0, 0, cc.p(0, 0), cc.size(0, 0), self.icon_mt_layout, 0)
	self.mt_layout_top2 = MainuiMultiLayout.CreateMultiLayout(0, 0, cc.p(0, 0), cc.size(0, 0), self.icon_mt_layout, 0)
	
	-- self.boss_refurbish_icon = XUI.CreateImageView(root_size.width - 488, root_size.height - 50, ResPath.GetMainui("boss_refresh_bg"))
	-- --self.boss_refurbish_icon = XUI.CreateImageView(-226,-18, ResPath.GetMainui("boss_refresh_bg"))
	-- self.mt_layout_root:TextureLayout():addChild(self.boss_refurbish_icon, 100)
	-- self.boss_refurbish_icon.rtxt = XUI.CreateRichText(101 , 9 ,self.boss_refurbish_icon:getContentSize().width, self.boss_refurbish_icon:getContentSize().height, true)
	-- local text = string.format(Language.Common.BossRefresh,60,Language.Common.Ji,Language.Boss.TabGrop[2])
	-- RichTextUtil.ParseRichText(self.boss_refurbish_icon.rtxt, text, 18)
	-- self.boss_refurbish_icon:addChild(self.boss_refurbish_icon.rtxt )
	-- XUI.RichTextSetCenter(self.boss_refurbish_icon.rtxt )
	-- self.boss_refurbish_icon:setVisible(false)
	
	self.mt_layout_child = MainuiMultiLayout.New()
	local mainui_root_layout = self.mainui_view:GetRootLayout()
	local mainui_root_size = mainui_root_layout:getContentSize()
	self.mt_layout_child:CreateByParent(mainui_root_layout:EffectLayout(), COMMON_CONSTS.ZORDER_MAX)
	self.mt_layout_child:setPosition(mainui_root_size.width / 2, mainui_root_size.height / 2)
	self.mt_layout_child:setContentSize(cc.size(mainui_root_size.width, mainui_root_size.height))

	local real_root_node = XUI.CreateLayout(mainui_root_size.width / 2, mainui_root_size.height / 2, mainui_root_size.width, mainui_root_size.height)
	real_root_node:setTouchEnabled(true)
	real_root_node:setBackGroundColor(COLOR3B.BLACK)
	real_root_node:setBackGroundColorOpacity(120)
	self.mt_layout_child:TextureLayout():addChild(real_root_node, -2)
	XUI.AddClickEventListener(real_root_node, BindTool.Bind(self.CloseAllChildView, self))
	self.mt_layout_child:setVisible(false)

	self:OnFlushLayoutVisible()

	local cfg_list = MainuiIcons
	local icon = nil
    if IS_AUDIT_VERSION then
        local temp_list ={}
        for k, v in pairs(cfg_list) do
            if v.res ~= "24" and "104" ~= v.res  and "60" ~= v.res and "71" ~= v.res then
                table.insert(temp_list, v)
            end
        end
        cfg_list = temp_list
    end
	for k, v in pairs(cfg_list) do
	
		if v.area == "top1" then
			icon = self:CreateMainuiIcon(self.mt_layout_top1, v.res, v)
			table.insert(self.top1_icon_list, icon)
		elseif v.area == "top2" then
			icon = self:CreateMainuiIcon(self.mt_layout_top2, v.res, v)
			table.insert(self.top2_icon_list, icon)
		elseif v.area then
			if nil == self.child_icon_list[v.area] then
				local view_obj = ChildAreaView.New(v.area)
				view_obj:SetRealOpenFunc(BindTool.Bind(self.OpenChildView, self, v.area))
				view_obj:SetRealCloseFunc(BindTool.Bind(self.CloseChildView, self, v.area))
				self.child_views[v.area] = view_obj

				self.child_icon_list[v.area] = {}
				local mt_size = self.mt_layout_child:getContentSize()
				local mt_layout = MainuiMultiLayout.CreateMultiLayout(mt_size.width / 2, mt_size.height / 2, cc.p(0.5, 0.5), MainUiIconbar.CHILD_LAYOUT_SIZE, self.mt_layout_child, 0)
				-- mt_layout:SetBgColor(COLOR3B.RED)
				self.mt_layout_child_t[v.area] = mt_layout

				local child_icon_view_bg = XUI.CreateImageView(MainUiIconbar.CHILD_LAYOUT_SIZE.width / 2, MainUiIconbar.CHILD_LAYOUT_SIZE.height / 2 + 65, ResPath.GetBigPainting("mainui_child_bg"))
				-- child_icon_view_bg:setAnchorPoint(cc.p(0, 0))
				-- child_icon_view_bg:setTouchEnabled(true)
				-- child_icon_view_bg:setIsHittedScale(false)
				child_icon_view_bg:setTag(999)
				mt_layout:TextureLayout():addChild(child_icon_view_bg, 0)
				mt_layout:setVisible(false)
			end
			icon = self:CreateMainuiIcon(self.mt_layout_child_t[v.area], v.res, v)
			table.insert(self.child_icon_list[v.area], icon)
		end

		if v.remind then
			icon:SetRemindNum(1)
		end

		if v.remind_group then
			self.remind_icon_list[v.remind_group] = icon
		end

		if v.vis_cond then
			self.cond_list[v.vis_cond] = icon
		end

		if icon then
			icon:SetBottomContent(self:GetIconBottomContent(v.view_pos))
			icon:AddClickEventListener(BindTool.Bind(self.OnClickIcon, self, icon))
		end
	end
	
	self:UpdateIconPos()
	-- self:FlushMenuRemind()

	self:RegisterAllEvents()
	
end

local find_icon = function(icon_list, view_pos)
	for _, icon in pairs(icon_list) do
		if icon.GetData then
			local data = icon:GetData()
			if data and data.view_pos == view_pos then
				return icon
			end
		end
	end
end

local find_child_icon = function(list, view_pos)
	for _, child_list in pairs(list) do
		for __, icon in pairs(child_list) do
			if icon.GetData then
				local data = icon:GetData()
				if data and data.view_pos == view_pos then
					return icon
				end
			end
		end
	end
end
function MainUiIconbar:GetIcon(view_pos)
	return find_icon(self.top1_icon_list, view_pos) or find_icon(self.top2_icon_list, view_pos) or find_child_icon(self.child_icon_list, view_pos)
end

function MainUiIconbar:GetIconBottomContent(view_pos)
	local text = ""
	local open_server_days = OtherData.Instance:GetOpenServerDays()
	local open_server_time = OtherData.Instance:GetOpenServerTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	-- if view_pos == ViewDef.CrossBoss then
	-- 	if not IS_ON_CROSSSERVER then
	-- 		local left_time = open_server_time + CROSS_SERVER_OPEN_TIME - server_time
	-- 		if left_time > 0 then
	-- 			local hour = math.floor(left_time / 3600)
	-- 			local minute = math.floor((left_time / 60) % 60)
	-- 			local second = math.floor(left_time % 60)
	-- 			text = string.format("{color;1eff00;%d小时%d分%d秒开启}", hour, minute, second)
	-- 		end
	-- 	end
	-- end
	if view_pos == ViewDef.Explore.RareTreasure then
		local data = ExploreData.Instance:GetRareTreasureData()
		local left_time = (data.end_time or 0) + COMMON_CONSTS.SERVER_TIME_OFFSET - os.time()
		if left_time > 0 then
			text = string.format("{color;1eff00;%s}", TimeUtil.FormatSecond(left_time))
		end
	end

	return text
end

function MainUiIconbar:CreateMainuiIcon(parent, res, data)
	local width = res == "01" and 160 or MainUiIconbar.ICON_SIZE.width
	local height = res == "01" and 160 or MainUiIconbar.ICON_SIZE.height
	local icon = MainUiIcon.New(width, height)
	icon:Create(parent)
	icon:SetData(data)
	-- icon:SetScale(1)
	icon:SetBgFramePath(ResPath.GetMainui("icon_bg"))
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	icon:SetBottomPath(ResPath.GetMainui(string.format("icon_%s_word", res)), 12)

	return icon
end

function MainUiIconbar:OnClickMenu()
	self:ChangeShowState(not self.is_top1_visible)
end

function MainUiIconbar:OnClickArrow()
	if not self.is_arrow_up then
		self.is_active_hide = false
		self:ShowIconBar()
		--GlobalEventSystem:Fire(MainUiIconbar.CLICK_BOSS_ICON,true)
	else
		self.is_active_hide = true
		self:HideIconBar()
	end
end

function MainUiIconbar:ShowIconBar()
	if self.is_arrow_up then
		return
	end

	self.is_arrow_up = true
	self.img_arrow:setRotation(0)
	self.icon_mt_layout:setVisible(true)
	self.icon_mt_layout:setScale(0)

	self.icon_mt_layout:stopAllActions()
	self.icon_mt_layout:runAction(cc.ScaleTo:create(0.1, 1))
	-- self:OnFlushBossIconPostion()
	-- self:HideIconChangeFixed()
end

function MainUiIconbar:HideIconBar()
	if not self.is_arrow_up then
		return
	end

	self.is_arrow_up = false
	self.img_arrow:setRotation(180)

	self.icon_mt_layout:stopAllActions()
	local scale_to = cc.ScaleTo:create(0.1, 0)
	local action_complete_callback = function()
		self.icon_mt_layout:setVisible(false)
		-- self:OnFlushBossIconPostion()
		-- self:HideIconChangeFixed()
	end
	local action = cc.Sequence:create(scale_to)
	GlobalTimerQuest:AddDelayTimer(action_complete_callback, 0.1)
	self.icon_mt_layout:runAction(action)
end

function MainUiIconbar:HideAndShowIconBar()
	--切换时首先显示菜单栏
	self.icon_mt_layout:setVisible(true)
	self.is_arrow_up = true
	self.img_arrow:setRotation(25)

	self.icon_mt_layout:stopAllActions()
	local scale_to = cc.ScaleTo:create(0.1, 0)
	local scale_to2 = cc.ScaleTo:create(0.1, 1)
	local action = cc.Sequence:create(scale_to, scale_to2)
	GlobalTimerQuest:AddDelayTimer(function()
		self:OnFlushLayoutVisible()
	end, 0.1)
	self.icon_mt_layout:runAction(action)
end

function MainUiIconbar:OnFlushLayoutVisible()
	if self.is_top1_visible then
		self.mt_layout_top1:setVisible(true)
		self.mt_layout_top2:setVisible(false)
	else
		self.mt_layout_top1:setVisible(false)
		self.mt_layout_top2:setVisible(true)
	end
	-- self:OnFlushBossIconPostion()
end

function MainUiIconbar:OnFlushBossIconPostion()
	if self.mt_layout_top1:isVisible() then
		self.boss_refurbish_icon:setPosition(self.mt_layout_root:getContentSize().width-488,self.mt_layout_root:getContentSize().height-50)
	elseif self.mt_layout_top2:isVisible() then
		self.boss_refurbish_icon:setPosition(self.mt_layout_root:getContentSize().width-407,self.mt_layout_root:getContentSize().height-120)
	else
		self.boss_refurbish_icon:setPosition(self.mt_layout_root:getContentSize().width-405,self.mt_layout_root:getContentSize().height-30)
	end
	if self.icon_mt_layout:isVisible() == false then
		self.boss_refurbish_icon:setPosition(self.mt_layout_root:getContentSize().width-405,self.mt_layout_root:getContentSize().height-30)
	end
end

function MainUiIconbar:ChangeShowState(show_menu)
	self:HideAndShowIconBar()
	self.is_top1_visible = show_menu
end

function MainUiIconbar:ChangeShowStateComoplete(show_menu)

end

function MainUiIconbar:FlushMenuRemind()
	local node = self.img_menu:getChildByTag(1)
	if node then
		local num = 0
		for k, v in pairs(self.remind_icon_list) do
			if v:GetRemindNum() > 0 then
				num = 1
				break
			end
		end
		node:setVisible(num > 0)
	end
end


function MainUiIconbar:OnPassiveChangeState(is_show, is_active_hide)
	if nil ~= is_active_hide then
		self.is_active_hide = is_active_hide
	end
	if is_show then
		self:HideIconBar()
	else
		if not self.is_active_hide then
			self:ShowIconBar()
		end
	end

	--右下菜单
	-- self:IntoFight()
end

function MainUiIconbar:OnPassDay()
	--刷新点击特效 首次点击后消失
	self:OnFirstRemind()
end

function MainUiIconbar:UpdateIconBottomContent(view_pos)
	local icon = self:GetIcon(view_pos)
	if icon then
		icon:SetBottomContent(self:GetIconBottomContent(view_pos))
	end
end

-- 最后一行根据数量进行偏移
function MainUiIconbar:GetOffsetX(max_count, line_count, index, x_offset)
	if math.floor(index / line_count) == math.floor((max_count - 1) / line_count) then
		return x_offset
	end

	return 0
end

-- 根据固定排列的图标得到要偏移的顺序数
function MainUiIconbar:GetIconAlighOffset(fixed_order_icon_list, order)
	local offset_count = 0
	for fixed_order, _ in pairs(fixed_order_icon_list) do
		if order >= fixed_order then
			offset_count = offset_count + 1
			fixed_order_icon_list[fixed_order] = nil -- 已经计算过偏移，移除
		end
	end
	return offset_count
end

-- 设置图标的显示隐藏，并计算好排列顺序
local icon_sort_func = function(a, b)
	return a:GetData().order < b:GetData().order
end
function MainUiIconbar:SetIconsVisAndSort(icon_list)
	local icon_data = nil
	local fixed_order_icon_list = {}
	local vis
	for _, v in pairs(icon_list) do
		icon_data = v:GetData()
		vis = (nil == icon_data.vis_cond) or GameCondMgr.Instance:GetValue(icon_data.vis_cond)
		-- vis = true
		v:SetVisible(vis)
		if vis then
			if nil ~= icon_data.fixed_order then--固定排列的图标
				v.align_order = icon_data.fixed_order
				fixed_order_icon_list[v.align_order] = v
			else
				v.align_order = 0
			end
		end
	end

	-- 计算非固定排列的图标的顺序，要根据固定排列的图标进行偏移
	table.sort(icon_list, icon_sort_func)
	local align_order = 0
	for _, v in pairs(icon_list) do
		if v.align_order == 0 and v:IsVisible() then
			align_order = align_order + 1
			align_order = align_order + self:GetIconAlighOffset(fixed_order_icon_list, align_order) -- 偏移
			v.align_order = align_order
		end
	end
end

-- 孩子图标排列
function MainUiIconbar:UpdateIconAllChildPos()
	-- child_icons
	local line_count = 3
	local size = MainUiIconbar.ICON_SIZE
	local layout_size = MainUiIconbar.CHILD_LAYOUT_SIZE
	local row, col, mod = 0, 0, 0
	local x_interval = (layout_size.width - line_count * size.width) / (line_count - 1)
	local y_interval = 5
	local x_offset = size.width / 2
	local y_offset = layout_size.height - size.height / 2
	local idx = 0
	local icon_data = nil
	for _, icons in pairs(self.child_icon_list) do
		self:SetIconsVisAndSort(icons)
		for i, v in ipairs(icons) do
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
end

-- 顶部图标排列
function MainUiIconbar:UpdateIconTopPos(icon_list)
	local line_count = 8
	local size = MainUiIconbar.ICON_SIZE

	-- self:SetIconsVisAndSort(icon_list)

	local row, col, mod = 0, 0, 0
	local x_interval = 0
	local y_interval = 0
	local x_offset = -10
	local y_offset = -18
	local idx = 0

	local fix_list = {}
	for i,v in ipairs(MainuiIcons) do
		if v.fixed_order then
			fix_list[v.fixed_order] = true
		end
	end

	local checkNext = nil
	checkNext = function (idx)
		if fix_list[idx] then
			idx = idx + 1
			return checkNext(idx)
		else
			return idx
		end
	end
	for i, v in ipairs(icon_list) do
		local icon_data = v:GetData()
		local vis = (nil == icon_data.vis_cond) or GameCondMgr.Instance:GetValue(icon_data.vis_cond)
		v:SetVisible(vis)
		if vis then
			idx = idx + 1
			idx = checkNext(idx)

			mod = idx % line_count
			row = math.floor(idx / line_count) + (mod == 0 and 0 or 1)
			col = mod == 0 and line_count or mod
			if idx == 1 then
				x_offset = -50
				y_offset = -42
			else
				x_offset = 4
				y_offset = -18				
			end
			x = x_offset - ((col - 1) * (size.width + x_interval))
			y = y_offset - ((row - 1) * (size.height + y_interval))
			v:SetPosition(x, y)
		end
	end
end

function MainUiIconbar:UpdateIconPos()
	self:UpdateIconTopPos(self.top1_icon_list)
	self:UpdateIconTopPos(self.top2_icon_list)
	self:UpdateRightIconPos()
	self:UpdateLeftIconPos()
	-- self:UpdateFixedIconPos()
	self:UpdateIconAllChildPos()
end

function MainUiIconbar:UpdateBrilliantIcon()
	for k, v in pairs(self.top1_icon_list) do
		if ViewDef.Explore.RareTreasure == v:GetData().view_pos then
			local rare_treasure_data = ExploreData.Instance:GetRareTreasureData()
			local res_id = rare_treasure_data.award_pools_index or 1
			local bg_icon_path = ResPath.GetMainui(string.format("rare_treasure_icon_%d", res_id))

			v:SetIconPath(bg_icon_path)
		end

		if ViewDef.ZsTaskView == v:GetData().view_pos then
			local res_id = ZsTaskData.Instance:GetBigTaskIndex()
			local bg_icon_path = ResPath.GetMainui(string.format("zs_task_%d", res_id))

			v:SetIconPath(bg_icon_path)
		end

		if ViewDef.ChargeGift == v:GetData().view_pos then
			local res_id = ChargeGiftData.Instance:GetGiftGrade() or 1
			local bg_icon_path = ResPath.GetMainui(string.format("change_%d", res_id))

			v:SetIconPath(bg_icon_path)
		end

		local view_index = 1
		while(ViewDef["ActivityBrilliant" .. view_index])
		do
			if ViewDef["ActivityBrilliant" .. view_index] == v:GetData().view_pos then
				local res_id = ActivityBrilliantData.Instance:GetActViewResId(view_index)
				local bg_icon_path = ResPath.GetActivityIcon(string.format("brilliant_act_icon_%d", res_id))

				v:SetIconPath(bg_icon_path)
			end
			view_index = view_index + 1
		end
	end
end

function MainUiIconbar:OnClickIcon(icon)
	local size = icon:GetContentSize()
	local data = icon:GetData()

	local view_name = data.view_name
	if data.view_pos then
		if data.open_cond == nil or GameCondMgr.Instance:GetValue(data.open_cond) then
			ViewManager.Instance:OpenViewByDef(data.view_pos)

			if data.view_pos == ViewDef.ChargeFirst or data.view_pos == ViewDef.ChargeGift  then
				MainuiCtrl.Instance:SetRemoveEffect(data.view_pos)
			end
		else
			local text = GameCond[data.open_cond] and GameCond[data.open_cond].Tip	or ""
			SysMsgCtrl.Instance:FloatingTopRightText(text)
		end
	end

	if nil == self.mt_layout_child_t[data.view_pos] then
		self:CloseAllChildView()
	end
	if (data.view_pos == ViewDef.Boss) then
		--GlobalEventSystem:Fire(MainUiIconbar.CLICK_BOSS_ICON,false)
		-- self.boss_refurbish_icon:setVisible(false)
		self.boss_is_show = false
	end

	--点击去除当天首次登陆添加的提醒特效
	if icon.CloseOnceEffect then icon.CloseOnceEffect() end
end

function MainUiIconbar:OnGetUiNode(node_name)
	local view_node = ViewManager.Instance:GetViewByStr(node_name)
	
	if nil == view_node then
		return nil, false
	end

	-- for k, v in pairs(self.right_icons) do
	-- 	if v:GetData().view_pos == view_node then
	-- 		if self.mt_layout_top1:isVisible() and self.icon_mt_layout:isVisible() then
	-- 			return v:GetView(), true 
	-- 		else
	-- 			if self.mt_layout_top2:isVisible() then
	-- 				return self.img_menu, false
	-- 			else
	-- 				return self.img_arrow, false
	-- 			end
	-- 		end
	-- 	end
	-- end
	for k, v in pairs(self.top1_icon_list) do
		--print(v:GetData().view_pos.name, view_node.name, v:GetData().view_pos == view_node)
		if v:GetData().view_pos.name == view_node.name then
			if self.mt_layout_top1:isVisible() and self.icon_mt_layout:isVisible() then
				--print(">>>>>>>222222",v:GetPosition())
				return v:GetView(), true 
			else
				if self.mt_layout_top2:isVisible() then
					return v:GetView(), false
				else
					return v:GetView(), false
				end
			end
		end
	end
	
	for k, v in pairs(self.top2_icon_list) do
		if v:GetData().view_pos == view_node then
			if self.mt_layout_top2:isVisible() and self.icon_mt_layout:isVisible() then
				return v:GetView(), true 
			else
				if self.mt_layout_top1:isVisible() then
					return self.img_menu, false
				else
					return self.img_arrow, false
				end
			end
		end
	end
	for area, v in pairs(self.child_icon_list) do
		for _, icon in pairs(v) do
			if icon:GetData().view_pos == view_node then
				local mt = self.mt_layout_child_t[area]
				if mt and mt:isVisible() and self.mt_layout_child:isVisible() then
					return icon:GetView(), true
				else
					local node, is_next = self:OnGetUiNode(ViewManager.Instance:GetStrByView(area))
					return node, false
				end
			end
		end
	end

	for k, v in pairs(self.left_icons or {}) do
		if v:GetData().view_pos == view_node then
			return v:GetView(), true 
		end
	end

	return nil, true
end

function MainUiIconbar:RemindChange(remind_name, num)
end

function MainUiIconbar:RemindGroupChange(group_name, num)
	if self.remind_icon_list[group_name] then
		if not self.remind_icon_list[group_name].show_remind then
			if group_name == "BossView" then
				self.remind_icon_list[group_name]:SetRemindNum(num, nil, 100)
			end
			self.remind_icon_list[group_name]:SetRemindNum(num)
		end

		-- self:FlushMenuRemind()
	end
end

function MainUiIconbar:OnGameCondChange(cond_name)
	if self.cond_list[cond_name] then
		self:UpdateIconPos()
	end
end

function MainUiIconbar:OnOneSecond()
	self:UpdateIconBottomContent(ViewDef.CrossBoss)
end

function MainUiIconbar:OnFirstRemind(is_cross_login) 
	-- if not is_cross_login then return end 跨天数据
	local need_remind_icon = {{"RefiningExp"}}
	local need_eff_icon = {{"ZsTaskView"}}
    -- if IS_AUDIT_VERSION then
    --     need_remind_icon = {"Shop", "ChargeFirst", "ChargeEveryDay","RefiningExp","OpenSerVeGift","OpenServiceAcitivity",}
    -- end
	for i,v in pairs(need_remind_icon) do
		-- local is_close = false
		local icon = self:GetIcon(ViewDef[v[1]])
		if icon then
			-- icon:PlayIconEffect(400, {x = 48, y = 47}, 9999, 1)
			icon:SetRemindNum(1)
			icon.show_remind = true
			function icon.CloseOnceEffect()
				-- if is_close then return end
				-- icon:RemoveIconEffect()
				-- is_close = true
				icon:SetRemindNum(RemindManager.Instance:GetRemindGroup(v[2]))
				icon.CloseOnceEffect = nil
				icon.show_remind = nil
			end
		end

	end

	for i1,v1 in pairs(need_eff_icon) do
		local icon = self:GetIcon(ViewDef[v1[1]])
		if icon then
			icon:PlayIconEffect(400, {x = 48, y = 47}, 9999, 1)
			-- icon.show_remind = true
			function icon.CloseOnceEffect()
				if is_close then return end
				-- is_close = true
				icon:RemoveIconEffect()
			end
		end

	end
end
---------------------------------------------------
-- 刷新boss提示信息 end
---------------------------------------------------

-- function MainUiIconbar:SetBossListInfo()
-- 	if(self.refresh_boss_info ~= nil) then
-- 		self.refresh_boss_info = nil
-- 	end
-- 	self.refresh_boss_info = {}
-- 	local SecretBossList = SecretBossData.Instance:GetSecretBossList()
-- 	local BossZhiJiaList =  HouseBossData.Instance:GetHouseBossList()
-- 	local WildBossList = WildBossData.Instance:GetBossListInfo()
-- 	for k,v in pairs (WildBossList) do
-- 		if (v.boss_state == 0) then
-- 			table.insert(self.refresh_boss_info,v)
-- 		end
-- 	end
-- 	for k,v in pairs (BossZhiJiaList) do
-- 		if (v.boss_state == 0) then
-- 			table.insert(self.refresh_boss_info,v)
-- 		end
-- 	end
-- 	self:SortList(self.refresh_boss_info)
-- 	for k,v in pairs (SecretBossList) do
-- 		if (v.boss_state == 0) then
-- 			table.insert(self.refresh_boss_info,v)
-- 		end
-- 	end
-- 	if(#self.refresh_boss_info > 0 and not IS_ON_CROSSSERVER) then
-- 		self:RefreshBossUiInfo() 
-- 	else
-- 		self.boss_refurbish_icon:setVisible(false)
-- 	end
-- end

-- function MainUiIconbar:SortList(list)
-- 	table.sort(list,function (a,b)
-- 		if a.boss_lunhui~=b.boss_lunhui then
-- 			return a.boss_lunhui < b.boss_lunhui
-- 		else
-- 			if a.boss_circle~=b.boss_circle then
-- 				return a.boss_circle < b.boss_circle
-- 			else
-- 				if a.boss_level~= b.boss_level then
-- 					return a.boss_level < b.boss_level
-- 				else
-- 					return false
-- 				end
-- 			end
-- 		end
-- 	end)
-- end

-- function MainUiIconbar:RefreshBossUiInfo()  
-- 	if(nil ~= next(self.refresh_boss_info)) then
-- 		local show_boss = self.refresh_boss_info[#self.refresh_boss_info]
-- 		--boss类型
-- 		local name = nil
-- 		if(show_boss.boss_type == 1) then
-- 			name = Language.Common.WildBoss
-- 		elseif(show_boss.boss_type == 2)then
-- 			name = Language.Common.HouseBoss
-- 		elseif(show_boss.boss_type == 3)then
-- 			name = Language.Common.SecretBoss
-- 		end

-- 		local text = 1
-- 		if(show_boss.boss_lunhui > 0)then
-- 			text = string.format(Language.Common.BossRefresh,show_boss.boss_lunhui,Language.Common.BossDao,name)
-- 		else
-- 			if(show_boss.boss_circle>0) then
-- 				text = string.format(Language.Common.BossRefresh,show_boss.boss_circle,Language.Common.BossZhuan,name)
-- 			else
-- 				if(show_boss.boss_level>0) then
-- 					text = string.format(Language.Common.BossRefresh,show_boss.boss_level,Language.Common.BossJi,name)
-- 				else
-- 					text = string.format(Language.Common.BossRefresh,"","",name)
-- 				end
-- 			end
-- 		end

-- 		self.boss_refurbish_icon:setVisible(true)
-- 		RichTextUtil.ParseRichText(self.boss_refurbish_icon.rtxt, text, 18)
-- 		self:OnPassiveChangeState(false,false)  --自动弹出上方的菜单
-- 	end	
-- end

-- ---------------------------------------------------
-- -- 刷新boss提示信息 end
-- ---------------------------------------------------

-- function MainUiIconbar:SetBossRemindVisible(vis)
-- 	--self.boss_refurbish_icon:setVisible(vis)
-- end



-- 刷新boss提示信息 end
---------------------------------------------------
function MainUiIconbar:SetBossListInfo()
	if IS_ON_CROSSSERVER then return end
	if(self.boss_is_show == true ) then
		local refresh_boss_list = BossData.Instance:GetSceneRefreshBossList()
		if(nil ~= next(refresh_boss_list)) then
			self:RefreshBossInfo(refresh_boss_list)
			self.BossNum = #self.refresh_boss_info
			-- if(self.BossNum > 1) then
			-- 	self.BossNum = math.random(1,self.BossNum)   --随机一个
			-- end
			-- self:RefreshBossUiInfo() 
		else
			if(nil ~=self.boss_refurbish_icon) then
			 	self.boss_refurbish_icon:setVisible(false)
			end
		end
	end
end

function MainUiIconbar:RefreshBossInfo(refresh_boss_list)  --根据服务器传来的id找到相应配置信息
	if(nil ~= next(refresh_boss_list)) then
		local list = {}
		local boss_name = ""
		self.refresh_boss_info={}
		for k,v in pairs (refresh_boss_list) do
			local id = v.boss_id
			local boss_type = v.boss_type
			-- local SecretBossList = SecretBossData.Instance:GetSecretBossList()
			-- local BossZhiJiaList =  HouseBossData.Instance:GetHouseBossList()
			-- local PersonalList =PersonalBossData.Instance:GetPersonalBossList()
			list = {}
			if boss_type == 1 then
				list = WildBossData.Instance:GetBossListInfo()
				boss_name = Language.Common.WildBoss
			elseif boss_type == 2 then
				list = HouseBossData.Instance:GetHouseBossList()
				boss_name = Language.Common.HouseBoss
			elseif boss_type == 3 then
				list = SecretBossData.Instance:GetSecretBossList()
				boss_name = Language.Common.SecretBoss
			end
			for k,v in pairs(list) do
				if (v.boss_id == id and v.boss_state == 0 and BossData.Instance:GetRemindFlag(boss_type, v.rindex) == 0) then
					data={}
					data.boss_name = boss_name
					data.boss_level = v.boss_level
					data.boss_circle =v.boss_circle
					data.boss_lunhui = v.boss_lunhui
					table.insert(self.refresh_boss_info,data)
					break
				end
			end
		end
	end
	-- if(BossData.Instance:GetOnlineRefresh() == 0) then   --登录游戏时加上个人boss的刷新
	-- 	local list = PersonalBossData.Instance:GetPersonalBossList()
	-- 	for k,v in pairs(list) do
	-- 		if (v.state == 0) then
	-- 			data={}
	-- 			data.boss_name = Language.Common.PersonalBoss
	-- 			data.boss_level = v.boss_level
	-- 			data.boss_circle =v.boss_circle
	-- 			data.boss_lunhui = v.boss_lunhui
	-- 			table.insert(self.refresh_boss_info,data)
	-- 		end
	-- 	end
	-- end
end

function MainUiIconbar:RefreshBossUiInfo()  
	if(nil ~= next(self.refresh_boss_info)) then
		local name = self.refresh_boss_info[self.BossNum].boss_name 
		local level =self.refresh_boss_info[self.BossNum].boss_level or 0
		local circle = self.refresh_boss_info[self.BossNum].boss_circle or 0
		local dao = self.refresh_boss_info[self.BossNum].boss_lunhui or 0
		if(dao > 0)then
			text = string.format(Language.Common.BossRefresh,dao,Language.Common.BossDao,name)
		else
			if(circle>0) then
				text = string.format(Language.Common.BossRefresh,circle,Language.Common.BossZhuan,name)
			else
				if(level>0) then
					text = string.format(Language.Common.BossRefresh,level,Language.Common.BossJi,name)
				else
					text = string.format(Language.Common.BossRefresh,"","",name)
				end
			end
		end
		self.boss_refurbish_icon:setVisible(true)
		RichTextUtil.ParseRichText(self.boss_refurbish_icon.rtxt, text, 18)
		--self:OnPassiveChangeState(false,false)  --自动弹出上方的菜单
	    -- self.BossNum = self.BossNum-1
	    -- if( self.BossNum <= 0) then
	    -- 	self.boss_refurbish_icon:setVisible(false)
	    -- 	CountDown.Instance:RemoveCountDown(self.timer1)
	    -- end
	else
	 	self.boss_refurbish_icon:setVisible(false)
	end	
end

function MainUiIconbar:SetBossRemindVisible(vis)
	self.boss_refurbish_icon:setVisible(vis)
end


ChildAreaView = ChildAreaView or BaseClass(BaseView)
function ChildAreaView:SetRealOpenFunc(func)
	self.real_open_func = func
end
function ChildAreaView:SetRealCloseFunc(func)
	self.real_close_func = func
end
function ChildAreaView:OpenCallBack()
	if self.real_open_func then
		self.real_open_func()
	end
end
function ChildAreaView:CloseCallBack()
	if self.real_close_func then
		self.real_close_func()
	end
end

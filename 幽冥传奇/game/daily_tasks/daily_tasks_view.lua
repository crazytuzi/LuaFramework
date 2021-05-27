--------------------------------------------------------
-- 日常任务(降妖除魔)视图  配置 XiangYaoChuMoCfg
--------------------------------------------------------

DailyTasksView = DailyTasksView or BaseClass(BaseView)

function DailyTasksView:__init()
	self.texture_path_list[1] = 'res/xui/daily_tasks.png'
	-- self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		-- {"common2_ui_cfg", 1, {0}},
		{"daily_tasks_ui_cfg", 1, {0}},
		{"daily_tasks_ui_cfg", 2, {0}, false}, -- 默认隐藏 layout_receive_tasks
		{"daily_tasks_ui_cfg", 3, {0}, false}, -- 默认隐藏 layout_get_rewards
		-- {"common2_ui_cfg", 2, {0}},
	}

	self.data = {} --日常任务数据 
	self.item_cell = nil -- 物品图标列表
	self.start_part = nil -- 星星
	self.text_btn = nil -- "提升封神"文本按钮
	self.text_buy_time = nil 	-- "购买次数"文本按钮
end

function DailyTasksView:__delete()

end

--释放回调
function DailyTasksView:ReleaseCallBack()

	if self.item_cell then
		for _, v in pairs(self.item_cell) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.item_cell = nil
	end

	if self.one_item_cell then
		for _, v in pairs(self.one_item_cell) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.one_item_cell = nil
	end
	if self.one_click_to_complete_alert then
		self.one_click_to_complete_alert:DeleteMe()
		self.one_click_to_complete_alert = nil
	end
	if self.double_receiving_alert then
		self.double_receiving_alert:DeleteMe()
		self.double_receiving_alert = nil
	end
end

--加载回调
function DailyTasksView:LoadCallBack(index, loaded_times)
	-- 索引日常任务数据(只需索引一次)
	self.data = DailyTasksData.Instance:GetData()

	--按钮特效
	self.node_t_list["btn_receive_2"].remind_eff = RenderUnit.CreateEffect(23, self.node_t_list["btn_receive_2"].node, 1)

	self.node_t_list["lbl_one_key"].node:setString("消耗钻石：" .. XiangYaoChuMoCfg.oneKeyBindYb[1].count)
	self.node_t_list["lbl_doble_rew"].node:setString("消耗钻石：" .. XiangYaoChuMoCfg.doubleConsumeBindYb[1].count)

	-- 设置"刷星"费用
	if nil ~= XiangYaoChuMoCfg.shuaXin then
		self.node_t_list["lbl_consume"].node:setString(XiangYaoChuMoCfg.shuaXinCousume[1].count)
	end

	-- 创建星星
	local ph = self.ph_list["ph_stars"]
	local param = {x = ph.x, y = ph.y, star_num = XiangYaoChuMoCfg.shuaXin[1], interval_x = 5, parent = self.node_t_list["layout_receive_tasks"].node, zorder = 99}
	self.start_part = UiInstanceMgr.Instance:CreateStarsUi(param)

	self:CreateItemView()
	-- self:CreateTextBtn()
	self:CreateBuyTime()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_receive_task"].node, BindTool.Bind(self.OnReceiveTaskBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_flush_stars"].node, BindTool.Bind(self.OnFlushStarsBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_one_key"].node, BindTool.Bind(self.OnDirectCompleteBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_continue_task"].node, BindTool.Bind(self.OnContinueTaskBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_receive_1"].node, BindTool.Bind(self.OnReceiveBtn, self, 1))
	XUI.AddClickEventListener(self.node_t_list["btn_receive_2"].node, BindTool.Bind(self.OnReceiveBtn, self, 2))

	-- 数据监听
	EventProxy.New(DailyTasksData.Instance, self):AddEventListener(DailyTasksData.TASKS_DATA_CHANGE, BindTool.Bind(self.OnTasksDataChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(OfficeData.Instance, self):AddEventListener(OfficeData.OFFICE_LEVEL_CHANGE, BindTool.Bind(self.OnOfficeLevelChange, self))
end

function DailyTasksView:OpenCallBack()
	-- 请求除魔任务信息
	DailyTasksCtrl.Instance:SendDailyTasksReq(1)
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DailyTasksView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function DailyTasksView:ShowIndexCallBack(index)
	self:FlushDailyTasksView()
	self:FlushItemNumView()
	ViewManager.Instance:CloseViewByDef(ViewDef.Tasks) -- 加载完后关闭"任务面板"
end

function DailyTasksView:OnFlush()
	self:FlushTextBtn()
end

----------视图函数----------

-- 创建"提升封神"文本按钮
function DailyTasksView:CreateTextBtn()
	local ph = self.ph_list["ph_text_btn"]
	self.text_btn = RichTextUtil.CreateLinkText("提升封神", 19, COLOR3B.GREEN, nil, true)
	self.text_btn:setPosition(ph.x, ph.y)
	self.node_t_list["layout_receive_tasks"].node:addChild(self.text_btn, 20)
	XUI.AddClickEventListener(self.text_btn, BindTool.Bind(self.OnTextBtn, self), true)
	self:FlushTextBtn()
end

-- 创建"购买次数"文本按钮
function DailyTasksView:CreateBuyTime()
	local ph = self.ph_list["ph_buy_txt"]
	self.text_buy_time = RichTextUtil.CreateLinkText("购买次数", 19, COLOR3B.GREEN, nil, true)
	self.text_buy_time:setPosition(ph.x, ph.y)
	self.node_t_list["layout_receive_tasks"].node:addChild(self.text_buy_time, 20)
	XUI.AddClickEventListener(self.text_buy_time, BindTool.Bind(self.OnTextBuyTime, self), true)
end

-- 刷新"提升封神"文本按钮动作
function DailyTasksView:FlushTextBtn()
	local index = DeifyData.Instance.GetRemindIndex()
	if index == 1 then
		UiInstanceMgr.AddRectEffect({node = self.text_btn, init_size_scale = 1.3, act_size_scale = 1.6, offset_w =10, offset_h = 3, color = COLOR3B.GREEN})
	else
		UiInstanceMgr.DelRectEffect(self.text_btn)
	end
end

-- 创建"奖励物品"图标视图
function DailyTasksView:CreateItemView()
	local ph = nil
	local index = DailyTasksData.Instance:GetTaskRewIndex()
	-- 获取奖励物品配置
	local item_cfg = {}
	for k, v in pairs(XiangYaoChuMoCfg.reward[index].awards[1]) do
		item_cfg[k] = {type = v.type, item_id = v.id, is_bind = v.bind, num = 1}
	end

	if #item_cfg > 1 then
		self:SetDobleItem(item_cfg)
	else
		self:SetOneItem(item_cfg)
	end
end

-- 如果物品奖励为1个的时候
function DailyTasksView:SetOneItem(item_cfg)
	-- 共创建3个物品图标
	self.one_item_cell = {}
	for i = 1, 3 do
		ph = self.ph_list["ph_one_" .. i]
		self.one_item_cell[i] = BaseCell.New()
		self.one_item_cell[i]:GetView():setAnchorPoint(cc.p(0.5, 0.5))
		self.one_item_cell[i]:SetPosition(ph.x, ph.y)
	
		if item_cfg[1].type == 0 then
			self.one_item_cell[i]:SetData(item_cfg[1])
		else
			self.one_item_cell[i]:SetData(ItemData.FormatItemData(item_cfg[1]))
		end


		-- 把物品图标插入图层
		if i <= 1 then
			self.node_t_list["layout_receive_tasks"].node:addChild(self.one_item_cell[i]:GetView(), 20)
		else
			self.node_t_list["layout_get_rewards"].node:addChild(self.one_item_cell[i]:GetView(), 20)
		end
	end
end

-- 如果物品奖励为两个的时候
function DailyTasksView:SetDobleItem(item_cfg)
	-- 共创建6个物品图标
	self.item_cell = {}
	for i = 1, 6 do
		ph = self.ph_list["ph_item_cell_" .. i]
		self.item_cell[i] = BaseCell.New()
		self.item_cell[i]:GetView():setAnchorPoint(cc.p(0.5, 0.5))
		self.item_cell[i]:SetPosition(ph.x, ph.y)
		-- 设置物品数量
		if i%2 == 0 then
			if item_cfg[2].type == 0 then
				self.item_cell[i]:SetData(item_cfg[2])
			else
				self.item_cell[i]:SetData(ItemData.FormatItemData(item_cfg[2]))
			end
		else
			if item_cfg[1].type == 0 then
				self.item_cell[i]:SetData(item_cfg[1])
			else
				self.item_cell[i]:SetData(ItemData.FormatItemData(item_cfg[1]))
			end
		end

		-- 把物品图标插入图层
		if i <= 2 then
			self.node_t_list["layout_receive_tasks"].node:addChild(self.item_cell[i]:GetView(), 20)
		else
			self.node_t_list["layout_get_rewards"].node:addChild(self.item_cell[i]:GetView(), 20)
		end
	end
end

-- 刷新"奖励物品"数量视图
function DailyTasksView:FlushItemNumView()
	if self.data.stars_num == 0 then return end
	local cfg = XiangYaoChuMoCfg.reward[DailyTasksData.Instance:GetTaskRewIndex()].awards
	local text = nil
	local rich = nil
	-- local item_cfg = ItemData.Instance:GetItemConfig(cfg[1].id)
	local item_color = COLOR3B.GREEN--Str2C3b(string.format("%06x", item_cfg.color))
	
	if #cfg[self.data.stars_num] > 1 then
		local item_num1 = cfg[self.data.stars_num][1].count -- 经验数量
		local item_num2 = cfg[self.data.stars_num][2].count -- 声望卷轴数量

		-- 接受奖励数量显示
		text = "×" .. item_num1
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_item_num_1"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)
		text = "×" .. item_num2
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_item_num_2"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)

		-- 领取奖励 免费领取数量显示
		text = "×" .. item_num1
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_item_num_3"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)
		text = "×" .. item_num2
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_item_num_4"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)

		-- 领取奖励 两倍领取数量显示
		text = "×" .. (item_num1 * 2)
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_item_num_5"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)
		text = "×" .. (item_num2 * 2)
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_item_num_6"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)
	else
		local one_num = cfg[self.data.stars_num][1].count -- 经验数量

		-- 接受奖励数量显示
		text = "×" .. one_num
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_one_1"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)

		text = "×" .. one_num
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_one_2"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)

		text = "×" .. (one_num * 2)
		rich = RichTextUtil.ParseRichText(self.node_t_list["rich_one_3"].node, text, 22, item_color)
		XUI.RichTextSetCenter(rich)
	end
end

-- 刷新"每日任务"视图
function DailyTasksView:FlushDailyTasksView()

	if self.data.state == 2 then
		-- "领取奖励"视图
		self.node_t_list["layout_get_rewards"].node:setVisible(true) -- 显示"领取奖励"视图布局
		self.node_t_list["layout_receive_tasks"].node:setVisible(false) -- 隐藏"任务"主视图布局
	else
		-- "任务"主视图
		self.node_t_list["layout_get_rewards"].node:setVisible(false) -- 隐藏"领取奖励"视图布局
		self.node_t_list["layout_receive_tasks"].node:setVisible(true) -- 显示"任务"主视图布局

		self.node_t_list["layout_receive"].node:setVisible(self.data.state == 0) -- "接受任务"按钮
		self.node_t_list["layout_continue_task"].node:setVisible(self.data.times > 0) -- "继续任务"布局
		self.node_t_list["btn_flush_stars"].node:setVisible(self.data.state == 0) -- "刷星"按钮(接受任务后隐藏)
		self.node_t_list["lbl_consume"].node:setVisible(self.data.state == 0)
		self.node_t_list["img_stars_max"].node:setVisible(self.data.stars_num == 10) -- "满星"图片显示
		self.node_t_list["lbl_task_num"].node:setString(self.data.times) -- "剩余任务次数"
		self.start_part:SetStarActNum(self.data.stars_num) -- 刷新"星星"视图
		self.node_t_list["layout_complete"].node:setVisible(self.data.times == 0) -- "任务已完成"显示

		-- "任务目标"
		RichTextUtil.ParseRichText(self.node_t_list["rich_task_goal"].node, self.data.goal, 20, COLOR3B.GOLD)
		self.node_t_list["rich_task_goal"].node:setAnchorPoint(cc.p(0, 1))
		XUI.RichTextSetCenter(self.node_t_list["rich_task_goal"].node)
	end

	self.text_buy_time:setEnabled(self.data.but_time < XiangYaoChuMoCfg.maxBuyTms)
	self.text_buy_time:setColor(self.data.but_time < XiangYaoChuMoCfg.maxBuyTms and COLOR3B.GREEN or COLOR3B.GRAY)

	-- "任务已完成"视图显示
	if self.data.times == 0 then
		self.node_t_list["layout_receive"].node:setVisible(false) -- "接受任务"按钮
		self.node_t_list["btn_continue_task"].node:setVisible(false) -- "接受任务"按钮
		self.node_t_list["btn_flush_stars"].node:setVisible(false) -- "刷星"按钮
		self.node_t_list["layout_complete"].node:setVisible(true) -- "任务已完成"显示
	end
end

-- 获取元宝途径
function DailyTasksView:OpenGetBingGoldWindow()
	local bind_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)
	local need_bind_gold = XiangYaoChuMoCfg.doubleConsumeBindYb[1].count
	if bind_gold < need_bind_gold then -- 绑元不足时打开
		local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[3585]
		local data = string.format("{reward;0;%d;1}", 3585) .. (ways and ways or "")
		TipCtrl.Instance:OpenBuyTip(data)
		return
	end
end

----------end----------
-- "背包物品"改变回调
function DailyTasksView:OnBagItemChange()
	self:Flush()
end

-- "官职等级"改变回调
function DailyTasksView:OnOfficeLevelChange()
	self:Flush()
end

-- "进阶官职"按钮点击回调
function DailyTasksView:OnTextBtn()
	-- ViewManager.Instance:OpenViewByDef(ViewDef.Office)
	-- self:Close()
end

function DailyTasksView:OnTextBuyTime()
	self.but_time = self.but_time or Alert.New()
	self.but_time:SetLableString(string.format(Language.DailyTasks.BuyTimeTxt, XiangYaoChuMoCfg.buyTmsCost[1].count))
	self.but_time:SetOkFunc(function()
		DailyTasksCtrl.Instance:SendDailyTasksReq(8)
	end)
	self.but_time:SetShowCheckBox(false)
	self.but_time:Open()
end

-- "接受任务"按钮点击回调
function DailyTasksView:OnReceiveTaskBtn()
	DailyTasksData.Instance:SetFlyEffSwitch(true)
	DailyTasksCtrl.Instance:SendDailyTasksReq(2)
	self:Close()
end

-- "一键完成"按钮点击回调
function DailyTasksView:OnDirectCompleteBtn()
	local bind_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)
	local cfg = XiangYaoChuMoCfg
	if cfg.oneKeyBindYb[1].count <= bind_gold then
		DailyTasksData.Instance:SetFlyEffSwitch(false)
		DailyTasksCtrl.Instance:SendDailyTasksReq(3)
	else
		if nil == cfg then return end
		-- local consume_yuanbao = math.ceil((cfg.oneKeyBindYb[1].count - bind_gold) / 2)
		self.one_click_to_complete_alert = self.one_click_to_complete_alert or Alert.New()
		self.one_click_to_complete_alert:SetLableString(string.format(cfg.yuanBaoConsumeTips, cfg.oneKeyBindYb[1].count))
		self.one_click_to_complete_alert:SetOkFunc(function()
			DailyTasksData.Instance:SetFlyEffSwitch(false)
			DailyTasksCtrl.Instance:SendDailyTasksReq(3)
		end)
		self.one_click_to_complete_alert:SetShowCheckBox(false)
		self.one_click_to_complete_alert:Open()
	end
end

-- "继续除魔"按钮点击回调
function DailyTasksView:OnContinueTaskBtn()
	DailyTasksCtrl.Instance:SendDailyTasksReq(4)
	self:Close()
end

-- "刷新星级"按钮点击回调
function DailyTasksView:OnFlushStarsBtn()
	DailyTasksCtrl.Instance:SendDailyTasksReq(5)
end

-- "领取奖励"按钮点击回调
function DailyTasksView:OnReceiveBtn(index)
	local bind_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)
	if index ~= 2 or bind_gold >= XiangYaoChuMoCfg.doubleConsumeBindYb[1].count then
		DailyTasksCtrl.Instance:SendDailyTasksReq(6, index)
	else
		local cfg = XiangYaoChuMoCfg
		if nil == cfg then return end
		-- local consume_yuanbao = math.ceil((cfg.doubleConsumeBindYb[1].count - bind_gold) / 2)
		self.double_receiving_alert = self.double_receiving_alert or Alert.New()
		self.double_receiving_alert:SetLableString(string.format(cfg.yuanBaoConsumeTips, cfg.doubleConsumeBindYb[1].count))
		self.double_receiving_alert:SetOkFunc(function()
			DailyTasksCtrl.Instance:SendDailyTasksReq(6, index)
		end)
		self.double_receiving_alert:SetShowCheckBox(false)
		self.double_receiving_alert:Open()
	end 
end

-- "日常任务"改变回调
function DailyTasksView:OnTasksDataChange()
	self:FlushDailyTasksView()
	self:FlushItemNumView()
end
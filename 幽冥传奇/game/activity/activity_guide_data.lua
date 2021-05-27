-- 活动导航
ActivityData = ActivityData or BaseClass()

ActivityData.RANKING_DATA_CHANGE = "ranking_data_change"
ActivityData.MY_SCORE_CHANGE = "my_score_change"
ActivityData.BOSS_INSPIRE_TIMES_CHANGE = "boss_inspire_times_change"



ActivityData.GUIDE_SHOW_TYPE = {
	-- [DAILY_ACTIVITY_TYPE.BI_GUAN] = {guide_name = MainuiTask.GUIDE_NAME.ACT_BI_GUAN, enter = MainuiTask.SHOW_TYPE.LEFT, out = MainuiTask.SHOW_TYPE.LEFT, del_pro_bar = 1},
	-- [DAILY_ACTIVITY_TYPE.JU_MO] = {guide_name = MainuiTask.GUIDE_NAME.ACT_JU_MO, enter = MainuiTask.SHOW_TYPE.LEFT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [DAILY_ACTIVITY_TYPE.YA_SONG] = {guide_name = MainuiTask.GUIDE_NAME.ACT_YA_SONG, enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [DAILY_ACTIVITY_TYPE.MO_BAI] = {guide_name = MainuiTask.GUIDE_NAME.ACT_MO_BAI, enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT, del_pro_bar = 1},
	-- [DAILY_ACTIVITY_TYPE.WULIN_ZHENG_BA] = {guide_name = MainuiTask.GUIDE_NAME.ACT_WULIN_ZHENG_BA, enter = MainuiTask.SHOW_TYPE.LEFT, out = MainuiTask.SHOW_TYPE.LEFT, del_pro_bar = 1},
	-- [DAILY_ACTIVITY_TYPE.YUAN_BAO] = {guide_name = MainuiTask.GUIDE_NAME.ACT_YUAN_BAO, enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [DAILY_ACTIVITY_TYPE.ZHEN_YING] = {guide_name = MainuiTask.GUIDE_NAME.ACT_ZHEN_YING, enter = MainuiTask.SHOW_TYPE.LEFT, out = MainuiTask.SHOW_TYPE.LEFT, del_pro_bar = 1},
	-- [DAILY_ACTIVITY_TYPE.WANG_CHENG] = {guide_name = MainuiTask.GUIDE_NAME.ACT_WANG_CHENG, enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [DAILY_ACTIVITY_TYPE.HANG_HUI] = {guide_name = MainuiTask.GUIDE_NAME.ACT_HANG_HUI, enter = MainuiTask.SHOW_TYPE.LEFT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [DAILY_ACTIVITY_TYPE.GONG_CHENG] = {guide_name = MainuiTask.GUIDE_NAME.ACT_GONG_CHENG, enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING] = {guide_name = MainuiTask.GUIDE_NAME.ACT_DUOBAO_QIBING, enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT, del_pro_bar = 1},
	-- [DAILY_ACTIVITY_TYPE.FU_GUI_SHOU] = {guide_name = MainuiTask.GUIDE_NAME.ACT_FU_GUI_SHOU, enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
}

function ActivityData:InitGuideData(act_id)
	if act_id then
		self.act_info = self.act_info or {}
		self.act_info[act_id] = nil
	else
		self.act_info = {}
	end
end

function ActivityData:IsOnActivity(act_id)
	return self.act_info[act_id] ~= nil
end

-- 设置活动数据
function ActivityData:SetActData(protocol)
	local data = protocol.act_data_t
	local act_id = data.act_id
	local first_enter = self.act_info[act_id] == nil
	self.act_info[act_id] = self.act_info[act_id] or {}
	self.act_id = act_id -- 当前活动ID

	if act_id == DAILY_ACTIVITY_TYPE.BI_GUAN then -- 闭关修炼
		self:OnBiGuan(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING then -- 夺宝奇兵
		self:OnDuoBaoQiBing(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.HANG_HUI then -- 行会闯关
		self:OnHangHui(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.GONG_CHENG then -- 攻城战
		self:OnGongCheng(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.MO_BAI then -- 膜拜城主
		self:OnMoBai(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.WULIN_ZHENG_BA then -- 武林争霸
		self:OnWulinZhengBa(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.YUAN_BAO then -- 元宝嘉年华
		self:OnYuanBao(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.YA_SONG then -- 多倍押送
		self:OnYaSong(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS then -- 行会BOSS
		self:OnHangHuiBoss(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.ZHEN_YING then -- 阵营战
		self:OnZhenYing(data)
	elseif act_id == DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS then -- 世界BOSS
		self:OnShiJieBoss(data)
	end
end

-- 获取当前活动ID
function ActivityData:GetActivityID()
	return self.act_id
end

function ActivityData.GetCommonTips(tip_content, tip_title)
	return {
		path = ResPath.GetCommon("part_100"),
		x = MainuiTask.task_size.width - 30,
		y = (MainuiTask.task_size.height - 60) - 30,
		event = function ()
			DescTip.Instance:SetContent(tip_content, tip_title or Language.Activity.ActTipsTitle)
		end,
	}
end

-- 设置活动面板数据
function ActivityData:SetTaskData(act_id, guide_data)
	local left_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)

	-- 创建布局
	self.layout_practice = XUI.CreateLayout(80, 520, 150, 0)
	left_top:TextureLayout():addChild(self.layout_practice, -20)

	GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)
	if nil == self.practice_top_tip[act_id] then
		self.practice_top_tip[act_id] = self:CreateTotalRevenueView(self.layout_practice, act_id)
	else
		self.practice_top_tip[act_id]:SetVisible(true)
	end
	self.practice_top_tip[act_id]:Flush(guide_data)
end

-- 创建活动面板视图
function ActivityData:CreateTotalRevenueView(parent, act_id)
	local view = {}
	local LeftTime = {}
	local ph_item = ConfigManager.Instance:GetUiConfig("daily_activity_ui_cfg")[act_id]
	--顶部活动面板
	local node_tree = {}
	local node = XUI.CreateLayout(520, 100, 150, 0)
	XUI.Parse(ph_item, node, nil, node_tree)
	parent:addChild(node)

	-----面板刷新-----	
	function view:Flush(data)
		if nil ~= data.title then
			RichTextUtil.ParseRichText(node_tree.rich_total_revenue.node, data.total_revenue, 22)
			if act_id == DAILY_ACTIVITY_TYPE.HANG_HUI then
				node_tree["img_title"].node:loadTexture(ResPath.GetMainui(data.title))
			end
		elseif act_id == DAILY_ACTIVITY_TYPE.YUAN_BAO then
			node_tree.lbl_wave_num.node:setString(data.wave_num)
			LeftTime:CheckLeftTimeTimer(data.left_time, Status.NowTime)
		elseif act_id == DAILY_ACTIVITY_TYPE.YA_SONG then
			RichTextUtil.ParseRichText(node_tree.rich_total_revenue.node, data.total_revenue, 22)
			XUI.RichTextSetCenter(node_tree.rich_total_revenue.node)
			ActivityData.Instance:EscortAward(node_tree["layout_award_view"].node, data.state, data.award_id)
			ActivityData.Instance:SetNodeList(act_id, node_tree["rich_total_revenue"].node)
			node_tree["lbl_state"].node:setString(Language.Escort.State[data.state])
			node_tree["lbl_state"].node:setColor(data.state == 0 and COLOR3B.RED or COLOR3B.GREEN)
		elseif act_id == DAILY_ACTIVITY_TYPE.GONG_CHENG then
			node_tree.lbl_guild_name.node:setString(data.guild_name)
			LeftTime:CheckLeftTimeTimer(data.left_time, Status.NowTime)
		end

		self.now_time = Status.NowTime
		self.time = data.act_left_time
		self:CheckTimer()
	end

	function view:CheckTimer() --检查计时器任务
		local left_time = math.max((self.time + self.now_time - Status.NowTime), 0)
		if left_time > 0 then
			node_tree.lbl_time.node:setString(TimeUtil.FormatSecond(left_time)) -- 刷新剩余时间
			if nil == self.timer then
				self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SecTime, self), 1)
			end
		else
			GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
			self.timer = nil
			if LeftTime.timer then
				GlobalTimerQuest:CancelQuest(LeftTime.timer) -- 取消计时器任务
				LeftTime.timer = nil
			end
			node:removeFromParent() -- 释放主界面视图节点
			ActivityData.Instance.practice_top_tip[act_id] = nil
		end
	end
	function view:SecTime() --倒计时每秒回调
		local left_time = math.max((self.time + self.now_time - Status.NowTime), 0)
		node_tree.lbl_time.node:setString(TimeUtil.FormatSecond(left_time)) -- 刷新剩余时间
		if left_time == 0 then
			self:CheckTimer()
		end
	end
	function view:SetVisible(vis) -- 设置面板显示状态
		if nil ~= node then
			node:setVisible(vis)
		end
	end

	function LeftTime:CheckLeftTimeTimer(time, now_time) --检查计时器任务
		self.time = time
		self.now_time = now_time
		local left_time = math.max((self.time + self.now_time - Status.NowTime), 0)

		node_tree.lbl_time2.node:setString(TimeUtil.FormatSecond(left_time)) -- 刷新剩余时间
		if left_time > 0 then
			if nil == self.timer then
				self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SecLeftTimeTime, self), 1)
			end
		else
			GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
			self.timer = nil
			self.left_time = nil
			if act_id == DAILY_ACTIVITY_TYPE.YUAN_BAO then
				node_tree.lbl_time2.node:setString("当前为最后一波")
			end
		end
	end
	function LeftTime:SecLeftTimeTime() --倒计时每秒回调
		local left_time = math.max((self.time + self.now_time - Status.NowTime), 0)
		node_tree.lbl_time2.node:setString(TimeUtil.FormatSecond(left_time)) -- 刷新剩余时间
		if left_time == 0 then
			self:CheckLeftTimeTimer(self.time, self.now_time)
		end
	end

	return view
end

-- 退出活动
function ActivityData:ExitActivity()
	if nil ~= self.practice_top_tip[self.act_id] then
		self.practice_top_tip[self.act_id]:SetVisible(false)
		self.practice_top_tip[self.act_id].now_time = Status.NowTime
		self.practice_top_tip[self.act_id].time = 5 -- 退出活动后,面板节点保留时间
		self.node_list = nil
		if self.award_cell_list then 
			for k, v in pairs(self.award_cell_list) do
				v:GetView():removeFromParent()
				v:DeleteMe()
			end
			self.award_cell_list = nil
		end
		self.car_info = nil
		self.ranking_data = nil
	end
	self.act_id = nil
	self.my_act_rank = 0
	GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, false, false)
end

-- 闭关修炼
function ActivityData:OnBiGuan(data)
	local act_cfg = StdActivityCfg[data.act_id]
	if act_cfg == nil then return end
	local guide_data = {
	title = "activity_9",
	act_left_time = data.act_left_time,
	total_revenue = data.total_revenue,
	}
	self:SetTaskData(data.act_id, guide_data)
end

-- 膜拜
function ActivityData:OnMoBai(data)
	local act_cfg = StdActivityCfg[data.act_id]
	if act_cfg == nil then return end
	local guide_data = {
	title = "activity_9",
	act_left_time = data.act_left_time,
	total_revenue = data.total_revenue,
	}

	self:SetTaskData(data.act_id, guide_data)
end

-- 武林争霸
function ActivityData:OnWulinZhengBa(data)
	local award_yb = StdActivityCfg[DAILY_ACTIVITY_TYPE.WULIN_ZHENG_BA].awardsYb
	local title_id = StdActivityCfg[DAILY_ACTIVITY_TYPE.WULIN_ZHENG_BA].awardsMasterTitle[1].id
	local title_name = ItemData.Instance:GetItemConfig(title_id).name
	local guide_data = {
	title = "activity_10",
	act_left_time = data[1],
	total_revenue = string.format("奖励钻石：{wordcolor;1eff00;%s}\n%s（称号）:{wordcolor;1eff00;1}", award_yb, title_name),
	}

	self:SetTaskData(data.act_id, guide_data)
end

-- 元宝嘉年华
function ActivityData:OnYuanBao(data)
	local guide_data = {
	left_time = data.left_time,
	act_left_time = data.act_left_time,
	wave_num = data.wave_num .. "波",
	}

	self:SetTaskData(data.act_id, guide_data)
end

-- 行会闯关
function ActivityData:OnHangHui(data)
	local act_cfg = StdActivityCfg[data.act_id]
	if act_cfg == nil then
		return
	end

	local guide_data = {
	title = "activity_guild_" .. data[1],
	act_left_time = data[2],
	total_revenue = act_cfg.awards[data[1]].desc,
	}
	self:SetTaskData(data.act_id, guide_data)
end

-- 功城战(王城争霸)
function ActivityData:OnGongCheng(data)
	local guide_data = {
	left_time = data.ensure_left_time,
	act_left_time = data.act_left_time,
	}
	guide_data.guild_name = data.guild_name == "" and "无" or data.guild_name

	self:SetTaskData(data.act_id, guide_data)
end

-- 夺宝奇兵
function ActivityData:OnDuoBaoQiBing(data)
	local guide_data = {
	title = "activity_9",
	act_left_time = data.act_left_time,
	total_revenue = data.total_revenue,
	}
	self:SetTaskData(data.act_id, guide_data)
end

-- 押送
function ActivityData:OnYaSong(data)
	ActivityCtrl.Instance:StartAutoEscort()
	self.car_info = {} -- 用干刷新时
	self.car_info.text = Language.Escort.CarTimes[data.is_double] .. data.car_name .. "({color;%s;%d}/%d)"
	self.car_info.max_hp = data.max_hp
	self.car_info.car_name = data.car_name
	self.car_info.state = data.is_buy_insure
	local guide_data = {
	act_left_time = data.esc_left_time,
	total_revenue = string.format(self.car_info.text, COLORSTR.WHITE, data.max_hp, data.max_hp),
	state = data.is_buy_insure,
	award_id = data.award_id
	}
	self:SetTaskData(data.act_id, guide_data)
end

-- 行会BOSS
function ActivityData:OnHangHuiBoss(data)
	self.ranking_data = data
	self:SetActLeftTime(data)
	self:SetActBossOrder(data)
	self:SetBossInspireTimes(data)
	if (not ViewManager.Instance:IsOpen(ViewDef.ActRanking)) then
		GlobalEventSystem:FireNextFrame(MainUIEventType.SET_TIPS_UI_VIS, false)
		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActRanking)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActBossInspire)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActGuildBoss)
	end
	self:DispatchEvent(ActivityData.RANKING_DATA_CHANGE)
end

-- 阵营战
function ActivityData:OnZhenYing(data)
	self.ranking_data = data
	self:SetActLeftTime(data)
	if (not ViewManager.Instance:IsOpen(ViewDef.ActRanking)) then
		GlobalEventSystem:FireNextFrame(MainUIEventType.SET_TIPS_UI_VIS, false)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActRanking)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActZhenYing)
	end
	self:DispatchEvent(ActivityData.RANKING_DATA_CHANGE)
end

-- 世界BOSS
function ActivityData:OnShiJieBoss(data)
	self.ranking_data = data
	self:SetActLeftTime(data)
	self:SetBossInspireTimes(data)
	if (not ViewManager.Instance:IsOpen(ViewDef.ActRanking)) then
		GlobalEventSystem:FireNextFrame(MainUIEventType.SET_TIPS_UI_VIS, false)
		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActRanking)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActBossInspire)
		ViewManager.Instance:OpenViewByDef(ViewDef.ActWorldBoss)
	end

	self:DispatchEvent(ActivityData.RANKING_DATA_CHANGE)
end

-- 更新BOSS排行榜
function ActivityData:UpdateBossRanking(data)
	self.ranking_data = self.ranking_data or {}
	self.ranking_data.ranking_count = data.ranking_count
	self.ranking_data.rakning_list = data.rakning_list
	
	self:DispatchEvent(ActivityData.RANKING_DATA_CHANGE)
end


function ActivityData:GetRankingData()
	return self.ranking_data or {}
end

-- 设置世界boss排行榜自己的积分
function ActivityData:SetWorldBossMyScore(protocol)
	self.ranking_data = self.ranking_data or {}
	self.ranking_data.my_score = protocol.my_score
	self:DispatchEvent(ActivityData.MY_SCORE_CHANGE)
end

function ActivityData:GetWorldBossMyScore()
	local data = self.ranking_data or {}
	local my_score = data.my_score or 0
	return my_score
end

-- 设置boss鼓舞次数
function ActivityData:SetBossInspireTimes(protocol)
	self.inspir_list = self.inspir_list or {}
	self.inspir_list = {
		[protocol.act_id] = protocol.inspire_times
	}
	self:DispatchEvent(ActivityData.BOSS_INSPIRE_TIMES_CHANGE)
end

function ActivityData:GetBossInspireTimes(act_id)
	self.inspir_list = self.inspir_list or {}
	return self.inspir_list[act_id] or 0
end

-- 设置活动剩余时间
function ActivityData:SetActLeftTime(data)
	self.left_time = self.left_time or {}
	self.left_time.act_left_time = data.act_left_time
	self.left_time.set_act_left_time = data.set_act_left_time
end

-- 获取活动剩余时间
function ActivityData:GetActLeftTime()
	return self.left_time or {}
end

-- 设置活动BOSS顺序
function ActivityData:SetActBossOrder(data)
	self.boss_order = data.boss_order or 1
end

-- 获取活动BOSS顺序
function ActivityData:GetActBossOrder()
	return self.boss_order or 1
end

function ActivityData:GetBossInspireTimes(act_id)
	self.inspir_list = self.inspir_list or {}
	return self.inspir_list[act_id] or 0
end

function ActivityData:EscortAward(layout, state, award_id)
	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
			v = nil
		end
		self.award_cell_list = {}
	end

	local cfg = StdActivityCfg[DAILY_ACTIVITY_TYPE.YA_SONG].tBiaoche[award_id]
	local item_list = {}

	if state == 1 then
		for k,v in pairs(cfg.otherAwards) do
			item_list[#item_list + 1] = ItemData.InitItemDataByCfg(v)
		end
	end
	for k,v in pairs(cfg.Awards) do
		item_list[#item_list + 1] = ItemData.InitItemDataByCfg(v)
	end
	self.award_cell_list = {}
	local x, y = 0, 0
	local x_interval = 63
	local size = layout:getContentSize()
	local correct = (#item_list * x_interval - size.width) / 2 -- 居中
	for k, v in pairs(item_list) do
		local award_cell = BaseCell.New()
		award_cell:SetAnchorPoint(0, 0)
		layout:addChild(award_cell:GetView(), 99)
		award_cell:SetPosition(x - correct, y)
		award_cell:SetData(v)
		award_cell:GetView():setScale(0.75)
		x = x + x_interval
		table.insert(self.award_cell_list, award_cell)
	end
end

function ActivityData:SetNodeList(act_id, node)
	self.node_list = self.node_list or {}
	self.node_list[act_id] = node
end

function ActivityData:GetNodeList()
	return self.node_list
end

-- 是否在活动场景
function ActivityData.IsInActivityScene()
	local state = false
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = main_role_vo.scene_id
	local scene_list = ActivityData.Instance.GetActivitySceneList()

	return scene_list[scene_id] ~= nil
end

-- 获取需要显示退出按钮的活动场景列表
function ActivityData.GetActivitySceneList()
	local scene_list = {}

	-- 注意:每个活动中的scene字段不一样
	scene_list[StdActivityCfg[DAILY_ACTIVITY_TYPE.BI_GUAN].sceneid] = 1
	scene_list[StdActivityCfg[DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING].sceneId] = 1
	scene_list[StdActivityCfg[DAILY_ACTIVITY_TYPE.WULIN_ZHENG_BA].lowSceenId] = 1
	scene_list[StdActivityCfg[DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS].sceneId] = 1
	scene_list[StdActivityCfg[DAILY_ACTIVITY_TYPE.ZHEN_YING].sceneId] = 1
	scene_list[StdActivityCfg[DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS].sceneId] = 1
	scene_list[218] = 1
	scene_list[219] = 1
	scene_list[223] = 1
	
	return scene_list
end

-- 是否在活动场景
function ActivityData.IsInZhenyingActivityScene()
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = main_role_vo.scene_id
    return StdActivityCfg[DAILY_ACTIVITY_TYPE.ZHEN_YING].sceneId == scene_id
    	or StdActivityCfg[DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS].sceneId == scene_id
    	or StdActivityCfg[DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS].sceneId == scene_id
end

-- 是否在押镖场景
function ActivityData.IsInEscortActivityScene()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = main_role_vo.scene_id
	return StdActivityCfg[DAILY_ACTIVITY_TYPE.YA_SONG].DartsSceneId[scene_id] ~= nil
end
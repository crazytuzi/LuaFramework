--------------------------------------------------------
-- 发现BOSS视图  配置 RandomBossCfg
--------------------------------------------------------

FindBossView = FindBossView or BaseClass(BaseView)

function FindBossView:__init()
	self.texture_path_list[1] = 'res/xui/find_boss.png'
	self:SetModal(true)
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"find_boss_ui_cfg", 1, {0}, false},
		{"common_ui_cfg", 2, {0}},
	}

	self.item_daley_timer = nil
	self.data = nil
	self.boss_eff = nil
end

function FindBossView:__delete()
end

--释放回调
function FindBossView:ReleaseCallBack()
	if nil ~= self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar = nil
	end
	if self.enter_fuben_countdown then
		GlobalTimerQuest:CancelQuest(self.enter_fuben_countdown)
		self.enter_fuben_countdown = nil
	end
	self:CancelTimer()
	self.boss_eff = nil
end

--加载回调
function FindBossView:LoadCallBack(index, loaded_times)

	self.data = FindBossData.Instance:GetData()

	self:CreateProgressView()
	self:CreateBossEffect()
	
	self.node_t_list['img_pointer'].node:setAnchorPoint(cc.p(0.5, -0.56))

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_lucky_draw"].node, BindTool.Bind(self.OnBtnLuckyDraw, self))
	XUI.AddClickEventListener(self.node_t_list["layout_enter"].node, BindTool.Bind(self.OnEnter, self), true) -- "进入副本"按钮回调绑定

	-- 数据监听
	EventProxy.New(FindBossData.Instance, self):AddEventListener(FindBossData.FINDBOSS_DATA_CHANGE, BindTool.Bind(self.OnFindBossDataChange, self))
end

function FindBossView:OpenCallBack()
	FindBossCtrl.Instance:SendDiamondsCreateReq(1)
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FindBossView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	GlobalTimerQuest:CancelQuest(self.time)
end

--显示指数回调
function FindBossView:ShowIndexCallBack(index)
	self:FlushBossView()
	self:FlushTimes()
	self:CheckTimer()
	self:CheckEnterCountdown()

	self.node_t_list["layout_count_down"].node:setVisible(self.data.boss_index == 0)
	self.node_t_list["layout_enter"].node:setVisible(self.data.boss_index ~= 0)

	local left_time = TimeUtil.FormatSecond(FindBossData.Instance:GetExtractTime(), 2)
	local text = self.data.times ~= 0 and left_time or "今日挑战次数已用完了"
	self.node_t_list["lbl_time_1"].node:setString(text)

	local Angle = self.data.boss_index * 360 / 6 - 30
	Angle = Angle > 0 and Angle or 0
	self.node_t_list['img_pointer'].node:setRotation(Angle)

	self:FlushBossEffect()
	self.btn_eff:setVisible(self.data.times > 0 and self.data.boss_index == 0 and self.data.extract_time <= 0)

	self.node_t_list.layout_find_boss.node:setVisible(true)
end
----------视图函数----------

-- 刷新BOSS视图
function FindBossView:FlushBossView()
	local index
	local boss_list_index
	if self.data.last_time_zs > 0 then
		boss_list_index = self.data.last_time_zs
		index = self.data.last_time_zs
	else
		boss_list_index = self.data.last_time_lv > 79 and 80 or 70
		index = self.data.last_time_lv > 79 and "02" or "01"
	end
	for i = 1, 6 do
		self.node_t_list["img_boss_type_" .. i].node:loadTexture(ResPath.GetFindBoss("boss_type_" .. index))
		boss_name = RandomBossCfg.bossInfo[boss_list_index][i].boss_name
		self.node_t_list["lbl_boss_name_" .. i].node:setString(boss_name .. Language.FindBoss.BossType[i])
	end
end

-- 创建'转盘动作'
function FindBossView:FlushAction()
	if self.data.type ~= 2 then return end
	local index = self.data.boss_index

	self.node_t_list['img_pointer'].node:stopAllActions()
	self.node_t_list['img_pointer'].node:setAnchorPoint(cc.p(0.5, -0.56))
	local act_info = {{0.2, 0.2}} -- 启动动作
	local act_info_item ={{0.3, 0.4}, {0.2, 0.2}, {0.25, 0.2}} -- 停止前的缓冲动作

	local current_angle = self.node_t_list['img_pointer'].node:getRotation() -- 获取当前角度
	local Angle = (index * 360 / 6 - 30 - current_angle%360 + 360)%360 -- 算出需旋转的角度
	local ratio = (Angle  + 288) / 288 -- 算出缓冲动作需要改变的"比例"
	-- 根据"比例"改变缓冲动作每一步的时间和"角度比例"
	for k,v in pairs(act_info_item) do
		table.insert(act_info, {(v[1] * ratio), (v[2] * ratio)})
	end
	-- 创建动作
	local act_t = {}
	for i, v in pairs(act_info) do
		act_t[i] = cc.RotateBy:create(v[1], v[2] * 360)
	end

	local seq_act = cc.Sequence:create(unpack(act_t)) -- 合并动作
	local seq_act = cc.Sequence:create(seq_act, cc.CallFunc:create(BindTool.Bind(self.OnTableActionChange, self))) -- 绑定动作回调
	self.node_t_list['img_pointer'].node:runAction(seq_act) -- 运行操作
end

function FindBossView:CreateProgressView()
	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(self.node_t_list["prog9_progress"].node)
	self.progressbar:SetTailEffect(991, 1)
	self.progressbar:SetEffectOffsetX(-22)
	self.progressbar:SetEffectOffsetY(-2)
	-- self.progressbar:SetCompleteCallback(BindTool.Bind1(self.LoadingBarComplete, self))
end

function FindBossView:FlushProgressBar()
	-- if self.data.times == 0 then reutrn end
	local extract_time = FindBossData.Instance:GetExtractTime()
	local per = 100 - (RandomBossCfg.timesCd - extract_time) / RandomBossCfg.timesCd * 100
	self.progressbar.tail_effect:setVisible(per ~= 0 and self.data.times ~= 0)
	self.progressbar:SetPercent(per, false, false)
end

function FindBossView:FlushTimes()
	local day_times = RandomBossCfg.dayTimes
	local color = self.data.times > 0 and COLORSTR.GREEN or COLORSTR.RED
	local text = "今日挑战次数({wordcolor;" .. color  ..";" .. self.data.times .. "}/" .. day_times .. ")"
	RichTextUtil.ParseRichText(self.node_t_list["rich_times"].node, text, 18, COLOR3B.GREEN)
	XUI.RichTextSetCenter(self.node_t_list["rich_times"].node)
end

-- 检查或创建记时器
function FindBossView:CheckTimer()
	local left_time = FindBossData.Instance:GetExtractTime()
	self:FlushProgressBar()
	if left_time > 0  and self.data.times > 0 then
		if nil == self.time then
			self.time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimerCallBack, self, i), 1)
		end
	else
		self:CancelTimer()
	end
end

-- 取消计时器
function FindBossView:CancelTimer()
	if self.time then
		GlobalTimerQuest:CancelQuest(self.time)
		self.time = nil
	end
end

function FindBossView:TimerCallBack()
	self:FlushProgressBar()
	local left_time = FindBossData.Instance:GetExtractTime()
	if self:IsOpen() then
		local text = self.data.times ~= 0 and TimeUtil.FormatSecond(left_time, 2) or "今日挑战次数已用完了"
		self.node_t_list["lbl_time_1"].node:setString(text)
	end
	if left_time == 0 then
		self:CheckTimer()
	end
end

function FindBossView:CheckEnterCountdown()
	if self.data.enter_time > 0 then -- 进入副本倒计时时间不为0
		self.enter_fuben_time = self.data.enter_time
		self:FlushEnterCountdown()
		if self.enter_fuben_countdown then
			GlobalTimerQuest:CancelQuest(self.enter_fuben_countdown)
		end
		self.enter_fuben_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetEnterCountdown, self), 1)
		self.node_t_list["rich_time_2"].node:setVisible(true)
	else
		self.node_t_list["rich_time_2"].node:setVisible(false)
	end
end

-- 设置进入副本倒计时
function FindBossView:SetEnterCountdown()
	self.enter_fuben_time = FindBossData.Instance:GetEnterTime()
	if self.enter_fuben_time and self.enter_fuben_time >= 0 then
		self:FlushEnterCountdown()
	end
	if self.enter_fuben_time == 0 and self.enter_fuben_countdown then
		GlobalTimerQuest:CancelQuest(self.enter_fuben_countdown)
		if self:IsOpen() then
			self.node_t_list['img_pointer'].node:stopAllActions()
			self.node_t_list["rich_time_2"].node:setVisible(false)
			self.node_t_list['img_pointer'].node:setRotation(0)
		end
	end
end

function FindBossView:FlushEnterCountdown()
	if self:IsOpen() then
		local time = TimeUtil.FormatSecond(self.enter_fuben_time, 2)
		local text = "挑战BOSS有效时间：{color;00ff00;" .. time .. "}"
		RichTextUtil.ParseRichText(self.node_t_list["rich_time_2"].node, text, 18, COLOR3B.ORANGE)
		XUI.RichTextSetCenter(self.node_t_list["rich_time_2"].node)
	end
end

-- 播放特效
function FindBossView:CreateBossEffect()
	-- boss图标特效
	local path, name = ResPath.GetEffectUiAnimPath(358)
	self.boss_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.boss_eff:setVisible(false)
	self.node_t_list["layout_find_boss"].node:addChild(self.boss_eff, 99)

	-- 抽取按钮特效
	local path, name = ResPath.GetEffectUiAnimPath(357)
	self.btn_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.btn_eff:setVisible(false)
	local x, y = self.node_t_list.btn_lucky_draw.node:getPosition()
	self.btn_eff:setPosition(x + 3, y + 7)
	self.node_t_list["layout_find_boss"].node:addChild(self.btn_eff, 99)
end

function FindBossView:FlushBossEffect()
	if self.data.boss_index ~= 0 then
		local x, y = self.node_t_list["img_boss_" .. self.data.boss_index].node:getPosition()
		self.boss_eff:setPosition(x, y + 14)
		self.boss_eff:setVisible(true)
	else
		self.boss_eff:setVisible(false)
	end
end
----------end----------

-- "进入副本"按钮点击回调
function FindBossView:OnEnter()
	-- 背包格子少于20格时弹出提示
	if BagData.Instance:GetBagGridNum() - BagData.Instance:GetBagItemCount() < 20 then
		local start_alert = Alert.New()
		start_alert:SetLableString(string.format(Language.Fuben.NoEnoughGrid, 20))
		start_alert:SetOkFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
		end)
		-- self.start_alert:SetShowCheckBox(false)
		start_alert:SetOkString(Language.Fuben.GotoRecycle)
		start_alert:Open()
	else
		FindBossCtrl.Instance:SendDiamondsCreateReq(3)
	end
end

-- "开始抽奖"按钮点击回调
function FindBossView:OnBtnLuckyDraw()
	FindBossCtrl.Instance:SendDiamondsCreateReq(2)
end

-- 转盘动作回调
function FindBossView:OnTableActionChange()
	self.node_t_list["layout_count_down"].node:setVisible(false)
	self.node_t_list["layout_enter"].node:setVisible(true)
	self:FlushBossEffect()
	self:CheckEnterCountdown()
end

-- 发现BOSS数据改变回调
function FindBossView:OnFindBossDataChange()
	self:FlushAction()
	self:FlushTimes()
	self:CheckTimer()
	self:FlushBossView()
	self.btn_eff:setVisible(self.data.times > 0 and self.data.boss_index == 0 and self.data.extract_time <= 0)
	if self.data.boss_index == 0 then
		self:CheckEnterCountdown()
		self:FlushBossEffect()
		self.node_t_list["layout_count_down"].node:setVisible(true)
		self.node_t_list["layout_enter"].node:setVisible(false)
	end
	local left_time = FindBossData.Instance:GetExtractTime()
	local text = self.data.times ~= 0 and TimeUtil.FormatSecond(left_time, 2) or "今日挑战次数已用完了"
	self.node_t_list["lbl_time_1"].node:setString(text)
end

--------------------

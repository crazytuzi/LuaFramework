LkDrawView = LkDrawView or BaseClass(ActBaseView)

function LkDrawView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function LkDrawView:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if nil ~= self.consume_money then
		self.consume_money:DeleteMe()
		self.consume_money = nil
	end

	if self.auto_play_timer then
		GlobalTimerQuest:CancelQuest(self.auto_play_timer)
		self.auto_play_timer = nil
	end
end

function LkDrawView:InitView()
	self:CreateLuckyDrawGride()
	self:CreateDrawMoneyBar()
	XUI.AddClickEventListener(self.node_t_list["img_pointer"].node, BindTool.Bind(self.OnClickTurntableHandler, self), false)
	XUI.AddClickEventListener(self.node_t_list["layout_skip"].node, BindTool.Bind(self.OnSkipAction, self))
	XUI.AddClickEventListener(self.node_t_list["layout_aout_play"].node, BindTool.Bind(self.OnAoutPlay, self))
	XUI.AddClickEventListener(self.node_t_list["btn_stop_play"].node, BindTool.Bind(self.OnStopPlay, self))

	self.node_t_list["img_pointer"].node:setAnchorPoint(0.5, 0.36)
end

-- 视图关闭回调
function LkDrawView:CloseCallback() 
	self:InitPlayState()
	self:CancelAutoPlayTimer()

	if self.node_t_list['img_pointer'] then
		self.node_t_list['img_pointer'].node:stopAllActions()
		self.node_t_list['img_pointer'].node:setRotation(0)
	end
	BagData.Instance:SetDaley(false)
end

-- 选中当前视图回调
function LkDrawView:ShowIndexView()
	self:InitPlayState()
end

function LkDrawView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	local act_id = self.act_id
	local lk_draw_num = data.lk_draw_num
	local money = data.mine_num[self.act_id]
	self.consume_money:SetNumber(money)
	self.tree.lbl_draw_times.node:setString(lk_draw_num)
	self.can_play = lk_draw_num > 0

	for k,v in pairs(param_list) do
		if k == "flush_view" and v.act_id == act_id and v.result then
			if self.spik_play_actions then
				self:OnTableActionChange()
			else
				self.award_index = v.result
				self:FlushAction()
			end
		end
	end
end

-- 初始化抽奖状态
function LkDrawView:InitPlayState()
	if self.node_t_list["btn_stop_play"] then
		self.node_t_list["btn_stop_play"].node:setVisible(false)
	end

	if self.node_t_list["img_skip_hook"] then
		self.node_t_list["img_skip_hook"].node:setVisible(false)
	end

	if self.node_t_list["img_aout_play_hook"] then
		self.node_t_list["img_aout_play_hook"].node:setVisible(false)
	end

	self.spik_play_actions = false 	-- 跳过动画
	self.auto_play_actions = false	-- 自动抽奖
	self.need_auto_play = false		-- 自动请求 true-抽奖结束时,自动请求抽奖
	self.play_state = false 		-- 抽奖状态 true-抽奖中, false-未抽奖或抽奖结束
end

function  LkDrawView:CreateLuckyDrawGride()
	self.cell_list = {}

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id) or {}
	local cfg = act_cfg.config or {}
	local center_x, center_y = self.node_t_list["img_pointer"].node:getPosition() -- 以img_pointer的坐标为中心点
	local r = 140 -- 半径
	self.max_count = #(cfg.award or {})
	for i,v in ipairs(cfg.award or {}) do
		local angle = (i - 1) * 360 / self.max_count
		local x = center_x + r * math.sin(math.rad(angle))
		local y = center_y + r * math.cos(math.rad(angle))

		local cell = ActBaseCell.New()
		cell:SetPosition(x, y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetData(ItemData.InitItemDataByCfg(v))
		self.tree.node:addChild(cell:GetView(), 2)
		table.insert(self.cell_list, cell)
	end
end

function LkDrawView:CreateDrawMoneyBar()
	local ph = self.ph_list.ph_draw_money
	self.consume_money = NumberBar.New()
	self.consume_money:SetRootPath(ResPath.GetCommon("num_10_"))
	self.consume_money:SetPosition(ph.x, ph.y)
	self.consume_money:SetGravity(NumberBarGravity.Center)
	self.consume_money:SetSpace(-5)
	self.tree.node:addChild(self.consume_money:GetView(), 300, 300)
end

function LkDrawView:FlushAction()
	if self.award_index == 0 then return end
	local item_index = self.award_index
	self.node_t_list['img_pointer'].node:stopAllActions()

	local act_info = {{0.5, 0.5}, {0.3, 0.5}, {0.2, 0.5}, {1.5, 5}} -- 启动动作
	local act_info_item ={{0.18, 0.6}, {0.16, 0.4}, {0.2, 0.4}, {0.25, 0.4}, {0.15, 0.2}, {0.25, 0.25}, {0.4, 0.2}, {0.15, 0.05}} -- 停止前的缓冲动作

	local current_angle = self.node_t_list['img_pointer'].node:getRotation()
	local item_Angle = ((item_index - 1) * 360 / self.max_count - current_angle%360)%360
	local ratio = (item_Angle  + 900) / 900 -- 900 是缓冲动作的旋转角度
	for k,v in pairs(act_info_item) do
		table.insert(act_info, {(v[1] * ratio), (v[2] * ratio)})
	end

	local act_t = {}
	for i, v in pairs(act_info) do
		act_t[i] = cc.RotateBy:create(v[1], v[2] * 360)
	end

	local seq_act = cc.Sequence:create(unpack(act_t))
	local seq_act = cc.Sequence:create(seq_act, cc.CallFunc:create(BindTool.Bind(self.OnTableActionChange, self)))
	self.node_t_list['img_pointer'].node:runAction(seq_act)
end

function LkDrawView:OnTableActionChange()
	BagData.Instance:SetDaley(false)
	self.play_state = false

	if self.auto_play_actions and self.need_auto_play then
		self:OnClickTurntableHandler()
	else
		if self.node_t_list['img_pointer'] then
			self.node_t_list['img_pointer'].node:setTouchEnabled(true)
		end
	end
end

function LkDrawView:OnClickTurntableHandler()
	-- 初始化自动抽奖状态
	self.need_auto_play = false
	self.play_state = false

	if self.can_play then
		if not self.spik_play_actions then
			BagData.Instance:SetDaley(true)
		end

		if self.auto_play_actions then
			self.node_t_list["btn_stop_play"].node:setVisible(true)
			self:CreateAutoPlayTimer()
		end

		self.play_state = true
		self.node_t_list['img_pointer'].node:setTouchEnabled(false)
		local act_id = self.act_id or 0
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 1)
	else
		SystemHint.Instance:FloatingTopRightText(Language.ActivityBrilliant.Text42)
		self.node_t_list["btn_stop_play"].node:setVisible(false)
	end
end

function LkDrawView:CreateAutoPlayTimer()
	self:CancelAutoPlayTimer()

	local callback = function()
		if self.auto_play_actions then
			if self.play_state then
				self.need_auto_play = true
			else
				self:OnClickTurntableHandler()
			end
		end
	end

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id or 0) or {}
	local cfg = act_cfg.config or {}
	local delay_time = cfg.auto_play_delay_time or 1
	self.auto_play_timer = GlobalTimerQuest:AddDelayTimer(callback, delay_time)
end

-- 取消自动抽奖计时器
function LkDrawView:CancelAutoPlayTimer()
	if self.auto_play_timer then
		GlobalTimerQuest:CancelQuest(self.auto_play_timer)
		self.auto_play_timer = nil
	end
end

function LkDrawView:OnSkipAction()
	local vis = self.node_t_list["img_skip_hook"].node:isVisible()
	self.node_t_list["img_skip_hook"].node:setVisible(not vis)
	self.spik_play_actions = not vis
end

function LkDrawView:OnAoutPlay()
	local vis = self.node_t_list["img_aout_play_hook"].node:isVisible()
	self.node_t_list["img_aout_play_hook"].node:setVisible(not vis)
	self.auto_play_actions = not vis

	self.node_t_list["btn_stop_play"].node:setVisible(false)

	-- 关闭自动抽奖时,停止自动请求
	if self.auto_play_actions == false then
		self:CancelAutoPlayTimer()
		self.need_auto_play = false
	end
end

-- 暂停按钮点击加调
function LkDrawView:OnStopPlay()
	-- 停止并关闭自动抽奖
	self.node_t_list["btn_stop_play"].node:setVisible(false)
	self.need_auto_play = false
	self:CancelAutoPlayTimer()
end
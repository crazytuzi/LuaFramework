--------------------------------------------------------
-- 圣兽宫殿视图  配置 therionPalaceCfg
--------------------------------------------------------

BeastPalaceView = BeastPalaceView or BaseClass(BaseView)

function BeastPalaceView:__init()
	self.texture_path_list[1] = 'res/xui/beast_palace.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"beast_palace_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.copy_id = therionPalaceCfg.fbid -- 圣兽宫副本ID
	self.data = nil -- 圣兽宫数据
	self.boss_list = nil -- boss数据列表
	self.timer_list = {} -- 计时器列表
	self.item_cell = {} -- 物品列表

end

function BeastPalaceView:__delete()

end

--释放回调
function BeastPalaceView:ReleaseCallBack()

	if self.item_cell then
		for _, v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = {}
	end
end

--加载回调
function BeastPalaceView:LoadCallBack(index, loaded_times)
	self.data = BeastPalaceData.Instance:GetData() -- 获取数据索引(只需获取一次)
	self.copy_list = CrossServerData.Instance:GetCopyData() -- 获取跨服副本数据列表(只需获取一次)

	self:CreateCellView()
	self:CreateTextBtn()
	for i = 1, 4 do
		-- 按钮监听
		XUI.AddClickEventListener(self.node_t_list["img_" .. i].node, BindTool.Bind(self.OnBeast, self))
		-- 圣兽设置成黑白并屏蔽触摸
		self.node_t_list["img_" .. i].node:setGrey(true)
		self.node_t_list["img_" .. i].node:setTouchEnabled(false)
	end
	

	-- 数据监听
	EventProxy.New(BeastPalaceData.Instance, self):AddEventListener(BeastPalaceData.NUMBER_CHANGE, BindTool.Bind(self.FlushNumberView, self))
	EventProxy.New(CrossServerData.Instance, self):AddEventListener(CrossServerData.COPY_DATA_CHANGE, BindTool.Bind(self.OnCopyDataChange, self))

end

function BeastPalaceView:OpenCallBack()
	-- 请求"跨服副本"数据 返回(26, 86)
	CrossServerCtrl.Instance.SendCrossServerCopyDataReq(self.copy_id)
	-- 请求"圣兽宫殿"次数 返回(144, 10)
	BeastPalaceCtrl.Instance.SendBeastPalaceNumberReq(1)

	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BeastPalaceView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	-- 关闭窗口时,取消所有计时器
	for i = 1, 4 do
		GlobalTimerQuest:CancelQuest(self.timer_list[i])
		self:CancelTimer(i)
	end

end

--显示指数回调
function BeastPalaceView:ShowIndexCallBack(index)
		-- self:CheckTimer() -- 检查或创建记时器
	if self.copy_list[self.copy_id] then
		self:CheckTimer()
		self:FlushNameView()
	end
	self:FlushNumberView()
end

----------视图函数----------

-- 创建"购买击杀次数"按钮
function BeastPalaceView:CreateTextBtn()
	local ph = self.ph_list["ph_text_btn"]
	local text = RichTextUtil.CreateLinkText(Language.BeastPalace.TextBtn, 19, COLOR3B.GREEN, nil, true)
	text:setPosition(ph.x, ph.y)
	self.node_t_list["layout_beast_palace"].node:addChild(text, 20)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self), true)
end

-- 创建"物品图标"视图
function BeastPalaceView:CreateCellView()
	local data = BeastPalaceData.Instance:GetItemData()
	for i = 1, 6 do
		ph = self.ph_list["ph_cell_" .. i]
		self.item_cell[i] = BaseCell.New()
		self.item_cell[i]:SetPosition(ph.x, ph.y)
		self.item_cell[i]:GetView():setAnchorPoint(cc.p(0.5, 0.5))
		self.item_cell[i]:SetData(data[i])
		self.node_t_list["layout_beast_palace"].node:addChild(self.item_cell[i]:GetView(), 20)
	end
end

-- 刷新剩余击杀次数
function BeastPalaceView:FlushNumberView()
	for i = 1, 4 do
		self.node_t_list["lbl_number_" .. i].node:setString(self.data.number)
	end
end

-- 刷新上次归属
function BeastPalaceView:FlushNameView()
	for i = 1, 4 do
		local player_name = self.copy_list[self.copy_id].boss_list[i + 427].player_name
		if player_name ~= "" then
			self.node_t_list["lbl_name_" .. i].node:setString(player_name)
		else
			
		end
	end
end

----------end----------

----------计时器----------

-- 检查或创建记时器
function BeastPalaceView:CheckTimer()
	local left_time = nil -- 剩于时间
	for i = 1, 4 do
		self:FlushLeftTimeView(i)
		left_time = CrossServerData.Instance:GetBossRefreshTime(self.copy_list[self.copy_id].boss_list[i + 427])
		if left_time > 0 then
			if nil == self.timer_list[i] then
				self.timer_list[i] = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimerCallBack, self, i), 1)
			end

			-- 圣兽设置成黑白并屏蔽触摸,显示已击杀
			self.node_t_list["img_dead_" .. i].node:setVisible(true)
			self.node_t_list["img_" .. i].node:setGrey(true)
			self.node_t_list["img_" .. i].node:setTouchEnabled(false)
		else
			self:CancelTimer(i)
			self.node_t_list["img_dead_" .. i].node:setVisible(false)
			self.node_t_list["img_" .. i].node:setGrey(false)
			self.node_t_list["img_" .. i].node:setTouchEnabled(true)
		end
	end
end

-- 取消计时器
function BeastPalaceView:CancelTimer(index)
	if self.timer_list[index] then
		GlobalTimerQuest:CancelQuest(self.timer_list[index])
		self.timer_list[index] = nil
	end
end

-- 计时器每秒回调
function BeastPalaceView:TimerCallBack(index)
	local left_time = CrossServerData.Instance:GetBossRefreshTime(self.copy_list[self.copy_id].boss_list[index + 427])
	self:FlushLeftTimeView(index)
	if left_time == 0 then
		self:CheckTimer(index)
	end
end

-- 刷新剩余时间视图
function BeastPalaceView:FlushLeftTimeView(index)
	if (not ViewManager.Instance:IsOpen(ViewDef.BeastPalace)) then
		self:CancelTimer(index)
		return
	end
	local left_time = CrossServerData.Instance:GetBossRefreshTime(self.copy_list[self.copy_id].boss_list[index + 427])
	self.node_t_list["lbl_time_" .. index].node:setString(TimeUtil.FormatSecond(left_time, 3))
end

----------end----------

-- "文本按钮"点击回调
function BeastPalaceView:OnTextBtn()
	-- 请求购买击杀次数(144, 2)
	BeastPalaceCtrl.Instance.SendBeastPalaceNumberReq(2)
end

-- "圣兽"点击回调
function BeastPalaceView:OnBeast()
	-- 请求进入圣兽宫殿(144, 2)
	CrossServerCtrl.Instance.SentJoinCrossServerReq(4, 1)
end

-- 跨服副本数据改变回调
function BeastPalaceView:OnCopyDataChange()
	self:CheckTimer()
	self:FlushNameView()
end

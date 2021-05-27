---------------------------------------------
-- 运营活动 31 狂欢活动
---------------------------------------------

ActHolidayView = ActHolidayView or BaseClass(ActBaseView)

function ActHolidayView:__init(view, parent, act_id)
	self:LoadView(parent)

end

function ActHolidayView:__delete()
	if nil ~= self.consume_list then
		self.consume_list:DeleteMe()
		self.consume_list = nil
	end

	if nil ~= self.show_cell then
		self.show_cell:DeleteMe()
		self.show_cell = nil
	end

	if nil ~= self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar = nil
	end
end

-- 初始化视图
function ActHolidayView:InitView()
	self:CreateCellList()
	self:CreateShowCell()
	self:CreateProgressbar()

	-- 初始化self.cfg后,才能调用Flush函数
	local data = ActivityBrilliantData.Instance or {}
	local act_cfg = data:GetOperActCfg(self.act_id) or {}
	self.cfg = act_cfg.config or {}

	self:FlushBg()
	self:FlushCellList()
	self:FlushShowCell()
	self:FlushProgressbar()

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.FlushConsumeCell, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_COIN, BindTool.Bind(self.FlushConsumeCell, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_GOLD, BindTool.Bind(self.FlushConsumeCell, self))
end

-- 注册通用点击事件
function ActHolidayView:AddActCommonClickEventListener()
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OpenAwardsView, self))
	XUI.AddClickEventListener(self.node_t_list["btn_2"].node, BindTool.Bind(self.OnSubmitCallBack, self))
end

-- 视图关闭回调
function ActHolidayView:CloseCallback() 
end

-- 选中当前视图回调
function ActHolidayView:ShowIndexView()
end

-- 切换当前视图回调
function ActHolidayView:SwitchIndexView()
	
end

-- 刷新当前视图
function ActHolidayView:RefreshView(param_list)

	self:FlushProgressbar()

end

function ActHolidayView:FlushBg()
	local act_index = self.cfg.act_index or ""
	local path = ResPath.GetBigPainting("act_31_bg" .. act_index, false)
	self.node_t_list["img_bg"].node:loadTexture(path)
end

function ActHolidayView:CreateCellList()
	-- 锚点 0.5, 0.5
	local ph = self.ph_list["ph_consume_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
	local parent = self.tree.node
	local item_render = self.ConsumeCellRender
	local line_dis = ph_item.w
	local direction = ScrollDir.Horizontal -- 滑动方向-横向
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.OnCellCallBack, self))
	parent:addChild(grid_scroll:GetView(), 20)
	self.consume_list = grid_scroll
end

function ActHolidayView:FlushCellList()
	local consume = self.cfg.commitaward and self.cfg.commitaward.consume or {}
	local list = {}
	for i,v in ipairs(consume) do
		if type(v) == "table" and v[1] then
			table.insert(list, v[1])
		end
	end
	self.consume_list:SetDataList(list)
	self.consume_list:SetCenter()
end

function ActHolidayView:CreateShowCell()
	-- 锚点 0, 0
	local cell = ActBaseCell.New()
	local parent = self.tree.node
	local ph = self.ph_list["ph_show_cell"] or {x = 0, y = 0, w = 10, h = 10}
	cell:GetView():setPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 30)
	self.show_cell = cell
end

function ActHolidayView:FlushShowCell()
	local item_data = ItemData.Instance:GetItemConfig(self.cfg.show_id)
	self.show_cell:SetData(item_data)
end

function ActHolidayView:CreateProgressbar()
	self.prog_node = self.node_t_list["prog9_1"].node
	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(self.prog_node)
	self.progressbar:SetTailEffect(991, nil, true)
	self.progressbar:SetEffectOffsetX(-20)
	self.progressbar:SetPercent(0)
	self.progressbar:SetTotalTime(1)
end

function ActHolidayView:FlushProgressbar()
	local data = ActivityBrilliantData.Instance or {}

	local commitaward = self.cfg.commitaward or {}
	local max_happiness = commitaward.needhappiness or 0
	local happiness = data.sign and data.sign[self.act_id] or 0 -- 幸福度
	local percent = math.floor(happiness / max_happiness * 100)
	percent = math.min(percent, 100) 
	percent = math.max(percent, 0) 
	self.progressbar:SetPercent(percent)

	self.node_t_list["lbl_value"].node:setString(happiness .. "/" .. max_happiness)

	self.can_receive = percent >= 100 -- 可领取特殊奖励
	local receive_times = data.mine_num and data.mine_num[self.act_id] or 0 -- 已领取特殊奖励次数
	local daytimes = commitaward.daytimes or 0
	if receive_times < daytimes then
		if self.can_receive and self.node_t_list["btn_1"].node.UpdateReimd == nil then
			XUI.AddRemingTip(self.node_t_list["btn_1"].node)
		end
		if self.node_t_list["btn_1"].node.UpdateReimd then
			self.node_t_list["btn_1"].node:UpdateReimd(self.can_receive)
		end
	else
		self.node_t_list["btn_1"].node:setEnabled(false)
		if self.node_t_list["btn_1"].node.UpdateReimd then
			self.node_t_list["btn_1"].node:UpdateReimd(false)
		end
	end
end

-- 刷新活动公告
function ActHolidayView:OnFlushTopView(beg_time, end_time, act_desc)
	-- self.node_t_list["lbl_activity_about"].node:setString(act_desc[1])
end

-- 刷新活动剩余
function ActHolidayView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(end_time - now_time)
	self.node_t_list["lbl_activity_left_time"].node:setString(str)
end

function ActHolidayView:OpenAwardsView()
	if self.can_receive then
		local act_id = self.act_id or 0
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 1) -- 领取特殊奖励
	else
		local data = ActivityBrilliantData.Instance or {}
		local commitaward = self.cfg.commitaward or {}
		local max_happiness = commitaward.needhappiness
		local happiness = data.sign and data.sign[self.act_id] -- 幸福度
		local color = happiness >= max_happiness and COLORSTR.GREEN or COLORSTR.RED
		--例 爱心回馈,0/1000幸福度可免费领取
		local text = string.format(Language.ActivityBrilliant.Text38, color, happiness, max_happiness)

		local item_list = {}
		for i, item in ipairs(commitaward.happyaward or {}) do
			local item_data = ItemData.InitItemDataByCfg(item)
			table.insert(item_list, item_data)
		end
		TipCtrl.Instance:OpenAwardShowTip(text, item_list)
	end
end

function ActHolidayView:OnSubmitCallBack()
	if self.select_index and self.select_index > 0 then
		if self.can_submit then
			local act_id = self.act_id or 0
			ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0, self.select_index)
		else
			SystemHint.Instance:FloatingTopRightText(Language.ActivityBrilliant.Text39)
		end
	else
		SystemHint.Instance:FloatingTopRightText(Language.ActivityBrilliant.Text40)
	end
end

function ActHolidayView:OnCellCallBack(item)
	self.select_index = item:GetIndex()
	self.can_submit = item.can_submit
end

function ActHolidayView:FlushConsumeCell()
	local cells = self.consume_list:GetItems()
	for i, cell in ipairs(cells) do
		cell:Flush()
	end

	local cell = cells[self.select_index] or {}
	self.can_submit = cell.can_submit
end

----------------------------------------
-- 项目渲染命名
----------------------------------------
ActHolidayView.ConsumeCellRender = BaseClass(BaseRender)
local ConsumeCellRender = ActHolidayView.ConsumeCellRender
function ConsumeCellRender:__init()
	self.item_cell = nil
end

function ConsumeCellRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ConsumeCellRender:CreateChild()
	BaseRender.CreateChild(self)

	local cell = ActBaseCell.New()
	cell:SetEventEnabled(false)
	self.view:addChild(cell:GetView(), 20)
	self.item_cell = cell
end

function ConsumeCellRender:OnFlush()
	if nil == self.data then return end
	local item_data = ItemData.InitItemDataByCfg(self.data)
	self.item_cell:SetData(item_data)

	local cfg_num = self.data.count or 0
	local item_id = self.data.id or 0
	local item_type = self.data.type or 0
	local num = BagData.GetConsumesCount(item_id, item_type)

	self.can_submit = num >= cfg_num -- 可提交
	XUI.SetLayoutImgsGrey(self.item_cell:GetView(), not self.can_submit)
end
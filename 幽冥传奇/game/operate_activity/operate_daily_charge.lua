-- 运营活动-每日充值
DailyChargePage = DailyChargePage or BaseClass()

function DailyChargePage:__init()
	self.view = nil
	self.reward_cell = {}
	self.cells_container = nil
end

function DailyChargePage:__delete()
	self:RemoveEvent()
	if self.reward_cell then 
		for k, v in pairs(self.reward_cell) do
			v:GetView():removeFromParent()
			v:DeleteMe()
		end
		self.reward_cell = {}
	end

	if self.cells_container then
		self.cells_container:removeFromParent()
		self.cells_container = nil
	end

	if self.charge_num then
		self.charge_num:DeleteMe()
		self.charge_num = nil
	end

	self.view = nil
end


function DailyChargePage:InitPage(view)
	self.view = view
	self:CreateCellsContainer()
	self:CreateChargeNumberBar()
	self:InitEvent()
	self:OnDailyChargeDataChange()
end

--初始化事件
function DailyChargePage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_charge_every_day.node, BindTool.Bind(self.OnChargeMoneyClick, self), true)
	self.daily_charge_evt = GlobalEventSystem:Bind(OperateActivityEventType.DAILY_CHARGE_DATA_CHANGE, BindTool.Bind(self.OnDailyChargeDataChange, self))
end

--移除事件
function DailyChargePage:RemoveEvent()
	if self.daily_charge_evt then
		GlobalEventSystem:UnBind(self.daily_charge_evt)
		self.daily_charge_evt = nil
	end
end

function DailyChargePage:CreateCellsContainer()
	if not self.cells_container then
		local pos_x, pos_y = self.view.node_t_list.btn_charge_every_day.node:getPositionX(), self.view.node_t_list.btn_charge_every_day.node:getPositionY()
		self.cells_container = XLayout:create(0, 80)
		self.cells_container:setAnchorPoint(0.5, 0)
		self.cells_container:setPosition(pos_x, pos_y + 70)
		self.view.node_t_list.layout_charge_everyday.node:addChild(self.cells_container, 100)
	end
end

function DailyChargePage:CreateChargeNumberBar()
	if not self.charge_num then
		local ph = self.view.ph_list.ph_money_num
		-- 需要充值金额
		self.charge_num = NumberBar.New()
		self.charge_num:SetRootPath(ResPath.GetMainui("num_"))
		self.charge_num:SetPosition(ph.x + 6, ph.y)
		self.charge_num:SetSpace(-6)
		self.charge_num:SetGravity(NumberBarGravity.Center)
		self.charge_num:GetView():setScale(1.5)
		self.view.node_t_list.layout_charge_everyday.node:addChild(self.charge_num:GetView(), 300, 300)
	end
end

-- 刷新
function DailyChargePage:UpdateData(param_t, index)
end

function DailyChargePage:SetAwardCells(awards_data)
	if not awards_data or not next(awards_data) then return end

	local gap = 8
	local cell_cnt = #awards_data
	local need_width = (80 * cell_cnt) + (cell_cnt - 1) * gap
	self.cells_container:setContentWH(need_width, 80)
	for i, v in ipairs(awards_data) do
		if not self.reward_cell[i] then
			local cell = BaseCell.New()
			cell:SetPosition((i - 1) * 88, 0)
			cell:SetData(v)
			cell.eff = RenderUnit.CreateEffect(7, cell:GetView(), 201, nil, nil)
			self.cells_container:addChild(cell:GetView(), 100)
			self.reward_cell[i] = cell
		else
			local cell = self.reward_cell[i]
			cell:SetPosition((i - 1) * 88, 0)
			cell:SetData(v)
		end
	end
end

function DailyChargePage:FlushInfo()
	local daily_charge_data = OperateActivityData.Instance:GetDailyChargeData()
	if nil == daily_charge_data then return end

	local state = daily_charge_data.state
	local grade = daily_charge_data.grade
	local path = nil
	if state == 0 then
		path = ResPath.GetVipResPath("text_bg")
	else
		path = ResPath.GetCommon("stamp_14")
	end
	self.view.node_t_list.img_recharge.node:loadTexture(path)
	self.view.node_t_list.btn_charge_every_day.node:setEnabled(grade <= daily_charge_data.maxGrade and state ~= DAILY_CHARGE_FETCH_ST.FETCHED)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_charge_every_day.node, grade >= daily_charge_data.maxGrade and state == DAILY_CHARGE_FETCH_ST.FETCHED, true)

	self:SetAwardCells(daily_charge_data.awards)
	local gold_num = daily_charge_data.target_money
	self.charge_num:SetNumber(gold_num)
	-- self.view.node_t_list.img_bg.node:loadTexture(ResPath.GetCharge("charge_level_" .. grade))
end

function DailyChargePage:OnDailyChargeDataChange()
	self:FlushInfo()
end

function DailyChargePage:OnChargeMoneyClick()
	local daily_charge_data = OperateActivityData.Instance:GetDailyChargeData()
	if nil == daily_charge_data then return end

	local state = daily_charge_data.state
	local grade = daily_charge_data.grade
	local cmd_id = daily_charge_data.cmd_id
	if state == 0 then 
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	else
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.DAILY_RECHARGE, grade)
	end
end
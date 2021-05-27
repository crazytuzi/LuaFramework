--重复充值
OperateRepeatChargePage = OperateRepeatChargePage or BaseClass()

function OperateRepeatChargePage:__init()
	self.view = nil
	self.reward_cell = {}
	self.cells_container = nil
end

function OperateRepeatChargePage:__delete()
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


function OperateRepeatChargePage:InitPage(view)
	self.view = view
	self.view.node_t_list.rich_repeat_charge_rest.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- self.view.node_t_list.rich_repeat_charge_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:CreateCellsContainer()
	-- self:CreateChargeNumberBar()
	self:SetAwardCells()
	self:InitEvent()
	self:OnRepeatChargeDataChange()
end

--初始化事件
function OperateRepeatChargePage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_charge_repeat.node, BindTool.Bind(self.OnChargeMoneyClick, self), true)
	self.repeate_charge_evt = GlobalEventSystem:Bind(OperateActivityEventType.REPEAT_CHARGE_DATA_CHANGE, BindTool.Bind(self.OnRepeatChargeDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

--移除事件
function OperateRepeatChargePage:RemoveEvent()
	if self.repeate_charge_evt then
		GlobalEventSystem:UnBind(self.repeate_charge_evt)
		self.repeate_charge_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

function OperateRepeatChargePage:CreateCellsContainer()
	if not self.cells_container then
		local pos_x, pos_y = self.view.node_t_list.btn_charge_repeat.node:getPositionX(), self.view.node_t_list.btn_charge_repeat.node:getPositionY()
		self.cells_container = XLayout:create(0, 80)
		self.cells_container:setAnchorPoint(0.5, 0)
		self.cells_container:setPosition(pos_x, pos_y + 70)
		self.view.node_t_list.layout_repeat_charge.node:addChild(self.cells_container, 100)
	end
end

function OperateRepeatChargePage:CreateChargeNumberBar()
	if not self.charge_num then
		local ph = self.view.ph_list.ph_money_num
		-- 需要充值金额
		self.charge_num = NumberBar.New()
		self.charge_num:SetRootPath(ResPath.GetMainui("num_"))
		self.charge_num:SetPosition(ph.x + 6, ph.y)
		self.charge_num:SetSpace(-6)
		self.charge_num:SetGravity(NumberBarGravity.Center)
		self.charge_num:GetView():setScale(1.5)
		self.view.node_t_list.layout_repeat_charge.node:addChild(self.charge_num:GetView(), 300, 300)
	end
end

-- 刷新
function OperateRepeatChargePage:UpdateData(param_t, index)
end

function OperateRepeatChargePage:SetAwardCells()
	local base_data = OperateActivityData.Instance:GetRepeatChargeBaseData()
	if not base_data or not next(base_data) then return end

	local awards_data = base_data.awards
	if not awards_data or not next(awards_data) then return end
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.REPEAT_CHARGE)
	local content = act_cfg and act_cfg.act_desc
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_repeat_charge_des.node, content, 24, COLOR3B.YELLOW)
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

function OperateRepeatChargePage:FlushInfo()
	local base_data = OperateActivityData.Instance:GetRepeatChargeBaseData()
	if not base_data or not next(base_data) then return end
	local rest_cnt = OperateActivityData.Instance:GetRepeatChargeRestCount()
	local content = string.format(Language.OperateActivity.RepeatChargeTexts[2], rest_cnt)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_repeat_charge_rest.node, content, 20)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_charge_repeat.node, rest_cnt <= 0, true)
	-- self.view.node_t_list.btn_charge_repeat.node:setEnabled(rest_cnt > 0)
end

-- 倒计时
function OperateRepeatChargePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.REPEAT_CHARGE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_time_4 then
		self.view.node_t_list.text_time_4.node:setString(time_str)
	end
end

function OperateRepeatChargePage:OnRepeatChargeDataChange()
	self:FlushTime()
	self:FlushInfo()
end

function OperateRepeatChargePage:OnChargeMoneyClick()
	self.view:Close()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end
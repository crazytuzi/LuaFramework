-- 运营活动-幸运购
LuckyBuyPage = LuckyBuyPage or BaseClass()

function LuckyBuyPage:__init()
	self.view = nil
	self.reward_cell = {}
	self.cells_container = nil
end

function LuckyBuyPage:__delete()
	self:RemoveEvent()
	if self.reward_cell then 
		for k, v in pairs(self.reward_cell) do
			v:GetView():removeFromParent()
			v:DeleteMe()
		end
		self.reward_cell = {}
	end

	if self.special_award_cell then
		self.special_award_cell:DeleteMe()
		self.special_award_cell = nil
	end

	if self.cells_container then
		self.cells_container:removeFromParent()
		self.cells_container = nil
	end
	-- self.is_first_open = true

	self.view = nil
end


function LuckyBuyPage:InitPage(view)
	self.view = view
	self.is_first_open = true
	self:CreateCellsContainer()
	self:InitEvent()
	self.scroll_node = self.view.node_t_list["rich_lucky_buy_rule"].node
	self.rich_content = XUI.CreateRichText(50, 0, 374, 0, false)
	self.scroll_node:addChild(self.rich_content, 100, 100)
	
end

--初始化事件
function LuckyBuyPage:InitEvent()
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_of_name.node, Language.Activity.FortuneBuyTip, 20, COLOR3B.OLIVE)
	XUI.AddClickEventListener(self.view.node_t_list.btn_lucky_buy.node, BindTool.Bind(self.OnLuckyBuyClick, self), true)
	self.lucky_buy_data_evt = GlobalEventSystem:Bind(OperateActivityEventType.LUCKY_BUY_DATA, BindTool.Bind(self.OnLuckyBuyDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self),  1)
end

--移除事件
function LuckyBuyPage:RemoveEvent()
	if self.lucky_buy_data_evt then
		GlobalEventSystem:UnBind(self.lucky_buy_data_evt)
		self.lucky_buy_data_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function LuckyBuyPage:CreateCellsContainer()
	if not self.cells_container then
		local ph = self.view.ph_list.ph_lucky_buy_awards_container
		self.cells_container = XLayout:create(0, 80)
		self.cells_container:setAnchorPoint(0.5, 0)
		self.cells_container:setPosition(ph.x, ph.y)
		self.view.node_t_list.layout_lucky_buy.node:addChild(self.cells_container, 100)
	end

	if self.special_award_cell == nil then
		local ph = self.view.ph_list.ph_lucky_buy_special_cell
		self.special_award_cell = BaseCell.New()
		self.special_award_cell:SetPosition(ph.x, ph.y)
		RenderUnit.CreateEffect(7, self.special_award_cell:GetView(), 201, nil, nil)
		self.view.node_t_list.layout_lucky_buy.node:addChild(self.special_award_cell:GetView(), 100)
	end
end

-- 刷新
function LuckyBuyPage:UpdateData(param_t, index)
	self:FlushTime()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCKY_BUY)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.LUCKY_BUY)
	end

	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.LUCKY_BUY)
	local content = cfg and cfg.act_desc or ""
	local real_content = string.gsub(content, "##", "\n")
	RichTextUtil.ParseRichText(self.rich_content, real_content, 20)
	self.rich_content:refreshView()
	local scroll_size = self.scroll_node:getContentSize()
	local inner_h = math.max(self.rich_content:getInnerContainerSize().height + 10, scroll_size.height)
	self.scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	self.rich_content:setPosition(scroll_size.width / 2, inner_h - 5)
	self.scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end

function LuckyBuyPage:FlushTime()
	local awar_open_time = OperateActivityData.Instance:GetLuckyBuyAwarOpenTime()
	local cur_time = ActivityData.GetNowShortTime()
	self.view.node_t_list.btn_lucky_buy.node:setEnabled(cur_time < awar_open_time)
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.LUCKY_BUY)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	-- if self:IsNowZhengDian(cur_time) then
	-- 	self.is_first_open = true
	-- 	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCKY_BUY)
	-- 	if cmd_id then
	-- 		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.LUCKY_BUY)
	-- 	end
	-- end

	if self.view.node_t_list.text_time_lucky_buy then
		self.view.node_t_list.text_time_lucky_buy.node:setString(time_str)
	end

end

function LuckyBuyPage:IsNowZhengDian(now_time)
	for i = 0, 23 do
		if now_time == i * 3600 then
			return true
		end
	end
	return false
end

function LuckyBuyPage:SetAwardCells(awards_data)
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
			cell.eff = RenderUnit.CreateEffect(920, cell:GetView(), 201, nil, nil)
			self.cells_container:addChild(cell:GetView(), 100)
			self.reward_cell[i] = cell
		else
			local cell = self.reward_cell[i]
			cell:SetPosition((i - 1) * 88, 0)
			cell:SetData(v)
		end
	end
end

function LuckyBuyPage:FlushInfo()
	local all_cnt, my_cnt, cur_cost = OperateActivityData.Instance:GetLuckyBuyCnt()
	local all_cnt_str = string.format(Language.OperateActivity.LuckyBuyTxts[1], all_cnt)
	local my_cnt_str = string.format(Language.OperateActivity.LuckyBuyTxts[2], my_cnt)
	-- if self.is_first_open then
	-- 	self.is_first_open = false
	-- 	self.view.node_t_list.txt_lucky_buy_all_cnt.node:setString(all_cnt_str)
	-- end
	self.view.node_t_list.txt_lucky_buy_all_cnt.node:setString(all_cnt_str)
	self.view.node_t_list.txt_lucky_buy_my_cnt.node:setString(my_cnt_str)
	self.view.node_t_list.txt_lucky_buy_cost.node:setString(cur_cost)
	local cur_group_award, cur_daily_awards = OperateActivityData.Instance:GetAwardsData()
	if cur_group_award then
		self.special_award_cell:SetData(cur_group_award)
	end
	self:SetAwardCells(cur_daily_awards)
end

function LuckyBuyPage:OnLuckyBuyDataChange()
	self:FlushInfo()
end

function LuckyBuyPage:OnLuckyBuyClick()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LUCKY_BUY)
	if cmd_id then 
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LUCKY_BUY)
	end
end
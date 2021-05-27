-- 运营活动-摇钱树
OperateActPrayTreePage = OperateActPrayTreePage or BaseClass()

function OperateActPrayTreePage:__init()
	self.view = nil
end

function OperateActPrayTreePage:__delete()
	self:RemoveEvent()

	if self.awards_show_list then
		for k, v in pairs(self.awards_show_list) do
			v:DeleteMe()
		end
		self.awards_show_list = nil
	end

	if self.yb_pool_award_list then
		for k, v in pairs(self.yb_pool_award_list) do
			v:DeleteMe()
		end
		self.yb_pool_award_list = nil
	end

	if self.awards_result_wnd then
		self.awards_result_wnd:DeleteMe()
		self.awards_result_wnd = nil
	end
	self.sel_idx = nil
	self.view = nil
end


function OperateActPrayTreePage:InitPage(view)
	self.view = view
	self:CreateShowItemsList()

	self:InitEvent()
	self:OnDataChange()
end

--初始化事件
function OperateActPrayTreePage:InitEvent()
	-- self.view.node_t_list.btn_pray_tree_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list.btn_pray_one.node, BindTool.Bind(self.OnPrayOneTime, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_pray_ten.node, BindTool.Bind(self.OnPrayTenTime, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_pray_tree_tip.node,BindTool.Bind(self.OnHelp,self),true)

	self.pray_money_tree_data_change_evt = GlobalEventSystem:Bind(OperateActivityEventType.PRAY_MONEY_TREE_DATA_CHANGE, BindTool.Bind(self.OnDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function OperateActPrayTreePage:RemoveEvent()
	if self.pray_money_tree_data_change_evt then
		GlobalEventSystem:UnBind(self.pray_money_tree_data_change_evt)
		self.pray_money_tree_data_change_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

function OperateActPrayTreePage:CreateShowItemsList()
	if not self.awards_show_list then
		self.awards_show_list = {}
		for i = 1, 7 do
			local cell = BaseCell.New()
			local ph = self.view.ph_list["ph_pray_cell_" .. i]
			cell:SetPosition(ph.x, ph.y)
			cell.eff = RenderUnit.CreateEffect(920, cell:GetView(), 210, nil, nil)
			self.view.node_t_list.layout_pray_money_tree.node:addChild(cell:GetView(), 100)
			self.awards_show_list[i] = cell
		end
	end

	if not self.yb_pool_award_list then
		self.yb_pool_award_list = {}
		for i = 1, 6 do
			local ph = self.view.ph_list["ph_yb_award_" .. i]
			local render = OperateActPrayYBPoolRender.New()
			render:SetUiConfig(self.view.ph_list.ph_yb_award_render, true)
			render:SetPosition(ph.x, ph.y)
			render:SetIndex(i)
			render:AddClickEventListener(BindTool.Bind(self.OnYbPoolAwardRenderClicked, self, render, i))
			self.view.node_t_list.layout_pray_money_tree.node:addChild(render:GetView(), 100)
			self.yb_pool_award_list[i] = render
		end
	end

	if not self.awards_result_wnd then
		self.awards_result_wnd = AwardResultWnd.New()
		self.awards_result_wnd:SetTenTimeFunc(function() 
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE, self.index, 1, OperateActivityData.PrayMoneyBuyType.TenTime)
				end
			end)
		self.awards_result_wnd:SetOneMoreTimeFunc(function() 
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE, self.index, 1, OperateActivityData.PrayMoneyBuyType.OneTime)
				end
			end)
	end
end

function OperateActPrayTreePage:OnYbPoolAwardRenderClicked(render, index)
	if not render or self.sel_idx == index then 
		return 
	end
	render:SetSelect(true)
	if self.sel_idx and self.yb_pool_award_list[self.sel_idx] then
		self.yb_pool_award_list[self.sel_idx]:SetSelect(false)
	end
	self.sel_idx = index
end

function OperateActPrayTreePage:SetStaticInfo()
	local data = OperateActivityData.Instance:GetPrayMoneyTreeCfgInfo()
	if not next(data) or not self.awards_show_list or not self.yb_pool_award_list then return end
	for k, v in ipairs(data.show_item_list) do
		if self.awards_show_list[k] then
			self.awards_show_list[k]:SetData(v)
		end
	end	
	for i, v in ipairs(data.exchange) do
		local money_str = v.ExchangeCost
		money_str = money_str .. (ShopData.GetMoneyTypeName(data.cost_type) or "")
		if v.consumes then
			local item_data = v.consumes[1]
			local cfg = ItemData.Instance:GetItemConfig(item_data.id)
			if cfg then
				money_str = money_str .. string.format(Language.OperateActivity.PrayTreeItemCost, cfg.name, item_data.count)
			end
		end
		self.view.node_t_list["txt_pray_cost_" .. i].node:setString(money_str)
	end
end

-- 刷新
function OperateActPrayTreePage:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
	end

	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_pray_des.node, content, 24, COLOR3B.YELLOW)
	self:SetStaticInfo()
end

function OperateActPrayTreePage:FlushInfo()
	local data = OperateActivityData.Instance:GetPrayMoneyTreeCfgInfo()
	if not next(data) then return end
	for k, v in ipairs(data.yb_pool_info) do
		if self.yb_pool_award_list[k] then
			self.yb_pool_award_list[k]:SetData(v)
		end
	end
	local all_ser_buy_time, awar_pool_yb_cnt = OperateActivityData.Instance:GetPrayMoneyAllSerData()
	self.view.node_t_list.txt_all_serv_pray_time.node:setString(all_ser_buy_time)
	self.view.node_t_list.txt_awar_pool_yb_cnt.node:setString(awar_pool_yb_cnt)
end

function OperateActPrayTreePage:OnDataChange()
	self:FlushRemainTime()
	self:FlushInfo()
	if self.awards_result_wnd then
		local award_data, extra_awar_data = OperateActivityData.Instance:GetPrayMoneyGetAwardsInfo()
		if next(award_data) then
			self.awards_result_wnd:SetData(award_data)
			self.awards_result_wnd:Open()
			if next(extra_awar_data) then
				for k, v in ipairs(extra_awar_data) do
					local str = string.format(Language.OperateActivity.PrayExtraAwarTip, v.buy_idx, v.awar_cnt)
					SystemHint.Instance:FloatingTopRightText(str)
				end
			end
			OperateActivityData.Instance:EmptyGetAwardsInfo()
		end
	end
end

function OperateActPrayTreePage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)

	if self.view.node_t_list.txt_pray_tree_time then
		self.view.node_t_list.txt_pray_tree_time.node:setString(time)
	end
	
end

-- 摇1次
function OperateActPrayTreePage:OnPrayOneTime()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
	if cmd_id then
		if self.awards_result_wnd then
			self.awards_result_wnd:SetOperType(OperateActivityData.PrayMoneyBuyType.OneTime)
		end
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE, self.index, 1, OperateActivityData.PrayMoneyBuyType.OneTime)
	end
end

-- 摇10次
function OperateActPrayTreePage:OnPrayTenTime()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
	if cmd_id then
		if self.awards_result_wnd then
			self.awards_result_wnd:SetOperType(OperateActivityData.PrayMoneyBuyType.TenTime)
		end
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE, self.index, 1, OperateActivityData.PrayMoneyBuyType.TenTime)
	end
end

--帮助点击
function OperateActPrayTreePage:OnHelp()
	DescTip.Instance:SetContent(Language.OperateActivity.Content[1], Language.OperateActivity.Title[1])
end	
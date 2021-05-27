-- 运营活动-摇钱树
OperateActPrayTreePageTwo = OperateActPrayTreePageTwo or BaseClass()

function OperateActPrayTreePageTwo:__init()
	self.view = nil
end

function OperateActPrayTreePageTwo:__delete()
	self:RemoveEvent()

	if self.awards_show_list then
		for k, v in pairs(self.awards_show_list) do
			v:DeleteMe()
		end
		self.awards_show_list = nil
	end

	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end

	if self.awards_result_wnd then
		self.awards_result_wnd:DeleteMe()
		self.awards_result_wnd = nil
	end
	self.view = nil
end


function OperateActPrayTreePageTwo:InitPage(view)
	self.view = view
	self:CreateShowItemsList()

	self:InitEvent()
	self:OnDataChange()
end

--初始化事件
function OperateActPrayTreePageTwo:InitEvent()
	self.view.node_t_list.btn_pray2_tree_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list.btn_pray2_one.node, BindTool.Bind(self.OnPrayOneTime, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_pray2_ten.node, BindTool.Bind(self.OnPrayTenTime, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_pray2_tree_tip.node,BindTool.Bind(self.OnHelp,self),true)

	self.pray_money_tree_data_change_evt = GlobalEventSystem:Bind(OperateActivityEventType.PRAY_MONEY_TREE_DATA_CHANGE_2, BindTool.Bind(self.OnDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function OperateActPrayTreePageTwo:RemoveEvent()
	if self.pray_money_tree_data_change_evt then
		GlobalEventSystem:UnBind(self.pray_money_tree_data_change_evt)
		self.pray_money_tree_data_change_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

function OperateActPrayTreePageTwo:CreateShowItemsList()
	if not self.awards_show_list then
		self.awards_show_list = {}
		for i = 1, 7 do
			local cell = BaseCell.New()
			local ph = self.view.ph_list["ph_pray2_cell_" .. i]
			cell:SetPosition(ph.x, ph.y)
			cell.eff = RenderUnit.CreateEffect(920, cell:GetView(), 210, nil, nil)
			self.view.node_t_list.layout_pray_money_tree_2.node:addChild(cell:GetView(), 100)
			self.awards_show_list[i] = cell
		end
	end
	if self.grid_scroll == nil then
		local ph = self.view.ph_list.ph_pray2_grid
		local item_ui_cfg = self.view.ph_list.ph_yb2_award_render
		self.grid_scroll = GridScroll.New()
		self.grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 3, item_ui_cfg.h + 5, OperateActPrayYBPoolRenderTwo, ScrollDir.Vertical, false, item_ui_cfg)
		self.grid_scroll:SetSelectCallBack(BindTool.Bind(self.OnYbPoolAwardRenderClicked, self))
		self.view.node_t_list.layout_pray_money_tree_2.node:addChild(self.grid_scroll:GetView(), 100)
	end
	if not self.awards_result_wnd then
		self.awards_result_wnd = AwardResultWnd.New()
		self.awards_result_wnd:SetTenTimeFunc(function() 
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2, self.index, 1, OperateActivityData.PrayMoneyBuyType.TenTime)
				end
			end)
	end
end

function OperateActPrayTreePageTwo:OnYbPoolAwardRenderClicked(render)
	if not render or not render:GetData() then 
		return 
	end
	
end

function OperateActPrayTreePageTwo:SetStaticInfo()
	local data = OperateActivityData.Instance:GetPrayMoneyTreeCfgInfoTwo()
	if not next(data) or not self.awards_show_list then return end
	for k, v in ipairs(data.show_item_list) do
		if self.awards_show_list[k] then
			self.awards_show_list[k]:SetData(v)
		end
	end	
	for i, v in ipairs(data.exchange) do
		local money_str = v.ExchangeCost
		money_str = money_str .. (ShopData.GetMoneyTypeName(data.cost_type) or "")
		self.view.node_t_list["txt_pray2_cost_" .. i].node:setString(money_str)
	end
end

-- 刷新
function OperateActPrayTreePageTwo:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)
	end

	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_pray2_des.node, content, 20, COLOR3B.GREEN)
	self:SetStaticInfo()
end

function OperateActPrayTreePageTwo:FlushInfo()
	local data = OperateActivityData.Instance:GetPrayMoneyTreeCfgInfoTwo()
	if not next(data) then return end
	self.grid_scroll:SetDataList(data.yb_pool_info)
	local my_score = OperateActivityData.Instance:GetPrayMoneyTreeTwoMyScore()
	self.view.node_t_list.txt_my_score.node:setString(my_score)
end

function OperateActPrayTreePageTwo:OnDataChange()
	self:FlushRemainTime()
	self:FlushInfo()
	if self.awards_result_wnd then
		local award_data = OperateActivityData.Instance:GetPrayMoneyGetAwardsInfoTwo()
		if next(award_data) then
			self.awards_result_wnd:SetData(award_data)
			self.awards_result_wnd:Open()
			OperateActivityData.Instance:EmptyGetAwardsInfoTwo()
		end
	end
end

function OperateActPrayTreePageTwo:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)

	if self.view.node_t_list.txt_pray2_tree_time then
		self.view.node_t_list.txt_pray2_tree_time.node:setString(time)
	end
	
end

-- 摇1次
function OperateActPrayTreePageTwo:OnPrayOneTime()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2, self.index, 1, OperateActivityData.PrayMoneyBuyType.OneTime)
	end
end

-- 摇10次
function OperateActPrayTreePageTwo:OnPrayTenTime()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2, self.index, 1, OperateActivityData.PrayMoneyBuyType.TenTime)
	end
end

--帮助点击
function OperateActPrayTreePageTwo:OnHelp()
	DescTip.Instance:SetContent(Language.OperateActivity.Content[1], Language.OperateActivity.Title[1])
end	
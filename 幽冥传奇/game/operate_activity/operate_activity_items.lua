------限时商品Render------
OperateActLimitGoodsRender = OperateActLimitGoodsRender or BaseClass(BaseRender)
function OperateActLimitGoodsRender:__init()

end

function OperateActLimitGoodsRender:__delete()	
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateActLimitGoodsRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 2 do
		local ph = self.ph_list["ph_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		self.view:addChild(cell:GetView(), 100)
		table.insert(self.cell_list, cell)
	end
	self.node_tree.btn_buy.node:addClickEventListener(BindTool.Bind(self.OnBuyClick, self))
end

function OperateActLimitGoodsRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.text_ingot.node:setString(self.data.ingot)
	self.node_tree.img_box.node:loadTexture(ResPath.GetLimitedActivity("box_" .. self.data.idx))
	self.node_tree.btn_buy.node:setTitleText("￥ " .. self.data.money)
	for i = 1, 2 do
		self.cell_list[i]:SetData(self.data.awards[i]) 
	end
end

function OperateActLimitGoodsRender:OnBuyClick()
	local role_id = GameVoManager.Instance:GetUserVo():GetNowRole()
	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	local server_id = GameVoManager.Instance:GetUserVo().real_server_id		--登陆的服ID
	local amount = self.data.money
	if amount and amount > 0 and role_id and role_name and server_id then
		AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)
		Log("Recharge:", role_name, role_id, server_id, amount)
	else
		SysMsgCtrl.Instance:ErrorRemind("充值失败!!!", force)
	end
end

function OperateActLimitGoodsRender:CreateSelectEffect()

end

-- 限时商品2Render
OperateActLimitGoodsRenderTwo = OperateActLimitGoodsRenderTwo or BaseClass(BaseRender)
function OperateActLimitGoodsRenderTwo:__init()

end

function OperateActLimitGoodsRenderTwo:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateActLimitGoodsRenderTwo:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_buy.node:addClickEventListener(BindTool.Bind(self.OnBuyClick, self))
end

function OperateActLimitGoodsRenderTwo:OnFlush()

	if nil == self.data then return end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	self.node_tree.btn_buy.node:setTitleText("￥ " .. self.data.money)
	local txt = string.format(Language.Limited.LimitGoods, self.data.money)
	self.node_tree.txt_name.node:setString(txt)

end

function OperateActLimitGoodsRenderTwo:CreateSelectEffect()

end

function OperateActLimitGoodsRenderTwo:OnBuyClick()
	local role_id = GameVoManager.Instance:GetUserVo():GetNowRole()
	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	local server_id = GameVoManager.Instance:GetUserVo().real_server_id		--登陆的服ID
	local amount = self.data.money
	if amount and amount > 0 and role_id and role_name and server_id then
		AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)
		Log("Recharge:", role_name, role_id, server_id, amount)
	else
		SysMsgCtrl.Instance:ErrorRemind("充值失败!!!", force)
	end
end

-- 限时单笔
OperateActTimeLimitOnceRender = OperateActTimeLimitOnceRender or BaseClass(BaseRender)
function OperateActTimeLimitOnceRender:__init()

end

function OperateActTimeLimitOnceRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateActTimeLimitOnceRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_buy.node:addClickEventListener(BindTool.Bind(self.OnBuyClick, self))
end

function OperateActTimeLimitOnceRender:OnFlush()
	if nil == self.data then return end
	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	self.node_tree.btn_buy.node:setEnabled(self.data.state ~= 2)
	local txt = "￥ " .. self.data.money
	if self.data.state ~= 0 then
		txt = Language.OperateActivity.FetchStateTexts[self.data.state]
	end
	self.node_tree.btn_buy.node:setTitleText(txt)
	self.node_tree.txt_name.node:setString(self.data.desc)

end

function OperateActTimeLimitOnceRender:CreateSelectEffect()

end

function OperateActTimeLimitOnceRender:OnBuyClick()
	if not self.data then return end
	if self.data.state == 0 then
		local role_id = GameVoManager.Instance:GetUserVo():GetNowRole()
		local role_name = GameVoManager.Instance:GetMainRoleVo().name
		local server_id = GameVoManager.Instance:GetUserVo().real_server_id		--登陆的服ID
		local amount = self.data.money
		if amount and amount > 0 and role_id and role_name and server_id then
			AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)
			Log("Recharge:", role_name, role_id, server_id, amount)
		else
			SysMsgCtrl.Instance:ErrorRemind("充值失败!!!", force)
		end
	elseif self.data.state == 1 then
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE, self.data.idx)
		end
	end
end


-- 累计充值奖励Render
OperateActAccumuChargeRender = OperateActAccumuChargeRender or BaseClass(BaseRender)
function OperateActAccumuChargeRender:__init()

end

function OperateActAccumuChargeRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateActAccumuChargeRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OperateActAccumuChargeRender:OnFlush()

	if nil == self.data then return end
	if self.data.state == 0 then
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local my_money = OperateActivityData.Instance:GetRechargeMoney()
		local need_money = self.data.money - my_money
		local txt_1 = string.format(Language.Limited.Need, need_money)
		self.node_tree.layout_nodabiao.txt_need_name.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_reward.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	
	local txt = string.format(Language.Limited.Reward, self.data.money)
	self.node_tree.txt_name.node:setString(txt)

end

function OperateActAccumuChargeRender:CreateSelectEffect()

end

function OperateActAccumuChargeRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE, self.index)
	end
end

-- 每日累计充值奖励Render
OperateActDailyAccuChargeRender = OperateActDailyAccuChargeRender or BaseClass(BaseRender)
function OperateActDailyAccuChargeRender:__init()

end

function OperateActDailyAccuChargeRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateActDailyAccuChargeRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_consume.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OperateActDailyAccuChargeRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.btn_get_consume.node:setEnabled(self.data.state == 1)
	self.node_tree.btn_get_consume.node:setVisible(self.data.state ~= 2)
	self.node_tree.Image_dabiao.node:setVisible(self.data.state == 2)
	self.node_tree.txt_need_name1.node:setString("")
	if self.data.state == 0 then
		local charge_money = OperateActivityData.Instance:GetDailyRechargeMoney()
		local need_money = self.data.money - charge_money
		local txt_1 = string.format(Language.Limited.Need, need_money)
		self.node_tree.txt_need_name1.node:setString(txt_1)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end

	local txt = string.format(Language.Limited.Reward, self.data.money)
	self.node_tree.txt_name_1.node:setString(txt)	  

end

function OperateActDailyAccuChargeRender:CreateSelectEffect()

end

function OperateActDailyAccuChargeRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.DAILY_CHARGE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.DAILY_CHARGE, self.index)
	end
end

--累计消费Render
OperateAccumuSpendRender = OperateAccumuSpendRender or BaseClass(BaseRender)
function OperateAccumuSpendRender:__init()
	
end

function OperateAccumuSpendRender:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateAccumuSpendRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1) * 85, ph.y)
		equip_cell:SetAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_consume.node:addClickEventListener(BindTool.Bind(self.OnFetchAwardsClick, self))
end

function OperateAccumuSpendRender:OnFlush()
	if nil == self.data then return end
	if self.data.state == 0 then
		self.node_tree.btn_get_consume.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local consumemoney = OperateActivityData.Instance:GetConsumeMoney()
		local need_money = self.data.money - consumemoney
		local txt_1 = string.format(Language.Limited.Need, need_money)
		self.node_tree.layout_nodabiao.txt_need_name1.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_consume.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_consume.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end

	local txt = string.format(Language.Limited.Consume, self.data.money)
	self.node_tree.txt_name_1.node:setString(txt)	  
end

function OperateAccumuSpendRender:CreateSelectEffect()

end

function OperateAccumuSpendRender:OnFetchAwardsClick()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND, self.index)
	end
end

--每日累计消费Render
OperateDailySpendRender = OperateDailySpendRender or BaseClass(BaseRender)
function OperateDailySpendRender:__init()
	
end

function OperateDailySpendRender:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateDailySpendRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1) * 85, ph.y)
		equip_cell:SetAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_consume.node:addClickEventListener(BindTool.Bind(self.OnFetchAwardsClick, self))
end

function OperateDailySpendRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.btn_get_consume.node:setEnabled(self.data.state == 1)
	self.node_tree.btn_get_consume.node:setVisible(self.data.state ~= 2)
	self.node_tree.Image_dabiao.node:setVisible(self.data.state == 2)
	self.node_tree.txt_need_name1.node:setString("")
	if self.data.state == 0 then
		local consumemoney = OperateActivityData.Instance:GetDailyConsumeMoney()
		local need_money = self.data.money - consumemoney
		local txt_1 = string.format(Language.Limited.Need, need_money)
		self.node_tree.txt_need_name1.node:setString(txt_1)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end

	local txt = string.format(Language.Limited.Consume, self.data.money)
	self.node_tree.txt_name_1.node:setString(txt)	  
end

function OperateDailySpendRender:CreateSelectEffect()

end

function OperateDailySpendRender:OnFetchAwardsClick()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.DAILY_SPEND)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.DAILY_SPEND, self.index)
	end
end


-- 宝物折扣Render
OperActDiscountTreasureRender = OperActDiscountTreasureRender or BaseClass(BaseRender)
function OperActDiscountTreasureRender:__init()

end

function OperActDiscountTreasureRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperActDiscountTreasureRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_consume.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OperActDiscountTreasureRender:OnFlush()
	if nil == self.data then return end
	
	for k, v in pairs(self.cell_list) do
		v:SetVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end

	local txt = string.format(Language.OperateActivity.DiscountTreasureDesc, self.data.desc, self.data.need_money, self.data.rest_cnt)
	self.node_tree.txt_name_1.node:setString(txt)	  

end

function OperActDiscountTreasureRender:CreateSelectEffect()

end

function OperActDiscountTreasureRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE, self.data.idx)
	end
end


-- 达标竞技Render
OperateSportsItem = OperateSportsItem or BaseClass(BaseRender)
function OperateSportsItem:__init()
	self.cells_list = {}
end

function OperateSportsItem:__delete()
	for k, v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
	self.awar_icon = nil
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function OperateSportsItem:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_open_cell
	self.cells_list = {}
	for i = 1, 3 do
		ph = self.ph_list["ph_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetVisible(false)
		self.view:addChild(cell:GetView(), 99)
		self.cells_list[i] = cell
	end
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchClicked, self), true)
	self.node_tree.txt_fetch_awar_time.node:setLocalZOrder(100)
	self.node_tree.txt_fetch_awar.node:setLocalZOrder(100)
end

function OperateSportsItem:OnFlush()
	if not self.data then return end
	local icon_id = OperateActivityData.GetSportsAndRankIconIDByActID(self.data.act_id)
	if not self.awar_icon then
		local img_ph = self.ph_list.ph_open_cell
		local path = ResPath.GetOperateActsRes("icon_" .. icon_id)
		self.awar_icon = XUI.CreateImageView(img_ph.x, img_ph.y, path, true)
		self.view:addChild(self.awar_icon, 100)
	else
		local path = ResPath.GetOperateActsRes("icon_" .. icon_id)
		self.awar_icon:loadTexture(path)
	end
	
	for i, v in ipairs(self.cells_list) do
		v:SetVisible(false)
	end

	for i, v in ipairs(self.data.awards) do
		if self.cells_list[i] then
			self.cells_list[i]:SetVisible(true)
			self.cells_list[i]:SetData(v)
		end
	end
	self.node_tree.txt_item_name.node:setString(self.data.desc)


	if self.data.top1_name and self.data.top1_role_id then
		local main_role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
		self.node_tree.img_state.node:setVisible(self.data.top1_name == "")
		self.node_tree.btn_fetch.node:setVisible(false)
		self.node_tree.txt_rest_title.node:setString(Language.OpenServiceAcitivity.TopOne)
		self.node_tree.txt_rest_cnt.node:setString(self.data.top1_name ~= "" and self.data.top1_name or Language.Common.ZanWu)
		self.node_tree.txt_fetch_awar_time.node:setString("")
		self.node_tree.txt_fetch_awar.node:setString("")
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end

		if self.data.top1_name ~= "" then
			self:SetTimerCountDown()
		end
		-- else
		-- 	self.node_tree.img_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		-- end
	else
		self.node_tree.txt_rest_cnt.node:setString(self.data.max_cnt == -1 and Language.OpenServiceAcitivity.NoLimit or self.data.rest_cnt)
		self.node_tree.btn_fetch.node:setVisible(self.data.state == STANDARD_SPROTS_FETCH_STATE.CAN_FETCH)
		self.node_tree.img_state.node:setVisible(self.data.state ~= STANDARD_SPROTS_FETCH_STATE.CAN_FETCH)
		if self.node_tree.img_state.node:isVisible() then
			local path = ""
			if self.data.state == STANDARD_SPROTS_FETCH_STATE.NOT_COMPLETE then
				path = ResPath.GetCommon("stamp_3")
			elseif self.data.state == STANDARD_SPROTS_FETCH_STATE.HAVE_FETCHED then
				path = ResPath.GetCommon("stamp_10")
			elseif self.data.state == STANDARD_SPROTS_FETCH_STATE.NO_CNT then
				path = ResPath.GetCommon("stamp_11")
			end
			self.node_tree.img_state.node:loadTexture(path)
		end
	end
end

-- 设置倒计时
function OperateSportsItem:SetTimerCountDown()
	if nil == self.data then return end

	local is_daily_act = OperateActivityData.IsDailySports(self.data.act_id)
	local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
	local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local cur_time = nil
	local end_time = nil
	if is_daily_act then
		cur_time = (format_time.hour * 60 + format_time.min) * 60 + format_time.sec
		end_time = 24 * 3600
	else
		local act_cfg = OperateActivityData.Instance:GetActCfgByActID(self.data.act_id)
		if not act_cfg then return end

		cur_time = server_time
		end_time = act_cfg.end_time
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if not self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetTimerCountDown, self), 60)
	end
	local left_time = end_time - cur_time
	if left_time <= 0 then 
		self.node_tree.txt_fetch_awar_time.node:setString("")
		self.node_tree.txt_fetch_awar.node:setString("")
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
			return
		end
	end

	local time_str = TimeUtil.FormatSecond2Str(left_time, 0)
	self.node_tree.txt_fetch_awar_time.node:setString(time_str)
	self.node_tree.txt_fetch_awar.node:setString(Language.OpenServiceAcitivity.Fetch)
end

function OperateSportsItem:OnFetchClicked()
	if not self.data then return end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(self.data.act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, self.data.act_id, self.index)
	end
end

-- 创建选中特效
function OperateSportsItem:CreateSelectEffect()
	
end

------消费积分ItemRender------------
SpendScoreItemRender = SpendScoreItemRender or BaseClass(BaseRender)
function SpendScoreItemRender:__init()
	self.item_cell = nil
end

function SpendScoreItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SpendScoreItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	-- self.item_cell:SetEventEnabled(false)
	self.item_cell:GetView():setAnchorPoint(cc.p(0,0))
	self.view:addChild(self.item_cell:GetView(), 100)
	
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
	
	-- local act_eff = RenderUnit.CreateEffect(920, self.view, 200, nil, nil, self.ph_list.ph_item_cell.x + self.ph_list.ph_item_cell.w / 2 , self.ph_list.ph_item_cell.y + self.ph_list.ph_item_cell.h / 2)
	
end

function SpendScoreItemRender:OnClickBuyBtn()
	if not self.data then return end
	local act_id = OPERATE_ACTIVITY_ID.SPEND_SCORE
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.idx, oper_type)
	end
end

-- function SpendScoreItemRender:OnClick()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end

function SpendScoreItemRender:OnFlush()
	
	if nil == self.data then
		return
	end
	local awar_item = self.data.awards_t[1]
	local item_config = ItemData.Instance:GetItemConfig(awar_item.item_id)
	if nil == item_config then
		return
	end
	self.item_cell:SetData(awar_item)

	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_item_name.node:setString(item_config.name)

	self.node_tree.lbl_item_cost.node:setColor(COLOR3B.WHITE)
	self.node_tree.lbl_item_cost.node:setString(self.data.cost)

	local rest_buy = ""
	if self.data.rest_cnt > 0 then
		rest_buy = string.format(Language.Common.RestCount, self.data.rest_cnt)
	end
	self.node_tree.lbl_rest_buy.node:setString(rest_buy)
end

function SpendScoreItemRender:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img9_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	self.select_effect:setScale(1.1)
	self.select_effect:setScaleX(1.05)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
end


------超值限购ItemRender------------
DiscountLimitItemRender = DiscountLimitItemRender or BaseClass(BaseRender)
function DiscountLimitItemRender:__init()
	self.item_cell = nil
end

function DiscountLimitItemRender:__delete()
	-- if self.draw_node then
	-- 	self.draw_node:clear()
	-- 	self.draw_node:removeFromParent()
	-- 	self.draw_node = nil
	-- end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function DiscountLimitItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	self.item_cell:GetView():setScale(0.8)
	-- self.item_cell:SetEventEnabled(false)
	self.item_cell:GetView():setAnchorPoint(cc.p(0,0))
	self.view:addChild(self.item_cell:GetView(), 100)
	self.draw_node = cc.DrawNode:create()
	self.view:addChild(self.draw_node, 99)
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
	
	-- local act_eff = RenderUnit.CreateEffect(920, self.view, 200, nil, nil, self.ph_list.ph_item_cell.x + self.ph_list.ph_item_cell.w / 2 , self.ph_list.ph_item_cell.y + self.ph_list.ph_item_cell.h / 2)
	
end

function DiscountLimitItemRender:OnClickBuyBtn()
	if not self.data then return end
	local act_id = OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.idx, oper_type)
	end
end

-- function DiscountLimitItemRender:OnClick()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end

function DiscountLimitItemRender:OnFlush()
	
	if nil == self.data then
		return
	end
	local awar_item = self.data.awards_t[1]
	local item_config = ItemData.Instance:GetItemConfig(awar_item.item_id)
	if nil == item_config then
		return
	end
	self.item_cell:SetData(awar_item)

	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_item_name.node:setString(item_config.name)

	self.node_tree.txt_cost_price.node:setString(self.data.now_price)
	self.node_tree.txt_old_price.node:setString(self.data.old_price)
	local old_price = self.data.old_price
	old_price = tostring(old_price)
	local str_len = string.len(old_price)
	local line_len = 10 * str_len
	self.draw_node:clear()
	local x, y = self.node_tree.txt_old_price.node:getPositionX(), self.node_tree.txt_old_price.node:getPositionY()

	local pos1 = cc.p(x + 3, y - 10)
	local pos2 = cc.p(pos1.x + line_len, pos1.y)
	self.draw_node:drawSegment(pos1, pos2, 1, cc.c4f(1, 0, 0, 1))

	local rest_buy = ""
	if self.data.rest_cnt > 0 then
		rest_buy = string.format(Language.Common.RestCount, self.data.rest_cnt)
	end
	self.node_tree.txt_rest_buy_time.node:setString(rest_buy)
end

function DiscountLimitItemRender:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img9_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	self.select_effect:setScale(1.1)
	self.select_effect:setScaleX(1.05)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
end


-- 天数充值奖励Render
OperateDayNumChargeRender = OperateDayNumChargeRender or BaseClass(BaseRender)
function OperateDayNumChargeRender:__init()

end

function OperateDayNumChargeRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateDayNumChargeRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OperateDayNumChargeRender:OnFlush()

	if nil == self.data then return end
	if self.data.state == 0 then
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local day_num = OperateActivityData.Instance:GetRechargeDayNum()
		local need_day = self.data.day_cond - day_num
		local txt_1 = string.format(Language.OperateActivity.DayNumTexts[2], need_day)
		self.node_tree.layout_nodabiao.txt_need_name.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_reward.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	
	local txt = string.format(Language.OperateActivity.DayNumTexts[3], self.data.day_cond)
	self.node_tree.txt_name.node:setString(txt)

end

function OperateDayNumChargeRender:CreateSelectEffect()

end

function OperateDayNumChargeRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE, self.index)
	end
end


-- 连续累充充值奖励Render
ContiAddupChargeItem = ContiAddupChargeItem or BaseClass(BaseRender)
function ContiAddupChargeItem:__init()

end

function ContiAddupChargeItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function ContiAddupChargeItem:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	self.interval = 2
	local ph = self.ph_list.ph_cells_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 99)
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
	self.node_tree.btn_get_reward.node:setLocalZOrder(1000)
end

function ContiAddupChargeItem:OnFlush()
	if nil == self.data then return end
	self.node_tree.btn_get_reward.node:setVisible(self.data.state == DAILY_CHARGE_FETCH_ST.CAN)
	self.node_tree.Image_dabiao.node:setVisible(self.data.state ~= DAILY_CHARGE_FETCH_ST.CAN)
	local all_data = OperateActivityData.Instance:GetContinousAddupChargeData()
	local day_num = all_data and all_data.day
	local str = ""
	local path = ResPath.GetCommon("stamp_3")
	if self.data.state ~= DAILY_CHARGE_FETCH_ST.CNNOT then
		path = ResPath.GetCommon("stamp_9")
	elseif day_num and day_num == self.data.idx and self.data.money and self.data.money < self.data.need_num then
		str = string.format(Language.OperateActivity.ContiAddupChargeTxts[2], self.data.need_num-self.data.money)
	end
	self.node_tree.txt_need_name1.node:setString(str)	
	self.node_tree.Image_dabiao.node:loadTexture(path)
	self.node_tree.txt_item_name.node:setString(string.format(Language.OperateActivity.ContiAddupChargeTxts[3], self.data.idx))
	self.node_tree.txt_min_des.node:setString(string.format(Language.OperateActivity.RankMinTexts[1], self.data.need_num))
	self:SetCellsListData(self.data.awards)

end

function ContiAddupChargeItem:CreateSelectEffect()

end

function ContiAddupChargeItem:SetCellsListData(data)
	if data == nil then return end
	self.cells_list:SetData(data)
	local ph = self.ph_list.ph_cells_list
	local len = #data
	if len < 3 then
		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
		self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.cells_list:GetView():setPosition(ph.x, ph.y)
	end	
end

function ContiAddupChargeItem:GetReward()
	if not self.data then return end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE, self.data.idx, 1)
	end
end

-- 天数消费奖励Render
OperateDayNumSpendRender = OperateDayNumSpendRender or BaseClass(BaseRender)
function OperateDayNumSpendRender:__init()

end

function OperateDayNumSpendRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateDayNumSpendRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OperateDayNumSpendRender:OnFlush()

	if nil == self.data then return end
	if self.data.state == 0 then
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local day_num = OperateActivityData.Instance:GetSpendDayNum()
		local need_day = self.data.day_cond - day_num
		local txt_1 = string.format(Language.OperateActivity.DayNumTexts[2], need_day)
		self.node_tree.layout_nodabiao.txt_need_name.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_reward.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	
	local txt = string.format(Language.OperateActivity.DayNumTexts[6], self.data.day_cond)
	self.node_tree.txt_name.node:setString(txt)

end

function OperateDayNumSpendRender:CreateSelectEffect()

end

function OperateDayNumSpendRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.DAY_NUM_SPEND)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.DAY_NUM_SPEND, self.index)
	end
end

-- 团购活动奖励Render
GroupPurchaseAwardRender = GroupPurchaseAwardRender or BaseClass(BaseRender)
function GroupPurchaseAwardRender:__init()

end

function GroupPurchaseAwardRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function GroupPurchaseAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function GroupPurchaseAwardRender:OnFlush()

	if nil == self.data then return end
	if self.data.state == 0 then
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local buy_cnt = OperateActivityData.Instance:GetGroupPurchaseAllBuyTime()
		local need_buy_cnt = self.data.buyCnt - buy_cnt
		local txt_1
		if need_buy_cnt <= 0 then
			txt_1 = Language.OperateActivity.GroupPurchaseTexts[6]
		else
			txt_1 = string.format(Language.OperateActivity.GroupPurchaseTexts[2], need_buy_cnt)
		end
		self.node_tree.layout_nodabiao.txt_need_name.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_reward.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in pairs(self.data.awards_t) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	
	local txt = string.format(Language.OperateActivity.GroupPurchaseTexts[3], self.data.buyCnt)
	self.node_tree.txt_name.node:setString(txt)

end

function GroupPurchaseAwardRender:CreateSelectEffect()

end

function GroupPurchaseAwardRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.GROUP_PURCHASE, self.index, 2)
	end
end

-- 超级团购活动奖励Render
SuperGroupPurchaseAwardRender = SuperGroupPurchaseAwardRender or BaseClass(BaseRender)
function SuperGroupPurchaseAwardRender:__init()

end

function SuperGroupPurchaseAwardRender:__delete()
	for k,v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
	self.cells_view_container:removeFromParent()
	self.cells_view_container = nil
end

function SuperGroupPurchaseAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cells_list = {}
	self:CreateCellsContainer()
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function SuperGroupPurchaseAwardRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.btn_get_reward.node:setVisible(self.data.state == 1)
	self.node_tree.img_standard.node:setVisible(self.data.state == 2)
	self.node_tree.img_not_standard.node:setVisible(self.data.state == 0)

	local txt_1 = ""
	if self.data.state == 0 then

		local buy_cnt = OperateActivityData.Instance:GetSuperGroupPurchaseAllBuyTime()
		local need_buy_cnt = self.data.buyCnt - buy_cnt
		if need_buy_cnt <= 0 then
			txt_1 = Language.OperateActivity.GroupPurchaseTexts[6]
		else
			txt_1 = string.format(Language.OperateActivity.GroupPurchaseTexts[2], need_buy_cnt)
		end
	end
	self.node_tree.txt_need_name.node:setString(txt_1)

	self:SetAwardCells(self.data.awards_t)
	
	local txt = string.format(Language.OperateActivity.GroupPurchaseTexts[3], self.data.buyCnt)
	self.node_tree.txt_name.node:setString(txt)

end

function SuperGroupPurchaseAwardRender:CreateSelectEffect()

end

function SuperGroupPurchaseAwardRender:CreateCellsContainer()
	if not self.cells_view_container then
		local ph = self.ph_list.ph_cells_container
		self.cells_view_container = XLayout:create(0, 64)
		self.cells_view_container:setAnchorPoint(0.5, 0)
		self.cells_view_container:setPosition(ph.x, ph.y)
		self.view:addChild(self.cells_view_container, 100)
	end
end

function SuperGroupPurchaseAwardRender:SetAwardCells(awards_data)
	if not awards_data or not next(awards_data) then return end

	local gap = 2
	local award_cnt = #awards_data
	local need_width = (64 * award_cnt) + (award_cnt - 1) * gap
	self.cells_view_container:setContentWH(need_width, 64)
	-- 多余的删除掉
	if #self.cells_list > award_cnt then
		local no_need_cnt = #self.cells_list - award_cnt
		for i = 1, no_need_cnt do
			local cell = table.remove(self.cells_list, #self.cells_list)
			if cell then
				cell:GetView():removeFromParent()
				cell:DeleteMe()
			end
		end
	end

	for i, v in ipairs(awards_data) do
		if not self.cells_list[i] then
			local cell = BaseCell.New()
			cell:GetView():setScale(0.8)
			cell:SetPosition((i - 1) * (64 + gap), 0)
			cell:SetData(v)
			self.cells_view_container:addChild(cell:GetView(), 100)
			self.cells_list[i] = cell
		else
			local cell = self.cells_list[i]
			cell:GetView():setPositionX((i - 1) * (64 + gap))
			cell:SetData(v)
		end
	end
end

function SuperGroupPurchaseAwardRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE, self.index, 2)
	end
end

-- 超级团购活动选中出售Render
SuperGroupChosenItem = SuperGroupChosenItem or BaseClass(BaseRender)
function SuperGroupChosenItem:__init()

end

function SuperGroupChosenItem:__delete()
	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end

	if self.chosen_item_cell then
		self.chosen_item_cell:DeleteMe()
		self.chosen_item_cell = nil
	end
end

function SuperGroupChosenItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_group_buy.node, BindTool.Bind(self.BuyItem, self), true)
	local ph = self.ph_list.ph_chosen_item_cell
	self.chosen_item_cell = BaseCell.New()
	self.chosen_item_cell:SetPosition(ph.x, ph.y)
	-- self.chosen_item_cell:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.chosen_item_cell:GetView(), 100)

	self.draw_node = cc.DrawNode:create()
	self.view:addChild(self.draw_node, 99)
end

function SuperGroupChosenItem:OnFlush()
	if nil == self.data then return end
	self.chosen_item_cell:SetData(self.data.item)
	local rest_buy = string.format(Language.OperateActivity.GroupPurchaseTexts[4], self.data.rest_buy_time)
	self.node_tree.txt_group_rest_buy_time.node:setString(rest_buy)
	self.node_tree.btn_group_buy.node:setEnabled(self.data.rest_buy_time > 0)
	local content = string.format(Language.OperateActivity.GroupPurchaseTexts[5], self.data.now_price, self.data.old_price)
	self.node_tree.txt_cost_price.node:setString(self.data.now_price)
	self.node_tree.txt_old_price.node:setString(self.data.old_price)
	local old_price = self.data.old_price
	old_price = tostring(old_price)
	local str_len = string.len(old_price)
	local line_len = 10 * str_len
	self.draw_node:clear()
	local x, y = self.node_tree.txt_old_price.node:getPositionX(), self.node_tree.txt_old_price.node:getPositionY()

	local pos1 = cc.p(x + 3, y - 10)
	local pos2 = cc.p(pos1.x + line_len, pos1.y)
	self.draw_node:drawSegment(pos1, pos2, 0.45, cc.c4f(1, 0, 0, 1))
end

function SuperGroupChosenItem:CreateSelectEffect()

end

function SuperGroupChosenItem:BuyItem()
	if not self.data then return end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE, self.data.idx, 1)
	end
end

-- 竞技排行Render
OperateSportsRankItem = OperateSportsRankItem or BaseClass(BaseRender)
function OperateSportsRankItem:__init()
	self.cells_list = {}
	self.cells_view_container = nil
end

function OperateSportsRankItem:__delete()
	for k, v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
	self.cells_view_container:removeFromParent()
	self.cells_view_container = nil
	self.awar_icon = nil
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function OperateSportsRankItem:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateCellsContainer()
	self.node_tree.img_rank_des_bg.node:setLocalZOrder(99)
	self.node_tree.txt_rank_des.node:setLocalZOrder(99)
end

function OperateSportsRankItem:OnFlush()
	if not self.data then return end
	local min_des = ""
	-- local min_des_2 = ""
	if self.data.act_id == OPERATE_ACTIVITY_ID.GREATE_RECHARGE_RANK or self.data.act_id == OPERATE_ACTIVITY_ID.GREATE_SPEND_RANK then
		if self.data.need_min_value then
			if self.data.act_id == OPERATE_ACTIVITY_ID.GREATE_RECHARGE_RANK then
				min_des = string.format(Language.OperateActivity.RankMinTexts[1], self.data.need_min_value)
			else
				min_des = string.format(Language.OperateActivity.RankMinTexts[2], self.data.need_min_value)
			end
		end
	else
		if self.data.need_min_charge then
			min_des = string.format(Language.OperateActivity.RankMinTexts[3], self.data.need_min_charge)
		end
	end
	self.node_tree.img_rank_des_bg.node:setVisible(self.data.rank_des ~= nil)
	self.node_tree.txt_rank_des.node:setString(self.data.rank_des or "")
	self.node_tree.txt_min_des.node:setString(min_des)
	-- self.node_tree.txt_min_des_2.node:setString(min_des_2)
	local icon_id = OperateActivityData.GetSportsAndRankIconIDByActID(self.data.act_id)
	if not self.awar_icon then
		local img_ph = self.ph_list.ph_open_cell
		local path = ResPath.GetOperateActsRes("icon_" .. icon_id)
		self.awar_icon = XUI.CreateImageView(img_ph.x, img_ph.y, path, true)
		self.view:addChild(self.awar_icon, 10)
	else
		local path = ResPath.GetOperateActsRes("icon_" .. icon_id)
		self.awar_icon:loadTexture(path)
	end
	self:SetAwardCells(self.data.awards)
	self.node_tree.txt_item_name.node:setString(self.data.desc)
	self.node_tree.txt_item_name_2.node:setString(self.data.desc)
	self.node_tree.txt_item_name.node:setVisible(self.data.need_min_value ~= nil)
	self.node_tree.txt_item_name_2.node:setVisible(self.data.need_min_value == nil)
end

-- 设置倒计时
function OperateSportsRankItem:SetTimerCountDown()
	if nil == self.data then return end
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(self.data.act_id)
	if not act_cfg then return end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if not self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetTimerCountDown, self), 60)
	end
	local cur_time = TimeCtrl.Instance:GetServerTime() or os.time()
	local end_time = act_cfg.end_time
	local left_time = end_time - cur_time
	if left_time <= 0 then 
		self.node_tree.txt_fetch_awar_time.node:setString("")
		self.node_tree.txt_fetch_awar.node:setString("")
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
			return
		end
	end

	local time_str = TimeUtil.FormatSecond2Str(left_time, 0)
	self.node_tree.txt_fetch_awar_time.node:setString(time_str)
	RichTextUtil.ParseRichText(self.node_tree.rich_fetch_awar.node, Language.OpenServiceAcitivity.Fetch, 16, COLOR3B.BRIGHT_GREEN)
end

function OperateSportsRankItem:CreateCellsContainer()
	if not self.cells_view_container then
		local ph = self.ph_list.ph_cells_container
		self.cells_view_container = XLayout:create(0, 80)
		self.cells_view_container:setAnchorPoint(0.5, 0)
		self.cells_view_container:setPosition(ph.x, ph.y)
		self.view:addChild(self.cells_view_container, 100)
	end
end

function OperateSportsRankItem:SetAwardCells(awards_data)
	if not awards_data or not next(awards_data) then return end

	local gap = 2
	local award_cnt = #awards_data
	local need_width = (80 * award_cnt) + (award_cnt - 1) * gap
	self.cells_view_container:setContentWH(need_width, 80)
	-- 多余的删除掉
	if #self.cells_list > award_cnt then
		local no_need_cnt = #self.cells_list - award_cnt
		for i = 1, no_need_cnt do
			local cell = table.remove(self.cells_list, #self.cells_list)
			if cell then
				cell:GetView():removeFromParent()
				cell:DeleteMe()
			end
		end
	end

	for i, v in ipairs(awards_data) do
		if not self.cells_list[i] then
			local cell = BaseCell.New()
			cell:SetPosition((i - 1) * (80 + gap), 0)
			cell:SetData(v)
			self.cells_view_container:addChild(cell:GetView(), 100)
			self.cells_list[i] = cell
		else
			local cell = self.cells_list[i]
			cell:GetView():setPositionX((i - 1) * (80 + gap))
			cell:SetData(v)
		end
	end
end

-- 创建选中特效
function OperateSportsRankItem:CreateSelectEffect()
	
end


RecordRender = RecordRender or BaseClass(BaseRender)
function RecordRender:__init()	
end

function RecordRender:__delete()	
end

function RecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function RecordRender:OnFlush()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then 
		return 
	end
	local  color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.player_name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local text = string.format(Language.OperateActivity.Txt, self.rolename_color, self.rolename_color, self.data.player_name, self.rolename_color, Language.OperateActivity.Prefix, color, item_cfg.name, self.data.item_id, color, self.data.num)
	if self.node_tree.rich_record_content then
		RichTextUtil.ParseRichText(self.node_tree.rich_record_content.node, text, 20)
	end
end

function RecordRender:CreateSelectEffect()

end

-- 累计登陆奖励Render
OperateActAddupLoginRender = OperateActAddupLoginRender or BaseClass(BaseRender)
function OperateActAddupLoginRender:__init()

end

function OperateActAddupLoginRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateActAddupLoginRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OperateActAddupLoginRender:OnFlush()

	if nil == self.data then return end
	
	if self.data.state == 0 then
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local login_day = OperateActivityData.Instance:GetAddupLoginDayNum()
		local need_day = self.data.cond - login_day
		local txt_1 = string.format(Language.OperateActivity.AddupLoginTexts[1], need_day)
		self.node_tree.layout_nodabiao.txt_need_name.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_reward.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in ipairs(self.cell_list) do
		v:SetVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	
	self.node_tree.txt_name.node:setString(self.data.desc)

end

function OperateActAddupLoginRender:CreateSelectEffect()

end

function OperateActAddupLoginRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.ADDUP_LOGIN)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.ADDUP_LOGIN, self.data.idx)
	end
end

-- 寻宝10连抽送奖奖励Render
TenTimeExplGiveRender = TenTimeExplGiveRender or BaseClass(BaseRender)
function TenTimeExplGiveRender:__init()

end

function TenTimeExplGiveRender:__delete()
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end
end

function TenTimeExplGiveRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_list
	local item_ui_cfg = self.ph_list.ph_vip_cell
	self.cell_list = ListView.New()
	self.cell_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, item_ui_cfg)
	self.cell_list:SetItemsInterval(2)
	self.view:addChild(self.cell_list:GetView(), 99)
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function TenTimeExplGiveRender:OnFlush()
	if nil == self.data then return end
	
	self.node_tree.Image_dabiao.node:setVisible(self.data.state == 2)
	self.node_tree.btn_get_reward.node:setEnabled(self.data.state == 1)
	self.node_tree.btn_get_reward.node:setVisible(self.data.state ~= 2)
	local unit = OperateActivityData.Instance:GetTenTimeExploreGiveUnit()
	local need_cnt = self.data.need_cnt - OperateActivityData.Instance:GetTenTimeExploreGiveCnt() / unit
	self.node_tree.txt_need_name.node:setString(need_cnt > 0 and string.format(Language.OperateActivity.NeedCntStr, need_cnt) or "")

	self.cell_list:SetData(self.data.awards)
	self.node_tree.txt_name.node:setString(self.data.desc)

end

function TenTimeExplGiveRender:CreateSelectEffect()

end

function TenTimeExplGiveRender:GetReward()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE, self.data.idx)
	end
end

--摇钱树元宝奖池Render
OperateActPrayYBPoolRender = OperateActPrayYBPoolRender or BaseClass(BaseRender)
function OperateActPrayYBPoolRender:__init()
	
end

function OperateActPrayYBPoolRender:__delete()
	
end

function OperateActPrayYBPoolRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchClicked, self), true)
	XUI.AddClickEventListener(self.node_tree.img_icon.node, BindTool.Bind(self.OnShowTips, self), false)
end

function OperateActPrayYBPoolRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_icon.node:loadTexture(ResPath.GetItem(self.data.icon))
	self.node_tree.img_fetched_stamp.node:setVisible(self.data.state == PRAY_MONEY_TREE_FETCH_STATE.FETCHED)
	self.node_tree.btn_fetch.node:setVisible(self.data.state == PRAY_MONEY_TREE_FETCH_STATE.CAN)
	self.node_tree.layout_base_info.node:setVisible(self.data.state ~= PRAY_MONEY_TREE_FETCH_STATE.CAN)
	self.node_tree.layout_base_info.txt_buy_cnt.node:setString(self.data.buy_cnt .. Language.Common.Count)
	self.node_tree.layout_base_info.txt_vip_cond.node:setString(string.format(Language.OperateActivity.VipCond, self.data.vip_lv))
end

function OperateActPrayYBPoolRender:OnFetchClicked()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE, self.index, 2)
	end
end

function OperateActPrayYBPoolRender:SetSelecStampVis(vis)
	-- if self.node_tree and self.node_tree.img_selected_stamp.node then
	-- 	self.node_tree.img_selected_stamp.node:setVisible(vis)
	-- end
end

function OperateActPrayYBPoolRender:OnShowTips()
	if not self.data then return end
	self:OnClick()
	TipsCtrl.Instance:OpenPrayTreeTip(self.data.tips)
end

function OperateActPrayYBPoolRender:CreateSelectEffect()
	local size = cc.size(80, 80)
	local pos_x, pos_y = self.node_tree.img_icon.node:getPosition() 
	self.select_effect = XUI.CreateImageViewScale9(pos_x, pos_y, size.width, size.height, ResPath.GetCommon("cell_select_bg_2"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

-- 选择状态改变
function OperateActPrayYBPoolRender:OnSelectChange(is_select)

end


--幸运转盘奖励展示Render
OperateActLuckTurnAwarRender = OperateActLuckTurnAwarRender or BaseClass(BaseRender)
function OperateActLuckTurnAwarRender:__init()

end

function OperateActLuckTurnAwarRender:__delete()
	
end

function OperateActLuckTurnAwarRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_selec.node:setVisible(self.index == 1)
end

function OperateActLuckTurnAwarRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_awar_icon.node:loadTexture(ResPath.GetItem(self.data.icon))
end

function OperateActLuckTurnAwarRender:SetSelecStampVis(vis)
	if self.node_tree and self.node_tree.img_selec.node then
		self.node_tree.img_selec.node:setVisible(vis)
	end
end

function OperateActLuckTurnAwarRender:CreateSelectEffect()

end

-- 聚宝盆记录
JvBaoRecordRender = JvBaoRecordRender or BaseClass(BaseRender)
function JvBaoRecordRender:__init()	
end

function JvBaoRecordRender:__delete()	
end

function JvBaoRecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function JvBaoRecordRender:OnFlush()
	if self.data == nil then return end
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.player_name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local text = string.format(Language.OperateActivity.JvBaoTxt, self.rolename_color, self.rolename_color, self.data.player_name, self.rolename_color, self.data.cost_money, self.data.get_money)
	if self.node_tree.rich_record_content then
		RichTextUtil.ParseRichText(self.node_tree.rich_record_content.node, text, 18)
	end
end

function JvBaoRecordRender:CreateSelectEffect()

end


--摇钱树2元宝奖池Render
OperateActPrayYBPoolRenderTwo = OperateActPrayYBPoolRenderTwo or BaseClass(BaseRender)
function OperateActPrayYBPoolRenderTwo:__init()
	
end

function OperateActPrayYBPoolRenderTwo:__delete()
	
end

function OperateActPrayYBPoolRenderTwo:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchClicked, self), true)
	XUI.AddClickEventListener(self.node_tree.img_icon.node, BindTool.Bind(self.OnShowTips, self), false)
end

function OperateActPrayYBPoolRenderTwo:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_icon.node:loadTexture(ResPath.GetItem(self.data.icon))
	self.node_tree.img_fetched_stamp.node:setVisible(self.data.state == PRAY_MONEY_TREE_FETCH_STATE.FETCHED)
	self.node_tree.btn_fetch.node:setVisible(self.data.state == PRAY_MONEY_TREE_FETCH_STATE.CAN)
	self.node_tree.layout_base_info.node:setVisible(self.data.state ~= PRAY_MONEY_TREE_FETCH_STATE.CAN)
	self.node_tree.layout_base_info.txt_buy_cnt.node:setString(string.format(Language.OperateActivity.Score, self.data.buy_cnt))
	self.node_tree.layout_base_info.txt_vip_cond.node:setString(string.format(Language.OperateActivity.VipCond, self.data.vip_lv))
	self.node_tree.layout_base_info.txt_vip_cond.node:setVisible(self.data.vip_lv > 0)
end

function OperateActPrayYBPoolRenderTwo:OnFetchClicked()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2, self.index, 2)
	end
end

function OperateActPrayYBPoolRenderTwo:SetSelecStampVis(vis)
	-- if self.node_tree and self.node_tree.img_selected_stamp.node then
	-- 	self.node_tree.img_selected_stamp.node:setVisible(vis)
	-- end
end

function OperateActPrayYBPoolRenderTwo:OnShowTips()
	if not self.data then return end
	self:OnClick()
	TipsCtrl.Instance:OpenPrayTreeTip(self.data.tips)
end

function OperateActPrayYBPoolRenderTwo:CreateSelectEffect()
	local size = cc.size(80, 80)
	local pos_x, pos_y = self.node_tree.img_icon.node:getPosition() 
	self.select_effect = XUI.CreateImageViewScale9(pos_x, pos_y, size.width, size.height, ResPath.GetCommon("cell_select_bg_2"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end


--天降奇宝奖池Render
OperateActTreasureDropRender = OperateActTreasureDropRender or BaseClass(BaseRender)
function OperateActTreasureDropRender:__init()
	self.start_pos_y = 0
	self.col_idx = 0
	self.row_idx = 1
	self.orig_pos_y = 0
	self.fetch_state = 0
	self:SetContentSize(BaseCell.SIZE, BaseCell.SIZE)
	self.cell = BaseCell.New()
	self.view:addChild(self.cell:GetView())
end

function OperateActTreasureDropRender:__delete()
	self.start_pos_y = 0
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function OperateActTreasureDropRender:OnFlush()
	if not self.data then return end
	self.cell:SetData(self.data.award)
end

function OperateActTreasureDropRender:SetStartPosY(pos_y)
	self.start_pos_y = pos_y
end

function OperateActTreasureDropRender:GetStartPosY()
	return self.start_pos_y
end

function OperateActTreasureDropRender:SetAwardColIndex(col_idx)
	self.col_idx = col_idx
end

function OperateActTreasureDropRender:GetAwardColIndex()
	return self.col_idx
end

function OperateActTreasureDropRender:SetDefaultPosY(pos_y)
	self.orig_pos_y = pos_y
end

function OperateActTreasureDropRender:GetDefaultPosY()
	return self.orig_pos_y
end

function OperateActTreasureDropRender:SetAwardRowIndex(row_idx)
	self.row_idx = row_idx
end

function OperateActTreasureDropRender:GetAwardRowIndex()
	return self.row_idx
end

function OperateActTreasureDropRender:SetFetchState(state)
	self.fetch_state = state
	self.view:setVisible(self.fetch_state == 0)
end

function OperateActTreasureDropRender:GetFetchState()
	return self.fetch_state
end

function OperateActTreasureDropRender:RunDropAction(target_pos)
	self.view:stopAllActions()
	-- print("执行动作")
	local move_to = cc.MoveTo:create(0.075, target_pos)
	self.view:runAction(move_to)
end

function OperateActTreasureDropRender:CreateSelectEffect()
	-- local size = cc.size(80, 80)
	-- local pos_x, pos_y = self.node_tree.img_icon.node:getPosition() 
	-- self.select_effect = XUI.CreateImageViewScale9(pos_x, pos_y, size.width, size.height, ResPath.GetCommon("cell_select_bg_2"), true)
	-- if nil == self.select_effect then
	-- 	ErrorLog("BaseRender:CreateSelectEffect fail")
	-- 	return
	-- end

	-- self.view:addChild(self.select_effect, 999)
end

-- 选择状态改变
function OperateActTreasureDropRender:OnSelectChange(is_select)

end

--秘钥宝藏数字Render
OperateActSecretKeyNumRender = OperateActSecretKeyNumRender or BaseClass(BaseRender)
function OperateActSecretKeyNumRender:__init()
	
end

function OperateActSecretKeyNumRender:__delete()
	
end

function OperateActSecretKeyNumRender:CreateChild()
	BaseRender.CreateChild(self)
	self.num_bar = NumberBar.New()
	local ph = self.ph_list.ph_secret_key_num_bar
	self.num_bar:SetRootPathEx(ResPath.GetFightRoot("g_"))
	self.num_bar:SetGravity(NumberBarGravity.Center)
	self.num_bar:SetPosition(ph.x, ph.y)
	self.num_bar:SetSpace(-4)
	self.view:addChild(self.num_bar:GetView(), 300, 300)
	self.num_bar:SetNumber(self.index)
end

function OperateActSecretKeyNumRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_fetched_stamp.node:setVisible(self.data.state == 1)
	self.num_bar:SetGrey(self.data.state == 0)
end

function OperateActSecretKeyNumRender:CreateSelectEffect()

end


--秘钥宝藏连成线奖励Render
OperateActSecretKeyLineAwardRender = OperateActSecretKeyLineAwardRender or BaseClass(BaseRender)
function OperateActSecretKeyLineAwardRender:__init()
	
end

function OperateActSecretKeyLineAwardRender:__delete()
	
end

function OperateActSecretKeyLineAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	local size = self.view:getContentSize()
	self.cell = BaseCell.New()
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:GetView():setScale(0.7)
	self.cell:SetPosition(size.width / 2, size.height / 2)
	self.view:addChild(self.cell:GetView())

	self.img_fetched_stamp = XUI.CreateImageView(size.width * 0.5, size.height * 0.5, ResPath.GetCommon("stamp_20"), is_plist)
	self.img_fetched_stamp:setScale(0.7)
	self.view:addChild(self.img_fetched_stamp, 1)
	self.img_fetched_stamp:setVisible(false)
	
end

function OperateActSecretKeyLineAwardRender:OnFlush()
	if nil == self.data then return end
	if nil == self.cell:GetData() then
		self.cell:SetData(self.data.award)
	end
	self.img_fetched_stamp:setVisible(self.data.state == 1)
end

function OperateActSecretKeyLineAwardRender:CreateSelectEffect()

end

--秘钥宝藏完成事件信息Render
SecretKeyEvtRender = SecretKeyEvtRender or BaseClass(BaseRender)
function SecretKeyEvtRender:__init()
	
end

function SecretKeyEvtRender:__delete()
	
end

function SecretKeyEvtRender:CreateChild()
	BaseRender.CreateChild(self)
end

function SecretKeyEvtRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.txt_desc.node:setString(self.data.str)
	local state_str = Language.OperateActivity.SecretKeyTreasureState[self.data.state]
	self.node_tree.txt_state.node:setString(state_str)
end

function SecretKeyEvtRender:CreateSelectEffect()

end


-- 秘钥宝藏神秘奖励Render
SecretKeySecretAwardRender = SecretKeySecretAwardRender or BaseClass(BaseRender)
function SecretKeySecretAwardRender:__init()
	self.cells_list = {}
	self.cells_view_container = nil
end

function SecretKeySecretAwardRender:__delete()
	for k, v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
	self.cells_view_container:removeFromParent()
	self.cells_view_container = nil
end

function SecretKeySecretAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateCellsContainer()
end

function SecretKeySecretAwardRender:OnFlush()
	if not self.data then return end
	self:SetAwardCells(self.data.awards)
	self.node_tree.txt_desc.node:setString(self.data.str)
	local state_str = Language.OperateActivity.SecretKeyTreasureState[self.data.state]
	self.node_tree.txt_state.node:setString(state_str)

end

function SecretKeySecretAwardRender:CreateCellsContainer()
	if not self.cells_view_container then
		local ph = self.ph_list.ph_secret_cell_container
		self.cells_view_container = XLayout:create(0, 80)
		self.cells_view_container:setAnchorPoint(0.5, 0)
		self.cells_view_container:setPosition(ph.x, ph.y)
		self.view:addChild(self.cells_view_container, 100)
	end
end

function SecretKeySecretAwardRender:SetAwardCells(awards_data)
	if not awards_data or not next(awards_data) then return end

	local gap = 2
	local award_cnt = #awards_data
	local need_width = (80 * award_cnt) + (award_cnt - 1) * gap
	self.cells_view_container:setContentWH(need_width, 80)
	-- 多余的删除掉
	if #self.cells_list > award_cnt then
		local no_need_cnt = #self.cells_list - award_cnt
		for i = 1, no_need_cnt do
			local cell = table.remove(self.cells_list, #self.cells_list)
			if cell then
				cell:GetView():removeFromParent()
				cell:DeleteMe()
			end
		end
	end

	for i, v in ipairs(awards_data) do
		if not self.cells_list[i] then
			local cell = BaseCell.New()
			cell:SetPosition((i - 1) * (80 + gap), 0)
			cell:SetData(v)
			self.cells_view_container:addChild(cell:GetView(), 100)
			self.cells_list[i] = cell
		else
			local cell = self.cells_list[i]
			cell:GetView():setPositionX((i - 1) * (80 + gap))
			cell:SetData(v)
		end
	end
end

-- 创建选中特效
function SecretKeySecretAwardRender:CreateSelectEffect()
	
end


--拼抢中订单Render
OperActPinDanRender = OperActPinDanRender or BaseClass(BaseRender)
function OperActPinDanRender:__init()
	
end

function OperActPinDanRender:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperActPinDanRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 3 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1) * 68, ph.y)
		equip_cell:SetAnchorPoint(0, 0)
		equip_cell:GetView():setScale(0.8)
		-- equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end

	self.invite_btns = {
							self.node_tree.layout_info_container.layout_joined_info_1.btn_invite_1.node,
							self.node_tree.layout_info_container.layout_joined_info_2.btn_invite_2.node,
							self.node_tree.layout_info_container.layout_joined_info_3.btn_invite_3.node,
						}

	self.join_btns = {
						self.node_tree.layout_info_container.layout_joined_info_1.btn_join_1.node,
						self.node_tree.layout_info_container.layout_joined_info_2.btn_join_2.node,
						self.node_tree.layout_info_container.layout_joined_info_3.btn_join_3.node,
					}

	self.join_names = {
						self.node_tree.layout_info_container.layout_joined_info_1.txt_pd_player_name_1.node,
						self.node_tree.layout_info_container.layout_joined_info_2.txt_pd_player_name_2.node,
						self.node_tree.layout_info_container.layout_joined_info_3.txt_pd_player_name_3.node,
					}
	self.joined_imgs = {
						self.node_tree.layout_info_container.layout_joined_info_1.img_player_1.node,
						self.node_tree.layout_info_container.layout_joined_info_2.img_player_2.node,
						self.node_tree.layout_info_container.layout_joined_info_3.img_player_3.node,
					}
	for i = 1, 3 do
		XUI.AddClickEventListener(self.invite_btns[i], BindTool.Bind(self.OnInviteClick, self), true)
		XUI.AddClickEventListener(self.join_btns[i], BindTool.Bind(self.OnJoinClick, self), true)	
	end

	XUI.AddClickEventListener(self.node_tree.btn_pindan.node, BindTool.Bind(self.OnStartPindanClick, self), true)
	-- self.node_tree.btn_get_consume.node:addClickEventListener(BindTool.Bind(self.OnFetchAwardsClick, self))
end

function OperActPinDanRender:OnFlush()
	if nil == self.data then return end
	local cfg = OperateActivityData.Instance:GetPinDanQiangGouOneGiftCfg(self.data.gift_type)
	if cfg then
		self.cost_price = cfg.price
		for k, v in pairs(self.cell_list) do
			local award = cfg.awards[k]
			v:SetVisible(false)
			if award then
				v:SetData(award)
				v:SetVisible(true)
			end
		end

		self.node_tree.txt_name_1.node:setString(cfg.gift_name)
		-- self.node_tree.layout_price.node:setVisible(self.data.info_list == nil or #self.data.info_list < 1)
		self.node_tree.layout_price.txt_price.node:setString(cfg.price)
		self.node_tree.layout_discount_info.node:setVisible(self.data.info_list ~= nil and #self.data.info_list > 1)
		local discount_str = ""
		local back_money = ""
		if self.data.info_list then
			local num = #self.data.info_list < #cfg.percent_back and #self.data.info_list or #cfg.percent_back
			local discount = cfg.percent_back[num].discount
			back_money = cfg.percent_back[num].disCountNum
			discount_str = string.format(Language.OperateActivity.PinDanDiscount, discount)
			local not_beginner_info = {}
			for k, v in ipairs(self.data.info_list) do
				if v.is_beginner == 0 then
					table.insert(not_beginner_info, v)
				end
			end
			for i = 1, 3 do
				local info = not_beginner_info[i]
				self.join_names[i]:setString(info and info.player_name or "")
				self.invite_btns[i]:setVisible(info == nil and self.data.is_self_in == true)
				self.join_btns[i]:setVisible(info == nil and self.data.is_self_in == false)
				local path = ResPath.GetCommon("bg_104")
				self.joined_imgs[i]:setScale(1)
				if info then
					path = ResPath.GetRoleHead("big_" .. info.prof .. "_" .. info.sex) 
					self.joined_imgs[i]:setScale(0.8)
				end
				self.joined_imgs[i]:loadTexture(path)
			end

		end

		self.node_tree.layout_discount_info.txt_discount.node:setString(discount_str)
		self.node_tree.layout_discount_info.txt_back_money.node:setString(back_money)
		local beginner_str = ""
		if self.data.beginner and self.data.beginner ~= "" then
			beginner_str = string.format(Language.OperateActivity.PinDanBeginner, self.data.beginner)
		end
		self.node_tree.txt_start_player.node:setString(beginner_str)
		self.node_tree.btn_pindan.node:setVisible(self.data.info_list == nil)
		self.node_tree.layout_info_container.node:setVisible(self.data.info_list ~= nil)
	end

end

function OperActPinDanRender:OnInviteClick()
	-- print("invite====")
	if not self.data or not self.data.info_list then return end
	local friend_list = TableCopy(SocietyData.Instance:GetFriendList())
	if not next(friend_list) then 
		SysMsgCtrl.Instance:ErrorRemind(Language.OperateActivity.PinDanNoFriend, force)
		return
	end
	for k, v in ipairs(friend_list) do
		v.is_in = false
		v.dindan_id = self.data.dindan_id
		for _, v_2 in ipairs(self.data.info_list) do
			if v.role_id == v_2.role_id then
				v.is_in = true
				break
			end
		end
	end
	ViewManager.Instance:Open(ViewName.FriendPinDan)
	ViewManager.Instance:FlushView(ViewName.FriendPinDan, 0, nil, {data = friend_list})
end

function OperActPinDanRender:OnJoinClick()
	-- print("join====")
	if not self.data or self.data.dindan_id < 0 or self.cost_price == nil then return end
	OperateActivityCtrl.Instance:OpenConfirmJoinAlert(3, self.data.dindan_id, self.cost_price, self.data.gift_type)
end

function OperActPinDanRender:CreateSelectEffect()

end

function OperActPinDanRender:OnStartPindanClick()
	if not self.data or self.cost_price == nil then return end
	OperateActivityCtrl.Instance:OpenConfirmJoinAlert(1, self.data.dindan_id, self.cost_price, self.data.gift_type)
end


--我的拼抢订单Render
OperActMyPinDanRender = OperActMyPinDanRender or BaseClass(BaseRender)
function OperActMyPinDanRender:__init()
	
end

function OperActMyPinDanRender:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperActMyPinDanRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 3 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1) * 68, ph.y)
		equip_cell:SetAnchorPoint(0, 0)
		equip_cell:GetView():setScale(0.8)
		-- equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.join_names = {
						self.node_tree.layout_info_container.layout_joined_info_1.txt_pd_player_name_1.node,
						self.node_tree.layout_info_container.layout_joined_info_2.txt_pd_player_name_2.node,
						self.node_tree.layout_info_container.layout_joined_info_3.txt_pd_player_name_3.node,
					}

	self.joined_imgs = {
						self.node_tree.layout_info_container.layout_joined_info_1.img_player_1.node,
						self.node_tree.layout_info_container.layout_joined_info_2.img_player_2.node,
						self.node_tree.layout_info_container.layout_joined_info_3.img_player_3.node,
					}
end

function OperActMyPinDanRender:OnFlush()
	if nil == self.data then return end
	local cfg = OperateActivityData.Instance:GetPinDanQiangGouOneGiftCfg(self.data.gift_type)
	if cfg then
		for k, v in pairs(self.cell_list) do
			local award = cfg.awards[k]
			v:SetVisible(false)
			if award then
				v:SetData(award)
				v:SetVisible(true)
			end
		end
		self.node_tree.txt_name_1.node:setString(cfg.gift_name)
		local discount_str = ""
		local back_money = ""
		if self.data.info_list then
			local num = #self.data.info_list < #cfg.percent_back and #self.data.info_list or #cfg.percent_back
			local discount = cfg.percent_back[num].discount
			back_money = cfg.percent_back[num].disCountNum
			discount_str = string.format(Language.OperateActivity.PinDanDiscount, discount)
			local not_beginner_info = {}
			for k, v in ipairs(self.data.info_list) do
				if v.is_beginner == 0 then
					table.insert(not_beginner_info, v)
				end
			end
			for i = 1, 3 do
				local info = not_beginner_info[i]
				self.join_names[i]:setString(info and info.player_name or "")
				local path = ResPath.GetCommon("bg_104")
				self.joined_imgs[i]:setScale(1)
				if info then
					path = ResPath.GetRoleHead("big_" .. info.prof .. "_" .. info.sex) 
					self.joined_imgs[i]:setScale(0.8)
				end
				self.joined_imgs[i]:loadTexture(path)
			end

		end
		self.node_tree.layout_discount_info.txt_discount.node:setString(discount_str)
		self.node_tree.layout_discount_info.txt_back_money.node:setString(back_money)
		local beginner_str = ""
		if self.data.beginner and self.data.beginner ~= "" then
			beginner_str = string.format(Language.OperateActivity.PinDanBeginner, self.data.beginner)
		end
		self.node_tree.txt_start_player.node:setString(beginner_str)
	end
	
end

function OperActMyPinDanRender:CreateSelectEffect()

end

function OperActMyPinDanRender:OnFetchAwardsClick()
	-- local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.DAILY_SPEND)
	-- if cmd_id then
	-- 	OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.DAILY_SPEND, self.index)
	-- end
end

----------------------------------------------------
-- FriendPinDanRender
----------------------------------------------------
FriendPinDanRender = FriendPinDanRender or BaseClass(BaseRender)
function FriendPinDanRender:__init()
end

function FriendPinDanRender:__delete()	
	
end

function FriendPinDanRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_invite.node, BindTool.Bind(self.OnInviteClick, self), true)
end

function FriendPinDanRender:OnFlush()
	if not self.data then return end
	-- self.node_tree.txt_pindan_friend_name.node:setString(self.data.name)
	self.node_tree.btn_invite.node:setVisible(self.data.is_in == false)
	local state_str = self.data.is_in and Language.OperateActivity.PinDanJoined or ""
	self.node_tree.txt_pindan_state.node:setString(state_str)
	self.node_tree.txt_pindan_friend_name.node:setString(self.data.name)
	
end

function FriendPinDanRender:OnInviteClick()
	if not self.data then return end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU, gift_type, 2,
		 oper_time, self.data.dindan_id, self.data.role_id, join_type)
	end
end

function FriendPinDanRender:CreateSelectEffect()
	-- if nil == self.node_tree.btn_img then
	-- 	self.cache_select = true
	-- 	return
	-- end
	-- local size =self.node_tree.btn_img.node:getContentSize()
	-- self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("btn_106_select"), true, cc.rect(69,24,86,16))
	-- if nil == self.select_effect then
	-- 	ErrorLog("BaseRender:CreateSelectEffect fail")
	-- 	return
	-- end
	-- self.node_tree.btn_img.node:addChild(self.select_effect, 99)
end

------连续登录奖励cell------
ContinuousLoginAwarCell = ContinuousLoginAwarCell or BaseClass(BaseCell)
function ContinuousLoginAwarCell:OnFlush()
	if nil == self.data then return end
	BaseCell.OnFlush(self)
	self:SetQualityEffect(self.data.sp_effect_id or 0)
end

function ContinuousLoginAwarCell:CreateSelectEffect()

end

------充值/消费送礼奖励Render------
OperateGiveGiftAwarRender = OperateGiveGiftAwarRender or BaseClass(BaseCell)
-- function OperateGiveGiftAwarRender:__init()

-- end

-- function OperateGiveGiftAwarRender:__delete()	
-- 	if self.cell then

-- 	end
-- end

-- function OperateGiveGiftAwarRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	self.cell_list = {}
-- 	for i = 1, 2 do
-- 		local ph = self.ph_list["ph_cell_" .. i]
-- 		local cell = BaseCell.New()
-- 		cell:SetPosition(ph.x, ph.y)
-- 		self.view:addChild(cell:GetView(), 100)
-- 		table.insert(self.cell_list, cell)
-- 	end
-- end

-- function OperateGiveGiftAwarRender:OnFlush()
-- 	if nil == self.data then return end
	-- self.node_tree.text_ingot.node:setString(self.data.ingot)
	-- self.node_tree.img_box.node:loadTexture(ResPath.GetLimitedActivity("box_" .. self.data.idx))
	-- self.node_tree.btn_buy.node:setTitleText("￥ " .. self.data.money)
	-- for i = 1, 2 do
	-- 	self.cell_list[i]:SetData(self.data.awards[i]) 
	-- end
-- end

-- function OperateGiveGiftAwarRender:OnBuyClick()
-- 	local role_id = GameVoManager.Instance:GetUserVo():GetNowRole()
-- 	local role_name = GameVoManager.Instance:GetMainRoleVo().name
-- 	local server_id = GameVoManager.Instance:GetUserVo().real_server_id		--登陆的服ID
-- 	local amount = self.data.money
-- 	if amount and amount > 0 and role_id and role_name and server_id then
-- 		AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)
-- 		Log("Recharge:", role_name, role_id, server_id, amount)
-- 	else
-- 		SysMsgCtrl.Instance:ErrorRemind("充值失败!!!", force)
-- 	end
-- end

function OperateGiveGiftAwarRender:CreateSelectEffect()

end

-- 充值/消费送礼奖励状态Render
OperateGiveGiftFetchStateRender = OperateGiveGiftFetchStateRender or BaseClass(BaseRender)
function OperateGiveGiftFetchStateRender:__init()

end

function OperateGiveGiftFetchStateRender:__delete()	
	
end

function OperateGiveGiftFetchStateRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.txt_day_num.node:setString(string.format(Language.Common.DayText, self.index))
end

function OperateGiveGiftFetchStateRender:OnFlush()
	if nil == self.data then return end
	local opened_day = OperateActivityData.Instance:GetChargeGiveOpenInfo().opened_day
	self.node_tree.img_box.node:setGrey(self.index > opened_day)
	self.node_tree.img_stamp.node:setVisible(self.data.state == 2)
end

-- function OperateGiveGiftFetchStateRender:CreateSelectEffect()

-- end


-- 奖励兑换Render
OperateActConvertAwarItem = OperateActConvertAwarItem or BaseClass(BaseRender)
function OperateActConvertAwarItem:__init()

end

function OperateActConvertAwarItem:__delete()	
	if self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end

	if self.convert_items_list then
		self.convert_items_list:DeleteMe()
		self.convert_items_list = nil
	end
end

function OperateActConvertAwarItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_convert.node, BindTool.Bind(self.OnConvertClick, self))
	self.node_tree.layout_need_money.img_money.node:setScale(0.7)
	self.interval = 1
	local ph = self.ph_list.ph_award_list_1
	local item_ui_cfg = self.ph_list.ph_money_cell
	self.award_list = ListView.New()
	self.award_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, item_ui_cfg)
	self.award_list:SetItemsInterval(self.interval)
	self.view:addChild(self.award_list:GetView(), 99)
	self.origin_posx = self.node_tree.layout_need_money.node:getPositionX()
	ph = self.ph_list.ph_convert_items_list
	self.convert_list_start_posx = ph.x - ph.w / 2
	self.convert_items_list = ListView.New()
	self.convert_items_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, item_ui_cfg)
	self.convert_items_list:SetItemsInterval(self.interval)
	self.view:addChild(self.convert_items_list:GetView(), 99)

end

function OperateActConvertAwarItem:OnFlush()
	if nil == self.data then return end
	self.convert_items_list:SetData(self.data.convert_item)
	self.award_list:SetData(self.data.awards_t)
	for k, v in pairs (self.convert_items_list:GetAllItems()) do
		v:GetView():setScale(0.8)
	end
	local list_w = self.ph_list.ph_convert_items_list.w
	local item_w = #self.data.convert_item * 80 + (#self.data.convert_item - 1) * self.interval
	local offset_x = math.min(list_w, item_w) + 10
	self.node_tree.layout_need_money.node:setPositionX(self.origin_posx + offset_x)
	self.node_tree.layout_need_money.node:setVisible(next(self.data.convert_money) ~= nil)
	if next(self.data.convert_money) then
		self.node_tree.layout_need_money.img_money.node:loadTexture(ResPath.GetItem(self.data.convert_money[1].icon_id))
		self.node_tree.layout_need_money.txt_need_money.node:setString(self.data.convert_money[1].count)
	end
	local txt = self.data.rest_cnt > 0 and string.format(Language.Common.RestCount, self.data.rest_cnt) or ""
	self.node_tree.txt_rest_cnt.node:setString(txt)
	self.node_tree.btn_convert.node:setEnabled(self.data.can_convert)
end

function OperateActConvertAwarItem:OnConvertClick()
	if not self.data then return end
	local act_id = OPERATE_ACTIVITY_ID.CONVERT_AWARD
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.idx)
	end
end

function OperateActConvertAwarItem:CreateSelectEffect()

end

----------------------------------------------------
-- SpringFestivalLoginAwardRender
----------------------------------------------------
SpringFestivalLoginAwardRender = SpringFestivalLoginAwardRender or BaseClass(BaseRender)
function SpringFestivalLoginAwardRender:__init()
	self.is_select = false
end

function SpringFestivalLoginAwardRender:__delete()
	self.reward_item = nil
end

function SpringFestivalLoginAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.select_effect = self.node_tree.img_select.node
	self.select_effect:setVisible(false)
	self.node_tree.img_reward_name.node:setScale(0.7)
	self.node_tree.img_reward_name.node:setVisible(false)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.img_stamp.node:setLocalZOrder(11)
	self.node_tree.img_stamp_2.node:setVisible(false)
	self.node_tree.img_stamp_2.node:setLocalZOrder(11)
	-- self:AddClickEventListener(self.click_callback)
end

function SpringFestivalLoginAwardRender:SetSelectVisible(is_select)
	-- if self.node_tree.img_select then
	-- 	self.node_tree.img_select.node:setVisible(is_select)
	-- end
	-- self.is_select = is_select
end

function SpringFestivalLoginAwardRender:CreateSelectEffect()
end

function SpringFestivalLoginAwardRender:OnFlush()
	if not self.data then return end
	local index = self.index
	if nil == self.reward_item then
		local x, y = self.node_tree.award_bg.node:getPosition()
		self.reward_item = XUI.CreateImageView(x, y, ResPath.GetItem(self.data.icon), true)
		-- self.reward_item:setScale(0.5)
		self.view:addChild(self.reward_item, 10)
	end

	self.node_tree.img_day.node:loadTexture(ResPath.GetWelfare("day_" .. self.data.day))
	self.node_tree.img_stamp.node:setVisible(self.data.state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED)
	-- self.node_tree.img_stamp_2.node:setVisible(self.data.state ~= SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED and self.data.need_makeup)
	-- self.node_tree.img_reward_name.node:loadTexture(ResPath.GetWelfare("word_reward_" .. index))
	-- self.node_tree.img_select.node:setVisible(self.is_select)
end

function SpringFestivalLoginAwardRender:SetRewardState(state)
	-- self.node_tree.img_stamp.node:setVisible(state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED)
end

-- ProsperyRedEnveInfoItem 开服达标奖励item
ProsperyRedEnveInfoItem = ProsperyRedEnveInfoItem or BaseClass(BaseRender)
function ProsperyRedEnveInfoItem:__init()

end

function ProsperyRedEnveInfoItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function ProsperyRedEnveInfoItem:CreateChild()
	BaseRender.CreateChild(self)
	self.interval = 4
	local ph = self.ph_list.ph_cells_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, BaseCell, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 99)
	-- self.cells_list:GetView():setTouchEnabled(false)
end

function ProsperyRedEnveInfoItem:OnFlush()
	if not self.data then return end
	self.node_tree.txt_name_1.node:setString(self.data.desc)
	self.cells_list:SetData(self.data.awards)
end

-- function ProsperyRedEnveInfoItem:SetCellsListData(data)
-- 	if data == nil then return end
-- 	self.cells_list:SetData(data)
-- 	for _, v in pairs(self.cells_list:GetAllItems()) do
-- 		v:GetView():setScale(0.8)
-- 	end
-- 	local ph = self.ph_list.ph_cells_list
-- 	local len = #data
-- 	if len < 3 then
-- 		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
-- 		self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
-- 	else
-- 		self.cells_list:GetView():setPosition(ph.x, ph.y)
-- 	end	
-- end

-- 创建选中特效
function ProsperyRedEnveInfoItem:CreateSelectEffect()
	
end

-- 怪物来袭Item
OperateBossAtkItem = OperateBossAtkItem or BaseClass(BaseRender)
function OperateBossAtkItem:__init()

end

function OperateBossAtkItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function OperateBossAtkItem:CreateChild()
	BaseRender.CreateChild(self)
	self.interval = 4
	local ph = self.ph_list.ph_awar_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 99)
	-- self.cells_list:GetView():setTouchEnabled(false)
end

function OperateBossAtkItem:OnFlush()
	if not self.data then return end
	self.node_tree.txt_name.node:setString(self.data.name)
	local time_str = OperateActivityData.Instance:GetBossAtkIncomeRefreshTime(self.data.mob_time_list)
	self.node_tree.txt_time_cd.node:setString(time_str)
	self.cells_list:SetData(self.data.awards)
end

-- function OperateBossAtkItem:SetCellsListData(data)
-- 	if data == nil then return end
-- 	self.cells_list:SetData(data)
-- 	for _, v in pairs(self.cells_list:GetAllItems()) do
-- 		v:GetView():setScale(0.8)
-- 	end
-- 	local ph = self.ph_list.ph_cells_list
-- 	local len = #data
-- 	if len < 3 then
-- 		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
-- 		self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
-- 	else
-- 		self.cells_list:GetView():setPosition(ph.x, ph.y)
-- 	end	
-- end

-- 创建选中特效
function OperateBossAtkItem:CreateSelectEffect()
	
end


-- 守卫主城Item
OperateDefendCityItem = OperateDefendCityItem or BaseClass(BaseRender)
function OperateDefendCityItem:__init()

end

function OperateDefendCityItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function OperateDefendCityItem:CreateChild()
	BaseRender.CreateChild(self)
	self.interval = 4
	local ph = self.ph_list.ph_awar_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 99)
	-- self.cells_list:GetView():setTouchEnabled(false)
end

function OperateDefendCityItem:OnFlush()
	if not self.data then return end
	self.node_tree.txt_name.node:setString(self.data.name)
	self.node_tree.boss_icon.node:loadTexture(ResPath.GetBossHead("boss_icon_"..self.data.icon))
	local time_str = OperateActivityData.Instance:GetDefendCityRefreshTime(self.data.mob_time_list)
	self.node_tree.txt_time_cd.node:setString(time_str)
	self.cells_list:SetData(self.data.awards)
end

-- function OperateDefendCityItem:SetCellsListData(data)
-- 	if data == nil then return end
-- 	self.cells_list:SetData(data)
-- 	for _, v in pairs(self.cells_list:GetAllItems()) do
-- 		v:GetView():setScale(0.8)
-- 	end
-- 	local ph = self.ph_list.ph_cells_list
-- 	local len = #data
-- 	if len < 3 then
-- 		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
-- 		self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
-- 	else
-- 		self.cells_list:GetView():setPosition(ph.x, ph.y)
-- 	end	
-- end

-- 创建选中特效
function OperateDefendCityItem:CreateSelectEffect()
	
end


OperSecretRender = OperSecretRender or BaseClass(BaseRender)
function OperSecretRender:__init()
	self.cell = nil
	self.alert_view = nil 
end

function OperSecretRender:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	
end

function OperSecretRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 100)
	end
	self.node_tree.img_buy_bg.node:setVisible(false)
	self.node_tree.img_buy_bg.node:setLocalZOrder(999)
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind1(self.BuyShopItem, self), true)
end

function OperSecretRender:OnFlush()
	if self.data == nil then return end
	if self.data.cfg_data == nil then return end
	local data = {item_id = self.data.cfg_data.id, num = self.data.cfg_data.count, is_bind = self.data.cfg_data.bind}
	self.cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.cfg_data.id)
	if item_cfg == nil then
		return 
	end
	self.node_tree.lbl_item_name.node:setString(item_cfg.name)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))

	local price_str = RoleData.Instance:ToStringByNumber(self.data.cfg_data.price)
	local disprice_str = RoleData.Instance:ToStringByNumber(self.data.cfg_data.discprice)
	self.node_tree.lbl_item_cost.node:setString(price_str)
	self.node_tree.lbl_now_item_cost.node:setString(disprice_str)
	self.node_tree.txt_rest_buy_time.node:setString(string.format(Language.Common.RestCount,self.data.cfg_data.buyNumLimit - self.data.buy_num))
	local path = nil 
	if self.data.cfg_data.discpriceType == 0 then
		path = ResPath.GetCommon("icon_money")
	elseif self.data.cfg_data.discpriceType == 2 then
		path = ResPath.GetCommon("bind_gold")
	elseif self.data.cfg_data.discpriceType == 3 then
		path = ResPath.GetCommon("gold")
	end
	self.node_tree.img_cost_now.node:loadTexture(path)
	local path_1 = nil
	if self.data.cfg_data.priceType == 0 then
		path_1 = ResPath.GetCommon("icon_money")
	elseif self.data.cfg_data.priceType == 2 then
		path_1 = ResPath.GetCommon("bind_gold")
	elseif self.data.cfg_data.priceType == 3 then
		path_1 = ResPath.GetCommon("gold")
	end
	self.node_tree.img_cost.node:loadTexture(path_1)
	local vis = self.data.buy_num >= (self.data.cfg_data.buyNumLimit or 1)
	self.node_tree.buyBtn.node:setGrey(self.data.buy_num >= (self.data.cfg_data.buyNumLimit or 1))
	self.node_tree.img_buy_bg.node:setVisible(vis)
	
end

function OperSecretRender:BuyShopItem()
	if not self.data then return end
	if self.data.buy_num < (self.data.cfg_data.buyNumLimit or 1) then
		if self.data.cfg_data == nil then return end
		local alert_view = OperateActivityData.Instance:GetAlertWnd()
		if not alert_view:GetIsNolongerTips() then
			alert_view:SetOkFunc(function ()
				local act_id = OPERATE_ACTIVITY_ID.SECRET_SHOP
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.index, 1, oper_time, dindan_id, role_id, join_type)
				end
		  	end)
			local item_cfg = ItemData.Instance:GetItemConfig(self.data.cfg_data.id)
			local money_name = ShopData.GetMoneyTypeName(self.data.cfg_data.discpriceType)--Language.CombineServerActivity.Money_Name[self.data.cfg_data.discpriceType]
			local txt = string.format(Language.CombineServerActivity.ShenMi_Shop, money_name, self.data.cfg_data.discprice, string.format("%06x", item_cfg.color), item_cfg.name, self.data.cfg_data.count)
			alert_view:SetLableString(txt)
		  	alert_view:Open()
	  	else
	  		local act_id = OPERATE_ACTIVITY_ID.SECRET_SHOP
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.index, 1, oper_time, dindan_id, role_id, join_type)
			end
	  	end
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombineServerActivity.Had_Buy)
	end
end


OperateActWorldCupBossRender = OperateActWorldCupBossRender or BaseClass(BaseRender)
function OperateActWorldCupBossRender:__init()
	self.cell = nil
	self.alert_view = nil 
end

function OperateActWorldCupBossRender:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
end

function OperateActWorldCupBossRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		-- self.cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 100)
	end
	XUI.SetTextVAlienment(self.node_tree.lbl_item_name.node, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	XUI.SetTextVAlienment(self.node_tree.txt_rest_buy_time.node, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	XUI.SetTextVAlienment(self.node_tree.txt_cost.node, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind(self.BuyShopItem, self), true)
end

function OperateActWorldCupBossRender:OnFlush()
	if self.data == nil then return end
	self.cell:SetData(self.data.award)
	self.node_tree.txt_rest_buy_time.node:setString(string.format(Language.Common.RestCount,self.data.rest_cnt))
	self.node_tree.txt_cost.node:setString(self.data.consume.count)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.award.item_id)
	if item_cfg == nil then
		return 
	end
	self.node_tree.lbl_item_name.node:setString(item_cfg.name)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	
end

function OperateActWorldCupBossRender:BuyShopItem()
	if not self.data then return end
	if self.alert_view == nil then
		self.alert_view = Alert.New()
	end
	self.alert_view:SetOkFunc(function ()
		local act_id = OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.idx, 1, oper_time, dindan_id, role_id, join_type)
		end
  	end)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.award.item_id)
	local money_name = ShopData.GetMoneyTypeName(3)
	local txt = string.format(Language.OperateActivity.CostAlertContent, self.data.consume.count, money_name, string.format("%06x", item_cfg.color), item_cfg.name, self.data.award.num)
	self.alert_view:SetLableString(txt)
  	self.alert_view:Open()
end

-- 创建选中特效
function OperateActWorldCupBossRender:CreateSelectEffect()
	
end

---------------------新重复充值-----------------------
OperateActNewRepeatChargeRender = OperateActNewRepeatChargeRender or BaseClass(BaseRender)
function OperateActNewRepeatChargeRender:__init()
	
end

function OperateActNewRepeatChargeRender:__delete()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function OperateActNewRepeatChargeRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	self.item_cells = {}
	for i = 1, 2 do
		local item_cell = BaseCell.New()
		item_cell:GetView():setAnchorPoint(0,0)
		item_cell:SetPosition(self.ph_list["ph_cell_" .. i].x, self.ph_list["ph_cell_" .. i].y)
		self.view:addChild(item_cell:GetView(), 100)
		table.insert(self.item_cells, item_cell)
	end
	
	XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
	
end

function OperateActNewRepeatChargeRender:OnFlush()
	if nil == self.data then
		return
	end
	for i=1,2 do
		self.item_cells[i]:SetData(self.data.awards_t[i])
	end
	-- self.node_tree.text_ingot.node:setString("")
	local data = OperateActivityData.Instance:GetNewRepeatChargeData()
	self.node_tree.btn_buy.node:setEnabled(data.used_cnt < data.own_cnt)

end

function OperateActNewRepeatChargeRender:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img9_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	self.select_effect:setScale(1.1)
	self.select_effect:setScaleX(1.05)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
end

function OperateActNewRepeatChargeRender:OnClickBuyBtn()
	if not self.data then return end
	local act_id = OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.idx, oper_type)
	end
end

-- function OperateActNewRepeatChargeRender:OnClick()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end


------消费积分兑换返利券ItemRender------------
SpendScoreExchaPaybackItemRender = SpendScoreExchaPaybackItemRender or BaseClass(BaseRender)
function SpendScoreExchaPaybackItemRender:__init()
	self.item_cell = nil
end

function SpendScoreExchaPaybackItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SpendScoreExchaPaybackItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
	
	-- local act_eff = RenderUnit.CreateEffect(920, self.view, 200, nil, nil, self.ph_list.ph_item_cell.x + self.ph_list.ph_item_cell.w / 2 , self.ph_list.ph_item_cell.y + self.ph_list.ph_item_cell.h / 2)
	
end

function SpendScoreExchaPaybackItemRender:OnFlush()
	if nil == self.data then
		return
	end
	self.node_tree.lbl_item_name.node:setString(self.data.titleTxt)
	self.node_tree.txt_cost_price.node:setString(self.data.needScore)

	local rest_buy = ""
	rest_buy = string.format(Language.Common.RestCount, self.data.restNum)
	self.node_tree.txt_rest_num.node:setString(rest_buy)
	self.node_tree.buyBtn.node:setEnabled(self.data.restNum > 0)
end

function SpendScoreExchaPaybackItemRender:OnClickBuyBtn()
	if not self.data then return end
	local alert_view = OperateActivityData.Instance:GetAlertWndTwo()
	alert_view:SetOkFunc(function ()
		local act_id = OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.awardId, 1, oper_time, dindan_id, role_id, join_type)
		end
  	end)
	-- local item_cfg = ItemData.Instance:GetItemConfig(self.data.cfg_data.id)
	-- local money_name = ShopData.GetMoneyTypeName(self.data.cfg_data.discpriceType)--Language.CombineServerActivity.Money_Name[self.data.cfg_data.discpriceType]
	local txt = string.format(Language.OperateActivity.SpendscoreExchangePaybackTxts[2], self.data.needScore, self.data.titleTxt)
	alert_view:SetLableString(txt)
  	alert_view:Open()
end

function SpendScoreExchaPaybackItemRender:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img9_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	self.select_effect:setScale(1.1)
	self.select_effect:setScaleX(1.05)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
end

----------------------------------------------------
-- SpendscoreExchCheckRender
----------------------------------------------------
SpendscoreExchCheckRender = SpendscoreExchCheckRender or BaseClass(BaseRender)
function SpendscoreExchCheckRender:__init()
end

function SpendscoreExchCheckRender:__delete()	
	
end

function SpendscoreExchCheckRender:CreateChild()
	BaseRender.CreateChild(self)
	
end

function SpendscoreExchCheckRender:OnFlush()
	if not self.data then return end
	self.node_tree.txt_name.node:setString(self.data.titleTxt)
	self.node_tree.txt_num.node:setString(self.data.restNum)
	
end

function SpendscoreExchCheckRender:CreateSelectEffect()
	-- if nil == self.node_tree.btn_img then
	-- 	self.cache_select = true
	-- 	return
	-- end
	-- local size =self.node_tree.btn_img.node:getContentSize()
	-- self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("btn_106_select"), true, cc.rect(69,24,86,16))
	-- if nil == self.select_effect then
	-- 	ErrorLog("BaseRender:CreateSelectEffect fail")
	-- 	return
	-- end
	-- self.node_tree.btn_img.node:addChild(self.select_effect, 99)
end

-- 连续累充充值奖励Render
NewContiAddupChargeItem = NewContiAddupChargeItem or BaseClass(BaseRender)
function NewContiAddupChargeItem:__init()

end

function NewContiAddupChargeItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function NewContiAddupChargeItem:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	self.interval = 2
	local ph = self.ph_list.ph_cells_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, OperateGiveGiftAwarRender, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 99)
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
	self.node_tree.btn_get_reward.node:setLocalZOrder(1000)
end

function NewContiAddupChargeItem:OnFlush()
	if nil == self.data then return end
	self.node_tree.btn_get_reward.node:setVisible(self.data.state == DAILY_CHARGE_FETCH_ST.CAN)
	self.node_tree.Image_dabiao.node:setVisible(self.data.state ~= DAILY_CHARGE_FETCH_ST.CAN)
	local all_data = OperateActivityData.Instance:GetNewContinousAddupChargeData()
	local data = OperateActivityData.Instance:GetNewContinousAddupChargeAwards(self.data.plan)
	local money = all_data and all_data.money or 0
	local day_num = data and data.day
	local str = ""
	local path = ResPath.GetCommon("stamp_3")
	if self.data.state ~= DAILY_CHARGE_FETCH_ST.CNNOT then
		path = ResPath.GetCommon("stamp_9")
	elseif day_num and day_num == self.data.idx and money < data.gold then
		str = string.format(Language.OperateActivity.ContiAddupChargeTxts[2], data.gold-money)
	end
	self.node_tree.txt_need_name1.node:setString(str)	
	self.node_tree.Image_dabiao.node:loadTexture(path)
	RichTextUtil.ParseRichText(self.node_tree.txt_item_name.node, string.format(Language.OperateActivity.NewContiAddupChargeTxts[2], self.data.idx, data.gold))
	self.cells_list:SetData(self.data.awards)
	-- self:SetCellsListData(self.data.awards)

end

function NewContiAddupChargeItem:CreateSelectEffect()

end

function NewContiAddupChargeItem:SetCellsListData(data)
	if data == nil then return end
	self.cells_list:SetData(data)
	local ph = self.ph_list.ph_cells_list
	local len = #data
	if len < 3 then
		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
		self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.cells_list:GetView():setPosition(ph.x, ph.y)
	end	
end

function NewContiAddupChargeItem:GetReward()
	if not self.data then return end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW, self.data.idx, self.data.plan)
	end
end


----------------------------------------------------
-- NationalDayLoginAwardRender
----------------------------------------------------
NationalDayLoginAwardRender = NationalDayLoginAwardRender or BaseClass(BaseRender)
function NationalDayLoginAwardRender:__init()
	-- self.ignore_data_to_select = true
	self:AddClickEventListener()
end

function NationalDayLoginAwardRender:__delete()
	self.reward_item = nil
end

function NationalDayLoginAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_select.node:setVisible(false)
	self.node_tree.img_reward_name.node:setScale(0.7)
	self.node_tree.img_reward_name.node:setVisible(false)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.img_stamp.node:setLocalZOrder(11)
	self.node_tree.img_remind_flag.node:setVisible(false)
	-- self:AddClickEventListener(self.click_callback)
end

-- -- 是否可选中
-- function NationalDayLoginAwardRender:CanSelect()
-- 	return true
-- end

function NationalDayLoginAwardRender:SetSelectVisible(is_select)
	-- if self.node_tree.img_select then
	-- 	self.node_tree.img_select.node:setVisible(is_select)
	-- end
	-- self.is_select = is_select
end

function NationalDayLoginAwardRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

function NationalDayLoginAwardRender:OnFlush()
	if not self.data then return end
	self.node_tree.img_remind_flag.node:setVisible(OperateActivityData.Instance:GetLoginSendGiftOneDayIsRemind(self.data.day))
	local index = self.index
	if nil == self.reward_item then
		local x, y = self.node_tree.award_bg.node:getPosition()
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.show_id)
		local icon = item_cfg and item_cfg.icon or 0
		self.reward_item = XUI.CreateImageView(x, y, ResPath.GetItem(icon), true)
		-- self.reward_item:setScale(0.5)
		self.view:addChild(self.reward_item, 10)
	end

	self.node_tree.img_day.node:loadTexture(ResPath.GetWelfare("day_" .. self.data.day))
	self.node_tree.img_stamp.node:setVisible(self.data.state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED)
	-- self.node_tree.img_reward_name.node:loadTexture(ResPath.GetWelfare("word_reward_" .. index))
	-- self.node_tree.img_select.node:setVisible(self.is_select)
end

function NationalDayLoginAwardRender:SetRewardState(state)
	-- self.node_tree.img_stamp.node:setVisible(state == SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED)
end


--NatiDayOnlineAwardRender
NatiDayOnlineAwardRender = NatiDayOnlineAwardRender or BaseClass(BaseRender)
function NatiDayOnlineAwardRender:__init()

end

function NatiDayOnlineAwardRender:__delete()
	if self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar = nil
	end

	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function NatiDayOnlineAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cells_list
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, BaseCell, nil, nil, self.ph_list.ph_cell)
	self.cells_list:SetMargin(2)
	self.view:addChild(self.cells_list:GetView(), 100)
	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(self.node_tree.prog9_count_down.node)
	self.progressbar:SetTotalTime(0)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchAward, self), true)
end

function NatiDayOnlineAwardRender:OnFlush()
	if not self.data then return end
	local btn_txt = Language.OperateActivity.FetchStateTexts[1]
	if self.data.state == DAILY_CHARGE_FETCH_ST.FETCHED then
		btn_txt = Language.OperateActivity.FetchStateTexts[2]
	end
	self.node_tree.btn_fetch.node:setTitleText(btn_txt)
	self.cells_list:SetData(self.data.awards)
	if self.data.day == OperateActivityData.Instance:GetLoginSendGiftCurDay() then
		local rest_time = (self.data.rest_time > 0 and self.data.state == DAILY_CHARGE_FETCH_ST.CNNOT) and TimeUtil.FormatSecond(self.data.rest_time, 3) or ""
		local onlin_time = OperateActivityData.Instance:GetOnlineTime()
		local prog_percent = onlin_time / self.data.online * 100
		self.progressbar:SetPercent(prog_percent)
		self.node_tree.lbl_get_state.node:setString(rest_time)					--  ~= "" and rest_time or Language.Welfare.FetchStateTexts[state]
		self.node_tree.btn_fetch.node:setEnabled(self.data.state == DAILY_CHARGE_FETCH_ST.CAN)
	else
		local cur_data = OperateActivityData.Instance:GetLoginSendGiftDataByDay(self.data.day)
		if cur_data then
			if cur_data.online_time == -2 then
				self.node_tree.btn_fetch.node:setEnabled(false)
			else
				self.node_tree.btn_fetch.node:setEnabled(self.data.state ~= DAILY_CHARGE_FETCH_ST.FETCHED)
			end
		end
		self.node_tree.lbl_get_state.node:setString("")
		self.progressbar:SetPercent(100)
	end
end

--领取在线奖励
function NatiDayOnlineAwardRender:OnFetchAward()
	if not self.data then return end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT)
	local cur_data = OperateActivityData.Instance:GetLoginSendGiftDataByDay(self.data.day)
	if cmd_id and cur_data then
		local oper_type = cur_data.online_time == -1 and 2 or 1
		if oper_type == 2 then
			local box = Alert.New(string.format(Language.OperateActivity.LoginSendGift[1], self.data.cost_money))
			local function ok_callback()
				--发送购买协议
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT, self.data.idx, oper_type, self.data.day, dindan_id, role_id, join_type)
				box:DeleteMe()
				box = nil
			end
			local function cancel_callback()
				box:DeleteMe()
				box = nil
			end	
			box.zorder = COMMON_CONSTS.ZORDER_MAX
			-- box:SetOkString(Language.Common.HappyBuy)
			-- box:SetCancelString(Language.Common.NotHappyBuy)
			box:SetOkFunc(ok_callback)
			box:SetCancelFunc(cancel_callback)
			box:Open()
			-- box:NoCloseButton()
		else
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT, self.data.idx, oper_type, self.data.day, dindan_id, role_id, join_type)
		end
	end
	-- WelfareCtrl.Instance:OnlineRewardInfoReq(ONLINE_AWARD_REQ_TYPE.FETCH_AWARD, self.data.idx)
end

function NatiDayOnlineAwardRender:SetGrey(bool)
	-- self.node_tree.img_get_box.node:setGrey(bool)
	-- self.node_tree.img_frame.node:setGrey(bool)
end

function NatiDayOnlineAwardRender:CreateSelectEffect()

end


OperBossTreasureRender = OperBossTreasureRender or BaseClass(BaseRender)
function OperBossTreasureRender:__init()
	self.cell = nil
	self.alert_view = nil 
end

function OperBossTreasureRender:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	
end

function OperBossTreasureRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:GetView():setScale(0.8)
		-- self.cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 100)
	end
	-- self.node_tree.img_buy_bg.node:setVisible(false)
	-- self.node_tree.img_buy_bg.node:setLocalZOrder(999)
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind1(self.BuyShopItem, self), true)
end

function OperBossTreasureRender:OnFlush()
	if self.data == nil then return end
	if self.data.cfg_data == nil then return end
	local data = {item_id = self.data.cfg_data.id, num = self.data.cfg_data.count, is_bind = self.data.cfg_data.bind}
	self.cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.cfg_data.id)
	if item_cfg == nil then
		return 
	end
	self.node_tree.lbl_item_name.node:setString(item_cfg.name)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))

	local disprice_str = RoleData.Instance:ToStringByNumber(self.data.cfg_data.consume[1].count)
	self.node_tree.txt_cost.node:setString(disprice_str)
	-- self.node_tree.txt_rest_buy_time.node:setString(string.format(Language.Common.RestCount,self.data.cfg_data.buyNumLimit - self.data.buy_num))
	local path_1 = nil
	if self.data.cfg_data.discpriceType == 0 then
		path_1 = ResPath.GetCommon("icon_money")
	elseif self.data.cfg_data.discpriceType == 2 then
		path_1 = ResPath.GetCommon("bind_gold")
	elseif self.data.cfg_data.discpriceType == 3 then
		path_1 = ResPath.GetCommon("gold")
	elseif self.data.cfg_data.discpriceType == -1 then
		path_1 = ResPath.GetCommon("boss_sp")
	end
	self.node_tree.img_cost.node:loadTexture(path_1)
	local vis = self.data.buy_num >= (self.data.cfg_data.buyNumLimit or 1)
	self.node_tree.buyBtn.node:setGrey(self.data.buy_num >= (self.data.cfg_data.buyNumLimit or 1))
	self.node_tree.buyBtn.node:setTouchEnabled(not vis)
	-- self.node_tree.img_buy_bg.node:setVisible(vis)
	
end

function OperBossTreasureRender:BuyShopItem()
	if not self.data then return end
	if self.data.buy_num < (self.data.cfg_data.buyNumLimit or 1) then
		if self.data.cfg_data == nil then return end
		local alert_view = OperateActivityData.Instance:GetAlertWnd()
		if not alert_view:GetIsNolongerTips() then
			alert_view:SetOkFunc(function ()
				local act_id = OPERATE_ACTIVITY_ID.BOSS_TREASURE
				local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
				if cmd_id then
					OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.index, 1, oper_time, dindan_id, role_id, join_type)
				end
		  	end)
			local item_cfg = ItemData.Instance:GetItemConfig(self.data.cfg_data.id)
			local money_name = ShopData.GetMoneyTypeName(self.data.cfg_data.discpriceType)--Language.CombineServerActivity.Money_Name[self.data.cfg_data.discpriceType]
			local txt = string.format(Language.OperateActivity.BossTreasureTip, money_name, self.data.cfg_data.consume[1].count, string.format("%06x", item_cfg.color), item_cfg.name, self.data.cfg_data.count)
			alert_view:SetLableString(txt)
		  	alert_view:Open()
	  	else
	  		local act_id = OPERATE_ACTIVITY_ID.BOSS_TREASURE
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.index, 1, oper_time, dindan_id, role_id, join_type)
			end
	  	end
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombineServerActivity.Had_Buy)
	end
end


-- 名动传奇奖励Render
OperateActLegendryRepuRender = OperateActLegendryRepuRender or BaseClass(BaseRender)
function OperateActLegendryRepuRender:__init()

end

function OperateActLegendryRepuRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function OperateActLegendryRepuRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 1 do
		local ph = self.ph_list.ph_item_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		equip_cell:SetVisible(false)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OperateActLegendryRepuRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.btn_get.node:setVisible(self.data.personal == true)
	self.node_tree.btn_get.node:setEnabled(self.data.state and self.data.state == 1)
	local txt = Language.OperateActivity.FetchStateTexts[1]
	if self.data.state == 2 then
		txt = Language.OperateActivity.FetchStateTexts[2]
	end
	self.node_tree.btn_get.node:setTitleText(txt)
	local awar_cfg = self.data.personal and self.data[1] or self.data.awards[1]
	local awards = {{item_id = awar_cfg.id, num = awar_cfg.count, is_bind = awar_cfg.bind}}
	for k, v in pairs(awards) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData(v)
			self.cell_list[k]:SetVisible(true)
		end
	end
	
	txt = self.data.personal and Language.OperateActivity.NeedCondTitle[1] or string.format(Language.OperateActivity.RankTitle, self.index)
	self.node_tree.txt_title.node:setString(txt)
	local my_money = OperateActivityData.Instance:GetLegendryReputationMyMoneyCnt()
	txt = self.data.personal and string.format(Language.OperateActivity.LegendryReputation[4], my_money, self.data.gold_cond) or 
		((self.data.player_name and self.data.player_name ~= "") and self.data.player_name or Language.OperateActivity.NeedSomeOne)
	self.node_tree.txt_desc.node:setString(txt)

end

function OperateActLegendryRepuRender:CreateSelectEffect()

end

function OperateActLegendryRepuRender:GetReward()
	if not self.data then return end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION, self.data.idx)
	end
end


------嗨购一车商城ItemRender------------
HappyShoppingItemRender = HappyShoppingItemRender or BaseClass(BaseRender)
function HappyShoppingItemRender:__init()
	self.item_cell = nil
end

function HappyShoppingItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.img_remind = nil
end

function HappyShoppingItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	self.item_cell:GetView():setScale(0.8)
	-- self.item_cell:SetEventEnabled(false)
	-- self.item_cell:GetView():setAnchorPoint(cc.p(0,0))
	self:SetRemindVis()
	self.view:addChild(self.item_cell:GetView(), 100)
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
	
	
end

function HappyShoppingItemRender:OnClickBuyBtn()
	if not self.data then return end
	local act_id = OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data.itemIdx, 1)
	end
end

-- function HappyShoppingItemRender:OnClick()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end

function HappyShoppingItemRender:OnFlush()	
	if nil == self.data or not ItemData.AwardToItem(self.data) then
		return
	end
	local item_data = ItemData.AwardToItem(self.data)

	local item_config = ItemData.Instance:GetItemConfig(item_data.item_id)
	if nil == item_config then
		return
	end
	self.item_cell:SetData(item_data)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_item_name.node:setString(item_config.name)
	self.node_tree.txt_cost_price.node:setString(self.data.costNum)
end

function HappyShoppingItemRender:CreateSelectEffect()
	
end

function HappyShoppingItemRender:SetRemindVis()
	if not self.data then return end
	if not self.img_remind then
		self.img_remind = XUI.CreateImageView(152, 38, ResPath.GetMainui("remind_flag"), true)
		self.view:addChild(self.img_remind, 200)
	end
	self.img_remind:setVisible(OperateActivityData.Instance:GetHappyShopCanInputCnt() > 0)
end


----------------------------------------------------
-- OperateActMyShopCartRender
----------------------------------------------------
OperateActMyShopCartRender = OperateActMyShopCartRender or BaseClass(BaseRender)
function OperateActMyShopCartRender:__init()
end

function OperateActMyShopCartRender:__delete()	
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function OperateActMyShopCartRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	-- self.item_cell:GetView():setScale(0.8)
	-- self.item_cell:SetEventEnabled(false)
	self.view:addChild(self.item_cell:GetView(), 100)
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind(self.OnClickCancel, self), true)
end

function OperateActMyShopCartRender:OnFlush()
	if not self.data then return end
	local cfg = OperateActivityData.Instance:GetHappyShopOneItemCfgByIdx(self.data)
	if not cfg or not ItemData.AwardToItem(cfg) then return end
	local item_data = ItemData.AwardToItem(cfg)
	local item_config = ItemData.Instance:GetItemConfig(item_data.item_id)
	if nil == item_config then
		return
	end
	self.item_cell:SetData(item_data)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_item_name.node:setString(item_config.name)
	self.node_tree.txt_cost_price.node:setString(cfg.costNum)
end

function OperateActMyShopCartRender:CreateSelectEffect()
	
end

function OperateActMyShopCartRender:OnClickCancel()
	if not self.data then return end
	local act_id = OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, self.data, 2)
	end
end

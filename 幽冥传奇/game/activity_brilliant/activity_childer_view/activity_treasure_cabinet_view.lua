TreasureCabinetView = TreasureCabinetView or BaseClass(ActBaseView)

function TreasureCabinetView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function TreasureCabinetView:__delete()
	if self.next_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.next_flush_timer)
		self.next_flush_timer = nil
	end

	if nil ~= self.act_63_spare_timer then
		GlobalTimerQuest:CancelQuest(self.act_63_spare_timer)
	end

	if self.flush_alert then
		self.flush_alert:DeleteMe()
  		self.flush_alert = nil
	end	

	if self.buy_all_alert then
		self.buy_all_alert:DeleteMe()
  		self.buy_all_alert = nil
	end	

	if self.buy_alert then
		self.buy_alert:DeleteMe()
  		self.buy_alert = nil
	end	

	if self.cabinet_grid then
		self.cabinet_grid:DeleteMe()
		self.cabinet_grid = nil
	end

	if self.vip_reward_list then
		self.vip_reward_list:DeleteMe()
		self.vip_reward_list = nil
	end

	if self.common_reward_list then
		self.common_reward_list:DeleteMe()
		self.common_reward_list = nil
	end

	if self.cabinet_cell_list and next(self.cabinet_cell_list) then
		for k,v in pairs(self.cabinet_cell_list) do
			v:DeleteMe()
		end
		self.cabinet_cell_list = {}
	end 
end

function TreasureCabinetView:InitView()
	self.act_63_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZBG)
	self:CreateFlushTimer()
	self:CreateAct63SpareTimer()
	self:CreateCabinetGrid()
	self:CreateShowCell()
	self:CreateVipRewardList()
	self:CreateCommonRewardList()
	XUI.AddClickEventListener(self.node_t_list.btn_63_flush.node, BindTool.Bind(self.OnClickBtnFlush, self), false)
	XUI.AddClickEventListener(self.node_t_list.btn_63_all_buy.node, BindTool.Bind(self.OnClickBtnAllBuy, self), false)
	self:SetAwardDataList()
	self.can_flush = true
end

function TreasureCabinetView:RefreshView(param_list)
	self:SetDataList()
	if self.can_flush then
		self:SetAwardDataList()
	end
	self:FlushShowCabinet()
end

function TreasureCabinetView:OnClickBtnFlush()
	if self.flush_alert == nil then
		self.flush_alert = Alert.New()
	end
	self.flush_alert:SetShowCheckBox(true)
	local cost = ActivityBrilliantData.Instance:GetZBGFlushCost()
	self.flush_alert:SetLableString(string.format(Language.ActivityBrilliant.FlushCabinetAlert, cost))
	self.flush_alert:SetOkFunc(function ()
		ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.ZBG, 0)
  	end)
	self.flush_alert:Open()
end

function TreasureCabinetView:OnClickBtnAllBuy()
	if self.buy_all_alert == nil then
		self.buy_all_alert = Alert.New()
	end
	local money_type_str = ""
	local cabinetList = ActivityBrilliantData.Instance:GetCabinetItemList()
	local money_type_list = {[0] = 0, 0, 0, 0}
	local can_open = false
	for k,v in pairs(cabinetList) do
		if v.sign < 1 then
			can_open = true
			money_type_list[v.money_type] = money_type_list[v.money_type] + v.money
		end
	end
	for k,v in pairs(money_type_list) do
		if v > 0 then
			if "" ~= money_type_str then
				money_type_str = money_type_str .. ",";
			end
			money_type_str = money_type_str .. v .. Language.ActivityBrilliant.MoneyTypeList[k];
		end
	end
	local des = string.format(Language.ActivityBrilliant.BuyAllCabinetAlert, money_type_str)
	self.buy_all_alert:SetLableString(des)
	self.buy_all_alert:SetShowCheckBox(true)
	self.buy_all_alert:SetOkFunc(function ()
		ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.ZBG, 2)
  	end)
  	if can_open then
		self.buy_all_alert:Open()
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.ActivityBrilliant.TreasureSellOut)
  	end
end

function TreasureCabinetView:UpdateNextFlushTime()
	if nil == self.act_63_cfg then return end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local flush_time =  ActivityBrilliantData.Instance.cabinet_flush_time + self.act_63_cfg.config.params[1]
	local next_flush_time = math.floor(flush_time - server_time)
	if next_flush_time <= 0 then
		ActivityBrilliantCtrl.Instance.ActivityReq(3, ACT_ID.ZBG)
	end
	self.node_t_list.layout_treasure_cabinet.lbl_63_flush_time.node:setString(TimeUtil.FormatSecond2Str(next_flush_time))
	self.node_t_list.layout_treasure_cabinet.lbl_63_flush_time.node:setColor(COLOR3B.GREEN)
end

function TreasureCabinetView:UpdateAct63SpareTime()
	if nil == self.act_63_cfg then return end
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(self.act_63_cfg.end_time - now_time)
	self.node_t_list.layout_treasure_cabinet.lbl_63_surplus_time.node:setString(str)
end

function TreasureCabinetView:CreateFlushTimer()
	self.set_now_time = TimeCtrl.Instance:GetServerTime()
	self.next_flush_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateNextFlushTime, self), 1)
end
function TreasureCabinetView:CreateAct63SpareTimer()
	if nil ~= self.act_63_spare_timer then
		GlobalTimerQuest:CancelQuest(self.act_63_spare_timer)
	end
	self.act_63_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateAct63SpareTime, self), 1)
end

function TreasureCabinetView:CreateShowCell()
	self.cabinet_cell_list = {}
	for i = 1, 9 do
		local cell_ph = self.ph_list["ph_63_cell_" .. i]
		local cell = ActBaseCell.New()
		cell:SetPosition(cell_ph.x, cell_ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetCellBg(ResPath.GetCommon("cell_102"))
		self.node_t_list.layout_treasure_cabinet.node:addChild(cell:GetView(), 103)
		cell:GetView():setVisible(false)
		table.insert(self.cabinet_cell_list, cell)
	end
end

function TreasureCabinetView:CreateCabinetGrid()
	local bag_cells = 8
	local pos_t = {}
	for i = 0, 7 do
		local ph_cell= self.ph_list["ph_cabinet_" .. i + 1]
		if ph_cell ~= nil then
			pos_t[i] = {ph_cell.x, ph_cell.y}	-- 获取占位符的位置
		end
	end
	--创建格子
	local ph = self.ph_list.ph_64_tower_list
	self.cabinet_grid = BaseGrid.New()
	local size = self.node_t_list.layout_treasure_cabinet.node:getContentSize()
	local grid_node = self.cabinet_grid:CreateCellsByPos({w = size.width, h = size.height,  itemRender = CabinetRender, ui_config = self.ph_list.ph_cabinet_render}, pos_t)
	self.cabinet_grid:SetSelectCallBack(BindTool.Bind(self.SelectItemCallBack, self))
	self.node_t_list.layout_treasure_cabinet.node:addChild(grid_node, 0)
end

-- VIP奖励列表
function TreasureCabinetView:CreateVipRewardList()
	if nil == self.node_t_list.layout_treasure_cabinet then
		return
	end
	if nil == self.vip_reward_list then
		local ph = self.ph_list.ph_cabinet_vip_award
		self.vip_reward_list = ListView.New()
		self.vip_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, CabinetItemRender, nil, nil, self.ph_list.ph_cabinet_flush_render)
		-- self.vip_reward_list:SetItemsInterval(4)
		self.vip_reward_list:GetView():setAnchorPoint(0.5, 0.5)
		self.vip_reward_list:SetJumpDirection(ListView.Top)
		self.vip_reward_list:SetSelectCallBack(BindTool.Bind(self.SelectListItemCallBack, self))
		self.node_t_list.layout_treasure_cabinet.node:addChild(self.vip_reward_list:GetView())
	end
end

-- 普通奖励列表
function TreasureCabinetView:CreateCommonRewardList()
	if nil == self.node_t_list.layout_treasure_cabinet then
		return
	end
	if nil == self.common_reward_list then
		local ph = self.ph_list.ph_cabinet_common_award
		self.common_reward_list = ListView.New()
		self.common_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, CabinetItemRender, nil, nil, self.ph_list.ph_cabinet_flush_render)
		-- self.common_reward_list:SetItemsInterval(4)
		self.common_reward_list:GetView():setAnchorPoint(0.5, 0.5)
		self.common_reward_list:SetJumpDirection(ListView.Top)
		self.common_reward_list:SetSelectCallBack(BindTool.Bind(self.SelectListItemCallBack, self))
		self.node_t_list.layout_treasure_cabinet.node:addChild(self.common_reward_list:GetView())
	end
end

function TreasureCabinetView:FlushShowCabinet()
	local show_data = ActivityBrilliantData.Instance:GetShowCabinetList()
	if nil == show_data then return end
	for k,v in pairs(self.cabinet_cell_list) do
		if show_data[k] then
			local item_data = {is_bind = show_data[k].bind, item_id = show_data[k].id, num = show_data[k].count, effectId = show_data[k].effectId}
			v:SetData(item_data)
			v:GetView():setVisible(true)
		else
			v:SetData(nil)
			v:GetView():setVisible(false)
		end
	end
end

function TreasureCabinetView:SetDataList()
	local cabinetList = ActivityBrilliantData.Instance:GetCabinetItemList()
	cabinetList[0] = table.remove(cabinetList, 1)
	if self.cabinet_grid then
		self.cabinet_grid:SetDataList(cabinetList)
	end 
end

function TreasureCabinetView:SetAwardDataList()
	local vip_award_list = ActivityBrilliantData.Instance:GetCabinetVipList()
	local common_award_list = ActivityBrilliantData.Instance:GetCabinetCommonList()
	if self.vip_reward_list then
		self.vip_reward_list:SetDataList(vip_award_list)
	end 
	if self.common_reward_list then
		self.common_reward_list:SetDataList(common_award_list)
	end 	
end

function TreasureCabinetView:SelectItemCallBack(item)
	local view = ViewManager.Instance:GetView(ViewName.ActivityBrilliant)
	if item.data == nil then return end
	if item.data.sign == 1 or not item.is_turning then
		return
	end
	if self.buy_alert == nil then
		self.buy_alert = Alert.New()
	end
	local item_name = ItemData.Instance:GetItemName(item.data.id)
	local item_cfg = ItemData.Instance:GetItemConfig(item.data.id, item_data)
	if item_cfg == nil then
		return
	end
	local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
	local money_type_str = item.data.money .. Language.ActivityBrilliant.MoneyTypeList[item.data.money_type]
	local des = string.format(Language.ActivityBrilliant.BuyCabinetAlert, money_type_str, C3b2Str(color), item_name)
	self.buy_alert:SetShowCheckBox(true)
	self.buy_alert:SetLableString(des)
	self.buy_alert:SetOkFunc(function ()
		ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.ZBG, 1, item.data.index)
  	end)
	self.buy_alert:Open()
end

function TreasureCabinetView:SelectListItemCallBack(item)
	self.can_flush = false
	item:SetTurnEndCallback(function()
		self:SetAwardDataList()
		self.can_flush = true
	end)
end

function TreasureCabinetView:ItemConfigCallback()
	self:RefreshView()
end


CabinetRender = CabinetRender or BaseClass(BaseRender)
function CabinetRender:__init()
	self:AddClickEventListener()
end

function CabinetRender:__delete()
	if self.cabinet_cell then
		self.cabinet_cell:DeleteMe()
		self.cabinet_cell = nil
	end
	if self.buy_alert then
		self.buy_alert:DeleteMe()
  		self.buy_alert = nil
	end	
end

function CabinetRender:CreateChild()
	BaseRender.CreateChild(self)
	self.is_turning = true
	self.cabinet_cell = ActBaseCell.New()
	local ph = self.ph_list["ph_render_cell"]
	self.cabinet_cell:SetPosition(ph.x, ph.y)
	self.cabinet_cell:SetAnchorPoint(0.5, 0.5)
	self.node_tree.layout_brand1.node:addChild(self.cabinet_cell:GetView(), 300)
end

function CabinetRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function CabinetRender:OnFlush()
	if nil == self.data then
		return
	end
	if not self.node_tree.layout_brand1.node:isVisible() and self.data.sign ~= 1 and not self.is_turning then
		self:OnTurn(true)
	elseif not self.node_tree.layout_brand2.node:isVisible() and self.data.sign == 1 and self.is_turning then
		self:OnTurn(false)
	else 
		self.node_tree.layout_brand1.node:setVisible(self.data.sign ~= 1)
		self.node_tree.layout_brand2.node:setVisible(self.data.sign == 1)
	end
	local item_data = {}
	if nil ~= self.data then
		item_data.item_id = self.data.id
		item_data.num = self.data.count
		item_data.is_bind = self.data.bind
		item_data.effectId = self.data.effectId
		self.cabinet_cell:SetData(item_data)
	else
		self.cabinet_cell:SetData(nil)
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.id, item_data)
	if item_cfg == nil then
		return
	end
	local str = ItemData.Instance:GetItemName(self.data.id)
	local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
	self.node_tree.layout_brand1.lbl_item_name.node:setString(str)
	self.node_tree.layout_brand1.lbl_item_name.node:setColor(color)
end

function CabinetRender:OnTurn(is_open)
	if nil == is_open then
		is_open = true
	end

	self.is_turning = is_open
	local act_time = 0.8

	self.node_tree.layout_brand1.node:stopAllActions()
	self.node_tree.layout_brand2.node:stopAllActions()

	if is_open then
		self.node_tree.layout_brand1.node:setScale(-1, 1)
		self.node_tree.layout_brand1.node:setVisible(false)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local front_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand1.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand2.node:setScale(1, 1)
		self.node_tree.layout_brand2.node:setVisible(true)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local back_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand2.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	else
		self.node_tree.layout_brand1.node:setScale(1, 1)
		self.node_tree.layout_brand1.node:setVisible(true)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local front_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand1.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand2.node:setScale(-1, 1)
		self.node_tree.layout_brand2.node:setVisible(false)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local back_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand2.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	end
end

function CabinetRender:CreateSelectEffect()
end



CabinetItemRender = CabinetItemRender or BaseClass(BaseRender)
function CabinetItemRender:__init()
	self:AddClickEventListener()
	self.turn_end_callback = nil
end

function CabinetItemRender:__delete()
	if self.flush_cell then
		self.flush_cell:DeleteMe()
		self.flush_cell = nil
	end
end

function CabinetItemRender:CreateChild()
	BaseRender.CreateChild(self)
	-- self.is_turning = true
	self.flush_cell = ActBaseCell.New()
	local ph = self.ph_list["ph_render_cell"]
	self.flush_cell:SetPosition(ph.x, ph.y)
	self.flush_cell:SetIndex(i)
	self.flush_cell:SetAnchorPoint(0.5, 0.5)
	self.node_tree.layout_brand3.node:addChild(self.flush_cell:GetView(), 300)

	self.flag_bg = XUI.CreateImageView(110, 170, ResPath.GetMainui("remind_flag"), true)
	self.node_tree.layout_brand3.node:addChild(self.flag_bg, 300)
end

function CabinetItemRender:OnClick()
	if self.data == nil then return end
	local flush_times = ActivityBrilliantData.Instance:GetZBGFlushTimes()
	if self.data.sign == 1 then
		return
	end
	if flush_times < self.data.times then return end
	local vip_level = VipData.Instance:GetVipLevel()
	if vip_level >= self.data.viplv then
		self:OnTurn2(false)
	end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.ZBG, 3, self.data.index)
end

function CabinetItemRender:SetTurnEndCallback(func)
	self.turn_end_callback = func
end

function CabinetItemRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.layout_brand4.node:setScale(1, 1)
	self.node_tree.layout_brand3.node:setScale(1, 1)
	self.node_tree.layout_brand3.node:setVisible(self.data.sign ~= 1)
	self.node_tree.layout_brand4.node:setVisible(self.data.sign == 1)

	local item_data = {}
	if nil ~= self.data then
		item_data.item_id = self.data[1].id
		item_data.num = self.data[1].count
		item_data.is_bind = self.data[1].bind
		item_data.effectId = self.data[1].effectId
		self.flush_cell:SetData(item_data)
	else
		self.flush_cell:SetData(nil)
	end

	self.flag_bg:setVisible(false)
	local vip_level = VipData.Instance:GetVipLevel()
	local flush_times = ActivityBrilliantData.Instance:GetZBGFlushTimes()
	local color = COLOR3B.RED
	if flush_times >= self.data.times then
		flush_times = self.data.times
		color = COLOR3B.GREEN
		if self.data.sign ~= 1 and vip_level >= self.data.viplv then
			self.flag_bg:setVisible(true)
		end
	end
	self.node_tree.layout_brand3.lbl_item_name.node:setColor(color)
	self.node_tree.layout_brand3.lbl_item_name.node:setString(flush_times .. "/" .. self.data.times .. Language.ActivityBrilliant.Text22)
	if self.data.viplv > 0 then 
		local vip_str = string.format(Language.ActivityBrilliant.VipLvStr, self.data.viplv)
		self.node_tree.layout_viplv_lbl.node:setVisible(true)
		self.node_tree.layout_viplv_lbl.lbl_vip_lv.node:setString(vip_str)
	else 
		self.node_tree.layout_viplv_lbl.node:setVisible(false)
	end
end

function CabinetItemRender:OnTurn2(is_open)
	if nil == is_open then
		is_open = true
	end
	local act_time = 0.8
	-- self.is_turning = is_open

	self.node_tree.layout_brand3.node:stopAllActions()
	self.node_tree.layout_brand4.node:stopAllActions()

	local end_callback = cc.CallFunc:create(function()
		if nil ~= self.turn_end_callback then
			self.turn_end_callback()
		end
	end)

	if is_open then
		self.node_tree.layout_brand3.node:setScale(-1, 1)
		self.node_tree.layout_brand3.node:setVisible(false)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local front_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand3.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand4.node:setScale(1, 1)
		self.node_tree.layout_brand4.node:setVisible(true)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local back_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand4.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	else
		self.node_tree.layout_brand3.node:setScale(1, 1)
		self.node_tree.layout_brand3.node:setVisible(true)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local front_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand3.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand4.node:setScale(-1, 1)
		self.node_tree.layout_brand4.node:setVisible(false)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local back_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand4.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	end
end

function CabinetItemRender:CreateSelectEffect()
end

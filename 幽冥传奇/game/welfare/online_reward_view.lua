-- 在线奖励
local WelfareOnlineRewardView = BaseClass(SubView)

function WelfareOnlineRewardView:__init()
	self.texture_path_list = {
		'res/xui/welfare.png',
	}
	self.config_tab = {
		{"welfare_ui_cfg", 5, {0}},
	}
end

function WelfareOnlineRewardView:__delete()

end

function WelfareOnlineRewardView:ReleaseCallBack()
	if self.draw_item_data then
		for i,v in ipairs(self.draw_item_data) do
			v.try_change = true
		end
		self.draw_item_data = nil
	end
	self.online_data = nil
	if self.draw_item_list ~= nil then
		for _,v in ipairs(self.draw_item_list) do
			v:DeleteMe()
		end
	end
	self.draw_item_list = nil
	self:DeleteOnlineTimer()
end

function WelfareOnlineRewardView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.online_timer = nil
		self.online_data = WelfareData.Instance:GetOnlineRewardInfo()
		self.draw_item_data = self.online_data.draw_data
		self:CreateDrawItem()
		XUI.AddClickEventListener(self.node_t_list.btn_online_draw.node, BindTool.Bind1(self.OnClickDrawHandle, self))
	end

	-- EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataWelfareOnline, self))
end

function WelfareOnlineRewardView:CreateOnlineTimer()
	if not self.online_timer then
		self.online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.UpdateOnlineTime, self, 1), 1)
	end
end

function WelfareOnlineRewardView:UpdateOnlineDrawBtnState()
	local call_roll_times = 0
	for i,v in ipairs(self.draw_item_data) do
		if v.left_time == 0 and not WelfareData.Instance:IsOnlineRewardReceive(v.index) then
			call_roll_times = call_roll_times + 1
		end
	end

	XUI.SetButtonEnabled(self.node_t_list.btn_online_draw.node, call_roll_times > 0)
end

function WelfareOnlineRewardView:OpenCallBack()
	-- EventProxy.New(WelfareData.Instance, self):AddEventListener(WelfareData.ONLINE_REWARD_RESULT, BindTool.Bind(self.SetOnlineDrawResult, self))	
	-- EventProxy.New(WelfareData.Instance, self):AddEventListener(WelfareData.ONLINE_HAVEREWARD, BindTool.Bind(self.ChangeData, self))
end

function WelfareOnlineRewardView:ItemDataWelfareOnline()
	-- self:Flush()
end

function WelfareOnlineRewardView:CloseCallBack()
	
end

function WelfareOnlineRewardView:ShowIndexCallBack(index)
	WelfareCtrl.OnlineRewardInfoReq()
	self:Flush(index)
end

function WelfareOnlineRewardView:OnFlush(param_t, index)
	self:OnFlushOnlineRewardView()
end

function WelfareOnlineRewardView:OnFlushOnlineRewardView()
	self:DeleteOnlineTimer()
	self:OnlineDrawItemSetData()
	self:UpdateOnlineDrawBtnState()
	self:CreateOnlineTimer()
end


-- function WelfareOnlineRewardView:ChangeData()
-- 	if self.draw_item_data then
-- 		self:UpdateOnlineTime()
-- 	end
-- end

function WelfareOnlineRewardView:UpdateOnlineTime()
	-- 在线时间
	local flush_list = WelfareData.Instance:FlushOnlineTime()
	local hour = math.floor(self.online_data.online_time / 3600)
	local minute = math.floor((self.online_data.online_time / 60) % 60)
	local second = math.floor(self.online_data.online_time % 60)
	-- self.node_t_list.lbl_online_hour.node:setString(string.format("%02d", hour))
	-- self.node_t_list.lbl_online_min.node:setString(string.format("%02d", minute))
	-- self.node_t_list.lbl_online_sec.node:setString(string.format("%02d", second))

	-- 抽奖剩余时间
	if next(flush_list) then
		for k,v in pairs(flush_list) do
			self.draw_item_list[v]:SetData(self.draw_item_data[v])
		end
		self:OnlineDrawItemSetData()
		self:UpdateOnlineDrawBtnState()
	end
end

function WelfareOnlineRewardView:CreateCheckBox()
	self.skip_animation_check_box = self.skip_animation_check_box or {}
	self.skip_animation_check_box.status = WelfareData.Instance.skip_animation_check_box_status
	self.skip_animation_check_box.node = XUI.CreateImageView(20, 20, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.skip_animation_check_box.node:setVisible(self.skip_animation_check_box.status)
	self.node_t_list.layout_skip_animation.node:addChild(self.skip_animation_check_box.node, 10)
	XUI.AddClickEventListener(self.node_t_list.layout_skip_animation.node, BindTool.Bind(self.OnClickSelectBoxHandler, self), true)
end

function WelfareOnlineRewardView:OnClickSelectBoxHandler()
	if self.skip_animation_check_box == nil then return end
	self.skip_animation_check_box.status = not self.skip_animation_check_box.status
	self.skip_animation_check_box.node:setVisible(self.skip_animation_check_box.status)
end

function WelfareOnlineRewardView:DeleteOnlineTimer()
	if self.online_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.online_timer)
		self.online_timer = nil
	end
end

function WelfareOnlineRewardView:OnClickDrawHandle()
	for i,v in ipairs(self.draw_item_list) do
		v:ActToRoll()
	end
end

function WelfareOnlineRewardView:changeSelect()
	
	if self.selectIndex == self.draw_item_data_length + 1 then
		self.selectIndex = self.selectIndex - self.draw_item_data_length
	end
	self.draw_item_list[self.selectIndex]:SetSelect(true)
	for k, v in pairs(self.draw_item_list) do
		if k ~= self.selectIndex then
			v:SetSelect(false)
		end
	end
	
	local time = self.CountDownInstance:GetRemainTime(self.tiner1)

	if self.runTime > 0.3 then
		local data = self.Ignor_item_list[self.selectIndex]:GetData()
		if self.reward_index_id == data.item_id then 
			self.CountDownInstance:RemoveCountDown(self.tiner1)
			time = 1
			WelfareCtrl.GetOnlineReward(self.reward_index)
			self.is_runing = false
		end
	end
	self.selectIndex = self.selectIndex+1
	if time < 0.1 then
		self.runTime = self.runTime + 0.1
		self.CountDownInstance:RemoveCountDown(self.tiner1)
		self.tiner1 = self.CountDownInstance:AddCountDown(0.1, self.runTime, BindTool.Bind(self.changeSelect, self))
	end
	XUI.SetButtonEnabled(self.node_t_list.btn_online_draw.node, false)
end

function WelfareOnlineRewardView:OnlineDrawItemSetData()
	for i,item in ipairs(self.draw_item_list) do
		local data = self.draw_item_data[i]
		if data and data.try_change == true then
			item:SetData(data)
		end
	end
end

-- 在线奖励显示创建
function WelfareOnlineRewardView:CreateDrawItem()
	self.draw_item_list = {}
	for i,v in ipairs(self.draw_item_data) do
		if nil == self.draw_item_list[i] then
			local draw_item = OnlineDrawRender.New()
			draw_item:SetUiConfig(self.ph_list["ph_online_reward_render"], true)
			local item_size = draw_item:GetView():getContentSize()
			-- local x = (i * 2 - 1) * 70 - item_size.width / 2
			-- draw_item:GetView():setPosition(x, 152)

			if i < 5 then
				local x = (i * 2 - 1) * 90 - item_size.width / 2
				draw_item:GetView():setPosition(x, 230)
			elseif i <= 8 then
				local x = ((i-4) * 2 - 1) * 90 - item_size.width / 2
				draw_item:GetView():setPosition(x, 70)
			end

			self.node_t_list.layout_online_draw.node:addChild(draw_item:GetView(), 99, 99)
			self.draw_item_list[i] = draw_item
		end
	end
end


----------------------------------------------------
-- OnlineDrawRender
----------------------------------------------------
OnlineDrawRender = OnlineDrawRender or BaseClass(BaseRender)
OnlineDrawRender.MIN_ROLL_TIME = 0.1
OnlineDrawRender.MAX_ROLL_TIME = 0.13
OnlineDrawRender.CHANGE_SPEED_TIMES = 1
OnlineDrawRender.SPEED_UP_CHANGE_TIME = - 0.05
OnlineDrawRender.SPEED_DOWN_CHANGE_TIME = 0.025
OnlineDrawRender.MAX_PASS_TIMES = 1

function OnlineDrawRender:__init()
	self.item_cell = nil
	self.scorll_view = nil
	self.item_list = {}
end

function OnlineDrawRender:CreateChild()
	BaseRender.CreateChild(self)

	self:InitRollVal()
	-- self.img_already_receive = self.node_tree.img_already_receive.node
	-- self.img_already_receive:setLocalZOrder(12)
	-- self.lbl_text_1 = self.node_tree.lbl_text_1.node
	self.lbl_time = self.node_tree.lbl_time.node
	-- self.img_already_receive:setVisible(false)
	self.lbl_time:setString(TimeUtil.FormatSecond(0, 3))

	local ph = self.ph_list.ph_cell
	local item_cell = BaseCell.New()
	item_cell:GetView():setAnchorPoint(0.5, 0.5)
	item_cell:GetView():setPosition(ph.x, ph.y)
	self.view:addChild(item_cell:GetView(), 10)
	self.item_cell = item_cell
	self.item_cell_index = nil

	self.scorll_view = XUI.CreateLayout(ph.x, ph.y, ph.w, ph.h - 6)
	self.scorll_view:setClippingEnabled(true)
	self.view:addChild(self.scorll_view, 11)
end

function OnlineDrawRender:__delete()
	self.scorll_view = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self:InitRollVal()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
end

function OnlineDrawRender:OnFlush()
	if next(self.data) == nil then return end

	local is_receive = WelfareData.Instance:IsOnlineRewardReceive(self.data.index)
	local left_time = ""
	local color = COLOR3B.GREEN
	if self.data.left_time > 0 then
		left_time = TimeUtil.FormatSecond(self.data.left_time, 3)
		color = COLOR3B.RED
	else
		if is_receive then
			left_time = "已领取"
			color = COLOR3B.G_W2
		else
			left_time = "可领取"
		end
	end
	self.lbl_time:setString(left_time)
	self.lbl_time:setColor(color)
	self:SetRewardItem(self.data.item_index or 1)
	-- self.img_already_receive:setVisible(is_receive)
end

function OnlineDrawRender:InitRollVal()
	self.change_item = nil
	self.is_rolling = false
	self.cur_index = 1
	self.pass_times = 0
	self.roll_cost_t = 0.4
	self.add_cost_t = self.SPEED_UP_CHANGE_TIME
end

function OnlineDrawRender:SetRewardItem(index)
	if self.is_rolling == true then return end

	if self.item_cell_index and self.item_cell_index == index then
		return
	end
	local item_cfg = WelfareData.GetOnlineAwardCfg()[self.data.index].awards
	local item = item_cfg and item_cfg[1]
	if item then
		self.item_cell:SetData({item_id = item.id, num = item.count, is_bind = item.bind})
		local item_config = ItemData.Instance:GetItemConfig(item.id)
		if item_config then
			-- self.node_tree.lbl_text_1.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
			-- self.lbl_text_1:setString(item_config.name)
			self.item_cell_index = index
			self.data.try_change = false
		end
	else
		self.item_cell:SetData()
		-- self.lbl_text_1:setString("")
		self.item_cell_index = nil
	end
	self.scorll_view:setVisible(false)
end

function OnlineDrawRender:ActToRoll()
	if not WelfareData.Instance:IsOnlineRewardReceive(self.data.index) and self.data.left_time == 0
		and not self.is_rolling then
		-- WelfareCtrl.StartOnlineReward(self.data.index)
		
		WelfareCtrl.GetOnlineReward(self.data.index)
	end
end

function OnlineDrawRender:StartRoll(index)
	if self.is_rolling == true then return end

	self:SetRewardItem(0)
	self.roll_to_index = index
	self.is_rolling = true

	local x = self.scorll_view:getContentSize().width / 2
	local h = self.scorll_view:getContentSize().height

	self.scorll_view:setVisible(true)
	local item_cfg = WelfareData.GetOnlineAwardCfg()[self.data.index].awards
	for i, v in ipairs(item_cfg) do
		if nil == self.item_list[i] then
			local cell = BaseCell.New()
			cell:GetCell():setAnchorPoint(cc.p(0.5, 0.5))
			cell:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
			cell.bg_img:setVisible(false)
			cell:GetView():setTouchEnabled(false)
			self.item_list[i] = cell
			self.scorll_view:addChild(self.item_list[i]:GetView(), 99, 99)
		end
		self.item_list[i]:GetView():stopAllActions()
		y = h * 2
		self.item_list[i]:SetPosition(x, y)
	end

	self.change_item = self.item_list[self.cur_index]
	self:RunRollAction(self.change_item)
end

function OnlineDrawRender:RunRollAction(change_item)
	local item_cfg = WelfareData.GetOnlineAwardCfg()[self.data.index].awards
	local h = BaseCell.SIZE
	change_item:GetView():setPositionY(h * 1.5)

	local next_roll_cost = self.roll_cost_t + self.add_cost_t
	if next_roll_cost > self.MAX_ROLL_TIME then
		self.roll_cost_t = self.MAX_ROLL_TIME
	elseif self.roll_cost_t < self.MIN_ROLL_TIME then
		self.roll_cost_t = self.MIN_ROLL_TIME
	else
		self.roll_cost_t = next_roll_cost
	end

	local move_by1 = cc.MoveBy:create(self.roll_cost_t, cc.p(0, - h))
	local move_by2 = cc.MoveBy:create(self.roll_cost_t, cc.p(0, - h))
	local func = function()
		if self.cur_index == self.roll_to_index then
			self.pass_times = self.pass_times + 1
			if self.pass_times == self.CHANGE_SPEED_TIMES then
				self.add_cost_t = self.SPEED_DOWN_CHANGE_TIME
			end

			if self.pass_times > self.MAX_PASS_TIMES then
				self.change_item:GetView():stopAllActions()
				WelfareCtrl.GetOnlineReward(self.data.index)
				self:InitRollVal()
				self:SetRewardItem(self.roll_to_index)
				self.roll_to_index = -1
				return
			end
		end
		self.cur_index = (self.cur_index + 1) > #item_cfg and 1 or (self.cur_index + 1)
		self.change_item = self.item_list[self.cur_index]

		self:RunRollAction(self.change_item)
	end
	local call_back = cc.CallFunc:create(func)
	local sequence = cc.Sequence:create(move_by1, call_back, move_by2)

	change_item:GetView():stopAllActions()
	change_item:GetView():runAction(sequence)
end

return WelfareOnlineRewardView
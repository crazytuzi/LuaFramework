-- 每日签到
local WelfareDailySignInView = BaseClass(SubView)

function WelfareDailySignInView:__init()

	self.texture_path_list = {
		'res/xui/welfare.png',
	}
	self.config_tab = {
		{"welfare_ui_cfg", 3, {0}},
	}

	self.grid_view = nil
	self.scroll_view = nil
	self.grid_items = {}
end


function WelfareDailySignInView:__delete()
	
end

function WelfareDailySignInView:ReleaseCallBack()
	self.grid_view = nil
	self.scroll_view = nil
	self.sign_in_data = nil

	if self.grid_items ~= nil then
		for k, v in pairs(self.grid_items) do
			v:DeleteMe()
		end
	end
	self.grid_items = {}

	if self.pop_alert then
		self.pop_alert:DeleteMe()
		self.pop_alert = nil
	end

	if self.month_num then
		self.month_num:DeleteMe()
		self.month_num = nil
	end
end

function WelfareDailySignInView:LoadCallBack(index, loaded_times)
	self:GetDataAndChangeView()

	EventProxy.New(WelfareData.Instance, self):AddEventListener(WelfareData.DAILY_SIGN_IN_DATA_CHANGE, BindTool.Bind(self.ChangeDailyDataAbout, self))
	self.node_t_list.img_bg_line.node:setLocalZOrder(102)
	--EventProxy.New(WelfareData.Instance, self):AddEventListener(WelfareData.DAILY_SIGN_IN_DATA_AGAIN, BindTool.Bind(self.ChangeDailyDataAbout, self))
end

function WelfareDailySignInView:GetDataAndChangeView()
	self.node_t_list.layout_daily_sign_in.can_jump = 1
	self.sign_in_data = WelfareData.Instance:GetSignInData()

	-- self:CreateMountNumBar()

	for i = 1, SIGN_IN_ADD_REWARD_MAX_INDEX do
		local node = self.node_t_list["layout_chest_" .. i] and self.node_t_list["layout_chest_" .. i].node
		if node ~= nil then
			XUI.AddClickEventListener(node, BindTool.Bind2(self.OnClickChestHandler, self, i), true)
		end
	end

	-- self.node_t_list.lbl_sign_in_num.node:setString(self.sign_in_data.sign_in_times)    --  本月签到次数
	self:CreateDayGrid()
	self:FlushChestReward()
end


function WelfareDailySignInView:OpenCallBack()
end

function WelfareDailySignInView:ShowIndexCallBack(index)
end

function WelfareDailySignInView:OnFlush(param_t, index)
end

function WelfareDailySignInView:CloseCallBack(is_all)
end
---------------------------------------------------------------------------------------

function WelfareDailySignInView:ChangeDailyDataAbout(vo, datas)
	-- self.node_t_list.lbl_sign_in_num.node:setString(datas)
	self:CreateDayGrid()
	self:FlushChestReward()
end


function WelfareDailySignInView:CreateDayGrid()
	if not self.sign_in_data then
		return
	end

	local each_row_num = 5		-- 一行多少个item
	local row_jianju = 10		-- 每一行之间的间距
	local ph = self.ph_list.ph_sign_in_list
	local item_w = self.ph_list.ph_sign_in_render.w
	local item_h = self.ph_list.ph_sign_in_render.h
	local row_size = math.ceil(#self.sign_in_data.day_datas / each_row_num)		-- 总行数
	local height = (item_h + row_jianju) * row_size								-- scroll_view真实高度
	local column_jianju = (ph.w - item_w * each_row_num) / (each_row_num - 1)	-- 每一列之间的间距

	if not self.grid_view then
		self.grid_view = XUI.CreateLayout(ph.x, ph.y, ph.w, ph.h)
		self.node_t_list.layout_daily_sign_in.node:addChild(self.grid_view, 100, 100)
	end
	if not self.scroll_view then
		self.scroll_view = XUI.CreateScrollView(0, 0, ph.w, ph.h, ScrollDir.Vertical)
		self.scroll_view:setAnchorPoint(cc.p(0, 0))
		self.scroll_view:setBounceEnabled(true)
		self.scroll_view:setTouchEnabled(true)
		self.scroll_view:setContentSize(cc.size(ph.w, ph.h))
		self.scroll_view:setInnerContainerSize(cc.size(ph.w, height))
		self.grid_view:addChild(self.scroll_view)
	end

	self.grid_items = self.grid_items or {}
	local first_can_get = nil
	for i,v in ipairs(self.sign_in_data.day_datas) do
		if not self.grid_items[i] then
			local item = SignInRender.New()
			item:SetUiConfig(self.ph_list.ph_sign_in_render)
			item:SetIsUseStepCalc(true)
			local cur_row = math.ceil(i / each_row_num)	                                     -- 判断当前item在第哪一行
			local cur_column = i % each_row_num	== 0 and each_row_num or i % each_row_num	 -- 判断当前item在第哪一列
			local size = item:GetView():getContentSize()
			local x = (cur_column - 1) * (size.width + column_jianju)
			local y = height - (size.height + row_jianju) * cur_row
			item.view:setPosition(x, y)
			self.scroll_view:addChild(item.view, 100, 100)
			item:SetClickCallBack(BindTool.Bind1(self.ClickSignInHandler, self))
			self.grid_items[i] = item
		end
		self.grid_items[i]:SetData(v)

		if first_can_get == nil and v.status == SIGN_IN_STATUS.SIGN_IN then
			first_can_get = v.day
		end
	end

	if first_can_get == nil then
		first_can_get = self.sign_in_data.cur_day
	end
	if self.node_t_list.layout_daily_sign_in.node:isVisible() and self.node_t_list.layout_daily_sign_in.can_jump == 1 then
		if first_can_get > 0 then
			local inner_h = self.scroll_view:getInnerContainerSize().height
			local totle_h = inner_h - self.scroll_view:getContentSize().height
			if totle_h > 0 then	
				local offset_y = (item_h + row_jianju) * math.floor((first_can_get - 1) / each_row_num)
				local percent = offset_y / totle_h * 100
				if percent > 100 then
					percent = 100
				end
				self.scroll_view:jumpToPercentVertical(percent)
			end
			self.node_t_list.layout_daily_sign_in.can_jump = 0
		end
	end
end

function WelfareDailySignInView:OnClickChestHandler(index)
	local chest_data = WelfareData.GetAccumulatedDaysAward()[index]
	local is_receive = WelfareData.Instance:IsAddSignReward(index)
	if self.sign_in_data.sign_in_times >= chest_data.days and not is_receive then
		WelfareCtrl.GetAddDaysReward(index)
	else
		local tips_data = {}
		tips_data.desc = string.format(Language.Welfare.ChestTips, chest_data.days)
		tips_data.item_data = chest_data.reward
		WelfareCtrl.Instance:SetDataWefare(tips_data)
	end
end 

function WelfareDailySignInView:FlushChestReward()
	
	for i = 1, SIGN_IN_ADD_REWARD_MAX_INDEX do
		local chest_data = WelfareData.GetAccumulatedDaysAward()[i]
		local node_cfg = self.node_t_list["layout_chest_" .. i]
		if node_cfg and chest_data then
			local is_receive = WelfareData.Instance:IsAddSignReward(i)--是否已经领取
			if is_receive then
				if not node_cfg.stamp then
					local x, y = node_cfg.node:getPosition()
					local stamp = XUI.CreateImageView(x, y, ResPath.GetCommon("stamp_1"), true)
					self.node_t_list.layout_daily_sign_in.node:addChild(stamp, 20)
					node_cfg.stamp = stamp
				end
			elseif self.sign_in_data.sign_in_times >= chest_data.days then
				if not node_cfg.receive_effect then
					local x, y = node_cfg.node:getPosition()
					local size = node_cfg.node:getContentSize()
					local receive_effect = XUI.CreateImageView(x + 20, y + 30, ResPath.GetMainUiImg("remind_flag"), true)
					self.node_t_list.layout_daily_sign_in.node:addChild(receive_effect, 20)
					node_cfg.receive_effect = receive_effect
				end
			end
			if node_cfg.stamp then
				node_cfg.stamp:setVisible(is_receive)
			end
			if node_cfg.receive_effect then
				node_cfg.receive_effect:setVisible(self.sign_in_data.sign_in_times >= chest_data.days and not is_receive)
			end
			node_cfg.node:setColor(is_receive and COLOR3B.GRAY or COLOR3B.WHITE)
		end
	end

	if next(self.sign_in_data) == nil then return end

	local month = self.sign_in_data.cur_month
	-- self.month_num:SetNumber(month)
	local add_sign_reward_cfg = WelfareData.GetAccumulatedDaysAward()
	local prog_num = 0
	for i,v in ipairs(add_sign_reward_cfg) do
		if self.sign_in_data.sign_in_times >= v.days then
			prog_num = prog_num + 1
		end
	end

	self.node_t_list.prog9_sign_in.node:setPercent((prog_num - 1) / (#add_sign_reward_cfg - 1) * 100)
	
end

function WelfareDailySignInView:CreateMountNumBar()
	if self.month_num ~= nil then return end

	self.month_num = NumberBar.New()
	self.month_num:SetRootPath(ResPath.GetWelfare("month_num_"))
	local x, y = self.node_t_list["img_word_month"].node:getPosition()
	self.month_num:SetPosition(x - 16, y - 18)
	self.month_num:SetSpace(1)
	self.month_num:SetGravity(NumberBarGravity.Right)
	self.node_t_list["layout_daily_sign_in"].node:addChild(self.month_num:GetView(), 100)
end

function WelfareDailySignInView:ClickSignInHandler(cell)
	if cell.data.status == SIGN_IN_STATUS.SIGN_IN then
		WelfareCtrl.EveryDaySignReq(cell.data.day)
	elseif cell.data.status == SIGN_IN_STATUS.AGAIN then
		WelfareCtrl.EveryDaySignReq(cell.data.day)
	elseif cell.data.status == SIGN_IN_STATUS.ALREADYGET then
		TipCtrl.Instance:OpenItem(cell.data.itemvo, EquipTip.FROM_NORMAL)
	elseif cell.data.status == SIGN_IN_STATUS.BACK or cell.data.status == SIGN_IN_STATUS.V1_BACK or cell.data.status == SIGN_IN_STATUS.V2_BACK or cell.data.status == SIGN_IN_STATUS.V3_BACK  then
		local cost = WelfareData.GetSignInFindCost()
		self.pop_alert = self.pop_alert or Alert.New()
		self.pop_alert:SetLableString(string.format(Language.Welfare.GoldFindBack, cost))
		self.pop_alert:SetOkFunc(BindTool.Bind1(function ()
			WelfareCtrl.EveryDaySignReq(cell.data.day)
		end, self))
		self.pop_alert:SetCancelString(Language.Common.Cancel)
		self.pop_alert:SetOkString(Language.Common.Confirm)
		self.pop_alert:SetShowCheckBox(true)
		self.pop_alert:Open()
	elseif cell.data.status == SIGN_IN_STATUS.WAIT then
		TipCtrl.Instance:OpenItem(cell.data.itemvo, EquipTip.FROM_NORMAL)
	elseif cell.data.status == SIGN_IN_STATUS.V1 then
		TipCtrl.Instance:OpenItem(cell.data.itemvo, EquipTip.FROM_NORMAL)
	elseif cell.data.status == SIGN_IN_STATUS.V2 then
		TipCtrl.Instance:OpenItem(cell.data.itemvo, EquipTip.FROM_NORMAL)
	elseif cell.data.status == SIGN_IN_STATUS.V3 then
		TipCtrl.Instance:OpenItem(cell.data.itemvo, EquipTip.FROM_NORMAL)
	end
end

----------------------------------------------------
-- SignInRender
----------------------------------------------------
SignInRender = SignInRender or BaseClass(BaseRender)
SignInRender.SelectItem = nil
function SignInRender:__init()
	self.click_callback = nil
	SignInRender.SelectItem = nil
end

function SignInRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function SignInRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph_cell = self.ph_list.ph_cell
	self.cell = BaseCell.New()
	self.cell:GetCell():setAnchorPoint(cc.p(0.5, 0.5))
	self.cell:GetCell():setPosition(ph_cell.x, ph_cell.y)
	self.view:addChild(self.cell:GetCell(), 1, 1)
	self.img_receive_status = self.node_tree["img_receive_stamp"].node
	self.node_tree.lbl_text_1.node:setString(string.format(Language.Welfare.SignInDay, self.data.day))
	self.cell:SetClickCallBack(BindTool.Bind1(self.OnClickViewHandler, self))
	XUI.AddClickEventListener(self.view, BindTool.Bind1(self.OnClickViewHandler, self), false)
	self.act_eff = RenderUnit.CreateEffect(326, self.cell:GetCell(), nil, nil, nil, 38,22)
end

function SignInRender:OnClickViewHandler()
	if SignInRender.SelectItem then
		SignInRender.SelectItem:SetSelect(false)
	end
	self:SetSelect(true)
	SignInRender.SelectItem = self
	self:OnClick()
end

function SignInRender:OnFlush()
	local title_path = "stamp_receive"
	self.cell:SetIsShowTips(false)
	self.node_tree.img_already_receive.node:setVisible(false)
	self.img_receive_status:setVisible(true)
	self.act_eff:setVisible(false)
	if self.data.status == SIGN_IN_STATUS.SIGN_IN then
		title_path = "stamp_receive"
		self.act_eff:setVisible(true)
	elseif self.data.status == SIGN_IN_STATUS.AGAIN then
		title_path = "stamp_receive_again"
		self.act_eff:setVisible(true)
	elseif self.data.status == SIGN_IN_STATUS.ALREADYGET then
		self.node_tree.img_already_receive.node:setVisible(true)
		self.img_receive_status:setVisible(false)
	elseif self.data.status == SIGN_IN_STATUS.BACK then
		title_path = "stamp_findback"
	elseif self.data.status == SIGN_IN_STATUS.WAIT then
		title_path = "stamp_receive"
		self.img_receive_status:setVisible(false)
		self.cell:SetIsShowTips(true)
	elseif self.data.status == SIGN_IN_STATUS.V1 or self.data.status == SIGN_IN_STATUS.V1_BACK then
		title_path = "stamp_v1"
	elseif self.data.status == SIGN_IN_STATUS.V2 or self.data.status == SIGN_IN_STATUS.V2_BACK then
		title_path = "stamp_v2"
	elseif self.data.status == SIGN_IN_STATUS.V3 or self.data.status == SIGN_IN_STATUS.V3_BACK then
		title_path = "stamp_v3"
	end
	self.view:setColor(self.data.status == SIGN_IN_STATUS.ALREADYGET and COLOR3B.GRAY or COLOR3B.WHITE)
	self.img_receive_status:loadTexture(ResPath.GetWelfare(title_path), true)
	self.cell:SetData(self.data.itemvo)
end

return WelfareDailySignInView

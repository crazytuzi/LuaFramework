local OpenServeChargeZPView = OpenServeChargeZPView or BaseClass(SubView)
local ITEM_COUNT = 10

function OpenServeChargeZPView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"open_serve_act_gold_turnble_ui_cfg", 3, {0}},
	}

	RemindManager.Instance:RegisterCheckRemind(function ()
		return OpenServiceAcitivityData.Instance:GoldCanDrawNum()
	end, RemindName.OpenServiceGoldDraw)

	GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, function ()
		-- OpenServiceAcitivityData.SendOpenServerActGoldDrawReq(2)
		OpenServiceAcitivityData.Instance:SetGoldDrawTabbarVisible()
	end)
end

function OpenServeChargeZPView:ReleaseCallBack()
	if self.zp_53_log_list then
		self.zp_53_log_list:DeleteMe()
		self.zp_53_log_list = nil
	end

	if self.spare_54_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_54_time)
		self.spare_54_time = nil
	end

	if self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	--派发完成后 清除抽奖索引 区分是否抽奖下发
	OpenServiceAcitivityData.Instance:GetGoldDrawInfo().draw_award_index = 0
end

function OpenServeChargeZPView:OpenCallBack()
end

function OpenServeChargeZPView:LoadCallBack()
	self.node_t_list.btn_54_draw.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))
	self.node_t_list.layout_dzp_point.node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.btn_charge_54.node:addClickEventListener(function () ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge) end)

	XUI.AddClickEventListener(self.node_t_list.layout_act_auto_hook.btn_nohint_checkbox.node, BindTool.Bind(self.OnClickZhuanPanAutoUse, self), true)
	self.node_t_list.layout_act_auto_hook.img_hook.node:setVisible(false)

	self.reward_view = self:CreateCZZPReward()

	--选择奖励
	self.select_reward_view = self:CreateSelectRewardView()
	self.node_t_list.layout_stuff_tips.node:setVisible(false)
	self.node_t_list.layout_stuff_tips.node:setLocalZOrder(300)
	XUI.AddClickEventListener(self.node_t_list.btn_close_select.node, function ()
		self.select_reward_view:Close()
	end)

	self:CreateCZZPRewardLog()
	self:CreateSpareFFTimer()

	self.event_proxy = EventProxy.New(OpenServiceAcitivityData.Instance, self)
	self.event_proxy:AddEventListener(OpenServiceAcitivityData.GoldDrawChange, BindTool.Bind(self.OnFlushGoldDrawView, self))

	--ui调整
	XUI.RichTextSetCenter(self.node_t_list.rich_draw_need_tip.node)

	self:OnFlushGoldDrawView()
end

function OpenServeChargeZPView:ShowIndexCallBack()
	self:OnFlushGoldDrawView()
end

function OpenServeChargeZPView:OnClickZhuanPanAutoUse()
	local vis = self.node_t_list.layout_act_auto_hook.img_hook.node:isVisible()
	self.node_t_list.layout_act_auto_hook.img_hook.node:setVisible(not vis)
end

function OpenServeChargeZPView:GetIsIgnoreAction()
	return self.node_t_list.layout_act_auto_hook and self.node_t_list.layout_act_auto_hook.img_hook.node:isVisible()
end

OpenServeChargeZPView.Language = {
	LastLoopTip = "已到最后一轮",
	LoopPayTip = "再充值{wordcolor;DC143C;%s元宝}可激活",
	SelectTip = {
		[1] = "您是否立即领取抽中的{wordcolor;DC143C;%s元宝}？",
		[2] = "您第二天领取抽中的{wordcolor;DC143C;%s元宝}将增加20%%",
		[3] = "您第三天领取抽中的{wordcolor;DC143C;%s元宝}将增加30%%",
	}
}
function OpenServeChargeZPView:OnFlushGoldDrawView(param_list)
	local data = OpenServiceAcitivityData.Instance:GetGoldDrawInfo()
	local is_end = OpenServiceAcitivityData.Instance:GoldDrawIsEnd()

	local show_loop = data.already_used_num == #openYbTurnDiscCfg.roundList and #openYbTurnDiscCfg.roundList or data.already_used_num + 1

	local need_gold_tip = is_end and OpenServeChargeZPView.Language.LastLoopTip or string.format("再充值{wordcolor;DC143C;%s元宝}可激活", data.next_draw_need_gold_num)
	RichTextUtil.ParseRichText(self.node_t_list.rich_draw_need_tip.node, need_gold_tip, 20)


	local function flush_info_change()
		self.zp_53_log_list:SetDataList(data.record_list)
		self.reward_view:Update()
		self.node_t_list.img_loop_tip.node:loadTexture(ResPath.GetOpenServerActivity("img_loop_" .. show_loop))
		self.node_t_list.lbl_gold_num.node:setString(openYbTurnDiscCfg.roundList[show_loop].consumeYb)
		self.node_t_list.lbl_54_draw_num.node:setString(OpenServiceAcitivityData.Instance:GoldCanDrawNum())

		if data.draw_award_index > 0 then
			local cfg =  openYbTurnDiscCfg.roundList[data.already_used_num]
			local gold = cfg.awardPool[data.draw_award_index].multiple * cfg.consumeYb
			self.select_reward_view:Open(gold)
		end
	end

	if data.draw_award_index > 0 and not self:GetIsIgnoreAction() then
		self.node_t_list.layout_dzp_point.node:stopAllActions()
		local rotate = self.node_t_list.layout_dzp_point.node:getRotation() % 360
		local to_rotate =360 - rotate + 360 / ITEM_COUNT / 2 + 360 / ITEM_COUNT * (data.draw_award_index - 1)
		local rotate_by = cc.RotateBy:create(0.5, to_rotate)
		local callback = cc.CallFunc:create(function ()
			self.node_t_list.btn_54_draw.node:setEnabled(true)
			ItemData.Instance:SetDaley(false)
			flush_info_change()
		end)
		local sequence = cc.Sequence:create(rotate_by, callback)
		self.node_t_list.layout_dzp_point.node:runAction(sequence)
	else
		flush_info_change()
	end
end

function OpenServeChargeZPView:CreateSelectRewardView()
	local view = {}
	local parent = self.node_t_list.layout_stuff_tips.node
	local HIGH_RADIO = 70
	local item_list = {}
	local select_idx = 1

	local function create_item(index)
		local item = {}
		local x = 40
		local y = - index * HIGH_RADIO + 320

		local img_check_bg = XUI.CreateImageView(x, y, ResPath.GetCommon("check_1_bg"), true)
		parent:addChild(img_check_bg, 300)
		XUI.AddClickEventListener(img_check_bg, function ()
			for i, item in ipairs(item_list) do
				item:SetSelect(index == i)
				select_idx = index
			end
		end)

		local img_check_cross = XUI.CreateImageView(x, y, ResPath.GetCommon("check_1_cross"), true)
		parent:addChild(img_check_cross, 301)
		img_check_cross:setVisible(select_idx == index)

		local rich_content = XUI.CreateRichText(x + 20, y + 11, 400, 50, false)
		rich_content:setAnchorPoint(0, 1)
		parent:addChild(rich_content, 300)
		XUI.AddClickEventListener(rich_content, function ()
			for i, item in ipairs(item_list) do
				item:SetSelect(index == i)
				select_idx = index
			end
		end)

		local frame_size = cc.Director:getInstance():getOpenGLView():getFrameSize()
		local img_bg = XUI.CreateLayout(parent:getPositionX() - 250, parent:getPositionY() - 280, frame_size.width, frame_size.height)
		-- img_bg:setAnchorPoint(0, 0)
		img_bg:setBackGroundColor(COLOR3B.BLACK)
		img_bg:setBackGroundColorOpacity(50)
		img_bg:setTouchEnabled(true)
		parent:addChild(img_bg, -1)

		if index == 3 then
			UiInstanceMgr.AddRectEffect({node = rich_content, init_size_scale = 1, time = 0.5, act_size_scale = 1.02, offset_w =  15, offset_y = 15, offset_h = -5 , color = COLOR3B.GREEN})
		end

		function item:SetSelect(is_select)
			-- img_check_bg:setVisible(is_select)
			img_check_cross:setVisible(is_select)
		end

		function item:SetSelectTip(gold)
			gold = math.floor(gold)
			RichTextUtil.ParseRichText(rich_content, string.format(OpenServeChargeZPView.Language.SelectTip[index], gold, 20))
			rich_content:refreshView()
		end

		return item
	end

	--init
	for i = 1, 3 do
		table.insert(item_list, create_item(i))
	end

	function view:Open(gold)
		for i,item in ipairs(item_list) do
			item:SetSelectTip(gold)
			item:SetSelect(select_idx == i)
		end
		parent:setVisible(true)
	end


	function view:Close()
		parent:setVisible(false)
		OpenServiceAcitivityData.SendOpenServerActGoldDrawSelectTypeReq(select_idx)
		select_idx = 1
	end

	return view
end

function OpenServeChargeZPView:CreateCZZPReward()
	local view = {}
	local item_list = {}

	local r = 110
	local r_x, r_y = self.node_t_list.layout_dzp_point.node:getPosition()

	local function create_item(i)
		local item = {}

		local x = r_x + r * math.cos(math.rad(74 - 360 / ITEM_COUNT * (i - 1))) - 8
		local y = r_y  + r * math.sin(math.rad(74 - 360 / ITEM_COUNT * (i - 1))) - 10

		--ui
		local num_bar = NumberBar.New()
		num_bar:SetRootPath(ResPath.GetOpenServerActivity("num_"))
		num_bar:SetPosition(x, y)
		num_bar:SetGravity(NumberBarGravity.Center)
		self.node_t_list.layout_turntable_54.node:addChild(num_bar:GetView(), 300)

		local text = XUI.CreateImageView(0, 0, ResPath.GetOpenServerActivity("img_text_1"), true)
		text:setPosition(30, 13)
		num_bar:GetView():addChild(text)

		local text = XUI.CreateImageView(0, 0, ResPath.GetOpenServerActivity("num_point"), true)
		text:setPosition(-1, 5)
		num_bar:GetView():addChild(text)

		--func
		function item:DeleteMe()
			num_bar:DeleteMe()
		end

		function item:SetData(num)
			num_bar:SetNumber(num)
		end

		return item
	end

	for i = 1, ITEM_COUNT do
		local item = create_item(i)
		table.insert(item_list, item)
	end

	function view:DeleteMe()
		for i,v in ipairs(item_list) do
			v:DeleteMe()
		end
	end

	function view:Update()
		local loop_num = OpenServiceAcitivityData.Instance:GetGoldDrawInfo().already_used_num
		if loop_num == 0 then loop_num = 1 end	
		local cfg = openYbTurnDiscCfg.roundList[loop_num].awardPool --{multiple = 1.2,weight = 2000, istip = 1,islog = 1},
		for i,v in ipairs(item_list) do
			v:SetData(cfg[i].multiple * 10)
		end
	end
	return view
end

function OpenServeChargeZPView:CreateCZZPRewardLog()
	local ph = self.ph_list.ph_zp_54_list
	self.zp_53_log_list = ListView.New()
	self.zp_53_log_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OpenServeCZZPLogRender, nil, nil, self.ph_list.ph_item_54)
	self.zp_53_log_list:GetView():setAnchorPoint(0.5, 0.5)
	self.zp_53_log_list:SetJumpDirection(ListView.Top)
	self.zp_53_log_list:SetItemsInterval(5)
	self.node_t_list.layout_turntable_54.node:addChild(self.zp_53_log_list:GetView(), 100)
end

function OpenServeChargeZPView:UpdateSpareFFTime()
	local spare_time = OpenServiceAcitivityData.Instance:GetGoldDrawSpareTime()
	if spare_time <= 0 then
		--元宝转盘开启检测
		OpenServiceAcitivityData.Instance:SetGoldDrawTabbarVisible()
	end

	self.node_t_list.layout_turntable_54.lbl_activity_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function OpenServeChargeZPView:CreateSpareFFTimer()
	self.spare_54_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end

function OpenServeChargeZPView:OnClickTurntableHandler()
	if OpenServiceAcitivityData.Instance:GoldCanDrawNum() <= 0 and not OpenServiceAcitivityData.Instance:GoldDrawIsEnd() then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.ActivityBrilliant.ChongZhiZPTip)
		return 
	elseif OpenServiceAcitivityData.Instance:GoldDrawIsEnd() and OpenServiceAcitivityData.Instance:GoldCanDrawNum() <= 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(OpenServeChargeZPView.Language.LastLoopTip)
		return 
	end
	self:OnClickCZZPHandler()
end

function OpenServeChargeZPView:OnClickCZZPHandler()
	--跳过动画
	if self:GetIsIgnoreAction() then
		OpenServiceAcitivityData.SendOpenServerActGoldDrawReq(1)
		return
	end

	local rotate_by1 = cc.RotateBy:create(2, 360 * 5)
	local rotate_by2 = cc.RotateBy:create(1, 360 * 2)
	local callback = cc.CallFunc:create(function ()
		ItemData.Instance:SetDaley(true)
   		OpenServiceAcitivityData.SendOpenServerActGoldDrawReq(1)
	end)
	local callback2 = cc.CallFunc:create(function ()
		self.node_t_list.btn_54_draw.node:setEnabled(true)
	end)
	local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	self.node_t_list.btn_54_draw.node:setEnabled(false)
	self.node_t_list.layout_dzp_point.node:runAction(sequence)
end

OpenServeCZZPLogRender = OpenServeCZZPLogRender or BaseClass(BaseRender)
function OpenServeCZZPLogRender:__init()	
end

function OpenServeCZZPLogRender:__delete()	
end

function OpenServeCZZPLogRender:CreateChild()
	BaseRender.CreateChild(self)
end

function OpenServeCZZPLogRender:OnFlush()
	if self.data == nil then return end
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end

	local str = "{rolename;%s;[%s]}抽中了{wordcolor;1eff00;%s倍}获得{wordcolor;DC143C;%s元宝}"
	local text = string.format(str, self.rolename_color, self.data.name, self.data.multiple_num / 100, self.data.reawrd_gold_num)
	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node,text, 18)
end

function OpenServeCZZPLogRender:CreateSelectEffect()
end


return OpenServeChargeZPView
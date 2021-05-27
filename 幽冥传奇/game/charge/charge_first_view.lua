ChargeFirstView = ChargeFirstView or BaseClass(BaseView)

first_charge_eff_pos = {
	[264] = {x = 740, y = 140},
	[265] = {x = 1100, y = 350},
	[266] = {x = 1100, y = 280},
	[267] = {x = 555, y = 200},
	[70] = {x = 560, y = 190},
	[269] = {x = 550, y = 200},
}

function ChargeFirstView:__init()
	self.is_any_click_close = true
	self.is_modal = true
	self.texture_path_list[1] = 'res/xui/charge.png'
	self.texture_path_list[2] = 'res/xui/out_of_print.png'
	self.config_tab = {
		{"charge_ui_cfg", 1, {0}},
		{"charge_ui_cfg", 2, {0}},
	}
	self.cell_list = {}

	--进入20级boss副本 弹出首冲提示
	self.open_from_tip = false
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, function ()
		if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) <= 70 and Scene.Instance:GetSceneId() == 61 then
			GlobalTimerQuest:AddDelayTimer(function ()
				self.open_from_tip = true
				ViewManager.Instance:OpenViewByDef(ViewDef.ChargeFirst)
			end, 3)	
		end
	end)
end

function ChargeFirstView:__delete()
end

function ChargeFirstView:ReleaseCallBack()
	if nil ~= self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar=nil
	end

	self.charge_eff = nil
	-- self.title_eff = nil
	-- self.song_eff = nil
	-- self.terrace_eff = nil

	self.has_get_fc_gift = nil
end

function ChargeFirstView:OpenCallBack()
	-- ChargeRewardCtrl.SendFirstChargeInfoReq()
	AudioManager.Instance:PlayOpenCloseUiEffect()

	--播放动作
	if self.open_from_tip then
		local root_node = self:GetRootNode()
		root_node:setScale(0.2)
		local back_scale = cc.ScaleTo:create(0.8, 1, 1)
		local end_callback = cc.CallFunc:create(function ()
			self.open_from_tip = false
		end)
		root_node:runAction(cc.Sequence:create(back_scale, end_callback))
	end
end

function ChargeFirstView:LoadCallBack(index, loaded_times)
	self.profession_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)	 --职业
	XUI.AddClickEventListener(self.node_t_list.layout_first_charge_btn.node, BindTool.Bind(self.OnClickTransmitHandler, self), true)
	XUI.AddClickEventListener(self.node_t_list.layout_get_first_gift_btn.node, BindTool.Bind(self.OnClickGetGift, self), true)
	self.node_t_list.layout_first_charge_btn.node:setVisible(false)
	self.node_t_list.layout_get_first_gift_btn.node:setVisible(false)

	self:InitTabbar()
	self:CreateNumber()

	self.get_gift_btn_eff = RenderUnit.CreateEffect(1156, self.node_t_list.layout_get_first_gift_btn.node, 10, nil, nil, 110, 30)
	self.get_gift_btn_eff:setScaleX(self.node_t_list.layout_get_first_gift_btn.node:getContentSize().width / self.node_t_list.layout_first_charge_btn.node:getContentSize().width)
	self.node_t_list.layout_get_first_gift_btn.img_txt.node:setLocalZOrder(20)

	EventProxy.New(ChargeRewardData.Instance, self):AddEventListener(ChargeRewardData.FirstDataChangeEvent, BindTool.Bind(self.OnFirstChargeChange, self))
end

function ChargeFirstView:CreateWuQiEffect(index)
	local wuqi_res_id = ChargeRewardData.Instance:GetWuqiResId(index)
	if nil ~= self.wuqi_eff then
		self.node_t_list.layout_first_charge.node:removeChild(self.wuqi_eff)
	end
	local eff_pos_x = first_charge_eff_pos[wuqi_res_id].x
	local eff_pos_y = first_charge_eff_pos[wuqi_res_id].y
	self.wuqi_eff = RenderUnit.CreateEffect(wuqi_res_id, self.node_t_list.layout_first_charge.node, 10, nil, nil, eff_pos_x, eff_pos_y)
end

function ChargeFirstView:ShowIndexCallBack(index)
	local index = ChargeRewardData.Instance:GetFirstChargeAutoJumpIndex()
	self.tabbar:SelectIndex(index)
	self:OnFlushPanel()
end

function ChargeFirstView:InitTabbar()
	if nil == self.tabbar then
		local group = {}
		local recharge_rate = ChongzhiData.Instance:GetRechargeRate()
		local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift or {}
		local cur_cfg = cfg[1] and cfg[1].rewardGrade or {}
		for i,v in ipairs(cur_cfg) do
			if v.payMinYb then
				local title = ""
				if v.payMinYb <= 1 then
					title = "任意金额"
				else
					title = (v.payMinYb / recharge_rate) .. "元"
				end
				table.insert(group, title)
			end
		end

		-- self.tabbar_group = {ResPath.GetCharge("tabbar_toggle_1_normal"), ResPath.GetCharge("tabbar_toggle_2_normal"),ResPath.GetCharge("tabbar_toggle_3_normal")}		
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.layout_first_charge.node, 40, self.ph_list.ph_tabbar.y - 20,
		BindTool.Bind(self.TabSelectCallBack, self), group, false, ResPath.GetCharge("tabbar_toggle"))
		self.tabbar:SetSpaceInterval(8)
		self.tabbar:GetView():setLocalZOrder(1)
	end
end

function ChargeFirstView:CreateNumber()
	local ph = self.ph_list["ph_charge_num"]
	local path = ResPath.GetCharge("num_")
	local parent = self.node_t_list["layout_first_charge"].node
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-7)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.number = number_bar
	self:AddObj("number")
end

function ChargeFirstView:OnFlushPanel()
	if ChargeRewardData.Instance:GetFirstChargeIsAllGet() then
		ViewManager.Instance:CloseViewByDef(ViewDef.ChargeFirst)
	end

	local recharge_rate = ChongzhiData.Instance:GetRechargeRate()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift or {}
	local cur_cfg = cfg[1] and cfg[1].rewardGrade or {}
	local index = self.tabbar:GetCurSelectIndex()
	local cur_gole = cur_cfg[index] and cur_cfg[index].payMinYb or 1
	local cur_yuan = math.max(cur_gole / recharge_rate, 1)

	if index == 1 then
		self.node_t_list["img_charge_num"].node:setVisible(true)
		self.node_t_list["img_yuan"].node:setVisible(false)
		self.number:SetVisible(false)
		self.node_t_list.img_charge_num.node:loadTexture(ResPath.GetCharge("any_amount"))
		self.node_t_list.img_word_list3.node:loadTexture(ResPath.GetCharge("change_bg_4"))
	elseif index == 2 then
		self.number:SetVisible(true)
		self.number:SetNumber(cur_yuan)

		self.node_t_list["img_charge_num"].node:setVisible(false)
		self.node_t_list["img_yuan"].node:setVisible(true)
		self.node_t_list.img_word_list3.node:loadTexture(ResPath.GetCharge("change_bg_9"))
	elseif index == 3 then
		self.number:SetVisible(true)
		self.number:SetNumber(cur_yuan)
		self.node_t_list["img_charge_num"].node:setVisible(false)
		self.node_t_list["img_yuan"].node:setVisible(true)
		self.node_t_list.img_word_list3.node:loadTexture(ResPath.GetCharge("change_bg_10"))
	end

	for i,v in pairs(ChargeRewardData.Instance:GetFirstChargeGiftIdentificationData()) do
		if v == 2 then
			self.tabbar:SetToggleVisible(i,false)
		end
	end
	self:CreateWuQiEffect(index)
	self:OnFlushItem()
	self:OnFlushBtnState()
end

function ChargeFirstView:OnFlushItem()
	local index = self.tabbar:GetCurSelectIndex()
	local data = ChargeRewardData.Instance:GetFirstChargeRewardData(index)
	if nil == data then return end
	for k,v in pairs(self.cell_list) do
		v:SetVisible(false)
		v.cell_effect:setVisible(false)
	end

	local num = #data
	local ph = self.ph_list["ph_fc_cell"]
	local total_width = num * ph.w + (num - 1) * 8
	local x, y = 0, 0
	for i = 1, num do
		local cell = self.cell_list[i]
		x, y = ((ph.w + 8) * (i - 1) + ph.w ) + (ph.x - total_width / 2), ph.y
		if cell then
			cell:SetVisible(true)
		else
			cell = BaseCell.New()
			local cell_effect = AnimateSprite:create()
			self.node_t_list.layout_first_charge.node:addChild(cell_effect, 6)
			cell_effect:setVisible(false)
			cell.cell_effect = cell_effect
			table.insert(self.cell_list, cell)
			self.node_t_list.layout_first_charge.node:addChild(cell:GetView(), 5)
		end
		cell:SetPosition(x, y)
		cell.cell_effect:setPosition(x - 1, y-4)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetCellBg(ResPath.GetCommon("cell_110"))
		cell:SetData(data[i])
		local path, name = ResPath.GetEffectUiAnimPath(929)
		if path and name then
			cell.cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.23, false)
			cell.cell_effect:setVisible(data[i].show_eff ~= 0)
		else
			cell.cell_effect:setVisible(false)
		end
	end
end

-- function ChargeFirstView:OnFlushBtnState()
-- 	local index = self.tabbar:GetCurSelectIndex()
-- 	local tag = ChargeRewardData.Instance:GetFirstChargeGiftIdentificationData()[index]
-- 	self.node_t_list.layout_first_charge_btn.node:setVisible(false)
-- 	self.node_t_list.layout_get_first_gift_btn.node:setVisible(false)
-- 	local is_charge = ChargeRewardData.Instance:GetFirstChargeAutoJumpIndex() ~= 0
-- 	if not is_charge then
-- 		self.node_t_list.layout_first_charge_btn.node:setVisible(true)
-- 		self.charge_eff:setVisible(true)
-- 	else
-- 		self.node_t_list.layout_get_first_gift_btn.node:setVisible(true)
-- 		self.node_t_list.layout_get_first_gift_btn.node:setEnabled(true)
-- 		XUI.SetLayoutImgsGrey(self.node_t_list.layout_get_first_gift_btn.node, false)
-- 		self.charge_eff:setVisible(false)
-- 	end

-- 	if 2 == tag or 0 == tag then
-- 		self.node_t_list.layout_get_first_gift_btn.node:setEnabled(false)
-- 		XUI.SetLayoutImgsGrey(self.node_t_list.layout_get_first_gift_btn.node, true)
-- 	end
-- end

function ChargeFirstView:OnFlushBtnState()
	local index = self.tabbar:GetCurSelectIndex()
	local is_charge = ChargeRewardData.Instance:GetFirstChargeGiftIdentificationData()[index] == 1
	self.node_t_list.layout_first_charge_btn.node:setVisible(not is_charge)
	self.node_t_list.layout_get_first_gift_btn.node:setVisible(is_charge)
end

function ChargeFirstView:OnFirstChargeChange()
	local auto_jump_index = ChargeRewardData.Instance:GetFirstChargeAutoJumpIndex()
	if 0 == auto_jump_index then 
		self.tabbar:SelectIndex(1)
	elseif nil ~= auto_jump_index then
		self.tabbar:SelectIndex(auto_jump_index)
	end
	self:OnFlushPanel()
end

function ChargeFirstView:TabSelectCallBack(index)
	self:OnFlushPanel()
end

function ChargeFirstView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChargeFirstView:OnFlush(param_t, index)
end

function ChargeFirstView:OnClickTransmitHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

function ChargeFirstView:OnClickGetGift()
	self.has_get_fc_gift = not (ChargeRewardData.Instance:GetFirstChargeGiftIdentificationData()[self.tabbar:GetCurSelectIndex()] == 1)
	if not self.has_get_fc_gift then
		ChargeRewardCtrl.SendGetFirstChargeAwardReq(self.tabbar:GetCurSelectIndex())
	end
end

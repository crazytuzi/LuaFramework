-- require("scripts/game/operate_activity/spring_festival/charge_give_gift")
-- require("scripts/game/operate_activity/spring_festival/consume_give_gift")
-- require("scripts/game/operate_activity/spring_festival/spring_addup_login")
-- require("scripts/game/operate_activity/spring_festival/yb_send_gift")
-- require("scripts/game/operate_activity/spring_festival/prospery_red_enev")
-- require("scripts/game/operate_activity/spring_festival/addup_recharge_payback")

------------------------------------------------------------
-- 运营活动新春活动View
------------------------------------------------------------
SpringFestivalActView = SpringFestivalActView or BaseClass(XuiBaseView)

function SpringFestivalActView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/limit_activity.png'
	self.texture_path_list[2] = 'res/xui/charge.png'
	self.texture_path_list[3] = "res/xui/welfare.png"
	self.texture_path_list[4] = 'res/xui/vip.png'
	self.texture_path_list[5] = 'res/xui/openserviceacitivity.png'
	-- self.texture_path_list[6] = 'res/xui/operate_activity.png'
	-- self.texture_path_list[7] = 'res/xui/boss.png'
	-- self.texture_path_list[8] = 'res/xui/shangcheng.png'
	-- self.texture_path_list[9] = 'res/xui/skill.png'
	-- self.texture_path_list[10] = 'res/xui/combineserveractivity.png'
	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"spring_festival_act_ui_cfg", 1, {0}},
		{"spring_festival_act_ui_cfg", 2, {TabIndex.operact_spring_addup_login}},
		{"spring_festival_act_ui_cfg", 3, {TabIndex.operact_charge_give}},
		{"spring_festival_act_ui_cfg", 4, {TabIndex.operact_consume_give}},	

		{"spring_festival_act_ui_cfg", 5, {TabIndex.operact_yb_send_gift}},
		{"spring_festival_act_ui_cfg", 6, {TabIndex.operact_prospery_red_enev}},
		{"spring_festival_act_ui_cfg", 7, {TabIndex.operact_addup_recharge_payback}},
		
	}
	
	-- 页面表
	self.page_list = {}
	self.page_list[TabIndex.operact_spring_addup_login] = SpringAddupLoginPage.New()					--新春大礼
	self.page_list[TabIndex.operact_charge_give] = SpringChargeGiveGiftPage.New()						--充值送礼
	self.page_list[TabIndex.operact_consume_give] = SpringConsumeGiveGiftPage.New()						--消费送礼
	self.page_list[TabIndex.operact_yb_send_gift] = SpringYBSendGiftPage.New()							--元宝献礼
	self.page_list[TabIndex.operact_prospery_red_enev] = SpringProsperyRedEnvePage.New()				--旺旺红包
	self.page_list[TabIndex.operact_addup_recharge_payback] = SpringAddupChargePayPage.New()			--累充返利

	self.selec_index = 1
	self.selec_act_id = 1
	self.remind_temp = {}
end

function SpringFestivalActView:__delete()

end

function SpringFestivalActView:ReleaseCallBack()
	-- 清理页面生成信息
	for k, v in pairs(self.page_list) do
		v:DeleteMe()
	end

	if self.sports_type_act_page then
		self.sports_type_act_page:DeleteMe()
	end

	if self.btns_list then
		self.btns_list:DeleteMe()
		self.btns_list = nil
	end

	if self.del_act_evt then
		GlobalEventSystem:UnBind(self.del_act_evt)
		self.del_act_evt = nil
	end

	if self.add_act_evt then
		GlobalEventSystem:UnBind(self.add_act_evt)
		self.add_act_evt = nil
	end

	self.selec_index = 1
end

function SpringFestivalActView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateBtnsList()
		self.del_act_evt = GlobalEventSystem:Bind(OperateActivityEventType.DELETE_CLOSE_ACT, BindTool.Bind(self.SetBtnsListData, self))
		self.add_act_evt = GlobalEventSystem:Bind(OperateActivityEventType.ADD_OPEN_ACT, BindTool.Bind(self.SetBtnsListData, self))
	end
	if self.page_list[index] then
		-- 初始化页面接口
		self.page_list[index]:InitPage(self)
	end
	
end

function SpringFestivalActView:OpenCallBack()
	if self.btns_list then
		self.btns_list:SelectIndex(1)
		self.btns_list:AutoJump()
		-- self:ChangeToIndex(self.selec_index)
	end
end

function SpringFestivalActView:CloseCallBack()
	
end

function SpringFestivalActView:ShowIndexCallBack(index)
	self:Flush(index)
end

function SpringFestivalActView:OnFlush(param_t, index)
	if nil ~= self.page_list[index] then
		-- 更新页面接口
		self.page_list[index]:UpdateData(param_t)
	end

	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushRemind()
		elseif k == "flush_remind" then
			self:FlushRemind()
		end
	end

end

function SpringFestivalActView:CreateBtnsList()
	if nil == self.btns_list then
		local ph = self.ph_list.ph_btns_list
		self.btns_list = ListView.New()
		self.btns_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActBtnRender, nil, nil, self.ph_list.ph_btn_item)
		self.btns_list:SetItemsInterval(5)
		self.btns_list:GetView():setAnchorPoint(0, 0)
		self.btns_list:SetJumpDirection(ListView.Top)
		self.btns_list:SetIsUseStepCalc(false)
		self.btns_list:SetSelectCallBack(BindTool.Bind(self.SelectItemCallback, self))
		self.node_t_list.layout_scroll.node:addChild(self.btns_list:GetView(), 20)
		self:SetBtnsListData()
	end
end

function SpringFestivalActView:SelectItemCallback(item, index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	self.selec_index = index
	self.selec_act_id = data.act_id
	self:ChangeToIndex(data.act_id)
	self:Flush(data.act_id)
end

function SpringFestivalActView:SetBtnsListData()
	if not self.btns_list then return end
	local btn_data_list = OperateActivityData.Instance:GetSpringFestivalActList()
	self.btns_list:SetData(btn_data_list)
	if btn_data_list and next(btn_data_list) then
		self.btns_list:SelectIndex(math.min(self.selec_index, #btn_data_list))
	else
		self:Close()
	end
end

function SpringFestivalActView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name)
	end
end

function SpringFestivalActView:FlushRemind()
	if not self.btns_list then return end
	local remind_list = OperateActivityData.Instance:GetRemindList()
	for k, v in pairs(self.btns_list:GetAllItems()) do
		if v and v:GetData() then
			local data = v:GetData()
			v:SetRemindVis(remind_list[data.act_id])
		end
	end
end

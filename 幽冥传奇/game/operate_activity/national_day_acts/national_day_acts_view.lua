require("scripts/game/operate_activity/national_day_acts/nati_login_send_gift")
require("scripts/game/operate_activity/national_day_acts/nati_boss_treasure")
require("scripts/game/operate_activity/national_day_acts/nati_defend_city")
require("scripts/game/operate_activity/national_day_acts/nati_rotate_panel_award")
require("scripts/game/operate_activity/national_day_acts/nati_legendry_reputation")

------------------------------------------------------------
-- 国庆活动View
------------------------------------------------------------
NationalDayActsView = NationalDayActsView or BaseClass(XuiBaseView)

function NationalDayActsView:__init()
	self:SetModal(true)
	self.texture_path_list = {'res/xui/limit_activity.png',
								'res/xui/charge.png',
								'res/xui/welfare.png',
								'res/xui/vip.png',
								'res/xui/openserviceacitivity.png',
								'res/xui/national_day.png',
								'res/xui/shangcheng.png',
							}
	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"national_day_act_ui_cfg", 1, {0}},
		{"national_day_act_ui_cfg", 2, {TabIndex.operact_login_send_gift}},
		{"national_day_act_ui_cfg", 3, {TabIndex.operact_boss_treasure}},
		{"national_day_act_ui_cfg", 4, {TabIndex.operact_defend_city}},	
		{"national_day_act_ui_cfg", 5, {TabIndex.operact_rotate_panel_award}},
		{"national_day_act_ui_cfg", 6, {TabIndex.operact_legendry_reputation}},
		{"national_day_act_ui_cfg", 7, {0}},
		
	}
	
	-- 页面表
	self.page_list = {}
	self.page_list[TabIndex.operact_login_send_gift] = NatiLoginSendGiftPage.New()				-- 登陆送礼(国庆)
	self.page_list[TabIndex.operact_boss_treasure] = NatiBossTreasurePage.New()					-- BOSS宝藏
	self.page_list[TabIndex.operact_defend_city] = NatiDefendCityPage.New()						-- 守卫主城
	self.page_list[TabIndex.operact_rotate_panel_award] = NatiRotatePanelAwardPage.New()		-- 万宝轮盘
	self.page_list[TabIndex.operact_legendry_reputation] = NatiLegendryReputationPage.New()		-- 名动传奇
	self.selec_index = 1
	self.selec_act_id = 1
	self.remind_temp = {}
	self.title_img_path = ResPath.GetNationalDayRes("wnd_title")
end

function NationalDayActsView:__delete()

end

function NationalDayActsView:ReleaseCallBack()
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

function NationalDayActsView:LoadCallBack(index, loaded_times)
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

function NationalDayActsView:OpenCallBack()
	if self.btns_list then
		self.btns_list:SelectIndex(1)
		self.btns_list:AutoJump()
		-- self:ChangeToIndex(self.selec_index)
	end
end

function NationalDayActsView:CloseCallBack()
	
end

function NationalDayActsView:ShowIndexCallBack(index)
	self:Flush(index)
end

function NationalDayActsView:OnFlush(param_t, index)
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

function NationalDayActsView:CreateBtnsList()
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

function NationalDayActsView:SelectItemCallback(item, index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	self.selec_index = index
	self.selec_act_id = data.act_id
	self:ChangeToIndex(data.act_id)
	self:Flush(data.act_id)
end

function NationalDayActsView:SetBtnsListData()
	if not self.btns_list then return end
	local btn_data_list = OperateActivityData.Instance:GetNationalDayActList()
	self.btns_list:SetData(btn_data_list)
	if btn_data_list and next(btn_data_list) then
		self.btns_list:SelectIndex(math.min(self.selec_index, #btn_data_list))
	else
		self:Close()
	end
end

function NationalDayActsView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name)
	end
end

function NationalDayActsView:FlushRemind()
	if not self.btns_list then return end
	local remind_list = OperateActivityData.Instance:GetRemindList()
	for k, v in pairs(self.btns_list:GetAllItems()) do
		if v and v:GetData() then
			local data = v:GetData()
			v:SetRemindVis(remind_list[data.act_id])
		end
	end
end

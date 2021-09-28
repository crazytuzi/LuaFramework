require("game/activity_online/activity_online_toggle_item")
require("game/activity_online/activity_online_danbi_chongzhi/kuanghuan_activity_panel_danbichongzhi_view")
require("game/activity_online/activity_online_total_charge/kuanghuan_activity_panel_total_charge_view")
require("game/activity_online/activity_online_login_reward/activity_panel_login_reward_view")
ActivityOnLineView = ActivityOnLineView or BaseClass(BaseView)

local on_line_prefab_1 = "uis/views/onlineview_prefab"
function ActivityOnLineView:__init()
	self.ui_config = {on_line_prefab_1, "OnLineView"}

	self.full_screen = true
	self.is_async_load = false
	self.toggle_group = {}
	self.click_toggle_tab = 0

	self.is_async_load_panel = {}
end

function ActivityOnLineView:__delete()
end

function ActivityOnLineView:LoadCallBack()
	--obj
	self.list_view = self:FindObj("ToggleList")
	local delegate = self.list_view.list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleNumber, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshToggleCell, self)
	self.right_content = self:FindObj("RightContent")

	self.child_panel = {
		--单笔充值
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "KuangHuanDanBiChongZhiContent",
			view_class = KuanHuanActivityPanelDanBiChongZhiView,
			flush_paramt = {["danbi"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0,
			view = nil,
			show_once = true,
			remind_name = RemindName.OnLineDanBi,
			remind_time = 0,
			send_req_mathod = nil,
		},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "KuangHuanDanBiChongZhiContent",
			view_class = KuanHuanActivityPanelDanBiChongZhiView,
			flush_paramt = {["danbi"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1,
			view = nil,
			remind_name = RemindName.OnLineDanBi,
			show_once = true,
			remind_time = 0,
			send_req_mathod = nil,
		},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "KuangHuanDanBiChongZhiContent",
			view_class = KuanHuanActivityPanelDanBiChongZhiView,
			flush_paramt = {["danbi"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2,
			view = nil,
			remind_name = RemindName.OnLineDanBi,
			show_once = true,
			remind_time = 0,
			send_req_mathod = nil,
		},

		--累计充值
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "KuangHuanTotalChargeContent",
			view_class = KuangHuanTotalChargeView,
			flush_paramt = {["totalcharge"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0,
			view = nil,
			remind_name = RemindName.OffLineTotalCharge,
			show_once = true,
			remind_time = 0,
			send_req_mathod = nil,
		},	
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "KuangHuanTotalChargeContent",
			view_class = KuangHuanTotalChargeView,
			flush_paramt = {["totalcharge"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1,
			view = nil,
			remind_name = RemindName.OffLineTotalCharge,
			show_once = true,
			remind_time = 0,
			send_req_mathod = nil,
		},	
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "KuangHuanTotalChargeContent",
			view_class = KuangHuanTotalChargeView,
			flush_paramt = {["totalcharge"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2,
			view = nil,
			remind_name = RemindName.OffLineTotalCharge,
			show_once = true,
			remind_time = 0,
			send_req_mathod = nil,
		},			
		--登录有礼
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "LoginRewardContent",
			view_class = ActivityPanelLogicRewardView,
			flush_paramt = {["login_reward"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0,
			view = nil,
			remind_name = RemindName.RewardGift0,
			remind_time = 0,
			send_req_mathod = nil,
		},	

		--登录有礼
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "LoginRewardContent",
			view_class = ActivityPanelLogicRewardView,
			flush_paramt = {["login_reward"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1,
			view = nil,
			remind_name = RemindName.RewardGift1,
			remind_time = 0,
			send_req_mathod = nil,
		},	
		
		--登录有礼
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2] = {
			prefab_1 = on_line_prefab_1,
			prefab_2 = "LoginRewardContent",
			view_class = ActivityPanelLogicRewardView,
			flush_paramt = {["login_reward"] = true,},
			toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2,
			view = nil,
			remind_name = RemindName.RewardGift2,
			remind_time = 0,
			send_req_mathod = nil,
		},	
	}

    self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
    self.list_view.scroller:ReloadData(0)
end

function ActivityOnLineView:ReleaseCallBack()
	for k, v in pairs(self.child_panel) do
		if v.view then
			v.view:DeleteMe()
		end
	end

	self.click_toggle_tab = 0

	if self.toggle_group then
		for k,v in pairs(self.toggle_group) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.toggle_group = nil
	end

	self.toggle_group = {}

	self.is_async_load_panel = {}

	self:CancelAllTimeQuest()

	self.list_view = nil
	self.right_content = nil
end

function ActivityOnLineView:OpenCallBack()
	self:Flush()
end

function ActivityOnLineView:CloseCallBack()
end

function ActivityOnLineView:SetRendering(value)
	BaseView.SetRendering(self, value)
	self:Flush()
end

function ActivityOnLineView:OnFlush(param_t)
	local cfg = self.child_panel[self.click_toggle_tab]
	if cfg and cfg.view then
		if param_t then
			for k,v in pairs(param_t) do
				if cfg.flush_paramt[k] then
					cfg.view:Flush(k)
				elseif k == "toggle" then
					self:ActivityStatusChangeClick()
					self.list_view.scroller:ReloadData(0)
				else
					cfg.view:Flush()
				end
			end
		end
	end
	if 0 == self.click_toggle_tab then
		self:OnClickTab(ActivityOnLineData.Instance:GetFirstOpenActivity())
	end
end

function ActivityOnLineView:ActivityStatusChangeClick()
	local cfg = ActivityOnLineData.Instance:GetActivityOpenList()
	if nil == cfg then
		return
	end

	for k,v in pairs(cfg) do
		if v.act_id == self.click_toggle_tab then
			if v.status == ACTIVITY_STATUS.CLOSE then
				self:OnClickTab(ActivityOnLineData.Instance:GetFirstOpenActivity())
			end
		end
	end
end

function ActivityOnLineView:GetToggleNumber()
	return ActivityOnLineData.Instance:GetActivityOpenNum()
end

function ActivityOnLineView:RefreshToggleCell(cell, data_index)
	data_index = data_index + 1
	local toggle_cell = self.toggle_group[cell]

	if nil == toggle_cell then
		toggle_cell = OnLineActivityToggleItem.New(cell)
		self.toggle_group[cell] = toggle_cell
	end
	local open_list = ActivityOnLineData.Instance:GetActivityOpenListByIndex(data_index)
	if nil == open_list then
		return
	end

	toggle_cell:SetActId(open_list.act_id)
	--打开默认面板第一个
	toggle_cell:ListenClick(BindTool.Bind(self.OnClickTab, self, open_list.act_id))

	toggle_cell:FlushHl(self.click_toggle_tab)

	toggle_cell:SetBindRedPoint(self.child_panel[open_list.act_id].remind_name)
	toggle_cell:SetIndex(data_index)
	toggle_cell:SetData(open_list)
end

function ActivityOnLineView:AsyncLoadView(tab)
	local cfg = self.child_panel[tab]
	if nil == cfg then
		return
	end

	local last_view = self.child_panel[self.click_toggle_tab]
	if last_view ~= nil and nil ~= last_view.view then
		last_view.view:SetActive(false)
	end

	self.click_toggle_tab = tab

	if cfg.view == nil then
		if self.is_async_load_panel[tab] then
			return
		end

		self.is_async_load_panel[tab] = true

		UtilU3d.PrefabLoad(cfg.prefab_1, cfg.prefab_2,
			function(prefab)
				prefab.transform:SetParent(self.right_content.transform, false)
				prefab = U3DObject(prefab)
				cfg.view = cfg.view_class.New(prefab)
				cfg.view:SetActId(tab)
				if cfg.toggle_index ~= self.click_toggle_tab then
					cfg.view:SetActive(false)
				else
					cfg.view:OpenCallBack()			
				end
				
				if cfg.show_once then
					cfg.view:PanelClick()
				end	
			end)
	else
		cfg.view:SetActive(true)
		cfg.view:Flush()
	end
end

-- function ActivityOnLineView:FlushRedPoint()
-- 	local list = ActivityOnLineData.Instance:GetActivityOpenList()

-- 	for k,v in pairs(list) do
-- 		if v.status == ACTIVITY_STATUS.OPEN then
-- 			RemindManager.Instance:Fire(ActivityOnLineData.RemindName_From_Id[v.act_id])
-- 		end
-- 	end
-- end

function ActivityOnLineView:OnClickTab(tab)
	if tab == self.click_toggle_tab or nil == self.child_panel[tab] then
		return
	end

	local cfg = self.child_panel[tab]
	if nil ~= cfg.send_req_mathod then
		cfg.send_req_mathod()
	end

	self:AsyncLoadView(tab)
	self:FlushHl()

	if cfg.show_once then
		RemindManager.Instance:SetRemindToday(cfg.remind_name)
	end

	if cfg and cfg.remind_name and cfg.remind_time 
		and cfg.remind_time > 0 and RemindManager.Instance:GetRemind(cfg.remind_name) > 0 then
		RemindManager.Instance:AddNextRemindTime(cfg.remind_name, cfg.remind_time)
	end	
end

function ActivityOnLineView:FlushHl()
	for k,v in pairs(self.toggle_group) do
		if v then
			v:FlushHl(self.click_toggle_tab)
		end
	end
end

function ActivityOnLineView:CloseView()
	self:Close()
end

function ActivityOnLineView:ShowIndexCallBack(tab)
	self:OnClickTab(tab)
end

function ActivityOnLineView:CancelAllTimeQuest()

end
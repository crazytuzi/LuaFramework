require("scripts/game/limitedactivity/limitedactivity_yh_page")
require("scripts/game/limitedactivity/limitedactivity_cz_page")
require("scripts/game/limitedactivity/limitedactivity_xf_page")

------------------------------------------------------------
-- 限时活动View
------------------------------------------------------------
LimitedActivityView = LimitedActivityView or BaseClass(XuiBaseView)

function LimitedActivityView:__init()
	self:SetModal(true)
	self.def_index = TabIndex.limitedactivity_yh

	self.texture_path_list[1] = 'res/xui/limit_activity.png'
	self.texture_path_list[2] = 'res/xui/boss.png'
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"common_ui_cfg", 1, {0}},
		{"limitedactivity_ui_cfg", 1, {TabIndex.limitedactivity_cz}},
		{"limitedactivity_ui_cfg", 2, {TabIndex.limitedactivity_xf}},
		{"limitedactivity_ui_cfg", 3, {TabIndex.limitedactivity_yh}},	
		{"limitedactivity_ui_cfg", 4, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	-- 页面表
	self.page_list = {}
	self.page_list[TabIndex.limitedactivity_yh] = LimitedActivityYhPage.New()
	self.page_list[TabIndex.limitedactivity_cz] = LimitedActivityCzPage.New()
	self.page_list[TabIndex.limitedactivity_xf] = LimitedActivityXfPage.New()

	self.remind_temp = {}

end

function LimitedActivityView:__delete()

end

function LimitedActivityView:ReleaseCallBack()
	-- 清理页面生成信息
	for k, v in pairs(self.page_list) do
		v:DeleteMe()
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function LimitedActivityView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.tabbar = ScrollTabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 0, 0,
				BindTool.Bind1(self.SelectTabCallback, self), Language.Limited.Name, 
				true, ResPath.GetCommon("btn_106_normal"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		
	end

	if nil == self.page_list[index] then
		return
	end

	-- 初始化页面接口
	self.page_list[index]:InitPage(self)
end

function LimitedActivityView:OpenCallBack()
	-- LimitedActivityCtrl.Instance:SendChongzhjiReq()
	-- LimitedActivityCtrl.Instance:SendXiaofeiReq()
end

function LimitedActivityView:CloseCallBack()
	
end

function LimitedActivityView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index, self.root_node)
	self:Flush(index)
end

function LimitedActivityView:OnFlush(param_t, index)
	if nil ~= self.page_list[index] then
		-- 更新页面接口
		self.page_list[index]:UpdateData(param_t)
	end
	for k, v in pairs(param_t) do
		if k == "tab_vis" then
			self:SetTabbarVis(v)
		end
	end
end

function LimitedActivityView:SelectTabCallback(index)
	-- self.tabbar:ChangeToIndex(index)
	self:ChangeToIndex(index)
end

function LimitedActivityView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name)
	end
end

function LimitedActivityView:SetTabbarVis(close_data)
	--print("设置按钮显示状态")
	--PrintTable(close_data)
	for i = TabIndex.limitedactivity_yh, TabIndex.limitedactivity_xf do
		self.tabbar:SetToggleVisible(i, not close_data[i + 2])
	end
	local index = TabIndex.limitedactivity_yh
	
	
	if close_data[BACK_STAGE_TIMER_ACTIVITY_ID.TIME_LIMITED_GOODS] then
		if close_data[BACK_STAGE_TIMER_ACTIVITY_ID.ACCUMULATE_RECHARGE] then
			index = TabIndex.limitedactivity_xf
		else
			index = TabIndex.limitedactivity_cz
		end
	elseif close_data[BACK_STAGE_TIMER_ACTIVITY_ID.ACCUMULATE_RECHARGE] then
		if close_data[BACK_STAGE_TIMER_ACTIVITY_ID.TIME_LIMITED_GOODS] then
			index = TabIndex.limitedactivity_xf
		else
			index = TabIndex.limitedactivity_yh
		end
	elseif close_data[BACK_STAGE_TIMER_ACTIVITY_ID.ACCUMULATE_SPEND] then
		if close_data[BACK_STAGE_TIMER_ACTIVITY_ID.TIME_LIMITED_GOODS] then
			index = TabIndex.limitedactivity_cz
		else
			index = TabIndex.limitedactivity_yh
		end
	end
	self.tabbar:ChangeToIndex(index)
	self:ChangeToIndex(index)
	-- self.node_t_list.layout_recharge.node:setVisible(not closeActs[TabIndex.limitedactivity_cz])
	-- self.node_t_list.layout_consume.node:setVisible(not closeActs[TabIndex.limitedactivity_xf])
	-- self.node_t_list.layout_discount.node:setVisible(not closeActs[TabIndex.limitedactivity_yh])
end

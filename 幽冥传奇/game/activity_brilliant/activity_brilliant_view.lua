
OperationActivityView = OperationActivityView or BaseClass(BaseView)

function OperationActivityView:__init(index)
	self.view_index = self.view_def.view_index or 1
	
	self:SetModal(true)
	self:SetBackRenderTexture(true)

	self.title_img_path = ResPath.GetWord("word_brillant_activity_0")
	self.texture_path_list = {
		"res/xui/activity_brilliant.png",
		"res/xui/act_84_93.png",
		"res/xui/act_73_83.png",
		"res/xui/combind.png",
		"res/xui/vip.png",
		"res/xui/shangcheng.png",
		"res/xui/openserviceacitivity.png",
		"res/xui/privilege.png",
		"res/xui/rankinglist.png",
		"res/xui/zs_vip.png",
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"activity_brilliant_ui_cfg", 1, {0}},
		{"activity_brilliant_ui_cfg", 2, {0}, false},
		{"activity_brilliant_ui_cfg", 3, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.sub_view_act_id = nil
	self.activity_list = nil
	self.sub_view_list = {}
	self.item_config_callback = BindTool.Bind(self.ItemConfigCallback, self)
	self.bag_item_change = BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE,BindTool.Bind(self.UptateTabbarRemind, self))
end

function OperationActivityView:__delete()
end

function OperationActivityView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ActivityBrilliantCtrl.Instance:OpenActDataReq()
	ItemData.Instance:NotifyItemConfigCallBack(self.item_config_callback)
end

function OperationActivityView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	-- if self.sub_view_act_id and self.sub_view_list[self.sub_view_act_id] then
	-- 	self.sub_view_list[self.sub_view_act_id]:CloseCallback()
	-- end
	for k,v in pairs(self.sub_view_list) do
		if v.CloseCallBack then
			v:CloseCallBack()
		end
	end

	self.sub_view_act_id = nil
	ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_callback)
	if BagData.Instance then
		BagData.Instance:RemoveEventListener(self.bag_item_change)
	end
end

function OperationActivityView:ReleaseCallBack()
	if nil ~= self.activity_list then
		self.activity_list:DeleteMe()
		self.activity_list = nil
	end

	for k, v in pairs(self.sub_view_list) do
		v:DeleteMe()
	end
	self.sub_view_list = {}

	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end

	self.sub_view_act_id = nil
	self.common_tips_btn = nil
end

function OperationActivityView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:LoadCommonTopBg()
		self:CreateTopTitle()
		self:CreateActivityList()

		XUI.EnableOutline(self.node_t_list.layout_common_right_panel.lbl_activity_about.node)
	end
end

function OperationActivityView:ShowIndexCallBack(index)
	self:SelectActByActId()
	self:Flush()
end

function OperationActivityView:OnFlush(param_list, index)
	for k,v in pairs(param_list) do
		if k == "all" then
		elseif k == "tabbar" then
			self.activity_list:SetDataList(ActivityBrilliantData.Instance:GetTabbarNameList(self.view_index))
		elseif k == "flush_remind" then
			-- self:UptateTabbarRemind()
		elseif k == "flush_view" then
			if nil ~= v.act_id and nil ~= self.sub_view_list[v.act_id] then
				self.sub_view_list[v.act_id]:RefreshView(param_list)
			end
		end
	end
	self:UptateTabbarRemind()
end

function OperationActivityView:ItemConfigCallback(...)
	local cur_sub_view = self.sub_view_list[self.sub_view_act_id]
	if cur_sub_view and cur_sub_view.ItemConfigCallback then
		cur_sub_view:ItemConfigCallback(...)
	end
end

function OperationActivityView:LoadCommonTopBg()
	local size = self.node_t_list.layout_common_right_panel.node:getContentSize()
	local res_id = ActivityBrilliantData.Instance:GetActViewResId(self.view_index)
	local path = ResPath.GetBigPainting(string.format("brilliant_act_top_bg_%d", res_id))
	-- local img = XUI.CreateImageView(size.width / 2, size.height / 2, path)
	-- self.node_t_list.layout_common_right_panel.node:addChild(img, -1)
	self.node_t_list["img_bg"].node:loadTexture(path)

	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end
	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)

	self.title_img_path = ResPath.GetWord("word_brillant_activity_" .. res_id)
end

function OperationActivityView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.sub_view_act_id)
	if nil == cfg then
		return
	end
	local time = cfg.end_time
	if time == nil then
		time = cfg.end_openday or cfg.end_combineday
	end
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combind_days = OtherData.Instance:GetCombindDays()
	if cfg.end_openday ~= nil then
		time = (cfg.end_openday-open_days) * 86400 + (TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime()))
	elseif cfg.end_combineday then
		time = (cfg.end_combineday-combind_days) * 86400 + (TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime()))
	end
	local sub_act_view = self.sub_view_list[self.sub_view_act_id]
	if sub_act_view and sub_act_view.UpdateSpareTime then
		sub_act_view:UpdateSpareTime(time)
	else
		local now_time = TimeCtrl.Instance:GetServerTime()
		local str = TimeUtil.FormatSecond2Str(time - now_time)
		self.node_t_list.layout_common_right_panel.lbl_activity_spare_time.node:setString(str)
	end
end

function OperationActivityView:CreateActivityList()
	if nil == self.activity_list then
		local ph = self.ph_list.ph_list_view
		self.activity_list = ListView.New()
		self.activity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperationActivityRender, nil, nil, self.ph_list.ph_activity_item)
		self.activity_list:SetItemsInterval(10)
		self.activity_list:SetJumpDirection(ListView.Top)
		self.activity_list:SetSelectCallBack(BindTool.Bind(self.SelectActivityListCallback, self))
		self.node_t_list.layout_activity_brilliant_bg.node:addChild(self.activity_list:GetView(), 20)
	end

	self:InitActListData()
end

function OperationActivityView:InitActListData()
	local list = ActivityBrilliantData.Instance:GetTabbarNameList(self.view_index)
	self.activity_list:SetDataList(list)
	self:ActListSelectActByActId(self.sub_view_act_id)
end

-- 列表选中
function OperationActivityView:ActListSelectActByActId(act_id)
	local index = 1
	if nil ~= act_id then
		for k, v in pairs(self.activity_list:GetDataList()) do
			if v.act_id == act_id then
				index = k
				break
			end
		end
	end
	
	self.activity_list:SelectIndex(index)
end

function OperationActivityView:SelectActivityListCallback(render)
	if render == nil then return end
	local act_id = render:GetData().act_id
	self:Flush(0, "flush_view", {act_id = act_id})
	self:SelectActByActId(act_id)
end

function OperationActivityView:SelectActByActId(act_id)
	if nil == act_id then
		self.activity_list:SelectIndex(1)
		return
	end

	if nil ~= self.sub_view_act_id and act_id == self.sub_view_act_id then
		return
	end

	if nil ~= self.sub_view_act_id then
		self.sub_view_list[self.sub_view_act_id]:SwitchIndexView()
	end

	self.sub_view_act_id = act_id
	for k, v in pairs(self.sub_view_list) do
		v:SetVisible(false)
	end

	if nil == self.sub_view_list[act_id] then
		local sub_view_class = OPER_ACT_CLIENT_CFG[act_id].sub_view_class
		if nil == sub_view_class then
			ErrorLog(string.format("OperationActivityView no sub_view_class !, act_id : %d", act_id))
			return
		end
		self.sub_view_list[act_id] = sub_view_class.New(self, self.node_t_list.layout_act_panel.node, act_id)
	end

	self.sub_view_list[act_id]:SetVisible(true)
	self.sub_view_list[act_id]:ShowIndexView()
	self:FlushCommonTopView()
end

function OperationActivityView:FlushCommonTopView()
	local client_act_cfg = OPER_ACT_CLIENT_CFG[self.sub_view_act_id]
	local vis = true
	if nil ~= client_act_cfg then
		if nil ~= client_act_cfg.is_show_top_view then
			vis = client_act_cfg.is_show_top_view
		end
		self.node_t_list.layout_common_right_panel.node:setVisible(vis)
	end

	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.sub_view_act_id)
	if nil == cfg then
		return
	end

	local act_desc = Split(cfg.act_desc, "#")
	if not vis then
		-- 子View需要自己顶部栏
		if self.sub_view_act_id ~= nil and self.sub_view_list[self.sub_view_act_id].OnFlushTopView then
			self.sub_view_list[self.sub_view_act_id]:OnFlushTopView(cfg.beg_time, cfg.end_time, act_desc)
		end
	else
		local beg_time = os.date("*t", cfg.beg_time)
		local end_time = os.date("*t", cfg.end_time)
		-- local str_time = string.format(Language.ActivityBrilliant.AboutTime, beg_time.month, beg_time.day, beg_time.hour, beg_time.min)
		-- local str_time_2 = string.format(Language.ActivityBrilliant.AboutTime, end_time.month, end_time.day, end_time.hour, end_time.min)
		-- self.node_t_list.layout_common_right_panel.lbl_activity_time.node:setString(str_time .. "-" .. str_time_2)
		self.node_t_list.layout_common_right_panel.lbl_activity_about.node:setString(act_desc[1])
	end


	if nil == self.common_tips_btn then
		self.common_tips_btn = XUI.CreateImageView(0, 0, ResPath.GetCommon("part_100"))
		self.root_node:addChild(self.common_tips_btn, 99)
		XUI.AddClickEventListener(self.common_tips_btn, BindTool.Bind(self.OnClickActTipHandler, self), true)
		self.common_tips_btn:setVisible(false)
	end

	local tips_btn_p = client_act_cfg.tips_btn_p or {}
	self.common_tips_btn:setPosition(tips_btn_p[1] or 1035, tips_btn_p[2] or 580)

	self.common_tips_btn:setVisible((vis and nil ~= act_desc[2]) or nil ~= client_act_cfg.tips_btn_p)
end

function OperationActivityView:OnClickActTipHandler()
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.sub_view_act_id)
	local act_desc = Split(cfg.act_desc, "#") --#号之后为btn_act_tips文本
	DescTip.Instance:SetContent(act_desc[2] or act_desc[1], Language.ActivityBrilliant.ActTip)
end

function OperationActivityView:UptateTabbarRemind()
	if nil == self.activity_list then
		return
	end

	for k,v in pairs(self.activity_list:GetAllItems()) do
		v:RefreshRemind()
	end
end


----------------------------------------------------
-- 运营活动列表OperationActivityRender
----------------------------------------------------
OperationActivityRender = OperationActivityRender or BaseClass(BaseRender)
function OperationActivityRender:__init()
end

function OperationActivityRender:__delete()	
end

function OperationActivityRender:OnFlush()
	if nil == self.data then
		return
	end

	self.node_tree.lbl_activity_name.node:setString(self.data.name)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	self:RefreshRemind()
end

function OperationActivityRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetCommon("btn_181_select"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.img_bg.node:addChild(self.select_effect, 998)
end

function OperationActivityRender:RefreshRemind()
	self:SetRemind(ActivityBrilliantData.Instance:GetRemindNum(self.data.act_id) > 0)
end

function OperationActivityRender:SetRemind(bool)
	if bool and nil == self.remind_img and self.node_tree.img_bg then
		self.remind_img = XUI.CreateImageView(170, 50, ResPath.GetMainui("remind_flag"), true)
		self.node_tree.img_bg.node:addChild(self.remind_img, 999)
	elseif self.remind_img then 
		self.remind_img:setVisible(bool)
	end
end

require("scripts/game/combinedserveract/combined_child_view/combined_double_view")
require("scripts/game/combinedserveract/combined_child_view/combined_accumul_view")
require("scripts/game/combinedserveract/combined_child_view/combined_gongcheng_view")
require("scripts/game/combinedserveract/combined_child_view/combined_party_view")
require("scripts/game/combinedserveract/combined_child_view/combined_fashion_view")
require("scripts/game/combinedserveract/combined_child_view/combined_turntable_view")
require("scripts/game/combinedserveract/combined_child_view/combined_xunbao_view")
CombinedServerActView = CombinedServerActView or BaseClass(BaseView)

function CombinedServerActView:__init()
	self:SetModal(true)
	self.def_index = TabIndex.combinedserv_accumulative
	self.is_any_click_close = false
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.texture_path_list[2] = 'res/xui/combind.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"combinedactivity_ui_cfg", 1, {0}},
		{"combinedactivity_ui_cfg", 2, {0}},
		{"combinedactivity_ui_cfg", 3, {TabIndex.combinedserv_accumulative}},
		{"combinedactivity_ui_cfg", 4, {TabIndex.combinedserv_ybparty, TabIndex.combinedserv_cbparty, TabIndex.combinedserv_bsparty, 
        TabIndex.combinedserv_zhparty,TabIndex.combinedserv_lhparty, TabIndex.combinedserv_gongcheng, TabIndex.combinedserv_fashion, TabIndex.combinedserv_turntable}},
--		{"combinedactivity_ui_cfg", 5, {TabIndex.combinedserv_accumulative}},
		{"combinedactivity_ui_cfg", 6, {TabIndex.combinedserv_gongcheng}},
		{"combinedactivity_ui_cfg", 7, {TabIndex.combinedserv_ybparty, TabIndex.combinedserv_cbparty, TabIndex.combinedserv_bsparty, TabIndex.combinedserv_zhparty,TabIndex.combinedserv_lhparty}},
--		{"combinedactivity_ui_cfg", 7, {TabIndex.combinedserv_lhparty}},
		{"combinedactivity_ui_cfg", 8, {TabIndex.combinedserv_fashion}},
		{"combinedactivity_ui_cfg", 9, {TabIndex.combinedserv_turntable}},
--        {"combinedactivity_ui_cfg", 10, {TabIndex.combinedserv_leijichongzhi}},
		{"common_ui_cfg", 2, {0}},
	}

	self.gongcheng_reward_t = {}
	self.fashion_reward_t = {}
	self.table_reward_t = {}
	self.remind_t = {}
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end

function CombinedServerActView:__delete()
end

function CombinedServerActView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
    self:DeleteAccumulView()
	self:DeleteDoubleView()
	self:DeleteGongchengView()
	self:DeleteFashionView()
	self:DeletePartyView()
	self:DeleteTurntableView()
	self:DeleteXunbaoView()
	GlobalTimerQuest:CancelQuest(self.last_timer)
end

function CombinedServerActView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:InitTabbar()
		self.last_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateCombinedLastTime, self), 1)
		for k,v in pairs(self.remind_t) do
			self.tabbar:SetRemindByIndex(k, v > 0)
		end
	end
	if index == TabIndex.combinedserv_double then
		self:LoadDoubleView()
    elseif index == TabIndex.combinedserv_accumulative then
        self:LoadAccumulView()
	elseif index == TabIndex.combinedserv_gongcheng then
		self:LoadGongchengView()
	elseif index == TabIndex.combinedserv_ybparty 
		or index == TabIndex.combinedserv_cbparty
		or index == TabIndex.combinedserv_bsparty
		or index == TabIndex.combinedserv_zhparty 
        or index == TabIndex.combinedserv_lhparty then
		self:LoadPartyView()
	elseif index == TabIndex.combinedserv_fashion then
		self:LoadFashionView()
	elseif index == TabIndex.combinedserv_turntable then
		self:LoadTurntableView()
	elseif index == TabIndex.combinedserv_xunbao then
		self:LoadXunbaoView()
	end
end

function CombinedServerActView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = ScrollTabbar.New()
		self.tabbar.space_interval_V = 10
		self.tabbar:SetSpaceInterval(2)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 5, 0,
			BindTool.Bind1(self.SelectTabCallback, self), Language.CombinedServerAct.TabGroup, 
			true, ResPath.GetCommon("toggle_120"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self:CheckMyTabbarOpen()
	end
end

function CombinedServerActView:CheckMyTabbarOpen()
	if nil == self.tabbar then return end
	local index = nil
	for i = 1, self.tabbar:GetCount() do
		local vis = CombinedServerActData.Instance:GetCombinedIndexIsOpen(i)
		self.tabbar:SetToggleVisible(i, vis)
		if vis and (nil == index or i < index) then
			index = i
		end
	end

	if index then 
		self:ChangeToIndex(index)
	else
		self:Close()						-- 没有任何合服活动开启则关闭面板
	end
end

function CombinedServerActView:OnClickTransmitHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
	self:Close()
end

function CombinedServerActView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CombinedServerActView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index)
	CombinedServerActCtrl.SendSendCombinedInfo(CombinedServerActData.GetActIdByIndex(index))
	self:Flush(index)
end

function CombinedServerActView:SelectTabCallback(index)
	self:ChangeToIndex(index)
	self:CancelAutoDrawTimer() --取消转盘自动抽奖
end

function CombinedServerActView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:CancelAutoDrawTimer() --取消转盘自动抽奖
end

function CombinedServerActView:OnFlush(param_t, index)
	self:FlushTopView(param_t, index)
	if index == TabIndex.combinedserv_double then
		self:FlushDoubleView(param_t)
    elseif index == TabIndex.combinedserv_accumulative then
		self:FlushAccumulView(param_t)
	elseif index == TabIndex.combinedserv_gongcheng then
		self:FlushGongchengView(param_t)
	elseif index == TabIndex.combinedserv_ybparty 
		or index == TabIndex.combinedserv_cbparty
		or index == TabIndex.combinedserv_bsparty
		or index == TabIndex.combinedserv_zhparty 
        or index == TabIndex.combinedserv_lhparty then
		self:FlushPartyView(param_t)
	elseif index == TabIndex.combinedserv_fashion then
		self:FlushFashionView(param_t)
	elseif index == TabIndex.combinedserv_turntable then
		self:FlushTurntableView(param_t)
	elseif index == TabIndex.combinedserv_xunbao then
		self:FlushDoubleView(param_t)
	end
end

function CombinedServerActView:FlushTopView(param_t, index)
	local act_id = CombinedServerActData.GetActIdByIndex(index)
    if act_id ==  TabIndex.combinedserv_accumulative then return end
	local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
	local act_info = CombinedServerActData.Instance:GetActInfo(act_id)
	if nil == act_cfg or nil == act_info then return end
	local open_time_t = os.date("*t", act_info.begin_time)
	local end_time_t = os.date("*t", act_info.end_time)
	local act_time = string.format(Language.CombinedServerAct.OpenTimeFormat, open_time_t.month, open_time_t.day, end_time_t.month, end_time_t.day)
	self.node_t_list.txt_time.node:setString(act_time)
	-- self.node_t_list.rich_act_content.node:setString(act_cfg.desc)
	if index == TabIndex.combinedserv_turntable then
		RichTextUtil.ParseRichText(self.node_t_list.rich_act_content.node, act_cfg.desc.." 传奇券、 龙魂券当天有效，跨天清零。", nil, cc.c3b(0xE1, 0xA0, 0x34))
	else
		RichTextUtil.ParseRichText(self.node_t_list.rich_act_content.node, act_cfg.desc, nil, cc.c3b(0xE1, 0xA0, 0x34));
	end
	local has_time = math.max(0, act_info.end_time - TimeCtrl.Instance:GetServerTime())
	self.node_t_list.txt_remaining_time.node:setString(TimeUtil.FormatSecond2Str(has_time))
end

function CombinedServerActView:UpdateCombinedLastTime()
	local act_id = CombinedServerActData.GetActIdByIndex(self:GetShowIndex())
	local act_info = CombinedServerActData.Instance:GetActInfo(act_id)
	if nil == act_info or nil == self.node_t_list.txt_remaining_time then return end
	local has_time = math.max(0, act_info.end_time - TimeCtrl.Instance:GetServerTime())
	if 0 == has_time then
		self:CheckMyTabbarOpen()
	end
	self.node_t_list.txt_remaining_time.node:setString(TimeUtil.FormatSecond2Str(has_time))
end

function CombinedServerActView:RemindChange(remind_name, num)
	if remind_name == RemindName.CombinedServGCZReward then
		self.remind_t[TabIndex.combinedserv_gongcheng] = num
	elseif remind_name == RemindName.CombinedServFashionReward then
		self.remind_t[TabIndex.combinedserv_fashion] = num
	elseif remind_name == RemindName.CombinedServDZPCount then
		self.remind_t[TabIndex.combinedserv_turntable] = num
    elseif remind_name == RemindName.CombinedServLJCZReward then
		self.remind_t[TabIndex.combinedserv_accumulative] = num
	end
		
	if self.tabbar == nil  then return end
	for k,v in pairs(self.remind_t) do
		self.tabbar:SetRemindByIndex(k, v > 0)
	end
end

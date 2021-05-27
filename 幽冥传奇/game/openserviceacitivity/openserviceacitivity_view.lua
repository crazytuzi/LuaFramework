OpenServiceAcitivityView = OpenServiceAcitivityView or BaseClass(BaseView)

function OpenServiceAcitivityView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		"res/xui/openserviceacitivity.png",
		"res/xui/guild.png",
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"openserviceacitivity_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
end

function OpenServiceAcitivityView:__delete()

end

function OpenServiceAcitivityView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	GlobalEventSystem:UnBind(self.remind_event_h)
	self:UnBindGlobalEvent(self.open_day_change)
end

function OpenServiceAcitivityView:LoadCallBack(index, loaded_times)
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.TabbarDisplayChange, BindTool.Bind(self.SetTabbarVisible, self))
	self:InitTabbar()
	self:InitRemind()
	OpenServiceAcitivityCtrl:SendSportsListInfo(OpenServiceAcitivityData.Instance:GetSportsShowIndex())
	self.remind_event_h = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
	self.open_day_change = GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, BindTool.Bind(self.OnOpenDayChange, self))
end

function OpenServiceAcitivityView:OpenCallBack()
	if self.tabbar then
		self:SetTabbarVisible()
	end
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OpenServiceAcitivityView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function OpenServiceAcitivityView:ShowIndexCallBack(index)

end

function OpenServiceAcitivityView:InitTabbar()
	if nil == self.tabbar then
		local tabbar_title_list = OpenServiceAcitivityData.Instance:GetTabbarTitleList()
		self.tabbar = ScrollTabbar.New()
		self.tabbar.space_interval_V = 10
		self.tabbar:SetSpaceInterval(2)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 5, 0,
			BindTool.Bind1(self.SelectTabCallback, self), tabbar_title_list, 
			true, ResPath.GetCommon("toggle_120"))

		--更新tabbar列表
		OpenServiceAcitivityData.Instance:UpdateTabbarMarkList()

		--元宝转盘开启检测
		OpenServiceAcitivityData.Instance:SetGoldDrawTabbarVisible()

		self:SetTabbarVisible()
	end
end

function OpenServiceAcitivityView:SelectTabCallback(index)
	self:GetViewManager():OpenViewByDef(OpenServiceAcitivityData.ViewTable[index])
	OpenServiceAcitivityData.Instance:UpdateTabbarMarkList()
end

-- 更新Tabbar显示
function OpenServiceAcitivityView:SetTabbarVisible()
	-------------------------------------------------------
	local tabbar_mark_list = OpenServiceAcitivityData.Instance:GetTabbarMarkList() -- 获取Tabbar列表
	-------------------------------------------------------
	local display_index = 0
	for k, v in pairs(tabbar_mark_list) do
		-- 有按钮显示需要改变才刷新
		if self.tabbar:GetToggleByIndex(k):isVisible() ~= (v == 1) then
			self.tabbar:SetToggleVisible(k, v == 1)
		end
		-- 当前子界面是否被隐藏
		if self:GetViewManager():IsOpen(OpenServiceAcitivityData.ViewTable[k]) and 1 == v then
			display_index = k
		end
	end

	-- 当前子界面被隐藏了
	if display_index == 0 then
		display_index = OpenServiceAcitivityData.Instance:GetTabbarDefaultIndex()
	end
	if 0 == display_index then
		self:GetViewManager():CloseViewByDef(ViewDef.OpenServiceAcitivity)
	else
		self.tabbar:SelectIndex(display_index)
	end
	
end

-- 跨天更新
function OpenServiceAcitivityView:OnOpenDayChange()
	OpenServiceAcitivityData.Instance:UpdateTabbarMarkList()
end

function OpenServiceAcitivityView:RemindChange(remind_name, num)
	if nil == self.tabbar then return end
	if remind_name == RemindName.OpenServiceLevelGift then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift, num > 0)
	elseif remind_name == RemindName.OpenServiceMoldingSoulSports then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulSports, num > 0)	
	elseif remind_name == RemindName.OpenServiceGemStoneSports then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneSports, num > 0)	
	elseif remind_name == RemindName.OpenServiceDragonSpiritSports then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritSports, num > 0)	
	elseif remind_name == RemindName.OpenServiceWingSports then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingSports, num > 0)	
	elseif remind_name == RemindName.OpenServiceCardHandlebookSports then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookSports, num > 0)	
	elseif remind_name == RemindName.OpenServiceCircleSports then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleSports, num > 0)	
	elseif remind_name == RemindName.OpenServiceCharge then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge, num > 0)	
	elseif remind_name == RemindName.OpenServiceLuckyDraw then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw, num > 0)	
	elseif remind_name == RemindName.OpenServiceBoss then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss, num > 0)	
	elseif remind_name == RemindName.OpenServiceXunBao then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao, num > 0)
	elseif remind_name == RemindName.OpenServiceFinancial then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityFinancial, num > 0)
	elseif remind_name == RemindName.OpenServiceGoldDraw then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.GoldDraw, num > 0)
	elseif remind_name == RemindName.OpenServiceConsume then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityConsume, num > 0)
	elseif remind_name == RemindName.OpenServiceRecharge then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityRecharge, num > 0)
	elseif remind_name == RemindName.OpenServiceExploreRank then
		self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank, num > 0)
	end
end

function OpenServiceAcitivityView:InitRemind()
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceLevelGift) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulSports, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceMoldingSoulSports) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneSports, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceGemStoneSports) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritSports, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceDragonSpiritSports) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingSports, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceWingSports) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookSports, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceCardHandlebookSports) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleSports, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceCircleSports) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceCharge) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceLuckyDraw) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceBoss) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceXunBao) > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityFinancial, WelfareData.Instance:GetFinancingRemind() > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.GoldDraw, OpenServiceAcitivityData.Instance:GoldCanDrawNum() > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityConsume, WelfareData.Instance:GetConsumeRankRemind() > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityRecharge, WelfareData.Instance:GetRechargeRankRemind() > 0)
	self.tabbar:SetRemindByIndex(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank, OpenServiceAcitivityData.Instance:GetRemindNumByType(RemindName.OpenServiceExploreRank) > 0)

end
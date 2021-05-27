CarnivalView = CarnivalView or BaseClass(XuiBaseView)

function CarnivalView:__init()
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"carnival_ui_cfg", 1, {0}},
		{"carnival_ui_cfg", 2, {TabIndex.carnival_rank}},
		{"carnival_ui_cfg", 3, {TabIndex.carnival_pool}},
		{"carnival_ui_cfg", 4, {TabIndex.carnival_goldBoss}},
		{"carnival_ui_cfg", 5, {TabIndex.carnival_goldLease}},
		{"carnival_ui_cfg", 6, {TabIndex.carnival_returnWelfare}},
		{"common_ui_cfg", 2, {0}},
	}

	self.texture_path_list = {'res/xui/welfare.png',
								'res/xui/openserviceacitivity.png',
								'res/xui/limit_activity.png', 
								'res/xui/fight.png',
								'res/xui/supervip.png',
								'res/xui/role.png',
								"res/xui/invest_plan.png",}
	self:SetModal(true)
	-- self.title_img_path = ResPath.GetPray("chellenge_title")

	self.page_list = {}
	self.page_list[TabIndex.carnival_rank] = CarnivalRankPage.New() 		--开服排行页面
	self.page_list[TabIndex.carnival_pool] = CarnivalPoolPage.New() 		----许愿池页面
	self.page_list[TabIndex.carnival_goldBoss] = CarnivalGoldBossPage.New() 	--神装boss页面
	self.page_list[TabIndex.carnival_goldLease] = CarnivalGoldLeasePage.New() 				--神力租赁页面
	self.page_list[TabIndex.carnival_returnWelfare] = CarnivalWellfarePage.New() 		--消费返利页面
	self.tabbar = nil
end

function CarnivalView:__delete()
end

function CarnivalView:ReleaseCallBack()
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end

	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.Carnival)
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function CarnivalView:LoadCallBack(index, loaded_times)
	if self.page_list[index] then
		-- if WelfareData.Instance:IsShowTabbarToggleByIndex(index) then
		-- end
			self.page_list[index]:InitPage(self)
	end
	if loaded_times <= 1 then
		-- self.node_t_list.lookseeBtn.node:addClickEventListener(BindTool.Bind(self.ChargeFirstMoney, self))
		self:CreateTabbarList()
		ViewManager.Instance:RegsiterTabFunUi(ViewName.Carnival, self.tabbar)
		self:SetTabToggleVis()
	end
end

function CarnivalView:CreateTabbarList()
	if self.tabbar ~= nil then return end

	self.tabbar = ScrollTabbar.New()
	self.tabbar.space_interval_V = 8
	self.tabbar:CreateWithNameList(self.node_t_list.scroll_bar.node, 7, 0,
		BindTool.Bind1(self.SelectTabCallback, self), Language.Carnival.TabGroup, 
		true, ResPath.GetCommon("btn_106"),cc.size(230,62),cc.rect(22,18,98,25),Str2C3b("fff999"), Str2C3b("bdaa93"))
	local index  = CarnivalData.Instance:MinOpenActivity()
	self:ChangeToIndex(index)
	-- self.tabbar:SetSpaceInterval(5)
	-- local effect = self.tabbar:SetEffectByIndex(10,10)
	-- effect:setScaleX(1.5)
	-- effect = self.tabbar:SetEffectByIndex(TabIndex.welfare_invest_plan,10)
	-- effect:setScaleX(1.5)
end

function CarnivalView:ShowIndexCallBack(index)
	self:Flush(index)
	self.tabbar:ChangeToIndex(index)
end

function CarnivalView:SelectTabCallback(index)
	CarnivarCtrl.Instance:RecvMainRoleInfo()
	self:ChangeToIndex(index)
end
 
function CarnivalView:OnClose()
	self:Close()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end
function CarnivalView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.tabbar then
		local index  = CarnivalData.Instance:MinOpenActivity()
		self:ChangeToIndex(index)
		self.tabbar:SelectIndex(index)
	end
	CarnivarCtrl.Instance:RecvMainRoleInfo()
end

function CarnivalView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CarnivalView:OnFlush(param_t, index)
	if self.page_list[index] then

		self.page_list[index]:UpdateData(param_t)
		-- if WelfareData.Instance:IsShowTabbarToggleByIndex(index) then
		-- end
	end
	for k,v in pairs(param_t) do
		if k == "type" then
			if CarnivalData.Instance:BossIsOpen() then
				self:ChangeToIndex(TabIndex.carnival_goldBoss)
				self.tabbar:SelectIndex(TabIndex.carnival_goldBoss)
			else
				self:Close()
			end
		elseif k == "lease" then
			if CarnivalData.Instance:LeaseIsOpen() then
				self:ChangeToIndex(TabIndex.carnival_goldLease)
				self.tabbar:SelectIndex(TabIndex.carnival_goldLease)
			else
				self:Close()
			end
		end
	end
	self.tabbar:SetRemindByIndex(TabIndex.carnival_pool, CarnivalData.Instance:RemindData() > 0)
end

function CarnivalView:SetTabToggleVis(tab_index)
	local is_visible = true
	if not tab_index then
		for k, v in pairs(Language["Carnival"]["TabGroup"]) do
			is_visible = CarnivalData.Instance:IsShowTabbarToggleByIndex(k)			
			self.tabbar:SetToggleVisible(k, is_visible)
			local index  = CarnivalData.Instance:MinOpenActivity()
			self:ChangeToIndex(index)
			self.tabbar:SelectIndex(index)
		end
	end
end

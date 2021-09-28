--充值界面
RechargePanel =BaseClass(CommonBackGround)

function RechargePanel:__init()
	self.id = "RechargePanel"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}

	self:SetTitle("充值活动")
	self.bgUrl = "bg_big1"
	self.useFade = false
end

function RechargePanel:Layout()
	self:InitData()
	self:InitUI()
	self:InitEvent()
	self:AddEvent()
	-- self:SetTabbarVisible("2", false)
end

function RechargePanel:InitData()
	self.defaultTabIndex = 0
	self.selectTabId = -1

	self.model = RechargeModel:GetInstance()  --+++++++++11.6
end

function RechargePanel:InitUI()
	self:InitTabsUI()
end

function RechargePanel:InitEvent()
	self.openCallback = function (  )
		RechargeController:GetInstance():C_GetPayActData()
	end
end

function RechargePanel:AddEvent()
	self.handler0 = self.model:AddEventListener(RechargeConst.DailyRechargeGet, function()
		self:RefreshRed()
		self.model:ShowRedTips()
	end)
	self.handler1 = self.model:AddEventListener(RechargeConst.LQJijinData, function()
		self:RefreshRed()
		self.model:ShowRedTips()
	end)
	self.handler2 = self.model:AddEventListener(RechargeConst.allRewardData, function()
		self:RefreshRed()
		self.model:ShowRedTips()
	end)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.RefershTotalRechargeRedTipsState , function ()
		self:RefreshRed()
		self.model:ShowRedTips()
	end)
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.RefershConsumRed , function ()
		self:RefreshRed()
		self.model:ShowRedTips()
	end)
	-- self.monthCardRedChangeHanlder = GlobalDispatcher:AddEventListener(EventName.MonthCardStateChange , function()
 --    	self:RefreshRed()
 --    end)
    self.turnRedChangeHandler = GlobalDispatcher:AddEventListener(EventName.TurnRedChange, function(data)
  		self:RefreshRed()
  		self.model:ShowRedTips()
    end)
    self.SevenRechargeRedChange = GlobalDispatcher:AddEventListener(EventName.SevenRechargeRedChange, function(data)
  		self:RefreshRed()
  		if self.model then
  			self.model:ShowRedTips()
  		end
    end)
end

function RechargePanel:InitTabsUI()
	local tabBg = UIPackage.GetItemURL("Common","btnBg_001")
	local tabSelectedBg = UIPackage.GetItemURL("Common","btnBg_002")
	local x = 148
	local y = 122
	local tabType = 0
	local yInternal = 60
	local redW = 153
	local redH = 53
	local tabData = {}
	local tabCfgData = RechargeModel:GetInstance():GetPanelTabData()
	
	for i = 1, #tabCfgData do
		table.insert(tabData, {label = tabCfgData[i][2], res0 = tabBg, res1 = tabSelectedBg, id = tabCfgData[i][1], red = false , fontColor = newColorByString("2e3341") })
	end
	local ctrl, tabs = CreateTabbar(self.ui, tabType, function(idx, id, bar)
		self.selectTabId = tonumber(idx)
		local selectTabId = self.selectTabId + 1
		if selectTabId == RechargeConst.RechargeType.GrowUpJijin then    --成长基金
			if not self.growUpPanel then
				self.growUpPanel = GrowUpPanel.New()
				self.growUpPanel:SetXY(311, 107)
				self.container:AddChild(self.growUpPanel.ui)
			end
		elseif selectTabId == RechargeConst.RechargeType.TotalRecharge then
			if not self.accRechargePanel then
				self.accRechargePanel = TotalRechargeUI.New()
				self.accRechargePanel:SetXY(311, 108)
				self.container:AddChild(self.accRechargePanel.ui)
			end
		elseif selectTabId == RechargeConst.RechargeType.DailyRecharge then
			if not self.rechargeDailyPanel then
				self.rechargeDailyPanel = RechargeDailyPanel.New()
				self.rechargeDailyPanel:SetXY(311, 107)
				self.container:AddChild(self.rechargeDailyPanel.ui)
			end
		elseif selectTabId == RechargeConst.RechargeType.TotalPay then
			if not self.totalPayPanel then
				self.totalPayPanel = ConsumPanel.New(self.container)
				self.totalPayPanel:SetXY(311, 107)
			end
		-- elseif selectTabId == RechargeConst.RechargeType.MonthCard then
		-- 	if not self.cardPanel then
		-- 		self.cardPanel = MonthCardController:GetInstance():GetCardPanel()
		-- 		self.cardPanel:SetXY(311, 107)
		-- 		self.container:AddChild(self.cardPanel.ui)
		-- 	end
		elseif selectTabId == RechargeConst.RechargeType.Turn then
			self:InitTurnContentUI()
		elseif selectTabId == RechargeConst.RechargeType.Tomb then
			self:InitTombContentUI()
		elseif selectTabId == RechargeConst.RechargeType.SevenRecharge then
			self:InitSevenContentUI()
		end
		self:RefreshContentUI()
		bar:GetChild("title").color = newColorByString("#2e3341")
	end, tabData, x, y, self.defaultTabIndex, yInternal, redW, redH)
	self.tabCtrl = ctrl
	self.tabs = tabs
end

function RechargePanel:RefreshContentUI()
	self:CloseAllContent()
	local selectTabId = self.selectTabId + 1
	if selectTabId == RechargeConst.RechargeType.DailyRecharge then
		if self.rechargeDailyPanel then
			self.rechargeDailyPanel:SetVisible(true)
		end
	elseif selectTabId == RechargeConst.RechargeType.TotalRecharge then
		if self.accRechargePanel then
			self.accRechargePanel:SetVisible(true)
		end
	elseif selectTabId == RechargeConst.RechargeType.GrowUpJijin then
		if self.growUpPanel then
			self.growUpPanel:SetVisible(true)
		end
	elseif selectTabId == RechargeConst.RechargeType.TotalPay then
		if self.totalPayPanel then
			self.totalPayPanel:SetVisible(true)
		end
	-- elseif selectTabId == RechargeConst.RechargeType.MonthCard then
	-- 	if self.cardPanel then
	-- 		self.cardPanel:SetVisible(true)
	-- 		self.cardPanel:RefreshUI()
	-- 	end
	elseif selectTabId == RechargeConst.RechargeType.Turn then
		if self.turnPanel then
			self.turnPanel:Reset()
			self.turnPanel:SetVisible(true)
			RechargeController:GetInstance():TurnInitRequest()
		end
	elseif selectTabId == RechargeConst.RechargeType.Tomb then
		if self.tombPanel then
			self.tombPanel:SetVisible(true)
			--self.tombPanel:RefreshUI()
			RechargeController:GetInstance():C_GetTombData()
		end
	elseif selectTabId == RechargeConst.RechargeType.SevenRecharge then
		if self.sevenPanel then
			self.sevenPanel:SetVisible(true)
			RechargeController:GetInstance():C_GetSevenPayData()
		end
	end
	self:RefreshRed()   --红点++++++++++
end

function RechargePanel:CloseAllContent()
	if self.rechargeDailyPanel then
		self.rechargeDailyPanel:SetVisible(false)
	end
	if self.accRechargePanel then
		self.accRechargePanel:SetVisible(false)
	end
	if self.growUpPanel then
		self.growUpPanel:SetVisible(false)
	end
	if self.totalPayPanel then
		self.totalPayPanel:SetVisible(false)
	end
	if self.cardPanel then
		self.cardPanel:SetVisible(false)
	end
	if self.turnPanel then
		self.turnPanel:SetVisible(false)
	end
	if self.tombPanel then
		self.tombPanel:SetVisible(false)
	end
	if self.sevenPanel then
		self.sevenPanel:SetVisible(false)
	end
end

function RechargePanel:RefreshRed()
	if not self.tabs then return end
	local tabCfgData = RechargeModel:GetInstance():GetPanelTabData()
	if (not TableIsEmpty(tabCfgData)) then
		for i = 1, #self.tabs do
			local idx = tonumber( tabCfgData[i][1] )
			local tab = self.tabs[tonumber(idx)]
			if idx == RechargeConst.RechargeType.DailyRecharge then
				tab:GetChild("red").visible = RechargeModel:GetInstance():IsDailyRechargeRed()
			elseif idx == RechargeConst.RechargeType.GrowUpJijin then
				tab:GetChild("red").visible = RechargeModel:GetInstance():IsAllWelfareRed() or RechargeModel:GetInstance():IsJijinRed()
			elseif idx == RechargeConst.RechargeType.TotalRecharge then
				tab:GetChild("red").visible = TotalRechargeModel:GetInstance():IsHasRewardCanGet()
			elseif idx == RechargeConst.RechargeType.TotalPay then
				tab:GetChild("red").visible = ConsumModel:GetInstance():IsHasCanGet()
			-- elseif idx == RechargeConst.RechargeType.MonthCard then
			-- 	tab:GetChild("red").visible = MonthCardModel:GetInstance():GetRed()
			elseif idx == RechargeConst.RechargeType.Turn then
				tab:GetChild("red").visible = RechargeModel:GetInstance():GetTurnRed()
			elseif idx == RechargeConst.RechargeType.Tomb then
				tab:GetChild("red").visible = false
			elseif idx == RechargeConst.RechargeType.SevenRecharge then
				tab:GetChild("red").visible = RechargeModel:GetInstance():GetSevenRed()
			end
		end
	else
		for i = 1, #self.tabs do
			self.tabs[i]:GetChild("red").visible = false
		end
	end
end

function RechargePanel:Open(tabIdx)
	CommonBackGround.Open(self)

	if tabIdx then
		self:SetTabSelect(tabIdx)
	else
		--self:SetTabSelect(WelfareConst.WelfareType.Sign)
	end
	self:RefreshRed()  --红点++++++++++
end

function RechargePanel:SetTabSelect(tabType)
	if self.tabCtrl then
		self.tabCtrl.selectedIndex = tabType - 1 --从0开始，因此减1
	end
end

function RechargePanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
		self.model:RemoveEventListener(self.handler1)
		self.model:RemoveEventListener(self.handler2)
	end

	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	--GlobalDispatcher:RemoveEventListener(self.monthCardRedChangeHanlder)
	GlobalDispatcher:RemoveEventListener(self.turnRedChangeHandler)
	GlobalDispatcher:RemoveEventListener(self.SevenRechargeRedChange)
	
	if self.rechargeDailyPanel then
		self.rechargeDailyPanel:Destroy()
	end
	if self.growUpPanel then
		self.growUpPanel:Destroy()
	end
	if self.accRechargePanel then
		self.accRechargePanel:Destroy()
	end
	if self.totalPayPanel then
		self.totalPayPanel:Destroy()
	end
	self.totalPayPanel = nil
	self.accRechargePanel = nil
	self.rechargeDailyPanel = nil
	self.growUpPanel = nil

	--MonthCardController:GetInstance():DestroyCardPanel()
	self.cardPanel = nil
	RechargeController:GetInstance():DestroyTurnPanel()
	self.turnPanel = nil
	RechargeController:GetInstance():DestroyTombPanel()
	self.tombPanel = nil
	RechargeController:GetInstance():DestroySevenRechargePanel()
	self.sevenPanel = nil
end

function RechargePanel:InitTombContentUI()
	if not self.tombPanel then
		self.tombPanel = RechargeController:GetInstance():GetTombPanel()
		self.tombPanel:SetXY(311, 107)
		self.container:AddChild(self.tombPanel.ui)
	end
end

function RechargePanel:InitTurnContentUI()
	if not self.turnPanel then
		self.turnPanel = RechargeController:GetInstance():GetTurnPanel()
		self.turnPanel:SetXY(311, 107)
		self.container:AddChild(self.turnPanel.ui)
	end
end

function RechargePanel:InitSevenContentUI()
	if not self.sevenPanel then
		self.sevenPanel = RechargeController:GetInstance():GetSevenRechargePanel()
		self.sevenPanel:SetXY(311, 107)
		self.container:AddChild(self.sevenPanel.ui)
	end
end
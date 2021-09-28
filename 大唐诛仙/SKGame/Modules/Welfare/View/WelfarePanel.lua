--福利界面
WelfarePanel =BaseClass(CommonBackGround)

function WelfarePanel:__init()
	self.id = "WelfarePanel"
	self.showBtnClose = true

	self:SetTitle("福利")
	self.bgUrl = "bg_big1"
	self.openTopUI = true
	self.openResources = {1, 2}
	--self.useFade = false

	self:AddChouDai()
end

function WelfarePanel:Layout()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function WelfarePanel:InitData()
	self.defaultTabIndex = 0
	self.selectTabId = -1
	self.oldTabData = {}
end

function WelfarePanel:InitUI()
	self:InitTabsUI()
end

function WelfarePanel:InitEvent()
	self.eventHandler0 = GlobalDispatcher:AddEventListener(EventName.GetOnlineReward, function(data)
		self:HandleGetOnlineReward(data)
	end)

	self.eventHandler1 = GlobalDispatcher:AddEventListener(EventName.SyncOnlineRewardList, function(data)
		self:HandleSyncOnlineRewardList(data)
	end)

	self.closeCallback = function()
		if self.onlineRewardContent then
			self.onlineRewardContent:RemoveTimer()
		end
		self.selectTabId = -1
	end

	self.openCallback = function()
	end

	self.signRedChangeHandler = GlobalDispatcher:AddEventListener(EventName.SignRedChange, function(data)
  		self:RefreshRed()
    end)

end

function WelfarePanel:InitOnlineRewardContentUI()
	if not self.onlineRewardContent then
		self.onlineRewardContent = OnlineRewardContent.New()
		self.onlineRewardContent:SetXY(311, 107)
		self.container:AddChild(self.onlineRewardContent.ui)
	end
end
--冲级狂人
function WelfarePanel:GetLevelingMadmanPanel()
	if not self.levelingMadmanContent  then
		self.levelingMadmanContent = PowerLevelView.New()
		self.levelingMadmanContent:SetXY(311, 107)	
		self.container:AddChild(self.levelingMadmanContent.ui)
		--[[for i=1,6 do
			self.levelingMadmanContent:RegistLevelButton(i)
		end	--]]
	end
end
--冲战斗力
function WelfarePanel:GetImproveBattlePanel()
	if not self.improveBattleContent then
		self.improveBattleContent = PowerBattleView.New()
		self.improveBattleContent:SetXY(311, 107)
		self.container:AddChild(self.improveBattleContent.ui)
		--[[for i=1,6 do
			self.improveBattleContent:RegistBattleButton(i)
		end--]]
	end
end

function WelfarePanel:InitTabsUI()
	local tabBg = UIPackage.GetItemURL("Common","btnBg_001")
	local tabSelectedBg = UIPackage.GetItemURL("Common","btnBg_002")
	local x = 145
	local y = 122
	local tabType = 0
	local yInternal = 60
	local redW = 163
	local redH = 53
	local tabData = {}
	local tabCfgData = WelfareModel:GetInstance():GetPanelTabData()
	self.oldTabData = tabCfgData
	for i = 1, #self.oldTabData do
		table.insert(tabData, {label = self.oldTabData[i][2], res0 = tabBg, res1 = tabSelectedBg, id = self.oldTabData[i][1] , red = false , fontColor = newColorByString("#2e3341") })		
	end
	local ctrl, tabs = CreateTabbar(self.ui, tabType, function(idx, id, bar)
		self.selectTabId = tonumber(idx)
		local selectTabId = self.selectTabId + 1
		local selectTabId = tonumber(id)
		if selectTabId == WelfareConst.WelfareType.BindPhone then
			self.selectTabId = selectTabId - 1
			if not self.accountPanel or WelfareModel:GetInstance():GetHuoDongTime() <= 0 then
				self.accountPanel = AccountController:GetInstance():GetAccountPanel()
				self.accountPanel:SetXY(312, 110)
				self.container:AddChild(self.accountPanel.ui)
			end
		elseif selectTabId == WelfareConst.WelfareType.Sign then
			if not self.signPanel then
				local ctrl = SignController:GetInstance()
				local function cbOpenSign()
					self.signPanel = ctrl:GetFuliPanel()
					self.signPanel:SetXY(106, 30)
					self.container:AddChild(self.signPanel.ui)
				end
				cbOpenSign()
				-- if not ctrl.isFuliDestroying then
				-- 	cbOpenSign()
				-- else
				-- 	DelayCall(cbOpenSign, 0.03)
				-- end
			end
		elseif selectTabId == WelfareConst.WelfareType.LevelingMadman  then
			PowerLevelCtr:GetInstance():C_GetLevelAwardData()		
			self:GetLevelingMadmanPanel()
			self.levelingMadmanContent:RegistBtn()
		elseif selectTabId == WelfareConst.WelfareType.WildRage  then
			PowerLevelCtr:GetInstance():C_GetBVAwardData()
			self:GetImproveBattlePanel()
			self.improveBattleContent:RegistBtn()	
		elseif selectTabId == WelfareConst.WelfareType.OnlineReward then
			self:InitOnlineRewardContentUI()

		elseif selectTabId == WelfareConst.WelfareType.RewardCode then	
			self.selectTabId = selectTabId - 1			
			if not self.rewardCodePanel then
				self.rewardCodePanel = RewardCodePanel.New()
				self.rewardCodePanel:SetXY(311, 107)
				self.container:AddChild(self.rewardCodePanel.ui)
			end
		-- elseif selectTabId == WelfareConst.WelfareType.Identify then
		-- 	self.selectTabId = selectTabId - 1		
		-- 	if not self.identifyPanel then
		-- 		self.identifyPanel = IdentifyPanel.New()
		-- 		self.identifyPanel:SetXY(318, 107)
		-- 		self.container:AddChild(self.identifyPanel.ui)
		-- 	end
		end
		self:RefreshContentUI()
		bar:GetChild("title").color = newColorByString("#2e3341")
	end, tabData, x, y, self.defaultTabIndex, yInternal, redW, redH)
	self.tabCtrl = ctrl
	self.tabs = tabs
end

function WelfarePanel:Open(tabIdx)
	CommonBackGround.Open(self)
	if tabIdx then
		if WelfareModel:GetInstance():GetHuoDongTime() <= 0 then
			self:SetTabSelect(tabIdx - 2)
		else	
			self:SetTabSelect(tabIdx)
		end
	else
		self:SetTabSelect(WelfareConst.WelfareType.OnlineReward)
	end
	self:RefreshRed()
end

function WelfarePanel:SetTabSelect(tabType)
	if self.tabCtrl then
		self.tabCtrl.selectedIndex = tabType - 1 --从0开始，因此减1
	end
end

function WelfarePanel:RefreshContentUI()
	self:CloseAllContent()
	local selectTabId = self.selectTabId + 1
	if selectTabId == WelfareConst.WelfareType.OnlineReward then
		if self.onlineRewardContent then
			self.onlineRewardContent:RefershData()
			self.onlineRewardContent:SetVisible(true)
		end
	elseif selectTabId == WelfareConst.WelfareType.BindPhone then
		if self.accountPanel then
			self.accountPanel:SetVisible(true)
		end
	elseif selectTabId == WelfareConst.WelfareType.Sign then
		if self:IsSignPanelExist() then
			self.signPanel:SetVisible(true)
			self.signPanel:RefreshUI()
		end
	elseif selectTabId == WelfareConst.WelfareType.LevelingMadman  then
		if self.levelingMadmanContent then
			self.levelingMadmanContent:SetVisible(true)
		end
	elseif selectTabId == WelfareConst.WelfareType.WildRage  then
		if self.improveBattleContent then
			self.improveBattleContent:SetVisible(true)
		end
	elseif selectTabId == WelfareConst.WelfareType.RewardCode  then
		if self.rewardCodePanel then
			self.rewardCodePanel:SetVisible(true)
		end	
	elseif selectTabId == WelfareConst.WelfareType.Identify then
		if self.identifyPanel then
			self.identifyPanel:SetVisible(true)
		end		
	end
	self:RefreshRed()
end

function WelfarePanel:IsSignPanelExist()
	return self.signPanel and self.signPanel.ui
end

function WelfarePanel:RefreshRed()
	if not self.tabs then return end
	local tabCfgData = self.oldTabData
	if (not TableIsEmpty(tabCfgData)) then
		for i = 1, #self.tabs do
			local idx = tonumber( tabCfgData[i][1] )
			local tab = self.tabs[tonumber(idx)]
			if idx == WelfareConst.WelfareType.Sign then
				tab:GetChild("red").visible = SignModel:GetInstance():GetRed()
			elseif idx == WelfareConst.WelfareType.OnlineReward then
				tab:GetChild("red").visible = WelfareModel:GetInstance():IsHasOnlineRewardCanGet()
			elseif idx == WelfareConst.WelfareType.LevelingMadman and WelfareModel:GetInstance():GetHuoDongTime() > 0 then
				tab:GetChild("red").visible = PowerModel:GetInstance():IsHasOnlevelRewardCanGet()
			elseif idx == WelfareConst.WelfareType.WildRage and WelfareModel:GetInstance():GetHuoDongTime() > 0 then
				tab:GetChild("red").visible = PowerModel:GetInstance():IsHasOnbattleRewardCanGet()
			elseif idx == WelfareConst.WelfareType.BindPhone then
				tab:GetChild("red").visible = false
			-- elseif idx == WelfareConst.WelfareType.Identify then
			-- 	tab:GetChild("red").visible = false
			end
		end
	else
		for i = 1, #self.tabs do
			self.tabs[i]:GetChild("red").visible = false
		end
	end
end

function WelfarePanel:CloseAllContent()
	if self.onlineRewardContent then
		self.onlineRewardContent:SetVisible(false)
	end
	if self.accountPanel then
		self.accountPanel:SetVisible(false)
	end
	if self:IsSignPanelExist() then
		self.signPanel:SetVisible(false)
	end
	if self.levelingMadmanContent then
		self.levelingMadmanContent:SetVisible(false)
	end
	if self.improveBattleContent then
		self.improveBattleContent:SetVisible(false)
	end
	if self.rewardCodePanel then
		self.rewardCodePanel:SetVisible(false)
	end
	if self.identifyPanel then
		self.identifyPanel:SetVisible(false)
	end
end

function WelfarePanel:HandleGetOnlineReward(e)
	local rewardId = e
	
	if rewardId ~= 0 then
		if self.onlineRewardContent then
			self.onlineRewardContent:RefershStateUI(rewardId)
		end
	end
end
---------------------------------
--[[function WelfarePanel:HandleGetOnLevelReward(e)
	local LevelrewardId = e
	if LevelrewardId ~= 0 then
		if self.levelingMadmanContent then
			self.levelingMadmanContent:RefershStateUI(LevelrewardId)
		end
	end
end--]]

function WelfarePanel:HandleSyncOnlineRewardList(e)
	if self.onlineRewardContent then 
		self.onlineRewardContent:RefershUI()
	end
end

--[[function WelfarePanel:HandleSyncOnLevelRewardList(e)
	if self.levelingMadmanContent then 
		for i=1,6 do
			self.levelingMadmanContent:RegistLevelButton(i)
		end
		
	end
end--]]

--[[function WelfarePanel:HandleSyncOnBattleRewardList(e)
	if self.improveBattleContent then 
		for i=1,6 do
			self.improveBattleContent:RegistBattleButton(i)
		end
		
	end
end--]]

function WelfarePanel:ShowOnlineRewardRedTips()
	local tabCfgData = self.oldTabData
	local tabIdx = tabCfgData[WelfareConst.WelfareType.OnlineReward][1] or -1
	if not TableIsEmpty(tabCfgData) and tabIdx ~= -1 then
		self.tabs[tonumber(tabIdx)]:GetChild("red").visible = WelfareModel:GetInstance():IsHasOnlineRewardCanGet()
	end
end

function WelfarePanel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.eventHandler0)
	GlobalDispatcher:RemoveEventListener(self.eventHandler1)
	GlobalDispatcher:RemoveEventListener(self.signRedChangeHandler)
end

function WelfarePanel:__delete()
	if self.onlineRewardContent then
		self.onlineRewardContent:Destroy()
	end
	if self.levelingMadmanContent then
		self.levelingMadmanContent:Destroy()
	end
	if self.improveBattleContent then
		self.improveBattleContent:Destroy()
	end
	if self.rewardCodePanel then
		self.rewardCodePanel:Destroy()
	end

	if self.identifyPanel then
		self.identifyPanel:Destroy()
	end
	
	SignController:GetInstance():DestroyFuliPanel()
	self.signPanel = nil
	AccountController:GetInstance():DestroyAccountPanel()
	self.accountPanel = nil
	self.onlineRewardContent = nil
	self.levelingMadmanContent = nil
	self.improveBattleContent = nil
	self.rewardCodePanel = nil
	self:CleanEvent()
	self.oldTabData = {}
end

function WelfarePanel:Close()
	if self:IsSignPanelExist() and self.signPanel.DestoryGrids then
		self.signPanel:DestoryGrids()
	end
	CommonBackGround.Close(self)
end
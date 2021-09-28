-- 主面板:背包
PlayerInfoView = BaseClass(CommonBackGround)

function PlayerInfoView:__init()
	self.infoPanel = nil
	self.wakanPanel = nil
	self.stylePanel = nil

	resMgr:AddUIAB("PlayerInfo")
	self:Config()
	self:InitEvent()
end

-- 配置
function PlayerInfoView:Config()
	self.id = "PlayerInfoView"
	self.showBtnClose = true
	-- self.titleName = "背包" -- self.titleNameRes = "Icon/Title/a1"
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="js03", res1="js02", id="0", red=false}, 
		{label="", res0="sz01", res1="sz00", id="1", red=false},
		{label="", res0="yy00", res1="yy01", id="2", red=false},
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil

	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("属  性")
			if not self.infoPanel then
				self.infoPanel = PlayerInfoUI.New()
				self.infoPanel:InitPanel()
				self.container:AddChild(self.infoPanel.ui)
			end
			self.infoPanel:OnOpenHanlder()
			-- self.infoPanel:CreatePlayerModel()
			cur = self.infoPanel
		elseif id == "1" then
			self:SetTitle("时  装")
			if not self.stylePanel then
				self.stylePanel = StyleController:GetInstance():GetStylePanel()
				self.stylePanel:SetXY(140, 124)
				self.container:AddChild(self.stylePanel.ui)
			end
			cur = self.stylePanel

		elseif id == "2" then
			self:SetTitle("翅  膀")
			if not self.wakanPanel then
				local activeIds = WingModel:GetInstance():GetActiveWingIds()
				self.wakanPanel = WingController:GetInstance():GetWingPanel(activeIds)
				self.wakanPanel:SetXY(143, 104)
				self.container:AddChild(self.wakanPanel.ui)
			end
			cur = self.wakanPanel
		end

		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
				-- if self.isFinishLayout then -- 在布局完成才调用（不要让打开回调与这里一起回调）
				-- 	cur:Refresh() -- 更新当前面板数据（每个面板切换时更新）
				-- end
			end
		end
		--self:SetTabarTips(id, false)
	end
end

-- 事件监听
function PlayerInfoView:InitEvent()
	self.closeCallback = function ()
		if self.infoPanel then
			self.infoPanel:Close()
		end
		StyleController:GetInstance():Close()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end

	self.openCallback = function()
		self:InitRedTips()
	end
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.MAINUI_RED_TIPS , function(data) self:HandlerRedTips(data) end)
end

function PlayerInfoView:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function PlayerInfoView:HandlerRedTips(data)
	if not TableIsEmpty(data) then
		if data.moduleId == FunctionConst.FunEnum.playerInfo then
			self:SetTabarTips("0" , data.state)
		end
	end
end

function PlayerInfoView:InitRedTips()
	--显示属性页签红点
	local isNeedShowRedTisp = PlayerInfoModel:GetInstance():IsEquipSlotNeedShowRedTips()
	self:SetTabarTips("0" , isNeedShowRedTisp)
	

	--其他待定
end

-- 重构打开
function PlayerInfoView:Open(tabIndex)
	CommonBackGround.Open(self)
	
	if tabIndex then
		self:SetSelectTabbar(tabIndex)
	else
		self:SetSelectTabbar(0)
	end
	if self.selectPanel == WakanController:GetInstance():GetWakanPanel() then
		self.selectPanel:DefaultSet()
	end
end

-- 各个面板这里布局
function PlayerInfoView:Layout()
	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
end

function PlayerInfoView:__delete()
	self:CleanEvent()
	if self.infoPanel  then
		self.infoPanel:Destroy()
	end
	self.infoPanel = nil
	if self.stylePanel  then
		self.stylePanel:Destroy()
	end
	self.stylePanel = nil
	if self.wakanPanel  then
		self.wakanPanel:Destroy()
	end
	self.wakanPanel = nil
	WingController:GetInstance():DestroyWingPanel()
	StyleController:GetInstance():DestroyStylePanel()
end
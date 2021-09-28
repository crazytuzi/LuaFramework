TradingMainPanel  = BaseClass(CommonBackGround)

function TradingMainPanel:__init()
	resMgr:AddUIAB("Trading")
	self:Config()
	self:InitEvent()
end

function TradingMainPanel:Config()
	self.id = "TradingMainPanel"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="sd01", res1="sd00", id=TradingConst.tabType.store, red=false}, 
		{label="", res0="js01", res1="js00", id=TradingConst.tabType.stall, red=false}
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == TradingConst.tabType.store then
			self:SetTitle("商  店")
			if not self.storePanel then
				self.storePanel = StorePanel.New(self.container)
			end
			cur = self.storePanel
		elseif id == TradingConst.tabType.stall then
			self:SetTitle("寄  售")
			if not self.stallPanel then -- 摊位
				self.stallPanel = StallPanel.New(self.container)
			end
			cur = self.stallPanel
		end

		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
				if self.isFinishLayout then -- 在布局完成才调用（不要让打开回调与这里一起回调）
					cur:Update() -- 更新当前面板数据（每个面板切换时更新）
				end
			end
		end
		self:SetTabarTips(id, false)
	end

	self.tradingModel = TradingModel:GetInstance()
end
-- 重构打开
function TradingMainPanel:Open()
	if self:IsOpen() then -- 已经打开，就切换指定标签
		
	else
		CommonBackGround.Open(self)
	end
end

-- 仅一次布局
function TradingMainPanel:Layout()
	-- 这里多界面不作处理
	if SHENHE then
		self:SetTabbarVisible( TradingConst.tabType.stall, false )
	end
end

function TradingMainPanel:InitEvent()
	self.openCallback = function () -- 打开回调
		if self.tradingModel.tabType then
			self:SetSelectTabbar( self.tradingModel.tabType )
			self.tradingModel.tabType = nil
		end
		if self.selectPanel then
			self.selectPanel:Update()
		end
	end
	self.closeCallback = function () 
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end -- 关闭回调

	
end

function TradingMainPanel:__delete()
	if self.storePanel then self.storePanel:Destroy() end
	if self.stallPanel then self.stallPanel:Destroy() end
	self.storePanel = nil
	self.stallPanel = nil
	self.selectPanel = nil
end
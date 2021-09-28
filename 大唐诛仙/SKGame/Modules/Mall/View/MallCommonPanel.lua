-- 主面板:商城
MallCommonPanel = BaseClass(CommonBackGround)

function MallCommonPanel:__init(itemId, mallTabId)
	self.model = MallModel:GetInstance()

	self.id = "MallCommonPanel"
	-- self.titleName = "背包" -- self.titleNameRes = "Icon/Title/a1"
	self.showBtnClose = true

	self.openTopUI = true
	self.openResources = {1, 2}

	if not SHENHE then 
		self.tabBar = {
			{label="", res0="sc01", res1="sc00", id="0", red=false},
			{label="", res0="vip00", res1="vip01", id="1", red=false},
			{label="", res0="cz00", res1="cz01", id="2", red=false}
		}
	else
		self.tabBar = {
			{label="", res0="sc01", res1="sc00", id="0", red=false}
		}
	end
	self:_LayoutTabBar_()---------------
	self:AddChouDai()
	self.selectPanel = nil
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("商  城")
			if not self.mallPanel then
				self.mallPanel = MallPanel.New()
				if itemId then
					self:LocationItem(itemId)
				else
					if mallTabId then
						self:LocationTab(mallTabId)
					end
				end
				self.mallPanel:SetXY(133, 115)
				self.container:AddChild(self.mallPanel.ui)
			end
			cur = self.mallPanel
		elseif id == "1" then
			self:SetTitle("尊贵VIP特权")
			if not self.vipPanel then
				resMgr:AddUIAB("Vip")
				self.vipPanel = VipPanel.New()
				self.vipPanel:SetXY(147,115)
				self.container:AddChild(self.vipPanel.ui)
			end
			cur = self.vipPanel	
		elseif id == "2" then
			self:SetTitle("充  值")
			if not self.payPanel then
				resMgr:AddUIAB("Pay")
				self.payPanel = PayPanel.New()
				self.payPanel:SetXY(127,125)
				self.container:AddChild(self.payPanel.ui)
			end
			cur = self.payPanel
		end

		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
			end
		end
	end
	self.closeCallBack = nil
	self.openCallback = function()
		self:SetRed()
	end
	self:AddEvent()
end

function MallCommonPanel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.VipDailyState, function()  --全局事件
		self:SetRed()
	end)
end

function MallCommonPanel:SetRed()
	local model = VipModel:GetInstance()
	local isFirRed = false
	for i,v in ipairs(model.lqStateTab) do
		if v == 1 then
			isFirRed = true
			break
		end
	end
	if model.isDailyLQ == 0 or (model.vipId > 0 and model.isWelfareDaily == 0) or isFirRed then
		self:SetTabarTips(1, true)
	else
		self:SetTabarTips(1, false)
	end
end

function MallCommonPanel:Refresh()
	if self.mallPanel then
		self.mallPanel:RefreshPage()
	end
end

function MallCommonPanel:LocationItem(marketId)
	if self.mallPanel then
		self.mallPanel:LocationItem(marketId)
	end
end

function MallCommonPanel:LocationTab(tabId)
	if self.mallPanel then
		self.mallPanel:LocationTab(tabId)
	end
end

function MallCommonPanel:SetCloseCallBack(closeCallBack)
	self.closeCallBack = closeCallBack
end

function MallCommonPanel:Open(tabIndex)
	CommonBackGround.Open(self)
	
	if tabIndex then
		self:SetSelectTabbar(tabIndex)
	else
		self:SetSelectTabbar(0)
	end
end

function MallCommonPanel:Close()
	CommonBackGround.Close(self)
	if self.closeCallBack then
		self.closeCallBack()
		self.closeCallBack = nil
	end
end

-- 各个面板这里布局
function MallCommonPanel:Layout()
	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
end

function MallCommonPanel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	if self.mallPanel then
		self.mallPanel:Destroy()
	end
	self.mallPanel = nil
	if self.vipPanel then
		self.vipPanel:Destroy()
	end
	self.vipPanel = nil
	if self.payPanel then
		self.payPanel:Destroy()
	end
	self.payPanel = nil
	self.selectPanel = nil
	self.closeCallBack = nil
end
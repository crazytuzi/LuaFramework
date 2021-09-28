RegistModules("Mall/MallConst")
RegistModules("Mall/MallModel")
RegistModules("Mall/MallView")

--商城
RegistModules("Mall/View/Mall/MallItem")
RegistModules("Mall/View/Mall/MallPanel")
RegistModules("Mall/View/Mall/MallBuyPanel")

RegistModules("Mall/View/MallCommonPanel")

MallController =BaseClass(LuaController)

function MallController:GetInstance()
	if MallController.inst == nil then
		MallController.inst = MallController.New()
	end
	return MallController.inst
end

function MallController:__init()
	self.model = MallModel:GetInstance()
	self.view = nil

	self:InitEvent()
	self:RegistProto()

	self.openMarketId = nil
	self.openMallTabId = nil
	self.openTabIndex = nil
	self.closeCallBack = nil
end

function MallController:InitEvent()
	
end

-- 协议注册
function MallController:RegistProto()
	self:RegistProtocal("S_MarketBuy") --商城物品购买
	self:RegistProtocal("S_GetMarketItemList") --商城物品列表
end

function MallController:S_GetMarketItemList(buff)
	local msg = self:ParseMsg(market_pb.S_GetMarketItemList(), buff)
	self.model:SetBuyInfoByList(msg.marketItemList)

	if not self.view then
		self.view = MallView.New()
	end
	self.view:OpenMallPanel(self.openMarketId, self.openTabIndex, self.openMallTabId, self.closeCallBack)
	self.openMarketId = nil
	self.openTabIndex = nil
	self.openMallTabId = nil
	self.closeCallBack = nil
end

function MallController:S_MarketBuy(buff)
	local msg = self:ParseMsg(market_pb.S_MarketBuy(), buff)
	self.model:SetBuyInfo(msg.marketId, msg.curBuyNum)
end

-- 请求购买信息
function MallController:ReqBuyInfo()
	local msg = market_pb.C_GetMarketItemList()
	self:SendMsg("C_GetMarketItemList", msg)
end

-- 请求购买 useFlag：是否快捷使用
function MallController:ReqBuy(marketId, num, useFlag)
	local msg = market_pb.C_MarketBuy()
	msg.marketId = marketId
	msg.num = num
	msg.useFlag = useFlag
	self:SendMsg("C_MarketBuy", msg)
end

function MallController:OpenMallPanel(marketId, tabIndex, mallTabId, closeCallBack)
	self.openMarketId = marketId or nil
	self.openTabIndex = tabIndex or 0
	self.openMallTabId = mallTabId or nil
	self.closeCallBack = closeCallBack
	self:ReqBuyInfo()
end

function MallController:Close()
	if self.view then 
		self.view:Close()
	end
end

--快速购买
--@param marketId 商品编号
--@param closeCallBack 关闭回调
function MallController:QuickBuy(marketId, closeCallBack)
	local data = self.model:QuickIndex(marketId)
	if not data then 
		return
	end
	local callBack = closeCallBack
	local mallBuyPanel = MallBuyPanel.New()
	mallBuyPanel:Update(data, function()
		if callBack then
			callBack()
		end
	end)
	UIMgr.ShowCenterPopup(mallBuyPanel)
end

function MallController:__delete()
	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	self.openMarketId = nil
	self.openMallTabId = nil
	self.openTabIndex = nil

	MallController.inst = nil
	MallView.isInited = nil
end
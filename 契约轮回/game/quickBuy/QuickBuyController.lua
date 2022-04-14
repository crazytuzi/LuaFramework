require('game.quickBuy.RequireQuickBuy')
QuickBuyController = QuickBuyController or class("QuickBuyController",BaseController)
local QuickBuyController = QuickBuyController

function QuickBuyController:ctor()
	QuickBuyController.Instance = self
	self.model = QuickBuyModel:GetInstance()
	self.global_events = {}
	self:AddEvents()
	self:RegisterAllProtocal()
end

function QuickBuyController:dctor()
	GlobalEvent:RemoveTabListener(self.global_events)
end

function QuickBuyController:GetInstance()
	if not QuickBuyController.Instance then
		QuickBuyController.new()
	end
	return QuickBuyController.Instance
end

function QuickBuyController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写

end

function QuickBuyController:AddEvents()

	local function call_back(data)
		--打开快捷购买界面
		lua_panelMgr:GetPanelOrCreate(QuickBuyPanel):Open(data)
	end
	GlobalEvent:AddListener(QuickBuyEvent.OpenQuickBuyPanel, call_back)

	
end
















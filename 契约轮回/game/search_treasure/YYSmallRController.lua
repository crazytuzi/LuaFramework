YYSmallRController = YYSmallRController or class("YYSmallRController",BaseController)
local YYSmallRController = YYSmallRController

function YYSmallRController:ctor()
	YYSmallRController.Instance = self
	self.model = YYSmallRModel:GetInstance()
	self.global_events = {}
	self:AddEvents()
	self:RegisterAllProtocal()
end

function YYSmallRController:dctor()
	GlobalEvent:RemoveTabListener(self.global_events)
end

function YYSmallRController:GetInstance()
	if not YYSmallRController.Instance then
		YYSmallRController.new()
	end
	return YYSmallRController.Instance
end

function YYSmallRController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写

end

function YYSmallRController:AddEvents()

	local function call_back()
		--打开小R活动面板
		local id_list = OperateModel:GetInstance():GetSmallRActIds()
		table.sort(id_list)
		lua_panelMgr:GetPanelOrCreate(YYSmallRPanel):Open(id_list)
	end
	GlobalEvent:AddListener(SearchTreasureEvent.OpenYYSmallRPanel, call_back)

	
end
















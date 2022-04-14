require('game.casthouse.RequireCasthouse')
CasthouseController = CasthouseController or class("CasthouseController",BaseController)
local CasthouseController = CasthouseController

function CasthouseController:ctor()
	CasthouseController.Instance = self
	self.model = CasthouseModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function CasthouseController:dctor()
end

function CasthouseController:GetInstance()
	if not CasthouseController.Instance then
		CasthouseController.new()
	end
	return CasthouseController.Instance
end

function CasthouseController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1139_casthouse_pb"
    self:RegisterProtocal(proto.CASTHOUSE_INFO, self.HandleInfo)
    self:RegisterProtocal(proto.CASTHOUSE_START, self.HandleStart)
    self:RegisterProtocal(proto.CASTHOUSE_REWARD, self.HandleReward)
    self:RegisterProtocal(proto.CASTHOUSE_RESET, self.HandleReset)
end

function CasthouseController:AddEvents()
	
	local function call_back()
		lua_panelMgr:GetPanelOrCreate(CastHousePanel):Open()
	end
	GlobalEvent:AddListener(CasthouseEvent.OpenCasthousePanel, call_back)

	local function call_back(data)
		local cfg = Config.db_casthouse[1]
		local maxfreecount = cfg.free_count
		local flag = data.sezi_count < maxfreecount
		GlobalEvent:Brocast(MainEvent.ChangeRedDot, "casthouse", flag)
		GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 49, flag)
	end
	self.model:AddListener(CasthouseEvent.UpdateInfo, call_back)
	self.model:AddListener(CasthouseEvent.UpdateSezi, call_back)
end

-- overwrite
function CasthouseController:GameStart()
	local function call_back()
		self:RequestInfo()
	end
	GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.VLow)
end

----请求基本信息
function CasthouseController:RequestInfo()
	local pb = self:GetPbObject("m_casthouse_info_tos")
	self:WriteMsg(proto.CASTHOUSE_INFO,pb)
end

----服务的返回信息
function CasthouseController:HandleInfo(  )
	local data = self:ReadMsg("m_casthouse_info_toc")

	self.model:Brocast(CasthouseEvent.UpdateInfo, data)
end

function CasthouseController:RequestStart()
	local pb = self:GetPbObject("m_casthouse_start_tos")
	self:WriteMsg(proto.CASTHOUSE_START,pb)
end

function CasthouseController:HandleStart( )
	local data = self:ReadMsg("m_casthouse_start_toc")

	self.model:Brocast(CasthouseEvent.UpdateSezi, data)
end


function CasthouseController:RequestReward()
	local pb = self:GetPbObject("m_casthouse_reward_tos")
	self:WriteMsg(proto.CASTHOUSE_REWARD,pb)
end

function CasthouseController:HandleReward( )
	local data = self:ReadMsg("m_casthouse_reward_toc")

	self.model:Brocast(CasthouseEvent.UpdateGrid, data)
	if not Config.db_casthouse_grid[data.grid+1] then
		lua_panelMgr:GetPanelOrCreate(CasthouseResultPanel):Open(data.item_ids)
	end
end

function CasthouseController:RequestReset()
	local pb = self:GetPbObject("m_casthouse_reset_tos")
	self:WriteMsg(proto.CASTHOUSE_RESET,pb)
end

function CasthouseController:HandleReset( )
	local data = self:ReadMsg("m_casthouse_reset_toc")
	Notify.ShowText("Reset successful")
end

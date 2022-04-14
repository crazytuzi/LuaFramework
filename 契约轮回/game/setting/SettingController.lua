require('game.setting.RequireSetting')
SettingController = SettingController or class("SettingController",BaseController)
local SettingController = SettingController

function SettingController:ctor()
	SettingController.Instance = self
	self.model = SettingModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function SettingController:dctor()
end

function SettingController:GetInstance()
	if not SettingController.Instance then
		SettingController.new()
	end
	return SettingController.Instance
end

function SettingController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1127_afk_pb"
    self:RegisterProtocal(proto.AFK_INFO, self.HandleAfkInfo)
    self:RegisterProtocal(proto.AFK_SETTLE, self.HandleAfkSettle)
end

function SettingController:AddEvents()
	-- --请求基本信息
	
	local function call_back( ... )
		lua_panelMgr:GetPanelOrCreate(SettingPanel):Open()
	end
	GlobalEvent:AddListener(SettingEvent.OpenPanel, call_back)

	local function call_back()
		DailyModel:GetInstance():GoCurHookPos()
	end
	GlobalEvent:AddListener(SettingEvent.AutoPlay, call_back)
end

-- overwrite
function SettingController:GameStart()
	self:RequestAfkInfo()
	
	local function ok_func()
		local hour = math.floor(self.model.afk_time/3600)
		if hour < 1 and RoleInfoModel:GetInstance():GetMainRoleLevel() >= 65 then
			local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
			local item = AutoTipPanel(UITransform)
			item:SetData(11005)
		end
	end
	GlobalSchedule:StartOnce(ok_func, Constant.GameStartReqLevel.Low)
end

----请求基本信息
function SettingController:RequestAfkInfo()
	local pb = self:GetPbObject("m_afk_info_tos")
	self:WriteMsg(proto.AFK_INFO,pb)
end

----服务的返回信息
function SettingController:HandleAfkInfo(  )
	local data = self:ReadMsg("m_afk_info_toc")
	local time = data.time

	self.model:SetAfkTime(time)
	self.model:Brocast(SettingEvent.UpdateAfkInfo, time)
	GlobalEvent:Brocast(SettingEvent.UpdateAfkInfo)
end


function SettingController:HandleAfkSettle()
	local data = self:ReadMsg("m_afk_settle_toc")
	local rewards = data.rewards
	if not table.isempty(rewards) then
		lua_panelMgr:GetPanelOrCreate(AutoPlayRewardPanel):Open(data)
	end
end



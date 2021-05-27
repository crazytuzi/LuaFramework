require("scripts/game/city_pool_fight/city_pool_fight_data")
require("scripts/game/city_pool_fight/city_pool_fight_view")

-- 城池争霸
CityPoolFightCtrl = CityPoolFightCtrl or BaseClass(BaseController)

function CityPoolFightCtrl:__init()
	if CityPoolFightCtrl.Instance ~= nil then
		ErrorLog("[CityPoolFightCtrl] attempt to create singleton twice!")
		return
	end
	CityPoolFightCtrl.Instance = self

	self.data = CityPoolFightData.New()
	self.view = CityPoolFightView.New(ViewName.CityPoolFight)
	self:RegisterAllProtocols()
	self:RegisterAllEvents()
end

function CityPoolFightCtrl:__delete()
	CityPoolFightCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

end

function CityPoolFightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCityPoolFightGuildList, "OnCityPoolFightGuildList")
	self:RegisterProtocol(SCCityPoolFightState, "OnCityPoolFightState")
	self:RegisterProtocol(SCCityPoolFightWinName, "OnCityPoolFightWinName")
	
end

function CityPoolFightCtrl:RegisterAllEvents()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
end

function CityPoolFightCtrl:OnRecvMainRoleInfo()
	CityPoolFightCtrl.CityPoolFightGuildListReq()
	CityPoolFightCtrl.CityPoolFightStateReq()
	CityPoolFightCtrl.CityPoolFightWinGuildReq()
end

--========================下发=====================

-- 城战参战行会列表
function CityPoolFightCtrl:OnCityPoolFightGuildList(protocol)
	self.data:SetJoinWarGuildList(protocol)
	self.view:Flush(0, "guild_name_list")

	-- print("攻城行会列表")
	-- PrintTable(protocol)
end

-- 城战的状态
function CityPoolFightCtrl:OnCityPoolFightState(protocol)
	self.data:SetCityPoolWarState(protocol)
	-- self.view:Flush()
end

-- 城战获胜行会名
function CityPoolFightCtrl:OnCityPoolFightWinName(protocol)
	self.data:SetCityPoolWinGuildName(protocol)
	self.view:Flush(0, "guild_name_list")
end


--=======================请求========================

-- 申请城池战
function CityPoolFightCtrl.ApplyCityPoolFight()
	local protocol = ProtocolPool.Instance:GetProtocol(CSApplyCityPoolFightReq)
	protocol:EncodeAndSend()
end

-- 获取行会争夺列表
function CityPoolFightCtrl.CityPoolFightGuildListReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCityPoolFightGuildListReq)
	protocol:EncodeAndSend()
end

-- 获取行会争夺战的状态
function CityPoolFightCtrl.CityPoolFightStateReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCityPoolFightStateReq)
	protocol:EncodeAndSend()
end

-- 行会争夺获胜方的名字
function CityPoolFightCtrl.CityPoolFightWinGuildReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCityPoolFightWinGuildReq)
	protocol:EncodeAndSend()
end
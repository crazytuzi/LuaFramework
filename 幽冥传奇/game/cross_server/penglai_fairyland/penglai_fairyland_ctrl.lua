require("scripts/game/cross_server/penglai_fairyland/penglai_fairyland_data")
require("scripts/game/cross_server/penglai_fairyland/penglai_fairyland_view")

PengLaiFairylandCtrl = PengLaiFairylandCtrl or BaseClass(BaseController)

function PengLaiFairylandCtrl:__init()
	if PengLaiFairylandCtrl.Instance then
		ErrorLog("[PengLaiFairylandCtrl]:Attempt to create singleton twice!")
	end
	PengLaiFairylandCtrl.Instance = self
	require("scripts/game/cross_server/penglai_fairyland/penglai_fairyland_sub_view").New(ViewDef.PengLaiFairyland.PengLaiFairylandSub)
	require("scripts/game/cross_server/penglai_fairyland/lucky_flop_sub_view").New(ViewDef.PengLaiFairyland.LuckyFlopSub)
	self.data = PengLaiFairylandData.New()
	self.view = PengLaiFairylandView.New(ViewDef.PengLaiFairyland)
	self:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self:RegisterAllProtocals()
end

function PengLaiFairylandCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCPengLaiFairylandInfo, "OnPengLaiFairylandInfo")
	-- self:RegisterProtocol(SCCrossBrandInfo, "OnSCCrossBrandInfo")
end

function PengLaiFairylandCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil
end

-- 上线请求
function PengLaiFairylandCtrl:OnRecvMainRoleInfo()
	self:SendInfoReq()
end

function PengLaiFairylandCtrl:SendInfoReq()
	PengLaiFairylandCtrl.SendPengLaiInfo(1)
end

-------------------------------------
-- 幸运翻牌 begin
-------------------------------------

-- 请求幸运翻牌信息/翻牌
function PengLaiFairylandCtrl.SendTurnLuckyFlop(brand_index)
	PengLaiFairylandCtrl.SendTurnLuckyFlopOpt(1, brand_index)
end

-- 请求幸运翻牌信息/翻牌
function PengLaiFairylandCtrl.SendTurnLuckyFlopOpt(opt_type, brand_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossTurnBrandReq)
	-- protocol.fuben_index = 1
	protocol.opt_type = opt_type
	protocol.brand_index = brand_index
	protocol:EncodeAndSend()
end

-- 下发翻牌信息
function PengLaiFairylandCtrl:OnSCCrossBrandInfo(protocol)
	local brand_num = #PengLaiXianJieCfg.allCards
	for i = 1, brand_num do 
		protocol.brands_data[i] = {prize_pool_index = bit:_and(protocol.prize_pool_index_data, 255), item_index = bit:_and(protocol.item_index_data, 255)}
		protocol.prize_pool_index_data = bit:_rshift(protocol.prize_pool_index_data, 8)
		protocol.item_index_data = bit:_rshift(protocol.item_index_data, 8)
	end
	self.data:SetLuckyFlopInfo(protocol)
end

-------------------------------------
-- 幸运翻牌 end
-------------------------------------

-------------------------------------
-- 蓬莱仙界 begin
-------------------------------------

-- 请求蓬莱仙界信息/购买击杀次数
function PengLaiFairylandCtrl.SendPengLaiInfo(req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerBossPengLai)
	protocol.req_type = req_type
	protocol:EncodeAndSend()
end

-- 下发蓬莱仙界信息
function PengLaiFairylandCtrl:OnPengLaiFairylandInfo(protocol)
	self.data:SetPengLaiInfo(protocol)
end

-------------------------------------
-- 蓬莱仙界 end
-------------------------------------
require("game/honour/honour_data")
require("game/honour/honour_view")
require("game/honour/span_battle_view")
require("game/honour/span_battle_data")

HonourCtrl = HonourCtrl or BaseClass(BaseController)
function HonourCtrl:__init()
	if HonourCtrl.Instance ~= nil then
		print_error("[ElementBattleCtrl] attempt to create singleton twice!")
		return
	end
	HonourCtrl.Instance = self
	self.view = HonourView.New(ViewName.HonourView)
	self.data = HonourData.New()

	self.spanBattle_view = SpanBattleView.New(ViewName.SpanBattleView)
	self.span_battle_data = SpanBattleData.New()
	
	self:RegisterAllProtocols()
end

function HonourCtrl:__delete()
	if self.span_battle_data ~= nil then
		self.span_battle_data:DeleteMe()
		self.span_battle_data = nil
	end
	if self.spanBattle_view ~= nil then
		self.spanBattle_view:DeleteMe()
		self.spanBattle_view = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	HonourCtrl.Instance = nil
end

function HonourCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossMedalInfo, "OnSCCrossMedalInfo")
end

--0请求信息，1升级
function HonourCtrl:SendHonourInfo(param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMedalReq)
	send_protocol.param = param or 0
	send_protocol:EncodeAndSend()
end

function HonourCtrl:OnSCCrossMedalInfo(protocol)
	self.data:SetHonourInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.Honour)
end
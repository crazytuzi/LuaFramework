require ("game/xianzunka/xianzunka_data")
require ("game/xianzunka/xianzunka_view")
require ("game/xianzunka/xianzunka_dec_view")

XianzunkaCtrl = XianzunkaCtrl or BaseClass(BaseController)

function XianzunkaCtrl:__init()
	if 	XianzunkaCtrl.Instance ~= nil then
		print("[XianzunkaCtrl] attempt to create singleton twice!")
		return
	end
	XianzunkaCtrl.Instance = self
	self.data = XianzunkaData.New()
	self.view = XianzunkaView.New(ViewName.XianzunkaView)
	self.dec_view = XianzunkaDecView.New(ViewName.XianzunkaDecView)
	self:RegisterAllProtocols()
end

function XianzunkaCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.dec_view then
		self.dec_view:DeleteMe()
		self.dec_view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	XianzunkaCtrl.Instance = nil
end

function XianzunkaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCXianZunKaAllInfo, "OnXianZunKaAllInfo")
end

function XianzunkaCtrl:OpenXIanzunkaDecView(data)
	self.dec_view:SetData(data)
	self.dec_view:Open()
end

function XianzunkaCtrl:OnXianZunKaAllInfo(protocol)
	self.data:SetXianZunKaInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Xianzunka)
end

--购买仙尊卡
function XianzunkaCtrl.SendXianZunKaOperaBuyReq(card_type)
	XianzunkaCtrl.SendXianZunKaOperaReq(XIANZUNKA_OPERA_REQ_TYPE.BUY_CARD, card_type)
end

--拿取每日奖励
function XianzunkaCtrl.SendXianZunKaOperaRewardReq(card_type)
	XianzunkaCtrl.SendXianZunKaOperaReq(XIANZUNKA_OPERA_REQ_TYPE.FETCH_DAILY_REWARD, card_type)
end

function XianzunkaCtrl.SendXianZunKaOperaReq(opera_req_type, param_1, param_2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXianZunKaOperaReq)
	send_protocol.opera_req_type = opera_req_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol:EncodeAndSend()
end

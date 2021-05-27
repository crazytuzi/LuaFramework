require("scripts/game/grab_redenvelope/grab_redenvelope_data")
require("scripts/game/grab_redenvelope/grab_redenvelope_view")
require("scripts/game/grab_redenvelope/grab_redenvelope_tip_view")
GrabRedEnvelopeCtrl = GrabRedEnvelopeCtrl or BaseClass(BaseController)
function GrabRedEnvelopeCtrl:__init()
	if GrabRedEnvelopeCtrl.Instance then
		ErrorLog("[GrabRedEnvelopeCtrl] Attemp to create a singleton twice !")
	end
	GrabRedEnvelopeCtrl.Instance = self
		
	self.view  = GrabRedEnvelopeView.New(ViewDef.GrapRobRedEnvelope)
	self.data = GrabRedEnvelopeData.New()

	self.tip_view = GrabRedEnvelopeTipView.New(ViewDef.GrapRobRedEnvelopeTip)
	self:RegisterAllProtocols()
end

function GrabRedEnvelopeCtrl:__delete()
	GrabRedEnvelopeCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil
	
	self.data:DeleteMe()
	self.data = nil

	self.tip_view:DeleteMe()
	self.tip_view = nil

	if self.login_info_event then
		self:UnBindGlobalEvent(self.login_info_event)
		self.login_info_event = nil
	end

	if self.pass_data_event then
		self:UnBindGlobalEvent(self.pass_data_event)
		self.pass_data_event = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end

function GrabRedEnvelopeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCChargeRedEnvlopeData, "OnChargeRedEnvlopeData")
	self.login_info_event = self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
	self.pass_data_event = self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind(self.OnPassDay, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	self.num = 0
end

function GrabRedEnvelopeCtrl:OnPassDay()
	
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
		if ViewManager.Instance:CanOpen(ViewDef.GrapRobRedEnvelope) then
			self:SendGetChargeRedEnvlopeData()
		end
		if self.delay_timer then
			GlobalTimerQuest:CancelQuest(self.delay_timer)
			self.delay_timer = nil
		end
	end, 0.5)
		
end


function GrabRedEnvelopeCtrl:RecvMainInfoCallBack()
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
		if ViewManager.Instance:CanOpen(ViewDef.GrapRobRedEnvelope) then
			self:SendGetChargeRedEnvlopeData()
		end
		if self.delay_timer then
			GlobalTimerQuest:CancelQuest(self.delay_timer)
			self.delay_timer = nil
		end
	end, 0.5)

end


--抢红包
function GrabRedEnvelopeCtrl:SendGrapRedEnvlopeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGrapRedEnvlopeReq)
	protocol:EncodeAndSend()
end

--领取红包
function GrabRedEnvelopeCtrl:SendGetRewardReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetRedEnvlopeRewardReq)
	protocol:EncodeAndSend()
end


--请求充值红包数据
function GrabRedEnvelopeCtrl:SendGetChargeRedEnvlopeData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetChargeRedEnvlopeReq)
	protocol:EncodeAndSend()
end


function GrabRedEnvelopeCtrl:OnChargeRedEnvlopeData(protocol)
	self.data:SetOnChargeRedEnvlopeData(protocol)
	if self.data:HadGetAll() then
		if ViewManager.Instance:IsOpen(ViewDef.GrapRobRedEnvelope) then
			if self.view then
				self.view:CloseView()
			end
		end
	end
	self.num = 1
end

function GrabRedEnvelopeCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL then
		if self.num == 0 then --未请求过数据，等级变换的时候请求一次
			if ViewManager.Instance:CanOpen(ViewDef.GrapRobRedEnvelope) then
				self:SendGetChargeRedEnvlopeData()
			end
		end
	end
end

-- CSGrapRedEnvlopeReq = CSGrapRedEnvlopeReq or BaseClass(BaseProtocolStruct)
-- function CSGrapRedEnvlopeReq:__init()
-- 	self:InitMsgType(139, 104)
-- end

-- function CSGrapRedEnvlopeReq:Encode()
-- 	self:WriteBegin()
-- end

-- --===领取红包
-- CSGetRedEnvlopeRewardReq = CSGetRedEnvlopeRewardReq or BaseClass(BaseProtocolStruct)
-- function CSGetRedEnvlopeRewardReq:__init()
-- 	self:InitMsgType(139, 105)
-- end

-- function CSGetRedEnvlopeRewardReq:Encode()
-- 	self:WriteBegin()
-- end

-- --请求充值红包数据
-- CSGetChargeRedEnvlopeReq = CSGetChargeRedEnvlopeReq or BaseClass(BaseProtocolStruct)
-- function CSGetChargeRedEnvlopeReq:__init()
-- 	self:InitMsgType(139, 106)
-- end

-- function CSGetChargeRedEnvlopeReq:Encode()
-- 	self:WriteBegin()
-- end


-- SCChargeRedEnvlopeData = SCChargeRedEnvlopeData or BaseClass(BaseProtocolStruct)
-- function SCChargeRedEnvlopeData:__init( ... )
-- 	self:InitMsgType(139, 95)
-- 	self.zs_num = 0
-- 	self.reward_flag = 0
-- 	self.first_charge = 0
-- 	self.cur_level = 0
-- 	self.red_envlope_gold = 0
-- 	self.record = "" 
-- end


-- function SCChargeRedEnvlopeData:Decode( ... )
-- 	self.zs_num = MsgAdapter.ReadUInt()
-- 	self.reward_flag = MsgAdapter.ReadUInt()
-- 	self.first_charge = MsgAdapter.ReadUChar()
-- 	self.cur_level = MsgAdapter.ReadUChar()
-- 	self.red_envlope_gold = MsgAdapter.ReadUInt()
-- 	self.record = MsgAdapter.ReadStr()
-- end


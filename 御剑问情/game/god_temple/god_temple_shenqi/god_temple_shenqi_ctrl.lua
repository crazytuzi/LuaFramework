require("game/god_temple/god_temple_shenqi/god_temple_shenqi_data")

GodTempleShenQiCtrl = GodTempleShenQiCtrl or BaseClass(BaseController)

function GodTempleShenQiCtrl:__init()
	if GodTempleShenQiCtrl.Instance ~= nil then
		ErrorLog("[GodTempleShenQiCtrl] attempt to create singleton twice!")
		return
	end

	GodTempleShenQiCtrl.Instance = self

	self.data = GodTempleShenQiData.New()

	self:RegisterProtocols()
end

function GodTempleShenQiCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	self:StopTimeQuest()

	GodTempleShenQiCtrl.Instance = nil
end

function GodTempleShenQiCtrl:RegisterProtocols()
	self:RegisterProtocol(CSPataFbNewShenQiInfoReq)
	self:RegisterProtocol(CSPataFbNewGetSheneqiExp)
	self:RegisterProtocol(SCPataFbNewShenQiInfo, "OnPataFbNewShenQiInfo")
end

--请求神器信息
function GodTempleShenQiCtrl:ReqPataFbNewShenQiInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPataFbNewShenQiInfoReq)
	send_protocol:EncodeAndSend()
end

--领取经验
function GodTempleShenQiCtrl:ReqPataFbNewGetSheneqiExp()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPataFbNewGetSheneqiExp)
	send_protocol:EncodeAndSend()
end

local is_first = false
function GodTempleShenQiCtrl:OnPataFbNewShenQiInfo(protocol)
	--判断是不是第一次进这条协议，为了处理神器升级的情况
	if not is_first then
		is_first = true
		self.data:SetInfo(protocol, true)
	else
		self.data:SetInfo(protocol)
	end
	if ViewManager.Instance:IsOpen(ViewName.GodTempleView) then
		ViewManager.Instance:FlushView(ViewName.GodTempleView, "shenqi")
	end

	RemindManager.Instance:Fire(RemindName.GodTemple_ShenQi)

	self:CheckCanReqInfo()
end

function GodTempleShenQiCtrl:StopTimeQuest()
	if self.check_exp_time_quest then
		GlobalTimerQuest:CancelQuest(self.check_exp_time_quest)
		self.check_exp_time_quest = nil
	end
end

--检查是否可以请求信息
function GodTempleShenQiCtrl:CheckCanReqInfo()
	self:StopTimeQuest()
	if self.data:CalcRemind() > 0 then
		--经验已满
		return
	end

	local next_flush_exp_timestamp = self.data:GetNextFlushExpTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local delay_time = next_flush_exp_timestamp - server_time 
	if delay_time > 0 then
		self:StartTimeQuest(delay_time)
	end
end

function GodTempleShenQiCtrl:StartTimeQuest(delay_time)
	self.check_exp_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self:ReqPataFbNewShenQiInfo()
	end, delay_time)
end
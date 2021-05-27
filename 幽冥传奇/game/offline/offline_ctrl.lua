require("scripts/game/offline/offline_data")
require("scripts/game/offline/exp_award_view")

OfflineCtrl = OfflineCtrl or BaseClass(BaseController)

function OfflineCtrl:__init()
	if OfflineCtrl.Instance then
		ErrorLog("[OfflineCtrl]:Attempt to create singleton twice!")
	end
	OfflineCtrl.Instance = self
	
	self.data = OfflineData.New()

	self.exp_award_view = ExpAwardView.New(ViewDef.ExpAward)	--试炼经验奖励
	
	self:RegisterAllProtocols()
	
	self.stop_click = true
	if AgentAdapter.GetSpid and AgentAdapter:GetSpid() == "dev" then
		self.stop_click = false
	end
	
	self.start_online_time = 0
end

function OfflineCtrl:__delete()
	
	self.exp_award_view:DeleteMe()
	self.exp_award_view = nil
	
	self.data:DeleteMe()
	self.data = nil
	
	self.stop_click = nil
	
	OfflineCtrl.Instance = nil

end

function OfflineCtrl:RegisterAllProtocols()
	--同一面板显示
	self:RegisterProtocol(SCOfflineGuajiInfo, "OnOfflineGuajiInfo")
	-- self:RegisterProtocol(SCTQOfflineGuajiInfo, "OnTQOfflineGuajiInfo")
	-- self:RegisterProtocol(SCExpAwardInfo, "OnExpAwardInfo")

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuajiReward)
end

function OfflineCtrl:OnExpAwardInfo(protocol)
	-- self.exp_award_view:Flush(0, "all", {exp_num = protocol.exp_num, online_time = Status.NowTime - self.start_online_time})	
end

function OfflineCtrl:GetOnlineTime()
	return Status.NowTime - self.start_online_time
end

function OfflineCtrl:OnTQOfflineGuajiInfo(protocol)
	-- if IS_ON_CROSSSERVER then
	-- 	return
	-- end
	
	-- if protocol.tq_exp_num <= 0 then return end 	--小于0 不弹出

	-- self.view:Open()
	-- GlobalTimerQuest:AddDelayTimer(function ()
	-- 	self.view:Flush(0, "all", {tq_exp_num = protocol.tq_exp_num, offline_time = protocol.offline_time})
	-- end, 0)
end

function OfflineCtrl:OnOfflineGuajiInfo(protocol)
	if IS_ON_CROSSSERVER then
		return
	end

	local msg_id = protocol.msg_id

	self.data:SetData(protocol)
	if msg_id == OfflineData.REQ_ID.INFO then
		if protocol.results == 0 then return end 	-- 没奖励不弹出
		ViewManager:OpenViewByDef(ViewDef.Activity.Offline)
	end

	self.start_online_time = Status.NowTime
end

--开始挂机
function OfflineCtrl.SendOfflineBeginReq(map_index)
	OfflineCtrl.SendOfflineGuajiReq(OfflineData.REQ_ID.BEGIN, map_index)
end

--领取离线挂机奖励
function OfflineCtrl.SendOfflineReward(id)
	OfflineCtrl.SendOfflineGuajiReq(OfflineData.REQ_ID.OFFLINE_REWARD, id)
end

--挂机信息
function OfflineCtrl.SendOfflineInfoReq()
	OfflineCtrl.SendOfflineGuajiReq(OfflineData.REQ_ID.INFO)
end

--停止在线挂机
function OfflineCtrl.SendOfflineStopReq()
	OfflineCtrl.SendOfflineGuajiReq(OfflineData.REQ_ID.STOP)
end

function OfflineCtrl.SendOfflineGuajiReq(msg_id, id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOfflineGuajiReq)
	protocol.msg_id = msg_id
	protocol.id = id
	protocol:EncodeAndSend()
end

--请求试炼奖励 在线经验
function OfflineCtrl.SendOfflineVipReward()	
	local protocol = ProtocolPool.Instance:GetProtocol(CSExpAwardReq)
	protocol.id = 1
	protocol:EncodeAndSend()
end

--请求领取离线奖励
function OfflineCtrl.SendOfflineLingqu()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOfflineExpAwardReq)
	protocol.id = 2
	protocol:EncodeAndSend()
end



function OfflineCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.GuajiReward then
		return self.data:GetRewardRemind()
	end
	return 0
end 
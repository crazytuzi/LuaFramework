require("scripts/game/combinedserveract/combinedserveract_data")
require("scripts/game/combinedserveract/combinedserveract_view")

-- 开服活动
CombinedServerActCtrl = CombinedServerActCtrl or BaseClass(BaseController)

function CombinedServerActCtrl:__init()
	if	CombinedServerActCtrl.Instance then
		ErrorLog("[CombinedServerActCtrl]:Attempt to create singleton twice!")
	end
	CombinedServerActCtrl.Instance = self

	self.data = CombinedServerActData.New()
	self.view = CombinedServerActView.New(ViewDef.CombineServAct)

	self:RegisterAllProtocols()
end

function CombinedServerActCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil


	CombinedServerActCtrl.Instance = nil
end

function CombinedServerActCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCombinedActReqResult, "OnCombinedActReqResult")
	self:RegisterProtocol(SCCombinedActInfo, "OnCombinedActInfo")
	self:RegisterProtocol(SCClearCombinedServDZPLog, "OnClearCombinedServDZPLog")
	self:RegisterProtocol(SCombinedServDZPLog, "OnombinedServDZPLog")
	self:RegisterProtocol(SCOneCombinedServDZPLog, "OnOneCombinedServDZPLog")
    self:RegisterProtocol(SCCombinedActAccumul, "OnChargeInfo")
   

	GlobalEventSystem:Bind(OtherEventType.COMBINED_DAY_CHANGE, BindTool.Bind(self.CombinedDayChangeCallBack, self))
	self:RegisterAllRemind()
end

function CombinedServerActCtrl:RegisterAllRemind()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CombinedServGCZReward)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CombinedServFashionReward)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CombinedServDZPCount)
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CombinedServLJCZReward)
end

function CombinedServerActCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.CombinedServGCZReward then
		return self.data:GetRemindNum(remind_name)
	elseif remind_name == RemindName.CombinedServFashionReward then
		return self.data:GetRemindNum(remind_name)
	elseif remind_name == RemindName.CombinedServDZPCount then
		return self.data:GetRemindNum(remind_name)
    elseif remind_name == RemindName.CombinedServLJCZReward then
		return self.data:GetRemindNum(remind_name)
	end
end

function CombinedServerActCtrl:CombinedDayChangeCallBack(combined_day)
	if combined_day > 0 and combined_day <= GlobalConfig.combineSvrFifthDay then
		for k,v in pairs(CombinedActId) do
			CombinedServerActCtrl.SendSendCombinedInfo(v)
		end 
		CombinedServerActCtrl.SendGetCombinedServDZPLogReq()
	else
		ViewManager.Instance:Close(ViewDef.CombineServAct)
	end
	-- if ViewManager.Instance then
	-- 	ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "icon_pos")
	-- end
end


function CombinedServerActCtrl:OnCombinedActReqResult(protocol)
	if CombinedActId.Fashion == protocol.act_id then
		local info = self.data:GetActInfo(CombinedActId.Fashion)
		if nil ~= info then
			info.reward_count = protocol.result
		end
		RemindManager.Instance:DoRemind(RemindName.CombinedServFashionReward)
    elseif CombinedActId.Accumulative == protocol.act_id then
        self.data.act_info[CombinedActId.Accumulative].accumul_state = protocol.result
        RemindManager.Instance:DoRemind(RemindName.CombinedServLJCZReward)
	elseif CombinedActId.DZP == protocol.act_id then
		local info = self.data:GetActInfo(CombinedActId.DZP)
		if nil ~= info then
			info.reward_count = protocol.result
		end
		RemindManager.Instance:DoRemind(RemindName.CombinedServDZPCount)
	end
	self.view:Flush(CombinedServerActData.GetIndexByActId(protocol.act_id), "result" , {act_id = protocol.act_id, result = protocol.result})
end

function CombinedServerActCtrl:OnCombinedActInfo(protocol)
	self.data:SetCombinedServData(protocol)
	if protocol.act_id == CombinedActId.Gongcheng then
		RemindManager.Instance:DoRemind(RemindName.CombinedServGCZReward)
	elseif protocol.act_id == CombinedActId.Fashion then
		RemindManager.Instance:DoRemind(RemindName.CombinedServFashionReward)
	elseif protocol.act_id == CombinedActId.DZP then
		RemindManager.Instance:DoRemind(RemindName.CombinedServDZPCount)
    elseif protocol.act_id == CombinedActId.Accumulative then
		RemindManager.Instance:DoRemind(RemindName.CombinedServLJCZReward)
	end
	
	self.view:Flush(CombinedServerActData.GetIndexByActId(protocol.act_id))
end

function CombinedServerActCtrl:OnClearCombinedServDZPLog(protocol)
	self.data:ClearDZPRewardLog()
	self.view:Flush(CombinedServerActData.GetIndexByActId(CombinedActId.DZP))
end

function CombinedServerActCtrl:OnombinedServDZPLog(protocol)
	self.data:SetDZPRewardLog(protocol.dzp_log)
	self.view:Flush(CombinedServerActData.GetIndexByActId(CombinedActId.DZP))
end

function CombinedServerActCtrl:OnOneCombinedServDZPLog(protocol)
	self.data:AddDZPRewardLog(protocol)
    RemindManager.Instance:DoRemind(RemindName.CombinedServDZPCount)
	self.view:Flush(CombinedServerActData.GetIndexByActId(CombinedActId.DZP))
end

function CombinedServerActCtrl:OnChargeInfo(protocol)
    self.data:SetCombinedAccumulData(protocol)
--    if CombinedActId.Accumulative == protocol.act_id then
        RemindManager.Instance:DoRemind(RemindName.CombinedServLJCZReward)
        self.view:Flush(CombinedServerActData.GetIndexByActId(CombinedActId.Accumulative))
--	end
    
end
--合区活动处理
function CombinedServerActCtrl.SendSendCombinedReq(act_id, act_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendCombinedReq)
	protocol.act_id = act_id
    if(nil ~= act_level) then
        protocol.level = act_level
    end
	protocol:EncodeAndSend()
end

--合区活动信息(139,192)
function CombinedServerActCtrl.SendSendCombinedInfo(act_id)
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSSendCombinedInfo)
	-- protocol.act_id = act_id
	-- protocol:EncodeAndSend()
end

--获取合区全服奖记录
function CombinedServerActCtrl.SendGetCombinedServDZPLogReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetCombinedServDZPLogReq)
	RemindManager.Instance:DoRemind(RemindName.CombinedServDZPCount)
	protocol:EncodeAndSend()
end
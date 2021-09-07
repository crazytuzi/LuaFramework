ActiviteHongBaoData = ActiviteHongBaoData or BaseClass()
ActHongBaoFlag = {
	CanGet = 0,
	HasGet = 1,
}

function ActiviteHongBaoData:__init()
	if ActiviteHongBaoData.Instance ~= nil then
		ErrorLog("[ActiviteHongBaoData] Attemp to create a singleton twice !")
	end
	ActiviteHongBaoData.Instance = self
	self.consume_gold_num_list = {}
	self.reward_flag = 0
	self.randactivity_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	
	RemindManager.Instance:Register(RemindName.ActHongBao, BindTool.Bind(self.GetMarryMeRemind, self))
end

function ActiviteHongBaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ActHongBao)
	
	ActiviteHongBaoData.Instance = nil
end

function ActiviteHongBaoData:SetRARedEnvelopeGiftInfo(protocol)
	self.consume_gold_num_list = protocol.consume_gold_num_list
	self.reward_flag = protocol.reward_flag
end

function ActiviteHongBaoData:GetDiamondNum()
	return self.consume_gold_num_list
end

function ActiviteHongBaoData:GetFlag()
	return self.reward_flag
end

function ActiviteHongBaoData:GetRebateTotalVal()
	local return_percent = self.randactivity_cfg.red_envelope_gift[1].percent / 10000
	local total_val = 0
	for i = 1, 7 do
		total_val = total_val + self.consume_gold_num_list[i] * return_percent - self.consume_gold_num_list[i] * return_percent % 1
	end
	return total_val
end


function ActiviteHongBaoData:GetRebateDayVal(day)
	local return_percent = self.randactivity_cfg.red_envelope_gift[1].percent / 10000
	if self.consume_gold_num_list[day] ~= nil then
		return self.consume_gold_num_list[day] * return_percent - self.consume_gold_num_list[day] * return_percent % 1
	end
end

function ActiviteHongBaoData:GetReturnPercent()
	return self.randactivity_cfg.red_envelope_gift[1].percent / 100
end

function ActiviteHongBaoData:GetMarryMeRemind()
	if TimeCtrl.Instance:GetCurOpenServerDay() > GameEnum.NEW_SERVER_DAYS then
		return 1
	end

	return 0
end
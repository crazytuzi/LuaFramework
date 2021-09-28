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
	self.has_read =	false

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

function ActiviteHongBaoData:GetFlag(day)
	local index = day - 1
	local bit_list = bit:d2b(self.reward_flag)
	return bit_list[32 - index]
end

function ActiviteHongBaoData:IsGetAll()
	local is_get_all = true
	for i = 1, 7 do
		if self:GetRebateDayVal(i) ~= 0 then
			if self:GetFlag(i) == 0 then
				is_get_all = false
			end
		end
	end
	return is_get_all
end

function ActiviteHongBaoData:GetRebateTotalVal()
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local return_percent = cfg.red_envelope_gift[1].percent / 10000
	local total_val = 0
	for i = 1, 7 do
		total_val = total_val + self.consume_gold_num_list[i] * return_percent - self.consume_gold_num_list[i] * return_percent % 1
	end
	return total_val
end

function ActiviteHongBaoData:GetRebateDayVal(day)
	local cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local return_percent = cfg.red_envelope_gift[1].percent / 10000
	if self.consume_gold_num_list[day] ~= nil then
		return self.consume_gold_num_list[day] * return_percent - self.consume_gold_num_list[day] * return_percent % 1
	end
end

function ActiviteHongBaoData:TurnIsRead()
	self.has_read = true

end

function ActiviteHongBaoData:IsRead()
	return self.has_read
end

function ActiviteHongBaoData:GetHongBaoRemind()
	local is_show_rpt = false
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local remind_day = UnityEngine.PlayerPrefs.GetInt(main_role_id.."hongbao_remind_day") or cur_day						--红点一天只提醒一次

	if TimeCtrl.Instance:GetCurOpenServerDay() < 8 then
		if cur_day ~= -1 and cur_day ~= remind_day then
			is_show_rpt = true 
		end
	end
	return is_show_rpt
end
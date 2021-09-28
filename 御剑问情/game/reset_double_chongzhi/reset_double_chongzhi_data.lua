ResetDoubleChongzhiData = PuTianTongQingData or BaseClass()

function ResetDoubleChongzhiData:__init()
	if ResetDoubleChongzhiData.Instance then
		print_error("[ResetDoubleChongzhiData] Attemp to create a singleton twice !")
	end
	ResetDoubleChongzhiData.Instance = self

	self.chong_zhi_info = {
		chongzhi_reward_flag = 0,
	}
end

function ResetDoubleChongzhiData:__delete()
	ResetDoubleChongzhiData.Instance = nil
end

function ResetDoubleChongzhiData:SetChongzhiInfo(protocol)
	if not protocol then return end

	if not self.chong_zhi_info then
		self.chong_zhi_info = {}
	end

	self.chong_zhi_info.chongzhi_reward_flag = protocol.chongzhi_reward_flag or 0
end

function ResetDoubleChongzhiData:GetChongzhiInfo()
	return self.chong_zhi_info
end

function ResetDoubleChongzhiData:CheckIsFirstRechargeById(index)
	if not index or index < 0 then return true end

	if self.chong_zhi_info and self.chong_zhi_info.chongzhi_reward_flag then
		local flag = bit:d2b(self.chong_zhi_info.chongzhi_reward_flag)

		if flag and flag[32 - index] then
			return flag[32 - index] == 1
		end
	end

	return true
end

function ResetDoubleChongzhiData:IsAllRecharge()
	local cfg = RechargeData.Instance:GetRechargeIdList()

	if cfg then
		local is_all = true

		for k, v in pairs(cfg) do
			local is_charge = self:CheckIsFirstRechargeById(v)

			if not is_charge then
				is_all = false
				break
			end
		end

		return is_all
	end

	return true
end

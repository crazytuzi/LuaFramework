GuanggaoData = GuanggaoData or BaseClass()

function GuanggaoData:__init()
	if GuanggaoData.Instance then
		ErrorLog("[GuanggaoData]:Attempt to create singleton twice!")
	end
	GuanggaoData.Instance = self

	self.rew_state = {}

end

function GuanggaoData:__delete()
	GuanggaoData.Instance = nil
end

function GuanggaoData:SetRewardInfo(protocol)
	self.rew_state = protocol.reward_state
end

function GuanggaoData:GetRewardState()
	return self.rew_state
end

function GuanggaoData:GetBtnShowState(index)
	for k, v in pairs(self.rew_state) do
		if k == index then
			return v.state
		end
	end
end
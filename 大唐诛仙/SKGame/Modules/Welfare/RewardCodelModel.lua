RewardCodelModel = BaseClass(LuaModel)

function RewardCodelModel:GetInstance()
	if RewardCodelModel.inst == nil then
		RewardCodelModel.inst = RewardCodelModel.New()
	end
	return RewardCodelModel.inst
end

function RewardCodelModel:__init( ... )
	self:Reset()
	self:AddEvent()
end

function RewardCodelModel:Reset()

end

function RewardCodelModel:AddEvent()

end

function RewardCodelModel:__delete()
	RewardCodelModel.inst = nil
end
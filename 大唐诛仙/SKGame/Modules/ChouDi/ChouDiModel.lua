ChouDiModel = BaseClass(LuaModel)

function ChouDiModel:__init( ... )
	self.choudiList = {}
	self.enemyPlayerId = 0
	self.playerName = " "
	self.mapId = 0
end

function ChouDiModel:GetResMarketId(itemId)
	local id = 0
	local data = GetCfgData("market")
	for k , v in pairs(data) do
		if type(v) ~= 'function' and v and v.itemId == itemId then
			id = v.marketId
			break
		end
	end
	return id
end

function ChouDiModel:GetInstance()
	if ChouDiModel.inst == nil then
		ChouDiModel.inst = ChouDiModel.New()
	end
	return ChouDiModel.inst
end

function ChouDiModel:__delete(  )
	ChouDiModel.inst = nil
end
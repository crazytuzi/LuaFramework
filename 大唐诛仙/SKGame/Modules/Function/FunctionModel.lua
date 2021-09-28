FunctionModel =BaseClass(LuaModel)

function FunctionModel:__init()
	self:InitData()
	self:InitEvent()
end

function FunctionModel:__delete()
	FunctionModel.inst = nil
end

function FunctionModel:InitData()
			
end

function FunctionModel:InitEvent()

end

function FunctionModel:GetInstance()
	if FunctionModel.inst == nil then
		FunctionModel.inst = FunctionModel.New()
	end
	return FunctionModel.inst
end

--[[
	获取某个功能对应的NPC唯一ID
]]
function FunctionModel:GetNPCIdByFun(funType)
	local rtnNPCId = -1
	if funType then
		local npcCfg = GetCfgData("npc")
		for k , v in pairs(npcCfg) do
			if type(v) ~= 'function' then
				local funArr = v.functionId
				for index = 1, #funArr do
					if funArr[index] == funType then
						rtnNPCId = v.eid
						break
					end
				end
			end
		end
	end
	return rtnNPCId
end

function FunctionModel:IsOpenByFunId(funId)
	local rtnIsOpen = false
	if funId == FunctionConst.FunEnum.ConsignForSale then
		rtnIsOpen = TradingModel:GetInstance():IsConsignForSaleFunCanOpen()
	else
		rtnIsOpen = true
	end
	return rtnIsOpen
end
EquipmentStoreTipsModel = BaseClass(LuaModel)

function EquipmentStoreTipsModel:__init()
	self:InitData()
end

function EquipmentStoreTipsModel:__delete()
	self:CleanData()
end

function EquipmentStoreTipsModel:GetInstance()
	if EquipmentStoreTipsModel.inst == nil then
		EquipmentStoreTipsModel.inst = EquipmentStoreTipsModel.New()
	end
	return EquipmentStoreTipsModel.inst
end

function EquipmentStoreTipsModel:InitData()

end

function EquipmentStoreTipsModel:CleanData()

end


function EquipmentStoreTipsModel:IsCanPopup()
	local rtnIsCan = false
	local timeIsOk = false
	local sceneIsOk = false
	local isHasNewbieGuide = NewbieGuideModel:GetInstance():IsNeedNewbieGuide()
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()

	if mainPlayerVo then
		local playerId = mainPlayerVo.playerId
		local characterVo = LoginModel:GetInstance():GetRoleByPlayerId(playerId)
		if characterVo then
			local createTime = characterVo.createTime or 0
			--local formatCreateTime1 = TimeTool.GetTimeYMD(createTime)
			local endTime = characterVo.createTime + EquipmentStoreTipsConst.MaxExistDay * 60 * 60 * 24 * 1000
			--local formatEndTime1 = TimeTool.GetTimeYMD(endTime)

			local formatCreateTime = TimeTool.getYMD3(createTime)
			local formatEndTime = TimeTool.getYMD3(endTime)

			local startTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatCreateTime)
			local closeTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatEndTime)

			local curTime = TimeTool.GetCurTime() * 0.001

			if curTime >= startTime and curTime <= closeTime then
				timeIsOk = true
			end
		end
	end

	if SceneModel:GetInstance():IsMain() then
		sceneIsOk = true
	end

	if timeIsOk and sceneIsOk and (not isHasNewbieGuide) then
		rtnIsCan = true
	end

	return rtnIsCan
end

function EquipmentStoreTipsModel:IsClose()
	local isClose = true
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayerVo then
		local playerId = mainPlayerVo.playerId
		local characterVo = LoginModel:GetInstance():GetRoleByPlayerId(playerId)
		if characterVo then
			local createTime = characterVo.createTime or 0
			local endTime = characterVo.createTime + EquipmentStoreTipsConst.MaxExistDay * 60 * 60 * 24 * 1000

			local formatCreateTime = TimeTool.getYMD3(createTime)
			local formatEndTime = TimeTool.getYMD3(endTime)

			local startTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatCreateTime)
			local closeTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatEndTime)

			local curTime = TimeTool.GetCurTime() * 0.001

			if curTime >= startTime and curTime <= closeTime then
				isClose = false
			end
		end
	end
	return isClose
end

function EquipmentStoreTipsModel:GetStartEndTime(outputType)
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	local formatCreateTime = 0
	local formatEndTime = 0
	local createTime = 0
	local endTime = 0
	if mainPlayerVo then
		local playerId = mainPlayerVo.playerId
		local characterVo = LoginModel:GetInstance():GetRoleByPlayerId(playerId)
		if characterVo then
			createTime = characterVo.createTime or 0
			endTime = characterVo.createTime + EquipmentStoreTipsConst.MaxExistDay * 60 * 60 * 24 * 1000
			if outputType == 1 then
				formatCreateTime = TimeTool.GetTimeYMD2(createTime)
				local endTime2 = endTime - 60 * 60 * 24 * 1000 --显示减一天
				formatEndTime = TimeTool.GetTimeYMD2(endTime2)
			else
				formatCreateTime = TimeTool.GetTimeYMD(createTime)
				formatEndTime = TimeTool.GetTimeYMD(endTime)
			end
		end

	end
	return createTime , endTime , formatCreateTime , formatEndTime
end

function EquipmentStoreTipsModel:Reset()

end
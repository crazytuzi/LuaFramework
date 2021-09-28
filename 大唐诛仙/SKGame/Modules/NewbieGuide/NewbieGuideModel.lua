NewbieGuideModel = BaseClass(LuaModel)

function NewbieGuideModel:__init()
	self:InitData()
end

function NewbieGuideModel:__delete()
	self:CleanData()
	NewbieGuideModel.inst = nil
end

function NewbieGuideModel:GetInstance()
	if NewbieGuideModel.inst == nil then
		NewbieGuideModel.inst = NewbieGuideModel.New()
	end
	return NewbieGuideModel.inst
end

function NewbieGuideModel:InitData()
	self.guideData = {} --当前所有的引导VO数据
	self.curGuideData = {} --当前正在执行的引导VO数据
	self.curGuideStep = 0 --当前正在执行的引导步骤数
	self.mainUICtrl = MainUIController:GetInstance()
end

function NewbieGuideModel:CleanData()
	self:CleanAllGuideData()
	self:CleanCurGuideData()
	self:CleanCurGuideStep()
	self.mainUICtrl = nil
end

--[[
	设置当前所有的引导VO
]]
function NewbieGuideModel:SetAllGuideData()
	self:CleanAllGuideData()
	self.guideData = {}

	local isNeedHasGuideId = true
	local guideTaskList = TaskModel:GetInstance():GetGuideTaskList(isNeedHasGuideId)
	for index = 1, #guideTaskList do
		local curTaskDataObj = guideTaskList[index]		
		if not TableIsEmpty(curTaskDataObj) then
			local newbieGuideVo = NewbieGuideVo.New({taskId = curTaskDataObj:GetTaskId() , guideId = curTaskDataObj:GetGuideId()})
			if newbieGuideVo then
				table.insert(self.guideData , newbieGuideVo)
			end
		end
	end
end

--更新当前引导VO
function NewbieGuideModel:UpdateAllGuideData()
	local isNeedHasGuideId = true
	local newList = TaskModel:GetInstance():GetGuideTaskList(isNeedHasGuideId)

	if not TableIsEmpty(self.curGuideData) then
		self:DestroyGuideData(self.curGuideData:GetGuideId())
	end

	if newList and #newList > 0 then
		for index = 1, #newList do
			local curTaskDataObj = newList[index]	
			if not TableIsEmpty(curTaskDataObj) then
				local rtnIsHas , rtnIndex = self:IsHasNewbieGuide(curTaskDataObj:GetTaskId())
				if rtnIsHas == true and rtnIndex ~= -1 then
					--当前已经拥有
				else
					local newbieGuideVo = NewbieGuideVo.New({taskId = curTaskDataObj:GetTaskId() , guideId = curTaskDataObj:GetGuideId()})
					if newbieGuideVo then
						table.insert(self.guideData , newbieGuideVo)
					end
				end
			end
		end
	end
end

function NewbieGuideModel:DestroyGuideData(guideId)
	if guideId then
		for index , guideDataVo in pairs(self.guideData) do
			if not TableIsEmpty(guideDataVo) and guideDataVo:GetGuideId() == guideId then
				table.remove(self.guideData , index)
				break
			end
		end
	end
end

--当前是否拥有某个引导（任务Id和引导ID是一一对应关系）
function NewbieGuideModel:IsHasNewbieGuide(taskId)
	local rtnIsHas = false
	local rtnIndex = -1
	if taskId ~= nil then
		for index, guideDataVo in pairs(self.guideData) do
			if guideDataVo:GetTaskId() == taskId then
				rtnIsHas = true
				rtnIndex = index
				break
			end
		end
	end
	return rtnIsHas, rtnIndex
end


--[[
	获取当前所有的引导VO
]]
function NewbieGuideModel:GetAllGuideData()
	return self.guideData
end

--[[
	清除当前所有的引导VO
]]
function NewbieGuideModel:CleanAllGuideData()
	if self.guideData then
		for index = 1 , #self.guideData do
			self.guideData[index]:Destroy()
			self.guideData[index] = nil
		end
		self.guideData = nil
	end
end

--[[
	引导表中是否包含引导ID为guideId的数据
]]
function NewbieGuideModel:IsHasGuideInCfg(guideId)
	local isHas = false
	if guideId then
		local guideCfg = GetCfgData("FunctionGuide"):Get(guideId)
		if guideCfg then
			isHas = true
		end
	end
	return isHas
end

--[[
	设置当前正在执行的引导VO数据
]]
function NewbieGuideModel:SetCurGuideData(guideTaskId)
	if guideTaskId then
		self.curGuideData = {}
		for index = 1 , #self.guideData do
			local newbieGuideVo = self.guideData[index]
			if not TableIsEmpty(newbieGuideVo) then
				if newbieGuideVo:GetTaskId() == guideTaskId then
					self.curGuideData = newbieGuideVo
					break
				end
			end
		end
	end
end

--[[
	获取当前正在执行的引导VO数据
]]
function NewbieGuideModel:GetCurGuideData()
	return self.curGuideData
end

--[[
	清除当前正在执行的引导VO数据
]]
function NewbieGuideModel:CleanCurGuideData()
	if not TableIsEmpty(self.curGuideData) then
		self.curGuideData:Destroy()
		self.curGuideData = nil
	end
end

--[[
	获取某个引导的对应引导表数据
]]
function NewbieGuideModel:GetGuideCfg(guideId)
	local rtnCfg = {}
	if guideId then
		rtnCfg = GetCfgData("FunctionGuide"):Get(guideId) or {}
	end
	return rtnCfg
end

--[[
	获取当前引导步骤对应的引导参数
]]
function NewbieGuideModel:GetCurGuideStepParam()
	local rtnGuideParam = {}
	if not TableIsEmpty(self.curGuideData) then
		local guideId = self.curGuideData:GetGuideId()
		if guideId then
			guideCfg = self:GetGuideCfg(guideId)
			if not TableIsEmpty(guideCfg) then
				if guideCfg.param[self.curGuideStep] then
					rtnGuideParam = guideCfg.param[self.curGuideStep]
				end
			end
		end
	end
	return rtnGuideParam
end

--[[
	当前引导步骤是否结束
]]
function NewbieGuideModel:IsCurGuideStepEnd()
	local rtnIsEnd = false
	if not TableIsEmpty(self.curGuideData) then
		local guideId = self.curGuideData:GetGuideId()
		if guideId then
			guideCfg = self:GetGuideCfg(guideId)
			if not TableIsEmpty(guideCfg) then
				if #guideCfg.param < self.curGuideStep then
					rtnIsEnd = true
				end
			end
		end
	end
	return rtnIsEnd
end

--[[
	是否是当前的引导
]]
function NewbieGuideModel:IsCurGuide(guideTaskId)
	local rtnIs = false
	if not TableIsEmpty(self.curGuideData) then
		if guideTaskId then
			if self.curGuideData:GetTaskId() == guideTaskId then
				rtnIs = true
			end
		end
	end
	return rtnIs
end

--[[
	获取当前的引导对应的任务ID
]]
function NewbieGuideModel:GetCurGuideTaskId()
	local rtnTaskId = 0
	if not TableIsEmpty(self.curGuideData) then
		rtnTaskId = self.curGuideData:GetTaskId()
	end
	return rtnTaskId
end

--[[
	对当前的引导步骤进行累加
]]
function NewbieGuideModel:SetCurGuideStep()
	self.curGuideStep = self.curGuideStep + 1
end

--[[
	获取当前的引导步骤
]]
function NewbieGuideModel:GetCurGuideStep()
	return self.curGuideStep
end

--[[
	对当前的引导步骤置零
]]
function NewbieGuideModel:CleanCurGuideStep()
	self.curGuideStep = 0 --当前正在执行的引导步骤数
end

--[[
	获取某个引导对应的uiid
]]
function NewbieGuideModel:GetGuideUIID(guideId)
	local rtnUIID = ""
	if guideId then
		local guideCfg = self:GetGuideCfg(guideId)
		if not TableIsEmpty(guideCfg) then
			rtnUIID = guideCfg.uiid or ""
		end
	end
	return rtnUIID
end

--[[
	检测引导步骤是否需要做特殊处理
	--1.
]]
function NewbieGuideModel:IsNeedSpecialHandling(guideId)
	local rtnIsNeed = false
	local UIID = NewbieGuideConst.UIID
	local uiid = UIID.None
	if guideId then
		uiid = self:GetGuideUIID(guideId)
		if uiid ~= "" then
			if uiid == UIID.Skill then
				rtnIsNeed = true
			elseif uiid == UIID.GodFightRune then
				rtnIsNeed = true
			elseif uiid == UIID.Friend then
				rtnIsNeed = true
			elseif uiid == UIID.ZDMain then
				rtnIsNeed = true
			elseif uiid == UIID.Trading then
				rtnIsNeed = true
			end
		end
	end
	return rtnIsNeed , uiid
end

--[[
	对引导步骤进行特殊处理
]]
function NewbieGuideModel:DoSpecialHandling(guideId)
	if guideId then
		local isNeed , uiid = self:IsNeedSpecialHandling(guideId)
		local UIID = NewbieGuideConst.UIID
		if isNeed then
			local mainView = self.mainUICtrl:GetView()
			local mainCityUI = nil
			if mainView then mainCityUI = mainView:GetPanel() end

			--如果当前MainCityUI，处于主城模式，则跳过点击旋转按钮的引导，直接进入下一步,反之，正常进行引导步骤
			if uiid == UIID.Skill or
			 	uiid == UIID.GodFightRune or
				uiid ==	UIID.Friend	then
				if mainCityUI and mainCityUI:IsInCityUIState() then
					self:SetCurGuideStep()
					self:SetCurGuideStep()
				else
					self:SetCurGuideStep()
				end
			end

			--如果当前组队界面左侧的按钮被隐藏了，主动帮玩家恢复显示
			if uiid == UIID.ZDMain then
				if mainCityUI and mainCityUI:IsTaskTeamStateOut() then
					mainCityUI:SwitchTaskTeamStateIn()
				end

				if mainCityUI and mainCityUI:IsInTeamCtrl() then
					self:SetCurGuideStep()
					self:SetCurGuideStep()
				else
					self:SetCurGuideStep()
				end		
			end

			--如果主界面的Activites，主动帮玩家恢复显示
			if uiid == UIID.Trading then
				if mainCityUI and mainCityUI:GetActivitesVisible() == false then
					mainCityUI:OnBtnHideClick()
				end
				self:SetCurGuideStep()
			end
		end
	end
end

--[[
	对某个引导VO的execCnt进行累加
]]
function NewbieGuideModel:AddGuideExecCnt(guideId)
	if guideId then
		for index = 1 , #self.guideData do
			local curGuideData = self.guideData[index]
			if not TableIsEmpty(curGuideData) and curGuideData:GetGuideId() == guideId then
				curGuideData:AddExecCnt()
				break
			end
		end
	end
end

function NewbieGuideModel:GetGuideDataByGuideId(guideId)
	local rtnGuideData = {}
	if guideId then
		for index = 1, #self.guideData do
			local curGuideData = self.guideData[index]
			if not TableIsEmpty(curGuideData) and curGuideData:GetGuideId() == guideId then
				rtnGuideData = curGuideData
				break
			end
		end
	end
	return rtnGuideData
end

--是否具有技能升级引导任务
function NewbieGuideModel:IsHasSkillUpgradeGuide()
	local rtnIsHas = false
	for index = 1 , #self.guideData do
		local curGuideData = self.guideData[index]
		if not TableIsEmpty(curGuideData) and curGuideData:GetGuideId() == NewbieGuideConst.SkillUpgradeGuideID then
			rtnIsHas = true
			break
		end
	end
	return rtnIsHas
end

--是否拥有好友添加引导任务
function NewbieGuideModel:IsHasFriendAddGuide()
	local rtnIsHas = false
	for index = 1 , #self.guideData do
		local curGuideData = self.guideData[index]
		if not TableIsEmpty(curGuideData) and curGuideData:GetGuideId() == NewbieGuideConst.FriendAddGuideID then
			rtnIsHas = true
			break
		end
	end
	return rtnIsHas
end

function NewbieGuideModel:IsNewbieGuideRunning()
	if not TableIsEmpty(self.curGuideData) then
		return true
	else
		return false
	end
end

--是否含有待引导的新手引导
function NewbieGuideModel:IsNeedNewbieGuide()
	local rtnIsNeed = false
	for index , guideDataVo in pairs(self.guideData) do
		if not TableIsEmpty(guideDataVo) then
			rtnIsNeed = true
			break
		end
	end
	return rtnIsNeed
end

function NewbieGuideModel:Reset()
	self.guideData = {} --当前所有的引导VO数据
	self.curGuideData = {} --当前正在执行的引导VO数据
	self.curGuideStep = 0 --当前正在执行的引导步骤数
end
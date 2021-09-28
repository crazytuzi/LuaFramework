SkillModel =BaseClass(LuaModel)

function SkillModel:__init()
	self:InitEvent()
	self:InitData()
end

function SkillModel:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function()
		self:HandleBagChange()
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.BAG_INITED, function()
		self:HandleBagChange()
	end)
end

function SkillModel:InitData()
	self.skillUpCfg = GetCfgData("skillUp")
	self.skillCfg = nil
	self.skillMsgVoList = {} --当前已经拥有的技能VoList
	self.allSkillList = {} --当前职业的技能信息
	self.curLearnSkillId = -1 --当前正在学习的skillId
	self.previousLevSkillId = -1 --上一等级的skillId（当它为铭文时则为铭文id）
	self.skillBookData = {} --背包中的技能书数据
	self.curSelectSkillData = {}
end

function SkillModel:GetSkillVo(skillId)
	if not self.skillCfg then
		self.skillCfg = GetCfgData("skill_CellNewSkillCfg")
	end
	return self.skillCfg:Get(skillId)
end

function SkillModel:GetInstance()
	if SkillModel.inst == nil then
		SkillModel.inst = SkillModel.New()
	end
	return SkillModel.inst
end


------接入后台协议start
function SkillModel:SetSkillMsg(skillMsg)
	if skillMsg ~= nil then
		self.skillMsgVoList = {}
		for index = 1, #skillMsg do
			local curSkillMsgVo = SkillMsgVo.New()
			curSkillMsgVo:SetVo(skillMsg[index])
			table.insert(self.skillMsgVoList, curSkillMsgVo)
		end
	end
end

--同步技能熟练度
--包含两层意义：
--1.同步技能熟练度
--2.同步技能（当铭文技能id不为0时，用铭文技能id，否则用技能id）
function SkillModel:SyncSkillMastery(skillMsg)
	if skillMsg ~= nil then
		for msgIndex = 1, #skillMsg do
			local msgSkillIndex = self:GetSkillIndexById(skillMsg[msgIndex].skillId)
			for voIndex = 1, #self.skillMsgVoList do
				local voSkillIndex = self:GetSkillIndexById(self.skillMsgVoList[voIndex].id)
				if msgSkillIndex == voSkillIndex then
					local tempOldSkillId = -1
					if skillMsg[msgIndex].mwSkillId ~= 0 then
						--新增或者替换新的铭文id
						if self.skillMsgVoList[voIndex].id ~= skillMsg[msgIndex].mwSkillId then
							self.skillMsgVoList[voIndex].id = skillMsg[msgIndex].mwSkillId
							tempOldSkillId = skillMsg[msgIndex].skillId
							GlobalDispatcher:DispatchEvent(EventName.SkillUpgrade, {oldSkillId = skillMsg[msgIndex].skillId, newSkillId = skillMsg[msgIndex].mwSkillId})
						end
					else
						--卸下铭文id
						if not (self.skillMsgVoList[voIndex].skillId == skillMsg[msgIndex].skillId and self.skillMsgVoList[voIndex].mwSkillId == skillMsg[msgIndex].mwSkillId)  then
							self.skillMsgVoList[voIndex].id = skillMsg[msgIndex].skillId
							tempOldSkillId = self.skillMsgVoList[voIndex].mwSkillId
							GlobalDispatcher:DispatchEvent(EventName.SkillUpgrade, {oldSkillId = self.skillMsgVoList[voIndex].mwSkillId, newSkillId = skillMsg[msgIndex].skillId})
						end
					end

					self.skillMsgVoList[voIndex].skillId = skillMsg[msgIndex].skillId
					self.skillMsgVoList[voIndex].mwSkillId = skillMsg[msgIndex].mwSkillId
					self.skillMsgVoList[voIndex].mastery = skillMsg[msgIndex].mastery
					self.skillMsgVoList[voIndex].level = self:GetLevelBySkillId(self.skillMsgVoList[voIndex].id)

				
					if tempOldSkillId ~= -1  then
						local playerSkillMsg = {}
						playerSkillMsg.skillId = self.skillMsgVoList[voIndex].skillId
						playerSkillMsg.mastery = self.skillMsgVoList[voIndex].mastery
						playerSkillMsg.mwSkillId = self.skillMsgVoList[voIndex].mwSkillId

						self:UpgradeAllSkillMsg(tempOldSkillId, playerSkillMsg)
					end

					break
				end
			end
		end
	end
end

function SkillModel:SetCurLearnSkillId(skillId)
	if skillId then
		self.curLearnSkillId = skillId
	end
end

function SkillModel:GetCurLearnSkillId()
	return self.curLearnSkillId
end


function SkillModel:UpgradeSkillMsg(oldSkillId, newSkillMsg)
	if oldSkillId ~= nil and newSkillMsg ~= nil then
		--remove oldSkill
		for index = 1, #self.skillMsgVoList do
			if self.skillMsgVoList[index].id == oldSkillId or (self:GetSkillIndexById(self.skillMsgVoList[index].id) ==  self:GetSkillIndexById(oldSkillId)) then
				self.skillMsgVoList[index]:Destroy()
				table.remove(self.skillMsgVoList, index)
				break
			end
		end

		--add newSkill
		local newSKillMsgVo = SkillMsgVo.New()
		newSKillMsgVo:SetVo(newSkillMsg)
		table.insert(self.skillMsgVoList, newSKillMsgVo)
	end

end

function SkillModel:ActiveSkillMsg(skillMsg)
	if skillMsg then
		local newSkillMsgVo = SkillMsgVo.New()
		newSkillMsgVo:SetVo(skillMsg)
		table.insert(self.skillMsgVoList, newSkillMsgVo)
	end
end

--获取当前拥有的技能
function SkillModel:GetSkill()
	local rtnSkillIdList = {}
	for index = 1, #self.skillMsgVoList do
		table.insert(rtnSkillIdList, self.skillMsgVoList[index].id)
	end
	return rtnSkillIdList
end

--按类型获取技能Id
--@param skillType 1:普攻 ^1:非普攻
function SkillModel:GetSkillByType(skillType)
	local rtnSkillIdList = {}
	local skillVo = nil
	for index = 1, #self.skillMsgVoList do
		skillVo = self:GetSkillVo(self.skillMsgVoList[index].id)
		if skillVo then
			if skillType == 1 and skillVo.bIfNomalAttack == 1 then
				table.insert(rtnSkillIdList, {id = self.skillMsgVoList[index].id, index = skillVo.skillIndex})
			elseif skillType ~= 1 and skillVo.bIfNomalAttack ~= 1 then
				table.insert(rtnSkillIdList, {id = self.skillMsgVoList[index].id, index = skillVo.skillIndex})
			end
		end
	end

	SortTableByKey(rtnSkillIdList, "index", true)

	local skillIdList = {}
	for i = 1, #rtnSkillIdList do
		table.insert(skillIdList, rtnSkillIdList[i].id)
	end
	return skillIdList
end

--获取当前职业所有技能（包括未解锁和解锁的）
function SkillModel:GetAllSkillList()
	return self.allSkillList
end

function SkillModel:GetAllSkillListIndexById(skillId)
	local rtnSkillIndex = -1
	
	for index = 1, #self.allSkillList  do
		if self.allSkillList[index].skillId == skillId then
			rtnSkillIndex = index
			break
		end
	end
	return rtnSkillIndex
end

--当前是否拥有该技能
function SkillModel:IsHasSkill(skillId)
	local rtnIsHas = false
	if skillId ~= nil then
		for index = 1, #self.skillMsgVoList do
			if self.skillMsgVoList[index].id == skillId then
				rtnIsHas = true
				break
			end
		end
	end
	return rtnIsHas
end

function SkillModel:IsHasSkillIndex(skillIndex)
	local rtnIsHas = false
	for index = 1, #self.allSkillList do
		if self.allSkillList[index].skillIndex == skillIndex then
			rtnIsHas = true
			break
		end
	end
	return rtnIsHas
end

function SkillModel:IsPlaceHoldSkillIndex(skillIndex)
	local rtnIsPlaceHolder = false
	if skillIndex ~= nil then
		for index = 1, #self.skillMsgVoList do
			local curSkillUpCfg = self.skillUpCfg:Get(self.skillMsgVoList[index].id)
			if curSkillUpCfg ~= nil and curSkillUpCfg.skillIndex == skillIndex then
				rtnIsPlaceHolder = true
				break
			end
		end
	end

	return rtnIsPlaceHolder
end

--是否能升级
function SkillModel:IsCanUpgrade(skillId)
	local rtnIsCan = true
	if skillId ~= nil then
		local curSkill = self:GetSkillById(skillId)
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		if mainPlayer ~= nil and curSkill ~= nil then
			if (curSkill.mastery < curSkill.needMastery) or (mainPlayer.level < curSkill.needLevel) or (curSkill.levelMax <= curSkill.level) then
				rtnIsCan = false
			end
		end
	end
	return rtnIsCan
end

--玩家等级是否满足当前技能升级要求等级
function SkillModel:IsEnoughLevelToUpgrade(skillId)
	local rntIsEngough = false
	if skillId ~= nil then
		local curSkill = self:GetSkillById(skillId)
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		
		if mainPlayer ~= nil and curSkill ~= nil then
			if mainPlayer.level ~= nil and curSkill.needLevel ~= nil then
				if mainPlayer.level >= curSkill.needLevel then
					rntIsEngough = true
				end
			end
		end
	end
	return rntIsEngough
end

--判断某个技能是否达到等级上限
function SkillModel:IsMaxSkillLev(skillId)
	local rtnIsMax = false
	if skillId ~= nil then
		local curSkill = self:GetSkillById(skillId)

		if curSkill ~= nil then
			if curSkill.level == curSkill.levelMax then
				rtnIsMax = true
			end
		end
	end
	return rtnIsMax
end

--从配置表中取得某个技能的等级上限
function SkillModel:IsMaxSkillLevByCfg(skillId)
	local rtnIsMax = false
	if skillId then
		local curSkillCfg =  self:GetSkillVo(skillId)
		if curSkillCfg then
			if curSkillCfg.level == curSkillCfg.levelMax then
				rtnIsMax = true
			end
		end
	end
	return rtnIsMax
end


function SkillModel:IsMaxSkillLevByPlayerLev(skillId)
	local rtnIsMax = false
	if skillId ~= nil then
		local curSkill = self:GetSkillById(skillId)
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		if mainPlayer ~= nil and curSkill ~= nil then
			if mainPlayer.level < curSkill.needLevel then
				rtnIsMax = true
			end
		end
	end
	return rtnIsMax
end

function SkillModel:GetSkillMsgVoList()
	return self.skillMsgVoList
end

function SkillModel:GetSkillLevel()
	local data = self:GetSkillMsgVoList()
	local lv = 0
	self.skillMiniLv = 1000
	if data then
		for i,v in ipairs(data) do
			if v.level < self.skillMiniLv then
				self.skillMiniLv = v.level
			end
			lv = lv + v.level
		end
	end
	return lv
end

--获取当前职业中的某个技能
function SkillModel:GetSkillById(skillId)
	if skillId ~= nil then
		for index = 1, #self.allSkillList do
			if self.allSkillList[index].skillId == skillId then
				return self.allSkillList[index]
			end
		end
	end
	return {}
end

--获取技能熟练度
function SkillModel:GetSkillMastery(skillId)
	if skillId ~= nil then
		local curSkillMsgVoList = self:GetSkillMsgVoList()
		for index = 1, #curSkillMsgVoList do
			if curSkillMsgVoList[index].id == skillId then
				return curSkillMsgVoList[index].mastery
			end
		end
	end
	return 0
end

--获取某个职业的某个技能槽的最低技能id
function SkillModel:GetLowestSkillByCareerIndex(career, skillIndex)
	local rtnSkillId = -1
	local lowestLev = 1000000
	if career ~= nil and skillIndex ~= nil then
		for key , v in pairs(self.skillUpCfg) do
			if type(v) ~= 'function' then
				if v.clanId == career and v.skillIndex == skillIndex then
					if lowestLev > self:GetLevelBySkillId(v.id) then
						lowestLev = self:GetLevelBySkillId(v.id)
						rtnSkillId = v.id
					end
				end
			end
		end
	end
	return rtnSkillId
end


----在技能总表配置中通过一个技能ID获取到这个技能等级
function SkillModel:GetLevelBySkillId(skillId)
	local rtnSkillLev = 0 
	local curSkillInfo = self:GetSkillVo(skillId)
	if curSkillInfo ~= nil then
		rtnSkillLev = curSkillInfo.level
	end
	return rtnSkillLev
end

--新增技能至技能总列表
function SkillModel:AddSkillToAllSkillList(curSkillId)
	local curSkillCfg =  self:GetSkillVo(curSkillId)
	local curSkillUpCfg = self.skillUpCfg:Get(curSkillId)

	--用当前等级升到下一等级所需要的熟练度放到下一等级的技能配置数据中
	--local nextLevSkillData = self:GetNextLevSkillData(curSkillId)
	local nextLevNeedMoney = self:GetNextLevSkillNeedMoney(curSkillId)
	local nextLevSkillNeedMastery = self:GetNextLevSkillNeedMastery(curSkillId)
	local nextLevSkillLev = self:GetNextLevSkillNeedLev(curSkillId)
	-- if not TableIsEmpty(nextLevSkillData) then
	-- 	nextLevSkillNeedMastery = nextLevSkillData.needMastery
	-- end

	if curSkillCfg ~= nil and curSkillUpCfg ~= nil then
		table.insert(self.allSkillList, {
				skillId = curSkillId,
				mastery = self:GetSkillMastery(curSkillId) or 0,

				skillIndex = curSkillUpCfg.skillIndex,
				careerId = curSkillUpCfg.clanId,
				proName1 = curSkillUpCfg.proName1,
				proValue1 = curSkillUpCfg.proValue1,
				proName2 = curSkillUpCfg.proName2,
				proValue2 = curSkillUpCfg.proValue2,

				needMoney = nextLevNeedMoney,
				needMastery = nextLevSkillNeedMastery,
				needLevel = nextLevSkillLev,

				name = curSkillCfg.name,
				des = curSkillCfg.des,
				iconID = curSkillCfg.iconID,
				level = curSkillCfg.level,
				levelMax = curSkillCfg.levelMax
			})
	end
end

--以技能下标的升序对技能总表进行排序
function SkillModel:SortAllSkillList()
	table.sort(self.allSkillList, function (a, b)
		return a.skillIndex < b.skillIndex
	end)
end

--初始化所有总技能列表
function SkillModel:InitAllSkillList()
	self.allSkillList = {}
	local player = SceneModel:GetInstance():GetMainPlayer()
	if not TableIsEmpty(player) then
		for key , v in pairs(self.skillUpCfg) do
			if type(v) ~= 'function' then
				if v.clanId == player.career and self:IsHasSkillIndex(v.skillIndex) == false then
					local curSkillId = -1
					--如果已经拥有
					if self:IsHasSkill(v.id) == true then
						curSkillId = v.id
					else
					--如果还未拥有，则取等级最低的那个技能
						if self:IsPlaceHoldSkillIndex(v.skillIndex) == false then
							--local lowestSkillId = self:GetLowestSkillByCareerIndex(v.clanId, v.skillIndex)
							local lowestSkillId = self:GetInitSkillId(v.clanId, v.skillIndex)
							if lowestSkillId ~= -1  then
								curSkillId = lowestSkillId
							end
						end
					end
					if curSkillId ~= -1 then
						self:AddSkillToAllSkillList(curSkillId)
					end
				end
			end
		end
	end
	self:SortAllSkillList()
end


function SkillModel:PrintSkillList()
	for index = 1, #self.skillMsgVoList do
		self.skillMsgVoList[index]:ToString()
	end
end

--在总技能表中用新的SkillId替换了旧的SkillId
function SkillModel:UpgradeAllSkillMsg(oldSkillId, newSkillMsg)
	if oldSkillId ~= nil and (not TableIsEmpty(newSkillMsg)) then
		for index = 1, #self.allSkillList do
			if (self.allSkillList[index].skillId == oldSkillId) or (self:GetSkillIndexById(self.allSkillList[index].skillId) == self:GetSkillIndexById(oldSkillId)) then
				table.remove(self.allSkillList, index)
				break
			end
		end
			
		local skillId = 0
		if newSkillMsg.mwSkillId ~= 0 then
			skillId = newSkillMsg.mwSkillId
		else
			skillId = newSkillMsg.skillId
		end
		if skillId ~= 0 then
			self:AddSkillToAllSkillList(skillId)
		end

	end

	self:SortAllSkillList()
end

--设置最近的上一等级的技能Id
function SkillModel:SetPreviousLevSkillId(skillId)
	self.previousLevSkillId = skillId or -1
end

--获取最近的上一等级的技能Id
function SkillModel:GetPreviousLevSkillId()
	return self.previousLevSkillId
end

--同步所有技能熟练度
function SkillModel:SyncAllSkillMastery(skillMsg)
	if skillMsg ~= nil then
		for msgIndex = 1, #skillMsg do
			local skillId = -1
			if skillMsg[msgIndex].mwSkillId ~= 0 then
				skillId = skillMsg[msgIndex].mwSkillId
			else
				skillId = skillMsg[msgIndex].skillId
			end
			for index = 1,  #self.allSkillList do
				if self.allSkillList[index].skillId == skillId then
					self.allSkillList[index].mastery = skillMsg[msgIndex].mastery
					break
				end
			end
		end
	end
end

--获取某个技能的下一等级的技能数据
function SkillModel:GetNextLevSkillData(curSkillId)
	local rtnSkillData = {}
	if curSkillId ~= nil then
		local curSkillUpCfg = self.skillUpCfg:Get(curSkillId)
		local curSkillCfg = self:GetSkillVo(curSkillId)
		local nextLevSkillId = -1

		if curSkillUpCfg ~= nil and curSkillCfg then
			local curSkillCareer = curSkillUpCfg.clanId
			local curSkillIndex = curSkillUpCfg.skillIndex
			local curSkillLev = curSkillCfg.level
			
			for skillIdKey, skillUpInfo in pairs(self.skillUpCfg) do
				if type(skillIdKey) == "number" then
					if skillUpInfo.clanId == curSkillUpCfg.clanId and skillUpInfo.skillIndex == curSkillUpCfg.skillIndex and self:GetLevelBySkillId(skillUpInfo.id) == (curSkillCfg.level + 1) then
						nextLevSkillId = skillUpInfo.id
						break
					end
				end
			end
		end

		if nextLevSkillId ~= -1 then
			local nextSkillCfg =  self:GetSkillVo(nextLevSkillId)
			local nextSkillUpCfg = self.skillUpCfg:Get(nextLevSkillId)
			if nextSkillCfg ~= nil and nextSkillUpCfg ~= nil then

				rtnSkillData.skillId = nextLevSkillId
				rtnSkillData.mastery = self:GetSkillMastery(nextLevSkillId) or 0
									
				rtnSkillData.skillIndex = nextSkillUpCfg.skillIndex
				rtnSkillData.careerId = nextSkillUpCfg.clanId
				rtnSkillData.proName1 = nextSkillUpCfg.proName1
				rtnSkillData.proValue1 = nextSkillUpCfg.proValue1
				rtnSkillData.proName2 = nextSkillUpCfg.proName2
				rtnSkillData.proValue2 = nextSkillUpCfg.proValue2

				rtnSkillData.needMoney = nextSkillUpCfg.needMoney
				rtnSkillData.needMastery = nextSkillUpCfg.needMastery
				rtnSkillData.needLevel = nextSkillUpCfg.needLevel

				rtnSkillData.name = nextSkillCfg.name
				rtnSkillData.des = nextSkillCfg.des
				rtnSkillData.iconID = nextSkillCfg.iconID
				rtnSkillData.level = nextSkillCfg.level
				rtnSkillData.levelMax = nextSkillCfg.levelMax

			end
		end

	end
	return rtnSkillData
end

--通过当前技能id和目标技能等级获取一个对应的技能ID
function SkillModel:GetSkillIdByIdLev(curSkillId, targetLev)
	local targetSkillId = -1
	if curSkillId ~= nil then
		local curSkillUpCfg = self.skillUpCfg:Get(curSkillId)
		local curSkillCfg = self:GetSkillVo(curSkillId)

		if curSkillUpCfg ~= nil and curSkillCfg then
			local curSkillCareer = curSkillUpCfg.clanId
			local curSkillIndex = curSkillUpCfg.skillIndex
			local curSkillLev = curSkillCfg.level
			

			for skillIdKey, skillUpInfo in pairs(self.skillUpCfg) do
				if type(skillIdKey) == "number" then
					if skillUpInfo.clanId == curSkillUpCfg.clanId and skillUpInfo.skillIndex == curSkillUpCfg.skillIndex then 
						if targetLev and self:GetLevelBySkillId(skillUpInfo.id) == targetLev then
							targetSkillId = skillUpInfo.id
							break
						end
					end
				end
			end
		end
	end
	-- 
	-- 
	return targetSkillId
end

--获取当前技能列表中，是否有不小于目标技能ID的技能（同一个技能槽位）
function SkillModel:IsNoLessThanSkillId(skillId)
	local rtnIsNoLess = false
	if skillId then
		local curSkillUpCfg = self.skillUpCfg:Get(skillId)
		local curSkillCfg = self:GetSkillVo(skillId)

		if not TableIsEmpty(curSkillUpCfg) and not TableIsEmpty(curSkillCfg) then
			if self.allSkillList then
				for index = 1, #self.allSkillList do
					if self.allSkillList[index].skillIndex == curSkillUpCfg.skillIndex and self.allSkillList[index].careerId == curSkillUpCfg.clanId then
						if self:GetLevelBySkillId(self.allSkillList[index].skillId) >= curSkillCfg.level then
							rtnIsNoLess = true
							break
						end
					end
				end
			end
		end
	end
	return rtnIsNoLess
end

--获取技能id通过基础技能id和技能下标
function SkillModel:GetSkillIdByBaseIdAndSkillIndex(baseSkillId, skillIndex)
	local rtnSkillId  = -1
	if baseSkillId ~= nil and skillIndex ~= nil then
		local oldSkillId = self:GetSkillIdByIndex(skillIndex)
		if oldSkillId ~= -1 then
			local oldSkillLevel = self:GetSkillLevelById(oldSkillId)
			if oldSkillLevel ~= 0 then
				rtnSkillId = self:GetSkillIdByBaseIdAndLev(baseSkillId, oldSkillLevel)
			end
		end
	end
	return rtnSkillId
end


--改变某个技能槽的基础技能ID，保持原技能等级
function SkillModel:SwapSkillByBaseIdAndIndex(baseSkillId, skillIndex, isPutOn)
	if baseSkillId ~= nil and skillIndex ~= nil then
		if isPutOn == true then
			local oldSkillId = self:GetSkillIdByIndex(skillIndex)
			if oldSkillId ~= -1 then
				local oldSkillLevel = self:GetSkillLevelById(oldSkillId)
				local newSkillId = self:GetSkillIdByBaseIdAndLev(baseSkillId, oldSkillLevel)
	
				local oldSkillMastery = 0

				for index = 1, #self.skillMsgVoList do
					if self.skillMsgVoList[index].id == oldSkillId then
						oldSkillMastery = self.skillMsgVoList[index].mastery

						self.skillMsgVoList[index]:Destroy()
						table.remove(self.skillMsgVoList, index)
						break
					end
				end
				--add newSkill
				local newSKillMsgVo = SkillMsgVo.New()
				newSkillMsg = {}
				newSkillMsg.mwSkillId = newSkillId
				newSkillMsg.skillId = oldSkillId
				newSkillMsg.mastery = oldSkillMastery
				newSKillMsgVo:SetVo(newSkillMsg)

				table.insert(self.skillMsgVoList, newSKillMsgVo)
			end
		else
			local skillMsgIndex = self:GetSkillMsgIndexByIndex(skillIndex)
			
			if self.skillMsgVoList[skillMsgIndex] then
			
				self.skillMsgVoList[skillMsgIndex].id = self.skillMsgVoList[skillMsgIndex].skillId
				self.skillMsgVoList[skillMsgIndex].mwSkillId = 0
			
			end
		end
	end
end

--获取技能ID通过基础技能id和等级
function SkillModel:GetSkillIdByBaseIdAndLev(baseSkillId, level)
	local rtnSkillId = -1
	if baseSkillId ~= nil and level ~= nil then
		rtnSkillId = level * 10000 + baseSkillId
	end
	return rtnSkillId
end

--[[
	获取某个技能所属技能下标是否激活
]]
function SkillModel:IsSkillIndexActive(skillId)
	local rtnHasActive = false
	if skillId then
		local rtnSkillIndex = self:GetSkillIndexById(skillId)
		if rtnSkillIndex ~= -1 then
			local rtnSkillId =   self:GetSkillIdByIndex(rtnSkillIndex)
			if rtnSkillId ~= -1 then
				rtnHasActive = true
			end
		end
	end
	-- 
	return rtnHasActive
end

--获取该skillIndex的技能Id
function SkillModel:GetSkillIdByIndex(skillIndex)
	local rtnSkillId = -1
	if skillIndex then
		for index = 1, #self.skillMsgVoList do
			local curSkillIndex = self:GetSkillIndexById(self.skillMsgVoList[index].id)
			if curSkillIndex ~= -1 and curSkillIndex == skillIndex then
				rtnSkillId = self.skillMsgVoList[index].id
				break
			end
		end
	end
	return rtnSkillId
end

--获取技能Msg Vo通过技能下标
function SkillModel:GetSkillMsgIndexByIndex(skillIndex)
	local rtnSkillIndex = -1
	if skillIndex then
		for index = 1, #self.skillMsgVoList do
			local curSkillIndex = self:GetSkillIndexById(self.skillMsgVoList[index].id)
			if curSkillIndex ~= -1 and curSkillIndex == skillIndex then
				rtnSkillIndex = index
				break
			end
		end
	end
	return rtnSkillIndex
end

--获取技能下标通过技能id
function SkillModel:GetSkillIndexById(skillId)
	local rtnSkillIndex = -1
	if skillId ~= nil then
		local curSkillCfg = self:GetSkillVo(skillId)
		if curSkillCfg then
			rtnSkillIndex = curSkillCfg.skillIndex
		end
	end
	return rtnSkillIndex
end

--获取技能等级通过某个技能id
function SkillModel:GetSkillLevelById(skillId)
	local rtnSkillLev = 0
	if skillId then
		for index = 1, #self.skillMsgVoList do
			if self.skillMsgVoList[index].id == skillId then
				rtnSkillLev = self.skillMsgVoList[index].level
				break
			end
		end
	end
	return rtnSkillLev
end

--获取技能名称通过一个技能id
function SkillModel:GetSkillNameById(skillId)
	if skillId then
		local curSkillCfg = self:GetSkillVo(skillId)
		if curSkillCfg then
			return curSkillCfg.name
		end
	end
	return ""
end

--获取SkillMsgVo中的技能id通过技能id
function SkillModel:GetSkillIdById(skillId)
	if skillId then
		for index = 1, #self.skillMsgVoList do
			if self.skillMsgVoList[index].id == skillId then
				return self.skillMsgVoList[index].skillId
			end
		end
	end
	
	return 0
end

--获取初始技能通过职业和技能下标
function SkillModel:GetInitSkillId(career, skillIndex)
	if career and skillIndex then
		local newDefaultCfg = GetCfgData("newroleDefaultvalue")
		local curPlayerVo = SceneModel:GetInstance():GetMainPlayer()
		local initSkillList = {}
		if curPlayerVo then
			if curPlayerVo.career == career  then
				for key, v in pairs(newDefaultCfg) do
					if type(v) ~= 'function' then
						if v.career == curPlayerVo.career then
							initSkillList = v.initSkills
							break
						end
					end
				end

				for index = 1, #initSkillList do
					if self:GetSkillIndexById(initSkillList[index]) == skillIndex then
						return initSkillList[index]
					end
				end
			end
		end
	end
	
	return -1
end

------接入后台协议end

function SkillModel:HandleBagChange()
	self:CleanSkillBookCnt()
	self:SetSkillBookData()
	self:DispatchEvent(SkillConst.UpdateSkillBook)
end


--设置技能书数据
function SkillModel:SetSkillBookData()
	local onGrids = PkgModel:GetInstance():GetOnGrids()
	for index = 1 , #onGrids do
		local curGrid = onGrids[index]
		if self:IsSkillBook(curGrid.bid) then
			local isHas ,isHasIndex = self:IsHasSkillBookData(curGrid.bid)
			if isHas and isHasIndex ~= -1 then
				self.skillBookData[isHasIndex].cnt = self.skillBookData[isHasIndex].cnt + curGrid.num
			else
				table.insert(self.skillBookData, {id = curGrid.bid, cnt = curGrid.num})
			end
		end
	end
	self:SortSkillBookData()
end

--对技能书数据按品阶进行排序(品级>ID)
function SkillModel:SortSkillBookData()
	table.sort(self.skillBookData , function (a , b)
		local aRare = self:GetSkillBookRare(a.id)
		local bRare = self:GetSkillBookRare(b.id)
		if aRare == bRare then
			return a.id < b.id
		else
			return aRare < bRare
		end
	end)
end

function SkillModel:GetSkillBookRare(bid)
	local bookData = GetCfgData("item"):Get(bid)
	if bookData then
		return bookData.rare
	else
		return 0
	end
end


function SkillModel:CleanSkillBookCnt()
	for index = 1 , #self.skillBookData do
		self.skillBookData[index].cnt = 0
	end
end

function SkillModel:IsHasSkillBookData(bid)
	local rtnIsHas = false
	local rtnIndex = -1
	if bid then
		for index = 1 , #self.skillBookData do
			local curSkillData = self.skillBookData[index]
			if not TableIsEmpty(curSkillData) and curSkillData.id == bid then
				rtnIsHas = true
				rtnIndex = index
				break
			end
		end
	end
	return rtnIsHas , rtnIndex
end

function SkillModel:IsSkillBook(bid)
	local rtnIs = false
	if bid then
		local itemCfg = GetCfgData("item"):Get(bid)
		if itemCfg then
			if itemCfg.tinyType == GoodsVo.TinyType.skillBook then
				rtnIs = true
			end
		end
	end
	return rtnIs
end

--获取背包中技能书数据
function SkillModel:GetSkillBookData()
	return self.skillBookData or {}
end

function SkillModel:IsEmptySkillBook()

	local isEmpty = true
	for index = 1 , #self.skillBookData do
		local curSkillBook = self.skillBookData[index]
		if curSkillBook.id ~= 0 and curSkillBook.cnt ~= 0 then
			isEmpty = false
			break
		end
	end
	return isEmpty
end

--设置当前选中的技能数据
function SkillModel:SetSelectSkillData(skillData)
	self.curSelectSkillData = skillData or {}
end

--获取当前选中的技能数据
function SkillModel:GetSelectSkillData()
	return self.curSelectSkillData
end

function SkillModel:CleanSelectSkillData()
	self.curSelectSkillData = {}
end

function SkillModel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)

	self.skillUpCfg = {}
	self.skillCfg = {}
	self.skillMsgVoList = {}
	self.allSkillList = {}
	self.curLearnSkillId = -1
	self.previousLevSkillId = -1
	self.skillBookData = {}

	SkillModel.inst = nil
end

function SkillModel:IsMWSkill(skillId)
	local rtnIs = false
	if skillId then
		local skillCfg = self:GetSkillVo(skillId)
		if skillCfg then
			if skillCfg.isMWSkill == 1 then
				rtnIs = true
			end
		end
	end
	return rtnIs
end

function SkillModel:GetSkillIdByMWId(mwSkillId)
	local rtnSkillId = -1
	if mwSkillId ~= nil then
		for index = 1, #self.skillMsgVoList do
			local curSkillMsgVo = self.skillMsgVoList[index]
			if curSkillMsgVo.mwSkillId == mwSkillId then
				rtnSkillId = curSkillMsgVo.skillId
				break
			end
		end
	end
	return rtnSkillId
end

--主界面技能按钮出现提示规则：
--出现：有可以升级的技能（技能熟练度已满）
--不出现：技能等级升到上限，或技能熟练度不够升级

--改成和技能显示升级图标显示一致
function SkillModel:ShowSkillRedTips()
	local isShow = false
	-- for index = 1 , #self.skillMsgVoList do
	-- 	local curSkillMsgVo = self.skillMsgVoList[index]
	-- 	if curSkillMsgVo.id ~= -1 then
	-- 		local needMastery = self:GetNeedMastery(curSkillMsgVo.id)
			
	-- 		if needMastery ~= -1 then
	-- 			if curSkillMsgVo.mastery >= needMastery and self:IsMaxSkillLevByCfg(curSkillMsgVo.id) == false then
	-- 				isShow = true
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end

	for index = 1 , #self.skillMsgVoList do
		local curSkillMsgVo = self.skillMsgVoList[index]
		if curSkillMsgVo and  curSkillMsgVo.id ~= -1 then
			if self:IsCanUpgrade(curSkillMsgVo.id) == true then
				isShow = true
				break
			end
		end
	end
	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.skill , state = isShow})
end

--根据技能学习槽位，获取相对应职业的学习技能id
-- 战士： 学习技能id=11000+（技能下标-1）*10
-- 法师： 学习技能id=11100+（技能下标-1）*10
-- 啊呜： 学习技能id=11200+（技能下标-1）*10
function SkillModel:GetLearnSkillIdByIndex(career , skillIndex)
	local rtnSkillId = 0
	if career and skillIndex and career > 0 and skillIndex > 0 then
		local careerScore = (career - 1) * 100 
		local skillIndexScore = (skillIndex -1 ) * 10
		rtnSkillId = 11000 + careerScore + skillIndexScore
	end
	return rtnSkillId
end

--获取当前技能id的升到下一等级所需要的熟练度
function SkillModel:GetNextLevSkillNeedMastery(curSkillId)
	--用当前等级升到下一等级所需要的熟练度放到下一等级的技能配置数据中
	local rtnNeedMastery = 0
	local nextLevSkillData = self:GetNextLevSkillData(curSkillId)
	if not TableIsEmpty(nextLevSkillData) then
		rtnNeedMastery = nextLevSkillData.needMastery
	end
	return rtnNeedMastery
end

--获取当前技能id的升到下一等级所需要的金币
function SkillModel:GetNextLevSkillNeedMoney(curSkillId)
	--用当前等级升到下一等级所需要的金币放到下一等级的技能配置数据中
	local rtnNeedMoney = 0
	local nextLevSkillData = self:GetNextLevSkillData(curSkillId)
	if not TableIsEmpty(nextLevSkillData) then
		rtnNeedMoney = nextLevSkillData.needMoney
	end
	return rtnNeedMoney
end

--获取当前技能id的升到下一等级所需要的等级
function SkillModel:GetNextLevSkillNeedLev(curSkillId)
	--用当前等级升到下一等级所需要的金币放到下一等级的技能配置数据中
	local rtnNeedLev = 0
	local nextLevSkillData = self:GetNextLevSkillData(curSkillId)
	if not TableIsEmpty(nextLevSkillData) then
		rtnNeedLev = nextLevSkillData.needLevel
	end
	return rtnNeedLev
end


function SkillModel:GetNeedMastery(skillId)
	local needMastery = -1
	if skillId then
		local curSkillCfg =  self:GetSkillVo(skillId)
		local curSkillUpCfg = self.skillUpCfg:Get(skillId)
		if curSkillCfg ~= nil and curSkillUpCfg ~= nil then
			needMastery = curSkillUpCfg.needMastery
		end
	end
	return needMastery
end

function SkillModel:GetNeedMoney(skillId)
	local rtnNeedMoney = -1
	if skillId then
		local curSkillCfg =  self:GetSkillVo(skillId)
		local curSkillUpCfg = self.skillUpCfg:Get(skillId)
		if curSkillCfg ~= nil and curSkillUpCfg ~= nil then
			rtnNeedMoney = curSkillUpCfg.needMoney
		end
	end
	return rtnNeedMoney
end


function SkillModel:Reset()
	self.skillMsgVoList = {}
	self.allSkillList = {}
	self.curLearnSkillId = -1
	self.previousLevSkillId = -1
	self.skillBookData = {}
end

function SkillModel:IsAllSkillListEmpty()
	if self.allSkillList or TableIsEmpty(self.allSkillList) then
		return true
	else
		return false
	end
end

--判断是否为三连击的第一、第二击
--如果技能id最后两位为00或者01，则为三连击的前两击
function SkillModel:IsFirstSecondHitInThreeCombo(skillId)
	local rtnIs = false
	local strSkillId = tostring(skillId)
	local subStr = string.sub(strSkillId , -2)
	if subStr == '00' or subStr == '01' then
		--print("===== 如果技能id最后两位为00或者01，则为三连击的前两击" , skillId , rtnIs)
		rtnIs = true
	end
	
	return rtnIs
end
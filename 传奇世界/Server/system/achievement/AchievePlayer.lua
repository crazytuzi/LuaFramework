--AchievePlayer.lua

AchievePlayer = class()

local prop = Property(AchievePlayer)
prop:accessor("roleSID")
prop:accessor("roleID")
prop:accessor("achievePoint", 0)	--成就点数
prop:accessor("loadAchieveFlag", false)	--加载完成就数据
prop:accessor("achieveLevel", 0)	--成就等级
prop:accessor("currentPoint", 0)		-- 当前等级点数
prop:accessor("updatePropFlag", false)		-- 更新属性标识位


function AchievePlayer:__init(player)
	prop(self, "roleSID", player:getSerialID())
	prop(self, "roleID", player:getID())
	prop(self, "school", player:getSchool())

	self:init()
end

function AchievePlayer:init()
	self._doneAchieve = {}			-- 完成的成就列表
	self._achieve = {}			-- 进行中的成就列表
	self._group = {}				-- 成就组数据，记录当前组正在进行的成就
	self._doneGroup = {}		-- 完成的成就组
	self._titles = {}			-- 称号
	self._curTitle = 0			-- 当前称号
end

function AchievePlayer:getDoneAchieve(achieveID)
	return self._doneAchieve[achieveID]
end

function AchievePlayer:setDoneAchieve(achieveID, time)
	self._doneAchieve[achieveID] = time

	local achieveConfig = g_achieveMgr:getAchieveConfig(achieveID)
	if achieveConfig then
		local groupID = achieveConfig.q_groupid
		local achieveIDs = g_achieveMgr:getGroupAchieveIDs(groupID)
		if achieveIDs and achieveIDs[#achieveIDs] == achieveID then
			self._doneGroup[groupID] = achieveConfig.q_value
		end
	end
end

function AchievePlayer:getDoneGroups()
	return self._doneGroup
end

-- 设置进行中的成就
function AchievePlayer:setAchieve(achieveID, data)
	if type(data) == "number" and data < 0 then
		self._achieve[achieveID] = 0
	else
		self._achieve[achieveID] = data
	end
end

-- 获得进行中的成就
function AchievePlayer:getAchieve(achieveID)
	return self._achieve[achieveID]
end

function AchievePlayer:getTitles()
	return self._titles
end

function AchievePlayer:getDoneAchieves()
	return self._doneAchieve
end

function AchievePlayer:getAchieves()
	return self._achieve
end

--保存成就数据
function AchievePlayer:castAchieve2DB()
	local achieve = {}
	for achieveID, finishTime in pairs(self._doneAchieve) do
		table.insert(achieve, {achieveID = achieveID, finishTime = finishTime})
	end
	local dbData = {
		achieve = achieve
	}
	local cache_buff = protobuf.encode("AchieveProtocol", dbData)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_ACHIEVE, cache_buff, #cache_buff)
end

--加载成就数据
function AchievePlayer:loadAchieveDBData(cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("AchieveProtocol", cache_buf)
		if datas then
			for _, achieve in pairs(datas.achieve) do
				self:setDoneAchieve(achieve.achieveID, achieve.finishTime)
			end
			
			local achievePoint = 0
			for achieveID, _ in pairs(self._doneAchieve) do
				local achieveConfig = g_achieveMgr:getAchieveConfig(achieveID)
				if achieveConfig then
					achievePoint = achievePoint + achieveConfig.q_activity
				end
			end

			self:setAchievePoint(achievePoint)
		end
	end

	self:setLoadAchieveFlag(true)
end

--保存成就进度数据
function AchievePlayer:castAchieveEvent2DB()
	local achieveEvent = {}
	for achieveID, data in pairs(self._achieve) do
		table.insert(achieveEvent, {eventType = achieveID, data = data})
	end
	local dbData = {
		achieveEvent = achieveEvent
	}
	local cache_buff = protobuf.encode("AchieveEventProtocol", dbData)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_ACHIEVE_EVENT, cache_buff, #cache_buff)
end

--加载成就进度数据
function AchievePlayer:loadAchieveEventDBData(cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("AchieveEventProtocol", cache_buf)

		for _, event in pairs(datas.achieveEvent) do
			self:setAchieve(event.eventType, event.data)
		end
	end
end

--保存称号数据
function AchievePlayer:castTitile2DB()
	local titles = {}
	for titleID, finishTime in pairs(self._titles) do
		table.insert(titles, {titleID = titleID, finishTime = finishTime})
	end

	local dbData = {
		curTitle = self._curTitle,
		titles = titles,
		validTitles = {},
		progress = {},
	}

	local cache_buff = protobuf.encode("TitleProtocol", dbData)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_TITLE, cache_buff, #cache_buff)
end

--加载称号数据
function AchievePlayer:loadTitleDBData(cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("TitleProtocol", cache_buf)

		self._curTitle = datas.curTitle
		for _, title in pairs(datas.titles) do
			self._titles[title.titleID] = title.finishTime
			--self:setTitleProp(title.titleID, 1)
		end
		
		local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
		if self._curTitle ~= 0 and player then
			player:setTitle(self._curTitle)
			fireProtoMessage(player:getID(), ACHIEVE_SC_LOADTITLE, "AchieveLoadTitleID", {titleID = self._curTitle})
		end
	end
end

-- 处理添加物品称号
function AchievePlayer:dealAddItemTitle(itemID)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local titleFlag = {}
	self:getItemTitle(itemID, titleFlag)

	for _, titleData in pairs(HasItemTitle) do
		local titleID = titleData.title[player:getSchool()]
		if titleID then
			if titleFlag[titleID] then
				self:addTitle(titleID)
			end
		end
	end
end


-- 获得物品称号
function AchievePlayer:getItemTitle(itemID, titleFlag)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	for _, titleData in pairs(HasItemTitle) do
		local titleID = titleData.title[player:getSchool()]
		if titleID then
			if itemID >= titleData.startItemID and itemID <= titleData.endItemId then
				local itemProto = g_entityMgr:getConfigMgr():getItemProto(itemID)
				if itemProto then
					if os.time() < itemProto.dateOff or itemProto.dateOff == 0 then
						titleFlag[titleID] = true
					end
				end
			end
		end
	end
end

-- 玩家加载完成
function AchievePlayer:playerLoad()
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	self:updateAchieveLevel()

	local titleID = ShaCityTitle[player:getSchool()]
	if titleID then
		local shaFactionID = g_shaWarMgr:getShaFactionId()
			
		if self._titles[titleID] then
			local factionID = player:getFactionID()
			local faction = g_factionMgr:getFaction(factionID)
			if not (faction and player:getSerialID() == faction:getLeaderID() and shaFactionID == factionID) then
				self:removeTitle(titleID)
			end
		else
			local factionID = player:getFactionID()
			local faction = g_factionMgr:getFaction(factionID)
			if not g_shaWarMgr:getOpenState() and faction and player:getSerialID() == faction:getLeaderID() and shaFactionID == factionID then
				self:addTitle(titleID)
			end
		end	
	end

	local charmingTitle = CharmingTitle[player:getSchool()]
	if charmingTitle then
		if self._titles[charmingTitle] then
			local glamourData = g_RankMgr:getGlamour()
			if not glamourData or glamourData[1] ~= player:getSerialID() then
				self:removeTitle(charmingTitle)
			end
		else
			local glamourData = g_RankMgr:getGlamour()
			if glamourData and glamourData[1] == player:getSerialID() then
				self:addTitle(charmingTitle)
			end
		end
	end

	local itemMgr = player:getItemMgr()
	if itemMgr then
		local titleFlag = {}

		local itemBag = itemMgr:getBag(Item_BagIndex_Bag)
		if itemBag then
			local count = itemBag:getCapacity()
			for i = 1, count do
				local item = itemMgr:findItem(i, Item_BagIndex_Bag)
				if item then
					self:getItemTitle(item:getProtoID(), titleFlag)
				end
			end
		end

		itemBag = itemMgr:getBag(Item_BagIndex_Bank)
		if itemBag then
			local count = itemBag:getCapacity()
			for i = 1, count do
				local item = itemMgr:findItem(i, Item_BagIndex_Bank)
				if item then
					self:getItemTitle(item:getProtoID(), titleFlag)
				end
			end
		end

		for _, titleData in pairs(HasItemTitle) do
			local titleID = titleData.title[player:getSchool()]
			if titleID then
				if titleFlag[titleID] then
					self:addTitle(titleID)
				else
					self:removeTitle(titleID)
				end
			end
		end
	end
end

-- 添加称号
function AchievePlayer:addTitle(titleID)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local titleConfig = g_achieveMgr:getTitleConfig(titleID)
	if titleConfig == nil then
		return
	end

	if titleConfig.school ~= player:getSchool() then
		return
	end

	if self._titles[titleID] then
		return
	end

	self._titles[titleID] = os.time()
	--self:setTitleProp(titleID, 1)

	fireProtoMessage(player:getID(), ACHIEVE_SC_GETNEWACHIEVE, "AchieveGetNewAchieve", {titleID = titleID})
	self:castTitile2DB()

	g_logManager:writeAchievement(self:getRoleSID(), 2, titleConfig.q_titleName, 0)
end

-- 移除称号
function AchievePlayer:removeTitle(titleID)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	if not self._titles[titleID] then
		return
	end

	local titleConfig = g_achieveMgr:getTitleConfig(titleID)
	if titleConfig == nil then
		return
	end

	self._titles[titleID] = nil
	--self:setTitleProp(titleID, -1)

	if self._curTitle == titleID then
		self:setCurTitle(0)
	end
	self:castTitile2DB()

	g_logManager:writeAchievement(self:getRoleSID(), 2, "removeTitle:" .. titleConfig.q_titleName, 0)
end

-- 更新成就组正在进行的成就
function AchievePlayer:updateGroupAchieveID(groupID)
	local achieveIDs = g_achieveMgr:getGroupAchieveIDs(groupID)
	if achieveIDs == nil then
		return
	end

	local achieveID = 0

	for i = 1, #achieveIDs do
		local achieveIDTmp = achieveIDs[i]
		if not self:getDoneAchieve(achieveIDTmp) then
			achieveID = achieveIDTmp
			break
		end
	end

	self._group[groupID] = achieveID
end

-- 获得成就组正在进行的成就
function AchievePlayer:getGroupAchieveID(groupID)
	if self._group[groupID] == nil then
		self:updateGroupAchieveID(groupID)
	end

	return self._group[groupID]
end

-- 处理成就
function AchievePlayer:dealAchieve(conditionType, achieveData)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local groupIDs = g_achieveMgr:getAchieveConfitionGroupIDs(conditionType)
	if groupIDs == nil then
		return
	end

	local updateAchieveFlag = false
	local updateDoneAchieveFlag = false
	local updateDoneAchieve = {}

	for _, groupID in pairs(groupIDs) do
		local achieveID = self:getGroupAchieveID(groupID)
		if achieveID and achieveID ~= 0 then
			local achieveConfig = g_achieveMgr:getAchieveConfig(achieveID)
			if achieveConfig then
				if achieveData.achieveFail then
					updateAchieveFlag = true
					self:setAchieve(achieveID, 0)
				else
					local flag = true
					for i = 1, AchieveCustomValueMax do
						local value = achieveConfig["q_value" .. i]
						local valueCmp = achieveConfig["q_valueCmp" .. i]
						if value and valueCmp and value ~= 0 then
							if achieveData.customValues == nil then
								flag = false
								break
							end

							local customValue = achieveData.customValues[i] 
							if customValue == nil then
								flag = false
								break
							end

							if valueCmp == AchieveCustomValueCmpType.et then
								if value ~= customValue then
									flag = false
									break
								end
							elseif valueCmp == AchieveCustomValueCmpType.bet then
								if value < customValue then
									flag = false
									break
								end
							end
						end
					end

					local flag2 = true
					for i = 1, AchieveValueSetMax do
						local valueSet = achieveConfig["q_valueset" .. i]
						if valueSet ~= nil and type(valueSet) == "table" then
							if achieveData.customSetValues == nil then
								flag2 = false
								break
							end

							local setValue = achieveData.customSetValues[i]
							if setValue == nil then
								flag2 = false
								break
							end

							if valueSet[setValue] == nil then
								flag2 = false
								break
							end
						end
					end

					if flag and flag2 then
						updateAchieveFlag = true
						local value = 0
						if achieveConfig.q_updateValueType == AchieveValueUpdateType.add then
							local oldValue = self:getAchieve(achieveID) or 0
							value = oldValue + achieveData.value
						elseif achieveConfig.q_updateValueType == AchieveValueUpdateType.cover then
							value = achieveData.value
						elseif achieveConfig.q_updateValueType == AchieveValueUpdateType.bigCover then
							local oldValue = self:getAchieve(achieveID) or 0
							if achieveData.value > oldValue then
								value = achieveData.value
							else
								value = oldValue
							end
						end

						if value < 0 then
							value = 0
						end

						if value >= achieveConfig.q_value then
							updateDoneAchieveFlag = true
							self:achieveDone(groupID, value)
						else
							self:setAchieve(achieveID, value)
						end
					end
				end
			end
		end
	end

	if updateDoneAchieveFlag then
		self:castAchieve2DB()
	end

	if updateAchieveFlag then
		self:castAchieveEvent2DB()
	end
end

-- 成就完成
function AchievePlayer:achieveDone(groupID, value)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local achieveIDs = g_achieveMgr:getGroupAchieveIDs(groupID)
	if achieveIDs == nil then
		return
	end

	for i = 1, #achieveIDs do
		local achieveID = achieveIDs[i]
		if not self._doneAchieve[achieveID] then
			local achieveConfig = g_achieveMgr:getAchieveConfig(achieveID)
			if achieveConfig then
				if value >= achieveConfig.q_value then
					self:setAchieve(achieveID, nil)
					self:setDoneAchieve(achieveID, os.time())
					self:updateGroupAchieveID(groupID)
					-- local flag = self:updateTitle(achieveID)
					
					local achievePoint = self:getAchievePoint() + achieveConfig.q_activity
					self:setAchievePoint(achievePoint)

					self:updateAchieveLevel()
					
					fireProtoMessage(player:getID(), ACHIEVE_SC_GETNEWACHIEVE, "AchieveGetNewAchieve", {achieveID = achieveID})

					g_logManager:writeAchievement(player:getSerialID(), 1, achieveConfig.q_name, achieveConfig.q_activity)

					g_tlogMgr:TlogAchieveFlow(player, achieveID, achieveConfig.q_name, achieveConfig.q_activity, achievePoint, self:getAchieveLevel())
				else
					self:setAchieve(achieveID, value)
					break
				end
			end
		end 
	end
end

-- 更新成就等级
function AchievePlayer:updateAchieveLevel()
	local achieveLevelConfigs = g_achieveMgr:getAchieveLevelConfig()
	if not achieveLevelConfigs then
		return
	end

	local level = 1
	local achievePoint = self:getAchievePoint() 
	for i = 1, #achieveLevelConfigs do
		local config = achieveLevelConfigs[i]
		if config then
			if achievePoint >= config.q_achievePoint then
				if i == #achieveLevelConfigs then
					level = config.q_achieveLevel
					achievePoint = config.q_achievePoint
				else
					level = config.q_achieveLevel + 1
					achievePoint = achievePoint - config.q_achievePoint
				end
			else
				break
			end
		end
	end

	local oldLevel = self:getAchieveLevel()
	if self:getUpdatePropFlag() then
		if level > oldLevel then
			self:setAchieveProp(oldLevel, -1)
			self:setAchieveProp(level, 1)
		end
	else
		self:setAchieveProp(level, 1)
	end

	self:setUpdatePropFlag(true)

	self:setAchieveLevel(level)
	self:setCurrentPoint(achievePoint)
end


-- 更新称号
function AchievePlayer:updateTitle(achieveID)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local titles = g_achieveMgr:getAchieveTitle(achieveID)
	if titles == nil then
		return
	end

	for titleID, _ in pairs(titles) do
		local titleConfig = g_achieveMgr:getTitleConfig(titleID)
		if titleConfig and titleConfig.school == player:getSchool() then
			local flag = true
			for achieveID, _ in pairs(titleConfig.q_needAchieves) do
				if self._doneAchieve[achieveID] == nil then
					flag = false
					break
				end
			end

			if flag then
				self:addTitle(titleID)
				return true
			end
		end
	end
end

-- 设置当前称号
function AchievePlayer:setCurTitle(titleID)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	if titleID ~= 0 then
		if self._titles[titleID] == nil then
			fireProtoMessage(player:getID(), ACHIEVE_SC_SETTITLERET, "AchieveSetTitleRet", {titleID = -1})
			return
		end
	end

	if titleID ~= 0 and self._curTitle == titleID then
		return
	end

	self._curTitle = titleID
	player:setTitle(titleID)
	self:castTitile2DB()
	fireProtoMessage(player:getID(), ACHIEVE_SC_LOADTITLE, "AchieveLoadTitleID", {titleID = self._curTitle})

	if titleID ~= 0 then
		fireProtoMessage(player:getID(), ACHIEVE_SC_SETTITLERET, "AchieveSetTitleRet", {titleID = titleID})
	else
		fireProtoMessage(player:getID(), ACHIEVE_SC_DISLOADTITLERET, "AchieveRemoveTitleRet", {titleID = 0})
	end
end

-- 设置称号属性
function AchievePlayer:setTitleProp(titleID, flag)
	local titleConfig = g_achieveMgr:getTitleConfig(titleID)
	if titleConfig == nil then
		return
	end

	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local school = player:getSchool()
	local minIncVal = player:getMinAT()
	local maxIncVal = player:getMaxAT()
	if school == 1 then
		if titleConfig.q_attack_min and titleConfig.q_attack_min > 0 then
			player:setMinAT(minIncVal + flag * titleConfig.q_attack_min)
		end
		if titleConfig.q_attack_max and titleConfig.q_attack_max > 0 then
			player:setMaxAT(maxIncVal + flag * titleConfig.q_attack_max)
		end
	elseif school == 2 then
		if titleConfig.q_magic_attack_min and titleConfig.q_magic_attack_min > 0 then
			minIncVal = player:getMinMT()
			player:setMinMT(minIncVal + flag * titleConfig.q_magic_attack_min)
		end

		if titleConfig.q_magic_attack_max and titleConfig.q_magic_attack_max > 0 then
			maxIncVal = player:getMaxMT()
			player:setMaxMT(maxIncVal + flag * titleConfig.q_magic_attack_max)
		end
	elseif school ==3 then
		if titleConfig.q_sc_attack_min and titleConfig.q_sc_attack_min > 0 then
			minIncVal = player:getMinDT()
			player:setMinDT(minIncVal + flag * titleConfig.q_sc_attack_min)
		end

		if titleConfig.q_sc_attack_max and titleConfig.q_sc_attack_max > 0 then
			maxIncVal = player:getMaxDT()
			player:setMaxDT(maxIncVal + flag * titleConfig.q_sc_attack_max)
		end
	end
	if titleConfig.q_max_hp and titleConfig.q_max_hp > 0 then
		local incMaxHP = player:getMaxHP()
		player:setMaxHP(incMaxHP + flag * titleConfig.q_max_hp)
	end

	if titleConfig.q_defence_min and titleConfig.q_defence_min > 0 then
		minIncVal = player:getMinDF()
		player:setMinDF(minIncVal + flag * titleConfig.q_defence_min)
	end

	if titleConfig.q_defence_max and titleConfig.q_defence_max > 0 then
		maxIncVal = player:getMaxDF()
		player:setMaxDF(maxIncVal + flag * titleConfig.q_defence_max)
	end

	if titleConfig.q_magic_defence_min and titleConfig.q_magic_defence_min > 0 then
		minIncVal = player:getMinMF()
		player:setMinMF(minIncVal + flag * titleConfig.q_magic_defence_min)
	end

	if titleConfig.q_magic_defence_max and titleConfig.q_magic_defence_max > 0 then
		maxIncVal = player:getMaxMF()
		player:setMaxMF(maxIncVal + flag * titleConfig.q_magic_defence_max)
	end

	if titleConfig.q_crit and titleConfig.q_crit > 0 then
		player:setCrit(player:getCrit() + flag * titleConfig.q_crit)
	end

	if titleConfig.q_hit and titleConfig.q_hit > 0 then
		player:setHit(player:getHit() + flag * titleConfig.q_hit)
	end

	if titleConfig.q_dodge and titleConfig.q_dodge > 0 then
		player:setDodge(player:getDodge() + flag * titleConfig.q_dodge)
	end

	if titleConfig.battle and titleConfig.battle > 0 then
		player:setbattle(player:getbattle() + flag * titleConfig.battle)
	end
end


-- 设置成就属性
function AchievePlayer:setAchieveProp(achieveLevel, flag)
	local achieveLevelConfigs = g_achieveMgr:getAchieveLevelConfig()
	if not achieveLevelConfigs then
		return
	end

	local achieveLevelConfig = achieveLevelConfigs[achieveLevel]
	if not achieveLevelConfig then
		return
	end

	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local config = achieveLevelConfig.attr[player:getSchool()]
	if not config then
		return
	end

	local school = player:getSchool()
	local minIncVal = player:getMinAT()
	local maxIncVal = player:getMaxAT()
	if school == 1 then
		if config.q_attack_min and config.q_attack_min > 0 then
			player:setMinAT(minIncVal + flag * config.q_attack_min)
		end
		if config.q_attack_max and config.q_attack_max > 0 then
			player:setMaxAT(maxIncVal + flag * config.q_attack_max)
		end
	elseif school == 2 then
		if config.q_magic_attack_min and config.q_magic_attack_min > 0 then
			minIncVal = player:getMinMT()
			player:setMinMT(minIncVal + flag * config.q_magic_attack_min)
		end

		if config.q_magic_attack_max and config.q_magic_attack_max > 0 then
			maxIncVal = player:getMaxMT()
			player:setMaxMT(maxIncVal + flag * config.q_magic_attack_max)
		end
	elseif school ==3 then
		if config.q_sc_attack_min and config.q_sc_attack_min > 0 then
			minIncVal = player:getMinDT()
			player:setMinDT(minIncVal + flag * config.q_sc_attack_min)
		end

		if config.q_sc_attack_max and config.q_sc_attack_max > 0 then
			maxIncVal = player:getMaxDT()
			player:setMaxDT(maxIncVal + flag * config.q_sc_attack_max)
		end
	end
	if config.q_max_hp and config.q_max_hp > 0 then
		local incMaxHP = player:getMaxHP()
		player:setMaxHP(incMaxHP + flag * config.q_max_hp)
	end

	if config.q_defence_min and config.q_defence_min > 0 then
		minIncVal = player:getMinDF()
		player:setMinDF(minIncVal + flag * config.q_defence_min)
	end

	if config.q_defence_max and config.q_defence_max > 0 then
		maxIncVal = player:getMaxDF()
		player:setMaxDF(maxIncVal + flag * config.q_defence_max)
	end

	if config.q_magic_defence_min and config.q_magic_defence_min > 0 then
		minIncVal = player:getMinMF()
		player:setMinMF(minIncVal + flag * config.q_magic_defence_min)
	end

	if config.q_magic_defence_max and config.q_magic_defence_max > 0 then
		maxIncVal = player:getMaxMF()
		player:setMaxMF(maxIncVal + flag * config.q_magic_defence_max)
	end

	if config.q_crit and config.q_crit > 0 then
		player:setCrit(player:getCrit() + flag * config.q_crit)
	end

	if config.q_hit and config.q_hit > 0 then
		player:setHit(player:getHit() + flag * config.q_hit)
	end

	if config.q_dodge and config.q_dodge > 0 then
		player:setDodge(player:getDodge() + flag * config.q_dodge)
	end

	if config.battle and config.battle > 0 then
		player:setbattle(player:getbattle() + flag * config.battle)
	end
end


-- 完成成就
function AchievePlayer:finishAchievememt(achieveID)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return
	end

	local achieveConfig = g_achieveMgr:getAchieveConfig(achieveID)
	if achieveConfig == nil then
		return
	end

	local groupID = achieveConfig.q_groupid

	self:achieveDone(groupID, achieveConfig.q_value)
	
	self:castAchieve2DB()
end

function AchievePlayer:getAchieveAttrString()
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if player == nil then
		return ""
	end

	local attrData = {}

	local school = player:getSchool()

	attrData.q_max_hp = 0
	if school == 1 then
		attrData.q_attack_min = 0
		attrData.q_attack_max = 0
	elseif school == 2 then
		attrData.q_magic_attack_min = 0
		attrData.q_magic_attack_max = 0
	elseif school == 3 then
		attrData.q_sc_attack_min = 0
		attrData.q_sc_attack_max = 0
	end
	attrData.q_defence_min = 0
	attrData.q_defence_max = 0
	attrData.q_magic_defence_min = 0
	attrData.q_magic_defence_max = 0

	local achieveLevelConfigs = g_achieveMgr:getAchieveLevelConfig()
	if not achieveLevelConfigs then
		return serialize(attrData)
	end

	local achieveLevel = self:getAchieveLevel()

	local achieveLevelConfig = achieveLevelConfigs[achieveLevel]
	if not achieveLevelConfig then
		return serialize(attrData)
	end

	local config = achieveLevelConfig.attr[school]
	if not config then
		return serialize(attrData)
	end

	attrData.q_max_hp = config.q_max_hp or 0
	if school == 1 then
		attrData.q_attack_min = config.q_attack_min or 0
		attrData.q_attack_max = config.q_attack_max or 0
	elseif school == 2 then
		attrData.q_magic_attack_min = config.q_magic_attack_min or 0
		attrData.q_magic_attack_max = config.q_magic_attack_max or 0
	elseif school == 3 then
		attrData.q_sc_attack_min = config.q_sc_attack_min or 0
		attrData.q_sc_attack_max = config.q_sc_attack_max or 0
	end
	attrData.q_defence_min = config.q_defence_min or 0
	attrData.q_defence_max = config.q_defence_max or 0
	attrData.q_magic_defence_min = config.q_magic_defence_min or 0
	attrData.q_magic_defence_max = config.q_magic_defence_max or 0

	return serialize(attrData)
end



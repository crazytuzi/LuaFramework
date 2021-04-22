-- @Author: xurui
-- @Date:   2017-04-01 11:04:14
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-21 19:36:45
local QBaseModel = import("...models.QBaseModel")
local QSpar = class("QSpar", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")

QSpar.EVENT_SPAR_UPDATE = "QSPARE_EVENT_SPAR_UPDATE"
QSpar.EVENT_WEAR_SPAR_SUCCESS = "EVENT_WEAR_SPAR_SUCCESS"
QSpar.EVENT_UNWEAR_SPAR_SUCCESS = "EVENT_UNWEAR_SPAR_SUCCESS"

QSpar.EVENT_INHERIT_SPAR_SUCCESS = "EVENT_INHERIT_SPAR_SUCCESS"
QSpar.EVENT_INHERIT_SPAR_CANCEL_SUCCESS = "EVENT_INHERIT_SPAR_CANCEL_SUCCESS"


QSpar.EVENT_SS_SPAR_UPDATE = "QSPARE_EVENT_SS_SPAR_UPDATE"
QSpar.EVENT_SS_SPAR_UPDATE_HERO = "QSPARE_EVENT_SS_SPAR_UPDATE_HERO"


QSpar.SPAR_NONE = "SPAR_NONE" --无状态
QSpar.SPAR_ICON = "SPAR_ICON" --显示为icon
QSpar.SPAR_LOCK = "SPAR_LOCK" --未解锁
QSpar.SPAR_WEAR = "SPAR_WEAR" --已装备
QSpar.SPAR_CAN_WEAR = "SPAR_CAN_WEAR" --可装备

QSpar.SKILL_LEVEL = {"Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ","Ⅷ","Ⅸ","Ⅹ"}

-- SS品质分界，低于此值的星级和实际显示一致，大于等于此值显示星级有+n的细分
QSpar.SPAR_SS_QUALITY = 22

QSpar._uiProps = {} -- 记录外骨显示使用的数据

table.insert(QSpar._uiProps, {fieldName = "team_attack_value", longName = "全队攻击", shortName = "全队攻击", isPercent = false })
table.insert(QSpar._uiProps, {fieldName = "team_hp_value", longName = "全队生命", shortName = "全队生命", isPercent = false })
table.insert(QSpar._uiProps, {fieldName = "team_armor_physical", longName = "全队物防", shortName = "全队物防", isPercent = false })
table.insert(QSpar._uiProps, {fieldName = "team_armor_magic", longName = "全队法防", shortName = "全队法防", isPercent = false })
table.insert(QSpar._uiProps, {fieldName = "attack_value", longName = "攻	    击", shortName = "攻击", isPercent = false })
table.insert(QSpar._uiProps, {fieldName = "hp_value", longName = "生    命", shortName = "生命", isPercent = false })
table.insert(QSpar._uiProps, {fieldName = "armor_physical", longName = "物理防御", shortName = "物防", isPercent = false })
table.insert(QSpar._uiProps, {fieldName = "armor_magic", longName = "法术防御", shortName = "法防", isPercent = false })

table.insert(QSpar._uiProps, {fieldName = "team_attack_percent", longName = "全队攻击", shortName = "全队攻击", isPercent = true })
table.insert(QSpar._uiProps, {fieldName = "team_hp_percent", longName = "全队生命", shortName = "全队生命", isPercent = true })
table.insert(QSpar._uiProps, {fieldName = "team_armor_physical_percent", longName = "全队物防", shortName = "全队物防", isPercent = true })
table.insert(QSpar._uiProps, {fieldName = "team_armor_magic_percent", longName = "全队法防", shortName = "全队法防", isPercent = true })
table.insert(QSpar._uiProps, {fieldName = "attack_percent", longName = "攻    击", shortName = "攻击", isPercent = true })
table.insert(QSpar._uiProps, {fieldName = "hp_percent", longName = "生    命", shortName = "生命", isPercent = true })
table.insert(QSpar._uiProps, {fieldName = "armor_physical_percent", longName = "物理防御", shortName = "物防", isPercent = true })
table.insert(QSpar._uiProps, {fieldName = "armor_magic_percent", longName = "法术防御", shortName = "法防", isPercent = true })



function QSpar:ctor(options)
	QSpar.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._spars = {}
end

function QSpar:didappear()
	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.heroUpdateEventHandler))
	self._gemstoneSuitConfigs = QStaticDatabase:sharedDatabase():getItemsByProp("type", ITEM_CONFIG_TYPE.GEMSTONE)
end

function QSpar:loginEnd()
	self:requestSparList()
end

function QSpar:disappear()

end

function QSpar:heroUpdateEventHandler()
	local heros = remote.herosUtil.heros
	local spars = {}
    for key,value in pairs(heros) do
    	if value.spar ~= nil then
    		for _, spar in ipairs(value.spar) do
    			spar.actorId = value.actorId
    			spar.count = 1
    			table.insert(spars, spar)
    		end
    	end
    end
	self:setSpars(spars , true)
end

function QSpar:getAllSpars()
	return self._spars or {}
end

function QSpar:setSpars(spars,isHeroUpdate)
	for _, value in pairs(spars) do
		if value.actorId == nil then
			value.actorId = 0
		end
		self._spars[value.sparId] = value
	end

	self:_countProp()

    self:dispatchEvent({name = QSpar.EVENT_SPAR_UPDATE})
    if not isHeroUpdate then
		self:_checkChangeSparSS()
    end

end

function QSpar:deletSpars(spars)
	for _, value in pairs(spars) do
		if self._spars[value.sparId].count and self._spars[value.sparId].count > 1 then
			self._spars[value.sparId].count = self._spars[value.sparId].count - 1
		else
			self._spars[value.sparId] = nil
		end
	end

    self:dispatchEvent({name = QSpar.EVENT_SPAR_UPDATE})
	self:_checkChangeSparSS()

end

--判断是否刷新全局属性
function QSpar:_checkChangeSparSS()
	local sparList = self:getTopSsSparList()
	local extraProp = app.extraProp:getSelfExtraProp() or {}
	local bRefrehs = not q.isEmpty(sparList)  or (q.isEmpty(sparList) and not q.isEmpty(extraProp) 
		and extraProp[app.extraProp.SPAR_PROP] and not q.isEmpty(extraProp[app.extraProp.SPAR_PROP]))
	if bRefrehs  then
    	self:dispatchEvent({name = QSpar.EVENT_SS_SPAR_UPDATE , sparList = sparList})
    	self:dispatchEvent({name = QSpar.EVENT_SS_SPAR_UPDATE_HERO })		
	end
end

--获得最强的外骨组合
function QSpar:getTopSsSparList()

	if q.isEmpty(self._spars) then
		return {}
	end

	local sparList = {}
	local sparTypeList = {}
	sparTypeList[1]={}
	sparTypeList[2]={}

	for _, spar in pairs(self._spars) do
		local sparConfig = QStaticDatabase:sharedDatabase():getItemByID(spar.itemId)
		if sparConfig.gemstone_quality and sparConfig.gemstone_quality >= APTITUDE.SS and spar.count > 0 then
			if sparConfig.type == ITEM_CONFIG_TYPE.GARNET then
				table.insert(sparTypeList[1], spar)
			else
				table.insert(sparTypeList[2], spar)
			end
		end
	end


	local index = 0
	local maxNum = 16	--左右外骨最多取

	if not q.isEmpty(sparTypeList[1]) then

		table.sort(sparTypeList[1],function(a, b) 

			if a.grade ~= b.grade then
				return a.grade > b.grade 
			else
				return a.itemId < b.itemId 
			end

			end)
		--spar struct {itemId, grade }

		for i,spar in ipairs(sparTypeList[1]) do
			if index >= maxNum then
				break
			end
			local  lastNum = maxNum - index
			lastNum = lastNum > spar.count and spar.count or lastNum
			for i=1,lastNum do
				table.insert(sparList, {itemId = spar.itemId , grade = spar.grade})
				index = index + 1
			end
		end
	end

	index = 0
	if not q.isEmpty(sparTypeList[2]) then
		table.sort(sparTypeList[2],function(a, b) 
			if a.grade ~= b.grade then
				return a.grade > b.grade 
			else
				return a.itemId < b.itemId 
			end
		 end)
		for i,spar in ipairs(sparTypeList[2]) do
			if index >= maxNum then
				break
			end
			local  lastNum = maxNum - index
			lastNum = lastNum > spar.count and spar.count or lastNum
			for i=1,lastNum do
				table.insert(sparList, {itemId = spar.itemId , grade = spar.grade})
				index = index + 1
			end
		end
	end

	return sparList
end

-- sparType 晶石类型 ITEM_CONFIG_TYPE.GARNET 代表榴石， ITEM_CONFIG_TYPE.OBSIDIAN 代表曜石
function QSpar:getSparsByType(sparType)
	local filterFunc
	filterFunc = function (itemId, itemType)
		if sparType == nil then
			return true
		end
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
		if itemInfo.type == itemType then
			return true
		end
		return false
	end

	
	local spar = {}
	for _, value in pairs(self._spars) do
		if value.count > 0 and filterFunc(value.itemId, sparType) then
			table.insert(spar, value)
		end
	end
	-- for _, value in pairs(self._spars) do
	-- 	if value.count == 0 then

	-- 	end
	-- end
	return spar
end

function QSpar:getSparsBySparId(sparId)
	if sparId == nil then return {} end

	for _, value in pairs(self._spars) do
		if value.sparId == sparId then
			return value
		end
	end
end

function QSpar:getSparsByItemId(itemId)
	if itemId == nil then return {} end
	
	for _, value in pairs(self._spars) do
		if value.itemId == itemId then
			return value
		end
	end
end


function QSpar:getCanAbsorbSparsByItemId(itemId)
	if itemId == nil then return {},0 end
	local spars = {}
	local num = 0
	for _, value in pairs(self._spars) do
		if value.itemId == itemId and (value.actorId == nil or value.actorId == 0)  and value.grade == 0 and value.level == 1 and value.exp == 0 then
			table.insert(spars ,value)
			num = num + value.count
		end
	end

	table.sort( spars, function(a, b) 
		if a.grade ~= b.grade then
			return a.grade < b.grade 
		elseif a.exp ~= b.exp then
			return a.exp < b.exp 
		else
			return a.count > b.count 
		end
	end )

	return  spars ,num
end


function QSpar:getSparsIndexByItemId(itemId)
	local itemInfo = db:getItemByID(itemId)
	if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.OBSIDIAN then
		return 2
	end
	return 1
end


function QSpar:getSparsIndexBySparId(sparId)
	if sparId == nil then return 1 end

	local sparIndex = 1
	local sparInfo = self:getSparsBySparId(sparId)

	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(sparInfo.itemId)
	if itemInfo.type == ITEM_CONFIG_TYPE.OBSIDIAN then
		sparIndex = 2
	end
	return sparInfo, sparIndex
end

--计算当前获得的宝石属性
function QSpar:_countProp()
	for _, spar in pairs(self._spars) do
	    spar = self:countSparProp(spar)
	end
end

function QSpar:countSparProp(spar)
	local sparConfig = db:getItemByID(spar.itemId)
	spar.prop = {}
	if sparConfig == nil then return spar end

    --强化属性
    local strengthProp = db:getTotalEnhancePropByLevel(sparConfig.enhance_data, spar.level)

    --升星属性
	local gradeConfig = db:getGradeByHeroActorLevel(spar.itemId, spar.grade)
	--吸收属性
	local absorbConfig = db:getSparsAbsorbConfigBySparItemIdAndLv(spar.itemId, spar.inheritLv or 0)

	--这里的属性只用于显示 所有不排除全局属性
    for name,_ in pairs(QActorProp._field) do
        if sparConfig[name] ~= nil then
        	spar.prop[name] = (spar.prop[name] or 0) + sparConfig[name]
        end
        if strengthProp[name] ~= nil then
        	spar.prop[name] = (spar.prop[name] or 0) + strengthProp[name]
        end
        if gradeConfig[name] ~= nil   then
        	spar.prop[name] = (spar.prop[name] or 0) + gradeConfig[name]
        end
        if absorbConfig and absorbConfig[name] ~= nil    then 
        	spar.prop[name] = (spar.prop[name] or 0) + absorbConfig[name]
        end        
    end

    return spar
end


function QSpar:setPropInfo(config , short ,isPercentFirst)
	local prop = {}
	local backProp = {}
	if not config then return prop end 
	--fieldName = "attack_value", longName = "攻    击", shortName = "攻击", isPercent = false 
	for i,v in ipairs(QSpar._uiProps) do
		if config[v.fieldName] ~= nil then
			local name = v.longName
			if short then
				name = v.shortName
			end
            local value = config[v.fieldName]
            if v.isPercent then
                value = q.PropPercentHanderFun(value)
            end
            local data_ = {value = value , name = name , key = v.fieldName}
            if isPercentFirst and not v.isPercent   then
				table.insert( backProp ,data_ )
            else
				table.insert( prop, data_)
            end
		end
	end
	for i,v in ipairs(backProp) do
		table.insert( prop,v)
	end
	return prop 
end 


function QSpar:setDivPropInfo(configOld ,configNew)
	local prop = {}
	local backProp = {}
	if not configNew then return prop end 

	if configOld== nil then configOld ={} end 


	for i,v in ipairs(QSpar._uiProps) do
		if configNew[v.fieldName] ~= nil then
            local value = configNew[v.fieldName] -( configOld[v.fieldName] or 0)
            if value > 0 then
				local name = v.longName
	            if v.isPercent then
	                value = q.PropPercentHanderFun(value)
	            end
	            local data_ = {value = value , name = name , key = v.fieldName}
				table.insert( prop, data_)
            end
		end
	end

	return prop 
end



--根据晶石id和星级获取套装信息
function QSpar:getSparSuitInfosBySparId(sparId, grade)
    if sparId == nil then return {} end
    
    grade = math.max(grade, 1)

    local  jewelrySuit = db:getStaticByName("jewelry_suit")

    local suits = {}
    for _, suit in pairs(jewelrySuit) do
        for _, value in pairs(suit) do
            if value.colour_ls == sparId or value.colour_ys == sparId then
                table.insert(suits,suit[1])
                break
            end
        end
    end

    return suits
end



-- 根据晶石ID和魂师ID获取可以激活和未激活的套装信息
function QSpar:getSuitInfoById(sparId, actorId)
	if sparId == nil then return {} end

	local sparInfo1, sparIndex = self:getSparsIndexBySparId(sparId)
	local suit = self:getSparSuitInfosBySparId(sparInfo1.itemId, 0)
	for _, value in pairs(suit) do
		value.isActive = false
	end
	-- QPrintTable(suit)

	local realSuit = {}
	local data = {}

	local index = sparIndex == 1 and 2 or 1
	local UIHeroModel = remote.herosUtil:getUIHeroByID(actorId)
	local sparInfo2 = UIHeroModel:getSparInfoByPos(index).info or {}

	local minGrade = UIHeroModel:getHeroSparMinGrade()
	local itemId1 = sparIndex == 1 and sparInfo1.itemId or sparInfo2.itemId
	local itemId2 = sparIndex == 1 and sparInfo2.itemId or sparInfo1.itemId
	if sparInfo2 ~= nil and next(sparInfo2) ~= nil then

		local activeSuit = QStaticDatabase:sharedDatabase():getActiveSparSuitInfoBySparId(itemId1, itemId2, minGrade)

		if activeSuit and next(activeSuit) then
			for _, value in pairs(suit) do
				if value.id == activeSuit.id then
					activeSuit.isActive = true
					data[#data+1] = activeSuit
				else
					value.isActive = false
					data[#data+1] = value
				end
			end
		end
	end
	if next(data) == nil then
		data = suit
	end 
	for _, value in pairs(data) do
		if value.isActive or (itemId1 == value.colour_ls and itemId2 == value.colour_ys) then
			table.insert(realSuit, 1, value)
		else
			value.isActive = false
			table.insert(realSuit, value)
		end
	end

	return realSuit
end

function QSpar:checkSparCanUpGrade(sparId, index)
	if sparId == nil then return 0, false end

	local sparInfo = self:getSparsBySparId(sparId)
	if sparInfo == nil then return 0, false end
	local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(sparInfo.itemId, sparInfo.grade+1)
	if gradeConfig == nil then return 0, false end
	local needNum = gradeConfig.soul_gem_count or 0
	local itemId = gradeConfig.soul_gem
	local itemConfig = db:getItemByID(itemId)
	if itemConfig == nil then return 0, false end

	local count = 0
	local isStrength = false
	local strengthCount = 0
	if itemConfig.category == ITEM_CONFIG_CATEGORY.SPAR_PIECE then
		local  num  = remote.items:getItemsNumByID(itemId)
		count = num
	elseif itemConfig.category == ITEM_CONFIG_CATEGORY.SPAR then

		local itemType = self:getSparItemTypeByIndex(index)
		local spars = self:getSparsByType(itemType)
		for _, value in pairs(spars) do
			if value.sparId ~= sparId and (value.actorId == nil or value.actorId == 0) and value.itemId == sparInfo.itemId and value.grade == 0 then
				if (value.level == 1 and value.exp > 0) or value.level > 1 then
					strengthCount = strengthCount + (value.count or 1)
					strengthCount = strengthCount > needNum and needNum or strengthCount
				end
				count = count + (value.count or 1)
			end
		end
	end

	if count - strengthCount < needNum then
		isStrength = true
	end
	return count, isStrength, strengthCount
end

function QSpar:checkSparIsBetter(sparId, index)
	if sparId == nil then return false end

	local isBetter = false
	local sparInfo = self:getSparsBySparId(sparId)
	if sparInfo == nil then return false end
	local itemType = self:getSparItemTypeByIndex(index)
	local spars = self:getSparsByType(itemType)
	for _, value in pairs(spars) do
		if value.sparId ~= sparId and (value.actorId == nil or value.actorId == 0) then
			if value.grade > sparInfo.grade or ( value.grade == sparInfo.grade and value.level > sparInfo.level ) then
				isBetter = true
				break
			end
		end
	end

	return isBetter
end

function QSpar:getSparItemTypeByIndex(index)
	local itemType =  ITEM_CONFIG_TYPE.GARNET
	if index == 2 then	
		itemType = ITEM_CONFIG_TYPE.OBSIDIAN
	end

	return itemType
end



function QSpar:getSparAbsorbTotalNumByItemIdAndLv(itemId, inheritLv)
	local totleNum = 0
	if inheritLv <= 0 then return 0 end

	for i=1,inheritLv do
		local absorbConfig = db:getSparsAbsorbConfigBySparItemIdAndLv(itemId, i )
		if absorbConfig then
			totleNum = totleNum + tonumber(absorbConfig.inherit_num)
		end
	end
	return totleNum
end

-- 检查宝石背包小红点
function QSpar:checkBackPackTips()
	if app.unlock:checkLock("UNLOCK_ZHUBAO", false) == false then
		return false
	end

	if self:checkSparPieceRedTip() then 
		return true
	end

	return false
end

function QSpar:checkSparPieceRedTip()
	local pieceInfo = QStaticDatabase:sharedDatabase():getItemsByProp("type", ITEM_CONFIG_TYPE.SPAR_PIECE)
	for i = 1, #pieceInfo do
		local craftInfo = remote.items:getItemsByMaterialId(pieceInfo[i].id) or {}
		local haveCount = remote.items:getItemsNumByID(pieceInfo[i].id) or 0
		if craftInfo[1] ~= nil and haveCount >= (craftInfo[1].component_num_1 or 0) and remote.user.money > (craftInfo[1].price or 0) then
			return true
		end
	end
	return false
end

--检查宝石背包里面是否有晶石
function QSpar:checkSparBackPackItemNum()
	-- 检查晶石碎片
	local items = QStaticDatabase:sharedDatabase():getItemsByCategory(ITEM_CONFIG_CATEGORY.SPAR_PIECE)
	for _, value in pairs(items) do
		if remote.items:getItemsNumByID(value.id) > 0 then
			return true
		end
	end
	--检查宝石
	local sparInfo = self:getSparsByType()
	if next(sparInfo) ~= nil then
		return true
	end

	return false
end

function QSpar:checkSparIsInitial(spar)
	if spar == nil or next(spar) == nil then return true end

	local state = false
	if spar.grade == 0 and spar.level == 1 and spar.exp == 0 then
		state = true
	end

	return state
end

function QSpar:getUnlockHeroLevelByIndex(index)
	local config = app.unlock:getConfigByKey("UNLOCK_ZHUBAO")
	if index == 2 then
		config = app.unlock:getConfigByKey("UNLOCK_ZHUBAO_1")
	end
	local level = config.hero_level

	return level
end	

--获取已经拥有晶石的ID组合
function QSpar:getHeros(selectId)
    local herosID = remote.herosUtil:getHaveHero()
    local heros = {}
    local selectPos = 1
    for _,actorId in ipairs(herosID) do
        local heroInfo = remote.herosUtil:getHeroByID(actorId)
        if heroInfo.spar ~= nil then
            table.insert(heros, actorId)
            if actorId == selectId then
                selectPos = #heros
            end
        end
    end
    return heros,selectPos
end

--获取已经拥有晶石的ID组合
function QSpar:removeSparNameSpecialStr(name)
	local str = string.split(name, "八蛛矛")
	return (str[1] or "")..(str[2] or "")
end


function QSpar:getSparItemIds(quality)
	local result = {}
	local items = QStaticDatabase:sharedDatabase():getItemsByCategory(ITEM_CONFIG_CATEGORY.SPAR)
	for k,v in pairs(items or {}) do
		if v.gemstone_quality == quality then
			table.insert(result ,v.id)
		end
	end
	table.sort(result, function(a, b)
				return a < b
		end)
	return result
end


function QSpar:getSparSuitSkillShowIds(suitConfig)
	local skillSzId = suitConfig.skill_sz
	if string.find(skillSzId, ";") then
		local skillSzIds = string.split(suitConfig.skill_sz, ";")
		skillSzId = skillSzIds[1] or skillSzId
	end

	local skillYzId = suitConfig.skill_yz
	if string.find(skillYzId, ";") then
		local skillYzIds = string.split(suitConfig.skill_sz, ";")
		skillYzId = skillYzIds[1] or skillYzId
	end

	-- print("skillSzId "..skillSzId)
	-- print("skillYzId "..skillYzId)
	return skillSzId , skillYzId
end


----------------------------------------- 协议 -----------------------------------------------

function QSpar:responseHandler(data, success, fail, succeeded)
	if data.sparInheritResponse then
		-- QPrintTable(data.sparInheritResponse)
		self:setSpars(data.sparInheritResponse.changedSparList or {})
		self:setSpars( {data.sparInheritResponse.spar or {} } )
	end


	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end

--[[
	拉取晶石列表
]]
function QSpar:requestSparList(success, fail, status)
	local request = {api = "SPAR_GET"}
	app:getClient():requestPackageHandler("SPAR_GET", request, function(response)
			self:responseSparList(response, success, nil, true, kind)
		end,
		function(response)
			self:responseSparList(response, nil, fail, nil, kind)
		end)
end

--[[
	拉取晶石列表协议返回
]]
function QSpar:responseSparList(data, success, fail, succeeded, kind)
	if data.sparGetResonse then
		self:setSpars(data.sparGetResonse.sparList or {})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	晶石强化列表
	@param: string sparId, 晶石ID
	@param: repeated Item consumeItems, 消耗的道具
]]
function QSpar:requestSparEnhance(sparId, consumeItems, success, fail, status)
	local sparEnhanceRequeset = {sparId = sparId, consumeItems = consumeItems}
	local request = {api = "SPAR_ENHANCE", sparEnhanceRequeset = sparEnhanceRequeset}
	app:getClient():requestPackageHandler("SPAR_ENHANCE", request, function(response)
			self:responseSparEnhance(response, success, nil, true, kind)
		end,
		function(response)
			self:responseSparEnhance(response, nil, fail, nil, kind)
		end)
end

--[[
	晶石强化协议返回
]]
function QSpar:responseSparEnhance(data, success, fail, succeeded, kind)
	if data.sparEnhanceResponse then
		self:setSpars( {data.sparEnhanceResponse.spar or {} } )
		-- data.sparEnhanceResponse.hero
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	晶石合成
	@param: int32 itemId, 物品ID
	@param: int32 count, 物品数量
]]
function QSpar:requestSparCraft(itemId, count, success, fail, status)
	local sparCraftRequest = {itemId = itemId, count = count}
	local request = {api = "SPAR_CRAFT", sparCraftRequest = sparCraftRequest}
	app:getClient():requestPackageHandler("SPAR_CRAFT", request, function(response)
			self:responseSparCraft(response, success, nil, true, kind)
		end,
		function(response)
			self:responseSparCraft(response, nil, fail, nil, kind)
		end)
end

--[[
	晶石合成协议返回
]]
function QSpar:responseSparCraft(data, success, fail, succeeded, kind)
	if data.sparCraftResponse then
		self:setSpars(data.sparCraftResponse.sparList or {})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	晶石升星
	@param: string sparId, 晶石ID
]]
function QSpar:requestSparUpgrade(sparId , success, fail, status)
	local sparUpgradeRequest = {sparId = sparId }
	local request = {api = "SPAR_UPGRADE", sparUpgradeRequest = sparUpgradeRequest}
	app:getClient():requestPackageHandler("SPAR_UPGRADE", request, function(response)
			self:responseSparUpgrade(response, success, nil, true, kind)
		end,
		function(response)
			self:responseSparUpgrade(response, nil, fail, nil, kind)
		end)
end

--[[
	晶石升星协议返回
]]
function QSpar:responseSparUpgrade(data, success, fail, succeeded, kind)
	if data.sparUpgradeResponse then
		self:setSpars(data.sparUpgradeResponse.changedSparList or {})
		self:setSpars({data.sparUpgradeResponse.spar})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	晶石装备
	@param: string sparId, 晶石ID
	@param: int32 actor, 魂师ID
	@param: bool equipType, 装卸状态，true 为装备, false 为卸下
]]
function QSpar:requestSparEquipment(sparId, actor, equipType, itemId, success, fail, status)
	local sparEquipRequest = {sparId = sparId, actor = actor, equipType = equipType}
	local request = {api = "SPAR_EQUIP", sparEquipRequest = sparEquipRequest}
	app:getClient():requestPackageHandler("SPAR_EQUIP", request, function(response)
			self:responseSparEquipment(equipType, sparId, response, success, nil, true, kind)
		end,
		function(response)
			self:responseSparEquipment(equipType, sparId, response, nil, fail, nil, kind)
		end)
end

--[[
	晶石装备协议返回
]]
function QSpar:responseSparEquipment(equipType, sparId, data, success, fail, succeeded, kind)
	if data.sparEquipResponse then
		self:setSpars(data.sparEquipResponse.changeSpar or {})
		if equipType then
    		self:dispatchEvent({name = QSpar.EVENT_WEAR_SPAR_SUCCESS, sparId = sparId})
   	 	else
    		self:dispatchEvent({name = QSpar.EVENT_UNWEAR_SPAR_SUCCESS, sparId = sparId})
    	end
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	晶石重生
	@param: repeated Spar recoverSpar, 重生的晶石
]]
function QSpar:requestSparReCover(recoverSpar, success, fail, status)
	local sparRecoverRequest = {recoverSpar = recoverSpar}
	local request = {api = "SPAR_RECOVER", sparRecoverRequest = sparRecoverRequest}
	app:getClient():requestPackageHandler("SPAR_RECOVER", request, function(response)
			self:responseSparReCover(response, success, nil, true, kind)
		end,
		function(response)
			self:responseSparReCover(response, nil, fail, nil, kind)
		end)
end

--[[
	晶石重生协议返回
]]
function QSpar:responseSparReCover(data, success, fail, succeeded, kind)
	if data.sparRecoverResponse then
		self:deletSpars(data.sparRecoverResponse.recoverSpar or {})
		self:setSpars(data.sparRecoverResponse.gainSpar or {})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	晶石分解
	@param: repeated Spar returnSparList, 分解的晶石列表
	@param: repeated Item returnItemList, 分解的晶石碎片列表
]]
function QSpar:requestSparReturn(returnSparList, returnItemList, success, fail, status)
	local sparReturnRequest = {returnSparList = returnSparList, returnItemList = returnItemList}
	local request = {api = "SPAR_RETURN", sparReturnRequest = sparReturnRequest}
	app:getClient():requestPackageHandler("SPAR_RETURN", request, function(response)
			self:responseSparReturn(returnSparList, response, success, nil, true, kind)
		end,
		function(response)
			self:responseSparReturn(nil, response, nil, fail, nil, kind)
		end)
end

--[[
	晶石分解协议返回
]]
function QSpar:responseSparReturn(returnSparList, data, success, fail, succeeded, kind)
	if data.sparReturnRespons and next(returnSparList) then
		self:deletSpars({ returnSparList[1].returnSparInfo } or {})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	晶石一键强化
    optional string actorId = 1;                                                    // 晶石id
    optional int32 targetLevel = 2;                                               // 目标等级
]]
function QSpar:requestSparOneKeyEnhanceRequest(actorId, targetLevel, success, fail, status)
	local sparOneKeyEnhanceRequeset = {actorId = actorId, targetLevel = targetLevel}
	local request = {api = "SPAR_ONE_KEY_ENHANCE", sparOneKeyEnhanceRequeset = sparOneKeyEnhanceRequeset}
	app:getClient():requestPackageHandler(request.api, request, function(response)
			self:responseOneKeyEnhanceReturn(response, success, nil, true, kind)
		end,
		function(response)
			self:responseOneKeyEnhanceReturn(response, nil, fail, nil, kind)
		end)
end

--[[
	晶石一键强化协议返回
]]
function QSpar:responseOneKeyEnhanceReturn(data, success, fail, succeeded, kind)
	if data.sparReturnRespons then
		self:setSpars(data.sparReturnRespons.returnSparInfo or {})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--晶石吸收Request
function QSpar:requestSparInherit(sparId, consumeSpar, success, fail, status)
	local sparInheritRequest = {sparId = sparId, consumeSpar = consumeSpar}
	local request = {api = "SPAR_INHERIT", sparInheritRequest = sparInheritRequest}
	app:getClient():requestPackageHandler("SPAR_INHERIT", request, function(response)
			self:responseHandler(response, success, nil, true)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil)
		end)
end

--晶石重置吸收Request
function QSpar:requestSparInheritCancel(sparId, success, fail, status)
	local sparInheritCancelRequest = {sparId = sparId}
	local request = {api = "SPAR_CANCEL_ALL_INHERIT", sparInheritCancelRequest = sparInheritCancelRequest }
	app:getClient():requestPackageHandler("SPAR_CANCEL_ALL_INHERIT", request, function(response)
			self:responseHandler(response, success, nil , true)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil)
		end)
end



return QSpar
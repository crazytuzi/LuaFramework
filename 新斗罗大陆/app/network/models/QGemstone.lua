--
-- Author: wkwang
-- Date: 2016-7-15
-- 宝石数据管理

local QBaseModel = import("...models.QBaseModel")
local QGemstone = class("QGemstone", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QUserData = import("..utils.QUserData")

QGemstone.EVENT_UPDATE = "QGEMSTONE_EVENT_UPDATE"
QGemstone.EVENT_EXTRAPROP_UPDATE = "QGEMSTONE_EVENT_EXTRAPROP_UPDATE"
QGemstone.EVENT_SSPLUS_UPDATE = "QGEMSTONE_EVENT_SSPLUS_UPDATE"		-- ss+魂骨

QGemstone.EVENT_WEAR = "EVENT_WEAR"
QGemstone.EVENT_UNWEAR = "EVENT_UNWEAR"

QGemstone.GEMSTONE_NONE = "GEMSTONE_NONE" --无状态
QGemstone.GEMSTONE_ICON = "GEMSTONE_ICON" --显示为icon
QGemstone.GEMSTONE_LOCK = "GEMSTONE_LOCK" --未解锁
QGemstone.GEMSTONE_WEAR = "GEMSTONE_WEAR" --已装备
QGemstone.GEMSTONE_CAN_WEAR = "GEMSTONE_CAN_WEAR" --可装备
QGemstone.GEMSTONE_ANDVANCED_STATE = "GEMSTONE_ANDVANCED_STATE" --魂骨进阶阶段
QGemstone.GEMSTONE_TOGOD_STATE = "GEMSTONE_TOGOD_STATE" --魂骨化神阶段

QGemstone.GEMSTONE_MIX_SUIT_SKILL = "GEMSTONE_MIX_SUIT_SKILL" --魂骨混合技能


QGemstone.EVENT_ADVANCED = "EVENT_ADVANCED"  --魂骨进阶
QGemstone.EVENT_TOGOD = "EVENT_TOGOD"  --魂骨化神

QGemstone.EVENT_MIX_SUCCESS = "EVENT_MIX_SUCCESS"  --魂骨融合成功

QGemstone.EVENT_JUMP_MIX = "EVENT_JUMP_MIX"  --魂骨融合跳转


QGemstone.GEMSTONE_TOGOD_LEVEL = 25		--进阶到化神的等级分割

QGemstone.GEMSTONE_GODLEVLE_TEST = 0	--自己测试默认的进阶等级


-- 消耗魂骨碎片的品质 若有修改_getRefinePieceExp和_refineAutoSelectFilter也要改 一个返回经验一个添加过滤
QGemstone.GEMSTONE_REFINE_CONSUME_QUALITY = 20
-- 记录到本地的字段  是否开启精炼自动选择的过滤
QGemstone.GEMSTONE_REFINE_ENABLE_FILTER = "GEMSTONE_REFINE_ENABLE_FILTER"
-- 精炼中快捷转换量表属性所用的转换表
QGemstone.GEMSTONE_CONVERT_TABLE_REFINE = {
	team_attack_value = { name = "全队攻击", isPercent = false },
	team_hp_value = { name = "全队生命", isPercent = false },
	team_armor_physical = { name = "全队物防", isPercent = false },
	team_armor_magic = { name = "全队法防", isPercent = false },
	team_attack_percent = { name = "全队攻击", isPercent = true },
	team_hp_percent = { name = "全队生命", isPercent = true },
	team_armor_physical_percent = { name = "全队物防", isPercent = true },
	team_armor_magic_percent = { name = "全队法防", isPercent = true },
}


function QGemstone:ctor(options)
	QGemstone.super.ctor(self, options)
	self._gemstones = {}
	self._gemstonesMap = {}
end

function QGemstone:didappear()
	QGemstone.super.didappear(self)
	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.heroUpdateEventHandler))
	self._gemstoneSuitConfigs = QStaticDatabase:sharedDatabase():getItemsByProp("type", ITEM_CONFIG_TYPE.GEMSTONE)
end

function QGemstone:disappear()
	if self._remoteProxy then
		self._remoteProxy:removeAllEventListeners()
	end
end

--更新魂师身上的宝石信息
function QGemstone:heroUpdateEventHandler()
	for _,gemstone in ipairs(self._gemstones) do
		gemstone.actorId = nil
		gemstone.position = nil
	end
	local heros = remote.herosUtil.heros
	local gemstones = {}
    for key,value in pairs(heros) do
    	if value.gemstones ~= nil then
    		for _,gemstone in ipairs(value.gemstones) do
    			gemstone = clone(gemstone)
    			gemstone.actorId = value.actorId
    			table.insert(gemstones, gemstone)
    		end
    	end
    end
	self:setGemstones(gemstones , true)
end

-- 是否进入化神阶段
function QGemstone:isShowToGodByid(sid)
	self._gemstonesMap ={}
	return false
end
--获取所有已经获得宝石信息
function QGemstone:getGemstones()
	return self._gemstones
end

function QGemstone:getGemsonesAdvanced(godLevel)
	local newadvanced = math.floor(godLevel/5)
	local nextLevel = (godLevel+1) % 5 
	if nextLevel == 0 then
		nextLevel = 5
	end

	return newadvanced, nextLevel
end
--根据是否穿戴获取宝石
function QGemstone:getGemstoneByWear(isWear)
	local _gemstones = {}
	for _,gemstone in ipairs(self._gemstones) do
		if (gemstone.position ~= nil and gemstone.position > 0) == isWear then
			table.insert(_gemstones, gemstone)
		end
	end
	return _gemstones
end


--判断是否培养过
function QGemstone:checkGemstoneIsCulture(gemstone)
	if gemstone.level and gemstone.level > 1 then
		return true
	end 
	if gemstone.craftLevel and gemstone.craftLevel > 0 then
		return true
	end 
	if gemstone.godLevel and gemstone.godLevel > 0 then
		return true
	end 
	if gemstone.mix_exp and gemstone.mix_exp > 0 then
		return true
	end 
	if gemstone.mix_level and gemstone.mix_level > 0 then
		return true
	end 
	if gemstone.refine_consume and gemstone.refine_consume ~="" then
		return true
	end 
	if gemstone.refine_level and gemstone.refine_level > 0 then
		return true
	end 					
	return false
end

--魂师信息发生变化后设置魂师的宝石信息
function QGemstone:updateHeroGemstone(heros)
	-- body
end

--根据ID获取宝石
function QGemstone:getGemstoneById(sid)
	return self._gemstonesMap[sid]
end

function QGemstone:getAllGemstones()
	return self._gemstones or {}
end

--获取指定类型的宝石
--@param types = {true,false,true,false}
function QGemstone:getGemstonesByType(types, gemstoneQuality)
	if gemstoneQuality == nil then gemstoneQuality = 0 end
	local _gemstones = {}
	for _,gemstone in ipairs(self._gemstones) do
		for index,isCan in ipairs(types) do
			if isCan == true and index == gemstone.gemstoneType and gemstone.actorId == nil and gemstone.gemstoneQuality > gemstoneQuality then
				table.insert(_gemstones, gemstone)
			end
		end
	end
	return _gemstones
end

--获取目标资质即以上的宝石
function QGemstone:getGemstonesByQuality(gemstoneQuality)
	if gemstoneQuality == nil then gemstoneQuality = 0 end
	local _gemstones = {}
	for _,gemstone in ipairs(self._gemstones) do
		if gemstone.gemstoneQuality >= gemstoneQuality then
			table.insert(_gemstones, gemstone)
		end
	end
	return _gemstones
end

--判断两个宝石是否是套装
function QGemstone:checkGemstoneIsSuit(itemId1, itemId2)
	local itemConfig1 = QStaticDatabase:sharedDatabase():getItemByID(itemId1)
	local itemConfig2 = QStaticDatabase:sharedDatabase():getItemByID(itemId2)
	return itemConfig1.gemstone_set_index == itemConfig2.gemstone_set_index	
end

--计算当前获得的宝石属性
function QGemstone:_countProp()
	for _,gemstone in ipairs(self._gemstones) do
		if gemstone.isNew == true then
		    gemstone.isNew = false
		    gemstone = self:countGemstoneProp(gemstone)
		end
	end
end


function QGemstone:getNextConfigListByGoalLevel(id, curLevel, goalLevel)
	local tbl = {}
	for i = curLevel + 1, goalLevel, 1 do
		local config = db:getGemstoneEvolutionBygodLevel(id, i)
		table.insert(tbl, config)
	end
	return tbl
end


function QGemstone:checkGemstoneIsSsAptitude(gemstoneData)
	local goldLevel = gemstoneData.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local mixLevel = gemstoneData.mix_level or 0
	return mixLevel > 0 or goldLevel >= GEMSTONE_MAXADVANCED_LEVEL
end


function QGemstone:getGemstoneMixConfigListById(id)
	local  configs = db:getStaticByName("gemstone_mix") 
	-- QPrintTable(configs)
	-- QPrintTable(configs[tostring(id)])
	return configs[tostring(id)] or {}
end

function QGemstone:getGemstoneMixConfigByIdAndLv(id , lv)
	return db:getGemstoneMixConfigByIdAndLv(id , lv)
end

-- return tbl
-- {value = value , name = name , key = v.fieldName}
function QGemstone:setPropInfo(config , short ,isPercentFirst ,isAllTeamFirst)
	local prop = {}
	local percentWeight = isPercentFirst and 1000 or 0
	local allTeamWeight = isAllTeamFirst and 100 or 0

	for i,v in ipairs(QActorProp._uiFields) do
		if config[v.fieldName] ~= nil then
			local name = v.name
			-- if short then
			-- 	name = v.shortName
			-- end
			local weight = i 
       		local value = config[v.fieldName]
            if v.handlerFun then
                value = q.PropPercentHanderFun(value)
                weight = weight + percentWeight
            end
            if v.isAllTeam then
                weight = weight + allTeamWeight
            end
            local data_ = {value = value , name = name , key = v.fieldName , weight = weight}
            table.insert(prop,data_) 
		end
	end

	table.sort( prop, function(a, b) 
				return a.weight > b.weight 
			end )
	
	return prop 

end


function QGemstone:getGemstoneMixConfigAndNextByIdAndLv(id , lv)
	local configs = self:getGemstoneMixConfigListById(id)
	local curConfig = nil
	local nextConfig = nil
	for i,v in ipairs(configs) do
		if tonumber(v.mix_level) == lv then
			curConfig = v
		elseif tonumber(v.mix_level) == (lv + 1) then
			nextConfig = v
		end
	end
	return curConfig , nextConfig
end

function QGemstone:getGemstoneMixSuitConfigTableById(id , suitNum)
	local configs = db:getStaticByName("gemstone_suit")[tostring(id)]
	local resultTbl = {}
	for k,v in pairs(configs or {}) do
		if v.suit_num == suitNum then
			table.insert(resultTbl, tonumber(v.level) ,v)
		end
end

	return resultTbl
end

function QGemstone:getGemstoneMixSuitConfigByData(id , suitNum , level)
	return db:getGemstoneMixSuitConfigByData(id , suitNum , level)
end

--gemstoneData 存储转换数据的关键属性	itemId、godLevel、mix_level
--返回转化后的数据	 转化后的 itemId 、 quality、 iconPath
function QGemstone:getGemstoneTransferInfoByData(gemstoneData)
	local resultItem = 1
	local resultQuality = APTITUDE.C
	local resultIconPath = ""
	local itemId = gemstoneData.itemId
	if not itemId then 
		return resultItem , resultQuality ,resultIconPath
	end
	local godLevel =  gemstoneData.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local mixLevel = gemstoneData.mix_level or 0
	if mixLevel > 0 then
		resultItem	= itemId	
		resultQuality = APTITUDE.SSR
		local mixConfig= self:getGemstoneMixConfigAndNextByIdAndLv(itemId,mixLevel)
		if mixConfig and mixConfig.gem_icon then
			resultIconPath = mixConfig.gem_icon
		end

	elseif godLevel >= GEMSTONE_MAXADVANCED_LEVEL then
		local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(itemId,GEMSTONE_MAXADVANCED_LEVEL)
		if gemstoneInfo_ss then
			resultItem = gemstoneInfo_ss.gem_evolution_new_id
		else
			resultItem = itemId
		end
		resultQuality = APTITUDE.SS
		local itemConfig = db:getItemByID(resultItem)
		resultIconPath = itemConfig.icon
	else
		resultItem	= itemId	
		local itemConfig = db:getItemByID(resultItem)
		resultQuality = itemConfig.gemstone_quality
		resultIconPath = itemConfig.icon
	end
	return resultItem , resultQuality ,resultIconPath
end

function QGemstone:getGemstoneEvolutionSkillProp(itemId,goldLevel)

	local advancedSkillId, godSkillId = db:getGemstoneEvolutionSkillIdBygodLevel(itemId,goldLevel)
	local skillsProp = {}
	if advancedSkillId then
		local skillData = db:getSkillDataByIdAndLevel(advancedSkillId,1)
		local count = 1
		while true do
			local key = skillData["addition_type_"..count]
			local value = skillData["addition_value_"..count]
			if key == nil then
				break
			end
			if skillsProp[key] == nil then
				skillsProp[key] = value
			else
				skillsProp[key] = skillsProp[key] + value
			end
			count = count + 1
		end
	end
	if godSkillId then
		local skillData = db:getSkillDataByIdAndLevel(godSkillId,1)
		local count = 1
		while true do
			local key = skillData["addition_type_"..count]
			local value = skillData["addition_value_"..count]
			if key == nil then
				break
			end
			if skillsProp[key] == nil then
				skillsProp[key] = value
			else
				skillsProp[key] = skillsProp[key] + value
			end
			count = count + 1
		end
	end

	return skillsProp
end


function QGemstone:getAllAdvancedProp(itemId,startLevel,endlevel)
	if itemId == nil then return end
	local propInfo = {}
    for ii = startLevel ,endlevel do
    	local advancedInfo = db:getGemstoneEvolutionBygodLevel(itemId,ii)
    	if advancedInfo.attack_value then
    		propInfo.attack_value = (propInfo.attack_value or 0) + advancedInfo.attack_value
    	end

    	if advancedInfo.hp_value then
    		propInfo.hp_value = (propInfo.hp_value or 0) + advancedInfo.hp_value
    	end
    	if advancedInfo.armor_physical then
    		propInfo.armor_physical = (propInfo.armor_physical or 0) + advancedInfo.armor_physical
    	end
    	if advancedInfo.armor_magic then
    		propInfo.armor_magic = (propInfo.armor_magic or 0) + advancedInfo.armor_magic
    	end
    end

    return propInfo
end
function QGemstone:countGemstoneProp(gemstone)
	local gemstoneConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
    gemstone.gemstoneType = gemstoneConfig.gemstone_type
    gemstone.gemstoneQuality = gemstoneConfig.gemstone_quality
	gemstone.prop = {}
	gemstone.strengthMasterLevel = 0
	gemstone.strengthMasterProp = {}
    --强化属性
    local strnegthProp = db:getTotalEnhancePropByLevel(gemstoneConfig.enhance_data, gemstone.level)
    --突破属性
	local breakconfig = db:getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel)

	--进阶属性
	local advancedInfo = db:getGemstoneEvolutionAllPropBygodLevel(gemstone.itemId,(gemstone.godLevel or 0))
    --大师属性
 --    if ENABLE_GEMSTONE_MASTER then
	--     local masterConfig = QStaticDatabase:sharedDatabase():getGemstoneStrengthenMasterByLevel(gemstoneConfig.gemstone_quality, gemstoneConfig.gemstone_type, gemstone.level)
	--     if masterConfig ~= nil then 
	--     	gemstone.strengthMasterLevel = masterConfig.master_level
	--     end
	-- end

    for name,_ in pairs(QActorProp._field) do
        if gemstoneConfig[name] ~= nil then
        	gemstone.prop[name] = (gemstone.prop[name] or 0) + gemstoneConfig[name]
        end
        if strnegthProp[name] ~= nil then
        	gemstone.prop[name] = (gemstone.prop[name] or 0) + strnegthProp[name]
        end
        if breakconfig[name] ~= nil then
        	gemstone.prop[name] = (gemstone.prop[name] or 0) + breakconfig[name]
        end

        if advancedInfo then
        	for _,v in pairs(advancedInfo) do
		        if v[name] ~= nil then
		        	gemstone.prop[name] = (gemstone.prop[name] or 0) + v[name]
		        end
		    end
	    end
        -- if ENABLE_GEMSTONE_MASTER and masterConfig ~= nil and masterConfig[name] ~= nil then
        -- 	gemstone.prop[name] = (gemstone.prop[name] or 0) + masterConfig[name]
        -- 	gemstone.strengthMasterProp[name] = (gemstone.strengthMasterProp[name] or 0) + masterConfig[name]
        -- end
    end

 --    --属性
 --    for name,_ in pairs(QActorProp._field) do
 --        if gemstoneConfig[name] ~= nil then
 --        	gemstone.prop[name] = gemstoneConfig[name]
 --        end
 --    end

 --    --强化属性
 --    local strnegthProp = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(gemstoneConfig.enhance_data, gemstone.level)
 --    for name,_ in pairs(QActorProp._field) do
 --        if strnegthProp[name] ~= nil then
 --        	if gemstone.prop[name] ~= nil then
 --        		gemstone.prop[name] = gemstone.prop[name] + strnegthProp[name]
 --        	else
 --        		gemstone.prop[name] = strnegthProp[name]
 --        	end
 --        end
 --    end

 --    --突破属性
	-- local breakconfig = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel)
 --    for name,_ in pairs(QActorProp._field) do
 --        if breakconfig[name] ~= nil then
 --        	if gemstone.prop[name] ~= nil then
 --        		gemstone.prop[name] = gemstone.prop[name] + breakconfig[name]
 --        	else
 --        		gemstone.prop[name] = breakconfig[name]
 --        	end
 --        end
 --    end

 --    --大师属性
 --    local masterConfig = QStaticDatabase:sharedDatabase():getGemstoneStrengthenMasterByLevel(gemstone.gemstoneQuality, gemstone.gemstoneType, gemstone.level)
 --    if masterConfig ~= nil then
 --    	gemstone.strengthMasterLevel = masterConfig.master_level
	--     for name,_ in pairs(QActorProp._field) do
	--         if masterConfig[name] ~= nil then
	--         	gemstone.strengthMasterProp[name] = masterConfig[name]
	--         	if gemstone.prop[name] ~= nil then
	--         		gemstone.prop[name] = gemstone.prop[name] + masterConfig[name]
	--         	else
	--         		gemstone.prop[name] = masterConfig[name]
	--         	end
	--         end
	--     end
 --    end
    return gemstone
end

--根据item表的配置获取类型描述
function QGemstone:getTypeDesc(gemstoneType)
	if gemstoneType == 1 then
		return "攻击类"
	elseif gemstoneType == 2 then
		return "物防类"
	elseif gemstoneType == 3 then
		return "法防类"
	elseif gemstoneType == 4 then
		return "生命类"
	end
	return ""
end

function QGemstone:getGemstoneNameByData(nameStr , godLevel , mixLevel)
	local nameResult = nameStr

	godLevel = godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	mixLevel = mixLevel or 0

	if godLevel > 0 and godLevel <= GEMSTONE_MAXADVANCED_LEVEL  then
 		local advanced,level = self:getGemsonesAdvanced(godLevel)
    	nameResult = nameResult ..q.getRomanNumberalsByInt(advanced).."阶"
	elseif godLevel > GEMSTONE_MAXADVANCED_LEVEL then
   		nameResult = "神·"..nameResult
    end
	if mixLevel > 0 then
   		nameResult = "【无瑕】"..nameResult
	end
	return nameResult
end


--根据品质获取品质信息
function QGemstone:getSABC(aptitude)
    for _,value in ipairs(HERO_SABC) do
        if value.aptitude == aptitude then
            return value
        end
    end
end

--根据itemId获取套装
function QGemstone:getSuitByItemId(itemId)
	local suits = {}
	local itemConfig = db:getItemByID(itemId)
	if self._gemstoneSuitConfigs ~= nil then
		for _,config in ipairs(self._gemstoneSuitConfigs) do
			if config.gemstone_set_index == itemConfig.gemstone_set_index then
				table.insert(suits, config)
			end
		end
	end
	return suits
end

-- 魂骨精炼查主键获取列表
function QGemstone:_getRefineConfigListByIdAndLevel(id)
	local  configs = db:getStaticByName("gemstone_refine") 
	return configs[tostring(id)] or {}
end
-- 魂骨精炼 获取id和等级对应条目
function QGemstone:getRefineConfigByIdAndLevel(id , lv)
	-- local configs = self:_getRefineConfigListByIdAndLevel(id)

	-- for i,v in ipairs(configs) do
	-- 	if tonumber(v.level) == lv then
	-- 		return v
	-- 	end
	-- end
	return db:getRefineConfigByIdAndLevel(id , lv)
end

-- 转换魂骨精炼的属性信息  给显示层显示用的
function QGemstone:convertRefineAttribute(config, isZero)
	-- 显示用的
	local attributes = {
		valueName = "",		-- 固定属性名
		value = "0",		-- 固定属性
		valueSrc = 0,		-- 固定属性的原数值

		percentName = "",	-- 百分比属性名
		percent = "0",		-- 百分比属性
		percentSrc = 0		-- 百分比属性的原数值
	}

	local tValue = 0
	for key, value in pairs(config or {}) do
		if QGemstone.GEMSTONE_CONVERT_TABLE_REFINE[key] then
			local target = QGemstone.GEMSTONE_CONVERT_TABLE_REFINE[key]
			tValue = value or 0
			if isZero then
				tValue = 0
			end
			if target.isPercent then
				attributes.percentName = target.name
				attributes.percentSrc = tValue
				attributes.percent = q.getFilteredNumberToString(tValue, true, 2)
			else
				local num, unit = q.convertLargerNumber(tValue)
				attributes.valueName = target.name
				attributes.valueSrc = tValue
				attributes.value = tostring(num) .. unit
			end
		end
	end
	return attributes
end

-- 根据魂骨类型和品质获取对应魂骨碎片id数量  获取要消耗的魂骨碎片列表的
function QGemstone:getStonePieceByTypeAndQuality(stoneType)
	local stoneList = {}

	local pieceInfo = db:getItemsByProp("type", ITEM_CONFIG_TYPE.GEMSTONE_PIECE)
	for _, itemConfig in ipairs(pieceInfo) do
		if itemConfig.gemstone_type == stoneType and itemConfig.gemstone_quality == QGemstone.GEMSTONE_REFINE_CONSUME_QUALITY then
			table.insert(stoneList, {
				id = itemConfig.id,
				count = remote.items:getItemsNumByID(itemConfig.id),
				selectedCount = 0
			})
		end
	end
	table.sort(stoneList, function(a, b)
		return a.id > b.id
	end)
	return stoneList
end

-- 获取精炼历史消耗物品  从后端给的数据获取的
function QGemstone:getRefineHistoryItems(sid)
	local gemstone = self:getGemstoneById(sid)
	if gemstone and gemstone.refine_consume then
		return remote.items:analysisServerItem(gemstone.refine_consume)
	end
	return {}
end

-- 获取精炼历史经验,isUpdate是否更新数据
function QGemstone:getRefineHistoryExp(sid, isUpdate)
	self._refineHistoryExpMap = self._refineHistoryExpMap or {}
	local exp = self._refineHistoryExpMap[sid]
	if not exp or isUpdate then
		exp = self:calcRefineItemsExp(self:getRefineHistoryItems(sid), "id", "count")
		self._refineHistoryExpMap[sid] = exp
	end
	return exp
end

-- 精炼，计算道具列表经验
function QGemstone:calcRefineItemsExp(itemList, itemIdKey, countKey)
	local exp = 0
	itemList = itemList or {}
	for _, item in ipairs(itemList) do
		exp = exp + self:getRefinePieceExp(item[itemIdKey]) * item[countKey]
	end
	return exp
end

-- 精炼，给出itemId获取对应经验  获取碎片经验的
function QGemstone:getRefinePieceExp(itemId)
	local itemConfig = db:getItemByID(itemId)
	return itemConfig.exp_num
end

-- 根据sid和选择清单，获取相应状态信息  给出选中列表返回预期等级经验信息的
function QGemstone:getCurrentRefineInfoByItemList(sid, selectedList, showCheck)
	local refineConfig = db:getStaticByName("gemstone_refine")
	-- 返回信息
	local info = {
		level = 0,		-- 等级
		exp = 0,		-- 经验
		nextExp = 0,	-- 升级所需经验
		isMax = false	-- 是否满级
	}

	info.exp = info.exp + self:getRefineHistoryExp(sid, false)							-- 当前经验
	info.exp = info.exp + self:calcRefineItemsExp(selectedList, "id", "selectedCount")	-- 所选item能获得的经验

	local gemstoneInfo = self:getGemstoneById(sid)
	if not gemstoneInfo then
		return info
	end

	local itemConfig = refineConfig[tostring(gemstoneInfo.itemId)]
	for _, item in ipairs(itemConfig) do
		info.nextExp = item.exp
		if info.exp >= info.nextExp then
			info.level = item.level
			info.exp = info.exp - info.nextExp
		else
			break
		end
	end

	if showCheck then
		-- 测试验证本地level和服务器返回的level是否一致
		local gemstone = self:getGemstoneById(sid)
		if info.level ~= tonumber(gemstone.refine_level or 0) then
			print(string.format("精炼等级不一致：%d %d", info.level, gemstone.refine_level or 0))
		end
	end

	info.isMax = (info.level >= #itemConfig)

	return info
end

-- 自动选择的过滤函数
function QGemstone:_refineAutoSelectFilter(itemId)
	return (603001 <= itemId and itemId <= 603004)			-- 海神魔鲸套
end

-- 魂骨精炼 给出道具列表自动选择到下一级所需经验  计算自动选择的
function QGemstone:autoSelectRefineList(nowExp, nextExp, itemList)
	local enableFilter = self:getRefineFilterEnable()

	local isPass = false
	for _, value in ipairs(itemList) do
		isPass = false
		if enableFilter and self:_refineAutoSelectFilter(value.id) then
			isPass = true
		end

		if not isPass then
			for num = value.selectedCount + 1, value.count do
				if nowExp < nextExp then
					value.selectedCount = num
					nowExp = nowExp + self:getRefinePieceExp(value.id)
				end
				if nowExp >= nextExp then
					break
				end
			end
		end
	end
	return itemList
end

-- 设置精炼的自动选择是否有过滤
function QGemstone:setRefineFilterEnable(isEnable)
	local value = QUserData.STRING_FALSE
	if isEnable then
		value = QUserData.STRING_TRUE
	end
	app:getUserData():setUserValueForKey(QGemstone.GEMSTONE_REFINE_ENABLE_FILTER, value)
end

-- 获取精炼的自动选择是否过滤
function QGemstone:getRefineFilterEnable()
	local isEnable = app:getUserData():getUserValueForKey(QGemstone.GEMSTONE_REFINE_ENABLE_FILTER) or QUserData.STRING_FALSE
	return isEnable == QUserData.STRING_TRUE
end

-- 魂骨精炼 给出选择列表，检查列表中是否有选中数据
function QGemstone:checkRefineSelectList(selectList)
	for _, value in ipairs(selectList) do
		if value.selectedCount > 0 then
			return true
		end
	end
	return false
end

--根据套装Id和套装件数获得当前套装效果
function QGemstone:getSuitEffctBySuitIdAndSuitNum(suitId, num)
	local suitInfo = QStaticDatabase:sharedDatabase():getGemstoneSuitEffectBySuitId(suitId)
	if suitInfo ~= nil then
		for _,config in ipairs(suitInfo) do
			if config.set_number == num then
				return config
			end
		end
	end
	return {}
end

-- 根据碎片ID找宝石合成的相关信息
function QGemstone:getStoneCraftInfoByPieceId(pieceId)
	if pieceId == nil then return nil end

	local crafts = remote.items:getItemsByMaterialId(pieceId)
	if crafts ~= nil then
		return crafts[1]
	end
  	-- local itemCraftInfo = QStaticDatabase:sharedDatabase():getItemCraft()
  	-- if itemCraftInfo == nil then return nil end

  	-- for _, value in pairs(itemCraftInfo) do
  	-- 	if value.component_id_1 == pieceId then
  	-- 		return value
  	-- 	end
  	-- end
  	return nil
end

-- 检查宝石背包小红点
function QGemstone:checkBackPackTips()
	if app.unlock:getUnlockGemStone() == false then
		return false
	end

	if self:checkPieceRedTip() then 
		return true
	end
	if self:checkMaterialRedTip() then 
		return true
	end

	return false
end

function QGemstone:checkPieceRedTip()
	local pieceInfo = QStaticDatabase:sharedDatabase():getItemsByProp("type", ITEM_CONFIG_TYPE.GEMSTONE_PIECE)
	for i = 1, #pieceInfo do
		local stoneInfo = self:getStoneCraftInfoByPieceId(pieceInfo[i].id)
		local haveCount = remote.items:getItemsNumByID(pieceInfo[i].id)
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(pieceInfo[i].id)
		if haveCount >= (stoneInfo.component_num_1 or 0) and remote.user.money > stoneInfo.price and itemInfo.appear_1 ~= false then
			return true
		end
	end
	return false
end

function QGemstone:checkMaterialRedTip()
	if remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.GEMSTONE_MATERIAL) then
		return true
	end
	return false
end

--xurui: 检查宝石背包里面是否有物品
function QGemstone:checkGemstoneBackPackItemNum()
	-- 检查宝石碎片和宝石消耗品
	local items = QStaticDatabase:sharedDatabase():getItemsByCategory(ITEM_CONFIG_CATEGORY.GEMSTONE_PIECE, ITEM_CONFIG_CATEGORY.GEMSTONE_MATERIAL)
	for _, value in pairs(items) do
		if remote.items:getItemsNumByID(value.id) > 0 then
			return true
		end
	end
	--检查宝石
	local gemstoneInfo = self:getGemstones()
	if next(gemstoneInfo) ~= nil then
		return true
	end

	return false
end

--获取已经拥有暗器的ID组合
function QGemstone:getHeros(selectId)
    local herosID = remote.herosUtil:getHaveHero()
    local heros = {}
    local selectPos = 1
    for _,actorId in ipairs(herosID) do
        local heroInfo = remote.herosUtil:getHeroByID(actorId)
        if heroInfo.gemstones ~= nil then
            table.insert(heros, actorId)
            if actorId == selectId then
                selectPos = #heros
            end
        end
    end
    return heros,selectPos
end

--------------------------------------通讯协议部分--------------------------------------



function QGemstone:responseHandler(data, success, fail, succeeded)
	
	if data.gemstones ~= nil then
		self:setGemstones(data.gemstones)
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



function QGemstone:setGemstones(gemstones,isHeroUpdate)
	for _,gemstone in ipairs(gemstones) do
		if self._gemstonesMap[gemstone.sid] == nil then
			table.insert(self._gemstones, gemstone)
			self._gemstonesMap[gemstone.sid] = gemstone
			gemstone.isNew = true
		else
			local _gemstone = self._gemstonesMap[gemstone.sid]
			for key,value in pairs(gemstone) do
				_gemstone[key] = value
			end
			_gemstone.isNew = true
		end
	end
	self:_countProp()
    self:dispatchEvent({name = QGemstone.EVENT_UPDATE})
    if not isHeroUpdate then
		self:_checkChangeGemstoneSSP()
    end

end

--删除指定的宝石 
function QGemstone:removeGemstones(sid)
	self._gemstonesMap[sid] = nil
	for index,gemstone in ipairs(self._gemstones) do
		if gemstone.sid == sid then
			table.remove(self._gemstones, index)
		end
	end
    self:dispatchEvent({name = QGemstone.EVENT_UPDATE})
end

function QGemstone:removeGemstonesByList(sidList)
	for _, sid in ipairs(sidList) do
		self._gemstonesMap[sid] = nil
		for index,gemstone in ipairs(self._gemstones) do
			if gemstone.sid == sid then
				table.remove(self._gemstones, index)
			end
		end
	end
    self:dispatchEvent({name = QGemstone.EVENT_UPDATE})
end

function QGemstone:_checkChangeGemstoneSSP()
	local gemstoneList = self:getTopSspGemstoneList()
	local extraProp = app.extraProp:getSelfExtraProp() or {}
	local bRefrehs = not q.isEmpty(gemstoneList)  or (q.isEmpty(gemstoneList) and not q.isEmpty(extraProp) 
		and extraProp[app.extraProp.GEMSTONE_SSP_PROP] and not q.isEmpty(extraProp[app.extraProp.GEMSTONE_SSP_PROP]))
	if bRefrehs then
    	self:dispatchEvent({name = QGemstone.EVENT_EXTRAPROP_UPDATE , gemstoneList = gemstoneList})
    	self:dispatchEvent({name = QGemstone.EVENT_SSPLUS_UPDATE })		
	end
end

function QGemstone:getTopSspGemstoneList()
	if q.isEmpty(self._gemstones) then
		return {}
	end
	local gemstoneList = {}
	local gemstoneTypeList = {}
	gemstoneTypeList[1]={}
	gemstoneTypeList[2]={}
	gemstoneTypeList[3]={}
	gemstoneTypeList[4]={}

	for _, gemstone in pairs(self._gemstones) do
		if gemstone.mix_level and gemstone.mix_level >= 1 then
		local gemstoneConfig = db:getItemByID(gemstone.itemId)
			if gemstoneConfig then
				local typeIdx = tonumber(gemstoneConfig.gemstone_type)
				table.insert(gemstoneTypeList[typeIdx], gemstone)
			end
		end
	end
	local index = 0
	local maxNum = 16	--左右魂骨最多取

	for i,gemstoneValue in ipairs(gemstoneTypeList) do
		table.sort(gemstoneValue,function(a, b) 
			if a.mix_level ~= b.mix_level then
				return a.mix_level > b.mix_level 
			elseif a.refine_level ~= b.refine_level then
				return a.refine_level > b.refine_level 
			else
				return a.itemId < b.itemId 
			end
			end)	
		index = 0
		for ii,gemstone in ipairs(gemstoneValue) do
			if index >= maxNum then
				break
			end
			local lastNum = maxNum - index
			table.insert(gemstoneList, {itemId = gemstone.itemId , mix_level = gemstone.mix_level, refine_level = gemstone.refine_level})
			index = index + 1
		end
	end

	return gemstoneList
end


-- 请求宝石信息
function QGemstone:getGemstoneRequest(success, fail)
    local request = {api = "GEMSTONE_GET"}
    app:getClient():requestPackageHandler("GEMSTONE_GET", request, function (response)
        self:getGemstoneResponse(response, success, nil, true)
    end, function (response)
        self:getGemstoneResponse(response, nil, fail)
    end)
end

-- 返回宝石信息
function QGemstone:getGemstoneResponse(data, success, fail, succeeded)
	-- if data.gemstoneGetResponse ~= nil then
	-- 	local gemstones = data.gemstoneGetResponse.gemstones
	-- 	if gemstones ~= nil then 
	-- 		for _,gemstone in ipairs(gemstones) do
	-- 			table.insert(self._gemstones, gemstone)
	-- 		end
	-- 	end
	-- end
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
	@title 请求强化
	@param sid 要强化的物品
	@param targetLevel 要强化后的等级
]]
function QGemstone:gemstoneEnhanceRequest(sid, targetLevel, success, fail)
	local gemstoneEnhanceRequest = {sid = sid, targetLevel = targetLevel}
    local request = {api = "GEMSTONE_ENCHANCE", gemstoneEnhanceRequest = gemstoneEnhanceRequest}
    app:getClient():requestPackageHandler("GEMSTONE_ENCHANCE", request, function (response)
        self:gemstoneEnhanceResponse(response, success, nil, true)
    end, function (response)
        self:gemstoneEnhanceResponse(response, nil, fail)
    end)
end

function QGemstone:gemstoneOneKeyEnhanceRequest( actorId,isTop,success,fail)
	local gemstoneOneKeyEnhanceRequest = {isTop = isTop,actorId = actorId}
	local request = {api = "GEMSTONE_ONE_KEY_ENHANCE", gemstoneOneKeyEnhanceRequest = gemstoneOneKeyEnhanceRequest}
	app:getClient():requestPackageHandler("GEMSTONE_ONE_KEY_ENHANCE", request, function (response)
        self:gemstoneEnhanceResponse(response, success, nil, true)
    end, function (response)
        self:gemstoneEnhanceResponse(response, nil, fail)
    end)
end
--[[
	请求强化返回
]]
function QGemstone:gemstoneEnhanceResponse(data, success, fail, succeeded)
	if data.gemstoneEnhanceResponse ~= nil then
		
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
	@title 请求突破
	@param sid 要突破的物品
]]
function QGemstone:gemstoneCraftRequest(sid, success, fail)
	local gemstoneCraftRequest = {sid = sid}
    local request = {api = "GEMSTONE_CRAFT", gemstoneCraftRequest = gemstoneCraftRequest}
    app:getClient():requestPackageHandler("GEMSTONE_CRAFT", request, function (response)
        self:gemstoneCraftResponse(response, success, nil, true)
    end, function (response)
        self:gemstoneCraftResponse(response, nil, fail)
    end)
end

--[[
	@title 请求一键突破
	@param sid 要突破的物品
]]
function QGemstone:gemstoneOneKeyCraftRequest(actorId, isTop, success, fail)
	local gemstoneOneKeyCraftRequest = {actorId = actorId, isTop = isTop}
    local request = {api = "GEMSTONE_ONE_KEY_CRAFT", gemstoneOneKeyCraftRequest = gemstoneOneKeyCraftRequest}
    app:getClient():requestPackageHandler("GEMSTONE_ONE_KEY_CRAFT", request, function (response)
        self:gemstoneCraftResponse(response, success, nil, true)
    end, function (response)
        self:gemstoneCraftResponse(response, nil, fail)
    end)
end

--[[
	请求突破返回
]]
function QGemstone:gemstoneCraftResponse(data, success, fail, succeeded)
	if data.gemstoneCraftResponse ~= nil then
		
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
	@title 请求合成
	@param sid 要合成的物品碎片
]]
function QGemstone:gemstoneComposeRequest(sid, success, fail)
	local gemstoneComposeRequest = {itemId = sid}
    local request = {api = "GEMSTONE_COMPOSE", gemstoneComposeRequest = gemstoneComposeRequest}
    app:getClient():requestPackageHandler("GEMSTONE_COMPOSE", request, function (response)
        self:gemstoneComposeResponse(response, success, nil, true)
    end, function (response)
        self:gemstoneComposeResponse(response, nil, fail)
    end)
end

--[[
	请求合成返回
]]
function QGemstone:gemstoneComposeResponse(data, success, fail, succeeded)
	if data.gemstones ~= nil then
		self:setGemstones(data.gemstones)
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
	@title 请求装备
    optional string sid = 1;                                                  //宝石ID
    optional int32 type = 2;                                                  // 类型（1安装，2拆卸）
    optional int32 actorId = 3;                                               //魂师ID（安装需要）
    optional int32 position = 4;                                              //位置 （安装需要）
]]
function QGemstone:gemstoneLoadRequest(sid, type, actorId, position, success, fail)
	local gemstoneLoadRequest = {sid = sid, type = type, actorId = actorId, position = position}
    local request = {api = "GEMSTONE_LOAD", gemstoneLoadRequest = gemstoneLoadRequest}
    app:getClient():requestPackageHandler("GEMSTONE_LOAD", request, function (response)
        self:gemstoneLoadResponse(response, function (data)
			if success ~= nil then
				success(data)
			end
        end, nil, true)
    end, function (response)
        self:gemstoneLoadResponse(response, nil, fail)
    end)
end

--[[
	请求装备返回
]]
function QGemstone:gemstoneLoadResponse(data, success, fail, succeeded)
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
/**
 * 宝石进阶
 */
message GemstoneAdvanceRequest {
    optional string sid = 1;                                                      // 要进阶的物品
    optional int32 targetLevel = 2; // 一键强化到多少级
}
]]
-- @targetLevel 缺省时，默认升一级
function QGemstone:gemstoneToGodAndAdvanced(sid, targetLevel,success, fail)
	local gemstoneAdvanceRequest = {sid = sid, targetLevel = targetLevel}
	local request = {api = "GEMSTONE_ADVANCE", gemstoneAdvanceRequest = gemstoneAdvanceRequest}
	app:getClient():requestPackageHandler("GEMSTONE_ADVANCE",request,function(response)
		if success ~= nil then
			success(response)
		end
	end,function(response)
		if fail ~= nil then
			fail(response)
		end
	end)
end


function QGemstone:gemstoneQuickExchange(actorId, gemstoneIds, sparIds, success, fail)
	local gemstoneOneKeyLoadRequest = {actorId = actorId, gemstoneIds = gemstoneIds, sparIds = sparIds}
	local request = {api = "GEMSTONE_ONE_KEY_LOAD", gemstoneOneKeyLoadRequest = gemstoneOneKeyLoadRequest}
	app:getClient():requestPackageHandler("GEMSTONE_ONE_KEY_LOAD",request,function(response)
		if success ~= nil then
			success(response)
		end
	end,function(response)
		if fail ~= nil then
			fail(response)
		end
	end)
end


--[[
//宝石融合
message GemstoneMixRequest {
    optional int32 count = 1; //        要消耗的精神本源数量
    optional string sid = 2; // 要融合的宝石ID
}
]]
function QGemstone:gemstoneMixRequest(count , sid , success, fail)
	local gemstoneMixRequest = {count = count, sid = sid}
	local request = {api = "GEMSTONE_MIX", gemstoneMixRequest = gemstoneMixRequest}
	app:getClient():requestPackageHandler("GEMSTONE_MIX",request,function(response)
		self:responseHandler(response, success, nil, true)
	end,function(response)
		self:responseHandler(response, nil, fail, nil)
	end)
end

--[[
//宝石融合一键拆下
message GemstoneCancelMixRequest {
    optional string sid = 1;                                                   //宝石ID
}
]]
function QGemstone:gemstoneCancelMixRequest(sid , success, fail)
	local gemstoneCancelMixRequest = { sid = sid}
	local request = {api = "GEMSTONE_CANCEL_MIX", gemstoneCancelMixRequest = gemstoneCancelMixRequest}
	app:getClient():requestPackageHandler("GEMSTONE_CANCEL_MIX",request,function(response)
		self:responseHandler(response, success, nil, true)
	end,function(response)
		self:responseHandler(response, nil, fail, nil)
	end)
end



--[[
	@title 请求精炼
	@param sid 魂骨sid
	@param consumeItems	消耗的魂骨碎片列表
]]
function QGemstone:gemstoneRefineRequest(sid, consumeItems, success, fail)
	local params = {sid = sid, consumeItems = consumeItems}
	local request = {api = "GEMSTONE_REFINE", gemstoneRefineRequest = params}
    app:getClient():requestPackageHandler("GEMSTONE_REFINE", request, function (response)
        self:gemstoneRefineResponse(response, success, nil, true)
    end, function (response)
        self:gemstoneRefineResponse(response, nil, fail)
	end)
end

--[[
	@title 请求精炼摘除
	@param sid 魂骨sid
]]
function QGemstone:gemstoneCancelRefineRequest(sid, success, fail)
	local params = {sid = sid}
    local request = {api = "GEMSTONE_CANCEL_REFINE", gemstoneCancelRefineRequest = params}
	app:getClient():requestPackageHandler("GEMSTONE_CANCEL_REFINE", request, function (response)
        self:gemstoneRefineResponse(sid, response, success, nil, true)
    end, function (response)
        self:gemstoneRefineResponse(sid, response, nil, fail)
	end)
end

--[[
	请求精炼返回
]]
function QGemstone:gemstoneRefineResponse(sid, data, success, fail, succeeded)
	if data.gemstones ~= nil then
		self:setGemstones(data.gemstones)
		self:getRefineHistoryExp(sid, true)	-- 更新历史经验
	end

	if succeeded == true then
		if success ~= nil then
			-- 更新钱包和道具
			local wallet = {}
			wallet.money = data.money
			wallet.token = data.token
			remote.user:update( wallet )
			if data.items then 
				remote.items:setItems(data.items) 
			end
			success(data)
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		end
	else
		if fail ~= nil then
			fail(data)
		end
	end
end

function QGemstone:gemReborn(sid , success, fail)
    local gemstoneReturnRequest = {sid = sid}
    local request = {api = "GEMSTONE_RETURN", gemstoneReturnRequest = gemstoneReturnRequest}
	app:getClient():requestPackageHandler("GEMSTONE_RETURN",request,function(response)
		self:responseHandler(response, success, nil, true)
	end,function(response)
		self:responseHandler(response, nil, fail, nil)
	end)

end



function QGemstone:gemRecycle(sid , success, fail)
    local gemstoneRecoverRequest = {sid = sid}
    local request = {api = "GEMSTONE_RECOVER", gemstoneRecoverRequest = gemstoneRecoverRequest}
	app:getClient():requestPackageHandler("GEMSTONE_RECOVER",request,function(response)
		self:responseHandler(response, success, nil, true)
	end,function(response)
		self:responseHandler(response, nil, fail, nil)
	end)
end

-- optional string  gemstoneId = 1;                                                    // 魂骨ID
function QGemstone:gemstoneReturnGodLevelRequest(gemstoneId, success, fail)
    local gemstoneReturnGodLevelRequest = {gemstoneId = gemstoneId}
    local request = {api = "GEMSTONE_RETURN_GOD_LEVEL", gemstoneReturnGodLevelRequest = gemstoneReturnGodLevelRequest}
	app:getClient():requestPackageHandler("GEMSTONE_RETURN_GOD_LEVEL",request,function(response)
		self:responseHandler(response, success, nil, true)
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	end,function(response)
		self:responseHandler(response, nil, fail, nil)
	end)
end

return QGemstone
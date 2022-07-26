pvp = {}

local function addInstTable(pack, tableName, isFilter)
	if pvp[tableName] then
		pvp[tableName] = nil
	end
	if pack.msgdata.message[tableName] and pack.msgdata.message[tableName].message then
		pvp[tableName] = pack.msgdata.message[tableName].message
	end
	if isFilter then
		if pvp[tableName] then
			local _tempData = nil 
	    for key, obj in pairs(pvp[tableName]) do 
	      _tempData = obj
	    end
	    pvp[tableName] = _tempData
    end
	end
end

function pvp.loadGameData(pack)
	pvp.InstPlayer = pack.msgdata.message.InstPlayer
	addInstTable(pack, "InstPlayerCard")
	addInstTable(pack, "InstPlayerFormation")
	addInstTable(pack, "InstPlayerEquip")
	addInstTable(pack, "InstPlayerLineup")
	--addInstTable(pack, "InstPlayerPartner")
	addInstTable(pack, "InstPlayerTrain")
	addInstTable(pack, "InstPlayerWash")
	addInstTable(pack, "InstPlayerMagic")
	addInstTable(pack, "InstPlayerConstell")
	addInstTable(pack, "InstEquipGem")
	addInstTable(pack, "InstPlayerFire")
	addInstTable(pack, "InstPlayerManualSkill")
	addInstTable(pack, "InstPlayerManualSkillLine",true)
    addInstTable(pack,"InstPlayerFightSoul")
    addInstTable(pack, "InstPlayerYFire")
    addInstTable(pack,"InstPlayerWing")
    addInstTable(pack,"InstUnionPractice",true)
	addInstTable(pack, "InstPlayerEquipBox")
    addInstTable(pack, "InstPlayerEnchantment" , true)
end
--- 判断卡牌缘分 3v3（返回true缘分点亮，否则未点亮）
-- @dictCardLuck : 卡牌缘分字典数据
-- @_instFormationId : 阵型实例ID
-- @isFilterFriend : 是否过滤小伙伴
function pvp.isCardLuck3v3(dictCardLuck, _instFormationId, isFilterFriend ,team )
    local function inTeam( instId )
        for key ,value in pairs( team ) do
            if tonumber( value ) == instId then
                return true
            end
        end
        return false
    end
    local _isLuck = false
    local lucks = utils.stringSplit(dictCardLuck.lucks, ";")
    if lucks and #lucks > 0 then
        local _luckFlags = { }
        for key, obj in pairs(lucks) do
            _luckFlags[key] = false
            local temp = utils.stringSplit(obj, "_")
            local tableTypeId, tableFieldId = tonumber(temp[1]), tonumber(temp[2])
            if tableTypeId == StaticTableType.DictCard then
                for k, ipf in pairs(pvp.InstPlayerFormation) do
                    if inTeam( tonumber( ipf.int[ "3" ] ) ) and ( ipf.int["4"] == 1 or ipf.int["4"] == 2 ) then
                        if tableFieldId == ipf.int["6"] then
                            -- cardId,卡牌字典Id
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
                if not isFilterFriend and pvp.InstPlayerFormation then
                    for k, ipp in pairs(pvp.InstPlayerFormation) do
                        if inTeam( tonumber( ipp.int[ "3" ] ) ) and ipp.int["4"] == 3 then
                            if tableFieldId == ipp.int["6"] then
                                -- cardId,卡牌字典Id
                                _luckFlags[key] = true
                                break
                            end
                        end
                    end
                end
            elseif tableTypeId == StaticTableType.DictMagic then
                if pvp.InstPlayerMagic and _instFormationId then
                    for k, ipm in pairs(pvp.InstPlayerMagic) do
                        -------------------------------------------instCardId,卡牌实例Id-----------------------------------------法宝功法Id
                        if pvp.InstPlayerFormation[tostring(_instFormationId)].int["3"] == ipm.int["8"] and tableFieldId == ipm.int["3"] then
                            _luckFlags[key] = true
                            break
                        end
                    end
                end
            end
        end
        _isLuck = true
        for key, obj in pairs(_luckFlags) do
            if not obj then
                _isLuck = false
                break
            end
        end
    end
    return _isLuck
end
---判断卡牌缘分（返回true缘分点亮，否则未点亮）
--@dictCardLuck : 卡牌缘分字典数据
--@_instFormationId : 阵型实例ID
--@isFilterFriend : 是否过滤小伙伴
function pvp.isCardLuck(dictCardLuck, _instFormationId, isFilterFriend)
	local _isLuck = false
	local lucks = utils.stringSplit(dictCardLuck.lucks, ";")
	if lucks and #lucks > 0 then
		local _luckFlags = {}
		for key, obj in pairs(lucks) do
			_luckFlags[key] = false
			local temp = utils.stringSplit(obj, "_")
			local tableTypeId, tableFieldId = tonumber(temp[1]), tonumber(temp[2])
			if tableTypeId == StaticTableType.DictCard then
				for k, ipf in pairs(pvp.InstPlayerFormation) do
                    if ipf.int["4"] == 1 or ipf.int["4"] == 2 then
					    if tableFieldId == ipf.int["6"] then
						    _luckFlags[key] = true
						    break
					    end
                    end
				end
				if not isFilterFriend and pvp.InstPlayerFormation then
					for k, ipp in pairs(pvp.InstPlayerFormation) do
                        if ipp.int["4"] == 3 then
						    if tableFieldId == ipp.int["6"] then
							    _luckFlags[key] = true
							    break
						    end
                        end
					end
				end
			elseif tableTypeId == StaticTableType.DictMagic then
				if pvp.InstPlayerMagic and _instFormationId then
					for k, ipm in pairs(pvp.InstPlayerMagic) do
						if pvp.InstPlayerFormation[tostring(_instFormationId)].int["3"] == ipm.int["8"] and tableFieldId == ipm.int["3"] then
							_luckFlags[key] = true
							break
						end
					end
				end
			end
		end
		_isLuck = true
		for key, obj in pairs(_luckFlags) do
			if not obj then
				_isLuck = false
				break
			end
		end
	end
	return _isLuck

--[[
	if dictCardLuck.tableTypeId == StaticTableType.DictCard then
		for k, ipf in pairs(pvp.InstPlayerFormation) do
			if dictCardLuck.tableFieldId == ipf.int["6"] then
				return true
			end
		end
		if not isFilterFriend and pvp.InstPlayerPartner then
			for k, ipp in pairs(pvp.InstPlayerPartner) do
				if dictCardLuck.tableFieldId == ipp.int["4"] then
					return true
				end
			end
		end
	elseif dictCardLuck.tableTypeId == StaticTableType.DictMagic then
		if pvp.InstPlayerMagic then
			for k, ipm in pairs(pvp.InstPlayerMagic) do
				if pvp.InstPlayerFormation[tostring(_instFormationId)].int["3"] == ipm.int["8"] and dictCardLuck.tableFieldId == ipm.int["3"] then
					return true
				end
			end
		end
	elseif dictCardLuck.tableTypeId == StaticTableType.DictEquipment then
		if pvp.InstPlayerLineup then
			for k, ipl in pairs(pvp.InstPlayerLineup) do
				if _instFormationId == ipl.int["3"] and dictCardLuck.tableFieldId == pvp.InstPlayerEquip[tostring(ipl.int["5"])].int["4"] then
					return true
				end
			end
		end
	end
--]]
end

---获取装备洗练属性
--@instEquipId : 装备实例ID
local function getEquipWashAttribute(instEquipId)
	local attribute = {}
	for key, obj in pairs(DictFightProp) do
		attribute[obj.id] = 0
	end
	if pvp.InstPlayerEquip and instEquipId then
		if pvp.InstPlayerWash then
			local washIndex, washCount = 0, 4 --最大洗练个数
			for key, obj in pairs(pvp.InstPlayerWash) do
				local instWashEquipId = obj.int["3"] --装备实例ID
				if instEquipId == instWashEquipId then
					local fightPropId = obj.int["4"] --战斗属性ID
					local equipWashId = obj.int["5"] --洗练字典ID
					local dictDquipWashData = DictEquipWash[tostring(equipWashId)]
					attribute[fightPropId] = attribute[fightPropId] + dictDquipWashData.value
					washIndex = washIndex + 1
					if washIndex >= washCount then
						break
					end
				end
			end
		end
	end
	return attribute
end

---获取装备镶嵌宝石属性
--@instEquipId : 装备实例ID
local function getEquipGemAttribute(instEquipId)
	local attribute = {}
	for key, obj in pairs(DictFightProp) do
		attribute[obj.id] = 0
	end
	if pvp.InstPlayerEquip and instEquipId then
		local instEquipData = pvp.InstPlayerEquip[tostring(instEquipId)]
		local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])] --装备字典表
		local dictEquipQualityData = DictEquipQuality[tostring(dictEquipData.equipQualityId)] --装备品质字典表
		local holeNum = dictEquipQualityData.holeNum --拥有宝石孔数
		local geamIndex = 0
		if pvp.InstEquipGem then
			for key, obj in pairs(pvp.InstEquipGem) do
				if instEquipId == obj.int["3"] then
					local _thingId = obj.int["4"] --物品Id 0表示未镶嵌宝石
					if _thingId > 0 then
						local dictThingData = DictThing[tostring(_thingId)]
						attribute[dictThingData.fightPropId] = attribute[dictThingData.fightPropId] + dictThingData.fightPropValue
					end
					geamIndex = geamIndex + 1
					if geamIndex >= holeNum then
						break
					end
				end
			end
		end
	end
	return attribute
end

local isInSuit = { }
--- 获取装备套装属性(返回的是一组table属性值,table下标就是属性ID)
-- @instEquipId : 装备实例ID

function pvp.getEquipSuitAttribute(_instFormationId, _instEquipId, isPvp)
    local attribute = { }
    for key, obj in pairs(DictFightProp) do
        attribute[obj.id] = 0
    end
    if pvp.InstPlayerEquip and _instEquipId then
        local suitEquipData , suitEquipRedData = utils.getEquipSuit(tostring(pvp.InstPlayerEquip[tostring(_instEquipId)].int["4"]))
        if not suitEquipData then
            -- cclog("utils 此物品无套装")
            return { }
        end
        local suitEquipTable = utils.stringSplit(suitEquipData.suitEquipIdList, ";")
        local curSuitEquipData = { 0, 0, 0, 0 }

        local suitCount = 0
        local suitStarLvl = 5
		local suitRedStarLvl = 5
        function addSuitCountAndStarLvl(equipId, isSuitEquip, starLvl, index)
            if _instEquipId ~= equipId and isSuitEquip then
                suitCount = suitCount + 1
                table.insert(isInSuit, equipId)
            end
			
            local instEquipData = pvp.InstPlayerEquip[tostring(equipId)]
            local _equipAdvanceId = instEquipData.int["8"]
			local tempLvl = starLvl
			if _equipAdvanceId and _equipAdvanceId > 0 then
				local dictEquipAdvanceData = _equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(_equipAdvanceId)] or DictEquipAdvance[tostring(_equipAdvanceId)]
				if dictEquipAdvanceData.equipQualityId == StaticEquip_Quality.golden then
					if suitRedStarLvl > tempLvl then
						suitRedStarLvl = tempLvl
					end
					tempLvl = 5
				else
					suitRedStarLvl = -1
				end
			else
				suitRedStarLvl = -1
			end
            if tempLvl < suitStarLvl then
                suitStarLvl = tempLvl
            end
        end
        local count = 0
        for key, obj in pairs(pvp.InstPlayerLineup) do
            if _instFormationId and tonumber(_instFormationId) == tonumber(obj.int["3"]) then
                local equipTypeId = obj.int["4"]
                -- 装备类型Id
                local instEquipId = obj.int["5"]
                -- 装备实例Id
                local instEquipData = pvp.InstPlayerEquip[tostring(instEquipId)]
                -- 装备实例数据
                local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
                -- 装备字典数据
                local equipLevel = instEquipData.int["5"]
                -- 装备等级
                local qualityImage = utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small)
                local qualitySuperscriptImg = utils.getEquipQualitySuperscript(dictEquipData.equipQualityId)
                local equipStarLvl = 0
                local equipAdvanceId = instEquipData.int["8"]
                if equipAdvanceId and tonumber(equipAdvanceId) > 0 then
                    local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
                    -- 装备进阶字典表
                    equipStarLvl = dictEquipAdvanceData.starLevel
                end

                if equipTypeId == StaticEquip_Type.outerwear then
                    -- 护甲
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[2]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[2] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 2)
                elseif equipTypeId == StaticEquip_Type.pants then
                    -- 头盔
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[3]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[3] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 3)
                elseif equipTypeId == StaticEquip_Type.necklace then
                    -- 饰品
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[4]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[4] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 4)
                elseif equipTypeId == StaticEquip_Type.equip then
                    -- 武器
                    local isSuit = false
                    if tonumber(dictEquipData.id) ~= tonumber(suitEquipTable[1]) then
                        isSuit = false
                    else
                        isSuit = true
                        curSuitEquipData[1] = instEquipId
                    end
                    count = count + 1
                    addSuitCountAndStarLvl(instEquipId, isSuit, equipStarLvl, 1)
                end
                if count >= 4 then
                    break
                end
            end
        end
        --     cclog("utils suitCount : "..suitCount .. " suitStarLvl :"..suitStarLvl)
        local function getAddProp(propId, data)
            local propAdd = 0
            local baseProp = 0
            local tempAttr = { }
            if propId == 1 then
                -- 首饰

                if curSuitEquipData[4] == 0 then
                    return 0
                end
                tempAttr = pvp.getEquipAttribute(curSuitEquipData[4])
            elseif propId == 2 or propId == 3 then
                -- 武器

                if curSuitEquipData[1] == 0 then
                    return 0
                end
                tempAttr = pvp.getEquipAttribute(curSuitEquipData[1])
            elseif propId == 8 then
                -- 护甲

                if curSuitEquipData[2] == 0 then
                    return 0
                end
                tempAttr = pvp.getEquipAttribute(curSuitEquipData[2])
            elseif propId == 9 then
                -- 头盔

                if curSuitEquipData[3] == 0 then
                    return 0
                end
                tempAttr = pvp.getEquipAttribute(curSuitEquipData[3])
            end
            baseProp = tempAttr[propId]
            propAdd = baseProp * data
            return propAdd
        end
        for i = 2, 4 do
            local propStr = nil
            if i == 2 then
                propStr = suitEquipData.suit2NumProp
            elseif i == 3 then
                propStr = suitEquipData.suit3NumProp
            elseif i == 4 then
                propStr = suitEquipData.suit4NumProp
            end
            if i < 2 + suitCount then
                local propTable = utils.stringSplit(propStr, ";")
                for key, value in pairs(propTable) do
                    local data = utils.stringSplit(value, "_")
                    if tonumber(data[2]) < 1 then
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + math.floor(getAddProp(tonumber(data[1]), tonumber(data[2])))
                    else
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2])
                    end
                end
            end
        end
        for i = 1, 5 do
            local propStr = nil
            if i == 1 then
                propStr = suitEquipData.suit1StarProp
            elseif i == 2 then
                propStr = suitEquipData.suit2StarProp
            elseif i == 3 then
                propStr = suitEquipData.suit3StarProp
            elseif i == 4 then
                propStr = suitEquipData.suit4StarProp
            elseif i == 5 then
                propStr = suitEquipData.suit5StarProp
            end
            if suitCount >= 3 and i <= suitStarLvl then
                local propTable = utils.stringSplit(propStr, ";")
                for key, value in pairs(propTable) do
                    local data = utils.stringSplit(value, "_")
                    if tonumber(data[2]) < 1 then
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + math.floor(getAddProp(tonumber(data[1]), tonumber(data[2])))
                    else
                        -- cclog( "data[2] : "..data[ 2 ])
                        attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2])
                    end
                end
            end
        end
        if suitEquipRedData then
		    for i = 1 , 6 do
			    local propStr = suitEquipRedData[string.format("Redsuit%dStarProp", i - 1)]
--                if i == 1 then
--                    propStr = suitEquipRedData.suit0StarProp
--                elseif i == 2 then
--                    propStr = suitEquipRedData.suit1StarProp
--                elseif i == 3 then
--                    propStr = suitEquipRedData.suit2StarProp
--                elseif i == 4 then
--                    propStr = suitEquipRedData.suit3StarProp
--                elseif i == 5 then
--                    propStr = suitEquipRedData.suit4StarProp
--			    elseif i == 6 then
--				    propStr = suitEquipRedData.suit5StarProp
--                end
                if suitCount >= 3 and 5 <= suitStarLvl and i - 1 <= suitRedStarLvl then
                    local propTable = utils.stringSplit(propStr, ";")
                    for key, value in pairs(propTable) do
                        local data = utils.stringSplit(value, "_")
                        if tonumber(data[2]) < 1 then
                            attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + math.floor(getAddProp(tonumber(data[1]), tonumber(data[2])))
                        else
                            -- cclog( "data[2] : "..data[ 2 ])
                            attribute[tonumber(data[1])] = attribute[tonumber(data[1])] + tonumber(data[2])
                        end
                    end
                end
		    end
        end
    end
    return attribute
end

--获取器匣加成属性百分比值
function pvp.getQixiaAddPropPerValue(_instFormationId, _equipTypeId)
    local _ipebAddPropPer = 0
    if pvp.InstPlayerEquipBox then
        local _ipebInstData = nil
        for _ipebKey, _ipebObj in pairs(pvp.InstPlayerEquipBox) do
            if _instFormationId == _ipebObj.int["3"] then
                if _equipTypeId == StaticEquip_Type.equip then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["4"], ";")
                elseif _equipTypeId == StaticEquip_Type.outerwear then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["5"], ";")
                elseif _equipTypeId == StaticEquip_Type.pants then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["6"], ";")
                elseif _equipTypeId == StaticEquip_Type.necklace then
                    _ipebInstData = utils.stringSplit(_ipebObj.string["7"], ";")
                end
                break
            end
        end
        if _ipebInstData and #_ipebInstData > 0 then
            for _iii, _ooo in pairs(_ipebInstData) do
                local _tempOOO = utils.stringSplit(_ooo, "_")
                local _lvId = _tempOOO[1]
                local _state = tonumber(_tempOOO[2]) --0可精炼 1普通 2优良 3完美
                if _state > 0 then
                    if _state == 1 then
                        _ipebAddPropPer = _ipebAddPropPer + DictEquipBox[_lvId].goodAdd
                    elseif _state == 2 then
                        _ipebAddPropPer = _ipebAddPropPer + DictEquipBox[_lvId].betterAdd
                    elseif _state == 3 then
                        _ipebAddPropPer = _ipebAddPropPer + DictEquipBox[_lvId].bestAdd
                    end
                end
            end
        end
    end
    return _ipebAddPropPer
end

---获取装备属性(返回的是一组table属性值,table下标就是属性ID)
--@instEquipId : 装备实例ID
function pvp.getEquipAttribute(instEquipId, isFilter)
	local attribute = {}
	for key, obj in pairs(DictFightProp) do
		attribute[obj.id] = 0
	end
	if pvp.InstPlayerEquip and instEquipId then
		local instEquipData = pvp.InstPlayerEquip[tostring(instEquipId)]
		local equipTypeId = instEquipData.int["3"] --装备类型ID
        local dictEquipId = instEquipData.int["4"] --装备字典ID
		local equipLv = instEquipData.int["5"] --装备等级
		local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID
		local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])] --装备字典表
		local equipPropData = {}
		local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
		for key, obj in pairs(propData) do
			equipPropData[key] = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:initValue, [3]:addValue
		end
		local attAddValue = 0
        -- 装备进阶
		for key, obj in pairs(DictEquipAdvance) do
			if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId and equipAdvanceId >= obj.id then
				attAddValue = attAddValue + obj.propAndAdd
			end
		end
        if equipAdvanceId and equipAdvanceId >= 1000 then --红装
            for key, obj in pairs(DictEquipAdvancered) do
                if dictEquipId == obj.equipId and DictEquipAdvancered[tostring(equipAdvanceId)].starLevel >= obj.starLevel then
                    attAddValue = attAddValue + obj.propAndAdd
                end
            end
        end
        --装备强化
		for key, obj in pairs(equipPropData) do
			local fightPropId, initValue,  addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
			attribute[fightPropId] = attribute[fightPropId] + formula.getEquipAttribute(equipLv, initValue, addValue + attAddValue)
		end
		
		if not isFilter then
			--[[
			local _washAttribute = getEquipWashAttribute(instEquipId)
			for _fightPropId, _value in pairs(_washAttribute) do
				attribute[_fightPropId] = attribute[_fightPropId] + _value
			end
			--]]
			local _gemAttribute = getEquipGemAttribute(instEquipId)
			for _fightPropId, _value in pairs(_gemAttribute) do
				attribute[_fightPropId] = attribute[_fightPropId] + _value
			end
		end
		
	end
	return attribute
end

---获取卡牌属性(返回的是一组table属性值,table下标就是属性ID)
--@instCardId : 卡牌实例ID
function pvp.getCardAttribute(instCardId , fightSoulValue , is3V3 , noFire , attr )
	local attribute = {}
	for key, obj in pairs(DictFightProp) do
		attribute[obj.id] = 0
	end
    local magicPercent = {}
	
	if instCardId and pvp.InstPlayerCard[tostring(instCardId)] then
		local instCardData = pvp.InstPlayerCard[tostring(instCardId)]
		local dictCardId = instCardData.int["3"] --卡牌字典ID
		local cardQualityId = instCardData.int["4"] --卡牌品阶ID
		local cardStarLevelId = instCardData.int["5"] --卡牌星级ID
		local cardTitleDetailId = instCardData.int["6"] --卡牌具体称号字典ID
		local cardLevel = instCardData.int["9"] --卡牌等级
		local inTeam = instCardData.int["10"] --是否在队伍中 0-不在 1-在
		local instGongFaId = instCardData.int["12"] --功法实例ID
		local instConstellsId = instCardData.string["13"] --命宫实例ID
        local trainDatas = instCardData.string["20"] --培养进度  格式：属性Id_数值;
		local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
		
		-------------基础属性数据（等级+卡边颜色）---------------
		attribute[StaticFightProp.blood] = formula.getCardBlood(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
		attribute[StaticFightProp.wAttack] = formula.getCardGasAttack(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
		attribute[StaticFightProp.wDefense] = formula.getCardGasDefense(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
		attribute[StaticFightProp.fAttack] = formula.getCardSoulAttack(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
		attribute[StaticFightProp.fDefense] = formula.getCardSoulDefense(cardLevel, cardQualityId, cardStarLevelId, dictCardData)
		attribute[StaticFightProp.dodge] = formula.getCardDodge(cardLevel, dictCardData)
		attribute[StaticFightProp.hit] = formula.getCardHit(cardLevel, dictCardData)
		attribute[StaticFightProp.crit] = formula.getCardCrit(cardLevel, dictCardData)
		attribute[StaticFightProp.flex] = formula.getCardTenacity(cardLevel, dictCardData)

		-------------称号属性数据---------------
		if cardTitleDetailId then
			for tddKey, tddObj in pairs(DictTitleDetail) do
				if cardTitleDetailId >= tddObj.id then
					local _tempData = utils.stringSplit(tddObj.effects, ";")
					for key, obj in pairs(_tempData) do
						local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
						local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
						attribute[_fightPropId] = attribute[_fightPropId] + _value
					end
                    if cardTitleDetailId ~= tddObj.id then
                        local _tempTrainData = utils.stringSplit(tddObj.train, ";")
                        for key, obj in pairs(_tempTrainData) do
                            local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [3]:value
                            local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[3])
				            attribute[_fightPropId] = attribute[_fightPropId] + _value
                        end
                    end
				end
			end
            local _trainDatas = utils.stringSplit(trainDatas, ";")
            for key, obj in pairs(_trainDatas) do
                local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
                local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
                attribute[_fightPropId] = attribute[_fightPropId] + _value
            end
		end
		
		if inTeam == 1 then
			local isFriend = 1 --是否是小伙伴 1是 0否

			for key, obj in pairs(pvp.InstPlayerFormation) do
				    local _instFormationId = obj.int["1"]
				    local _instCardId = obj.int["3"]
				    if instCardId == _instCardId then

                    if tonumber( obj.int[ "4" ] ) == 3 then
                        isFriend = 1
                    else
                        isFriend = 0
                    end
					-------------装备基础属性数据（不包括镶嵌宝石）---------------
					if pvp.InstPlayerLineup then
						local equipCount = 0
						for lineupKey, lineupObj in pairs(pvp.InstPlayerLineup) do
							if _instFormationId == lineupObj.int["3"] then
								equipCount = equipCount + 1
								local _instEquipId = lineupObj.int["5"]
								local tempAttribute = pvp.getEquipAttribute(_instEquipId, true)
                                -------------装备精炼属性数据（不包括镶嵌宝石）---------------
                                local _ipebAddPropPer = pvp.getQixiaAddPropPerValue(_instFormationId, lineupObj.int["4"])
                                -------------装备精炼属性数据（不包括镶嵌宝石）---------------
								for attKey, attObj in pairs(tempAttribute) do
									attribute[attKey] = attribute[attKey] + attObj * (1 + _ipebAddPropPer / 100)
								end
								if equipCount >= 4 then
									break
								end
							end
						end
					end            

                     ------------斗魂属性数据-------------------
                    if pvp.InstPlayerFightSoul then
                        for soulKey, soulValue in pairs(pvp.InstPlayerFightSoul) do
                            -- cclog("------------->".._instCardId .. "  ".._instFormationId.."  "..soulValue.int["7"] )
                            if soulValue.int["7"] == _instCardId then
                                local pro = nil
                                for key, value in pairs(DictFightSoulUpgradeProp) do
                                    if value.fightSoulId == soulValue.int["3"] and value.level == soulValue.int["5"] then
                                        pro = value
                                        break
                                    end
                                end
                                if pro then
                                    attribute[pro.fightPropId] = attribute[pro.fightPropId] + pro.fightPropValue
                                    if fightSoulValue then
                                        fightSoulValue = fightSoulValue + pro.fightValue
                                    end
                                end
                            end
                            --  cclog("<------------------")
                        end
                    end

                        if pvp.InstPlayerWing then
                            for wingKey , wingValue in pairs( pvp.InstPlayerWing ) do
                                if wingValue.int["6"] == _instCardId then
                                    local wingId = wingValue.int["3"]
                                    local level = wingValue.int["4"]
                                    local starNum = wingValue.int["5"]
                                    local pro = nil
                                    local thingData = nil
                                    for key , value in pairs( DictWingStrengthen ) do
                                        if value.wingId == wingId and value.level == level then
                                            thingData = value
                                            break
                                        end                                 
                                    end
                                    local advanceData = nil                              
                                    for key , value in pairs( DictWingAdvance ) do
                                        if value.wingId == wingId and value.starNum == starNum then
                                            advanceData = value
                                            break
                                        end                                   
                                    end
                                    local proShow = utils.stringSplit( advanceData.openFightPropIdList , ";" )
                                    local pro = utils.stringSplit( thingData.fightPropValueList , ";" )
                                    local function getShowValue( id )
                                        for key ,value in pairs ( pro ) do
                                            local data = utils.stringSplit( value , "_")
                                            if data[1] == id then
                                                return data[2]
                                            end
                                        end
                                        return 0
                                    end
                                    for key , value in pairs ( proShow ) do           
                                        attribute[tonumber(value)] = attribute[tonumber(value)] + getShowValue( value )
                                    end
                                end
                            end
                        end
                    			    -------------修炼属性数据---------------
			    if pvp.InstPlayerTrain then
				    for trainKey, trainObj in pairs(pvp.InstPlayerTrain) do
					    if instCardId == trainObj.int["3"] then
						    local _fightPropId = trainObj.int["4"]
						    local _value = trainObj.int["5"]
						    attribute[_fightPropId] = attribute[_fightPropId] + (_value * utils.FightValueFactor[_fightPropId])
					    end
				    end
			    end

                                            -------------装备套装属性---------------
                        if pvp.InstPlayerLineup then
                            local equipCount = 0
                            isInSuit = { }
                            for lineupKey, lineupObj in pairs(pvp.InstPlayerLineup) do
                                if _instFormationId == lineupObj.int["3"] then
                                    local _instEquipId = lineupObj.int["5"]
                                    local instEquipData = pvp.InstPlayerEquip[tostring(_instEquipId)]
                                    local dictEquipData = DictEquipment[tostring(instEquipData.int["4"])]
                                    -- 装备字典表
                                    equipCount = equipCount + 1
                                    if dictEquipData.equipQualityId >= 3 then
                                        -- 只有紫色、橙色可能有套装属性
                                        -- cclog("utils 套装属性 .. _instEquipId :".._instEquipId.." _instFormationId : ".._instFormationId)

                                        local isSame = false
                                        for key, value in pairs(isInSuit) do
                                            if tonumber(value) == tonumber(_instEquipId) then
                                                isSame = true
                                                break
                                            end
                                        end
                                        if not isSame then
                                            --  cclog("utils isSame")
                                            local tempAttribute = pvp.getEquipSuitAttribute(_instFormationId, _instEquipId, true)
                                            for attKey, attObj in pairs(tempAttribute) do
                                                -- cclog("attKey:"..attKey.."  attObj:"..attObj)
                                                attribute[attKey] = attribute[attKey] + attObj
                                            end
                                        end
                                    end
                                    if equipCount >= 4 then
                                        break
                                    end
                                end
                            end
                        end
				
					    -------------缘分属性数据---------------
                        if is3V3 then
                        --要单独算
                        local tempCount = 0
                        for luckKey, luckObj in pairs(DictCardLuck) do
                            if luckObj.cardId == dictCardId then
                                tempCount = tempCount + 1
                                if pvp.isCardLuck3v3(luckObj, _instFormationId , false , is3V3 ) then
                                    local luckFightValues = utils.stringSplit(luckObj.fightValues, ";")
                                    if luckFightValues and #luckFightValues > 0 then
                                        for lfvKey, lfvObj in pairs(luckFightValues) do
                                            local temp = utils.stringSplit(lfvObj, "_")
                                            -- fightPropId_value
                                            local luckFightPropId, luckAddValue = tonumber(temp[1]), tonumber(temp[2])
                                            attribute[luckFightPropId] = attribute[luckFightPropId] + math.floor(attribute[luckFightPropId] *(luckAddValue / 100))
                                            temp = nil
                                        end
                                    end
                                    luckFightValues = nil
                                    -- attribute[luckObj.fightPropId] = attribute[luckObj.fightPropId] + math.floor(attribute[luckObj.fightPropId] * (luckObj.addValue / 100))
                                end
                                if tempCount >= 6 then
                                    break
                                end
                            end
                        end
                    else
					    local tempCount = 0
					    for luckKey, luckObj in pairs(DictCardLuck) do
						    if luckObj.cardId == dictCardId then
							    tempCount = tempCount + 1
							    if pvp.isCardLuck(luckObj, _instFormationId) then
								    local luckFightValues = utils.stringSplit(luckObj.fightValues, ";")
								    if luckFightValues and #luckFightValues > 0 then
									    for lfvKey, lfvObj in pairs(luckFightValues) do
										    local temp = utils.stringSplit(lfvObj, "_")--fightPropId_value
										    local luckFightPropId, luckAddValue = tonumber(temp[1]), tonumber(temp[2])
										    attribute[luckFightPropId] = attribute[luckFightPropId] + math.floor(attribute[luckFightPropId] * (luckAddValue / 100))
										    temp = nil
									    end
								    end
								    luckFightValues = nil
								    -- attribute[luckObj.fightPropId] = attribute[luckObj.fightPropId] + math.floor(attribute[luckObj.fightPropId] * (luckObj.addValue / 100))
							    end
							    if tempCount >= 6 then
								    break
							    end
						    end
					    end
                    end
				
					    -------------装备镶嵌宝石属性数据---------------
					    if pvp.InstPlayerLineup then
						    local equipCount = 0
						    for lineupKey, lineupObj in pairs(pvp.InstPlayerLineup) do
							    if _instFormationId == lineupObj.int["3"] then
								    equipCount = equipCount + 1
								    local _instEquipId = lineupObj.int["5"]
								    --[[
								    local tempAttribute = getEquipWashAttribute(_instEquipId)
								    for attKey, attObj in pairs(tempAttribute) do
									    attribute[attKey] = attribute[attKey] + attObj
								    end
								    --]]
								    local tempAttribute = getEquipGemAttribute(_instEquipId)
								    for attKey, attObj in pairs(tempAttribute) do
									    attribute[attKey] = attribute[attKey] + attObj
								    end
								    if equipCount >= 4 then
									    break
								    end
							    end
						    end
					    end

					    -------------法宝和功法属性数据（具体值）---------------
					    if pvp.InstPlayerMagic then
						    local _magicCount = 0
						    for magicKey, magicObj in pairs(pvp.InstPlayerMagic) do
							    if instCardId == magicObj.int["8"] then
								    _magicCount = _magicCount + 1
								    local magicLv = DictMagicLevel[tostring(magicObj.int["6"])].level
								    local dictMagicData = DictMagic[tostring(magicObj.int["3"])]
                                    if magicObj.int["3"] >= 37 and magicObj.int["3"] <= 40 then 
                                    
                                    else
								        for _valueI = 1, 6 do
									        local _tValues = utils.stringSplit(dictMagicData["value" .. _valueI], "_")
									        if string.len(dictMagicData["value" .. _valueI]) > 0 and _tValues and #_tValues > 0 then
										        if _valueI <= 3 then
											        local fightPropId = tonumber(_tValues[2])
											        local fightAddValue = formula.getMagicValue1(magicLv, tonumber(_tValues[3]), tonumber(_tValues[4]))
											        if tonumber(_tValues[1]) == 1 then
												        magicPercent[fightPropId] = (magicPercent[fightPropId] and magicPercent[fightPropId] or 0) + fightAddValue
											        else
												        attribute[fightPropId] = attribute[fightPropId] + fightAddValue
											        end
										        else
											        if (_valueI == 4 and magicLv >= 10) or (_valueI == 5 and magicLv >= 20) or (_valueI == 6 and magicLv >= 40) then
												        magicPercent[tonumber(_tValues[1])] = (magicPercent[tonumber(_tValues[1])] and magicPercent[tonumber(_tValues[1])] or 0) + tonumber(_tValues[2])
											        end
										        end
									        end
								        end
                                    end

                                    local magicAdvanceId = magicObj.int["10"]
                                    if magicAdvanceId and magicAdvanceId > 0 then
                                        local magic_refining = {}
                                        if dictMagicData.magicQualityId <= StaticMagicQuality.DJ then
                                            for key  ,value in pairs( DictMagicrefining ) do
                                                 if dictMagicData.id == value.MagicId then
                                                     magic_refining[value.starLevel] = value.id
                                                 end
                                            end
                                        end
                                        local magicRifingingLevel = DictMagicrefining[tostring(magicAdvanceId)].starLevel
                                        for key ,value in pairs( magic_refining ) do
                                            if key <= magicRifingingLevel then
                                                local proValue = DictMagicrefining[ tostring( value ) ]
                                            --    cclog("magic refining : "..proValue.fightPropId .. "  "..proValue.value)
                                                attribute[proValue.fightPropId] = attribute[proValue.fightPropId] + tonumber( proValue.value )
                                            end
                                        end
                                    end

								    if _magicCount >= 2 then
									    break
								    end
							    end
						    end
					    end
					
					    break
				    end
				
			    end
			
			    -------------命宫属性数据---------------
			    if pvp.InstPlayerConstell and string.len(instConstellsId) > 0 then
				    local instConstellId_table = utils.stringSplit(instConstellsId, ";")
				    for key, id in pairs(instConstellId_table) do
					    local _instConstellData = pvp.InstPlayerConstell[tostring(id)] --命宫实例数据
					    local _dictConstellId = _instConstellData.int["4"] --命宫字典ID
					    local _isUse = _instConstellData.string["5"] --命宫丹药状态 0-未服用 1-服用（全为1表示该命宫点亮）
					    local _dictConstellData = DictConstell[tostring(_dictConstellId)]
					    local _pills = _dictConstellData.pills --丹药 丹药字典Id用分号隔开
					    local _isUses = utils.stringSplit(_isUse, ";")
					    local _dictPillIds = utils.stringSplit(_pills, ";")
					    for key, pillId in pairs(_dictPillIds) do
						    local _dictPillData = DictPill[tostring(pillId)]
						    if tonumber(_isUses[key]) == 1 then
							    if _dictPillData.tableTypeId == StaticTableType.DictFightProp then
								    attribute[_dictPillData.tableFieldId] = attribute[_dictPillData.tableFieldId] + _dictPillData.value
							    end
						    end
					    end
				    end
			    end
			
			    --[[
			    -------------功法属性数据---------------
			    if instGongFaId > 0 and pvp.InstPlayerKungFu then
				    local _instGongFaData = pvp.InstPlayerKungFu[tostring(instGongFaId)]
				    local _fightProps = {}
				    _fightProps[1] = _instGongFaData.string["8"]
				    _fightProps[2] = _instGongFaData.string["9"]
				    _fightProps[3] = _instGongFaData.string["10"]
				    _fightProps[4] = _instGongFaData.string["12"]
				    _fightProps[5] = _instGongFaData.string["13"]
				    _fightProps[6] = _instGongFaData.string["14"]
				    for fpKey = 1, 6 do
					    if _fightProps[fpKey] and string.len(_fightProps[fpKey]) > 0 then
						    local _propData = utils.stringSplit(_fightProps[fpKey], "_") --[1]:fightPropId, [2]:value
						    local _fightPropId, _value = tonumber(_propData[1]), tonumber(_propData[2])
						    attribute[_fightPropId] = attribute[_fightPropId] + _value
					    end
				    end
			    end
			    --]]
			


			    -------------红颜系统属性数据---------------
			    -- local tempInstBeautyCard = {}
			    -- if pvp.InstPlayerBeautyCard then
			    -- 	for ipbKey, ipbObj in pairs(pvp.InstPlayerBeautyCard) do
			    -- 		tempInstBeautyCard[ipbObj.int["3"]] = ipbObj
			    -- 	end
			    -- end
			    -- for dictKey, dictObj in pairs(DictBeautyCardFight) do
			    -- 	local _curBeautyCardExpId = 1 --默认为1级
			    -- 	local instBeautyCard = tempInstBeautyCard[dictObj.beautyCardId]
			    -- 	if instBeautyCard then
			    -- 		_curBeautyCardExpId = instBeautyCard.int["4"]
			    -- 	end
			    -- 	if _curBeautyCardExpId >= dictObj.beautyCardExpId then
			    -- 		local _fightPropId = dictObj.fightPropId
			    -- 		local _value = dictObj.value
			    -- 		attribute[_fightPropId] = attribute[_fightPropId] + _value
			    -- 	end
			    -- end
			    -- tempInstBeautyCard = nil

			    -------------法宝和功法属性数据（百分比）---------------
			    if magicPercent then
				    for _fightPropKey, _fightPropId in pairs(StaticFightProp) do
					    if magicPercent[_fightPropId] then
						    if (_fightPropId == StaticFightProp.blood or _fightPropId == StaticFightProp.wAttack or _fightPropId == StaticFightProp.fAttack or _fightPropId == StaticFightProp.wDefense or _fightPropId == StaticFightProp.fDefense) then
							    attribute[_fightPropId] = math.floor(attribute[_fightPropId] * (1 + magicPercent[_fightPropId] / 100))
						    else ----------即将传入战斗中的XX率-----------
							    -- cclog("---------->>>@ " .. DictFightProp[tostring(_fightPropId)].name .. "率：" .. magicPercent[_fightPropId] .. "%%")
						    end
					    end
				    end
			    end

			    --[[
			    -------------异火属性数据---------------
			    if pvp.InstPlayerFire then
				    for fireKey, fireObj in pairs(pvp.InstPlayerFire) do
					    local dictFireId = fireObj.int["3"] --异火字典ID
					    local fireLv = fireObj.int["4"] --异火等级
					    local bySkillIds = fireObj.string["6"] --被动技能
					    local dictFireData = DictFire[tostring(dictFireId)]
					    local fireSkillAddPercent = formula.getFireSkillAttribute(fireLv, dictFireData.fireSkillAdd)
					    local ids_ = utils.stringSplit(bySkillIds, ";")
					    for key, obj in pairs(ids_) do
						    local temp = utils.stringSplit(obj, "_") --[1]:位置, [2]:异火技能字典ID
						    local fireSkillId = tonumber(temp[2])
						    if fireSkillId > 0 then
							    local dictFireSkillData = DictFireSkill[tostring(fireSkillId)]
							    attribute[dictFireSkillData.fightPropId] = attribute[dictFireSkillData.fightPropId] + dictFireSkillData.fightPropValue * (fireSkillAddPercent / 100)
						    end
					    end
					    break
				    end
			    end
			    --]]


                ----------------异火属性数据---------------
                if not is3V3 and not noFire then
                    local _fireFightProps = {}
                    local _equipFireInstData = pvp.getEquipFireInstData(instCardId)
                    for _keyYF, _objYF in pairs(CustomDictYFireProp) do
                        local _condition = 0 --0.未达成, 1.达成
                        if cardQualityId >= _objYF.qualityId then
                            if cardQualityId == _objYF.qualityId then
                                if cardStarLevelId >= _objYF.starLevelId then
                                    _condition = 1
                                end
                            else
                                _condition = 1
                            end
                        end
                        if _condition == 1 and #_equipFireInstData >= _objYF.equipFireCount then
                            local fightPropId = utils.stringSplit(_objYF.fightPropId, ";")
                            local fightPropValue = utils.stringSplit(_objYF.fightPropValue, ";")
                            for _k, _fightPropId in pairs(fightPropId) do
                                if _fireFightProps[tonumber(_fightPropId)] == nil then
                                    _fireFightProps[tonumber(_fightPropId)] = 0
                                end
                                _fireFightProps[tonumber(_fightPropId)] = _fireFightProps[tonumber(_fightPropId)] + fightPropValue[_k]
                            end
                            fightPropValue = nil
                            fightPropId = nil
                        end
                    end
                    for _keyAtt, _objAtt in pairs(attribute) do
                        if _fireFightProps[_keyAtt] then
                            attribute[_keyAtt] = _objAtt * (1 + _fireFightProps[_keyAtt] / 100)
                        end
                    end
                    _fireFightProps = nil
                    _equipFireInstData = nil
                end
                ----------------异火属性数据---------------

                ----------------境界称号的生命加成属性数据---------------
                local _titleHPAdd = 0
                local _dictTitleDetailData = DictTitleDetail[tostring(cardTitleDetailId)]
                if _dictTitleDetailData then
                    local _dictTitleData = DictTitle[tostring(_dictTitleDetailData.titleId)]
                    if _dictTitleData then
                        _titleHPAdd = tonumber((_dictTitleData.description == "") and "0" or _dictTitleData.description)
                    end
                end
                ----------------翅膀天赋属性数据--------------
                if pvp.InstPlayerWing then
                    for wingKey , wingValue in pairs( pvp.InstPlayerWing ) do
                        if wingValue.int["6"] == instCardId then
                            for key , value in pairs( DictWingLuck ) do
                                if value.cardId == dictCardId then
                                     local lucks = utils.stringSplit( value.lucks , ";" )
                                     local values = utils.stringSplit( value.fightValues , ";" )
                                     if wingValue.int["5"] >= tonumber(lucks[ 1 ]) then
                                         local data = utils.stringSplit( values[1] , "_" )
                                        -- cclog(" data "..data[ 2 ])
                                         if tonumber( data[ 1 ] ) == StaticFightProp.blood  then
                                             _titleHPAdd = _titleHPAdd + tonumber( data[2] ) * 100
                                         
                                         else
                                            attribute[tonumber( data[ 1 ] )] = attribute[tonumber( data[ 1 ] )] + tonumber( data[2] / 2 )
                                         end
                                     end
                                     if wingValue.int["5"] >= tonumber(lucks[ 2 ]) then
                                       -- cclog(" data "..data[ 2 ])
                                         local data = utils.stringSplit( values[2] , "_" )
                                         if tonumber( data[ 1 ] ) == StaticFightProp.blood  then
                                             _titleHPAdd = _titleHPAdd + tonumber( data[2] ) * 100
                                         else
                                            attribute[tonumber( data[ 1 ] )] = attribute[tonumber( data[ 1 ] )] + tonumber( data[2] / 2 )
                                         end
                                     end
                                     break
                                end
                            end
                            break
                        end
                    end
                end

                --称号和翅膀生命统一加百分比
                attribute[StaticFightProp.blood] = attribute[StaticFightProp.blood] * (1 + _titleHPAdd / 100)


                --------------联盟修炼技能的属性数据--------------
                if pvp.InstUnionPractice then
                    -- 修炼Id_当前等级_当前经验;
                    local practice = utils.stringSplit(pvp.InstUnionPractice.string["3"], ";")
                    for key, obj in pairs(practice) do
                        local _tempObj = utils.stringSplit(obj, "_")
                        local _id = tonumber(_tempObj[1])
                        local _level = tonumber(_tempObj[2])
                        local _dictUnionPracticeData = DictUnionPractice[tostring(_id)]
                        if _dictUnionPracticeData then
                            local _tempData = utils.stringSplit(_dictUnionPracticeData.propEffect, "_")
                            local _tableTypeId = tonumber(_tempData[1])
                            local _fightPropId = tonumber(_tempData[2])
                            if _tableTypeId == StaticTableType.DictFightProp then
                                if _fightPropId < StaticFightProp.cutCrit then
                                    attribute[_fightPropId] = attribute[_fightPropId] * (1 + (_level * _dictUnionPracticeData.levelAdd) / 100)
                                else
                                    attribute[_fightPropId] = attribute[_fightPropId] + (_level * _dictUnionPracticeData.levelAdd) / 100
                                end
                            end
                        end
                        _tempObj = nil
                    end
                    practice = nil
                end


                 if isFriend == 0 and not is3V3 then --非小伙伴加
                    --结界属性数据
                    if attr then
                        for key ,value in pairs( attr ) do
                            attribute[key] = attribute[key] + value
                        end
                    elseif pvp.InstPlayerEnchantment then
                        local enchantIndex = tonumber( pvp.InstPlayerEnchantment.int["3"] )
                        local slots = pvp.InstPlayerEnchantment.string[ "4" ]
                        if slots then
                            local slotsData = utils.stringSplit( slots , ";" )
                            local slotsPro = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].slots , ";" )
                            for key ,value in pairs( slotsData ) do
                                if tonumber( value ) > 0 then
                                    local propData = utils.stringSplit( slotsPro[ key ] , "_" )
                                    local _fightPropId = tonumber(propData[1])
                                    local attProp = pvp.getCardAttribute( tonumber( value ) , nil , nil , true )
                                    attribute[_fightPropId] = attribute[_fightPropId] + attProp[ _fightPropId ] * tonumber( propData[2] )
                                    if tonumber( key ) == #slotsData then --界门
                                        local conditionData = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].addition , ";" )
                                        for i = 1 , #conditionData do
                                            local obj = utils.stringSplit( conditionData[ i ] , "_" )
                                            local conditionIndex1 = tonumber( obj[ 3 ] )
                                            local conditionIndex2 = tonumber( obj[ 4 ] )
                                            local condition1 = ""
                                            local condition2 = ""
                                            local cardData = {}
                                            local comCount = 0
                                            if conditionIndex1 == 0 then
                                                cardData[ #cardData + 1 ] = slotsData[ #slotsData ]
                                                comCount = 1
                                            elseif conditionIndex1 == #slotsData then
                                                cardData = slotsData
                                                comCount = conditionIndex1
                                            else
                                                cardData = slotsData
                                                comCount = conditionIndex1
                                            end
                                            local isEnough = false
                                            if conditionIndex2 == 1 then
                                                local aa = 0
                                                for key ,value in pairs( cardData ) do
                                                    if tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "9" ] >= tonumber( obj[ 5 ] ) then
                                                        aa = aa + 1
                                                    end
                                                end
                                                if aa >= comCount then
                                                    isEnough = true
                                                else
                                                    isEnough = false
                                                end
                                            elseif conditionIndex2 == 2 then
                                                local aa = 0
                                                for key ,value in pairs( cardData ) do
                                                    if tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "6" ] >= tonumber( obj[ 5 ] ) then
                                                        aa = aa + 1
                                                    end
                                                end
                                                if aa >= comCount then
                                                    isEnough = true
                                                else
                                                    isEnough = false
                                                end
                                            elseif conditionIndex2 == 3 then
                                                local aa = 0
                                                for key ,value in pairs( cardData ) do
                                                    if tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "4" ] == tonumber( obj[ 5 ] ) and pvp.InstPlayerCard[ tostring( value ) ].int[ "5" ] > tonumber( obj[ 6 ] ) then
                                                        aa = aa + 1
                                                    elseif tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "4" ] > tonumber( obj[ 5 ] ) then
                                                        aa = aa + 1
                                                    end
                                                end
                                                if aa >= comCount then
                                                    isEnough = true
                                                else
                                                    isEnough = false
                                                end
                                            end
                                            if isEnough then
                                                attribute[tonumber( obj[ 1 ] )] = attribute[tonumber( obj[ 1 ] )] + attProp[ tonumber( obj[ 1 ] ) ] * tonumber( obj[ 2 ] ) 
                                            end
                                        end

                                    end
                                end
                            end
                        end
                    end
                end

			end
		
	end
	if fightSoulValue then
        return attribute , fightSoulValue
    else
        return attribute, magicPercent
    end
end
--获取结界加的属性		
function pvp.getEnchantmentPro()
	local attribute = {}
	if pvp.InstPlayerEnchantment then
        local enchantIndex = tonumber( pvp.InstPlayerEnchantment.int["3"] )
        local slots = pvp.InstPlayerEnchantment.string[ "4" ]
        if slots then
            local slotsData = utils.stringSplit( slots , ";" )
            local slotsPro = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].slots , ";" )
            for key ,value in pairs( slotsData ) do
                if tonumber( value ) > 0 then
                    local propData = utils.stringSplit( slotsPro[ key ] , "_" )
                    local _fightPropId = tonumber(propData[1])
                    local attProp = pvp.getCardAttribute( tonumber( value ) , nil , nil , true , {} )
					if attribute[_fightPropId] then
						attribute[_fightPropId] = attribute[_fightPropId] + attProp[ _fightPropId ] * tonumber( propData[2] )
					else
						attribute[_fightPropId] = attProp[ _fightPropId ] * tonumber( propData[2] )
					end
                    if tonumber( key ) == #slotsData then --界门
                        local conditionData = utils.stringSplit( DictEnchantment[ tostring( enchantIndex ) ].addition , ";" )
                        for i = 1 , #conditionData do
                            local obj = utils.stringSplit( conditionData[ i ] , "_" )
                            local conditionIndex1 = tonumber( obj[ 3 ] )
                            local conditionIndex2 = tonumber( obj[ 4 ] )
                            local condition1 = ""
                            local condition2 = ""
                            local cardData = {}
                            local comCount = 0
                            if conditionIndex1 == 0 then
                                cardData[ #cardData + 1 ] = slotsData[ #slotsData ]
                                comCount = 1
                            elseif conditionIndex1 == #slotsData then
                                cardData = slotsData
                                comCount = conditionIndex1
                            else
                                cardData = slotsData
                                comCount = conditionIndex1
                            end
                            local isEnough = false
                            if conditionIndex2 == 1 then
                                local aa = 0
                                for key ,value in pairs( cardData ) do
                                    if tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "9" ] >= tonumber( obj[ 5 ] ) then
                                        aa = aa + 1
                                    end
                                end
                                if aa >= comCount then
                                    isEnough = true
                                else
                                    isEnough = false
                                end
                            elseif conditionIndex2 == 2 then
                                local aa = 0
                                for key ,value in pairs( cardData ) do
                                    if tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "6" ] >= tonumber( obj[ 5 ] ) then
                                        aa = aa + 1
                                    end
                                end
                                if aa >= comCount then
                                    isEnough = true
                                else
                                    isEnough = false
                                end
                            elseif conditionIndex2 == 3 then
                                local aa = 0
                                for key ,value in pairs( cardData ) do
                                    if tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "4" ] == tonumber( obj[ 5 ] ) and pvp.InstPlayerCard[ tostring( value ) ].int[ "5" ] > tonumber( obj[ 6 ] ) then
                                        aa = aa + 1
                                    elseif tonumber( value ) > 0 and pvp.InstPlayerCard[ tostring( value ) ].int[ "4" ] > tonumber( obj[ 5 ] ) then
                                        aa = aa + 1
                                    end
                                end
                                if aa >= comCount then
                                    isEnough = true
                                else
                                    isEnough = false
                                end
                            end
                            if isEnough then
								if attribute[tonumber( obj[ 1 ] )]  then
									attribute[tonumber( obj[ 1 ] )] = attribute[tonumber( obj[ 1 ] )] + attProp[ tonumber( obj[ 1 ] ) ] * tonumber( obj[ 2 ] ) 
								else
									attribute[tonumber( obj[ 1 ] )] = attProp[ tonumber( obj[ 1 ] ) ] * tonumber( obj[ 2 ] ) 
								end
                            end
                        end

                    end
                end
            end
        end
    end
	return attribute
end
--- 获取玩家战力值
function pvp.getFightValueByTeam( team1 )
    local team = {}
        --得到实力id
    local function getInstPlayerCardId( formationId )
        if tonumber( formationId ) == 0 then
            return nil
        end
        return pvp.InstPlayerFormation[ tostring( formationId) ].int[ "3" ]
    end
    for key ,value in pairs ( team1 ) do
        team[ key ] = getInstPlayerCardId( tonumber( value ) )
    end
    local fightValue = 0
    if team then
        local isNull = true
        for key, obj in pairs( team ) do
            if obj then
                isNull = false
                local instCardId = obj
                -- 卡牌实例ID
                local attribute, fightSoulValue = pvp.getCardAttribute(instCardId, 0 ,team)
                for _fightPropId, _fightPropValue in pairs(attribute) do
                    if utils.FightValueFactor[_fightPropId] then
                        fightValue = fightValue +(_fightPropValue / utils.FightValueFactor[_fightPropId])
                    end
                end
                fightValue = fightValue + fightSoulValue
            end
        end

        --------------联盟修炼技能的战力数据--------------
        if pvp.InstUnionPractice and not isNull then
            -- 修炼Id_当前等级_当前经验;
            local practice = utils.stringSplit(pvp.InstUnionPractice.string["3"], ";")
            for key, obj in pairs(practice) do
                local _tempObj = utils.stringSplit(obj, "_")
                local _id = tonumber(_tempObj[1])
                local _level = tonumber(_tempObj[2])
                local _dictUnionPracticeData = DictUnionPractice[tostring(_id)]
                if _dictUnionPracticeData then
                    local _tempData = utils.stringSplit(_dictUnionPracticeData.propEffect, "_")
                    local _tableTypeId = tonumber(_tempData[1])
                    local _fightPropId = tonumber(_tempData[2])
                    if _tableTypeId == StaticTableType.DictFightProp and _fightPropId >= StaticFightProp.cutCrit then
                        for _k, _o in pairs(DictUnionPracticeUpgrade) do
                            if _o.unionPracticeId == _dictUnionPracticeData.id and _o.level == _level then
                                fightValue = fightValue + _o.fightValueAdd
                                break
                            end
                        end
                    end
                    _tempData = nil
                end
                _tempObj = nil
            end
            practice = nil
        end
    end
    return math.floor(fightValue)
end
---获取玩家战力值
function pvp.getFightValue()
	local fightValue = 0
	if pvp.InstPlayerFormation then
        local attr = pvp.getEnchantmentPro()
		for key, obj in pairs(pvp.InstPlayerFormation) do
            if obj.int["4"] == 1 or obj.int["4"] == 2 then
			    local instCardId = obj.int["3"] --卡牌实例ID
			    local attribute , fightSoulValue = pvp.getCardAttribute(instCardId , 0 , nil , nil , attr )
			    for _fightPropId, _fightPropValue in pairs(attribute) do
				    if utils.FightValueFactor[_fightPropId] then
					    fightValue = fightValue + (_fightPropValue / utils.FightValueFactor[_fightPropId])
				    end
			    end
                fightValue = fightValue + fightSoulValue
            end
		end

        --------------联盟修炼技能的战力数据--------------
        if pvp.InstUnionPractice then
            -- 修炼Id_当前等级_当前经验;
            local practice = utils.stringSplit(pvp.InstUnionPractice.string["3"], ";")
            for key, obj in pairs(practice) do
                local _tempObj = utils.stringSplit(obj, "_")
                local _id = tonumber(_tempObj[1])
                local _level = tonumber(_tempObj[2])
                local _dictUnionPracticeData = DictUnionPractice[tostring(_id)]
                if _dictUnionPracticeData then
                    local _tempData = utils.stringSplit(_dictUnionPracticeData.propEffect, "_")
                    local _tableTypeId = tonumber(_tempData[1])
                    local _fightPropId = tonumber(_tempData[2])
                    if _tableTypeId == StaticTableType.DictFightProp and _fightPropId >= StaticFightProp.cutCrit then
                        for _k, _o in pairs(DictUnionPracticeUpgrade) do
                            if _o.unionPracticeId == _dictUnionPracticeData.id and _o.level == _level then
                                fightValue = fightValue + _o.fightValueAdd
                                break
                            end
                        end
                    end
                    _tempData = nil
                end
                _tempObj = nil
            end
            practice = nil
        end

	end
--	if pvp.InstPlayerManualSkillLine and pvp.InstPlayerManualSkill then
--		for i = 1, 4 do
--			local _id = pvp.InstPlayerManualSkillLine.int[tostring(i + 2)]
--			if _id > 0 and pvp.InstPlayerManualSkill[tostring(_id)] then
--				local _instManualSkill = pvp.InstPlayerManualSkill[tostring(_id)]
--				local _dictManualSkillData = DictManualSkill[tostring(_instManualSkill.int["4"])]
--				local _skillLv = _instManualSkill.int["5"]
--				fightValue = fightValue + formula.getManualSkillFightValue(_skillLv, _dictManualSkillData.fightValue, _dictManualSkillData.fightValueAdd)
--			end
--		end
--	end
	return math.floor(fightValue)
end

--根据卡牌实例ID获取装备的异火实例数据(最多三条数据)
function pvp.getEquipFireInstData(_cardInstId, _isFilter)
    local _equipFireInstData = {}
    --FIX 修复Lua语法#(取表长度的Bug),该Bug导致异火莫名其妙的无法显示.
    --FIX 不考虑_position可能重复导致统计错误的问题.
    local tableSize = 0
    if pvp.InstPlayerYFire then
        for key, obj in pairs(pvp.InstPlayerYFire) do
            local cardIds = utils.stringSplit(obj.string["8"], ";")
            for _k, _o in pairs(cardIds) do
                local _tempO = utils.stringSplit(_o, "_")
                if tonumber(_tempO[1]) == _cardInstId then
                    local _position = tonumber(_tempO[2])
                    if _isFilter then
                        local instCardData = pvp.InstPlayerCard[tostring(_cardInstId)] --卡牌实例数据
	                    local qualityId = instCardData.int["4"] --品阶ID
	                    local starLevelId = instCardData.int["5"] --星级ID
                        local _gridState = 0 --0.上锁, 1.开启
                        if qualityId >= dp.FireEquipGrid[_position].qualityId then
                            if qualityId == dp.FireEquipGrid[_position].qualityId then
                                if starLevelId >= dp.FireEquipGrid[_position].starLevelId then
                                    _gridState = 1
                                end
                            else
                                _gridState = 1
                            end
                        end
                        if _gridState == 1 then
                            _equipFireInstData[_position] = obj
                            tableSize = tableSize + 1
                            _tempO = nil
                            break
                        end
                    else
                        _equipFireInstData[_position] = obj
                        tableSize = tableSize + 1
                        _tempO = nil
                        break
                    end
                end
                _tempO = nil
            end
            cardIds = nil
            if tableSize >= #dp.FireEquipGrid then
                break
            end
        end
    end
    return _equipFireInstData
end

--根据异火实例ID获取装备的异火状态和当前HP(0:未激活，1:旺盛，2:狂暴)
function pvp.getEquipFireState(_fireInstId)
    local _fireState, _curFireHP = 0, 0
    if pvp.InstPlayerYFire and pvp.InstPlayerYFire[tostring(_fireInstId)] then
        local instPlayerYFire = pvp.InstPlayerYFire[tostring(_fireInstId)]
        local _curFireState = instPlayerYFire.int["4"]
        _curFireHP = instPlayerYFire.int["6"]
        local _cardList = utils.stringSplit(instPlayerYFire.string["8"], ";")
        _fireState = _curFireState
        if _curFireState == 0 then --未激活状态
        elseif _curFireState == 1 then --激活状态（旺盛）
        elseif _curFireState == 2 then --激活状态（狂暴）
            if #_cardList > 0 then
                local _times = math.floor((utils.getCurrentTime() - utils.GetTimeByDate(instPlayerYFire.string["5"])) / 60)
                if _times < 0 then
                    _times = _times * -1
                end
                local _fireHP = _times * instPlayerYFire.int["7"] * #_cardList
                _curFireHP = _curFireHP - _fireHP
                if _curFireHP <= 0 then --进入旺盛状态
                    pvp.InstPlayerYFire[tostring(_fireInstId)].int["4"] = 1
                    pvp.InstPlayerYFire[tostring(_fireInstId)].int["6"] = 0
                    _fireState = 1
                    _curFireHP = 0
                end
            end
        end
        _cardList = nil
    end
    return _fireState, _curFireHP
end
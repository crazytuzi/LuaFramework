-- FileName: ChariotIllustrateData.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车图鉴数据处理中心

module("ChariotIllustrateData", package.seeall)

require "db/DB_Item_warcar"
require "db/DB_Suit_warcar"
require "script/ui/chariot/ChariotDef"

local _chariotBookInfo 		= nil -- 战车图鉴信息
local _chariotBookAttrInfo 	= nil -- 战车图鉴加成信息
local _chariotSuitInfo 		= nil -- 战车组合信息
local _chariotSuitAttrInfo 	= nil -- 战车组合加成信息

--[[
	@desc   : 设置战车图鉴信息
    @param  : pBookData 后端返回的战车图鉴信息
    @return : 
--]]
function setChariotBookInfo( pBookData )
	_chariotBookInfo = {}
	-- 将数组解析成字典，方便查找指定id的战车是否存在
	for i,id in ipairs(pBookData) do
		id = tonumber(id)
		_chariotBookInfo[id] = id
	end

	-- 设置战车组合信息
	local suitInfo = calculateActivatedSuitIds()
	setChariotSuitInfo(suitInfo)
end

--[[
	@desc   : 获取战车图鉴信息
    @param  : 
    @return : 
--]]
function getChariotBookInfo()
	return _chariotBookInfo
end

--[[
	@desc 	: 根据战车Tid 激活战车图鉴
	@param 	: pTid 战车Tid
	@return : 
--]]
function activeChariotByTid( pTid )
	-- 更新战车图鉴信息
	if (_chariotBookInfo == nil) then
		_chariotBookInfo = {}
	end
	-- 如果已经激活过，不执行更新操作
	if (_chariotBookInfo[tonumber(pTid)] ~= nil) then
		return
	end
	_chariotBookInfo[tonumber(pTid)] = pTid

	-- 更新战车组合信息
	local suitInfo = calculateActivatedSuitIds()
	setChariotSuitInfo(suitInfo)

	-- 刷新战力加成信息
	getChariotBookAttrInfo(true)
	getChariotSuitAttrInfo(true)
end

--[[
	@desc 	: 是否已获得过战车
	@param 	: pTid 战车Tid
	@return : bool
--]]
function isHadChariotByTid( pTid )
	local isHadChariot = false
	local chariotBookInfo = getChariotBookInfo()
	if (not table.isEmpty(chariotBookInfo)) then
    	if (chariotBookInfo[pTid] ~= nil or chariotBookInfo[tonumber(pTid)] ~= nil) then
    		isHadChariot = true
    	end
    end
	return isHadChariot
end

--[[
	@desc 	: 根据战车tid获取战车信息(包括是否获得)
	@param 	: pTid 战车tid
	@return : 战车信息
--]]
function getChariotInfoByTid( pTid )
	local retData = getChariotDBByTid(pTid)
	if (retData ~= nil) then
		-- 记录是否获得过
		retData.isGot = isHadChariotByTid(pTid)
	end
	return retData
end

--[[
	@desc 	: 根据战车tid获取战车DB
	@param 	: pTid 战车tid
	@return : 战车DB
--]]
function getChariotDBByTid( pTid )
	local retData = DB_Item_warcar.getDataById(pTid)
	return retData
end

--[[
	@desc   : 获取展示的战车图鉴信息
    @param  : 
    @return : 
--]]
function getAllBookInfo()
	local allChariotInfo = {}
	-- 只有show 为 1 显示在图鉴列表中
	local arrChariot = DB_Item_warcar.getArrDataByField("show",ChariotDef.kIllustrateStatusShow)
	for i,v in ipairs(arrChariot) do
        local chariotInfo = getChariotInfoByTid(v.id)
       	table.insert(allChariotInfo,chariotInfo)
    end
    -- 按id排序
    table.sort(allChariotInfo,function (v1,v2)
    	return v1.id < v2.id
	end)

	print("---------------getAllBookInfo---------------")
	print_t(allChariotInfo)
	print("---------------getAllBookInfo---------------")

	return allChariotInfo
end

--[[
	@desc 	: 根据战车Tid获取战车图鉴属性加成信息
	@param 	: pTid 战车Tid
	@return : table 战车图鉴属性加成信息
--]]
function getChariotIllustrateAttrInfoByTid( pTid )
	local chariotDB = getChariotDBByTid(pTid)
	local attrInfo  = {}
	if (chariotDB) then
		local recordabilityTab = parseField(chariotDB.Recordability,2)

		-- print("---------------getChariotIllustrateAttrInfoByTid---------------")
		-- print_t(recordabilityTab)
		-- print("---------------getChariotIllustrateAttrInfoByTid---------------")

		for k,v in pairs(recordabilityTab) do
			local attrId = tonumber(v[1])
			local attrNum = tonumber(v[2])
			attrInfo[attrId] = attrNum
		end
	else
		print("getChariotIllustrateAttrInfoByTid pTid error!")
	end
	return attrInfo
end

--[[
	@desc 	: 计算战车图鉴属性加成信息 给全体上阵武将加
	@param 	: 
	@return : table {id = value} 全体上阵武将加成属性加成信息
--]]
function calculateChariotBookAttrInfo()
	local retData = {}
	if DataCache.getSwitchNodeState(ksSwitchChariot, false) then
		local chariotBookInfo = getChariotBookInfo()
		if ( not table.isEmpty(chariotBookInfo) ) then
			for k,v in pairs(chariotBookInfo) do
				local attrTab = getChariotIllustrateAttrInfoByTid(v)
				for attrId,attrNum in pairs(attrTab) do
					if( retData[attrId] == nil  )then
						retData[attrId] = attrNum
					else
						retData[attrId] = retData[attrId] + attrNum
					end
				end
			end
		end
	end
	return retData
end

--[[
	@desc	: 获取战车图鉴属性加成信息
	@param	: pIsForce 强制重新计算
	@return : table {id = value} 战车图鉴属性加成信息
--]]
function getChariotBookAttrInfo( pIsForce )
	if (pIsForce or _chariotBookAttrInfo == nil) then
		_chariotBookAttrInfo = calculateChariotBookAttrInfo()
	end

	print("-----------------------getChariotBookAttrInfo---------------------")
	print_t(_chariotBookAttrInfo)
	print("-----------------------getChariotBookAttrInfo---------------------")
	
	return _chariotBookAttrInfo
end

------------------------------------------------------ 战车套装(组合) 相关------------------------------------------------

--[[
	@desc 	: 根据战车组合id获取战车组合DB
	@param 	: pSuitId 战车组合id
	@return :
--]]
function getSuitDBById( pSuitId )
	local retData = DB_Suit_warcar.getDataById(pSuitId)
	return retData
end

--[[
	@desc 	: 根据战车组合id获取战车组合信息(是否已激活)
	@param 	: pSuitId 战车组合id
	@return : 战车组合信息
--]]
function getSuitInfoById( pSuitId )
	local retData = getSuitDBById(pSuitId)

	if (retData ~= nil) then
		-- 是否已激活
		retData.isActivated = isActivatedSuitById(pSuitId)

		-- 战车信息
	    local needTids = getSuitItemsById(pSuitId)
		retData.chariotOne = getChariotInfoByTid(needTids[1])
		retData.chariotTwo = getChariotInfoByTid(needTids[2])
	end

	return retData
end

--[[
	@des 	: 根据战车组合id获取组合tid
	@param 	: pSuitId 战车组合id
	@return : {tid1,tid2}
--]]
function getSuitItemsById( pSuitId )
	local retData = getSuitDBById(pSuitId)
	local suitItems = string.split(retData.suit_items,",")
	return suitItems
end

--[[
	@desc   : 设置战车组合信息
    @param  : 
    @return : 
--]]
function setChariotSuitInfo( pSuitData )
	_chariotSuitInfo = pSuitData
end

--[[
	@desc   : 获取战车组合信息
    @param  : 
    @return : 
--]]
function getChariotSuitInfo()
	return _chariotSuitInfo
end

--[[
	@desc   : 获取展示的战车组合信息
    @param  : 
    @return : 
--]]
function getAllSuitInfo()
	local allSuitInfo = {}
	for k,v in pairs(DB_Suit_warcar.Suit_warcar) do
        local suitInfo = getSuitInfoById(v[1])
       	table.insert(allSuitInfo,suitInfo)
    end
    -- 按id排序
    table.sort(allSuitInfo,function (v1,v2)
    	return v1.id < v2.id
	end)

	print("---------------getAllSuitInfo---------------")
	print_t(allSuitInfo)
	print("---------------getAllSuitInfo---------------")

	return allSuitInfo
end

--[[
	@desc   : 计算所有战车激活组合的id
    @param  : 
    @return : 
--]]
function calculateActivatedSuitIds()
 	local retData = {}
	for k,v in pairs(DB_Suit_warcar.Suit_warcar) do
		local suitId = tonumber(v[1])
		local isActivate = isActivatedSuitById(suitId)
		if (isActivate) then
			retData[suitId] = suitId
		end
	end
	return retData
end

--[[
	@desc 	: 是否激活战车组合
	@param 	: pSuitId 战车组合id
	@return : bool
--]]
function isActivatedSuitById( pSuitId )
	local isActivated = false
	if(pSuitId == nil)then
		return isActivated
	end
	local needTids = getSuitItemsById(pSuitId)
	local isHave1 = isHadChariotByTid(needTids[1])
	local isHave2 = isHadChariotByTid(needTids[2])
	if( isHave1 and isHave2 )then
		isActivated = true
	end
	return isActivated
end

--[[
	@desc 	: 根据战车组合id获取战车组合属性加成信息
	@param 	: pSuitId 战车组合id
	@return : table 战车组合属性加成信息
--]]
function getChariotSuitAttrInfoById( pSuitId )
	local suitDB = getSuitDBById(pSuitId)
	local attrInfo  = {}
	if (suitDB) then
		local suitAttTab = parseField(suitDB.suit_att,2)

		-- print("---------------getChariotSuitAttrInfoById---------------")
		-- print_t(suitAttTab)
		-- print("---------------getChariotSuitAttrInfoById---------------")

		for k,v in pairs(suitAttTab) do
			local attrId = tonumber(v[1])
			local attrNum = tonumber(v[2])
			attrInfo[attrId] = attrNum
		end
	else
		print("getChariotSuitAttrInfoById pSuitId error!")
	end
	return attrInfo
end

--[[
	@desc 	: 计算战车组合属性加成信息 给全体上阵武将加
	@param 	: 
	@return : table {id = value} 全体上阵武将加成属性加成信息
--]]
function calculateChariotSuitAttrInfo()
	local retData = {}
	if DataCache.getSwitchNodeState(ksSwitchChariot, false) then
		local chariotSuitInfo = getChariotSuitInfo()
		if ( not table.isEmpty(chariotSuitInfo) ) then
			for k,v in pairs(chariotSuitInfo) do
				local attrTab = getChariotSuitAttrInfoById(v)
				for attrId,attrNum in pairs(attrTab) do
					if( retData[attrId] == nil  )then
						retData[attrId] = attrNum
					else
						retData[attrId] = retData[attrId] + attrNum
					end
				end
			end
		end
	end
	return retData
end

--[[
	@desc	: 获取战车组合属性加成信息
	@param	: pIsForce 强制重新计算
	@return : table {id = value} 战车组合属性加成信息
--]]
function getChariotSuitAttrInfo( pIsForce )
	if (pIsForce or _chariotSuitAttrInfo == nil) then
		_chariotSuitAttrInfo = calculateChariotSuitAttrInfo()
	end

	print("-----------------------getChariotSuitAttrInfo---------------------")
	print_t(_chariotSuitAttrInfo)
	print("-----------------------getChariotSuitAttrInfo---------------------")
	
	return _chariotSuitAttrInfo
end
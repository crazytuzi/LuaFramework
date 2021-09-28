-- FileName : StageEnhanceData.lua
-- Author   : YangRui
-- Date     : 2015-12-07
-- Purpose  : 

module("StageEnhanceData", package.seeall)

require "db/DB_Secondfriends"
require "db/DB_Secondfriends_levelup"

local _stageLvData = nil  -- 助战位等级数据
local _needItemNum = 0  -- 强化所需物品数量


local _secondStageLockAffix = {}

--[[
	@des 	: 获取开启的助战位个数
	@param 	: 
	@return : 
--]]
function getOpenStageNum( ... )
	local secFriendsStageData = SecondFriendData.getSecondFriendInfo()
	local secFriendsNum = 0
	if table.isEmpty(secFriendsStageData) then
		secFriendsNum = 0
	else
		for index,info in pairs(secFriendsStageData) do
			if tonumber(info) >= 0 then
				secFriendsNum = secFriendsNum + 1
			end
		end
	end

	return secFriendsNum
end

--[[
	@des 	: 获取当前助战位等级
	@param 	: 
	@return : 
--]]
function getCurStageLv( pIndex )
	local curLv = nil
	if not table.isEmpty(_stageLvData) then
		curLv = tonumber(_stageLvData[pIndex])
		if curLv == nil or curLv <= 0 then
			curLv = 0
		end
	else
		curLv = 0
	end
	
	return curLv
end

--[[
	@des 	: 添加助战位等级
	@param 	: 
	@return : 
--]]
function addCurStageLv( pIndex )
	print("===|addCurStageLv pIndex|===",pIndex)
	if not table.isEmpty(_stageLvData) then
		if _stageLvData[pIndex] ~= nil then
			if tonumber(_stageLvData[pIndex]) == -1 then
				-- 刚开启后强化
				_stageLvData[pIndex] = tostring(1)
			else
				_stageLvData[pIndex] = tostring(tonumber(_stageLvData[pIndex])+1)
			end
		else
			_stageLvData[pIndex] = tostring(1)
		end
	else
		_stageLvData = {}
		_stageLvData[pIndex] = tostring(1)
	end
end

--[[
	@des 	: 设置助战位等级数据
	@param 	: 
	@return : 
--]]
function setStageLvData( pData )
	_stageLvData = {}
	_stageLvData = pData
end

--[[
	@des 	: 获取助战位等级数据
	@param 	: 
	@return : 
--]]
function getStageLvData( ... )
	return _stageLvData
end

--[[
	@des 	: 获取当前所需物品数量
	@param 	: 
	@return : 
--]]
function getNeedItemNum( ... )
	return _needItemNum
end

--[[
	@des 	: 添加当前所需物品数量
	@param 	: 
	@return : 
--]]
function addNeedItemNum( pNum )
	_needItemNum = _needItemNum+tonumber(pNum)
end

--[[
	@des 	: 设置当前所需物品数量
	@param 	: 
	@return : 
--]]
function setNeedItemNum( pNum )
	_needItemNum = tonumber(pNum)
end

--[[
	@des 	: 将额外提升属性字符串变为表
	@param 	: 
	@return : 
--]]
function handleExtraAffix( pIndex )
	local extraAffix = getExtraAffix(pIndex)
	local extraAffixTab = string.split(extraAffix,",")
	return extraAffixTab
end

--[[
	@des 	: 处理单条额外属性提升
	@param 	: 
	@return : 
--]]
function handleSingleExtraAffix( pData )
	local singleExtraAffixTab = string.split(pData,"|")
	local needLv, affixId, affixUpVal = tonumber(singleExtraAffixTab[1]),tonumber(singleExtraAffixTab[2]),tonumber(singleExtraAffixTab[3])
	return needLv, affixId, affixUpVal
end

--[[
	@des 	: 将提升属性字符串变为表
	@param 	: 
	@return : 
--]]
function handleUpAffix( pIndex )
	local upAffix = getUpAffix(pIndex)
	local upAffixTab = string.split(upAffix,",")
	return upAffixTab
end

--[[
	@des 	: 处理单条属性提升为表
	@param 	: 
	@return : 
--]]
function handleSingleUpAffix( pIndex, pLv )
	local singleUpAffix = handleUpAffix(pIndex)
	local retTab = {}
	for k,v in pairs(singleUpAffix) do
		local tab = string.split(v, "|")
		retTab[tonumber(tab[2])] = tonumber(tab[3])*pLv
	end
	return retTab
end

--[[
	@des 	: 将基础属性字符串转变为表
	@param 	: 
	@return : 
--]]
function handleBasicAffix( pIndex )
	local basicAffix = getAttribute(pIndex)
	local basicAffixTab = string.split(basicAffix,",")
	return basicAffixTab
end


--[[
	@des 	: 获取助战位强化到下一等级所需消耗
	@param 	: 
	@return : 
--]]
function getNextLvEnhanceCost( pNextLv )
	local silverCost, itemCost = getEachLvCost(pNextLv)
	local itemCostTab = string.split(itemCost,"|")
	local itemCostId, itemCostNum = tonumber(itemCostTab[1]),tonumber(itemCostTab[2])
	return silverCost,itemCostId,itemCostNum
end

--[[
	@des 	: 计算当前属性
	@param 	: 
	@return : 
--]]
function calcCurAffix( pIndex, pLv )
	-- 基础+等级*提升
	local upAffixTab = handleSingleUpAffix(pIndex,pLv)
	-- 获取该位置上的武将
	-- local secFriendsBasicAffixTab = SecondFriendData.getSecFriendAddAttrByPos(pIndex)
	-- for index,data in pairs(secFriendsBasicAffixTab) do
	-- 	upAffixTab[tonumber(data[2])] = upAffixTab[tonumber(data[2])]+tonumber(data[3])
	-- end

	return upAffixTab
end

--[[
	@des 	: 获取所有助战位增加的属性值
	@param 	: 
	@return : 
--]]
function getAllAffixUpInfo( ... )
	local allAttrDataTab = {}
	local stageNum = table.count(DB_Secondfriends.Secondfriends)
	for i=1,stageNum do
		local curStageLv = getCurStageLv(i)
		local singleAttr = handleSingleUpAffix(i,curStageLv)
		table.insert(allAttrDataTab,singleAttr)
	end

	return allAttrDataTab
end

--[[
	@des 	: 获取所有的助战位解锁的属性值
	@param 	: 
	@return : 
--]]
function calcAttrExtraUpInfo( ... )
	local allAttrExtraDataTab = {}
	local stageNum = table.count(DB_Secondfriends.Secondfriends)
	for i=1,stageNum do
		local curStageLv = getCurStageLv(i)
		local curData = handleExtraAffix(i)
		for k,v in pairs(curData) do
			local needLv,affixId,affixUpVal = handleSingleExtraAffix(v)
			if curStageLv >= needLv then
				-- 解锁
				if allAttrExtraDataTab[affixId] ~= nil then
					allAttrExtraDataTab[affixId] = allAttrExtraDataTab[affixId]+affixUpVal
				else
					allAttrExtraDataTab[affixId] = affixUpVal
				end
			end
		end
	end

	return allAttrExtraDataTab
end

function getLockAffiX(pForce)
	if table.isEmpty(_secondStageLockAffix) or pForce then
		_secondStageLockAffix = calcAttrExtraUpInfo()
	end
	return _secondStageLockAffix
end


---------------------------------------------------配置---------------------------------------------------

--[[
	@des 	: 获取某一助战位最大强化等级  -- 50
	@param 	: 
	@return : 
--]]
function getEnhanceMaxLv( pIndex )
	local secFriendsData = DB_Secondfriends.getDataById(pIndex)
	return secFriendsData.max_lv
end

--[[
	@des 	: 获取提升属性  -- upAffix 4|54|100,5|55|100
	@param 	: 
	@return : 
--]]
function getUpAffix( pIndex )
	local secFriendsData = DB_Secondfriends.getDataById(pIndex)
	return secFriendsData.upAffix
end

--[[
	@des 	: 获取基础属性值  attribute  4|54|1500,5|55|1500
	@param 	: 
	@return : 
--]]
function getAttribute( pIndex )
	local basicAffixData = DB_Secondfriends.getDataById(pIndex)
	return basicAffixData.attribute
end

--[[
	@des 	: 获取额外提升属性  -- 3|54|50,3|55|50,5|54|50,5|55|50,7|54|50,7|55|50
	@param 	: 
	@return : 
--]]
function getExtraAffix( pIndex )
	local secFriendsData = DB_Secondfriends.getDataById(pIndex)
	return secFriendsData.extraAffix
end

--[[
	@des 	: 获取每级强化消耗  -- 2000  60040|2
	@param 	: 
	@return : 
--]]
function getEachLvCost( pNextLv )
	local LvCostData = DB_Secondfriends_levelup.getDataById(pNextLv)
	return tonumber(LvCostData.costsilver),LvCostData.costitems
end

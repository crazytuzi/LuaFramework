-- Filename：	FestivalActiveData.lua
-- Author：		Zhang Zihang
-- Date：		2015-1-9
-- Purpose：		节日活动数据层

module("FestivalActiveData", package.seeall)

require "script/ui/item/ItemUtil"

tagCopyDrop = 1
tagCompose = 2

local _composedNumInfo	--已合成次数的信息

--[[
	@des 	:得到活动类型
	@return :活动类型
--]]
function getActivityType()
	local returnType
	local gameType = tonumber(getDataInfo().tpye)
	if gameType == 1 then
		returnType = tagCopyDrop
	elseif gameType == 2 then
		returnType = tagCompose
	end

	return returnType
end

--[[
	@des 	:得到活动配置
	@return :活动配置
--]]
function getConfigInfo()
	return ActivityConfigUtil.getDataByKey("festival")
end

--[[
	@des 	:得到数据信息
	@return :数据信息
--]]
function getDataInfo()
	return getConfigInfo().data[1]
end

--[[
	@des 	:得到活动开始时间
	@return :开始时间戳
--]]
function getStartTime()
	local beginTime = getConfigInfo().start_time

	return beginTime
end

--[[
	@des 	:得到活动结束时间
	@return :结束时间戳
--]]
function getEndTime()
	local endTime = getConfigInfo().end_time

	return endTime
end

--[[
	@des 	:得到掉落物品信息
	@return :掉落物品信息
--]]
function getDropInfo()
	local dropInfo = getDataInfo().drop_view
	local returnTable = string.split(dropInfo,"|")

	return returnTable
end

--[[
	@des 	:得到合成物品信息
	@return :合成物品信息
--]]
function getComposeInfo()
	local returnTable = {}
	for i = 1,getFormulaNum() do
		local targetData = getDataInfo()["target" .. i]
		if targetData ~= nil and targetData ~= "" then
			local targetTable = string.split(targetData,"|")
			table.insert(returnTable,targetTable[1])
		end
	end

	return returnTable
end

--[[
	@des 	:得到活动福利描述
	@return :活动福利描述
--]]
function getActiveDes()
	local desString = getDataInfo().desc

	return string.gsub(desString, "\\n", "\n")
end

--[[
	@des 	:得到活动说明
	@return :活动说明
--]]
function getActiveExpl()
	local explString = getDataInfo().expl

	return string.gsub(explString, "\\n", "\n")
end

--[[
	@des 	:得到合成描述
	@return :合成描述
--]]
function getComposeDes()
	local composeString = getDataInfo().compose_desc

	return string.gsub(composeString, "\\n", "\n")
end

--[[
	@des 	:得到公式数量
	@return :公式信息
--]]
function getFormulaNum()
	return tonumber(getDataInfo()["compose_num"])
end

--[[
	@des 	:得到公式信息
	@return :公式信息
--]]
function getFormulaInfo()
	local formulaInfo = {}

	local formulaNum = getFormulaNum()

	for i = formulaNum,1,-1 do
		--如果公式不为空或nil，则
		local formulaData = getDataInfo()["formula" .. i]
		if not (formulaData == nil or formulaData == "") then
			--可合成数目
			local canComposeNum = 999999
			local innerTable = {}
			local formulaTable_1 = string.split(formulaData,",")
			--合成公式id
			innerTable.formulaId = i
			--公式数目
			innerTable.num = #formulaTable_1
			local maxComposeNum = getDataInfo()["max_num" .. i]
			--最大合成次数
			innerTable.maxNum = tonumber(maxComposeNum)
			--已合成次数
			innerTable.composedNum = getComposedNum(i)
			--公式物品信息
			innerTable.itemInfo = {}
			for j = 1,#formulaTable_1 do
				local itemInnerTable = {}
				local formulaTable_2 = string.split(formulaTable_1[j],"|")
				--公式物品tid
				itemInnerTable.id = tonumber(formulaTable_2[1])
				--公式物品需要数量
				itemInnerTable.num = tonumber(formulaTable_2[2])
				--当前背包中拥有的数量
				itemInnerTable.own = tonumber(ItemUtil.getCacheItemNumBy(itemInnerTable.id))

				local canNum = math.floor(itemInnerTable.own/itemInnerTable.num)
				canComposeNum = getLowerValue(canComposeNum,canNum)

				table.insert(innerTable.itemInfo,itemInnerTable)
			end

			--是否满足合成条件
			innerTable.isEnough = true
			--如果不满足合成条件，则isEnough为0
			if canComposeNum <= 0 then
				innerTable.isEnough = false
			end
			--总共可合成数目
			innerTable.totalComposeNum = canComposeNum

			local targetData = getDataInfo()["target" .. i]
			local targetTable = string.split(targetData,"|")
			innerTable.targetInfo = {}
			innerTable.targetInfo.id = tonumber(targetTable[1])
			innerTable.targetInfo.num = tonumber(targetTable[2])

			table.insert(formulaInfo,innerTable)
		end
	end

	return formulaInfo
end

--[[
	@des 	:返回较小的值
	@param 	: $ p_oldValue 		:一个值
	@param 	: $ p_newValue		:另一个值
	@return :较小的值
--]]
function getLowerValue(p_oldValue,p_newValue)
	local oldValue = tonumber(p_oldValue)
	local newValue = tonumber(p_newValue)

	return (oldValue < newValue) and oldValue or newValue
end

--[[
	@des 	:设置后端返回的合成信息
--]]
function setServiceComposeInfo(p_info)
	_composedNumInfo = p_info
end

--[[
	@des 	:得到已合成次数
	@param 	:公式id
	@return :已合成次数
--]]
function getComposedNum(p_index)
	local index = tostring(p_index)
	return (_composedNumInfo[index] == nil) and 0 or tonumber(_composedNumInfo[index])
end

--[[
	@des 	:设置合成数目
	@param 	: $ p_index 		: 公式id
	@param  : $ p_num 			: 修改的数量
--]]
function addComposeNum(p_index,p_num)
	local index = tostring(p_index)
	if _composedNumInfo[index] == nil then
		_composedNumInfo[index] = 0
	end
	_composedNumInfo[index] = p_num + _composedNumInfo[index]
end
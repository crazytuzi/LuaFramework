-- Filename: PetDescriptionData.lua
-- Author: ZQ
-- Date: 2014-07-07
-- Purpose: 处理宠物说明面板中的数据

module("PetDescriptionData",package.seeall)

local _descriptionString = nil
local _allPetInfoTable = nil

--[[
	@des:		设置宠物说明字符串
	@param:		p_descriptionString 宠物说明字符串
	@return:	none
--]]
function setDescriptionString(p_descriptionString)
	_descriptionString = p_descriptionString
end

--[[
	@des:		获得宠物说明字符串
	@param:		p_descriptionTable 宠物说明字符串
	@return:	none
--]]
function getDescriptionString()
	if _descriptionString == nil then
		require "db/DB_Pet_cost"
		_descriptionString = DB_Pet_cost.getDataById(1).description
	end
	print("setDescriptionString: %s",_descriptionString)
	return _descriptionString
end

--[[
	@des:		指定每行字数(或确定的文本框宽度及字体大小)获取字符串显示在文本框中时的行数
	@param:		p_descStr 需要显示的字符串
				p_wordsPerLineNum 指定每行字数
				p_wordSizeNum 指定字体大小
				p_fixedLineWidthNum 指定文本框的宽
	@return:	字符串显示在文本框中时的行数
--]]
function getStringToLineNumber(p_descStr, p_wordsPerLineNum, p_wordSizeNum, p_fixedLineWidthNum)
	-- 确定每行字数：p_fixedLineWidthNum / p_wordSizeNum 优先级高于 p_wordsPerLineNum
	local wordsPerLine = p_wordsPerLineNum
	if p_wordSizeNum ~= nil and p_fixedLineWidthNum ~= nil then
		wordsPerLine = math.floor(p_fixedLineWidthNum / p_wordSizeNum)
	end

	-- 每行字数默认为1
	if wordsPerLine < 1 then wordsPerLine = 1 end

	-- 统计行数
	local lineNumber = 1
	local wordNum = 0
	local wordIndex = 1
	while wordIndex <= #p_descStr do
		if string.byte(p_descStr,wordIndex) >127 then
			--汉字
			wordNum = wordNum + 1
			wordIndex = wordIndex + 3
		elseif string.byte(p_descStr,wordIndex) == 10 then
			--换行符
			wordNum = 0
			wordIndex = wordIndex + 1
			lineNumber = lineNumber + 1
		elseif string.byte(p_descStr,wordIndex) == 32 then
			--空格
			wordNum = wordNum + 1/3
			wordIndex = wordIndex + 1
		else
			--英文
			wordNum = wordNum + 1
			wordIndex = wordIndex +1
		end

		if wordNum == wordsPerLine then
			wordNum = 0
			lineNumber = lineNumber + 1
		elseif wordNum > wordsPerLine then
			--若每行字数3个，字符串“aa a”将计算为“aa ”＋“a”，字数10/3
			if string.byte(p_descStr,wordIndex-1) == 32 then
				wordNum = 1/3
			else
				wordNum = 1
			end
			lineNumber = lineNumber + 1
		else
		end
	end

	return lineNumber
end

--[[
	@des:		指定每行字数及字体大小获取显示字符串所需的文本框尺寸
	@param:		p_descStr 需要显示的字符串
				p_wordsPerLineNum 指定每行字数
				p_wordSizeNum 指定字体大小
				p_lineSpaceNum 指定行间距
	@return:	显示字符串所需的文本框尺寸
--]]
function getStringToLineDimensions(p_descStr, p_wordsPerLineNum, p_wordSizeNum)
	local lineNum = getStringToLineNumber(p_descStr, p_wordsPerLineNum)
	local width = p_wordsPerLineNum * p_wordSizeNum
	local height = (p_wordSizeNum + 2) * lineNum
	return CCSizeMake(width,height)
end

--[[
	@des:		设置所有宠物信息表
	@param:		p_table 所有宠物信息表
	@return:	none
--]]
function setAllPetInfoTable(p_table)
	_allPetInfoTable = p_table
end

--[[
	@des:		获得所有宠物信息表
	@param:		none
	@return:	所有宠物信息表
--]]
function getAllPetInfoTable()
	if _allPetInfoTable ~= nil then return _allPetInfoTable end

	_allPetInfoTable = {}
	local tempTable = nil
	require "db/DB_Pet"
	for i = 1,table.count(DB_Pet.Pet) do
		tempTable = DB_Pet.getDataById(i)
		--判断该宠物是否显示：1 显示 0 不显示
		if tempTable.handBook == 1 then
			table.insert(_allPetInfoTable, tempTable)
		end
	end

	local function sortFunc(object1, object2)
		return object1.id < object2.id
	end
	table.sort(_allPetInfoTable,sortFunc)

	return _allPetInfoTable
end

--[[
	@des:		根据宠物模版id及key获得对应的值
	@param:		p_tidNum 宠物模版id
				p_keyObj 键
	@return:	id为p_tidNum的宠物模版中键p_keyObj对应的值
--]]
function getValueByKeyForId(p_tidNum, p_keyObj)
	assert(_allPetInfoTable ~= nil)

	for _,v in pairs(_allPetInfoTable) do
		if v.id == p_tidNum then
			return v[p_keyObj]
			--return v.p_keyObj -- 会出错
		end
	end

	return nil
end

--[[
	@des:		将宠物模版中键“bookTips”对应的字符串格式化
	@param:		p_tidNum 宠物模版id
	@return:	如:	"通过副本指定据点获得|通过竞技场排名获得|通过比武排名获得"
					=> "1.通过副本指定据点获得\n2.通过竞技场排名获得\n3.通过比武排名获得"
--]]
function getTipString(p_tidNum)
	local sourceStr = getValueByKeyForId(p_tidNum, "bookTips")
	local stringTable = lua_string_split(sourceStr, "|")
	local targetStr = ""
	for i = 1,#stringTable do
		targetStr = targetStr .. i .. "." .. stringTable[i]
		if i ~= #stringTable then
			targetStr = targetStr .. "\n"
		end
	end
	return targetStr
end
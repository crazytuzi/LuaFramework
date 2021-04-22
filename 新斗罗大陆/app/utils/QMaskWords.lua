-- Author: qinyuanji
-- 2015/03/26
-- This class is to process masks

local QMaskWords = class("QMaskWords")
local QStaticDatabase = import("..controllers.QStaticDatabase")

local maskData = {}
local xiData = {{{},{},{}},{{},{},{}}}
xiData[1]["习"] = {index=1, isStart=true}
xiData[1]["刁"] = {index=1, isStart=true}
xiData[1]["进"] = {index=2}
xiData[1]["近"] = {index=2}
xiData[1]["瓶"] = {index=3, isEnd=true}
xiData[1]["平"] = {index=3, isEnd=true}
xiData[2]["xi"] = {index=1, isStart=true}
xiData[2]["xijin"] = {index=2, isStart=true}
xiData[2]["jin"] = {index=2}
xiData[2]["jinping"] = {index=2, isEnd=true}
xiData[2]["ping"] = {index=3, isEnd=true}
xiData[2]["xijinping"] = {index=4, isStart=true, isEnd=true}
table.insert(maskData, xiData)

local MARKS_RANGE=0

function QMaskWords:process(input, replace)
    local maskWords = QStaticDatabase:sharedDatabase():getMaskWords()

    local start = 0
    local lenth = string.len(input)
    for k, v in pairs(maskWords) do
    	if v.mask_word and lenth >= string.len(v.mask_word) then
            local index = string.find(input, v.mask_word)
            if index ~= nil then
        	    input = string.gsub(input, v.mask_word, replace)
            end
        end
    end

    return input
end

function QMaskWords:isFind(input)
	local maskWords = QStaticDatabase:sharedDatabase():getMaskWords()

    local lenth = string.len(input)
	for k, v in pairs(maskWords) do
		if v.mask_word and lenth >= string.len(v.mask_word) then
	        local index = string.find(input, v.mask_word)
	        if index ~= nil then
	        	return true
	        end
	    end
    end

    return false
end

function QMaskWords:clearSymbol(str)
    str = string.gsub(str, "[%s%p]+", "")
    return str
end

function QMaskWords:getMaskIndex(str, kind)
    for i,data in ipairs(maskData) do
        if kind == 1 then
            return data[1][str]
        elseif kind == 2 then
            if data[2][str] then
                return data[2][str]
            end
            for k,v in pairs(data[2]) do
                if string.find(str, k) then
                    return v
                end
            end
        end
    end
end

--[[
    屏蔽联想字库 @wkwang
    支持权重配置 MARKS_RANGE
    未完成版本，需要策划配置对应的量表
]]
function QMaskWords:findMaskWord(input)
    if input == nil then return end
    -- input = self:clearSymbol(input)
    local len = #input
    local i = 1
    local c,b
    local cutPos = 0
    local words = {}
    local chartType = 1
    local cutFun = function (pos, chartType)
        local data = {}
        data.value = string.sub(input, cutPos, pos)
        data.kind = chartType
        data.pos1 = cutPos
        data.pos2 = pos
        words[#words+1] = data
        cutPos = pos+1
    end
    while true do 
        c = string.sub(input,i,i)
        b = string.byte(c)
        if b > 128 then
            if chartType ~= 1 then
                cutFun(i-1, chartType)
            end
            chartType = 1
            cutFun(i+2, chartType)
            i = i + 3
        else
            if (b > 65 and b < 92) or (b > 97 and b < 124) then
                if chartType == 0 then
                    cutFun(i-1, chartType)
                end
                chartType = 2
            else
                if chartType == 2 then
                    cutFun(i-1, chartType)
                end
                chartType = 0
            end
            i = i + 1
        end
        if i > len then
            break
        end
    end
    local checkIndex = {}
    local order = 1
    for i,v in ipairs(words) do
        if v.kind ~= 0 then
            v.order = order
            order = order + 1
            local indexData = self:getMaskIndex(v.value, v.kind) 
            if indexData then
                v.isStart = indexData.isStart
                v.isEnd = indexData.isEnd
                if indexData.isStart then
                    if indexData.isEnd then
                        v.value = "*"
                    else
                        checkIndex[indexData.index] = v
                    end
                elseif checkIndex[indexData.index-1] ~= nil then
                    checkIndex[indexData.index] = v
                end
                if indexData.isEnd then
                    local index = indexData.index
                    local count = 0
                    local endOrder = v.order
                    while checkIndex[index] do
                        count = count+1
                        if checkIndex[index].isStart then
                            local distance = endOrder-checkIndex[index].order+1-count
                            -- local range = math.ceil(distance/(count-1))
                            if distance/(count-1) <= MARKS_RANGE then
                                while checkIndex[index] do
                                    local wordData = checkIndex[index]
                                    checkIndex[index] = nil
                                    wordData.value = "*"
                                    if wordData.isEnd then
                                        break
                                    end
                                    index = index+1
                                end
                            end
                            break
                        end
                        index = index-1
                    end
                end
            end
        end
    end
    local str = ""
    for i,v in ipairs(words) do
        str = str..v.value
    end
    return str
end

return QMaskWords
local MHSD_UTILS = require "utils.mhsdutils"
local LuaProtocolManager = require "manager.luaprotocolmanager"
local BeanConfigManager = require "manager.beanconfigmanager"
local SReqShenDiaoRoad = require "protocoldef.knight.gsp.sdzhaji.sreqshendiaoroad"

local SDZhiLuDataManager = {}

SDZhiLuDataManager.__index = SDZhiLuDataManager

SDZhiLuDataManager.DisplayData = nil

local ProrocolData = nil
local WordMap = nil

-- 遍历字符替换表查找对应字符串
local function GetStringFromeTableBayWordAndKey(word, key)
    key = tostring(key)
    local worldTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhiluzifu")
    local wordWholeTable = worldTable:getDisorderAllID()
    local haveGet = false
    for k,v in pairs(wordWholeTable) do
        local curConfig = worldTable:getRecorder(v)
        if curConfig.para == word and curConfig.ziduanneirong == key then
            return tostring(curConfig.wenzi)
        end
    end
    -- 错误：未找到匹配项
    if not haveGet then
        LogErr("unknown " ..word .. "-" .. key .. " in SDZhiLu")
        return nil
    end
end

-- 遍历字符替换表匹配字符串的替换配置
local function SetWordMapByTable(word, key, wordmap)
    if GetStringFromeTableBayWordAndKey(word, key) then
        wordmap[word] = GetStringFromeTableBayWordAndKey(word, key)
    else
        return
    end
end

-- 直接设置字符串替换配置
local function SetWordMapByValue(word, value, wordmap)
    wordmap[word] = tostring(value)
end

-- 读取WordMap
local function GetWordMap(word)
    if WordMap[word] ~= nil then
        return WordMap[word]
    else
        LogErr("unknown word " .. tostring(word) .. " at GetWordMap in SDZhiLu")
        return ""
    end
end

-- 返回解析后的字符串
local function GetFormatString(index)
    local contextTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhilupeizhi")
    local curConfig = contextTable:getRecorder(index)
    if curConfig ~= nil then
        local curString = curConfig.neirong
        for k,v in pairs(WordMap) do
            curString = string.gsub(curString, "%$" .. k .. "%$", v)
        end
        return curString
    else
        LogErr("unknown index " .. tostring(index) .. " at GetFormatString in SDZhiLu")
        return ""
    end
end

-- 添加页面
local s_curPage = 1
local function AddPage(table, corner, context, sort, time)

    local curConfig = {}
    curConfig.type = type
    curConfig.corner = ""
    curConfig.context = ""
    curConfig.time = 0
    curConfig.sort = 0


    curConfig.type = type
    curConfig.corner = corner
    curConfig.context = context
    curConfig.time = tonumber(time)
    curConfig.sort = tonumber(sort)

    table[s_curPage] = curConfig
    s_curPage = s_curPage + 1
end

local function SetProtocolData(protocol)
    -- SReqShenDiaoRoad 协议
    if protocol.type == SReqShenDiaoRoad.PROTOCOL_TYPE then
        ProrocolData = protocol
    end
end

local function MakeWordMap()
    if ProrocolData == nil then
        LogErr("Can not get protocol data at MakeWordMap in SDZhiLu")
        return
    end

    local contextTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhilupeizhi")

    --设置WordMap

        local newWordMap = {}

        -- rolename
        SetWordMapByValue("rolename", GetDataManager():GetMainCharacterName(), newWordMap)
        -- sumonlinetime
        SetWordMapByValue("sumonlinetime", ProrocolData.sumonlinetime, newWordMap)
        -- factionlevel
        SetWordMapByValue("factionlevel", ProrocolData.factionlevel, newWordMap)
        -- factionposition
        SetWordMapByTable("factionposition", ProrocolData.factionposition, newWordMap)
        -- factionctri
        SetWordMapByValue("factionctri", ProrocolData.factioncontri, newWordMap)
        -- factionname
        SetWordMapByValue("factionname", ProrocolData.factionname, newWordMap)
        -- marryto
        SetWordMapByValue("marryto", ProrocolData.marryto, newWordMap)
        -- tudi
        SetWordMapByValue("tudi", ProrocolData.tudi, newWordMap)
        -- shifu
        SetWordMapByValue("shifu", ProrocolData.shifu, newWordMap)
        -- jiebai
        for i=1, 4, 1 do
            if ProrocolData.jiebainames[i] ~= nil then
                SetWordMapByValue("jiebai" .. tostring(i), ProrocolData.jiebainames[i] .. MHSD_UTILS.get_resstring(3161), newWordMap)
            else
                SetWordMapByValue("jiebai" .. tostring(i), "", newWordMap)
            end
        end
        -- titletime 1-6
        for i=1, 6, 1 do
            if ProrocolData.titlenums[205+i] ~= nil then
                SetWordMapByValue("titletime" .. tostring(i), ProrocolData.titlenums[205+i], newWordMap)
            else
                SetWordMapByValue("titletime" .. tostring(i), "0", newWordMap)
            end
        end
        -- titletime7
        if ProrocolData.titlenums[150] ~= nil then
            SetWordMapByValue("titletime7", ProrocolData.titlenums[150], newWordMap)
        else
            SetWordMapByValue("titletime7", "0", newWordMap)
        end

        -- character
        SetWordMapByTable("character", GetDataManager():GetMainCharacterCreateShape(), newWordMap)
        -- schoolteacher
        SetWordMapByTable("schoolteacher", GetDataManager():GetMainCharacterSchoolID(), newWordMap)
        -- weapon
        SetWordMapByTable("weapon", GetDataManager():GetMainCharacterCreateShape(), newWordMap)
        -- special
        SetWordMapByTable("special", GetDataManager():GetMainCharacterSchoolID(), newWordMap)
        -- school
        SetWordMapByTable("school", GetDataManager():GetMainCharacterSchoolID(), newWordMap)
        -- zhenyingtiaojian
        SetWordMapByTable("zhenyingtiaojian", ProrocolData.camptitle, newWordMap)
        -- camp
        SetWordMapByTable("camp", ProrocolData.camp, newWordMap)

        -- 战队赛相关会重复出现，MakeDisplayData中处理

        WordMap = newWordMap
end

local function MakeDisplayData(protocol)
    if ProrocolData == nil then
        LogErr("Can not get protocol data at MakeDisplayData in SDZhiLu")
        return
    end
    if WordMap == nil then
        LogErr("Can not get wordmap data at MakeDisplayData in SDZhiLu")
        return
    end
    local contextTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhilupeizhi")

    local newDisplayData = {}
    s_curPage = 1

    -- 创建角色
    AddPage(newDisplayData, 
            MHSD_UTILS.intToDateTimeCN(ProrocolData.createtime), 
            GetFormatString(1), 
            contextTable:getRecorder(1).paixu)
    -- 加入门派
    AddPage(newDisplayData, 
            MHSD_UTILS.intToDateTimeCN(ProrocolData.createtime), 
            GetFormatString(2), 
            contextTable:getRecorder(2).paixu)
    -- 阵营
    if ProrocolData.camp ~= nil and ProrocolData.camp ~= 0 then
        AddPage(newDisplayData, 
                contextTable:getRecorder(3).youshangjiao, 
                GetFormatString(3), 
                contextTable:getRecorder(3).paixu)
    end
    -- 帮派
    if ProrocolData.factionname ~= nil and ProrocolData.factionname ~= "" then
        AddPage(newDisplayData, 
                contextTable:getRecorder(4).youshangjiao, 
                GetFormatString(4), 
                contextTable:getRecorder(4).paixu)
    end
    -- 结婚
    if ProrocolData.marrytime ~= nil and ProrocolData.marrytime > 0 then
         AddPage(newDisplayData, 
                MHSD_UTILS.intToDateTimeCN(ProrocolData.marrytime), 
                GetFormatString(5), 
                contextTable:getRecorder(5).paixu, 
                ProrocolData.marrytime)
    end
    -- 收徒
    if ProrocolData.shoututime ~= nil and ProrocolData.shoututime > 0 then
         AddPage(newDisplayData, 
                MHSD_UTILS.intToDateTimeCN(ProrocolData.shoututime), 
                GetFormatString(6), 
                contextTable:getRecorder(6).paixu, 
                ProrocolData.shoututime)
    end
    -- 拜师
    if ProrocolData.baishitime ~= nil and ProrocolData.baishitime > 0 then
         AddPage(newDisplayData, 
                MHSD_UTILS.intToDateTimeCN(ProrocolData.baishitime), 
                GetFormatString(7), 
                contextTable:getRecorder(7).paixu, 
                ProrocolData.baishitime)
    end
    -- 结拜
    if ProrocolData.jiebaitime ~= nil and ProrocolData.jiebaitime > 0 then
         AddPage(newDisplayData, 
                MHSD_UTILS.intToDateTimeCN(ProrocolData.jiebaitime), 
                GetFormatString(8), 
                contextTable:getRecorder(8).paixu, 
                ProrocolData.jiebaitime)
    end
    -- 称号
    for i=1, 7, 1 do
        if GetWordMap("titletime" .. tostring(i)) ~= nil and GetWordMap("titletime" .. tostring(i)) ~= "0" then
            AddPage(newDisplayData, 
                contextTable:getRecorder(i+8).youshangjiao,
                GetFormatString(i+8), 
                contextTable:getRecorder(i+8).paixu)
        end
    end

    -- 战队赛会重复出现
    for k,v in pairs(ProrocolData.factionpk) do
        AddPage(newDisplayData, 
                MHSD_UTILS.intToDateTimeCN(k),
                string.gsub(GetFormatString(16), "%$order%$", tostring(v)),
                contextTable:getRecorder(16).paixu,
                k)
    end

    for k,v in pairs(ProrocolData.cross) do
        AddPage(newDisplayData, 
                MHSD_UTILS.intToDateTimeCN(k),
                string.gsub(GetFormatString(17), "%$crossmingci%$", GetStringFromeTableBayWordAndKey("crossmingci", tostring(v))),
                contextTable:getRecorder(17).paixu,
                k)
    end

    -- 排序
    local function sortFunc(a ,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        else
            return a.time < b.time
        end
    end
    table.sort(newDisplayData, sortFunc)

    SDZhiLuDataManager.DisplayData = newDisplayData

end

function SDZhiLuDataManager.GetDisplayData(protocol)
    ProrocolData = nil
    SDZhiLuDataManager.DisplayData = nil
    WordMap = nil

    SetProtocolData(protocol)
    MakeWordMap()
    MakeDisplayData()
    return SDZhiLuDataManager.DisplayData
end

return SDZhiLuDataManager

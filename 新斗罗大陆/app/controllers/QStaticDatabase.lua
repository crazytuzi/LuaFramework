local QStaticDatabase = class("QStaticDatabase")

-- local QSQLiteDataBase = import(".QSQLiteDataBase")
local QActorProp = import("..models.QActorProp")
local QLogFile = import("..utils.QLogFile")

function QStaticDatabase:sharedDatabase()
	if app._database == nil then
        app._database = QStaticDatabase.new()
        GlobalVal["db"] = app._database
    end
    return app._database
end
--
local initProgressCallBack = nil
local loadEndCallBack = nil
function QStaticDatabase.setInitProgressFunc( callBack )
    -- body
    initProgressCallBack = callBack
end

function QStaticDatabase.setLoadEndFunc( callBack ) 
    -- body
    loadEndCallBack = callBack
end

function QStaticDatabase:ctor()
    self:loadStaticDatabase()
end

function QStaticDatabase:loadCalculatedDatabase()
    self._calculatedDatabase = {}
    self._calculatedDatabase["getStrengthenInfoByEquLevel"] = {}
    self:getStrengthenInfoByEquLevel(200)
    self._calculatedDatabase["calculateSuperSkill"] = {}
    self._calculatedDatabase["getTotalEnhancePropByLevel"] = {}

    local dungeon_config_by_int_id = {}
    for _, config in pairs(self._staticDatabase.dungeon_config or {}) do
        local int_id = config.int_id
        if int_id then
            dungeon_config_by_int_id[int_id] = config
        end
    end
    self._calculatedDatabase["dungeon_config_by_int_id"] = dungeon_config_by_int_id

    local glyphByIdAndLevel = {}
    for _, config in pairs(self._staticDatabase.glyph or {}) do
        local glyphById = {}
        glyphByIdAndLevel[config[1].glyph_id] = glyphById
        for j, levelConfig in ipairs(config) do
            glyphById[levelConfig.glyph_level] = levelConfig
        end
    end
    self._calculatedDatabase["glyphByIdAndLevel"] = glyphByIdAndLevel

    local skillDataByIdAndLevel = {}
    for _, config in pairs(self._staticDatabase.skill_data or {}) do
        local skillDataById = {}
        skillDataByIdAndLevel[config[1].id] = skillDataById
        local lastSkillData
        for j, levelConfig in ipairs(config) do
            if levelConfig.level then
                skillDataById[levelConfig.level] = levelConfig
            end
            lastSkillData = levelConfig
        end
        skillDataById[-1] = lastSkillData
    end
    self._calculatedDatabase["skillDataByIdAndLevel"] = skillDataByIdAndLevel
end

function QStaticDatabase:loadStaticDatabase()
    self:reloadStaticDatabase_Lua(function ( )
        -- body
        if IS_GO then
            self:_processGo()
        end

        self:loadCalculatedDatabase()

        if loadEndCallBack then
            loadEndCallBack()
        end
    end)
end

function QStaticDatabase:loadIndexFile()
    local index, timestamp = QStaticDatabase.loadIndex(CCFileUtils:sharedFileUtils():getFileData("static/index"))
    if timestamp then
        self._dic_version = string.sub(timestamp, 2)
    end
    return index
end

local hex_table = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
hex_table[0] = "0"
function QStaticDatabase.loadIndex(content)
    local index = {}
    local lines = string.split(content, "\n")
    local count = #lines
    local v2 = count > 0 and string.find(lines[1], "v2")
    if v2 then
        local key = string.trim(string.split(lines[2], " ")[2])
        QUtility:updateText(key)
        local bin = string.sub(content, string.len(lines[1]) + string.len(lines[2]) + 3)
        local cur = 1
        while true do
            local space_index = string.find(bin, "\n", cur, true)
            if space_index then
                local name = string.sub(bin, cur, space_index - 1)

                local md5 = string.sub(bin, space_index + 1, space_index + 1 + 15)
                local md5_str = ""
                for i = 1, string.len(md5) do
                    local c = string.byte(md5, i, i)
                    local h = math.floor(c / 16)
                    local l = c - h * 16
                    md5_str = md5_str .. hex_table[h] .. hex_table[l]
                end
                md5 = md5_str

                local size = string.sub(bin, space_index + 17, space_index + 17 + 3)
                -- little endian
                local size_number = 0
                for i = 1, string.len(size) do
                    local c = string.byte(size, i, i)
                    size_number = size_number + c * (256 ^ (i - 1))
                end
                size = size_number

                local gz = string.sub(bin, space_index + 21, space_index + 21 + 3)
                -- little endian
                local gz_number = 0
                for i = 1, string.len(gz) do
                    local c = string.byte(gz, i, i)
                    gz_number = gz_number + c * (256 ^ (i - 1))
                end
                gz = gz_number

                index[name] = {
                    name = name,
                    md5 = md5,
                    size = size,
                    gz = gz,
                    retry = 0
                }

                cur = space_index + 25
            else
                -- end parsing
                break
            end
        end
    else
        for _, line in ipairs(lines) do
            if line:sub(1, 5) == "#MD5:" then -- 杩欓噷鏄竴涓潪甯哥壒娈婄殑鍦版柟锛屽疄闄呯敤閫旀槸鐢ㄤ簬璁剧疆瑙ｅ瘑缃戠粶浼犺緭鐨刱ey
                local key = string.trim(string.split(line, " ")[2])
                QUtility:updateText(key)
                GlobalVal.NETWORK_KEY = key
            elseif line:sub(1, 1) ~= '#' then -- the first line is the time stamp
                line = string.trim(line)
                if string.len(line) > 0 then
                    local values = string.split(line, " ")

                    -- nzhang: 浠ラ槻鏂囦欢鍚嶆湁绌烘牸, 涓嶈兘搴斿澶氫釜绌烘牸杩炲湪涓�璧风殑鎯呭喌
                    local values_len = #values
                    local name_entry_number = values_len - 3
                    local name = values[1]
                    local count = 2
                    while count <= name_entry_number do
                        name = name .. " " .. values[count]
                        count = count + 1
                    end

                    index[name] = {
                        name = name,
                        md5 = values[name_entry_number + 1],
                        size = tonumber(values[name_entry_number + 2]),
                        gz = tonumber(values[name_entry_number + 3]),
                        retry = 0
                    }
                end
            end
        end
    end

    local timestamp = lines[1]
    return index, timestamp, count
end

local function shrinkStaticDatabase(db, chartenums, chartabbr)
    local enums = nil
    local enum2string, string2enum = nil, nil
    local abbr = nil

    local raw_db = db
    db = {}
    for chart_name, raw_chart in pairs(raw_db) do
        enums, enum2string, string2enum = nil, nil, nil
        if chartenums then
            enums = chartenums[chart_name]
            if enums then
                string2enum = enums
                enum2string = {}
                for prop, enumeration in pairs(string2enum) do
                    local obj = {}
                    for k, v in pairs(enumeration) do
                        obj[v] = k
                    end
                    enum2string[prop] = obj
                end
            end
        end

        abbr = chartabbr[chart_name]
        if abbr then
            for k, v in pairs(abbr) do
                abbr[k] = tostring(v)
            end

            local chart = {}
            local chart_colnames_bykey = {}
            local chart_colnames_byindex = {}
            local mt = {}
            for obj_key, raw_obj in pairs(raw_chart) do
                if #raw_obj > 0 then
                    local raw_arr = raw_obj
                    local arr = {}
                    for _, raw_obj in ipairs(raw_arr) do
                        for k, v in pairs(abbr) do
                            local value = raw_obj[v]
                            if value then
                                raw_obj[k] = value
                                raw_obj[v] = nil
                            end
                        end
                        table.insert(arr, q.shrinkObject(chart_colnames_bykey, chart_colnames_byindex, mt, raw_obj, enum2string, string2enum))
                    end
                    chart[obj_key] = arr
                else
                    for k, v in pairs(abbr) do
                        local value = raw_obj[v]
                        if value then
                            raw_obj[k] = value
                            raw_obj[v] = nil
                        end
                    end
                    chart[obj_key] = q.shrinkObject(chart_colnames_bykey, chart_colnames_byindex, mt, raw_obj, enum2string, string2enum)
                end
            end
            db[chart_name] = chart
        else
            local chart = {}
            local chart_colnames_bykey = {}
            local chart_colnames_byindex = {}
            local mt = {}
            for obj_key, raw_obj in pairs(raw_chart) do
                if #raw_obj > 0 then
                    local raw_arr = raw_obj
                    local arr = {}
                    for _, raw_obj in ipairs(raw_arr) do
                        table.insert(arr, q.shrinkObject(chart_colnames_bykey, chart_colnames_byindex, mt, raw_obj, enum2string, string2enum))
                    end
                    chart[obj_key] = arr
                else
                    chart[obj_key] = q.shrinkObject(chart_colnames_bykey, chart_colnames_byindex, mt, raw_obj, enum2string, string2enum)
                end
            end
            db[chart_name] = chart
        end
    end
    return db
end

function QStaticDatabase:getDicVersion()
    return self._dic_version
end

function QStaticDatabase:shrink()
    local chartenums, chartabbr
    local fileutil = CCFileUtils:sharedFileUtils()
    local enumeration_filepath = fileutil:fullPathForFilename("static/meta/enumeration")
    if fileutil:isFileExist(enumeration_filepath) then
        local content = fileutil:getFileData(enumeration_filepath)
        chartenums = json.decode(content)
    end
    local abbreviation_filepath = fileutil:fullPathForFilename("static/meta/abbreviation")
    if fileutil:isFileExist(abbreviation_filepath) then
        local content = fileutil:getFileData(abbreviation_filepath)
        chartabbr = json.decode(content)
    end

    self._staticDatabase = shrinkStaticDatabase(self._staticDatabase, chartenums, chartabbr)
    chartenums = nil
    chartabbr = nil
end

local function createChart(chartname)
    local fileUtil = CCFileUtils:sharedFileUtils()
    local zipName
    if IS_64_BIT_CPU == true then
        zipName = fileUtil:fullPathForFilename("static_lua/" .. chartname .. "_64.lua.zip")
    else
        zipName = fileUtil:fullPathForFilename("static_lua/" .. chartname .. ".lua.zip")
    end
    local t
    if fileUtil:isFileExist(zipName) == true then
        local content
        if IS_64_BIT_CPU == true then
            content = QUtility:decryptZipFile(zipName, chartname .. "_64.lua")
        else
            content = QUtility:decryptZipFile(zipName, chartname .. ".lua")
        end
        local f = loadstring(content)
        assert(f, function() return "local f = loadstring(content), f is nil, zipName is " ..  tostring(zipName) end)
        t = f()
        assert(t, function() return "t = f(), t is nil, zipName is " ..  tostring(zipName) .. ". f type is " .. type(f) .. ". count is " .. tostring(count) end)
        -- CCMessageBox(zipName, "")
    else
        t = import( "....res.static_lua." .. chartname)
    end

    -- 加个安全判断
    if type(t) ~= "table" then
        if device.platform == "android" or device.platform == "ios" then
            app:alert({title = "系统提示", content = "检测到游戏文件缺失，需要重新启动游戏更新文件~", callback = function()
                local wfile = io.open(CCFileUtils:sharedFileUtils():getWritablePath() .. "version", "wb")
                assert(wfile)
                wfile:write("nil")
                wfile:close()
                
                app:relaunchGame(true)
            end})
        end
        return
    end
    
    local charttable, __colnames, __colindices, __enum2string, __string2enum, __patterns = t[1], t[2], t[3], t[4], t[5], t[6]
    -- QSQLiteDataBase:sharedDatabase():createTableWithConfig(__colnames, charttable,chartname)
    local mt = q.getShrinkMetatable(__colindices, __colnames, __enum2string, __string2enum, __patterns, charttable)
    if next(charttable) then
        -- 因为已经shrink过，不能通过#obj>0判断是不是array，可以判断第一个元素是不是table类型来判断是不是array
        if type(charttable[next(charttable)][1]) == "table" then
            for _, obj in pairs(charttable) do
                for _, obj in ipairs(obj) do
                    setmetatable(obj, mt)
                end
            end
        else
            for _, obj in pairs(charttable) do
                setmetatable(obj, mt)
            end
        end
    end

    return charttable
end

function QStaticDatabase:reloadStaticDatabase_Lua(endCallback)
    -- q.disableDebugHook()

    self._initfuncs = {}
    self._initfuncs["story_line"] = function(chartname)
        return import("..tutorial.config.story_line", "app.controllers.QStaticDatabase")
    end
    self._initialized = {}
    self._staticDatabase = {}
    local __index = function(t, k)
        local value = self._initialized[k]
        if value == nil or type(value) ~= "table" or next(value) == nil then
            local func = self._initfuncs[k]
            self._initfuncs[k] = nil
            local chart = func and func() or createChart(k)
            self._initialized[k] = chart
            value = self._initialized[k]
        end
        return value
    end
    setmetatable(self._staticDatabase, {__index = __index})


    local fileUtil = CCFileUtils:sharedFileUtils()
    local count = 0
    -- print(string.format("LUA VM MEMORY USED BEFORE Load Database: %0.2f KB", collectgarbage("count")))
    local staticTable = self:loadIndexFile()
    local staticNames = {}

    for name,_ in pairs(staticTable) do
        count = count + 1
        table.insert( staticNames, name)
    end

    local totalCount = count > 0 and count or 99999
    self._totalCount = totalCount
    self._staticNames = staticNames
    self._curIndex = 0
    self._schedulerID = scheduler.scheduleUpdateGlobal(function ( )
        -- body
        if self._curIndex < self._totalCount then
            local max = self._curIndex + 10  > self._totalCount and self._totalCount or self._curIndex + 10
            for i=self._curIndex + 1, max do
                local name = self._staticNames[i]
                repeat
                    if not string.find(name, ".json") then
                        break
                    end

                    local str = string.sub(name, 1, string.find(name, ".json") - 1)
                    local chartname = string.sub(str, string.find(str, "/", -string.len(str)) + 1)
                    local zipName
                    if IS_64_BIT_CPU == true then
                        zipName = fileUtil:fullPathForFilename("static_lua/" .. chartname .. "_64.lua.zip")
                    else
                        zipName = fileUtil:fullPathForFilename("static_lua/" .. chartname .. ".lua.zip")
                    end
                    self._initfuncs[chartname] = function()
                        return createChart(chartname)
                    end
                until true
                if initProgressCallBack then
                    initProgressCallBack(i/self._totalCount)
                end
            end
            self._curIndex = self._curIndex + 10
        else
            self._staticNames = nil
            self._totalCount = 0
            self._curIndex = 0
            
            self._isArrayOfBuffData = true
            self._isArrayOfTrapData = false

            if app.sound ~= nil then
                app.sound:reloadSoundConfig()
            end

            self._initfuncs["animation_time"] = function()
                local animation_time = {}
                local fileUtils = CCFileUtils:sharedFileUtils()
                local filepath = "res/actor/animation_time"
                if fileUtils:isFileExist(fileUtils:getWritablePath()..filepath) then
                    filepath = fileUtils:getWritablePath()..filepath
                end
                local content = fileUtils:getFileData(filepath)
                local lines = string.split(content, "\n")
                local animationFile = nil
                local index = nil
                local time = nil
                local bytes = nil
                for _, line in ipairs(lines) do
                    if line ~= "" then
                        if string.sub(line, 1, 1) ~= ' ' then
                            bytes = {string.byte(line, 1, -1)}
                            if bytes[#bytes] == 13 then
                                line = string.sub(line, 1, #bytes - 1)
                            end
                            animationFile = {}
                            animation_time[line] = animationFile
                        else
                            index = string.find(line, "\"", 3, true)
                            time = tonumber(string.sub(line, index + 2))
                            animationFile[string.sub(line, 3, index - 1)] = {time}
                        end
                    end
                end
                local filepath = "res/actor/fca/animation_time"
                if fileUtils:isFileExist(fileUtils:getWritablePath()..filepath) then
                    filepath = fileUtils:getWritablePath()..filepath
                end
                local content = fileUtils:getFileData(filepath)
                local lines = string.split(content, "\n")
                local animationFile, action, len
                for _, line in ipairs(lines) do
                    if string.find(line, "^ ") then
                        action, len = string.match(line, [[^ "(.+)" ([^%s]+)]])
                        animationFile[action] = {tonumber(len), {}, {}, {}} -- length, atk, spd, loop
                        local idx1, idx2 = string.find(line, [[^ ".+" [^%s]+]])
                        idx2 = idx2 + 1
                        while true do
                            idx1, idx2 = string.find(line, [[[^%s]+]], idx2)
                            if idx1 == nil then
                                break
                            end
                            table.insert(animationFile[action][2], tonumber(string.sub(line, idx1, idx2)))
                            idx2 = idx2 + 1
                        end
                    elseif string.find(line, "^@sp") then
                        local idx1, idx2 = string.find(line, "^@sp ")
                        idx2 = idx2 + 1
                        while true do
                            idx1, idx2 = string.find(line, [[[^%s]+]], idx2)
                            if idx1 == nil then
                                break
                            end
                            table.insert(animationFile[action][3], tonumber(string.sub(line, idx1, idx2)))
                            idx2 = idx2 + 1
                        end
                    elseif string.find(line, "^@lp") then
                        local idx1, idx2 = string.find(line, "^@lp ")
                        idx2 = idx2 + 1
                        while true do
                            idx1, idx2 = string.find(line, [[[^%s]+]], idx2)
                            if idx1 == nil then
                                break
                            end
                            table.insert(animationFile[action][4], tonumber(string.sub(line, idx1, idx2)))
                            idx2 = idx2 + 1
                        end
                    else
                        animationFile = {}
                        animation_time["fca/"..string.match(line, "([a-zA-Z0-9%-_]*)")] = animationFile
                    end
                end
                return animation_time
            end

            if endCallback then
                endCallback()
            end

            if self._schedulerID then
                scheduler.unscheduleGlobal(self._schedulerID)
                self._schedulerID = nil
            end
        end
    end)
end


function QStaticDatabase:warmupRestStaticDatabase()
    local initfuncs = clone(self._initfuncs)
    local dum
    for chartname, _ in pairs(initfuncs) do
        dum = self._staticDatabase[chartname]
    end
end

-- @deprecated
function QStaticDatabase:reloadStaticDatabase()
    q.disableDebugHook()

    collectgarbage("collect")
    -- CCMessageBox("before_reload " .. tostring(collectgarbage("count")*1024), "")

    self._staticDatabase = {}

    local contents = {}

    local content = nil
    local fileUtil = CCFileUtils:sharedFileUtils()
    for name, _ in pairs(self:loadIndexFile()) do
        repeat
            if not string.find(name, ".json") then
                break
            end

            local zipName = fileUtil:fullPathForFilename(name .. ".zip")
            if fileUtil:isFileExist(zipName) == true then
                content = QUtility:decryptZipFile(zipName, name)
                if content ~= nil then
                    table.insert(contents, {content = content, name = name})
                    content = nil
                end
            else
                content = QUtility:decryptFile(name)
                if content ~= nil then
                    table.insert(contents, {content = content, name = name})
                    content = nil
                end
            end
        until true
    end

    for _, obj in ipairs(contents) do
        printInfo("decode json file:" .. obj.name)
        local subtable = json.decode(obj.content)
        assert(subtable ~= nil, function() return string.format("量表格式错误：%s", obj.name) end)
        table.merge(self._staticDatabase, subtable)

        obj.content = nil
        obj.name = nil
    end

    -- check buff_data is array or table
    -- skill_data and character_data are always an array
    self._isArrayOfBuffData = false
    for _, datas in pairs(self._staticDatabase.buff_data) do
        if datas[1] ~= nil then
            self._isArrayOfBuffData = true 
        end
        break
    end
    self._isArrayOfTrapData = false
    if self._staticDatabase.trap_data then
        for _, datas in pairs(self._staticDatabase.trap_data) do
            if datas[1] ~= nil then
                self._isArrayOfTrapData = true 
            end
            break
        end
    end

    collectgarbage("collect")
    -- CCMessageBox("before_shrink " .. tostring(collectgarbage("count")*1024), "")

    self:shrink()

    collectgarbage("collect")
    -- CCMessageBox("after_shrink " .. tostring(collectgarbage("count")*1024), "")

    if app.sound ~= nil then
        app.sound:reloadSoundConfig()
    end

    q.enableDebugHook()
end

function QStaticDatabase:filterNoneArrayTableByProperty(t, k, v)
    local results = {}
    for _, obj in pairs(self._staticDatabase[t]) do
        if obj[k] == v then
            results[#results + 1] = obj
        end
    end
    return results
end

function QStaticDatabase:getConfiguration()
    return self._staticDatabase.configuration
end

function QStaticDatabase:getConfigurationValue(key)
    local obj = self._staticDatabase.configuration[key]
    return obj and obj.value
end

function QStaticDatabase:getArenaAward(rank)
    local vector = self:sharedDatabase()._staticDatabase.arena_awards
    if vector == nil then
        return
    end
    for i, v in pairs(vector) do
        -- local low = string.split(v.condition, ":")
        -- local high = nil
        -- if #low == 1 then
        --     high = low[1]
        --     low = high
        -- else
        --     high = low[2]
        --     low = low[1]
        -- end
        local low = v.rank_lower
        local high = v.rank_upper
        if rank <= tonumber(high) and rank >= tonumber(low) then
            return v, low, high
        end
    end
end

--閲戦挶浣撳姏璐拱閰嶇疆
function QStaticDatabase:getTokenConsumeByType(typeName)
    if typeName == nil then return nil end
    local vector = self:sharedDatabase()._staticDatabase.token_consume
    return vector[tostring(typeName)]
end

function QStaticDatabase:getTokenConsume(type, time)
    local vector = self:sharedDatabase()._staticDatabase.token_consume
    for _, good in ipairs(vector[type]) do
        if good.type == type and good.consume_times == time then
            return good, true
        end
    end
    return vector[type][#vector[type]], false
end
--config.award_type_exp 缁忛獙
--config.award_type_money 閲戦挶
--config.award_type_token_money 浠ｅ竵
--config.award_type_team_exp 鍥㈤槦缁忛獙
--config.award_type_item 鐗╁搧
function QStaticDatabase:getConfig()
    return global.config
end

-- return game tips from the id of dungeon @qinyuanji
function QStaticDatabase:getGameTipsByID(dungeon_id)
    if dungeon_id == nil then return nil end

    return self._staticDatabase.gametips[dungeon_id]
end

-- return game tips from the level of gametips_universal @qinyuanji
function QStaticDatabase:getGameTipsByLevel(level)
    if not level then return nil end

    local config = self._staticDatabase.gametips_universal
    if config == nil then return nil end
    for _, value in pairs(config) do
        if value[1].minlevel <= level and level <= value[1].maxlevel then
            return value
        end
    end

    return nil
end

-- return random names @qinyuanji
function QStaticDatabase:getNamePlayers()
    return self._staticDatabase.name_players
end

--------head_default---------
-- return default avatars and frames @qinyuanji
-- type=1 头像 
-- type=2 头像框
-- type=3 宗门头像
-- type=4 宗门头像框
-- type=5 底座
-- type=6 称号

-- User's avatar
function QStaticDatabase:getDefaultAvatarIcon()
    return self:getDefaultAvatar().icon
end

function QStaticDatabase:getDefaultAvatar()
    if self._defaultAvatar then
        return self._defaultAvatar
    else
        local avatars = {}
        for k, v in pairs(self:getAvatars(1)) do
            table.insert(avatars, v)
        end
        table.sort(avatars, function (x, y)
            return x.id < y.id
        end)
        self._defaultAvatar = avatars[1]
        return self._defaultAvatar
    end
end

function QStaticDatabase:getDefaultAvatars()
    return self:getAvatars(1)
end

function QStaticDatabase:getAvatars(function_type)
    local avatars = {}
    for k, v in pairs(self._staticDatabase.head_default) do
        if function_type then
            if v.function_type == function_type and v.type == 1 then
                avatars[v.id] = v
            end
        else
            if v.type == 1 then
                avatars[v.id] = v
            end
        end
    end

    return avatars
end

-- User's frame
function QStaticDatabase:getDefaultFrameIcon()
    return self:getDefaultFrame().icon
end

function QStaticDatabase:getDefaultFrame()
    if self._defaultFrame then
        return self._defaultFrame
    else
        local frames = self:getFrames()
        self._defaultFrame = frames[10000]
        return self._defaultFrame
    end
end

function QStaticDatabase:getFrames(function_type)
    local frames = {}
    for k, v in pairs(self._staticDatabase.head_default) do
        if function_type then
            if v.function_type == function_type and v.type == 2 then
                frames[v.id] = v
            end
        else
            if v.type == 2 then
                frames[v.id] = v
            end
        end
    end
    return frames
end

function QStaticDatabase:getFramesByindexId(function_type,indexid)
    local frames = {}
    for k, v in pairs(self._staticDatabase.head_default) do
        if function_type then
            if v.function_type == function_type and v.type == 2 and indexid == v.index_id then
                frames[v.id] = v
            end
        else
            if v.type == 2 then
                frames[v.id] = v
            end
        end
    end
    return frames
end
-- User's hero base
function QStaticDatabase:getDefaultHeroBaseIcon()
    return self:getDefaultHeroBase().icon
end

function QStaticDatabase:getDefaultHeroBase()
    if self._defaultHeroBase then
        return self._defaultHeroBase
    else
        local heroBases = {}
        for k, v in pairs(self:getHeroBase()) do
            table.insert(heroBases, v)
        end
        table.sort(heroBases, function (x, y)
            return x.id < y.id
        end)

        self._defaultHeroBase = heroBases[1]
        return self._defaultHeroBase
    end
end

function QStaticDatabase:getHeroBase(function_type)
    local heroBases = {}
    for k, v in pairs(self._staticDatabase.head_default) do
        if function_type then
            if v.function_type == function_type and v.type == 5 then
                heroBases[v.id] = v
            end
        else
            if v.type == 5 then
                heroBases[v.id] = v
            end
        end
    end

    return heroBases
end

-- hero`s title
function QStaticDatabase:getHeroTitle(function_type)
    local heroTitle = {}
    for k, v in pairs(self._staticDatabase.head_default) do
        if function_type then
            if v.function_type == function_type and v.type == 6 then
                heroTitle[v.id] = v
            end
        else
            if v.type == 6 then
                heroTitle[v.id] = v
            end
        end
    end

    return heroTitle
end

-- Union's icon
function QStaticDatabase:getDefaultUnionIcon()
    return self:getDefaultUnion().icon
end

function QStaticDatabase:getDefaultUnion()
    if self._defaultUnion then
        return self._defaultUnion
    else
        local unions = {}
        for k, v in pairs(self:getUnionIcons()) do
            table.insert(unions, v)
        end
        table.sort(unions, function (x, y)
            return x.id < y.id
        end)

        self._defaultUnion = unions[1]
        return self._defaultUnion
    end
end

function QStaticDatabase:getUnionIcons(function_type)
    local icons = {}
    for k, v in pairs(self._staticDatabase.head_default) do
        if v.type == 3 then
            if function_type ~= nil then
                if v.function_type == function_type then
                    icons[v.id] = v
                end
            else
                icons[v.id] = v
            end
        end
    end

    return icons
end

-- Union's frame
function QStaticDatabase:getDefaultUnionFrameIcon()
    return self:getUnionFrames()[110000].icon
end

function QStaticDatabase:getDefaultUnionFrame()
    return self:getUnionFrames()[110000]
end

function QStaticDatabase:getUnionFrames(function_type)
    local frames = {}
    for k, v in pairs(self._staticDatabase.head_default) do
        if function_type then
            if v.function_type == function_type and v.type == 4 then
                frames[v.id] = v
            end
        else
            if v.type == 4 then
                frames[v.id] = v
            end
        end
    end

    return frames
end

function QStaticDatabase:getHeadDefaults()
    return self._staticDatabase.head_default
end

function QStaticDatabase:getHeadInfoById(id)
    return self._staticDatabase.head_default[tostring(id)]
end

--------head_default---------

function QStaticDatabase:getBlackSoulSpirt(id)
    return self._staticDatabase.blackrock_soul_spirit[tostring(id)]
end
function QStaticDatabase:getBlackChapterSoulSpirt()
    return self._staticDatabase.blackrock_chapter_soul_spirit
end
function QStaticDatabase:getCharacter()
    return self._staticDatabase.character
end

function QStaticDatabase:getCharacterIDs()
    return table.keys(self._staticDatabase.character)
end

function QStaticDatabase:getCharacterByID(id)
    if id == nil then return nil end
    
    local obj = self._staticDatabase.character[tostring(id)]
    assert(obj, function() return "character id:" .. tostring(id) .. " not exist" end)
    obj.display_id = obj.id
    return obj
end

function QStaticDatabase:getCharacterData(id, dataType, npcDifficulty, npcLevel)
    assert(dataType, function() return id .. "\'s data_type is a nil value" end)
    if npcDifficulty ~= nil and npcLevel == nil or npcDifficulty == nil and npcLevel ~= nil then
        assert(false, function() return id .. " invalid value: npc_difficulty and npc_level" end)
        return nil
    end

    local datas = self._staticDatabase.character_data[tostring(dataType)]
    if datas == nil then
        assert(datas, function() return "data_type:" .. dataType .. " not exist" end)
        return nil
    end

    if npcDifficulty == nil and npcLevel == nil then
        -- hero
        return datas[1]
    else
        -- npc
        for _, data in ipairs(datas) do
            if (npcDifficulty == "" or data.npc_difficulty == npcDifficulty) and data.npc_level == npcLevel then
                return data
            end
        end
        assert(false, function() return "faild to find character data with data_type:" .. 
            tostring(dataType) .. " npc_difficulty:" .. tostring(npcDifficulty) .. " npc_level:" .. tostring(npcLevel) end)
        return nil
    end
end

function QStaticDatabase:getCharacterDataByID(id, level)
    local dataType = self:getCharacterByID(id).data_type
    for _, data in ipairs(self._staticDatabase.character_data[tostring(dataType)]) do
        if tonumber(data.npc_level) == tonumber(level) then
            return data
        end
    end

    return self._staticDatabase.character_data[tostring(dataType)][#self._staticDatabase.character_data[tostring(dataType)]]
end

-- deprecated
function QStaticDatabase:getCharacterDisplayIds()
    return table.keys(self._staticDatabase.character)
end

-- deprecated
function QStaticDatabase:getCharacterDisplayByID(id)
    if id == nil then return nil end

    return self._staticDatabase.character[tostring(id)]
end

function QStaticDatabase:getMonstersById(id)
    return self._staticDatabase.dungeon_monster[id]
end

function QStaticDatabase:insertMonster(id, tbl)
    if self._staticDatabase.dungeon_monster[id] == nil then
        self._staticDatabase.dungeon_monster[id] = {}
        table.insert(self._staticDatabase.dungeon_monster[id], tbl)
    else
        table.insert(self._staticDatabase.dungeon_monster[id], tbl)
    end
end

function QStaticDatabase:clearMonstersById(id)
    self._staticDatabase.dungeon_monster[id] = nil
end

--[[
    @id, dugeon id
    @npcsHp, 副本怪物保存血量结构体，npcsHp[i] = {actorId = xxx, currHp = yyy, currMp = zzz}
]]
function QStaticDatabase:calculateDungeonHpPercent(id, npcsHp)
    if self._staticDatabase.dungeon_config[id] == nil then
        return
    end
    local monsters = self._staticDatabase.dungeon_monster[self._staticDatabase.dungeon_config[id].monster_id]
    if monsters == nil then
        return
    end
    local hpMax = 0
    local hpLeft = 0
    local models = {}
    for index, monster in ipairs(monsters) do
        if monster.wave > 0 then
            local modelId = tostring(monster.npc_id)..tostring(monster.npc_difficulty)..tostring(monster.npc_level)
            local model = models[modelId] or app:createNpc(monster.npc_id, monster.npc_difficulty, monster.npc_level)
            models[modelId] = model
            local hp = model:getMaxHp()
            hpMax = hpMax + hp
            local currHp = nil
            for _, obj in ipairs(npcsHp or {}) do
                if obj.actorId == index then
                    if obj.currHp == -2 then -- not created yet
                        currHp = hp
                    elseif obj.currHp == -1 then -- dead
                        currHp = 0
                    else
                        currHp = obj.currHp
                    end
                    break
                end
            end
            currHp = currHp or hp
            hpLeft = hpLeft + currHp
        end
    end
    models = nil
    if hpMax > 0 then
        return hpLeft / hpMax
    else
        return 0
    end
end

--鍏冲崱鎺夎惤
function QStaticDatabase:getDungeonAwardByID(id)
    if id == nil then
        return nil
    end
    for _,config in pairs(self:sharedDatabase()._staticDatabase.dungeon_awards) do
        if config.id == id then
            return config
        end
    end
    return nil
end

--鑾峰彇鍦板浘閰嶇疆
function QStaticDatabase:getMaps()
    return self._staticDatabase.map_config
end

--转换mapid
function QStaticDatabase:convertMapID(id)
    if id == nil then return nil end
    if type(id) == "number" then
        for _,value in pairs(self._staticDatabase.map_config) do
            if value.int_instance_id == id then
                return value.instance_id
            end
        end
    else
        for _,value in pairs(self._staticDatabase.map_config) do
            if value.instance_id == id then
                return value.int_instance_id
            end
        end
    end
end

function QStaticDatabase:convertUserId(id)
    if id == nil then return nil end

    for _,value in pairs(self._staticDatabase.head_default) do
            if value.index_id == id and value.type == 1 and value.function_type == 2 then
                return value.id
            end
    end
end
--转换用户头像
function QStaticDatabase:convertUserIcon(icon)
    if icon == nil then return nil end
    if type(icon) == "number" then
        for _,value in pairs(self._staticDatabase.head_default) do
            -- nzhang: add "value.type == 1 and value.function_type == 2 and " due to http://jira.joybest.com.cn/browse/WOW-9167
            if value.type == 1 and value.function_type == 2 and value.id == icon then
                return value.icon
            end
        end
    else
        for _,value in pairs(self._staticDatabase.head_default) do
            -- nzhang: add "value.type == 1 and value.function_type == 2 and " due to http://jira.joybest.com.cn/browse/WOW-9167
            if value.type == 1 and value.function_type == 2 and value.icon == icon then
                return value.id
            end
        end
    end
end

function QStaticDatabase:convertUserIconToId(icon)
    if icon == nil then return nil end
    if type(icon) ~= "number" then
        for _,value in pairs(self._staticDatabase.head_default) do
            if value.icon == icon then
                return value.id
            end
        end
    end

    return icon
end

function QStaticDatabase:getMapAchievement(instanceID)
     if instanceID == nil then return nil end
     return self._staticDatabase.map_achievement[instanceID]
end

function QStaticDatabase:getLuckyDraw(index)
     if index == nil then return nil end
     return self._staticDatabase.lucky_draw[index]
end

function QStaticDatabase:getLuckyDrawAwardTable(index)
    if index == nil then return nil end

    local data = self._staticDatabase.lucky_draw[index]
    local awardList = {}
    local index = 1
    while data["type_"..index] do
        table.insert(awardList, {id = data["id_"..index], itemType = data["type_"..index], count = data["num_"..index]})
        index = index + 1
    end

    return awardList
end

function QStaticDatabase:getDungeonConfigByID(id)
    if id == nil then return nil end
    return q.cloneShrinkedObject(self._staticDatabase.dungeon_config[id])
end

function QStaticDatabase:getDungeonConfigByIntID(intId)
    if intId == nil then return nil end
    return self._calculatedDatabase.dungeon_config_by_int_id[intId]
end

function QStaticDatabase:convertDungeonID(id)
    if id == nil then return nil end
    if type(id) == "number" then
        local dungeon_config_by_int_id = self._calculatedDatabase["dungeon_config_by_int_id"]
        if dungeon_config_by_int_id[id] then
            return dungeon_config_by_int_id[id].id
        else
            for k, config in pairs(self._staticDatabase.dungeon_config) do
                if config.int_id == id then
                    return config.id
                end
            end
        end
    else
        return self._staticDatabase.dungeon_config[id].int_id
    end
end

function QStaticDatabase:getDungeonTargetByID(id)
    if id == nil then return nil end
    return self._staticDatabase.dungeon_target[id]
end

--鎴樻枟鍔涢厤缃�
function QStaticDatabase:getForceConfigByLevel(level)
    if level == nil then return nil end
    for _,value in pairs(self._staticDatabase.force) do
        if value.level == level then
            return value
        end
    end
    local count = #self._staticDatabase.force
    return self._staticDatabase.force[count]
end

-- 计算单个属性带来的战斗力提高 @qinyuanji
function QStaticDatabase:getBattleForceBySingleAttribute(attribute, value, level)
    if value == 0 then return 0 end

    local config = self:getForceConfigByLevel(level)
    local force = 0
    if config ~= nil then
        force = value * config[attribute]
    end

    return force
end

--绐佺牬閰嶇疆
-- 绐佺牬 澶╄祴 瑁呭閰嶇疆
function QStaticDatabase:getBreakthroughByTalentLevel(talentID,level)
    if talentID == nil or level == nil or self._staticDatabase.breakthrough[talentID] == nil then return nil end
    for _, config in pairs(self._staticDatabase.breakthrough[talentID]) do 
        if config.breakthrough_level == level then
            return config
        end
    end
    return nil
end

--鏍规嵁澶╄祴鑾峰彇绐佺牬
function QStaticDatabase:getBreakthroughByTalent(talentID)
    if talentID == nil then return nil end
    return self._staticDatabase.breakthrough[talentID]
end

--获取突破表
function QStaticDatabase:getBreakthrough()
    return self._staticDatabase.breakthrough
end

function QStaticDatabase:getGemstoneEvolution(gemstoneId)
    if gemstoneId == nil then return nil end
    local gemStonedInfo = {}
    for _, config in pairs(self._staticDatabase.gemstone_evolution) do
        if config.gem_id == gemstoneId then
            table.insert(gemStonedInfo,config)
        end
    end
    table.sort(gemStonedInfo, function(a,b)
        return tonumber(a.evolution_level) < tonumber(b.evolution_level)
    end )
    return gemStonedInfo
end

function QStaticDatabase:getRefineConfigByIdAndLevel(gemstoneId , lv)
    local  configs = self._staticDatabase.gemstone_refine[tostring(gemstoneId)]
    for i,v in ipairs(configs or {}) do
        if tonumber(v.level) == lv then
            return v
        end
    end
    return nil
end

function QStaticDatabase:getGemstoneMixConfigByIdAndLv(gemstoneId , lv)
    local  configs = self._staticDatabase.gemstone_mix[tostring(gemstoneId)]
    for i,v in ipairs(configs or {}) do
        if tonumber(v.mix_level) == lv then
            return v
        end
    end
    return nil
end

function QStaticDatabase:getGemstoneMixSuitConfigByData(id , suitNum , level)
    local configs = self._staticDatabase.gemstone_suit[tostring(id)]
    -- QPrintTable(configs)
    for k,v in pairs(configs or {}) do
        -- QPrintTable(v)
        if v.suit_num == suitNum and v.level == level then
            return v
        end
    end
    return nil
end

function QStaticDatabase:getGemstoneEvolutionBygodLevel(itemId,godLevel)
    local gemstoneInfo = self:getGemstoneEvolution(itemId)
    if gemstoneInfo then
        for _,v in pairs(gemstoneInfo or {}) do
            if tonumber(v.evolution_level) == godLevel then
               return v
            end
        end
    end
    return nil
end


function QStaticDatabase:getGemstoneMixSuitSkillByGemstones(gemstones)
    local resultIds = {}

    local mixSuit = {}
    for _,gemstone in ipairs(gemstones) do
        local mixConfig = self:getGemstoneMixConfigByIdAndLv(gemstone.itemId , gemstone.mix_level or 0)
        if mixConfig and mixConfig.gem_suit and gemstone.mix_level then
            if not mixSuit[mixConfig.gem_suit] then
                mixSuit[mixConfig.gem_suit] = {}
                mixSuit[mixConfig.gem_suit].mixLevelTbl  = {}
            end
            table.insert(mixSuit[mixConfig.gem_suit].mixLevelTbl , tonumber(gemstone.mix_level) )
        end
    end

    if  next(mixSuit) ~= nil then
        local finSuit = {}
       
        for key,value in pairs(mixSuit) do
            local gemSuit = key
            local suitNum = #value.mixLevelTbl
            if suitNum > 1 then
                table.sort( value.mixLevelTbl, function(a, b)
                        return a > b
                    end)
            end
            for i= 1, suitNum do
                local minLevel = value.mixLevelTbl[i]
                if finSuit[i] == nil then
                    finSuit[i] = {gemSuit = gemSuit ,minLevel = minLevel }
                elseif finSuit[i].minLevel < minLevel or (finSuit[i].minLevel == minLevel and finSuit[i].gemSuit > gemSuit) then
                    finSuit[i] = {gemSuit = gemSuit ,minLevel = minLevel }
                end
            end
        end

        for i,v in pairs(finSuit) do
            local suitConfigs = self:getGemstoneMixSuitConfigByData(v.gemSuit ,i , v.minLevel ) 
            if suitConfigs and suitConfigs.suit_skill then
                local skillStr = suitConfigs.suit_skill
                local skillIds = string.split(skillStr, ";")
                for k,id in ipairs(skillIds or {}) do
                    table.insert(resultIds , id)
                end
            end
        end
    end

    return resultIds
end


function QStaticDatabase:getGemstoneGodSkillByGemstones(gemstones,is_new ,cur_godlevel)--is_new 判定是否是新激活的套装技能 --cur_godlevel 判断是否是当前等级触发的套装
    local stones_num = #gemstones
    if stones_num < 4 then return nil end -- 未满四件不成套装 退出
    local skill_level = 99
    local gemstoneInfo_ss = nil
    local gem_evolution_new_set = -1
    local gemstoneInfo_ss_bef = nil


    for _,gemstone in ipairs(gemstones) do
        local beyond_god_lv = (gemstone.godLevel or 0) - GEMSTONE_MAXADVANCED_LEVEL 
        if beyond_god_lv < 1 then return nil end -- 有非化神魂骨 退出
        skill_level = math.min(skill_level, (gemstone.godLevel or 0))
        gemstoneInfo_ss = self:getGemstoneEvolutionBygodLevel(gemstone.itemId,skill_level)
        gemstoneInfo_ss_bef= self:getGemstoneEvolutionBygodLevel(gemstone.itemId,skill_level - 1)
        if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
            if gem_evolution_new_set == -1 then
                gem_evolution_new_set = gemstoneInfo_ss.gem_evolution_new_set
            elseif gem_evolution_new_set ~= gemstoneInfo_ss.gem_evolution_new_set then -- 不成四件套 退出
                return nil 
            end
        else
            return nil
        end
    end


    local new_skill = true 
    local cur_skill = true 

    if is_new ~= nil then
        new_skill = gemstoneInfo_ss_bef and gemstoneInfo_ss.gem_god_skill ~= gemstoneInfo_ss_bef.gem_god_skill
    end

    if cur_godlevel ~= nil then
        cur_skill = gemstoneInfo_ss and gemstoneInfo_ss.evolution_level == cur_godlevel
        print("cur_godlevel     ".. cur_godlevel)
        print("gemstoneInfo_ss.evolution_level      ".. gemstoneInfo_ss.evolution_level )
    end

    if gemstoneInfo_ss and cur_skill and new_skill then
        return gemstoneInfo_ss.gem_god_skill
    end

    return nil
end


function QStaticDatabase:getGemstoneEvolutionAllPropBygodLevel(itemId,godLevel)
    local gemstoneInfo = self:getGemstoneEvolution(itemId)
    local gemstoneEvolution = {}
    if gemstoneInfo then
        for _,v in pairs(gemstoneInfo) do
            if tonumber(v.evolution_level) <= godLevel then
               table.insert(gemstoneEvolution,v)
            end
        end
    end
    return gemstoneEvolution
end

function QStaticDatabase:getGemstoneEvolutionSkillIdBygodLevel(itemId,godLevel)
    local gemstoneInfo = self:getGemstoneEvolution(itemId)
    
    local advancedSkillId, godSkillId = nil,nil
    if gemstoneInfo then
        for index,v in pairs(gemstoneInfo) do
            local compareLevel = tonumber(v.evolution_level)
            if compareLevel > godLevel then
                break
            end

            if v.gem_evolution_skill then
                if godLevel <= GEMSTONE_MAXADVANCED_LEVEL then
                    advancedSkillId = v.gem_evolution_skill
                    godSkillId = nil
                else
                    if compareLevel == GEMSTONE_MAXADVANCED_LEVEL then
                        advancedSkillId = v.gem_evolution_skill
                    end
                    godSkillId = v.gem_evolution_skill
                end
            end
        end
    end
    return advancedSkillId, godSkillId
end

--鏍规嵁鑻遍泟ID鑾峰彇绐佺牬
function QStaticDatabase:getBreakthroughByActorId(actorId)
    if actorId == nil then return nil end
    local heroConfig = self:getCharacterByID(actorId)
    return self:getBreakthroughByTalent(heroConfig.talent)
end

--鏍规嵁鑻遍泟ID鑾峰彇绐佺牬鑻遍泟灞炴�ч厤缃�
function QStaticDatabase:getBreakthroughHeroByActorId(actorId)
    if actorId == nil then return nil end
    return self._staticDatabase.breakthrough_hero[tostring(actorId)]
end

-- 突破 魂师 加成配置
function QStaticDatabase:getBreakthroughHeroByHeroActorLevel(actorId,level)
    if actorId == nil or level == nil or self._staticDatabase.breakthrough_hero[tostring(actorId)] == nil then return nil end
    for _, config in pairs(self._staticDatabase.breakthrough_hero[tostring(actorId)]) do 
        if config.breakthrough_level == level then
            return config
        end
    end
    return nil
end

--进阶配置
-- 进阶 魂师 加成配置
function QStaticDatabase:getGradeByHeroActorLevel(actorId,level)
    if q.isEmpty(self._staticDatabase.grade) then return nil end
    if actorId == nil or level == nil or self._staticDatabase.grade[tostring(actorId)] == nil then return nil end
    for _, config in ipairs(self._staticDatabase.grade[tostring(actorId)]) do 
        if config.grade_level == level then
            return config
        end
    end
    return nil
end

function QStaticDatabase:getMaxGradeByHeroActor(actorId)
    if actorId == nil or self._staticDatabase.grade[tostring(actorId)] == nil then return 0 end
    local result = 0
    for _, config in ipairs(self._staticDatabase.grade[tostring(actorId)]) do 
        if config.grade_level > result then
            result = config.grade_level
        end
    end
    return result
end


function QStaticDatabase:getGradeByHeroId(actorId)
    return self._staticDatabase.grade[tostring(actorId)]
end

function QStaticDatabase:getActorIdBySoulId(soul_gem)
    for _, config in pairs(self._staticDatabase.grade) do 
       if config[1].soul_gem == tonumber(soul_gem) then
          return config[1].id
       end
    end
end

function QStaticDatabase:getNeedSoulByHeroActorLevel(actorId,level)
    if actorId == nil or level == nil or self._staticDatabase.grade[tostring(actorId)] == nil then return nil end
    local need = 0
    for i=0,level,1 do
        local config = self:getGradeByHeroActorLevel(actorId,i)
        need = need + config.soul_gem_count
    end
    return need
end

--鏍规嵁鑻遍泟纰庣墖ID鑾峰彇鑻遍泟褰撳墠绐佺牬绛夌骇鎵�闇�鏈�澶х鐗囨暟
function QStaticDatabase:getGradeNeedMaxSoulNumByHeroSoulId(soul_gem)
    local actorId = nil
    if soul_gem == nil then return nil end
    actorId = self:getActorIdBySoulId(soul_gem)
    local soulNum = nil
    local heroIsHave = false
    local haveHerosID = remote.herosUtil:getHaveHero()
    for _, value in pairs(haveHerosID) do
        if value == actorId then
          heroIsHave = true
        end
    end
    if heroIsHave == false then
        local heroInfo = self:getCharacterByID(actorId)
        soulNum = self:getNeedSoulByHeroActorLevel(actorId, (heroInfo.grade or 0))
    else
        local heroInfo = remote.herosUtil:getHeroByID(actorId)
        local config = self:getGradeByHeroActorLevel(actorId, (heroInfo.grade or 0)+1)
        if config ~= nil then
            soulNum = config.soul_gem_count
        end
    end
    return soulNum
end

--鐗╁搧閰嶇疆
function QStaticDatabase:getItemByID(itemId)
    if itemId == nil then return nil end
    itemId = tostring(itemId)
    return self._staticDatabase.item[itemId]
end

--鐗╁搧閰嶇疆
function QStaticDatabase:getItemsByCategory( ... )
    local data = {...}
    local items = {}
    for k, v in pairs(self._staticDatabase.item) do
        
        local isHave = false
        for _, value in pairs(data) do
            if v.category == value then
                isHave = true
                break
            end
        end
        if isHave then
            items[#items+1] = v
        end
    end
    return items
end

--根据物品属性获取物品集合
function QStaticDatabase:getItemsByProp(prop, value)
    -- TOFIX: SHRINK
    if prop == nil then 
        local ret = {}
        for k, v in pairs(self._staticDatabase.item) do
            ret[k] = v
        end
        return ret
    end
    local items = {}
    for _,item in pairs(self._staticDatabase.item) do
        if item[prop] ~= nil then
            if value ~= nil then
                if item[prop] == value then
                    table.insert(items, item)
                end
            else
                if type(item[prop]) == "number" then
                    if item[prop] > 0 then
                        table.insert(items, item)
                    end
                else
                    table.insert(items, item)
                end
            end
        end
    end
    return items
end

--获取合成配置
function QStaticDatabase:getItemCraft()
    return self._staticDatabase.item_craft
end

--根据物品Id和前置ID获取合成配置
function QStaticDatabase:getItemCraftByItemId(itemId)
    if itemId == nil then return nil end
    itemId = tostring(itemId)
    return self._staticDatabase.item_craft[itemId]
end

function QStaticDatabase:getSkillByActorAndSlot(actorId, slot)
    local slotConfig = self._staticDatabase.skill_slot[tostring(actorId)]
    if slotConfig ~= nil then
        return slotConfig["slot_"..slot]
    end
    return nil
end

function QStaticDatabase:getSkillSlotConfigByActor(actorId)
    return self._staticDatabase.skill_slot[tostring(actorId)]
end

function QStaticDatabase:getSkillByID(id)
    if id == nil then return nil end

    -- TOFIX: SHRINK
    local skill = q.cloneShrinkedObject(self._staticDatabase.skill[tostring(id)])
    if skill ~= nil then
        if skill.skill_cast ~= nil and self._staticDatabase.skill_cast[tostring(skill.skill_cast)] ~= nil then
            local obj = q.cloneShrinkedObject(self._staticDatabase.skill_cast[tostring(skill.skill_cast)])
            obj.id = nil
            table.merge(skill, obj)
        end
        if skill.skill_animation ~= nil and self._staticDatabase.skill_animation[tostring(skill.skill_animation)] ~= nil then
            local obj = q.cloneShrinkedObject(self._staticDatabase.skill_animation[tostring(skill.skill_animation)])
            obj.id = nil
            table.merge(skill, obj)
        end
    else
        printInfo("skill id : ".. id .. " is nil !")
    end

    return skill
end

function QStaticDatabase:getSkillGroupBySkillId(skillId)
    local skillName = nil 
    local skillGroup = {}

    skillId = tostring(skillId)

    local skillDatas = self._staticDatabase.skill_data[skillId]
    if skillDatas ~= nil then
        skillGroup = skillDatas
    end

    return skillGroup
end

function QStaticDatabase:getSound()
    return self._staticDatabase.sound
end

function QStaticDatabase:getSoundById(id)
    if id == nil then return nil end
    return self._staticDatabase.sound[id]
end

-- this function is inefficiently
-- Never use it in game
function QStaticDatabase:getSkillsByName(name)
    if name == nil then return nil end

    local skillIds = {}
    for _, skillInfo in pairs(self._staticDatabase.skill) do
        if skillInfo.name == name then
            table.insert(skillIds, skillInfo.id)
        end
    end
    return skillIds
end

function QStaticDatabase:getSkillsInfoByName(name)
    if name == nil then return nil end

    local skills = {}
    for _, skillInfo in pairs(self._staticDatabase.skill) do
        if skillInfo.name == name then
            local skill = self:getSkillByID(skillInfo.id)
            if skill ~= nil then
                table.insert(skills, skill)
            end
        end
    end
    return skills
end

function QStaticDatabase:getSkillDataByIdAndLevel(id, level)
    if id == nil or id == 0 or level == nil then return nil end

    local skillDataByIdAndLevel = self._calculatedDatabase["skillDataByIdAndLevel"]
    if skillDataByIdAndLevel then
        local skillDataById = skillDataByIdAndLevel[tonumber(id)]
        if skillDataById then
            return skillDataById[level] or skillDataById[-1] -- lastSkillData
        end
    end

    local skillDatas = self._staticDatabase.skill_data[tostring(id)]
    assert(skillDatas, function() return "faild to find skill data by id:" .. id end)

    local skillData = nil
    local lastSkillData = nil
    for _, data in ipairs(skillDatas) do
        lastSkillData = data
        if data.level == level then
            skillData = data
            break
        end
     end

    return skillData or lastSkillData
end

function QStaticDatabase:getSkillDataByIdAndLevel_Strict(id, level)
    if id == nil or level == nil then return nil end

    local skillDatas = self._staticDatabase.skill_data[tostring(id)]
    assert(skillDatas, function() return "faild to find skill data by id:" .. id end)

    local skillData = nil
    for _, data in ipairs(skillDatas) do
        if data.level == level then
            skillData = data
            break
        end
     end

    return skillData
end

function QStaticDatabase:parseSkillDescription(description, level)
    local function parseText(text)
        local parts = string.split(text, ",")
        if #parts ~= 4 then
            return ""
        end
        if parts[1] == "skillID" then
            local id = tonumber(parts[2])
            local skill = self:getSkillByID(id)
            if skill == nil then
                return ""
            end
            local skill_data = self:getSkillDataByIdAndLevel(id, level)
            if skill_data == nil then
                return ""
            end
            local skill_data_high = self:getSkillDataByIdAndLevel(id, level + 1)
            local value = skill_data[parts[3]] or skill[parts[3]]
            local value_high = (skill_data_high and skill_data_high[parts[3]]) or skill[parts[3]]
            value_high = value_high or value
            return q.evaluateFormula(parts[4], {value = value, difference_value = value_high - value})
        elseif parts[1] == "buffID" then
            local id = parts[2]
            local buff = self:getBuffByID(id)
            if buff == nil then
                return ""
            end
            local buff_data = self:getBuffDataByIdAndLevel(id, level)
            if buff_data == nil then
                return ""
            end
            local buff_data_high = self:getBuffDataByIdAndLevel(id, level + 1)
            local value = buff_data[parts[3]] or buff[parts[3]]
            local value_high = (buff_data_high and buff_data_high[parts[3]]) or buff[parts[3]]
            value_high = value_high or value
            return q.evaluateFormula(parts[4], {value = value, difference_value = value_high - value})
        end
    end

    local result = ""
    local index = 1
    local length = string.len(description)
    while index <= length do
        local find1 = string.find(description, "#", index, true)
        if find1 then
            result = result .. string.sub(description, index, find1 - 1)
            local find2 = string.find(description, "#", find1 + 1, true)
            if find2 then
                result = result .. parseText(string.sub(description, find1 + 1, find2 - 1))
                index = find2 + 1
            else
                result = result .. string.sub(description, index)
                break
            end
        else
            result = result .. string.sub(description, index)
            break
        end
    end

    return result
end

function QStaticDatabase:getBuffByID(id)
    if id == nil then return nil end

    return self._staticDatabase.buff[id]
end

function QStaticDatabase:getBuffDataByIdAndLevel(id, level)
    if id == nil or level == nil then return nil end

    local buffDatas = self._staticDatabase.buff_data[id]

    assert(buffDatas, "faild to find buff data by id:" .. tostring(id))

    local buffData = nil
    if self._isArrayOfBuffData == true then
        for _, data in ipairs(buffDatas) do

            if data.level == nil then
                data.level = 1
            end
        
            if data.level == level then
                buffData = data
                break
            end
        end
    else
        local data = buffDatas

        if data.level == nil then
            data.level = 1
        end

        if data.level == level then
            buffData = data 
        else
            assert(false, function() return "faild to find buff data by id:" .. tostring(id) .. " and level:" .. tostring(level) end)
        end
    end

    return buffData 
end

function QStaticDatabase:getTrapByID(id)
    if id == nil then return nil end

    return self._staticDatabase.trap[id]
end

function QStaticDatabase:isTrapDataEnabled()
    return self._staticDatabase.trap_data ~= nil
end

function QStaticDatabase:getTrapDataByIdAndLevel(id, level)
    if self._staticDatabase.trap_data == nil then
        return nil
    end

    if id == nil or level == nil then return nil end

    local trapDatas = self._staticDatabase.trap_data[id]
    assert(trapDatas, function() return "failed to find trap data by id:" .. tostring(id) end)

    local trapData = nil
    if self._isArrayOfTrapData == true then
        for _, data in ipairs(trapDatas) do

            if data.level == nil then
                data.level = 1
            end
        
            if data.level == level then
                trapData = data
                break
            end
        end
        assert(trapData ~= nil, function() return "failed to find trap data by id:" .. tostring(id) .. " and level:" .. tostring(level) end)
    else
        local data = trapDatas

        if data.level == nil then
            data.level = 1
        end

        if data.level == level then
            trapData = data 
        else
            assert(false, function() return "failed to find trap data by id:" .. tostring(id) .. " and level:" .. tostring(level) end)
        end
    end

    return trapData 
end

--鍐涜閰嶇疆 鏍规嵁鍐涜Code鑾峰彇鍐涜閰嶇疆
function QStaticDatabase:getRankConfigByCode(rankCode)
    if rankCode == nil then return nil end
    for _,config in pairs(self._staticDatabase.rank) do
        if config.code == rankCode then
            return config
        end
    end
    return nil
end

function QStaticDatabase:getRankConfig()
    return self._staticDatabase.rank
end

--鎴橀槦缁忛獙 绛夌骇閰嶇疆
function QStaticDatabase:getTeamLevelByExperience(experience)
    local level = 1
    -- TBD: binary search 
    for k, el in pairs(self._staticDatabase.team_exp_level) do
        level = el.level
        if experience < el.exp then
            break
        end
    end
    return level
end

function QStaticDatabase:getExperienceByTeamLevel(level)
    if level == nil then return nil end 
    -- TBD: binary search 
    local exp = 1
    for k, el in pairs(self._staticDatabase.team_exp_level) do
        if level == el.level then
            exp = el.exp
            break
        end
    end
    return exp
end

function QStaticDatabase:getTeamConfigByTeamLevel(level)
    if level == nil then return nil end 
    for k, el in pairs(self._staticDatabase.team_exp_level) do
        if level == el.level then
            return el
        end
    end
    return nil
end

function QStaticDatabase:getLevelByExperience(experience)
    local level = 1
    -- TBD: binary search 
    local exp_level = table.sort(self._staticDatabase.exp_level)
    for _, el in pairs(self._staticDatabase.exp_level) do
        level = el.level
        if experience < el.exp then
            break
        end
    end
    return level
end

function QStaticDatabase:getExperienceByLevel(level)
    if level == nil then return nil end 
    -- TBD: binary search 
    local exp = 1
    return self._staticDatabase.exp_level[tostring(level)].exp or 1
end

function QStaticDatabase:getTotalExperienceByLevel(level)
    if level == nil then return 0 end 
    -- TBD: binary search 
    local exp = 0
    for k, el in pairs(self._staticDatabase.exp_level) do
        if level > el.level then
            exp = exp + el.exp
        end
    end
    return exp
end

function QStaticDatabase:getLevelCoefficientByLevel(level)
    if level == nil then return nil end

    return self._staticDatabase.level_coefficient[level]
end

function QStaticDatabase:getEffectIds()
    return table.keys(self._staticDatabase.effect)
end

function QStaticDatabase:getLevelRewardInfoById(id)
    if not id then return nil end
    return self._staticDatabase.level_reward[tostring(id)]
end
--获取商店npc对话
function QStaticDatabase:getShopTalk(shop_id, talk_type)
    if shop_id == nil or self._staticDatabase.shop_talk[shop_id] == nil then return nil end
    local talkWord = {}
    for k, talks in pairs(self._staticDatabase.shop_talk[shop_id]) do
        if talks.event == talk_type then
            talkWord = talks
            break
        end
    end

    local words = {}
    local index = 1
    while talkWord["talk"..index] ~= nil do
        local word = string.split(talkWord["talk"..index], "^")
        if word[2] == nil then
            words[#words+1] = word[1]
        elseif remote.user.level < tonumber(word[1]) then
            words[#words+1] = word[2]
        end
        index = index + 1
    end
    return words
end

function QStaticDatabase:getRandomInvasionYell()
    local number = table.nums(self._staticDatabase.shop_talk["10001"][1]) - 2
    local random = math.random(number)
    return self._staticDatabase.shop_talk["10001"][1]["talk" .. random]
end

function QStaticDatabase:getShopNpcInfo(shopId)
    if shopId == nil or self._staticDatabase.shop_talk[shopId] == nil then return nil end
    
    return self._staticDatabase.shop_talk[shopId]
end

--根据商店ID获取商店信息
function QStaticDatabase:getShopDataByID(shopId)
    return self._staticDatabase.shop[shopId] or nil
end

--根据商店ID获取商店刷新时间
function QStaticDatabase:getGeneralShopRefreshTimeByID(shopId)
    if self._staticDatabase.shop[shopId] == nil then return nil end
    return self._staticDatabase.shop[shopId].refresh_times
end

--根据当前年月获取签到奖励表
function QStaticDatabase:getDailySignInItmeByMonth(date)
  return self._staticDatabase.check_in[date]
end

--根据当前签到次数获取奖励表
function QStaticDatabase:getAddUpSignInItmeByMonth(signNum, signAward)
  	local data = {}
  	local awards = {}
    
    local index = 1
    for _, value in pairs(self._staticDatabase.check_in_add) do
        data[index] = value
        index = index + 1
    end
    table.sort( data, function(a, b) return a.times < b.times end )

  	for i = 1, #data do
  		if data[i].times > signAward and data[i].times <= signNum then
  			awards = data[i]
  			break
        elseif data[i].times == signAward and data[i].times <= signNum then
            awards = data[i+1] or {}
            break
  		end
  	end

    if awards == nil or next(awards) == nil then
        if signAward == 0 then
            awards = data[1]
        else
            awards = data[#data]
        end
    end

  	return awards
end

--姣忔棩浠诲姟
function QStaticDatabase:getTask()
    return self._staticDatabase.tasks
end

--根据任务ID获取任务
function QStaticDatabase:getTaskById(taskId)
    if taskId == nil then return {} end
    
    return self._staticDatabase.tasks[tostring(taskId)] or {}
end

--根据任务类型获取任务
function QStaticDatabase:getTaskByType(taskType)
    if taskType == nil then return {} end

    local tasks = {}
    for _, value in pairs(self._staticDatabase.tasks) do
        if value.task_type == taskType then
            tasks[#tasks+1] = value
        end
    end

    return tasks
end

-- mark effect value
function QStaticDatabase:getEffectFileByID(id)
    if id == nil then return nil end

    if self._staticDatabase.effect[id] == nil then
        assert(false, function() return "effect id: " .. id .. " is not found" end)
        return nil, nil
    end
    return self._staticDatabase.effect[id].file, self._staticDatabase.effect[id].file_back
end

function QStaticDatabase:getEffectScaleByID(id)
    if id == nil then return nil end

    local scale = self._staticDatabase.effect[id].scale
    if scale == nil then
        scale = 1.0
    end
    return scale
end

function QStaticDatabase:getEffectPlaySpeedByID(id)
    if id == nil then return nil end

    local playSpeed = self._staticDatabase.effect[id].play_speed
    if playSpeed == nil then
        playSpeed = 1.0
    end
    return playSpeed
end

function QStaticDatabase:getEffectOffsetByID(id)
    if id == nil then return 0, 0 end

    local offsetX = self._staticDatabase.effect[id].offset_x
    local offsetY = self._staticDatabase.effect[id].offset_y
    if offsetX == nil then
        offsetX = 0.0
    end
    if offsetY == nil then
        offsetY = 0.0
    end
    return offsetX, offsetY
end

function QStaticDatabase:getEffectRotationByID(id)
    if id == nil then return nil end

    local rotation = self._staticDatabase.effect[id].rotation
    if rotation == nil then
        rotation = 0.0
    end
    return rotation
end

function QStaticDatabase:getEffectIsFlipWithActorByID(id)
    if id == nil then return true end
    local is_flip_with_actor = self._staticDatabase.effect[id].is_flip_with_actor
    if is_flip_with_actor == nil then
        return true
    else 
        return is_flip_with_actor
    end
end

function QStaticDatabase:getEffectDummyByID(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].dummy
end

function QStaticDatabase:getEffectIsLayOnTheGroundByID(id)
    if id == nil then return false end

    if self._staticDatabase.effect[id].is_lay_on_the_ground == true then
        return true
    else
        return false
    end
end

function QStaticDatabase:getEffectDelayByID(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].delay
end

function QStaticDatabase:getEffectSoundIdById(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].audio_id
end

function QStaticDatabase:getEffectSoundStopByID(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].audio_stop
end

function QStaticDatabase:getEffectIsHSIEnabledById(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].is_hsi_enabled
end

function QStaticDatabase:getEffectHueById(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].hue
end

function QStaticDatabase:getEffectSaturationById(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].saturation
end

function QStaticDatabase:getEffectintensityById(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id].intensity
end

function QStaticDatabase:getEffectConfigByID(id)
    if id == nil then return nil end

    return self._staticDatabase.effect[id]
end

--鑾峰彇閿欒鐮�
function QStaticDatabase:getErrorCode(code)
    return self._staticDatabase.errorcode[code]
end

-- get dungeon hero config
function QStaticDatabase:getDungeonHeroByIndex(index)
    for _,value in pairs(self._staticDatabase.dungeon_hero) do
        if tonumber(value.id) == tonumber(index) then
            return value
        end
    end
    return nil
end

--根据斗魂场排名获取相应的奖励
function QStaticDatabase:getAreanRewardByRank(rank, level)
    if rank == nil or level == nil then return end
    local minlevel = self:getAreanRewardConfigByRank(rank,level)
    if minlevel ~= nil then
        local rankItemInfo = self._staticDatabase.lucky_draw[minlevel.lucky_draw]
        if self._staticDatabase.pvp_rank_reward[tostring(tonumber(minlevel.ID) - 1)] ~= nil then
            return rankItemInfo, minlevel.rank, self._staticDatabase.pvp_rank_reward[tostring(tonumber(minlevel.ID) - 1)].rank + 1
        else
            return rankItemInfo, minlevel.rank
        end
    end
    return nil
end

--根据斗魂场排名获取奖励配置
function QStaticDatabase:getAreanRewardConfigByRank(rank, level)
    if rank == nil or level == nil then return end
    local minlevel = nil
    for _,value in pairs(self._staticDatabase.pvp_rank_reward) do
        if value.level_min <= level and value.level_max >= level and rank <= value.rank then
            if minlevel == nil then
                minlevel = value
            elseif minlevel.rank > value.rank then
                minlevel = value
            end
        end
    end
    return minlevel
end

--根据云顶之战排名获取相应的奖励
function QStaticDatabase:getSotoTeamRewardById(id)
    local pvp_rank_reward = self._staticDatabase.pvp_rank_reward
    local lucky_draw = self._staticDatabase.lucky_draw
    return lucky_draw[pvp_rank_reward[tostring(id)].soto_team_lucky_draw]
end

--根据云顶之战赛季全区排名获取相应的奖励
function QStaticDatabase:getSotoTeamSeasonRewardById(id)
    local pvp_rank_reward = self._staticDatabase.pvp_rank_reward
    local lucky_draw = self._staticDatabase.lucky_draw
    return lucky_draw[pvp_rank_reward[tostring(id)].soto_team_competition_season_lucky_draw]
end

--根据等级获取奖励配置
function QStaticDatabase:getRewardConfigByLevel(level)
    if level == nil then return {} end
    local tbl = {}
    for _,value in pairs(self._staticDatabase.pvp_rank_reward) do
        if value.level_min <= level and value.level_max >= level then
            table.insert(tbl, value)
        end
    end
    return tbl
end


--根据胜场次数获得大师赛积分奖励
function QStaticDatabase:getMockBattleScoreRewardById(id ,seasonType)
    seasonType = seasonType and seasonType or 1
    for _,value in pairs(self._staticDatabase.mock_battle_reward) do
        if value.type ==1 and value.condition == id and value.season_type == seasonType then
            return value.score
        end
    end
    return 0
end

--根据首次胜场次数获得大师赛首胜奖励
function QStaticDatabase:getMockBattleFirstWinRewardById(id,seasonType)
    seasonType = seasonType and seasonType or 1
    for _,value in pairs(self._staticDatabase.mock_battle_reward) do
        if value.type ==3 and value.condition == id and value.season_type == seasonType then
            return value.rewards
        end
    end
    return nil
end

function QStaticDatabase:getGloryTowerRewardByRank(floor)
    local tower_rank_reward = self._staticDatabase.tower_rank_reward
    local lucky_draw = self._staticDatabase.lucky_draw
    
    for _, value in pairs(tower_rank_reward) do
        if value.floor == floor then
            return lucky_draw[value.lucky_draw]
        end
    end
    local rankNums = table.nums(tower_rank_reward)
    return lucky_draw[tower_rank_reward[tostring(rankNums)].lucky_draw]
end

function QStaticDatabase:getGloryTowerRewardByID(ID)
    local tower_rank_reward = self._staticDatabase.tower_rank_reward
    local lucky_draw = self._staticDatabase.lucky_draw
    return lucky_draw[tower_rank_reward[tostring(ID)].lucky_draw]
end

function QStaticDatabase:getSunwellMap()
    return self._staticDatabase.sunwell_map
end

function QStaticDatabase:getSunwellMapConfigByIndex(index)
    for _,value in pairs(self._staticDatabase.sunwell_map) do
        if value.wave == index then
            return value
        end
    end
end

function QStaticDatabase:getSunwellAwardsByIndex(index)
    return self._staticDatabase.sunwell_reward[tostring(index)]
end

function QStaticDatabase:getSunwellStarAwards()
    return self._staticDatabase.sunwell_star_reward
end

function QStaticDatabase:getAnnouncement(index)
    if index ~= nil then
        return self._staticDatabase.announcement[index]
    else
        return self._staticDatabase.announcement
    end
end
function QStaticDatabase:getVIP()
    return self._staticDatabase.vip
end

function QStaticDatabase:getUnlockVIPLevelByName(name)
    local minLevel = nil
    if name ~= nil then
        for _,value in pairs(self._staticDatabase.vip) do
            if value[name] == true then
                if minLevel == nil or value.vip < minLevel then
                    minLevel = value.vip
                end
            end
        end
    end
    return minLevel or 0
end

function QStaticDatabase:getVipContnentByVipLevel(vipLevel)
    if vipLevel == nil then return end
   
    return self._staticDatabase.vip[tostring(vipLevel)]
end

function QStaticDatabase:getMaxVipContnent()
    local vipLevel = table.nums(self._staticDatabase.vip) - 1 --vip 从0开始
    return self._staticDatabase.vip[tostring(vipLevel)]
end

function QStaticDatabase:getEnhanceDataByEquLevel(data, level)
    if data == nil then return end
    local enhanceData = self._staticDatabase.enhance_data[tostring(data)]
    if level == 0 then
        return enhanceData[1]
    end

    if level > enhanceData[#enhanceData]["enhance_level_max"] then
        return enhanceData[#enhanceData]
    end
  
    for _, value in pairs(enhanceData) do
        if value["enhance_level_min"] <= level and value["enhance_level_max"] >= level then
            return value
        end
    end
end

function QStaticDatabase:getTotalEnhancePropByLevel(enhanceId, level)
    local cache = self._calculatedDatabase["getTotalEnhancePropByLevel"]
    local cacheId = enhanceId * 10000 + level
    if cache[cacheId] then
        return cache[cacheId]
    end

    if enhanceId == nil then return nil end
    local enhanceData = self._staticDatabase.enhance_data[tostring(enhanceId)]
    assert(enhanceData, function() return "enhanceId: "..enhanceId.." can't find in enhance_data config!" end)
    local _enhance = {}
    local enhance = nil
    for i = 1,level,1 do
        if enhance == nil or enhance.enhance_level_min > i or enhance.enhance_level_max < i then
            enhance = nil
            for _, value in ipairs(enhanceData) do
                if value.enhance_level_min <= i and value.enhance_level_max >= i then
                    enhance = value
                    break
                end
            end
        end
        if enhance ~= nil then
            for key,value in pairs(enhance) do
                if _enhance[key] == nil then
                    _enhance[key] = value
                else
                    _enhance[key] = _enhance[key] + value
                end
            end
        end
    end
    cache[cacheId] = _enhance

    return _enhance
end

function QStaticDatabase:getTotalEnchantPropByLevel(itemId, level, actorId)
    local enchantConfig = self:getEnchant(itemId, level, actorId)
    enchantConfig = q.cloneShrinkedObject(enchantConfig)
    return enchantConfig
end

function QStaticDatabase:getStrengthenInfoByEquLevel(level)
  if level == nil then return end

  local results = self._calculatedDatabase["getStrengthenInfoByEquLevel"]
  local result = results[level]
  if result then
    return result
  end

  local money = 0
  for _, value in pairs(self._staticDatabase.enhance) do
    local enhance_level = value["enhance_level"]
    if enhance_level == level then
        result = value.money or 0
        results[level] = result
      return result
    elseif enhance_level ~= nil then
        results[enhance_level] = value.money or 0
    end
    if money <= value.money then 
        money = value.money
    end
  end
  results[level] = money
  return money
end

function QStaticDatabase:getStrengthenReturnMoney(level)
    level = level or 1

    local totalMoney = 0
    for _, value in pairs(self._staticDatabase.enhance) do
        if value.enhance_level <= level then
            totalMoney = totalMoney + value.money_recover
        end
    end

    return totalMoney
end

-- 根据饰品的强化等级获取升级所需经验
function QStaticDatabase:getJewelryStrengthenInfoByLevel(level)
  if level == nil then return end
  for _, value in pairs(self._staticDatabase.enhance_advanced) do
    if value["enhance_level"] == level then
      return value
    end
  end
  return nil
end

-- 根据饰品的强化等级获取升级所需全部经验
function QStaticDatabase:getJewelryStrengthenTotalExpByLevel(level, index, expType)
    local totalExp = 0
    level  = level or 0
    index = 1 --@qinyuanji, wow-6308

    for _, value in pairs(self._staticDatabase.enhance_advanced) do
        if value["enhance_level"] <= level then
            totalExp = totalExp + (value[expType .. index] or 0)
        end
    end

    return totalExp
end

--根据魂师突破等级获取当前魂师装备强化上限
function QStaticDatabase:getMaxStrengthenLevelByHeroLevel(level)
    if level == nil then return 0 end
    if level >= 0 and level < 2 then
        return 1
    end

    local index = 0 
    local maxLevel = {}
    local maxValue = {}
    for _, value in pairs(self._staticDatabase.enhance) do
        index = index + 1
        if value["breakthrough"] == level then
            table.insert(maxValue, value.enhance_level)
        end
    end
    if maxValue[1] ~= nil then
        local max = 0
        for _, v in pairs(maxValue) do
            if max < v then
                max = v
            end
        end
        return max
    else
        local maxLev = 0
        for _, value in pairs(self._staticDatabase.enhance) do
            if maxLev < value["breakthrough"] then
                maxLev = value["breakthrough"]
            end
        end
        local maxStrengthenLev = self:getMaxStrengthenLevelByHeroLevel(maxLev)
        return maxStrengthenLev
    end
end

--获取魂师装备突破最高等级
function QStaticDatabase:getMaxStrengthenLevel()
  local index = 0 
  local maxLevel = 0
  for _, value in pairs(self._staticDatabase.enhance) do
     if maxLevel < value["breakthrough"] then
        maxLevel = value["breakthrough"]
    end
  end
  local maxStrengthenLev = self:getMaxStrengthenLevelByHeroLevel(maxLevel)
  return maxStrengthenLev
end

--根据ItemId和觉醒等级和魂师ID获取觉醒配置
function QStaticDatabase:getEnchant(itemId, level, actorId)
    if itemId == nil or level == nil or actorId == nil then
        return {}
    end
    local itemConfig = self:getItemByID(itemId)
    local character = self:getCharacterByID(actorId)
    local enchant = tostring(itemConfig.enchant)
    if character.aptitude == APTITUDE.SS then
        enchant = tostring(itemConfig.enchant_ss)
    elseif character.aptitude == APTITUDE.SSR then
        enchant = tostring(itemConfig.enchant_ssr)
    end
    local enchantConfig = self._staticDatabase.enchant[enchant] or {}
    local defaultConfig = nil
    local actorConfig = nil
    for _,config in ipairs(enchantConfig) do
        if config.enchant_level == level then
            if config.hero_id == actorId then
                actorConfig = config
            elseif config.hero_id == nil then
                defaultConfig = config
            end
        end
    end
    if actorConfig ~= nil then 
        return actorConfig 
    end
    return defaultConfig or {}
end

function QStaticDatabase:getMaxEnchantLevel(itemId, actorId)
    local enchants = self:getEnchants(itemId, actorId)
    return #enchants
end

function QStaticDatabase:getEnchants(itemId, actorId)
    local itemConfig = self:getItemByID(itemId)
    local character = self:getCharacterByID(actorId)
    local enchant = tostring(itemConfig.enchant)
    if character.aptitude == APTITUDE.SS then
        enchant = tostring(itemConfig.enchant_ss)
    elseif character.aptitude == APTITUDE.SSR then
        enchant = tostring(itemConfig.enchant_ssr)
    end
    local enchants = self._staticDatabase.enchant[enchant] or {}
    local tbl1 = {}
    local tbl2 = {}
    for _,value in ipairs(enchants) do
        if value.hero_id == tonumber(actorId) then
            table.insert(tbl1, value)
        end
        if value.hero_id == nil then
            table.insert(tbl2, value)
        end
    end
    if #tbl1 > 0 then
        return tbl1
    end
    return tbl2
end

function QStaticDatabase:getEnchantMaterials(itemId, level, actorId)
    local enchant = self:getEnchant(itemId, level, actorId)
    local materials = {}
    if enchant.enchant_item1 ~= nil then
        table.insert(materials, {id = enchant.enchant_item1, count = enchant.enchant_num1})
    end
    if enchant.enchant_item2 ~= nil then
        table.insert(materials, {id = enchant.enchant_item2, count = enchant.enchant_num2})
    end
    if enchant.enchant_item3 ~= nil then
        table.insert(materials, {id = enchant.enchant_item3, count = enchant.enchant_num3})
    end

    return materials, enchant
end

function QStaticDatabase:getEnchantSkill(itemId, level, actorId)
    local enchant = self:getEnchant(itemId, level, actorId)

    if enchant then
        return enchant.enchant_skill
    else
        return nil
    end
end

--根据魂师ID获取组合相关信息
function QStaticDatabase:getCombinationInfoByHeroId(heroId)
    if heroId == nil then return {} end
    
    if ENABLE_HERO_COMBINATION == false then return {} end
  
    return self._staticDatabase.combination[tostring(heroId)] or {}
end

--根据魂师Id获得该魂师所有组合和该魂师可以激活的组合
function QStaticDatabase:getCombinationInfoByactorId(actorId)
    if actorId == nil then return end

    if ENABLE_HERO_COMBINATION == false then return {} end

    local combinationInfos = {}
    for k, value in pairs(self._staticDatabase.combination) do
        for i = 1, #value do
            if value[i].hero_id == actorId then
                combinationInfos[#combinationInfos+1] = value[i]
            else
                local index = 1
                while value[i]["combination_hero_"..index] do
                    if value[i]["combination_hero_"..index] == actorId then
                        combinationInfos[#combinationInfos+1] = value[i]
                        break
                    end
                    index = index + 1
                end   
            end
        end
    end
    return combinationInfos
end

--获取组合的信息列表
function QStaticDatabase:getCombinationInfo()
    local combinConfig = {}
    local data = self._staticDatabase.combination
    for k, value in pairs(data) do
        local index = 1
        local actorId = tonumber(value.id)
        while true do
            local combinationId = value["combination_"..index]
            if combinationId ~= nil then
                if combinConfig[actorId] == nil then
                    combinConfig[actorId] = {}
                end
                combinConfig[actorId][combinationId] = {}
                local herosId = string.split(value["hero_"..index], ";")
                for _,heroId in pairs(herosId) do
                    table.insert(combinConfig[actorId][combinationId], tonumber(heroId))
                end
                table.insert(combinConfig[actorId][combinationId], tonumber(value.id))
                index = index + 1
            else
                break
            end
        end
    end
    return combinConfig
end

--根据当前装备觉醒或强化等级获得下一级强化大师信息
function QStaticDatabase:getStrengthenMasterByLevel(type, level)
    if type == nil or self._staticDatabase.strength_master == nil then return 0 end

    local index = 1
    local masterData = self._staticDatabase.strength_master
    while masterData[type..index] do
        if level < masterData[type..index].condition then
            return 0
        elseif level >= masterData[type..index].condition and masterData[type..(index + 1)] == nil then
            return index
        elseif level >= masterData[type..index].condition and level < masterData[type..(index + 1)].condition then
            return index
        end
        index = index + 1
    end
    return 0
end

--根据当前装备觉醒或强化等级获得下一级强化大师信息
function QStaticDatabase:getGemstoneStrengthenMasterByLevel(quality, type, level)
    if type == nil or self._staticDatabase.strength_master == nil then return 0 end

    local index = 1
    local masterData = self._staticDatabase.strength_master
    while masterData["baoshiqianghua_master_"..quality.."_"..type.."_"..index] do
        local  data = masterData["baoshiqianghua_master_"..quality.."_"..type.."_"..index]
        local  nextData = masterData["baoshiqianghua_master_"..quality.."_"..type.."_"..(index + 1)]
        if level >= data.condition and nextData == nil then
            return data
        elseif level >= data.condition and level < nextData.condition then
            return data
        end
        index = index + 1
    end
    return nil
end

--根据当前装备强化大师信息
function QStaticDatabase:getGemstoneStrengthenMaster(quality, type)
    if type == nil or self._staticDatabase.strength_master == nil then return 0 end

    local index = 1
    local masterData = self._staticDatabase.strength_master
    local masterConfigs = {}
    while masterData["baoshiqianghua_master_"..quality.."_"..type.."_"..index] do
        table.insert(masterConfigs, masterData["baoshiqianghua_master_"..quality.."_"..type.."_"..index])
        index = index + 1
    end
    return masterConfigs
end

--根据当前装备强化大师等级获得强化大师当前等级和下一级信息
function QStaticDatabase:getStrengthenMasterByMasterLevel(type, level, offset)
    if type == nil or level == nil then return end
    if offset == nil then offset = 1 end

    if level == 0 then 
        return nil, self._staticDatabase.strength_master[type..offset], false
    elseif self._staticDatabase.strength_master[type..(level+offset)] == nil then
        return self._staticDatabase.strength_master[type..level], self._staticDatabase.strength_master[type..level], true
    end
    return self._staticDatabase.strength_master[type..level], self._staticDatabase.strength_master[type..(level+offset)], false
end

--根据当前装备强化大师等级获得强化大师当前等级和下一级信息
function QStaticDatabase:getMasterByMasterLevel(masterType, level)
    if masterType == nil or level == nil then return end

    return self._staticDatabase.strength_master[masterType..level]
end


function QStaticDatabase:getMaskWords()
    return self._staticDatabase.mask_word
end

function QStaticDatabase:getDungeonDialogs()
    return self._staticDatabase.dungeon_dialog
end

function QStaticDatabase:getDialogDisplay()
    return self._staticDatabase.dialog_display
end

function QStaticDatabase:getDialogDisplayById(id)
    return self._staticDatabase.dialog_display[tostring(id)]
end

--获取商城热卖物品组
function QStaticDatabase:getItemShopSellStateByShopId(shopId, state)
    if self._staticDatabase.shop[shopId] == nil then return end

    local hotGoods = {}
    local hotGoodIds = {}
    local shop = self._staticDatabase.shop[shopId]
    if shop.id == tonumber(shopId) and shop[state] ~= nil then
        hotGoods = {tostring(shop[state])}
        if type(shop[state]) ~= "number" then
            hotGoods = string.split(shop[state], ";")
        end
    end

    for i = 1, #hotGoods, 1 do
        hotGoods[hotGoods[i]] = hotGoods[i]
    end

    if next(hotGoods) then 
        for i = 1, #hotGoods, 1 do
            local index = 1
            while self._staticDatabase.shop_good[tostring(hotGoods[hotGoods[i]])][1]["id_"..index] ~= nil do
                local value = self._staticDatabase.shop_good[tostring(hotGoods[hotGoods[i]])][1]["id_"..index]
                hotGoodIds[value] = value
                index = index + 1
            end
        end
    end

    return hotGoodIds, hotGoods
end

--根据物品组ID,获取物品组
function QStaticDatabase:getGoodsGroupByGroupId(groupId)
    if groupId == nil or self._staticDatabase.shop_good[tostring(groupId)] == nil then return end
    local value = self._staticDatabase.shop_good[tostring(groupId)]
    local info = nil
    for i = 1, #value, 1 do
        if value[i].team_level_min <= remote.user.level and  value[i].team_level_max >= remote.user.level then
            return value[i]
        end
    end
    return value[1]
end

--根据物品组ID,物品刷新等级区间
function QStaticDatabase:getGoodsLevleIntervalByGroupId(groupId)
    if groupId == nil then return 0 ,0 end
    local value = self._staticDatabase.shop_good[tostring(groupId)] or {}
    if next(value) == nil then
        return 0,0
    end
    
    for i = 1, #value, 1 do
        if value[i].team_level_min <= remote.user.level and  value[i].team_level_max >= remote.user.level then
            return value[i].team_level_min,value[i].team_level_max
        end
    end
    return value[1].team_level_min, value[1].team_level_max
end

--根据商店ID,获取物品组ID
function QStaticDatabase:getGroupIdByShopId(shopId)
    if shopId == nil then return end
    return self._staticDatabase.shop[tostring(shopId)]
end

--根据商店奖励ID,获取物品
function QStaticDatabase:getItemsByShopAwardsId(awardsId)
    if awardsId == nil then return nil end
    return self._staticDatabase.shop_rewardterm[tostring(awardsId)]
end

--根据公告Id获取公告内容
function QStaticDatabase:getNoticeContentByNoticeIndex(index)
    if index == nil then return nil end
    return self._staticDatabase.notice[tostring(index)]
end

--获取客户端本地公告
function QStaticDatabase:getNativeNotice()
    local notices = self._staticDatabase.notice
    local nativeNotice = {}
    for _, notice in pairs(notices) do
        if tonumber(notice.open_client) == 1 then
            nativeNotice[#nativeNotice+1] = notice
        end
    end
    return nativeNotice
end

--根据酒馆类型，获取酒馆预览信息
function QStaticDatabase:getTavernOverViewInfoByTavernType(tavernType)
    if tavernType == nil then return nil end
    return self._staticDatabase.tavern_preview[tavernType]
end

--培养相关的量表
function QStaticDatabase:getTrainingCost(type)
    if type then
        return self._staticDatabase.train_consume[type]
    else
        return self._staticDatabase.train_consume
    end
end

function QStaticDatabase:getTrainingAttribute(index, level)
    if level and index then
        local config = self._staticDatabase.train_attribute[tostring(index)]
        for k, v in ipairs(config) do
            if v.hero_lv == level then
                return v
            end  
        end
        return {}
    elseif index then
        return self._staticDatabase.train_attribute[tostring(index)]
    else
        return self._staticDatabase.train_attribute
    end
end

function QStaticDatabase:getTrainingBonus(actorId)
    if actorId then
        return self._staticDatabase.train_extra[tostring(actorId)] or {}
    else
        return self._staticDatabase.train_extra
    end
end

function QStaticDatabase:getGuidenceWordById(id)
    return self._staticDatabase.guidance[tostring(id)]
end 

function QStaticDatabase:getHPPerLayerByLevel(level, dungeonConfig)
    if self._staticDatabase.boss_hp_set then
        local obj = self._staticDatabase.boss_hp_set[tostring(level)]
        if obj then
            local value
            if dungeonConfig and dungeonConfig.isThunder then
                value = obj.thunder_value
            elseif dungeonConfig and dungeonConfig.isUnionDragonWar then
                value = obj.sociaty_dragon_value
            end
            if value == nil then
                value = obj.value
            end
            return value
        end
    end
end

function QStaticDatabase:getQuickWayInfoByType(quickType)
    if self._staticDatabase.shortcut_approach then
        local quickInfo = {}
        for _, value in pairs(self._staticDatabase.shortcut_approach) do
            if value.type == quickType and value.rank ~= nil then
                table.insert(quickInfo, q.cloneShrinkedObject(value))
            end
        end
        return quickInfo
    end
    return nil
end

function QStaticDatabase:getDungeonRageOffenceByDungeonID(dungeon_id)
    local dungeon_rage_offence = self._staticDatabase.dungeon_rage_offence
    if dungeon_rage_offence then
        local obj = dungeon_rage_offence[dungeon_id]
        if obj then
            return q.cloneShrinkedObject(obj)
        end
    end
end

function QStaticDatabase:getDungeonRageDefenceByDungeonID(dungeon_id)
    local dungeon_rage_defence = self._staticDatabase.dungeon_rage_defence
    if dungeon_rage_defence then
        local obj = dungeon_rage_defence[tostring(dungeon_id)]
        if obj then
            return q.cloneShrinkedObject(obj)
        end
    end
end

function QStaticDatabase:getCharacterRageByCharacterID(character_id)
    local character_rage = self._staticDatabase.character_rage
    if character_rage then
        local obj = character_rage[tostring(character_id)]
        if obj then
            return q.cloneShrinkedObject(obj)
        end
    end
end

-- 魂师大赛
function QStaticDatabase:getGloryTower(level)
    if level then
        return self._staticDatabase.tower_of_glory[tostring(level)] or {}
    else
        return self._staticDatabase.tower_of_glory
    end
end

-- 魂师大赛，最高积分
function QStaticDatabase:getGloryTowerMaxScore()
    local towerInfo = self._staticDatabase.tower_of_glory
    local maxScore = 0
    local i = 1
    while towerInfo[tostring(i)].score ~= nil do
        maxScore = towerInfo[tostring(i)].score
        i = i + 1
    end
    return maxScore
end

-- 魂师大赛，最高段位
function QStaticDatabase:getGloryTowerMaxFloor()
    for _, config in pairs(self._staticDatabase.tower_of_glory) do
        if config.ranking == 1 then
            return config.id
        end
    end
end

-- 魂师大赛每日积分奖励
function QStaticDatabase:getGloryTowerDailyRewardWithoutItem()
    return self._staticDatabase.tower_reward
end

-- 魂师大赛每日积分奖励，包含了奖励物品信息
function QStaticDatabase:getGloryTowerDailyReward()
    local luckyDrawTable = {}
    local level = remote.user.dailyTeamLevel or 1

    local maxRewardsLevel = 1
    local getRewardsFunc = function()
        for k, v in pairs(self._staticDatabase.tower_reward) do
            if v.lowest_levels <= level and level <= v.maximum_levels then
                local luckyDraw = self:getLuckyDraw(v.lucky_draw)
                table.insert(luckyDrawTable, {id = v.id, reward_id = luckyDraw.id_1, type = luckyDraw.type_1, 
                    count = luckyDraw.num_1, score_service = v.score_service})
            end
            maxRewardsLevel = maxRewardsLevel < v.maximum_levels and v.maximum_levels or maxRewardsLevel
        end
    end
    getRewardsFunc()

    if next(luckyDrawTable) == nil then
        level = maxRewardsLevel
        getRewardsFunc()
    end

    return luckyDrawTable
end

-- 魂师大赛排名奖励
function QStaticDatabase:getGloryTowerLadderReward()
    local luckyDrawTable = {}
    for k, v in pairs(self._staticDatabase.tower_rank_reward) do
        local luckyDraw = self:getLuckyDraw(v.lucky_draw)
        table.insert(luckyDrawTable, {id = v.id, rank = v.rank, floor = v.floor, luckyDraw = luckyDraw})
    end

    return luckyDrawTable
end

-- 魂师大赛排名奖励，根据排位
function QStaticDatabase:getGloryTowerLadderRewardByFloor(floor)
    local luckyDrawTable = {}
    for k, v in pairs(self._staticDatabase.tower_rank_reward) do
        if v.floor == floor then
            local luckyDraw = self:getLuckyDraw(v.lucky_draw)
            return {id = v.id, rank = v.rank, floor = v.floor, luckyDraw = luckyDraw}
        end
    end
end

-- buff效果提示文字库
function QStaticDatabase:getBuffTip(effect_key)
    return self._staticDatabase.buff_tip[effect_key]
end

-- 宗门
function QStaticDatabase:getSocietyLevel(level)
    return self._staticDatabase.sociaty_level[tostring(level)] or {}
end
--获取 工会人数上限
function QStaticDatabase:getSocietyMemberLimitByLevel( level )
    -- body
    local config = self._staticDatabase.sociaty_level[tostring(level)]
    if config then
        return config.sociaty_scale
    end
end

function QStaticDatabase:getSocietyFete(type)
    return self._staticDatabase.sociaty_fete[tostring(type)] or {}
end

function QStaticDatabase:getSocietyFeteReward(level)
    return self._staticDatabase.sociaty_fetereward[tostring(level)] or {}
end

function QStaticDatabase:getMaxSocietyFeteProgress(level)
    local feteConfig = self:getSocietyFeteReward(level)
    if next(feteConfig) then
        return feteConfig[#feteConfig].fete_schedule
    else
        return 0
    end
end

function QStaticDatabase:getMaxSocietyLevel()
    return table.nums(self._staticDatabase.sociaty_level)
end

--获取雷电王座BUFF
function QStaticDatabase:getThunderBuffById(id)
    if id == nil then return nil end
    return self._staticDatabase.thunder_buff[tostring(id)]
end

--获取雷电王座关卡通过ID
function QStaticDatabase:getThunderConfigByDungeonId(dungeonId)
    if dungeonId == nil then return nil end
    for _,config in pairs(self._staticDatabase.thunder_config) do
        for i=1,3 do
            if config["dungeon"..i.."easy"] == dungeonId or config["dungeon"..i.."_normal"] == dungeonId or config["dungeon"..i.."_hard"] == dungeonId then
                return config,i
            end
        end
    end
    return nil
end

--获取雷电王座关卡
function QStaticDatabase:getThunderConfigByLayer(layer)
    if layer == nil then return nil end
    return self._staticDatabase.thunder_config[tostring(layer)]
end

--获取雷电王座通关条件
function QStaticDatabase:getThunderWinConditionByDungeonId(dungeonId)
    if dungeonId == nil then return nil end
    local info = self._staticDatabase.thunder_complete[dungeonId]
    if info == nil then return nil end
    return info.target_type, info.target_value_1, info.target_text
end

--获取雷电王座通关配置
function QStaticDatabase:getThunderCompleteByDungeonId(dungeonId)
    if dungeonId == nil then return nil end
    return self._staticDatabase.thunder_complete[dungeonId]
end

--获取考古学院配置
function QStaticDatabase:getArcharologyConfig()
    return self._staticDatabase.archaeology
end

--获取副本小怪气泡文字配置
function QStaticDatabase:getMonsterStringByID(id)
    local t = self._staticDatabase.monster_string
    if t then
        return t[tostring(id)]
    end
end

--获取活动配置
function QStaticDatabase:getActivities()
    return self._staticDatabase.activities
end

--获取活动目标配置
function QStaticDatabase:getActivityTarget()
    return self._staticDatabase.activity_targets
end

--获取活动目标配置
function QStaticDatabase:getUnlock()
    return self._staticDatabase.unlock
end

function QStaticDatabase:calculateSuperSkill(dictIDAsKey)
    for id, enable in pairs(DEBUG_SUPER_SKILL or {}) do
        for _, config in pairs(self._staticDatabase.super_skill) do
            if id == config.hero then
                if config.Deputy_hero1 then
                    dictIDAsKey[config.Deputy_hero1] = enable and config.Deputy_hero1 or nil
                end
                if config.Deputy_hero2 then
                    dictIDAsKey[config.Deputy_hero2] = enable and config.Deputy_hero2 or nil
                end
                if config.Deputy_hero3 then
                    dictIDAsKey[config.Deputy_hero3] = enable and config.Deputy_hero3 or nil
                end
            end
        end
    end

    local cache = self._calculatedDatabase["calculateSuperSkill"]
    if next(cache) == nil then
        for _, obj in pairs(self._staticDatabase.super_skill) do
            local main = obj.hero
            local deputies = {}
            if obj.Deputy_hero1 then
                deputies[obj.Deputy_hero1] = obj.skill_Multiple1 or 0
            end
            if obj.Deputy_hero2 then
                deputies[obj.Deputy_hero2] = obj.skill_Multiple2 or 0
            end
            if obj.Deputy_hero3 then
                deputies[obj.Deputy_hero3] = obj.skill_Multiple3 or 0
            end
            local operator = obj.operand
            cache[#cache + 1] = {main = main, skill = obj.Super_skill, multiple = obj.skill_Multiple or 0, deputies = deputies, operator = operator}
        end
    end

    local results = {}
    local function mergeResult(id, srcObj)
        local dstObj = results[id]
        if dstObj == nil then
            results[id] = srcObj
        else
            if srcObj.deputies then
                dstObj.multiple = dstObj.multiple + srcObj.multiple
                dstObj.skill = srcObj.skill -- 主技能只能有一个
                dstObj.deputies = srcObj.deputies -- 只显示使主技能生效的那个组合
            else
                dstObj.multiple = dstObj.multiple + srcObj.multiple
            end
        end
    end
    for _, obj in ipairs(cache) do
        local main = obj.main
        local skill = obj.skill
        local multiple = obj.multiple
        local deputies = obj.deputies
        local operator = obj.operator
        if dictIDAsKey[main] then
            local check
            local availableDeputies = {}
            if operator == nil or operator == 1 then
                check = true
                for deputy, multiple in pairs(deputies) do
                    if not dictIDAsKey[deputy] then
                        check = false
                        break
                    else
                        availableDeputies[deputy] = multiple
                    end
                end
            elseif operator == 2 then
                check = false
                for deputy, multiple in pairs(deputies) do
                    if dictIDAsKey[deputy] then
                        check = true
                        availableDeputies[deputy] = multiple
                    end
                end
            end
            if check then
                -- {skill = objbymain.Super_skill, multiple = objbymain.skill_Multiple, deputy = objbymain.Deputy_hero}
                mergeResult(main, {skill = skill, multiple = multiple, deputies = availableDeputies})
                for deputy, multiple in pairs(availableDeputies) do
                    mergeResult(deputy, {multiple = multiple})
                end
            end
        end
    end
    return results
end

function QStaticDatabase:calculateCombinationProp(dictIDAsKey)
    local combination = self._staticDatabase.combination
    local returnProp = {}
    local configs, prop, ok, index
    for id, _ in pairs(dictIDAsKey) do
        configs = combination[tostring(id)]
        if configs then
            prop = nil
            for _, config in ipairs(configs) do
                ok = true
                index = 1
                while true do
                    local deputy = config["combination_hero_"..index]
                    if deputy then
                        if not dictIDAsKey[deputy] then
                            ok = false
                            break
                        end
                    else
                        break
                    end
                    index = index + 1
                end
                if ok then
                    if prop == nil then
                        prop = {}
                    end
                    for k, v in pairs(config) do
                        if type(v) == "number" and k ~= "hero_id" and not string.find(k, "combination", 1) then
                            prop[k] = (prop[k] or 0) + v
                        end
                    end
                end
            end
            if prop then
                returnProp[id] = prop
            end
        end
    end
    return returnProp
end

function QStaticDatabase:calculateUnionSkillProp(consortiaSkillList)
    local unionSkillProp = {}
    for k,v in pairs(consortiaSkillList or {}) do
        local curConfig = self:getUnionSkillConfigByLevel(v.skillId, v.skillLevel)
        if curConfig then
            for name,filed in pairs(QActorProp._field) do
                if curConfig[name] ~= nil then
                    if unionSkillProp[name] == nil then
                        unionSkillProp[name] = curConfig[name]
                    else
                        unionSkillProp[name] = curConfig[name] + unionSkillProp[name]
                    end
                end
            end
        end
    end
    return unionSkillProp 
end

-- 计算激活的暗器图鉴的属性
function QStaticDatabase:calculateMountCombinationProp(historyMount)
    if historyMount == nil or next(historyMount) == nil then return {} end
    local combinations = self:getMountCombinationInfo()


    local checkMount = function(combination)
        local mounts = string.split(combination.condition, ";")
        if mounts == nil and next(mounts) == nil then 
            return false
        end

        local checkHave = function(mountId)
            if not tonumber(mountId) then
                return false
            end
            for i = 1, #historyMount, 1 do
                if historyMount[i] == tonumber(mountId) then
                    return true
                end
            end
            return false
        end

        local isActive = false
        local isTwice = combination.condition_num or 2
        if isTwice == 2 then
            if checkHave(mounts[1]) and checkHave(mounts[2]) then
                isActive = true
            end
        else
            if checkHave(mounts[1]) then
                isActive = true
            end
        end
        return isActive
    end

    local mountCombinationProp = {}
    for k,v in pairs(combinations or {}) do
        if checkMount(v) then
            for name,filed in pairs(QActorProp._field) do
                if v[name] ~= nil then
                    if mountCombinationProp[name] == nil then
                        mountCombinationProp[name] = v[name]
                    else
                        mountCombinationProp[name] = v[name] + mountCombinationProp[name]
                    end
                end
            end
        end
    end
    return mountCombinationProp 
end

-- 计算激活的暗器图鉴的属性
function QStaticDatabase:calculateSoulSpiritCombinationProp(soulSpiritRecords)
    if soulSpiritRecords == nil or next(soulSpiritRecords) == nil then return {} end
    local combinations = self._staticDatabase.soul_tujian or {}
    local getSoulSpiritCombinationInfo = function(soulSpirit)
        local combination = combinations[tostring(soulSpirit.id)]
        for _, info in pairs(combination) do
            if info.grade == soulSpirit.grade then
                return info
            end
        end
    end

    local soulSpiritCombinationProp = {}
    for k, soulSpirit in pairs(soulSpiritRecords) do
        local soulSpiritInfo = getSoulSpiritCombinationInfo(soulSpirit)
        for name,filed in pairs(QActorProp._field) do
            if soulSpiritInfo[name] ~= nil then
                if soulSpiritCombinationProp[name] == nil then
                    soulSpiritCombinationProp[name] = soulSpiritInfo[name]
                else
                    soulSpiritCombinationProp[name] = soulSpiritInfo[name] + soulSpiritCombinationProp[name]
                end
            end
        end
    end
    return soulSpiritCombinationProp 
end

function QStaticDatabase:getAvatarFrameId(avatar)
    avatar = math.fmod(avatar, 1000000)
    local avatarId = math.fmod(avatar, 10000)
    local frameId = avatar - avatarId

    return avatarId, frameId
end

-- zxs
function QStaticDatabase:calculateAvatarProp(avatar, title, userTitles)
    avatar = tonumber(avatar or 0)
    title = title or 0
    userTitles = userTitles or {}

    local allProp = {}
    local calculatePropFunc = function (propInfo, allProp)
        for key, value in pairs(QActorProp._field) do
            if propInfo[key] then
                allProp[key] = allProp[key] or 0
                allProp[key] = allProp[key] + propInfo[key]
            end
        end
    end

    -- 可叠加属性
    for i, v in pairs(userTitles) do
        local propInfo = self._staticDatabase.head_default[tostring(v.titleId)]
        if propInfo and propInfo.attribute_add == 1 then
            calculatePropFunc(propInfo, allProp)
        end
    end

    -- 使用中不可叠加属性
    -- 头像，头像框，底座
    if avatar > 0 then
        local avatarId, frameId = self:getAvatarFrameId(avatar)
        local propInfo = self._staticDatabase.head_default[tostring(frameId)]
        if propInfo and propInfo.attribute_add ~= 1 then
            calculatePropFunc(propInfo, allProp)
        end
    end
    -- 称号
    if title > 0 then
        local propInfo = self._staticDatabase.head_default[tostring(title)]
        if propInfo and propInfo.attribute_add ~= 1 then
            calculatePropFunc(propInfo, allProp)
        end
    end

    return allProp
end

function QStaticDatabase:calculateArchaeologyProp( fragmentID )
    if fragmentID == nil or fragmentID == 0 then return {} end
    local propTbl = {}
    local archaeologyConfig = self._staticDatabase.archaeology
    for _,config in pairs(archaeologyConfig) do
        if config.id <= fragmentID then
            config = q.cloneShrinkedObject(config)
            for name,filed in pairs(QActorProp._field) do
                if config[name] ~= nil then
                    if propTbl[name] == nil then
                        propTbl[name] = config[name]
                    else
                        propTbl[name] = config[name] + propTbl[name]
                    end
                end
            end
        end
    end
    return propTbl
end

function QStaticDatabase:calculateSoulGuideLevelProp( soulGuideLevel )
    local propTbl = {}
    if not soulGuideLevel or soulGuideLevel == 0 then
        return propTbl
    end
    local soulConfig = db:getSoulGuideConfigByLevel(soulGuideLevel)
    QActorProp:getPropByConfig(soulConfig, propTbl)

    local talentConfig = db:getSoulGuideTalentConfigByLevel(soulGuideLevel)
    QActorProp:getPropByConfig(talentConfig, propTbl)

    return propTbl
end


function QStaticDatabase:calculateSoulTrialProp( soulTrial )
    local tbl = {}
    if soulTrial ~= nil and soulTrial > 0 then
        local chapter = 0
        local config = {}
        for _, value in pairs( self:getSoulTrial() ) do
            if tonumber(value.id) == soulTrial then
                chapter = value.index
                config = value
            end
        end
        if config.boss == 1 then
            chapter = chapter
        else
            chapter = chapter - 1
        end

        local bossConfig = {}
        local sortConfig = self:getSortSoulTrial()
        local configs = sortConfig[tonumber(chapter)] or {}
        for _, value in ipairs(configs) do
            if value.boss == 1 then
                bossConfig = value
            end
        end
        
        for key, value in pairs( bossConfig ) do
            if QActorProp._field[key] then
                if not tbl[key] then
                    tbl[key] = tonumber(value)
                else
                    tbl[key] = tbl[key] + tonumber(value)
                end
            end
        end
    end

    return tbl
end

function QStaticDatabase:calculateGlyphTeamProp(glyphs)
    local propTbl = {}
    local value1, value2, filed
    local QActorPropField = QActorProp._field
    for _, glyph in ipairs(glyphs) do
        local config = self:getGlyphSkillByIdAndLevel(glyph.glyphId, glyph.glyphLevel)
        if config then
            for name, value1 in pairs(config) do
                filed = QActorPropField[name]
                if filed and filed.isAllTeam then
                    value2 = propTbl[name]
                    if value2 == nil then
                        propTbl[name] = value1
                    else
                        propTbl[name] = value2 + value1
                    end
                end
            end
        end
    end
    return propTbl
end

-- create validation (first time call) and validate (late calls)
function QStaticDatabase:validateData()
    if ENABLE_QSTATICDATABASE_VALIDATION then
        local vds = self["data_validation"]
        if vds == nil then
            vds = {}
            vds.item = q.createValidationForTable(self._staticDatabase.item)
            vds.enhance_data = q.createValidationForTable(self._staticDatabase.enhance_data)
            vds.enchant = q.createValidationForTable(self._staticDatabase.enchant)
            self["data_validation"] = vds
        else
            for table_name, validation in pairs(vds) do
                q.validateForTable(self._staticDatabase[table_name], validation)
            end
        end
    end
end

function QStaticDatabase:getAssistSkill(actorId)
    if actorId == nil then return nil end
    local skillInfos = self._staticDatabase.super_skill
    for _, value in pairs(skillInfos)do
        if value.hero == actorId then
            return value
        end
    end
    return nil
end

-- 获取魂师作为主将或副将的所有能激活的合体技
-- return  all assist skill info array
function QStaticDatabase:getAllAssistSkillByActorId(actorId)
    if actorId == nil then return {} end

    local assistSkillInfos = {} 
    local skillInfos = self._staticDatabase.super_skill
    for _, value in pairs(skillInfos)do
        if value.hero == actorId then
            assistSkillInfos[#assistSkillInfos+1] = value
        else
            local index = 1
            while value["Deputy_hero"..index] do
                if value["Deputy_hero"..index] == actorId then
                    assistSkillInfos[#assistSkillInfos+1] = value
                    break
                end
                index = index + 1
            end 
        end
    end
    return assistSkillInfos
end

function QStaticDatabase:getAssistSkillForHero(actorId1, actorId2)
    if not actorId1 or not actorId2 then return nil end

    local skillInfos = self._staticDatabase.super_skill
    for _, value in pairs(skillInfos)do
        if (tonumber(value.hero) == actorId1 and tonumber(value.Deputy_hero) == actorId2) or 
         (tonumber(value.hero) == actorId2 and tonumber(value.Deputy_hero) == actorId1) and value.skill_Multiple then
            return value
        end
    end
    return nil
end

function QStaticDatabase:getIntrusionReward(rewardType)
    local luckyDrawTable = {}
    for k, v in pairs(self._staticDatabase.intrusion_reward) do
        if v.type == rewardType then
            local luckyDraw = self:getLuckyDraw(v.lucky_draw)
            table.insert(luckyDrawTable, {id = v.id, reward_id = luckyDraw.id_1, type = luckyDraw.type_1, 
                count = luckyDraw.num_1, meritorious_service = v.meritorious_service, lowest_levels = v.lowest_levels, 
                maximum_levels = v.maximum_levels, luckyDraw = v.lucky_draw})
        end
    end

    return luckyDrawTable
end

function QStaticDatabase:getPlunderTargetReward(rewardType, level)
    level = level == nil and remote.user.level or level
    local luckyDrawTable = {}
    for k, v in pairs(self._staticDatabase.plunder_target_reward) do
        if v.rank_type == rewardType and v.level_min <= level and v.level_max >= level   then
            table.insert(luckyDrawTable, v)
        end
    end

    return luckyDrawTable
end

function QStaticDatabase:getPlunderRankReward(rewardType, level)
    level = level == nil and remote.user.level or level
    local luckyDrawTable = {}
    for k, v in pairs(self._staticDatabase.plunder_rank_reward) do
        if v.rank_type == rewardType and v.level_min <= level and v.level_max >= level  then
            table.insert(luckyDrawTable, v)
        end
    end

    return luckyDrawTable
end

function QStaticDatabase:getIntrusionEscapeTime(level)
    level  = level or 1
    for k, v in pairs(self._staticDatabase.intrusion) do
        if level >= v.levels and level <= v.levels2 then
            return v.escape_time
        end
    end
end

function QStaticDatabase:getIntrusionPos(level)
    level  = level or 1
    for k, v in pairs(self._staticDatabase.intrusion) do
        if level >= v.levels and level <= v.levels2 then
            return v.size, v.positionX, v.positionY
        end
    end
end

function QStaticDatabase:getIntrusionMaximumLevel(id)
    local dataType = self:getCharacterByID(id).data_type
    local datas = self._staticDatabase.character_data[tostring(dataType)]
    if datas == nil then
        assert(datas, function() return "data_type:" .. dataType .. " not exist" end)
        return nil
    end

    return #datas
end

function QStaticDatabase:getForceColorByForce(force, isTeamForce)
    if force == nil then return nil end
    local forceInfos = self._staticDatabase.force_color
    local tbl = {}
    for _,v in pairs(forceInfos) do
        table.insert(tbl, v)
    end
    table.sort(tbl, function (a,b)
        return a.force_max < b.force_max
    end)
    local forceInfo
    if isTeamForce then
        for _,v in ipairs(tbl) do
            forceInfo = v
            if v.team_force_max > force then
                break
            end
        end
    else
        for _,v in ipairs(tbl) do
            forceInfo = v
            if v.force_max > force then
                break
            end
        end
    end
    return forceInfo
end

--斗魂场文字
function QStaticDatabase:getArenaLangaue()
    return self._staticDatabase.arena_langaue
end

-- 资源
function QStaticDatabase:getResource()
    return self._staticDatabase.resource
end

-- 获得豪华召唤相关信息
function QStaticDatabase:getTavernLuckyDraw()
    return self._staticDatabase.lucky_draw_directional_info
end

-- 获得充值相关信息
function QStaticDatabase:getRecharge()
    local recharge = {}
    if device.platform == "android" then
        -- for k, v in pairs(self._staticDatabase.recharge) do
        --     if v.platform == 2 then
        --         table.insert(recharge, v)
        --     end
        -- end
        for k, v in pairs(self._staticDatabase.recharge) do
            if v.platform == 2 then
                table.insert(recharge, v)
            end
        end
    else
        for k, v in pairs(self._staticDatabase.recharge) do
            if v.platform == 1 then
                table.insert(recharge, v)
            end
        end
    end

    return recharge
end

function QStaticDatabase:getGenreInfo()
    return self._staticDatabase.genre
end

function QStaticDatabase:getHeroGenreById(actorId)
    if actorId == nil then return nil end
    local genreInfos = QStaticDatabase:sharedDatabase():getGenreInfo()
    for _, genreInfo in pairs(genreInfos) do
        local genre = string.split(genreInfo.ID, ";")
        for _, value in pairs(genre) do
            if value == tostring(actorId) then
                return genreInfo.GENRE_TEXT, genreInfo.INDEX
            end
        end
    end
    return nil
end

--指定id是否是肉盾
function QStaticDatabase:isTank(actorId)
    local _,index = self:getHeroGenreById(actorId)
    return index == HERO_FUNC_TYPE.TANK
end

--指定id是否是治疗
function QStaticDatabase:isHealth(actorId)
    local _,index = self:getHeroGenreById(actorId)
    return index == HERO_FUNC_TYPE.HEALTH
end

--指定id是否是dps
function QStaticDatabase:isDPS(actorId)
    local _,index = self:getHeroGenreById(actorId)
    return index == HERO_FUNC_TYPE.DPS_M or index == HERO_FUNC_TYPE.DPS_P
end


--指定id是否是魔攻
function QStaticDatabase:isDPS_M(actorId)
    local _,index = self:getHeroGenreById(actorId)
    return index == HERO_FUNC_TYPE.DPS_M
end

--指定id是否是物攻
function QStaticDatabase:isDPS_P(actorId)
    local _,index = self:getHeroGenreById(actorId)
    return index == HERO_FUNC_TYPE.DPS_P
end

--获取战败引导配置
function QStaticDatabase:getDefeatGuidance()
    return self._staticDatabase.defeat_guidance
end

--获取开服战力竞赛配置
function QStaticDatabase:getActivityForce()
    return self._staticDatabase.activity_force
end

--主界面人物说话
function QStaticDatabase:getDialogue(wordType)
    if wordType == nil then return {} end

    local words = {}
    for _, value in pairs(self._staticDatabase.dialogue) do
        if value.type == wordType then
            words[#words+1] = value
        end
    end

    return words
end

function QStaticDatabase:getDragonDialogue(wordType, level)
    if wordType == nil then return {} end

    local words = {}
    for _, value in pairs(self:getDialogue(wordType)) do
        if value.dragon_level_down <= level and level <= value.dragon_level_up then
            words[#words+1] = value
        end
    end

    return words
end

--根据等级掉落查找奖励
function QStaticDatabase:getLevelDropById(id, level)
    if id == nil then return {} end
    local config = self._staticDatabase.task_level_drop[tostring(id)]
    if config == nil then return {} end
    local luckyDrawId = nil
    local dropInfo = nil
    for _,value in ipairs(config) do
        if value.minlevel <= level and level <= value.maxlevel then
            luckyDrawId = value.lucky_draw
            dropInfo = value
            break
        end
    end
    return self:getluckyDrawById(luckyDrawId), dropInfo
end

--根据奖励Id统计奖励内容
function QStaticDatabase:getluckyDrawById(luckyDrawId)
    local awards = {}
    if luckyDrawId == nil then return awards end
    local luckyConfig = self:getLuckyDraw(luckyDrawId)
    if luckyConfig == nil then return awards end
    local index = 1
    while luckyConfig["type_"..index] ~= nil do
        table.insert(awards, {id = luckyConfig["id_"..index], typeName = luckyConfig["type_"..index], count = luckyConfig["num_"..index]})
        index = index + 1
    end
    return awards
end

function QStaticDatabase:getShortcut()
    return self._staticDatabase.shortcut_approach_new
end

function QStaticDatabase:getShortcutByID( id )
    for _, value in pairs(self:getShortcut()) do
        if tonumber(value.ID) == tonumber(id) then
            return value
        end
    end
    
    return nil
end

--根据等级获取每日任务的奖励
function QStaticDatabase:getDaliyTaskScoreAwardsByLevel(level, awardType)
    local tbl = {}
    for _, awards in pairs(self._staticDatabase.daily_task_reward) do
        for _, value in ipairs(awards) do
            if value.level_min <= level and value.level_max >= level and value.type == awardType then
                tbl[value.ID] = value
                break
            end
        end
    end
    return tbl
end

--获取每日任务的奖励
function QStaticDatabase:getDaliyTaskAwards(level, awardType)
    local tbl = {}
    for _, awards in pairs(self._staticDatabase.daily_task_reward) do
        for _, value in ipairs(awards) do
            if value.level_min <= level and value.level_max >= level and value.type == awardType then
                tbl[#tbl+1] = value
            end
        end
    end
    return tbl
end

--根据等级获取斗魂场的每日积分奖励
function QStaticDatabase:getArenaScoreAwardsByLevel(level)
    local tbl = {}
    for _, awards in pairs(self._staticDatabase.arena_reward) do
        for _, value in ipairs(awards) do
            if value.level_min <= level and value.level_max >= level then
                tbl[value.ID] = value
                break
            end
        end
    end
    return tbl
end

-- 根据暴击数值获取暴击属于哪一档
function QStaticDatabase:getYieldLevelByYieldData(yield, yeildType)
    if yield == nil or yeildType == nil then return 1 end
    local yieldInfo = self._staticDatabase.critical_hit[yeildType]
    local index = 2 
    while yieldInfo["multiple_"..index] ~= nil do
        if yieldInfo["multiple_"..index] == yield then
            return index-1
        end
        index = index + 1
    end
    return 1
end

-- 获取指定魂师ID所需的超级碎片的数量
function QStaticDatabase:getActorSABC(actorId)
    local character = self:getCharacterByID(actorId)
    if character then
        return self:getSABCByQuality(character.aptitude)
    else
        return nil
    end
end

function QStaticDatabase:getSABCByQuality(quality)
    for _,value in ipairs(HERO_SABC) do
        if value.aptitude == quality then
            return value
        end
    end
end

function QStaticDatabase:getSABCByAptitude(aptitude_int)
    if aptitude_int >#HERO_SABC then
        return HERO_SABC[#HERO_SABC]
    end
    return HERO_SABC[#HERO_SABC + 1 - aptitude_int]
end


-- 获取指定魂师ID所需的超级碎片的数量
function QStaticDatabase:getSuperSoulByActorId(actorId)
    local qc = self:getActorSABC(actorId).qc
    local configuration = self:getConfiguration()
    if qc ~= nil then
        if qc == "S" then
            return configuration.WANNENGSUIPIAN_S_XIAOLV.value
        elseif qc == "A+" then
            return configuration["WANNENGSUIPIAN_A+_XIAOLV"].value
        elseif qc == "A" then
            return configuration.WANNENGSUIPIAN_A_XIAOLV.value
        elseif qc == "B" then
            return configuration.WANNENGSUIPIAN_B_XIAOLV.value
        elseif qc == "C" then
            return configuration.WANNENGSUIPIAN_C_XIAOLV.value
        end
    end
    return 0
end

function QStaticDatabase:getSunWarMapConfig()
    return self._staticDatabase.battlefield_chapter_reward
end

function QStaticDatabase:getSunWarWaveConfig()
    return self._staticDatabase.battlefield_reward
end

function QStaticDatabase:getSunWarDungeonRageConfig(chapter, wave)
    for _, config in pairs(self._staticDatabase.battlefield_enemy) do
        if (not chapter or chapter == config.chapter) and wave == config.wave then
            return config
        end
    end
end

function QStaticDatabase:getSunWarBuffConfigByCount(count)
    local maxCount, maxConfig = nil
    for _, config in pairs(self._staticDatabase.battlefield_buff) do
        if config.id == count then
            return config, config.id
        elseif maxCount == nil or maxCount < config.id then
            maxCount = config.id
            maxConfig = config
        end
    end
    if maxCount and count > maxCount then
        return maxConfig, maxConfig.id
    end
end

function QStaticDatabase:getSunWarBuffConfigByID(id)
    for _, config in pairs(self._staticDatabase.battlefield_buff) do
        if config.id == id then
            return config
        end
    end
    return {}
end

function QStaticDatabase:getSunWarEnemyCoefficient(todayPassedWaveCount)
    local configs = self._staticDatabase.battlefield_enemy_coefficient
    local selectedConfig = nil
    for _, config in pairs(configs) do
        if config.day_wave <= todayPassedWaveCount and (not selectedConfig or selectedConfig.day_wave < config.day_wave) then
            selectedConfig = config
        end
    end

    return selectedConfig and selectedConfig.coefficient or 1.0
end

--根据等级获取排名奖励集合
function QStaticDatabase:getIntrusionRankAwardByLevel(awardType, level)
    if level == nil then return {} end
    local tbl = {}
    for _,value in pairs(self._staticDatabase.intrusion_rank_reward) do
        if value.type == awardType and value.level_min <= level and value.level_max >= level then
            table.insert(tbl, value)
        end
    end
    return tbl
end

--根据等级和排行获取排名奖励
function QStaticDatabase:getIntrusionAwardsRankByRank(rank, awardType, level)
    if rank == nil then return nil end
    local data = self:getIntrusionRankAwardByLevel(awardType, level)
    table.sort( data, function(a, b) return a.rank < b.rank end )

    local tbl = {}
    local nextTbl = {}
    for i = 1, #data do
        if ( data[i-1] ~= nil and rank > data[i-1].rank and rank <= data[i].rank ) 
            or data[i].rank == rank then
            tbl = data[i]
            nextTbl = data[i-1] or data[i]
        end
    end
    return tbl, nextTbl
end

function QStaticDatabase:_processGo()
    for _, config in pairs(self._staticDatabase.character) do
        if config.name_go then
            config.name = config.name_go
        end
    end
    for _, config in pairs(self._staticDatabase.skill) do
        if config.name_go then
            config.name = config.name_go
        end
    end
    for _, config in pairs(self._staticDatabase.item) do
        if config.name_go then
            config.name = config.name_go
        end
    end
end

--根据KEY获取邮件模版
function QStaticDatabase:getMailStencilByKey(key)
    if key ~= nil then
        return self._staticDatabase.mail[key]
    end
    return nil
end

--获取觉醒宝箱兑换奖励
function QStaticDatabase:getEnchantOrientAwards()
    return self._staticDatabase.enchant_score_shop or {}
end

function QStaticDatabase:getGameLoad()
    return self._staticDatabase.game_load
end


-- 宗门技能
function QStaticDatabase:getUnionSkillConfigByLevel( skillID, level )
    -- body
    local unionSkill = self._staticDatabase.sociaty_skill
    local skills = unionSkill[tostring(skillID)]
    if skills then
        for k,v in pairs(skills) do
            if tonumber(v.level) == level then
                return v
            end
        end

    end
end

function QStaticDatabase:getUnionSkillMaxLimitLevel( skillID, unionLevel )
    -- body
    local unionSkill = self._staticDatabase.sociaty_skill
    local skills = unionSkill[tostring(skillID)]
    local level 
    if skills then
        local data = {}
        for k,v in pairs(skills) do
         
            if tonumber(v.sociaty_lv_require) <= tonumber(unionLevel) then
                if not level then
                    level = tonumber(v.level)
                elseif level < v.level then
                    level = tonumber(v.level)
                end
            end
        end
    end

    return level

end


function QStaticDatabase:getUnionSkillConfigs(  )
    -- body
    return self._staticDatabase.sociaty_skill
end

function QStaticDatabase:getCharacterAnimationDuration(id, animation, skinId)
    if skinId and skinId ~= 0 then
        local config = self:getHeroSkinConfigByID(skinId)
        if config and config.skins_fca then
            local config2 = self._staticDatabase.animation_time[config.skins_fca]
            if config2 and config2[animation] then
                return config2[animation]
            end
        end
    else
        local config = self:getCharacterByID(id)
        if config and config.actor_file then
            local config2 = self._staticDatabase.animation_time[config.actor_file]
            if config2 and config2[animation] then
                return config2[animation]
            end
        end
    end
    return {1.25}
end

function QStaticDatabase:getGlyphSkillsBySkillID( id )
    return self._staticDatabase.glyph[tostring(id)]
end

function QStaticDatabase:getGlyphSkillByIdAndLevel( id, level )
    if id and level then
        local glyphByIdAndLevel = self._calculatedDatabase["glyphByIdAndLevel"]
        local config = glyphByIdAndLevel[tonumber(id)]
        if config then
            local level_config = config[level]
            if level_config then
                return level_config
            end
        end
    end

    local config = self:getGlyphSkillsBySkillID(id)
    for _, value in pairs(config) do
        if value.glyph_level == level then
            return value
        end
    end

    return nil
end

function QStaticDatabase:getGlyphSkillsByGlyphs(glyphs)
    local configs = {}
    for _, glyph in pairs(glyphs) do
        local config = self:getGlyphSkillByIdAndLevel(glyph.glyphId, glyph.level)
        if config then
            configs[#configs + 1] = config
        end
    end
    return configs
end

function QStaticDatabase:getItemUseLinkByID( id )
     local config = self._staticDatabase.item_use_link
     for _, value in pairs(config) do
        if value.id == id then
            return value
        end
     end
end

function QStaticDatabase:getItemUseLink()
    return self._staticDatabase.item_use_link or {}
end

function QStaticDatabase:getAllScoietyChapter()
    return self._staticDatabase.sociaty_chapter
end

function QStaticDatabase:getScoietyChapter( mapId )
    local config = self:getAllScoietyChapter()
    local r = config[tostring(mapId)]
    if r and r.chapter == mapId then
        return r
    end

    for _, values in pairs(config) do
        for _, value in pairs(values) do
            if value.chapter == mapId then
                return values
            end
        end
    end

    return nil
end

function QStaticDatabase:getScoietyWave( waveId, mapId )
    local config = self:getScoietyChapter(mapId)
    if q.isEmpty(config) then return nil end

    
    for _, value in pairs(config) do
        if value.wave == waveId then
            return value
        end
    end

    return nil
end

function QStaticDatabase:getScoietyDungeonBuff( buffId )
    local config = self._staticDatabase.buff_des
    local r = config[tostring(buffId)]
    if r and r.id == buffId then
        return r
    end

    for _, values in pairs(config) do
        for _, value in pairs(values) do
            if value.idr == buffId then
                return values
            end
        end
    end

    return nil
end

function QStaticDatabase:getUnionLogByID(id)
    -- body
    local config = self._staticDatabase.sociaty_log
    for _, value in pairs(config) do
        if value.id == id then
            return value
        end
    end
end

function QStaticDatabase:getLevelGuideInfosByType(guideType)
    local configs = {}
    for _,v in pairs(self._staticDatabase.level_goal or {}) do
        if v.type == guideType then
            table.insert(configs, v)
        end
    end
    return configs
end

function QStaticDatabase:getSilvermineCaveConfigs()
    return self._staticDatabase.silvermine_cave_config
end

function QStaticDatabase:getSilvermineMineConfigs()
    return self._staticDatabase.silvermine_mine_config
end

function QStaticDatabase:getSilvermineLevelConfigs()
    return self._staticDatabase.silvermine_level_config
end

function QStaticDatabase:getSilvermineThingsConfigs()
    return self._staticDatabase.silvermine_things_config
end

--根据itemid和等级获取宝石突破的配置
function QStaticDatabase:getGemstoneBreakThroughByLevel(itemId, breakLevel)
    local configs = self._staticDatabase.gemstone_breakthrough[tostring(itemId)] or {}
    for _,config in ipairs(configs) do
        if config.break_level == breakLevel then
            return config
        end
    end
    return {}
end

function QStaticDatabase:getGemstoneBreakThrough(itemId)
    local configs = self._staticDatabase.gemstone_breakthrough[tostring(itemId)]
    return configs
end

function QStaticDatabase:getGemstoneStrengthByQuality(quality)
    return self._staticDatabase.gemstone_strengthen[tostring(quality)]
end

function QStaticDatabase:getGemstoneSuitEffectBySuitId(suitId)
    return self._staticDatabase.gemstone_set[tostring(suitId)]
end

function QStaticDatabase:getTurntableRankAwardByRowNum(rowNum)
    return self._staticDatabase.lucky_draw_directional_reward[tostring(rowNum)]
end
-- 获取兑换商店的新信息
function QStaticDatabase:getExchangeShopInfo()
    return self._staticDatabase.exchange_shop

end

function QStaticDatabase:getHelpDescribeByType( typeName )
    -- body
    return self._staticDatabase.help_describe[tostring(typeName)]
end

function QStaticDatabase:getGloryArenaAwards( id, isCrossServer )
    -- body
    if isCrossServer then
        return self._staticDatabase.tower_quanfu_competition[tostring(id)]
    else
        return self._staticDatabase.tower_benfu_competition[tostring(id)]
    end
end

function QStaticDatabase:getGloryArenaQuanfuAwards(  )
    -- body
    return self._staticDatabase.tower_quanfu_competition
end

function QStaticDatabase:getGloryArenaBenfuAwards(  )
    -- body
    return self._staticDatabase.tower_benfu_competition
end

function QStaticDatabase:getGloryArenaChenghaoID( rank )
    -- body
    for id = 601, 605 do
        local info = self._staticDatabase.head_default[tostring(id)] 
        if info then
            if rank <= info.condition then
                return info.id
            end
        end
    end
    return 0
end
--根据等级获取荣耀斗魂场的每日积分奖励
function QStaticDatabase:getGloryArenaScoreAwardsByLevel(level)
    local tbl = {}
    for _, awards in pairs(self._staticDatabase.tower_competition_reward) do
        for _, value in ipairs(awards) do
            if value.level_min <= level and value.level_max >= level then
                tbl[value.ID] = value
                break
            end
        end
    end
    return tbl
end

--根据等级获取荣耀斗魂场的每日积分奖励
function QStaticDatabase:getStormArenaScoreAwardsByLevel(level)
    local tbl = {}
    for _, awards in pairs(self._staticDatabase.storm_arena_reward) do
        for _, value in ipairs(awards) do
            if value.level_min <= level and value.level_max >= level then
                tbl[value.ID] = value
                break
            end
        end
    end
    return tbl
end

--获取徽章配置
function QStaticDatabase:getBadge()
    return self._staticDatabase.badge
end

--根据通关数量获取徽章配置
function QStaticDatabase:getBadgeByCount(count)
    local config = nil
    for _,value in pairs(self._staticDatabase.badge) do
        if count >= value.number then
            if config == nil or config.number < value.number then
                config = value
            end
        end
    end
    return config
end


--更具轮次 获取团购信息
function QStaticDatabase:getGroupBuyInfoByRownum( num )
    -- body
    return self._staticDatabase.group_buying[tostring(num)]
end

--根据等级获取积分奖励
function QStaticDatabase:getScoreAwardsByLevel(funcName, level)
    local scoreData = self._staticDatabase.score_reward[funcName] or {}
    local tbl = {}

    for _, awards in pairs(scoreData) do
        if awards.level_min <= level and awards.level_max >= level then
            tbl[awards.id] = awards
        end
    end
    return tbl
end

--魂导科技配置
function QStaticDatabase:getSoulGuideConfigByLevel(level)
    local configs = self._staticDatabase.soul_arms_science or {}
    for _, value in pairs(configs) do
        if value.science_lev == level then
            return value
        end
    end
end

--魂导科技天赋配置
function QStaticDatabase:getSoulGuideTalentConfigByLevel(level)
    local configs = self._staticDatabase.soul_arms_science_tianfu or {}
    local tbl = {}
    for _, value in pairs(configs) do
        tbl[value.id] = value
    end

    local curConfig = {}
    for id, value in pairs(tbl) do
        if value.condition > level then
            break
        end
        curConfig = value
    end
    return curConfig
end

--根据暗器强化等级获取暗器强化信息
function QStaticDatabase:getMountStrengthenBylevel(aptitude, level)
    local infos = self._staticDatabase.zuoqi_qianghua[tostring(aptitude)] or {}
    for _, value in pairs(infos) do
        if value.zuoqi_level == level then
            return value
        end
    end
end

--根据暗器改造等级获取暗器强化信息
function QStaticDatabase:getReformConfigByAptitudeAndLevel(aptitude, reformLevel)
    if not reformLevel then return nil end
    
    local infos = self._staticDatabase.super_zuoqi_reform[tostring(aptitude)] or {}
    for _, value in pairs(infos) do
        if value.level == reformLevel then
            return value
        end
    end
end

--根据暗器Id获取强化材料
function QStaticDatabase:getMountMaterialById(characterId)
    if characterId == nil then return nil end
    return self._staticDatabase.zuoqi_shengji_daoju[tostring(characterId)] or {}
end

--根据暗器强化等级获取强化大师
function QStaticDatabase:getMountMasterInfo(aptitude, level)
    local infos = self._staticDatabase.zuoqi_tianfu[tostring(aptitude)] or {}
    if level == nil then
        return infos, 0
    end
    local maxLevel = 0
    local masterInfos = {}
    for _, value in pairs(infos) do
        if value.level and value.level > 0 and (value.condition or 0) <= level and maxLevel < value.level then
            maxLevel = value.level
            table.insert(masterInfos, value)
        end
    end
    return masterInfos, maxLevel
end

--根据大师等级获取强化大师信息
function QStaticDatabase:getMountMasterInfoByLevel(aptitude, masterLevel)
    local infos = self._staticDatabase.zuoqi_tianfu[tostring(aptitude)] or {}
    if masterLevel == nil then
        return nil
    end
    for _, value in pairs(infos) do
        if value.level == masterLevel then
            return value
        end
    end
    return nil
end

--根据大师等级获取强化大师属性
function QStaticDatabase:getMountMasterPropByLevel(aptitude, masterLevel)
    local infos = self._staticDatabase.zuoqi_tianfu[tostring(aptitude)] or {}
    if masterLevel == nil then
        return nil
    end
    local prop = {}
    for _, value in pairs(infos) do
        if value.level <= masterLevel then
            for name,filed in pairs(QActorProp._field) do
                if value[name] ~= nil then
                    if prop[name] == nil then
                        prop[name] = value[name]
                    else
                        prop[name] = value[name] + prop[name]
                    end
                end
            end
        end
    end
    return prop
end

--根据暗器强化等级获取对应的经验值
function QStaticDatabase:getMountEnhanceTotalExpByLevel(aptitude, level)
    local totalExp = 0
    local infos = self._staticDatabase.zuoqi_qianghua[tostring(aptitude)] or {}
    for _, value in pairs(infos) do
        if value.zuoqi_level < level then
            totalExp = totalExp + value.strengthen_zuoqi
        end
    end

    return totalExp
end

-- 根据等级和队号获得风暴斗魂场已解锁数量
function QStaticDatabase:getStormArenaUnlockCount(level, index)
    local minLevel = 0
    for k, v in pairs(self._staticDatabase.storm_arena_lineup) do
        if level >= v.lev and minLevel < v.lev then
            minLevel = v.lev
        end
    end

    if minLevel > 0 then
        if index == 1 or index == 0 then 
            return self._staticDatabase.storm_arena_lineup[tostring(minLevel)].team1_num 
        elseif index == 2 then 
            return self._staticDatabase.storm_arena_lineup[tostring(minLevel)].team2_num
        elseif index == 4 then 
            return self._staticDatabase.storm_arena_lineup[tostring(minLevel)].team3_num 
        else
            -- assert(false, "Index is " .. tostring(index) .. ". Index must be 1, 2, 4")
        end
    end

    return 0
end

-- 根据等级和队号获得风暴斗魂场剩余未解锁信息
function QStaticDatabase:getStormArenaUnlockLevel(level, index)
    local unlockLevel = {}
    local count = self:getStormArenaUnlockCount(level, index)

    local lineup = {}
    for k, v in pairs(self._staticDatabase.storm_arena_lineup) do
        table.insert(lineup, v)
    end
    table.sort(lineup, function (a, b)
        return a.lev < b.lev
    end)

    for k, v in ipairs(lineup) do
        if index == 1 or index == 0 then 
            if count == 0 then
                for i = 1, v.team1_num - 1 do
                    table.insert(unlockLevel, v.lev)
                end
            end
            if v.team1_num > count then
                table.insert(unlockLevel, v.lev)
                count = v.team1_num
            end
        elseif index == 2 then 
            if count == 0 then
                for i = 1, v.team2_num - 1 do
                    table.insert(unlockLevel, v.lev)
                end
            end
            if v.team2_num > count then
                table.insert(unlockLevel, v.lev)
                count = v.team2_num
            end
        elseif index == 4 then 
            if count == 0 then
                for i = 1, v.team3_num - 1 do
                    table.insert(unlockLevel, v.lev)
                end
            end
            if v.team3_num > count then
                table.insert(unlockLevel, v.lev)
                count = v.team3_num
            end
        else
            assert(false, "Index must be 1, 2, 4")
        end
    end

    return unlockLevel
end

--根据暗器图鉴信息
function QStaticDatabase:getMountCombinationInfo()
    return self._staticDatabase.zuoqi_tujian or {}
end

--获得小舞课堂配置
function QStaticDatabase:getXiaoNaNa(id)
    if id then
        return self._staticDatabase.help_classroom[tostring(id)]
    else
        return self._staticDatabase.help_classroom
    end
end

function QStaticDatabase:getXiaoNaNaTreeStructure()
    local sorted = {}
    for k, v in pairs(self._staticDatabase.help_classroom) do
        table.insert(sorted, {id = v.id, value = v})
    end

    table.sort(sorted, function (a, b)
        return a.id > b.id
    end)

    local tree = {}
    local parentText = nil
    for k, v in ipairs(sorted) do
        if v.value.small_title then
            parentText = v.value.big_title

            local found = false
            for k1, v1 in ipairs(tree) do
                if v1.name == parentText then
                    table.insert(v1.children, {name = v.value.small_title, id = v.value.id, value = v.value})
                    found = true
                    break
                end
            end

            if not found then
                table.insert(tree, {name = v.value.big_title, id = v.value.id, value = v.value})
                tree[#tree].children = {}
                table.insert(tree[#tree].children, {name = v.value.small_title, id = v.value.id, value = v.value})
            end
        else
            table.insert(tree, {name = v.value.big_title, id = v.value.id, value = v.value})
        end
    end

    return tree
end

function QStaticDatabase:getCombinationByMountId(mountId)
    if mountId == nil then return end

    local combination = {}
    for _, value in pairs(self._staticDatabase.zuoqi_tujian) do
        local mounts = string.split(value.condition, ";")
        if mountId == tonumber(mounts[1]) or mountId == tonumber(mounts[2]) then
            return value
        end
    end
    return {}
end

--获取海神岛说话的配置根据Index
function QStaticDatabase:getBattlefieldLangaueByIndex(index)
    if index == nil then return end

    return self._staticDatabase.battlefield_enemy_langaue[tostring(index)]
end

function QStaticDatabase:getPlunderCaveConfigs()
    return self._staticDatabase.plunder_cave_config
end

function QStaticDatabase:getPlunderMineConfigs()
    return self._staticDatabase.plunder_mine_config
end

function QStaticDatabase:getSilvesAeraneConfigs()
    return self._staticDatabase.silves_arena_season_end_reward
end

function QStaticDatabase:getDivinationRankAwards(benfuName, quanfuName)
    -- body
    return self._staticDatabase.rank_reward[benfuName], self._staticDatabase.rank_reward[quanfuName]
end


function QStaticDatabase:getDivinationShowInfo( rowNum )
    -- body
    local temp = self._staticDatabase.zhanbu[tostring(rowNum)]
    if temp then
        return temp
    end
end

--获取黑石配置
function QStaticDatabase:getBalckRockConfig()
    return self._staticDatabase.blackrock_chapter_monster
end

--根据副本ID和buffID获取配置
function QStaticDatabase:getBlackRockBuffId(buffId)
    local configs = self._staticDatabase.blackrock_chapter_buff
    for _,dungeonBuffs in pairs(configs) do
        for _,value in ipairs(dungeonBuffs) do
            if value.buff_index == buffId then
                return value
            end
        end
    end
end

function QStaticDatabase:getRefineBuffConfig()
    return self._staticDatabase.refine_attribute
end

function QStaticDatabase:getBlackRockRewardGropByLevel(level)
    local rewards = {}
    for _,v1 in pairs(self._staticDatabase.black_rock_reward_group) do
        for _,v2 in ipairs(v1) do
            if (v2.level_min or 0) <= level and (v2.level_max or 0) >= level then
                table.insert(rewards, v2)
            end
        end
    end
    table.sort(rewards, function (a,b)
        return a.rank < b.rank 
    end)
    return rewards
end

--获取黑石塔星级奖励
function QStaticDatabase:getBlackRockStarAwardsById(id)
    if id == nil then return nil end
    return self._staticDatabase.blackrock_chapter_staraward[tostring(id)]
end

--获取神技
function QStaticDatabase:getGodSkillById(id)
    if id == nil then return nil end
    return self._staticDatabase.god_skill[tostring(id)]
end

--ss神技进阶配置
function QStaticDatabase:getGodSkillByIdAndGrade(id, grade)
    local godSkills = self:getGodSkillById(id)
    if godSkills == nil then
        return nil
    end
    for _, config in pairs(godSkills) do 
        if config.level == grade then
            return config
        end
    end
    return nil
end

--ss神技进阶配置
function QStaticDatabase:getGodSkillByIdAndShowLevel(id, showLevel)
    local godSkills = self:getGodSkillById(id)
    if godSkills == nil then
        return nil
    end
    local tbl = {}
    for _, config in pairs(godSkills) do 
        if config.grade == showLevel then
            table.insert(tbl, config)
        end
    end
    table.sort(tbl, function(a, b)
        return a.level < b.level
    end)

    return tbl
end

--获取神器技能配置
function QStaticDatabase:getArtifactSkillConfigById(id)
    if id == nil then return nil end
    return self._staticDatabase.artifact_skill[tostring(id)]
end

--获取神器强化配置
function QStaticDatabase:getArtifactLevelConfigBylevel(aptitude, level)
    local infos = self._staticDatabase.artifact_enhance[tostring(aptitude)] or {}
    if not level then
        return infos
    end
    for _, value in pairs(infos) do
        if value.artifact_level == level then
            return value
        end
    end
end

-- 获取武魂真身经验
function QStaticDatabase:getArtifactTotalExpByLevel(aptitude, level)
    local exp = 0
    local infos = self._staticDatabase.artifact_enhance[tostring(aptitude)] or {}
    for _, value in pairs(infos) do
        if value.artifact_level < level then
            exp = exp + value.artifact_exp
        end
    end
    return exp
end

--获取神器突破配置
function QStaticDatabase:getArtifactGradeConfigById(id)
    if id == nil then return nil end
    return self._staticDatabase.artifact_breakthtough[tostring(id)]
end

-- 按照grade表的形式修改consume_item_str
function QStaticDatabase:getGradeByArtifactLevel(id, level)
    local gradeConfig = db:getArtifactGradeConfigById(id) or {}
    for _, config in pairs(gradeConfig) do
        if config.breakthrough == level then
            return config
        end
    end
end

--根据暗器强化等级获取强化大师
function QStaticDatabase:getArtifactMasterInfo(aptitude, level)
    local infos = self._staticDatabase.artifact_tianfu[tostring(aptitude)] or {}
    if level == nil then
        return infos, 0
    end
    local maxLevel = 0
    local masterInfos = {}
    local masterConfig = nil
    for _, value in pairs(infos) do
        if value.condition <= level and maxLevel < value.level then
            maxLevel = value.level
            masterConfig = value
            table.insert(masterInfos, value)
        end
    end

    -- 已激活所有大师，当前最大大师等级，当前最大等级大师信息
    return masterInfos, maxLevel, masterConfig
end

--根据大师等级获取强化大师信息
function QStaticDatabase:getArtifactMasterInfoByLevel(aptitude, masterLevel)
    local infos = self._staticDatabase.artifact_tianfu[tostring(aptitude)] or {}
    if masterLevel == nil then
        return nil
    end
    for _, value in pairs(infos) do
        if value.level == masterLevel then
            return value
        end
    end
    return nil
end

-- 获取排行奖励
function QStaticDatabase:getRankAwardsByType(typeName, level)
    if level == nil then level = 1 end

    local awards = self._staticDatabase.rank_reward[typeName]

    local finalAwards = {}
    if q.isEmpty(awards) == false and level then
        for _, value in ipairs(awards) do
            if level >= value.level_min and level <= value.level_max then
                finalAwards[#finalAwards+1] = value
            end
        end
    end

    return finalAwards
end

-- 获取福利追回
function QStaticDatabase:getRewardRecover()
    return self._staticDatabase.reward_recover
end

-- 获取玩法日历功能
function QStaticDatabase:getGameCalendar()
    return self._staticDatabase.game_calendar
end

--获取图腾配置
function QStaticDatabase:getDragonTotemConfigById(dragonId)
    if dragonId == nil then return nil end
    return self._staticDatabase.dragon_stone[tostring(dragonId)]
end

-- 获取图腾等级配置
function QStaticDatabase:getDragonTotemConfigByIdAndLevel(id, level)
    local configs = self:getDragonTotemConfigById(id)
    if configs ~= nil then
        for _,v in ipairs(configs) do
            if v.level == level then
                return v
            end
        end
    end
    return nil
end

--获取图腾天赋配置
function QStaticDatabase:getDragonTotemTalent()
    return self._staticDatabase.dragon_tianfu
end

--id获取宗门武魂
function QStaticDatabase:getUnionDragonConfigById(dragonId)
    if dragonId == nil or dragonId == 0 then dragonId = 1 end
    return self._staticDatabase.sociaty_dragon[tostring(dragonId)]
end

--type获取宗门武魂
function QStaticDatabase:getUnionDragonListDragonByType(dragonType)
    local dragons = {}
    local sociatyDragon = self._staticDatabase.sociaty_dragon or {}
    for i, dragon in pairs(sociatyDragon) do
        if dragon.type == dragonType then
            table.insert(dragons, dragon)
        end
    end
    return dragons
end

--获取宗门巨龙等级信息
function QStaticDatabase:getUnionDragonInfoByLevel(dragonLevel)
    if dragonLevel == nil then return {} end
    
    return self._staticDatabase.sociaty_dragon_level[tostring(dragonLevel)]
end

--获取宗门巨龙所有技能信息
function QStaticDatabase:getUnionDragonSkillById(dragonId)
    if dragonId == nil then return {} end
    
    return self._staticDatabase.sociaty_dragon_skill[tostring(dragonId)]
end

--获取宗门巨龙当前技能信息
function QStaticDatabase:getUnionDragonSkillByIdAndLevel(dragonId, dragonLevel)
    dragonLevel = dragonLevel or 1
    if dragonId == 0 then dragonId = 1 end
    local dragonSkills = self:getUnionDragonSkillById(dragonId) or {}
    local curLevel = 1
    local curSkill = {}
    for i, skill in pairs(dragonSkills) do
        if dragonLevel >= skill.dragon_level and skill.dragon_level >= curLevel then
            curLevel = skill.dragon_level
            curSkill = skill
        end
    end
    return curSkill
end

--根据ID获取问题
function QStaticDatabase:getQuestionById(questionId)
    if questionId == nil then return nil end
    return self._staticDatabase.union_answer[tostring(questionId)]
end

--根据答题对的数量获取奖励
function QStaticDatabase:getQuestionAwardsByCount(rightCount)
    if rightCount == nil then return nil end
    return self._staticDatabase.union_answer_all[tostring(rightCount)]    
end

function QStaticDatabase:getVersionPostInfo()
    return self._staticDatabase.publicity_map or {}
end

function QStaticDatabase:getDragonEvolutionInfo()
    return self._staticDatabase.sociaty_dragon_evolution or {}
end

function QStaticDatabase:getDragonWarWeatherById(weatherId)
    if weatherId == nil then weatherId = 1 end
    return self._staticDatabase.sociaty_dragon_fight_weather[tostring(weatherId)]
end

function QStaticDatabase:getDragonEvolutionInfoByLevel(dragonLevel)
    return self._staticDatabase.sociaty_dragon_evolution[tostring(dragonLevel)] or {}
end

function QStaticDatabase:getUnionDragonFloorInfoByFloor(floor)
    if floor == nil then return {} end
    
    local floorData = {}
    for _, value in pairs(self._staticDatabase.sociaty_dan) do
        if value.level_min <= remote.user.level and value.level_max >= remote.user.level and value.dan == floor then
            return value
        end
    end

    return {}
end

--获取龙战的每日功勋奖励
function QStaticDatabase:getDragonFightAwardsByLevel(level)
    local awards = {}
    if level ~= nil then
        for _,configs in pairs(self._staticDatabase.sociaty_dragon_fight_reward) do
            for _,v in ipairs(configs) do
                if v.level_min <= level and v.level_max >= level then
                    table.insert(awards, v)
                end
            end
        end
    end
    return awards
end

--获取龙战的段位奖励
function QStaticDatabase:getDragonFloorAwardsByLevel(level)
    local configs = {}
    for _, value in pairs(self._staticDatabase.sociaty_dan) do
        if value.level_min <= level and value.level_max >= level then
            table.insert(configs, value)
        end
    end
    return configs
end

function QStaticDatabase:getRemoteNotification()
    return self._staticDatabase.push
end

--根据星星数量获取晶石场等级
function QStaticDatabase:getSparFieldLevelByStarCount(starCount)
    if starCount == nil then return nil end
    local levelConfig = nil
    for _,v in pairs(self._staticDatabase.spar_lev) do
        if starCount >= v.star then
            if levelConfig == nil or v.star >= levelConfig.star then
                levelConfig = v
            end
        end
    end
    return levelConfig
end


--获取魂灵传承
function QStaticDatabase:getSoulSpiritInheritConfig(inheritLevel_ , characterId_ )
    for _,value in pairs(self._staticDatabase.soul_inherit or {}) do
        if value.level == inheritLevel_ and characterId_ == value.character then
            return value
        end
    end
    return nil
end
--获取魂灵觉醒
function QStaticDatabase:getSoulSpiritAwakenConfig(awakenLevel_ , quality_)
    for _,value in pairs(self._staticDatabase.soul_awaken  or {}) do
        if value.level == awakenLevel_ and quality_ == value.quality then
            return value
        end
    end
    return nil
end


--根据编号获取晶石场等级配置
function QStaticDatabase:getSparFieldLevelById(level)
    if level == nil then return nil end
    for _,v in pairs(self._staticDatabase.spar_lev) do
        if v.lev == level then
            return v
        end
    end
end

--获取晶石场等级配置
function QStaticDatabase:getSparFieldLevel()
    return self._staticDatabase.spar_lev
end

--获取晶石场奖励配置
function QStaticDatabase:getSparFieldReward(wave, level)
    if wave == nil or level == nil then 
        return nil
    end
    for _,config in pairs(self._staticDatabase.spar_reward) do
        if config.wave == wave and config.lev_min <= level and config.lev_max >= level then
            return config
        end
    end
end

--根据晶石id和星级获取套装信息
function QStaticDatabase:getSparSuitInfosBySparId(sparId, grade)
    if sparId == nil then return {} end
    
    grade = math.max(grade, 1)
    local suits = {}
    for _, suit in pairs(self._staticDatabase.jewelry_suit) do
        for _, value in pairs(suit) do
            if value.star_min <= grade and ( value.colour_ls == sparId or value.colour_ys == sparId ) then
                suits[#suits+1] = value
                break
            end
        end
    end 

    return suits
end

--根据 榴石id、曜石id、星级 获取激活套装信息
function QStaticDatabase:getActiveSparSuitInfoBySparId(sparId1, sparId2, grade)
    if sparId1 == nil then return {} end

    local activeSuit = {}
    for _, suit in pairs(self._staticDatabase.jewelry_suit) do
        for _, value in ipairs(suit) do
            if  value.colour_ls == tonumber(sparId1) and value.colour_ys == tonumber(sparId2) then
                if tonumber(value.star_min) > tonumber(grade) then
                    break
                end
                activeSuit = value
            end
        end
        if next(activeSuit) then
            break
        end
    end 

    return activeSuit
end

--根据套装ID获取套装信息
function QStaticDatabase:getSparSuitInfosBySuitId(suitId)
    if suitId == nil then return {} end

    return self._staticDatabase.jewelry_suit[tostring(suitId)] or {}
end

function QStaticDatabase:getSparsIndexByItemId(itemId)
    if itemId == nil then return 1 end

    local sparIndex = 1

    local itemInfo = self:getItemByID(itemId)
    if itemInfo.type == ITEM_CONFIG_TYPE.OBSIDIAN then
        sparIndex = 2
    end
    return sparIndex
end

function QStaticDatabase:getSparsAbsorbConfigBySparItemIdAndLv(itemId,level)
    if itemId == nil or level == nil then 
        return nil
    end
    for _, inherit in pairs(self._staticDatabase.jewelry_inherit) do
        for i,v in ipairs(inherit) do
            if v.jewelry_id == itemId and v.level == level then
                return v
            end
        end
    end

    return nil
end

function QStaticDatabase:getSparFieldLegend()
    return self._staticDatabase.spar_legend_hero_effect["1"]
end

function QStaticDatabase:getSparMap()
    return self._staticDatabase.spar_map
end

function QStaticDatabase:getStorylineById(id)
    if self._staticDatabase.story_line then
        return self._staticDatabase.story_line[id]
    end
end

function QStaticDatabase:getNewEnemyTips(id)
    if nil ~= self._staticDatabase.dungeon_monster_tips then
        return self._staticDatabase.dungeon_monster_tips[tostring(id)]
    end
end

function QStaticDatabase:getDungeonSummaryPlot(id)
    if nil ~= self._staticDatabase.dungeon_summary_plot then
        return self._staticDatabase.dungeon_summary_plot[tostring(id)]
    end
end

-- 魂力试炼
function QStaticDatabase:getSoulTrial()
    return self._staticDatabase.soul_trial
end

function QStaticDatabase:getSortSoulTrial()
    local config = self:getSoulTrial()
    local tbl = {}
    for _, value in pairs(config) do
        if not tbl[tonumber(value.index)] then
            tbl[tonumber(value.index)] = {}
        end
        table.insert(tbl[tonumber(value.index)], value)
    end
    for _, value in ipairs(tbl) do
        table.sort(value, function(a, b)
                return tonumber(a.id) < tonumber(b.id)
            end)
    end
    return tbl
end

-- 魂力试炼
function QStaticDatabase:getSoulTrialById( id )
    return self._staticDatabase.soul_trial[tostring(id)]
end

-- 嘉年华积分奖励
function QStaticDatabase:getActivityForSevenScoreInfoById( id )
    return self._staticDatabase.activity_carnival[tostring(id)]
end

-- 七日登录奖励
function QStaticDatabase:getEntryRewardConfig(entryType)
    local entryReward = {}
    for i, v in pairs(self._staticDatabase.entry_reward) do
        if v.type == entryType then
            table.insert(entryReward, v)
        end
    end
    return entryReward
end

-- 封测返利
function QStaticDatabase:getRechargeFeedback()
    return self._staticDatabase.activity_rechargefeedback
end

-- 名人堂
function QStaticDatabase:getFamousPersonConfig()
    local config = self._staticDatabase.celebrity_hall or {}
    return config
end
-- 名人堂
function QStaticDatabase:getFamousPersonValueByRank( type, rank )
    local config = self._staticDatabase.celebrity_hall[tostring(rank)]
    if config then
        return config[type]
    end
    return nil
end

function QStaticDatabase:calculateSuperSkillIDArray(idArray)
    local dictIDAsKey = {}
    for _, id in ipairs(idArray) do
        dictIDAsKey[id] = id
    end
    return self:calculateSuperSkill(dictIDAsKey)
end

function QStaticDatabase:calculateCombinationPropByIDArray(idArray)
    local dictIDAsKey = {}
    for _, id in ipairs(idArray) do
        dictIDAsKey[id] = id
    end
    return self:calculateCombinationProp(dictIDAsKey)
end

--获取金属之城关卡配置
function QStaticDatabase:getMetalCityMapConfig()
    return self._staticDatabase.metalcity_config
end

--获取月度签到奖励
function QStaticDatabase:getMonthSignInAwards(time)
    if time == nil then return nil end
    
    return self._staticDatabase.check_in_yuedu[time]
end

--获取月度签到累计奖励
function QStaticDatabase:getMonthSignInChestAwards(time)
    if time == nil then return nil end
    
    return self._staticDatabase.check_in_add_yuedu[time]
end

--获取活动主题
function QStaticDatabase:getActivityThemeInfoById(themeId)
    if themeId == nil then return nil end
    
    return self._staticDatabase.activity_icon[tostring(themeId)]
end

--获取每日Vip福利列表内容
function QStaticDatabase:getVipGiftDailyList()
    return self._staticDatabase.vip_gift_daily
end

--根据VIP等级获取每日Vip福利
function QStaticDatabase:getVipGiftDailyListByLevel(level)
    return self._staticDatabase.vip_gift_daily[tostring(level+1)]
end
--获取每周礼包列表内容
function QStaticDatabase:getVipGiftWeekList()
    return self._staticDatabase.vip_gift_week
end

--获取搏击俱乐部的量表配置
function QStaticDatabase:getFightClubRankInfo()
    local rankInfo = {}
    for i, v in pairs(self._staticDatabase.fight_club_rank_info) do
        table.insert(rankInfo, v)
    end
    return rankInfo
end

-- 英雄开关
function QStaticDatabase:getHeroSwitch()
    return self._staticDatabase.hero_switch
end

-- 道具屏蔽 type
function QStaticDatabase:checkItemShields(id, idType)
    idType = idType or ITEM_TYPE.ITEM
    local heros = self:getHeroSwitch()
    for _, hero in pairs(heros) do
        if hero.is_shields == 1 and hero.type == idType and hero.shield_id == tonumber(id) then
            local openTime = q.getDateTimeByStandStr(hero.start_at)
            if openTime > q.serverTime() then
                return true
            end
        end
    end
    return false
end

-- 英雄屏蔽 type_1
function QStaticDatabase:checkHeroShields(id, idType)
    idType = idType or SHIELDS_TYPE.HERO
    local heros = self:getHeroSwitch()
    for _, hero in pairs(heros) do
        if hero.is_shields == 1 and hero.type_1 == idType and hero.shield_id == tonumber(id) then
            local openTime = q.getDateTimeByStandStr(hero.start_at)
            if openTime > q.serverTime() then
                return true
            end
        end
    end
    return false
end



-- 查询屏蔽英雄是否上线 zxs暂时不用了
-- function QStaticDatabase:checkHeroAutoOnLineById(id)
--     local heros = self:getHeroSwitch()
--     for _, hero in pairs(heros) do
--         if hero.is_shields == 1 and hero.type_1 == SHIELDS_TYPE.HERO and hero.shield_id == tonumber(id) then
--             local openTime = q.getDateTimeByStandStr(hero.start_at)
--             if openTime <= q.serverTime() then
--                 return true
--             end
--         end
--     end
--     return false
-- end

-- 大富翁主题英雄表
function QStaticDatabase:getMonopolyMainHeroConfig()
    return self._staticDatabase.binghuoliangyiyan_zhuti
end

-- 大富翁格子颜色表
function QStaticDatabase:getMonopolyGridColorConfig()
    return self._staticDatabase.binghuoliangyiyan_colour
end

-- 大富翁毒药表
function QStaticDatabase:getMonopolyPoisonConfig()
    return self._staticDatabase.binghuoliangyiyan_du
end

-- 大富翁仙品表
function QStaticDatabase:getMonopolyFlowerConfig()
    return self._staticDatabase.binghuoliangyiyan_xianpin
end

-- 大富翁事件表
function QStaticDatabase:getMonopolyEventConfig()
    return self._staticDatabase.binghuoliangyiyan_shijian
end

-- 图鉴
function QStaticDatabase:getHandBookConfig()
    return self._staticDatabase.handbook
end

-- 宗门红包
function QStaticDatabase:getUnionRedpacketConfig()
    return self._staticDatabase.consortia_redpacket
end

-- 宗门红包成就
function QStaticDatabase:getUnionRedpacketAchieveConfig()
    return self._staticDatabase.consortia_redpacket_tasks
end

-- 养龙：任务箱子
function QStaticDatabase:getDragonBoxConfig()
    return self._staticDatabase.sociaty_dragon_box
end

-- 养龙：任务
function QStaticDatabase:getDragonTaskConfig()
    return self._staticDatabase.sociaty_dragon_task
end

-- 养龙：答题
function QStaticDatabase:getDragonQuestionConfig()
    return self._staticDatabase.sociaty_dragon_question
end

--根据量表名称获取量表对象
function QStaticDatabase:getStaticByName(staticName)
    return self._staticDatabase[staticName] or {}
end

-------------------------- 复盘中使用到的量表操作 ---------------------------

function QStaticDatabase:getHeroSkinConfigByID(skinId)
    if skinId == nil or skinId == 0 then return {} end

    local skinConfig = self._staticDatabase.character_skins[tostring(skinId)] or {}
    if skinConfig.is_show == 0 then
        skinConfig = {}
    end

    return skinConfig
end

function QStaticDatabase:getSkinSkillsBySkinID(skinId)
    if skinId == nil or skinId == 0 then return {} end

    return self._staticDatabase.skill_skins[tostring(skinId)] or {}
end

function QStaticDatabase:getMagicHerb()
    return self._staticDatabase["magic_herb"]
end

function QStaticDatabase:getMagicHerbGrade()
    return self._staticDatabase["magic_herb_grade"]
end

function QStaticDatabase:getMagicHerbDevour()
    return self._staticDatabase["magic_herb_devour"]
end

function QStaticDatabase:getMagicHerbEnhance( ... )
    return self._staticDatabase["magic_herb_enhance"]
end

function QStaticDatabase:getMagicHerbSuitKill( ... )
    return self._staticDatabase["magic_herb_suit_kill"]
end


function QStaticDatabase:getMagicHerbBreedConfigs( ... )
    return self._staticDatabase["magic_herb_breed"]
end


function QStaticDatabase:getMagicHerbEnhanceExtraConfigs( ... )
    return self._staticDatabase["magic_herb_enhance_extra"]
end

--仙品培育
function QStaticDatabase:getMagicHerbBreedConfigByBreedLvAndId(magicId , breedlv)
    if breedlv == nil then return nil end
    local configs = self._staticDatabase["magic_herb_breed"] or {}
    for k,v in pairs(configs) do
        if v.breed_level == breedlv and v.magic_herb_id == magicId then
            return v
        end
    end
    return nil
end

--仙品培育对强化属性加成
function QStaticDatabase:getMagicHerbEnhanceExtraConfigByBreedLvAndId(enhanceLv , breedlv)
    if breedlv == nil or breedlv == 0  then return nil end
    if enhanceLv == nil or enhanceLv == 0  then return nil end
    local configs = self._staticDatabase["magic_herb_enhance_extra"] or {}
    for k,config in pairs(configs) do
       if config.level == enhanceLv and config.breed_level == breedlv then
            return config
       end
    end

    return nil
end


function QStaticDatabase:getConsortiaWarHall()
    return self._staticDatabase["consortia_war_hall"]
end

function QStaticDatabase:getBlackRockSoulSpriteMonsterId(monster_id, npc_id)
    local cfg = self._staticDatabase["black_rock_monster_index"][monster_id]
    if cfg then
        return cfg["index_"..npc_id]
    end
end

function QStaticDatabase:getPlayerComebackBuffByType(_type)
    return self._staticDatabase["player_comeback_buff"][tostring(_type)]
end

function QStaticDatabase:getCrystalGift()
    return self._staticDatabase.crystal_gift
end

function QStaticDatabase:getCrystalGiftInfoByPrize(prize)
    for _,v in pairs(self._staticDatabase.crystal_gift) do
        if prize == v.prize then
            return v
        end
    end
    return nil
end

function QStaticDatabase:getCollegeTrainConfig()
    return self._staticDatabase.college_train
end

function QStaticDatabase:getCollegeTrainConfigById(id)
    if tostring(id) == nil then return nil end
    local strId = tostring(id)
    return self._staticDatabase.college_train[strId]
end



function QStaticDatabase:getMockBattleCardConfig()
    return self._staticDatabase.mock_battle_card
end

function QStaticDatabase:getGodarmMasterByAptitude( aptitude )
    return self._staticDatabase.god_arm_talent[tostring(aptitude)]
end

--获取神器强化配置
function QStaticDatabase:getGodarmLevelConfigBylevel(aptitude, level)
    local infos = self._staticDatabase.god_arm_enhance[tostring(aptitude)] or {}
    if not level then
        return infos
    end
    for _, value in pairs(infos) do
        if value.level == level then
            return value
        end
    end
end

--神器天赋配置
function QStaticDatabase:getGodarmMasterByAptitudeAndLevel(aptitude,level)
    local configs = self._staticDatabase.god_arm_talent[tostring(aptitude)] or {}
    table.sort(configs, function(a, b)
            return a.condition < b.condition
        end)    
    local curConfig = {}
    for id, value in pairs(configs) do
        if value.condition > level then
            break
        end
        curConfig = value
    end
    return curConfig
end

--根据大师等级获取强化大师属性
function QStaticDatabase:getGodarmMasterPropByLevel(aptitude, masterLevel)
    local infos = self._staticDatabase.god_arm_talent[tostring(aptitude)] or {}
    if masterLevel == nil then
        return nil
    end
    local prop = {}
    for _, value in pairs(infos) do
        if value.condition <= masterLevel and value.condition > 0 then
            for name,filed in pairs(QActorProp._field) do
                if value[name] ~= nil then
                    if prop[name] == nil then
                        prop[name] = value[name]
                    else
                        prop[name] = value[name] + prop[name]
                    end
                end
            end
        end
    end
    return prop
end

--根据暗器强化等级获取对应的经验值
function QStaticDatabase:getGodarmEnhanceTotalExpByLevel(aptitude, level)
    local totalExp = 0
    local infos = self._staticDatabase.god_arm_enhance[tostring(aptitude)] or {}
    for _, value in pairs(infos) do
        if value.level <= level then
            totalExp = totalExp + (value.strengthen_zuoqi or 0)
        end
    end

    return totalExp
end


function QStaticDatabase:getTotemChallengeForceYieldProperty(force_yield)
    if force_yield then
        local tab = self._staticDatabase.force_yield_property
        for k,config in pairs(tab) do
            if force_yield > config.min and force_yield <= config.max then
                return config
            end
        end
    end
    return {}
end

function QStaticDatabase:getTotemAffixsConfigByBuffId(buffId)
    return self._staticDatabase.shengzhutiaozhan_rule[tostring(buffId)]
end

function QStaticDatabase:getGodArmPropByList(haveGodarmList)
    if haveGodarmList == nil or next(haveGodarmList) == nil then return {} end

    local godarmReformProp = {}
    for _, godarmInfo in pairs(haveGodarmList) do
        local godarmConfig = self:getCharacterByID(godarmInfo.id)
        --强化属性
        local refromProp = self:getGodarmLevelConfigBylevel(godarmConfig.aptitude, godarmInfo.level or 1) or {}
        QActorProp:getPropByConfig(refromProp, godarmReformProp)
        --星级属性
        local gradeProp = self:getGradeByHeroActorLevel(godarmInfo.id, godarmInfo.grade or 0)
        QActorProp:getPropByConfig(gradeProp, godarmReformProp)

        --天赋属性
        local curTalentInfo = self:getGodarmMasterPropByLevel(godarmConfig.aptitude, godarmInfo.level or 1) or {}
        QActorProp:getPropByConfig(curTalentInfo, godarmReformProp)
    end

    return godarmReformProp
end

function QStaticDatabase:getAllChildSoulFires()
    return self._staticDatabase.soul_technology
end

function QStaticDatabase:getAllChildSoulFiresByTree(treeType)
    if not treeType then return {} end
    local allChildInfo = {}
    for _,v in pairs(self._staticDatabase.soul_technology) do
        if treeType == v.tree_type then
            table.insert(allChildInfo,v)
        end
    end

    return allChildInfo
end

function QStaticDatabase:getAllSoulFireBigPoint()
    return self._staticDatabase.soul_fire_bigpoint
end

--获取大魂火信息
function QStaticDatabase:getMianSoulFireInfo( treeType,parentPoint)
    for _,v in pairs(self._staticDatabase.soul_fire_bigpoint) do
        if v.tree_type ==treeType and v.cell_id == parentPoint then
            return v
        end
    end

    return {}
end

--获取大魂火下所有子魂火信息
function QStaticDatabase:getAllChildSoulFireInfo(treeType,parentPoint)
    local allChildPoints = self:getAllChildSoulFiresByTree(treeType)
    local allChildInfo = {}
    for _,v in pairs(allChildPoints) do
        if tonumber(v.cell_type) and tonumber(v.cell_type) == tonumber(parentPoint) then
            table.insert(allChildInfo,v)
        end
    end

    return allChildInfo
end

--获取单个子魂火信息
function QStaticDatabase:getChildSoulFireInfo(treeType,parentPoint,childPoint)
    local allChildPoints = self:getAllChildSoulFireInfo(treeType,parentPoint)
    for _,v in pairs(allChildPoints) do
        if v.cell_id == childPoint then
            return v
        end
    end

    return nil
end

--根据轮次获取奖励列表
function QStaticDatabase:getSkyFallActivityRewardByRowNum(rowNum)
    for _,v in pairs(self._staticDatabase.sky_fall_activity_reward) do
        if v.row_num == rowNum then
            return v
        end
    end
    return nil
end

--根据轮次获取累计奖励
function QStaticDatabase:getSkyFallScoreRewardByRowNum(rowNum)
    local tbl = {}
    for _,v in pairs(self._staticDatabase.sky_fall_score_reward) do
        if v.row_num == rowNum then
            table.insert(tbl,v)
        end
    end
    return tbl
end

-- 根据渠道id显示关服公告
function QStaticDatabase:getChannelCloseDisc(channelid)
    for _,v in pairs(self._staticDatabase.channel_closure) do
        if v.id == tonumber(channelid) then
            return v.content
        end
    end
end
-- 根据渠道id得到关服公告显示时间
function QStaticDatabase:getChannelCloseTime(channelid)
    for _,v in pairs(self._staticDatabase.channel_closure) do
        if v.id == tonumber(channelid) then
            return v.time
        end
    end
end

function QStaticDatabase:getSkinsEggByType(eggType)
    local resultList = {}
    for _, v in pairs(self._staticDatabase.skins_easter_egg) do
        if v.type == eggType then
            table.insert(resultList, v)
        end
    end

    return resultList
end

function QStaticDatabase:getSoulTowerForceConfigById(id)
    return self._staticDatabase.soul_tower_force[tostring(id)]
end

return QStaticDatabase

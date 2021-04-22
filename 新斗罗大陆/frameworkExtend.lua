
singletons = {}
singletons.director = CCDirector:sharedDirector()
singletons.spriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
singletons.textureCache = CCTextureCache:sharedTextureCache()
singletons.fileUtils = CCFileUtils:sharedFileUtils()
singletons.shaderCache = CCShaderCache:sharedShaderCache()
singletons.skeletonDataCache = QSkeletonDataCache:sharedSkeletonDataCache()
singletons.ccbDataCache = QCCBDataCache:sharedCCBDataCache()

ccblDataCache = {}

-- extern color for ccc3
display.COLOR_YELLOW	= ccc3(255, 255, 0)
display.COLOR_MAGENTA	= ccc3(255, 0, 255)
display.COLOR_ORANGE  	= ccc3(255, 127, 0)
display.COLOR_GRAY		= ccc3(166, 166, 166)

display.COLOR_WHITE_C3 = display.COLOR_WHITE
display.COLOR_BLACK_C3 = display.COLOR_BLACK
display.COLOR_RED_C3   = display.COLOR_RED
display.COLOR_GREEN_C3 = display.COLOR_GREEN
display.COLOR_BLUE_C3  = display.COLOR_BLUE

display.COLOR_YELLOW_C3		= display.COLOR_YELLOW
display.COLOR_MAGENTA_C3	= display.COLOR_MAGENTA
display.COLOR_ORANGE_C3  	= display.COLOR_ORANGE
display.COLOR_GRAY_C3		= display.COLOR_GRAY

-- extern color for ccc4
display.COLOR_WHITE_C4 = ccc4(255, 255, 255, 255)
display.COLOR_BLACK_C4 = ccc4(0, 0, 0, 255)
display.COLOR_RED_C4   = ccc4(255, 0, 0, 255)
display.COLOR_GREEN_C4 = ccc4(0, 255, 0, 255)
display.COLOR_BLUE_C4  = ccc4(0, 0, 255, 255)

display.COLOR_YELLOW_C4		= ccc4(255, 255, 0, 255)
display.COLOR_MAGENTA_C4	= ccc4(255, 0, 255, 255)
display.COLOR_ORANGE_C4  	= ccc4(255, 127, 0, 255)
display.COLOR_GRAY_C4		= ccc4(166, 166, 166, 255)

-- extern color for ccc4f
display.COLOR_WHITE_C4F = ccc4f(1, 1, 1, 1)
display.COLOR_BLACK_C4F = ccc4f(0, 0, 0, 1)
display.COLOR_RED_C4F   = ccc4f(1, 0, 0, 1)
display.COLOR_GREEN_C4F = ccc4f(0, 1, 0, 1)
display.COLOR_BLUE_C4F  = ccc4f(0, 0, 1, 1)

display.COLOR_YELLOW_C4F	= ccc4f(1, 1, 0, 1)
display.COLOR_MAGENTA_C4F	= ccc4f(1, 0, 1, 1)
display.COLOR_ORANGE_C4F  	= ccc4f(1, 0.5, 0, 1)
display.COLOR_GRAY_C4F		= ccc4f(0.65, 0.65, 0.65, 1)

scheduler = require("framework.scheduler")

_import = import
function import(moduleName, currentModuleName)
	local theModuleNameParts = string.split(moduleName, ".")
    local theModuleName = theModuleNameParts[#theModuleNameParts]
    local theModule = q[theModuleName]
    if theModule == nil then
    	if not currentModuleName then
            local n,v = debug.getlocal(3, 1)
            currentModuleName = v
        end
    	theModule = _import(moduleName, currentModuleName)
    	q[theModuleName] = theModule
	end

    return theModule
end

_class = class
function class(classname, super)
	local cls = _class(classname, super)
    q[classname] = cls
    return cls
end

_printInfo = printInfo
function printInfo(fmt, ...)
    if DEBUG > 0 then
        printLog("INFO", fmt, ...)
    end
end

function isImplement(obj, classname)
    while true do
        if obj.super ~= nil and obj.super ~= obj then
            if obj.super.__cname == classname then
                return true
            else
                obj = obj.super
            end
        else
            return false
        end
    end
end

function printTable(t, prefix, level)
    if DEBUG > 0 and t ~= nil and type(t) == "table" then
        if prefix == nil then
            prefix = ""
        end
        trace(prefix .. "{", level)
        local newPrefix = prefix .. "    "
        for k, v in pairs(t) do
            if type(v) == "table" then
                trace(newPrefix .. tostring(k) .. ": ", level)
                local p = newPrefix
                printTable(v, p, level)
            else
                trace(newPrefix .. tostring(k) .. ": " .. tostring(v) .. "", level) 
            end
        end
        trace(prefix .. "}", level)
    end
end

PRINT_FRONT_COLOR_DISABLE = "0"
PRINT_FRONT_COLOR_BLACK = "30"
PRINT_FRONT_COLOR_RED = "31"
PRINT_FRONT_COLOR_GREEN = "32"
PRINT_FRONT_COLOR_YELLOW = "33"
PRINT_FRONT_COLOR_BLUE = "34"
PRINT_FRONT_COLOR_PURPLE = "35"
PRINT_FRONT_COLOR_DARK_GREEN = "36"
PRINT_FRONT_COLOR_WHITE = "37"

PRINT_BACK_COLOR_DISABLE = "0"
PRINT_BACK_COLOR_BLACK = "40"
PRINT_BACK_COLOR_RED = "41"
PRINT_BACK_COLOR_GREEN = "42"
PRINT_BACK_COLOR_YELLOW = "43"
PRINT_BACK_COLOR_BLUE = "44"
PRINT_BACK_COLOR_PURPLE = "45"
PRINT_BACK_COLOR_DARK_GREEN = "46"
PRINT_BACK_COLOR_WHITE = "47"

function printLogWithColor(frontColor, backColor, tag, fmt, ...)
    if frontColor == nil then
        frontColor = PRINT_FRONT_COLOR_DISABLE
    end
    if backColor == nil then
        backColor = PRINT_BACK_COLOR_DISABLE
    end

    local t = {
        "[",
        string.upper(tostring(tag)),
        "] ",
        string.format(tostring(fmt), ...)
    }
    trace("\27[" .. backColor .. ";" .. frontColor .. "m" .. table.concat(t) .. "\27[0m")
end

function printInfoWithColor(frontColor, backColor, fmt, ...)
    if DEBUG <= 0 then
        return
    end

    if device.platform == "ios" or device.platform == "android" then
        printLog("INFO", fmt, ...)
    else
        printLogWithColor(frontColor, backColor, "INFO", fmt, ...)
    end
end

function printTableWithColor(frontColor, backColor, t, prefix, level)
    if device.platform == "ios" or device.platform == "android" then
        printTable(t, prefix, level)
        return
    end

    if DEBUG > 0 and t ~= nil and type(t) == "table" then
        if frontColor == nil then
            frontColor = PRINT_FRONT_COLOR_DISABLE
        end
        if backColor == nil then
            backColor = PRINT_BACK_COLOR_DISABLE
        end

        if prefix == nil then
            prefix = ""
        end
        trace("\27[" .. backColor .. ";" .. frontColor .. "m" .. prefix .. "{" .. "\27[0m", level)
        local newPrefix = prefix .. "    "
        for k, v in pairs(t) do
            if type(v) == "table" then
                trace("\27[" .. backColor .. ";" .. frontColor .. "m" .. newPrefix .. tostring(k) .. ": " .. "\27[0m", level)
                local p = newPrefix
                printTableWithColor(frontColor, backColor, v, p, level)
            else
                local str = tostring(v)
                str = string.gsub(str,"%%", "%%%%")
                trace("\27[" .. backColor .. ";" .. frontColor .. "m" .. newPrefix .. tostring(k) .. ": " .. str .. "" .. "\27[0m", level)
            end
        end
        trace("\27[" .. backColor .. ";" .. frontColor .. "m" .. prefix .. "}" .. "\27[0m", level)
    end
end

function printError(fmt, ...)
    printLogWithColor(PRINT_FRONT_COLOR_RED, nil, "ERR", fmt, ...)
    trace("\27[" .. PRINT_BACK_COLOR_DISABLE .. ";" .. PRINT_FRONT_COLOR_RED .. "m" .. debug.traceback("", 2) .. "\27[0m", level)
end

if device.platform == "windows" then

    PRINT_FRONT_COLOR_DISABLE = 7
    PRINT_FRONT_COLOR_BLACK = 0
    PRINT_FRONT_COLOR_RED = 4
    PRINT_FRONT_COLOR_GREEN = 2
    PRINT_FRONT_COLOR_YELLOW = 6
    PRINT_FRONT_COLOR_BLUE = 1
    PRINT_FRONT_COLOR_PURPLE = 5
    PRINT_FRONT_COLOR_DARK_GREEN = 3
    PRINT_FRONT_COLOR_WHITE = 7

    PRINT_BACK_COLOR_DISABLE = 0
    PRINT_BACK_COLOR_BLACK = 0
    PRINT_BACK_COLOR_RED = 4*16
    PRINT_BACK_COLOR_GREEN = 2*16
    PRINT_BACK_COLOR_YELLOW = 6*16
    PRINT_BACK_COLOR_BLUE = 1*16
    PRINT_BACK_COLOR_PURPLE = 5*16
    PRINT_BACK_COLOR_DARK_GREEN = 3*16
    PRINT_BACK_COLOR_WHITE = 7*16

    printLogWithColor = function (frontColor, backColor, tag, fmt, ...)
        if frontColor == nil then
            frontColor = PRINT_FRONT_COLOR_DISABLE
        end
        if backColor == nil then
            backColor = PRINT_BACK_COLOR_DISABLE
        end

        local t = {
            "[",
            string.upper(tostring(tag)),
            "] ",
            string.format(tostring(fmt), ...)
        }

        if ENABLE_CONSOLE_COLOR == true then
            QUtility:setConsoleColor(backColor + frontColor)
        end
        trace(table.concat(t))
        if ENABLE_CONSOLE_COLOR == true then
            QUtility:setConsoleColor(PRINT_BACK_COLOR_DISABLE + PRINT_FRONT_COLOR_DISABLE)
        end
    end

    printInfoWithColor = function (frontColor, backColor, fmt, ...)
        if DEBUG <= 0 then
            return
        end

        if device.platform == "ios" or device.platform == "android" then
            printLog("INFO", fmt, ...)
        else
            printLogWithColor(frontColor, backColor, "INFO", fmt, ...)
        end
    end

    printTableWithColor = function (frontColor, backColor, t, prefix, isColorChanged, level)
        if device.platform == "ios" or device.platform == "android" then
            printTable(t, prefix)
            return
        end

        if DEBUG > 0 and t ~= nil and type(t) == "table" then
            if frontColor == nil then
                frontColor = PRINT_FRONT_COLOR_DISABLE
            end
            if backColor == nil then
                backColor = PRINT_BACK_COLOR_DISABLE
            end

            if prefix == nil then
                prefix = ""
            end
            if isColorChanged == nil then
                if ENABLE_CONSOLE_COLOR == true then
                    QUtility:setConsoleColor(backColor + frontColor)
                end
            end
            trace(prefix .. "{", level)
            local newPrefix = prefix .. "    "
            for k, v in pairs(t) do
                if type(v) == "table" then
                    trace(newPrefix .. tostring(k) .. ": ", level)
                    local p = newPrefix
                    printTableWithColor(frontColor, backColor, v, p, true, level)
                else
                    local str = tostring(v)
                    str = string.gsub(str,"%%", "%%%%")
                    trace(newPrefix .. tostring(k) .. ": " .. str .. "", level)
                end
            end
            trace(prefix .. "}", level)
            if isColorChanged == nil then
                if ENABLE_CONSOLE_COLOR == true then
                    QUtility:setConsoleColor(PRINT_BACK_COLOR_DISABLE + PRINT_FRONT_COLOR_DISABLE)
                end
            end
        end
    end

    printError = function (fmt, ...)
        if ENABLE_CONSOLE_COLOR == true then
            QUtility:setConsoleColor(PRINT_BACK_COLOR_DISABLE + PRINT_FRONT_COLOR_RED)
        end
        printLog("ERR", fmt, ...)
        trace(debug.traceback("", 2), level)
        if ENABLE_CONSOLE_COLOR == true then
            QUtility:setConsoleColor(PRINT_BACK_COLOR_DISABLE + PRINT_FRONT_COLOR_DISABLE)
        end
    end

end

local _audio_playMusic = audio.playMusic
local _audio_playSound = audio.playSound

local function _audio_ignore_playMusic( ... )
    
end

local function _audio_ignore_playSound( ... )
    return 0
end

local function _audio_playMusic_ext(filename, isLoop)
    if not filename then
        printError("audio.playMusic() - invalid filename")
        return
    end
    if type(isLoop) ~= "boolean" then isLoop = true end

    -- @qinyuanji, in android release music right after stop may cause crash. 
    -- Please refer to http://stackoverflow.com/questions/18224097/android-mediaplayer-nullpointerexception
    if device.platform ~= "android" then
        audio.stopMusic(true)
    end
    
    if DEBUG > 1 then
        printInfo("audio.playMusic() - filename: %s, isLoop: %s", tostring(filename), tostring(isLoop))
    end
    SimpleAudioEngine:sharedEngine():playBackgroundMusic(filename, isLoop)
end

local soundFiles = {}
local function _audio_playSound_ext(filename, isLoop, volume, prjor)
    if not filename then
        printError("audio.playSound() - invalid filename")
        return
    end
    soundFiles[filename] = 1
    return _audio_playSound(filename, isLoop, volume, prjor)
end

local function _audio_unloadAllSound()
    for fileName, count in pairs(soundFiles) do
        audio.unloadSound(fileName)
    end
    soundFiles = {}
end

function resetAudioFunctions(isSkip)
    if isSkip == true then
        audio.playMusic = _audio_ignore_playMusic
        audio.playSound = _audio_ignore_playSound
    else
        audio.playMusic = _audio_playMusic_ext
        audio.playSound = _audio_playSound_ext
    end

    audio.unloadAllSound = _audio_unloadAllSound
end

-- By Kumo 战斗编辑器部分按钮连点功能
function newTTFLabelMenuItem(params)
    local p = clone(params)
    p.x, p.y = nil, nil
    local label = ui.newTTFLabel(p)

    local listener = params.listener
    local tag      = params.tag
    local x        = params.x
    local y        = params.y
    local sound    = params.sound
    local count = 0
    local item = CCMenuItemLabel:create(label)
    if item then
        if type(listener) == "function" then
            -- item:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(tag)
            --     if sound then audio.playSound(sound) end
            --     listener(tag)
            -- end)
            item:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(tag) 
                if count > 60 then
                    listener(tag)
                elseif count == 1 then
                    if sound then audio.playSound(sound) end
                    listener(tag)
                    count = count + 1
                else
                    count = count + 1
                end 
            end)
            item:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
                 if event.name == "began" then
                    count = 0
                    item:scheduleUpdate()
                    return true
                end
                if event.name == "ended" then
                    count = 0
                    item:unscheduleUpdate()
                end
            end)
        end
        if x and y then item:setPosition(x, y) end
        if tag then item:setTag(tag) end
    end
    return item
end

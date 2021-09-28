--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-23
-- Time: 上午11:45
-- To change this template use File | Settings | File Templates.
--

function c_func(f, ...) 
    local args1 = {... }

    return function()
        return f(unpack(args1))
    end
end

function readTable(data_table,index,msg)
    local outMsg = msg or ""    
    if(type(data_table[index]) == "nil") then
        if(GAME_DEBUG == true) then
            CCMessageBox("读表错误,id为"..index, outMsg)
        end
    else
        return data_table[index]
    end
end

function GameAssert(isAs,str)
    if GAME_DEBUG == true then
        assert(isAs, str)
    end
end

function logOut(xxx,dumpData)
    print(xxx)
    if dumpData ~= nil then
        -- dump(dumpData)
    end
end

function RegNotice(target, listener, key)
    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(target, listener, key)
end

function UnRegNotice(target, key)
    CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(target, key)
end

function PostNotice(key,msg)
    if msg == nil then
        CCNotificationCenter:sharedNotificationCenter():postNotification(key)
    else

        
        CCNotificationCenter:sharedNotificationCenter():postNotification(key,msg)
    end
end

function setControlBtnEvent(btn,func,soundFunc)
    btn:addHandleOfControlEvent(function(eventName,sender)       

        sender:runAction(transition.sequence({
            -- CCScaleTo:create(0.08, 0.8),
            CCCallFunc:create(function()
                if soundFunc~= nil then
                    soundFunc()
                else
                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
                end
                func()
            end),
            -- CCScaleTo:create(0.1, 1.2),
            -- CCScaleTo:create(0.02, 1)
            }))
    end,
    CCControlEventTouchUpInside)

end


local SEC_OF_MIN  = 60
local SEC_OF_HOUR = 3600


function format_time(t)
    local hour = math.floor(t / SEC_OF_HOUR)
    local min  = math.floor ((t % SEC_OF_HOUR) / SEC_OF_MIN)
    local sec  = t - hour * SEC_OF_HOUR - min * SEC_OF_MIN
    return string.format("%02d:%02d:%02d", hour, min, sec)
end

function format_time_unit(t)
    local hour = math.floor(t / SEC_OF_HOUR)
    local min  = math.floor ((t % SEC_OF_HOUR) / SEC_OF_MIN)
    local sec  = t - hour * SEC_OF_HOUR - min * SEC_OF_MIN
    return string.format("%02d小时%02d分%02d秒", hour, min, sec)
end

function arrangeTTF(cells)
--各种讨厌的排一排的TTF
    for i  = 1,#cells do
        if i ~= 1 then
            cells[i]:setPosition(cells[i-1]:getPositionX() + cells[i-1]:getContentSize().width , cells[i-1]:getPositionY())
        end
    end
end

function arrangeTTFByPosX(cells)
--按照X位置排序
    for i  = 1,#cells do
        if i ~= 1 then
            cells[i]:setPositionX(cells[i-1]:getPositionX() + cells[i-1]:getContentSize().width)
        end
    end
end


function copyNodePos(nodes)
    local orNode = nodes[1]
    local tarNode = nodes[2]
    local anchor = tarNode:getAnchorPoint()
    orNode:setAnchorPoint(anchor)
    orNode:setPosition(tarNode:getPositionX(),tarNode:getPositionY())
end




local sharedDirector = CCDirector:sharedDirector()

local sceneLevel = 1
function push_scene(scene)
    assert(scene, "Scene is nil")
--
--    printf(debug.traceback())
    sceneLevel = sceneLevel + 1
    printf("push scene")
    sharedDirector:pushScene(scene)
end

function pop_scene()
    printf("pop scene: " .. tostring(display.getRunningScene().__cname))

    if sceneLevel > 1 then
        sceneLevel = sceneLevel - 1
        sharedDirector:popScene()
    end
end

function show_tip_label(str, delay)
    print(str)
    local tipLabel = require("utility.TipLabel").new(str,  delay)
    display.getRunningScene():addChild(tipLabel, 3000000)
end

function get_table_len(t)
    local i = 0
    for k, v in pairs(t) do
        i = i + 1
    end
    return i
end

function res_path(path)

    if CCFileUtils:sharedFileUtils():isAbsolutePath(path) then
        local pos, _  = string.find(path, "/res/")
        if pos then
            local tmpPath = device.writablePath .. string.sub(path, pos + 1)
            if io.exists(tmpPath) then
                return tmpPath
            else
                return path
            end
        else
            return path
        end
    else
        for _, v in ipairs(SearchPath) do
            local tmpPath = device.writablePath .. v ..path
            if io.exists(tmpPath) then
                return tmpPath
            end
        end
        return CCFileUtils:sharedFileUtils():fullPathForFilename(path)
    end
end

function setNodeSize(node,width,height)
    local tarNode = node
    local orWidth = node:getContentSize().width
    local orHeight = node:getContentSize().height

    if width ~= nil then
        node:setScaleX(width/orWidth)
    end
    if height ~= nil then
        node:setScaleY(height/orHeight)
    end
end


function setExpectSize(param)
    local tarNode = param.node
    
    local tarWidth = param.width
    local tarHeight = param.height

    local orWidth = tarNode:getContentSize().width
    local orHeight = tarNode:getContentSize().height

    local scaleX = tarWidth/orWidth
    local scaleY = tarHeight/orHeight

    if scaleX > scaleY then
        tarNode:setScale(scaleX)
    else
        tarNode:setScale(scaleY)
    end
end

function safe_call(f, message)
    if type(f) == "function" then
        local err, ret = xpcall(f, function()
            __G__TRACKBACK__(message or 'error:')
        end)
        if err then
            return ret
        end
    else
        show_tip_label("请确定f是个函数")
    end
end

function resetctrbtnimage(btn, image)
    btn:setBackgroundSpriteForState(display.newScale9Sprite(image), CCControlStateNormal)
    btn:setBackgroundSpriteForState(display.newScale9Sprite(image), CCControlStateHighlighted)
    btn:setBackgroundSpriteForState(display.newScale9Sprite(image), CCControlStateDisabled)
end

function resetbtn(btn, parentNode, zorder)
    local closepos= btn:convertToWorldSpace(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    btn:retain()
    btn:removeFromParentAndCleanup(false)
    btn:setPosition(parentNode:convertToNodeSpace(closepos))
    parentNode:addChild(btn, zorder)
    btn:release()
    btn:setTouchEnabled(true)
end

function isrexueproj()
    if device.platform == "android" then
        if CSDKShell.GetSDKTYPE() == SDKType.ANDROID_TENCENT_RXQZ then
            return true
        end
    end
    return false
end


function debug_print_attr(data, param)
    printf("===============HelloWorld=======================")
    for k, v in ipairs(data) do
        printf("{")
        for a, b in pairs(param) do

            if v[b] ~= nil then
                printf(string.format("  %s = %s", b, tostring(v[b])))
            end

        end
        printf("}")
    end
    printf("================end=====================")
end

if __G__TRACKBACK__ then
    __G__TRACKBACK__ = function (errorMessage)
        printf("----------------------------------------")
        printf("LUA ERROR: " .. tostring(errorMessage) .. "\n")
        printf(debug.traceback("", 2))
        printf("----------------------------------------")
        NetworkHelper.request(ServerInfo.LOG_URL, {
            info = string.urlencode(errorMessage .. "       " .. debug.traceback("", 2)),

        },function() end, "GET", true)
    end
end

function addbackevent(target)
    if device.platform == "android" then
        local layer = display.newLayer()
        layer:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                CSDKShell.back(function(a)

                end)
            end
        end, 0.5)
        target:addChild(layer)
        layer:setKeypadEnabled(true)
    end
end


-- 系统时间
function GetSystemTime( ... )
    local curTime = os.date("%H:%M",os.time())
    return curTime    
end

-- 字符串中是否含有中文
function isCnChar( str )
    local len  = string.len(str)
    local left = len
    local cnt  = 0

    for i=1,len do
        local curByte = string.byte(str, i)
        -- '￥' = 239
        if(curByte > 127) then
            dump(curByte)
            return true
        end
    end

    return false
end

-- 字符串是否含有非法字符
function hasIllegalChar( str )
    local illegalStr = ""--"`-=[]\\;',./～！@#￥%…&×（）—『』|：“”《》？·【】、；’‘，。~!$^*()_+{}:\"<>?"

    local len = string.len(illegalStr)
    local curByte = nil
    for i=1, len do
        curByte = string.sub(str,i)
        printf(curByte)
        contain = string.find(str, curByte)
        printf(contain)
        if(contain ~= nil) then
            printf("hasIllegalChar")
            return true
        end
    end

    return false
end
-- 
-- 全局方法，都是一些工具性的方法 
-- author: zhouhongjie@apowo.com
-- date: 2014-02-20 09:56:10
--

--- 多语言方法
-- @param text 文本内容
-- @return 返回翻译之后的文本
local function __(text)
    return text
end

--- 判断当前是否存在多语言文件
--if CCFileUtils:sharedFileUtils():isFileExist(LANG) then
--    __ = assert(require("framework.cc.utils.Gettext").gettextFromFile(LANG))
--end

local function _(text, ...)
    text = __(text)
    return string.format(text, ...)
end

--- 使用二分法查找
-- @param table 数据表
-- @param key 查找的键，默认是type
-- @param val 查找的值
-- @return 数据表中的元素
function queryByType(table, key, val)
    if table then
        key = key or 'type'
        local leftIndex = 1
        local middleIndex = 1
        local rightIndex = #table

        while rightIndex >= leftIndex do
            middleIndex = checkint((rightIndex + leftIndex) / 2)
            if tonumber(table[middleIndex][key]) > val then
                rightIndex = middleIndex - 1
            else
                leftIndex = middleIndex + 1
            end
        end
        return table[leftIndex - 1]
    end
end

--- 根据type读取相应的配置文件
-- @param propType 物品Type
-- @param configType 配置文件，取lua文件名
-- @return 返回配置文件中物品的配置信息
function getConfig(propType, configType)
    local config = require('app.config.' .. configType)
    if config then
        return queryByType(config, 'ID', checkint(propType))
    end
end

--- 场景onEnter里调用该方法，如果是android系统，要在场景里增加一个响应按键的layer
-- @param scene 当前场景
function sceneOnEnter(scene)
    -- 友盟统计
    cc.analytics:doCommand({command = "beginScene", args = {sceneName = scene.name}})
    if debugLayer:getParent() then
        debugLayer:removeFromParentAndCleanup(false)
    end

    -- 添加一个debug层
    debugLayer:addTo(scene, 9999)

    -- 添加UI层
    uiManager:addUIContainerTo(scene)
    
    if device.platform == "android" then
        -- avoid unmeant back
        scene:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then app.exit() end
            end)
            scene:addChild(layer)

            layer:setKeypadEnabled(true)
        end, 0.5)
    end
end

--- 场景onExit里调用该方法，在场景撤离舞台后的一些逻辑
-- @param scene 场景
function sceneOnExit(scene)
    cc.analytics:doCommand({command = "endScene", args = {sceneName = scene.name}})

    -- 清除数据
    CCArmatureDataManager:purge()
    SceneReader:sharedSceneReader():purge()
    ActionManager:purge()
    GUIReader:purge()
end

--- 切换场景
-- @param scene 新的场景
function replaceScene(scene)
	-- 去掉所有未完成的动作
	CCDirector:sharedDirector():getActionManager():removeAllActions()
	display.replaceScene(scene, "fade", 0.5, ccc3(255,255, 255))
end

--- 获取自动换行的string
-- @param str 源String
-- @param fontName 字体名
-- @param fontSize 字体大小
-- @param lineWidth 一行的宽度
-- @return 带有换行符的字符串
function getWrapStr(str, fontName, fontSize, lineWidth)
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local label = CCLabelTTF:create('', fontName, fontSize)

    local strLen = #str
    local index = strLen
    local indexList = { }
    local tmpLineWidth = lineWidth
    for i = 1, string.len(str) do
        local tmp = string.byte(str, -index)
        local arrLen = #arr
        while arr[arrLen] do
            if tmp == nil then
                break
            end
            if tmp >= arr[arrLen] then
                index = index - arrLen
                break
            end
            arrLen = arrLen - 1
        end
        tmp = strLen - index
        if table.indexof(indexList, tmp) == false then
            indexList[#indexList + 1] = tmp
        end
    end
    
    -- 指定一个差不多的初始值 numStr（可以用指定宽度 width 除以字体大小），
    -- 截出 0 到 numStr 位置的字符串，用 getStrWidth 计算宽度，如果比我们指定的宽度 width 大，numStr--，
    -- 继续比较；否则 numStr++ 继续。直到 numStr 个字符宽度和我们指定宽度刚好相等（很小的概率），
    -- 或者 numStr 个字符长度不够，但 numStr+1 长度又多了的情况下，
    -- 可以确定这一行可以放这 numStr 个字符。然后继续处理下一行，直至字符串结束。
    local newStr = ''
    local numIndex = #indexList
    -- 每一行理论上的字数
    local numStr = checkint(lineWidth / fontSize)

    -- 截取一行文字的索引值
    local startIndex = 1
    local endIndexInIndexList = numStr
    if endIndexInIndexList > numIndex then
        endIndexInIndexList = numIndex
    end
    local endIndex = indexList[endIndexInIndexList]
    -- 一行文字
    local lineStr = ''
    local lineW, lineH = 0, 0
    local maxLineWidth = 1
    local minLineWidth = lineWidth + 1000
    -- 行数
    local lineNum = 0
    label:setString(lineStr)
    local size = nil
    while endIndexInIndexList <= numIndex do
        lineStr = string.sub(str, startIndex, endIndex)
        label:setString(lineStr)
        size = label:getContentSize()
        lineW, lineH = size.width, size.height
        if lineW > lineWidth then
            -- 要减少一个字符，直到w <= lineWidth
            repeat
                endIndexInIndexList = endIndexInIndexList - 1
                endIndex = indexList[endIndexInIndexList]
                lineStr = string.sub(str, startIndex, endIndex)
                label:setString(lineStr)
                size = label:getContentSize()
                lineW, lineH = size.width, size.height
            until lineW <= lineWidth
        elseif lineW < lineWidth then
            -- 要增加一个字符，直到w >= lineWidth
            repeat
                endIndexInIndexList = endIndexInIndexList + 1
                if endIndexInIndexList > numIndex then
                    break
                end
                endIndex = indexList[endIndexInIndexList]
                lineStr = string.sub(str, startIndex, endIndex)
                label:setString(lineStr)
                size = label:getContentSize()
                lineW, lineH = size.width, size.height
            until lineW >= lineWidth
            -- 刚刚超出了预设宽度，所以减去一个字符
            endIndexInIndexList = endIndexInIndexList - 1
            endIndex = indexList[endIndexInIndexList]
            lineStr = string.sub(str, startIndex, endIndex)
        end
        if maxLineWidth < lineW then
            maxLineWidth = lineW
        end
        if minLineWidth > lineW then
            minLineWidth = lineW
        end
        -- 一行文字确定完毕
        newStr = newStr .. lineStr .. '\n'
        lineNum = lineNum + 1
        -- 继续判断后面的文字
        startIndex = endIndex + 1
        if endIndexInIndexList >= numIndex then
            break
        end
        endIndexInIndexList = endIndexInIndexList + numStr
        if endIndexInIndexList > numIndex then
            endIndexInIndexList = numIndex
        end
        endIndex = indexList[endIndexInIndexList]
    end
    return newStr, maxLineWidth, lineNum, minLineWidth, lineH
end

--- 截取某个宽度的string
-- @param str 源String
-- @param fontName 字体名
-- @param fontSize 字体大小
-- @param lineWidth 宽度
-- @return 截取出的字符串
-- @return 剩下的字符串
function getSubStrByWidth(str, fontName, fontSize, lineWidth)
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}

    local strLen = #str
    local index = strLen
    local indexList = { }
    local tmpLineWidth = lineWidth
    for i = 1, string.len(str) do
        local tmp = string.byte(str, -index)
        local arrLen = #arr
        while arr[arrLen] do
            if tmp == nil then
                break
            end
            if tmp >= arr[arrLen] then
                index = index - arrLen
                break
            end
            arrLen = arrLen - 1
        end
        tmp = strLen - index
        if table.indexof(indexList, tmp) == false then
            indexList[#indexList + 1] = tmp
        end
    end
    
    local label = CCLabelTTF:create(str, fontName, fontSize)
    if label:getContentSize().width <= lineWidth then
        -- 不用截
        return str, nil, label:getContentSize().height
    else
        local numIndex = #indexList
        -- 理论上的字数
        local numStr = checkint(lineWidth / fontSize)
        if numStr < 1 then
            return nil, str, 0
            -- numStr = 1
        end
        -- 截取一行文字的索引值
        local startIndex = 1
        local endIndexInIndexList = numStr
        if endIndexInIndexList > numIndex then
            endIndexInIndexList = numIndex
        end
        local endIndex = indexList[endIndexInIndexList]

        -- 一行文字
        local lineStr = string.sub(str, startIndex, endIndex)
        local lineW = 1
        label:setString(lineStr)
        if lineW > lineWidth then
            -- 要减少一个字符，直到w <= lineWidth
            repeat
                endIndexInIndexList = endIndexInIndexList - 1
                endIndex = indexList[endIndexInIndexList]
                lineStr = string.sub(str, startIndex, endIndex)
                label:setString(lineStr)
                lineW = label:getContentSize().width
            until lineW <= lineWidth
        elseif lineW < lineWidth then
            -- 要增加一个字符，直到w >= lineWidth
            repeat
                endIndexInIndexList = endIndexInIndexList + 1
                if endIndexInIndexList > numIndex then
                    break
                end
                endIndex = indexList[endIndexInIndexList]
                lineStr = string.sub(str, startIndex, endIndex)
                label:setString(lineStr)
                lineW = label:getContentSize().width
            until lineW >= lineWidth
            -- 刚刚超出了预设宽度，所以减去一个字符
            endIndexInIndexList = endIndexInIndexList - 1
            endIndex = indexList[endIndexInIndexList]
            lineStr = string.sub(str, startIndex, endIndex)
        end
        return lineStr, string.sub(str, endIndex + 1), label:getContentSize().height
    end
end

--- 获取当前年月日时分秒
function getDate()
    return os.date("%Y-%m-%d %H:%M:%S")
end

--- 解析各种奖励, 本来是想用if-elseif来合并到一起，但是呢考虑到好多不必要的if判断, 还是把各种奖励解析
-- 拆开来，不过都放在globalFunction中，方便查找和修改，如果这种做法不对，请鸿杰大神指出
function getSignAwardStr(awards)
    local result = nil
    print("=============开始解析签到奖励==============")
    for i,v in ipairs(awards) do
        print("奖励type值: " .. v.type)
        print("奖励name:" .. v.name)
        print("奖励数量value：" .. v.value)
    end
    print("=============签到奖励解析完毕==============")
end

--[[
function object:creareMask(pData, pOrigin)
    local function setBlend(obj, src, dst)
        local b = ccBlendFunc:new()
        b.src = src
        b.dst = dst
        obj:setBlendFunc(b)
    end
    
    local myLayer = display.newColorLayer(ccc4(0,0,0,pOrigin.alpha or 230))
    --myLayer:runAction(CCFadeIn:create(0.3))
    --self:addChild(myLayer)
    
    local pMask
    --创建遮罩图片
    pMask = display.newSprite("#block_mask.png")
    pMask:setAnchorPoint(ccp(0,0))
    pMask:setPosition(100,100)
    setBlend(pMask, GL_ZERO, GL_ONE_MINUS_SRC_ALPHA)

    --创建干净的画板
    local pRt = CCRenderTexture:create(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
    self:addChild(pRt);
    pRt:setPosition(CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    pRt:setOpacity(0)
    pRt:runAction(CCFadeIn:create(1))

    pRt:begin()
    myLayer:visit()
    pMask:visit()
    pRt:endToLua()
end
]]
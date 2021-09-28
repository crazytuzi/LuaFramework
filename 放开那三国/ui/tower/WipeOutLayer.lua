-- FileName: WipeOutLayer.lua 
-- Author: zhang zihang
-- Date: 14-1-8
-- Purpose: 扫荡界面

module("WipeOutLayer", package.seeall)

require "script/ui/tower/TowerCache"

local bgLayer = nil
local levelInputBox = nil
local inputText = nil

function init()
	bgLayer = nil
    levelInputBox = nil
    inputText = nil
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		-- print("began")
	    return true
    elseif (eventType == "moved") then
  
    else
        -- print("end")
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then

		bgLayer:unregisterScriptTouchHandler()
	end
end

function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	bgLayer:removeFromParentAndCleanup(true)
	bgLayer = nil
end

-- 扫荡回调
function sweepCallback( cbFlag, dictData, bRet )
    if(dictData.err == "ok")then
        bgLayer:removeFromParentAndCleanup(true)
        bgLayer = nil
        TowerCache.setTowerInfo(dictData.ret)
        -- 代理
        TowerMainLayer.startSweepDelegate(inputText)
    end
end

-- 
function okCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    local level_text = levelInputBox:getText()
    
    if(level_text == nil)then
        AnimationTip.showTip(GetLocalizeStringBy("key_2954"))
        return
    end
    level_text = string.gsub(level_text, " ", "")
    if(level_text == nil or level_text == "")then
        AnimationTip.showTip(GetLocalizeStringBy("key_2954"))
        return
    end
    if(string.isIntergerByStr(level_text) == false )then
        AnimationTip.showTip(GetLocalizeStringBy("key_2542"))
        return
    end

    level_text = tonumber(level_text)
    if(level_text > tonumber(TowerCache.getTowerInfo().max_level) )then
        AnimationTip.showTip(GetLocalizeStringBy("key_3066").. TowerCache.getTowerInfo().max_level .. GetLocalizeStringBy("key_2073"))
        return
    end

    if(level_text < tonumber(TowerCache.getTowerInfo().cur_level) )then
        AnimationTip.showTip(GetLocalizeStringBy("key_3377").. (tonumber(TowerCache.getTowerInfo().cur_level) ) .. GetLocalizeStringBy("key_2073"))
        return
    end
    inputText = level_text
    -- 发送请求
    local args = Network.argsHandler(TowerCache.getTowerInfo().cur_level, level_text)
    RequestCenter.tower_sweep(sweepCallback, args)

end

function showLayer()
	init()

	bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	bgLayer:registerScriptHandler(onNodeEvent)

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(bgLayer,1500)

    require "script/ui/main/MainScene"
    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(450,300)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local breakSayBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    breakSayBg:setContentSize(mySize)
    breakSayBg:setScale(myScale)
    breakSayBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    breakSayBg:setAnchorPoint(ccp(0.5,0.5))
    bgLayer:addChild(breakSayBg)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    breakSayBg:addChild(menu,99)

    local width = nil
    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(breakSayBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(ccp(width,54))
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local okBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    okBtn:setPosition(ccp(breakSayBg:getContentSize().width*0.25,35))
    okBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(okBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    width = (okBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(ccp(width,54))
    okBtn:addChild(closeLabel)
    okBtn:registerScriptTapHandler(okCb)
    
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local content = CCLabelTTF:create(GetLocalizeStringBy("key_3216"), g_sFontName ,24)
    content:setColor(ccc3(0x78,0x25,0x00))
    levelInputBox = CCEditBox:create(CCSizeMake(70,50), CCScale9Sprite:create("images/common/bg/search_bg.png"))
    levelInputBox:setTouchPriority(-551)
    -- levelInputBox:setPlaceHolder(GetLocalizeStringBy("key_3398"))
    levelInputBox:setText(TowerCache.getTowerInfo().max_level)
    levelInputBox:setFont(g_sFontPangWa,25)
    levelInputBox:setFontColor(ccc3(0xff,0xff,0xff))
    levelInputBox:setPlaceholderFontColor(ccc3(0xff,0xff,0xff))
    levelInputBox:setMaxLength(3)
    levelInputBox:setInputMode(kEditBoxInputModeNumeric)
    --levelInputBox:setInputFlag(kEditBoxInputModePhoneNumber)

    local content2 = CCLabelTTF:create(GetLocalizeStringBy("key_1659"), g_sFontName ,24)
    content2:setColor(ccc3(0x78,0x25,0x00))

    require "script/utils/BaseUI"
    local aleteNode = BaseUI.createHorizontalNode({content,levelInputBox,content2})
    aleteNode:setAnchorPoint(ccp(0.5, 0.5))
    aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height-80))
    breakSayBg:addChild(aleteNode)

    local wenzi = CCRenderLabel:create(GetLocalizeStringBy("key_1173"), g_sFontPangWa, 25, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    wenzi:setColor(ccc3(0x78,0x25,0x00))
    wenzi:setAnchorPoint(ccp(0.5,0.5))
    wenzi:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2))
    breakSayBg:addChild(wenzi)
end

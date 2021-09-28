-- Filename：	PetDescription.lua
-- Author：		zhang zihang
-- Date：		2014-4-11
-- Purpose：		宠物说明
module ("PetDescription", package.seeall)
local _bgLayer
local _myScale
local _mySize
local desInfo
local lineH

local function init()
	_bgLayer = nil
	_mySize = nil
	_myScale = nil
	desInfo = nil
	lineH = nil
end

local function onTouchesHandler(eventType, x, y)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
  		print("moved")
    else
        print("end")
	end
end

local function onNodeEvent(event)
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

local function createUI()
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local breakSayBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    breakSayBg:setContentSize(_mySize)
    breakSayBg:setScale(_myScale)
    breakSayBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    breakSayBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(breakSayBg)

    local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3223"), g_sFontPangWa,35,2,ccc3(0xff,0xff,0xff),type_shadow)
	labelTitle:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height-20))
	labelTitle:setAnchorPoint(ccp(0.5,1))
	labelTitle:setColor(ccc3(0x78,0x25,0x00))
	breakSayBg:addChild(labelTitle)

	require "db/DB_Pet_cost"
	local desInfo = DB_Pet_cost.getDataById(1).description

	local EXPL = CCLabelTTF:create(tostring(desInfo), g_sFontName, 24, CCSizeMake(560, lineH), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	EXPL:setPosition(ccp(breakSayBg:getContentSize().width/2,breakSayBg:getContentSize().height-80))
	EXPL:setAnchorPoint(ccp(0.5,1))
	EXPL:setColor(ccc3(0x78,0x25,0x00))
	breakSayBg:addChild(EXPL)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    breakSayBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_mySize.width*1.03,_mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)
end

local function counLine(str)
	local strLen = 0
	local i =1
	local enter = 0
	while i<= #str do
		if(string.byte(str,i) > 127) then
			-- 汉字
			strLen = strLen + 1
			i= i+ 3
		elseif(string.byte(str,i) == 10) then
			--换行符
			i =i+1
			enter = enter+1
		elseif(string.byte(str,i) == 32) then
			strLen = strLen + 1/3
			i = i+1
		else
			--英文
			i =i+1
			strLen = strLen + 1
		end
	end

	--21号字
	local linNum = math.ceil(strLen/21)+enter
	local linHeight = linNum*23

	return linHeight
end

function showLayer()
	init()

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999)

    require "db/DB_Pet_cost"
	desInfo = DB_Pet_cost.getDataById(1).description

	lineH = counLine(tostring(desInfo))

	require "script/ui/main/MainScene"
    _myScale = MainScene.elementScale
	_mySize = CCSizeMake(620,lineH+100)

	createUI()
end

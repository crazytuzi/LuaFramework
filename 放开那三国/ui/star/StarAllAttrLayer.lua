-- Filename：	StarAllAttrLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-13
-- Purpose：		属性总览

module ("StarAllAttrLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"

require "script/utils/LuaUtil"
require "script/ui/main/MainScene"

require "script/ui/star/StarUtil"
require "script/libs/LuaCCLabel"
require "script/model/user/UserModel"


local Img_Path = "images/star/"


local _bgLayer 		= nil
local _bgSprite		= nil

-----------------------

local function init()
	_bgLayer 		= nil
	_bgSprite		= nil
end


-- 头部的UI
local function createTopUI()
	local topSprite = CCSprite:create(Img_Path .. "fightbg.png")
	topSprite:setAnchorPoint(ccp(0,1))
	topSprite:setPosition(ccp(0, _bgLayer:getContentSize().height))
	topSprite:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(topSprite)

	-- 战斗力
    local fightValueLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x6b, 0x00, 0x00), type_stroke)
    fightValueLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    fightValueLabel:setPosition(146, 34)
    topSprite:addChild(fightValueLabel,999)

	-- 银币
	local silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()), g_sFontName, 20)
	silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	silverLabel:setAnchorPoint(ccp(0, 0))
	silverLabel:setPosition(ccp(380, 10))
	topSprite:addChild(silverLabel)

	-- 金币
	local goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	goldLabel:setAnchorPoint(ccp(0, 0))
	goldLabel:setPosition(ccp(522, 10))
	topSprite:addChild(goldLabel)
end

-- 创建中间的scrollView
local function createScrollView()

	-- 背景 1
	local fullRect_2 = CCRectMake(0,0,75, 75)
	local insetRect_2 = CCRectMake(30,30,15,15)
	local graySprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect_2, insetRect_2)
	graySprite:setPreferredSize(CCSizeMake(455, 580)) 
	graySprite:setAnchorPoint(ccp(0.5, 0.5))
	graySprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height*0.52))
	-- graySprite:setScale(1/MainScene.elementScale)
	_bgSprite:addChild(graySprite, 1)

	-- scrollView 背景
	local fullRect_3 = CCRectMake(0,0,75, 75)
	local insetRect_3 = CCRectMake(30,30,15,15)
	local scrollSprite = CCScale9Sprite:create("images/star/cell9s.png", fullRect_3, insetRect_3)
	scrollSprite:setPreferredSize(CCSizeMake(440, 560))  -- (CCSizeMake(640, 930))
	scrollSprite:setAnchorPoint(ccp(0.5, 0))
	scrollSprite:setPosition(ccp(graySprite:getContentSize().width/2, 0))
	-- scrollSprite:setScale(MainScene.elementScale)
	graySprite:addChild(scrollSprite)

---- 获得相应的数据
	local displayInfoArr, all_levels, allStars = StarUtil.getTotalStarAttrForDisplay()
	---- 当前拥有名将
	local starAllLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1183") , g_sFontPangWa, 30, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    starAllLabel:setColor(ccc3(0x78, 0x25, 0x00))
    starAllLabel:setPosition(90, 66)
    _bgSprite:addChild(starAllLabel)
    -- 拥有名将个数
    local starNumLabel = CCRenderLabel:create(allStars .. GetLocalizeStringBy("key_2690") , g_sFontName, 30, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    starNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    starNumLabel:setPosition(290, 60)
    _bgSprite:addChild(starNumLabel)

	
	local contentHeight = 52 + 40 * 4 + 32
	if( not table.isEmpty(displayInfoArr)) then
		contentHeight = #displayInfoArr * 40 
	end

	if (contentHeight < 560) then
		contentHeight = 560
	end

	local contentSprite = CCSprite:create()
	contentSprite:setContentSize(CCSizeMake(440, contentHeight))

---- 人物属性加成
-- 	local pLabel = CCLabelTTF:create( GetLocalizeStringBy("key_1633"), g_sFontName, 25)
-- 	pLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
-- 	pLabel:setAnchorPoint(ccp(0, 1))
-- 	pLabel:setPosition(ccp(20, contentHeight - 10))
-- 	contentSprite:addChild(pLabel)

-- ----
-- 	local curAdd, nextLevels, nextAdd = StarUtil.getTotalStarsAddValue(all_levels)

-- 	-- 横线
-- 	local lineSprite_1 = CCSprite:create( Img_Path .. "line.png")
-- 	lineSprite_1:setAnchorPoint(ccp(0, 0))
-- 	lineSprite_1:setPosition(ccp(4, contentHeight - pLabel:getContentSize().height - 15 ))
-- 	contentSprite:addChild(lineSprite_1)

-- 	-- 当前名将好感总和
-- 	local a_label = CCLabelTTF:create( GetLocalizeStringBy("key_1220"), g_sFontName, 23)
-- 	a_label:setColor(ccc3(0x78, 0x25, 0x00))
-- 	a_label:setAnchorPoint(ccp(0, 1))
-- 	a_label:setPosition(ccp(20, contentHeight - 52 - 40 * 0 ))
-- 	contentSprite:addChild(a_label)
-- 	local numLabel_1 = CCLabelTTF:create( all_levels, g_sFontName, 23)
-- 	numLabel_1:setColor(ccc3(0x00, 0x6d, 0x2f))
-- 	numLabel_1:setAnchorPoint(ccp(0, 1))
-- 	numLabel_1:setPosition(ccp(225, contentHeight - 52 - 40 * 0  ))
-- 	contentSprite:addChild(numLabel_1)

-- 	-- 红心
-- 	local heartSprite = CCSprite:create("images/star/intimate/heart_s.png")
-- 	heartSprite:setAnchorPoint(ccp(0, 1))
-- 	heartSprite:setPosition(ccp(275, contentHeight - 52 - 40 * 0))
-- 	contentSprite:addChild(heartSprite)

-- 	-- 武将所有属性
-- 	local a_label_2 = CCLabelTTF:create( GetLocalizeStringBy("key_1479"), g_sFontName, 23)
-- 	a_label_2:setColor(ccc3(0x78, 0x25, 0x00))
-- 	a_label_2:setAnchorPoint(ccp(0, 1))
-- 	a_label_2:setPosition(ccp(20, contentHeight - 52 - 40 * 1 ))
-- 	contentSprite:addChild(a_label_2)
-- 	local numLabel_2 = CCLabelTTF:create( "+" .. curAdd/100 .. "%", g_sFontName, 23)
-- 	numLabel_2:setColor(ccc3(0x00, 0x6d, 0x2f))
-- 	numLabel_2:setAnchorPoint(ccp(0, 1))
-- 	numLabel_2:setPosition(ccp(225, contentHeight - 52 - 40 * 1  ))
-- 	contentSprite:addChild(numLabel_2)

-- 	-- 名将好感总和达到
-- 	local a_label_3 = CCLabelTTF:create( GetLocalizeStringBy("key_1781"), g_sFontName, 23)
-- 	a_label_3:setColor(ccc3(0x78, 0x25, 0x00))
-- 	a_label_3:setAnchorPoint(ccp(0, 1))
-- 	a_label_3:setPosition(ccp(20, contentHeight - 52 - 40 * 2 ))
-- 	contentSprite:addChild(a_label_3)
-- 	local numLabel_3 = CCLabelTTF:create( nextLevels, g_sFontName, 23)
-- 	numLabel_3:setColor(ccc3(0x00, 0x6d, 0x2f))
-- 	numLabel_3:setAnchorPoint(ccp(0, 1))
-- 	numLabel_3:setPosition(ccp(225, contentHeight - 52 - 40 * 2  ))
-- 	contentSprite:addChild(numLabel_3)
-- 	-- 红心
-- 	local heartSprite_2 = CCSprite:create("images/star/intimate/heart_s.png")
-- 	heartSprite_2:setAnchorPoint(ccp(0, 1))
-- 	heartSprite_2:setPosition(ccp(275, contentHeight - 52 - 40 * 2))
-- 	contentSprite:addChild(heartSprite_2)

-- 	-- next武将所有属性
-- 	local a_label_4 = CCLabelTTF:create( GetLocalizeStringBy("key_1479"), g_sFontName, 23)
-- 	a_label_4:setColor(ccc3(0x78, 0x25, 0x00))
-- 	a_label_4:setAnchorPoint(ccp(0, 1))
-- 	a_label_4:setPosition(ccp(20, contentHeight - 52 - 40 * 3 ))
-- 	contentSprite:addChild(a_label_4)
-- 	local numLabel_4 = CCLabelTTF:create( "+" .. nextAdd / 100 .. "%", g_sFontName, 23)
-- 	numLabel_4:setColor(ccc3(0x00, 0x6d, 0x2f))
-- 	numLabel_4:setAnchorPoint(ccp(0, 1))
-- 	numLabel_4:setPosition(ccp(225, contentHeight - 52 - 40 * 3  ))
-- 	contentSprite:addChild(numLabel_4)



---- 武将属性加成
	local s_label = CCLabelTTF:create( GetLocalizeStringBy("key_2121"), g_sFontName, 25)
	s_label:setColor(ccc3(0x00, 0x6d, 0x2f))
	s_label:setAnchorPoint(ccp(0, 1))
	s_label:setPosition(ccp(20, contentHeight - 32 ))
	contentSprite:addChild(s_label)

	-- 横线
	local lineSprite_2 = CCSprite:create( Img_Path .. "line.png")
	lineSprite_2:setAnchorPoint(ccp(0, 0))
	lineSprite_2:setPosition(ccp(4, contentHeight - 32 - 32  ))
	contentSprite:addChild(lineSprite_2)

	-- 武将属性
	if( not table.isEmpty(displayInfoArr)) then
		for k, t_disInfo in pairs(displayInfoArr) do

			local yPosition = contentHeight-32 -32- 10 - (k-1) * 40 
			local titleLabel = CCLabelTTF:create( t_disInfo.name .. ":", g_sFontName, 23)
			titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
			titleLabel:setAnchorPoint(ccp(0, 1))
			titleLabel:setPosition(ccp(20, yPosition))
			contentSprite:addChild(titleLabel)

			local numLabel = CCLabelTTF:create( "+" .. t_disInfo.num, g_sFontName, 23)
			numLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
			numLabel:setAnchorPoint(ccp(0, 1))
			numLabel:setPosition(ccp(225, yPosition ))
			contentSprite:addChild(numLabel)

		end
	end

	-- scrollView
	local attrScrollView = CCScrollView:create()
	attrScrollView:setContainer(contentSprite)
	attrScrollView:setTouchEnabled(true)
	attrScrollView:setDirection(kCCScrollViewDirectionVertical)
	attrScrollView:setViewSize(scrollSprite:getContentSize())
	attrScrollView:setBounceable(true)

	scrollSprite:addChild(attrScrollView)

end

-- 关闭
function closeAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
	-- local starLayer = StarLayer.createLayer()
	-- MainScene.changeLayer(starLayer, "starLayer")
end

-- 中间的sprite
local function createMidUI()

	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	_bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
	_bgSprite:setPreferredSize(CCSizeMake(515, 710))
	_bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.45))
	_bgSprite:setScale(g_fScaleX)
	_bgLayer:addChild(_bgSprite)	

	-- 标题
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_bgSprite:getContentSize().width/2, _bgSprite:getContentSize().height*0.99))
	_bgSprite:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2836"), g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	closeMenuBar:setTouchPriority(-412)
	_bgSprite:addChild(closeMenuBar)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.98, _bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

---- 创建scrollView
	createScrollView()


end 

-- 创建UI
local function createUI()
	-- createTopUI()
	createMidUI()
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("AlertTip.onNodeEvent.......................enter")
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -411, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("AlertTip.onNodeEvent.......................exit")
		_bgLayer:unregisterScriptTouchHandler()
	end
end

---- 
function createLayer()
	init()
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155)) --MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)
	_bgLayer:registerScriptHandler(onNodeEvent)
	
	createUI()

	return _bgLayer
end


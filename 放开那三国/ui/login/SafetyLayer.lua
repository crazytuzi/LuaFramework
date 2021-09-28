-- Filename: SafetyLayer.lua
-- Author: baoxu
-- Date: 2015-04-27
-- Purpose: 安全提示

module ("SafetyLayer", package.seeall)

require "script/ui/tip/AlertTip"

local _sid = nil
local _uid = nil

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

function showSafetyLayer( uid,sid )
	ininlize()
	_sid = sid
	_uid = uid
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_mainLayer = CCLayerColor:create(ccc4(11,11,11,166))
	runningScene:addChild(_mainLayer,999)

	_mainLayer:registerScriptTouchHandler(onTouchesHandler, false, -128, true)
	_mainLayer:setTouchEnabled(true)
 
	local size_more_w = 15

	-- 九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	mainBg= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	require "script/ui/rewardCenter/AdaptTool"
	mainBg:setPreferredSize(CCSizeMake(640,496))
	mainBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height/2))
	mainBg:setAnchorPoint(ccp(0.5,0.5))
	AdaptTool.setAdaptNode(mainBg)
	_mainLayer:addChild(mainBg)


	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	mainBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("bx_1014"), g_sFontPangWa,35,2,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)


	--提示
	local size_infoLabel = CCSizeMake(mainBg:getContentSize().width,50)
	local size_infoLabel_s = CCSizeMake(mainBg:getContentSize().width,40)
	local infoLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("bx_1015"), g_sFontName, 25,size_infoLabel_s,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	infoLabel_1:setPosition(ccp(40, mainBg:getContentSize().height-100))
	infoLabel_1:setColor(ccc3(100, 25, 4))
	infoLabel_1:setAnchorPoint(ccp(0,0.5))
	mainBg:addChild(infoLabel_1)

	local infoLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("bx_1016"), g_sFontName, 20,size_infoLabel_s,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	infoLabel_2:setPosition(ccp(40, mainBg:getContentSize().height-150))
	infoLabel_2:setColor(ccc3(100, 25, 4))
	infoLabel_2:setAnchorPoint(ccp(0,0.5))
	mainBg:addChild(infoLabel_2)

	local infoLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("bx_1017"), g_sFontName, 20,size_infoLabel_s,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	infoLabel_3:setPosition(ccp(40, mainBg:getContentSize().height-200))
	infoLabel_3:setColor(ccc3(100, 25, 4))
	infoLabel_3:setAnchorPoint(ccp(0,0.5))
	mainBg:addChild(infoLabel_3)

	-- 关闭按钮
	local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-551)
	mainBg:addChild(menu,1000)
	_cancelBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	_cancelBtn:setAnchorPoint(ccp(1, 1))
	_cancelBtn:setPosition(ccp(mainBg:getContentSize().width+1, mainBg:getContentSize().height+24))
	_cancelBtn:registerScriptTapHandler(layerCloseCallback)
	menu:addChild(_cancelBtn)


	--绑定邮箱
	require "script/libs/LuaCC"
	local btn_binding = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(250,73),GetLocalizeStringBy("bx_1018"),ccc3(255,222,0))
    btn_binding:setAnchorPoint(ccp(0.5, 0.5))
    btn_binding:setPosition(mainBg:getContentSize().width*0.5, 190)
	menu:addChild(btn_binding)
	btn_binding:registerScriptTapHandler(gotoBinding)

	--进入游戏
	local btn_enter = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(250,73),GetLocalizeStringBy("key_2281"),ccc3(255,222,0))
    btn_enter:setAnchorPoint(ccp(0.5, 0.5))
    btn_enter:setPosition(mainBg:getContentSize().width*0.5, 90)
	menu:addChild(btn_enter)
	btn_enter:registerScriptTapHandler(enterGame)

end

password = nil

function enterGame( ... )
	layerCloseCallback()
end

function gotoBinding( ... )
	-- 绑定
	local dict = config.getBindingParam(Platform.getPid())
    Platform.getSdk():callOCFunctionWithName_oneParam_noBack("openZXYWebView",dict)
end


-- 初始化
function ininlize()

	_tableView = nil
	_tableViewSp = nil
	_cancelBtn = nil
	_mainLayer = nil
	mainBg = nil
end


function layerCloseCallback( ... )
	_mainLayer:removeFromParentAndCleanup(true)
end

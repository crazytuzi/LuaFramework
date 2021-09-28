-- FileName: MyInfoLayer.lua 
-- Author: llp 
-- Date: 14-4-21 
-- Purpose: 查看报名军团 


module("MyInfoLayer", package.seeall)
require "script/ui/lordWar/MySupportLayer"
require "script/ui/lordWar/LordWarData"
local touchPriority                  = nil
local supportItem 					 = nil
local resultItem  				     = nil
local zorder 						 = nil
local supportNumLabel 				 = nil
local supportNumLabelTag 			 = 101	
local reportNode 					 = nil	

function init( ... )
	touchPriority                  	 = nil
	zorder 						 	 = nil
	supportNumLabel 				 = nil
	resultItem  				     = nil
	supportItem 					 = nil
	reportNode 					 	 = nil	
end
-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true    
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

local function getSupportNum( ... )
	-- body
	local cellDataCache = LordWarData.getMySupportInfo()
	local index = 0
	for k,v in pairs(cellDataCache)do
		index = index+1
	end
	return index
end

local function showResult()
	require "script/ui/lordWar/myReport/MyReportNode"
    if(reportNode~=nil)then
    	reportNode:removeFromParentAndCleanup(true)
    	reportNode = nil
    end
	if(reportNode==nil)then
		reportNode = MyReportNode.createNode(touchPriority - 1,999)
		reportNode:setScale(g_fScaleX)
		-- reportNode:setScaleY(g_fScaleY)
		_bgLayer:addChild(reportNode,10,1)
		reportNode:setAnchorPoint(ccp(0.5,0.5))
		reportNode:setPosition(ccp(_backGround:getContentSize().width*0.515*g_fScaleX,
			_backGround:getContentSize().height*0.57*g_fScaleY))
	end
	resultItem:selected()
	supportItem:unselected()
end

local function serviceCallFunc( ... )
	-- body
	reportNode = MySupportLayer.createLayer()
	
	reportNode:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(reportNode,10,2)
	reportNode:setScale(g_fScaleX)
	-- reportNode:setScaleY(g_fScaleY)
	reportNode:setAnchorPoint(ccp(0.5,0.5))
	reportNode:setPosition(ccp(_backGround:getContentSize().width*0.515*g_fScaleX,
	_backGround:getContentSize().height*0.57*g_fScaleY))
	supportItem:selected()
	local num = getSupportNum()
	supportNumLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_89")..num..GetLocalizeStringBy("llp_90"),g_sFontPangWa,23)
	supportNumLabel:setColor(ccc3(0x78,0x25,0x00))
	-- supportNumLabel:setScale(g_fElementScaleRatio)
	reportNode:addChild(supportNumLabel,0,supportNumLabelTag)
	supportNumLabel:setAnchorPoint(ccp(0.5,0))
	supportNumLabel:setPosition(ccp(reportNode:getContentSize().width*0.5,
		_backGround:getContentSize().height*0.5-reportNode:getContentSize().height*0.5))
end

local function supportCallBack( tag,sender )
	-- body
	
	
	if(reportNode~=nil)then
    	reportNode:removeFromParentAndCleanup(true)
    	reportNode = nil
    end
    
	if(reportNode==nil)then
		print("hahahahaha111")
		reportNode = MySupportLayer.createLayer()
		reportNode:setScale(g_fScaleX)
		-- reportNode:setScaleY(g_fScaleY)
		_bgLayer:addChild(reportNode,10,2)
		reportNode:setAnchorPoint(ccp(0.5,0.5))
		reportNode:setPosition(ccp(_backGround:getContentSize().width*0.515*g_fScaleX,
			_backGround:getContentSize().height*0.57*g_fScaleY))
		print("!!!!!!!!!")
		print_t(LordWarData.getMySupportInfo())
		print("!!!!!!!!!")
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(1),CCCallFunc:create(function ( ... )
            local num = getSupportNum()
			supportNumLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_89")..num..GetLocalizeStringBy("llp_90"),g_sFontPangWa,23)
			supportNumLabel:setColor(ccc3(0x78,0x25,0x00))
			-- supportNumLabel:setScale(g_fElementScaleRatio)
			reportNode:addChild(supportNumLabel,0,supportNumLabelTag)
			supportNumLabel:setAnchorPoint(ccp(0.5,0))
			supportNumLabel:setPosition(ccp(reportNode:getContentSize().width*0.5,
				_backGround:getContentSize().height*0.5-reportNode:getContentSize().height*0.5))
        end))
    	reportNode:runAction(seq)
		-- if(LordWarData.getMySupportInfo()~=nil)then
		-- 	local num = getSupportNum()
		-- 	supportNumLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_89")..num..GetLocalizeStringBy("llp_90"),g_sFontPangWa,23)
		-- 	supportNumLabel:setColor(ccc3(0x78,0x25,0x00))
		-- 	-- supportNumLabel:setScale(g_fElementScaleRatio)
		-- 	reportNode:addChild(supportNumLabel,0,supportNumLabelTag)
		-- 	supportNumLabel:setAnchorPoint(ccp(0.5,0))
		-- 	supportNumLabel:setPosition(ccp(reportNode:getContentSize().width*0.5,
		-- 		_backGround:getContentSize().height*0.5-reportNode:getContentSize().height*0.5))
		-- else
		-- 	-- LordWarService.getMySupport(serviceCallFunc)
		-- end
		-- serviceCallFunc()
	end
	supportItem:selected()
	resultItem:unselected()
end

-- 结果按钮回调
local function resultCallBack( tag, sender )	
    require "script/ui/lordWar/myReport/MyReportNode"
    if(reportNode~=nil)then
    	reportNode:removeFromParentAndCleanup(true)
    	reportNode = nil
    end
	if(reportNode==nil)then
		reportNode = MyReportNode.createNode(touchPriority - 1,999)
		reportNode:setScale(g_fScaleX)
		-- reportNode:setScaleY(g_fScaleY)
		_bgLayer:addChild(reportNode,10,1)
		reportNode:setAnchorPoint(ccp(0.5,0.5))
		reportNode:setPosition(ccp(_backGround:getContentSize().width*0.515*g_fScaleX,
			_backGround:getContentSize().height*0.57*g_fScaleY))
	end
	resultItem:selected()
	supportItem:unselected()
end

function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,touchPriority,true)
		_bgLayer:setTouchEnabled(true)
		-- 注册删除回调
		-- GuildImpl.registerCallBackFun("LookApplyLayer",closeButtonCallback)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
		-- GuildImpl.registerCallBackFun("LookApplyLayer",nil)
	end
end



-- 初始化界面
function show( _priority,_zorder )
    init()
	touchPriority = _priority or -454
	zorder = _zorder or 1000
	print("width"..g_winSize.width.."height"..g_winSize.height)
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,zorder,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(620, 760))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(_backGround)
    _backGround:setScale(g_fScaleX)
    -- _backGround:setScaleY(g_fScaleY)
    -- 适配
    -- setAdaptNode(_backGround)
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_83"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(touchPriority-10)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"

	supportItem = LuaCC.create9ScaleMenuItem(image_n,image_h,CCSizeMake(230, 60),GetLocalizeStringBy("llp_82"),ccc3(0xff, 0xff, 0xff),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- supportItem:setScaleY(1/g_fScaleX)
	supportItem:setAnchorPoint(ccp(0,0.5))
	if(g_winSize.width==640 and g_winSize.height==1136)then
		supportItem:setPosition(ccp(_backGround:getContentSize().width * 0.5, _backGround:getContentSize().height*0.9 ))
	else
		supportItem:setPosition(ccp(_backGround:getContentSize().width * 0.5, _backGround:getContentSize().height*0.91 ))
	end
	supportItem:registerScriptTapHandler(supportCallBack)
	menu:addChild(supportItem)

	resultItem = LuaCC.create9ScaleMenuItem(image_n,image_h,CCSizeMake(230, 60),GetLocalizeStringBy("zzh_1058"),ccc3(0xff, 0xff, 0xff),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- resultItem:setScaleY(1/g_fScaleX)
	resultItem:setAnchorPoint(ccp(1,0.5))
	resultItem:registerScriptTapHandler(resultCallBack)
	-- resultItem:registerScriptTapHandler(resultCallBack)
	if(g_winSize.width==640 and g_winSize.height==1136)then
		resultItem:setPosition(ccp(_backGround:getContentSize().width * 0.5, _backGround:getContentSize().height*0.9 ))
	else
		resultItem:setPosition(ccp(_backGround:getContentSize().width * 0.5, _backGround:getContentSize().height*0.91 ))
	end
	menu:addChild(resultItem)
	-- return _bgLayer
	showResult()

	-- LordWarService.getMySupport()
end
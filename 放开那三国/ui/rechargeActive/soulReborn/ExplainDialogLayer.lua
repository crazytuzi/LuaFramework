-- FileName: ExplainDialogLayer.lua 
-- Author: licong 
-- Date: 15/9/29 
-- Purpose: 活动说明


module("ExplainDialogLayer", package.seeall)

local _bgLayer  						= nil
local _touchPriority  					= nil
local _zOrder 							= nil	
local _titleStr 						= nil
local _textStr 							= nil

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer  							= nil
	_touchPriority  					= nil
	_zOrder 							= nil
	_titleStr 							= nil
	_textStr 							= nil	

end

--[[
	@des 	: touch事件处理
	@param 	: 
	@return : 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
	@des 	: onNodeEvent事件
	@param 	: 
	@return : 
--]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end


--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeBtnCallFunc( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

   	if( _bgLayer ~= nil )then
   		_bgLayer:removeFromParentAndCleanup(true)
   		_bgLayer = nil
   	end
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(550, 550))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(bgSprite)
    setAdaptNode(bgSprite)
    
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-6.6 ))
	bgSprite:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(_titleStr, g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

    -- scrollView
	local viewSize = CCSizeMake(440,440)
	local scroll = CCScrollView:create()
	scroll:setViewSize(viewSize)
	scroll:setDirection(kCCScrollViewDirectionVertical)
	scroll:setTouchPriority(_touchPriority-1)
	scroll:setBounceable(true)
	scroll:ignoreAnchorPointForPosition(false)
	scroll:setAnchorPoint(ccp(0.5,0))
	scroll:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.08))
	bgSprite:addChild(scroll)

	-- 内容
    local textInfo = {
     		width = 430, -- 宽度
	        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 24,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = _textStr,
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local fontNode = LuaCCLabel.createRichLabel(textInfo)

	-- containerLayer
	local containerHight = fontNode:getContentSize().height+20
	local containerLayer = CCLayer:create()
	containerLayer:setContentSize(CCSizeMake(viewSize.width,containerHight))
	scroll:setContainer(containerLayer)
	scroll:setContentOffset(ccp(0,scroll:getViewSize().height-containerLayer:getContentSize().height))

	fontNode:setAnchorPoint(ccp(0.5,1))
	fontNode:setPosition(ccp(containerLayer:getContentSize().width*0.5,containerLayer:getContentSize().height))
	containerLayer:addChild(fontNode)


	-- 关闭按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-3)
    bgSprite:addChild(menuBar)
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.02, bgSprite:getContentSize().height*1.02))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler( closeBtnCallFunc )
	
	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( p_touchPriority, p_zOrder, p_titleStr, p_textStr )
	-- 初始化
	init()

	_touchPriority = p_touchPriority or -500
	_zOrder = p_zOrder or 1010
	_titleStr = p_titleStr
	_textStr = p_textStr

	local runningScene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer()
    runningScene:addChild(layer,_zOrder)
end



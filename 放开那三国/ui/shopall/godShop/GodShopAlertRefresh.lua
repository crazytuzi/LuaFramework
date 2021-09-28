-- Filename: GodShopAlertRefresh.lua
-- Author: DJN
-- Date: 2014-12-20
-- Purpose: 神兵商店确认花金币刷新

module("GodShopAlertRefresh", package.seeall)
require "script/audio/AudioUtil"
--require "script/ui/item/ItemUtil"


local _bgLayer       --背景层
local _touchPriority --触摸优先级
local _ZOrder		 --Z轴值
local _tag          -- 传进来的需要金币的数量
local _costType
local _confirmCb     -- 得到确认并向网络请求后的回调函数

function init()
	
	_bgLayer = nil
	_touchPriority = nil
	_ZOrder		   = nil
    _tag    = nil
    _costType = {}
    _confirmCb = nil
end
----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
	if eventType == "began" then
		print("onTouchesHandler,began")
	    return true
    elseif eventType == "moved" then
    	print("onTouchesHandler,moved")
    else
        print("onTouchesHandler,else")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeMenuCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    close()
end
--[[
	@des 	:关闭函数
	@param 	:
	@return :
--]]
function close( ... )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end
--“确定”按钮回调
function confirmMenuCb( ... )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(GodShopData.isGoldEnough(_tag))then
		if(_confirmCb ~= nil)then
			_confirmCb()
		end
	else
		----提示充值
		require "script/ui/tip/LackGoldTip"
	    LackGoldTip.showTip(_touchPriority-50,_ZOrder+10)
	end
	close()
end
---------------------------------------UI函数
--[[
	@des 	:创建背景
	@param 	:
	@return :
--]]
 function createBgUI()
	require "script/ui/main/MainScene"
	local bgSize = CCSizeMake(530,400)
	local bgScale = MainScene.elementScale
    
	--主黄色背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
	bgSprite:setScale(bgScale)
	_bgLayer:addChild(bgSprite)

    local MenuBar = CCMenu:create()
	MenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(MenuBar)

   
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.01, bgSprite:getContentSize().height*0.98))
    closeBtn:registerScriptTapHandler(closeMenuCallBack)
	MenuBar:addChild(closeBtn)
	MenuBar:setTouchPriority(_touchPriority-10)

    -- 确定按钮
	local confirmItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_n.png",CCSizeMake(140,70),GetLocalizeStringBy("key_8022"),ccc3(255,222,0))
    confirmItem:setAnchorPoint(ccp(0.5, 0))
    confirmItem:setPosition(bgSprite:getContentSize().width*0.3, bgSprite:getContentSize().height*0.18)
	MenuBar:addChild(confirmItem)
	confirmItem:registerScriptTapHandler(confirmMenuCb)
    -- 取消按钮
	local cancelItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_n.png",CCSizeMake(140,70),GetLocalizeStringBy("key_2326"),ccc3(255,222,0))
    cancelItem:setAnchorPoint(ccp(0.5, 0))
    cancelItem:setPosition(bgSprite:getContentSize().width*0.7, bgSprite:getContentSize().height*0.18)
	MenuBar:addChild(cancelItem)
	cancelItem:registerScriptTapHandler(closeMenuCallBack)
   
    local noteStr = CCRenderLabel:create(GetLocalizeStringBy("key_3158"),g_sFontPangWa,35,1,ccc3(0xff,0xff,0xff),type_stroke)
    noteStr:setAnchorPoint(ccp(0.5,0))
    noteStr:setColor(ccc3(0x78, 0x25, 0x00))
    noteStr:setPosition(ccp(bgSprite:getContentSize().width *0.5,bgSprite:getContentSize().height*0.7))
    bgSprite:addChild(noteStr)

    require "script/libs/LuaCCLabel"
    
    local imgPath= "images/common/gold.png"
    local strColor = ccc3(0x00, 0xff, 0x18)
  
    local richInfo = {lineAlignment = 2,elements = {}}
       richInfo.elements[1] = {
			    ["type"] = "CCLabelTTF", 
			    newLine = false, 
			    text = GetLocalizeStringBy("djn_103"),
			    font = g_sFontName, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}
	    richInfo.elements[2] = {
			    ["type"] = "CCSprite", 
			    newLine = false, 
			    --text = GetLocalizeStringBy("key_1307"),
			    image = imgPath}
	    richInfo.elements[3] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = _tag,
			    font = g_sFontName, 
			    size = 30, 
			    color = strColor,
				strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
	    richInfo.elements[4] = {
			    ["type"] = "CCLabelTTF", 
			    newLine = false, 
			    text = GetLocalizeStringBy("djn_115"),
			    font = g_sFontName, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}
  
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,1))
    midSp:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.6))
    bgSprite:addChild(midSp)
	
end

-----------入口函数
-----------参数：花费金币数量,得到确定后回调、触摸优先级、Z轴
function showLayer(p_tag,p_ConfirmCb,p_touchPriority,p_ZOrder)
	init()
	_touchPriority = p_touchPriority or -599
	_ZOrder = p_ZOrder or 999

	_tag = p_tag
	_confirmCb = p_ConfirmCb
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	--_bgLayer:setScale(g_fScaleX)
	local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder)

    createBgUI()

	return _bgLayer
end
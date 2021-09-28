-- FileName: WorldArenaRegisterLayer.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 巅峰对决报名界面
--[[TODO List]]

module("WorldArenaRegisterLayer", package.seeall)

require "script/ui/WorldArena/WorldArenaUtil"

local _bgLayer  						= nil

local _timeDesNode 						= nil
local _signUpMenuItem     				= nil
local _upMenuItem 						= nil
local _signUpFont 						= nil
local _upCDLable  						= nil

local _nextUpTime 						= nil

local _touchPriority  					= nil
local _zOrder 							= nil	

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer  							= nil

	_timeDesNode 						= nil
	_signUpMenuItem     				= nil
	_upMenuItem 						= nil
	_signUpFont 						= nil
	_upCDLable  						= nil

	_nextUpTime 						= nil

	_touchPriority  					= nil
	_zOrder 							= nil	

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
	@des 	:关闭layer
	@param 	:
	@return :
--]]
function closeLayer()
   	if( _bgLayer ~= nil )then
   		_bgLayer:removeFromParentAndCleanup(true)
   		_bgLayer = nil
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

   	closeLayer()

   	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end



--[[
	@des 	:奖励预览按钮回调
	@param 	:
	@return :
--]]
function rewardMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/WorldArena/reward/WorldArenaRewardLayer"
    WorldArenaRewardLayer.showLayer( _touchPriority-30, _zOrder+10 )
end

--[[
	@des 	:活动说明按钮回调
	@param 	:
	@return :
--]]
function explainMenuItemCallFunc( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/WorldArena/WorldArenaExplainDialog"
    WorldArenaExplainDialog.showLayer( _touchPriority-30, _zOrder+10 )
end

--[[
	@des 	:报名按钮回调
	@param 	:
	@return :
--]]
function signUpMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local nextCallFun = function ( ... )
    	updateBtnFun()
    end
    WorldArenaController.signUpCallback( nextCallFun )
end

--[[
	@des 	:更新信息按钮回调
	@param 	:
	@return :
--]]
function upMenuItemCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local nextCallFun = function ( ... )
    	-- 更新信息按钮cd
		local lastUpdateTime = WorldArenaMainData.getlastUpdateFightForceTime() 
		local updateCD = WorldArenaMainData.getUpdateFightForceCD()  
		local curTime = TimeUtil.getSvrTimeByOffset(0)
		_nextUpTime = lastUpdateTime + updateCD
		if( _nextUpTime > curTime )then
			_upCDLable:setVisible(true)
			_upCDLable:setString( GetLocalizeStringBy("lic_1688") .. TimeUtil.getTimeString(_nextUpTime - curTime) )
			schedule(_upMenuItem, refreshCDLable, 1)
		end
    end
    WorldArenaController.updateFmtCallback( nextCallFun )
end


--------------------------------------------------------------------- 创建ui ---------------------------------------------------------------------------------
--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function refreshCDLable( ... )
	-- 更新信息按钮cd
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	if( _nextUpTime <= curTime )then
		_upMenuItem:stopAllActions()
		_upCDLable:setVisible(false)
		return
	end
	_upCDLable:setString( GetLocalizeStringBy("lic_1688") .. TimeUtil.getTimeString(_nextUpTime - curTime) )
	_upCDLable:setVisible(true)
end

--[[
	@des 	: 按钮显示
	@param 	: 
	@return : 
--]]
function updateBtnFun( ... )
	-- 报名按钮置灰
	local mySignUpTime = WorldArenaMainData.getMySignUpTime()
	local signUpEndTime = WorldArenaMainData.getSignUpEndTime()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	if(mySignUpTime > 0)then
		-- 判断是否已经报过名
		_signUpMenuItem:setEnabled(false)
    	_signUpFont:setString( GetLocalizeStringBy("lic_1687") )
    	_signUpFont:setColor(ccc3(0x64,0x64,0x64))
    	_signUpMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.3, _bgLayer:getContentSize().width*0.2))
    	-- 显示更新信息按钮
    	_upMenuItem:setVisible(true)

    elseif(curTime >= signUpEndTime )then
    	-- 判断是否报名结束
    	_signUpMenuItem:setEnabled(false)
    	_signUpFont:setColor(ccc3(0x64,0x64,0x64))
    else
	end
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,230))
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 返回按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-3)
    _bgLayer:addChild(menuBar,10)
    local closeBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.98, _bgLayer:getContentSize().height*0.95))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler( closeBtnCallFunc )
	closeBtn:setScale(g_fElementScaleRatio)

	-- 标题
	local titleSp = XMLSprite:create("images/worldarena/effect/dfduijue/dfduijue")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.7))
	_bgLayer:addChild(titleSp)
	titleSp:setScale(g_fElementScaleRatio)

	-- 时间描述
	_timeDesNode = WorldArenaUtil.getTimeDesNode()
	if( _timeDesNode ~= nil )then
		_timeDesNode:setAnchorPoint(ccp(0.5,0.5))
		_timeDesNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
		_bgLayer:addChild(_timeDesNode)
		_timeDesNode:setScale(g_fElementScaleRatio)
		local refreshTimeDesNode = function ( ... )
			if( _timeDesNode ~= nil )then
				_timeDesNode:removeFromParentAndCleanup(true)
				_timeDesNode = nil
			end
			_timeDesNode = WorldArenaUtil.getTimeDesNode()
			_timeDesNode:setAnchorPoint(ccp(0.5,0.5))
			_timeDesNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
			_bgLayer:addChild(_timeDesNode)
			_timeDesNode:setScale(g_fElementScaleRatio)
		end
		schedule(_bgLayer, refreshTimeDesNode, 1)
	end

	-- 报名按钮
	local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSprite:setContentSize(CCSizeMake(200,70))

    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(200,70))

    local disSprite  = CCScale9Sprite:create("images/common/btn/btn1_g.png")
    disSprite:setContentSize(CCSizeMake(200,70))

    -- 报名按钮
    _signUpMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disSprite)
    _signUpMenuItem:setAnchorPoint(ccp(0.5,0.5))
    _signUpMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().width*0.2))
    _signUpMenuItem:registerScriptTapHandler(signUpMenuItemCallBack)
    menuBar:addChild(_signUpMenuItem)
    _signUpMenuItem:setScale(g_fElementScaleRatio)

    _signUpFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1685"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _signUpFont:setColor(ccc3(0xff, 0xf6, 0x00))
    _signUpFont:setAnchorPoint(ccp(0.5,0.5))
    _signUpFont:setPosition(ccpsprite(0.5, 0.5, _signUpMenuItem))
    _signUpMenuItem:addChild(_signUpFont,10)

    -- 更新信息按钮
	local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSprite:setContentSize(CCSizeMake(200,70))

    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(200,70))

    _upMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    _upMenuItem:setAnchorPoint(ccp(0.5,0.5))
    _upMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.7, _bgLayer:getContentSize().width*0.2))
    _upMenuItem:registerScriptTapHandler(upMenuItemCallBack)
    menuBar:addChild(_upMenuItem)
    _upMenuItem:setScale(g_fElementScaleRatio)
    _upMenuItem:setVisible(false)

    local upFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1686"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    upFont:setColor(ccc3(0xff, 0xf6, 0x00))
    upFont:setAnchorPoint(ccp(0.5,0.5))
    upFont:setPosition(ccpsprite(0.5, 0.5, _upMenuItem))
    _upMenuItem:addChild(upFont)

    _upCDLable = CCRenderLabel:create(GetLocalizeStringBy("lic_1688") .. "00:00:00", g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_upCDLable:setColor(ccc3(0x00,0xff,0x18))
	_upCDLable:setAnchorPoint(ccp(0.5,1))
	_upCDLable:setPosition(ccp(_upMenuItem:getContentSize().width*0.5,-5))
	_upMenuItem:addChild(_upCDLable)
	_upCDLable:setVisible(false)

	-- 更新信息按钮cd
	local lastUpdateTime = WorldArenaMainData.getlastUpdateFightForceTime() --1436177956
	local updateCD = WorldArenaMainData.getUpdateFightForceCD() -- 1000 
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	_nextUpTime = lastUpdateTime + updateCD
	if( _nextUpTime > curTime )then
		_upCDLable:setVisible(true)
		_upCDLable:setString( GetLocalizeStringBy("lic_1688") .. TimeUtil.getTimeString(_nextUpTime - curTime) )
		schedule(_upMenuItem, refreshCDLable, 1)
	end

	-- 奖励预览按钮
    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(0.5,0.5))
    rewardMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.3,_bgLayer:getContentSize().height*0.95 ))
    menuBar:addChild(rewardMenuItem)
    rewardMenuItem:registerScriptTapHandler(rewardMenuItemCallBack)
    rewardMenuItem:setScale(g_fElementScaleRatio)

	--活动说明
	local explainMenuItem = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
	explainMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	explainMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.1,_bgLayer:getContentSize().height*0.95 ))
	menuBar:addChild(explainMenuItem)
	explainMenuItem:registerScriptTapHandler(explainMenuItemCallFunc)
	explainMenuItem:setScale(g_fElementScaleRatio)


	-- 更新按钮状态
	updateBtnFun()
	
	-- 到报名结束再更新一次
	local signUpEndTime = WorldArenaMainData.getSignUpEndTime()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local delayTime = signUpEndTime - curTime
	performWithDelay(_bgLayer, updateBtnFun, delayTime)

	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( p_touchPriority, p_zOrder )
	-- 初始化
	init()

	_touchPriority = p_touchPriority or -500
	_zOrder = p_zOrder or 1010

	local runningScene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer()
    runningScene:addChild(layer,_zOrder)
end



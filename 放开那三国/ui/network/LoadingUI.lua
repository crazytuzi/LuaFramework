-- Filename：	LoadingUI.lua
-- Author：		Cheng Liang
-- Date：		2013-7-22
-- Purpose：		loading

module("LoadingUI", package.seeall)




local kTimeOutInterval = 45

local addTimes = 0
local loadingLayer = nil

local isEatTouched = false --是否吃掉touch 事件

local loadingSprite = nil
local _updateTimeScheduler = nil
local parentScene = nil
--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		-- print("began")
		if(loadingLayer and isEatTouched==true)then
		    return true
		else
			return false
		end
	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		loadingLayer:registerScriptTouchHandler(onTouchesHandler, false, -99999, true)
		loadingLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		loadingLayer:unregisterScriptTouchHandler()
		release()
	end
end

-- 停止scheduler
local function stopScheduler()
	if(_updateTimeScheduler)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

-- 启动scheduler
local function startScheduler()
	if(_updateTimeScheduler == nil) then
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeOutFunc, kTimeOutInterval, true)
	end
end

function timeOutFunc()
	stopScheduler()
	stopLoadingUI()
	print("connect time out.....")
	require "script/ui/login/LoginScene"
	LoginScene.netWorkFailed()
	Network.close()
end

local function checkSceneChanged()
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	if runningScene ~= parentScene then
		print("scene changed")
		loadingLayer = nil
	end
end

local function showLoading()
	print("showLoading....")
	loadingLayer = nil
	loadingLayer = CCLayer:create()--CCLayerColor:create(ccc4(0,0,0,155))
	loadingLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(loadingLayer,999999999,90901)
	parentScene = runningScene

	loadingSprite = CCSprite:create("images/common/bg/connectbg.png")
	loadingSprite:setAnchorPoint(ccp(0.5, 0.5))
	loadingSprite:setPosition(ccp(runningScene:getContentSize().width/2 , runningScene:getContentSize().height/2))
	loadingSprite:setScale(g_fScaleX)	
	loadingLayer:addChild(loadingSprite)
	-- 动画
	local loadEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/load/load4"), -1,CCString:create(""));
    loadEffectSprite:retain()
    loadEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
    loadEffectSprite:setPosition(ccp(loadingSprite:getContentSize().width*0.45, loadingSprite:getContentSize().height*0.5))
    loadEffectSprite:setScale(0.4)
    loadingSprite:addChild(loadEffectSprite)
    loadEffectSprite:release()
end

function addLoadingUI()
	checkSceneChanged()
	addTimes = addTimes +1
	if (addTimes==1) then
		loadingLayer = tolua.cast(loadingLayer, "CCLayer")
		if(loadingLayer == nil)then
			showLoading()
		end
		loadingLayer:setVisible(true)
		loadingSprite:setVisible(false)
		-- 延时显示 loadingSprite
		local actionArr = CCArray:create()
		actionArr:addObject(CCDelayTime:create(0.5))
		actionArr:addObject(CCCallFuncN:create(showLoadingSprite))
		loadingLayer:runAction(CCSequence:create(actionArr))

		isEatTouched = true
		-- 防止超时
		stopScheduler()
		startScheduler()
	end
end

function showLoadingSprite()
	if(loadingLayer and loadingLayer:isVisible() == true)then
		loadingSprite:setVisible(true)
	end
end

function reduceLoadingUI(  )
	checkSceneChanged()
	addTimes = addTimes -1
	if (addTimes<=0) then
		loadingLayer = tolua.cast(loadingLayer, "CCLayer")
		if (loadingLayer)then
			loadingLayer:setVisible(false)
			loadingSprite:setVisible(false)
			isEatTouched = false
		end
		addTimes=0
		stopScheduler()
	end
end

-- 直接停止
function stopLoadingUI(  )
	checkSceneChanged()
	addTimes = 0
	loadingLayer = tolua.cast(loadingLayer, "CCLayer")
	if (loadingLayer)then
		loadingLayer:setVisible(false)
        isEatTouched = false
	end
	stopScheduler()
end

function setVisiable( visable )
	loadingLayer:setVisible(visable)
end
function getVisiable()
	return loadingLayer:isVisible()
end

function release( ... )
	stopScheduler()
	stopLoadingUI()
	loadingLayer = nil
	addTimes=0
end

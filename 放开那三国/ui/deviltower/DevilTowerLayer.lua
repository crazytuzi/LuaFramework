-- FileName: DevilTowerLayer.lua
-- Author: lgx
-- Date: 2016-07-29
-- Purpose: 试炼梦魇主界面

module("DevilTowerLayer", package.seeall)

require "script/ui/deviltower/DevilTowerData"
require "script/ui/deviltower/DevilTowerUtil"
require "script/ui/deviltower/DevilTowerController"
require "script/utils/TimeUtil"

local kTagFinishGold 		= 1000 -- 立即完成金币标签Tag
local kTagSchedulerAction 	= 1001 -- 扫荡定时器动作Tag

local x_rate = 0.8
local y_rate = 0.25

-- 模块局部变量 --
local _touchPriority		= nil -- 触摸优先级
local _zOrder				= nil -- 显示层级
local _bgLayer				= nil -- 背景层
local _layerSize			= nil -- 背景层大小
local _topBg 				= nil -- 顶部背景
local _silverLabel 			= nil -- 银币标签
local _goldLabel			= nil -- 金币标签
local _curFloorLabel 		= nil -- 层数标签
local _passConditionLabel 	= nil -- 条件标签
local _loveStarArr 			= nil -- 挑战次数红心Arr
local _grayLoveStarArr 		= nil -- 挑战次数灰心Arr
local _mainMenu				= nil -- 按钮菜单
local _resetItem			= nil -- 重置按钮
local _leftResetTimesLabel	= nil -- 剩余重置次数标签
local _sweepItem 			= nil -- 扫荡按钮
local _cancelSweepItem		= nil -- 取消扫荡按钮
local _sweepRestTimeLabel	= nil -- 扫荡倒计时标签
local _finishItem			= nil -- 立即完成按钮
local _canFinish			= nil -- 是否可以立即完成
local _finishGoldSprite 	= nil -- 立即完成金币icon
local _finishCostLabel 		= nil -- 立即完成金币标签
local _passedEffectSprite	= nil -- 通关特效
local _enterNextItem 		= nil -- 进入下一层按钮
local _attackNpcItem 		= nil -- 怪物形象按钮
local _isEnterNextStatus 	= false -- 是否能进入下一层
local _sweepScheduler		= nil -- 扫荡定时器动作
local _sweepEndLevel 		= nil -- 扫荡结束塔层

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority			= nil
	_zOrder					= nil
	_bgLayer				= nil
	_layerSize				= nil
	_topBg 					= nil
	_silverLabel			= nil
	_goldLabel				= nil
	_curFloorLabel			= nil
	_passConditionLabel		= nil
	_loveStarArr 			= nil
	_grayLoveStarArr 		= nil
	_mainMenu 				= nil
	_resetItem				= nil
	_leftResetTimesLabel	= nil
	_sweepItem				= nil
	_cancelSweepItem		= nil
	_sweepRestTimeLabel		= nil
	_finishItem				= nil
	_canFinish				= nil
	_finishGoldSprite		= nil
	_finishCostLabel		= nil
	_passedEffectSprite		= nil
	_enterNextItem			= nil
	_attackNpcItem			= nil
	_isEnterNextStatus		= false
	_sweepScheduler			= nil
	_sweepEndLevel			= nil
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,false)
		_bgLayer:setTouchEnabled(true)
		-- 金币改变 刷新
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(refreshTopUI)
		-- 播放背景音乐
		playDevilTowerBgMusic()
	elseif (event == "exit") then
		-- 停止扫荡定时器
		stopScheduler()
		-- 释放通知方法
		LoginScene.removeObserverForNetConnected("requestDevilTowerInfo")
		-- 停止背景音乐
		stopDevilTowerBgMusic()
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc	: 播放试炼梦魇背景音乐
    @param	: 
    @return	: 
—-]]
function playDevilTowerBgMusic()
	AudioUtil.playBgm("audio/bgm/music12.mp3")
end

--[[
	@desc	: 停止试炼梦魇背景音乐
    @param	: 
    @return	: 
—-]]
function stopDevilTowerBgMusic()
	AudioUtil.playMainBgm()
end

--[[
	@desc 	: 显示界面方法
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pTouchPriority, pZorder )

	-- 判断背包
	if(ItemUtil.isBagFull() == true )then
		return
	end

	-- 判断功能是否开启
    if (not DevilTowerData.isDevilTowerOpen()) then
        return
    end

	-- 使用 MainSence.changeLayer 进入
	MainScene.setMainSceneViewsVisible(true,false,true)
	local devilTowerLayer = createLayer(pTouchPriority, pZorder)
	MainScene.changeLayer(devilTowerLayer, "DevilTowerLayer")
end

--[[
	@desc 	: 创建Layer及UI
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : CCLayer 背景层
--]]
function createLayer( pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -500
	_zOrder = pZorder or 500

	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local avatarLayerSize = MainScene.getAvatarLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = CCSizeMake(g_winSize.width, g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX)

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setContentSize(_layerSize)
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

	-- 背景图
	local bgSprite = CCSprite:create("images/tower/tower_bg.png")
	bgSprite:setScale(g_fBgScaleRatio)
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_layerSize.width/2,_layerSize.height/2))
	_bgLayer:addChild(bgSprite)

	-- 拉取后端数据
	DevilTowerController.getDevilTowerInfo(function()
		-- 处理扫荡的数据
		DevilTowerData.changeCurSweepHell()
		-- 创建UI
		createAllUI()
		if (DevilTowerData.isDevilTowerSweep() == true) then
			-- 启动扫荡定时器
			startScheduler()
		end
	end)

	return _bgLayer
end

--[[
	@desc	: 创建所有UI
    @param	: 
    @return	: 
—-]]
function createAllUI()
	createDevilEffect()
	createTopUI()
	createMiddleUI()
	createAttackUI()
end

--[[
	@desc	: 创建试炼梦魇特效
    @param	: 
    @return	: 
—-]]
function createDevilEffect()
	local devilEffect = XMLSprite:create("images/base/effect/ziseyanwu/ziseyanwu")
	devilEffect:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	devilEffect:setScaleY(g_fBgScaleRatio)
	devilEffect:setScaleX(-g_fBgScaleRatio)
	_bgLayer:addChild(devilEffect,1)
end

--[[
	@desc	: 创建顶部信息视图
    @param	: 
    @return	: 
—-]]
function createTopUI()
	_topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
	_topBg:setAnchorPoint(ccp(0,1))
	_topBg:setPosition(ccp(0, _layerSize.height))
	_topBg:setScale(g_fScaleX)
	_bgLayer:addChild(_topBg,10)

	-- 战斗力
	local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)

    local powerNumLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    powerNumLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(powerNumLabel)

	-- 银币
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setAnchorPoint(ccp(0, 0))
	_silverLabel:setPosition(ccp(390, 10))
	_topBg:addChild(_silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0))
	_goldLabel:setPosition(ccp(522, 10))
	_topBg:addChild(_goldLabel)
end

--[[
	@desc	: 刷新顶部信息视图
    @param	: 
    @return	: 
—-]]
function refreshTopUI()
	_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
	_goldLabel:setString(UserModel.getGoldNumber())
end

--[[
	@desc	: 创建中间信息UI
    @param	: 
    @return	: 
—-]]
function createMiddleUI()
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local curFloorDesc = DevilTowerData.getDevilTowerById(towerInfo.cur_hell)

	-- 当前层数
	local floorSprite = CCSprite:create("images/tower/floorbg.png")
	floorSprite:setAnchorPoint(ccp(0,1))
	floorSprite:setPosition(ccp(20*g_fScaleX, _layerSize.height - (_topBg:getContentSize().height + 10) * g_fScaleX) )
	floorSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(floorSprite,5)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1763") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleLabel:setAnchorPoint(ccp(0, 0.5))
	titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	titleLabel:setPosition(ccp(60, floorSprite:getContentSize().height*0.5))
	floorSprite:addChild(titleLabel)

	-- 层数
	_curFloorLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. towerInfo.cur_hell .. GetLocalizeStringBy("key_2400") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_curFloorLabel:setAnchorPoint(ccp(0, 0.5))
	_curFloorLabel:setColor(ccc3(0x00, 0xe4, 0xff))
	_curFloorLabel:setPosition(ccp(185, floorSprite:getContentSize().height*0.5))
	floorSprite:addChild(_curFloorLabel)

	-- 通关条件
	local passConditionTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2061") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	passConditionTitle:setAnchorPoint(ccp(0, 1))
	passConditionTitle:setColor(ccc3(0xff, 0xff, 0xff))
	passConditionTitle:setPosition(ccp(20*g_fScaleX, _layerSize.height-160*g_fScaleY))
	passConditionTitle:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(passConditionTitle,5)

	_passConditionLabel = CCRenderLabel:create(DevilTowerData.getPassFloorCondition(curFloorDesc.star_condition) , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_passConditionLabel:setAnchorPoint(ccp(0, 1))
	_passConditionLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_passConditionLabel:setPosition(ccp(120*g_fScaleX, _layerSize.height-160*g_fScaleY))
	_passConditionLabel:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(_passConditionLabel,5)

	-- 挑战次数
	local timesTittle = CCRenderLabel:create(GetLocalizeStringBy("key_3399") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	timesTittle:setAnchorPoint(ccp(0, 1))
	timesTittle:setColor(ccc3(0xff, 0xff, 0xff))
	timesTittle:setPosition(ccp(20*g_fScaleX, _layerSize.height-190*g_fScaleY))
	timesTittle:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(timesTittle,5)

	_loveStarArr = {}
	_grayLoveStarArr = {}

	local maxLoseTimes = DevilTowerData.getMaxLoseTimes()
	for i=1, maxLoseTimes do
		local loveSprite = CCSprite:create("images/tower/love.png")
		loveSprite:setAnchorPoint(ccp(0,1))
		loveSprite:setPosition(ccp(120*g_fScaleX + 35*(i-1)*g_fScaleX, _layerSize.height-195*g_fScaleY))
		loveSprite:setScale(g_fElementScaleRatio)
		_bgLayer:addChild(loveSprite,5)
		table.insert(_loveStarArr, loveSprite)

		local grayLoveSprite = BTGraySprite:create("images/tower/love.png")
		grayLoveSprite:setAnchorPoint(ccp(0,1))
		grayLoveSprite:setPosition(ccp(120*g_fScaleX + 35*(i-1)*g_fScaleX, _layerSize.height-195*g_fScaleY))
		grayLoveSprite:setScale(g_fElementScaleRatio)
		_bgLayer:addChild(grayLoveSprite,5)
		table.insert(_grayLoveStarArr, grayLoveSprite)
	end

	-- 刷新红心
	refreshLoveStar()

	-- 菜单
	_mainMenu = CCMenu:create()
	_mainMenu:setPosition(ccp(0, 0))
	_mainMenu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(_mainMenu,5)

	-- 梦魇商店
	local devilShopItem = CCMenuItemImage:create("images/deviltower/btn_devilshop_n.png", "images/deviltower/btn_devilshop_h.png")
	devilShopItem:setAnchorPoint(ccp(1,1))
	devilShopItem:setScale(g_fElementScaleRatio)
	devilShopItem:setPosition(ccp(_layerSize.width-90*g_fScaleX, _layerSize.height-(_topBg:getContentSize().height+12)*g_fElementScaleRatio))
	devilShopItem:registerScriptTapHandler(devilShopCallback)
	_mainMenu:addChild(devilShopItem, 1)

	-- 试练塔
	local towerItem = CCMenuItemImage:create("images/deviltower/btn_tower_n.png", "images/deviltower/btn_tower_h.png")
	towerItem:setAnchorPoint(ccp(1,1))
	towerItem:setScale(g_fElementScaleRatio)
	towerItem:setPosition(ccp(_layerSize.width-200*g_fScaleX, _layerSize.height-_topBg:getContentSize().height*g_fElementScaleRatio))
	towerItem:registerScriptTapHandler(towerItemCallback)
	_mainMenu:addChild(towerItem, 1)

	-- 重置
	_resetItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1040"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_resetItem:setAnchorPoint(ccp(0.5, 0))
	_resetItem:setScale(g_fElementScaleRatio)
    _resetItem:setPosition(ccp(_layerSize.width*0.2, 60*g_fScaleY))
    _resetItem:registerScriptTapHandler(resetItemCallback)
	_mainMenu:addChild(_resetItem)

	-- 剩余重置次数
	_leftResetTimesLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3056") .. towerInfo.reset_hell, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_leftResetTimesLabel:setAnchorPoint(ccp(0.5, 1))
	_leftResetTimesLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_leftResetTimesLabel:setPosition(ccp(_resetItem:getContentSize().width*0.5, 0))
	_resetItem:addChild(_leftResetTimesLabel)

	-- 立即完成
	_finishItem = nil
	if (tonumber(towerInfo.cur_hell) >= tonumber(towerInfo.max_hell)) then
		_canFinish = false
		_finishItem = LuaCC.create9ScaleMenuItem("images/tower/graybg.png","images/tower/graybg.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		_canFinish = true
		_finishItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	_finishItem:setAnchorPoint(ccp(0.5, 0))
	_finishItem:setScale(g_fElementScaleRatio)
    _finishItem:setPosition(ccp(_layerSize.width*0.5, 60*g_fScaleY))
    _finishItem:registerScriptTapHandler(finishItemCallback)
	_mainMenu:addChild(_finishItem)

	-- 扫荡
	_sweepItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1143"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_sweepItem:setAnchorPoint(ccp(0.5, 0))
	_sweepItem:setScale(g_fElementScaleRatio)
    _sweepItem:setPosition(ccp(_layerSize.width*0.8, 60*g_fScaleY))
    _sweepItem:registerScriptTapHandler(sweepItemCallback)
	_mainMenu:addChild(_sweepItem)

	-- 取消扫荡
	_cancelSweepItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3226"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_cancelSweepItem:setAnchorPoint(ccp(0.5, 0))
	_cancelSweepItem:setScale(g_fElementScaleRatio)
    _cancelSweepItem:setPosition(ccp(_layerSize.width*0.8, 60*g_fScaleY))
    _cancelSweepItem:registerScriptTapHandler(cancelSweepItemCallback)
	_mainMenu:addChild(_cancelSweepItem)

	_sweepRestTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3173"), g_sFontName, 24)
	_sweepRestTimeLabel:setColor(ccc3(0xf2, 0x0f, 0x0f))
	_sweepRestTimeLabel:setAnchorPoint(ccp(0.5, 1))
	_sweepRestTimeLabel:setPosition(ccp(_cancelSweepItem:getContentSize().width*0.5, 0))
	_cancelSweepItem:addChild(_sweepRestTimeLabel)

	refreshSweepItem()
	refreshMiddleUI()
end

--[[
	@desc	: 刷新挑战次数 红心显示
    @param	: 
    @return	: 
—-]]
function refreshLoveStar()
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local maxLoseTimes = DevilTowerData.getMaxLoseTimes()
	for i=1, maxLoseTimes do
		if (i <= tonumber(towerInfo.can_fail_hell)) then
			_loveStarArr[i]:setVisible(true)
			_grayLoveStarArr[i]:setVisible(false)
		else
			_loveStarArr[i]:setVisible(false)
			_grayLoveStarArr[i]:setVisible(true)
		end
	end
end

--[[
	@desc	: 刷新扫荡按钮状态
    @param	: 
    @return	: 
—-]]
function refreshSweepItem()
	if(DevilTowerData.isDevilTowerSweep() == true)then
		_sweepItem:setVisible(false)
		_cancelSweepItem:setVisible(true)
	else
		_sweepItem:setVisible(true)
		_cancelSweepItem:setVisible(false)
	end
end

--[[
	@desc	: 刷新中间信息UI
    @param	: 
    @return	: 
—-]]
function refreshMiddleUI()
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local curFloorDesc = DevilTowerData.getDevilTowerById(towerInfo.cur_hell)

	-- 当前层数
	_curFloorLabel:setString(GetLocalizeStringBy("key_2886") .. towerInfo.cur_hell .. GetLocalizeStringBy("key_2400"))

	-- 通关条件
	if (_passConditionLabel ~= nil) then
		_passConditionLabel:removeFromParentAndCleanup(true)
		_passConditionLabel = nil
	end
	_passConditionLabel = CCRenderLabel:create(DevilTowerData.getPassFloorCondition(curFloorDesc.star_condition) , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_passConditionLabel:setAnchorPoint(ccp(0, 1))
	_passConditionLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_passConditionLabel:setPosition(ccp(120*g_fScaleX, _layerSize.height-160*g_fScaleY))
	_passConditionLabel:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(_passConditionLabel,5)

	-- 重置状态
	if (_resetItem ~= nil) then
		_resetItem:removeFromParentAndCleanup(true)
		_resetItem = nil
	end
	local btnLabelRate = 0.5
	if (tonumber(towerInfo.reset_hell) <= 0) then
		btnLabelRate = 0.4
	end
	_resetItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png","images/common/btn/btn1_d.png",CCSizeMake(200, 73))
	_resetItem:setAnchorPoint(ccp(0.5, 0))
	_resetItem:setScale(g_fElementScaleRatio)
    _resetItem:setPosition(ccp(_layerSize.width*0.2, 60*g_fScaleY))
    _resetItem:registerScriptTapHandler(resetItemCallback)
	_mainMenu:addChild(_resetItem)

	local resetLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1040"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	resetLabel:setAnchorPoint(ccp(0.5, 0.5))
	resetLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	resetLabel:setPosition(ccp(_resetItem:getContentSize().width*btnLabelRate, _resetItem:getContentSize().height*0.5))
	_resetItem:addChild(resetLabel)

	-- 剩余重置次数
	_leftResetTimesLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3056") .. towerInfo.reset_hell, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_leftResetTimesLabel:setAnchorPoint(ccp(0.5, 1))
	_leftResetTimesLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_leftResetTimesLabel:setPosition(ccp(_resetItem:getContentSize().width*0.5, 0))
	_resetItem:addChild(_leftResetTimesLabel)

	if(tonumber(towerInfo.reset_hell) <= 0)then
		-- 金币图标
	    local goldSprite = CCSprite:create("images/common/gold.png")
	    goldSprite:setAnchorPoint(ccp(0,0.5))
	    goldSprite:setPosition(ccp(_resetItem:getContentSize().width*0.6, _resetItem:getContentSize().height*0.45))
	    _resetItem:addChild(goldSprite)

	    local costGold = DevilTowerData.getResetCostGold()
	    local costGoldLabel = CCLabelTTF:create(costGold, g_sFontName, 23)
	    costGoldLabel:setAnchorPoint(ccp(0, 0.5))
	    costGoldLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    costGoldLabel:setPosition(ccp(goldSprite:getContentSize().width,goldSprite:getContentSize().height*0.5))
	    goldSprite:addChild(costGoldLabel)
	end

	-- 立即完成状态
	if (_finishGoldSprite ~= nil) then
		_finishGoldSprite:removeFromParentAndCleanup(true)
		_finishGoldSprite = nil
	end
	if (_finishItem ~= nil) then
		_finishItem:removeFromParentAndCleanup(true)
		_finishItem = nil
	end
	if (tonumber(towerInfo.cur_hell) >= tonumber(towerInfo.max_hell)) then
		_canFinish = false
		_finishItem = LuaCC.create9ScaleMenuItem("images/tower/graybg.png","images/tower/graybg.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		_canFinish = true
		_finishItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	_finishItem:setAnchorPoint(ccp(0.5, 0))
	_finishItem:setScale(g_fElementScaleRatio)
    _finishItem:setPosition(ccp(_layerSize.width*0.5, 60*g_fScaleY))
    _finishItem:registerScriptTapHandler(finishItemCallback)
	_mainMenu:addChild(_finishItem)

	-- 金币消耗信息
	_finishGoldSprite = CCSprite:create("images/common/gold.png")
	_finishItem:addChild(_finishGoldSprite,10,kTagFinishGold)
	_finishGoldSprite:setAnchorPoint(ccp(1,0))
	_finishGoldSprite:setPosition(ccp(_finishItem:getContentSize().width*0.5,-_finishGoldSprite:getContentSize().height))

	local wipeGold = DevilTowerData.getWipeGold()
	if (DevilTowerData.isDevilTowerSweep() == false) then
		_finishCostLabel = CCLabelTTF:create((tonumber(towerInfo.max_hell)-tonumber(towerInfo.cur_hell)+1)*wipeGold, g_sFontName, 24)
		_finishCostLabel:setColor(ccc3(0x00, 0xff, 0x18))
		_finishCostLabel:setAnchorPoint(ccp(0,0))
		_finishCostLabel:setPosition(ccp(_finishItem:getContentSize().width*0.5,-_finishGoldSprite:getContentSize().height))
		_finishItem:addChild(_finishCostLabel)
	else
		if (_sweepEndLevel ~= nil) then
			_finishCostLabel = CCLabelTTF:create((_sweepEndLevel-tonumber(towerInfo.cur_hell)+1)*wipeGold, g_sFontName, 24)
			_finishCostLabel:setColor(ccc3(0x00, 0xff, 0x18))
			_finishCostLabel:setAnchorPoint(ccp(0,0))
			_finishCostLabel:setPosition(ccp(_finishItem:getContentSize().width*0.5,-_finishGoldSprite:getContentSize().height))
			_finishItem:addChild(_finishCostLabel)
		else
			_finishCostLabel = CCLabelTTF:create((tonumber(towerInfo.max_hell)-tonumber(towerInfo.cur_hell)+1)*wipeGold, g_sFontName, 24)
			_finishCostLabel:setColor(ccc3(0x00, 0xff, 0x18))
			_finishCostLabel:setAnchorPoint(ccp(0,0))
			_finishCostLabel:setPosition(ccp(_finishItem:getContentSize().width*0.5,-_finishGoldSprite:getContentSize().height))
			_finishItem:addChild(_finishCostLabel)
		end
	end
	-- 最高层
	if (tonumber(towerInfo.cur_hell)==tonumber(towerInfo.max_hell)) then
		_finishCostLabel:setString("0")
	end
end

--[[
	@desc	: 创建攻打怪物的UI
    @param	: 
    @return	: 
—-]]
function createAttackUI()
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local curFloorDesc = DevilTowerData.getDevilTowerById(towerInfo.cur_hell)

	if (_passedEffectSprite ~= nil) then
		_passedEffectSprite:removeFromParentAndCleanup(true)
		_passedEffectSprite = nil
	end

	if (_enterNextItem ~= nil) then
		_enterNextItem:removeFromParentAndCleanup(true)
		_enterNextItem = nil
	end

	if (_attackNpcItem ~= nil) then
		_attackNpcItem:removeFromParentAndCleanup(true)
		_attackNpcItem = nil
	end

	if (DevilTowerData.isDevilTowerHadPassed() == true) then
		-- 已通关
		_passedEffectSprite = XMLSprite:create("images/base/effect/tower/yitongguan")
		_passedEffectSprite:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
		_passedEffectSprite:setAnchorPoint(ccp(0.5,0.5))
		_passedEffectSprite:setScale(g_fElementScaleRatio)
		_bgLayer:addChild(_passedEffectSprite,999)

	elseif (_isEnterNextStatus == true) then
		-- 进入下一层
		local normalSprite = CCSprite:create()
		normalSprite:setContentSize(CCSizeMake(80, 150))
		_enterNextItem = CCMenuItemSprite:create(normalSprite, normalSprite)
		_enterNextItem:setAnchorPoint(ccp(0.5, 0))
		_enterNextItem:setScale(g_fElementScaleRatio)
		_enterNextItem:registerScriptTapHandler(enterNextCallback)
		_enterNextItem:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
		_mainMenu:addChild(_enterNextItem)

		-- 特效特效
		local nextEffectSprite = XMLSprite:create("images/base/effect/tower/xiayiguan")
		nextEffectSprite:setAnchorPoint(ccp(0.5,0.5))
	    nextEffectSprite:setPosition(_enterNextItem:getContentSize().width/2,0)
	    _enterNextItem:addChild(nextEffectSprite,-1);

	else
		-- 攻打怪物
		DevilTowerUtil.showBlackFadeAction()
		local monsterType = curFloorDesc.monsterType or 1
		local monsterQuality = curFloorDesc.monsterQuality or 1
		local monsterModel = curFloorDesc.monsterModel
		local monsterName = curFloorDesc.name

		_attackNpcItem = DevilTowerUtil.createNpcItemSprite(monsterType, monsterQuality, monsterModel, monsterName)
		_attackNpcItem:setAnchorPoint(ccp(0.5, 0))
		_attackNpcItem:registerScriptTapHandler(attackNpcCallback)
		_attackNpcItem:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
		_attackNpcItem:setScale(g_fElementScaleRatio)
		_mainMenu:addChild(_attackNpcItem)

		if (DevilTowerData.isDevilTowerSweep() == true) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1676") .. towerInfo.cur_hell ..  GetLocalizeStringBy("key_2400"))
		end

		-- 加特效
		DevilTowerUtil.addNpcEffectWithItem(monsterType,_attackNpcItem)
		_attackNpcItem:setVisible(false)

		-- 卡牌下落动画
		local dorpEndCallback = function()
			_attackNpcItem:setVisible(true)
		end
		local dropEffectSprite = DevilTowerUtil.createDropAnimationWithItem(monsterType, monsterQuality, monsterModel, dorpEndCallback)
		dropEffectSprite:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
	    dropEffectSprite:setAnchorPoint(ccp(0, 0))
	    dropEffectSprite:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(dropEffectSprite,9999)
	end
end

--[[
	@desc	: 启动扫荡定时器
    @param	: 
    @return	: 
—-]]
function startScheduler()
	if (_sweepScheduler == nil) then
		_sweepScheduler = schedule(_bgLayer,updateTimeFunc,1)
    	_sweepScheduler:setTag(kTagSchedulerAction)
    end
end

--[[
	@desc	: 停止扫荡定时器
    @param	: 
    @return	: 
—-]]
function stopScheduler()
	if (_sweepScheduler ~= nil) then
		if (not tolua.isnull(_bgLayer)) then
			_bgLayer:stopActionByTag(kTagSchedulerAction)
		end
		_sweepScheduler = nil
	end
end

--[[
	@desc	: 扫荡倒计时回调方法
    @param	: 
    @return	: 
—-]]
function updateTimeFunc()
	if (DevilTowerData.getSweepEndTime()) then
		-- 1.扫荡中
		-- 剩余时间
		local leftTimeInterval = DevilTowerData.getSweepEndTime() - TimeUtil.getSvrTimeByOffset()
		-- 倒计时
		if (_sweepRestTimeLabel ~= nil) then
			_sweepRestTimeLabel:setString(GetLocalizeStringBy("key_1124") .. TimeUtil.getTimeString(leftTimeInterval) )
		end
		if (leftTimeInterval > 0) then
			-- 1.1 扫荡倒计时中
			if (math.mod((TimeUtil.getSvrTimeByOffset() - DevilTowerData.getSweepStartTime()),DevilTowerData.getWipeCD()) == 0) then
				-- 处理扫荡的数据
				DevilTowerData.changeCurSweepHell()

				-- 刷新UI
				refreshMiddleUI()
				createAttackUI()
			end
		else
			-- 1.2 扫荡倒计时结束
			refreshSweepItem()
			stopScheduler()
			if(g_network_status == g_network_connected)then
				-- 重新拉取试炼梦魇信息
				DevilTowerController.getDevilTowerInfo(sweepOverCallback)
			else
				-- 增加断线重连回调
				LoginScene.addObserverForNetConnected("requestDevilTowerInfo", reConnectCallback)
			end
		end
	else
		-- 2.扫荡结束
		refreshSweepItem()
		stopScheduler()
	end
end

--[[
	@desc	: 扫荡正常倒计时结束
    @param	: 
    @return	: 
—-]]
function sweepOverCallback()
	-- 提示
	AnimationTip.showTip(GetLocalizeStringBy("key_1361"))

	-- 刷新UI
	refreshMiddleUI()
 	createAttackUI()
 	refreshSweepItem()
end

--[[
	@desc	: 断线重连后回调
    @param	: 
    @return	: 
—-]]
function reConnectCallback()
	-- 释放通知方法
	LoginScene.removeObserverForNetConnected("requestDevilTowerInfo")
	DevilTowerController.getDevilTowerInfo(sweepOverCallback)
end

--[[
	@desc	: 点击梦魇商店按钮回调
    @param	: 
    @return	: 
—-]]
function devilShopCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 判断试炼梦魇是否开启
    if (not DevilTowerData.isDevilTowerOpen()) then
        return
    end
	require "script/ui/deviltower/shop/DevilTowerShopLayer"
    local layer = DevilTowerShopLayer.create(_touchPriority-100,1000)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer,1000)
end

--[[
	@desc	: 点击试炼塔按钮回调
    @param	: 
    @return	: 
—-]]
function towerItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 进入试炼塔
	if (ItemUtil.isBagFull() == true) then
		return
	end
	local canEnter = DataCache.getSwitchNodeState( ksSwitchTower )
	if ( canEnter ) then
		require "script/ui/tower/TowerMainLayer"
		local towerMainLayer = TowerMainLayer.createLayer()
		MainScene.changeLayer(towerMainLayer, "towerMainLayer")
	end
	stopDevilTowerBgMusic()
end

--[[
	@desc	: 点击重置按钮回调
    @param	: 
    @return	: 
—-]]
function resetItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local resetCallback = function()
		-- 重置下一层状态
		_isEnterNextStatus = false

		-- 刷新UI
		refreshLoveStar()
		refreshTopUI()
		refreshMiddleUI()
		createAttackUI()
	end
	DevilTowerController.resetDevilTower(resetCallback)
end

--[[
	@desc	: 点击立即完成按钮回调
    @param	: 
    @return	: 
—-]]
function finishItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if (_canFinish) then
		local finishCallback = function()
			-- 刷新UI
			refreshTopUI()
			refreshMiddleUI()
			refreshLoveStar()
			createAttackUI()
		end
		DevilTowerController.finishDevilTower(finishCallback)
	end
end

--[[
	@desc	: 点击扫荡按钮回调
    @param	: 
    @return	: 
—-]]
function sweepItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local sweepCallback = function( pLevel )


		_sweepEndLevel = pLevel
		_isEnterNextStatus = false

		-- 处理扫荡的数据
		DevilTowerData.changeCurSweepHell()

		-- 刷新UI
		refreshSweepItem()

		-- 提示
		AnimationTip.showTip(GetLocalizeStringBy("key_2384"))

		-- 启动定时器
		if (DevilTowerData.isDevilTowerSweep() == true) then
			startScheduler()
		end
	end
	DevilTowerController.sweepDevilTower(sweepCallback)
end

--[[
	@desc	: 点击取消扫荡按钮回调
    @param	: 
    @return	: 
—-]]
function cancelSweepItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local endSweepCallback = function()
		-- 刷新UI
		refreshMiddleUI()
 		createAttackUI()
 		refreshSweepItem()
	end
	DevilTowerController.endSweepDevilTower(endSweepCallback)
end

--[[
	@desc	: 点击进入下一层按钮回调
    @param	: 
    @return	: 
—-]]
function enterNextCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local enterCallback = function()
		_isEnterNextStatus = false
		-- 爆特效
		local enterEffectSprite = XMLSprite:create("images/base/effect/tower/bao")
        enterEffectSprite:setScale(g_fElementScaleRatio)
        enterEffectSprite:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
   		_bgLayer:addChild(enterEffectSprite,9999)

        local animationEndCallback = function()
        	enterEffectSprite:removeFromParentAndCleanup(true)
        	enterEffectSprite = nil

        	-- 刷新UI 黑色转场
        	refreshMiddleUI()
	 		createAttackUI()
	 		refreshTopUI()
	    end
	    enterEffectSprite:registerEndCallback( animationEndCallback )
	end
	DevilTowerController.enterNextLayer(enterCallback)
end

--[[
	@desc	: 战斗回调方法
    @param	: pNewData 后端返回的新的试炼信息
    @return	: 
—-]]
function doBattleCallback( pNewData )
	local isPassed = false

	if (pNewData) then
		if( pNewData.pass and (pNewData.pass == "true" or pNewData.pass==true) )then
			isPassed = true
		end
	end

	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local curFloorDesc = DevilTowerData.getDevilTowerById(towerInfo.cur_hell)

	if (isPassed == true) then
		-- 过关
		_isEnterNextStatus = true

		-- 设置通关状态
		if (tonumber(towerInfo.cur_hell) == DevilTowerData.getMaxDevilTower()) then
			DevilTowerData.setDevilTowerPassedStatus(true)
		end

		-- 修改当前塔层
		DevilTowerData.addCurHell(1)

		createAttackUI()
		refreshTopUI()

	elseif (isPassed == false) then
		-- 未过关
		local conditionStr = DevilTowerData.getPassFloorCondition(curFloorDesc.star_condition)
		AnimationTip.showTip(GetLocalizeStringBy("key_2935") .. conditionStr)

		-- 扣除次数
		DevilTowerData.addDefeatTimes(-1)

		-- 刷新心显示
		refreshLoveStar()
	end
end

--[[
	@desc	: 点击攻击怪物按钮回调
    @param	: 
    @return	: 
—-]]
function attackNpcCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local curFloorDesc = DevilTowerData.getDevilTowerById(towerInfo.cur_hell)
	DevilTowerController.attackNpc(doBattleCallback,curFloorDesc.id,curFloorDesc.stronghold)
end


-- FileName: CountryWarEncourageLayer.lua
-- Author: yangrui
-- Date: 2015-11-18
-- Purpose: 国战鼓舞

module("CountryWarEncourageLayer", package.seeall)

require "script/ui/countryWar/encourage/CountryWarEncourageData"
require "script/ui/countryWar/encourage/CountryWarEncourageService"
require "script/ui/countryWar/encourage/CountryWarEncourageController"
require "script/ui/countryWar/encourage/CountryWarEncourageDialog"
require "script/ui/countryWar/foundation/CountryWarFoundationLayer"

local _bgLayer               = nil
local _forceUpLabel          = nil  -- 战斗力提升百分比Label
local _encourageMenuItem     = nil  -- 鼓舞按钮
local _detailPanel           = nil  -- 鼓舞子菜单背景
local _battleCDMenuItem      = nil  -- 参战冷却按钮
local _battleCDSp            = nil  -- 参战冷却CD
local _battleCDSchedule      = nil  -- 参战冷却CD定时器
local _bloodRecoveryMenuItem = nil

local _touchPriority 	 = nil
-- Tag
local kTagBattleCDSchedule = 8686  -- 参战冷却CD定时器Tag

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer               = nil
	_forceUpLabel          = nil  -- 战斗力提升百分比Label
	_encourageMenuItem     = nil  -- 鼓舞按钮
	_detailPanel           = nil  -- 鼓舞子菜单背景
	_battleCDMenuItem      = nil  -- 参战冷却按钮
	_battleCDSp            = nil  -- 参战冷却CD
	_battleCDSchedule      = nil  -- 参战冷却CD定时器
	_bloodRecoveryMenuItem = nil
	_touchPriority         = nil
end

--[[
	@des 	: 攻击鼓舞回调
	@param 	: 
	@return : 
--]]
function forceBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 网络请求
	CountryWarEncourageController.inspire(function( ... )
		-- 飘字
		local forceUpValue = CountryWarEncourageData.getEncourageUpForcePercent()
		local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("yr_5022",forceUpValue),g_sFontPangWa,30)
		tipLabel:setAnchorPoint(ccp(0.5,0.5))
		tipLabel:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
		tipLabel:setColor(ccc3(0x00,0xff,0x18))
		tipLabel:setScale(g_fScaleX)
		_bgLayer:addChild(tipLabel)
		-- 1s后执行动画
		local arrAction = CCArray:create()
		arrAction:addObject(CCMoveBy:create(1,ccp(0,100)))
		arrAction:addObject(CCFadeOut:create(1.2))
		arrAction:addObject(CCCallFunc:create(function( ... )
        	tipLabel:removeFromParentAndCleanup(true)
        	tipLabel = nil
        end))
		local seq = CCSequence:create(arrAction)
		tipLabel:runAction(seq)
	end)
end

--[[
	@des 	: 参战冷却按钮回调
	@param 	: 
	@return : 
--]]
function battleCDBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 网络请求
	CountryWarEncourageController.clearJoinCd(function( ... )
		stopBattleCDScheduler()
		-- 设置参战冷却时间
		-- 聪聪
		CountryWarPlaceData.setCanJoinTime(0)
		-- 自动参战
        CountryWarPlaceLayer.checkAutoJoin()
	end)
end

--[[
	@des 	: 回满血怒按钮回调
	@param 	: 
	@return : 
--]]
function bloodRecoveryBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 网络请求
	CountryWarEncourageController.recoverByUser(function( ... )
		-- 特效  聪聪
		CountryWarPlaceLayer.recoverEffect()
	end)
end

--[[
	@des 	: 国战资金按钮回调
	@param 	: 
	@return : 
--]]
function countryWarFundBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	CountryWarFoundationLayer.showLayer()
end

--[[
	@des 	: 设置按钮回调
	@param 	: 
	@return : 
--]]
function settingBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	CountryWarEncourageDialog.showLayer()
end

--[[
	@des 	: 设置定时器
	@param 	: 
	@return : 
--]]
function startBattleCDScheduler()
	-- 当前参战CD
    local curBattleCD = CountryWarPlaceData.getCanJoinTime()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	print("===|curBattleCD,curTime|===",curBattleCD,curTime)
    if curBattleCD > curTime then
	    local curBattleCDStr = TimeUtil.getTimeHHSSByString(curBattleCD-curTime)
	    _battleCDSp:setString(curBattleCDStr)
    	_battleCDSp:setVisible(true)
    else
    	print("===|cdTime end|===")
    	_battleCDSp:setVisible(false)
    	-- 如果不在战场 进入战场
    	if not CountryWarPlaceLayer.getIsJoinBattle() then
	    	-- 自动参战
	        CountryWarPlaceLayer.checkAutoJoin()
    	end
	end
end

--[[
	@des 	: 取消定时器
	@param 	: 
	@return : 
--]]
function stopBattleCDScheduler()
	-- CountryWarEncourageData.setBattleCDTime(CountryWarPlaceData.getCanJoinTime())
    _battleCDSp:setVisible(false)
end

--[[
	@des 	: 更新攻击Label
	@param 	: 
	@return : 
--]]
function updateForceUpLabel( ... )
	local forceUpValue = CountryWarEncourageData.getForceUpValue()
	if _forceUpLabel ~= nil then
		_forceUpLabel:setString(GetLocalizeStringBy("yr_5000",forceUpValue))
	end
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return : 
--]]
function createUI( ... )
	-- 按钮背景
	local btnBg = CCSprite:create("images/country_war/encourage/didii.png")
	btnBg:setAnchorPoint(ccp(0.5,0))
	local offsetY = 50
	btnBg:setPosition(ccp(_bgLayer:getContentSize().width/2,-offsetY*g_fScaleX))
	btnBg:setScale(g_fScaleX)
	_bgLayer:addChild(btnBg)
	-- 按钮MenuBar
	local btnMenuBar = CCMenu:create()
	btnMenuBar:setAnchorPoint(ccp(1,1))
	btnMenuBar:setPosition(ccp(0,0))
	btnMenuBar:setTouchPriority(_touchPriority-10)
	btnBg:addChild(btnMenuBar)
	-- 攻击鼓舞
    local forceMenuItem = CCMenuItemImage:create("images/country_war/encourage/force_btn_n.png","images/country_war/encourage/force_btn_h.png")
    forceMenuItem:setAnchorPoint(ccp(0.5,0))
	forceMenuItem:setPosition(ccp(btnBg:getContentSize().width*0.14,25+offsetY))
    forceMenuItem:registerScriptTapHandler(forceBtnCallback)
    forceMenuItem:setScale(0.8)
    btnMenuBar:addChild(forceMenuItem)
    -- 攻击鼓舞消耗
    local forceCost = CountryWarEncourageData.getEncourageCost()
    local forceCostLabel = CCLabelTTF:create(forceCost,g_sFontPangWa,20)
    forceCostLabel:setColor(ccc3(0xff,0xfe,0x00))
	forceCostLabel:setAnchorPoint(ccp(0.5,1))
	forceCostLabel:setPosition(ccp(forceMenuItem:getContentSize().width/2-forceCostLabel:getContentSize().width/2,0))
	forceMenuItem:addChild(forceCostLabel)
    local forceCostSp = CCSprite:create("images/common/countrycoin.png")
    forceCostSp:setAnchorPoint(ccp(0.5,1))
    forceCostSp:setPosition(ccp(forceMenuItem:getContentSize().width/2+forceCostSp:getContentSize().width/2,-4))
    forceCostSp:setScale(0.8)
    forceMenuItem:addChild(forceCostSp)
    -- 提升箭头
	local upArrowForceSp = CCSprite:create("images/common/xiangshang.png")
	upArrowForceSp:setAnchorPoint(ccp(0.5,0))
	upArrowForceSp:setPosition(ccp(forceMenuItem:getContentSize().width/2-upArrowForceSp:getContentSize().width/2,30))
	upArrowForceSp:setScale(0.5)
	forceMenuItem:addChild(upArrowForceSp)
	-- 攻击提升Label
	local forceUpValue = CountryWarEncourageData.getForceUpValue()
	_forceUpLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_5000",forceUpValue),g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_shadow)
	_forceUpLabel:setAnchorPoint(ccp(0.5,0))
	_forceUpLabel:setPosition(ccp(forceMenuItem:getContentSize().width/2+_forceUpLabel:getContentSize().width/2,30))
	_forceUpLabel:setColor(ccc3(0x00,0xff,0x18))
	forceMenuItem:addChild(_forceUpLabel)
	-- 参战冷却
	_battleCDMenuItem = CCMenuItemImage:create("images/country_war/encourage/battlecd_btn_n.png","images/country_war/encourage/battlecd_btn_h.png")
    _battleCDMenuItem:setAnchorPoint(ccp(0.5,0))
    _battleCDMenuItem:setPosition(ccp(btnBg:getContentSize().width*0.32,25+offsetY))
    _battleCDMenuItem:registerScriptTapHandler(battleCDBtnCallback)
    _battleCDMenuItem:setScale(0.8)
    btnMenuBar:addChild(_battleCDMenuItem)
    -- 倒计时
    _battleCDSp = CCRenderLabel:create("",g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_shadow)
    _battleCDSp:setAnchorPoint(ccp(0.5,0))
    _battleCDSp:setPosition(ccp(_battleCDMenuItem:getContentSize().width/2,28))
    _battleCDSp:setColor(ccc3(0x00,0xff,0x18))
    _battleCDMenuItem:addChild(_battleCDSp)
    -- 参战冷却
	_battleCDSchedule = schedule(_battleCDMenuItem,startBattleCDScheduler,1)
    -- removeCDCost
    local removeCDCost = CountryWarEncourageData.getRemoveBattleCDCost()
    local removeCDCostLabel = CCLabelTTF:create(removeCDCost,g_sFontPangWa,20)
    removeCDCostLabel:setColor(ccc3(0xff,0xfe,0x00))
	removeCDCostLabel:setAnchorPoint(ccp(0.5,1))
	removeCDCostLabel:setPosition(ccp(_battleCDMenuItem:getContentSize().width/2-removeCDCostLabel:getContentSize().width/2,0))
	_battleCDMenuItem:addChild(removeCDCostLabel)
    local removeCDCostSp = CCSprite:create("images/common/countrycoin.png")
    removeCDCostSp:setAnchorPoint(ccp(0.5,1))
    removeCDCostSp:setPosition(ccp(_battleCDMenuItem:getContentSize().width/2+removeCDCostSp:getContentSize().width/2,-4))
    removeCDCostSp:setScale(0.8)
    _battleCDMenuItem:addChild(removeCDCostSp)
	-- 回满血怒
	_bloodRecoveryMenuItem = CCMenuItemImage:create("images/country_war/encourage/recoveryblood_btn_n.png","images/country_war/encourage/recoveryblood_btn_h.png")
    _bloodRecoveryMenuItem:setAnchorPoint(ccp(0.5,0))
    _bloodRecoveryMenuItem:setPosition(ccp(btnBg:getContentSize().width*0.5,25+offsetY))
    _bloodRecoveryMenuItem:registerScriptTapHandler(bloodRecoveryBtnCallback)
    _bloodRecoveryMenuItem:setScale(0.8)
    btnMenuBar:addChild(_bloodRecoveryMenuItem)
    -- bloodRecoveryCost
    local bloodRecoveryCost = CountryWarEncourageData.getRecoveryBloodCost()
    local bloodRecoveryCostLabel = CCLabelTTF:create(bloodRecoveryCost,g_sFontPangWa,20)
    bloodRecoveryCostLabel:setColor(ccc3(0xff,0xfe,0x00))
	bloodRecoveryCostLabel:setAnchorPoint(ccp(0.5,1))
	bloodRecoveryCostLabel:setPosition(ccp(_bloodRecoveryMenuItem:getContentSize().width/2-bloodRecoveryCostLabel:getContentSize().width/2,0))
	_bloodRecoveryMenuItem:addChild(bloodRecoveryCostLabel)
    local bloodRecoveryCostSp = CCSprite:create("images/common/countrycoin.png")
    bloodRecoveryCostSp:setAnchorPoint(ccp(0.5,1))
    bloodRecoveryCostSp:setPosition(ccp(_bloodRecoveryMenuItem:getContentSize().width/2+bloodRecoveryCostSp:getContentSize().width/2,-4))
    bloodRecoveryCostSp:setScale(0.8)
    _bloodRecoveryMenuItem:addChild(bloodRecoveryCostSp)
	-- 国战资金
	local countryWarFundMenuItem = CCMenuItemImage:create("images/country_war/guozhanzijin_btn_n.png","images/country_war/guozhanzijin_btn_h.png")
    countryWarFundMenuItem:setAnchorPoint(ccp(0.5,0))
    countryWarFundMenuItem:setPosition(ccp(btnBg:getContentSize().width*0.68,25+offsetY))
    countryWarFundMenuItem:registerScriptTapHandler(countryWarFundBtnCallback)
    countryWarFundMenuItem:setScale(0.8)
    btnMenuBar:addChild(countryWarFundMenuItem)
	-- 设置
	local settingMenuItem = CCMenuItemImage:create("images/worldarena/gong_n.png","images/worldarena/gong_h.png")
    settingMenuItem:setAnchorPoint(ccp(0.5,0))
    settingMenuItem:setPosition(ccp(btnBg:getContentSize().width*0.86,25+offsetY))
    settingMenuItem:registerScriptTapHandler(settingBtnCallback)
    settingMenuItem:setScale(0.8)
    btnMenuBar:addChild(settingMenuItem)
end

--[[
	@des 	: 创建膜拜Layer
	@param 	: 
	@return : 
--]]
function createEncourageLayer( pTouchPriority )
	-- init
	init()

	_touchPriority = pTouchPriority or -600
	-- 设置鼓舞信息
	CountryWarEncourageData.setEncourageForceTimes()
	CountryWarEncourageData.setForceUpValue()
	_bgLayer = CCLayer:create()
	-- createUI
	createUI()

	return _bgLayer
end

--[[
	@des 	: 显示膜拜Layer
	@param 	: 
	@return : 
--]]
function showEncourageLayer( ... )
	-- body
end

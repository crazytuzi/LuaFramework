-- Filename: RefiningMainLayer.lua
-- Author: zhang zihang
-- Date: 2015-2-27
-- Purpose: 炼化炉主界面

module ("RefiningMainLayer", package.seeall)

require "script/ui/shop/RechargeLayer"
require "script/ui/main/BulletinLayer"
require "script/ui/refining/RefiningData"
require "script/ui/recycle/BreakDownSay"
require "script/ui/recycle/ResurrectSay"
require "script/ui/rechargeActive/RechargeActiveMain"
require "script/model/user/UserModel"
require "script/libs/LuaCCSprite"
require "script/audio/AudioUtil"

local _bgLayer  											--背景层
local _curLayer 											--当前所在页面
local _silverLabel 											--银币数量label
local _goldLabel 											--金币数量label
local _explanationMenu 										--说明按钮
local _mysteryShopMenu  									--神秘商店按钮
local _resolveMenu 											--炼化按钮
local _resurrectMenu 										--重生按钮                                        

local kPlusZOrder = 999										--说明界面z轴

local kTagResolve = RefiningData.kResolveMainTag 			--炼化按钮tag
local kTagResurrect = RefiningData.kResurrectMainTag 		--重生按钮tag

--==================== 化魂 ====================
-- 化魂按钮
local _soulMenu
-- 化魂按钮tag
local _kTagSoul = RefiningData.kSoulMainTag                                    

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_bgLayer = nil
	_curLayer = nil
	_silverLabel = nil
	_goldLabel = nil
	_explanationMenu = nil
	_mysteryShopMenu = nil
	_resolveMenu = nil
	_resurrectMenu = nil
	_soulMenu = nil
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function onNodeEvent(p_event)
	--华仔当年写的刷新金币数量的注册方法，在退出时取消注册
	if p_event == "exit" then
		RechargeLayer.registerChargeGoldCb(nil)
	end
end

--==================== CallBack ====================
--[[
	@des 	:切换按钮回调
	@param 	:按钮tag值
--]]
function changeModeCallBack(p_tag)
	local curTag = RefiningData.getCurMainTag()

	--设置当前标签显示为已选择
	changeSelectStatus(p_tag)

	--如果当前所在页面和点击的是同一个，则没有反应
	if curTag == p_tag then
		return
	end

	--设置当前tag
	RefiningData.setCurMainTag(p_tag)
	--重置最新页面数据
	RefiningData.resetSelectData()
	--创建要切换到的页面
	createCurLayer(p_tag)
end

--[[
	@des 	:更新银币数量
--]]
function updateSilverNum()
	local userInfo = UserModel.getUserInfo()
	-- modified by yangrui at 2015-12-03
	_silverLabel:setString(string.convertSilverUtilByInternational(tonumber(userInfo.silver_num)))
end

--[[
	@des 	:更新金币数量
--]]
function updateGoldNum()
	local userInfo = UserModel.getUserInfo()
	_goldLabel:setString(userInfo.gold_num)
end

--[[
	@des 	:更新金银币数据数量回调
--]]
function updateCoinNumCallBack()
	--更新银币数量
	updateSilverNum()
	--更新金币数量
	updateGoldNum()
end

--[[
	@des 	:说明按钮回调
--]]
function explanationCallBack()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local curTag = RefiningData.getCurMainTag()
	if curTag == kTagResolve then
		local showLayer = BreakDownSay.createLayer()
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(showLayer,kPlusZOrder)
	elseif curTag == kTagResurrect then
		local showLayer = ResurrectSay.createLayer()
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(showLayer,kPlusZOrder)
	elseif curTag == _kTagSoul then
		require "script/ui/recycle/SoulSay"
		local showLayer = SoulSay.createLayer()
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(showLayer,kPlusZOrder)
	end
end

--[[
	@des 	:神秘商店回调
--]]
function mysteryShopCallBack()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---[==[炼化炉 新手引导屏蔽层 第3步changLayer
	---------------------新手引导---------------------------------
		--add by licong 2013.09.06
		require "script/guide/NewGuide"
		require "script/guide/ResolveGuide"
		if(NewGuide.guideClass ==  ksGuideResolve and ResolveGuide.stepNum == 3) then
			ResolveGuide.changLayer()
		end
	---------------------end-------------------------------------
	--]==]
	require "script/ui/shopall/ShoponeLayer"
	ShoponeLayer.show(ShoponeLayer.ksTagMysteryShop)
end

--[[
	@des 	:改变标签选中显示状态
	@param 	:要选中的标签
--]]
function changeSelectStatus(p_curTag)
	if p_curTag == kTagResolve then
		_resolveMenu:selected()
		_resurrectMenu:unselected()
		_soulMenu:unselected()
	elseif(p_curTag == _kTagSoul) then
		_soulMenu:selected()
		_resurrectMenu:unselected()
		_resolveMenu:unselected()
	elseif p_curTag == kTagResurrect then
		_resurrectMenu:selected()
		_resolveMenu:unselected()
		_soulMenu:unselected()
	end
end

--[[
	@des 	:将所有按钮设置不可点击
--]]
function setMenuItemDisable()
	local curTag = RefiningData.getCurMainTag()
	if curTag == kTagResolve then
		_resolveMenu:setEnabled(false)
		_resolveMenu:selected()
	elseif (curTag == _kTagSoul) then
		_soulMenu:setEnabled(false)
		_soulMenu:selected()
	else
		_resurrectMenu:setEnabled(false)
		_resurrectMenu:selected()
	end
	_explanationMenu:setEnabled(false)
	_mysteryShopMenu:setEnabled(false)
end

--[[
	@des 	:将所有按钮设置为可点
--]]
function setMenuItemEnable()
	local curTag = RefiningData.getCurMainTag()
	if curTag == kTagResolve then
		_resolveMenu:setEnabled(true)
		_resolveMenu:selected()
	elseif (curTag == _kTagSoul) then
		_soulMenu:setEnabled(true)
		_soulMenu:selected()
	elseif (curTag == kTagResurrect) then
		_resurrectMenu:setEnabled(true)
		_resurrectMenu:selected()
	end
	_explanationMenu:setEnabled(true)
	_mysteryShopMenu:setEnabled(true)
	_soulMenu:setEnabled(true)
end

--==================== UI ====================
--[[
	@des 	:创建顶部切换按钮
	@param  :要切换的页面tag
--]]
function createCurLayer(p_tag)
	--删除之前创建的layer
	if _curLayer ~= nil then
		_curLayer:removeAllChildrenWithCleanup(true)
	end
	--创建炼化页面
	if p_tag == kTagResolve then
		require "script/ui/refining/ResolveLayer"
		_curLayer = ResolveLayer.createLayer()
	--创建化魂页面
	elseif p_tag == _kTagSoul then
		require "script/ui/refining/SoulLayer"
		_curLayer = SoulLayer.createLayer()
	--创建重生页面
	elseif p_tag == kTagResurrect then
		require "script/ui/refining/RebornLayer"
		_curLayer = RebornLayer.createLayer()
	end

	_bgLayer:addChild(_curLayer)
end

--[[
	@des 	:创建顶部切换按钮和当前界面UI
--]]
function createTopMenuAndUI()
	--创建主菜单标签
	local argsTable = {}
	--炼化
	argsTable[1] = { text = GetLocalizeStringBy("key_3040"),x = 10,tag = kTagResolve,handler = changeModeCallBack }
	--重生
	argsTable[2] = { text = GetLocalizeStringBy("key_2251"),x = 200,tag = kTagResurrect,handler = changeModeCallBack }
	--化魂
	argsTable[3] = { text = GetLocalizeStringBy("key_10338"),x = 390,tag = _kTagSoul,handler = changeModeCallBack }

	--创建顶部菜单栏的公用方法
	local topMenu = LuaCCSprite.createTitleBar(argsTable)
	topMenu:setAnchorPoint(ccp(0,1))
	topMenu:setPosition(0,g_winSize.height - 50*g_fScaleX)
	topMenu:setScale(g_fScaleX)
	_bgLayer:addChild(topMenu)

	--获取两个分标签
	local tempMenu = tolua.cast(topMenu:getChildByTag(10001),"CCMenu")
	_resolveMenu = tolua.cast(tempMenu:getChildByTag(kTagResolve),"CCMenuItem")
	_resurrectMenu = tolua.cast(tempMenu:getChildByTag(kTagResurrect),"CCMenuItem")
	_soulMenu = tolua.cast(tempMenu:getChildByTag(_kTagSoul),"CCMenuItem")

	--当前tag
	local curTag = RefiningData.getCurMainTag()
	--设置当前标签选中状态
	changeSelectStatus(curTag)
	--创建当前界面UI
	createCurLayer(curTag)
end

--[[
	@des 	:创建中部的入口按钮
--]]
function createMiddleMenu()
	local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    _bgLayer:addChild(bgMenu)

    --按钮距离左右边界的距离
    local xPos = g_winSize.width*60/640
    --按钮距离上边界的距离
    local yPos = g_winSize.height - 230*g_fScaleY

    --说明按钮
	_explanationMenu = CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png","images/recycle/btn/btn_explanation_n.png")
	_explanationMenu:registerScriptTapHandler(explanationCallBack)
	_explanationMenu:setScale(g_fElementScaleRatio)
	_explanationMenu:setAnchorPoint(ccp(0.5,0.5))
	_explanationMenu:setPosition(xPos,yPos)
	bgMenu:addChild(_explanationMenu)

	--神秘商店按钮
	_mysteryShopMenu = CCMenuItemImage:create("images/recycle/btn/btn_mysterystore_h.png","images/recycle/btn/btn_mysterystore_n.png")
	_mysteryShopMenu:registerScriptTapHandler(mysteryShopCallBack)
	_mysteryShopMenu:setScale(g_fElementScaleRatio)
	_mysteryShopMenu:setAnchorPoint(ccp(0.5,0.5))
	_mysteryShopMenu:setPosition(g_winSize.width - xPos,yPos)
	bgMenu:addChild(_mysteryShopMenu)
end

--[[
	@des 	:创建顶部UI
--]]
function createTopUI()
	--走马灯大小
	local bulletSize = BulletinLayer.getLayerContentSize()

	--信息栏背景
	local topBgSprite = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBgSprite:setAnchorPoint(ccp(0,1))
    topBgSprite:setPosition(0,g_winSize.height - bulletSize.height*g_fScaleX)
    topBgSprite:setScale(g_fScaleX)
    _bgLayer:addChild(topBgSprite)

    --信息栏背景大小
    local topBgSize = topBgSprite:getContentSize()

    --添加战斗力文字图片
    local powerSprite = CCSprite:create("images/common/fight_value.png")
    powerSprite:setAnchorPoint(ccp(0.5,0.5))
    powerSprite:setPosition(topBgSize.width*0.13,topBgSize.height*0.43)
    topBgSprite:addChild(powerSprite)

    --读取用户信息
    local userInfo = UserModel.getUserInfo()
    
    --战斗力
    local powerLabel = CCRenderLabel:create(tostring(UserModel.getFightForceValue()),g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    powerLabel:setColor(ccc3(0xff,0xf6,0x00))
    powerLabel:setPosition(topBgSize.width*0.23,topBgSize.height*0.66)
    topBgSprite:addChild(powerLabel)
    
    --银币
    -- modified by yangrui at 2015-12-03
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(topBgSize.width*0.61,topBgSize.height*0.43)
    topBgSprite:addChild(_silverLabel)
    
    --金币
    _goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(topBgSize.width*0.82,topBgSize.height*0.43)
    topBgSprite:addChild(_goldLabel)

    --注册华仔当年写的更新金银币数量的方法
    RechargeLayer.registerChargeGoldCb(updateCoinNumCallBack)
end

--[[
	@des 	:创建背景UI
--]]
function createBgUI()
	--主背景
	local bgSprite = CCSprite:create("images/recycle/recyclebg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.5)
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	--炼化炉
	local stoveSprite = CCSprite:create("images/recycle/owen.png")
	stoveSprite:setAnchorPoint(ccp(0.5,0.5))
	stoveSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.5 + 50*g_fScaleY)
	stoveSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(stoveSprite)
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--创建背景相关的UI
	createBgUI()
	--创建切换按钮和当前页面
	createTopMenuAndUI()
	--创建顶部信息UI
	createTopUI()
	--创建中部的按钮
	createMiddleMenu()
end

--[[
	@des 	:创建特效
--]]
function createAnimation(p_callBack)
	AudioUtil.playEffect("audio/effect/chongshen.mp3")
	--炉子特效
	local stoveAnimation = XMLSprite:create("images/base/effect/recycle/chongsheng")
	stoveAnimation:setReplayTimes(1)
	stoveAnimation:registerEndCallback(p_callBack)
	stoveAnimation:setScale(g_fElementScaleRatio)
	stoveAnimation:setPosition(g_winSize.width*0.5,g_winSize.height*0.5 + 110*g_fScaleY)
	_bgLayer:addChild(stoveAnimation)
	--法轮大法特效
	local wheelAnimation = XMLSprite:create("images/base/effect/recycle/fazhen")
	wheelAnimation:setReplayTimes(1)
	wheelAnimation:setScale(g_fElementScaleRatio)
	wheelAnimation:setPosition(g_winSize.width*0.5,g_winSize.height*0.5 - 90*g_fScaleY)
	_bgLayer:addChild(wheelAnimation)
end

--==================== Entrance ====================
--[[
	@des 	:创建炼化炉主页面
	@param  :是否初始化数据层
--]]
function createLayer(p_isInitData)
	init()

	--如果从外部进入炼化炉，需要对数据进行初始化
	if p_isInitData then
		RefiningData.resetAllData()
	end

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	createUI()

	MainScene.setMainSceneViewsVisible(true,false,true)
	MainScene.changeLayer(_bgLayer,"RefiningMainLayer")

	-- 炼化炉 第2步 内部提示
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideResolveGuide2()
		end))
	_bgLayer:runAction(seq)
end

---[==[炼化炉 第2步 内部提示
---------------------新手引导---------------------------------
function addGuideResolveGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/ResolveGuide"
    if(NewGuide.guideClass == ksGuideResolve and ResolveGuide.stepNum == 1) then
        ResolveGuide.show(2, nil)
    end
end
---------------------end-------------------------------------
--]==]

function returnMysteryStore()
	return _mysteryShopMenu
end
-- Filename：	PurgatoryMainLayer.lua
-- Author：		LLP
-- Date：		2015-5-21
-- Purpose：		炼狱主界面


module("PurgatoryMainLayer", package.seeall)

require "db/DB_Vip"
require "db/DB_Army"
require "db/DB_Team"
require "db/DB_Heroes"
require "db/DB_Lianyutiaozhan_rule"
require "script/utils/TimeUtil"
require "script/animation/XMLSprite"
require "script/ui/purgatorychallenge/PurgatoryUtil"
require "script/ui/purgatorychallenge/PurgatoryScoreLayer"
require "script/ui/purgatorychallenge/PurgatoryData"
require "script/ui/purgatorychallenge/PurgatoryServes"
require "script/ui/purgatorychallenge/PurgatoryAddHeroLayer"
require "script/ui/purgatorychallenge/PurgatoryRewardPreviewLayer"


local _kTagBox            = 10001		--宝箱tag
local _kTagBattle         = 10002		--据点tag
local _kTagBuff           = 10003 	--附加属性tag
local _topSpriteBgTag     = 777		--上面适配sprite
local _passNameBgTag      = 1000 		--关卡名板
local _bodyMenuAndItemTag = 111 --中间按钮menu和item
local _mainBgTag          = 999		--主背景
local _tongGuanTeXiao     = 101 		--该layer特效和mainscene一个layer

local kDarkLayerZOrder    = 100
local _topSpriteBg        = nil
local _passNameBg         = nil
local _weaponShopItem     = nil
local _copyInfo           = nil 		--enter信息
local _mainLayer          = nil		--主层
local _starLabel          = nil		--下边星数label
local _defeatLabel        = nil		--下边防御label
local _lifeLabel          = nil		--下边血量label
local _attackLabel        = nil 		--下边攻击label
local _challengeTimeLabel = nil
local _priceNumLabel      = nil
local _dialog             = nil
local _closeMenuItem      = nil
local _touch_priority     = -500      --触摸相应级别
local _canClick           = true
local _showAll            = false

local _status             = 1 		--1为据点
local _challengeTime      = 0
local _buyNum             = 0
local _atkcost            = 0

--名称、 关卡层数、积分
local _passPointLabel
local _passNameLabel
local _passNumLabel

local _isRewardTime       = true

local _middleItem         = nil
local addTimeMenu         = nil
local bottomBgSprite      = nil

--中间的按钮是否有效, 防止特效没播完
local _isCanEffect        = false

-- 播放特效时屏蔽按钮事件
local _interceptLayer     = nil

local _toNextMenu         = nil

-- 光特效
local _lightEffect        = nil


--初始化
function init( ... )
	-- body
	_topSpriteBg 		= nil
	_passNameBg 		= nil
	_closeMenuItem    	= nil
	_weaponShopItem     = nil
	_copyInfo 			= nil
	_mainLayer 			= nil
	_starLabel 			= nil
	_defeatLabel		= nil
	_lifeLabel 			= nil
	_attackLabel 		= nil
	_passPointLabel 	= nil
	_passNameLabel		= nil
	_passNumLabel		= nil
	addTimeMenu 		= nil
	_interceptLayer 	= nil
	_challengeTimeLabel = nil
	_priceNumLabel 		= nil
	_dialog 			= nil
	_isRewardTime 		= true
	_canClick 			= true
	_showAll 			= false
	_middleItem 		= nil
	_toNextMenu 		= nil
	_lightEffect 		= nil
	bottomBgSprite 		= nil
	_challengeTime 		= 0
	_status 			= 1
	_buyNum 			= 0
end

--layer进入退出
function onNodeEvent(event)
	if (event == "enter") then
		_mainLayer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _mainLayer:setTouchEnabled(true)
        AudioUtil.playBgm("audio/bgm/music17.mp3")
	elseif (event == "exit") then
		_mainLayer:unregisterScriptTouchHandler()
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	end
end
--layer触摸事件
function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		return false
	end
end

-----------------------------------------------命令相关BEGIN-----------------------------------
--发送enter命令
function sendCommond( ... )
	-- body
	PurgatoryServes.getCopyInfo(createLayer)
end
-- 判断活动未开始相关显示
function getShowStatus( ... )
	-- body
	local curServerTime = BTUtil:getSvrTimeInterval()
	if(tonumber(curServerTime)<tonumber(_copyInfo.begin_time) or tonumber(curServerTime)>=tonumber(_copyInfo.end_time))then
		return false
	else
		return true
	end
end

function createTimeLabel( ... )
	-- body
	local str = GetLocalizeStringBy("llp_198")
	local str1 = ""
	local topBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	local sprite = CCSprite:create()
	_mainLayer:addChild(topBg, 10)
	topBg:setContentSize(CCSizeMake(640, 50))
	topBg:setAnchorPoint(ccp(0.5, 1))
	topBg:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _mainLayer:getContentSize().height-_mainLayer:getChildByTag(_topSpriteBgTag):getChildByTag(_passNameBgTag):getContentSize().height*g_fScaleX*1.3))
	topBg:setScale(g_fScaleX)

	local label = CCLabelTTF:create(str,g_sFontPangWa,25)
	label:setAnchorPoint(ccp(0,0))
	sprite:addChild(label,1)
	label:setPosition(ccp(0,0))
	label:setColor(ccc3(0xff,0xf6,0x00))

	local timeLabel = CCLabelTTF:create(str1,g_sFontPangWa,25)
	local deltaTime = tonumber(_copyInfo.period_end_time)-tonumber(_copyInfo.reward_end_time)
	timeLabel:setAnchorPoint(ccp(0,0))
	sprite:addChild(timeLabel,1)
	timeLabel:setPosition(ccp(label:getContentSize().width,0))
	timeLabel:setColor(ccc3(0x00,0xff,0x18))
	sprite:setContentSize(CCSizeMake(label:getContentSize().width+timeLabel:getContentSize().width,label:getContentSize().height))
	local curServerTime = BTUtil:getSvrTimeInterval()
	local actions1 = CCArray:create()
            actions1:addObject(CCDelayTime:create(1))
            actions1:addObject(CCCallFunc:create(function ( ... )
                curServerTime = BTUtil:getSvrTimeInterval()
                if(tonumber(curServerTime)<tonumber(_copyInfo.begin_time))then
                	if(tonumber(curServerTime)>(tonumber(_copyInfo.begin_time)-deltaTime))then
                		setClick(true)
                		_isRewardTime = true
                	else
                		_showAll = true
                		_isRewardTime = false
                		setClick(true)
                	end
					str  = GetLocalizeStringBy("llp_198")
					str1 = TimeUtil.getRemainTime(tonumber(_copyInfo.begin_time))
                	freshAnimation(false)
                elseif(tonumber(curServerTime)==tonumber(_copyInfo.begin_time))then
					str  = GetLocalizeStringBy("llp_199")
					str1 = TimeUtil.getRemainTime(tonumber(_copyInfo.end_time))
                	_isRewardTime = false
                	setClick(true)
                	PurgatoryServes.getCopyInfo(refreshFunc)
                	freshAnimation(true)
                elseif(tonumber(curServerTime)>tonumber(_copyInfo.begin_time) and tonumber(curServerTime)<tonumber(_copyInfo.end_time))then
					str  = GetLocalizeStringBy("llp_199")
					str1 = TimeUtil.getRemainTime(tonumber(_copyInfo.end_time))
                	_isRewardTime = false
            	elseif(tonumber(curServerTime)==tonumber(_copyInfo.end_time))then
            		local runningScene = CCDirector:sharedDirector():getRunningScene()
            		if(runningScene:getChildByTag(87)~=nil)then
            			runningScene:removeChildByTag(87,true)
            		end
					str  = GetLocalizeStringBy("llp_198")
					str1 = TimeUtil.getRemainTime(tonumber(_copyInfo.period_end_time)+1)
                	setClick(true)
                	_isRewardTime = false
                	refreshFunc()
                	freshAnimation(false)
                	if(_mainLayer:getChildByTag(_tongGuanTeXiao)~=nil)then
						_mainLayer:removeChildByTag(_tongGuanTeXiao,true)
					end
					if(_mainLayer:getChildByTag(_mainBgTag)~=nil and _mainLayer:getChildByTag(_mainBgTag):getChildByTag(_bodyMenuAndItemTag)~=nil)then
						_mainLayer:getChildByTag(_mainBgTag):removeChildByTag(_bodyMenuAndItemTag,true)
					end
					if(_mainLayer:getChildByTag(_bodyMenuAndItemTag)~=nil)then
						_mainLayer:removeChildByTag(_bodyMenuAndItemTag,true)
					end
                elseif(tonumber(curServerTime)>tonumber(_copyInfo.end_time) and tonumber(curServerTime)<=tonumber(_copyInfo.reward_end_time))then
					str  = GetLocalizeStringBy("llp_198")
					str1 = TimeUtil.getRemainTime(tonumber(_copyInfo.period_end_time)+1)
                	setClick(true)
                	_isRewardTime = false
                elseif(tonumber(curServerTime)>tonumber(_copyInfo.reward_end_time) and tonumber(curServerTime)<tonumber(_copyInfo.period_end_time))then
					str  = GetLocalizeStringBy("llp_198")
					str1 = TimeUtil.getRemainTime(tonumber(_copyInfo.period_end_time)+1)
                	setClick(true)
                	_isRewardTime = true
                	freshAnimation(false)
                elseif(tonumber(curServerTime)==tonumber(_copyInfo.period_end_time)+1)then
                	_isRewardTime = false
                	setClick(true)
                	PurgatoryServes.getCopyInfo(refreshFunc)
                	str = GetLocalizeStringBy("llp_199")
                	str1 = TimeUtil.getRemainTime(tonumber(_copyInfo.end_time))
                	freshAnimation(true)
                end
                label:setString(str)
                timeLabel:setString(str1)
                sprite:setContentSize(CCSizeMake(label:getContentSize().width+timeLabel:getContentSize().width,label:getContentSize().height))
            end))
    local sequence = CCSequence:create(actions1)
    local action = CCRepeatForever:create(sequence)
    topBg:addChild(sprite)
	sprite:setAnchorPoint(ccp(0.5,0.5))
	sprite:setPosition(ccp(topBg:getContentSize().width*0.5,topBg:getContentSize().height*0.5))
    _mainLayer:runAction(action)
end
--获取copyInfo信息
function getCopyInfoFunc( ... )
	-- body
	_copyInfo = PurgatoryData.getCopyInfo()

	--创建背景
	createBg()
	--创建上边栏
	createTop()
	--创建中间布局
	createMiddle()
	--创建底部布局
	createBottom()
	createTimeLabel()
	-- 刷新
	refreshTop()
	refreshBottom()
	MainScene.changeLayer(_mainLayer, "PurgatoryMainLayer")
	MainScene.setMainSceneViewsVisible(false,false,false)
end

--刷新
function refreshFunc( ... )
	-- body
	_mainLayer:setTouchEnabled(true)

	_copyInfo = PurgatoryData.getCopyInfo()
	-- body
	refreshTop()
	refreshBottom()
	refreshMiddle()
end
-----------------------------------------------命令相关END-----------------------------------

-----------------------------------------------上中下布局相关创建BEGIN-----------------------------------
function createBg()
	--背景图片
	local mainBg = CCSprite:create("images/purgatory/" .. "purgatorybg.jpg" )--GodWeaponCopyData.getCopyBgName()
	mainBg:setScale(g_fBgScaleRatio)
	mainBg:setAnchorPoint(ccp(0.5,0.5))
	mainBg:setPosition(_mainLayer:getContentSize().width*0.5,_mainLayer:getContentSize().height*0.5)
	_mainLayer:addChild(mainBg,1,_mainBgTag)

	-- 场景特效
    changjingSprite = XMLSprite:create("images/purgatory/lianyu_changjing/lianyu_changjing")
    changjingSprite:setPosition(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.5)
    mainBg:addChild(changjingSprite,1)

    -- up特效
    upSprite = XMLSprite:create("images/purgatory/lianyu_kapaiup/lianyu_kapaiup")
    upSprite:setPosition(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.5)
    mainBg:addChild(upSprite,100)
    upSprite:setVisible(getShowStatus())
    -- down特效
    downSprite = XMLSprite:create("images/purgatory/lianyu_kapaidown/lianyu_kapaidown")
    downSprite:setPosition(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height*0.5)
    upSprite:setVisible(getShowStatus())
    mainBg:addChild(downSprite,1)
end

--返回当前是哪关
function getPassName( ... )
	-- body
	local str = 0
	if(tonumber(_copyInfo.passed_stage)~=6)then
		str = tonumber(_copyInfo.passed_stage)+1
	else
		str = 6
	end
	return str
end

--创建上边栏
function createTop( ... )
	--上边总sprite 缩放用
	_topSpriteBg = CCSprite:create()
	_topSpriteBg:setAnchorPoint(ccp(0, 1))
	_topSpriteBg:setPosition(ccp(0, g_winSize.height))
	_topSpriteBg:setContentSize(CCSizeMake(640, 130))
	_topSpriteBg:setScale(g_fScaleX)
	_mainLayer:addChild(_topSpriteBg,1,_topSpriteBgTag)

	-- body
	--当前关卡名称底板 如果活动未开启显示炼狱副本 开启显示具体关卡
	if(not getShowStatus())then
		_passNameBg = CCSprite:create("images/purgatory/challengebg.png")
	else
		_passNameBg = CCSprite:create("images/purgatory/levelbg.png")

		local str = getPassName()
		--具体关卡名字
		local monsterId = tonumber(_copyInfo.monster[tostring(str)])
		local armyData = DB_Army.getDataById(monsterId)
		_passNameLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_119",str),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		_passNameLabel:setColor(ccc3(0xff,0xf6,0x00))
		_passNameBg:addChild(_passNameLabel,1,1)
		_passNameLabel:setAnchorPoint(ccp(0.5,0))
		_passNameLabel:setPosition(ccp(_passNameBg:getContentSize().width*0.5,_passNameBg:getContentSize().height*5/12))
		_passNumLabel = CCRenderLabel:create(armyData.display_name,g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		_passNumLabel:setColor(ccc3(0xff,0xff,0xff))
		_passNameBg:addChild(_passNumLabel,1,2)
		_passNumLabel:setAnchorPoint(ccp(0.5,1))
		_passNumLabel:setPosition(ccp(_passNameBg:getContentSize().width*0.5,_passNameBg:getContentSize().height*4/12))
	end
	_topSpriteBg:addChild(_passNameBg,1,_passNameBgTag)
	_passNameBg:setAnchorPoint(ccp(0.5,1))
	_passNameBg:setPosition(ccp(_topSpriteBg:getContentSize().width*0.5,_topSpriteBg:getContentSize().height))

	--上边Menu
	local clickMenu = CCMenu:create()
	clickMenu:setTouchPriority(_touch_priority-1)
	clickMenu:setAnchorPoint(ccp(0,0))
	clickMenu:setPosition(ccp(0,0))
	_topSpriteBg:addChild(clickMenu)

	--排行Item
	local rankItem = CCMenuItemImage:create("images/match/paihang_n.png", "images/match/paihang_h.png")
	clickMenu:addChild(rankItem,1,1)
	rankItem:setAnchorPoint(ccp(0,0.5))
	rankItem:registerScriptTapHandler(rankListAction)
	rankItem:setPosition(ccp(0,_topSpriteBg:getContentSize().height*0.5))

	-- 奖励预览按钮
    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(0,0.5))
    clickMenu:addChild(rewardMenuItem,1,1)
	rewardMenuItem:registerScriptTapHandler(rewardAction)
	rewardMenuItem:setPosition(ccp(rankItem:getContentSize().width,_topSpriteBg:getContentSize().height*0.5))
	-- 返回Item
	_closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	_closeMenuItem:registerScriptTapHandler(backAction)
	clickMenu:addChild(_closeMenuItem)
	_closeMenuItem:setAnchorPoint(ccp(1,0.5))
	_closeMenuItem:setPosition(ccp(_passNameBg:getPositionX()*2-rankItem:getPositionX(),_topSpriteBg:getContentSize().height*0.5))
end

function getBodyStr( ... )
	-- body
	local monsterId = tonumber(_copyInfo.monster[tostring(tonumber(_copyInfo.passed_stage)+1)])
	local armyData = DB_Army.getDataById(monsterId)
	local monsterGroupId = tonumber(armyData.monster_group)
	local monsterData = DB_Team.getDataById(monsterGroupId)
	local heroId = tonumber(monsterData.copyTeamShowId)
	local heroBodyStr = DB_Heroes.getDataById(heroId).body_img_id
	return heroBodyStr
end

--创建中间布局
function createMiddle( ... )
	--判断通关状态 通关:显示通关特效 未通关:显示英雄身相 并且活动未开启时中间部分不显示
	if(not PurgatoryData.isHavePass())then
		local heroBodyStr = getBodyStr()

		local bodyMenu = CCMenu:create()
		bodyMenu:setAnchorPoint(ccp(0,0))
		bodyMenu:setPosition(ccp(0,0))
		_mainLayer:getChildByTag(_mainBgTag):addChild(bodyMenu,1,_bodyMenuAndItemTag)
		bodyMenu:setTouchPriority(_touch_priority-1)
		local bodyItem = nil
		if(getShowStatus()==true)then
			bodyItem = CCMenuItemImage:create("images/base/hero/body_img/"..heroBodyStr, "images/base/hero/body_img/"..heroBodyStr)
			-- 上部特效 上下动的箭头
		    local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/tower/guangbiao"), -1,CCString:create(""));
		    spellEffectSprite_2:retain()
		    spellEffectSprite_2:setPosition(bodyItem:getContentSize().width*0.5, bodyItem:getContentSize().height)
		    bodyItem:addChild(spellEffectSprite_2,1);
		    spellEffectSprite_2:release()
		    bodyMenu:addChild(bodyItem,1,_bodyMenuAndItemTag)
			bodyItem:setAnchorPoint(ccp(0.5,0.5))
			bodyItem:setPosition(ccp(_mainLayer:getChildByTag(_mainBgTag):getContentSize().width*0.5,_mainLayer:getChildByTag(_mainBgTag):getContentSize().height*0.4))
			bodyItem:registerScriptTapHandler(bodyClickAction)
		end
	else
		if(getShowStatus()==true)then
			local _spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/purgatory/lianyu_tongguan/lianyu_tongguan"), -1,CCString:create(""));
		    _spellEffectSprite:setAnchorPoint(ccp(0.5,0))
		    _spellEffectSprite:retain()
		    _spellEffectSprite:setScale(g_fElementScaleRatio)
		    _spellEffectSprite:setPosition(ccp(_mainLayer:getContentSize().width*0.5, _mainLayer:getContentSize().height*0.5))
		    _mainLayer:addChild(_spellEffectSprite,1,_tongGuanTeXiao);
		    _spellEffectSprite:release()

		    local bodyMenu = CCMenu:create()
			_mainLayer:addChild(bodyMenu,1,_bodyMenuAndItemTag)
			bodyMenu:setTouchPriority(_touch_priority-1)

		    local refreshItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_186"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		    refreshItem:setAnchorPoint(ccp(0.5,1))
		    refreshItem:setPosition(ccp(0, -_mainLayer:getContentSize().height*0.32))
		    refreshItem:setScale(g_fScaleY )
		    refreshItem:registerScriptTapHandler(bodyClickAction)
			bodyMenu:addChild(refreshItem,1,_bodyMenuAndItemTag)
		end
	end
end
--创建底边栏
function createBottom( ... )
	local _copyInfo = PurgatoryData.getCopyInfo()
	local passNameBg = CCSprite:create("images/godweaponcopy/passnamebg.png")
	--挑战次数label
	local challengeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_160"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	challengeLabel:setColor(ccc3(0xff,0xff,0xff))
	challengeLabel:setAnchorPoint(ccp(0,0.5))
	--挑战次数数值
	local normalData = DB_Lianyutiaozhan_rule.getDataById(1)
	_challengeTime = tonumber(_copyInfo.atk_num)
	_challengeTimeLabel = CCRenderLabel:create(_challengeTime,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_challengeTimeLabel:setColor(ccc3(0x00,0xff,0x18))
	_challengeTimeLabel:setAnchorPoint(ccp(0,0.5))
	--购买挑战次数按钮
	addTimeMenu = CCMenu:create()
	addTimeMenu:setAnchorPoint(ccp(0,0))
	addTimeMenu:setPosition(ccp(0,0))
	addTimeMenu:setTouchPriority(_touch_priority-1)
	local addItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
	addItem:registerScriptTapHandler(buyTime)
	addItem:setAnchorPoint(ccp(0,0.5))
	addTimeMenu:addChild(addItem)
	--挑战次数底板
	local fullRect = CCRectMake(0,0,112,29)
	local insetRect = CCRectMake(50,10,10,8)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/gray_bg.png",fullRect, insetRect)
	grayBg:setVisible(getShowStatus())
	grayBg:setPreferredSize(CCSizeMake(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width+addItem:getContentSize().width,addItem:getContentSize().height))
	grayBg:setAnchorPoint(ccp(0,0))
	grayBg:setPosition(ccp(0,0))
	grayBg:addChild(challengeLabel)
	grayBg:addChild(_challengeTimeLabel,1)
	grayBg:addChild(addTimeMenu)
	grayBg:setScale(g_fBgScaleRatio)
	_mainLayer:addChild(grayBg,1,119)

	challengeLabel:setPosition(ccp(0,grayBg:getContentSize().height*0.5))
	_challengeTimeLabel:setPosition(ccp(challengeLabel:getContentSize().width,grayBg:getContentSize().height*0.5))
	addItem:setPosition(ccp(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width,grayBg:getContentSize().height*0.5))
	--闯关积分
	local passLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_120"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	passLabel:setColor(ccc3(0xff,0xff,0xff))
	passLabel:setAnchorPoint(ccp(0,0.5))
	_passPointLabel = CCRenderLabel:create(_copyInfo.curr_point,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_passPointLabel:setColor(ccc3(0x00,0xff,0x18))
	_passPointLabel:setAnchorPoint(ccp(0,0.5))
	--闯关积分底板
	local fullRect = CCRectMake(0,0,112,29)
	local insetRect = CCRectMake(50,10,10,8)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/gray_bg.png",fullRect, insetRect)
	grayBg:setVisible(getShowStatus())
	grayBg:setPreferredSize(CCSizeMake(passLabel:getContentSize().width+_passPointLabel:getContentSize().width,passLabel:getContentSize().height))
	grayBg:setAnchorPoint(ccp(0,0))
	grayBg:setPosition(ccp(0,addItem:getContentSize().height*g_fBgScaleRatio))
	grayBg:setScale(g_fBgScaleRatio)
	_mainLayer:addChild(grayBg,1,120)--_grayBgTag1001
	grayBg:addChild(passLabel)
	grayBg:addChild(_passPointLabel,1,1)
	passLabel:setPosition(ccp(0,grayBg:getContentSize().height*0.5))
	_passPointLabel:setPosition(ccp(passLabel:getContentSize().width,grayBg:getContentSize().height*0.5))

	--查看积分按钮
	lookScoreMenu = CCMenu:create()
	lookScoreMenu:setAnchorPoint(ccp(0,0))
	lookScoreMenu:setPosition(ccp(0,0))
	lookScoreMenu:setTouchPriority(_touch_priority-1)
	local lookItem = CCMenuItemImage:create("images/olympic/checkbutton/check_btn_h.png","images/olympic/checkbutton/check_btn_n.png")
	lookItem:registerScriptTapHandler(scoreAction)
	lookItem:setAnchorPoint(ccp(0,0.5))
	lookScoreMenu:addChild(lookItem)
	grayBg:addChild(lookScoreMenu)
	lookItem:setPosition(ccp(passLabel:getContentSize().width+_passPointLabel:getContentSize().width,grayBg:getContentSize().height*0.5))
	--下边Menu
	local clickMenu = CCMenu:create()
	clickMenu:setTouchPriority(_touch_priority-100)
	clickMenu:setAnchorPoint(ccp(0,0))
	clickMenu:setPosition(ccp(0,0))
	_mainLayer:addChild(clickMenu,1)

	--商店Item
	_weaponShopItem = CCMenuItemImage:create("images/purgatory/devilshop1.png", "images/purgatory/devilshop2.png")
	clickMenu:addChild(_weaponShopItem,1,2)
	_weaponShopItem:setAnchorPoint(ccp(1,0))
	_weaponShopItem:setPosition(ccp(_mainLayer:getContentSize().width,0))
	_weaponShopItem:registerScriptTapHandler(shopAction)
	_weaponShopItem:setScale(g_fBgScaleRatio)
end
-----------------------------------------------上中下布局相关创建END-----------------------------------

-----------------------------------------------上中下布局刷新创建BEGIN-----------------------------------
--动画刷洗
function freshAnimation( pShow )
	-- body
	upSprite:setVisible(pShow)
	downSprite:setVisible(pShow)
end

--刷新上方 删除重建
function refreshTop()
	_mainLayer:getChildByTag(_topSpriteBgTag):removeFromParentAndCleanup(true)
	createTop()
end

--刷新中间 删除重建
function refreshMiddle( ... )
	if(_mainLayer:getChildByTag(_mainBgTag)~=nil and _mainLayer:getChildByTag(_mainBgTag):getChildByTag(_bodyMenuAndItemTag)~=nil)then
		_mainLayer:getChildByTag(_mainBgTag):removeChildByTag(_bodyMenuAndItemTag,true)
	end
	if(_mainLayer:getChildByTag(_bodyMenuAndItemTag)~=nil)then
		_mainLayer:removeChildByTag(_bodyMenuAndItemTag,true)
	end
	if(_mainLayer:getChildByTag(_tongGuanTeXiao)~=nil)then
		_mainLayer:removeChildByTag(_tongGuanTeXiao,true)
	end
	createMiddle()
end

--刷新底边
function refreshBottom( ... )
	_copyInfo = PurgatoryData.getCopyInfo()
	_buyNum = PurgatoryData.getBuyTimes()

	-- 刷新挑战次数
	_mainLayer:getChildByTag(119):setVisible(getShowStatus())
	_mainLayer:getChildByTag(120):setVisible(getShowStatus())

	_mainLayer:removeChildByTag(119,true)
	_mainLayer:removeChildByTag(120,true)
	createBottom()

	_mainLayer:getChildByTag(119):setVisible(getShowStatus())
	_mainLayer:getChildByTag(120):setVisible(getShowStatus())
end

-----------------------------------------------上中下布局刷新创建END-----------------------------------
function createLayer()
	init()

	--创建layer
	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setPosition(ccp(0, 0))
	_mainLayer:setAnchorPoint(ccp(0, 0))
	getCopyInfoFunc()
	return _mainLayer
end

function showLayer()
	-- body
	sendCommond()
end

-----------------------------------------------各种回调BEGIN-----------------------------------
--查看积分
function scoreAction( ... )
	if(_canClick==true)then
		PurgatoryScoreLayer.showLayer()
	end
end

--购买次数
function buyTime( tag,itembtn )
	if(_canClick==true)then
	 	local goldCostData = DB_Lianyutiaozhan_rule.getDataById(1)
	    local tab = string.split(goldCostData.challengeBuy,",")
	    local p_data = string.split(tab[table.count(tab)],"|")
	    local leftNum = tonumber(p_data[1])-_copyInfo.buy_atk_num
	    _atkcost = 0

		if(leftNum>0)then
			local node =  CCNode:create()
		    local totlePirceLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1120"),g_sFontName,25)
		    totlePirceLabel:setColor(ccc3(0x78,0x25,0x00))
		    node:addChild(totlePirceLabel)
		    local sprite = CCSprite:create("images/common/gold.png")
		    node:addChild(sprite)
		    sprite:setPosition(ccp(totlePirceLabel:getContentSize().width,0))

		    for k,v in pairs(tab) do
		        local t_data = string.split(v,"|")
		        if(tonumber(_copyInfo.buy_atk_num)+1 <= tonumber(t_data[1]))then
		            _atkcost = tonumber(t_data[2])
		            break
		        end
		    end
		    _priceNumLabel = CCLabelTTF:create(_atkcost..GetLocalizeStringBy("llp_191"),g_sFontName,25)
		    _priceNumLabel:setColor(ccc3(0x78,0x25,0x00))
		    _priceNumLabel:setPosition(ccp(totlePirceLabel:getContentSize().width+sprite:getContentSize().width,0))
		    node:addChild(_priceNumLabel)
		    node:setContentSize(CCSizeMake(totlePirceLabel:getContentSize().width+sprite:getContentSize().width+_priceNumLabel:getContentSize().width,totlePirceLabel:getContentSize().height))
		    require "script/ui/tip/TipByNode"
			TipByNode.showLayer(node,buyAtkAction)
		else
			AnimationTip.showTip(GetLocalizeStringBy("llp_192"))
		end
	end
end

--发送完购买次数回调
function buyCallBack( ... )
	-- body
	UserModel.addGoldNumber(-_atkcost)
	AnimationTip.showTip(GetLocalizeStringBy("key_2824"))
	PurgatoryData.addBuyTimes(1)
	refreshBottom()
end

--奖励预览
function rewardAction( ... )
	-- body
	if(_canClick==true)then
		PurgatoryRewardPreviewLayer.show()
	end
end

--购买挑战次数确定回调
function buyAtkAction( ... )
	-- body
	if(_atkcost>UserModel.getGoldNumber())then
        LackGoldTip.showTip()
        return
    end
    PurgatoryServes.buyTimeCommond(buyCallBack)
end

--选择数量改变相应金币数
function changeCallBack( ... )
	-- body
	local goldCostData = DB_Lianyutiaozhan_rule.getDataById(1)
    local tab = string.split(goldCostData.challengeBuy,",")
    _atkcost = 0
    for i=1,_dialog._selectNum do
    	for k,v in pairs(tab)do
    		local t_data = string.split(v,"|")
    		local dataNum1 = tonumber(t_data[1])
    		local dataNum2 = tonumber(t_data[2])

    		if(dataNum1>=i)then
    			_atkcost = _atkcost + dataNum2
    			break
    		end
    	end
    end
	_priceNumLabel:setString(_atkcost)
end

-- 返回
function backAction(tag, itembtn)
	if(_canClick==true)then
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		local curScene = CCDirector:sharedDirector():getRunningScene()
		local passLayer = curScene:getChildByTag(_tongGuanTeXiao)
		if(passLayer~=nil)then
			_mainLayer:removeChildByTag(_tongGuanTeXiao,true)
			passLayer = nil
		end
		require "script/ui/active/ActiveList"
		local activeListr = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeListr, "activeListr")
	end
end
--排行按钮回调
function rankListAction( )
	if(_canClick==true and not _isRewardTime)then
		btimport "script/ui/purgatorychallenge/PurgatoryRankLayer"
		PurgatoryRankLayer.show();
	end
end
--积分商店按钮回调
function shopAction()
	if(_canClick==true)then
		_mainLayer:removeChildByTag(_tongGuanTeXiao,true)
	    -- require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopLayer"
	    -- PurgatoryShopLayer.show()
	    require "script/ui/shopall/purgatoryshop/PurgatoryShopLayer"
	    PurgatoryShopLayer.show(_touch_priority-200)
	end
end

function resetAction( pInfo )
	-- body
	PurgatoryData.reset(pInfo)
	-- local curScene = CCDirector:sharedDirector():getRunningScene()
	_mainLayer:removeChildByTag(_tongGuanTeXiao,true)
	setClick(true)
	refreshFunc()
end
--中间英雄item点击回调
function bodyClickAction( tag,itembtn )
	-- body
	if(_canClick==true)then
	-- 	setClick(false)
		if(getShowStatus()==true)then
			local challengeTime = tonumber(_copyInfo.atk_num)
			if(_challengeTime==0)then
				AnimationTip.showTip(GetLocalizeStringBy("llp_187"))
				setClick(true)
				return
			end
			if(not PurgatoryData.isHavePass())then
				setClick(false)
				PurgatoryAddHeroLayer.showLayer()
			else
				PurgatoryServes.resetCopy(resetAction)
			end
		else
		-- 	_showAll=true
		-- 	refreshFunc()
		end
	end
end

function setClick( p_Click )
	-- body
	_canClick = p_Click
end
-----------------------------------------------各种回调END-----------------------------------
































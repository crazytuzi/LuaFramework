-- FileName: DevilTowerFightResultLayer.lua
-- Author: lgx
-- Date: 2016-08-04
-- Purpose: 试炼梦魇战斗结算面板

module("DevilTowerFightResultLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/deviltower/DevilTowerData"
require "db/DB_Stronghold"
require "script/utils/LuaUtil"
require "db/DB_Level_up_exp"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"

-- UI控件引用变量 --
local IMG_PATH 				= "images/battle/report/" -- 图片主路径
local animationTime 		= 1.3 -- 动画执行时间

-- 模块局部变量 --
local _touchPriority		= nil -- 触摸优先级
local _zOrder				= nil -- 显示层级
local _bgLayer				= nil -- 背景层
local _animSprite 			= nil -- 胜负动画1
local _backAnimSprite 		= nil -- 胜负动画2
local _backAnimSprite2 		= nil -- 胜负动画3

local _isWin				= nil -- 战斗胜负
local _clickOKCallback 		= nil -- 确认按钮回调

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 		= nil
	_zOrder				= nil
	_bgLayer			= nil
	_animSprite 		= nil
	_backAnimSprite 	= nil
	_backAnimSprite2	= nil
	_isWin				= nil
	_clickOKCallback	= nil
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
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
		PreRequest.setIsCanShowAchieveTip(false)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
		PreRequest.setIsCanShowAchieveTip(true)
	end
end

--[[
	@desc 	: 创建界面方法
	@param 	: pAppraisal 战斗评价
	@param  : pArmyId 塔层据点id
	@param 	: pRewardData 奖励信息
	@param 	: pCallback 确认按钮回调
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pAppraisal, pArmyId, pRewardData, pCallback, pTouchPriority, pZorder )
	init()

	_clickOKCallback = pCallback
	_touchPriority = pTouchPriority or -700
	_zOrder = pZorder or 500

	local towerNumber = pRewardData.tower_num==nil and 0 or tonumber(pRewardData.tower_num)

	require "script/battle/BattleLayer"
    BattleLayer.endShake()

    require "script/audio/AudioUtil"
    AudioUtil.stopBgm()

    local winSize = CCDirector:sharedDirector():getWinSize()
    _bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 判断战斗胜负
    if( pAppraisal ~= "E" and pAppraisal ~= "F" )then
        _isWin = true
    else
        _isWin = false        
    end

	-- 创建背景框
    local bgSpriteSize = _isWin and CCSizeMake(520,346) or CCSizeMake(520,668)
    local bgSprite = BaseUI.createViewBg(bgSpriteSize)
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
    _bgLayer:addChild(bgSprite)

    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    bgSprite:addChild(menu)
    menu:setTouchPriority(_touchPriority-20)

    local shDB = DB_Stronghold.getDataById(pArmyId)
    -- 塔层名称
    local nameRate = _isWin and 0.8 or 0.9
	local shName = CCRenderLabel:create(shDB.name, g_sFontPangWa, 30, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    shName:setColor(ccc3( 0xff, 0xe4, 0x00))
    shName:setAnchorPoint(ccp(0.5,0.5))
    shName:setPosition(bgSpriteSize.width*0.5,bgSpriteSize.height*nameRate)
    bgSprite:addChild(shName)

    -- 播放胜负动画
    if (_isWin) then
    	-- 胜利界面
        -- 获得试炼币
        local towerBg = CCScale9Sprite:create(CCRectMake(84, 10, 12, 8),"images/common/purple.png")
        towerBg:setContentSize(CCSizeMake(380,50))
        towerBg:setAnchorPoint(ccp(0.5,0.5))
        towerBg:setPosition(bgSpriteSize.width*0.5,bgSpriteSize.height*0.535)
        bgSprite:addChild(towerBg)

        local towerDesc = CCLabelTTF:create(GetLocalizeStringBy("lgx_1100"),g_sFontPangWa,25)
        towerDesc:setAnchorPoint(ccp(0,0.5))
        towerDesc:setPosition(ccp(towerBg:getContentSize().width*0.2,towerBg:getContentSize().height*0.5))
        towerDesc:setColor(ccc3(0xff,0xff,0xff))
        towerBg:addChild(towerDesc)

		local towerIcon = CCSprite:create("images/common/tower_num_small.png")
		towerIcon:setAnchorPoint(ccp(1,0.5))
		towerIcon:setPosition(ccp(towerBg:getContentSize().width*0.68,towerBg:getContentSize().height*0.5))
		towerBg:addChild(towerIcon)

        local towerLabel = CCLabelTTF:create("" .. towerNumber,g_sFontPangWa,25)
        towerLabel:setAnchorPoint(ccp(0,0.5))
        towerLabel:setPosition(towerBg:getContentSize().width*0.7,towerBg:getContentSize().height*0.5)
        towerLabel:setColor(ccc3(0xff,0xf6,0x00))
        towerBg:addChild(towerLabel)

        local itemRate = _isWin and 0.2 or 0.25
        local oKMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_1061"),ccc3(255,222,0))
        oKMenuItem:setAnchorPoint(ccp(0.5,0.5))
        if(Platform.getOS() == "wp")then
            oKMenuItem:setPosition(ccp(bgSpriteSize.width*0.5,bgSpriteSize.height*itemRate))
        else
            oKMenuItem:setPosition(ccp(bgSpriteSize.width*0.7,bgSpriteSize.height*itemRate))
        end
        oKMenuItem:registerScriptTapHandler(oKItemCallback)
        oKMenuItem:setCascadeColorEnabled(true)
        menu:addChild(oKMenuItem)

        local shareMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_2391"),ccc3(255,222,0))
        shareMenuItem:setAnchorPoint(ccp(0.5,0.5))
        shareMenuItem:setPosition(ccp(bgSpriteSize.width*0.3,bgSpriteSize.height*itemRate))
        shareMenuItem:registerScriptTapHandler(shareItemCallback)
        if(Platform.getOS() ~= "wp")then
            menu:addChild(shareMenuItem)
        end

        -- 胜利特效
        _backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));
        _backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
        _backAnimSprite2:setPosition(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height)
        bgSprite:addChild(_backAnimSprite2,-1)
        _backAnimSprite2:setVisible(false)
        local function showBg2()
            _backAnimSprite2:setVisible(true)
        end
        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.1))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        _backAnimSprite2:runAction(CCSequence:create(layerActionArray))

        _backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));
        _backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
        _backAnimSprite:setPosition(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-10)
        bgSprite:addChild(_backAnimSprite,0)

        _animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""))
        bgSprite:registerScriptHandler(function ( eventType, node )
            if(eventType == "enter") then
               if(file_exists("audio/effect/zhandoushengli.mp3")) then
                   AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
               end
            end
            if(eventType == "exit") then
                
            end
        end)
    else
    	-- 失败界面
        -- 确认按钮
        local oKMenuItem = CCMenuItemImage:create("images/battle/btn/btn_commit_n.png","images/battle/btn/btn_commit_h.png")
        oKMenuItem:setAnchorPoint(ccp(0.5,0.5))
        oKMenuItem:setPosition(ccp(bgSpriteSize.width*0.5,bgSpriteSize.height*0.09))
        oKMenuItem:registerScriptTapHandler(oKItemCallback)
       	menu:addChild(oKMenuItem)

        -- 创建中间ui
        local middleBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/bg_ng_attr.png")
        middleBg:setContentSize(CCSizeMake(bgSpriteSize.width-50,450))
        middleBg:setAnchorPoint(ccp(0.5,1))
        middleBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-100))
        bgSprite:addChild(middleBg)

        local str1 = GetLocalizeStringBy("key_3053")
        local text1 = CCRenderLabel:create( str1 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text1:setColor(ccc3(0xff, 0xff, 0xff))
        text1:setPosition(ccp(45,middleBg:getContentSize().height-10))
        middleBg:addChild(text1)

        local str2 = GetLocalizeStringBy("key_1175")
        local text2 = CCRenderLabel:create( str2 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text2:setColor(ccc3(0xff, 0xff, 0xff))
        text2:setPosition(ccp(10,middleBg:getContentSize().height-50))
        middleBg:addChild(text2)

        local str3 = GetLocalizeStringBy("key_2265")
        local text3 = CCRenderLabel:create( str3 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text3:setColor(ccc3(0xff, 0xff, 0xff))
        text3:setPosition(ccp(10,middleBg:getContentSize().height-90))
        middleBg:addChild(text3)

        -- 当前战斗力
        local fightSp = CCSprite:create("images/common/cur_fight.png")
        fightSp:setAnchorPoint(ccp(0.5,0.5))
        fightSp:setPosition(ccp(bgSpriteSize.width*0.4,middleBg:getContentSize().height-150))
        middleBg:addChild(fightSp)

        local  powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
        powerDescLabel:setAnchorPoint(ccp(0,0.5))
        powerDescLabel:setPosition(fightSp:getPositionX()+fightSp:getContentSize().width/2+10,fightSp:getPositionY())
        middleBg:addChild(powerDescLabel)

        -- 按钮菜单
        local middleMenu = CCMenu:create()
        middleMenu:setPosition(ccp(0,0))
        middleMenu:setTouchPriority(_touchPriority-20)
        middleBg:addChild(middleMenu)

        -- 武将强化
        local strengthenHeroItem = CCMenuItemImage:create("images/common/strengthen_hero_n.png","images/common/strengthen_hero_h.png")
        strengthenHeroItem:setAnchorPoint(ccp(0,0.5))
        strengthenHeroItem:setPosition(ccp(18,181))
        middleMenu:addChild(strengthenHeroItem)
        strengthenHeroItem:registerScriptTapHandler(strengthenHeroCallback)

        -- 调整整容
        local formationItem = CCMenuItemImage:create("images/common/change_formation_n.png","images/common/change_formation_h.png")
        formationItem:setAnchorPoint(ccp(0.5,0.5))
        formationItem:setPosition(ccp(middleBg:getContentSize().width/2 ,181))
        middleMenu:addChild(formationItem)
        formationItem:registerScriptTapHandler(formationCallback)

        -- 装备强化
        local strengthenArmItem = CCMenuItemImage:create("images/common/strengthen_arm_n.png","images/common/strengthen_arm_h.png")
        strengthenArmItem:setAnchorPoint(ccp(0.5,0.5))
        strengthenArmItem:setPosition(ccp(387,181))
        middleMenu:addChild(strengthenArmItem)
        strengthenArmItem:registerScriptTapHandler(strengthenArmCallback)

        -- 培养名将
        local trainStarItem = CCMenuItemImage:create("images/common/train_star_n.png","images/common/train_star_h.png")
        trainStarItem:setAnchorPoint(ccp(0.5,0.5))
        trainStarItem:setPosition(ccp(123,58))
        middleMenu:addChild(trainStarItem)
        trainStarItem:registerScriptTapHandler(trainStarCallback)

        -- 升级战魂
        local fightSoulItem = CCMenuItemImage:create("images/common/up_fightsoul_n.png","images/common/up_fightsoul_h.png")
        fightSoulItem:setAnchorPoint(ccp(0.5,0.5))
        fightSoulItem:setPosition(ccp(337,56))
        middleMenu:addChild(fightSoulItem)
        fightSoulItem:registerScriptTapHandler(fightSoulCallback)

        -- 失败特效
    	_backAnimSprite = nil
        _animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
        bgSprite:registerScriptHandler(function ( eventType, node )
            if(eventType == "enter") then
               if(file_exists("audio/effect/zhandoushibai.mp3")) then
                    AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
                end
            end
            if(eventType == "exit") then
                
            end
        end)
    end

    _animSprite:setAnchorPoint(ccp(0.5, 0.5));
    _animSprite:setPosition(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-20)
    bgSprite:addChild(_animSprite)
    
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEndCallback)
    _animSprite:setDelegate(delegate)

    -- 适配
    setAdaptNode(bgSprite)

    return _bgLayer
end

--[[
	@desc	: 特效播放结束后回调
    @param	: 
    @return	: 
—-]]
function animationEndCallback()
    if (_backAnimSprite ~= nil) then
        _backAnimSprite:cleanup()
    end

    if (_animSprite ~= nil) then
        _animSprite:cleanup()
    end
end

--[[
	@desc	: 功能简介
    @param	: 参数说明
    @return	: 是否有返回值，返回值说明  
—-]]
function shareItemCallback()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/utils/BaseUI"
    local shareImagePath = BaseUI.getScreenshots()
    require "script/ui/share/ShareLayer"
    ShareLayer.show(nil, shareImagePath,9999, -1000, nil)
end

--[[
	@desc	: 点击确认按钮回调
    @param	: 
    @return	: 
—-]]
function oKItemCallback()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    if (_animSprite ~= nil) then
        _animSprite:removeFromParentAndCleanup(true)
        _animSprite = nil
    end

    if (_backAnimSprite ~= nil) then
        _backAnimSprite:removeFromParentAndCleanup(true)
        _backAnimSprite = nil
    end

    if (_backAnimSprite2 ~= nil) then
        _backAnimSprite2:removeFromParentAndCleanup(true)
        _backAnimSprite2 = nil
    end

    if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    -- 调用回调
    if (_clickOKCallback ~= nil) then
        _clickOKCallback()
    end
end

--[[
	@desc	: 点击武将强化按钮回调
    @param	: 
    @return	: 
—-]]
function strengthenHeroCallback()
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2409"))
    -- 先关闭战斗场景
    oKItemCallback()

    if not DataCache.getSwitchNodeState(ksSwitchGeneralForge) then
        return
    end
    require "script/ui/hero/HeroLayer"
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

--[[
	@desc	: 点击调整整容按钮回调
    @param	: 
    @return	: 
—-]]
function formationCallback()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    oKItemCallback()

    require("script/ui/formation/FormationLayer")
    local formationLayer = FormationLayer.createLayer()
    MainScene.changeLayer(formationLayer, "formationLayer")
end

--[[
	@desc	: 点击装备强化按钮回调
    @param	: 
    @return	: 
—-]]
function strengthenArmCallback()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_1244"))
    -- 先关闭战斗场景
    oKItemCallback()

    if not DataCache.getSwitchNodeState(ksSwitchWeaponForge) then
        return
    end
    require "script/ui/bag/BagLayer"
    local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
    MainScene.changeLayer(bagLayer, "bagLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

--[[
	@desc	: 点击培养名将按钮回调
    @param	: 
    @return	: 
—-]]
function trainStarCallback()
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2827"))
    -- 先关闭战斗场景
    oKItemCallback()

    if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
        return
    end
    require "script/ui/star/StarLayer"
    local starLayer = StarLayer.createLayer()
    MainScene.changeLayer(starLayer, "starLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

--[[
	@desc	: 点击升级战魂按钮回调
    @param	: 
    @return	: 
—-]]
function fightSoulCallback()
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    oKItemCallback()

    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
end


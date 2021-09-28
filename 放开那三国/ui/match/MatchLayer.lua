-- FileName: MatchLayer.lua 
-- Author: Li Cong 
-- Date: 13-11-7 
-- Purpose: function description of module 

require "script/model/user/UserModel"
require "script/ui/match/MatchService"
require "script/ui/match/MatchData"
require "script/utils/LuaUtil"
module("MatchLayer", package.seeall)

m_titleHeight 				= nil				-- 上部分高度
_silverLabel 				= nil		  		-- 银币
_goldLabel					= nil				-- 金币
local _bgLayer 				= nil               -- 比武layer
local _layerSize 			= nil            	-- 比武layer的ContentSize
local _powerDescLabel 		= nil       		-- 战斗力
local matchBtn 				= nil				-- 比武按钮
local enemyBtn 				= nil				-- 仇人按钮
local _curButton 			= nil				-- 当前按钮
local _btnFrameSp 			= nil 				-- 按钮背景
local _curDisplayLayer 		= nil				-- 当前展示Layer
local topBg  				= nil				-- 战斗力，银币，金币背景
refreshMatchGold 			= nil				-- 刷新金币函数

local _exchangeBtn 			= nil 				-- 兑换按钮

-- 初始化变量
function init()
	m_titleHeight 			= nil				-- 上部分高度
	_bgLayer 				= nil               -- 比武layer
	_layerSize 				= nil            	-- 比武layer的ContentSize
	_powerDescLabel 		= nil       		-- 战斗力
	_silverLabel 			= nil		  		-- 银币
	_goldLabel				= nil				-- 金币
	matchBtn 				= nil				-- 比武按钮
	enemyBtn 				= nil				-- 仇人按钮
	_curButton 				= nil				-- 当前按钮
	_btnFrameSp 			= nil 				-- 按钮背景
	_curDisplayLayer 		= nil				-- 当前展示Layer
	topBg  					= nil				-- 战斗力，银币，金币背景
	_exchangeBtn 			= nil 				-- 兑换按钮
end


-- 标签按钮
function matchRobAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	itemBtn:selected()
	if (_curButton ~= itemBtn) then
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		if(_curDisplayLayer) then
			_curDisplayLayer:removeFromParentAndCleanup(true)
			_curDisplayLayer=nil
		end
		local curDisplayLayerHight = _layerSize.height- topBg:getContentSize().height * g_fScaleX - btnFrameSp:getContentSize().height * g_fScaleX
		-- 比武
		if(_curButton == matchBtn) then
			-- 如果是休息时间 显示休息界面
			if( MatchData.getIsRest() )then
				require "script/ui/match/RestTimeLayer"
				_curDisplayLayer = RestTimeLayer.createRestTimeLayer(CCSizeMake(_layerSize.width, curDisplayLayerHight))
			else
			-- 不是休息时间 显示比武界面
				require "script/ui/match/MatchPlace"
				_curDisplayLayer = MatchPlace.createMatchPlaceLayer(CCSizeMake(_layerSize.width, curDisplayLayerHight))
			end
		elseif(_curButton == enemyBtn) then
		-- 复仇
			require "script/ui/match/MatchEnemy"
			_curDisplayLayer = MatchEnemy.createMatchEnemyLayer(CCSizeMake(_layerSize.width, curDisplayLayerHight))
		elseif(_curButton == _exchangeBtn) then
		-- 兑换
		-- new shop enter
			require "script/ui/shopall/honor/HonorShopLayer"
			_curDisplayLayer = HonorShop.createHonorShopLayer( CCSizeMake(_layerSize.width/g_fScaleX, curDisplayLayerHight/g_fScaleX), false )
		end
		_curDisplayLayer:setScale(1/MainScene.elementScale)
		_bgLayer:addChild(_curDisplayLayer)
	end
end

-- 初始化比武层
function initMatchLayer( ... )
	-- 比武层layer大小
	_layerSize = _bgLayer:getContentSize()
	-- 上标题栏 显示战斗力，银币，金币
	topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
	topBg:setAnchorPoint(ccp(0,1))
	topBg:setPosition(ccp(0, _bgLayer:getContentSize().height))
	topBg:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(topBg,10)
	
	-- 战斗力
	local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)
    _powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerDescLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
    topBg:addChild(_powerDescLabel)

	-- 银币
	-- modified by yangrui at 2015-12-03
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setAnchorPoint(ccp(0, 0))
	_silverLabel:setPosition(ccp(390, 10))
	topBg:addChild(_silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0))
	_goldLabel:setPosition(ccp(522, 10))
	topBg:addChild(_goldLabel)

	--按钮背景
    local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height-topBg:getContentSize().height * g_fScaleX))
	btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(btnFrameSp,10)

	local matchMenuBar = CCMenu:create()
	matchMenuBar:setPosition(ccp(0, 0))
	btnFrameSp:addChild(matchMenuBar)
	matchBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_2182"))
	matchBtn:setAnchorPoint(ccp(0, 0))
	matchBtn:setPosition(ccp(10, btnFrameSp:getContentSize().height*0.1))
	matchBtn:registerScriptTapHandler(matchRobAction)
	matchMenuBar:addChild(matchBtn, 2, 10001)

	-- 仇人
	enemyBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1999"))
	enemyBtn:setAnchorPoint(ccp(0, 0))
	enemyBtn:setPosition(ccp(matchBtn:getPositionX()+matchBtn:getContentSize().width, btnFrameSp:getContentSize().height*0.1))
	enemyBtn:registerScriptTapHandler(matchRobAction)
	matchMenuBar:addChild(enemyBtn, 2, 10002)

	-- 兑换按钮
	_exchangeBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("lic_1071"))
	_exchangeBtn:setAnchorPoint(ccp(0, 0))
	_exchangeBtn:setPosition(ccp(enemyBtn:getPositionX()+enemyBtn:getContentSize().width, btnFrameSp:getContentSize().height*0.1))
	_exchangeBtn:registerScriptTapHandler(matchRobAction)
	matchMenuBar:addChild(_exchangeBtn, 2, 10003)

	-- 创建关闭按钮
	local menuCloseBar = CCMenu:create()
	menuCloseBar:setPosition(ccp(0,0))
	menuCloseBar:setTouchPriority(-150)
	btnFrameSp:addChild(menuCloseBar)
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(fnCloseArenaLayerAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(btnFrameSp:getContentSize().width-20,btnFrameSp:getContentSize().height*0.5+6))
	menuCloseBar:addChild(closeMenuItem)

	-- 当前状态
	_curButton = matchBtn
	_curButton:selected()
	local curDisplayLayerHight = _layerSize.height- topBg:getContentSize().height * g_fScaleX - btnFrameSp:getContentSize().height * g_fScaleX
	-- 如果是休息时间 显示休息界面
	if( MatchData.getIsRest() )then
		require "script/ui/match/RestTimeLayer"
		_curDisplayLayer = RestTimeLayer.createRestTimeLayer(CCSizeMake(_layerSize.width, curDisplayLayerHight))
	else
	-- 不是休息时间 显示比武界面
		require "script/ui/match/MatchPlace"
		_curDisplayLayer = MatchPlace.createMatchPlaceLayer(CCSizeMake(_layerSize.width, curDisplayLayerHight))
	end
	_curDisplayLayer:setScale(1/MainScene.elementScale)
	_bgLayer:addChild(_curDisplayLayer)
end

-- 关闭按钮action
function fnCloseArenaLayerAction( ... )
	init()
	require "script/ui/active/ActiveList"
	local  activeList = ActiveList.createActiveListLayer()
	MainScene.changeLayer(activeList, "activeList")
end



-- 创建比武层
function createMatchLayer( ... )
	init()
	_bgLayer = MainScene.createBaseLayer("images/match/match_bg.jpg", true, false,true)
	
	_bgLayer:registerScriptHandler(function ( eventType,node )
   		if(eventType == "enter") then
   			require "script/ui/shop/RechargeLayer"
			RechargeLayer.registerChargeGoldCb(refreshMatchGold)
   		end
		if(eventType == "exit") then
			init()
			require "script/ui/shop/RechargeLayer"
			RechargeLayer.registerChargeGoldCb(nil)
		end
	end)
	local function createNextFun( ... )
		-- 初始化
   		initMatchLayer()
   		-- 新手引导
		addGuideMatchGuide3()
   	end
	MatchService.getCompeteInfo(createNextFun)
				
	return _bgLayer
end



-- 根据发奖状态 刷新ui
function updateUIforRewardState( state )
	-- 发奖状态
	MatchData.m_rewardState = state
	if(state == "start")then
		if(_bgLayer ~= nil )then
			if(_curButton == matchBtn)then
				local function createNextFun( ... )
					if(_curDisplayLayer) then
						_curDisplayLayer:removeFromParentAndCleanup(true)
						_curDisplayLayer=nil
					end
					require "script/ui/match/RestTimeLayer"
					print("1233")
					print_t(MatchData.m_allData)
					local curDisplayLayerHight = _layerSize.height- topBg:getContentSize().height * g_fScaleX - btnFrameSp:getContentSize().height * g_fScaleX
					_curDisplayLayer = RestTimeLayer.createRestTimeLayer(CCSizeMake(_layerSize.width, curDisplayLayerHight))
					_curDisplayLayer:setScale(1/MainScene.elementScale)
					_bgLayer:addChild(_curDisplayLayer)
			   	end
				MatchService.getCompeteInfo(createNextFun)
			else
				local function createNextFun( ... )
					print("更新比武数据。。。")
				end
				MatchService.getCompeteInfo(createNextFun)
			end
		end
	end
	if(state == "end")then
		require "script/ui/match/RestTimeLayer"
		if(RestTimeLayer._bgLayer ~= nil)then
			if(	RestTimeLayer._bgLayer:getChildByTag(10001) ~= nil )then
				RestTimeLayer._bgLayer:removeChildByTag(10001,true)
			end
			if(	RestTimeLayer._bgLayer:getChildByTag(10002) ~= nil )then
				RestTimeLayer._bgLayer:removeChildByTag(10002,true)
			end
			local str = GetLocalizeStringBy("key_1449")
		    local below_font = CCRenderLabel:create( str, g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
		    below_font:setAnchorPoint(ccp(0.5,0))
		    below_font:setColor(ccc3(0xff,0xe4,0x00))
		    below_font:setPosition(ccp(RestTimeLayer._bgLayer:getContentSize().width*0.5,58*g_fScaleX))
		    RestTimeLayer._bgLayer:addChild(below_font,1,10001)
		    below_font:setScale(MainScene.elementScale)
	        local str2 = GetLocalizeStringBy("key_2891")
	        local below_font2 = CCRenderLabel:create( str2, g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
	        below_font2:setAnchorPoint(ccp(0.5,0))
	        below_font2:setColor(ccc3(0xff,0xe4,0x00))
	        below_font2:setPosition(ccp(RestTimeLayer._bgLayer:getContentSize().width*0.5,18*g_fScaleX))
	        RestTimeLayer._bgLayer:addChild(below_font2,1,10002)
	        below_font2:setScale(MainScene.elementScale)
	    end
	end
end



---[==[比武 第3步
---------------------新手引导---------------------------------
function addGuideMatchGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/MatchGuide"
    if(NewGuide.guideClass ==  ksGuideContest and MatchGuide.stepNum == 2) then
        MatchGuide.show(3, nil)
    end
end
---------------------end-------------------------------------
--]==]


-- 刷新界面金币
refreshMatchGold = function ( ... )
	if(_goldLabel)then
		_goldLabel:setString( UserModel.getGoldNumber() )
	end
end

-- FileName: ArenaLayer.lua 
-- Author: Li Cong 
-- Date: 13-8-12 
-- Purpose: function description of module 

module("ArenaLayer", package.seeall)

require "script/model/user/UserModel"
require "script/ui/arena/ArenaData"
require "script/ui/arena/ArenaService"
require "script/utils/BaseUI"
require "script/model/DataCache"
require "script/utils/TimeUtil"
require "script/ui/arena/ArenaChallenge"
require "script/ui/arena/ArenaRankings"

-- 全局变量
layerSize = nil                                        			-- 竞技表层大小
menuBg = nil    												-- 按钮背景
m_powerLabel = nil            									-- 战斗力数值
m_silverLabel = nil												-- 银币值
m_goldLabel	= nil												-- 金币值
_staminaLabel = nil												-- 耐力

-- local 全局变量
local m_arena = nil                      				 		-- 竞技层
local tabLayer = nil											-- 竞技，排行tabLayer
local menuCloseBar = nil                          				-- 关闭返回按钮

--[[
	@des 	: inite
	@param 	: 
	@return : 
--]]
function init( ... )
	-- 全局变量
	layerSize = nil                                        			-- 竞技表层大小
	menuBg = nil    												-- 按钮背景
	m_powerLabel = nil            									-- 战斗力数值
	m_silverLabel = nil												-- 银币值
	m_goldLabel	= nil												-- 金币值
	_staminaLabel = nil												-- 耐力

	m_arena = nil                      				 		-- 竞技层
	tabLayer = nil											-- 竞技，排行tabLayer
	menuCloseBar = nil                          				-- 关闭返回按钮
end

-- 关闭返回处理函数
function closeArenaLayerAction( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- 取消竞技层 所有定时器
	for k,v in pairs(ArenaData.arenaScheduleId) do
		if(v ~= nil)then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
		end
		ArenaData.arenaScheduleId[k] = nil
		-- print(GetLocalizeStringBy("key_2408") .. k )
	end
	-- 取消排行层定时器
	if( ArenaData.rankScheduleId ~= nil )then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.rankScheduleId)
		ArenaData.rankScheduleId = nil
		-- print("释放rankScheduleId")
	end
	-- 取消数据定时器
	if( ArenaData.scheduleId_data ~= nil )then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.scheduleId_data)
		ArenaData.scheduleId_data = nil
	end
	-- ArenaLayer 全局变量置nil
	menuBg = nil    												-- 按钮背景
	m_powerLabel = nil            									-- 战斗力数值
	m_silverLabel = nil												-- 银币值
	m_goldLabel	= nil												-- 金币值
	_staminaLabel = nil												-- 耐力
	-- ArenaChallenge 全局变量
	ArenaChallenge.todaySurplusNum = nil							-- 今日剩余次数
	ArenaChallenge.curRanking = nil  								-- 当前名次
	ArenaChallenge.challengeTableView = nil							-- 竞技列表
	-- ArenaData 全局变量
	ArenaData.allUserData = nil 									-- 竞技场所有玩家表
	ArenaData.luckyListData = nil                     				-- 幸运排名数据
	ArenaData.rewardData = nil										-- 领取奖励数据
	ArenaData.rankListData = nil                      				-- 排行榜前十数据
	ArenaData.challengeData = nil                     				-- 挑战后返回数据
	ArenaData.arenaScheduleId = {}									-- 定时器表
	ArenaData.arenaInfo = nil                         				-- 竞技场数据
	-- 释放竞技场资源
	if (m_arena) then
		m_arena:removeFromParentAndCleanup(true)
		m_arena = nil
	end
	menuCloseBar:removeFromParentAndCleanup(true)
	menuCloseBar = nil
	require "script/ui/active/ActiveList"
	local  activeList = ActiveList.createActiveListLayer()
	MainScene.changeLayer(activeList, "activeList")
end


-- 返回按钮
local function addCloseFortsLayoutMenu( ... )
	menuCloseBar = CCMenu:create()
	menuCloseBar:setTouchPriority(-150)
	menuCloseBar:setPosition(ccp(0,0))
	menuBg:addChild(menuCloseBar)
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(closeArenaLayerAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(menuBg:getContentSize().width-20,menuBg:getContentSize().height*0.5+6))
	menuCloseBar:addChild(closeMenuItem)
end


-- 初始化竞技场
function initArenaLayer( ... )
	-- 竞技层layer大小
	layerSize = m_arena:getContentSize()
	-- 上标题栏 显示战斗力，银币，金币
	local topBg = CCSprite:create("images/star/intimate/top.png")
	topBg:setAnchorPoint(ccp(0,1))
	topBg:setPosition(ccp(0, m_arena:getContentSize().height))
	topBg:setScale(g_fScaleX/MainScene.elementScale)
	m_arena:addChild(topBg)
	titleSize = topBg:getContentSize()
	
	-- 战斗力
    powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    powerDescLabel:setPosition(108, 34)
    topBg:addChild(powerDescLabel)

    -- 耐力
    _staminaLabel = CCLabelTTF:create(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(), g_sFontName, 20)
	_staminaLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_staminaLabel:setAnchorPoint(ccp(0, 0))
	_staminaLabel:setPosition(ccp(278, 10))
	topBg:addChild(_staminaLabel)
	-- 注册耐力更新函数
	require "script/ui/main/MainScene"
	MainScene.registerStaminaNumberChangeCallback( upDateStamina )

	-- 银币
	m_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)  -- modified by yangrui at 2015-12-03
	m_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	m_silverLabel:setAnchorPoint(ccp(0, 0))
	m_silverLabel:setPosition(ccp(402, 10))
	topBg:addChild(m_silverLabel)

	-- 金币
	m_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	m_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	m_goldLabel:setAnchorPoint(ccp(0, 0))
	m_goldLabel:setPosition(ccp(522, 10))
	topBg:addChild(m_goldLabel)

    -- 创建按钮背景
    local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	menuBg = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	menuBg:setPreferredSize(CCSizeMake(layerSize.width/MainScene.elementScale, 90))
	menuBg:setAnchorPoint(ccp(0.5,1))
	menuBg:setPosition(ccp(layerSize.width*0.5,layerSize.height - topBg:getContentSize().height*g_fScaleX ))
	m_arena:addChild(menuBg,0)

	--  创建竞技和排行按钮
	local fontSizeN = 36
	local fontSizeH = 30
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		fontSizeN = 27
		fontSizeH = 24
	end
	tabLayer = BaseUI.createTopTabLayer( { GetLocalizeStringBy("key_2203"), GetLocalizeStringBy("key_2354"), GetLocalizeStringBy("key_1583") },
	  	fontSizeN,fontSizeH,
	  	g_sFontPangWa,
	  	ccc3(0xff, 0xe4, 0x00),ccc3(0x48, 0x85, 0xb5) 
	)
	tabLayer:setPosition(ccp(0,0))
    tabLayer:setScale(1/MainScene.elementScale)
    m_arena:addChild(tabLayer,2)
    --  设置竞技和排行按钮位置
    tabLayer:buttonOfIndex(0):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(0):setPosition(ccp(25,menuBg:getPositionY()-menuBg:getContentSize().height*MainScene.elementScale + 10*MainScene.elementScale))
    tabLayer:buttonOfIndex(0):setScale(MainScene.elementScale)

	local x = tabLayer:buttonOfIndex(0):getPositionX()+tabLayer:buttonOfIndex(0):getContentSize().width *MainScene.elementScale
	tabLayer:buttonOfIndex(1):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(1):setPosition(ccp(x, menuBg:getPositionY()-menuBg:getContentSize().height*MainScene.elementScale + 10*MainScene.elementScale))
    tabLayer:buttonOfIndex(1):setScale(MainScene.elementScale)

    local x = tabLayer:buttonOfIndex(1):getPositionX()+tabLayer:buttonOfIndex(1):getContentSize().width *MainScene.elementScale
	tabLayer:buttonOfIndex(2):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(2):setPosition(ccp(x, menuBg:getPositionY()-menuBg:getContentSize().height*MainScene.elementScale + 10*MainScene.elementScale))
    tabLayer:buttonOfIndex(2):setScale(MainScene.elementScale)

	-- 设置默认显示
    require "script/ui/arena/ArenaChallenge"
    tabLayer:layerOfIndex(0):addChild( ArenaChallenge.createArenaChallengeLayer() )
    -- add by yangrui on 2015-09-22 
	local curDisplayLayerHight = layerSize.height-topBg:getContentSize().height*g_fScaleX-menuBg:getContentSize().height*g_fScaleX
    -- 按钮切换事件
	tabLayer:registerScriptTapHandler(function ( button,index )
		if (index == 0) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			-- 取消排行层定时器
			if( ArenaData.rankScheduleId ~= nil )then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.rankScheduleId)
				ArenaData.rankScheduleId = nil
			end
			tabLayer:layerOfIndex(0):addChild( ArenaChallenge.createArenaChallengeLayer() )
		elseif (index == 1) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			-- 取消竞技层 所有定时器
			for k,v in pairs(ArenaData.arenaScheduleId) do
				if(v ~= nil) then
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
				end
				ArenaData.arenaScheduleId[k] = nil
			end
            require "script/ui/arena/ArenaRankings"
            tabLayer:layerOfIndex(1):addChild( ArenaRankings.createArenaRankingsLayer() )
        elseif (index == 2) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			-- 取消竞技层 所有定时器
			for k,v in pairs(ArenaData.arenaScheduleId) do
				if(v ~= nil) then
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
				end
				ArenaData.arenaScheduleId[k] = nil
			end
            -- new shop enter
            require "script/ui/shopall/arena/PrestigeShop"
            tabLayer:layerOfIndex(2):addChild( PrestigeShop.createPrestigeShopLayer( CCSizeMake(layerSize.width/g_fScaleX, curDisplayLayerHight/g_fScaleX), false ) )
        end
	end)

	-- 关闭返回按钮
	addCloseFortsLayoutMenu()
end


-- 创建竞技层
function createArenaLayer()
	init()

    m_arena =  MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)
    m_arena:registerScriptHandler(function ( eventType,node )
   		if(eventType == "enter") then
   			require "script/ui/shop/RechargeLayer"
			RechargeLayer.registerChargeGoldCb(refreshArenaGold)
   		end
		if(eventType == "exit") then
			require "script/ui/main/MainScene"
			MainScene.registerStaminaNumberChangeCallback( nil )
			require "script/ui/shop/RechargeLayer"
			RechargeLayer.registerChargeGoldCb(nil)
			fnRelease()
		end
	end)


    -- 下一步创建与数据有关UI
    local function createNext( ... )
   		-- 更新倒计时
	   	local function updateRewardTime()
	   		-- 时间减1
	   		ArenaData.setAwardTime( ArenaData.getAwardTime() - 1 )
	   		-- print("更新倒计时！！！ " .. ArenaData.getAwardTime() )
	   		if (ArenaData.getAwardTime() <= 0) then 
	   			if(ArenaData.scheduleId_data ~= nil)then
	   				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.scheduleId_data)
	   				ArenaData.scheduleId_data = nil
	   			end
	   		end
	   	end
	   	-- 启动倒计时定时器
	   	if (ArenaData.getAwardTime() > 0 ) then 
	   		-- 启动定时器
	   		if(ArenaData.scheduleId_data == nil)then
	   			ArenaData.scheduleId_data = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateRewardTime, 1, false)
	   		end
	   	end
	   	local function createNextFun( ... )
			-- 初始化
	   		initArenaLayer()

	   		-- 新手引导
			addGuideArenaGuide3()

   		end
   		-- 获取幸运排名数据
   		ArenaService.getLuckyList(createNextFun)
	end
    -- 初始化数据
	ArenaService.getArenaInfo(createNext)
    
    return m_arena
end


-- 刷新耐力显示UI
function upDateStamina()
	if( tolua.isnull(_staminaLabel) )then
		return
	end
	_staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
end

-- 刷新界面金币
function refreshArenaGold ( ... )
	if( tolua.isnull(m_goldLabel) )then
		return
	end
	m_goldLabel:setString( UserModel.getGoldNumber() )
end

-- 耐力使用框 刷新方法
function refreshStaminaAndGold( ... )
	if( tolua.isnull(m_arena) )then
		return
	end
	upDateStamina()
	refreshArenaGold()
end

---[==[竞技场 第3步
---------------------新手引导---------------------------------
function addGuideArenaGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/ArenaGuide"
    if(NewGuide.guideClass == ksGuideArena and ArenaGuide.stepNum == 2) then
        ArenaGuide.show(3, nil)
    end
end
---------------------end-------------------------------------
--]==3


function fnRelease( ... )
	-- 取消竞技层 所有定时器
	for k,v in pairs(ArenaData.arenaScheduleId) do
		if(v ~= nil)then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
		end
		ArenaData.arenaScheduleId[k] = nil
		-- print(GetLocalizeStringBy("key_2408") .. k )
	end
	-- 取消排行层定时器
	if( ArenaData.rankScheduleId ~= nil )then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.rankScheduleId)
		ArenaData.rankScheduleId = nil
		-- print("释放rankScheduleId")
	end
	-- 取消数据定时器
	if( ArenaData.scheduleId_data ~= nil )then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ArenaData.scheduleId_data)
		ArenaData.scheduleId_data = nil
	end
	-- ArenaLayer 全局变量置nil
	menuBg = nil    												-- 按钮背景
	m_powerLabel = nil            									-- 战斗力数值
	m_silverLabel = nil												-- 银币值
	m_goldLabel	= nil												-- 金币值
	_staminaLabel = nil												-- 耐力
	-- ArenaChallenge 全局变量
	ArenaChallenge.todaySurplusNum = nil							-- 今日剩余次数
	ArenaChallenge.curRanking = nil  								-- 当前名次
	ArenaChallenge.challengeTableView = nil							-- 竞技列表
	-- ArenaData 全局变量
	ArenaData.allUserData = nil 									-- 竞技场所有玩家表
	ArenaData.luckyListData = nil                     				-- 幸运排名数据
	ArenaData.rewardData = nil										-- 领取奖励数据
	ArenaData.rankListData = nil                      				-- 排行榜前十数据
	ArenaData.challengeData = nil                     				-- 挑战后返回数据
	ArenaData.arenaScheduleId = {}									-- 定时器表
	ArenaData.arenaInfo = nil                         				-- 竞技场数据
end




























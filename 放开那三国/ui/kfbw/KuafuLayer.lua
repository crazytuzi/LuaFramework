-- FileName: KuafuLayer.lua 
-- Author: yangrui
-- Date: 15-09-23
-- Purpose: 跨服比武 主界面

module("KuafuLayer", package.seeall)

require "script/ui/kfbw/KuafuData"
require "script/ui/kfbw/KuafuService"
require "script/ui/kfbw/KuafuController"
require "script/ui/kfbw/KuafuResultLayer"
require "script/ui/kfbw/KuafuProstrateLayer"
require "script/ui/kfbw/ActiveNotOpenLayer"
require "script/model/user/UserModel"
require "script/utils/TimeUtil"
require "script/audio/AudioUtil"
require "script/ui/tip/AnimationTip"

local _bgLayer              = nil
local _layerSize            = nil
local _curDisplayLayer      = nil
local _boardSize            = nil  -- 战斗力、银币、金币信息板 Size
local _powerLabel           = nil  -- 战斗力Label
local _silverLabel          = nil  -- 银币Label
local _goldLabel            = nil  -- 金币Label
local _btnHeight            = nil  -- 上方按钮栏的高度
local _countDownLayer       = nil  -- 倒计时Layer
local _curDisplayLayerHight = nil  -- 当前显示Layer的高

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer              = nil
	_layerSize            = nil
	_curDisplayLayer      = nil
	_boardSize            = nil  -- 战斗力、银币、金币信息板 Size
	_powerLabel           = nil  -- 战斗力Label
	_silverLabel          = nil  -- 银币Label
	_goldLabel            = nil  -- 金币Label
	_btnHeight            = nil  -- 上方按钮栏的高度
	_countDownLayer       = nil  -- 倒计时Layer
	_curDisplayLayerHight = nil  -- 当前显示Layer的高
end

--[[
	@des 	: 回调onEnter和onExit事件
	@param 	: 
	@return : 
--]]
function onNodeEvent( pEvent )
    if pEvent == "enter" then
    elseif pEvent == "exit" then
       _bgLayer = nil
    end
end

--[[
	@des    : 得到上方面板的高
	@para   : 
	@return : 
--]]
function getBoardHeight( ... )
	require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	return _boardSize.height+bulletinLayerSize.height
end

--[[
	@des    : 刷新信息面板银币数
	@para   : 
	@return : 
--]]
function refreshSliverLabelFunc( ... )
	if _silverLabel ~= nil then
		-- modified by yangrui at 2015-12-03
		_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
	end
end

--[[
	@des    : 刷新信息面板金币数
	@para   : 
	@return : 
--]]
function refreshGoldLabelFunc( ... )
	if _goldLabel ~= nil then
		_goldLabel:setString(UserModel.getGoldNumber())
	end
end

--[[
	@des    : 创建战斗力、银币、金币信息板
	@para   : 
	@return : 
--]]
function createUserInfoBoard( ... )
	require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
	-- 上标题栏 显示战斗力，银币，金币
	local boardBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    boardBg:setAnchorPoint(ccp(0,1))
    boardBg:setPosition(0,_bgLayer:getContentSize().height)
    boardBg:setScale(g_fScaleX/MainScene.elementScale)
    _bgLayer:addChild(boardBg)
    -- 获取战斗力条的Size
    _boardSize = boardBg:getContentSize()
    -- 战斗力 文字 Label
    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(boardBg:getContentSize().width*0.13,boardBg:getContentSize().height*0.43)
    boardBg:addChild(powerDescLabel)
    -- 战斗力 数值 Label
    _powerLabel = CCRenderLabel:create(tonumber(UserModel.getFightForceValue()),g_sFontName,23,1.5,ccc3( 0x00, 0x00, 0x00),type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setAnchorPoint(ccp(0,0.5))
    _powerLabel:setPosition(boardBg:getContentSize().width*0.23,boardBg:getContentSize().height*0.47)
    boardBg:addChild(_powerLabel)
    -- 银币 数值 Label
    -- modified by yangrui at 2015-12-03
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(boardBg:getContentSize().width*0.61,boardBg:getContentSize().height*0.43)
    boardBg:addChild(_silverLabel)
    -- 金币 数值 Label
    _goldLabel = CCLabelTTF:create(tonumber(userInfo.gold_num),g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(boardBg:getContentSize().width*0.82,boardBg:getContentSize().height*0.43)
    boardBg:addChild(_goldLabel)
end

--[[
	@des    : 关闭按钮回调
	@para   : 
	@return : 
--]]
function closeKuafuLayerAction( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/active/ActiveList"
	local  activeList = ActiveList.createActiveListLayer()
	MainScene.changeLayer(activeList, "activeList")
end

--[[
	@des    : 说明按钮回调
	@para   : 
	@return : 
--]]
function guideBtnCallFunc( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 说明key 8  DB_Help_tips
	require "script/utils/DescLayer"
	DescLayer.show(GetLocalizeStringBy("key_3223"),8,-550,1000)
end

--[[
	@des    : 预览按钮回调
	@para   : 
	@return : 
--]]
function rewardBtnCallFunc( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/kfbw/kfbwreward/KFBWRewardLayer"
	KFBWRewardLayer.showLayer()
end

--[[
	@des    : 积分排行按钮回调
	@para   : 
	@return : 
--]]
function standingBtnCallFunc( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/kfbw/kfbwstandings/KFBWRankLayer"
	KFBWRankLayer.showLayer()
end

--[[
	@des    : 商店按钮回调
	@para   : 
	@return : 
--]]
function kfbwShopBtnCallFunc( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/kfbw/kfbwshop/KFBWShopLayer"
	KFBWShopLayer.showLayer()
end

--[[
	@des    : 创建上方按钮
	@para   : 
	@return : 
--]]
function createTopBtn( ... )
	local topBtnBg = CCScale9Sprite:create()
	topBtnBg:setPreferredSize(CCSizeMake(640, 100))
	topBtnBg:setAnchorPoint(ccp(0.5, 1))
	topBtnBg:setPosition(ccp(_layerSize.width*0.5,_layerSize.height-_boardSize.height*g_fScaleX))
	topBtnBg:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(topBtnBg)
	local mainMenuBar = CCMenu:create()
	mainMenuBar:setAnchorPoint(ccp(1,1))
	mainMenuBar:setPosition(ccp(0,0))
	topBtnBg:addChild(mainMenuBar)
	-- 返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0,0))
	closeMenuItem:setPosition(ccp(topBtnBg:getContentSize().width-closeMenuItem:getContentSize().width-10,10))
	closeMenuItem:registerScriptTapHandler(closeKuafuLayerAction)
	mainMenuBar:addChild(closeMenuItem)
	-- 说明按钮
	local guideMenuItem = CCMenuItemImage:create("images/kfbw/des_n.png","images/kfbw/des_h.png")
    guideMenuItem:setAnchorPoint(ccp(0,0))
    guideMenuItem:setPosition(ccp(closeMenuItem:getPositionX()-guideMenuItem:getContentSize().width-10,0))
    guideMenuItem:registerScriptTapHandler(guideBtnCallFunc)
    mainMenuBar:addChild(guideMenuItem)
    -- 奖励预览按钮
    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(0,0))
    rewardMenuItem:setPosition(ccp(guideMenuItem:getPositionX()-rewardMenuItem:getContentSize().width-10,-5))
    rewardMenuItem:registerScriptTapHandler(rewardBtnCallFunc)
    mainMenuBar:addChild(rewardMenuItem)
    -- 积分排行按钮
    local standingButton = CCMenuItemImage:create("images/recharge/score_wheel/rank_btn_n.png","images/recharge/score_wheel/rank_btn_h.png")
	standingButton:setAnchorPoint(ccp(0,0))
	standingButton:setPosition(ccp(rewardMenuItem:getPositionX()-standingButton:getContentSize().width-10,0))
	standingButton:registerScriptTapHandler(standingBtnCallFunc)
	mainMenuBar:addChild(standingButton)
    -- 跨服比武商店按钮
    local kfbwShopButton = CCMenuItemImage:create("images/kfbw/kfbwshop/kfbwshop_n.png","images/kfbw/kfbwshop/kfbwshop_h.png")
	kfbwShopButton:setAnchorPoint(ccp(0,0))
	kfbwShopButton:setPosition(ccp(standingButton:getPositionX()-kfbwShopButton:getContentSize().width-10,0))
	kfbwShopButton:registerScriptTapHandler(kfbwShopBtnCallFunc)
	mainMenuBar:addChild(kfbwShopButton)

	_btnHeight = topBtnBg:getContentSize().height
end

--[[
	@des    : 创建比武Layer
	@para   : 
	@return : 
--]]
function createBattleLayer( ... )
	require "script/ui/kfbw/KuafuMatchLayer"
	if _curDisplayLayer ~= nil then
		_curDisplayLayer:removeFromParentAndCleanup(true)
		_curDisplayLayer = nil
	end
	_curDisplayLayer = KuafuMatchLayer.createKFBWMatchLayer(CCSizeMake(_layerSize.width,_curDisplayLayerHight))
	_curDisplayLayer:setScale(1/MainScene.elementScale)
	_bgLayer:addChild(_curDisplayLayer)
end

--[[
	@des    : 创建膜拜Layer
	@para   : 
	@return : 
--]]
function createProstrateLayer( ... )
	if _curDisplayLayer ~= nil then
		_curDisplayLayer:removeFromParentAndCleanup(true)
		_curDisplayLayer = nil
	end
	_curDisplayLayer = KuafuProstrateLayer.createKFBWProstrateLayer(CCSizeMake(_layerSize.width,_curDisplayLayerHight))
	_curDisplayLayer:setScale(1/MainScene.elementScale)
	_bgLayer:addChild(_curDisplayLayer)
end

--[[
	@des    : 创建活动未开启倒计时Layer
	@para   : 
	@return : 
--]]
function createNotopenLayer( ... )
	if _curDisplayLayer ~= nil then
		_curDisplayLayer:removeFromParentAndCleanup(true)
		_curDisplayLayer = nil
	end
	_curDisplayLayer = ActiveNotOpenLayer.createNotOpenLayer()
	_curDisplayLayer:setScale(1/MainScene.elementScale)
	_bgLayer:addChild(_curDisplayLayer)
end

--[[
	@des    : 创建UI
	@para   : 
	@return : 
--]]
function createUI( ... )
	print("createUI===")
	-- 当前显示Layer的高
	_curDisplayLayerHight = _layerSize.height-_boardSize.height*g_fScaleY-_btnHeight*g_fScaleY
	print("_curDisplayLayerHight",_curDisplayLayerHight)
	-- 根据配置时间来调用比武还是膜拜
	local curTime = TimeUtil.getSvrTimeByOffset()
	local battleStartTime = KuafuData.getStartTime()         -- 比武开启时间
	local battleEndTime = KuafuData.getEndTime()             -- 比武结束时间  也是膜拜开始时间
	local prostrateEndTime = KuafuData.getRewardEndTime()    -- 膜拜结束时间
	local newBattleStartTime = KuafuData.getPeriedEndTime()  -- 整个活动结束时间  即新活动开启时间
	print("=|=|=",curTime,battleStartTime,battleEndTime,prostrateEndTime,newBattleStartTime)
	if battleStartTime <= curTime and curTime < battleEndTime then
		print("createUI  比武")
		-- 比武
		createBattleLayer()
	elseif battleEndTime <= curTime and curTime < prostrateEndTime then
		print("createUI   膜拜")
		-- 膜拜
		createProstrateLayer()
	elseif prostrateEndTime <= curTime and curTime < newBattleStartTime then
		print("createUI   未开始比武")
		-- 判断是不是新活动开启前进入
		-- 展示倒计时
		createNotopenLayer()
	end
end

--[[
	@des    : 关闭所有打开的弹框
	@para   : 
	@return : 
--]]
function closeAllOpenDialog( ... )
	require "script/ui/kfbw/ShowChestLayer"
	ShowChestLayer.closeButtonFunc()
	require "script/ui/kfbw/BuyBattleTimes"
	BuyBattleTimes.closeFunc()
	require "script/ui/kfbw/AlertConsumeLayer"
	AlertConsumeLayer.closeAction()
end

--[[
	@des    : 活动结束时间点刷新
	@para   : 
	@return : 
--]]
function refreshOnActivitiesEnd()
	print("refreshOnActivitiesEnd")
    require "script/utils/extern"
    if (_bgLayer ~= nil) then
		local curTime = TimeUtil.getSvrTimeByOffset()
		local battleStartTime = KuafuData.getStartTime()         -- 比武开启时间
		local battleEndTime = KuafuData.getEndTime()             -- 比武结束时间  也是膜拜开始时间
		local prostrateEndTime = KuafuData.getRewardEndTime()    -- 膜拜结束时间
		if battleStartTime <= curTime and curTime < battleEndTime then
			local subTime = battleEndTime-curTime
			if ( subTime > 0 ) then
                performWithDelay(_bgLayer, function( ... )
                	-- 关闭所有打开的弹框
                	closeAllOpenDialog()
					_curDisplayLayer:removeFromParentAndCleanup(true)
					_curDisplayLayer = nil
                   	-- 膜拜
					-- 创建膜拜UI
					createProstrateLayer()
                end, subTime)
            end
		elseif battleEndTime <= curTime and curTime < prostrateEndTime then
			local subTime = prostrateEndTime-curTime
			if ( subTime > 0 ) then
				performWithDelay(_bgLayer, function( ... )
					-- 活动倒计时
					_curDisplayLayer:removeFromParentAndCleanup(true)
					_curDisplayLayer = nil
					-- 展示倒计时
					createNotopenLayer()
				end, subTime)
			end
		end
    end
end

--[[
	@des    : 0点刷新
	@para   : 
	@return : 
--]]
function refreshInZero( ... )
	-- 跨服比武商店如果是开启状态说明活动需要刷新
	if KuafuData.isOpenKuafuShop() then
		-- 根据配置时间来调用比武还是膜拜
		local curTime = TimeUtil.getSvrTimeByOffset()
		local battleStartTime = KuafuData.getStartTime()         -- 比武开启时间
		local battleEndTime = KuafuData.getEndTime()             -- 比武结束时间  也是膜拜开始时间
		local prostrateEndTime = KuafuData.getRewardEndTime()    -- 膜拜结束时间
		local newBattleStartTime = KuafuData.getPeriedEndTime()  -- 整个活动结束时间  即新活动开启时间
		print("=|refreshInZero|=",curTime,battleStartTime,battleEndTime,prostrateEndTime,newBattleStartTime)
		if battleStartTime <= curTime and curTime < battleEndTime then
		-- 比武的话
		-- 挑战次数
		-- 重设刷新次数
		-- 不刷新对手
		-- 重设胜场奖励进度条
		-- 重置胜场数
		-- 关闭所有打开的弹框
		closeAllOpenDialog()
		KuafuService.getWorldCompeteInfo(function( ... )
			local kuafuInfo = KuafuData.getWorldCompeteInfo()
			if kuafuInfo.ret == "ok" then
				if _bgLayer ~= nil then
					-- 创建比武UI
					createBattleLayer()
				end
			end
		end)
		elseif battleEndTime <= curTime and curTime < prostrateEndTime then
			if _bgLayer ~= nil then
				-- 膜拜的话
				-- 创建膜拜UI
				createProstrateLayer()
			end
		elseif prostrateEndTime <= curTime and curTime < newBattleStartTime then
			if _bgLayer ~= nil then
				-- 当前时间到达了活动结束时间  处于分组时期
				_curDisplayLayer:removeFromParentAndCleanup(true)
				_curDisplayLayer = nil
				-- 展示倒计时
				createNotopenLayer()
			end
		end
	end
end

--[[
	@des    : 创建跨服比武Layer
	@para   : 
	@return : 
--]]
function createKFBWLayer( ... )
	-- init
	init()
	_bgLayer = MainScene.createBaseLayer("images/kfbw/kfbw_bg.jpg",false,false,true)
	_bgLayer:registerScriptHandler(onNodeEvent)
	_layerSize = _bgLayer:getContentSize()
	-- 创建战斗力、银币、金币信息板
	createUserInfoBoard()
	-- 创建上方按钮
	createTopBtn()
	-- 活动时间点刷新
	refreshOnActivitiesEnd()

	return _bgLayer
end

--[[
	@des    : 将时间转换为下一个星期一的0点
	@para   : 
	@return : 
--]]
function convertToNextMonday( pTime )
	local openTime = tonumber(pTime)
	if openTime < TimeUtil.getSvrTimeByOffset(0) then
		openTime = TimeUtil.getSvrTimeByOffset(0)
	end
	local transFormTime = os.date("*t",openTime)
	transFormTime.hour = 0
	transFormTime.min = 0
	transFormTime.sec = 0
	local preZeroTime = os.time(transFormTime)
	local weekDay = tonumber(os.date("%w",preZeroTime))
	if weekDay == 0 then
		preZeroTime = preZeroTime-6*86400
	else
		preZeroTime = preZeroTime-(weekDay-1)*86400
	end
	
	return preZeroTime+7*86400
end

--[[
	@des    : 显示跨服比武Layer
	@para   : 
	@return : 
--]]
function showKFBWLayer( ... )
	KuafuService.getWorldCompeteInfo(function( ... )
		local kuafuInfo = KuafuData.getWorldCompeteInfo()
		if kuafuInfo.ret == "no" then
			-- 不可以进入的时候
			-- yr_2020 = "由于开服时间限制，跨服比武活动将于",
			-- yr_2021 = "开始。",
			local zeroTime = convertToNextMonday(kuafuInfo.open_time)
			local str = GetLocalizeStringBy("yr_2020") .. TimeUtil.getTimeFormatChnYMDHM(zeroTime) .. GetLocalizeStringBy("yr_2021")
			AnimationTip.showTip(str)
		else
			-- 可以进入的时候
			local kfbwLayer = createKFBWLayer()
			MainScene.changeLayer(kfbwLayer, "kfbwLayer")
			-- 创建UI
			createUI()
		end
	end)
end

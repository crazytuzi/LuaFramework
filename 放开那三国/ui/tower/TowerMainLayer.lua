-- Filename：	TowerMainLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-1-7
-- Purpose：		爬塔主界面


module("TowerMainLayer", package.seeall)


require "script/ui/tower/TowerCache"
require "script/ui/tower/TowerUtil"
require "script/ui/tower/TowerRewardLayer"
require "db/DB_Tower_layer"
require "db/DB_Vip"

Tag_Btn_Reward	= 20001
Tag_Btn_Rank	= 20002
Tag_Btn_Secret  = 20003
Tag_Menu_Bar	= 20004
Tag_SecretMenu_Bar	= 20005

local x_rate = 0.8
local y_rate = 0.25

local _bgLayer 			= nil
local _layerSize 		= nil
local _tipSprite  		= nil
local _secretNum 		= 1

local _silverLabel 		= nil
local _goldLabel 		= nil
local cost 				= -1
local _topBg 			= nil

local _curFloorLabel		= nil 	-- 当前层
local _passConditionLabel 	= nil 	-- 通关条件

local _loveSpiteArr 		= {} 	-- 挑战次数的心
local _grayLoveSpiteArr 	= {} 	-- 挑战次数的心 灰色

local _rewardSilverLabel 	= nil 	-- 通关奖励 银币
local _rewardSoulLabel		= nil 	-- 通关奖励 将魂

local _leftResetTimesLabel  = nil 	-- 剩余重置次数

local _attackTowerBtn 		= nil 	-- 攻打
local _enterNextBtn 		= nil	-- 进入下一层

local _isEnterNextStatus	= false -- 进入的状态

local _attackOrEnterMenuBar = nil 	-- 攻打或进入下一层
local _floorRewardMenuBar	= nil 	-- 创建特殊层的奖励按钮

local _curFloorDesc 		= nil 	-- 当前层的相关信息

local _towerInfo 			= nil 	-- 缓存中的信息

local floorSprite 			= nil 	-- 当前层数背景

local resetBtn 				= nil 	-- 重置
local swipBtn 				= nil 	-- 扫荡
local finishBtn 			= nil   -- 立即完成按钮
local finishCostLabel 		= 0 	-- 立即完成花费金币数
local goldSpriteIcon 		= nil	-- 金sprite
local canFinish				= true  -- 可以立即完成
local cancelSwipBtn 		= nil 	-- 取消扫荡
local _sweepRestTimeLabel 	= nil 	-- 扫荡倒计时
--local secretItem			= nil   -- 神秘塔item
local _secretTimeLabel      = nil   -- 神秘塔关闭倒计时汉字
local _secretTimeNumLabel	= nil	-- 神秘塔关闭倒计时数字
local _secretAttackLabel    = nil   -- 神秘塔攻打次数汉字
local _secretAttackCount	= nil	-- 神秘塔攻打次数数字

local _updateTimeScheduler 	= nil	-- scheduler
local _spellEffectSprite 	= nil 	-- 已通关特效

local _updateTimeSecretScheduler 	= nil	-- scheduler

local _isNeedReRequestInfo 	= false -- 断线重连后是否需要发请求

local _specialData = nil			--神秘层总数据

local _secretCount = 0

local haveSpecial = nil					--神秘层具体数据
local secretItem = nil					--神秘层按钮
local mainMenuBar = nil
local mainMenuBarCpy = nil				--神秘层menu
local strongId = 0
local mainMenuBar = nil
local inputTextCpy = nil

function init()
	_bgLayer 		= nil
	_layerSize 		= nil
	_silverLabel 	= nil
	_goldLabel 		= nil
	_topBg 			= nil
	_curFloorLabel	= nil 	-- 当前层

	_passConditionLabel = nil 	-- 通关条件
	_loveSpiteArr 		= {} 	-- 挑战次数的心
	_grayLoveSpiteArr 	= {} 	-- 挑战次数的心 灰色
	_rewardSilverLabel 	= nil 	-- 通关奖励 银币
	_rewardSoulLabel	= nil 	-- 通关奖励 将魂
	_leftResetTimesLabel= nil 	-- 剩余重置次数

	_attackTowerBtn 	= nil 	-- 攻打
	_enterNextBtn 		= nil	-- 进入下一层

	_isEnterNextStatus 	= false -- 进入的状态
	_attackOrEnterMenuBar = nil -- 攻打或进入下一层
	_floorRewardMenuBar = nil 	-- 创建特殊层的奖励按钮

	_curFloorDesc 		= nil 	-- 当前层的相关信息
	_towerInfo 			= nil 	-- 缓存中的信息
	floorSprite 		= nil 	-- 当前层数背景
	resetBtn 			= nil 	-- 重置
	finishBtn 			= nil   -- 立即完成按钮·
	finishCostLabel 	= 0 	-- 立即完成花费金币数
	goldSpriteIcon 			= nil	-- 金sprite
	canFinish			= true  -- 可以立即完成
	swipBtn 			= nil 	-- 扫荡
	cancelSwipBtn 		= nil 	-- 取消扫荡
	_updateTimeScheduler = nil	-- scheduler
	_updateTimeSecretScheduler = nil --secretsch
	_sweepRestTimeLabel = nil 	-- 扫荡倒计时
	_spellEffectSprite 	= nil 	-- 已通关特效
	mainMenuBarCpy 		= nil
	_isNeedReRequestInfo= false -- 断线重连后是否需要发请求\
	mainMenuBar 		= nil
	inputTextCpy 		= nil
	secretItem 			= nil
end

--设置神秘层数据
function setSpecialData( mData )
	_specialData = mData
end

--获取神秘层数据
function getSpecialData()
	for k,v in pairs (_specialData) do
		_secretCount = _secretCount + 1
	end
	return _specialData
end

-- 停止scheduler
function stopScheduler()
	if(_updateTimeScheduler ~= nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

-- 停止scheduler
function stopSecretScheduler()
	if(_updateTimeSecretScheduler ~= nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeSecretScheduler)
		_updateTimeSecretScheduler = nil
	end
end

-- 启动scheduler
function startScheduler()
	if(_updateTimeScheduler == nil) then
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeFunc, 1, false)
	end
end

-- 启动神秘层scheduler
function startSecretScheduler()
	if(_updateTimeSecretScheduler == nil) then
		_updateTimeSecretScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeSecretFunc, 1, false)
	end
end

-- 刷新神秘层数据和数量
function freshData()
	-- body
	-- _towerInfo = TowerCache.getTowerInfo()
	-- -- _secretNum = 0
	-- if(_towerInfo.va_tower_info.special_tower.specail_tower_list ~= nil)then
	-- 	if(not table.isEmpty(_towerInfo.va_tower_info.special_tower.specail_tower_list))then
	-- 		for k,v in pairs (_towerInfo.va_tower_info.special_tower.specail_tower_list) do
	-- 			_secretNum = _secretNum + 1
	-- 		end
	-- 		if(_secretNum ~= 0)then
	-- 			setSpecialData(_towerInfo.va_tower_info.special_tower.specail_tower_list)
	-- 			showSecret()
	-- 		end
	-- 	end
	-- end
end

-- 断线重连后回调
function reConnectDelegate()
	-- 释放通知方法
	print(GetLocalizeStringBy("key_1629"))
	LoginScene.removeObserverForNetConnected("requestTowerInfo")

	-- if(_isNeedReRequestInfo == true)then
	-- _isNeedReRequestInfo = false
	-- RequestCenter.tower_getTowerInfo(sweepOverCallback)
	-- end
	RequestCenter.tower_getTowerInfo(sweepOverCallback)
end

-- 扫荡倒计时
function updateTimeFunc( ... )
	if(TowerCache.getSweepEndTime())then
		local leftTimeInterval = TowerCache.getSweepEndTime() - TimeUtil.getSvrTimeByOffset()
		if(_sweepRestTimeLabel ~= nil)then
			_sweepRestTimeLabel:setString(GetLocalizeStringBy("key_1124") .. TimeUtil.getTimeString(leftTimeInterval) )
		end
		if(leftTimeInterval>0)then
			if(math.mod( (TimeUtil.getSvrTimeByOffset() - TowerCache.getSweepStartTime()) , TowerUtil.getWipeCD()  ) == 0  )then
				-- 处理扫荡的数据
				handleSweepData()
				refreshMainUI()
				createAttackUI()
			end
		else
			refreshSweepBtn()
			stopScheduler()
			if(g_network_status==g_network_connected)then
				-- 重新拉取爬塔信息
				-- _isNeedReRequestInfo = true
				RequestCenter.tower_getTowerInfo(sweepOverCallback)
			else
				-- 增加断线重连回调
				LoginScene.addObserverForNetConnected("requestTowerInfo", reConnectDelegate)
			end
		end
	else
		refreshSweepBtn()
		stopScheduler()
	end
end

-- 神秘层倒计时
function updateTimeSecretFunc( ... )
	local gData = getSpecialData()

	for k,v in pairs (gData) do
		-- _secretCount = _secretCount + 1
		local sevTime = TimeUtil.getSvrTimeByOffset()
		cp = DB_Tower.getDataById(1)

		local leftTimeInterval = tonumber(v[2])+cp.hideLayerTime - TimeUtil.getSvrTimeByOffset()
		if(leftTimeInterval>0)then

			leftTimeInterval = leftTimeInterval - 1

			v[2] = tostring(sevTime - leftTimeInterval)

			setSpecialData(gData)

		elseif(leftTimeInterval==0) then
			_secretCount = _secretCount - 1

			table:remove(gData,k)

			setSpecialData(gData)

			if(_secretCount == 0)then

				stopSecretScheduler()

			end
		end
	end
end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(refreshTopUI)
		--- 停止 提前拉取的定时程序
		TowerCache.stopScheduler()

	elseif (event == "exit") then
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(nil)
		-- 停止扫荡
		stopScheduler()

		-- 如果扫荡没用结束 启动 提前拉取的定时程序
		if(TowerCache.isTowerSweep()==true)then
			TowerCache.startScheduler()
		end
		-- 释放通知方法
		LoginScene.removeObserverForNetConnected("requestTowerInfo")
	end
end

-- 创建Top
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
    _powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerDescLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerDescLabel)

	-- 银币
	-- modified by yangrui at 2015-12-03
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


-- 刷新上部UI
function refreshTopUI()
	-- modified by yangrui at 2015-12-03
	_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
	_goldLabel:setString(UserModel.getGoldNumber())
end

-- 刷新挑战次数
function refreshAttackArr()
	for i=1,TowerUtil.getMaxFailedTimes() do
		if(i<=tonumber(_towerInfo.can_fail_num))then
			_loveSpiteArr[i]:setVisible(true)
			_grayLoveSpiteArr[i]:setVisible(false)
		else
			_loveSpiteArr[i]:setVisible(false)
			_grayLoveSpiteArr[i]:setVisible(true)
		end
	end
end

-- 刷新主界面的UI
function refreshMainUI()
-- 当前层数
	if(_curFloorLabel)then
		_curFloorLabel:removeFromParentAndCleanup(true)
		_curFloorLabel=nil
	end
	_towerInfo = TowerCache.getTowerInfo()
	-- 当前层数
	_curFloorLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. _towerInfo.cur_level .. GetLocalizeStringBy("key_2400") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_curFloorLabel:setAnchorPoint(ccp(0, 0.5))
	_curFloorLabel:setColor(ccc3(0x00, 0xe4, 0xff))
	_curFloorLabel:setPosition(ccp(185, floorSprite:getContentSize().height*0.5))
	floorSprite:addChild(_curFloorLabel)
	-- finishCostLabel:setString((_towerInfo.max_level-_towerInfo.cur_level+1)*cp.wipeGold)
	-- 立即完成
	if(finishBtn~=nil)then
		finishBtn:removeFromParentAndCleanup(true)
		finishBtn = nil
	end
	if(tonumber(_towerInfo.cur_level)>=tonumber(_towerInfo.max_level))then
		canFinish = false
		finishBtn = LuaCC.create9ScaleMenuItem("images/tower/graybg.png","images/tower/graybg.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		canFinish = true
		finishBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	finishBtn:setAnchorPoint(ccp(0.5, 0))
	finishBtn:setScale(g_fElementScaleRatio)
    finishBtn:setPosition(ccp(_layerSize.width*0.5, 60*g_fScaleY))
    finishBtn:registerScriptTapHandler(finishNowAction)
	mainMenuBar:addChild(finishBtn)

	if(finishBtn:getChildByTag(110)~=nil)then
		goldSpriteIcon:removeFromParentAndCleanup(true)
		goldSpriteIcon = nil
	end
	goldSpriteIcon = CCSprite:create("images/common/gold.png")
	finishBtn:addChild(goldSpriteIcon,10,110)
	goldSpriteIcon:setAnchorPoint(ccp(1,0))
	goldSpriteIcon:setPosition(ccp(finishBtn:getContentSize().width*0.5,-goldSpriteIcon:getContentSize().height))

	if(TowerCache.isTowerSweep() == false)then
		cp = DB_Tower.getDataById(1)
		finishCostLabel = CCLabelTTF:create((tonumber(_towerInfo.max_level)-tonumber(_towerInfo.cur_level)+1)*cp.wipeGold, g_sFontName, 24)
		finishCostLabel:setColor(ccc3(0x00, 0xff, 0x18))
		finishCostLabel:setAnchorPoint(ccp(0,0))
		finishCostLabel:setPosition(ccp(finishBtn:getContentSize().width*0.5,-goldSpriteIcon:getContentSize().height))
		finishBtn:addChild(finishCostLabel)
	else
		cp = DB_Tower.getDataById(1)
		if(inputTextCpy~=nil)then
			finishCostLabel = CCLabelTTF:create((inputTextCpy-tonumber(_towerInfo.cur_level)+1)*cp.wipeGold, g_sFontName, 24)
			finishCostLabel:setColor(ccc3(0x00, 0xff, 0x18))
			finishCostLabel:setAnchorPoint(ccp(0,0))
			finishCostLabel:setPosition(ccp(finishBtn:getContentSize().width*0.5,-goldSpriteIcon:getContentSize().height))
			finishBtn:addChild(finishCostLabel)
		else
			finishCostLabel = CCLabelTTF:create((tonumber(_towerInfo.max_level)-tonumber(_towerInfo.cur_level)+1)*cp.wipeGold, g_sFontName, 24)
			finishCostLabel:setColor(ccc3(0x00, 0xff, 0x18))
			finishCostLabel:setAnchorPoint(ccp(0,0))
			finishCostLabel:setPosition(ccp(finishBtn:getContentSize().width*0.5,-goldSpriteIcon:getContentSize().height))
			finishBtn:addChild(finishCostLabel)
		end
	end
	if(tonumber(_towerInfo.cur_level)==tonumber(_towerInfo.max_level))then
		finishCostLabel:setString("0")
	end
-- 通关条件
	if(_passConditionLabel)then
		_passConditionLabel:removeFromParentAndCleanup(true)
		_passConditionLabel= nil
	end
	_passConditionLabel = CCRenderLabel:create(TowerUtil.getPassFloorCondition(_curFloorDesc.star_condition) , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_passConditionLabel:setAnchorPoint(ccp(0, 1))
	_passConditionLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_passConditionLabel:setPosition(ccp(120*g_fScaleX, _layerSize.height-160*g_fScaleY))
	_passConditionLabel:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(_passConditionLabel)

-- 通关奖励
	-- 银币和将魂
	_rewardSilverLabel:setString(_curFloorDesc.silver)
	local soul_num = _curFloorDesc.soul or 0
	_rewardSoulLabel:setString(soul_num)


	if(resetBtn)then
		resetBtn:removeFromParentAndCleanup(true)
		resetBtn = nil
	end
	-- 重置按钮
	local btnLabelRate = 0.5
	if(tonumber(_towerInfo.reset_num) <= 0)then
		btnLabelRate = 0.4
	end
	resetBtn = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png","images/common/btn/btn1_d.png",CCSizeMake(200, 73))  --create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), btn_string, ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	resetBtn:setAnchorPoint(ccp(0.5, 0))
	resetBtn:setScale(g_fElementScaleRatio)
    resetBtn:setPosition(ccp(_layerSize.width*0.2, 60*g_fScaleY))
    resetBtn:registerScriptTapHandler(resetAttackAction)
	mainMenuBar:addChild(resetBtn)

	local resetLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1040"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	resetLabel:setAnchorPoint(ccp(0.5, 0.5))
	resetLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	resetLabel:setPosition(ccp(resetBtn:getContentSize().width*btnLabelRate, resetBtn:getContentSize().height*0.5))
	resetBtn:addChild(resetLabel)

-- 剩余重置次数
	_leftResetTimesLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3056") .. _towerInfo.reset_num, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_leftResetTimesLabel:setAnchorPoint(ccp(0.5, 1))
	_leftResetTimesLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_leftResetTimesLabel:setPosition(ccp(resetBtn:getContentSize().width*0.5, 0))
	resetBtn:addChild(_leftResetTimesLabel)

	if(tonumber(_towerInfo.reset_num) <= 0)then

		-- 金币图标
	    local goldSprite = CCSprite:create("images/common/gold.png")
	    goldSprite:setAnchorPoint(ccp(0,0.5))
	    goldSprite:setPosition(ccp(resetBtn:getContentSize().width*0.6, resetBtn:getContentSize().height*0.45))
	    resetBtn:addChild(goldSprite)

	    --
	    local costGold = TowerCache.getGoldByResetTimes(TowerCache.getTimesByGoldReset() + 1)
	    local costGoldLabel = CCLabelTTF:create(costGold, g_sFontName, 23)
	    costGoldLabel:setAnchorPoint(ccp(0, 0.5))
	    costGoldLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    costGoldLabel:setPosition(ccp( goldSprite:getContentSize().width, goldSprite:getContentSize().height*0.5 ))
	    goldSprite:addChild(costGoldLabel)
	end

-- 刷新宝箱
	createFloorReward()
end

-- 刷新扫荡
function refreshSweepBtn()
	if(TowerCache.isTowerSweep() == true)then
		swipBtn:setVisible(false)
		cancelSwipBtn:setVisible(true)
	else
		swipBtn:setVisible(true)
		cancelSwipBtn:setVisible(false)
	end
end

-- 宝物预览和排行
function preAndRankAction( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == Tag_Btn_Reward)then
		-- 宝物预览
		require "script/ui/tower/RewardPreviewLayer"
	    local layer = RewardPreviewLayer.createLayer()
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(layer,999)
	elseif(tag == Tag_Btn_Rank)then
		-- 排名
		require "script/ui/tower/TowerRankLayer"
	    local layer = TowerRankLayer.createRankingsLayer()
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(layer,999)
    elseif(tag == Tag_Btn_Secret)then
        -- 神秘塔
        if(ItemUtil.isBagFull() == true)then
			return
		end
        require "script/ui/tower/RewardSecretLayer"
        specialData = getSpecialData()
	    local layer = RewardSecretLayer.createLayer(specialData)

	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(layer,999)
	    layer:setTag(121)
	end

end

-- 某一层的特殊奖励
function floorRewardAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 一层奖励
	TowerRewardLayer.showRewardWindow(tonumber(_towerInfo.cur_level))
end

-- 重置回调
function resetAttackCallback(cbFlag, dictData, bRet)
	if(dictData.err == "ok")then
		-- 减重置次数
		TowerCache.addResetTowerTimes(-1)
		resetAttackRefresh()
	end
end

-- 金币购买重置回调
function resetAttackRefresh()
	AnimationTip.showTip(GetLocalizeStringBy("key_3103"))
	-- 修改当前塔层为1
	TowerCache.changeCurFloorLevel(1)
	-- 修改成未通关
	TowerCache.setCurTowerPassedStatus(false)
	-- 修改挑战次数
	TowerCache.changeAttackTowerTimes(TowerUtil.getMaxFailedTimes())

	handleData()
	_isEnterNextStatus = false

	refreshAttackArr()
	refreshTopUI()
	refreshMainUI()
	createAttackUI()
end

-- 重置代理
function resetConfirmDelegate( isConfirm )
	if(isConfirm == true)then
		RequestCenter.tower_resetTower(resetAttackCallback)
	end
end

-- 重置攻打
function resetAttackAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tonumber(_towerInfo.cur_level)<=1)then
		AnimationTip.showTip(GetLocalizeStringBy("key_1980"))

	elseif(TowerCache.isTowerSweep() == true)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2244"))

	elseif( tonumber(_towerInfo.reset_num) <= 0 )then
		AnimationTip.showTip(GetLocalizeStringBy("key_3304"))
		require "script/ui/tower/TowerDefeatNumTip"
		TowerDefeatNumTip.showAlert()

	else
		AlertTip.showAlert( GetLocalizeStringBy("key_1521"), resetConfirmDelegate, true, nil, GetLocalizeStringBy("key_2864"), GetLocalizeStringBy("key_2326"), nil)

	end
end


-- 扫荡
function swipAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if( TowerCache.isCurTowerHadPassed() ==  true )then
		AnimationTip.showTip(GetLocalizeStringBy("key_2532"))
	elseif(tonumber(_towerInfo.cur_level)>tonumber(_towerInfo.max_level) )then
		AnimationTip.showTip(GetLocalizeStringBy("key_2264"))
	elseif(tonumber(_towerInfo.can_fail_num) <= 0 )then
		-- AnimationTip.showTip(GetLocalizeStringBy("key_2517"))
		-- 攻打次数不足，使用金币购买
		showBuyAttackNumTip()
	else
		require "script/ui/tower/WipeOutLayer"
		WipeOutLayer.showLayer()
	end
end

-- 立即完成
function finishNowAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(canFinish==false)then

	else
		if(TowerCache.isTowerSweep() == true)then
			-- if(UserModel.getGoldNumber()<(tonumber(inputTextCpy)-tonumber(_towerInfo.cur_level)+1)*cp.wipeGold)then
			-- 	-- 金币不足
			-- 	require "script/ui/tip/LackGoldTip"
   --  			LackGoldTip.showTip()
			-- else
				require "script/ui/tower/SweepFinish"
				SweepFinish.showLayer()
			-- end
		else
			require "script/ui/tower/ChooseFinishLayer"
			ChooseFinishLayer.showLayer()
		end
	end
end

function buySecretCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err == "ok")then
		local costInfo = DB_Vip.getDataById(UserModel.getVipLevel()+1)
		local costSplit = string.split(costInfo.callMysicalTower,",")
		_towerInfo = TowerCache.getTowerInfo()
		local tab = string.split(costSplit[tonumber(_towerInfo.buy_special_num)+1],"|")
		-- end
		local cost = -tonumber(tab[2])
		UserModel.addGoldNumber(cost)
		refreshTopUI()
		TowerCache.setTowerInfo(dictData.ret)
		handleData()
		-- local tab = nil
		-- for i=1,#costSplit do


		-- refreshMainUI()
		-- freshData()
	end
end

-- function buyConfirm( tag,itemBtn )
-- 	-- body
-- 	if(UserModel.getGoldNumber()<5)then
-- 		-- 金币不足
-- 		require "script/ui/tip/LackGoldTip"
-- 		LackGoldTip.showTip()
-- 	else
-- 		RequestCenter.buySecretCommond(buySecretCallBack)
-- 	end
-- end

-- 买神秘层
function buySecretAction( tag,itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local costInfo = DB_Vip.getDataById(UserModel.getVipLevel()+1)
	local costSplit = string.split(costInfo.callMysicalTower,",")
	if(#costSplit == 0)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_74"))
		return
	end
	-- local tab = nil
	-- for i=1,#costSplit do
	local tab = string.split(costSplit[tonumber(_towerInfo.buy_special_num)+1],"|")
	-- end
	-- if(tonumber(tab[1])~=1)then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("llp_74"))
	-- 	return
	-- end
	if(tab[2]~=nil)then
		if(tonumber(_towerInfo.max_level)>=10)then
			local buyConfirm = function(is_confirmed, arg)
	            if is_confirmed == true then
	            	-- if(tonumber(tab[1])==1)then
		                if(UserModel.getGoldNumber()<tonumber(tab[2]))then
							-- 金币不足
							require "script/ui/tip/LackGoldTip"
							LackGoldTip.showTip()
						else
							RequestCenter.buySecretCommond(buySecretCallBack)
						end
					-- else
					-- 	AnimationTip.showTip(GetLocalizeStringBy("llp_74"))
					-- end
	            end
	            AlertTip.closeAction()
	        end
			AlertTip.showAlert(GetLocalizeStringBy("llp_71")..tab[2]..GetLocalizeStringBy("llp_72")..tonumber(UserModel.getVipLevel())..GetLocalizeStringBy("llp_79")..#costSplit..GetLocalizeStringBy("llp_80"), buyConfirm, true, nil)
		else
			AnimationTip.showTip(GetLocalizeStringBy("llp_73"))
		end
	else
		AnimationTip.showTip(GetLocalizeStringBy("llp_78"))
	end
end

-- 取消扫荡的回调
-- function cancelSwipCallback(cbFlag, dictData, bRet)
-- 	if(dictData.err=="ok")then
-- 		TowerCache.setTowerInfo(dictData.ret)
-- 		handleData()

-- 		refreshMainUI()
--  		createAttackUI()
--  		refreshSweepBtn()

-- 	end
-- end

-- 扫荡正常结束
function sweepOverCallback( cbFlag, dictData, bRet )
	if(dictData.err=="ok")then

		AnimationTip.showTip(GetLocalizeStringBy("key_1361"))
		TowerCache.setTowerInfo(dictData.ret)
		setSpecialData(dictData.ret.va_tower_info.special_tower.specail_tower_list)
		handleData()

		refreshMainUI()
 		createAttackUI()
 		refreshSweepBtn()
	end
end

-- 取消扫荡
function cancelSwipAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 停止scheduler
	stopScheduler()

	RequestCenter.tower_endSweep(sweepOverCallback)

end

-- 创建主UI
function createMainUI()
	-- 当前层数
	floorSprite = CCSprite:create("images/tower/floorbg.png")
	floorSprite:setAnchorPoint(ccp(0,1))
	floorSprite:setPosition(ccp(20*g_fScaleX, _layerSize.height - (_topBg:getContentSize().height + 10) * g_fScaleX) )
	floorSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(floorSprite)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1763") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleLabel:setAnchorPoint(ccp(0, 0.5))
	titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	titleLabel:setPosition(ccp(60, floorSprite:getContentSize().height*0.5))
	floorSprite:addChild(titleLabel)

	-- 当前层数
	_curFloorLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. _towerInfo.cur_level .. GetLocalizeStringBy("key_2400") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_curFloorLabel:setAnchorPoint(ccp(0, 0.5))
	_curFloorLabel:setColor(ccc3(0x00, 0xe4, 0xff))
	_curFloorLabel:setPosition(ccp(185, floorSprite:getContentSize().height*0.5))
	floorSprite:addChild(_curFloorLabel)

	mainMenuBar = CCMenu:create()
	mainMenuBar:setPosition(ccp(0, 0))
	mainMenuBar:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(mainMenuBar)
	mainMenuBar:setTag(Tag_Menu_Bar)

	mainMenuBarCpy = CCMenu:create()
	mainMenuBarCpy:setPosition(ccp(0, 0))
	mainMenuBarCpy:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(mainMenuBarCpy)
	mainMenuBarCpy:setTag(Tag_SecretMenu_Bar)

	-- 添加试炼梦魇按钮 add by lgx 20160802
	require "script/ui/deviltower/DevilTowerData"
    local itemFileN = (not DevilTowerData.isDevilTowerOpen(false)) and "images/deviltower/btn_deviltower_d.png" or "images/deviltower/btn_deviltower_n.png"
    local itemFileH = (not DevilTowerData.isDevilTowerOpen(false)) and "images/deviltower/btn_deviltower_d.png" or "images/deviltower/btn_deviltower_h.png"
	local devilTowerItem = CCMenuItemImage:create(itemFileN, itemFileH)
	devilTowerItem:setAnchorPoint(ccp(1,1))
	devilTowerItem:setScale(g_fElementScaleRatio)
	devilTowerItem:setPosition(ccp(_layerSize.width-200*g_fScaleX, _layerSize.height-(_topBg:getContentSize().height)*g_fElementScaleRatio))
	devilTowerItem:registerScriptTapHandler(devilTowerCallback)
	mainMenuBar:addChild(devilTowerItem, 1)

	-- 宝箱预览
	local preBoxMenuItem = CCMenuItemImage:create("images/tower/btn_box_n.png", "images/tower/btn_box_h.png")
	preBoxMenuItem:setAnchorPoint(ccp(1,1))
	preBoxMenuItem:setScale(g_fElementScaleRatio)
	preBoxMenuItem:setPosition(ccp(_layerSize.width-90*g_fScaleX, _layerSize.height-(_topBg:getContentSize().height+32)*g_fElementScaleRatio))
	preBoxMenuItem:registerScriptTapHandler(preAndRankAction)
	mainMenuBar:addChild(preBoxMenuItem, 1, Tag_Btn_Reward)

	-- 排行
	local rankMenuItem = CCMenuItemImage:create("images/match/paihang_n.png", "images/match/paihang_h.png")
	rankMenuItem:setAnchorPoint(ccp(1,1))
	rankMenuItem:setScale(g_fElementScaleRatio)
	rankMenuItem:setPosition(ccp(_layerSize.width-10*g_fScaleX, _layerSize.height-(_topBg:getContentSize().height+15)*g_fElementScaleRatio))
	rankMenuItem:registerScriptTapHandler(preAndRankAction)
	mainMenuBar:addChild(rankMenuItem, 1, Tag_Btn_Rank)

	-- 通关条件标题
	local passConditionTittle = CCRenderLabel:create(GetLocalizeStringBy("key_2061") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	passConditionTittle:setAnchorPoint(ccp(0, 1))
	passConditionTittle:setColor(ccc3(0xff, 0xff, 0xff))
	passConditionTittle:setPosition(ccp(20*g_fScaleX, _layerSize.height-160*g_fScaleY))
	passConditionTittle:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(passConditionTittle)
	-- 通关条件
	_passConditionLabel = CCRenderLabel:create(TowerUtil.getPassFloorCondition(_curFloorDesc.star_condition) , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_passConditionLabel:setAnchorPoint(ccp(0, 1))
	_passConditionLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_passConditionLabel:setPosition(ccp(120*g_fScaleX, _layerSize.height-160*g_fScaleY))
	_passConditionLabel:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(_passConditionLabel)

	-- 挑战次数标题
	local timesTittle = CCRenderLabel:create(GetLocalizeStringBy("key_3399") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	timesTittle:setAnchorPoint(ccp(0, 1))
	timesTittle:setColor(ccc3(0xff, 0xff, 0xff))
	timesTittle:setPosition(ccp(20*g_fScaleX, _layerSize.height-190*g_fScaleY))
	timesTittle:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(timesTittle)

	_loveSpiteArr = {}
	_grayLoveSpiteArr = {}

	for i=1, TowerUtil.getMaxFailedTimes() do
		local loveSprite = CCSprite:create("images/tower/love.png")
		loveSprite:setAnchorPoint(ccp(0,1))
		loveSprite:setPosition(ccp(120*g_fScaleX + 35*(i-1)*g_fScaleX, _layerSize.height-195*g_fScaleY))
		loveSprite:setScale(g_fElementScaleRatio)
		_bgLayer:addChild(loveSprite)
		table.insert(_loveSpiteArr, loveSprite)

		local grayLoveSprite = BTGraySprite:create("images/tower/love.png")
		grayLoveSprite:setAnchorPoint(ccp(0,1))
		grayLoveSprite:setPosition(ccp(120*g_fScaleX + 35*(i-1)*g_fScaleX, _layerSize.height-195*g_fScaleY))
		grayLoveSprite:setScale(g_fElementScaleRatio)
		_bgLayer:addChild(grayLoveSprite)
		table.insert(_grayLoveSpiteArr, grayLoveSprite)
	end
	-- 刷新
	refreshAttackArr()


----------- 通关奖励
	-- 背景
	local passAwardSprite = CCSprite:create("images/tower/gray.png")
	passAwardSprite:setAnchorPoint(ccp(0, 1))
	passAwardSprite:setPosition(ccp(0, _layerSize.height-240*g_fScaleY))
	passAwardSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(passAwardSprite)
	local sp_size = passAwardSprite:getContentSize()
	-- 标题
	local tittleSprite = CCSprite:create("images/tower/award.png")
	tittleSprite:setAnchorPoint(ccp(0, 0.5))
	tittleSprite:setPosition(ccp(10, sp_size.height))
	passAwardSprite:addChild(tittleSprite)
	-- 银币
	local silverSprite = CCSprite:create("images/common/coin.png")
	silverSprite:setAnchorPoint(ccp(0.5, 0.5))
	silverSprite:setPosition(ccp(20, 70))
	passAwardSprite:addChild(silverSprite)
	-- 数值
	_rewardSilverLabel = CCLabelTTF:create(_curFloorDesc.silver, g_sFontName, 24)
	_rewardSilverLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_rewardSilverLabel:setAnchorPoint(ccp(0, 0.5))
	_rewardSilverLabel:setPosition(ccp(40, 70))
	passAwardSprite:addChild(_rewardSilverLabel)

	-- 将魂
	local soulSprite = CCSprite:create("images/common/icon_soul.png")
	soulSprite:setAnchorPoint(ccp(0.5, 0.5))
	soulSprite:setPosition(ccp(20, 20))
	passAwardSprite:addChild(soulSprite)
	-- 数值
	local soul_num = _curFloorDesc.soul or 0
	_rewardSoulLabel = CCLabelTTF:create(soul_num, g_sFontName, 24)
	_rewardSoulLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_rewardSoulLabel:setAnchorPoint(ccp(0, 0.5))
	_rewardSoulLabel:setPosition(ccp(40, 20))
	passAwardSprite:addChild(_rewardSoulLabel)

----- 特殊奖励
	createFloorReward()

--创建神秘层
	_secretTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2119"), g_sFontPangWa, 18)
	local secretItem = CCMenuItemImage:create("images/tower/secret1.png", "images/tower/secret.png")


	-- showSecret()

---- 重置和扫荡
	-- 重置
	-- resetBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1040"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- resetBtn:setAnchorPoint(ccp(0.5, 0))
	-- resetBtn:setScale(g_fElementScaleRatio)
 --    resetBtn:setPosition(ccp(_layerSize.width*0.5, 60*g_fScaleY))
 --    resetBtn:registerScriptTapHandler(resetAttackAction)
	-- mainMenuBar:addChild(resetBtn)
	-- -- 剩余重置次数
	-- _leftResetTimesLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3056") .. _towerInfo.reset_num, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- _leftResetTimesLabel:setAnchorPoint(ccp(0.5, 1))
	-- _leftResetTimesLabel:setColor(ccc3(0x00, 0xff, 0x18))
	-- _leftResetTimesLabel:setPosition(ccp(resetBtn:getContentSize().width*0.5, 0))
	-- resetBtn:addChild(_leftResetTimesLabel)


	-- 扫荡
	swipBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1143"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	swipBtn:setAnchorPoint(ccp(0.5, 0))
	swipBtn:setScale(g_fElementScaleRatio)
    swipBtn:setPosition(ccp(_layerSize.width*0.8, 60*g_fScaleY))
    swipBtn:registerScriptTapHandler(swipAction)
	mainMenuBar:addChild(swipBtn)

	-- 立即完成
	finishBtn = nil
	if(tonumber(_towerInfo.cur_level)>=tonumber(_towerInfo.max_level))then
		canFinish = false
		finishBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_hui.png","images/common/btn/btn_hui.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		canFinish = true
		finishBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_64"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	finishBtn:setAnchorPoint(ccp(0.5, 0))
	finishBtn:setScale(g_fElementScaleRatio)
    finishBtn:setPosition(ccp(_layerSize.width*0.5, 60*g_fScaleY))
    finishBtn:registerScriptTapHandler(finishNowAction)
	mainMenuBar:addChild(finishBtn)

	buySecretBtn = CCMenuItemImage:create("images/tower/buysecret_n.png","images/tower/buysecret_h.png")
	mainMenuBar:addChild(buySecretBtn)
	buySecretBtn:setScale(g_fElementScaleRatio)
	buySecretBtn:setAnchorPoint(ccp(1,0.5))
	buySecretBtn:setPosition(ccp(135*g_fScaleX,_layerSize.height-580*g_fScaleY))
	buySecretBtn:registerScriptTapHandler(buySecretAction)
	-- goldSpriteIcon = CCSprite:create("images/common/gold.png")
	-- finishBtn:addChild(goldSpriteIcon)
	-- goldSpriteIcon:setAnchorPoint(ccp(1,0))
	-- goldSpriteIcon:setPosition(ccp(finishBtn:getContentSize().width*0.5,-goldSpriteIcon:getContentSize().height))

	-- cp = DB_Tower.getDataById(1)
	-- finishCostLabel = CCLabelTTF:create((_towerInfo.max_level-_towerInfo.cur_level+1)*cp.wipeGold, g_sFontName, 24)
	-- finishCostLabel:setColor(ccc3(0x00, 0xff, 0x18))
	-- finishCostLabel:setAnchorPoint(ccp(0,0))
	-- finishCostLabel:setPosition(ccp(finishBtn:getContentSize().width*0.5,-goldSpriteIcon:getContentSize().height))
	-- finishBtn:addChild(finishCostLabel)
	-- print("i am in 3")

	-- 取消扫荡
	cancelSwipBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3226"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelSwipBtn:setAnchorPoint(ccp(0.5, 0))
	cancelSwipBtn:setScale(g_fElementScaleRatio)
    cancelSwipBtn:setPosition(ccp(_layerSize.width*0.8, 60*g_fScaleY))
    cancelSwipBtn:registerScriptTapHandler(cancelSwipAction)
	mainMenuBar:addChild(cancelSwipBtn)

	_sweepRestTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3173"), g_sFontName, 24)
	_sweepRestTimeLabel:setColor(ccc3(0xf2, 0x0f, 0x0f))
	_sweepRestTimeLabel:setAnchorPoint(ccp(0.5, 1))
	_sweepRestTimeLabel:setPosition(ccp(cancelSwipBtn:getContentSize().width*0.5, 0))
	cancelSwipBtn:addChild(_sweepRestTimeLabel)

	-- 刷新扫荡按钮的状态
	refreshSweepBtn()
	refreshMainUI()
end

--神秘层图标创建函数
function showSecret()
	-- body
	--神秘层
	_towerInfo = TowerCache.getTowerInfo()
	_secretNum = 0
	print("heiyou")
	print_t(_towerInfo.va_tower_info.special_tower)
	print("heiyou")
	if(TowerCache.haveSceretTower()==true)then
		if(_towerInfo.va_tower_info.special_tower ~= nil)then
			if(not table.isEmpty(_towerInfo.va_tower_info.special_tower.specail_tower_list))then
				for k,v in pairs (_towerInfo.va_tower_info.special_tower.specail_tower_list) do
					print("我进来了我操")
					_secretNum = _secretNum + 1
				end
			end
		end
	end
	if(_secretNum ~= 0)then
		secretItem = CCMenuItemImage:create("images/tower/secret1.png", "images/tower/secret.png")
		secretItem:setPosition(ccp(20*g_fScaleX,_layerSize.height-510*g_fScaleY))
		secretItem:registerScriptTapHandler(preAndRankAction)
		secretItem:setScale(g_fElementScaleRatio)
		mainMenuBarCpy = _bgLayer:getChildByTag(Tag_SecretMenu_Bar)

		if(mainMenuBarCpy ~= nil)then
			mainMenuBarCpy:addChild(secretItem, 1, Tag_Btn_Secret)
		else
			mainMenuBarCpy = CCMenu:create()
			mainMenuBarCpy:setPosition(ccp(0, 0))
			mainMenuBarCpy:setAnchorPoint(ccp(0,0))
			_bgLayer:addChild(mainMenuBarCpy)
			mainMenuBarCpy:setTag(Tag_SecretMenu_Bar)
			mainMenuBarCpy:addChild(secretItem, 1, Tag_Btn_Secret)
		end

		-- for k,v in pairs (_specialData) do
		-- 	_secretCount = _secretCount + 1
		-- end
		if(_tipSprite == nil)then
			_tipSprite=ItemDropUtil.getTipSpriteByNum(_secretNum)
			_tipSprite:setPosition(ccp(secretItem:getContentSize().width*0.97, secretItem:getContentSize().height*0.98))
			_tipSprite:setAnchorPoint(ccp(1,1))
			_tipSprite:setVisible(true)
			secretItem:addChild(_tipSprite,11)
		else
			-- _tipSprite:setVisible(false)
			secretItem:removeChild(_tipSprite,true)
	    	_tipSprite=ItemDropUtil.getTipSpriteByNum(_secretNum)
			_tipSprite:setPosition(ccp(secretItem:getContentSize().width*0.97, secretItem:getContentSize().height*0.98))
			_tipSprite:setAnchorPoint(ccp(1,1))
			_tipSprite:setVisible(true)
			secretItem:addChild(_tipSprite,11)
	    end
	else
		mainMenuBarCpy = _bgLayer:getChildByTag(Tag_SecretMenu_Bar)
		if(mainMenuBarCpy~=nil)then
			mainMenuBarCpy:setVisible(false)
			secretItem = nil
			_bgLayer:removeChild(mainMenuBarCpy,true)
			mainMenuBarCpy = nil
		end
		if(secretItem~=nil)then
			secretItem:setVisible(false)
		end
	end
end

-- 第几层的按钮
function getFloorItemByFloor( curFloor )
	local sprite_n = CCSprite:create("images/tower/btn_floor_n.png")
	local sprite_h = CCSprite:create("images/tower/btn_floor_h.png")
	local floorLabel_n = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. curFloor .. GetLocalizeStringBy("key_2400") , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	floorLabel_n:setAnchorPoint(ccp(0.5, 0.5))
	floorLabel_n:setColor(ccc3(0xff, 0xf6, 0x00))
	floorLabel_n:setPosition(ccp(sprite_n:getContentSize().width*0.5, 0))
	sprite_n:addChild(floorLabel_n)

	local floorLabel_h = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. curFloor .. GetLocalizeStringBy("key_2400") , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	floorLabel_h:setAnchorPoint(ccp(0.5, 0.5))
	floorLabel_h:setColor(ccc3(0xff, 0xf6, 0x00))
	floorLabel_h:setPosition(ccp(sprite_n:getContentSize().width*0.5, 0))
	sprite_h:addChild(floorLabel_h)

	local menuItemBtn = CCMenuItemSprite:create(sprite_n, sprite_h)
	menuItemBtn:setScale(g_fElementScaleRatio)

	return menuItemBtn
end

-- 战斗回调
function doBattleCallback(  newData, isVictory, extra_reward )
	local isPassed = false

	if (newData) then
		if( newData.pass and (newData.pass == "true" or newData.pass==true) )then
			isPassed = true
		end
		--LLP ADD 2014-4-16
	 	if(not table.isEmpty(newData.tower_info) and newData.tower_info.va_tower_info.special_tower.specail_tower_list~=nil)then
			TowerCache.setSpeTowerInfo(newData.tower_info.va_tower_info.special_tower.specail_tower_list)
		end
	 	freshData()
 	--
	end
	if(isPassed == true)then

		removeFloorReward()
		if(_curFloorDesc.isShow ~= nil and _curFloorDesc.isShow == 1)then
			TowerRewardLayer.showRewardWindow(tonumber(_towerInfo.cur_level), true)
		end
		_isEnterNextStatus = true

		if( tonumber(_towerInfo.cur_level) == TowerUtil.getMaxTower() ) then
			TowerCache.setCurTowerPassedStatus(true)
		end
		TowerCache.addCurFloorLevel(1)
		if(newData.tower_info~=nil)then
			setSpecialData(newData.tower_info.va_tower_info.special_tower.specail_tower_list)
		end
		handleData()
		createAttackUI()
		refreshTopUI()
	elseif(isPassed == false)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2935") .. TowerUtil.getPassFloorCondition(_curFloorDesc.star_condition) )
		TowerCache.addAttackTowerTimes(-1)
		_towerInfo = TowerCache.getTowerInfo()
		refreshAttackArr()
	end
end

--设置strongid
function setStrongId( id )
	strongId = id
	-- body
end

--获取strongid
function getStrongId()
	return strongId
	-- body
end

--LLP ADD 2014-4-16
-- 神秘塔层战斗回调
function doSecretBattleCallback(  newData, isVictory, extra_reward )

	local isPassed = false
	if (newData) then
		if( newData.pass and (newData.pass == "true" or newData.pass == true)  )then
			isPassed = true
		end

		strongId = getStrongId()

		for k,v in pairs (_towerInfo.va_tower_info.special_tower.specail_tower_list) do
			if(tonumber(k)==tonumber(strongId))then
				local countryId = DB_Stronghold.getDataById(v[1])
    			cost = countryId.cost_energy_simple;
			end

    	end

	if(not table.isEmpty(newData.tower_info) and newData.tower_info.va_tower_info.special_tower.specail_tower_list~=nil)then
		TowerCache.setSpeTowerInfo(newData.tower_info.va_tower_info.special_tower.specail_tower_list)
	end
 	-- RequestCenter.tower_getTowerInfo(getTowerInfoCallback)
 	freshData()
	end
	if(isPassed == true)then
		local power = UserModel.getEnergyValue()
		if(power>=cost)then
			UserModel.addEnergyValue(-cost)
		end
		handleData()
		refreshTopUI()
	elseif(isPassed == false)then
		local power = UserModel.getEnergyValue()
		if(power>=cost)then
			UserModel.addEnergyValue(-cost)
		end
		refreshTopUI()
		_towerInfo = TowerCache.getTowerInfo()
		setSpecialData(_towerInfo.va_tower_info.special_tower.specail_tower_list)
	end
end
--

-- 攻打下一层
function attackNextAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 背包已满
	if(ItemUtil.isBagFull() == true )then
		return
	end
	if(TowerCache.isTowerSweep() == true)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2992"))

	elseif( tonumber(_towerInfo.can_fail_num) <= 0) then
		-- AnimationTip.showTip(GetLocalizeStringBy("key_1872"))

		-- 攻打次数不足，使用金币购买
		showBuyAttackNumTip()
	elseif( TowerCache.isCurTowerHadPassed() == true )then
		AnimationTip.showTip(GetLocalizeStringBy("key_1677"))

	elseif(UserModel.getHeroLevel()<_curFloorDesc.needLevel)then
		AnimationTip.showTip(GetLocalizeStringBy("key_1468"))

	else
		require "script/battle/BattleLayer"
		BattleLayer.enterBattle(_curFloorDesc.id, _curFloorDesc.stronghold, 0, doBattleCallback, 4,false)
	end

end

-- 购买攻打次数回调
function buyDefeatNumCallback( cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		local gold_num = tonumber(dictData.ret)
		UserModel.addGoldNumber(-gold_num)
		TowerCache.addBuyDefeatNumByGold(1)
		TowerCache.addAttackTowerTimes(1)
		refreshTopUI()
		refreshAttackArr()
		AnimationTip.showTip(GetLocalizeStringBy("key_2277"))
	end
end

-- 是否购买
function confirmCBFunc()

	if( UserModel.getGoldNumber() < TowerUtil.getCostGoldByTimes(tonumber(_towerInfo.gold_buy_num)+1))then
		-- 金币不足
		require "script/ui/tip/LackGoldTip"
    	LackGoldTip.showTip()
	else
		RequestCenter.tower_buyDefeatNum(buyDefeatNumCallback)
	end

end

-- 攻打次数不足，使用金币购买
function showBuyAttackNumTip()
	if(TowerUtil.getMaxBuyDefeatTimes() <= tonumber(_towerInfo.gold_buy_num))then
		AnimationTip.showTip(GetLocalizeStringBy("key_3379"))
	else
		require "script/ui/tip/AlertTipGold"
		AlertTipGold.showAlert( GetLocalizeStringBy("key_1949"), TowerUtil.getCostGoldByTimes(tonumber(_towerInfo.gold_buy_num)+1), confirmCBFunc)
	end
end

-- 进入下一层
function enterNextAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(TowerCache.isTowerSweep() == true)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2992"))
		return
	end
	_isEnterNextStatus = false
	if( TowerCache.isCurTowerHadPassed() == true )then
		AnimationTip.showTip(GetLocalizeStringBy("key_1677"))
		return
 	end
 	if(_attackOrEnterMenuBar)then
	 	_attackOrEnterMenuBar:removeFromParentAndCleanup(true)
	 	_attackOrEnterMenuBar = nil
	end
 	-- 特效特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/tower/bao"), 1,CCString:create(""));
    spellEffectSprite:setScale(g_fElementScaleRatio)
    spellEffectSprite:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
   	_bgLayer:addChild(spellEffectSprite,9999);

    local animationEnd = function(actionName,xmlSprite)
    	spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)
        -- 黑色转场
        refreshMainUI()
	 	createAttackUI()
	 	refreshTopUI()
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)

    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)


end

-- 普通
local function showAnimation_n( k_type, imageIcon )
	k_type = tonumber(k_type)
	local animationNameType = nil
	if(k_type == 1) then
		animationNameType = "fbjdmu"
	elseif(k_type == 2) then
		animationNameType = "fbjdying"
	elseif(k_type == 3) then
		animationNameType = "fbjdjin"
	end

	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/" .. animationNameType), -1,CCString:create(""));

    --替换头像
    local replaceXmlSprite = tolua.cast( spellEffectSprite:getChildByTag(1002) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create("images/base/hero/head_icon/" .. imageIcon))

    spellEffectSprite:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
    spellEffectSprite:setAnchorPoint(ccp(0, 0));
    spellEffectSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(spellEffectSprite,9999);

    --delegate
    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
    	spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)

        if(_attackTowerBtn~=nil)then
        	tolua.cast(_attackTowerBtn,"CCMenuItemSprite")
        	_attackTowerBtn:setVisible(true)
        end
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)

    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)
end

-- 特殊
local function showAnimation_s( k_type, imageIcon )
	k_type = tonumber(k_type)
	local animationNameType = nil
	if(k_type == 1) then
		animationNameType = "tong_bg.png"
	elseif(k_type == 2) then
		animationNameType = "yin_bg.png"
	elseif(k_type == 3) then
		animationNameType = "jin_bg.png"
	end

	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/tower/kapaixialuo"), 1,CCString:create(""));
	spellEffectSprite:setScale(g_fElementScaleRatio)
    --替换头像
    local replaceXmlSprite = tolua.cast( spellEffectSprite:getChildByTag(1001) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create("images/match/" .. animationNameType))

    spellEffectSprite:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
    spellEffectSprite:setAnchorPoint(ccp(0, 0))
    _bgLayer:addChild(spellEffectSprite,9999)

    --delegate
    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
    	spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)

        if(_attackTowerBtn~=nil)then
        	tolua.cast(_attackTowerBtn,"CCMenuItemSprite")
        	_attackTowerBtn:setVisible(true)
        end
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        if(frameIndex == 1)then
        	require "script/battle/BattleCardUtil"
		    local icon_sp_h = BattleCardUtil.getFormationPlayerCard(111111111,nil, imageIcon)
		    icon_sp_h:setAnchorPoint(ccp(0.5, 0))
		    icon_sp_h:setPosition(ccp(82 ,35))
		    replaceXmlSprite:addChild(icon_sp_h)
        end
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)
end

-- 攻打的UI
function createAttackUI()

	if(_attackOrEnterMenuBar)then
		_attackOrEnterMenuBar:removeFromParentAndCleanup(true)
		_attackOrEnterMenuBar = nil
	end
	if(_spellEffectSprite)then
		_spellEffectSprite:removeFromParentAndCleanup(true)
		_spellEffectSprite = nil
	end

	_attackOrEnterMenuBar = CCMenu:create()
	_attackOrEnterMenuBar:setAnchorPoint(ccp(0,0))
	_attackOrEnterMenuBar:setPosition(ccp(0,0))
	_bgLayer:addChild(_attackOrEnterMenuBar)

	if(TowerCache.isCurTowerHadPassed()==true)then

		-- 已通关特效
		_spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/tower/yitongguan"), -1,CCString:create(""));
	    _spellEffectSprite:retain()
        _spellEffectSprite:setScale(g_fElementScaleRatio)
	    _spellEffectSprite:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
	    _bgLayer:addChild(_spellEffectSprite,999);
	    _spellEffectSprite:release()

	elseif(_isEnterNextStatus == true)then
		-- 进入
		local enterSprite = CCSprite:create()
		enterSprite:setContentSize(CCSizeMake(80, 150))
		_enterNextBtn = CCMenuItemSprite:create(enterSprite, enterSprite)
		_enterNextBtn:setAnchorPoint(ccp(0.5, 0))
		_enterNextBtn:setScale(g_fElementScaleRatio)
		_enterNextBtn:registerScriptTapHandler(enterNextAction)
		_enterNextBtn:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
		_attackOrEnterMenuBar:addChild(_enterNextBtn)

		-- 特效特效
		local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/tower/xiayiguan"), -1,CCString:create(""));
	    spellEffectSprite:retain()
	    spellEffectSprite:setPosition(_enterNextBtn:getContentSize().width/2,0)
	    _enterNextBtn:addChild(spellEffectSprite,-1);
	    spellEffectSprite:release()


	else
		TowerUtil.showBlackFadeLayer()
		-- 攻打
		local m_type = _curFloorDesc.monsterType or 1
		local m_potential = _curFloorDesc.monsterQuality or 1

		_attackTowerBtn = TowerUtil.getFloorItem(m_type, m_potential, _curFloorDesc.monsterModel, _curFloorDesc.name) -- CCMenuItemImage:create("images/tower/btn_floor_n.png", "images/tower/btn_floor_h.png")
		_attackTowerBtn:retain()
		_attackTowerBtn:setAnchorPoint(ccp(0.5, 0))
		_attackTowerBtn:registerScriptTapHandler(attackNextAction)
		_attackTowerBtn:setPosition(ccp(_layerSize.width*x_rate, _layerSize.height*y_rate))
		_attackTowerBtn:setScale(g_fElementScaleRatio)
		_attackOrEnterMenuBar:addChild(_attackTowerBtn)

		if(TowerCache.isTowerSweep() == true)then
			AnimationTip.showTip(GetLocalizeStringBy("key_1676") .. _towerInfo.cur_level ..  GetLocalizeStringBy("key_2400"))
		end

		local topEffectPath = nil
		local bottomEffectPath = nil
		local yScale = 1
		if(m_type == 1)then
			bottomEffectPath = "images/base/effect/copy/fubenkegongji01"
			topEffectPath = "images/base/effect/copy/fubenkegongji02"
			yScale = 1.1
		else
			bottomEffectPath = "images/base/effect/tower/yuanpan"
			topEffectPath = "images/base/effect/tower/guangbiao"
			yScale = 1.5
		end

		-- 下部特效
		local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(bottomEffectPath), -1,CCString:create(""));
	    spellEffectSprite:retain()
	    spellEffectSprite:setPosition(_attackTowerBtn:getContentSize().width/2,0)
	    _attackTowerBtn:addChild(spellEffectSprite,-1);
	    spellEffectSprite:release()
	    -- 上部特效
	    local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create(topEffectPath), -1,CCString:create(""));
	    spellEffectSprite_2:retain()
	    spellEffectSprite_2:setPosition(_attackTowerBtn:getContentSize().width*0.5, _attackTowerBtn:getContentSize().height * yScale)
	    _attackTowerBtn:addChild(spellEffectSprite_2,1);
	    spellEffectSprite_2:release()

	    _attackTowerBtn:setVisible(false)
	    if( m_type == 1)then
		    showAnimation_n( m_potential, _curFloorDesc.monsterModel )
		else
		    showAnimation_s( m_potential, _curFloorDesc.monsterModel )
		end
	end
end

-- 创建特殊层的奖励按钮
function createFloorReward()
	if(_floorRewardMenuBar)then
		_floorRewardMenuBar:removeFromParentAndCleanup(true)
		_floorRewardMenuBar = nil
	end

	if(_curFloorDesc.isShow ~= nil and _curFloorDesc.isShow == 1 )then
		_floorRewardMenuBar = CCMenu:create()
		_floorRewardMenuBar:setAnchorPoint(ccp(0,0))
		_floorRewardMenuBar:setPosition(ccp(0,0))
		_bgLayer:addChild(_floorRewardMenuBar)

		--- 特殊奖励
		local floorRewardBtn = getFloorItemByFloor(_towerInfo.cur_level)
		floorRewardBtn:setAnchorPoint(ccp(0,1))
		floorRewardBtn:setScale(g_fElementScaleRatio)
		floorRewardBtn:setPosition(ccp(150*g_fElementScaleRatio, _layerSize.height-260*g_fScaleY))
		floorRewardBtn:registerScriptTapHandler(floorRewardAction)
		_floorRewardMenuBar:addChild(floorRewardBtn)
	end
end

-- 删除特殊层奖励
function removeFloorReward()
	if(_floorRewardMenuBar)then
		_floorRewardMenuBar:removeFromParentAndCleanup(true)
		_floorRewardMenuBar = nil
	end
end

-- 创建UI
function createUI()
	createTopUI()
	createMainUI()
	-- 攻打的UI
	createAttackUI()
end

-- 处理数据
function handleData()
	_towerInfo = TowerCache.getTowerInfo()
	print("_towerInfo.cur_level==",_towerInfo.cur_level)
	_curFloorDesc = TowerUtil.getTowerFloorDescBy(_towerInfo.cur_level)
	_secretNum = 0

	if(not table.isEmpty(_towerInfo.va_tower_info.special_tower.specail_tower_list))then
		for k,v in pairs (_towerInfo.va_tower_info.special_tower.specail_tower_list) do
			_secretNum = _secretNum + 1
		end
	end
	-- if(_secretNum ~= 0)then
		setSpecialData(_towerInfo.va_tower_info.special_tower.specail_tower_list)
		showSecret()
	-- else
	-- 	setSpecialData(_towerInfo.va_tower_info.special_tower.specail_tower_list)
	-- 	showSecret()
	-- end
end

-- 回调
function getTowerInfoCallback( cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		if(not table.isEmpty(dictData.ret))then
			TowerCache.setTowerInfo(dictData.ret)
			-- startSecretScheduler()
			if(TowerCache.isTowerSweep()==true)then
				handleSweepData()

			else
				handleData()
			end

			-- 创建UI
			createUI()

			if(TowerCache.isTowerSweep()==true )then
				-- 开始启动
				startScheduler()
			end
		end
	end
end

-- 处理扫荡的数据
function handleSweepData()
	TowerCache.changeCurSweepFloor()
	handleData()
end

-- 扫荡代理
function startSweepDelegate(inputText)
	inputTextCpy = tonumber(inputText)
	_isEnterNextStatus = false
	handleSweepData()
	refreshSweepBtn()
	AnimationTip.showTip(GetLocalizeStringBy("key_2384"))
	if(TowerCache.isTowerSweep()==true )then
		-- 开始启动
		startScheduler()
	end
end

-- 创建layer
function createLayer()
	init()
	MainScene.getAvatarLayerObj():setVisible(false)
	MenuLayer.getObject():setVisible(true)
	BulletinLayer.getLayer():setVisible(true)

	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local avatarLayerSize = MainScene.getAvatarLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = CCSizeMake(g_winSize.width, g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX)

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setContentSize(_layerSize)
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

	local bgSprite = CCSprite:create("images/tower/tower_bg.png")
	bgSprite:setScale(g_fBgScaleRatio)
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_layerSize.width/2,_layerSize.height/2))
	_bgLayer:addChild(bgSprite)

	-- 获取信息
	RequestCenter.tower_getTowerInfo(getTowerInfoCallback)

	-- 创建UI
	-- createUI()

	return _bgLayer
end

--[[
	@desc	: 点击试炼梦魇按钮回调，进入试炼梦魇
    @param	: 
    @return	: 
—-]]
function devilTowerCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 进入试炼梦魇
	-- print("devilTowerCallback => 进入试炼梦魇")
	require "script/ui/deviltower/DevilTowerLayer"
	DevilTowerLayer.showLayer()
end

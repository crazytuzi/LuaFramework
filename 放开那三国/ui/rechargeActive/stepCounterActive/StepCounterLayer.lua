-- Filename：	StepCounterLayer.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-11
-- Purpose：		计步活动界面

module ("StepCounterLayer", package.seeall)

require "script/ui/rechargeActive/stepCounterActive/StepCounterService"
require "script/ui/rechargeActive/stepCounterActive/StepCounterData"
require "script/ui/tip/AnimationTip"
require "script/utils/BaseUI"
require "script/utils/TimeUtil"
require "script/ui/item/ItemUtil"
require "script/ui/rechargeActive/stepCounterActive/StepTableView"
require "script/ui/item/ReceiveReward"

local _bgLayer
local _haveRewardMenuItem 		--已领奖按钮
local _rewardMenuItem 			--领奖按钮
local _banMenuItem 				--不能领奖按钮
local _haveReward 				--是否已经领奖
local _tip_6 					--累积步数
local _tip_7 					--累积在线时间

local _tempCounts  				--用于计时器，因为计步活动要5秒刷一次

----------------------------------------初始化函数----------------------------------------
local function init()
	_bgLayer = nil
	_haveRewardMenuItem = nil
	_rewardMenuItem = nil
	_banMenuItem = nil
	_tip_6 = nil
	_tip_7 = nil
	_haveReward = false
	_tempCounts = 0
end

----------------------------------------节点事件函数----------------------------------------
local function onNodeEvent(event)
	if event == "exit" then
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:按钮回调
	@param 	:按钮tag值
	@return :
--]]
function rewardCallBack(tag)
	--已领取
	if tag == 1 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1141"))
	--可领取
	elseif tag == 2 then
		--如果背包没满
		if not ItemUtil.isBagFull() then
			local rewardCallBack = function()
				--改变按钮可见
				changeMenuVisible(1)
				--弹出恭喜您活动窗口
				ReceiveReward.showRewardWindow(StepCounterData.getCurDayGift())
			end
			StepCounterService.recReward(rewardCallBack)
		end
	--不可领取
	else
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1142"))
	end
end

--[[
	@des 	:按钮显示控制
	@param 	:控制类型
			 1 领奖结束 		2 可以领奖 
	@return :
--]]
function changeMenuVisible(p_kind)
	if p_kind == 1 then
		_rewardMenuItem:setVisible(false)
		_haveRewardMenuItem:setVisible(true)
		_haveReward = true
		--重置奖励领取
		StepCounterData.setWetherReward()
	else
		_rewardMenuItem:setVisible(true)
		_banMenuItem:setVisible(false)
	end
end

--[[
	@des 	:更新时间函数
	@param 	:
	@return :
--]]
function updateTimeFunc()
	_tempCounts = _tempCounts + 1
	print("_tempCounts===", _tempCounts)
	if( _tempCounts%1 == 0 )then
		--得到当前已走的步数
		local stepNum =  StepCounterData.getStepNum() --StepCounterData.configStep()  注释部分为朱波录视频用
		print("stepNum==StepCounterData.configStep()=", stepNum, StepCounterData.configStep())
		--修改UI显示
		_tip_6:setString(stepNum)

		--如果大于等于可领奖步数
		if (tonumber(stepNum) >= tonumber(StepCounterData.configStep())) and (_haveReward == false) then
			--领奖按钮可见
			changeMenuVisible(2)
		end
	end
	
	_tip_7:setString(StepCounterData.transFormConfigTime(StepCounterData.getAccumulateTime()))

	if (StepCounterData.getAccumulateTime() >= tonumber(StepCounterData.configTime())) and (_haveReward == false) then
		--领奖按钮可见
		changeMenuVisible(2)
	end
	
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建上部红色背景框UI
	@param 	:$ p_middleHeight 	:中部高度
			 $ p_beginPosY		:红框高度开始Y位置
	@return :
--]]
function createUpperBg(p_middleHeight,p_redPosY)
	local wideX = g_winSize.width*370/640

	--红色描述框背景
	local redBgSprite = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
	redBgSprite:setPreferredSize(CCSizeMake(g_winSize.width*400/640,p_middleHeight*275/655))
	redBgSprite:setAnchorPoint(ccp(0.5,1))
	redBgSprite:setPosition(ccp(wideX,p_redPosY))
	_bgLayer:addChild(redBgSprite)

	--N多条描述
	--=================================================第一条
	local tip_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1143"),g_sFontName,21)
	tip_1:setColor(ccc3(0xff,0xf6,0x00))
	local pic_1 = CCSprite:create("images/recharge/stepCounter/pic_1.png")

	local node_1 = BaseUI.createHorizontalNode({tip_1,pic_1})
	node_1:setAnchorPoint(ccp(0.5,0.5))
	node_1:setPosition(ccp(wideX,p_redPosY - p_middleHeight*25/655))
	node_1:setScale(MainScene.elementScale)
	_bgLayer:addChild(node_1)

	--=================================================第二条
	local tip_2 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1144") .. StepCounterData.configStep() .. GetLocalizeStringBy("zzh_1145") .. StepCounterData.transFormConfigTime(StepCounterData.configTime()) .. GetLocalizeStringBy("zzh_1146"),g_sFontName,21)
	tip_2:setColor(ccc3(0xff,0xf6,0x00))
	tip_2:setAnchorPoint(ccp(0.5,0.5))
	tip_2:setPosition(ccp(wideX,p_redPosY - p_middleHeight*60/655))
	tip_2:setScale(MainScene.elementScale)
	_bgLayer:addChild(tip_2)

	--=================================================第三条
	local pic_2 = CCSprite:create("images/recharge/stepCounter/pic_2.png")
	local tip_3 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1147"),g_sFontName,21)
	tip_3:setColor(ccc3(0xff,0xf6,0x00))
	local pic_3 = CCSprite:create("images/recharge/stepCounter/pic_3.png")

	local node_2 = BaseUI.createHorizontalNode({pic_2,tip_3,pic_3})
	node_2:setAnchorPoint(ccp(0.5,0.5))
	node_2:setPosition(ccp(wideX,p_redPosY - p_middleHeight*95/655))
	node_2:setScale(MainScene.elementScale)
	_bgLayer:addChild(node_2)

	--=================================================第四条
	local pic_4 = CCSprite:create("images/recharge/stepCounter/pic_4.png")
	_tip_6 = CCRenderLabel:create(StepCounterData.getStepNum(),g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_tip_6:setColor(ccc3(0x00,0xff,0x18))
	local node_3 = BaseUI.createHorizontalNode({pic_4,_tip_6})
	node_3:setAnchorPoint(ccp(0.5,0.5))
	node_3:setPosition(ccp(wideX,p_redPosY - p_middleHeight*140/655))
	node_3:setScale(MainScene.elementScale)
	_bgLayer:addChild(node_3)

	--=================================================第五条
	local tip_4 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1148"),g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	tip_4:setColor(ccc3(0xff,0xf6,0x00))
	_tip_7 = CCRenderLabel:create(StepCounterData.transFormConfigTime(StepCounterData.getAccumulateTime()),g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_tip_7:setColor(ccc3(0xff,0xf6,0x00))
	local node_4 = BaseUI.createHorizontalNode({tip_4,_tip_7})
	node_4:setAnchorPoint(ccp(0.5,0.5))
	node_4:setPosition(ccp(wideX,p_redPosY - p_middleHeight*185/655))
	node_4:setScale(MainScene.elementScale)
	_bgLayer:addChild(node_4)

	--=================================================第六条
	local tip_5 = CCRenderLabel:create(GetLocalizeStringBy("lcy_10029"),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	tip_5:setColor(ccc3(0xff,0xff,0xff))
	local beginDay = CCRenderLabel:create(TimeUtil.getTimeForDayTwo(StepCounterData.getStartTime()),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	beginDay:setColor(ccc3(0x00,0xff,0x18))
	local toLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2358"),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	toLabel:setColor(ccc3(0x00,0xff,0x18))
	local endDay = CCRenderLabel:create(TimeUtil.getTimeForDayTwo(StepCounterData.getEndTime()),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	endDay:setColor(ccc3(0x00,0xff,0x18))
	local node_5 = BaseUI.createHorizontalNode({tip_5,beginDay,toLabel,endDay})
	node_5:setAnchorPoint(ccp(0.5,0.5))
	node_5:setPosition(ccp(wideX,p_redPosY - p_middleHeight*220/655))
	node_5:setScale(MainScene.elementScale)
	_bgLayer:addChild(node_5)

	--=================================================第七条
	local pic_5 = CCSprite:create("images/recharge/stepCounter/pic_5.png")
	pic_5:setAnchorPoint(ccp(0.5,0.5))
	pic_5:setPosition(ccp(wideX,p_redPosY - p_middleHeight*250/655))
	pic_5:setScale(MainScene.elementScale)
	_bgLayer:addChild(pic_5)

	--定时器
	schedule(_bgLayer,updateTimeFunc,1)
end

--[[
	@des 	:创建下部奖励预览框
	@param 	:框Y轴位置
	@return :
--]]
function createPreViewBg(p_beginPosY)
	--奖励预览背景
	local previewBgSprite = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	previewBgSprite:setPreferredSize(CCSizeMake(630,255))
	previewBgSprite:setAnchorPoint(ccp(0.5,0))
	previewBgSprite:setPosition(ccp(g_winSize.width/2,p_beginPosY + 10*MainScene.elementScale))
	previewBgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(previewBgSprite)

	--标题背景
	local underBgSprite = CCScale9Sprite:create(CCRectMake(86, 32, 4, 3),"images/recharge/vip_benefit/everyday.png")
	underBgSprite:setPreferredSize(CCSizeMake(380,68))
	underBgSprite:setAnchorPoint(ccp(0.5,0.5))
	underBgSprite:setPosition(ccp(previewBgSprite:getContentSize().width/2,previewBgSprite:getContentSize().height - 3))
	previewBgSprite:addChild(underBgSprite)

	--下部标题
	local previewTitleSprite = CCSprite:create("images/recharge/stepCounter/under_title.png")
	previewTitleSprite:setAnchorPoint(ccp(0.5,0.5))
	previewTitleSprite:setPosition(ccp(underBgSprite:getContentSize().width/2,underBgSprite:getContentSize().height/2))
	underBgSprite:addChild(previewTitleSprite)

	--奖励预览二级背景
	local secondBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondBgSprite:setPreferredSize(CCSizeMake(605,145))
	secondBgSprite:setAnchorPoint(ccp(0.5,1))
	secondBgSprite:setPosition(ccp(previewBgSprite:getContentSize().width/2,previewBgSprite:getContentSize().height - underBgSprite:getContentSize().height/2 - 3))
	previewBgSprite:addChild(secondBgSprite)

	--奖励预览TableView
	local previewTableView = StepTableView.createTableView()
	previewTableView:setAnchorPoint(ccp(0,0))
	previewTableView:setPosition(ccp(0,0))
	previewTableView:setBounceable(true)
	previewTableView:setDirection(kCCScrollViewDirectionHorizontal)
	previewTableView:reloadData()
	previewTableView:setTouchPriority(-551)
	secondBgSprite:addChild(previewTableView)

	--领奖按钮层
	local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(-551)
    previewBgSprite:addChild(bgMenu)

    --已领奖按钮
    _haveRewardMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_g.png","images/common/btn/btn1_g.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1369"),ccc3(0xff, 0xff, 0xff),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _haveRewardMenuItem:setAnchorPoint(ccp(0.5,0))
	_haveRewardMenuItem:setPosition(ccp(previewBgSprite:getContentSize().width/2,5))
	_haveRewardMenuItem:registerScriptTapHandler(rewardCallBack)
	_haveRewardMenuItem:setVisible(false)
	bgMenu:addChild(_haveRewardMenuItem,1,1)

	--领奖按钮
	_rewardMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1715"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_rewardMenuItem:setAnchorPoint(ccp(0.5,0))
	_rewardMenuItem:setPosition(ccp(previewBgSprite:getContentSize().width/2,5))
	_rewardMenuItem:registerScriptTapHandler(rewardCallBack)
	_rewardMenuItem:setVisible(false)
	bgMenu:addChild(_rewardMenuItem,1,2)

	--不可领奖按钮
	_banMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_g.png","images/common/btn/btn1_g.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1715"),ccc3(0xff, 0xff, 0xff),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_banMenuItem:setAnchorPoint(ccp(0.5,0))
	_banMenuItem:setPosition(ccp(previewBgSprite:getContentSize().width/2,5))
	_banMenuItem:registerScriptTapHandler(rewardCallBack)
	_banMenuItem:setVisible(false)
	bgMenu:addChild(_banMenuItem,1,3)

	--是否领奖初始化
	_haveReward = StepCounterData.getWetherReward()

    --已领取
    if StepCounterData.getWetherReward() == true then
    	_haveRewardMenuItem:setVisible(true)
	--可领奖
	elseif StepCounterData.getCanReward() == true then
		_rewardMenuItem:setVisible(true)
	--不可领奖
	else
		_banMenuItem:setVisible(true)
	end
end

--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	--紫色背景
	local bgSprite = CCScale9Sprite:create("images/recharge/stepCounter/purple_bg.png")
	bgSprite:setPreferredSize(CCSizeMake(640,960))
	bgSprite:setScale(MainScene.bgScale)
	_bgLayer:addChild(bgSprite)

	--系统通知条和活动菜单栏
	require "script/ui/main/BulletinLayer"
	local bulletSize = RechargeActiveMain.getTopSize()
	require "script/ui/rechargeActive/RechargeActiveMain"
	local rechargeHeight = RechargeActiveMain.getBgWidth()

	--主菜单栏
	require "script/ui/main/MenuLayer"
	local menuLayerSize = MenuLayer.getLayerContentSize()

	--中间可显示高度
	local middleHeight = g_winSize.height - bulletSize.height*g_fScaleX - rechargeHeight - menuLayerSize.height*g_fScaleX

	--下部开始Y轴坐标
	local underPosY = menuLayerSize.height*g_fScaleX

	--小女孩儿
	local girlSprite = CCSprite:create("images/recharge/stepCounter/girl_bg.png")
	girlSprite:setAnchorPoint(ccp(0.5,0.5))
	girlSprite:setPosition(ccp(g_winSize.width/2,underPosY + middleHeight*440/655))
	girlSprite:setScale(g_fScaleX)
	_bgLayer:addChild(girlSprite)

	--下部太阳光
	local underLightSprite = CCSprite:create("images/recharge/stepCounter/under_light.png")
	underLightSprite:setAnchorPoint(ccp(0.5,0))
	underLightSprite:setPosition(ccp(g_winSize.width/2,underPosY + 230*MainScene.elementScale))
	underLightSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(underLightSprite)

	--顶端Y轴坐标
	local upPosY = g_winSize.height - bulletSize.height*g_fScaleX - rechargeHeight

	--上部太阳光
	local upperLightSprite = CCSprite:create("images/recharge/stepCounter/upper_light.png")
	upperLightSprite:setAnchorPoint(ccp(0.5,1))
	upperLightSprite:setPosition(ccp(g_winSize.width*370/640,upPosY))
	upperLightSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(upperLightSprite)

	--活动名称
	local titleSprite = CCSprite:create("images/recharge/stepCounter/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(upperLightSprite:getContentSize().width/2,upperLightSprite:getContentSize().height/2 + 5))
	upperLightSprite:addChild(titleSprite)

	--创建上部红色背景
	createUpperBg(middleHeight,upPosY - upperLightSprite:getContentSize().height*MainScene.elementScale + 15*MainScene.elementScale)

	--创建下部奖励预览框
	createPreViewBg(underPosY)
end

--[[
	@des 	:创建UI
	@param 	:
	@return :
--]]
function createUI()
	--设置是否可以领奖的参数
	StepCounterData.setCanReward()
	--加入这一条是因为，如果玩家进入游戏时是前一天夜里，到了第二天要重新计时
	--此时就要重新设置开始计时时间戳
	StepCounterData.setKeyForUserDefault()
	--创建背景UI
	createBgUI()
end

----------------------------------------入口函数----------------------------------------
function createLayer()
	init()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	--网络回调
	serviceCallBack = function()
		createUI()
	end

	if StepCounterData.getWetherReward() == nil then
		StepCounterService.checkStatus(serviceCallBack)
	else
		createUI()
	end

	return _bgLayer
end
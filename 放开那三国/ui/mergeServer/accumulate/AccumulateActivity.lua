-- Filename：	AccumulateActivity.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-15
-- Purpose：		合服登录累积 & 合服充值回馈 活动界面
-- 				放一起是因为太像了，所以统一处理			

module("AccumulateActivity", package.seeall)

require "script/ui/main/MainScene"
require "script/utils/BaseUI"
require "script/ui/mergeServer/accumulate/AccumulateService"
require "script/ui/mergeServer/accumulate/AccumulateData"
require "script/utils/TimeUtil"

local _bgLayer
local _type
local _scrollBgSprite 		--滑动层背景
local _bgZorder = 2 		--背景图片Z轴
local _sunZorder = 3 		--太阳图片Z轴
local _redBgZorder = 4 		--红色背景框Z轴

----------------------------------------初始化函数----------------------------------------
local function init()
	_bgLayer = nil
	_type = nil
	_scrollBgSprite = nil
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建UI
	@param 	:
	@return :
--]]
function createUI()
	--红色背景
	local bgSprite = CCScale9Sprite:create("images/mergeServer/accumulate/red_bg.png")
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

	--顶端位置Y
	local ceilPosY = g_winSize.height - bulletSize.height*g_fScaleX - rechargeHeight

	--小女孩儿图
	local girlSprite
	--活动标题文字
	local titleSprite
	--标题背景图片
	local titleBgSprite = CCSprite:create("images/recharge/rechargeBigRun/titlebg.png")
	--红色背景框
	--在这里声明是为了在下面分开两个条件进行node的添加
	local redBgSprite = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
	redBgSprite:setPreferredSize(CCSizeMake(420,80))
	--时间背景
	local timeBgSprite = CCScale9Sprite:create("images/recharge/restore_energy/desc_bg.png")
	timeBgSprite:setPreferredSize(CCSizeMake(640,50))
	--时间提示文字1
	local timeLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_2000") .. "  ",g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	timeLabel_1:setColor(ccc3(0xff,0xff,0xff))
	--时间提示文字2
	local timeLabel_2

	local openTime
	local endTime
	
	--如果是合服累积
	if _type == 1 then
		girlSprite = CCSprite:create("images/mergeServer/accumulate/first_girl.png")
		
		titleSprite = CCSprite:create("images/mergeServer/accumulate/login_title.png")

		--红色背景框上第一条提示信息
		local firstLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1149"),g_sFontName,21)
		firstLabel:setColor(ccc3(0xff,0xf6,0x00))
		firstLabel:setAnchorPoint(ccp(0.5,1))
		firstLabel:setPosition(ccp(redBgSprite:getContentSize().width/2,redBgSprite:getContentSize().height - 5))
		redBgSprite:addChild(firstLabel)

		--红色北京框上第二条提示信息
		local seccondLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1150"),g_sFontName,21)
		seccondLabel_1:setColor(ccc3(0xff,0xf6,0x00))
		local secondSprite = CCSprite:create("images/mergeServer/accumulate/tip_1.png")
		local seccondLabel_2 = CCLabelTTF:create("!",g_sFontName,21)
		seccondLabel_2:setColor(ccc3(0xff,0xf6,0x00))

		local firstNode = BaseUI.createHorizontalNode({seccondLabel_1,secondSprite,seccondLabel_2})
		firstNode:setAnchorPoint(ccp(0.5,0))
		firstNode:setPosition(ccp(redBgSprite:getContentSize().width/2,5))
		redBgSprite:addChild(firstNode)

		openTime,endTime = AccumulateData.gameOpenEndTime("mergeAccumulate")
	--如果是充值回馈则
	else
		girlSprite = CCSprite:create("images/mergeServer/accumulate/sec_girl_bg.png")

		--第二张图背景和人是分离的，所以还要拼接一个人上去
		local secGirlSprite = CCSprite:create("images/mergeServer/accumulate/second_girl.png")
		secGirlSprite:setAnchorPoint(ccp(0,1))
		secGirlSprite:setPosition(ccp(0,ceilPosY))
		secGirlSprite:setScale(MainScene.elementScale)
		_bgLayer:addChild(secGirlSprite,_redBgZorder)

		titleSprite = CCSprite:create("images/mergeServer/accumulate/recharge_title.png")

		--红色背景框第一条提示
		local firstLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1151"),g_sFontName,21)
		firstLabel:setColor(ccc3(0xff,0xf6,0x00))
		local firstSprite = CCSprite:create("images/mergeServer/accumulate/tip_2.png")

		local firstNode = BaseUI.createHorizontalNode({firstLabel,firstSprite})
		firstNode:setAnchorPoint(ccp(0.5,1))
		firstNode:setPosition(ccp(redBgSprite:getContentSize().width/2,redBgSprite:getContentSize().height - 5))
		redBgSprite:addChild(firstNode)

		--红色背景框第二条提示
		local secondLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1152"),g_sFontName,21)
		secondLabel_1:setColor(ccc3(0xff,0xf6,0x00))
		local secondSprite = CCSprite:create("images/mergeServer/accumulate/tip_3.png")
		local secondLabel_2 = CCLabelTTF:create("!",g_sFontName,21)
		secondLabel_2:setColor(ccc3(0xff,0xf6,0x00))

		local secondNode = BaseUI.createHorizontalNode({secondLabel_1,secondSprite,secondLabel_2})
		secondNode:setAnchorPoint(ccp(0.5,0))
		secondNode:setPosition(ccp(redBgSprite:getContentSize().width/2,5))
		redBgSprite:addChild(secondNode)

		--太阳背景，看到太阳就想到了伟大领袖金日成主席
		local sunSprite = CCSprite:create("images/mergeServer/accumulate/sun_bg.png")
		sunSprite:setAnchorPoint(ccp(1,0))
		sunSprite:setPosition(ccp(g_winSize.width,ceilPosY - 455*g_fScaleX))
		sunSprite:setScale(MainScene.elementScale)
		_bgLayer:addChild(sunSprite,_sunZorder)

		openTime,endTime = AccumulateData.gameOpenEndTime("mergeRecharge")
	end

	--时间文字
	timeLabel_2 = CCRenderLabel:create(TimeUtil.getTimeFormatYMDH(openTime) .. GetLocalizeStringBy("key_2358") .. TimeUtil.getTimeFormatYMDH(endTime),g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	timeLabel_2:setColor(ccc3(0x00,0xff,0x18))

	--设置小女孩儿图位置
	girlSprite:setAnchorPoint(ccp(0.5,1))
	girlSprite:setPosition(ccp(g_winSize.width/2,ceilPosY))
	girlSprite:setScale(g_fScaleX)
	_bgLayer:addChild(girlSprite,_bgZorder)

	--活动背景位置
	titleBgSprite:setAnchorPoint(ccp(0.5,1))
	titleBgSprite:setPosition(ccp(g_winSize.width*405/640,ceilPosY - 10*g_fScaleX))
	titleBgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(titleBgSprite,_redBgZorder)

	--活动标题位置
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(titleBgSprite:getContentSize().width/2,titleBgSprite:getContentSize().height))
	titleBgSprite:addChild(titleSprite)

	--红色背景框位置
	redBgSprite:setAnchorPoint(ccp(0.5,1))
	redBgSprite:setPosition(ccp(g_winSize.width*405/640,ceilPosY - 120*g_fScaleX))
	redBgSprite:setScale(g_fScaleX)
	_bgLayer:addChild(redBgSprite,_redBgZorder)

	--时间背景框位置
	timeBgSprite:setAnchorPoint(ccp(0.5,1))
	timeBgSprite:setPosition(ccp(g_winSize.width/2,ceilPosY - 230*g_fScaleX))
	timeBgSprite:setScale(g_fScaleX)
	_bgLayer:addChild(timeBgSprite,_redBgZorder)

	--中部区域高度
	local middleHeight = g_winSize.height - bulletSize.height*g_fScaleX - rechargeHeight - menuLayerSize.height*g_fScaleX

	--滑动背景层
	_scrollBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_scrollBgSprite:setPreferredSize(CCSizeMake(g_winSize.width*605/640,middleHeight - 280*g_fScaleX))
	_scrollBgSprite:setAnchorPoint(ccp(0.5,1))
	_scrollBgSprite:setPosition(ccp(g_winSize.width/2,ceilPosY - 260*g_fScaleX))
	_bgLayer:addChild(_scrollBgSprite,_redBgZorder)

	--时间node
	local timeNode = BaseUI.createHorizontalNode({timeLabel_1,timeLabel_2})
	timeNode:setAnchorPoint(ccp(0.5,1))
	timeNode:setPosition(ccp(timeBgSprite:getContentSize().width/2,timeBgSprite:getContentSize().height - 3))
	timeBgSprite:addChild(timeNode)

	require "script/ui/mergeServer/accumulate/MergeScrollView"

	--ScrollView
	local underScrollView = MergeScrollView.createScrollView(_type)
	underScrollView:setAnchorPoint(ccp(0,0))
	underScrollView:setPosition(ccp(0,0))
	underScrollView:setTouchPriority(-551)
	_scrollBgSprite:addChild(underScrollView)
end

----------------------------------------入口函数----------------------------------------
--[[
	@des 	:入口函数
	@param 	:创建的活动的类型 
			 1 登录累积 		2 充值回馈
	@return :创建好的layer
--]]
function createLayer(p_type)
	init()

	_type = p_type

	_bgLayer = CCLayer:create()

	local serviceCallBack = function()
		--创建UI
		createUI()
	end

	AccumulateService.getRewardInfo(p_type,serviceCallBack)

	return _bgLayer
end

----------------------------------------工具函数----------------------------------------
--[[
	@des 	:得到ScrollView背景层大小
	@param 	:
	@return :背景层大小
--]]
function getBgSize()
	return _scrollBgSprite:getContentSize()
end
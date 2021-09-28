-- Filename：	RechargeBigRunLayer.lua
-- Author：		Zhang Zihang
-- Date：		2014-7-7
-- Purpose：		充值大放送界面

module("RechargeBigRunLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/utils/TimeUtil"
require "script/ui/rechargeActive/rechargeBigRun/RechargeBigRunData"
require "script/ui/item/ReceiveReward"
require "script/ui/rechargeActive/rechargeBigRun/RechargeBigRunService"
require "script/ui/rechargeActive/rechargeBigRun/ShowGiftTableView"
require "script/ui/rechargeActive/rechargeBigRun/RunPreviewTableView"
require "script/ui/item/ItemUtil"

local _bgLayer				--背景层
local _remainTimer			--剩余时间定时器
local _remainLabel 			--剩余时间label
local _curRewardBgSprite 	--红色预览框背景
local _bgMenu				--领奖按钮层
local kMenuTag = 1001		--领奖按钮tag

----------------------------------------初始化函数----------------------------------------
local function init()
	_bgLayer = nil
	_remainTimer = nil
	_remainLabel = nil
	_curRewardBgSprite = nil
	_bgMenu = nil
end

----------------------------------------节点事件函数----------------------------------------
local function onNodeEvent(event)
	if event == "exit" then
		--退出时结束定时器
		if _remainTimer ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_remainTimer)
		end
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:领奖回调
	@param 	:
	@return :
--]]
function getRewardCallBack()
	if ItemUtil.isBagFull() then
	else
		--充值够了，可以领奖
		if RechargeBigRunData.canGetReward() == true then

			retCallBack = function()
				--刷新领奖按钮
				refreshBtn()
				--显示领取奖励界面
				ReceiveReward.showRewardWindow(RechargeBigRunData.getDataByDay(RechargeBigRunData.getToday()))
			end
			--发送网络消息
			RechargeBigRunService.topupRewardRec(retCallBack)
		--充值不足，不能领取
		else
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1025"))
		end
	end
end

--[[
	@des 	:网络回调领奖失败
	@param 	:
	@return :
--]]
function getFailed()
	AnimationTip.showTip(GetLocalizeStringBy("zzh_1026"))
end

----------------------------------------刷新函数----------------------------------------
--[[
	@des 	:刷新剩余时间
	@param 	:
	@return :
--]]
function refreshRemainTime()
	_remainLabel:setString(RechargeBigRunData.getRemainTimeFormat())
end

--[[
	@des 	:领奖后刷新领奖按钮
	@param 	:
	@return :
--]]
function refreshBtn()
	--删除原有按钮
	_bgMenu:removeChildByTag(kMenuTag,true)
	--创建以领取按钮
	-- local getRewardBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_g.png","images/common/btn/btn1_g.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1369"),ccc3(0xff, 0xff, 0xff),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- getRewardBtn:setAnchorPoint(ccp(0.5,1))
	-- getRewardBtn:setPosition(ccp(_curRewardBgSprite:getContentSize().width/2,-5))
	-- _bgMenu:addChild(getRewardBtn,1,kMenuTag)
	local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
    receive_alreadySp:setPosition(ccp(_curRewardBgSprite:getContentSize().width*0.5,-15))
    receive_alreadySp:setAnchorPoint(ccp(0.5,1))
    _curRewardBgSprite:addChild(receive_alreadySp)
end

----------------------------------------创建UI函数----------------------------------------
--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	--紫色背景
	local bgSprite = CCScale9Sprite:create("images/recharge/rechargeBigRun/darkred.png")
	bgSprite:setPreferredSize(CCSizeMake(640,960))
	bgSprite:setScale(MainScene.bgScale)
	_bgLayer:addChild(bgSprite)

	--得到菜单栏大小
	require "script/ui/main/MenuLayer"
	local menuLayerSize = MenuLayer.getLayerContentSize()

	local blackBgPosY = menuLayerSize.height*g_fScaleX + 20*g_fScaleY

	--因为适配问题，小女孩儿背景可能遮挡其他的，所以其他背景z轴为2，小女孩儿为1
	local otherBgZOrder = 2

	--最下面的黑色礼品背景框
	_blackBgSprite = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_blackBgSprite:setPreferredSize(CCSizeMake(620,160))
	_blackBgSprite:setAnchorPoint(ccp(0.5,0))
	_blackBgSprite:setPosition(ccp(g_winSize.width/2,blackBgPosY))
	_blackBgSprite:setScale(MainScene.elementScale)
	--设置Z轴要高于小女孩儿，以免被小女孩儿遮挡
	_bgLayer:addChild(_blackBgSprite,otherBgZOrder)

	blackBgSize = _blackBgSprite:getContentSize()
	
	require "script/ui/main/BulletinLayer"
	local bulletSize = RechargeActiveMain.getTopSize()
	require "script/ui/rechargeActive/RechargeActiveMain"
	--函数名虽然是getBgWidth()不过得到的却是活动栏的高（华仔英文弄混了）
	--getBgWidth()内部已经写好了适配（乘以了g_fScaleX）
	local rechargeHeight = RechargeActiveMain.getBgWidth() 

	--考虑到由于适配小女孩儿位置的问题，做了以下的操作，具体的自己看吧，描述起来太难
	local emptyHeight = g_winSize.height - bulletSize.height*g_fScaleX - rechargeHeight - blackBgPosY - blackBgSize.height*g_fScaleX
	local blackBgHeightY = blackBgPosY + blackBgSize.height*g_fScaleX 
	local girlSpritePosY = blackBgHeightY + emptyHeight/2

	--小女孩儿z轴
	local girlZOrder = 1

	--小丫头
	local girlSprite = CCSprite:create("images/recharge/rechargeBigRun/littlegirl.png")
	girlSprite:setAnchorPoint(ccp(0,0.5))
	girlSprite:setPosition(ccp(0,girlSpritePosY))
	girlSprite:setScale(MainScene.elementScale)
	--设置Z轴低于黑色礼品背景框
	_bgLayer:addChild(girlSprite,girlZOrder)	

	--星星的背景
	local starBgSprite = CCSprite:create("images/recharge/rechargeBigRun/starbg.png")
	starBgSprite:setAnchorPoint(ccp(1,0.5))
	starBgSprite:setPosition(ccp(g_winSize.width,girlSpritePosY))
	starBgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(starBgSprite)

	--活动名称背景
	local titleBgSprite = CCSprite:create("images/recharge/rechargeBigRun/titlebg.png")
	titleBgSprite:setAnchorPoint(ccp(0.5,1))
	titleBgSprite:setPosition(ccp(g_winSize.width*0.65,g_winSize.height - bulletSize.height*g_fScaleX - rechargeHeight))
	titleBgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(titleBgSprite,otherBgZOrder)

	--充值放送名称
	local titleSprite = CCSprite:create("images/recharge/rechargeBigRun/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(titleBgSprite:getContentSize().width/2,titleBgSprite:getContentSize().height/2 + 15))
	titleBgSprite:addChild(titleSprite)

	--活动描述
	local desSprite = CCSprite:create("images/recharge/rechargeBigRun/describe.png")
	desSprite:setAnchorPoint(ccp(0.5,0.5))
	desSprite:setPosition(ccp(g_winSize.width*0.65,blackBgHeightY + emptyHeight*0.7 + 5*g_fScaleY))
	desSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(desSprite,otherBgZOrder)

	--当日奖励预览红色背景
	local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(50,50,6,4)
	_curRewardBgSprite = CCScale9Sprite:create("images/recharge/desc_bg.png",fullRect,insetRect)
	_curRewardBgSprite:setPreferredSize(CCSizeMake(475,160))
	_curRewardBgSprite:setAnchorPoint(ccp(1,0.5))
	_curRewardBgSprite:setPosition(ccp(g_winSize.width - 10*g_fScaleX,blackBgHeightY + emptyHeight*0.45))
	_curRewardBgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(_curRewardBgSprite,otherBgZOrder)

	--把按钮加到_curRewardBgSprite上是为了更好地适配
	_bgMenu = CCMenu:create()
	_bgMenu:setPosition(ccp(0,0))
	_curRewardBgSprite:addChild(_bgMenu)

	--领取礼包按钮
	local getRewardBtn
	--如果未领取
	if RechargeBigRunData.haveGetReward() == false then
		getRewardBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("zzh_1017"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		getRewardBtn:registerScriptTapHandler(getRewardCallBack)
		getRewardBtn:setAnchorPoint(ccp(0.5,1))
		getRewardBtn:setPosition(ccp(_curRewardBgSprite:getContentSize().width/2,-15))
		_bgMenu:addChild(getRewardBtn,1,kMenuTag)
	--如果已领取
	else
		getRewardBtn =  CCSprite:create("images/sign/receive_already.png")
		getRewardBtn:setPosition(ccp(_curRewardBgSprite:getContentSize().width*0.5,-15))
	    getRewardBtn:setAnchorPoint(ccp(0.5,1))
	    _curRewardBgSprite:addChild(getRewardBtn)
	end
	

	--把下面的文字加到黑色背景框上是为了更好地适配
	--活动时间Y轴位置
	local timePosY = 55 + _blackBgSprite:getContentSize().height

	--活动时间 文字
	local activeTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1019"),g_sFontName,18)
	activeTimeLabel:setAnchorPoint(ccp(1,0.5))
	activeTimeLabel:setPosition(ccp(_blackBgSprite:getContentSize().width*0.3,timePosY))
	activeTimeLabel:setColor(ccc3(0x00,0xe4,0xff))
	_blackBgSprite:addChild(activeTimeLabel)

	--活动时间 年-月-日
	local startYMD = TimeUtil.getTimeFormatChnYMDHM(RechargeBigRunData.getStartTime())
	local endYMD = TimeUtil.getTimeFormatChnYMDHM(RechargeBigRunData.getEndTime())
	local timeLabel = CCLabelTTF:create(startYMD .. " - " .. endYMD,g_sFontName,18)
	timeLabel:setColor(ccc3(0x00,0xff,0x18))
	timeLabel:setAnchorPoint(ccp(0,0.5))
	timeLabel:setPosition(ccp(_blackBgSprite:getContentSize().width*0.3,timePosY))
	_blackBgSprite:addChild(timeLabel)

	--剩余时间Y轴位置
	local remainPosY = 30 + _blackBgSprite:getContentSize().height

	--活动剩余时间 文字
	local timeRemainLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1020"),g_sFontName,18)
	timeRemainLabel:setAnchorPoint(ccp(1,0.5))
	timeRemainLabel:setPosition(ccp(_blackBgSprite:getContentSize().width*0.3,remainPosY))
	timeRemainLabel:setColor(ccc3(0x00,0xe4,0xff))
	_blackBgSprite:addChild(timeRemainLabel)

	--剩余时间 日-小时-分-秒
	_remainLabel = CCLabelTTF:create(RechargeBigRunData.getRemainTimeFormat(),g_sFontName,18)
	_remainLabel:setColor(ccc3(0x00,0xff,0x18))
	_remainLabel:setAnchorPoint(ccp(0,0.5))
	_remainLabel:setPosition(ccp(_blackBgSprite:getContentSize().width*0.3,remainPosY))
	_blackBgSprite:addChild(_remainLabel)

	--当前充值金额位置
	local curGoldPosY = 5 - getRewardBtn:getContentSize().height/2
	local curGoldPosX = 10
	--当日充值 文本
	local curRecharge = CCRenderLabel:create(GetLocalizeStringBy("zzh_1034"),g_sFontName,20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	curRecharge:setColor(ccc3(0x00,0xff,0x18))
	curRecharge:setAnchorPoint(ccp(1,1))
	curRecharge:setPosition(ccp(curGoldPosX,curGoldPosY))
	_curRewardBgSprite:addChild(curRecharge)

	--金币数量
	local curGoldLabel = CCRenderLabel:create(RechargeBigRunData.getCurrentGold(),g_sFontName,20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	--够金额是绿色
	if RechargeBigRunData.goldEnough() then
		curGoldLabel:setColor(ccc3(0x00,0xff,0x18))
	--不够是红色
	else
		curGoldLabel:setColor(ccc3(0xff,0x00,0x00))
	end
	curGoldLabel:setAnchorPoint(ccp(0,1))
	curGoldLabel:setPosition(ccp(curGoldPosX,curGoldPosY))
	_curRewardBgSprite:addChild(curGoldLabel)

	curGoldPosX = curGoldPosX + curGoldLabel:getContentSize().width
	--需要金币的数量
	local needGoldLabel = CCRenderLabel:create("/" .. RechargeBigRunData.getRechargeNum(),g_sFontName,20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	needGoldLabel:setColor(ccc3(0x00,0xff,0x18))
	needGoldLabel:setAnchorPoint(ccp(0,1))
	needGoldLabel:setPosition(ccp(curGoldPosX,curGoldPosY))
	_curRewardBgSprite:addChild(needGoldLabel)

	curGoldPosX = curGoldPosX + needGoldLabel:getContentSize().width
	--金币图标
	local goldSprite = CCSprite:create("images/common/gold.png")
	goldSprite:setAnchorPoint(ccp(0,1))
	goldSprite:setPosition(ccp(curGoldPosX,curGoldPosY + 5))
	_curRewardBgSprite:addChild(goldSprite)

	--定时器，刷新剩余时间
	_remainTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(refreshRemainTime, 1, false)
end

--[[
	@des 	:创建奖励预览UI
	@param 	:
	@return :
--]]
function createShowGiftUI()
	--------------------从此开始暴力拼接法，感到颤抖了吗，唔哈哈哈哈哈
	--"当日充值"
	local curRechargeLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1021"),g_sFontPangWa,21)
	curRechargeLabel:setAnchorPoint(ccp(0,1))
	curRechargeLabel:setPosition(ccp(20,_curRewardBgSprite:getContentSize().height-10))
	curRechargeLabel:setColor(ccc3(0xff,0xff,0xff))
	_curRewardBgSprite:addChild(curRechargeLabel)

	--充值多少x坐标
	local numLabelPosX = 20 + curRechargeLabel:getContentSize().width

	--充值多少
	local rechargeNumLabel = CCLabelTTF:create(RechargeBigRunData.getRechargeNum(),g_sFontPangWa,21)
	rechargeNumLabel:setAnchorPoint(ccp(0,1))
	rechargeNumLabel:setPosition(ccp(numLabelPosX,_curRewardBgSprite:getContentSize().height-10))
	rechargeNumLabel:setColor(ccc3(0xff,0xf6,0x00))
	_curRewardBgSprite:addChild(rechargeNumLabel)

	--下面那个文本文本x坐标
	numLabelPosX = numLabelPosX + rechargeNumLabel:getContentSize().width

	--文本"元即可领取："
	local willGetLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1022"),g_sFontPangWa,21)
	willGetLabel:setAnchorPoint(ccp(0,1))
	willGetLabel:setPosition(ccp(numLabelPosX,_curRewardBgSprite:getContentSize().height-10))
	willGetLabel:setColor(ccc3(0xff,0xff,0xff))
	_curRewardBgSprite:addChild(willGetLabel)

	numLabelPosX = numLabelPosX + willGetLabel:getContentSize().width

	--第几天礼包
	local dayGiftLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1023") .. RechargeBigRunData.getToday() .. GetLocalizeStringBy("zzh_1024"),g_sFontPangWa,21)
	dayGiftLabel:setAnchorPoint(ccp(0,1))
	dayGiftLabel:setPosition(ccp(numLabelPosX,_curRewardBgSprite:getContentSize().height-10))
	dayGiftLabel:setColor(ccc3(0x00,0xe4,0xff))
	_curRewardBgSprite:addChild(dayGiftLabel)
	--------------------拼完了，暴力是解决一切的办法

	--箭头X坐标
	local arrowPosX = _curRewardBgSprite:getContentSize().width - 40

	--上箭头
	local upArrowSprite = CCSprite:create("images/common/arrow_up_h.png")
	upArrowSprite:setAnchorPoint(ccp(0.5,0))
	upArrowSprite:setPosition(ccp(arrowPosX,_curRewardBgSprite:getContentSize().height - 25))
	_curRewardBgSprite:addChild(upArrowSprite)

	--下箭头
	local downArrowSprite = CCSprite:create("images/common/arrow_down_h.png")
	downArrowSprite:setAnchorPoint(ccp(0.5,1))
	downArrowSprite:setPosition(ccp(arrowPosX,10))
	_curRewardBgSprite:addChild(downArrowSprite)

	--创建预览框tableView
	local giftTableView = ShowGiftTableView.createShowGiftTableView()
	giftTableView:setAnchorPoint(ccp(0,0))
	giftTableView:setPosition(ccp(0,0))
	giftTableView:setBounceable(true)
	--设置优先级这么高是为了滑动在图片上也能滑动
	giftTableView:setTouchPriority(-600)
	_curRewardBgSprite:addChild(giftTableView)
end

--[[
	@des 	:创建礼包预览UI
	@param 	:
	@return :
--]]
function createPreviewGiftUI()
	--礼包预览背景
	local preViewBgSprite = CCScale9Sprite:create(CCRectMake(25, 15, 20, 10),"images/common/astro_labelbg.png")
	preViewBgSprite:setPreferredSize(CCSizeMake(190,35))
	preViewBgSprite:setAnchorPoint(ccp(0.5,0.5))
	preViewBgSprite:setPosition(ccp(_blackBgSprite:getContentSize().width/2,_blackBgSprite:getContentSize().height))
	_blackBgSprite:addChild(preViewBgSprite)

	--充值礼包预览 标题
	local preViewLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1018"),g_sFontPangWa,24)
	preViewLabel:setColor(ccc3(0xff,0xf6,0x00))
	preViewLabel:setAnchorPoint(ccp(0.5,0.5))
	preViewLabel:setPosition(ccp(preViewBgSprite:getContentSize().width/2,preViewBgSprite:getContentSize().height/2))
	preViewBgSprite:addChild(preViewLabel)

	--文本 "点击礼包可预览"
	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1027"),g_sFontName,18)
	tipLabel:setColor(ccc3(0x00,0xff,0x18))
	tipLabel:setAnchorPoint(ccp(1,1))
	tipLabel:setPosition(ccp(_blackBgSprite:getContentSize().width - 15,_blackBgSprite:getContentSize().height - 5))
	_blackBgSprite:addChild(tipLabel)

	--左箭头
	local leftArrowSprite = CCSprite:create("images/formation/btn_left.png")
	leftArrowSprite:setAnchorPoint(ccp(0,0.5))
	leftArrowSprite:setPosition(ccp(5,_blackBgSprite:getContentSize().height/2))
	_blackBgSprite:addChild(leftArrowSprite)

	--右箭头
	local rightArrowSprite = CCSprite:create("images/formation/btn_right.png")
	rightArrowSprite:setAnchorPoint(ccp(1,0.5))
	rightArrowSprite:setPosition(ccp(_blackBgSprite:getContentSize().width - 5,_blackBgSprite:getContentSize().height/2))
	_blackBgSprite:addChild(rightArrowSprite)

	--创建礼包tableView
	local giftTableView = RunPreviewTableView.createPreviewTableView()
	giftTableView:setAnchorPoint(ccp(0,0))
	giftTableView:setPosition(ccp(55,5))
	giftTableView:setBounceable(true)
	giftTableView:setDirection(kCCScrollViewDirectionHorizontal)
	--如果不reload还是默认竖着创建
	giftTableView:reloadData()
	--设置优先级这么高是为了滑动在图片上也能滑动
	giftTableView:setTouchPriority(-600)
	--因为一行只能显示4个，如果超过4天的礼物，为了引人注意，向左显示出来
	if tonumber(RechargeBigRunData.getToday()) > 4 then
		giftTableView:setContentOffset(ccp(-130*(RechargeBigRunData.getToday() - 4),giftTableView:getContentOffset().y))
	end
	_blackBgSprite:addChild(giftTableView)
end

----------------------------------------入口函数----------------------------------------
function createLayer()
	init()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	--网络回调
	serviceCallBack = function()
		--创建背景UI
		createBgUI()
		--创建今日可领取奖励UI
		createShowGiftUI()
		--创建奖励预览UI
		createPreviewGiftUI()
	end

	RechargeBigRunService.topupRewardGetInfo(serviceCallBack)

	return _bgLayer
end
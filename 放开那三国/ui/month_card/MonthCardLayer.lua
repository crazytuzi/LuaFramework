-- Filename：	MonthCardLayer.lua
-- Author：		zhz
-- Date：		2013-6-12
-- Purpose：		月卡功能

module("MonthCardLayer", package.seeall)

require "script/ui/month_card/MonthCardData"
require "script/ui/item/ItemUtil"
require "script/ui/month_card/MonthCardService"
require "script/ui/item/ReceiveReward"
require "script/utils/TimeUtil"
require "script/ui/month_card/MonthCardCell"

local _bgLayer				--背景的layer
local _monthCardBg			--月卡的背景
local _gameType 			--15天活动还是3天活动 1代表15天，2代表3天 
local _timeCounter 			--定时器
local _layerSize
local _giftStatus
local _monthSendSp
local _remainTimeLabel
local _monthCardItem
local _mCardNormalBg
local _mCardSuperBg 
local _tableView
local _kGiftStatusOne = 1
local _kGiftStatusTwo = 2
local _kGiftStatusThree = 3
local function init( )
	_bgLayer			=nil
	_monthCardBg		=nil
	_gameType 			=0
	_timeCounter 		= nil
	_layerSize 			= {}
	_giftStatus 		= nil
	_remainTimeLabel 	= nil
	_monthSendSp		= nil
	_monthCardItem		= nil
	_mCardNormalBg		= nil
	_mCardSuperBg 		= nil
	_tableView			= nil
end


-- 创建顶部的UI
 function createTopUI( ... )
 	if(_monthSendSp~=nil)then
 		_monthSendSp:removeFromParentAndCleanup(true)
 		_monthSendSp = nil
 	end
	--月卡大派送
	_monthSendSp= CCSprite:create("images/month_card/month_send_sp1.png")
	_monthSendSp:setPosition(ccp(5, _layerSize.height))
	_monthSendSp:setAnchorPoint(ccp(0,1))
	_monthSendSp:setScale(g_fScaleX)
	_bgLayer:addChild(_monthSendSp,5)

	--文字“两种月卡可以同时购买”
	local desLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_073"),g_sFontPangWa, 21,1, ccc3(0x00,0,0),type_stroke)
	desLable:setColor(ccc3(0x00,0xff,0x18))
	desLable:setAnchorPoint(ccp(0.5,1))
	desLable:setPosition(ccp(_monthSendSp:getContentSize().width*0.5,-_monthSendSp:getContentSize().height*0.2))
	_monthSendSp:addChild(desLable)

	--月卡礼包
	local menuBar=CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	_bgLayer:addChild(menuBar)

	if(_monthCardItem~=nil)then
 		_monthCardItem:removeFromParentAndCleanup(true)
 		_monthCardItem = nil
 	end
	-- 月卡礼包按钮
	_monthCardItem=CCMenuItemImage:create("images/month_card/month_item/month_card_n.png", "images/month_card/month_item/month_card_h.png")
	_monthCardItem:setPosition(ccp(_layerSize.width- 24*g_fScaleX, _layerSize.height))
	_monthCardItem:setAnchorPoint(ccp(1,1))
	_monthCardItem:setScale(g_fScaleX )
	_monthCardItem:registerScriptTapHandler(monthCallBack)
	menuBar:addChild(_monthCardItem)

	local img_path = CCString:create("images/base/effect/yuekalibaoguang/yuekalibaoguang")
    local  petBottomEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
    petBottomEffect:setFPS_interval(1/60.0)
    petBottomEffect:retain()
    petBottomEffect:setPosition(ccp(_monthCardItem:getContentSize().width/2, _monthCardItem:getContentSize().height/2))
    petBottomEffect:setAnchorPoint(ccp(0.5,0.5))
    _monthCardItem:addChild(petBottomEffect,-1)
	
	--倒计时
	--文本 （活动倒计时：
	_gameMinusLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1029"),g_sFontName, 21,1, ccc3(0x00,0,0),type_stroke)
	_gameMinusLabel_1:setColor(ccc3(0xff,0xff,0xff))
	_gameMinusLabel_1:setAnchorPoint(ccp(1,1))
	_gameMinusLabel_1:setPosition(ccp(-5, 0))
	_monthCardItem:addChild(_gameMinusLabel_1)

	--倒计时
	_remainTimeLabel = CCRenderLabel:create(MonthCardData.remainTimeFormat(_gameType),g_sFontName,21,1, ccc3(0x00,0,0),type_stroke)
	_remainTimeLabel:setColor(ccc3(0x00,0xff,0x18))
	_remainTimeLabel:setAnchorPoint(ccp(0,0.5))
	_remainTimeLabel:setPosition(ccp(_gameMinusLabel_1:getContentSize().width,_gameMinusLabel_1:getContentSize().height*0.5))
	_gameMinusLabel_1:addChild(_remainTimeLabel)

	--文本 ）
	local gameMinusLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_4039"),g_sFontName,21,1, ccc3(0x00,0,0),type_stroke)
	gameMinusLabel_2:setColor(ccc3(0xff,0xff,0xff))
	gameMinusLabel_2:setAnchorPoint(ccp(0,0.5))
	gameMinusLabel_2:setPosition(ccp(_remainTimeLabel:getContentSize().width,_remainTimeLabel:getContentSize().height*0.5))
	_remainTimeLabel:addChild(gameMinusLabel_2)

	local labelString
	if(MonthCardData.isMerge())then
		labelString = GetLocalizeStringBy("fqq_082")
	else
		labelString = GetLocalizeStringBy("fqq_074")
	end
	-- 文字"开服15日内可领取月卡大礼包"
	local descLabel =CCLabelTTF:create(labelString,g_sFontName,21,CCSizeMake(200,60),kCCTextAlignmentLeft)
 	descLabel:setAnchorPoint(ccp(1,0))
    descLabel:setPosition(ccp(-15,0))
    descLabel:setColor(ccc3(0x00,0xff,0x18))
    _monthCardItem:addChild(descLabel)
	if _gameType ~= 0 then
		startSchedule()
	end
	if MonthCardData.wetherHaveBag() then
		--月卡礼包按钮
		_monthCardItem:setVisible(true)
	else
		_monthCardItem:setVisible(false)
	end
	
end

function startSchedule()
	if(_timeCounter == nil)then
		_timeCounter = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(refreshRemainTime, 1, false)
	end
end

function stopSchedule()
	if(_timeCounter)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timeCounter)
		_timeCounter = nil
	end
end





local function onNodeEvent( event )
	if (event == "enter") then
	elseif (event == "exit") then
		--如果定时器为空不走，因为涉及到界面切换的问题
		-- if (_gameType ~= 0) and (_timeCounter ~= nil) then
		-- 	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timeCounter)
		-- end
		stopSchedule()
		-- _bgLayer  = nil
	end
end

function createLayer( )
	init()
	_bgLayer  = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_gameType = MonthCardData.getTypeNumber()
	print("_gameType",_gameType)
	require "script/ui/rechargeActive/RechargeActiveMain"
	--消息提示栏和主菜单栏显示可见，主角信息栏不可见
	MainScene.setMainSceneViewsVisible(true, false, false)
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local  activeMainWidth = RechargeActiveMain.getBgWidth()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX- activeMainWidth

	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
	print("_bgLayer:getContentSize().width",_bgLayer:getContentSize().width)
	print("_bgLayer:getContentSize().height",_bgLayer:getContentSize().height)
	_monthCardBg= CCSprite:create("images/month_card/buttonsprite.png")
	_monthCardBg:setScale(g_fScaleX)
	_monthCardBg:setAnchorPoint(ccp(0.5, 0))
	_monthCardBg:setPosition(ccp(_layerSize.width/2, 0))
	_bgLayer:addChild(_monthCardBg)

	
	
	--调用后端接口进行网络回调，回调结束后运行传入的函数
	MonthCardService.getCardInfo(function ( ... )
		createTopUI()
  		createUI()
	end )

	return _bgLayer
end
-- function createAllUI( ... )
-- 	if (_mCardNormalBg) then
-- 		_mCardNormalBg:removeFromParentAndCleanup(true)
-- 		_mCardNormalBg = nil
-- 	end
-- 	_mCardNormalBg = createUI(MonthCardData.kNormalMonthCard)
	
-- 	if (_mCardSuperBg) then
-- 		_mCardSuperBg:removeFromParentAndCleanup(true)
-- 		_mCardSuperBg = nil
-- 	end
-- 	_mCardSuperBg = createUI(MonthCardData.kSuperMonthCard)
-- end
function createUI(  )
	if( _tableView~= nil ) then
        _tableView:removeFromParentAndCleanup(true)
        _tableView=nil
    end
    local dataInfo = {}
	local dataInfo1 = MonthCardData.getVipCardDatafromXml(1)
	table.insert(dataInfo,dataInfo1)
	local dataInfo2 = MonthCardData.getVipCardDatafromXml(2)
	table.insert(dataInfo,dataInfo2)
	local tableViewSize = CCSizeMake(_layerSize.width,_layerSize.height*0.8)
	local cellSize = CCSizeMake(tableViewSize.width,280*g_fScaleX)
	local luaHandler = LuaEventHandler:create(function ( fn,t,a1,a2 )
		local pCell = nil
		if fn == "cellSize" then
			pCell = CCSizeMake(cellSize.width,cellSize.height)
		elseif fn == "cellAtIndex" then
			pCell = MonthCardCell.createCell(dataInfo[a1+1], a1+1)
		elseif fn == "numberOfCells" then
			pCell = #dataInfo
		elseif fn == "cellTouched" then
			
		end
	return pCell
	end)
	_tableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	_tableView:setTouchPriority(-450)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(5,5))
	_bgLayer:addChild(_tableView)
end

--------------------------------- 回调事件 -----------------------------




--月卡礼包按钮中的领取礼包的回调
function getGift( )
	local function callBack(  )
		local items= MonthCardData.getFirstReward()
		print("----getGift----")
		print_t(items)
		print("---------------")
		ItemUtil.addRewardByTable(items)
		ReceiveReward.showRewardWindow( items,nil,nil,-500)
		MonthCardData.changeGiftStatus(3)
		rfesshButtonBigGift()
	end
	
	MonthCardService.getGift(callBack )
end
--领取后刷新大礼包中的刷新按钮
function rfesshButtonBigGift( ... )
			createTopUI()
end
-- 点击月卡礼包按钮的回调函数
function monthCallBack( tag, item)
	require "script/utils/ItemTableView"
	local items= MonthCardData.getFirstReward()

	local layer = ItemTableView:create(items)	

	local taParam
	local alertContent = {}

	print("礼包状态，哎",MonthCardData.getGiftStatus())

	if MonthCardData.getGiftStatus() == _kGiftStatusTwo then
		taParam= { img_n= "images/common/btn/btn_bg_n.png" , img_h= "images/common/btn/btn_bg_h.png", size= CCSizeMake(192,61),txt= GetLocalizeStringBy("key_4016"), txtColor=ccc3(0xfe, 0xdb, 0x1c),txtSize=35,font=g_sFontPangWa,strokeSize=1, strokeColor=ccc3(0x00, 0x00, 0x00) }
		alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1248") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
	elseif MonthCardData.getGiftStatus() == _kGiftStatusOne then
		taParam= { img_n= "images/common/btn/btn_hui.png" , img_h= "images/common/btn/btn_hui.png", size= CCSizeMake(192,61),txt= GetLocalizeStringBy("key_4016"), txtColor=ccc3(0xff, 0xff, 0xff),txtSize=35,font=g_sFontPangWa,strokeSize=1, strokeColor=ccc3(0x00, 0x00, 0x00) }
		alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("zzh_1032") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
	else
		taParam= { img_n= "images/common/btn/btn_hui.png" , img_h= "images/common/btn/btn_hui.png", size= CCSizeMake(192,61),txt= GetLocalizeStringBy("key_1369"), txtColor=ccc3(0xff, 0xff, 0xff),txtSize=35,font=g_sFontPangWa,strokeSize=1, strokeColor=ccc3(0x00, 0x00, 0x00) }
		alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("zzh_1032") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
	end
	layer:addSureBtn(taParam)
	layer:registerScriptSureEvent(getGift)
	alertContent[1]:setColor(ccc3(0xff, 0xc0, 0x00))
	local alert = BaseUI.createHorizontalNode(alertContent)
	layer:setContentTitle(alert)

	local scene= CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer, 560)
end

function refreshRemainTime()
	_remainTimeLabel:setString(MonthCardData.remainTimeFormat(_gameType))
end
--每日零点刷新
function refresh( ... )
	--先判断当前是否在此界面
	if( tolua.isnull(_bgLayer) )then
		return
	else
		local callBack = function ( ... )
		createTopUI()
		createUI()
		end
		MonthCardService.getCardInfo(callBack)
	end
	
end
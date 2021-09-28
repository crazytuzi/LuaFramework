-- Filename：	RaffleItemLayer.lua
-- Author：		lichenyang
-- Date：		2014-6-12
-- Purpose：		转盘抽奖界面



module ("RaffleItemLayer", package.seeall)

require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleData"
require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleService"
require "script/utils/BaseUI"
require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/item/ItemSprite"
require "script/utils/GoodTableView"

local _bgLayer        = nil	--主lyaer
local _layerSize      = nil	
local _nowIndex       = 1	--当前抽奖档次
local _topBg          = nil
local _turntableBg    = nil
local _selectedItemBg = nil
local _pointerSprite  = nil
local _updateTimer    = nil
local _startButton    = nil
----------------------------[[ 初始化 ]]--------------------------
function init( ... )
	_bgLayer        = nil
	_nowIndex       = 1	
	_topBg          = nil
	_turntableBg    = nil
	_selectedItemBg = nil
	_pointerSprite  = nil
	_updateTimer    = nil
	_startButton    = nil
end

-----------------------------[[ 节点事件 ]]------------------------------
function registerNodeEvent( ... )
	_pointerSprite:registerScriptHandler(function ( nodeType )
		if(nodeType == "exit") then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
			_selectedItemBg = nil
		end
	end)
end


----------------------------[[ 创建ui ]]--------------------------
--p_index 抽奖档次
function create( p_index )

	init()
	
	_nowIndex = p_index
	_bgLayer = CCLayer:create()
	MainScene.setMainSceneViewsVisible(true, false, false)
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local  activeMainWidth  = RechargeActiveMain.getBgWidth()
	local menuLayerSize     = MenuLayer.getLayerContentSize()
	_layerSize              = {width= 0, height=0}
	_layerSize.width        = g_winSize.width 
	_layerSize.height       = g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX- activeMainWidth
	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

	createTopAndButtonUi()
	createOtherUi()
	createTurntable()
	registerNodeEvent()
	return _bgLayer
end



function createTopAndButtonUi( ... )
	--top
	_topBg = CCSprite:create("images/recharge/rechargeRaffle/top_bg.png")
	_topBg:setPosition(_layerSize.width/2, _layerSize.height)
	_topBg:setAnchorPoint(ccp(0.5, 1))
	_topBg:setScale(g_fScaleX)
	_bgLayer:addChild(_topBg)

	local recharge_word_bg = CCSprite:create("images/recharge/rechargeRaffle/raffle_des.png")
	recharge_word_bg:setPosition(_topBg:getContentSize().width/2, _topBg:getContentSize().height/2)
	recharge_word_bg:setAnchorPoint(ccp(0.5, 0.5))
	_topBg:addChild(recharge_word_bg)

	_layerSize.height = _layerSize.height - _topBg:getContentSize().height * g_fScaleX

end


function createOtherUi( ... )

	--左上角
	local range1Sprite = CCSprite:create("images/recharge/rechargeRaffle/range_sprite.png")
	range1Sprite:setAnchorPoint(ccp(1, 0))
	range1Sprite:setPosition(_layerSize.width * 0.01, _layerSize.height * 0.99)
	range1Sprite:setRotation(180)
	_bgLayer:addChild(range1Sprite)

	--右上角
	local range2Sprite = CCSprite:create("images/recharge/rechargeRaffle/range_sprite.png")
	range2Sprite:setAnchorPoint(ccp(1, 0))
	range2Sprite:setPosition(_layerSize.width * 0.99, _layerSize.height * 0.99)
	range2Sprite:setRotation(270)
	_bgLayer:addChild(range2Sprite)

	--左下角
	local range3Sprite = CCSprite:create("images/recharge/rechargeRaffle/range_sprite.png")
	range3Sprite:setAnchorPoint(ccp(1, 0))
	range3Sprite:setPosition(_layerSize.width * 0.01, _layerSize.height * 0.01)
	range3Sprite:setRotation(90)
	_bgLayer:addChild(range3Sprite)

	--右下角
	local range4Sprite = CCSprite:create("images/recharge/rechargeRaffle/range_sprite.png")
	range4Sprite:setAnchorPoint(ccp(1, 0))
	range4Sprite:setPosition(_layerSize.width * 0.99, _layerSize.height * 0.02)
	_bgLayer:addChild(range4Sprite)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(menu)

	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	closeMenuItem:registerScriptTapHandler(closeLayerCallFunc)
	closeMenuItem:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.9))
	menu:addChild(closeMenuItem)
	closeMenuItem:setScale(MainScene.elementScale)


	local havaRaffleTitle =  CCRenderLabel:create(GetLocalizeStringBy("lcy_10020"), g_sFontPangWa, 24,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	havaRaffleTitle:setPosition(_layerSize.width * 0, _layerSize.height * 0.07)
	havaRaffleTitle:setAnchorPoint(ccp(0, 0.5))
	_bgLayer:addChild(havaRaffleTitle)
	havaRaffleTitle:setColor(ccc3(0xff,0xf6,00))
	havaRaffleTitle:setScale(MainScene.elementScale)
	havaRaffleTitle:setVisible(false)

	_havaRaffleDes =  CCLabelTTF:create(ChargeRaffleData.getCanRaffleNum(_nowIndex), g_sFontPangWa, 24)
	_havaRaffleDes:setPosition(havaRaffleTitle:getContentSize().width * MainScene.elementScale  + havaRaffleTitle:getPositionX() + 15*MainScene.elementScale,_layerSize.height * 0.07)
	_havaRaffleDes:setAnchorPoint(ccp(0, 0.5))
	_bgLayer:addChild(_havaRaffleDes)
	_havaRaffleDes:setColor(ccc3(0x00,0xff,0x18))
	_havaRaffleDes:setScale(MainScene.elementScale)
	_havaRaffleDes:setVisible(false)
end

--创建转盘
function createTurntable( ... )
	_turntableBg = CCSprite:create("images/recharge/rechargeRaffle/turntable_bg.png")
	_turntableBg:setAnchorPoint(ccp(0.5, 0.5))
	_turntableBg:setPosition(_layerSize.width/2, _layerSize.height/2)
	_bgLayer:addChild(_turntableBg)
	_turntableBg:setScale(MainScene.elementScale)

	_turntableCenter = CCSprite:create("images/recharge/rechargeRaffle/turntable_center.png")
	_turntableCenter:setAnchorPoint(ccp(0.5, 0.5))
	_turntableCenter:setPosition(_turntableBg:getContentSize().width/2, _turntableBg:getContentSize().height/2)
	_turntableBg:addChild(_turntableCenter)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_turntableCenter:addChild(menu)

	_startButton = CCMenuItemSprite:create(CCSprite:create("images/recharge/rechargeRaffle/start_btn_n.png"), CCSprite:create("images/recharge/rechargeRaffle/start_btn_h.png"), BTGraySprite:create("images/recharge/rechargeRaffle/start_btn_n.png"))
	_startButton:setPosition(_turntableCenter:getContentSize().width/2, _turntableCenter:getContentSize().height/2)
	_startButton:setAnchorPoint(ccp(0.5, 0.5))
	menu:addChild(_startButton)
	_startButton:registerScriptTapHandler(startButtonCallback)


	_selectedItemBg = CCSprite:create("images/recharge/rechargeRaffle/select_bg.png")
	_selectedItemBg:setPosition(_turntableBg:getContentSize().width/2, _turntableBg:getContentSize().height/2)
	_selectedItemBg:setAnchorPoint(ccp(0.5, 0))
	_turntableBg:addChild(_selectedItemBg,1)


	_pointerSprite = CCSprite:create("images/recharge/rechargeRaffle/pointer.png")
	_pointerSprite:setPosition(_turntableBg:getContentSize().width/2, _turntableBg:getContentSize().height/2)
	_pointerSprite:setAnchorPoint(ccp(0.5, 0))
	_turntableBg:addChild(_pointerSprite,3)

	local itemsInfo = ChargeRaffleData.getRaffleItems(_nowIndex)
	local count = table.count(itemsInfo)
	local ox,oy = _turntableBg:getContentSize().width/2,_turntableBg:getContentSize().height/2
	for i = 1,#itemsInfo do
		local v = itemsInfo[i]
	    local rotation =math.rad(i * 360/count + 54) 
   		local moveDis = -218
	    local nx = math.cos(rotation) 	* moveDis + ox
    	local ny = - math.sin(rotation) * moveDis + oy

    	-- 按钮外框
    	local item = ItemSprite.getItemSpriteByItemId(v.tid)
		item:setPosition(nx, ny)
		item:setAnchorPoint(ccp(0.5, 0.5))
		_turntableBg:addChild(item, 2)
		item:setScale(0.8)

		local num  = CCRenderLabel:create(tostring(v.num), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		num:setColor(ccc3(0x00, 0xff, 0x18))
		num:setAnchorPoint(ccp(1, 0))
		num:setPosition(ccpsprite(0.99, 0.01, item))
		item:addChild(num)

		local name = CCRenderLabel:create(tostring(v.db.name), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		name:setColor(HeroPublicLua.getCCColorByStarLevel(v.db.quality))
		name:setAnchorPoint(ccp(0.5, 1))
		name:setPosition(ccpsprite(0.5, -0.07, item))
		item:addChild(name)
	end
	_updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeFunc, 0.01, false)
end
-----------------------------------[[ 更新UI方法 ]]------------------------------------
function updateUI( ... )
	if(_havaRaffleDes) then
		_havaRaffleDes:setString(ChargeRaffleData.getCanRaffleNum(_nowIndex))
	end
end



--------------------------------------[[ 特效 ]] --------------------------------------------

function raffleAction( p_tid )
	print("p_tid:", p_tid)
	local itemsInfo = ChargeRaffleData.getRaffleItems(_nowIndex)
	print("itemsInfo:")
	print_table("itemsInfo",itemsInfo)
	

	local raffleInfo = nil
	local old = _pointerSprite:getRotation()%360
	local r = 0
	for i=1,#itemsInfo do
		local v = itemsInfo[i]
		if(tonumber(v.tid) == tonumber(p_tid)) then
			raffleInfo = v
			break
		end
		r = r + 36
	end
	r = r + 360 * 4 + (360 - old)
	local rotationAction = CCRotateBy:create(10, r)
	local easeAction     = CCEaseInOut:create(rotationAction, 5)
	--弹出物品面板
	local showItemList = function ( ... )
		_startButton:setEnabled(true)
		local itemData = {}
		local item = {}
		item.type = "item"
		item.tid = p_tid
		item.num = raffleInfo.num
		table.insert(itemData, item)
		local itemLayer = GoodTableView.ItemTableView:create(itemData)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(itemLayer, 20)
		print("showItemTableView")
	end

	local actionArray = CCArray:create()
	actionArray:addObject(easeAction)
	actionArray:addObject(CCCallFunc:create(showItemList))
	local seqAction =	CCSequence:create(actionArray)
	_pointerSprite:runAction(seqAction)
end




-------------------------------------[[ 回调事件 ]]-------------------------------------------

function updateTimeFunc( ... )
	local pr = _pointerSprite:getRotation()
	local sr = math.floor((pr + 18)/36) * 36 
	_selectedItemBg:setRotation(sr)
end


--开始抽奖按钮回调
function startButtonCallback( ... )
	if(ChargeRaffleData.getCanRaffleNum(_nowIndex) <= 0) then
		AnimationTip.showTip(GetLocalizeStringBy("lcy_10031"))
		return
	end

	_startButton:setEnabled(false)
	local requestCallback = function ( p_tid )
		raffleAction(p_tid)
		updateUI()
	end
	ChargeRaffleService.raffle(_nowIndex,requestCallback)
end


function closeLayerCallFunc( ... )
	require "script/ui/rechargeActive/RechargeActiveMain"
	require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleLayer"
	local  layer = ChargeRaffleLayer.create()
	RechargeActiveMain.changeButtomLayer(layer)
end






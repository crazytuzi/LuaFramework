-- Filename：	ChargeRaffleLayer.lua
-- Author：		lichenyang
-- Date：		2014-6-12
-- Purpose：		充值抽奖活动layer

module ("ChargeRaffleLayer", package.seeall)

require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleData"
require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleService"
require "script/utils/BaseUI"
require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"

local _bgLayer             = nil	--主lyaer
local _layerSize           = nil	
local _nowIndex            = 1	--当前抽奖档次
local _topBg               = nil
local _bottomBg            = nil
local _itemsPanel          = nil
local _itemsPanelContainer = nil
local _haveTimeDes         = nil
local _updateTimer         = nil
local _getRewardButton     = 1
local _havaRaffleDes       = nil
local _raffleButton        = nil
local _downArrowSp         = nil
local _upArrowSp           = nil
local _raffleWordNum 	   = nil
local _raffleWordNum2 	   = nil
local _wordMesg 		   = nil
local _raffleTip		   = nil

----------------------------[[ 初始化 ]]--------------------------
function init( ... )
	_bgLayer             = nil
	_topBg               = nil
	_bottomBg            = nil
	_itemsPanel          = nil
	_itemsPanelContainer = nil
	_haveTimeDes         = nil
	_updateTimer         = nil
	_getRewardButton	 = nil
	_havaRaffleDes 	   	 = nil
	_raffleButton		 = nil
	_downArrowSp		 = nil
	_upArrowSp			 = nil
	_raffleWordNum 	   	 = nil
	_raffleWordNum2 	 = nil
	_wordMesg 		     = nil
	_raffleTip 			 = nil
end

-----------------------------[[ 节点事件 ]]------------------------------
function registerNodeEvent( ... )
	_bgLayer:registerScriptHandler(function ( nodeType )
		if(nodeType == "exit") then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
			_haveTimeDes   = nil
			_havaRaffleDes = nil
			_raffleButton  = nil
		end
	end)
end


----------------------------[[ 创建ui ]]--------------------------
function create( ... )

	init()
	_bgLayer = CCLayer:create()
	MainScene.setMainSceneViewsVisible(true, false, false)
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local  activeMainWidth  = RechargeActiveMain.getBgWidth()
	local menuLayerSize     = MenuLayer.getLayerContentSize()
	_layerSize              = {width= 0, height=0}
	_layerSize.width        = g_winSize.width 
	_layerSize.height       =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX- activeMainWidth
	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

	
	ChargeRaffleService.getInfo(function ( ... )
		createTopAndButtonUi()
		createTabMenu()
		createItemPanel()
		createItemsInPanel(_nowIndex)
		createOther()
		updateUi()
		_updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeFunc, 1, false)
	end)
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

	local recharge_word_bg = CCSprite:create("images/recharge/rechargeRaffle/recharge_word_bg.png")
	recharge_word_bg:setPosition(_topBg:getContentSize().width/2, _topBg:getContentSize().height/2)
	recharge_word_bg:setAnchorPoint(ccp(0.5, 0.5))
	_topBg:addChild(recharge_word_bg)
	

	local recharge_word = CCSprite:create("images/recharge/rechargeRaffle/recharge_word.png")
	recharge_word:setPosition(recharge_word_bg:getContentSize().width/2, recharge_word_bg:getContentSize().height/2)
	recharge_word:setAnchorPoint(ccp(0.5, 0.5))
	recharge_word_bg:addChild(recharge_word)

	--bottom
	_bottomBg = CCSprite:create("images/recharge/rechargeRaffle/bottom_bg.png")
	_bottomBg:setPosition(_layerSize.width/2, 0)
	_bottomBg:setAnchorPoint(ccp(0.5, 0))
	_bottomBg:setScale(g_fScaleX)
	_bgLayer:addChild(_bottomBg)

	local bottomDes =  CCRenderLabel:create(GetLocalizeStringBy("lcy_10025"), g_sFontPangWa, 36, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	bottomDes:setPosition(_bottomBg:getContentSize().width * 0.05,_bottomBg:getContentSize().height * 0.5)
	bottomDes:setAnchorPoint(ccp(0, 0.5))
	_bottomBg:addChild(bottomDes)
	bottomDes:setColor(ccc3(0xff,0xf6,00))


	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	_bottomBg:addChild(menu)

	--领奖按钮
	_getRewardButton = createButton("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", GetLocalizeStringBy("lcy_10026"), g_sFontPangWa, 30, ccc3(0xfe, 0xdb, 0x1c))
	_getRewardButton:setAnchorPoint(ccp(0.5,0.5))
	_getRewardButton:setPosition(_bottomBg:getContentSize().width * 0.85, _bottomBg:getContentSize().height/2)
	_getRewardButton:registerScriptTapHandler(getRewardButtonCallback)
	menu:addChild(_getRewardButton)
	if(ChargeRaffleData.getRewardStatus() ~= 1) then
		_getRewardButton:setEnabled(false)
	end


	local firstRewardInfo = ChargeRaffleData.getFirstChargeReward()
	local firstRewardItem = ItemSprite.createCommonIcon(firstRewardInfo.type, firstRewardInfo.tid, firstRewardInfo.num)
	firstRewardItem:setPosition(_bottomBg:getContentSize().width * 0.67, _bottomBg:getContentSize().height * 0.5)
	firstRewardItem:setAnchorPoint(ccp(0.5, 0.5))
	_bottomBg:addChild(firstRewardItem)
	firstRewardItem:setScale(0.8)

	-- local num  = CCRenderLabel:create(tostring(firstRewardInfo.num), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- num:setColor(ccc3(0x00, 0xff, 0x18))
	-- num:setAnchorPoint(ccp(1, 0))
	-- num:setPosition(ccpsprite(0.99, 0.01, firstRewardItem))
	-- firstRewardItem:addChild(num)

	-- local name = CCRenderLabel:create(tostring(firstRewardInfo.db.name), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- name:setColor(HeroPublicLua.getCCColorByStarLevel(firstRewardInfo.db.quality))
	-- name:setAnchorPoint(ccp(0.5, 1))
	-- name:setPosition(ccpsprite(0.5, -0.1, firstRewardItem))
	-- firstRewardItem:addChild(name)
end


--[[
	@des:	创建分页按钮
]]
function createTabMenu( )
	local radioMenu = BTMenu:create()
	radioMenu:setAnchorPoint(ccp(0, 0))
	radioMenu:setPosition(ccp(0, 0))
	radioMenu:setStyle(kMenuRadio)
	_bgLayer:addChild(radioMenu, 3)

	local lineSprite = CCSprite:create("images/recharge/rechargeRaffle/line.png")
	lineSprite:setAnchorPoint(ccp(0, 1))
	lineSprite:setPosition(0, _layerSize.height - 154* MainScene.elementScale)
	_bgLayer:addChild(lineSprite,3)
	lineSprite:setScale(g_fScaleX)
	--青铜
	local tab1Button = createTabButton(GetLocalizeStringBy("lcy_1002" .. 1) .. GetLocalizeStringBy("lcy_10027"), ccc3(0x00, 0xff, 0x18))
	tab1Button:setAnchorPoint(ccp(0,0))
	tab1Button:setPosition(10*MainScene.elementScale, _layerSize.height - 160 * MainScene.elementScale)
	tab1Button:setScale(MainScene.elementScale)
	tab1Button:registerScriptTapHandler(radioButtonCallback)
	radioMenu:addChild(tab1Button, 1, 1)
	
	--白银
	local tab2Button = createTabButton(GetLocalizeStringBy("lcy_1002" .. 2) .. GetLocalizeStringBy("lcy_10027"), ccc3(0x00, 0xe4, 0xff))
	tab2Button:setAnchorPoint(ccp(0,0))
	tab2Button:setPosition(1*MainScene.elementScale + tab1Button:getContentSize().width* MainScene.elementScale + tab1Button:getPositionX(), _layerSize.height - 160 * MainScene.elementScale)
	tab2Button:setScale(MainScene.elementScale)
	tab2Button:registerScriptTapHandler(radioButtonCallback)
	radioMenu:addChild(tab2Button, 1, 2)
	
	--黄金
	local tab3Button = createTabButton(GetLocalizeStringBy("lcy_1002" .. 3) .. GetLocalizeStringBy("lcy_10027"), ccc3(0xe4, 0x00, 0xff))
	tab3Button:setAnchorPoint(ccp(0,0))
	tab3Button:setPosition(1*MainScene.elementScale + tab2Button:getContentSize().width* MainScene.elementScale + tab2Button:getPositionX(), _layerSize.height - 160 * MainScene.elementScale)
	tab3Button:setScale(MainScene.elementScale)
	tab3Button:registerScriptTapHandler(radioButtonCallback)
	radioMenu:addChild(tab3Button, 1, 3)
	
	if(_nowIndex == 1) then
		radioMenu:setMenuSelected(tab1Button)
	elseif(_nowIndex == 2) then
		radioMenu:setMenuSelected(tab2Button)
	elseif(_nowIndex == 3) then
		radioMenu:setMenuSelected(tab3Button)
	end
end 


function createItemPanel( ... )


	local roleSprite = CCSprite:create("images/recharge/rechargeRaffle/role.png")
	roleSprite:setAnchorPoint(ccp(0, 0.5))
	roleSprite:setPosition(ccp(0, _layerSize.height*0.5))
	_bgLayer:addChild(roleSprite)
	roleSprite:setScale(MainScene.elementScale)

	local pHeight = _layerSize.height - _topBg:getContentSize().height * g_fScaleX - _bottomBg:getContentSize().height * g_fScaleX - 200 *MainScene.elementScale
	_itemsPanel = CCScale9Sprite:create("images/common/s9_4.png")
	_itemsPanel:setContentSize(CCSizeMake(_layerSize.width * 0.55 - 4, pHeight))
	-- _itemsPanel:setContentSize(CCSizeMake(640, 294))
	_itemsPanel:setAnchorPoint(ccp(1, 1))
	_itemsPanel:setPosition(_layerSize.width, _layerSize.height - 190*MainScene.elementScale)
	_bgLayer:addChild(_itemsPanel)

	print("_itemsPanel:getContentSize().height:",_itemsPanel:getContentSize().height)


	_itemsPanelContainer = CCScrollView:create()
	_itemsPanelContainer:setTouchEnabled(true)
	_itemsPanelContainer:setViewSize(CCSizeMake(_itemsPanel:getContentSize().width, _itemsPanel:getContentSize().height - 20*MainScene.elementScale))
	_itemsPanelContainer:setContentSize(CCSizeMake(_itemsPanel:getContentSize().width, _itemsPanel:getContentSize().height))
	_itemsPanelContainer:setPosition(0, 5 * MainScene.elementScale)
	_itemsPanelContainer:getContainer():setPosition(0, 0)
	_itemsPanelContainer:setDirection(kCCScrollViewDirectionVertical)
	_itemsPanel:addChild(_itemsPanelContainer, 10)
	_itemsPanelContainer:setTouchPriority(-1100)



	local titleBg = CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleBg:setContentSize(CCSizeMake(140, 35))
	titleBg:setPosition(_itemsPanel:getContentSize().width/2,  _itemsPanel:getContentSize().height)
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_itemsPanel:addChild(titleBg)
	titleBg:setScale(MainScene.elementScale)

	local titleDes =  CCRenderLabel:create(GetLocalizeStringBy("lcy_10028"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleDes:setAnchorPoint(ccp(0.5, 0.5))
	titleDes:setPosition(ccp(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2))
	titleDes:setColor(ccc3(0xff, 0xf6, 0x1c))
	titleBg:addChild(titleDes)


	-- 向上的箭头
	_upArrowSp = CCSprite:create( "images/common/arrow_up_h.png")
	_upArrowSp:setPosition(_itemsPanelContainer:getContentSize().width*0.9, _itemsPanelContainer:getContentSize().height-5)
	_upArrowSp:setAnchorPoint(ccp(0.5,1))
	_itemsPanel:addChild(_upArrowSp,100, 101)
	_upArrowSp:setVisible(false)
	_upArrowSp:setScale(MainScene.elementScale)

	-- 向下的箭头
	_downArrowSp = CCSprite:create( "images/common/arrow_down_h.png")
	_downArrowSp:setPosition(_itemsPanelContainer:getContentSize().width*0.9, 5)
	_downArrowSp:setAnchorPoint(ccp(0.5,0))
	_itemsPanel:addChild(_downArrowSp,100, 102)
	_downArrowSp:setVisible(true)
	_downArrowSp:setScale(MainScene.elementScale)

	arrowAction(_downArrowSp)
	arrowAction(_upArrowSp)
end

function createItemsInPanel( p_index )
	_itemsPanelContainer:getContainer():removeAllChildrenWithCleanup(true)

	local itemsInfo = ChargeRaffleData.getRaffleItems(p_index)
	print("itemsInfo:")
	print_table("itemsInfo", itemsInfo)

	local menu = BTMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	_itemsPanelContainer:addChild(menu,200)
	menu:setScrollView(_itemsPanelContainer)

	local l,r = 3,5
	local i = 0
	local pHeight = r * (90*MainScene.elementScale + 30*MainScene.elementScale) +  50*MainScene.elementScale
	_itemsPanelContainer:setContentSize(CCSizeMake(_itemsPanelContainer:getContentSize().width, pHeight))
	_itemsPanelContainer:setContentOffset(ccp(0, _itemsPanelContainer:getViewSize().height - _itemsPanelContainer:getContentSize().height))
	for k,v in pairs(itemsInfo) do
		local item = ItemSprite.getItemSpriteById(v.tid)
		local xw   = (_itemsPanelContainer:getContentSize().width  - 50*MainScene.elementScale - item:getContentSize().width*MainScene.elementScale * l)/(l-1)
		local xv   = i - math.floor(i/l)*l
		local x    = 25*MainScene.elementScale + item:getContentSize().width*MainScene.elementScale*xv +  xw*xv
		
		local yv   = (_itemsPanelContainer:getContentSize().height - item:getContentSize().height*MainScene.elementScale * r)/(r+1)
		local yd   = yv + math.floor(i/l)*(item:getContentSize().height*MainScene.elementScale +yv)
		local y    = _itemsPanelContainer:getContentSize().height - yd - item:getContentSize().height*MainScene.elementScale

		item:setPosition(x, y)
		item:setAnchorPoint(ccp(0, 0))
		_itemsPanelContainer:addChild(item,1, v.tid)
		item:setScale(MainScene.elementScale)

		local num  = CCRenderLabel:create(tostring(v.num), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		num:setColor(ccc3(0x00, 0xff, 0x18))
		num:setAnchorPoint(ccp(1, 0))
		num:setPosition(ccpsprite(0.99, 0.01, item))
		item:addChild(num)

		local name = CCRenderLabel:create(tostring(v.db.name), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		name:setColor(HeroPublicLua.getCCColorByStarLevel(v.db.quality))
		name:setAnchorPoint(ccp(0.5, 1))
		name:setPosition(ccpsprite(0.5, -0.03, item))
		item:addChild(name)

		i = i + 1
	end
end

function createOther( ... )

	--活动开启时间
	local startTimeTitle =  CCRenderLabel:create(GetLocalizeStringBy("lcy_10029"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	startTimeTitle:setPosition(_layerSize.width * 0.2, _layerSize.height - _topBg:getContentSize().height*g_fScaleX - 15 * MainScene.elementScale)
	startTimeTitle:setAnchorPoint(ccp(1, 0.5))
	_bgLayer:addChild(startTimeTitle)
	startTimeTitle:setColor(ccc3(0x00,0xe4,0xff))
	startTimeTitle:setScale(MainScene.elementScale)

	local startTimeDes =  CCRenderLabel:create( ChargeRaffleData.getOpenTimeDes() .. "--" .. ChargeRaffleData.getEndTimeDes() , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	startTimeDes:setPosition(startTimeTitle:getPositionX() + 20*MainScene.elementScale, _layerSize.height - _topBg:getContentSize().height*g_fScaleX - 15 * MainScene.elementScale)
	startTimeDes:setAnchorPoint(ccp(0, 0.5))
	_bgLayer:addChild(startTimeDes)
	startTimeDes:setColor(ccc3(0x00,0xff,0x18))
	startTimeDes:setScale(MainScene.elementScale)


	local haveTimeTitle =  CCRenderLabel:create(GetLocalizeStringBy("lcy_10030"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	haveTimeTitle:setPosition(_layerSize.width * 0.2,  _layerSize.height - _topBg:getContentSize().height*g_fScaleX - 35 * MainScene.elementScale)
	haveTimeTitle:setAnchorPoint(ccp(1, 0.5))
	_bgLayer:addChild(haveTimeTitle)
	haveTimeTitle:setColor(ccc3(0x00,0xe4,0xff))
	haveTimeTitle:setScale(MainScene.elementScale)

	_haveTimeDes =  CCLabelTTF:create( ChargeRaffleData.getHaveTimeDes() , g_sFontPangWa, 18)
	_haveTimeDes:setPosition(haveTimeTitle:getPositionX() + 20*MainScene.elementScale, _layerSize.height - _topBg:getContentSize().height*g_fScaleX - 35 * MainScene.elementScale)
	_haveTimeDes:setAnchorPoint(ccp(0, 0.5))
	_bgLayer:addChild(_haveTimeDes)
	_haveTimeDes:setColor(ccc3(0x00,0xff,0x18))
	_haveTimeDes:setScale(MainScene.elementScale)

	
	--活动结束时间

	--剩余抽奖次数
	local havaRaffleTitle =  CCRenderLabel:create(GetLocalizeStringBy("lcy_10019") .. GetLocalizeStringBy("lcy_1002" .. _nowIndex) ..  GetLocalizeStringBy("lcy_10020"), g_sFontPangWa, 24,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	havaRaffleTitle:setPosition(_bottomBg:getContentSize().width * 0.07,_bottomBg:getContentSize().height * g_fScaleX + 25 *g_fScaleX)
	havaRaffleTitle:setAnchorPoint(ccp(0, 0.5))
	_bgLayer:addChild(havaRaffleTitle)
	havaRaffleTitle:setColor(ccc3(0xff,0xf6,00))
	havaRaffleTitle:setScale(MainScene.elementScale)
	havaRaffleTitle:setVisible(false)

	_havaRaffleDes =  CCLabelTTF:create(ChargeRaffleData.getCanRaffleNum(_nowIndex), g_sFontPangWa, 24)
	_havaRaffleDes:setPosition(havaRaffleTitle:getContentSize().width * MainScene.elementScale  + havaRaffleTitle:getPositionX() + 15*MainScene.elementScale,_bottomBg:getContentSize().height * g_fScaleX + 25 *g_fScaleX)
	_havaRaffleDes:setAnchorPoint(ccp(0, 0.5))
	_bgLayer:addChild(_havaRaffleDes)
	_havaRaffleDes:setColor(ccc3(0x00,0xff,0x18))
	_havaRaffleDes:setScale(MainScene.elementScale)
	_havaRaffleDes:setVisible(false)

	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	_bgLayer:addChild(menu)

	--抽奖按钮
	-- local raffleButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png", CCSizeMake(150,73), GetLocalizeStringBy("lcy_10024"), ccc3(255,222,0))
	_raffleButton = createButton("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", GetLocalizeStringBy("lcy_10024"), g_sFontPangWa, 30, ccc3(0xfe, 0xdb, 0x1c), CCSizeMake(171, 73))
	_raffleButton:setAnchorPoint(ccp(0.5,0.5))
	_raffleButton:setPosition(_bottomBg:getContentSize().width * g_fScaleX * 0.75, _bottomBg:getContentSize().height * g_fScaleX + 25 *g_fScaleX)
	_raffleButton:registerScriptTapHandler(raffleButtonCallback)
	menu:addChild(_raffleButton)
	_raffleButton:setScale(MainScene.elementScale)


	local  rechargeBtn = CCMenuItemImage:create("images/common/btn/btn_recharge_n.png", "images/common/btn/btn_recharge_h.png")
	rechargeBtn:setAnchorPoint(ccp(1, 1))
	rechargeBtn:setPosition(ccp(_layerSize.width * 0.95, _layerSize.height *0.89))
	rechargeBtn:registerScriptTapHandler(rechargeAction)
	menu:addChild(rechargeBtn)
	rechargeBtn:setScale(MainScene.elementScale)


	--
	local raffleWord = CCSprite:create("images/recharge/rechargeRaffle/raffle_word.png")
	raffleWord:setPosition(ccp(_layerSize.width * 0.22, _layerSize.height * 0.3))
	raffleWord:setAnchorPoint(ccp(0.5, 0))
	_bgLayer:addChild(raffleWord)
	raffleWord:setScale(MainScene.elementScale)
	
	_raffleWordNum =  CCLabelTTF:create(ChargeRaffleData.getCostMoney(_nowIndex), g_sFontPangWa, 25)
	_raffleWordNum:setPosition(127, raffleWord:getContentSize().height/2)
	_raffleWordNum:setAnchorPoint(ccp(0.5, 0.5))
	raffleWord:addChild(_raffleWordNum,2)
	_raffleWordNum:setColor(ccc3(0xff,0xf6,0x00))

	_raffleWordNum2 =  CCLabelTTF:create(ChargeRaffleData.getCostMoney(_nowIndex), g_sFontPangWa, 28)
	_raffleWordNum2:setPosition(127, raffleWord:getContentSize().height/2)
	_raffleWordNum2:setAnchorPoint(ccp(0.5, 0.5))
	raffleWord:addChild(_raffleWordNum2)
	_raffleWordNum2:setColor(ccc3(0x00,0x00,0x00))

	if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
		_raffleWordNum:setPosition(155, raffleWord:getContentSize().height/2)
		_raffleWordNum2:setPosition(155, raffleWord:getContentSize().height/2)
	end

	_raffleTip = CCSprite:create("images/recharge/rechargeRaffle/0" .. _nowIndex .. ".png")
	_raffleTip:setPosition(ccp(_layerSize.width * 0.22, raffleWord:getPositionY() - 10*MainScene.elementScale))
	_raffleTip:setAnchorPoint(ccp(0.5, 1))
	_bgLayer:addChild(_raffleTip)
	_raffleTip:setScale(MainScene.elementScale)

	--(每日仅限一次)
	_wordMesg =  CCRenderLabel:create(GetLocalizeStringBy("lcy_10039"), g_sFontPangWa, 21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_wordMesg:setPosition(_layerSize.width * 0.22, _raffleTip:getPositionY() - _raffleTip:getContentSize().height*MainScene.elementScale - 10*MainScene.elementScale)
	_wordMesg:setAnchorPoint(ccp(0.5, 1))
	_bgLayer:addChild(_wordMesg)
	_wordMesg:setColor(ccc3(0xff,0xff,0xff))
	_wordMesg:setScale(MainScene.elementScale)


end
--------------------------[[ 更新ui方法 ]] -------------------
function updateUi( ... )
	if(_havaRaffleDes) then
		_havaRaffleDes:setString(ChargeRaffleData.getCanRaffleNum(_nowIndex))
	end
	if(_raffleButton) then
		if(ChargeRaffleData.getCanRaffleNum(_nowIndex) <= 0) then
			_raffleButton:setEnabled(false)
		else
			_raffleButton:setEnabled(true)
		end
	end

	_raffleWordNum:setString(ChargeRaffleData.getCostMoney(_nowIndex))
	_raffleWordNum2:setString(ChargeRaffleData.getCostMoney(_nowIndex))
	local texture = CCSprite:create("images/recharge/rechargeRaffle/0" .. _nowIndex .. ".png")
	_raffleTip:setTexture(texture:getTexture())
end

--充值后刷新数据回调
function updateChargeInfo( ... )
	local requestCallfunc = function ( ... )
		updateUi()
	end
	if(ActivityConfigUtil.isActivityOpen("chargeRaffle") == true and _havaRaffleDes ~= nil) then
		ChargeRaffleService.getInfo(requestCallfunc)
	end
end

------------------------- [[ 事件回调 ]] ----------------------

---
-- 定时器
-- @function updateTimeFunc 
function updateTimeFunc( ... )
	if(_haveTimeDes) then
		if(ChargeRaffleData.getHaveTimeInteral() <= 0) then
			_haveTimeDes:setString(GetLocalizeStringBy("lcy_10032"))
		else
			_haveTimeDes:setString(ChargeRaffleData.getHaveTimeDes())
		end
	end
	updateArrow()
end

function updateArrow( ... )
	local offset =  _itemsPanelContainer:getContentSize().height+ _itemsPanelContainer:getContentOffset().y- _itemsPanelContainer:getViewSize().height
	if(_upArrowSp~= nil )  then
		if(offset>1 or offset<-1) then
			_upArrowSp:setVisible(true)
		else
			_upArrowSp:setVisible(false)
		end
	end
	if(_downArrowSp ~= nil) then
		if( _itemsPanelContainer:getContentOffset().y ~=0) then
			_downArrowSp:setVisible(true)
		else
			_downArrowSp:setVisible(false)
		end
	end
end


---
-- 领取按钮回调事件
-- @function getRewardButtonCallback 
function radioButtonCallback( tag,sender )
	_nowIndex = tag
	print("now Select index = ", tag)
	createItemsInPanel(_nowIndex)
	updateUi()
end

---
-- 领取按钮回调事件
-- @function getRewardButtonCallback 
function getRewardButtonCallback( tag,sender )
	local showItemList = function ( ... )
		local rewardInfo = ChargeRaffleData.getFirstChargeRewardForItemList()
		local itemLayer = GoodTableView.ItemTableView:create(rewardInfo)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(itemLayer, 20)
		print("showItemTableView")
	end

	local requestCallfunc = function ( ... )
		_getRewardButton:setEnabled(false)
		showItemList()
	end

	if(ChargeRaffleData.getRewardStatus() == 1) then
		ChargeRaffleService.getReward(requestCallfunc)
	end
end

---
-- 抽奖按钮回调事件
-- @function raffleButtonCallback 
function raffleButtonCallback(  tag,sender  )
	if(ItemUtil.isBagFull() == true )then
		return
	end

	require "script/ui/rechargeActive/RechargeActiveMain"
	require "script/ui/rechargeActive/chargeRaffle/RaffleItemLayer"
	local  layer = RaffleItemLayer.create(_nowIndex)
	RechargeActiveMain.changeButtomLayer(layer)
end


-- 充值
function rechargeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local layer = RechargeLayer.createLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer,1111)
end

---------------------- [[ 工具方法 ]] ------------------------------
function createTabButton( p_buttonName,p_color )
	local tab1NorSprite = CCScale9Sprite:create("images/common/btn/tab_button/btn1_n.png")
	tab1NorSprite:setContentSize(CCSizeMake(120,43))
	local tab1HigSprite = CCScale9Sprite:create("images/common/btn/tab_button/btn1_h.png")
	tab1HigSprite:setContentSize(CCSizeMake(120,53))

	local tab1Button = CCMenuItemSprite:create(tab1NorSprite,tab1HigSprite)

	local tab1ButtonDes =  CCRenderLabel:create(p_buttonName, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tab1ButtonDes:setAnchorPoint(ccp(0.5, 0.5))
	tab1ButtonDes:setPosition(ccp(tab1Button:getContentSize().width/2, tab1Button:getContentSize().height/2))
	tab1ButtonDes:setColor( p_color or ccc3(0xfe, 0xdb, 0x1c))
	tab1Button:addChild(tab1ButtonDes)

	return tab1Button
end

function createButton( p_norImage, p_higImage, p_word, p_font, p_size, p_color,p_buttonSize)
	-- body
	local norSprite = CCScale9Sprite:create(p_norImage)
	if(p_buttonSize ~= nil) then
		norSprite:setContentSize(p_buttonSize)
	end	
	local norWord   = CCRenderLabel:create(p_word, p_font, p_size, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	norWord:setColor(p_color)
	norWord:setPosition(norSprite:getContentSize().width/2, norSprite:getContentSize().height/2)
	norWord:setAnchorPoint(ccp(0.5, 0.5))
	norSprite:addChild(norWord)


	local higSprite = CCScale9Sprite:create(p_higImage)
	if(p_buttonSize ~= nil) then
		higSprite:setContentSize(p_buttonSize)
	end
	local higWord   = CCRenderLabel:create(p_word, p_font, p_size, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	higWord:setColor(p_color)
	higWord:setPosition(higSprite:getContentSize().width/2, higSprite:getContentSize().height/2)
	higWord:setAnchorPoint(ccp(0.5, 0.5))
	higSprite:addChild(higWord)


	local disSprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	if(p_buttonSize ~= nil) then
		disSprite:setContentSize(p_buttonSize)
	end
	local disWord   = CCRenderLabel:create(p_word, p_font, p_size, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	disWord:setColor(ccc3(90, 90, 90))
	disWord:setPosition(disSprite:getContentSize().width/2, disSprite:getContentSize().height/2)
	disWord:setAnchorPoint(ccp(0.5, 0.5))
	disSprite:addChild(disWord)

	local button = CCMenuItemSprite:create(norSprite, higSprite, disSprite)
	return button
end

-- 箭头的动画
function arrowAction( arrow)
	local arrActions_2 = CCArray:create()
	arrActions_2:addObject(CCFadeOut:create(1))
	arrActions_2:addObject(CCFadeIn:create(1))
	local sequence_2 = CCSequence:create(arrActions_2)
	local action_2 = CCRepeatForever:create(sequence_2)
	arrow:runAction(action_2)
end


-- Filename: RedPacketLayer.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 红包主界面
require "script/ui/redpacket/RedPacketController"
module("RedPacketLayer" , package.seeall)

local IMG_PATH = "images/redpacket/"
local _layer					= nil
local _tableView 				= nil
local _activeDataCopy			= nil
local _packBackground			= nil
local _packetData 				= nil
local _leftGoldLabel 			= nil
local _itemBg					= nil
local _goldPanel 				= nil
local _leftGoldNumLabel 		= nil
local _goldLabel 				= nil
local _redPacketItem 			= nil
local _goldNode 				= nil
local _allPacketButton			= nil
local _menuBar 					= nil
local _tableViewHeight 			= 0
local _radio_data 				= {}
local _isRob 					= 1
local _isLook 					= 2
local _isRedLayer 				= false
local _curIndex 				= 1

function init( )
	_radio_data 				= {}
	_isRedLayer 				= false
	_menuBar 					= nil
	_allPacketButton			= nil
	_goldLabel 					= nil
	_redPacketItem 				= nil
	_goldPanel 					= nil
	_goldNode 					= nil
	_leftGoldNumLabel 			= nil
 	_layer 						= nil
 	_tableView 					= nil
 	_activeDataCopy				= nil
	_packBackground 			= nil
	_packetData 				= nil
	_leftGoldLabel 				= nil
	_itemBg						= nil
	_curIndex 					= 1
	_tableViewHeight 			= 0
end

--设置是否在红包界面
function setIsRedLayer( pIsRed )
	_isRedLayer = pIsRed
end

--获取是否在红包界面
function getIsRedLayer()
	return _isRedLayer
end

function freshTableView( pInfo )
	-- body
	if(_tableView~=nil)then
		_tableView:removeFromParentAndCleanup(true)
		_tableView = nil
	end
	createTableView(pInfo)
end

function freshUI( pInfo )
	print("--------")
	print_t(pInfo)
	print("--------")
	--推送采取在本界面刷本界面，不在本界面在主页的话刷新主页红包，故作如下判断
	if tolua.isnull(_layer) then
		setIsRedLayer(false)
		if(MainScene.getOnRunningLayerSign() == "main_base_layer")then
			require "script/ui/main/MainBaseLayer"
			local main_base_layer = MainBaseLayer.create()
			MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	        MainScene.setMainSceneViewsVisible(true,true,true)
	    end
		return
	end

	_leftGoldNumLabel:setString(pInfo.canSendTotal)
	_goldLabel:setPosition(ccp(_leftGoldNumLabel:getPositionX()+_leftGoldNumLabel:getContentSize().width,0))
	local goldNodeWidth = _leftGoldLabel:getContentSize().width+_leftGoldNumLabel:getContentSize().width+_goldLabel:getContentSize().width
	_goldNode:setContentSize(CCSizeMake(goldNodeWidth,_leftGoldLabel:getContentSize().height))

	freshTableView(pInfo)
end

function menuBarCb(tag,item)
    if(_curIndex == tag)then
        return
    end
    RedPacketData.setClickTag(tag)
    _curIndex = tag
    RedPacketController.getInfo(freshUI,_curIndex)
end

local function sendPacketAction( tag,item )
	_packetData = RedPacketData.getRedPacketData()
	if(tonumber(_packetData.canSendTotal)==0)then
		--没充值
		AnimationTip.showTip(GetLocalizeStringBy("llp_313"))
		return
	end
	if(tonumber(_packetData.canSendTotal)~=0 and tonumber(_packetData.canSendToday)==0)then
		--今日可发的金额已经发完
		AnimationTip.showTip(GetLocalizeStringBy("llp_322"))
		return
	end
	if(tonumber(_packetData.canSendToday)<tonumber(ActiveCache.getRedPacketMinGold()))then
		--今日可发金额小余最小发红包金额
		AnimationTip.showTip(GetLocalizeStringBy("llp_313"))
		return
	end
	require "script/ui/redpacket/SendPacketDialog"
    SendPacketDialog.showDialog()
end

function selectRadio( index )
	if tolua.isnull(_layer) then
		setIsRedLayer(false)
		if(MainScene.getOnRunningLayerSign() == "main_base_layer")then
			require "script/ui/main/MainBaseLayer"
			local main_base_layer = MainBaseLayer.create()
			MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	        MainScene.setMainSceneViewsVisible(true,true,true)
	    end
		return
	end
	local menuItem = _radio_data.items[index]
	_radio_data.reallyCallback(index, menuItem)
end

local function activeDesAction( ... )
	require "script/ui/redpacket/RedPacketIntroLayer"
	--活动说明
	RedPacketIntroLayer.showLayer(-570,10)
end

local function createRadioMenu( ... )
	--创建标签
    require "script/libs/LuaCCMenuItem"
    
	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	local btn_size_n	= CCSizeMake(180, 50)
	local btn_size_n2	= CCSizeMake(180, 50)
	local btn_size_h	= CCSizeMake(180, 55)
	local btn_size_h2	= CCSizeMake(180, 55)
	
	local text_color_n	= ccc3(0xf2, 0xe0, 0xcc)
	local text_color_h	= ccc3(0xff, 0xff, 0xff)
	local font			= g_sFontPangWa
	local font_size		= 30
	local strokeCor_n	= ccc3(0xf2, 0xe0, 0xcc)
	local strokeCor_h	= ccc3(0x00, 0x00, 0x00)
	local stroke_size_n	= 0
    local stroke_size_h = 1

    _radio_data = {}
    _radio_data.touch_priority = - 550
    _radio_data.space = -2
    _radio_data.callback = menuBarCb
    _radio_data.direction = 1
    _radio_data.defaultIndex = _curIndex
    _radio_data.items = {}

    _allPacketButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("llp_292"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    local guildPacketButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("llp_293"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    local myPacketButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("llp_294"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    table.insert(_radio_data.items,_allPacketButton)
    table.insert(_radio_data.items,guildPacketButton)
    table.insert(_radio_data.items,myPacketButton)
    _menuBar = LuaCCSprite.createRadioMenuWithItems(_radio_data)
    _menuBar:setScale(g_fElementScaleRatio)
    _menuBar:setAnchorPoint(ccp(0.5,0))
    _goldPanel:addChild(_menuBar)
end

function createDesUI()
	local bgWidth = _packBackground:getContentSize().width
	local bgHeight = _packBackground:getContentSize().height
	local packetActiveSprite = CCSprite:create(IMG_PATH.."redpacketword.png")
		  packetActiveSprite:setScale(g_fElementScaleRatio)
		  packetActiveSprite:setAnchorPoint(ccp(0.5,1))
		  packetActiveSpriteYPos = _layer:getContentSize().height-RechargeActiveMain.getBgWidth()-RechargeActiveMain.getTopSize().height*g_fScaleX
		  packetActiveSprite:setPosition(ccp(_layer:getContentSize().width*0.5,packetActiveSpriteYPos))
	_layer:addChild(packetActiveSprite)
	-- 开始时间
    local startTime = ActiveCache.getRedPacketStartTime()
    local startTimeStr = TimeUtil.getTimeToMin( tonumber(startTime) ) or " "
    -- 结束时间
    local endTime = ActiveCache.getRedPacketEndTime()
    local endTimeStr = TimeUtil.getTimeToMin( tonumber(endTime) ) or " "
    local timeStr = startTimeStr .. "-" ..  endTimeStr
	local timeLabel = CCRenderLabel:create(timeStr,g_sFontName,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  timeLabel:setScale(g_fElementScaleRatio)
		  timeLabel:setColor(ccc3(0x00,0xff,0x00))
		  timeLabel:setAnchorPoint(ccp(0.5,1))
		  timeLabelYPos = packetActiveSprite:getPositionY()-packetActiveSprite:getContentSize().height*0.3*g_fElementScaleRatio-10
		  timeLabel:setPosition(ccp(packetActiveSprite:getPositionX()+10,timeLabelYPos))
	_layer:addChild(timeLabel,4)
	
	local menu = CCMenu:create()
		  menu:setPosition(ccp(0,0))
	_packBackground:addChild(menu)
	local activeDesItem = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
		  activeDesItem:setAnchorPoint(ccp(0,1))
		  activeDesItem:setPosition(ccp(10,_packBackground:getContentSize().height-10))
		  activeDesItem:registerScriptTapHandler(activeDesAction)
	menu:addChild(activeDesItem)

	local desSprite = CCSprite:create(IMG_PATH.."descword.png")
		  desSprite:setAnchorPoint(ccp(0.5,1))
		  desSpriteYPos = activeDesItem:getPositionY()-activeDesItem:getContentSize().height-20
		  desSprite:setPosition(ccp(desSprite:getContentSize().width*0.5+10,desSpriteYPos))
	_packBackground:addChild(desSprite)

	local sendMenu = CCMenu:create()
		  sendMenu:setAnchorPoint(ccp(0,0))
		  sendMenu:setPosition(ccp(0,0))
	_layer:addChild(sendMenu)
	local _redPacketItem = CCMenuItemImage:create(IMG_PATH.."sendpacket1.png",IMG_PATH.."sendpacket2.png")
		  _redPacketItem:setScale(g_fElementScaleRatio)
		  _redPacketItem:setAnchorPoint(ccp(0.5,1))
		  _redPacketItemYPos = timeLabel:getPositionY()-timeLabel:getContentSize().height*g_fElementScaleRatio-10
		  _redPacketItem:setPosition(ccp(packetActiveSprite:getPositionX()+10,_redPacketItemYPos))
		  _redPacketItem:registerScriptTapHandler(sendPacketAction)
	sendMenu:addChild(_redPacketItem)

	_goldNode = CCNode:create()
	_goldNode:setAnchorPoint(ccp(0.5,0))
	_goldNodeYPos = _redPacketItem:getPositionY()-_redPacketItem:getContentSize().height*g_fElementScaleRatio-10
	_goldNode:setPosition(ccp(packetActiveSprite:getPositionX()+10,_goldNodeYPos))

	_leftGoldLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_300"),g_sFontName,23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_leftGoldLabel:setAnchorPoint(ccp(0,1))
	_leftGoldLabel:setPosition(ccp(0,0))
	_goldNode:addChild(_leftGoldLabel)
	
	_leftGoldNumLabel = CCRenderLabel:create("0",g_sFontName,23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_leftGoldNumLabel:setColor(ccc3(0,255,0))
	_leftGoldNumLabel:setAnchorPoint(ccp(0,1))
	_leftGoldNumLabel:setPosition(ccp(_leftGoldLabel:getContentSize().width,0))
	_goldNode:addChild(_leftGoldNumLabel)
	
	_goldLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1508"),g_sFontName,23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_goldLabel:setAnchorPoint(ccp(0,1))
	_goldLabel:setPosition(ccp(_leftGoldNumLabel:getPositionX()+_leftGoldNumLabel:getContentSize().width,0))
	_goldNode:addChild(_goldLabel)

	local goldNodeWidth = _leftGoldLabel:getContentSize().width+_leftGoldNumLabel:getContentSize().width+_goldLabel:getContentSize().width
	_goldNode:setContentSize(CCSizeMake(goldNodeWidth,_leftGoldLabel:getContentSize().height))
	_goldNode:setScale(g_fElementScaleRatio)
	_layer:addChild(_goldNode)
	
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height)*g_fScaleX
	
	-- 金色的条
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()
	_goldPanel = CCScale9Sprite:create("images/recharge/" .. "gift_panel.png")
	createRadioMenu()

	_tableViewHeight = height-packetActiveSprite:getContentSize().height*g_fElementScaleRatio-timeLabel:getContentSize().height*g_fElementScaleRatio-_redPacketItem:getContentSize().height*g_fElementScaleRatio-_goldNode:getContentSize().height*g_fElementScaleRatio-_allPacketButton:getContentSize().height*_allPacketButton:getScale()+30

	_goldPanel:setContentSize(CCSizeMake(640*g_fScaleX,_tableViewHeight))
	_goldPanel:setAnchorPoint(ccp(0.5,0))
	_goldPanel:setPosition(ccp(_layer:getContentSize().width*0.5,menuLayerSize.height*g_fScaleX))
	_layer:addChild(_goldPanel)
	-- 物品的背景
	_itemBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_itemBg:setContentSize(CCSizeMake(640*g_fScaleX-30,_tableViewHeight-40))
	_itemBg:setPosition(ccp(_goldPanel:getContentSize().width/2, _goldPanel:getContentSize().height/2))
	_itemBg:setAnchorPoint(ccp(0.5,0.5))
	_goldPanel:addChild(_itemBg)

	_menuBar:setPosition(ccp(640*g_fScaleX * 0.45,_goldPanel:getContentSize().height-5))
end

function getNextDialog( pInfo )
	local isHaveRob = RedPacketData.isHaveRob()
	if(isHaveRob)then
		--之前抢过直接显示信息界面
		require "script/ui/redpacket/RedPocketInfoDialog"
		RedPocketInfoDialog.createDialog(pInfo,true)
	else
		--没抢过显示抢红包界面
		require "script/ui/redpacket/OpenRedPacketDialog"
		OpenRedPacketDialog.createDialog(pInfo)
	end
end

local function robOrLookAction( tag,item )
	RedPacketController.getSingleRedPacketInfo(getNextDialog,tag)
end

local function afterCloseForOpen( pInfo )
	require "script/ui/redpacket/RedPocketInfoDialog"
	RedPocketInfoDialog.createDialog(pInfo,true)
end

local function lookAction( tag,item )
	RedPacketController.getSingleRedPacketInfo(afterCloseForOpen,tag)
end

--非我的红包，没过期，有剩余的红包
local function createNormalLeftPacketLabel( pInfo,pCell,labelMenu )
	-- body
	local nameLabel = CCLabelTTF:create(pInfo.uname,g_sFontName,25)
		  nameLabel:setColor(ccc3(255,255,0))
	pCell:addChild(nameLabel)
	local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_298"),g_sFontName,25)
		  label1:setColor(ccc3(0xff,0xeb,0xa3))
		  label1:setPosition(ccp(nameLabel:getContentSize().width,0))
	pCell:addChild(label1)
	local label2 = CCLabelTTF:create(pInfo.left,g_sFontName,25)
		  label2:setColor(ccc3(0xff,0x00,0x00))
		  label2:setPosition(ccp(label1:getContentSize().width+nameLabel:getContentSize().width,0))
	pCell:addChild(label2)
	local label3 = CCLabelTTF:create(GetLocalizeStringBy("llp_299"),g_sFontName,25)
		  label3:setColor(ccc3(0xff,0xeb,0xa3))
		  label3:setPosition(ccp(label2:getPositionX()+label2:getContentSize().width,0))
	pCell:addChild(label3)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_295"),g_sFontName,25)
		  pLable:setColor(ccc3(0xff,0x00,0x00))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:registerScriptTapHandler(robOrLookAction)
		  labelItem:setPosition(ccp(460,0))
		  
	labelMenu:addChild(labelItem,1,pInfo.eid)
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

--非我的红包，没过期，无剩余的红包
local function createNormalNoLeftPacketLabel( pInfo,pCell,labelMenu )
	-- body
	local nameLabel = CCLabelTTF:create(pInfo.uname,g_sFontName,25)
		  nameLabel:setColor(ccc3(255,255,0))
	pCell:addChild(nameLabel)
	local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_297"),g_sFontName,25)
		  label1:setColor(ccc3(0xff,0xeb,0xa3))
		  label1:setPosition(ccp(nameLabel:getContentSize().width,0))
	pCell:addChild(label1)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_296"),g_sFontName,25)
		  pLable:setColor(ccc3(0x00,0xff,0x18))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:setPosition(ccp(460,0))
		  labelItem:registerScriptTapHandler(lookAction)
	labelMenu:addChild(labelItem,1,tonumber(pInfo.eid))
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

--非我的红包，无剩余，过期
local function createNormalNoLeftOverTimePacketLabel( pInfo,pCell,labelMenu )
	-- body
	local nameLabel = CCLabelTTF:create(pInfo.uname,g_sFontName,25)
		  nameLabel:setColor(ccc3(255,255,0))
	pCell:addChild(nameLabel)
	local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_297"),g_sFontName,25)
		  label1:setColor(ccc3(0xff,0xeb,0xa3))
		  label1:setPosition(ccp(nameLabel:getContentSize().width,0))
	pCell:addChild(label1)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_296"),g_sFontName,25)
		  pLable:setColor(ccc3(0x00,0xff,0x18))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:setPosition(ccp(460,0))
		  labelItem:registerScriptTapHandler(lookAction)
	labelMenu:addChild(labelItem,1,tonumber(pInfo.eid))
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

local function createNormalLeftOverTimePacketLabel( pInfo,pCell,labelMenu )
	-- body
	local label1 = CCLabelTTF:create(pInfo.uname,g_sFontName,25)
		  label1:setColor(ccc3(255,255,0))
	pCell:addChild(label1)
	local label2 = CCLabelTTF:create(GetLocalizeStringBy("llp_319"),g_sFontName,25)
		  label2:setColor(ccc3(0xff,0xeb,0xa3))
		  label2:setPosition(ccp(label1:getContentSize().width,2))
	pCell:addChild(label2)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_296"),g_sFontName,25)
		  pLable:setColor(ccc3(0x00,0xff,0x18))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:setPosition(ccp(460,0))
		  labelItem:registerScriptTapHandler(lookAction)
	labelMenu:addChild(labelItem,1,tonumber(pInfo.eid))
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

--自己发的有剩余的
local function createMySendLeftPacketLabel(pInfo,pCell,labelMenu )
	-- body
	local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_314"),g_sFontName,25)
		  label1:setColor(ccc3(0xff,0xeb,0xa3))
	pCell:addChild(label1)
	local label2 = CCLabelTTF:create(pInfo.left,g_sFontName,25)
		  label2:setColor(ccc3(0x00,0xff,0x18))
		  label2:setPosition(ccp(label1:getContentSize().width,0))
	pCell:addChild(label2)
	local label3 = CCLabelTTF:create(GetLocalizeStringBy("llp_315"),g_sFontName,25)
		  label3:setColor(ccc3(0xff,0xeb,0xa3))
		  label3:setPosition(ccp(label2:getPositionX()+label2:getContentSize().width,0))
	pCell:addChild(label3)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_295"),g_sFontName,25)
		  pLable:setColor(ccc3(0xff,0x00,0x00))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:registerScriptTapHandler(robOrLookAction)
		  labelItem:setPosition(ccp(460,0))
		  
	labelMenu:addChild(labelItem,1,pInfo.eid)
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

--自己发的没有剩余的
local function createMySendNoLeftPacketLabel(pInfo,pCell,labelMenu)
	-- body
	local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_297"),g_sFontName,25)
		  label1:setColor(ccc3(0xff,0xeb,0xa3))
	pCell:addChild(label1)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_296"),g_sFontName,25)
		  pLable:setColor(ccc3(0x00,0xff,0x18))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:setPosition(ccp(460,0))
		  labelItem:registerScriptTapHandler(lookAction)
	labelMenu:addChild(labelItem,1,tonumber(pInfo.eid))
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

--自己发的超时的
local function createMySendOverTimePacketLabel(pInfo,pCell,labelMenu)
	-- body
	local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_320"),g_sFontName,25)
		  label1:setColor(ccc3(0xff,0xeb,0xa3))
	pCell:addChild(label1)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_296"),g_sFontName,25)
		  pLable:setColor(ccc3(0x00,0xff,0x18))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:setPosition(ccp(460,0))
		  labelItem:registerScriptTapHandler(lookAction)
	labelMenu:addChild(labelItem,1,tonumber(pInfo.eid))
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

--别人发的
local function createOtherSendPacketLabel( pInfo,pCell,labelMenu )
	-- body
	local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_316"),g_sFontName,25)
		  label1:setColor(ccc3(0xff,0xeb,0xa3))
	pCell:addChild(label1)
	local label2 = CCLabelTTF:create(pInfo.uname,g_sFontName,25)
		  label2:setColor(ccc3(255,255,0))
		  label2:setPosition(ccp(label1:getContentSize().width,0))
	pCell:addChild(label2)
	local label3 = CCLabelTTF:create(GetLocalizeStringBy("llp_321")..tonumber(pInfo.gold)..GetLocalizeStringBy("llp_318"),g_sFontName,25)
		  label3:setPosition(ccp(label2:getPositionX()+label2:getContentSize().width,0))
		  label3:setColor(ccc3(0xff,0xeb,0xa3))
	pCell:addChild(label3)
	local pLable = CCLabelTTF:create(GetLocalizeStringBy("llp_296"),g_sFontName,25)
		  pLable:setColor(ccc3(0x00,0xff,0x18))
	local labelItem = CCMenuItemLabel:create(pLable)
		  labelItem:setAnchorPoint(ccp(0,0))
		  labelItem:setPosition(ccp(460,0))
		  labelItem:registerScriptTapHandler(lookAction)
	labelMenu:addChild(labelItem,1,tonumber(pInfo.eid))
	labelMenu:setPosition(ccp(0,0))
	pCell:addChild(labelMenu)
end

local function createLabelCell( pInfo )
	local cell = CCTableViewCell:create()
	local labelMenu = CCMenu:create()
	local endtime = tonumber(pInfo.sendTime) + tonumber(ActivityConfig.ConfigCache.envelope.data[1].time)
	local serverTime = tonumber(TimeUtil.getSvrTimeByOffset())
	
		if(tonumber(_curIndex)~=3)then
			if(serverTime<endtime)then
				if(tonumber(pInfo.left)~=0)then
					createNormalLeftPacketLabel(pInfo,cell,labelMenu)
				else
					createNormalNoLeftPacketLabel(pInfo,cell,labelMenu)
				end
			else
				if(tonumber(pInfo.left)==0)then
					createNormalNoLeftOverTimePacketLabel(pInfo,cell,labelMenu)
				else
					createNormalLeftOverTimePacketLabel(pInfo,cell,labelMenu)
				end
			end
		else
			if(tonumber(pInfo.gold)==0)then
				if(serverTime<endtime)then
					if(tonumber(pInfo.left)~=0)then
						createMySendLeftPacketLabel(pInfo,cell,labelMenu)
					else
						createMySendNoLeftPacketLabel(pInfo,cell,labelMenu)
					end
				else
					createMySendOverTimePacketLabel(pInfo,cell,labelMenu)
				end
			else
				createOtherSendPacketLabel(pInfo,cell,labelMenu)
			end
		end
	cell:setScale(g_fScaleX)
	return cell
end

-- 创建签到的tableView
function createTableView(pInfo)	
	local listCount = table.count(pInfo.rankList)
	local labelHeight = CCLabelTTF:create("pInfo.left",g_sFontName,25)
	local cellSize = CCSizeMake(640*g_fScaleX-30,labelHeight:getContentSize().height*1.1*g_fElementScaleRatio)	
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
			local info = pInfo.rankList
            a2= createLabelCell(info[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r= listCount
		elseif (fn == "cellTouched") then
		else
		end
		return r
	end)	

	_tableView= LuaTableView:createWithHandler(handler,CCSizeMake(cellSize.width,_tableViewHeight-45))
	_tableView:setBounceable(true)
	_tableView:setTouchPriority(-499)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0))
	_tableView:setPosition(ccp(_itemBg:getContentSize().width*0.5+5*g_fScaleX,0))
	_itemBg:addChild(_tableView)
	_tableView:reloadData()
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

local function initBaseUI( ... )
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()

	_packBackground = CCScale9Sprite:create(IMG_PATH .. "packetbg.png")
	_packBackground:setAnchorPoint(ccp(0,1))
	_packBackground:setScale(g_fScaleX)
	_packBackground:setPosition(ccp(0,g_winSize.height - (bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()))
	
	_layer:addChild(_packBackground)

	createDesUI()
end

local function onNodeEventMask(event)
    if event == "enter" then
       _isRedLayer = true
    elseif eventType == "exit" then
       _isRedLayer = false
    end
end

function createLayer()
	init()
	RedPacketData.setShowRedPacket(false)
	_layer = CCLayer:create()
	_layer:registerScriptHandler(onNodeEventMask)

	--layer特效
	local _runningScene = CCDirector:sharedDirector():getRunningScene()
	local endtime = ActiveCache.getRedPacketEndTime()
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function ( ... )
			local serverTime = tonumber(TimeUtil.getSvrTimeByOffset())
            if(tonumber(endtime)==tonumber(serverTime))then
            	_runningScene:removeChildByTag(343,true)
            	AnimationTip.showTip(GetLocalizeStringBy("llp_324"))
            	require "script/ui/main/MainBaseLayer"
				local main_base_layer = MainBaseLayer.create()
				MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		        MainScene.setMainSceneViewsVisible(true,true,true)
		        _layer:stopAllActions()
        	end
        end))
	local action = CCRepeatForever:create(seq)
    _layer:runAction(action)

	initBaseUI()
	--根据网络请求刷新tableView
	RedPacketController.getInfo(freshUI,_curIndex)

	return _layer
end
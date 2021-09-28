-- Filename: ShopClosedLayer.lua
-- Author: zhangqiang
-- Date: 2014-10-10
-- Purpose: 周末商店时，未开启时

module("ShopClosedLayer", package.seeall)
require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/rechargeActive/weekendShop/WeekendShopData"
require "script/ui/rechargeActive/ActiveUtil"

local kAdaptSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
local kMidRectSize = CCSizeMake(640, kAdaptSize.height-MenuLayer.getLayerContentSize().height
	                                 -BulletinLayer.getLayerHeight()-RechargeActiveMain.getTopBgHeight())
--local kTableBgSize = CCSizeMake(640,kMidRectSize.height-355)
local kTableBgSize = CCSizeMake(640,kMidRectSize.height-315)
local kMainPriority = -200
local kMenuPriority = -205

local _mainLayer = nil
local _timeDownLabel = nil
local _tableView = nil

--[[
	@desc :	初始化
	@param:
	@ret  :
--]]
function init( ... )
	_mainLayer = nil
	_timeDownLabel = nil
	_tableView = nil
end

--[[
	@desc :	创建UI节点
	@param:
	@ret  :
--]]
function createUINode( ... )
	local node = CCNode:create()
	node:setContentSize(kMidRectSize)

	--周末商人背景
	local titleBg = CCScale9Sprite:create("images/recharge/restore_energy/desc_bg.png")
	titleBg:setPreferredSize(CCSizeMake(640,52))
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(320,kMidRectSize.height)
	node:addChild(titleBg,1)

	--周末商人
	local titleLabel = CCSprite:create("images/weekendShop/weekend_label.png")
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(320,26)
	titleBg:addChild(titleLabel)

	--貂蝉
	local heroBody = CCSprite:create("images/weekendShop/diaochan.png")
	heroBody:setAnchorPoint(ccp(0.5,0.5))
	heroBody:setPosition(320,kMidRectSize.height-110)
	node:addChild(heroBody)

	--活动倒计时
	local intervalTime = WeekendShopData.getCurShopStartTime() - BTUtil:getSvrTimeInterval()
	local timeDownData = {GetLocalizeStringBy("zz_105"), TimeUtil.getTimeString( intervalTime )}
	_timeDownLabel = {}
	local positionX = 420
	for i = 1,2 do
		_timeDownLabel[i] = CCRenderLabel:create(timeDownData[i], g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
		_timeDownLabel[i]:setColor(ccc3(0x00,0xff,0x18))
		_timeDownLabel[i]:setVisible(false)
		_timeDownLabel[i]:setAnchorPoint(ccp(0,0))
		_timeDownLabel[i]:setPosition(positionX, kMidRectSize.height-80)
		node:addChild(_timeDownLabel[i])
		positionX = positionX + _timeDownLabel[i]:getContentSize().width+5
	end
	--_timeLabel = _timeDownLabel[2]

	--倒计时动作
	schedule(_timeDownLabel[1], updateTime, 1)

	--活动描述背景
	local descBg = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
	descBg:setPreferredSize(CCSizeMake(398,90))
	descBg:setAnchorPoint(ccp(0.5,1))
	descBg:setPosition(320,kMidRectSize.height-178)
	node:addChild(descBg)

	--活动描述
	local descLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_106"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
	descLabel:setColor(ccc3(0xff,0xff,0xff))
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(199,46)
	descBg:addChild(descLabel)

	--创建TableView
	local tableView = createTableView()
	tableView:setAnchorPoint(ccp(0.5,0))
	tableView:setPosition(320,15)
	node:addChild(tableView)

	return node
end

--[[
	@desc :	创建TableView
	@param:
	@ret  :
--]]
function createTableView( ... )
	local firstBg = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	firstBg:setPreferredSize(kTableBgSize)

	--一级背景
	local titleBg = CCScale9Sprite:create(CCRectMake(86, 32, 4, 3),"images/recharge/vip_benefit/everyday.png")
	titleBg:setPreferredSize(CCSizeMake(380,68))
	titleBg:setAnchorPoint(ccp(0.5,0.5))
	titleBg:setPosition(kTableBgSize.width*0.5,kTableBgSize.height-3)
	firstBg:addChild(titleBg,1)

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_107"), g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff,0xf6,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(190,34)
	titleBg:addChild(titleLabel)

	--二级背景
	local secondBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondBg:setPreferredSize(CCSizeMake(kTableBgSize.width-30,kTableBgSize.height-40))
	secondBg:setAnchorPoint(ccp(0.5,0.5))
	secondBg:setPosition(kTableBgSize.width*0.5,kTableBgSize.height*0.5)
	firstBg:addChild(secondBg)

	--tableView
	require "script/ui/replaceSkill/CreateUI"
	local secondBgSize = secondBg:getContentSize()
	local tableSize = CCSizeMake(secondBgSize.width-30,secondBgSize.height-20)
	--local cellCount = math.ceil(#WeekendShopData.getCurShopAllGoods()/5)
	_tableView = CreateUI.createTableView(0, tableSize, CCSizeMake(tableSize.width,128), nil, createCell, function ()
		return math.ceil(#WeekendShopData.getCurShopAllGoods()/5)
	end)
	_tableView:setTouchPriority(kMenuPriority)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0.5))
	_tableView:setPosition(secondBgSize.width*0.5, secondBgSize.height*0.5)
	secondBg:addChild(_tableView)

	return firstBg
end

--[[
	@desc :	创建商品预览表的单元格
	@param:
	@ret  :
--]]
function createCell( pCellIndex )
	local cell = CCTableViewCell:create()
	local index = pCellIndex*5
	local positionX = 5
	for i = index-4,index do
		local goodData = WeekendShopData.getCurShopAllGoods()[i]
		if goodData ~= nil then
			local icon = createIcon(goodData.good.type, goodData.config.isHot, goodData.good.tid, goodData.good.num, kMenuPriority+2)
			icon:setAnchorPoint(ccp(0,1))
			icon:setPosition(positionX,118)
			cell:addChild(icon)
			positionX = positionX + 115
		end
	end

	return cell
end

--[[
	@desc :	创建商品图标，名字，数量
	@param:
	@ret  :
--]]
function createIcon( pType, pIsHot, pTid, pNum, pMenuPriority, pLayerPriority)
	pType = tonumber(pType)
	pMenuPriority = pMenuPriority or -999
	pLayerPriority = pLayerPriority or -998
	-- local icon = pType == 1 and ItemSprite.getItemSpriteById(pTid, nil, nil, nil, pMenuPriority, nil, pLayerPriority) 
	--              or ItemSprite.getHeroIconItemByhtid(pTid, pMenuPriority)
	local icon = ActiveUtil.getItemIcon(pType,pTid,pMenuPriority)
	local size = icon:getContentSize()

	--数量
	if pNum ~= nil then
		local numLabel = CCRenderLabel:create(tostring(pNum), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
		numLabel:setColor(ccc3(0x00,0xff,0x18))
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(size.width-10, 6)
		icon:addChild(numLabel)
	end

	--热卖图标
	if pIsHot == 1 then
		local hotIcon = CCSprite:create("images/weekendShop/hot_sell.png")
		hotIcon:setAnchorPoint(ccp(1,1))
		hotIcon:setPosition(size.width, size.height)
		icon:addChild(hotIcon)
	end

	--名字
	local configData = pType == 1 and ItemUtil.getItemById(pTid) or HeroUtil.getHeroLocalInfoByHtid(pTid)
	local quality = pType == 1 and configData.quality or configData.star_lv
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(configData.name, g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5,1))
	nameLabel:setPosition(size.width*0.5,2)
	icon:addChild(nameLabel)

	return icon
end

--[[
	@desc :	刷新预览表
	@param:
	@ret  :
--]]
function refreshTableView( ... )
	if _tableView ~= nil then
		_tableView:reloadData()
	end
end

--[[
	@desc :	倒计时更新
	@param:
	@ret  :
--]]
--local curTime = BTUtil:getSvrTimeInterval()
function  updateTime( ... )
	local curTime = BTUtil:getSvrTimeInterval()

	local getInfoCb = function ( pWeekCount )
		WeekendShopData.init( pWeekCount )
		refreshTableView()
	end

	--商店关闭期间，每天零点还在该界面时，系统刷新商品预览
	local timeTable = os.date("*t",curtime)
	--print("sss:",timeTable.min,timeTable.sec)
	if timeTable.hour == 0 and timeTable.min == 0 and timeTable.sec == 3 then
		WeekendShopService.getShopNum(getInfoCb)
	end

	--开启倒计时
	--local leftTime = curTime + 5 - BTUtil:getSvrTimeInterval()
	local leftTime = WeekendShopData.getCurShopStartTime()+5 - curTime
	--leftTime = leftTime < 0 and 0 or leftTime
	if leftTime ==0 and leftTime >= -1 then
		require "script/ui/rechargeActive/weekendShop/WeekendShopLayer"
		RechargeActiveMain.changeButtomLayer(WeekendShopLayer.createLayer())
		return
	elseif leftTime < -1 then
		--活动结束后，如星期天晚上11:30结束后，商店开启界面会返回到该界面
		_timeDownLabel[1]:setVisible(false)
		_timeDownLabel[2]:setVisible(false)
		return
	else

	end

	_timeDownLabel[1]:setVisible(true)
	_timeDownLabel[2]:setVisible(true)

	require "script/utils/TimeUtil"
	local timeStr = TimeUtil.getTimeString(leftTime)
	_timeDownLabel[2]:setString(timeStr)
end

--[[
	@desc :	创建层
	@param:
	@ret  :
--]]
function createLayer( ... )
	init()

	--创建层
	_mainLayer = CCLayer:create()
	_mainLayer:setContentSize(kAdaptSize)
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setScale(g_fScaleX)

	--背景
	local mainBg = CCScale9Sprite:create("images/recharge/change/zhong_bg.png")
	mainBg:setPreferredSize(kAdaptSize)
	mainBg:setScale(MainScene.bgScale/g_fScaleX)
	mainBg:setAnchorPoint(ccp(0.5,0))
	mainBg:setPosition(320,0)
	_mainLayer:addChild(mainBg)

	--创建中间的UI
	local uiNode = createUINode()
	uiNode:setAnchorPoint(ccp(0.5,0))
	uiNode:setPosition(320,MenuLayer.getLayerContentSize().height)
	_mainLayer:addChild(uiNode)

	return _mainLayer
end
-----------------------------------------------------[[ 回调函数 ]]---------------------------------------------------------------------
--[[
	@desc :	创建层时的回调
	@param:
	@ret  :
--]]
function onNodeEvent( pEventType )
	if pEventType == "enter" then
		_mainLayer:registerScriptTouchHandler(touchMainLayerCb, false, kMainPriority, true)
		_mainLayer:setTouchEnabled(true)
	elseif pEventType == "exit" then
		_mainLayer:unregisterScriptTouchHandler()
	else

	end
end

--[[
	@desc :	触摸层的回调
	@param:
	@ret  :
--]]
function touchMainLayerCb( pEventType, pTouchX, pTouchY )
	if pEventType == "began" then
		--return true
	elseif pEventType == "moved" then

	elseif pEventType == "cancelled" then

	else
		-- pEventType = "ended"
	end
end










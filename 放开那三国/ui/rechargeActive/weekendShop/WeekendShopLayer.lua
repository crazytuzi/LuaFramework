-- Filename: WeekendShopLayer.lua
-- Author: zhangqiang
-- Date: 2014-10-10
-- Purpose: 神秘商店周末版,开启时

module("WeekendShopLayer", package.seeall)

require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/rechargeActive/weekendShop/WeekendShopData"
require "script/ui/rechargeActive/weekendShop/WeekendShopService"
require "script/ui/rechargeActive/weekendShop/ShopClosedLayer"

local kAdaptSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
local kMidRectSize = CCSizeMake(640, kAdaptSize.height-MenuLayer.getLayerContentSize().height
	                                 -BulletinLayer.getLayerHeight()-RechargeActiveMain.getTopBgHeight())
local kTableBgSize = CCSizeMake(472,kMidRectSize.height-212)
local kMainPriority = -200
local kMenuPriority = -205

local _mainLayer = nil
local _btnTable = nil
local _topLabelTable = nil
local _timeLabelTable = nil
local _refreshLabel = nil
local _refreshLabelTable = nil
local _tableView = nil
local _goldIcon = nil
local _goldCostNum = nil

--[[
	@desc :	初始化
	@param:
	@ret  :
--]]
function init( ... )
	_mainLayer = nil
	_btnTable = {}
	_topLabelTable = {}
	_timeLabelTable = {}
	_refreshLabelTable = {}
	_refreshLabel = nil
	_tableView = nil
	_goldIcon = nil
	_goldCostNum = nil
end

--[[
	@desc :	创建中间的UI
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

	local menu = CCMenu:create()
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(0,0)
	node:addChild(menu,2)
	--商品预览、刷新按钮
	require "script/ui/replaceSkill/CreateUI"
	local btnData = {
		[1] = {CreateUI.createScale9MenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png", nil,
			   CCSizeMake(168,60), GetLocalizeStringBy("zz_110"),30), tapPreviewBtnCb, ccp(476,kMidRectSize.height+7)},
		[2] = {CreateUI.createScale9MenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", "images/common/btn/btn1_g.png",
			   CCSizeMake(196,68), nil, 30, nil, nil, -30), tapRefreshBtnCb, ccp(407,105)},
	}
	for i =1,2 do
		btnData[i][1]:registerScriptTapHandler(btnData[i][2])
		btnData[i][1]:setAnchorPoint(ccp(0,1))
		btnData[i][1]:setPosition(btnData[i][3])
		menu:addChild(btnData[i][1])
		_btnTable[i] = btnData[i][1]
	end

	--“刷新”
	_refreshLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_111"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_shadow)
	_refreshLabel:setColor(ccc3(0xff,0xe4,0x00))
	_refreshLabel:setAnchorPoint(ccp(0.5,0.5))
	_refreshLabel:setPosition(98,34)
	_btnTable[2]:addChild(_refreshLabel)

	--顶端描述：可兑换次数 当前魂玉数
	local topDescData = {
		[1] = {text=GetLocalizeStringBy("zz_108"), font=g_sFontPangWa, size=18, color=ccc3(0x00,0xe4,0xff)},
		[2] = {text="0000", font=g_sFontPangWa, size=18, color=ccc3(0xff,0xf6,0x00), offsetX = 5},
		[3] = {text=GetLocalizeStringBy("zz_124"), font=g_sFontPangWa, size=18, color=ccc3(0x00,0xe4,0xff), offsetX = 3},
		[4] = {text=GetLocalizeStringBy("zz_109"), font=g_sFontPangWa, size=18, color=ccc3(0x00,0xe4,0xff), offsetX = 30},
		[5] = {text="0000", font=g_sFontPangWa, size=18, color=ccc3(0xff,0xf6,0x00), offsetX = 5},
	}
	_topLabelTable = createLabel(topDescData)
	_topLabelTable.parent:setAnchorPoint(ccp(0.5,0))
	_topLabelTable.parent:setPosition(320,kMidRectSize.height-92)
	node:addChild(_topLabelTable.parent,1)

	--貂蝉 和 活动描述
	local activityData = {
		-- [1] = {"images/weekendShop/diaochan.png", ccp(78,kMidRectSize.height-292)},	
		-- [2] = {"images/weekendShop/desc.png", ccp(124,kMidRectSize.height-330)},
		[1] = {"images/weekendShop/diaochan.png", ccp(78,kMidRectSize.height*0.5)},	
		[2] = {"images/weekendShop/desc.png", ccp(124,kMidRectSize.height-320)},	
	}
	for i = 1,2 do
		local sp = CCSprite:create(activityData[i][1])
		sp:setAnchorPoint(ccp(0.5,0.5))
		sp:setPosition(activityData[i][2])
		node:addChild(sp)
	end

	--创建tableView
	local tableView = createTableView()
	tableView:setAnchorPoint(ccp(0,1))
	tableView:setPosition(156,kMidRectSize.height-105)
	node:addChild(tableView)

	--每天0点刷新
	local refreshTip = CCRenderLabel:create(GetLocalizeStringBy("zz_115"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
	refreshTip:setColor(ccc3(0x00,0xff,0x18))
	refreshTip:setAnchorPoint(ccp(0,0))
	refreshTip:setPosition(243,83)
	node:addChild(refreshTip)

	--离开时间倒计时 
	local intervalTime = WeekendShopData.getCurShopEndTime() - BTUtil:getSvrTimeInterval()
	local timeDescData = {
		[1] = {text=GetLocalizeStringBy("zz_112"), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff)},
		[2] = {text=TimeUtil.getTimeString(intervalTime), font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18), offsetX = 5},
	}
	_timeLabelTable = createLabel(timeDescData)
	_timeLabelTable.parent:setAnchorPoint(ccp(0,0))
	_timeLabelTable.parent:setPosition(12,16)
	node:addChild(_timeLabelTable.parent)

	--倒计时动作
	schedule(_timeLabelTable.parent, updateTime, 1)

	--当前拥有的刷新材料
	local refreshDescData = {
		[1] = {text=GetLocalizeStringBy("zz_113"), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff)},
		[2] = {text="00", font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18)},
		[3] = {text=GetLocalizeStringBy("zz_114"), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff)},
	}
	_refreshLabelTable = createLabel(refreshDescData)
	_refreshLabelTable.parent:setAnchorPoint(ccp(0,0))
	_refreshLabelTable.parent:setPosition(406,12)
	node:addChild(_refreshLabelTable.parent)

	--金币图标
	_goldIcon = CCSprite:create("images/common/gold.png")
	_goldIcon:setAnchorPoint(ccp(0,0.5))
	local btnSize = _btnTable[2]:getContentSize()
	_goldIcon:setPosition(btnSize.width*0.5+5,btnSize.height*0.5)
	_btnTable[2]:addChild(_goldIcon)

	--需要花费的金币数
	_goldCostNum = CCRenderLabel:create("00", g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
	_goldCostNum:setColor(ccc3(0xff,0xf6,0x00))
	_goldCostNum:setAnchorPoint(ccp(0,0.5))
	_goldCostNum:setPosition(30,_goldIcon:getContentSize().height*0.5)
	_goldIcon:addChild(_goldCostNum)

	--每天零点系统刷新
	schedule(node, refreshGoodsBySys, 1)

	--刷新剩余可兑换武魂数量
	refreshRemainBuyNum()
	--刷新当前的魂玉数
	refreshSoulJewelNum()
	--刷新刷新按钮和下端的描述
	refreshRefreshBtn()

	return node
end

--[[
	@desc :	创建文本
	@param: 
	pLabelTable = {
		{
			text = string
			font = string
			size = int
			color = ccc3
			offsetX = int
		}
	}
	@ret  :
--]]
function createLabel( pLabelTable )
	if pLabelTable == nil then return end

	local ret = {parent=CCNode:create(), children={}}
	local size = CCSizeMake(0,0)
	for k,v in ipairs(pLabelTable) do
		local label = CCRenderLabel:create(v.text, v.font, v.size, 1, ccc3(0x00,0x00,0x00), type_stroke)
		local offsetX = v.offsetX or 0
		label:setColor(v.color)
		label:setAnchorPoint(ccp(0,0))
		label:setPosition(size.width+offsetX,0)
		ret.parent:addChild(label)
		ret.children[k] = label

		local labelSize = label:getContentSize()
		size.width = size.width + labelSize.width + offsetX
		size.height = size.height > labelSize.height and size.height or labelSize.height
	end
	ret.parent:setContentSize(size)

	return ret
end

--[[
	@desc :	创建TableView
	@param:
	@ret  :
--]]
function createTableView( ... )
	--一级背景
	local firstBg = CCScale9Sprite:create(CCRectMake(53, 57, 10, 10),"images/recharge/change/zhong_bg1.png")
	firstBg:setPreferredSize(kTableBgSize)

	--tableView
	require "script/ui/replaceSkill/CreateUI"
	local tableSize = CCSizeMake(kTableBgSize.width-6,kTableBgSize.height-20)
	_tableView = CreateUI.createTableView(0, tableSize, CCSizeMake(tableSize.width,145), nil, createCell, function (  )
		return #WeekendShopData.getCurGoodList()
	end)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0.5))
	_tableView:setPosition(kTableBgSize.width*0.5, kTableBgSize.height*0.5)
	firstBg:addChild(_tableView)

	--可滚动提示
	local arrowData = {
		[1] = {"images/common/arrow_up_h.png",ccp(kTableBgSize.width*0.5, kTableBgSize.height-50)},
		[2] = {"images/common/arrow_down_h.png",ccp(kTableBgSize.width*0.5, 0)},
	}
	local arrows = {}
	for i = 1,2 do
		arrows[i] = CCSprite:create(arrowData[i][1])
		arrows[i]:setVisible(false)
		arrows[i]:setAnchorPoint(ccp(0.5,0))
		arrows[i]:setPosition(arrowData[i][2])
		firstBg:addChild(arrows[i],1)

		local sequence = CCSequence:createWithTwoActions(CCFadeIn:create(1), CCFadeOut:create(1))
		arrows[i]:runAction(CCRepeatForever:create(sequence))
	end

	local updateArrow = function ()
		local offset =  _tableView:getContentSize().height+ _tableView:getContentOffset().y- _tableView:getViewSize().height
		if(arrows[1]~= nil )  then
			if(offset>1) then
				arrows[1]:setVisible(true)
			else
				arrows[1]:setVisible(false)
			end
		end
		if(arrows[2] ~= nil) then
			if( _tableView:getContentOffset().y <-1) then
				arrows[2]:setVisible(true)
			else
				arrows[2]:setVisible(false)
			end
		end
	end
	schedule(firstBg, updateArrow, 1)

	return firstBg
end

--[[
	@desc :	创建商品预览表的单元格
	@param:
	@ret  :
--]]
function createCell( pCellIndex )
	local cell = CCTableViewCell:create()
	--local cellData = {items = 2, costType = 2, tid=10036}
	local cellData = WeekendShopData.getCurGoodList()[pCellIndex]
	
	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBg:setPreferredSize(CCSizeMake(kTableBgSize.width-6,145))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(0,0)
	cell:addChild(cellBg)

	local goodBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	goodBg:setPreferredSize(CCSizeMake(294,110))
	goodBg:setAnchorPoint(ccp(0,0))
	goodBg:setPosition(17,17)
	cellBg:addChild(goodBg)

	--商品图标
	--local goodIcon = cellData.good.type == 1 and ItemSprite.getItemSpriteById(cellData.good.tid) or ItemSprite.getHeroIconItemByhtid(cellData.good.tid)
	local goodIcon = ActiveUtil.getItemIcon(cellData.good.type,cellData.good.tid)
	goodIcon:setAnchorPoint(ccp(0,0))
	goodIcon:setPosition(7,7)
	goodBg:addChild(goodIcon)
	local iconSize = goodIcon:getContentSize()

	--商品单位数目
	local numLabel = CCRenderLabel:create(tonumber(cellData.good.num), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
	numLabel:setColor(ccc3(0x00,0xff,0x18))
	numLabel:setAnchorPoint(ccp(1,0))
	numLabel:setPosition(iconSize.width-10,5)
	goodIcon:addChild(numLabel)

	--热卖图标
	if cellData.config.isHot == 1 then
		local hotIcon = CCSprite:create("images/weekendShop/hot_sell.png")
		hotIcon:setAnchorPoint(ccp(1,1))
		hotIcon:setPosition(iconSize.width, iconSize.height)
		goodIcon:addChild(hotIcon)
	end

	--商品名称
	local goodData = cellData.good.type == 1 and ItemUtil.getItemById(cellData.good.tid) or HeroUtil.getHeroLocalInfoByHtid(cellData.good.tid)
	local quality = cellData.good.type == 1 and goodData.quality or goodData.star_lv
	local goodNameLabel = CCRenderLabel:create(goodData.name, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
	--goodNameLabel:setColor(ccc3(0xff,0xf6,0x00))
	goodNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
	goodNameLabel:setAnchorPoint(ccp(0,0))
	goodNameLabel:setPosition(112,61)
	goodBg:addChild(goodNameLabel)

	--根据不同的花费类型确定不同的显示内容
	local costNameStr = nil
	local costIconImg = nil
	local btnStr = GetLocalizeStringBy("zz_116")
	local leftNumStr = GetLocalizeStringBy("zz_118", cellData.remain)
	if cellData.config.costType == WeekendShopData.kSoulJewelTag then
		costNameStr = GetLocalizeStringBy("key_1510")
		costIconImg = "images/common/soul_jade.png"
		btnStr = GetLocalizeStringBy("zz_117")
		leftNumStr = GetLocalizeStringBy("zz_119", cellData.remain)
	elseif cellData.config.costType == WeekendShopData.kGoldTag then
		costNameStr = GetLocalizeStringBy("key_1491")
		costIconImg = "images/common/gold.png"
	elseif cellData.config.costType == WeekendShopData.kSilverTag then
		costNameStr = GetLocalizeStringBy("key_1687")
		costIconImg = "images/common/coin_silver.png"
	else
		error("cost type miss")
	end

	local costData = {
		[1] = {text=costNameStr, font=g_sFontName, size=21, color=ccc3(0xff,0xf6,0x00)},
		[2] = {text=tostring(cellData.config.costNum), font=g_sFontName, size=21, color=ccc3(0xff,0xf6,0x00), offsetX=44},
	}
	local costLabel = createLabel(costData)
	costLabel.parent:setAnchorPoint(ccp(0,0))
	costLabel.parent:setPosition(113,19)
	goodBg:addChild(costLabel.parent)

	local costIcon = CCSprite:create(costIconImg)
	costIcon:setAnchorPoint(ccp(0,0.5))
	costIcon:setPosition(costLabel.children[1]:getContentSize().width+5, costLabel.children[1]:getContentSize().height*0.5)
	costLabel.children[1]:addChild(costIcon)

	local menu = BTMenu:create()
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(0,0)
	menu:setScrollView(_tableView)
	cellBg:addChild(menu)
	--按钮
	local cellBtn = CreateUI.createScale9MenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png", "images/common/btn/btn_blue_hui.png",
			                                      CCSizeMake(109,60), btnStr,30)
	cellBtn:registerScriptTapHandler(tapCellBtnCb)
	cellBtn:setAnchorPoint(ccp(0,0))
	cellBtn:setPosition(325,58)
	menu:addChild(cellBtn,1,pCellIndex)
	if cellData.remain <= 0 then
		cellBtn:setEnabled(false)
	else
		cellBtn:setEnabled(true)
	end

	--剩余次数
	local leftNumLabel = CCLabelTTF:create(leftNumStr, g_sFontName, 23)
	leftNumLabel:setColor(ccc3(0x78,0x25,0x00))
	leftNumLabel:setAnchorPoint(ccp(0,0))
	leftNumLabel:setPosition(320,26)
	cellBg:addChild(leftNumLabel)

	return cell
end

--[[
	@desc :	倒计时
	@param:
	@ret  :
--]]
function updateTime( ... )
	local curTime = BTUtil:getSvrTimeInterval()
	local leftTime = WeekendShopData.getCurShopEndTime() - curTime
	--leftTime = leftTime < 0 and 0 or leftTime
	if leftTime <= 0 then
		RechargeActiveMain.changeButtomLayer(ShopClosedLayer.createLayer())
		return
	end

	require "script/utils/TimeUtil"
	local timeStr = TimeUtil.getTimeString(leftTime)
	_timeLabelTable.children[2]:setString(timeStr)
end

--[[
	@desc :	刷新剩余可兑换的次数
	@param:
	@ret  :
--]]
function refreshRemainBuyNum( ... )
	local remainNum = WeekendShopData.getRemainBuyNum()
	_topLabelTable.children[2]:setString(remainNum)

	_topLabelTable.children[3]:setPosition(_topLabelTable.children[2]:getPositionX()+_topLabelTable.children[2]:getContentSize().width+3,
		                                   _topLabelTable.children[2]:getPositionY())
end

--[[
	@desc :	刷新当前的魂玉数
	@param:
	@ret  :
--]]
function refreshSoulJewelNum( ... )
	local soulJewelNum = UserModel.getJewelNum()
	_topLabelTable.children[5]:setString(soulJewelNum)
end

--[[
	@desc :	刷新tableView
	@param:
	@ret  :
--]]
function refreshTableView( pKeepOffset )
	local offset = _tableView:getContentOffset()
	--更新数据源
	WeekendShopData.updateCurGoodList()

	--重新加载表格
	_tableView:reloadData()

	--恢复偏移量
	pKeepOffset = pKeepOffset == nil and true or pKeepOffset
	if pKeepOffset then
		_tableView:setContentOffset(offset)
	end

end

--[[
	@desc :	设置刷新按钮上，金币数量、金币图标的可见性
	@param:
	@ret  :
--]]
function setGoldVisible( pIsVisible )
	_goldIcon:setVisible(pIsVisible)
	_goldCostNum:setVisible(pIsVisible)

	if pIsVisible then
		_refreshLabel:setPosition(68,34)
	else
		_refreshLabel:setPosition(98,34)
	end
end

--[[
	@desc :	刷新购买随机列表刷新次数的金币数量
	@param:
	@ret  :
--]]
function refreshRefreshBtn( ... )
	local costTid, costNum, hasNum = WeekendShopData.getRefreshCostItem()
	if costTid == WeekendShopData.kGoldTag then
		if costNum ~= 0 then
			setGoldVisible(true)
			_goldCostNum:setString(tostring(costNum))
		else
			setGoldVisible(false)
		end
		_refreshLabelTable.parent:setVisible(false)
	else
		setGoldVisible(false)
		_refreshLabelTable.parent:setVisible(true)
		local itemData = ItemUtil.getItemById(costTid)
		--刷新当前拥有的刷新材料数量
		local refreshDescData = {
			GetLocalizeStringBy("zz_113",itemData.name), tostring(hasNum), GetLocalizeStringBy("zz_114"),
		}
		local positionX = 0
		for k,v in ipairs(_refreshLabelTable.children) do
			v:setString(refreshDescData[k])
			v:setPositionX(positionX)
			positionX = positionX + v:getContentSize().width
		end
	end
end

--[[
	@desc :	系统每天0点刷新物品
	@param:
	@ret  :
--]]
function refreshGoodsBySys( ... )
	local getInfoCb = function ( pData )
		WeekendShopData.setAllInfo(pData)

		--加载表格
		refreshTableView(false)

		--更新可兑换次数
		refreshRemainBuyNum()
	end

	local curTime = BTUtil:getSvrTimeInterval()
	--每天零点系统刷新
	local timeTable = os.date("*t",curtime)
	if timeTable.hour == 0 and timeTable.min == 0 and timeTable.sec == 3 then
		WeekendShopService.getInfo(getInfoCb)
	end
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
	--images/recharge/change/zhong_bg.png
	local mainBg = CCScale9Sprite:create("images/recharge/change/zhong_bg.png")
	mainBg:setPreferredSize(kAdaptSize)
	mainBg:setScale(MainScene.bgScale/g_fScaleX)
	mainBg:setAnchorPoint(ccp(0.5,0))
	mainBg:setPosition(320,0)
	_mainLayer:addChild(mainBg)

	--中间的UI
	local getInfoCb = function ( pData )
		WeekendShopData.initOpenShop(pData)
		
		local uiNode = createUINode()
		uiNode:setAnchorPoint(ccp(0.5,0))
		uiNode:setPosition(320, MenuLayer.getLayerContentSize().height)
		_mainLayer:addChild(uiNode)
	end
	WeekendShopService.getInfo(getInfoCb)

	return _mainLayer
end

--[[
	@desc :	不同时间段显示不同的层
	@param:
	@ret  :
--]]
function changeLayer( ... )
	if not DataCache.getSwitchNodeState(ksWeekendShop,false) then
		require "db/DB_Switch"
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_127", DB_Switch.getDataById(ksWeekendShop).level))
		return
	end

	local getShopNumCb = function ( pNum )
		print("getShopNumCb",pNum)
		WeekendShopData.init(pNum)
		
		if WeekendShopData.doShopOpen() then
			RechargeActiveMain.changeButtomLayer(createLayer())
		else
			RechargeActiveMain.changeButtomLayer(ShopClosedLayer.createLayer())
		end
	end
	WeekendShopService.getShopNum(getShopNumCb)
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

--[[
	@desc :	点击预览按钮的回调
	@param:
	@ret  :
--]]
function tapPreviewBtnCb( pTag, pItem )
	require "script/ui/rechargeActive/weekendShop/PreviewShopLayer"
	PreviewShopLayer.showLayer()
end

--[[
	@desc :	点击刷新按钮的回调
	@param:
	@ret  :
--]]
function tapRefreshBtnCb( pTag, pItem )
	local ret, retStr = WeekendShopData.doMeetRefreshConditions()
	if ret == false then
		require "script/ui/tip/SingleTip"
		SingleTip.showSingleTip(retStr)
		return
	end

	local costTid, costNum, hasNum = WeekendShopData.getRefreshCostItem()
	local refreshType = costTid == WeekendShopData.kGoldTag and 1 or 2
	
	local callBack = function ( pData )
		WeekendShopData.setAllInfo(pData)
		WeekendShopData.refreshGoodSuccessful(costTid, costNum)
	end
	WeekendShopService.refreshGoodList( refreshType, costTid, callBack )
end

--[[
	@desc :	点击单元格中按钮的回调
	@param:
	@ret  :
--]]
function tapCellBtnCb( pTag, pItem )
	local ret, retStr = WeekendShopData.doMeetBuyConditions(pTag)
	if ret == false then
		require "script/ui/tip/SingleTip"
		SingleTip.showSingleTip(retStr)
		return
	end

	local callBack = function ( ... )
		WeekendShopData.buyGoodSuccessful(pTag)
	end
	WeekendShopService.buyGood(WeekendShopData.getCurGoodList()[pTag].config.id, callBack)
end
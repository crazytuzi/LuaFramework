--Filename: exchangeLayer.lua
--Author: ZQ
--Date: 2014-06-18
--Purpose: 创建寻龙积分兑换界面

module("FindLongExchangeLayer",package.seeall)
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/ui/exchange/FindLongExchangeCell"
require "script/ui/exchange/FindLongExchangeCache"

local _layer = nil
local _visibleWidth = nil
local _visibleHeight = nil
local _bulletinHeight = nil
local _bottomMenuHeight = nil
local _offsetY = nil

local _exchangeInfoLayer = nil
local _FindLongExchangeCellData = nil
local _exchangeTable = nil
local _findDrogonNum = nil

function create()
	--if _layer ~= nil then return end

	-- 屏幕适配参数
	print("winSize::",g_winSize.width,g_winSize.height)
	--local maxScale = g_fScaleX > g_fScaleY and g_fScaleX or g_fScaleY
	local maxScale = g_fScaleX
	_visibleWidth  = g_winSize.width / maxScale
	_visibleHeight = g_winSize.height / maxScale
	print("visibleSize::",_visibleWidth,_visibleHeight)

	-- 获取bulletin高度
	-- 获取底部菜单的高度
	_bulletinHeight = BulletinLayer.getLayerContentSize().height
	_bottomMenuHeight = MenuLayer.getLayerContentSize().height

	-- 创建界面层
	_layer = CCLayer:create()
	_layer:setContentSize(CCSizeMake(_visibleWidth,_visibleHeight))
	_layer:setScale(maxScale)
	_layer:setTouchEnabled(true)
	_layer:setTouchPriority(-150)
	local function layerTouchCb(eventType,x,y)
		return true
	end
	_layer:registerScriptTouchHandler(layerTouchCb,false)

	-- 设置背景
	local layerBg = CCSprite:create("images/main/module_bg.png")
	layerBg:setAnchorPoint(ccp(0,0))
	layerBg:setPosition(0,_bottomMenuHeight)
	layerBg:setScale((g_fScaleX > g_fScaleY and g_fScaleX or g_fScaleY) / maxScale)
	_layer:addChild(layerBg)

	-- 添加顶部状态栏：战斗力 银币 金币
	local topBar = CCSprite:create("images/hero/avatar_attr_bg.png")
	topBar:setAnchorPoint(ccp(0,1))
	_offsetY = _visibleHeight - _bulletinHeight
	topBar:setPosition(0,_offsetY)
	_layer:addChild(topBar)

	local fightDesc = CCSprite:create("images/common/fight_value.png")
	fightDesc:setAnchorPoint(ccp(0,0.5))
	fightDesc:setPosition(52,21)
	topBar:addChild(fightDesc)

	-- 战斗力
	require "script/model/user/UserModel"
	local fightNum = CCRenderLabel:create(UserModel.getFightForceValue(), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fightNum:setAnchorPoint(ccp(0,0.5))
	fightNum:setPosition(140,20)
	topBar:addChild(fightNum)

	-- 银币
	m_silverLabel = CCLabelTTF:create(UserModel.getSilverNumber(), g_sFontName, 20)
	m_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	m_silverLabel:setAnchorPoint(ccp(0, 0.5))
	m_silverLabel:setPosition(ccp(375, 20))
	topBar:addChild(m_silverLabel)

	-- 金币
	m_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	m_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	m_goldLabel:setAnchorPoint(ccp(0, 0.5))
	m_goldLabel:setPosition(ccp(520, 20))
	topBar:addChild(m_goldLabel)

	-- 添加顶部菜单栏
	local topMenu = CCScale9Sprite:create("images/common/menubg.png")
	topMenu:setPreferredSize(CCSizeMake(_visibleWidth,100))
	topMenu:setAnchorPoint(ccp(0,1))
	_offsetY = _offsetY - topBar:getContentSize().height
	topMenu:setPosition(0,_offsetY)
	_layer:addChild(topMenu)
	_offsetY = _offsetY - topMenu:getContentSize().height

	-- 顶部菜单栏中添加按钮
	local exchangeMenu = CCMenu:create()
	exchangeMenu:setAnchorPoint(ccp(0,0))
	exchangeMenu:setPosition(10,9)
	topMenu:addChild(exchangeMenu)

	local exchangeBtn = CCMenuItemImage:create("images/active/rob/btn_title_n.png","images/active/rob/btn_title_h.png")
	exchangeMenu:addChild(exchangeBtn) 

	local exchangeBtnStr = CCLabelTTF:create(GetLocalizeStringBy("zz_1"),g_sFontPangWa,30)
	--print("sss::",exchangeBtnStr:getContentSize().width,exchangeBtnStr:getContentSize().height)
	--exchangeBtnStr:setColor(ccc3(0xff,0xe4,0x00))
	exchangeBtnStr:setColor(ccc3(0x48,0x85,0xb5))
	exchangeBtn:selected()
	exchangeBtnStr:setAnchorPoint(ccp(0,0))
	exchangeBtnStr:setPosition(60,10)
	exchangeBtn:addChild(exchangeBtnStr)
	--默认创建兑换层
	FindLongExchangeCache.getExchangeInfoFromSever(createExchangeInfoLayer)

	local function exchangeBtnCb(tag, itemBtn)
		exchangeBtnStr:setColor(ccc3(0x48,0x85,0xb5))
		exchangeBtn:selected()
		if _exchangeInfoLayer == nil then
			FindLongExchangeCache.getExchangeInfoFromSever(createExchangeInfoLayer)
		end
	end
	exchangeBtn:registerScriptTapHandler(exchangeBtnCb)

	--顶部返回按钮
	local backMenu = CCMenu:create()
	backMenu:setAnchorPoint(ccp(0,0))
	backMenu:setPosition(541,20)
	topMenu:addChild(backMenu)

	local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	backMenu:addChild(backBtn)

	local function backBtnCb(tag, itemBtn)
		print("_exchangeInfoLayer:")
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
		_exchangeInfoLayer = nil
		require "script/ui/forge/FindTreasureLayer"
		FindTreasureLayer.show()
	end
	backBtn:registerScriptTapHandler(backBtnCb)

	-- 添加到main_base_layer
	require "script/ui/main/MainScene"
	MainScene.changeLayer(_layer, "FindLongExchangeLayer")
	--MainSceneViewsVisible(menuVisible,avatarVisible,bulletinVisible)
    MainScene.setMainSceneViewsVisible(true,false,true)
end

function createExchangeInfoLayer()
	print("createExchangeInfoLayer")

	local offsetY = _offsetY - _bottomMenuHeight

	_exchangeInfoLayer = CCLayer:create()
	_exchangeInfoLayer:setContentSize(CCSizeMake(_visibleWidth,offsetY))
	_exchangeInfoLayer:setAnchorPoint(ccp(0,0))
	_exchangeInfoLayer:setPosition(0,_bottomMenuHeight)
	_layer:addChild(_exchangeInfoLayer)

	--蓝色线条背景
	local blueLine = CCScale9Sprite:create("images/common/bg/name_bg.png")
	blueLine:setPreferredSize(CCSizeMake(400,37))
	blueLine:setAnchorPoint(ccp(0.5,0.5))
	offsetY = offsetY - 40
	blueLine:setPosition(_visibleWidth/2,offsetY)
	_exchangeInfoLayer:addChild(blueLine)

	--标题“当前寻龙积分：..”
	local titleStr = CCRenderLabel:create(GetLocalizeStringBy("zz_2"),g_sFontPangWa,36,2,ccc3(0x00,0x00,0x00),type_shadow)
	titleStr:setColor(ccc3(0xff,0xe4,0x00))
	titleStr:setAnchorPoint(ccp(1,0.5))
	titleStr:setPosition(368,offsetY)
	_exchangeInfoLayer:addChild(titleStr)

	local jifenSprite = CCSprite:create("images/forge/xunlongjifen_icon.png")
	jifenSprite:setAnchorPoint(ccp(0,0.5))
	jifenSprite:setPosition(375,offsetY)
	_exchangeInfoLayer:addChild(jifenSprite)

	_findDrogonNum = FindTreasureData.getTotalPoint()
	local titleNum = CCRenderLabel:create(tostring(_findDrogonNum),g_sFontPangWa,36,2,ccc3(0x00,0x00,0x00),type_shadow)
	titleNum:setColor(ccc3(0xff,0xe4,0x00))
	titleNum:setAnchorPoint(ccp(0,0.5))
	titleNum:setPosition(415,offsetY)
	_exchangeInfoLayer:addChild(titleNum,1,90)

	--顶部分割线
	local topSeparator = CCSprite:create("images/common/separator_top.png")
	topSeparator:setAnchorPoint(ccp(0.5,0.5))
	offsetY = offsetY - 50
	topSeparator:setPosition(_visibleWidth/2,offsetY)
	_exchangeInfoLayer:addChild(topSeparator)

	--底部分割线
	local bottomSeparator = CCSprite:create("images/common/separator_bottom.png")
	bottomSeparator:setAnchorPoint(ccp(0.5,0))
	bottomSeparator:setPosition(_visibleWidth/2,0)
	_exchangeInfoLayer:addChild(bottomSeparator)
	
	--创建兑换表
	_FindLongExchangeCellData = FindLongExchangeCache.filterExchangeDataTable()
	print("sss::")
	print_table("sss::",_FindLongExchangeCellData)

	local function onSetExchangeTableParams(paramName,table,object1,object2)
		local ret = nil
		if paramName == "cellSize" then
			ret = CCSizeMake(632,200)
		elseif paramName == "cellAtIndex" then

			ret = FindLongExchangeCell.create(_FindLongExchangeCellData[object1+1])
		elseif paramName == "numberOfCells" then
			ret = #_FindLongExchangeCellData
		else
		end
		return ret
	end
	local eventHandler = LuaEventHandler:create(onSetExchangeTableParams)
	local exchangeTable = LuaTableView:createWithHandler(eventHandler,CCSizeMake(632,offsetY-20))
	--exchangeTable:setAnchorPoint(ccp(0,1))
	--exchangeTable:setPosition(_visibleWidth/2,offsetY-10)
	exchangeTable:setPosition(5,13)
	exchangeTable:setBounceable(true)
	exchangeTable:setVerticalFillOrder(kCCTableViewFillTopDown)
	exchangeTable:setTouchPriority(-160)
	_exchangeInfoLayer:addChild(exchangeTable,1,100)
	_exchangeTable = exchangeTable
end

--获得兑换表
function getExchangeInfoLayer()
	return _exchangeInfoLayer
end

--获得本地寻龙积分
function getFindDrogonNum()
	return _findDrogonNum
end

--设置本地寻龙积分
function setFindDrogonNum(num)
	_findDrogonNum = num
end

--获取tableView
function getExchangeTable( ... )
	return _exchangeTable
end

--刷新数据，获得剩余次数大于零的数据
function freshFindLongExchangeCellData()
	local temp = {}
	-- 当剩余兑换次数大于0时才在table中显示出来
	for _,v in pairs(_FindLongExchangeCellData) do
		if v.remainExchangeNum > 0 then
			table.insert(temp,v)
		end
	end
	_FindLongExchangeCellData = temp
end
-- -- used in "MainBaseLayer.lua" for test
-- function createExchangeBtn(bgLayer)
-- 	local maxScale = g_fScaleX > g_fScaleY and g_fScaleX or g_fScaleY
-- 	local visibleWidth  = g_winSize.width / maxScale
-- 	local visibleHeight = g_winSize.height / maxScale
	
-- 	local menu = CCMenu:create()
-- 	--MainScene中是单独对每一个精灵进行的适配，因此该处也要单独适配
-- 	menu:setPosition(visibleWidth*0.2*maxScale,visibleHeight*0.5*maxScale)
-- 	--menu:setPosition(100,200)
-- 	bgLayer:addChild(menu)

-- 	local btn = CCMenuItemImage:create("images/level_reward/level_reward_n.png", "images/level_reward/level_reward_h.png")
-- 	menu:addChild(btn)

-- 	local function tapBtnCb()
-- 		local layer = create()
-- 		local scene = CCDirector:sharedDirector():getRunningScene()
-- 		scene:addChild(layer,5555)
-- 	end
-- 	btn:registerScriptTapHandler(tapBtnCb)
-- end
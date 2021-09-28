-- Filename: HeroLayer.lua
-- Author: fang
-- Date: 2013-07-05
-- Purpose: 该文件用于: 武将阁系统

-- 武将阁系统层对外声明
module ("HeroLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/ui/hero/HeroLayerCell"
require "script/model/hero/HeroModel"
require "script/ui/hero/HeroInfoLayer"
require "script/ui/bag/BagUtil"

m_sign="HeroLayer"
-- 菜单项数据结构
local _menu_item_data 

local _ksTagHero=1001
local _ksTagHeroSoul=1002
local _ksTagExpand=1003
local _ksTagSell=1004
local _ksTagsEvolve = 1006
-- 出售层菜单上的MenuItem
local _ksTagStarSell = 1004
local _ksTagBack = 1005
-- 进阶按钮tag
local _ksTagMetempsychosis=3001
-- 强化按钮tag
local _ksTagStrengthen=4001
-- TableView的tag
local _ksTagTableViewLayer = 5001
-- 英雄头像按钮起始tag
local _ksTagHeroBegin = 6001
-- scrollview的item所有数据（数组）
local _arrHeroesValue
-- 可视的scrollview Cell个数
local _visiableCellNum = 0
-- scrollview高度
local _scrollview_height = 0
-- 当前层
local _ccCurrentLayer
-- 内容层的rect = {x, y, w, h}
local _rectContentLayer = {}

local _bIsHeroModule = true
-- 创建英雄列表tableview方法
local fnCreateHeroTableView
-- 武将互表
local _ccTableViewHeroList
-- 武魂列表
local _ccTableViewSoulList

-- 标题栏对象
local _cs9TitleBar
-- 武将按钮
local _cmiHero
-- 武将按钮
local _cmiHeroSoul
-- 扩充按钮
local _cmiExpand
-- 出售按钮
local _cmiSale

-- 购买武将格子需要的花费
local _nGoldCost=0

local _isEnter = false

--武魂分栏按钮
local _soulTitleButton 		= nil
local _fuseHeroTipSprite 	= nil
local _fuseHeroLabel 		= nil
-- 武将列表索引
m_indexOfHero=1
-- 武魂列表索引
m_indexOfSoul=2

local _nFocusHid=0
local _csBringNumber

local _curOpenIndex = nil
local _lastOpenIndex = nil

local _openCellHeight = 128

-- 菜单按钮被点击事件处理
local function menu_item_tap_handler(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if (tag >= _ksTagMetempsychosis and tag <= (_ksTagMetempsychosis + #_arrHeroesValue)) then
		-- 进阶按钮被点击
		require "script/ui/hero/HeroTransferLayer"
		local nItemIndex = tag-_ksTagMetempsychosis
		local tArgs={selectedHeroes=_arrHeroesValue[nItemIndex]}
		tArgs.fnCreate = HeroLayer.createLayer
		tArgs.sign = m_sign
		tArgs.reserved = {index=m_indexOfHero, item_index=nItemIndex}
		tArgs.heriListoffset= _ccTableViewHeroList:getContentOffset()
		tArgs.addPos = HeroInfoLayer.kHeroBagPos
		MainScene.changeLayer(HeroTransferLayer.createLayer(tArgs), "HeroTransferLayer")

		require "script/guide/NewGuide"
		require "script/guide/GeneralUpgradeGuide"
	    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade) then
	        GeneralUpgradeGuide.changeLayer()
	    end

	elseif (tag >= _ksTagStrengthen and tag <= (_ksTagStrengthen + #_arrHeroesValue)) then
		---[==[强化所新手引导屏蔽层
		---------------------新手引导---------------------------------
			--add by licong 2013.09.06
			require "script/guide/NewGuide"
			if(NewGuide.guideClass ==  ksGuideForge) then
				require "script/guide/StrengthenGuide"
				StrengthenGuide.changLayer()
			end
		---------------------end-------------------------------------
		--]==]
		-- 强化按钮被点击
		require "script/ui/hero/HeroStrengthenLayer"

		local tArgs={sign=HeroLayer.m_sign, fnCreate=HeroLayer.createLayer}
		tArgs.reserved = {index=m_indexOfHero}
		_arrHeroesValue[tag-_ksTagStrengthen].addPos = HeroInfoLayer.kHeroBagPos
		MainScene.changeLayer(HeroStrengthenLayer.createLayer(_arrHeroesValue[tag-_ksTagStrengthen], tArgs), "HeroStrengthenLayer")
		-- 强武将引导 第3步
		addStrengthenGuide3()
	elseif (tag >= _ksTagHeroBegin and tag <= _ksTagHeroBegin + #_arrHeroesValue) then
		require "script/ui/hero/HeroInfoLayer"
		_arrHeroesValue[tag-_ksTagHeroBegin].addPos = HeroInfoLayer.kHeroBagPos
		HeroInfoLayer.createLayer(_arrHeroesValue[tag-_ksTagHeroBegin], {isPanel=true},nil,nil,true, refreshTableView)
	elseif (tag >= 10*_ksTagMetempsychosis) and (tag <= 10*_ksTagMetempsychosis + #_arrHeroesValue) then
		local index = tag - 10*_ksTagMetempsychosis
		require "script/ui/develop/DevelopLayer"
		DevelopLayer.showLayer(_arrHeroesValue[index].hid, DevelopLayer.kOldLayerTag.kHeroTag)
	end
end

local IMG_PATH="images/hero/"
-- 菜单项数据
_menu_item_data = {
	{normal=IMG_PATH.."hero_n.png", highlighted=IMG_PATH.."hero_h.png", 
		pos_x=30, tag=_ksTagHero, ccObj=nil, focus=true, cb=menu_item_tap_handler},
	{normal=IMG_PATH.."soul_n.png", highlighted=IMG_PATH.."soul_h.png", 
		pos_x=270, tag=_ksTagHeroSoul, ccObj=nil, cb=menu_item_tap_handler},
	{normal=IMG_PATH.."sell_n.png", highlighted=IMG_PATH.."sell_h.png", 
		pos_x=500, tag=_ksTagSell, ccObj=nil, cb=menu_item_tap_handler},
}
-- scrollview内容cell中的按钮
local _cell_menu_item_data = {
	{normal=IMG_PATH.."metempsychosis_n.png", highlighted=IMG_PATH.."metempsychosis_h.png", 
		pos_x=320, pos_y=20, tag=_ksTagMetempsychosis, ccObj=nil, focus=true, cb=menu_item_tap_handler},
	{normal=IMG_PATH.."strengthen_n.png", highlighted=IMG_PATH.."strengthen_h.png", 
		pos_x=464, pos_y=20, tag=_ksTagStrengthen, ccObj=nil, cb=menu_item_tap_handler},
}

function setSoulTableView(obj)
	_ccTableViewSoulList = obj
end

-- 获取主页菜单图片完整路径
local function getImagePath(filename, isHighlighted)
	if isHighlighted then
		return IMG_PATH .. filename .. "_h.png"
	end
	return IMG_PATH .. filename .. "_n.png"
end

-- 设置武将系统的菜单项
function createMenusWithBg(layer, menuBGFile, items_data)
	local menu_bg = CCSprite:create(menuBGFile)
	menu_bg:setScale(g_fScaleX)
	local top_y = layer:getContentSize().height
	local y_pos_menu_bg = top_y-(menu_bg:getContentSize().height)*g_fScaleX
	menu_bg:setPosition(ccp(0, y_pos_menu_bg))
	_scrollview_height = y_pos_menu_bg

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 10))
	local point = CCPointMake(0, 0)
	for i=1, #items_data do
		local item=CCMenuItemImage:create(items_data[i].normal, items_data[i].highlighted)
		if (items_data[i].focus == true) then
			item:selected()
		end
		item:setAnchorPoint(point)
		item:setScale(g_fElementScaleRatio/g_fBgScaleRatio)
		item:setPosition(ccp(items_data[i].pos_x*g_fElementScaleRatio/g_fBgScaleRatio, 0))
		item:registerScriptTapHandler(items_data[i].cb)
		items_data[i].ccObj = item
		menu:addChild(item, 0, items_data[i].tag)
	end
	menu_bg:setVisible(false)
	menu_bg:addChild(menu)

	return menu_bg
end

-- 排序原则，1：星级; 2：经验值;........................

-- 武将系统武将列表显示
fnCreateHeroTableView = function (layer)
	local cellBg = CCSprite:create("images/hero/attr_bg.png")
	local cellSize = cellBg:getContentSize()
	cellSize.width = cellSize.width * g_fScaleX
	cellSize.height = cellSize.height * g_fScaleX
	cellBg = nil

	_bIsHeroModule = true

	_visiableCellNum = math.floor(_scrollview_height/(cellSize.height*g_fScaleX))
	
	-- 
	_arrHeroesValue = getArrHeroesValue()

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			if( BagUtil.isSupportBagCell() and _curOpenIndex == a1 )then 
				r = CCSizeMake(cellSize.width, cellSize.height+_openCellHeight*g_fScaleX)
			else
				r = CCSizeMake(cellSize.width, cellSize.height)
			end
		elseif (fn == "cellAtIndex") then
			local length=#_arrHeroesValue
			local value = _arrHeroesValue[length-a1]
			r = HeroLayerCell.createCell(_arrHeroesValue[length-a1],nil,true, a1)
			value.ccCellObj = r
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #_arrHeroesValue
		end
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layer:getContentSize().width, _scrollview_height))
	tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(ccp(0.5,0))
	tableView:setBounceable(true)
	
	-- local bFocusHid = false
	-- if _nFocusHid > 0 then
	-- 	local nIndex = 0
 --        for i=1, #_arrHeroesValue do
 --        	if tonumber(_arrHeroesValue[i].hid) == _nFocusHid then
 --        		nIndex = i
 --        		bFocusHid = true
 --        		break
 --        	end
 --        end
	-- 	local nOffset = _scrollview_height - (#_arrHeroesValue-nIndex+1)*cellSize.height
	-- 	tableView:setContentOffset(ccp(0, nOffset))
	-- end
	-- if not bFocusHid then
	-- 	local maxAnimateIndex = _visiableCellNum
	-- 	if (_visiableCellNum > #_arrHeroesValue) then
	-- 		maxAnimateIndex = #_arrHeroesValue
	-- 	end
	-- 	for i=1, maxAnimateIndex do
	-- 		local cell = tableView:cellAtIndex(maxAnimateIndex - i)
	-- 		if (cell) then
	-- 			local cellBg = tolua.cast(cell:getChildByTag(9001), "CCSprite")
	-- 			cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
	-- 			cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * i ,ccp(0,0)))
	-- 		end
	-- 	end
	-- end

	return tableView
end

-- 获得武将的全部信息
function getArrHeroesValue( ... )
	local hids = HeroModel.getAllHeroesHid()
	-- 武将数值
	local heroesValue = {}
	require "script/utils/LuaUtil"
	require "script/model/hero/HeroModel"
	require "db/DB_Heroes"
	require "script/ui/hero/HeroPublicLua"
	require "script/model/hero/HeroModel"
	require "script/ui/hero/HeroFightForce"
	require "script/ui/hero/HeroFightSimple"
	for i=1, #hids do
		local value = {}
		value.hid = hids[i]
		local hero = HeroModel.getHeroByHid(hids[i])
		

		value.soul = tonumber(hero.soul)
		value.level = tonumber(hero.level)
		value.lock= hero.lock		--  如果武将没有锁定  此字段没有  如果锁定 值为1
		local db_hero = DB_Heroes.getDataById(hero.htid)
		value.isAvatar = HeroModel.isNecessaryHero(hero.htid)
		if value.isAvatar then
			value.name = UserModel.getUserName()
			value.htid = UserModel.getAvatarHtid()
		else
			value.name = db_hero.name
			value.htid = hero.htid
		end
		db_hero = DB_Heroes.getDataById(value.htid)
		value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
        value.decompos_soul = db_hero.decompos_soul
        value.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
        value.awake_id = db_hero.awake_id
		value.grow_awake_id = db_hero.grow_awake_id
		value.heroQuality = db_hero.heroQuality
		
		value.star_lv = db_hero.star_lv
		value.exp_id = db_hero.exp
		-- 武将是否在阵上
		value.isBusy=HeroPublicLua.isInFormationByHid(hids[i])
		value.evolve_level = tonumber(hero.evolve_level)
		value.db_hero = db_hero
		value.fight_value = 0
		value.turned_id = hero.turned_id
		heroesValue[#heroesValue+1] = value
	end
	-- 武将界面 武将排序，排序规则在HeroSort文件中有详细说明
	require "script/ui/hero/HeroSort"
	local arrHeroesValue = HeroSort.sortForHeroList(heroesValue)

	require "db/DB_Hero_evolve"
	local nArrLen = #arrHeroesValue
	for i=1, nArrLen do
		local value = arrHeroesValue[i]
		value.menu_items = {}
		table.hcopy(_cell_menu_item_data, value.menu_items)
		-- 主角只有“进阶”按钮
		if value.isAvatar then
			-- value.menu_items[1].pos_x = 464
			-- value.menu_items[2].pos_x = 10464
		end
		for j=1, #value.menu_items do
			--因为想新建一个tag段，可是方老师法力过于强大，所以只能这么干了
			--目的是对于进阶+7武将且可以进阶成橙将的，进阶按钮变为武将进化按钮
			--added by Zhang Zihang
			--if (tonumber(value.evolve_level) == 7) and (DB_Hero_evolve.getDataById(value.htid) ~= nil) and (j == 1) then
			require "script/ui/develop/DevelopData"
			if DevelopData.doOpenDevelopByHid(value.hid) and (j == 1) then
				value.menu_items[j].tag = 10*value.menu_items[j].tag + i
			else
				value.menu_items[j].tag = value.menu_items[j].tag + i
			end
		end
		value.hero_tag = _ksTagHeroBegin+i
		value.hero_cb = menu_item_tap_handler
		value.menu_tag = 80001

		if(HeroModel.isNecessaryHero(value.htid)) then
			value.dressId = UserModel.getDressIdByPos(1)
		end
	end
	return arrHeroesValue
end

-- 购买武将格子网络回调
function fnHandlerOfNetwork(cbFlag, dictData, bRet)
	if bRet then
		local nRetValue = tonumber(dictData.ret)
		local nAdded = nRetValue-UserModel.getHeroLimit()
		UserModel.addGoldNumber(-_nGoldCost)
		UserModel.setHeroLimit(nRetValue)
		AnimationTip.showTip(GetLocalizeStringBy("key_2343")..nAdded..GetLocalizeStringBy("key_2491"))
		addBringSprite(_ccCurrentLayer)
	end
end

-- 标题栏的按钮事件处理
function fnHandlerOfTitleButtons(tag, obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	obj:selected()
	-- 武将列表
	if tag == _ksTagHero then
		if _bIsHeroModule then
			return
		end
		if not _bIsHeroModule then
			if _ccTableViewSoulList then
				_ccTableViewSoulList:removeFromParentAndCleanup(true)
			end
			setOpenIndex(nil)
			_ccTableViewHeroList = fnCreateHeroTableView(_ccCurrentLayer)
			_ccTableViewHeroList:setPosition(_ccCurrentLayer:getContentSize().width*0.5,10*g_fScaleX)
			_ccCurrentLayer:addChild(_ccTableViewHeroList)
		end
		_bIsHeroModule=true
		_cmiHero:selected()
		_cmiHeroSoul:unselected()
		_cmiExpand:setVisible(true)
		_cmiSale:setVisible(true)
		if(_cmiEvolveItem ~= nil)then
			_cmiEvolveItem:setVisible(true)
		end
		addBringSprite(_ccCurrentLayer)
	-- 武魂项
	elseif tag == _ksTagHeroSoul then
		if not _bIsHeroModule then
			return
		end
		if _ccTableViewHeroList then
			_ccTableViewHeroList:removeFromParentAndCleanup(true)
		end
		cleanupBringSprite()
		require "script/ui/hero/HeroSoulLayer"
		_ccTableViewSoulList = HeroSoulLayer.createTableView(_ccCurrentLayer, _scrollview_height)
		_ccTableViewSoulList:ignoreAnchorPointForPosition(false)
    	_ccTableViewSoulList:setAnchorPoint(ccp(0.5,0))
		_ccTableViewSoulList:setPosition(_ccCurrentLayer:getContentSize().width*0.5,10*g_fScaleX)
		_ccCurrentLayer:addChild(_ccTableViewSoulList)
		_bIsHeroModule=false
		_cmiHeroSoul:selected()
		_cmiHero:unselected()
		_cmiExpand:setVisible(false)
		_cmiSale:setVisible(false)
		if(_cmiEvolveItem ~= nil)then
			_cmiEvolveItem:setVisible(false)
		end
	-- 武将数量扩充
	elseif tag == _ksTagExpand then
		require "script/ui/hero/HeroPublicUI"
		local function fnExpandCb( ... )
			addBringSprite(_ccCurrentLayer)
		end
		HeroPublicUI.showHeroExpandUI({cb_expand=fnExpandCb})
	-- 武将出售
	elseif tag == _ksTagSell then
		cleanupBringSprite()
		-- 进入武将出售菜单项（出售按钮）
		require "script/ui/hero/HeroSellLayer"
		require "script/ui/main/MainScene"
		MainScene.changeLayer(HeroSellLayer.createLayer(), "HeroSellLayer")
		_bIsHeroModule = true
	elseif tag == _ksTagsEvolve then
		---[==[武将进化 新手引导屏蔽层
		---------------------新手引导---------------------------------
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideHeroDevelop) then
			require "script/guide/HeroDevelopGuide"
			HeroDevelopGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]
		require "script/ui/develop/DevelopLayer"
		DevelopLayer.showLayer(nil, DevelopLayer.kOldLayerTag.kHeroTag)
	end
end

-- added by zhz
function setHeroListOffSet(offset )
	if(offset == nil)then
		return
	end
	local maxContentOffset = _ccTableViewHeroList:getViewSize().height - _ccTableViewHeroList:getContentSize().height
	if(offset.y < maxContentOffset) then
		_ccTableViewHeroList:setContentOffset(ccp(0, maxContentOffset))
	else
		_ccTableViewHeroList:setContentOffset(offset)
	end
end

-- added by zhz
function refreshTableView( )
	local offfset = _ccTableViewHeroList:getContentOffset()
	_arrHeroesValue =getArrHeroesValue()
	_ccTableViewHeroList:reloadData()
	_ccTableViewHeroList:setContentOffset(offfset)

end

-- 添加其它按钮
function addOtherButtons(cmButtons)
	-- 扩充按钮
	local cmiExpand = CCMenuItemImage:create("images/common/btn/btn_expand_n.png", "images/common/btn/btn_expand_h.png")
	cmiExpand:registerScriptTapHandler(fnHandlerOfTitleButtons)
	cmiExpand:setPosition(460, 6)
	-- 出售按钮
	local cmiSale = CCMenuItemImage:create("images/common/btn/btn_sale_n.png", "images/common/btn/btn_sale_h.png")
	cmiSale:registerScriptTapHandler(fnHandlerOfTitleButtons)
	cmiSale:setPosition(540, 6)
	--进化按钮
	if DataCache.getSwitchNodeState(ksHeroDevelop, false) then
		_cmiEvolve = CCMenuItemImage:create("images/develop/develop_btn_n.png","images/develop/develop_btn_h.png")
		_cmiEvolve:registerScriptTapHandler(fnHandlerOfTitleButtons)
		_cmiEvolve:setPosition(380,6)
		cmButtons:addChild(_cmiEvolve,0,_ksTagsEvolve)
	end

	cmButtons:addChild(cmiExpand, 0, _ksTagExpand)
	cmButtons:addChild(cmiSale, 0, _ksTagSell)
	cmButtons:setTouchPriority(-550)
end

local function init( ... )
	_csBringNumber=nil
	_curOpenIndex = nil
end

-- 创建“武将系统”层
function createLayer(tParam)
	init()
	_isEnter = true
	local bgLayer = CCLayer:create()
	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	MainScene.getAvatarLayerObj():setVisible(true)
	MenuLayer.getObject():setVisible(true)
	BulletinLayer.getLayer():setVisible(true)
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local avatarLayerSize = MainScene.getAvatarLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local layerSize = {}
	-- 层高等于设备总高减去“公告层”，“avatar层”，GetLocalizeStringBy("key_2785")高
	layerSize.height = g_winSize.height - (bulletinLayerSize.height+avatarLayerSize.height+menuLayerSize.height)*g_fScaleX
	layerSize.width = g_winSize.width
	bgLayer:setContentSize(CCSizeMake(layerSize.width, layerSize.height))
	bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
	local ccSpriteBg = CCSprite:create("images/main/module_bg.png")
	ccSpriteBg:setScale(g_fBgScaleRatio)
	ccSpriteBg:setAnchorPoint(ccp(0.5, 0.5))
	ccSpriteBg:setPosition(ccp(layerSize.width/2, layerSize.height/2))
	bgLayer:addChild(ccSpriteBg)

	-- 内容层区域
	_rectContentLayer.x = 0
	_rectContentLayer.y = menuLayerSize.height*g_fScaleX
	_rectContentLayer.width = g_winSize.width
	_rectContentLayer.height = layerSize.height

	local tArgs = {}
	tArgs[1] = {text=GetLocalizeStringBy("key_1453"), x=10, tag=_ksTagHero, handler=fnHandlerOfTitleButtons}
	tArgs[2] = {text=GetLocalizeStringBy("key_3237"), x=200, tag=_ksTagHeroSoul, handler=fnHandlerOfTitleButtons}
	require "script/libs/LuaCCSprite"
	local cs9TitleBar = LuaCCSprite.createTitleBar(tArgs)
	_cs9TitleBar = cs9TitleBar
	cs9TitleBar:setAnchorPoint(ccp(0, 1))
	cs9TitleBar:setPosition(0, layerSize.height+19*g_fScaleX)
	cs9TitleBar:setScale(g_fScaleX)
	addOtherButtons(cs9TitleBar:getChildByTag(10001))
	bgLayer:addChild(cs9TitleBar)
	local csMenu = tolua.cast(cs9TitleBar:getChildByTag(10001), "CCMenu")
	_soulTitleButton = tolua.cast(csMenu:getChildByTag(1002), "CCSprite")
	_fuseHeroTipSprite = CCSprite:create("images/common/tip_2.png")
	_fuseHeroTipSprite:setAnchorPoint(ccp(0.5, 0.5))
	_fuseHeroTipSprite:setPosition(ccpsprite(0.9, 0.9, _soulTitleButton))
	_soulTitleButton:addChild(_fuseHeroTipSprite)

	require "script/ui/hero/HeroSoulLayer"
	_fuseHeroLabel = CCLabelTTF:create(tostring(HeroSoulLayer.getFuseSoulNum()),g_sFontName,21)
	_fuseHeroLabel:setAnchorPoint(ccp(0.5, 0.5))
	_fuseHeroLabel:setPosition(ccpsprite(0.5, 0.5, _fuseHeroTipSprite))
	_fuseHeroTipSprite:addChild(_fuseHeroLabel)

	refreshTitleTipNum()

	local menu = createMenusWithBg(bgLayer, "images/hero/menu_bg.png", _menu_item_data)

	_bIsHeroModule=true
	bgLayer:addChild(menu)

	local menu = tolua.cast(_cs9TitleBar:getChildByTag(10001), "CCMenu")
	_cmiHero=tolua.cast(menu:getChildByTag(_ksTagHero), "CCMenuItem")
	_cmiHeroSoul=tolua.cast(menu:getChildByTag(_ksTagHeroSoul), "CCMenuItem")
	_cmiExpand=tolua.cast(menu:getChildByTag(_ksTagExpand), "CCMenuItem")
	_cmiSale=tolua.cast(menu:getChildByTag(_ksTagSell), "CCMenuItem")
	_cmiEvolveItem = tolua.cast(menu:getChildByTag(_ksTagsEvolve), "CCMenuItem")

	_cmiHero:selected()
	_nFocusHid=0
	if tParam and tParam.focusHid then
		_nFocusHid=tonumber(tParam.focusHid)
	end
	--	if tParam and tParam
	if tParam and tParam.index and tParam.index == m_indexOfSoul then
		require "script/ui/hero/HeroSoulLayer"
		_ccTableViewSoulList = HeroSoulLayer.createTableView(bgLayer, _scrollview_height)
		_ccTableViewSoulList:ignoreAnchorPointForPosition(false)
    	_ccTableViewSoulList:setAnchorPoint(ccp(0.5,0))
    	_ccTableViewSoulList:setPosition(bgLayer:getContentSize().width*0.5,10*g_fScaleX)
		bgLayer:addChild(_ccTableViewSoulList)
		_bIsHeroModule=false
		_cmiHero:unselected()
		_cmiHeroSoul:selected()
		_cmiExpand:setVisible(false)
		_cmiSale:setVisible(false)
		if(_cmiEvolveItem ~= nil)then
			_cmiEvolveItem:setVisible(false)
		end
	else
		_ccTableViewHeroList = fnCreateHeroTableView(bgLayer)
		_ccTableViewHeroList:setPosition(bgLayer:getContentSize().width*0.5,10*g_fScaleX)
		bgLayer:addChild(_ccTableViewHeroList, 0, _ksTagTableViewLayer)
		addBringSprite(bgLayer)
	end
	_ccCurrentLayer = bgLayer

	-- 进阶新手引导兼容
	if( BagUtil.isSupportBagCell() and NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 1 )then
		local needIndex = #_arrHeroesValue-1
		setOpenIndex(needIndex)
		refreshBagTableView(_openCellHeight,needIndex)
	end

	-- 武将强化 第二步 新手 
	_ccCurrentLayer:registerScriptHandler(function (event)
		if event == "enter" then
			-- local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			-- 	StrengthenGuide2stCallback()
			-- 	layerDidLoadCallfunc()
			-- end))
			-- _ccCurrentLayer:runAction(seq)
		end
	end)

	bgLayer:registerScriptHandler(function ( eventType )
		if(eventType == "enter") then
			local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
				StrengthenGuide2stCallback()
				layerDidLoadCallfunc()
				-- 武将进化第2步
				addGuideHeroDevelopGuide2()
			end))
			_ccCurrentLayer:runAction(seq)
		elseif(eventType == "exit") then
			require "script/model/hero/HeroModel"
			HeroModel.clearAllNewHeroSign()
			require "script/ui/main/MainBaseLayer"
			MainBaseLayer.removeNewHeroButton()
		end
	end)
	require "script/model/hero/HeroModel"
	HeroModel.bHaveNewHero	=	false
	return bgLayer
end
-- 增加GetLocalizeStringBy("key_2314")提示

function addBringSprite(cParent)
	cleanupBringSprite()
	-- 物品个数背景
    local csBg = CCScale9Sprite:create("images/common/bgng_lefttimes.png", CCRectMake(0,0,33,33), CCRectMake(20,8,5,1))
    
    csBg:setAnchorPoint(ccp(0.5, 0))
    csBg:setPosition(cParent:getContentSize().width/2, cParent:getContentSize().height*0.015)
    cParent:addChild(csBg, 9999)

    -- 携带数标题：
    local bringNumLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1838"), g_sFontName, 24, 1, ccc3(0, 0, 0), type_stroke)
    bringNumLabel:setAnchorPoint(ccp(0.5, 0.5))
    local hOffset = 6
    local tSizeOfText = bringNumLabel:getContentSize()
    bringNumLabel:setPosition(tSizeOfText.width/2+hOffset, csBg:getContentSize().height/2-1)
    csBg:addChild(bringNumLabel)

    local displayNum = #_arrHeroesValue.."/"..UserModel.getHeroLimit()
    -- 携带数数据：
    local numLabel = CCRenderLabel:create(displayNum, g_sFontName, 24, 1, ccc3(0, 0, 0), type_stroke)
    numLabel:setColor(ccc3(0x36, 255, 0))
    numLabel:setAnchorPoint(ccp(0.5, 0.5))
    local tSizeOfNum = numLabel:getContentSize()
    local x = tSizeOfText.width + hOffset + tSizeOfNum.width/2
    numLabel:setPosition(x-10, csBg:getContentSize().height/2-2)
    csBg:addChild(numLabel)

    local nWidth = x + tSizeOfNum.width/2
	
    csBg:setPreferredSize(CCSizeMake(nWidth, 33))
    csBg:setScale(g_fScaleX)
    _csBringNumber=csBg
end

function cleanupBringSprite( ... )
	if _csBringNumber then
		_csBringNumber:removeFromParentAndCleanup(true)
	end
	_csBringNumber=nil
end

--[[
	@des 	:设置展开的cellIndex
	@param 	:pIndex
	@return :
--]]
function setOpenIndex( pIndex )
	_lastOpenIndex= _curOpenIndex
	_curOpenIndex = pIndex
end

--[[
	@des 	:得到展开的cellIndex
	@param 	:
	@return :pIndex
--]]
function getOpenIndex()
	return _curOpenIndex
end

--[[
	@des 	:得到展开的cellIndex
	@param 	:
	@return :pIndex
--]]
function refreshBagTableView(pAddHeight,pIndex )
	if(tolua.isnull(_ccCurrentLayer))then 
		return
	end
	-- print("_curOpenIndex",_curOpenIndex)
	-- 偏移量记忆
	local offset = _ccTableViewHeroList:getContentOffset()
	-- print("refreshBagTableView offset==>",offset.y,pIndex)
	_ccTableViewHeroList:reloadData()
	-- print("_visiableCellNum,",_visiableCellNum,#_arrHeroesValue)
	if( (_lastOpenIndex == 0 or pIndex == 0) and _visiableCellNum <= #_arrHeroesValue  )then
		offset.y = 0
	elseif( _lastOpenIndex == nil or _lastOpenIndex == pIndex )then
		offset.y = offset.y-pAddHeight*g_fScaleX
	end
	-- print("refreshBagTableView offset==>2",offset.y,_lastOpenIndex,pIndex)
	_ccTableViewHeroList:setContentOffset(offset)
end

--------------------------------------------[[ 新手引导 ]]----------------------------------------------------------

function getUpgradeButton( ... )
	local cell = tableView:cellAtIndex(0)
	
end


-- 为新手引导提供”强化“ 按钮对象
function getStrengthenButtonForGuide( ... )
	local nCells = #_arrHeroesValue
	local ccCellObj = _arrHeroesValue[2].ccCellObj
	local cellBg = tolua.cast(ccCellObj:getChildByTag(9001), "CCSprite")
	local ccMenu = tolua.cast(cellBg:getChildByTag(80001), "CCMenu")
	local cmiStrengthen = tolua.cast(ccMenu:getChildByTag(_ksTagStrengthen+2), "CCMenuItem")

	return cmiStrengthen
end


function StrengthenGuide2stCallback( ... )
	---[==[ 第二步强化按钮
	---------------------新手引导---------------------------------
    --add by licong 2013.09.06
    require "script/guide/NewGuide"
	require "script/guide/StrengthenGuide"
    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 1) then
	    local strengthenButton = getStrengthenButtonForGuide()
	    local touchRect = getSpriteScreenRect(strengthenButton)
	    StrengthenGuide.show(2, touchRect)
	end
 	---------------------end-------------------------------------
	--]==]
end


function addStrengthenGuide3( ... )
	---[==[ 第三步加号按钮
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.07
	    require "script/guide/NewGuide"
		require "script/guide/StrengthenGuide"
	    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 2) then
		    require "script/ui/hero/HeroStrengthenLayer"
		    local strengthenButton = HeroStrengthenLayer.getAddButtonForGuide()
		    local touchRect = getSpriteScreenRect(strengthenButton)
		    StrengthenGuide.show(3, touchRect)
		end
	 ---------------------end-------------------------------------
	--]==]
end

-- 获得主角进阶按钮（新手引导相关）
function getAvatarTransferButton( ... )
	local item = nil
	if(  BagUtil.isSupportBagCell() )then
		local cmAvatar = _arrHeroesValue[1].ccCellObj
		local csBg = tolua.cast(cmAvatar:getChildByTag(9002), "CCSprite")
		local menu = tolua.cast(csBg:getChildByTag(80002), "CCMenu")
		item = tolua.cast(menu:getChildByTag(_ksTagMetempsychosis+1), "CCMenuItem")
	else
		local cmAvatar = _arrHeroesValue[1].ccCellObj
		local csBg = tolua.cast(cmAvatar:getChildByTag(9001), "CCSprite")
		local menu = tolua.cast(csBg:getChildByTag(80001), "CCMenu")
		item = tolua.cast(menu:getChildByTag(_ksTagMetempsychosis+1), "CCMenuItem")
	end
	return item
end

--[[
	@des:	layer didload event
]]
function layerDidLoadCallfunc( ... )

	--武将进阶新手引导
	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 1) then
     	local equipButton = getAvatarTransferButton()
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(2,touchRect)
    end
end


--[[
	@des: 得到提示图标
--]]
function getTitleTipSprite( ... )
	if(_fuseHeroTipSprite) then
		return _fuseHeroTipSprite
	else
		return nil
	end
end

function getIsEnter( ... )
	return _isEnter
end


--[[
	@des:	刷新提示数量
--]]
function refreshTitleTipNum( ... )
	require "script/ui/hero/HeroSoulLayer"
	local num = HeroSoulLayer.getFuseSoulNum()
	if(num <= 0) then
		_fuseHeroTipSprite:setVisible(false)
	else
		_fuseHeroTipSprite:setVisible(true)
		_fuseHeroLabel:setString(tostring(num))
	end
end

-- 得到武将进阶按钮
function getCmiEvolveBtn( ... )
	return _cmiEvolve
end


---[==[武将进化 第2步
---------------------新手引导---------------------------------
function addGuideHeroDevelopGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/HeroDevelopGuide"
    if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 1) then
     	local button = getCmiEvolveBtn()
        local touchRect   = getSpriteScreenRect(button)
        HeroDevelopGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]





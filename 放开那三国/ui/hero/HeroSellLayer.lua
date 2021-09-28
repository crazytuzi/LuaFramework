-- Filename: HeroSell.lua.
-- Author: fang.
-- Date: 2013-07-18
-- Purpose: 武将出售功能

module("HeroSellLayer", package.seeall)

require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/formation/secondfriend/SecondFriendData"
-- 出售层菜单上的MenuItem
-- 按星级出售按钮tag
local _ksTagStarSell = 1001
-- 返回按钮tag
local _ksTagBack = 1002
-- 出售按钮tag
local _ksTagSell = 2001
-- 复选框背景tag
local _ksTagCheckBg = 3001
-- 英雄tableview的tag
local _ksTagHeroTableView = 4001
-- 按星级出售层tag
local _ksTagLayerStarSell = 5001
-- 星级出售tag
local _ksTagStarLevelSell = 6001
-- 星级出售面板GetLocalizeStringBy("key_1284")按钮tag
local _ksTagStarSellPanelCloseBtn = 7001
-- 星级出售面板“取消选择”按钮tag
local _ksTagStarSellPanelSelectAll = 7002
-- 星级出售面板“选择全部”按钮tag
local _ksTagStarSellPanelCancel = 7003
-- 星级出售面板“确定”按钮tag
local _ksTagStarSellPanelSure = 7004
-- 星级出售面板菜单tag
local _ksTagStarSellPanelMenu = 8001
-- 武将头像起始tag
local _ksTagHeadIconBegin = 9001
-- tableview中的菜单tag
local _ksTagTableViewMenu=101
-- tableview中的背景tag
local _ksTagTableViewBg = 201
-- 总售总计银币文本显示
local _ccLabelSilverNumber
-- 出售英雄个数文本显示
local _ccLabelNumber
-- 按星级出售的menu
local _ccMenuStarSell
local _nHeroSellCount = 0
local _onNetCallFlag
-- 当前英雄列表控件
local _ccCurrentTableView
-- 底部框控件layer
local _CCLayerBottom
-- 全部选择按钮
local _ccButtonSelectAll
-- 取消选择按钮
local _ccButtonCancel

-- scrollview的item所有数据（数组）
local _arrHeroesValue
-- 更新选择信息方法
local fnUpdateSelectionInfo
-- 更新英雄列表方法
local fnUpdateTableView
-- 更新英雄列表勾选状态方法(在星级出售选择之后)
local fnUpdateTableViewAfterStarSell
-- 取得出售银币数量
local fnGetSellSilverNumber

local IMG_PATH="images/hero/"

-- 可视的scrollview Cell个数
local _visiableCellNum = 0
-- scrollview的高度（需要计算）
local _scrollview_height = 0
-- 当前正在运行的层
local _onRunningLayer

local function fnOnHeroSell(cbName, dictData, bRet)
	if (_onNetCallFlag == cbName and bRet) then
		-- 获得银币数量
		local silver_number = fnGetSellSilverNumber()
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2736")..silver_number..GetLocalizeStringBy("key_1687"))
		require "script/model/user/UserModel"
		UserModel.addSilverNumber(silver_number)
		-- 更新列表内容
		for i=1, #_arrHeroesValue do
			--判断该武将是否在神兵副本中，神兵副本中的武将不能出售
			local isGodCopyHero = false
			if GodWeaponCopyData.isOnCopyFormationBy(_arrHeroesValue[i].hid) then
				isGodCopyHero = true
			end
			if (_arrHeroesValue[i].checkIsSelected and isGodCopyHero == false) then
				HeroModel.deleteHeroByHid(_arrHeroesValue[i].hid)
				_arrHeroesValue[i].checkIsSelected  = false
			end
		end
		_nHeroSellCount = 0
		fnUpdateSelectionInfo()
		fnUpdateTableView()
	end
end

-- 星级数据数组
local _star_level_data = {
	{number=1, tag=_ksTagStarLevelSell+1, },
	{number=2, tag=_ksTagStarLevelSell+2, },
	{number=3, tag=_ksTagStarLevelSell+3, },
	{number=4, tag=_ksTagStarLevelSell+4, },
}
-- 按星级出售菜单项回调处理
local function fnHandlerOfMenuItemStarLevelSell(tag, item_obj)
	-- “关闭”按钮事件处理
	if tag==_ksTagStarSellPanelCloseBtn or tag==_ksTagStarSellPanelSure then
		for i=1, #_star_level_data do
			local item = tolua.cast(_ccMenuStarSell:getChildByTag(_star_level_data[i].tag), "CCMenuItemImage")
			if item then
				local ccSelected = tolua.cast(item:getChildByTag(_star_level_data[i].tag), "CCSprite")
				if (ccSelected:isVisible()) then
					_star_level_data[i].isSelected = true
				end
			end
		end
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:removeChildByTag(_ksTagLayerStarSell, true)
--		_onRunningLayer:removeChildByTag(_ksTagLayerStarSell, true)
		fnUpdateTableViewAfterStarSell()
	-- “全部选择”按钮事件处理
	elseif (tag == _ksTagStarSellPanelSelectAll) then
		_ccButtonSelectAll:setVisible(false)
		_ccButtonCancel:setVisible(true)
		for i=1, #_star_level_data do
			local item = tolua.cast(_ccMenuStarSell:getChildByTag(_star_level_data[i].tag), "CCMenuItemImage")
			if item then
				local ccSelected = tolua.cast(item:getChildByTag(_star_level_data[i].tag), "CCSprite")
				ccSelected:setVisible(true)
			end
		end
	-- “取消选择”按钮事件处理
	elseif tag == _ksTagStarSellPanelCancel then
		_ccButtonSelectAll:setVisible(true)
		_ccButtonCancel:setVisible(false)
		for i=1, #_star_level_data do
			local item = tolua.cast(_ccMenuStarSell:getChildByTag(_star_level_data[i].tag), "CCMenuItemImage")
			if item then
				local ccSelected = tolua.cast(item:getChildByTag(_star_level_data[i].tag), "CCSprite")
				ccSelected:setVisible(false)
			end
		end
	-- 各星级点击事件处理
	elseif (tag >= _ksTagStarLevelSell and tag <= _ksTagStarLevelSell+#_star_level_data) then
		local item = tolua.cast(_ccMenuStarSell:getChildByTag(tag), "CCMenuItemImage")
		local ccSelected = tolua.cast(item:getChildByTag(tag), "CCSprite")
		if (ccSelected:isVisible() == true) then
			ccSelected:setVisible(false)
		else
			ccSelected:setVisible(true)
		end
	end
end

-- 创建星级菜单项方法
local function createStarLevelMenuItem(star_level_data)
	local item = CCMenuItemImage:create("images/hero/star_sell/item_bg_n.png", "images/hero/star_sell/item_bg_h.png")
	item:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	-- 几星文本显示
	local ccLabelNumber = CCLabelTTF:create(star_level_data.number, g_sFontName, 30)
	ccLabelNumber:setColor(ccc3(0xff, 0xed, 0x55))
	ccLabelNumber:setPosition(ccp(78, 8))
	item:addChild(ccLabelNumber)
	-- 星图片
	local ccSpriteStar = CCSprite:create("images/hero/star.png")
	ccSpriteStar:setPosition(ccp(120, 14))
	item:addChild(ccSpriteStar)
	-- 是否选中显示
	local ccSpriteSelected = CCSprite:create("images/common/checked.png")
	ccSpriteSelected:setPosition(ccp(176, 10))
	ccSpriteSelected:setVisible(false)
	item:addChild(ccSpriteSelected, 0, star_level_data.tag)

	return item
end
local function fnFilterTouchEvent(event, x, y)
	return true
end

-- 创建按星级出售层
local function createLayerStarSell(_onRunningLayer)
	local layer = CCLayerColor:create(ccc4(11,11,11,166))
	-- 背景九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	local ccStarSellBG = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	ccStarSellBG:setPreferredSize(CCSizeMake(524, 438))
	local bg_size = ccStarSellBG:getContentSize()
	local pos_y = _scrollview_height/2+_CCLayerBottom:getContentSize().height*g_fScaleX
	ccStarSellBG:setPosition(ccp(g_winSize.width/2, pos_y))
	ccStarSellBG:setAnchorPoint(ccp(0.5, 0.5))
	-- 按星级出售标题背景
	local ccTitleBG = CCSprite:create("images/common/viewtitle1.png")
	ccTitleBG:setPosition(ccp(bg_size.width/2, bg_size.height-6))
	ccTitleBG:setAnchorPoint(ccp(0.5, 0.5))
	ccStarSellBG:addChild(ccTitleBG)
	-- 按星级出售标题文本
	local ccLabelTitle = CCLabelTTF:create (GetLocalizeStringBy("key_1487"), g_sFontName, 35, CCSizeMake(315, 61), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	ccLabelTitle:setPosition(ccp(ccTitleBG:getContentSize().width/2, (ccTitleBG:getContentSize().height-1)/2))
	ccLabelTitle:setAnchorPoint(ccp(0.5, 0.5))
	ccLabelTitle:setColor(ccc3(0xff, 0xf0, 0x49))
	ccTitleBG:addChild(ccLabelTitle)
	-- “请选择星级”文本显示
	local ccLabelTip = CCRenderLabel:create(GetLocalizeStringBy("key_3317"), g_sFontName, 30, 1, ccc3(0, 0, 0), type_stroke)
	ccLabelTip:setAnchorPoint(ccp(0.5, 0))
	ccLabelTip:setPositionX(bg_size.width/2)
	ccLabelTip:setColor(ccc3(0xff, 0xed, 0x55))
	ccLabelTip:setPositionY(356)
	ccStarSellBG:addChild(ccLabelTip)

	local menu = CCMenu:create()
	menu:setContentSize(bg_size)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(-454)
	-- 星级MenuItem
	pos_y = 94
	for i=1, #_star_level_data do
		local item = createStarLevelMenuItem(_star_level_data[#_star_level_data-i+1])
		item:setPosition(ccp(bg_size.width/2, pos_y))
		item:setAnchorPoint(ccp(0.5, 0))
		menu:addChild(item, 0, _star_level_data[#_star_level_data-i+1].tag)
		pos_y = pos_y + item:getContentSize().height+10
	end

	local ccButtonClose = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	ccButtonClose:setAnchorPoint(ccp(1, 1))
	ccButtonClose:setPosition(ccp(bg_size.width+14, bg_size.height+14))
	ccButtonClose:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(ccButtonClose, 0, _ksTagStarSellPanelCloseBtn)

	ccStarSellBG:addChild(menu, 0, _ksTagStarSellPanelMenu)

	require "script/libs/LuaCC"
	_ccButtonSelectAll = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2776"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	-- 全部选择按钮
	_ccButtonSelectAll:setAnchorPoint(ccp(0.5, 0))
	_ccButtonSelectAll:setPosition(bg_size.width*0.3, 18)
	_ccButtonSelectAll:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(_ccButtonSelectAll, 0, _ksTagStarSellPanelSelectAll)
	-- 取消选择按钮
	_ccButtonCancel = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2982"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	_ccButtonCancel:setAnchorPoint(ccp(0.5, 0))
	_ccButtonCancel:setPosition(bg_size.width*0.3, 18)
	_ccButtonCancel:setVisible(false)
	_ccButtonCancel:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(_ccButtonCancel, 0, _ksTagStarSellPanelCancel)

-- 确定按钮
	local ccBtnSure = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2229"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	ccBtnSure:setAnchorPoint(ccp(0.5, 0))
	ccBtnSure:setPosition(bg_size.width*0.7, 18)
	ccBtnSure:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(ccBtnSure, 0, _ksTagStarSellPanelSure)

	_ccMenuStarSell = menu

	ccStarSellBG:setScale(g_fElementScaleRatio)

	layer:addChild(ccStarSellBG)
	layer:setTouchPriority(-451)
	layer:setTouchEnabled(true)
	layer:registerScriptTouchHandler(fnFilterTouchEvent,false,-450, true)

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, 1000, _ksTagLayerStarSell)
end

local function menu_item_tap_handler(tag, item_obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	if (tag == _ksTagStarSell) then
		createLayerStarSell(_onRunningLayer)
	elseif (tag == _ksTagBack) then
		-- print ("_ksTagBack is clicked")
		-- 进入武将layer
		require "script/ui/hero/HeroLayer"
		require "script/ui/main/MainScene"
		MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
	elseif (tag == _ksTagSell) then
		-- 如果卖出英雄个数大于0，则进行卖出交互操作
		if _nHeroSellCount > 0 then
			local function fnSell(bIsConfirm)
				if bIsConfirm then
					-- 英雄卖出
					require "script/network/Network"
					require "script/network/RequestCenter"
					require "script/model/hero/HeroModel"
					-- 通知服务器
					local subArgs = CCArray:create()
					for i=1, #_arrHeroesValue do
						if (_arrHeroesValue[i].checkIsSelected) then
							--神兵副本中的武将不能出售
							if GodWeaponCopyData.isOnCopyFormationBy(_arrHeroesValue[i].hid) == false 
								and SecondFriendData.isInSecondFriendByHid(_arrHeroesValue[i].hid) == false then
								subArgs:addObject(CCInteger:create(_arrHeroesValue[i].hid))
							end
						end
					end
					local args = CCArray:createWithObject(subArgs)
					_onNetCallFlag = RequestCenter.hero_sell(fnOnHeroSell, args)
				end
			end
			require "script/ui/tip/AlertTip"
			AlertTip.showAlert(GetLocalizeStringBy("key_3389").._nHeroSellCount..GetLocalizeStringBy("key_2198")..fnGetSellSilverNumber()..GetLocalizeStringBy("key_1687"), fnSell, true)
		else
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_2653"))
		end
	end
end
-- 菜单项数据
local _menu_item_data = {
	{normal=IMG_PATH.."btn_star_sell_n.png", highlighted=IMG_PATH.."btn_star_sell_h.png",
		pos_x=320, tag=_ksTagStarSell, ccObj=nil, cb=menu_item_tap_handler},
	{normal=IMG_PATH.."btn_back_n.png", highlighted=IMG_PATH.."btn_back_h.png", 
		pos_x=534, tag=_ksTagBack, ccObj=nil, cb=menu_item_tap_handler},
}
-- scrollview内容cell中的按钮
local _cell_menu_item_data = {
	{normal="images/common/checkbg.png", highlighted="images/common/checkbg.png", 
		pos_x=548, pos_y=46, tag=_ksTagCheckBg, 
		ccObj=nil, focus=true, cb=menu_item_tap_handler},
}

-- 英雄出售底
local function createMenuBottomLayer()
	local layer = CCLayer:create()
	-- 背景
	local bg = CCSprite:create("images/common/sell_bottom.png")
	layer:setContentSize(CCSizeMake(bg:getContentSize().width, bg:getContentSize().height))
	layer:setScale(g_fScaleX)
	-- 已选择武将(label)
	local ccLabelSelected = CCLabelTTF:create (GetLocalizeStringBy("key_1529"), g_sFontName, 25)
	ccLabelSelected:setPosition(ccp(4, 26))
	bg:addChild(ccLabelSelected)

	-- 出售英雄个数背景(9宫格)
	local fullRect = CCRectMake(0, 0, 34, 32)
	local insetRect = CCRectMake(12, 12, 10, 6)
	local ccHeroNumberBG = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	ccHeroNumberBG:setPreferredSize(CCSizeMake(70, 36))
	ccHeroNumberBG:setPosition(ccp(ccLabelSelected:getContentSize().width+ccLabelSelected:getPositionX()-10, ccLabelSelected:getPositionY()))
	bg:addChild(ccHeroNumberBG)
	-- 出售英雄个数
	_ccLabelNumber = CCLabelTTF:create ("0", g_sFontName, 25, CCSizeMake(70, 32), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
	_ccLabelNumber:setPosition(ccp(ccHeroNumberBG:getPositionX(), ccHeroNumberBG:getPositionY()))
	bg:addChild(_ccLabelNumber)

	-- 总计出售
	local ccLabelTotal = CCLabelTTF:create (GetLocalizeStringBy("key_1821"), g_sFontName, 25)
	ccLabelTotal:setPosition(ccp(ccHeroNumberBG:getContentSize().width+ccHeroNumberBG:getPositionX()+20, 26))
	bg:addChild(ccLabelTotal)
	-- 总计出售背景
	local ccTotalSilverBG = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	ccTotalSilverBG:setPreferredSize(CCSizeMake(142, 36))
	ccTotalSilverBG:setPosition(ccp(ccLabelTotal:getContentSize().width+ccLabelTotal:getPositionX()-10, ccLabelTotal:getPositionY()))
	bg:addChild(ccTotalSilverBG)
	-- 银币图标
	local ccSilverIcon = CCSprite:create("images/common/coin_silver.png")
	ccSilverIcon:setPosition(ccp(ccTotalSilverBG:getPositionX()+8, ccTotalSilverBG:getPositionY()+2))
	bg:addChild(ccSilverIcon)
	-- 银币数量
	_ccLabelSilverNumber = CCLabelTTF:create ("0", g_sFontName, 25)
	_ccLabelSilverNumber:setPosition(ccp(ccSilverIcon:getPositionX()+ccSilverIcon:getContentSize().width+2, ccSilverIcon:getPositionY()))
	bg:addChild(_ccLabelSilverNumber)
	-- 出售按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(-403)
	local ccButtonSell = CCMenuItemImage:create("images/hero/btn_sell_n.png", "images/hero/btn_sell_h.png")
	ccButtonSell:registerScriptTapHandler(menu_item_tap_handler)
	menu:addChild(ccButtonSell, 0, _ksTagSell)
	menu:setPosition(ccp(500, 10))
	bg:addChild(menu)

	layer:addChild(bg)

	return layer
end

-- 中间内容列表显示区域 scrollview
-- 武将系统武将列表显示
local function createHeroSellTableView(layer)
	local cellBg = CCSprite:create("images/hero/attr_bg.png")
	local cellSize = cellBg:getContentSize()
	cellSize.width = cellSize.width * g_fScaleX
	cellSize.height = cellSize.height * g_fScaleX
	cellBg = nil

	_visiableCellNum = math.floor(_scrollview_height/(cellSize.height*g_fScaleX))

	local hids = HeroModel.getAllHeroesHid()
	-- 武将数值
	local heroesValue = {}
	require "script/utils/LuaUtil"
	require "db/DB_Heroes"
	require "script/model/hero/HeroModel"
	require "script/ui/hero/HeroPublicLua"
	require "script/ui/hero/HeroFightForce"

	for i=1, #hids do
		-- 过滤主角
		local isAvatar = HeroModel.isNecessaryHeroByHid(hids[i])
		-- 过滤在阵容的武将
		-- 从阵容信息中获取该武将是否已上阵
		-- 上阵武将，五星及以上武将，进阶过的武将，都不能卖
		local isFree = (not HeroPublicLua.isBusyWithHid(hids[i]))
		local hero
		local db_hero
		local bIsNotEvolved = true

		if isAvatar then
			isFree=false
		elseif isFree then 
			hero = HeroModel.getHeroByHid(hids[i])
			-- 过滤进化过的武将
			if tonumber(hero.evolve_level) > 0 then
				bIsNotEvolved = false
			end
			if bIsNotEvolved then
				db_hero = DB_Heroes.getDataById(hero.htid)
			end
		end
		--过滤神兵副本中的武将
		local isGodCopyHero = false
		if GodWeaponCopyData.isOnCopyFormationBy(hids[i]) then
			isGodCopyHero = true
		end
		local isSecondFriend = false
		if SecondFriendData.isInSecondFriendByHid(hids[i]) then
			isSecondFriend = true
		end
		-- 只能出售5星以下的武将
		if isFree and bIsNotEvolved and db_hero.star_lv < 5 and isGodCopyHero == false and isSecondFriend == false then
			local value = {}
			value.hid = hids[i]
			value.htid = hero.htid
			value.isBusy=false
			value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
			value.name = db_hero.name
            value.soul = tonumber(hero.soul)
            value.decompos_soul = db_hero.decompos_soul
            value.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
			value.level = tonumber(hero.level)
			value.evolve_level = tonumber(hero.evolve_level)
			value.star_lv = db_hero.star_lv
			value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
			value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
			value.quality_h = "images/hero/quality/highlighted.png"
			value.price = db_hero.recruit_gold
            value.awake_id = db_hero.awake_id
            value.grow_awake_id = db_hero.grow_awake_id
			
			value.menu_items = {}
			table.hcopy(_cell_menu_item_data, value.menu_items)
			for j=1, #value.menu_items do
				value.menu_items[j].tag = value.menu_items[j].tag + #heroesValue
			end
			value.type = "StarSell"
			value.checkIsSelected = false
			value.menu_tag = _ksTagTableViewMenu
			value.tag_bg = _ksTagTableViewBg
			value.hero_cb = fnHandlerOfHeadButtons
			value.hero_tag = _ksTagHeadIconBegin+i
			heroesValue[#heroesValue+1] = value
		end
	end
	-- 按价格进行排序
	require "script/ui/hero/HeroSort"
	_arrHeroesValue = HeroSort.fnSortOfHeroSell(heroesValue)

	require "script/ui/hero/HeroLayerCell"
	require "script/ui/hero/HeroFightSimple"
	local handler = LuaEventHandler:create(function(fn, pt, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
			local value = _arrHeroesValue[a1+1]
			if value.fight_value == nil or value.fight_value==0 then
				value.force_values =  HeroFightSimple.getAllForceValues(value)
				value.fight_value = value.force_values.fightForce
			end
			a2 = HeroLayerCell.createCell(value)
			a2:setScale(g_fScaleX)
			local actionSeq = CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(function ( ... )
				local visible = _arrHeroesValue[a1+1].checkIsSelected
				local bg = tolua.cast(a2:getChildByTag(_ksTagTableViewBg), "CCSprite")
				local checkbg = tolua.cast(bg:getChildByTag(10001), "CCSprite")
				local ccSpriteSelected = tolua.cast(checkbg:getChildByTag(10002), "CCSprite")
				ccSpriteSelected:setVisible(visible)			
			end)))
			a2:runAction(actionSeq)
			_arrHeroesValue[a1+1].ccObj = a2
			r = a2
		elseif (fn == "numberOfCells") then
			r = #heroesValue
		elseif (fn == "cellTouched") then
			fnHandlerOfCellTouched(a1:getIdx())
		end
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layer:getContentSize().width, _scrollview_height))
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setBounceable(true)

	-- local maxAnimateIndex = _visiableCellNum
	-- if (_visiableCellNum > #_arrHeroesValue) then
	-- 	maxAnimateIndex = #_arrHeroesValue
	-- end
	-- for i=1, maxAnimateIndex do
	-- 	local cell = tableView:cellAtIndex(maxAnimateIndex - i)
	-- 	if (cell) then
	-- 		local cellBg = tolua.cast(cell:getChildByTag(_ksTagTableViewBg), "CCSprite")
	-- 		cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
	-- 		cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * i ,ccp(0,0)))
	-- 	end
	-- end

	return tableView
end

-- 处理单元格被点击事件
fnHandlerOfCellTouched = function (pIndex)
	local nIndex = pIndex + 1

	local ccCellObj = tolua.cast(_arrHeroesValue[nIndex].ccObj:getChildByTag(_ksTagTableViewBg), "CCSprite")
	local ccSpriteCheckBox = tolua.cast(ccCellObj:getChildByTag(10001), "CCSprite")
	local ccSpriteSelected =  tolua.cast(ccSpriteCheckBox:getChildByTag(10002), "CCSprite")

	if (_arrHeroesValue[nIndex].checkIsSelected == false) then
		_arrHeroesValue[nIndex].checkIsSelected = true
		ccSpriteSelected:setVisible(true)
		_nHeroSellCount = _nHeroSellCount + 1
	else
		_arrHeroesValue[nIndex].checkIsSelected = false
		ccSpriteSelected:setVisible(false)
		_nHeroSellCount = _nHeroSellCount - 1
	end
	fnUpdateSelectionInfo()
end

-- 设置武将系统的菜单项
function createMenusWithBg(layer, menuBGFile, items_data)
	local menu_bg = CCSprite:create(menuBGFile)
	local top_y = layer:getContentSize().height
	local y_pos_menu_bg = top_y-(menu_bg:getContentSize().height-19)*g_fScaleX
	menu_bg:setPosition(ccp(0, y_pos_menu_bg))
	_scrollview_height = y_pos_menu_bg

	local menu = CCMenu:create()
	menu:setContentSize(menu_bg:getContentSize())
	menu:setPosition(ccp(0, 10))
	menu:setAnchorPoint(ccp(0, 0))
	local point = CCPointMake(0.5, 0)
	for i=1, #items_data do
		local item=CCMenuItemImage:create(items_data[i].normal, items_data[i].highlighted)
		item:setAnchorPoint(point)
		item:setPosition(ccp(items_data[i].pos_x, 0))
		item:registerScriptTapHandler(items_data[i].cb)
		items_data[i].ccObj = item
		menu:addChild(item, 0, items_data[i].tag)
	end
	menu_bg:addChild(menu)

	return menu_bg
end

-- 创建武将出售层
function createLayer()
	_nHeroSellCount = 0
	_onRunningLayer = CCLayer:create()
	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	BulletinLayer.getLayer():setVisible(true)
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local avatarLayerSize = MainScene.getAvatarLayerContentSize()
	MainScene.getAvatarLayerObj():setVisible(true)
	local layerSize = {}
	-- 层高等于设备总高减去“公告层”，“avatar层”，GetLocalizeStringBy("key_2785")高
	layerSize.height = g_winSize.height - (bulletinLayerSize.height+avatarLayerSize.height)*g_fScaleX
	layerSize.width = g_winSize.width
	_onRunningLayer:setContentSize(CCSizeMake(layerSize.width, layerSize.height))

	local ccSpriteBg = CCSprite:create("images/main/module_bg.png")
	ccSpriteBg:setScale(g_fBgScaleRatio)
	ccSpriteBg:setAnchorPoint(ccp(0.5, 0.5))
	ccSpriteBg:setPosition(ccp(layerSize.width/2, layerSize.height/2))
	_onRunningLayer:addChild(ccSpriteBg)

	-- 获得GetLocalizeStringBy("key_1762")尺寸
	local menu = createMenusWithBg(_onRunningLayer, "images/hero/menu_bg.png", _menu_item_data)
	menu:setScale(g_fScaleX)
	_onRunningLayer:addChild(menu)
	-- 隐藏主界面菜单栏显示
	MenuLayer.getObject():setVisible(false)
	_CCLayerBottom = createMenuBottomLayer()
	
	-- 12个像素偏移是因为下底框有12个像素的通明高度
	_scrollview_height = layerSize.height - (menu:getContentSize().height-19+_CCLayerBottom:getContentSize().height - 12)*g_fScaleX

	local tableview = createHeroSellTableView(_onRunningLayer)
	tableview:setPosition(ccp(0, (_CCLayerBottom:getContentSize().height-12)*g_fScaleX))
	_onRunningLayer:addChild(tableview, 0, _ksTagHeroTableView)
	-- 下底框
	_onRunningLayer:addChild(_CCLayerBottom)

	return _onRunningLayer
end

fnGetSellSilverNumber = function ()
	local nSilverNumber = 0
	for i = 1, #_arrHeroesValue do
		if _arrHeroesValue[i].checkIsSelected then
			nSilverNumber = nSilverNumber + tonumber(_arrHeroesValue[i].price)
		end
	end
	return nSilverNumber
end

-- 更新选择列表信息
fnUpdateSelectionInfo = function ()
	-- 更新已选择武将个数
	_ccLabelNumber:setString(_nHeroSellCount)
	-- 更新出售银币
	local nSilverNumber = fnGetSellSilverNumber()
	_ccLabelSilverNumber:setString(nSilverNumber)
end
-- 武将被删除后更新列表信息
fnUpdateTableView = function ()
	_onRunningLayer:removeChildByTag(_ksTagHeroTableView, true)
	local tableview = createHeroSellTableView(_onRunningLayer)
	tableview:setPosition(ccp(0, (_CCLayerBottom:getContentSize().height-12)*g_fScaleX))
	_onRunningLayer:addChild(tableview, 0, _ksTagHeroTableView)
end
fnUpdateTableViewCellSelectionStatus = function (star_lv)
	for i = 1, #_arrHeroesValue do
		if (_arrHeroesValue[i].star_lv == star_lv) then
			if (_arrHeroesValue[i].checkIsSelected == false) then
				_arrHeroesValue[i].checkIsSelected = true
				-- if _arrHeroesValue[i].ccObj then
				-- 	print(".........i: ", i, ", name: ", _arrHeroesValue[i].name, ", type(aa): ", tolua.type(_arrHeroesValue[i].ccObj))

				-- 	local test_bg = _arrHeroesValue[i].ccObj:getChildByTag(_ksTagTableViewBg)
				-- 	print(".........i: ", i, ", ccObj: ", _arrHeroesValue[i].ccObj, ", test_bg: ", test_bg, ", type(test_bg): ", tolua.type(test_bg))

				-- 	local bg = tolua.cast(_arrHeroesValue[i].ccObj:getChildByTag(_ksTagTableViewBg), "CCSprite")

				-- 	local checkbg = tolua.cast(bg:getChildByTag(10001), "CCSprite")
				-- 	local ccSpriteSelected = tolua.cast(checkbg:getChildByTag(10002), "CCSprite")
				-- 	ccSpriteSelected:setVisible(true)
				-- end
				_nHeroSellCount = _nHeroSellCount + 1
			end
		end
	end
	fnUpdateSelectionInfo()
end

-- 更新英雄列表勾选状态方法(在按星级出售选择之后)
fnUpdateTableViewAfterStarSell = function ()
	for i=1, #_star_level_data do
		if _star_level_data[i].isSelected then
			fnUpdateTableViewCellSelectionStatus(_star_level_data[i].number)
		end
		_star_level_data[i].isSelected = nil
	end
end
-- 武将头像被点击事件处理
fnHandlerOfHeadButtons = function (tag, obj)
	for i=1, #_arrHeroesValue do
		if tag == _arrHeroesValue[i].hero_tag then
			require "script/ui/main/MainScene"
			require "script/ui/hero/HeroInfoLayer"
			local tArgs = {}
			tArgs.sign = "HeroSellLayer"
			tArgs.fnCreate = HeroSellLayer.createLayer
			MainScene.changeLayer(HeroInfoLayer.createLayer(_arrHeroesValue[i], tArgs), "HeroInfoLayer")
		end
	end
end



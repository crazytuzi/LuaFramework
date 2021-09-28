-- FileName: UpgradeByStarLayer.lua 
-- Author: Li Cong 
-- Date: 14-3-5 
-- Purpose: function description of module 


module("UpgradeByStarLayer", package.seeall)
require "script/ui/huntSoul/HuntSoulData"
require "script/ui/huntSoul/UpgradeFightSoulLayer"

-- 按星级出售层tag
local _ksTagLayerStarSell = 5001
-- 星级出售tag
local _ksTagStarLevelSell = 6001
-- 星级出售面板关闭按钮tag
local _ksTagStarSellPanelCloseBtn = 7001
-- 星级出售面板“取消选择”按钮tag
local _ksTagStarSellPanelSelectAll = 7002
-- 星级出售面板“选择全部”按钮tag
local _ksTagStarSellPanelCancel = 7003
-- 星级出售面板“确定”按钮tag
local _ksTagStarSellPanelSure = 7004
-- 星级出售面板菜单tag
local _ksTagStarSellPanelMenu = 8001
-- 全部选择按钮
local _ccButtonSelectAll  = nil
-- 取消选择按钮
local _ccButtonCancel  = nil
-- 按星级出售菜单上的menu
local _ccMenuStarSell	= nil


-- 星级数据数组 1.2.3 4 星
local _star_level_data = {}

-- 按星级出售菜单项回调处理
local function fnHandlerOfMenuItemStarLevelSell(tag, item_obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- “关闭”按钮事件处理
	if tag==_ksTagStarSellPanelSure then
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
	-- 关闭按钮
	elseif tag==_ksTagStarSellPanelCloseBtn then
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:removeChildByTag(_ksTagLayerStarSell, true)
	else
		print("无操作。。")
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
function createLayerStar()
	local bgSize = CCSizeMake(524, 438)
	-- 满足条件加入选择四星
	local isNeed = HuntSoulData.getIsChooseFourStarSoul()
	if(isNeed)then
		_star_level_data = {
			{number=1, tag=_ksTagStarLevelSell+1, },
			{number=2, tag=_ksTagStarLevelSell+2, },
			{number=3, tag=_ksTagStarLevelSell+3, },
			{number=4, tag=_ksTagStarLevelSell+4, },
		}
		bgSize = CCSizeMake(524, 488)
	else
		_star_level_data = {
			{number=1, tag=_ksTagStarLevelSell+1, },
			{number=2, tag=_ksTagStarLevelSell+2, },
			{number=3, tag=_ksTagStarLevelSell+3, },
		}
	end

	local layer = CCLayerColor:create(ccc4(11,11,11,166))
	-- 背景九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	local ccStarSellBG = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	ccStarSellBG:setPreferredSize(bgSize)
	local bg_size = ccStarSellBG:getContentSize()
	ccStarSellBG:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	ccStarSellBG:setAnchorPoint(ccp(0.5, 0.5))
	-- 按星级出售标题背景
	local ccTitleBG = CCSprite:create("images/common/viewtitle1.png")
	ccTitleBG:setPosition(ccp(bg_size.width/2, bg_size.height-6))
	ccTitleBG:setAnchorPoint(ccp(0.5, 0.5))
	ccStarSellBG:addChild(ccTitleBG)
	-- 按星级出售标题文本
	local ccLabelTitle = CCLabelTTF:create (GetLocalizeStringBy("key_3150"), g_sFontName, 35, CCSizeMake(315, 61), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	ccLabelTitle:setPosition(ccp(ccTitleBG:getContentSize().width/2, (ccTitleBG:getContentSize().height-1)/2))
	ccLabelTitle:setAnchorPoint(ccp(0.5, 0.5))
	ccLabelTitle:setColor(ccc3(0xff, 0xf0, 0x49))
	ccTitleBG:addChild(ccLabelTitle)
	-- “请选择星级”文本显示
	local ccLabelTip = CCRenderLabel:create(GetLocalizeStringBy("key_3317"), g_sFontName, 30, 1, ccc3(0, 0, 0), type_stroke)
	ccLabelTip:setAnchorPoint(ccp(0.5, 0))
	ccLabelTip:setColor(ccc3(0xff, 0xed, 0x55))
	ccLabelTip:setPosition(bg_size.width/2,bg_size.height-80)
	ccStarSellBG:addChild(ccLabelTip)

	local menu = CCMenu:create()
	menu:setContentSize(bg_size)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(-454)
	-- 星级MenuItem
	local pos_y = 140
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
	_ccButtonSelectAll:setPosition(bg_size.width*0.3, 48)
	_ccButtonSelectAll:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(_ccButtonSelectAll, 0, _ksTagStarSellPanelSelectAll)
	-- 取消选择按钮
	_ccButtonCancel = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2982"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	_ccButtonCancel:setAnchorPoint(ccp(0.5, 0))
	_ccButtonCancel:setPosition(bg_size.width*0.3, 48)
	_ccButtonCancel:setVisible(false)
	_ccButtonCancel:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(_ccButtonCancel, 0, _ksTagStarSellPanelCancel)

-- 确定按钮
	local ccBtnSure = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2229"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))

	ccBtnSure:setAnchorPoint(ccp(0.5, 0))
	ccBtnSure:setPosition(bg_size.width*0.7, 48)
	ccBtnSure:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
	menu:addChild(ccBtnSure, 0, _ksTagStarSellPanelSure)

	_ccMenuStarSell = menu

	setAdaptNode(ccStarSellBG)
	layer:addChild(ccStarSellBG)
	layer:setTouchPriority(-451)
	layer:setTouchEnabled(true)
	layer:registerScriptTouchHandler(fnFilterTouchEvent,false,-450, true)

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, 1000, _ksTagLayerStarSell)
end

-- 更新列表勾选状态方法(在按星级选择之后)
fnUpdateTableViewAfterStarSell = function ()
	local t_List = {}
	for i=1, #_star_level_data do
		if _star_level_data[i].isSelected then
			fnUpdateTableViewCellSelectionStatus(_star_level_data[i].number,t_List)
		end
		_star_level_data[i].isSelected = nil
	end


	-- 设置选择列表
	local desItemData,maxLevel = UpgradeFightSoulLayer.getNeedUpgradeItemDataAndMaxLv()
	-- 清空选择战魂列表
	HuntSoulData.ClearChooseFSItemTable()
	for k,v in pairs(t_List) do
		-- 进行判断是否溢出
		-- 已经选择的战魂可以提供的等级
		if(desItemData and maxLevel)then
			local canUpLv,a,b = HuntSoulData.getCurLvAndCurExpAndNeedExp( desItemData.itemDesc.upgradeID, desItemData.item_id )
			if(canUpLv >= maxLevel)then
				break
			end
		end
		-- 添加到列表中
		HuntSoulData.addChooseFSItemId(v)
	end
	-- 更新tableView
	UpgradeFightSoulLayer.refreshTableView()
end

-- 打钩
fnUpdateTableViewCellSelectionStatus = function (star_lv,tab)
	print("star_lv:",star_lv)
	local curData = UpgradeFightSoulLayer.getFsoulData() or {}
	print("curData:")
	print_t(curData)
	for i = 1, #curData do
		print("quality",curData[i].itemDesc.quality,"star_lv",star_lv)
		if ( tonumber(curData[i].itemDesc.quality) == tonumber(star_lv)) then
			table.insert(tab,curData[i].item_id)
		end
	end
end









































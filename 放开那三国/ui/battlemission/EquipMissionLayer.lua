-- Filename: EquipMissionLayer.lua
-- Author: llp
-- Date: 2014-6-12
-- Purpose: 该文件用于: 炼化选择界面

module ("EquipMissionLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/ui/bag/EquipBagCell"
local typeCpy           = 0
local qualityCpy        = 0
local posCpy            = 0
local ttidCpy           = 0

local _okButtonCallBack = nil 		--确定按钮回调
local _selectedMaxCount = nil 		--选择最大上限
local _touchPriority    = nil
local _maskLayer		= nil
function init()
	typeCpy            = 0
	qualityCpy         = 0
	posCpy             = 0
	ttidCpy            = 0

	_ksTagSure         = 5001

	_ksTagChooseHero   = 1001
	_ksTagChooseItem   = 1002
	_ksTagChooseGood   = 1003
	_ksTagChooseCloth  = 1004
	_ksTagCheckBg      = 3001
	_ksTagTableViewBg  = 201

	_nSelectedCount    = 0
	_nItemCount        = 0

	--已选择武将数目栏
	_ccHeroCount       = nil
	ccLabelSelected    = nil
	_layerSize         = nil
	layer              = nil

	_menuHero          = nil
	_menuItem          = nil
	_menuGood          = nil

	_whereILocate      = nil
	_heroLayer         = nil
	_itemLayer         = nil
	_goodLayer         = nil
	_clothLayer        = nil

	tBottomSize        = nil
	topMenuBar         = nil
	bulletinLayerSize  = nil
	_tParentParam      = nil

	_arrSelectedHeroes = {}
	_arrSelectedItems  = {}
	_arrSelectedGoods  = {}
	_arrSelectedCloths = {}

	_arrSign           = nil
	_arrViewLocation   = nil

	_arrHeroesValue    = nil
	_arrItemValue      = nil

	_selectId          = false

	_itemId            = false

	_goodId            = false

	_clothId           = false
	_okButtonCallBack  = nil 		--确定按钮回调
	_touchPriority     = nil
	_selectedMaxCount  = nil
	_maskLayer		   = nil
end

function fnHandlerOfClothTouched(clothMenu,curBox)
	local isIn = curBox.isSelected
	if(isIn == true) then
		clothMenu:unselected()
		curBox.isSelected = false
		_nItemCount = _nItemCount-1
		_clothId = true
	else
		if tonumber(_nItemCount) == _selectedMaxCount then
			clothMenu:unselected()
			AnimationTip.showTip(GetLocalizeStringBy("key_3164"))
		else
			_clothId = true
			clothMenu:selected()
			curBox.isSelected = true
			_nItemCount = _nItemCount+1
		end
	end
	fnUpdateSelectionInfo(_nItemCount)
end

function fnHandlerOfItemTouched(itemMenu,curBox)
	local isIn = curBox.isSelected
	if(isIn == true) then
		itemMenu:unselected()
		curBox.isSelected = false
		_nItemCount = _nItemCount-1
		_itemId = true
	else
		if tonumber(_nItemCount) == _selectedMaxCount then
			itemMenu:unselected()
			AnimationTip.showTip(GetLocalizeStringBy("llp_36").._selectedMaxCount..GetLocalizeStringBy("llp_37"))
		else
			_itemId = true
			itemMenu:selected()
			curBox.isSelected = true
			_nItemCount = _nItemCount+1
		end
	end
	fnUpdateSelectionInfo(_nItemCount)
end

function checkedItemAction(tag, itemMenu)
	for k,v in pairs(_tParentParam.filtersItem) do
		if tonumber(v.gid) == tonumber(itemMenu:getTag()) then
			fnHandlerOfItemTouched(itemMenu,v)
		end
	end
end

--武将列表更新底栏
function fnUpdateSelectionInfo(num)
	_ccHeroCount:setString(tostring(num) .. "/" .. _selectedMaxCount)
end

--选中武将
function fnHandlerOfCellTouched(pIndex)
	local nIndex = #_arrHeroesValue - pIndex

	local ccCellObj = tolua.cast(_arrHeroesValue[nIndex].ccObj:getChildByTag(_ksTagTableViewBg), "CCSprite")
	local ccSpriteCheckBox = tolua.cast(ccCellObj:getChildByTag(10001), "CCSprite")
	local ccSpriteSelected =  tolua.cast(ccSpriteCheckBox:getChildByTag(10002), "CCSprite")

	if (_arrHeroesValue[nIndex].checkIsSelected == false) then
		print(GetLocalizeStringBy("key_2892"))
		print(_arrHeroesValue[nIndex].hid)
		print(_arrHeroesValue[nIndex].name)
		print("#####################################")

		if _nSelectedCount == _selectedMaxCount then
			AnimationTip.showTip(GetLocalizeStringBy("key_3027"))
		else
			_selectId = true
			_arrHeroesValue[nIndex].checkIsSelected = true
			ccSpriteSelected:setVisible(true)
			print(GetLocalizeStringBy("key_2051"),_nSelectedCount)
			_nSelectedCount = _nSelectedCount + 1
		end
	else
		_arrHeroesValue[nIndex].checkIsSelected = false
		ccSpriteSelected:setVisible(false)
		_nSelectedCount = _nSelectedCount - 1
		_selectId = true
	end
	fnUpdateSelectionInfo(_nSelectedCount)
end

function updateItemParentParam(a1,a2)
	_tParentParam.filtersItem[a1+1].ccObj = a2
end

function createChooseItemLayer()
	local nHeightOfBottom = (tBottomSize.height-12)*g_fScaleX
	local nHeightOfTitle = (topMenuBar:getContentSize().height-16)*g_fScaleX
	local _scrollview_height = g_winSize.height - bulletinLayerSize.height*g_fScaleX - nHeightOfBottom - nHeightOfTitle
	local cellHeight
	require "script/ui/battlemission/MissionEquipResolveCell"
	_itemLayer , cellHeight= MissionEquipResolveCell.createItemSellTableview(_tParentParam,layer:getContentSize().width,_scrollview_height)
	_itemLayer:setTouchPriority( _touchPriority - 10)

	--_tParentParam.filtersItem为createLayer传入参数的装备的过滤信息

	local firstPos = 1
	if _tParentParam.filtersItem ~= nil then
		firstPos = #_tParentParam.filtersItem
		for i = 1,#_tParentParam.filtersItem do
			if _tParentParam.filtersItem[i].isSelected == true then
				firstPos = i
				_nItemCount = _nItemCount+1
				_ccHeroCount:setString(_nItemCount .. "/" .. _selectedMaxCount)
			end
		end
	end

	_itemLayer:setPosition(0,nHeightOfBottom)
	_itemLayer:setContentOffset(ccp(0,_scrollview_height-(firstPos)*cellHeight))
	_whereILocate = "itemView"
	layer:addChild(_itemLayer)
end

--切换武将、装备和宝物选择
function fnHandlerOfButtons(tag, obj)
	--创建装备界面
	local i
	_nItemCount = 0
	if _tParentParam.filtersItem ~= nil then
		for i = 1, #_tParentParam.filtersItem do
			_tParentParam.filtersItem[i].isSelected = false
		end
	end
	createChooseItemLayer()
	ccLabelSelected:setString(GetLocalizeStringBy("key_1351"))
	_ccHeroCount:setString("0/" .. _selectedMaxCount)
	_whereILocate = "itemView"
end

function fnHandlerOfClose()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
 	-- require "script/ui/battlemission/MissionLayer"
	-- local missLayer = MissionLayer.createLayer( )
	-- MainScene.changeLayer(missLayer, "MissionLayer")

	_maskLayer:removeFromParentAndCleanup(true)
	_maskLayer = nil
end

function createTitleLayer(layerRect)
	local tArgs = {}

	--待选择的项目标题
	--tag值见全局变量
	tArgs[1] = {x=125, tag=_ksTagChooseItem, handler=fnHandlerOfButtons}

	--创建主菜单
	require "script/libs/LuaCCSprite"
	topMenuBar = LuaCCSprite.createTitleBarCpy(tArgs)
	topMenuBar:setAnchorPoint(ccp(0, 1))
	topMenuBar:setPosition(0, layerRect.height)
	topMenuBar:setScale(g_fScaleX)
	layer:addChild(topMenuBar)

	local tItems = {
		{normal="images/common/close_btn_n.png", highlighted="images/common/close_btn_h.png", pos_x=550, pos_y=20, cb=fnHandlerOfClose},
	}
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	topMenuBar:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	closeButton:setPosition(ccp(550, 20))
	closeButton:registerScriptTapHandler(fnHandlerOfClose)
	menu:addChild(closeButton)

	--获取分标签
	local topBottomMenu = tolua.cast(topMenuBar:getChildByTag(10001), "CCMenu")
	_menuItem = tolua.cast(topBottomMenu:getChildByTag(_ksTagChooseItem), "CCMenuItem")

	--对应选择不同的标题，创建不同的下拉列表界面
	--_arrViewLocation是createLayer中tParam.nowIn值
	createChooseItemLayer()
end

local function upCallBack(ret)
	-- body
	layer:removeFromParentAndCleanup(true)
	layer=nil
	require "script/ui/guild/GuildImpl"
    GuildImpl.showLayer()
end

function fnHandlerOfReturn(tag, item_obj)

	print("_nItemCount",_nItemCount)

	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/recycle/BreakDownLayer"
	local tArgs = {}
	tArgs.sign = _arrSign
	tArgs.nowSit = "goodList"

	if _nItemCount ~= 0 then
		local allGoodTable = {}
		for k,v in pairs(_tParentParam.filtersItem) do
			if(v.isSelected == true) then
				table.insert(allGoodTable, v)
			end
		end
		tArgs.selectedHeroes = allGoodTable
	else
		tArgs.selectedHeroes = {}
	end
	if(table.count(tArgs.selectedHeroes) < _selectedMaxCount) then
		AnimationTip.showTip(GetLocalizeStringBy("key_10002"))
		return
	end
	fnHandlerOfClose()
	_okButtonCallBack( tArgs.selectedHeroes )
end

function createBottomPanel()
	-- 背景
	local bg = CCSprite:create("images/common/sell_bottom.png")
	bg:setScale(g_fScaleX)

	ccLabelSelected = CCLabelTTF:create (GetLocalizeStringBy("key_1351"), g_sFontName, 25)


	-- 已选择武将(label)
	--ccLabelSelected = CCLabelTTF:create (GetLocalizeStringBy("key_1529"), g_sFontName, 25)
	ccLabelSelected:setAnchorPoint(ccp(1,0))
	ccLabelSelected:setPosition(ccp(bg:getContentSize().width/2, 26))
	bg:addChild(ccLabelSelected)

	-- 出售英雄个数背景(9宫格)
	local fullRect = CCRectMake(0, 0, 34, 32)
	local insetRect = CCRectMake(12, 12, 10, 6)
	local ccHeroNumberBG = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	ccHeroNumberBG:setPreferredSize(CCSizeMake(70, 36))
	ccHeroNumberBG:setAnchorPoint(ccp(1,0))
	ccHeroNumberBG:setPosition(ccp(ccLabelSelected:getContentSize().width+ccLabelSelected:getPositionX()-60, ccLabelSelected:getPositionY()))
	bg:addChild(ccHeroNumberBG)
	-- 已选择英雄个数
	_ccHeroCount = CCLabelTTF:create ("0/1", g_sFontName, 25, CCSizeMake(70, 36), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
	_ccHeroCount:setAnchorPoint(ccp(1,0))
	_ccHeroCount:setPosition(ccHeroNumberBG:getPositionX(), ccHeroNumberBG:getPositionY()+2)
	bg:addChild(_ccHeroCount)

	-- 确定按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(_touchPriority - 50)
	local cmiiSure = CCMenuItemImage:create("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png")
	--_cmiiSureButton = cmiiSure
	cmiiSure:registerScriptTapHandler(fnHandlerOfReturn)
	menu:addChild(cmiiSure, 0, _ksTagSure)
	menu:setPosition(ccp(504, 10))
	bg:addChild(menu)

	return bg
end

--过滤装备
function getFiltersForItem()
	local filt = {}
	local bagInfo = DataCache.getBagInfo()
	
	local bagArmInfo = {}
	for k,v in pairs(bagInfo.arm) do
		if (tonumber(v.itemDesc.type) == tonumber(typeCpy)) and (tonumber(v.itemDesc.quality) == tonumber(qualityCpy)) then
			table.insert(filt,v)
		end
		v.isSelected = false
		--v.ccObj = nil
	end
	return filt

end

function createLayer(type,quality,p_maxCount, p_okButtonCallback, p_touchPriority)
	init()

	typeCpy = type
	qualityCpy = quality
	posCpy = pos
	ttidCpy = ttid
	_selectedMaxCount = tonumber(p_maxCount) or 5
	_okButtonCallBack = p_okButtonCallback
	_touchPriority    = p_touchPriority
	local tArgsOfModule = {sign="BreakDownLayer"}

	-- tArgsOfModule.filters = getFiltersForSelection()
	tArgsOfModule.filtersItem = getFiltersForItem()
	-- tArgsOfModule.filtersCloth = getFiltersForCloth()

	--tArgsOfModule.nowIn表示目前选中的是哪个界面
	--同时修改本次选中的页面，用于下一次快速找到的NOWIN_TAG值

	if not table.isEmpty(_arrSelectedItems) then
		tArgsOfModule.nowIn = "itemList"

		for i = 1,#tArgsOfModule.filtersItem do
			for j = 1,#_arrSelectedItems do
				if tArgsOfModule.filtersItem[i].item_id == _arrSelectedItems[j].item_id then
					tArgsOfModule.filtersItem[i].isSelected = true
				end
			end
		end

		tArgsOfModule.selected = _arrSelectedItems
	end
	--判断目前在哪个选择界面
	_tParentParam = tArgsOfModule

	--_tParentParam.selected为选中的项目
	_arrSelectedItems = _tParentParam.selected

	_arrSign = _tParentParam.sign

	--用于判断在哪个界面，创建对应的选择列表
	_arrViewLocation = _tParentParam.nowIn

	print("HHYY")
	print_t(_tParentParam.filtersItem)
	layer = CCLayer:create()
	-- 加载模块背景图
	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	layer:addChild(bg)

	_layerSize = layer:getContentSize()

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MenuLayer"
	bulletinLayerSize = BulletinLayer.getLayerContentSize()
	MenuLayer.getObject():setVisible(false)

	--底层框
	local ccBottomPanel = createBottomPanel()
	layer:addChild(ccBottomPanel)

	local ccObjAvatar = MainScene.getAvatarLayerObj()
	ccObjAvatar:setVisible(false)

	local layerRect = {}
	layerRect.width = g_winSize.width
	layerRect.height = g_winSize.height - bulletinLayerSize.height*g_fScaleX
	layer:setContentSize(CCSizeMake(g_winSize.width, layerRect.height))

	tBottomSize = ccBottomPanel:getContentSize()

	--创建选择项目标题栏
	createTitleLayer(layerRect)
	require "script/utils/BaseUI"
	_maskLayer = BaseUI.createMaskLayer(_touchPriority, nil, nil, 0)
	_maskLayer:addChild(layer)
	return _maskLayer
end

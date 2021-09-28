-- Filename: GoodMissionLayer.lua
-- Author: llp
-- Date: 2014-6-12
-- Purpose: 该文件用于: 宝物选择界面

module ("GoodMissionLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/ui/bag/EquipBagCell"
local typeCpy = 0
local qualityCpy = 0

local _okButtonCallBack 		= nil 		--确定按钮回调
local _selectedMaxCount 		= nil 		--选择最大上限
local _touchPriority 			= nil
local _maskLayer		   		= nil

local _ksTagSure         = 5001
local _ksTagChooseHero   = 1001
local _ksTagChooseItem   = 1002
local _ksTagChooseGood   = 1003
local _ksTagChooseCloth  = 1004
local _ksTagCheckBg      = 3001
local _ksTagTableViewBg  = 201

function init()
	typeCpy            = 0
	qualityCpy         = 0

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
	_touchPriority	   = nil
	_selectedMaxCount  = nil
	_maskLayer		   = nil
end



function fnHandlerOfGoodTouched(goodMenu,curBox)
	local isIn = curBox.isSelected
	if(isIn == true) then
		goodMenu:unselected()
		curBox.isSelected = false
		_nItemCount = _nItemCount-1
		_goodId = true
	else
		if tonumber(_nItemCount) >= _selectedMaxCount then
			goodMenu:unselected()
			AnimationTip.showTip(string.format(GetLocalizeStringBy("lcy_10045"), _selectedMaxCount))
		else 
			_goodId = true
			goodMenu:selected()
			curBox.isSelected = true
			_nItemCount = _nItemCount+1
		end
	end
	fnUpdateSelectionInfo(_nItemCount)
end

function checkedGoodAction(tag,goodMenu)
	for k,v in pairs(_tParentParam.filtersGood) do
		if tonumber(v.gid) == tonumber(goodMenu:getTag()) then
			fnHandlerOfGoodTouched(goodMenu,v)
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
			AnimationTip.showTip(GetLocalizeStringBy("llp_36").._selectedMaxCount..GetLocalizeStringBy("llp_37"))
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

function updateGoodParentParam(a1,a2)
	_tParentParam.filtersGood[a1+1].ccObj = a2
end

function createChooseGoodLayer()
	print("hehehaha")
	local nHeightOfBottom = (tBottomSize.height-12)*g_fScaleX
	local nHeightOfTitle = (topMenuBar:getContentSize().height-16)*g_fScaleX
	local _scrollview_height = g_winSize.height - bulletinLayerSize.height*g_fScaleX - nHeightOfBottom - nHeightOfTitle
	local cellHeight
	require "script/ui/battlemission/MissionGoodResolveCell"
	_goodLayer ,cellHeight= MissionGoodResolveCell.createGoodSellTableview(_tParentParam,layer:getContentSize().width,_scrollview_height)

	local i
	local firstPos = 1
	--_tParentParam.filtersGood为符合筛选的宝物信息
	-- if _tParentParam.filtersGood ~= nil then
		firstPos = #_tParentParam.filtersGood
		for i = 1,#_tParentParam.filtersGood do
			if _tParentParam.filtersGood[i].isSelected == true then
				firstPos = i
				_nItemCount = _nItemCount+1
				_ccHeroCount:setString(_nItemCount .. "/" .. _selectedMaxCount)
			end
		end
	-- end

	_goodLayer:setPosition(0,nHeightOfBottom)
	_goodLayer:setContentOffset(ccp(0,_scrollview_height-(firstPos)*cellHeight))
	_goodLayer:setTouchPriority(_touchPriority - 10)
	--whereILocate表示目前显示的是哪个界面
	_whereILocate = "goodView"
	layer:addChild(_goodLayer)
end

--切换武将、装备和宝物选择
function fnHandlerOfButtons(tag, obj)

	--创建宝物界面
	
	local i
	_nItemCount = 0
	if _tParentParam.filtersGood ~= nil then
		for i = 1, #_tParentParam.filtersGood do
			_tParentParam.filtersGood[i].isSelected = false
		end
	end
	createChooseGoodLayer()
	ccLabelSelected:setString(GetLocalizeStringBy("key_1979"))
	_ccHeroCount:setString("0/5")
	_whereILocate = "goodView"
		
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

local function upCallBack(ret)
	-- body
	layer:removeFromParentAndCleanup(true)
	layer=nil
	require "script/ui/guild/GuildImpl"
    GuildImpl.showLayer()
end

function createTitleLayer(layerRect)
	local tArgs = {}

	--待选择的项目标题
	--tag值见全局变量
	tArgs[1] = {x=125, tag=_ksTagChooseItem, handler=fnHandlerOfButtons}
	tArgs[2] = {x=260, tag=_ksTagChooseGood, handler=fnHandlerOfButtons}

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
	local menu = LuaCC.createMenuWithItems(tItems)
	menu:setTouchPriority(_touchPriority - 10)
	menu:setPosition(ccp(0, 0))
	topMenuBar:addChild(menu)

	--获取分标签
	local topBottomMenu = tolua.cast(topMenuBar:getChildByTag(10001), "CCMenu")
	_menuGood = tolua.cast(topBottomMenu:getChildByTag(_ksTagChooseGood), "CCMenuItem")

	--对应选择不同的标题，创建不同的下拉列表界面
	--_arrViewLocation是createLayer中tParam.nowIn值
	createChooseGoodLayer()
end

function fnHandlerOfReturn(tag, item_obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/recycle/BreakDownLayer"
	local tArgs = {}
	tArgs.sign = _arrSign
	tArgs.nowSit = "goodList"
	
	if _nItemCount ~= 0 then
		local allGoodTable = {}
		for k,v in pairs(_tParentParam.filtersGood) do
			if(v.isSelected == true) then
				table.insert(allGoodTable, v)
			end
		end
		tArgs.selectedHeroes = allGoodTable
	else
		tArgs.selectedHeroes = {}
	end

	if(table.count(tArgs.selectedHeroes) < _selectedMaxCount) then
		AnimationTip.showTip(GetLocalizeStringBy("key_10003"))
		return
	end

	fnHandlerOfClose()
	_okButtonCallBack( tArgs.selectedHeroes )
end

function createBottomPanel()
	-- 背景
	local bg = CCSprite:create("images/common/sell_bottom.png")
	bg:setScale(g_fScaleX)

	ccLabelSelected = CCLabelTTF:create (GetLocalizeStringBy("key_1979"), g_sFontName, 25)

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
	_ccHeroCount = CCLabelTTF:create ("0/".. _selectedMaxCount, g_sFontName, 25, CCSizeMake(70, 36), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
	_ccHeroCount:setAnchorPoint(ccp(1,0))
	_ccHeroCount:setPosition(ccHeroNumberBG:getPositionX(), ccHeroNumberBG:getPositionY()+2)
	bg:addChild(_ccHeroCount)

	-- 确定按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(_touchPriority-50)
	local cmiiSure = CCMenuItemImage:create("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png")
	--_cmiiSureButton = cmiiSure
	cmiiSure:registerScriptTapHandler(fnHandlerOfReturn)
	menu:addChild(cmiiSure, 0, _ksTagSure)
	menu:setPosition(ccp(504, 10))
	bg:addChild(menu)

	return bg
end

function getFiltersForGood()
	local filt = {}
	local bagInfo = DataCache.getBagInfo()
	local bagGoodInfo = {}

	table.hcopy(bagInfo.treas,bagGoodInfo)
	for k,v in pairs(bagGoodInfo) do
		if (tonumber(v.itemDesc.type) == tonumber(typeCpy)) and (tonumber(v.itemDesc.quality) == tonumber(qualityCpy)) then
			table.insert(filt,v)
		end
		v.isSelected = false
	end

	return filt
end

function createLayer(p_type, p_quality, p_maxCount, p_okButtonCallback, p_touchPriority)
	init()
	typeCpy           = p_type
	qualityCpy        = p_quality
	_selectedMaxCount = tonumber(p_maxCount) or 5
	_okButtonCallBack = p_okButtonCallback
	_touchPriority    = p_touchPriority
	local tArgsOfModule = {sign="BreakDownLayer"}

	-- tArgsOfModule.filters = getFiltersForSelection()
	tArgsOfModule.filtersGood = getFiltersForGood()
	-- tArgsOfModule.filtersCloth = getFiltersForCloth()

	--tArgsOfModule.nowIn表示目前选中的是哪个界面
	--同时修改本次选中的页面，用于下一次快速找到的NOWIN_TAG值

	tArgsOfModule.nowIn = "goodList"
	for i = 1,#tArgsOfModule.filtersGood do
		for j = 1,#_arrSelectedGoods do
			if tArgsOfModule.filtersGood[i].item_id == _arrSelectedGoods[j].item_id then
				tArgsOfModule.filtersGood[i].isSelected = true
			end
		end
	end
	tArgsOfModule.selected = _arrSelectedGoods
	
	--判断目前在哪个选择界面
	_tParentParam = tArgsOfModule

	--_tParentParam.selected为选中的项目
	_arrSelectedGoods = _tParentParam.selected
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

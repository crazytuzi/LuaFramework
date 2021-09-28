-- Filename：	GodWeaponPreviewLayer.lua
-- Author：		Zhang zihang
-- Date：		2015-1-8
-- Purpose：		神兵录界面

module("GodWeaponPreviewLayer", package.seeall)

require "script/ui/godweapon/GodWeaponService"
require "script/ui/godweapon/GodWeaponData"
require "script/ui/item/ItemSprite"
require "script/ui/hero/HeroPublicLua"

local _touchPirority 		--触摸优先级
local _zOrder				--z轴
local _bgLayer 				--背景层
local _secBgSize 			--二级背景大小
local _generalMenuItem 		--通用神兵按钮
local _specialMenuItem 		--专属神兵按钮
local _lordMenuItem 		--特殊神兵
local _nowTag 				--当前tag值
local _collectInfo 			--收集到的神兵的信息
local _allShowInfo 			--所有要显示的神兵信息
local _curCellInfo 			--当前cellInfo
local _showTableView 		--展示的tableView

local kTagGeneral = 1000 	--通用神兵tag
local kTagSpecial = 2000 	--专属神兵tag
local kTagLord = 3000 		--特殊神兵tag

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_touchPirority = nil
	_zOrder = nil
	_bgLayer = nil
	_secBgSize = nil
	_generalMenuItem = nil
	_specialMenuItem = nil
	_lordMenuItem = nil
	_showTableView = nil
	_nowTag = kTagGeneral
	_collectInfo = {}
	_allShowInfo = {}
	_curCellInfo = {}
end

--[[
	@des 	:触摸点击函数
	@param  :点击类型
	@return :true
--]]
function onTouchesHandler(eventType)
	if (eventType == "began") then
	    return true
	end
end

--[[
	@des 	:事件注册函数
	@param  :事件
--]]
function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPirority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--==================== CallBack ====================
--[[
	@des 	:查看神兵信息回调
	@param  :神兵Tid
--]]
function checkCallBack(p_itemTid)
	require "script/ui/godweapon/GodWeaponInfoLayer"
	GodWeaponInfoLayer.showLayer(p_itemTid,nil,nil,nil,nil,nil,nil,_touchPirority - 7)
end

--[[
	@des 	:清除背景
--]]
function removeLayer()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:关闭回调
--]]
function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	removeLayer()
end

--[[
	@des 	:切换回调
	@param 	:tag
--]]
function changeCallBack(p_tag)
	--点就发亮
	selectMenu(p_tag)

	--如果点击当前的界面则没有反应
	if _nowTag == p_tag then
		return
	end

	if p_tag == kTagGeneral then
		unselectMenu(kTagSpecial)
		unselectMenu(kTagLord)
		_curCellInfo = _allShowInfo.common
	elseif p_tag == kTagSpecial then
		unselectMenu(kTagGeneral)
		unselectMenu(kTagLord)
		_curCellInfo = _allShowInfo.special
	else
		unselectMenu(kTagGeneral)
		unselectMenu(kTagSpecial)
		_curCellInfo = _allShowInfo.lord
	end

	_showTableView:reloadData()

	--设置当前tag
	setNowTag(p_tag)
end

--[[
	@des 	:不选择按钮
	@param 	:tag
--]]
function unselectMenu(p_tag)
	if p_tag == kTagGeneral then
		_generalMenuItem:unselected()
	elseif p_tag == kTagSpecial then
		_specialMenuItem:unselected()
	else
		_lordMenuItem:unselected()
	end
end

--[[
	@des 	:选择按钮
	@param 	:tag
--]]
function selectMenu(p_tag)
	if p_tag == kTagGeneral then
		_generalMenuItem:selected()
	elseif p_tag == kTagSpecial then
		_specialMenuItem:selected()
	else
		_lordMenuItem:selected()
	end
end

--[[
	@des 	:设置当前tag值
	@param 	:tag
--]]
function setNowTag(p_tag)
	_nowTag = p_tag
end

--==================== TableView ====================
--[[
	@des 	:创建物品的Sprite
	@param  :物品信息
	@return :创建好的Sprite
--]]
function createItemSprite(p_itemData)
	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local bgSize = CCSizeMake(150,190)
    local itemBgSprite = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect,insetRect)
    itemBgSprite:setContentSize(bgSize)
    local innerMenu = CCMenu:create()
	innerMenu:setAnchorPoint(ccp(0,0))
	innerMenu:setPosition(ccp(0,0))
	innerMenu:setTouchPriority(_touchPirority - 2)
	itemBgSprite:addChild(innerMenu)

    local itemId = p_itemData.id

    local itemSprite
    local itemColor
    local desColor
    
    if _collectInfo[tonumber(itemId)] ~= nil then
    	itemSprite = ItemSprite.getItemSpriteById(itemId,nil,nil,nil,_touchPirority - 2,nil,_touchPirority - 7)
    	itemColor = HeroPublicLua.getCCColorByStarLevel(p_itemData.quality)
    	desColor = ccc3(0x00,0xff,0x18)

    	local gainSprite = CCSprite:create("images/god_weapon/preview/gained.png")
    	gainSprite:setAnchorPoint(ccp(0.5,0.5))
    	gainSprite:setPosition(ccp(bgSize.width - 25,bgSize.height - 20))
    	itemBgSprite:addChild(gainSprite,2)
    	itemBgSprite:addChild(itemSprite,1)
    else
        local itemSprite_n = ItemSprite.getItemGraySpriteByItemId(itemId)
        local itemSprite_h = ItemSprite.getItemGraySpriteByItemId(itemId)
    	itemSprite = CCMenuItemSprite:create(itemSprite_n,itemSprite_h)
    	
    	itemSprite:registerScriptTapHandler(checkCallBack)
		innerMenu:addChild(itemSprite,1,tonumber(itemId))
    	itemColor = ccc3(0x64,0x64,0x64)
    	desColor = ccc3(0x64,0x64,0x64)
    end
	itemSprite:setAnchorPoint(ccp(0.5,1))
	itemSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 10))
	

	local nameLabel = CCRenderLabel:create(p_itemData.name,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	nameLabel:setColor(itemColor)
	nameLabel:setAnchorPoint(ccp(0.5,1))
	nameLabel:setPosition(ccp(bgSize.width*0.5,bgSize.height - 100))
	itemBgSprite:addChild(nameLabel)

	local atrrTable = string.split(p_itemData.Recordability,",")
	for i = 1,#atrrTable do
		local atrrSecTable = string.split(atrrTable[i],"|")
		local affixInfo,dealNum = ItemUtil.getAtrrNameAndNum(atrrSecTable[1],atrrSecTable[2])
		local showLabel = CCRenderLabel:create(affixInfo.displayName .. " +" .. dealNum,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
		showLabel:setColor(desColor)
		showLabel:setAnchorPoint(ccp(0.5,1))
		showLabel:setPosition(ccp(bgSize.width*0.5,bgSize.height - 130 - (i - 1)*25))
		itemBgSprite:addChild(showLabel)
	end



	-- local checkMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/purple01_n.png","images/common/btn/purple01_h.png",CCSizeMake(bgSize.width,65),GetLocalizeStringBy("zzh_1261"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	-- checkMenuItem:setAnchorPoint(ccp(0.5,1))
	-- checkMenuItem:setPosition(ccp(bgSize.width*0.5,0))
	-- checkMenuItem:registerScriptTapHandler(checkCallBack)
	-- innerMenu:addChild(checkMenuItem,1,tonumber(itemId))

    return itemBgSprite
end

--[[
	@des 	:创建预览的cell
	@param  :下标index
	@return :创建好的cell
--]]
function createShowWeaponCell(p_index)
	local prizeViewCell = CCTableViewCell:create()
	local posArrX = {100,280,460}
	for i = 1,3 do
		local curData = _curCellInfo[p_index*3 + i]
		if curData ~= nil then
			local itemSprite = createItemSprite(curData)
			itemSprite:setAnchorPoint(ccp(0.5,1))
			itemSprite:setPosition(ccp(posArrX[i],220))
			prizeViewCell:addChild(itemSprite)
		end
	end
	return prizeViewCell
end

--[[
	@des 	:创建tableView
	@return :创建好的tabelView
--]]
function createTableView()
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(_secBgSize.width, 230)
		elseif fn == "cellAtIndex" then
			a2 = createShowWeaponCell(math.ceil(#_curCellInfo/3) - a1 - 1)
			r = a2
		elseif fn == "numberOfCells" then
			r = math.ceil(#_curCellInfo/3)
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h,CCSizeMake(_secBgSize.width,_secBgSize.height) )
end

--==================== UI ====================
--[[
	@des 	:创建UI
--]]
function createUI()
	local bgSize = CCSizeMake(630,750)

	local bgSprite = CCScale9Sprite:create(CCRectMake(122,165,8,10),"images/god_weapon/preview/bg.png")
	bgSprite:setContentSize(bgSize)
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	_bgLayer:addChild(bgSprite)

	local titleSprite = CCSprite:create("images/god_weapon/preview/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,0))
	titleSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 40))
	bgSprite:addChild(titleSprite)

	_secBgSize = CCSizeMake(560,520)

	_secondBgSprite = CCScale9Sprite:create(CCRectMake(30,30,15,10),"images/god_weapon/preview/sec_bg.png")
	_secondBgSprite:setContentSize(_secBgSize)
	_secondBgSprite:setAnchorPoint(ccp(0.5,0))
	_secondBgSprite:setPosition(ccp(bgSize.width*0.5,75))
	bgSprite:addChild(_secondBgSprite)

	local desLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1249"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	desLabel:setColor(ccc3(0x00,0xff,0x18))
	desLabel:setAnchorPoint(ccp(0.5,0))
	desLabel:setPosition(ccp(bgSize.width*0.5,45))
	bgSprite:addChild(desLabel)

	local desLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1287"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	desLabel_2:setColor(ccc3(0x00,0xff,0x18))
	desLabel_2:setAnchorPoint(ccp(0.5,0))
	desLabel_2:setPosition(ccp(bgSize.width*0.5,15))
	bgSprite:addChild(desLabel_2)

	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPirority - 4)
	bgSprite:addChild(bgMenu)

	local returnMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	returnMenuItem:setAnchorPoint(ccp(1,0))
	returnMenuItem:setPosition(ccp(bgSize.width - 15,bgSize.height + 5))
	returnMenuItem:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(returnMenuItem)

	local twoMenuPosY = bgSize.height - 150
	local twoMenuGapX = 120

	_generalMenuItem = CCMenuItemImage:create("images/god_weapon/preview/general_n.png","images/god_weapon/preview/general_h.png")
	_generalMenuItem:setAnchorPoint(ccp(0.5,0))
	_generalMenuItem:setPosition(ccp(twoMenuGapX,twoMenuPosY))
	_generalMenuItem:registerScriptTapHandler(changeCallBack)
	bgMenu:addChild(_generalMenuItem,1,kTagGeneral)

	_specialMenuItem = CCMenuItemImage:create("images/god_weapon/preview/special_n.png","images/god_weapon/preview/special_h.png")
	_specialMenuItem:setAnchorPoint(ccp(0.5,0))
	_specialMenuItem:setPosition(ccp(bgSize.width*0.5,twoMenuPosY))
	_specialMenuItem:registerScriptTapHandler(changeCallBack)
	bgMenu:addChild(_specialMenuItem,1,kTagSpecial)

	_lordMenuItem = CCMenuItemImage:create("images/god_weapon/preview/lord_n.png","images/god_weapon/preview/lord_h.png")
	_lordMenuItem:setAnchorPoint(ccp(0.5,0))
	_lordMenuItem:setPosition(ccp(bgSize.width - twoMenuGapX,twoMenuPosY))
	_lordMenuItem:registerScriptTapHandler(changeCallBack)
	bgMenu:addChild(_lordMenuItem,1,kTagLord)	

	selectMenu(kTagGeneral)
	setNowTag(kTagGeneral)

	--所有要显示的神兵信息
	_allShowInfo = GodWeaponData.getDBBookInfo()
	--拥有的神兵
	_collectInfo = GodWeaponData.getCounterBookInfo()
	--初始显示为普通神兵
	_curCellInfo = _allShowInfo.common

	_showTableView = createTableView()
	_showTableView:setAnchorPoint(ccp(0,0))
	_showTableView:setPosition(ccp(0,0))
	_showTableView:setTouchPriority(_touchPirority - 3)
	_secondBgSprite:addChild(_showTableView)
end

--==================== Entrance ====================
--[[
	@des 	:入口函数
	@param  : $p_touchPriority      : 触摸优先级
	@param  : $p_zOrder 			: Z轴
--]]
function showLayer(p_touchPriority,p_zOrder)
	init()

	_touchPirority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    --创建UI
    GodWeaponService.getGodWeaponBook(createUI)
end
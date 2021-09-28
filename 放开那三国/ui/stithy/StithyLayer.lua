-- Filename：	StithyLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-9-5
-- Purpose：		铁匠入口

module ("StithyLayer", package.seeall)

require "script/ui/bag/EquipBagCell"
require "script/ui/bag/TreasBagCell"


require "script/ui/tip/AnimationTip"
require "script/ui/main/MainScene"
require "script/ui/item/ItemUtil"
require "script/utils/LuaUtil"

require "script/ui/bag/ItemCell"


local _bgLayer = nil
local _curButtonTag = 1001
local _curData = {}
local _myTableView = nil

local equipBtn = nil
local treasBtn = nil
local _curButton = nil

function init( )
	_bgLayer = nil
	_curButtonTag = 1001
	_curData = {}
	_myTableView = nil
	equipBtn = nil
	treasBtn = nil
	_curButton = nil
end


local function itemMenuAction(tag, itemBtn )
	itemBtn:selected()
	
	if(_curButton ~= itemBtn)then
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		handleData()
		createTableView()
	end
end 

--[[
	@desc   背包tableView的创建
	@para 	none
	@return void
--]]
function createTableView( ... )
	
	local cellBg = CCSprite:create("images/bag/item/item_cellbg.png")
	cellSize = cellBg:getContentSize()			--计算cell大小
	if(_myTableView)then
		_myTableView:removeFromParentAndCleanup(true)
		_myTableView = nil
	end

    local myScale = _bgLayer:getContentSize().width/cellBg:getContentSize().width/_bgLayer:getElementScale()
   
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			if(_curButton == equipBtn)then
	            a2 = EquipBagCell.createEquipCell(curData[a1 + 1], false, refreshMyTableView)
	        elseif(_curButton == treasBtn)then
	        	a2 = TreasBagCell.createTreasCell(curData[a1 + 1], false, refreshMyTableView)
	        end
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #curData
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width/_bgLayer:getElementScale(),_bgLayer:getContentSize().height*0.885/_bgLayer:getElementScale()))
    _myTableView:setAnchorPoint(ccp(0,0))
	_myTableView:setBounceable(true)
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(_myTableView)
end

-- 刷新Tableview
function refreshMyTableView()
	MainScene.setMainSceneViewsVisible(true, true, true)
	if(_myTableView)then
		local contentOffset = _myTableView:getContentOffset() 
		_myTableView:reloadData()
		_myTableView:setContentOffset(contentOffset) 
	end
end

-- 添加切换按钮
local function addCopyMenus()


	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--添加背景
	local btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 0))
	btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height*0.88))
	btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(btnFrameSp)

	local  menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	btnFrameSp:addChild(menu)
	
	-- 装备强化
	equipBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_3074"), 31, 28)
	equipBtn:setAnchorPoint(ccp(0, 0))
	equipBtn:setPosition(ccp(btnFrameSp:getContentSize().width*0.03, btnFrameSp:getContentSize().height*0.1))
	equipBtn:registerScriptTapHandler(itemMenuAction)
	equipBtn:selected()
	_curButton = equipBtn
	menu:addChild(equipBtn)

	-- 宝物强化
	treasBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_2307"), 31, 28)
	treasBtn:setAnchorPoint(ccp(0, 0))
	treasBtn:setPosition(ccp(btnFrameSp:getContentSize().width*0.3, btnFrameSp:getContentSize().height*0.1))
	treasBtn:registerScriptTapHandler(itemMenuAction)
	menu:addChild(treasBtn)
    
end 

-- 处理数据
function handleData( )
	if(_curButton == equipBtn)then
		curData = {}
		local herosEquips = ItemUtil.getEquipsOnFormation()
		local bagInfo = DataCache.getBagInfo()
		for k,v in pairs(bagInfo.arm) do
			table.insert(curData, v)
		end
		for k,v in pairs(herosEquips) do
			table.insert(curData, v)
		end
	elseif(_curButton == treasBtn)then
		local bagInfo = DataCache.getBagInfo()
		curData = {}
		for k,v in pairs(bagInfo.treas) do
			table.insert(curData, v)
		end
		local herosTreas = ItemUtil.getTreasOnFormation()
		for k,v in pairs(herosTreas) do
			table.insert(curData, v)
		end
	end
	
end

--
function create( )
	addCopyMenus()
	handleData()
	createTableView()
end

-- 创建
function createLayer()

	init()
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png")
	create()
	return _bgLayer
end 

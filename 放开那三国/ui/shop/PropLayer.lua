-- Filename：	PropLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-22
-- Purpose：		商店购买道具

module ("PropLayer", package.seeall)

require "script/ui/shop/PropCell"
require "script/ui/shop/ShopUtil"

local _bgLayer = nil
local myTableView = nil
local _allGoods = {}

local function init()
	_bgLayer = nil
	_allGoods = {}
	myTableView = nil
end

function createTableView( )
	local layerSize = _bgLayer:getContentSize()

	local cellSize = CCSizeMake(640, 210)			--计算cell大小

    local myScale = _bgLayer:getContentSize().width/cellSize.width
	
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = PropCell.createCell(_allGoods[a1+1])
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_allGoods
		elseif fn == "cellTouched" then
			print("cellTouched", a1:getIdx())

		elseif (fn == "scroll") then
			
		end
		return r
	end)
	myTableView = LuaTableView:createWithHandler(h, _bgLayer:getContentSize())
	myTableView:setBounceable(true)
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(myTableView)

end

function reloadDataFunc( )
	local offset = myTableView:getContentOffset()
	myTableView:reloadData()
	myTableView:setContentOffset(offset)
end

function createLayerBySize( layerSize )
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:setContentSize(layerSize)
	_allGoods = ShopUtil.getAllShopInfo()
	createTableView()

	return _bgLayer
end

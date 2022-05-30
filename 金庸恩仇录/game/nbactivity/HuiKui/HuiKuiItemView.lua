local data_item_item = require("data.data_item_item")
local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")

local HuiKuiItemView = class("JifenRewordItem", function()
	return CCTableViewCell:new()
end)

function HuiKuiItemView:getContentSize()
	return cc.size(620,200)
end

function HuiKuiItemView:refreshItem(param)
	
	self:removeAllChildren()
	
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	
	local node = CCBuilderReaderLoad("nbhuodong/chongzhihuikui_item.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0,0))
	self:addChild(node)
	
	
	local boardWidth = self._rootnode["listview"]:getContentSize().width
	local boardHeight = self._rootnode["listview"]:getContentSize().height
	
	
	-- 创建
	local function createFunc(index)
		local item = require("game.TanBao.JifenRewordItem").new()
		return item:create({
		id = index,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		itemData = self._data[index + 1],
		})
	end
	-- 刷新
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = self._data[index + 1],
		viewSize = CCSizeMake(boardWidth, boardHeight)
		})
	end
	local cellContentSize = require("game.TanBao.JifenRewordItem").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size        = CCSizeMake(boardWidth, boardHeight),
	createFunc  = createFunc,
	refreshFunc = refreshFunc,
	cellNum     = #self._data,
	cellSize    = cellContentSize,
	direction   = kCCScrollViewDirectionVertical
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode["listview"]:addChild(self.ListTable)
	self._rootnode["listview"]:setPositionY(self._rootnode["listview"]:getPositionY() + 5)
end

function HuiKuiItemView:create(param)
	self._data = {
	
	}
	local cellDatas = {}
	for i = 1,2 do
		local temp = {}
		temp.id = 1
		temp.num = 12
		temp.type = 7
		temp.iconType = ResMgr.getResType(7)
		temp.name = require("data.data_item_item")[1].name
		table.insert(cellDatas,temp)
	end
	self._data = cellDatas
	
	self:refreshItem(param)
	
	return self
end

function HuiKuiItemView:refresh(param)
	self:refreshItem(param)
end


return HuiKuiItemView
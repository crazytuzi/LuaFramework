--test

local BagTableView2 = class("BagTableView2", BaseLayer)


function BagTableView2:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagTableView")
    self.type = 0
end

function BagTableView2:initUI(ui)
	self.super.initUI(self,ui)

	self:initTableView()
end

function BagTableView2:setHomeLayer()
end


function BagTableView2:removeUI()
    self.tableView = nil
    self.createNewHoldGoodsCallback = nil
    self.holdGoodsNumberChangedCallback = nil
    self.deleteHoldGoodsCallback = nil
	self.super.removeUI(self)
end 


function BagTableView2:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function BagTableView2:refreshUI()
    self:refreshTableView()
end


function BagTableView2:initTableView()
    print("BagTableView2:initTableView()")
    local  tableView =  TFTableView:create()
    print("create tabview size " .. self.ui:getContentSize().width .. ' , ' .. self.ui:getContentSize().height)
    tableView:setTableViewSize(self.ui:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView = tableView
    self.tableView.logic = self
    self.ui:addChild(tableView)
end


function BagTableView2:setType(type)
    self.type = type
    self.selectId = nil
    self:refreshUI()
    self:selectDefault()
end


function BagTableView2:onSelectCell(data)
end


function BagTableView2:updateTableSource()

	local sortFunc = nil
	print("setType ==== ",self.type)
    if self.type == 1 then --道具
        self.itemlist = BagManager:getDaojuItemList()
        -- self.itemlist = BagManager:getItemByType({EnumGameItemType.Item,EnumGameItemType.Box,EnumGameItemType.Stuff,EnumGameItemType.Token})
        --sortFunc = sortProp
    elseif self.type == 2 then --武学
        self.itemlist = BagManager:getItemByType(EnumGameItemType.Book)
    elseif self.type == 3 then --侠魂
        self.itemlist = BagManager:getBagDisplaySoul()
        --sortFunc = sortSoul
    --changed by wuqi
    elseif self.type == 4 then
        self.itemlist = SkyBookManager:getAllUnEquippedBook()
        --sortFunc = sortSkyBookByPower
    elseif self.type == 5 then --碎片
        self.itemlist = BagManager:getItemByKind(EnumGameItemType.Piece,{1,2,3,4,5})
        --sortFunc = sortPiece
    elseif self.type == 6 then --碎片
        self.itemlist = BagManager:getItemByKind(EnumGameItemType.Piece,10)
        --sortFunc = sortPiece
    else                       --全部
        self.itemlist = BagManager:getItemByType(1)
        --sortFunc = sortAll
    end


    --self.itemlist:sort(sortFunc)
end


function BagTableView2:registerEvents()
    self.super.registerEvents(self)


    --table view 事件
    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, BagTableView2.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, BagTableView2.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, BagTableView2.numberOfCellsInTableView)

end


function BagTableView2:removeEvents()

    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.super.removeEvents(self)
end


function BagTableView2:dispose()
    self:disposeAllPlanes()
    self.super.dispose(self)
end


function BagTableView2:disposeAllPlanes()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        if panel then
            panel:dispose()
        end
    end
end


function BagTableView2:unselectedAllCellPanels()
	end


function BagTableView2:updateSelectCell()
end


function BagTableView2:selectDefault()
end


function BagTableView2:isItemHas(id)
end


function BagTableView2:refreshTableView()
    print("BagTableView2:refreshTableView()")
    local bEmpty = true

    self:updateTableSource()

    if self.itemlist == nil or self.itemlist:length() < 1 then
        self.ui:setVisible(false)
    else
        self.ui:setVisible(true)
        bEmpty = false
    end

    self.tableView:reloadData()
    if self.selectId == nil or self:isItemHas(self.selectId) == false then
        self:selectDefault()
    end
    self:updateSelectCell()
    if self.homeLayer then
        if self.homeLayer.img_empty then
            self.homeLayer.img_empty:setVisible(bEmpty)
        end
    end
end


function BagTableView2.cellSizeForTable(table, idx)
	return 110,429
end

local column = 4
local row = 5

function BagTableView2.tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
    local self = table.logic
    local viewType = self.type

    self.allPanels = self.allPanels or {}
    if nil == cell then
    	cell = TFTableViewCell:create()
    	for i = 1,column do
    		local bagItem_panel = nil
    		bagItem_panel = require('lua.logic.bag.BagCell'):new()
    		local size = bagItem_panel:getSize()
    		local x = size.width * (i - 1) + 10
    		if i > 1 then
    			x = x + (i-1)*15
    		end

    		bagItem_panel:setPosition(ccp(x,0))
    		bagItem_panel:setLogic(self)
    		cell:addChild(bagItem_panel)

    		cell.bagItem_panel = cell.bagItem_panel or {}
    		cell.bagItem_panel[i] = bagItem_panel
    		local newIndex = #self.allPanels + 1
    		self.allPanels[newIndex] = bagItem_panel
    	end
    end

    for i=1,column do
    	local tmpIndex = idx * column + i

    	if self.itemlist and tmpIndex <= self.itemlist:length() then
    		local _item = self.itemlist:objectAt(tmpIndex)
    		local _itemInfo = ItemData:objectByID(_item.id)
    		if _item and _itemInfo then
    			if self.type == 4 then
    				cell.bagItem_panel[i]:setData(_itemInfo.type, _item.instanceId)
    			else
    				cell.bagItem_panel[i]:setData(_itemInfo.type, _item.id)
    			end
    		else
    			cell.bagItem_panel[i]:setData(nil)
    		end
    	else
    		cell.bagItem_panel[i]:setData(nil)
    	end
    end

    return cell
end


function BagTableView2.numberOfCellsInTableView(table)
	local self = table.logic
    if self.itemlist and self.itemlist:length() > 0 then
        local num = math.ceil(self.itemlist:length()/column)
        if num < row then
            return row
        end

        return num
    end
    return row
end

--[[
    选中
]]
function BagTableView2:select(id)
end

--table cell 被选中时在对应的Cell中触发此回调函数
function BagTableView2:tableCellClick(cell)
    self:select(cell.id)
end

return BagTableView2
--[[
******礼包包含物品内容显示*******

	-- by david.dai
	-- 2015/4/27
]]

function GiftsContentsView:ctor(viewSize)
    print("GiftsContentsView:ctor ： ",viewSize)
    self.super.ctor(self)
    self.viewSize = viewSize
end

function GiftsContentsView:setId(id)
    self.id = id
    self.refreshTableView()
end

function GiftsContentsView:refreshUI()
    self:refreshTableView()
end

--初始化TableView
function GiftsContentsView:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.viewSize)
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView = tableView
    self.tableView.logic = self
    self:addChild(tableView)
end

--[[
    更新TableView显示的内容
]]
function GiftsContentsView:updateTableSource()
    local gift_pack = GiftPackData:objectByID(self.id)
    if gift_pack == nil then
        print("礼包表无此礼包 id== "..self.id)
        self.itemList = nil
        return
    end
    
    self.itemList = gift_pack:getGiftList()
end

function GiftsContentsView:registerEvents()
    self.super.registerEvents(self)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, GiftsContentsView.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, GiftsContentsView.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, GiftsContentsView.numberOfCellsInTableView)

end

function GiftsContentsView:removeEvents()
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    self.super.removeEvents(self)
end

--销毁方法
function GiftsContentsView:dispose()
    self:disposeAllPanels()
    self.super.dispose(self)
end

--销毁所有TableView的Cell中的Panel
function GiftsContentsView:disposeAllPanels()
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

function GiftsContentsView:refreshTableView()
    print("GiftsContentsView:refreshTableView ： ")
    self:updateTableSource()
    if self.itemlist == nil or self.itemlist:length() < 1 then
        self.ui:setVisible(false)
    else
        self.ui:setVisible(true)
    end
    self.tableView:reloadData()
end

function GiftsContentsView.cellSizeForTable(table,idx)
    return 64,310
end

column = 5
row = 1

function GiftsContentsView.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    if nil == cell then
        cell = TFTableViewCell:create()
        for i=1,column do
    	    local bagItem_panel = require('lua.logic.bag.GiftCell'):new()
	    	local size = bagItem_panel:getSize()
	    	local x = size.width*(i-1) + 10
	    	if i > 1 then
	    	    x = x + (i-1)*15
	    	end
	    	bagItem_panel:setPosition(ccp(0,x))
	    	bagItem_panel:setLogic(self)
	    	cell:addChild(bagItem_panel)
			
    	    cell.bagItem_panel = cell.bagItem_panel or {}
    	    cell.bagItem_panel[i] = bagItem_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = bagItem_panel
    	end
        
    end
    for i=1,column do
        if self.itemlist and (idx * column + i) <= self.itemlist:length() then
            local _item = self.itemlist:objectAt(idx * column + i)
            cell.bagItem_panel[i]:setData(_item.id)
        else
            cell.bagItem_panel[i]:setData(nil)
        end
    end

    return cell
end

function GiftsContentsView.numberOfCellsInTableView(table)
    return 1
end

--召唤侠士成功回调函数
function GiftsContentsView:summonPaladinSuccessCallback(unitInstance)
    self:refreshTableView()
    self:selectDefault()
end

return GiftsContentsView

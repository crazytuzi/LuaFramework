--[[
******天书购买列表页*******

    -- by Chikui Peng
    -- 2016/3/28
]]

local AdventureShopPage = class("AdventureShopPage", BaseLayer)
local columnNumber = 4
function AdventureShopPage:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.shop.GiftsShopPage")
end

function AdventureShopPage:initUI(ui)
	self.super.initUI(self,ui)

    --根节点
	self.panel_content          = TFDirector:getChildByPath(ui, 'panel_content')

	--右侧tableView
	self.panel_list       = TFDirector:getChildByPath(ui, 'panel_list')

    --构建tableView
    self.itemlist = {}
	self:initTableView()
end

function AdventureShopPage:removeUI()
    TFDirector:removeTimer(self.nTimerId);
    self.super.removeUI(self)
end

--初始化TableView
function AdventureShopPage:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    --tableView:setPosition(self.panel_list:getPosition())

    self.tableView = tableView
    self.tableView.logic = self
    self.panel_list:addChild(tableView)
end

function AdventureShopPage:registerEvents()
    self.super.registerEvents(self)

    --table view 事件
    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, AdventureShopPage.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, AdventureShopPage.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, AdventureShopPage.numberOfCellsInTableView)

    self.tableView:reloadData()
end

function AdventureShopPage:removeEvents()
    --TableView事件
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    
    self.super.removeEvents(self)
end

--销毁方法
function AdventureShopPage:dispose()
    self:disposeAllPanels()

    self.super.dispose(self)

    self.panel_content = nil
    self.tableView = nil
    self.panel_list = nil
end

--销毁所有TableView的Cell中的Panel
function AdventureShopPage:disposeAllPanels()
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

function AdventureShopPage:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function AdventureShopPage:refreshUI()
    self:refreshTableView()
end

function AdventureShopPage:refreshTableView()
    if self.tableView then
        self.tableView:reloadData()
    end
end

function AdventureShopPage.cellSizeForTable(table,idx)
    return 180,537
end

function AdventureShopPage.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    local startOffset = 10
    local columnSpace = 10
    self.allPanels = self.allPanels or {}
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,columnNumber do
    	    local bagItem_panel = require('lua.logic.mall.AdventureItemCell'):new()
	    	local size = bagItem_panel:getSize()
	    	local x = size.width*(i-1)
	    	if i > 1 then
	    	    x = x + (i-1)*columnSpace
	    	end
            x = x + startOffset
	    	bagItem_panel:setPosition(ccp(x,0))
	    	bagItem_panel:setLogic(self)
	    	cell:addChild(bagItem_panel)
			
    	    cell.bagItem_panel = cell.bagItem_panel or {}
    	    cell.bagItem_panel[i] = bagItem_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = bagItem_panel
    	end
        
    end
    for i=1,columnNumber do
        if (idx * columnNumber + i) <= #self.itemlist then
            local _item = self.itemlist[idx * columnNumber + i]
            cell.bagItem_panel[i]:setVisible(true)
            cell.bagItem_panel[i]:setData(self.type,_item)
        else
            cell.bagItem_panel[i]:setVisible(false)
        end
    end

    return cell
end

function AdventureShopPage.numberOfCellsInTableView(table)
    local self = table.logic
    local num = math.ceil(#self.itemlist/columnNumber)
    return num
end

--table cell 被选中时在对应的Cell中触发此回调函数
function AdventureShopPage:tableCellClick(cell)

end

function AdventureShopPage:setData(type,data)
    self.type = type
    self.itemlist = data or {}
    self.tableView:reloadData()
    self.tableView:setScrollToBegin()
end

return AdventureShopPage

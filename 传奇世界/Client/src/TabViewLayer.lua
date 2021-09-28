local TabViewLayer = class("TabViewLayer", function() return cc.Layer:create() end)

function TabViewLayer:ctor()

end

function TabViewLayer:scrollViewDidScroll(view)

end

function TabViewLayer:scrollViewDidZoom(view)

end

function TabViewLayer:tableCellTouched(table,cell)

end
-- function TabViewLayer:tableCellLongTouched(table,cell)
-- 	print("tableCellLongTouched")
-- end
function TabViewLayer:cellSizeForTable(table,idx) 
    return 60,60
end

function TabViewLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    return cell
end

function TabViewLayer:numberOfCellsInTableView(table)
   return 25
end

function TabViewLayer:tableCellHighlight(table,cell)

end

function TabViewLayer:tableCellUnhighlight(table,cell)

end

function TabViewLayer:createTableView(parent,size,pos,t_type,sliderFile)

	if not self.m_tabView then
	    size = size or cc.size(0,0)
	    local tableView = cc.TableView:create(size)
	    if not t_type then
	    	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	    else 
	    	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	    	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	    end
	    tableView:setPosition(pos)
	    tableView:setDelegate()

        if sliderFile then
            sliderFile = "res/common/slider.png"
            tableView:addSlider(sliderFile)
        end
        
	    if parent then
	    	parent:addChild(tableView)
	    end

	    --registerScriptHandler functions must be before the reloadData funtion
	    tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
	    tableView:registerScriptHandler(function(view) self:scrollViewDidScroll(view) end,cc.SCROLLVIEW_SCRIPT_SCROLL)
	    tableView:registerScriptHandler(function(view) self:scrollViewDidZoom(view) end,cc.SCROLLVIEW_SCRIPT_ZOOM)
	    tableView:registerScriptHandler(function(table,cell) self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
	    --tableView:registerScriptHandler(function(table,cell) self:tableCellLongTouched(table,cell) end,cc.TABLECELL_LONGTOUCHED)
	    tableView:registerScriptHandler(function(table,cell) self:tableCellHighlight(table,cell) end,cc.TABLECELL_HIGH_LIGHT)
	    tableView:registerScriptHandler(function(table,cell) self:tableCellUnhighlight(table,cell) end,cc.TABLECELL_UNHIGH_LIGHT)
	    
	    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end ,cc.TABLECELL_SIZE_FOR_INDEX)
	    tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end ,cc.TABLECELL_SIZE_AT_INDEX)
	    tableView:reloadData()
	    self.m_tabView = tableView
	end
end
function TabViewLayer:getTableView()
	if not self.m_tabView then
		self:createTableView()
	end
	return self.m_tabView
end

return TabViewLayer


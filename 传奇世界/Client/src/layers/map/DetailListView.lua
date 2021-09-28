local DetailListView = class("RichTextView", require ("src/TabViewLayer"))

local DetailListViewType = {}
DetailListViewType.NpcType = 1
DetailListViewType.MonsterType = 2

function DetailListView:ctor(parent, size, pos, type, tab)
	if parent == nil then
		log("DetailListView param error")
		return
	end
	log("#tab="..#tab)
	self.data = {}
	self.cellWith = cellWith
	self.cellHeight = cellHeight
	self.type = type
	self.dataTab = tab

	self:createTableView(self, size, pos, true)
	parent:addChild(self)
end

function DetailListView:tableCellTouched(table, cell)
	log("DetailListView:tableCellTouched")
	log("self.type="..self.type)
	local x, y = cell:getPosition()
	if self.selLab then
		removeFromParent(self.selLab)
		self.selLab = nil
	end
	if self.selectedRect then
		removeFromParent(self.selectedRect)
		self.selectedRect = nil
	end
	self.selectedRect = createScale9Sprite(table, "res/common/scalable/item_sel.png", cc.p(0, 0), cc.size(274, 52), cc.p(0, 0))
	self.selectedRect:setPosition(cc.p(x, y))
	self.select = cell:getIdx()
	self.selLab = createLabel(table, self.dataTab[self.select+1].name, cc.p(141, 28), cc.p(0.5, 0.5), 22, true, 5,nil, MColor.lable_yellow)
	self.selLab:setPosition(cc.p(x+141,y+28))
	if self.touched then
		self:getParent():getParent():goToSomeOne(self.type, cell:getIdx()+1)
	end
end


function DetailListView:cellSizeForTable(table, idx)
    --return cellHeight, cellWidth
    return 55, 274
end

function DetailListView:tableCellAtIndex(table, idx)
	--log("DetailListView:tableCellAtIndex idx:"..idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()   
    else
	  	--cell = cc.TableViewCell:new()   
	  	cell:removeAllChildren()      	      
    end
    -- local cellBgSpr = createSprite(cell, "res/mapui/23.png", cc.p(0, 0), cc.p(0, 0))
    local cellBgSpr = createScale9Sprite(cell,"res/common/scalable/item.png",cc.p(0,0),cc.size(274,52),cc.p(0,0))
    createLabel(cellBgSpr, self.dataTab[idx+1].name, cc.p(141, 28), cc.p(0.5, 0.5), 22, true, 5, nil, MColor.lable_black)

    return cell
end

function DetailListView:numberOfCellsInTableView(table)
	--log("#self.dataTab"..#self.dataTab)
   	return #self.dataTab
end

function DetailListView:reloadData()
	self:getTableView():reloadData()
end

return DetailListView
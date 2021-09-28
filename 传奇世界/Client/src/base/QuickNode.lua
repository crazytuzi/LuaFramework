local QuickNode = class("QuickNode", require("src/LeftSelectNode") )

function QuickNode:ctor(parent,q_btn,closeFunc)
	local color_layer = cc.LayerColor:create(cc.c4b(14, 9, 0, 110))
	color_layer:setPosition(cc.p(-g_scrSize.width+87,0))
	self:addChild(color_layer)
	color_layer:setVisible(false)
	local func = function()
		color_layer:setVisible(true)
	end
	self.closeFunc = closeFunc
	performWithDelay(self,func,0.1)
	local bg = createSprite(self, "res/mainui/quickbtns/bg.png", cc.p(0, 0), cc.p(0, 0.0))
	local bg_size = bg:getContentSize()
	local callback = function()
		if G_MAINSCENE then
			if self.quick_btn then
				self.quick_btn:setPosition(cc.p(480+g_scrSize.width/2,300))
			end
			G_MAINSCENE.quick_node = nil
			performWithDelay(self, function() removeFromParent(self) end, 0.0)
		end
	end
	local spany = 0
	if g_scrSize.height > 640 then
		spany = (g_scrSize.height - 640)/2
	end 
	local quick_btn = createTouchItem(self, "res/mainui/quickbtns/quick.png", cc.p(0, 300+spany), callback)
	quick_btn:setAnchorPoint(1.0,0.5)
	bg:setScaleY(g_scrSize.height/bg_size.height)
	--createScale9Sprite(self, "res/common/scalable/2.png", cc.p(0,0),cc.size(100,520),cc.p(0.0,0.5))
	self.selectIdx = 0
	self.quick_btn = q_btn
	self.normal_img = {}
	self.iten_num = 0
	self.items = {}
	if G_MAINSCENE then
		if G_MAINSCENE.leftBottomBtn then
			for k,v in ipairs(G_MAINSCENE.leftBottomBtn)do 
				if v.node:isVisible() then
					self.iten_num = self.iten_num + 1
					self.items[self.iten_num] = k-1
				end
			end
		end
		if G_MAINSCENE.rightBottomBtn then
			for k,v in ipairs(G_MAINSCENE.rightBottomBtn)do 
				if v.node:isVisible() then
					self.iten_num = self.iten_num + 1
					self.items[self.iten_num] = 6+k
				end
			end
		end
	end

	self:createTableView(self, cc.size(100,g_scrSize.height), cc.p(0, 0 ), true)
	if parent then
		parent:addChild(self,300)
	end
	SwallowTouches(self)
end

function QuickNode:tableCellTouched(table,cell)
	AudioEnginer.playTouchPointEffect()
	local index = cell:getIdx() + 1
	if self.selectIdx == index then
		return 
	end
	if G_MAINSCENE then
		if self.quick_btn then
			self.quick_btn:setPosition(cc.p(480+g_scrSize.width/2,300))
		end
		G_MAINSCENE.quick_node = nil
		if self.closeFunc  then self.closeFunc() end
		G_MAINSCENE.bottomItemTouched(G_MAINSCENE,self.items[index])
		performWithDelay(self, function() removeFromParent(self) end, 0.0)
	end
	self.selectIdx = index
end

function QuickNode:cellSizeForTable(table,idx) 
    return 100, 100
end

function QuickNode:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()   
	else
		cell:removeAllChildren()
	end
	--createSprite(cell, self.normal_img[idx+1], cc.p(0, 0), cc.p(0, 0))
	createSprite(cell, "res/mainui/quickbtns/"..(self.items[idx+1])..".png", cc.p(0, 0), cc.p(0, 0))
	createSprite(cell, "res/mainui/quickbtns/line.png", cc.p(5,0), cc.p(0, 0))
    return cell
end

function QuickNode:numberOfCellsInTableView(table)
   return self.iten_num
end

function QuickNode:createTableView(parent,size,pos,t_type)
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
	    if parent then
	    	parent:addChild(tableView)
	    end
	    tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
	    tableView:registerScriptHandler(function(table,cell) self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)    
	    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end ,cc.TABLECELL_SIZE_FOR_INDEX)
	    tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end ,cc.TABLECELL_SIZE_AT_INDEX)
	    tableView:reloadData()
	    self.m_tabView = tableView
	end
end

return QuickNode
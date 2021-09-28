local TabViewNode = class("TabViewNode", function() return cc.Node:create() end)

function TabViewNode:ctor(parent, leftBtns, size, pos, callback , imgs , isHideArrow ,chooseBtn ,btnSize,canChooseNum,tipForNoChoose )
	self.parent =parent
	self.leftBtns = leftBtns
	self.callBackFunc = callback
	self.selectIdx = chooseBtn or 0
	self.btnSize = btnSize
	self.normal_img = "res/component/button/40.png"
	self.select_img = "res/component/button/40_sel.png"
	self.canChooseNum = canChooseNum or #self.leftBtns  --可以选择到的第几个按钮 后面按钮变灰
	self.tipForNoChoose = tipForNoChoose   --点击变灰按钮时的tip
	local msize = size or cc.size(210, 530)
	if msize.width < 200 then
		self.normal_img = "res/component/button/43.png"
		self.select_img = "res/component/button/43_sel.png"
	end
	if imgs then
		self.normal_img = imgs.def
		self.select_img = imgs.sel
	end
	self.isHideArrow = isHideArrow
	self:createTableView(self, msize, pos or cc.p(20, 20), true)
	if parent then
		parent:addChild(self)
	end
end

function TabViewNode:tableCellTouched(table,cell)
	local index = cell:getIdx()
	if self.selectIdx == index or index+1 > self.canChooseNum then
		if self.tipForNoChoose and index+1 > self.canChooseNum then
			TIPS({str = self.tipForNoChoose, type = 1})
		end
		return 
	else
		AudioEnginer.playTouchPointEffect()
		local old_cell = table:cellAtIndex(self.selectIdx)
		if old_cell then 
			local button = tolua.cast(old_cell:getChildByTag(10),"cc.Sprite")
			if button then
				button:setTexture(self.normal_img)
				if button:getChildByTag(20) then
					button:removeChildByTag(20)
				end
			end
		end
		local button = tolua.cast(cell:getChildByTag(10),"cc.Sprite")--cell:getChildByTag(10)
		if button then
			button:setTexture(self.select_img)
			local texture = 
			button:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0)))
			local select_allow =  button:getChildByTag(20)
			if select_allow then
				select_allow:setPosition(cc.p(button:getContentSize().width, button:getContentSize().height/2))
			else
				if not self.isHideArrow then
					local arrow = LoginUtils.createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
					arrow:setOpacity(0)
					arrow:runAction(cc.FadeIn:create(0.5))
					arrow:setTag(20)
				end
			end
		end
	end

	self.selectIdx = index

	if self.callBackFunc then
		self.callBackFunc(self.selectIdx+1)
	end
end

function TabViewNode:cellSizeForTable(table,idx) 
	if self.btnSize then
		return self.btnSize.width,self.btnSize.height
	else
    	return 70, 200
    end
end

function TabViewNode:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()   
	else
		cell:removeAllChildren()
	end
	--local button = LoginUtils.createSprite(cell, self.normal_img, cc.p(0, 0), cc.p(0, 0))
	local button = GraySprite:create(self.normal_img)
	button:setPosition(cc.p(0,0))
	button:setAnchorPoint(cc.p(0,0))
	cell:addChild(button)
	local buttonSize = button:getContentSize()
	-- self.btnRed[idx+1] = createSprite(button,"res/component/flag/red.png",cc.p(buttonSize.width-5,buttonSize.height-15))
	-- self.btnRed[idx+1]:setVisible(false)
	if self.parent then
		local p = self.parent
		if p.haveAwards then
			for k,v in pairs(p.haveAwards) do
				if k == idx+1 and v then
					createSprite(button,"res/component/flag/red.png",cc.p(buttonSize.width-5,buttonSize.height-15))
				end
			end
		end
	end
	if idx + 1 > self.canChooseNum then
		button:addColorGray()
	end
	if button then
		button:setTag(10)
		if idx == self.selectIdx then
			button:setTexture(self.select_img)
			if not self.isHideArrow then
				local arrow = LoginUtils.createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
				arrow:setTag(20)
			end
		end
		if self.leftBtns[idx+1] then
			LoginUtils.createLabel(button, self.leftBtns[idx+1], LoginUtils.getCenterPos(button),cc.p(0.5, 0.5), 24, true, nil, nil )
		end
	end
    return cell
end

function TabViewNode:numberOfCellsInTableView(table)
   return #self.leftBtns
end

function TabViewNode:createTableView(parent,size,pos,t_type)
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

function TabViewNode:getTableView()
	if not self.m_tabView then
		self:createTableView()
	end
	return self.m_tabView
end

return TabViewNode


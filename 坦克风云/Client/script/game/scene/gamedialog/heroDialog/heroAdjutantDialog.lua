heroAdjutantDialog = commonDialog:new()

function heroAdjutantDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
	    spriteController:addPlist("public/datebaseShow.plist")
    end)
    return nc
end

function heroAdjutantDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function heroAdjutantDialog:initTableView()
    self.heroList1 = {}
    self.heroList2 = {}
    local heroList = heroVoApi:getHeroList()
    for k, v in pairs(heroList) do
        if heroAdjutantVoApi:isCanEquipAdjutant(v) then
            table.insert(self.heroList1, v)
        else
            table.insert(self.heroList2, v)
        end
    end
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - 110))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 90)
    self.bgLayer:addChild(tableViewBg)
    
    self.list1Size = SizeOfTable(self.heroList1)
    self.list2Size = SizeOfTable(self.heroList2)
    self.cellNum = self.list1Size + (self.list2Size > 0 and (1 + self.list2Size) or 0)
    self.tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tv:setPosition(ccp(3, 3))
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(self.tv)

    self.refreshListener = function(event, data)
    	if data == nil then
    		return
    	end
    	self:setAdjutantUI(self.selectedCell, data.hid)
	end
    eventDispatcher:addEventListener("heroAdjutant.list.refresh", self.refreshListener)
end

function heroAdjutantDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, (idx + 1 == self.list1Size + 1) and 60 or 130)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellW, cellH = self.tvSize.width, (idx + 1 == self.list1Size + 1) and 60 or 130
        cell:setContentSize(CCSizeMake(cellW, cellH))
        local fontSize = 22
        if G_isAsia() == false then
            fontSize = 16
        end
        
        local index = idx + 1
        if index == self.list1Size + 1 then
            local titleW = cellW - 50
            if G_getCurChoseLanguage()=="en" then
                titleW = cellW - 180
            end
            local titleBg, titleLb, titleLbHeight = G_createNewTitle({getlocal("heroAdjutant_notAdjTips"), fontSize, G_ColorYellowPro}, CCSizeMake(titleW, 0), nil, true, "Helvetica-bold")
            titleBg:setPosition(cellW / 2, (cellH - titleLbHeight) / 2)
            cell:addChild(titleBg)
        else
            local data = self.heroList1[index]
            if data == nil then
                data = self.heroList2[index - self.list1Size - 1]
            end
            if data == nil then
                do return cell end
            end
            
            local heroIcon = heroVoApi:getHeroIcon(data.hid, data.productOrder,nil,nil,nil,nil,nil,{showAjt=false})
            heroIcon:setAnchorPoint(ccp(0.5, 0.5))
            heroIcon:setScale(0.6)
            heroIcon:setPosition(25 + heroIcon:getContentSize().width * heroIcon:getScale() / 2, cellH / 2 + 5)
            cell:addChild(heroIcon)
            
            local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            titleBg:setContentSize(CCSizeMake(cellW - heroIcon:getContentSize().width * heroIcon:getScale() - 130, titleBg:getContentSize().height))
            titleBg:setAnchorPoint(ccp(0, 1))
            titleBg:setPosition(heroIcon:getPositionX() + heroIcon:getContentSize().width * heroIcon:getScale() / 2, cellH - 15)
            titleBg:setTag(10)
            cell:addChild(titleBg)
            local heroName = getlocal(heroListCfg[data.hid].heroName)
            if heroVoApi:isInQueueByHid(data.hid) then
                heroName = heroName .. getlocal("designate")
            end
            heroName = heroName .. (G_LV() .. data.level)
            local nameLb = GetTTFLabel(heroName, fontSize, true)
            nameLb:setAnchorPoint(ccp(0, 0.5))
            nameLb:setPosition(15, titleBg:getContentSize().height / 2)
            nameLb:setColor(heroVoApi:getHeroColor(data.productOrder))
            titleBg:addChild(nameLb)
            
            if index <= self.list1Size then
            	local clickSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()
                    if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        heroAdjutantVoApi:showAdjutantInfoDialog(self.layerNum + 1, data)
                        self.selectedCell = cell    
                    end
                end)
                clickSp:setContentSize(CCSizeMake(cellW, cellH))
                clickSp:setPosition(cellW / 2, cellH / 2)
                clickSp:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
                clickSp:setOpacity(0)
                cell:addChild(clickSp)

            	self:setAdjutantUI(cell, data.hid)
            end
            
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
            lineSp:setContentSize(CCSizeMake((cellW - 10), 4))
            lineSp:ignoreAnchorPointForPosition(false)
            lineSp:setAnchorPoint(ccp(0.5, 0))
            lineSp:setPosition(cellW / 2, 0)
            cell:addChild(lineSp)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function heroAdjutantDialog:setAdjutantUI(cell, hid)
	local cell = tolua.cast(cell, "CCTableViewCell")
	if cell then
		local titleBg = tolua.cast(cell:getChildByTag(10), "CCSprite")
		local cellW = cell:getContentSize().width
		local cellH = cell:getContentSize().height
		local adjTotalLv = heroAdjutantVoApi:getAdjutantTotalLevel(hid)
		local adjData = heroAdjutantVoApi:getAdjutant(hid)
	    local propIconFirstPosX
	    local propIconScapeW = 3
	    for i = 1, 4 do
	    	local propIconTag = 100 + i
	    	local adjutantIconTag = 200 + i
	    	local oldPropIcon = tolua.cast(cell:getChildByTag(propIconTag), "CCSprite")
	    	if oldPropIcon then
	    		oldPropIcon:removeFromParentAndCleanup(true)
	    		oldPropIcon = nil
	    	end
	    	local oldAdjutantIcon = tolua.cast(cell:getChildByTag(adjutantIconTag), "CCSprite")
	    	if oldAdjutantIcon then
	    		oldAdjutantIcon:removeFromParentAndCleanup(true)
	    		oldAdjutantIcon = nil
	    	end
	    	local propIconName = "adj_propertyIcon_lock.png"
	    	if adjTotalLv >= heroAdjutantVoApi:getAdjutantCfg().chainEffectList[i].totalLv then
	    		propIconName = "adj_property_icon"..i..".png"
	    	end
	        local propIcon = CCSprite:createWithSpriteFrameName(propIconName)
	        propIcon:setScale(0.3)
	        if propIconFirstPosX == nil then
	            propIconFirstPosX = cellW - (propIcon:getContentSize().width * propIcon:getScale() * 4 + (4 - 1) * propIconScapeW) - 5
	        end
	        propIcon:setAnchorPoint(ccp(0, 0.5))
	        propIcon:setPosition(propIconFirstPosX + (i - 1) * (propIcon:getContentSize().width * propIcon:getScale() + propIconScapeW), titleBg:getPositionY() - titleBg:getContentSize().height / 2)
	        propIcon:setTag(propIconTag)
	        cell:addChild(propIcon)
	        local adjId, adjActivateState
	        if adjData and adjData[i] then
	        	if adjData[i][3] then
	        		adjId = adjData[i][3]
	        	end
	        	if adjData[i][1] == 1 then
	        		adjActivateState = true
	        	end
	        end
	        local adjutantIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, adjActivateState, nil, nil, nil, i)
	        adjutantIcon:setScale(0.335)
	        adjutantIcon:setAnchorPoint(ccp(0, 1))
	        adjutantIcon:setPosition(titleBg:getPositionX() + 40 + (i - 1) * (adjutantIcon:getContentSize().width * adjutantIcon:getScale() + 8), titleBg:getPositionY() - titleBg:getContentSize().height - 5)
	        adjutantIcon:setTag(propIconTag)
	        cell:addChild(adjutantIcon)
	    end
	end
end

function heroAdjutantDialog:doUserHandler()
end

function heroAdjutantDialog:tick()
end

function heroAdjutantDialog:dispose()
	if self.refreshListener then
    	eventDispatcher:removeEventListener("heroAdjutant.list.refresh", self.refreshListener)
    	self.refreshListener = nil
    end
    self = nil
	spriteController:removePlist("public/datebaseShow.plist")
end
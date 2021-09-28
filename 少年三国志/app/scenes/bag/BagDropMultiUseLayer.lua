-- 走掉落表的道具批量使用


local BagDropMultiUseLayer = class("BagDropMultiUseLayer", UFCCSModelLayer)

local EffectSingleMoving = require ("app.common.effects.EffectSingleMoving")
local ItemCell = require("app.scenes.bag.BagDropMultiUseCell")
local EffectNode = require ("app.common.effects.EffectNode")

local USE_INTERVAL = 0.01 -- 每秒100次
local NUM_LABEL_ORIGINAL_POSX = 45
local NUM_TAG_LABEL_ORIGINAL_POSX = -5
local NUM_LABEL_ORIGINAL_WIDTH = 16

function BagDropMultiUseLayer.show( itemId, propNum, ... )
	local layer = BagDropMultiUseLayer.new("ui_layout/bag_DropMultiUseLayer.json", Colors.modelColor, itemId, propNum, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end


function BagDropMultiUseLayer:ctor( json, color, itemId, propNum, ... )
	__Log("[BagDropMultiUseLayer:ctor] itemId = %d", itemId)
	self._itemId = itemId
	self._propNum = propNum

	self._useCount = 0
	self._scrollView = nil
	self._scrollCellList	= {}	-- items cell table
	self._scrollTotalHeight	= 0		-- 滑动区域的总长度

	self._isUseStop = false

	self._currentNumTagLabel = nil
	self._currentNumLabel = nil

	self.super.ctor(self, json)
end


function BagDropMultiUseLayer:onLayerLoad( ... )
	self._scrollView = self:getScrollViewByName("ScrollView_Items")
	self._scrollView:setScrollEnable(false)
end


function BagDropMultiUseLayer:onLayerEnter( ... )
	EffectSingleMoving.run(self:getImageViewByName("Image_Bg"), "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)

	self._currentNumLabel = self:getLabelByName("Label_Current_Num")
	self._currentNumLabel:createStroke(Colors.strokeBrown, 1)
	self._currentNumTagLabel = self:getLabelByName("Label_Current_Num_Tag")
	self._currentNumTagLabel:createStroke(Colors.strokeBrown, 1)
	self:_updateItemRemainNum()

	local scrollBg = self:getImageViewByName("Image_Inner_Bg")
	local bgHeight = scrollBg:getSize().height
	local initHeight = bgHeight * 0.95
	local initY = -initHeight * 0.5
	local oldSize = self._scrollView:getSize()

	self._scrollView:setPositionY(initY)
	self._scrollView:setSize(CCSize(oldSize.width, initHeight))
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, initHeight))

	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._recvUseBagItem, self) 
	self:registerBtnClickEvent("Button_Finish_Using", handler(self, self._onUsingFinishedClicked))
	self:registerBtnClickEvent("Button_Pause_Using", handler(self, self._onPauseUsingClicked))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseBtnClicked))

	self:showWidgetByName("Button_Pause_Using", true)
	self:showWidgetByName("Button_Finish_Using", false)
	local finishBtn = self:getButtonByName("Button_Finish_Using")
	-- 按钮光环特效
	local btnEffect = EffectNode.new("effect_around2")     
	btnEffect:setScale(1.8) 
	finishBtn:addNode(btnEffect)
	btnEffect:play()

	self:_useNextItem()
end


function BagDropMultiUseLayer:_onPauseUsingClicked(  )
	self._isUseStop = true
end


function BagDropMultiUseLayer:_onUsingFinishedClicked(  )
	self:animationToClose()
end

function BagDropMultiUseLayer:_onCloseBtnClicked(  )
	-- if not self._isUseStop then
	-- 	return
	-- end
	self:animationToClose()
end

function BagDropMultiUseLayer:_useNextItem(  )

	if self._useCount < self._propNum and not self._isUseStop then
		local CheckFunc = require("app.scenes.common.CheckFunc")
		local scenePack = G_GlobalFunc.sceneToPack("app.scenes.bag.BagScene", {})
	    if CheckFunc.checkBeforeUseItem(self._itemId, scenePack) then
	    	self:_usingStopped()
	        return
	    end
		self._useCount = self._useCount + 1
		G_HandlersManager.bagHandler:sendUseItemInfo(self._itemId)
	else
		self:_usingStopped()
	end
	
end


function BagDropMultiUseLayer:_recvUseBagItem( data )

	if rawget(data, "awards") then
		self:_addDropedItem(data.awards, ItemCell.IN_USE)
		self:_updateItemRemainNum()
	end

	-- wait a moment and use next item
	if self._useCount < self._propNum then
		uf_funcCallHelper:callAfterDelayTimeOnObj(self, USE_INTERVAL, nil, handler(self, self._useNextItem))
	else
		self:_usingStopped()
	end
end

function BagDropMultiUseLayer:_updateItemRemainNum(  )
	self._currentNumLabel:setText(math.max(self._propNum-self._useCount, 0))

	-- adjust position
	local labelSize = self._currentNumLabel:getSize()
	local deltaPosx = (labelSize.width - NUM_LABEL_ORIGINAL_WIDTH ) / 2
	self._currentNumTagLabel:setPositionX(NUM_TAG_LABEL_ORIGINAL_POSX - deltaPosx)
	self._currentNumLabel:setPositionX(NUM_LABEL_ORIGINAL_POSX - deltaPosx)
end

function BagDropMultiUseLayer:_usingStopped(  )
	self._isUseStop = true
	self._scrollView:setScrollEnable(true)
	self:showWidgetByName("Button_Pause_Using", false)
	self:showWidgetByName("Button_Finish_Using", true)
	self:_addDropedItem(nil, ItemCell.STOP_USE)

	for i, v in ipairs(self._scrollCellList) do
		v:setItemImageClickable()
	end
end

function BagDropMultiUseLayer:_addDropedItem( items, cellType )
	-- create a cell and attach it to the scroll view
	local cellIndex = #self._scrollCellList + 1
	local newCell = ItemCell.new(cellType, items, self._useCount)
	self._scrollCellList[cellIndex] = newCell
	self._scrollView:getInnerContainer():addChild(newCell)

	-- if the scroll height is not enough, then extend it
	local curScrollSize = self._scrollView:getInnerContainerSize()
	local cellHeight = newCell:getHeight()
	self._scrollTotalHeight = self._scrollTotalHeight + cellHeight + ItemCell.GAP * (cellIndex > 1 and 1 or 0)

	local viewExtended = false
	if self._scrollTotalHeight > curScrollSize.height then
		viewExtended = true
		self._scrollView:setInnerContainerSize(CCSize(curScrollSize.width, self._scrollTotalHeight))
	end

	-- adjust the position of the cells
	if viewExtended then
		local curY = self._scrollTotalHeight
		for i, v in ipairs(self._scrollCellList) do
			local cellHeight = v:getHeight()
			local y = curY - cellHeight - ItemCell.GAP * (i > 1 and 1 or 0)
			v:setPositionY(y)
			curY = y
		end

		self._scrollView:jumpToBottom()
	else
		local y = curScrollSize.height - self._scrollTotalHeight
		newCell:setPositionY(y)
	end
end


function BagDropMultiUseLayer:onLayerExit( ... )
	-- body
end


function BagDropMultiUseLayer:onLayerUnload( ... )
	-- body
end


return BagDropMultiUseLayer
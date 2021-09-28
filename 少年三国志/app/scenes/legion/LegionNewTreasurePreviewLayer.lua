--LegionNewTreasurePreviewLayer.lua

require("app.cfg.corps_dungeon_award_info")

local LegionNewTreasurePreviewLayer = class("LegionNewTreasurePreviewLayer", UFCCSModelLayer)

function LegionNewTreasurePreviewLayer.show( ... )
	local legionLayer = LegionNewTreasurePreviewLayer.new("ui_layout/legion_DungeonNewTreasure.json", Colors.modelColor,...)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionNewTreasurePreviewLayer:ctor( ... )
	self._treasurePreviewList = nil
	self:_initCheckBox()
	self.super.ctor(self, ...)
end

function LegionNewTreasurePreviewLayer:onLayerLoad( _,_,chapterId )
	self._chapterId = chapterId
	self._treasureData = G_Me.legionData:getNewAwardPreviewListByChapter(chapterId)
	-- self:enableLabelStroke("Label_title2", Colors.strokeBrown, 2 )
	self:showTextWithLabel("Label_desc1", G_lang:get("LANG_NEW_LEGION_TREASURE_DESC1"))
	self:showTextWithLabel("Label_desc2", G_lang:get("LANG_NEW_LEGION_TREASURE_DESC2"))

	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))
end

function LegionNewTreasurePreviewLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_2"), "smoving_bounce")
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_AWARD_LIST, self._onAwardListUpdate, self)
	
	self:_updateCheckBox()
	self:_initTreasurePreviewList()
	-- local panel = self:getPanelByName("Panel_treasure_list")
	-- self:createAwardList(panel,self._treasureData,3)

	self:_initCountDonwTime()
end

function LegionNewTreasurePreviewLayer:onLayerExit( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        		self._timer = nil
	end
end

function LegionNewTreasurePreviewLayer:_initCheckBox( ... )
	self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)
	self._tabs:add("CheckBox_1",nil,"Label_name1")
	self._tabs:add("CheckBox_2",nil,"Label_name2")
	self._tabs:add("CheckBox_3",nil,"Label_name3")
	self._tabs:add("CheckBox_4",nil,"Label_name4")
end

function LegionNewTreasurePreviewLayer:_updateCheckBox( ... )
	local info = corps_dungeon_chapter_info.get(self._chapterId)
	self._tabList = {CheckBox_1=info.dungeon_1,CheckBox_2=info.dungeon_2,CheckBox_3=info.dungeon_3,CheckBox_4=info.dungeon_4}
	self._tabs:checked("CheckBox_1")
	for i = 1 , 4 do 
		local name = self._treasureData[i].name
		self:getLabelByName("Label_name"..i):setText(name)
		self:getLabelByName("Label_name"..i.."_0"):setText(name)
	end
end

function LegionNewTreasurePreviewLayer:onCheckCallback( btnName )
	self._checkedId = self._tabList[btnName]
	self._treasureListData = G_Me.legionData:getNewAwardPreviewList(self._checkedId)
	if G_Me.legionData:getNewAwardInited(self._checkedId) then
		self:_initTreasurePreviewList()
	else
		G_HandlersManager.legionHandler:sendGetNewDungeonAwardList(self._checkedId)
	end
end

function LegionNewTreasurePreviewLayer:_onAwardListUpdate()
	self._treasureListData = G_Me.legionData:getNewAwardPreviewList(self._checkedId)
	if self._treasureListData then
		self:_initTreasurePreviewList()
	end
end

function LegionNewTreasurePreviewLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionNewTreasurePreviewLayer:_initCountDonwTime( ... )
	self._countDownTime = G_Me.legionData:getLeftDungeonTime()
	local _updateTime = function ( ... )
		if self._countDownTime < 0 then 
			self._countDownTime = 0
		end
		local hour = self._countDownTime/3600
		local min = (self._countDownTime%3600)/60
		local sec = self._countDownTime%60
		self:showTextWithLabel("Label_time", string.format("%02d:%02d:%02d", hour, min, sec))
		self._countDownTime = self._countDownTime -1	
	end
	_updateTime()
	if not self._timer then 
		self._timer = G_GlobalFunc.addTimer(1,function()
			if _updateTime then 
				_updateTime()
			end
		end)
	end
end

function LegionNewTreasurePreviewLayer:_initTreasurePreviewList( ... )
	if not self._treasurePreviewList then 
		local panel = self:getPanelByName("Panel_treasure_list")
		if panel == nil then
			return 
		end

	self._treasurePreviewList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._treasurePreviewList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionNewTreasurePreviewItem").new(list, index)
    	end)
    	self._treasurePreviewList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(self._treasureListData,index + 1)
    		end
    	end)
	end

	local count = #self._treasureData
	local itemSize = count/3
	if count % 3 ~= 0 then
		itemSize = itemSize + 1
	end
    	self._treasurePreviewList:reloadWithLength(itemSize)
end

function LegionNewTreasurePreviewLayer:createAwardList(panel,content,rowNum)
	if type(content) ~= "table" or #content < 1 then 
		return 
	end

	local contentList = self:getScrollViewByName("ScrollView_treasureList")

	local scrollSize = contentList:getSize()
	local topPt = ccp(scrollSize.width/2, scrollSize.height - 10)
	local leftEdge = 10
	local contentEdge = 10
	local topYPos = 5
	local _addContent = function ( award, topY )
		local row = math.ceil(#award/rowNum)
		local top = topY
		for index = row , 1, -1 do 
			local item = require("app.scenes.legion.LegionNewTreasurePreviewItem").new()
			item:updateItem(award,index)
			contentList:addChild(item)
			local descSize = item:getSize()

			top = top + contentEdge
			item:setPositionXY(0, top)
			top = top + descSize.height
		end
		return top
	end

	local _addTitle = function ( title, topY )
		local back = ImageView:create()
		back:loadTexture(G_Path.getKnightNameBack())
		local nameLabel = GlobalFunc.createGameLabel(title, 24, Colors.darkColors.TITLE_01, Colors.strokeBrown)
		back:addChild(nameLabel)
		nameLabel:setPosition(ccp(0, 6))
		contentList:addChild(back)
		local size = back:getSize()
		local top = topY + size.height/2 + 15
		back:setPositionXY(scrollSize.width/2, top)
		return top + size.height/2
	end

	for loopi = #content, 1, -1 do 
		local awardCell = content[loopi]
		if awardCell then
			topYPos = _addContent(awardCell.award, topYPos)
			topYPos = _addTitle(awardCell.name, topYPos)
			topYPos = topYPos + 10
		end
	end

	if scrollSize.height > topYPos then
		local xPos, yPos = contentList:getPosition()
		contentList:setPositionXY(xPos, yPos + (scrollSize.height - topYPos))
	else
		contentList:setInnerContainerSize(CCSizeMake(scrollSize.width, topYPos))
		contentList:jumpToTop()
	end
end

return LegionNewTreasurePreviewLayer

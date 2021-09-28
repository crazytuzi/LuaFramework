--LegionListLayer.lua

local LegionListLayer = class("LegionListLayer", UFCCSNormalLayer)

LegionListLayer.MAX_CORP_LENGTH = 5

function LegionListLayer.create( ... )
	return LegionListLayer.new("ui_layout/legion_MainLayer.json", nil, ...)
end

function LegionListLayer:ctor( ... )
	self._startIndex = 1
	self._corpList = nil
	self._layerMoveOffset = 0
	self._showSearchResult = false

	self.super.ctor(self, ...)
end

function LegionListLayer:onLayerLoad( _, _, scenePack )
	G_GlobalFunc.savePack(self, scenePack)

	self:registerBtnClickEvent("Button_back", handler(self, self._onBackClick))
	self:registerBtnClickEvent("Button_create", handler(self, self._onCreateClick))
	self:registerBtnClickEvent("Button_find", handler(self, self._onSearchClick))
	self:registerBtnClickEvent("Button_showList", handler(self, self._onShowCorpListClick))

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_LIST, self._onReceiceCorpList, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_JOIN_CORP_LIST, self._onUpdateJoinCorpList, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CREATE_CORP, self._onCreateCorp, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SEARCH_CORP, self._onSearchCorpResult, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REQUEST_JOIN_CORP, self._onApplyCorpFresh, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DELETE_JOIN_CORP, self._onCancelApplyCorpFresh, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_DETAIL, self._onRefreshCorpDetail, self)

	self:enableLabelStroke("Label_list_check", Colors.strokeBrown, 2 )

	self:registerTextfieldEvent("TextField_name",function ( textfield, eventType )
		self:callAfterFrameCount(1, function ( ... )
		    self:_onInputLegionNameEvent(eventType) 
		end)
		    
     end)
	self:showWidgetByName("Button_showList", false)
	G_HandlersManager.legionHandler:sendGetJoinCorpList()
end

function LegionListLayer:onLayerUnload( ... )
	G_Me.legionData:clearCorpList()
end

function LegionListLayer:onLayerEnter( ... )
	self:callAfterFrameCount(1, function ( ... )
		self:adapterWidgetHeight("Panel_content", "Panel_Top", "Image_21", 10, 0)
		--self:adapterWidgetHeight("Panel_legion_list", "Panel_Top", "Image_21", 0, 0)
		if G_Me.legionData:getCorpLength() < 1 then 
			G_HandlersManager.legionHandler:sendGetCorpList(self._startIndex, LegionListLayer.MAX_CORP_LENGTH + self._startIndex - 1)
		else
			self:_refreshCorpList()
		end
	end)
	
end

function LegionListLayer:_onBackClick( ... )
	local packScene = G_GlobalFunc.createPackScene(self)
    if not packScene then 
        packScene = require("app.scenes.mainscene.MainScene").new()
    end
    uf_sceneManager:replaceScene(packScene)
end

function LegionListLayer:_onCreateClick( ... )
	require("app.scenes.legion.LegionCreateLayer").createLegion()
end

function LegionListLayer:_onSearchClick( ... )
	local textfield = self:getTextFieldByName("TextField_name")
	if not textfield then 
		return 
	end

	local text = textfield:getStringValue() or ""
	if G_GlobalFunc.matchText(text) then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CREATE_INVALID_NAME"))
	end

	if #text < 1 then 
		return 
	end

	G_HandlersManager.legionHandler:sendSearchCorp(text)
end

function LegionListLayer:_onSearchCorpResult( ... )
	self._showSearchResult = true
	self:showWidgetByName("Button_showList", true)
	local corp = G_Me.legionData:getSearchResultCorp()
	if self._corpList then
		self._corpList:setShowPostfix(false)
		self._corpList:reloadWithLength( type(corp) == "table" and 1 or 0 )
	end
end

function LegionListLayer:_onShowCorpListClick( ... )
	self._showSearchResult = false
	self:showWidgetByName("Button_showList", false)
	if self._corpList then
		self._corpList:setShowPostfix(true)
		self._corpList:reloadWithLength( G_Me.legionData:getCorpLength() )
	end
end

function LegionListLayer:_onReceiceCorpList( ret, startId, endId )
	if not startId or not endId or (startId == 0 and startId == endId) then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CORP_LIST_NO_MORE"))
	end

	self:_onUpdateJoinCorpList()
end

function LegionListLayer:_onUpdateJoinCorpList(  )
	self:_refreshCorpList()
end

function LegionListLayer:_refreshCorpList( ... )
	if not self._corpList then 
		local _getMoreCorpList = function ( ... )
			self:callAfterFrameCount(5, function ( ... )
    	 		local endCorpIndex = G_Me.legionData:getEndCorpIndex()
    	 		local startCorpIndex = G_Me.legionData:getShowCorpStart()
                	--if endCorpIndex == startCorpIndex + LegionListLayer.MAX_CORP_LENGTH - 1 then 
               	G_HandlersManager.legionHandler:sendGetCorpList(endCorpIndex + 1, endCorpIndex + LegionListLayer.MAX_CORP_LENGTH)
                	--end
                -- if topLeft then
                -- 	if startCorpIndex > 1 then 
                -- 		if startCorpIndex > LegionListLayer.MAX_CORP_LENGTH then
                -- 			G_HandlersManager.legionHandler:sendGetCorpList(startCorpIndex - LegionListLayer.MAX_CORP_LENGTH, startCorpIndex - 1)
                -- 		else
                -- 			G_HandlersManager.legionHandler:sendGetCorpList(1, LegionListLayer.MAX_CORP_LENGTH)
                -- 		end
                -- 	end
                -- end
    	 	end)
		end
		local panel = self:getPanelByName("Panel_legion_list")
		if panel == nil then
			return 
		end

		self._corpList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._corpList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionListItem").new(list, index)
    	end)
    	self._corpList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			local corpItem = nil 
    			if self._showSearchResult then 
    				corpItem = G_Me.legionData:getSearchResultCorp()
    			else
    				corpItem = G_Me.legionData:getCorpByIndex(index + 1)
    			end
    			cell:updateItem(corpItem)
    		end
    	end)
    	self._corpList:setSelectCellHandler(function ( cell, index )
    	end)
    	self._corpList:setShowMoreHandler(function ( list, topLeft, bottomRight )
    		if  bottomRight then 
    	 	  _getMoreCorpList()
    	 	end
        end)

		local postfix = CCSItemCellBase:create("ui_layout/legion_MoreLegion.json")
    	--postfix:getLabelByName("Label_more"):setText(G_lang:get("LANG_MAIL_MORE"))
    	postfix:registerBtnClickEvent("Button_more", function ( widget )
        	_getMoreCorpList()
    	end)
    	self._corpList:setPostfixCell(postfix)
    	self._corpList:setShowMoreEnable(true)
	end

	local startIndex = self._corpList:getShowStart()
	self._corpList:reloadWithLength( G_Me.legionData:getCorpLength(), startIndex )
end

function LegionListLayer:_onCreateCorp( ... )
	
	
end

function LegionListLayer:_onRefreshCorpDetail( ... )
	if G_Me.legionData:hasCorp() then 
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end
end

function LegionListLayer:_onInputLegionNameEvent( eventType )
	local textfield = self:getTextFieldByName("TextField_name")
	local sharedApplication = CCApplication:sharedApplication()
	local target = sharedApplication:getTargetPlatform()

	local widgetRoot = self:getWidgetByName("Image_21")
	if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW then 
		if target == kTargetIphone or target == kTargetIpad then 
			if self._layerMoveOffset < 1 and textfield then 
					local textSize = textfield:getSize()
					local screenPosx, screenPosy = textfield:convertToWorldSpaceXY(0, 0)
					local keyboardHeight = textfield:getKeyboardHeight()
          			if display.contentScaleFactor >= 2 then 
            			keyboardHeight = keyboardHeight/2
          			end
					if keyboardHeight > screenPosy - 2*textSize.height then 
						self._layerMoveOffset = keyboardHeight - screenPosy + 2*textSize.height
					end

					if self._layerMoveOffset > 0 then 
						widgetRoot:runAction(CCMoveBy:create(0.2, ccp(0, self._layerMoveOffset)))
						textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
					end
			end
		end
	elseif eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_HIDE then 
		if self._layerMoveOffset > 0 then 
			widgetRoot:runAction(CCMoveBy:create(0.2, ccp(0, -self._layerMoveOffset)))
			textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
			self._layerMoveOffset = 0
		end
	end
end

function LegionListLayer:_onApplyChange( isApply )
	if self._corpList then 
		self._corpList:refreshAllCell()
	end

	G_MovingTip:showMovingTip(G_lang:get(isApply and "LANG_LEGION_APPLY_CORP_SUCCESS" or "LANG_LEGION_CANCEL_APPLY_CORP_SUCCESS"))
end

function LegionListLayer:_onApplyCorpFresh( ... )
	self:_onApplyChange(true)
end

function LegionListLayer:_onCancelApplyCorpFresh( ... )
	self:_onApplyChange(false)
end

return LegionListLayer


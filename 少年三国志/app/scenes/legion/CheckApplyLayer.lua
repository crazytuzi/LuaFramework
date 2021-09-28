--CheckApplyLayer.lua


local CheckApplyLayer = class("CheckApplyLayer", UFCCSModelLayer)


function CheckApplyLayer.show( ... )
	local checkApply = CheckApplyLayer.new("ui_layout/legion_CheckApply.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(checkApply)
end

function CheckApplyLayer:ctor( ... )
	self.super.ctor(self, ...)
end

function CheckApplyLayer:onLayerLoad( ... )
    G_HandlersManager.legionHandler:sendGetCorpJoinMember()
	self:closeAtReturn(true)
	self:registerBtnClickEvent("Button_close", handler(self, self._onCloseClick))
	self:registerBtnClickEvent("Button_close_1", handler(self, self._onCloseClick))

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CONFIRM_JOIN_CORP, self._onDisposeCorpApply, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_JOIN_MEMBER, self._onRefreshCorpApplyList, self)
end

function CheckApplyLayer:onLayerEnter( ... )
	self:showAtCenter(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
	self:_initApplyList()
end

function CheckApplyLayer:_onCloseClick( ... )
	self:animationToClose()
end

function CheckApplyLayer:_initApplyList( ... )
	if not self._applyList then 
		local panel = self:getPanelByName("Panel_check_list")
		if panel == nil then
			return 
		end

		self._applyList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._applyList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionApplyItem").new(list, index)
    	end)
    	self._applyList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)
    	self._applyList:setSelectCellHandler(function ( cell, index )
    	end)
	end
	self._applyList:reloadWithLength(G_Me.legionData:getCorpApplyLength())

	self:showWidgetByName("Label_no_apply_tip", G_Me.legionData:getCorpApplyLength() < 1)

	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	local corpsInfo = corps_info.get(detailCorp and detailCorp.level or 0)
	if detailCorp and corpsInfo then
		self:showTextWithLabel("Label_count_value", (detailCorp.size or 0).."/"..(corpsInfo and corpsInfo.number or 0))
	end
end

function CheckApplyLayer:_onRefreshCorpApplyList( ... )
	self._applyList:reloadWithLength(G_Me.legionData:getCorpApplyLength())
	self:showWidgetByName("Label_no_apply_tip", G_Me.legionData:getCorpApplyLength() < 1)
end

function CheckApplyLayer:_onDisposeCorpApply( ret )
	if ret ~= 1 then 
		return G_HandlersManager.legionHandler:sendGetCorpJoinMember()
	end
	if not self._applyList then 
		return 
	end

	local length = G_Me.legionData:getCorpApplyLength() or 0
	if length < 1 then 
		return self:_onCloseClick()
	end

	local startIndex = self._applyList:getShowStart()
	self._applyList:reloadWithLength(length, startIndex)
	self:showWidgetByName("Label_no_apply_tip", G_Me.legionData:getCorpApplyLength() < 1)
end

return CheckApplyLayer

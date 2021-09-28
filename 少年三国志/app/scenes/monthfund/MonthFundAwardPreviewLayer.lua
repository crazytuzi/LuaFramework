--月基金奖励预览

require("app.cfg.month_fund_info")

local MonthFundPreviewAwardItemNumPerLine = 4

local MonthFundAwardPreviewLayer = class("MonthFundAwardPreviewLayer", UFCCSModelLayer)

function MonthFundAwardPreviewLayer.show( ... )
	local awardLayer = MonthFundAwardPreviewLayer.new("ui_layout/monthfund_AwardPreviewLayer.json", Colors.modelColor,...)
	if awardLayer then 
		uf_sceneManager:getCurScene():addChild(awardLayer)
	end
end

function MonthFundAwardPreviewLayer:ctor( json,color,_type )
	self._awardPreviewList = nil
	self._type = _type
	self.super.ctor(self, json)
end

function MonthFundAwardPreviewLayer:onLayerLoad( ... )

	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
end

function MonthFundAwardPreviewLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

	self:_initAwardPreviewList()

end

function MonthFundAwardPreviewLayer:onLayerExit( ... )

end

function MonthFundAwardPreviewLayer:_onCancelClick( ... )
	self:animationToClose()
end


function MonthFundAwardPreviewLayer:_initAwardPreviewList( ... )
	if not self._awardPreviewList then 
		local panel = self:getPanelByName("Panel_list")
		if panel == nil then
			return 
		end

		self._awardPreviewList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._awardPreviewList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.monthfund.MonthFundAwardPreviewItem").new(list, index)
    	end)
    	self._awardPreviewList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1,self._type)
    		end
    	end)
	end

	local count = month_fund_info.getLength()
	local itemSize = math.ceil(count/MonthFundPreviewAwardItemNumPerLine)

    self._awardPreviewList:reloadWithLength(itemSize)
end

return MonthFundAwardPreviewLayer

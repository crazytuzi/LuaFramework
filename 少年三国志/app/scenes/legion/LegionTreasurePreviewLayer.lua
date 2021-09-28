--LegionTreasurePreviewLayer.lua

require("app.cfg.corps_dungeon_award_info")

local LegionTreasurePreviewLayer = class("LegionTreasurePreviewLayer", UFCCSModelLayer)

function LegionTreasurePreviewLayer.show( ... )
	local legionLayer = LegionTreasurePreviewLayer.new("ui_layout/legion_DungeonTreasure.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionTreasurePreviewLayer:ctor( ... )
	self._treasurePreviewList = nil
	self.super.ctor(self, ...)
end

function LegionTreasurePreviewLayer:onLayerLoad( ... )
	self:enableLabelStroke("Label_20", Colors.strokeBrown, 2 )

	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))
end

function LegionTreasurePreviewLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_2"), "smoving_bounce")
	
	self:_initTreasurePreviewList()

	self:_initCountDonwTime()
end

function LegionTreasurePreviewLayer:onLayerExit( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
	end
end

function LegionTreasurePreviewLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionTreasurePreviewLayer:_initCountDonwTime( ... )
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
function LegionTreasurePreviewLayer:_initTreasurePreviewList( ... )
	if not self._treasurePreviewList then 
		local panel = self:getPanelByName("Panel_treasure_list")
		if panel == nil then
			return 
		end

		self._treasurePreviewList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._treasurePreviewList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionTreasurePreviewItem").new(list, index)
    	end)
    	self._treasurePreviewList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)
	end

	local count = corps_dungeon_award_info.getLength()
	local itemSize = count/3
	if count % 3 ~= 0 then
		itemSize = itemSize + 1
	end
    self._treasurePreviewList:reloadWithLength(itemSize)
end

return LegionTreasurePreviewLayer

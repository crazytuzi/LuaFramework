--LegionAttackAimLayer.lua

require("app.cfg.corps_dungeon_chapter_info")

local LegionAttackAimLayer = class("LegionAttackAimLayer", UFCCSModelLayer)

function LegionAttackAimLayer.show( ... )
	local legionLayer = LegionAttackAimLayer.new("ui_layout/legion_DungeonChooseAim.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionAttackAimLayer:ctor( ... )
	self._chapterList = nil
	self.super.ctor(self, ...)
end

function LegionAttackAimLayer:onLayerLoad( ... )
	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_close_1", handler(self, self._onCancelClick))

	self:_initChapterList()

	G_HandlersManager.legionHandler:sendGetCorpChapter()
end

function LegionAttackAimLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CHATER_INFO, self._onTomorrowChapterChange, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SET_CORP_CHAPTER_ID, self._onTomorrowChapterChange, self)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function LegionAttackAimLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionAttackAimLayer:_initChapterList( ... )
	if not self._hallMemberList then 
		local panel = self:getPanelByName("Panel_list")
		if panel == nil then
			return 
		end

		self._hallMemberList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._hallMemberList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionAttackAimItem").new(list, index)
    	end)
    	self._hallMemberList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)
	end
    self._hallMemberList:reloadWithLength(corps_dungeon_chapter_info.getLength() - 1, 0,  0.2)
end

function LegionAttackAimLayer:_onTomorrowChapterChange( ... )
	if self._hallMemberList then 
		self._hallMemberList:refreshAllCell()
	end
end

return LegionAttackAimLayer


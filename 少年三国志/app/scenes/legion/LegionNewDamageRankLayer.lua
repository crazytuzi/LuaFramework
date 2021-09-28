--LegionNewDamageRankLayer.lua


require("app.cfg.corps_dungeon_rank_info")

local LegionNewDamageRankLayer = class("LegionNewDamageRankLayer", UFCCSModelLayer)


function LegionNewDamageRankLayer.show( ... )
	local legionLayer = LegionNewDamageRankLayer.new("ui_layout/legion_DungeonNewRankList.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionNewDamageRankLayer:ctor( ... )
	self._memberRankList = nil 
	self.super.ctor(self, ...)
end

function LegionNewDamageRankLayer:onLayerLoad( ... )

	self:enableLabelStroke("Label_info_check", Colors.strokeBrown, 2 )
    	self:enableLabelStroke("Label_member_check", Colors.strokeBrown, 2 )
    	self:showTextWithLabel("Label_rank_name", G_lang:get("LANG_NEW_LEGION_PAIHANG_RANK") )
    	self:showTextWithLabel("Label_rank_award", G_lang:get("LANG_NEW_LEGION_PAIHANG_TIMES") )
    	self:showTextWithLabel("Label_rank_damage", G_lang:get("LANG_NEW_LEGION_PAIHANG_DAMAGE") )
    	self:showTextWithLabel("Label_tip", G_lang:get("LANG_NEW_LEGION_PAIHANG_TIPS") )

	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))

	G_HandlersManager.legionHandler:sendGetNewDungeonCorpMemberRank()	
end

function LegionNewDamageRankLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_CORP_MEMBER_RANK, self._onMemberRankUpdate, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("bg"), "smoving_bounce")
end
function LegionNewDamageRankLayer:_onCancelClick( ... )
	self:animationToClose()
end


function LegionNewDamageRankLayer:_onMemberRankUpdate( ... )
	-- if self._memberRankList then 
	-- 	local legionRankCount = G_Me.legionData:getLegionRankCount()
	-- 	local startIndex = self._memberRankList:getShowStart()
	-- 	self._memberRankList:reloadWithLength(legionRankCount, startIndex)
	-- end
	self:_updateList()
end

function LegionNewDamageRankLayer:_updateList( ... )
	self:_updateMyLegionRank()

	if not self._memberRankList then 
		local panel = self:getPanelByName("member_ranklist")
		if panel == nil then
			return 
		end

		self._memberRankList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	    	self._memberRankList:setCreateCellHandler(function ( list, index)
	    	    return require("app.scenes.legion.LegionNewDamageRankLegionItem").new(list, index)
	    	end)
	    	self._memberRankList:setUpdateCellHandler(function ( list, index, cell)
	    		if cell then 
	    			cell:updateItem(index + 1)
	    		end
	    	end)    	
	end

	self._memberRankList:reloadWithLength(#G_Me.legionData:getNewLegionRank())
	self:showWidgetByName("Label_tip", #G_Me.legionData:getNewLegionRank()==0)
end

function LegionNewDamageRankLayer:_updateMyLegionRank( ... )
	local selfLegionRank = G_Me.legionData:getNewMyLegionRank() or 1
	self:showTextWithLabel("Label_rank_value", selfLegionRank == 0 and G_lang:get("LANG_LEGION_RANK_NUMBER_NULL") or selfLegionRank)

	local rankInfo = G_Me.legionData:getNewLegionRankByIndex(selfLegionRank)
	self:showTextWithLabel("Label_rank_award_value", rankInfo and rankInfo.sp1 or 0)
	self:showTextWithLabel("Label_rank_damage_value", rankInfo and G_GlobalFunc.ConvertNumToCharacter(rankInfo.harm) or 0)
end

return LegionNewDamageRankLayer


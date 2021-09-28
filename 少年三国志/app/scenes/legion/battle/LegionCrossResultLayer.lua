--LegionCrossResultLayer.lua

local LegionCrossResultLayer = class("LegionCrossResultLayer", UFCCSModelLayer)


function LegionCrossResultLayer.show( ... )
	local resultLayer = LegionCrossResultLayer.new("ui_layout/legion_CrossMemberRankList.json", Colors.modelColor)
	uf_sceneManager:getCurScene():addChild(resultLayer)
end

function LegionCrossResultLayer:ctor( ... )
	self._crossResultList = nil
	self.super.ctor(self, ...)
end

function LegionCrossResultLayer:onLayerLoad( ... )
	

	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCloseClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCloseClick))

	G_HandlersManager.legionHandler:sendCrossBattleMemberRank()

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_MEMBER_RANK, 
		self._onRefreshMemberRank, self)
end

function LegionCrossResultLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("bg"), "smoving_bounce")
	self:_initResultList()
end

function LegionCrossResultLayer:_onCloseClick( ... )
	self:animationToClose()
end

function LegionCrossResultLayer:_onRefreshMemberRank( ... )
	self:_initResultList()
end

function LegionCrossResultLayer:_initResultList( ... )
	if not self._crossResultList then 
		local panel = self:getPanelByName("member_ranklist")
		if panel == nil then
			return 
		end

		self._crossResultList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._crossResultList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.battle.LegionCrossResultItem").new(list, index)
    	end)
    	self._crossResultList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)
    	self._crossResultList:setSelectCellHandler(function ( cell, index )
    	end)
	end
	self._crossResultList:reloadWithLength(G_Me.legionData:getBattleRankCount())

	self:showWidgetByName("Label_tip", G_Me.legionData:getBattleRankCount() < 1)

	local myRank = G_Me.legionData:getSelfBattleRankIndex()
	self:showWidgetByName("BitmapLabel_rank_value", myRank > 0)
	self:showWidgetByName("Label_rank_value", myRank < 1)
	if myRank > 0 then
		local rankLabel = self:getLabelBMFontByName("BitmapLabel_rank_value")
		if rankLabel then
			rankLabel:setText(myRank > 0 and myRank or 0)
		end
		local rankInfo = G_Me.legionData:getBattleRankInfoByIndex(myRank)
		if rankInfo then 
			self:showTextWithLabel("Label_acquire_exp_value", rankInfo.rob_exp)
			self:showTextWithLabel("Label_kill_count_value", rankInfo.kill_count)
		end
	else
		self:showTextWithLabel("Label_rank_value", G_lang:get("LANG_LEGION_RANK_NUMBER_NULL"))	
		self:showTextWithLabel("Label_acquire_exp_value", "")
		self:showTextWithLabel("Label_kill_count_value", "")
	end
end


return LegionCrossResultLayer


--LegionDamageRankLayer.lua


require("app.cfg.corps_dungeon_rank_info")

local LegionDamageRankLayer = class("LegionDamageRankLayer", UFCCSModelLayer)


function LegionDamageRankLayer.show( ... )
	local legionLayer = LegionDamageRankLayer.new("ui_layout/legion_DungeonRankList.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionDamageRankLayer:ctor( ... )
	self._memberRankList = nil 
	self._allMemberRankList = nil

	self._isShowAllMember = true
	self.super.ctor(self, ...)
end

function LegionDamageRankLayer:onLayerLoad( ... )
	self:addCheckBoxGroupItem(1, "CheckBox_allMember")
    self:addCheckBoxGroupItem(1, "CheckBox_member")

	self:enableLabelStroke("Label_info_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_member_check", Colors.strokeBrown, 2 )

	self:addCheckNodeWithStatus("CheckBox_allMember", "Label_member_check", true)
	self:addCheckNodeWithStatus("CheckBox_allMember", "Panel_global", true)
    self:addCheckNodeWithStatus("CheckBox_allMember", "Label_member_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_member", "Label_info_check", true)
    self:addCheckNodeWithStatus("CheckBox_member", "Panel_legion", true)
    self:addCheckNodeWithStatus("CheckBox_member", "Label_info_uncheck", false)

    self:registerCheckboxEvent("CheckBox_allMember", handler(self, self._onAllMemberCheck))
	self:registerCheckboxEvent("CheckBox_member", handler(self, self._onMemberCheck))
	self:setCheckStatus(1, "CheckBox_allMember")

	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))

	G_HandlersManager.legionHandler:sendGetDungeonCorpRank()
	G_HandlersManager.legionHandler:sendGetDungeonCorpMemberRank()	
end

function LegionDamageRankLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_DUNGEON_CORP_RANK, self._onAllMemberRankUpdate, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_DUNGEON_CORP_MEMBER_RANK, self._onMemberRankUpdate, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("bg"), "smoving_bounce")
end
function LegionDamageRankLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionDamageRankLayer:_onAllMemberRankUpdate( ... )
	if self._allMemberRankList then
		local globalRankCount = G_Me.legionData:getGlobalRankCount()
		local startIndex = self._allMemberRankList:getShowStart()
		self._allMemberRankList:reloadWithLength(globalRankCount, startIndex)
	elseif self._isShowAllMember then
		self:_onSwitchAllMember()
	end
end

function LegionDamageRankLayer:_onMemberRankUpdate( ... )
	if self._memberRankList then 
		local legionRankCount = G_Me.legionData:getLegionRankCount()
		local startIndex = self._memberRankList:getShowStart()
		self._memberRankList:reloadWithLength(legionRankCount, startIndex)
	elseif not self._isShowAllMember then
		self:_onSwitchMember()
	end
end

function LegionDamageRankLayer:_onAllMemberCheck( ... )
	self._isShowAllMember  = true
	self:_onSwitchAllMember()
end

function LegionDamageRankLayer:_onMemberCheck( ... )
	self._isShowAllMember  = false
	self:_onSwitchMember()
end

function LegionDamageRankLayer:_onSwitchAllMember( ... )
	self:_updateMyGlobalRank()
	local globalRankCount = G_Me.legionData:getGlobalRankCount()

	if globalRankCount < 1 then 
		if self._allMemberRankList then 
			self._allMemberRankList:reloadWithLength(0)
		end
    		if self._isShowAllMember then
    			self:showWidgetByName("Label_tip", globalRankCount < 1)
    		end
		return 
	end

	if not self._allMemberRankList then 
		local panel = self:getPanelByName("legion_ranklist")
		if panel == nil then
			return 
		end

		self._allMemberRankList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self:addCheckNodeWithStatus("CheckBox_allMember", "legion_ranklist", true)
    	self._allMemberRankList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionDamageRankGloablItem").new(list, index)
    	end)
    	self._allMemberRankList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)

    	
	end
	
    self._allMemberRankList:reloadWithLength(globalRankCount)
    if self._isShowAllMember then
    	self:showWidgetByName("Label_tip", globalRankCount < 1)
    end
end

function LegionDamageRankLayer:_updateMyGlobalRank( ... )
	local selfGlobalRank = G_Me.legionData:getSelfGlobalRank() or 1
	self:showTextWithLabel("Label_rank_value", selfGlobalRank == 0 and G_lang:get("LANG_LEGION_RANK_NUMBER_NULL") or selfGlobalRank)

	local rankInfo = G_Me.legionData:getGlobalRankByIndex(selfGlobalRank)
	if rankInfo then 
		local _findRankAwardInfo = function ( rankValue )
			if type(rankValue) ~= "number" then 
				return nil
			end

			local length = corps_dungeon_rank_info.getLength()
			for loopi = 1, length do 
				local rankInfo = corps_dungeon_rank_info.get(loopi)
				if rankInfo and rankValue >= rankInfo.rank_min and rankValue <= rankInfo.rank_max then 
					return rankInfo
				end
			end

			return nil
		end

		local text = ""
		local rankAwardInfo = _findRankAwardInfo(rankInfo.rank)
		if rankAwardInfo then 
			local goodInfo = G_Goods.convert(rankAwardInfo.award_type, rankAwardInfo.award_value, rankAwardInfo.award_size)
			if goodInfo then 
				text = "x"..goodInfo.size
			end
		end
		self:showTextWithLabel("Label_rank_award_value", text)
		self:showTextWithLabel("Label_rank_damage_value", rankInfo.harm)
	else
		self:showTextWithLabel("Label_rank_award_value", 0)
		self:showTextWithLabel("Label_rank_damage_value", 0)
	end
end

function LegionDamageRankLayer:_onSwitchMember( ... )
	self:_updateMyLegionRank()

	local legionRankCount = G_Me.legionData:getLegionRankCount()
	if legionRankCount < 1 then 
		if self._memberRankList then 
			self._memberRankList:reloadWithLength(0)
		end
    	if not self._isShowAllMember then
   			self:showWidgetByName("Label_tip", legionRankCount < 1)
		end
		return 
	end

	if not self._memberRankList then 
		local panel = self:getPanelByName("member_ranklist")
		if panel == nil then
			return 
		end

		self._memberRankList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self:addCheckNodeWithStatus("CheckBox_member", "member_ranklist", true)
    	self._memberRankList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionDamageRankLegionItem").new(list, index)
    	end)
    	self._memberRankList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)    	
	end

    self._memberRankList:reloadWithLength(legionRankCount)
    if not self._isShowAllMember then
   		self:showWidgetByName("Label_tip", legionRankCount < 1)
	end
end

function LegionDamageRankLayer:_updateMyLegionRank( ... )
	local selfLegionRank = G_Me.legionData:getSelfLegionRank() or 1
	self:showTextWithLabel("Label_rank_value", selfLegionRank == 0 and G_lang:get("LANG_LEGION_RANK_NUMBER_NULL") or selfLegionRank)

	local rankInfo = G_Me.legionData:getLegionRankByIndex(selfLegionRank)
	self:showTextWithLabel("Label_rank_topdamage_value", rankInfo and rankInfo.harm or 0)
end

return LegionDamageRankLayer


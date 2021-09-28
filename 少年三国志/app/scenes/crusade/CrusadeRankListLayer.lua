--CrusadeRankListLayer.lua

local CrusadeRankListLayer = class("CrusadeRankListLayer", UFCCSModelLayer)


function CrusadeRankListLayer.show( ... )
	local rankLayer = CrusadeRankListLayer.new("ui_layout/crusade_RankListLayer.json", Colors.modelColor)
	if rankLayer then 
		uf_sceneManager:getCurScene():addChild(rankLayer)
	end
end

function CrusadeRankListLayer:ctor( ... )
	self._rankLayer = nil 
	self.super.ctor(self, ...)
end

function CrusadeRankListLayer:onLayerLoad( ... )

	self:showTextWithLabel("Label_rank_name", G_lang:get("LANG_CRUSADE_MY_RANK") )
	self:showTextWithLabel("Label_max_points", G_lang:get("LANG_CRUSADE_MAX_POINTS") )
	self:showTextWithLabel("Label_my_points", G_lang:get("LANG_CRUSADE_MY_POINTS") )
	self:showTextWithLabel("Label_no_rank", G_lang:get("LANG_CRUSADE_NO_RANK_LIST") )
	self:showTextWithLabel("Label_rank_tip", G_lang:get("LANG_CRUSADE_RANK_TIP") )

	self:showWidgetByName("Label_no_rank", false)

	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))

end

function CrusadeRankListLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_GET_RANK, self._updateRankList, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("bg"), "smoving_bounce")

	G_HandlersManager.crusadeHandler:sendGetRankList()	
end


function CrusadeRankListLayer:_onCancelClick( ... )
	self:animationToClose()
end


function CrusadeRankListLayer:_updateRankList(data)

	if not data or type(data) ~= "table" then return end

	local myRank = 0
	local rankCount = 0

	if data.users and #data.users > 0 then

		local rankData = data.users

		local sortFunc = function(a,b)
			--sp1 --> pet_points
			if not a.sp1 then
				return false
			elseif not b.sp1 then
				return true
			else
	        	return a.sp1 > b.sp1
	        end
    	end

    	table.sort(rankData,sortFunc)
    	rankCount = #rankData

    	for i=1, rankCount do
    		if rankData[i].id == G_Me.userData.id and tostring(rankData[i].sid) == tostring(G_PlatformProxy:getLoginServer().id) then
    			myRank = i
    			break
    		end
    	end

		if not self._rankLayer then 
			local panel = self:getPanelByName("Panel_ranklist")
			if panel == nil then
				return 
			end

			self._rankLayer = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		    	self._rankLayer:setCreateCellHandler(function ( list, index)
		    	    return require("app.scenes.crusade.CrusadeRankListItem").new(list, index)
		    	end)
		    	self._rankLayer:setUpdateCellHandler(function ( list, index, cell)
		    		if cell then
		    			cell:updateItem(rankData[index+1], index+1)
		    		end
		    	end)    	
		end

		self._rankLayer:reloadWithLength(rankCount)

	end

	self:showWidgetByName("Label_no_rank", rankCount==0)
	self:showTextWithLabel("Label_rank_value", myRank == 0 and G_lang:get("LANG_CRUSADE_NOT_IN_RANK") or G_lang:get("LANG_CRUSADE_MY_RANK_NUM",{rank=myRank}) )
	self:showTextWithLabel("Label_max_points_value", G_Me.crusadeData:getMaxPoints())
	self:showTextWithLabel("Label_my_points_value", G_Me.crusadeData:getCurPoints())
end


return CrusadeRankListLayer


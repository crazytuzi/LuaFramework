-- 

local LegionNewChapterRewardLayer = class("LegionNewChapterRewardLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require ("app.cfg.corps_dungeon_chapter_info")

function LegionNewChapterRewardLayer.show( ... )
	local layer = LegionNewChapterRewardLayer.new("ui_layout/legion_DungeonNewAwardList.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function LegionNewChapterRewardLayer:ctor(json, color, ... )
	self.super.ctor(self, json, color)

	self._listView = nil
end

function LegionNewChapterRewardLayer:onLayerEnter(  )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	EffectSingleMoving.run(self, "smoving_bounce")

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_CHAPER_AWARD, self._onRewards, self)
	
	self._curChapterIndex = G_Me.legionData:getNewCurrentChapter()
	local chapterInfo = corps_dungeon_chapter_info.get(self._curChapterIndex)
	self:getLabelByName("Label_jinduDes"):setText(G_lang:get("LANG_NEW_LEGION_JINDU"))
	self:getLabelByName("Label_jinduTxt"):setText(G_lang:get("LANG_LEGION_DUNGEON_MAP_TITLE_FORMAT",{chapterIndex=self._curChapterIndex,chapterName=chapterInfo.name}))

	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:animationToClose()
	end)
	self:registerBtnClickEvent("Button_TopClose", function ( ... )
		self:animationToClose()
	end)

	self:_initListView()
end

function LegionNewChapterRewardLayer:_initListView(  )
	if not self._listView then
		local panel = self:getPanelByName("member_ranklist")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self._listView:setCreateCellHandler(function ( list, index )
			return require("app.scenes.legion.LegionNewChapterRewardCell").new()
		end)
		self._listView:setUpdateCellHandler(function ( list, index, cell )
			local awardData = G_Me.legionData:getNewChapterAwardData()
			cell:updateCell(awardData[index+1])
		end)

		self._listView:initChildWithDataLength(#G_Me.legionData:getNewChapterAwardData())
	end 
end

function LegionNewChapterRewardLayer:onLayerExit(  )
	
end

-- 成就奖励
function LegionNewChapterRewardLayer:_onRewards( data )
	if data.ret == 1 then
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
	    	uf_notifyLayer:getModelNode():addChild(_layer, 1000)
	    end   

	    self._listView:reloadWithLength(#G_Me.legionData:getNewChapterAwardData()) 
end

return LegionNewChapterRewardLayer
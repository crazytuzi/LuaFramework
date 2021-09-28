--LegionNewDungeonItem.lua
local EffectNode = require "app.common.effects.EffectNode"

local LegionNewDungeonItem = class("LegionNewDungeonItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_LegionNewDungeonItem.json")
end)

function LegionNewDungeonItem:ctor( ... )
	self:enableLabelStroke("Label_chapter_1", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_chapter_2", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_chapter_3", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_chapter_4", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_Pass1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_Pass2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_Pass3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_Pass4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_text_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_text_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_text_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_text_4", Colors.strokeBrown, 1 )

	if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local effect = require("app.common.effects.EffectNode").new("effect_fubengditu")
    	self:addNode(effect, 10,10)
    	effect:play()
    	effect:setPosition(ccp(320,570))
    end
end

function LegionNewDungeonItem:updateItem( cellIndex, curChapterIndex, validChapter, maxChapterIndex )
	if type(cellIndex) ~= "number" or type(maxChapterIndex) ~= "number" then 
		return __LogError("LegionNewDungeonItem: wrong cellIndex:%d, maxChapterIndex:%d",
			cellIndex or -1, maxChapterIndex or 0)
	end

--__Log("cellIndex:%d, curChapterIndex:%d, validChapter:%d, maxChapterIndex:%d", 
--	cellIndex, curChapterIndex, validChapter, maxChapterIndex)
	if self.tips then
		self.tips:removeFromParentAndCleanup(true)
		self.tips = nil
	end

	curChapterIndex = curChapterIndex or 1
	local startChapterIndex = cellIndex*4
	local chapterData = G_Me.legionData:getNewChapterData()
	for loopi = 1, 4, 1 do 
		local localChapterIndex = startChapterIndex + loopi
		local isNextChapter = (localChapterIndex == validChapter + 1)
		local isCurChapter = (localChapterIndex == curChapterIndex)
		local isPassedChapter = ((localChapterIndex <= validChapter) and (localChapterIndex ~= curChapterIndex))
		local chapterInfo = corps_dungeon_chapter_info.get(localChapterIndex)
		local chapterData = G_Me.legionData:getNewChapterInfo(localChapterIndex)
		local canEnter = (chapterData ~= nil)
		local isOpen = G_Me.legionData:getDungeonOpen(localChapterIndex)
		local isUnRealChapter = (not chapterInfo) or (chapterInfo.dungeon_1 == 0)

		--__Log("loopi:%d, startChapterIndex:%d, chapterIndex:%d, isNextChapter:%d, isCurChapter:%d, isPassedChapter:%d",
		--	loopi, startChapterIndex, localChapterIndex, isNextChapter and 1 or 0, isCurChapter and 1 or 0, isPassedChapter and 1 or 0)
		self:showWidgetByName("ImageView_City"..loopi, (isNextChapter or isCurChapter or isPassedChapter) and not isUnRealChapter)
		self:showWidgetByName("ImageView_Po"..loopi, isPassedChapter)
		self:showWidgetByName("Image_progress_"..loopi, canEnter)
		self:showWidgetByName("Label_chapter_"..loopi, isNextChapter or isCurChapter or isPassedChapter)
		self:showWidgetByName("Panel_WuJiangZhuan"..loopi, (isNextChapter and not isUnRealChapter) or isCurChapter)

		local cityImg = self:getImageViewByName("ImageView_City"..loopi)
		if cityImg and cityImg:isVisible() then 
			local heroPath = G_Path.getLegionChapterIcon(not isUnRealChapter and chapterInfo.base_id or 1)
	    		cityImg:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
			cityImg:showAsGray(isNextChapter)
		end

		if not isUnRealChapter then
			self:showTextWithLabel("Label_chapter_"..loopi, G_lang:get("LANG_LEGION_DUNGEON_MAP_TITLE_FORMAT", 
    				{chapterIndex = localChapterIndex, chapterName = chapterInfo and chapterInfo.name or ""}) )
		else
			self:showTextWithLabel("Label_chapter_"..loopi, "")
		end
		
		local tipText = ""
		if isUnRealChapter then
			tipText = G_lang:get("LANG_LEGION_NOT_COMPLETE_DUNGEON")
			-- self:showTextWithLabel("Label_Pass"..loopi, tipText)
		elseif not isOpen then
			tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_1",{levelValue=chapterInfo.open_level})
			self:showTextWithLabel("Label_Pass"..loopi, tipText)
		elseif not canEnter and not isPassedChapter and chapterInfo then
			local prefChapter = corps_dungeon_chapter_info.get(chapterInfo.open_id)
			tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_2", {chapterName = prefChapter and prefChapter.name or ""})
			self:showTextWithLabel("Label_Pass"..loopi, tipText)
		-- elseif isNextChapter and chapterInfo then
		-- 	local prefChapter = corps_dungeon_chapter_info.get(chapterInfo.open_id)
		-- 	tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_2", {chapterName = prefChapter and prefChapter.name or ""})
		-- 	self:showTextWithLabel("Label_Pass"..loopi, tipText)
		elseif isCurChapter then
			self:showTextWithLabel("Label_Pass"..loopi, G_lang:get("LANG_NEW_LEGION_ATTACK_TIP"))
		elseif canEnter then
			
		elseif not canEnter then
			tipText = G_lang:get("LANG_NEW_LEGION_HAS_FINISHED")
		end

		self:showWidgetByName("Image_Tips"..loopi, G_Me.legionData:getNewChapterAwardNeedTip(localChapterIndex) )

		local progress = 0
		if canEnter then 
			if chapterData then
				progress = chapterData.max_hp > 0 and (chapterData.hp*100)/chapterData.max_hp or 0
				progress = 100 - progress
				self:showTextWithLabel("Label_progress_text_"..loopi, string.format("%.0f%%", progress))
			end
			local progressBar = self:getLoadingBarByName("ProgressBar_attack_progress_"..loopi)
			if progressBar then 
				progressBar:runToPercent(progress, 0.2)
			end
		end

		if isCurChapter or isPassedChapter then 
			local statusImg = self:getImageViewByName("Image_status_"..loopi)
			if statusImg then 
				statusImg:loadTexture((isCurChapter and progress < 100) and "ui/text/txt/jt_gongda.png" or "ui/text/txt/zxfb_tongguan.png")
			end
		end

		if isCurChapter and G_Me.legionData:getDugeonEndTime() > 0 then
			-- self.tips:setScale(1.5)
			self.tips = EffectNode.new("effect_knife", 
			    function(event, frameIndex)
			        if event == "finish" then
			     
			        end
			    end
			)
			self.tips:play()
			self.tips:setVisible(true)
			self:getImageViewByName("ImageView_City"..loopi):addNode(self.tips) 
			self.tips:setPosition(ccp(0,50))
			self.tips:setZOrder(10)
		end
		for i = 1, 3 do
			self:registerWidgetClickEvent("Panel_Click" .. loopi .."_".. i, function ( ... )
				self:_onDungeonClick(localChapterIndex, isNextChapter, isCurChapter, canEnter,isOpen, tipText)
			end)
		end
	end
end

function LegionNewDungeonItem:_onDungeonClick( chapterIndex, isNextChapter, isCurChapter, canEnter,isOpen, tipText )
	if isNextChapter or not canEnter or not isOpen then 
		return G_MovingTip:showMovingTip(tipText or "")
	end

	if canEnter then 
		if G_Me.legionData:getAwardEndTime() > 0 then
			uf_sceneManager:replaceScene(require("app.scenes.legion.LegionNewMapScene").new( chapterIndex ))
		else
			G_MovingTip:showMovingTip(G_lang:get("LANG_NEW_LEGION_TIME_HAS_FINISHED"))
		end
	end
end

return LegionNewDungeonItem

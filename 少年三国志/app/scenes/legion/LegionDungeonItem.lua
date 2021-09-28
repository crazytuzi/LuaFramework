--LegionDungeonItem.lua


local LegionDungeonItem = class("LegionDungeonItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_LegionDungeonItem.json")
end)

function LegionDungeonItem:ctor( ... )
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

function LegionDungeonItem:updateItem( cellIndex, curChapterIndex, validChapter, maxChapterIndex )
	if type(cellIndex) ~= "number" or type(maxChapterIndex) ~= "number" then 
		return __LogError("LegionDungeonItem: wrong cellIndex:%d, maxChapterIndex:%d",
			cellIndex or -1, maxChapterIndex or 0)
	end

--__Log("cellIndex:%d, curChapterIndex:%d, validChapter:%d, maxChapterIndex:%d", 
--	cellIndex, curChapterIndex, validChapter, maxChapterIndex)
	curChapterIndex = curChapterIndex or 1
	local startChapterIndex = cellIndex*4
	local corpChapters = G_Me.legionData:getCorpChapters()
	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	for loopi = 1, 4, 1 do 
		local localChapterIndex = startChapterIndex + loopi
		local isNextChapter = (localChapterIndex == validChapter + 1)
		local isCurChapter = (localChapterIndex == curChapterIndex)
		local isPassedChapter = ((localChapterIndex <= validChapter) and (localChapterIndex ~= curChapterIndex))
		local chapterInfo = corps_dungeon_chapter_info.get(localChapterIndex)
		local isUnRealChapter = (not chapterInfo) or (chapterInfo.dungeon_1 == 0)

		--__Log("loopi:%d, startChapterIndex:%d, chapterIndex:%d, isNextChapter:%d, isCurChapter:%d, isPassedChapter:%d",
		--	loopi, startChapterIndex, localChapterIndex, isNextChapter and 1 or 0, isCurChapter and 1 or 0, isPassedChapter and 1 or 0)
		self:showWidgetByName("ImageView_City"..loopi, isNextChapter or isCurChapter or isPassedChapter)
		self:showWidgetByName("ImageView_Po"..loopi, isCurChapter)
		self:showWidgetByName("Image_progress_"..loopi, isCurChapter)
		self:showWidgetByName("Label_chapter_"..loopi, isNextChapter or isCurChapter or isPassedChapter)
		self:showWidgetByName("Panel_WuJiangZhuan"..loopi, (isNextChapter or isPassedChapter) and not isUnRealChapter)

		local cityImg = self:getImageViewByName("ImageView_City"..loopi)
		if cityImg and cityImg:isVisible() then 
			local heroPath = G_Path.getLegionChapterIcon(chapterInfo and chapterInfo.base_id or 1)
	    	cityImg:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 

			cityImg:showAsGray(isNextChapter)
		end

		if isCurChapter or isPassedChapter or isNextChapter then
			self:showTextWithLabel("Label_chapter_"..loopi, G_lang:get("LANG_LEGION_DUNGEON_MAP_TITLE_FORMAT", 
    		{chapterIndex = localChapterIndex, chapterName = chapterInfo and chapterInfo.name or ""}) )
		end
		
		local tipText = ""
		if isUnRealChapter then
			tipText = G_lang:get("LANG_LEGION_NOT_COMPLETE_DUNGEON")
		elseif isNextChapter and chapterInfo and corpChapters and detailCorp then
			if detailCorp.level < chapterInfo.open_level then 
				tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_1", {levelValue = chapterInfo.open_level})
			elseif corpChapters.chapters and chapterInfo.open_id > 0 and not corpChapters.chapters[chapterInfo.open_id] then
				local prefChapter = corps_dungeon_chapter_info.get(chapterInfo.open_id)
				tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_2", {chapterName = prefChapter and prefChapter.name or ""})
			elseif corpChapters.today_chid ~= self._enemyChapterIndex then 
				tipText = G_lang:get("LANG_LEGION_CHAPTER_NOT_SETTING")
			end
			self:showTextWithLabel("Label_Pass"..loopi, tipText)
		elseif isPassedChapter then
			tipText = G_lang:get("LANG_LEGION_CHAPTER_NOT_SETTING")
			self:showTextWithLabel("Label_Pass"..loopi, tipText)
		end

		if isCurChapter then 
			self:showWidgetByName("Image_Tips"..loopi, G_Me.legionData:canHitEgg() or G_Me.legionData:hasAcquireFinishAward())
		end

		local progress = 0
		if isCurChapter then 
			if corpChapters then
				progress = corpChapters.max_hp > 0 and (corpChapters.hp*100)/corpChapters.max_hp or 100
				progress = 100 - progress
				self:showTextWithLabel("Label_progress_text_"..loopi, string.format("%.0f%%", progress))
			end
			local progressBar = self:getLoadingBarByName("ProgressBar_attack_progress_"..loopi)
			if progressBar then 
				progressBar:runToPercent(progress, 0.2)
			end
		-- elseif isPassedChapter then
		-- 	self:showTextWithLabel("Label_progress_text_"..loopi, "0%")
		-- 	local progressBar = self:getLoadingBarByName("ProgressBar_attack_progress_"..loopi)
		-- 	if progressBar then 
		-- 		progressBar:setPercent(0)
		-- 	end
		end

		if isCurChapter or isPassedChapter then 
			local statusImg = self:getImageViewByName("Image_status_"..loopi)
			if statusImg then 
				statusImg:loadTexture((isCurChapter and progress < 100) and "ui/text/txt/jt_gongda.png" or "ui/text/txt/zxfb_tongguan.png")
			end
		end

		for i = 1, 3 do
			self:registerWidgetClickEvent("Panel_Click" .. loopi .."_".. i, function ( ... )
				self:_onDungeonClick(localChapterIndex, isNextChapter, isCurChapter, isPassedChapter, tipText)
			end)
		end
	end
end

function LegionDungeonItem:_onDungeonClick( chapterIndex, isNextChapter, isCurChapter, isPassedChapter, tipText )
	if isNextChapter or isPassedChapter then 
		return G_MovingTip:showMovingTip(tipText or "")
	end

	if isCurChapter then 
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionMapScene").new( chapterIndex ))
	end
end

return LegionDungeonItem

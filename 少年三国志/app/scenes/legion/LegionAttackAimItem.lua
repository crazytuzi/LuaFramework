--LegionAttackAimItem.lua

require("app.cfg.corps_dungeon_chapter_info")

local LegionAttackAimItem = class("LegionAttackAimItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonAimItem.json")
end)

function LegionAttackAimItem:ctor( ... )
	self:enableLabelStroke("Label_legion_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title", Colors.strokeBrown, 1 )
end

function LegionAttackAimItem:updateItem( chapterIndex )
	if type(chapterIndex) ~= "number" then 
		chapterIndex = 1 
	end

	local chapterInfo = corps_dungeon_chapter_info.get(chapterIndex)
	if not chapterInfo then 
		return __LogError("[LegionAttackAimItem] wrong chapter index:%d", chapterIndex or 0)
	end

	self:showTextWithLabel("Label_legion_name", G_lang:get("LANG_LEGION_DUNGEON_MAP_TITLE_FORMAT", 
    		{chapterIndex = chapterIndex, chapterName = chapterInfo and chapterInfo.name or ""}))
	self:showTextWithLabel("Label_attack_value", chapterInfo.fight)
	self:showTextWithLabel("Label_title", G_lang:get("LANG_LEGION_CHAPTER_INDEX_FORMAT", {indexValue = chapterIndex}))

	--local knightInfo = knight_info.get(chapterInfo.base_id)
	local img = self:getImageViewByName("Image_legion_icon")
	if img then 
		local heroPath = G_Path.getLegionChapterIcon(chapterInfo.base_id)
		--local heroPath = G_Path.getKnightIcon(knightInfo.res_id)
    	img:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
    	img:setScale(0.6)
	end

	local tipText = ""
	local unOpen = false
	local prefChapter = corps_dungeon_chapter_info.get(chapterInfo.open_id)
	local corpChapters = G_Me.legionData:getCorpChapters()
	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	if corpChapters and detailCorp then 
		if detailCorp.level < chapterInfo.open_level then 
			unOpen = true
			tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_1", {levelValue = chapterInfo.open_level})
		elseif corpChapters.chapters and chapterInfo.open_id > 0 and
		 (not corpChapters.chapters[chapterInfo.open_id] or not corpChapters.chapters[chapterInfo.open_id]) then
			unOpen = true
			tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_2", {chapterName = prefChapter and prefChapter.name or ""})
		--elseif corpChapters.today_chid ~= chapterIndex then 
		--	unOpen = true
		--	tipText = G_lang:get("LANG_LEGION_CHAPTER_NOT_SETTING")
		end
	end

	self:showWidgetByName("CheckBox_choose", not unOpen)
	self:showWidgetByName("Label_tip", unOpen)
	self:showTextWithLabel("Label_tip", tipText)

	if not unOpen then 
		local check = self:getCheckBoxByName("CheckBox_choose")
		if check then 
			check:setCheckDisabled(true)
			check:setSelectedState(corpChapters.chapter_id == chapterIndex)
		end
	end

	--self:enableWidgetByName("CheckBox_choose", detailCorp and detailCorp.position == 1)

	self:registerCheckboxEvent("CheckBox_choose", function ( widget, checkType, selected )
		if not detailCorp or detailCorp.position ~= 1 then 
			if selected then 
				widget:setSelectedState(false)
			end
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CHANGE_BATTLE_AIM_TIP"))
		end
		self:_onCheckboxEvent(selected, chapterIndex)
	end)
end

function LegionAttackAimItem:_onCheckboxEvent( selected, chapterIndex )
	if selected and type(chapterIndex) == "number" then 
		G_HandlersManager.legionHandler:sendSetCorpChapterId(chapterIndex)
	end
end

return LegionAttackAimItem



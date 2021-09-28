--LegionEnemyItem.lua

require("app.cfg.knight_info")

local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"
local KnightPic = require "app.scenes.common.KnightPic"
require("app.cfg.corps_dungeon_chapter_info")
local knightPic = require("app.scenes.common.KnightPic")

local LegionEnemyItem = class("LegionEnemyItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DugneonItem.json")
end)

function LegionEnemyItem:ctor( ... )
	self._enemyChapterIndex = 0
	self._enemyPic = nil
	self._effectNode = nil
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
end

function LegionEnemyItem:updateItem( enemyIndex, clickEnable, drop )
	self._enemyChapterIndex = enemyIndex or 0

	local chapterInfo = corps_dungeon_chapter_info.get(self._enemyChapterIndex)
	if not chapterInfo then 
		return __LogError("[LegionEnemyItem] wrong enemyIndex:%d", enemyIndex or -1)
	end

	local panel = self:getWidgetByName("Panel_container")
	if not panel then 
		return 
	end
	panel:removeAllChildren()

	local isLock = false
	local finishPreview = true
	local isNotSetting = false
	local tipText = ""
	local corpChapters = G_Me.legionData:getCorpChapters()
	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	if corpChapters and detailCorp then 
		
		if detailCorp.level < chapterInfo.open_level then 
			isLock = true 
			tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_1", {levelValue = chapterInfo.open_level})
		elseif corpChapters.chapters and chapterInfo.open_id > 0 and not corpChapters.chapters[chapterInfo.open_id] then
			finishPreview = false
			tipText = G_lang:get("LANG_LEGION_CHAPTER_LOCK_2", {levelValue = prefChapter and prefChapter.name or ""})
		elseif corpChapters.today_chid ~= self._enemyChapterIndex then 
			isNotSetting = true
			tipText = G_lang:get("LANG_LEGION_CHAPTER_NOT_SETTING")
		end
	end

	self:showWidgetByName("Image_lock", isLock or not finishPreview)

	local knightInfo = knight_info.get(chapterInfo.base_id)
	if knightInfo then
		self._enemyPic = knightPic.createKnightButton(knightInfo.res_id, panel, "knight_button", self, function ( widget )
				self:_onEnemyChapterClick( self._enemyChapterIndex, isLock, finishPreview, isNotSetting, tipText )
			end, true, true)

		if self._enemyPic then 
			self._enemyPic:setTouchEnabled(clickEnable)
		end
	end

	if drop then
		self:_dropNewKnight(chapterInfo.base_id, function ( ... ) end)
	end

	self:breathKnight( clickEnable )
	--self:_dropKnightPic(chapterInfo.image, panel:getScale(), panel, 0, 0, function ( ... )
	--	__Log("_dropKnightPic")
	--end)

	self:showTextWithLabel("Label_name", chapterInfo.name)
end

function LegionEnemyItem:breathKnight( breath )
	if breath then 
		if not self._effectNode then 
			local panel = self:getWidgetByName("Panel_container")
			if not panel then 
				return 
			end
			local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        	self._effectNode = EffectSingleMoving.run(panel, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
        end
        self._effectNode:play()
    else
    	if self._effectNode then
    		self._effectNode:stop()
    		self._effectNode = nil
    	end
	end
end

function LegionEnemyItem:_dropNewKnight( baseId, func )
    local equipPanel = self:getWidgetByName("Image_border")
	local panel = self:getWidgetByName("Panel_container")
	if not panel or not equipPanel then
		return func and func()
	end

    self:showWidgetByName("Panel_container", false)
	local size = panel:getSize()
	local centerPtx, centerPty = panel:getPosition()
	--centerPtx, centerPty = equipPanel:convertToNodeSpaceXY(centerPtx, centerPty)
   -- centerPty = centerPty + 45
	local KnightAppearEffect = require("app.scenes.hero.KnightAppearEffect")
	local ani = nil 
    ani = KnightAppearEffect.new(baseId, function()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.KNIGHT_DOWN)
    	if func then 
    		func() 
    	end
    	if ani then
    		ani:removeFromParentAndCleanup(true)
    	end
    	self:showWidgetByName("Panel_container", true)
    end)
    ani:setScale(panel:getScale())
    ani:setPositionXY(centerPtx, centerPty)
    ani:play()
    equipPanel:addNode(ani)
end

function LegionEnemyItem:setEnemyEnable( enable )
	if self._enemyPic then 
		self._enemyPic:setTouchEnabled(enable)
	end
end

function LegionEnemyItem:getEnemyChapterIndex( ... )
	return self._enemyChapterIndex
end

function LegionEnemyItem:_onEnemyChapterClick( chapterIndex, isLock, finishPreview, isNotSetting, tipText )
	if isLock or not finishPreview or isNotSetting then 
		return G_MovingTip:showMovingTip(tipText)
	end

	uf_sceneManager:replaceScene(require("app.scenes.legion.LegionMapScene").new( chapterIndex ))
end

return LegionEnemyItem

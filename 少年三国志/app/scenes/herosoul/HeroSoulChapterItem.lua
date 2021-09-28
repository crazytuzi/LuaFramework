local HeroSoulChapterItem = class("HeroSoulChapterItem", function()
	return CCSItemCellBase:create("ui_layout/herosoul_ChapterItem.json")
end)

require("app.cfg.ksoul_group_chapter_info")

function HeroSoulChapterItem:ctor()
	self._chapterIndex = 0
	self._isUnlocked   = false
	self._nameLabel    = self:getLabelBMFontByName("BitmapLabel_ChapterName")

	self:enableLabelStroke("Label_ActivatedDesc", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ChapterNo", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Progress", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Cond_1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Cond_2", Colors.strokeBrown, 1)

	self:registerWidgetClickEvent("Image_Bg", handler(self, self._onClick))
end

function HeroSoulChapterItem:update(chapterIndex)
	self._chapterIndex = chapterIndex
	local chapterInfo = ksoul_group_chapter_info.indexOf(chapterIndex)

	-- set background
	local bgImage = "ui/herosoul/lzt_bg" .. chapterInfo.image .. ".png"
	self:getImageViewByName("Image_Bg"):loadTexture(bgImage)

	-- set star color
	local starColor = chapterInfo.star_color
	local r = starColor / (2 ^ 16)
	local g = (starColor % (2 ^ 16)) / (2 ^ 8)
	local b = starColor % (2 ^ 8)
	self:getImageViewByName("Image_StarBg"):setColor(ccc3(r, g, b))

	-- set chapter name
	self._nameLabel:setText(chapterInfo.name)
	self:showTextWithLabel("Label_ChapterNo", G_lang:get("LANG_DUNGEON_CHAPTER_INDEX", {num = chapterIndex}))

	-- set locked or unlocked info
	self._isUnlocked = G_Me.heroSoulData:isChapterUnlocked(chapterInfo.id)
	self:showWidgetByName("Image_ProgressBg", self._isUnlocked)
	self:showWidgetByName("Label_ActivatedDesc", self._isUnlocked)
	self:showWidgetByName("Panel_Mask", not self._isUnlocked)
	self:showWidgetByName("Panel_Lock", not self._isUnlocked)

	if self._isUnlocked then
		self:_updateUnlockedInfo()
	else
		self:_updateLockedInfo(chapterInfo)
	end

	-- update red tip
	self:_updateRedTip()
end

function HeroSoulChapterItem:_updateUnlockedInfo()
	local totalNum = G_Me.heroSoulData:getTotalChartsNumByChap(self._chapterIndex)
	local activatedNum = G_Me.heroSoulData:getActivatedChartsNumByChap(self._chapterIndex)
	self:showTextWithLabel("Label_Progress", activatedNum .. "/" .. totalNum)
	self:getLoadingBarByName("ProgressBar_Chapter"):setPercent(activatedNum / totalNum * 100)
end

function HeroSoulChapterItem:_updateLockedInfo(chapterInfo)
	local strCond1 = G_lang:get("LANG_HERO_SOUL_CHAPTER_CONDITION_1", {level = chapterInfo.level})
	self:showTextWithLabel("Label_Cond_1", strCond1)

	local strCond2 = G_lang:get("LANG_HERO_SOUL_CHAPTER_CONDITION_2", {chapter = chapterInfo.pre_chapter, num = chapterInfo.group_num})
	self:showTextWithLabel("Label_Cond_2", strCond2)
end

function HeroSoulChapterItem:_updateRedTip()
	local redTip = self:getImageViewByName("Image_RedTip")
	if not self._isUnlocked then
		redTip:setVisible(false)
		return
	end

	local showRedTip = G_Me.heroSoulData:hasChartToActivateByChap(self._chapterIndex)
	redTip:setVisible(showRedTip)

	if showRedTip then
		local nameLabelSize = self._nameLabel:getContentSize()
		redTip:setPositionXY(nameLabelSize.width / 2, nameLabelSize.height / 2)
	end
end

function HeroSoulChapterItem:_onClick()
	if self._isUnlocked then
		uf_sceneManager:getCurScene():goToLayer("HeroSoulChartList", true, self._chapterIndex)
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_HERO_SOUL_CHAPTER_LOCKED"))
	end
end

return HeroSoulChapterItem
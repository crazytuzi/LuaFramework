	--LegionDungeionLayer.lua

require("app.cfg.corps_dungeon_chapter_info")

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local LegionDungeionLayer = class("LegionDungeionLayer", UFCCSNormalLayer)

LegionDungeionLayer.ENEMY_OPACITY_HALF = 153

function LegionDungeionLayer.create( ... )
	return LegionDungeionLayer.new("ui_layout/legion_DungeonLayer.json")
end

function LegionDungeionLayer:ctor( ... )
	self._maxMoveXDist = 0
	self._maxMoveYOffset = 0
	self._maxMoveXOffset = 0
	self._hasDoMove = false

	self._lastStartX = 0
	self._moveStartX = 0
	self._enemysArr = {}
	self._enemyPosArr = {}

	self._enemyInit = false
	self._defaultEnemyIndex = 1
	self._maxEnemyChapter = 0
	self.super.ctor(self, ...)
end

function LegionDungeionLayer:onLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_status", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_text", Colors.strokeBrown, 1 )

	self:registerBtnClickEvent("Button_return", handler(self, self._onBackClick))
	self:registerBtnClickEvent("Button_help", handler(self, self._onHelpClick))
	self:registerBtnClickEvent("Button_attack", handler(self, self._onAttackClick))

	self:registerWidgetTouchEvent("Panel_touch", function ( widget, touchType )
		self:_onTouchPanelTouched(widget, touchType)
	end)
	self:registerBtnClickEvent("Button_left", function ( ... )
		self:_onEnemyChapterSwitch(true)
	end)
	self:registerBtnClickEvent("Button_right", function ( ... )
		self:_onEnemyChapterSwitch(false)
	end)

	self:_updateCorpDetail()
	self:_initTouchParams()
	self:_onChapterUpdate()

	--if not G_Me.legionData:hasCorpChapterInit() then 
		G_HandlersManager.legionHandler:sendGetCorpChapter()
	--end
end

function LegionDungeionLayer:onLayerEnter( ... )
     self:callAfterFrameCount(1, function ( ... )
    	self:adapterWidgetHeight("Panel_bottom", "Panel_top", "", 0, 0)
    	if G_Me.legionData:hasCorpChapterInit() then 
     		self:_initEnemys()
     		--self:_onChapterUpdate()
     	end
     end)

     G_GlobalFunc.showDayEffect(G_Path.DAY_NIGHT_EFFECT.MAIN_SCENE, self:getWidgetByName("Panel_effect"))
     uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CHATER_INFO, self._onChapterUpdate, self)
     uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)
end

function LegionDungeionLayer:_onBackClick( ... )
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end
end

function LegionDungeionLayer:_onHelpClick( ... )
	require("app.scenes.legion.LegionHelpLayer").show(G_lang:get("LANG_LEGION_HELP_DUNGEON_TITLE"), G_lang:get("LANG_LEGION_HELP_DUNGEON"))
end

function LegionDungeionLayer:_onEnemyChapterSwitch( moveLeft )
	self._moveStartX = 0
	self:_onFinishMoveEnemys( moveLeft and self._maxMoveXDist or -self._maxMoveXDist)
end

function LegionDungeionLayer:_onAttackClick( ... )
	require("app.scenes.legion.LegionAttackAimLayer").show()
end

function LegionDungeionLayer:_updateCorpDetail( ... )
	local detailCorp = G_Me.legionData:getCorpDetail() or {}

	self:showTextWithLabel("Label_level", detailCorp.level or 1)
	self:showTextWithLabel("Label_name", detailCorp.name or "")
	local maxExp = 0
	local curExp = 0
	if detailCorp then 
		local corpsInfo = corps_info.get(detailCorp.level)
		maxExp = corpsInfo and corpsInfo.exp or 0
        curExp = detailCorp.exp
	end
	self:showTextWithLabel("Label_progress", curExp.."/"..maxExp)
	local progressBar = self:getLoadingBarByName("ProgressBar_progrss")
	if progressBar then 
		progressBar:runToPercent(maxExp > 0 and (curExp*100)/maxExp or 0, 0.2)
	end
end

function LegionDungeionLayer:_initEnemys( ... )
	if self._enemyInit then 
		return 
	end
	local enemyPanel = self:getWidgetByName("Panel_enemys")
	if not enemyPanel then 
		return 
	end

	self._enemyInit = true
	local leftPanel = self:getWidgetByName("Panel_left_enemy")
	if leftPanel then 
		local enemyItem = require("app.scenes.legion.LegionEnemyItem").new()
		if enemyItem then 
			local posx, posy = leftPanel:getPosition()
			self._enemyPosArr[1] = {posx - self._maxMoveXOffset, posy, LegionDungeionLayer.ENEMY_OPACITY_HALF, leftPanel:getScale()}
			self._enemyPosArr[2] = {posx, posy, LegionDungeionLayer.ENEMY_OPACITY_HALF, leftPanel:getScale()}
			enemyItem:setPositionXY(posx, posy)
			enemyItem:setScale(leftPanel:getScale())
			enemyItem:setCascadeOpacityEnabled(true)
			enemyItem:setOpacity(LegionDungeionLayer.ENEMY_OPACITY_HALF)
			enemyPanel:addChild(enemyItem)
			self._enemysArr[2] = enemyItem

			enemyItem = require("app.scenes.legion.LegionEnemyItem").new()
			if enemyItem then 
				enemyItem:setPositionXY(posx - self._maxMoveXOffset, posy)
				enemyItem:setScale(leftPanel:getScale())
				enemyItem:setCascadeOpacityEnabled(true)
				enemyPanel:addChild(enemyItem)
				self._enemysArr[1] = enemyItem
			end
		end
	end

	local rightPanel = self:getWidgetByName("Panel_right_enemy")
	if rightPanel then 
		local enemyItem = require("app.scenes.legion.LegionEnemyItem").new()
		if enemyItem then 
			local posx, posy = rightPanel:getPosition()
			self._enemyPosArr[5] = {posx + self._maxMoveXOffset, posy, LegionDungeionLayer.ENEMY_OPACITY_HALF, rightPanel:getScale()}
			self._enemyPosArr[4] = {posx, posy, LegionDungeionLayer.ENEMY_OPACITY_HALF, rightPanel:getScale()}
			enemyItem:setPositionXY(posx, posy)
			enemyItem:setScale(rightPanel:getScale())
			enemyItem:setCascadeOpacityEnabled(true)
			enemyItem:setOpacity(LegionDungeionLayer.ENEMY_OPACITY_HALF)
			enemyPanel:addChild(enemyItem)
			self._enemysArr[4] = enemyItem

			enemyItem = require("app.scenes.legion.LegionEnemyItem").new()
			if enemyItem then 
				enemyItem:setPositionXY(posx + self._maxMoveXOffset, posy)
				enemyItem:setScale(leftPanel:getScale())
				enemyItem:setCascadeOpacityEnabled(true)
				enemyPanel:addChild(enemyItem)
				self._enemysArr[5] = enemyItem
			end
		end
	end

	local middlePanel = self:getWidgetByName("Panel_middle_enemy")
	if middlePanel then 
		local enemyItem = require("app.scenes.legion.LegionEnemyItem").new()
		if enemyItem then 
			local posx, posy = middlePanel:getPosition()
			self._enemyPosArr[3] = {posx, posy, 255, 1}
			enemyItem:setPositionXY(posx, posy)
			enemyItem:setScale(middlePanel:getScale())
			enemyItem:setCascadeOpacityEnabled(true)
			enemyPanel:addChild(enemyItem)
			self._enemysArr[3] = enemyItem
		end
	end

	self:_loadAllEnemyItems()
end

function LegionDungeionLayer:_loadAllEnemyItems( ... )
	local maxCount = corps_dungeon_chapter_info.getLength()

	local chapterIndex = 1
	local enemyItem = self._enemysArr[1]
	if enemyItem then 
		chapterIndex = (maxCount*2 + self._defaultEnemyIndex - 2 - 1)%maxCount + 1
		enemyItem:updateItem(chapterIndex, chapterIndex == self._defaultEnemyIndex )
		enemyItem:setOpacity(enemyItem:getOpacity())
		--__Log("loopi:%d, index:%d", 1, )
	end

	enemyItem = self._enemysArr[2]
	if enemyItem then 
		chapterIndex = (maxCount*2 + self._defaultEnemyIndex - 1 - 1)%maxCount + 1
		enemyItem:updateItem(chapterIndex, chapterIndex == self._defaultEnemyIndex)
		enemyItem:setOpacity(enemyItem:getOpacity())
		--__Log("loopi:%d, index:%d", 2, )
	end

	for loopi = 2, 4, 1 do
		chapterIndex = (loopi - 1 + maxCount - 2 + self._defaultEnemyIndex)%maxCount + 1
		local enemyItem = self._enemysArr[loopi + 1]
		enemyItem:updateItem(chapterIndex, chapterIndex == self._defaultEnemyIndex, chapterIndex == self._defaultEnemyIndex)
		enemyItem:setOpacity(enemyItem:getOpacity())
		--__Log("loopi:%d, index:%d", loopi + 1, ())
	end

	self._maxEnemyChapter = maxCount
end

function LegionDungeionLayer:_initTouchParams( ... )
	local touchPanel = self:getWidgetByName("Panel_touch")
	if touchPanel then 
		local size = touchPanel:getSize()
		self._maxMoveXDist = size.width
	end

	local middlePanel = self:getWidgetByName("Panel_middle_enemy")
	local rightPanel = self:getWidgetByName("Panel_right_enemy")
	if middlePanel and rightPanel then 
		local middlePosx, middlePosy = middlePanel:getPosition()
		local rightPosx, rightPosy = rightPanel:getPosition()
		self._maxMoveYOffset = rightPosy - middlePosy
		self._maxMoveXOffset = rightPosx - middlePosx
	end
end

function LegionDungeionLayer:_onTouchPanelTouched( widget, touchType )
	if type(touchType) ~= "number" or not widget then 
		return 
	end

	if touchType == TOUCH_EVENT_BEGAN then 
		self._lastStartX = widget:getTouchStartPos().x
		self._moveStartX = self._lastStartX
		self._hasDoMove = false
	elseif touchType == TOUCH_EVENT_MOVED then 
		if not self._hasDoMove then 
			self:showWidgetByName("Panel_ctrls", false)
		end
		self._hasDoMove = true
		self:_onMoveEnemys(widget:getTouchMovePos())
	elseif touchType == TOUCH_EVENT_ENDED or touchType == TOUCH_EVENT_CANCELED then 
		if self._hasDoMove then
			self:showWidgetByName("Panel_ctrls", true)
			self:_onFinishMoveEnemys(widget:getTouchMovePos().x)
		end
	end
end

function LegionDungeionLayer:_onMoveEnemys( pos )
	local moveOffset = pos.x - self._lastStartX
	--self._lastStartX = pos.x

	self:_doMoveEnemyWithOffset(moveOffset, pos.x - self._moveStartX < 0)
end

function LegionDungeionLayer:_onFinishMoveEnemys( posx )
	local moveOffset = math.abs(posx - self._moveStartX)

	if moveOffset == 0 then 
		return 
	end
	local moveEnemyItem = moveOffset >= self._maxMoveXDist*0.5
	local moveToRight = false
	if moveEnemyItem then 
		moveToRight = posx > self._moveStartX
	end

	if moveEnemyItem then 
		if moveToRight then 
			local tempEnemyItem = self._enemysArr[5]
			self._defaultEnemyIndex = self._enemysArr[2]:getEnemyChapterIndex()
			if self._enemysArr[3] then
				self._enemysArr[3]:breathKnight(false)
			end
			for loopi = 5, 2, -1 do 
				self._enemysArr[loopi] = self._enemysArr[loopi - 1]
				self._enemysArr[loopi]:setEnemyEnable(self._defaultEnemyIndex == self._enemysArr[loopi]:getEnemyChapterIndex())
			end
			if self._enemysArr[3] then
				self._enemysArr[3]:breathKnight(true)
			end
			if tempEnemyItem then 
				local enemyIndex = (self._maxEnemyChapter*2 + self._defaultEnemyIndex - 2 - 1)%self._maxEnemyChapter + 1
				tempEnemyItem:updateItem( enemyIndex, enemyIndex == self._defaultEnemyIndex )
			end
			self._enemysArr[1] = tempEnemyItem
		else
			local tempEnemyItem = self._enemysArr[1]
			self._defaultEnemyIndex = self._enemysArr[4]:getEnemyChapterIndex()
			if self._enemysArr[3] then
				self._enemysArr[3]:breathKnight(false)
			end
			for loopi = 1, 4, 1 do 
				self._enemysArr[loopi] = self._enemysArr[loopi + 1]
				self._enemysArr[loopi]:setEnemyEnable(self._defaultEnemyIndex == self._enemysArr[loopi]:getEnemyChapterIndex())
			end
			if self._enemysArr[3] then
				self._enemysArr[3]:breathKnight(true)
			end
			if tempEnemyItem then 
				local enemyIndex = (self._maxEnemyChapter +1 + self._defaultEnemyIndex)%self._maxEnemyChapter + 1
				tempEnemyItem:updateItem( enemyIndex, enemyIndex == self._defaultEnemyIndex )
			end
			self._enemysArr[5] = tempEnemyItem
		end

		self:_updateCurChapterInfo()
	end

	for loopi = 1, 5, 1 do 
		if self._enemysArr[loopi] then 
			local pos = self._enemyPosArr[loopi]
			self._enemysArr[loopi]:setPositionXY(pos[1], pos[2])
			self._enemysArr[loopi]:setScale(pos[4])
			self._enemysArr[loopi]:setOpacity(pos[3])

			--__Log("loopi:%d, index:%d", loopi, self._enemysArr[loopi]:getEnemyChapterIndex())
		end
	end
	

end

function LegionDungeionLayer:_doMoveEnemyWithOffset( offsetx, moveLeft )
	if type(offsetx) ~= "number" or offsetx == 0 then 
		return 
	end

	local moveXFlag = offsetx > 0
	local moveRait = math.abs(offsetx)/self._maxMoveXDist
	if moveRait > 1 then 
		moveRait = 1 
	end
	local moveOffsetx = moveRait * self._maxMoveXOffset
	local moveOffsety = moveRait * self._maxMoveYOffset

	--__Log("offsetx:%d, moveLeft:%d, moveXFlag:%d, moveRait:%f, moveOffsetx:%d, moveOffsety:%d",
		--offsetx, moveLeft and 1 or 0, moveXFlag and 1 or 0, moveRait, moveOffsetx, moveOffsety)
	for loopi = 1, 5, 1 do 
		local moveAimIndex = 0
		local moveYFlag = false
		local shouldMoveY = false
		if loopi == 2 and not moveLeft then 
			shouldMoveY = true
			moveYFlag = false
			moveAimIndex = 1
		elseif loopi == 4 and moveLeft then
			shouldMoveY = true
			moveYFlag = false
			moveAimIndex = -1
		elseif loopi == 3 then 
			shouldMoveY = true
			moveYFlag = true
			moveAimIndex = moveLeft and -1 or 1
		end
		local enemyItem = self._enemysArr[loopi]
		if enemyItem then 
			local posStart = self._enemyPosArr[loopi]
			local scale = posStart[4]
			local opacity = posStart[3]
			local posx, posy = posStart[1], posStart[2]
			local posx = moveXFlag and (posx + moveOffsetx) or (posx - moveOffsetx)
			if shouldMoveY then 
				posy = moveYFlag and (posy + moveOffsety) or (posy - moveOffsety)
				local posEnd = self._enemyPosArr[loopi + moveAimIndex]
				if posEnd then 
					scale = scale + (posEnd[4] - scale) * moveRait
					opacity = opacity + (posEnd[3] - opacity) * moveRait
				end
				if loopi == 2 then 
				end
			end
			enemyItem:setOpacity(opacity)
			enemyItem:setScale(scale)
			enemyItem:setPositionXY(posx, posy)
		end
	end
end

function LegionDungeionLayer:_onChapterUpdate( ... )
	local chapterInfo = G_Me.legionData:getCorpChapters()
	if not self._enemyInit then 
		if chapterInfo then
			self._defaultEnemyIndex = chapterInfo.today_chid or 1
		end
	end

	self:showWidgetByName("Label_count_tip", chapterInfo and true or false)
	if chapterInfo then
		self:showTextWithLabel("Label_count_tip", G_lang:get("LANG_LEGION_FIGHT_MAX_FORMAT", 
				{maxCount = chapterInfo.chapter_count}))
	end
	if G_Me.legionData:hasCorpChapterInit() then 
    	self:_initEnemys()
    end
	self:_updateCurChapterInfo()
end

function LegionDungeionLayer:_updateCurChapterInfo( ... )
	local corpChapters = G_Me.legionData:getCorpChapters()
	if not corpChapters then 
		return 
	end

	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	local _calcChapterStatus = function ( chapterId )
		if type(chapterId) ~= "number" then 
			__LogError("wrong chapterId1:"..chapterId)
			return ""
		end

		local chapterInfo = corps_dungeon_chapter_info.get(chapterId)
		if not chapterInfo then 
			__LogError("wrong chapterId2:"..chapterId)
			return ""
		end


		local prefChapter = corps_dungeon_chapter_info.get(chapterInfo.open_id)
		if detailCorp.level < chapterInfo.open_level then 
			return G_lang:get("LANG_LEGION_CHAPTER_LOCK_1", {levelValue = chapterInfo.open_level})
		elseif corpChapters.chapters and chapterInfo.open_id > 0 and not corpChapters.chapters[chapterInfo.open_id] then 
			return G_lang:get("LANG_LEGION_CHAPTER_LOCK_2", {chapterName = prefChapter and prefChapter.name or ""})
		elseif corpChapters.today_chid == chapterId then 
			return G_lang:get("LANG_LEGION_CHAPTER_FIGHTING")
		else
			return G_lang:get("LANG_LEGION_CHAPTER_NOT_SETTING")
		end
	end

	self:showTextWithLabel("Label_status", _calcChapterStatus(self._defaultEnemyIndex))

	local todayChapter = (corpChapters.today_chid or 1)
	self:showWidgetByName("Image_progress", self._defaultEnemyIndex == todayChapter)
	if todayChapter == self._defaultEnemyIndex and corpChapters then 
		local progress = corpChapters.max_hp > 0 and (corpChapters.hp*100)/corpChapters.max_hp or 0
		progress = progress/1
		self:showTextWithLabel("Label_progress_text", string.format("%.0f%%", progress))
		local progressBar = self:getLoadingBarByName("ProgressBar_attack_progress")
		if progressBar then 
			progressBar:runToPercent(progress, 0.2)
		end
	end
end

return LegionDungeionLayer

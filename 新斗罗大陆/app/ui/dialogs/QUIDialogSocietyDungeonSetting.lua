--
-- Author: Kumo.Wang
-- Date: Thu May 19 17:52:33 2016
-- 军团副本的集火设定界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyDungeonSetting = class("QUIDialogSocietyDungeonSetting", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QUIWidgetSocietyDungeonBoss = import("..widgets.QUIWidgetSocietyDungeonBoss")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSocietyDungeonMap = import("..widgets.QUIWidgetSocietyDungeonMap")

function QUIDialogSocietyDungeonSetting:ctor(options)
	local ccbFile = "ccb/Dialog_society_fuben_chongzhi.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSave", callback = handler(self, QUIDialogSocietyDungeonSetting._onTriggerSave)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, QUIDialogSocietyDungeonSetting._onTriggerReset)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyDungeonSetting._onTriggerClose)},
	}
	QUIDialogSocietyDungeonSetting.super.ctor(self, ccbFile, callBacks, options)

	self._callback = options.callback

	self:_init(options)
end

function QUIDialogSocietyDungeonSetting:viewDidAppear()
	QUIDialogSocietyDungeonSetting.super.viewDidAppear(self)

end

function QUIDialogSocietyDungeonSetting:viewWillDisappear()
	QUIDialogSocietyDungeonSetting.super.viewWillDisappear(self)
end

-- function QUIDialogSocietyDungeonSetting:onTriggerBackHandler()
--     app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
-- end

function QUIDialogSocietyDungeonSetting:_onTriggerSave(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_save) == false then return end
	app.sound:playSound("common_small")
	if self._callback then
		self._callback()
	end
	self:playEffectOut()
end

function QUIDialogSocietyDungeonSetting:_onTriggerReset(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_reset) == false then return end
	app.sound:playSound("common_small")
	remote.union:consortiaBossSetFocusedGoalRequest(true, 1, self._chapter, function()
			for _, value in pairs(self._scoietyChapterConfig) do
				-- print(" value.wave = ", value.wave)
				local boss = self._bossList[value.wave]
				if boss then 
					boss:setFocuseNum("")
					if value.wave_pre then
						boss:makeColorGray()
					else
						boss:makeColorNormal()
					end
				end
			end
		end, function() end)
end

function QUIDialogSocietyDungeonSetting:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_small")
	-- print("[Kumo] QUIDialogSocietyDungeonSetting:_onTriggerClose() ")
	-- for _, value in pairs(self._bossList) do
	-- 	value:setIsSetting(false)
	-- end
	if self._callback then
		self._callback()
	end
	self:playEffectOut()
end

function QUIDialogSocietyDungeonSetting:_init(options)
	self:_updateInit()
end

function QUIDialogSocietyDungeonSetting:_updateInit()
	self._chapter = remote.union:getShowChapter()
	if self._chapter <= 0 then
		remote.union:setShowChapter(remote.union:getFightChapter())
		self._chapter = remote.union:getFightChapter()
	end
	self._bossList = {}
	local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(self._chapter)
	self._scoietyChapterConfig = {}
	local mapIndex = 0
	for _, config in ipairs(scoietyChapterConfig) do
		self._scoietyChapterConfig[config.wave] = config
		if config.color_type then
			mapIndex = config.color_type
		end
	end
	-- QPrintTable(self._scoietyChapterConfig)
	self:_initMap(mapIndex)
end

function QUIDialogSocietyDungeonSetting:_initMap(mapIndex)
	local scoietyChapterConfig = QStaticDatabase.sharedDatabase():getScoietyChapter(self._chapter)
	self._map = QUIWidgetSocietyDungeonMap.new( { mapIndex = mapIndex, config = scoietyChapterConfig } ) 
	if not self._map then
		mapIndex = 1
		self._map = QUIWidgetSocietyDungeonMap.new( { mapIndex = mapIndex } ) 
	end
	self._ccbOwner.node_map:addChild( self._map )
	self:_autoScaleMap( self._map )
	-- self:_addMask( self._map )
	self:_initBossInfo()
end

function QUIDialogSocietyDungeonSetting:_autoScaleMap( widgetMap )
	local mapWidth = widgetMap:getMapWidth()
	local thisWidth = self._ccbOwner.layer_bj:getContentSize().width*self._ccbOwner.layer_bj:getScaleX()
	local mapScale = thisWidth/mapWidth
	widgetMap:setScale(mapScale)
end

function QUIDialogSocietyDungeonSetting:_addMask( widgetMap )
	local size = self._ccbOwner.layer_bj:getContentSize()
	local scaleX = self._ccbOwner.layer_bj:getScaleX()
    local scaleY = self._ccbOwner.layer_bj:getScaleY()
    local clippingNode = CCClippingNode:create()
    local stencil = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
    stencil:setScaleX(scaleX)
    stencil:setScaleY(scaleY)
    stencil:ignoreAnchorPointForPosition(true)
    stencil:setAnchorPoint(self._ccbOwner.layer_bj:getAnchorPoint())
    stencil:setPosition(ccp(self._ccbOwner.layer_bj:getPosition()))
    clippingNode:setStencil(stencil)
	
	local parent = widgetMap:getParent()
    widgetMap:retain()
    widgetMap:removeFromParent()
    clippingNode:addChild(widgetMap)
    parent:addChild(clippingNode)
    widgetMap:release()
end

function QUIDialogSocietyDungeonSetting:_initBossInfo()
	if self._bossList and #self._bossList > 0 then
		for _, value in pairs(self._bossList) do
			value:removeFromParentAndCleanup(true)
			value:removeAllEventListeners()
			value:cleanUp()
			value = nil
		end
		self._bossList = {}
	end

	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if not bossList or #bossList == 0 then return end
	table.sort(bossList, function(a, b)
			return a.setFocusedTime < b.setFocusedTime
		end)
	local focuseIndex = 0
	for _, value in pairs(bossList) do
		value.isSetting = true
		local boss = QUIWidgetSocietyDungeonBoss.new(value)
		boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_CLICK, handler(self, self._onEvent))
		boss:setRecommend(false)
		if value.setFocusedTime ~= remote.union.FOCUSED_TIME then
			focuseIndex = focuseIndex + 1
			boss:setFocuseNum(focuseIndex)
		else
			boss:setFocuseNum("")
		end
		local bossNode = self._map:getBossNodeByIndex(value.wave)
		-- print("[Kumo] QUIDialogSocietyDungeonSetting:_initBossInfo  ", value.wave, bossNode)
		if bossNode then
			bossNode:removeAllChildren()
			bossNode:addChild(boss)
			bossNode:setVisible(true)
		end
		self._bossList[value.wave] = boss
	end

	for _, value in ipairs(bossList) do
		if self._bossList[value.wave] then
			if value.setFocusedTime ~= remote.union.FOCUSED_TIME then
				self._bossList[value.wave]:makeColorNormal()
			else
				local config = self._scoietyChapterConfig[value.wave]
				if config and config.wave_pre and self._bossList[config.wave_pre] and self._bossList[config.wave_pre]:getFocuseNum() > 0 then
					self._bossList[value.wave]:makeColorNormal()
				elseif config and not config.wave_pre then
					self._bossList[value.wave]:makeColorNormal()	
				else
					self._bossList[value.wave]:makeColorGray()
				end
			end
		end
	end
end

function QUIDialogSocietyDungeonSetting:_onEvent( event )
	-- print("QUIDialogSocietyDungeonSetting:_onEvent()", event.name)
	if event.name == QUIWidgetSocietyDungeonBoss.EVENT_CLICK then
		remote.union:consortiaBossSetFocusedGoalRequest(false, event.wave, event.chapter, function()
			remote.union:unionGetBossListRequest(function(data)
					local bossList = remote.union:getConsortiaBossList(self._chapter)
					if not bossList or #bossList == 0 then return end
					table.sort(bossList, function(a, b)
							return a.setFocusedTime < b.setFocusedTime
						end)
					-- QPrintTable(bossList)
					local focuseIndex = 0
					for _, value in ipairs(bossList) do
						if self._bossList[value.wave] then
							if value.setFocusedTime ~= remote.union.FOCUSED_TIME then
								focuseIndex = focuseIndex + 1
								self._bossList[value.wave]:setFocuseNum(focuseIndex)
							else
								self._bossList[value.wave]:setFocuseNum("")
							end
						end
					end

					for _, value in ipairs(bossList) do
						if self._bossList[value.wave] then
							if value.setFocusedTime ~= remote.union.FOCUSED_TIME then
								self._bossList[value.wave]:makeColorNormal()
							else
								local config = self._scoietyChapterConfig[value.wave]
								if config and config.wave_pre and self._bossList[config.wave_pre] and self._bossList[config.wave_pre]:getFocuseNum() > 0 then
									self._bossList[value.wave]:makeColorNormal()
								elseif config and not config.wave_pre then
									self._bossList[value.wave]:makeColorNormal()	
								else
									self._bossList[value.wave]:makeColorGray()
								end
							end
						end
					end
				end)
			end, function()end)
	end
end

return QUIDialogSocietyDungeonSetting
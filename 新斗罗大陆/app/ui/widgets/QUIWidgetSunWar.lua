--
-- Author: Kumo
-- Date: Mon Mar  7 23:43:55 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSunWar = class("QUIWidgetSunWar", QUIWidget)
local QUIWidgetSunWarPlayerInfo = import(".QUIWidgetSunWarPlayerInfo")
local QUIWidgetSunWarChest = import("..widgets.QUIWidgetSunWarChest")

QUIWidgetSunWar.UPDATE_COMPLETE = "UPDATE_COMPLETE"

function QUIWidgetSunWar:ctor(options)
	local ccbFile = "ccb/Widget_SunWar.ccbi"
	local callBacks = {
    }
	QUIWidgetSunWar.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._maxWidth = 0
	self._nameAni = "Default Timeline"

	---------------------

	self._maps = {}
	self._players = {}
	self._chests = {}

	self._aniManagers = {}
    self._aniCcbViews = {}

    self:updateMap()
    self:fastfowardSnow()
end

function QUIWidgetSunWar:fastfowardSnow()
	local node_snow = self._ccbOwner.node_snow
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
	node_snow:update(0.125)
end

function QUIWidgetSunWar:onEnter()
	self:_updatePlayerInfo()
	self:_updateChest()
end

function QUIWidgetSunWar:onExit()
end

function QUIWidgetSunWar:updateMap()
	-- if not remote.sunWar:getIsNeedMapUpdate() then return end
	
	self:clearMap()
	self:_updateMap()
end

function QUIWidgetSunWar:updatePlayerInfo()
	-- if not remote.sunWar:getIsNeedPlayerUpdate() then return end

	self:_updatePlayerInfo()
end

function QUIWidgetSunWar:updateChest()
	-- if not remote.sunWar:getIsNeedChestUpdate() then return end

	self:_updateChest()
end

function QUIWidgetSunWar:clearMap()
	self._maxWidth = 0

	if not self._maps then return end
	for _, map in pairs(self._maps) do
		map:removeFromParent()
	end
	self._maps = {}
end

function QUIWidgetSunWar:clearPlayerInfo()
	if not self._players then return end
	for _, player in pairs(self._players) do
		player:removeAllEventListeners()
		player:removeFromParent()
	end
	self._players = {}
end

function QUIWidgetSunWar:clearChest()
	if not self._chests then return end
	for _, chest in pairs(self._chests) do
		chest:removeFromParent()
	end
	self._chests = {}
end

function QUIWidgetSunWar:getMaxWidth()
	return self._maxWidth - 10
end

function QUIWidgetSunWar:_updateMap()
	local tbl = remote.sunWar:getMapURLByID(remote.sunWar:getCurrentMapID())

	local index = 1
	while(true) do
		if tbl[index] then
			local map = tbl[index]
			local sprite, size = self:_getSpriteByURL(map.url)
			local scale = map.scale*1.25
			self._ccbOwner.node_maps:addChild(sprite)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setScale(scale)
			local x = self._maxWidth
			local y = 0
			sprite:setPosition(ccp(x, y))
			table.insert(self._maps, sprite)
			self._maxWidth = self._maxWidth + sprite:getTextureRect().size.width * scale-3
			index = index + 1
		else
			break
		end
	end
	self:_updateChest()
	self:dispatchEvent({name = QUIWidgetSunWar.UPDATE_COMPLETE})
	remote.sunWar:setIsNeedMapUpdate( false )
end

function QUIWidgetSunWar:_updatePlayerInfo()
	if not remote.sunWar:getCurrentWaveID() then return end
	
	local mapInfo = remote.sunWar:getMapInfoByMapID(remote.sunWar:getCurrentMapID())
	local waveTbl = mapInfo.waves
	for i = 1, #waveTbl, 1 do
		local w = waveTbl[i]
		if not self._players[i] then		
			-- 初始化
			local player = QUIWidgetSunWarPlayerInfo.new({waveID = w.wave})
			local x = w.avatar_x
			local y = w.avatar_y
			player:setPosition(ccp(x, y))
			self._players[i] = player
			self._ccbOwner.node_players:addChild(player)

			player:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_AVATAR_CLICK, handler(self, self._onEvent))
			player:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_INFO_CLICK, handler(self, self._onEvent))
			player:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_FAST_FIGHT_CLICK, handler(self, self._onEvent))
			player:addEventListener(QUIWidgetSunWarPlayerInfo.EVENT_AUTO_FIGHT_CLICK, handler(self, self._onEvent))
		else
			self._players[i]:setWaveID( w.wave )
		end
		
		if w.wave < remote.sunWar:getCurrentWaveID() then
			-- 已击败
			self._players[i]:updateState(QUIWidgetSunWarPlayerInfo.PASS)
		elseif w.wave == remote.sunWar:getCurrentWaveID() then
			self._currentPosX = self._players[i]:getPositionX()
			if remote.sunWar:getLastPassedWave() == w.wave then
				local todayPassedWaves = remote.sunWar:getTodayPassedWaves()
				local isFind = false
				for _, id in pairs(todayPassedWaves) do
					if id == w.wave then
						-- 说明是今天打的，而不是之前打的
						isFind = true
					end
				end

				if isFind then
					self._players[i]:updateState(QUIWidgetSunWarPlayerInfo.PASS)
				else
					self._players[i]:updateState(QUIWidgetSunWarPlayerInfo.NOW)
				end
			else
				self._players[i]:updateState(QUIWidgetSunWarPlayerInfo.NOW)
			end
		else
			-- 未交战
			self._players[i]:updateState(QUIWidgetSunWarPlayerInfo.FUTURE)
		end
	end

	self:_updateChest()

	remote.sunWar:setIsNeedPlayerUpdate( false )
end

function QUIWidgetSunWar:_updateChest()
	local mapInfo = remote.sunWar:getMapInfoByMapID(remote.sunWar:getCurrentMapID())
	local waveTbl = mapInfo.waves
	local color = 0

	if self._chests and table.nums(self._chests) > 0 then
		for _, chest in pairs(self._chests) do
			chest:removeFromParent()
			chest = nil
		end
		self._chests = {}
	end

	for i = 1, #waveTbl, 1 do
		local w = waveTbl[i]
		local id = w.wave

		if not self._chests[id] then
			-- 初始化
			if w.chest_id then
				local chest = QUIWidgetSunWarChest.new({waveID = id})
				local x = w.chest_x
				local y = w.chest_y
				color = color + 1
				chest:setIndex( color )
				chest:addEventListener(QUIWidgetSunWarChest.CHEST_OPENED, handler(self, self._onEvent))
				chest:setPosition(ccp(x, y))
				chest:setScale(w.chest_scale or 1)

				self._chests[id] = chest
				chest:setActive(false)

				self._ccbOwner.node_chests:addChild(chest)
			end
		end

		if self._chests[id] then
			local curWaveID = remote.sunWar:getCurrentWaveID() or 0
			-- local isHeroFirstAppearance = remote.sunWar:getIsHeroFirstAppearance()
			local lastPassedWaveID = remote.sunWar:getLastPassedWave() or 0
			local isOpen = remote.sunWar:getIsChestOpenedByWaveID( id )
			
			local isMaxWave = remote.sunWar:isLastMapLastWaveByWaveID( id )
            local todayPassedWaves = remote.sunWar:getTodayPassedWaves()
            local isFind = false
            for _, id in pairs(todayPassedWaves) do
                if id == w.wave then
                    -- 说明是今天打的，而不是之前打的
                    isFind = true
                end
            end

			if id < curWaveID then
				if isOpen then
					self._chests[id]:playDisappearAnimation()
				else
					self._chests[id]:setActive(true)
					self._chests[id]:playJumpAnimation()
				end
			else
				if id <= lastPassedWaveID and isOpen then
					self._chests[id]:playDisappearAnimation()
				elseif isMaxWave and isFind then
					self._chests[id]:setActive(true)
					self._chests[id]:playJumpAnimation()
				else
					self._chests[id]:playStaticAnimation()
				end
			end
		end
	end

	remote.sunWar:setIsNeedChestUpdate( false )
end

function QUIWidgetSunWar:_onEvent( event )
	self:dispatchEvent({name = event.name, waveID = event.waveID})
end

function QUIWidgetSunWar:_getSpriteByURL( str )
	local url = str
	local url1 = ""
	local url2 = ""
	local size = nil
	local _, e1 = string.find(url, "%.plist")
	local _, e2 = string.find(url, "%.plist/")
	if e1 and e2 then
		url1 = string.sub(url, 1, e1)
		url2 = string.sub(url, e2 + 1)
	end


	local sprite = nil
	if url1 == "" then
		local texture = CCTextureCache:sharedTextureCache():addImage(url)
		sprite = CCSprite:createWithTexture( texture )
	else
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(url1)
		local spriteFrameName = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(url2)

		size = spriteFrameName:getRect().size
		sprite = CCSprite:createWithSpriteFrame( spriteFrameName ) 
	end

	return sprite, size
end

function QUIWidgetSunWar:getCurrentPosition()
	return self._currentPosX or 0
end

return QUIWidgetSunWar
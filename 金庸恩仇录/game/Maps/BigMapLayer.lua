local data_world_world = require("data.data_world_world")
local data_field_field = require("data.data_field_field")
local MAX_ZORDER = 1111

local BigMapLayer = class("BigMapLayer", function()
	return display.newLayer()
end)

local TILE_WIDTH = 32
local TILE_HEIGHT = 32
local TILES_W_NUM = 20
local TILES_H_NUM = 30
local SCALE_HANDLE = false

BigMapLayer.buildBtns = {}

function BigMapLayer:initBg()
	local scrollViewBg = CCScrollView:create()
	local bg = display.newScale9Sprite("ui/alphaBg.png")
	local bgImage = display.newSprite("ui/jpg_bg/bigmap/bigmap_1.jpg")
	self.bgImage = bgImage
	local BG_WIDTH = bgImage:getContentSize().width
	local BG_HEIGHT = bgImage:getContentSize().height
	--[[
	if display.sizeInPixels.width > bgImage:getContentSize().width then
		local factorWidth = display.sizeInPixels.width
		if device.model == "ipad" and factorWidth == 1536 then
			factorWidth = 768
		end
		if device.platform == "android" then
			factorWidth = 768
		end
		local scale_factor = factorWidth / bgImage:getContentSize().width
		bgImage:setScale(scale_factor)
		BG_WIDTH = BG_WIDTH * scale_factor
		BG_HEIGHT = BG_HEIGHT * scale_factor
		if not SCALE_HANDLE then
			TILE_WIDTH = TILE_WIDTH * scale_factor
			TILE_HEIGHT = TILE_HEIGHT * scale_factor
			SCALE_HANDLE = true
		end
	end
	]]
	bgImage:align(display.LEFT_BOTTOM, 0, 0)
	bg:addChild(bgImage)
	bg:setPreferredSize(cc.size(display.width, BG_HEIGHT))
	scrollViewBg:setViewSize(cc.size(display.width, display.height - 259))
	scrollViewBg:setPosition(cc.p(0, self.top:getBottomContentSize().height))
	scrollViewBg:ignoreAnchorPointForPosition(true)
	scrollViewBg:setContainer(bg)
	scrollViewBg:setContentSize(cc.size(display.width, BG_HEIGHT))
	scrollViewBg:updateInset()
	scrollViewBg:setDirection(kCCScrollViewDirectionVertical)
	scrollViewBg:setClippingToBounds(true)
	scrollViewBg:setBounceable(false)
	self:addChild(scrollViewBg)
	
	self.bg = scrollViewBg
	local levelBg = require("utility.HorizonListBg").new()
	levelBg:setPosition(display.cx, display.height - self.top:getVoiceSize().height * 0.8 - levelBg:getContentSize().height / 2)
	self.levelBg = levelBg
	self:addChild(levelBg)
end

function BigMapLayer:refreshBg(bgName)
	if self.bgImage then
		self.bgImage:setDisplayFrame(display.newSprite("ui/jpg_bg/bigmap/" .. bgName .. ".jpg"):getDisplayFrame())
	end
	self.bgName = bgName
end

function BigMapLayer:enterSubMap(index)
	if index <= self._curLevel.bigMap then
		for i = 1, #self.buildBtns do
			local btn = self.buildBtns[i]
			btn:setVisible(false)
		end
		PageMemoModel.saveOffset(self.bgName, self.bg)
		MapModel:setCurrentBigMapID(index)
		self:setEnterMsg({bigMapID = index})
		self:onEnter()
	end
end

function BigMapLayer:removeLevelTip()
	if self._jiantouEff ~= nil and self._jiantouEff:getParent() then
		self._jiantouEff:removeSelf()
		self._jiantouEff = nil
	end
end

function BigMapLayer:init()
	ResMgr.addPromptRes()
	local maxZorder = 10
	local i = 0
	if self.nodes ~= nil then
		for i, v in ipairs(self.nodes) do
			v:removeSelf()
		end
		self.nodes = nil
	end
	self.nodes = {}
	local btnIndx = 1
	for k, v in pairs(self._subMap) do
		do
			local submapID = checkint(k)
			local subMapData = data_field_field[submapID]
			local function btnListener()
				if submapID <= self._curLevel.subMap and game.player.m_level >= data_field_field[submapID].level then
					local curBigMapID = self.bigMapID
					if curBigMapID == nil then
						curBigMapID = self._curLevel.bigMap
					end
					DramaMgr.runDramaBefSub(submapID, function()
						game.player:setFubenDisOffset(self.bg:getContentOffset())
						PostNotice(NoticeKey.REMOVE_TUTOLAYER)
						GameStateManager:ChangeState(GAME_STATE.STATE_SUBMAP, {
						submapID = submapID,
						subMap = self._subMap
						})
					end)
				else
					show_tip_label("[" .. data_field_field[submapID].name .. "] " .. data_field_field[submapID].level .. common:getLanguageString("@GuildShopUnlock"))
				end
			end
			local buildBtn = self.buildBtns[btnIndx]
			local imgName = "lvl/" .. subMapData.icon .. ".png"
			if buildBtn == nil then
				buildBtn = require("utility.CommonButton").new({img = imgName, listener = btnListener})
				self.buildBtns[btnIndx] = buildBtn
				self.bg:addChild(buildBtn, maxZorder - i)
				
				local nameBg = display.newSprite("lvl/lv_b_name_bg.png")
				nameBg:setPosition(buildBtn:getContentSize().width / 2, 0)
				buildBtn:addChild(nameBg, maxZorder)
				local nameLabel = ui.newTTFLabel({
				text = "",
				font = FONTS_NAME.font_fzcy,
				size = 22,
				color = display.COLOR_WHITE,
				x = nameBg:getContentSize().width / 2,
				y = nameBg:getContentSize().height / 2,
				align = ui.TEXT_ALIGN_CENTER,
				})
				nameBg:addChild(nameLabel)
				buildBtn.nameLabel = nameLabel
				local starLabel = ui.newBMFontLabel({
				text = "",
				font = FONTS_NAME.font_property,
				size = 22,
				color = display.COLOR_WHITE,
				x = nameBg:getContentSize().width / 2,
				y = -nameBg:getContentSize().height * 0.8,
				align = ui.TEXT_ALIGN_CENTER,
				})
				nameBg:addChild(starLabel)
				buildBtn.starLabel = starLabel
				local starIcon = display.newSprite("#bigmap_star.png")
				starIcon:setPosition(nameBg:getContentSize().width * 0.68 + starIcon:getContentSize().width / 2, -nameBg:getContentSize().height / 2)
				nameBg:addChild(starIcon)
				buildBtn.starIcon = starIcon
				local tipIcon = display.newSprite("#toplayer_mail_tip.png")
				tipIcon:setPosition(nameBg:getContentSize().width * 0.9, nameBg:getContentSize().height / 2)
				tipIcon:setScale(0.5)
				nameBg:addChild(tipIcon)
				buildBtn.tipIcon = tipIcon
			else
				buildBtn:setListener(btnListener)
				buildBtn.sprite:setDisplayFrame(display.newSprite(imgName):getDisplayFrame())
			end
			btnIndx = btnIndx + 1
			buildBtn:setVisible(true)
			local btnW = buildBtn.sprite:getContentSize().width
			local btnH = buildBtn.sprite:getContentSize().height
			buildBtn:setAlign(display.CENTER)
			buildBtn:setPosition(subMapData.x_axis * TILE_WIDTH , subMapData.y_axis * TILE_HEIGHT)
			i = i + 1
			if submapID == self._curLevel.subMap then
				if submapID ~= 1101 then
					-- 关卡特效
					local jiantouEff = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = "dangqianguankatexiao_jiantou",
					isRetain = true
					})
					jiantouEff:align(display.BOTTOM_CENTER, subMapData.x_axis * TILE_WIDTH, buildBtn:getPositionY() + buildBtn.sprite:getContentSize().height/2)
					self.bg:addChild(jiantouEff, maxZorder)
					self.nodes[#self.nodes + 1] = jiantouEff
					-- 关卡特效
					local boEff = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = "dangqianguankatexiao_bo",
					isRetain = true
					})
					boEff:align(display.CENTER_TOP, subMapData.x_axis * TILE_WIDTH, buildBtn:getPositionY())
					self.bg:addChild(boEff)
					self.nodes[#self.nodes + 1] = boEff
				end
				if self.isFirst == true then
					self.isFirst = false
					self.bg:setContentOffset(cc.p(0, -(subMapData.y_axis - 1) * TILE_HEIGHT + btnH))
				end
			end
			if subMapData.id == 1101 then
				TutoMgr.addBtn("putongfuben_btn_niujiacun1", buildBtn)
				TutoMgr.active()
			end
			if subMapData.id == 1102 then
				TutoMgr.addBtn("bigmap_second_lvl", buildBtn)
				TutoMgr.active()
			end
			local fontColor = display.COLOR_WHITE
			if self._curLevel.subMap == subMapData.id then
				fontColor = display.COLOR_RED
			end
			buildBtn.nameLabel:setString(subMapData.name)
			buildBtn.nameLabel:setColor(fontColor)
			local star = self._subMap[tostring(subMapData.id)]
			buildBtn.starLabel:setString(star .. "/" .. data_field_field[subMapData.id].star)
			if self._fieldRedTipAry and self._fieldRedTipAry[tostring(subMapData.id)] and self._fieldRedTipAry[tostring(subMapData.id)] == 1 then
				buildBtn.tipIcon:setVisible(true)
			else
				buildBtn.tipIcon:setVisible(false)
			end
			if star == 0 and submapID > self._curLevel.subMap then
				if data_field_field[subMapData.id].cloud_live_anim ~= nil then
					local armaName = data_field_field[subMapData.id].cloud_live_anim
					if(ResMgr.isHighEndDevice() == false) then
					armaName = "yun1_piaodong"
				end
				local xunhuanEffect = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = armaName,
				isRetain = true
				})
				local x = subMapData.x_axis * TILE_WIDTH + data_field_field[subMapData.id].cloud_x
				local y = subMapData.y_axis * TILE_HEIGHT + data_field_field[subMapData.id].cloud_y
				xunhuanEffect:setPosition(x, y)
				xunhuanEffect:align(display.CENTER)
				self.bg:addChild(xunhuanEffect, maxZorder - i +1)
				self.nodes[#self.nodes + 1] = xunhuanEffect
			end
		elseif star == 0 and submapID == self._curLevel.subMap then
			local hasPlayed = CCUserDefault:sharedUserDefault():getBoolForKey("big" .. submapID, false)
			if hasPlayed == false then
				CCUserDefault:sharedUserDefault():setBoolForKey("big" .. submapID, true)
				local armaName = data_field_field[subMapData.id].cloud_die_anim
				if ResMgr.isHighEndDevice() == false then
					armaName = "yun1_sankai"
				end
				if data_field_field[subMapData.id].cloud_die_anim ~= nil then
					local xunhuanEffect = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = data_field_field[subMapData.id].cloud_die_anim,
					isRetain = true
					})
					local x = subMapData.x_axis * TILE_WIDTH - xunhuanEffect:getContentSize().width/2 + data_field_field[subMapData.id].cloud_x
					local y = subMapData.y_axis * TILE_HEIGHT - xunhuanEffect:getContentSize().height*0.6 + data_field_field[subMapData.id].cloud_y
					xunhuanEffect:setPosition(x,y)
					self.bg:addChild(xunhuanEffect,maxZorder- i +1)
					self.nodes[#self.nodes + 1] = xunhuanEffect
				end
			end
		end
	end
end
end

function BigMapLayer:initLevelChoose()
	self.levelData = {}
	for k, v in pairs(data_world_world) do
		table.insert(self.levelData, v)
	end
	table.sort(self.levelData, function(l, r)
		return l.id < r.id
	end)
	local HOLDER_SPACE_WIDTH = 80
	local viewSize = cc.size(self.levelBg:getContentSize().width - HOLDER_SPACE_WIDTH, self.levelBg:getContentSize().height)
	self.mOpenNewBigmapId = 0
	local upCellSize = require("game.Maps.BigMapUpCell").new():getContentSize()
	local function getUpCellState(idx)
		local bChoose = false
		if self.bigMapID ~= nil and self.levelData[idx].id == self.bigMapID then
			bChoose = true
		elseif self.bigMapID == nil and self.levelData[idx].id == self._curLevel.bigMap then
			bChoose = true
		end
		local bLock = false
		if self.levelData[idx].id > self._curLevel.bigMap then
			bLock = true
		end
		return bChoose, bLock
	end
	if self._bagItemList == nil then
		self._bagItemList = require("utility.TableViewExt").new({
		size = viewSize,
		direction = kCCScrollViewDirectionHorizontal,
		createFunc = function(idx)
			idx = idx + 1
			local bChoose, bLock = getUpCellState(idx)
			return require("game.Maps.BigMapUpCell").new():create({
			itemData = self.levelData[idx],
			idx = idx,
			viewSize = viewSize,
			choose = bChoose,
			bLock = bLock,
			redTip = self._worldRedTipAry[tostring(self.levelData[idx].id)],
			mNewBigmapId = mNewBigmapState,
			curUnLock = self:checkIsNewBigMap(self.levelData[idx].id),
			unLockListener = function()
				game.player:setBattleData({isOpenNewBigmap = false})
			end
			})
		end,
		refreshFunc = function(cell, idx)
			idx = idx + 1
			local bChoose, bLock = getUpCellState(idx)
			cell:refresh({
			itemData = self.levelData[idx],
			idx = idx,
			choose = bChoose,
			redTip = self._worldRedTipAry[tostring(self.levelData[idx].id)],
			mNewBigmapId = mNewBigmapState,
			bLock = bLock,
			curUnLock = self:checkIsNewBigMap(self.levelData[idx].id)
			})
		end,
		cellNum = #self.levelData,
		cellSize = upCellSize,
		touchFunc = function(cell)
			local idx = cell:getIdx() + 1
			if MapModel:getCurrentBigMapID() ~= self.levelData[idx].id then
				self:removeLevelTip()
				self:enterSubMap(self.levelData[idx].id)
			end
			printf("====== %d", self.levelData[idx].id)
		end,
		scrollFunc = function()
			if self._bagItemList ~= nil and not self._bagItemListreload then
				PageMemoModel.saveOffset("big_map_up_icon", self._bagItemList)
				self:removeLevelTip()
			end
		end
		})
		self._bagItemList:setPosition(-self.levelBg:getContentSize().width / 2 + HOLDER_SPACE_WIDTH / 2, -self.levelBg:getContentSize().height / 2 + 10)
		self.levelBg:addChild(self._bagItemList)
		if #self.levelData > 5 then
			if (MapModel:getCurrentBigMapID() or 1) > self.levelData[3].id then
				self._bagItemList:setContentOffset(cc.p(-upCellSize.width, 0))
			end
		end
	else
		self._bagItemListreload = true
		self._bagItemList:reloadData()
	end
	self._bagItemListreload = false
	PageMemoModel.resetOffset("big_map_up_icon", self._bagItemList)
	if self.mOpenNewBigmapId ~= nil and self.mOpenNewBigmapId > 0 then
		local newNum = self.mOpenNewBigmapId - 11
		if newNum == 0 then
			return
		end
		local width_cell = upCellSize.width
		if newNum >= 5 then
			self._bagItemList:setContentOffset(cc.p(-(newNum - 4) * width_cell, 0))
			newNum = 4
		end
		local rootNode = {}
		self._jiantouEff = LoadUI("mainmenu/navigtion.ccbi", rootNode)
		self._jiantouEff:setAnchorPoint(0.5, 1)
		self._jiantouEff:setVisible(true)
		self._jiantouEff:setRotation(180)
		self._jiantouEff:setPosition(-self.levelBg:getContentSize().width / 2 + 40 + width_cell * (newNum + 0.5), -self.levelBg:getContentSize().height / 2 + 10)
		self.levelBg:addChild(self._jiantouEff, 100)
	end
end

function BigMapLayer:checkIsNewBigMap(id)
	local unlock = false
	local battleData = game.player:getBattleData()
	if battleData.isOpenNewBigmap and battleData.cur_bigMapId == id then
		unlock = true
		self.mOpenNewBigmapId = id
	end
	return unlock
end

function BigMapLayer:initBigmapData(data)
	local bgName = "bigmap_1"
	self._curLevel = {
	bigMap = MapModel.bigMap,
	subMap = MapModel.subMap,
	level = MapModel.level
	}
	self._subMap = data.subMapStar
	self._worldRedTipAry = MapModel:getWorldRedTipAry()
	self._fieldRedTipAry = data.fieldRedTipAry
	game.player:setBattleData({
	cur_bigMapId = MapModel.bigMap,
	cur_subMapId = MapModel.subMap,
	new_subMapId = MapModel.subMap
	})
	local mapId = self.bigMapID or MapModel.bigMap
	bgName = data_world_world[mapId].background
	local soundName = ResMgr.getSound(data_world_world[mapId].bgm)
	GameAudio.playMusic(soundName, true)
	game.player.m_maxLevel = MapModel.level
	local battleData = game.player:getBattleData()
	if self.submapNewMsg ~= nil and tolua.cast(self.submapNewMsg, "cc.Node") then
		self.submapNewMsg:removeSelf()
	end
	self.submapNewMsg = nil
	if battleData.isOpenNewBigmap then
		local levelName = data_world_world[battleData.cur_bigMapId].name
		local submapNewMsg = require("game.Maps.SubmapNewMsg").new(common:getLanguageString("@NewWorldMapUnlock"), levelName)
		self:addChild(submapNewMsg, MAX_ZORDER)
		self.submapNewMsg = submapNewMsg
	end
	self:refreshBg(bgName)
	self:init()
	self:initLevelChoose()
	if not PageMemoModel.resetOffset(self.bgName, self.bg) then
		if self.bigMapID and self.bigMapID < MapModel.bigMap then
			self.bg:setContentOffset(cc.p(0, -(self.bg:getContentSize().height - self.bg:getViewSize().height)))
		else
			local maxOffsetY = -(self.bg:getContentSize().height - self.bg:getViewSize().height)
			local subMapData = data_field_field[self._curLevel.subMap]
			local offsetY = -(subMapData.y_axis - 1) * TILE_HEIGHT + 150
			if offsetY > 0 then
				offsetY = 0
			elseif maxOffsetY > offsetY then
				offsetY = maxOffsetY
			end
			self.bg:setContentOffset(cc.p(0, offsetY))
		end
	end
	if self.worldFunc ~= nil then
		worldFunc()
	end
end

function BigMapLayer:ctor()
	self:setNodeEventEnabled(true)
	self.buildBtns = {}
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
	display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
	self.top = require("game.scenes.TopLayer").new()
	self:addChild(self.top, 100)
	self.top:setInfoBgVisible(false)
	self:initBg()
end

function BigMapLayer:setEnterMsg(msg)
	self.msg = msg
end

function BigMapLayer:onEnter()
	if not self.top then
		self.top = require("game.scenes.TopLayer").new(true)
		self:addChild(self.top, 100)
		self.top:setInfoBgVisible(false)
	end
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
	local bigMapID = self.msg.bigMapID
	self.isFirst = false
	if MapModel:getCurrentBigMapID() ~= 0 then
		bigMapID = MapModel:getCurrentBigMapID()
	else
		self.isFirst = true
		MapModel:setCurrentBigMapID(bigMapID)
	end
	self.bigMapID = bigMapID
	if bigMapID ~= nil then
		self.bg:setContentOffset(game.player:getFubenDisOffset(), false)
	end
	game.player:setFubenDisOffset(cc.p(0, 0))
	local bigmapName = "bigmap_1"
	if bigMapID ~= nil then
		dump(bigMapID)
		bigmapName = data_world_world[bigMapID].background
	end
	self:refreshBg(bigmapName)
	self.worldFunc = self.msg.worldFunc
	local mapData = MapModel:getBigMap(bigMapID)
	if mapData == nil then
		local function _callback()
			mapData = MapModel:getBigMap(bigMapID)
			self:initBigmapData(mapData)
		end
		MapModel:requestMapData(bigMapID, _callback)
	else
		self:initBigmapData(mapData)
	end
	GameStateManager.currentState = GAME_STATE.STATE_FUBEN
	self.top:initBroadcast()
end

function BigMapLayer:onExit()
	--if self.top then
	--	self.top:removeSelf()
	--	self.top = nil
	--end
	--self:removeLevelTip()
	
	PageMemoModel.saveOffset(self.bgName, self.bg)
	self.bgImage:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
	TutoMgr.removeBtn("putongfuben_btn_niujiacun1")
	TutoMgr.removeBtn("bigmap_second_lvl")
	ResMgr.ReleaseUIArmature("dangqianguankatexiao_jiantou")
	ResMgr.ReleaseUIArmature("dangqianguankatexiao_bo")
	for i = 1, 4 do
		local name_piaodong = string.format("yun%d_piaodong/yun_%d", i, i)
		local name_sankai = string.format("yun%d_sankai/yun_%d", i, i)
		ResMgr.ReleaseUIArmature(name_piaodong)
		ResMgr.ReleaseUIArmature(name_sankai)
	end
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	collectgarbage("collect")
end

return BigMapLayer
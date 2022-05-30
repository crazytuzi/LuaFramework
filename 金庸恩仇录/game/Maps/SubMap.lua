local data_battle_battle = require("data.data_battle_battle")
local data_item_item = require("data.data_item_item")
local data_field_field = require("data.data_field_field")
local data_world_world = require("data.data_world_world")
local SCENE_INFO_ZORDER = 100
local OPENLAYER_ZORDER = 10001
local NEWLEVEL_ZORDER = OPENLAYER_ZORDER + 3
local EFFECT_TAG = 11
local BOX_TOUCH_TAG = 12
local addInfoLayerTag = 102
local newMapLayerTag = 1084
local bigMapBgTag = 7658

local CommonButton = require("utility.CommonButton")

local SubMap = class("SubMap", function()
	return require("game.BaseLayer").new({
	topFile = "public/top_frame_other.ccbi",
	contentFile = "fuben/sub_map_layer.ccbi",
	isOther = true,
	isHideBottom = true
	})
end)

--计算场景通关星数
local function calSubmapStar(id)
	local num = 0
	if data_field_field[id] then
		for k, v in ipairs(data_field_field[id].arr_battle) do
			if v == nil then
				CCMessageBox(v, "")
			end
			num = num + data_battle_battle[v].star
		end
	end
	return num
end

function SubMap:ctor(param)
	self:setNodeEventEnabled(true)
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
	local listViewNode = self._rootnode.listView_node
	local listHeigt = self:getCenterHeight() - self._rootnode.bottom_node:getContentSize().height - self._rootnode.top_node:getContentSize().height
	local listSize = cc.size(listViewNode:getContentSize().width * 0.95, listHeigt)
	self._listViewSize = cc.size(listSize.width, listSize.height * 0.97)
	local listBg = display.newScale9Sprite("#submap_bg.png", 0, 0, listSize)
	listBg:align(display.CENTER_BOTTOM, listViewNode:getContentSize().width / 2, 0)
	listViewNode:addChild(listBg)
	self._listViewNode = display.newNode()
	self._listViewNode:setContentSize(self._listViewSize)
	self._listViewNode:align(display.CENTER_BOTTOM, listViewNode:getContentSize().width / 2, listSize.height * 0.01)
	listViewNode:addChild(self._listViewNode)
	
	--返回
	self._rootnode.backBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true and TutoMgr.notLock() then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			GameStateManager:ChangeState(GAME_STATE.STATE_FUBEN, {bigMapID = self.subMapInfo.world})
		end
	end,
	CCControlEventTouchUpInside)
	
	--阵容 亲  测 源码 网  w w w. q c y m w .c o m
	self._rootnode.zhenrongBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true and TutoMgr.notLock() then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			local formCtrl = require("game.form.FormCtrl")
			formCtrl.createFormSettingLayer({
			parentNode = game.runningScene,
			touchEnabled = true
			})
		end
	end,
	CCControlEventTouchUpInside)
	self.curBigMapID = nil
	self._bg = nil
	self._scrollItemList = nil
	
end

--[[初始化场景场景数据]]
function SubMap:setSubMapData(param)
	self._rootnode.backBtn:setScale(1)
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
	self.battleId = param.battleId
	ResMgr.createBefTutoMask(self)
	local subMap = param.subMap
	local subMapID = param.submapID
	self._rootnode.level_name_lbl:setString(data_field_field[subMapID].name)
	self.isRefreshList = param.isRefresh
	game.player.m_cur_normal_fuben_ID = subMapID
	self.subMapInfo = data_field_field[subMapID]
	local LvIcon = self._rootnode.level_icon
	LvIcon:setDisplayFrame(display.newSprite("lvl/" .. self.subMapInfo.icon .. ".png"):getDisplayFrame())
	self._rootnode.level_name_lbl:setPositionX(LvIcon:getContentSize().width * LvIcon:getScaleX() + 10)
	self._bg = self:getChildByTag(bigMapBgTag)
	if not self._bg then
		self.curBigMapID = self.subMapInfo.world
		self._bg = display.newSprite("ui/jpg_bg/bigmap/" .. data_world_world[self.curBigMapID].background .. ".jpg")
		self._bg:setPosition(display.cx, display.cy)
		self:addChild(self._bg, -10)
		self._bg:setTag(bigMapBgTag)
	elseif self.curBigMapID ~= self.subMapInfo.world then
		self.curBigMapID = self.subMapInfo.world
		local spriteFrame = display.newSprite("ui/jpg_bg/bigmap/" .. data_world_world[self.curBigMapID].background .. ".jpg"):getDisplayFrame()
		self._bg:setDisplayFrame(spriteFrame)
	end
	if subMap ~= nil then
		self:initLevelInfo(subMap)
	end
	self.subMapID = subMapID
	self:getSubLevelList(subMapID)
end

function SubMap:initLevelInfo(subMap)
	local TILE_WIDTH = 32
	local TILE_HEIGHT = 32
	local maxZorder = 10
	local i = 0
	for k, v in pairs(subMap) do
		local submapID = checkint(k)
		local subMapData = data_field_field[checkint(k)]
		local buildBtn = require("utility.CommonButton").new({
		img = "lvl/" .. subMapData.icon .. ".png",
		listener = function()
		end
		})
		buildBtn:setTouchEnabled(false)
		local btnW = buildBtn:getContentSize().width
		local btnH = buildBtn:getContentSize().height
		buildBtn:setPosition(subMapData.x_axis * TILE_WIDTH - btnW / 2, subMapData.y_axis * TILE_HEIGHT - btnH / 2)
		self._bg:addChild(buildBtn, maxZorder - i)
		i = i + 1
		local nameBg = display.newSprite("lvl/lv_b_name_bg.png")
		nameBg:setPosition(buildBtn:getContentSize().width / 2, 0)
		buildBtn:addChild(nameBg, maxZorder)
		local nameLabel = ui.newTTFLabel({
		text = subMapData.name,
		font = FONTS_NAME.font_fzcy,
		size = 20,
		color = fontColor,
		x = nameBg:getContentSize().width / 2,
		y = nameBg:getContentSize().height / 2,
		align = ui.TEXT_ALIGN_CENTER
		})
		nameBg:addChild(nameLabel)
		local star = subMap[tostring(subMapData.id)]
		local starLabel = ui.newBMFontLabel({
		text = star .. "/" .. data_field_field[subMapData.id].star,
		font = FONTS_NAME.font_property,
		size = 22,
		color = display.COLOR_WHITE,
		x = nameBg:getContentSize().width / 2,
		y = -nameBg:getContentSize().height * 0.8,
		align = ui.TEXT_ALIGN_CENTER
		})
		nameBg:addChild(starLabel)
		local starIcon = display.newSprite("#bigmap_star.png")
		starIcon:setPosition(nameBg:getContentSize().width * 0.65 + starIcon:getContentSize().width / 2, -nameBg:getContentSize().height / 2)
		nameBg:addChild(starIcon)
	end
end

function SubMap:checkLevelReward(subMapID)
	local _curStars = self._subMapInfo["2"].stars
	local _boxState = self._subMapInfo["2"].box
	self._allLevelReward = {}
	for i = 1, 3 do
		local star, arrReward, arrNum
		if i == 1 then
			star = self.subMapInfo.star1
			arrReward = self.subMapInfo.arr_reward1
			arrNum = self.subMapInfo.arr_num1
		elseif i == 2 then
			star = self.subMapInfo.star2
			arrReward = self.subMapInfo.arr_reward2
			arrNum = self.subMapInfo.arr_num2
		else
			star = self.subMapInfo.star3
			arrReward = self.subMapInfo.arr_reward3
			arrNum = self.subMapInfo.arr_num3
		end
		if star ~= nil and arrReward ~= nil and arrNum ~= nil then
			local rewardData = {}
			for j, v in ipairs(arrReward) do
				local item = data_item_item[v]
				local iconType = ResMgr.getResType(item.type)
				table.insert(rewardData, {
				id = item.id,
				type = item.type,
				name = item.name,
				iconType = iconType,
				num = arrNum[j] or 0
				})
			end
			table.insert(self._allLevelReward, {
			star = star,
			hard = i,
			itemData = rewardData
			})
		end
	end
	for i = 1, 3 do
		if i > #self._allLevelReward then
			self._rootnode["box_" .. i]:setVisible(false)
		else
			self._rootnode["box_" .. i]:setVisible(true)
			--星星数量
			local curNumLbl = self._rootnode["box_starNum_" .. i]
			if curNumLbl.refreshed == nil then
				curNumLbl = ui.newTTFLabelWithOutline({
				text = tostring(self._allLevelReward[i].star),
				size = 22,
				font = FONTS_NAME.font_haibao,
				align = ui.TEXT_ALIGN_LEFT,
				color = cc.c3b(255, 216, 0),
				outlineColor = cc.c3b(43, 6, 0),
				})
				ResMgr.replaceKeyLableEx(curNumLbl, self._rootnode, "box_starNum_" .. i, 0, 10)
				curNumLbl:align(display.BOTTOM_LEFT)
				curNumLbl.refreshed = true
			else
				curNumLbl:setString(tostring(self._allLevelReward[i].star))
			end
			
			local boxIcon = self._rootnode["box_icon_" .. i]
			boxIcon:removeChildByTag(EFFECT_TAG, true)
			boxIcon:removeChildByTag(BOX_TOUCH_TAG, true)
			--dump("boxIcon:removeChildByTag(BOX_TOUCH_TAG, true)")
			local state = _boxState[i]
			if state == 1 then
				boxIcon:setDisplayFrame(display.newSprite("#submap_box_close_" .. i .. ".png"):getDisplayFrame())
			elseif state == 2 then
				game.player:setJiangHuBoxNum(1)
				PostNotice(NoticeKey.BottomLayer_JiangHu)
				boxIcon:setDisplayFrame(display.newSprite("#submap_box_open_" .. i .. ".png"):getDisplayFrame())
				local effect = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = "fubenjiangli_shanguang",
				isRetain = true,
				finishFunc = function()
				end
				})
				effect:setPosition(boxIcon:getContentSize().width / 2, boxIcon:getContentSize().height / 2)
				boxIcon:addChild(effect, 1, EFFECT_TAG)
			elseif state == 3 then
				boxIcon:setDisplayFrame(display.newSprite("#submap_box_end_" .. i .. ".png"):getDisplayFrame())
			else
				CCMessageBox(state, common:getLanguageString("@ServerStageStatusError"))
			end
			
			local boxIconBtn = require("utility.MyLayer").new({
			size = boxIcon:getContentSize(),
			swallow = true,
			})
			if i == 1 then
				self._rootnode["box_guide_btn"] = boxIconBtn
				TutoMgr.addBtn("submap_baoxiang_box", boxIconBtn)
			end
			--boxIconBtn:ignoreAnchorPointForPosition(false)
			--boxIconBtn:align(display.LEFT_BOTTOM)
			boxIcon:addChild(boxIconBtn)
			boxIconBtn:setTag(BOX_TOUCH_TAG)
			boxIconBtn:setTouchHandler(function(event)
				dump(_boxState[i])
				if event.name == "began" then
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
					if not self.hasBagState then
						show_tip_label(common:getLanguageString("@DataInRequest"))
						return
					end
					if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true and TutoMgr.notLock() then
						boxIconBtn:setTouchEnabled(false)
						PostNotice(NoticeKey.REMOVE_TUTOLAYER)
						ResMgr.createBefTutoMask(self)
						local rewardLayer = require("game.Maps.SubmapRewardLayer").new({
						id = subMapID,
						hard = self._allLevelReward[i].hard,
						needStar = self._allLevelReward[i].star,
						itemData = self._allLevelReward[i].itemData,
						bagState = self._subMapInfo["3"],
						state = _boxState[i],
						updateListener = function(hard)
							self._subMapInfo["2"].box[hard] = 3
							_boxState[hard] = 3
							boxIcon:setDisplayFrame(display.newSprite("#submap_box_end_" .. i .. ".png"):getDisplayFrame())
							boxIcon:removeChildByTag(EFFECT_TAG, true)
							local worldId = data_field_field[subMapID].world
							MapModel:requestMapData(worldId, nil, true)
						end,
						closeListener = function()
							boxIconBtn:setTouchEnabled(true)
							TutoMgr.active()
						end
						})
						self:addChild(rewardLayer, OPENLAYER_ZORDER)
					end
					return true
				elseif event.name == "end" then
				end
			end)
		end
	end
end

function SubMap:getSubLevelList(id, refreshSubInfoFunc)
	
	local function _callback(data, bagState)
		if self._scrollItemList then
			self._scrollItemList:setVisible(true)
		end
		self.hasBagState = bagState
		if data then
			if #data["0"] == 0 then
				-- 总星星数量
				local tNumLbl = self._rootnode["allStarLabel"]
				if tNumLbl.refreshed == nil then
					tNumLbl = ui.newTTFLabelWithOutline({
					text = "/" .. tostring(calSubmapStar(id)),
					size = 22,
					font = FONTS_NAME.font_haibao,
					align = ui.TEXT_ALIGN_LEFT,
					color = cc.c3b(255, 216, 0),
					outlineColor = cc.c3b(43, 6, 0),
					})
					ResMgr.replaceKeyLableEx(tNumLbl, self._rootnode, "allStarLabel", - tNumLbl:getContentSize().width, 0)
					tNumLbl:align(display.CENTER_LEFT)
					tNumLbl.refreshed = true
				else
					tNumLbl:setString("/" .. tostring(calSubmapStar(id)))
				end
				-- 当前星星数量
				local curNumLbl = self._rootnode["curStarLabel"]
				if curNumLbl.refreshed == nil then
					curNumLbl = ui.newTTFLabelWithOutline({
					text = tostring(data["2"].stars),
					size = 22,
					font = FONTS_NAME.font_haibao,
					align = ui.TEXT_ALIGN_LEFT,
					color = cc.c3b(255, 216, 0),
					outlineColor = cc.c3b(43, 6, 0),
					})
					ResMgr.replaceKeyLableEx(curNumLbl, self._rootnode, "curStarLabel", - curNumLbl:getContentSize().width, 0)
					curNumLbl:align(display.CENTER_LEFT)
					curNumLbl.refreshed = true
				else
					curNumLbl:setString(tostring(data["2"].stars))
				end
				
				local allStarIcon = self._rootnode.allStar_icon
				self._rootnode.curStar_icon:setPositionX(allStarIcon:getPositionX() - allStarIcon:getContentSize().width - tNumLbl:getContentSize().width)
				self._subMapInfo = data
				self:createMapNode()
				self:checkLevelReward(id)
				--自动进入关卡详情界面
				if self.battleId ~= nil then
					self:removeChildByTag(addInfoLayerTag)
					if self:getChildByTag(addInfoLayerTag) == nil then
						self:createSubInfo(data_battle_battle[self.battleId])
						self.battleId = nil
					end
				end
				if refreshSubInfoFunc ~= nil then
					refreshSubInfoFunc()
				end
			else
				CCMessageBox(common:getLanguageString("@ServerError"), "Tip")
			end
		end
		if self.hasBagState then
			TutoMgr.active()
		end
	end
	
	if self._scrollItemList then
		self._scrollItemList:setVisible(false)
	end
	
	self.hasBagState = false
	if refreshSubInfoFunc then
		MapModel:getSmallMapData(id, _callback, true)
	else
		MapModel:getSmallMapData(id, _callback)
	end
end

function SubMap:update()
	self:refreshTopText()
	self:getSubLevelList(self.subMapID)
end

function SubMap:refreshRes()
	self:refreshTopText()
	self:getSubLevelList(self.subMapID,
	function()
		self:createSubInfo(self.refreshSubId)
	end,
	true)
end

--[[创建关卡详情]]
function SubMap:createSubInfo(subMapId)
	self:removeChildByTag(addInfoLayerTag, true)
	if self:getChildByTag(addInfoLayerTag) == nil then
		self.dramainfoLayer = require("game.Maps.SubMapInfoLayer").new(
		subMapId,
		self._subMapInfo,
		function(hasChange) --关闭调用
			self:update()
			if hasChange then
				self:updateEnter()
			end
		end,
		function() --购买关卡次数后调用
			self.dramainfoLayer:removeSelf()
			self.dramainfoLayer = nil
			self:refreshRes()
		end)
		self:addChild(self.dramainfoLayer, SCENE_INFO_ZORDER)
		self.dramainfoLayer:setTag(addInfoLayerTag)
		self.refreshSubId = subMapId
	end
end

function SubMap:createMapNode()
	self._data = {}
	if not self.cellSize then
		self.cellSize = require("game.Maps.SubMapScrollCell").new():getContentSize()
	end
	for k, v in pairs(self._subMapInfo["1"]) do
		if tonumber(k) <= game.player.m_maxLevel then
			table.insert(self._data, {
			id = checkint(k),
			cnt = v.cnt,
			star = v.star,
			baseInfo = data_battle_battle[checkint(k)]
			})
		end
	end
	table.sort(self._data, function(l, r)
		return l.id > r.id
	end)
	
	--进入关卡详情
	local function onItemDetail(idx)
		local subMapId = self._data[idx].baseInfo
		DramaMgr.runDramaBefNpc(self._data[idx].baseInfo, function()
			self:removeChildByTag(addInfoLayerTag)
			if self:getChildByTag(addInfoLayerTag) == nil then
				self:createSubInfo(subMapId)
				if idx ~= 1 or self._scrollItemList:getCellNum() == #self.subMapInfo.arr_battle then
					game.player.submapOffsetId = self.subMapInfo.id
					game.player:setSubmapOffset(self._scrollItemList:getContentOffset())
				else
					game.player:setSubmapOffset(cc.p(0, 0))
				end
			end
			self.refreshSubId = subMapId
		end)
	end
	if self._scrollItemList == nil then
		self._scrollItemList = require("utility.TableViewExt").new({
		size = self._listViewSize,
		direction = kCCScrollViewDirectionVertical,
		createFunc = function(idx)
			local item = require("game.Maps.SubMapScrollCell").new()
			idx = idx + 1
			return item:create({
			viewSize = self._listViewSize,
			itemData = self._data[idx],
			idx = idx,
			mapInfo = self._subMapInfo,
			onBtn = function(idx)
				if not self.hasBagState then
					show_tip_label(common:getLanguageString("@DataInRequest"))
					return
				end
				if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true then
					ResMgr.isInSubInfo = true
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					onItemDetail(idx + 1)
				end
			end
			})
		end,
		refreshFunc = function(cell, idx)
			idx = idx + 1
			cell:refresh({
			idx = idx,
			itemData = self._data[idx],
			mapInfo = self._subMapInfo
			})
		end,
		cellNum = #self._data,
		cellSize = self.cellSize,
		touchFunc = function(cell)
		end,
		scrollFunc = function()
			PageMemoModel.saveOffset("submap_" .. self.subMapID, self._scrollItemList)
		end
		})
		self._scrollItemList:setPosition(0, 5)
		self._listViewNode:removeAllChildrenWithCleanup(true)
		self._listViewNode:addChild(self._scrollItemList)
	else
		self._scrollItemList:resetListByNumChange(#self._data)
	end
	
	if self.isRefreshList ~= true then
		PageMemoModel.resetOffset("submap_" .. self.subMapID, self._scrollItemList)
	else
		PageMemoModel.saveOffset("submap_" .. self.subMapID, self._scrollItemList)
	end
	
	local cell = self._scrollItemList:cellAtIndex(0)
	if cell ~= nil then
		local btn = cell:getBtn()
		TutoMgr.addBtn("putongfuben_btn_niujiacunliebiao1", btn)
	end
	
	TutoMgr.addBtn("submap_btn_zhenrong", self._rootnode.zhenrongBtn)
	TutoMgr.addBtn("submap_back_btn", self._rootnode.backBtn)
end

function SubMap:updateEnter()
	local soundName = ResMgr.getSound(data_world_world[self.subMapInfo.world].bgm)
	GameAudio.playMusic(soundName, true)
	local levelName
	local battleData = game.player:getBattleData()
	--dump("battll data")
	--dump(battleData)
	if battleData.new_subMapId > battleData.cur_subMapId then
		game.player:setBattleData({
		cur_subMapId = battleData.new_subMapId
		})
		if battleData.new_subMapId ~= 1101 then
			levelName = data_field_field[battleData.new_subMapId].name
			local newMapLayer = require("game.Maps.SubmapNewMsg").new(common:getLanguageString("@NewDungeonUnlock"), levelName)
			self:addChild(newMapLayer, NEWLEVEL_ZORDER)
			newMapLayer:setTag(newMapLayerTag)
		end
	else
		self:removeChildByTag(newMapLayerTag, true)
	end
	local levelData = game.player:getLevelUpData()
	if levelData.isLevelUp then
		local _, systemIds = OpenCheck.checkIsOpenNewFuncByLevel(levelData.beforeLevel, levelData.curLevel)
		game.player:updateLevelUpData({isLevelUp = false})
		local function createOpenLayer()
			if #systemIds > 0 then
				local systemId = systemIds[1]
				local jumpToMainScene = function()
					GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
				end
				ResMgr.createMaskLayer(display.getRunningScene())
				local openLayer = require("game.OpenSystem.OpenLayer").new({
				systemId = systemId,
				confirmFunc = createOpenLayer,
				goFunc = jumpToMainScene
				})
				self:addChild(openLayer, OPENLAYER_ZORDER)
				table.remove(systemIds, 1)
			end
		end
		createOpenLayer()
	end
	self:refreshTopText()
end

function SubMap:onEnter()
	game.runningScene = self:getParent()
	self:regNotice()
	if device.platform == "windows" or device.platform == "mac" then
		ResMgr.showTextureCache()
	end
	self:updateEnter()
end

function SubMap:onExit()
	self:unregNotice()
	TutoMgr.removeBtn("putongfuben_btn_niujiacunliebiao1")
	TutoMgr.removeBtn("submap_back_btn")
	TutoMgr.removeBtn("submap_baoxiang_box")
	display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	display.removeSpriteFrameByImageName("fonts/font_title.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun1_piaodong/yun_1.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun2_piaodong/yun_2.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun3_piaodong/yun_3.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun4_piaodong/yun_4.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun1_sankai/yun_1.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun2_sankai/yun_2.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun3_sankai/yun_3.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/yun4_sankai/yun_4.png")
	ResMgr.ReleaseUIArmature("fubenjiangli_shanguang")
	display.removeSpriteFrameByImageName("ui/jpg_bg/bigmap/" .. data_world_world[self.subMapInfo.world].background .. ".jpg")
	display.removeSpriteFrameByImageName("ui/ui_bigmap_cloud.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	collectgarbage("collect")
end

return SubMap
local eventHeroColor = "#F7AD24"
local eventContentColor = "#5C2614"
local eventNumColor = "#3E7EC3"
local eventRewardColor = "#830E85"
local itemDropHeroColor = "#57B867"
local itemDropContentColor = "#4A3218"
local enumChuangState = {
free = 0,
going = 1,
finished = 2
}
local data_chuangdang_chuangdang = require("data.data_chuangdang_chuangdang")
local data_card_card = require("data.data_card_card")
local data_item_item = require("data.data_item_item")
local data_chuangdangtext_chuangdangtext = require("data.data_chuangdangtext_chuangdangtext")

local chuangDangMap = class("chuangDangMap", function()
	return CCTableViewCell:new()
end)

function chuangDangMap:getContentSize()
	return cc.size(160, 184)
end

function chuangDangMap:ctor()
	
end

function chuangDangMap:create(param)
	local _viewSize = param.viewSize
	local _itemData = param.itemData
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("chuangdang/chuangdang_head_map_cell.ccbi", proxy, self._rootnode)
	self:addChild(node)
	local size = self:getContentSize()
	node:setPosition(size.width * 0.5, size.height * 0.5)
	self.nameLabel = self._rootnode.map_name
	self.goingLabel = self._rootnode.runing_node
	self:setHighLight(false)
	self:refresh(param)
	return self
end

function chuangDangMap:refresh(param)
	self.idx = param.idx
	self.itemData = param.itemData
	self:setChuangStatus(self.itemData.status)
	local mapData = data_chuangdang_chuangdang[self.itemData.mapId]
	local sprite = self._rootnode.nodeIcon:getChildByTag(10000)
	if sprite then
		sprite:removeFromParentAndCleanup(true)
	end
	
	local mapIconName = "lvl/" .. mapData.icon .. ".png"
	local mapBg
	if game.player.getLevel() < data_chuangdang_chuangdang[self.itemData.mapId].lockLv then
		mapBg = display.newGraySprite(mapIconName, {
		0.4,
		0.4,
		0.4,
		0.1
		})
	else
		mapBg = display.newSprite(mapIconName)
	end
	mapBg:setTag(10000)
	mapBg:setScale(0.8)
	self._rootnode.icon_node:setVisible(false)
	self._rootnode.nodeIcon:addChild(mapBg)
	self.nameLabel:setString(mapData.name)
	self:setHighLight(param.beSelect)
end

function chuangDangMap:getIdx(param)
	return self.idx
end

function chuangDangMap:setHighLight(selected)
	self._rootnode.high_light_node:setVisible(selected)
end

function chuangDangMap:setChuangStatus(status)
	if status == enumChuangState.finished then
		self._rootnode.redNode:setVisible(true)
		self.goingLabel:setVisible(false)
	elseif status == enumChuangState.going then
		self.goingLabel:setVisible(true)
		self._rootnode.redNode:setVisible(false)
	else
		self.goingLabel:setVisible(false)
		self._rootnode.redNode:setVisible(false)
	end
end

local msg = {
--[[闯荡详情]]
getChuangInfo = function(param)
	local _callback = param.callback
	local msg = {m = "chuang", a = "info"}
	RequestHelper.request(msg, _callback, param.errback)
end,
--[[开始闯荡]]
enterChuang = function(param)
	local _callback = param.callback
	local msg = {
	m = "chuang",
	a = "enter",
	mapId = param.mapId,
	cardId = param.cardId,
	duration = param.duration,
	level = param.level
	}
	RequestHelper.request(msg, _callback, param.errback)
end,
--[[闯荡领奖]]
getChuangReward = function(param)
	local _callback = param.callback
	local msg = {
	m = "chuang",
	a = "reward",
	mapId = param.mapId
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}

local ChuangDangScene = class("ChuangDangScene", function()
	return require("game.BaseScene").new({})
end)

local ChuangDangHeadHeight = 194

function ChuangDangScene:ctor()
	ResMgr.removeBefLayer()
	local proxy = CCBProxy:create()
	self.timeNode = display.newNode()
	self:addChild(self.timeNode)
	dump(self._rootnode)
	self._top_height = self:getTopHeight()
	self._bottom_height = self:getBottomHeight()
	local centerH = self:getCenterHeight() - ChuangDangHeadHeight
	local viewSize = cc.size(display.width, centerH)
	self._viewSize = cc.size(display.width, self:getCenterHeight())
	local node = CCBuilderReaderLoad("chuangdang/chuangdang_main_scene.ccbi", proxy, self._rootnode, self, viewSize)
	node:setPosition(display.cx, self._bottom_height + centerH)
	self:addChild(node, 1)
	self._baseNode = node
	
	self.selectMapIndex = 1
	
	display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
	self.chuangMapInfo = {}
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.headList:getContentSize().width, self._rootnode.headList:getContentSize().height),
	createFunc = function(idx)
		idx = idx + 1
		local item = chuangDangMap.new()
		return item:create({
		itemData = self.chuangMapInfo[idx],
		idx = idx,
		beSelect = self.selectMapIndex == idx
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self.chuangMapInfo[idx],
		beSelect = self.selectMapIndex == idx
		})
	end,
	cellNum = #self.chuangMapInfo,
	cellSize = chuangDangMap.new():getContentSize(),
	touchFunc = function(cell)
		local idx = cell:getIdx()
		if self.selectMapIndex == idx then
			return
		elseif game.player.getLevel() < data_chuangdang_chuangdang[idx].lockLv then
			show_tip_label(common:getLanguageString("@LevelOpen", data_chuangdang_chuangdang[idx].lockLv))
			return
		end
		local oldCell = self._scrollItemList:cellAtIndex(self.selectMapIndex - 1)
		if oldCell then
			oldCell:setHighLight(false)
		end
		cell:setHighLight(true)
		self:selectMap(idx)
	end
	})
	self._scrollItemList:setPosition(ccp(0, 0))
	self._rootnode.headList:addChild(self._scrollItemList)
	local size = self._rootnode.items_list_node:getContentSize()
	self._rootnode.items_list_node:setContentSize(CCSizeMake(size.width, size.height - 6))
	local size = self._rootnode.event_list_node:getContentSize()
	self._rootnode.event_list_node:setContentSize(CCSizeMake(size.width, size.height - 6))
	local scrollViewSize = self._rootnode.items_list_node:getContentSize()
	local scrollView = CCScrollView:create()
	scrollView:setViewSize(scrollViewSize)
	scrollView:setPosition(cc.p(0, 0))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:setClippingToBounds(true)
	scrollView:setBounceable(true)
	self._rootnode.items_list_node:addChild(scrollView)
	scrollView:setAnchorPoint(cc.p(0, 0))
	local innnerlayout = CCNode:create()
	scrollView:setContainer(innnerlayout)
	self._innnerlayout = innnerlayout
	self._scrollViewSize = scrollViewSize
	self._scrollView = scrollView
	local eventViewSize = self._rootnode.event_list_node:getContentSize()
	local eventScrollView = CCScrollView:create()
	eventScrollView:setViewSize(eventViewSize)
	eventScrollView:setPosition(cc.p(0, 0))
	eventScrollView:setDirection(kCCScrollViewDirectionVertical)
	eventScrollView:setClippingToBounds(true)
	eventScrollView:setBounceable(true)
	self._rootnode.event_list_node:addChild(eventScrollView)
	eventScrollView:setAnchorPoint(cc.p(0, 0))
	local eventInnnerlayout = CCNode:create()
	eventScrollView:setContainer(eventInnnerlayout)
	self._eventInnnerlayout = eventInnnerlayout
	self._eventScrollView = eventScrollView
	self._eventViewSize = eventViewSize
	self:initSelectInfo()
	
	--开始闯荡
	self._rootnode.start_btn:setEnabled(false)
	self._rootnode.start_btn:addHandleOfControlEvent(function(sender, eventName)
		local mapInfo = self.chuangMapInfo[self.selectMapIndex]
		if mapInfo.status == enumChuangState.free then
			self:startChuangDang()
		elseif mapInfo.status == enumChuangState.finished then
			self:getChuangReward()
		end
	end,
	CCControlEventTouchUpInside)
	
	--详情
	self._rootnode.act_desc:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local layer = require("game.SplitStove.SplitDescLayer").new(41)
		--self:addChild(layer, 1000)
		CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
	end,
	CCControlEventTouchUpInside)
	
end

function ChuangDangScene:setStartTipLbl()
	local mapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[mapInfo.mapId]
	mapInfo.duration = mapInfo.duration == 0 and 1 or mapInfo.duration
	mapInfo.level = mapInfo.level == 0 and 1 or mapInfo.level
	local duration = mapInfo.duration
	local level = mapInfo.level
	local text
	if level == 1 then
		text = mapData.tili[duration] .. common:getLanguageString("@PhysicalPower")
	else
		text = mapData.yuanbao[duration] .. common:getLanguageString("@Goldlabel")
	end
	self._rootnode.start_lbl:setVisible(true)
	self._rootnode.start_lbl:setString(common:getLanguageString("@Expend") .. text)
end

function ChuangDangScene:updateTime()
	if self.chuangMapInfo == nil or #self.chuangMapInfo == 0 then
		return
	end
	for key, mapInfo in pairs(self.chuangMapInfo) do
		if mapInfo.status == enumChuangState.going then
			local mapData = data_chuangdang_chuangdang[mapInfo.mapId]
			if self._curTime >= mapData.waitTime[mapInfo.duration] + mapInfo.startTime then
				mapInfo.status = enumChuangState.finished
				if key == self.selectMapIndex then
					self:selectMap(self.selectMapIndex)
				else
					local cell = self._scrollItemList:cellAtIndex(key - 1)
					if cell then
						cell:refresh({idx = key, itemData = mapInfo})
					end
				end
			end
		end
	end
	local mapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[mapInfo.mapId]
	if mapInfo.status == enumChuangState.going then
		local timeCount = mapInfo.startTime - self._curTime
		local needTime = mapData.waitTime[mapInfo.duration] + timeCount
		local timeLbl = format_time(math.floor(needTime))
		self._rootnode.start_lbl:setString(common:getLanguageString("@LeftTime") .. ":" .. timeLbl)
		if mapInfo.timeLength then
			local timeLength = math.floor((0 - timeCount) / mapData.timeInterval[mapInfo.level])
			if timeLength > mapInfo.timeLength then
				self:selectMap(self.selectMapIndex)
			end
		end
	end
end

function ChuangDangScene:setStartBtn()
	local mapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[mapInfo.mapId]
	local btn = self._rootnode.start_btn
	if mapInfo.status == enumChuangState.free then
		btn:setEnabled(true)
		resetctrbtnString(btn, common:getLanguageString("@ChuangDangTitle"))
		self:setStartTipLbl()
		self._rootnode.start_lbl:setVisible(true)
	elseif mapInfo.status == enumChuangState.going then
		btn:setEnabled(false)
		resetctrbtnString(btn, common:getLanguageString("@ChuangDangIng"))
		self._rootnode.start_lbl:setVisible(true)
		local needTime = mapData.waitTime[mapInfo.duration] + mapInfo.startTime - self._curTime
		local timeLbl = format_time(math.floor(needTime))
		self._rootnode.start_lbl:setString(common:getLanguageString("@LeftTime") .. ":" .. timeLbl)
	else
		btn:setEnabled(true)
		self._rootnode.start_lbl:setVisible(false)
		resetctrbtnString(btn, common:getLanguageString("@lingjiang"))
	end
end

function ChuangDangScene:changeMenuImage(curIndex, maxIndex, name)
	curIndex = curIndex or 1
	for i = 1, maxIndex do
		local menu = self._rootnode[name .. i]
		local spriteName = "#item_board_" .. (curIndex == i and "" or "un") .. "selected.png"
		menu:setDisplayFrame(display.newSprite(spriteName):getDisplayFrame())
	end
	if self.chuangMapInfo then
		local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
		curMapInfo[name .. "index"] = curIndex
		if name == "levelSelectBtn_" then
			curMapInfo.level = curIndex
			self:checkHeroSepicalSign()
		else
			curMapInfo.duration = curIndex
		end
	end
	self:setStartTipLbl()
end

function ChuangDangScene:checkHeroSepicalSign()
	local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
	local hero = curMapInfo.selectHero
	if not hero then
		return
	end
	local heroNode = self._rootnode.iconPos
	local specialTbl = self._specialMapTbl[self.selectMapIndex][curMapInfo.level]
	if specialTbl[hero.resId] and hero.cls >= specialTbl[hero.resId] then
		if heroNode.sepicalSign and tolua.cast(heroNode.sepicalSign, "cc.Sprite") then
			heroNode.sepicalSign:setVisible(true)
		else
			local sprite = display.newSprite("ui/ui_CommonResouces/chuang_special_sign.png")
			heroNode:addChild(sprite)
			sprite:setPosition(28, 28)
			heroNode.sepicalSign = sprite
		end
	elseif heroNode.sepicalSign and tolua.cast(heroNode.sepicalSign, "cc.Sprite") then
		heroNode.sepicalSign:setVisible(false)
	end
end

function ChuangDangScene:changehero(hero)
	local heroNode = self._rootnode.iconPos
	heroNode:removeAllChildren()
	heroNode.sepicalSign = nil
	self._rootnode.add_hero_lbl:setVisible(true)
	if not self.chuangMapInfo then
		return
	end
	local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
	if not hero then
		curMapInfo.selectHero = nil
		return
	end
	if hero.mapIndex then
		self.chuangMapInfo[hero.mapIndex].selectHero = nil
	end
	curMapInfo.selectHero = hero
	curMapInfo.selectHero.mapIndex = self.selectMapIndex
	self._rootnode.add_hero_lbl:setVisible(false)
	local heroIcon = ResMgr.refreshIcon({
	itemBg = nil,
	cls = curMapInfo.selectHero.cls,
	id = curMapInfo.selectHero.resId,
	resType = ResMgr.HERO
	})
	heroNode:addChild(heroIcon)
	local nameStr = data_card_card[curMapInfo.selectHero.resId].name
	if curMapInfo.selectHero.cls > 0 then
		nameStr = nameStr .. " +" .. curMapInfo.selectHero.cls
	end
	local nameColor = ResMgr.getItemNameColorByType(curMapInfo.selectHero.resId, ResMgr.HERO)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = nameStr,
	size = 20,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	})
	local itemSize = heroIcon:getContentSize()
	nameLbl:setPosition(itemSize.width / 2, -12)
	heroIcon:addChild(nameLbl)
	self:checkHeroSepicalSign()
end

function ChuangDangScene:initSelectInfo()
	for i = 1, 3 do
		self._rootnode["timeSelectBtn_" .. i]:setTouchEnabled(true)
		self._rootnode["timeSelectBtn_" .. i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				self:changeMenuImage(i, 3, "timeSelectBtn_")
				return true
			end
		end)
	end
	for i = 1, 2 do
		self._rootnode["levelSelectBtn_" .. i]:setTouchEnabled(true)
		self._rootnode["levelSelectBtn_" .. i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				self:changeMenuImage(i, 2, "levelSelectBtn_")
				return true
			end
		end)
	end
	self._rootnode.add_hero_btn:setTouchEnabled(true)
	self._rootnode.add_hero_btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			if not self._heroReslist then
				show_tip_label(common:getLanguageString("@DataInRequest"))
			else
				local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
				local layer = require("game.Huodong.ChuangDang.ChuangDangSelectHeroLayer").new({
				viewSize = self._viewSize,
				heroList = self._heroReslist,
				mapInfo = curMapInfo,
				specialMapTbl = self._specialMapTbl[curMapInfo.mapId][curMapInfo.level],
				callBackFunc = function(hero)
					self._baseNode:setVisible(true)
					if hero then
						self:changehero(hero)
					end
				end
				})
				self:addChild(layer, 1)
				self._baseNode:setVisible(false)
				layer:setPosition(display.width * 0.5, self._bottom_height)
			end
			return true
		end
	end)
	self._specialMapTbl = {}
	for key, mapInfo in pairs(data_chuangdang_chuangdang) do
		local tbl = {}
		tbl[1] = {}
		tbl[2] = {}
		for i, resId in pairs(mapInfo.role1) do
			if resId > 0 then
				tbl[1][resId] = mapInfo.cls1[i]
			end
		end
		for i, resId in pairs(mapInfo.role2) do
			if resId > 0 then
				tbl[2][resId] = mapInfo.cls2[i]
			end
		end
		self._specialMapTbl[key] = tbl
	end
	self._dropTbl = {}
	local data_chuangdangdrop_chuangdangdrop = require("data.data_chuangdangdrop_chuangdangdrop")
	for key, dropItem in pairs(data_chuangdangdrop_chuangdangdrop) do
		if not self._dropTbl[dropItem.group] then
			self._dropTbl[dropItem.group] = {}
		end
		dropItem.id = dropItem.itemId
		table.insert(self._dropTbl[dropItem.group], dropItem)
	end
	local function showDropInfo(index)
		if self._showDropIndex == index then
			return
		end
		if index == 1 then
			self:showprimaryDropInfo()
		else
			self:showAdvancedDropInfo()
		end
	end
	CtrlBtnGroupAsMenu({
	self._rootnode.drop_preshow_btn_1,
	self._rootnode.drop_preshow_btn_2
	}, function(idx)
		showDropInfo(idx)
	end)
end

function ChuangDangScene:setTimeLang()
	local mapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[mapInfo.mapId]
	for i = 1, 3 do
		local t = mapData.waitTime[i]
		local hour = math.floor(t / 3600)
		local min = math.floor(t % 3600 / 60)
		local timeLbl = common:getLanguageString("@ChuangDangTitle") .. (hour > 0 and hour .. common:getLanguageString("@TimeHourLbl") or "") .. (min > 0 and min .. common:getLanguageString("@ChuangMinuteTime") or "")
		self._rootnode["timeSelectLbl_" .. i]:setString(timeLbl)
	end
end

function ChuangDangScene:startChuangDang()
	local mapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[mapInfo.mapId]
	local cost
	if not mapInfo.selectHero then
		show_tip_label(common:getLanguageString("@ChuangStartTip1"))
		return
	elseif mapInfo.level == 1 then
		cost = mapData.tili[mapInfo.duration]
		if cost > game.player:getStrength() then
			self:addChild(require("game.Maps.TiliMsgBox").new({
			updateListen = function()
				PostNotice(NoticeKey.CommonUpdate_Label_Tili)
			end
			}), 100)
			return
		end
	else
		cost = mapData.yuanbao[mapInfo.duration]
		if cost > game.player:getGold() then
			show_tip_label(common:getLanguageString("@PriceEnough"))
			return
		end
	end
	
	local function callBackFunc(data)
		local mapInfo = data
		if mapInfo.level == 2 then --高级
			game.player:setGold(game.player:getGold() - cost)
			PostNotice(NoticeKey.CommonUpdate_Label_Gold)
		end
		mapInfo.startTime = mapInfo.startTime / 1000
		self._heroReslist[mapInfo.resId].isChuangDang = true
		self.chuangMapInfo[self.selectMapIndex] = mapInfo
		self:selectMap(self.selectMapIndex)
		local oldCell = self._scrollItemList:cellAtIndex(self.selectMapIndex - 1)
		oldCell:setChuangStatus(enumChuangState.going)
	end
	
	--开始闯荡
	msg.enterChuang({
	mapId = mapInfo.mapId,
	cardId = mapInfo.selectHero._id,
	duration = mapInfo.duration,
	level = mapInfo.level,
	callback = callBackFunc
	})
end

local itemX = 64
local itemOffset = 115
local itemInfoSize = cc.size(600, 120)

function ChuangDangScene:create5Items(items)
	local baseNode = CCNode:create()
	baseNode:setContentSize(itemInfoSize)
	for i = 1, 5 do
		if items[i] then
			local newSprite = display.newSprite()
			ResMgr.refreshItemWithTagNumName({
			itemBg = newSprite,
			itemType = items[i].type,
			id = items[i].id,
			itemNum = items[i].num,
			isShowIconNum = items[i].num == 1 and 0
			})
			baseNode:addChild(newSprite)
			newSprite:setPosition(itemX + itemOffset * (i - 1), 50)
			newSprite.item = items[i]
			local touchNode = require("utility.MyLayer").new({
			size = newSprite:getContentSize(),
			swallow = false,
			touch = true,
			parent = newSprite,
			touchHandler = function(event, btn)
				if event.name == "ended" and math.abs(event.y - event.startY) <= 5 then
					local itemInfo = require("game.Huodong.ItemInformation").new({
					id = newSprite.item.id,
					type = newSprite.item.type
					})
					self:addChild(itemInfo, 9999)
				end
			end
			})
		end
	end
	return baseNode
end

function ChuangDangScene:createSepicalItemNode(nodeType, resId, cls, dropIndex, isLast)
	local baseNode = CCNode:create()
	local height = 0
	local text
	if nodeType == 1 then
		text = "<font size=\"20\" color=\"" .. itemDropContentColor .. "\">" .. common:getLanguageString("@ChuangSepialTitle1") .. "</font>" .. "<font size=\"20\" color=\"" .. itemDropHeroColor .. "\">+" .. cls .. "</font>" .. "<font size=\"20\" color=\"" .. itemDropContentColor .. "\">" .. common:getLanguageString("@ChuangSepialTitle2") .. "</font>" .. "<font size=\"20\" color=\"" .. itemDropHeroColor .. "\">" .. "[" .. data_card_card[resId].name .. "]" .. "</font>" .. "<font size=\"20\" color=\"" .. itemDropContentColor .. "\">" .. common:getLanguageString("@ChuangSepialTitle3") .. "</font>"
	else
		local mapNameLbl = "[" .. data_chuangdang_chuangdang[resId].name .. "-" .. common:getLanguageString(cls == 1 and "@ChuangLevelNormal" or "@ChuangLevelDiffcult") .. "]"
		text = "<font size=\"20\" color=\"" .. itemDropContentColor .. "\">" .. common:getLanguageString("@ChuangSepialTitle4") .. "</font>" .. "<font size=\"20\" color=\"" .. itemDropHeroColor .. "\">" .. mapNameLbl .. "</font>" .. "<font size=\"20\" color=\"" .. itemDropContentColor .. "\">" .. common:getLanguageString("@ChuangSepialTitle3") .. "</font>"
	end
	local dropTbl = self._dropTbl[dropIndex]
	if not isLast then
		local lineSprite = display.newSprite("#line_point.png")
		lineSprite:setScaleX(270)
		baseNode:addChild(lineSprite)
		lineSprite:setPosition(itemInfoSize.width * 0.5 - 5, 5)
	end
	local numOneLine = 5
	local lineNums = 0
	local newItemTbl = {}
	for index = 1, #dropTbl, numOneLine do
		local items = {}
		for i = 0, numOneLine - 1 do
			if dropTbl[index + i] then
				table.insert(items, dropTbl[index + i])
			end
		end
		lineNums = lineNums + 1
		table.insert(newItemTbl, items)
	end
	local richText = getRichText(text, itemInfoSize.width - 40)
	baseNode:addChild(richText)
	height = itemInfoSize.height * #newItemTbl + 10 + richText:getContentSize().height
	baseNode:setContentSize(cc.size(itemInfoSize.width, height))
	richText:setPosition(20, height - richText.offset)
	for key, items in pairs(newItemTbl) do
		local itemNode = self:create5Items(items)
		baseNode:addChild(itemNode)
		itemNode:setPosition(0, 30 + itemInfoSize.height * (#newItemTbl - key))
	end
	return baseNode
end

function ChuangDangScene:showDropItemInfo(levelIndex)
	self._innnerlayout:removeAllChildren()
	local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[curMapInfo.mapId]
	local height = 0
	local nodeTbl = {}
	local innerBg = display.newScale9Sprite("#c_bg_2.png")
	self._innnerlayout:addChild(innerBg)
	innerBg:setPosition(self._scrollViewSize.width * 0.5, 0)
	innerBg:setAnchorPoint(cc.p(0.5, 0))
	local roleTbl = mapData["role" .. levelIndex]
	local drowNum = 0
	for i = #roleTbl, 1, -1 do
		local resId = roleTbl[i]
		if resId > 0 then
			drowNum = drowNum + 1
			local baseNode = self:createSepicalItemNode(1, resId, mapData["cls" .. levelIndex][i], mapData["roleDrop" .. levelIndex][i], i == #roleTbl)
			self._innnerlayout:addChild(baseNode)
			baseNode:setPosition(0, height)
			height = baseNode:getContentSize().height + height
		end
	end
	local baseNode = self:createSepicalItemNode(2, curMapInfo.mapId, levelIndex, mapData.randomDrop[levelIndex], drowNum == 0)
	self._innnerlayout:addChild(baseNode)
	baseNode:setPosition(0, height)
	height = baseNode:getContentSize().height + height
	local maxHight = height
	self._innnerlayout:setContentSize(cc.size(self._scrollViewSize.width, maxHight))
	innerBg:setContentSize(cc.size(self._scrollViewSize.width - 8, maxHight))
	self._scrollView:setContentOffset(cc.p(0, self._scrollViewSize.height - maxHight))
end

function ChuangDangScene:showprimaryDropInfo()
	self._showDropIndex = 1
	self:showDropItemInfo(1)
end

function ChuangDangScene:showAdvancedDropInfo()
	self._showDropIndex = 2
	self:showDropItemInfo(2)
end
local timeStartPosX = 20
local eventLblWidth
local eventFontSize = 20
local turnColortoCcc3 = function(color_str)
	local colorStr = string.sub(color_str, 2)
	local color = cc.c3b(checkint(string.format("%d", "0x" .. string.sub(colorStr, 1, 2))), checkint(string.format("%d", "0x" .. string.sub(colorStr, 3, 4))), checkint(string.format("%d", "0x" .. string.sub(colorStr, 5, 6))))
	return color
end

function ChuangDangScene:createEventNode(type, eventTime, eventTbl, heroName, mapName)
	local baseNode = CCNode:create()
	local timeLbl = os.date("[%H:%M]", math.ceil(tonumber(eventTime)))
	local timeNode = ResMgr.createNomarlMsgTTF({text = timeLbl})
	local timeLblSize = timeNode:getContentSize()
	if not eventLblWidth then
		eventLblWidth = self._eventViewSize.width - timeStartPosX - timeLblSize.width - 30
	end
	local eventLbl
	local goingLbl
	baseNode:setAnchorPoint(0, 0)
	if type == 0 then --开始闯荡xxx
		local text = "<font size=\"20\" color=\"" .. eventHeroColor .. "\">" .. heroName .. "</font><font size=\"20\" color=\"" .. eventContentColor .. "\">" .. common:getLanguageString("@ChuangDangEvent1", mapName) .. "</font>"
		eventLbl = getRichText(text, eventLblWidth)
	elseif type == 1 then --正在闯荡
		eventLbl = ui.newTTFLabel({
		text = heroName,
		size = eventFontSize,
		color = turnColortoCcc3(eventHeroColor),
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		eventLbl:setAnchorPoint(0, 0.5)
		goingLbl = ui.newTTFLabel({
		text = common:getLanguageString("@ChuangDangEvent2"),
		size = eventFontSize,
		color = turnColortoCcc3(eventContentColor),
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT,
		dimensions = cc.size(eventLblWidth, 0)
		})
		baseNode.runingIndex = 0
		
		local function runingIndex()
			baseNode.runingIndex = baseNode.runingIndex + 1
			if baseNode.runingIndex > 6 then
				baseNode.runingIndex = 0
			end
			local pointLbl = ""
			for i = 1, baseNode.runingIndex do
				pointLbl = pointLbl .. "."
			end
			goingLbl:setString(common:getLanguageString("@ChuangDangEvent2") .. pointLbl)
			local timeLbl = os.date("[%H:%M]", math.ceil(tonumber(self._curTime)))
			timeNode:setString(timeLbl)
		end
		baseNode:schedule(runingIndex, 1)
	elseif type == 2 then --完成了本次闯荡，获得了xxx
		local text = "<font size=\"20\" color=\"" .. eventHeroColor .. "\">" .. heroName .. "</font>" .. "<font size=\"20\" color=\"" .. eventContentColor .. "\">" .. common:getLanguageString("@ChuangDangEvent3") .. "</font>"
		for key, reward in pairs(eventTbl) do
			local resType = ResMgr.getResType(reward.type)
			local rewardName = ResMgr.getItemNameByType(reward.id, resType)
			text = text .. "<font size=\"20\" color=\"" .. eventNumColor .. "\">" .. reward.num .. "</font>" .. "<font size=\"20\" color=\"" .. eventRewardColor .. "\">" .. rewardName .. "</font>"
		end
		eventLbl = getRichText(text, eventLblWidth)
	else
		local resType = ResMgr.getResType(eventTbl.type)
		local rewardName = ResMgr.getItemNameByType(eventTbl.id, resType)
		local text = "<font size=\"20\" color=\"" .. eventContentColor .. "\">" .. data_chuangdangtext_chuangdangtext[eventTbl.eventId].content .. "</font>"
		text = common:fill(text, "</font><font size=\"20\" color=\"" .. eventHeroColor .. "\">" .. heroName .. "</font><font size=\"20\" color=\"" .. eventContentColor .. "\">", "</font><font size=\"20\" color=\"" .. eventNumColor .. "\">" .. eventTbl.num .. "</font><font size=\"20\" color=\"" .. eventContentColor .. "\">", "</font><font size=\"20\" color=\"" .. eventRewardColor .. "\">" .. rewardName .. "</font><font size=\"20\" color=\"" .. eventContentColor .. "\">")
		eventLbl = getRichText(text, eventLblWidth)
	end
	local eventLblSize = eventLbl:getContentSize()
	baseNode:setContentSize(cc.size(self._eventViewSize.width, eventLblSize.height + 10))
	
	timeNode:align(display.LEFT_TOP, timeStartPosX, eventLblSize.height + 5)
	baseNode:addChild(timeNode)
	baseNode:addChild(eventLbl)
	
	if type ~= 1 then
		eventLbl:setPosition(timeStartPosX + timeLblSize.width + 6, eventLblSize.height - eventLbl.offset + 5)
	else
		eventLbl:setPosition(timeStartPosX + timeLblSize.width + 6, eventLblSize.height * 0.5 + 5)
	end
	
	if goingLbl then
		baseNode:addChild(goingLbl)
		local x,y = eventLbl:getPosition()
		goingLbl:align(display.LEFT_CENTER, x + eventLbl:getContentSize().width + 2, y)
	end
	
	baseNode:setAnchorPoint(0, 0)
	return baseNode
end

function ChuangDangScene:showEventInfo()
	self._eventInnnerlayout:removeAllChildren()
	local innerBg = display.newScale9Sprite("#c_bg_2.png")
	self._eventInnnerlayout:addChild(innerBg)
	innerBg:setPosition(self._eventViewSize.width * 0.5, 0)
	innerBg:setAnchorPoint(cc.p(0.5, 0))
	local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[curMapInfo.mapId]
	local eventTbl = {}
	local heroName = data_card_card[curMapInfo.resId].name .. (0 < curMapInfo.cls and "+" .. curMapInfo.cls or "")
	local height = 0
	
	--一次性计算物品奖励，和帮派生产一样
	if curMapInfo.status == enumChuangState.going then
		local timeLength = math.floor((self._curTime - curMapInfo.startTime) / mapData.timeInterval[curMapInfo.level])
		for i = 1, timeLength do
			table.insert(eventTbl, curMapInfo.reward[i])
		end
		local baseNode = self:createEventNode(1, self._curTime, {}, heroName)
		self._eventInnnerlayout:addChild(baseNode)
		baseNode:setPosition(0, 0)
		height = baseNode:getContentSize().height
	elseif curMapInfo.status == enumChuangState.finished then
		for key, item in pairs(curMapInfo.reward) do
			table.insert(eventTbl, item)
		end
		local baseNode = self:createEventNode(2, curMapInfo.startTime + mapData.waitTime[curMapInfo.duration], curMapInfo.finalReward, heroName)
		self._eventInnnerlayout:addChild(baseNode)
		baseNode:setPosition(0, 0)
		height = baseNode:getContentSize().height
	end
	for i = #eventTbl, 1, -1 do
		local curTime = curMapInfo.startTime + mapData.timeInterval[curMapInfo.level] * i
		local baseNode = self:createEventNode(3, curTime, eventTbl[i], heroName)
		self._eventInnnerlayout:addChild(baseNode)
		baseNode:setPosition(0, height)
		height = height + baseNode:getContentSize().height
	end
	local mapAllName = mapData.name .. "-" .. common:getLanguageString(curMapInfo.level == 1 and "@ChuangLevelNormal" or "@ChuangLevelDiffcult")
	local baseNode = self:createEventNode(0, curMapInfo.startTime, {}, heroName, mapAllName)
	self._eventInnnerlayout:addChild(baseNode)
	baseNode:setPosition(0, height)
	height = height + baseNode:getContentSize().height + 10
	innerBg:setContentSize(cc.size(self._eventViewSize.width - 8, height))
	self._eventInnnerlayout:setContentSize(cc.size(self._eventViewSize.width, height))
	if height < self._eventViewSize.height then
		self._eventScrollView:setContentOffset(CCPointMake(0, self._eventViewSize.height - height))
	else
		self._eventScrollView:setContentOffset(CCPointMake(0, 0))
	end
end

function ChuangDangScene:showHasGotInfo()
	self._innnerlayout:removeAllChildren()
	local innerBg = display.newScale9Sprite("#c_bg_2.png")
	self._innnerlayout:addChild(innerBg)
	innerBg:setPosition(self._eventViewSize.width * 0.5, 0)
	innerBg:setAnchorPoint(cc.p(0.5, 0))
	local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
	local mapData = data_chuangdang_chuangdang[curMapInfo.mapId]
	local dropTbl = {}
	if curMapInfo.status == enumChuangState.going then
		local timeLength = math.floor((self._curTime - curMapInfo.startTime) / mapData.timeInterval[curMapInfo.level])
		if timeLength < 0 then
			timeLength = 0
		end
		for i = 1, timeLength do
			table.insert(dropTbl, curMapInfo.reward[i])
		end
		curMapInfo.timeLength = timeLength
	elseif curMapInfo.status == enumChuangState.finished then
		for key, item in pairs(curMapInfo.reward) do
			table.insert(dropTbl, item)
		end
		for key, item in pairs(curMapInfo.finalReward) do
			table.insert(dropTbl, item)
		end
	end
	local sortTbl = {}
	local newDropTbl = {}
	local sortNum = 0
	for i = 1, #dropTbl do
		local key = dropTbl[i].id + dropTbl[i].type * 1000000
		if sortTbl[key] then
			sortTbl[key].num = sortTbl[key].num + dropTbl[i].num
		else
			sortTbl[key] = clone(dropTbl[i])
			newDropTbl[#newDropTbl + 1] = sortTbl[key]
		end
	end
	local numOneLine = 5
	local lineNums = 0
	local newItemTbl = {}
	for index = 1, #newDropTbl, numOneLine do
		local items = {}
		for i = 0, numOneLine - 1 do
			if newDropTbl[index + i] then
				table.insert(items, newDropTbl[index + i])
			end
		end
		lineNums = lineNums + 1
		table.insert(newItemTbl, items)
	end
	local height = 0
	for key = #newItemTbl, 1, -1 do
		local items = newItemTbl[key]
		local baseNode = self:create5Items(items)
		self._innnerlayout:addChild(baseNode)
		baseNode:setPosition(0, height + 20)
		height = height + baseNode:getContentSize().height
	end
	self._innnerlayout:setContentSize(cc.size(self._scrollViewSize.width, height))
	if #newItemTbl > 0 then
		innerBg:setContentSize(cc.size(self._scrollViewSize.width - 8, height))
	else
		innerBg:setVisible(false)
	end
	if height < self._scrollViewSize.height then
		self._scrollView:setContentOffset(cc.p(0, self._scrollViewSize.height - height))
	else
		self._scrollView:setContentOffset(cc.p(0, 0))
	end
end

--[[获取闯荡奖励]]
function ChuangDangScene:getChuangReward()
	local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
	if curMapInfo.status ~= enumChuangState.finished then
		return
	end
	local function callBackFunc(data)
		dump(data)
		local rtnObj = data--.rtnObj
		if rtnObj and #rtnObj.checkBag > 0 then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = rtnObj.checkBag
			})
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
			return
		end
		local curMapInfo = self.chuangMapInfo[self.selectMapIndex]
		if curMapInfo.resId then
			if self._heroReslist[curMapInfo.resId] then
				self._heroReslist[curMapInfo.resId].isChuangDang = false
			end
			curMapInfo.status = enumChuangState.free
			curMapInfo.reward = {}
			curMapInfo.finalReward = {}
			curMapInfo.startTime = 0
			local oldCell = self._scrollItemList:cellAtIndex(self.selectMapIndex - 1)
			oldCell:setChuangStatus(enumChuangState.free)
			self:selectMap(self.selectMapIndex)
		end
		dump(data)
		local items = {}
		local itemKeyTbl = {}
		for key, item in pairs(rtnObj.rtnAry) do
			local keys = item.id + item.t * 100000
			if itemKeyTbl[keys] then
				itemKeyTbl[keys].num = itemKeyTbl[keys].num + item.n
			else
				local resType = ResMgr.getResType(item.t)
				local tbl = {
				id = item.id,
				type = item.t,
				num = item.n,
				iconType = resType
				}
				itemKeyTbl[keys] = tbl
				table.insert(items, tbl)
			end
		end
		local title = common:getLanguageString("@GetRewards")
		local msgBox = require("game.Huodong.RewardMsgBox").new({title = title, cellDatas = items})
		CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
	end
	msg.getChuangReward({
	mapId = curMapInfo.mapId,
	callback = callBackFunc
	})
end

function ChuangDangScene:selectMap(index)
	self.selectMapIndex = index
	local curMapInfo = self.chuangMapInfo[index]
	local mapData = data_chuangdang_chuangdang[curMapInfo.mapId]
	if curMapInfo.status == enumChuangState.free then
		self._rootnode.select_node:setVisible(true)
		self._rootnode.event_node:setVisible(false)
		self:setTimeLang()
		self:changehero(curMapInfo.selectHero)
		self:changeMenuImage(curMapInfo.duration ~= 0 and curMapInfo.duration or 1, 3, "timeSelectBtn_")
		self:changeMenuImage(curMapInfo.level ~= 0 and curMapInfo.level or 1, 2, "levelSelectBtn_")
		self:showprimaryDropInfo()
		self._rootnode.drop_preshow_btn_2:setVisible(true)
		self._rootnode.drop_preshow_btn_2:setEnabled(true)
		local btn = self._rootnode.drop_preshow_btn_1
		btn:setEnabled(false)
		btn:setBackgroundSpriteForState(display.newScale9Sprite("#chuangdang_btn1.png"), CCControlStateNormal)
		btn:setBackgroundSpriteForState(display.newScale9Sprite("#chuangdang_btn1_sel.png"), CCControlStateHighlighted)
		btn:setBackgroundSpriteForState(display.newScale9Sprite("#chuangdang_btn1_sel.png"), CCControlStateDisabled)
	else
		self._rootnode.select_node:setVisible(false)
		self._rootnode.event_node:setVisible(true)
		self._rootnode.drop_preshow_btn_2:setVisible(false)
		self._rootnode.drop_preshow_btn_1:setEnabled(false)
		resetctrbtnimage(self._rootnode.drop_preshow_btn_1, "#chuangdang_btncur.png")
		self:showEventInfo()
		self:showHasGotInfo()
	end
	self:setStartBtn()
end

--[[获取闯荡事件列表]]
function ChuangDangScene:getBaseInfo()
	local function callback(data)
		self.chuangMapInfo = data
		for key, mapInfo in pairs(self.chuangMapInfo) do
			mapInfo.startTime = mapInfo.startTime / 1000
		end
		self._scrollItemList:resetListByNumChange(#self.chuangMapInfo)
		self:selectMap(1)
		local cell = self._scrollItemList:cellAtIndex(0)
		cell:setHighLight(true)
		self.herolist = nil
		RequestHelper.getHeroList({
		callback = function(data)
			local heroReslist = {}
			for key, hero in pairs(data["1"]) do
				if not heroReslist[hero.resId] then
					heroReslist[hero.resId] = hero
				elseif heroReslist[hero.resId].cls < hero.cls then
					heroReslist[hero.resId] = hero
				end
			end
			heroReslist[1] = nil
			heroReslist[2] = nil
			self._heroReslist = heroReslist
			for key, chuangMapInfo in pairs(self.chuangMapInfo) do
				if chuangMapInfo.status == enumChuangState.going and chuangMapInfo.resId and self._heroReslist[chuangMapInfo.resId] then
					self._heroReslist[chuangMapInfo.resId].isChuangDang = true
				end
			end
		end
		})
	end
	msg.getChuangInfo({callback = callback})
end

function ChuangDangScene:onEnter()
	game.runningScene = self
	self:regNotice()
	self:setBroadcast()
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	PostNotice(NoticeKey.CommonUpdate_Label_Silver)
	GameAudio.playMainmenuMusic(true)
	if self._bExit == true then
		self._bExit = false
		local broadcastBg = self._rootnode.broadcast_tag
		game.broadcast:reSet(broadcastBg)
	end
	self:getBaseInfo()
	local function update(dt)
		self._curTime = GameModel.getServerTimeInSec()
		self:updateTime()
	end
	self._curTime = GameModel.getServerTimeInSec()
	self.timeNode:schedule(update, 1)
end

function ChuangDangScene:onExit()
	self.timeNode:stopAllActions()
	self:unregNotice()
	self._bExit = true
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return ChuangDangScene
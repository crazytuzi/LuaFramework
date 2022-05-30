local ZORDER = 100
local listViewDisH = 95

local LevelRewardLayer = class("LevelRewardLayer", function()
	return require("utility.ShadeLayer").new()
end)

function LevelRewardLayer:sendRequest()
	RequestHelper.levelReward.getInfo({
	callback = function(data)
		dump(data)
		if string.len(data["0"]) > 0 then
			CCMessageBox(data["0"], "Tip")
		else
			self:init(data)
		end
	end
	})
end

function LevelRewardLayer:onReward(cell)
	if self.isFull then
		self:addChild(require("utility.LackBagSpaceLayer").new({
		bagObj = self.bagObj,
		callback = function()
			self.isFull = false
		end
		}), ZORDER)
	else
		RequestHelper.levelReward.getReward({
		level = cell:getLevel(),
		callback = function(data)
			cell:setRewardEnabled(true)
			if string.len(data["0"]) > 0 then
				show_tip_label(data["0"])
			else
				table.insert(self.hasRewardLvs, cell:getLevel())
				cell:getReward(self.hasRewardLvs)
				local title = common:getLanguageString("GetRewards")
				local index = cell:getIdx() + 1
				local msgBox = require("game.Huodong.RewardMsgBox").new({
				title = title,
				cellDatas = self.cellDatas[index].itemData
				})
				self:addChild(msgBox, ZORDER)
				game.player:updateMainMenu({
				silver = data["1"].silver,
				gold = data["1"].gold
				})
				PostNotice(NoticeKey.MainMenuScene_Update)
				game.player:setDengjilibao(game.player:getDengjilibao() - 1)
				if self:checkIsCollectAllReward() then
					game.player.m_isSHowDengjiLibao = false
				end
				PostNotice(NoticeKey.MainMenuScene_DengjiLibao)
			end
		end
		})
	end
end

function LevelRewardLayer:checkIsCollectAllReward()
	local collectAll = true
	for _, v in ipairs(self.giftList) do
		local collect = false
		for j, vl in ipairs(self.hasRewardLvs) do
			if v.level == vl then
				collect = true
				break
			end
		end
		if not collect then
			collectAll = false
			break
		end
	end
	return collectAll
end

function LevelRewardLayer:onInformation(param)
	if self._curInfoIndex ~= -1 then
		return
	end
	local index = param.index
	self._curInfoIndex = index
	local iconIdx = param.iconIndex
	local icon_data = self.cellDatas[index + 1].itemData[iconIdx]
	if icon_data then
		dump(icon_data)
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = icon_data.id,
		type = icon_data.type,
		name = icon_data.name,
		describe = icon_data.describe,
		endFunc = function()
			self._curInfoIndex = -1
		end
		})
		self:addChild(itemInfo, ZORDER)
	end
end

function LevelRewardLayer:init(data)
	local data_item_item = require("data.data_item_item")
	self.curLevel = game.player.m_level
	local curLevel_index = 1
	self.hasRewardLvs = data["1"]
	self.isFull = data["2"]
	self.giftList = data["3"]
	self.bagObj = data["4"]
	self.cellDatas = {}
	for i, v in ipairs(self.giftList) do
		if self.curLevel <= v.level then
			curLevel_index = i
		end
		local itemData = {}
		for _, j in ipairs(v.item) do
			local item = data_item_item[j.id]
			local iconType = ResMgr.getResType(j.type)
			if iconType == ResMgr.HERO then
				item = ResMgr.getCardData(j.id)
			end
			table.insert(itemData, {
			id = j.id,
			type = j.type,
			name = item.name,
			iconType = iconType,
			describe = item.describe,
			num = j.num or 0
			})
		end
		table.insert(self.cellDatas, {
		id = v.id,
		level = v.level,
		itemData = itemData
		})
	end
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height - listViewDisH
	local function createFunc(index)
		local item = require("game.Huodong.levelReward.LevelRewardCell").new()
		return item:create({
		id = index,
		curLevel = self.curLevel,
		hasRewardLvs = self.hasRewardLvs,
		level = self.cellDatas[index + 1].level,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		cellData = self.cellDatas[index + 1],
		rewardListener = handler(self, LevelRewardLayer.onReward)
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		level = self.cellDatas[index + 1].level,
		itemData = self.cellDatas[index + 1].itemData
		})
	end
	local cellContentSize = require("game.Huodong.levelReward.LevelRewardCell").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.cellDatas,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		--dump(cell)
		local idx = cell:getIdx()
		for i = 1, 4 do
			local icon = cell:getIcon(i)
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				self:onInformation({
				index = idx,
				iconIndex = i
				})
				break
			end
		end
	end
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self.ListTable)
	self:checkTopCell()
	local tutoCell = self.ListTable:cellAtIndex(0)
	local tutoBtn = tutoCell and tutoCell:getRewardBtn()
	if tutoBtn ~= nil then
		TutoMgr.addBtn("kaifulibao_page_lingqu_btn", tutoBtn)
	end
	TutoMgr.active()
	TutoMgr.addBtn("dengjilibao_page_close_btn", self._rootnode.tag_close)
end

function LevelRewardLayer:checkTopCell()
	local minLevel_index = 1
	local minLevel = self.giftList[1].level
	local needTop = false
	for i, v in ipairs(self.giftList) do
		if v.level <= self.curLevel then
			local has = false
			for j, vl in ipairs(self.hasRewardLvs) do
				if vl == v.level then
					has = true
					break
				end
			end
			if not has then
				needTop = true
			end
		end
	end
	if needTop then
		for i, v in ipairs(self.giftList) do
			if v.level <= self.curLevel and minLevel < v.level then
				minLevel = v.level
				minLevel_index = i
			end
		end
		local function isHasGot(level)
			for i, v in ipairs(self.hasRewardLvs) do
				if v == level then
					return true
				end
			end
			return false
		end
		for i, v in ipairs(self.giftList) do
			if v.level <= self.curLevel and not isHasGot(v.level) and minLevel > v.level then
				minLevel = v.level
				minLevel_index = i
			end
		end
	else
		for i, v in ipairs(self.giftList) do
			if v.level > self.curLevel then
				minLevel = v.level
				minLevel_index = i
				break
			end
		end
	end
	local cellContentSize = require("game.Huodong.levelReward.LevelRewardCell").new():getContentSize()
	local pageCount = self.ListTable:getViewSize().height / cellContentSize.height
	local maxMove = #self.cellDatas - pageCount
	local tmpLevelIndex = minLevel_index - 1
	if maxMove < tmpLevelIndex then
		tmpLevelIndex = maxMove
	end
	local curIndex = maxMove - tmpLevelIndex
	self.ListTable:setContentOffset(cc.p(0, -(curIndex * cellContentSize.height)))
end

function LevelRewardLayer:ctor(data)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._curInfoIndex = -1
	local node = CCBuilderReaderLoad("reward/normal_reward_bg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@LevelReward"))
	
	--¹Ø±Õ
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		sender:runAction(transition.sequence({
		CCCallFunc:create(function()
			self:removeFromParentAndCleanup(true)
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	self:init(data)
end

function LevelRewardLayer:onExit(...)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return LevelRewardLayer
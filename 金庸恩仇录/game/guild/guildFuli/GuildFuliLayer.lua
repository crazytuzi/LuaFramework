local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local data_union_fuli_union_fuli = require("data.data_union_fuli_union_fuli")
require("data.data_error_error")
local MAX_ZORDER = 101
local listViewDisH = 95

local GuildFuliLayer = class("GuildFuliLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildFuliLayer:getReward(cell)
	RequestHelper.Guild.getReward({
	id = cell:getFuliType(),
	errback = function(data)
		cell:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data, common:getLanguageString("@GuildRecieveReward"), 6)
		if data.err ~= "" then
			dump(data.err)
			cell:setBtnEnabled(true)
		else
			local rtnObj = data.rtnObj
			cell:setOpened(true)
			cell:setBtnEnabled(true)
			if rtnObj.gift ~= nil then
				game.player:getGuildInfo():updateData({
				selfMoney = rtnObj.gift
				})
				PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
			end
			local msgBox
			local rewardList = rtnObj.rewardList
			local fuliType = cell:getFuliType()
			if fuliType == GUILD_FULIITEM_TYPE.barbecue then
				for i, v in ipairs(self._listData) do
					if v.id == fuliType then
						v.hasGet = true
						break
					end
				end
				local tili, naili
				for i, v in ipairs(rewardList) do
					if v.t == 7 then
						if v.id == 3 then
							tili = v.n
						elseif v.id == 4 then
							naili = v.n
						end
					end
				end
				msgBox = require("game.guild.guildFuli.GuildFuliRewardMsgBox").new({naili = naili, tili = tili})
				game.player:updateMainMenu({naili = naili, tili = tili})
			elseif fuliType == GUILD_FULIITEM_TYPE.weekly then
				local cellDatas = {}
				for i, v in ipairs(rewardList) do
					local item
					local iconType = ResMgr.getResType(v.t)
					if iconType == ResMgr.HERO then
						item = ResMgr.getCardData(v.id)
					else
						item = data_item_item[v.id]
					end
					table.insert(cellDatas, {
					id = v.id,
					type = v.t,
					name = item.name,
					iconType = iconType,
					num = v.n
					})
				end
				msgBox = require("game.Huodong.RewardMsgBox").new({cellDatas = cellDatas})
			end
			if msgBox ~= nil then
				self:addChild(msgBox, MAX_ZORDER)
			else
				ResMgr.showAlert(msgBox, common:getLanguageString("@GuildWelfareNotInit"))
			end
		end
	end
	})
end

function GuildFuliLayer:openActivities(cell)
	RequestHelper.Guild.openActivities({
	id = cell:getFuliType(),
	errback = function(data)
		cell:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			cell:setBtnEnabled(true)
		else
			local rtnObj = data.rtnObj
			game.player:getGuildInfo():updateData({
			currentUnionMoney = rtnObj.unionCurrentMoney
			})
			PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
			if rtnObj.surplusTime ~= nil and rtnObj.surplusTime > 0 then
				for i, v in ipairs(self._listData) do
					if v.id == cell:getFuliType() then
						v.isShowTime = true
						v.leftTime = rtnObj.surplusTime
						v.isOpen = GUILD_FULI_OPEN_TYPE.hasOpen
						v.isEnd = false
						v.hasGet = false
						break
					end
				end
				cell:updateTimeState({
				isShowTime = true,
				leftTime = rtnObj.surplusTime,
				fuliType = cell:getFuliType(),
				isEnd = false
				})
				self:addToTimeList({
				index = cell:getIdx(),
				fuliType = cell:getFuliType(),
				leftTime = rtnObj.surplusTime
				})
			end
			cell:setBtnEnabled(true)
			cell:setOpened(false)
		end
	end
	})
end

function GuildFuliLayer:checkTime(timeData)
	GameRequest.Guild.checkTime({
	id = timeData.fuliType,
	errback = function(data)
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		else
			local rtnObj = data.rtnObj
			local isOpen, isShowTime
			if rtnObj.isOver == 0 then
				isShowTime = false
				isOpen = GUILD_FULI_OPEN_TYPE.hasEnd
			elseif rtnObj.isOver == 1 then
				isShowTime = true
				isOpen = GUILD_FULI_OPEN_TYPE.hasOpen
				timeData.leftTime = rtnObj.leftTime
			end
			local itemData = self._listData[timeData.index + 1]
			itemData.leftTime = rtnObj.leftTime
			itemData.isShowTime = isShowTime
			itemData.isOpen = isOpen
			self._listViewTable:reloadCell(timeData.index, itemData)
		end
	end
	})
end

function GuildFuliLayer:ctor(data)
	dump(data, common:getLanguageString("@GuildWelfareList"), 5)
	self:setNodeEventEnabled(true)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_guildFuli_bg.ccbi", proxy, self._rootnode, self, cc.size(display.width, display.height * 0.94))
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@GuildWelfare"))
	
	--¹Ø±Õ
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self._unionCurrentMoney = data.rtnObj.unionCurrentMoney
	self._lastContribute = data.rtnObj.lastContribute
	game.player:getGuildInfo():updateData({
	selfMoney = self._lastContribute,
	currentUnionMoney = self._unionCurrentMoney
	})
	PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
	self._listData = {}
	self._timeListData = {}
	self:createListData(data)
	self:reloadListView()
	self:initTimeSchedule()
end

function GuildFuliLayer:addToTimeList(param)
	if self._timeListData == nil then
		self._timeListData = {}
	end
	table.insert(self._timeListData, {
	index = param.index,
	fuliType = param.fuliType,
	leftTime = param.leftTime
	})
end

function GuildFuliLayer:initTimeSchedule()
	self._scheduler = require("framework.scheduler")
	local function updateTime()
		for i, v in ipairs(self._timeListData) do
			if v.leftTime > 0 then
				v.leftTime = v.leftTime - 1
				local itemData = self._listData[v.index + 1]
				itemData.leftTime = v.leftTime
				if itemData.leftTime <= 0 then
					self:checkTime(v)
				else
					self._listViewTable:reloadCell(v.index, itemData)
				end
			end
		end
	end
	self._checkSchedule = self._scheduler.scheduleGlobal(updateTime, 1, false)
end

function GuildFuliLayer:createListData(data)
	local welfList = data.rtnObj.welfList
	for i, v in ipairs(welfList) do
		local itemData = {}
		local itemInfo = data_union_fuli_union_fuli[v.id]
		ResMgr.showAlert(itemInfo, common:getLanguageString("@ServerGuildWelfareIDError") .. v.id)
		itemData = v
		itemData.title = itemInfo.title
		itemData.content = itemInfo.content
		if v.isGet == 1 then
			itemData.hasGet = false
		elseif v.isGet == 0 then
			itemData.hasGet = true
		end
		if itemData.id == GUILD_FULIITEM_TYPE.barbecue then
			itemData.content = string.format(itemData.content, v.addPhy, v.addRes)
		end
		itemData.needStr = itemInfo.need
		itemData.costStr = itemInfo.cost
		itemData.isShowTime = false
		if itemData.leftTime ~= nil and 0 < itemData.leftTime then
			itemData.isShowTime = true
			self:addToTimeList({
			index = i - 1,
			fuliType = itemData.id,
			leftTime = itemData.leftTime
			})
		end
		table.insert(self._listData, itemData)
	end
end

function GuildFuliLayer:reloadListView()
	if self._listViewTable ~= nil then
		self._listViewTable:removeFromParentAndCleanup(true)
		self._listViewTable = nil
	end
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height - listViewDisH
	local function createFunc(index)
		local item = require("game.guild.guildFuli.GuildFuliItem").new()
		return item:create({
		viewSize = cc.size(boardWidth, boardHeight),
		itemData = self._listData[index + 1],
		rewardFunc = function(cell)
			local idx = cell:getIdx() + 1
			local itemData = self._listData[idx]
			local bCanGet = true
			if itemData.id == GUILD_FULIITEM_TYPE.weekly and itemData.costNum > self._lastContribute then
				show_tip_label(data_error_error[2900014].prompt)
				cell:setBtnEnabled(true)
				bCanGet = false
			end
			if bCanGet == true then
				self:getReward(cell)
			end
		end,
		openFunc = function(cell)
			local idx = cell:getIdx() + 1
			local itemData = self._listData[idx]
			if itemData.id == GUILD_FULIITEM_TYPE.barbecue then
				if itemData.costNum > self._unionCurrentMoney then
					show_tip_label(data_error_error[2900015].prompt)
					cell:setBtnEnabled(true)
				else
					self:openActivities(cell)
				end
			end
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(self._listData[index + 1])
	end
	local cellContentSize = require("game.guild.guildFuli.GuildFuliItem").new():getContentSize()
	self._rootnode.touchNode:setTouchEnabled(true)
	local posX = 0
	local posY = 0
	self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
		posX = event.x
		posY = event.y
	end)
	self._listViewTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._listData,
	cellSize = cellContentSize
	})
	self._listViewTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self._listViewTable)
end

function GuildFuliLayer:onExit()
	if self._checkSchedule ~= nil then
		self._scheduler.unscheduleGlobal(self._checkSchedule)
	end
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return GuildFuliLayer
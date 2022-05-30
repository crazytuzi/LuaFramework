local data_yueqian_yueqian = require("data.data_yueqian_yueqian")
local data_item_item = require("data.data_item_item")
local MAX_ZORDER = 1111
local YueqianLayer = class("YueqianLayer", function ()
	return display.newNode()
end)
function YueqianLayer:getStatus()
	RequestHelper.yueqian.monthSignStatus({
	callback = function (data)
		self:initData(data)
	end
	})
end

function YueqianLayer:getReward(cell, tag)
	local index = cell:getIdx() + 1
	local itemData = self._rewardData[index]
	local curItemData = itemData[tag]
	local day = curItemData.day
	local function confirmGetRewardFunc()
		RequestHelper.yueqian.getReward({
		month = self._curMon,
		day = day,
		callback = function (data)
			if data.result == 1 then
				self._curInfoIndex = -1
				table.insert(self._hasGetAry, day)
				cell:getReward({
				hasGetAry = self._hasGetAry,
				itemData = itemData
				})
				self._rootnode.total_day_lbl:setString(tostring(#self._hasGetAry))
				local cellDatas = {}
				table.insert(cellDatas, curItemData)
				if curItemData.vip > 0 and game.player:getVip() >= curItemData.vip then
					table.insert(cellDatas, curItemData)
				end
				local title = common:getLanguageString("@huodejl")
				local msgBox = require("game.Huodong.RewardMsgBox").new({
				title = title,
				cellDatas = cellDatas,
				confirmFunc = function ()
					self._curInfoIndex = -1
				end
				})
				game.runningScene:addChild(msgBox, MAX_ZORDER)
			end
		end,
		errback = function ()
			self._curInfoIndex = -1
		end
		})
	end
	local isCanGet = false
	if curItemData.day <= self._curDay then
		isCanGet = true
	end
	local rewardMxgBox = require("game.nbactivity.Yueqian.YueqianMsgbox").new({
	itemData = curItemData,
	isCanGet = isCanGet,
	confirmFunc = function ()
		confirmGetRewardFunc()
	end,
	cancleFunc = function ()
		self._curInfoIndex = -1
	end
	})
	game.runningScene:addChild(rewardMxgBox, MAX_ZORDER)
end
function YueqianLayer:ctor(param)
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/yueqian_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(node)
	local titleIcon = self._rootnode.title_icon
	local bottomNode = self._rootnode.bottom_node
	local listBgHeight = viewSize.height - titleIcon:getContentSize().height - bottomNode:getContentSize().height
	local listBg = display.newScale9Sprite("#month_item_bg_bg.png", 0, 0, CCSize(viewSize.width, listBgHeight))
	listBg:setAnchorPoint(0.5, 0)
	listBg:setPosition(display.width / 2, 0)
	self._rootnode.listViewNode:addChild(listBg)
	self._listViewSize = CCSizeMake(viewSize.width * 0.98, listBgHeight - 25)
	self._listViewNode = display.newNode()
	self._listViewNode:setContentSize(self._listViewSize)
	self._listViewNode:setAnchorPoint(0.5, 0.5)
	self._listViewNode:setPosition(display.width / 2, listBgHeight / 2)
	listBg:addChild(self._listViewNode)
	self._touchNode = display.newNode()
	self._touchNode:setContentSize(self._listViewSize)
	self._touchNode:setAnchorPoint(0.5, 0.5)
	self._touchNode:setPosition(display.width / 2, listBgHeight / 2)
	listBg:addChild(self._touchNode, 1)
	self._curInfoIndex = -1
	self:getStatus()
end

function YueqianLayer:initData(data)
	self._hasGetAry = data.hasGet or {}
	self._curDay = data.dayCnt
	self._curVip = data.vip
	self._curMon = data.month
	self._rootnode.cur_month_lbl:setString(tostring(self._curMon))
	self._rootnode.total_day_lbl:setString(tostring(#self._hasGetAry))
	self._rewardData = {}
	local tmpRewardData = {}
	for i, v in ipairs(data_yueqian_yueqian) do
		if v.month == self._curMon then
			local id = v.itemid
			local type = v.type
			local iconType = ResMgr.getResType(type)
			local item
			if iconType == ResMgr.HERO then
				local data_card_card = require("data.data_card_card")
				item = data_card_card[id]
			else
				item = data_item_item[id]
			end
			table.insert(tmpRewardData, {
			day = v.time,
			id = id,
			name = item.name,
			describe = item.describe or "",
			num = v.num or 0,
			type = type,
			iconType = iconType,
			vip = v.vip
			})
		end
	end
	local cellNum = 4
	local num
	if #tmpRewardData % cellNum == 0 then
		num = #tmpRewardData / cellNum
	else
		num = #tmpRewardData / cellNum + 1
	end
	local startIndex = 0
	for i = 1, num do
		local itemData = {}
		for j = 1, cellNum do
			local index = startIndex + j
			if index <= #tmpRewardData then
				table.insert(itemData, tmpRewardData[index])
			end
		end
		table.insert(self._rewardData, itemData)
		startIndex = startIndex + cellNum
	end
	self:createList()
end

function YueqianLayer:createList()
	local function createFunc(index)
		local item = require("game.nbactivity.Yueqian.YueqianItem").new()
		return item:create({
		viewSize = self._listViewSize,
		hasGetAry = self._hasGetAry,
		curDay = self._curDay,
		itemData = self._rewardData[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(self._rewardData[index + 1])
	end
	local cellContentSize = require("game.nbactivity.Yueqian.YueqianItem").new():getContentSize()
	self._listTable = require("utility.TableViewExt").new({
	size = self._listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._rewardData,
	cellSize = cellContentSize,
	touchFunc = function (cell, x, y)
		if self._curInfoIndex ~= -1 then
			return
		end
		local idx = cell:getIdx()
		for i = 1, 4 do
			local icon = cell:getIcon(i)
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				local day = self._rewardData[idx+1][i].day
				local hasGet = self:checkIsHasget(day)
				if hasGet == false then
					self._curInfoIndex = i
					self:getReward(cell, i)
					dump("当前领取, idx: " .. idx .. ", i: " .. i)
				end
				break
			end
		end
		
	end
	})
	self._listTable:setPosition(0, 0)
	self._listViewNode:addChild(self._listTable)
end

function YueqianLayer:checkIsHasget(day)
	local hasGet = false
	for j, d in ipairs(self._hasGetAry) do
		if d == day then
			hasGet = true
			break
		end
	end
	return hasGet
end

return YueqianLayer
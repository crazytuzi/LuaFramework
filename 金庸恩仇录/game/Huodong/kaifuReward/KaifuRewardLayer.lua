local ZORDER = 100
local listViewDisH = 95
local data_item_item = require("data.data_item_item")

local KaifuRewardLayer = class("KaifuRewardLayer", function()
	return require("utility.ShadeLayer").new()
end)

function KaifuRewardLayer:sendRequest()
	RequestHelper.kaifuReward.getInfo({
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			dump(data["0"])
		else
			self:init(data)
		end
	end
	})
end

function KaifuRewardLayer:onReward(cell)
	RequestHelper.kaifuReward.getReward({
	day = cell:getDay(),
	callback = function(data)
		cell:setRewardEnabled(true)
		if data["0"] ~= "" then
			dump(data["0"])
		else
			table.insert(self._hasRewardDays, cell:getDay())
			cell:getReward(self._hasRewardDays)
			game.player:updateMainMenu({
			silver = data["1"].silver,
			gold = data["1"].gold
			})
			PostNotice(NoticeKey.MainMenuScene_Update)
			game.player:setKaifuLibao(game.player:getKaifuLibao() - 1)
			PostNotice(NoticeKey.MainMenuScene_KaifuLibao)
			local title = common:getLanguageString("GetRewards")
			local index = cell:getIdx() + 1
			local msgBox = require("game.Huodong.RewardMsgBox").new({
			title = title,
			cellDatas = self._cellDatas[index].itemData
			})
			self:addChild(msgBox, ZORDER)
		end
	end
	})
end

function KaifuRewardLayer:onInformation(param)
	if self._curInfoIndex ~= -1 then
		return
	end
	local index = param.index
	self._curInfoIndex = index
	local iconIdx = param.iconIndex
	local icon_data = self._cellDatas[index + 1].itemData[iconIdx]
	if icon_data then
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

function KaifuRewardLayer:init(data)
	self._curDay = data["1"]
	self._hasRewardDays = data["2"]
	self._giftList = data["3"]
	self._cellDatas = {}
	for i, v in ipairs(self._giftList) do
		local itemData = {}
		for _, j in ipairs(v.item) do
			local iconType = ResMgr.getResType(j.type)
			local item = ResMgr.getItemByType(j.id, iconType)
			table.insert(itemData, {
			id = j.id,
			type = j.type,
			name = item.name,
			iconType = iconType,
			describe = item.describe,
			num = j.num or 0
			})
		end
		table.insert(self._cellDatas, {
		id = v.id,
		day = v.day,
		itemData = itemData
		})
	end
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height - listViewDisH
	local function createFunc(index)
		local item = require("game.Huodong.kaifuReward.KaifuRewardCell").new()
		return item:create({
		curDay = self._curDay,
		hasRewardDays = self._hasRewardDays,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		cellData = self._cellDatas[index + 1],
		rewardListener = handler(self, KaifuRewardLayer.onReward)
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		day = self._cellDatas[index + 1].day,
		itemData = self._cellDatas[index + 1].itemData
		})
	end
	
	local cellContentSize = require("game.Huodong.kaifuReward.KaifuRewardCell").new():getContentSize()
	self._ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._cellDatas,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		local idx = cell:getIdx()
		for i = 1, 4 do
			local icon = cell:getIcon(i)
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if (cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos))then
				self:onInformation({index = idx, iconIndex = i})
				break
			end
		end
	end
	})
	self._ListTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self._ListTable)
	local tutoCell = self._ListTable:cellAtIndex(0)
	local tutoBtn = tutoCell:getRewardBtn()
	if tutoBtn ~= nil then
		TutoMgr.addBtn("kaifulibao_page_lingqu_btn", tutoBtn)
	end
	TutoMgr.active()
	self:checkTopCell()
end

function KaifuRewardLayer:checkTopCell()
	local minDay_index = 1
	local minDay = self._giftList[1].day
	local needTop = false
	for i, v in ipairs(self._giftList) do
		if v.day <= self._curDay then
			local has = false
			for j, vl in ipairs(self._hasRewardDays) do
				if vl == v.day then
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
		for i, v in ipairs(self._giftList) do
			if v.day <= self._curDay and minDay < v.day then
				minDay = v.day
				minDay_index = i
			end
		end
		local function isHasGot(day)
			for i, v in ipairs(self._hasRewardDays) do
				if v == day then
					return true
				end
			end
			return false
		end
		for i, v in ipairs(self._giftList) do
			if v.day <= self._curDay and not isHasGot(v.day) and minDay > v.day then
				minDay = v.day
				minDay_index = i
			end
		end
	else
		for i, v in ipairs(self._giftList) do
			if v.day > self._curDay then
				minDay = v.day
				minDay_index = i
				break
			end
		end
	end
	local cellContentSize = require("game.Huodong.kaifuReward.KaifuRewardCell").new():getContentSize()
	local pageCount = self._ListTable:getViewSize().height / cellContentSize.height
	local maxMove = #self._cellDatas - pageCount
	local tmpDayIndex = minDay_index - 1
	if maxMove < tmpDayIndex then
		tmpDayIndex = maxMove
	end
	local curIndex = maxMove - tmpDayIndex
	self._ListTable:setContentOffset(cc.p(0, -(curIndex * cellContentSize.height)))
end

function KaifuRewardLayer:ctor(data)
	self._curInfoIndex = -1
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/normal_reward_bg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@NewServerReward"))
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	end,
	CCControlEventTouchUpInside)
	
	self:init(data)
	TutoMgr.addBtn("kaifulibao_page_close_btn", self._rootnode.tag_close)
	TutoMgr.active()
	
end

function KaifuRewardLayer:onExit()
	TutoMgr.removeBtn("kaifulibao_page_lingqu_btn")
	TutoMgr.removeBtn("kaifulibao_page_close_btn")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return KaifuRewardLayer
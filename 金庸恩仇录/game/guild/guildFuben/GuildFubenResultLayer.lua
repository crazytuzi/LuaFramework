local data_item_item = require("data.data_item_item")

local GuildFubenResultLayer = class("GuildFubenResultLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildFubenResultLayer:ctor(param)
	self._hasShowInfo = false
	local data = param.data
	local confirmFunc = param.confirmFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/guild/guild_fuben_result_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@GuildChaReward"))
	self._rootnode.hurt_lbl:setString(tostring(data["3"]))
	local function closeBtnFunc()
		if confirmFunc ~= nil then
			confirmFunc()
		end
		self:removeFromParentAndCleanup(true)
	end
	
	self._rootnode.tag_close:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeBtnFunc()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeBtnFunc()
	end,
	CCControlEventTouchUpInside)
	
	local rewardList = {}
	local rewardData = data["4"]
	for i, v in ipairs(rewardData) do
		local rewardId = v.id
		local rewardType = v.t
		local rewardItem
		local iconType = ResMgr.getResType(rewardType)
		if iconType == ResMgr.HERO then
			rewardItem = ResMgr.getCardData(rewardId)
		else
			rewardItem = data_item_item[rewardId]
		end
		ResMgr.showAlert(rewardItem, common:getLanguageString("@HintNoID") .. rewardId .. "type: " .. rewardType)
		table.insert(rewardList, {
		id = rewardId,
		type = rewardType,
		name = rewardItem.name,
		describe = rewardItem.describe,
		iconType = iconType,
		num = v.n
		})
	end
	self:createRewardList(rewardList)
end

function GuildFubenResultLayer:createRewardList(cellDatas)
	local function createFunc(index)
		local item = require("game.Huodong.RewardItem").new()
		return item:create({
		id = index,
		itemData = cellDatas[index + 1],
		viewSize = self._rootnode.listView:getContentSize()
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = cellDatas[index + 1]
		})
	end
	local cellContentSize = require("game.Huodong.RewardItem").new():getContentSize()
	self._rootnode.touchNode:setTouchEnabled(true)
	local listTable = require("utility.TableViewExt").new({
	size = self._rootnode.listView:getContentSize(),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #cellDatas,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		if self._hasShowInfo == false then
			local icon = cell:getRewardIcon()
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), icon:convertToNodeSpace(cc.p(x, y))) then
				self._hasShowInfo = true
				local idx = cell:getIdx() + 1
				local itemData = cellDatas[idx]
				local itemInfo = require("game.Huodong.ItemInformation").new({
				id = itemData.id,
				type = itemData.type,
				name = itemData.name,
				describe = itemData.describe,
				endFunc = function()
					self._hasShowInfo = false
				end
				})
				game.runningScene:addChild(itemInfo, self:getZOrder() + 1)
			end
		end
	end
	})
	listTable:setPosition(0, 0)
	self._rootnode.listView:addChild(listTable)
end

return GuildFubenResultLayer
local data_item_item = require("data.data_item_item")

local WorldBossExtraRewardLayer = class("WorldBossExtraRewardLayer", function()
	return require("utility.ShadeLayer").new()
end)

function WorldBossExtraRewardLayer:ctor(param)
	local rewardListData = param.rewardListData
	local confirmFunc = param.confirmFunc
	self._isGuildBoss = param.isGuildBoss
	self._normalReward = param.normalReward
	self._level = param.level
	if self._level == nil then
		self._level = game.player:getLevel()
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huodong/worldBoss_extraReward_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if confirmFunc ~= nil then
			confirmFunc()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self:getWardData(rewardListData)
	self:createRewardList()
end

function WorldBossExtraRewardLayer:getWardData(rewardListData)
	self._rewardDatas = {}
	for j, bossData in ipairs(rewardListData) do
		local itemData = {}
		for i = 1, bossData.reward_num do
			local itemType = bossData.type[i]
			local id = bossData.itemid[i]
			local iconType = ResMgr.getResType(itemType)
			local item
			if iconType == ResMgr.HERO then
				item = ResMgr.getCardData(id)
			elseif iconType == ResMgr.PET then
				item = ResMgr.getPetData(id)
			else
				item = data_item_item[id]
			end
			ResMgr.showAlert(item, "rewardListData 没有此物品，id: " .. tostring(id))
			local num = 0
			if self._normalReward == true then
				num = bossData.num[i] or 0
			elseif self._isGuildBoss == false then
				num = bossData.num[i] or 0
				if itemType == 7 and id == 2 then
					num = num * self._level
				end
			elseif self._isGuildBoss == true then
				num = bossData.fix[i] + bossData.ratio[i] * self._level
			end
			table.insert(itemData, {
			id = id,
			type = itemType,
			name = item.name,
			describe = item.describe or "",
			iconType = iconType,
			num = num
			})
		end
		table.insert(self._rewardDatas, {
		title = bossData.title or "",
		rewardId = bossData.id,
		itemData = itemData
		})
	end
end

function WorldBossExtraRewardLayer:createRewardList()
	local listViewDisH = self._rootnode.titleBoard:getContentSize().height + self._rootnode.listView:getPositionY() + 20
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height - listViewDisH
	local listViewSize = cc.size(boardWidth, boardHeight)
	local listBg = display.newScale9Sprite("#sh_rank_bg.png", 0, 0, cc.size(boardWidth * 0.9, boardHeight + 20))
	listBg:setAnchorPoint(0.5, 0)
	listBg:setPosition(boardWidth / 2, -10)
	self._rootnode.listView:addChild(listBg)
	local function createFunc(index)
		local item = require("game.Worldboss.WorldBossExtraRewardItem").new()
		return item:create({
		viewSize = listViewSize,
		cellData = self._rewardDatas[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(self._rewardDatas[index + 1])
	end
	local cellContentSize = require("game.Worldboss.WorldBossExtraRewardItem").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._rewardDatas,
	cellSize = cellContentSize
	})
	self.ListTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self.ListTable)
end

return WorldBossExtraRewardLayer
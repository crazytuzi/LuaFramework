local data_item_item = require("data.data_item_item")

local ChallengeFubenRewardLayer = class("ChallengeFubenRewardLayer", function()
	return require("utility.ShadeLayer").new()
end)

function ChallengeFubenRewardLayer:ctor(param)
	self._hasShowInfo = false
	local rewardList = param.rewardList
	local closeFunc = param.closeFunc
	local height = display.height
	if height > 960 then
		height = 960
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/challenge/challengeFuben_reward_layer.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, height))
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@ProbFall"))
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local sizeH = node:getContentSize().height - self._rootnode.top_node:getContentSize().height - self._rootnode.bottom_node:getContentSize().height
	local sizeW = self._rootnode.top_node:getContentSize().width
	self._listViewSize = cc.size(sizeW, sizeH)
	self._listViewNode = display.newNode()
	self._listViewNode:setContentSize(self._listViewSize)
	self._listViewNode:setAnchorPoint(0.5, 0)
	self._listViewNode:setPosition(node:getContentSize().width / 2, self._rootnode.bottom_node:getContentSize().height)
	self._rootnode.bottom_node:addChild(self._listViewNode)
	self._touchNode = display.newNode()
	self._touchNode:setContentSize(self._listViewNode:getContentSize())
	self._touchNode:setAnchorPoint(0.5, 0)
	self._touchNode:setPosition(self._listViewNode:getPosition())
	self._rootnode.bottom_node:addChild(self._touchNode)
	local rewardDataList = {}
	for j = 1, #rewardList do
		local rewardData = rewardList[j]
		local cellDatas = {}
		for i = 1, #rewardData.arr_id do
			local rewardId = rewardData.arr_id[i]
			local rewardType = rewardData.arr_type[i]
			local item
			local iconType = ResMgr.getResType(rewardType)
			if iconType == ResMgr.HERO then
				item = ResMgr.getCardData(rewardId)
			elseif iconType == ResMgr.PET then
				item = ResMgr.getPetData(rewardId)
			else
				item = data_item_item[rewardId]
			end
			table.insert(cellDatas, {
			id = rewardId,
			type = rewardType,
			name = item.name,
			describe = item.describe,
			iconType = iconType,
			num = 1
			})
		end
		table.insert(rewardDataList, {
		cellDatas = cellDatas,
		iconName = rewardData.iconName
		})
	end
	self:createListView(rewardDataList)
end

function ChallengeFubenRewardLayer:createListView(rewardDataList)
	local fileName = "game.ChallengeFuben.ChallengeFubenRewardCell"
	local function createFunc(index)
		local item = require(fileName).new()
		return item:create({
		viewSize = self._listViewSize,
		itemData = rewardDataList[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(rewardDataList[index + 1])
	end
	local cellContentSize = require(fileName).new():getContentSize()
	local listTable = require("utility.TableViewExt").new({
	size = self._listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #rewardDataList,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		if self._hasShowInfo == false then
			local idx = cell:getIdx() + 1
			for i = 1, 5 do
				local icon = cell:getIcon(i)
				local pos = icon:convertToNodeSpace(cc.p(x, y))
				if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
					self._hasShowInfo = true
					self:onInformation(rewardDataList[idx].cellDatas[i])
					break
				end
			end
		end
	end
	})
	listTable:setPosition(0, 0)
	self._listViewNode:addChild(listTable)
end

function ChallengeFubenRewardLayer:onInformation(itemData)
	if itemData then
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

function ChallengeFubenRewardLayer:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return ChallengeFubenRewardLayer
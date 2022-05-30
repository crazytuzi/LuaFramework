local ZORDER = 100
local listViewDisH = 95
local data_item_item = require("data.data_item_item")
local data_lunjian_lunjian = require("data.data_lunjian_lunjian")

local Item = class("Item", function()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(640, 200)
end

function Item:updateItem(itemData)
	for i, v in ipairs(itemData.itemid) do
		local reward = self._rootnode["reward_" .. tostring(i)]
		reward:setVisible(true)
		local rewardIcon = self._rootnode["reward_icon_" .. tostring(i)]
		rewardIcon:removeAllChildrenWithCleanup(true)
		local num = itemData.num[i]
		if itemData.silver ~= nil and v == 2 then
			num = num * game.player.getLevel() + itemData.silver
		end
		printf("========== %d", v)
		ResMgr.refreshItemWithTagNumName({
		id = v,
		itemBg = rewardIcon,
		resType = ResMgr.getResType(itemData.type[i]),
		isShowIconNum = num > 1 and 1 or 0,
		itemNum = num,
		itemType = itemData.type[i],
		cls = 0
		})
	end
	local count = #itemData.itemid
	while count < 4 do
		self._rootnode["reward_" .. tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
end

function Item:refreshItem(param)
	local itemData = param.itemData
	self._rootnode.index:setString(itemData.title)
	self:updateItem(itemData)
end

function Item:getIcon(index)
	return self._rootnode["reward_icon_" .. tostring(index)]
end

function Item:create(param)
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_reward_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	self:refreshItem(param)
	return self
end

function Item:refresh(param)
	self:refreshItem(param)
end

local HuaShanRewardShow = class("HuaShanRewardShow", function(param)
	return require("utility.ShadeLayer").new()
end)

function HuaShanRewardShow:onInformation(param)
	local index = param.index
	local iconIdx = param.iconIndex
	local icon_data = data_lunjian_lunjian[index]
	printf("======== %d, %d", index, iconIdx)
	if icon_data then
		dump(data_item_item[icon_data.itemid[iconIdx]])
		if data_item_item[icon_data.itemid[iconIdx]] then
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = icon_data.itemid[iconIdx],
			type = icon_data.type[iconIdx],
			name = data_item_item[icon_data.itemid[iconIdx]].name,
			describe = icon_data.describe,
			endFunc = function()
			end
			})
			self:addChild(itemInfo, ZORDER)
		end
	end
end

function HuaShanRewardShow:init()
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height - listViewDisH
	if self._props_title then
		local propsLable = ui.newTTFLabel({
		text = self._props_title,
		size = 22,
		align = ui.TEXT_ALIGN_CENTER,
		color = cc.c3b(83, 59, 42)
		})
		self._rootnode.listView:addChild(propsLable)
		propsLable:setPosition(cc.p(boardWidth * 0.5, boardHeight - 15))
		boardHeight = boardHeight - 40
	end
	
	local function createFunc(index)
		local item = Item.new()
		return item:create({
		viewSize = cc.size(boardWidth, boardHeight),
		itemData = data_lunjian_lunjian[index + 1]
		})
	end
	
	local function refreshFunc(cell, index)
		cell:refresh({
		itemData = data_lunjian_lunjian[index + 1]
		})
	end
	
	local cellContentSize = require("game.Huodong.kaifuReward.KaifuRewardCell").new():getContentSize()
	local tableView = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #data_lunjian_lunjian,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		local idx = cell:getIdx()
		for i = 1, 4 do
			local icon = cell:getIcon(i)
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				self:onInformation({
				index = idx + 1,
				iconIndex = i
				})
				break
			end
		end
	end
	})
	tableView:setPosition(0, 0)
	self._rootnode.listView:addChild(tableView)
end

function HuaShanRewardShow:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/normal_reward_bg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._props_title = param.props_title
	if param.miPageId == 1 then
		data_lunjian_lunjian = require("data.data_lunjian_lunjian")
		self._rootnode.titleLabel:setString(common:getLanguageString("@TalkSwordReward"))
	elseif param.miPageId == 2 then
		data_lunjian_lunjian = require("data.data_union_fubenjiangli_union_fubenjiangli")
		self._rootnode.titleLabel:setString(common:getLanguageString("@RewardPreview"))
	elseif param.miPageId == 3 then
		data_lunjian_lunjian = {}
		local typeTbl = {}
		for key, value in pairs(param.typeTbl) do
			typeTbl[value] = true
		end
		local tmpTbl = require("data.data_kuafu_jiangli_kuafu_jiangli")
		for key, value in ipairs(tmpTbl) do
			if typeTbl[value.rewardtype] then
				table.insert(data_lunjian_lunjian, value)
			end
		end
		self._rootnode.titleLabel:setString(common:getLanguageString("@RewardPreview"))
	end
	
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self:init()
end

function HuaShanRewardShow:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HuaShanRewardShow
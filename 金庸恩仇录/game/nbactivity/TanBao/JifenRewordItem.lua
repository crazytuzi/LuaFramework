local JifenRewordItem = class("JifenRewordItem", function()
	return CCTableViewCell:new()
end)

function JifenRewordItem:getContentSize()
	return cc.size(105, 120)
end

function JifenRewordItem:refreshItem(param)
	local itemData = param.itemData
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	dump(itemData)
	if itemData.type == ITEM_TYPE.zhenqi then
		self._rootnode.reward_icon:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
		self._rootnode.reward_icon:removeAllChildrenWithCleanup(true)
		self._icon = require("game.Spirit.SpiritIcon").new({
		resId = itemData.id
		})
		self._rootnode.reward_icon:addChild(self._icon)
		require("game.Spirit.SpiritCtrl").clear()
		--czy
		addTouchListener(self._icon, function(sender, eventType)
			if eventType == EventType.ended then
				local closeFunc = function()
					if CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
						CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111, true)
					end
				end
				local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
				resId = tonumber(itemData.id)
				}, nil, closeFunc)
				CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 100000000, 1111)
			end
		end)
	else
		self._icon = ResMgr.refreshIcon({
		id = itemData.id,
		resType = itemData.iconType,
		iconNum = itemData.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = cc.c3b(0, 255, 0),
		numLblOutColor = cc.c3b(0, 0, 0),
		itemType = itemData.type
		})
		rewardIcon:addChild(self._icon)
		if itemData.hideCorner then
			local cornerNode = self._icon:getChildByTag(ResMgr.cornerTag)
			if cornerNode then
				cornerNode:setVisible(false)
			end
		end
	end
	addTouchListener(self._icon, function(sender, eventType)
		if eventType == EventType.ended then
			if itemData.type ~= 6 then
				local closeFunc = function()
					CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111, true)
				end
				local itemInfo = require("game.Huodong.ItemInformation").new({
				id = itemData.id,
				type = itemData.type,
				name = itemData.name,
				describe = require("data.data_item_item")[itemData.id].dis,
				endFunc = closeFunc
				})
				CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000, 1111)
			else
				local closeFunc = function()
					if CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
						CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111, true)
					end
				end
				local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
				resId = tonumber(itemData.type)
				}, nil, closeFunc)
				CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 100000000, 1111)
			end
			dump(itemData.type)
		end
	end)
	local nameKey = "reward_name"
	local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = itemData.name,
	size = 20,
	color = nameColor,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(100, 0)
	})
	--nameLbl:setPosition(0, 12)
	--self._rootnode[nameKey]:removeAllChildren()
	--self._rootnode[nameKey]:addChild(nameLbl)
	ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, 12)
	nameLbl:align(display.CENTER)
	
	
	
end

function JifenRewordItem:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/reward_item.ccbi", proxy, self._rootnode)
	local contentSize = self._rootnode.reward:getContentSize()
	node:setPosition(self:getContentSize().width * 0.5, _viewSize.height * 0.5)
	self:addChild(node)
	self:refreshItem(param)
	return self
end

function JifenRewordItem:refresh(param)
	self:refreshItem(param)
end

return JifenRewordItem
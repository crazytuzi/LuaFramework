local RewardItem = class("RewardItem", function ()
	return CCTableViewCell:new()
end)

function RewardItem:getContentSize()
	return cc.size(105, 120)
end

function RewardItem:getRewardIcon()
	return self._rootnode.reward_icon
end

function RewardItem:refreshItem(param)
	local itemData = param.itemData
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	if itemData.id == 56 and itemData.isClear == nil then
		require("game.Spirit.SpiritCtrl").clear()
	end
	if itemData.type == ITEM_TYPE.zhenqi then
		self._rootnode.reward_icon:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
		self._rootnode.reward_icon:removeAllChildrenWithCleanup(true)
		self._rootnode.reward_icon:addChild(require("game.Spirit.SpiritIcon").new({
		resId = itemData.id
		}))
		if itemData.isClear == nil then
			require("game.Spirit.SpiritCtrl").clear()
		end
	else
		ResMgr.refreshIcon({
		id = itemData.id,
		resType = itemData.iconType,
		itemBg = rewardIcon,
		iconNum = itemData.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = cc.c3b(0, 255, 0),
		numLblOutColor = cc.c3b(0, 0, 0),
		itemType = itemData.type
		})
		if itemData.hideCorner then
			local cornerNode = rewardIcon:getChildByTag(ResMgr.cornerTag)
			if cornerNode then
				cornerNode:setVisible(false)
			end
		end
	end
	
	if param.unShowName ~= true then
		local nameKey = "reward_name"
		local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
		local itemName = itemData.name
		itemName = itemName or ResMgr.getItemNameByType(itemData.id, itemData.iconType)
		local nameLbl = ui.newTTFLabelWithShadow({
		text = itemName,
		size = 20,
		color = nameColor,
		shadowColor = FONT_COLOR.BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_CENTER,
		dimensions = cc.size(100, 0)
		})
		if itemData.type == ITEM_TYPE.zhenqi and itemData.num > 1 then
			nameLbl:setString(itemData.name .. "X" .. itemData.num)
		end
		ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, 0)
		nameLbl:align(display.BOTTOM_CENTER)
	end
end

function RewardItem:create(param)
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

function RewardItem:refresh(param)
	self:refreshItem(param)
end

return RewardItem
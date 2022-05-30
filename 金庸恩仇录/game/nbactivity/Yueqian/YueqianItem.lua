local YueqianItem = class("YueqianItem", function ()
	return CCTableViewCell:new()
end)

function YueqianItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("nbhuodong/yueqian_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function YueqianItem:getIcon(index)
	return self._rootnode["bg_icon_" .. tostring(index)]
end

function YueqianItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	self._hasGetAry = param.hasGetAry
	self._curDay = param.curDay
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/yueqian_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	self:refreshItem(itemData)
	return self
end

function YueqianItem:refresh(itemData)
	self:refreshItem(itemData)
end

function YueqianItem:refreshItem(itemData)
	for i = 1, 4 do
		self._rootnode["boss_node_" .. i]:setVisible(false)
	end
	for i, v in ipairs(itemData) do
		self._rootnode["boss_node_" .. i]:setVisible(true)
		local vipIcon = self._rootnode["vip_icon_" .. i]
		if v.vip ~= nil and v.vip > 0 then
			vipIcon:setVisible(true)
			vipIcon:setDisplayFrame(display.newSprite("#yueqian_vip_" .. tostring(v.vip) .. ".png"):getDisplayFrame())
		else
			vipIcon:setVisible(false)
		end
		local hasGet = false
		for j, d in ipairs(self._hasGetAry) do
			if d == v.day then
				hasGet = true
				break
			end
		end
		local effectNode = self._rootnode["effect_node_" .. i]
		if hasGet == true then
			self._rootnode["hasGet_node_" .. i]:setVisible(true)
			effectNode:removeAllChildrenWithCleanup(true)
		else
			self._rootnode["hasGet_node_" .. i]:setVisible(false)
			effectNode:removeAllChildrenWithCleanup(true)
			if v.day <= self._curDay then
				local effTextWin = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = "yueqiandaobiankuang",
				isRetain = true
				})
				effectNode:addChild(effTextWin)
			end
		end
		local rewardIcon = self._rootnode["reward_icon_" .. i]
		rewardIcon:removeAllChildrenWithCleanup(true)
		ResMgr.refreshItemWithTagNumName({
		id = v.id,
		itemBg = rewardIcon,
		isShowIconNum = 1 < v.num and 1 or 0,
		itemNum = v.num,
		itemType = v.type,
		resType = v.iconType
		})
	end
end

function YueqianItem:getReward(param)
	self._hasGetAry = param.hasGetAry
	local itemData = param.itemData
	self:refreshItem(itemData)
end

return YueqianItem
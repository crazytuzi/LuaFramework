local GuildFubenCell = class("GuildFubenCell", function()
	return CCTableViewCell:new()
end)

function GuildFubenCell:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("guild/guild_fuben_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function GuildFubenCell:getRewardBoxIcon()
	return self._rootnode.reward_box
end

function GuildFubenCell:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_fuben_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, 0)
	self:addChild(node)
	self:refreshItem(itemData)
	return self
end

function GuildFubenCell:refresh(itemData)
	self:refreshItem(itemData)
end

function GuildFubenCell:refreshItem(itemData)
	local imagePath = "ui/ui_guild_fb/" .. itemData.icon .. ".png"
	local itemBg
	if itemData.state == FUBEN_STATE.notOpen then
		itemBg = display.newGraySprite(imagePath, {
		0.4,
		0.4,
		0.4,
		0.1
		})
	else
		itemBg = display.newSprite(imagePath)
	end
	itemBg:setAnchorPoint(0.5, 0)
	itemBg:setPosition(self._rootnode.itemBg_node:getContentSize().width / 2, 0)
	self._rootnode.itemBg_node:removeAllChildren()
	self._rootnode.itemBg_node:addChild(itemBg)
	local rewardBox = self._rootnode.reward_box
	if itemData.state == FUBEN_STATE.notOpen then
		dump(itemData.openMsg)
		for k, v in pairs(itemData.openMsg) do
			local color = cc.c3b(255, 255, 255)
			if k == "lvTxt" then
				color = cc.c3b(255, 222, 0)
			end
			self._rootnode[k]:setString(v)
			self._rootnode[k]:setColor(color)
			--[[
			ResMgr.createOutlineMsgTTF({
			text = v,
			color = color,
			parentNode = self._rootnode[k]
			})
			]]
		end
		self._rootnode.passed_icon:setVisible(false)
		self._rootnode.open_node:setVisible(true)
		self._rootnode.hp_node:setVisible(false)
	else
		if itemData.state == FUBEN_STATE.hasPass then
			self._rootnode.passed_icon:setVisible(true)
		else
			self._rootnode.passed_icon:setVisible(false)
		end
		self._rootnode.open_node:setVisible(false)
		self._rootnode.hp_node:setVisible(true)
	end
	self:setBoxState(itemData.boxState)
	self:updateHp(itemData)
end

function GuildFubenCell:updateHp(itemData)
	self._rootnode.blood_lbl:setString(tostring(itemData.leftHp) .. "/" .. tostring(itemData.totalHp))
	local percent = itemData.leftHp / itemData.totalHp
	local normalBar = self._rootnode.normalBar
	local bar = self._rootnode.addBar
	local rotated = false
	if bar:isTextureRectRotated() == true then
		rotated = true
	end
	bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, normalBar:getContentSize().width * percent, bar:getTextureRect().height), rotated, cc.size(normalBar:getContentSize().width * percent, normalBar:getContentSize().height * percent))
end

function GuildFubenCell:setBoxState(state)
	local rewardBox = self._rootnode.reward_box
	if state == FUBEN_REWARD_STATE.notOpen then
		rewardBox:setDisplayFrame(display.newSprite("#guild_fuben_box_1.png"):getDisplayFrame())
	elseif state == FUBEN_REWARD_STATE.canGet then
		rewardBox:setDisplayFrame(display.newSprite("#guild_fuben_box_2.png"):getDisplayFrame())
	elseif state == FUBEN_REWARD_STATE.hasGet then
		rewardBox:setDisplayFrame(display.newSprite("#guild_fuben_box_3.png"):getDisplayFrame())
	end
end

return GuildFubenCell
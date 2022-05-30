local GuildFuliItem = class("GuildFuliItem", function()
	return CCTableViewCell:new()
end)

local format_time = function(time)
	local hour = math.floor(time / 60)
	if hour < 10 then
		hour = "0" .. hour or hour
	end
	local min = time % 60
	if min < 10 then
		min = "0" .. min or min
	end
	local str = hour .. ":" .. min
	return str
end

function GuildFuliItem:getContentSize()
	if self._contentSz == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("guild/guild_guildFuli_item.ccbi", proxy, rootnode)
		self._contentSz = rootnode.item_bg:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self._contentSz
end

function GuildFuliItem:setBtnEnabled(bEnabled)
	self._rootnode.openBtn:setEnabled(bEnabled)
	self._rootnode.rewardBtn:setEnabled(bEnabled)
end

function GuildFuliItem:getFuliType()
	return self._fuliType
end

function GuildFuliItem:create(param)
	self:setNodeEventEnabled(true)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local openFunc = param.openFunc
	local rewardFunc = param.rewardFunc
	self._fuliType = itemData.id
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_guildFuli_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width / 2, 0)
	self:addChild(node)
	
	self._rootnode.openBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if openFunc ~= nil then
			self:setBtnEnabled(false)
			openFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.rewardBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if rewardFunc ~= nil then
			self:setBtnEnabled(false)
			rewardFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:refreshItem(itemData)
	return self
end

function GuildFuliItem:refresh(itemData)
	self:refreshItem(itemData)
end

function GuildFuliItem:refreshItem(itemData)
	self._fuliType = itemData.id
	local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType
	local isEnd = false
	if itemData.isOpen == GUILD_FULI_OPEN_TYPE.hasOpen then
		self:setOpened(itemData.hasGet)
	elseif itemData.isOpen == GUILD_FULI_OPEN_TYPE.notOpen then
		self._rootnode.tag_has_get:setVisible(false)
		self._rootnode.rewardBtn:setVisible(false)
		self._rootnode.tag_end:setVisible(false)
		if jopType == GUILD_JOB_TYPE.leader or jopType == GUILD_JOB_TYPE.assistant then
			self._rootnode.tag_not_open:setVisible(false)
			self._rootnode.openBtn:setVisible(true)
		else
			self._rootnode.tag_not_open:setVisible(true)
			self._rootnode.openBtn:setVisible(false)
		end
	elseif itemData.isOpen == GUILD_FULI_OPEN_TYPE.hasEnd then
		isEnd = true
	end
	self:updateTimeState({
	isShowTime = itemData.isShowTime,
	leftTime = itemData.leftTime,
	fuliType = self._fuliType,
	isEnd = isEnd
	})
	self._rootnode.title_lbl:setString(tostring(itemData.title))
	local createText = function(text, contentNode)
		contentNode:removeAllChildren()
		local infoNode = getRichText(text, contentNode:getContentSize().width)
		infoNode:setPosition(0, contentNode:getContentSize().height - 30)
		contentNode:addChild(infoNode)
	end
	createText(itemData.content, self._rootnode.content_tag)
	createText(itemData.needStr, self._rootnode.need_tag)
	createText(itemData.costStr, self._rootnode.cost_tag)
	local isShowTime = itemData.isShowTime
	if itemData.canSetup == 1 then
		self._rootnode.autotimenode:setVisible(true)
		if itemData.autoTime == -1 then
			self._rootnode.auto_time_lbl:setColor(cc.c3b(255, 0, 0))
			self._rootnode.auto_time_lbl:setString(common:getLanguageString("@contentcancelAuto"))
		else
			self._rootnode.auto_time_lbl:setColor(cc.c3b(78, 143, 0))
			self._rootnode.auto_time_lbl:setString(format_time(itemData.autoTime))
		end
		alignNodesOneByOne(self._rootnode.openlabel, self._rootnode.auto_time_lbl, 0)
	else
		self._rootnode.autotimenode:setVisible(false)
	end
end

function GuildFuliItem:setOpened(hasGet)
	if hasGet == true then
		self._rootnode.tag_has_get:setVisible(true)
		self._rootnode.rewardBtn:setVisible(false)
	elseif hasGet == false then
		self._rootnode.tag_has_get:setVisible(false)
		self._rootnode.rewardBtn:setVisible(true)
	end
	self._rootnode.openBtn:setVisible(false)
	self._rootnode.tag_not_open:setVisible(false)
	self._rootnode.tag_end:setVisible(false)
end

function GuildFuliItem:updateTimeState(msg)
	local isShowTime = msg.isShowTime
	local leftTime = msg.leftTime
	local isEnd = msg.isEnd
	local fuliType = msg.fuliType
	if fuliType == self._fuliType then
		if isShowTime == true then
			self._rootnode.left_time_lbl:setVisible(true)
			self._rootnode.left_time_lbl:removeAllChildren()
			local timelabel = getRichText(common:getLanguageString("@bbqtimeremain", format_time(leftTime)))
			timelabel:setAnchorPoint(ccp(1, 0))
			self._rootnode.left_time_lbl:addChild(timelabel)
		else
			self._rootnode.left_time_lbl:setVisible(false)
		end
		if isEnd == true and fuliType ~= GUILD_FULIITEM_TYPE.weekly then
			self._rootnode.tag_end:setVisible(true)
			self._rootnode.openBtn:setVisible(false)
			self._rootnode.rewardBtn:setVisible(false)
			self._rootnode.tag_not_open:setVisible(false)
			self._rootnode.tag_has_get:setVisible(false)
		end
	end
end

return GuildFuliItem
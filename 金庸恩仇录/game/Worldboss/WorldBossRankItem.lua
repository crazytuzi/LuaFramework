local WorldBossRankItem = class("WorldBossRankItem", function()
	return CCTableViewCell:new()
end)

function WorldBossRankItem:getContentSize()
	if self.cntSize == nil then
		local proxy = CCBProxy:create()
		local rootNode = {}
		local node = CCBuilderReaderLoad("huodong/worldBoss_rank_item.ccbi", proxy, rootNode)
		self.cntSize = rootNode.itemBg:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self.cntSize
end

function WorldBossRankItem:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local checkFunc = param.checkFunc
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/worldBoss_rank_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	
	self._rootnode.zhenrongBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if checkFunc ~= nil then
			checkFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:updateItem(itemData)
	return self
end

function WorldBossRankItem:refresh(itemData)
	self:updateItem(itemData)
end

function WorldBossRankItem:updateItem(itemData)
	local bgName = "#sh_bg_4.png"
	local lvBgName = "#sh_lv_bg_4.png"
	local playerBgName = "#sh_name_bg_4.png"
	local mark = itemData.rank
	if mark > 10 then
		mark = 10
	end
	local markIcon = "#sh_mark_" .. mark .. ".png"
	if itemData.rank == 0 then
		bgName = "#sh_bg_5.png"
		playerBgName = "#sh_name_bg_6.png"
		lvBgName = "#sh_lv_bg_5.png"
	elseif itemData.rank < 4 then
		bgName = "#sh_bg_" .. itemData.rank .. ".png"
		playerBgName = "#sh_name_bg_" .. itemData.rank .. ".png"
		lvBgName = "#sh_lv_bg_" .. itemData.rank .. ".png"
	end
	self._rootnode.bg_node:removeAllChildren()
	local bg = display.newScale9Sprite(bgName, 0, 0, self._rootnode.bg_node:getContentSize())
	bg:setAnchorPoint(0, 0)
	self._rootnode.bg_node:addChild(bg)
	self._rootnode.name_bg:removeAllChildren()
	local playerBg = display.newScale9Sprite(playerBgName, 0, 0, self._rootnode.name_bg:getContentSize())
	playerBg:setAnchorPoint(0, 0)
	self._rootnode.name_bg:addChild(playerBg)
	self._rootnode.lv_bg:setDisplayFrame(display.newSprite(lvBgName):getDisplayFrame())
	self._rootnode.mark_icon:setDisplayFrame(display.newSprite(markIcon):getDisplayFrame())
	self._rootnode.lv_lbl:setString("LV." .. tostring(itemData.lv))
	self._rootnode.name_lbl:setString(itemData.name)
	if mark == 0 then
		self._rootnode.hurt_node:setVisible(false)
		self._rootnode.jisha_node:setVisible(true)
	else
		self._rootnode.hurt_node:setVisible(true)
		self._rootnode.jisha_node:setVisible(false)
		self._rootnode.hurt_lbl:setString(itemData.hurt or 0)
	end
	if itemData.faction ~= nil and itemData.faction ~= "" then
		self._rootnode.guild_name_lbl:setString("[" .. tostring(itemData.faction) .. "]")
	else
		self._rootnode.guild_name_lbl:setString("")
	end
	if itemData.isTrueData ~= nil and not itemData.isTrueData then
		self._rootnode.zhenrongBtn:setEnabled(false)
	else
		self._rootnode.zhenrongBtn:setEnabled(true)
	end
	alignNodesOneByAllCenterX(self._rootnode.hurt_node, {
	self._rootnode.InjuryBloodLabel,
	self._rootnode.hurt_lbl
	}, 5)
end

return WorldBossRankItem
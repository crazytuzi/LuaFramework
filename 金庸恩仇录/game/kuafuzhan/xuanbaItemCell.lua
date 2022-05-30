local MAX_ZORDER = 10003
local xuanbaItemCell = class("xuanbaItemCell", function()
	return CCTableViewCell:new()
end)

function xuanbaItemCell:getContentSize()
	if self.cntSize == nil then
		local proxy = CCBProxy:create()
		local rootNode = {}
		local node = CCBuilderReaderLoad("kuafu/xuanba_item_cell.ccbi", proxy, rootNode)
		self.cntSize = rootNode.itemBg:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self.cntSize
end

function xuanbaItemCell:onExit()
end

function xuanbaItemCell:refresh(itemData)
	self._itemData = itemData
	if not self._itemData.faction then
		self._rootnode.gang_name:setVisible(false)
	elseif string.len(self._itemData.faction) == 0 then
		self._rootnode.gang_name:setVisible(false)
	else
		self._rootnode.gang_name:setVisible(true)
		self._rootnode.gang_name:setString(common:getLanguageString("@kfs_mingzifuhao", self._itemData.faction))
	end
	local id = itemData.rank
	local playerBgName = "#arena_name_bg_4.png"
	local bgname = "#arena_itemBg_4.png"
	local innerBgName = "#arena_itemInner_bg_1.png"
	local lvBgName = "#arena_lv_bg_4.png"
	if self._formationFunc then
		if game.player:checkIsSelfByAcc(itemData.account) and game.player:getServerID() == itemData.serverId then
			playerBgName = "#arena_name_bg_5.png"
			bgname = "#arena_itemBg_5.png"
			self._rootnode.form_btn:setVisible(false)
		else
			self._rootnode.form_btn:setVisible(true)
		end
		if self.markIcon then
			self.markIcon:removeSelf()
			self.markIcon = nil
		end
		if id < 4 then
			playerBgName = "#arena_name_bg_" .. id .. ".png"
			bgname = "#arena_itemBg_" .. id .. ".png"
			lvBgName = "#arena_lv_bg_" .. id .. ".png"
			innerBgName = "#arena_itemInner_bg_" .. id .. ".png"
			display.addSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
			self.markIcon = display.newSprite("#wj_extra_mark_" .. id + 1 .. ".png")
			self:addChild(self.markIcon)
			self.markIcon:setPosition(self:getContentSize().width * 0.07, self:getContentSize().height * 0.85)
		end
		self._rootnode.innerBg_node:removeAllChildren()
		local innerBg = display.newScale9Sprite(innerBgName, 0, 0, self._rootnode.innerBg_node:getContentSize())
		innerBg:setAnchorPoint(0, 0)
		self._rootnode.innerBg_node:addChild(innerBg)
		self._rootnode.lv_bg:setDisplayFrame(display.newSprite(lvBgName):getDisplayFrame())
	end
	
	if self._challengeFunc then
		if self._itemData.account == game.player:getAccount() and self._itemData.serverId == game.player:getServerID() then
			self._showBtn:setVisible(false)
			self._rootnode.has_challenge_label:setVisible(false)
		else
			self._showBtn:setVisible(true)
			self._rootnode.has_challenge_label:setVisible(false)
		end
		--[[
		if self._itemData.hasChallenge then
			self._showBtn:setVisible(false)
			self._rootnode.has_challenge_label:setVisible(true)
		else
			self._showBtn:setVisible(true)
			self._rootnode.has_challenge_label:setVisible(false)
		end
		]]
	elseif self._revengeFunc then
		if self._itemData.revengen == 1 then
			self._showBtn:setVisible(false)
			self._rootnode.has_challenge_label:setVisible(true)
			local challenge_text = common:getLanguageString("@kuafuChallengeLabel") .. common:getLanguageString("@SuccessLabel")
			self._rootnode.has_challenge_label:setString(challenge_text)
		elseif self._itemData.revengen == 2 then
			self._showBtn:setVisible(false)
			self._rootnode.has_challenge_label:setVisible(true)
			local challenge_text = common:getLanguageString("@kuafuChallengeLabel") .. common:getLanguageString("@FailedLabel")
			self._rootnode.has_challenge_label:setString(challenge_text)
		else
			self._showBtn:setVisible(true)
			self._rootnode.has_challenge_label:setVisible(false)
		end
	end
	self._rootnode.bg_node:removeAllChildren()
	local bg = display.newScale9Sprite(bgname, 0, 0, self._rootnode.bg_node:getContentSize())
	bg:setAnchorPoint(0, 0)
	self._rootnode.bg_node:addChild(bg)
	self._rootnode.name_bg:removeAllChildren()
	local playerBg = display.newScale9Sprite(playerBgName, 0, 0, self._rootnode.name_bg:getContentSize())
	playerBg:setAnchorPoint(0, 0)
	self._rootnode.name_bg:addChild(playerBg)
	self._rootnode.lv_num:setString("LV." .. tostring(self._itemData.level))
	self._rootnode.jifen_num:setString(tostring(self._itemData.point))
	local playerName = self._itemData.roleName
	self._rootnode.player_name:setString(playerName)
	self._rootnode.rank_num:setString(common:getLanguageString("@Ranking", tostring(self._itemData.rank)))
	self._rootnode.fight_num:setString(tostring(self._itemData.battlePower))
	local server_num = common:getLanguageString("@kfs_fuwuqi") .. self._itemData.serverName
	self._rootnode.server_num:setString(server_num)
	alignNodesOneByOne(self._rootnode.jifen_label, self._rootnode.jifen_num, 5)
	for i = 1, 4 do
		self._rootnode["icon_" .. i]:setVisible(false)
	end
	for key, team in ipairs(self._itemData.resTeam) do
		if key < 5 then
			self._rootnode["icon_" .. key]:setVisible(true)
			local cls = team.cls
			local resId = team.resId
			ResMgr.refreshIcon({
			id = resId,
			itemBg = self._rootnode["icon_" .. key],
			resType = ResMgr.HERO,
			cls = cls
			})
		end
	end
end

function xuanbaItemCell:create(param)
	local _id = param.id
	self._challengeFunc = param.challengeFunc
	self._formationFunc = param.formationFunc
	self._revengeFunc = param.revengeFunc
	self._itemData = param.itemData
	dump(self._itemData)
	self:setNodeEventEnabled(true)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("kuafu/xuanba_item_cell.ccbi", proxy, self._rootnode)
	node:setPosition(display.width / 2, 0)
	self:addChild(node)
	self._rootnode.form_btn:setVisible(false)
	self._rootnode.challenge_btn:setVisible(false)
	self._showBtn = nil
	local challenge_text
	local function addBtnHandler(btn, callBack)
		if callBack then
			btn:setVisible(true)
			btn:addHandleOfControlEvent(function(eventName, sender)
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				callBack(self._itemData)
			end,
			CCControlEventTouchUpInside)
			
			self._showBtn = btn
		else
			btn:setVisible(false)
		end
	end
	addBtnHandler(self._rootnode.challenge_btn, self._challengeFunc)
	addBtnHandler(self._rootnode.form_btn, self._formationFunc)
	addBtnHandler(self._rootnode.revenge_btn, self._revengeFunc)
	if self._challengeFunc then
		local challenge_text = common:getLanguageString("@kuafuChallengeLabel") .. common:getLanguageString("@SuccessLabel")
		self._rootnode.has_challenge_label:setString(challenge_text)
	end
	self:refresh(param.itemData)
	return self
end

function xuanbaItemCell:beTouched()
end

return xuanbaItemCell
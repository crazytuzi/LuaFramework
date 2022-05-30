local data_item_item = require("data.data_item_item")
local data_ui_ui = require("data.data_ui_ui")
local data_union_fuben_union_fuben = require("data.data_union_fuben_union_fuben")
local data_config_union_config_union = require("data.data_config_union_config_union")
local MAX_ZORDER = 100

local GuildFubenScene = class("GuildFubenScene", function()
	local bottomFile = "guild/guild_bottom_frame_normal.ccbi"
	local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType
	if jopType ~= GUILD_JOB_TYPE.normal then
		bottomFile = "guild/guild_bottom_frame.ccbi"
	end
	return require("game.guild.utility.GuildBaseScene").new({
	contentFile = "guild/guild_fuben_bg.ccbi",
	subTopFile = "guild/guild_fuben_up_tab.ccbi",
	bottomFile = bottomFile
	})
end)

function GuildFubenScene:reqLevelup(msgBox)
	levelupBtn = self._rootnode.levelup_btn
	RequestHelper.Guild.unionLevelUp({
	unionid = game.player:getGuildMgr():getGuildInfo().m_id,
	buildtype = self._buildType,
	errback = function(data)
		levelupBtn:setEnabled(true)
		msgBox:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data, "建筑升级", 8)
		ResMgr.showErr(2900083)
		msgBox:removeFromParentAndCleanup(true)
		self:updateLevel(data.buildLevel, data.currentUnionMoney)
		game.player:getGuildInfo():updateData({
		fubenLevel = data.buildLevel,
		currentUnionMoney = data.currentUnionMoney
		})
		self:forceUpdateShowType()
		levelupBtn:setEnabled(true)
	end
	})
end

function GuildFubenScene:reqListData(showType, cb)
	RequestHelper.Guild.enterUnionCopy({
	type = showType,
	errback = function()
	end,
	callback = function(data)
		dump(data, "副本", 8)
		cb(data)
	end
	})
end

function GuildFubenScene:getReward(showType, cell, itemData, msgBox)
	local bagObj = {}
	local function extendBag(data)
		if bagObj[1].curCnt < data["1"] then
			table.remove(bagObj, 1)
		else
			bagObj[1].cost = data["4"]
			bagObj[1].size = data["5"]
		end
		if #bagObj > 0 then
			game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = bagObj,
			callback = function(data)
				extendBag(data)
			end
			}), MAX_ZORDER)
		end
	end
	RequestHelper.Guild.getFubenReward({
	id = itemData.id,
	errback = function()
		msgBox:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data, "领取帮派副本奖励", 8)
		if #data.packet > 0 then
			msgBox:setBtnEnabled(true)
			game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj =  data.packet,
			callback = function(data)
				extendBag(data)
			end
			}), MAX_ZORDER)
		else
			ResMgr.showErr(2900090)
			itemData.boxState = FUBEN_REWARD_STATE.hasGet
			cell:setBoxState(itemData.boxState)
			msgBox:removeFromParentAndCleanup(true)
			local num = 0
			for k, v in pairs(itemData.rewardList) do
				if v.id == 2 then
					num = num + v.num
				end
			end
			game.player:setSilver(game.player:getSilver() + num)
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
		end
	end
	})
end

function GuildFubenScene:showRankLayer()
	RequestHelper.Guild.showHurtList({
	errback = function()
		self._rootnode.shuchuBtn:setEnabled(true)
	end,
	callback = function(data)
		dump(data, "伤害排行", 8)
		local hurtList = data.hurtList
		local layer = require("game.guild.guildFuben.GuildFubenRankLayer").new({
		hurtList = hurtList,
		confirmFunc = function()
			self._rootnode.shuchuBtn:setEnabled(true)
		end
		})
		self:addChild(layer, MAX_ZORDER)
	end
	})
end

function GuildFubenScene:forceUpdateShowType()
	self:setShowType(self._showType)
end

function GuildFubenScene:ctor(param)
	self._buildType = GUILD_BUILD_TYPE.fuben
	self._hasShowRewardBox = false
	local data = param.data
	self:regNotice()
	self._listViewSize = cc.size(self._rootnode.listView:getContentSize().width, self:getCenterHeightWithSubTop())
	
	--返回
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
	end,
	CCControlEventTouchUpInside)
	
	--输出排行
	local shuchuBtn = self._rootnode.shuchuBtn
	shuchuBtn:addHandleOfControlEvent(function(sender, eventName)
		shuchuBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:showRankLayer()
	end,
	CCControlEventTouchUpInside)
	
	--奖励预览
	local RewardShowBtn = self._rootnode.RewardShowBtn
	RewardShowBtn:addHandleOfControlEvent(function(sender, eventName)
		local layer = require("game.huashan.HuaShanRewardShow").new({miPageId = 2})
		self:addChild(layer, 100)
	end,
	CCControlEventTouchUpInside)
	
	--说明
	local helpBtn = self._rootnode.helpBtn
	helpBtn:addHandleOfControlEvent(function(sender, eventName)
		helpBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local helpLayer = require("game.guild.guildFuben.GuildFubenHelpLayer").new({
		msg = data_ui_ui[10].content,
		closeFunc = function()
			helpBtn:setEnabled(true)
		end
		})
		self:addChild(helpLayer, MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
	local jopType = game.player:getGuildInfo().m_jopType
	local guildMgr = game.player:getGuildMgr()
	local levelupBtn = self._rootnode.levelup_btn
	if jopType == GUILD_JOB_TYPE.leader or jopType == GUILD_JOB_TYPE.assistant then
		--升级副本
		levelupBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if guildMgr:checkIsReachMaxLevel(self._buildType, self._level) == true then
				ResMgr.showErr(2900021)
			else
				levelupBtn:setEnabled(false)
				local msgBox = require("game.guild.GuildBuildLevelUpMsgBox").new({
				curLevel = self._level,
				toLevel = self._level + 1,
				needCoin = self._needCoin,
				curCoin = self._currentUnionMoney,
				buildType = self._buildType,
				cancelFunc = function()
					levelupBtn:setEnabled(true)
				end,
				confirmFunc = function(msgBox)
					self:reqLevelup(msgBox)
				end
				})
				game.runningScene:addChild(msgBox, MAX_ZORDER)
			end
		end,
		CCControlEventTouchUpInside)
	else
		levelupBtn:setVisible(false)
	end
	
	local fbList = data.fbList
	self:createAllLbl()
	self:updateInfo(data)
	self._showType = 1
	self:createTopList(self._showType, fbList)
	self._bExit = false
	addbackevent(self)
end

function GuildFubenScene:updateInfo(data)
	self._maxType = data.type
	self._canBuyCount = data.canBuyCount
	self._vipLevel = data.vipLevel
	self._battleLvId = data.battleLvId
	self:updateLeftCount(data.leftCount)
	self:updateLevel(data.copyLevel, data.currentUnionMoney)
end

function GuildFubenScene:updateLeftCount(count)
	self._leftCount = count or 0
	self._rootnode.today_left_num:setString(tostring(self._leftCount))
	alignNodesOneByAllCenterX(self._rootnode.propLabel_1:getParent(), {
	self._rootnode.propLabel_1,
	self._rootnode.today_left_num,
	self._rootnode.propLabel_3
	}, 2)
end

function GuildFubenScene:updateLevel(level, currentUnionMoney)
	local guildMgr = game.player:getGuildMgr()
	self._level = level
	guildMgr:getGuildInfo().m_fubenLevel = self._level
	self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level)
	self._currentUnionMoney = currentUnionMoney
	self:createShadowLbl("LV." .. tostring(self._level), cc.c3b(255, 222, 0), self._rootnode, "cur_level_lbl")
	self:createShadowLbl(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode, "cur_coin_lbl")
	self:updateNeedCoinLbl(self._needCoin)
end

function GuildFubenScene:updateNeedCoinLbl(needCoin)
	local str, isMax
	if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then
		str = common:getLanguageString("@GuildLvMax")
		isMax = true
	else
		str = tostring(needCoin)
		isMax = false
	end
	local node = self:createShadowLbl(str, FONT_COLOR.WHITE, self._rootnode, "cost_coin_lbl")
	alignNodesOneByOne(self._rootnode.cost_coin_msg_lbl, self._rootnode.cost_coin_lbl)
end

function GuildFubenScene:createShadowLbl(text, color, nodes, name, size)
	local lbl = ui.newTTFLabelWithShadow({
	text = text,
	size = size or 20,
	color = color,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = color,
	shadowColor = FONT_COLOR.BLACK,
	})
	ResMgr.replaceKeyLableEx(lbl, nodes, name, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildFubenScene:createAllLbl()
	local yColor = cc.c3b(255, 222, 0)
	self.GuildGoldForUpgrade = self:createShadowLbl(common:getLanguageString("@GuildGoldForUpgrade"), yColor, self._rootnode, "cost_coin_msg_lbl")
	self:createShadowLbl(common:getLanguageString("@GuildGold"), yColor, self._rootnode, "cur_coin_msg_lbl")
end

function GuildFubenScene:createTopList(showType, fbList)
	self._showType = showType
	local proxy = CCBProxy:create()
	local rootnode = {}
	self._topListData = {}
	for i = 1, data_config_union_config_union[1].guild_fuben_max_chapter do
		table.insert(self._topListData, i)
	end
	local listViewSize = self._rootnode.top_listView:getContentSize()
	local itemFileName = "game.guild.guildFuben.GuildFubenTopCell"
	local function createFunc(index)
		local bSelected = false
		if self._showType == self._topListData[index + 1] then
			bSelected = true
		end
		local item = require(itemFileName).new()
		return item:create({
		viewSize = listViewSize,
		chapterId = self._topListData[index + 1],
		bSelected = bSelected
		})
	end
	local function refreshFunc(cell, index)
		local bSelected = false
		if self._showType == self._topListData[index + 1] then
			bSelected = true
		end
		cell:refresh({
		chapterId = self._topListData[index + 1],
		bSelected = bSelected
		})
	end
	local cellContentSize = require(itemFileName).new():getContentSize()
	
	self._topListTable = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionHorizontal,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._topListData,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		if cell:getChapterId() ~= self._showType then
			local icon = cell:getIcon()
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				if cell:getChapterId() > self._maxType then
					ResMgr.showErr(2900093)
				else
					self:setShowType(cell:getChapterId())
				end
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			end
		end
	end
	})
	self._rootnode.top_listView:addChild(self._topListTable)
	local pageCount = self._topListTable:getViewSize().width / cellContentSize.width
	local maxMove = self._topListTable:getCellNum() - pageCount
	local curIndex = 0
	local tmpCount = 0
	for i, v in ipairs(self._topListData) do
		if v == self._showType then
			tmpCount = i
			break
		end
	end
	if pageCount < tmpCount then
		curIndex = tmpCount - pageCount
	end
	if maxMove < curIndex then
		curIndex = maxMove
	end
	if pageCount < self._topListTable:getCellNum() then
		self._topListTable:setContentOffset(CCPoint(-curIndex * cellContentSize.width, 0))
	end
	self:setShowType(showType, fbList)
end

function GuildFubenScene:getTotalHp(cardId)
	local hp = 0
	local cardData = ResMgr.getCardData(cardId)
	hp = hp + cardData.base[1]
	return hp
end

function GuildFubenScene:createItemData(fbItem, preItm)
	local item = data_union_fuben_union_fuben[fbItem.id]
	if fbItem.state == FUBEN_STATE.hasPass then
		if fbItem.rewardState == 0 then
			fbItem.boxState = FUBEN_REWARD_STATE.canGet
		elseif fbItem.rewardState == 1 then
			fbItem.boxState = FUBEN_REWARD_STATE.hasGet
		elseif fbItem.rewardState == 2 then
			fbItem.boxState = FUBEN_REWARD_STATE.canGet
		end
	else
		fbItem.boxState = FUBEN_REWARD_STATE.notOpen
		--[[
		if fbItem.state == FUBEN_STATE.hasOpen and self._battleLvId < item.battle then
			fbItem.state = FUBEN_STATE.notOpen
		end
		]]
		if fbItem.state == FUBEN_STATE.notOpen then
			fbItem.openMsg = {}
			local preTxt = ""
			local battleTxt = ""
			local lvTxt = ""
			if item.prefield ~= 0 and preItm ~= nil and preItm.state ~= FUBEN_STATE.hasPass then
				preTxt = item.preTxt
			end
			--[[
			if self._level < item.limitlevel then
				lvTxt = item.lvTxt
			end
			if self._battleLvId < item.battle then
				battleTxt = item.battleTxt
			end
			]]
			fbItem.openMsg.preTxt = preTxt
			fbItem.openMsg.lvTxt = lvTxt
			fbItem.openMsg.battleTxt = battleTxt
		end
	end
	fbItem.totalHp = self:getTotalHp(item.card)
	fbItem.icon = item.icon
	local rewardList = {}
	for j = 1, item.num do
		local rewardId = item.rewardIds[j]
		local rewardType = item.rewardTypes[j]
		local rewardItem
		local iconType = ResMgr.getResType(rewardType)
		if iconType == ResMgr.HERO then
			rewardItem = ResMgr.getCardData(rewardId)
		else
			rewardItem = data_item_item[rewardId]
		end
		table.insert(rewardList, {
		id = rewardId,
		type = rewardType,
		name = rewardItem.name,
		describe = rewardItem.describe,
		iconType = iconType,
		num = item.rewardNums[j]
		})
	end
	fbItem.rewardList = rewardList
end

function GuildFubenScene:setShowType(showType, listData)
	self._showType = showType
	if self._topListTable ~= nil then
		for i = 0, self._topListTable:getCellNum() - 1 do
			local cell = self._topListTable:cellAtIndex(i)
			if cell ~= nil then
				if self._showType == cell:getChapterId() then
					cell:setSelected(true)
				else
					cell:setSelected(false)
				end
			end
		end
	end
	local function setData(data)
		self._listData = {}
		local function isHasAdd(id)
			local bAdd = false
			for i, v in ipairs(self._listData) do
				if v.id == id then
					bAdd = true
					break
				end
			end
			return bAdd
		end
		for i = 1, #data do
			local max = -1
			local idx = -1
			for j, v in ipairs(data) do
				if max < v.id and isHasAdd(v.id) == false then
					max = v.id
					idx = j
				end
			end
			if idx ~= -1 then
				table.insert(self._listData, data[idx])
			end
		end
		for i, v in ipairs(self._listData) do
			local preItm
			if i < #self._listData then
				preItm = self._listData[i + 1]
			end
			self:createItemData(v, preItm)
		end
		self:reloadListView(self._listData)
	end
	if listData ~= nil then
		setData(listData)
	else
		self:reqListData(self._showType, function(data)
			self:updateInfo(data)
			setData(data.fbList)
		end)
	end
end

function GuildFubenScene:reloadListView(listData)
	if self._listTable ~= nil then
		self._listTable:removeFromParentAndCleanup(true)
	end
	local dataList = listData
	local function showRewardBox(itemData, cell)
		local msgBox = require("game.guild.guildFuben.GuildFubenRewardMsgBox").new({
		topMsg = data_ui_ui[15].content,
		boxState = itemData.boxState,
		rewordState = itemData.rewardState,
		cellDatas = itemData.rewardList,
		closeFunc = function(box)
			self._hasShowRewardBox = false
		end,
		rewardFunc = function(box)
			self._hasShowRewardBox = false
			self:getReward(self._showType, cell, itemData, box)
		end
		})
		self:addChild(msgBox, MAX_ZORDER)
	end
	
	local function showFubenInfoLayer(itemData, cell)
		game.player:getGuildMgr():RequestFubenInfo({
		id = itemData.id,
		errcb = function()
			self._hasShowRewardBox = false
		end,
		cb = function(data)
			itemData.leftHp = data.leftHp
			if data.isDead == 0 then
				itemData.state = FUBEN_STATE.hasPass
				if itemData.boxState == FUBEN_REWARD_STATE.notOpen then
					itemData.boxState = FUBEN_REWARD_STATE.canGet
				end
			end
			cell:updateHp(itemData)
			local infoLayer = require("game.guild.guildFuben.GuildFubenInfoLayer").new({
			itemData = itemData,
			data = data,
			showFunc = function()
				self._hasShowRewardBox = false
			end
			})
			self:addChild(infoLayer, MAX_ZORDER)
		end
		})
	end
	local itemFileName = "game.guild.guildFuben.GuildFubenCell"
	local function createFunc(index)
		local item = require(itemFileName).new()
		return item:create({
		viewSize = self._listViewSize,
		itemData = dataList[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(dataList[index + 1])
	end
	local cellContentSize = require(itemFileName).new():getContentSize()
	
	self._listTable = require("utility.TableViewExt").new({
	size = self._listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #dataList,
	cellSize = cellContentSize,
	touchFunc = function(cell, x , y)
		if self._hasShowRewardBox == false then
			local icon = cell:getRewardBoxIcon()
			local itemData = dataList[cell:getIdx() + 1]
			local pos = icon:convertToNodeSpace(cc.p(x, y))
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
				self._hasShowRewardBox = true
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				showRewardBox(itemData, cell)
			else
				if itemData.state == FUBEN_STATE.notOpen then
					ResMgr.showErr(2900093)
				else
					self._hasShowRewardBox = true
					showFubenInfoLayer(itemData, cell)
				end
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			end
		end
	end
	})
	self._listTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self._listTable)
end

function GuildFubenScene:onEnter()
	game.runningScene = self
	game.broadcast:reSet(self._rootnode.broadcast_tag)
	self:regNotice()
end

function GuildFubenScene:onExit()
	self:unregNotice()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	if self._checkSchedule ~= nil then
		self._scheduler.unscheduleGlobal(self._checkSchedule)
	end
	--self._bExit = true
end

return GuildFubenScene
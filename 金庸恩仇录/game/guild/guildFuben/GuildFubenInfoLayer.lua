local data_union_fuben_union_fuben = require("data.data_union_fuben_union_fuben")
local data_item_item = require("data.data_item_item")
local data_union_fubenui_union_fubenui = require("data.data_union_fubenui_union_fubenui")
local MAX_ZORDER = 11113

local GuildFubenInfoLayer = class("GuildFubenInfoLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildFubenInfoLayer:ctor(param)
	self._itemData = param.itemData
	local data = param.data
	local showFunc = param.showFunc
	local fbItem = data_union_fuben_union_fuben[self._itemData.id]
	self._hasShowInfo = false
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/guild/guild_fuben_info.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	local function closeBtnFunc()
		game.player:getGuildMgr():setFbInfoLayer(nil)
		if game.player:getGuildMgr():getFbHasFight() == true then
			game.player:getGuildMgr():setFbHasFight(false)
			self:getParent():forceUpdateShowType()
		end
		self:removeFromParentAndCleanup(true)
	end
	
	self._rootnode.returnBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeBtnFunc()
	end,
	CCControlEventTouchUpInside)
	
	local closeBtn = self._rootnode.closeBtn
	local enterBtn = self._rootnode.enterBtn
	closeBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeBtnFunc()
	end,
	CCControlEventTouchUpInside)
	
	local function enterBtnEnabled(bEnable)
		enterBtn:setEnabled(bEnable)
	end
	
	enterBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._leftCount < 1 then
			ResMgr.showErr(2900089)
		else
			enterBtnEnabled(false)
			self:showChooseHeroScene({isClicked = true})
		end
	end,
	CCControlEventTouchUpInside)
	
	local bossIcon = self._rootnode.tag_bossIcon
	local bossIconBg = ResMgr.getLevelBossIcon(fbItem.bossicon, 3)
	bossIcon:addChild(bossIconBg)
	local titleLabel = ui.newTTFLabelWithOutline({
	text = fbItem.bossname,
	font = FONTS_NAME.font_fzcy,
	size = 30,
	color = FONT_COLOR.LEVEL_NAME,
	align = ui.TEXT_ALIGN_CENTER
	})
	
	titleLabel:align(display.CENTER)
	ResMgr.replaceKeyLableEx(titleLabel, self._rootnode, "title_lbl", 0, 0)
	
	local rewardList = {}
	for i = 1, fbItem.dropnum do
		local rewardId = fbItem.dropIds[i]
		local rewardType = fbItem.dropTypes[i]
		local rewardItem
		local iconType = ResMgr.getResType(rewardType)
		if iconType == ResMgr.HERO then
			rewardItem = ResMgr.getCardData(rewardId)
		else
			rewardItem = data_item_item[rewardId]
		end
		ResMgr.showAlert(rewardItem, common:getLanguageString("@HintNoID") .. rewardId .. "type: " .. rewardType)
		table.insert(rewardList, {
		id = rewardId,
		type = rewardType,
		name = rewardItem.name,
		describe = rewardItem.describe,
		iconType = iconType,
		num = 1
		})
	end
	self:createRewardList(rewardList)
	self:updateData(data)
	if showFunc ~= nil then
		showFunc()
	end
end

function GuildFubenInfoLayer:showChooseHeroScene(param)
	local isClicked = param.isClicked
	local fbItem = data_union_fuben_union_fuben[self._itemData.id]
	game.player:getGuildMgr():RequestFubenChooseCard({
	sysId = fbItem.sys_id,
	errcb = function()
		if isClicked == true then
			self._rootnode.enterBtn:setEnabled(true)
		end
	end,
	cb = function(msg)
		if msg.state == 1 then
			if isClicked == true then
				ResMgr.showErr(2900094)
				self._rootnode.enterBtn:setEnabled(true)
			end
		else
			do
				local _needLeadRole = false
				local fbItem = data_union_fuben_union_fuben[self._itemData.id]
				if fbItem.lead_role == 1 then
					_needLeadRole = true
				end
				local function extendBag(data)
					if self._bagObj[1].curCnt < data["1"] then
						table.remove(self._bagObj, 1)
					else
						self._bagObj[1].cost = data["4"]
						self._bagObj[1].size = data["5"]
					end
					if #self._bagObj > 0 then
						game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
						bagObj = self._bagObj,
						callback = function(data)
							extendBag(data)
						end
						}), MAX_ZORDER)
					end
				end
				push_scene(require("game.scenes.formSettingBaseScene").new({
				id = self._itemData.id,
				heros = self:sortCards(msg.cardsList),
				formSettingType = FormSettingType.BangPaiFuBenType,
				needLeadRole = _needLeadRole,
				confirmFunc = function(fmtstr)
					RequestHelper.Guild.unionFBfight({
					id = self._itemData.id,
					sysid = fbItem.sys_id,
					fmt = fmtstr,
					callback = function(data)
						if data["0"] == 1 then
							self._bagObj = data["1"]
							game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
							bagObj = self._bagObj,
							callback = function(data)
								extendBag(data)
							end
							}), MAX_ZORDER)
						elseif data["0"] == 2 then
							ResMgr.showErr(2900097)
							game.player:getGuildMgr():forceUpdateFbInfoLayer({
							reqEndFunc = function()
								pop_scene()
							end
							})
						else
							pop_scene()
							game.player:getGuildMgr():setFbHasFight(true)
							local scene = require("game.guild.guildFuben.GuildFubenBattleScene").new({
							data = data,
							id = self._itemData.id
							})
							push_scene(scene)
						end
						GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
					end
					})
				end,
				
				showFunc = function()
					if isClicked == true then
						self._rootnode.enterBtn:setEnabled(true)
					end
				end
				}))
			end
		end
	end
	})
end

function GuildFubenInfoLayer:forceUpdate(param)
	local reqEndFunc = param.reqEndFunc
	game.player:getGuildMgr():RequestFubenInfo({
	id = self._itemData.id,
	errcb = function()
	end,
	cb = function(msg)
		self._itemData.leftHp = msg.leftHp
		self:updateData(msg)
		if reqEndFunc ~= nil then
			reqEndFunc()
		end
	end
	})
end

function GuildFubenInfoLayer:updateData(data)
	local fbItem = data_union_fuben_union_fuben[self._itemData.id]
	local closeBtn = self._rootnode.closeBtn
	local enterBtn = self._rootnode.enterBtn
	local deadIcon = self._rootnode.dead_icon
	if data.isDead == 0 then
		closeBtn:setVisible(true)
		enterBtn:setVisible(false)
		deadIcon:setVisible(true)
	elseif data.isDead == 1 then
		closeBtn:setVisible(false)
		enterBtn:setVisible(true)
		deadIcon:setVisible(false)
	end
	self._leftCount = data.leftCount or 0
	--self._rootnode.attack_lbl:setString(tostring(data.attackNum))
	--self._rootnode.hurt_lbl:setString(tostring(data.allDamage))
	alignNodesOneByOne(self._rootnode.hurt_Tag, self._rootnode.hurt_lbl)
	alignNodesOneByOne(self._rootnode.attack_Tag, self._rootnode.attack_lbl)
	self._rootnode.blood_lbl:setString(tostring(data.leftHp) .. "/" .. tostring(data.totalHp))
	local percent = data.leftHp / data.totalHp
	if percent > 1 then
		percent = 1
	end
	local normalBar = self._rootnode.normalBar
	local bar = self._rootnode.addBar
	local rotated = false
	if bar:isTextureRectRotated() == true then
		rotated = true
	end
	bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, normalBar:getContentSize().width * percent, bar:getTextureRect().height), rotated, cc.size(normalBar:getContentSize().width * percent, normalBar:getContentSize().height * percent))
	
	data.attackNum = 0
	data.allDamage = 0
	
	local dynamicList = {}
	for i, v in ipairs(data.ufbdlist) do
		local item = data_union_fubenui_union_fubenui[v.type]
		ResMgr.showAlert(item, "data_union_fubenui_union_fubenui没有此id: " .. v.type)
		local itemData = {}
		itemData.content = string.format(data_union_fubenui_union_fubenui[1].content, v.name, v.damage)
		table.insert(dynamicList, itemData)
		if v.type == 2 then
			itemData = {}
			itemData.content = string.format(item.content, v.name, fbItem.bossname)
			table.insert(dynamicList, itemData)
		end
		if v.roleId == game.player.m_playerID then
			data.attackNum = data.attackNum + 1
			data.allDamage = data.allDamage + v.damage
		end
	end
	self:createDynamicList(dynamicList)
	self._rootnode.attack_lbl:setString(tostring(data.attackNum))
	self._rootnode.hurt_lbl:setString(tostring(data.allDamage))
end

function GuildFubenInfoLayer:createRewardList(cellDatas)
	
	local function createFunc(index)
		local item = require("game.Huodong.RewardItem").new()
		return item:create({
		id = index,
		itemData = cellDatas[index + 1],
		viewSize = self._rootnode.bottom_listView:getContentSize()
		})
	end
	
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = cellDatas[index + 1]
		})
	end
	
	local cellContentSize = require("game.Huodong.RewardItem").new():getContentSize()
	self._rootnode.touchNode:setTouchEnabled(true)
	local listTable = require("utility.TableViewExt").new({
	size = self._rootnode.bottom_listView:getContentSize(),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #cellDatas,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		if self._hasShowInfo == false then
			local icon = cell:getRewardIcon()
			if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), icon:convertToNodeSpace(cc.p(x, y))) then
				self._hasShowInfo = true
				local idx = cell:getIdx() + 1
				local itemData = cellDatas[idx]
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
	end
	})
	listTable:setPosition(0, 0)
	self._rootnode.bottom_listView:addChild(listTable)
end

function GuildFubenInfoLayer:createDynamicList(dynamicList)
	self._rootnode.top_listView:removeAllChildrenWithCleanup(true)
	local fileName = "game.guild.guildFuben.GuildFubenDynamicItem"
	
	local function createFunc(index)
		local item = require(fileName).new()
		return item:create({
		itemData = dynamicList[index + 1],
		viewSize = self._rootnode.top_listView:getContentSize()
		})
	end
	
	local function refreshFunc(cell, index)
		cell:refresh(dynamicList[index + 1])
	end
	
	local cellContentSize = require(fileName).new():getContentSize()
	local listTable = require("utility.TableViewExt").new({
	size = self._rootnode.top_listView:getContentSize(),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #dynamicList,
	cellSize = cellContentSize
	})
	listTable:setPosition(0, 0)
	self._rootnode.top_listView:addChild(listTable)
end

function GuildFubenInfoLayer:sortCards(cards)
	local data_card_card = require("data.data_card_card")
	local getIsHasAdd = function(index, indexList)
		local bHas = false
		for i, v in ipairs(indexList) do
			if v == index then
				bHas = true
				break
			end
		end
		return bHas
	end
	local zizhiList = {}
	local clsList = {}
	local qianghuaList = {}
	local sameIdList = {}
	local function getItemByZizhi(indexList)
		local max = -1
		zizhiList = {}
		for i, v in ipairs(cards) do
			local zizhi = data_card_card[v.resId].arr_zizhi[v.cls + 1]
			if getIsHasAdd(i, indexList) == false and max < zizhi then
				max = zizhi
			end
		end
		for i, v in ipairs(cards) do
			local zizhi = data_card_card[v.resId].arr_zizhi[v.cls + 1]
			if getIsHasAdd(i, indexList) == false and zizhi == max then
				table.insert(zizhiList, i)
			end
		end
	end
	local function getItemByCls(indexList)
		local max = -1
		clsList = {}
		for i, v in ipairs(zizhiList) do
			if getIsHasAdd(v, indexList) == false and max < cards[v].cls then
				max = cards[v].cls
			end
		end
		for i, v in ipairs(zizhiList) do
			if getIsHasAdd(v, indexList) == false and cards[v].cls == max then
				table.insert(clsList, v)
			end
		end
	end
	local function getItemByQianghua(indexList)
		local max = -1
		qianghuaList = {}
		for i, v in ipairs(clsList) do
			if getIsHasAdd(v, indexList) == false and max < cards[v].level then
				max = cards[v].level
			end
		end
		for i, v in ipairs(clsList) do
			if getIsHasAdd(v, indexList) == false and cards[v].level == max then
				table.insert(qianghuaList, v)
			end
		end
	end
	local cardData = {}
	local indexList = {}
	local function addToList(index)
		if index ~= -1 and getIsHasAdd(index, indexList) == false then
			local itemData = cards[index]
			table.insert(indexList, index)
			table.insert(cardData, itemData)
		end
	end
	for i, v in ipairs(cards) do
		if v.resId == 1 or v.resId == 2 then
			addToList(i)
			break
		end
	end
	for i, v in ipairs(cards) do
		if v.cardId then
			v.id = v.cardId
		end
		if v.life then
			v.life = nil
		end
	end
	for _, _ in ipairs(cards) do
		getItemByZizhi(indexList)
		for _, _ in ipairs(zizhiList) do
			getItemByCls(indexList)
			for _, _ in ipairs(clsList) do
				getItemByQianghua(indexList)
				for _, v in ipairs(qianghuaList) do
					local id = cards[v].resId
					for _, value in ipairs(qianghuaList) do
						if id == cards[value].resId then
							addToList(value)
						end
					end
				end
			end
		end
	end
	return cardData
end

function GuildFubenInfoLayer:onEnter()
	game.player:getGuildMgr():setFbInfoLayer(self)
end

return GuildFubenInfoLayer
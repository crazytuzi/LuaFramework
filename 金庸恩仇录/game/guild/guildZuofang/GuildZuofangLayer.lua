local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
require("data.data_error_error")
local data_union_gongfang_union_gongfang = require("data.data_union_gongfang_union_gongfang")
local MAX_ZORDER = 110

local GuildZuofangLayer = class("GuildZuofangLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildZuofangLayer:reqLevelup(msgBox)
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
		workshopLevel = data.buildLevel,
		currentUnionMoney = data.currentUnionMoney
		})
		PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
		PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL)
		levelupBtn:setEnabled(true)
		self:initListData(data.typeList)
		self:updateBuildList(self._buildList)
		if self._curWorkData ~= nil then
			local tmpData = self._curWorkData
			for i, v in ipairs(self._buildList) do
				if v.id == self._curWorkData.id then
					self._curWorkData = v
					self._curWorkData.surplusTime = tmpData.surplusTime
					self._curWorkData.workType = tmpData.workType
					break
				end
			end
		else
			self._curWorkData = self._buildList[1]
		end
		self:selectedTab(self._curWorkData.id)
		self:updateCurBuildData(self._curWorkData)
	end
	})
end

function GuildZuofangLayer:startBuild(workData, workType, curBtns)
	local function resetBtns()
		for i, v in ipairs(curBtns) do
			v:setEnabled(true)
		end
	end
	RequestHelper.Guild.unionWorkShopProduct({
	unionid = game.player:getGuildMgr():getGuildInfo().m_id,
	workType = workType,
	workId = workData.id,
	errback = function(data)
		resetBtns()
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			resetBtns()
		else
			resetBtns()
			local rtnObj = data.rtnObj
			workData.workType = workType
			workData.surplusTime = rtnObj.surplusTime
			self:updateCurBuildData(workData)
			self:resetChooseBtnState(false, workData)
			self:updateGoldNum(rtnObj.surplusGold)
			self:updateFreeAndExtraCount(rtnObj.freeCount, rtnObj.extCount, rtnObj.extCostGold)
		end
	end
	})
end

function GuildZuofangLayer:endBuild(workData, curBtns)
	local function resetBtns()
		for i, v in ipairs(curBtns) do
			v:setEnabled(true)
		end
	end
	RequestHelper.Guild.unionWorkShopGetReward({
	unionId = game.player:getGuildMgr():getGuildInfo().m_id,
	errback = function(data)
		resetBtns()
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			resetBtns()
		else
			local rtnObj = data.rtnObj
			self:updateGoldNum(rtnObj.gold)
			self:showRewardMsgBox(rtnObj.rewardList)
			resetBtns()
			workData.surplusTime = -1
			self:updateCurBuildData(workData)
			self:resetChooseBtnState(true)
		end
	end
	})
end

function GuildZuofangLayer:checkWorkShopTime(workData)
	RequestHelper.Guild.checkWorkShopTime({
	type = 1,
	errback = function(data)
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		else
			local rtnObj = data.rtnObj
			if rtnObj.isOver == 0 then
				self:showRewardMsgBox(rtnObj.rewardList)
				workData.surplusTime = -1
				self:updateCurBuildData(workData)
				self:resetChooseBtnState(true)
			else
				workData.surplusTime = rtnObj.leftTime
			end
		end
	end
	})
end

function GuildZuofangLayer:showRewardMsgBox(rewardList)
	if rewardList ~= nil and #rewardList > 0 then
		local cellDatas = {}
		for i, v in ipairs(rewardList) do
			local item
			local iconType = ResMgr.getResType(v.t)
			if iconType == ResMgr.HERO then
				item = ResMgr.getCardData(v.id)
			else
				item = data_item_item[v.id]
			end
			table.insert(cellDatas, {
			id = v.id,
			type = v.t,
			name = item.name,
			iconType = iconType,
			num = v.n
			})
		end
		msgBox = require("game.Huodong.RewardMsgBox").new({cellDatas = cellDatas})
		game.runningScene:addChild(msgBox, MAX_ZORDER)
	end
end

function GuildZuofangLayer:ctor(data)
	dump(data, "作坊数据", 6)
	self._buildType = GUILD_BUILD_TYPE.zuofang
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_zuofang_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.width / 2, display.height / 2)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@GuildWorkshop"))
	--关闭
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	local guildMgr = game.player:getGuildMgr()
	local guildInfo = guildMgr:getGuildInfo()
	local jopType = guildInfo.m_jopType
	local levelupBtn = self._rootnode.levelup_btn
	if jopType ~= GUILD_JOB_TYPE.leader and jopType ~= GUILD_JOB_TYPE.assistant then
		levelupBtn:setVisible(false)
	else
		levelupBtn:setVisible(true)
		levelupBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if guildMgr:checkIsReachMaxLevel(self._buildType, self._level) == true then
				show_tip_label(data_error_error[2900021].prompt)
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
		
	end
	local rtnObj = data.rtnObj
	self:showRewardMsgBox(rtnObj.rewardList)
	self:updateLevel(rtnObj.workShopLevel, rtnObj.currentUnionMoney)
	self:updateGoldNum(rtnObj.gold)
	self:updateFreeAndExtraCount(rtnObj.freeCount, rtnObj.extNum, rtnObj.extGoldNum)
	self:createAllLbl()
	local typeList = rtnObj.typeList
	self:initListData(typeList)
	if rtnObj.isWork == 0 then
		for i, v in ipairs(self._buildList) do
			if v.id == rtnObj.workType then
				self._curWorkData = v
				self._curWorkData.surplusTime = rtnObj.surplusTime
				self._curWorkData.workType = rtnObj.overtimeflag
				self:resetChooseBtnState(false, self._curWorkData)
				break
			end
		end
	else
		self._curWorkData = self._buildList[1]
	end
	self:initBuildListView(self._buildList, self._curWorkData)
	self:initBtnEvent()
	self:initTimeSchedule()
end

function GuildZuofangLayer:initBtnEvent()
	local normalBuildBtn = self._rootnode.normal_build_btn
	local fastBuildBtn = self._rootnode.fast_build_btn
	local normalEndBtn = self._rootnode.normal_end_btn
	local fastEndBtn = self._rootnode.fast_end_btn
	local btns = {
	normalBuildBtn,
	fastBuildBtn,
	normalEndBtn,
	fastEndBtn
	}
	local function resetBtns(bEnabled)
		for i, v in ipairs(btns) do
			v:setEnabled(bEnabled)
		end
	end
	local function buildFunc(workType)
		resetBtns(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local function confirmBuildFunc()
			if workType == GUILD_ZF_WORK_TYPE.normal then
				self:startBuild(self._curWorkData, workType, btns)
			elseif workType == GUILD_ZF_WORK_TYPE.fast then
				if self._curGold < self._curWorkData.fastCostGold then
					show_tip_label(data_error_error[2900047].prompt)
					resetBtns(true)
				else
					self:startBuild(self._curWorkData, workType, btns)
				end
			end
		end
		if self._freeCount > 0 then
			confirmBuildFunc()
		elseif 0 >= self._extraCount then
			show_tip_label(data_error_error[2900027].prompt)
			resetBtns(true)
		elseif 0 < self._extraCount then
			local costGold = self._extraCostGold
			if workType == GUILD_ZF_WORK_TYPE.fast then
				costGold = self._extraCostGold + self._curWorkData.fastCostGold
			end
			local msgBox = require("game.guild.utility.GuildNormalMsgBox").new({
			title = common:getLanguageString("@Hint"),
			isSingleBtn = false,
			isBuyExtraBuild = true,
			extraCostGold = costGold,
			cancelFunc = function()
				resetBtns(true)
			end,
			confirmFunc = function(node)
				if self._curGold < self._extraCostGold then
					show_tip_label(data_error_error[2900050].prompt)
					resetBtns(true)
				else
					node:removeSelf()
					confirmBuildFunc()
				end
			end
			})
			game.runningScene:addChild(msgBox, MAX_ZORDER)
		end
	end
	local function endFunc()
		resetBtns(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._curGold < self._curWorkData.endCostGold then
			show_tip_label(data_error_error[2900051].prompt)
			resetBtns(true)
		else
			self:endBuild(self._curWorkData, btns)
		end
	end
	
	normalBuildBtn:addHandleOfControlEvent(function(sender, eventName)
		buildFunc(GUILD_ZF_WORK_TYPE.normal)
	end,
	CCControlEventTouchUpInside)
	
	fastBuildBtn:addHandleOfControlEvent(function(sender, eventName)
		buildFunc(GUILD_ZF_WORK_TYPE.fast)
	end,
	CCControlEventTouchUpInside)
	
	normalEndBtn:addHandleOfControlEvent(function(sender, eventName)
		endFunc()
	end,
	CCControlEventTouchUpInside)
	
	fastEndBtn:addHandleOfControlEvent(function(sender, eventName)
		endFunc()
	end,
	CCControlEventTouchUpInside)
	
end

function GuildZuofangLayer:initTimeSchedule()
	self._scheduler = require("framework.scheduler")
	local function updateTime()
		if self._curWorkData ~= nil and self._curWorkData.surplusTime ~= nil and self._curWorkData.surplusTime > 0 then
			self._curWorkData.surplusTime = self._curWorkData.surplusTime - 1
			if self._curWorkData.workType == GUILD_ZF_WORK_TYPE.normal then
				self._rootnode.normal_time_lbl:setString(format_time(self._curWorkData.surplusTime))
			else
				self._rootnode.fast_time_lbl:setString(format_time(self._curWorkData.surplusTime))
			end
			if self._curWorkData.surplusTime <= 0 then
				self:checkWorkShopTime(self._curWorkData)
			end
		end
	end
	self._checkSchedule = self._scheduler.scheduleGlobal(updateTime, 1, false)
end

function GuildZuofangLayer:initListData(buildList)
	self._buildList = {}
	local function getAddStr(id, t, n)
		local item
		local iconType = ResMgr.getResType(t)
		if iconType == ResMgr.HERO then
			item = ResMgr.getCardData(id)
		else
			item = data_item_item[id]
		end
		ResMgr.showAlert(item, common:getLanguageString("@HintRewardError") .. id .. common:getLanguageString("@TypeEnTex") .. t)
		local str = common:getLanguageString("@Increase") .. tostring(n) .. tostring(item.name)
		return str
	end
	for i, v in ipairs(buildList) do
		local itemData = v
		if v.isOpen == 0 then
			itemData.hasOpen = true
		elseif v.isOpen == 1 then
			itemData.hasOpen = false
		end
		local info = self:getDataInfoById(v.id)
		itemData.level = info.level
		itemData.lock = info.lock
		itemData.unlock = info.unlock
		itemData.endCostGold = info.end_cost_gold
		itemData.fastCostGold = info.fast_build_gold
		itemData.normalAddStr = getAddStr(v.itemId, v.itemType, v.normalNum)
		itemData.fastAddStr = getAddStr(v.itemId, v.itemType, v.fastNum)
		table.insert(self._buildList, itemData)
	end
end

function GuildZuofangLayer:getDataInfoById(id)
	local info = data_union_gongfang_union_gongfang[id]
	ResMgr.showAlert(info, common:getLanguageString("@HintServerWorkshopIDerror") .. id)
	return info
end

function GuildZuofangLayer:updateBuildList(buildList)
	local bOpened = false
	for i, v in ipairs(buildList) do
		self._rootnode["line_" .. i]:setVisible(true)
		local openKey = "line_open_" .. tostring(i)
		local unopenKey = "line_unopen_" .. tostring(i)
		local openMsgKey = "line_open_msg_lbl_" .. tostring(i)
		local unopenMsgKey = "line_unopen_msg_lbl_" .. tostring(i)
		self._rootnode[openMsgKey]:setString(tostring(v.unlock))
		self._rootnode[unopenMsgKey]:setString(tostring(v.lock))
		if v.hasOpen == true then
			bOpened = true
			self._rootnode[openKey]:setVisible(true)
			self._rootnode[unopenKey]:setVisible(false)
		elseif v.hasOpen == false then
			self._rootnode[openKey]:setVisible(false)
			self._rootnode[unopenKey]:setVisible(true)
		end
	end
	if bOpened == true then
		self._rootnode.tag_normal_unopen:setVisible(false)
		self._rootnode.tag_fast_unopen:setVisible(false)
	else
		self._rootnode.tag_normal_unopen:setVisible(true)
		self._rootnode.tag_fast_unopen:setVisible(true)
	end
end

function GuildZuofangLayer:resetChooseBtnState(bVisible, curWorkData)
	local index
	if curWorkData ~= nil then
		for i, v in ipairs(self._buildList) do
			if v.id == curWorkData.id then
				index = i
				break
			end
		end
	end
	for i = 1, #data_union_gongfang_union_gongfang do
		if i ~= index then
			self._rootnode["choose_btn_" .. tostring(i)]:setVisible(bVisible)
		end
	end
end

function GuildZuofangLayer:selectedTab(tag)
	for i = 1, #data_union_gongfang_union_gongfang do
		if tag == i then
			self._rootnode["choose_btn_" .. tostring(i)]:selected()
		else
			self._rootnode["choose_btn_" .. tostring(i)]:unselected()
		end
	end
end

function GuildZuofangLayer:initBuildListView(buildList, curWorkData)
	self:updateBuildList(buildList)
	local function onTabBtn(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:selectedTab(tag)
		self._curWorkData = self._buildList[tag]
		self:updateCurBuildData(self._curWorkData)
	end
	local function initTab()
		for i = 1, #data_union_gongfang_union_gongfang do
			self._rootnode["choose_btn_" .. tostring(i)]:registerScriptTapHandler(onTabBtn)
		end
		if curWorkData.hasOpen == true then
			self:selectedTab(curWorkData.id)
			self:updateCurBuildData(curWorkData)
		end
	end
	initTab()
end

function GuildZuofangLayer:updateCurBuildData(curWorkData)
	local info = self:getDataInfoById(curWorkData.id)
	self._rootnode.normal_end_cost_lbl:setString(tostring(info.end_cost_gold))
	self._rootnode.fast_cost_lbl:setString(tostring(info.fast_build_gold))
	self._rootnode.fast_end_cost_lbl:setString(tostring(info.end_cost_gold))
	self._rootnode.normal_add_lbl:setVisible(true)
	self._rootnode.fast_add_lbl:setVisible(true)
	self._normalAddLbl:setString(curWorkData.normalAddStr)
	self._fastAddLbl:setString(curWorkData.fastAddStr)
	if curWorkData.surplusTime ~= nil and curWorkData.surplusTime > 0 then
		if curWorkData.workType == GUILD_ZF_WORK_TYPE.normal then
			self._rootnode.tag_normal_time:setVisible(true)
			self._rootnode.normal_time_lbl:setString(format_time(curWorkData.surplusTime))
			self._rootnode.normal_build_btn:setVisible(false)
			self._rootnode.tag_normal_end:setVisible(true)
			self._rootnode.tag_normal_time:setVisible(true)
			self._rootnode.tag_fast_build:setVisible(true)
			self._rootnode.fast_build_btn:setEnabled(false)
			self._rootnode.tag_fast_end:setVisible(false)
			self._rootnode.tag_fast_time:setVisible(false)
		elseif curWorkData.workType == GUILD_ZF_WORK_TYPE.fast then
			self._rootnode.tag_fast_time:setVisible(true)
			self._rootnode.fast_time_lbl:setString(format_time(curWorkData.surplusTime))
			self._rootnode.tag_fast_build:setVisible(false)
			self._rootnode.tag_fast_end:setVisible(true)
			self._rootnode.tag_fast_time:setVisible(true)
			self._rootnode.normal_build_btn:setVisible(true)
			self._rootnode.normal_build_btn:setEnabled(false)
			self._rootnode.tag_normal_end:setVisible(false)
			self._rootnode.tag_normal_time:setVisible(false)
		end
	else
		self._rootnode.normal_build_btn:setVisible(true)
		self._rootnode.normal_build_btn:setEnabled(true)
		self._rootnode.tag_normal_end:setVisible(false)
		self._rootnode.tag_normal_time:setVisible(false)
		self._rootnode.tag_fast_build:setVisible(true)
		self._rootnode.fast_build_btn:setEnabled(true)
		self._rootnode.tag_fast_end:setVisible(false)
		self._rootnode.tag_fast_time:setVisible(false)
	end
end

function GuildZuofangLayer:updateFreeAndExtraCount(freeCount, extNum, extGoldNum)
	self._freeCount = freeCount
	self._extraCount = extNum
	self._extraCostGold = extGoldNum
	if self._freeCount ~= nil and self._freeCount > 0 then
		self._rootnode.free_num_lbl:setString(tostring(self._freeCount))
		alignNodesOneByAllRightX({
		self._rootnode.free_num_msg_lbl,
		self._rootnode.free_num_lbl,
		self._rootnode.free_msg_lbl
		}, 2)
		self._rootnode.tag_free:setVisible(true)
		self._rootnode.tag_extra:setVisible(false)
	elseif self._extraCount ~= nil and self._extraCount > 0 then
		self._rootnode.extra_num_lbl:setString(tostring(self._extraCount))
		self._rootnode.extra_cost_gold_lbl:setString(tostring(self._extraCostGold))
		self._rootnode.tag_free:setVisible(false)
		self._rootnode.tag_extra:setVisible(true)
		alignNodesOneByAllRightX({
		self._rootnode.extra_num_msg_lbl,
		self._rootnode.extra_num_lbl,
		self._rootnode.extra_num_msg_lbl_2,
		self._rootnode.extra_cost_gold_lbl,
		self._rootnode.extra_cost_gold_icon
		}, 2)
	else
		self._rootnode.tag_free:setVisible(false)
		self._rootnode.tag_extra:setVisible(false)
	end
end

function GuildZuofangLayer:updateGoldNum(goldNum)
	self._curGold = goldNum
	game.player:updateMainMenu({
	gold = self._curGold
	})
	self._rootnode.cur_gold_msg_lbl:setString(common:getLanguageString("@Own"))
	self._rootnode.cur_gold_lbl:setString(tostring(self._curGold))
	alignNodesOneByAll({
	self._rootnode.cur_gold_msg_lbl,
	self._rootnode.cur_gold_lbl,
	self._rootnode.cur_gold_icon
	}, 2)
end

function GuildZuofangLayer:updateLevel(level, currentUnionMoney)
	local guildMgr = game.player:getGuildMgr()
	self._level = level
	guildMgr:getGuildInfo().m_workshoplevel = self._level
	self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level)
	self._currentUnionMoney = currentUnionMoney
	self:createShadowLbl("LV." .. tostring(self._level), cc.c3b(255, 222, 0), "cur_level_lbl")--, display.CENTER)
	self._rootnode.cur_coin_msg_lbl:setString(common:getLanguageString("@GuildGold"))
	self._rootnode.cur_coin_lbl:setString(tostring(self._currentUnionMoney))
	alignNodesOneByOne(self._rootnode.cur_coin_msg_lbl, self._rootnode.cur_coin_lbl, 2)
	self:updateNeedCoinLbl(self._needCoin)
end

function GuildZuofangLayer:updateNeedCoinLbl(needCoin)
	local str
	if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then
		str = common:getLanguageString("@GuildUpgradeMax")
	else
		str = tostring(needCoin)
	end
	self._rootnode.cost_coin_msg_lbl:setString(common:getLanguageString("@GuildGoldForUpgrade"))
	self._rootnode.cost_coin_lbl:setString(str)
	alignNodesOneByOne(self._rootnode.cost_coin_msg_lbl, self._rootnode.cost_coin_lbl, 2)
end

function GuildZuofangLayer:createShadowLbl(text, color, nameKey, align, size)
	local lbl = ui.newTTFLabelWithShadow({
	text = text,
	size = size or 20,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = color,
	shadowColor = FONT_COLOR.BLACK,
	})
	ResMgr.replaceKeyLableEx(lbl, self._rootnode, nameKey, 0, 0)
	lbl:align(align or display.LEFT_CENTER)
	return lbl
end

function GuildZuofangLayer:createAllLbl()
	local guildMgr = game.player:getGuildMgr()
	local yColor = cc.c3b(255, 222, 0)
	self._normalAddLbl = self:createShadowLbl(common:getLanguageString("@HintUndetermined"), cc.c3b(0, 219, 52), "normal_add_lbl", display.CENTER)
	self._fastAddLbl = self:createShadowLbl(common:getLanguageString("@HintUndetermined"), cc.c3b(0, 219, 52), "fast_add_lbl", display.CENTER)
end

function GuildZuofangLayer:onExit()
	if self._checkSchedule ~= nil then
		self._scheduler.unscheduleGlobal(self._checkSchedule)
	end
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return GuildZuofangLayer
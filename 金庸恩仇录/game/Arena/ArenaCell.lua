local MAX_ZORDER = 10003

local ArenaCell = class("ArenaCell", function()
	return CCTableViewCell:new()
end)

function ArenaCell:getContentSize()
	if self.cntSize == nil then
		local proxy = CCBProxy:create()
		local rootNode = {}
		local node = CCBuilderReaderLoad("arena/arena_item.ccbi", proxy, rootNode)
		self.cntSize = rootNode.itemBg:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self.cntSize
end

function ArenaCell:timeSchedule(param)
	self.restTime = param.time
	local timeLabel = param.label
	local callBack = param.callBack
	timeLabel:setString(format_time(self.restTime))
	local function update(dt)
		if timeLabel == nil or timeLabel:getParent() == nil or self.restTime <= 0 then
			self.scheduler.unscheduleGlobal(self.timeData)
			if self.restTime <= 0 then
				callBack()
			end
		else
			self.restTime = self.restTime - 1
			timeLabel:setString(format_time(self.restTime))
		end
	end
	self.scheduler = require("framework.scheduler")
	if self.timeData ~= nil then
		self.scheduler.unscheduleGlobal(self.timeData)
	end
	self.timeData = self.scheduler.scheduleGlobal(update, 1, false)
end

function ArenaCell:onExit()
	self:unregNotice()
end

function ArenaCell:regNotice()
	RegNotice(self, function(timeStr, ss)
		local curTime = tonumber(ss)
		self._rootnode.rest_time:setString(format_time(curTime))
	end,
	NoticeKey.ArenaRestTime)
	
	RegNotice(self, function()
		if self.timeType == 1 then
			self._rootnode.time_rest_name:setString(common:getLanguageString("@Countdown"))
		else
			self._rootnode.time_rest_name:setString(common:getLanguageString("@GiveOut"))
		end
	end,
	NoticeKey.SwitchArenaTimeType)
end

function ArenaCell:unregNotice()
	UnRegNotice(self, NoticeKey.ArenaRestTime)
	UnRegNotice(self, NoticeKey.SwitchArenaTimeType)
end

function ArenaCell:refresh(id, restTime, timeType)
	local cellData = self.data[id]
	self.timeType = timeType
	self.restTime = restTime
	self.acc = cellData.acc
	self.cards = cellData.card
	self.getPopual = cellData.getPopual
	self.getSilver = cellData.getSilver
	self.level = cellData.level
	self.name = cellData.name
	self.rank = cellData.rank
	self.isVip = cellData.vip
	self.attrack = cellData.attrack
	self.faction = cellData.faction
	if self.faction == "" then
		self._rootnode.gang_name:setVisible(false)
	else
		self._rootnode.gang_name:setVisible(true)
		self._rootnode.gang_name:setString("【" .. self.faction .. "】")
	end
	if self.timeType == 1 then
		self._rootnode.time_rest_name:setString(common:getLanguageString("@Countdown"))
	else
		self._rootnode.time_rest_name:setString(common:getLanguageString("@GiveOut"))
	end
	local playerBgName = "#arena_name_bg_4.png"
	local bgname = "#arena_itemBg_4.png"
	if game.player:isSelf(cellData.roleId) then
		playerBgName = "#arena_name_bg_5.png"
		bgname = "#arena_itemBg_5.png"
		self._rootnode.challenge_btn:setVisible(false)
		self._rootnode.time_rest_node:setVisible(true)
		self:regNotice()
		function self.btnFunc()
			dump(common:getLanguageString("@Part"))
		end
	else
		self._rootnode.challenge_btn:setVisible(true)
		self._rootnode.time_rest_node:setVisible(false)
		function self.btnFunc()
			dump("replace scene" .. self.acc)
			if game.player.m_energy < 2 then
				self.notEnoughFunc()
			else
				ResMgr.oppName = self.name
				self:sendCheckRankList()
			end
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
	self._rootnode.lv_num:setString("LV." .. tostring(self.level))
	self._rootnode.player_name:setString(self.name)
	self._rootnode.reward_money:setString(tostring(self.getSilver))
	self._rootnode.shengwang_num:setString("x" .. tostring(self.getPopual))
	self._rootnode.rank_num:setString(common:getLanguageString("@Ranking", tostring(self.rank)))
	self._rootnode.fight_num:setString(tostring(self.attrack))
	alignNodesOneByAll({
	self._rootnode.propLabel_1,
	self._rootnode.sellBtns,
	self._rootnode.reward_money,
	self._rootnode.shengwang,
	self._rootnode.propLabel_2,
	self._rootnode.shengwang_num
	}, 3)
	alignNodesOneByOne(self._rootnode.sellBtns, self._rootnode.reward_money)
	for i = 1, 4 do
		if i > #self.cards then
			self._rootnode["icon_" .. i]:setVisible(false)
		else
			self._rootnode["icon_" .. i]:setVisible(true)
			local cls = self.cards[i].cls
			local resId = self.cards[i].resId
			ResMgr.refreshIcon({
			id = resId,
			itemBg = self._rootnode["icon_" .. i],
			resType = ResMgr.HERO,
			cls = cls
			})
		end
	end
end

function ArenaCell:sendCheckRankList()
	RequestHelper.sendCheckRankList({
	acc2 = self.acc,
	rank = self.rank,
	callback = function(data)
		dump("check data")
		dump(data)
		local change = data["1"]
		if change == 1 then
			game.player.m_energy = game.player.m_energy - 2
			self:sendBattleReq()
		elseif change == 2 then
			local changeMsgBox = require("game.Arena.ArenaChangeMsgBox").new({
			battleFunc = function()
				self:sendBattleReq()
			end,
			resetFunc = function()
				self.resetFunc()
			end
			})
			display.getRunningScene():addChild(changeMsgBox, MAX_ZORDER)
		elseif change == 3 then
			do
				local isBagFull = true
				local bagObj = data["2"]
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
					else
						isBagFull = false
					end
				end
				if isBagFull then
					game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
					bagObj = bagObj,
					callback = function(data)
						extendBag(data)
					end
					}), MAX_ZORDER)
				end
			end
		end
	end
	})
end

function ArenaCell:sendBattleReq()
	RequestHelper.ArenaBattle({
	rank = self.rank,
	callback = function(data)
		local isSelf = data["6"]
		dump("==================================")
		dump("==================================")
		dump("==================================")
		dump("==================================")
		self.battleData = data
		dump(self.battleData)
		dump("==================================")
		dump("==================================")
		dump("==================================")
		dump("==================================")
		if isSelf == 1 then
			GameStateManager:ChangeState(GAME_STATE.STATE_ARENA_BATTLE, self.battleData)
		elseif isSelf == 2 then
			show_tip_label(common:getLanguageString("@RankingChange"))
			self.resetFunc()
		elseif isSelf == 3 then
			show_tip_label(common:getLanguageString("@Grant"))
		end
	end
	})
end

function ArenaCell:create(param)
	local _id = param.id
	local _viewSize = param.viewSize
	self.data = param.listData
	self.restTime = param.restTime
	self.timeType = param.timeType
	self.notEnoughFunc = param.notEnoughFunc
	self.resetFunc = param.resetFunc
	dump(self.data)
	self:setNodeEventEnabled(true)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("arena/arena_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, 0)
	self:addChild(node)
	function self.btnFunc()
		dump("nonono")
	end
	
	--挑战
	self._rootnode.challenge_btn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self.btnFunc()
	end,
	CCControlEventTouchUpInside)
	
	self:refresh(_id + 1, self.restTime, self.timeType)
	return self
end

function ArenaCell:beTouched()
end

function ArenaCell:runEnterAnim()
end

return ArenaCell
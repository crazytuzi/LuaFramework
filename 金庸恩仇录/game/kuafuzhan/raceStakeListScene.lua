local raceStakeListScene = class("raceStakeListScene", function()
	return display.newScene("raceStakeListScene")
end)

local enumViewType = {wulinzhizun = 1, mingdongjianghu = 2}
local upLayerTag = 192

local kuafuMsg = {
getRaceStakeList = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossStakeList",
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

setRaceStake = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossStake",
	targetAcc = param.targetAcc,
	targetIdx = param.targetIdx,
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

--比赛对战回放记录
getBattleInfoHistory = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossBattleInfoHistory",
	sourceAcc = param.sourceAcc,
	sourceIdx = param.sourceIdx,
	targetAcc = param.targetAcc,
	targetIdx = param.targetIdx,
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

--对战历史记录查看押注
getStakeHistory = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossStakeHistory"
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

getBattleInfoShow = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossBattleInfoShow",
	id = param.id,
	round = param.round,
	index = param.index
	}
	RequestHelper.request(msg, _callback, param.errback)
end

}
local lineTbl = {
8,
4,
2,
1
}
local stateTitle = {
[4] = common:getLanguageString("@raceType1", 16, 8) .. common:getLanguageString("@Bet"),
[5] = common:getLanguageString("@raceType1", 16, 8),
[6] = common:getLanguageString("@raceType1", 8, 4) .. common:getLanguageString("@Bet"),
[7] = common:getLanguageString("@raceType1", 8, 4),
[8] = common:getLanguageString("@raceType2") .. common:getLanguageString("@Bet"),
[9] = common:getLanguageString("@raceType2"),
[10] = common:getLanguageString("@raceType3") .. common:getLanguageString("@Bet"),
[11] = common:getLanguageString("@raceType3")
}

function raceStakeListScene:ctor(param)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local contentSize = cc.size(display.width, display.height)
	self:setContentSize(contentSize)
	local bgNode = CCBuilderReaderLoad("kuafu/kuafu_competition_layer.ccbi", self._proxy, self._rootnode, self, contentSize)
	self:addChild(bgNode)
	
	local phaseIndex = KuafuModel.getShowPhaseLanginfo(KuafuModel.getKuafuPhase())
	
	self._rootnode.kuafu_title:setString(common:getLanguageString("@KuafuTitle", phaseIndex))
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		pop_scene()
	end,
	CCControlEventTouchUpInside)
	
	self.viewType = 0
	--武林至尊
	self._rootnode.MasterHero_btn:addHandleOfControlEvent(function(sender, eventName)
		self:changeViewType(enumViewType.wulinzhizun)
	end,
	CCControlEventTouchUpInside)
	
	--江湖新秀
	self._rootnode.NameDynamic_btn:addHandleOfControlEvent(function(sender, eventName)
		self:changeViewType(enumViewType.mingdongjianghu)
	end,
	CCControlEventTouchUpInside)
	
	--我的比赛
	self._rootnode.mycomp_btn:addHandleOfControlEvent(function(sender, eventName)
		self:myCompBtnFunc()
	end,
	CCControlEventTouchUpInside)
	
	--我的押注
	self._rootnode.mybet_btn:addHandleOfControlEvent(function(sender, eventName)
		self:myBetBtnFunc()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.NameDynamic_btn:setTouchEnabled(false)
	self._rootnode.NameDynamic_btn:setVisible(false)
	
	self._rootnode.mycomp_btn:setVisible(false)
	self._rootnode.mycomp_btn:setTouchEnabled(false)
	self._rootnode.mybet_btn:setVisible(false)
	self._rootnode.mybet_btn:setTouchEnabled(false)
	self._rootnode.MasterHero_btn:setPositionX(display.cx)
	
	--self.stakeData = {}
	self:changeViewType(enumViewType.wulinzhizun)
	for key, num in pairs(lineTbl) do
		for index = 1, num do
			--查看比赛记录or押注按键
			self._rootnode["race_btn_" .. key .. "_" .. index]:addHandleOfControlEvent(function(sender, eventName)
				--第几轮 第几组
				self:raceBtnFunc(key, index)
			end,
			CCControlEventTouchUpInside)
		end
	end
	
	for i = 1, 16 do
		local imageButton = require("game.Biwu.ImageButton"):new()
		imageButton:addTouchListener(self._rootnode["race_player_bg_" .. i], function(sender, eventType)
			if eventType == EventType.ended then
				--查看玩家整容
				self:racePlayerBgFunc(i)
			end
		end)
	end
	
	--[[
	for index = 1, 16 do
		setTTFLabelOutline({
		label = self._rootnode["player_servers_" .. index]
		})
		setTTFLabelOutline({
		label = self._rootnode["player_name_" .. index]
		})
		setTTFLabelOutline({
		label = self._rootnode["player_battle_" .. index]
		})
	end
	
	setTTFLabelOutline({
	label = self._rootnode.player_name
	})
	setTTFLabelOutline({
	label = self._rootnode.player_server
	})
	setTTFLabelOutline({
	label = self._rootnode.kuafu_state_title
	})
	]]
	
	self.timeNode = display.newNode()
	self:addChild(self.timeNode)
	self.kuafuState = KuafuModel.getKuafuState()
end

function raceStakeListScene:racePlayerBgFunc(index)
	local stakeData = self.stakeData --self.stakeData[self.viewType]
	if not stakeData then
		return
	end
	local user = stakeData.all[index]
	if not user then
		return
	end
	local tbl = {}
	tbl.name = user.roleName
	tbl.combat = user.battlePower
	tbl.cards = user.resTeam
	local formLayer = require("game.scenes.showEnemyFormLayer").new({info = tbl})
	self:addChild(formLayer, upLayerTag)
	
end

function raceStakeListScene:getUserInfoByAcc(account, serverId, viewType)
	--[[
	if not viewType or not {viewType} then
		local tbl = {1, 2}
	end
	for key, type in pairs(tbl) do
		for _, user in pairs(self.stakeData[type].all) do
			if user.account == account and user.serverId == serverId then
				return user
			end
		end
	end
	]]
	
	for _, user in pairs(self.stakeData.all) do
		if user.account == account and user.serverId == serverId then
			return user
		end
	end
end

function raceStakeListScene:parseBattleInfo(data, user1, user2)
	local battleInfo = {}
	local viewType
	if type(user1) == "number" then
		viewType = user1
	end
	local j = require("framework.json")
	for key, value in pairs(data) do
		battleInfo[key] = {}
		battleInfo[key].win = value.win
		battleInfo[key].id = value.id
		battleInfo[key].action = value.action
		battleInfo[key].set = value.set
		battleInfo[key].get = value.get
		battleInfo[key].select = value.select
		local userInfo1 = user1
		local userInfo2 = user2
		if value.popNum ~= 16 then
			if user1 and user2 then
			else
				userInfo1 = self:getUserInfoByAcc(value.sourceAccount, value.sourceServerId, viewType)
				userInfo2 = self:getUserInfoByAcc(value.targetAccount, value.targetServerId, viewType)
			end
		else
			if value.actionType == 1 then
				value.popNum = 32
			end
			userInfo1 = {}
			userInfo1.name = value.sourceName
			userInfo1.serverName = value.sourceServerName
			userInfo1.res = {
			j.decode(value.sourceRes)
			}
			userInfo1.viewType = 0
			userInfo2 = {}
			userInfo2.name = value.targetName
			userInfo2.serverName = value.targetServerName
			userInfo2.res = {
			j.decode(value.targetRes)
			}
			userInfo1.viewType = 0
		end
		battleInfo[key].popNum = value.popNum
		battleInfo[key].userInfo = {userInfo1, userInfo2}
	end
	return battleInfo
end

function raceStakeListScene:raceBtnFunc(turn, index)
	local stakeData = self.stakeData --self.stakeData[self.viewType]
	if not stakeData then
		return
	end
	local user1 = stakeData.all[stakeData.winData[turn][index * 2 - 1]]
	local user2 = stakeData.all[stakeData.winData[turn][index * 2]]
	if not user1 or not user2 then
		return
	end
	--[[
	if user1.count == user2.count then
		dump("yazhu")
		if stakeData.stakeKey then
			local text = common:getLanguageString("@BetTip2", stakeData.all[stakeData.stakeKey].name)
			show_tip_label(text)
		elseif self.kuafuState == enumKuafuState.knockout + (turn * 2 - 1) then
			self:raceStakeStartBet(user1, user2)
		else
			show_tip_label(common:getLanguageString("@BetTip4"))
		end
	else
		dump("chakan")
		kuafuMsg.getBattleInfoHistory({
		type = self.viewType - 1,
		sourceAcc = user1.account,
		sourceIdx = user1.serverId,
		targetAcc = user2.account,
		targetIdx = user2.serverId,
		callback = function(data)
			dump(data)
			local _stakeHistoryList = self:parseBattleInfo(data, user1, user2)
			local battleType
			local times = 0
			for i = #_stakeHistoryList, 1, -1 do
				local battleInfo = _stakeHistoryList[i]
				if battleInfo.popNum ~= battleType then
					times = 0
					battleType = battleInfo.popNum
				end
				times = times + 1
				battleInfo.times = times
			end
			local battleInfoLayer = require("game.kuafuzhan.raceBattleInfoHistory").new({
			battleInfoList = _stakeHistoryList,
			title = common:getLanguageString("@RaceReplay")
			})
			self:addChild(battleInfoLayer, upLayerTag)
		end
		})
	end
	]]
	
    dump("duang! duang! duang!")
	local users = {}
	users[1] = user1
	users[2] = user2
	kuafuMsg.getBattleInfoShow({
	round = turn,
	index = index,
	id = 0,
	callback = function(data)
		local battleData = {}
		battleData["1"] = {}
		battleData["1"][1] = 1
		battleData["2"] = {}
		battleData["2"][1] = data
		for i = 1, 2 do
			local heroData = battleData["2"][1].d[1]["f" .. i]
			for _, hero in pairs(heroData) do
				if hero.id == 1 or hero.id == 2 then
					hero.name = users[i].roleName
					break
				end
			end
		end
		local scene = require("game.kuafuzhan.xuanbaBattleScene").new({
		beRace = true,
		data = battleData,
		heroName = user1.roleName,
		heroCombat = user1.battlePower,
		enemyName = user2.roleName,
		enemyCombat = user2.battlePower
		})
		push_scene(scene)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	})
end

function raceStakeListScene:myCompBtnFunc()
	kuafuMsg.getBattleInfoHistory({
	type = -1,
	sourceAcc = game.player:getAccount(),
	sourceIdx = game.player:getServerID(),
	callback = function(data)
		dump(data)
		local _stakeHistoryList = self:parseBattleInfo(data.rtnObj, self.myCompInfo and self.myCompInfo.viewType)
		if #_stakeHistoryList == 0 and not self.myCompInfo then
			show_tip_label(common:getLanguageString("@kuafuNotHaveRace"))
			return
		end
		local battleType
		local times = 0
		for i = #_stakeHistoryList, 1, -1 do
			local battleInfo = _stakeHistoryList[i]
			if battleInfo.popNum ~= battleType then
				times = 0
				battleType = battleInfo.popNum
			end
			times = times + 1
			battleInfo.times = times
		end
		local battleInfoLayer = require("game.kuafuzhan.raceBattleInfoHistory").new({
		battleInfoList = _stakeHistoryList,
		title = common:getLanguageString("@MyComp")
		})
		self:addChild(battleInfoLayer, upLayerTag)
	end
	})
end

function raceStakeListScene:myBetBtnFunc()
	kuafuMsg.getStakeHistory({
	callback = function(data)
		dump(data)
		local _stakeHistoryList = self:parseBattleInfo(data)
		if #_stakeHistoryList == 0 then
			show_tip_label(common:getLanguageString("@BetTip3"))
			return
		end
		local stakeHistoryLayer = require("game.kuafuzhan.raceStakeHistory").new({
		stakeHistoryList = _stakeHistoryList,
		title = common:getLanguageString("@MyBet")
		})
		self:addChild(stakeHistoryLayer, upLayerTag)
	end
	})
end

function raceStakeListScene:updateStateList()
	kuafuMsg.getRaceStakeList({
	callback = function(data)
		--data.all --所有参赛玩家
		--data.rem --所有对战结果
		--dump(data)
		local stakeData = {}
		stakeData.all = data.all
		local j = require("framework.json")
		local winData = {}
		winData[1] = {}
		for index, user in pairs(stakeData.all) do
			user.count = 0
			winData[1][index] = index
			user.viewType = 1
		end
		
		for key, rankList in pairs(data.rem) do
			winData[key + 1] = {}
			for i, uid in pairs(rankList) do --每一轮的获胜者
				for index, user in pairs(stakeData.all) do
					if uid == user.serverId .. "#" .. user.account then
						user.count = user.count + 1
						winData[key + 1][i] = index  --获胜玩家
						break
					end
				end
			end
		end
		
		if #winData[#winData] == 1 and #winData < 5 then
			winData[5] = {}
			winData[5][1] = winData[#winData][1]
		end
		
		stakeData.winData = winData
		if data.stakeKey then --押注?
			for index, user in pairs(stakeData.all) do
				if data.stakeKey == user.serverId .. "#" .. user.account then
					stakeData.stakeKey = index
					break
				end
			end
		end
		self.stakeData = stakeData
		
		local myAcc = game.player:getAccount()
		local myServerId = game.player:getServerID()
		self.myCompInfo = self:getUserInfoByAcc(myAcc, myServerId)
		self:swithViewType()
	end
	})
end

function raceStakeListScene:swithViewType()
	self._rootnode.MasterHero_btn:setEnabled(self.viewType ~= enumViewType.wulinzhizun)
	self._rootnode.NameDynamic_btn:setEnabled(self.viewType == enumViewType.wulinzhizun)
	self._rootnode.base_node:setVisible(true)
	self:setRaceStakeData(self.stakeData)
	--self:setRaceStakeData(self.stakeData[self.viewType])
end

function raceStakeListScene:changeViewType(viewType)
	--[[
	if self.viewType == viewType then
		return
	end
	self.viewType = viewType
	self._rootnode.base_node:setVisible(false)
	if self.stakeData[viewType] then
		self:swithViewType()
	else
		self:updateStateList()
	end
	]]
	
	
	if self.stakeData then
		return
	end
	self.viewType = viewType
	self:updateStateList()
end

local spriteNameTbl = {
{
"kuafu_competition_ui_03.png",
"kuafu_competition_ui_04.png"
},
{
"kuafu_competition_ui_03.png",
"kuafu_competition_ui_04.png"
},
{
"kuafu_competition_ui_03.png",
"kuafu_competition_ui_04.png"
},
{
"kuafu_competition_ui_06.png",
"kuafu_competition_ui_05.png"
}
}
function raceStakeListScene:setRaceStakeData(data)
	local maxCount = 0
	for i = 1, 16 do
		if i <= #data.all then
			local hero = data.all[i]
			self._rootnode["player_servers_" .. i]:setString(tostring(hero.serverName))
			self._rootnode["player_name_" .. i]:setString(hero.roleName)
			self._rootnode["player_battle_" .. i]:setString(hero.battlePower)
			if maxCount < hero.count then
				maxCount = hero.count
			end
		else
			self._rootnode["player_servers_" .. i]:setString("")
			self._rootnode["player_name_" .. i]:setString("")
			self._rootnode["player_battle_" .. i]:setString("")
		end
	end
	
	--[[
	for index, hero in pairs(data.all) do
		self._rootnode["player_servers_" .. index]:setString(tostring(hero.serverName))
		self._rootnode["player_name_" .. index]:setString(hero.name)
		self._rootnode["player_battle_" .. index]:setString(hero.point)
		if maxCount < hero.count then
			maxCount = hero.count
		end
	end
	]]
	local bgSize = self._rootnode.race_player_bg_1:getContentSize()
	bgPngTbl = {
	"ui/ui_9Sprite/ui_sh_bg_22.png",
	"ui/ui_9Sprite/ui_sh_bg_30.png"
	}
	colorTbl = {
	{
	cc.c3b(166, 249, 0),
	cc.c3b(255, 211, 0),
	cc.c3b(255, 38, 0)
	},
	{
	cc.c3b(127, 127, 127),
	cc.c3b(127, 127, 127),
	cc.c3b(127, 127, 127)
	}
	}
	for index, hero in pairs(data.all) do
		local bgNode = self._rootnode["race_player_bg_" .. index]
		local keyIndex = maxCount > hero.count and 2 or 1
		bgNode:setSpriteFrame(display.newSprite(bgPngTbl[keyIndex]):getDisplayFrame())
		bgNode:setContentSize(bgSize)
		self._rootnode["player_servers_" .. index]:setColor(colorTbl[keyIndex][1])
		self._rootnode["player_name_" .. index]:setColor(colorTbl[keyIndex][2])
		self._rootnode["player_battle_" .. index]:setColor(colorTbl[keyIndex][3])
	end
	
	local setStakeBtnState = function(btn)
		btn:setBackgroundSpriteForState(display.newScale9Sprite("#kuafu_competition_ui_01.png"), CCControlStateNormal)
		btn:setBackgroundSpriteForState(display.newScale9Sprite("#kuafu_competition_ui_01.png"), CCControlStateHighlighted)
		btn:setBackgroundSpriteForState(display.newScale9Sprite("#kuafu_competition_ui_07.png"), CCControlStateDisabled)
	end
	
	for lineIndex, num in pairs(lineTbl) do
		for i = 1, num do
			local lineNode1 = self._rootnode["race_line" .. lineIndex .. "_" .. i * 2 - 1]
			local lineNode2 = self._rootnode["race_line" .. lineIndex .. "_" .. i * 2]
			local race_btn = self._rootnode["race_btn_" .. lineIndex .. "_" .. i]
			local png1Path, png2Path
			if data.winData[lineIndex] and #data.winData[lineIndex] >= (i * 2 - 1) then
				local user1 = data.all[data.winData[lineIndex][i * 2 - 1]]
				local user2 = {}
				local idx2 = data.winData[lineIndex][i * 2]
				if idx2  == nil then
					user2.count = -1
				else
					user2 = data.all[idx2]
				end
				png1Path = user1.count >= user2.count and spriteNameTbl[lineIndex][1] or spriteNameTbl[lineIndex][2]
				png2Path = user2.count >= user1.count and spriteNameTbl[lineIndex][1] or spriteNameTbl[lineIndex][2]
				if user1.count == user2.count then
					setStakeBtnState(race_btn)
					if self.kuafuState == enumKuafuState.knockout + (lineIndex * 2 - 1) then
						race_btn:setEnabled(true)
					else
						race_btn:setEnabled(false)
					end
				else
					resetctrbtnimage(race_btn, "#kuafu_competition_ui_02.png")
					race_btn:setEnabled(true)
				end
			else
				png1Path = spriteNameTbl[lineIndex][2]
				png2Path = spriteNameTbl[lineIndex][2]
				setStakeBtnState(race_btn)
				race_btn:setEnabled(false)
			end
			if lineIndex == 1 then
				lineNode1:setDisplayFrame(display.newSprite("#" .. png1Path):getDisplayFrame())
				lineNode2:setDisplayFrame(display.newSprite("#" .. png2Path):getDisplayFrame())
			else
				local size = lineNode1:getContentSize()
				lineNode1:setSpriteFrame(display.newSprite("#" .. png1Path):getDisplayFrame())
				lineNode1:setContentSize(size)
				size = lineNode2:getContentSize()
				lineNode2:setSpriteFrame(display.newSprite("#" .. png2Path):getDisplayFrame())
				lineNode2:setContentSize(size)
			end
		end
	end
	
	if data.winData[5] then
		self._rootnode.winner_node:setVisible(true)
		self._rootnode.kuafu_state_title:setVisible(false)
		local winnerInfo = data.all[data.winData[5][1]]
		self._rootnode.player_name:setString(winnerInfo.name)
		self._rootnode.player_server:setString("[" .. winnerInfo.serverName .. "]")
		ResMgr.refreshIcon({
		id = winnerInfo.resTeam[1].resId,
		itemBg = self._rootnode.player_icon,
		resType = ResMgr.HERO,
		cls = winnerInfo.resTeam[1].cls
		})
	else
		self._rootnode.winner_node:setVisible(false)
		self._rootnode.kuafu_state_title:setVisible(true)
		self._rootnode.kuafu_state_title:setString(stateTitle[self.kuafuState] or "")
	end
end

function raceStakeListScene:raceStakeStartBet(user1, user2)
	local layer = require("game.kuafuzhan.raceBetLayer").new({
	leftPlayer = user1,
	rightPlayer = user2,
	betType = self.viewType - 1,
	listener = function(side)
		local user = side == 1 and user1 or user2
		kuafuMsg.setRaceStake({
		type = self.viewType - 1,
		targetAcc = user.account,
		targetIdx = user.serverId,
		callback = function(data)
			local text = common:getLanguageString("@Bet")
			if data.rtnObj then
				local stakeData = self.stakeData[self.viewType]
				for index, userInfo in pairs(stakeData.all) do
					if userInfo.serverId == user.serverId and userInfo.account == user.account then
						stakeData.stakeKey = index
						break
					end
				end
				text = text .. common:getLanguageString("@SuccessLabel")
			else
				text = text .. common:getLanguageString("@FailedLabel")
			end
			show_tip_label(text)
		end
		})
	end
	})
	self:addChild(layer, upLayerTag)
end

function raceStakeListScene:onEnter()
	local function update(dt)
		local newState = KuafuModel.getKuafuState()
		if newState <= enumKuafuState.knockout then
			self.timeNode:stopAllActions()
			self:performWithDelay(function()
				pop_scene()
			end,
			1)
			show_tip_label(common:getLanguageString("@kuafuStateChangeTip"), 1)
		elseif self.kuafuState ~= newState then
			self:updateStateList()
			self.kuafuState = newState
		end
	end
	self.timeNode:schedule(update, 1)
end

function raceStakeListScene:onExit()
	self.timeNode:stopAllActions()
end

return raceStakeListScene
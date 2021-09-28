-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arena_list = i3k_class("wnd_arena_list", ui.wnd_base)

local f_typeTable = {
	{title = "单人竞技场", needLvl = i3k_db_arena.arenaCfg.needLvl, iconID = 3497},
	{title = "正邪道场", needLvl = i3k_db_taoist.needLvl, iconID = 3498},
	{title = "会武场", needLvl = i3k_db_tournament_base.needLvl, iconID = 3499},
	{title = "正邪势力战", needLvl = i3k_db_forcewar[1].needLvl, iconID = 3500},
	{title = "伏魔洞试炼", needLvl = i3k_db_demonhole_base.needLvl, iconID = 3501, showLvl = i3k_db_demonhole_base.showLvl, isHide = true},
	{title = i3k_get_string(17759), needLvl = i3k_db_maze_battle.openLvl, iconID = 8316, showLvl = i3k_db_maze_battle.showLvl},
	--{title = "嘉年华对抗赛", needLvl = i3k_db_forcewar[g_CHANNEL_COMBAT].needLvl, iconID = 3998},
	{title = "决战荒漠", needLvl = i3k_db_desert_battle_base.openLvl, iconID = 7953, showLvl = i3k_db_desert_battle_base.showLvl},
	{title = "帮派战", needLvl = i3k_db_faction_fightgroup.common.joinLevel, iconID = 4049},
	{title = i3k_get_string(1217), needLvl = i3k_db_fightTeam_base.budo.showLvl, iconID = 5086},
	{title = i3k_get_string(1313), needLvl = i3k_db_crossRealmPVE_cfg.levelLimit, iconID = 3494},
	{title = "城战", needLvl = i3k_db_defenceWar_cfg.playerLvl, iconID = 7350},
}

 --单人 组队报名
local TOURNAMENT_JOIN = {3591, 3590}
local TOURNAMENT_CANCEL = {3593, 3592}

local f_pagePath = {
	"ui/widgets/jingjichang",
	"ui/widgets/zhengxiedaochang",
	"ui/widgets/huiwu",
	"ui/widgets/shilizhan",
	"ui/widgets/fumodong",
	"ui/widgets/tianmomigong",
	--"ui/widgets/qudaosai",
	"ui/widgets/juezhanhuangmo",
	"ui/widgets/bangpaizhan",
	"ui/widgets/wudaohui",
	"ui/widgets/shendiyoumingjing",
	"ui/widgets/chengzhan",
}

local WUDAOHUIDWT = "ui/widgets/wudaohuidw"

local f_redWordColor	= "FFFF0000"
local f_greenWordColor	= "FF029133"



-- 左侧btn
local NORMAL_ICON1	= 3490
local NORMAL_ICON2	= 3491
local PRESSED_ICON	= 3492

--层数图片1~9/0
local COUNT_ICON = {3643, 3644, 3645, 3646, 3647, 3648, 3649, 3650, 3651, 3642}

--城战状态显示
local DEFENCE_WAR_STATE =
{
	[g_DEFENCE_WAR_STATE_NONE] 		= {state = "尚未开启"},
	[g_DEFENCE_WAR_STATE_SIGN_WAIT] = {state = "等待占城报名中", descFormat = "将在%s开始报名（截止时间%s）", btnImgID = 7045},
	[g_DEFENCE_WAR_STATE_SIGN_UP]	= {state = "占城报名中", descFormat = "已经开始报名，截止时间%s", img = "stateImg1", btnImgID = 7045, funcName = "openDefenceWarSign"},
	[g_DEFENCE_WAR_STATE_PVE_WAIT] 	= {state = "竞速等待中", descFormat = "报名已截止，竞速占城将于%s开启"},
	[g_DEFENCE_WAR_STATE_PVE] 		= {state = "竞速占城中", descFormat = "活动时间%s~%s", img = "stateImg2", btnImgID = 7044, funcName = "enterDefenceWar"},
	[g_DEFENCE_WAR_STATE_NO_FIGHT] 	= {state = "休战期", descFormat = "将在%s开始竞标夺城"},
	[g_DEFENCE_WAR_STATE_BID] 		= {state = "争锋夺城竞标中", descFormat = "竞标时间%s~%s", img = "stateImg3", btnImgID = 7042, funcName = "openDefenceWarBid"},
	[g_DEFENCE_WAR_STATE_BID_SHOW] 	= {state = "竞标公示中", descFormat = "夺城将在%s开始"},
	[g_DEFENCE_WAR_STATE_PVP]		= {state = "争锋夺城中", descFormat = "活动时间%s~%s", img = "stateImg4", btnImgID = 7044, funcName = "enterDefenceWar"},
	[g_DEFENCE_WAR_STATE_PEACE] 	= {state = "和平期", descFormat = "城池归属将在%s重置"},
}

function wnd_arena_list:ctor()
	self._arenaCanChallenge = true
	self._status = g_FACTION_FIGHT_PUSH_NO_MATCH -- 默认未报名
	self._timeCounter = 0
	self._btnState = false
	self._timeCount = 0
	self._fightTeamIsWin = false
	self._isShowSign = true
	self._globalPveTimeInfo = {}
	self._defenceWarInfo = {}
	self._redList = {}
end

function wnd_arena_list:configure()
	self._state = g_ARENA_STATE
	self._layout.vars.close_btn:onClick(self, function ()
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamGameReport)
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamAward)
		self:onCloseUI()
	end)
	self._rootWidget = self._layout.vars.rootWidget
end

function wnd_arena_list:onShow()
	local scroll = self._layout.vars.scroll
	local  roleLvl = g_i3k_game_context:GetLevel()
	for i=1,#f_typeTable do
		if not f_typeTable[i].isHide then
			local node = require("ui/widgets/hdlbt")()
			node.vars.btn:setTag(i)
			node.vars.btn:onClick(self, self.changeState)
			node.vars.name:setText(f_typeTable[i].title)
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(f_typeTable[i].iconID))
		table.insert(self._redList, node.vars.red)
		if i == g_FORCE_WAR_STATE then
			self:setForceWarLotteryRed()
		else
			node.vars.red:setVisible(false)
		end
			node.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON2))
			if i == self._state then
				node.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(PRESSED_ICON))
			end
			node.vars.showlock:setVisible(roleLvl < f_typeTable[i].needLvl)
			if f_typeTable[i].showLvl and roleLvl < f_typeTable[i].showLvl then
			else
			scroll:addItem(node)
			end
		end
	end

	--self:updateMoney(g_i3k_game_context:GetVit(), g_i3k_game_context:GetVitMax())
end

local getDayIndex = function ()
	local openDay = i3k_game_get_server_open_day()
	local nowDay = g_i3k_get_day(i3k_game_get_time() - 5*60*60)
	return nowDay - openDay + 1
end

function wnd_arena_list:addChildWidget(widget)
	local children = self._rootWidget:getAddChild()
	while #self._rootWidget:getAddChild()>0 do
		self._rootWidget:removeChild(self._rootWidget:getAddChild()[1])
	end
	self._rootWidget:addChild(widget)
end

function wnd_arena_list:getWidget(state)
	if self._state == state then
		return self._rootWidget:getAddChild()[1]
	end
	return nil
end
function wnd_arena_list:disVisibleFinishBtn()
	local widget = self:getWidget(self._state)
	if widget.vars.finish_btn then
		widget.vars.finish_btn:setVisible(false)
	end
end

function wnd_arena_list:hasNoOpenUI(dayOpen)
	local widget = require("ui/widgets/hdwkq")()
	self:addChildWidget(widget)
	widget.vars.text:setText(i3k_get_string(581, dayOpen))
end

function wnd_arena_list:changeStateImpl(state)
	if state ~= self._state then
		local roleLvl = g_i3k_game_context:GetLevel()
		if state == g_ARENA_STATE then
			i3k_sbean.sync_arena_info()
		elseif state == g_TAOIST_STATE then
			if roleLvl < i3k_db_taoist.needLvl then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_taoist.needLvl))
			else
				if g_i3k_game_context:GetTransformLvl()>= 2 then
					if not g_i3k_game_context:IsInRoom() then
						i3k_sbean.sync_taoist()
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(143))
					end
				else
					self:loadUnlockTaoist()
				end
			end
		elseif state == g_TOURNAMENT_STATE then
			if getDayIndex()<=i3k_db_tournament_base.openDay then
				self:loadTournament()
			elseif roleLvl>=i3k_db_tournament_base.needLvl then
				i3k_sbean.team_arena_sync()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(338, i3k_db_tournament_base.needLvl))
			end--]]
		elseif state == g_FORCE_WAR_STATE then
			if getDayIndex()<=i3k_db_forcewar_base.serverOpenDayslimit then
				self:reloadForceWarActivity()
			elseif roleLvl>= i3k_db_forcewar[1].needLvl then
				i3k_sbean.sync_activities_forcewar()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(571, i3k_db_forcewar[1].needLvl,f_typeTable[g_FORCE_WAR_STATE].title))
			end
		elseif state == g_DEMON_HOLE_STATE then
			if roleLvl >= f_typeTable[state].needLvl then
				i3k_sbean.demonhole_sync()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3066, f_typeTable[state].needLvl))
			end
		elseif state == g_MAZE_BATTLE_STATE then
			if roleLvl >= f_typeTable[state].needLvl then
				i3k_sbean.sync_battle_maze()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17748,i3k_db_maze_battle.openLvl))
			end
		elseif state == g_CHANNEL_COMBST then
			--if roleLvl >= f_typeTable[state].needLvl then
				--self:loadChannelCombat()
			--end
		elseif state == g_BATTLE_DESERT then--决战荒漠
			if roleLvl >= f_typeTable[state].needLvl then
				i3k_sbean.sync_battle_desert()
			else
				g_i3k_ui_mgr:PopupTipMessage(string.format("%d级开启", f_typeTable[state].needLvl))
			end
		elseif state == g_BANGPAIZHAN then
			if roleLvl >= f_typeTable[state].needLvl then
				i3k_sbean.request_sect_fight_group_sync_req(function ()
					i3k_sbean.sect_fight_group_cur_status(function (state)
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadfactionfightgroup", state)
					end)
				end)
			else
				g_i3k_ui_mgr:PopupTipMessage(string.format("%d级开启",f_typeTable[state].needLvl))
			end
		elseif state == g_FIGHT_TEAM_STATE then
			if roleLvl >= f_typeTable[state].needLvl then
				i3k_sbean.fightteam_sync()
			else
				g_i3k_ui_mgr:PopupTipMessage(string.format("%d级开启", f_typeTable[state].needLvl))
			end
		elseif state == g_GLOBAL_PVE_STATE then
			if roleLvl >= f_typeTable[state].needLvl then
				i3k_sbean.globalpve_sync()
			else
				g_i3k_ui_mgr:PopupTipMessage(string.format("%d级开启", f_typeTable[state].needLvl))
			end
		elseif state == g_DEFENCE_WAR_STATE then
			if roleLvl >= f_typeTable[state].needLvl then

				local fun1 = function()
					local callback = function()
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadDefenceWar")
					end
					i3k_sbean.defenceWarInfo(callback)
				end
				-- 先同步下帮派的信息
				local data = i3k_sbean.sect_sync_req.new()
				data.fun = fun1
				data.doNotOpenUI = true
				i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())

			else
				g_i3k_ui_mgr:PopupTipMessage(string.format("%d级开启", f_typeTable[state].needLvl))
			end
		end
	end
end

function wnd_arena_list:changeState(sender)
	local tag = sender:getTag()
	self:changeStateImpl(tag)
	g_i3k_ui_mgr:CloseUI(eUIID_FightTeamList)
end
-- 设置页签状态改变
function wnd_arena_list:setState(state)
	self._state = state
	if state ~= g_FIGHT_TEAM_STATE then
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamGameReport)
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamAward)
	end
end

function wnd_arena_list:setTabBarLight()
	local roleLvl = g_i3k_game_context:GetLevel()
	for i,v in ipairs(self._layout.vars.scroll:getAllChildren()) do
		local tag = v.vars.btn:getTag()
		--local bgIconId = tag%2 ~= 0 and NORMAL_ICON1 or NORMAL_ICON2
		v.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON2))
		if tag == self._state then
			v.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(PRESSED_ICON))
		end
	end
end

--function 单人竞技场() end
function wnd_arena_list:OpenWithArena(info, bestRise)
	self:setState(g_ARENA_STATE)
	self:setTabBarLight()
	local node = require(f_pagePath[self._state])()
	self:addChildWidget(node)
	--注册触摸回调
	node.vars.refresh:onClick(self, self.onRefresh, info.rankNow)
	node.vars.shop:onClick(self, self.toArenaShop)
	node.vars.rankBtn:onClick(self, self.toArenaRank, info.rankNow)
	node.vars.integral:onClick(self, self.toIntegral)
	node.vars.battleInfo:onClick(self, self.toBattleInfo)
	g_i3k_game_context:SetIsHideArenaDefen(info.hideDefence)
	node.vars.defensive:onClick(self, self.setDefensive)
	node.vars.coolRoot:hide()
	node.vars.addTimes:onClick(self, self.toAddTimes)

	--设置头像信息
	local txImage = node.vars.icon
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	node.vars.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		txImage:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end
	--设置战报、积分红点
	self:setLogsRed(g_i3k_game_context:getArenaLogsRed())
	self:setInteralRed(g_i3k_game_context:getArenaInteralRed())
	--帮助按钮
	node.vars.toHelp:onClick(self, self.toHelpUI, info)

	--是否可战斗
	local lastTime = info.lastFightTime
	local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
	if lastTime>0 and timeNow-lastTime<i3k_db_arena.arenaCfg.attackCoolTime then
		self._arenaCanChallenge = false
		g_i3k_game_context:StartAttackCoolTime(i3k_db_arena.arenaCfg.attackCoolTime - (timeNow - lastTime))
	end


	--设置战力等数据
	local hero = i3k_game_get_player_hero()
	node.vars.name:setText(hero._name)
	node.vars.level:setText(hero._lvl)
	local power = hero:Appraise()

	local timeUsed = info.timeUsed
	local timeBuyed = info.timeBuyed
	local lastFightTime = info.lastFightTime
	local pets = info.pets
	local petPower = 0

	--g_i3k_game_context:SetMyPower(power)
	local totalTimes = i3k_db_arena.arenaCfg.freeTimes+info.timeBuyed
	node.vars.challengeTimeLabel:setText(totalTimes-info.timeUsed.."/"..totalTimes)
	g_i3k_game_context:SetArenaChallengeTimes(timeUsed, totalTimes)
	if totalTimes-info.timeUsed==0 then
		node.vars.challengeTimeLabel:setTextColor(f_redWordColor)
	else
		node.vars.challengeTimeLabel:setTextColor(f_greenWordColor)
	end
	node.vars.rankLabel:setText(info.rankNow)

	local playPetCount = 0
	for i,v in pairs(pets) do
		local mercenaryPower = g_i3k_game_context:getBattlePower(v)
		petPower = petPower + mercenaryPower
		playPetCount = playPetCount + 1
	end
	self:setEnemyData(info)
	self:reloadPowerLabel(power+petPower)

	--设置防守红点
	node.vars.defensiveRed:hide()
	if playPetCount<3 then
		local allPets, playPets = g_i3k_game_context:GetYongbingData()
		local hasPetsCount = 0
		for i,v in pairs(allPets) do
			hasPetsCount = hasPetsCount + 1
		end
		node.vars.defensiveRed:setVisible(hasPetsCount>playPetCount)
	end

	--最高排名的弹出奖励
	if bestRise then
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaRankBest)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArenaRankBest, info.rankBestOld)
	end
end

function wnd_arena_list:setEnemyData(info)
	local node = self:getWidget(g_ARENA_STATE)
	if node then
		local enemies = {}
		for k,v in pairs(info.enemies) do
			v.rank = k
			table.insert(enemies, v)
		end

		local _sort = function(p1, p2)
			if p1.rank ~= p2.rank then
				return p1.rank < p2.rank
			end

			return false
		end
		table.sort(enemies, _sort)

		local enemyTable = {}
		local scroll = node.vars.scroll
		scroll:setBounceEnabled(false)

		local children = scroll:addChildWithCount("ui/widgets/1v1jjct", 4, #enemies)
		for i,v in ipairs(children) do
			local enemyData = {}
			enemyData.rank = enemies[i].rank
			enemyData.role = enemies[i].roleSocial.role
			enemyData.pets = enemies[i].pets
			enemyData.hideDefence = enemies[i].hideDefence
			enemyData.sectData = {sectId = enemies[i].roleSocial.sectId, sectName = enemies[i].roleSocial.sectName, personalMsg = enemies[i].roleSocial.personalMsg}
			table.insert(enemyTable, enemyData)

			v.vars.rank:setText(enemyData.rank)
			v.vars.lvl:setText(enemyData.role.level)
			v.vars.name:setText(enemyData.role.name)
			local petsPower = 0;
			if enemies[i].roleSocial.role.id<0 then
				local robot = i3k_db_arenaRobot[math.abs(enemies[i].roleSocial.role.id)]
				enemyData.role.fightPower = robot.power
			else
				for i,v in pairs(enemyData.pets) do
					petsPower = petsPower + v.fightPower
				end
			end

			v.vars.power:setText(enemyData.role.fightPower + petsPower)
			v.vars.zhiyeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[enemyData.role.type].classImg))
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(enemyData.role.headIcon, false))
			v.vars.iconType:setImage(g_i3k_get_head_bg_path(enemyData.role.bwType, enemyData.role.headBorder))
			v.vars.icon:setTag(i+5000)
			v.vars.icon:onClick(self, self.toEnemyLineup)
			v.vars.challenge:setTag(i+1000)
			v.vars.challenge:onClick(self, self.challengeEnemy, info.rankNow)
		end
		scroll:stateToNoSlip()
		g_i3k_game_context:SetArenaEnemys(enemyTable)
	end
end

function wnd_arena_list:challengeEnemy(sender, rankNow)
	if self._arenaCanChallenge then
		local tag = sender:getTag()-1000
		local enemys = g_i3k_game_context:GetArenaEnemys()
		local enemy = enemys[tag]
		if enemy then
			local node = self:getWidget(g_ARENA_STATE)
			local canUseTimeString = node.vars.challengeTimeLabel:getText()
			local canUseTime = string.sub(canUseTimeString, 0, 1)
			if tonumber(canUseTime)==0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(131))
			else
				if not g_i3k_game_context:IsInRoom() then
					g_i3k_ui_mgr:OpenUI(eUIID_ArenaSetBattle)
					g_i3k_ui_mgr:RefreshUI(eUIID_ArenaSetBattle, enemy.role, enemy.rank, enemy.pets, rankNow, enemy.hideDefence)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(695))
				end
			end
		end
	else
		local tips = string.format("请耐心等待冷却或点击重置")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end
function wnd_arena_list:onRefresh(sender, rankNow)
	local refresh = i3k_sbean.arena_refresh_req.new()
	refresh.rankNow = rankNow
	i3k_game_send_str_cmd(refresh, i3k_sbean.arena_refresh_res.getName())
end

function wnd_arena_list:toArenaRank(sender, rankNow)
	local rank = i3k_sbean.arena_ranks_req.new()
	rank.rankNow = rankNow
	i3k_game_send_str_cmd(rank, i3k_sbean.arena_ranks_res.getName())
end

function wnd_arena_list:toArenaShop(sender)
	local syncShop = i3k_sbean.arena_shopsync_req.new()
	i3k_game_send_str_cmd(syncShop, i3k_sbean.arena_shopsync_res.getName())
end

function wnd_arena_list:toEnemyLineup(sender)
	local tag = sender:getTag()-5000
	local enemys = g_i3k_game_context:GetArenaEnemys()
	local enemy = enemys[tag]
	if enemy then
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaEnemyLineup)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArenaEnemyLineup, enemy.role, enemy.pets, enemy.sectData, enemy.hideDefence)
	end
end

function wnd_arena_list:setDefensive(sender)
	local node = self:getWidget(g_ARENA_STATE)
	if node then
		node.vars.defensiveRed:hide()
	end
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaSetLineup)
	local pets = g_i3k_game_context:GetArenaDefensive()
	local hideDefence = g_i3k_game_context:GetIsHideArenaDefen()
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaSetLineup, pets, hideDefence)
end

function wnd_arena_list:setLogsRed(isShow)
	if self._state==g_ARENA_STATE then
		local node = self:getWidget(g_ARENA_STATE)
		if node then
			node.vars.logsRed:setVisible(isShow)
		end
	end
end

function wnd_arena_list:toBattleInfo(sender)
	local battleInfo = i3k_sbean.arena_log_req.new()
	i3k_game_send_str_cmd(battleInfo, i3k_sbean.arena_log_res.getName())
end

function wnd_arena_list:setInteralRed(isShow)
	if self._state==g_ARENA_STATE then
		local node = self:getWidget(g_ARENA_STATE)
		if node then
			node.vars.interalRed:setVisible(isShow)
		end
	end
end

function wnd_arena_list:toIntegral(sender)
	local syncIntegral = i3k_sbean.arena_scoresync_req.new()
	i3k_game_send_str_cmd(syncIntegral, i3k_sbean.arena_scoresync_res.getName())
end

function wnd_arena_list:toAddTimes(sender)
	local timeUsed, totalTimes = g_i3k_game_context:GetArenaChallengeTimes()
	local buyTimes = totalTimes-i3k_db_arena.arenaCfg.freeTimes
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local maxBuyTimes = i3k_db_kungfu_vip[vipLvl].arenaBuyTimes
	if buyTimes<maxBuyTimes then
		local timeBuyed = buyTimes
		local buyTimeCfg = i3k_db_arena.arenaCfg.buyTimesNeedDiamond
		local needDiamond = buyTimeCfg[timeBuyed+1]
		if not needDiamond then
			needDiamond = buyTimeCfg[#buyTimeCfg]
		end
		descText = string.format("是否花费<c=green>%d绑定元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次", needDiamond, maxBuyTimes-timeBuyed)

		local function callback(isOk)
			if isOk then
				local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
				if haveDiamond >= needDiamond then
					local buy = i3k_sbean.arena_buytimes_req.new()
					buy.times = timeBuyed+1
					buy.needDiamond = needDiamond
					i3k_game_send_str_cmd(buy, "arena_buytimes_res")
				else
					local tips = string.format("%s", "您的元宝不足，购买失败")
					g_i3k_ui_mgr:PopupTipMessage(tips)
				end
			else

			end
		end

		g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(148))
	end
end

function wnd_arena_list:resetCoolTime(sender)
	local bindDiamond = g_i3k_game_context:GetDiamondCanUse(false)
	if bindDiamond>i3k_db_arena.arenaCfg.cleanCoolDiamond then
		local reset = i3k_sbean.arena_resetcool_req.new()
		i3k_game_send_str_cmd(reset, "arena_resetcool_res")
	else
		local tips = string.format("%s", "您的绑定元宝不足以重置挑战时间")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

function wnd_arena_list:toHelpUI(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaHelp)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaHelp, info)
end

function wnd_arena_list:reloadPowerLabel(power)
	local node = self:getWidget(g_ARENA_STATE)
	node.vars.powerLabel:setText(power)
end

function wnd_arena_list:buyTimesCB(haveTimes, totalTimes)
	local node = self:getWidget(g_ARENA_STATE)
	if node then
		node.vars.challengeTimeLabel:setText(haveTimes.."/"..totalTimes)
		node.vars.challengeTimeLabel:setTextColor(f_greenWordColor)
		g_i3k_ui_mgr:PopupTipMessage("购买成功")
	end
end

function wnd_arena_list:cool(coolTime)
	local node = self:getWidget(g_ARENA_STATE)
	if node then
		self._arenaCanChallenge = false
		node.vars.btnName:setText("重置")
		node.vars.refresh:onClick(self, self.resetCoolTime)

		node.vars.coolRoot:show()
		node.vars.addTimes:hide()
		node.vars.coolTimeLabel:setText(os.date("%M:%S", math.ceil(coolTime)))
		local needCount = i3k_db_arena.arenaCfg.cleanCoolDiamond
		local needText = string.format("x%d", needCount)
		node.vars.needDiamond:setText(needText)
	end
end

function wnd_arena_list:cool2()
	local node = self:getWidget(g_ARENA_STATE)
	if node then
		self._arenaCanChallenge = true
		node.vars.btnName:setText("换一换")
		node.vars.refresh:onClick(self, self.onRefresh)
		node.vars.coolRoot:hide()
		node.vars.addTimes:show()
	end
end






--function 正邪道场() 
function wnd_arena_list:loadUnlockTaoist()
	self:setState(g_TAOIST_STATE)
	self:setTabBarLight()
	local node = require("ui/widgets/zhengxiedaochangkq")()
	local vas = node.vars
	vas.des:setText(i3k_get_string(17906))
	local items = i3k_db_taoist.showRedwards
	local comps = {}
	for i = 1, 3 do
		comps[i] = {}
		comps[i].icon = vas["icon" .. i]
		comps[i].root = vas["root" .. i]
		comps[i].lock = vas["suo" .. i]
		comps[i].btn = vas["bt" .. i]
		comps[i].name = vas["name" .. i]
	end
	for k, id in ipairs(items) do
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(id) 
		comps[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		comps[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		comps[k].name:setText(cfg.name)
		comps[k].lock:setVisible(id > 0)
		comps[k].btn:onClick(self, function() g_i3k_ui_mgr:ShowCommonItemInfo(id) end)
	end
	self:addChildWidget(node)
end
function wnd_arena_list:loadTaoist(info)
	self:setState(g_TAOIST_STATE)
	self:setTabBarLight()
	local node = require(f_pagePath[self._state])()
	self:addChildWidget(node)

	--self._taoistMaxPetsCount = 0
	self._taoistCanFight = true
	local widget = node.vars

	--人物信息
	local hero = i3k_game_get_player_hero()
	node.vars.myName:setText(hero._name)
	node.vars.myLevel:setText(hero._lvl)
	node.vars.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		node.vars.myIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end

	widget.logBtn:onClick(self, self.syncLogs)
	widget.rankBtn:onClick(self, self.onRank)
	widget.toHelp:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15158))
	end)

	self._taoistPetsCount = 0

	local maxPetsCount = i3k_db_taoist_level_cfg[info.lvl].maxPetsCount
	local petNums = g_i3k_game_context:GetYongbingNums()
	local nowNum = info.pets and table.nums(info.pets) or 0
	widget.lineupRed:setVisible(nowNum < maxPetsCount and petNums > 0 and nowNum < petNums)

	self:setTaoistData(node, info)
end

function wnd_arena_list:setTaoistData(node, info)
	--关于人物信息的协议部分
	local cfg = i3k_db_taoist_level_cfg
	node.vars.taoistLvlLabel:setText(info.lvl.."级")
	local maxExp = cfg[#cfg].needExp
	local lvlMaxExp = cfg[info.lvl+1] and cfg[info.lvl+1].needExp or maxExp
	if info.lvl >= #cfg then
		node.vars.expLabel:setVisible(false)
		node.vars.max:setVisible(true)
		node.vars.expPercent:setPercent(100)
	else
		node.vars.max:setVisible(false)
		node.vars.expLabel:setVisible(true)
	node.vars.expLabel:setText(info.exp.."/"..lvlMaxExp)
	node.vars.expPercent:setPercent(info.exp/lvlMaxExp*100)
	end
	local hero = i3k_game_get_player_hero()
	local myPower = hero:Appraise()
	for i,v in pairs(info.pets) do
		myPower = myPower + g_i3k_game_context:getBattlePower(i)
	end
	node.vars.powerLabel:setText(myPower)


	--奖励部分
	local canGetRewardScore = i3k_db_taoist.needInteral
	node.vars.percentLabel:setText(string.format("%d/%d", info.rewardScore, canGetRewardScore))
	node.vars.rewardLabel:setText(string.format("每得%d分可以领奖", canGetRewardScore))
	node.vars.box:onClick(self, self.takeReward, info)

	node.vars.boxAnis:setVisible(info.rewardScore>=canGetRewardScore)
	if info.rewardScore<canGetRewardScore then
		node.vars.box:setTouchEnabled(false)
	end



	--挑战次数以及换一换
	local freeTimes = i3k_db_taoist.freeTimes
	local surplusTimes = freeTimes+info.timeBuyed-info.timeUsed
	node.vars.challengeTimeLabel:setText(surplusTimes.."/"..freeTimes+info.timeBuyed)
	if surplusTimes>0 then
		node.vars.btnName:setText(string.format("换一换"))
		node.vars.refreshBtn:onClick(self, self.refreshEnemies)
		self._taoistRefreshTimes = info.dayRefreshTimes
		if self._taoistRefreshTimes >= g_MAX_REFRESH_TIMES then
			node.vars.refreshBtn:disableWithChildren()
		end
		self._taoistCanFight = true
	else
		self._taoistCanFight = false
		node.vars.btnName:setText(string.format("购买"))
		node.vars.refreshBtn:onClick(self, self.addTimes, info)
	end
	if self:calculateTime()~=1 then
		node.vars.refreshBtn:disableWithChildren()
	else
		node.vars.refreshBtn:enableWithChildren()
	end

	--设置对手信息
	self:setEnemiesData(info.enemies)


	--[[--出战随从
	local count = i3k_db_taoist_level_cfg[#i3k_db_taoist_level_cfg].maxPetsCount
	local scroll = node.vars.scroll
	local petPower = 0
	local pets = {}
	for i,v in pairs(info.pets) do
		table.insert(pets, i)
		petPower = petPower + g_i3k_game_context:getBattlePower(i)
	end
	self._taoistPetsCount = #pets
	node.vars.petsPowerLabel:setText(petPower)
	local cfg = i3k_db_taoist_level_cfg[info.lvl]
	self._taoistMaxPetsCount = cfg.maxPetsCount
	node.vars.lackLabel:hide()
	for i=1, count do
		local node = require("ui/widgets/zxdct")()
		if i<=#pets then
			local iconId = g_i3k_db.i3k_db_get_head_icon_id(pets[i])
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
			node.vars.petRoot:show()
			node.vars.noPetRoot:hide()
			node.vars.noOpenRoot:hide()
		else
			if i<=cfg.maxPetsCount then
				node.vars.petRoot:hide()
				node.vars.noPetRoot:show()
				node.vars.noOpenRoot:hide()
				node.vars.lackLabel:show()
			else
				node.vars.petRoot:hide()
				node.vars.noPetRoot:hide()
				node.vars.noOpenRoot:show()
				for j,v in ipairs(i3k_db_taoist_level_cfg) do
					if v.maxPetsCount==i then
						node.vars.desc:setText(string.format("%d级开放", j))
						break
					end
				end
			end
		end
		scroll:addItem(node)
	end--]]

	node.vars.adjustBtn:onClick(self, self.onAdjustPets, info)
end

function wnd_arena_list:setEnemiesData(enemies)
	local node = self:getWidget(g_TAOIST_STATE)
	if node then
		local widgets = {}
		for i=1,4 do
			local role = {}
			role.root = node.vars["root"..i]
			role.nameLabel = node.vars["nameLabel"..i]
			role.scoreImg = node.vars["scoreImg"..i]
			role.levelLabel = node.vars["levelLabel"..i]
			role.iconType = node.vars["iconType"..i]
			role.icon = node.vars["icon"..i]
			role.btn = node.vars["btn"..i]
			role.winImg = node.vars["winImg"..i]
			role.zhiyeImg = node.vars["zhiyeImg"..i]
			role.powerLabel = node.vars["powerLabel"..i]
			widgets[i] = role
		end
		if enemies and #enemies~=0 then
			g_i3k_game_context:setTaoistEnemy(enemies)
			for i,v in ipairs(widgets) do
				if enemies[i] then
					local role = enemies[i].array.roleSocial.role
					local pets = enemies[i].array.pets
					local win = enemies[i].win--1胜利，0失败，-1没打过
					local score = enemies[i].score
					local imgPath = win==0 and g_i3k_db.i3k_db_get_icon_path(1852) or g_i3k_db.i3k_db_get_icon_path(1851)
					v.winImg:setImage(imgPath)
					v.winImg:setVisible(win>=0)
					local scoreImgPath = score==1 and g_i3k_db.i3k_db_get_icon_path(1920) or g_i3k_db.i3k_db_get_icon_path(1921)
					v.scoreImg:setImage(scoreImgPath)
					v.levelLabel:setText(role.level)
					v.nameLabel:setText(role.name)
					v.zhiyeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[role.type].classImg))
					v.iconType:setImage(g_i3k_get_head_bg_path(role.bwType, role.headBorder))
					v.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(role.headIcon, false))
					local power = role.fightPower
					for _,e in pairs(pets) do
						power = power + e.fightPower
					end
					v.powerLabel:setText(power)
					v.btn:setTag(role.id)
					v.btn:onClick(self, self.onEnemyClick, role.name)
					if win>=0 then
						v.btn:disableWithChildren()
					else
						v.btn:enableWithChildren()
					end
					v.root:show()
				else
					v.root:hide()
				end
			end
		end
	end
end

function wnd_arena_list:calculateTime()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local openTime = i3k_db_taoist.openTime
	local endTime = i3k_db_taoist.closeTime
	--判断是否在开启时段
	local open = string.split(openTime, ":")
	local close = string.split(endTime, ":")
	local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
	local closeTimeStamp = os.time({year = year, month = month, day = day, hour = close[1], min = close[2], sec = close[3]})
	if closeTimeStamp<=openTimeStamp then
		closeTimeStamp = closeTimeStamp + 24*60*60
	end
	if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
		--当天活动开启状态
		return 1
	elseif timeStamp>closeTimeStamp then
		--当天活动已结束状态
		return 2
	elseif timeStamp<openTimeStamp then
		--当天活动未开启状态
		return 3
	end
end

function wnd_arena_list:challengeEnemyCB(roleId, name)
	if g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	local desc = string.format("确定挑战%s?", name)
	local callback = function (isOk)
		if isOk then
			i3k_sbean.taoist_start_fight(roleId, self._taoistPetsCount)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end

function wnd_arena_list:onEnemyClick(sender, name)
	local node = self:getWidget(g_TAOIST_STATE)
	if self:calculateTime()== 1 then
		if self._taoistCanFight then
			if not node.vars.boxAnis:isVisible() then
				if not g_i3k_game_context:IsInRoom() then
					local func = function ()
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "challengeEnemyCB", sender:getTag(), name)
					end
					g_i3k_game_context:CheckMulHorse(func)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(693))
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15146))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(131))
		end
	else
		--时间不到
		local openTime = i3k_db_taoist.openTime
		local endTime = i3k_db_taoist.closeTime
		openTime = string.sub(openTime, 1, 5)
		endTime = string.sub(endTime, 1, 5)
		local msg = string.format("大侠，正邪道场正在清理昨天的战斗垃圾。\n               %s~%s开放", openTime, endTime)
		g_i3k_ui_mgr:ShowMessageBox1(msg)
	end
end

function wnd_arena_list:refreshEnemies(sender)
	if self._taoistRefreshTimes >= g_MAX_REFRESH_TIMES then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15162))
		return
	end
	local needDiamond = i3k_db_taoist.refreshDiamond
	local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
	if needDiamond<=haveDiamond then
		local desc = i3k_get_string(15145, needDiamond, g_MAX_REFRESH_TIMES - self._taoistRefreshTimes)
		local callback = function (isOk)
			if isOk then
				i3k_sbean.refresh_taoist_enemy()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("元宝数量不足，刷新失败"))
	end
end

function wnd_arena_list:addRefreshTimes()
	self._taoistRefreshTimes = self._taoistRefreshTimes + 1
end

function wnd_arena_list:addTimes(sender, info)
	local needDiamondTable = i3k_db_taoist.buyTimesNeedDiamond
	local needDiamond = info.timeBuyed+1>#needDiamondTable and needDiamondTable[#needDiamondTable] or needDiamondTable[info.timeBuyed+1]
	local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local maxBuyTimes = i3k_db_kungfu_vip[vipLvl].taoistBuyTimes
	local callfunc = function ()
		info.timeBuyed = info.timeBuyed + 1
		g_i3k_game_context:UseDiamond(needDiamond, false,AT_BWARENA_BUY_TIMES)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadTaoist", info)
	end
	if info.timeBuyed<maxBuyTimes then
		descText = i3k_get_string(15161, needDiamond, maxBuyTimes-info.timeBuyed)

		local function callback(isOk)
			if isOk then
				if haveDiamond > needDiamond then
					i3k_sbean.taoist_buy_times(info.timeBuyed+1, callfunc)
				else
					local tips = string.format("%s", "您的元宝不足，购买失败")
					g_i3k_ui_mgr:PopupTipMessage(tips)
				end
			end
		end

		g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(148))
	end

end

function wnd_arena_list:onAdjustPets(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_TaoistPets)
	info.pets = self._taoistFightPets or info.pets
	g_i3k_ui_mgr:RefreshUI(eUIID_TaoistPets, info)
end


function wnd_arena_list:refreshFightPets(pets, maxCount)
	local node = self:getWidget(g_TAOIST_STATE)
	if node then
		self._taoistPetsCount = #pets
		local petPower = 0
		self._taoistFightPets = {}
		for i,v in ipairs(pets) do
			self._taoistFightPets[v] = true
			petPower = petPower + g_i3k_game_context:getBattlePower(v)
		end
		local myPower = i3k_game_get_player_hero():Appraise()
		node.vars.powerLabel:setText(myPower + petPower)

		local nowNum = table.nums(pets) or 0
		local petNums = g_i3k_game_context:GetYongbingNums()
		node.vars.lineupRed:setVisible(nowNum < maxCount and petNums > 0 and nowNum < petNums)
	end
end

function wnd_arena_list:syncLogs(sender)
	i3k_sbean.sync_taoist_log()
end

function wnd_arena_list:onRank(sender)
	local bwType = g_i3k_game_context:GetTransformBWtype()
	i3k_sbean.sync_taoist_rank(bwType, 0, 10)
end

function wnd_arena_list:refreshReward(score, info)
	local node = self:getWidget(g_TAOIST_STATE)
	if node then
		local canGetRewardScore = i3k_db_taoist.needInteral
		node.vars.percentLabel:setText(string.format("%d/%d", score, canGetRewardScore))
		node.vars.boxAnis:setVisible(score>=canGetRewardScore)
		node.vars.box:onClick(self, self.takeReward, info)
		if score<canGetRewardScore then
			node.vars.box:setTouchEnabled(false)
		end
	end
end

function wnd_arena_list:takeReward(sender, info)
	local bwType = g_i3k_game_context:GetTransformBWtype()
	local item = {}
	if bwType == 1 then
		item.id = i3k_db_taoist_level_cfg[info.lvl].rightItemId
		item.count = i3k_db_taoist_level_cfg[info.lvl].rightItemCount
	else
		item.id = i3k_db_taoist_level_cfg[info.lvl].villainItemId
		item.count = i3k_db_taoist_level_cfg[info.lvl].villainItemCount
	end
	local t = {[item.id] = item.count}
	if not g_i3k_game_context:IsBagEnough(t) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
	local callback = function ()
		local itemTable = {
			[1] = item
		}
		g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
		local canGetRewardScore = i3k_db_taoist.needInteral
		local enemies = g_i3k_game_context:getTaoistEnemy()
		info.rewardScore = info.rewardScore - canGetRewardScore
		info.enemies = enemies
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadTaoist", info)
	end
	i3k_sbean.take_taoist_reward(callback)
end


--function 会武() end
function wnd_arena_list:openWithTournament()
	local roleLvl = g_i3k_game_context:GetLevel()
	if getDayIndex()<=i3k_db_tournament_base.openDay then
		self:loadTournament()
	elseif roleLvl >= i3k_db_tournament_base.needLvl then
		i3k_sbean.team_arena_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(338, i3k_db_tournament_base.needLvl))
	end
end

function wnd_arena_list:loadTournament(info)
	self:setState(g_TOURNAMENT_STATE)
	self:setTabBarLight()
	local dayIndex = getDayIndex()
	if dayIndex <= i3k_db_tournament_base.openDay then
		self:hasNoOpenUI(i3k_db_tournament_base.openDay - dayIndex + 1)
		return
	end
	local widget = require(f_pagePath[self._state])()
	self:addChildWidget(widget)
	i3k_sbean.super_arena_week_reward_sync()
	widget.vars.nameLabel:setText(g_i3k_game_context:GetRoleName())
	widget.vars.levelLabel:setText(g_i3k_game_context:GetLevel())
	local power = g_i3k_game_context:GetRolePower()
	if g_i3k_game_context:GetTournamentPet() ~= 0 then
		power = power + g_i3k_game_context:getBattlePower(g_i3k_game_context:GetTournamentPet())
	end
	widget.vars.powerLabel:setText(power)
	widget.vars.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	widget.vars.petBtn:onClick(self, self.onTournamentChoosePet)
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		widget.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end
	widget.vars.shop:onClick(self, self.onTournamentShop)--todo
	widget.vars.rankBtn:onClick(self, self.onTournamentRank, info)--todo
	widget.vars.toHelp:onClick(self, function (sender)
		local cfg = i3k_db_tournament_base
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17181, cfg.weaponKillAaddScore, cfg.weaponDeadReduceScore, cfg.weaponMaxScore))
	end)

	widget.vars.weaponSetBtn:onClick(self, self.onTournamentWeaponSet)
	self:setTournamentData(widget, info)
	self:showFirstRewardBtn(widget, FIRST_CLEAR_REWARD_TOURNAMENT)
end

-- 神兵乱战设置
function wnd_arena_list:onTournamentWeaponSet(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SuperArenaWeaponSet)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuperArenaWeaponSet)
end
-- 周奖励
function wnd_arena_list:onWeekReward(sender)
	local info = g_i3k_game_context:getTournamentWeekRewardInfo()
	if table.nums(info.reward) == #i3k_db_tournament_week_reward then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1751))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_TournamentWeekReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_TournamentWeekReward)
	end
end
--周奖励红点
function wnd_arena_list:isWeekRewardRed()
	local info = g_i3k_game_context:getTournamentWeekRewardInfo()
	for k, v in  ipairs(i3k_db_tournament_week_reward) do
		if info.reward and info.reward[v.needTimes] then
		else
			if info.weekTimes >=  v.needTimes then
				return true
			end	
		end
	end
	return false
end
--刷新会武
function wnd_arena_list:updataWeekReward()
	local node = self:getWidget(g_TOURNAMENT_STATE)
	if node then
		node.vars.weekReward:onClick(self, self.onWeekReward)
		node.vars.rewardRed:setVisible(self:isWeekRewardRed())
	end
end

function wnd_arena_list:GetSortTournament(db)
	table.sort(db, function (a,b)
		return a.sortID < b.sortID
	end)
	return db
end

function wnd_arena_list:setTournamentData(widget, info)
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)

	local dbCfg = i3k_clone(i3k_db_tournament)
	for _, v in ipairs(self:GetSortTournament(dbCfg)) do
		local node = require("ui/widgets/4v4jjct")()
		node.rootVar:setTag(v.id)
		node.vars.nameImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconId))
		node.vars.levelLabel:setText(v.needLvl)
		node.vars.timesLabel:setText(info.logs[v.id] and info.logs[v.id].dayEnterTimes or "0")

		local score = info.logs[v.id] and info.logs[v.id].elo or i3k_db_tournament_base.defaultScore
		local eloDesc = g_i3k_db.i3k_db_get_tournament_elo_name(v.id, score)
		node.vars.scoreLable:setText(string.format("%s %s", score, eloDesc))
		node.vars.scoreRuleBtn:onClick(self, function (sender)
			g_i3k_ui_mgr:ShowHelp(i3k_get_string(15423))
		end)

		--设置时间以及开放日
		local isOpen = i3k_get_activity_is_open(v.openDay)
		local isInTime = false
		if isOpen then
			for k=1,2 do
				if not v.startTime[k] then
					node.vars["timeLabel"..k]:hide()
					break
				end
				local openTime, closeTime = i3k_get_start_close_time_show(v.startTime[k], v.lifeTime)
				node.vars["timeLabel"..k]:setText(openTime.."~"..closeTime)
				--判断是否在开启时段
				local open = string.split(v.startTime[k], ":")
				local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
				local closeTimeStamp = openTimeStamp + v.lifeTime;
				if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
					isInTime = true
				end
				node.vars["timeLabel"..k]:setTextColor(g_i3k_get_cond_color(isInTime))
			end
		end
		local matchType, actType = g_i3k_game_context:getMatchState()
		if isOpen and isInTime and (matchType~=g_TOURNAMENT_MATCH or actType~=v.id) then
			node.vars.aloneBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_JOIN[1]))
			node.vars.teamBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_JOIN[2]))
			node.vars.aloneBtn:onClick(self, self.aloneJoin, {arenaType = v.id, needLvl = v.needLvl})
			node.vars.teamBtn:onClick(self, self.teamJoin, {arenaType = v.id, needLvl = v.needLvl})
		elseif matchType==g_TOURNAMENT_MATCH and actType==v.id then
			node.vars.aloneBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_CANCEL[1]))
			node.vars.teamBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_CANCEL[2]))
			node.vars.aloneBtn:onClick(self, self.onStopMatchOperation, g_TOURNAMENT_MATCH)
			node.vars.aloneLabel:setText("取消报名")
			node.vars.teamBtn:onClick(self, self.onStopMatchOperation, g_TOURNAMENT_MATCH)
			node.vars.teamLabel:setText("取消报名")
		else
			if not isOpen then
				node.vars.timeLabel1:hide()
				node.vars.timeLabel2:show()
				node.vars.timeLabel2:setText(i3k_get_activity_open_desc(v.openDay))
				node.vars.timeLabel2:setTextColor(g_i3k_get_red_color())
			end
			node.vars.aloneBtn:disableWithChildren()
			node.vars.teamBtn:disableWithChildren()
		end
		if #v.openDay == 0 then
			node.vars.timeLabel1:hide()
			node.vars.timeLabel2:setText(i3k_get_string(1750))
		end
		widget.vars.scroll:addItem(node)
		self:loadTournamentSkills(node, v)
		self:LoadArmsBtn(node, v)
	end
end
function wnd_arena_list:LoadArmsBtn(node, tournamentCfg)
	if tournamentCfg.id == g_TOURNAMENT_CHUHAN then
		node.vars.arms:show()
		node.vars.armsBtn:onClick(self, self.onArmsBtn)
	else
		node.vars.arms:hide()
	end
end
function wnd_arena_list:onArmsBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ChuHanFightInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChuHanFightInfo)
end

function wnd_arena_list:loadTournamentSkills(node, tournamentCfg)
	local isShowSkillRoot = tournamentCfg.sceneSkill == 1
	node.vars.skillRoot:setVisible(isShowSkillRoot)
	if isShowSkillRoot then
		local skillsCfg = i3k_db_tournament_weapon_skills
		for i = 1, 3 do
			local skillCfg = skillsCfg[i]
			node.vars["skillBg"..i]:setVisible(skillCfg ~= nil)
			if skillCfg then
				node.vars["sIcon"..i]:setImage(g_i3k_db.i3k_db_get_skill_icon_path(skillCfg.skillID))
				--local pos = self:getTournamentSkillsPosition(node.vars["skillBtn"..i])
				node.vars["skillBtn"..i]:onTouchEvent(self, self.onCheckTournamentSkill, {skillID = skillCfg.skillID, btn = node.vars["skillBtn"..i]})
			end
		end
	end
end

function wnd_arena_list:getTournamentSkillsPosition(btn)
	local btnSize = btn:getParent():getContentSize()
	local sectPos = btn:getPosition()
	local btnPos = btn:getParent():getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_arena_list:onCheckTournamentSkill(sender, eventType, data)
	if eventType == ccui.TouchEventType.began then
		local pos = self:getTournamentSkillsPosition(data.btn)
		g_i3k_ui_mgr:OpenUI(eUIID_DescTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_DescTips, i3k_db_skills[data.skillID].name, i3k_db_skills[data.skillID].desc, pos)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_DescTips)
		end
	end

end

function wnd_arena_list:isCanEnterWeaponSWar(info)
	if info.arenaType == g_TOURNAMENT_WEAPON then
		local weapons = g_i3k_game_context:GetTournamentWeapons()
		if #weapons == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17177))
			return false
		end
	end
	return true
end

function wnd_arena_list:aloneJoin(sender, value)
	if not self:isCanEnterWeaponSWar(value) then
		return false
	end

	local matchType, actType = g_i3k_game_context:getMatchState()
	if matchType~=0 then
		self:inMatchingPopText()
		return
	end
	local room = g_i3k_game_context:IsInRoom()
	if room then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(339, "房间", i3k_db_tournament[value.arenaType].name))
		return
	end

	local teamId = g_i3k_game_context:GetTeamId()
	if teamId~=0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(339, "队伍", i3k_db_tournament[value.arenaType].name))
		return
	end

	local hero = i3k_game_get_player_hero()
	if hero._lvl<value.needLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341, value.needLvl))
		return
	end
	local func = function ()
		i3k_sbean.mate_alone(value.arenaType)
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_TOURNAMENT_MATCH, value.arenaType)
	end
	local callback = function ()
		g_i3k_game_context:CheckMulHorse(func)
	end
	local fightPetID = g_i3k_game_context:GetTournamentPet()
	local petCount = g_i3k_game_context:GetPetCount()
	if fightPetID == 0 and petCount ~= 0 and i3k_db_tournament[value.arenaType].isFightPets == 1 then
		local callback = function (isOk)
			if not isOk then
				g_i3k_game_context:CheckMulHorse(func)
			else
				g_i3k_ui_mgr:OpenUI(eUIID_TournamentChoosePet)
				g_i3k_ui_mgr:RefreshUI(eUIID_TournamentChoosePet)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(286), callback)
	else
		g_i3k_game_context:CheckMulHorse(func)
	end
end

function wnd_arena_list:teamJoin(sender, value)
	if not self:isCanEnterWeaponSWar(value) then
		return false
	end

	local cfg = i3k_db_tournament[value.arenaType]
	local canJoin = i3k_can_dungeon_join(true, cfg.name, cfg.roomMemberCount, value.needLvl)
	if canJoin then
		i3k_sbean.create_arena_room(value.arenaType)
	end

end

function wnd_arena_list:onTournamentShop(sender)
	i3k_sbean.sync_team_arena_store()
end

function wnd_arena_list:onTournamentRank(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_TournamentRecord)
	g_i3k_ui_mgr:RefreshUI(eUIID_TournamentRecord, info)
end

function wnd_arena_list:onTournamentChoosePet(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_TournamentChoosePet)
	g_i3k_ui_mgr:RefreshUI(eUIID_TournamentChoosePet)
end



--function 势力战() end
function wnd_arena_list:openWithForceWar()
	local  hero = i3k_game_get_player_hero()
	if getDayIndex()<=i3k_db_forcewar_base.serverOpenDayslimit then
		self:reloadForceWarActivity()
	elseif hero._lvl>= i3k_db_forcewar[1].needLvl then
		i3k_sbean.sync_activities_forcewar()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(571, i3k_db_forcewar[1].needLvl,f_typeTable[g_FORCE_WAR_STATE].title))
	end
end

function wnd_arena_list:reloadForceWarActivity(dayEnterTimes,enterTimes,winTimes,bestRank,punishEndTime)
	self:setState(g_FORCE_WAR_STATE)
	self:setTabBarLight()
	local dayIndex = getDayIndex()
	if dayIndex <= i3k_db_forcewar_base.serverOpenDayslimit then
		self:hasNoOpenUI(i3k_db_forcewar_base.serverOpenDayslimit - dayIndex + 1)
		return
	end

	local widget = require(f_pagePath[self._state])()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self._widgets = widgets
	self._punishtime = punishEndTime

	self:loadRoleHeadInfo(widgets)
	self._isDropOut = g_i3k_game_context:getForceWarDropOutState()--是否存在惩罚时间
	widgets.punishtime:setVisible(self._isDropOut)
	widgets.punishTxt:setVisible(self._isDropOut)
	widgets.punishtime:setTextColor(g_i3k_get_cond_color(punishEndTime == 0))
	widgets.punishTxt:setTextColor(g_i3k_get_cond_color(punishEndTime == 0))

	local l_winRate = 0
	if enterTimes > 0 then
		l_winRate = string.format("%.1f", winTimes/enterTimes*100)--math.modf()
	end
	widgets.powerLabel:setText(winTimes) --胜场数
	widgets.powerLabel2:setText(l_winRate.."%")--胜率
	widgets.powerLabel3:setText(enterTimes)--历史参与次数
	widgets.dayEnterLabel:setText(dayEnterTimes)--今日参与次数
	widgets.dayEnterLabel:setTextColor(g_i3k_get_cond_color(dayEnterTimes>0))

	--帮助 显示规则
	local timesLimit = i3k_db_forcewar_base.lotteryData.gainTimes
	widgets.toHelp:onClick(self, function (sender)
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15171, timesLimit, timesLimit))
	end)

	widgets.rankBtn:onClick(self,function (sender)---排行榜
		g_i3k_logic:OpenForceWarRankListUI()
	end)
	local num = g_i3k_game_context:getForceWarLotteryNum()
	widgets.lottery_btn:onClick(self, self.onLotteryBtnClick)
	widgets.lottery_red:setVisible(num > 0)

	self:setForceWarActivityInfo(widget)
end

function wnd_arena_list:setForceWarActivityInfo(widget)
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y",  timeStamp)
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local l_curLvl =  g_i3k_game_context:GetLevel()

	local openDay = i3k_game_get_server_open_day()
	local nowDay = g_i3k_get_day(i3k_game_get_time())
	local days = nowDay - openDay
	local dayslimit = i3k_db_forcewar_base.serverOpenDayslimit

	local matchType, actType = g_i3k_game_context:getMatchState()
	local scroll = widget.vars.scroll
	for i, v in ipairs(i3k_db_forcewar) do
		if i < g_CHANNEL_COMBAT then
			local node = require("ui/widgets/shilizhant")()
			node.rootVar:setTag(v.id)
			local isOpen = false
			local isInTime = false
			for _,t in ipairs(v.openDay) do
				if t==week then
					isOpen = true
					break
				end
			end
			local needLvl = v.needLvl
			node.vars.need_lvl:setText(needLvl)
			node.vars.need_lvl:setTextColor(g_i3k_get_cond_color(l_curLvl >= needLvl))
			if isOpen then--如果开启
				for k=1,#v.startTime do
					if not v.startTime[k] then
						break
					end
					local openTime = string.sub(v.startTime[k], 1, 5)
					local hour = tonumber(string.sub(openTime, 1, #openTime-3))
					local len = #openTime
					local min = tonumber(string.sub(openTime, #openTime-1, #openTime))
					local lifeMin = math.floor(v.lifeTime/60);--780
					local lifeHour = math.floor(lifeMin/60);--13
					local endMin = math.floor(lifeMin%60);--0
					local endHour = math.floor(hour + lifeHour);--23
					if endMin + min >= 60 then
						endHour = endHour + 1;
						endMin = endMin + min - 60;
					end
					local closeTime = string.format("%02d:%02d", endHour, endMin)
					if endHour >= 24 then
						endHour = endHour - 24;
						closeTime = string.format("次日%02d:%02d", endHour, endMin)
					end
					local time = openTime.."~"..closeTime
					--判断是否在开启时段
					local open = string.split(v.startTime[k], ":")
					local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
					local closeTimeStamp = openTimeStamp + v.lifeTime
					if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
						isInTime = true
					end
					node.vars.join_time:setTextColor(g_i3k_get_cond_color(isInTime))
					node.vars.join_time:setText(time)
				end
			end
			local isAble = true
			node.vars.isAble = true
			local condition = isOpen and isInTime and days and l_curLvl >= needLvl and  days>= dayslimit
			if condition and (matchType ~= g_FORCE_WAR_MATCH or actType ~= v.id ) then
				node.vars.join_text:setText("报名")
				node.vars.join:enableWithChildren()
				node.vars.join:onClick(self, self.onClickJoinBtn, v.id)---报名
			elseif condition and matchType == g_FORCE_WAR_MATCH and actType == v.id then
				node.vars.join:enableWithChildren()
				node.vars.join_text:setText("取消报名")
				node.vars.join:onClick(self, self.onStopMatchOperation, g_FORCE_WAR_MATCH)
			else
				node.vars.isAble = false
				node.vars.join:disableWithChildren()
				if not isOpen then
					local text = #v.openDay == 0 and i3k_get_string(1315) or i3k_get_activity_open_desc(v.openDay)
					node.vars.join_time:setText(text)--时间段
					node.vars.join_time:setTextColor(g_i3k_get_red_color())
				end
			end
			node.vars.nameImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconID))
			scroll:addItem(node)
		end
	end
end

function wnd_arena_list:onLotteryBtnClick(sender)
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_ForceWarLottery)
end
function wnd_arena_list:setForceWarLotteryRed()
	local num = g_i3k_game_context:getForceWarLotteryNum()
	self._redList[g_FORCE_WAR_STATE]:setVisible(num > 0)
	local node = self:getWidget(g_FORCE_WAR_STATE)
	if node then
		node.vars.lottery_red:setVisible(num > 0)
	end
end
--单人报名入口
function wnd_arena_list:onClickJoinBtn(sender, forcewarType)
	local matchType, actType = g_i3k_game_context:getMatchState()
	if matchType~=0 then
		self:inMatchingPopText()
		return
	end
	local isDropOut = g_i3k_game_context:getForceWarDropOutState()
	if g_i3k_game_context:GetTransformLvl()>= 2 then
		if forcewarType ~= g_CHANNEL_COMBAT and self._currentTime < self._punishtime and isDropOut  then
			g_i3k_ui_mgr:PopupTipMessage("你刚刚逃离了势力战场,暂时无法报名")
		else
			self:joinForceWar(forcewarType)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("尚未加入正邪阵营")
	end
end
function wnd_arena_list:joinForceWar(forcewarType)
			--加入势力战的队伍判断
			local teamId = g_i3k_game_context:GetTeamId()
			if teamId==0 then
				if not g_i3k_game_context:IsInRoom() then
					local func = function ()
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "joinForceWarCB", forcewarType)
					end
					g_i3k_game_context:CheckMulHorse(func)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(694))
				end
			else
				if g_i3k_game_context:IamTeamLeader() then
					--组队报名的逻辑
					self:warTeamJion(forcewarType)
				else
					--提示队员不能报名
					g_i3k_ui_mgr:PopupTipMessage("只有队长可以组队报名参与势力战")
		end
	end

end

--组队报名的逻辑jxw
function wnd_arena_list:warTeamJion(fType)
	local room = g_i3k_game_context:IsInRoom()
	if room then
		if room.type~=0 and room.type~=gRoom_Force_War then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(343, ""))
			return
		else
			if g_i3k_game_context:getForceWarRoomType() == g_CHANNEL_COMBAT then
				g_i3k_ui_mgr:OpenUI(eUIID_CreateCombatTeam)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateCombatTeam, "loaMembersProfile", g_i3k_game_context:getForceWarRoomLeader(), g_i3k_game_context:getForceWarMemberProfiles())
				return
			end
			local callback = function (isOk)
				if isOk then
					g_i3k_ui_mgr:OpenUI(eUIID_War_Team_Room)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room, "aboutMyRoom", g_i3k_game_context:getForceWarRoomLeader(), g_i3k_game_context:getForceWarMemberProfiles())
					return
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1023), callback)
			return
		end
	end
	local isOk= false
	local index = 0

	--判断自己等级是否符合
	local roleLvl = g_i3k_game_context:GetLevel() --判断等级
	local needLvl = i3k_db_forcewar[fType].needLvl
	if roleLvl < needLvl then
		g_i3k_ui_mgr:PopupTipMessage(341, needLvl)
	end

	--队员有不同势力或未加入正邪阵营 则return
	local transfer = g_i3k_game_context:GetTransformBWtype()
	local otherInfo = g_i3k_game_context:GetTeamOtherMembersProfile() --除了自己以外的其他人
	for i,v in ipairs(otherInfo) do
		if fType == g_FORCEWAR_NORMAL then --正邪势力战判断
			local t  = v.overview.bwType
			if v.overview.bwType ~= transfer or transfer==0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1022))
				return
			end
		end
		if v.overview.level< needLvl then   --elseif	队伍中存在级别不足的玩家
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3072))
			return
		else
			--弹出下级ui
			index = index +1
			isOk = true
		end
	end

	if (isOk and index==#otherInfo) or fType == g_CHANNEL_COMBAT then
		--全部符合条件
		if not g_i3k_game_context:IsInRoom() then
			local func = function ()
				--g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "joinForceWarCB")
				i3k_sbean.war_create_room(fType)
			end
			g_i3k_game_context:CheckMulHorse(func)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(694))
		end
	end
end

function wnd_arena_list:joinForceWarCB(fType)
	--g_i3k_ui_mgr:OpenUI(eUIID_ForceWarMatching)
	g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_FORCE_WAR_MATCH, fType)
	i3k_sbean.join_forcewar(fType)
	--g_i3k_game_context:OnMatchingOperation()
end

function wnd_arena_list:onStopMatchOperation(sender, matchType)
	if matchType==g_TOURNAMENT_MATCH then
		i3k_sbean.cancel_mate()
	elseif matchType==g_FORCE_WAR_MATCH then
		i3k_sbean.quit_join_forcewar()
	elseif matchType == g_FIGHT_TEAM_MATCH then
		i3k_sbean.fightteam_quitqualifying_request()
	end
end

function wnd_arena_list:startMatching(joinTime, matchType, actType)
	if matchType==g_TOURNAMENT_MATCH and self._state==g_TOURNAMENT_STATE then
		--灰化，不可点击报名
		--i3k_log("g_TOURNAMENT_MATCH")
		local widget = self:getWidget(g_TOURNAMENT_STATE)
		if widget then
			local children = widget.vars.scroll:getAllChildren()
			local node
			for i,v in ipairs(children) do
				if v.rootVar:getTag()==actType then
					node = v
					break
				end
			end
			node.vars.aloneBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_CANCEL[1]))
			node.vars.teamBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_CANCEL[2]))
			node.vars.aloneBtn:onClick(self, self.onStopMatchOperation, g_TOURNAMENT_MATCH)
			node.vars.aloneLabel:setText("取消报名")
			node.vars.teamBtn:onClick(self, self.onStopMatchOperation, g_TOURNAMENT_MATCH)
			node.vars.teamLabel:setText("取消报名")
		end
	elseif matchType==g_FORCE_WAR_MATCH and self._state==g_FORCE_WAR_STATE then
		--灰化，不可点击报名
		--i3k_log("g_FORCE_WAR_MATCH")
		local widget = self:getWidget(g_FORCE_WAR_STATE)
		if widget then
			local children = widget.vars.scroll:getAllChildren()
			local node
			for i,v in ipairs(children) do
				if v.rootVar:getTag()==actType then
					node = v
					break
				end
			end
			node.vars.join:onClick(self, self.onStopMatchOperation, g_FORCE_WAR_MATCH)
			node.vars.join_text:setText("取消报名")
		end
	elseif matchType == g_FORCE_WAR_MATCH and self._state == CHANNEL_COMBST then
		local widget = self:getWidget(CHANNEL_COMBST)
		if widget then
			widget.vars.joinCombat:onClick(self, self.onStopMatchOperation, g_FORCE_WAR_MATCH)
			widget.vars.joinCombatTxt:setText("取消报名")
		end
	elseif matchType == g_FIGHT_TEAM_MATCH and self._state == g_FIGHT_TEAM_STATE then
		local widget = self:getWidget(g_FIGHT_TEAM_STATE)
		if widget then
			if actType == g_FIGHTTEAM_QUALIFYING_MATCH then
				widget.vars.qualifyingBtn:onClick(self, self.onStopMatchOperation, g_FIGHT_TEAM_MATCH)
				widget.vars.qualifyingTxt:setText(i3k_get_string(1222))
			else
				widget.vars.signBtn:disableWithChildren()
			end
		end
	end
	local room = g_i3k_game_context:IsInRoom()
	if not room or room.type~=gRoom_Force_War or g_i3k_game_context:getForceWarRoomType() == g_CHANNEL_COMBAT then
		g_i3k_ui_mgr:OpenUI(eUIID_SignWait)
		g_i3k_ui_mgr:RefreshUI(eUIID_SignWait, joinTime, matchType, actType)
	end
end

function wnd_arena_list:inMatchingPopText()
	g_i3k_ui_mgr:PopupTipMessage(string.format("已有其他活动报名中"))
end

function wnd_arena_list:stopMatching(matchType, actType)
	if matchType==g_TOURNAMENT_MATCH and self._state==g_TOURNAMENT_STATE then
		--取消灰化，重新可点击报名
		local widget = self:getWidget(g_TOURNAMENT_STATE)
		if widget then
			local children = widget.vars.scroll:getAllChildren()
			local node
			for i,v in ipairs(children) do
				if v.rootVar:getTag()==actType then
					node = v
					break
				end
			end
			if node then
			local cfg = i3k_db_tournament[node.rootVar:getTag()]
			node.vars.aloneBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_JOIN[1]))
			node.vars.teamBtn:setImage(g_i3k_db.i3k_db_get_icon_path(TOURNAMENT_JOIN[2]))
			node.vars.aloneLabel:setText("单人报名")
			node.vars.aloneBtn:onClick(self, self.aloneJoin, {arenaType = node.rootVar:getTag(), needLvl = cfg.needLvl})
			node.vars.teamLabel:setText("组队报名")
			node.vars.teamBtn:onClick(self, self.teamJoin, {arenaType = node.rootVar:getTag(), needLvl = cfg.needLvl})
			end
		end
	elseif matchType==g_FORCE_WAR_MATCH and self._state==g_FORCE_WAR_STATE then
		--取消灰化，重新可点击报名
		local widget = self:getWidget(g_FORCE_WAR_STATE)
		if widget then
			local children = widget.vars.scroll:getAllChildren()
			local node
			for i,v in ipairs(children) do
				if v.rootVar:getTag()==actType then
					node = v
					break
				end
			end
			if node then
			node.vars.join:onClick(self, self.onClickJoinBtn, node.rootVar:getTag())
			node.vars.join_text:setText("报名")
			end
		end
	elseif matchType == g_FORCE_WAR_MATCH and self._state == CHANNEL_COMBST then
		local widget = self:getWidget(CHANNEL_COMBST)
		if widget then
			widget.vars.joinCombat:onClick(self, self.onWarTeamJion, widget.vars.joinCombat:getTag())
			widget.vars.joinCombatTxt:setText("报名")
		end
	elseif matchType == g_FIGHT_TEAM_MATCH and self._state == g_FIGHT_TEAM_STATE then
		local widget = self:getWidget(g_FIGHT_TEAM_STATE)
		if widget then
			if actType == g_FIGHTTEAM_QUALIFYING_MATCH then
				widget.vars.qualifyingBtn:onClick(self, self.onQualifyingBtn)
				widget.vars.qualifyingTxt:setText(i3k_get_string(1223))
			else
				widget.vars.signBtn:enableWithChildren()
			end
		end
	end
end

--[[function 伏魔洞试炼()
end--]]
function wnd_arena_list:loadDemonHole(curFloor, dayEnterTimes)
	self:setState(g_DEMON_HOLE_STATE)
	local widget = require(f_pagePath[self._state])()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self:loadRoleHeadInfo(widgets)
	widgets.toHelp:onClick(self, function (sender)
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(3070))
	end)
	self:setDemonHoleActivityInfo(widgets, curFloor, dayEnterTimes)
	self:setTabBarLight()
end

function wnd_arena_list:setDemonHoleActivityInfo(widgets, curFloor, dayEnterTimes)
	local demonHoleCfg = i3k_db_demonhole_base

	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	self._demonHoleWidget = widgets
	local roleLvl =  g_i3k_game_context:GetLevel()
	local isOpen = g_i3k_db.i3k_get_activity_is_open(i3k_db_demonhole_base.openDay)
	widgets.need_lvl:setText(demonHoleCfg.needLvl)
	-- 开启时间段
	--local openTime, closeTime = i3k_get_start_close_time_show(demonHoleCfg.startTime, demonHoleCfg.lifeTime)
	widgets.have_times:setText(i3k_get_activity_open_time_desc(demonHoleCfg.openTimes))
	--判断是否在开启时段
	local _, _, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(demonHoleCfg.openTimes)
	widgets.have_times:setTextColor(g_i3k_get_cond_color(isInTime))
	-- 开启日期
	widgets.join_time:setText(i3k_get_activity_open_desc(demonHoleCfg.openDay))--时间段
	widgets.join_time:setTextColor(g_i3k_get_cond_color(isOpen))
	local showCurFloor = curFloor == 0 and 1 or curFloor
	self:updateFloorImage(widgets, showCurFloor)
	widgets.join:onClick(self, self.onDemonHoleJoinBtn, {dayEnterTimes = dayEnterTimes, curFloor = curFloor})
end

function wnd_arena_list:updateFloorImage(widgets, count)
	if count < 10 then
		widgets.ten_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[10]))
		widgets.unit_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[count]))
	else
		local tag = count%10 == 0 and 10 or count%10
		widgets.ten_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[math.modf(count/10)]))
		widgets.unit_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[tag]))
	end
end

function wnd_arena_list:onDemonHoleJoinBtn(sender, data)
	if data.dayEnterTimes >= i3k_db_demonhole_base.canJoinTimes and data.curFloor <= 0 then
	 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3126, i3k_db_demonhole_base.canJoinTimes))
	 	return
	end

	local roleLvl = g_i3k_game_context:GetLevel()
	if roleLvl < i3k_db_demonhole_base.needLvl then
		g_i3k_ui_mgr:PopupTipMessage("您的等级过低，不能参与此活动")
		return
	end

	local roleTransformLvl = g_i3k_game_context:GetTransformLvl()
	if roleTransformLvl < i3k_db_demonhole_base.needTransformLvl then
		g_i3k_ui_mgr:PopupTipMessage("您必须完成二转方可参与此活动")
		return
	end

	local room = g_i3k_game_context:IsInRoom()
	if room or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage("您正在报名其他活动，不能参与此活动")
		return
	end

	local function func()
		i3k_sbean.demonhole_join()
	end
	g_i3k_game_context:CheckMulHorse(func)
end

-- 渠道对抗赛
function wnd_arena_list:loadChannelCombat()
	self:setState(CHANNEL_COMBST)
	self:setTabBarLight()
	local widget = require(f_pagePath[self._state])()
	local widgets = widget.vars
	self:addChildWidget(widget)
	self:loadRoleHeadInfo(widgets)
	widgets.toHelp:onClick(self, function (sender)
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(3070))
	end)
	self:loadChannelCombatJoin(widgets)
end

function wnd_arena_list:loadChannelCombatJoin(widgets)
	local cfg = i3k_db_forcewar[g_CHANNEL_COMBAT]

	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y",  timeStamp)
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local l_curLvl =  g_i3k_game_context:GetLevel()

	local openDay = i3k_game_get_server_open_day()
	local nowDay = g_i3k_get_day(i3k_game_get_time())
	local days = nowDay - openDay
	local dayslimit = i3k_db_forcewar_base.serverOpenDayslimit

	local matchType, actType = g_i3k_game_context:getMatchState()
	widgets.joinCombat:setTag(cfg.id)
	local isOpen = false
	local isInTime = false
	for _,t in ipairs(cfg.openDay) do
		if t==week then
			isOpen = true
			break
		end
	end
	local needLvl = cfg.needLvl
	if isOpen then--如果开启
		for k=1,#cfg.startTime do
			if not cfg.startTime[k] then
				break
			end
			local openTime = string.sub(cfg.startTime[k], 1, 5)
			local hour = tonumber(string.sub(openTime, 1, #openTime-3))
			local len = #openTime
			local min = tonumber(string.sub(openTime, #openTime-1, #openTime))
			local lifeMin = cfg.lifeTime/60;--780
			local lifeHour = lifeMin/60;--13
			local endMin = lifeMin%60;--0
			local endHour = hour + lifeHour;--23
			if endMin + min >= 60 then
				endHour = endHour + 1;
				endMin = endMin + min - 60;
			end
			local closeTime = string.format("%02d:%02d", endHour, endMin)
			if endHour >= 24 then
				endHour = endHour - 24;
				closeTime = string.format("次日%02d:%02d", endHour, endMin)
			end
			local time = openTime.."~"..closeTime
			--判断是否在开启时段
			local open = string.split(cfg.startTime[k], ":")
			local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
			local closeTimeStamp = openTimeStamp + cfg.lifeTime
			if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
				isInTime = true
			end
			--node.vars.join_time:setTextColor(g_i3k_get_cond_color(isInTime))
			--node.vars.join_time:setText(time)
		end
	end
	local condition = isOpen and isInTime and days and l_curLvl >= needLvl and  days>= dayslimit
	if condition and (matchType ~= g_FORCE_WAR_MATCH or actType ~= cfg.id ) then
		widgets.joinCombatTxt:setText("报名")
		widgets.joinCombat:enableWithChildren()
		widgets.joinCombat:onClick(self, self.onWarTeamJion, cfg.id)---报名
	elseif condition and matchType == g_FORCE_WAR_MATCH and actType == cfg.id then
		widgets.joinCombat:enableWithChildren()
		widgets.joinCombatTxt:setText("取消报名")
		widgets.joinCombat:onClick(self, self.onStopMatchOperation, g_FORCE_WAR_MATCH)
	else
		widgets.joinCombat:disableWithChildren()
	end
	widgets.combatList:onClick(self, self.onCombatList, cfg.id)
	widgets.createCombat:onClick(self, self.onCreateCombat, cfg.id)
end

function wnd_arena_list:onWarTeamJion(sender, fType)
	local roleId = g_i3k_game_context:GetRoleId()
	local leaderId = g_i3k_game_context:getForceWarRoomLeader()
	if roleId ~= leaderId then
		g_i3k_ui_mgr:PopupTipMessage("不是团长不能报名")
		return
	end
	if i3k_db_forcewar_base.channelData.fightNum > #g_i3k_game_context:getForceWarMemberProfiles() then
		g_i3k_ui_mgr:PopupTipMessage("报名人数不足")
		return
	end
	local fRoomType = g_i3k_game_context:getForceWarRoomType()
	g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_FORCE_WAR_MATCH, fRoomType)
	i3k_sbean.join_forcewar(fRoomType)
end

function wnd_arena_list:onCombatList(sender, fType)
	if g_i3k_game_context:getForceWarRoomType() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage("已报名其他活动无法观战")
		return
	end
	i3k_sbean.forcewar_mapbrief(fType)
end

function wnd_arena_list:onCreateCombat(sender, fType)
	self:warTeamJion(fType)
end

--天魔迷宫
function wnd_arena_list:loadbattlemaze(data)
	self:setState(g_MAZE_BATTLE_STATE)
	self:setTabBarLight()
	local widgets = require(f_pagePath[self._state])()
	self:addChildWidget(widgets)
	local vars = widgets.vars
	self.battleMazeWidget = vars
	local lvl = g_i3k_game_context:GetLevel()
	vars.need_lv:setText(i3k_db_maze_battle.openLvl)
	if lvl < i3k_db_maze_battle.openLvl then
		vars.need_lv:setTextColor(g_i3k_get_cond_hl_color())
	end
	vars.open_time:setText(i3k_get_activity_open_time_desc(i3k_db_maze_battle.openTime))
	vars.open_date:setText(i3k_get_activity_open_desc(i3k_db_maze_battle.openWeekDay))
	vars.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17764, i3k_db_maze_battle.openLvl, i3k_db_maze_battle.originalToolsNum, i3k_db_maze_battle.transferneedNum, 
	i3k_db_maze_difficulty[1].defeatNum, i3k_db_maze_battle.peopleMax))
	end)
	self:onUpdateMazeScroll()
	vars.join:onClick(self, self.onMazeBattleBtnClick, data)
	vars.ExplainBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_MazeBattleExplain)
	end)
end
function wnd_arena_list:onMazeBattleBtnClick(sender, data)
	local roleTransformLvl = g_i3k_game_context:GetTransformLvl()
	if roleTransformLvl < i3k_db_maze_battle.needTransformLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17794))
		return
	end
	
	local roleLvl = g_i3k_game_context:GetLevel()
	
	if roleLvl < i3k_db_maze_battle.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341, i3k_db_maze_battle.openLvl))
		return
	end

	local room = g_i3k_game_context:IsInRoom()
	
	if room or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5322))
		return
	end
	
	local isTimeValid = false
	local openTime, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(i3k_db_maze_battle.openTime)

	if data.dayEnterTimes < i3k_db_maze_battle.joinTimes then
		isTimeValid = isInTime
	elseif data.dayEnterTimes == i3k_db_maze_battle.joinTimes then
		local time = g_i3k_get_GMTtime(data.lastJoinTime)
		isTimeValid = time > openTime and time < closeTime
	end
	
	if isTimeValid then
		if i3k_check_resources_downloaded(i3k_db_maze_battle.sceneDetection) then
			i3k_sbean.join_battle_maze()
		end	
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17755))
	end
end

function wnd_arena_list:onUpdateMazeScroll()
	self.battleMazeWidget.rewards:removeAllChildren()
	
	for _, id in ipairs(i3k_db_maze_battle.awardPreview) do
		if id ~= 0 then
			local node = require("ui/widgets/tianmomigongt")()
			self:updateMazeCell(node.vars, id)
			self.battleMazeWidget.rewards:addItem(node)
		end	
	end
end

function wnd_arena_list:updateMazeCell(node, itemID)
	node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	node.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
	node.btn:onClick(self, function()
		g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
	end)
	node.suo:setVisible(itemID > 0)
end

--天魔迷宫倒计时
function wnd_arena_list:onBattleMazeUpdate(dTime)
	local vars = self.battleMazeWidget
	local cfg = i3k_db_maze_battle
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(cfg.openTime)
	local curtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local seconds = closeTime - curtime
	local isOpen = i3k_get_activity_is_open(cfg.openWeekDay)
	local lvLimit = cfg.openLvl <= g_i3k_game_context:GetLevel()
	if not self._isMazeBattleOnTime then
		self._isMazeBattleOnTime = isOpen and isInTime
		vars.join:SetIsableWithChildren(self._isMazeBattleOnTime)
	end
	if isOpen and isInTime then
		if not self._isMazeBattleOnTime then
			vars.join:enableWithChildren()
		end
	else
		if self._isMazeBattleOnTime then
			vars.join:disableWithChildren()
		end
	end
	self._isMazeBattleOnTime = isOpen and isInTime
	vars.not_open:setVisible(not(isOpen and isInTime))
	vars.countdown_desc:setVisible(not vars.not_open:isVisible())
	vars.countdown:setVisible(not vars.not_open:isVisible())
	vars.open_date:setTextColor(g_i3k_get_cond_hl_color(isOpen))
	vars.open_time:setTextColor(g_i3k_get_cond_hl_color(isInTime))
	vars.need_lv:setTextColor(g_i3k_get_cond_hl_color(lvLimit))
	if isOpen and isInTime and seconds >= 0 then
		vars.countdown:setText(i3k_get_time_show_text(seconds))
	end
end
--决战荒漠
function wnd_arena_list:loadbattledesert(data)
	self:setState(g_BATTLE_DESERT)
	self:setTabBarLight()
	self._battleShowTimer = 2
	local widgets = require(f_pagePath[self._state])()
	self:addChildWidget(widgets)
	local vars = widgets.vars
	self.battleDesertWidget = vars
	vars.desc:setText(i3k_get_string(17660))
	local lvl = g_i3k_game_context:GetLevel()
	vars.need_lv:setText(i3k_db_desert_battle_base.openLvl)
	if lvl < i3k_db_desert_battle_base.openLvl then
		vars.need_lv:setTextColor(g_i3k_get_red_color())
	end
	local leftCount = i3k_db_desert_battle_base.countPerDay - g_i3k_game_context:getBattleDesertDayEnterTimes()
	vars.leftCount:setText(leftCount)
	vars.leftCount:setTextColor(g_i3k_get_cond_color(leftCount > 0))
	vars.open_time:setText(i3k_get_activity_open_time_desc(i3k_db_desert_battle_base.openTime))
	vars.open_date:setText(i3k_get_activity_open_desc(i3k_db_desert_battle_base.openWeekDay))
	vars.singleBtn:onClick(self, self.onDesertBattleSingleBtnClick)
	vars.teamBtn:onClick(self, self.onDesertBattleTeamBtnClick)
	vars.selectHeroBtn:onClick(self, self.onDesertBattleSelectHeroBtnClick)
	vars.awardBtn:onClick(self, self.onDesertBattleAwardBtnClick)
	vars.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17602))
	end)
	vars.rankBtn:onClick(self, function (sender)   ---排行榜
		g_i3k_logic:OpenDesertBattleRankListUI()
	end)
end
--决战荒漠倒计时
function wnd_arena_list:onBattleDesertUpdate(dTime)
	local vars = self.battleDesertWidget
	local cfg = i3k_db_desert_battle_base
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(cfg.openTime)
	local curtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local seconds = closeTime - curtime
	local isOpen = i3k_get_activity_is_open(cfg.openWeekDay)
	local lvLimit = cfg.openLvl <= g_i3k_game_context:GetLevel()
	if not self._isDesertBattleOnTime then
		self._isDesertBattleOnTime = isOpen and isInTime
		vars.singleBtn:SetIsableWithChildren(self._isDesertBattleOnTime)
		vars.teamBtn:SetIsableWithChildren(self._isDesertBattleOnTime)
	end
	if isOpen and isInTime then
		if not self._isDesertBattleOnTime then
			vars.singleBtn:enableWithChildren()
			vars.teamBtn:enableWithChildren()
		end
	else
		if self._isDesertBattleOnTime then
			vars.singleBtn:disableWithChildren()
			vars.teamBtn:disableWithChildren()
		end
	end
	self._isDesertBattleOnTime = isOpen and isInTime
	vars.not_open:setVisible(not(isOpen and isInTime))
	vars.countdown_desc:setVisible(not vars.not_open:isVisible())
	vars.open_date:setTextColor(g_i3k_get_cond_color(isOpen))
	vars.open_time:setTextColor(g_i3k_get_cond_color(isInTime))
	vars.need_lv:setTextColor(g_i3k_get_cond_color(lvLimit))
	if isOpen and isInTime and seconds >= 0 then
		vars.countdown:setText(i3k_get_time_show_text(seconds))
	end
	if self._battleShowTimer > 0 then
		self._battleShowTimer = self._battleShowTimer - dTime
	else
		vars.show_desc:hide()
	end
end
function wnd_arena_list:onDesertBattleSingleBtnClick(sender)
	local cfg = i3k_db_desert_battle_base
	local matchType, actType = g_i3k_game_context:getMatchState()
	if matchType~=0 then
		self:inMatchingPopText()
		return
	end
	local room = g_i3k_game_context:IsInRoom()
	if room then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(339, i3k_get_string(17651), cfg.gameName))
		return
	end
	local teamId = g_i3k_game_context:GetTeamId()
	if teamId~=0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(339, i3k_get_string(17652), cfg.gameName))
		return
	end
	local hero = i3k_game_get_player_hero()
	if hero._lvl < cfg.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341, cfg.openLvl))
		return
	end
	if not self:CheckCanEnterBattleDesert() then
		return
	end
	local func = function ()
		i3k_sbean.mate_alone(g_DESERT_BATTLE_MATCH)
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_TOURNAMENT_MATCH, g_DESERT_BATTLE_MATCH)
	end
	g_i3k_game_context:CheckMulHorse(func)
end
function wnd_arena_list:onDesertBattleTeamBtnClick(sender)
	if not self:CheckCanEnterBattleDesert() then
		return
	end
	local canJoin = i3k_can_dungeon_join(true, i3k_db_desert_battle_base.gameName, i3k_db_desert_battle_base.teamPersonNum, i3k_db_desert_battle_base.openLvl)
	if canJoin then
		i3k_sbean.create_arena_room(g_DESERT_BATTLE_MATCH)
	end
	end

function wnd_arena_list:CheckCanEnterBattleDesert()
	if g_i3k_game_context:getBattleDesertRoleInfo().curHero == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17605))
		return false
	end
	if g_i3k_game_context:getBattleDesertDayEnterTimes() == i3k_db_desert_battle_base.countPerDay then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17656))
		return false
	end
	if g_i3k_game_context:getBattleDesertPunishTime() > i3k_game_get_time() then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleDesertPunish)
		return false
	end
	return true
end
function wnd_arena_list:onDesertBattleSelectHeroBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleDesertHero)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleDesertHero)
end
function wnd_arena_list:onDesertBattleAwardBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleDesertAward)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleDesertAward)
end
-----------------end----------------------
--帮派战
function wnd_arena_list:loadfactionfightgroup(data)
	local status = -1
	if data.status then
		status = data.status.curStatus
		self._status = data.status.curStatus
	end
	self:setState(g_BANGPAIZHAN)
	self:setTabBarLight()
	local widgets = require(f_pagePath[self._state])()
	self:addChildWidget(widgets)
	self._faction_fight_widget = widgets.vars
	widgets.vars.join:hide()
	local lvl = g_i3k_game_context:GetLevel()
	widgets.vars.need_lvl:setText(i3k_db_faction_fight_cfg.commonrule.applylvl)
	local cfgtime = g_i3k_db.i3k_db_get_bangpaizhan_Starttime()
	widgets.vars.join_time:setText(i3k_get_string(17433,cfgtime.month,cfgtime.day) )
	if not status or status == -1 or status == 6 then
		widgets.vars.join_text2:setText("报名")
		widgets.vars.join_text2:enableOutline("ff1c7c5e")
		widgets.vars.join2:setImage(g_i3k_db.i3k_db_get_icon_path(4105))
	elseif status == 0 then
		widgets.vars.join_text2:setText("取消报名")
		widgets.vars.join_text2:enableOutline("ffcb8933")
		widgets.vars.join2:setImage(g_i3k_db.i3k_db_get_icon_path(4104))
	else
		widgets.vars.join_text2:setText("进入")
	end
	widgets.vars.join2:onClick(self, self.apply, status)
	widgets.vars.toHelp:onClick(self, function(sender)
		g_i3k_ui_mgr:OpenUI(eUIID_Help)
		g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(3125))
	end)
	widgets.vars.list:onClick(self, function(sender)
		g_i3k_logic:Openfactionfightrank() --打开帮战排行榜
	end)
	widgets.vars.showAward:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightAward)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightAward)
	end)
	self:showFirstRewardBtn(widgets, FIRST_CLEAR_REWARD_SECT)
	widgets.vars.ExplainBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightExplain)
	end)
end

function wnd_arena_list:apply(sender, status)
	if status == -1 or status == 6 then
		if not self._btnState then
			if self:judgeCanApply() then
				local groupId = g_i3k_game_context:getFightGroupId()
				i3k_sbean.sect_war_sign(groupId, function()
					i3k_sbean.sect_fight_group_cur_status(function (state)
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadfactionfightgroup", state)
					end)
				end)
			end
			self._btnState = true
			self._timeCount = 0
		else
			g_i3k_ui_mgr:PopupTipMessage("操作过于频繁")
		end
	elseif status == 0 then
		if not self._btnState then
			local groupId = g_i3k_game_context:getFightGroupId()
			if groupId then
				i3k_sbean.sect_war_quit(groupId, function()
					i3k_sbean.sect_fight_group_cur_status(function (state)
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadfactionfightgroup", state)
					end)
				end)
			else
				g_i3k_ui_mgr:PopupTipMessage("只有堂主才能取消报名")
			end
			self._btnState = true
			self._timeCount = 0
		else
			g_i3k_ui_mgr:PopupTipMessage("操作过于频繁")
		end
	else
		local groupId = g_i3k_game_context:getFightGroupId()
		local fun = function()
			i3k_sbean.enter_sectwar(groupId)
		end
		g_i3k_game_context:CheckMulHorse(fun)
	end
end

--判断是否能报名
function wnd_arena_list:judgeCanApply()
	local groupId = g_i3k_game_context:getFightGroupId()
	if groupId then
		local roleId = g_i3k_game_context:GetRoleId()
		if g_i3k_game_context:roleIsFactionFightGroupLeaderById(roleId, groupId) then
			if self:judgeInApply() then
				local data = g_i3k_game_context:getFactionFightGroupData()
				if i3k_db_faction_fightgroup.common.limitNumber > table.nums(data[groupId].member) then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3113, i3k_db_faction_fightgroup.common.limitNumber))
					return false
				else
					return true
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3124))
				return false
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3122))
			return false
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3122))
		return false
	end
end

--判断是否在报名时间
function wnd_arena_list:judgeInApply()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local isOpen = g_i3k_db.i3k_db_is_open_bangpaizhan() --帮派战是否今天开启
	for i = 1, #i3k_db_faction_fight_cfg.timebucket do
		local startTime = string.split(i3k_db_faction_fight_cfg.timebucket[i].applytime, ":")--报名开始时间
		local beginTime = string.split(i3k_db_faction_fight_cfg.timebucket[i].beginfight, ":")--战斗开始时间
		local openTime = os.time({year = year, month = month, day = day, hour = startTime[1], min = startTime[2], sec = startTime[3]})
		local fightTime = os.time({year = year, month = month, day = day, hour = beginTime[1], min = beginTime[2], sec = beginTime[3]})
		if timeStamp > openTime and timeStamp < fightTime and isOpen then
			return true
		end
	end
	return false
end
--设置头像信息
function wnd_arena_list:loadRoleHeadInfo(widgets)
	local headIcon = g_i3k_game_context:GetRoleHeadIconId()
	widgets.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie)
	if hicon and hicon > 0 then
		widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	end
	widgets.levelLabel:setText(g_i3k_game_context:GetLevel())
	widgets.nameLabel:setText(g_i3k_game_context:GetRoleName())
	widgets.myPower:setText(g_i3k_game_context:GetRolePower())
end
-----------------------------武道大会 began-----------------------------
function wnd_arena_list:reloadFightTeam()
	self:setState(g_FIGHT_TEAM_STATE)
	local widget = require(f_pagePath[self._state])()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self:setTabBarLight()
	self:loadFightTeamWidget(widgets)
	self._layout.vars.scroll:jumpToChildWithIndex(self._state)
	self:setGroupUI(widgets)
end

function wnd_arena_list:loadFightTeamWidget(widgets)
	local stage = g_i3k_game_context:getScheduleStage()
	widgets.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_fightTeam_base.display.titleIcon))
	widgets.scheduleBtn:onClick(self, self.onScheduleBtn) -- 赛程表
	widgets.guardBtn:setVisible(i3k_db_fightTeam_base.display.isShowGuard > 0)
	widgets.guardBtn:onClick(self, self.onGuardBtn)
	local tabs = {
		widgets.mainUIBtn,
		widgets.gameBtn,
		widgets.rewardBtn
	}

	local showTab = function (index)
		if index == 1 then -- 参赛
			g_i3k_ui_mgr:CloseUI(eUIID_FightTeamAward)
			g_i3k_ui_mgr:CloseUI(eUIID_FightTeamGameReport)
		end

		if index == 2 then -- 赛事，修改为 两组
			local default = g_i3k_game_context:getDefaultGroupID()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "openFightTeamReport", default)
		end

		if index == 3 then -- 打开奖励
			g_i3k_ui_mgr:OpenUI(eUIID_FightTeamAward)
			g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamAward)
		end

		for k,v in ipairs(tabs) do
			if k == index then
				v:stateToPressed()
			else
				v:stateToNormal()
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamList)
	end

	for k,v in ipairs(tabs) do
		v:setButtonStateColor("ff500c01","fffe984d")
		v:onClick(nil,function ()
			showTab(k)
		end)
	end

	showTab(1)

	if g_i3k_game_context:getScheduleStage() > 1 then
		if not g_i3k_game_context:getFightTeamGroup() then
			tabs[1]:setVisible(false)
			showTab(2)
		end
	end

	widgets.createTeam:onClick(self, self.onCreateFightTeam) --创建战队
	widgets.timeTxt:setText(g_i3k_db.i3k_db_get_stage_time_desc(stage)) -- 时间描述
	local explainCfg = i3k_db_fightTeam_explain[stage]
	if explainCfg then
		widgets.stageDesc:setText(explainCfg.uiName)
	end
	local needLvl = i3k_db_fightTeam_base.team.requireLvl
	widgets.needLvlTxt:setTextColor(g_i3k_game_context:GetLevel() >= needLvl and "ff63e25a" or "fff13915")
	widgets.needLvlTxt:setText(i3k_get_string(1219, needLvl)) --需求等级
end
function wnd_arena_list:openFightTeamReport(id)
	local stage = g_i3k_game_context:getScheduleStage()
	if stage > 1 then
		if stage > 6 then
			stage = 6
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FightTeamGameReport)
		g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamGameReport, stage, id)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1218))
		return
	end
end
function wnd_arena_list:setGroupUI(widgets)
	local default = g_i3k_game_context:getDefaultGroupID()
	widgets.joinCombatTxt2:setText(g_i3k_db.i3k_db_get_fightTeam_group_name(default))
	widgets.gameBtn:onClick(nil, function(index)
		local stage = g_i3k_game_context:getScheduleStage()
		if stage <= 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1218))
			return
		end
		widgets.mainUIBtn:stateToNormal()
		widgets.gameBtn:stateToPressed()
		widgets.rewardBtn:stateToNormal()
		widgets.joinCombatTxt2:setText(g_i3k_db.i3k_db_get_fightTeam_group_name(default))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "openFightTeamReport", default)
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamList)
	end)
	local commonFunc = function(widgets, id)
		widgets.joinCombatTxt2:setText(g_i3k_db.i3k_db_get_fightTeam_group_name(id))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "openFightTeamReport", id)
		widgets.mainUIBtn:stateToNormal()
		widgets.gameBtn:stateToPressed()
		widgets.gameBtn:onClick(nil, function()
			local stage = g_i3k_game_context:getScheduleStage()
			if stage <= 1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1218))
				return
			end
			widgets.mainUIBtn:stateToNormal()
			widgets.gameBtn:stateToPressed()
			widgets.rewardBtn:stateToNormal()
			widgets.joinCombatTxt2:setText(g_i3k_db.i3k_db_get_fightTeam_group_name(id))
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "openFightTeamReport", id)
			g_i3k_ui_mgr:CloseUI(eUIID_FightTeamList)
		end)
		widgets.rewardBtn:stateToNormal()
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamList)
	end
	local funcs = {
		function()
			commonFunc(widgets, g_FIGHT_TEAM_WUHUANG)
		end,
		function()
			commonFunc(widgets, g_FIGHT_TEAM_WUDI)
		end,
	}
	widgets.selectGroup:onClick(self, function()
		local stage = g_i3k_game_context:getScheduleStage()
		if stage <= 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1218))
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FightTeamList)
		g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamList, funcs)
	end)
end

function wnd_arena_list:loadFightTeamInfo(info)
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		local stage = g_i3k_game_context:getScheduleStage()
		local widgets = widget.vars
		widgets.teamRoot:setVisible(info ~= nil)
		widgets.createTeam:setVisible(info == nil and stage <= f_FIGHTTEAM_STAGE_QUALIFY)
		if info then
			local qualifyingMaxTimes = i3k_db_fightTeam_base.primaries.times
			local eventID, stateDesc = g_i3k_db.i3k_db_get_fight_team_record(true)
			local str = eventID > f_FIGHTTEAM_STAGE_QUALIFY and stateDesc or string.format(stateDesc, qualifyingMaxTimes - info.qualifyingJoinTimes)
			widgets.leftTimes:setText(str)
			widgets.teamName:setText(info.name)
			widgets.scoreTxt:setText(i3k_get_string(1220, info.score))
			self:loadFightTeamMemberInfo(widgets, info)
			widgets.checkRecordBtn:onClick(self, self.onCheckBtn)
		end
		widgets.needLvlTxt:setVisible(info == nil and stage <= f_FIGHTTEAM_STAGE_QUALIFY)
	end
	self:loadQualifyingBtnState()
end

function wnd_arena_list:loadFightTeamMemberInfo(widgets, info)
	local roleID = g_i3k_game_context:GetRoleId()
	widgets.teamScroll:removeAllChildren()
	local membersInfo = g_i3k_db.i3k_db_sort_fightteam_member(info.members, g_i3k_game_context:getFightTeamLeaderID(), 1)
	local allWidget = widgets.teamScroll:addChildWithCount(WUDAOHUIDWT, 5, 5)
	for i, e in ipairs(allWidget) do
		local node = e.vars
		node.playerRoot:setVisible(membersInfo[i] ~= nil)
		node.addRoot:setVisible(membersInfo[i] == nil)
		if membersInfo[i] then
			local details = membersInfo[i].details
			local profile = details.overview
			local online = details.online
			local state = details.state
			node.leaderIcon:setVisible(info.leader == profile.id)
			node.typeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[profile.type].classImg))
			node.iconType:setImage(g_i3k_get_head_bg_path(profile.bwType, profile.headBorder))
			node.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(profile.headIcon, false))
			node.lvlTxt:setText(profile.level)
			node.playerName:setText(profile.name)
			node.playerPower:setText(profile.fightPower)
			node.isSign:setVisible(state == g_FIGHTTEAM_TOURNAMENT_MATCH) --签到
			node.kickBtn:setVisible(info.leader ~= profile.id and g_i3k_game_context:getIsFightTeamLeader())
			if online == 0 then
				node.playerBgIcon:disableWithChildren()
			end
			node.kickBtn:onClick(self, self.onKickBtn, profile)
			node.playerBtn:onClick(self, self.onPlayerBtn, profile)
			node.playerRoot:setTag(profile.id)
		else
			node.addRoot:onClick(self, self.onAddFriend)
		end
	end
	widgets.teamScroll:stateToNoSlip()
end

function wnd_arena_list:loadFightTeamHonor()
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		widget.vars.personalHonor:setText(i3k_get_string(1221, g_i3k_game_context:getFightTeamHonor()))
	end
end

function wnd_arena_list:getFightTeamMemberWidget(roleID)
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		local allScrollWidget = widget.vars.teamScroll:getAllChildren()
		local node = nil
		for _, v in ipairs(allScrollWidget) do
			if v.vars.playerRoot:getTag() == roleID then
				node = v
			end
		end
		return node
	end
	return nil
end

--是否在线
function wnd_arena_list:updateMemberOnline(roleID, online)
	local node = self:getFightTeamMemberWidget(roleID)
	if node then
		if online == 0 then
			node.vars.playerBgIcon:disableWithChildren()
		else
			node.vars.playerBgIcon:enableWithChildren()
		end
	end
end

-- 队员签到
function wnd_arena_list:updateMemberState(roleID, state)
	local node = self:getFightTeamMemberWidget(roleID)
	if node then
		node.vars.isSign:setVisible(state == g_FIGHTTEAM_TOURNAMENT_MATCH)
	end
end

function wnd_arena_list:loadQualifyingBtnState()
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		local info = g_i3k_game_context:getFightTeamInfo()
		local  stage = g_i3k_game_context:getScheduleStage()
		widget.vars.qualifyingBtn:setVisible(info ~= nil and stage == f_FIGHTTEAM_STAGE_QUALIFY)
		local matchType, actType = g_i3k_game_context:getMatchState()
		if matchType == g_FIGHT_TEAM_MATCH and actType == g_FIGHTTEAM_QUALIFYING_MATCH then
			widget.vars.qualifyingTxt:setText(i3k_get_string(1222))
			widget.vars.qualifyingBtn:onClick(self, self.onStopMatchOperation, g_FIGHT_TEAM_MATCH)
			if not g_i3k_game_context:getIsFightTeamLeader() then
				widget.vars.qualifyingBtn:disableWithChildren()
			end
		else
			widget.vars.qualifyingTxt:setText(i3k_get_string(1223))
			widget.vars.qualifyingBtn:onClick(self, self.onQualifyingBtn) -- 海选匹配
		end
	end
end

function wnd_arena_list:loadFightTeamGroup(group)
	self._fightTeamIsWin = false
	self._isShowSign = true
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		widget.vars.signRoot:setVisible(group ~= nil)
		widget.vars.signBtn:onClick(self, self.onSignBtn)
		if g_i3k_game_context:getIsSelfSign() then
			widget.vars.signBtn:disableWithChildren()
		end
		if group and group.group then
			widget.vars.goupLabel:setText(g_i3k_db.i3k_db_get_fightTeam_group_name(group.group))
			widget.vars.goupLabel:show()
		end
		if group and group.teams then
			local teams = self:sortGroupTeams(group.teams)
			widget.vars.emptyRoot:setVisible(#teams < 2) -- 轮空显示
			for i = 1, 2 do
				widget.vars["playerRoot"..i]:setVisible(teams[i] ~= nil)
				if teams[i] then
					local data = teams[i].data
					local team = data.team
					local state =  data.state
					local profile = team.leader
					widget.vars["iconType"..i]:setImage(g_i3k_get_head_bg_path(profile.bwType, profile.headBorder))
					widget.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_head_icon_path(profile.headIcon, false))
					widget.vars["lvlTxt"..i]:setText(profile.level)
					widget.vars["teamName"..i]:setText(team.name)
					widget.vars["signIcon"..i]:setVisible(state == f_FIGHT_RESULT_JOIN)
					widget.vars["resultIcon"..i]:setVisible(state == f_FIGHT_RESULT_WIN or state == f_FIGHT_RESULT_LOSE)
					local resultIconID = state == f_FIGHT_RESULT_WIN and 5052 or 5053
					if i == 1 and state == f_FIGHT_RESULT_WIN then --自己战队胜利
						self._fightTeamIsWin = true
					end
					if state == f_FIGHT_RESULT_WIN then
						self._isShowSign = false
					end
					widget.vars["resultIcon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(resultIconID))
					if team.id ~= g_i3k_game_context:getFightTeamID() then
						widget.vars["playerBtn"..i]:onClick(self, self.onCheckFightTeam, team.id)
					end
				end
			end
		end
	end
end

function wnd_arena_list:sortGroupTeams(teams)
	local tmp = {}
	for i, e in ipairs(teams) do
		local order = i
		if e.team.id == g_i3k_game_context:getFightTeamID() then
			order = order + 1000
		end
		table.insert(tmp, {data = e, order = order})
	end

	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

function wnd_arena_list:onCheckFightTeam(sender, fighetTeamID)
	i3k_sbean.request_fightteam_querym_req(fighetTeamID)
end

-- 刷新队友签到状态
function wnd_arena_list:reloadEnemySignState(state)
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		if widget.vars.signRoot:isVisible() and widget.vars.playerRoot2:isVisible() then
			widget.vars.signIcon2:setVisible(state == f_FIGHT_RESULT_JOIN)
		end
	end
end

function wnd_arena_list:updateGroupSignIcon()
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		if widget.vars.signRoot:isVisible() then
			widget.vars.signIcon1:setVisible(g_i3k_game_context:getFightTeamMemberIsSign())
			if g_i3k_game_context:getIsSelfSign() then
				widget.vars.signBtn:disableWithChildren()
			end
		end
	end
end

function wnd_arena_list:onAddFriend(sernder)
	if g_i3k_game_context:getMatchState() == g_FIGHT_TEAM_MATCH then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1244))
	end

	if not g_i3k_game_context:getIsFightTeamLeader() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1224))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_InviteFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteFriends, 5)
	i3k_sbean.fightteam_queryf()
end

function wnd_arena_list:onCreateFightTeam(sender)
	if g_i3k_game_context:getFightTeamJoinTimes() >= i3k_db_fightTeam_base.team.maxJoinTimes then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1254,  i3k_db_fightTeam_base.team.maxJoinTimes) )
	end

	g_i3k_ui_mgr:OpenUI(eUIID_CreateFightTeam)
	g_i3k_ui_mgr:RefreshUI(eUIID_CreateFightTeam)
end

function wnd_arena_list:onQualifyingBtn(sender)
	if g_i3k_game_context:getScheduleStage() > f_FIGHTTEAM_STAGE_QUALIFY then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1225))
	end

	if not g_i3k_game_context:getIsFightTeamLeader() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1226))
	end

	local qualifyingMaxTimes = i3k_db_fightTeam_base.primaries.times
	local fightTeamInfo = g_i3k_game_context:getFightTeamInfo()
	if qualifyingMaxTimes - fightTeamInfo.qualifyingJoinTimes <= 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1227, qualifyingMaxTimes))
	end

	if g_i3k_game_context:getMatchState() ~= 0 then -- 等待其他活动无法进行匹配
		return self:inMatchingPopText()
	end

	i3k_sbean.fightteam_joinqualifying_request()
end

function wnd_arena_list:onKickBtn(sender, profile)
	if g_i3k_game_context:getMatchState() == g_FIGHT_TEAM_MATCH then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1244))
	end
	local fun = (function(ok)
		if ok then
			i3k_sbean.fightteam_kick_requst(profile.id)
		end
	end)
	local cfg = i3k_db_fightTeam_base.team
	local desc = i3k_get_string(1228, profile.name, cfg.kickCD, i3k_db_fightTeam_base.team.maxJoinTimes)
	g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", desc, fun)
end

function wnd_arena_list:onCheckBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FightTeamRecord)
	g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamRecord)
end

function wnd_arena_list:onScheduleBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FightTeamSchedule)
	g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamSchedule)
end

function wnd_arena_list:onSignBtn(sender)
	if self._fightTeamIsWin then
		return g_i3k_ui_mgr:PopupTipMessage("您即将晋级")
	elseif not self._isShowSign then
		return g_i3k_ui_mgr:PopupTipMessage("胜负已分")
	end

	if g_i3k_game_context:getMatchState() ~= 0 or g_i3k_game_context:IsInRoom() then -- 等待其他活动无法进行匹配
		return self:inMatchingPopText()
	end

	local fun = function()
	i3k_sbean.fightteam_joinknockout()
	end
	g_i3k_game_context:CheckMulHorse(fun, false, 1756)
end

function wnd_arena_list:onUpdateSignTime(dTime)
	local widget = self:getWidget(g_FIGHT_TEAM_STATE)
	if widget then
		if widget.vars.signRoot:isVisible() then
			local joinTime, fightTime, endTime = g_i3k_game_context:getFightTeamStartTime()
			if joinTime ~= 0 then
				local condition = i3k_game_get_time() > joinTime and i3k_game_get_time() < fightTime
				widget.vars.signBtn:setVisible(self._fightTeamIsWin or condition)
				widget.vars.signTxt:setText(self._fightTeamIsWin and "您将晋级" or "签到")
				widget.vars.signTime:setVisible(self._isShowSign and condition)
				if self._isShowSign and condition then
					widget.vars.signTime:setText(i3k_get_format_time_to_show(fightTime - i3k_game_get_time()))
				end
			else
				widget.vars.signTime:hide()
				widget.vars.signTxt:hide()
				widget.vars.signBtn:hide()
			end
		end
	end
end

function wnd_arena_list:onGuardBtn(sender)
	if g_i3k_game_context:getMatchState() ~= 0 then -- 等待其他活动无法进行匹配
		return self:inMatchingPopText()
	end
	i3k_sbean.tournament_guard()
end

-----------------------------武道大会 end-----------------------------

-----------------------------PVE start -----------------------------
function wnd_arena_list:loadGlobalPve(startTime, endTime, openDays)
	self:setState(g_GLOBAL_PVE_STATE)
	local widget = require(f_pagePath[self._state])()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self._globalPveWidget = widgets
	self:setGlobalPveInfo(widgets, startTime, endTime, openDays)
	self._globalPveWidget.peaceRule:onClick(self, self.onGlobalPveRule, g_FIELD_SAFE_AREA) --和平区规则
	self._globalPveWidget.battleRule:onClick(self, self.onGlobalPveRule, g_FIELD_KILL) --对战区规则
	self:setTabBarLight()
	self._layout.vars.scroll:jumpToChildWithIndex(self._state)
end

function wnd_arena_list:setGlobalPveInfo(widgets, startTime, endTime, openDays)
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local openDay = {}
	for k, v in pairs(openDays) do
		table.insert(openDay, k)
	end
	self._globalPveTimeInfo = {startTime = startTime, endTime = endTime, openDay = openDay}
	widgets.need_lvl:setText(i3k_db_crossRealmPVE_cfg.levelLimit)
	widgets.need_lvl:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= i3k_db_crossRealmPVE_cfg.levelLimit))
	widgets.have_times:setText(i3k_get_time_show_text(startTime).."~"..i3k_get_time_show_text(endTime)) -- 开启时间段
	local isInTime = timeStamp >= g_i3k_get_GMTtime(g_i3k_get_day_time(startTime)) and timeStamp <= g_i3k_get_GMTtime(g_i3k_get_day_time(endTime))
	widgets.have_times:setTextColor(g_i3k_get_cond_color(isInTime))
	widgets.join_time:setText(i3k_get_activity_open_desc(openDay))-- 开启日期 时间段
	widgets.join_time:setTextColor(g_i3k_get_cond_color(g_i3k_db.i3k_get_activity_is_open(openDay)))
	widgets.join:onClick(self, self.onPVEJoinBtn)
end

function wnd_arena_list:onPVEJoinBtn(sender)
	if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage("您正在报名其他活动，不能参与此活动")
		return
	end

	local function func()
		i3k_sbean.globalpve_join()
	end

	local func1 = function () -- 队伍
		if g_i3k_game_context:GetTeamId() ~= 0 then
			local fun = (function(ok)
				if not ok then
					return
				else
					func()
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(68), fun)
			return
		else
			return func()
		end
		-- return func()
	end

	g_i3k_game_context:CheckMulHorse(func1)
end

function wnd_arena_list:onUpdategGlobalTime(dTime)
	if self._state == g_GLOBAL_PVE_STATE and self._globalPveWidget and self._globalPveTimeInfo.openDay then
		local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
		local isOpen = i3k_get_activity_is_open(self._globalPveTimeInfo.openDay)
		local isInTime = timeStamp >= g_i3k_get_GMTtime(g_i3k_get_day_time(self._globalPveTimeInfo.startTime)) and timeStamp <= g_i3k_get_GMTtime(g_i3k_get_day_time(self._globalPveTimeInfo.endTime))
		local condition = isOpen and isInTime
		self._globalPveWidget.not_open:setVisible(not condition)
		self._globalPveWidget.countdown_desc:setVisible(condition)
		self._globalPveWidget.countdown:setVisible(condition)
		if condition then
			self._globalPveWidget.countdown:setText(i3k_get_time_show_text(g_i3k_get_GMTtime(g_i3k_get_day_time(self._globalPveTimeInfo.endTime) - timeStamp)))
		end
		self._globalPveWidget.have_times:setTextColor(g_i3k_get_cond_color(condition))
		if condition then
			self._globalPveWidget.join:enableWithChildren()
		else
			self._globalPveWidget.join:disableWithChildren()
		end
	end
end

function wnd_arena_list:onGlobalPveRule(sender, ruleType)
	g_i3k_ui_mgr:OpenUI(eUIID_GlobalPveRule)
	g_i3k_ui_mgr:RefreshUI(eUIID_GlobalPveRule, ruleType)
end
-----------------------------PVE end-----------------------------

-----------------------------城战 start -----------------------------
function wnd_arena_list:loadDefenceWar()
	self:setState(g_DEFENCE_WAR_STATE)
	local widget = require(f_pagePath[self._state])()
	self:addChildWidget(widget)
	local widgets = widget.vars

	self:setDefenceBtn(widgets)
	self:setDefenceWarInfo()

	self:setTabBarLight()
	self._layout.vars.scroll:jumpToChildWithIndex(self._state)
	self:showFirstRewardBtn(widget, FIRST_CLEAR_REWARD_CITY)
end

-- 设置按钮点击事件
function wnd_arena_list:setDefenceBtn(widgets)
	widgets.toHelp:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_Help)
		g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(5327, i3k_db_defenceWar_cfg.joinCnt))
	end)
	widgets.bidShowBtn:onClick(self, function()
		g_i3k_logic:OpenDefenceWarBidResultUI()
	end)
	widgets.rewardBtn:onClick(self, function()
		g_i3k_logic:OpenDefenceWarRewardUI(self._defenceWarInfo.kings)
	end)
	--widgets.blessBtn:onClick(self, self.openCityLight)
end

-- 存一下同步的数据
function wnd_arena_list:syncDefenceWarInfo(citySign, cityBid, cityPve, cityPvp, kings)
	self._defenceWarInfo.citySign = citySign
	self._defenceWarInfo.cityBid = cityBid
	self._defenceWarInfo.cityPve = cityPve
	self._defenceWarInfo.cityPvp = cityPvp
	self._defenceWarInfo.kings = kings
end

function wnd_arena_list:defenceWarSignInSuccess(cityID)
	self._defenceWarInfo.citySign[cityID] = g_DEFENCE_WAR_SIGN_MINE
end

--是否已报名
function wnd_arena_list:isDefenceWarSignIn()
	for _, v in pairs(self._defenceWarInfo.citySign) do
		if v == g_DEFENCE_WAR_SIGN_MINE then
			return true
		end
	end
	return false
end

--是否已竞标
function wnd_arena_list:isDefenceWarBid()
	for _, v in pairs(self._defenceWarInfo.cityBid) do
		if v == g_DEFENCE_WAR_BID_MINE then
			return true
		end
	end
	return false
end

--pve是否结束
function wnd_arena_list:isDefenceWarPveEnd()
	local signCityId = g_i3k_db.i3k_db_get_defence_war_mySignCityID(self._defenceWarInfo.citySign)
	if not signCityId then
		return false
	end
	for k, v in pairs(self._defenceWarInfo.cityPve) do
		if k == signCityId and v == g_DEFENCE_WAR_FINISH then
			return true
		end
	end
	return false
end

--pvp是否结束
function wnd_arena_list:isDefenceWarPvpEnd()
	local bidCityId = g_i3k_game_context:getDefenceWarPveCity() --获取自己pve占据的城池
	if not bidCityId then
		bidCityId = g_i3k_db.i3k_db_get_defence_war_myBidCityID(self._defenceWarInfo.cityBid)
		if not bidCityId then
			return false
		end
	end
	for k, v in pairs(self._defenceWarInfo.cityPvp) do
		if k == bidCityId and v == g_DEFENCE_WAR_FINISH then
			return true
		end
	end
	return false
end

function wnd_arena_list:setDefenceWarInfo()
	local widget = self:getWidget(g_DEFENCE_WAR_STATE)
	if not widget then
		self:setState(g_DEFENCE_WAR_STATE)
		widget = require(f_pagePath[self._state])()
		self:addChildWidget(widget)
	end
	local widgets = widget.vars

	local warState = g_i3k_db.i3k_db_get_defence_war_state()

	widgets.bidShowBtn:setVisible(warState == g_DEFENCE_WAR_STATE_BID_SHOW)

	local descStr = self:getDefenceWarStateDesc(warState)
	widgets.desc:setText(descStr)
	widgets.state:setText(DEFENCE_WAR_STATE[warState].state)

	local desc = self:getDefenceWarDesc(warState)
	widgets.desc2:setVisible(desc ~= "")
	widgets.desc2:setText(desc)

	self:setDefenceWarImgState(widgets, warState)
	self:setDefenceWarJoinBtnState(widgets, warState)
	self:setDefenceWarProgressBar(widgets, warState)

	--如果是和平期则显示城池归属
	widgets.schedule:setVisible(warState ~= g_DEFENCE_WAR_STATE_PEACE)
	widgets.scroll:setVisible(warState == g_DEFENCE_WAR_STATE_PEACE)
	if warState == g_DEFENCE_WAR_STATE_PEACE then
		self:setCityBelong(widgets.scroll)
	end
end

function wnd_arena_list:setCityBelong(scroll)
	scroll:removeAllChildren()
	for cityID, v in ipairs(i3k_db_defenceWar_city) do
		local ui = require("ui/widgets/chengzhanhpqt")()
		ui.vars.CityImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconSign))
		ui.vars.CityName:setText(v.name)
		local sectInfo = self._defenceWarInfo.kings[cityID]
		local sectName = sectInfo and sectInfo.name or i3k_get_string(5318)
		ui.vars.SectName:setText(sectName)
		scroll:addItem(ui)
	end
end

function wnd_arena_list:setDefenceWarProgressBar(widgets, warState)
	local percent = 0

	if warState <= g_DEFENCE_WAR_STATE_NONE then
		percent = 0
	elseif warState <= g_DEFENCE_WAR_STATE_SIGN_UP then
		percent = 10
	elseif warState <= g_DEFENCE_WAR_STATE_PVE then
		percent = 30
	elseif warState <= g_DEFENCE_WAR_STATE_BID then
		percent = 60
	elseif warState <= g_DEFENCE_WAR_STATE_PVP then
		percent = 90
	else
		percent = 100
	end
	widgets.progressBar:setPercent(percent)
end

function wnd_arena_list:getDefenceWarStateDesc(warState)
	local descFormat = DEFENCE_WAR_STATE[warState].descFormat
	if not descFormat then
		return ""
	end
	return g_i3k_db.i3k_db_get_defence_war_desc(warState, descFormat)
end

--设置详细报名和竞标情况
function wnd_arena_list:getDefenceWarDesc(warState)
	local factionID = g_i3k_game_context:GetFactionSectId()
	if factionID == 0 then
		return i3k_get_string(5278) --加入帮派方可参与此活动
	end
	local factionLvl = g_i3k_game_context:GetFactionLevel()
	if warState == g_DEFENCE_WAR_STATE_SIGN_UP then  --报名阶段
		if factionLvl < i3k_db_defenceWar_cfg.factionLvl then
			return i3k_get_string(5279, i3k_db_defenceWar_cfg.factionLvl) --帮派等级不足%s,不能参加此活动
		end
		if self:isDefenceWarSignIn() then
			return i3k_get_string(5280) --我帮派已经报名参加
		else
			return i3k_get_string(5281) --帮派尚未报名参加
		end
	elseif warState == g_DEFENCE_WAR_STATE_BID then  --竞标阶段
		if factionLvl < i3k_db_defenceWar_cfg.factionLvl then
			return i3k_get_string(5283, i3k_db_defenceWar_cfg.factionLvl) --我帮派等级不足%s，不符合竞标资格
		end
		if self:isDefenceWarBid() then
			return i3k_get_string(5284) --我帮派已经参与竞标
		elseif g_i3k_game_context:getDefenceWarPveCity() then
			return i3k_get_string(5289) --我帮派此轮需要守城
		else
			return i3k_get_string(5285) --我帮派尚未参与竞标
		end
	elseif warState == g_DEFENCE_WAR_STATE_PVE then  --占城阶段
		if self:isDefenceWarPveEnd() then
			return i3k_get_string(5282) --您所在帮派报名的城池，已经决出胜负
		end
	elseif warState == g_DEFENCE_WAR_STATE_PVP then  --夺城阶段
		if self:isDefenceWarPvpEnd() then
			return i3k_get_string(5286) --您所在帮派报名的夺城活动，已经决出胜负
		end
	end
	return ""
end

function wnd_arena_list:setDefenceWarImgState(widgets, warState)
	local imgName = DEFENCE_WAR_STATE[warState].img
	for i = 1, 4 do
		widgets["stateImg"..i]:hide()
		if imgName then
			widgets[imgName]:show()
		end
	end
end

function wnd_arena_list:setDefenceWarJoinBtnState(widgets, warState)
	local btnImgID = DEFENCE_WAR_STATE[warState].btnImgID
	local funcName = DEFENCE_WAR_STATE[warState].funcName
	widgets.join:setVisible(btnImgID ~= nil)
	if btnImgID then
		btnImgID, funcName = self:getDefenceWarSpecialBtnImg(warState, btnImgID, funcName)
		if funcName then
			widgets.join:enableWithChildren()
			widgets.join:onClick(self, function()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, funcName, warState)
			end)
		else
			widgets.join:disableWithChildren()
		end
		widgets.join:setImage(g_i3k_db.i3k_db_get_icon_path(btnImgID))
	end
end

function wnd_arena_list:getDefenceWarSpecialBtnImg(warState, btnImgID, funcName)
	if warState == g_DEFENCE_WAR_STATE_SIGN_UP and self:isDefenceWarSignIn() then  --已报名
		btnImgID = 7268
	elseif warState == g_DEFENCE_WAR_STATE_BID and self:isDefenceWarBid() then  --已竞标
		btnImgID = 7269
	end
	return btnImgID, funcName
end

function wnd_arena_list:openCityLight(sender)
	local factionID = g_i3k_game_context:GetFactionSectId()
	if factionID == 0 then
		return g_i3k_ui_mgr:PopupTipMessage("尚未加入帮派")
	end

	local cityID = g_i3k_game_context:getDefenceWarCurrentCityState() --获取自己占据的城池
	if not cityID then
		return g_i3k_ui_mgr:PopupTipMessage("当前我帮未占领任何城池")
	end

	local permission = g_i3k_game_context:getDefenceWarSectPermission(g_DEFENCE_WAR_PERMISSION_CITY_LIGHT)
	if not permission then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5249)) -- "没有权限开启城主之光"
	end

	local isOpen = g_i3k_game_context:isOpenCityLight()
	local tipsDesc = isOpen and i3k_get_string(5246) or i3k_get_string(5247) -- "当前本服已经存在城主之光福利，确定要开启新的吗？" or "确定在本时段为本服玩家开启城主之光吗？"
	local callback = function(ok)
		if ok then
			i3k_sbean.city_light_open(cityID)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(tipsDesc, callback)
end

function wnd_arena_list:openDefenceWarSign()
	i3k_sbean.defenceWarSignInfo()
end

function wnd_arena_list:openDefenceWarBid()
	g_i3k_logic:OpenDefenceWarBidUI()
end

function wnd_arena_list:enterDefenceWar(warState)
	if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage("您正在报名其他活动，不能参与此活动")
		return
	end
	if g_i3k_game_context:GetLevel() < i3k_db_defenceWar_cfg.playerLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5188))  --等级不足，无法参与活动
		return
	end
	local factionID = g_i3k_game_context:GetFactionSectId()
	if factionID == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5278))  --加入帮派方可参与此活动
		return
	end

	local cityID = 0 --需要进入的城池ID
	local curState = g_i3k_db.i3k_db_get_defence_war_state()
	if warState == g_DEFENCE_WAR_STATE_PVE then
		if self:isDefenceWarPveEnd() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5282))  --您所在帮派报名的城池，已经决出胜负
			return
		else
			cityID = g_i3k_db.i3k_db_get_defence_war_mySignCityID(self._defenceWarInfo.citySign)
			if not cityID then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5281))  --我帮派尚未报名参加
				return
			end
		end
	end

	if warState == g_DEFENCE_WAR_STATE_PVP then
		if self:isDefenceWarPvpEnd() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5286))  --您所在帮派报名的夺城活动，已经决出胜负
			return
		else
			cityID = g_i3k_game_context:getDefenceWarPveCity() --获取自己pve占据的城池
			if not cityID then
				cityID = g_i3k_db.i3k_db_get_defence_war_myBidCityID(self._defenceWarInfo.cityBid)
				if not cityID then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5285))  --我帮派尚未参与竞标
					return
				end
			else
				if self._defenceWarInfo.cityBid[cityID] == g_DEFENCE_WAR_BID_NONE then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5298))  --无人竞标本帮占领的城池，坐看他人龙争虎斗
					return
				end
			end
		end
	end

	--进入城战
	local function func(cityID)
		i3k_sbean.defenceWarEnter(cityID)
	end

	local func1 = function () -- 队伍
		if g_i3k_game_context:GetTeamId() ~= 0 then
			local fun = (function(ok)
				if not ok then
					return
				else
					func(cityID)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(68), fun)
			return
		else
			return func(cityID)
		end
	end

	g_i3k_game_context:CheckMulHorse(func1)
end
-----------------------------城战 end-----------------------------

function wnd_arena_list:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 5 and self._state == g_BANGPAIZHAN and self._faction_fight_widget and self._status == 0 then
		i3k_sbean.sect_fight_group_cur_status(function (state)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadfactionfightgroup", state)
		end)
		self._timeCounter = 0
	end
	if self._btnState and self._state == g_BANGPAIZHAN and self._faction_fight_widget then
		self._timeCount = self._timeCount + dTime
		if self._timeCount > 1 then
			self._btnState = false
			self._timeCount = 0
		end
	end
	if self._state==g_FORCE_WAR_STATE and self._punishtime then
		self._currentTime  = math.modf(i3k_game_get_time())
		if self._currentTime > self._punishtime and self._punishtime ~=0 then--当前时间超过惩罚时间,可以再次报名
			self._isForceWar= false
			self._widgets.punishtime:hide()
			self._widgets.punishTxt:hide()
			self._widgets.punishtime:setTextColor(g_i3k_get_green_color())
			self._widgets.punishTxt:setTextColor(g_i3k_get_green_color())
			local children = self._widgets.scroll:getAllChildren()
			for i,v in ipairs(children) do
				if v.vars.isAble then
					v.vars.join:enableWithChildren()
				end
			end
		elseif self._isDropOut and self._currentTime <= self._punishtime then
			local min = math.modf(( self._punishtime - self._currentTime )  /60)
			local sec =  (self._punishtime - self._currentTime )  %60
			local str = string.format("%d分%d秒",min,sec)--你刚刚逃离了势力战场，暂时无法报名（剩余%d分%d秒）%02d:%02d
			self._widgets.punishtime:setText(str)
			local children = self._widgets.scroll:getAllChildren()
			for i,v in ipairs(children) do
				if v.vars.isAble then
					v.vars.join:disableWithChildren()
				end
			end
		end
	end

	if self._state == g_DEMON_HOLE_STATE and self._demonHoleWidget then
		local _, closeTimeStamp, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(i3k_db_demonhole_base.openTimes)
		local isOpen = g_i3k_db.i3k_get_activity_is_open(i3k_db_demonhole_base.openDay)
		local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
		local condition = isOpen and isInTime
		self._demonHoleWidget.not_open:setVisible(not condition)
		self._demonHoleWidget.countdown_desc:setVisible(condition)
		self._demonHoleWidget.countdown:setVisible(condition)
		if condition then
			self._demonHoleWidget.countdown:setText(i3k_get_time_show_text(closeTimeStamp - timeStamp))
		end
		self._demonHoleWidget.have_times:setTextColor(g_i3k_get_cond_color(condition))
		if condition then
			self._demonHoleWidget.join:enableWithChildren()
		else
			self._demonHoleWidget.join:disableWithChildren()
		end
	elseif self._state == g_BANGPAIZHAN and self._faction_fight_widget then
		local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
		local year = os.date("%Y", timeStamp )
		local month = os.date("%m", timeStamp )
		local day = os.date("%d", timeStamp)
		local totalDay = g_i3k_get_day(i3k_game_get_time())
		local week = math.mod(g_i3k_get_week(totalDay), 7)
		local isOpen = i3k_get_activity_is_open(i3k_db_faction_fight_cfg.commonrule.openday)
		local isOpendata =g_i3k_db.i3k_db_is_open_bangpaizhan()
		local allStart = string.split(i3k_db_faction_fight_cfg.timebucket[1].applytime, ":")
		local allOver = string.split(i3k_db_faction_fight_cfg.timebucket[3].endfight, ":")
		self._faction_fight_widget.have_times:setText(allStart[1]..":"..allStart[2].."~"..allOver[1]..":"..allOver[2])
		if isOpen and isOpendata then
			for i = 1, #i3k_db_faction_fight_cfg.timebucket do
				local startTime = string.split(i3k_db_faction_fight_cfg.timebucket[i].applytime, ":")--报名开始时间
				local beginTime = string.split(i3k_db_faction_fight_cfg.timebucket[i].beginfight, ":")--战斗开始时间
				local overTime = string.split(i3k_db_faction_fight_cfg.timebucket[i].endfight, ":")--战斗结束时间
				local openTime = os.time({year = year, month = month, day = day, hour = startTime[1], min = startTime[2], sec = startTime[3]})
				local fightTime = os.time({year = year, month = month, day = day, hour = beginTime[1], min = beginTime[2], sec = beginTime[3]})
				local closeTime = os.time({year = year, month = month, day = day, hour = overTime[1], min = overTime[2], sec = overTime[3]})
				if timeStamp < fightTime and timeStamp > openTime then
					self._faction_fight_widget.not_open:setText("")
					if self._status == 1 then
						self._faction_fight_widget.join2:hide()
						self._faction_fight_widget.match:show()
						self._faction_fight_widget.countdown_desc:setText("开战倒计时：")
						self._faction_fight_widget.countdown:setText(i3k_get_time_show_text(fightTime - timeStamp))
					else
						self._faction_fight_widget.join2:show()
						self._faction_fight_widget.match:hide()
						self._faction_fight_widget.join2:enableWithChildren()
						self._faction_fight_widget.countdown_desc:setText("报名倒计时：")
						self._faction_fight_widget.countdown:setText(i3k_get_time_show_text(fightTime - timeStamp))
					end
					return
				elseif timeStamp < closeTime and timeStamp > fightTime then
					self._faction_fight_widget.join2:show()
					self._faction_fight_widget.match:hide()
					self._faction_fight_widget.join2:enableWithChildren()
					self._faction_fight_widget.not_open:setText("")
					self._faction_fight_widget.countdown_desc:setText("战场倒计时：")
					self._faction_fight_widget.countdown:setText(i3k_get_time_show_text(closeTime - timeStamp))
					return
				end
			end
		end
		self._faction_fight_widget.join2:show()
		self._faction_fight_widget.match:hide()
		self._faction_fight_widget.join2:disableWithChildren()
		self._faction_fight_widget.not_open:setText("尚未开启")
		self._faction_fight_widget.countdown_desc:setText("")
		self._faction_fight_widget.countdown:setText("")
	elseif self._state == g_MAZE_BATTLE_STATE and self.battleMazeWidget then
		self:onBattleMazeUpdate(dTime)
	elseif self._state == g_BATTLE_DESERT and self.battleDesertWidget then
		self:onBattleDesertUpdate(dTime)
	end
	self:onUpdateSignTime(dTime)
	self:onUpdategGlobalTime(dTime)
	if self._timeCounter > 5 and self._state == g_DEFENCE_WAR_STATE then
		local callback = function()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "setDefenceWarInfo")
		end
		i3k_sbean.defenceWarInfo(callback)
		self._timeCounter = 0
	end
end

function wnd_arena_list:onHide()
	g_i3k_ui_mgr:CloseUI(eUIID_FightTeamList)
end
function wnd_arena_list:showFirstRewardBtn(widgets, id)
	local isShowFinishBtn, isShowRedPoint = g_i3k_game_context:checkIsShowFinishBtn(id)
	widgets.vars.finish_btn:setVisible(isShowFinishBtn)
	widgets.vars.finish_red_point:setVisible(isShowRedPoint)
	widgets.vars.finish_btn:onTouchEvent(self, self.onFinishBtnTouch, {['btn'] = widgets.vars.finish_btn, ['id'] = id})
	local finishBtnIcon = i3k_db_first_clear_reward.RewardConfig[id].icon
	widgets.vars.finish_btn:setImage(g_i3k_db.i3k_db_get_icon_path(finishBtnIcon))
end
function wnd_arena_list:onFinishBtnTouch(sender, eventType, args)
	if eventType == ccui.TouchEventType.began then
		args.btn:stateToPressed()
	elseif eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FirstClearReward, args.id)
		args.btn:stateToNormal()
	end
end
function wnd_create(layout, ...)
	local wnd = wnd_arena_list.new()
	wnd:create(layout, ...)
	return wnd;
end

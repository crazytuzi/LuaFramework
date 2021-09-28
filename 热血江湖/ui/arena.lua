-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arena = i3k_class("wnd_arena", ui.wnd_base)

local f_redWordColor	= "FFFF0000"
local f_greenWordColor	= "FF029133"
local f_rankNow			= 0

function wnd_arena:ctor()
	self._info = nil
	self._canChallenge = true
end

function wnd_arena:configure()
	local txImage = self._layout.vars.icon
	
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local headIcon = roleInfo.curChar._headIcon
	self._layout.vars.iconType:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(headIcon, g_i3k_db.eHeadShapeCircie);
	if hicon and hicon > 0 then
		txImage:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
	end
	
	self._layout.vars.refresh:onClick(self, self.onRefresh)
	self._layout.vars.shop:onClick(self, self.toArenaShop)
	self._layout.vars.rankBtn:onClick(self, self.toArenaRank)
	self._layout.vars.integral:onClick(self, self.toIntegral)
	self._layout.vars.battleInfo:onClick(self, self.toBattleInfo)
	self._layout.vars.defensive:onClick(self, self.setDefensive)
	
	self._layout.vars.coolRoot:hide()
	
	self._layout.vars.addTimes:onClick(self, self.toAddTimes)
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_arena:onShow()
	
end

function wnd_arena:refresh(info, bestRise)
	self:setLogsRed(g_i3k_game_context:getArenaLogsRed())
	self:setInteralRed(g_i3k_game_context:getArenaInteralRed())
	
	self._layout.vars.toHelp:onClick(self, self.toHelpUI, info)
	
	local usercfg = g_i3k_game_context:GetUserCfg()
	
	
	local lastTime = info.lastFightTime
	
	local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
	if lastTime>0 and timeNow-lastTime<i3k_db_arena.arenaCfg.attackCoolTime then
		self._canChallenge = false
		g_i3k_game_context:StartAttackCoolTime(i3k_db_arena.arenaCfg.attackCoolTime - (timeNow - lastTime))
	end
	--[[local coolTime = usercfg:GetArenaCoolTime()
	if coolTime.cool>0 then
		local coolNeed = g_i3k_get_GMTtime(i3k_game_get_time())-coolTime.thatTime
		if coolNeed>=coolTime.cool then
			usercfg:SetArenaCoolTime(0)
		else
			g_i3k_game_context:StartAttackCoolTime(coolTime.cool - coolNeed)
		end
	end--]]
	self:setData(info, bestRise)
end

function wnd_arena:setData(info, bestRise)
	self._info = info
	local logic = i3k_game_get_logic()
	local player = logic:GetPlayer()
	local hero = nil;
	if player then
		hero = player:GetHero()
	end
	self._layout.vars.name:setText(hero._name)
	self._layout.vars.level:setText(hero._lvl)
	local power = hero:Appraise()

	local timeUsed = info.timeUsed
	local timeBuyed = info.timeBuyed
	local lastFightTime = info.lastFightTime
	local pets = info.pets
	local petPower = 0
	
	g_i3k_game_context:SetMyPower(power)

	local totalTimes = i3k_db_arena.arenaCfg.freeTimes+info.timeBuyed
	self._layout.vars.challengeTimeLabel:setText(totalTimes-info.timeUsed.."/"..totalTimes)
	g_i3k_game_context:SetArenaChallengeTimes(timeUsed, totalTimes)
	if totalTimes-info.timeUsed==0 then
		self._layout.vars.challengeTimeLabel:setTextColor(f_redWordColor)
	else
		self._layout.vars.challengeTimeLabel:setTextColor(f_greenWordColor)
	end
	
	self._layout.vars.rankLabel:setText(info.rankNow)
	f_rankNow = info.rankNow
	
	local playPetCount = 0
	for i,v in pairs(pets) do
		local mercenaryPower = g_i3k_game_context:getBattlePower(v)
		petPower = petPower + mercenaryPower
		playPetCount = playPetCount + 1
	end
	self:setEnemyData(info)
	self:reloadPowerLabel(power+petPower)
	self._layout.vars.defensiveRed:hide()
	if playPetCount<3 then
		local allPets, playPets = g_i3k_game_context:GetYongbingData()
		local hasPetsCount = 0
		for i,v in pairs(allPets) do
			hasPetsCount = hasPetsCount + 1
		end
		self._layout.vars.defensiveRed:setVisible(hasPetsCount>playPetCount)
	end
	
	if bestRise then
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaRankBest)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArenaRankBest, info.rankBestOld)
	end
end

function wnd_arena:setEnemyData(info)
	
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
	local scroll = self._layout.vars.scroll
	scroll:setBounceEnabled(false)
	local count = 0
	for i,v in ipairs(enemies) do
		count = count + 1
	end
	
	local children = scroll:addChildWithCount("ui/widgets/1v1jjct", count, count)
	for i,v in ipairs(children) do
		local enemyData = {}
		enemyData.rank = enemies[i].rank
		enemyData.role = enemies[i].role
		enemyData.pets = enemies[i].pets
		table.insert(enemyTable, enemyData)
		
		v.vars.rank:setText(enemyData.rank)
		v.vars.lvl:setText(enemyData.role.level)
		v.vars.name:setText(enemyData.role.name)
		local petsPower = 0;
		if enemies[i].role.id<0 then
			local robot = i3k_db_arenaRobot[math.abs(enemies[i].role.id)]
			enemyData.role.fightPower = robot.power
		else
			for i,v in pairs(enemyData.pets) do
				petsPower = petsPower + v.fightPower
			end
		end

		v.vars.power:setText(enemyData.role.fightPower + petsPower)
		v.vars.zhiyeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[enemyData.role.type].classImg))
		v.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(enemyData.role.headIcon, false))
		v.vars.iconType:setImage(g_i3k_get_head_bg_path(enemyData.role.bwtype, enemyData.role.headBorder))
		v.vars.icon:setTag(i+5000)
		v.vars.icon:onClick(self, self.toEnemyLineup)
		v.vars.challenge:setTag(i+1000)
		v.vars.challenge:onClick(self, self.challengeEnemy)
	end
	g_i3k_game_context:SetArenaEnemys(enemyTable)
end

function wnd_arena:challengeEnemy(sender)
	if self._canChallenge then
		local tag = sender:getTag()-1000
		local enemys = g_i3k_game_context:GetArenaEnemys()
		local enemy = enemys[tag]
		-- local view = i3k_sbean.arena_view_req.new()
		-- view.rid = enemy.id
		-- view.enemy = enemy
		-- view.openId = eUIID_ArenaSetBattle
		-- i3k_game_send_str_cmd(view, i3k_sbean.arena_view_res.getName())
		if enemy then
			local canUseTimeString = self._layout.vars.challengeTimeLabel:getText()
			local canUseTime = string.sub(canUseTimeString, 0, 1)
			if tonumber(canUseTime)==0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(131))
			else
				g_i3k_ui_mgr:OpenUI(eUIID_ArenaSetBattle)
				g_i3k_ui_mgr:RefreshUI(eUIID_ArenaSetBattle, enemy.role, enemy.rank, enemy.pets,  self._info.rankNow)
			end
		end
	else
		local tips = string.format("请耐心等待冷却或点击重置")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end
function wnd_arena:onRefresh(sender)
	local refresh = i3k_sbean.arena_refresh_req.new()
	i3k_game_send_str_cmd(refresh, i3k_sbean.arena_refresh_res.getName())
end

function wnd_arena:toArenaRank(sender)
	local rank = i3k_sbean.arena_ranks_req.new()
	rank.rankNow = f_rankNow
	i3k_game_send_str_cmd(rank, i3k_sbean.arena_ranks_res.getName())
end

function wnd_arena:toArenaShop(sender)
	local syncShop = i3k_sbean.arena_shopsync_req.new()
	i3k_game_send_str_cmd(syncShop, i3k_sbean.arena_shopsync_res.getName())
end

function wnd_arena:toEnemyLineup(sender)
	local tag = sender:getTag()-5000
	local enemys = g_i3k_game_context:GetArenaEnemys()
	local enemy = enemys[tag]
	if enemy then
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaEnemyLineup)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArenaEnemyLineup, enemy.role, enemy.pets)
	end
end

function wnd_arena:setDefensive(sender)
	self._layout.vars.defensiveRed:hide()
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaSetLineup)
	local pets = g_i3k_game_context:GetArenaDefensive()
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaSetLineup, pets)
end

function wnd_arena:setLogsRed(isShow)
	self._layout.vars.logsRed:setVisible(isShow)
end

function wnd_arena:toBattleInfo(sender)
	local battleInfo = i3k_sbean.arena_log_req.new()
	i3k_game_send_str_cmd(battleInfo, i3k_sbean.arena_log_res.getName())
end

function wnd_arena:setInteralRed(isShow)
	self._layout.vars.interalRed:setVisible(isShow)
end

function wnd_arena:toIntegral(sender)
	local syncIntegral = i3k_sbean.arena_scoresync_req.new()
	i3k_game_send_str_cmd(syncIntegral, i3k_sbean.arena_scoresync_res.getName())
end

function wnd_arena:toAddTimes(sender)
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
		descText = string.format("是否花费<c=green>%d元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次", needDiamond, maxBuyTimes-timeBuyed)
		
		local function callback(isOk)
			if isOk then
				local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
				if haveDiamond > needDiamond then
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

function wnd_arena:resetCoolTime(sender)
	local bindDiamond = g_i3k_game_context:GetDiamondCanUse(false)
	if bindDiamond>i3k_db_arena.arenaCfg.cleanCoolDiamond then
		local reset = i3k_sbean.arena_resetcool_req.new()
		i3k_game_send_str_cmd(reset, "arena_resetcool_res")
	else
		local tips = string.format("%s", "您的绑定元宝不足以重置挑战时间")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

function wnd_arena:toHelpUI(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaHelp)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaHelp, info)
end

function wnd_arena:reloadPowerLabel(power)
	self._layout.vars.powerLabel:setText(power)
end

function wnd_arena:buyTimesCB(haveTimes, totalTimes)
	self._layout.vars.challengeTimeLabel:setText(haveTimes.."/"..totalTimes)
	self._layout.vars.challengeTimeLabel:setTextColor("FF00FF00")
	g_i3k_ui_mgr:PopupTipMessage("购买成功")
end

function wnd_arena:cool(coolTime)
	self._canChallenge = false
	self._layout.vars.btnName:setText("重置")
	self._layout.vars.refresh:onClick(self, self.resetCoolTime)
	
	self._layout.vars.coolRoot:show()
	self._layout.vars.addTimes:hide()
	self._layout.vars.coolTimeLabel:setText(os.date("%M:%S", math.ceil(coolTime)))
	local needCount = i3k_db_arena.arenaCfg.cleanCoolDiamond
	local needText = string.format("x%d", needCount)
	self._layout.vars.needDiamond:setText(needText)
end

function wnd_arena:cool2()
	self._canChallenge = true
	self._layout.vars.btnName:setText("换一换")
	self._layout.vars.refresh:onClick(self, self.onRefresh)
	self._layout.vars.coolRoot:hide()
	self._layout.vars.addTimes:show()
end

function wnd_create(layout, ...)
	local wnd = wnd_arena.new();
		wnd:create(layout, ...);

	return wnd;
end

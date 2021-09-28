------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

function i3k_sbean.sync_arena_info(callback)
	local bean = i3k_sbean.arena_sync_req.new()
	bean.__callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.arena_sync_res.getName())
end

-- 同步竞技场主界面信息
--Package:arena_sync_res
function i3k_sbean.arena_sync_res.handler(bean, req)
	local info = bean.info
	if info then
		--设置积分红点
		g_i3k_game_context:setArenaInteralRed(info.scoreReward==1)
		g_i3k_game_context:SetArenaMoney(info.point)--设置武斗币
		g_i3k_game_context:SetArenaDefensive(info.pets)--防守阵容
		local rankNow = info.rankNow
		local rankBestOld = g_i3k_game_context:GetArenaRankBest()--获取最佳排行
		local isBestRise = false--是否显示最佳排行界面
		if rankBestOld~=0 then
			if info.rankBest<rankBestOld then
				isBestRise = true
				info.rankBestOld = rankBestOld
				g_i3k_game_context:SetArenaRankBest(info.rankBest)--设置最佳名次
			end
		else
			g_i3k_game_context:SetArenaRankBest(info.rankBest)
		end
		info.lastFightTime = g_i3k_get_GMTtime(info.lastFightTime)--上次战斗时间
		--g_i3k_ui_mgr:CloseUI(eUIID_Arena_Choose)
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "OpenWithArena", info, isBestRise)
		--g_i3k_ui_mgr:RefreshUI(eUIID_ArenaList, info, isBestRise)
		
		if req and req.__callback then
			req.__callback()
		end
		g_i3k_game_context:LeadCheck()
	else
		local tips = string.format("%s", "资讯获取失败，请重试")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

---------------------------换一换功能-----------------------------
function i3k_sbean.arena_refresh_res.handler(bean, req)
	if req then
		local info = {enemies = bean.enemies, rankNow = req.rankNow}
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "setEnemyData", info)
	end
end

-------------------------排行榜----------------------------
function i3k_sbean.arena_ranks_res.handler(bean, res)
	if res then
		local ranks = bean.ranks
		local srank = res.rankNow
		if ranks then
			g_i3k_ui_mgr:OpenUI(eUIID_ArenaRank)
			g_i3k_ui_mgr:RefreshUI(eUIID_ArenaRank, srank, ranks)
		end
	end
end

-----------------------设置方式阵容-----------------------
function i3k_sbean.arena_setpets_res.handler(bean, res)
	local result = bean.ok
	if result==1 then
		local petPower = res.power
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Arena, "reloadPowerLabel", petPower)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "reloadPowerLabel", petPower)
		g_i3k_ui_mgr:CloseUI(eUIID_ArenaSetLineup)
		
		for k,v in pairs(res.pets) do
			local map = {}
			map["防守佣兵Id"] = tostring(k)
			DCEvent.onEvent("单人竞技场设置防守佣兵", map)
		end 
	else
		g_i3k_ui_mgr:PopupTipMessage("设置失败，重新退出")
	end
end

----------------------------开始战斗响应----------------------------
function i3k_sbean.arena_startattack_res.handler(bean, res)
	local result = bean.ok
	if result==1 then
		g_i3k_game_context:StartAttackCoolTime()
	elseif result==-1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(122))
	elseif result==-5 then
		local timeUsed, totalTimes = g_i3k_game_context:GetArenaChallengeTimes()
		local timeBuyed = totalTimes-i3k_db_arena.arenaCfg.freeTimes
		
		local buyTimeCfg = i3k_db_arena.arenaCfg.buyTimesNeedDiamond
		local needDiamond = buyTimeCfg[self._timeBuyed+1]
		if not needDiamond then
			needDiamond = buyTimeCfg[#buyTimeCfg]
		end
		local descText = string.format("今日挑战次数已经全部用完\n是否花费<c=green>%d元宝</c>购买1次挑战机会", needDiamond)
		local function callback(isOk)
			if isOk then
				if g_i3k_game_context:GetDiamondCanUse(false) > needDiamond then
					local buy = i3k_sbean.arena_buytimes_req.new()
					buy.times = timeBuyed+1
					buy.notOpenRet = true
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
		
	elseif result==-8 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(132))
	end
end

---------------------------同步战斗结果-------------------------------
function i3k_sbean.role_arena_result.handler(bean, res)
	local result = {selfRank = bean.selfRank, targetRank = bean.targetRank, defendingSide = bean.defendingSide}
	local win = bean.win
	if win==1 then
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaWin)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArenaWin, result)	
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaLose)
	end
end

-- 通知客户端竞技场副本开始
-- Package:role_arenamap_start
function i3k_sbean.role_arenamap_start.handler(res)
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_AREA, g_SCHEDULE_COMMON_MAPID)
end 

-- 通知客户端竞技场副本结束
-- Package:role_arenamap_end
function i3k_sbean.role_arenamap_end.handler(res)
	g_i3k_game_context:AddArenaEnterTimes()
	local world = i3k_game_get_world()
	if world then
		for k,v in pairs(world._entities[eGroupType_O]) do
			v._behavior:Set(eEBPrepareFight)
		end
	end
end 

----------------------------同步积分奖励----------------------
function i3k_sbean.arena_scoresync_res.handler(bean, res)
	local score = bean.score
	local takenScores = bean.takenScores
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaIntegral)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaIntegral, score, takenScores)
end

-------------------------领取积分奖励------------------------------------
function i3k_sbean.arena_takescore_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaIntegral, "reload", res.minScore, res.myScore, res.takenScores)
		if res.callback then
			res.callback()
		end
	else
		
	end
end

-------------------------战报-----------------------------
function i3k_sbean.arena_log_res.handler(bean, res)
	local logs = bean.logs
	
	g_i3k_game_context:setArenaLogsRed(false)
	
	for i,v in pairs(logs) do
		local fightPower = v.fightPower
		local role = v.role
		local pets = v.pets
	end
	if #logs>=1 then
		g_i3k_ui_mgr:OpenUI(eUIID_ArenaLogs)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArenaLogs, logs)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(130))
	end
end

------------------------------商城同步--------------------------
function i3k_sbean.arena_shopsync_res.handler(bean, res)
	local info = bean.info
	g_i3k_game_context:SetArenaMoney(bean.currency)
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_ARENA, bean.discount)
end

--------------------------商城刷新------------------------------
function i3k_sbean.arena_shoprefresh_res.handler(bean, req)
	local info = bean.info
	if info then
		if req.isSecondType > 0 then
			moneytype = g_BASE_ITEM_DIAMOND
		else
			moneytype = g_BASE_ITEM_ARENA_MONEY
		end
		g_i3k_game_context:UseCommonItem(moneytype, req.coinCnt, AT_USER_REFRESH_SHOP)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_ARENA, req.discount)
	else
		local tips = string.format("%s", "刷新失败，请重试")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

-------------------------------购买挑战次数回应---------------------------
function i3k_sbean.arena_buytimes_res.handler(bean, res)
	if bean.ok==1 then
		local timeUsed, totalTimes = g_i3k_game_context:GetArenaChallengeTimes()
		local haveTimes = totalTimes+1-timeUsed
		totalTimes = totalTimes+1
		g_i3k_game_context:SetArenaChallengeTimes(timeUsed, totalTimes)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "buyTimesCB", haveTimes, totalTimes)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Arena, "buyTimesCB", haveTimes, totalTimes)
		g_i3k_game_context:UseDiamond(res.needDiamond, false,AT_ARENA_BUY_TIMES)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败，请重试")
	end
end

--------------------------------重置挑战时间-------------------------------
function i3k_sbean.arena_resetcool_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:StartAttackCoolTime(0)
		g_i3k_game_context:UseDiamond(i3k_db_arena.arenaCfg.cleanCoolDiamond, false,AT_ARENA_RESET_COOL)
	else
		
	end
end

------------------------------购买商品的回应-----------------------------------
function i3k_sbean.arena_shopbuy(index, info, discount, discountCfg)
	local bean = i3k_sbean.arena_shopbuy_req.new()
	bean.seq = index
	bean.info = info
	bean.discount = discount
	bean.discountCfg = discountCfg
	i3k_game_send_str_cmd(bean, "arena_shopbuy_res")
end

function i3k_sbean.arena_shopbuy_res.handler(bean, res)
	if bean.ok==1 then
		local info = res.info
		local index = res.seq
		local shopItem = i3k_db_arenaShop[info.goods[index].id]
		local tips = i3k_get_string(189, shopItem.itemName.."*"..shopItem.itemCount)
		info.goods[index].buyTimes = 1
		local count = res.discount > 0 and (shopItem.moneyCount * res.discount / 10) or shopItem.moneyCount
		g_i3k_game_context:UseBaseItem(g_BASE_ITEM_ARENA_MONEY, math.ceil(count), AT_BUY_SHOP_GOOGS)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_ARENA, res.discountCfg)
		g_i3k_ui_mgr:PopupTipMessage(tips)
		DCItem.consume(g_BASE_ITEM_ARENA_MONEY,"武斗币",shopItem.moneyCount,AT_BUY_SHOP_GOOGS)
		DCItem.buy(shopItem.itemId,g_i3k_db.i3k_db_get_common_item_is_free_type(shopItem.itemId),shopItem.itemCount, shopItem.moneyType, shopItem.moneyCount, AT_BUY_SHOP_GOOGS)
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50065))
	else
		local tips = string.format("%s", "购买失败")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

----------------------被打名次下降时----------------------
function i3k_sbean.arena_attacked.handler(bean)
	g_i3k_game_context:setArenaLogsRed(true)
end

function i3k_sbean.get_rank_defensive(role, rank, sectData)
	local sync = i3k_sbean.arena_defencepets_req.new()
	sync.rid = role.id
	sync.rank = rank
	sync.role = role
	sync.sectData = sectData
	i3k_game_send_str_cmd(sync, "arena_defencepets_res")
end

-- 获取竞技场防守阵容
-- Package:arena_defencepets_res
function i3k_sbean.arena_defencepets_res.handler(bean, res)
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaEnemyLineup)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaEnemyLineup, res.role, bean.pets, res.sectData, bean.hideDefence)
end

--会武随从携带
--Package:superarena_setpets
function i3k_sbean.superarena_setpets(id)
	local sync = i3k_sbean.superarena_setpets_req.new()
	local pet = {}
	pet[id] = true
	sync.pets = pet
	i3k_game_send_str_cmd(sync, "superarena_setpets_res")
end

function i3k_sbean.superarena_setpets_res.handler(bean, res)
	if bean.ok == 1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadTournament", g_i3k_game_context:getTournamentData())
		g_i3k_ui_mgr:CloseUI(eUIID_TournamentChoosePet)
		g_i3k_ui_mgr:PopupTipMessage("保存成功")
	end
end

-- 设置隐藏
function i3k_sbean.arena_hidedefence(isHide)
	local data = i3k_sbean.arena_hidedefence_req.new()
	data.hide = isHide
	i3k_game_send_str_cmd(data, "arena_hidedefence_res")
end

function i3k_sbean.arena_hidedefence_res.handler(bean, req)
	if bean.ok == 1 then
		local cfg = g_i3k_game_context:GetUserCfg()
		if cfg and cfg:GetIsAreanDefendTips() then
			cfg:SetIsAreanDefendTips(0)
			g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15354))
		end
		g_i3k_game_context:SetIsHideArenaDefen(req.hide)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaSetLineup, "updateDefendImg", req.hide)
	end
end

-------------------跨服PVE神地幽冥境 start-------------------
-- PVE同步
function i3k_sbean.globalpve_sync()
	local data = i3k_sbean.globalpve_sync_req.new()
	i3k_game_send_str_cmd(data, "globalpve_sync_res")
end

function i3k_sbean.globalpve_sync_res.handler(bean, req)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadGlobalPve", bean.startTime, bean.endTime, bean.openDays)
end

-- 参加跨服PVE
function i3k_sbean.globalpve_join()
	local data = i3k_sbean.globalpve_join_req.new()
	i3k_game_send_str_cmd(data, "globalpve_join_res")
end

function i3k_sbean.globalpve_join_res.handler(bean, req)
	if bean.ok == 1 then
		
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1346))
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1347))
	end
end

-- pve开始
function i3k_sbean.role_globalpve_start.handler(bean)
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_GLOBAL_PVE, g_SCHEDULE_COMMON_MAPID)
end

-- pve结束
function i3k_sbean.role_globalpve_end.handler(bean)

end

-- 同步跨服PVE  boss初始信息
function i3k_sbean.globalpve_bosses_info.handler(bean)
	if bean then
		if g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.peaceMapID then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PvePeaceArea, "setBossInfo", bean.alive, bean.dead)
		elseif g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.battleMapID then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PveBattleArea, "setBossInfo", bean.alive, bean.dead)
		end
	end
end

--同步跨服PVE BOSS死亡同步
function i3k_sbean.globalpve_boss_dead.handler(bean)
	if bean then
		if g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.peaceMapID then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PvePeaceArea, "bossDie", bean.bossID, bean.lastCheckTime)
		elseif g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.battleMapID then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PveBattleArea, "bossDie", bean.bossID, bean.lastCheckTime)
		end
	end
end

--和平区boss传送
function i3k_sbean.peaceAreaBoss_transfer(mapID, bossID)
	local data = i3k_sbean.globalpve_teleboss_req.new()
	data.mapID = mapID
	data.bossID = bossID
	i3k_game_send_str_cmd(data, "globalpve_teleboss_res")
end

function i3k_sbean.globalpve_teleboss_res.handler()
	
end

--同步幽冥密令的数量
function i3k_sbean.globalpve_keys_sync.handler(bean)
	if bean then
		g_i3k_game_context:setPveBattleKey(bean.keys)
	end
end

--增加幽冥密令的数量
function i3k_sbean.globalpve_keys_add.handler(bean)
	if bean then
		g_i3k_game_context:addPveBattleKey(bean.add)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PvePeaceArea, "showBattleKeys")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShowLineInfo, "showBattleKeys")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1330, bean.add))
	end
end

--同步对战区线路信息
function i3k_sbean.showPveBattle_lineInfo(keys)
	local data = i3k_sbean.globalpve_syncwararea_req.new()
	data.keys = keys
	i3k_game_send_str_cmd(data, "globalpve_syncwararea_res")
end

function i3k_sbean.globalpve_syncwararea_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_ShowLineInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShowLineInfo, res.areas, req.keys)
end

--进入PVe对战区
function i3k_sbean.enter_pveBattleArea(line)
	local data = i3k_sbean.globalpve_enterwar_req.new()
	data.line = line
	i3k_game_send_str_cmd(data, "globalpve_enterwar_res")
end

function i3k_sbean.globalpve_enterwar_res.handler(res, req)
	if res.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1363))
	end
end

--获取对战区boss积分详情
function i3k_sbean.check_sectScore_rank(bossID)
	local data = i3k_sbean.query_globalpve_boss_rank.new()
	data.bossID = bossID
	i3k_game_send_str_cmd(data, "globalpve_boss_rank")
end

function i3k_sbean.globalpve_boss_rank.handler(res, req)
	if res then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PveBattleArea, "showScoreRank", res.rank, res.selfDamage, req.bossID)
	end
end

--超级boss出现
function i3k_sbean.globalpve_superboss_create.handler(bean)
	if bean then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PveBattleArea, "superBossShow", bean.sectName)
	end
end

--超级boss死亡
function i3k_sbean.globalpve_superboss_dead.handler(bean)
	if bean then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PveBattleArea, "superBossDie", bean.sectName)
	end
end

function i3k_sbean.globalpve_shareboss_damage.handler(bean)
	local world = i3k_game_get_world();
	if world then
		-- local roleID = g_i3k_game_context:GetRoleId()
		-- i3k_log(roleID.."| "..bean.totalDamage)
		local entity = world:GetEntity(eET_Monster, bean.mid);
		if entity then
			local totalDamage = bean.totalDamage
			local maxHP = entity:GetPropertyValue(ePropID_maxHP)
			local curHP = maxHP - totalDamage >= 0 and maxHP - totalDamage or 0
			entity:SetShareHp(curHP)
			entity:UpdateBloodBar(curHP / entity:GetPropertyValue(ePropID_maxHP));
			local logic = i3k_game_get_logic();
			local selEntity = logic._selectEntity;
			if selEntity then
				if selEntity._guid == entity._guid then
					g_i3k_game_context:OnTargetHpChangedHandler(curHP, maxHP)
				end
			end
			if world._mapType == g_SPIRIT_BOSS then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateBossBlood", entity._id, curHP, maxHP)
			end
		end
	end
end
-------------------跨服PVE神地幽冥境 end-------------------
function i3k_sbean.getFinishReward(id, items)
	local data = i3k_sbean.first_access_take_reward_req.new()
	data.id = id
	data.items = items
	i3k_game_send_str_cmd(data, "first_access_take_reward_res")
end
function i3k_sbean.first_access_take_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_FirstClearReward)
		g_i3k_ui_mgr:ShowGainItemInfo(req.items)
		g_i3k_game_context:refreshFirstClearInfo(req.id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "disVisibleFinishBtn")
	end
end

------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
--召唤佣兵
function i3k_sbean.pet_make(id)
	local data = i3k_sbean.pet_make_req.new()
	data.petId = id
	i3k_game_send_str_cmd(data, "pet_make_res")
end

function i3k_sbean.pet_make_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPetMakeData(req.petId)
	end
end

--佣兵转职
function i3k_sbean.goto_pet_transform(petId, tlvl)
	local data = i3k_sbean.pet_transform_req.new()
	data.petId = petId
	data.tlvl = tlvl
	i3k_game_send_str_cmd(data,"pet_transform_res")
end

function i3k_sbean.pet_transform_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:PetTransferLvl(req.petId, req.tlvl)
	end
end

--佣兵升级
function i3k_sbean.goto_pet_levelup(id, temp, up_lvl, last_exp, compare_lvl, layer)
	local data = i3k_sbean.pet_levelup_req.new()
	data.petId = id
	data.items = temp
	data.level = up_lvl
	data.exp = last_exp
	data.compare_lvl = compare_lvl
	data.layer = layer
	data.__callback = function(layer)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateSuicongUpLvlData")
	end
	i3k_game_send_str_cmd(data,"pet_levelup_res")
end

function i3k_sbean.pet_levelup_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "setCanUse", true)
		g_i3k_game_context:PetUpLevel(req.petId, req.items, req.level, req.exp, req.compare_lvl)
		local id = req.petId
		local transfer = g_i3k_game_context:getPetTransfer(id)
		local need_lvl = 0
		local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
		if trs_cfg then
			need_lvl = trs_cfg.maxLvl
		end
		if need_lvl ~= 0 and need_lvl ~= req.level and req.layer then
			req.__callback(req.layer)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "onUpLvlUpdata")
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "recordSkillBtn")
		g_i3k_game_context:LeadCheck(eLTEventMercenaryLvlUp,{petId = req.petId});
		g_i3k_game_context:PlotCheck(eLTEventMercenaryLvlUp,{petId = req.petId});

		if req.compare_lvl.isUpLvl then
			DCEvent.onEvent("随从升级", { ["随从ID"] = tostring(req.petId) })
		end
	end
end

--佣兵买等级
function i3k_sbean.goto_buylevel(id, level, needDiamond)
	local data = i3k_sbean.pet_buylevel_req.new()
	data.petId = id
	data.level = level
	data.needDiamond = needDiamond
	i3k_game_send_str_cmd(data,"pet_buylevel_res")
end

function i3k_sbean.pet_buylevel_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:PetBuyLevel(req.petId, req.level, req.needDiamond)
		g_i3k_game_context:LeadCheck(eLTEventMercenaryLvlUp,{petId = req.petId});
		g_i3k_game_context:PlotCheck(eLTEventMercenaryLvlUp,{petId = req.petId});

		DCEvent.onEvent("随从升级", { ["随从ID"] = tostring(req.petId) } )
	end
end

--佣兵升星
function i3k_sbean.goto_pet_starup(petId, star, itemCount, altCount)
	local data = i3k_sbean.pet_starup_req.new()
	data.petId = petId
	data.star = star
	data.itemCount = itemCount
	data.altCount = altCount
	i3k_game_send_str_cmd(data,"pet_starup_res")
end

function i3k_sbean.pet_starup_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:PetUpStartLevel(req.petId, req.itemCount ,req.altCount)

		DCEvent.onEvent("随从升星", { ["随从ID"] = tostring(req.petId) } )
	end
end

-- 佣兵突破等级提升
function i3k_sbean.goto_pet_breakskilllvlup(id, skillId, level, itemCount, altCount)
	local data = i3k_sbean.pet_breakskillvlup_req.new()
	data.petId = id
	data.skillId = skillId
	data.level = level
	data.itemCount = itemCount
	data.altCount = altCount
	i3k_game_send_str_cmd(data,"pet_breakskillvlup_res")
end

function i3k_sbean.pet_breakskillvlup_res.handler(res,req)
	if res.ok == 1 then
		g_i3k_game_context:PetBreakSkillUpLevel(req.petId ,req.skillId ,req.level,req.itemCount ,req.altCount)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end
end

-- 世界地图佣兵设置
function i3k_sbean.goto_pet_worldmapset(id)
	local data = i3k_sbean.pet_worldmapset_req.new()
	data.petId = id
	i3k_game_send_str_cmd(data,"pet_worldmapset_res")
end

function i3k_sbean.pet_worldmapset_res.handler(res,req)
	local is_ok = res.ok
	if is_ok == 1 then
		g_i3k_game_context:PetSetWorldPlay(req.petId)
		g_i3k_game_context:SetPrePower()
		if req.petId == 0 then
			g_i3k_game_context:setRoleFightPets({})
		else
			g_i3k_game_context:setRoleFightPets({ [req.petId] = true})
		end
		g_i3k_game_context:RefreshMercenarySpiritsProps()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"updatePetProp")
	end
end

-- 单人副本佣兵设置
function i3k_sbean.goto_pet_privatemapset(petsId)
	local data = i3k_sbean.pet_privatemapset_req.new()
	data.petsId = petsId
	i3k_game_send_str_cmd(data,"pet_privatemapset_res")
end
function i3k_sbean.pet_privatemapset_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:PetSetSingleDungeonPLay(req.petsId)
		g_i3k_ui_mgr:CloseUI(eUIID_SuicongDungeonPlay)
		g_i3k_ui_mgr:PopupTipMessage("保存成功")
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "服务器资讯：保存失败"))
	end
end

-- 帮派副本佣兵设置
function i3k_sbean.goto_pet_sectmapset(petsId,t)
	local data = i3k_sbean.pet_sectmapset_req.new()
	data.petsId = petsId
	i3k_game_send_str_cmd(data,"pet_sectmapset_res")
end

function i3k_sbean.pet_sectmapset_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:PetSetFactionDungeonPlay(req.petsId)
		g_i3k_ui_mgr:PopupTipMessage("保存成功")
		g_i3k_ui_mgr:CloseUI(eUIID_FactionSuicongPlay)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "服务器资讯：保存失败"))
	end
end

-- 活动副本佣兵设置
function i3k_sbean.goto_pet_activitymapset(petsId)
	local data = i3k_sbean.pet_activitymapset_req.new()
	data.petsId = petsId
	i3k_game_send_str_cmd(data, "pet_activitymapset_res")
end

function i3k_sbean.pet_activitymapset_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "保存成功"))
		g_i3k_ui_mgr:CloseUI(eUIID_ActivityPets)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "服务器资讯：保存失败"))
	end
end

-- 单人闯关副本佣兵设置
function i3k_sbean.single_explore_set_pet(exploreId, pets)
	local data = i3k_sbean.single_explore_set_pet_req.new()
	data.exploreId = exploreId
	data.pets = pets
	i3k_game_send_str_cmd(data,"single_explore_set_pet_res")
end
function i3k_sbean.single_explore_set_pet_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_SuicongDungeonPlay)
		g_i3k_ui_mgr:PopupTipMessage("保存成功")
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "服务器资讯：保存失败"))
	end
end

--随从技能升级
function i3k_sbean.pet_skill_level_up(petId, skillIndex, level, allItem)
	local data = i3k_sbean.pet_skill_level_up_req.new()
	data.petId = petId
	data.skillIndex = skillIndex
	data.level = level
	data.allItem = allItem
	i3k_game_send_str_cmd(data, "pet_skill_level_up_res")
end

function i3k_sbean.pet_skill_level_up_res.handler(bean, req)
	if bean.ok == 1 then
		if req.allItem then
			for k,v in pairs(req.allItem) do
				g_i3k_game_context:UseCommonItem(k, v,AT_PET_SKILL_LEVEL_UP)
			end
		end
		g_i3k_game_context:SetPetSkillData(req.petId, req.skillIndex, req.level)
	end
end

--随从界面同步协议（武库数据）
function i3k_sbean.pet_sync()
	local data = i3k_sbean.pet_sync_req.new()
	i3k_game_send_str_cmd(data, "pet_sync_res")
end

function i3k_sbean.pet_sync_res.handler(bean)
	g_i3k_game_context:setPetAllSpirits(bean.allSpirits)
	g_i3k_ui_mgr:OpenUI(eUIID_SuiCong)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuiCong)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateXinFaRedPoint")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateWuKuRedPoint")
end

--武库心法升级
function i3k_sbean.petspirit_lvlup(id, level, fun)
	local data = i3k_sbean.petspirit_lvlup_req.new()
	data.spiritID = id
	data.level = level
	data.fun = fun
	i3k_game_send_str_cmd(data, "petspirit_lvlup_res")
end

function i3k_sbean.petspirit_lvlup_res.handler(bean, req)
	if bean.ok == 1 then
		if req.fun then
			req.fun()
		end
		local tmp = {[req.spiritID] = req.level}
		g_i3k_game_context:addPetAllSpirits(tmp)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateXinFaRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateWuKuRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AllSpirits, "updateBookmark")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AllSpirits, "updateScrollData", req.spiritID)
	end
end

--随从心法修习
function i3k_sbean.petspirit_learn(petId, index, id, level, fun, _spiritID, part2Items)
	local data = i3k_sbean.petspirit_learn_req.new()
	data.petID = petId
	data.index = index
	data.spiritID = id
	data.fun = fun
	data.level = level
	data._spiritID = _spiritID
	data.cost2Items = part2Items
	i3k_game_send_str_cmd(data, "petspirit_learn_res")
end

function i3k_sbean.petspirit_learn_res.handler(bean, req)
	if bean.spiritLvl > 0 then
		if req.fun then
			req.fun()
		end
		if req._spiritID then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_StudySpirit, "updateScrollData", req.spiritID)
			g_i3k_ui_mgr:OpenUI(eUIID_SpiritTips2)
			g_i3k_ui_mgr:RefreshUI(eUIID_SpiritTips2, req.petID, req._spiritID, req.spiritID, bean.spiritLvl, req.index)
		else
			local oldPower = math.modf(g_i3k_game_context:getBattlePower(req.petID))
			g_i3k_game_context:setPetSpiritsData(req.petID, req.index, req.spiritID, bean.spiritLvl)
			local data = {petID = req.petID, id = req.spiritID, level = bean.spiritLvl}
			g_i3k_ui_mgr:OpenUI(eUIID_SpiritTips3)
			g_i3k_ui_mgr:RefreshUI(eUIID_SpiritTips3, data)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updatePetXinfa")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "refreshBattlePower", true)
			local afterPower = math.modf(g_i3k_game_context:getBattlePower(req.petID))
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "changeBattlePower", afterPower, oldPower)
			g_i3k_game_context:SetPrePower()
			g_i3k_game_context:RefreshMercenarySpiritsProps()
			g_i3k_game_context:ShowPowerChange()
		end
	end
end

--随从心法替换
function i3k_sbean.petspirit_replace(info)
	local data = i3k_sbean.petspirit_replace_req.new()
	data.petID = info.petID
	data.index = info.index
	data.id = info.id
	data.level = info.level
	i3k_game_send_str_cmd(data, "petspirit_replace_res")
end

function i3k_sbean.petspirit_replace_res.handler(bean, req)
	if bean.ok == 1 then
		local oldPower = math.modf(g_i3k_game_context:getBattlePower(req.petID))
		g_i3k_game_context:setPetSpiritsData(req.petID, req.index, req.id, req.level)
		g_i3k_ui_mgr:CloseUI(eUIID_SpiritTips2)
		g_i3k_ui_mgr:CloseUI(eUIID_StudySpirit)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updatePetXinfa")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "refreshBattlePower", true)
		local afterPower = math.modf(g_i3k_game_context:getBattlePower(req.petID))
		if afterPower ~= oldPower then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "changeBattlePower", afterPower, oldPower)
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshMercenarySpiritsProps()
		g_i3k_game_context:ShowPowerChange()
	end
end

--增加随从战绩
function i3k_sbean.pet_add_exploit.handler(bean)
	local name = i3k_db_mercenaries[bean.petID].name
	g_i3k_game_context:ShowSysMessage(i3k_get_string(798, name, bean.exploit),"宠物心法",0,0)

	local oldExploit = g_i3k_game_context:getPetExploit(bean.petID)
	local oldIndex = 0
	for i,e in ipairs(i3k_db_suicong_exploit[bean.petID]) do
		if oldExploit >= e.needExploit then
			oldIndex = i
		end
	end
	g_i3k_game_context:AddPetExploit(bean.petID, bean.exploit)
	local temp = {}
	local newExploit = g_i3k_game_context:getPetExploit(bean.petID)
	for i,e in ipairs(i3k_db_suicong_exploit[bean.petID]) do
		if newExploit >= e.needExploit then
			if i > oldIndex then
				table.insert(temp, i)
			end
		end
	end
	if next(temp) then
		for _,e in ipairs(temp) do
			g_i3k_game_context:ShowSysMessage(i3k_get_string(799, name, e),"宠物心法",0,0)
		end
	end
end

function i3k_sbean.syncPetRace()
	local data = i3k_sbean.pet_run_sync_req.new()
	i3k_game_send_str_cmd(data, "pet_run_sync_res")
end
function i3k_sbean.pet_run_sync_res.handler(res, req)
	local pets = res.pets
	local data = res.data
	local nowTime = i3k_game_get_time()%86400
	local beginTime = i3k_db_common.petRace.beforeTime
	local endTime = i3k_db_common.petRace.startTime
	if nowTime < beginTime then
		g_i3k_ui_mgr:PopupTipMessage("宠物赛跑开启时间未到")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_PetRace)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetRace, pets, data)
end


function i3k_sbean.petRunVote(petID, useDiamond, ticketNum, curTimes, score)
	local data = i3k_sbean.pet_run_ticket_req.new()
	data.petId = petID
	data.useDiamond = useDiamond -- 是否使用元宝 1 0
	data.ticketNum = ticketNum
	data.curTimes = curTimes
	data.score = score
	i3k_game_send_str_cmd(data, "pet_run_ticket_res")
end

function i3k_sbean.pet_run_ticket_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("投票成功")
		local itemType = req.useDiamond == 1 and 1 or 2
		local needItemID = i3k_db_common.petRace.needItems[itemType].id
		local needCount = i3k_db_common.petRace.needItems[itemType].count -- 每次使用数量
		g_i3k_game_context:UseBaseItem(needItemID, needCount * req.ticketNum, AT_PET_RACE_VOTE)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetRace, "updateVoteTimes", req.curTimes + req.ticketNum)
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetRace, "addMyScore", req.score)
		i3k_sbean.syncPetRace()
	else
		g_i3k_ui_mgr:PopupTipMessage("投票失败或活动未开启")
	end
end

-- 宠物赛跑，进入视野
function i3k_sbean.nearby_enter_petrunpets.handler(res)
	local pets = res.pets or {}
	local world = i3k_game_get_world()
	-- world:RemovePetRacePets({1, 2, 3})
	local locationRoad = nil
	for _, v in ipairs(pets) do
		local id = v.id
		local location = v.location
		if not locationRoad then
			locationRoad = v.location
		end
		if world then
			world:CreatePetRacePet(id, location)
		end
	end
	-- 创建跑道
	world:AddPetRaceRoad()
end

-- 宠物赛跑开始通知
function i3k_sbean.pet_run_start.handler(res)
	local world = i3k_game_get_world()
	if world then
		world:PlayPetRaceRoadStart()
	end
end
-- 宠物赛跑结束通知
function i3k_sbean.pet_run_end.handler(res)
	local winPetID = res.winId
	local world = i3k_game_get_world()
	if world and winPetID then
		world:PlayPetRaceRoadFinish(winPetID)
	end
end

-- 离开视野
function i3k_sbean.nearby_leave_petrunpets.handler(res)
	local world = i3k_game_get_world()
	if world then
		world:RemovePetRacePets(res.pets)
	end
end
-- 移动
function i3k_sbean.nearby_move_petrunpet.handler(res)
	local world = i3k_game_get_world()
	if world then
		world:PetRaceMovePos(res.id, res.pos, res.speed, res.rotation, res.timeTick)
	end
end
-- 停止移动
function i3k_sbean.nearby_stopmove_petrunpet.handler(res)
	local world = i3k_game_get_world()
	if world then
		world:PetRaceStopMove(res.id, res.pos, res.timeTick)
	end
end
-- 加buff
function i3k_sbean.nearby_petrunpet_addbuff.handler(res)
	local id = res.id
	local buffID = res.buffID
	local realmLvl = res.realmLvl
	local remainTime = res.remainTime
	local timeTick = res.timeTick
	local world = i3k_game_get_world()
	if world then
		world:PetsRacePetAddBuff(id, buffID)
	end
end
-- 移除buff
function i3k_sbean.nearby_petrunpet_removebuff.handler(res)
	local id = res.id
	local buffID = res.buffID
	local timeTick = res.timeTick
	local world = i3k_game_get_world()
	if world then
		world:PetsRacePetRemoveBuff(id, buffID)
	end
end

function i3k_sbean.petRunThrowItems(itemId, petId)
	local data = i3k_sbean.pet_run_throw_item_req.new()
	data.itemId = itemId
	data.petId = petId
	i3k_game_send_str_cmd(data, "pet_run_throw_item_res")
end
function i3k_sbean.pet_run_throw_item_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseBagItem(req.itemId, 1, AT_PET_RACE_SLOWDOWN)
		local maxTime = i3k_db_common.petRace.useItemsCD
		g_i3k_game_context:setPetRaceUseSkillTime(maxTime)
		g_i3k_game_context:throwToRacePet()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattlePetRace, "setUI")
		local hero = i3k_game_get_player_hero()
		hero:PlayPetRaceActions()
	else
		g_i3k_ui_mgr:PopupTipMessage("使用道具失败")
	end
end

-- 赛跑商城同步协议
function i3k_sbean.syncPetRaceShop()
	local data = i3k_sbean.pet_run_shopsync_req.new()
	i3k_game_send_str_cmd(data, "pet_run_shopsync_res")
end
function i3k_sbean.pet_run_shopsync_res.handler(res, req)
	local info = res.info
	local currency = res.currency
	local t =
	{
		refreshTimes = info.refreshTimes,
		items = info.goods
	}
	g_i3k_game_context:setPetRaceShopData(t)
	g_i3k_game_context:SetPetRaceCoin(currency)
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_PET, res.discount)
end

-- 宠物赛跑刷新协议
function i3k_sbean.refreshPetRaceShop(times, isSecondType, coinCnt, discount)
	local data = i3k_sbean.pet_run_shoprefresh_req.new()
	data.times = times
	data.isSecondType = isSecondType
	data.coinCnt = coinCnt
	data.discount = discount
	i3k_game_send_str_cmd(data, "pet_run_shoprefresh_res")
end
function i3k_sbean.pet_run_shoprefresh_res.handler(res, req)
	local info = res.info
	if info then
		if req.isSecondType > 0 then
			moneytype = g_BASE_ITEM_DIAMOND
		else
			moneytype = g_BASE_ITEM_PETCOIN
		end
		g_i3k_game_context:UseCommonItem(moneytype, req.coinCnt, AT_USER_REFRESH_SHOP)
		-- 更新界面
		local t =
		{
			refreshTimes = info.refreshTimes,
			items = info.goods
		}
		g_i3k_game_context:setPetRaceShopData(t)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_PET, req.discount)
	else
		local tips = string.format("%s", "刷新失败，请重试")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

-- 宠物赛跑买商品协议
function i3k_sbean.petRaceShopBuy(index, info, discount, discountCfg)
	local data = i3k_sbean.pet_run_shopbuy_req.new()
	data.seq = index
	data.info = info
	data.discount = discount
	data.discountCfg = discountCfg
	i3k_game_send_str_cmd(data, "pet_run_shopbuy_res")
end
function i3k_sbean.pet_run_shopbuy_res.handler(res, req)
	if res.ok > 0 then
		local info = req.info
		local index = req.seq
		local shopItem = i3k_db_pet_race_store.item_data[info.goods[index].id]
		local tips = i3k_get_string(189, shopItem.itemName.."*"..shopItem.itemCount)
		info.goods[index].buyTimes = 1
		local count = req.discount > 0 and (shopItem.moneyCount * req.discount / 10) or shopItem.moneyCount
		g_i3k_game_context:UseBaseItem(g_BASE_ITEM_PETCOIN, math.ceil(count), AT_BUY_SHOP_GOOGS)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_PET, req.discountCfg)
		g_i3k_ui_mgr:PopupTipMessage(tips)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50065))
	end
end

-- 通知客户端角色宠物赛跑货币增长
function i3k_sbean.role_add_petrun_coin(res, req)
	local petRaceCoin = res.petRunCoin
	local reason = res.reason
	g_i3k_game_context:AddPetRaceCoin(petRaceCoin)
end

-----------------------------佣兵觉醒---------------------------------------------
-- 开启宠物觉醒任务
function i3k_sbean.awakeTaskOpen(id)
	local data = i3k_sbean.pawaketask_open_req.new()
	data.pid = id
	i3k_game_send_str_cmd(data, "pawaketask_open_res")
end

function i3k_sbean.pawaketask_open_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setPetWakening(req.pid)
		g_i3k_game_context:setPetWakenTaskId(req.pid, g_TaskType1)
		g_i3k_game_context:setPetWakenTaskState(req.pid, g_TaskState1)
		g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTips)
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask1)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask1, req.pid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"updatePetWakenTxt", req.pid)
	end
end

-- 完成宠物觉醒任务
function i3k_sbean.awakeTaskFinish(id, taskId)
	local data = i3k_sbean.pawaketask_finish_req.new()
	data.pid = id
	data.taskId = taskId
	i3k_game_send_str_cmd(data, "pawaketask_finish_res")
end

function i3k_sbean.pawaketask_finish_res.handler(res, req)
	if res.ok > 0 then
		local task = i3k_db_mercenariea_waken_task[req.pid];
		if task then
			local taskData = task[req.taskId];
			if taskData and taskData.taskType then
				g_i3k_game_context:setPetWakenTaskState(req.pid, g_TaskState1)
				if taskData.taskType == g_TASK_KILL then
					g_i3k_game_context:setPetWakenTaskId(req.pid, g_TaskType2)
					g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTask1)
					g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask2)
					g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask2,req.pid)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"initAwakenTask")
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"updatePetWakenTxt", req.pid)
				elseif taskData.taskType == g_TASK_PASS_FUBEN then
					g_i3k_game_context:setPetWakenTaskId(req.pid, g_TaskType3)
					g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTask2)
					g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask3)
					g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask3,req.pid)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"initAwakenTask")
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"updatePetWakenTxt", req.pid)
				elseif taskData.taskType == g_TASK_SUBMIT_ITEM then
					if not g_i3k_ui_mgr:GetUI(eUIID_Main) then
						g_i3k_ui_mgr:CloseAllOpenedUI()
						g_i3k_ui_mgr:OpenUI(eUIID_Main)
						g_i3k_ui_mgr:RefreshUI(eUIID_Main)
					end
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"removeAwakenTask")
					g_i3k_ui_mgr:OpenUI(eUIID_SuiCong)
					g_i3k_ui_mgr:RefreshUI(eUIID_SuiCong, req.pid)
					g_i3k_game_context:clsPetWakening();
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"ChagePetModule", req.pid)
				end
			end
		end
	end
end

-- 放弃宠物觉醒任务
function i3k_sbean.awakeTaskQuit(id, taskId)
	local data = i3k_sbean.pawaketask_quit_req.new()
	data.pid = id
	data.taskId = taskId
	i3k_game_send_str_cmd(data, "pawaketask_quit_res")
end

function i3k_sbean.pawaketask_quit_res.handler(res, req)
	if res.ok > 0 then
		local task = i3k_db_mercenariea_waken_task[req.pid];
		if task then
			g_i3k_game_context:clsWakenKillCount();
			g_i3k_game_context:clsPetWakening();
			g_i3k_game_context:setPetWakenTaskId(req.pid, g_TaskType)
			g_i3k_game_context:setPetWakenTaskState(req.pid, g_TaskState)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateTaskInfo")
			if g_i3k_ui_mgr:GetUI(eUIID_SuiCong) then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"updatePetWakenTxt", req.pid)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenGiveUp)
			local taskData = task[req.taskId];
			if taskData and taskData.taskType then
				if taskData.taskType == g_TASK_KILL then
					g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTask1)
				elseif taskData.taskType == g_TASK_PASS_FUBEN then
					g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTask2)
				elseif taskData.taskType == g_TASK_SUBMIT_ITEM then
					g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTask3)
				end
			end
		end
	end
end

--重置宠物觉醒任务
function i3k_sbean.awakeTaskReset(id)
	local data = i3k_sbean.pawaketask_reset_req.new()
	data.pid = id
	i3k_game_send_str_cmd(data, "pawaketask_reset_res")
end
function i3k_sbean.pawaketask_reset_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:clsWakenKillCount();
		g_i3k_game_context:setPetWakenTaskState(req.pid, g_TaskState1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuicongWakenTask1,"updateKillCount", req.pid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateAwakenTaxt", req.pid)
		if g_i3k_ui_mgr:GetUI(eUIID_SuiCong) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"updatePetWakenTxt", req.pid)
		end
	end
end

-- 宠物觉醒任务提交道具
function i3k_sbean.awakeTaskSubmitItem(id, items, part1Items)
	local data = i3k_sbean.pawaketask_submititem_req.new()
	data.pid = id
	data.items1 = part1Items
	data.items = items
	i3k_game_send_str_cmd(data, "pawaketask_submititem_res")
end

function i3k_sbean.pawaketask_submititem_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setPetWakenTaskState(req.pid, g_TaskState2)
		for i,e in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(e.needItemID, e.needItemCount, AT_PET_AWAKE_TASK_SUBMIT_ITEM)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTask3)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateAwakenTaxt", req.pid)
		i3k_sbean.awakeTaskFinish(req.pid, g_TaskType3)
	end
end

-- 宠物觉醒设置
function i3k_sbean.petAwakeSet(id,isUse)
	local data = i3k_sbean.petawake_set_req.new()
	data.pid = id
	data.use = isUse
	i3k_game_send_str_cmd(data, "petawake_set_res")
end

function i3k_sbean.petawake_set_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setPetWakenUse(req.pid, req.use)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong,"updatePetModule", req.pid)
	end
end

-- 开始宠物觉醒任务副本
function i3k_sbean.petAwakeMap(id, mapID, pets)
	local data = i3k_sbean.start_pawakemap_req.new()
	data.pid = id
	data.mapID = mapID
	data.pets = pets
	i3k_game_send_str_cmd(data, "start_pawakemap_res")
end

function i3k_sbean.start_pawakemap_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setPetWakenTaskState(req.pid, g_TaskState1)
	end
end

--宠物觉醒任务副本结束
function i3k_sbean.pawake_map_end.handler(bean, res)
	if bean.mapID and bean.finish then
		local pid = g_i3k_game_context:getPetWakening();
		if pid and bean.finish == 1 then
			local task = g_i3k_game_context:getPetWakenTask(pid);
			if task and task.taskArg.Arg1 == bean.mapID then
				g_i3k_game_context:setPetWakenTaskState(pid, g_TaskState2)
			end
		end
	end
end

-- 宠物改名
function i3k_sbean.pet_modify_name(id, name)
	local data = i3k_sbean.pet_rename_req.new()
	data.petID = id
	data.name = name
	i3k_game_send_str_cmd(data, "pet_rename_res")
end

function i3k_sbean.pet_rename_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetPetName(req.petID, req.name)
		g_i3k_game_context:UseCommonItem(i3k_db_mercenariea_waken_cfg.itemId, 1, AT_PET_RENAME)

		g_i3k_ui_mgr:CloseUI(eUIID_ModifyPetName)
		g_i3k_ui_mgr:PopupTipMessage("宠物改名成功")
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("名字非法")
	else
		g_i3k_ui_mgr:PopupTipMessage("宠物改名失败")
	end
end

function i3k_sbean.petbook_pushReq(items)
	local bean = i3k_sbean.petbook_push_req.new()
	bean.items = items
	i3k_game_send_str_cmd(bean, "petbook_push_res")
end

function i3k_sbean.petbook_push_res.handler(res, req)
	if res.ok > 0 then
		for k,v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v)
		end

		g_i3k_game_context:addPetBook(req.items)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AllSpirits, "changeBookScroll", req.items)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AllSpirits, "updateBookmark")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateWuKuRedPoint")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16916))
	end
end

function i3k_sbean.petbook_popReq(books)
	local bean = i3k_sbean.petbook_pop_req.new()
	bean.books = books
	i3k_game_send_str_cmd(bean, "petbook_pop_res")
end

function i3k_sbean.petbook_pop_res.handler(res, req)
	if res.ok > 0 then
		for k,v in pairs(req.books) do
			g_i3k_game_context:subPetBook(k,v)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AllSpirits, "changeBookScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AllSpirits, "updateBookmark")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateWuKuRedPoint")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16917))
	end
end

-- 宠物驯养
-- 宠物驯养数据登陆同步
--[[
DBPetDomestication
    ├──petEquipSpirit (int32)
    ├──equipParts map[int32, DBPetEquipPart]
       DBPetEquipPart
    │    ├──petGroupID (int32)
    │    ├──upLvls (map[int32,int32])
    │    └──equip (map[int32,int32])
    └──trainSkills map[int32, DBPetTrainSkill]
       DBPetTrainSkill
        ├──petID (int32)
        └──skills (map[int32,int32])
]]
function i3k_sbean.pet_domestication_sync.handler(res)
	--self.petDomestication:		DBPetDomestication	
	g_i3k_game_context:SetPetDomesticationData(res.petDomestication)
	--[[
	for k,v in pairs(res.petDomestication.equipParts or {}) do
		print("petGroupID = "..v.petGroupID)
		for m,n in pairs(v.upLvls or {}) do
			print(m,n)
		end
		for m,n in pairs(v.equip or {}) do
			print(m,n)
		end
	end
	for k,v in pairs(res.petDomestication.trainSkills or {}) do
		print("petID = "..v.petID)
		for m,n in pairs(v.skills or {}) do
			print(m,n)
		end
	end
	]]
end

-- 宠物穿上装备
function i3k_sbean.pet_domestication_equip_wear(petGroupID, equips)
	--self.petGroupID:		int32	
	--self.equips:		map[int32, int32]	
	local bean = i3k_sbean.pet_domestication_equip_wear_req.new()
	bean.petGroupID = petGroupID
	bean.equips = equips
	i3k_game_send_str_cmd(bean, "pet_domestication_equip_wear_res")
end

function i3k_sbean.pet_domestication_equip_wear_res.handler(res, req)
	if res.ok > 0 then
		local petID = g_i3k_game_context:GetPetEquipPet()
		local oldPower = g_i3k_game_context:getBattlePower(petID)

		g_i3k_game_context:WearPetEquip(req.petGroupID, req.equips)
		g_i3k_game_context:RefreshPetEquipProp(req.petGroupID)

		local afterPower = g_i3k_game_context:getBattlePower(petID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "changeBattlePower", afterPower, oldPower)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateEquipUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateBagScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateTabRedPoint")

		g_i3k_ui_mgr:CloseUI(eUIID_PetEquipInfoTips)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1495))
	else
		g_i3k_ui_mgr:PopupTipMessage("装备失败")
	end
end

-- 宠物脱下装备
function i3k_sbean.pet_domestication_equip_unwear(petGroupID, partID)
	--self.petGroupID:		int32	
	--self.partID:		int32
	local bean = i3k_sbean.pet_domestication_equip_unwear_req.new()
	bean.petGroupID = petGroupID
	bean.partID = partID
	i3k_game_send_str_cmd(bean, "pet_domestication_equip_unwear_res")
end

function i3k_sbean.pet_domestication_equip_unwear_res.handler(res, req)
	if res.ok > 0 then
		local petID = g_i3k_game_context:GetPetEquipPet()
		local oldPower = g_i3k_game_context:getBattlePower(petID)

		g_i3k_game_context:UnwearPetEquip(req.petGroupID, req.partID)
		g_i3k_game_context:RefreshPetEquipProp(req.petGroupID)

		local afterPower = g_i3k_game_context:getBattlePower(petID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "changeBattlePower", afterPower, oldPower)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateEquipUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateBagScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateTabRedPoint")

		g_i3k_ui_mgr:CloseUI(eUIID_PetEquipInfoTips)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1496))
	else
		g_i3k_ui_mgr:PopupTipMessage("脱下失败")
	end
end

-- 宠物装备部位升级
function i3k_sbean.pet_domestication_part_lvlup(petGroupID, equipPart, nextLvl, costItem)
	--self.petGroupID:		int32	
	--self.equipPart:		int32	
	--self.nextLvl:		int32
	local bean = i3k_sbean.pet_domestication_part_lvlup_req.new()
	bean.petGroupID = petGroupID
	bean.equipPart = equipPart
	bean.nextLvl = nextLvl
	bean.costItem = costItem
	i3k_game_send_str_cmd(bean, "pet_domestication_part_lvlup_res")
end

function i3k_sbean.pet_domestication_part_lvlup_res.handler(res, req)
	if res.ok > 0 then
		local petID = g_i3k_game_context:GetPetEquipPet()
		local oldPower = g_i3k_game_context:getBattlePower(petID)

		g_i3k_game_context:UpdatePetEquipLvl(req.petGroupID, req.equipPart, req.nextLvl)
		g_i3k_game_context:RefreshPetEquipProp(req.petGroupID)

		local afterPower = g_i3k_game_context:getBattlePower(petID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipUpLevel, "changeBattlePower", afterPower, oldPower)

		for _, v in ipairs(req.costItem) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, "")
		end

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipUpLevel, "updateWearEquipsData", req.petGroupID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipUpLevel, "setEquipInfoUI", req.equipPart)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipUpLevel, "setGroupRedPoint", req.petGroupID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipUpLevel, "updateTabRedPoint")

		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1497))
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

-- 宠物驯养技能升级
function i3k_sbean.pet_domestication_skill_lvlup(petID, skillID, nextLvl, costItem)
	--self.petID:		int32	
	--self.skillID:		int32	
	--self.nextLvl:		int32	
	local bean = i3k_sbean.pet_domestication_skill_lvlup_req.new()
	bean.petID = petID
	bean.skillID = skillID
	bean.nextLvl = nextLvl
	bean.costItem = costItem
	i3k_game_send_str_cmd(bean, "pet_domestication_skill_lvlup_res")
end

function i3k_sbean.pet_domestication_skill_lvlup_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UpdatePetTrainSkillsData(req.petID, req.skillID, req.nextLvl)

		for _, v in ipairs(req.costItem) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, "")
		end

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipSkillUpLvl, "updateSkillScroll", req.petID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipSkillUpLvl, "setPetSkillPetScrollPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipSkillUpLvl, "updateTabRedPoint")

		local skillData = g_i3k_game_context:GetPetTrainSkillsData(req.petID)
		local skillLvl = skillData[req.skillID] or 0
		local maxLvl = g_i3k_db.i3k_db_get_pet_equip_skill_max_lvl(req.skillID)
		if skillLvl < maxLvl then
			g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipSkillUpGrade, req.petID, req.skillID)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_PetEquipSkillUpGrade)
		end

		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1497))
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

-- 宠物装备分解
function i3k_sbean.pet_domestication_equip_split(equips, getItem)
	--self.equips:		map[int32, int32]	
	local bean = i3k_sbean.pet_domestication_equip_split_req.new()
	bean.equips = equips
	bean.getItem = getItem
	i3k_game_send_str_cmd(bean, "pet_domestication_equip_split_res")
end

function i3k_sbean.pet_domestication_equip_split_res.handler(res, req)
	if res.ok > 0 then
		for equipID, count in pairs(req.equips) do
			g_i3k_game_context:UseCommonItem(equipID, count, "")
		end
		g_i3k_ui_mgr:ShowGainItemInfo_safe(req.getItem)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1498))

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateBagScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquipSaleBat, "refreshSaleScoll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetEquip, "updateTabRedPoint")

		g_i3k_ui_mgr:CloseUI(eUIID_PetEquipInfoTips)
	else
		g_i3k_ui_mgr:PopupTipMessage("分解失败")
	end
end

function i3k_sbean.enterPetDungeonMap(mapID, petID)
	local bean = i3k_sbean.pettrain_enter_req.new()
	bean.activityId = mapID
	bean.petId = petID
	i3k_game_send_str_cmd(bean, "pettrain_enter_res")
end

function i3k_sbean.pettrain_enter_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1499))
		local cfg = i3k_db_schedule.cfg
		local mapID = g_SCHEDULE_COMMON_MAPID
		
		for _, v in ipairs(cfg or {}) do
			if v.typeNum == g_SCHEDULE_TYPE_PET_DUNGEON then
				mapID = v.mapID
				break
			end
		end
		
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_PET_DUNGEON, mapID)
	else
		g_i3k_ui_mgr:PopupTipMessage("进入宠物试炼失败")
	end
end

function i3k_sbean.acceptPetDungeonTask(taskID)
	local bean = i3k_sbean.pettrain_task_take_req.new()
	bean.taskId = taskID
	i3k_game_send_str_cmd(bean, "pettrain_task_take_res")
end

function i3k_sbean.pettrain_task_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1500))
		g_i3k_game_context:updateAcceptPetDungeonTask(req.taskId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetDungeonBattleBase, "refreshTaskScoll")
		local cfg = i3k_db_PetDungeonTasks[req.taskId]
		
		if cfg then
			g_i3k_logic:ChangePowerRepNpcTitleVisible(cfg.npcID, false)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("接取失败")
	end
end

function i3k_sbean.submitPetDungeonTask(taskID)
	local bean = i3k_sbean.pettrain_task_finish_req.new()
	bean.taskId = taskID
	i3k_game_send_str_cmd(bean, "pettrain_task_finish_res")
end

function i3k_sbean.pettrain_task_finish_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:updateSubmitPetDungeonTask(req.taskId)
		
		if res.buffs then
			local buffs = res.buffs
			
			for k, v in pairs(buffs) do
				g_i3k_game_context:addPetDungeonCanUseBuffs(k, v)			
				local cfg = i3k_db_PetDungeonEvents[k]
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1501, cfg.name, v))
			end
		end
		
		g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonGatherDetail)
		g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonrEvents)
		g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonBattleBase)
		local taskCfg = i3k_db_PetDungeonTasks[req.taskId]
		local t = {}
		
		if taskCfg then	
			for k, v in ipairs(taskCfg.rewards) do
				if v.count ~= 0 then
					table.insert(t, v)
				end
			end
		
			table.insert(t, {id = 1000, count = taskCfg.exp}) -- 经验
		
			if #(t) ~= 0 then
				g_i3k_ui_mgr:ShowGainItemInfo(t) -- 需要在套一层table
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("完成失败")
	end
end

function i3k_sbean.pettrain_mineral_gather(info)
	local bean = i3k_sbean.pettrain_mineral_take_req.new()
	bean.mineralId = info.mineralId
	bean.time = info.time
	bean.mapId = info.mapId
	bean.mineralPosition = info.mineralPosition
	bean.ignoreCondition = info.ignoreCondition
	i3k_game_send_str_cmd(bean, "pettrain_mineral_take_res")
end

function i3k_sbean.pettrain_mineral_take_res.handler(res, req)
	if res.ok > 0 then
		local items = {}
		
		for k, v in pairs(res.drops) do
			table.insert(items, {id = k, count = v})
		end
		
		if g_i3k_game_context:getPetDungeonBuffs(g_DOUBLEDROP) > 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1502))
		end
		
		g_i3k_game_context:addPetDungeonHavaUseBuffs(req.ignoreCondition == 1, req.time)
		g_i3k_game_context:updatePetDungeonReward(items)
		g_i3k_game_context:updatePetDungeonGatherCount(req.time)
				
		if res.buffs then
			local buffs = res.buffs
			
			for k, v in pairs(buffs) do
				g_i3k_game_context:addPetDungeonCanUseBuffs(k, v)			
				local cfg = i3k_db_PetDungeonEvents[k]
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1501, cfg.name, v))
			end
		end
		
		g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonGatherDetail)
		g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonrEvents)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetDungeonBattleBase, "refreshGatherText")
		local tmp_items = {}
		
		if res.drops then
			local drops = res.drops
			
			for k, v in pairs(drops) do
				table.insert(tmp_items, {id = k, count = v})
			end
		end
				
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
	else
		if res.ok == -1 then
			g_i3k_ui_mgr:PopupTipMessage("距离太远，采集失败")
		elseif res.ok == -2 then
			g_i3k_ui_mgr:PopupTipMessage("幸运buff不够，采集失败")
		else
			g_i3k_ui_mgr:PopupTipMessage("采集失败")
		end	
	end
end

------守护灵兽-----
function i3k_sbean.pet_guard_active(id)
	local bean = i3k_sbean.pet_guard_active_req.new()
	bean.petGuardId = id
	i3k_game_send_str_cmd(bean, "pet_guard_active_res")
end

function i3k_sbean.pet_guard_active_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:ActivePetGuard(req.petGuardId)
		local cfg = i3k_db_pet_guard[req.petGuardId]
		g_i3k_game_context:UseCommonItem(cfg.needItemId, cfg.needItemCount)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "refreshAllInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "updateRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "onActive")
	end
end

function i3k_sbean.pet_guard_lvl_up(id, items)
	local bean = i3k_sbean.pet_guard_lvl_up_req.new()
	bean.petGuardId = id
	bean.items = items
	i3k_game_send_str_cmd(bean, "pet_guard_lvl_up_res")
end

function i3k_sbean.pet_guard_lvl_up_res.handler(bean, req)
	if bean.ok > 0 then
		local exp = 0
		for k, v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v)
			exp = exp + i3k_db_new_item[k].args1 * v
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "updateItemsCount")
		g_i3k_game_context:AddPetGuardExp(req.petGuardId, exp)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "onGetExp")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "updateRedPoint")
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "setIsWaitingProtocol", false)		
end

function i3k_sbean.pet_guard_unlock_latent(id, latentId, itemCnt, alternativeCount)
	local bean = i3k_sbean.pet_guard_unlock_latent_req.new()
	bean.petGuardId = id
	bean.latentId = latentId
	bean.itemCnt = itemCnt
	bean.alternativeCount = alternativeCount
	i3k_game_send_str_cmd(bean, "pet_guard_unlock_latent_res")
end

function i3k_sbean.pet_guard_unlock_latent_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:UnlockPetGuardLatent(req.petGuardId, req.latentId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuardPotentialActive, "ConsumeItems", req.itemCnt, req.alternativeCount)
		g_i3k_ui_mgr:CloseUI(eUIID_PetGuardPotentialActive)
		g_i3k_ui_mgr:RefreshUI(eUIID_PetGuardPotential, nil, req.latentId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuardPotential, "onUnlockSuccess", req.latentId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "updateScrollInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "updateRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "updateRecycleBtn")
	end
end

function i3k_sbean.pet_guard_change(petGuardId)
	local bean = i3k_sbean.pet_guard_change_req.new()
	bean.petGuardId = petGuardId
	i3k_game_send_str_cmd(bean, "pet_guard_change_res")
end

function i3k_sbean.pet_guard_change_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetCurPetGuard(req.petGuardId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "refreshAllInfo")
		local player = i3k_game_get_player()
		local pets = player:GetMercenaries()
		if pets then
			for k, v in pairs(pets) do
				v:DetachPetGuard()
				if g_i3k_game_context:GetPetGuardIsShow() then
					v:SetCurPetGuardId(req.petGuardId)
					if not v:IsDead() then
						v:AttachPetGuard(g_i3k_game_context:GetCurPetGuard())
					end
				else
					v:SetCurPetGuardId(nil)
				end
			end
		end
	end
end

function i3k_sbean.pet_guard_show(isShow)
	local bean = i3k_sbean.pet_guard_show_req.new()
	bean.isShow = isShow and 0 or 1
	i3k_game_send_str_cmd(bean, "pet_guard_show_res")
end

function i3k_sbean.pet_guard_show_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetPetGuardIsShow(req.isShow)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "UpdateIsShow")
		local player = i3k_game_get_player()
		local pets = player:GetMercenaries()
		if pets then
			for k, v in pairs(pets) do
				v:DetachPetGuard()
				if req.isShow == 1 then
					v:SetCurPetGuardId(nil)
				else
					v:SetCurPetGuardId(g_i3k_game_context:GetCurPetGuard())
					if not v:IsDead() then
						v:AttachPetGuard(g_i3k_game_context:GetCurPetGuard())
					end
				end
			end
		end
	end
end

function i3k_sbean.pet_guard_sync.handler(bean)
	g_i3k_game_context:SetPetGuardInfo(bean.petGuard)
end


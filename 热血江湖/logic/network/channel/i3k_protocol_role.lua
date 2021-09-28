------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
function i3k_sbean.role_base.handler(bean)
	if g_i3k_game_context then
		local _ch = { };
		_ch._id				= bean.id
		_ch._name			= bean.name
		_ch._ctype			= bean.classType
		_ch._gender			= bean.gender
		_ch._transformlvl 	= bean.transformLevel
		_ch._bwtype			= bean.bwType
		_ch._viplvl			= bean.vipLvl
		_ch._level			= bean.level
		_ch._exp			= bean.exp
		_ch._hpPool 		= bean.hpPool
		_ch._lastUseHpPoolTime = bean.lastUseHpPoolTime
		_ch._pkValue		= bean.pkValue
		_ch._vit 			= bean.vit
		_ch._headIcon		= bean.headIcon
		_ch._frameIcon		= bean.headBorder
		_ch._hair			= bean.hair
		_ch._face			= bean.face
		_ch._lastUseHpTime 	= bean.lastUseHpTime
		_ch._dayBuyCoinTimes = bean.dayBuyCoinTimes
		_ch._dayBuyVitTimes   = bean.dayBuyVitTimes
		_ch._vitRevertTime	= bean.vitRevertTime
		_ch._dayUseItemsTimes = bean.dayUseItemsTimes
		_ch._nextLeaveWrongPosTime = bean.nextLeaveWrongPosTime
		_ch._charm			= bean.charm
		_ch._loginDays		= bean.loginDays
		_ch._expVolume		= bean.expVolume
		_ch._credit			= bean.credit   
		_ch._sectDonationHonor = bean.sectDonationHonor
		g_i3k_game_context:setloginHeadIcon(_ch._gender,_ch._hair,_ch._face)
		g_i3k_game_context:SetCurrentCharacter(_ch)
		g_i3k_game_context:SetCurrencyInfo(bean.diamondF, bean.diamondR, bean.coinF, bean.coinR, bean.bonus, bean.dragoncoin, bean.fame)
		g_i3k_game_context:SetEnergyInfo(bean.equipEnergy, bean.gemEnergy, bean.bookInspiration)
		g_i3k_game_context:SetLoginDays(bean.loginDays)
		g_i3k_game_context:SetReviveTickLine(bean.lastReviveTime)
		g_i3k_game_context:SetRoleCreateTime(bean.createTime)----
		g_i3k_game_context:SetRoleLevelUpTime(bean.lastLevelUpTime)
		g_i3k_game_context:SetProductionSplit(bean.spliteSP)
		g_i3k_game_context:SetSectContribution(bean.sectContribution)
	end

	return true;
end

-- 月卡更新信息
--[[function i3k_sbean.role_monthlycard.handler(bean)
	g_i3k_game_context:SetMonthlyCardEndTime(bean.info)
end--]]

function i3k_sbean.role_bag.handler(bean)
--	local bag = bean.bag
--	local bagSize = bag.cellSize
--	local bagIndex = bag.expandTimes
--	local items = bag.bagItems

--	local bagItems = {equips={}, items={}, useCellSize=0}
--	for k, v in pairs(items) do
--		if g_i3k_db.i3k_db_get_common_item_type(k) == g_COMMON_ITEM_TYPE_EQUIP then
--			for kk, vv in pairs(v.equips) do
--				local equip = g_i3k_get_equip_from_bean(vv)
--				table.insert(bagItems.equips, equip)
--				bagItems.useCellSize = bagItems.useCellSize + 1
--			end
--		else
--			local item = {itemid = v.id, item_count = v.count}
--			table.insert(bagItems.items, item)
--			local stack_max = g_i3k_db.i3k_db_get_bag_item_stack_max(v.id)
--			bagItems.useCellSize = bagItems.useCellSize + g_i3k_get_use_bag_cell_size(v.count, stack_max)
--		end
--	end
	g_i3k_game_context:SetBagInfo(bean.bag.cellSize, bean.bag.expandTimes, bean.bag.items)
end

-- 同步角色穿戴信息
function i3k_sbean.role_wear.handler(bean)
	local wearParts = bean.wearParts
	local wearEquips = bean.wearEquips
	local size = #wearParts
	local wEquips = {}
	for i,v in pairs(wearParts) do
		local partid = v.id--args:pop_int()
		wEquips[partid] = {}

		wEquips[partid].eqGrowLvl = v.eqGrowLvl--args:pop_int()--???ˉμè??
		wEquips[partid].eqEvoLvl = v.eqEvoLvl--args:pop_int()--D???
		wEquips[partid].effectInfo = v.show --武器特效的显示，未设置里面等级字段为-1
		wEquips[partid].breakLvl = v.extra and v.extra.eqGrowBreakLvl or 0 --装备的突破等级
		local slots = wearParts[i].eqSlots
		local _count = #slots
		local _tmp = {}
		for i=1,_count do
			_tmp[i] = slots[i]--args:pop_int()
		end
		wEquips[partid].slot = _tmp
		wEquips[partid].upCount = v.upcnt
		wEquips[partid].gemBless = v.gemBless
	end

	local _size = #wearEquips

	for i,v in pairs(wearEquips) do
		local equip = {}
		equip.equip_id = wearEquips[i].equip.id
		equip.equip_guid = wearEquips[i].equip.guid
		local temp = {}
		for j=1, #wearEquips[i].equip.addValues do
			temp[j] = wearEquips[i].equip.addValues[j]
		end
		equip.attribute = temp
		equip.naijiu = wearEquips[i].equip.durability
		equip.refine = wearEquips[i].equip.refine
		equip.legends = wearEquips[i].equip.legends
		equip.smeltingProps = wearEquips[i].equip.smeltingProps
		equip.hammerSkill = wearEquips[i].equip.hammerSkill
		wEquips[i].equip = equip
	end

	g_i3k_game_context:SetWearEquips(wEquips)
	return true;
end

-- 同步角色套装收集信息
function i3k_sbean.role_suite.handler(bean,res)
	local t = bean.suites
	local data1 = {}
	local data2 = {}
	for k,v in pairs(t) do
		local id = tonumber(k)
		for a,b in pairs(v.collect) do
			b = tonumber(a)
			if data1[id] then
				 table.insert(data1[id],b)
			else
				 data1[id] = {}
				table.insert(data1[id],b)
			end
			data2[b] = id
		end
	end

	g_i3k_game_context:SetHaveSuitEquipData(data1)
	g_i3k_game_context:SetSuitSeach(data2)
	g_i3k_game_context:LoadSuitData()
end

-- 同步角色技能信息
function i3k_sbean.role_skill.handler(bean)
	if g_i3k_game_context then
		local askills = { };
		local cskills = { };

		local aexskills = {}
		local skills = bean.skills
		local curSkills = bean.curSkills
		local curUniqueSkill = bean.curUniqueSkill--当前装备的绝技

		for i,v in pairs(skills) do
			local iscurrent = false
			local id = skills[i].id
			local lvl = skills[i].level
			local bourn = skills[i].bourn
			for k,e in ipairs (i3k_db_exskills) do ---绝技
				for _,a in pairs (e.skills) do ---绝技
					if id == a then
						iscurrent = true
						local sortId = i3k_db_exskills[k].sortid
						aexskills[id] = { id = id, lvl = lvl, state = bourn ,sortId = sortId}
						break
					end
				end
				if iscurrent then
					break
				end
			end
			if not iscurrent  then
				askills[id] = { id = id, lvl = lvl, state = bourn }
			end
		end
		for i,v in pairs(curSkills) do
			table.insert(cskills, curSkills[i]);
		end
		g_i3k_game_context:SetRoleSkills(askills, cskills);
		g_i3k_game_context:SetRoleUniqueSkills(aexskills, curUniqueSkill)--设置绝技
	end

	return true;
end

-- 同步角色心法信息
function i3k_sbean.role_spirit.handler(bean)
	if g_i3k_game_context then
		local spirits = bean.spirits
		for k,v in pairs(spirits) do
			local id = spirits[k].id--args:pop_int()
			local level = spirits[k].level--args:pop_int()
			local typeXinfa = i3k_db_xinfa[id].type
			if typeXinfa == 1 then
				g_i3k_game_context:SetZhiyeXF(id,level)

			elseif typeXinfa == 2 then
				g_i3k_game_context:SetJianghuXF(id,level)

			elseif typeXinfa == 3 then
				g_i3k_game_context:SetPaibieXF(id,level)
			end
		end
		g_i3k_game_context:CleanUseXinfaData()
		local curSpirits = bean.curSpirits

		if not g_i3k_game_context:getFiveTrans() then
			g_i3k_game_context:setUseXinfaData(curSpirits) -- 存一下
		else
			local count  = #curSpirits--args:pop_int()
			for i=1 ,count do
				local id = curSpirits[i]--args:pop_int()
				g_i3k_game_context:SetUseXinfa(id)
			end
		end
	end

	return true;
end

-- 同步角色神兵信息
function i3k_sbean.role_weapon.handler(res)
	if g_i3k_game_context then

		local task = res.task
		local taskType = task.type
		local id = task.id
		local size = #task.values
		local dayLoopCount = task.dayLoopCount

		local values = task.values
		local tmp = {}
		for i=1,size do
			local value = values[i]--args:pop_int()
			tmp[i] = value
		end

		local type1 = i3k_db_weapon_task[taskType][id].type1
		local type2 = i3k_db_weapon_task[taskType][id].type2
		if type1 == g_TASK_TOATL_DAYS then
			tmp[1] = g_i3k_game_context:GetLoginDays()
		end
		if type2 == g_TASK_TOATL_DAYS then
			tmp[2] = g_i3k_game_context:GetLoginDays()
		end

		if type1 == g_TASK_REACH_LEVEL then
			tmp[1] = g_i3k_game_context:GetLevel()
		end
		if type2 == g_TASK_REACH_LEVEL then
			tmp[2] = g_i3k_game_context:GetLevel()
		end
		--g_i3k_game_context:setRemmeberTaskId(2,id)
		g_i3k_game_context:SetTaskDataList(TASK_CATEGORY_WEAPON, task.receiveTime)
		g_i3k_game_context:setWeaponTaskData(id,taskType,tmp,dayLoopCount)
	end
	local weapons = res.weapons
	for k,v in pairs(weapons) do
		local id = weapons[k].id
		local level = weapons[k].level
		local star = weapons[k].star
		local exp = weapons[k].exp
		local canUseTalentPoint = weapons[k].canUseTalentPoint
		local uniqueSkill = weapons[k].uniqueSkill
		local isOpen = uniqueSkill.open
		local mastery = uniqueSkill.master
		local form = weapons[k].form
		local awake = weapons[k].awake
		for a,b in ipairs(weapons[k].skills) do
			local skillId =	a
			local skillLvl = b
			g_i3k_game_context:SetShenBingUpSkillData(id,skillId,skillLvl)
		end
		for i,e in ipairs(weapons[k].talent) do
			local talentId = i
			local talentPoint = e
			g_i3k_game_context:SetShenBingTalentData(id,talentId,talentPoint)
		end
		g_i3k_game_context:SetShenBingUniqueSkillData(id,isOpen,mastery,form)
		g_i3k_game_context:SetShenBingCanUseTalentPoint(id,canUseTalentPoint)
		g_i3k_game_context:SetShenbingData(id,level,star,exp)
		g_i3k_game_context:SetShenBingAwakeData(id, awake)
	end

	local id = res.curWeapon
	g_i3k_game_context:SetUseShenbing(id)

	g_i3k_game_context:InitShenBingAllTalentPoint() --初始化神兵天赋点数

	for k,v in pairs(weapons) do
		local id = weapons[k].id
		local haveInput = g_i3k_game_context:GetShenBingAllTalentPoint(id)
		local canUse = g_i3k_game_context:GetShenBingCanUseTalentPoint(id)
		local gameGive = i3k_db_shen_bing_talent_init.init_talentPoint_counts[1]
		local haveBuy = haveInput + canUse - gameGive
		g_i3k_game_context:SetHaveBuyShenBingTalentPoint(id,haveBuy)
	end

	for i=1,#i3k_db_shen_bing do
		g_i3k_game_context:SetShenbingTalentRedPointRecord(i,false)
	end
	g_i3k_game_context:setWeaponNpcEnterTimes(res.dayEnterMapTimes)
	g_i3k_game_context:setWeaponSpecialCollTime(res.nextUSkillCanTrigTime)
end



function i3k_sbean.role_pet.handler(bean)
	local pets = bean.pets
	g_i3k_game_context:ClearPetLifeTask()
	local num = 0
	for a,b in pairs(pets) do
		for	a1,b1 in pairs(b.fightPet.curSpirits) do
			num = num + b1.level
		end
	end
	if pets then
		for i,v in pairs(pets) do
			local id = v.fightPet.id
			local level = v.fightPet.level
			local exp = v.exp
			local transfer = v.transformLvl
			local starlvl = v.fightPet.star
			local tupoSkill = v.fightPet.breakSkills
			local spirits = v.fightPet.curSpirits
			local skill = v.fightPet.skill
			local exploit = v.exploit
			local petName = v.name
			g_i3k_game_context:SetMercenarySkillData(i, skill)
			local mapLogs = v.mapLogs
			for k,v in pairs(mapLogs) do
				g_i3k_game_context:AddPetDungeonData(id,k)
			end
			if level ~= 0 then
				g_i3k_game_context:SetYongbingData(id,level,exp,starlvl,transfer,tupoSkill, spirits, exploit, petName)
			end
			local task = v.task
			local lifetask = v.lifetask
			local taskId = task.id
			local value = task.value
			local lifeTaskId = lifetask.id
			local lifeTaskValue = lifetask.value
			local lifeTaskReward = lifetask.reward
			if taskId ~= 0 then
				local taskType = i3k_db_pet_task[taskId].type
				if taskType == g_TASK_TOATL_DAYS then
					value = g_i3k_game_context:GetLoginDays()
				end
			end
			g_i3k_game_context:SetDailyCompleteTask(i, v.dailyCompleteTask)
			g_i3k_game_context:setOnePetTask(i,taskId,value)
			g_i3k_game_context:setOnePetLifeTask(i, lifeTaskId, lifeTaskValue, lifeTaskReward)
			g_i3k_game_context:setPetWaken(i, v.awake)
			local lvl,_value = g_i3k_db.i3k_db_get_pet_fri_lvl_by_value(i,v.coPracticeExp)
			g_i3k_game_context:SetYongbingOtherData(i,lvl,_value)
		end
		--登录同步宠物按战力降序排序的列表
		g_i3k_game_context:SortPetByPower()
	end

	g_i3k_game_context:CleanFactionDungeonPlayPet()
	g_i3k_game_context:CleanDungeonPlayPet()
	local worldMapPets = bean.worldMapPets
	local privateMapPets = bean.privateMapPets
	local sectMapPets = bean.sectMapPets
	for k,v in pairs(worldMapPets) do
		g_i3k_game_context:SetYongbingPlay(k,FIELD)
	end

	for k,v in pairs(privateMapPets) do
		g_i3k_game_context:SetYongbingPlay(k,DUNGEON)
	end

	for k,v in pairs(sectMapPets) do
		g_i3k_game_context:SetYongbingPlay(k,FACTION_DUNGEON)
	end

	g_i3k_game_context:SetNormalDungeonPets(bean.privateMapPets) --单人副本佣兵设置
	g_i3k_game_context:SetActivityPets(bean.activityMapPets) --活动副本佣兵设置
	g_i3k_game_context:SetFactionDungeonPets(bean.sectMapPets) --帮派副本佣兵设置

end

function i3k_sbean.role_task.handler(bean)
	if g_i3k_game_context then
		local task = bean.task
		local id = task.id

		local taskType = i3k_db_main_line_task[id].type

		local value = 0
		if taskType == g_TASK_TOATL_DAYS then
			value = g_i3k_game_context:GetLoginDays()
		else
			value = task.value
		end
		--g_i3k_game_context:setRemmeberTaskId(1,id)
		g_i3k_game_context:setMainTaskIdAndValue(id,value,task.state)
		g_i3k_game_context:SetTaskDataList(TASK_CATEGORY_MAIN, task.receiveTime)
	end

	return true;
end

--同步支线任务
function i3k_sbean.role_branch_task.handler(bean)
	--self.tasks:		map[int32, DBBranchTask]
	if g_i3k_game_context and bean then
		local tasks = bean.tasks
		g_i3k_game_context:setSubLineTask(tasks)
	end
end

--同步姻缘系列任务
function i3k_sbean.role_mrgtask.handler(bean)
	if g_i3k_game_context and bean then
		local task = bean.task
		g_i3k_game_context:SetMarriageTaskData(task.series, task.loop, task.open)
	end
end

--同步史诗任务
function i3k_sbean.role_epic_task.handler(bean)
	if g_i3k_game_context and bean then
		g_i3k_game_context:SetEpicTaskData(bean.tasks)
	end
end

--同步赏金任务
function i3k_sbean.global_world_task_sync.handler(bean)
	local iskong = next(bean.tasks) == nil
	if g_i3k_game_context and bean then
		g_i3k_game_context:SetGlobalWorldTask(bean.tasks)
		if g_i3k_game_context:GetLevel() >= i3k_db_war_zone_map_cfg.needLvl then
			g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_GLOBALWORLD, i3k_game_get_time())
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"refresh")
		end
	end
end
-- 登录后同步的普通副本地图进度信息
function i3k_sbean.role_normal_mapcopy_log.handler(bean,res)
	for k,v in pairs(bean.logs) do--v.rewardTimes
		g_i3k_game_context:SetDungeonData(k, v.finishTimes, v.enterTimes, v.bestScore, v.dayEnterTimes, v.dayBuyTimes,v.rewardTimes)
	end
end

function i3k_sbean.role_diyskill.handler(bean)
 	local myEquipDiySkill = bean.diySkill
	g_i3k_game_context:SetClanDiySkillTimes(bean.diyskillTimes)
	g_i3k_game_context:setDiySkillAndBorrowSkill(nil, nil)
	if myEquipDiySkill == nil then
		g_i3k_game_context:setCreateKungfuSkillIcon(0)
		g_i3k_game_context:setCurrentSkillID(0)
		g_i3k_game_context:setCreateKungfuData(nil)
		g_i3k_game_context:setCurrentSkillGradeId(nil)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateRoleDIYSkill", g_i3k_game_context:GetCurrentDIYSkillId(), g_i3k_game_context:GetCurrentDIYSkillIconId())
	else
		local id = myEquipDiySkill.id
		local t = {}
		t[id] = myEquipDiySkill
		g_i3k_game_context:setCreateKungfuSkillIcon(myEquipDiySkill.iconId)
		g_i3k_game_context:setCurrentSkillID(id)
		g_i3k_game_context:setCreateKungfuData(t)
		g_i3k_game_context:setCurrentSkillGradeId(myEquipDiySkill.diySkillData.gradeId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateRoleDIYSkill", g_i3k_game_context:GetCurrentDIYSkillId(), g_i3k_game_context:GetCurrentDIYSkillIconId(), myEquipDiySkill.diySkillData.gradeId)
	end
end

--function i3k_sbean.role_clan.handler(res)
--	g_i3k_game_context:SetCreateClanId(res.createClan)
--	g_i3k_game_context:SetAddClanList(res.addClans or {})
--	if res.createClan ~= 0 then
--		DCAccount.removeTag("拥有宗门", "")
--		DCAccount.addTag("拥有宗门",1)
--	elseif #res.addClans ~= 0 then
--		DCAccount.removeTag("拥有宗门", "")
--		DCAccount.addTag("拥有宗门",#res.addClans)
--	end
--
--end

-- 同步角色帮派名字和职位
function i3k_sbean.role_sectinfo.handler(bean, res)
	--self.info:		SectBrief
	--self.sectID:		int32
	--self.sectName:		string
	--self.sectPosition:		int8
	--self.sectIcon:		int16
	local info = bean.info
	g_i3k_game_context:SetSectId(info.sectID)
	g_i3k_game_context:SetFactionSectId(info.sectID)
	g_i3k_game_context:SetSectName(info.sectName)
	g_i3k_game_context:SetSectPosition(info.sectPosition)
	g_i3k_game_context:SetSectTitleIcon(info.sectIcon)
	g_i3k_game_context:setSectFactionLevel(info.sectLevel)
	local hero = i3k_game_get_player_hero();
	if hero then
		hero:ChangeSectName(info.sectName,info.sectPosition)
		hero:TitleColorTest();
	end

	if info.sectID == 0 then
		local roleId = g_i3k_game_context:getFactionTaskRoleId()
		g_i3k_game_context:removeFinishFactionTask(roleId)
		g_i3k_game_context:CancelEscortRes()
		g_i3k_game_context:RemoveAllEscortForHelpStr()
	else
		g_i3k_game_context:UpdateSubLineTaskValue(g_TASK_JOIN_FACTION,0)
	end
end

-- -1是劫镖，并且已经攻击了 0是没有劫镖状态 1是劫镖状态，并且没有攻击镖车
function i3k_sbean.role_rob_flag.handler(res)
	local flag = res.flag
	if flag then
		if flag == 0 then
			g_i3k_game_context:SetRobState(0)
			g_i3k_game_context:SetEscortRobState(0)
		elseif flag == -1 or flag == 1 then
			g_i3k_game_context:SetRobState(1)
			g_i3k_game_context:SetEscortRobState(1)
		end
	end
end

-- 登录时同步运镖信息
function i3k_sbean.role_sect_deliver.handler(res)
	local sectdeliver = res.sectdeliver
	g_i3k_game_context:SetFactionEscortSys(sectdeliver)
	g_i3k_game_context:SetFactionEscortPathId(sectdeliver.curRouteId)
	g_i3k_game_context:SetFactionEscortTaskId(sectdeliver.curTaskId)
	g_i3k_game_context:SetFactionEscortRefreshTimes(sectdeliver.refreshTimes)
	--g_i3k_game_context:setRemmeberTaskId(8,sectdeliver.curTaskId)
	g_i3k_game_context:SetFactionEscortRobTimes(sectdeliver.dayRobTime)
	g_i3k_game_context:SetFactionEscortAccTimes(sectdeliver.dayAcceptTime)
	g_i3k_game_context:SetEscortStoreMoney(sectdeliver.robMoney)
	g_i3k_game_context:SetEsortIsProtect(sectdeliver.isProtect)
	g_i3k_game_context:SetFactionEscortLuckInfo(sectdeliver.deliverLottery)
	g_i3k_game_context:SetEscortQuickCard(sectdeliver.quickDeliverBouns)
	if sectdeliver.curTaskId > 0 then
		g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_ESCORT, sectdeliver.startTime)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateFactionEscort")
	end
	if sectdeliver.curTaskId ~= 0 then
		g_i3k_game_context:SetTransportState(1)
		g_i3k_game_context:EscortCarStopMoveSync()
	else
		g_i3k_game_context:SetTransportState(0)
	end
end

--加劫镖的钱
function i3k_sbean.role_add_robmoney.handler(res)
	g_i3k_game_context:AddEscortStoreMoney(res.value)
	if not i3k_dataeye_itemtype(res.reason) then
		DCItem.get(g_BASE_ITEM_ESCORTT_MONEY, "赏金点", res.value, res.reason)
	end
end

-- 同步角色帮派光环信息
--Packet:role_sectaura
function i3k_sbean.role_sectaura.handler(res)
	local auras = res.auras
	local t = {}
	for k,v in pairs(auras) do
		t[k] = {}
		t[k].level = v
	end
	g_i3k_game_context:SetFactionSkillData(t)

	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UpdateFactionSkillProps()
	end
end

-- 同步角色帮派任务信息
function i3k_sbean.role_secttask.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local task = bean.task
	local data = task.task
	local sid = data.sid
	local taskId = data.taskId

	local value = task.value
	local ownerId = task.ownerId
	local ownerName = task.ownerName
	local receiveTime = task.receiveTime

	if ownerId == 0 then
		return
	end
	local tmp = {}
	tmp.taskID = taskId
	tmp.value = value
	tmp.roleID = ownerId
	tmp.roleName = ownerName
	tmp.receiveTime = receiveTime
	--g_i3k_game_context:setRemmeberTaskId(4,taskId)
	g_i3k_game_context:SetTaskDataList( TASK_CATEGORY_SECT, receiveTime)
	g_i3k_game_context:setFactionCurrentTask(ownerId,sid,value,taskId,ownerName,receiveTime)

end

function i3k_sbean.role_team.handler(bean)
	local mapType = i3k_game_get_map_type()
	if mapType ~= g_FORCE_WAR then
		g_i3k_game_context:SetMyTeam(bean.team.id, bean.team.leader, bean.team.members)
	end
end

function i3k_sbean.role_mroom.handler(bean,res)
	local room = bean.room

	local roomid = room.id
	local mapID = room.mapId
	local leader = room.leader

	local members = room.members
	local createTime = room.createTime

	local count = 0

	for k,v in pairs(members) do
		count = count + 1
	end
	g_i3k_game_context:SetRoomRoleCount(count)
	g_i3k_game_context:SetRoomCreateTime(createTime)
	g_i3k_game_context:SetRoomLeaderID(leader)
	g_i3k_game_context:SetRoomID(roomid)
	g_i3k_game_context:SetMapID(mapID)
	g_i3k_game_context:SetRoomType(room.type)
end
--好友基础信息
function i3k_sbean.role_friends.handler(bean)
	if g_i3k_game_context then
		local friends = bean.friends
		if friends then
			g_i3k_game_context:SetFriendsData(friends)
		end
	end
end
--同步竞技场进入次数
function i3k_sbean.role_arena_entertimes.handler(bean)
	if g_i3k_game_context then
		local enterTime = bean.enterTime
		if enterTime then
			g_i3k_game_context:SetArenaEnterTimes(enterTime)
		end
	end
end
--同步聊天数据
function i3k_sbean.role_msg.handler(bean)
	if g_i3k_game_context then
		local msgs = bean.msgs
		if msgs then
			for i,e in ipairs(msgs) do
				g_i3k_game_context:parseChatData(e)
			end
		end
	end
end

function i3k_sbean.query_rolebrief(rid, arg)
	local query = i3k_sbean.query_rolebrief_req.new()
	query.rid = rid
	if arg.arena then
		query.arena = true
		query.value = arg.value
	elseif arg.faction then
		query.faction = true
	elseif arg.clan then
		query.clan = true
	elseif arg.chat then
		query.chat = true
	elseif arg.isPriviteChat then
		query.isPriviteChat = true
		query.msgType = arg.msgType
	end
	query.srcSectId = arg.srcSectId
	i3k_game_send_str_cmd(query, "query_rolebrief_res")
end

function i3k_sbean.query_rolebrief_res.handler(bean, req)
	local brief = bean.brief
	if not brief then
		return
	end
	local roleOverview = brief.overview
	local roleModel = brief.model

	if req.arena then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaRank, "changeModel", roleOverview.type, roleOverview.bwType, roleOverview.gender, roleModel.face, roleModel.hair, roleModel.equips, roleModel.curFashions, roleModel.showFashionTypes, roleModel.equipParts, roleModel.armor, req.value, roleModel.weaponSoulShow, nil, roleModel.soaringDisplay)
	elseif req.faction then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionWorship, "changeModel", roleOverview.type, roleOverview.bwType, roleOverview.gender, roleModel.face, roleModel.hair, roleModel.equips, roleModel.curFashions,roleModel.showFashionTypes,roleModel.equipParts, roleModel.armor, roleModel.weaponSoulShow, nil, roleModel.soaringDisplay)
	elseif req.clan then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ClanMineLayer, "changeModel", roleOverview.type, roleOverview.bwType, roleOverview.gender, roleModel.face, roleModel.hair, roleModel.equips, roleModel.curFashions,roleModel.showFashionTypes,roleModel.equipParts, roleModel.armor, roleModel.weaponSoulShow, nil, roleModel.soaringDisplay)
	elseif req.chat or req.isPriviteChat then
		local player = {}
		player.msgType = req.msgType
		player.id = req.rid
		player.name = roleOverview.name
		player.iconId = roleOverview.headIcon
		player.bwType = roleOverview.bwType
		player.headBorder = roleOverview.headBorder
		player.level = roleOverview.level
		player.fightPower = roleOverview.fightPower
		player.gender = roleOverview.gender
		player.srcSectId = req.srcSectId or 0
		player.msgContent = {}
		player.teamID = bean.teamID
		local recentChatData = g_i3k_game_context:GetRecentChatData()
		for i,v in ipairs(recentChatData) do
			if math.abs(v.id)==req.rid then
				player.msgContent = v.msgContent
				break;
			end
		end
		g_i3k_ui_mgr:OpenUI(eUIID_ChatFC)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChatFC, player, req.isPriviteChat)
	end

end
--------------------------------------------------------------------
-- 获取玩家的特性信息
function i3k_sbean.query_rolefeature(playerId, index, rank)
	local data = i3k_sbean.query_rolefeature_req.new()
	data.rid = playerId
	data.index = index
	data.rank = rank
	i3k_game_send_str_cmd(data, "query_rolefeature_res")
end

function i3k_sbean.query_rolefeature_res.handler(bean, req)
	local data = bean.feature
	if data then
		if req.index  then
			g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleInfo)
			g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleInfo, data, req.rank, req.index)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_QueryRoleFeature)
			g_i3k_ui_mgr:RefreshUI(eUIID_QueryRoleFeature, data)
		end

	end
end

--查看荣耀殿堂雕像信息
function i3k_sbean.showStatueInfo(roleID, statueType)
	local data = i3k_sbean.honnor_statue_get_fightteam_statue_req.new()
	data.rid = roleID
	data.statueType = statueType
	i3k_game_send_str_cmd(data, "honnor_statue_get_fightteam_statue_res")
end

function i3k_sbean.honnor_statue_get_fightteam_statue_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_StatueInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_StatueInfo, res.feature, req.statueType)
	end
end

--荣耀殿堂敬礼功能
function i3k_sbean.statueSalute(statueType, rid, exp)
	local data = i3k_sbean.honnor_statue_interation_req.new()
	data.statueType = statueType
	data.rid = rid
	data.exp = exp
	i3k_game_send_str_cmd(data, "honnor_statue_interation_res")
end

function i3k_sbean.honnor_statue_interation_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo({{id = 1000, count = req.exp}})
	elseif res.ok == -101 then
		g_i3k_ui_mgr:PopupTipMessage("今日次数已用完")
	end
end


-- 查询机器人信息响应
function i3k_sbean.query_robot(rid, value)
	local query = i3k_sbean.query_robot_req.new()
	query.rid = rid
	query.rank = value.rank
	query.role = value.role
	query.sectData = value.sectData
	i3k_game_send_str_cmd(query, i3k_sbean.query_robot_res.getName())
end

function i3k_sbean.query_robot_res.handler(bean, req)
	local brief = bean.brief
	if not brief then
		return
	end
	local roleOverview = brief.overview
	local roleModel = brief.model
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaRank, "changeModel", roleOverview.type, roleOverview.bwType, roleOverview.gender, roleModel.face, roleModel.hair, roleModel.equips, roleModel.curFashions, roleModel.showFashionTypes, nil, roleModel.armor, {rank = req.rank, role = req.role, sectData = req.sectData}, roleModel.weaponSoulShow, nil, roleModel.soaringDisplay)
end


function i3k_sbean.transToNpc(mapId, npcId)
	if i3k_check_resources_downloaded(mapId) then
		local trans = i3k_sbean.teleport_npc_req.new()
		trans.npcId = npcId
		trans.mapId = mapId
		i3k_game_send_str_cmd(trans, "teleport_npc_res")
	end
end

function i3k_sbean.teleport_npc_res.handler(bean, res)
	if bean.ok~=1 then
		local str = string.format("%s", "传送失败")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		g_i3k_game_context:SetSuperOnHookValid(false)
		local needId = i3k_db_common.activity.transNeedItemId
		-- g_i3k_game_context:UseCommonItem(needId, 1,AT_TELEPORT_NPC)
		g_i3k_game_context:UseTrans(needId, 1, AT_TELEPORT_NPC)
		releaseSchedule()
		g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleMiniMap)
	end
end

function i3k_sbean.transToMonster(mapId, monsterPointId, callback)
	if i3k_check_resources_downloaded(mapId) then
		local trans = i3k_sbean.teleport_monster_req.new()
		trans.spawnPointId = monsterPointId
		trans.mapId = mapId
		i3k_game_send_str_cmd(trans, "teleport_monster_res")
	end
end

function i3k_sbean.teleport_monster_res.handler(bean)
	if bean.ok~=1 then
		local str = string.format("%s", "传送失败")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		g_i3k_game_context:SetSuperOnHookValid(false)
		local needId = i3k_db_common.activity.transNeedItemId
		-- g_i3k_game_context:UseCommonItem(needId, 1,AT_TELEPORT_MONSTER)
		g_i3k_game_context:UseTrans(needId, 1, AT_TELEPORT_MONSTER)
		releaseSchedule()
		g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleMiniMap)
	end
end

function i3k_sbean.transToMinePoint(mapId,mineralPointId)
	if i3k_check_resources_downloaded(mapId) then
		local trans = i3k_sbean.teleport_mineral_req.new()
		trans.mineralPointId = mineralPointId
		trans.mapId = mapId
		i3k_game_send_str_cmd(trans, "teleport_mineral_res")
	end
end

function i3k_sbean.teleport_mineral_res.handler(bean)
	if bean.ok~=1 then
		local str = string.format("%s", "传送失败")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		g_i3k_game_context:SetSuperOnHookValid(false)
		local needId = i3k_db_common.activity.transNeedItemId
		-- g_i3k_game_context:UseCommonItem(needId, 1,AT_TELEPORT_MINERAL)
		g_i3k_game_context:UseTrans(needId, 1, AT_TELEPORT_MINERAL)
		releaseSchedule()
		g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleMiniMap)
	end
end

function i3k_sbean.role_activity_mapgroup_log.handler(bean)
	local logs = bean.logs
	g_i3k_game_context:setActivityLogs(logs)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadDailyActivityReal")
end

function i3k_sbean.role_curfashions.handler(bean)
	g_i3k_game_context:SetFashionData(bean.curFashions, bean.allFashions)
end


--同步幻形信息
function i3k_sbean.role_transform_info.handler(bean)
	g_i3k_game_context:SetMetamorphosisInfo(bean.info.curTransform, bean.info.transforms)
end

function i3k_sbean.wrongpos_leave_res.handler(bean)
	if bean.ok == 1 then
		local intervalTime = g_i3k_db.i3k_db_get_common_cfg().game_set.breakDeathTime
		g_i3k_game_context:SetBreakDeathData(i3k_game_get_time() + intervalTime)
		g_i3k_logic:OpenBattleUI()
		g_i3k_ui_mgr:PopupTipMessage(string.format("成功使用了脱离卡死功能"))
	end
end

--登录时同步离线经验相关数据
function i3k_sbean.role_offlineexp.handler(bean)
	local info = bean.info
	g_i3k_game_context:SetOfflineExpData(info.accTimeTotal, info.accExpTotal, info.dailyOfflineExp, info.accDrops, bean.hide)
end

-- 离线经验奖励领取协议
function i3k_sbean.offlineexp_take(accTime, doubleExp, needPoint)
	local data = i3k_sbean.offlineexp_take_req.new()
	data.accTime = accTime
	data.doubleExp = doubleExp
	data.needPoint = needPoint
	i3k_game_send_str_cmd(data, "offlineexp_take_res")
end

function i3k_sbean.offlineexp_take_res.handler(bean, req)
	local offlineRewards = bean.offlineRewards
	if offlineRewards.exp > 0 then
		local offlineRewards = bean.offlineRewards
		g_i3k_game_context:SetOfflineExpTake(offlineRewards.exp, req.doubleExp, req.needPoint, offlineRewards.items,offlineRewards.realExp)
	elseif offlineRewards.exp == -1 then -- 背包已满
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	elseif offlineRewards.exp == -2 then -- 修炼点不足
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(385))
	else
		g_i3k_ui_mgr:PopupTipMessage("离线经验领取错误")
	end
end


--通知玩家被禁言---
function i3k_sbean.role_chat_banned.handler(bean)
	--self.leftTime:		int32
	--self.reason:		string
	local reason = bean.reason
	local leftTime = bean.leftTime
	if leftTime ~= 0 then
		local leftTimeStr = math.modf(leftTime / 60)
		leftTimeStr = leftTimeStr == 0 and 1 or leftTimeStr
		local msg = leftTime > 0 and string.format("帐号被封禁，距离解封还剩%d%s",leftTimeStr,"分钟") or "帐号永久封禁"
		msg = reason .. msg .. ",请联系客服人员"
		g_i3k_ui_mgr:ShowMessageBox2(msg)
	end
end


-- 同步势力战信息(登录时同步)
--Packet:role_forcewar
function i3k_sbean.role_forcewar.handler(bean)
	local joinTime	 = bean.joinTime  --是否报名
	local weekFeats = bean.weekFeats   --每周获得武勋
	local totalFeats = bean.totalFeats --历史获得的武勋
	local room = bean.room
	g_i3k_game_context:setForceWarLotteryNum(bean.totalLotteryCnt)
	g_i3k_game_context:setTodayForceWarTimes(bean.dayGainLotteryCnt)
	g_i3k_game_context:setForceWarAddFeat(totalFeats)
	g_i3k_game_context:setForceWarAddWeekFeats(weekFeats)
	if joinTime~=0 then
		g_i3k_game_context:InMatchingState(bean.joinTime, g_FORCE_WAR_MATCH, bean.joinType)
	end
	g_i3k_game_context:setForceWarCfgInfo(joinTime,weekFeats,totalFeats)
	--jxw 加势力战房间信息
	if room and room.id~=0 then
		g_i3k_game_context:setIsOpenForceWarRoom(false)
		g_i3k_game_context:syncForceWarRoom(room.id, room.leader,room.members, room.type)
	end
end

-- 登录时同步七日留存信息
function i3k_sbean.role_rmactivity.handler(bean)
	g_i3k_game_context:SetKeepActivityPos(bean.pos)
end

--角色改名
function i3k_sbean.role_modify_name(newName,itemtype)
	local data = i3k_sbean.role_rename_req.new()
	data.newName = newName
	data.type = itemtype
	i3k_game_send_str_cmd(data, "role_rename_res")
end

function i3k_sbean.role_rename_res.handler(res,req)
	if res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("此名已被占用")
		return
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("名字非法")
		return
	elseif res.ok == -3 then
		--local surplusTime = res.banTime - i3k_game_get_time()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1772, res.banTime < 0 and 0 or math.ceil(res.banTime/3600) ))
		return
	end
	if res.ok > 0 then
		i3k_game_set_role_name_invalid_flag(false)
		i3k_game_context:stopRoleNameInvalidRemind()
		g_i3k_game_context:SetRoleName(req.newName)

		local cfg = g_i3k_db.i3k_db_get_common_cfg()
		if req.type == g_BASE_ITEM_DIAMOND then
			g_i3k_game_context:UseDiamond(cfg.changeName.moneyCount,true,AT_ROLE_RENAME)
		elseif req.type == 2 then
			g_i3k_game_context:UseCommonItem(cfg.changeName.itemID, 1)
		end
		g_i3k_ui_mgr:PopupTipMessage("改名成功")
	end
end

function i3k_sbean.role_revive_info.handler(bean)
	local times = bean.insuitReviveTimes
	g_i3k_game_context:SetRevieTimes(times, bean.cprReviveCnt)
end

--同步限制使用道具属性
function i3k_sbean.role_item_props.handler(bean)
	g_i3k_game_context:setOneTimesItem(bean.itemProps)
end

function i3k_sbean.role_life_use.handler(bean)
	g_i3k_game_context:setOneTimesItemAllCountData(bean.lifeUse)
end

--同步是否首充
function i3k_sbean.role_firstpay.handler(bean)
	g_i3k_game_context:SetIsFirstPay(bean.finished)
end

--同步名望等级
function i3k_sbean.role_fame_level.handler(bean)
	g_i3k_game_context:SetFameLevel(bean.fameLevel)
end

-- 离线精灵同步协议
function i3k_sbean.role_offline_wizard.handler(bean)
	local info = bean.offlineWizard
	g_i3k_game_context:SetOfflineWizardData(info.level, info.exp, info.funcPoint, info.dayBuyPointTimes, info.curWizard, info.wizardEndTimes)
end

-- 同步当前休闲宠物(当休闲宠物过期时)
function i3k_sbean.role_cur_wizard_pet.handler(bean)
	if bean.petId then
		g_i3k_game_context:SetCurWizard(bean.petId);
		g_i3k_game_context:CreateWizar(bean.petId);
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "updateLeftState");
	end
end

function i3k_sbean.buyWizardTime(id, time, replace)
	local data = i3k_sbean.buy_wizard_pet_time_req.new()
	data.petId = id
	data.replace = replace
	data.time = time
	i3k_game_send_str_cmd(data,"buy_wizard_pet_time_res")
end

--购买休闲宠物时间
function i3k_sbean.buy_wizard_pet_time_res.handler(bean,req)
	if bean.ok == 1 then
		i3k_sbean.wizardWishSync()
		g_i3k_ui_mgr:CloseUI(eUIID_BuyChannelSpirit)
		g_i3k_ui_mgr:CloseUI(eUIID_BuyChannelSpiritOther)
		g_i3k_game_context:SetWizardEndTimes(req.petId, req.time);
		local data = i3k_db_arder_pet[req.petId];
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "ShowWizardDays");
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "updateAdditionDesc", data);
		if req.replace == g_TYPE_REPLACE then
			g_i3k_game_context:UseCommonItem(data.replaceItemId, data.replaceItemCount, AT_BUY_WIZARD_PET_TIME)
		else
			g_i3k_game_context:UseCommonItem(data.needItemId, data.needItemCount, AT_BUY_WIZARD_PET_TIME)
		end
	end
end

-- 设置当前休闲宠物
function i3k_sbean.setCurWizardID(id)
	local data = i3k_sbean.set_cur_wizard_pet_req.new()
	data.petId = id
	i3k_game_send_str_cmd(data, "set_cur_wizard_pet_res")
end

function i3k_sbean.set_cur_wizard_pet_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "updateLeftState", true);
	end
end

-- 送宝童子信息同步
function i3k_sbean.wizardWishSync()
	local data = i3k_sbean.wizard_wish_sync_req.new()
	i3k_game_send_str_cmd(data, "wizard_wish_sync_res")
end

function i3k_sbean.wizard_wish_sync_res.handler(bean,req)
	if bean.data then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "wizardGiftData", bean.data);
	end
end

-- 送宝童子求取
function i3k_sbean.wizardWishOperate(petId)
	local data = i3k_sbean.wizard_wish_operate_req.new()
	data.petId = petId
	i3k_game_send_str_cmd(data, "wizard_wish_operate_res")
end

function i3k_sbean.wizard_wish_operate_res.handler(bean,req)
	if bean.ok == 1 and bean.items then
		local petData = i3k_db_arder_pet[req.petId];
		g_i3k_game_context:UseDiamond(petData.arg2, true, AT_WIZARD_WISH_OPERATE)  --非绑元
		if not g_i3k_ui_mgr:GetUI(eUIID_WizardGift) then
			g_i3k_ui_mgr:OpenUI(eUIID_WizardGift)
			g_i3k_ui_mgr:RefreshUI(eUIID_WizardGift, req.petId, bean.items)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_WizardGift, "updateItemScroll", bean.items);
		end
	end
end

-- 送宝童子领奖
function i3k_sbean.wizardWishTake(petId, item)
	local data = i3k_sbean.wizard_wish_take_req.new()
	data.petId = petId
	data.itemId = item.id
	data.item = item
	i3k_game_send_str_cmd(data, "wizard_wish_take_res")
end

function i3k_sbean.wizard_wish_take_res.handler(bean,req)
	if bean.ok == 1 then
		i3k_sbean.wizardWishSync()
		local gift = {{id = req.item.id, count = req.item.count}}
		g_i3k_ui_mgr:CloseUI(eUIID_WizardGift)
		g_i3k_ui_mgr:ShowGainItemInfo(gift)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "wizardGiftCount");
	end
end

-- 精灵旅行同步
function i3k_sbean.role_wizard_trip_sync.handler(bean)
	if bean.tripWizard then
		g_i3k_game_context:wizardTripSync(bean.tripWizard);
	end
end

-- 精灵旅行开始
function i3k_sbean.wizardTripStart(wizardID, needItem)
	local data = i3k_sbean.role_wizard_trip_start_req.new()
	data.wizardID = wizardID
	data.needItem = needItem
	i3k_game_send_str_cmd(data, "role_wizard_trip_start_res")
end

function i3k_sbean.role_wizard_trip_start_res.handler(bean,req)
	if bean.ok > 0 and bean.tripWizard then
		for i,e in ipairs(req.needItem) do
			g_i3k_game_context:UseCommonItem(e.id, e.count, AT_START_WIZARD_TRIP)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardItem)
		g_i3k_game_context:wizardTripSync(bean.tripWizard);
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "udpateTripTitle");
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OfflineExpReceive, "updateLeftState");
	end
end

-- 精灵旅行设置新照片已读
function i3k_sbean.roleWizardTripReadPhoto()
	local bean = i3k_sbean.role_wizard_trip_read_new_photo.new()
	i3k_game_send_str_cmd(bean)
end

-- 精灵旅行分享照片
function i3k_sbean.wizardTripSharePhoto(msgType, index, serverName, photoID)
	local data = i3k_sbean.role_wizard_trip_share_photo_req.new()
	data.msgType = msgType
	data.wizardID = index
	data.serverName = serverName
	data.photoID = photoID
	i3k_game_send_str_cmd(data, "role_wizard_trip_share_photo_res")
end

function i3k_sbean.role_wizard_trip_share_photo_res.handler(bean,res)
	if bean.ok > 0 then
		if res.msgType == 1 then
			g_i3k_game_context:UseCommonItem(i3k_db_common.chat.worldNeedId,1,AT_USE_CHAT_ITEM)
		elseif res.msgType == 6 then
			g_i3k_game_context:UseCommonItem(i3k_db_common.chat.spanNeedId,1,AT_USE_CHAT_ITEM)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardSharePhoto)
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardPhotoAlbum)
	end
end

-- 旅行精灵结束提示
function i3k_sbean.role_wizard_trip_tips.handler(res)
	if res and res.wizardID then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17078))
	end
end

--修改角色等级经验
function i3k_sbean.role_level_exp.handler(res)
	g_i3k_game_context:SetLevel(res.level,res.exp)
end

-- 同步服务器冲关等级
function i3k_sbean.speedup_level.handler(bean)
	g_i3k_game_context:SetSpeedUpLvl(bean.lvl)
end

--太玄碑文
function i3k_sbean.role_stele.handler(bean)
	g_i3k_game_context:setStelaData(bean.info, bean.type, bean.canMineral)
	g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_STELA, bean.info.receiveTime)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"insertStelaItem")
end

-- 登陆同步特权卡（月卡、周卡）
function i3k_sbean.role_specialcards.handler(bean)
	g_i3k_game_context:setRoleSpecialCards(bean.cards)
end

--npc副本
function i3k_sbean.role_day_npc_map_times.handler(bean)
	g_i3k_game_context:setNpcDungeonEnterTimes(bean.times)
end

function i3k_sbean.role_mapcopy_cantake_drop.handler(bean)
	g_i3k_game_context:SetCurrMapCanReward(bean.canTakeDrop)
end

-- 登录后同步守护副本进度信息
function i3k_sbean.role_towerdefence_log.handler(bean)
	g_i3k_game_context:setTowerDefenceLogs(bean.logs)
end

function i3k_sbean.chageGender(gender, faceSkin, hairSkin)
	local data = i3k_sbean.role_change_gender_req.new()
	data.gender = gender
	data.face = faceSkin
	data.hair = hairSkin
	i3k_game_send_str_cmd(data,"role_change_gender_res")
end

-- 变性请求
function i3k_sbean.role_change_gender_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:clearItemCheckList()
		i3k_sbean.role_logout()
	end
end

function i3k_sbean.change_role_professionReq(classType, tlvl, bwType, faceSkin, hairSkin)
	local data = i3k_sbean.change_role_profession_req.new()
	data.classType = classType
	data.tlvl = tlvl
	data.bwType = bwType
	data.face = faceSkin
	data.hair = hairSkin
	i3k_game_send_str_cmd(data,"change_role_profession_res")
end

-- 变职业请求
function i3k_sbean.change_role_profession_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:clearItemCheckList()
		i3k_sbean.role_logout()
	end
end

function i3k_sbean.sync_last_change_pro_timeReq(titleName, bwType, classType)
	local data = i3k_sbean.sync_last_change_pro_time_req.new()
	data.titleName = titleName
	data.bwType = bwType
	data.classType = classType
	i3k_game_send_str_cmd(data,"sync_last_change_pro_time_res")
end
function i3k_sbean.sync_last_change_pro_time_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_ChangeProfession)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChangeProfession, res.lastChangeTime, req.titleName, req.bwType, req.classType)
end

--登录时同步buff药的信息
function i3k_sbean.role_buffdrugs.handler(res)
	g_i3k_game_context:SetBuffDrugData(res.drugs, res.extral)
end
--同步角色骑术背包与宠物武学背包信息

function i3k_sbean.role_bookbag.handler(res)
	g_i3k_game_context:SetHorseBooks(res.horseBooks)  --骑术背包
	g_i3k_game_context:SetPetBooks(res.petBooks)  --宠物武学背包
end

--登陆同步表情包信息
function i3k_sbean.role_iconpackages.handler(bean)
	g_i3k_game_context:setEmojiData(bean.iconTimes)
end

function i3k_sbean.role_divorce_time.handler(bean)
	g_i3k_game_context:setDivorcTime(bean.time)
end

function i3k_sbean.role_chat_box_sync_on_login.handler(bean)
	g_i3k_game_context:setChatBubbleCurrId(bean.currId)
end

-- 玩家角色名非法信息
function i3k_sbean.role_name_invalid.handler(bean)
	i3k_game_set_role_name_invalid_flag(true)
	g_i3k_game_context:startRoleNameInvalidRemind()
end

function i3k_sbean.role_show_props.handler(bean)
	local index = 0
	local str = ""
	local propID = 0
	for k, v in pairs(bean.props) do
		if i3k_db_prop_id[k] then
			local text = string.format("%s:%s", i3k_db_prop_id[k].desc, v)
			if index > 0 and index % 4 == 0 then
				str = string.format("%s  %s",str, "\n")
			end
			str = string.format("%s  %s",str, text)
			index = index + 1
			propID = k
		end
	end
	g_i3k_ui_mgr:PopupTipMessage(str)
	if index == 1 then
		local hero = i3k_game_get_player_hero()
		if hero and hero._properties then
			local p = hero._properties[propID]
			if p then
				p:printProps();
			end
		end
	end
end

-- 登录同步武道会信息
function i3k_sbean.role_fightteam.handler(bean)
	g_i3k_game_context:setFightTeamIdName(bean.teamID, bean.teamName, bean.leaderID)
	if bean.state > 0 then
		g_i3k_game_context:InMatchingState(bean.joinTime, g_FIGHT_TEAM_MATCH, bean.state)
	end
end

-- 武道会结束时间
function i3k_sbean.tournament_info.handler(bean)
	g_i3k_game_context:setFightTeamEndTime(bean.endTime)
end


-- 登录同步圣诞愿望卡片信息
function i3k_sbean.christmas_cards_login_sync_res.handler(bean)
	local cardInfo = {}
	cardInfo.wishUpdateTime = bean.wishUpdateTime
	cardInfo.dayCommentCnt = bean.dayCommentCnt
	cardInfo.overview = bean.overview
	g_i3k_game_context:SetMyChristmasCardInfo(cardInfo)
end

--登陆同步龙穴任务
function i3k_sbean.role_dragon_hole_task.handler(bean)
	g_i3k_game_context:DelAllAcceptDragonHoleTask()
	if bean.tasks then
		for k, v in pairs(bean.tasks) do
			g_i3k_game_context:AddAcceptDragonHoleTask(v.id, v.value, v.receiveTime, v.state)
		end
	end
	g_i3k_game_context:setDragonTaskScore(bean.score)
end

--设置装备特效
function i3k_sbean.equippart_setshowlvl(partId, evoLvl)
	local data = i3k_sbean.equippart_setshowlvl_req.new()
	data.partID = partId
	data.evoLvl = evoLvl
	i3k_game_send_str_cmd(data, "equippart_setshowlvl_res")
end


function i3k_sbean.equippart_setshowlvl_res.handler(res, req)
	if res.ok > 0 then 
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WeaponEffect, "onSetEffectInfo", req)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipUpStar, "updateRecover", req)
		local hero = i3k_game_get_player_hero()
		if hero:getWeaponShowType() ~= g_FLYING_SHOW_TYPE then
		hero:AttachEquipEffect()
		end
		g_i3k_game_context:updatePlayerHeirloomShow()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17168,g_i3k_game_context:getWeaponEffectName(req.evoLvl)))
	end
end 

--图钉相关--
function i3k_sbean.thumbtack_getinfo()
	local data = i3k_sbean.thumbtack_sync_req.new()
	i3k_game_send_str_cmd(data, "thumbtack_sync_res")
end

function i3k_sbean.thumbtack_sync_res.handler(res, req)
	--self.ok:		int32	
	--self.info:		vector[ThumbTackInfos]	
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SceneMap, "refreshMapBaseData", res.info)
	end
end

function i3k_sbean.thumbtack_Add(remarks)--备注
	local data = i3k_sbean.thumbtack_add_req.new()
	data.remarks = remarks
	i3k_game_send_str_cmd(data, "thumbtack_add_res")
end

function i3k_sbean.thumbtack_add_res.handler(res, req)
	--res.ok:		int32	
	--res.info:		ThumbTackInfo	
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ThumbtackScollUI, "addThumbtackImage", res.info)
	elseif res.ok == -404 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
	end
end	

function i3k_sbean.thumbtack_Delete(mapId, thumbtackId)
	local data = i3k_sbean.thumbtack_delete_req.new()
	data.mapId = mapId
	data.thumbtackId = thumbtackId
	i3k_game_send_str_cmd(data, "thumbtack_delete_res")
end

function i3k_sbean.thumbtack_delete_res.handler(res, req)
	--res.ok
	if res.ok > 0 then
		local info = {mapId = req.mapId, index = req.thumbtackId}
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ThumbtackScollUI, "removeThumbtackImage", info)
	end
end

function i3k_sbean.thumbtack_Modify(mapId, thumbtackId, remarks)
	local data = i3k_sbean.thumbtack_revise_remarks_req.new()
	data.mapId = mapId
	data.thumbtackId = thumbtackId
	data.remarks = remarks
	i3k_game_send_str_cmd(data, "thumbtack_revise_remarks_res")
end

function i3k_sbean.thumbtack_revise_remarks_res.handler(res, req)
	--res.ok:		int32	
	--res.remarks:		string
	if res.ok > 0 then
		local info = {remarks = res.remarks, mapId = req.mapId, index = req.thumbtackId}
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ThumbtackScollUI, "refreshModifyThumbtackUI", info)
	elseif res.ok == -404 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
	end
end

function i3k_sbean.thumbtack_Use(mapId, thumbtackId)
	local data = i3k_sbean.thumbtack_use_req.new()
	data.mapId = mapId
	data.thumbtackId = thumbtackId
	i3k_game_send_str_cmd(data, "thumbtack_use_res")
end

function i3k_sbean.thumbtack_use_res.handler(res, req)
	if res.ok < 1 then
		g_i3k_ui_mgr:PopupTipMessage("传送失败")
	else
		if g_i3k_game_context:IsTransNeedItem() then
			local needId = i3k_db_common.activity.transNeedItemId
			g_i3k_game_context:UseTrans(needId, 1, AT_THUMB_TACK)
		end
		
		releaseSchedule()		
	end
end

--登陆同步巨灵攻城货币
function i3k_sbean.sync_gaintboss_coin.handler(res)
	g_i3k_game_context:setSpiritBossCurrency(res.gaintBossCoin)
end

--添加巨灵攻城货币
function i3k_sbean.role_add_gaintboss_coin.handler(res)
	g_i3k_game_context:addSpiritBossCurrency(res.gaintBossCoin)
end

--登录同步角色家园放生善缘值
function i3k_sbean.role_release_info.handler(res)
	g_i3k_game_context:sethomelandReleaseValue(res.kindFate)
end

-- 标记脚本角色
function i3k_sbean.script_role_mark(time)
	local data = i3k_sbean.script_role_mark_req.new()
	data.time = time
	i3k_game_send_str_cmd(data, "script_role_mark_res")
end

function i3k_sbean.script_role_mark_res.handler(bean)
	-- nothing
end

function i3k_sbean.role_cross_friends.handler(res)
	g_i3k_game_context:SetSelfMooddiaryPersonInfo(res)
end
--登陆同步飞升信息
function i3k_sbean.soaring_login_sync.handler(res)
	g_i3k_game_context:setRoleFlyingData(res.soarings)
	g_i3k_game_context:setCurFootEffect(res.display.footEffect)
	g_i3k_game_context:setCurWeaponShowType(res.display.weaponDisplay)
	g_i3k_game_context:setCurWearShowType(res.display.weaponDisplay)
	--[[local hero = i3k_game_get_player_hero()
		hero:UpdateRoleFlyingProp()
	end--]]
	g_i3k_game_context:syncWithData(res)
end
--登录同步战斗姿态信息
function i3k_sbean.combat_type_info_sync.handler(res)
	g_i3k_game_context:SetCombatType(res.info.combatType)
	g_i3k_game_context:SetCombatCoolEndTime(res.info.coolEndTime)
end
function i3k_sbean.sendChangeCombatType(cType)
	local bean = i3k_sbean.modify_combat_type.new()
	bean.combatType = cType
	i3k_game_send_str_cmd(bean)
end

--开启灵墟寻路
function i3k_sbean.soaring_position_open(id, mapId)
	local data = i3k_sbean.soaring_position_open_req.new()
	data.id = id
	data.mapId = mapId
	i3k_game_send_str_cmd(data, "soaring_position_open_res")
end

function i3k_sbean.soaring_position_open_res.handler(res, req)
	if res.ok > 0 then
		
	else
		--g_i3k_ui_mgr:PopupTipMessage("失败")
	end
end

--进入灵墟
function i3k_sbean.soaring_map_enter(id, mapId)
	local data = i3k_sbean.soaring_map_enter_req.new()
	data.id = id
	data.mapId = mapId
	i3k_game_send_str_cmd(data, "soaring_map_enter_res")
end

function i3k_sbean.soaring_map_enter_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_AnyTimeAnimate)
		g_i3k_ui_mgr:RefreshUI(eUIID_AnyTimeAnimate)
		g_i3k_game_context:ClearFindWayStatus()
	else
		g_i3k_game_context:setIsNeedLoading()
	end
end

--开启飞升
function i3k_sbean.soaring_task_open(id, cb)
	local data = i3k_sbean.soaring_task_open_req.new()
	data.id = id
	data.callback = cb
	i3k_game_send_str_cmd(data, "soaring_task_open_res")
end

function i3k_sbean.soaring_task_open_res.handler(res, req)
	g_i3k_game_context._feisheng._upgraing = true
	if res.ok > 0 then
		local flyingData = g_i3k_game_context:getRoleFlyingData()
		if not flyingData then
			flyingData = {}
		end
		flyingData[req.id] = {id = req.id, roadMaps = {}, finishMaps = {}, isOpen = 0}
		g_i3k_game_context:setRoleFlyingData(flyingData)
		if req.callback then
			req.callback(res.ok)
		else
		g_i3k_ui_mgr:OpenUI(eUIID_RoleFlying)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleFlying, req.id)
		end
	else
		if req.callback then
			req.callback(res.ok)
		end
	end
end

--完成飞升
function i3k_sbean.soaring_task_finish(id)
	local data = i3k_sbean.soaring_task_finish_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "soaring_task_finish_res")
end

function i3k_sbean.soaring_task_finish_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:syncLvl(req.id)
		local flyingData = g_i3k_game_context:getRoleFlyingData()
		if flyingData then
			flyingData[req.id].isOpen = 1
		else
			flyingData = {}
			flyingData[req.id] = {id = req.id, roadMaps = {}, finishMaps = {}, isOpen = 1}
		end
		g_i3k_game_context:setRoleFlyingData(flyingData)
		g_i3k_game_context:setCurWeaponShowType(g_FLYING_SHOW_TYPE)
		g_i3k_game_context:setCurFootEffect(1)
		g_i3k_game_context:UpdateSubLineTaskValue(g_TASK_ROLE_FLYING, req.id)
		local hero = i3k_game_get_player_hero()
		if hero then
			g_i3k_game_context:SetPrePower()
			hero:UpdateRoleFlyingProp()
			g_i3k_game_context:ShowPowerChange()
		end
		if hero and req.id == 1 then
			hero:changeFootEffect(1)
			hero:setWeaponShowType(g_FLYING_SHOW_TYPE)
			hero:changeWeaponShowType()
		end
		--g_i3k_game_context:updatePlayerHeirloomShow()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleFlying, "finishFlyingHandler")
		--g_i3k_ui_mgr:CloseUI(eUIID_RoleFlying)
	else
		g_i3k_ui_mgr:PopupTipMessage("Fail to fensheng")
	end
end

--解锁脚底特效
function i3k_sbean.footeffect_unlock(id)
	local data = i3k_sbean.footeffect_unlock_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "footeffect_unlock_res")
end

function i3k_sbean.footeffect_unlock_res.handler(res, req)
	if res.ok > 0 then
		local effect = i3k_db_feet_effect[req.id]
		g_i3k_game_context:SetUseItemData(effect.needItemId, effect.needItemCount, nil, 1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleFlyingFoot, "unlockFootEffectId", req.id)
	else
		g_i3k_ui_mgr:PopupTipMessage("解锁脚底特效失败")
	end
end

--选择脚底特效
function i3k_sbean.footeffect_select(id)
	local data = i3k_sbean.footeffect_select_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "footeffect_select_res")
end

function i3k_sbean.footeffect_select_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setCurFootEffect(req.id)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:changeFootEffect(req.id)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleFlyingFoot, "onChangeFootEffectHandler", req.id)
	else
		g_i3k_ui_mgr:PopupTipMessage("替换脚底特效失败")
	end
end

--脚底特效同步
function i3k_sbean.footeffect_sync()
	local data = i3k_sbean.footeffect_sync_req.new()
	i3k_game_send_str_cmd(data, "footeffect_sync_res")
end

function i3k_sbean.footeffect_sync_res.handler(res, req)
	g_i3k_game_context:setFootEffect(res.info.unlockFootEffect)
	g_i3k_ui_mgr:OpenUI(eUIID_RoleFlyingFoot)
	g_i3k_ui_mgr:RefreshUI(eUIID_RoleFlyingFoot, res.info.unlockFootEffect)
end

--选择武器外显
function i3k_sbean.weapondisplay_select(weaponShowType)
	local data = i3k_sbean.weapondisplay_select_req.new()
	data.type = weaponShowType
	data.partType = g_FashionType_Weapon
	i3k_game_send_str_cmd(data, "weapondisplay_select_res")
end

function i3k_sbean.weapondisplay_select_res.handler(res, req)
	if res.ok > 0 and req.partType == g_FashionType_Weapon then
		g_i3k_game_context:setCurWeaponShowType(req.type)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:setWeaponShowType(req.type)
			hero:changeWeaponShowType()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "changeWeaponShowHandler")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "changeWeaponShowHandler")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "changeWeaponShowHandler")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy2, "changeWeaponShowHandler")
	elseif res.ok > 0 and req.partType == g_FashionType_Dress then
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:setWearShowType(req.type)
		end
		g_i3k_game_context:updateFashionTypeID(req.type)
		g_i3k_game_context:SetFashionIsShowData(req.type)
	else
		g_i3k_ui_mgr:PopupTipMessage("更换武器外显失败")
	end
end

--飞升装备推送
function i3k_sbean.soaring_equip_push.handler(bean)
	local equipCfg = 
	{
		equip_id = bean.equip.id,
		equip_guid = bean.equip.guid,
		attribute = bean.equip.addValues,
		naijiu = bean.equip.durability,
		refine = bean.equip.refine,
		legends = bean.equip.legends,
		smeltingProps = bean.equip.smeltingProps,
		hammerSkill = bean.equip.hammerSkill,
	}
	local pos = i3k_db_equips[bean.equip.id].partID or 0
	--[[
	local equipData = g_i3k_game_context:GetWearEquips()
	if equipData[pos].equip then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:setDeleteWearEquip(bean.equip.id)
	end
	]]--
	local flyingLevel = i3k_db_equips[bean.equip.id].flyingLevel
	if pos == eEquipFlyClothes and flyingLevel == 0 then
		g_i3k_game_context:SetFashionIsShowData(g_WEAR_FLYING_SHOW_TYPE)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:setWearShowType(g_WEAR_FLYING_SHOW_TYPE)
		end
		g_i3k_game_context:updateFashionTypeID(g_WEAR_FLYING_SHOW_TYPE)
		g_i3k_game_context:SetFashionIsShowData(g_WEAR_FLYING_SHOW_TYPE)
	end
	g_i3k_game_context:wearEquipHandler(bean.id, bean.guid, pos, equipCfg)
end

-- 周年舞会
function i3k_sbean.role_danceparty.handler(res)
	local times = res.dayAddExpTimes -- 每日获得经验次数
	local exps = res.dayAddExps -- 每日获得经验
	g_i3k_game_context:setDanceExp(times, exps)
end

-- 每收到一次这个协议，上面那个次数就++ 
function i3k_sbean.danceparty_addexp.handler(res)
	local exp = res.exp
	local reward = res.reward
	g_i3k_game_context:setDanceReward(exp, reward)
end
--登录同步驭灵
function i3k_sbean.ghost_island_syn_info.handler(bean)
	g_i3k_game_context:SetSpiritsData(bean.info)
end
function i3k_sbean.bag_useitem_add_activity_map_cnt(itemid, count)
	local bean = i3k_sbean.bag_useitem_add_activity_map_cnt_req.new()
	bean.itemID = itemid
	bean.count = count
	i3k_game_send_str_cmd(bean, "bag_useitem_add_activity_map_cnt_res")
end
function i3k_sbean.bag_useitem_add_activity_map_cnt_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:AddDayUseItemTiems(req.itemID, req.count)
		g_i3k_ui_mgr:PopupTipMessage("使用成功")
		g_i3k_game_context:UseCommonItem(req.itemID, req.count)
		g_i3k_ui_mgr:CloseUI(eUIID_ActivityAddTimesByItem)
		g_i3k_ui_mgr:CloseUI(eUIID_ActivityAddTimesWay)
		g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	end
end
function i3k_sbean.spring_lantern_day_group.handler(res)
	local groupID = g_i3k_game_context:getSpringRollGroupID()
	if groupID ~= 0 then
		local world = i3k_game_get_world()
		local oldNPC = i3k_db_spring_roll.npcConfig[groupID]
		g_i3k_game_context:setSpringRollGroupID(res.dayNpcGroup)
		for k, v in pairs(oldNPC) do
			local Entity = world:GetNPCEntityByID(k)
			if Entity then
				Entity:ChangeSpringRollIcon()
			end
		end
		local todayNPC = i3k_db_spring_roll.npcConfig[res.dayNpcGroup]
		for k, v in pairs(todayNPC) do
			local Entity = world:GetNPCEntityByID(k)
			if Entity then
				Entity:ChangeSpringRollIcon()
			end
		end
	else
		g_i3k_game_context:setSpringRollGroupID(res.dayNpcGroup)
	end
end

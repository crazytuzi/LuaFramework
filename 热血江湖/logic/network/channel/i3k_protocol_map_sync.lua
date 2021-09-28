------------------------------------------------------
module(..., package.seeall)

local require = require
require("i3k_sbean")

require("logic/entity/i3k_entity_def");
local BASE = require("logic/network/channel/i3k_channel");

-------------------------进入地图同步信息--------------------------------------------
------------------------------------------------------
-- 进入地图成功，对应role_enter_map的异步响应
--Packet:role_map_welcome
function i3k_sbean.role_map_welcome_start.handler(bean)
	i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler");

	local logic = i3k_game_get_logic();
	-- g_i3k_game_context:clearPlayLeadFlag()
	if logic then
		local world = logic:GetWorld();
		if world then
			local player = logic:GetPlayer();
			if player and player:GetHero() then
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 1");

				local hero = player:GetHero();
				hero:ClsBuffs()
				hero:ClearAutofightTriggerSkill()
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 2");

				for k = 1, player:GetPetCount() do
					local pet = player:GetPet(1);
					if pet then
						player:RmvPet(1,true);
						world:RmvEntity(pet);
					end
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 3");

				for k = 1, player:GetMercenaryCount() do
					local Mercenary = player:GetMercenary(1);
					if Mercenary then
						player:RmvMercenary(1,true);
						world:RmvEntity(Mercenary);
					end
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 4");

				for k = player:GetEscortCarCount(), 1, -1 do
					local EscortCar = player:GetEscortCar(k);
					if EscortCar then
						player:RmvEscortCar(k);
						world:RmvEntity(EscortCar);
					end
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 5");

				--清技能cd
				for k, v in pairs(hero._skills) do
					v:OnReset();
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 6");

				if hero._DIYSkill then
					hero._DIYSkill:OnReset();
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 7");

				hero._target = nil;
				hero:SetDeadState(false);
				i3k_global_log_info("i3k_sbean.role_map_welcome_start.handler 8");
				hero:DetachWeaponSoul()
				hero:setPlayActionState(0)
			end
		end
	end

end

function i3k_sbean.role_map_welcome.handler(bean)
	i3k_global_log_info("i3k_sbean.role_map_welcome.handler");
	
	local curHP = bean.curHP
	local curSP = bean.curSP
	local isDead = bean.isDead
	local curFightSp = bean.fightSP
	local attackMode = bean.attackMode
	local bufflist = bean.buffs
	local PKgrade = bean.pkNameGrade
	local PKstatus = bean.pkState
	local pets = bean.pets
	local petHost = bean.petHost
	local weaponLeftTime = bean.weaponLeftTime;
	local timeTick = bean.timeTick;
	local weaponBlessCurLevel = bean.weaponBless.nowBlessLvl
	local isWeaponBlessActive = bean.weaponBless.isActive
	local hasWeaponBless = bean.weaponBless.hasWeaponBless == 1
	--i3k_log("role_map_welcome timeLine = " .. timeTick.tickLine .. ", outTick = " .. timeTick.outTick);

	i3k_game_set_logic_tick_line(timeTick.tickLine * i3k_engine_get_tick_step() + timeTick.outTick + i3k_game_get_server_ping());

	g_i3k_game_context:SetFightMercenaryData(pets)
	g_i3k_game_context:SetFightMercenaryHostData(petHost)
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			i3k_global_log_info("i3k_sbean.role_map_welcome.handler 1");

			local player = logic:GetPlayer();
			if player and player:GetHero() then
				g_i3k_ui_mgr:CloseAllOpenedUI()
				g_i3k_ui_mgr:OpenUI(eUIID_BattleBase)
				local hero = player:GetHero();
				hero:SetColor(g_i3k_db.i3k_db_get_map_entity_color())
				hero:AttachCamera(logic:GetMainCamera());
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 2");

				--加buff
				for _, v in pairs(bufflist) do
					local BUFF = require("logic/battle/i3k_buff");
					local bcfg = i3k_db_buff[v.id];
					local buff = BUFF.i3k_buff.new(nil, v.id, bcfg, v.realmLvl);
					buff._endTime = v.remainTime
					if buff then
						hero:AddBuff(nil, buff);
					end
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 3");

				hero:SetPVPStatus(attackMode)
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 4");

				hero:UpdateHorseAi()
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 5");

				local worldMapType = world._mapType
				
				local cameraClipType = i3k_db_common.cameraClip
				
				if cameraClipType.MapID[worldMapType] then
					g_i3k_mmengine:SetNoClipDistance(cameraClipType.CameraRadius)
				else
					g_i3k_mmengine:SetNoClipDistance(40)
				end
				
				if hero then
					hero:UpdateProperty(ePropID_sp, 1, curSP, true, false, true);
					hero:UpdateFightSp(curFightSp);
					if curHP > 0 then
						hero:SetDeadState(false)
						hero:UpdateHP(curHP)
					end
					i3k_global_log_info("i3k_sbean.role_map_welcome.handler 6");

					if isDead == 1 then
						hero:OnDead();
						if g_i3k_db.i3k_db_get_is_open_revive_ui() then
							g_i3k_logic:OpenReviveUI()
						end
					end
					i3k_global_log_info("i3k_sbean.role_map_welcome.handler 7");

					hero._PVPFlag = PKstatus
					hero._PVPColor = PKgrade
					local PKValue = g_i3k_game_context:GetCurrentPKValue()
					if PKValue~= -1 then
						hero._PKvalue = PKValue
					end
					hero:ChangeTransportName()
					hero:TitleColorTest();
					i3k_global_log_info("i3k_sbean.role_map_welcome.handler 8");
					hero:AttachWeaponSoul()
					local mapNotAuto = {
						[g_SPY_STORY] = true,
						[g_FORCE_WAR] = true,
						[g_DEFENCE_WAR] = true,
						[g_DESERT_BATTLE] = true,
						[g_PRINCESS_MARRY] = true,
						[g_MAGIC_MACHINE] = true,
						[g_LONGEVITY_PAVILION] = true,
					}
					if worldMapType == g_FIELD then
						if g_i3k_game_context:GetSuperOnHookValid() then
							if not g_i3k_game_context:GetIsSpringWorld() then
								local curMapID = g_i3k_game_context:GetWorldMapID()
								local pos = g_i3k_game_context:GetSuperOnHookPos()
								g_i3k_game_context:SetAutoFight(true, pos)
							end
						else
							g_i3k_game_context:SetAutoFight(false)
						end
					elseif worldMapType == g_BASE_DUNGEON or worldMapType == g_TOURNAMENT or worldMapType == g_FACTION_WAR or worldMapType == g_BUDO or worldMapType == g_AT_ANY_MOMENT_DUNGEON then
						g_i3k_game_context:SetAutoFight(false)
					elseif world._fightmap and not mapNotAuto[worldMapType] then
						g_i3k_game_context:SetAutoFight(true)
					else
						g_i3k_game_context:SetAutoFight(false)
					end
					i3k_global_log_info("i3k_sbean.role_map_welcome.handler 9");

					if worldMapType == g_BASE_DUNGEON then
						local wequips = g_i3k_game_context:GetWearEquips()
						local Threshold = i3k_db_common["equip"]["durability"].Threshold
						for k,v in pairs(wequips) do
							if v.equip then
								if v.equip.naijiu > Threshold then
									if v.equip.legends[3] and v.equip.legends[3] ~= 0 then
										local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(v.equip.equip_id)
										local cfg = i3k_db_equips_legends_3[equip_t.partID][v.equip.legends[3]]
										if cfg and cfg.type == 3 then
											local bcfg = i3k_db_buff[cfg.args[1]];
											local BUFF = require("logic/battle/i3k_buff");
											local buff = BUFF.i3k_buff.new(nil, cfg.args[1], bcfg);
											if buff then
												hero:AddBuff(self, buff);
											end
										end
									end
								end
							end
						end
					end
					i3k_global_log_info("i3k_sbean.role_map_welcome.handler 10");
				end
				local mapid = world._cfg.id
				local mcfg = i3k_db_dungeon_base[mapid]
				if mcfg.openType == 1 and i3k_db_new_dungeon[mapid] and i3k_db_new_dungeon[mapid].openType == 0 then
					spawnPos = i3k_db_dungeon_base[mapid].spawnPos
					local pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(spawnPos)));
					hero:SetPos(pos);
					g_i3k_game_context:UpdateHeroBuffDrug()
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 11");
				--统一模型 and 设置势力战特效等级
				local needSetMap = {
					[g_FORCE_WAR] 		= true,
					[g_DEMON_HOLE] 		= true,
					[g_FACTION_WAR] 	= true,
					[g_BUDO]			= true,
					[g_DEFENCE_WAR]		= true,
					[g_SPIRIT_BOSS]		= true,
					[g_HOMELAND_HOUSE]		= true,
					[g_DESERT_BATTLE]		= true,
					[g_MAZE_BATTLE]		= true,
					[g_PRINCESS_MARRY]		= true,
					[g_LONGEVITY_PAVILION]		= true,
					[g_CATCH_SPIRIT]	= true,
					[g_SPY_STORY]		= true,
				}
				if  needSetMap[worldMapType] then
					if worldMapType ~= g_BUDO and worldMapType ~= g_SPIRIT_BOSS and worldMapType ~= g_HOMELAND_HOUSE 
						and worldMapType ~= g_DESERT_BATTLE and worldMapType ~= g_PRINCESS_MARRY and worldMapType ~= g_LONGEVITY_PAVILION and worldMapType ~= g_SPY_STORY and worldMapType ~= g_CATCH_SPIRIT and worldMapType ~= g_BIOGIAPHY_CAREER then -- 武道会不设置统一模型 设置特效等级
						hero:OnUnifyMode(true)
					end
					if worldMapType == g_HOMELAND_HOUSE then
						hero:ChangeArmorEffect()
					end
					else
					hero:ChangeArmorEffect()
					end
				-- 设置特效等级读取策划配置
				local effectFilterSet = i3k_db_common.effectLvlSet
				if effectFilterSet[worldMapType] then
					g_i3k_game_context:SetEffectFilter(effectFilterSet[worldMapType])
				else
					local cfg = g_i3k_game_context:GetUserCfg()
					local LvlTX = cfg:GetFilterTXLvl()
					g_i3k_game_context:SetEffectFilter(LvlTX)
				end
				if hero._soaringDisplay and hero._soaringDisplay.footEffect and hero._soaringDisplay.footEffect ~= 0 then
					hero:changeFootEffect(hero._soaringDisplay.footEffect)
				end
				if hero._combatType > 0 then
					hero:ChangeCombatEffect(hero._combatType)
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 12");
				
				if worldMapType ~= g_DESERT_BATTLE then
					g_i3k_game_context:setdesertBattleViewEntity(nil)
				end

				world:OnPlayerEnterWorld(player);
				g_i3k_game_context:setConvoyNpcState(false)
				g_i3k_game_context:setConvoyNpcState(true,mapid)

				local roleInfo = g_i3k_game_context:GetRoleInfo();
				if roleInfo then
					if hero._hugMode.valid and not hero._hugMode.isLeader then
						hero:SetFaceDir(0, 1.5, 0);
					else
						hero:SetFaceDir(0, roleInfo.curLocation.rotate, 0);
					end
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 13");

				local EscortCarCount = player:GetEscortCarCount();
				for i = tonumber(EscortCarCount) , 1 , -1 do
					local EscortCar = player:GetEscortCar(i)
					if world then
						world:RmvEntity(EscortCar);
					end
					player:RmvEscortCar(i);
				end
				i3k_global_log_info("i3k_sbean.role_map_welcome.handler 14");

				--在温泉区域检测是否在水域
				if mapid == i3k_db_spring.common.mapId then
					--添加水域检测ai
					hero:AddAiComp(eAType_CHECK_WATER)
					hero:InSpring()

					local cfg = i3k_db_schedule.cfg
					local mapID = g_SCHEDULE_COMMON_MAPID
					for _, v in ipairs(cfg or {}) do
						if v.typeNum == g_SCHEDULE_TYPE_SPRING then
							mapID = v.mapID
							break
						end
					end
					if g_i3k_game_context:getSpringWeeklyTimes() <= i3k_db_spring.common.weeklyEnter then
						g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SPRING, mapID)
					end
				else
					--移除水域ai
					hero:UseRide(g_i3k_game_context:getUseSteed())
					hero:setRideCurShowID(g_i3k_game_context:getSteedCurShowID())
					hero:RmvAiComp(eAType_CHECK_WATER)
				end

				if  g_i3k_game_context:GetIsInFactionZone() then
					i3k_sbean.request_sect_destiny_sync_req()
				end

				if g_i3k_game_context:GetIsInHomeLandZone() then --家园钓鱼检测ai
					hero:AddAiComp(eAType_CHECK_AREA)
					hero:AttachHomeLandCurEquip(g_i3k_game_context:GetHomeLandCurEquip())
				elseif worldMapType == g_MAGIC_MACHINE or worldMapType == g_CATCH_SPIRIT or worldMapType == g_SPY_STORY then
					hero:AddAiComp(eAType_CHECK_AREA)
				else
					hero:RmvAiComp(eAType_CHECK_AREA)
					g_i3k_game_context:ClearHomeLandFishStatus()
				end
				
				if g_i3k_game_context:GetIsInHomeLandHouse() then
					g_i3k_ui_mgr:OpenUI(eUIID_HouseBase)
					local house = g_i3k_game_context:getHomeLandHouseInfo()
					if house then
						world:ChangeHouseSkin(house.homeland.curSkin)
					end
					if g_i3k_game_context:GetIsInMyHouse() then
						hero:AddAiComp(eAType_CHECK_HOUSE_WALL)
					else
						hero:RmvAiComp(eAType_CHECK_HOUSE_WALL)
					end
				else
					hero:RmvAiComp(eAType_CHECK_HOUSE_WALL)
				end
				
				if worldMapType == g_FIELD then
					if g_i3k_game_context:isNeedAddFlyingAI() then
						hero:AddAiComp(eAType_CHECK_FLYING)
					else
						hero:RmvAiComp(eAType_CHECK_FLYING)
					end
				end
				
				if worldMapType == g_PRINCESS_MARRY then
					hero:AddAiComp(eAType_CHECK_FINDWAY_STATE)
				else
					hero:RmvAiComp(eAType_CHECK_FINDWAY_STATE)
				end
				--驭灵副本自动战斗ai
				if worldMapType == g_CATCH_SPIRIT then
					hero:AddAiComp(eAType_AUTOFIGHT_CATCH_SKILL)
				else
					hero:RmvAiComp(eAType_AUTOFIGHT_CATCH_SKILL)
				end
				
				if g_i3k_game_context:GetIsInIllusoryMap() then
					local illusoryCfg = i3k_db_illusory_dungeon[mapid]
					if illusoryCfg then
						local circleDot = i3k_db_illusory_dungeon_cfg.circleDot
						for index, spawnID in ipairs(illusoryCfg.areas) do
							local spawnPointID = i3k_db_spawn_area[spawnID].spawnPoints[1]
							local bossID = i3k_db_spawn_point[spawnPointID].monsters[1]
							local pos = i3k_db_illusory_dungeon_cfg.bossPos[index]
							if pos then
								world:CreateIllusoryMonster(bossID, pos, circleDot)
							else
								assert(pos ~= nil, "i3k_db_illusory_dungeon_cfg.bossPos "..index.." is nil")
							end
						end
					end
				end

				local diglett = g_i3k_db.i3k_db_open_hit_diglett_id(e_TYPE_DIGLETT)
				if diglett and mapid == i3k_db_findMooncake[diglett].mapId then
					hero:DetachCamera()
					hero:SetPos(i3k_world_pos_to_logic_pos(i3k_db_diglett_position.role))
					--g_i3k_game_context:setCameraDistance(i3k_db_diglett_position.distance/100)
					local logic = i3k_game_get_logic()
					if logic then
						local camera = logic:GetMainCamera()
						if camera then
							camera:UpdateCameraDistance(i3k_db_diglett_position.distance/100)
						end
					end
					world:initDiglettPosition()
					g_i3k_logic:OpenHitDiglettUI(diglett)
				else
					if i3k_db_common.cameraFubenAngleSet[worldMapType] then --这里副本相机角度配置改为通用 走通用配置表
						g_i3k_game_context:setFubenCameraAngle(worldMapType)
					else
						local percent = i3k_get_load_cfg():GetCameraInter() * 100
						g_i3k_game_context:setCameraDistance(percent / 100)
					end
					
					hero:updatePropertyOnEnterMap()
					g_i3k_ui_mgr:RefreshUI(eUIID_BattleBase)
				end
			end
		end
	end

	g_i3k_game_context:SetMapEnter(true);
	g_i3k_game_context:UpdatePassiveAuraProp()
	--g_i3k_ui_mgr:RefreshUI(eUIID_BattleBase)
	i3k_global_log_info("i3k_sbean.role_map_welcome.handler 15");
	local world = i3k_game_get_world()
	if world then
		local cfg = i3k_db_field_map[world._cfg.id]
		if cfg then
			if cfg.worldMapType == 2 then
				if not g_i3k_game_context:getIsShowFirstLoginUI() then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(484))
				end
			elseif cfg.worldMapType == 3 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(486))
			end
		end

		i3k_global_log_info("i3k_sbean.role_map_welcome.handler 16");

		if world._mapType == g_FIELD then
			local data = g_i3k_game_context:GetFindPathData()
			if data.mapid and data.pos then
				local hero = i3k_game_get_player_hero()
				if hero then
					local state,speed = hero:GetFindWayStatus()
					if state then
						local onHookValid = g_i3k_game_context:GetSuperOnHookValid()
						g_i3k_game_context:SeachPathWithMap(data.mapid,data.pos,data.task_type,data.petID,data.transferData,speed,data.line,data.callFunc, nil, nil, onHookValid)
					end
				end
			end
			if g_i3k_game_context:getDetectiveState() then
				g_i3k_logic:OpenKnightlyDetectiveUI()
				g_i3k_game_context:setDetectiveState(false)
			end
			g_i3k_game_context:checkAutoOpenOutCast()
			g_i3k_game_context:openTaskFinishDialogues()
			g_i3k_game_context:setIsNeedLoading()
			g_i3k_game_context:clearCatchSpiritMonsterSkill()--清除驭灵连招
			g_i3k_game_context:checkOpenBiographyUI()
		end
		if world._mapType == g_BIOGIAPHY_CAREER then
			local careerId = g_i3k_game_context:getCurBiographyCareerId()
			local biographyInfo = g_i3k_game_context:getBiographyCareerInfo()
			if careerId and biographyInfo and biographyInfo[careerId] and biographyInfo[careerId].enterNum == 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_BiographyAnimate)
				g_i3k_ui_mgr:RefreshUI(eUIID_BiographyAnimate, i3k_db_wzClassLand[careerId].animateId)
				biographyInfo[careerId].enterNum = 1
				g_i3k_game_context:setBiographyCareerInfo(biographyInfo)
			end
		end
	end
	i3k_global_log_info("i3k_sbean.role_map_welcome.handler 17");
	local hero = i3k_game_get_player_hero()
	if hero and hasWeaponBless then
		hero:SyncWeaponBlessState(isWeaponBlessActive, weaponBlessCurLevel)
	end
	g_i3k_game_context:LeadCheck()
	g_i3k_game_context:PlotCheck()
	g_i3k_game_context:SetMoveState(false)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateMapNameImg")
	g_i3k_game_context:OpenMapCopyDialogue()
	g_i3k_game_context:cleanDialogueFinish()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "playAnisAfterPlayerLead")

	--获得每周限时宝箱tips
	if g_i3k_game_context:GetIsShowGetBoxTips() and i3k_game_get_map_type() == g_FIELD then
		if not g_i3k_ui_mgr:GetUI(eUIID_WeekBoxGetTips) then
			local data = g_i3k_game_context:GetBoxTipsData()
			if data then
				g_i3k_ui_mgr:OpenUI(eUIID_WeekBoxGetTips)
				g_i3k_ui_mgr:RefreshUI(eUIID_WeekBoxGetTips, data.boxID, data.boxData)
				g_i3k_game_context:SetIsShowGetBoxTips(false)
				g_i3k_game_context:SetBoxTipsData(nil)
			end
		end
	end

	-- 3D Touch 打开的页面
	g_i3k_logic:OpenShortCutUI()
	g_i3k_game_context:ReloadMapLoadCallBack() --callback 副本结束打开ui等操作
	i3k_global_log_info("i3k_sbean.role_map_welcome.handler 18");

	return true;
end

-- 进地图同步玩家在第几个出生点
function i3k_sbean.role_spawn_point.handler(bean)
	if bean and bean.index then
		g_i3k_game_context:setCameraAngle(bean.index)
		local roleInfo = g_i3k_game_context:GetRoleInfo();
		if roleInfo then
			spawnPos = roleInfo.curLocation.pos;
		end
		local validPos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(spawnPos)));
		spawnPos = i3k_world_pos_to_logic_pos(validPos);
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:SetPos(spawnPos, true);
			hero:SetFaceDir(0, roleInfo.curLocation.rotate, 0);
			hero:Show(true, true);
			hero:Play(i3k_db_common.engine.defaultStandAction, -1);
		end
	end
end

-- map同步神兵变身剩余时间
function i3k_sbean.role_weaponlefttime.handler(bean)
	local leftTime = bean.leftTime
	local hero = i3k_game_get_player_hero()
	if hero then
		local animation = g_i3k_game_context:GetSelectWeaponMaxAnimation()
		if animation then
			g_i3k_game_context:OnStuntAnimationChangeHandler(animation,false)
		end
		g_i3k_game_context:OnCancelSelectHandler()
		-- if leftTime > 0 then
			if not hero._superMode.valid then
				hero._superMode.valid = true;
				hero:SuperMode(true);
			end
			if leftTime > 0 then
				hero._superMode.ticks = hero._weapon.ticks - leftTime
			end
		-- end
	end
end

-- map同步当前的骑乘的坐骑
function i3k_sbean.role_curridehorse.handler(bean)
	local curRide = bean.hid
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:ClearMulHorse()
		hero:OnRideMode(curRide ~= 0)
	end
end

-- map同步任务变身状态
function i3k_sbean.role_taskalter.handler(bean)
	local alter = bean.alter
	local hero = i3k_game_get_player_hero()
	if hero then
		if alter and alter.alterID ~= 0 then
			if not hero._missionMode.valid then
				hero:MissionMode(true, alter.alterID, alter.attrEndTime)
			else
				hero:ClearMissionattr()
			end
		else
			hero:MissionMode(false)	
			if i3k_game_get_map_type() == g_DEFENCE_WAR then
				hero:OnUnifyMode(true)				
			end	
		end
	end
end

--role_transform_use
--map幻形信息同步
function i3k_sbean.role_transform_use.handler(bean)
	g_i3k_game_context:SetMetamorphosisState(bean.use)
	local hero = i3k_game_get_player_hero()
	if hero then
		local metamorphosisID = g_i3k_game_context:GetCurMetamorphosis()
		if bean.use == 1 then					
			if not hero._missionMode.valid then
				local id =  i3k_db_metamorphosis[metamorphosisID].changeID
				hero:MissionMode(true, id, 0)
			else
				hero:ClearMissionattr()
			end
		elseif bean.use == 0 then
			hero:MissionMode(false, nil, nil, true)
		end
	end
	
end
-------------------------同步逻辑帧信息--------------------------------------------
------------------------------------------------------
-- 进入地图成功，对应role_update_timetick的异步响应
--Packet:role_update_timetick
function i3k_sbean.role_update_timetick.handler(bean)
	local timeTick = bean.timeTick;

	--i3k_log("role_update_timetick timeLine = " .. timeTick.tickLine .. ", outTick = " .. timeTick.outTick .. " , ping " .. i3k_game_get_server_ping());

	i3k_game_set_logic_tick_line(timeTick.tickLine * i3k_engine_get_tick_step() + timeTick.outTick + i3k_game_get_server_ping());

	return true;
end

function i3k_sbean.send_client_ping_start()
	if i3k_game_get_server_ping() > 0 then
	local bean = i3k_sbean.client_ping_start.new()

	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_logic_tick_line();

	bean.timeTick	= i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine	= timeTick;
	--bean.timeTick.tickLine	= g_i3k_game_context:GetPingTaskID();
	bean.taskID	= g_i3k_game_context:GetPingTaskID();
	bean.timeTick.outTick	= outTick - timeTick * i3k_engine_get_tick_step();
	bean.ping = i3k_game_get_server_ping();

	--i3k_log("send_client_ping_start id = " .. bean.timeTick.tickLine);

	if i3k_game_send_str_cmd(bean) then
		g_i3k_game_context:NewPingTask();
		end
	end
end

-- 计算延迟(客户端发起client_ping_start的服务器异步回应)
--Packet:client_ping_end
function i3k_sbean.client_ping_end.handler(bean)
	local sendtimeTick = bean.sendTimeTick;
	local recvTimeTick = bean.recvTimeTick;

	--i3k_log("client_ping_end id = " .. sendtimeTick.tickLine);

	--local ping = g_i3k_game_context:UpdatePingTask(sendtimeTick.tickLine);
	local ping = g_i3k_game_context:UpdatePingTask(bean.taskID);
	--[[
	local ping = math.max(0, i3k_integer((recvTimeTick.tickLine - sendtimeTick.tickLine) * i3k_engine_get_tick_step() + (recvTimeTick.outTick - sendtimeTick.outTick)));

	if ping > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updatePingInfo", ping);
	end
	i3k_game_set_server_ping(ping);

	if i3k_game_get_server_ping() > 1000 then
		if not g_i3k_game_context:IsInPingMode() then
			g_i3k_game_context:AddPingtick();
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(499));
		end
	else
		if not g_i3k_game_context:IsInPingMode() then
			g_i3k_game_context:ClearPingticks();
		else
			g_i3k_game_context:ClearPingStatus();
		end
	end
	]]
	--i3k_log("client_ping_end timeLine = " .. recvTimeTick.tickLine .. ", outTick = " .. recvTimeTick.outTick .. ", ping = " .. ping);

	--i3k_game_set_logic_tick_line(recvTimeTick.tickLine * i3k_engine_get_tick_step() + recvTimeTick.outTick + ping);
end

function i3k_sbean.client_role_sync_map()
	local bean = i3k_sbean.role_sync_map.new()
	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 进地图同步所以掉落
--Packet:role_sync_alldrops
function i3k_sbean.role_sync_alldrops.handler(bean, res)
	local Drops = bean.drops
	local DropsDetail = {}
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			for k,v in pairs(Drops) do
				local itemGuid = v.drop.dropID;
				local itemItemID = v.drop.itemID;
				local itemCount = v.drop.itemCount;
				local pos_x = v.position.x;
				local pos_y = v.position.y;
				local pos_z = v.position.z;
				local Pos = {x = pos_x,y = pos_y,z = pos_z}
				local args = {Gid =itemGuid,Id = itemItemID,nCount = itemCount}
				local DropsDetail = {args};
				world:CreateItemDropsFromNetwork(Pos,DropsDetail);
			end
		end
	end
	return true;
end


------------------------------------------------------
-- 同步单机副本进度
--Packet:privatemap_sync_progress
function i3k_sbean.privatemap_sync_progress.handler(bean, res)
	local mapprogress = bean.mapprogress
	local spawnPoint = mapprogress.spawnPoint
	local mapBuffs = mapprogress.mapBuffs
	local trap = mapprogress.trap
	local Mines = mapprogress.mineals;
	local Trapargs = {}
	local Spawnargs = {}
	local Mapbuffargs = {}
	local Mineargs = {}
	local logic = i3k_game_get_logic();

	if logic then
		local world = logic:GetWorld();
		if world then
			if trap then
				for k1, v1 in pairs(trap) do
					local TrapId = v1.id;
					local TrapState = v1.state;
					local args = {TrapState = TrapState}
					Trapargs[TrapId] = args
				end
			end
			world:OnTrapLoaded(Trapargs);
			if spawnPoint then
				for k1, v1 in pairs(spawnPoint) do
					local spawnPointId = v1.spawnPointId;
					local killedCount =v1.killedCount;
					local earlyDrop = v1.earlyDrop
					local args = {spawnTimes = spawnTimes,killedCount = killedCount, earlyDrop = earlyDrop}
					Spawnargs[spawnPointId] = args
				end
			end
			world:OnSpawnLoaded(Spawnargs);
			if mapBuffs then
				for k1, v1 in pairs(mapBuffs) do
					local MapbuffID = v1.id;
					local args = {MapbuffID = v1.id,MapbuffCfgID = v1.cfgID,Pos = v1.position}
					Mapbuffargs[v1.id] = args
				end
			end
			world:OnMapbuffLoaded(Mapbuffargs);
			if Mines then
				for k1, v1 in pairs(Mines) do
					local MapbuffID = v1.id;
					local args = {MineID = v1.id,MineCfgID = v1.cfgID,Pos = v1.position}
					Mineargs[v1.id] = args
				end
			end
			world:OnResourcePointLoaded(Mineargs);
			if not world._sceneAni.scenebegin then
				world._sceneAni.scenebegin = true;
				i3k_game_play_scene_ani(i3k_db_new_dungeon[world._cfg.id].dungeonbegin)
--				g_i3k_game_context:playFlash(i3k_db_new_dungeon[world._cfg.id].dungeonbegin)
			end
		end
	end
	return true;
end

-------------------------进入地图同步信息end--------------------------------------------

------------------------------------------------------------------------------------
-- 更新组队副本当前刷怪区域ID
function i3k_sbean.update_curspawnarea.handler(bean, res)
	local mapType = g_i3k_game_context:GetWorldMapType()
	if mapType == g_MAGIC_MACHINE then
		g_i3k_game_context:refreshCurMagicMachineArena(bean.id)
	else
	g_i3k_game_context:SetDungeonSpawnID(bean.id)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateAtAnyMomentState")
	end	
end

-- 奖励怪物刷新后进入副本推送坐标
function i3k_sbean.monster_position.handler(bean)
	g_i3k_game_context:SetMonsterPosition(bean.position)
end

------------------------------------单机副本------------------------------------------------
-- 同步玩家单机副本装备耐久
function i3k_sbean.sync_privatemap_durability(args)
	local bean = i3k_sbean.privatemap_durability.new()
	bean.wid = args.wid
	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 同步单机副本杀怪进度
function i3k_sbean.sync_privatemap_kill(args)
	local bean = i3k_sbean.privatemap_kill.new()
	bean.spawnPointID = args.spawnPointID
	bean.position = i3k_sbean.Vector3.new()
	bean.position.x = args.pos.x
	bean.position.y = args.pos.y
	bean.position.z = args.pos.z
	bean.weaponID = args.weaponID
	local damageRank = {} -- 单机本伤害排行同步
	for k, v in pairs(args.damageRank) do
		local attackDamageDetail = i3k_sbean.AttackDamageDetail.new()
		attackDamageDetail.attackName = v.attackName
		attackDamageDetail.damage = v.damage
		damageRank[k] = attackDamageDetail
	end
	bean.damageRank = damageRank
	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 单机副本持续掉落
function i3k_sbean.sync_privatemap_damage_reward(args)
	--self.spawnPointID:		int32
	--self.position:		Vector3
	--self.index:		vector[int32]
	local bean = i3k_sbean.privatemap_damage_reward.new()
	bean.spawnPointID = args.spawnPointID
	bean.position = i3k_sbean.Vector3.new()
	bean.position.x = args.pos.x
	bean.position.y = args.pos.y
	bean.position.z = args.pos.z
	bean.index = args.index
	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 同步单机副本陷阱状态
--Packet:privatemap_trap
function i3k_sbean.sync_privatemap_trap(args)
	local bean = i3k_sbean.privatemap_trap.new()
	bean.trapID = args.trapID
	bean.trapState = args.trapState
	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 同步玩家单机副本血量
--Packet:privatemap_role_updatehp
-- 同步佣兵单机副本血量
--Packet:privatemap_pet_updatehp
function i3k_sbean.privatemap_update_hp(entity,curHP,cfgID)
	if entity:GetEntityType() == eET_Player then
		local bean = i3k_sbean.privatemap_role_updatehp.new()
		bean.hp = curHP;
		i3k_game_send_str_cmd(bean)
	elseif entity:GetEntityType() == eET_Mercenary then
		local bean = i3k_sbean.privatemap_pet_updatehp.new()
		bean.cfgID = cfgID;
		bean.hp = curHP;
		i3k_game_send_str_cmd(bean)
	end
end

------------------------------------------------------------------------------------
-- 玩家鬼魂状态
--Packet:role_ghost
function i3k_sbean.role_ghost.handler(bean, res)
	local player = i3k_game_get_player()
	if player then
		player:SetCameraEntity()
	end
end

--进入身世副本同步变身的佣兵ID
function i3k_sbean.role_petalter.handler(bean)
	local pid = bean.pid
	
	if i3k_game_get_map_type() ~= g_PET_ACTIVITY_DUNGEON then
		g_i3k_game_context:SetLifeTaskRecordPetID(pid)
	else
		g_i3k_game_context:setPetDungeonID(pid)
	end
		
	local allData,PlayData,OtherData = g_i3k_game_context:GetYongbingData()
	local level = allData[pid] and allData[pid].level or 1
	local world = i3k_game_get_world();
	local player = i3k_game_get_player()
	local hero = i3k_game_get_player_hero()
	if player and not hero._inPetLife then
		world:OnPlayerEnterWorld(nil);
		player:SetPetLifeEntity(pid, level)
		world:OnPlayerEnterWorld(player);
	end
end

-- map同步当前出战佣兵
function i3k_sbean.role_fightpets.handler(bean)
	g_i3k_game_context:setRoleFightPets(bean.pets)
	g_i3k_game_context:RefreshMercenarySpiritsProps()
	g_i3k_game_context:UpdateWeaponSikillProp()
end

-- map同步当前神兵ID
function i3k_sbean.role_curweapon.handler(bean)
	local hero = i3k_game_get_player_hero()
	if hero then
		if bean.curWeapon ~= 0 then
			g_i3k_game_context:SetUseShenbing(bean.curWeapon)
			if g_i3k_db.i3k_db_is_weapon_unique_skill_has_aitrigger(bean.curWeapon) then
				g_i3k_game_context:setShenBingUniqueTrigger()
			else
				g_i3k_game_context:releaseShenBingUniqueTrigger()
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateSoulEnergy", g_i3k_game_context:GetSoulEnergy())
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "showWolfWeapon")
		end
	end
end

--进入宠物试炼同步
function i3k_sbean.pettrain_enter_sync.handler(bean)
	local info = bean.info
	
	if info then
		g_i3k_game_context:setPetDungeonInfo(info)
	end
end
function i3k_sbean.role_fiveelenemt.handler(bean)
	local info = bean.info
	if info then
		g_i3k_game_context:setFiveElementsInfo(info)
	end
end
function i3k_sbean.fiveelenemt_unlock_lastmap.handler(bean)
	local unlockFlag = 1
	g_i3k_game_context:setFiveElementsUnlockFlag(unlockFlag)
end
function i3k_sbean.five_elements_org(index, pets)
	local bean = i3k_sbean.fiveelement_org_req.new()
	bean.index = index
	bean.pets = pets
	i3k_game_send_str_cmd(bean,i3k_sbean.fiveelement_org_res.getName())
end
function i3k_sbean.fiveelement_org_res.handler(res, req)
	if res.ok == 1 then
		g_i3k_game_context:setFiveElementsStartIndex(req.index)
		i3k_sbean.five_elements_start(req.pets)
	end
end
function i3k_sbean.five_elements_start(pets)
	local bean = i3k_sbean.fiveelement_start_req.new()
	local petData = {}
	for k, v in ipairs(pets) do
		petData[v] = true
	end
	bean.pets = petData
	i3k_game_send_str_cmd(bean,i3k_sbean.fiveelement_start_res.getName())
end
function i3k_sbean.fiveelement_start_res.handler(res, req)
	if res.ok == 1 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_FIVE_ELEMENTS, g_SCHEDULE_COMMON_MAPID)
		g_i3k_game_context:ClearFindWayStatus()
		g_i3k_game_context:addFiveElementsEnterTimes()
	end
end

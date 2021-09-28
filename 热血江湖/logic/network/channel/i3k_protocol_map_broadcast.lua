------------------------------------------------------
module(..., package.seeall)

local require = require
require("i3k_sbean")

local frame_task_mgr = require("i3k_frame_task_mgr")

require("logic/entity/i3k_entity_def");
local BASE = require("logic/network/channel/i3k_channel");

local function addUpdateModelNetEntityCreatTask(world, name, RoleID, eType, configID, args, bwType, birthEffect, sectId)
	frame_task_mgr.addNormalTask({
				taskType = "net_entity",
				etype = eType,
				eid = RoleID,
				run = function()
					i3k_warn("!!!(tick=" .. i3k_get_update_tick() .. ") FrameTask runTask, etype=" .. eType ..", id= " .. RoleID)
					world:UpdateModelFromNetwork(RoleID,eType,configID, args, bwType, sectId);
					if birthEffect then
						local entityMonster = world._entities[eGroupType_E][name];
						if entityMonster and entityMonster._cfg and entityMonster._cfg.birtheffect then
							entityMonster:PlayHitEffect(entityMonster._cfg.birtheffect)
						end
					end
				end})

	return true
end

local function updateCreateNetEntityTask(RoleID, eType)
	--i3k_warn("FrameTask cancelTask, etype=" .. eType ..", id= " .. RoleID)
	--i3k_log("updateCreateNetEntityTask:".."RoleID ="..RoleID);
	frame_task_mgr.updateTask(function(task)
			return task.taskType == "net_entity" and task.etype == eType and task.eid == RoleID
		end)
end

--用于记录荣耀殿堂协议中的数据
local function getStatuArgsFromBean(info)
	local equips = {}
	for _,v in pairs(info.detail.wearEquips) do
		table.insert(equips, v.equip.id)
	end
	local args = {
	    RoleID      = info.roleID,
		RoleType 	= info.classType,
		Rolename 	= info.name,
		Gender 		= info.gender,
		--HeadIconID	= overview.headIcon,
		--HeadBorder 	= overview.headBorder,
		--nLevel		= overview.level,
		bwtype		= info.bwType,
		StatueType	= info.statueType,
		Face		= info.detail.face,
		Hair		= info.detail.hair,
		Armor		= info.detail.armor,
		roleEquipsDetails = info.detail.wearParts,
		fashions	= info.detail.curFashions,
		Equips		= equips,
		heirloom	= info.detail.heirloom,
		weaponSoulShow = info.detail.weaponSoulShow,
		soaringDisplay = info.detail.soaringDisplay,
		--sectname	= title.sectBrief.sectName,
		--sectID		= title.sectBrief.sectID,
		--sectPosition = title.sectBrief.sectPosition,
		--sectIcon	= title.sectBrief.sectIcon,
		--permanentTitle = title.permanentTitle,
		--timedTitles = title.timedTitles,

		--armorWeak	= state.armorWeak,
		}
	return	args
end


local SelectExp =
{
	[ 1] = function(tbl) -- 最近
		local _cmp = function(d1, d2)
			return d1.dist < d2.dist;
		end
		table.sort(tbl, _cmp);
	end,

	[ 2] = function(tbl) -- 最远
		local _cmp = function(d1, d2)
			return d1.dist > d2.dist;
		end
		table.sort(tbl, _cmp);
	end,
};
-----------------------------------------------------------广播协议-----------------------------------------------------------

------------------------------------------------------------------------------------
-- 附近玩家改变朝向（单体技能时使用）
--Packet:nearby_role_change_rotation
function i3k_sbean.nearby_role_change_rotation.handler(bean, res)
	local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
	local Dir = {x = 0 ,y = r ,z = 0 }
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:SetFaceDir(Dir.x,Dir.y,Dir.z);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 附近NPC出现
function i3k_sbean.nearby_enter_npcs.handler(bean, res)
	local npcs = bean.npcs or {}
	for i,v in ipairs(npcs) do
		local SEntity = require("logic/entity/i3k_npc");
		local entityNPC = SEntity.i3k_npc.new(i3k_gen_entity_guid_new(SEntity.i3k_npc.__cname, -v.id));
		if entityNPC:Create(v.cfgID, false, true) then
			local r = i3k_vec3_angle2(i3k_vec3(v.location.rotation.x, v.location.rotation.y, v.location.rotation.z), i3k_vec3(1, 0, 0));
			entityNPC:SetFaceDir(0, r, 0);
			-- entityNPC:SetFaceDir(v.location.rotation.y,v.location.rotation.x,v.location.rotation.z);
			entityNPC:SetPos(v.location.position);
			entityNPC:SetGroupType(eGroupType_O);
			entityNPC:Play(i3k_db_common.engine.defaultStandAction, -1);
			entityNPC:NeedUpdateAlives(false);
			entityNPC:SetCtrlType(eCtrlType_Network);
			entityNPC:AddAiComp(eAType_IDLE_NPC);
			entityNPC:AddAiComp(eAType_DEAD);
			entityNPC:Show(true, true, 100);
			entityNPC:ShowTitleNode(true);
			entityNPC:SetHittable(true)
			local logic = i3k_game_get_logic();
			local world = logic:GetWorld();
			world:CheckNpcShow(entityNPC)
			world:AddEntity(entityNPC);
		end
	end
	return true;
end

-- 附近NPC离开
function i3k_sbean.nearby_leave_npcs.handler(bean, res)
	-- local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
	-- local Dir = {x = 0 ,y = r ,z = 0 }
	local npcs = bean.npcs or {}
	local world = i3k_game_get_world()
	if world then
		for i,v in ipairs(npcs) do
			local Entity = world:GetNeutralNpcByID(-v);
			if Entity then
				world:ReleaseEntity(Entity);
			end
		end
	end
	return true;
end

--------------------------------------------------------
--附近玩家攻击目标改变（单体技能时使用）
--Packet nearby_role_change_target
function i3k_sbean.nearby_role_change_target.handler(bean,res)
	local User = nil;
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld();
		if world then
			local User = world:GetEntity(eET_Player, bean.rid);
			if bean.targetType == eET_Mercenary then
				Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.targetOwnerID);
			else
				Target = world:GetEntity(bean.targetType, bean.targetID);
			end
		end
		--[[if Target then
			User._target = Target
			User:SetTarget(Target)
		else
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:StartTurnTo(Dir);
		end--]]
		--目标
	end
end

------------------------------------------------------
--查询周围entity是否可删除
function i3k_sbean.entity_nearby.handler(bean,res)
	local Entity = nil;
	local world = i3k_game_get_world();
	if world then
		if bean.type then
			Entity = world:GetEntity(bean.type, bean.id);
		end
	end
	if Entity and bean.near then
		if bean.near == 0 then
			world:ReleaseEntity(Entity);
		end
	end

	return true;
end

------------------------------------------------------
-- 周围玩家们进入视野
--Packet:nearby_enter_roles
function i3k_sbean.nearby_enter_roles.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.roles) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.base.location.position, hero._curPos))
		end
		if #bean.roles > 0 then
			local exp = SelectExp[1];
			exp(bean.roles);
		end
	end
	local queryrolelist = {}
	for k,v in pairs(bean.roles) do
		local StartPos = v.base.location.position;
		local r = i3k_vec3_angle2(i3k_vec3(v.base.location.rotation.x,v.base.location.rotation.y,v.base.location.rotation.z), i3k_vec3(1, 0, 0));
		local Dir_p = {x = 0 ,y = r ,z = 0 }
		local world = i3k_game_get_world()
		if world then
		if world._embracers[i3k_game_on_entity_guid(eET_Player.."|"..v.base.id)] then
			return
		end

		local mapId = world._cfg.id
		--i3k_log("----- ====  1 nearby_enter_roles ",v.base.id,StartPos.x,mapId,hero._id)
		g_i3k_game_context:setForceWarMemberPosition(v.base.id, StartPos, mapId)---设置势力战成员位置

			local entityPlayer = world:GetEntity(eET_Player, v.base.id);
			if i3k_game_get_map_type() == g_FORCE_WAR then
				g_i3k_game_context:setForceWarMemberInfo(v.base.id, v.base.forceType)
			end
			if not entityPlayer then
				world:CreateModelFromNetwork(v.base.id, eET_Player, StartPos, Dir_p, v.base.forceType, v.curHP, v.maxHP, nil, nil, nil, nil, nil, v.base.sectId, v.base.bwType, nil, v.isDead);
			else
				if v.isDead == 0 then
					entityPlayer:ClearState();
				end
				entityPlayer:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				entityPlayer:SetFaceDir(0, Dir_p.y, 0);
				if v.maxHP and v.curHP then
					entityPlayer:UpdateProperty(ePropID_maxHP, 1, v.maxHP, true, false,true);
					entityPlayer:UpdateHP(v.curHP);
					entityPlayer:UpdateBloodBar(entityPlayer:GetPropertyValue(ePropID_hp) / entityPlayer:GetPropertyValue(ePropID_maxHP));
				end
				entityPlayer:ResetLeaveCache();
			end
			table.insert(queryrolelist, v.base.id)
		end
	end
	if #queryrolelist >0 then
		i3k_sbean.map_query_entitys(eET_Player,queryrolelist)
	end
	return true;
end

------------------------------------------------------
-- 周围佣兵们进入视野
--Packet:nearby_enter_pets
function i3k_sbean.nearby_enter_pets.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.pets) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.base.location.position, hero._curPos))
		end
		if #bean.pets > 0 then
			local exp = SelectExp[1];
			exp(bean.pets);
		end
	end
	local querypetlist = {}
	for k,v in pairs(bean.pets) do
		local r = i3k_vec3_angle2(i3k_vec3(v.base.location.rotation.x, v.base.location.rotation.y, v.base.location.rotation.z), i3k_vec3(1, 0, 0));
		local Dir_p = {x = 0 ,y = r , z = 0}
		local world = i3k_game_get_world()
		local posId = v.seq;
		if world then
			local entityMercenary = world:GetEntity(eET_Mercenary, v.base.cfgID.."|"..v.base.ownerID);
			if not entityMercenary then
				world:CreateModelFromNetwork(v.base.ownerID, eET_Mercenary, v.base.location.position, Dir_p, v.base.forceType, v.curHP, v.maxHP, v.base.cfgID, nil, nil, nil, nil, nil, v.base.bwType, posId, v.isDead);
				local info = i3k_sbean.PetBase.new()
				info.ownerID = v.base.ownerID
				info.pid = v.base.cfgID
				table.insert(querypetlist,info)
			else
				if v.isDead == 0 then
					entityMercenary:ClearState();
					entityMercenary:OnIdleState();
				end
				entityMercenary:SetPos(v.base.location.position, true);
				entityMercenary:SetPosId(posId)
				entityMercenary:SetBWType(v.base.bwType)
				entityMercenary:SetFaceDir(0, Dir_p.y, 0);
				if v.maxHP and v.curHP then
					entityMercenary:UpdateProperty(ePropID_maxHP, 1, v.maxHP, true, false,true);
					entityMercenary:UpdateHP(v.curHP);
					entityMercenary:UpdateBloodBar(entityMercenary:GetPropertyValue(ePropID_hp) / entityMercenary:GetPropertyValue(ePropID_maxHP));
				end
				--if not entityMonster._entityres then
				--	addCreateNetEntityTaskTest(world, i3k_game_on_entity_guid(v.base.ownerID), v.base.ownerID, eET_Monster, StartPos, Dir_m, v.base.cfgID, args, false)
				--end
				entityMercenary:ResetLeaveCache();
			end
		end
	end
	if #querypetlist >0 then
		i3k_sbean.map_query_entitys(eET_Mercenary,querypetlist)
	end
	return true;
end

-------------------------------------------------------------------------
--周围镖车进入视野
--package:nearby_enter_escortcars
function i3k_sbean.nearby_enter_escortcars.handler(bean)
	for k,v in ipairs(bean.cars) do
		local StartPos = v.detail.base.location.position
		local r = i3k_vec3_angle2(i3k_vec3(v.detail.base.location.rotation.x, v.detail.base.location.rotation.y, v.detail.base.location.rotation.z), i3k_vec3(1, 0, 0));
		local Dir_p = {x = 0 ,y = r ,z = 0 }
		local world = i3k_game_get_world()
		if world then
			local entityCar = world:GetEntity(eET_Car, v.detail.base.id);
			if not entityCar then
				world:CreateModelFromNetwork(v.detail.base.id, eET_Car, StartPos, Dir_p, v.detail.base.forceType, v.detail.curHP, v.detail.maxHP, v.detail.base.cfgID, v.ownerName, v.state, v.curBuffs, v.teamID, v.sectID,nil,nil,nil, v.skin);
			else
				entityCar:ClearState();
				entityCar:OnIdleState();
				entityCar:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				if v.detail.maxHP and v.detail.curHP then
					entityCar:UpdateProperty(ePropID_maxHP, 1,v.detail.maxHP, true, false,true);
					entityCar:UpdateHP(v.detail.curHP);
					entityCar:UpdateBloodBar(entityCar:GetPropertyValue(ePropID_hp) / entityCar:GetPropertyValue(ePropID_maxHP));
				end
				entityCar:SetFaceDir(0, Dir_p.y, 0);
				BUFF = require("logic/battle/i3k_buff"); --镖车添加buff
				for i,e in ipairs(v.curBuffs) do
					local bcfg = i3k_db_buff[e];
					local buff = BUFF.i3k_buff.new(nil,e, bcfg, nil);
					if buff then
						entityCar:AddBuff(nil, buff);
					end
				end
				entityCar:ResetLeaveCache();
				if v.detail.base.id == g_i3k_game_context:GetRoleId() then
					g_i3k_game_context:setEscortCarblood(v.detail.curHP, v.detail.maxHP)
				end
			end
		end
	end

	return true;
end

----------------------------------------------------------------------------
-- 周围婚车进入视野
--Packet:nearby_enter_weddingcars
function i3k_sbean.nearby_enter_weddingcars.handler(bean)
	for _,v in ipairs(bean.cars) do
		local StartPos = v.location.position;
		local world = i3k_game_get_world()
		if world then
			local marryCruise = world._entities[eGroupType_O]["i3k_marry_cruise|"..v.id];
			if not marryCruise then
				world:CreateMarryCruiseEntity(v.id, v.cfgID, v.manID, v.womanID, v.manName, v.womanName, v.location)
			else
				marryCruise:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				marryCruise:ResetLeaveCache();
			end
		end
	end
end

-----------------------------------------------------------------------------
-- 周围怪物在视野出生
--Packet:nearby_spawn_monster
function i3k_sbean.nearby_spawn_monster.handler(bean,res)
	local monsters = bean.monster
	local RoleID = monsters.base.id;
	local configID = monsters.base.cfgID;
	local x = monsters.base.location.position.x;
	local y = monsters.base.location.position.y;
	local z = monsters.base.location.position.z;
	local rotation = monsters.base.location.rotation
	local forceType = monsters.base.forceType
	local curHP = monsters.curHP;
	local maxHP = monsters.maxHP;
	local buffs = monsters.buffs
	local logic = i3k_game_get_logic();
	local StartPos = {x = x,y = y, z = z}
	local r = i3k_vec3_angle2(i3k_vec3(rotation.x, rotation.y, rotation.z), i3k_vec3(1, 0, 0));
	local Dir_y = i3k_engine_get_rnd_f(0, 6.28);
	local Dir_m = {x = 0 ,y = r ,z = 0 }
	local args = { curHP = curHP,maxHP = maxHP, curArmor = monsters.curArmor, maxArmor = monsters.maxArmor, param1 = monsters.param1, Buffs = buffs}
	if logic then
		local world = logic:GetWorld();
		if world then
			local entityMonster = world:GetEntity(eET_Monster, RoleID);
			if not entityMonster then
				local firstCreate = true
				world:CreateModelFromNetwork(RoleID, eET_Monster, StartPos, Dir_m, forceType, curHP, maxHP, configID, nil, nil, nil, nil, monsters.base.sectId, false, nil, nil, nil, firstCreate, monsters.clickNum) --v.base.sectId);
				addUpdateModelNetEntityCreatTask(world, i3k_game_on_entity_guid(eET_Monster.."|"..RoleID), RoleID, eET_Monster, configID, args, false, true, monsters.base.sectId) --v.base.sectId)
			else
				local id = math.abs(configID)
				local cfg = i3k_db_monsters[id];
				entityMonster:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)), g_i3k_db.i3k_db_get_detection_block_range(cfg))))
				if maxHP and curHP then
					entityMonster:UpdateProperty(ePropID_maxHP, 1,maxHP, true, false,true);
					entityMonster:UpdateHP(curHP);
					entityMonster:UpdateBloodBar(entityMonster:GetPropertyValue(ePropID_hp) / entityMonster:GetPropertyValue(ePropID_maxHP));
				end
				if not entityMonster:IsResCreated() then
					addUpdateModelNetEntityCreatTask(world, i3k_game_on_entity_guid(eET_Monster.."|"..RoleID), RoleID, eET_Monster, configID, args, false, false, monsters.base.sectId)
				end
				
				entityMonster:setCanClickCount(monsters.clickNum);		
				entityMonster:ResetLeaveCache();
			end
			if world._mapType == g_SPIRIT_BOSS then
				local bossData = g_i3k_game_context:getSpiritBossData()
				g_i3k_game_context:setSpiritBossData({}, bossData.nextBuffTime, configID, curHP, bossData.curBossIndex)
				g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossFight)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateBossBlood", configID, curHP, maxHP)
			end
		end
	end

	return true;
end

-----------------------------------------------------------------------------
-- 周围怪物们进入视野
--Packet:nearby_enter_monsters
function i3k_sbean.nearby_enter_monsters.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.monsters) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.base.location.position, hero._curPos))
		end
		if #bean.monsters > 0 then
			local exp = SelectExp[1];
			exp(bean.monsters);
		end
	end

	for k,v in pairs(bean.monsters) do
		local r = i3k_vec3_angle2(i3k_vec3(v.base.location.rotation.x, v.base.location.rotation.y, v.base.location.rotation.z), i3k_vec3(1, 0, 0));
		local StartPos = v.base.location.position
		local Dir_y = i3k_engine_get_rnd_f(0, 6.28);
		local Dir_m = {x = 0 ,y = r ,z = 0 }
		local args = { curHP = v.curHP, maxHP = v.maxHP, curArmor = v.curArmor, maxArmor = v.maxArmor, param1 = v.param1, Buffs = v.buffs}
		local world = i3k_game_get_world()
		if world then
			--i3k_log("nearby_enter_monsters = " ..v.base.id)
			local entityMonster = world:GetEntity(eET_Monster, v.base.id);
			if not entityMonster then
				local firstCreate = true
				updateCreateNetEntityTask(v.base.id, eET_Monster);
				world:CreateModelFromNetwork(v.base.id, eET_Monster, StartPos, Dir_m, v.base.forceType, v.curHP, v.maxHP, v.base.cfgID, nil, nil, nil, nil, v.base.sectId, v.base.bwType, nil, v.isDead, nil, firstCreate, v.clickNum);
				addUpdateModelNetEntityCreatTask(world, i3k_game_on_entity_guid(eET_Monster.."|"..v.base.id), v.base.id, eET_Monster, v.base.cfgID, args, v.base.bwType, false, v.base.sectId)
			else
				local id = v.base.cfgID
				if entityMonster._id ~= id then
					local cfg = i3k_db_monsters[id];
					if cfg and cfg.modelID then
						entityMonster:ChangeModelFacade(cfg.modelID)
					end				
				end
				entityMonster:ClsAttackers();
				entityMonster:ClearState();
				entityMonster:OnIdleState();
				entityMonster:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)), g_i3k_db.i3k_db_get_detection_block_range(cfg))))
				entityMonster:SetFaceDir(0, Dir_m.y, 0);
				if v.maxHP and v.curHP then
					entityMonster:UpdateProperty(ePropID_maxHP, 1,v.maxHP, true, false,true);
					entityMonster:UpdateHP(v.curHP);
					entityMonster:UpdateBloodBar(entityMonster:GetPropertyValue(ePropID_hp) / entityMonster:GetPropertyValue(ePropID_maxHP));
				end

				entityMonster:ResetLeaveCache();
				entityMonster:setCanClickCount(v.clickNum);		
			end
			if world._mapType == g_SPIRIT_BOSS then
				g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossFight)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateBossBlood", v.base.cfgID, v.curHP, v.maxHP)
			end
		end
	end
	
	return true;
end

------------------------------------------------------
-- 周围陷阱们进入视野
--Packet:nearby_enter_traps
function i3k_sbean.nearby_enter_traps.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.traps) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.location.position, hero._curPos))
		end
		if #bean.traps > 0 then
			local exp = SelectExp[1];
			exp(bean.traps);
		end
	end
	local querytraplist = {}
	for k,v in pairs(bean.traps) do
		local curState = v.ownerID;
		local StartPos = v.location.position
		local r = i3k_vec3_angle2(i3k_vec3(v.location.rotation.x, v.location.rotation.y, v.location.rotation.z), i3k_vec3(1, 0, 0));
		local Dir_m = {x = 0 ,y = r ,z = 0 }
		local world = i3k_game_get_world()
		local args = {ncurState = curState ,TargetIDs = relatedTraps}
		-- local roleID = g_i3k_game_context:GetRoleId()
		-- i3k_log(roleID.. "   nearby_enter_traps ".. v.id)
		if world then
			local entityTrap = world:GetEntity(eET_Trap, v.id);
			if not entityTrap then
				world:CreateModelFromNetwork(v.id, eET_Trap, StartPos, Dir_m, nil, nil, nil, v.cfgID);
				addUpdateModelNetEntityCreatTask(world, "i3k_trap|"..v.id, v.id, eET_Trap, v.cfgID, args, false, false)
			else
				if curState then
					entityTrap:SetTrapBehavior(curState,true);
				else
					entityTrap:SetTrapBehavior(eSTrapLocked,true);
				end
				entityTrap:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				entityTrap:ResetLeaveCache();
			end
		end
	end
	return true;
end

-----------------------------------------------------------------------------
-- 周围矿点们进入视野
--Packet:nearby_enter_minerals
function i3k_sbean.nearby_enter_minerals.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.minerals) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.location.position, hero._curPos))
		end
		if #bean.minerals > 0 then
			local exp = SelectExp[1];
			exp(bean.minerals);
		end
	end
	for k,v in pairs(bean.minerals) do
		local StartPos = v.location.position
		local r = i3k_vec3_angle2(i3k_vec3(v.location.rotation.x, v.location.rotation.y, v.location.rotation.z), i3k_vec3(1, 0, 0));
		local Dir_m = {x = 0 ,y = r ,z = 0 }
		local world = i3k_game_get_world()
		if world then
			local entityResourcePoint = world._ResourcePoints[v.id];
			if not entityResourcePoint then
				world:CreateModelFromNetwork(v.id,eET_ResourcePoint,StartPos,Dir_m);
				local args = {state = v.state,ownType = v.ownType, lastCnt = v.lastCnt}
				addUpdateModelNetEntityCreatTask(world, "i3k_mine|"..v.id, v.id, eET_ResourcePoint, v.cfgID, args)
			else
				entityResourcePoint:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				entityResourcePoint:ResetLeaveCache();
			end
		end
	end
	return true;
end

-----------------------------------------------------------------------------
-- 周围掉落场景BUFF
function i3k_sbean.drop_mapbuff.handler(bean,res)
	local StartPos = bean.mapbuff.position;
	local Dir_y = i3k_engine_get_rnd_f(0, 6.28);
	local Dir_m = {x = 0 ,y = Dir_y ,z = 0 }
	local world = i3k_game_get_world();
	if world then
		local MapBuff = world._mapbuffs[bean.mapbuff.id];
		if not MapBuff then
			world:CreateModelFromNetwork(bean.mapbuff.id,eET_MapBuff,StartPos,Dir_m);
			addUpdateModelNetEntityCreatTask(world, "i3k_mapbuff|"..bean.mapbuff.id, bean.mapbuff.id, eET_MapBuff, bean.mapbuff.cfgID)
		else
			MapBuff:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
			MapBuff:ResetLeaveCache();
		end
	end

	return true;
end

-----------------------------------------------------------------------------
-- 周围场景BUFF们进入视野
--Packet:nearby_enter_mapbuffs
function i3k_sbean.nearby_enter_mapbuffs.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.mapbuffs) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.location.position, hero._curPos))
		end
		if #bean.mapbuffs> 0 then
			local exp = SelectExp[1];
			exp(bean.mapbuffs);
		end
	end
	for k,v in pairs(bean.mapbuffs) do
		local StartPos = v.location.position
		local Dir_y = i3k_engine_get_rnd_f(0, 6.28);
		local Dir_m = {x = 0 ,y = Dir_y ,z = 0 }
		local world = i3k_game_get_world()
		if world then
			local MapBuff = world._mapbuffs[v.id];
			if not MapBuff then
				world:CreateModelFromNetwork(v.id,eET_MapBuff,StartPos,Dir_m);
				addUpdateModelNetEntityCreatTask(world, "i3k_mapbuff|"..v.id, v.id, eET_MapBuff, v.cfgID)
			else
				MapBuff:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				MapBuff:ResetLeaveCache();
			end
		end
	end
	return true;
end

-----------------------------------------------------------------------------
-- 周围法阵们进入视野
--Packet:nearby_enter_skillentitys
function i3k_sbean.nearby_enter_skillentitys.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.skillentitys) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.base.location.position, hero._curPos))
		end
		if #bean.skillentitys> 0 then
			local exp = SelectExp[1];
			exp(bean.skillentitys);
		end
	end
	for k,v in pairs(bean.skillentitys) do
		local skillID = v.base.cfgID
		local StartPos = v.base.location.position;
		local Dir_m = {x = 0 ,y = 0.785 ,z = 0 }
		local world = i3k_game_get_world()
		if world then
			local entitySkill = world:GetEntity(eET_Skill, v.base.id);
			if not entitySkill then
				local args = {Pos = StartPos , skillID = skillID , modelID = v.modelID ,Dir = Dir_m,ownerID = v.base.ownerID }
				world:UpdateModelFromNetwork(v.base.id, eET_Skill, nil, args);
			else
				entitySkill:ClearState();
				entitySkill:OnIdleState();
				entitySkill:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				entitySkill:SetFaceDir(0, Dir_m.y, 0);
				entitySkill:ResetLeaveCache();
			end
		end
	end


	return true;
end

-----------------------------------------------------------------------------
-- 周围残影们进入视野
--Packet:nearby_enter_blurs
function i3k_sbean.nearby_enter_blurs.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.blurs) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.base.location.position, hero._curPos))
		end
		if #bean.blurs > 0 then
			local exp = SelectExp[1];
			exp(bean.blurs);
		end
	end
	for k,v in pairs(bean.blurs) do
		local r = i3k_vec3_angle2(i3k_vec3(v.base.location.rotation.x, v.base.location.rotation.y, v.base.location.rotation.z), i3k_vec3(1, 0, 0));
		local StartPos = v.base.location.position;
		local Dir_m = {x = 0 ,y = r ,z = 0 }
		local world = i3k_game_get_world()
		if world then
			local entityPet = world:GetEntity(eET_Pet, v.base.id);
			if not entityPet then
				local args = {Pos = StartPos, curHP = v.curHP, maxHP = v.maxHP, Dir = Dir_m, ownerID = v.base.ownerID, forceType = v.base.forceType}
				--world:UpdateModelFromNetwork(v.base.id,eET_Pet,v.base.cfgID,args);
				addUpdateModelNetEntityCreatTask(world, i3k_game_on_entity_guid(eET_Pet.."|"..v.base.id), v.base.id, eET_Pet, v.base.cfgID, args, v.base.bwType, nil, v.base.sectId)
			else
				entityPet:ClearState();
				entityPet:OnIdleState();
				entityPet:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				entityPet:SetFaceDir(0, Dir_m.y, 0);
				entityPet:UpdateProperty(ePropID_maxHP, 1, v.maxHP, true, false, true);
				entityPet:UpdateHP(v.curHP);
				entityPet:ResetLeaveCache();
			end
		end
	end
	return true;
end

-----------------------------------------------------------------------------
-- 周围符灵卫进入视野
--Packet:nearby_enter_summoneds
function i3k_sbean.nearby_enter_summoneds.handler(bean,res)
	local hero = i3k_game_get_player_hero()
	if hero then
		for k,v in pairs(bean.summoneds) do
			v.dist = i3k_vec3_len(i3k_vec3_sub1(v.base.location.position, hero._curPos))
		end
		if #bean.summoneds > 0 then
			local exp = SelectExp[1];
			exp(bean.summoneds);
		end
	end
	for k,v in pairs(bean.summoneds) do
		local r = i3k_vec3_angle2(i3k_vec3(v.base.location.rotation.x, v.base.location.rotation.y, v.base.location.rotation.z), i3k_vec3(1, 0, 0));
		local StartPos = v.base.location.position;
		local Dir_m = {x = 0 ,y = r ,z = 0 }
		local world = i3k_game_get_world()
		if world then
			local entityPet = world:GetEntity(eET_Summoned, v.base.id);
			if not entityPet then
				i3k_log("nearby_enter_summoneds"..v.base.id.."guid"..hero._guid);
				local args = {Pos = StartPos, curHP = v.curHP, maxHP = v.maxHP, Dir = Dir_m, ownerID = v.base.ownerID, forceType = v.base.forceType}
				--world:UpdateModelFromNetwork(v.base.id,eET_Pet,v.base.cfgID,args);
				addUpdateModelNetEntityCreatTask(world, i3k_game_on_entity_guid(eET_Summoned.."|"..v.base.id), v.base.id, eET_Summoned, v.base.cfgID, args, v.base.bwType, nil, v.base.sectId)
			else
				entityPet:ClearState();
				entityPet:OnIdleState();
				entityPet:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos)))))
				entityPet:SetFaceDir(0, Dir_m.y, 0);
				entityPet:UpdateProperty(ePropID_maxHP, 1, v.maxHP, true, false, true);
				entityPet:UpdateHP(v.curHP);
				entityPet:ResetLeaveCache();
			end
		end
	end
	return true;
end
------------------------------------------------------------------------------------
-- 周围场景BUFF离开视野
--Packet:nearby_leave_mapbuff
function i3k_sbean.nearby_leave_mapbuff.handler(bean, res)
	updateCreateNetEntityTask(bean.id, eET_MapBuff)
	local RoleID = bean.id;
	local world = i3k_game_get_world();
	if world then
		local MapBuff = world._mapbuffs[RoleID];
		if MapBuff then
			world:ReleaseEntity(MapBuff, false);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家们离开视野
--Packet:nearby_leave_roles
function i3k_sbean.nearby_leave_roles.handler(bean, res)
	local roles = bean.roles
	local destory = bean.destory
	for k, v in ipairs(roles) do
		updateCreateNetEntityTask(v, eET_Player)
		local world = i3k_game_get_world();
		if world then
			local entity = world:GetEntity(eET_Player, v, true);
			if entity then
				if table.nums(entity:GetLinkEntitys()) then
					for i, e in pairs(entity:GetLinkEntitys()) do
						if not e:IsPlayer() then
							e:Release();
							world:RmvEntity(e);
							world:ReleasePassenger(e._guid);
						end
					end
				end
				if entity._linkHugChild then
					entity._linkHugChild:Release();
					world:RmvEntity(entity._linkHugChild);
					world:ReleaseEmbracer(entity._linkHugChild._guid);
				end
				if entity._behavior:Test(eEBDaZuo) then
					entity._behavior:Clear(eEBDaZuo);
				end
				world:ReleaseShowPlayer(entity._guid);
				world:ReleaseEntity(entity, destory == 1);

				if i3k_game_get_map_type()==g_FORCE_WAR  then
					g_i3k_game_context:ForceWarMemberLeave(v, entity._forceType)---势力战小地图上删除
				end
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物们离开视野
--Packet:nearby_leave_monsters
function i3k_sbean.nearby_leave_monsters.handler(bean, res)
	local monsters = bean.monsters
	for k, v in ipairs(monsters) do
		--i3k_log("nearby_leave_monsters id = " ..v)
		updateCreateNetEntityTask(v, eET_Monster)
		local world = i3k_game_get_world();
		if world then
			local entity = world:GetEntity(eET_Monster, v);
			if entity then
				world:ReleaseEntity(entity, false);
			end
		end
	end

	return true;
end
-----------------------------------------------------------------------------------
-- 周围怪物从视野内删除 （无延迟）
--Packet:spy_world_patrol_monster_vanish
function i3k_sbean.spy_world_patrol_monster_vanish.handler(bean, res)
	local monstersId = bean.monsterID
	updateCreateNetEntityTask(monstersId, eET_Monster)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, monstersId);

		if entity then
			world:ReleaseEntity(entity, true);
		end
	end
	return true;
end
------------------------------------------------------------------------------------
-- 周围陷阱们离开视野
--Packet:nearby_leave_traps
function i3k_sbean.nearby_leave_traps.handler(bean, res)
	local traps = bean.traps
	for k,v in ipairs(traps) do
		-- local roleID = g_i3k_game_context:GetRoleId()
		-- i3k_log(roleID.. "   nearby_leave_traps ".. v)
		updateCreateNetEntityTask(v, eET_Trap)
		local world = i3k_game_get_world();
		if world then
			local entityTrap = world:GetEntity(eET_Trap, v);
			if entityTrap then
				world:ReleaseEntity(entityTrap, true);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵们离开视野
--Packet:nearby_leave_pets
function i3k_sbean.nearby_leave_pets.handler(bean, res)
	for k,v in ipairs(bean.pets) do
		local rid = v.pid.."|"..v.ownerID ;
		updateCreateNetEntityTask(rid, eET_Mercenary)
		local world = i3k_game_get_world();
		if world then
			local entity = world:GetEntity(eET_Mercenary, rid);
			if entity then
				world:ReleaseEntity(entity, bean.destory == 1);
			end
		end
	end

	return true;
end

-------------------------------------------------------------------------------------
--周围镖车离开视野
--package:nearby_leave_escortcars
function i3k_sbean.nearby_leave_escortcars.handler(bean)
	for k,v in ipairs(bean.cars) do
		updateCreateNetEntityTask(v, eET_Car)
		local world = i3k_game_get_world();
		if world then
			local entity = world:GetEntity(eET_Car, v);
			if entity then
				world:ReleaseEntity(entity, true);
			end
		end
	end
	return true;
end

-----------------------------------------------------------------------------------
--周围婚车离开视野
--package:nearby_leave_weddingcars
function i3k_sbean.nearby_leave_weddingcars.handler(bean)
	for _,v in ipairs(bean.cars) do
		updateCreateNetEntityTask(v, eET_MarryCruise)
		local world = i3k_game_get_world();
		if world then
			local entity = world._entities[eGroupType_O]["i3k_marry_cruise|" .. v];
			if entity then
				for _,v in ipairs(entity._carEntityTab) do
					world:ReleaseEntity(v, true);
				end
				world:ReleaseEntity(entity, true);
			end
		end
	end
end
------------------------------------------------------------------------------------
-- 周围矿点们离开视野
--Packet:nearby_leave_minerals
function i3k_sbean.nearby_leave_minerals.handler(bean, res)
	for k,v in pairs(bean.minerals) do
		updateCreateNetEntityTask(v, eET_ResourcePoint)
		local world = i3k_game_get_world();
		if world then
			local entityResourcePoint = world._ResourcePoints[v];
			if entityResourcePoint then
				if world._mapType == g_BASE_DUNGEON and world._openType == g_FIELD then
					world:RmvEntity(entityResourcePoint);
				else
					world:ReleaseEntity(entityResourcePoint);
				end
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围场景BUFF们离开视野
--Packet:nearby_leave_mapbuffs
function i3k_sbean.nearby_leave_mapbuffs.handler(bean, res)
	for k,v in pairs(bean.mapbuffs) do
		updateCreateNetEntityTask(v, eET_MapBuff)
		local world = i3k_game_get_world();
		if world then
			local MapBuff = world._mapbuffs[v];
			if MapBuff then
				world:ReleaseEntity(MapBuff, false);
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围法阵们离开视野
--Packet:nearby_leave_skillentitys
function i3k_sbean.nearby_leave_skillentitys.handler(bean, res)
	for k,v in pairs(bean.skillentitys) do
		updateCreateNetEntityTask(v, eET_Skill)
		local world = i3k_game_get_world();
		if world then
			local SkillEntity = world:GetEntity(eET_Skill, v);
			if SkillEntity then
				world:ReleaseEntity(SkillEntity, false);
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围残影们离开视野
--Packet:nearby_leave_blurs
function i3k_sbean.nearby_leave_blurs.handler(bean, res)
	for k,v in pairs(bean.blurs) do
		updateCreateNetEntityTask(v, eET_Pet)
		local world = i3k_game_get_world();
		if world then
			local entity = world:GetEntity(eET_Pet, v);
			if entity then
				world:ReleaseEntity(entity, true);
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围符灵卫离开视野
--Packet:nearby_leave_summoneds
function i3k_sbean.nearby_leave_summoneds.handler(bean, res)
	for k,v in pairs(bean.blurs) do
		updateCreateNetEntityTask(v, eET_Summoned)
		local world = i3k_game_get_world();
		if world then
			local entity = world:GetEntity(eET_Summoned, v);
			if entity then
				i3k_log("nearby_leave_summoneds:"..v);
				world:ReleaseEntity(entity, true);
			end
		end
	end

	return true;
end

------------------------------------------------------
-- 周围玩家重置位置
--Packet:nearby_role_resetposition
function i3k_sbean.nearby_role_resetposition.handler(bean,res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			entityPlayer:SetPos({x = bean.pos.x, y = bean.pos.y, z = bean.pos.z});
		end
	end
	return true;
end

-----------------------------------------------------------------------------
-- 周围佣兵重置位置
--Packet:nearby_pet_resetposition
function i3k_sbean.nearby_pet_resetposition.handler(bean,res)
	local world = i3k_game_get_world();
	if world then
		local entityMercenary = world:GetEntity(eET_Mercenary, bean.pid.."|"..bean.rid);
		if entityMercenary then
			entityMercenary._forceFollow = nil;
			entityMercenary.target = nil;
			entityMercenary:StopMove(true);
			entityMercenary:SetPos({x = bean.pos.x, y = bean.pos.y, z = bean.pos.z},true);
		end
	end

	return true;
end


----------------------------------------------------------------------------------
-- 周围玩家移动
--Packet:nearby_move_role
function i3k_sbean.nearby_move_role.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.id);
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			if i3k_vec3_dist(entity._curPos, bean.pos) > 300 then
				entity:SyncPos(bean.pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end

	return true;
end

----------------------------------------------------------------------------------
-- 周围佣兵移动
--Packet:nearby_move_pet
function i3k_sbean.nearby_move_pet.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			if i3k_vec3_dist(entity._curPos, bean.pos) > 300 then
				entity:SyncPos(bean.pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end

	return true;
end

--------------------------------------------------------------------------------
--周围镖车移动
--Packet:nearby_move_escortcar
function i3k_sbean.nearby_move_escortcar.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Car, bean.id);
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			if i3k_vec3_dist(entity._curPos, bean.pos) > 300 then
				entity:SyncPos(bean.pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end

	return true;
end

---------------------------------------------------------------------------------
--周围婚车移动
--Packet:nearby_move_weddingcar
function i3k_sbean.nearby_move_weddingcar.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world._entities[eGroupType_O]["i3k_marry_cruise|"..bean.id];
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			if i3k_vec3_dist(entity._curPos, bean.pos) > 300 then
				entity:SyncPos(bean.pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end

	return true;
end


----------------------------------------------------------------------------------
-- 周围怪物移动
--Packet:nearby_move_monster
function i3k_sbean.nearby_move_monster.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.id);
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(bean.pos))));
			if i3k_vec3_dist(entity._curPos, _pos) > 300 then
				entity:SyncPos(_pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end

	return true;
end

----------------------------------------------------------------------------------
-- 周围残影移动
--Packet:nearby_move_blur
function i3k_sbean.nearby_move_blur.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Pet, bean.id);
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(bean.pos))));
			if i3k_vec3_dist(entity._curPos, _pos) > 300 then
				entity:SyncPos(_pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end
	return true;
end

----------------------------------------------------------------------------------
-- 周围符灵卫移动
--Packet:nearby_move_summoned
function i3k_sbean.nearby_move_summoned.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Summoned, bean.id);
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(bean.pos))));
			if i3k_vec3_dist(entity._curPos, _pos) > 300 then
				entity:SyncPos(_pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end
	return true;
end

----------------------------------------------------------------------------------
-- 周围法阵移动
--Packet:nearby_move_skillentity
function i3k_sbean.nearby_move_skillentity.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Skill, bean.id);
		if entity then
			entity:UpdateProperty(ePropID_speed, 1, bean.speed, true, false, true);
			local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(bean.pos))));
			if i3k_vec3_dist(entity._curPos, _pos) > 300 then
				entity:SyncPos(_pos);
			end
			entity:SyncVelocity(bean.rotation, bean.timeTick);
		end
	end
	return true;
end


----------------------------------------------------------------------------------
-- 周围玩家停止移动
--Packet:nearby_stopmove_role
function i3k_sbean.nearby_stopmove_role.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.id);
		if entity then
			entity:SyncPos(bean.pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end

----------------------------------------------------------------------------------
-- 周围佣兵停止移动
--Packet:nearby_stopmove_pet
function i3k_sbean.nearby_stopmove_pet.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if entity then
			entity:SyncPos(bean.pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end

----------------------------------------------------------------------------------
-- 周围怪物停止移动
--Packet:nearby_stopmove_monster
function i3k_sbean.nearby_stopmove_monster.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.id);
		if entity then
			local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(bean.pos))));
			entity:SyncPos(_pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end

---------------------------------------------------------------------------------
--周围镖车镖车停止移动
--Packet:nearby_stopmove_escortcar
function i3k_sbean.nearby_stopmove_escortcar.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Car, bean.id);
		if entity then
			entity:SyncPos(bean.pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end

---------------------------------------------------------------------------------
--周围婚车停止移动
--Packet:nearby_stopmove_weddingcar
function i3k_sbean.nearby_stopmove_weddingcar.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world._entities[eGroupType_O]["i3k_marry_cruise|"..bean.id];
		if entity then
			entity:SyncPos(bean.pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end

----------------------------------------------------------------------------------
-- 周围残影停止移动
--Packet:nearby_stopmove_blur
function i3k_sbean.nearby_stopmove_blur.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Pet, bean.id);
		if entity then
			local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(bean.pos))));
			entity:SyncPos(_pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end


----------------------------------------------------------------------------------
-- 周围符灵卫停止移动
--Packet:nearby_stopmove_summoned
function i3k_sbean.nearby_stopmove_summoned.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Summoned, bean.id);
		if entity then
			local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(bean.pos))));
			entity:SyncPos(_pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end

----------------------------------------------------------------------------------
-- 周围法阵停止移动
--Packet:nearby_stopmove_skillentity
function i3k_sbean.nearby_stopmove_skillentity.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Skill, bean.id);
		if entity then
			entity:SyncPos(bean.pos);
			entity:SyncStopMove(bean.timeTick);
		end
	end

	return true;
end

---------------------------------------------------------------------------------
-- 周围玩家使用技能
--Packet:nearby_role_useskill
function i3k_sbean.nearby_role_useskill.handler(bean, res)
	local User = nil;
	local Target = nil
	--i3k_log("nearby_role_useskill sid = " .. bean.skillID .. " timeTick = (" .. bean.timeTick.tickLine .. ", " .. bean.timeTick.outTick);
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Player, bean.id);
		if bean.targetType == eET_Mercenary then
			Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.ownerID);
		else
			Target = world:GetEntity(bean.targetType, bean.targetID);
		end
	end

	if User then
		local Pos = {x = bean.pos.x,y = bean.pos.y, z = bean.pos.z}
		User:SetPos(Pos,true);
		User:ClearMoveState()
		local _skill = nil;
		if Target then
			User._target = Target
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:SetFaceDir(Dir.x, Dir.y, Dir.z);
			User:SetTarget(Target)
		end
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:UseSkill(_skill)
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:UseSkill(_skill)
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:UseSkill(_skill)
					end
				end
			end
		end
	end

	return true;
end
---------------------------------------------------------------------------------
-- 周围玩家使用DIY技能
--Packet:nearby_role_usediyskill
function i3k_sbean.nearby_role_usediyskill.handler(bean, res)
	local User = nil;
	local Target = nil
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Player, bean.id);
		if bean.targetType == eET_Mercenary then
			Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.ownerID);
		else
			Target = world:GetEntity(bean.targetType, bean.targetID);
		end
	end

	if User then
		local Pos = {x = bean.pos.x,y = bean.pos.y, z = bean.pos.z}
		User:SetPos(Pos,true);
		User:ClearMoveState()
		local _skill = nil;
		if Target then
			User._target = Target
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:SetFaceDir(Dir.x, Dir.y, Dir.z);
			User:SetTarget(Target)
		end
		local reloadDIY = true
		if User._DIYSkillID and User._DIYSkillID == bean.actionID then
			reloadDIY = false
		end
		User._DIYSkillID = bean.actionID
		local scfg = i3k_db_skills[bean.skillID];
		if User._skills then
			if User._skills[bean.skillID] and not reloadDIY then
				_skill = User._skills[bean.skillID];
				User:UseSkill(_skill)
			else
				User._skills[bean.skillID] = nil

				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							User._skills[bean.skillID] = _skill;
							User:UseSkill(_skill)
						end
					end
				end
			end
		else
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						User._skills[bean.skillID] = _skill;
						User:UseSkill(_skill)
					end
				end
			end
		end
	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围佣兵使用技能
--Packet:nearby_pet_useskill
function i3k_sbean.nearby_pet_useskill.handler(bean, res)
	local User = nil;
	local Target = nil
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if bean.targetType == eET_Mercenary then
			Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.ownerID);
		else
			Target = world:GetEntity(bean.targetType, bean.targetID);
		end
	end

	if User then
		local Pos = {x = bean.pos.x,y = bean.pos.y, z = bean.pos.z}
		User:SetPos(Pos,true);
		User:ClearMoveState();
		local _skill = nil;
		if Target then
			User._target = Target
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:SetFaceDir(Dir.x, Dir.y, Dir.z);
			User:SetTarget(Target)
		end
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:UseSkill(_skill)
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:UseSkill(_skill)
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:UseSkill(_skill)
					end
				end
			end
		end

	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围怪物使用技能
--Packet:nearby_monster_useskill
function i3k_sbean.nearby_monster_useskill.handler(bean, res)
	local User = nil;
	local Target = nil
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Monster, bean.id);
		if bean.targetType == eET_Mercenary then
			Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.ownerID);
		else
			Target = world:GetEntity(bean.targetType, bean.targetID);
		end
	end
	if User then
		local Pos = {x = bean.pos.x,y = bean.pos.y, z = bean.pos.z}
		local hero = i3k_game_get_player_hero();
		if hero and Pos then
			if hero._curPos.y > Pos.y then
				Pos.y = hero._curPos.y;
			end
		end
		User:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(Pos)))), true);
		User:ClearMoveState();
		local _skill = nil;
		if Target then
			User._target = Target
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:SetFaceDir(Dir.x, Dir.y, Dir.z);
			User:SetTarget(Target)
		end
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:UseSkill(_skill)
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:UseSkill(_skill)
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:UseSkill(_skill)
					end
				end
			end
		end

	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围残影使用技能
--Packet:nearby_blur_useskill
function i3k_sbean.nearby_blur_useskill.handler(bean, res)
	local User = nil;
	local Target = nil
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Pet, bean.bid);
		if bean.targetType == eET_Mercenary then
			Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.ownerID);
		else
			Target = world:GetEntity(bean.targetType, bean.targetID);
		end
	end

	if User then
		local Pos = {x = bean.pos.x,y = bean.pos.y, z = bean.pos.z}
		User:SetPos(Pos,true);
		User:ClearMoveState();
		local _skill = nil;
		if Target then
			User._target = Target
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:SetFaceDir(Dir.x, Dir.y, Dir.z);
			User:SetTarget(Target)
		end
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:UseSkill(_skill)
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:UseSkill(_skill)
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:UseSkill(_skill)
					end
				end
			end
		end

	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围符灵卫使用技能
--Packet:nearby_summoned_useskill
function i3k_sbean.nearby_summoned_useskill.handler(bean, res)
	local User = nil;
	local Target = nil
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Summoned, bean.bid);
		if bean.targetType == eET_Mercenary then
			Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.ownerID);
		else
			Target = world:GetEntity(bean.targetType, bean.targetID);
		end
	end

	if User then
		local Pos = {x = bean.pos.x,y = bean.pos.y, z = bean.pos.z}
		User:SetPos(Pos,true);
		User:ClearMoveState();
		local _skill = nil;
		if Target then
			User._target = Target
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:SetFaceDir(Dir.x, Dir.y, Dir.z);
			User:SetTarget(Target)
		end
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:UseSkill(_skill)
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:UseSkill(_skill)
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:UseSkill(_skill)
					end
				end
			end
		end

	end
	return true;
end

---------------------------------------------------------------------------------
-- 附近玩家技能伤害结束(清除disattack)
--Packet:nearby_role_endskill
function i3k_sbean.nearby_role_endskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Player, bean.rid);
		if User then
			--i3k_log("nearby_role_endskill sid = " .. bean.skillID .. " timeTick = (" .. bean.timeTick.tickLine .. ", " .. bean.timeTick.outTick);
			User:ClsAttacker(bean.skillID);
		end
	end
end

-- 附近玩家技能伤害结束(清除attack)
--Packet:nearby_role_finishattack
function i3k_sbean.nearby_role_finishattack.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Player, bean.rid);
		if User then
		--i3k_log("nearby_role_finishattack sid = " .. bean.skillID .. " timeTick = (" .. bean.timeTick.tickLine .. ", " .. bean.timeTick.outTick);
			if not User._canAttack then
				User:FinishAttack();
			end
		end
	end
end

--附近佣兵技能伤害结束(清除disattack)
--Packet:nearby_pet_endskill
function i3k_sbean.nearby_pet_endskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Mercenary, bean.pid.."|"..bean.ownerID);
		if User then
			User:ClsAttacker(bean.skillID);
		end
	end
end

--附近佣兵技能伤害结束(清除disattack)
--Packet:nearby_pet_finishattack
function i3k_sbean.nearby_pet_finishattack.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Mercenary, bean.pid.."|"..bean.ownerID);
		if User then
			if not User._canAttack then
				User:FinishAttack();
			end
		end
	end
end

--附近怪物技能伤害结束(清除disattack)
--Packet:nearby_monster_endskill
function i3k_sbean.nearby_monster_endskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Monster, bean.mid);
		if User then
			--i3k_log("nearby_monster_endskill = "..skillID);
			User:ClsAttacker(bean.skillID);
		end
	end
end

--附近怪物技能伤害结束(清除disattack)
--Packet:nearby_monster_finishattack
function i3k_sbean.nearby_monster_finishattack.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Monster, bean.mid);
		if User then
			if not User._canAttack then
			--i3k_log("nearby_monster_finishattack = "..bean.skillID);
				User:FinishAttack();
			end
		end
	end
end

--附近残影技能伤害结束(清除disattack)
--Packet:nearby_blur_endskill
function i3k_sbean.nearby_blur_endskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Pet, bean.bid);
		if User then
			User:ClsAttacker(bean.skillID);
		end
	end
end

--附近残影技能结束
--Packet:nearby_blur_finishattack
function i3k_sbean.nearby_blur_finishattack.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Pet, bean.bid);
		if User then
			if not User._canAttack then
				User:FinishAttack();
			end
		end
	end
end

-- 附近法阵能伤害结束（清除disattack状态）
--Packet:nearby_skillentity_endskill
function i3k_sbean.nearby_skillentity_endskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entitySkill = world:GetEntity(eET_Skill, bean.sid);
		if entitySkill then
			if not entitySkill._canAttack then
				entitySkill:ClsAttacker(bean.skillID);
				entitySkill:FinishAttack();
			end
		end
	end
end

-- 附近符灵卫技能伤害结束（清除disattack状态）
--Packet:nearby_summoned_endskill
function i3k_sbean.nearby_summoned_endskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Summoned, bean.bid);
		if User then
			User:ClsAttacker(bean.skillID);
		end
	end
end

-- 附近符灵卫技能结束（清除attack状态）
--Packet:nearby_blur_finishattack
function i3k_sbean.nearby_summoned_finishattack.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Summoned, bean.bid);
		if User then
			if not User._canAttack then
				User:FinishAttack();
			end
		end
	end
end

--------------------------------------------------------------------------------
-- 周围玩家使用子技能
--Packet:nearby_role_usechildskill
function i3k_sbean.nearby_role_usechildskill.handler(bean, res)
	--i3k_log("nearby_role_usechildskill sid = " .. SkillID .. " mainSkill = " .. mainSkill );
	local world = i3k_game_get_world()
	if world then
		local User = world:GetEntity(eET_Player, bean.rid);
		if User and bean.mainSkill and bean.skillID then
			User:ChildAttack(bean.mainSkill, bean.skillID);
		end
	end
end

-- 周围佣兵使用子技能
--Packet:nearby_pet_usechildskill
function i3k_sbean.nearby_pet_usechildskill.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local User = world:GetEntity(eET_Mercenary, bean.pid.."|"..bean.rid);
		if User then
			User:ChildAttack(bean.mainSkill, bean.skillID);
		end
	end
end

-- 周围怪物使用子技能
--Packet:nearby_monster_usechildskill
function i3k_sbean.nearby_monster_usechildskill.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local User = world:GetEntity(eET_Monster, bean.mid);
		if User then
			User:ChildAttack(bean.mainSkill, bean.skillID);
		end
	end
end

-- 周围残影使用子技能
--Packet:nearby_blur_usechildskill
function i3k_sbean.nearby_blur_usechildskill.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local User = world:GetEntity(eET_Pet, bean.bid);
		if User then
			User:ChildAttack(bean.mainSkill, bean.skillID);
		end
	end
end

-- 周围符灵卫使用子技能
--Packet:nearby_summoned_usechildskill
function i3k_sbean.nearby_summoned_usechildskill.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local User = world:GetEntity(eET_Summoned, bean.bid);
		if User then
			User:ChildAttack(bean.mainSkill, bean.skillID);
		end
	end
end

-- 周围法阵使用子技能
--Packet:nearby_skillentity_usechildskill
function i3k_sbean.nearby_skillentity_usechildskill.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local entitySkill = world:GetEntity(eET_Skill ,bean.sid);
		if entitySkill then
			entitySkill:ChildAttack(bean.mainSkill, bean.skillID);
		end
	end
end

-- 附近玩家技能被打断_useSkill
--Packet:nearby_role_breakskill
function i3k_sbean.nearby_role_breakskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Player, bean.rid);
		if User then
			if not User._canAttack then
				User._isAttacking = false;
				User:ClsAttackers();
				User:FinishAttack();
			end
		end
	end
end

-- 附近佣兵技能被打断
--Packet:nearby_pet_breakskill
function i3k_sbean.nearby_pet_breakskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Mercenary, bean.pid.."|"..bean.rid);
		if User then
			if not User._canAttack then
				User._isAttacking = false;
				User:ClsAttackers();
				User:FinishAttack();
			end
		end
	end
end

-- 附近怪物技能被打断
--Packet:nearby_monster_breakskill
function i3k_sbean.nearby_monster_breakskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Monster, bean.mid);
		if User then
			if not User._canAttack then
			--i3k_log("nearby_monster_breakskill = "..User._useSkill._id);
				User._isAttacking = false;
				User:ClsAttackers();
				User:FinishAttack();
			end
		end
	end
end

-- 附近残影技能被打断
--Packet:nearby_blur_breakskill
function i3k_sbean.nearby_blur_breakskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Pet, bean.bid);
		if User then
			if not User._canAttack then
				User._isAttacking = false;
				User:ClsAttackers();
				User:FinishAttack();
			end
		end
	end
end

-- 附近符灵卫技能被打断
--Packet:nearby_summoned_breakskill
function i3k_sbean.nearby_summoned_breakskill.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local User = world:GetEntity(eET_Summoned, bean.bid);
		if User then
			if not User._canAttack then
				User._isAttacking = false;
				User:ClsAttackers();
				User:FinishAttack();
			end
		end
	end
end

---------------------------------------------------------------------------------
-- 周围玩家使用触发技能
--Packet:nearby_role_usetrigskill
function i3k_sbean.nearby_role_usetrigskill.handler(bean, res)
	local User = nil;
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Player, bean.id);
	end

	if User then
		local _skill = nil;
		if User._skills then

			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:StartAttack(_skill);
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:StartAttack(_skill);
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:StartAttack(_skill);
					end
				end
			end
		end
	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围佣兵使用触发技能
--Packet:nearby_pet_usetrigskill
function i3k_sbean.nearby_pet_usetrigskill.handler(bean, res)
	local User = nil;
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
	end

	if User then
		local _skill = nil;
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:StartAttack(_skill);
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:StartAttack(_skill);
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:StartAttack(_skill);
					end
				end
			end
		end

	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围怪物使用触发技能
--Packet:nearby_monster_usetrigskill
function i3k_sbean.nearby_monster_usetrigskill.handler(bean, res)
	local User = nil;
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Monster, bean.id);
	end

	if User then
		local _skill = nil;
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:StartAttack(_skill);
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:StartAttack(_skill);
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:StartAttack(_skill);
					end
				end
			end
		end

	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围残影使用触发技能
--Packet:nearby_blur_usetrigskill
function i3k_sbean.nearby_blur_usetrigskill.handler(bean, res)
	local User = nil;
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Pet, bean.bid);
	end

	if User then
		local _skill = nil;
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:StartAttack(_skill);
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:StartAttack(_skill);
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:StartAttack(_skill);
					end
				end
			end
		end

	end
	return true;
end

---------------------------------------------------------------------------------
-- 周围符灵卫使用触发技能技能
--Packet:nearby_summoned_usetrigskill
function i3k_sbean.nearby_summoned_usetrigskill.handler(bean, res)
	local User = nil;
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Summoned, bean.bid);
	end

	if User then
		local _skill = nil;
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:StartAttack(_skill);
			else
				local scfg = i3k_db_skills[bean.skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
						if _skill then
							table.insert(User._skills,bean.skillID,_skill);
							User:StartAttack(_skill);
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[bean.skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_TriSkill);
					if _skill then
						User._skills = {}
						table.insert(User._skills,bean.skillID,_skill);
						User:StartAttack(_skill);
					end
				end
			end
		end

	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家开始冲锋
--Packet:nearby_role_rushstart
function i3k_sbean.nearby_role_rushstart.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			local s = i3k_db_skills[bean.skillID].specialArgs;
			if s.rushInfo then
				if entityPlayer.OnRush then
					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos,entityPlayer._curPos ));
					local dist = i3k_vec3_dist(bean.endPos,entityPlayer._curPos)

					local rushInfo = { };
						rushInfo.type		= s.rushInfo.type;
						rushInfo.distance	= dist;
						rushInfo.height		= s.rushInfo.height;
						rushInfo.velocity	= s.rushInfo.velocity;
						rushInfo.endPos		= bean.endPos
					if entityPlayer._useSkill and entityPlayer._useSkill._id ~= bean.skillID then
						rushInfo.reinit		= true;
					end
					entityPlayer:OnRush(bean.skillID, dir, rushInfo);
				end
			end
		end
	end

	return true;
end
------------------------------------------------------------------------------------
-- 周围佣兵开始冲锋
--Packet:nearby_pet_rushstart
function i3k_sbean.nearby_pet_rushstart.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if Entity then
			local s = i3k_db_skills[bean.skillID].specialArgs;
			if s.rushInfo then
				if Entity.OnRush then
					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos,Entity._curPos ));
					local dist = i3k_vec3_dist(bean.endPos,Entity._curPos)

					local rushInfo = { };
						rushInfo.type		= s.rushInfo.type;
						rushInfo.distance	= dist;
						rushInfo.height		= s.rushInfo.height;
						rushInfo.velocity	= s.rushInfo.velocity;
						rushInfo.endPos		= bean.endPos
						Entity:OnRush(bean.skillID, dir, rushInfo);
				end
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物开始冲锋
--Packet:nearby_monster_rushstart
function i3k_sbean.nearby_monster_rushstart.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityMonster = world:GetEntity(eET_Monster, bean.id);
		if entityMonster then
			local s = i3k_db_skills[bean.skillID].specialArgs;
			if s.rushInfo then
				if entityMonster.OnRush then
					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos,entityMonster._curPos ));
					local dist = i3k_vec3_dist(bean.endPos,entityMonster._curPos)

					local rushInfo = { };
						rushInfo.type		= s.rushInfo.type;
						rushInfo.distance	= dist;
						rushInfo.height		= s.rushInfo.height;
						rushInfo.velocity	= s.rushInfo.velocity;
						rushInfo.endPos		= bean.endPos
						entityMonster:OnRush(bean.skillID, dir, rushInfo);
				end
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围残影开始冲锋
--Packet:nearby_blur_rushstart
function i3k_sbean.nearby_blur_rushstart.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Pet, bean.id);
		if Entity then
			local s = i3k_db_skills[bean.skillID].specialArgs;

			if s.rushInfo then
				if Entity.OnRush then
					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos,Entity._curPos ));
					local dist = i3k_vec3_dist(bean.endPos,Entity._curPos)
					local rushInfo = { };
					rushInfo.type		= s.rushInfo.type;
					rushInfo.distance	= dist;
					rushInfo.height		= s.rushInfo.height;
					rushInfo.velocity	= s.rushInfo.velocity;
					rushInfo.endPos		= bean.endPos
					Entity:OnRush(bean.skillID, dir, rushInfo);
				end
			end
		end
	end

	return true;
end


------------------------------------------------------------------------------------
-- 周围符灵卫开始冲锋
function i3k_sbean.nearby_summoned_rushstart.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Summoned, bean.id);
		if Entity then
			local s = i3k_db_skills[bean.skillID].specialArgs;

			if s.rushInfo then
				if Entity.OnRush then
					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos,Entity._curPos ));
					local dist = i3k_vec3_dist(bean.endPos,Entity._curPos)
					local rushInfo = { };
					rushInfo.type		= s.rushInfo.type;
					rushInfo.distance	= dist;
					rushInfo.height		= s.rushInfo.height;
					rushInfo.velocity	= s.rushInfo.velocity;
					rushInfo.endPos		= bean.endPos
					Entity:OnRush(bean.skillID, dir, rushInfo);
				end
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步玩家击退结束位置
function i3k_sbean.nearby_shiftend_role.handler(bean, res)
	local world = i3k_game_get_world();
	local entity = world:GetEntity(eET_Player, bean.rid);
	if entity then
		local s = i3k_db_skills[bean.skillID].specialArgs;
		if s.shiftInfo then
			local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos, entity._curPos));

			local shiftInfo = { };
				shiftInfo.type		= s.shiftInfo.type;
				shiftInfo.height	= s.shiftInfo.height;
				shiftInfo.velocity	= s.shiftInfo.velocity;
				shiftInfo.endPos	= bean.endPos;
				--i3k_log("shift end pos = " .. i3k_format_pos(bean.endPos));
			entity:SyncShift(dir, shiftInfo);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步佣兵击退结束位置
--Packet:nearby_shiftend_pet
function i3k_sbean.nearby_shiftend_pet.handler(bean, res)
	local world = i3k_game_get_world();
	local entity = world:GetEntity(eET_Mercenary, bean.pid.."|"..bean.rid);
	if entity then
		local s = i3k_db_skills[bean.skillID].specialArgs;
		if s.shiftInfo then
			local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos, entity._curPos));

			local shiftInfo = { };
				shiftInfo.type		= s.shiftInfo.type;
				shiftInfo.height	= s.shiftInfo.height;
				shiftInfo.velocity	= s.shiftInfo.velocity;
				shiftInfo.endPos	= bean.endPos;
			entity:SyncShift(dir, shiftInfo);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步怪物击退结束位置
--Packet:nearby_shiftend_monster
function i3k_sbean.nearby_shiftend_monster.handler(bean, res)
	local world = i3k_game_get_world();
	local entity = world:GetEntity(eET_Monster, bean.mid);
	if entity then
		local s = i3k_db_skills[bean.skillID].specialArgs;
		if s.shiftInfo then
			local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos, entity._curPos));

			local shiftInfo = { };
				shiftInfo.type		= s.shiftInfo.type;
				shiftInfo.height	= s.shiftInfo.height;
				shiftInfo.velocity	= s.shiftInfo.velocity;
				shiftInfo.endPos	= bean.endPos;
			entity:SyncShift(dir, shiftInfo);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步残影击退结束位置
--Packet:nearby_shiftend_blur
function i3k_sbean.nearby_shiftend_blur.handler(bean, res)
	local world = i3k_game_get_world();
	local entity = world:GetEntity(eET_Pet, bean.bid);
	if entity then
		local s = i3k_db_skills[bean.skillID].specialArgs;
		if s.shiftInfo then
			local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos, entity._curPos ));

			local shiftInfo = { };
				shiftInfo.type		= s.shiftInfo.type;
				shiftInfo.height	= s.shiftInfo.height;
				shiftInfo.velocity	= s.shiftInfo.velocity;
				shiftInfo.endPos	= bean.endPos;
			entity:SyncShift(dir, shiftInfo);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步符灵卫击退结束位置
function i3k_sbean.nearby_shiftend_summoned.handler(bean, res)
	local world = i3k_game_get_world();
	local entity = world:GetEntity(eET_Summoned, bean.bid);
	if entity then
		local s = i3k_db_skills[bean.skillID].specialArgs;
		if s.shiftInfo then
			local dir = i3k_vec3_normalize1(i3k_vec3_sub1(bean.endPos, entity._curPos ));

			local shiftInfo = { };
				shiftInfo.type		= s.shiftInfo.type;
				shiftInfo.height	= s.shiftInfo.height;
				shiftInfo.velocity	= s.shiftInfo.velocity;
				shiftInfo.endPos	= bean.endPos;
			entity:SyncShift(dir, shiftInfo);
		end
	end

	return true;
end

-------------------------------------------------------------------------
-- 周围玩家闪烁突刺
--Packet:nearby_role_blinkskill
function i3k_sbean.nearby_role_blinkskill.handler(bean, res)
	local User = nil;
	local Target = nil
	local world = i3k_game_get_world();
	if world then
		User = world:GetEntity(eET_Player, bean.id);
		if bean.targetType == eET_Mercenary then
			Target = world:GetEntity(bean.targetType, bean.targetID.."|"..bean.ownerID);
		else
			Target = world:GetEntity(bean.targetType, bean.targetID);
		end
	end

	if User then
		local Pos = {x = bean.endPos.x,y = bean.endPos.y, z = bean.endPos.z}
		User:SetPos(Pos,true);
		User:ClearMoveState()
		local _skill = nil;
		if Target then
			User._target = Target
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x,bean.rotation.y,bean.rotation.z), i3k_vec3(1, 0, 0));
			local Dir = {x = 0 ,y = r ,z = 0 }
			User:SetFaceDir(Dir.x, Dir.y, Dir.z);
			User:SetTarget(Target)
		end

		local scfg = i3k_db_skills[bean.skillID];
		if User._skills then
			if User._skills[bean.skillID] then
				_skill = User._skills[bean.skillID];
				User:UseSkill(_skill)
			else
				User._skills[bean.skillID] = nil
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							User._skills[bean.skillID] = _skill;
							User:UseSkill(_skill)
						end
					end
				end
			end
		else
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						User._skills[bean.skillID] = _skill;
						User:UseSkill(_skill)
					end
				end
			end
		end
	end
	return true;
end

--------------------------------------------------------------------------------
-- 周围玩家受到伤害
--Packet:nearby_role_ondamage
function i3k_sbean.nearby_role_ondamage.handler(bean,res)
	--armor.damage--伤害 armor.suck--吸收 armor.destroy--损毁 armor.weak--虚弱
	if bean.crit == 1 then
		bean.crit = true
	else
		bean.crit = false
	end

	if bean.batter == 1 then
		bean.batter = true
	else
		bean.batter = false
	end
	bean.godStarDefend = bean.godStarDefend == 1
	bean.godStarSplite = bean.godStarSplite == 1
	local Target = nil;
	local Attacker = nil
	local world = i3k_game_get_world();
	local hero = i3k_game_get_player_hero();
	--i3k_log("nearby_role_ondamage sid = " .. bean.skillID .. " timeTick = " .. bean.id .. ", ");
	if world then
		Target = world:GetEntity(eET_Player, bean.id);

		if bean.attackerType == eET_Mercenary then
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID.."|"..bean.ownerID);
		else
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID);
		end

		if Attacker then
			local scfg = i3k_db_skills[bean.skillID];
			if scfg.type == 1 then
				local enmity = false
				if bean.attackerType == eET_Player or bean.attackerType == eET_Mercenary then
					for k,v in pairs(hero._alives[2]) do
						if v.entity._guid == Attacker._guid then
							enmity = true
						end
					end
				else
					enmity = true
				end
				if not world._fightmap then
					if enmity then
						local player = i3k_game_get_player()
						local MercenaryCount =  player:GetMercenaryCount()
						for i = 1,MercenaryCount do
							local mercenary = player:GetMercenary(i);
							if mercenary and not mercenary:IsDead() then
								mercenary:AddEnmity(Attacker)
							end
						end
					end
				end
			end
		end
	end

	if Target then
		if Attacker then
			Attacker:SetCacheTargets(bean.skillID, bean.curEventTime, Target, bean.curHP, bean.deflect, bean.dodge, bean.crit, bean.suckBlood, bean.attackerType, bean.remit, bean.armor, bean.batter, bean.godStarSplite, bean.godStarDefend)
		elseif bean.curHP == 0 then
			Target:OnDead();
		end
	end
	return true;
end

--------------------------------------------------------------------------------
-- 周围佣兵受到伤害
--Packet:nearby_pet_ondamage
function i3k_sbean.nearby_pet_ondamage.handler(bean,res)
	if bean.crit == 1 then
		bean.crit = true
	else
		bean.crit = false
	end
	if bean.batter == 1 then
		bean.batter = true
	else
		bean.batter = false
	end
	bean.godStarDefend = bean.godStarDefend == 1
	bean.godStarSplite = bean.godStarSplite == 1
	local Target = nil;
	local Attacker = nil
	local world = i3k_game_get_world();
	if world then
		Target = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);

		if bean.attackerType == eET_Mercenary then
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID.."|"..bean.ownerID);
		else
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID);
		end

		if Attacker then
			local scfg = i3k_db_skills[bean.skillID];
			if scfg.type == 1 then
				if Target then
					local hero = i3k_game_get_player_hero()
					local guid = string.split(hero, "|")
					if tonumber(guid[2]) == bean.roleID then
						local enmity = false
						if bean.attackerType == eET_Player or bean.attackerType == eET_Mercenary then
							for k,v in pairs(hero._alives[2]) do
								if v.entity._guid == Attacker._guid then
									enmity = true
								end
							end
						else
							enmity = true
						end
						if enmity then
							Target:AddEnmity(Attacker)
						end
					end
				end
			end
		end
	end


	if Target then
		if Attacker then
			Attacker:SetCacheTargets(bean.skillID, bean.curEventTime, Target, bean.curHP, bean.deflect, bean.dodge, bean.crit, bean.suckBlood, bean.attackerType, bean.remit, nil, bean.batter, bean.godStarSplite, bean.godStarDefend)
		elseif bean.curHP == 0 then
			Target:OnDead();
		end
	end
	return true;
end

--------------------------------------------------------------------------------
-- 周围怪物受到伤害
--Packet:nearby_monster_ondamage
function i3k_sbean.nearby_monster_ondamage.handler(bean,res)
	if bean.crit == 1 then
		bean.crit = true
	else
		bean.crit = false
	end
	if bean.batter == 1 then
		bean.batter = true
	else
		bean.batter = false
	end
	bean.godStarDefend = bean.godStarDefend == 1
	bean.godStarSplite = bean.godStarSplite == 1
	--i3k_log("nearby_monster_ondamage:targetID".."|"..targetID)
	local Target = nil;
	local Attacker = nil
	local attackerID = bean.attackerID
	local world = i3k_game_get_world();
	if world then
		Target = world:GetEntity(eET_Monster, bean.id);

		if bean.attackerType == eET_Mercenary then
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID.."|"..bean.ownerID);
			attackerID = bean.ownerID
		else
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID);
		end

		if Attacker then
			local scfg = i3k_db_skills[bean.skillID];
			if scfg.type == 1 then
				local hero = i3k_game_get_player_hero()
				if hero then
					local guid = string.split(hero._guid, "|")

					if tonumber(guid[2]) == attackerID then
						local player = i3k_game_get_player()
						local MercenaryCount =  player:GetMercenaryCount()
						for i = 1,MercenaryCount do
							local mercenary = player:GetMercenary(i);
							if mercenary and not mercenary:IsDead() then
								mercenary:ClsEnmities()
								mercenary:AddEnmity(Target)
							end
						end
					end
				end
			end
		end
	end

	if Target then
		if Attacker then
			Target:AddEnmity(Attacker);
			Attacker:SetCacheTargets(bean.skillID, bean.curEventTime, Target, bean.curHP, bean.deflect, bean.dodge, bean.crit, bean.suckBlood, bean.attackerType, bean.remit, bean.armor, bean.batter, bean.godStarSplite, bean.godStarDefend)
		elseif bean.curHP == 0 then
			Target:OnDead();
		end

	end
	return true;
end

--------------------------------------------------------------------------------
-- 周围残影受到伤害
--Packet:nearby_blur_ondamage
function i3k_sbean.nearby_blur_ondamage.handler(bean,res)
	if bean.crit == 1 then
		bean.crit = true
	else
		bean.crit = false
	end
	if bean.batter == 1 then
		bean.batter = true
	else
		bean.batter = false
	end
	bean.godStarDefend = bean.godStarDefend == 1
	bean.godStarSplite = bean.godStarSplite == 1
	local Target = nil;
	local Attacker = nil
	local world = i3k_game_get_world();
	if world then
		Target = world:GetEntity(eET_Pet, bean.id);
		if bean.attackerType == eET_Mercenary then
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID.."|"..bean.ownerID);
		else
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID);
		end

		if Attacker then
			local scfg = i3k_db_skills[bean.skillID];
			if scfg.type == 1 then
				if Target then
					local hero = i3k_game_get_player_hero()
					local guid = string.split(hero._guid, "|")
					if tonumber(guid[2]) == bean.id then
						local enmity = false
						if bean.attackerType == eET_Player or bean.attackerType == eET_Mercenary then
							for k,v in pairs(hero._alives[2]) do
								if v.entity._guid == Attacker._guid then
									enmity = true
								end
							end
						else
							enmity = true
						end
						if enmity then
							Target:AddEnmity(Attacker)
						end
					end
				end
			end
		end
	end

	if Target and Attacker then
		if Attacker then
			Attacker:SetCacheTargets(bean.skillID, bean.curEventTime, Target, bean.curHP, bean.deflect, bean.dodge, bean.crit, bean.suckBlood, bean.attackerType, bean.remit, nil, bean.batter, bean.godStarSplite, bean.godStarDefend)
		elseif bean.curHP == 0 then
			Target:OnDead();
		end
	end
	return true;
end

--------------------------------------------------------------------------------
-- 周围符灵卫受到伤害
--Packet:nearby_summoned_ondamage
function i3k_sbean.nearby_summoned_ondamage.handler(bean,res)
	if bean.crit == 1 then
		bean.crit = true
	else
		bean.crit = false
	end
	if bean.batter == 1 then
		bean.batter = true
	else
		bean.batter = false
	end
	bean.godStarDefend = bean.godStarDefend == 1
	bean.godStarSplite = bean.godStarSplite == 1
	local Target = nil;
	local Attacker = nil
	local world = i3k_game_get_world();
	if world then
		Target = world:GetEntity(eET_Summoned, bean.id);
		if bean.attackerType == eET_Mercenary then
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID.."|"..bean.ownerID);
		else
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID);
		end

		if Attacker then
			local scfg = i3k_db_skills[bean.skillID];
			if scfg.type == 1 then
				if Target then
					local hero = i3k_game_get_player_hero()
					local guid = string.split(hero._guid, "|")
					if tonumber(guid[2]) == bean.id then
						local enmity = false
						if bean.attackerType == eET_Player or bean.attackerType == eET_Mercenary then
							for k,v in pairs(hero._alives[2]) do
								if v.entity._guid == Attacker._guid then
									enmity = true
								end
							end
						else
							enmity = true
						end
						if enmity then
							Target:AddEnmity(Attacker)
						end
					end
				end
			end
		end
	end

	if Target and Attacker then
		if Attacker then
			Attacker:SetCacheTargets(bean.skillID, bean.curEventTime, Target, bean.curHP, bean.deflect, bean.dodge, bean.crit, bean.suckBlood, bean.attackerType, bean.remit, nil, bean.batter, bean.godStarSplite, bean.godStarDefend)
		elseif bean.curHP == 0 then
			Target:OnDead();
		end
	end
	return true;
end

------------------------------------------------------------------------------------
--周围镖车受到伤害
--Packet:nearby_escortcar_ondamage
function i3k_sbean.nearby_escortcar_ondamage.handler(bean)
	if bean.crit == 1 then
		bean.crit = true
	else
		bean.crit = false
	end
	if bean.batter == 1 then
		bean.batter = true
	else
		bean.batter = false
	end
	bean.godStarDefend = bean.godStarDefend == 1
	bean.godStarSplite = bean.godStarSplite == 1
	local Target = nil;
	local Attacker = nil
	local world = i3k_game_get_world();
	if world then
		Target = world:GetEntity(eET_Car, bean.id);
		if bean.attackerType == eET_Mercenary then
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID.."|"..bean.ownerID);
		else
			Attacker = world:GetEntity(bean.attackerType, bean.attackerID);
		end
	end
	if Target and Attacker then
		if Attacker then
			Attacker:SetCacheTargets(bean.skillID, bean.curEventTime, Target, bean.curHP, bean.deflect, bean.dodge, bean.crit, bean.suckBlood, bean.attackerType, bean.remit, nil, bean.batter, bean.godStarSplite, bean.godStarDefend)
		elseif bean.curHP == 0 then
			Target:OnDead();
		end
		local guid = string.split(Target._guid, "|")
		if tonumber(guid[2]) == g_i3k_game_context:GetRoleId() then
			g_i3k_ui_mgr:PopupTipMessage("<c=hlred>您的镖车正在被攻击！！！</c>")
			--刷新血量ui
			g_i3k_game_context:setEscortCarblood(bean.curHP)
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家受到BUFF伤害
--Packet:nearby_role_buffdamage
function i3k_sbean.nearby_role_buffdamage.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			entityPlayer:ProcessBuffDamagefromNetwork(bean.attackerType, bean.curHP);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物受到BUFF伤害
--Packet:nearby_monster_buffdamage
function i3k_sbean.nearby_monster_buffdamage.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityMonster = world:GetEntity(eET_Monster, bean.id);
		if entityMonster then
			entityMonster:ProcessBuffDamagefromNetwork(bean.attackerType, bean.curHP);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵受到BUFF伤害
--Packet:nearby_pet_buffdamage
function i3k_sbean.nearby_pet_buffdamage.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityMercenary = world:GetEntity(eET_Mercenary, bean.cfgID.."|"..bean.roleID);
		if entityMercenary then
			entityMercenary:ProcessBuffDamagefromNetwork(bean.attackerType, bean.curHP);
		end
	end
	return true;
end

-----------------------------------------------------------------------------------
--周围镖车受到BUFF伤害
--packet:nearby_escortcar_buffdamage
function i3k_sbean.nearby_escortcar_buffdamage.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entityCar = world:GetEntity(eET_Car, bean.id);
		if entityCar then
			entityCar:ProcessBuffDamagefromNetwork(bean.attackerType, bean.curHP);
			if bean.id == g_i3k_game_context:GetRoleId() then
				g_i3k_game_context:setEscortCarblood(bean.curHP)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围残影受到BUFF伤害
--Packet:nearby_blur_buffdamage
function i3k_sbean.nearby_blur_buffdamage.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPet = world:GetEntity(eET_Pet, bean.id);
		if entityPet then
			entityPet:ProcessBuffDamagefromNetwork(bean.attackerType, bean.curHP);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围符灵卫受到BUFF伤害
--Packet:nearby_summoned_buffdamage
function i3k_sbean.nearby_summoned_buffdamage.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPet = world:GetEntity(eET_Summoned, bean.id);
		if entityPet then
			entityPet:ProcessBuffDamagefromNetwork(bean.attackerType, bean.curHP);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家吸收伤害
--Packet:nearby_role_reduce
function i3k_sbean.nearby_role_reduce.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Player, bean.id);
		if Entity then
			Entity:OnReduce(Entity, bean.value);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵吸收伤害
--Packet:nearby_pet_reduce
function i3k_sbean.nearby_pet_reduce.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if Entity then
			Entity:OnReduce(Entity, bean.value);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物吸收伤害
--Packet:nearby_monster_reduce
function i3k_sbean.nearby_monster_reduce.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Monster, bean.id);
		if Entity then
			Entity:OnReduce(Entity, bean.value);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家受到内伤伤害
--Packet:nearby_role_internalinjurydamage
function i3k_sbean.nearby_role_internalinjurydamage.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			entityPlayer:ProcessInternalInjuryDamagefromNetwork(bean.damageType, bean.curHP, bean.curInternalInjury);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家同步内伤值
--Packet:nearby_role_updateinternalinjury

function i3k_sbean.nearby_role_updateinternalinjury.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.id);
		if entity then
			entity:UpdateInternalInjury(bean.curInternalInjury);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家添加BUFF
--Packet:nearby_role_addbuff
function i3k_sbean.nearby_role_addbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			BUFF = require("logic/battle/i3k_buff_net");
			local bcfg = i3k_db_buff[bean.buffID];
			local _buff = entityPlayer._buffs[bean.buffID];
			local isHave = false;
			if _buff then
				isHave = true;
			end
			if not isHave then
				if bean.buffID >900000 and bean.buffID <999999 then
					bcfg.affectValue = bean.realmLvl
					bean.realmLvl = 0
				end

				local buff = BUFF.i3k_buff_net.new(nil,bean.buffID, bcfg, bean.realmLvl);
				if buff then
					entityPlayer:AddBuff(nil, buff);
				end
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物添加BUFF
--Packet:nearby_monster_addbuff
function i3k_sbean.nearby_monster_addbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityMonster = world:GetEntity(eET_Monster, bean.id);
		if entityMonster then
			BUFF = require("logic/battle/i3k_buff_net");
			local bcfg = i3k_db_buff[bean.buffID];
			local _buff = entityMonster._buffs[bean.buffID];
			local isHave = false;
			if _buff then
				isHave = true;
			end
			if not isHave then
				if bean.buffID >900000 and bean.buffID <999999 then
					bcfg.affectValue = bean.realmLvl
					bean.realmLvl = 0
				end

				local buff = BUFF.i3k_buff_net.new(nil,bean.buffID, bcfg, bean.realmLvl);
				if buff then
					entityMonster:AddBuff(nil, buff);
				end
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵添加BUFF
--Packet:nearby_pet_addbuff
function i3k_sbean.nearby_pet_addbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityMercenary = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if entityMercenary then
			BUFF = require("logic/battle/i3k_buff_net");
			local bcfg = i3k_db_buff[bean.buffID];
			local _buff = entityMercenary._buffs[bean.buffID];
			local isHave = false;
			if _buff then
				isHave = true;
			end
			if not isHave then
				if bean.buffID >900000 and bean.buffID <999999 then
					bcfg.affectValue = bean.realmLvl
					bean.realmLvl = 0
				end

				local buff = BUFF.i3k_buff_net.new(nil,bean.buffID, bcfg, bean.realmLvl);
				if buff then
					entityMercenary:AddBuff(nil, buff);
				end
			end
		end
	end
	return true;
end

-----------------------------------------------------------------------------------
--周围镖车添加BUFF
---package:nearby_escortcar_addbuff
function i3k_sbean.nearby_escortcar_addbuff.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entityCar = world:GetEntity(eET_Car, bean.id);
		if entityCar then
			BUFF = require("logic/battle/i3k_buff_net");
			local bcfg = i3k_db_buff[bean.buffID];
			local _buff = entityCar._buffs[bean.buffID];
			local isHave = false;
			if _buff then
				isHave = true;
			end
			if not isHave then
				local buff = BUFF.i3k_buff_net.new(nil,bean.buffID, bcfg, nil);
				if buff then
					entityCar:AddBuff(nil, buff);
				end
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围残影添加BUFF
--Packet:nearby_blur_addbuff
function i3k_sbean.nearby_blur_addbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPet = world:GetEntity(eET_Pet, bean.id);
		if entityPet then
			BUFF = require("logic/battle/i3k_buff_net");
			local bcfg = i3k_db_buff[bean.buffID];
			local _buff = entityPet._buffs[bean.buffID];
			local isHave = false;
			if _buff then
				isHave = true;
			end
			if not isHave then
				if bean.buffID >900000 and bean.buffID <999999 then
					bcfg.affectValue = bean.realmLvl
					bean.realmLvl = 0
				end

				local buff = BUFF.i3k_buff_net.new(nil,bean.buffID, bcfg, bean.realmLvl);
				if buff then
					entityPet:AddBuff(nil, buff);
				end
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围符灵卫添加BUFF(remainTime： 剩余毫秒)
--Packet:nearby_summoned_addbuff
function i3k_sbean.nearby_summoned_addbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPet = world:GetEntity(eET_Summoned, bean.id);
		if entityPet then
			BUFF = require("logic/battle/i3k_buff_net");
			local bcfg = i3k_db_buff[bean.buffID];
			local _buff = entityPet._buffs[bean.buffID];
			local isHave = false;
			if _buff then
				isHave = true;
			end
			if not isHave then
				if bean.buffID >900000 and bean.buffID <999999 then
					bcfg.affectValue = bean.realmLvl
					bean.realmLvl = 0
				end

				local buff = BUFF.i3k_buff_net.new(nil,bean.buffID, bcfg, bean.realmLvl);
				if buff then
					entityPet:AddBuff(nil, buff);
				end
			end
		end
	end
	return true;
end

-----------------------------------------------------------------------------------
-- 周围玩家去除BUFF
--Packet:nearby_role_removebuff
function i3k_sbean.nearby_role_removebuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			local buff = entityPlayer._buffs[bean.buffID]
			if buff then
				entityPlayer:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物去除BUFF
--Packet:nearby_monster_removebuff
function i3k_sbean.nearby_monster_removebuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityMonster = world:GetEntity(eET_Monster, bean.id);
		if entityMonster then
			local buff = entityMonster._buffs[bean.buffID]
			if buff then
				entityMonster:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵去除BUFF
--Packet:nearby_pet_removebuff
function i3k_sbean.nearby_pet_removebuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if Entity then
			local buff = Entity._buffs[bean.buffID]
			if buff then
				Entity:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围残影去除BUFF
--Packet:nearby_blur_removebuff
function i3k_sbean.nearby_blur_removebuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Pet, bean.id);
		if Entity then
			local buff = Entity._buffs[bean.buffID]
			if buff then
				Entity:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围符灵卫去除BUFF
--Packet:nearby_summoned_removebuff
function i3k_sbean.nearby_summoned_removebuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Summoned, bean.id);
		if Entity then
			local buff = Entity._buffs[bean.buffID]
			if buff then
				Entity:RmvBuff(buff);
			end
		end
	end
	return true;
end

-------------------------------------------------------------------------------------
--周围镖车去除BUFF
--Packet:nearby_escortcar_removebuff
function i3k_sbean.nearby_escortcar_removebuff.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Car, bean.id);
		if Entity then
			local buff = Entity._buffs[bean.buffID]
			if buff then
				Entity:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家驱散BUFF
--Packet:nearby_role_dispelbuff
function i3k_sbean.nearby_role_dispelbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			local buff = entityPlayer._buffs[bean.buffID]
			if buff then
				if buff._type == 1 then
					entityPlayer:ShowInfo(entityPlayer, eEffectID_DeBuff.style, i3k_get_string(425), i3k_db_common.engine.durNumberEffect[2] / 1000);
				elseif buff._type == 2 then
					entityPlayer:ShowInfo(entityPlayer, eEffectID_Buff.style, i3k_get_string(426), i3k_db_common.engine.durNumberEffect[2] / 1000);
				end
				entityPlayer:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物驱散BUFF
--Packet:nearby_monster_dispelbuff
function i3k_sbean.nearby_monster_dispelbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityMonster = world:GetEntity(eET_Monster, bean.id);
		if entityMonster then
			local buff = entityMonster._buffs[bean.buffID]
			if buff then
				entityMonster:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵驱散BUFF
--Packet:nearby_pet_dispelbuff
function i3k_sbean.nearby_pet_dispelbuff.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if Entity then
			local buff = Entity._buffs[bean.buffID]
			if buff then
				Entity:RmvBuff(buff);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家同步血量
--Packet:nearby_role_updatehp
function i3k_sbean.nearby_role_updatehp.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.id);
		if entity then
			entity:UpdateHP(bean.curHP);
			if entity:IsDead() and bean.curHP > 0 then --可能要判断大于0 等于0没有意义 修改这里是为了城战工程车死亡后复活血量为0的bug lht
				entity._reviveHP = bean.curHP;
			end
		end
	end

	return true;
end

-----------------------------------------------------------------------------------
-- 周围怪物同步血量
--Packet:nearby_monster_updatehp
function i3k_sbean.nearby_monster_updatehp.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.id);
		if entity then
			entity:UpdateHP(bean.curHP);
		end
	end

	return true;
end

--周围怪物同步头顶信息
function i3k_sbean.nearby_monster_updatetop.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.id);
		if entity then
			entity:UpdateHP(bean.curHP);
			if entity._armorState and entity._armorState.maxArmor and entity._armorState.maxArmor > 0 then
				entity:UpdateArmorValue(bean.curArmor);
			end
		end
	end
end

------------------------------------------------------------------------------------
-- 周围佣兵同步血量
--Packet:nearby_pet_updatehp
function i3k_sbean.nearby_pet_updatehp.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Mercenary, bean.cfgid .. "|" .. bean.roleID);
		if entity then
			entity:UpdateHP(bean.curHP);
		end
	end

	return true;
end

-----------------------------------------------------------------------------------
--周围镖车同步血量
--Packet:nearby_escortcar_updatehp
function i3k_sbean.nearby_escortcar_updatehp.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Car, bean.id);
		if entity then
			entity:UpdateHP(bean.curHP);
			entity._titleshow = false
			entity:SetTitleVisiable(false)
			if bean.id == g_i3k_game_context:GetRoleId() then
				g_i3k_game_context:setEscortCarblood(bean.curHP)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围残影同步血量
--Packet:nearby_blur_updatehp
function i3k_sbean.nearby_blur_updatehp.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Pet, bean.id);
		if entity then
			entity:UpdateHP(bean.curHP);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围符灵卫同步血量
function i3k_sbean.nearby_summoned_updatehp.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Summoned, bean.id);
		if entity then
			entity:UpdateHP(bean.curHP);
		end
	end

	return true;
end
------------------------------------------------------------------------------------
-- 周围玩家死亡
--Packet:nearby_role_dead
function i3k_sbean.nearby_role_dead.handler(bean, res)
	updateCreateNetEntityTask(bean.id, eET_Player)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.id);
		if entity then
			entity:SyncDead(bean.killerID, nil, true);
		end
		
		-- g_i3k_game_context:refreshKillTips(bean)
	end

	return true;
end

function i3k_sbean.map_role_kill.handler(bean)
	local world = i3k_game_get_world();
	if world then		
		g_i3k_game_context:refreshKillTips(bean)
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵死亡
--Packet:nearby_pet_dead
function i3k_sbean.nearby_pet_dead.handler(bean, res)
	updateCreateNetEntityTask(bean.cfgid.."|"..bean.roleID, eET_Mercenary)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if entity then
			entity:SyncDead(bean.killerID, nil, true);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物死亡
--Packet:nearby_monster_dead
function i3k_sbean.nearby_monster_dead.handler(bean, res)
	updateCreateNetEntityTask(bean.id, eET_Monster)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.id);
		if entity then
			--i3k_log("nearby_monster_dead"..entity._guid);
			entity:SyncDead(bean.killerID, nil, true);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围残影死亡
--Packet:nearby_blur_dead
function i3k_sbean.nearby_blur_dead.handler(bean, res)
	updateCreateNetEntityTask(bean.id, eET_Pet)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Pet, bean.id);
		if entity then
			entity:SyncDead(bean.killerID, nil, true);
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围符灵卫死亡
function i3k_sbean.nearby_summoned_dead.handler(bean, res)
	updateCreateNetEntityTask(bean.id, eET_Summoned)
	--i3k_log("nearby_summoned_dead"..bean.id);
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Summoned, bean.id);
		if entity then
			entity:SyncDead(bean.killerID, nil, true);
		end
	end

	return true;
end
------------------------------------------------------------------------------------
-- 周围玩家升级
function i3k_sbean.nearby_role_lvlup.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Player, bean.id);
		if Entity then
			local hero = i3k_game_get_player_hero();
			if hero and hero._guid ~= Entity._guid then
				Entity:UpdateProperty(ePropID_lvl,1,bean.newLvl-Entity:GetPropertyValue(ePropID_lvl),true,false)
				Entity:PlayLevelup()
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家同步最大血量
--Packet:nearby_role_updatemaxhp
function i3k_sbean.nearby_role_updatemaxhp.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Player, bean.id);
		local hero = i3k_game_get_player_hero();
		if Entity then
			if hero and hero._guid ~= Entity._guid then
				Entity:UpdateProperty(ePropID_maxHP, 1, bean.newMaxHp, true, false,true);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵同步最大血量
--Packet:nearby_pet_updatemaxhp
function i3k_sbean.nearby_pet_updatemaxhp.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if Entity then
			Entity:UpdateProperty(ePropID_maxHP, 1, bean.newMaxHp, true, false,true);
		end
	end
	return true;
end

----------------------------------------------------------------------------------
--周围镖车同步最大血量（包括镖车主人）
--Packet:nearby_escortcar_updatemaxhp
function i3k_sbean.nearby_escortcar_updatemaxhp.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Car, bean.id);
		if Entity then
			Entity:UpdateProperty(ePropID_maxHP, 1, bean.newMaxHp, true, false,true);
			if bean.id == g_i3k_game_context:GetRoleId() then
				g_i3k_game_context:setEscortCarblood(nil, bean.newMaxHp)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家复活
--Packet:nearby_role_revive
function i3k_sbean.nearby_role_revive.handler(bean, res)
	local world = i3k_game_get_world();
	if world and world._syncRpc then
		local entityPlayer = world:GetEntity(eET_Player, bean.id);
		if entityPlayer then
			entityPlayer._reviveHP = bean.curHP;
			entityPlayer:OnRevive({x = bean.position.x, y = bean.position.y, z = bean.position.z}, 0)
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵复活
--Packet:nearby_pet_revive
function i3k_sbean.nearby_pet_revive.handler(bean, res)
	local world = i3k_game_get_world();
	if world and world._syncRpc then
		local Entity = world:GetEntity(eET_Mercenary, bean.cfgID.."|"..bean.roleID);
		if Entity then
			Entity._reviveHP = Entity:GetPropertyValue(ePropID_maxHP);
			Entity:OnRevive({x = bean.position.x, y = bean.position.y, z = bean.position.z}, 0)
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 周围陷阱改变状态
--Packet:nearby_trap_changestate
function i3k_sbean.nearby_trap_changestate.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		-- local roleID = g_i3k_game_context:GetRoleId()
		-- i3k_log(roleID.. "   nearby_trap_changestate ".. bean.trapID .." |  "..bean.curState)
		local trap = world:GetEntity(eET_Trap, bean.trapID);
		if trap then
			trap:SetTrapBehavior(bean.curState,true);
			local hero = i3k_game_get_player_hero()
			if hero then
				-- 如果trap在自己Enmities列表中 强制更新trap状态
				hero:UpdateEnmitiesTrap(trap)
			end
		end
	end
	return true;
end


-------------------------------------------------------------------------------
--周围镖车同步状态
--Packet:nearby_escortcar_updatestate
function i3k_sbean.nearby_escortcar_updatestate.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Car, bean.id);
		if Entity then
			Entity:UpdateCarState(bean.state);
		end
	end
	return true;
end


-- 周围镖车社交信息
function i3k_sbean.nearby_escortcar_updatesocial.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Car, bean.id);
		if Entity then
			Entity._sectID = bean.sectID
			Entity._teamID = bean.teamID
		end
	end
	return true;
end

-- 周围玩家变更武魂形象
function i3k_sbean.nearby_weaponsoulshow_update.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:DetachWeaponSoul()
			if bean.showID ~= 0 then
				Entity:SetWeaponSoulShow(true)
				Entity:AttachWeaponSoul(bean.showID);
			else
				Entity:SetWeaponSoulShow(false)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家更换装备
--Packet:nearby_role_updateequip
function i3k_sbean.nearby_role_updateequip.handler(bean, res)
	--i3k_log("nearby_role_updateequip|"..hero._guid.."@RoleID|"..bean.roleID)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			Entity:AttachEquip(bean.eid);
			Entity:AttachEquipEffect(Entity._equipinfo)
			Entity:needShowHeirloom()
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家脱装备
--Packet:nearby_role_removeequip
function i3k_sbean.nearby_role_removeequip.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			Entity:DetachEquip(bean.wid, true);
			Entity:DetachEquipEffectByPartID(bean.wid)
			Entity:needShowHeirloom()
		end
	end
	return true;
end

-- 周围玩家家园装备变化广播
function i3k_sbean.nearby_role_updatehomelandequip.handler(bean, res)
	if g_i3k_game_context:GetIsInHomeLandZone() then --家园中收到广播才改变周围玩家钓鱼装备
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity._curHomeLandEquips = bean.homelandEquip
			Entity:DetachHomeLandEquip() --先卸载然后再穿上蒙皮
			Entity:AttachHomeLandCurEquip(bean.homelandEquip)
			Entity:UnloadHomeLandFishModel()--快速切换 先卸载钓鱼挂载模型
			Entity:LinkHomeLandFishEquip()
		end
	end
	return true;
	end
end

-- 周围玩家更新钓鱼状态
function i3k_sbean.nearby_role_fishstatus.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:SetFishStatus(bean.status)
			Entity:LinkHomeLandFishEquip()
			if bean.status ~= 1 then -- 周围玩家退出钓鱼状态，卸载挂载的模型entity
				Entity:UnloadHomeLandFishModel()
			end
		end
	end
end

-- 周围玩家开始钓鱼
function i3k_sbean.nearby_role_startfish.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			local r = i3k_vec3_angle2(i3k_vec3(bean.rotation.x, bean.rotation.y, bean.rotation.z), i3k_vec3(1, 0, 0));
			Entity:SetFaceDir(0, r, 0);
			Entity:PlayStartFishAct()
		end
	end
	return true;
end

-- 周围玩家结束钓鱼
function i3k_sbean.nearby_role_endfish.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			if Entity._curHomeLandEquips then
				Entity:PlayEndFishAct()
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
--通知周围玩家改变战斗姿态
--Packet:nearby_role_change_combat_type
function i3k_sbean.nearby_role_change_combat_type.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:SetCombatType(bean.combatType)
		end
	end
end
--------------------------------------------
-- 周围玩家激活神兵
--Packet:nearby_role_motivateweapon
function i3k_sbean.nearby_role_motivateweapon.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			Entity:UseWeapon(bean.weaponID, bean.form)
			Entity:OnSuperMode(true)
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家激活神兵结束
--Packet:nearby_role_motivateend
function i3k_sbean.nearby_role_motivateend.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			local hero = i3k_game_get_player_hero();
			if hero._guid == Entity._guid then
				Entity:SuperMode(false)			
			else
				if Entity._title then
					Entity:OnSuperMode(false)
				end
			end
			
			local maptype = 
			{
				[g_FORCE_WAR] = true,
				[g_DEMON_HOLE] = true,
				[g_FACTION_WAR] = true,
				[g_DEFENCE_WAR] = true,
				[g_MAZE_BATTLE] = true,
			}
			
			local map = i3k_game_get_map_type()
			
			if Entity:IsPlayer() and map and maptype[map] then
				Entity:OnUnifyMode(true)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家更换当前骑乘的坐骑
--Packet:nearby_ride_horse
function i3k_sbean.nearby_ride_horse.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:UseRide(bean.horseShowID)
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家下马
--Packet:nearby_unride_horse
function i3k_sbean.nearby_unride_horse.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:ClearOtherMulHorse()
			Entity:OnRideMode(false)
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家开始采矿
--Packet:nearby_role_mineralstart
function i3k_sbean.nearby_role_mineralstart.handler(bean, res)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.roleID);
		if entityPlayer then
			local mine = world._ResourcePoints[bean.mineralID]
			if mine and mine._gcfg then
				local roleID = g_i3k_game_context:GetRoleId()
				if roleID == bean.roleID then
					entityPlayer:SetDigStatus(2)
				end

				local action = mine._gcfg.Action;
				local pos = mine._curPos
				local newpos = entityPlayer._curPos
				local angle = i3k_vec3_angle2(i3k_vec3(pos.x-newpos.x, newpos.y, pos.z-newpos.z), i3k_vec3(1, 0, 0));
				entityPlayer:SetFaceDir(0, angle, 0)
				entityPlayer:Play(action, -1);
				mine:playCollectedAction()
			end

		end
	end

	return true;
end

--周围矿状态更新
function i3k_sbean.nearby_mineral_updatestate.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local mine = world._ResourcePoints[bean.id];
		if mine and mine._gcfg then
			if bean.state == 0 and mine._gcfg.destroyModleID > 0 then
				--mine:Play(mine._gcfg.destroyAction, -1);
				mine:ChangeModelFacade(mine._gcfg.destroyModleID)
			end
			mine:setResourcepointState(bean.state, true)
		end
	end
end

------------------------------------------------------------------------------------
-- 取消采矿
--Packet:mineral_quit
function i3k_sbean.send_mineral_quit()
	local bean = i3k_sbean.mineral_quit.new()
	i3k_game_send_str_cmd(bean)
end

-- 周围玩家采矿结束包括自己
--Packet:nearby_role_mineralend
function i3k_sbean.nearby_role_mineralend.handler(bean, res)
	local world = i3k_game_get_world();
	if not world then
		return
	end

	local hero = i3k_game_get_player_hero();
	local mineralId = bean.mineralId
	local entityPlayer = world:GetEntity(eET_Player, bean.roleID);
	local mineral = world._ResourcePoints[mineralId];
	if not hero or not mineral then
		return
	end

	if bean.success == 1 then
		local MineInfo = g_i3k_game_context:GetMineInfo()
		if g_i3k_game_context:GetRoleId() == bean.roleID and MineInfo then
			if MineInfo._gcfg.nType == 1 then		--任务矿
				local guid = string.split(MineInfo._guid, "|")
				local id = MineInfo._gcfg.ID
				local taskType = g_i3k_game_context:getMineTaskType()
				local isTrue = false
				hero:SetDigStatus(0)

				if taskType == TASK_CATEGORY_MAIN then
					local is_true,is_ok = g_i3k_game_context:UpdateMainTaskValue(g_TASK_COLLECT,id)
					if is_true and not is_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_WEAPON then
					local is_true1,is_true2,is_ok1,is_ok2 = g_i3k_game_context:UpdateWeaponTaskValue(g_TASK_COLLECT,id)
					if (is_true1 and not is_ok1) or (is_true2 and not is_ok2) then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_PET then
					local have_count,ok_count = g_i3k_game_context:UpdatePetTaskValue(g_TASK_COLLECT,id)
					if have_count ~= 0 and ok_count < have_count then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_SECT then
					local is_faction_true,is_faction_ok = g_i3k_game_context:UpdateFactionTaskValue(g_TASK_COLLECT,id)
					if is_faction_true and not is_faction_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_SUBLINE then
					local is_true3,is_ok3 = g_i3k_game_context:UpdateSubLineTaskValue(g_TASK_COLLECT,id)
					if is_true3 and not is_ok3 then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_LIFE then
					local is_true4,is_ok4 = g_i3k_game_context:UpdateLifeTaskValue(g_TASK_COLLECT,id)
					if is_true4 and not is_ok4 then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_OUT_CAST then
					local is_true4,is_ok4 = g_i3k_game_context:UpdateOutCastTaskValue(g_TASK_COLLECT,id)
					if is_true4 and not is_ok4 then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_EPIC then
					local is_true,is_ok = g_i3k_game_context:UpdateEpicTaskValue(g_TASK_COLLECT,id)
					if is_true and not is_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_ADVENTURE then
					local is_true,is_ok = g_i3k_game_context:UpdateAdventureTaskValue(g_TASK_COLLECT,id)
					if is_true and not is_ok then
						isTrue = true
					end
					g_i3k_game_context:setPusslePicIsFinish(false)
				elseif taskType == TASK_CATEGORY_FCBS then
					local is_true,is_ok = g_i3k_game_context:UpdateFCBSTaskValue(g_TASK_COLLECT,id)
					if is_true and not is_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_DRAGON_HOLE then
					local dragonCfg = g_i3k_game_context:UpdateDragonHoleValue(g_TASK_COLLECT, id)
					if dragonCfg then
						for _, v in ipairs(dragonCfg) do
							if v.isThis and not v.isFinished then
								isTrue = true
								break
							end
						end
					end
				elseif taskType == TASK_CATEGORY_CHESS then
					local is_true, is_ok = g_i3k_game_context:updateChessTaskValue(g_TASK_COLLECT, id)
					if is_true and not is_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_POWER_REP then
					local taskCfg = g_i3k_game_context:updatePowerRepTaskValue(g_TASK_COLLECT, id)
					if taskCfg then
						for k, v in ipairs(taskCfg) do
							if v.isThis and not v.isFinished then
								isTrue = true
								break
							end
						end
					end
				elseif taskType == TASK_CATEGORY_FESTIVAL then
					local taskCfg = g_i3k_game_context:updateFestivalTaskValue(g_TASK_COLLECT, id)
					if taskCfg then
						for k, v in ipairs(taskCfg) do
							if v.isThis and not v.isFinished then
								isTrue = true
								break
							end
						end
					end
				elseif taskType == TASK_CATEGORY_JUBILEE then
					local is_true, is_ok = g_i3k_game_context:updateJubileeTaskValue(g_TASK_COLLECT, id)
					if is_true and not is_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_SWORDSMAN then
					local is_true, is_ok = g_i3k_game_context:updateSwordsmanTaskValue(g_TASK_COLLECT, id)
					if is_true and not is_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_GLOBALWORLD then --赏金任务
					local is_true, is_ok = g_i3k_game_context:updateGlobalWorldTaskValue(g_TASK_COLLECT, id)
					if is_true and not is_ok then
						isTrue = true
					end
				elseif taskType == TASK_CATEGORY_BIOGRAPHY then
					local is_true, is_ok = g_i3k_game_context:updateBiographyTaskValue(g_TASK_COLLECT, id)
					if is_true and not is_ok then
						isTrue = true
					end
				end
				if isTrue then
					local func = function()
						g_i3k_game_context:SetMineInfo(MineInfo)
						i3k_sbean.role_mine(MineInfo._gcfg.ID,guid[2])
					end
					g_i3k_game_context:UnRide(func, true)
				end
			else
				hero:SetDigStatus(0)
				if MineInfo._gcfg.nType == 8 then
					g_i3k_game_context:addStelaMineCount()
					g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_STELE, g_SCHEDULE_COMMON_MAPID)
				elseif MineInfo._gcfg.nType == 13 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1243))
				elseif MineInfo._gcfg.nType == 18 then
					g_i3k_game_context:refeshBattleMazezoneMineralTimes(1)
				elseif MineInfo._gcfg.nType == g_TYPE_MINE_SPY_STORY then
					g_i3k_game_context:spyMineCompletedTask(MineInfo._gcfg.ID)
				end
			end
		end
		if bean.disappear == 1 then
			local func = function ()
				local world = i3k_game_get_world();
				if not world then
					return
				end
				local mineral = world._ResourcePoints[mineralId];
				if not mineral then
					return
				end
				updateCreateNetEntityTask(mineralId, eET_ResourcePoint)
				if world._mapType == g_BASE_DUNGEON and world._openType == g_FIELD then
					world:RmvEntity(mineral);
				else
					world:ReleaseEntity(mineral);
				end
			end

			if mineral._gcfg and mineral._gcfg.destroyAction ~= "0.0" then
                local alist = {}
                table.insert(alist, {actionName = mineral._gcfg.destroyAction, actloopTimes = 1})
                table.insert(alist, {actionName = mineral._gcfg.destroyAction.."loop", actloopTimes = 1})
				mineral:PlayActionList(alist, 1)
				g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForSeconds(mineral._gcfg.destroyActionTime + 1)
					func()
				end)
			else
				func()
			end
		end

	else
		if g_i3k_game_context:GetRoleId() == bean.roleID then
			hero:SetDigStatus(0)
			if mineral._gcfg then
				if bean.success == -100 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3119))
				elseif bean.success == -101 then
					local winForce = g_i3k_game_context:getWinForce()
					local force = g_i3k_game_context:GetForceType()
					local times = 1
					if winForce == force then
						--胜利
						times = i3k_db_faction_fight_cfg.other.winBoxPick
					else
						--失败
						times = i3k_db_faction_fight_cfg.other.failBoxPick
					end
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3117,times))
				elseif bean.success == -102 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(774))
				elseif bean.success == -7 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15538))
				elseif bean.success == -11 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5301))
				elseif bean.success == -12 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18668))
				else
					local str = string.format("%s%s失败",mineral._gcfg.mineText, mineral._gcfg.name)
					g_i3k_ui_mgr:PopupTipMessage(str)
				end
				mineral:breakCollectedAction()
			end
		end
	end

	if entityPlayer then
		entityPlayer:Play(i3k_db_common.engine.defaultStandAction, -1);
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家采矿打断
--Packet:nearby_role_mineralbreak
function i3k_sbean.nearby_role_mineralbreak.handler(bean, res)
	local RoleID = bean.roleID;
	local logic = i3k_game_get_logic();
	local world = i3k_game_get_world();
	local hero = i3k_game_get_player_hero();
	if world then
		local mineral = world._ResourcePoints[bean.mineralID];
		local entityPlayer = world:GetEntity(eET_Player, RoleID);
		if entityPlayer then
			if entityPlayer._guid == hero._guid then
				hero:SetDigStatus(0)
			end
			entityPlayer:Play(i3k_db_common.engine.defaultStandAction, -1);
			if mineral and mineral._gcfg then
				mineral:breakCollectedAction();
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家添加嘲讽状态
--Packet:nearby_addataunt_role
function i3k_sbean.nearby_addataunt_role.handler(bean, res)
	local attacker = nil
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.trid);
		if Entity then
			if bean.type == eET_Mercenary then
				attacker =  world:GetEntity(bean.type, bean.id.."|"..bean.ownerID);
			else
				attacker =  world:GetEntity(bean.type, bean.id);
			end
			if attacker then
				if Entity:GetEntityType() == eET_Player then
					local player = i3k_game_get_player();
					if player then
						local hero = i3k_game_get_player_hero();
						if hero._guid == Entity._guid then
							player:OnHitObject(nil, attacker)
						end
					end
				end
				Entity._forceAttackTarget = attacker
				Entity:ClearMoveState()
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围佣兵添加嘲讽状态
--Packet:nearby_addataunt_pet
function i3k_sbean.nearby_addataunt_pet.handler(bean, res)
	local attacker = nil
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Mercenary, bean.tpid.."|"..bean.townerID);
		if Entity then
			if bean.type == eET_Mercenary then
				attacker =  world:GetEntity(bean.type, bean.id.."|"..bean.ownerID);
			else
				attacker =  world:GetEntity(bean.type, bean.id);
			end
			if attacker then
				Entity._forceAttackTarget = attacker
				Entity:AddEnmity(attacker, true)
				Entity:ClearMoveState()
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物添加嘲讽状态
--Packet:nearby_addataunt_monster
function i3k_sbean.nearby_addataunt_monster.handler(bean, res)
	local attacker = nil
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Monster, bean.tmid);
		if Entity then
			if bean.type == eET_Mercenary then
				attacker =  world:GetEntity(bean.type, bean.id.."|"..bean.ownerID);
			else
				attacker =  world:GetEntity(bean.type, bean.id);
			end
			if attacker then
				Entity._forceAttackTarget = attacker
				Entity:AddEnmity(attacker, true)
				Entity:ClearMoveState()
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围残影添加嘲讽状态
--Packet:nearby_addataunt_blur
function i3k_sbean.nearby_addataunt_blur.handler(bean, res)
	local attacker = nil
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Pet, bean.tbid);
		if Entity then
			if bean.type == eET_Mercenary then
				attacker =  world:GetEntity(bean.type, bean.id.."|"..bean.ownerID);
			else
				attacker =  world:GetEntity(bean.type, bean.id);
			end
			if attacker then
				Entity._forceAttackTarget = attacker
				Entity:AddEnmity(attacker, true)
				Entity:ClearMoveState()
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围符灵卫添加嘲讽状态
function i3k_sbean.nearby_addataunt_summoned.handler(bean, res)
	local attacker = nil
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Summoned, bean.tbid);
		if Entity then
			if bean.type == eET_Mercenary then
				attacker =  world:GetEntity(bean.type, bean.id.."|"..bean.ownerID);
			else
				attacker =  world:GetEntity(bean.type, bean.id);
			end
			if attacker then
				Entity._forceAttackTarget = attacker
				Entity:AddEnmity(attacker, true)
				Entity:ClearMoveState()
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围怪物添加硬直状态
--Packet:nearby_addspa_monster
function i3k_sbean.nearby_addspa_monster.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local entityMonster = world:GetEntity(eET_Monster, bean.tmid);
		if entityMonster then
			entityMonster:OnSpa();
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 解散一个佣兵
--Packet:nearby_dissolve_pet
function i3k_sbean.nearby_dissolve_pet.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local entityMercenary = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..bean.roleID);
		if entityMercenary then
			world:RmvEntity(entityMercenary);
			entityMercenary:Release();
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家同步PK状态
--Packet:nearby_update_pkinfo
function i3k_sbean.nearby_update_pkinfo.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			Entity._PVPFlag = bean.pkState;
			Entity._PVPColor = bean.grade;
			Entity:TitleColorTest();
			world:UpdatePKState(Entity);
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家同步移动位置
--Packet:nearby_role_updateposition
function i3k_sbean.nearby_role_updateposition.handler(bean, res)
	local timeTick = bean.timeTick;
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.id);
		if entity then
			local p1 = i3k_vec3(entity._curPos.x, 0, entity._curPos.z);
			local p2 = i3k_vec3(bean.pos.x, 0, bean.pos.z);
			local dTick = i3k_game_get_server_ping() % i3k_engine_get_tick_step();
			if i3k_game_get_logic_tick() > timeTick.tickLine then
				dTick = dTick + (i3k_game_get_logic_tick() - timeTick.tickLine);
			end
			local dist = 0;
			if entity._velocity then
				dist = i3k_vec3_len(i3k_vec3_mul2(entity._velocity, entity:GetPropertyValue(ePropID_speed) * ((dTick * i3k_engine_get_tick_step()) / 1000)));
			end
			if i3k_vec3_dist(p1, p2) > 100 + dist then
				--i3k_log("nearby_role_updateposition invalid id = " .. bean.id .. ", client pos = " .. i3k_format_pos(p1) .. ", server pos = " .. i3k_format_pos(p2) .. ", timeTick = { tickLine = " .. timeTick.tickLine .. ", outTick = " .. timeTick.outTick .. " }" .. ", dist = " .. i3k_vec3_dist(p1, p2));
				local hero = i3k_game_get_player_hero();
				if hero._guid == entity._guid then
					i3k_sbean.sync_role_adjust_serverpos(entity._curPos);
				else
					entity:SetPos(bean.pos);
				end
			end
		end
	end

	return true;
end

-- 周围玩家休闲宠物更新
--Packet:nearby_role_updatewizardpet
function i3k_sbean.nearby_role_updatewizardpet.handler(bean,res)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.rid);
		if entity then
			entity:DetachWizard(entity._guid);
			local data = i3k_db_arder_pet[bean.petId];
			entity:AttachWizard(data);
		end
	end
end

------------------------------------------------------------------------------------
-- 周围佣兵同步移动位置
--Packet:nearby_pet_updateposition
function i3k_sbean.nearby_pet_updateposition.handler(bean, res)
	local timeTick = bean.timeTick;

	--[[
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Player, bean.id);
		if entity then
			local p1 = i3k_vec3(entity._curPos.x, 0, entity._curPos.z);
			local p2 = i3k_vec3(bean.pos.x, 0, bean.pos.z);

			--i3k_log("nearby_role_updateposition id = " .. bean.id .. ", client pos = " .. i3k_format_pos(p1) .. ", server pos = " .. i3k_format_pos(p2) .. ", timeTick = { tickLine = " .. timeTick.tickLine .. ", outTick = " .. timeTick.outTick .. " }");
			if i3k_vec3_dist(p1, p2) > 100 then
				--i3k_log("nearby_role_updateposition invalid id = " .. bean.id .. ", client pos = " .. i3k_format_pos(p1) .. ", server pos = " .. i3k_format_pos(p2) .. ", timeTick = { tickLine = " .. timeTick.tickLine .. ", outTick = " .. timeTick.outTick .. " }" .. ", dist = " .. i3k_vec3_dist(p1, p2));

				entity:SetPos(bean.pos);
			end
		end
	end
	]]

	return true;
end

-----------------------------------------------------------广播协议end---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------






-----------------------------------------------------------发协议-------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--镖车移动
--Packet:escortcar_move
function i3k_sbean.sync_escortcar_move(entity, args)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();
	local bean = i3k_sbean.escortcar_move.new();
	local guid = string.split(entity._guid, "|");
	bean.cfgid = guid[2];
	bean.pos = i3k_sbean.Vector3.new();
	bean.pos.x = args.pos.x;
	bean.pos.y = args.pos.y;
	bean.pos.z = args.pos.z;
	bean.target = i3k_sbean.Vector3.new();
	bean.target.x = args.target.x;
	bean.target.y = args.target.y;
	bean.target.z = args.target.z;
	bean.speed = args.speed;
	bean.rotation = i3k_sbean.Vector3.new();
	bean.rotation.x = args.rotation.x;
	bean.rotation.y = args.rotation.y;
	bean.rotation.z = args.rotation.z;
	bean.timeTick = i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine = timeTick;
	bean.timeTick.outTick = outTick;
	g_i3k_game_context:SetEscortCarLocation(g_i3k_game_context:GetWorldMapID(), args.pos, args.rotation)
	g_i3k_game_context:SetEscortCarMapInstance(g_i3k_game_context:GetCurrentLine())
	i3k_game_send_str_cmd(bean);
	g_i3k_game_context:EscortCarMoveSync()
end

--escortcar_stopmove
function i3k_sbean.sync_escortcar_stopmove(entity, args)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();
	local bean = i3k_sbean.escortcar_stopmove.new()
	local guid = string.split(entity._guid, "|")
	bean.cfgid = guid[2];
	bean.pos = i3k_sbean.Vector3.new()
	bean.pos.x = args.pos.x;
	bean.pos.y = args.pos.y;
	bean.pos.z = args.pos.z;
	bean.timeTick = i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine = timeTick;
	bean.timeTick.outTick = outTick;
	g_i3k_game_context:SetEscortCarLocation(g_i3k_game_context:GetWorldMapID(), args.pos, args.rotation)
	g_i3k_game_context:SetEscortCarMapInstance(g_i3k_game_context:GetCurrentLine())
	i3k_game_send_str_cmd(bean)
	g_i3k_game_context:EscortCarStopMoveSync()
end

--查询entity是否存在
--Packet:query_entity_nearby
function i3k_sbean.check_entity_nearby(entity, id, entityType)
	local bean = i3k_sbean.query_entity_nearby.new();
	bean.id = id;
	bean.type = entityType;
	i3k_game_send_str_cmd(bean);
end

-- 佣兵和玩家移动
--Packet:pet_move
function i3k_sbean.sync_map_move(entity, args)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();

	if entity:GetEntityType() == eET_Player then
		local bean = i3k_sbean.role_move.new();
		bean.pos = i3k_sbean.Vector3.new();
		bean.pos.x = args.pos.x;
		bean.pos.y = args.pos.y;
		bean.pos.z = args.pos.z;
		bean.target = i3k_sbean.Vector3.new();
		bean.target.x = args.target.x;
		bean.target.y = args.target.y;
		bean.target.z = args.target.z;
		bean.speed = args.speed;
		bean.rotation = i3k_sbean.Vector3.new();
		bean.rotation.x = args.rotation.x;
		bean.rotation.y = args.rotation.y;
		bean.rotation.z = args.rotation.z;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean);
	elseif entity:GetEntityType() == eET_Mercenary then
		local bean = i3k_sbean.pet_move.new();
		local guid = string.split(entity._guid, "|");
		bean.cfgid = guid[2];
		bean.pos = i3k_sbean.Vector3.new();
		bean.pos.x = args.pos.x;
		bean.pos.y = args.pos.y;
		bean.pos.z = args.pos.z;
		bean.target = i3k_sbean.Vector3.new();
		bean.target.x = args.target.x;
		bean.target.y = args.target.y;
		bean.target.z = args.target.z;
		bean.speed = args.speed;
		bean.rotation = i3k_sbean.Vector3.new();
		bean.rotation.x = args.rotation.x;
		bean.rotation.y = args.rotation.y;
		bean.rotation.z = args.rotation.z;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean);
	end
end

-- 佣兵和玩家停止移动
--Packet:pet_stopmove
function i3k_sbean.sync_map_stopmove(entity, pos)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();

	if entity:GetEntityType() == eET_Player then
		local bean = i3k_sbean.role_stopmove.new()
		bean.pos = i3k_sbean.Vector3.new()
		bean.pos.x = pos.x;
		bean.pos.y = pos.y;
		bean.pos.z = pos.z;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean);
	elseif entity:GetEntityType() == eET_Mercenary then
		local bean = i3k_sbean.pet_stopmove.new()
		local guid = string.split(entity._guid, "|")
		bean.cfgid = guid[2];
		bean.pos = i3k_sbean.Vector3.new()
		bean.pos.x = pos.x;
		bean.pos.y = pos.y;
		bean.pos.z = pos.z;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean);
	end
end

--Packet:role_adjust_serverpos
function i3k_sbean.sync_role_adjust_serverpos(pos)
	local bean = i3k_sbean.role_adjust_serverpos.new();
	bean.pos = i3k_sbean.Vector3.new();
	bean.pos.x = pos.x;
	bean.pos.y = pos.y;
	bean.pos.z = pos.z;
	i3k_game_send_str_cmd(bean);
end

--Packet:pet_adjust_serverpos
function i3k_sbean.sync_pet_adjust_serverpos()
end

------------------------------------------------------
-- 批量查询周围玩家信息协议
--Packet:query_roles_detail
-- 批量查询周围佣兵信息
--Packet:query_pets_detail
function i3k_sbean.map_query_entitys(nType,info)
	if nType == eET_Player then
		local bean = i3k_sbean.query_roles_detail.new()
		bean.roles = info;
		i3k_game_send_str_cmd(bean)
	elseif nType == eET_Mercenary then
		local bean = i3k_sbean.query_pets_detail.new()
		bean.pets = info
		i3k_game_send_str_cmd(bean)
	end
end

--------------------------------------------------------------------------------
--Packet:role_useskill
--Packet:pet_useskill
function i3k_sbean.map_useskill(entity,SkillID,pos,rotation,TargetID,TargetType,ownerID,cfgID)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();
	if entity:GetEntityType() == eET_Player then
		local bean = i3k_sbean.role_useskill.new()
		bean.pos = i3k_sbean.Vector3.new()
		bean.pos.x = pos.x
		bean.pos.y = pos.y
		bean.pos.z = pos.z
		bean.rotation = i3k_sbean.Vector3.new()
		bean.rotation.x = rotation.x
		bean.rotation.y = rotation.y
		bean.rotation.z = rotation.z
		bean.skillID = SkillID;
		bean.targetID = TargetID;
		bean.targetType  = TargetType;
		bean.ownerID = ownerID;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean)
	elseif entity:GetEntityType() == eET_Mercenary then
		local bean = i3k_sbean.pet_useskill.new()
		bean.pos = i3k_sbean.Vector3.new()
		bean.pos.x = pos.x
		bean.pos.y = pos.y
		bean.pos.z = pos.z
		bean.rotation = i3k_sbean.Vector3.new()
		bean.rotation.x = rotation.x
		bean.rotation.y = rotation.y
		bean.rotation.z = rotation.z
		bean.cfgid = cfgID;
		bean.skillID = SkillID;
		bean.targetID = TargetID;
		bean.targetType = TargetType;
		bean.ownerID = ownerID;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean)
	end
end

function i3k_sbean.blinkSkill(entity, SkillID, pos, endPos, rotation, TargetID, TargetType, ownerID, cfgID)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();
	if entity:GetEntityType() == eET_Player then
		local bean = i3k_sbean.role_blinkskill.new()
		bean.pos = i3k_sbean.Vector3.new()
		bean.pos.x = pos.x
		bean.pos.y = pos.y
		bean.pos.z = pos.z
		bean.rotation = i3k_sbean.Vector3.new()
		bean.rotation.x = rotation.x
		bean.rotation.y = rotation.y
		bean.rotation.z = rotation.z
		bean.endPos = i3k_sbean.Vector3.new()
		bean.endPos.x = endPos.x
		bean.endPos.y = endPos.y
		bean.endPos.z = endPos.z
		bean.skillID = SkillID;
		bean.targetID = TargetID;
		bean.targetType  = TargetType;
		bean.ownerID = ownerID;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean)
	end
end

function i3k_sbean.break_old_skill()
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();
	local bean = i3k_sbean.role_breakskill.new()
	bean.timeTick = i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine = timeTick;
	bean.timeTick.outTick = outTick;
	i3k_game_send_str_cmd(bean)
end

function i3k_sbean.use_item_skill(itemId,pos,rotation,TargetID,TargetType,ownerID,cfgID)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();
	local bean = i3k_sbean.bag_useitemskill_req.new()
	bean.pos = i3k_sbean.Vector3.new()
	bean.pos.x = pos.x
	bean.pos.y = pos.y
	bean.pos.z = pos.z
	bean.rotation = i3k_sbean.Vector3.new()
	bean.rotation.x = rotation.x
	bean.rotation.y = rotation.y
	bean.rotation.z = rotation.z
	bean.itemId = itemId;
	bean.targetID = TargetID;
	bean.targetType  = TargetType;
	bean.ownerID = ownerID;
	bean.timeTick = i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine = timeTick;
	bean.timeTick.outTick = outTick;
	i3k_game_send_str_cmd(bean, "bag_useitemskill_res")
end

function i3k_sbean.role_usemapskill_Start(SkillID,pos,rotation,TargetID,TargetType,ownerID)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();

	local bean = i3k_sbean.role_usemapskill.new()
	bean.pos = i3k_sbean.Vector3.new()
	bean.pos.x = pos.x
	bean.pos.y = pos.y
	bean.pos.z = pos.z
	bean.rotation = i3k_sbean.Vector3.new()
	bean.rotation.x = rotation.x
	bean.rotation.y = rotation.y
	bean.rotation.z = rotation.z
	bean.skillID = SkillID;
	bean.targetID = TargetID;
	bean.targetType  = TargetType;
	bean.ownerID = ownerID;
	bean.timeTick = i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine = timeTick;
	bean.timeTick.outTick = outTick;
	i3k_game_send_str_cmd(bean)
end

--------------------------------------------------------------------------------
--Packet:role_useskill
function i3k_sbean.map_usefollowskill(sid, seq)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();

	local bean = i3k_sbean.role_usefollowskill.new()
	bean.pos = i3k_sbean.Vector3.new()
	bean.skillID = sid;
	bean.seq = seq;
	bean.timeTick = i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine = timeTick;
	bean.timeTick.outTick = outTick;
	i3k_game_send_str_cmd(bean)
end
--------------------------------------------------------------------------------
--Packet:role_rushstart
--Packet:pet_rushstart
function i3k_sbean.map_rushstart(entity,endPos,SkillID,ownerID)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();
	if entity:GetEntityType() == eET_Player then
		local bean = i3k_sbean.role_rushstart.new()
		bean.endPos = i3k_sbean.Vector3.new()
		bean.endPos.x = endPos.x
		bean.endPos.y = endPos.y
		bean.endPos.z = endPos.z
		bean.skillID = SkillID;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean)
	elseif entity:GetEntityType() == eET_Mercenary then
		local bean = i3k_sbean.pet_rushstart.new()
		bean.cfgid = ownerID;
		bean.endPos = i3k_sbean.Vector3.new()
		bean.endPos.x = endPos.x
		bean.endPos.y = endPos.y
		bean.endPos.z = endPos.z
		bean.skillID = SkillID;
		bean.timeTick = i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine = timeTick;
		bean.timeTick.outTick = outTick;
		i3k_game_send_str_cmd(bean)
	end
end


------------------------------------------------------------------------------------
--Packet:role_shift_start
--Packet:pet_shift_start
function i3k_sbean.map_shiftstart(entity,pos,targetID,targetType,skillID,ownerID,attackpid)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();

	if entity:GetEntityType() == eET_Player then
		local bean = i3k_sbean.role_shift_start.new()
		bean.targetID = targetID;
		bean.skillID = skillID;
		bean.targetType = targetType;
		bean.ownerID = ownerID;
		bean.endpos = i3k_sbean.Vector3.new()
		bean.endpos.x = pos.x
		bean.endpos.y = pos.y
		bean.endpos.z = pos.z
		bean.timeTick	= i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine
						= timeTick;
		bean.timeTick.outTick
						= outTick;
		i3k_game_send_str_cmd(bean)
	elseif entity:GetEntityType() == eET_Mercenary then
		local bean = i3k_sbean.pet_shift_start.new()
		bean.attackpid = attackpid;
		bean.skillID = skillID;
		bean.targetType = targetType;
		bean.ownerID = ownerID;
		bean.targetID = targetID;
		bean.endpos = i3k_sbean.Vector3.new()
		bean.endpos.x = pos.x
		bean.endpos.y = pos.y
		bean.endpos.z = pos.z
		bean.timeTick	= i3k_sbean.TimeTick.new();
		bean.timeTick.tickLine
						= timeTick;
		bean.timeTick.outTick
						= outTick;
		i3k_game_send_str_cmd(bean)
	end
end

------------------------------------------------------------------------------------
-- 陷阱点击
--Packet:trap_click
function i3k_sbean.on_trap_click(args)
	local bean = i3k_sbean.trap_click.new()
	bean.trapID = args.trapID
	i3k_game_send_str_cmd(bean)
end

-- 怪物回到出生点
--Packet:set_monster_birthpos
function i3k_sbean.change_target_pos(id)
	local bean = i3k_sbean.set_monster_birthpos.new()
	bean.mid = id
	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 更新周围玩家帮派信息
--Packet:"nearby_update_sectbrief"
function i3k_sbean.nearby_update_sectbrief.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity._sectname = bean.sectBrief.sectName;
			Entity._sectpos = bean.sectBrief.sectPosition;
			Entity._sectID = bean.sectBrief.sectID;
			Entity._sectIcon = bean.sectBrief.sectIcon;
			Entity:ChangeSectName(bean.sectBrief.sectName, bean.sectBrief.sectPosition)
			Entity:TitleColorTest();
		end
	end
	return true;
end
------------------------------------------------------------------------------------
-- 更新周围玩家称号
--Packet:nearby_role_updatetitle
function i3k_sbean.nearby_role_updatetitle.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			Entity:ChangeHonorTitle(bean.titles)
		end
	end
	return true;
end
------------------------------------------------------------------------------------
-- 周围玩家时装是否显示
--Packet:nearby_set_fashionshow
function i3k_sbean.nearby_set_fashionshow.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			Entity:SetFashionVisiable(bean.isShow == 1, bean.type)
			if bean.isShow ~= 1 and bean.type == g_FashionType_Dress then
				Entity:setSkinDisplay()
			end
			if bean.type == 1 then
				Entity:needShowHeirloom()
			end
		end
	end
	return true;
end
------------------------------------------------------------------------------------
-- 周围玩家更换时装
--Packet:nearby_update_fashions
function i3k_sbean.nearby_upwear_fashion.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		if Entity then
			if bean.type == g_FashionType_Weapon then
				Entity:AttachFashion(bean.fashionID, Entity:IsFashionWeapShow(), bean.type)
				if bean.type == 1 then
					Entity:needShowHeirloom()
				end
			else
				Entity:AttachFashion(bean.fashionID, Entity:IsFashionShow(), bean.type)
			end
		end
	end
	return true;
end


-- 周围玩家传家宝更新--已废弃
function i3k_sbean.nearby_role_updateheirloom.handler(bean, req)
	local RoleID = bean.rid;
	local PartID = 1;
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			local Entity = world:GetEntity(eET_Player, RoleID);
			if Entity then
				if Entity._heirloom then
					Entity._heirloom.display = bean.heirloom.display
				end
				Entity:needShowHeirloom()
			end
		end
	end
	return true;
end
------------------------------------------------------------------------------------
-- 周围玩家变身状态（任务变身）
--Packet:nearby_role_alterstate
function i3k_sbean.nearby_role_alterstate.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.roleID);
		--[[local mcfg = i3k_db_missionmode_cfg[bean.alterID]
		local roleID = g_i3k_game_context:GetRoleId() 
		if mcfg.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS and bean.roleID == roleID then
			return
		end--]]
		if Entity then
			if bean.alterID ~= 0 then
				Entity:MissionMode(true, bean.alterID)
			else
				Entity:MissionMode(false)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 玩家使用社交动作
--Packet:role_socialaction
function i3k_sbean.play_role_socialaction(roleId, id, useRname, beusedRname)
	local bean = i3k_sbean.role_socialaction.new()
	bean.rid = roleId
	bean.actionID = id
	bean.useRname = useRname
	bean.beusedRname = beusedRname
	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 周围玩家使用社交动作
--Packet:nearby_role_socialaction
function i3k_sbean.nearby_role_socialaction.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			if bean.actionID == 0 then
				Entity:Play(i3k_db_common.engine.defaultStandAction, -1);
			else
				Entity:PlaySocialAction(bean.actionID)
				if bean.useRname ~= "" then
					local text = ""
					if bean.beusedRname then
						text = string.format(i3k_db_social[bean.actionID].doublePop, bean.useRname, bean.beusedRname, i3k_db_social[bean.actionID].name)
					else
						text = string.format(i3k_db_social[bean.actionID].singlePop, bean.useRname, i3k_db_social[bean.actionID].name)
					end
					g_i3k_ui_mgr:PopTextBubble(true, Entity, text)
				end
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家升星或强化
--Packet:nearby_role_updatepart
function i3k_sbean.nearby_role_updatepart.handler(bean, res)
	local equippart = bean.equipPart
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.id);
		if Entity then
			if Entity._equipinfo and Entity._equipinfo[equippart.id] then
				Entity._equipinfo[equippart.id].eqGrowLvl = equippart.eqGrowLvl
				Entity._equipinfo[equippart.id].eqEvoLvl = equippart.eqEvoLvl
				local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(Entity._soaringDisplay)
				if (not Entity._missionMode.valid or (Entity._missionMode.valid and (Entity._missionMode.type ~= 1 and Entity._missionMode.type ~= 2 and Entity._missionMode.type ~= 5) ) )and not Entity._superMode.valid and weaponDisplay ~= g_FLYING_SHOW_TYPE then
					local equipId = Entity._equips[equippart.id].equipId
					local effectids = g_i3k_db.i3k_db_get_equip_effect_id(equipId, Entity._id, equippart.id, equippart.eqGrowLvl, equippart.eqEvoLvl)
					if effectids then
						Entity:AttachEquipEffectByPartID(equippart.id, effectids)
					end
				end
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家添加状态
--Packet:nearby_role_addstate
function i3k_sbean.nearby_role_addstate.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity._behavior:Set(bean.sid)
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 周围玩家去除状态
--Packet:nearby_role_removestate
function i3k_sbean.nearby_role_removestate.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity._behavior:Clear(bean.sid)
		end
	end
	return true;
end
-----------------------------------------------------------------------------------
-- 周围玩家使用后续技能
--Packet:nearby_role_usefollowskill
function i3k_sbean.nearby_role_usefollowskill.handler(bean, res)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.id);
		if Entity then
			for k,v in pairs(Entity._attacker) do
				if v._skill._id == bean.skillID then
					v:NextSequence(bean.seq);
				end
			end
		end
	end
	return true;
end
-----------------------------------------------------------------------------------
-- 周围玩家一血提示
--Packet:nearby_first_blood
function i3k_sbean.nearby_first_blood.handler(bean, res)
	local killerID = bean.killer.id
	local killerName = bean.killer.name
	local deadID = bean.deader.id
	local deadName = bean.deader.name
	local assist = bean.assist
	local hero = i3k_game_get_player_hero()
	local heroID = hero:GetGuidID()
	if heroID == killerID then
		g_i3k_game_context:AddHonor(bean.killer.addHonor,true)
		g_i3k_ui_mgr:OpenUI(eUIID_ShouSha)
	else
		for k,v in ipairs(assist) do
			if v.id == heroID then
				g_i3k_game_context:AddHonor(v.addHonor)
				break;
			end
		end
	end
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15140,killerName,deadName))
	local text = ""
	if #assist == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15142,assist[1].name))
	elseif #assist == 2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15143,assist[1].name,assist[2].name))
	elseif #assist == 3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15144,assist[1].name,assist[2].name,assist[3].name))
	end
	return true;
end

-----------------------------------------------------------------------------------
-- 周围玩家一血提示
--Packet:nearby_roll_kill
function i3k_sbean.nearby_role_kill.handler(bean, res)
	local killerID = bean.killer.id
	local killerName = bean.killer.name
	local deadID = bean.deader.id
	local deadName = bean.deader.name
	local assist = bean.assist
	local hero = i3k_game_get_player_hero()
	local heroID = hero:GetGuidID()
	if heroID == killerID then
		g_i3k_game_context:AddHonor(bean.killer.addHonor,true)
	else
		for k,v in ipairs(assist) do
			if v.id == heroID then
				g_i3k_game_context:AddHonor(v.addHonor)
				break;
			end
		end
	end
	
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15141,killerName,deadName))
	
	local text = ""
	if #assist == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15142,assist[1].name))
	elseif #assist == 2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15143,assist[1].name,assist[2].name))
	elseif #assist == 3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15144,assist[1].name,assist[2].name,assist[3].name))
	end

	return true;
end


--更新周围玩家是否是劫镖者
function i3k_sbean.nearby_role_carbehavior.handler(bean)
	--bean.id --劫镖者id
	--bean.carRobber --是否为劫镖者
	--bean.carOwner  --是否为运镖者
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.id);
		if Entity then
			if Entity._iscarRobber == 1 and bean.carRobber == 0 then
				Entity._titleshow = false
				Entity:SetTitleVisiable(false)
			end
			Entity:SetRobState(bean.carRobber)
			Entity:SetTransportState(bean.carOwner)
			Entity:ChangeTransportName()
			world:UpdatePKState(Entity)
			Entity:TitleColorTest()
		end
	end
	return true
end

--更新周围玩家改名
function i3k_sbean.nearby_role_rename.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:ChangeHeroName(bean.newName)
		end
		g_i3k_game_context:ChangeMemberName(bean.rid, bean.newName)
	end
end

--更新周围宠物改名
function i3k_sbean.nearby_pet_rename.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Mercenary, bean.petId.."|"..bean.rid)
		if Entity then
			Entity:ChangeHeroName(bean.newName)
		end
	end
end

--周围玩家内甲变化
function i3k_sbean.nearby_role_updatearmor.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity._armor.id = bean.armor.id
			Entity._armor.stage = bean.armor.rank
			i3k_log("{{{{{{{{{{{{{{{{{{{{bean.armor.hideEffect",bean.armor.hideEffect)
			Entity:SetArmorEffectHide(bean.armor.hideEffect)
			Entity:ChangeArmorEffect()
		end
	end
end

--周围玩家内甲虚弱状态更新
function i3k_sbean.nearby_role_armorweak.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			if bean.weak==1 then
				Entity:AttachArmorWeakEffect()
			else
				Entity:DetachArmorWeakEffect()
			end
		end
	end
end

-- 广播周围玩家多人坐骑变化
function i3k_sbean.nearby_update_mulhorse.handler(bean)
	local leaderID = bean.leaderID
	local index = bean.index
	local member = bean.member
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Player, leaderID);
		if member then
			local memberID = member.overview.id
			local memberEntity = world:GetEntity(eET_Player, memberID);
			if Entity and memberEntity then
				Entity:AddLinkChild(memberEntity, index, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
				world:RmvEntity(memberEntity, true);
				Entity:UpdateMemberPos(Entity._curPos)
			end
		else
			local entitys = Entity:GetLinkEntitys()
			local passenger = entitys[index]
			if passenger then
				passenger:RemoveLinkChild()
				Entity:ReleaseLinkChildIdx(index)
				world:AddEntity(passenger);
				Entity:UpdateMemberPos(Entity._curPos)
			end
		end
	end
end

-- 广播周围玩家相依相偎
function i3k_sbean.nearby_role_staywith.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local leaderEntity = world:GetEntity(eET_Player, bean.leader.overview.id)
		local memberEntity = world:GetEntity(eET_Player, bean.member.overview.id)
		if leaderEntity and memberEntity and not leaderEntity._linkHugChild then
			leaderEntity:SyncHugMode(bean.leader.overview.id, bean.member)
			leaderEntity:AddHugLinkChild(memberEntity)
			memberEntity:EnableOccluder(true)
			world:RmvEntity(memberEntity)
		end
	end
end

-- 广播周围玩家解散相依相偎
function i3k_sbean.nearby_dissolve_staywith.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local entity = world:GetEntity(eET_Player, bean.rid)
		if entity and entity._linkHugChild then
			local memberEntity = entity._linkHugChild
			if memberEntity then
				memberEntity:RemoveHugLinkChild()
				memberEntity:EnableOccluder(false)
				entity._linkHugChild = nil
				entity:LeaveHugMode()
				memberEntity:LeaveHugMode()
				world:AddEntity(memberEntity)
			end
		end
	end
end

-- 周围怪物开始变身
--Packet:nearby_monster_alterstart
function i3k_sbean.nearby_monster_alterstart.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.mid)
		if entity and entity._behavior then
			entity:ClearState()
			entity:SyncAlter()
		end
	end
end

-- 周围怪物结束变身
--Packet:nearby_monster_alterend
function i3k_sbean.nearby_monster_alterend.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.mid)
		if entity and entity._behavior then
			if bean.alterType == 5 then
				g_i3k_ui_mgr:CloseUI(eUIID_MonsterPop)
				local cfg = i3k_db_monsters[bean.alterID];
				local pos = entity._curPos
				entity:ClearState()		
				entity:Release()
				entity:CreateActor();
				entity:Create(bean.alterID, cfg.name, nil, nil, nil, cfg.level,{},cfg,eET_Monster, false);
				entity:SetPos(pos)
					
				if cfg.hpOrg then
					entity:UpdateProperty(ePropID_maxHP, 1, cfg.hpOrg, true, false,true);			
					entity:UpdateHP(cfg.hpOrg);				
					entity:UpdateBloodBar(entity:GetPropertyValue(ePropID_hp) / entity:GetPropertyValue(ePropID_maxHP));
				end
				entity:CreateTitle()
			end
		end
	end
end

-- 周围怪物说话
--Packet:nearby_monster_pop
function i3k_sbean.nearby_monster_pop.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entity = world:GetEntity(eET_Monster, bean.mid)
		if entity and bean.dialogID then
			entity:MonsterPopText(bean.dialogID, true)
		end
	end
end

-- 周围玩家浮空延长
function i3k_sbean.nearby_role_prolong_floating.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:ProlongFloationgBuff()
		end
	end
end

-- 示爱道具进入视野
function i3k_sbean.nearby_enter_showloveitems.handler(bean)
	local items = bean.showloveitems or {}
	local world = i3k_game_get_world()
	for _, v in ipairs(items) do
		local id = v.id
		local location = v.location
		if world then
			world:CreateShowLoveItem(id, location)
		end
	end
end

-- 示爱道具离开视野
function i3k_sbean.nearby_leave_showloveitems.handler(bean)
	local ids = bean.showloveitems or {}
	local world = i3k_game_get_world()
	world:RemoveShowLoveItems(ids)
end

-- 使用示爱道具
function i3k_sbean.useShowLoveItem(itemID, roleID)
	local data = i3k_sbean.show_love_item_use_req.new()
	data.itemId = itemID
	data.beUsedRid = roleID
	i3k_game_send_str_cmd(data, "show_love_item_use_res")
end
function i3k_sbean.show_love_item_use_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("道具使用成功！")
		g_i3k_ui_mgr:CloseUI(eUIID_UseShowLoveItem)
		g_i3k_game_context:UseCommonItem(req.itemId, 1, AT_USE_SHOW_LOVE_ITEM)
		g_i3k_ui_mgr:OpenUI(eUIID_ShowLoveItemUI)
	elseif res.ok == -100 then -- 已经存在示爱道具
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16962))
		return
	elseif res.ok == -101 then -- 性别相同
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16964))
		return
	elseif res.ok == -102 then -- cd时间
		local curtime = i3k_game_get_time()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16965, res.cdEndTime - curtime))
	elseif res.ok == -103 then -- 不在坐标范围内
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16963))
	else
		g_i3k_ui_mgr:PopupTipMessage("道具使用失败！")
	end
end

function i3k_sbean.show_love_item_be_used_notice.handler(res, req)
	local itemID = res.itemID
	g_i3k_ui_mgr:OpenUI(eUIID_ShowLoveItemUI)
end


-- 荣耀殿堂雕像进入视野
function i3k_sbean.nearby_enter_honnorstatue.handler(bean)
	local status = bean.statue
	local world = i3k_game_get_world()
	for k, v in ipairs(status) do
		local args = getStatuArgsFromBean(v)
		local ID = v.id
	
		local r = i3k_vec3_angle2(i3k_vec3(v.location.rotation.x, v.location.rotation.y, v.location.rotation.z), i3k_vec3(1, 0, 0));
		local Dir_p = {x = 0 ,y = r ,z = 0 }
		local StartPos = {x = v.location.position.x, y = v.location.position.y, z = v.location.position.z}
		world:CreatePlayerStatuFromCfg(ID, StartPos, Dir_p, args)
	end
end

-- 荣耀殿堂雕像离开视野
function i3k_sbean.nearby_leave_honnorstatue.handler(bean)
	local status = bean.status
	local world = i3k_game_get_world()
	for _, v in ipairs(status) do
		local entity = world:GetEntity(eET_PlayerStatue, v)
		if entity then
			world:ReleaseEntity(entity, true)
		end
	end
end

-- 周围玩家更换良驹之灵外观
function i3k_sbean.nearby_horse_spirit_show.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			Entity:SetRideSpiritCurShowID(bean.showID)
			Entity:UpdateSteedSpiritShow(bean.showID ~= 0)
		end
	end
end

--周围玩家摆放地面家具
function i3k_sbean.house_land_furniture_use.handler(bean)
	local world = i3k_game_get_world()
	if world then
		world:CreateFloorFurniture(bean.furniture, true, nil, g_HOUSE_FLOOR_FURNITURE)
	end
	g_i3k_game_context:addHouseBuildValue(i3k_db_home_land_floor_furniture[bean.furniture.furnitureId].builtPoint)
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
end

--周围玩家摆放墙面家具
function i3k_sbean.house_wall_furniture_use.handler(bean)
	local world = i3k_game_get_world()
	if world then
		world:CreateWallFurniture(bean.furniture, true)
	end
	g_i3k_game_context:addHouseBuildValue(i3k_db_home_land_wall_furniture[bean.furniture.id].builtPoint)
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
end

--周围玩家摆放附加家具
function i3k_sbean.house_addition_furniture_use.handler(bean)
	local world = i3k_game_get_world()
	if world then
		world:FurnitureAddition(bean)
		g_i3k_game_context:addHouseBuildValue(i3k_db_home_land_hang_furniture[bean.furnitureId].builtPoint)
		g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
	end	
end

--周围玩家摆放地毯家具
function i3k_sbean.house_floor_furniture_use.handler(bean)
	local world = i3k_game_get_world()
	if world then
		world:CreateFloorFurniture(bean.furniture, true, nil, g_HOUSE_CARPET_FURNITURE)
	end
	g_i3k_game_context:addHouseBuildValue(i3k_db_home_land_carpet_furniture[bean.furniture.furnitureId].builtPoint)
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
end

--周围玩家移除家具
function i3k_sbean.house_land_furniture_remove.handler(bean)
	local world = i3k_game_get_world()
	if world then
		world:ReleasePlacedFurniture(bean.index, bean.type)
	end
end

--周围玩家移动地面家具
function i3k_sbean.house_furniture_move.handler(bean)
	local world = i3k_game_get_world()
	if world then
		world:RemoveFloorFurniture(bean)
	end
end

--所在家园的房屋等级提升
function i3k_sbean.homeland_house_level.handler(bean)
	g_i3k_game_context:SetCurHomeLandHouseLevel(bean.level)
end

--周围玩家替换房屋皮肤
function i3k_sbean.house_skin_change.handler(bean)
	g_i3k_game_context:changeCurHouseSkin(bean.index)
	local world = i3k_game_get_world()
	if world then
		world:ChangeHouseSkin(bean.index)
	end
end

--周围怪物可点击次数同步
function i3k_sbean.sync_monster_click_num.handler(bean)	
	local world = i3k_game_get_world();
	
	if world then
		local entity = world:GetEntity(eET_Monster, bean.mid);
		
		if entity then
			entity:setCanClickCount(bean.clickNum);
		end
			
		if bean.clickNum > 0 then
			local mapId = g_i3k_game_context:GetWorldMapID()
			local gruop_id = 0
		
			if i3k_db_activity_cfg[mapId] then
				gruop_id = i3k_db_activity_cfg[mapId].groupId
			end
		
			if gruop_id and gruop_id == 11 then --飞马渡组ID
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17456))
			end
		else
			entity:sethaveClickCount(0)
		end
	end
end

--通知客户端播放动画目前只有飞马度用
function i3k_sbean.broadcast_animation_activity_copy.handler(res)
	if res.animationID then
		i3k_game_play_scene_ani(res.animationID)
	end
end

-- 幻境副本 通知客户端刷新过的BOSS
function i3k_sbean.illusory_map_sync_refreshed_bossIDs.handler(res)
	--self.curBossID:		int32			当前boss刷怪区域
	--self.bossIDs:		vector[int32]		已刷新boss刷怪区域
	--self.deadBossIDs:		vector[int32]	所有死亡bossID
	local world = i3k_game_get_world()
	local monsterIDs = {}
	if res.bossIDs then
		if world then
			for _, spawnID in ipairs(res.bossIDs) do
				local spawnPointID = i3k_db_spawn_area[spawnID].spawnPoints[1]
				local bossID = i3k_db_spawn_point[spawnPointID].monsters[1]
				world:ReleaseIllusoryMonster(bossID)
				table.insert(monsterIDs, bossID)
			end
		end
		--幻境副本boss属性
		if g_i3k_ui_mgr:GetUI(eUIID_BattleIllusory) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleIllusory, "updateBossScroll", monsterIDs, res.deadBossIDs)
		end
	end

	--幻境副本boos提示
	local spawnID = res.curBossID
	if g_i3k_ui_mgr:GetUI(eUIID_BattleIllusory) and spawnID ~= 0 then
		local spawnPointID = i3k_db_spawn_area[spawnID].spawnPoints[1]
		local bossID = i3k_db_spawn_point[spawnPointID].monsters[1]
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleIllusory, "openBossRefreshTips", bossID)
	end
end

--决战荒漠周围玩家积分改变
function i3k_sbean.nearby_survive_score_update.handler(res)
	local world = i3k_game_get_world();
	local entityPlayer = world:GetEntity(eET_Player, res.rid);
		
	if entityPlayer then
		entityPlayer:setDesertBatttleInfo(res.score, entityPlayer._desertInfo.modleId)
		entityPlayer:changeScoreText(res.score)
	end
end
-- 周围实例进入视野
function i3k_sbean.nearby_enter_entities.handler(bean)
	--self.type:		int32	
	--self.entities:		vector[EnterEntity]	
	local world = i3k_game_get_world()
	if world then
		if bean.type == eET_HomePet then
			for _, v in ipairs(bean.entities) do
				world:CreateHomelandPets(v)
			end
		elseif bean.type == eET_DisposableNPC then
			for _, e in ipairs(bean.entities) do
				local entityNPC = world:GetEntity(bean.type, e.id)
				if not entityNPC then
					local cfg = i3k_db_jubilee_npcs[e.id]
					local textIndex = i3k_engine_get_rnd_u(1, #i3k_db_dialogue[cfg.popDialogueID])
					local txt = i3k_db_dialogue[cfg.popDialogueID][textIndex].txt
					world:CreateDisposableNpc(e.id, cfg.npcID, e.location, nil, txt)
				end
			end
		end
	end
end

-- 周围实例离开视野
function i3k_sbean.nearby_leave_entities.handler(bean)
	--self.type:		int32	
	--self.entities:		vector[int32]	
	local world = i3k_game_get_world()
	if world then
		if bean.type == eET_HomePet then
			for _, v in ipairs(bean.entities) do
				world:RemoveHomelandPets(v)
			end
		elseif bean.type == eET_DisposableNPC then
			for _, e in ipairs(bean.entities) do
				local entityNPC = world:GetEntity(bean.type, e)
				if entityNPC then
					world:ReleaseEntity(entityNPC, true)
				end
			end
		end
	end
end

-- 周围实例移动
function i3k_sbean.nearby_move_entity.handler(res)
	--self.type:		int32	
	--self.id:		int32	
	--self.pos:		Vector3	
	--self.speed:		int32	
	--self.rotation:		Vector3F	
	--self.timeTick:		TimeTick	
	local world = i3k_game_get_world()
	if world then
		if res.type == eET_HomePet then
			world:homelandPetsMovePos(res.id, res.pos, res.speed, res.rotation, res.timeTick)
		end
	end
end
-- 周围实例停止移动
function i3k_sbean.nearby_stopmove_entity.handler(res)
	--self.type:		int32	
	--self.id:		int32	
	--self.pos:		Vector3	
	--self.timeTick:		TimeTick	
	local world = i3k_game_get_world()
	if world then
		if res.type == eET_HomePet then
			world:homelandPetsStopMove(res.id, res.pos, res.timeTick)
		end
	end
end
--周围玩家更换脚底特效
function i3k_sbean.nearby_role_updatefooteffect.handler(bean)
	--<field name="roleID" type="int32"/>
	--<field name="footEffect" type="int32"/>
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			local Entity = world:GetEntity(eET_Player, bean.roleID);
			if Entity then
				if Entity._soaringDisplay then
					Entity._soaringDisplay.footEffect = bean.footEffect
				end
				Entity:changeFootEffect(bean.footEffect)
			end
		end
	end
	return true;
end
--周围玩家更换武器外显
function i3k_sbean.nearby_role_updateweapondisplay.handler(bean)
	--<field name="roleID" type="int32"/>
	--<field name="weaponDisplay" type="int32"/>
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			local Entity = world:GetEntity(eET_Player, bean.roleID);
			if Entity then
				if Entity._soaringDisplay then
					Entity._soaringDisplay.skinDisplay = math.floor(bean.weaponDisplay / g_FLYING_OFFSET)
					Entity._soaringDisplay.weaponDisplay = bean.weaponDisplay % g_FLYING_OFFSET
				end
				Entity:changeWeaponShowType()
			end
		end
	end
	return true;
end
-- 周围周年活动NPC创建
function i3k_sbean.nearby_create_jubileeactivitynpc.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local cfgID = bean.entity.id
		local cfg = i3k_db_jubilee_npcs[cfgID]
		local entityNPC = world:CreateDisposableNpc(cfgID, cfg.npcID, bean.entity.location, i3k_world_pos_to_logic_pos(cfg.startPos))
		local textIndex = i3k_engine_get_rnd_u(1, #i3k_db_dialogue[cfg.popDialogueID])
		local txt = i3k_db_dialogue[cfg.popDialogueID][textIndex].txt
		world:DisposableNpcMove(entityNPC, cfg.finalPos, txt, true)
	end
end
-- 周围周年活动NPC销毁
function i3k_sbean.nearby_destory_jubileeactivitynpc.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local entityNPC = world:GetEntity(eET_DisposableNPC, bean.id)
		if entityNPC then
			local cfg = i3k_db_jubilee_npcs[bean.id]
			world:DisposableNpcMove(entityNPC, cfg.startPos)
		end
	end
end
--self.roleID:		int32
--self.isShow:		int32
--self.curPetGuard:		int32
--self.pets			set<int32>
function i3k_sbean.nearby_role_changepetguard.handler(bean)
	local world = i3k_game_get_world()
	for k, v in pairs(bean.pets) do
		local petEntity = world:GetEntity(eET_Mercenary, k.."|"..bean.roleID)
		if petEntity then
			petEntity:DetachPetGuard()
			if bean.isShow == 0 and bean.curPetGuard ~= 0 then
				petEntity:SetCurPetGuardId(bean.curPetGuard)
				if not petEntity:IsDead() then
					petEntity:AttachPetGuard(bean.curPetGuard)
				end
			else
				petEntity:SetCurPetGuardId(nil)
			end
		end
	end
end
--驭灵点cd刷新
function i3k_sbean.ghost_island_single_point_update.handler(bean)
	--self.point:		int32	
	--self.time:		int32	
	g_i3k_game_context:changeCatchSpiritPointCD(bean.point, bean.time)
end
--驭灵boss状态更新
function i3k_sbean.ghost_island_boss_update.handler(bean)
	--bean.bosses
	g_i3k_game_context:setCatchSpiritBoss(bean.bosses)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritTask, "updateCatchCount")
end

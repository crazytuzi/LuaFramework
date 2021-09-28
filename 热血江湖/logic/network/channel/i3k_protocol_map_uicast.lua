------------------------------------------------------
module(..., package.seeall)

local require = require
require("i3k_sbean")

require("logic/entity/i3k_entity_def");
local BASE = require("logic/network/channel/i3k_channel");

local frame_task_mgr = require("i3k_frame_task_mgr")

local function addCreateNetEntityCreatTask(world, name, RoleID, eType, configID, args)
	--i3k_warn("FrameTask addTask, etype=" .. eType ..", id= " .. RoleID)
	frame_task_mgr.addNormalTask({
					taskType = "net_entity",
					etype = eType,
					eid = RoleID,
					run = function()
						i3k_warn("!!!(tick=" .. i3k_get_update_tick() .. ") FrameTask runTask, etype=" .. eType ..", id= " .. RoleID)
						world:UpdateModelFromNetwork(RoleID,eType,configID,args);
					end})

	return true
end

local function updateCreateNetEntityTask(RoleID, eType)
	--i3k_warn("FrameTask cancelTask, etype=" .. eType ..", id= " .. RoleID)
	frame_task_mgr.updateTask(function(task)
			return task.taskType == "net_entity" and task.etype == eType and task.eid == RoleID
		end)
end

-- 从协议数据roledetails获取客户端args数据table
local function getArgsFromBean(overview, model, title, state, appearance, buffDrugs, petOverview, combatType)
	local Equips = {}
	local args = {
		RoleType 	= overview.type,
		Rolename 	= overview.name,
		Gender 		= overview.gender,
		HeadIconID	= overview.headIcon,
		HeadBorder 	= overview.headBorder,
		nLevel		= overview.level,
		bwtype		= overview.bwType,
		Face		= model.face,
		Hair		= model.hair,
		Armor		= model.armor,
		roleEquipsDetails = model.equipParts,
		fashions	= model.curFashions,
		Equips		= model.equips,
		heirloom	= model.heirloom,
		homelandEquip = model.homelandEquip,
		isFishing	= model.isFishing, --钓鱼状态啊
		weaponSoulShow = model.weaponSoulShow,
		soaringDisplay = model.soaringDisplay, --脚印特效和武器显示
		pkGrade		= title.pkGrade,
		pkState		= title.pkState,
		sectname	= title.sectBrief.sectName,
		sectID		= title.sectBrief.sectID,
		sectPosition = title.sectBrief.sectPosition,
		sectIcon	= title.sectBrief.sectIcon,
		permanentTitle = title.permanentTitle,
		timedTitles = title.timedTitles,
		carOwner 	= title.carOwner,
		carRobber 	= title.carRobber,
		desertScore = title.score,
		Buffs 		= state.buffs,
		nCurHP 		= state.curHp,
		nMaxHP 		= state.maxHp,
		armorWeak	= state.armorWeak,
		states		= state.states,
		wizardPetId = appearance.wizardPetId,
		horseShowID = appearance.horseShowID,
		horseSpiritShowID = appearance.horseSpiritShowID,
		alterID		= appearance.alterID,
		socialActionID = appearance.socialActionID,
		Weapon		= appearance.transfromedWeapon,
		weaponForm	= appearance.weaponForm,
		Motivate = appearance.transfromedWeapon ~= 0,
		desertModelId = appearance.heroId,
		chessArm = appearance.chessArm,
		attackMode 	= 0,
		buffDrugs   = buffDrugs,
		petAlter    = petOverview,
		combatType  = combatType
	}
	return	args
end

----------------------------------------------------------------------------------
-- 玩家位置矫正
--Packet:role_adjust_pos
function i3k_sbean.role_adjust_pos.handler(bean, res)
	local pos = bean.pos
	local entityID = bean.entityID
	local Player = i3k_game_get_player()
	if Player then
		Player:SetHeroPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)))));
	end

	return true;
end

----------------------------------------------------------------------------------
-- 佣兵位置矫正
--Packet:pet_adjust_pos
function i3k_sbean.pet_adjust_pos.handler(bean, res)
	local pos = bean.pos
	local world = i3k_game_get_world();
	if world then
		local hero = i3k_game_get_player_hero();
		if hero then
			local guid = string.split(hero._guid, "|")
			local entityMercenary = world:GetEntity(eET_Mercenary, bean.cfgid.."|"..guid[2]);
			if entityMercenary then
				entityMercenary._forceFollow = nil;
				entityMercenary.target = nil;
				entityMercenary:StopMove(true);
				entityMercenary:SetPos(pos,true);
			end
		end
	end


	return true;
end

------------------------------------------------------------------------------------
-- 玩家自身添加状态
--Packet:role_addstate
function i3k_sbean.role_addstate.handler(bean, res)
	local stateID = bean.sid;
	local hero = i3k_game_get_player_hero();
	if hero then
		hero._behavior:Set(stateID)
	end
end

------------------------------------------------------------------------------------
-- 玩家自身去除状态
--Packet:role_removestate
function i3k_sbean.role_removestate.handler(bean, res)
	local stateID = bean.sid;
	local hero = i3k_game_get_player_hero();
	if hero then
		hero._behavior:Clear(stateID)
	end
end

------------------------------------------------------------------------------------
-- 佣兵自身添加状态
--Packet:pet_addstate
function i3k_sbean.pet_addstate.handler(bean, res)
	local CfgID = bean.pid;
	local stateID = bean.sid;
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer();
		if player then
			for k = 1,player:GetMercenaryCount() do
				local mercenary = player:GetMercenary(k);
				if mercenary then
					local guid = string.split(mercenary._guid, "|")
					if tonumber(guid[2]) == CfgID then
						mercenary._behavior:Set(stateID)
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------------------
-- 佣兵自身去除状态
--Packet:pet_removestate
function i3k_sbean.pet_removestate.handler(bean, res)
	local CfgID = bean.pid;
	local stateID = bean.sid;
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer();
		if player then
			for k = 1,player:GetMercenaryCount() do
				local mercenary = player:GetMercenary(k);
				if mercenary then
					local guid = string.split(mercenary._guid, "|")
					if tonumber(guid[2]) == CfgID then
						mercenary._behavior:Clear(stateID)
					end
				end
			end
		end
	end
end




------------------------------------------------------------------------------------
--佣兵召唤协议
function i3k_sbean.role_summon_pet.handler(bean, res)
	local petId = bean.petId
	local curHP = bean.curHP
	local curSP = bean.curSP
	local location = bean.location
	local isDead = bean.isDead;
	local posId = bean.seq
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			if world then
				local lvl = g_i3k_game_context:getPetLevel(petId)
				local skill = g_i3k_game_context:GetMercenarySkillLevelForIndex(petId)
				local SMercenary = require("logic/entity/i3k_mercenary");
				local guid = -1
				local hero = player:GetHero()
				if hero then
					guid = string.split(hero._guid, "|")
				end
				local Guid = i3k_gen_entity_guid_new(SMercenary.i3k_mercenary.__cname,petId.."|"..guid[2]);
				i3k_game_register_entity_RoleID(eET_Mercenary.."|"..petId.."|"..guid[2], Guid);
				local Mercenary = SMercenary.i3k_mercenary.new(Guid);
				if Mercenary:Create(petId, lvl, skill, false) then
					Mercenary:SetGroupType(eGroupType_O); -- 设置是否友好（和平，善恶，自由）
					local pos = location.position
					local rot = location.rotation
					local curSP = curSP
					local curHP = curHP
					local r = i3k_vec3_angle2(i3k_vec3(rot.x,rot.y,rot.z), i3k_vec3(1, 0, 0));
					Mercenary:SetFaceDir(0, r, 0); --朝向
					Mercenary:Birth(pos);		--起始位置
					Mercenary:SetPos(pos);
					Mercenary:SetPosId(posId)
					Mercenary:Show(true, true);
					Mercenary:SetBWType(hero._bwType)
					Mercenary:Play(i3k_db_common.engine.defaultStandAction, -1);  	--默认执行的动作
					Mercenary:OnDamage(Mercenary, 1, Mercenary:GetPropertyValue(ePropID_hp) - curHP, false, 1, false, true, nil, false);--承受伤害
					if isDead == 1 then
						Mercenary:OnDead();
					end
					Mercenary:UpdateBloodBar(Mercenary:GetPropertyValue(ePropID_hp) / Mercenary:GetPropertyValue(ePropID_maxHP)); --更新血条
					if world._openType == g_BASE_DUNGEON then
						Mercenary:UpdateProperty(ePropID_sp, 1, curSP, true, false, true);
					end
					Mercenary:SyncRpc(world._syncRpc);
					Mercenary:AddAiComp(eAType_IDLE);  --加载ai
					--Mercenary:AddAiComp(eAType_MOVE);
					if world._mapType==g_ARENA_SOLO or world._mapType==g_TAOIST then
						Mercenary:AddAiComp(eAType_FOLLOW_ARENA)
						Mercenary:AddAiComp(eAType_ARENA_MERCENARY_FIND_TARGET)
					else
						Mercenary:AddAiComp(eAType_FOLLOW);
						Mercenary:AddAiComp(eAType_FORCE_FOLLOW);
					end
					--Mercenary:AddAiComp(eAType_FOLLOW);
					Mercenary:AddAiComp(eAType_ATTACK);
					Mercenary:AddAiComp(eAType_AUTO_SKILL);
					Mercenary:AddAiComp(eAType_FIND_TARGET);
					--Mercenary:AddAiComp(eAType_FORCE_FOLLOW);
					Mercenary:AddAiComp(eAType_SPA);
					Mercenary:AddAiComp(eAType_SHIFT);
					Mercenary:AddAiComp(eAType_FEAR);
					Mercenary:AddAiComp(eAType_DEAD_MERCENARY);
					Mercenary:AddAiComp(eAType_DEAD_REVIVE);
					Mercenary:AddAiComp(eAType_MERCENARY_AUTO_FIND_TARGET)
					Mercenary:SetHittable(false);  --是否可以被点击
					player:AddMercenary(Mercenary); --加到人物中
					world:AddEntity(Mercenary); --加到世界中
					Mercenary:OnUpdate(0);
					--g_i3k_ui_mgr:RefreshUI(eUIID_Battle)  --更新界面
					-- g_i3k_ui_mgr:RefreshUI(eUIID_BattleBase)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateMercenaries",g_i3k_game_context:GetFightMercenaries())
				end
			end
		end
	end
end

------------------------------------------------------------------------------------
--佣兵解散协议
function i3k_sbean.role_unsummon_pet.handler(bean, res)
	--local pets = bean.pets
	local petId = bean.petId
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			local MercenaryCount = player:GetMercenaryCount();
			if world then
				for i = 1,MercenaryCount do
					local Mercenary = player:GetMercenary(i)
					local Mguid = string.split(Mercenary._guid, "|")
					local cfgID = math.abs(petId)
					if cfgID == tonumber(Mguid[2]) then
						world:RmvEntity(Mercenary);
						player:RmvMercenary(i);
						--g_i3k_ui_mgr:RefreshUI(eUIID_Battle)
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateMercenaries",g_i3k_game_context:GetFightMercenaries())
						break;
					end
				end
			end
		end
	end
end

--销毁镖车
function i3k_sbean.destory_own_car.handler(bean)
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			local GetEscortCarCount = player:GetEscortCarCount();
			if world then
				for i = GetEscortCarCount,1, -1 do
					local EscortCar = player:GetEscortCar(i)
					world:RmvEntity(EscortCar);
					player:RmvEscortCar(i);
				end
			end
		end
	end
end

--销毁婚车
function i3k_sbean.role_weddingcar_destory.handler()
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			local marryCruise = player:GetMarryCruise();
			if world then
				local hero = i3k_game_get_player_hero()
				hero:Show(true)
				--for _,v in ipairs(marryCruise._carEntityTab) do
					--world:ReleaseEntity(v, true);
				--end
				world:RmvEntity(marryCruise);
				player:RmvMarryCruise();
				if g_i3k_ui_mgr then
					g_i3k_ui_mgr:ShowNormalUI()
					i3k_log("role_weddingcar_destory : RmvMarryCruise")
				end
				if marryCruise then
					marryCruise:DetachCamera();
				end
				player:GetHero():DetachCamera()
				player:GetHero():AttachCamera(logic:GetMainCamera());
			end
		end
	end
end

------------------------------------------------------------------------------------
--佣兵复活协议
function i3k_sbean.role_revive_pet.handler(bean)
	local Pos = bean.location.position;
	local hero = i3k_game_get_player_hero();
	if hero then
		local guid = string.split(hero._guid, "|")
		local world = i3k_game_get_world();
		if world then
			local mercenary = world:GetEntity(eET_Mercenary, bean.pet.."|"..guid[2]);
			if mercenary then
				mercenary:LockAni(false);
				if world._syncRpc then
					mercenary:OnRevive(Pos,mercenary:GetPropertyValue(ePropID_maxHP),0)
				else
					mercenary._behavior:Set(eEBRevive);
					mercenary:OnRevive(nil,0,0)
					mercenary:SetDeadState(false)
					local offX = i3k_engine_get_rnd_u(200, 400);
					local offX_S = i3k_engine_get_rnd_u(0, 1);
					if offX_S == 0 then
						offX = offX * -1;
					end

					local offZ = i3k_engine_get_rnd_u(200, 400);
					local offZ_S = i3k_engine_get_rnd_u(0, 1);
					if offZ_S == 0 then
						offZ = offZ * -1;
					end
					local hero = i3k_game_get_player_hero()
					local pos = i3k_vec3_clone(hero._curPos);
					pos.x = pos.x + offX;
					pos.z = pos.z + offZ;

					mercenary:SetPos(pos, true);
					mercenary:SetFaceDir(0, 0, 0);
					mercenary._behavior:Clear(eEBRevive);
				end
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(82,mercenary._name))
			end
		end
	end
end


----------------------------------------------------------------------------------
--镖车召唤协议
--Packet:role_escortcar
function i3k_sbean.role_escortcar.handler(bean)
	local data = bean
	local car = bean.car
	local detail = car.detail
	local curBuffs = car.curBuffs
	local state	= car.state
	local curHP = detail.curHP
	local maxHP = detail.maxHP
	local base = detail.base
	local id = base.id
	local cfgID = base.cfgID
	local ownerID = base.ownerID
	local location = base.location
	g_i3k_game_context:SetEscortCarLocation(g_i3k_game_context:GetWorldMapID(), location.position, location.rotation) --记录镖车镖车位置
	g_i3k_game_context:SetEscortCarMapInstance(g_i3k_game_context:GetCurrentLine())
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			if world then
				local SCar = require("logic/entity/i3k_escort_car");
				local guid = i3k_gen_entity_guid_new(SCar.i3k_escort_car.__cname,id);
				local EscortCar = SCar.i3k_escort_car.new(guid);
				i3k_game_register_entity_RoleID(eET_Car.."|"..id, guid);
				if EscortCar:Create(cfgID, curHP, state, maxHP, car.be_robbed_times,car.skin) then
					EscortCar:SetGroupType(eGroupType_O); -- 设置是否友好（和平，善恶，自由）
					local pos = location.position
					local rot = location.rotation
					--local curSP = curSP
					--local curHP = curHP
					EscortCar:SetFaceDir(0, 0, 0); --朝向
					EscortCar:Birth(pos);		--起始位置
					EscortCar:SetPos(pos);
					EscortCar:Show(true, true);
					EscortCar:Play(i3k_db_common.engine.defaultStandAction, -1);  	--默认执行的动作
					EscortCar:OnDamage(EscortCar, 1, EscortCar:GetPropertyValue(ePropID_hp) - curHP, false, 1, false, true, nil, false);--承受伤害
					EscortCar:UpdateBloodBar(EscortCar:GetPropertyValue(ePropID_hp) / EscortCar:GetPropertyValue(ePropID_maxHP)); --更新血条
					EscortCar:SyncRpc(world._syncRpc);
					EscortCar:AddAiComp(eAType_IDLE);
					--EscortCar:AddAiComp(eAType_MOVE);
					EscortCar:AddAiComp(eAType_FOLLOW);
					EscortCar:AddAiComp(eAType_DAMAGE_CAR);
					EscortCar:SetHittable(true);  --是否可以被点击

					BUFF = require("logic/battle/i3k_buff"); --镖车添加buff
					for i,e in ipairs(curBuffs) do
						local bcfg = i3k_db_buff[e];
						local buff = BUFF.i3k_buff.new(nil,e, bcfg, nil);
						if buff then
							EscortCar:AddBuff(nil, buff);
						end
					end

					player:AddEscortCar(EscortCar); --加到人物中
					world:AddEntity(EscortCar); --加到世界中
					g_i3k_game_context:setEscortCarblood(curHP, maxHP)
				end
			end
		end
	end
end

--开启巡游
function i3k_sbean.role_weddingcar.handler(bean)
	local id = bean.car.id
	local cfgID = bean.car.cfgID
	local location = bean.car.location
	local manID = bean.car.manID
	local womanID = bean.car.womanID
	local manName = bean.car.manName
	local womanName = bean.car.womanName
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			if world then
				local hero = i3k_game_get_player_hero()
				world:CreateMarryCruiseEntity(id, cfgID, manID, womanID, manName, womanName, location)
			end
		end
	end
end

------------------------------------------------------------------------------------
-- 冷却玩家某个技能
--Packet:role_reset_skill
function i3k_sbean.role_reset_skill.handler(bean, res)
	local skillID = bean.skillID;
	local hero = i3k_game_get_player_hero();
	if hero then
		hero:OnNetworkResetSkill(skillID)
	end
	return true;
end

------------------------------------------------------------------------------------
-- 玩家自己触发技能（服务器触发）
--Packet:role_trig_skill
function i3k_sbean.role_trig_skill.handler(bean, res)
	local skillID = bean.skillID;
	local User = nil;
	local targetID = bean.targetID
	local targetType = bean.targetType
	local ownerID = bean.ownerID
	local Target = nil
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			User = player:GetHero();
		end
	end

	if User then
		local _skill = nil;
		if Target then
			User._target = Target
			User:SetTarget(Target)
		end
		if User._skills then
			if User._skills[skillID] then
				_skill = User._skills[skillID];
				User._maunalSkill = _skill;
			else
				local scfg = i3k_db_skills[skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							table.insert(User._skills,skillID,_skill);
							User._maunalSkill = _skill;
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						table.insert(User._skills,skillID,_skill);
						User._maunalSkill = _skill;
					end
				end
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 佣兵自己触发技能（服务器触发）
--Packet:pet_trig_skill
function i3k_sbean.pet_trig_skill.handler(bean, res)
	local CfgID = bean.pid;
	local skillID = bean.skillID;
	local User = nil;
	local targetID = bean.targetID
	local targetType = bean.targetType
	local ownerID = bean.ownerID
	local Target = nil
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer();
		if player then
			for i = 1,player:GetMercenaryCount() do
				local mercenary = self._player:GetMercenary(k);
				if mercenary then
					local guid = string.split(mercenary._guid, "|")
					if tonumber(guid[2]) == CfgID then
						User = mercenary
						break;
					end
				end
			end
		end
	end

	if User then
		local _skill = nil;
		if Target then
			User._target = Target
			User:SetTarget(Target)
		end
		if User._skills then
			if User._skills[skillID] then
				_skill = User._skills[skillID];
				User._maunalSkill = _skill;
			else
				local scfg = i3k_db_skills[skillID];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
						if _skill then
							table.insert(User._skills,skillID,_skill);
							User._maunalSkill = _skill;
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[skillID];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(User, scfg, 1, 0, skill.eSG_Attack);
					if _skill then
						User._skills = {}
						table.insert(User._skills,skillID,_skill);
						User._maunalSkill = _skill;
					end
				end
			end
		end

	end
	return true;
end

------------------------------------------------------------------------------------
-- 更新PK值
--Packet:role_update_pkvalue
function i3k_sbean.role_update_pkvalue.handler(bean, res)
	local pkvalue = bean.pkValue;
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer();
		if player then
			local hero = player:GetHero()
			if hero then
				hero._PKvalue = pkvalue;
				g_i3k_game_context:SetCurrentPKValue(pkvalue)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_PKMode, "UpdatePkText", pkvalue)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
 -- 同步玩家耐久度
--Packet:role_sync_durability
function i3k_sbean.role_sync_durability.handler(bean, res)
	local wEquipID = bean.wid;
	local durability = bean.durability;
	local hero = i3k_game_get_player_hero();
	if hero then
		hero:DesEquipDurability(wEquipID,durability)
	end
	return true;
end

------------------------------------------------------------------------------------
-- 同步玩家能量
--Packet:role_sync_sp
function i3k_sbean.role_sync_sp.handler(bean, res)
	local curSP = bean.sp;
	local hero = i3k_game_get_player_hero();
	if hero then
		hero:UpdateProperty(ePropID_sp, 1, curSP, true, false,true);
	end

	return true;
end

-- 同步玩家魂语
--Packet:role_sync_soulenergy
function i3k_sbean.role_sync_soulenergy.handler(bean, res)
	local hero = i3k_game_get_player_hero();
	if hero then
		local info = i3k_db_shen_bing_unique_skill[g_i3k_game_context:GetSelectWeapon()]
		for _,v in pairs(info) do
			if v.uniqueSkillType == 17 then--魂语
				hero:UpdateSoulenergyValue(bean.soulenergy);
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步佣兵能量
--Packet:pet_sync_sp
function i3k_sbean.pet_sync_sp.handler(bean, res)
	local curSP = bean.sp;
	local world = i3k_game_get_world();
	if world then
		local hero = i3k_game_get_player_hero();
		if hero then
			local guid = string.split(hero._guid, "|")
			local entityMercenary = world:GetEntity(eET_Mercenary, bean.cfgID.."|"..guid[2]);
			if entityMercenary then
				entityMercenary:UpdateProperty(ePropID_sp, 1, curSP, true, false,true);
			end
		end
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步玩家战斗能量
--Packet:role_sync_fightSP
function i3k_sbean.role_sync_fightSP.handler(bean, res)
	local curFightSP = bean.fightSP;
	local hero = i3k_game_get_player_hero();
	if hero then
		hero:UpdateFightSp(curFightSP)
	end

	return true;
end

------------------------------------------------------------------------------------
-- 同步玩家战斗能量通过buff
--Packet:role_sync_fightSP
function i3k_sbean.role_sync_bufffightSP.handler(bean, res)
	local curFightSP = bean.fightSP;
	local hero = i3k_game_get_player_hero();
	if hero then
		hero:UpdateFightSp(curFightSP,true)
	end

	return true;
end

------------------------------------------------------------------------------------
-- 删除掉落
--Packet:drop_delete
function i3k_sbean.drop_delete.handler(bean, res)
	local nDropID = bean.dropID;
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			local ItemDrop = world._ItemDrops[nDropID]
			if ItemDrop then
				ItemDrop:Release();
				world:RmvEntity(ItemDrop);
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 掉落
--Packet:role_sync_drops
function i3k_sbean.role_sync_drops.handler(bean, res)
	local pos_x = bean.position.x;
	local pos_y = bean.position.y;
	local pos_z = bean.position.z;
	local Drops = bean.drops
	local Pos = {x = pos_x,y = pos_y,z = pos_z}
	local DropsDetail = {}
	for k,v in pairs(Drops) do
		local itemGuid = v.dropID;
		local itemItemID = v.itemID;
		local itemCount = v.itemCount;
		local args = {Gid =itemGuid,Id = itemItemID,nCount = itemCount}
		table.insert(DropsDetail,args);
	end
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			world:CreateItemDropsFromNetwork(Pos,DropsDetail);
		end
	end
	return true;
end

-- map同步神兵快速变身时间
--Packet:role_quickmotivatetime
function i3k_sbean.role_quickmotivatetime.handler(bean, res)
	local hero = i3k_game_get_player_hero();
	if hero then
		g_i3k_game_context:setPromptlyWead(true)
		hero:UpdateLastUseTime(bean.lastUseTime);
	end

	return true;
end






----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 激活神兵请求
--Packet:role_motivate_weapon
function i3k_sbean.motivate_weapon(isSPFree)
	local timeTick = i3k_game_get_logic_tick();
	local outTick = i3k_game_get_delta_tick();

	local bean = i3k_sbean.role_motivate_weapon.new()
	bean.timeTick	= i3k_sbean.TimeTick.new();
	bean.timeTick.tickLine
					= timeTick;
	bean.timeTick.outTick
					= outTick;
	bean.isSPFree   = isSPFree; 

	i3k_game_send_str_cmd(bean)
end

------------------------------------------------------------------------------------
-- 激活神兵回应
--Packet:motivate_state
function i3k_sbean.motivate_state.handler(bean)
	if bean.success == 1 then
		local hero = i3k_game_get_player_hero()
		if hero then
			hero._superMode.valid = true;
			hero:SuperMode(true);
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "stopWeaponFullAnis")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updatePKModeSkillUI")
	end
	return true;
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 上坐骑请求
function i3k_sbean.horse_ride(entity, enable, callBack)
	local data = i3k_sbean.horse_ride_req.new()
	data.entity = entity
	data.enable = enable
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "horse_ride_res")
end

function i3k_sbean.horse_ride_res.handler(bean, req)
	if bean.ok == 1 then
		if req.entity then
			req.entity:OnRideMode(req.enable)
		end
		if req.callBack then
			req.callBack()
		end
	else
		--g_i3k_ui_mgr:PopupTipMessage("上马失败")
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 下坐骑请求
function i3k_sbean.horse_unride(entity, enable, notips, callBack)
	local data = i3k_sbean.horse_unride_req.new()
	data.entity = entity
	data.enable = enable
	data.notips = notips
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "horse_unride_res")
end

function i3k_sbean.horse_unride_res.handler(bean, req)
	if bean.ok == 1 then
		local Entity = req.entity
		if Entity then
			Entity:ClearMulHorse()
			Entity:OnRideMode(req.enable, req.notips)
		end
		if req.callBack then
			req.callBack()
		end
	else
		--g_i3k_ui_mgr:PopupTipMessage("下马失败")
	end
end

-- map同步上马CD(ms)
function i3k_sbean.role_ride_cooltime.handler(bean)
	local hero = i3k_game_get_player_hero()
	if hero then
		i3k_log("role_ride_cooltime - "..bean.coolTime)
		hero:SetRideCoolTime(bean.coolTime)
	end
end
------------------------------------------------------
--多人坐骑相关
-- 同步多人坐骑信息
function i3k_sbean.role_mulhorse.handler(bean)
	local leader = bean.leader
	local members = bean.members
	local r_x = bean.rotation.x;
	local r_y = bean.rotation.y;
	local r_z = bean.rotation.z;
	local StartPos = {x = bean.position.x, y = bean.position.y, z = bean.position.z}
	local r = i3k_vec3_angle2(i3k_vec3(r_x,r_y,r_z), i3k_vec3(1, 0, 0));
	local Dir_p = {x = 0 ,y = r ,z = 0 }
	local leaderId = leader.overview.id
	
	local hero = i3k_game_get_player_hero()
	local guid = string.split(hero._guid, "|")
	local memberIDs = leader.appearance.memberIDs
	hero:SyncMulRide(leaderId, memberIDs, members)

	local logic = i3k_game_get_logic(); --改变成员视角为队长视角
	if logic then
		local world = logic:GetWorld();
		if world then
			if leaderId ~= tonumber(guid[2]) then --乘客
				local Entity = world:GetEntity(eET_Player, leaderId);
				if Entity then
					hero:RmvAiComp(eAType_MOVE)
					local mulPos = hero:GetMulPos()
					hero:DetachCamera()
					Entity:AttachCamera(logic:GetMainCamera());
					if not Entity:GetLinkEntitysByIdx(mulPos) then
						Entity:AddLinkChild(hero, mulPos, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
						Entity:EnableOccluder(true);
					end
				else
					local args = getArgsFromBean(leader.overview, leader.model, leader.title, leader.state, leader.appearance, leader.buffdrugs, nil,leader.combatType)
					world:CreatePlayerModelFromCfg(leaderId, StartPos, Dir_p, args)
					local leaderEntity = world:GetEntity(eET_Player, leaderId);
					if leaderEntity then
						hero:RmvAiComp(eAType_MOVE)
						local mulPos = hero:GetMulPos()
						hero:DetachCamera()
						leaderEntity:AttachCamera(logic:GetMainCamera());
						if not leaderEntity:GetLinkEntitysByIdx(mulPos) then
							hero:SetLeaderEntity(leaderEntity)
							leaderEntity:EnableOccluder(true);
						end
					end
					for i, e in ipairs(memberIDs) do --memberIDs
						if e ~= 0 and e ~= tonumber(guid[2]) then
							local memberEntity = world:GetEntity(eET_Player, e);
							if memberEntity then
								if not leaderEntity:GetLinkEntitysByIdx(i) then
									leaderEntity:AddLinkChild(memberEntity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
									memberEntity:EnableOccluder(true);
								end
							else
								local member = members[e]
								local args = getArgsFromBean(member.overview, member.model, member.title, member.state, member.appearance, member.buffdrugs,  nil, member.combatType)
								world:CreatePlayerModelFromCfg(e, StartPos, Dir_p, args)
								local memberEntity = world:GetEntity(eET_Player, e);
								if memberEntity then
									if not leaderEntity:GetLinkEntitysByIdx(i) then
										leaderEntity:AddLinkChild(memberEntity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
									 	memberEntity:EnableOccluder(true);
									end
								end
							end
						end
					end
				end
			else --司机
				for i, e in ipairs(memberIDs) do --memberIDs
					if e ~= 0 then
						local Entity = world:GetEntity(eET_Player, e);
						if Entity then
							if not hero:GetLinkEntitysByIdx(i) then
								hero:AddLinkChild(Entity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
								Entity:EnableOccluder(true);
							end
						else
							local member = members[e]
							local args = getArgsFromBean(member.overview, member.model, member.title, member.state, member.appearance, member.buffdrugs, nil, member.combatType)
							world:CreatePlayerModelFromCfg(e, StartPos, Dir_p, args)
							local Entity = world:GetEntity(eET_Player, e);
							if Entity then
								if not hero:GetLinkEntitysByIdx(i) then
									hero:AddLinkChild(Entity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
									Entity:EnableOccluder(true);
								end
							end
						end
					end
				end
			end
		end
	end
end

-- 离开多人坐骑
function i3k_sbean.role_leave_mulhorse.handler(bean)
	local position = bean.position
	local hero = i3k_game_get_player_hero()
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld();
		if world then
			local Entity = world:GetEntity(eET_Player, hero:GetMulLeaderId());
			if Entity then
				Entity:DetachCamera();
				if Entity:GetLinkEntitysByIdx(hero:GetMulPos()) then
					Entity:ReleaseLinkChildIdx(hero:GetMulPos())
				end
			end
		end
	end
	hero:AddAiComp(eAType_MOVE)
	hero:SetPos(position)
	hero:DetachCamera()
	hero:AttachCamera(logic:GetMainCamera());
	hero:RemoveLinkChild()
	hero:LeaveMulRide()--设置位置转换视角
	if g_i3k_game_context:GetMulHorseCallbackFunc() then
		local callFunc = g_i3k_game_context:GetMulHorseCallbackFunc()
		callFunc()
		g_i3k_game_context:SetMulHorseCallbackFunc(nil)
	end
end

-- 通知成员多人坐骑变化
function i3k_sbean.role_update_mulhorse.handler(bean)
	local index = bean.index
	local member = bean.member

	--多人坐骑成员变化后改变挂载点乘客成员信息
	local hero = i3k_game_get_player_hero()
	local leaderId = hero:GetMulLeaderId()
	hero:MulMemberChanged(index, member)
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			local leaderEntity = world:GetEntity(eET_Player, leaderId);
			if member then
				local memberId = member.overview.id
				local memberEntity = world:GetEntity(eET_Player, memberId);
				if memberEntity then
					if not leaderEntity:GetLinkEntitysByIdx(index) then
						leaderEntity:AddLinkChild(memberEntity, index, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
						memberEntity:EnableOccluder(true);
						world:RmvEntity(memberEntity);
					end
				end
			else
				local entitys = leaderEntity:GetLinkEntitys();
				local passenger = entitys[index]
				if passenger then
					passenger:RemoveLinkChild()
					passenger:EnableOccluder(false);
					leaderEntity:ReleaseLinkChildIdx(index)
					world:AddEntity(passenger);
				end
			end
		end
	end
end

------------------------------------------------------
-- 批量查询周围玩家回应
--Packet:roles_detail
function i3k_sbean.roles_detail.handler(bean, res)
	local roles = bean.roledetails
	local world = i3k_game_get_world()
	if world then
		for k,v in pairs(roles) do
			local horseMembers = v.members
			local overview = v.detail.overview
			local model = v.detail.model
			local title = v.detail.title
			local state = v.detail.state
			local appearance = v.detail.appearance
			local mulRoleType = appearance.mulRoleType
			local buffDrugs = v.detail.buffdrugs
			local petAlter = v.detail.petAlter
			local combatType = v.detail.combatType
			--overview
			local RoleID = overview.id
			local horseMemberIDs = appearance.memberIDs
			--通过类型判断是否是敌方
			local hero = i3k_game_get_player_hero()
			--g_i3k_game_context:setForceWarMemberInfo(RoleID, overview.bwType)---设置势力战成员数据
			local logic = i3k_game_get_logic();
			local args = getArgsFromBean(overview, model, title, state, appearance, buffDrugs, petAlter, combatType)
			local Driver = world:GetEntity(eET_Player, RoleID);
			local springFunc = function(actType)
				if RoleID ~= hero:GetHugLeaderId() and Driver then
					if not Driver._title then
						world:UpdateModelFromNetwork(RoleID, eET_Player, overview.type, args);
					end
					Driver:SetSpringDoubleAct(actType)
					for i, e in pairs(horseMembers) do
						local mOverview = e.overview
						local memberID = mOverview.id
						local memberArgs = getArgsFromBean(mOverview, e.model, e.title, e.state, e.appearance, e.buffdrugs, nil, e.combatType)
						local leaderEntity = world:GetEntity(eET_Player, RoleID);
						if leaderEntity then
							local memberEntity = world:GetEntity(eET_Player, memberID);
							if not memberEntity then
								world:CreatePlayerModelFromCfg(memberID, leaderEntity._curPos, leaderEntity._faceDir, memberArgs)
							end
							local member = world:GetEntity(eET_Player, memberID);
							if member then
								local mulPos
								for a, b in pairs(appearance.memberIDs) do
									if b == memberID then
										mulPos = a
										break
									end
								end
								if not leaderEntity:GetLinkEntitysByIdx(mulPos) then
									leaderEntity:AddLinkChild(member, mulPos, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
								end
							end
						end
					end
				end
			end
			if table.nums(horseMembers) > 0 and mulRoleType == g_HORSE_ROLE_TYPE then
				if RoleID ~= hero:GetMulLeaderId() and Driver then
					if not Driver._title then
						world:UpdateModelFromNetwork(RoleID, eET_Player, overview.type, args);
					end
					for i, e in pairs(horseMembers) do
						local mOverview = e.overview
						local memberID = mOverview.id
						local memberArgs = getArgsFromBean(mOverview, e.model, e.title, e.state, e.appearance, e.buffdrugs, nil, e.combatType)
						local leaderEntity = world:GetEntity(eET_Player, RoleID);
						if leaderEntity then
							local memberEntity = world:GetEntity(eET_Player, memberID);
							if not memberEntity then
								world:CreatePlayerModelFromCfg(memberID, leaderEntity._curPos, leaderEntity._faceDir, memberArgs)
							end
							local member = world:GetEntity(eET_Player, memberID);
							if member then
								local mulPos
								for a, b in pairs(appearance.memberIDs) do
									if b == memberID then
										mulPos = a
										break
									end
								end
								if not leaderEntity:GetLinkEntitysByIdx(mulPos) then
									leaderEntity:AddLinkChild(member, mulPos, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
								end
							end
							leaderEntity:UpdateMemberPos(leaderEntity._curPos)
						end
					end
				end
			elseif mulRoleType == g_HUG_ROLE_TYPE then
				if RoleID ~= hero:GetHugLeaderId() and Driver then
					if not Driver._title then
						world:UpdateModelFromNetwork(RoleID, eET_Player, overview.type, args);
					end
					for _, e in pairs(horseMembers) do
						local mOverview = e.overview
						local memberID = mOverview.id
						local memberArgs = getArgsFromBean(mOverview, e.model, e.title, e.state, e.appearance, e.buffdrugs, nil, e.combatType)
						local leaderEntity = world:GetEntity(eET_Player, RoleID);
						if leaderEntity then
							local memberEntity = world:GetEntity(eET_Player, memberID);
							if not memberEntity then
								world:CreatePlayerModelFromCfg(memberID, leaderEntity._curPos, leaderEntity._faceDir, memberArgs)
							end
							local member = world:GetEntity(eET_Player,memberID);
							if member then
								if not leaderEntity._linkHugChild then
									leaderEntity:SyncHugMode(RoleID, e)
									leaderEntity:AddHugLinkChild(member)
								end
							end
						end
					end
				end
			elseif table.nums(horseMembers) > 0 and mulRoleType == g_SPRING_WATER_TYPE then --水
				springFunc(g_SPRING_WATER_TYPE)
			elseif table.nums(horseMembers) > 0 and mulRoleType == g_SPRING_LAND_TYPE then --陆地
				springFunc(g_SPRING_LAND_TYPE)
			else
				if not hero:VerifyMulMember(RoleID) and not hero:VerifyHugMember(RoleID) then
					local entityPlayer = world:GetEntity(eET_Player, RoleID);
					if entityPlayer then
						addCreateNetEntityCreatTask(world, i3k_game_on_entity_guid(eET_Player.."|"..RoleID), RoleID, eET_Player, overview.type, args)
					end
				end
			end
		end
	end
	
	return true;
end

------------------------------------------------------
-- 批量查询周围佣兵信息回应
function i3k_sbean.pets_detail.handler(bean, res)
	local pets = bean.petdetails
	for k,v in pairs(pets) do
		local RoleID = v.ownerID
		local overview = v.profile
		local state = v.state
		local petGuardIsShow = v.petGuardIsShow
		local curPetGuard = v.curPetGuard
		local nCurHP = state.curHp
		local nMaxHP = state.maxHp
		local petBuffs = state.buffs

		local CfgID = overview.id
		local nLevel = overview.level
		RoleID = CfgID.."|"..RoleID
		CfgID = math.abs(CfgID)
		local logic = i3k_game_get_logic();
		local args = {
			nLevel = nLevel,
			Buffs = petBuffs,
			curHP = nCurHP,
			maxHP = nMaxHP,
			ownerID = v.ownerID,
			awakeUse = overview.awakeUse,
			petName = overview.name,
			petGuardIsShow = petGuardIsShow,
			curPetGuard = curPetGuard,
		};
		local world = i3k_game_get_world()
		if world then
			local entityMercenary = world:GetEntity(eET_Mercenary, RoleID);
			if entityMercenary then
				addCreateNetEntityCreatTask(world, i3k_game_on_entity_guid(eET_Mercenary.."|"..RoleID), RoleID, eET_Mercenary, CfgID, args)
			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- 拾取掉落请求
--Packet:role_pickup_drops
function i3k_sbean.pickup_drops(drops)
	local bean = i3k_sbean.role_pickup_drops.new()
	bean.drops = drops
	i3k_game_send_str_cmd(bean)
end

-- 拾取掉落回应
--Packet:role_pickup_add
function i3k_sbean.role_pickup_add.handler(bean, res)
	if bean.drops then
		local logic = i3k_game_get_logic()
		if logic then
			local world = logic:GetWorld()
			if world then
				local player = i3k_game_get_player()
				for k,v in pairs(bean.drops) do
					updateCreateNetEntityTask(k, eET_ItemDrop);
					local ItemDrop = world._ItemDrops[k]
					if ItemDrop then
						ItemDrop:Fly();
						
						local mapty = 
						{
							[g_FIELD] = true,
							[g_FACTION_TEAM_DUNGEON] = true,
							[g_ANNUNCIATE] = true,
							[g_DESERT_BATTLE] = true,
							[g_SPY_STORY]    = true,
						}
						
						if mapty[world._mapType] then
							if player._pickup.cacheItems and player._pickup.cacheItems[ItemDrop._itemId] then
								player._pickup.cacheItems[ItemDrop._itemId] = player._pickup.cacheItems[ItemDrop._itemId] - ItemDrop._count
								if player._pickup.cacheItems[ItemDrop._itemId] == 0 then
									player._pickup.cacheItems[ItemDrop._itemId] = nil
								end
							end
						end
					end
				end

			end
		end
	end
	return true;
end

------------------------------------------------------------------------------------
-- 拾取场景BUFF回应
--Packet:role_mapbuff_add
function i3k_sbean.role_mapbuff_add.handler(bean, res)
	local nflag = bean.success;
	local nMapBuffID = bean.mapBuffID;
	if nflag == 1 then
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				local MapBuff = world._mapbuffs[nMapBuffID]
				if MapBuff and MapBuff._create and MapBuff:GetStatus() == 2 then --等待状态才能飞
					MapBuff:Fly();
				else
					g_i3k_game_context:AddMapBuffFlagInPracticeGate(nMapBuffID)
				end
			end
		end
	end
	return true;
end
------------------------------------------------------------------------------------

-- 快速冷却玩家某个技能（减少CD时间）
--Packet:role_quickcool_skill
function i3k_sbean.role_quickcool_skill.handler(bean, res)
	local skillID = bean.skillID;
	local coolTime = bean.time
	local hero = i3k_game_get_player_hero();
	if hero then
		hero:OnNetworkDesSkillCoolTime(skillID,coolTime)
	end
	return true;
end

------------------------------------------------------------------------------------
-- 冷却佣兵某个技能
--Packet:pet_reset_skill
function i3k_sbean.pet_reset_skill.handler(bean, res)
	local CfgID = bean.pid
	local skillID = bean.skillID
	local coolTime = bean.time
	local hero = i3k_game_get_player_hero();
	local world = i3k_game_get_world();
	if hero and world then
		local guid = string.split(hero._guid, "|")
		local entityMercenary = world:GetEntity(eET_Mercenary, CfgID.."|"..tonumber(guid[2]));
		if entityMercenary then
			local skill = entityMercenary._skills[skillID];
			if skill then
				skill:DesCoolTime(coolTime);
			end
		end
	end
	return true;
end

-- 相依相偎
function i3k_sbean.role_staywith.handler(bean)
	local leader = bean.leader
	local member = bean.member
	local r_x = bean.rotation.x;
	local r_y = bean.rotation.y;
	local r_z = bean.rotation.z;
	local StartPos = {x = bean.position.x, y = bean.position.y, z = bean.position.z}
	local r = i3k_vec3_angle2(i3k_vec3(r_x,r_y,r_z), i3k_vec3(1, 0, 0));
	local Dir_p = {x = 0 ,y = r ,z = 0 }
	local leaderId = leader.overview.id
	local hero = i3k_game_get_player_hero()
	hero:SyncHugMode(leaderId, member)

	local logic = i3k_game_get_logic(); --改变成员视角为队长视角
	if logic then
		local world = logic:GetWorld();
		if world then
			if leaderId ~= g_i3k_game_context:GetRoleId() then --乘客
				local Entity = world:GetEntity(eET_Player, leaderId);
				if Entity and not Entity._linkHugChild then
					hero:RmvAiComp(eAType_MOVE)
					hero:DetachCamera()
					Entity:AttachCamera(logic:GetMainCamera())
					Entity:SyncHugMode(leaderId, member)
					Entity:AddHugLinkChild(hero)
					Entity:EnableOccluder(true)
				else
					local args = getArgsFromBean(leader.overview, leader.model, leader.title, leader.state, leader.appearance, leader.buffdrugs, nil, leader.combatType)
					world:CreatePlayerModelFromCfg(leaderId, StartPos, Dir_p, args)
					local leaderEntity = world:GetEntity(eET_Player, leaderId);
					if leaderEntity and not leaderEntity._linkHugChild then
						hero:RmvAiComp(eAType_MOVE)
						hero:DetachCamera()
						leaderEntity:AttachCamera(logic:GetMainCamera())
						leaderEntity:SyncHugMode(leaderId, member)
						leaderEntity:AddHugLinkChild(hero)
						leaderEntity:EnableOccluder(true)
					end
				end
			else --司机
				if member then
				local memeberId = member.overview.id
				if memeberId ~= 0 then
					local Entity = world:GetEntity(eET_Player, memeberId);
					if Entity and not hero._linkHugChild then
						hero:AddHugLinkChild(Entity)
						Entity:EnableOccluder(true)
					else
							local args = getArgsFromBean(member.overview, member.model, member.title, member.state, member.appearance, member.buffdrugs, nil, member.combatType)
						world:CreatePlayerModelFromCfg(memeberId, StartPos, Dir_p, args)
						local memberEntity = world:GetEntity(eET_Player, memeberId);
						if memberEntity and not hero._linkHugChild then
							hero:AddHugLinkChild(memberEntity)
							memberEntity:EnableOccluder(true)
							world:RmvEntity(memberEntity)
							end
						end
					end
				end
			end
		end
	end
end

-- 解散相依相偎
function i3k_sbean.role_dissolve_staywith.handler(bean)
	local hero = i3k_game_get_player_hero()
	hero:ClearHug()
	hero:LeaveHugMode()
end

-- 双倍掉落冒字
function i3k_sbean.role_double_drop.handler(bean)
	local hero = i3k_game_get_player_hero()
	hero:ShowInfo(hero, eEffectID_ExSkill.style,  i3k_get_string(768), i3k_db_common.engine.durNumberEffect[2] / 1000);
end

--温泉双人动作
function i3k_sbean.role_doubleAct.handler(bean)
	local actType = bean.actType
	local leader = bean.leader
	local member = bean.member
	local r_x = bean.rotation.x;
	local r_y = bean.rotation.y;
	local r_z = bean.rotation.z;
	local StartPos = {x = bean.position.x, y = bean.position.y, z = bean.position.z}
	local r = i3k_vec3_angle2(i3k_vec3(r_x,r_y,r_z), i3k_vec3(1, 0, 0));
	local Dir_p = {x = 0 ,y = r ,z = 0 }

	local leaderId = leader.overview.id
	local hero = i3k_game_get_player_hero()
	local guid = string.split(hero._guid, "|")
	local memberIDs = {}
	local members = {}
	local memeberId = member.overview.id
	table.insert(memberIDs, memeberId)
	members[memeberId] = member
	hero:SyncMulRide(leaderId, memberIDs, members)
	hero:RmvAiComp(eAType_MOVE)
	hero:SetSpringDoubleType(actType)
	local logic = i3k_game_get_logic(); --改变成员视角为队长视角
	if logic then
		local world = logic:GetWorld();
		if world then
			if leaderId ~= tonumber(guid[2]) then --乘客				
				local Entity = world:GetEntity(eET_Player, leaderId);
				if Entity then
					Entity:SetSpringDoubleAct(actType)
					local mulPos = hero:GetMulPos()
					hero:DetachCamera()
					Entity:AttachCamera(logic:GetMainCamera());
					if not Entity:GetLinkEntitysByIdx(mulPos) then
						Entity:AddLinkChild(hero, mulPos, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
						Entity:EnableOccluder(true);
					end
				else
					local args = getArgsFromBean(leader.overview, leader.model, leader.title, leader.state, leader.appearance, leader.buffdrugs, nil, leader.combatType)
					world:CreatePlayerModelFromCfg(leaderId, StartPos, Dir_p, args)
					local leaderEntity = world:GetEntity(eET_Player, leaderId);
					if leaderEntity then
						local mulPos = hero:GetMulPos()
						hero:DetachCamera()
						leaderEntity:AttachCamera(logic:GetMainCamera());
						if not leaderEntity:GetLinkEntitysByIdx(mulPos) then
							hero:SetLeaderEntity(leaderEntity)
							leaderEntity:EnableOccluder(true);
						end
					end
					for i, e in ipairs(memberIDs) do --memberIDs
						if e ~= 0 and e ~= tonumber(guid[2]) then
							local memberEntity = world:GetEntity(eET_Player, e);
							if memberEntity then
								if not leaderEntity:GetLinkEntitysByIdx(i) then
									leaderEntity:AddLinkChild(memberEntity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
									memberEntity:EnableOccluder(true);
								end
							else
								local member = members[e]
								local args = getArgsFromBean(member.overview, member.model, member.title, member.state, member.appearance, member.buffdrugs, nil, member.combatType)
								world:CreatePlayerModelFromCfg(e, StartPos, Dir_p, args)
								local memberEntity = world:GetEntity(eET_Player, e);
								if memberEntity then
									if not leaderEntity:GetLinkEntitysByIdx(i) then
										leaderEntity:AddLinkChild(memberEntity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
									 	memberEntity:EnableOccluder(true);
									end
								end
							end
						end
					end
				end
			else --司机
				hero:SetSpringDoubleAct(actType)
				for i, e in ipairs(memberIDs) do --memberIDs
					if e ~= 0 then
						local Entity = world:GetEntity(eET_Player, e);
						if Entity then
							if not hero:GetLinkEntitysByIdx(i) then
								hero:AddLinkChild(Entity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
								Entity:EnableOccluder(true);
							end
						else
							local member = members[e]
							local args = getArgsFromBean(member.overview, member.model, member.title, member.state, member.appearance, member.buffdrugs, nil, member.combatType)
							world:CreatePlayerModelFromCfg(e, StartPos, Dir_p, args)
							local Entity = world:GetEntity(eET_Player, e);
							if Entity then
								if not hero:GetLinkEntitysByIdx(i) then
									hero:AddLinkChild(Entity, i, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
									Entity:EnableOccluder(true);
								end
							end
						end
					end
				end
			end
		end
	end
end

-- 解散温泉双人动作
function i3k_sbean.role_dissolve_doubleAct.handler()
	local hero = i3k_game_get_player_hero()
	hero:SetSpringDoubleType(0)
	if g_i3k_game_context:GetMulIsLeader() then
		hero:ClearMulHorse()
		hero:OnRideMode(false, true)
	else
		local logic = i3k_game_get_logic()
		if logic then
			local world = logic:GetWorld();
			if world then
				local Entity = world:GetEntity(eET_Player, hero:GetMulLeaderId());
				if Entity then
					hero:SetPos(Entity._curPos)
					Entity:ClearMulHorse()
					Entity:OnRideMode(false)
					Entity:DetachCamera();
					if Entity:GetLinkEntitysByIdx(hero:GetMulPos()) then
						Entity:ReleaseLinkChildIdx(hero:GetMulPos())
					end
				end
			end
		end
		hero:DetachCamera()
		hero:AttachCamera(logic:GetMainCamera());
		hero:RemoveLinkChild()
		hero:LeaveMulRide()--设置位置转换视角
	end
	hero:AddAiComp(eAType_MOVE)
end

-- 广播周围玩家双人动作
function i3k_sbean.nearby_role_doubleAct.handler(bean)
	local member = bean.member
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		local memberEntity = world:GetEntity(eET_Player, member.overview.id);
		if Entity and memberEntity then
			Entity:SetSpringDoubleAct(bean.actType)
			Entity:AddLinkChild(memberEntity, 1, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
			world:RmvEntity(memberEntity, true);
		end
	end
end

-- 广播周围玩家解散双人动作
function i3k_sbean.nearby_dissolve_doubleAct.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local Entity = world:GetEntity(eET_Player, bean.rid);
		if Entity then
			local entitys = Entity:GetLinkEntitys()
			local passenger = entitys[1] --温泉被邀请者为1
			if passenger then
				passenger:RemoveLinkChild()
				Entity:ReleaseLinkChildIdx(index)
				--world:AddEntity(passenger);
			end
			Entity:ClearOtherMulHorse()
			Entity:OnRideMode(false)
		end
	end
end

return {
	getArgsFromBean = getArgsFromBean
}

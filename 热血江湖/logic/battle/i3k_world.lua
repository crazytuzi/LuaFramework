----------------------------------------------------------------
module(..., package.seeall)

local require = require;

require("i3k_global");
require("logic/battle/i3k_world_grid");
require("logic/battle/i3k_collision");

local frame_task_mgr = require("i3k_frame_task_mgr")

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
	[ 3] = function(tbl) -- 随机
		local clone = { };
		for k, v in pairs(tbl) do
			clone[k] = v;
		end

		local range = table.maxn(tbl);
		for k, v in pairs(tbl) do
			local idx = i3k_engine_get_rnd_u(1, range);

			tbl[k] = table.remove(clone, idx);

			range = range - 1;
		end
	end,
}

local i3k_capture_players = { };
local furnitureTypeInfo =
{
	[g_HOUSE_FLOOR_FURNITURE] = {entityNum = eET_Furniture, furnitureId = "furnitureId"},
	[g_HOUSE_WALL_FURNITURE] = {entityNum = eET_WallFurniture, furnitureId = "id"},
	[g_HOUSE_HANG_FURNITURE] = {entityNum = nil, furnitureId = ""},
	[g_HOUSE_CARPET_FURNITURE] = {entityNum = eET_CarpetFurniture, furnitureId = "furnitureId"},
}
------------------------------------------------------
i3k_world = i3k_class("i3k_world")

local SearchDistance = 1000;
local RemoveTime = 10;
local MapGuideRefreshTime = 500
local MapTimeRefreshTime = 1000
local EntityNum = 0;
local SectDestinyRefreshTime = 5000 --帮派驻地龙运柱子刷新时间

function i3k_world:ctor()
	self._syncRpc	= true;
	self._timeLine	= 0;
	self._startTime = 0;
	self._synctick	= 0;
	self._grid_mgr	= i3k_grid_mgr.new(self);
	self._entities	= { [eGroupType_O] = { }, [eGroupType_E] = { }, [eGroupType_N] = { } };
	self._ItemDrops = { };
	self._ItemCrops = { }; -- 家园植物地块
	self._ResourcePoints	= { };
	self._TransferPoints	= { };
	self._Traps		= { };
	self._mapbuffs	= { };
	self._SkillEntitys = {};
	self._CacheEntitys = {};
	self._soundID	= -1;
	self._showGuide = false;
	self._mapguidetimeLine = 0;
	self._mapguideDeny = 0;
	self._updatePlayerList = {};
	self._sceneAni = {bossbegin = false,bossend = false ,scenebegin = false}
	self._passengers = {} 	--记录周围乘客entity
	self._embracers	= {} 	--记录被拥抱者
	self._specialMonsters = {}
	self._showPlayer = {} --玩家显示组
	self._isShowPlayerChanged = true --是否有所改变
	self._sectDestinyTimeLine = 0
	self._randomTime = nil --随机地鼠出现时间间隔
	self._randomDiglettTime = 0
	self._isHitDiglettWorld = false --是否是打地鼠地图
	self._furnitureList = {} --房屋家具
	self._floorEntitys = {}
	self._floorFurniture = {}
	self._floors = {} --房屋地板状态存储
	self._furnitureGid = 1 --家园房屋家具的gid
	self._curChooseFurniture = {} --当前选中的家具
	self._curMoveFurniture = nil --当前正在移动的家具guid
	self._wallFurniture = {} --墙面家具
	self._commonEntitys = {}
	self._houseSkin = {} --房屋皮肤
	self._carpetFurniture = {} --地毯家具
	-- 决战荒漠
	self._desertShrinkRing = false -- 是否正在缩圈
	self._desertSafeInfo = {pos = {}, radius = 0} -- 安全区
	self._disposableNpcs = {} --寻路npc
	self._danceNpcs = nil
	self._catchSpirit = {} --驭灵副本雕像
	self._ghostFragment = {}
	self._ghostFragmentCount = 1
end

function i3k_world:Create(id)
	local cfg = i3k_db_world[id];
	if not cfg then
		return false;
	end

	return self:CreateFromCfg(cfg);
end

function i3k_world:CreateFromCfg(cfg)
	if not cfg then
		return false;
	end

	self._cfg = cfg;

	local mcfg = i3k_db_combat_maps[cfg.mapID];
	if not mcfg then
		return false;
	end

	-- TODO 检测分包
	if not i3k_check_resources_byID(cfg.mapID) then
		local callback = function ()
			g_i3k_game_handler:ReturnInitView(false)
		end
		local msg = "游戏资源未下载完成，点击确定返回登入介面"
		g_i3k_ui_mgr:ShowMessageBox1(msg, callback)
		return
	end

	local maxTime = self:GetWorldMaxTime()
	self._maxTime	= maxTime
	self._timeLine	= 0;
	self._mapguidetimeLine = 0;
	self._synctick = 0;

	local logic = i3k_game_get_logic();

	self._mainCamera = logic:GetMainCamera();

	-- add self to list
	self:OnPlayerEnterWorld(logic:GetPlayer());

	local loadCB = function()
		self:OnMapLoaded();
	end
	logic:LoadMap(mcfg.path, Engine.SVector3(0.0, 10.0, -10.0):ToEngine(), cfg.mapCfg, loadCB);

	self:PlayBGM()

	return true;
end

function i3k_world:setMaxTime(time)
	self._maxTime = time
end

function i3k_world:PlayBGM()
	local sound = i3k_db_sound[self._soundID];
	if sound then
		i3k_game_play_bgm(sound.path, 1);
	end
end

function i3k_world:SetStartTime(tm)
	self._startTime = tm
end

function i3k_world:GetStartTime()
	return self._startTime
end

function i3k_world:GetWorldMaxTime()
	local maxTime = -1
	if self._cfg.openType == g_BASE_DUNGEON then
		maxTime =  i3k_db_new_dungeon[self._cfg.id].maxTime
	elseif self._cfg.openType == g_FACTION_DUNGEON then
		maxTime = i3k_db_faction_dungeon[self._cfg.id].maxTime
	elseif self._cfg.openType == g_ARENA_SOLO then
		maxTime = i3k_db_arena.arenaCfg.arenaMaxTime
	elseif self._cfg.openType == g_ACTIVITY then
		maxTime = i3k_db_activity_cfg[self._cfg.id].maxTime
	elseif self._cfg.openType == g_CLAN_ENCOUNTER then
		maxTime = i3k_db_clan_task_args.task.battle_time
	elseif self._cfg.openType == g_CLAN_MINE then
		maxTime = i3k_db_clan_mine_args.rob_mine.rob_mine_battle_time
	elseif self._cfg.openType == g_CLAN_BATTLE_WAR then
		--maxTime = i3k_db_clan.clan_war_args.battle_time
	elseif self._cfg.openType == g_FACTION_TEAM_DUNGEON then
		maxTime = i3k_db_faction_team_dungeon[self._cfg.id].maxTime
	elseif self._cfg.openType == g_TOURNAMENT then
		for i,v in ipairs(i3k_db_tournament) do
			if v.mapId==self._cfg.id then
				maxTime = v.maxTime
				break
			end
		end
	elseif self._cfg.openType == g_TAOIST then
		maxTime = i3k_db_taoist.maxTime
	elseif self._cfg.openType == g_TOWER then--爬塔
		maxTime = i3k_db_climbing_tower_fb[self._cfg.id].maxTime

	elseif self._cfg.openType == g_FORCE_WAR then --势力战
		maxTime = g_i3k_db.i3k_db_get_forcewar_max_time(self._cfg.id)
	elseif self._cfg.openType == g_WEAPON_NPC then--天隙
		maxTime = i3k_db_weapon_npc[self._cfg.id].maxtime
	elseif self._cfg.openType == g_DEMON_HOLE then
		maxTime = g_i3k_db.i3k_db_get_activity_max_time(i3k_db_demonhole_base.openTimes)
	elseif self._cfg.openType == g_RIGHTHEART then--正义之心
		maxTime = i3k_db_rightHeart2[self._cfg.id].maxTime
	elseif self._cfg.openType == g_ANNUNCIATE then
		g_i3k_game_context:SetAnnunciateActIdfromMapID(self._cfg.id)
		--self:SetStartTime(i3k_game_get_time())
		maxTime = g_i3k_game_context:getAnnunciateMaxTime()
	elseif self._cfg.openType == g_FIGHT_NPC then
		maxTime = i3k_db_fight_npc_fb[self._cfg.id].maxTime
	elseif self._cfg.openType == g_DEFEND_TOWER then
		maxTime = i3k_db_defend_fb[self._cfg.id].maxTime
	elseif self._cfg.openType == g_FACTION_WAR then
		maxTime = i3k_db_factionFight_dungon[self._cfg.id].maxTime
	elseif self._cfg.openType == g_QIECUO then
		maxTime = i3k_db_qieCuo_dungon[self._cfg.id].maxTime
	elseif self._cfg.openType == g_Pet_Waken then
		maxTime = i3k_db_pet_awken[self._cfg.id].maxTime
	elseif self._cfg.openType == g_BUDO then
		maxTime = i3k_db_fight_team_fb[self._cfg.id].maxTime
	elseif self._cfg.openType == g_GLOBAL_PVE then
		maxTime = i3k_db_crossRealmPVE_fb[self._cfg.id].maxTime
	elseif self._cfg.openType == g_SPIRIT_BOSS then
		maxTime = g_i3k_db.i3k_db_get_activity_max_time(i3k_db_spirit_boss.common.openTime)
	elseif self._cfg.openType == g_DEFENCE_WAR then -- 城战
		maxTime = i3k_db_defenceWar_cfg.fightTotalTime
	elseif self._cfg.openType == g_ILLUSORY_DUNGEON then
		maxTime = i3k_db_illusory_dungeon[self._cfg.id].maxTime
	elseif self._cfg.openType == g_PET_ACTIVITY_DUNGEON then
		maxTime = i3k_db_PetDungeonBase.lifeTime
	elseif self._cfg.openType == g_DESERT_BATTLE then
		maxTime = i3k_db_desert_battle_base.maxLife
	elseif self._cfg.openType == g_DOOR_XIULIAN then
		maxTime = i3k_db_dungeon_practice_door[self._cfg.id].duration
	elseif self._cfg.openType == g_MAZE_BATTLE then
		maxTime = g_i3k_db.i3k_db_get_activity_max_time(i3k_db_maze_battle.openTime)
	elseif self._cfg.openType == g_AT_ANY_MOMENT_DUNGEON then
		maxTime = i3k_db_at_any_moment[self._cfg.id].lastTime
	elseif self._cfg.openType == g_PRINCESS_MARRY then
		maxTime = i3k_db_princess_Config[self._cfg.id].maxTime
	elseif self._cfg.openType == g_MAGIC_MACHINE then
		maxTime = i3k_db_magic_machine.maxTime
	elseif self._cfg.openType == g_HOMELAND_GUARD then--家园保卫战
		maxTime = i3k_db_homeland_guard_base[self._cfg.id].maxTime
	elseif self._cfg.openType == g_FIVE_ELEMENTS then
		maxTime = g_i3k_db.i3k_db_get_five_element_time(self._cfg.id)
	elseif self._cfg.openType == g_LONGEVITY_PAVILION then
		maxTime = i3k_db_longevity_pavilion_dugeon_cfg[self._cfg.id].maxTime
	elseif self._cfg.openType == g_SPY_STORY then
		maxTime = i3k_db_spy_story_base.maxTime
	end
	return maxTime;
end

function i3k_world:CreateOnlyGuid(cfgID, nType,RoleID)
	local Guid = nil;
	if cfgID and EntityNum and EntityNum < 1000 then
		EntityNum = EntityNum + 1;
	else
		EntityNum = 0;
	end

	if nType == eET_Mercenary then
		Guid = i3k_gen_entity_guid_new(i3k_gen_entity_cname(nType),cfgID.."|"..RoleID).."|"..EntityNum;
		i3k_game_register_entity_RoleID(nType.."|"..cfgID.."|"..RoleID, Guid);
	else
		Guid = i3k_gen_entity_guid_new(i3k_gen_entity_cname(nType),RoleID).."|"..EntityNum;
		i3k_game_register_entity_RoleID(nType.."|"..RoleID, Guid);
	end

	if Guid then
		return Guid;
	end
end

function i3k_world:CreateModelFromNetwork(RoleID,nType,_pos,Dir,forceType,curHP,maxHP,configID, name, state, curBuffs,teamID,sectID, bwType, posId, isDead, carSkin, firstCreate, clickNum)
	local Pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos))));
	if nType == eET_Player then
		local entityPlayer = self:GetEntity(eET_Player, RoleID);
		if not entityPlayer then
			local SEntity = require("logic/entity/i3k_entity_net");
			local Guid = self:CreateOnlyGuid(1, nType, RoleID);
			local entityPlayer = SEntity.i3k_entity_net.new(Guid);
			local cfg = g_i3k_db.i3k_db_get_general(1);
			if entityPlayer:CreatePreRes(eET_Player,cfg) then
				if maxHP and curHP then
					entityPlayer:UpdateProperty(ePropID_maxHP, 1,maxHP, true, false,true);
					entityPlayer:UpdateHP(curHP);
					entityPlayer:UpdateBloodBar(entityPlayer:GetPropertyValue(ePropID_hp) / entityPlayer:GetPropertyValue(ePropID_maxHP));
				end

				if isDead == 1 then
					entityPlayer:SyncDead(nil, nil);
				end

				entityPlayer:NeedUpdateAlives(false);
				entityPlayer:SetFaceDir(Dir.x, Dir.y, Dir.z);
				entityPlayer:SetBWType(bwType);
				entityPlayer:SetForceType(forceType);
				entityPlayer:SetPos(Pos);
				entityPlayer:SetGroupType(eGroupType_O);
				entityPlayer:SetHittable(true);
				entityPlayer:Show(not self._isFilter, true, 100);
				entityPlayer:SetCtrlType(eCtrlType_NetWork);
				entityPlayer._sectID = sectID
				self:AddEntity(entityPlayer);
			end
		end
	elseif nType == eET_Monster then
		local entityMonster = self:GetEntity(eET_Monster, RoleID);
		if not entityMonster then
			local SEntity = require("logic/entity/i3k_entity_net");
			local cfgID = math.abs(configID)
			local cfg = i3k_db_monsters[cfgID];
			Pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos)), g_i3k_db.i3k_db_get_detection_block_range(cfg)));
			local Guid = self:CreateOnlyGuid(cfgID, nType, RoleID);
			local monster = SEntity.i3k_entity_net.new(Guid);
			if monster:CreatePreRes(eET_Monster,cfg) then
				if maxHP and curHP then
					monster:UpdateProperty(ePropID_maxHP, 1,maxHP, true, false,true);
					monster:UpdateHP(curHP);
				end
				if isDead == 1 then
					monster:SyncDead(nil, nil);
				end
				monster:NeedUpdateAlives(false);
				monster:SetPos(Pos);
				monster:SetGroupType(eGroupType_E);
				monster:SetFaceDir(Dir.x, Dir.y, Dir.z);
				monster:SetBWType(bwType);
				monster:SetForceType(forceType);
				monster:setCanClickCount(clickNum);
				monster._entityres = false;
				monster._sectID	 = sectID
				monster._firstCreate = firstCreate
				self:AddEntity(monster);
			end
		end
	elseif nType == eET_Mercenary then
		local entityMercenary = self:GetEntity(eET_Mercenary, configID.."|"..RoleID);
		if not entityMercenary then
			local SMercenary = require("logic/entity/i3k_entity_net");
			local Guid = self:CreateOnlyGuid(configID, nType, RoleID);
			local entityMercenary = SMercenary.i3k_entity_net.new(Guid);
			local cfgID = math.abs(configID)
			local cfg = i3k_db_mercenaries[cfgID];
			if entityMercenary:CreatePreRes(eET_Mercenary,cfg) then
				if maxHP and curHP then
					entityMercenary:UpdateProperty(ePropID_maxHP, 1,maxHP, true, false,true);
					entityMercenary:UpdateHP(curHP);
					entityMercenary:UpdateBloodBar(entityMercenary:GetPropertyValue(ePropID_hp) / entityMercenary:GetPropertyValue(ePropID_maxHP));
				end
				if isDead == 1 then
					entityMercenary:SyncDead(nil, nil);
				end
				entityMercenary:SetBWType(bwType)
				entityMercenary:SetForceType(forceType);
				entityMercenary:SetPosId(posId or 0)
				entityMercenary:NeedUpdateAlives(false);
				entityMercenary:SetFaceDir(Dir.x, Dir.y, Dir.z);
				entityMercenary:SetPos(Pos);
				entityMercenary:SetCtrlType(eCtrlType_NetWork);
				entityMercenary:Show(not self._isFilter, true, 100)
				entityMercenary:SetGroupType(eGroupType_O);
				entityMercenary:SetHittable(false)
				self:AddEntity(entityMercenary);
			end
		end
	elseif nType == eET_NPC then
	elseif nType == eET_ResourcePoint then
		local entityResourcePoint = self._ResourcePoints[RoleID];
		if not entityResourcePoint then
			local SEntity = require("logic/entity/i3k_entity_resourcepoint");
			local ResourcePoint = SEntity.i3k_entity_resourcepoint.new(i3k_gen_entity_guid_new(SEntity.i3k_entity_resourcepoint.__cname,RoleID));
			ResourcePoint:NeedUpdateAlives(false);
			ResourcePoint:SetPos(Pos);
			ResourcePoint:SetFaceDir(Dir.x, Dir.y, Dir.z);
			ResourcePoint:OnUpdate(0);
			self:AddEntity(ResourcePoint);
			--self._ResourcePoints[RoleID] = ResourcePoint
		end
	elseif nType == eET_Trap then
		local entityTrap = self._Traps[RoleID];
		if not entityTrap then
			local SEntityTrap = require("logic/entity/i3k_entity_trap");
			local Trap = SEntityTrap.i3k_entity_trap.new(i3k_gen_entity_guid_new( SEntityTrap.i3k_entity_trap.__cname,RoleID));
			if Trap:CreatePreRes(configID) then
				Trap:NeedUpdateAlives(false);
				Trap:SetPos(Pos);
				Trap:SetFaceDir(Dir.x, Dir.y, Dir.z);
				self:AddEntity(Trap);
				--self._Traps[RoleID] = Trap
			end
		end
	elseif nType == eET_TransferPoint then
	elseif nType == eET_MapBuff then
		local mapbuff = self._mapbuffs[RoleID];
		if not mapbuff then
			local Entitymapbuff = require("logic/entity/i3k_mapbuff");
			local MapBuff = Entitymapbuff.i3k_mapbuff.new(i3k_gen_entity_guid_new( Entitymapbuff.i3k_mapbuff.__cname,RoleID));
			MapBuff:NeedUpdateAlives(false);
			MapBuff:SetTempPos(Pos);
			self:AddEntity(MapBuff);
		end
	elseif nType == eET_Car then
		local entityCar = self:GetEntity(eET_Car, RoleID);
		if not entityCar then
			local SCar = require("logic/entity/i3k_entity_net");
			local cfgID = math.abs(configID)
			local cfg = i3k_db_escort_car[cfgID];
			local skinId = carSkin or 1
			local skinConfig = i3k_db_escort_skin[skinId]
			cfg.modelID = skinConfig["moduleId" .. cfgID]
			cfg.damage_model = skinConfig["breakModuleId" .. cfgID]

			cfg.speed = i3k_db_escort.escort_args.speed
			cfg.curHP = curHP
			local isShow = not g_i3k_game_context:GetEscortIsHide()
			local str = string.format("%s%s",name,"的镖车")
			local Guid = self:CreateOnlyGuid(configID, nType, RoleID);
			local EscortCar = SCar.i3k_entity_net.new(Guid);
			if EscortCar:Create(cfgID, str, nil, nil, nil,1,{},cfg,eET_Car, false) then
				EscortCar:SetGroupType(eGroupType_O);
				EscortCar:SetFaceDir(Dir.x, Dir.y, Dir.z);
				EscortCar:SetPos(Pos);
				EscortCar:Show(isShow, true);
				EscortCar:UpdateProperty(ePropID_maxHP, 1,maxHP, true, false,true);
				EscortCar:UpdateHP(curHP);
				EscortCar:UpdateBloodBar(EscortCar:GetPropertyValue(ePropID_hp) / EscortCar:GetPropertyValue(ePropID_maxHP)); --更新血条
				EscortCar:SetHittable(isShow);
				EscortCar:SetTitleShow(isShow);
				EscortCar:SetTitleVisiable(isShow);
				EscortCar:UpdateCarState(state);
				EscortCar._titleshow = false
				EscortCar._sectID	 = sectID
				EscortCar._teamID 	= teamID

				BUFF = require("logic/battle/i3k_buff"); --镖车添加buff
				for i,e in ipairs(curBuffs) do
					local bcfg = i3k_db_buff[e];
					local buff = BUFF.i3k_buff.new(nil,e, bcfg, nil);
					if buff then
						EscortCar:AddBuff(nil, buff);
					end
				end
				self:AddEntity(EscortCar);
			end
		end
	end
end

function i3k_world:UpdateModelFromNetwork(RoleID, nType, CfgID, args, bwType, sectID)
	if nType == eET_Player then
		local entityPlayer = self:GetEntity(eET_Player, RoleID);
		if entityPlayer then
			local cfg = g_i3k_db.i3k_db_get_general(CfgID);
			local createRet = true;		
			entityPlayer:setPetDungeonInfo(args.petAlter)
			entityPlayer:setDesertBatttleInfo(args.desertScore, args.desertModelId)
			entityPlayer:setSpyInfo(entityPlayer._forceType , CfgID)
			if not entityPlayer._firstCre then
				createRet = entityPlayer:Create(CfgID, args.Rolename, args.Gender, args.Hair, args.Face, args.nLevel,{},cfg,eET_Player, false,args.sectname,args.sectID,args.sectPosition, args.sectIcon, args.permanentTitle,args.timedTitles,args.bwtype,args.carRobber,args.carOwner)
			end
			if createRet and entityPlayer._entity then
				if args.Buffs then
					for k, v in pairs(args.Buffs) do
						if not entityPlayer._buffs[v] then
							BUFF = require("logic/battle/i3k_buff");
							local bcfg = i3k_db_buff[v];
							local buff = BUFF.i3k_buff.new(nil, v, bcfg);
							if buff then
								entityPlayer:AddBuff(nil, buff);
							end
						end
					end
				end
				if entityPlayer._buffs then
					for _, buff in pairs(entityPlayer._buffs) do
						if not args.Buffs[buff._id] then
							entityPlayer:RmvBuff(buff);
						end
					end
				end
				entityPlayer:setSoaringDisplay(args.soaringDisplay) 
				if args.soaringDisplay.footEffect ~= 0 then
					entityPlayer:changeFootEffect(args.soaringDisplay.footEffect)
				end
				local isCombat = i3k_get_is_combat()
				
				local mapty = 
				{
					[g_FORCE_WAR] = true,
					[g_DEMON_HOLE] = true,
					[g_FACTION_WAR] = true,
					[g_DEFENCE_WAR] = true,
					[g_PET_ACTIVITY_DUNGEON] = true,	
					[g_DESERT_BATTLE] = true,
					[g_MAZE_BATTLE] = true,
					[g_SPY_STORY]	= true,
				}

				if isCombat or not mapty[self._mapType] then
					for i,v in pairs(args.Equips) do
						if (not entityPlayer._equips[i]) or (v ~= entityPlayer._equips[i].equipId )then
							entityPlayer:AttachEquip(v);
						end
					end

					if entityPlayer._equips then
						for i,v in pairs(entityPlayer._equips) do
							if (not args.Equips[i]) or (v.equipId ~= args.Equips[i]) then
								entityPlayer:DetachEquip(v.equipId, true);
							end
						end
					end


					if args.fashions[g_FashionType_Weapon] then
						entityPlayer:AttachFashion(args.fashions[g_FashionType_Weapon], entityPlayer:IsFashionWeapShow(), g_FashionType_Weapon)
					end
					if args.fashions[g_FashionType_Dress] then
						entityPlayer:AttachFashion(args.fashions[g_FashionType_Dress], entityPlayer:IsFashionShow(), g_FashionType_Dress);
									end
					if not entityPlayer:isSpecial() then
						entityPlayer:changeWeaponShowType()
					end

					if args.Armor.id~=0 then
						entityPlayer._armor.id = args.Armor.id
						entityPlayer._armor.stage = args.Armor.rank
						entityPlayer:SetArmorEffectHide(args.Armor.hideEffect)
						if args.armorWeak==1 then
							entityPlayer:AttachArmorWeakEffect()
						end
						entityPlayer:ChangeArmorEffect()
					end
					
					if entityPlayer:isSpecial() then
						entityPlayer:SpringSpecialShow();
					end
					if g_i3k_game_context:GetIsInHomeLandZone() then --家园装备
						if args.homelandEquip then
							entityPlayer._curHomeLandEquips = args.homelandEquip
							entityPlayer:AttachHomeLandCurEquip(args.homelandEquip)
							entityPlayer:SetFishStatus(args.isFishing)
						end
					end								
				end
				
				local maptype = 
				{
					[g_PET_ACTIVITY_DUNGEON] = true,
					[g_DESERT_BATTLE] = true,
					[g_SPY_STORY]	= true,
					[g_BIOGIAPHY_CAREER] = true,
				}
				
				if args.roleEquipsDetails and not maptype[self._mapType] then
					entityPlayer._equipinfo = args.roleEquipsDetails
					local weaponDisplay = i3k_get_soaring_display_info(args.soaringDisplay)
					if weaponDisplay ~= g_FLYING_SHOW_TYPE then
						entityPlayer:AttachEquipEffect(args.roleEquipsDetails)
					end
				end
							
				if entityPlayer:IsInSuperMode() and not args.Weapon  then
					entityPlayer:OnSuperMode(false)
				end

				if args.Motivate and (not entityPlayer:IsInSuperMode()) then
					entityPlayer:UseWeapon(args.Weapon,args.weaponForm)
					entityPlayer:OnSuperMode(true)
				end

				if args.attackMode ~= entityPlayer._PVPStatus then
					entityPlayer:SetPVPStatus(args.attackMode)
				end

				if args.pkGrade then
					entityPlayer._PVPColor = args.pkGrade
				end
				if args.weaponSoulShow then
					entityPlayer:DetachWeaponSoul()
					if args.weaponSoulShow ~= 0 then
						entityPlayer:SetWeaponSoulShow(true)
						entityPlayer:AttachWeaponSoul(args.weaponSoulShow);
					else
						entityPlayer:SetWeaponSoulShow(false)
					end
				end

				if args.pkState then
					entityPlayer._PVPFlag = args.pkState
				end
				self:UpdatePKState(entityPlayer);

				if args.carRobber then
					entityPlayer._iscarRobber = args.carRobber
				end

				if args.carOwner then
					entityPlayer._iscarOwner = args.carOwner
				end
				if args.heirloom then
					entityPlayer._heirloom = args.heirloom
				end
				entityPlayer:TitleColorTest();

				if args.HeadIconID and entityPlayer._headiconID ~= args.HeadIconID  then
					entityPlayer._headiconID = args.HeadIconID
				end

				if args.HeadBorder and entityPlayer._headBorder ~= args.HeadBorder  then
					entityPlayer._headBorder = args.HeadBorder
				end

				if args.sectIcon then
					entityPlayer._sectIcon = args.sectIcon
				end

				if args.horseSpiritShowID ~= 0 then
					entityPlayer:SetRideSpiritCurShowID(args.horseSpiritShowID)
				end

				if (entityPlayer:IsOnRide() and args.horseShowID == 0) or args.horseShowID == 0 then
					entityPlayer:OnRideMode(false);
				end

				if not entityPlayer:IsOnRide() and args.horseShowID ~= 0  then
					entityPlayer:UseRide(args.horseShowID)
				end


				if args.alterID == 0 or (entityPlayer._missionMode.valid and args.alterID == 0) or (entityPlayer._missionMode and entityPlayer._missionMode.id and (entityPlayer._missionMode.id ~= args.alterID)) then
					entityPlayer:MissionMode(false)
				end

				if args.alterID and args.alterID ~= 0 then
					if not entityPlayer._missionMode.valid then
						entityPlayer:MissionMode(true,args.alterID)
					end
				end

				if args.bwtype then
					entityPlayer._bwtype = args.bwtype
				end

				entityPlayer:SetTitleShow(self:CheckTitleShow(entityPlayer))

				if entityPlayer._socialactionID ~= 0 and args.socialActionID == 0 then
					entityPlayer._socialactionID = args.socialActionID
				end

				if args.socialActionID ~= 0 then
					entityPlayer._socialactionID = args.socialActionID
					entityPlayer._playSocial = true;
					entityPlayer:PlaySocialAction(args.socialActionID,true)
				end

				if args.wizardPetId then
					entityPlayer._wizardPetId = args.wizardPetId;
				end

				if args.states then
					if args.states[eEBDaZuo] then
						entityPlayer._behavior:Set(eEBDaZuo)
					end
				end
				if not args.states[eEBInvisible] then
					entityPlayer:Show(not self._isFilter, true, 100);
					self:UpdateIsShowPlayerSate(true)
				end

				if args.buffDrugs and entityPlayer._buffDrugs ~= args.buffDrugs then
					entityPlayer._buffDrugs = args.buffDrugs
				end
				--楚汉兵种
				if args.chessArm ~= 0 then
					entityPlayer:AttachChessFlag(args.chessArm)
				end
				if args.combatType > 0 then
					entityPlayer:SetCombatType(args.combatType)
				end
			else
				self:RmvEntity(entityPlayer)
			end
		end
	elseif nType == eET_Monster then
		local entityMonster = self:GetEntity(eET_Monster, RoleID);
		if entityMonster then
			if args and args.param1 then
				entityMonster:setSpecialArg(args.param1)
			end
			local cfg = i3k_db_monsters[CfgID];
			if entityMonster:Create(CfgID, cfg.name, nil, nil, nil, cfg.level,{},cfg,eET_Monster, false) then
				if args then
					if args.Buffs then
						for k, v in pairs(args.Buffs) do
							local BUFF = require("logic/battle/i3k_buff");
							local bcfg = i3k_db_buff[v];
							local buff = BUFF.i3k_buff.new(nil, v, bcfg);
							if buff then
								entityMonster:AddBuff(nil, buff);
							end
						end
					end
				end

				if self._runState then
					if entityMonster._isBoss then
						if self._runState.finishType == 1 then
							if entityMonster._cfg.boss == 2 then
								self._runState.finishCheck = function()
									return not entityMonster:IsDestory();
								end
							end
						end
					end
				end
				if args.maxArmor and args.maxArmor > 0 then
					entityMonster:UpdateArmorValue(args.curArmor, args.maxArmor)
				end
				entityMonster:SetPos(entityMonster._curPos);
				entityMonster:SetFaceDir(0,entityMonster._faceDir.y,0);
				entityMonster:Show(true, true, 100);
				entityMonster:SetCtrlType(eCtrlType_NetWork);
				entityMonster:SetBWType(cfg.camp or 0)
				entityMonster:SetTitleShow(self:CheckTitleShow(entityMonster))
				entityMonster:AddSpecialEffect()
			end
		end
	elseif nType == eET_Mercenary then
		local entityMercenary = self:GetEntity(eET_Mercenary, RoleID);
		if entityMercenary then
			local nlevel = 1
			if args.nLevel then
				nlevel = args.nLevel
			end
			local cfgID = math.abs(CfgID)
			local cfg = i3k_db_mercenaries[cfgID];
			local petName = args.petName ~= "" and args.petName or cfg.name

			if args.awakeUse and args.awakeUse.use and args.awakeUse.use == 1 then
				entityMercenary._awaken = args.awakeUse.use;
			end

			if entityMercenary:Create(CfgID, petName, nil, nil, nil,nlevel,{},cfg,eET_Mercenary, false) then
				if args.Buffs then
					for k, v in pairs(args.Buffs) do
						if not entityMercenary._buffs[v] then
							BUFF = require("logic/battle/i3k_buff");
							local bcfg = i3k_db_buff[v];
							local buff = BUFF.i3k_buff.new(nil, v, bcfg);
							if buff then
								entityMercenary:AddBuff(nil, buff);
							end
						end
					end
				end

				if entityMercenary._buffs then
					for _, buff in pairs(entityMercenary._buffs) do
						if not args.Buffs[buff._id] then
							entityMercenary:RmvBuff(buff);
						end
					end
				end

				if args.ownerID then
					local hero = self:GetEntity(eET_Player, args.ownerID);
					entityMercenary._hoster = hero;
					entityMercenary._hosterID = args.ownerID;
				end
				self:UpdatePKState(entityMercenary);
				entityMercenary:SetTitleShow(self:CheckTitleShow(entityMercenary))
				--守护灵兽
				entityMercenary:DetachPetGuard()
				if args.petGuardIsShow == 0 and args.curPetGuard ~= 0 then
					entityMercenary:SetCurPetGuardId(args.curPetGuard)
					if not entityMercenary:IsDead() then
						entityMercenary:AttachPetGuard(args.curPetGuard)
					end
				else
					entityMercenary:SetCurPetGuardId(nil)
				end
			end
		end
	elseif nType == eET_NPC then
	elseif nType == eET_ResourcePoint then
		local entityResourcePoint = self._ResourcePoints[RoleID];
		if entityResourcePoint then
			if entityResourcePoint:Create(CfgID, false) then
				entityResourcePoint:SetPos(entityResourcePoint._curPos);
				local Dir_m = entityResourcePoint._faceDir.y;
				entityResourcePoint:SetFaceDir(0,Dir_m,0);
				entityResourcePoint:SetTrapBehavior(eSTrapMine,true);
				entityResourcePoint:SetHittable(true)
				--entityResourcePoint:ShowTitleNode(false)
				local mcfg = g_i3k_game_context:GetMianAndFactionTaskAnimationData()
				local mineIdTab = g_i3k_game_context:GetAllTaskMineData({})
				if mcfg and #mcfg.ore > 0 then
					for k,v in pairs(mcfg.ore) do
						if v == entityResourcePoint._gid then
							entityResourcePoint:ShowTitleNode(true);
							entityResourcePoint:PlayMissionEffect(i3k_db_common.mission.missioneffectID)
							break;
						end
					end
				end
				if mineIdTab and #mineIdTab >0 then
					for k,v in pairs(mineIdTab) do
						if v == entityResourcePoint._gid then
							entityResourcePoint:ShowTitleNode(true);
							break;
						end
					end
				end
				local festival = g_i3k_game_context:getFestivalLimitTask()
				for k, v in pairs(festival) do
					if v.curTask and v.curTask.state == 1 then
						local taskCfg = i3k_db_festival_task[v.curTask.groupId][v.curTask.index]
						if taskCfg.type == g_TASK_SCENE_MINE then
							local mineIndex = g_i3k_db.i3k_db_get_scene_mine_index(taskCfg.arg1, entityResourcePoint._gid)
							if mineIndex then
								entityResourcePoint:ShowTitleNode(false)
								local data = g_i3k_game_context:getFestivalTaskValue(v.curTask.groupId, v.curTask.index)
								local havePlace = g_i3k_db.i3k_db_get_scene_mine_have_place(data.value, taskCfg.arg1, entityResourcePoint._gid)
								if havePlace then
									entityResourcePoint:Play(entityResourcePoint._gcfg.destroyAction, -1)
								else
									entityResourcePoint:PlayMissionEffect(i3k_db_common.sceneMineEffectID)
								end
								break
							end
						end
					end
				end
				local jubilee = g_i3k_game_context:GetJubileeStep2Task()
				if jubilee and jubilee.state == 1 then
					local taskCfg = g_i3k_db.i3k_db_get_jubilee_task_cfg(jubilee.id)
					if taskCfg.type == g_TASK_SCENE_MINE then
						local mineIndex = g_i3k_db.i3k_db_get_scene_mine_index(taskCfg.arg1, entityResourcePoint._gid)
						if mineIndex then
							entityResourcePoint:ShowTitleNode(false)
							local havePlace = g_i3k_db.i3k_db_get_scene_mine_have_place(jubilee.value, taskCfg.arg1, entityResourcePoint._gid)
							if havePlace then
								entityResourcePoint:Play(entityResourcePoint._gcfg.destroyAction, -1)
							else
								entityResourcePoint:PlayMissionEffect(i3k_db_common.sceneMineEffectID)
							end
						end
					end
				end

				if entityResourcePoint._gcfg.nType == 5 then
					entityResourcePoint:Play("stand01", -1)
				end
			end
			if entityResourcePoint._gcfg.nType == 5 then
				if g_i3k_game_context:GetCurrentMapFlagId() == 0 then
					g_i3k_game_context:ChangeFactionFlagModle(438)
				elseif g_i3k_game_context:GetCurrentMapFlagId() == g_i3k_game_context:GetSectId() then
					g_i3k_game_context:ChangeFactionFlagModle(440)
				else
					g_i3k_game_context:ChangeFactionFlagModle(439)
				end
			end
			if args.state == 0 and entityResourcePoint._gcfg.destroyModleID > 0 then
				entityResourcePoint:ChangeModelFacade(entityResourcePoint._gcfg.destroyModleID)
			end
			entityResourcePoint:setResourcepointState(args.state, false)
			if args.ownType then
				entityResourcePoint:setOwnType(args.ownType)
			end
			if entityResourcePoint._gcfg.nType == 17 and args.lastCnt then
				entityResourcePoint:updataDesertTitleState(args.lastCnt, RoleID)
			end
			if entityResourcePoint._gcfg.nType == 12 then
				local cfgID = entityResourcePoint._gid
				local info = i3k_db_faction_dragon.dragonInfo
				if info[cfgID] then
					entityResourcePoint:Play(info[cfgID].action, -1)
				end
				i3k_sbean.request_sect_destiny_sync_req()
			end
		end

	elseif nType == eET_Trap then
		local entityTrap = self._Traps[RoleID];
		if entityTrap then
			if not entityTrap._isShow then
				if entityTrap:CreateFromCfg() then
					entityTrap:AddAiComp(eAType_ATTACK);
					entityTrap:AddAiComp(eAType_MANUAL_SKILL);
					entityTrap:SetHittable(true)
					entityTrap:Show(true, true, 100);
					if entityTrap._IsAttack ~= 0 then
						entityTrap:SetGroupType(eGroupType_N);
						self:AddEntity(entityTrap,true);
					end
				end
				if args then
					if args.TargetIDs then
						for k,v in pairs(args.TargetIDs) do
							entityTrap:SetTarget(v)
						end
					end
				end
			end
			entityTrap:SetPos(entityTrap._curPos);
			local cfg = i3k_db_traps_external[CfgID]
			local Dir_m = entityTrap._faceDir.y;
			if cfg then
				Dir_m = cfg.Direction[2]*6.28/360
			end
			entityTrap:SetFaceDir(0,Dir_m,0);

			if args and args.ncurState then
				entityTrap:SetTrapBehavior(args.ncurState,true);
			else
				entityTrap:SetTrapBehavior(eSTrapLocked,true);
			end
		end
	elseif nType == eET_MapBuff then
		local mapbuff = self._mapbuffs[RoleID];
		if mapbuff then
			if mapbuff:Create(CfgID,RoleID) then
				mapbuff:SetPos();
				mapbuff:Show(true, true, 100);
				mapbuff:SetHittable(false)
			end
		end
	elseif nType == eET_TransferPoint then
	elseif nType == eET_Skill then
		local entitySkill = self:GetEntity(eET_Skill, RoleID);
		if not entitySkill then
			local SEntity = require("logic/entity/i3k_entity_net");
			local Guid = self:CreateOnlyGuid(skillID, nType, RoleID);
			local entitySkill = SEntity.i3k_entity_net.new(Guid);
			if entitySkill then
				local skillID = args.skillID;
				local scfg = i3k_db_skills[skillID];
				if entitySkill:Create(skillID, scfg.name, nil, nil, nil, 1, {}, args, eET_Skill) then
					if scfg then
					entitySkill._hoster		= entitySkill;
					entitySkill._cfg       = { speed = 0 };
					entitySkill._movespeed	= nil;
					local _lvl = lvl or 1;
					local _rel = realm or 0;
					local _S = require("logic/battle/i3k_skill");
					local _skill = _S.i3k_skill_create(entitySkill, scfg, 1, 0, _S.eSG_Skill);
						if _skill then
							entitySkill._lifeTick	= 0;
							entitySkill._skills = {}
							table.insert(entitySkill._skills,skillID,_skill);
							entitySkill:UseSkill(_skill);
						end
					end
					entitySkill._summonID = skillID
				end
				if args.ownerID then
					entitySkill._hosterID = args.ownerID
				end
				entitySkill:NeedUpdateAlives(false);
				entitySkill:SetPos(args.Pos);
				entitySkill:SetFaceDir(args.Dir.x, args.Dir.y, args.Dir.z);
				self:AddEntity(entitySkill);
				entitySkill:Show(true, true, 100);
				entitySkill:SetHittable(false)
			end
		end
	elseif nType == eET_Pet then
		local entityPet = self:GetEntity(eET_Pet, RoleID);
		if not entityPet then
			local SEntity = require("logic/entity/i3k_entity_net");
			local Guid = self:CreateOnlyGuid(CfgID, nType, RoleID);
			local entityPet = SEntity.i3k_entity_net.new(Guid);
			local cfg = i3k_db_fightpet[CfgID];
			entityPet:Create(CfgID, cfg.name, nil, nil, nil,1,{},cfg,eET_Pet, false)
			entityPet._bwType = bwType or entityPet._bwType
			entityPet:SetForceType(args.forceType)
			entityPet._sectID = sectID
			if args then
				if args.maxHP then
					entityPet:UpdateProperty(ePropID_maxHP, 1, args.maxHP, true, false, true);
				end
				if args.curHP then
					entityPet:UpdateHP(args.curHP);
					entityPet:UpdateBloodBar(entityPet:GetPropertyValue(ePropID_hp) / entityPet:GetPropertyValue(ePropID_maxHP));
				end
				if args.Buffs then
					for k, v in pairs(args.Buffs) do
						BUFF = require("logic/battle/i3k_buff");
						local bcfg = i3k_db_buff[v];
						local buff = BUFF.i3k_buff.new(nil, v, bcfg);
						if buff then
							entityPet:AddBuff(nil, buff);
						end
					end
				end
				if args.ownerID then
					entityPet._hosterID = args.ownerID
				end
			end
			entityPet:SetCtrlType(eCtrlType_NetWork);
			entityPet:NeedUpdateAlives(false);
			entityPet:Show(true, true, 1000);
			entityPet:SetGroupType(eGroupType_O);
			entityPet:SetPos(args.Pos);
			entityPet:SetFaceDir(args.Dir.x, args.Dir.y, args.Dir.z);
			entityPet:SetHittable(true)
			if entityPet._hosterID then
				local hero = i3k_game_get_player_hero()
				if hero then
					local guid = string.split(hero:GetGUID(), "|")
					if tonumber(guid[2]) == entityPet._hosterID then
						entityPet:SetHittable(false)
					end
				end
			end
			entityPet:SetTitleShow(self:CheckTitleShow(entityPet))
			self:AddEntity(entityPet);
		end
	elseif nType == eET_Car then
		local entityCar = self:GetEntity(eET_Car, RoleID);
		entityCar:SetTitleShow(self:CheckTitleShow(entityCar))
	elseif nType == eET_Summoned then
		local entitySummoned = self:GetEntity(eET_Summoned, RoleID);
		if not entitySummoned then
			local SEntity = require("logic/entity/i3k_entity_net");
			local Guid = self:CreateOnlyGuid(CfgID, nType, RoleID);
			local entitySummoned = SEntity.i3k_entity_net.new(Guid);
			local cfg = i3k_db_summoned[CfgID];
			entitySummoned:Create(CfgID, cfg.name, nil, nil, nil,1,{},cfg,eET_Summoned, false)
			entitySummoned._bwType = bwType or entitySummoned._bwType
			entitySummoned:SetForceType(args.forceType)
			entitySummoned._sectID = sectID
			if args then
				if args.maxHP then
					entitySummoned:UpdateProperty(ePropID_maxHP, 1, args.maxHP, true, false, true);
				end
				if args.curHP then
					entitySummoned:UpdateHP(args.curHP);
					entitySummoned:UpdateBloodBar(entitySummoned:GetPropertyValue(ePropID_hp) / entitySummoned:GetPropertyValue(ePropID_maxHP));
				end
				if args.Buffs then
					for k, v in pairs(args.Buffs) do
						BUFF = require("logic/battle/i3k_buff");
						local bcfg = i3k_db_buff[v];
						local buff = BUFF.i3k_buff.new(nil, v, bcfg);
						if buff then
							entitySummoned:AddBuff(nil, buff);
						end
					end
				end
				if args.ownerID then
					entitySummoned._hosterID = args.ownerID
				end
			end
			entitySummoned:SetCtrlType(eCtrlType_NetWork);
			entitySummoned:NeedUpdateAlives(false);
			entitySummoned:Show(true, true, 1000);
			entitySummoned:SetGroupType(eGroupType_O);
			entitySummoned:SetPos(args.Pos);
			entitySummoned:SetFaceDir(args.Dir.x, args.Dir.y, args.Dir.z);
			entitySummoned:SetHittable(true)
			entitySummoned:SetTitleShow(self:CheckTitleShow(entitySummoned))
			if entitySummoned._hosterID then
				local hero = i3k_game_get_player_hero()
				if hero then
					local guid = string.split(hero:GetGUID(), "|")
					if tonumber(guid[2]) == entitySummoned._hosterID then
						entitySummoned:SetHittable(false)
						entitySummoned:SetTitleShow(true)
					end
				end
			end
			self:AddEntity(entitySummoned);
		end
	end
end

function i3k_world:CheckTitleShow(entity)
	if entity:GetEntityType() == eET_Player then
		if self._fightmap then
			return true;
		else
			return false;
		end
	elseif entity:GetEntityType() == eET_Monster then
		if self._mapType == g_FIELD or self._mapType == g_SPIRIT_BOSS then
			return false;
		else
			return true;
		end
	elseif entity:GetEntityType() == eET_Mercenary then
		if self._fightmap then
			return true;
		else
			return false;
		end
	elseif entity:GetEntityType() == eET_Pet or entity:GetEntityType() == eET_Summoned then
		if self._fightmap then
			return true;
		else
			return false;
		end
	elseif entity:GetEntityType() == eET_Car then
		if self._fightmap then
			return true;
		else
			return false;
		end
	end
end

function i3k_world:CheckNpcShow(entity)
	local curMapID = g_i3k_game_context:GetWorldMapID()
	if entity:GetEntityType() == eET_NPC then
		local ncpCfg = entity._baseCfg
		local isShowNpc = true
		if #ncpCfg.showtaskIDs > 0 and #ncpCfg.showADtaskIDs > 0 then
			local id,value = g_i3k_game_context:getMainTaskIdAndVlaue()
			local shownpc = false;
			for k,v in pairs(ncpCfg.showtaskIDs) do
				if v == id then
					shownpc = true;
					break;
				end
			end
			local id = g_i3k_game_context:getAdventureTask().id
			local showADnpc = false
			if id then
				for k,v in pairs(ncpCfg.showADtaskIDs) do
					if v == id then
						showADnpc = true;
						break;
					end
				end
			end
			isShowNpc = shownpc or showADnpc
		elseif #ncpCfg.showtaskIDs > 0 then
			local id,value = g_i3k_game_context:getMainTaskIdAndVlaue()
			isShowNpc = false;
			for k,v in pairs(ncpCfg.showtaskIDs) do
				if v == id then
					isShowNpc = true;
					break;
				end
			end
		elseif #ncpCfg.showADtaskIDs > 0 then
			local id = g_i3k_game_context:getAdventureTask().id
			isShowNpc = false
			if id then
				for k,v in pairs(ncpCfg.showADtaskIDs) do
					if v == id then
						isShowNpc = true;
						break;
					end
				end
			end
		elseif g_i3k_db.i3k_db_check_dance_npc(curMapID, ncpCfg.ID) then -- 根据id，地图id，时间点，来判断指定的id是否显示。
			if g_i3k_db.i3k_db_check_in_dance_time() then
				if not self._danceNpcs then 
					self._danceNpcs = {}
				end
				self._danceNpcs[ncpCfg.ID] = entity
				if i3k_db_dance_npc_action[ncpCfg.ID] then
					local alist = {}
					table.insert(alist, {actionName = i3k_db_dance_npc_action[ncpCfg.ID], actloopTimes = -1})
					entity:PlayActionList(alist, 1)
				end
				isShowNpc = true
			else
				isShowNpc = false
			end
		end
		if ncpCfg.FunctionID[1] == TASK_FUNCTION_SUBLINE_TASK then
			if g_i3k_game_context:getSubLineTaskIsFinishedByID(ncpCfg.exchangeId[1]) then
				isShowNpc = false
			end
		end
		if self._cfg.openType == g_BIOGIAPHY_CAREER then
			if #ncpCfg.showBiographyTask > 0 then
				local taskId = g_i3k_game_context:getBiographyTask()
				if taskId and table.indexof(ncpCfg.showBiographyTask, taskId) then
					isShowNpc = true
				else
					isShowNpc = false
				end
			else
				isShowNpc = true
			end
		end	
		
		if ncpCfg.showTime and ncpCfg.showTime > 0 then
			isShowNpc = g_i3k_db.i3k_db_check_npc_show_time(ncpCfg)
		end

		if isShowNpc and ncpCfg.FunctionID[1] ~= TASK_FUNCTION_WEAPON_NPC then
			entity:Show(true, true, 100);
			entity:ShowTitleNode(true);
			entity:SetHittable(true)
		else
			entity:Show(false, true, 100);
			entity:ShowTitleNode(false);
			entity:SetHittable(false)
		end
		g_i3k_game_context:showWeaponNPC()
		return isShowNpc

				end
			end

function i3k_world:refreshDanceNpcPopString()
	local curMapID = g_i3k_game_context:GetWorldMapID()
	if not i3k_db_dance_map[curMapID] then
		return 
	end
	if not self._danceNpcs then 
		return 
	end
	if not g_i3k_db.i3k_db_check_in_dance_time() then	
		for k, v in pairs(self._danceNpcs)do
			self:CheckNpcShow(v)
		end
		self._danceNpcs = nil
		return 
	end
	for k, v in pairs(self._danceNpcs)do
		local text = g_i3k_db.i3k_db_get_dance_pop_text()
		g_i3k_ui_mgr:PopTextBubble(true, v, text)
	end
end

function i3k_world:ResetTitleShow()
	for k1,v1 in pairs(self._entities[eGroupType_O]) do
		if v1:GetEntityType() == eET_Player or v1:GetEntityType() == eET_Monster or v1:GetEntityType() == eET_Mercenary or v1:GetEntityType() == eET_Pet then
			v1:SetTitleVisiable(self:CheckTitleShow(v1))
		end
	end
	for k1,v1 in pairs(self._entities[eGroupType_E]) do
		if v1:GetEntityType() == eET_Player or v1:GetEntityType() == eET_Monster or v1:GetEntityType() == eET_Mercenary or v1:GetEntityType() == eET_Pet then
			v1:SetTitleVisiable(self:CheckTitleShow(v1))
		end
	end
end

function i3k_world:CreateItemDropsFromNetwork(Pos,DropsDetail)
	local SEntityItemDrop = require("logic/entity/i3k_entity_itemdrop");
	for k,v in pairs(DropsDetail) do
		local ModelID = g_i3k_db.i3k_db.i3k_db_get_common_item_model(v.Id)
		local ItemName = g_i3k_db.i3k_db_get_common_item_name(v.Id)
		local ItemColor = g_i3k_db.i3k_db_get_common_item_rank(v.Id)
		local ItemDrop = SEntityItemDrop.i3k_entity_itemdrop.new(i3k_gen_entity_guid_new(SEntityItemDrop.i3k_entity_itemdrop.__cname,v.Gid));
		ItemDrop:Create(v.Gid, ModelID, v.nCount, ItemName, ItemColor, v.Id);
		ItemDrop:SetHittable(true);
		ItemDrop:Show(true);
		ItemDrop:Play("stand", -1);
		ItemDrop:NeedUpdateAlives(false);
		ItemDrop:ShowTitleNode(true);
		ItemDrop:Actived();
		local pos1 = i3k_vec3_to_engine(Pos);
		local dropRandRadius = i3k_db_common.droppick.dropRandRadius
		local xadd = i3k_engine_get_rnd_u(-dropRandRadius, dropRandRadius);
		local zadd = i3k_engine_get_rnd_u(-dropRandRadius, dropRandRadius);
		pos1.x = pos1.x+xadd
		pos1.z = pos1.z+zadd
		local pos2 = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos1))));
		ItemDrop:SetPos(pos2, true);
		self:AddEntity(ItemDrop)
		--self._ItemDrops[v.Gid] = ItemDrop
	end
end

function i3k_world:RefreshMissionEffect()
	local mcfg = g_i3k_game_context:GetMianAndFactionTaskAnimationData()
--	local mineIdTab = g_i3k_game_context:GetAllTaskMineData(mcfg.ore)
	for k1,v1 in pairs(self._ResourcePoints) do
		local stopmissioneffect = true;
		if mcfg and #mcfg.ore > 0 then
			for k,v in pairs(mcfg.ore) do
				if v == v1._gid then
					stopmissioneffect = false;
					if not self._missionEffectID then
						v1:ShowTitleNode(true)
						v1:PlayMissionEffect(i3k_db_common.mission.missioneffectID)
					end
					break;
				end
			end
		end
		if v1._gcfg and v1._gcfg.nType == 1 and stopmissioneffect then
			v1:ShowTitleNode(false)
			v1:StopMissionEffect()
		end
	end
	for k1,v1 in pairs(self._entities[eGroupType_O]) do
		if v1:GetEntityType() == eET_NPC then
			self:CheckNpcShow(v1)
			local stopmissioneffect = true;
			if mcfg and #mcfg.npc > 0 then
				for k,v in pairs(mcfg.npc) do
					if v == v1._id then
						stopmissioneffect = false;
						if not self._missionEffectID then
							v1:PlayMissionEffect(i3k_db_common.mission.missioneffectID)
						end
						break;
					end
				end
			end
			if stopmissioneffect then
				v1:StopMissionEffect()
			end
		end
	end
end

-- 刷新小地图NPC显示
function i3k_world:RefreshMiniMapNpc()
	local mapNpc = {}
	for k1,v1 in pairs(self._entities[eGroupType_O]) do
		if v1:GetEntityType() == eET_NPC then
			local isShow = self:CheckNpcShow(v1)
			mapNpc[v1._id] = isShow
		end
	end
	g_i3k_game_context:setMiniMapNPC(mapNpc)
end


function i3k_world:OnPlayerEnterWorld(player)
	if self._player ~= player then
		if self._player then
			local hero = self._player:GetHero();
			if hero then
				self:RmvEntity(hero);
			end

			for k = 1, self._player:GetPetCount() do
				local pet = self._player:GetPet(k);
				if pet then
					self:RmvEntity(pet);
				end
			end

			for k = 1, self._player:GetMercenaryCount() do
				local mercenary = self._player:GetMercenary(k);
				if mercenary then
					self:RmvEntity(mercenary);
				end
			end

			for k = 1, self._player:GetNPCCount() do
				local npc = self._player:GetNPC(k);
				if npc then
					self:RmvEntity(npc);
				end
			end
		end
		self._player = player;

		if self._player then
			self._player:Show(true, true);
			self._player:OnUpdate(0);

			local hero = self._player:GetHero();
			if hero then
				hero:SyncRpc(self._syncRpc);

				self:AddEntity(hero);
			end

			for k = 1, self._player:GetPetCount() do
				local pet = self._player:GetPet(k);
				if pet then
					pet:SyncRpc(self._syncRpc);

					self:AddEntity(pet);
				end
			end

			for k = 1, self._player:GetMercenaryCount() do
				local mercenary = self._player:GetMercenary(k);
				if mercenary then
					mercenary:SyncRpc(self._syncRpc);

					self:AddEntity(mercenary);
				end
			end

			for k = 1, self._player:GetNPCCount() do
				local npc = self._player:GetNPC(k);
				if npc then
					npc:SyncRpc(self._syncRpc);

					self:AddEntity(npc);
				end
			end

		end
	end
end

function i3k_world:Release(samemap)
	self:OnPlayerEnterWorld(nil);
	if self.petRaceCo then
		g_i3k_coroutine_mgr:StopCoroutine(self.petRaceCo)
	end
	self._grid_mgr:Cleanup();

	if self._entities then
		for k, v in pairs(self._entities) do
			for k1, v1 in pairs(v) do
				if not samemap or v1:GetEntityType() ~= eET_NPC or (v1:GetEntityType() == eET_NPC and v1._special) then
					if v1:GetEntityType() ~= eET_Trap then
						if table.nums(v1:GetLinkEntitys()) then
							for i, e in pairs(v1:GetLinkEntitys()) do
								if not e:IsPlayer() then
									e:Release();
								end
							end
						end
						if v1._linkHugChild and not v1._linkHugChild:IsPlayer() then
							v1._linkHugChild:Release()
						end
						v1:Release();
					end
					self._entities[k][k1] = nil;
				else
					self:OnAddEntity(v1)
				end
			end
		end

		if not samemap then
			self._entities	= { [eGroupType_O] = { }, [eGroupType_E] = { }, [eGroupType_N] = { } };
		end
	end

	if self._ItemDrops then
		for k, v in pairs(self._ItemDrops) do
			v:Release();
		end
		self._ItemDrops = {};
	end

	if self._ItemCrops then
		for k, v in pairs(self._ItemCrops) do
			v:Release();
		end
		self._ItemCrops = {};
	end
	
	if self._floorEntitys then
		for k, v in pairs(self._floorEntitys) do
			v:Release();
		end
		self._floorEntitys = {};
	end
	
	if self._floorFurniture then
		for k, v in pairs(self._floorFurniture) do
			v:Release();
		end
		self._floorFurniture = {};
	end
	
	if self._wallFurniture then
		for k, v in pairs(self._wallFurniture) do
			v:Release();
		end
		self._wallFurniture = {};
	end
	
	if self._carpetFurniture then
		for k, v in pairs(self._carpetFurniture) do
			v:Release();
		end
		self._carpetFurniture = {};
	end
	
	if self._houseSkin then
		for k, v in pairs(self._houseSkin) do
			v:Release();
		end
		self._houseSkin = {};
	end

	if self._ResourcePoints then
		for k, v in pairs(self._ResourcePoints) do
			v:Release();

		end
		self._ResourcePoints = {};
	end
	if self._disposableNpcs then
		for k, v in pairs(self._disposableNpcs) do
			v:Release();
		end
		self._disposableNpcs = {};
	end
	if self._catchSpirit then
		for k, v in pairs(self._catchSpirit) do
			v:Release();
		end
		self._catchSpirit = {};
	end
	if self._ghostFragment then
		for k, v in pairs(self._ghostFragment) do
			v:Release();
		end
		self._ghostFragment = {};
	end

	if not samemap then
		self._sceneAni = { bossbegin = false, bossend = false, scenebegin = false };
	end

	if self._TransferPoints then
		for k, v in pairs(self._TransferPoints) do
			if not samemap then
				v:Release();
			else
				self:OnAddEntity(v)
			end
		end
			if not samemap then
				self._TransferPoints = { };
		end
	end

	if self._Traps then
		for k, v in pairs(self._Traps) do
			v:Release();

		end
		self._Traps = {};
	end

	if self._mapbuffs then
		for k, v in pairs(self._mapbuffs) do
			v:Release();

		end
		self._mapbuffs = {};
	end

	if self._SkillEntitys then
		for k, v in pairs(self._SkillEntitys) do
			v:Release();
		end
		self._SkillEntitys = {};
	end

	if self._passengers then
		for k, v in pairs(self._passengers) do
			v:Release();
		end
		self._passengers = {};
	end

	if self._embracers then
		for k, v in pairs(self._embracers) do
			v:Release();
		end
		self._embracers = {}
	end

	if self._commonEntitys then
		for k, v in pairs(self._commonEntitys) do
			v:Release();
		end
		self._commonEntitys = {};
	end

	self._updatePlayerList = {}
	self._specialMonsters = {}
	self._showPlayer = {}
	self:ResetDesertPoisonInfo()
	frame_task_mgr.clearTasks();
end

function i3k_world:Exit()
end

function i3k_world:OnUpdate(dTime)
	self._grid_mgr:OnUpdate(dTime);
	if self._isHitDiglettWorld then
		self._randomDiglettTime = self._randomDiglettTime + dTime
		self._randomTime = self._randomTime or i3k_engine_get_rnd_u(0, 4000)/1000
		if self._randomDiglettTime >= self._randomTime then
			--生成地鼠
			local pos = self:RandomDiglettPosition()
			if pos then
				--i3k_log(string.format("random :%s", self._randomTime))
				--i3k_log(string.format("create id:%s", pos))
				self:CreateDiglettById(pos, i3k_db_diglett_position.digletts[pos])
				self._randomDiglettTime = 0
				self._randomTime = i3k_engine_get_rnd_u(0, 4000)/1000
			end
		end
	end

	return true;
end

local g_i3k_log_tick = 0;

function i3k_world:OnLogic(dTick)

	self._timeLine = self._timeLine + dTick * i3k_engine_get_tick_step();
	self._mapguidetimeLine = self._mapguidetimeLine + dTick * i3k_engine_get_tick_step();
	self._sectDestinyTimeLine = self._sectDestinyTimeLine + dTick * i3k_engine_get_tick_step();
	self._synctick = self._synctick + dTick * i3k_engine_get_tick_step();
	if self._maxTime > 0 then
		if self._timeLine> MapTimeRefreshTime then
			self._timeLine = 0;
			local tm = self._maxTime - (i3k_game_get_time() - self._startTime)
			if tm >= 0 then
				if tm > 10 then
					g_i3k_game_context:onBattleTimeChangeHandle(tm, "ffffffff");
				else
					g_i3k_game_context:onBattleTimeChangeHandle(tm, "ffff0000");
				end
			end
		end
	end

	self._grid_mgr:OnLogic(dTick);
	if not self._syncRpc then
		i3k_collision_mgr.OnLogic(dTick);
	end

	if self._mapguidetimeLine >= MapGuideRefreshTime then
		local old = self._showGuide
		if old ~= self:GetMapGuideShowCheck() then
			if self:GetMapGuideShowCheck() then
				self._mapguideDeny = self._mapguideDeny + 1
				if self._mapguideDeny > 10 then
					self._showGuide = self:GetMapGuideShowCheck()
					g_i3k_game_context:OnGuideVisibleChangedHandler(self._showGuide)
					self._mapguideDeny = 0
				end
			else
				self._showGuide = self:GetMapGuideShowCheck()
				self._mapguideDeny = 0
				g_i3k_game_context:OnGuideVisibleChangedHandler(self._showGuide)
			end
		end
		self:GetMapGuide()
		self._mapguidetimeLine = 0;
	end

	for i,v in ipairs(self._CacheEntitys) do
		self:RmvEntity(v.entity);
		v.entity:Release();
	end
	self._CacheEntitys = {};
	self:UpdateMonsterSelectEffect()
	self:UpdateItemDrop()
	if self._synctick > 1000 then --每秒更新周围玩家模型显隐
		if self._isFilter then
			self:CheckAroundPlayerIsShowModel()
		end
		self:UpdateDesertPoison()
		self:UpdateDesertPoisonSleepTime()
		self._synctick = 0;
	end

	if self._sectDestinyTimeLine >= SectDestinyRefreshTime then
		if g_i3k_game_context:GetIsInFactionZone() then
			local isNeedRefresh = false
			local destinyInfo = g_i3k_game_context:getSectDestiny()
			for k ,v in pairs(self._ResourcePoints) do
				if v and v._gcfg and v._gcfg.nType == 12 then
					isNeedRefresh = true
					break
				end
			end
			if isNeedRefresh or #destinyInfo > 0 then
				i3k_sbean.request_sect_destiny_sync_req()
			end
		end
		self._sectDestinyTimeLine = 0
	end
	
	
	return true;
end

function i3k_world:OnMapLoaded()
	if not self._cfg then
		return false;
	end
	g_i3k_game_context:SetjoystickMoveState(false);
	self:OnMapTransportsLoaded()
	-- g_i3k_ui_mgr:OpenUI(eUIID_BattleBase)

	local spawnPos = { x = 0 , y = 0 , z = 0 };
	if self._cfg.openType == g_BASE_DUNGEON then
		spawnPos = i3k_world_pos_to_logic_pos(i3k_db_dungeon_base[self._cfg.id].spawnPos);
	end

	local roleInfo = g_i3k_game_context:GetRoleInfo();
	if roleInfo then
		spawnPos = roleInfo.curLocation.pos;
	end

	local validPos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(spawnPos)));
	spawnPos = i3k_world_pos_to_logic_pos(validPos);

	if self._player then
		local hero = self._player:GetHero();
		if hero then
			hero:SetPos(spawnPos, true);
			hero:SetFaceDir(0, roleInfo.curLocation.rotate, 0);
			-- hero:SetFaceDir(0, 0, 0);
			hero:Show(true, true);
			hero:ClearCombatEffect()
			if hero:CanPlayCombatTypeAction() then
				--hero:PlayCombatAction(hero:GetCombatType())
				hero:ChangeCombatEffect(hero:GetCombatType())
			end
			hero:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
		end

		for k = 1, self._player:GetMercenaryCount() do
			local mercenary = self._player:GetMercenary(k);
			if mercenary and not mercenary:IsDead() then
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

				local pos = i3k_vec3_clone(spawnPos);
				pos.x = pos.x + offX;
				pos.z = pos.z + offZ;

				mercenary:SetPos(pos, true);
				mercenary:SetFaceDir(0, 0, 0);
				mercenary:Show(true, true);

				mercenary:Play(i3k_db_common.engine.defaultStandAction, -1);
			end
		end

		for k = 1, self._player:GetPetCount() do
			local pet = self._player:GetPet(k);
			if pet and not pet:IsDead() then
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

				local pos = i3k_vec3_clone(spawnPos);
				pos.x = pos.x + offX;
				pos.z = pos.z + offZ;

				pet:SetPos(pos, true);
				pet:SetFaceDir(0, 0, 0);
				pet:Show(true, true);

				pet:Play(i3k_db_common.engine.defaultStandAction, -1);
			end
		end

		for k = 1, self._player:GetNPCCount() do
			local npc = self._player:GetNPC(k);
			if npc and not npc:IsDead() then
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

				local pos = i3k_vec3_clone(spawnPos);
				pos.x = pos.x + offX;
				pos.z = pos.z + offZ;

				npc:SetPos(pos, true);
				npc:SetFaceDir(0, 0, 0);
				npc:Show(true, true);

				npc:Play(i3k_db_common.engine.defaultStandAction, -1);
			end
		end
	end


	for _,v in pairs(self._entities) do
		for __,t in pairs(v) do
			t:OnEnterScene()
		end
	end
	local hero = i3k_game_get_player_hero()
	if not g_i3k_game_context:isOnSprog() then
		i3k_game_send_str_cmd(i3k_sbean.role_enter_map.new());
	else
		-- 新手关
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				g_i3k_game_context:SetMoveState(true)
				g_i3k_game_context:SetMapEnter(true);
				g_i3k_ui_mgr:CloseUI(eUIID_Loading);

				local id = g_i3k_game_context:GetRoleType()
				local level = i3k_db_new_player_guide_init[id].initRoleLevel
				local gender = g_i3k_game_context:GetRoleGender()
				local world = i3k_game_get_world();
				local player = i3k_game_get_player()
				local hero = i3k_game_get_player_hero()
				local inSporg = hero._inSprog
				if player and not hero._inSprog then
					world:OnPlayerEnterWorld(nil);
					player:SetSprogEntity(id, level, gender)
					world:OnPlayerEnterWorld(player);
				end
				local stage = g_i3k_game_context:getPlayerLeadStage()
				local args = g_i3k_game_context:getSpawnLoadArgsByStage(stage)
				world:OnSpawnLoaded(args)
				world:OnTrapLoaded({})
				g_i3k_game_context:SetMoveState(false)
				g_i3k_ui_mgr:OpenUI(eUIID_BattleBase)
				g_i3k_ui_mgr:RefreshUI(eUIID_BattleBase)
			end
		end
	end
	--i3k_game_send_str_cmd(i3k_sbean.role_enter_map.new());

	return true;
end

--[[function i3k_world:OnNpcLoaded()
	local dcfg = self._cfg.npcs;
	if dcfg then
		for k,v in pairs(dcfg) do
			local entityNPC = self._entities[eGroupType_O]["i3k_npc|"..tonumber(v)];
			if not entityNPC then
				local SEntity = require("logic/entity/i3k_npc");

				local entityNPC = SEntity.i3k_npc.new(i3k_gen_entity_guid_new(SEntity.i3k_npc.__cname,tonumber(v)));
				local cfg = i3k_db_npc_area[tonumber(v)]
				if cfg and entityNPC:Create(cfg.NPCID, false) then


					if cfg then
						local Dir_m = cfg.dir.y*6.28/360
						local Pos = cfg.pos
						entityNPC:SetFaceDir(0,Dir_m,0);
						entityNPC:SetPos(i3k_world_pos_to_logic_pos(Pos));
					end
					entityNPC:SetGroupType(eGroupType_O);
					entityNPC:Play(i3k_db_common.engine.defaultStandAction, -1);
					entityNPC:Show(true, true, 100);
					entityNPC:SetCtrlType(eCtrlType_Network);
					entityNPC:AddAiComp(eAType_IDLE_NPC);
					entityNPC:AddAiComp(eAType_DEAD);
					entityNPC:NeedUpdateAlives(false);
					entityNPC:OnUpdate(0);
					self:AddEntity(entityNPC);
				end
			end

		end
	end

	return true
end]]

function i3k_world:CreateTransports(trfid)
	local entityTransferPoint = self._TransferPoints[tonumber(trfid)];
	if not entityTransferPoint then
		local SEntity = require("logic/entity/i3k_entity_transferpoint");
		local entityTransferPoint = SEntity.i3k_entity_transferpoint.new(i3k_gen_entity_guid_new(SEntity.i3k_entity_transferpoint.__cname, tonumber(trfid)));
		if entityTransferPoint:Create(tonumber(trfid), false) then
			local cfg = g_i3k_db.i3k_db_get_maze_transfer_points_cfg(trfid, self._cfg.openType)

			if cfg then
				--local Dir_m = cfg.dir.y*6.28/360
				local Pos = cfg.pos
				--entityTransferPoint:SetFaceDir(0,Dir_m,0);
				entityTransferPoint:SetPos(i3k_world_pos_to_logic_pos(Pos));
			end
			entityTransferPoint:Show(true, true, 100);
			entityTransferPoint:SetHittable(false)
			entityTransferPoint:NeedUpdateAlives(false);
			entityTransferPoint:OnUpdate(0);
			entityTransferPoint:Play(i3k_db_common.engine.defaultStandAction, -1)
			self:AddEntity(entityTransferPoint);
			--self._TransferPoints[tonumber(v)] = entityTransferPoint
		end
	end
end

function i3k_world:OnMapTransportsLoaded()
	local dcfg = self:getTransferPoints()
	if dcfg then
		for k,v in pairs(dcfg) do
			self:CreateTransports(v)
		end
	end

	return true
end
function i3k_world:getTransferPoints()	
	local getPoints = 
	{
		[g_MAZE_BATTLE] = function()
			return g_i3k_db.i3k_db_get_maze_transfer_points()
		end
	}
	local maptype = self._cfg.openType
	return getPoints[maptype] and getPoints[maptype]() or self._cfg.tranferpoints; 
end

function i3k_world:OnKeyDown(handled, key)
	if self._player then
		self._player:OnKeyDown(handled, key);
	end

	return 0;
end

function i3k_world:OnKeyUp(handled, key)
	if self._player then
		self._player:OnKeyUp(handled, key);
	end

	return 0;
end

function i3k_world:OnHitObject(handled, entity)
	if self._player then
		return self._player:OnHitObject(handled, entity)
	end

	return 0;
end

function i3k_world:OnHitGround(handled, x, y, z)
	if self._player then
		local guideUI = g_i3k_ui_mgr:GetUI(eUIID_GuideUI)
		if not guideUI then
			self._player:OnHitGround(handled, x, y, z);

			local user_cfg = i3k_get_load_cfg()
			if user_cfg:GetIsTouchOperate() then
				local hero = self._player:GetHero();
				hero._PreCommand = ePreTypeClickMove;
				if hero._AutoFight then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114));
					local _pos = { x = x, y = y, z = z };
					--_pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(_pos)));
					_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(_pos));
					--hero._tempPos = i3k_vec3(x, y, z);
					hero:MoveTo(_pos,true);
					hero._onStopMove = function(pos)
						local p1 = { x = _pos.x, y = 0, z = _pos.z };
						local p2 = { x = pos.x, y = 0, z = pos.z };
						--if i3k_vec3_dist(p1, p2) < 2 then
						if hero._PreCommand == ePreTypeClickMove then
							hero._PreCommand = -1
						end
					end
				end
				if not hero:IsMulMemberState() and not hero:IsHugMemberMode() then
					g_i3k_logic:PlaySceneEffect(i3k_db_common.engine.hitGroundEffect, {x = x, y = y, z = z})
				end
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateTargetNone")
		end
	end

	return 0;
end

function i3k_world:AddEntity(entity, canAttack)
	if not entity then
		return false;
	end

	if not entity:ValidInWorld() then
		return false;
	end
	local entityType = entity:GetEntityType()
	if entity:GetEntityType() == eET_ResourcePoint then
		self._ResourcePoints[entity:GetGuidID()] = entity
	elseif entity:GetEntityType() == eET_Trap then
		if not self._syncRpc then
			self._Traps[entity._gid] = entity
			self._entities[entity:GetGroupType()][entity:GetGUID()] = entity;
		else
			self._Traps[entity:GetGuidID()] = entity;
		end
	elseif entity:GetEntityType() == eET_TransferPoint then
		self._TransferPoints[entity:GetGuidID()] = entity
	elseif entity:GetEntityType() == eET_MapBuff then
		self._mapbuffs[entity:GetGuidID()] = entity
	elseif entity:GetEntityType() == eET_ItemDrop then
		self._ItemDrops[entity:GetGuidID()] = entity
	elseif entity:GetEntityType() == eET_Skill then
		self._SkillEntitys[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_Crop then
		self._ItemCrops[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_Floor then
		self._floorEntitys[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_Common then
		self._commonEntitys[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_Furniture then
		self._floorFurniture[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_WallFurniture then
		self._wallFurniture[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_HouseSkin then
		self._houseSkin[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_CarpetFurniture then
		self._carpetFurniture[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_DisposableNPC then
		self._disposableNpcs[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_CatchSpirit then
		self._catchSpirit[entity:GetGUID()] = entity
	elseif entity:GetEntityType() == eET_GhostFragment then
		self._ghostFragment[entity:GetGUID()] = entity
	else
		self._entities[entity:GetGroupType()][entity:GetGUID()] = entity;
	end

	--己方
	if self._entities[eGroupType_O] then
		local typeO = self._entities[eGroupType_O];
		if typeO then
			for k,v in pairs(typeO) do

				if v:IsNeedUpdateAlives() then
					if entity:GetEntityType() ~= eET_NPC then
						v:AddAlives(entity);
					end
				end
				if entity:IsNeedUpdateAlives() then
					if entity:GetEntityType() ~= eET_NPC then
						entity:AddAlives(v);
					end
				end
			end
		end
	end

	local egtype = entity:GetGroupType();
	--敌方
	if egtype ~= eGroupType_N then
		if self._entities[eGroupType_E] then
			local typeE = self._entities[eGroupType_E];
			if typeE then
				for k,v in pairs(typeE) do
					if v:IsNeedUpdateAlives() then
						v:AddAlives(entity);
					end
					if entity:IsNeedUpdateAlives()then
						entity:AddAlives(v);
					end
				end
			end
		end
	end

	--中立
	if egtype == eGroupType_O then
		if self._entities[eGroupType_N] then
			local typeN = self._entities[eGroupType_N];
			if typeN then
				for k,v in pairs(typeN) do
					if v:IsNeedUpdateAlives() then
						v:AddAlives(entity);
					end
				end
			end
		end
	end

	self:OnAddEntity(entity);
	entity:OnEnterWorld();

	return true;
end

function i3k_world:UpdatePKState(entity, status)
	if entity._PVPStatus then

		local egtype = entity:GetGroupType();
		if egtype ~= eGroupType_N then
			if self._entities[eGroupType_E] then
				local typeE = self._entities[eGroupType_E];
				if typeE then
					for k,v in pairs(typeE) do
						if v:IsNeedUpdateAlives() then
							v:RmvAlives(entity);
							v:AddAlives(entity);
						end
						if entity:IsNeedUpdateAlives()then
							entity:RmvAlives(v);
							entity:AddAlives(v);
						end
					end
				end
			end
		end

		if self._entities[eGroupType_O] then
			local typeO = self._entities[eGroupType_O];
			if typeO then
				for k,v in pairs(typeO) do
					if v:IsNeedUpdateAlives() then
						if v._guid ~= entity._guid then
							if self:IsCanAdd(v, entity) then
								v:RmvAlives(entity);
								v:AddAlives(entity);
							end
						end
					end

					if entity:IsNeedUpdateAlives() then
						if v:GetEntityType() == eET_Player or v:GetEntityType() == eET_Mercenary or v:GetEntityType() == eET_Pet or v:GetEntityType() == eET_Summoned or v:GetEntityType() == eET_Car then
							if v._guid ~= entity._guid then
								if self:IsCanAdd(entity, v) then
									entity:RmvAlives(v);
									entity:AddAlives(v);
								end
							end
						end
					end
				end
			end
		end
	end
end

function i3k_world:IsCanAdd(entity, typeOentity)
	--自己和自己的佣兵不用改变Pk状态
	if entity and typeOentity and entity._hoster then
		if entity._hoster._guid == typeOentity._guid then
			return false;
		end
	end

	if entity and typeOentity and typeOentity._hoster then
		if typeOentity._hoster._guid == entity._guid then
			return false;
		end
	end

return true;
end

function i3k_world:IsGridEntity(entity)
	if not entity or
		entity:GetEntityType() == eET_NPC or
		entity:GetEntityType() == eET_ResourcePoint--[[or
		entity:GetEntityType() == eET_MarryCruise]]  then
		return false
	end
	return true
end

function i3k_world:OnAddEntity(entity)
	if not self:IsGridEntity(entity) then
		return
	end
	local grid = self._grid_mgr:GetGridByPos(entity._curPos);
	if grid then
		grid:AddEntity(entity);
	end
end

function i3k_world:RmvEntity(entity, canAttack)
	if entity then
		if entity:ValidInWorld() then
			entity:OnLeaveWorld();

			if self._entities[eGroupType_O] then
				local typeO = self._entities[eGroupType_O];
				if typeO then
					for k,v in pairs(typeO) do
						if v:IsNeedUpdateAlives() then
							if not canAttack then
								v:RmvAlives(entity);
							end
						end
						if entity:IsNeedUpdateAlives() then
							if not canAttack then
								entity:RmvAlives(v);
							end
						end
					end
				end
			end

			self:OnRmvEntity(entity);

			if entity:GetEntityType() == eET_ResourcePoint then
				self._ResourcePoints[entity:GetGuidID()] = nil
			elseif entity:GetEntityType() == eET_Trap then
				self._Traps[entity:GetGuidID()] = nil
				if not self._syncRpc then
					self._entities[entity:GetGroupType()][entity:GetGUID()] = nil;
				end
			elseif entity:GetEntityType() == eET_TransferPoint then
				self._TransferPoints[entity:GetGuidID()] = nil
			elseif entity:GetEntityType() == eET_MapBuff then
				self._mapbuffs[entity:GetGuidID()] = nil
			elseif entity:GetEntityType() == eET_ItemDrop then
				self._ItemDrops[entity:GetGuidID()] = nil
			elseif entity:GetEntityType() == eET_Skill then
				self._SkillEntitys[entity:GetGuidID()] = nil
			elseif entity:GetEntityType() == eET_Crop then
				self._ItemCrops[entity:GetGuidID()] = nil
			elseif entity:GetEntityType() == eET_Common then
				self._commonEntitys[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_Floor then
				self._floorEntitys[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_Furniture then
				self._floorFurniture[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_WallFurniture then
				self._wallFurniture[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_HouseSkin then
				self._houseSkin[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_CarpetFurniture then
				self._carpetFurniture[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_DisposableNPC then
				self._disposableNpcs[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_CatchSpirit then
				self._catchSpirit[entity:GetGUID()] = nil
			elseif entity:GetEntityType() == eET_GhostFragment then
				self._ghostFragment[entity:GetGUID()] = nil
			else
				self._entities[entity:GetGroupType()][entity:GetGUID()] = nil;
			end

			return true;
		end
	end

	return false;
end

function i3k_world:OnRmvEntity(entity)
	if not self:IsGridEntity(entity) then
		return
	end

	local grid = self._grid_mgr:GetGridByPos(entity._curPos);
	if grid then
		grid:RmvEntity(entity);
	end
end

function i3k_world:ReleaseEntity(entity, force)
	if entity then -- 此处添加判空校验，协程调用可能引起的未知错误
		if not force and entity:Cacheable() then
			entity:EnterLeaveCache();
			--entity:SetTitleVisiable(false);
			entity:StopMove();
		else
			self:RmvEntity(entity);
			entity:Release();
		end
	end
end

function i3k_world:UpdateGrid(entity)
	if not self:IsGridEntity(entity) then
		return
	end
	if entity then
		local grid_o = entity:GetGrid();
		local grid_n = self._grid_mgr:GetGridByPos(entity._curPos);

		if grid_n then
			if (not grid_o) or grid_o._guid ~= grid_n._guid then
				if grid_o then
					grid_o:RmvEntity(entity);
				end

				grid_n:AddEntity(entity);
			end
		end
	end
end

function i3k_world:GetAliveEntities(entity, gType)
	local alives = { };
	if not entity or entity:IsDead() then return alives; end

	local heros = self._entities[gType];
	if heros then
		for k, v in pairs(heros) do
			if not v:IsDead() then
				table.insert(alives, { dist = i3k_vec3_len(i3k_vec3_sub1(entity._curPos, v._curPos)), entity = v });
			end
		end
	end

	return alives;
end

function i3k_world:GetPlayerPos()
	return self._player:GetHeroPos();
end

function i3k_world:GetTargetsByPos(entity, gType)
	local alives = { };

	if not entity then  return alives; end

	local heros = self._entities[gType];
	if heros then
		for k, v in pairs(heros) do
			if not v:IsDead() then
				table.insert(alives, { dist = i3k_vec3_len(i3k_vec3_sub1(entity._curPos, v._curPos)), entity = v });
			end
		end
	end

	return alives;
end

function i3k_world:GetMapGuideShowCheck()
	local showGuide = false
	if self._mapType == g_BASE_DUNGEON or self._mapType == g_ACTIVITY or self._mapType == g_FACTION_DUNGEON or self._mapType == g_TOWER or self._mapType == g_AT_ANY_MOMENT_DUNGEON then
		local hero = i3k_game_get_player_hero()
		if hero  then
			local radius = hero:GetPropertyValue(ePropID_alertRange)
			local target = hero._alives[2][1]; -- 敌方

			if not target or target.dist > radius then
				if self._openType == g_FIELD then
					if #self._spawns > 0 or self._curArea then
						showGuide = true;
					end
				else
					local spawnID = math.abs(g_i3k_game_context:GetDungeonSpawnID())
					if spawnID ~= 0 then
						spawnPointID = i3k_db_spawn_area[spawnID].spawnPoints[1]
						if i3k_db_spawn_point[spawnPointID].spawnType ~= 3 then
							showGuide = true;
						end
					end

				end
			end
		end
	end
	return showGuide
end

function i3k_world:GetMapGuide()
	if self._showGuide then
		local _pos = nil;
		if self._openType == g_FIELD then
			if #self._spawns > 0 or self._curArea then
				local isfind = false
				for k1,v1 in pairs(self._curArea._spawns) do
					for k2,v2 in pairs(v1._monsters) do
						if not v2:IsDead() then
							isfind = true;
							break;
						end
					end
					if isfind then
						_pos = v1._cfg.pos;
						break;
					end
				end

				if not _pos then
					_pos = self._curArea._spawns[1]._cfg.pos
				end

				if _pos then
					self:ChangedGuideDir(_pos);
				end
			else
				self._showGuide = false;
			end
		else
			local spawnID = math.abs(g_i3k_game_context:GetDungeonSpawnID())
			if spawnID ~= 0 then
				spawnPointID = i3k_db_spawn_area[spawnID].spawnPoints[1]
				_pos = i3k_db_spawn_point[spawnPointID].pos
			end
			if _pos then
				self:ChangedGuideDir(_pos);
			end
		end
	end
end

function i3k_world:ChangedGuideDir(pos)
	local hero = i3k_game_get_player_hero()
	if hero and pos then
		local p1 = i3k_vec3_clone(pos);
		local p2 = i3k_vec3_clone(hero._curPosE);
		local camera = i3k_game_get_logic():GetMainCamera();
		local rot_y = i3k_vec3_angle1(p1, p2, i3k_vec3(1, 0, 0));
		g_i3k_game_context:OnGuideDirChangedHandler(rot_y - math.pi * 2 + math.pi / 2 - camera._pose.rot)
	end
end

-- 藏宝图  挖矿寻路
function i3k_world:ChangeTreasureGuideDir(pos)
	local hero = i3k_game_get_player_hero()
	if hero and pos then
		local p1 = i3k_vec3_clone(pos);
		local p2 = i3k_vec3_clone(hero._curPosE);
		local camera = i3k_game_get_logic():GetMainCamera();
		local rot_y = i3k_vec3_angle1(p1, p2, i3k_vec3(1, 0, 0));
		local distance =( (p1.x - p2.x)*(p1.x - p2.x) + (p1.z - p2.z)*(p1.z - p2.z))
		g_i3k_game_context:OnTreasureGuideChangedHandler(rot_y - math.pi * 2 + math.pi / 2 - camera._pose.rot, distance)
	end
end

--精灵寻路
function i3k_world:ChangeSpiritGuideDir(range, skillRange)
	local hero = i3k_game_get_player_hero()
	local distance = nil
	local curMonster = nil	
	local heroPos = i3k_vec3_clone(hero._curPosE);
	if hero and range then
		if self._entities and self._entities[eGroupType_E] then
			local entities = self._entities[eGroupType_E]
			for k,v in pairs(entities) do
				if v:GetEntityType() == eET_Monster then
					local monsterPos = v._curPosE
					local curDistance = i3k_vec3_dist(monsterPos , heroPos)
					local curRange = range + (hero:GetRadius() + v:GetRadius())/100
					if not v:IsDead() and curDistance  < curRange  and (not distance or curDistance < distance) then
						distance = curDistance 
						curMonster = v
					end
				end
			end
		end	
	end
	if distance then 
		if skillRange + (hero:GetRadius() + curMonster:GetRadius())/100  > distance   then 
			return nil, g_SPIRIT_SEARCH_SHILL
		else
			local camera = i3k_game_get_logic():GetMainCamera();
			local rot_y = i3k_vec3_angle1(curMonster._curPosE, heroPos, i3k_vec3(1, 0, 0));
			return rot_y - math.pi * 2 + math.pi / 2 - camera._pose.rot, g_SPIRIT_SEARCH_SHOW
		end
	end
	return nil, g_SPIRIT_SEARCH_NONE
end
function i3k_world:GetNPCEntityByID(cfgID)
	for k,v in pairs(self._entities[eGroupType_O]) do
		if v:GetEntityType() == eET_NPC then
			if v._id == cfgID then
				return v;
			end
		end
	end
	return ;
end

-- 势力声望需要设置特定的npc头顶图片信息的显隐
function i3k_world:SetNpcEntityTitleVisible(npcID, visible)
	local entity = self:GetNPCEntityByID(npcID)
	if entity then
		entity:SetNpcTitleImageVisiable(visible);
	end
end

function i3k_world:GetNeutralNpcByID(npcID)
	return self._entities[eGroupType_O]["i3k_npc|"..npcID]
end

function i3k_world:GetPetRacePet(id)
	return self._entities[eGroupType_N]["i3k_pet_race|"..id]
end

function i3k_world:GetHomePet(id)
	return self._entities[eGroupType_N]["i3k_home_pet|"..id]
end
function i3k_world:GetPetRaceRoad()
	return self._entities[eGroupType_N]["i3k_mercenary|"..PET_RACE_ROAD_TYPE]
end
function i3k_world:GetDanceNpcs()
	return self._entities[eGroupType_N]["i3k_mercenary|"..DANCE_NPC_TYPE]
end

function i3k_world:GetAllRacePet()
	local allRacePet = {}
	for _, v in pairs(self._entities[eGroupType_N]) do
		if v:GetEntityType() == eET_PetRace then
			allRacePet[v._guid] = v
		end
	end
	return allRacePet
end

-- etype entity type
function i3k_world:GetEntity(etype, id, isCheck)
	local guid = i3k_game_on_entity_guid(etype.."|"..id)
	if etype == eET_Player then
		if isCheck then
			return self._entities[eGroupType_O][guid]
		else
			return self._entities[eGroupType_O][guid] or self._passengers[guid] or self._embracers[guid]
		end
	elseif etype == eET_Monster then
		return self._entities[eGroupType_E][guid];
	elseif etype == eET_Trap then
		return self._Traps[id];
	elseif etype == eET_Skill then
		return self._SkillEntitys[guid]
	elseif etype == eET_ResourcePoint then
		return self._ResourcePoints[id]
	elseif etype == eET_Common then
		return self._commonEntitys[guid]
	elseif etype == eET_Floor then
		return self._floorEntitys[id]
	elseif etype == eET_Furniture then
		return self._floorFurniture[id]
	elseif etype == eET_WallFurniture then
		return self._wallFurniture[id]
	elseif etype == eET_HouseSkin then
		return self._houseSkin[id]
	elseif etype == eET_CarpetFurniture then
		return self._carpetFurniture[id]
	elseif etype == eET_DisposableNPC then
		return self._disposableNpcs[guid]
	elseif etype == eET_CatchSpirit then
		return self._catchSpirit[id]
	elseif etype == eET_GhostFragment then
		return self._ghostFragment[id]
	else
		return  self._entities[eGroupType_O][guid];
	end
end

function i3k_world:GetEntitiesInWorld(pos, etype)
	if self._grid_mgr then
		return self._grid_mgr:GetValidEntitiesByPos(pos, function(entity) return entity:GetEntityType() == etype; end);
	end

	return { };
end

function i3k_world:ChangeEntitySectVisible(vis)
	for k,v in pairs(self._entities[eGroupType_O]) do
		if v:GetEntityType() == eET_Player then
			v:SetHeroSectNameVisiable(vis)
		end
	end
end

function i3k_world:ChangeOtherOnesTitleVisible(isShow)
	for k,v in pairs(self._entities[eGroupType_O]) do
		if v:GetEntityType() == eET_Player then
			local hero = i3k_game_get_player_hero()
			if hero:GetGuidID() ~= v:GetGuidID() then
				v:SetHeroTitleVisiable(isShow)
			end
		end
	end
end

--改变镖车的显示状态
function i3k_world:ChangeCarShowState()
	local isShow =  not g_i3k_game_context:GetEscortIsHide()
	local teamId = g_i3k_game_context:GetTeamId()
	local roleId = g_i3k_game_context:GetRoleId()
	for k,v in pairs(self._entities[eGroupType_O]) do
		if v:GetEntityType() == eET_Car then
			local guid = string.split(v._guid, "|")
			if tostring(roleId) ~= guid[2] then
				v:Show(isShow,true)
				v:SetHittable(isShow)
				v:SetTitleShow(isShow)
				v:SetTitleVisiable(isShow)
			end
		end
	end
end

function i3k_world:SetCustomRoles(ids)
	self._updatePlayerList = ids;
end

function i3k_world:CheckCustomRoles(RoleID,curHP,maxHP)
	if self._updatePlayerList[RoleID] then
		local entity = self:GetEntity(eET_Player, RoleID)
		if entity then
			local ScurHP = entity:GetPropertyValue(ePropID_hp)
			local SmaxHP = entity:GetPropertyValue(ePropID_maxHP)
			if curHP then
				ScurHP = curHP
			end
			if maxHP then
				SmaxHP = maxHP
			end
			g_i3k_game_context:OnListenedCustomRoleHpChangedHandler(RoleID, ScurHP,SmaxHP)
		end
		return true;
	end
	return false;
end

function i3k_world:ReleasePassenger(guid)
	if self._passengers[guid] then
		self._passengers[guid] = nil;
	end
end

function i3k_world:ReleaseEmbracer(guid)
	if self._embracers[guid] then
		self._embracers[guid] = nil;
	end
end

function i3k_world:ReleaseShowPlayer(guid)
	if self._showPlayer[guid] then
		self._showPlayer[guid] = nil;
	end
end

function i3k_world:CreatePlayerModelFromCfg(RoleID, _pos, Dir, args) -- 创建玩家模型
	local Pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos))));
	local entityPlayer = self:GetEntity(eET_Player, RoleID);
	if not entityPlayer then
		local cfg = g_i3k_db.i3k_db_get_general(args.RoleType);
	 	local SEntity = require("logic/entity/i3k_entity_net");
		local Guid = self:CreateOnlyGuid(1, eET_Player, RoleID);
		local entityPlayer = SEntity.i3k_entity_net.new(Guid);
		if entityPlayer:Create(args.RoleType, args.Rolename, args.Gender, args.Hair, args.Face, args.nLevel,{}, cfg, eET_Player, false, args.sectname, args.sectID, args.sectPosition, args.sectIcon, args.permanentTitle, args.timedTitles, args.bwtype, args.carRobber, args.carOwner) then
			entityPlayer:CreatePlayerRes()
			entityPlayer:UpdateProperty(ePropID_maxHP, 1, args.nMaxHP, true, false,true);
			entityPlayer:UpdateHP(args.nCurHP);
			entityPlayer:UpdateBloodBar(entityPlayer:GetPropertyValue(ePropID_hp) / entityPlayer:GetPropertyValue(ePropID_maxHP));
			entityPlayer:NeedUpdateAlives(false);
			entityPlayer:SetFaceDir(Dir.x, Dir.y, Dir.z);
			entityPlayer:SetPos(Pos);
			entityPlayer:SetGroupType(eGroupType_O);
			entityPlayer:SetHittable(true);
			entityPlayer:Show(true, true, 100);
			entityPlayer:SetCtrlType(eCtrlType_NetWork);
			self:AddEntity(entityPlayer);
		end

		if args.horseSpiritShowID ~= 0 then
			entityPlayer:SetRideSpiritCurShowID(args.horseSpiritShowID)
		end
		entityPlayer:setSoaringDisplay(args.soaringDisplay)
		if args.soaringDisplay.footEffect ~= 0 then
			entityPlayer:changeFootEffect(args.soaringDisplay.footEffect)
		end
		for v,k in pairs(args.Equips) do
			if k then
				entityPlayer:AttachEquip(k);
			end
		end
		if args.roleEquipsDetails then
			entityPlayer._equipinfo = args.roleEquipsDetails
			local weaponDisplay = i3k_get_soaring_display_info(args.soaringDisplay)
			if weaponDisplay ~= g_FLYING_SHOW_TYPE then
				entityPlayer:AttachEquipEffect(args.roleEquipsDetails)
			end
		end
		if args.Motivate then
			entityPlayer:UseWeapon(args.Weapon,args.weaponForm)
			entityPlayer:OnSuperMode(true)
		end

		if args.attackMode then
			entityPlayer:SetPVPStatus(args.attackMode)
		end

		if args.pkGrade then
			entityPlayer._PVPColor = args.pkGrade
		end

		if args.pkState then
			entityPlayer._PVPFlag = args.pkState
		end
		self:UpdatePKState(entityPlayer);
		if args.carRobber then
			entityPlayer._iscarRobber = args.carRobber
		end
		if args.carOwner then
			entityPlayer._iscarOwner = args.carOwner
		end
		entityPlayer:TitleColorTest();
		if args.Buffs then
			for k, v in pairs(args.Buffs) do
				BUFF = require("logic/battle/i3k_buff");
				local bcfg = i3k_db_buff[v];
				local buff = BUFF.i3k_buff.new(nil, v, bcfg);
				if buff then
					entityPlayer:AddBuff(nil, buff);
				end
			end
		end
		if args.HeadIconID then
			entityPlayer._headiconID = args.HeadIconID
		end

		if args.HeadBorder then
			entityPlayer._headBorder = args.HeadBorder
		end

		if args.sectIcon then
			entityPlayer._sectIcon = args.sectIcon
		end
		if args.horseShowID ~= 0 then
			entityPlayer:UseRide(args.horseShowID)
		end
		if args.weaponSoulShow then
			if args.weaponSoulShow ~= 0 then
				entityPlayer:SetWeaponSoulShow(true)
			else
				entityPlayer:SetWeaponSoulShow(false)
			end
			entityPlayer:AttachWeaponSoul(args.weaponSoulShow);
		end

		if args.fashions[g_FashionType_Dress] then
			entityPlayer:AttachFashion(args.fashions[g_FashionType_Dress], entityPlayer:IsFashionShow(), g_FashionType_Dress);
		end
		
		if args.fashions[g_FashionType_Weapon]   then
			entityPlayer:AttachFashion(args.fashions[g_FashionType_Weapon], entityPlayer:IsFashionWeapShow(), g_FashionType_Weapon)
		end

		if not entityPlayer:isSpecial() then
			entityPlayer:changeWeaponShowType()
		end

		if args.alterID and args.alterID ~= 0 then
			entityPlayer:MissionMode(true,args.alterID)
		end
		if args.bwtype then
			entityPlayer._bwtype = args.bwtype
		end
		entityPlayer:SetTitleShow(self:CheckTitleShow(entityPlayer))
		local flag = 0
		if entityPlayer:GetTitleShow() then
			flag = 1
		end

		if args.socialActionID ~= 0 then
			entityPlayer._socialactionID = args.socialActionID
			entityPlayer:PlaySocialAction(args.socialActionID,true)
		end

		if args.Armor.id~=0 then
			entityPlayer._armor.id = args.Armor.id
			entityPlayer._armor.stage = args.Armor.rank
			entityPlayer:SetArmorEffectHide(args.Armor.hideEffect)
			entityPlayer:ChangeArmorEffect()
		end

		if entityPlayer:isSpecial() then
			entityPlayer:SpringSpecialShow();
		end

		if args.buffDrugs then
			entityPlayer._buffDrugs = args.buffDrugs
		end
		if args.combatType > 0 then
			entityPlayer:SetCombatType(args.combatType)
		end
	end
end

function i3k_world:CreatePlayerStatuFromCfg(ID, _pos, Dir, args)  ----用于创建荣耀殿堂的雕像
	local Pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos))));
	local entityPlayerStatue = self:GetEntity(eET_PlayerStatue, ID);
	if not entityPlayerStatue then
		local cfg = g_i3k_db.i3k_db_get_general(args.RoleType);
	 	local SEntity = require("logic/entity/i3k_entity_net");
		local Guid = self:CreateOnlyGuid(1, eET_PlayerStatue, ID);
		local entityPlayerStatue = SEntity.i3k_entity_net.new(Guid);
		if entityPlayerStatue:Create(args.RoleType, args.Rolename, args.Gender, args.Hair, args.Face, args.nLevel,{}, cfg, eET_PlayerStatue, false, args.sectname, args.sectID, args.sectPosition, args.sectIcon, args.permanentTitle, args.timedTitles, args.bwtype, args.carRobber, args.carOwner) then
			entityPlayerStatue:CreatePlayerRes()
			entityPlayerStatue:SetScale(1.2)
			entityPlayerStatue:SetFaceDir(Dir.x, Dir.y, Dir.z);
			entityPlayerStatue:SetPos(Pos)
			entityPlayerStatue:SetTitleVisiable(false)
			entityPlayerStatue:SetGroupType(eGroupType_O);
			entityPlayerStatue:SetHittable(true);
			entityPlayerStatue:Show(true, true, 100);
			entityPlayerStatue:SetCtrlType(eCtrlType_NetWork);
			entityPlayerStatue:SetStatuTag(args.RoleID, args.StatueType);
			self:AddEntity(entityPlayerStatue);
		end
		entityPlayerStatue:setSoaringDisplay(args.soaringDisplay)
		
		for v,k in pairs(args.Equips) do
			if k then
				entityPlayerStatue:AttachEquip(k);
			end
		end
		local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(entityPlayerStatue._soaringDisplay)
		if args.roleEquipsDetails then
			entityPlayerStatue._equipinfo = args.roleEquipsDetails
			if weaponDisplay ~= g_FLYING_SHOW_TYPE then
				entityPlayerStatue:AttachEquipEffect(args.roleEquipsDetails)
		end
		end
		
		if args.fashions[g_FashionType_Weapon]   then
			entityPlayerStatue:AttachFashion(args.fashions[g_FashionType_Weapon],entityPlayerStatue:IsFashionWeapShow(), g_FashionType_Weapon)
		end
		if args.fashions[g_FashionType_Dress]  then
			entityPlayerStatue:AttachFashion(args.fashions[g_FashionType_Dress], entityPlayerStatue:IsFashionShow(), g_FashionType_Dress)
		end
		if not entityPlayerStatue:isSpecial() then
			entityPlayerStatue:changeWeaponShowType()
		end

		if args.weaponSoulShow then
			if args.weaponSoulShow ~= 0 then
				entityPlayerStatue:SetWeaponSoulShow(true)
			else
				entityPlayerStatue:SetWeaponSoulShow(false)
			end
			entityPlayerStatue:AttachWeaponSoul(args.weaponSoulShow);
		end

		if args.bwtype then
			entityPlayerStatue._bwtype = args.bwtype
		end
	end
end

function i3k_world:UpdateMonsterSelectEffect()
	if table.nums(self._specialMonsters) > 0 then
		for k, e in pairs(self._specialMonsters) do
			local m = self._entities[eGroupType_E][k]
			if m and e and not m._specialEffID and not m._targetSelEffID and not m:IsDead() then
				e:AddSpecialEffect()
			end
		end
	end
end

function i3k_world:UpdateItemDrop()
	local player = i3k_game_get_player()
	local mapty = 
	{
		[g_FIELD] = true,
		[g_FACTION_TEAM_DUNGEON] = true,
		[g_ANNUNCIATE] = true,
		[g_DESERT_BATTLE] = true,
	}
	
	if mapty[self._mapType] and self._ItemDrops then
		for i, e in pairs(self._ItemDrops) do
			if e._entity and (e:GetStatus() == eSItemDropActive or e:GetStatus() == eSItemDropWaitRequire) then
				local Pos = player:GetHeroPos();
				local dist = i3k_vec3_sub1(Pos, e._curPos);
				local ItemDropAutoRange = 1500	
				
				if self._cfg and self._cfg.ItemDropAutoRange then
					ItemDropAutoRange = self._cfg.ItemDropAutoRange
				end
				
				if ItemDropAutoRange > i3k_vec3_len(dist) then
					e:WaitRequire();
					e._Deny = 0;
					player:AddPickup(e._gid, e._itemId, e._count);
				end
			end
		end
	end
end

function i3k_world:ChangeFactionFlag(id)
	if self._ResourcePoints then
		local tmp = self._ResourcePoints
		for _,e in pairs(self._ResourcePoints) do
			if e._gcfg then
				if e._gcfg.nType == 5 then
					e:RestoreModelFacade()
					e:ChangeModelFacade(id)
					e:Play("stand",-1,true)
					e:UpdateFactionFlagLable()
				end
			end
		end
	end
end
--改变帮派战旗子状态
function i3k_world:ChangeFactionWarFlag(flagId, ownType)
	if self._ResourcePoints then
		local res = self._ResourcePoints[flagId]
		if res and res:IsResCreated() then
			res:setOwnType(ownType)
		end
	end
end

--改变荒漠补给点状态
function i3k_world:ChangeDesertBattleRes()
	if self._ResourcePoints then
		--[[local res = self._ResourcePoints[resId]
		if res and res:IsResCreated() then
			res:SetDesertTitleState(ownType, refreshTime)
		end--]]
		local ownType =0
		local ownType = 0
		for k, res in pairs(self._ResourcePoints) do
			ownType, refreshTime = g_i3k_db.i3k_desert_resource_can_open(k)
			if ownType then
				res:SetDesertTitleState(1, refreshTime)
			else
				res:SetDesertTitleState(0, refreshTime)
			end
			
		end
	end
end

function i3k_world:CheckAroundPlayerIsShowModel()
	local playerNum = g_i3k_game_context:GetSetUpPlayerNum()
	local hero = i3k_game_get_player_hero()
	for i, e in pairs(self._entities[eGroupType_O]) do
		if e:GetEntityType() == eET_Player and not e:IsPlayer() then
			local dist = i3k_vec3_len(i3k_vec3_sub1(e._linkParent and e._linkParent._curPos or e._curPos, hero._curPos))
			if dist <= i3k_db_common.filter.screenRadius then
				-- 如若有玩家进入到显示范围且显示人数未满，则加入到显示组中
				if not e._behavior:Test(eEBInvisible) and  not self._showPlayer[e._guid] and table.nums(self._showPlayer) < playerNum then
					self._showPlayer[e._guid] = e
					self._isShowPlayerChanged = true
				end
			else
				if self._showPlayer[e._guid] then
					self._showPlayer[e._guid] = nil
					self._isShowPlayerChanged = true
				end
			end
		end
	end
	if playerNum == 0 then
		self._showPlayer = {}
		self._isShowPlayerChanged = true
	elseif table.nums(self._showPlayer) > playerNum then
		--显范围内玩家数量大于设置， 随机删除显示组中玩家模型
		while table.nums(self._showPlayer) > playerNum do
			local tmp = {}
			for k, v in pairs(self._showPlayer) do
				table.insert(tmp, k)
			end
			if #tmp > 0 then
				local exp = SelectExp[3];
				exp(tmp)
			end
			self._isShowPlayerChanged = true
			self._showPlayer[tmp[1]] = nil
			if table.nums(self._showPlayer) == playerNum then
				break
			end
		end
	end
	self:UpdatePlayerIsShow()
	self:UpdateMulHorseIsShow()
	self:UpdateHugPlayerIsShow();
end

function i3k_world:UpdatePlayerIsShow()
	if self._isShowPlayerChanged then
		for i, e in pairs(self._showPlayer) do
			e:Show(true, true)
			e:ShowCarryItem(true)
			local usecfg = i3k_get_load_cfg()
			if usecfg then
				local OthersIsShow = usecfg:GetIsShowOthersHeadInfo()
				e:SetHeroTitleVisiable(OthersIsShow)
			else
				e:SetHeroTitleVisiable(false)
			end
		end
		if table.nums(self._showPlayer) > 0 then
			self._isShowPlayerChanged = false
		end
		for i, e in pairs(self._entities[eGroupType_O]) do --不在显示组的全部隐藏
			if e:GetEntityType() == eET_Player and not e:IsPlayer() then
				if not self._showPlayer[e._guid] then
					e:HidePlayerModel()
					e:ShowCarryItem(false)
					e:SetHeroTitleVisiable(false)
				end
			end
		end
	end
	self:UpdateMercenaryIsShow()
end

function i3k_world:UpdateMercenaryIsShow()
	for i, e in pairs(self._entities[eGroupType_O]) do
		if e:GetEntityType() == eET_Mercenary then
			local ower = string.split(e._guid, "|");
			local hoster = self:GetEntity(eET_Player, ower[3])
			if hoster then
				if self._showPlayer[hoster._guid] then
					e:Show(true, true)
					e:SetHittable(true)
				else
					local hero = i3k_game_get_player_hero()
					if hoster._guid ~= hero._guid then --主角出战的随从不屏蔽
						e:Show(false, true)
						e:SetHittable(false)
					end
				end
			end
		end
	end
end

function i3k_world:UpdateIsShowPlayerSate(state)
	self._isShowPlayerChanged = state
end

function i3k_world:IsShowPlayer(entity)
	return self._showPlayer[entity._guid]
end

function i3k_world:UpdateMulHorseIsShow()
	local passengers = self._passengers
	local hero = i3k_game_get_player_hero()
	if hero then
		local heroLinkParent = hero._linkParent
		for k, v in pairs(self._passengers) do
			local _guid = string.split(v._guid, "|")
			local playerId = tonumber(_guid[2])
			local Entity = v._linkParent
			if (Entity and self._showPlayer[Entity._guid]) or v._linkParent:IsPlayer() or (heroLinkParent and heroLinkParent._guid ==  Entity._guid) then
				v:Show(true, true)
			end
		end
		for _, v in pairs(self._entities[eGroupType_O]) do
			local _guid = string.split(v._guid, "|")
			local playerId = tonumber(_guid[2])
			if v:GetEntityType() == eET_Player then
				if hero:GetMulLeaderId() == playerId then
					v:Show(true, true)
				end
			end
		end
	end
end

function i3k_world:UpdateHugPlayerIsShow()
	local hero = i3k_game_get_player_hero()
	if hero then
		local heroLinkParent = hero._linkHugParent
		for k, v in pairs(self._embracers) do
			local _guid = string.split(v._guid, "|")
			local playerId = tonumber(_guid[2])
			local Entity = v._linkHugParent
			if (Entity and self._showPlayer[Entity._guid]) or v._linkHugParent:IsPlayer() or (heroLinkParent and heroLinkParent._guid ==  Entity._guid) then
				v:Show(true, true, nil, false)
			end
		end
		for _, v in pairs(self._entities[eGroupType_O]) do
			local _guid = string.split(v._guid, "|")
			local playerId = tonumber(_guid[2])
			if v:GetEntityType() == eET_Player then
				if hero:GetHugLeaderId() == playerId then
					v:Show(true, true)
				end
			end
		end
	end
end

function i3k_world:CreateMarryCruiseEntity(id, cfgID, manID, womanID, manName, womanName, location)
	local logic = i3k_game_get_logic();
	local player = i3k_game_get_player()
	local hero = i3k_game_get_player_hero()
	local _guid = hero and string.split(hero._guid, "|")
	local heroID = tonumber(_guid[2])
	local sMarry = require("logic/entity/i3k_marry_cruise");
	local MarryCruise = sMarry.i3k_marry_cruise.new(i3k_gen_entity_guid_new(sMarry.i3k_marry_cruise.__cname,id));
	if MarryCruise:Create(cfgID, manID, womanID, manName, womanName, location) then
		MarryCruise:SetGroupType(eGroupType_O);
		if hero and (heroID == manID or heroID == womanID) then
			hero:Show(false)
			hero:DetachCamera()
			MarryCruise:AttachCamera(logic:GetMainCamera())
			if g_i3k_ui_mgr then
				g_i3k_ui_mgr:HideNormalUI()
			end
		end
		local pos = location.position
		local rot = location.rotation
		local r = i3k_vec3_angle2(i3k_vec3(rot.x,rot.y,rot.z), i3k_vec3(1, 0, 0));
		MarryCruise:SetFaceDir(0, r, 0);
		MarryCruise:SetPos(pos);
		MarryCruise:Show(true, true);
		MarryCruise:Play(i3k_db_common.engine.defaultStandAction, -1);
		MarryCruise:AddAiComp(eAType_NETWORK_MOVE);
		MarryCruise:SetHittable(false);
		player:AddMarryCruise(MarryCruise)
		self:AddEntity(MarryCruise);
	end
end


-- 宠物赛跑相关
function i3k_world:CreatePetRacePet(id, location)
	if not self:GetPetRacePet(id) then
		local petClass = require("logic/entity/i3k_pet_race")
		local pet = petClass.i3k_pet_race.new(i3k_gen_entity_guid_new(petClass.i3k_pet_race.__cname, id))
		local modelID = i3k_db_common.petRacePets[id].modelID
		pet:CreatePetRaceRes(id, modelID)
		local pos = location.position
		local rot = location.rotation
		local r = i3k_vec3_angle2(i3k_vec3(rot.x,rot.y,rot.z), i3k_vec3(1, 0, 0));
		pet:SetFaceDir(0, r, 0);
		pet:SetPos(pos);
		pet:Show(true, true);
		pet:ShowTitleNode(true)
		pet:Play(i3k_db_common.engine.defaultStandAction, -1);
		self:AddEntity(pet);
	end
end

function i3k_world:RemovePetRacePets(pets)
	for _, v in ipairs(pets) do
		local entity = self:GetPetRacePet(v)
		if entity then
			self:ReleaseEntity(entity, true)
		end
	end
end

function i3k_world:PetRaceMovePos(id, pos, speed, rotation, timeTick)
	if speed < 10 then
		speed = 10 -- 客户端限制一下，速度小于这个阀值的时候，就给他一个最小速度，防止动作播放不出来
	end
	local entity = self:GetPetRacePet(id)
	if entity then
		entity:PlayPetRunAction()
		entity:UpdateProperty(ePropID_speed, 1, speed, true, false, true)
		if i3k_vec3_dist(entity._curPos, pos) > 300 then
			entity:SyncPos(pos)
		end
		entity:SyncVelocity(rotation, timeTick)
	end
end

function i3k_world:PetRaceStopMove(id, pos, timeTick)
	local entity = self:GetPetRacePet(id)
	if entity then
		entity:SetPos(pos)
		entity:SyncStopMove(timeTick)
	end
end

-- 添加赛道
function i3k_world:AddPetRaceRoad()
	if self:GetPetRaceRoad() then
		return -- 如果已经有一个赛道的实例了
	end
	local petClass = require("logic/entity/i3k_mercenary")
	local pet = petClass.i3k_mercenary.new(i3k_gen_entity_guid_new(petClass.i3k_mercenary.__cname, PET_RACE_ROAD_TYPE))
	pet:CreatePetRaceRes(PET_RACE_ROAD_TYPE, 2245)
	local targetPos = i3k_db_common.petRace.roadPos
	local rotation = i3k_db_common.petRace.roadRotation
	local pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine((targetPos))));
	pet:SetFaceDir(0, rotation, 0)
	pet:SetPos(pos);
	pet:Show(true, true);
	pet:ShowTitleNode(false)
	pet:SetHittable(false)
	pet:Play(i3k_db_common.engine.defaultStandAction, -1);
	self:AddEntity(pet);
end

-- 移除赛道
function i3k_world:RemovePetRaceRoad()
	local entity = self:GetPetRaceRoad(PET_RACE_ROAD_TYPE)
	if entity then
		self:ReleaseEntity(entity, true)
	end
end

function i3k_world:PlayPetRaceRoadStart()
	local entity = self:GetPetRaceRoad(PET_RACE_ROAD_TYPE)
	if entity then
		entity:PlayPetRaceRoadStartActions()
	end
	-- 比赛开始的时候小龟冒泡文字
	for i = 1, 3 do
		local entity = self:GetPetRacePet(i)
		if entity then
			local str = g_i3k_db.i3k_db_get_pet_race_start_str()
			entity:popMessage(str)
		end
	end
end

function i3k_world:PlayPetRaceRoadFinish(winPetID)
	local entityPet = self:GetPetRacePet(winPetID)
	if entityPet then
		local str = g_i3k_db.i3k_db_get_pet_race_finish_str()
		entityPet:popMessage(str)
	end

	local entity = self:GetPetRaceRoad(PET_RACE_ROAD_TYPE)
	if entity then
		entity:PlayPetRaceRoadEndActions()
	end
	-- 移除掉所有
	self.petRaceCo = g_i3k_coroutine_mgr:StartCoroutine(function()
		local time = i3k_db_common.petRace.endSeconds -- 80
		g_i3k_coroutine_mgr.WaitForSeconds(time) --延时
		local world = i3k_game_get_world()
		if world then
			world:RemovePetRaceRoad()
			world:RemovePetRacePets({1, 2, 3})
		end
		g_i3k_coroutine_mgr:StopCoroutine(self.petRaceCo)
	end)
end

-- 添加buff
function i3k_world:PetsRacePetAddBuff(id, buffID)
	local entity = self:GetPetRacePet(id)
	local BUFF = require("logic/battle/i3k_buff");
	local bcfg = i3k_db_buff[buffID];
	local buff = BUFF.i3k_buff.new(nil, buffID, bcfg);
	if buff and entity then
		entity:AddBuff(nil, buff);
		local str = g_i3k_db.i3k_db_get_pet_race_buff_str()
		local rand = math.random(100) -- 随机一个概率
		local popChance = i3k_db_common.petRace.popChance
		if rand < popChance then
			entity:popMessage(str)
		end
	end
end

-- 移除buff
function i3k_world:PetsRacePetRemoveBuff(id, buffID)
	local entity = self:GetPetRacePet(id)
	if entity then
		local buff = entity._buffs[buffID]
		if buff  then
			entity:RmvBuff(buff);
		end
	end
end

-- 通过配置ID获得矿entity
function i3k_world:GetResourcePointFormCfgID(cfgID)
	for _, v in pairs(self._ResourcePoints) do
		if v._gid == cfgID then
			return v
		end
	end
	return nil
end

-- 示爱道具
function i3k_world:CreateShowLoveItem(id, location)
	if not self:GetShowLoveItem(id) then
		-- g_i3k_ui_mgr:PopupTipMessage("CreateShowLoveItem"..id)
		local itemClass = require("logic/entity/i3k_show_love_item")
		local item = itemClass.i3k_show_love_item.new(i3k_gen_entity_guid_new(itemClass.i3k_show_love_item.__cname, id))
		local tab =
		{
			[i3k_db_show_love_item.typeNormalID] = 2393, -- 对应的模型id
			[i3k_db_show_love_item.typeLuxuryID] = 2392,
		}
		local modelID = tab[id]
		item:CreateShowLoveItemRes(id, modelID)
		local pos = location.position
		local rot = location.rotation
		local r = i3k_vec3_angle2(i3k_vec3(rot.x,rot.y,rot.z), i3k_vec3(1, 0, 0));
		local curMapID = g_i3k_game_context:GetWorldMapID()
		if curMapID == 10 or curMapID == 13 then -- 对应战役地图表，花亭平原和松月关，需要旋转45度
			r = r + 1.58
		end
		item:SetFaceDir(0, r, 0);
		item:SetPos(pos);
		item:Show(true, true);
		item:Play(i3k_db_common.engine.defaultStandAction, -1);
		self:AddEntity(item);
	end
end

function i3k_world:GetShowLoveItem(id)
	return self._entities[eGroupType_N]["i3k_show_love_item|"..id]
end

-- args {id1, id2, id3...}
function i3k_world:RemoveShowLoveItems(items)
	-- g_i3k_ui_mgr:PopupTipMessage("RemoveShowLoveItems".. #items)
	for _, v in ipairs(items) do
		local entity = self:GetShowLoveItem(v)
		if entity then
			self:ReleaseEntity(entity, true)
		end
	end
end

function i3k_world:CreateDiglettById(id, position)
	self:changeDiglettPosition(id, true)
	if not self:GetDiglett(id) then
		local diglettItem = require("logic/entity/i3k_diglett")
		local diglett = diglettItem.i3k_diglett.new(i3k_gen_entity_guid_new(diglettItem.i3k_diglett.__cname, id))
		local modelId = nil
		local gameId = g_i3k_db.i3k_db_open_hit_diglett_id(e_TYPE_DIGLETT)
		if #i3k_db_findMooncake[gameId].imageTotal <= 1 then
			modelId = i3k_engine_get_rnd_u(i3k_db_findMooncake[gameId].imageTotal[1][1], i3k_db_findMooncake[gameId].imageTotal[1][2])
		else
			local index = i3k_engine_get_rnd_u(1, #i3k_db_findMooncake[gameId].imageTotal)
			modelId = i3k_engine_get_rnd_u(i3k_db_findMooncake[gameId].imageTotal[index][1], i3k_db_findMooncake[gameId].imageTotal[index][2])
		end
		local isTrueDiglett = false
		for _, v in ipairs(i3k_db_findMooncake[gameId].cakeInfo) do
			if modelId == v.id then
				isTrueDiglett = true
				break
			end
		end
		diglett:createDiglett(id, modelId, isTrueDiglett)
		local r = i3k_vec3_angle2(i3k_vec3(1, 1, 0), i3k_vec3(1, 0, 0))
		--local curMapID = g_i3k_game_context:GetWorldMapID()
		diglett:SetFaceDir(0, r, 0)
		diglett:SetPos(i3k_world_pos_to_logic_pos(position));
		diglett:Show(true, true);
		diglett:playRiseAct()
		self:AddEntity(diglett);
	end
end

function i3k_world:initDiglettPosition()
	self._diglettPosition = {}
	for i = 1, #i3k_db_diglett_position.digletts do
		self._diglettPosition[i] = false
	end
end

function i3k_world:changeDiglettPosition(positionId, change)
	if self._diglettPosition then
		self._diglettPosition[positionId] = change
	end
end

function i3k_world:RandomDiglettPosition()
	local position = {}
	for k, v in ipairs(self._diglettPosition) do
		if not v then
			table.insert(position, k)
		end
	end
	if next(position) then
		local index = math.random(1, #position)
		return position[index]
	else
		return false
	end
end

function i3k_world:GetDiglett(id)
	return self._entities[eGroupType_N]["i3k_diglett|"..id]
end

function i3k_world:GetAllDigletts(isDiglett)
	local addDigletts = {}
	for _, v in pairs(self._entities[eGroupType_N]) do
		if v:GetEntityType() == eET_Diglett then
			if isDiglett then
				if v:GetIsTrueDiglett() then
					addDigletts[v._guid] = v
				end
			else
				if not v:GetIsTrueDiglett() then
					addDigletts[v._guid] = v
				end
			end
		end
	end
	return addDigletts
end

function i3k_world:RemoveDigletts(id)
	local entity = self:GetDiglett(id)
	self:changeDiglettPosition(id, false)
	if entity then
		self:ReleaseEntity(entity, true)
	end
end

function i3k_world:SetAllArmorEffect( )	--ChangeArmorEffect 会判断是否显示
	for k,v in pairs(self._entities[eGroupType_O]) do
		if  v:GetEntityType() == eET_Player then
			v:ChangeArmorEffect()
		end
	end
end

-- 进入家园后后端广播的的家园作物同步协议（如果不存在地块创建地块，其他时候更新）
function i3k_world:CreateItemCrops(ground)
	local groundId = ground.groundId
	local posCfg = i3k_db_home_land_plantArea[groundId]

	if not posCfg or not posCfg.pos then
		return
	end

	local modelID = g_i3k_db.i3k_db_getGroundEmptyModelID(ground.groundId)
	if ground._plantCfg then -- 如果有植物的话植物model替换空模型
		modelID =  ground._plantCfg.modelID
	end

	local SCrop = require("logic/entity/i3k_crop"); -- 这里可能会频繁创建，后期优化拿他拿出去
	local itemCrop = SCrop.i3k_crop.new(i3k_gen_entity_guid_new(eET_Crop, groundId))
	itemCrop:Create(groundId, modelID, ground.groundType, ground.groundIndex);
	itemCrop:SetHittable(true);
	itemCrop:Show(true);
	itemCrop:Play("stand", -1);
	itemCrop:NeedUpdateAlives(false);
	itemCrop:ShowTitleNode(true);
	local pos = posCfg.pos
	pos = i3k_world_pos_to_logic_pos(i3k_vec3_to_engine(i3k_vec3(pos[1], pos[2], pos[3])));
	itemCrop:SetPos(pos, true);
	self:AddEntity(itemCrop)
	return itemCrop
end

-- 所有地块的信息同步
function i3k_world:UpdateItemCrops(groundInfo, homelandLevel)
	if not self._ItemCrops then return end
	local groundEntity = nil -- 地块entity的临时引用-
	local needCreate = {}
	for groundId, ground in pairs(groundInfo) do -- 根据信息更新所有地块，不存在的地块创建
		groundEntity = self._ItemCrops[groundId]
		if not groundEntity then
			groundEntity = self:CreateItemCrops(ground)
		end

		if groundEntity then
			groundEntity:updateInfo(ground)
		end
	end
end

function i3k_world:getItemCrop(cropType, groundIndex)
	for index, cropItem in pairs(self._ItemCrops) do
		if cropType == cropItem._typeid  and cropItem._groundIndex == groundIndex then
			return cropItem
		end
	end
	return nil
end

-- 单个地块被操作本地计算新状态
function i3k_world:onItemCropOperate(cropType, groundIndex, operateType, arg1, arg2)
	local cropItem = self:getItemCrop(cropType, groundIndex)
	if cropItem then
		cropItem:onItemCropOperate(operateType, arg1, arg2)
	end
end

--[[function i3k_world:onItemCropLevelUp(cropType, groundIndex, level)
	local cropItem = self:getItemCrop(cropType, groundIndex)
	if cropItem then
		cropItem:onItemCropLevelUp(level)
	end
end --]]

--家园房屋地板占用状态初始化
function i3k_world:initHouseFloorModels()
	for k, v in pairs(self._furnitureList) do
		for _, i in ipairs(v) do
			self:RemoveFurnitureById(i, k)
		end
	end
	self._furnitureList = {[g_HOUSE_FLOOR_FURNITURE] = {}, [g_HOUSE_WALL_FURNITURE] = {}, [g_HOUSE_HANG_FURNITURE] = {}, [g_HOUSE_CARPET_FURNITURE] = {}} --房屋家具
	self._floorEntitys = {}
	self._floorFurniture = {}
	self._floors = {[g_HOUSE_FLOOR_FURNITURE] = {}, [g_HOUSE_CARPET_FURNITURE] = {}} --房屋地板状态存储
	self._furnitureGid = 1 --家园房屋家具的gid
	self._pendantsGid = 1
	self._curChooseFurniture = {} --当前选中的家具
	local level = g_i3k_game_context:getCurHouseLevel()
	local houseData = i3k_db_home_land_house[level]
	for i = 0, houseData.houseWidth - 1 do
		for k = 0, houseData.houseLength - 1 do
			if not self._floors[g_HOUSE_FLOOR_FURNITURE][i] then
				self._floors[g_HOUSE_FLOOR_FURNITURE][i] = {}
			end
			if not self._floors[g_HOUSE_CARPET_FURNITURE][i] then
				self._floors[g_HOUSE_CARPET_FURNITURE][i] = {}
			end
			self._floors[g_HOUSE_FLOOR_FURNITURE][i][k] = false
			self._floors[g_HOUSE_CARPET_FURNITURE][i][k] = false
			if i >= houseData.notPlace.start and i <= houseData.notPlace.start + houseData.notPlace.width and k < houseData.notPlace.length then
				self._floors[g_HOUSE_FLOOR_FURNITURE][i][k] = true
				self._floors[g_HOUSE_CARPET_FURNITURE][i][k] = true
			end
		end
	end
	self:CreateHouseFurnitures()
end

--家园房屋地板创建
function i3k_world:createFloors(startX, startY, length, width, placeType)
	local level = g_i3k_game_context:getCurHouseLevel()
	local houseData = i3k_db_home_land_house[level]
	local floorId = 1
	for i = startX, startX + width - 1 do
		for k = startY, startY + length - 1 do
			local floor = require("logic/entity/i3k_floor")
			local floorModel = floor.i3k_floor.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_Floor), floorId))
			floorModel:Create(i3k_db_home_land_base.houseFurniture.modelId, floorId)
			local position = i3k_clone(houseData.startPos)
			position.x = houseData.startPos.x - (i + 0.5) * i3k_db_home_land_base.houseFurniture.size.width
			position.z = houseData.startPos.z - (k + 0.5) * i3k_db_home_land_base.houseFurniture.size.length
			if k < houseData.demarcation - 1 then
				position.y = 0.6
			else
				position.y = 0.15
			end
			local r = i3k_vec3_angle2(i3k_vec3(1, 0, 0), i3k_vec3(1, 0, 0))
			floorModel:SetFaceDir(0, r, 0)
			floorModel:SetPos(i3k_world_pos_to_logic_pos(position))
			floorModel:Show(true, true)
			floorModel:SetHittable(false)
			floorModel:NeedUpdateAlives(false)
			self:AddEntity(floorModel)
			if self._floors[placeType][i][k] then
				floorModel:Play("stand02", -1)
			else
				floorModel:Play("stand01", -1)
			end
			floorId = floorId + 1
		end
	end
end

--在人物附近创建地面家具空模型
function i3k_world:CreateFloorFurnitureSpace(id, placeType)
	local furniture = g_i3k_db.i3k_db_get_furniture_data(placeType, id)
	local level = g_i3k_game_context:getCurHouseLevel()
	local houseData = i3k_db_home_land_house[level]
	local hero = i3k_game_get_player_hero()
	local row, line = g_i3k_db.i3k_db_get_house_floor_pos(i3k_logic_pos_to_world_pos(hero._curPos))
	local startY = line <= furniture.occupyLength and 1 or line - furniture.occupyLength
	local startX = row <= furniture.occupyWidth and 1 or row - furniture.occupyWidth
	if startX >= houseData.notPlace.start and startX <= houseData.notPlace.start + houseData.notPlace.width and startY <= houseData.notPlace.length then
		startY = houseData.notPlace.length + 1
	end
	self:CreateFloorFurniture({furnitureId = id, positionX = startX, positionY = startY, direction = 1, additionId = 0}, false, nil, placeType)
end

--地面家具旋转，1向左，2向右
function i3k_world:turnFloorFurniture(direction, placeType)
	if self._curChooseFurniture.furnitureType == g_HOUSE_FLOOR_FURNITURE or self._curChooseFurniture.furnitureType == g_HOUSE_CARPET_FURNITURE then
		self:RemoveChooseFurniture()
		local curDirection = self._curChooseFurniture.direction
		self._curChooseFurniture.direction = g_i3k_db.i3k_db_get_turn_furniture_direction(direction, curDirection)
		self._curChooseFurniture.positionX, self._curChooseFurniture.positionY = g_i3k_db.i3k_db_get_adjust_furniture_position(self._curChooseFurniture)
		self:CreateFloorFurniture(self._curChooseFurniture, false, nil, placeType)
	else
		g_i3k_ui_mgr:PopupTipMessage("不能旋转")
	end
end

--地面家具移动，1左2右3上4下
function i3k_world:moveFloorFurniture(direction, placeType)
	if self._curChooseFurniture.furnitureType == g_HOUSE_FLOOR_FURNITURE or self._curChooseFurniture.furnitureType == g_HOUSE_CARPET_FURNITURE then
		self:RemoveChooseFurniture()
		self._curChooseFurniture.positionX, self._curChooseFurniture.positionY = g_i3k_db.i3k_db_get_move_furniture_position(direction, self._curChooseFurniture)
		self:CreateFloorFurniture(self._curChooseFurniture, false, nil, placeType)
	elseif self._curChooseFurniture.furnitureType == g_HOUSE_WALL_FURNITURE then
		local wallId = g_i3k_game_context:getInWallType()
		if wallId then
			if direction == g_MOVE_DIRECTION_LEFT or direction == g_MOVE_DIRECTION_RIGHT then
			self:RemoveChooseFurniture()
			self._curChooseFurniture.position = g_i3k_db.i3k_db_get_wall_furniture_move_position(direction, self._curChooseFurniture)
			self:CreateWallFurniture(self._curChooseFurniture, false)
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("不在墙边无法移动")
		end
	end
end

function i3k_world:CreateHouseFurnitures()
	local house = g_i3k_game_context:getHomeLandHouseInfo()
	self._furnitureGid = 1
	if house.homeland.furnitures then
		for k, v in ipairs(house.homeland.furnitures) do
			self:CreateFloorFurniture(v, true, nil, g_HOUSE_FLOOR_FURNITURE)
		end
	end
	if house.homeland.pendants then
		self._pendantsGid = 1
		for k, v in ipairs(house.homeland.pendants) do
			self:CreateWallFurniture(v, true)
		end
	end
	if house.homeland.floorFurnitures then
		for k, v in ipairs(house.homeland.floorFurnitures) do
			self:CreateFloorFurniture(v, true, nil, g_HOUSE_CARPET_FURNITURE)
		end
	end
end

function i3k_world:CreateFloorFurniture(info, isPlace, index, placeType)
	local house = g_i3k_game_context:getHomeLandHouseInfo()
	local level = house.homeland.houseLevel
	local houseData = i3k_db_home_land_house[level]
	local furnitureInfo = g_i3k_db.i3k_db_get_furniture_data(placeType, info.furnitureId)
	local furniture
	local guid
	local position = i3k_clone(houseData.startPos)
	if placeType == g_HOUSE_FLOOR_FURNITURE then
		local item = require("logic/entity/i3k_furniture")
		guid = i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_Furniture), self._furnitureGid)
		furniture = item.i3k_furniture.new(guid)
		if info.positionY >= houseData.demarcation - 1 then
			position.y = 0.20
		else
			position.y = 0.65
		end
	else
		local item = require("logic/entity/i3k_carpet_furniture")
		guid = i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_CarpetFurniture), self._furnitureGid)
		furniture = item.i3k_carpet_furniture.new(guid)
		if info.positionY >= houseData.demarcation - 1 then
			position.y = 0.05
		else
			position.y = 0.60
		end
	end
	furniture:create(furnitureInfo.models[info.direction], info, isPlace)
	local length = furnitureInfo.occupyLength
	local width = furnitureInfo.occupyWidth
	if info.direction == 2 or info.direction == 4 then
		length = furnitureInfo.occupyWidth
		width = furnitureInfo.occupyLength
	end
	position.x = houseData.startPos.x - (info.positionX + width / 2) * i3k_db_home_land_base.houseFurniture.size.width
	position.z = houseData.startPos.z - (info.positionY + length / 2) * i3k_db_home_land_base.houseFurniture.size.length
	--local r = i3k_vec3_angle2(i3k_vec3(1, 0, 0), i3k_vec3(1, 0, 0))
	furniture:SetFaceDir(0, 0, 0)
	furniture:Show(true, true)
	furniture:SetHittable(true)
	furniture:SetPos(i3k_world_pos_to_logic_pos(position))
	furniture:NeedUpdateAlives(false)
	self:AddEntity(furniture)
	if not isPlace then
		--furniture:EnableOutline(true, i3k_db_home_land_base.houseFurniture.outlineColor)
		self._curChooseFurniture = info
		self._curChooseFurniture.guid = guid
		self._curChooseFurniture.furnitureType = placeType
		self:createFloors(info.positionX, info.positionY, length, width, placeType)
		--self:ChangeFloorColor(info.positionX, info.positionY, length, width)
	else
		self:ChangeFloorState(info.positionX, info.positionY, length, width, true, placeType)
		if index then
			self._furnitureList[placeType][index] = guid
		else
			table.insert(self._furnitureList[placeType], guid)
		end
	end
	self._furnitureGid = self._furnitureGid + 1
end

function i3k_world:ChangeFloorState(startX, startY, length, width, state, placeType)
	for i = startX, startX + width - 1 do
		for k = startY, startY + length - 1 do
			self._floors[placeType][i][k] = state
		end
	end
end

--尝试放置家具，判断是否冲突
function i3k_world:TryToPlaceFurniture()
	if self._curChooseFurniture.furnitureType == g_HOUSE_FLOOR_FURNITURE or self._curChooseFurniture.furnitureType == g_HOUSE_CARPET_FURNITURE then
		local furnitureInfo = g_i3k_db.i3k_db_get_furniture_data(self._curChooseFurniture.furnitureType, self._curChooseFurniture.furnitureId)
		local length = furnitureInfo.occupyLength
		local width = furnitureInfo.occupyWidth
		if self._curChooseFurniture.direction == 2 or self._curChooseFurniture.direction == 4 then
			length = furnitureInfo.occupyWidth
			width = furnitureInfo.occupyLength
		end
		for i = self._curChooseFurniture.positionX, self._curChooseFurniture.positionX + width - 1 do
			for k = self._curChooseFurniture.positionY, self._curChooseFurniture.positionY + length - 1 do
				if self._floors[self._curChooseFurniture.furnitureType][i][k] then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17429))
					return false
				end
			end
		end
		if self._curMoveFurniture then
			local index = self:GetFurnitureIndex(self._curMoveFurniture, self._curChooseFurniture.furnitureType)
			if self._curChooseFurniture.furnitureType == g_HOUSE_FLOOR_FURNITURE then
				i3k_sbean.land_furniture_move(index, self._curChooseFurniture)
			else
				i3k_sbean.floor_furniture_move(index, self._curChooseFurniture)
			end
		else
			if self._curChooseFurniture.furnitureType == g_HOUSE_FLOOR_FURNITURE then
				i3k_sbean.land_furniture_put(self._curChooseFurniture)
			else
				i3k_sbean.floor_furniture_put(self._curChooseFurniture)
			end
		end
		return true
	elseif self._curChooseFurniture.furnitureType == g_HOUSE_WALL_FURNITURE then
		local wallId = g_i3k_game_context:getInWallType()
		if wallId then
			local pendant = i3k_db_home_land_wall_furniture[self._curChooseFurniture.id]
			local level = g_i3k_game_context:getCurHouseLevel()
			local wallCfg = i3k_db_home_land_house[level].wallCfg[self._curChooseFurniture.wallIndex]
			if self._curChooseFurniture.position >= 0 and self._curChooseFurniture.position <= wallCfg.toPos - wallCfg.fromPos then
				for k, v in ipairs(self._furnitureList[g_HOUSE_WALL_FURNITURE]) do
					if self._curMoveFurniture and self._curMoveFurniture == v then
						
					else
						local entity = self:GetEntity(eET_WallFurniture, v)
						if entity and entity._furnitureInfo.wallIndex == self._curChooseFurniture.wallIndex then
							if math.abs(entity._furnitureInfo.position - self._curChooseFurniture.position) < (entity._furnitureInfo.position > self._curChooseFurniture.position and pendant.length or i3k_db_home_land_wall_furniture[entity._furnitureInfo.id].length) then
								g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17429))
								return false
							end
						end
					end
				end
				if self._curMoveFurniture then
					local callback = function ()
						i3k_sbean.wall_furniture_put(self._curChooseFurniture.id, self._curChooseFurniture.wallIndex, self._curChooseFurniture.position)
					end
					self:RemovePlacedFurniture(self._curMoveFurniture, g_HOUSE_WALL_FURNITURE, callback)
				else
					i3k_sbean.wall_furniture_put(self._curChooseFurniture.id, self._curChooseFurniture.wallIndex, self._curChooseFurniture.position)
				end
				return true
			else
				g_i3k_ui_mgr:PopupTipMessage("当前位置不可用")
				return false
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("不在墙边无法放置")
		end
	end
end

function i3k_world:isPlacedMaxCount(furnitureType, furnitureId)
	local count = 0
	for k, v in ipairs(self._furnitureList[furnitureType]) do
		local entity = self:GetEntity(furnitureTypeInfo[furnitureType].entityNum, v)
		if entity and entity._furnitureInfo[furnitureTypeInfo[furnitureType].furnitureId] == furnitureId then
			count = count + 1
			local furnitureData = g_i3k_db.i3k_db_get_furniture_data(furnitureType, furnitureId)
			if count >= furnitureData.limitCount then
				return true
			end
		end
	end
	return false
end

--保存成功之后删除当前选中的家具信息
function i3k_world:ReleaseChooseFurniture()
	self:RemoveChooseFurniture()
	self._curChooseFurniture = {}
end

--对选中的家具操作删除之前的模型
function i3k_world:RemoveChooseFurniture()
	if self._curChooseFurniture.guid then
		self:RemoveFurnitureById(self._curChooseFurniture.guid, self._curChooseFurniture.furnitureType)
	end
	if self._floorEntitys then
		for k, v in pairs(self._floorEntitys) do
			self:ReleaseEntity(v, true)
		end
	end
end

--移除已经放置的家具
function i3k_world:RemovePlacedFurniture(guid, furnitureType, callback)
	local index = self:GetFurnitureIndex(guid, furnitureType)
	if index then
		if furnitureType == g_HOUSE_FLOOR_FURNITURE then
			i3k_sbean.land_furniture_remove(index)
		elseif furnitureType == g_HOUSE_CARPET_FURNITURE then
			i3k_sbean.floor_furniture_remove(index)
		elseif furnitureType == g_HOUSE_WALL_FURNITURE then
			i3k_sbean.wall_furniture_remove(index, callback)
		end
		return true
	end
end

function i3k_world:GetFurnitureIndex(guid, furnitureType)
	for k, v in ipairs(self._furnitureList[furnitureType]) do
		if v == guid then
			return k
		end
	end
end

--移除成功后调用
function i3k_world:ReleasePlacedFurniture(index, furnitureType)
	if furnitureType == g_HOUSE_FLOOR_FURNITURE then
		local entity = self:GetEntity(eET_Furniture, self._furnitureList[furnitureType][index])
		if entity then
			if entity._curMountFurniture then
				g_i3k_game_context:subHouseBuildValue(i3k_db_home_land_hang_furniture[entity._furnitureInfo.additionId].builtPoint)
				entity:DetachMountFurniture()
			end
			local furnitureInfo = i3k_db_home_land_floor_furniture[entity._furnitureInfo.furnitureId]
			local length = furnitureInfo.occupyLength
			local width = furnitureInfo.occupyWidth
			if entity._furnitureInfo.direction == 2 or entity._furnitureInfo.direction == 4 then
				length = furnitureInfo.occupyWidth
				width = furnitureInfo.occupyLength
			end
			self:ChangeFloorState(entity._furnitureInfo.positionX, entity._furnitureInfo.positionY, length, width, false, g_HOUSE_FLOOR_FURNITURE)
			g_i3k_game_context:subHouseBuildValue(furnitureInfo.builtPoint)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
		end
	elseif furnitureType == g_HOUSE_WALL_FURNITURE then
		local entity = self:GetEntity(eET_WallFurniture, self._furnitureList[furnitureType][index])
		if entity then
			local furnitureInfo = i3k_db_home_land_wall_furniture[entity._furnitureInfo.id]
			g_i3k_game_context:subHouseBuildValue(furnitureInfo.builtPoint)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
		end
	elseif furnitureType == g_HOUSE_CARPET_FURNITURE then
		local entity = self:GetEntity(eET_CarpetFurniture, self._furnitureList[furnitureType][index])
		if entity then
			local furnitureInfo = i3k_db_home_land_carpet_furniture[entity._furnitureInfo.furnitureId]
			local length = furnitureInfo.occupyLength
			local width = furnitureInfo.occupyWidth
			if entity._furnitureInfo.direction == 2 or entity._furnitureInfo.direction == 4 then
				length = furnitureInfo.occupyWidth
				width = furnitureInfo.occupyLength
			end
			self:ChangeFloorState(entity._furnitureInfo.positionX, entity._furnitureInfo.positionY, length, width, false, g_HOUSE_CARPET_FURNITURE)
			g_i3k_game_context:subHouseBuildValue(furnitureInfo.builtPoint)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
		end
	end
	self:RemoveFurnitureById(self._furnitureList[furnitureType][index], furnitureType)
	table.remove(self._furnitureList[furnitureType], index)
end

--移除单个的家具
function i3k_world:RemoveFurnitureById(guid, furnitureType)
	local entity = self:GetEntity(furnitureTypeInfo[furnitureType].entityNum, guid)
	if entity then
		self:ReleaseEntity(entity, true)
	end
end

--移动已经摆放的家具
function i3k_world:MovePlacedFurniture(info)
	self._curMoveFurniture = info.guid
	if info.furnitureType == g_HOUSE_FLOOR_FURNITURE then
		local furnitureInfo = i3k_db_home_land_floor_furniture[info.furnitureId]
		local length = furnitureInfo.occupyLength
		local width = furnitureInfo.occupyWidth
		if info.direction == 2 or info.direction == 4 then
			length = furnitureInfo.occupyWidth
			width = furnitureInfo.occupyLength
		end
		self:ChangeFloorState(info.positionX, info.positionY, length, width, false, g_HOUSE_FLOOR_FURNITURE)
		self:CreateFloorFurniture(info, false, nil, g_HOUSE_FLOOR_FURNITURE)
	elseif info.furnitureType == g_HOUSE_WALL_FURNITURE then
		self:CreateWallFurniture(info, false)
	elseif info.furnitureType == g_HOUSE_CARPET_FURNITURE then
		local furnitureInfo = i3k_db_home_land_carpet_furniture[info.furnitureId]
		local length = furnitureInfo.occupyLength
		local width = furnitureInfo.occupyWidth
		if info.direction == 2 or info.direction == 4 then
			length = furnitureInfo.occupyWidth
			width = furnitureInfo.occupyLength
		end
		self:ChangeFloorState(info.positionX, info.positionY, length, width, false, g_HOUSE_CARPET_FURNITURE)
		self:CreateFloorFurniture(info, false, nil, g_HOUSE_CARPET_FURNITURE)
	end
end

--移动已经摆放的家具改变地板的占用状态
function i3k_world:ChangeCurMoveFloor(state)
	if self._curMoveFurniture then
		local entity = self:GetEntity(eET_Furniture, self._curMoveFurniture)
		if entity then
			local furnitureInfo = i3k_db_home_land_floor_furniture[entity._furnitureInfo.furnitureId]
			local length = furnitureInfo.occupyLength
			local width = furnitureInfo.occupyWidth
			if entity._furnitureInfo.direction == 2 or entity._furnitureInfo.direction == 4 then
				length = furnitureInfo.occupyWidth
				width = furnitureInfo.occupyLength
			end
			self:ChangeFloorState(entity._furnitureInfo.positionX, entity._furnitureInfo.positionY, length, width, state, g_HOUSE_FLOOR_FURNITURE)
		end
		local entity = self:GetEntity(eET_CarpetFurniture, self._curMoveFurniture)
		if entity then
			local furnitureInfo = i3k_db_home_land_carpet_furniture[entity._furnitureInfo.furnitureId]
			local length = furnitureInfo.occupyLength
			local width = furnitureInfo.occupyWidth
			if entity._furnitureInfo.direction == 2 or entity._furnitureInfo.direction == 4 then
				length = furnitureInfo.occupyWidth
				width = furnitureInfo.occupyLength
			end
			self:ChangeFloorState(entity._furnitureInfo.positionX, entity._furnitureInfo.positionY, length, width, state, g_HOUSE_CARPET_FURNITURE)
		end
	end
end

--移动地面家具成功后调用
function i3k_world:RemoveFloorFurniture(info)
	local entity = self:GetEntity(furnitureTypeInfo[info.type].entityNum, self._furnitureList[info.type][info.index])
	if entity then
		if entity._curMountFurniture then
			entity:DetachMountFurniture()
		end
		local curFurniture = entity._furnitureInfo
		local furnitureInfo = g_i3k_db.i3k_db_get_furniture_data(info.type, curFurniture.furnitureId)
		local length = furnitureInfo.occupyLength
		local width = furnitureInfo.occupyWidth
		if curFurniture.direction == 2 or curFurniture.direction == 4 then
			length = furnitureInfo.occupyWidth
			width = furnitureInfo.occupyLength
		end
		self:ChangeFloorState(curFurniture.positionX, curFurniture.positionY, length, width, false, info.type)
		local furniture = {}
		furniture.furnitureId = curFurniture.furnitureId
		furniture.positionX = info.positionX
		furniture.positionY = info.positionY
		furniture.direction = info.direction
		if info.type == g_HOUSE_FLOOR_FURNITURE then
			furniture.additionId = curFurniture.additionId
		end
		self:CreateFloorFurniture(furniture, true, info.index, info.type)
		self:ReleaseEntity(entity, true)
	end
end

--创建墙面家具空模型
function i3k_world:CreateWallFurnitureSpace(id, furniture)
	local wallId = g_i3k_game_context:getInWallType()
	if wallId then
		local hero = i3k_game_get_player_hero()
		if hero then
			g_i3k_ui_mgr:OpenUI(eUIID_HouseFurnitureSet)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurnitureSet, furniture)
			local house = g_i3k_game_context:getHomeLandHouseInfo()
			local level = house.homeland.houseLevel
			local heroPos = i3k_logic_pos_to_world_pos(hero._curPos)
			local pos = 0
			local pendant = i3k_db_home_land_wall_furniture[id]
			local wallCfg = i3k_db_home_land_house[level].wallCfg[wallId]
			if wallCfg.wallType == 1 then
				pos = heroPos.z
			else
				pos = heroPos.x
			end
			if pos < wallCfg.fromPos + pendant.length / 2 then
				pos = wallCfg.fromPos + pendant.length / 2
			end
			if pos > wallCfg.toPos - pendant.length / 2 then
				pos = wallCfg.toPos - pendant.length / 2
			end
			self:CreateWallFurniture({id = id, wallIndex = wallId, position = pos - wallCfg.fromPos - pendant.length / 2}, false)
			return true
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("不在墙边无法放置")
		return false
	end
end

--墙面家具创建
function i3k_world:CreateWallFurniture(info, isPlace)
	local house = g_i3k_game_context:getHomeLandHouseInfo()
	local level = house.homeland.houseLevel
	local houseData = i3k_db_home_land_house[level]
	local position = {}
	if houseData.wallCfg[info.wallIndex].wallType == 1 then
		position.x = houseData.wallCfg[info.wallIndex].unChangePos
		position.z = houseData.wallCfg[info.wallIndex].fromPos + info.position + i3k_db_home_land_wall_furniture[info.id].length / 2
	else
		position.z = houseData.wallCfg[info.wallIndex].unChangePos
		position.x = houseData.wallCfg[info.wallIndex].fromPos + info.position + i3k_db_home_land_wall_furniture[info.id].length / 2
	end
	position.y = i3k_db_home_land_wall_furniture[info.id].height
	local item = require("logic/entity/i3k_wall_furniture")
	local furniture = item.i3k_wall_furniture.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_WallFurniture), self._pendantsGid))
	furniture:create(i3k_db_home_land_wall_furniture[info.id].models[houseData.wallCfg[info.wallIndex].wallType], info)
	local r = i3k_vec3_angle2(i3k_vec3(1, 0, 0), i3k_vec3(0, 0, 0))
	furniture:SetFaceDir(0, r, 0)
	furniture:Show(true, true)
	furniture:SetHittable(true)
	furniture:SetPos(i3k_world_pos_to_logic_pos(position))
	furniture:NeedUpdateAlives(false)
	self:AddEntity(furniture)
	if isPlace then
		table.insert(self._furnitureList[g_HOUSE_WALL_FURNITURE], i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_WallFurniture), self._pendantsGid))
	else
		self._curChooseFurniture = info
		self._curChooseFurniture.guid = i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_WallFurniture), self._pendantsGid)
		self._curChooseFurniture.furnitureType = g_HOUSE_WALL_FURNITURE
	end
	self._pendantsGid = self._pendantsGid + 1
end

--家具挂载
function i3k_world:FurnitureAddition(info)	
	if not info then
		return
	end
	local entity = self:GetEntity(eET_Furniture, self._furnitureList[g_HOUSE_FLOOR_FURNITURE][info.index])
	if entity then
		entity:AttachMountFurniture(info.furnitureId)
	end
end

--房屋皮肤创建
function i3k_world:createHouseSkin(id)
	local level = g_i3k_game_context:getCurHouseLevel()
	local houseData = i3k_db_home_land_house[level]
	local item = require("logic/entity/i3k_house_skin")
	local houseSkin = item.i3k_house_skin.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_HouseSkin), 1))
	houseSkin:create(i3k_db_home_land_house_skin[id].models[level])
	local r = i3k_vec3_angle2(i3k_vec3(1, 0, 0), i3k_vec3(0, 0, 0))
	houseSkin:SetFaceDir(0, r, 0)
	houseSkin:Show(true, true)
	houseSkin:SetHittable(false)
	houseSkin:SetPos(i3k_world_pos_to_logic_pos({x = 0, y = -0.3, z = 0.5}))
	houseSkin:NeedUpdateAlives(false)
	self:AddEntity(houseSkin)
end

function i3k_world:releaseHouseSkin()
	local entity = self:GetEntity(eET_HouseSkin, i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_HouseSkin), 1))
	if entity then
		self:ReleaseEntity(entity)
	end
end

function i3k_world:ChangeHouseSkin(id)
	self:releaseHouseSkin()
	self:createHouseSkin(id)
end

--幻境副本怪物模型创建
function i3k_world:CreateIllusoryMonster(id, pos, circleDot)
	if not self:GetIllusoryMonster(id) then
		local SEntity = require("logic/entity/i3k_monster")
		local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_Monster), id))
		monster:Create(id, false)
		monster:Show(true, true)
		monster:SetGroupType(eGroupType_N)
		local monsterPos = i3k_world_pos_to_logic_pos(pos)
		local rot_y = i3k_vec3_angle1(circleDot, monsterPos, i3k_vec3(1, 0, 0))
		monster:SetFaceDir(0, rot_y, 0)
		monster:SetHittable(false)
		monster:SetPos(monsterPos)
		monster:NeedUpdateAlives(false)
		monster:ShowTitleNode(true)
		monster:SetTitleShow(false)
		monster:SetTitleVisiable(false)
		monster:Play(i3k_db_common.engine.defaultStandAction, -1)
		self:AddEntity(monster)
	end
end

function i3k_world:GetIllusoryMonster(id)
	return self._entities[eGroupType_N]["i3k_monster|"..id]
end

function i3k_world:ReleaseIllusoryMonster(id)
	local entity = self:GetIllusoryMonster(id)
	if entity then
		self:ReleaseEntity(entity, true)
	end
end



function i3k_world:CreateOnlyPlayerModelFromCfg(RoleID, _pos, Dir, args, forceType) -- 创建玩家模型
	local Pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos))));
	local entityPlayer = self:GetEntity(eET_Player, RoleID);
	if not entityPlayer then
		local cfg = g_i3k_db.i3k_db_get_general(args.RoleType);
	 	local SEntity = require("logic/entity/i3k_entity_net");
		local Guid = self:CreateOnlyGuid(1, eET_Player, RoleID);
		local entityPlayer = SEntity.i3k_entity_net.new(Guid);		
		entityPlayer:setDesertBatttleInfo(args.desertScore, args.desertModelId)
		entityPlayer:setSpyInfo(forceType, args.RoleType)
		if entityPlayer:Create(args.RoleType, args.Rolename, args.Gender, args.Hair, args.Face, args.nLevel,{}, cfg, eET_Player, false, args.sectname, args.sectID, args.sectPosition, args.sectIcon, args.permanentTitle, args.timedTitles, args.bwtype, args.carRobber, args.carOwner) then
			entityPlayer:CreatePlayerRes()
			entityPlayer:UpdateProperty(ePropID_maxHP, 1, args.nMaxHP, true, false,true);
			entityPlayer:UpdateHP(args.nCurHP);
			entityPlayer:UpdateBloodBar(entityPlayer:GetPropertyValue(ePropID_hp) / entityPlayer:GetPropertyValue(ePropID_maxHP));
			entityPlayer:NeedUpdateAlives(false);
			entityPlayer:SetFaceDir(Dir.x, Dir.y, Dir.z);
			entityPlayer:SetPos(Pos);
			entityPlayer:SetForceType(forceType);
			entityPlayer:SetGroupType(eGroupType_O);
			entityPlayer:SetHittable(false);
			entityPlayer:Show(true, true, 100);
			entityPlayer:SetCtrlType(eCtrlType_NetWork);
			self:AddEntity(entityPlayer);
		end
	end
end

-- 创建通用模型
function i3k_world:CreateCommonEntity(modelID)
	local hero = i3k_game_get_player_hero()
	if hero then
		-- if self._commonEntitys then -- 每次创建新的清空以前的测试用例
		-- 	for k, v in pairs(self._commonEntitys) do
		-- 		v:Release();
		-- 	end
		-- 	self._commonEntitys = {};
		-- end
		local common = require("logic/entity/i3k_entity_common")
		local Guid = self:CreateOnlyGuid(1, eET_Common, modelID);
		local commonEntity = common.i3k_entity_common.new(Guid)
		commonEntity:Create(modelID);
		commonEntity:SetHittable(false);
		commonEntity:Show(true);
		commonEntity:Play("stand", -1);
		commonEntity:NeedUpdateAlives(false);
		commonEntity:ShowTitleNode(true);
		commonEntity:SetPos(hero._curPos);
		commonEntity:SetFaceDir(hero._faceDir.x, hero._faceDir.y, hero._faceDir.z)
		self:AddEntity(commonEntity)
	end
end 

-- 测试模型，目前只用于策划测试模型动作
function i3k_world:PlayTestEntityAct(modelID)
	local commonEntity = self:GetEntity(eET_Common, modelID)
	if commonEntity then
		local cfg = i3k_db_models_actions[commonEntity._testModelID]
		if cfg and #cfg > 0 then
			local alist = {}
			local totalNum = #cfg
			for i, e in ipairs(cfg) do
				local times = totalNum ~= i and 1 or -1 --最后一个动作持续播放
				table.insert(alist, {actionName = e, actloopTimes = times})
			end
			commonEntity:PlayActionList(alist, 1)
		end
	end
end

-- 用于测试 隐藏所有entity的title和名字
function i3k_world:visTitleAndName(vis)
	for _, ee in pairs(self._entities) do
		for _, v in pairs(ee) do
			v:visTitleInfo(vis)
		end
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:visTitleInfo(vis)
	end
end

-- 更新决战荒漠缩圈时间
function i3k_world:UpdateDesertPoisonSleepTime()
	if self._cfg and self._cfg.openType == g_DESERT_BATTLE then
		local sleepTime = g_i3k_db.i3k_db_get_poisonCircle_sleepTime()
		if not self._desertShrinkRing then
			if sleepTime and sleepTime <= 1 then
				self:UpdateDesertPoisonInfo()
			end
		end
	end
end

-- 更新决战荒漠毒圈
function i3k_world:UpdateDesertPoison()
	if self._cfg and self._cfg.openType == g_DESERT_BATTLE then
		if self._desertPoisonInfo then
			-- local curTime = os.date("%H:%M:%S", g_i3k_get_GMTtime(i3k_game_get_time()))
			-- local pos, r = self._desertPoisonInfo.pos, self._desertPoisonInfo.radius
			-- i3k_log("Pos: "..i3k_format_pos(pos).. " | radius: ".. r.. "   nowTime: ".. curTime)
			-- i3k_log("safePos : "..i3k_format_pos(self._desertSafeInfo.pos).. "| radius: ".. self._desertSafeInfo.radius)
			self:UpdateShrinkRingPoison()
		end
	end
end

function i3k_world:UpdateDesertPoisonInfo()
	self._desertShrinkRing = false
	local safeInfo, poisonInfo, time = g_i3k_db.i3k_db_get_desert_battle_poisonCircle()
	if safeInfo then
		self._desertSafeInfo = safeInfo
		local desertSleepTime = g_i3k_db.i3k_db_get_poisonCircle_sleepTime()
		if poisonInfo then
			self._desertPoisonInfo = poisonInfo
			self:UpdatePoisonPos(poisonInfo.pos, poisonInfo.radius) --更新下位置比例
			if desertSleepTime and desertSleepTime <= 1 then
				self._desertShrinkRing = true
				local speedInfo = g_i3k_db.i3k_db_get_desertSpeed_info(safeInfo, poisonInfo, time)
				self:SetDesertSpeedInfo(speedInfo)
			end
		end
	end
end

function i3k_world:UpdateShrinkRingPoison()
	if self._desertShrinkRing then
		local pos, radius = self:GetPoisonData()
		self._desertPoisonInfo.pos = pos
		self._desertPoisonInfo.radius = radius
		self:UpdatePoisonPos(pos, radius)
	end
end

function i3k_world:UpdatePoisonPos(pos, radius)
	local cfg = i3k_db_desert_battle_base
	local poisonEntity = self:GetEntity(eET_Common, cfg.poisonModelID)
	if poisonEntity then
		poisonEntity:SetScale(radius / cfg.poisonEffectRadius)
		poisonEntity:SetPos(i3k_world_pos_to_logic_pos(pos))
	end
end

-- 更新毒圈数据
function i3k_world:GetPoisonData()
	local speed = self._desertSpeedInfo
	local safePos = self._desertSafeInfo.pos
	local poisonPos = self._desertPoisonInfo.pos
	-- local absX = math.abs(poisonPos.x + speed.x - safePos.x)
	-- local absZ = math.abs(poisonPos.z + speed.z - safePos.z)
	local r = math.abs(self._desertPoisonInfo.radius + speed.radius - self._desertSafeInfo.radius)
	if self._desertPoisonInfo.radius <= self._desertSafeInfo.radius then
		self._desertShrinkRing = false
		return safePos, self._desertSafeInfo.radius
	end
	return {x = poisonPos.x + speed.x, y = 0, z = poisonPos.z + speed.z}, self._desertPoisonInfo.radius + speed.radius
end

function i3k_world:SetDesertSpeedInfo(info)
	self._desertSpeedInfo = info
end

-- 获取毒圈圆心，半径
function i3k_world:GetDesertPoisonInfo()
	if self._desertPoisonInfo then
		return self._desertPoisonInfo.pos, self._desertPoisonInfo.radius
	end
	return nil
end

function i3k_world:ResetDesertPoisonInfo()
	self._desertPoisonInfo = nil
end
--家园宠物相关
function i3k_world:CreateHomelandPets(petInfo)
	if not self:GetHomePet(petInfo.id) then
		local petClass = require("logic/entity/i3k_home_pet")
		local pet = petClass.i3k_home_pet.new(i3k_gen_entity_guid_new(petClass.i3k_home_pet.__cname, petInfo.id))
		pet:CreateHomePetRes(petInfo)
		local pos = petInfo.location.position
		local rot = petInfo.location.rotation
		local r = i3k_vec3_angle2(i3k_vec3(rot.x,rot.y,rot.z), i3k_vec3(1, 0, 0));
		pet:SetFaceDir(0, r, 0);
		pet:SetPos(pos);
		pet:Show(true, true);
		pet:ShowTitleNode(true)
		pet:Play(i3k_db_common.engine.defaultStandAction, -1);
		self:AddEntity(pet);
	end
end
function i3k_world:RemoveHomelandPets(pets)
	local entity = self:GetHomePet(pets)
	if entity then
		self:ReleaseEntity(entity, true)
	end
end
function i3k_world:homelandPetsMovePos(id, pos, speed, rotation, timeTick)
	if speed < 10 then
		speed = 10 -- 客户端限制一下，速度小于这个阀值的时候，就给他一个最小速度，防止动作播放不出来
	end
	local entity = self:GetHomePet(id)
	if entity then
		entity:PlayPetRunAction()
		entity:UpdateProperty(ePropID_speed, 1, speed, true, false, true)
		if i3k_vec3_dist(entity._curPos, pos) > 300 then
			entity:SyncPos(pos)
		end
		entity:SyncVelocity(rotation, timeTick)
	end
end
function i3k_world:homelandPetsStopMove(id, pos, timeTick)
	local entity = self:GetHomePet(id)
	if entity then
		entity:SetPos(pos)
		entity:SyncStopMove(timeTick)
	end
end
function i3k_world:ResetHomePetTitle(id)
	local entity = self:GetHomePet(id)
	if entity then
		entity:UpdateHomePetTitle()
	end
end
--创建一次性自动寻路NPC
function i3k_world:CreateDisposableNpc(cfgID, npcID, location, pos, txt)
	local entityNPC = self:GetEntity(eET_DisposableNPC, cfgID)
	if not entityNPC then
		local Guid = self:CreateOnlyGuid(1, eET_DisposableNPC, cfgID);
		local SEntity = require("logic/entity/i3k_npc_disposable");
		entityNPC = SEntity.i3k_npc_disposable.new(Guid);
		if entityNPC:Create(npcID) then
			local r = i3k_vec3_angle2(i3k_vec3(location.rotation.x, location.rotation.y, location.rotation.z), i3k_vec3(1, 0, 0));
			local startPos = pos or location.position
			entityNPC:SetFaceDir(0, r, 0);
			entityNPC:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(startPos)))))
			entityNPC:SetGroupType(eGroupType_O)
			entityNPC:Play(i3k_db_common.engine.defaultStandAction, -1)
			entityNPC:Show(true, true, 100)
			entityNPC:NeedUpdateAlives(false)
			entityNPC:AddAiComp(eAType_IDLE_NPC)
			entityNPC:AddAiComp(eAType_DEAD)
			entityNPC:AddAiComp(eAType_AUTO_MOVE)
			entityNPC:AddAiComp(eAType_CHECK_ARRIVAL_TARGET)
			entityNPC:ShowTitleNode(true)
			entityNPC:SetHittable(true)
			self:AddEntity(entityNPC)
			if txt then
				entityNPC:popMessage(txt)
			end
		end
	end
	return entityNPC
end
function i3k_world:DisposableNpcMove(entityNPC, pos, popTxt, notRemove, fadeDistance)
	if not g_i3k_game_context:Caculator(entityNPC._curPosE, i3k_vec3_to_engine(pos), g_MOVE_STOP_DISTANCE) then
		local fun = function()
			if not notRemove then
				entityNPC:Show(false, false, 1000)--i3k_db_common.npcFadeTime);
				entityNPC:ShowTitleNode(false);
			end
			entityNPC:reSetFindPos()
			if popTxt then
				entityNPC:popMessage(popTxt)
			end
		end
		g_i3k_game_context:entityFindPath(entityNPC, pos, fun, notRemove, fadeDistance)
	end
end
--创建神机藏海机关通道NPC路径点entity
function i3k_world:CreateNpcPathEntity(floorId, pos)
	local floor = require("logic/entity/i3k_floor")
	local floorModel = floor.i3k_floor.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_Floor), floorId))
	floorModel:Create(i3k_db_magic_machine.moveEffectModleId, floorId)
	local r = i3k_vec3_angle2(i3k_vec3(1, 0, 0), i3k_vec3(1, 0, 0))
	floorModel:SetFaceDir(0, r, 0)
	floorModel:SetPos(pos)
	floorModel:Show(true, true)
	floorModel:SetHittable(false)
	floorModel:NeedUpdateAlives(false)
	self:AddEntity(floorModel)
	floorModel:Play("stand", -1)
end
--创建神机藏海机关通道NPC
function i3k_world:CreateMagicMachineNPC(pointIndex, routeId)
	local npcID = i3k_db_magic_machine.moveNpcId
	local pos = i3k_db_magic_machine.initNpcPos
	local dir = i3k_db_magic_machine.initNpcAngl  
	local r = i3k_vec3_angle2(i3k_vec3(dir.x, dir.y, dir.z), i3k_vec3(1, 0, 0));
	if pointIndex and routeId then
		local routePos = i3k_db_move_road_points[routeId].points
		pos = routePos[pointIndex]
	end
	local entityNPC = self:GetEntity(eET_DisposableNPC, npcID)
	if not entityNPC then
		local Guid = self:CreateOnlyGuid(1, eET_DisposableNPC, npcID);
		local SEntity = require("logic/entity/i3k_npc_disposable");
		entityNPC = SEntity.i3k_npc_disposable.new(Guid);
		if entityNPC:Create(npcID) then
			entityNPC:SetFaceDir(0, r, 0)
			entityNPC:SetGroupType(eGroupType_O)
			entityNPC:Play(i3k_db_common.engine.defaultStandAction, -1)
			entityNPC:Show(true, true, 100)
			entityNPC:NeedUpdateAlives(false)
			entityNPC:AddAiComp(eAType_IDLE_NPC)
			entityNPC:AddAiComp(eAType_DEAD)
			entityNPC:AddAiComp(eAType_AUTO_MOVE)
			entityNPC:AddAiComp(eAType_CHECK_ARRIVAL_TARGET)
			entityNPC:ShowTitleNode(true)
			entityNPC:SetHittable(true)
			entityNPC:SetPos(i3k_world_pos_to_logic_pos(pos))
			self:AddEntity(entityNPC)
		end
	end
end
function i3k_world:notifyMagicMachineNPCStartMove(pointIndex, routeId)
	local entityNPC = self:GetEntity(eET_DisposableNPC, i3k_db_magic_machine.moveNpcId)	
	if entityNPC then
		local routePos = i3k_db_move_road_points[routeId].points
		local speed = entityNPC:GetPropertyValue(ePropID_speed)
		entityNPC:SetMovePoints(g_i3k_db.i3k_db_get_move_point_info(routePos, speed / 100), pointIndex)
		self:loadNpcPathEntityPoints(routePos, pointIndex)
	end
end
function i3k_world:loadNpcPathEntityPoints(routePos, index)
	if index > 1 then
		for i = 1, index - 1 do
			self:CreateNpcPathEntity(i, i3k_world_pos_to_logic_pos(routePos[i]))			
		end
	end
end
----------------------------------帮派合照---------------------------------------
function i3k_world:CreateTakePhotoInfo(info, pos, scale)
	local SEntity = require("logic/entity/i3k_hero");
	local chiefId = g_i3k_game_context:GetFactionChiefID()
	local cfgInfo = i3k_db_faction_photo.cfgBase
	local Guid = self:CreateOnlyGuid(roleID, eET_Capture, info.id);
	local entity = SEntity.i3k_hero.new(Guid, true)
	local isChief = info.id == chiefId 
	entity:SetSyncCreateRes(true);
	if not entity:Create(info.overview.type, info.overview.name, info.overview.gender, info.wear.hair, info.wear.face, info.overview.level, { }, true, false, nil, info.overview.bwType) then
		entity = nil;
	end
	if entity then

		entity:setSoaringDisplay(info.wear.soaringDisplay)
		local _, skinDisplay = i3k_get_soaring_display_info(entity._soaringDisplay)
		entity._soaringDisplay.weaponDisplay = g_WEAPON_SHOW_TYPE
		if info.wear.heirloom then
			entity._heirloom = info.wear.heirloom
			entity:needShowHeirloom()
		end
		entity:SetFaceDir(0, 1.5707963, 0);
		entity:SetHittable(false);

		entity:SetPos(i3k_world_pos_to_logic_pos(pos), true);
		entity:Show(true, true);
		entity:SetScale(scale);
		for i,v in pairs(info.wear.wearEquips) do
			if (not entity._equips[i]) or (v ~= entity._equips[i].equipId )then
				entity:AttachEquip(v.equip.id);
			end
		end		
		
		local isShowWear = skinDisplay == g_WEAR_FASTION_SHOW_TYPE;
		if info.wear.curFashions[g_FashionType_Dress] and not entity:isSpecial()  then
			entity:AttachFashion(info.wear.curFashions[g_FashionType_Dress],isShowWear, g_FashionType_Dress)
		end
		entity:changeClothesShowType()
		entity:HidePlayerEquipPos()
		entity:ClearSkinEffect()
		entity:ShowTitleNode(false);
		entity:DetachTitleSPR()
		if info.id == chiefId then	
			--entity:CreateTitle(true)
			local name = g_i3k_game_context:GetSectName()
			entity:ShowTitleNode(true);
			entity:visTitleInfo(false)
			local color = tonumber("0xffffff00", 16)
			local nameColor = tonumber("0xffffff00", 16)
			entity:TakePhotoCreateTitle( -0.5, 1, -4.5,0.7,i3k_get_string(1790), true, "name", color)
			entity:TakePhotoCreateTitle( -0.5, 1, 3.2, 0.7, name, true, "typeName", nameColor)
		end
		entity:SetColor(g_i3k_db.i3k_db_get_map_entity_color())
		table.insert(i3k_capture_players, entity);
	end
end
function i3k_world:CapturePlayersRunAction() 
	for _, v in ipairs(i3k_capture_players) do
		v:Play(i3k_db_faction_photo.cfgBase.memberAction , 1);
	end
end
function i3k_world:CapturePlayersPause() 
	for _, v in ipairs(i3k_capture_players) do
		v:Pause();
	end
end
function i3k_world:ReleaseCapturePlayers()
	for _, v in ipairs(i3k_capture_players) do
		v:Release();
	end
	i3k_capture_players = { };
end
--创建场景
function i3k_world:CreateTakePhotoScene(senceInfo)
	local hero = i3k_game_get_player_hero()
	if hero then
		local common = require("logic/entity/i3k_entity_common")
		local Guid = self:CreateOnlyGuid(1, eET_Common, senceInfo.sceneModel);
		local commonEntity = common.i3k_entity_common.new(Guid)
		commonEntity:SetSyncCreateRes(true);
		commonEntity:Create(senceInfo.sceneModel);
		commonEntity:SetHittable(false);
		commonEntity:Show(true);
		commonEntity:Play("stand", -1);
		--commonEntity:NeedUpdateAlives(false);
		commonEntity:ShowTitleNode(true);
		commonEntity:SetPos(i3k_world_pos_to_logic_pos(senceInfo.scenePos));
		commonEntity:SetFaceDir(-0.523598, 1.5707963, 0)
		--self:AddEntity(commonEntity)
		commonEntity:SetColor(g_i3k_db.i3k_db_get_map_entity_color())
		table.insert(i3k_capture_players, commonEntity);
	end
end
----------------------------------------------
function i3k_world:createCatchSpiritEntities(points, pointCD)
	for k, _ in pairs(points) do
		local spirit = require("logic/entity/i3k_catch_spirit")
		local spiritModel = spirit.i3k_catch_spirit.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_CatchSpirit), k))
		spiritModel:Create(i3k_db_catch_spirit_base.dungeon.modelId, k)
		spiritModel:SetFaceDir(i3k_db_catch_spirit_position[k].rotation[1]/180*math.pi, i3k_db_catch_spirit_position[k].rotation[2]/180*math.pi, i3k_db_catch_spirit_position[k].rotation[3]/180*math.pi)
		local position = {}
		position.x = i3k_db_catch_spirit_position[k].pos[1]
		position.y = i3k_db_catch_spirit_position[k].pos[2]
		position.z = i3k_db_catch_spirit_position[k].pos[3]
		spiritModel:SetPos(i3k_world_pos_to_logic_pos(position))
		spiritModel:Show(true, true)
		spiritModel:SetHittable(false)
		spiritModel:NeedUpdateAlives(false)
		spiritModel:updateCallTime(pointCD and pointCD[k] or 0)
		self:AddEntity(spiritModel)
	end
end
function i3k_world:changeCatchSpiritCD(point, time)
	local spirit = self:GetEntity(eET_CatchSpirit, i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_CatchSpirit), point))
	if spirit then
		spirit:updateCallTime(time)
	end
end
function i3k_world:createCatchSpiritFragment(id, pos)
	local drop = require("logic/entity/i3k_ghost_fragment")
	local dropModel = drop.i3k_ghost_fragment.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_GhostFragment), self._ghostFragmentCount))
	dropModel:SetPos(i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)))))
	dropModel:Create(id, i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_GhostFragment), self._ghostFragmentCount))
	dropModel:Show(true, true)
	dropModel:SetHittable(false)
	dropModel:NeedUpdateAlives(false)
	self:AddEntity(dropModel)
	self._ghostFragmentCount = self._ghostFragmentCount + 1
end
function i3k_world:RefreshBiographyNpc()
	for k1, v1 in pairs(self._entities[eGroupType_O]) do
		if v1:GetEntityType() == eET_NPC then
			self:CheckNpcShow(v1)
		end
	end
end
-- 新节日任务特殊NPC显示状态
function i3k_world:SetNpcEntityPlayAction(npcID, action)
	local entity = self:GetNPCEntityByID(npcID)
	if entity then
		entity:Play(action, -1);
	end
end

--判定圣诞树等特殊Npc,需要同步圣诞树信息
function i3k_world:CheckSpecialNpcShow(npcid)
	if g_i3k_db.i3k_db_is_in_new_festival_task() then 
		if npcid == i3k_db_new_festival_info.specialNpc then
			
			g_i3k_game_context:CheckSpecialShowNpc();
		end
	end
end

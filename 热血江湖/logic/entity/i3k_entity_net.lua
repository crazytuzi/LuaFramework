------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_hero").i3k_hero;
require("logic/entity/i3k_entity");
local BASEENTITY = i3k_entity;


------------------------------------------------------
--
local eCmd_None				= -1;
local eCmd_UseSkill 		=  0;
local eCmd_ChildAttack		=  1;
local eCmd_FinishAttack		=  2;
local eCmd_EndSkill			=  3;
local eCmd_Move				=  4;
local eCmd_StopMove			=  5;
local eCmd_Shift			=  6;
local eCmd_Alter			=  7;
local eCmd_Dead				=  8;
local eCmd_Revive           =  9;


local eState_None			= -1;
local eState_Idle			=  0;
local eState_Move			=  1;
local eState_Attack			=  2;
local eState_Shift			=  3;
local eState_Alter			=  4;
local eState_Dead			=  5;
local eState_Revive         =  6;


------------------------------------------------------
i3k_entity_net = i3k_class("i3k_entity_net", BASE);
function i3k_entity_net:ctor(guid)
	self._cfg		= nil;
	self._player		= false;
	--self._auras		= { };
	self._buffs		= { };
	self._buffInsts		= { };
	self._curSkill		= nil;
	self._useSkill		= nil;
	self._maunalSkill	= nil;

	self._skills	= { }; -- 主动技能

	self._isDead	= false;
	self._target	= nil;
	self._attacker	= { };
	self._movement	= nil;
	self._equips	= { };
	self._ReviveStatus = 0;
	self._superMode	= { cache = { valid = false }, valid = false, attacks = 1, ticks = 0 };
	self._weapon	= { valid = false };
	self._changeEName
					= { };
	self._enmities	= { };
	self._headiconID = 0;
	self._fightsptime = 0;
	self._PKvalue = -1;
	self._PVPStatus = 0;
	self._PVPColor = -2;
	self._PVPFlag = 0;
	self._DIYSkillID = 0;
	self._fightstatus = false
	self._ride	= { cache = { valid = false }, valid = false, onMulHorse = false};
	self._mulHorse = {leaderId = 0, isLeader = false, memberIDs = {}, members = {}, mulPos = 1};
	self._fighttime = 0
	self._rideCurSpiritShowID = 0
	self._rideCurSpiritShow = nil
	self._cacheTargets = {}
	self._skilldeny = 0; --C
	self._needUpdateProperty = false;
	self._sectname = ""
	self._timedTitles = {}
	self._sectID = 0
	self._sectpos = -1
	self._Usefashion = {}
	self._equipinfo = {}
	self._fashionshow = true;
	self._bloodbarvis = false;
	self._changemodel = false;
	self._name = "";
	self._bwType = 0;
	self._forceType = 0;
	self._posId = 0;
	self._iscarRobber   = 0;--是否是劫镖者
	self._iscarOwner	= 0;--是否是运镖者
	self._lastAttacker	= nil;
	self._isAttacking	= false;
	self._cmdPool		= { };
	self._carState		= 0;
	self._isReplaceCar = false;
	self._sectIcon		= 1;
	self._state			= eState_None;
	self._timeTick      = 0;
	self._revived       = false;
	self._cacheClearTime = 0;
	self._inLeaveCache	= false;
	self._firstCre		= false;
	self._overtime 		= 0;
	self._processCmd	= nil;
	self._updateCmd		= function(dTime) self:OnIdleState(); end
	--神兵变身，任务变身状态下缓存时装改变数据，神兵变身结束时改变时装
	self._cacheFashionData = {vallid = false, fashionID = {}, isShow = {}}
	self._cacheFashionVis = {valid = false, isShow = {}}
	self._hugMode = {valid = false, isLeader = false, leaderId = 0, member = nil, memberId = 0, isStarKiss = false, isStarKissTime = 0};
	self._playSocial	= false;
	self._wizardPetId = nil;
	self._headBorder = 0;
	self._buffDrugs = {};
	self._isChagePaly = false;
	self._curWeaponSoulShow = false;
	self._curWeaponSoulID = nil;
	self._awaken = 0;
	self._specialArg = 0; --暂时未怪物特殊名字使用
	self._statueId = nil ; --用于记录荣耀殿堂内雕像id
	self._statueType = nil ; --用于记录荣耀殿堂内雕像类型
	self._sharetHp = nil;
	self._homeLandEquipSkinID = 0; --家园装备skinID
	self._deadFadeTime = i3k_db_common.engine.defaultDeadLoopTime -- 死亡持续时间
	self._fishStatus = 0 --钓鱼状态
	self._combatType = 0 --拳师姿态
end

function i3k_entity_net:Create(id, name, gender, hair, face, lvl, skills, cfg, entityType, agent, sectname, sectId, sectpos, sectIcon, permanentTitle, timedTitles, bwtype, carRobber, carOwner, awaken) --继承重写
	if not cfg then
		return false;
	end

	self._entityType = entityType
	if entityType == eET_Monster then
		self._entityType	= eET_Monster;
		self._isBoss		= cfg.boss ~= 0;
		if cfg.deadLoopTime then 
			self._deadFadeTime	= cfg.deadLoopTime
		end
	elseif entityType == eET_Player then
		self._entityType	= eET_Player;
		self._fashion		= g_i3k_db.i3k_db_get_general_fashion(id, gender or 1);
		if not self._fashion then
			return false;
		end
		self._firstCre		= true;
		self._fashionInfo	= { };
		self._iscarRobber	= carRobber or 0;
		self._iscarOwner	= carOwner or 0;
		self._bwType 		= bwtype or 0;
		self._gender		= gender or 1;
		self._hair			= hair or 0;
		self._face			= face or 0;
		self._sectname		= sectname or "";
		self._sectID		= sectId or 0;
		self._sectpos		= sectpos or -1;
		self._sectIcon		= sectIcon or 1
		self._timedTitles	= timedTitles or { };
	elseif entityType == eET_PlayerStatue then
		self._entityType	= eET_PlayerStatue;
		self._fashion		= g_i3k_db.i3k_db_get_general_fashion(id, gender or 1);
		if not self._fashion then
			return false;
		end
		self._firstCre		= true;
		self._fashionInfo	= { };
		self._iscarRobber	= carRobber or 0;
		self._iscarOwner	= carOwner or 0;
		self._bwType 		= bwtype or 0;
		self._gender		= gender or 1;
		self._hair			= hair or 0;
		self._face			= face or 0;
		self._sectname		= sectname or "";
		self._sectID		= sectId or 0;
		self._sectpos		= sectpos or -1;
		self._sectIcon		= sectIcon or 1
		self._timedTitles	= timedTitles or { };
	elseif entityType == eET_Mercenary then
		self._entityType	= eET_Mercenary;
		self._hoster		= nil;
		self._deadTimeLine	= -1;
	elseif entityType == eET_Pet then
		self._entityType	= eET_Pet;
		self._hoster		= nil;
	elseif entityType == eET_Car then
		self._entityType	= eET_Car;
		self._hoster		= nil;
	elseif entityType == eET_Skill then
		self._entityType	= eET_Skill;
		self._hoster        = nil;
	elseif entityType == eET_MarryCruise then
		self._entityType = eET_MarryCruise
		self._hoster = nil
	elseif entityType == eET_Summoned then
		self._entityType	= eET_Summoned;
		self._hoster		= nil;
	end
	self._isCreated = true

	return self:CreateFromCfg(id, name, cfg, lvl, skills, false);
end

function i3k_entity_net:CreatePreRes(entityType, cfg) --继承重写
	self._entityType	= entityType
	self._cfg			= cfg;
	self._lvl			= 1;
	self._name			= "";
	self._id            = cfg.id;
	self._create        = true;

	if entityType == eET_Monster then
		self._pop = {
			startPopProp = cfg.sPopProp,
			startPopText = cfg.sPopText,
			deathPopProp = cfg.dPopProp,
			deathPopText = cfg.dPopText,
		}
		self._isAttacked = false
		self._isPop = false
	end

	local res = BASEENTITY.Create(self, cfg.id, self._name);
	if res then
		self._hp = self:GetPropertyValue(ePropID_maxHP);
		self._sp = 0;
	end

	return res;
end

function i3k_entity_net:CreatePlayerRes()
	local res = BASEENTITY.Create(self, self._id, self._name);
	if res then
		self._hp = self:GetPropertyValue(ePropID_maxHP);
		self._sp = 0;
	end

	return res;
end

function i3k_entity_net:CreateTitle(reset)
	local _T = require("logic/entity/i3k_entity_title");
	if reset then
		if self._title and self._title.node then
			self._title.node:Release();
			if self:GetEntityType() == eET_Player then
				self._isHaveDynamic = false;
				self:DetachTitleSPR();
			end
			self._title.node = nil;
		end
		self._title = nil;
	end
	local title = { };

	local hero = i3k_game_get_player_hero()
	local mapType = i3k_game_get_map_type()
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("hero_title_node_" .. self._guid) then
		if self:GetEntityType() == eET_Player or self:GetEntityType() == eET_PlayerStatue then
			local offsetY = 0
			local isShow = true
			local mapTb = {
				[g_FORCE_WAR]	= true,
				[g_QIECUO] 		= true,
				[g_FACTION_WAR] = true,
				[g_TOURNAMENT]  = true,
				[g_TAOIST]		= true,
				[g_ARENA_SOLO] 	= true,
				[g_DEMON_HOLE]	= true,
				[g_BUDO]  		= true,
				[g_DEFENCE_WAR] = true,
				[g_PET_ACTIVITY_DUNGEON] = true,
				[g_DESERT_BATTLE] = true,
				[g_MAZE_BATTLE] = true,
				[g_PRINCESS_MARRY] = true,
				[g_MAGIC_MACHINE] = true,
				[g_GOLD_COAST] = true,
				[g_SPY_STORY] = true,
			}
			if mapType and mapTb[mapType] then
				isShow = false
			end
			if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
				isShow = false
			end

			local function creatSectTitle()
				local fullName = g_i3k_game_context:GetfullSectName(self._sectname,self._sectpos) or ""
				title.guild = title.node:AddTextLable(-0.5, 0.15, 0, 0.5, tonumber("0xffffe868", 16), fullName);
				if self._sectIcon then
					local len = i3k_get_name_len(fullName)
					local iconname = g_i3k_db.i3k_db_get_scene_icon_path(i3k_db_faction_icons[self._sectIcon].titleIcon)
					title.sectImg = title.node:AddImgLable(-(len/18)-1.0, 0.8, -0.7, 0.8, iconname);
				end
				offsetY = offsetY - 0.6
			end
			if self._sectname ~= "" and isShow then
				creatSectTitle()
				if self._iscarRobber == 1 then
					local image = g_i3k_db.i3k_db_get_scene_icon_path(i3k_db_escort.escort_args.robDartTitle)
					title.carName = title.node:AddImgLable(-1, 2, -1.2, 1,image);
					offsetY = offsetY - 0.6
					isShow = false
				end
			elseif mapType == g_GOLD_COAST and self._sectname ~= "" then --只显示帮派不显示称号
				creatSectTitle()
			end
			if isShow then
				title.honor = {}
				title.honorbg = {}
				local hindex = 0;
				for i=#self._timedTitles, 1, -1 do
					local cfg = i3k_db_title_base[self._timedTitles[i].titleId]
					if cfg then
						if cfg.isDynamic == 1 then
							self._isHaveDynamic = true;
							self._titleSprData = cfg;
							self:DetachTitleSPR();
							self:AttachTitleSPR();
							break;
						end
					end
				end
				if not self._isHaveDynamic then
					for i=#self._timedTitles, 1, -1 do
						local cfg = i3k_db_title_base[self._timedTitles[i].titleId]
						if cfg then
							local image = g_i3k_db.i3k_db_get_title_icon_path(cfg.name)
							local bgimage = g_i3k_db.i3k_db_get_title_icon_path(cfg.iconbackground)
							hindex = hindex + 1
							if bgimage ~= "" then
								title.honorbg[hindex] =  title.node:AddImgLable(-4, 8, offsetY - 1.25, 2, bgimage);
							end
							if image ~= "" then
								title.honor[hindex] =  title.node:AddImgLable(-1, 2, offsetY - 0.75, 1, image);
							end
							offsetY = offsetY - 0.85;
						end
					end
				end
			end
			if self:GetEntityType() == eET_PlayerStatue then
				if self._statueType == 1 then
					local titleIconID = i3k_db_statueExp_power_cfg[self._id].titleIconID
					local titleIcon = g_i3k_db.i3k_db_get_scene_icon_path(titleIconID)
					title.statueImage = title.node:AddImgLable(-5, 10, -2.5, 2.5, titleIcon)
				elseif self._statueType == 2 then
					local titleIcon = g_i3k_db.i3k_db_get_scene_icon_path(i3k_db_fight_team_champion.titleIconID)
					title.statueImage = title.node:AddImgLable(-5, 10, -2.5, 2.5,titleIcon)
				end
			end
			local world = i3k_game_get_world()
			if (mapType == g_TOURNAMENT and g_i3k_game_context:IsTeamMember(self:GetGuidID() or 0) or ((mapType==g_FORCE_WAR or mapType == g_BUDO or mapType == g_SPY_STORY) and self._forceType==hero._forceType)) then
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
			elseif (mapType == g_ARENA_SOLO or mapType == g_TAOIST or mapType == g_QIECUO) then
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, true);
			elseif mapType == g_FIELD or mapType == g_FACTION_GARRISON or mapType == g_GOLD_COAST then
				local isRed = self._sectID == 0 or self._sectID ~= g_i3k_game_context:GetSectId()
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, isRed);
			elseif mapType == g_DEMON_HOLE or mapType == g_MAZE_BATTLE then
				local isRed = self._sectID == 0 or self._sectID ~= g_i3k_game_context:GetSectId()
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, isRed);
			elseif hero and (hero._iscarRobber == 1 and self._iscarOwner == 1) or(hero._iscarOwner == 1 and self._iscarRobber == 1) then
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, true);
			elseif mapType == g_FACTION_WAR or mapType == g_DEFENCE_WAR or mapType == g_DESERT_BATTLE or mapType == g_PRINCESS_MARRY or mapType == g_SPY_STORY then 
				if self._forceType==hero._forceType then
					title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
				else
					title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, true);
				end			
			elseif g_MAGIC_MACHINE == mapType then
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
			else
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, not isShow);
			end
			local name = self._name
			if mapType == g_DEMON_HOLE then
				title.serverName = title.node:AddTextLable(-0.5, 0.2, -0.1, 0.5, tonumber("0xffffffff", 16), self:GetPlayerShowName(world));
				name =  i3k_get_string(i3k_db_demonhole_base.unifiedName)
			elseif mapType == g_DESERT_BATTLE then
				local score = self._desertInfo and self._desertInfo.scroe or 0
				name = i3k_get_string(17600, name, score)	
			elseif mapType == g_MAZE_BATTLE then
				name = i3k_get_string(i3k_db_maze_battle.nameId)
			elseif mapType == g_GOLD_COAST then 
				local len = i3k_get_name_len(name)		
				local iconname = self._forceType == hero._forceType and i3k_db_war_zone_map_cfg.sameSeverImg or i3k_db_war_zone_map_cfg.differSeverImg
				local titlePath = g_i3k_db.i3k_db_get_scene_icon_path(iconname)
				title.severImg = title.node:AddImgLable(-(len / 18) - 0.8, 0.6, -0.05, 0.6, titlePath);
			elseif mapType == g_SPY_STORY then
				name = name
			end
			
			title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), name);
		elseif self:GetEntityType() == eET_Mercenary or self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Summoned then
			title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), self._name);
			if (self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Summoned) and hero and (hero:GetGuidID() == self._hosterID or g_i3k_game_context:IsTeamMember(self._hosterID or 0))then
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
			elseif mapType == g_MAGIC_MACHINE then
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
			else
				local test = self:GetTournamentFriendPet(self._guid)
				local mapTable = 
				{
					[g_FORCE_WAR] = true,
					[g_FACTION_WAR] = true,
					[g_BUDO] = true,
					[g_DEFENCE_WAR] = true,
					[g_PRINCESS_MARRY] = true,
					[g_SPY_STORY] = true,
				}
				if ((mapTable[mapType] and self._forceType==hero._forceType) or (mapType == g_TOURNAMENT and test)) then
					title.bbar = title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
				else
					title.bbar = title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5, true);
				end
			end
		elseif self:GetEntityType() == eET_Car then
			title.name	= title.node:AddTextLable(-0.5, 1, -0.1, 0.5, tonumber("0xffffffff", 16), self._name);
			local carRobSate = g_i3k_game_context:GetEscortRobState()
			if carRobSate == 1 then
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.1, 0.25 * 0.5,true);
			else
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.1, 0.25 * 0.5);
			end
		elseif self:GetEntityType() == eET_Monster then
			title = self:CreateMonsterTitle(title)
		end
	else
		title.node = nil;
	end

	return title;
end

function i3k_entity_net:CreateMonsterTitle(title)
	local titleMul = {}
	local color = tonumber("0xffffffff", 16)
	local showName = self:GetMonsterShowName()
	if self._cfg.typeDesc ~= "" then
		titleMul = {
		[1] = {isText = true, isTypeName = true, x = -0.5, w = 1, y = -0.5, h = 0.5, name = self._cfg.typeDesc},
		[2] = {isText = true, isTypeName = false, x = -0.5, w = 0.2, y = -0.1, h = 0.5, name = showName},
		[3] = {isText = false, x = -0.5, w = 1, y = 0.5, h = 0.125},
		}
	else
		titleMul = {
		[1] = {isText = true, x = -0.5, w = 1, y = -0.5, h = 0.5, name = showName},
		[2] = {isText = false, x = -0.5, w = 1, y = 0.5, h = 0.25 * 0.5}
		}
	end
	title.nameTb = {}
	for i, e in ipairs(titleMul) do
		if e.isText then
			if e.isTypeName then
				title.typeName = title.node:AddTextLable(e.x, e.w, e.y, e.h, color, e.name);
			else
				title.name = title.node:AddTextLable(e.x, e.w, e.y, e.h, color, e.name);
			end
		else
			local mapType = i3k_game_get_map_type()
			local hero = i3k_game_get_player_hero()
			local mapTable = 
			{
				[g_FORCE_WAR] = true,
				[g_FACTION_WAR] = true,
				[g_BUDO] = true,
				[g_DEFENCE_WAR] = true,
				[g_PRINCESS_MARRY] = true,
				[g_SPY_STORY] = true,
			} 
			if mapTable[mapType] and self._forceType == hero._forceType then
				title.bbar = title.node:AddBloodBar(e.x, e.w, e.y, e.h);
			elseif mapType == g_DEFEND_TOWER and self._bwType == g_DEFENCE_NPC_TYPE then
				title.bbar = title.node:AddBloodBar(e.x, e.w, e.y, e.h); --守护npc血条颜色特殊处理
			elseif mapType == g_HOMELAND_GUARD and self._bwType == g_HOMELAND_GUARD_TREE_TYPE then
				title.bbar = title.node:AddBloodBar(e.x, e.w, e.y, e.h); --家园保卫战果树血条颜色特殊处理
			else
				title.bbar = title.node:AddBloodBar(e.x, e.w, e.y, e.h, true);
			end
		end
	end
	return title
end

function i3k_entity_net:GetPlayerShowName(world)
	local showName = ""
	if world and world._mapType == g_DEMON_HOLE then
		local _guid = string.split(self._guid, "|")
		local playerId = tonumber(_guid[2])
		local serverName = i3k_game_get_server_name_from_role_id(playerId)
		showName = serverName
	else
		showName = self._name
	end
	return showName
end

function i3k_entity_net:CanRelease() --继承重写
	if self:GetEntityType() == eET_Player or self:GetEntityType() == eET_Mercenary then
		return false;
	else
		return true;
	end
end

function i3k_entity_net:IsPlayer() --继承重写
	return false;
end

function i3k_entity_net:IsSyncEntity()
	return true;
end

function i3k_entity_net:CreateFromCfg(id, name, cfg, lvl, agent) --继承重写
	self._lvl		= lvl;
	self._id		= id
	self._cfg		= cfg;
	self._rescfg	= i3k_db_models[self._cfg.modelID]
	self._cname		= cfg.name;
	self._name		= name;
	self._radius	= cfg.radius;

	local res = true
	if not self._create then
		res = BASEENTITY.Create(self, id, name);
		self._hp = self:GetPropertyValue(ePropID_maxHP);
		self._sp = 0;
	end

	self:TitleColorTest();
	self:ShowTitleNode(true);

	if self._fashion then
		self:CreateResWithFashion(self._fashion);
	elseif self:GetEntityType() == eET_Mercenary and self._awaken == 1 then 
		self:CreateRes(i3k_db_mercenariea_waken_property[id].modelID);
	else
		self:CreateRes(self._cfg.modelID);
	end

	if self:GetEntityType() == eET_Monster then
		if self._cfg.hasOutline == 1 then
			self:EnableOutline(true, self._cfg.outlineColor);
		end
	end

	return res;
end

function i3k_entity_net:CreateNetRes(id, modelID)
	if id == -1 then
		self._entityType = eET_Ghost;
	end

	if self._fashion then
		self:CreateResWithFashion(self._fashion);
	else
		self:CreateRes(modelID);
	end

	--local res = BASEENTITY.Create(self, id, self._name);
	--return res
end

function i3k_entity_net:Release() --继承重写
	if self._attacker then
		for k, v in ipairs(self._attacker) do
			v:Release(false);
		end
	end
	if self._selected then
		local logic = i3k_game_get_logic();
		if logic then
			logic:SwitchSelectEntity(nil);
		end
	end
	BASEENTITY.Release(self);
end

function i3k_entity_net:OnIdleState()
	if self._state ~= eState_Idle then
		self._state = eState_Idle;
		if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId and not self:IsOnRide() then
			self:PlaySpringIdleAct()
		elseif self._hugMode.valid and self:GetEntityType() == eET_Player then
			if self._hugMode.isLeader then
				self:Play(i3k_db_common.hugMode.pickUpStand, -1);
			else
				self:Play(i3k_db_common.hugMode.pickedUpStand, -1);
			end
		else
			self._isChagePaly = false;
			self:ChageWeaponSoulAction(i3k_db_common.engine.defaultStandAction);
			if self:GetEntityType() == eET_PlayerStatue and self._statueType == 1 then
				self:Play(i3k_db_common.engine.defaultStandAction, -1);
			elseif self:GetEntityType() == eET_PlayerStatue and self._statueType == 2 then
				self:Play("rongyaodiantang", -1)
			else
				self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
			end
		end
	end

	self._updateCmd = nil;
end

function i3k_entity_net:OnDeadState(killer, isPlay)
	if self._state ~= eState_Dead then
		self._state = eState_Dead;

		self:OnDead(killer);
		self._movement = nil;

		self:ShowTitleNode(false);

		local etype = self:GetEntityType();

		if etype == eET_Player then
			if self._superMode.valid then
				self:OnSuperMode(false);
			end

			if self:IsOnRide() then
				self:OnRideMode(false);
			end
		end

		if etype ~= eET_Pet and etype ~= eET_Skill then
			local alist = {}
			if isPlay and isPlay ~= nil  then
                table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadAction, actloopTimes = 1})
			end
            table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadLoopAction, actloopTimes = -1})
			self:PlayActionList(alist, 1);
			--self:LockAni(true);
		end

		self._deadLine	= 0;
		self._deadFade	= false;
	end
end

function i3k_entity_net:UpdateDeadState(dTime)
	self._deadLine = self._deadLine + dTime;

	if self._deadLine > 4 then
		self:Destory();
	elseif self._deadLine > self._deadFadeTime / 1000 then
		if not self._deadFade then
			self._deadFade = true;

			self:Show(false, true, self._deadFadeTime);
		end
	end
end

function i3k_entity_net:StartMonsterAlter()
	if self._state == eState_Alter then
		local alist = {}
        table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadAction, actloopTimes = 1})
        table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadLoopAction, actloopTimes = -1})
		self:PlayActionList(alist, 1);
	end
end

function i3k_entity_net:SyncAlter()
	self:PushCmd({
		id = eCmd_Alter,
		func = function()
			self._state = eState_Alter;
		end
	});
end

function i3k_entity_net:UpdateState()
	local _attack	= self._attacker and self._attacker[1];
	local _move		= self._movement ~= nil;
	local _dead		= self._state == eState_Dead;
	local _revive   = self._revived;
	local _arlter	= self._state == eState_Alter;

	if _dead then
		if self:CanRelease() then
			self._updateCmd = function(dTime)
				self:UpdateDeadState(dTime);
			end
		else
			self._updateCmd = nil;
		end
	elseif _attack and _move then
		self._updateCmd = function(dTime)
			if self._attacker then
				for k, v in ipairs(self._attacker) do
					v:OnUpdate(dTime);
				end
			end
			if self._movement then
				self._movement.update(dTime);
			end
		end
	elseif _attack then
		self._updateCmd = function(dTime)
			if self._attacker then
				for k, v in ipairs(self._attacker) do
					v:OnUpdate(dTime);
				end
			end
		end
	elseif _move then
		self._updateCmd = function(dTime)
			self._playSocial = false;
			if self._movement then
				self._movement.update(dTime);
			end
		end
	elseif self._isAttacking then
		--self._updateCmd = nil;
	elseif _revive then
		self._updateCmd = function(dTime)
			self._timeTick = self._timeTick + dTime * 1000;
			if self._timeTick > i3k_db_common.rolerevive.duration then
				self._revived = false;
				self:StopReviveEffect();
				self:UpdateState();
			end
		end
	elseif _arlter then
		self:StartMonsterAlter();
	end
	
	local behavior = 
	{
		[eEBFloating] = true,
		[eEBPrepareFight] = true,
	}
	
	if (not self._isAttacking) and (not _move) and (not _dead) and (not _revive) and (not self._playSocial) and not _arlter and not self:TestBehaviorStateMap(behavior) then
		self:OnIdleState();

		--self._updateCmd = nil;
	end

	if (not _dead) and (not _move) and (not _attack) and (not _revive) then
		self._updateCmd = nil;
	end
end

function i3k_entity_net:ClearState()
	-- self._attacker = {};
	self:ClsAttackers()
	self._movement = nil;
	self._state = eState_None;
	self._revived = false;
	self._updateCmd = nil;
end

function i3k_entity_net:OnLeaveWorld() --继承hero
	BASEENTITY.OnLeaveWorld(self);

	if self._skills then
		for k, v in pairs(self._skills) do
			v:OnReset();
		end
	end

	self:ClsBuffs();
	self:ClsAttackers();
end

function i3k_entity_net:SetTitleVisiable(vis)
	if not self._bloodbarvis and vis then
		if self._entity then
			self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP));
		end
	end
	self._bloodbarvis = vis
	local entityType = self:GetEntityType()
	if entityType == eET_Monster or entityType == eET_Car then
		if self._title and self._title.node then
			if self._title.name then
				self._title.node:SetElementVisiable(self._title.name,vis)
			end
			if self._title.typeName then
				self:SetTypeNameVisiable(vis)
			end
		end
	end
	self:SetTitleShow(vis)
	self:SetBloodBarVisiable(vis);
end

-- 更新引擎相关
function i3k_entity_net:OnUpdate(dTime) --继承hero
	if self._processCmd then
		self._processCmd();
	end

	if self._updateCmd then
		self._updateCmd(dTime);
	end

	self._text_pool:OnUpdate(dTime);

	local g_i3k_release_time = 3;
	if self._inLeaveCache then
		self._cacheClearTime = self._cacheClearTime + dTime;

		if self._cacheClearTime > g_i3k_release_time then
			local world = i3k_game_get_world();
			if world and world._CacheEntitys then
				table.insert(world._CacheEntitys,{entity = self});
			end
		end
	end

	if  self:GetEntityType() == eET_Player then
		self:updateWizard(dTime)
	end

	self._overtime = self._overtime + dTime;
	if self._overtime > 60 then
		self._overtime = 0;
		local guid = string.split(self._guid, "|");
		local RoleID = tonumber(guid[2]);
		local entityType = self:GetEntityType();
		if self and self._guid and entityType ~= eET_NPC then
			if entityType == eET_Player or entityType == eET_Car or entityType == eET_Monster or entityType == eET_Trap then
				i3k_sbean.check_entity_nearby(self, RoleID, entityType);
			else
				if entityType == eET_Mercenary or entityType == eET_Pet or entityType == eET_Skill then
					if self._hosterID and self._hosterID ~= nil then
						local world = i3k_game_get_world();
						local Entity = world:GetEntity(eET_Player, self._hosterID);
						if self and not Entity then
							world:ReleaseEntity(self);
						end
					end
				end
			end
		end
	end


	--[[
	self._idle = not self:ProcessCmd();

	if self._attacker then
		for k, v in ipairs(self._attacker) do
			v:OnUpdate(dTime);
		end
	end

	if self._movement then
		self._idle = false;

		self._movement.update(dTime);
	end
	]]

	--[[
	if self._buffs then
		for _, buff in pairs(self._buffs) do
			buff:OnUpdate(dTime);
		end
	end

	BASEENTITY.OnUpdate(self, dTime);
	]]
end

function i3k_entity_net:OnLogic(dTick, real)
	--local valid = self:ProcessCmd();

	--[[
	if self._attacker then
		local rmvs = { };
		for k, v in ipairs(self._attacker) do
			if not v:OnLogic(dTick) then
				v:Release();

				table.insert(rmvs, k);
			end
		end

		for k = #rmvs, 1, -1 do
			table.remove(self._attacker, rmvs[k]);
		end
	end

	if self._buffs then
		for _, buff in pairs(self._buffs) do
			if not buff:OnLogic(dTick) then
				self:RmvBuff(buff);
			end
		end
	end

	BASEENTITY.OnLogic(self, dTick, valid);
	]]
end

function i3k_entity_net:InitProperties() --继承重写
	local properties = BASEENTITY.InitProperties(self);

	return properties;
end

function i3k_entity_net:OnInitBaseProperty(props) --继承重写
	local id	= self._id;
	local lvl	= self._lvl;
	local cfg	= self._cfg;

	local properties = BASEENTITY.OnInitBaseProperty(self, props);

	-- add new property
	properties[ePropID_maxHP]			= i3k_entity_property.new(self, ePropID_maxHP,			0);
	properties[ePropID_maxSP]			= i3k_entity_property.new(self, ePropID_maxSP,			0);
	properties[ePropID_sp]				= i3k_entity_property.new(self, ePropID_sp,			0);

	local all_hp		= 600;
	local speed			= 0;
	local all_sp		= i3k_db_common.general.maxEnergy;
	if not lvl then
		lvl = 1
	end
	if cfg then
		local _lvl = lvl - 1;
		all_hp		= all_hp
		speed		= cfg.speed;
	end

	-- update all properties
	properties[ePropID_lvl				]:Set(lvl,			ePropType_Base, true);
	properties[ePropID_maxHP			]:Set(all_hp,		ePropType_Base);
	properties[ePropID_maxSP			]:Set(all_sp,		ePropType_Base);
	properties[ePropID_sp				]:Set(0,			ePropType_Base);

	return properties;
end

function i3k_entity_net:SyncVelocity(vel, tick)
	self:PushCmd({
		id		= eCmd_Move,
		tick	= tick,
		func	= function()
			local _vel = i3k_vec3_clone(vel);
			_vel.y = 0;

			local _speed= self:GetPropertyValue(ePropID_speed) / 100;
			local hero = i3k_game_get_player_hero();
			if self:GetEntityType() ~= eET_Skill then
				if self:GetEntityType() == eET_Player and (self._iscarOwner == 1 and self:GetPropertyValue(ePropID_speed) <= g_i3k_game_context:GetEscortCarSpeed() or g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId) then
					if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
						if g_i3k_game_context:getSpringPos(self._curPosE) == SPRING_TYPE_WATER then
							self:Play(i3k_db_spring.common.waterWalk, -1);
						else
							self:Play(i3k_db_spring.common.landWalk, -1);
						end
					else
						self:Play(i3k_db_common.engine.roleWalkAction, -1);
					end
				else
					if not self._isChagePaly then
						self._isChagePaly = true;
						self:ChageWeaponSoulAction(i3k_db_common.engine.defaultRunAction);
					end
					self:Play(i3k_db_common.engine.defaultRunAction, -1);
				end
			end
			self:SetFaceDir(0, i3k_vec3_angle2(vel, i3k_vec3(1, 0, 0)), 0);
			self._state = eState_Move;

			local movement = { };
			movement.update = function(dTime)
				local pos = i3k_vec3_add1(self._curPosE, i3k_vec3_mul2(_vel, _speed * dTime));
				self:UpdateWorldPos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(pos)));
			end

			self._movement = movement;
		end
	});
end

function i3k_entity_net:SyncStopMove(tick)
	self:PushCmd({
		id		= eCmd_StopMove,
		tick	= tick,
		func	= function()
			self._movement = nil;
			--BASE.SyncStopMove(self, tick);
		end
	});
end

function i3k_entity_net:SyncShift(dir, info)
	self:PushCmd({
		id		= eCmd_Shift,
		tick	= tick,
		func	= function()
			self._state		= eState_Shift;
			self._shiftLine	= 0;

			local shiftInfo = { };
				shiftInfo.dir		= dir;
				shiftInfo.height	= (info.height / 100);
				shiftInfo.velocity	= (info.velocity / 100);
				shiftInfo.startPos	= self._curPosE;
				--shiftInfo.targetPos	= i3k_logic_pos_to_world_pos(info.endPos);
				shiftInfo.targetPos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(info.endPos)));
				shiftInfo.middlePos	= i3k_vec3_div2(i3k_vec3_add1(shiftInfo.startPos, shiftInfo.targetPos), 2);
				shiftInfo.middlePos.y = shiftInfo.middlePos.y + (info.height / 100);
				shiftInfo.step		= { };
				shiftInfo.step[1]	= { };
				shiftInfo.step[1].dir		= i3k_vec3_normalize1(i3k_vec3_sub1(shiftInfo.middlePos, shiftInfo.startPos));
				shiftInfo.step[1].duration	= i3k_vec3_dist(shiftInfo.middlePos, shiftInfo.startPos) / shiftInfo.velocity;
				shiftInfo.step[2]	= { };
				shiftInfo.step[2].dir		= i3k_vec3_normalize1(i3k_vec3_sub1(shiftInfo.targetPos, shiftInfo.middlePos));
				shiftInfo.step[2].duration	= i3k_vec3_dist(shiftInfo.targetPos, shiftInfo.middlePos) / shiftInfo.velocity;
				shiftInfo.duration	= shiftInfo.step[1].duration + shiftInfo.step[2].duration;

			local movement = { };
			movement.update = function(dTime)
				self._shiftLine = self._shiftLine + dTime;

				-- 结束
				if self._shiftLine >= shiftInfo.duration then
					self._movement = nil;
					self:UpdateWorldPos(i3k_vec3_to_engine(shiftInfo.targetPos));
					self:UpdateState();
				elseif self._shiftLine >= shiftInfo.step[1].duration then
					local pos = i3k_vec3_add1(self._curPosE, i3k_vec3_mul2(shiftInfo.step[2].dir, shiftInfo.velocity * dTime));

					self:UpdateWorldPos(i3k_vec3_to_engine(pos));
				else
					local pos = i3k_vec3_add1(self._curPosE, i3k_vec3_mul2(shiftInfo.step[1].dir, shiftInfo.velocity * dTime));

					self:UpdateWorldPos(i3k_vec3_to_engine(pos));
				end
			end

			local shift_str;
			if info.type == 3 then
				shift_str = i3k_get_string(169); -- 拖拽
			elseif info.height == 0 then
				shift_str = i3k_get_string(162); -- 击退
			else
				shift_str = i3k_get_string(568); -- 击飞
			end
			self:ShowInfo(sender, eEffectID_DeBuff.style, shift_str, i3k_db_common.engine.durNumberEffect[2] / 1000);

			self._movement = movement;
		end
	});
end

function i3k_entity_net:OnStopAction(action) --继承重写
	BASEENTITY.OnStopAction(self, action);
end

-- only for maunal handle
function i3k_entity_net:MaunalAttack(id)
	local res = false;

	local _skill = nil;

	if self._superMode.valid then
		_skill = self._weapon.skills[self._superMode.attacks];
	else
		if id == 0 then
			_skill = self:GetAttackSkill();
		else
			local sid = self._bindSkills[id];
			if sid then
				_skill = self._skills[sid];
			end
		end
	end

	if _skill then
		if self:CanUseSkill(_skill) then
			if self._AutoFight and not self._targets and _skill._etype ~= 2 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(235))
			else
				self._maunalSkill = _skill;
			end
			res = true;
		else
			self._PreCommand = id;
		end
	end

	return res;
end

function i3k_entity_net:ResetMaunalAttack()
	self._maunalSkill = nil;
end

function i3k_entity_net:OnSuperMode(enable)
	self._superMode.cache.valid = enable;
	if self:IsResCreated() or (self._changemodel and not enable )then
		self:FinishAttack();
		self:ResetMaunalAttack();
		self._curSkill = nil;
		self._target = nil;
		self:ClsAttackers();
		
		if enable then
			self:ClsAttackers();
			self:ClearEquipEffect();
			self:DetachWeaponSoul()
			if self:IsOnRide() then
				self:OnRideMode(false);
			end
			if not self._superMode.valid then
				self._superMode.valid = true;
			end
			local ismoveing = self._behavior:Test(eEBMove)
			if ismoveing then
				self:Play(i3k_db_common.engine.defaultRunAction, -1);
			else
				self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
			end
			self:ClearCombatEffect()
			self:ChangeModelFacade(self._weapon.deform.args);
			self._changemodel = true;	
		else
			self._changemodel = false;
			self._target = nil;
			self:ClsAttackers();
			if self._superMode.valid then
				self._superMode.valid = false
			end
			if self._equipinfo then
				self:AttachEquipEffect(self._equipinfo)
			end
			self:RestoreModelFacade()
			self:AttachWeaponSoul(self._curWeaponSoulID)
		end
	end
end

function i3k_entity_net:UpdateSuperMode(dTick) --无用
end

function i3k_entity_net:updateWizard(dTick)
	if self._wizardPetId then
		local wizarData = i3k_db_arder_pet[self._wizardPetId]
		if self:isDaZuo() and not self._wizard[self._guid] then
			self:AttachWizard(wizarData);
		elseif not self:isDaZuo()and self._wizard[self._guid] then
			self:DetachWizard(self._guid)
		end
	end
end

function i3k_entity_net:UseWeapon(wid,form) --继承重写
	self._weapon.valid = false;
	local changeType, args = g_i3k_db.i3k_db_get_weapon_deform(self._gender, wid, form)
	self._weapon.deform = { type = changeType, args = args};
end

function i3k_entity_net:OnBuffChanged(hoster)
	local logic = i3k_game_get_logic()
	local selEntity = logic._selectEntity;
	if selEntity then
		if selEntity._guid == hoster._guid then
			local buffs = {}
			for k,v in pairs(hoster._buffs) do
				buffs[v._id] = v._endTime - v._timeLine
			end
			g_i3k_game_context:OnTargetBuffChangedHandler(buffs)
		end
	end
end

function i3k_entity_net:OnProlongBuff(buff, value)
	for k, v in pairs(self._buffs) do
		local valid = false;
		if buff then
			valid = v._type == eBuffType_Buff;
		else
			valid = v._type == eBuffType_DBuff;
		end

		if valid then
			if v._endTime > 0 and value.type == 1 then
				v._endTime = v._endTime + value.value;
			end
		end
	end
end

function i3k_entity_net:ChildAttack(mainSkill, skillID)
	self:PushCmd({
		id		= eCmd_ChildAttack,
		tick	= nil,
		func	= function()
			local child = nil;
			local skill = self._skills[mainSkill];

			if skill and skill._child_skill then
				for k, v in ipairs(skill._child_skill) do
					child = self:StartAttack(v);
				end
			end
			local mainAttacker = self:CheckAttacker(mainSkill,self._attacker);

			if mainAttacker then
				mainAttacker:AddChilds(child)
			end
		end
	});

	return true;
end

function i3k_entity_net:CheckAttacker(skillID,attacker)
	if attacker then
		for k,v in ipairs(attacker) do
			if v._skill and v._skill._id == skillID then
				return v;
			elseif v._parentSkill and v._parentSkill._id == skillID then
				return v;
			else
				if #v._childs > 0 then
					return self:CheckAttacker(skillID, v._childs)
				end
			end
		end
	end

	return nil;
end

function i3k_entity_net:CanAttack()
	return true;
end

function i3k_entity_net:CanMove()
	return true;
end

function i3k_entity_net:CanUseSkill(skill)
	return true;
end

function i3k_entity_net:UseSkill(skill)
	self:PushCmd({
		id = eCmd_UseSkill,
		func = function()
			if not self._isAttacking then
				self._isAttacking	= true;
				self._state			= eState_Attack;
				self._curSkill		= skill;
				self._lastAttacker	= self:StartAttack();
			end
		end
	});

	return true;
end

function i3k_entity_net:StartAttack(skill)
	local _force = true;
	local _skill = self._curSkill;
	if skill then
		_skill = skill;
		_force = false;
	end

	if _skill then
		if g_i3k_db.i3k_db_is_skillId_pet_skill(self._id, _skill._id) then
			self:PlayPetGuardAction("01attack01")
		end
		_skill:Use(eSStep_Spell);

		if _force then
			self._behavior:Set(eEBAttack);
		end

		local _A = require("logic/battle/i3k_attacker_net");
		local attacker = _A.i3k_attacker_net_create(self, _skill, { self._target }, not _force, false);
		if attacker and self._attacker then
			table.insert(self._attacker, attacker);
		end

		if _force and not _skill._canAttack then
			self._behavior:Set(eEBDisAttack);
		end

		self._useSkill		= self._curSkill;
		if _force then
			self._curSkill	= nil;
			self._maunalSkill
							= nil;
			self._target	= nil;
		end

		return attacker;
	end

	return nil;
end

function i3k_entity_net:FinishAttack()
	self:PushCmd({
		id = eCmd_FinishAttack,
		func = function()
			self._isAttacking = false;

			self._behavior:Clear(eEBAttack);
		end
	});
end

function i3k_entity_net:ClsAttacker(skillid)
	self:PushCmd({
		id = eCmd_EndSkill,
		func = function()
			local attacker = self:CheckAttacker(skillid, self._attacker);
			if attacker then
				attacker:Release();
			end
		end
	});
end

function i3k_entity_net:ClsAttackers()
	if self._attacker then
		for k, v in ipairs(self._attacker) do
			v:Release(false);
		end
		self._attacker = { };
	end
end

function i3k_entity_net:PushCmd(cmd)
	table.insert(self._cmdPool, cmd);

	self._processCmd = function()
		self:ProcessCmd();
	end
end

function i3k_entity_net:ProcessCmd()
	local cmd = self._cmdPool[1];
	if cmd then
		cmd.func();

		table.remove(self._cmdPool, 1);

		-- check cmd udpate func
		if not self._cmdPool[1] then
			self._processCmd = nil;
		end

		self:UpdateState();

		return true;
	end

	return false;
end

-- stype -1: all
function i3k_entity_net:BreakAttack(stype)
	local _type = -1;
	if stype then
		_type = stype;
	end

	local rmvs = { };
	for k, v in ipairs(self._attacker) do
		if (_type == -1) or (_type == v._stype) then
			v:Release(false);
			table.insert(rmvs, k);
		end
	end

	for k = #rmvs, 1, -1 do
		local rid = rmvs[k];
		if rid then
			table.remove(self._attacker, rid);
		end
	end
end

function i3k_entity_net:SetTarget(target)
	self._target = target;
end

function i3k_entity_net:SetForceTarget(target)

end

function i3k_entity_net:GetFollowTarget()
	return self._target;
end

function i3k_entity_net:OnSelected(val)	
	BASEENTITY.OnSelected(self, val);
	if val == false then
		g_i3k_game_context:OnCancelSelectHandler()
		return;
	end
	local maxhp = self:GetPropertyValue(ePropID_maxHP)
	local curhp = self:GetPropertyValue(ePropID_hp)
	local buffs = {}
	for k,v in pairs (self._buffs) do
		buffs[v._id] = v._endTime-v._timeLine;
	end
	if self:GetEntityType() == eET_Player then
		local guid = string.split(self._guid, "|")
		local name = self._name
		local level = self._lvl
		local mapType = i3k_game_get_map_type()
		if mapType == g_DEMON_HOLE then
			name = i3k_get_string(i3k_db_demonhole_base.unifiedName)
		elseif mapType == g_PET_ACTIVITY_DUNGEON and self._petDungeonInfo then
			level = self._petDungeonInfo.level
		elseif mapType == g_MAZE_BATTLE then
			name = i3k_get_string(i3k_db_maze_battle.nameId)
		end
		g_i3k_game_context:OnSelectRoleHandler(tonumber(guid[2]), self._headiconID, name, level, curhp, maxhp, buffs, (self._bwtype or 0), self._ride.onMulHorse,self._sectID, self._gender, self._headBorder, self._buffDrugs, self._id, self._internalInjuryState.value, self._internalInjuryState.maxInjury)
	elseif self:GetEntityType() == eET_Monster then
		local showName  = self:GetMonsterShowName()
		if g_i3k_game_context:GetBossBloodNeedUpdate() then
			curhp = self:GetShareHp() or curhp
		end
		if self._armorState.value and self._armorState.maxArmor and self._armorState.maxArmor ~= 0 then
			g_i3k_game_context:OnSelectMonsterHandler(self._id, curhp, maxhp, buffs, self._armorState.value, self._armorState.maxArmor, showName, self._guid)
		else
			g_i3k_game_context:OnSelectMonsterHandler(self._id, curhp, maxhp, buffs, nil, nil, showName, self._guid)
		end
		--g_i3k_ui_mgr:PopupTipMessage(self._guid)
		local time = i3k_game_get_time()
		local clickData = self._canClickData
		
		if clickData.canClickCount and clickData.canClickCount > 0 and time - clickData.clickTime >= i3k_db_common.clicklimit then
			self._canClickData.clickTime = time
			self._canClickData.haveClickCount = clickData.haveClickCount + 1
			
			if self._canClickData.haveClickCount >= clickData.canClickCount then
				i3k_sbean.recordHorseClickCount(self:GetGuidID())
			end			
		end
	elseif self:GetEntityType() == eET_Mercenary then
		g_i3k_game_context:OnSelectMercenaryHandler(self._cfg.id, self._lvl, self._name, curhp, maxhp, buffs, self._awaken)
	elseif self:GetEntityType() == eET_Pet then
		g_i3k_game_context:OnSelectPetHandler(self._id, curhp, maxhp, buffs)
	elseif self:GetEntityType() == eET_Summoned then
		g_i3k_game_context:OnSelectSummonedHandler(self._id, curhp, maxhp, buffs)
	elseif self:GetEntityType() == eET_Car then
		g_i3k_game_context:OnSelectEscortCarHandler(self._cfg.id, self._lvl, self._name, curhp, maxhp, buffs, true)
	elseif self:GetEntityType() == eET_PlayerStatue then
		i3k_sbean.showStatueInfo(self._statueId, self._statueType)
	end	
end

function i3k_entity_net:OnMaxHpChangedCheck() --无用
end

function i3k_entity_net:OnPropUpdated(id, value)
	BASEENTITY.OnPropUpdated(self, id, value);

	if id == ePropID_speed then
		-- 速度变化后更新寻路数据
		if self:GetEntityType() == eET_Player and (self._iscarOwner == 1 and value <= g_i3k_game_context:GetEscortCarSpeed() or g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId) then
			self:Play(i3k_db_common.engine.roleWalkAction, -1);
		end
		if self._entity then
			self._entity:SetActionSpeed(i3k_db_common.engine.defaultRunAction, value / self._cfg.speed);
		end
	elseif id == ePropID_hp then

		if self._entity and self:GetTitleShow() then
			if g_i3k_game_context:GetBossBloodNeedUpdate() and self:GetEntityType() == eET_Monster then

			else
				self:UpdateBloodBar(value / self:GetPropertyValue(ePropID_maxHP));
			end
		end
		if self:GetEntityType() == eET_Player then
			local world = i3k_game_get_world()
			if world then
				world:CheckCustomRoles(self:GetGuidID())
			end
		end
		local logic = i3k_game_get_logic();
		local selEntity = logic._selectEntity;
		if selEntity then
			if selEntity._guid == self._guid then
				if g_i3k_game_context:GetBossBloodNeedUpdate() and self:GetEntityType() == eET_Monster then

				else
					g_i3k_game_context:OnTargetHpChangedHandler(value, self:GetPropertyValue(ePropID_maxHP))
				end
			end
		end
	elseif id == ePropID_maxHP then
		if self._entity then
			if self:GetTitleShow() then
				if value then
					self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / value);
				else
					self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP));
				end
			end
			if self:GetEntityType() == eET_Player then
				local world = i3k_game_get_world()
				if world then
					world:CheckCustomRoles(self:GetGuidID())
				end
			end
			local logic = i3k_game_get_logic();
			if logic then
				local selEntity = logic._selectEntity;
				if selEntity then
					if selEntity._guid == self._guid then
						g_i3k_game_context:OnTargetHpChangedHandler(self:GetPropertyValue(ePropID_hp), self:GetPropertyValue(ePropID_maxHP))
					end
				end
			end
		end
	end
end

function i3k_entity_net:GetHoster()

end

function i3k_entity_net:IsDead()
	return self._isDead;
end

function i3k_entity_net:AddBuff(attacker, buff) --部分继承重写
	if buff then
		local res, overlays = buff:Bind(attacker, self);
		if res then
			self._buffs[buff._id]		= buff;
			self._buffInsts[buff._guid] = true;
			self:OnBuffChanged(self);
			return true;
		elseif overlays then
			self:OnBuffChanged(self);
			return true;
		end
	end
	return false;
end

function i3k_entity_net:RmvBuff(buff) --部分继承重写
	if buff then
		buff:Unbind();
		self._buffs[buff._id]		= nil;
		self._buffInsts[buff._guid] = nil;
		self:OnBuffChanged(self);
	end
end

--[[function i3k_entity_net:AttachEquip(eid) --部分继承重写
	local E = require("logic/battle/i3k_equip");
	local equip = E.i3k_equip.new();
	if equip:Create(self, eid, self._gender) then
		equip.equipId = eid
		if self:HasEquip(equip._partID) then
			self:DetachEquip(equip._partID, true);
		end
		self._equips[equip._partID] = equip;
		if equip._skin.valid then
			
			local isshow = self:IsFashionShow()
			if isshow then
				isshow = false
				for k,v in pairs(self._Usefashion) do
					if v.dressInfo[equip._partID] then
						isshow = true;
						break;
					end
				end
			end

			if not isshow then
				self:ReleaseFashion(self._fashion, equip._partID);
			if self:GetEntityType() == eET_Player and equip._partID == eEquipWeapon and self:GetIsBeingHomeLandEquip() then
					return
				end
			if self:GetEntityType() == eET_Player then
				if (equip._partID ~= eEquipFlying and equip._partID ~= eEquipWeapon) or (equip._partID == eEquipWeapon and self._soaringDisplay.weaponDisplay == g_WEAPON_SHOW_TYPE) then
				for k, v in ipairs(equip._skin.skins) do
					self._entity:AttachHosterSkin(v.path, v.name);
				end
			end
			else
				for k, v in ipairs(equip._skin.skins) do
					self._entity:AttachHosterSkin(v.path, v.name);
		end
	end
			--end

		elseif equip._model.valid then
			if self:GetEntityType() == eET_Player and equip._partID == eEquipFlying and self:GetIsBeingHomeLandEquip() then
				return
					end
			self:AttachFlyingWeapon(equip._model.models)
				end
	end
end--]]

--[[function i3k_entity_net:DetachEquip(partID, isForce) --部分继承重写
	local equip = self._equips[partID];
	if equip and equip._skin.valid then
		for k, v in ipairs(equip._skin.skins) do
			self._entity:DetachHosterSkin(v.name)
		end
		if isForce then
			equip:Release();
			self._equips[partID] = nil;
		end
	else
		self:ReleaseFashion(self._fashion, partID)
	end
end--]]

--[[function i3k_entity_net:changeSpecialWeap()
	self:changeWeaponShowType()
	self:CreateFashion(self._fashion, eEquipWeapon)
	for k, v in pairs(self._equips) do
		if v and v.equipId then
			self:AttachEquip(v.equipId, true);
		end
	end
	self:AttachEquipEffect()
	local fashions = self._Usefashion
	local isShowWeap = self._fashionWeapShow
	if fashions[g_FashionType_Weapon] then
		self:AttachFashion(fashions[g_FashionType_Weapon].id, isShowWeap, g_FashionType_Weapon);
	end
	if not isShowWeap then
		if self._heirloom and self._soaringDisplay.weaponDisplay == g_HEIRHOOM_SHOW_TYPE then
			local scfg = i3k_db_skins[g_i3k_game_context:getHeirloomSkinID(self._id)];
			if scfg then
				self:ReleaseFashion(self._fashion, eEquipWeapon)
				if self._equips[eEquipWeapon] then
					for k, v in ipairs(self._equips[eEquipWeapon]._skin.skins) do
						self._entity:DetachHosterSkin(v.name);
					end
				end
				local name = string.format("hero_skin_%s_%d", self._guid, 1);
				self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
				self:AttachSkinEffect(eFashion_Weapon,scfg.effectID)
			end
		end
	end
end--]]

--[[--隐藏普通武器，时装，传家宝，飞升装备
function i3k_entity_net:HidePlayerEquipPos()
	local fashions = self._Usefashion
	if fashions and fashions[g_FashionType_Weapon] then
		self:SetFashionVisiable(false, g_FashionType_Weapon, true);
	end
	if self._heirloom then
		local scfg = i3k_db_skins[g_i3k_game_context:getHeirloomSkinID(self._id)];
		if scfg then
			local name = string.format("hero_skin_%s_%d", self._guid, 1);
			self._entity:DetachHosterSkin(name);
		end
	end
	self:ChangeFashionPre(eEquipWeapon)
	self:DetachFlyingEquip()
	self:ClearEquipEffect()
	--self:DetachEquip(eEquipWeapon, true);
	--self:ReleaseFashion(self._fashion, eEquipWeapon);
end--]]

function i3k_entity_net:OnDead(killerId) --部分继承
	if self:IsDead() then
		return false;
	end

	if not self:CheckDead() then
		return;
	end

	if self:GetEntityType() == eET_Monster then
		if killerId then
			if self._isPop then
				g_i3k_ui_mgr:CloseUI(eUIID_MonsterPop)
			end
			local hero = i3k_game_get_player_hero()
			local heroGuid = string.split(hero._guid, "|")
			heroGuid = tonumber(heroGuid[2])
			local prop = self._pop.deathPopProp*10;
			local num = math.random(0, 10)
			num = num==0 and 1 or math.ceil(num)
			if killerId==heroGuid  and num<=prop  then
				self:MonsterPopText(self._pop.deathPopText);
			end
		end

		if self._selected then
			local logic = i3k_game_get_logic();
			if logic then
				logic:SwitchSelectEntity(nil);
			end
		end
	end

	if self:GetEntityType() == eET_Player then
		self:CheckMissionRide(false);
	elseif self:GetEntityType() == eET_Mercenary then
		self:DetachPetGuard()
	end

	self:SetDeadState(true)
	self._hp		= 0;
	self._sp		= 0;
	self._internalInjuryState.value = 0

	self:OnDeadClsBuffs();
	self:ClsAttackers();
	self:DetachChessFlag();
	return true;
end

function i3k_entity_net:MonsterPopText(popTextId, isAlterend)
	if not g_i3k_ui_mgr:GetUI(eUIID_MonsterPop) and self:IsResCreated() then
		local textIndex = math.random(#i3k_db_dialogue[popTextId])
		g_i3k_ui_mgr:OpenUI(eUIID_MonsterPop)
		if isAlterend then
			g_i3k_ui_mgr:RefreshUI(eUIID_MonsterPop, i3k_db_dialogue[popTextId][textIndex].txt, self, isAlterend)
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_MonsterPop, i3k_db_dialogue[popTextId][textIndex].txt, self)
		end
	end
end

function i3k_entity_net:SyncDead(killer, timeTick, isPlay)
	self:PushCmd({
		id = eCmd_Dead,
		func = function()
			self:OnDeadState(killer, isPlay);
			--BASE.SyncDead(self, killer, timeTick);
		end
	});
end

function i3k_entity_net:UpdateHP(curHP)
	BASE.UpdateHP(self, curHP);
end

function i3k_entity_net:OnRevive(pos, sp) --部分继承重写
	if pos then
		self:SetPos(pos);
		self:ClearMoveState();
	end

	self:PushCmd({
	id = eCmd_Revive,
	func = function()
		self._revived       = true;
		self._state			= eState_Revive;
		self._timeTick		= 0;
		self._reviveSP	= sp;

		if self:GetEntityType() == eET_Player then
			self:CheckMissionRide(true);
		end
		self:SetDeadState(false)

		self:ShowTitleNode(true);

		local alist = {}
		if i3k_db_common.rolerevive.action ~= "" then
            table.insert(alist, {actionName = i3k_db_common.rolerevive.action, actloopTimes = 1})
            table.insert(alist, {actionName = i3k_db_common.engine.defaultAttackIdleAction, actloopTimes = -1})
			self:PlayActionList(alist, 1);
		end
		if self:GetEntityType() == eET_Mercenary or self._entity._inPetLife then
			self:PlayReviveEffect(i3k_db_common.rolerevive.effID);
			if self:GetCurPetGuardId() then
				self:AttachPetGuard(self:GetCurPetGuardId())
			end
		end
		if self:IsPlayer() then
			local logic = i3k_game_get_logic()
			self:AttachCamera(logic:GetMainCamera())
			self._entity._cameraentity = nil;
		end



		if self._reviveHP then
			self:UpdateHP(self._reviveHP);
		else
			self:UpdateHP(self:GetPropertyValue(ePropID_maxHP));
		end

		if self._reviveSP then
			self:UpdateProperty(ePropID_sp, 1, self._reviveSP, false, false);
		else
			self:UpdateProperty(ePropID_sp, 1, 0, false, false);
		end
		self._reviveHP = nil;
		end
});
end

function i3k_entity_net:OnSpa()
	if self:GetEntityType() == eET_Monster then
        local alist = {}
        table.insert(alist, {actionName = i3k_db_common.engine.defaultHurtAction, actloopTimes = 1})
        table.insert(alist, {actionName = i3k_db_common.engine.defaultAttackIdleAction, actloopTimes = -1})
		self:PlayActionList(alist, 1);
	end
end

function i3k_entity_net:OnDamage(attacker, atr, val, cri, stype, showInfo, update, SourceType, direct, buffid, armor, isCombo, godStarSplite, godStarDefend)  --部分继承重写
	local hero = i3k_game_get_player_hero()
	if self:GetEntityType()==eET_Monster and not self._isAttacked and attacker._guid and attacker._guid == hero._guid then
		self._isAttacked = true
		local prop = self._pop.startPopProp*10;
		local num = math.random(0, 10)
		num = num==0 and 1 or math.ceil(num)
		if num<=prop then
			self:MonsterPopText(self._pop.startPopText);
			self._isPop = true
		end
	end
	if not self._hp then return; end

	if attacker and attacker._guid ~= self._guid and stype ~= eSE_Buff then
		self:ClsBuffByBehavior(eEBSleep);
	end

	local _direct = false;
	if direct then
		_direct = direct;
	end

	local _info = false;
	if showInfo ~= nil then
		_info = showInfo;
	end

	local dv = val;
	if dv ~= 0 then
		local hp = self._hp;
		if dv > 0 then
			if _info then
				if stype == eSE_Damage then
					hp = hp - dv;
					if self:IsPlayer() or attacker:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Summoned or self:GetEntityType() == eET_Skill) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or ((attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Summoned or attacker:GetEntityType() == eET_Skill) and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or g_i3k_game_context:IsTeamMember(attacker:GetGuidID()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 or not _direct then
						local armorDamage = ""
						if armor and armor.damage>0 then
							self:UpdateArmorValue(self._armorState.value - armor.damage)
							armorDamage = string.format("(%s)", armor.damage)
							if armor.suck~=0 then
								self:PlayHitEffect(i3k_db_under_wear_alone.underWearAbsorbEffect)
							end
							if armor.destroy~=0 then
								self:PlayHitEffect(i3k_db_under_wear_alone.underWearDamagedEffect)
							end
						end
						if self:IsHideDamage() then
							local godStarDesc = "" --神斗技能 冒字
							if godStarDefend then
								godStarDesc = godStarDesc .. " " .. i3k_get_string(1712)
							end
							if godStarSplite then
								godStarDesc = godStarDesc .. " " .. i3k_get_string(1713)
							end
							if cri then
								self:ShowInfo(attacker, eEffectID_DamageCri.style, eEffectID_DamageCri.txt .. ' - ' .. dv .. armorDamage .. godStarDesc, nil, SourceType);
							elseif atr == 2 then
								self:ShowInfo(attacker, eEffectID_DodgeEx.style, eEffectID_DodgeEx.txt .. ' - ' .. dv .. armorDamage .. godStarDesc, nil, SourceType);
							else
								self:ShowInfo(attacker, eEffectID_Damage.style, '- ' .. dv .. armorDamage .. godStarDesc, nil, SourceType);
							end
						end
					end
				elseif stype == eSE_Buff then
					hp = hp + dv;
					if self:IsPlayer() or attacker:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill or self:GetEntityType() == eET_Summoned) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or ((attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill or attacker:GetEntityType() == eET_Summoned) and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or g_i3k_game_context:IsTeamMember(attacker:GetGuidID()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
						if cri then
							self:ShowInfo(attacker, eEffectID_HealCri.style, eEffectID_HealCri.txt .. ' + ' .. dv, nil, SourceType);
						else
							self:ShowInfo(attacker, eEffectID_Heal.style, '+ ' .. dv, nil, SourceType);
						end
					end
				end
			end
		end

		local maxHP = self:GetPropertyValue(ePropID_maxHP);
		if hp < 0 then
			hp = 0;
		elseif hp > maxHP then
			hp = maxHP;
		end
		hp = i3k_integer(hp);

		if self._hp ~= hp or hp == 0 then
			self._hp = hp;
			self:OnPropUpdated(ePropID_hp, self._hp);
		end
	end
end

--屏蔽伤害冒字
function i3k_entity_net:IsHideDamage()
	if not self._id or not self._entityType or self._entityType ~= eET_Monster then return true end	
	return g_i3k_db.i3k_db_shield_hurt_title(self._id)
end

function i3k_entity_net:OnRush(skillid, dir, info, sender) --仅同步使用

	local attacker = self:CheckAttacker(skillid, self._attacker);
	if attacker then
		if self._behavior:Set(eEBRush) then
			attacker:StartRush(dir, info, sender);
		end
	else
		if info.endPos then
			self:SetPos(info.endPos);
		end
	end

	return false;
end

function i3k_entity_net:OnStopRush()
	self._rushInfo = nil;

	self._behavior:Clear(eEBRush);
end

function i3k_entity_net:UseRide(sid)
	local rcfg = i3k_db_steed_huanhua[sid];
	if rcfg then
		self._ride.curShowID	= sid
		self._ride.deform	= { args = rcfg.modelId, horseLinkPoint = rcfg.horseLinkPoint, memberOffSet = rcfg.memberOffSet};
		if self:IsOnRide() then
			self:OnRideMode(false);
		end
		self:OnRideMode(true);
	end
end

function i3k_entity_net:OnRideMode(enable)
	if i3k_db_common.debugswitch.rideopen ~= 0 then
		self._ride.cache.valid = enable;
		--i3k_log("OnRideMode1:"..self._guid)
		if self:IsResCreated() then
			if self._ride and self._ride.deform then
				--i3k_log("OnRideMode##########")
				self:FinishAttack();
				self:ResetMaunalAttack();
				self._curSkill = nil;
				self:ClsAttackers();
			
				if self:isRideSpecialShow() then
					self:ChangeRidePlayAction(g_HS_First, self:isRideSpecialShow())
				end
				self:ChangeCombatEffect(self._combatType)
				if enable then
					if not self._ride.valid then
						--i3k_log("OnRideMode1:ride"..self._guid)
						local rideEffectID = i3k_db_steed_common.rideEffectID
						if rideEffectID then
							self:PlayHitEffect(rideEffectID)
						end
						if not self._curWeaponSoulShow then
							self:DetachWeaponSoul()
						end
						self._ride.valid = true;
						local ismoveing = self._behavior:Test(eEBMove)
						if ismoveing then
							self:Play(i3k_db_common.engine.defaultRunAction, -1);
						else
							self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
						end
						local modelID = i3k_engine_check_is_use_stock_model(self._ride.deform.args)
						if modelID then
							local mcfg = i3k_db_models[modelID]
							local horseLinkPoint = self._ride.deform.horseLinkPoint
							local linkPoint = horseLinkPoint[1]
							if #horseLinkPoint > 1 then
								self._ride.onMulHorse = true
								self._mulHorse.isLeader = true
							end
							self:SetVehicleInfo(mcfg.path, linkPoint, i3k_db_steed_common.LinkRolePoint);
							self:Mount();
							if self._entity and self._title and self._title.node then
								self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
								self:DetachTitleSPR();
								self:AttachTitleSPR();
							end
						end
					end
				else
					if self._ride.valid then
						self:DetachWeaponSoul()
						self:AttachWeaponSoul(self._curWeaponSoulID)
						--i3k_log("OnRideMode1:unride"..self._guid)
						local unrideEffectID = i3k_db_steed_common.unrideEffectID
						if unrideEffectID then
							self:PlayHitEffect(unrideEffectID)
						end
						if self._rideSpecialSpr then
							self:ClearRidePlay()
						end
						self._ride.valid = false
						self._ride.onMulHorse = false
						self:Unmount();
						if self._entity and self._title and self._title.node and self._rescfg then
							self._entity:AddTitleNode(self._title.node:GetTitle(), self._rescfg.titleOffset);
							self:DetachTitleSPR();
							self:AttachTitleSPR();
						end
					end
				end
				self:UpdateSteedSpiritShow(enable)
			end
		end
	end
end

function i3k_entity_net:MissionMode(enable,id)
	if self._superMode.valid and enable then
		self:OnSuperMode(false);
	end
	
	--幻形变身特殊处理
	if enable and  self._missionMode.valid and self._missionMode.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS then		
		self:OnMissionMode(false)
	end
		
	if i3k_entity_net and not self._missionMode.valid and enable then
		self._missionMode = { cache = { valid = false }, valid = false,attrvalid = false  };
		self._missionMode.id = id;
		self._missionMode.valid	= true;
		local mcfg = i3k_db_missionmode_cfg[id]
		self._missionMode.type = mcfg.type
		self._missionMode.mcfg = mcfg
		if self._missionMode.type ~= 2 then
			self._missionMode.deform = mcfg.modelId
		elseif self._missionMode.type == 2 then
			local gender = self._gender
			local wcfg = i3k_db_shen_bing[mcfg.modelId];
			if gender == 1 then
				self._missionMode.deform	= wcfg.changeArgs
			else
				self._missionMode.deform	= wcfg.changeArgsF
			end
		end
	else

	end
	self:OnMissionMode(enable);
end

function i3k_entity_net:OnMissionMode(enable)
	self._missionMode.cache.valid = enable;

	if self:IsResCreated() or (self._changemodel and not enable) then
		self:FinishAttack();
		self:ResetMaunalAttack();
		self._curSkill = nil;
		self._target = nil;
		self:ClsAttackers();
		self:ChangeCombatEffect(self._combatType)
        if not self:IsDead() then
            local ismoveing = self._behavior:Test(eEBMove)
            if ismoveing then
                self:Play(i3k_db_common.engine.defaultRunAction, -1);
            else
                self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
            end
        end
		self._missionMode.attacksIdx = 0;
		local missionTypeTable = {
			[g_TASK_TRANSFORM_STATE_PEOPLE]			 = true,
			[g_TASK_TRANSFORM_STATE_SUPER]			 = true,
			[g_TASK_TRANSFORM_STATE_SKULL]			 = true,
			[g_TASK_TRANSFORM_STATE_METAMORPHOSIS]	 = true,
			[g_TASK_TRANSFORM_STATE_CHESS] 			 = true,
			[g_TASK_TRANSFORM_STATE_CAR] 			 = true,
			[g_TASK_TRANSFORM_STATE_SPY]			 = true,
		}
		local missionType =  self._missionMode.type
		if  missionTypeTable[missionType] then
			if enable then
				self:ClearEquipEffect()
				self._missionMode.valid = true;
				self._changemodel = true;
				self:ChangeModelFacade(self._missionMode.deform);
				if missionType == g_TASK_TRANSFORM_STATE_SKULL then
					self:PlaySkullReviveEffect(i3k_db_desert_battle_base.reviveEffectID)
				end
				if missionType ==  g_TASK_TRANSFORM_STATE_CHESS then
					self:SetChuhanTitle()
				end
				self:ClearCombatEffect()
			else
				self._changemodel = false;
				self:DetachChessFlag()
				if self._equipinfo then
					self:AttachEquipEffect(self._equipinfo);
				end
				self._missionMode.valid = false
				self:RestoreModelFacade();
			end
		elseif missionType == g_TASK_TRANSFORM_STATE_ANIMAL then
			if enable then
				self._missionMode.valid = true;
				local modelID = i3k_engine_check_is_use_stock_model(self._missionMode.deform)
				if modelID then
					local mcfg = i3k_db_models[modelID]
					self:SetVehicleInfo(mcfg.path, i3k_db_steed_common.LinkPoint, i3k_db_steed_common.LinkRolePoint);
					self:Mount();
					if self._entity and self._title and self._title.node then
						self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
					end
					local rideEffectID = i3k_db_steed_common.rideEffectID
					if rideEffectID then
						self:PlayHitEffect(rideEffectID)
					end
					self:ClearCombatEffect()
				end
			else
				self._missionMode.valid = false;
				self:Unmount();
				if self._entity and self._title and self._title.node and self._rescfg then
					self._entity:AddTitleNode(self._title.node:GetTitle(), self._rescfg.titleOffset);
				end
				local unrideEffectID = i3k_db_steed_common.unrideEffectID
				if unrideEffectID then
					self:PlayHitEffect(unrideEffectID)
				end

			end
		elseif missionType == g_TASK_TRANSFORM_STATE_CARRY then
			if enable then
				self._missionMode.valid = true;
				local deform = self._missionMode.deform
				local modelID = deform ~= -1 and i3k_engine_check_is_use_stock_model(deform) or deform
				if modelID then
					self:CarryItem(modelID);
				end
				self:ClearCombatEffect()
			else
				self._missionMode.valid = false;
				self:UnCarryItem();
			end
		end
		if self._missionMode and self._missionMode.type then
			if enable then
				self:DetachFlyingEquip()
				self:DetachWeaponSoul()
				self:ClearCombatEffect()
			else
				self:AttachWeaponSoul(self._curWeaponSoulID)
			end
		end
	end
end

--楚汉
function i3k_entity_net:AttachChessFlag(forceArm)
	self._forceArm = forceArm
	if not self._curChessFlag then
		local id = g_i3k_db.i3k_db_chess_get_props_for_model(self._forceType, forceArm)
		if not id then return end
		local martialFlag = i3k_db_chess_generals[id];
		if martialFlag then
			local modelID = i3k_engine_check_is_use_stock_model(martialFlag.modelID);
			if modelID and self._entity then
				local cfg = i3k_db_models[modelID]
				if cfg then
					local Link = i3k_db_martial_soul_cfg;
					local hosterLink = i3k_db_tournament_base.chess_base.hosterLink
					local effectID = 0;
					if cfg.path then
						effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_chess_%s_effect_%d", self._guid, 1), hosterLink, "", 0.0, cfg.scale);
					end
					self._curChessFlag = effectID;
					self._entity:LinkChildSelectAction(effectID, i3k_db_common.engine.defaultStandAction)
					self._entity:LinkChildPlay(effectID, -1, true);
					self._entity:LinkChildShow(effectID, true)
				end
			end
		end
	end
end


function i3k_entity_net:OnAsyncLoaded()
	BASE.OnAsyncLoaded(self);

	if not self._isReplaceCar and self._carState ~= 0 then
		self:UpdateCarState(self._carState);
	end
end

function i3k_entity_net:UpdateCarState(state)
	self._carState = state;
	if self:IsResCreated() then
		if self._carState ~= 0 then
			self:ChangeModelFacade(self._cfg.damage_model)
			self._isReplaceCar = true
		end
	end
end

function i3k_entity_net:Cacheable()
	return true;
end

function i3k_entity_net:ResetLeaveCache()
	self._inLeaveCache = false;
	self._cacheClearTime = 0;
end

function i3k_entity_net:EnterLeaveCache()
	if not self._inLeaveCache then
		self._inLeaveCache = true;
		self._cacheClearTime = 0;
	end
end

function i3k_entity_net:StopAttack(skill, result, attackSuc)
	local sid = skill._id;

	local rid = -1;
	if self._attacker then
		for k, v in ipairs(self._attacker) do
			if v._skill._id == sid then
				rid = k;
				v:Release(false);
				break;
			end
		end

		if rid ~= -1 then
			table.remove(self._attacker, rid);
		end
	end
end

function i3k_entity_net:UpdateArmorValue(curArmor, maxArmor)
	if  self:GetEntityType() == eET_Monster and self._id then
		self._armorState.value = curArmor;
		if maxArmor then
			self._armorState.maxArmor = maxArmor;
		end
		g_i3k_game_context:OnBossArmorValueChangedHandler(self._id, curArmor, self._armorState.maxArmor)
	end
end

--武魂相关
function i3k_entity_net:isAttachWeaponSoul()
	local world = i3k_game_get_world()
	if world and self:GetEntityType() == eET_Player then
		if self._superMode.valid or self._missionMode.valid then
			return false;
		end
		local mapType = i3k_game_get_map_type()
		local mapTb = {
			[g_FORCE_WAR]	= true,
			[g_DEMON_HOLE] 	= true,
			[g_FACTION_WAR] = true,
			[g_Life]  		= true,
			[g_DEFENCE_WAR] = true,
			[g_PET_ACTIVITY_DUNGEON] = true,
			[g_DESERT_BATTLE] = true,
			[g_MAZE_BATTLE] = true,
			[g_SPY_STORY]  = true,
			[g_BIOGIAPHY_CAREER] = true,
		}
		if self:isSpecial() or mapTb[mapType] then
			return false;
		end
		return self._curWeaponSoulShow;
	end
	return false;
end

function i3k_entity_net:AttachWeaponSoul(showID)
	if self:isAttachWeaponSoul() then
		local martialSoul = i3k_db_martial_soul_display[showID];
		if martialSoul then
			local modelID = i3k_engine_check_is_use_stock_model(martialSoul.modelID);
			if modelID then
				local cfg = i3k_db_models[modelID]
				if cfg and self._entity then
					local Link = i3k_db_martial_soul_cfg;
					local hosterLink = Link.hosterLink[self._id];
					local effectID = 0;
					if cfg.path then
						effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_net_soul_%s_effect_%d", self._guid, martialSoul.diaplayType), hosterLink, Link.sprLink, 0.0, cfg.scale);
					end
					self._curWeaponSoul = effectID;
					self._curWeaponSoulID = showID;
					self._entity:LinkChildSelectAction(effectID, i3k_db_common.engine.defaultStandAction)
					self._entity:LinkChildPlay(effectID, -1, true);
					self._entity:LinkChildShow(effectID, true)
				end
			end
		end
	end
end

function i3k_entity_net:SetWeaponSoulShow(isShow)
	self._curWeaponSoulShow = isShow
end
function i3k_entity_net:SetCombatType(cType)
	if self._combatType ~= cType then
		self._combatType = cType
		self:ChangeCombatEffect(self._combatType)
		if self:CanPlayCombatTypeAction() and self._state == eState_Idle then
			self:PlayCombatAction(self._combatType)
		end
	end
end

-- 钓鱼状态
function i3k_entity_net:SetFishStatus(status)
	self._fishStatus = status
end

-- 是否在钓鱼状态
function i3k_entity_net:IsInFishStatus()
	return self._fishStatus == 1
end

function i3k_entity_net:LinkHomeLandFishEquip()
	if self:IsInFishStatus() and self._curHomeLandEquips then
		local guid = string.split(self._guid, "|")
		local roelID = tonumber(guid[2])
		self:LinkHomeLandFishModel(self._curHomeLandEquips, roelID)
	end
end

---------荣耀殿堂相关-----------
function i3k_entity_net:SetStatuTag(id, kind)
	self._statueId = id
	self._statueType = kind
end

function i3k_entity_net:GetShareHp()
	return self._sharetHp
end

function i3k_entity_net:SetShareHp(value)
	self._sharetHp = value
end
------------------------------------以下为网络无用函数 屏蔽继承hero
function i3k_entity_net:AddChild(child, spawn_eff)
end

function i3k_entity_net:GetSpecialChild(sid)
end

function i3k_entity_net:ClsChilds()
end

function i3k_entity_net:MaunalAttack(id)
end

function i3k_entity_net:SuperMode(enable)
end

function i3k_entity_net:ClsEnmities()
end

function i3k_entity_net:GetEnmities()
end

function i3k_entity_net:ClearFightTime()
end

function i3k_entity_net:GetFightTime()
end

function i3k_entity_net:OnFightTime(dTime, add)
end

function i3k_entity_net:GetDigStatus()
end

function i3k_entity_net:SetDigStatus(status)
end

function i3k_entity_net:CheckDigStatus()
end

function i3k_entity_net:DigMineCancel()
end

function i3k_entity_net:PlayerDigMineStart()
end

function i3k_entity_net:ProcessDamage(skill, target, sdata,ticknum)
end

function i3k_entity_net:ProcessBuffDamage(attacker, buffid, eType, eCountType, eValue)
end

function i3k_entity_net:Appraise()
end

function i3k_entity_net:AppraiseSkill()
end

function i3k_entity_net:UpdateFightSp(curFightSP,byBuff)
end

function i3k_entity_net:CreateFightSpCanYing(id,num,level,RoleID,Pos)
end

function i3k_entity_net:UpdateFightSpCanYing(curFightSP,byBuff)
end

function i3k_entity_net:AddAutofightTriggerSkill()
end

function i3k_entity_net:ClearAutofightTriggerSkill()
end

function i3k_entity_net:GetSkillCoolLeftTime(id) --修改后无用
end

function i3k_entity_net:GetDodgeSkillCoolLeftTime() --修改后无用
end

function i3k_entity_net:GetDIYSkillCoolLeftTime() --修改后无用
end

function i3k_entity_net:IsAutoFight()
end

function i3k_entity_net:SetAutoFight(auto)
end

function i3k_entity_net:DesEquipDurability(partID, Durability)
end

function i3k_entity_net:UpdateEquipProps(props)
end

function i3k_entity_net:UpdateTalentProps(props, updateEffector)
end

function i3k_entity_net:UpdateFashionProps(props)
end

function i3k_entity_net:UpdateFightSPProps(props)
end

function i3k_entity_net:UpdateWeaponProps(props)
end

function i3k_entity_net:UpdateSuitProps(props)
end

function i3k_entity_net:UpdateRewardProps(props)
end

function i3k_entity_net:UpdateCollectionProps(props)
end

function i3k_entity_net:UpdateFactionSkillProps(props)
end

function i3k_entity_net:UpdateProfessionProps(props)
end

function i3k_entity_net:UpdateTitleProps(props)
end

function i3k_entity_net:UpdateTalentEffector(props)
end

function i3k_entity_net:UpdateLongyinProps(props)
end

function i3k_entity_net:UpdateLiLianProps(props)
end

function i3k_entity_net:ClearMissionattr()
end

function i3k_entity_net:UpdateMissionModeProps(props)
end

function i3k_entity_net:UpdateMercenaryAchievementProps(props)
end

function i3k_entity_net:UpdateMercenaryRelationProps(props)
end

function i3k_entity_net:AddTalent(id, lvl)
end

function i3k_entity_net:RmvTalent(talent)
end

function i3k_entity_net:ClsTalents()
end

function i3k_entity_net:AddEnmity(entity, force)
end

function i3k_entity_net:RmvEnmity(entity)
end

function i3k_entity_net:UpdateEnmities()
end

function i3k_entity_net:ResetDamageRetrive()
end

function i3k_entity_net:ResetDamageDes()
end

function i3k_entity_net:UpdateDamageDes(factor)
end

function i3k_entity_net:GetDamageDes()
end

function i3k_entity_net:UpdateDamageRetrive(all, dmg, cir, value)
end

function i3k_entity_net:GetDamageRetrive(dmg, cir)
end

function i3k_entity_net:UpdateExtProperty(props)
end

function i3k_entity_net:UpdateAlives()
end

function i3k_entity_net:TestRelative(entity)
end


function i3k_entity_net:AddAura(skill, auraInfo)
end

function i3k_entity_net:GetPVPStatus()
end

function i3k_entity_net:SetPVPStatus(mode)
end

function i3k_entity_net:SetPlayer(player)
end

function i3k_entity_net:UpdateProperties()
end

function i3k_entity_net:InitSkills(resetBinds)
end

function i3k_entity_net:LoadDIYSkill(CurrentSkillID, KungfuData)
end

function i3k_entity_net:normalizeDIYcfg(cfg,CurrentSkillID, KungfuData)
end

function i3k_entity_net:InitPlayerAttackList()
end

function i3k_entity_net:BindSkills(skills)
end

function i3k_entity_net:BindSkill(skill, slot)
end

function i3k_entity_net:OnSkillUpgradeLvl(sid, lvl)
end

function i3k_entity_net:OnSkillUpgradeRealm(sid, realm)
end

function i3k_entity_net:GetAttackSkill()
end

function i3k_entity_net:DodgeSkill()
end

function i3k_entity_net:DIYSkill()
end

function i3k_entity_net:OnRandomResetSkill()
end

function i3k_entity_net:OnDesSkillCoolTime(skillID, coolTime)
end

function i3k_entity_net:OnNetworkResetSkill(skillID)
end

function i3k_entity_net:OnNetworkDesSkillCoolTime(skillID, coolTime)
end

function i3k_entity_net:OnEnableDodgeSkill(value)
end
function i3k_entity_net:AttachEquipEffect(equipInfo)
	local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	if self._superMode.cache.valid or weaponDisplay == g_FLYING_SHOW_TYPE then
		return
	end
	local wequips = self._equipinfo
	if equipInfo then
		wequips = equipInfo
	end
	if wequips then
		for k, v in pairs(wequips) do
			local equipId = self._equips[k] and self._equips[k].equipId or nil
			local effectids = equipId and g_i3k_db.i3k_db_get_equip_effect_id_show(equipId, self._id, k, v.eqGrowLvl, v.eqEvoLvl, v.effectInfo) or nil
			if effectids then
				self:AttachEquipEffectByPartID(k, effectids)
			else
				self:DetachEquipEffectByPartID(k)
			end
		end
	end
end

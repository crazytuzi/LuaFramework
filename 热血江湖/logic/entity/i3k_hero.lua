------------------------------------------------------
module(..., package.seeall)

local require = require

--local BASE =
--	require("logic/entity/i3k_entity").i3k_entity;
require("logic/entity/i3k_entity");
local BASE = i3k_entity;
require("logic/entity/i3k_hero_def");
require("logic/i3k_horse_special_args");


------------------------------------------------------
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
	[ 4] = function(tbl) -- 过滤优先级
		local _cmp = function(d1, d2)
			return d1.entity._filterorder > d2.entity._filterorder;
		end
		table.sort(tbl, _cmp);
	end,
	[ 5] = function(tbl) -- 技能优先级
		local _cmp = function(d1, d2)
			return d1.order < d2.order
		end
		table.sort(tbl, _cmp);
	end,
	[ 6] = function(tbl) -- 主线怪, 要求必须是稳定排序
		local _cmp = function(d1, d2)
			local mId, mValue = g_i3k_game_context:getMainTaskIdAndVlaue();
			local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId);
			local arg1 = main_task_cfg.arg1;

			local r1 = d1.dist
			local r2 = d2.dist
			local p = -100000
			if (d1.entity:GetEntityType() == eET_Monster) and (arg1 == d1.entity._id) then
				r1 = r1 + p
			end
			if (d2.entity:GetEntityType() == eET_Monster) and (arg1 == d2.entity._id) then
				r2 = r2 + p
			end

			return r1 < r2

			-- if (d1.entity:GetEntityType() == eET_Monster) and (arg1 == d1.entity._id) then
			-- 	if (d2.entity:GetEntityType() == eET_Monster) and (arg1 == d2.entity._id) then
			-- 		return d1.dist < d2.dist; -- 两个都是主线怪
			-- 	else
			-- 		return true; -- 第二个不是主线怪，那么返回true
			-- 	end
			-- elseif (d2.entity:GetEntityType() == eET_Monster) and (arg1 == d2.entity._id) then
			-- 	return false;
			-- else
			-- 	return d1.dist < d2.dist;
			-- end
			--
			-- return false
		end
		table.sort(tbl, _cmp);
	end,
	[ 7] = function(tbl) -- boss怪
		local _cmp = function(d1, d2)

			if (d1.entity:GetEntityType() == eET_Monster) and d1.entity._isBoss then
				if (d2.entity:GetEntityType() == eET_Monster) and d2.entity._isBoss then
					if d1.dist ~=  d2.dist then
						return d1.dist < d2.dist;
					end
				else
					return true;
				end
			elseif (d2.entity:GetEntityType() == eET_Monster) and d2.entity._isBoss then
				return false;
			else
				if d1.dist ~=  d2.dist then
					return d1.dist < d2.dist;
				end
			end

			return false;
		end
		table.sort(tbl, _cmp);
	end,
	[ 8] = function(tbl) -- 周围玩家
		local _cmp = function(d1, d2)

			if d1.entity:GetEntityType() == eET_Player then
				if d2.entity:GetEntityType() == eET_Player then
					if d1.dist ~=  d2.dist then
						return d1.dist < d2.dist;
					end
				else
					return true;
				end
			elseif d2.entity:GetEntityType() == eET_Player then
				return false;
			else
				if d1.dist ~=  d2.dist then
					return d1.dist < d2.dist;
				end
			end

			return false;
		end
		table.sort(tbl, _cmp);
	end,
};

--拳师姿态动作
local boxerActionList = 
{
	[g_BOXER_NORMAL] = i3k_db_common.engine.defaultAttackIdleAction,
	[g_BOXER_ATTACK] = i3k_db_common.general.boxerAttackAction,
	[g_BOXER_DEFENCE] = i3k_db_common.general.boxerDefenceAction,
};
local boxerEffectList = 
{
	[g_BOXER_ATTACK] = i3k_db_common.general.boxerAttackEffect,
	[g_BOXER_DEFENCE] = i3k_db_common.general.boxerDefenceEffect,
}
------------------------------------------------------
i3k_hero = i3k_class("i3k_hero", BASE);
function i3k_hero:ctor(guid, player)
	self._cfg		= nil;
	self._player	= player or false;
	self._auras		= { };
	self._buffs		= { };
	self._buffInsts	= { };
	self._talents	= { };
	self._curSkill	= nil;
	self._useSkill	= nil;
	self._maunalSkill
					= nil;
	self._attacks	= { }; -- 普通攻击
	self._attackIdx	= 1; -- 普通攻击索引
	self._hp		= 0;
	self._sp		= 0;
	self._ReduceCd		= 0;

	self._skills	= { }; -- 主动技能
	self._ultraSkill= nil;
	self._uniqueSkill= nil;
	self._dodgeSkill= nil;
	self._DIYSkill	= nil;
	self._spiritSkill = nil --驻地精灵技能
	self._anqiAllActiveSkills = {}
	self._anqiSkill	= nil;
	self._weaponManualSkill = nil -- 神兵类型19手动特技
	self._talentChangeSkill = {}
	self._talentChangeAi = {}
	self._horseChangeSkill = {}

	self._itemSkills	= {};
	self._gameInstanceSkills = {};
	self._gameInstanceSkillId = -1;
	self._tournamentSkills = {};
	self._tournamentSkillID = -1;

	self._attackID	= -1; -- 攻击序列索引
	self._attackLst = { }; -- 攻击序列
	self._isDead	= false;
	self._target	= nil;
	self._alives	= { { }, { }, { },};
	self._all_alives
					= { { }, { }, { } }; --友方 敌方 中立
	self._attacker	= { };
	self._entityType= eET_Player;
	self._equips	= { };
	self._childs	= { };
	self._DigStatus = 0;
	self._ReviveStatus = 0;
	self._superMode	= { cache = { valid = false }, valid = false, attacks = 1, ticks = 0 };
	self._weapon	= { valid = false };
	self._changeEName	= { };
	self._enmities	= { };
	self._damageRetrive = 1;
	self._damageDes = 0;
	self._damageAddition = 0;
	self._headiconID = 0;
	self._fightsptime = 0;
	self._PKvalue = -1;
	self._PVPStatus = 0;
	self._PVPColor = -2;
	self._PVPFlag = 0;
	self._DIYSkillID = 0;
	self._AutoFight = false;
	self._PreCommand = -1;
	self._preSkillItemId = nil;
	self._AutoFight_Point = {x = 0,y = 0 , z = 0}
	self._fightstatus = false
	self._autonormalattack = false
	self._preautonormalattack = false;
	self._ride = { cache = { valid = false }, valid = false, onMulHorse = false, rideSpeed = nil, ticks = 0};
	self._mulHorse = {leaderId = 0, isLeader = false, memberIDs = {}, members = {}, mulPos = 1}; --多人骑乘相关
	self._mulEntity = nil;
	self._rideFight = false; --正在使用的是否是骑战类坐骑皮肤
	self._rideCurSpiritShowID = 0
	self._rideCurSpiritShow = nil
	self._missionMode = { cache = { valid = false }, valid = false,attrvalid = false, endTime = 0};
	self._fighttime = 0
	self._filterorder = 0;
	self._updateFilterTime = 0
	self._cacheTargets = {}
	self._skilldeny = 0;
	self._Usefashion = {};
	self._TestfashionID = {};
	self._steedtids = { };
	self._weapontids = {};
	self._meridiansAi = {};
	self._equiptids = {}
	self._petTids = {}
	self._passivesTids = {} -- 被动
	self._fashionWeapShow = false;
	self._fashionsID = 0;
	self._fashionWeap = 0;
	self._missionShow = false;
	self._trapinit = true;
	self._EquipEffects = {};
	self._socialactionID = 0;
	self._cameraentity = nil;
	self._deadtriskill = {};
	self._timedTitles = {};
	self._inPetLife 	= false;
	self._inDesertBattle = false;
	self._inBiographyCareer = false
	self._inSpyStory = false;
	self._bwType = 0;
	self._forceType = 0;
	self._forceArm = 1 ; -- 楚汉兵种
	self._posId = 0;
	self._isfindway		= false;
	self._findWayTmpSpeed = nil
	self._iscarRobber   = 0;--是否是劫镖者
	self._iscarOwner	= 0;--是否是运镖者
	self._hitEffectIDs  = {};
	self._attackStack	= 0;
	self._attackTick	= 10;
	self._carEntityTab 	 = {}
	self._shenbinguniquetids = {} --神兵挂的ai触发公式
	self:CreateActor();
	-- 内甲相关
	self._armor = { id = 0, level = 0, stage = 0, rune = { {}, {}, {},}, talent = {}, restraintId = 0, restrainedId = 0, effectId = {}, hideEffect = 0 };
	self._armorState = { value = 0, maxArmor = 0, freeze = 0, weakEffectId = 0, recTicks = 0, freezeTicks = 0};
	-- 内伤相关
	self._internalInjuryState = {value = 0, maxInjury = 0}
	--神兵变身，任务变身状态下缓存时装改变数据，神兵变身结束时改变时装
	self._cacheFashionData = {valid = false, fashionID = {}, isShow = {}}
	self._cacheFashionVis = {valid = false, isShow = {}}
	self._hugMode = {valid = false, isLeader = false, leaderId = 0, member = nil, memberId = 0, isStarKiss = false, isStarKissTime = 0} --相依相偎
	self._unifyMode = {cache = {valid = false}, valid = false}
	self._autoOfflineTime = {deadTime = 0, dazuoTime = 0};--自动离线时间，死亡或打坐
	self._playSocialId	= 0;
	self._wizard 		= {};
	self._killerId		= 0;
	self._rideSpecialSpr = {};
	self._updateWeapTime = 0;
	self._lastWeapUseTime = 0;
	self._isUpdateWeap 	= true;
	self._isCanSpecialWean = true;
	self._isGuard		= false; --是否是渠道对抗赛的观战者，默认不是，服务器同步状态则设置
	self._updatePkTipTime = 0;
	self._isUpdatePkTip = false;
	self._isShowPkTip	= false;
	self._headBorder	= 0;
	self._blinkEndPos	= Engine.SVector3(0, 0, 0);
	self._isBlink		= false;
	self._invisibleEnd	= false;--隐身结束
    self._isInWater     = nil;
    self._isInLand      = nil;
	self._TearWoundA	= 0;
	self._TearWoundB	= 0;
	self._SpringFashion = {};
	self._springDoubleType = 0;
	self._isBlinkSkill	= false;--是否闪现
	self._curWeaponSoul = nil;
	self._isAttachedSoul = false;
	self._specialArg 	= 0; --暂时未怪物特殊名字使用
	self._titleSpr 		= 0;--动态称号SPR
	self._titleSprData	= nil;
	self._isHaveDynamic		= false;--是否拥有动态称号
	self._soulenergy = 0;
	self._soulenergyMaxValue = 0;
	self._allPorpReduceValue = 0 -- 全属性降低,单独记下来
	self._WeaponBlessAllPorpReduceValue = 0;--武器祝福全属性提升吗,单独记下来
	self._homeLandEquipSkinID = 0; --家园装备skinID
	self._areaType	= 0 --区域类型
	self._soaringDisplay = {} -- 武器外显和脚底特效
	self._curFlyingWeapon = {}
	self:InitWeaponBless()--武器祝福
	self._playActState = 0
	self._combatType = 0 --拳师姿态（0，平衡姿态，1，战斗姿态，2，防御姿态）
	self._combatTypeEffect = 0 --拳师姿态特效
	self._dynamicfindwayflag = false --寻路动态目标开关目的时间间隔
	self._catchSpiritSkills = {} --驭灵技能
	self._catchSpiritTrigger = {} --驭灵触发技能
	self._catchSpiritIndex = 1
	self._footEffect = -1
	--self._catchSpiritAttact = {} --驭灵技能序列
end

function i3k_hero:Create(id, name, gender, hair, face, lvl, skills, agent, updateProperty, fromType, BWType)
	local cfg = g_i3k_db.i3k_db_get_general(id);
	if not cfg then
		return false;
	end
	self._fashion = g_i3k_db.i3k_db_get_general_fashion(id, gender or eGENDER_MALE);
	if not self._fashion then
		return false;
	end
	self._fashionInfo
					= { };
	self._skineffectInfo		= { };
	self._gender	= gender or eGENDER_MALE
	if fromType and fromType ~= eBaseFrom then
		self._hair		= g_i3k_db.i3k_db_get_general_faction_head_res(self._fashion,fromType) or 0
	else
		self._hair = hair or 0
	end
	self._face		= face or 0;
	self._bwType	= BWType or 0;
	self._needUpdateProperty
					= updateProperty or false;

	return self:CreateFromCfg(id, name, cfg, lvl, skills, agent,fromType);
end

function i3k_hero:OnEnterWorld()
	BASE.OnEnterWorld(self)
	if self:IsPlayer() then
		self:ClearFightTime();
	end
	self._target = nil;
	self._forceAttackTarget = nil;
	self._alives = { { }, { }, { } };
	self:ClsEnmities();
end

function i3k_hero:OnEnterScene()
	BASE.OnEnterScene(self)
	if self:IsPlayer() then
		local mapType = g_i3k_game_context:GetWorldMapType()
		self._heroInWorld = false
		for i,v in pairs(i3k_db_common.autoFight.autoFightMap) do
			if v==mapType then
				self._heroInWorld = true
				break
			end
		end
		self._inWorldTime = i3k_game_get_time();
	end
end

function i3k_hero:GetPVPStatus()
	return self._PVPStatus;
end

function i3k_hero:SetPVPStatus(mode)--0:和平、1:自由、2:善恶、3:帮派
	self._PVPStatus = mode
	if self._isShowPkTip then
		self:ClearPkAttackedTip();
	end

	if mode == 0 then
		self._AutoFight_Point = {x = self._curPos.x,y = self._curPos.y,z = self._curPos.z};
	end

	if self:IsPlayer() then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateRolePKMode", mode)
	end
end

function i3k_hero:CreateFromCfg(id, name, cfg, lvl, skills, agent, fromType, isAwake) -- isAwake 宠物试炼和身世副本用
	self._lvl	= lvl;
	self._cfg	= cfg;
	self._cname	= cfg.name;
	self._name	= name;
	self._validSkills = skills;
	self._radius= cfg.radius;
	self._attacker
				= { };

	if agent then
		self:CreateAgent();
	end
	if self:GetEntityType()==eET_Monster then
		self._pop = {
			startPopProp = cfg.sPopProp,
			startPopText = cfg.sPopText,
			deathPopProp = cfg.dPopProp,
			deathPopText = cfg.dPopText,
		}
		self._isAttacked = false
		self._isPop = false
	end

	if self._fashion then
		self:CreateResWithFashion(self._fashion, fromType);
	elseif self:GetEntityType() == eET_Mercenary then
		local isAwaken =  g_i3k_game_context:getPetIsWaken(id);
		local isUseAwaken = g_i3k_game_context:getPetWakenUse(id);
		if isAwaken and isUseAwaken then
			self:CreateRes(i3k_db_mercenariea_waken_property[id].modelID);
		else
			self:CreateRes(self._cfg.modelID);
		end
	else
		if isAwake then --宠物试炼和身世副本 自己看自己觉醒
			self:CreateRes(i3k_db_mercenariea_waken_property[id].modelID);
		else
			self:CreateRes(self._cfg.modelID);
		end
	end

	local res = BASE.Create(self, id, name);
	if res then
		self:InitSkills(true);
	end

	self._hp = self:GetPropertyValue(ePropID_maxHP);
	self._sp = 0;
	self._fightsp = 0;
	self._ReduceCd = 0;
	self:TitleColorTest();

	if self:GetEntityType() == eET_Monster then
		if cfg.ArmorType and cfg.ArmorType ~= 0 then
			self:AttachArmor(cfg.ArmorType, nil, 1);
			self:UpdateArmorValue(cfg.ArmorValue);
		end
	end

	if cfg.aiNode and self._triMgr then
		self._tids = { };
		for k, v in ipairs(cfg.aiNode) do
			local tcfg = i3k_db_ai_trigger[v];
			if tcfg then
				local TRI = require("logic/entity/ai/i3k_trigger");
				local tri = TRI.i3k_ai_trigger.new(self);
				if tri:Create(tcfg,-1,v) then
					local tid = self._triMgr:RegTrigger(tri, self);
					if tid >= 0 then
						table.insert(self._tids, tid);
					end
				end
			end
		end
	end
	self:ShowTitleNode(true);

	if self:IsPlayer() then
		self:EnableOccluder(true);
	end
    self:TitleIsShowByusercfg()
	return res;
end

function i3k_hero:GetGuidID()
	local entityType =
	{
		[eET_Player] = true,
		[eET_ResourcePoint] = true,
		[eET_Trap] = true,
		[eET_TransferPoint] = true,
		[eET_MapBuff] = true,
		[eET_Skill] = true,
		[eET_Monster] = true,
		[eET_NPC] = true,
	}

	if entityType[self:GetEntityType()] then
		local guid = string.split(self._guid, "|")
		return tonumber(guid[2])
	end
	return 0;
end

function i3k_hero:TitleIsShowByusercfg()
	local usecfg = i3k_get_load_cfg()
	if usecfg then
--[[		local entitySectVisible = usecfg:GetIsShowHeadInfo()
		self:SetHeroSectNameVisiable(entitySectVisible)--]]
		if self:IsPlayer() then
			local MyselfIsShow = usecfg:GetIsShowMyselfHeadInfo()
			self:SetHeroTitleVisiable(MyselfIsShow)
		elseif self:GetEntityType() == eET_Car then
			self:SetTitleVisiable(self:GetTitleShow())
		else
			local OthersIsShow = usecfg:GetIsShowOthersHeadInfo()
			self:SetHeroTitleVisiable(OthersIsShow)
		end
	end
end

function i3k_hero:OnAsyncLoaded()
	local needchangemode = false;
	if self._superMode.cache.valid or self._ride.cache.valid or self._missionMode.cache.valid then
		needchangemode = true;
	end

	if needchangemode then
		self._resCreated = self._resCreated + 1
	end

	BASE.OnAsyncLoaded(self);

	if needchangemode then
		self._resCreated = self._resCreated - 1
	end
	self:TitleIsShowByusercfg()
	
	local hero = i3k_game_get_player_hero();

	if self:GetEntityType() == eET_Player then
		local score = hero._guid == self._guid and g_i3k_game_context:getDesertBattleMapScore() or self._desertInfo.scroe
		self:changeScoreText(score)
	end

	if self._superMode.cache.valid then
		self:OnSuperMode(true);
	end


	if self._ride.cache.valid then
		self:OnRideMode(true);
		local hero = i3k_game_get_player_hero()
		if hero and hero:IsMulMemberState() and self:GetGuidID() == hero:GetMulLeaderId() then
			hero:OnAddLinkChild()
		end
	end

	if self._unifyMode.cache.valid then
		self:OnUnifyMode(true);
	end

	if self._missionMode.cache.valid then
		self:OnMissionMode(true);
	end
	
	if self:GetPropertyValue(ePropID_hp) and self:GetPropertyValue(ePropID_maxHP) and self:GetTitleShow() then
		self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP));
	end
	self:ChangeArmorEffect()
end

function i3k_hero:OnAsyncModelChanged()
	BASE.OnAsyncModelChanged(self);

	if self._changemodelid then
		self._resCreated = self._resCreated - 1;

		if self:GetEntityType() ~= eET_ResourcePoint then
			self:PlayAction()
		else
            local alist = {}
            table.insert(alist, {actionName = "change01", actloopTimes = 1})
            table.insert(alist, {actionName = "stand01", actloopTimes = -1})
			self:PlayActionList(alist, 1);
		end

		if self:IsPlayer() then
			self:EnableOccluder(true)
		end
		if self:GetEntityType() == eET_Player and not self:IsPlayer() then
			if self._titleSpr and self._titleSpr > 0 then
				self:DetachTitleSPR();
				self:AttachTitleSPR();
			end
		end
		if self._isAgainRide then
			self:OnRideMode(true, true)
			self._isAgainRide = false
		end

		self:SetColor(g_i3k_db.i3k_db_get_map_entity_color())
		local mcfg = i3k_db_models[self._changemodelid];
		if mcfg and self._entity then
			--[[
			if mcfg.ignoreBlend[i3k_db_common.engine.defaultStandAction] then
				self._entity:SetActionBlendTime(0);
			else
				self._entity:SetActionBlendTime(0.2);
			end
			self._entity:SelectAction(i3k_db_common.engine.defaultStandAction, self._actionLoops);
			]]
			self._oriScale = self._scale;
			self:SetScale(1) --TODO delet
			self:SetScale(mcfg.scale)
		end

		self:SetPos(self._curPos, true);
		
		local mapType = i3k_game_get_map_type()
		local mapTb = {
			[g_DEFENCE_WAR] = true,
		}
		
		if mapTb[mapType] and self._missionMode.type == g_TASK_TRANSFORM_STATE_CAR then
			if self._missionMode.cache.valid and not self._missionMode.valid then
				self:OnMissionMode(true)
			end
		end			
	end
end

function i3k_hero:CreateTitle(reset)
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
	local mapType = i3k_game_get_map_type()
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("hero_title_node_" .. self._guid) then
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
		if mapTb[mapType] then
			isShow = false
		end
		if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
			isShow = false
		end
		
		local function creatSectTitle()
			local fullSectName = g_i3k_game_context:GetfullSectName(g_i3k_game_context:GetSectName(),g_i3k_game_context:GetSectPosition()) or ""
			title.guild = title.node:AddTextLable(-0.5, 0.15, 0, 0.5, tonumber("0xffffe868", 16), fullSectName);
			local sectTitleImg = g_i3k_game_context:GetSectTitleIcon()
			if sectTitleImg ~= "" and sectTitleImg then
				local len = i3k_get_name_len(fullSectName)
				title.sectImg = title.node:AddImgLable(-(len/18)-1.0, 0.8, -0.7, 0.8, sectTitleImg);
			end
			offsetY = offsetY - 0.6
		end
		if g_i3k_game_context:GetSectName() ~= "" and isShow then
			creatSectTitle()
			if self._iscarRobber == 1 then
				local image = g_i3k_db.i3k_db_get_scene_icon_path(i3k_db_escort.escort_args.robDartTitle)
				title.carName = title.node:AddImgLable(-1, 2, -1.2, 1,image);
				offsetY = offsetY - 0.6
				isShow = false
			end
		elseif mapType == g_GOLD_COAST then --只显示帮派不显示称号
			creatSectTitle()			
		end
		if isShow then
			title.honor = {}
			title.honorbg = {}
			local allTitles = g_i3k_game_context:GetAllEquipTitles()
			for i,e in ipairs(allTitles) do
				local cfg = i3k_db_title_base[e]
				if cfg then
					if cfg.isDynamic == 1 then
						self._isHaveDynamic = true;
						self._titleSprData = cfg;
						self:AttachTitleSPR();
						break;
					end
				end
			end
			if not self._isHaveDynamic then
				for i,e in ipairs(allTitles) do
					local cfg = i3k_db_title_base[e]
					if cfg then
						local image = g_i3k_db.i3k_db_get_title_icon_path(cfg.name)
						local bgimage = g_i3k_db.i3k_db_get_title_icon_path(cfg.iconbackground)
						if bgimage ~= "" then
							title.honorbg[i] =  title.node:AddImgLable(-4, 8, offsetY - 1.25, 2, bgimage);
						end
						if image ~= "" then
							title.honor[i] =  title.node:AddImgLable(-1, 2, offsetY - 0.75, 1, image);
						end
						offsetY = offsetY - 0.85;
					end
				end
			end
		end
		title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
		local name = self._name
		if mapType and self:IsPlayer() then
			if mapType == g_DEMON_HOLE then 
			local serverName = i3k_game_get_server_name(i3k_game_get_login_server_id())
			name =  i3k_get_string(i3k_db_demonhole_base.unifiedName)
			title.serverName	= title.node:AddTextLable(-0.5, 0.2, -0.1, 0.5, tonumber("0xffffffff", 16), serverName);
			elseif mapType == g_MAZE_BATTLE then 
				name = i3k_get_string(i3k_db_maze_battle.nameId)
			end
		end
		if self:IsPlayer() and self:GetIsGuard() then
			name = "观战者"
		end
		title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), name);
	else
		title.node = nil;
	end

	return title;
end

function i3k_hero:SetHeroSectNameVisiable(vis)
	if self._title and self._title.node then
		if self._title.guild then
			self._title.node:SetElementVisiable(self._title.guild,vis)
		end
		if self._title.sectImg then
			self._title.node:SetElementVisiable(self._title.sectImg,vis)
		end
		self:SetHeroTitleVisiable(vis)
	end
end

function i3k_hero:SetHeroTitleVisiable(vis)
	if self._title and self._title.node then
		if self._title.honor then
			for k,v in ipairs(self._title.honor) do
				self._title.node:SetElementVisiable(v,vis)
			end
		end
		if self._title.honorbg then
			for k,v in ipairs(self._title.honorbg) do
				self._title.node:SetElementVisiable(v,vis)
			end
		end
		if self._title.permanentTitle then
			self._title.node:SetElementVisiable(self._title.permanentTitle,vis)
		end
		if self._title.permanentTitleImg then
			self._title.node:SetElementVisiable(self._title.permanentTitleImg,vis)
		end
	end
end

function i3k_hero:ChangeTransportName()
	if self._title and self._title.node then
		self._title = self:CreateTitle(true)
		if self._title and self._title.node then
			self._title.node:SetVisible(true);
			self._title.node:EnterWorld();
			local titleOffset = 0
			if self._ride.valid then
				local mcfg = i3k_db_models[self._ride.deform.args]
				titleOffset = mcfg.titleOffset
			elseif self._missionMode and self._missionMode.type == 3 and self._missionMode.valid then
				local mcfg = i3k_db_models[self._missionMode.deform]
				titleOffset = mcfg.titleOffset
			else
				if self._rescfg then
					titleOffset = self._rescfg.titleOffset;
				end
			end
			self._entity:AddTitleNode(self._title.node:GetTitle(), titleOffset);
			self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP))
			--会武
			if self._missionMode and self._missionMode.type == g_TASK_TRANSFORM_STATE_CHESS and i3k_get_is_tournament_chu_han() then
				self:SetChuhanTitle()
			end
		end
		self:TitleIsShowByusercfg()
	end
end

function i3k_hero:ChangeSectName(name,pos)
	if self._title and self._title.node then
		self._title = self:CreateTitle(true)
		if self._title and self._title.node then
			self._title.node:SetVisible(true);
			self._title.node:EnterWorld();
			local titleOffset = 0
			if self._ride.valid then
				local mcfg = i3k_db_models[self._ride.deform.args]
				titleOffset = mcfg.titleOffset
			elseif self._missionMode and self._missionMode.type == 3 and self._missionMode.valid then
				local mcfg = i3k_db_models[self._missionMode.deform]
				titleOffset = mcfg.titleOffset
			else
				if self._rescfg then
					titleOffset = self._rescfg.titleOffset;
				end
			end
			self._entity:AddTitleNode(self._title.node:GetTitle(), titleOffset);
			self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP))
			if not self:IsPlayer() then
				self:SetBloodBarVisiable(false)
			end
			g_i3k_game_context:ChangPKMode();
		end
		self:TitleIsShowByusercfg()
	end
end

function i3k_hero:ChangeHeroName(name)
	if name then
		self._name = name
		if self._title and self._title.node then
			self._title.node:UpdateTextLable(self._title.name,name,true, tonumber("0xffffffff", 16),false)
		end
	end
end

function i3k_hero:ChangeHonorTitle(titles)
	if self._timedTitles and titles then
		self._timedTitles = titles
	end
	if self._title and self._title.node then
		self._title = self:CreateTitle(true)
		if self._title and self._title.node then
			self._title.node:SetVisible(true);
			self._title.node:EnterWorld();
			local titleOffset = 0
			if self._ride.valid then
				local mcfg = i3k_db_models[self._ride.deform.args]
				titleOffset = mcfg.titleOffset
			elseif self._missionMode and self._missionMode.type == 3 and self._missionMode.valid then
				local mcfg = i3k_db_models[self._missionMode.deform]
				titleOffset = mcfg.titleOffset
			else
				if self._rescfg then
					titleOffset = self._rescfg.titleOffset;
				end
			end
			
			self._entity:AddTitleNode(self._title.node:GetTitle(), titleOffset);
			self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP))
			if not self:IsPlayer() then
				self:SetBloodBarVisiable(false)
			end
		end
		self:TitleIsShowByusercfg()
	end
end

function i3k_hero:Release()
	if self.setLevelCoroutine ~= nil then
		g_i3k_coroutine_mgr:StopCoroutine(self.setLevelCoroutine)
		self.setLevelCoroutine = nil
	end
	if self._tids then
		if self._triMgr then
			for k, v in ipairs(self._tids) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._tids = nil;
	end
	if self._steedtids then
		if self._triMgr then
			for k, v in ipairs(self._steedtids) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._steedtids = nil;
	end
	if self._weapontids then
		if self._triMgr then
			for k,v in ipairs(self._weapontids) do
				self._triMgr:UnregTrigger(v);
			end
		end
	end
	if self._meridiansAi then
		if self._triMgr then
			for k,v in ipairs(self._meridiansAi) do
				self._triMgr:UnregTrigger(v);
			end
		end
	end
	if self._equiptids then
		if self._triMgr then
			for _,v in ipairs(self._equiptids) do
				self._triMgr:UnregTrigger(v)
			end
		end
	end
	if self._shenbinguniquetids then
		if self._triMgr then
			for k,v in ipairs(self._shenbinguniquetids) do
				self._triMgr:UnregTrigger(v);
			end
		end
	end
	if self._passivesTids then
		if self._triMgr then
			for k, v in ipairs(self._passivesTids) do
				self._triMgr:UnregTrigger(v);
			end
		end
	end
	if self._attacker then
		for k, v in ipairs(self._attacker) do
			v:Release();
		end
	end
	self:StopMissionEffect()
	self:ClearEquipEffect()
	if not self:IsPlayer() then
		self:ClsChilds()
	end
	BASE.Release(self);
end

function i3k_hero:isSpecial()
	if self:GetEntityType() == eET_Player and g_i3k_game_context:GetIsSpringWorld() then
		return true;
	end
	return false;
end

function i3k_hero:IsWearFashion()
	local fashionID = i3k_db_spring.common.fationId;
	if self._fashionsID  and self._fashionsID ~= 0 then
		local isHave = false;
		for i,e in ipairs(i3k_db_spring.common.exFationId) do
			if e == self._fashionsID and self:IsFashionShow() then
				isHave = true;
			end
		end
		if not isHave then
			self:SpringFashion(fashionID);
		end
	else
		self:SpringFashion(fashionID);
	end
end

function i3k_hero:SpringSpecialShow()
	self:ClearSkinEffect()
	self:IsWearFashion();
	-- self:HidePlayerEquipPos()
	self:DetachArmorEffect()
end

function i3k_hero:changeSpecialWeap()
	self:changeWeaponShowType()
end

--隐藏普通武器，时装，传家宝，飞升装备
function i3k_hero:HidePlayerEquipPos()
	local fashions = self._Usefashion
	if fashions and fashions[g_FashionType_Weapon] then
		self:SetFashionVisiable(false, g_FashionType_Weapon, true);
	end
	self:DttachHeirhoomEquip()
	self:ChangeFashionPre(eEquipWeapon)
	self:DetachFlyingEquip()
	self:ClearEquipEffect()
	--self:DetachEquip(eEquipWeapon, true);
	--self:ReleaseFashion(self._fashion, eEquipWeapon);
end

function i3k_hero:AttachHomeLandEquip(equipID)
	local cfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(equipID)
	if not cfg then
		return
	end
	local scfg = i3k_db_skins[cfg.skinID];
	if scfg then
		self:ReleaseFashion(self._fashion, eEquipWeapon)
		if self._equips[eEquipWeapon] then
			for k, v in ipairs(self._equips[eEquipWeapon]._skin.skins) do
				self._entity:DetachHosterSkin(v.name);
			end
		end
		local name = string.format("hero_fish_equip_%s_%d", self._guid, cfg.skinID);
		self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
		self:AttachSkinEffect(eFashion_Weapon,scfg.effectID)
		self._homeLandEquipSkinID = cfg.skinID
		self:Play(i3k_db_common.engine.defaultStandAction, -1)
	end
end

function i3k_hero:DetachHomeLandEquip()
	if self:GetIsBeingHomeLandEquip() then
		local name = string.format("hero_fish_equip_%s_%d", self._guid, self._homeLandEquipSkinID);
		self._entity:DetachHosterSkin(name);
		self._homeLandEquipSkinID = 0
		self:changeSpecialWeap()
	end
end

-- 是否正在装备钓鱼装备外显对武器部位有影响
function i3k_hero:GetIsBeingHomeLandEquip()
	return self._homeLandEquipSkinID ~= 0
end

function i3k_hero:GetHomeLandEquipSkinID()
	return self._homeLandEquipSkinID
end

-- 装备家园装备,隐藏装备部位，添加家园装备蒙皮
function i3k_hero:AttachHomeLandCurEquip(curEuqips)
	for _, v in pairs(curEuqips) do
		local cfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(v.confId)
		if cfg and cfg.skinID ~= 0 then
			self:HidePlayerEquipPos()
			self:AttachHomeLandEquip(v.confId)
		end
	end
end

-- 挂载家园钓鱼装备模型
function i3k_hero:LinkHomeLandFishModel(curEuqips, roleID)
	for _, v in pairs(curEuqips) do
		local cfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(v.confId)
		if cfg and cfg.modelID ~= 0 then
			self:LinkFishItem(cfg.modelID, roleID)
			self:Play(i3k_db_home_land_base.fishActCfg.actStand, -1)
		end
	end
end

-- 去除挂载的家园钓鱼装备模型
function i3k_hero:UnloadHomeLandFishModel()
	self:RemoveLinkItem()
	if self._linkItem then
		self._linkItem:Release()
		self._linkItem = nil
		self:Play(i3k_db_common.engine.defaultStandAction, -1)
	end
end

-- 播放开始钓鱼动作
function i3k_hero:PlayStartFishAct()
	local alist = {}
	table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actStart, actloopTimes = 1})
	table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actFishing, actloopTimes = -1})
	self:PlayActionList(alist, 1)
end

-- 播放结束钓鱼动作
function i3k_hero:PlayEndFishAct()
	local alist = {}
	table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actFishEnd, actloopTimes = 1})
	table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actStand, actloopTimes = -1})
	self:PlayActionList(alist, 1)
end

function i3k_hero:WearOldFashion()
	local fashionID = i3k_db_spring.common.fationId;
	if self._fashionsID and self._fashionsID ~= 0 and self._fashionsID ~= fashionID and self:IsFashionShow() then
		self:SpringFashion(self._fashionsID, true);
	else
		self:SpringDetachFashion(true);
	end
end

function i3k_hero:OnLeaveWorld()
	BASE.OnLeaveWorld(self);

	if self._attacks then
		for k, v in pairs(self._attacks) do
			v:OnReset();
		end
	end

	if self._skills then
		for k, v in pairs(self._skills) do
			v:OnReset();
		end
	end
	if self._uniqueSkill then
		self._uniqueSkill:OnReset();
	end

	if self._dodgeSkill then
		self._dodgeSkill:OnReset();
	end

	if self._ultraSkill then
		self._ultraSkill:OnReset();
	end

	if self._DIYSkill then
		self._DIYSkill:OnReset();
	end
	
	if self._anqiAllActiveSkills then
		for _, v in pairs(self._anqiAllActiveSkills) do
			v:OnReset(dTime);
		end
	end

	if self._missionMode.attacks then
		for k, v in pairs(self._missionMode.attacks) do
			v:OnReset();
		end
	end

	if self._missionMode.skills then
		for k, v in pairs(self._missionMode.skills) do
			v:OnReset();
		end
	end
	if self._catchSpiritSkills then
		for k, v in pairs(self._catchSpiritSkills) do
			v:OnReset();
		end
	end
	if self._catchSpiritTrigger then
		for k, v in pairs(self._catchSpiritTrigger) do
			v:OnReset();
		end
	end
	--[[if self._catchSpiritAttact then
		for k, v in pairs(self._catchSpiritAttact) do
			v:OnReset();
		end
	end--]]

	self._deadtriskill = {};
	self._all_alives = {{}, {}, {}};
	self._alives = { { }, { }, { } };

	self:ClsBuffs();
	self:ClsChilds();
	self:ClsEffect();
	self:ClsEnmities();
	self:ClsAttackers();
end

function i3k_hero:CreateResWithFashion(fashion,fromType)
	if fashion then
		self:CreateRes(fashion.modelID);
		local isCombat = i3k_get_is_combat()
		
		local mapTb = {
			[g_FORCE_WAR]	= true,
			[g_DEMON_HOLE] 	= true,
			[g_FACTION_WAR] = true,
			[g_DEFENCE_WAR] = true,
			[g_PET_ACTIVITY_DUNGEON] = true,
			[g_DESERT_BATTLE] = true,
			[g_MAZE_BATTLE] = true,
			[g_SPY_STORY]	= true,
		}

		if mapTb[i3k_game_get_map_type()] and self:GetEntityType() == eET_Player and not self:IsPlayer() and not isCombat then
		else
			self:CreateFashion(fashion, eFashion_Face);
			self:CreateFashion(fashion, eFashion_Hair);
			self:CreateFashion(fashion, eFashion_Body,fromType);
			self:CreateFashion(fashion, eFashion_Weapon,fromType);
		end
	end
end

function i3k_hero:ValidInWorld()
	return true;
end

-- now only face and hair valid
function i3k_hero:ChangeFashion(fashion, ftype, fvalue)
	local fname = string.format("hero_skin_%s_%d", self._guid, ftype);

	if fashion then
		if ftype == eFashion_Face then
			self._face = fvalue;
		elseif ftype == eFashion_Hair then
			self._hair = fvalue;
		end

		if self._entity then

			self._entity:DetachHosterSkin(fname);
			self:DetachSkinEffect(ftype);

			local rcfg = g_i3k_db.i3k_db_fashion_res[fvalue];
			if rcfg then
				local scfg = i3k_db_skins[rcfg.skinID];
				if scfg then
					self._entity:AttachHosterSkin(scfg.path, fname, not self._syncCreateRes);
					self:AttachSkinEffect(ftype,scfg.effectID)
				end
			end
		end
	end
end

function i3k_hero:CreateFashion(fashion, part,fromType)
	if not self._fashionInfo then
		self._fashionInfo = { };
	end
	self._fashionInfo[part]	= { };

	if part == eFashion_Face then
		local rcfg = g_i3k_db.i3k_db_fashion_res[self._face];
		if rcfg then
			local scfg = i3k_db_skins[rcfg.skinID];
			if scfg then
				if self._entity then
					local name = string.format("hero_skin_%s_%d", self._guid, eFashion_Face);

					self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
					self:AttachSkinEffect(eFashion_Face,scfg.effectID)
					table.insert(self._fashionInfo[eFashion_Face], name);
				end
			end
		end
	elseif part == eFashion_Hair then

		local rcfg = g_i3k_db.i3k_db_fashion_res[self._hair];
		if rcfg then
			local scfg = i3k_db_skins[rcfg.skinID];
			if scfg then
				if self._entity then
					local name = string.format("hero_skin_%s_%d", self._guid, eFashion_Hair);

					self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
					self:AttachSkinEffect(eFashion_Hair,scfg.effectID)
					table.insert(self._fashionInfo[eFashion_Hair], name);
				end
			end
		end


	elseif part == eFashion_Body then
		local rcfg = g_i3k_db.i3k_db_get_general_fashion_body_res(fashion,fromType);
		if rcfg then
			for k, v in ipairs(rcfg) do
				local scfg = i3k_db_skins[v];
				if scfg then
					if self._entity then
						local name = string.format("hero_skin_%s_%d_%d", self._guid, eFashion_Body, k);

						self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
						self:AttachSkinEffect(eFashion_Body,scfg.effectID)
						table.insert(self._fashionInfo[eFashion_Body], name);
					end
				end
			end
		end
	elseif part == eFashion_Weapon then
		if self:GetIsBeingHomeLandEquip() then
			return
		end
		rcfg = g_i3k_db.i3k_db_get_general_fashion_weapon_res(fashion,fromType);
		if rcfg then
			for k, v in ipairs(rcfg) do
				local scfg = i3k_db_skins[v];
				if scfg then
					if self._entity then
						local name = string.format("hero_skin_%s_%d_%d", self._guid, eFashion_Weapon, k);

						self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
						self:AttachSkinEffect(eFashion_Weapon,scfg.effectID)
						table.insert(self._fashionInfo[eFashion_Weapon], name);
					end
				end
			end
		end
	end
end

function i3k_hero:ReleaseFashion(fashion, part)
	if self._fashionInfo and self._fashionInfo[part] then
		for k, v in ipairs(self._fashionInfo[part]) do
			if self._entity then
				self._entity:DetachHosterSkin(v);
			end
		end
		self:DetachSkinEffect(part);
	end
end

function i3k_hero:AttachSkinEffect(part,effectIDs)
	if not effectIDs or #effectIDs == 0 then
		return false;
	end
	if not self._skineffectInfo then
		self._skineffectInfo = { };
	end
	if not self._skineffectInfo[part] then
		self._skineffectInfo[part]	= { };
	end

	if part == eFashion_Face then
		for k,v in pairs(effectIDs) do
			local cfg = i3k_db_effects[v];
			if cfg and self._entity then
				local effectID = 0;
				if cfg.hs == '' or cfg.hs == 'default' then
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), "", "", 0.0, cfg.radius);
				else
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), cfg.hs, "", 0.0, cfg.radius);
				end

				self._entity:LinkChildPlay(effectID, -1, true);
				table.insert(self._skineffectInfo[eFashion_Face], effectID);
			end
		end
	elseif part == eFashion_Hair then
		for k,v in pairs(effectIDs) do
			local cfg = i3k_db_effects[v];
			if cfg and self._entity then
				local effectID = 0;
				if cfg.hs == '' or cfg.hs == 'default' then
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), "", "", 0.0, cfg.radius);
				else
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), cfg.hs, "", 0.0, cfg.radius);
				end

				self._entity:LinkChildPlay(effectID, -1, true);
				table.insert(self._skineffectInfo[eFashion_Hair], effectID);
			end
		end
	elseif part == eFashion_Body then
		for k,v in pairs(effectIDs) do
			local cfg = i3k_db_effects[v];
			if cfg and self._entity then
				local effectID = 0;
				if cfg.hs == '' or cfg.hs == 'default' then
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), "", "", 0.0, cfg.radius);
				else
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), cfg.hs, "", 0.0, cfg.radius);
				end

				self._entity:LinkChildPlay(effectID, -1, true);
				table.insert(self._skineffectInfo[eFashion_Body], effectID);
			end
		end
	elseif part == eFashion_Weapon then
		for k,v in pairs(effectIDs) do
			local cfg = i3k_db_effects[v];
			if cfg and self._entity then
				local effectID = 0;
				if cfg.hs == '' or cfg.hs == 'default' then
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), "", "", 0.0, cfg.radius);
				else
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), cfg.hs, "", 0.0, cfg.radius);
				end

				self._entity:LinkChildPlay(effectID, -1, true);
				table.insert(self._skineffectInfo[eFashion_Weapon], effectID);
			end
		end
	elseif part == eFashion_FlyBody then
		for k,v in pairs(effectIDs) do
			local cfg = i3k_db_effects[v];
			if cfg and self._entity then
				local effectID = 0;
				if cfg.hs == '' or cfg.hs == 'default' then
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), "", "", 0.0, cfg.radius);
				else
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_fashion_%s_effect_%d_%d", self._guid, part, v), cfg.hs, "", 0.0, cfg.radius);
				end
				self._entity:LinkChildPlay(effectID, -1, true);
				table.insert(self._skineffectInfo[eFashion_FlyBody], effectID);
			end
		end
	end
end

function i3k_hero:DetachSkinEffect(part)
	if self._skineffectInfo and self._skineffectInfo[part] then
		if self._entity then
			for k,v in pairs(self._skineffectInfo[part]) do
				self._entity:RmvHosterChild(v);
			end
			self._skineffectInfo[part] = nil;
		end
	end
end

function i3k_hero:ClearSkinEffect()
	if self._skineffectInfo then
		if self._entity then
			for k1,v1 in pairs(self._skineffectInfo) do
				for k,v in pairs(v1) do
					self._entity:RmvHosterChild(v);
				end
			end
			self._skineffectInfo = {}
		end
	end
end

function i3k_hero:CanRelease()
	return false;
end

function i3k_hero:SetPlayer(player)
	self._player = player;
end

function i3k_hero:IsPlayer()
	return self._player;
end

-- 更新引擎相关
function i3k_hero:OnUpdate(dTime)
	if self._childs then
		for k1, v1 in pairs(self._childs) do
			for k2, v2 in ipairs(v1) do
				v2:OnUpdate(dTime);
			end
		end
	end

	if self._attacks then
		for k, v in pairs(self._attacks) do
			v:OnUpdate(dTime);
		end
	end

	if self._skills then
		for k, v in pairs(self._skills) do
			v:OnUpdate(dTime);
		end
	end

	if self._dodgeSkill then
		self._dodgeSkill:OnUpdate(dTime);
	end

	if self._uniqueSkill then
		self._uniqueSkill:OnUpdate(dTime);
	end

	if self._DIYSkill then
		self._DIYSkill:OnUpdate(dTime);
	end
	if self._spiritSkill then
		self._spiritSkill:OnUpdate(dTime);
	end
	if self._anqiAllActiveSkills then
		for _, v in pairs(self._anqiAllActiveSkills) do
			v:OnUpdate(dTime);
		end
	end

	if self._ultraSkill then
		self._ultraSkill:OnUpdate(dTime);
	end

	if self._attacker then
		for k, v in ipairs(self._attacker) do
			v:OnUpdate(dTime);
		end
	end

	if self._auras then
		for _, aura in pairs(self._auras) do
			aura:OnUpdate(dTime);
		end
	end

	if self._buffs then
		for _, buff in pairs(self._buffs) do
			buff:OnUpdate(dTime);
		end
	end

	if self._itemSkills then
		for i,v in pairs(self._itemSkills) do
			v:OnUpdate(dTime)
		end
	end

	if self._tournamentSkills then
		for i,v in pairs(self._tournamentSkills) do
			v:OnUpdate(dTime)
		end
	end

	if self._gameInstanceSkills then
		for i,v in pairs(self._gameInstanceSkills) do
			v:OnUpdate(dTime)
		end
	end

	if self._missionMode and self._missionMode.valid then
		for k, v in pairs(self._missionMode.skills) do
			v:OnUpdate(dTime);
		end
		for k, v in pairs(self._missionMode.attacks) do
			v:OnUpdate(dTime);
		end
	end
	if self._weaponManualSkill then
		self._weaponManualSkill:OnUpdate(dTime);
	end
	--[[if g_i3k_game_context:getCurrTripWizardEndTime() and g_i3k_game_context:getCurrTripWizardEndTime() > 0 then
		local tiem = g_i3k_game_context:getCurrTripWizardEndTime() - i3k_game_get_time()
		g_i3k_game_context:setTripTime(tiem)
	end--]]

	if self._weaponBless.ID ~= 0 then
		self:onBlessSkillTick(dTime)
	end
	BASE.OnUpdate(self, dTime);
end

function i3k_hero:OnLogic(dTick)
	if self._childs then
		for k1, v1 in pairs(self._childs) do
			local rmvs = { };
			for k2, v2 in ipairs(v1) do
				if v2:IsDestory() then
					local logic = i3k_game_get_logic();
					local world = logic:GetWorld();
					if world then
						world:RmvEntity(v2);
					end
					v2:Release();

					table.insert(rmvs, k2);
				else
					v2:OnLogic(dTick);
				end

				for k = #rmvs, 1, -1 do
					table.remove(v1, rmvs[k]);
				end
			end

			-- clear special skill child
			if #v1 == 0 then
				self._childs[k1] = nil;
			end
		end
	end

	if self._attacks then
		for k, v in pairs(self._attacks) do
			v:OnLogic(dTick);
		end
	end

	if self._skills then
		for k, v in pairs(self._skills) do
			v:OnLogic(dTick);
		end
	end

	if self._itemSkills then
		for i,v in pairs(self._itemSkills) do
			v:OnLogic(dTick)
		end
	end

	if self._tournamentSkills then
		for i,v in pairs(self._tournamentSkills) do
			v:OnLogic(dTick)
		end
	end

	if self._gameInstanceSkills then
		for i,v in pairs(self._gameInstanceSkills) do
			v:OnLogic(dTick)
		end
	end

	if self._dodgeSkill then
		self._dodgeSkill:OnLogic(dTick);
	end

	if self._uniqueSkill then
		self._uniqueSkill:OnLogic(dTick);
	end

	if self._ultraSkill then
		self._ultraSkill:OnLogic(dTick);
	end

	if self._DIYSkill then
		self._DIYSkill:OnLogic(dTick);
	end
	if self._spiritSkill then
		self._spiritSkill:OnLogic(dTick)
	end
	if self._weaponManualSkill then
		self._weaponManualSkill:OnLogic(dTick);
	end
	if self._anqiAllActiveSkills then
		for _, v in pairs(self._anqiAllActiveSkills) do
			v:OnLogic(dTime);
		end
	end

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

	if self._auras then
		for k, aura in pairs(self._auras) do
			if not aura:OnLogic(dTick) then
				aura:Unbind();

				self._auras[k] = nil;
			end
		end
	end

	if self._buffs then
		for _, buff in pairs(self._buffs) do
			if not buff:OnLogic(dTick) then
				self:RmvBuff(buff);
			end
		end
	end

	--self:UpdateAttackState(dTick);

	local world = i3k_game_get_world();
	if world then
		local syncRpc = world._openType == g_FIELD;
		if syncRpc then
			if self:GetEntityType() == eET_Player then
				if self._fightsp and self._fightsp > 0 then
					local player = i3k_game_get_player()
					local petcount = player:GetPetCount()
					if petcount == 0 then
						self._fightsptime = self._fightsptime - dTick * i3k_engine_get_tick_step();
						if self._fightsptime < 0 then
							self:UpdateFightSp(self._fightsp - 1);
						end
					end
				end
			end
		end
		if (world._mapType == g_FIELD or world._mapType == g_HOME_LAND or world._mapType == g_HOMELAND_HOUSE) and self:GetEntityType() == eET_Player and self:IsHugLeader() then
			if self._hugMode.isStarKiss and self._hugMode.valid and self._hugMode.isStarKissTime then
				self._hugMode.isStarKissTime = self._hugMode.isStarKissTime + dTick * i3k_engine_get_tick_step();
				if self._hugMode.isStarKissTime > i3k_db_common.hugMode.kissTime * 1000 then
					self._hugMode.isStarKissTime = 0;
					self._hugMode.isStarKiss = false;
					self:AddAiComp(eAType_MOVE)
				end
			end
		end
	end


	if self._updateAlives then
		self._updateAliveTick = self._updateAliveTick + dTick * i3k_engine_get_tick_step();
		if self._updateAliveTick > 500 then -- 0.5秒更新一次
			self._updateAliveTick = 0;

			if self:InAttackState() then
				self:UpdateAlives();
			end

			if self:IsPlayer() then
				self:UpdateTrans(dTick);
			end
		end
	end


	if self:IsPlayer() then
		self:CheckDigStatus()
		self:UpdateSuperMode(dTick);
		self:UpdateMissionMode(dTick);
		self:UpdateArmorRecovery(dTick);
		self:UpdateAutoOffline(dTick);
		self:updateWizard(dTick)
		self:UpdateSpecialSuperMode(dTick)
		self:UpdatePkAttackedTip(dTick);
		self:UpdateRideCoolTime(dTick);
		self:UpdataWarZoneCardTime(dTick)
	end

	if self._skilldeny > 0 then
		self._skilldeny = self._skilldeny - dTick * i3k_engine_get_tick_step();
	end

	if self._heroInWorld then
		if not self._isOperationed and i3k_game_get_time() - self._inWorldTime >= i3k_db_common.autoFight.autoTime then
			g_i3k_game_context:SetAutoFight(true)
			self:SetIsOperationed(true)
		end
	end

	BASE.OnLogic(self, dTick);
end
function i3k_hero:UpdataWarZoneCardTime(dTick)
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	if cardInfo.card then
		local inUse = cardInfo.card.inUse
		for k,v in pairs(inUse) do
			local timeNow = i3k_game_get_time()
			if v - timeNow <= 0 then
				g_i3k_game_context:SetWarZoneCardInvalid(k)
			end
		end
	end
end

function i3k_hero:UpdatePkAttackedTip(dTick)
	local mapType = i3k_game_get_map_type()
	if mapType == g_FIELD then
		if self._PVPStatus == g_PeaceMode and self._isUpdatePkTip then
			self._updatePkTipTime = self._updatePkTipTime + dTick * i3k_engine_get_tick_step();
		end
		if (self._PVPStatus == g_PeaceMode) and self._isShowPkTip and not self._isUpdatePkTip then
			self._isUpdatePkTip = true;
			g_i3k_ui_mgr:OpenUI(eUIID_PkTooltip)
		end

		if self._updatePkTipTime > 4000 and self._isShowPkTip then
			self:ClearPkAttackedTip();
		end
	end
end

function i3k_hero:ClearPkAttackedTip()
	self._isUpdatePkTip = false;
	self._isShowPkTip = false;
	self._updatePkTipTime = 0;
	g_i3k_ui_mgr:CloseUI(eUIID_PkTooltip);
end

function i3k_hero:CalcMoveInfo()
	local res = BASE.CalcMoveInfo(self)
	if res then
		if self:IsPlayer() then
			self:SetIsOperationed(true)
		end
	end

	return res;
end

function i3k_hero:InitProperties()
	local properties = BASE.InitProperties(self);

	self._LockProperties = true;

	if self._needUpdateProperty then
		self:UpdateEquipProps(properties);
		self:UpdateTalentProps(properties, true);
		self:UpdateRewardProps(properties);
		if self.setLevelCoroutine ~= nil then
			i3k_coroutine_mgr.WaitForNextFrame()
		end
		self:UpdateWeaponProps(properties);
		self:UpdateFactionSkillProps(properties);
		self:UpdateProfessionProps(properties);
		self:UpdateSuitProps(properties);
		self:UpdateCollectionProps(properties);
		self:UpdateHorseProps(properties);
		if self.setLevelCoroutine ~= nil then
			i3k_coroutine_mgr.WaitForNextFrame()
		end
		self:UpdateLongyinProps(properties);
		self:UpdateFashionProps(properties)
		self:UpdateMissionModeProps(properties)
		self:UpdateClanChildProps(properties)
		self:UpdateLiLianProps(properties)
		if self.setLevelCoroutine ~= nil then
			i3k_coroutine_mgr.WaitForNextFrame()
		end
		self:UpdateTitleProps(properties);
		self:UpdateMercenaryAchievementProps(properties);
		self:UpdateMercenaryRelationProps(properties);
		self:UpdateArmorProps(properties);
		self:UpdateMarryProps(properties);
		self:UpdateWeaponTalentProps(properties);
		self:UpdateOneTimeItemProps(properties)
		self:UpdateWeaponUniqueSkillProps(properties)
		self:UpdateMercenarySpiritsProps(properties)
		self:UpdateSpecialCardProps(properties)
		self:UpdateHeirloomStrength(properties)
		self:UpdatePassiveProp(properties)
		self:UpdateEpicTaskAttr(properties)
		self:UpdateMartialSoulProp(properties)
		self:UpdateStarSoulProp(properties)
		self:UpdateShenDouProp(properties)
		self:UpdateQilingProp(properties)
		self:UpdateQilingTransProp(properties)
		self:UpdateCardPacketProp(properties)
		self:UpdateMeridianProp(properties)
		self:UpdateXingHunProp(properties)
		self:UpdateBaGuaProp(properties)
		self:UpdateDestinyRollProp(properties)
		self:UpdateXiuXinProp(properties)
		self:UpdateHideWeaponProp(properties)
		self:UpdateWuJueProp(properties)
		self:UpdateMetamorphosisProps(properties)
		self:UpdateHorseEquipProp(properties)
		self:UpdatePetGuardProp(properties)
		self:UpdateRoleFlyingProp(properties)
		self:UpdateWarZoneCardProp(properties)
		self:UpdateArrayStoneProp(properties)
		self:UpdateCombatTypeProp(properties) --拳师姿态提升属性
	end

	self._LockProperties = false;

	return properties;
end

function i3k_hero:UpdateProperties()
	self:UpdateEquipProps();
	self:UpdateTalentProps(nil, false);
	self:UpdateRewardProps();
	self:UpdateWeaponProps();
	self:UpdateFactionSkillProps();
	self:UpdateProfessionProps();
	self:UpdateSuitProps();
	self:UpdateCollectionProps();
	self:UpdateHorseProps();
	self:UpdateLongyinProps()
	self:UpdateFashionProps();
	self:UpdateLiLianProps();
	self:UpdateTitleProps();
	self:UpdateMercenaryAchievementProps();
	self:UpdateMercenaryRelationProps();
	self:UpdateArmorProps();
	self:UpdateMarryProps();
	self:UpdateWeaponTalentProps();
	self:UpdateOneTimeItemProps()
	self:UpdateWeaponUniqueSkillProps()
	self:UpdateMercenarySpiritsProps()
	self:UpdateSpecialCardProps()
	self:UpdateHeirloomStrength()
	self:UpdatePassiveProp()
	self:UpdateEpicTaskAttr()
	self:UpdateMartialSoulProp()
	self:UpdateQilingProp()
	self:UpdateQilingTransProp()
	self:UpdateCardPacketProp()
	self:UpdateStarSoulProp()
	self:UpdateShenDouProp()
	self:UpdateMeridianProp()
	self:UpdateXingHunProp()
	self:UpdateBaGuaProp()
	self:UpdateDestinyRollProp()
	self:UpdateXiuXinProp()
	self:UpdateHideWeaponProp()
	self:UpdateWuJueProp()
	self:UpdateHorseEquipProp()
	self:UpdatePetGuardProp()
	self:UpdateRoleFlyingProp()
	self:UpdateWarZoneCardProp()
	self:UpdateArrayStoneProp()
	self:UpdateCombatTypeProp() --拳师姿态提升属性
	local power = self:Appraise()

	g_i3k_game_context:SetTaskDataByTaskType(power,g_TASK_POWER_COUNT)
	--支线任务组战力解锁判断
	g_i3k_game_context:checkSubLineTaskIsLock(2)
	--随从解锁需要战力解锁
	g_i3k_game_context:checkPetPoint()
end

function i3k_hero:OnInitBaseProperty(props)
	local id	= self._id;
	local lvl	= self._lvl;
	local cfg	= self._cfg;

	local properties = BASE.OnInitBaseProperty(self, props);

	-- add new property
	properties[ePropID_maxHP]			= i3k_entity_property.new(self, ePropID_maxHP,			0);
	properties[ePropID_atkN]			= i3k_entity_property.new(self, ePropID_atkN,			0);
	properties[ePropID_defN]			= i3k_entity_property.new(self, ePropID_defN,			0);
	properties[ePropID_atr]				= i3k_entity_property.new(self, ePropID_atr,			0);
	properties[ePropID_ctr]				= i3k_entity_property.new(self, ePropID_ctr,			0);
	properties[ePropID_acrN]			= i3k_entity_property.new(self, ePropID_acrN,			0);
	properties[ePropID_tou]				= i3k_entity_property.new(self, ePropID_tou,			0);
	properties[ePropID_atkA]			= i3k_entity_property.new(self, ePropID_atkA,			1);
	properties[ePropID_defA]			= i3k_entity_property.new(self, ePropID_defA,			1);
	properties[ePropID_deflect]			= i3k_entity_property.new(self, ePropID_deflect,		1);
	properties[ePropID_atkD]			= i3k_entity_property.new(self, ePropID_atkD,			1);
	properties[ePropID_atkH]			= i3k_entity_property.new(self, ePropID_atkH,			0);
	properties[ePropID_atkC]			= i3k_entity_property.new(self, ePropID_atkC,			0);
	properties[ePropID_defC]			= i3k_entity_property.new(self, ePropID_defC,			0);
	properties[ePropID_atkW]			= i3k_entity_property.new(self, ePropID_atkW,			0);
	properties[ePropID_defW]			= i3k_entity_property.new(self, ePropID_defW,			0);
	properties[ePropID_masterC]			= i3k_entity_property.new(self, ePropID_masterC,		0);
	properties[ePropID_masterW]			= i3k_entity_property.new(self, ePropID_masterW,		0);
	properties[ePropID_healA]			= i3k_entity_property.new(self, ePropID_healA,			0);
	properties[ePropID_sbd]				= i3k_entity_property.new(self, ePropID_sbd,			0);
	properties[ePropID_shell]			= i3k_entity_property.new(self, ePropID_shell,			0);
	properties[ePropID_dmgToH]			= i3k_entity_property.new(self, ePropID_dmgToH,			1);
	properties[ePropID_dmgToB]			= i3k_entity_property.new(self, ePropID_dmgToB,			1);
	properties[ePropID_dmgToD]			= i3k_entity_property.new(self, ePropID_dmgToD,			1);
	properties[ePropID_dmgToA]			= i3k_entity_property.new(self, ePropID_dmgToA,			1);
	properties[ePropID_dmgToO]			= i3k_entity_property.new(self, ePropID_dmgToO,			1);
	properties[ePropID_dmgByH]			= i3k_entity_property.new(self, ePropID_dmgByH,			1);
	properties[ePropID_dmgByB]			= i3k_entity_property.new(self, ePropID_dmgByB,			1);
	properties[ePropID_dmgByD]			= i3k_entity_property.new(self, ePropID_dmgByD,			1);
	properties[ePropID_dmgByA]			= i3k_entity_property.new(self, ePropID_dmgByA,			1);
	properties[ePropID_dmgByO]			= i3k_entity_property.new(self, ePropID_dmgByO,			1);
	properties[ePropID_res1]			= i3k_entity_property.new(self, ePropID_res1,			1);
	properties[ePropID_res2]			= i3k_entity_property.new(self, ePropID_res2,			1);
	properties[ePropID_res3]			= i3k_entity_property.new(self, ePropID_res3,			1);
	properties[ePropID_res4]			= i3k_entity_property.new(self, ePropID_res4,			1);
	properties[ePropID_res5]			= i3k_entity_property.new(self, ePropID_res5,			1);
	properties[ePropID_alertRange]		= i3k_entity_property.new(self, ePropID_alertRange,		0);
	properties[ePropID_maxSP]			= i3k_entity_property.new(self, ePropID_maxSP,			0);
	properties[ePropID_sp]				= i3k_entity_property.new(self, ePropID_sp,				0);
	properties[ePropID_healGain]		= i3k_entity_property.new(self, ePropID_healGain,		0);
	properties[ePropID_defStrike]		= i3k_entity_property.new(self, ePropID_defStrike,		0);
	properties[ePropID_mercenarydmgTo]	= i3k_entity_property.new(self, ePropID_mercenarydmgTo,	1);
	properties[ePropID_mercenarydmgBy]	= i3k_entity_property.new(self, ePropID_mercenarydmgBy,	1);
	properties[ePropID_behealGain]		= i3k_entity_property.new(self, ePropID_behealGain,	1);
	properties[ePropID_internalForces]	= i3k_entity_property.new(self, ePropID_internalForces,		0);
	properties[ePropID_dex]				= i3k_entity_property.new(self, ePropID_dex,		0);
	properties[ePropID_armorMaxValue]	= i3k_entity_property.new(self, ePropID_armorMaxValue, 0);
	properties[ePropID_armorDef]		= i3k_entity_property.new(self, ePropID_armorDef, 0);
	properties[ePropID_armorFit]		= i3k_entity_property.new(self, ePropID_armorFit, 0);
	properties[ePropID_armorRec]		= i3k_entity_property.new(self, ePropID_armorRec, 0);
	properties[ePropID_armorFrezze]		= i3k_entity_property.new(self, ePropID_armorFrezze, 0);
	properties[ePropID_armorAbsorb]		= i3k_entity_property.new(self, ePropID_armorAbsorb, 0);
	properties[ePropID_armorDestory]	= i3k_entity_property.new(self, ePropID_armorDestory, 0);
	properties[ePropID_armorWeak]		= i3k_entity_property.new(self, ePropID_armorWeak, 0);
	properties[ePropID_attackUp]		= i3k_entity_property.new(self, ePropID_hero, 1);
	properties[ePropID_ignoreDef]		= i3k_entity_property.new(self, ePropID_ignoreDef, 1);
	properties[ePropID_ignoreDodge]		= i3k_entity_property.new(self, ePropID_ignoreDodge, 1);
	properties[ePropID_ignoretou]		= i3k_entity_property.new(self, ePropID_ignoretou, 1);
	properties[ePropID_rapidly]			= i3k_entity_property.new(self, ePropID_rapidly, 0);
	properties[ePropID_armorCurValue]	= i3k_entity_property.new(self, ePropID_armorCurValue, 0);
	properties[ePropID_daoDmgAdd]		= i3k_entity_property.new(self, ePropID_daoDmgAdd, 1);
	properties[ePropID_daoDmgMinus]		= i3k_entity_property.new(self, ePropID_daoDmgMinus, 1);
	properties[ePropID_jianDmgAdd]		= i3k_entity_property.new(self, ePropID_jianDmgAdd, 1);
	properties[ePropID_jianDmgMinus]	= i3k_entity_property.new(self, ePropID_jianDmgMinus, 1);
	properties[ePropID_qiangDmgAdd]		= i3k_entity_property.new(self, ePropID_qiangDmgAdd, 1);
	properties[ePropID_qiangDmgMinus]	= i3k_entity_property.new(self, ePropID_qiangDmgMinus, 1);
	properties[ePropID_gongDmgAdd]		= i3k_entity_property.new(self, ePropID_gongDmgAdd, 1);
	properties[ePropID_gongDmgMinus]	= i3k_entity_property.new(self, ePropID_gongDmgMinus, 1);
	properties[ePropID_yiDmgAdd]		= i3k_entity_property.new(self, ePropID_yiDmgAdd, 1);
	properties[ePropID_yiDmgMinus]		= i3k_entity_property.new(self, ePropID_yiDmgMinus, 1);
	properties[ePropID_combo]			= i3k_entity_property.new(self, ePropID_combo, 1);
	properties[ePropID_comboA]			= i3k_entity_property.new(self, ePropID_comboA, 0);
	properties[ePropID_InvisBreak]		= i3k_entity_property.new(self, ePropID_InvisBreak, 1);
	properties[ePropID_shenbingDmgAdd]	= i3k_entity_property.new(self, ePropID_shenbingDmgAdd, 1);
	properties[ePropID_shenbingDmgMinus]= i3k_entity_property.new(self, ePropID_shenbingDmgMinus, 1);
	properties[ePropID_buffMaster1]		= i3k_entity_property.new(self, ePropID_buffMaster1, 1);
	properties[ePropID_buffMaster2]		= i3k_entity_property.new(self, ePropID_buffMaster2, 1);
	properties[ePropID_buffMaster3]		= i3k_entity_property.new(self, ePropID_buffMaster3, 1);
	properties[ePropID_ThugDmgAdd]		= i3k_entity_property.new(self, ePropID_ThugDmgAdd, 1);
	properties[ePropID_ThugDmgMinus]	= i3k_entity_property.new(self, ePropID_ThugDmgMinus, 1);
	properties[ePropID_BeSuperHitRes]	= i3k_entity_property.new(self, ePropID_BeSuperHitRes, 1);
	properties[ePropID_internalForceMaster]	= i3k_entity_property.new(self, ePropID_internalForceMaster, 1);
	properties[ePropID_WindDamage]	= i3k_entity_property.new(self, ePropID_WindDamage, 0);
	properties[ePropID_WindDefence]	= i3k_entity_property.new(self, ePropID_WindDefence, 0);
	properties[ePropID_FireDamage]	= i3k_entity_property.new(self, ePropID_FireDamage, 0);
	properties[ePropID_FireDefence]	= i3k_entity_property.new(self, ePropID_FireDefence, 0);
	properties[ePropID_SoilDamage]	= i3k_entity_property.new(self, ePropID_SoilDamage, 0);
	properties[ePropID_SoilDefence]	= i3k_entity_property.new(self, ePropID_SoilDefence, 0);
	properties[ePropID_WoodDamage]	= i3k_entity_property.new(self, ePropID_WoodDamage, 0);
	properties[ePropID_WoodDefence]	= i3k_entity_property.new(self, ePropID_WoodDefence, 0);
	properties[ePropID_DexMaster]	= i3k_entity_property.new(self, ePropID_DexMaster, 1);
	properties[ePropID_CampMaster]	= i3k_entity_property.new(self, ePropID_CampMaster, 0);
	properties[ePropID_OutATK]		= i3k_entity_property.new(self, ePropID_OutATK, 1);
	properties[ePropID_WithinATK]	= i3k_entity_property.new(self, ePropID_WithinATK, 1);
	properties[ePropID_ElementATK]	= i3k_entity_property.new(self, ePropID_ElementATK, 1);
	properties[ePropID_MeridianHPIncrease]	= i3k_entity_property.new(self, ePropID_MeridianHPIncrease, 1);
	properties[ePropID_MeridianHPUpper]	= i3k_entity_property.new(self, ePropID_MeridianHPUpper, 0);
	properties[ePropID_EquipLevel]		= i3k_entity_property.new(self, ePropID_EquipLevel, 0);
	properties[ePropID_DismountMaster]	= i3k_entity_property.new(self, ePropID_DismountMaster, 0);
	properties[ePropID_DismountResist]	= i3k_entity_property.new(self, ePropID_DismountResist, 0);
	properties[ePropID_AllPropertyReduce]	= i3k_entity_property.new(self, ePropID_AllPropertyReduce, 1);
	properties[ePropID_SteedFightDamage]	= i3k_entity_property.new(self, ePropID_SteedFightDamage, 0);
	properties[ePropID_SteedFightDefend]	= i3k_entity_property.new(self, ePropID_SteedFightDefend, 0);
	properties[ePropID_SuperStateDamage]	= i3k_entity_property.new(self, ePropID_SuperStateDamage, 1);
	properties[ePropID_PetByHoster]			= i3k_entity_property.new(self, ePropID_PetByHoster, 1);
	properties[ePropID_symbolDmgAdd]			= i3k_entity_property.new(self, ePropID_symbolDmgAdd, 1);
	properties[ePropID_symbolDmgMinus]			= i3k_entity_property.new(self, ePropID_symbolDmgMinus, 1);
	properties[ePropID_meleeDmgMinus]			= i3k_entity_property.new(self, ePropID_meleeDmgMinus, 1);
	properties[ePropID_damageTransferred]			= i3k_entity_property.new(self, ePropID_damageTransferred, 1);
	properties[ePropID_ArmorDamageAdd]			= i3k_entity_property.new(self, ePropID_ArmorDamageAdd, 1);
	properties[ePropID_ReviveArmorPercent]			= i3k_entity_property.new(self, ePropID_ReviveArmorPercent, 1);
	properties[ePropID_OutATKDeepen]			= i3k_entity_property.new(self, ePropID_OutATKDeepen, 1);
	properties[ePropID_WithinATKDeepen]			= i3k_entity_property.new(self, ePropID_WithinATKDeepen, 1);
	properties[ePropID_ElementATKDeepen]		= i3k_entity_property.new(self, ePropID_ElementATKDeepen, 1);
	properties[ePropID_DmgBarrier]		= i3k_entity_property.new(self, ePropID_DmgBarrier, 1);
	properties[ePropID_ResistTaunt]		= i3k_entity_property.new(self, ePropID_ResistTaunt, 1);
	properties[ePropID_FistAgainst]		= i3k_entity_property.new(self, ePropID_FistAgainst, 1);
	properties[ePropID_ResisNoReturnHP] = i3k_entity_property.new(self, ePropID_ResisNoReturnHP, 1);
	properties[ePropID_MeleeDamage]		= i3k_entity_property.new(self, ePropID_MeleeDamage, 1);
	properties[ePropID_BoxerDmgAdd]		= i3k_entity_property.new(self, ePropID_BoxerDmgAdd, 1);
	properties[ePropID_BoxerDmgMinus]	= i3k_entity_property.new(self, ePropID_BoxerDmgMinus, 1);
	properties[ePropID_NormalDmgMinus]	= i3k_entity_property.new(self, ePropID_NormalDmgMinus, 1);
	properties[ePropID_CombatTypeCD]	= i3k_entity_property.new(self, ePropID_CombatTypeCD, 0);

	local all_hp		= 0;
	local all_atkN		= 0;
	local all_defN		= 0;
	local all_defA		= 0;
	local all_atr		= 0;
	local all_ctr		= 0;
	local all_acrN		= 0;
	local all_tou		= 0;
	local all_atkA		= 0;
	local all_defA		= 0;
	local all_deflect	= 0;
	local all_atkD		= 0;
	local all_atkH		= 0;
	local all_atkC		= 0;
	local all_defC		= 0;
	local all_atkW		= 0;
	local all_defW		= 0;
	local all_masterC	= 0;
	local all_masterW	= 0;
	local all_healA		= 0;
	local all_sbd		= 0;
	local all_shell		= 0;

	local all_dmgToH	= 0;
	local all_dmgToB	= 0;
	local all_dmgToD	= 0;
	local all_dmgToA	= 0;
	local all_dmgToO	= 0;
	local all_dmgByH	= 0;
	local all_dmgByB	= 0;
	local all_dmgByD	= 0;
	local all_dmgByA	= 0;
	local all_dmgByO	= 0;

	local all_res1		= 0;
	local all_res2		= 0;
	local all_res3		= 0;
	local all_res4		= 0;
	local all_res5		= 0;

	local speed			= 0;
	local alertRange	= i3k_db_common.general.alertRange;
	local all_sp		= i3k_db_common.general.maxEnergy;


	if cfg then
		speed		= cfg.speed;
		if not self._inBiographyCareer then
			local _lvl = lvl - 1;
		alertRange	= cfg.checkRange;
		if self:GetEntityType()== eET_Mercenary then
			local mapType = i3k_game_get_map_type()
			if mapType==g_ARENA_SOLO or mapType==g_TAOIST then
				alertRange = 1000000000;
			end
			if g_i3k_game_context:getPetIsWaken(self._id) then
				cfg = i3k_db_mercenariea_waken_property[self._id];
			end
		end
		all_hp		= all_hp		+ cfg.hpOrg		+ cfg.hpInc1		* _lvl * _lvl + cfg.hpInc2		* _lvl;
		all_atkN	= all_atkN		+ cfg.atkNOrg	+ cfg.atkNInc1		* _lvl * _lvl + cfg.atkNInc2	* _lvl;
		all_defN	= all_defN		+ cfg.defNOrg	+ cfg.defNInc1		* _lvl * _lvl + cfg.defNInc2	* _lvl;
		all_atr		= all_atr		+ cfg.atrOrg	+ cfg.atrInc1		* _lvl * _lvl + cfg.atrInc2		* _lvl;
		all_ctr		= all_ctr		+ cfg.ctrOrg	+ cfg.ctrInc1		* _lvl * _lvl + cfg.ctrInc2		* _lvl;
		all_acrN	= all_acrN		+ cfg.acrNOrg	+ cfg.acrNInc1		* _lvl * _lvl + cfg.acrNInc2	* _lvl;
		all_tou		= all_tou		+ cfg.touOrg	+ cfg.touInc1		* _lvl * _lvl + cfg.touInc2		* _lvl;
		all_atkA	= all_atkA		+ cfg.atkAOrg	+ cfg.atkAInc1		* _lvl * _lvl + cfg.atkAInc2	* _lvl;
		end
	end


	-- update all properties
	properties[ePropID_lvl				]:Set(lvl,			ePropType_Base, true);
	properties[ePropID_maxHP			]:Set(all_hp,		ePropType_Base);
	properties[ePropID_atkN				]:Set(all_atkN,		ePropType_Base);
	properties[ePropID_defN				]:Set(all_defN,		ePropType_Base);
	properties[ePropID_atr				]:Set(all_atr,		ePropType_Base);
	properties[ePropID_ctr				]:Set(all_ctr,		ePropType_Base);
	properties[ePropID_acrN				]:Set(all_acrN,		ePropType_Base);
	properties[ePropID_tou				]:Set(all_tou,		ePropType_Base);
	properties[ePropID_atkA				]:Set(all_atkA,		ePropType_Base);
	properties[ePropID_defA				]:Set(all_defA,		ePropType_Base);
	properties[ePropID_deflect			]:Set(all_deflect,	ePropType_Base);
	properties[ePropID_atkD				]:Set(all_atkD,		ePropType_Base);
	properties[ePropID_atkH				]:Set(all_atkH,		ePropType_Base);
	properties[ePropID_atkC				]:Set(all_atkC,		ePropType_Base);
	properties[ePropID_defC				]:Set(all_defC,		ePropType_Base);
	properties[ePropID_atkW				]:Set(all_atkW,		ePropType_Base);
	properties[ePropID_defW				]:Set(all_defW,		ePropType_Base);
	properties[ePropID_masterC			]:Set(all_masterC,	ePropType_Base);
	properties[ePropID_masterW			]:Set(all_masterW,	ePropType_Base);
	properties[ePropID_healA			]:Set(all_healA,	ePropType_Base);
	properties[ePropID_sbd				]:Set(all_sbd,		ePropType_Base);
	properties[ePropID_shell			]:Set(all_shell,	ePropType_Base);
	properties[ePropID_dmgToH			]:Set(all_dmgToH,	ePropType_Base);
	properties[ePropID_dmgToB			]:Set(all_dmgToB,	ePropType_Base);
	properties[ePropID_dmgToD			]:Set(all_dmgToD,	ePropType_Base);
	properties[ePropID_dmgToA			]:Set(all_dmgToA,	ePropType_Base);
	properties[ePropID_dmgToO			]:Set(all_dmgToO,	ePropType_Base);
	properties[ePropID_dmgByH			]:Set(all_dmgByH,	ePropType_Base);
	properties[ePropID_dmgByB			]:Set(all_dmgByB,	ePropType_Base);
	properties[ePropID_dmgByD			]:Set(all_dmgByD,	ePropType_Base);
	properties[ePropID_dmgByA			]:Set(all_dmgByA,	ePropType_Base);
	properties[ePropID_dmgByO			]:Set(all_dmgByO,	ePropType_Base);
	properties[ePropID_res1				]:Set(all_res1,		ePropType_Base);
	properties[ePropID_res2				]:Set(all_res2,		ePropType_Base);
	properties[ePropID_res3				]:Set(all_res3,		ePropType_Base);
	properties[ePropID_res4				]:Set(all_res4,		ePropType_Base);
	properties[ePropID_res5				]:Set(all_res5,		ePropType_Base);
	properties[ePropID_speed			]:Set(speed,		ePropType_Base);
	properties[ePropID_alertRange		]:Set(alertRange,	ePropType_Base);
	properties[ePropID_maxSP			]:Set(all_sp,		ePropType_Base);
	properties[ePropID_sp				]:Set(0,			ePropType_Base);
	properties[ePropID_healGain			]:Set(0,			ePropType_Base);
	properties[ePropID_defStrike		]:Set(0,			ePropType_Base);
	properties[ePropID_mercenarydmgTo	]:Set(0,			ePropType_Base);
	properties[ePropID_mercenarydmgBy	]:Set(0,			ePropType_Base);
	properties[ePropID_behealGain		]:Set(0,			ePropType_Base);
	properties[ePropID_internalForces	]:Set(0,			ePropType_Base);
	properties[ePropID_dex				]:Set(0,			ePropType_Base);
	properties[ePropID_armorMaxValue	]:Set(0,			ePropType_Base);
	properties[ePropID_armorDef			]:Set(0,			ePropType_Base);
	properties[ePropID_armorFit			]:Set(0,			ePropType_Base);
	properties[ePropID_armorRec			]:Set(0,			ePropType_Base);
	properties[ePropID_armorFrezze		]:Set(0,			ePropType_Base);
	properties[ePropID_armorAbsorb		]:Set(0,			ePropType_Base);
	properties[ePropID_armorDestory		]:Set(0,			ePropType_Base);
	properties[ePropID_armorWeak		]:Set(0,			ePropType_Base);
	properties[ePropID_attackUp			]:Set(0,			ePropType_Base);
	properties[ePropID_ignoreDef		]:Set(0,			ePropType_Base);
	properties[ePropID_ignoreDodge		]:Set(0,			ePropType_Base);
	properties[ePropID_ignoretou		]:Set(0,			ePropType_Base);
	properties[ePropID_rapidly			]:Set(0,			ePropType_Base);
	properties[ePropID_armorCurValue	]:Set(0,			ePropType_Base)
	properties[ePropID_daoDmgAdd		]:Set(0,			ePropType_Base)
	properties[ePropID_daoDmgMinus		]:Set(0,			ePropType_Base)
	properties[ePropID_jianDmgAdd		]:Set(0,			ePropType_Base)
	properties[ePropID_jianDmgMinus		]:Set(0,			ePropType_Base)
	properties[ePropID_qiangDmgAdd		]:Set(0,			ePropType_Base)
	properties[ePropID_qiangDmgMinus	]:Set(0,			ePropType_Base)
	properties[ePropID_gongDmgAdd		]:Set(0,			ePropType_Base)
	properties[ePropID_gongDmgMinus		]:Set(0,			ePropType_Base)
	properties[ePropID_combo			]:Set(0,			ePropType_Base)
	properties[ePropID_comboA			]:Set(0,			ePropType_Base)
	properties[ePropID_InvisBreak		]:Set(0,			ePropType_Base)
	properties[ePropID_yiDmgAdd			]:Set(0,			ePropType_Base)
	properties[ePropID_yiDmgMinus		]:Set(0,			ePropType_Base)
	properties[ePropID_shenbingDmgAdd	]:Set(0,			ePropType_Base)
	properties[ePropID_shenbingDmgMinus	]:Set(0,			ePropType_Base)
	properties[ePropID_buffMaster1		]:Set(0,			ePropType_Base)
	properties[ePropID_buffMaster2		]:Set(0,			ePropType_Base)
	properties[ePropID_buffMaster3		]:Set(0,			ePropType_Base)
	properties[ePropID_ThugDmgAdd		]:Set(0,			ePropType_Base)
	properties[ePropID_ThugDmgMinus		]:Set(0,			ePropType_Base)
	properties[ePropID_BeSuperHitRes	]:Set(0,			ePropType_Base)
	properties[ePropID_internalForceMaster]:Set(0,			ePropType_Base)
	properties[ePropID_WindDamage		]:Set(0,			ePropType_Base)
	properties[ePropID_WindDefence		]:Set(0,			ePropType_Base)
	properties[ePropID_FireDamage		]:Set(0,			ePropType_Base)
	properties[ePropID_FireDefence		]:Set(0,			ePropType_Base)
	properties[ePropID_SoilDamage		]:Set(0,			ePropType_Base)
	properties[ePropID_SoilDefence		]:Set(0,			ePropType_Base)
	properties[ePropID_WoodDamage		]:Set(0,			ePropType_Base)
	properties[ePropID_WoodDefence		]:Set(0,			ePropType_Base)
	properties[ePropID_DexMaster		]:Set(0,			ePropType_Base)
	properties[ePropID_CampMaster		]:Set(0,			ePropType_Base)
	properties[ePropID_OutATK			]:Set(0,			ePropType_Base)
	properties[ePropID_WithinATK		]:Set(0,			ePropType_Base)
	properties[ePropID_ElementATK		]:Set(0,			ePropType_Base)
	properties[ePropID_MeridianHPIncrease]:Set(0,			ePropType_Base)
	properties[ePropID_MeridianHPUpper	]:Set(0,			ePropType_Base)
	properties[ePropID_EquipLevel		]:Set(0,			ePropType_Base)
	properties[ePropID_DismountMaster	]:Set(0,			ePropType_Base)
	properties[ePropID_DismountResist	]:Set(0,			ePropType_Base)
	properties[ePropID_AllPropertyReduce]:Set(0,			ePropType_Base)
	properties[ePropID_SteedFightDamage	]:Set(0,			ePropType_Base)
	properties[ePropID_SteedFightDefend	]:Set(0,			ePropType_Base)
	properties[ePropID_SuperStateDamage	]:Set(0,			ePropType_Base)
	properties[ePropID_PetByHoster		]:Set(0,			ePropType_Base)
	properties[ePropID_symbolDmgAdd		]:Set(0,			ePropType_Base)
	properties[ePropID_symbolDmgMinus	]:Set(0,			ePropType_Base)
	properties[ePropID_meleeDmgMinus	]:Set(0,			ePropType_Base)
	properties[ePropID_damageTransferred]:Set(0,			ePropType_Base)
	properties[ePropID_ArmorDamageAdd	]:Set(0,			ePropType_Base)
	properties[ePropID_ReviveArmorPercent]:Set(0,			ePropType_Base)
	properties[ePropID_OutATKDeepen		]:Set(0,			ePropType_Base)
	properties[ePropID_WithinATKDeepen	]:Set(0,			ePropType_Base)
	properties[ePropID_ElementATKDeepen	]:Set(0,			ePropType_Base)
	properties[ePropID_DmgBarrier		]:Set(0,			ePropType_Base)
	properties[ePropID_ResistTaunt		]:Set(0,			ePropType_Base)
	properties[ePropID_FistAgainst		]:Set(0,			ePropType_Base)
	properties[ePropID_ResisNoReturnHP	]:Set(0,			ePropType_Base)
	properties[ePropID_MeleeDamage		]:Set(0,			ePropType_Base)
	properties[ePropID_BoxerDmgAdd		]:Set(0,			ePropType_Base)
	properties[ePropID_BoxerDmgMinus	]:Set(0,			ePropType_Base)
	properties[ePropID_NormalDmgMinus	]:Set(0,			ePropType_Base)
	properties[ePropID_CombatTypeCD 	]:Set(0,			ePropType_Base)


	return properties;
end

function i3k_hero:InitSkills(resetBinds)
	local cooltimes = { };
	local uniqueTime = nil;
	if self._attacks then
		for k,v in pairs(self._attacks) do
			if not v:CanUse() then
				cooltimes[v._id] = v._coolTick
			end
		end
	end
	if self._skills then
		for k,v in pairs(self._skills) do
			if not v:CanUse() then
				cooltimes[v._id] = v._coolTick
			end
		end
	end
	if self._ultraSkill then
		if not self._ultraSkill:CanUse() then
			cooltimes[self._ultraSkill._id] = self._ultraSkill._coolTick
		end
	end
	if self._dodgeSkill then
		if not self._dodgeSkill:CanUse() then
			cooltimes[self._dodgeSkill._id] = self._dodgeSkill._coolTick
		end
	end
	if self._uniqueSkill then
		if not self._uniqueSkill:CanUse() then
			uniqueTime = self._uniqueSkill._coolTick
		end
	end
	if self._DIYSkill then
		if not self._DIYSkill:CanUse() then
			cooltimes[self._DIYSkill._id] = self._DIYSkill._coolTick
		end
	end

	if self._anqiAllActiveSkills then
		for _, v in pairs(self._anqiAllActiveSkills) do
			if not v:CanUse() then
				cooltimes[v._id] = v._coolTick
			end
		end
	end

	self._attacks	= { }; -- 普通攻击
	self._attackIdx	= 1; -- 普通攻击索引
	self._skills	= { }; -- 主动技能
	self._ultraSkill= nil;
	self._uniqueSkill= nil;
	self._dodgeSkill= nil;
	self._DIYSkill	= nil;
	self._anqiAllActiveSkills = {}
	self._anqiSkill = nil;
	self._seq_skill = { valid = false, parent = nil, skill = nil };
	self._attackID	= -1; -- 攻击序列索引
	self._attackLst = { }; -- 攻击序列
	local cfg = self._cfg;
	if cfg then
		-- init attacks
		if cfg.attacks then
			for k, v in ipairs(cfg.attacks) do
				local scfg = i3k_db_skills[v];
				if scfg then
					local skill = require("logic/battle/i3k_skill");
					if skill then
						local _skill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Attack);
						if cooltimes[v] then
							_skill:CalculationCoolTime(cooltimes[v]);
						end
						if _skill then
							table.insert(self._attacks, _skill);
						end
					end
				end
			end
		end

		-- init skills
		if self._validSkills then
			for k, v in pairs(self._validSkills) do
				local vsl = v;
				if vsl then
					local lvl	= vsl.lvl;
					local valid = (lvl ~= nil and lvl > 0);
					local scfg = i3k_db_skills[v.id];
					if valid and scfg then
						local skill = require("logic/battle/i3k_skill");
						if skill then
							local longyininfo = g_i3k_game_context:GetLongYinInfo();
							if longyininfo.skills then
								if longyininfo.skills[v.id] then
									lvl = lvl + longyininfo.skills[v.id]
								end
							end
							local _skill = skill.i3k_skill_create(self, scfg, lvl, vsl.state or 0, skill.eSG_Skill);
							if cooltimes[v.id] then
								_skill:CalculationCoolTime(cooltimes[v.id]);
							end
							if _skill then
								self._skills[k] = _skill;
							end
						end
					end
				end
			end
		end
		if cfg.dodgeSkill then
			local scfg = i3k_db_skills[cfg.dodgeSkill];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill, changeTick);
					if cooltimes[cfg.dodgeSkill] then
						self._dodgeSkill:CalculationCoolTime(cooltimes[cfg.dodgeSkill]);
					end
					local wearEquip = g_i3k_game_context:GetWearEquips()
					for k,v in pairs(wearEquip) do
						if v.equip then
							for i,e in ipairs(v.equip.legends) do
								if i==3 and e ~= 0 then
									local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(v.equip.equip_id)
									local eCfg = i3k_db_equips_legends_3[equip_t.partID][e]
									if eCfg and eCfg.type == 5 then
										self._dodgeSkill:ChangeSkillTick(eCfg.args[1])
										break
									end
								end
							end
						end
					end
				end
			end
		end

		local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝技
		if use_uniqueSkill and use_uniqueSkill > 0 then
			local scfg = i3k_db_skills[use_uniqueSkill];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				local now_lv = role_unique_skill[use_uniqueSkill].lvl
				local state  = role_unique_skill[use_uniqueSkill].state
				if not now_lv then
					now_lv = 1;
				end
				if not state then
					state = 0;
				end
				if skill then
					self._uniqueSkill = skill.i3k_skill_create(self, scfg, now_lv, state, skill.eSG_Skill);
					if uniqueTime and uniqueTime ~= nil then
						self._uniqueSkill:CalculationCoolTime(uniqueTime);
					end
				end
			end
		end

		if cfg.ultraSkill then
			local scfg = i3k_db_skills[cfg.ultraSkill];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					if self:GetEntityType() == eET_Mercenary then
						self._ultraSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Attack);
					else
						self._ultraSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
					end
					if cooltimes[cfg.ultraSkill] then
						self._ultraSkill:CalculationCoolTime(cooltimes[cfg.ultraSkill]);
					end
				end
			end
		end

		if self:GetEntityType() == eET_Player then
			if g_i3k_game_context and g_i3k_game_context:getCurrentSkillID()~= 0 then
				local kfcfg = g_i3k_game_context:getCreateKungfuData()
				self:LoadDIYSkill(g_i3k_game_context:getCurrentSkillID(),kfcfg)
				if cooltimes[9999999] then
					self._DIYSkill:CalculationCoolTime(cooltimes[9999999]);
				end
			end
		end

		if self:GetEntityType() == eET_Player and g_i3k_game_context then
			local curAnqiInfo = g_i3k_game_context:getEquipedHideWeaponSkill()
			local anqiSkills = g_i3k_game_context:getHideWeaponSkills()

			if anqiSkills then
				for _, v in ipairs(anqiSkills) do
					local skill = require("logic/battle/i3k_skill");
					local id = v.skillID
					local level = v.level
					local anqiSkillCfg = i3k_db_skills[id]

					if skill and anqiSkillCfg then
						local skillItem = skill.i3k_skill_create(self, anqiSkillCfg, level, 0, skill.eSG_Skill);
						skillItem._anqiSkillID = id

						if cooltimes[id] then
							skillItem:CalculationCoolTime(cooltimes[id]);
						end

						table.insert(self._anqiAllActiveSkills, skillItem)

						if curAnqiInfo ~= nil and id == curAnqiInfo.skillID then
							self._anqiSkill = skillItem
						end
					end
				end
			end
		end

		-- init attack list(only for monster, etc)
		if not self:IsPlayer() then
			if cfg.attkLst then
				for k, aid in ipairs(cfg.attkLst) do
					if aid == 0 then
						table.insert(self._attackLst, 0);
					else
						local skill = nil
						if cfg.skills[aid] then
							skill = self._skills[cfg.skills[aid]];
						end
						if skill then
							table.insert(self._attackLst, cfg.skills[aid]);
						else
							table.insert(self._attackLst, 0);
						end
					end
				end
			end
		else
			self:InitPlayerAttackList()
		end
	end

	if resetBinds then
		self._bindSkills = { };
	end
end

function i3k_hero:LoadDIYSkill(CurrentSkillID,KungfuData)
	local Skillcfg = KungfuData[CurrentSkillID].diySkillData
	local DIYshowID = Skillcfg.skillActionID %1000 + self._id *1000
	local DIYcfg = i3k_db_create_kungfu_showargs_new[DIYshowID];
	self._DIYSkillID = DIYshowID;
	local scfg = self:normalizeDIYcfg(DIYcfg,CurrentSkillID,KungfuData)
	local skill = require("logic/battle/i3k_skill");
	if skill then
		self._DIYSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
	end
end

function i3k_hero:LoadSpiritSkill()
	local cooltimes = { };
	if self._spiritSkill then
		if not self._spiritSkill:CanUse() then
			cooltimes[self._spiritSkill._id] = self._spiritSkill._coolTick
		end
	end
	--驻地精灵特殊技能
	if self:GetEntityType() == eET_Player then
		--local spiritSkills = g_i3k_game_context:getHideWeaponSkills()
		local isOpen = g_i3k_db.i3k_db_get_faction_spirit_is_open()
		if isOpen then
			local skill = require("logic/battle/i3k_skill");
			local skillId = i3k_db_faction_spirit.spiritCfg.skillId
			local spiritSkillCfg = i3k_db_skills[skillId]
			if skill and spiritSkillCfg then
				local skillItem = skill.i3k_skill_create(self, spiritSkillCfg, 1, 0, skill.eSG_Skill);
				if cooltimes[skillId] then
					skillItem:CalculationCoolTime(cooltimes[skillId]);
				end
				self._spiritSkill = skillItem
			end
		end
	end
end

function i3k_hero:get_range_fix(role_id,range_type,range)
	local range_arg1 = 0
	local range_arg2 = 0
	if role_id == 4 or role_id == 5 or role_id == 7 then
		-- 若是弓手，则对距离进行修正
		if range_type == 2 then
			range_arg1 = (range - 100) * 2 + 200  -- 单体距离 = (原始距离 - 50) * 2 + 200
			range_arg2 = 0
		elseif range_type == 6 then
			range_arg1 = (range - 100) * 2 + 200 -- 矩形距离 = (原始距离 - 100) * 2 + 200
			range_arg2 = 150                     --弓手或医生时，矩形宽度只有150厘米
		elseif range_type == 5 then
			range_arg1 = (range - 50) * 2 + 200  -- 扇形距离 = (原始距离 - 50) * 2 + 200
			range_arg2 = 60                      --弓手或医生时，扇形只有60度
		elseif range_type == 3 then              --圆形距离 = 原始距离 + 250
			range_arg1 = range + 250
			range_arg2 = 0
		else
			range_arg1 = range
			range_arg2 = 0
		end
	else
		if range_type == 2 then
			range_arg1 = range                   -- 若不是弓手或医生，则range不变
			range_arg2 = 0
		elseif range_type == 6 then
			range_arg1 = range
			range_arg2 = 200                     -- 若不是弓手或医生，则矩形宽度为200
		elseif range_type == 5 then
			range_arg1 = range
			range_arg2 = 120                     -- 若不是弓手或医生，扇形角度为120
		elseif range_type == 3 then
			range_arg1 = range
			range_arg2 = 0
		else
			range_arg1 = range
			range_arg2 = 0
		end
	end
	return range_arg1,range_arg2
end

function i3k_hero:normalizeDIYcfg(cfg,CurrentSkillID,KungfuData)
	local Skillcfg = KungfuData[CurrentSkillID]
	local attackTime = 1
	local DIYSkillData = Skillcfg.diySkillData
	local DIYcfg = i3k_db_skills[9999999];
	DIYcfg.name = ""
	if Skillcfg.name then
		DIYcfg.name = Skillcfg.name
	end
	if Skillcfg.iconId then
		DIYcfg.icon = Skillcfg.iconId
	end
	DIYcfg.scope.type = cfg.attackType
	if DIYcfg.scope.type == 2 then
		local fix = self:get_range_fix(cfg.profession,DIYcfg.scope.type,DIYSkillData.scope[1])
		DIYcfg.scope.arg1 = fix
	elseif DIYcfg.scope.type == 3 then
		local fix = self:get_range_fix(cfg.profession,DIYcfg.scope.type,DIYSkillData.scope[1])
		DIYcfg.scope.arg1 = fix
	elseif DIYcfg.scope.type == 4 then
		DIYcfg.scope.arg1 = DIYSkillData.scope[1]
		DIYcfg.scope.arg2 = DIYSkillData.scope[2]
	elseif DIYcfg.scope.type == 5 then
		local fix1,fix2 = self:get_range_fix(cfg.profession,DIYcfg.scope.type,DIYSkillData.scope[1])
		DIYcfg.scope.arg1 = fix1
		DIYcfg.scope.arg2 = fix2
		DIYcfg.scope.arg3 = DIYSkillData.scope[3]
	elseif DIYcfg.scope.type == 6 then
		local fix1,fix2 = self:get_range_fix(cfg.profession,DIYcfg.scope.type,DIYSkillData.scope[1])
		DIYcfg.scope.arg1 = fix1
		DIYcfg.scope.arg2 = fix2
	end
	DIYcfg.duration = cfg.duration
	DIYcfg.attack.time = cfg.duration
	DIYcfg.basecfg = cfg
	return DIYcfg;
end

function i3k_hero:InitPlayerAttackList()
	if self:IsPlayer() then
		self._attackLst = { };
		-- init attack list(only for self)
		local _, heroUseSkills = g_i3k_game_context:GetRoleSkills()
		local _, useUniqueSkill = g_i3k_game_context:GetRoleUniqueSkills()

		local normalskill = {}
		if heroUseSkills then
			for k, v in ipairs(heroUseSkills) do
				local scfg = i3k_db_skills[v];
				if scfg and scfg.useorder > 1 then
					local nskill = {order = scfg.useorder,skill = v}
					table.insert(normalskill,nskill);
				end
			end
		end

		if #normalskill > 0 then
			local exp = SelectExp[5];
			exp(normalskill);
		end
		if useUniqueSkill then
			local _skill_data = i3k_db_skills[useUniqueSkill];
			if _skill_data then
				table.insert(self._attackLst,_skill_data.id)
			end
		end

		for k,v in ipairs(normalskill) do
			table.insert(self._attackLst, v.skill);
		end
		if self._DIYSkill then
			table.insert(self._attackLst, 9999999);
		end

		if self._anqiSkill then
			table.insert(self._attackLst, self._anqiSkill._id);
		end
--[[		if self._spiritSkill then
			table.insert(self._attackLst, self._spiritSkill._id)
		end--]]
	end
end

function i3k_hero:BindSkills(skills)
	self._bindSkills = { };
	if skills then
		for k, v in ipairs(skills) do
			for k1, v1 in pairs(self._skills) do
				if v == v1._id then
					self._bindSkills[k] = k1;

					break;
				end
			end
		end
	end
end

function i3k_hero:BindSkill(skill, slot)
	if skill then
		for k1, v1 in ipairs(self._skills) do
			if skill == v1._id then
				self._bindSkills[slot] = k1;

				break;
			end
		end
	end
end

function i3k_hero:OnSkillUpgradeLvl(sid, lvl)
	self:InitSkills(false);
	self:UpdateTalentEffector(self._properties);
	self:UpdatePassiveProp()
end

function i3k_hero:OnSkillUpgradeRealm(sid, realm)
	self:InitSkills(false);
	self:UpdateTalentEffector(self._properties);
	self:UpdatePassiveProp()
end

function i3k_hero:OnUniqueSkillUpgradeLvl(sid, lvl)
	self:InitSkills(false);
	self:UpdateTalentEffector(self._properties);
end

function i3k_hero:OnUniqueSkillUpgradeRealm(sid, realm)
	self:InitSkills(false);
	self:UpdateTalentEffector(self._properties);
end

function i3k_hero:OnStopAction(action)
	BASE.OnStopAction(self, action);

	if self:IsPlayer() then
	--	i3k_log("action", action, "stoped");
	end
end

-- 目前用于召唤
local gChildSpawnEffIdx = 1;
function i3k_hero:AddChild(child, spawn_eff)
	if child and not child:IsDead() then
		if child._summonID then
			if not self._childs[child._summonID] then
				self._childs[child._summonID] = { };
			end

			table.insert(self._childs[child._summonID], child);
		end


		local world = i3k_game_get_world()
			if world then
				world:AddEntity(child);
		end

		if spawn_eff then
			child:PlayHitEffect(spawn_eff)

		end
	end
end

function i3k_hero:GetSpecialChild(sid)
	return self._childs[sid];
end

function i3k_hero:ClsChilds()
	if self._childs then
		for k1, v1 in pairs(self._childs) do
			for k2, v2 in ipairs(v1) do
				local world = i3k_game_get_world()
				world:RmvEntity(v2)
				v2:Release();
			end
		end
	end

	self._childs = { };
end

function i3k_hero:TrySequentialSkill(skill)
	if not self:InDisableAttackState() and (self._useSkill == skill and skill:IsSequenceSkill()) then
		local _skill = skill:GetSequenceSkill();
		if _skill and skill._id~=_skill._id then
			skill:NextSequence();

			--self._useSkill = _skill;

			self._seq_skill.valid	= true;
			self._seq_skill.parent	= skill;
			self._seq_skill.skill	= _skill;
		end

		return true;
	end

	return false;
end

-- only for maunal handle
function i3k_hero:MaunalAttack(id)
	local res = false;
	self:ClearFindwayStatus()
	local _skill = nil;

	if self._superMode.valid then
		_skill = self._weapon.skills[self._superMode.attacks];
	elseif self._missionMode.valid then
		if id == 0 then
			local missionType = self._missionMode.type
			local typeTb = {
				[g_TASK_TRANSFORM_STATE_PEOPLE]			= self._missionMode.attacks,
				[g_TASK_TRANSFORM_STATE_SUPER]			= self._missionMode.skills,
				[g_TASK_TRANSFORM_STATE_CAR]			= self._missionMode.skills,
				[g_TASK_TRANSFORM_STATE_METAMORPHOSIS]	= self._missionMode.attacks,
				[g_TASK_TRANSFORM_STATE_CHESS]			= self._missionMode.attacks,
			}
			if typeTb[missionType] then
				self._missionMode.attacksIdx = self._missionMode.attacksIdx + 1
				if self._missionMode.attacksIdx > # self._missionMode.attacks then
					self._missionMode.attacksIdx = 1;
				end
				_skill = typeTb[missionType][self._missionMode.attacksIdx];
			end
			
		else
			_skill = self._missionMode.skills[id];
		end
	elseif g_i3k_game_context:GetWorldMapType() == g_CATCH_SPIRIT then
		_skill = self._catchSpiritSkills[id]
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
				self:TestBreakAttack(_skill);
				self._maunalSkill = _skill;
			end
			res = true;
		else
			if not self:TrySequentialSkill(_skill) then
				self._PreCommand = id;
			end
		end
	end
	return res;
end

function i3k_hero:ResetMaunalAttack()
	self._maunalSkill = nil;
end

-- 普通攻击
function i3k_hero:GetAttackSkill()
	return self._attacks[self._attackIdx];
end

function i3k_hero:ResetAttackIdx() -- 重置普攻索引
	self._attackIdx	= 1;
end

function i3k_hero:IsInSuperMode()
	return self._superMode.valid
end
function i3k_hero:IsInMissionMode()
	return self._missionMode.valid
end

function i3k_hero:SuperMode(enable)
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(self._weapon.id)
	if enable and self._weapon and self._weapon.valid then
		self:UpdateProperty(ePropID_sp, 1, 0, true, false, true);
		self:Checkunride()
		self:OnSuperMode(true);
		self:UpdateWeaponTalentProps()
		local animation = g_i3k_game_context:GetSelectWeaponMaxAnimation()
		if animation then
			g_i3k_game_context:OnStuntAnimationChangeHandler(animation,false)
		end
		if self._AutoFight then
			self:ClearAutofightTriggerSkill()
		end
	else
		self:OnSuperMode(false);
		self:UpdateWeaponTalentProps()
		if self._AutoFight then
			self:AddAutofightTriggerSkill()
		end
	end
	self._triMgr:PostEvent(self, eTEventChange, 3, self._weapon.id, isOpen == 1);
	self._superMode.ticks = 0;
end

function i3k_hero:OnSuperMode(enable)
	self._superMode.cache.valid = enable;
	self:changeWeaponDeform()
	if self:IsResCreated() then
		local ismoveing = self._behavior:Test(eEBMove)
		self:ClearAttckState()
		self:ChangeCombatEffect(self._combatType)
		if ismoveing then
			self:Play(i3k_db_common.engine.defaultRunAction, -1);
		else
			self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
		end
		self._superMode.attacks = 1;
		if enable then
			for k, v in pairs(self._weapon.skills) do
				v:OnReset();
			end
			self:DetachWeaponSoul()
			self:ClearEquipEffect()
			self:ClearCombatEffect(self)
			if not self._superMode.valid then
				if self._syncRpc and self:IsPlayer() then
					local func = function()
						i3k_sbean.motivate_weapon()
					end
					g_i3k_game_context:UnRide(func, true)
					return;
				end
				self._superMode.valid = true;
			end
			if self._weapon.deform.type == 1 then -- 武器模型
				self:ChangeEquipFacade(1, self._weapon.deform.args);
			elseif self._weapon.deform.type == 2 then -- 人物模型
				self:ChangeModelFacade(self._weapon.deform.args);
			elseif self._weapon.deform.type == 3 then -- 特效
			end
			if self._weapon and self._weapon.valid and self._weapon.id then
				local cfg = i3k_db_shen_bing[self._weapon.id]
				if cfg then
					local scfg = i3k_db_skills[cfg.lightSkillID];
					if scfg then
						local skill = require("logic/battle/i3k_skill");
						if skill then
							self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
						end
					end
				end
			end
		else
			self:AttachEquipEffect();
			if self._superMode.valid then
				self._superMode.valid = false
			end
			self:AttachWeaponSoul()
			if self._weapon.deform.type == 1 then -- 武器模型
				self:RestoreEquipFacade(1);
			elseif self._weapon.deform.type == 2 then -- 人物模型
				self:RestoreModelFacade();
			elseif self._weapon.deform.type == 3 then -- 特效
			end

			local scfg = i3k_db_skills[self._cfg.dodgeSkill];
			
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				
				if skill then
					self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);					
					local wearEquip = g_i3k_game_context:GetWearEquips()
					
					for k,v in pairs(wearEquip) do
						if v.equip then
							for i,e in ipairs(v.equip.legends) do
								if i == 3 and e ~= 0 then
									local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(v.equip.equip_id)
									local eCfg = i3k_db_equips_legends_3[equip_t.partID][e]
									
									if eCfg and eCfg.type == 5 then
										self._dodgeSkill:ChangeSkillTick(eCfg.args[1])
										break
									end
								end
							end
						end
					end
				end
			end			
		end

		if self:IsPlayer() then
			self:UpdateSteedSpiritSpeed(enable)
			g_i3k_game_context:OnSuperModeChangedHandler(g_i3k_game_context:IsInSuperMode())
		end
	end
end

-- 良驹之灵改变神兵变身时速度
function i3k_hero:UpdateSteedSpiritSpeed(enable)
	if enable then
		local speed = g_i3k_game_context:getSteedSpiritChangeSpeed()
		if speed ~= 0 then
			self._isSteedSpiritChangSpeed = true
			self:UpdateProperty(ePropID_speed, 1, speed, true, false, true);
		end
	else
		if self._isSteedSpiritChangSpeed then
			self._isSteedSpiritChangSpeed = false
			self:UpdateProperty(ePropID_speed, 1, self._cfg.speed, true, false, true);
		end
	end
end

function i3k_hero:PlaySocialAction(id,init)
	if self._missionMode.valid then
		if self:IsPlayer() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(350));
		end
		return false;
	end
	if self._superMode.valid then
		if self:IsPlayer() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(350));
		end
		return false;
	end

	if self:CheckAbnormalState() then
		if self:IsPlayer() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(350));
		end
		return false;
	end

	self:ClearFindwayStatus()
	local cfg = i3k_db_social[id]
    local alist = {}
	if init then
		if #cfg.actions > 0 then
            table.insert(alist, {actionName = cfg.actions[#cfg.actions], actloopTimes = cfg.times[#cfg.actions]})
		end
	else
		for k,v in pairs(cfg.actions) do
			local name = cfg.actions[k]
			if name == "attackstand" and self._combatType > 0 then
				name = boxerActionList[self._combatType]
			end
            table.insert(alist, {actionName = name, actloopTimes = cfg.times[k]})
		end
	end
	self:PlayActionList(alist, 1)
end

function i3k_hero:CheckAbnormalState()
	local abNormalTb = {
		[eEBSpasticity] = true,
		[eEBAttack]		= true,
		[eEBShift]		= true,
		[eEBStun]		= true,
		[eEBSleep]		= true,
		[eEBRoot]		= true,
		[eEBFreeze]		= true,
		[eEBPetrifaction] = true,
	}
	return self:TestBehaviorStateMap(abNormalTb)
end

function i3k_hero:CheckDead()
	if self._behavior:Test(eEBGotodead) then
		return false;
	end

	if self._behavior:Test(eEBUndead) then
		return false;
	end

	return true;
end

function i3k_hero:MissionMode(enable, id, endTime, isHuanXing)
	if self._superMode.valid then
		self:OnSuperMode(false);
		local animation = g_i3k_game_context:GetSelectWeaponMaxAnimation()
		if animation then
			g_i3k_game_context:OnStuntAnimationChangeHandler(animation,false)
		end
	end
	if not isHuanXing then
		self:Checkunride()
	end
	if self._AutoFight then
		self:ClearAutofightTriggerSkill()
	end
	
	--幻形变身特殊处理
	if enable and  self._missionMode.valid and self._missionMode.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS then		
		self:OnMissionMode(false)
	end
		
	if enable and not self._missionMode.valid then
		self._missionMode = { cache = { valid = false }, valid = false,attrvalid = false  };
		self._missionMode.id = id;
		--self._missionMode.valid	= true;
		--上面注释是因为下面self:OnMissionMode(enable);这个方法里会执行 这里重复了但是为了解决神兵状态下工程车变身bug，
		--在OnAsyncModelChanged 里利用这个flag判断是否执行变身
		local now_time = i3k_game_get_time()
		if endTime > now_time then
			self._missionMode.attrvalid = true;
		end
		self._missionMode.endTime = endTime
		-- init weapon skills
		self._missionMode.skills	= { };
		self._missionMode.attacks	= { };
		local mcfg = i3k_db_missionmode_cfg[id]
		self._missionMode.type = mcfg.type
		self._missionMode.speedodds = mcfg.speedodds
		if self._missionMode.type  == g_TASK_TRANSFORM_STATE_METAMORPHOSIS then
			local rideID = g_i3k_game_context:getUseSteed()
			if rideID ~= 0 then
				local speed = i3k_db_steed_cfg[rideID].speed
				
				self._missionMode.speedodds = speed
			else
				self._missionMode.speedodds = self._cfg.speed
			end		
		end
		
		
		self._missionMode.mcfg = mcfg
		for k, v in ipairs(mcfg.attacks) do
			local scfg = i3k_db_skills[v];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
					if _skill then
						self._missionMode.attacks[k] = _skill;
					end
				end
			end
		end
		for k, v in ipairs(mcfg.skills) do
			local scfg = i3k_db_skills[v.skillid];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(self, scfg, v.skilllvl, 0, skill.eSG_Skill);
					if _skill then
						self._missionMode.skills[k] = _skill;
					end
				end
			end
		end
		self:InitMissionAttackList()
		if self._missionMode.type ~= 2 then
			self._missionMode.deform = mcfg.modelId
		elseif self._missionMode.type == 2 then
			local gender = self._gender
			local wcfg = i3k_db_shen_bing[mcfg.modelId];
			if gender == eGENDER_MALE then
				self._missionMode.deform	= wcfg.changeArgs
			else
				self._missionMode.deform	= wcfg.changeArgsF
			end
		end
	else
		self:ClearMissionattr()
	end
	self:OnMissionMode(enable);
end

function i3k_hero:GetMissionEndTime()
	return self._missionMode.endTime
end

function i3k_hero:InitMissionAttackList()
	self._missionMode.skillList = { };
	-- init attack list(only for self)
	local missionskill = {}
	for k, v in pairs(self._missionMode.skills) do
		local scfg = v._cfg
		if scfg and scfg.useorder >= 1 then
			local nskill = {order = scfg.useorder,skill = v}
			table.insert(missionskill,nskill);
		end
	end

	if #missionskill > 0 then
		local exp = SelectExp[5];
		exp(missionskill);
	end

	for k,v in ipairs(missionskill) do
		table.insert(self._missionMode.skillList, v.skill);
	end
end

function i3k_hero:OnMissionMode(enable)
	self._missionMode.cache.valid = enable;

	if self:IsResCreated() then
		self:ClearAttckState();
		self._missionMode.attacksIdx = 0;
		self._missionMode.skillIdx = 1;
		local missionType = self._missionMode.type
		local missionTypeTable = {
			[g_TASK_TRANSFORM_STATE_PEOPLE] = true,
			[g_TASK_TRANSFORM_STATE_SUPER] = true,
			[g_TASK_TRANSFORM_STATE_SKULL] = true,
			[g_TASK_TRANSFORM_STATE_METAMORPHOSIS] = true,
			[g_TASK_TRANSFORM_STATE_CHESS] = true,
			[g_TASK_TRANSFORM_STATE_SPY]	= true,
		}
		if missionTypeTable[missionType] then
			if enable then
				for k, v in pairs(self._missionMode.skills) do
					v:OnReset();
				end
				
					local ismoveing = self._behavior:Test(eEBMove)
					self:ClearAttckState();
					if ismoveing then
						self:Play(i3k_db_common.engine.defaultRunAction, -1);
					else
						self:Play(i3k_db_common.engine.defaultStandAction, -1);
					end
				--幻形清除打坐
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS then
					g_i3k_game_context:SetAutoFight(false)--清自动攻击
				end
				
				self:ClearEquipEffect()
				self:DetachFlyingEquip()
				self._missionMode.valid = true;
				
				self:ChangeModelFacade(self._missionMode.deform);
				if self._missionMode and self._missionMode.valid and self._missionMode.type == g_TASK_TRANSFORM_STATE_SUPER then --神兵
					local cfg = i3k_db_shen_bing[self._missionMode.mcfg.modelId]
					if cfg then
						local scfg = i3k_db_skills[cfg.lightSkillID];
						if scfg then
							local skill = require("logic/battle/i3k_skill");
							if skill then
								self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
							end
						end
					end
				end
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS then --幻形
					g_i3k_game_context:SetAutoFight(false)
					local rideEffectID = i3k_db_steed_common.rideEffectID
					if rideEffectID then
						self:PlayHitEffect(rideEffectID)
					end
				end
				
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_SKULL then --决战荒漠
					self:PlaySkullReviveEffect(i3k_db_desert_battle_base.reviveEffectID)
				end
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_CHESS then --楚汉之争
					self:OnInitBaseProperty(self._properties)
					self:UpdateChessProps()
					self:AttachChessFlag()
					self:ClsTalents()
					self:SetChuhanTitle()
				end
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_SPY then --密探风云
					self:RmvAiComp(eAType_MOVE)
				end
				local speed = self._missionMode.speedodds
				self:UpdateProperty(ePropID_speed, 1, speed, true, false, true);
			else
				self:DetachChessFlag()
				self:AttachEquipEffect();
				self._missionMode.valid = false
				self:UpdateProperty(ePropID_speed, 1, self._cfg.speed, true, false, true);
				self:RestoreModelFacade();
				if self._missionMode and  self._missionMode.type == g_TASK_TRANSFORM_STATE_SUPER then
					local scfg = i3k_db_skills[self._cfg.dodgeSkill];
					if scfg then
						local skill = require("logic/battle/i3k_skill");
						if skill then
							self._dodgeSkill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
							-- if cooltimes[self._cfg.dodgeSkill] then
							-- 	self._dodgeSkill:CalculationCoolTime(cooltimes[self._cfg.dodgeSkill]);
							-- end
						end
					end
				end
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS then
					local rideEffectID = i3k_db_steed_common.rideEffectID
					if rideEffectID then
						self:PlayHitEffect(rideEffectID)
					end
				end
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_CHESS then
					self:OnInitBaseProperty(self._properties)
					self:UpdateProperties()
					self:UpdateTalentEffector()
				end
				if self._missionMode.type == g_TASK_TRANSFORM_STATE_SPY then
					self:AddAiComp(eAType_MOVE)
					g_i3k_game_context:setSpyStoryTransformId(0)
				end
			end
		elseif self._missionMode.type == g_TASK_TRANSFORM_STATE_ANIMAL then
			if enable then
				local ismoveing = self._behavior:Test(eEBMove)
				if ismoveing then
					self:Play(i3k_db_common.engine.defaultRunAction, -1);
				else
					self:Play(i3k_db_common.engine.defaultStandAction, -1);
				end
				local speed = self._missionMode.speedodds
				self:UpdateProperty(ePropID_speed, 1, speed, true, false, true);
				self._missionMode.valid = true;
				local modelID = i3k_engine_check_is_use_stock_model(self._missionMode.deform)
				if modelID then
					local mcfg = i3k_db_models[modelID]
					self:SetVehicleInfo(mcfg.path, i3k_db_steed_common.LinkPoint, i3k_db_steed_common.LinkRolePoint);
					self:Mount();
					if self._entity and self._title and self._title.node then
						self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
					end
				end			else
				self:UpdateProperty(ePropID_speed, 1, self._cfg.speed, true, false, true);
				self:Unmount();
				if self._entity and self._title and self._title.node then
					self._entity:AddTitleNode(self._title.node:GetTitle(), self._rescfg.titleOffset);
				end
				self._missionMode.valid = false;
			end
		elseif self._missionMode.type == g_TASK_TRANSFORM_STATE_CARRY then
			if enable then
				local speed = self._missionMode.speedodds
				self:UpdateProperty(ePropID_speed, 1, speed, true, false, true);
				self._missionMode.valid = true;
				local deform = self._missionMode.deform
				local modelID = deform ~= -1 and i3k_engine_check_is_use_stock_model(deform) or deform
				if modelID then
					self:CarryItem(modelID);
				end
			else
				self:UpdateProperty(ePropID_speed, 1, self._cfg.speed, true, false, true);
				self._missionMode.valid = false;
				self:UnCarryItem();
			end
		elseif self._missionMode.type == g_TASK_TRANSFORM_STATE_CAR then
			if enable then
				for k, v in pairs(self._missionMode.skills) do
					v:OnReset();
				end

				self:ClearEquipEffect()
				self:DetachFlyingEquip()
				self._missionMode.valid = true;
				self:UpdateProperty(ePropID_speed, 1, self._missionMode.speedodds, true, false, true);
				local value = g_i3k_game_context:getDefenceWarCarMaxHP()
				self:UpdateHP(value)
				self:ChangeModelFacade(self._missionMode.deform);
				g_i3k_game_context:SetAutoFight(false)
			else
				self._missionMode.valid = false
				self:UpdateProperty(ePropID_speed, 1, self._cfg.speed, true, false, true)
				self:RestoreModelFacade();

				if not self:IsDead() then
					self:UpdateHP(self:GetPropertyValue(ePropID_maxHP))
				end
			end

			self:OnMaxHpChangedCheck()
		end

		if enable then
			self:DetachWeaponSoul()
			self:ClearCombatEffect()
		else
			self:AttachWeaponSoul()
			self:PlayCombatActionAndEffectByMissionOver()
		end

		if self:IsPlayer() then
			g_i3k_game_context:OnMissionModeChangedHandler(self._missionMode.id,self._missionMode.valid)
			self:UpdateMissionModeProps()
		end
	end
end
--主要用于任务变身结束后对拳师特效和动作的处理
function i3k_hero:PlayCombatActionAndEffectByMissionOver()
	if self:CanPlayCombatTypeAction() then
		self:ChangeCombatEffect(self._combatType)
		local ismoveing = self._behavior:Test(eEBMove)
		if ismoveing then
		    self:Play(i3k_db_common.engine.defaultRunAction, -1);
		else
		    self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
		end
	end
end
function i3k_hero:ClearCombatEffect()
	if self._combatTypeEffect > 0 then
		self:OnStopChild(self._combatTypeEffect)
		self._combatTypeEffect = 0
	end
end
--创建楚汉头顶
function i3k_hero:SetChuhanTitle()
	local id = g_i3k_db.i3k_db_chess_get_props_for_model(self._forceType, self._forceArm)
	if not id then return end
	local martialFlag = i3k_db_chess_generals[id];
	if self._title.node and not self._title.chuhanImg  then
		local titleIcon = g_i3k_db.i3k_db_get_scene_icon_path(martialFlag.chuhanImg)
		self._title.chuhanImg = self._title.node:AddImgLable(-0.5, 1, -1, 1,  titleIcon);
	end
end

function i3k_hero:CheckMissionRide(enable)
	if self._missionMode.valid and self._missionMode.type == 3 then
		if enable then
			if self._missionMode and self._missionMode.deform then
				local modelID = i3k_engine_check_is_use_stock_model(self._missionMode.deform)
			if modelID then
				local mcfg = i3k_db_models[modelID]
				self:SetVehicleInfo(mcfg.path, i3k_db_steed_common.LinkPoint, i3k_db_steed_common.LinkRolePoint);
				self:Mount();
				if self._entity and self._title and self._title.node then
					self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
					end
				end
			end
		else
			self:Unmount();
			if self._entity and self._title and self._title.node then
				self._entity:AddTitleNode(self._title.node:GetTitle(), self._rescfg.titleOffset);
			end
		end
	elseif self._missionMode.valid and self._missionMode.type == 4 then
		if enable then
			self:CarryItem(self._missionMode.deform);
		else
			self:UnCarryItem();
		end
	elseif self._missionMode.valid and self._missionMode.type == 5 then
		if not self._unifyMode.valid then
			if self._missionMode.valid then
				self:MissionMode(false)
			end

			self:OnUnifyMode(true)
		end

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefenceWarBattle, "updataUnrideCarBtState", false)
	end
end

function i3k_hero:ClearMissionattr()
	self._missionMode.attrvalid = false
	self._missionMode.endTime = 0
	self:UpdateMissionModeProps()
end

function i3k_hero:UpdateMissionModeProps(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_MissionMode,false,ePropChangeType_Base);
		v:Set(0, ePropType_MissionMode,false,ePropChangeType_Percent);
	end
	
	--[[if self._missionMode.attrvalid and self._missionMode.id and self._missionMode.id ~= 0 then
		local mcfg = i3k_db_missionmode_cfg[self._missionMode.id]
		for k, v in pairs(mcfg.props) do
			local prop1 = _props[v.Propid];
			if prop1 then
				prop1:Set(prop1._valueMM.Base + v.Propvalue , ePropType_MissionMode,false,ePropChangeType_Base);
			end
		end
	end
	self:OnMaxHpChangedCheck()]]
end

function i3k_hero:UpdateMetamorphosisProps(props)
	local _props = props or self._properties;
	-- reset all missionmode properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Metamorphosis,false,ePropChangeType_Base);
		v:Set(0, ePropType_Metamorphosis,false,ePropChangeType_Percent);
	end
	local id = g_i3k_game_context:GetCurMetamorphosis()
	if id and id ~= 0  then		
		local cfg = i3k_db_metamorphosis[id];
		for k1 = 1,2 do
			local prop1 = _props[cfg["property"..k1.."Id"]];
			if prop1 then
				prop1:Set(prop1._valueHX.Base + cfg["property"..k1.."Value"], ePropType_Metamorphosis,false,ePropChangeType_Base);
			end
		end
	end
end


function i3k_hero:UpdateClanChildProps(props)
	local _props = props or self._properties;
	-- reset all missionmode properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_ClanChild,false,ePropChangeType_Base);
		v:Set(0, ePropType_ClanChild,false,ePropChangeType_Percent);
	end

	local ClanChild = g_i3k_game_context:GetClanAttrData()
	if ClanChild then
		if ClanChild.ssAddHarm then
			local prop1 = _props[ePropID_atkH];
			if prop1 then
				prop1:Set(prop1._valueCC.Base + ClanChild.ssAddHarm , ePropType_ClanChild,false,ePropChangeType_Base);
			end
		end
		if ClanChild.xfAddHarm then
			local prop1 = _props[ePropID_atkC];
			if prop1 then
				prop1:Set(prop1._valueCC.Base + ClanChild.xfAddHarm , ePropType_ClanChild,false,ePropChangeType_Base);
			end
		end
		if ClanChild.sbAddHarm then
			local prop1 = _props[ePropID_atkW];
			if prop1 then
				prop1:Set(prop1._valueCC.Base + ClanChild.sbAddHarm , ePropType_ClanChild,false,ePropChangeType_Base);
			end
		end
		if ClanChild.qxAddHarm then
			local prop1 = _props[ePropID_maxHP];
			if prop1 then
				prop1:Set(prop1._valueCC.Base + ClanChild.qxAddHarm , ePropType_ClanChild,false,ePropChangeType_Base);
			end
		end
	end


	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateChessProps(props)
	local _props = props or self._properties;
	if self._missionMode.id  then
		local _fromType
		local id = g_i3k_db.i3k_db_chess_get_props_for_model(self._forceType, self._forceArm )
		if not id then return end
		local cfgProps =  i3k_db_chess_generals[id].chessProperties
		if cfgProps then
			for k, v in pairs(cfgProps) do
				local  pro = _props[v.id]
				pro:Set(v.value, ePropType_Base)
			end
		end
	end
end
--添加
function i3k_hero:AttachChessFlag()
	local id = g_i3k_db.i3k_db_chess_get_props_for_model(self._forceType, self._forceArm)
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
--楚汉
function i3k_hero:DetachChessFlag()
	if self._curChessFlag then
		self._entity:RmvHosterChild(self._curChessFlag);
		self._curChessFlag = nil
	end
end
function i3k_hero:UpdateLastUseTime(lastUseTime)
	local totalTime = g_i3k_game_context:GetTotalSuperTime()
	if totalTime and lastUseTime then
		if totalTime >= lastUseTime then
			self._updateWeapTime = 0;
			self._updateWeapTime = totalTime - lastUseTime;
		end
	end
end

function i3k_hero:UpdateSpecialSuperMode(dTick)
	local totalTime = g_i3k_game_context:GetTotalSuperTime()
	if totalTime then
		if not self._isCanSpecialWean then
			self._updateWeapTime = self._updateWeapTime  + dTick * i3k_engine_get_tick_step();
		end
		if g_i3k_game_context:getPromptlyWead() then
			g_i3k_game_context:setPromptlyWead(false);
			self._isCanSpecialWean = false;
		end
		if self._updateWeapTime > totalTime and (not g_i3k_game_context:getPromptlyWead()) then
			self._isCanSpecialWean = true;
		end
	end
end

function i3k_hero:isCanPromptlySuper()
	local totalTime = g_i3k_game_context:GetTotalSuperTime()
	if totalTime and self._isCanSpecialWean then
		return true
	end
	return false
end

function i3k_hero:UpdateSuperMode(dTick)
	if self._superMode.valid then
		for k, v in pairs(self._weapon.skills) do
			v:OnLogic(dTick);
		end
		self._superMode.ticks = self._superMode.ticks + dTick * i3k_engine_get_tick_step();
		if self._superMode.ticks > self._weapon.ticks then
			local world = i3k_game_get_world()
			if not world._syncRpc then
				self:SuperMode(false);
				return ;
			end
		end
		if self._weapon.ticks - self._superMode.ticks < 5000 then
			--给UI发特效
		end
		g_i3k_game_context:OnWeaponEnergyChangedHandler(i3k_get_is_tournament_weapon() and self._weapon.ticks or self._weapon.ticks - self._superMode.ticks, self._weapon.ticks)
	end
end

function i3k_hero:UpdateMissionMode(dTick)
	if self._missionMode.valid then
		for k, v in pairs(self._missionMode.skills) do
			v:OnLogic(dTick);
		end
		for k, v in pairs(self._missionMode.attacks) do
			v:OnLogic(dTick);
		end
	end
end

function i3k_hero:AddWeaponTicks()
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(self._weapon.id)
	if isOpen == 1 then
		local info = i3k_db_shen_bing_unique_skill[self._weapon.id]
		for _,v in pairs(info) do
			if v.uniqueSkillType == 15 then--延长变身时间
				local curparameters = v.parameters
				if g_i3k_game_context:isMaxWeaponStar(self._weapon.id) then
					curparameters = v.manparameters
				end
				local wcfg = i3k_db_shen_bing[self._weapon.id];
				self._weapon.ticks = wcfg.keepTime;
				self._weapon.ticks = self._weapon.ticks + curparameters[1];
			end
		end
	end
	--神兵觉醒的延长时间
	if self._weapon.awakeExtendTime then
		self._weapon.ticks = self._weapon.ticks + (self._weapon.awakeExtendTime[self._weapon.id] or 0)
	end
end

--设置神兵觉醒延长的变身时间
function i3k_hero:SetWeaponAwakeExtendTicks(weaponID,time)
	self._weapon.awakeExtendTime = self._weapon.awakeExtendTime or {}
	self._weapon.awakeExtendTime[weaponID] = time or 0
end

function i3k_hero:UseWeapon(wid)
	self._weapon.valid = false;
	self._weapon.id = wid
	local selfhero = true
	local gender = eGENDER_MALE
	local hero = i3k_game_get_player_hero();
	if g_i3k_game_context then
		local roledata = g_i3k_game_context._roleData.curChar
		if roledata then
			gender = roledata._gender
		end
	end
	if self._weapon.id and self._weapon.id ~= 0 then
		self:changeWeaponDeform()
	end
	if hero._guid ~= self._guid then
		selfhero = false
		gender = self._gender
	end

	if g_i3k_game_context then
		local wps = g_i3k_game_context._shenBing.all;
		if wid and wps then
			local weapon = wps[wid];
			if weapon or not selfhero then
				if not selfhero then
					weapon = {slvl = 1}
				end
				local wcfg = i3k_db_shen_bing[wid];
				if wcfg then
					self._weapon.valid	= true;
					self._weapon.id		= wid;

					-- init weapon skills
					self._weapon.skills	= { };

					local skills = { { id = wcfg.skill1ID, lvl = 1 }, { id = wcfg.skill2ID, lvl = 1 }, { id = wcfg.skill3ID, lvl = 1 }, { id = wcfg.skill4ID, lvl = 1 } };
					local scfgs = g_i3k_game_context:GetShenBingUpSkillData()
					if scfgs then
						--local scfg = scfgs[weapon.slvl];
						local scfg = scfgs[wid]
						if scfg then
							skills[1].lvl = scfg[1];
							skills[2].lvl = scfg[2];
							skills[3].lvl = scfg[3];
							skills[4].lvl = scfg[4];
						end
					end

					for k, v in ipairs(skills) do
						local scfg = i3k_db_skills[v.id];
						if scfg then
							local skill = require("logic/battle/i3k_skill");
							if skill then
								local _skill = skill.i3k_skill_create(self, scfg, v.lvl, 0, skill.eSG_Skill);
								if _skill then
									self._weapon.skills[k] = _skill;
								end
							end
						end
					end

					self._weapon.ticks	= wcfg.keepTime;
					if self._weapon.awakeExtendTime then
						self._weapon.ticks = self._weapon.ticks + (self._weapon.awakeExtendTime[self._weapon.id] or 0)
					end
					self:creatWeaponManualSkill(wid)
				end
			end
		end
	end
end


function i3k_hero:UpdateWeapon(qlvl, slvl)
	if g_i3k_game_context and self._weapon.valid then
		local wps = g_i3k_game_context._shenBing.all;
		if wps then
			local weapon = wps[self._weapon.id];
			if weapon then
				local wcfg = i3k_db_shen_bing[self._weapon.id];
				if wcfg then
					-- init weapon skills
					self._weapon.skills	= { };

					local skills = { { id = wcfg.skill1ID, lvl = 1 }, { id = wcfg.skill2ID, lvl = 1 }, { id = wcfg.skill3ID, lvl = 1 }, { id = wcfg.skill4ID, lvl = 1 } };
					local scfgs = g_i3k_game_context:GetShenBingUpSkillData()
					if scfgs then
						local scfg = scfgs[wid]
						if scfg then
							skills[1].lvl = scfg[1];
							skills[2].lvl = scfg[2];
							skills[3].lvl = scfg[3];
							skills[4].lvl = scfg[4];
						end
					end

					for k, v in ipairs(skills) do
						local scfg = i3k_db_skills[v.id];
						if scfg then
							local skill = require("logic/battle/i3k_skill");
							if skill then
								local _skill = skill.i3k_skill_create(self, scfg, v.lvl, 0, skill.eSG_Skill);
								if _skill then
									self._weapon.skills[k] = _skill;
								end
							end
						end
					end

					self._weapon.ticks	= wcfg.keepTime;
					self:AddWeaponTicks()
					self:changeWeaponDeform()
					self:creatWeaponManualSkill(self._weapon.id)
				end
			end
		end
	end
end

function i3k_hero:changeWeaponDeform()
	local gender = g_i3k_game_context:GetRoleGender()
	local isOpen , mastery , form = g_i3k_game_context:GetShenBingUniqueSkillData(self._weapon.id)
	local changeType, args = g_i3k_db.i3k_db_get_weapon_deform(gender, self._weapon.id, form)
	self._weapon.deform	= { type = changeType, args = args };
end

function i3k_hero:SyncMulRide(leaderId, memberIDs, members)
	local roleID = g_i3k_game_context:GetRoleId()
	self._mulHorse.leaderId = leaderId
	self._mulHorse.isLeader = roleID == leaderId
	self._mulHorse.members = members
	self._mulHorse.memberIDs = memberIDs

	for i, e in ipairs(memberIDs) do
		if e == roleID then
			self._mulHorse.mulPos = i
			self:SetMulHorseState(true)
			break
		end
	end
	if self:IsLeaderMemberState() then
		g_i3k_game_context:OnMulRideChangedHandler()
	end
end

function i3k_hero:MulMemberChanged(index, member) --多人坐骑成员变换
	if member then
		local memberID = member.overview.id
		self._mulHorse.memberIDs[index] = memberID
		self._mulHorse.members[memberID] = member
	else
		local memberID = self._mulHorse.memberIDs[index]
		self._mulHorse.memberIDs[index] = 0
		self._mulHorse.members[memberID] = nil
	end
	g_i3k_game_context:OnMulRideChangedHandler()
end

function i3k_hero:GetMulLeaderId()
	return self._mulHorse.leaderId
end

function i3k_hero:GetMulIsLeader()
	return self._mulHorse.isLeader
end

function i3k_hero:GetMulMemberInfo()
	return self._mulHorse.memberIDs, self._mulHorse.members
end

function i3k_hero:GetMulMemberSum()
	local count = 0
	for _, v in ipairs(self._mulHorse.memberIDs) do
		if v ~= 0 then
			count = count + 1
		end
	end
	return count
end

function i3k_hero:GetMulPos()
	return self._mulHorse.mulPos
end

function i3k_hero:IsHaveMulMember()
	return self:GetMulMemberSum() > 0
end

function i3k_hero:IsLeaderMemberState()
	return self._mulHorse.isLeader and self:IsHaveMulMember()
end

function i3k_hero:IsMulMemberState()
	return not self._mulHorse.isLeader and self:IsOnMulRide()
end

function i3k_hero:LeaveMulRide(position)
	self._ride.valid = false
	self._ride.onMulHorse = false
	self._mulHorse = {leaderId = 0, isLeader = false, memberIDs = {}, member = {}}; --清除多人骑乘数据
	if g_i3k_game_context:GetIsSpringWorld() then
		self:PlaySpringIdleAct()
	else
		self:Play(i3k_db_common.engine.defaultStandAction, -1)
	end
	g_i3k_game_context:OnRideChangedHandler()
	g_i3k_game_context:OnMulRideChangedHandler()
end

function i3k_hero:ResetMulHorse()
	self._mulHorse = {leaderId = 0, isLeader = false, memberIDs = {}, member = {}, mulPos = 1}
end

function i3k_hero:VerifyMulMember(roleID) --是否是自己车上的乘客
	local isMemeber = false
	for _, e in pairs(self:GetLinkEntitys()) do
		if e:GetGuidID() == roleID then
			isMemeber = true
			break
		end
	end
	return isMemeber
end

function i3k_hero:SetLeaderEntity(entity)
	self._mulEntity = entity
end

function i3k_hero:OnAddLinkChild() --司机OnAsyncLoaded成功后，再将自己挂载到车上
	if self._mulEntity then
		self._mulEntity:AddLinkChild(self, self._mulHorse.mulPos, i3k_db_steed_common.LinkRolePoint, Engine.SVector3(0.0, 0.0, 0.0))
		self._mulEntity = nil;
	end
end

function i3k_hero:UseRide(rid)
	if g_i3k_game_context then
		if rid ~= 0 and i3k_db_steed_cfg[rid] then
			self._ride.id = rid
			if self:IsOnRide() then
				self:UpdateProperty(ePropID_speed, 1, i3k_db_steed_cfg[rid].speed, true, false, true);
				self._ride._rideSpeed = i3k_db_steed_cfg[rid].speed;
			end
		end
	end
end

function i3k_hero:setRideCurShowID(curShowID)
	local rcfg = i3k_db_steed_huanhua[curShowID]
	if rcfg then
		self._ride.curShowID = curShowID
		self._ride.deform = {args = rcfg.modelId, horseLinkPoint = rcfg.horseLinkPoint, memberOffSet = rcfg.memberOffSet};
		self:updateRideIsCanFight()
	end
end

function i3k_hero:updateRideIsCanFight()
	if self._ride and self._ride.curShowID and i3k_db_steed_huanhua[self._ride.curShowID] then
		local rcfg = i3k_db_steed_huanhua[self._ride.curShowID]
		if rcfg then
			local fightData = g_i3k_game_context:getSteedFightShowIDs()
			self._rideFight = fightData[self._ride.curShowID]
		end
	end
end

function i3k_hero:GetRideIsFight()
	return self._rideFight
end

function i3k_hero:SetRideCoolTime(coolTime)
	self._ride.ticks = coolTime
end

function i3k_hero:UpdateRideCoolTime(dTick)
	if self._ride.ticks ~= 0 then
		self._ride.ticks = self._ride.ticks - dTick * i3k_engine_get_tick_step();
		if self._ride.ticks < 0 then
			self._ride.ticks = 0
		end
	end
end

function i3k_hero:isRideSpecialShow()
	if self._ride.curShowID then
		local rcfg = i3k_db_steed_huanhua[self._ride.curShowID];
		if rcfg.ChangeSpecialAction and rcfg.ChangeSpecialAction ~= 0 then
			return rcfg.ChangeSpecialAction;
		end
		return false;
	end
	return false
end

function i3k_hero:RidePlayAction(args)
	local cfg = i3k_db_models[args.link_spr_id];
	effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_Ride_%s_effect_%d", self._guid, args.link_spr_id), args.hoster_link, args.spr_link, 0.0, cfg.scale);
	self._entity:LinkChildPlay(effectID, -1, true);
	self._rideSpecialSpr[effectID] = effectID;
end

function i3k_hero:ClearRidePlay()
	for k,v in pairs(self._rideSpecialSpr) do
		if self._entity then
			self._entity:RmvHosterChild(v);
		end
	end
	self._rideSpecialSpr = {};
end

function i3k_hero:ChangeRidePlayAction(Pos, specialId, entity)
	local args = nil;
	if Pos == g_HS_First then
		args =  i3k_horse_special_args[specialId].player_link[g_HS_First];
		self:RidePlayAction(args);
	elseif Pos == g_HS_Second then
		args = i3k_horse_special_args[specialId].player_link[g_HS_Second];
		for k,v in ipairs(args) do
			self:RidePlayAction(v);
		end
	elseif Pos == g_HS_Third then
		args = i3k_horse_special_args[specialId].player_link[g_HS_Third];
		self:RidePlayAction(args);
	elseif Pos == g_HS_Fourth then
		args = i3k_horse_special_args[specialId].player_link[g_HS_Fourth];
		self:RidePlayAction(args);
	end
end

function i3k_hero:OnRideMode(enable,notips)
	self._ride.cache.valid = enable;
	if self:IsResCreated() then
		if i3k_db_common.debugswitch.rideopen ~= 0 then
			if self._ride and self._ride.deform then
				if enable then
					local effectID = 0;
					if self:isRideSpecialShow() then
						self:ChangeRidePlayAction(g_HS_First, self:isRideSpecialShow())
					end
					if not g_i3k_game_context:GetWeaponSoulCurHide() then
						self:DetachWeaponSoul()
					end
					self:ClearAttckState();
					
					if not self._ride.valid then
						if self:IsPlayer() and not notips then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(194));
						end

						local cfg = i3k_db_steed_cfg[self._ride.id]
						self:UpdateProperty(ePropID_speed, 1, cfg.speed, true, false, true);
						self._ride._rideSpeed = cfg.speed;
						self._ride.valid = true;
						if self._behavior:Test(eEBMove) then
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
							local rideEffectID = i3k_db_steed_common.rideEffectID
							if rideEffectID then
								self:PlayHitEffect(rideEffectID)
							end
						end
					end
				else
					if self._ride.valid then
						local world = i3k_game_get_world()
						if world and not world._syncRpc then
							self:ClearAttckState();
						end
						if self:IsPlayer() and not notips then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(195));
						end
						if self._rideSpecialSpr then
							self:ClearRidePlay()
						end
						self._ride.valid = false
						self._ride.onMulHorse = false
						self._mulHorse.isLeader = false
						self:DetachWeaponSoul()
						self:AttachWeaponSoul()
						if not g_i3k_game_context:GetIsSpringWorld() then
							self:UpdateProperty(ePropID_speed, 1, self._cfg.speed, true, false, true);
						else
							self:InSpring()
						end
						self:Unmount();
						if self._entity and self._title and self._title.node then
							self._entity:AddTitleNode(self._title.node:GetTitle(), self._rescfg.titleOffset);
							self:DetachTitleSPR();
							self:AttachTitleSPR();
						end
						local unrideEffectID = i3k_db_steed_common.unrideEffectID
						if unrideEffectID then
							self:PlayHitEffect(unrideEffectID)
						end
					end
				end
				self:UpdateSteedSpiritShow(enable)
				if self:GetDigStatus() ~= 0 then
					self:DigMineCancel()
				end
				self:ChangeCombatEffect(self._combatType)
				g_i3k_game_context:OnRideChangedHandler(enable)
				g_i3k_game_context:OnMulRideChangedHandler()
			end
		end
	end
end

function i3k_hero:ClearMulHorse()
	local world = i3k_game_get_world()
	for i, e in pairs(self:GetLinkEntitys()) do
		if e then
			e:RemoveLinkChild()
			if not e:IsPlayer() then
				e:EnableOccluder(false);
				e:SetPos(e._curPos, true);
			end
			world:AddEntity(e);
		end
	end
	self:ReleaseLinkChils()
	self:ResetMulHorse() --清除多人坐骑数据
end

function i3k_hero:ClearOtherMulHorse()
	local world = i3k_game_get_world()
	for i, e in pairs(self:GetLinkEntitys()) do
		if e then
			e:RemoveLinkChild()
			if not e:IsPlayer() then
				e:EnableOccluder(false);
				e:SetPos(e._curPos, true);
			end
			if e:IsPlayer() then
				world:AddEntity(e);
			else
				world:ReleaseEntity(e)
			end
		end
	end
	self:ReleaseLinkChils()
	self:ResetMulHorse() --清除多人坐骑数据
end

function i3k_hero:SetRideSpiritCurShowID(showID)
	self._rideCurSpiritShowID = showID
end

function i3k_hero:GetRideSpiritCurShowID()
	if self:IsPlayer() then
		return g_i3k_game_context:getSteedSpiritCurShowID()
	end

	return self._rideCurSpiritShowID
end

function i3k_hero:UpdateSteedSpiritShow(enable)
	if enable then
		self:DetachSteedSpiritShow()
		self:AttachSteedSpiritShow()
	else
		self:DetachSteedSpiritShow()
	end
end

function i3k_hero:AttachSteedSpiritShow()
	local showID = self:GetRideSpiritCurShowID()
	local isShow = self:IsPlayer() and g_i3k_game_context:getSteedSpiritIsHide() or false
	local isMember = self:IsPlayer() and self:IsMulMemberState() or false
	local isUnlock = true
    if self:IsPlayer() then
        isUnlock = g_i3k_game_context:getIsUnlockSteedSpirit()
    end
	if i3k_db_steed_fight_spirit_show[showID] and isUnlock and (self:IsOnRide() and not isMember) and not isShow then
		local id = i3k_db_steed_fight_spirit_show[showID].sceneModelID
		local modelID = i3k_engine_check_is_use_stock_model(id)
		if modelID then
			local cfg = i3k_db_models[modelID]
			if cfg and self._entity then
				local effectID = 0;
				effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_steed_spirit_show_%s", self._guid), "", "", 0.0, cfg.scale);
				self._rideCurSpiritShow = effectID;
				self._entity:LinkChildSelectAction(effectID, i3k_db_steed_fight_base.standAction)
				self._entity:LinkChildPlay(effectID, -1, true);
				self._entity:LinkChildShow(effectID, true)
			end
		end
	end
end

function i3k_hero:DetachSteedSpiritShow()
	if self._entity and self._rideCurSpiritShow then
		self._entity:RmvHosterChild(self._rideCurSpiritShow);
		self._rideCurSpiritShow  = nil;
	end
end

function i3k_hero:SteedSpiritShowPlayAction(actionName)
	if self._entity and self._rideCurSpiritShow then
		self._entity:LinkChildSelectAction(self._rideCurSpiritShow, actionName or i3k_db_steed_fight_base.superAttackAction)
		self._entity:LinkChildPlay(self._rideCurSpiritShow, -1, true);
	end
end

function i3k_hero:DodgeSkill()
	local res = false;
	if self._dodgeSkill then
		if self:CanUseSkill(self._dodgeSkill) then
			if not self._behavior:Test(eEBDisDodgeSkill) then
				self:TestBreakAttack(self._dodgeSkill);
				self._maunalSkill = self._dodgeSkill;
				res = true;
			end
		else
			if not self:TrySequentialSkill(self._dodgeSkill) then
				self._PreCommand = ePreTypeDodgeSkill;
			else
				res = true;
			end
		end
	end
	if self:IsPlayer() and self._autoUseDidge then
		g_i3k_game_context:SetAutoFight(true)
		self._autoUseDidge = false
	end
	return res;
end

function i3k_hero:UniqueSkill()
	local res = false
		if self._uniqueSkill then
			if self:CanUseSkill(self._uniqueSkill) then
				self:TestBreakAttack(self._uniqueSkill);
				self._maunalSkill = self._uniqueSkill;
				res = true;
			else
				if not self:TrySequentialSkill(self._uniqueSkill) then
					self._PreCommand = ePreTypeUniqueSkill
				else
					res = true
				end
			end
		end
	if res and not self._syncRpc then
		local skill = g_i3k_game_context:GetHammerSkillByTypeOnWearEquip(g_EQUIP_SKILL_TYPE_GOD_POWER_BLESS)
		if next(skill) then
			for k, v in pairs(skill) do
				local args = i3k_db_equip_temper_skill[k][v].args
				local curLvl = self._weaponBless.getCurLevel()
				self._weaponBless.setCurLevel(curLvl + args[1])
				i3k_sbean.role_weaponbless_state.handler({state = 1})--冒字
			end
		end
	end
	return res;
end

function i3k_hero:DIYSkill()
	local res = false;
	self:ClearFindwayStatus()
	if self._DIYSkill then
		if self:CanUseSkill(self._DIYSkill) then
			self:TestBreakAttack(self._DIYSkill);
			self._maunalSkill = self._DIYSkill;

			res = true;
		else
			self._PreCommand = ePreTypeDIYSkill;
		end
	end

	return res;
end

function i3k_hero:AnqiSkill()
	local res = false;
	self:ClearFindwayStatus()

	if self._anqiSkill then
		if self:CanUseSkill(self._anqiSkill) then
			self:TestBreakAttack(self._anqiSkill);
			self._maunalSkill = self._anqiSkill;

			res = true;
		else
			self._PreCommand = ePreTypeAnqiSkill;
		end
	end

	return res;
end

function i3k_hero:SpiritSkill()
	local res = false;
	self:ClearFindwayStatus()

	if self._spiritSkill then
		if self:CanUseSkill(self._spiritSkill) then
			self:TestBreakAttack(self._spiritSkill);
			self._maunalSkill = self._spiritSkill;

			res = true;
		else
			self._PreCommand = ePreTypeSpiritSkill;
		end
	end

	return res;
end
function i3k_hero:UseSkill(skill)
	if self:IsPlayer() then
		self:SetIsOperationed(true)
	end

	local res = false;
	if self:CanUseSkill(skill) then
		local valid = true;
		if self._behavior:Test(eEBSilent) then
			if skill and (not self._superMode.valid and skill._gtype == eSG_Skill) then
				valid = false;
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(168))
			end
		end

		if valid then
			if skill then
				--i3k_log_stack()
				res = true;
				self:PrivateMapWeaponMaster()
				local func = function()
					self._curSkill = skill;
					if self:IsPlayer() and skill and skill._specialArgs.blink then
						self._isBlinkSkill = true;
					end
					if self._curSkill then
						if self._curSkill:CanUse() then
							self:UpdateAlives();
							if skill and skill._isRunNow then
								self:TestBreakAttack(skill);
							end

							if self:IsPlayer() and not self:IsAttacksSkill(skill) and skill._gtype ~= eSG_TriSkill then
								self:ResetAttackIdx()
							end
						end
					end
				end
				if self:GetEntityType() == eET_Player then
					local world = i3k_game_get_world()
					if world and world._syncRpc then
						g_i3k_game_context:UnRide(func);
					else
						g_i3k_game_context:UnRideNotSyncRpc(func)
					end
				else
					if func then
						func()
					end
				end
			else
				self._curSkill = skill;
			end

		end
	end

	return res;
end

function i3k_hero:IsAttacksSkill(skill)
	for _, e in ipairs(self._attacks) do
		if e._id == skill._id then
			return true
		end
	end
	return false
end

function i3k_hero:PushAttackState()
	if self._attackStack == 0 then
		self:UpdateAlives();
	end
	self._attackStack = self._attackStack + 1;
end

function i3k_hero:PopAttackState()
	self._attackStack = math.max(0, self._attackStack - 1);
end

function i3k_hero:UpdateAttackState(dTick)
	if self._attackStack > 0 then
		self._attackTick = 10;
	else
		self._attackTick = math.max(0, self._attackTick - dTick);
	end
end

function i3k_hero:InAttackState()
	return self._curSkill or self._useSkill;-- or self._attackStack > 0 or (self._attackTick ~= 0);
end

function i3k_hero:OnRandomResetSkill()
	local skills = { };
	for bid, sid in pairs(self._bindSkills) do
		if sid then
			local skill = self._skills[sid];
			if skill:CanUse() then
				table.insert(skills, { bid = bid, skill = skill });
			end
		end
	end

	if self._anqiSkill and self._anqiSkill:CanUse() then
		table.insert(skills, {anqi = true, skill = self._anqiSkill});
	end

	if self._DIYSkill and self._DIYSkill:CanUse() then
		table.insert(skills, { diy = true, skill = self._DIYSkill });
	end
	if self._dodgeSkill and self._dodgeSkill:CanUse() then
		table.insert(skills, { dodge= true, skill = self._dodgeSkill });
	end
	if self._uniqueSkill and self._uniqueSkill:CanUse() then
		table.insert(skills,{ unique = true, skill = self._uniqueSkill})
	end
	if #skills > 0 then
		local rnd = i3k_engine_get_rnd_u(1, #skills);
		local skill = skills[rnd];

		skill.skill:Use(eSStep_Unknown);
	end
end

function i3k_hero:OnDesSkillCoolTime(skillID,coolTime)
	if SKILL_DIY == skillID then
		self._DIYSkill:DesCoolTime(coolTime)
	elseif self._dodgeSkill._id == skillID then
		self._dodgeSkill:DesCoolTime(coolTime)
	elseif self._uniqueSkill and self._uniqueSkill._id == skillID then
		self._uniqueSkill:DesCoolTime(coolTime)
	elseif self._ultraSkill._id == skillID then
		self._ultraSkill:DesCoolTime(coolTime)
	elseif self._anqiSkill and self._anqiSkill._id == skillID then
		self._anqiSkill:DesCoolTime(coolTime)
	elseif self._spiritSkill and self._spiritSkill._id == skillID then
		self._spiritSkill:DesCoolTime(coolTime)
	else
		for bid, sid in pairs(self._bindSkills) do
			if sid == skillID then
				local skill = self._skills[sid];
				skill:DesCoolTime(coolTime);
				break;
			end
		end
	end
end

function i3k_hero:OnRandomDesSkillCoolTime(coolTime)
	local skills = { };
	for bid, sid in pairs(self._bindSkills) do
		if sid then
			local skill = self._skills[sid];
			if not skill:CanUse() then
				table.insert(skills, { bid = bid, skill = skill });
			end
		end
	end

	if self._DIYSkill and not self._DIYSkill:CanUse() then
		table.insert(skills, { diy = true, skill = self._DIYSkill });
	end

	if self._anqiSkill and self._anqiSkill:CanUse() then
		table.insert(skills, {anqi = true, skill = self._anqiSkill});
	end

	if self._dodgeSkill and not self._dodgeSkill:CanUse() then
		table.insert(skills, { dodge= true, skill = self._dodgeSkill });
	end
	if self._uniqueSkill and self._uniqueSkill:CanUse() then
		table.insert(skills,{unique = true, skill = self._uniqueSkill });
	end

	if #skills > 0 then
		local rnd = i3k_engine_get_rnd_u(1, #skills);
		local skill = skills[rnd];
		skill.skill:DesCoolTime(coolTime);
	end
end

function i3k_hero:OnNetworkResetSkill(skillID)
	if SKILL_DIY == skillID then
		self._DIYSkill:Use(eSStep_Unknown);
	elseif self._dodgeSkill._id == skillID then
		self._dodgeSkill:Use(eSStep_Unknown);
	elseif self._uniqueSkill  and self._uniqueSkill._id == skillID then
		self._uniqueSkill:Use(eSStep_Unknown);
	elseif self._anqiSkill and self._anqiSkill._id == skillID then
		self._anqiSkill:Use(eSStep_Unknown);
	elseif self._spiritSkill and self._spiritSkill._id == skillID then
		self._spiritSkill:Use(eSStep_Unknown);
	else
		for bid, sid in pairs(self._bindSkills) do
			if sid == skillID then
				local skill = self._skills[sid];
				skill:Use(eSStep_Unknown);
				break;
			end
		end
	end
end

function i3k_hero:OnNetworkDesSkillCoolTime(skillID,coolTime)
	if SKILL_DIY == skillID then
		self._DIYSkill:DesCoolTime(coolTime)
	elseif self._dodgeSkill and self._dodgeSkill._id == skillID then
		self._dodgeSkill:DesCoolTime(coolTime)
	elseif self._uniqueSkill  and self._uniqueSkill._id == skillID then
		 self._uniqueSkill:DesCoolTime(coolTime)
	elseif self._anqiSkill and self._anqiSkill._id == skillID then
		self._anqiSkill:DesCoolTime(coolTime)
	elseif self._spiritSkill and self._spiritSkill._id == skillID then
		self._spiritSkill:DesCoolTime(coolTime)
	else
		for bid, sid in pairs(self._bindSkills) do
			if sid == skillID then
				local skill = self._skills[sid];
				skill:DesCoolTime(coolTime);
				break;
			end
		end
	end
end

function i3k_hero:OnBuffChanged(hoster)
	if hoster:IsPlayer() then
		local buffs = {}
		local aboveBuffs = {}
		for k,v in pairs(hoster._buffs) do
			if not v._cfg.isShowAbove then
				if v._endTime - v._timeLine > 0 then
					buffs[v._id] = v._endTime - v._timeLine
				elseif v._endTime == -1 then
					buffs[v._id] = -1
				end
			else
				table.insert(aboveBuffs, v._cfg)
			end
		end
		g_i3k_game_context:OnBuffChangedHandler(buffs)
		g_i3k_game_context:OnAboveBuffChangedHandler(aboveBuffs)
	end
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

function i3k_hero:OnEnableDodgeSkill(value)
	if self:IsPlayer() then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "onEnableDodgeSkill", value) -- ?
	end
end

-- 延长正面负面效果
function i3k_hero:OnProlongBuff(buff, value)
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

-- 延长浮空buff时长
function i3k_hero:ProlongFloationgBuff(prolongTime)
	for k, v in pairs(self._buffs) do
		if i3k_get_is_floating_buff(v._cfg) then
            local alist = {}
            table.insert(alist, {actionName = i3k_db_common.skill.floatSuspendStart, actloopTimes = 1})
            table.insert(alist, {actionName = i3k_db_common.skill.floatSuspendContinue, actloopTimes = -1})
			self:PlayActionList(alist, 1);
			if prolongTime and i3k_db_common.skill.extendLimitTimes > v:GetFloatingProlTimes() then
				v._endTime = v._endTime + prolongTime
				v:AddFloatingProlTimes()
			end
		end
	end
end

function i3k_hero:IsAttackable(attacker)
	for i,v in ipairs(attacker._alives[2]) do
		if self._guid == v.entity._guid then
			return true;
		end
	end
	for i,v in ipairs(attacker._alives[3]) do
		if self._guid == v.entity._guid then
			return true;
		end
	end

	return false;
end

function i3k_hero:CanAttack()
	local disAttackTb = {
		[eEBStun] = true,
		[eEBSleep] = true,
		[eEBScarecrow] = true,
		[eEBFreeze]	= true,
		[eEBPetrifaction] = true,
		[eEBRetreat] = true,
		[eEBPrepareFight] = true,
		[eEBFloating] = true,
	}

	return not self:TestBehaviorStateMap(disAttackTb);
end

function i3k_hero:CanMove()
	if not BASE.CanMove(self) then
		if self._AutoFight == true and self._PreCommand == ePreTypeClickMove then
			return true;
		else
			return false;
		end
	end
	local disCanMoveTb = {
		[eEBRoot] = true,
		[eEBSleep] = true,
		[eEBStun] = true,
		[eEBFreeze]	= true,
		[eEBPetrifaction] = true,
		[eEBSpasticity] = true,
		[eEBScarecrow] = true,
		[eEBShift] = true,
		[eEBPrepareFight] = true,
		[eEBFloating] = true,
	}

	return not self:TestBehaviorStateMap(disCanMoveTb);
end

function i3k_hero:InDisableAttackState()
	local disableAttackTb = {
		[eEBSleep] = true,
		[eEBStun] = true,
		[eEBFreeze] = true,
		[eEBPetrifaction] = true,
		[eEBSpasticity] = true,
		[eEBScarecrow] = true,
		[eEBShift] = true,
		[eEBPrepareFight] = true,
		[eEBFloating] = true,
	}

	return self:TestBehaviorStateMap(disableAttackTb);
end

function i3k_hero:TestBehaviorStateMap(stateMap)
	local res = false
	for k, v in pairs(stateMap) do
		if self._behavior:Test(k) then
			res = true
			break
		end
	end
	return res
end

function i3k_hero:CanUseSkill(skill)
	local isSameSkill = false
	if self._useSkill and skill then
		isSameSkill = self._useSkill._id==skill._id
	end
	local isInAttack = self._behavior:Test(eEBAttack) or self._behavior:Test(eEBDisAttack)
	if self:GetEntityType()==eET_Player then
		isInAttack = isInAttack and (skill and (isSameSkill or not skill._isRunNow))
	end
	local res = self:InDisableAttackState();

	if not skill then
		res = res or isInAttack;
	else
		res = res or not skill:CanUse() or isInAttack;
	end

	if self._ultraSkill and skill and self._ultraSkill._id == skill._id then
		self._skilldeny = 0;
	elseif self._skilldeny > 0 then
		res = true
	end

	return not self:IsDead() and not res;
end

function i3k_hero:ResetDamageRetrive()
	self._damageRetrive = 1;
end

function i3k_hero:ResetDamageDes()
	self._damageDes = 0
end

function i3k_hero:UpdateDamageDes(factor, propID)
	self._damageDes = self._damageDes + self:GetPropertyValue(propID) * factor
end

function i3k_hero:GetDamageDes()
	return self._damageDes or 0
end

function i3k_hero:ResetDamageAddition()
	self._damageAddition = 0
end

function i3k_hero:UpdateDamageAddition(factor, propID)
	self._damageAddition = self._damageAddition + self:GetPropertyValue(propID) * factor
end

function i3k_hero:GetDamageAddition()
	return self._damageAddition or 0
end

function i3k_hero:UpdateDamageRetrive(value)
	self._damageRetrive = self._damageRetrive + value;
end

function i3k_hero:GetDamageRetrive()
	return self._damageRetrive;
end

function i3k_hero:BlinkEndPos(pos)
	if pos then
		self._isBlink = true;
		self._blinkEndPos = pos;
	end
end

function i3k_hero:StartAttack(skill)
	local _force = true;
	local _skill = self._curSkill;
	if skill then
		_skill = skill;
		_force = false;
	end

	if _skill then
		_skill:Use(eSStep_Spell);

		if self:IsPlayer() then			
			local dodgeSecondSkillId = 0
			local dodgeFirstSkillId = 0
			local dodgeSkill = self._dodgeSkill
			
			if dodgeSkill then
				dodgeFirstSkillId = dodgeSkill._id
				
				if dodgeSkill._seq_skill.skills[1] then
					dodgeSecondSkillId = dodgeSkill._seq_skill.skills[1]._id
				end
			end		
			
			if dodgeSkill and _skill._id ~= dodgeFirstSkillId and _skill._id ~= dodgeSecondSkillId then
				if _skill._gtype ~= eSG_TriSkill and _skill._cfg.type ~= eSE_Buff then
					self:OnFightTime(0.01);
				end
			end
			if _skill._gtype ~= eSG_TriSkill and _skill._cfg.type ~= eSE_Buff then
				if self:IsOnRide() then
					--self:SetRide(false, true);
				end
			end
		end

		local player = i3k_game_get_player();
		local world = i3k_game_get_world();
		if self._syncRpc then
			if self:IsPlayer() then
				self._preautonormalattack = true;

				local target = self._target;

				if self._forceAttackTarget and not self._forceAttackTarget:IsDead() then
					target = self._forceAttackTarget;
				end

				local ownerID = 0;
				local targetID = 0;
				local targetType = 0;
				if target then
					targetType = target:GetEntityType();
					if targetType == eET_Mercenary then
						local guid = string.split(target._guid, "|");
						targetID = tonumber(guid[2])
						ownerID = tonumber(guid[3])
					elseif targetType == eET_Player then
						if target._guid ~= self._guid then
							local guid = string.split(target._guid, "|")
							targetID = tonumber(guid[2])
							if not world._fightmap then
								local mers = player:GetMercenaries();
								for k, v in pairs(mers) do
									if not v:IsDead() then
										v:AddEnmity(target)
									end
								end
							end
						end
					else
						local guid = string.split(target._guid, "|");
						targetID = tonumber(guid[2]);
					end
				end
				if _skill._itemSkillId~=0 then
					i3k_sbean.use_item_skill(_skill._itemSkillId, self._curPos, self._orientation, targetID, targetType, ownerID);
				elseif _skill._gameInstanceSkillId ~= 0 then
					i3k_sbean.role_usemapskill_Start(_skill._cfg.id, self._curPos, self._orientation, targetID, targetType, ownerID);
					g_i3k_game_context:addCatchSpiritMonsterSkill(_skill._cfg.id)
					--i3k_log("StartAttack skill ".._skill._cfg.id)
				elseif _skill._cfg.specialArgs and _skill._cfg.specialArgs.blink and self._isBlink then
					self._isBlink = false;
					i3k_sbean.blinkSkill(self, _skill._cfg.id, self._curPos, self._blinkEndPos, self._orientation, targetID, targetType, ownerID)
				elseif _skill._weaponManualId ~= 0 then
					i3k_sbean.use_weapon_trigskill()
				else
					i3k_sbean.map_useskill(self, _skill._cfg.id, self._curPos, self._orientation, targetID, targetType, ownerID);
				end
			end

			if self._hoster and self._hoster:IsPlayer() then
				local enmity = self:GetEnmities()

				local target = self._target or enmity[1];
				local targetID = 0;
				local ownerID = 0;
				local targetType = 0;
				local guid = string.split(self._guid, "|");
				if target then
					targetType = target:GetEntityType();

					if targetType == eET_Mercenary then
						local guid = string.split(target._guid, "|");
						targetID = tonumber(guid[2]);
						ownerID = tonumber(guid[3]);
					else
						local guid = string.split(target._guid, "|");
						targetID = tonumber(guid[2]);
					end
				end
				--宠物释放技能播放守护灵兽动画
				if self._linkItem then
					local skillId = self._curSkill and self._curSkill._id
					if skillId then
						local petId = self._id
						if g_i3k_db.i3k_db_is_skillId_pet_skill(petId, skillId) then
							self:PlayPetGuardAction("01attack01")
						end
					end
				end
				i3k_sbean.map_useskill(self, _skill._cfg.id, self._curPos, self._orientation, targetID, targetType, ownerID, guid[2]);
			end
		else
			if self:IsPlayer() then
				self._invisibleEnd = false;
				-- 取消隐身并附加隐身第一击效果
				if self._behavior:Test(eEBInvisible) then
					self._invisibleEnd = true;
					self:ClsBuffByBehavior(eEBInvisible);
				end
				self._preautonormalattack = true;
				if _skill._cfg.summonedId > 0 then
					local cfg = i3k_db_summoned[_skill._cfg.summonedId];
					if cfg then
						self:RemoveSummoned();
						self:CreateSummoned(self._skills, 1);
					end
				end

				if _skill._cfg.addsp > 0 then
					local cfg = i3k_db_fightsp[self._id];
					if cfg.affectType == 1 then
						local overlay = self:GetFightSp()

						if overlay >= 0 and overlay < cfg.overlays then
							overlay = overlay + _skill._cfg.addsp;
							if overlay > cfg.overlays then
								overlay = cfg.overlays;
							end

							self:UpdateFightSp(overlay);
						end
					elseif cfg.affectType == 2 then
						local petcount = player:GetPetCount();
						if petcount >= 0 and petcount < cfg.overlays then
							local lvl = 1;
							for k1, v1 in pairs(self._skills) do
								if v1._id == cfg.LinkSkill then
									lvl = v1._lvl;
								end
							end

							local creatnum = petcount + _skill._cfg.addsp;
							if creatnum > cfg.overlays then
								creatnum = cfg.overlays;
							end
							creatnum = creatnum - petcount;

							local xinfa = g_i3k_game_context:GetXinfa();
							local useXinfa = g_i3k_game_context:GetUseXinfa();
							local cfgID = cfg.affectID1;
							for k, v in pairs(self._talents) do
								if v._id == cfg.affectID2 then
									cfgID = cfg.value2[math.floor(v._lvl / 7) + 1];
								end
							end
							self:CreateFightSpCanYing(cfgID, creatnum, lvl);
							self:UpdateFightSpCanYing(petcount + creatnum);
						end
					end
				end

			end

			if self._target then
				if self:IsPlayer() then
					if _skill._gtype == eSG_Skill then
						--战斗能量条件3触发
						local talentadd = false
						local talentodds = 0
						local cfg = i3k_db_fightsp[self._id];
						if self._talents then
							for k, v in pairs(self._talents) do
								if v._id == cfg.TalentID then
									talentadd = true
									talentodds = cfg.TriProc2[math.floor(v._lvl / 7) + 1];

									break;
								end
							end
						end

						if self._behavior:Test(eEBFightSP) or talentadd then
							local add = 0
							if self._validSkills[tonumber(cfg.LinkSkill)] then
								add = tonumber(self._validSkills[tonumber(cfg.LinkSkill)].state) * tonumber(i3k_db_fightsp[self._id].SkillAdd)
							end

							for k, v in pairs(cfg.TriCond) do
								if tonumber(v) == 3 then
									local rollnum = i3k_engine_get_rnd_u(0, 10000);
									local odds = cfg.TriProc1 + add + talentodds;
									if rollnum < odds then
										local overlay = self:GetFightSp();
										if overlay >=0 and overlay <cfg.overlays then
											overlay = overlay + 1;
											self:UpdateFightSp(overlay)
										end
									end
								end
							end

							local wEquipID = i3k_engine_get_rnd_u(1, 8);
							local wequips = g_i3k_game_context:GetWearEquips();
							if wequips then
								local Equip =  wequips[wEquipID];
								if Equip and Equip.equip then
									if Equip.equip.naijiu ~= -1 then
										local durability = Equip.equip.naijiu;
										local eqcfg = i3k_db_common["equip"];
										if eqcfg then
											local ducfg = eqcfg["durability"];
											if ducfg then
												durability = durability - ducfg.perdec;
												if durability < 0 then
													durability = 0;
												end
											end
										end
										self:DesEquipDurability(wEquipID, durability);

										local args = { wid = wEquipID };
										i3k_sbean.sync_privatemap_durability(args);
									end
								end
							end
						end
					end

					if self._guid==i3k_game_get_player_hero()._guid then
						local ownerID = 0;
						local targetID = 0;
						local targetType = 0;
						local target = self._target
						targetType = target:GetEntityType();
						if targetType == eET_Mercenary then
							local guid = string.split(target._guid, "|");
							targetID = tonumber(guid[2])
							ownerID = tonumber(guid[3])
						elseif targetType == eET_Player then
							if target._guid ~= self._guid then
								local guid = string.split(target._guid, "|")
								targetID = tonumber(guid[2])
								local world = i3k_game_get_world()
								if not world._fightmap then
									local mers = i3k_game_get_player():GetMercenaries();
									for k, v in pairs(mers) do
										if not v:IsDead() then
											v:AddEnmity(target)
										end
									end
								end
							end
						else
							local guid = string.split(target._guid, "|");
							targetID = tonumber(guid[2]);
						end
						if _skill._itemSkillId~=0 then
							i3k_sbean.use_item_skill(_skill._itemSkillId, self._curPos, self._orientation, targetID, targetType, ownerID);
						end
					end
				end
			end
		end

		if _force then
			self._behavior:Set(eEBAttack);
		end

		local _m = require("logic/battle/i3k_attacker");
		local attacker = _m.i3k_attacker_create(self, _skill, { self._target }, not _force, false);
		if attacker then
			table.insert(self._attacker, attacker);
		end

		if _force and not _skill._canAttack then
			self._behavior:Set(eEBDisAttack);
		end

		if self._triMgr and _force then
			if self:IsPlayer() then
				local skilltype = 0
				local damagetype = self._curSkill._cfg.type

				if self._dodgeSkill and self._curSkill._id == self._dodgeSkill._id then
					skilltype = 2
				elseif self._curSkill._id == SKILL_DIY then
					skilltype = 3
				else
					for k,v in pairs(self._skills) do
						if self._curSkill._id == v._id then
							skilltype = 1
						end
					end
				end

				self._triMgr:PostEvent(self, eTEventSkill, skilltype, damagetype);
			end
		end

		if self._superMode.valid then
			while true do
				self._superMode.attacks = self._superMode.attacks + 1;
				if self._superMode.attacks > 4 then
					self._superMode.attacks = 1;
				end

				if self._weapon.skills[self._superMode.attacks] then
					break;
				end
			end
		else
			if _skill._gtype == eSG_Attack then
				--i3k_log_stack()
				self._attackIdx = self._attackIdx + 1;
				if self._attackIdx > #self._attacks then
					self._attackIdx = 1;
				end
			end
		end

		if _force then
			self._useSkill = self._curSkill;
			self._curSkill	= nil;
			self._maunalSkill = nil;
			self._target	= nil;
		end
		self:PushAttackState();

		return attacker;
	end

	return nil;
end

function i3k_hero:FinishAttack()
	local world = i3k_game_get_world();
	if world then
		local syncRpc = world._syncRpc;
		if syncRpc then

		else
			if self:GetEntityType() == eET_Monster then
				local mintime = g_i3k_game_context:getMonsterDeny_db(1)
				local maxtime = g_i3k_game_context:getMonsterDeny_db(2)

				local rnd = i3k_engine_get_rnd_f(mintime,maxtime);
				self._skilldeny = rnd
			end
		end
	end

	if self._hoster and self._hoster:IsPlayer() and self:GetEntityType() == eET_Mercenary then
		local mintime = self._cfg.skilldenymin
		local maxtime = self._cfg.skilldenymax
		local spirits = g_i3k_game_context:getPetSpiritsData(self._cfg.id)
		for _,v in ipairs(spirits) do
			if v.id ~= 0 then
				local sMin, sMax = g_i3k_game_context:GetMercenarySpirits(self._cfg.id, v.id, v.level, 2)
				if sMin then
					mintime = mintime - sMin
					maxtime = maxtime - sMax
				end
			end
		end

		local rnd = i3k_engine_get_rnd_f(mintime,maxtime);
		self._skilldeny = rnd
	end
	self._behavior:Clear(eEBAttack);
	self:PopAttackState();
end

function i3k_hero:StopAttack(skill, result, attackSuc)
	if skill then
		skill:Use(eSStep_End);
	end

	if attackSuc and skill then
		local func = function()
			self:UpdateProperty(ePropID_sp, 1, skill._data.addSP, false, false);
		end
		self:CheckUpdateSp(func)
	end

	if self._seq_skill and self._seq_skill.valid and self._seq_skill.parent == skill then
		self._seq_skill.valid = false;
	end

	if skill == self._useSkill then
		self._useSkill = nil;
	end
end

function i3k_hero:ClsAttacker(skillid)
	local attacker = self:CheckAttacker(skillid, self._attacker);
	if attacker then
		attacker:Release();
	end
end

function i3k_hero:ClsEffect()
	if self._entity then
		for k, v in pairs(self._hitEffectIDs) do
			self._entity:RmvHosterChild(v);
		end
		self._hitEffectIDs = { };
	end
end

function i3k_hero:ClsAttackers()
	--i3k_log("ClsAttackers"..self._guid)
	for k, v in ipairs(self._attacker) do
		v:Release();
	end
	self._attacker = { };
end

-- stype -1: all
function i3k_hero:BreakAttack(stype)
	local _type = -1;
	if stype then
		_type = stype;
	end

	local rmvs = { };
	for k, v in ipairs(self._attacker) do
		if (_type == -1) or (_type == v._stype) then
			v:Release();

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

function i3k_hero:SetTarget(target)
	if target then
		if self._target then
			if self._target._guid ~= target then
				if self:GetGroupType() ~= target:GetGroupType() then
					self:AddEnmity(target);
				end
			end
		else
			if self:GetGroupType() ~= target:GetGroupType() or self._PVPStatus == g_FreeMode then
				self:AddEnmity(target);
			end
		end
		local mapType = i3k_game_get_map_type()
		local mapTb = {
			[g_FORCE_WAR]	= true,
			[g_BUDO] 		= true,
			[g_FACTION_WAR] = true,
			[g_DEFENCE_WAR] = true,
			[g_DESERT_BATTLE] = true,
			[g_PRINCESS_MARRY] = true,
			[g_SPY_STORY]		= true,
		}

		if (mapTb[mapType] or i3k_get_is_tournament_weapon()) and target._forceType~=self._forceType then
			self:AddEnmity(target)
		end

		if self:GetEntityType() == eET_Player and target and target:GetEntityType() == eET_Monster then
			local guid = string.split(target._guid, "|");
			local targetID = tonumber(guid[2]);
			if not g_i3k_mmengine:CheckPath(i3k_vec3_to_engine(target._curPosE), i3k_vec3_to_engine(self._curPosE)) then
				i3k_sbean.change_target_pos(targetID);
			end
		end
	end

	self._target = target;
end

function i3k_hero:SetForceTarget(target)
	if not self:AddEnmity(target, true) then
		if self:IsPlayer() and self._onTargetChanged then
			if target and target:GetGroupType() ~= eGroupType_N then
				self._onTargetChanged(target);
			else
				self._onTargetChanged(nil);
			end
		end
	end
end

function i3k_hero:GetFollowTarget()
	return self._target;
end

function i3k_hero:OnSelected(val)
	BASE.OnSelected(self, val);
	if self:GetEntityType() == eET_Player then
		if val == false then
			g_i3k_game_context:OnCancelSelectHandler()
			return;
		end
		local maxhp = self:GetPropertyValue(ePropID_maxHP)
		local curhp = self:GetPropertyValue(ePropID_hp)
		local buffs = {}
		for k,v in pairs (self._buffs) do
			buffs[v._id] = v._endTime-v._timeLine
		end
		local guid = string.split(self._guid, "|")
		--[[
		if not self:IsPlayer() then
			g_i3k_game_context:OnSelectRoleHandler(tonumber(guid[2]), self._headiconID, self._name, self._lvl, curhp, maxhp, buffs, (self._bwtype or 0), self._ride.onMulHorse,self._sectID, self._gender, self._headBorder, self._buffDrugs, self._id)
		else
			g_i3k_game_context:OnSelectRoleHandler(tonumber(guid[2]), self._headiconID, self._name, self._lvl, curhp, maxhp, buffs, (self._bwtype or 0), self._ride.onMulHorse,self._sectID, self._gender, self._headBorder, self._buffDrugs, self._id, self._internalInjuryState.value, self._internalInjuryState.maxInjury)
			]]
		--[[
		else
			local world = i3k_game_get_world();
			if world then
			local entity = world:GetEntity(eET_Player, tonumber(guid[2]));
				if entity then
					g_i3k_game_context:OnSelectRoleHandler(tonumber(guid[2]), self._headiconID, self._name, self._lvl, curhp, maxhp, buffs, (self._bwtype or 0), self._ride.onMulHorse,self._sectID, self._gender, self._headBorder,self._id, entity._internalInjuryState.value, entity._internalInjuryState.maxInjury)
					if entity:IsDead() and bean.curInternalInjury > 0 then --可能要判断大于0 等于0没有意义 修改这里是为了城战工程车死亡后复活血量为0的bug lht
						entity._internalInjuryState.value = 0;
					end
				end
			end
		end
		]]
	end
end

function i3k_hero:OnMaxHpChangedCheck()
	local world = i3k_game_get_world()
	if i3k_game_get_map_type() == g_FIELD and self:IsPlayer()  then
		g_i3k_game_context:OnFightNpcStateChangedHandler(g_i3k_game_context:TestFightNpcState())
	end
	if world and not world._syncRpc then
		if self:GetPropertyValue(ePropID_hp) > self:GetPropertyValue(ePropID_maxHP) then
			self:UpdateProperty(ePropID_hp, 1, self:GetPropertyValue(ePropID_maxHP), false, false, true);
		end
	end
end

function i3k_hero:UpdateInternalInjury(val)
	self._internalInjuryState.value = val
	self._internalInjuryState.maxInjury = self:GetPropertyValue(ePropID_maxHP)--内伤值是以气血上限为比例
	if self:IsPlayer() then
		g_i3k_game_context:OnInternalInjuryDamageValueChangedHandler(self._internalInjuryState.value, self._internalInjuryState.maxInjury)
	end
	
	local selEntity = i3k_game_get_select_entity()
	if selEntity then
		if selEntity._guid == self._guid then
			g_i3k_game_context:OnTargetInternalInjuryChangedHandler(self._internalInjuryState.value, self._internalInjuryState.maxInjury)
		end
	end
end

function i3k_hero:UpdateHP(val)
	self._hp = val;
	self:OnPropUpdated(ePropID_hp, self._hp);
end

function i3k_hero:OnPropUpdated(id, value)
	BASE.OnPropUpdated(self, id, value);

	if id == ePropID_speed then
		-- 速度变化后更新寻路数据
		if self._agent then
			self._agent:SetSpeed(i3k_logic_val_to_world_val(value));
		end

		if self._entity then
			self._entity:SetActionSpeed(i3k_db_common.engine.defaultRunAction, value / self._cfg.speed);
			if self:GetEntityType() == eET_Player and self._iscarOwner == 1 and value <= g_i3k_game_context:GetEscortCarSpeed() then
					self:Play(i3k_db_common.engine.roleWalkAction, -1);
			elseif self._iscarOwner == 1 and self:GetEntityType() == eET_Player and not self._missionMode.valid and not self._superMode.valid then
				if self._behavior:Test(eEBMove) then
					self:Play(i3k_db_common.engine.defaultRunAction, -1)
				else
					self:Play(i3k_db_common.engine.defaultStandAction, -1)
				end
			end
		end
		local _, status = self:GetFindWayStatus()
		if status and status <= g_i3k_game_context:GetEscortCarSpeed() then
			self:SetFindWayTmpSpeed(g_i3k_game_context:GetEscortCarSpeed())
		end
		if self._velocity then
			self:SetVelocity(self._velocity);
		end
		-- 移动中更新速度属性 更新self._agent的速度
		if self._behavior:Test(eEBMove) then
			self:changMovingSpeedHander()
		end
	elseif id == ePropID_hp then

		if self._entity then
			self:UpdateBloodBar(value / self:GetPropertyValue(ePropID_maxHP));
		end

		local logic = i3k_game_get_logic();
		if logic then
			local selEntity = logic._selectEntity;
			if selEntity then
				if selEntity._guid == self._guid then
					g_i3k_game_context:OnTargetHpChangedHandler(value, self:GetPropertyValue(ePropID_maxHP))
				end
			end
			local world = i3k_game_get_world();
			local hero = i3k_game_get_player_hero();
			if hero then
				local damage = false
				if self:IsPlayer() then
					local roleInfo = g_i3k_game_context:GetRoleInfo();
					if roleInfo and roleInfo.curChar then
						if roleInfo.curChar._hp and roleInfo.curChar._hp > value then
							damage = true
						end
						roleInfo.curChar._hp = value;
					end
					if world and not world._syncRpc then
						local guid2 = string.split(self._guid, "|")
						i3k_sbean.privatemap_update_hp(self,self._hp,guid2[2])
					end
					local world = i3k_game_get_world()
					if world then
						world:CheckCustomRoles(self:GetGuidID())
					end
					g_i3k_game_context:OnHpChangedHandler(value, self:GetPropertyValue(ePropID_maxHP), damage)
				else
					local guid1 = string.split(hero._guid, "|")
					local guid2 = string.split(self._guid, "|")
					if world and not world._syncRpc then
						if self._entityType == eET_Mercenary then
							i3k_sbean.privatemap_update_hp(self,self._hp,guid2[2])
						end
					end
					if tonumber(guid1[2]) == tonumber(guid2[3]) then
						g_i3k_game_context:OnFightMercenaryHpChangedHandler(tonumber(guid2[2]), value, self:GetPropertyValue(ePropID_maxHP));
					end
				end
			end
		end
	elseif id == ePropID_maxHP then
		local roleInfo = g_i3k_game_context:GetRoleInfo();
		if roleInfo and roleInfo.curChar then
			if self._entity then
				local logic = i3k_game_get_logic();
				if logic then
					local selEntity = logic._selectEntity;
					if selEntity then
						if selEntity._guid == self._guid then
							g_i3k_game_context:OnTargetHpChangedHandler(self:GetPropertyValue(ePropID_hp), self:GetPropertyValue(ePropID_maxHP))
						end
					end

					local hero = i3k_game_get_player_hero();
					if hero then
						if self:IsPlayer() then
							local world = i3k_game_get_world()
							if world then
								world:CheckCustomRoles(self:GetGuidID())
							end
							g_i3k_game_context:OnHpChangedHandler(self:GetPropertyValue(ePropID_hp), self:GetPropertyValue(ePropID_maxHP))
						else
							local guid1 = string.split(hero._guid, "|")
							local guid2 = string.split(self._guid, "|")
							if tonumber(guid1[2]) == tonumber(guid2[3]) then
								if value then
									g_i3k_game_context:OnFightMercenaryHpChangedHandler(tonumber(guid2[2]), self:GetPropertyValue(ePropID_hp), value)
								else
									g_i3k_game_context:OnFightMercenaryHpChangedHandler(tonumber(guid2[2]), self:GetPropertyValue(ePropID_hp), self:GetPropertyValue(ePropID_maxHP))
								end
							end
						end

						if self:GetEntityType() == eET_Player then
							self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP));
						elseif self:GetEntityType() == eET_Mercenary then
							if value then
								self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / value);
							else
								self:UpdateBloodBar(self:GetPropertyValue(ePropID_hp) / self:GetPropertyValue(ePropID_maxHP));
							end
						end
					end
				end
			end
		end
	elseif id == ePropID_sp then
		local hero = i3k_game_get_player_hero()
		if hero then
			if self:IsPlayer() then
				if value then
					g_i3k_game_context:OnWeaponEnergyChangedHandler( value,self:GetPropertyValue(ePropID_maxSP))
				else
					g_i3k_game_context:OnWeaponEnergyChangedHandler(self:GetPropertyValue(ePropID_sp),self:GetPropertyValue(ePropID_maxSP))
				end
			else
				local guid1 = string.split(hero._guid, "|")
				local guid2 = string.split(self._guid, "|")
				if tonumber(guid1[2]) == tonumber(guid2[3]) then
					if value then
						g_i3k_game_context:OnFightMercenarySpChangedHandler(tonumber(guid2[2]),  value,self:GetPropertyValue(ePropID_maxSP))
					else
						g_i3k_game_context:OnFightMercenarySpChangedHandler(tonumber(guid2[2]), self:GetPropertyValue(ePropID_sp),self:GetPropertyValue(ePropID_maxSP))
					end
				end
			end
		end

		if self._onSPChanged then
			self._onSPChanged(value);
		end
	elseif id == ePropID_armorCurValue then
		i3k_log("ePropID_armorCurValue")
	end
end

function i3k_hero:AttachEquipEffect(equipInfo)
	local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	if self._superMode.cache.valid or weaponDisplay == g_FLYING_SHOW_TYPE then
		return
	end
	local wequips = g_i3k_game_context:GetWearEquips()
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

function i3k_hero:AttachEquipEffectByPartID(partID, effectIDs)
	if self._EquipEffects[partID] then
		for k, v in pairs(effectIDs) do
			if self._EquipEffects[partID][k] then
				return ;
			end
		end
		self:DetachEquipEffectByPartID(partID)
	end
	for k, v in pairs(effectIDs) do
		self:AttachEquipEffectData(partID, k)
	end
end

function i3k_hero:AttachEquipEffectData(partID, cfgID)
	local cfg = i3k_db_effects[cfgID];
	if cfg and self._entity then
		local effectID = -1;
		if cfg.hs == '' or cfg.hs == 'default' then
			effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_Equip_%s_effect_%d_%d", self._guid,partID, cfgID), "", "", 0.0, cfg.radius);
		else
			effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_Equip_%s_effect_%d_%d", self._guid,partID, cfgID), cfg.hs, "", 0.0, cfg.radius);
		end
		self._entity:LinkChildPlay(effectID, -1, true);
		if not self._EquipEffects[partID] then
			self._EquipEffects[partID] = {}
		end
		self._EquipEffects[partID][cfgID] = {effectID = effectID , cfgID = cfgID }
	end
end

function i3k_hero:DetachEquipEffectByPartID(partID)
	local EffectInfo = self._EquipEffects[partID]
	if self._entity and EffectInfo then
		for k, v in pairs(EffectInfo) do
			self._entity:RmvHosterChild(v.effectID);
		end
	end
	self._EquipEffects[partID] = nil;
end

function i3k_hero:updateWizard(dTick)
	local curWizardId = g_i3k_game_context:GetCurWizard()
	local wizarData = i3k_db_arder_pet[curWizardId]
	if self:isDaZuo() and not self._wizard[self._guid] then
		self:AttachWizard(wizarData);
	elseif not self:isDaZuo() and self._wizard[self._guid] then
		self:DetachWizard(self._guid)
	end
end

function i3k_hero:isDaZuo()
	if self._behavior:Test(eEBDaZuo) then
		return true;
	else
		return false;
	end
end

function i3k_hero:AttachTitleSPR()
	local isCreate = true;
	if self._hugMode.valid and not self._hugMode.isLeader then
		isCreate = false
	end
	if self._titleSprData and self._titleSprData.dynamicSPR > 0 and self._isHaveDynamic and isCreate then
		local cfg = i3k_db_models[self._titleSprData.dynamicSPR]
		if cfg and self._entity then
			local effectID = 0;
			if cfg.path then
				if self._ride and self._ride.valid and self._ride.deform and self._ride.deform.args then
					local modelID = i3k_engine_check_is_use_stock_model(self._ride.deform.args)
					local mcfg = i3k_db_models[modelID]
					if mcfg then
						effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_wizard_%s_effect_%d", self._guid, self._titleSprData.id), "", "", mcfg.titleOffset - 3.6, cfg.scale);
					end
				else
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_wizard_%s_effect_%d", self._guid, self._titleSprData.id), "", "", 0.0, cfg.scale);
				end
			end
			self._titleSpr = effectID;
			self:chageTitleAction(i3k_db_common.engine.defaultStandAction);
			self._entity:LinkChildShow(effectID, true)
		end
	end
end

function i3k_hero:chageTitleAction(action)
	if self._entity and self._titleSpr and self._titleSpr > 0 then
		self._entity:LinkChildSelectAction(self._titleSpr, action)
		self._entity:LinkChildPlay(self._titleSpr, -1, true);
	end
end

function i3k_hero:DetachTitleSPR()
	if self._entity and self._titleSpr and self._titleSpr > 0 then
		self._entity:RmvHosterChild(self._titleSpr);
		self._titleSpr = 0;
	end
end

function i3k_hero:AttachWizard(data)
	if data then
		local modelID = i3k_engine_check_is_use_stock_model(data.modelID);
		if modelID then
			local cfg = i3k_db_models[modelID]
			if cfg and self._entity then
				local effectID = 0;
				if cfg.path then
					effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_wizard_%s_effect_%d", self._guid, data.id), "", "", 0.0, cfg.scale);
				end
				self._wizard[self._guid] = effectID;
				self._entity:LinkChildSelectAction(effectID, i3k_db_common.engine.wizardStandAction)
				self._entity:LinkChildPlay(effectID, -1, true);
				self._entity:LinkChildShow(effectID, true)
			end
		end
	end
end

function i3k_hero:DetachWizard(id)
	if self._entity and self._wizard[id] then
		self._entity:RmvHosterChild(self._wizard[id]);
		self._wizard[id] = nil;
	end
end

function i3k_hero:ClearEquipEffect()
	for k =1 ,eEquipCount do
		self:DetachEquipEffectByPartID(k)
	end
	self._EquipEffects = {};
end

function i3k_hero:UpdateExtProperty(props)
	if not self:TryUpdateExtProperty() then
		return false;
	end

	local eps = { };

	local _props = props or self._properties;

	for _, p in pairs(self._passives) do
		table.insert(eps, { id = p.id, type = p.type, value = p.value });
	end

	-- self._buffs;
	local tmp = {}
	for _, buff in pairs(self._buffs) do
		local c = buff._cfg;
		if c.affectType == eBuffAType_Attr then
			if c.affectTick <= 0 then
				local buffSlot = c.buffSlot
				local buffSlotLvl = c.buffSlotLvl
				if buffSlot then --如果有buff槽配置
					if not tmp[buffSlot] or (tmp[buffSlot] and buffSlotLvl > tmp[buffSlot].lvl) then -- 没有或者比当前有的buff槽等级配置高
						--table.insert(eps, { id = c.affectID, type = c.valueType, value = buff:GetAffectValue() });
						tmp[buffSlot] = {lvl = buffSlotLvl, buff = buff}
					end
				else
					table.insert(eps, { id = c.affectID, type = c.valueType, value = buff:GetAffectValue() });
				end
			end
		end
	end

	for _, v in pairs(tmp) do
		local c = v.buff._cfg;
		table.insert(eps, { id = c.affectID, type = c.valueType, value = v.buff:GetAffectValue() });
	end

	_cmpEP = function(p1, p2)
		if p1.type < p2.type then
			return true
		elseif p1.type > p2.type then
			return false;
		else
			return p1.id < p2.id;
		end
	end
	table.sort(eps, _cmpEP);

	for k = 1, #eps do
		local p = eps[k];

		local prop = _props[p.id];
		if prop then
			if p.id == ePropID_AllPropertyReduce and p.value ~= 0  then
				self._allPorpReduceValue = p.value
			end
			if p.type == 1 then
				prop:Set(prop._valuePS.Base + p.value, ePropType_Passive,false,ePropChangeType_Base);
			else
				prop:Set(prop._valuePS.Percent + p.value, ePropType_Passive,false,ePropChangeType_Percent);
			end
		end
	end

	return true;
end

function i3k_hero:IsDead()
	return self._isDead;
end

function i3k_hero:SetDeadState(state)
	self._isDead = state
end

function i3k_hero:UpdateWorldPos(pos, real, updateCamera)
	if BASE.UpdateWorldPos(self, pos, real, updateCamera) then
		if self:IsPlayer() then
			if g_i3k_audio_listener then
				g_i3k_audio_listener:UpdatePos(i3k_vec3_to_engine(self._curPosE));
			end

			g_i3k_game_context:OnPlayerPositionChangedHandler(self._curPosE)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "updateCoordInfo", self._curPosE)
		end

		return true;
	end

	return false;
end

function i3k_hero:getTransferPointEntity()
	if jit then
		jit.off(true, true)
	end
		local world = i3k_game_get_world();
		if world then
			local nearby_trans = world:GetEntitiesInWorld(self._curPos, eET_TransferPoint);

			for i,v in ipairs(nearby_trans) do
				v.dist = i3k_vec3_dist(self._curPos, v._curPos)
			end
			SelectExp[1](nearby_trans);

		return nearby_trans[1]
	end
end

function i3k_hero:UpdateTrans(dTick)
	local world = i3k_game_get_world();
	if not world then
		return
	end
	if world._cfg.openType == g_MAZE_BATTLE then
		local trans = self:getTransferPointEntity()
		if trans then
			local cfg = g_i3k_db.i3k_db_get_maze_transfer_points_cfg(trans._gid, g_MAZE_BATTLE)
			local radios = cfg.Radius or 200
			if i3k_vec3_dist(self._curPos, trans._curPos) < radios and trans._gcfg.functionType == g_TRANSFERPOINT_NORMAL then			
				if not self._behavior:Test(eEBMove) then
					local resourcesFlag = true
					for k, v in pairs(i3k_db_maze_Map) do
						if not i3k_check_resources_downloaded(k) then
							resourcesFlag = false
						end
					end
					if resourcesFlag and g_i3k_game_context:addBattleMazeTransferCancelTimeCount(0) >= i3k_db_maze_battle.transferLimitTime then
						if g_i3k_game_context:isCanTransferInMaze() then
							local fun = function(flag)
								g_i3k_game_context:reSetBattleMazeTransferCancelTimeCount()
								if flag then
									if not g_i3k_db.i3k_db_get_maze_transferPonit_isIn_Area(trans._gcfg.id) then
										g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17791))
										return 
									end
									i3k_sbean.enter_maze_Transfer(trans._gcfg.id)
								end
							end
							if not g_i3k_ui_mgr:GetUI(eUIID_MidMessageBox2) then 
								g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(17750, i3k_db_maze_battle.transferneedNum), fun)
							end							
						else
							g_i3k_game_context:reSetBattleMazeTransferCancelTimeCount()
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17751))
						end
					else
						g_i3k_game_context:addBattleMazeTransferCancelTimeCount(dTick)
					end
				end			
			else
				g_i3k_game_context:addBattleMazeTransferCancelTimeCount(i3k_db_maze_battle.transferLimitTime)
			end			
		else
			g_i3k_game_context:addBattleMazeTransferCancelTimeCount(i3k_db_maze_battle.transferLimitTime)
		end
	else
		local is_ok = g_i3k_game_context:GetTransferState();
		if not is_ok and not self._behavior:Test(eEBMove) then
			local trans = self:getTransferPointEntity()
			if trans then
				if i3k_vec3_dist(self._curPos, trans._curPos) < 200 and trans._gcfg.functionType == g_TRANSFERPOINT_NORMAL then
						local toMapID = trans._gcfg.transmapID
						if i3k_check_resources_downloaded(toMapID) then
							local fdata = g_i3k_game_context:GetFindPathData()
							local data = i3k_sbean.waypoint_enter_req.new();
							data.wid = trans._gid;
							data.line = fdata.line or g_DEFAULT_WORLD_LINE
							if i3k_game_send_str_cmd(data, i3k_sbean.waypoint_enter_res.getName()) then
								g_i3k_game_context:SetTransferState(true);
						end
					end
				end
			end
		end
	end
end

function i3k_hero:AddAlives(entity)
	local et = self:GetEnemyType();
	local world = i3k_game_get_world();
	local mapType = i3k_game_get_map_type()

	local _ao = et[eGroupType_O];--他攻击的目标中有己方 怪，陷阱
	local _ae = et[eGroupType_E];--他攻击的目标中有敌方 玩家，佣兵

	local dist = i3k_vec3_len(i3k_vec3_sub1(self._curPos, entity._curPos))

	if entity:GetGroupType() == eGroupType_O then--己方
		if _ao then
			if self:GetEntityType() == eET_Monster and entity:GetEntityType() == eET_Player and world and not world._syncRpc and entity._behavior:Test(eEBInvisible) then
				--隐身状态下，不添加到怪物列表
				self._all_alives[1][entity._guid] = { entity = entity, dist = dist };
			else
				self._all_alives[2][entity._guid] = { entity = entity, dist = dist };
			end
		else
			local relative = false

			if entity:GetEntityType() == eET_Player or entity:GetEntityType() == eET_Mercenary or entity:GetEntityType() == eET_Car or entity:GetEntityType() == eET_Monster or entity:GetEntityType() == eET_Pet or entity:GetEntityType() == eET_Summoned then
				relative = self:TestRelative(entity);
			end

			if relative then
				self._all_alives[2][entity._guid] = { entity = entity, dist = dist };
			else
				self._all_alives[1][entity._guid] = { entity = entity, dist = dist };
			end
		end
	elseif entity:GetGroupType() == eGroupType_E then--敌方
		local mapTs = 
		{
			[g_FORCE_WAR] = true,
			[g_FACTION_WAR] = true,
			[g_BUDO] = true,
			[g_DEFENCE_WAR] = true,
			[g_DESERT_BATTLE] = true,
			[g_PRINCESS_MARRY] = true,
			[g_SPY_STORY]	= true,
		}
		
		if _ae then
			local sectId = g_i3k_game_context:GetFactionSectId()
			if ((mapTs[mapType] or i3k_get_is_tournament_weapon()) and self._forceType == entity._forceType) or (entity._sectID == sectId and sectId ~= 0) or (world._cfg.openType == g_DEFEND_TOWER and entity._bwType == g_DEFENCE_NPC_TYPE) or (self:IsPlayer() and self:GetIsGuard()) 
				or (world._cfg.openType == g_MAGIC_MACHINE and entity._forceType == g_DEFENCE_NPC_TYPE)  
				or (world._cfg.openType == g_HOMELAND_GUARD and entity._forceType == g_HOMELAND_GUARD_NPC_TYPE) 
				or (mapType == g_GOLD_COAST and not self:TestRelative(entity)) then
				self._all_alives[1][entity._guid] = { entity = entity, dist = dist }
			else
				self._all_alives[2][entity._guid] = { entity = entity, dist = dist };
			end
		else
			local relative = false
			if entity:GetEntityType() == eET_Player or entity:GetEntityType() == eET_Mercenary or entity:GetEntityType() == eET_Car or entity:GetEntityType() == eET_Monster or entity:GetEntityType() == eET_Pet or entity:GetEntityType() == eET_Summoned then
				relative = self:TestRelative(entity);
			end

			if (mapTs[mapType] or i3k_get_is_tournament_weapon()) and self._forceType == entity._forceType then
				self._all_alives[1][entity._guid] = { entity = entity, dist = dist }
			else
				if relative then
					self._all_alives[2][entity._guid] = { entity = entity, dist = dist };
				else
					self._all_alives[1][entity._guid] = { entity = entity, dist = dist };
				end
			end

		end
	elseif entity:GetGroupType() == eGroupType_N then--中立
		if entity:GetEntityType() == eET_Trap and entity:GetStatus() ~= eSTrapClosed then
			if entity._IsAttack  and entity._IsAttack ~= 0 then
				self._all_alives[3][entity._guid] = { entity = entity, dist = dist };
			end
		end
	end
	local world = i3k_game_get_world()
	if world and not world._syncRpc and self:IsPlayer() then
		self:UpdateOthersAuraAddBuff(entity)
	end
end

function i3k_hero:RmvAlives(entity)

	for i,v in pairs(self._all_alives[1]) do
		if entity._guid == v.entity._guid then
			self._all_alives[1][entity._guid] = nil;
		end
	end

	for i,v in pairs(self._all_alives[2]) do
		if entity._guid == v.entity._guid then
			self._all_alives[2][entity._guid] = nil;
		end
	end

	for i,v in pairs(self._all_alives[3]) do
		if entity._guid == v.entity._guid then
			self._all_alives[3][entity._guid] = nil;
		end
	end
end

function i3k_hero:UpdateAlives()
	local dTick = i3k_game_get_logic_tick() - self._lastUpdateAliveTick;
	if dTick > 0 and dTick < 5 then
		self._updateAliveTick = 0;

		return false;
	end
	self._lastUpdateAliveTick = i3k_game_get_logic_tick();

	self._alives = { { }, { }, { } };

	local _add = { false, false, false };

	-- 友方
	for i, v in pairs(self._all_alives[1]) do
		if not v.entity:IsDead() then
			_add[1] = true;

			v.dist = i3k_vec3_dist(v.entity._curPos, self._curPos);
			table.insert(self._alives[1], v);
		end
	end
	if _add[1] then
		local exp = SelectExp[1];

		exp(self._alives[1]);
	end

	-- 敌方
	for i, v in pairs(self._all_alives[2]) do
		if not v.entity:IsDead() then
			_add[2] = true;

			v.dist = i3k_vec3_dist(v.entity._curPos, self._curPos);
			table.insert(self._alives[2], v);
		end
	end

	if _add[2] then
		local exp = SelectExp[1];

		local mId, mValue = g_i3k_game_context:getMainTaskIdAndVlaue();
		if mId then
			local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId);
			if main_task_cfg and main_task_cfg.type then
				if main_task_cfg.type == g_TASK_KILL then
					exp = SelectExp[6]--主线怪
				end
			end
		end

		if self._PVPStatus == g_GoodAvilMode or self._PVPStatus == g_FreeMode or self._PVPStatus == g_FactionMode or self._PVPStatus == g_SeverMode then
			exp = SelectExp[8]--周围玩家
		end

		exp(self._alives[2]);
	end

	-- 中立
	for i, v in pairs(self._all_alives[3]) do
		if not v.entity:IsDead() then
			_add[3] = true;

			v.dist = i3k_vec3_dist(v.entity._curPos, self._curPos);
			table.insert(self._alives[3], v);
		end
	end

	if _add[3] then
		local exp = SelectExp[1];

		exp(self._alives[3]);
	end

	self:UpdateEnmities();
end

function i3k_hero:TestRelative(entity)
	--0:和平、1:自由、2:善恶、3:帮派 4:服务器
	local ChangeRelative = false
	if self:GetEntityType() == eET_Mercenary and self._hoster then
		return self._hoster:TestRelative(entity);
	end
	if self:IsPlayer() and self:GetIsGuard() then
		return false
	end

	if i3k_game_get_map_type() == g_QIECUO and not entity:IsCreated() then
		return false
	end

	local Entitytype = entity:GetEntityType()
	if self._PVPStatus then
		if Entitytype == eET_Mercenary or Entitytype == eET_Player or Entitytype == eET_Monster or Entitytype == eET_Trap or Entitytype == eET_Pet or Entitytype == eET_Car or Entitytype == eET_Summoned then
			local world = i3k_game_get_world();
			local mapType = i3k_game_get_map_type()
			if world then
				if self._PVPStatus == g_GoodAvilMode then
					if (mapType==g_FIELD or mapType == g_DEMON_HOLE or mapType == g_MAZE_BATTLE) then
						local sectId = g_i3k_game_context:GetFactionSectId()
						if (sectId ~= 0 and entity._hoster and entity._hoster._sectID and sectId == entity._hoster._sectID) or ( sectId ~= 0 and entity._sectID and sectId == entity._sectID) then
							ChangeRelative = false
						else
							if entity._PVPColor >= -1 then
								ChangeRelative = true
							end

							if entity._hoster and entity._hoster._PVPColor >= -1 and Entitytype == eET_Mercenary then
								ChangeRelative = true
							end
						end
					end
				elseif self._PVPStatus == g_FreeMode then
					ChangeRelative = true
				elseif self._PVPStatus == g_FactionMode then
					ChangeRelative = true
					if Entitytype == eET_Mercenary or Entitytype == eET_Pet or Entitytype == eET_Summoned then
						local sectId = g_i3k_game_context:GetFactionSectId()
						if sectId ~= 0 then
							if entity._hoster and entity._hoster._sectID then
								if sectId == entity._hoster._sectID then
									ChangeRelative = false
								end
							elseif entity._sectID then
								if sectId == entity._sectID then
									ChangeRelative = false
								end
							end
						end
					end
				elseif self._PVPStatus == g_SeverMode then
					ChangeRelative = self:GetForceType() ~= entity._forceType
				end

				if self._guid == entity._guid then
					ChangeRelative = false
					return ChangeRelative;
				end
				--非竞技场过滤
				if not world._fightmap then
					--等级过滤
					if Entitytype == eET_Player and entity._lvl then
						if (entity._lvl < i3k_db_common.pk.pkOpenlvl) or (self:GetEntityType() == eET_Player and self._lvl < i3k_db_common.pk.pkOpenlvl) then
							ChangeRelative = false
						end
					end
					if Entitytype == eET_Mercenary and entity._hoster and entity._hoster._lvl then
						if (entity._hoster._lvl < i3k_db_common.pk.pkOpenlvl) then
							ChangeRelative = false
						end
					end
				end
				--玩家过滤
				if Entitytype == eET_Player then
					if self._iscarRobber==1 and entity._iscarOwner==1 then
						ChangeRelative = true;
					end
					if entity._iscarRobber==1 then
						ChangeRelative = true;
					end
					local guid = string.split(entity._guid, "|")
					local RoleID = tonumber(guid[2])
					if g_i3k_game_context:IsTeamMember(RoleID) then
						ChangeRelative = false
					end
					if mapType==g_FIELD and not g_i3k_game_context:IsTeamMember(RoleID) and self._PVPStatus == g_FreeMode and entity._lvl >= i3k_db_common.pk.pkOpenlvl then--大地图的玩家判断
						ChangeRelative = true
					end
					--同一帮派的过滤
					if self._PVPStatus == g_FactionMode and (mapType==g_FIELD or mapType == g_DEMON_HOLE or mapType == g_FACTION_GARRISON or mapType == g_MAZE_BATTLE or g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.battleMapID
					or mapType == g_GOLD_COAST)then
						local sectId = g_i3k_game_context:GetFactionSectId()
						if sectId ~= 0 then
							if entity._sectID and sectId == entity._sectID then
								ChangeRelative = false
							end
						end
					end
				end
				--镖车过滤
				if Entitytype == eET_Car then
					if self._PVPStatus == g_PeaceMode then
						ChangeRelative = true
					end
					if self._iscarRobber == 0 then
						 return false;
					end
					if entity._carState == 1 then
						return false
					end
					local teamId = g_i3k_game_context:GetTeamId()
					if teamId ~= 0 and entity._teamID == teamId then
						return false
					end
					local sectId = g_i3k_game_context:GetFactionSectId()
					if sectId ~= 0 and sectId == entity._sectID then
						return false
					end
					local self_guid = string.split(self._guid, "|")
					local self_roleID = tonumber(self_guid[2])
					local car_guid = string.split(entity._guid, "|")
					local car_ID = tonumber(car_guid[2])
					if car_ID == self_roleID then
						return false
					end
					return ChangeRelative
				end
				--自己佣兵过滤
				if Entitytype == eET_Mercenary then
					local player = i3k_game_get_player()
					if player and player:GetHero() then
						local MercenaryCount = player:GetMercenaryCount();
						for i = 1,MercenaryCount do
							local Mercenary = player:GetMercenary(i)
							if Mercenary._guid == entity._guid then
								ChangeRelative = false
								break;
							end
						end
					end
					if mapType == g_FIELD and entity._hosterID then
						--队友佣兵过滤
						if g_i3k_game_context:IsTeamMember(entity._hosterID) then
							ChangeRelative = false
						end
					end
				end
				--自己和队友的残影和符灵卫过滤
				if Entitytype == eET_Pet or Entitytype == eET_Summoned then
					if entity._hosterID then
						local hero = i3k_game_get_player_hero()
						local guid = string.split(hero._guid, "|")
						if tonumber(guid[2]) == entity._hosterID then
							ChangeRelative = false
						end
						--队友残影过滤
						if g_i3k_game_context:IsTeamMember(entity._hosterID) then
							ChangeRelative = false
						end
					end
				end
				--势力战同势力怪物
				local mapTb = {
					[g_FORCE_WAR]	= true,
					[g_BUDO] 		= true,
					[g_FACTION_WAR] = true,
					[g_DEFENCE_WAR] = true,
					[g_DESERT_BATTLE] = true,
					[g_PRINCESS_MARRY] = true,
					[g_SPY_STORY]		= true,
				}

				if mapTb[mapType] or i3k_get_is_tournament_weapon() then
					ChangeRelative = self._forceType~=entity._forceType
				end
				--帮派夺旗战己方怪物
				if Entitytype == eET_Monster then
					local sectId = g_i3k_game_context:GetFactionSectId()
					if sectId ~= 0 and sectId == entity._sectID then
						return false
					end
					if g_GOLD_COAST == mapType then
						ChangeRelative = true
					end
				end
				--会武己方随从
				if mapType == g_TOURNAMENT then
					if Entitytype == eET_Mercenary then
						local test = self:GetTournamentFriendPet(entity._guid)
						if test then
							ChangeRelative = false
						end
					end
				end
			end
		end
	end
	return ChangeRelative
end








function i3k_hero:AddAura(skill, auraInfo)
	local _A = require("logic/battle/i3k_aura");

	local _aura = _A.i3k_aura.new(skill, auraInfo);
	if _aura and _aura:Bind(self) then
		self._auras[skill._id] = _aura;
	end
end

function i3k_hero:HaveSpecialBuff(guid)
	return self._buffInsts[guid] ~= nil;
end

function i3k_hero:AddBuff(attacker, buff)
	if buff then
		local res, overlays = buff:Bind(attacker, self);
		if res then
			self:ResetExtProperty(false);

			self._buffs[buff._id]		= buff;
			self._buffInsts[buff._guid] = true;
			self:OnBuffChanged(self);
			self:UpdateExtProperty(self._properties);
			if self:IsPlayer() then
				if i3k_db_steed_fight_spirit_buff_mapped[buff._id] then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1274, i3k_db_steed_fight_spirit_buff_mapped[buff._id]/100))
				end
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateDeBuffUI")
			end
			return true;
		elseif overlays then
			self:ResetExtProperty(false);
			self:OnBuffChanged(self);
			self:UpdateExtProperty(self._properties);

			return true;
		end
	end

	return false;
end

function i3k_hero:RmvBuff(buff)
	if buff then
		buff:Unbind();
		self:ResetExtProperty(false);
		self._buffs[buff._id]		= nil;
		self._buffInsts[buff._guid] = nil;
		self:OnBuffChanged(self);
		self:UpdateExtProperty(self._properties);
		if self:IsPlayer() then
			if i3k_db_steed_fight_spirit_buff_mapped[buff._id] or buff._cfg.affectID == ePropID_AllPropertyReduce then
				i3k_log("RmvBuff |"..buff._id)
				self._allPorpReduceValue = self:GetPropertyValue(ePropID_AllPropertyReduce)
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateDeBuffUI")
		end
	end
end

function i3k_hero:DispelBuff(dtype, count,note)
	if dtype == eEBDispelBuff then
		local dcount = 0;
		for k, v in pairs(self._buffs) do
			if v._type == eBuffType_Buff and not v:IsPassive() then
				self:RmvBuff(v);

				dcount = dcount + 1;
				if count > 0 and dcount >= count then
					break;
				end
			end
		end
		if self:IsPlayer() then
			self:ShowInfo(attacker, eEffectID_DeBuff.style, note, i3k_db_common.engine.durNumberEffect[2] / 1000);
		end
	elseif dtype == eEBDispelDBuff then
		local dcount = 0;
		for k, v in pairs(self._buffs) do
			if v._type == eBuffType_DBuff and not v:IsPassive() then
				self:RmvBuff(v);

				dcount = dcount + 1;
				if count > 0 and dcount >= count then
					break;
				end
			end
		end
		if self:IsPlayer() then
			self:ShowInfo(attacker, eEffectID_Buff.style, note, i3k_db_common.engine.durNumberEffect[2] / 1000);
		end
	end
end

function i3k_hero:ChangeFightSP(count)
	if self:GetEntityType() == eET_Player then
		local cfg = i3k_db_fightsp[self._id];
		if cfg.affectType == 1 then
			local overlay = self:GetFightSp()

			if overlay >= 0 and overlay <= cfg.overlays then
				overlay = overlay + count;
				if overlay > cfg.overlays then
					overlay = cfg.overlays;
				elseif overlay < 0 then
					overlay = 0;
				end
				self:UpdateFightSp(overlay,true);
			end
		elseif cfg.affectType == 2 then
			local player = i3k_game_get_player()
			local petcount = player:GetPetCount();
			if petcount >= 0 and petcount <= cfg.overlays then
				local lvl = 1;
				for k1, v1 in pairs(self._skills) do
					if v1._id == cfg.LinkSkill then
						lvl = v1._lvl;
					end
				end

				local creatnum = petcount + count;
				if creatnum > cfg.overlays then
					creatnum = cfg.overlays;
				elseif creatnum < 0 then
					creatnum = 0;
				end
				creatnum = creatnum - petcount;

				local xinfa = g_i3k_game_context:GetXinfa();
				local useXinfa = g_i3k_game_context:GetUseXinfa();
				local cfgID = cfg.affectID1;
				for k, v in pairs(self._talents) do
					if v._id == cfg.affectID2 then
						cfgID = cfg.value2[math.floor(v._lvl / 7) + 1];
					end
				end
				if creatnum > 0 then
					self:CreateFightSpCanYing(cfgID, creatnum, lvl);
				elseif creatnum < 0 then
					self:RemoveFightSpCanYing(creatnum);
				end
				self:UpdateFightSpCanYing(petcount + creatnum,true);
			end
		end
	end

end

function i3k_hero:ClsBuff(id)
	local buff = self._buffs[id];
	if buff then
		self:RmvBuff(buff);
	end
end

function i3k_hero:ClsBuffs(exclude)
	for bid, buff in pairs(self._buffs) do
		local _exclude =  buff:IsPassive() or (exclude and not exclude[bid]);
		if not _exclude then
			self:RmvBuff(buff);
		end
	end
end

function i3k_hero:OnDeadClsBuffs()
	for bid, buff in pairs(self._buffs) do
		local _exclude =  (buff:IsPassive() or buff._cfg.isShowAbove)
		if not _exclude then
			self:RmvBuff(buff);
		end
	end
end

function i3k_hero:ClsBuffByBehavior(bid)
	if self._behavior:Test(bid) then
		self._behavior:Clear(bid, -1);

		for k, v in pairs(self._behavior._value[bid].bid) do
			local buff = self._buffs[k];
			if buff then
				self:RmvBuff(buff);
			end
		end
	end
end

function i3k_hero:ChangeModelFacade(mid)
	local modelID = i3k_engine_check_is_use_stock_model(mid)
	if modelID then
		local mcfg = i3k_db_models[modelID];
		self._resCreated = self._resCreated + 1;
		if mcfg and self._entity then
			self._entity:ChangeHosterModel(mcfg.path, string.format("entity_%s", self._guid), false, mcfg.titleOffset);
			self._changemodelid = modelID
			self:ClearSkinEffect()
			self:ClearCombatEffect()
			local world = i3k_game_get_world()
			if world then
				world:UpdateIsShowPlayerSate(true)
			end
		end
		local wEquips = g_i3k_game_context:GetWearEquips()
		for i,v in pairs(wEquips) do
			self:DetachEquipEffectByPartID(i)
		end
		self:DetachFlyingEquip()
		if self._armor.id~=0 and self._entity then
			for _,v in ipairs(self._armor.effectId) do
				self._entity:RmvHosterChild(v)
			end
		end
	end
end

function i3k_hero:RestoreModelFacade()
	if not self._changemodelid then
		return;
	end
	self._changemodelid = nil;
	
	if self._entity then
		self._entity:RestoreHosterModel();
		local world = i3k_game_get_world()
		if world then
			world:UpdateIsShowPlayerSate(true)
		end
		self:PlayAction();

		if self._oriScale then
			self:SetScale(self._oriScale);
		end
	end
	self:SetPos(self._curPos, true);

	self:ChangeArmorEffect()
	self:ChangeCombatEffect(self._combatType)
	if self:GetEntityType() == eET_Player then
		if self._cacheFashionVis.valid then
			for k,v in pairs(self._cacheFashionVis.isShow) do
				self:SetFashionVisiable(v, k);
				--if not v and k == g_FashionType_Dress then
					--self:setSkinDisplay()
				--end
			end
			self._cacheFashionVis = {valid = false, isShow = {}}
		end
		if self._cacheFashionData.valid then
			for k, v in pairs(self._cacheFashionData.fashionID) do
				self:AttachFashion(v, self._cacheFashionData.isShow[k], k)
			end
			self._cacheFashionData = {valid = false, fashionID = {}, isShow = {}}
		end
		self:changeWeaponShowType()
	end
end

function i3k_hero:RestoreEquipEffect()
	local wequips = g_i3k_game_context:GetWearEquips()
	if not self:IsPlayer() then
		wequips = self._equipinfo
	end
	if wequips then
		for k1, v1 in pairs(wequips) do
			local equip = self._equips[k1];
			if equip and equip._skin.valid then
				local isshow = g_i3k_game_context:GetIsShwoFashion() or g_i3k_game_context:GetIsShowWeapon()
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
					for k, v in ipairs(equip._skin.skins) do
						self._entity:AttachHosterSkin(v.path, v.name, not self._syncCreateRes);
						self:AttachSkinEffect(k1,v.effectID)
					end
				end
			end
		end
	end
end

function i3k_hero:AttachEquip(eid,Isinit)
	local E = require("logic/battle/i3k_equip");
	local equip = E.i3k_equip.new();
	local FlyEquipSpecial = {
		[eEquipFlying] = true,
		[eEquipWeapon] = true,
		[eEquipClothes] = true,
		[eEquipFlyClothes] = true,
	}
	local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	if equip:Create(self, eid, self._gender) then
		equip.equipId = eid
		if self:HasEquip(equip._partID) then
			self:DetachEquip(equip._partID, true);
		end
		self:ReleaseFashion(self._fashion, equip._partID == eEquipFlyClothes and eEquipClothes or equip._partID)
		self._equips[equip._partID] = equip;
		if self._missionMode.valid or self:IsInSuperMode() then
			return
		end
		if (equip._partID == eEquipWeapon or equip._partID == eEquipFlying) and self:GetIsBeingHomeLandEquip() then
			return
		end
		if not FlyEquipSpecial[equip._partID]
			or  (equip._partID == eEquipClothes and  skinDisplay == g_WEAR_NORMAL_SHOW_TYPE) 
			or  (equip._partID == eEquipFlyClothes and skinDisplay == g_WEAR_FLYING_SHOW_TYPE ) then
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
				if equip._skin.valid then
					for k, v in ipairs(equip._skin.skins) do
						self._entity:AttachHosterSkin(v.path, v.name, not self._syncCreateRes);
						self:AttachSkinEffect(equip._partID,v.effectID)
					end
				else
					self:CreateFashion(self._fashion, equip._partID)
				end
			end
		elseif equip._partID == eEquipWeapon and weaponDisplay == g_WEAPON_SHOW_TYPE then
			if equip._skin.valid then
				for k, v in ipairs(equip._skin.skins) do
					self._entity:AttachHosterSkin(v.path, v.name, not self._syncCreateRes);
					self:AttachSkinEffect(equip._partID,v.effectID)
				end
			else
				self:CreateFashion(self._fashion, equip._partID)
			end
		elseif equip._partID == eEquipFlying and weaponDisplay == g_FLYING_SHOW_TYPE then
			self:AttachFlyingWeapon()
		end
		
		-- 重新计算属性
		local hero = i3k_game_get_player_hero();
		if hero and hero._guid == self._guid and not Isinit then
			self:UpdateEquipProps();
			self:UpdateRewardProps();
		end
	end
	if not self._changemodelid and weaponDisplay == g_WEAPON_SHOW_TYPE then
		self:AttachEquipEffect()
	end
end

function i3k_hero:DetachEquip(partID, isForce)
	local equip = self._equips[partID];
	local rmPartTable = {
		[eEquipWeapon] = true,
		[eEquipFlyClothes] = true,
		[eEquipClothes] = true,
	}
	if equip then
		if eEquipFlying == partID then
			if equip._model.valid then
				self:DetachFlyingEquip()
			end
		elseif rmPartTable[partID] then
			self:DetachEquipSkinAndEffect(partID)
		else
			self:DetachEquipSkinAndEffect(partID)
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
			if isshow then
				self:DetachEquipSkinAndEffect(partID)
			else
				self:CreateFashion(self._fashion, partID)
			end
		end
		if isForce then
			equip:Release();
			self._equips[partID] = nil;
		end
	else
		if partID == eEquipFlying then
			self:ReleaseFashion(self._fashion, eEquipWeapon)
		elseif partID == eEquipFlyClothes then
			self:ReleaseFashion(self._fashion, eEquipClothes)
		else
			self:ReleaseFashion(self._fashion, partID)
		end
	end
end

function i3k_hero:DetachEquipSkinAndEffect(partID)
	local equip = self._equips[partID];
	if equip and equip._skin.valid then
		for k, v in ipairs(equip._skin.skins) do
			self._entity:DetachHosterSkin(v.name)
		end
		self:DetachSkinEffect(partID)
	end
end
function i3k_hero:ChangeEquipFacade(pid, sid)
	local name = string.format("hero_skin_%s_%d", self._guid, pid);

	if self._entity then
		local equip = self._equips[pid];
		if equip and equip._skin.valid then
			for k, v in ipairs(equip._skin.skins) do
				self._entity:DetachHosterSkin(v.name);
			end
			self:DetachSkinEffect(pid);
		else
			self:ReleaseFashion(self._fashion, pid);
		end

		local scfg = i3k_db_skins[sid];
		if scfg then
			self._changeEName[pid] = name;

			self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
			self:AttachSkinEffect(pid,scfg.effectID)
		end
	end
end

function i3k_hero:SpringDetachFashion(isSpring)
	local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	local usefashion = nil;
	if isSpring then
		usefashion = self._SpringFashion[g_FashionType_Dress]
	else
		usefashion = self._Usefashion[g_FashionType_Dress]
	end
	if usefashion then
		for k,v in pairs(usefashion.dressInfo) do
			for k1,v1 in pairs(v) do
				self._entity:DetachHosterSkin(v1.name);
			end
			self:DetachSkinEffect(g_FashionType_Dress);
			if not ( k == eEquipClothes) then
			local equip = self._equips[k];
			if equip then
				if equip._skin.valid then
					for k2, v2 in ipairs(equip._skin.skins) do
						self._entity:AttachHosterSkin(v2.path, v2.name, not self._syncCreateRes);
						self:AttachSkinEffect(k,v2.effectID)
					end
				elseif k ~= 1 then
					self:CreateFashion(self._fashion, k);
				end
			elseif k ~= 1 then
				self:CreateFashion(self._fashion, k);
				end
			end
		end
	end
end

function i3k_hero:SpringFashion(fashionID, isSpring)
	local cfg = i3k_db_fashion_dress[fashionID]
	if not cfg or not self:IsCreated() then
		return false;
	end
	self:SpringDetachFashion(isSpring)
	local fashioninfo = {id = fashionID,dressInfo = {}}
	for k,v in pairs(cfg.fashionReflect) do
		local argsname = "skin"..self._id..self._gender
		local skincfg = i3k_db_fashion_dress_skin[v][argsname]
		local partID = i3k_db_fashion_dress_skin[v].partid
		self:ChangeFashionPre(partID);
		fashioninfo.dressInfo[partID] = {}
		for k1, v1 in ipairs(skincfg) do
			local scfg = i3k_db_skins[v1]
			local name = string.format("hero_Fashionskin_%s_%d_%d_%d_%d", self._guid,fashionID, cfg.fashionType,partID, k1);
			local info = {name = name,path = scfg.path,effectID = scfg.effectID}
			table.insert(fashioninfo.dressInfo[partID],info)
			self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
			self:AttachSkinEffect(partID,scfg.effectID)
		end
		self._SpringFashion[cfg.fashionType] = fashioninfo
	end
end

function i3k_hero:AttachFashion(fashionID, isshow, fashionType)
	local cfg = i3k_db_fashion_dress[fashionID]
	if not cfg or not self:IsCreated() then
		return false;
	end
	local missionModeType = {
		[g_TASK_TRANSFORM_STATE_PEOPLE]			= true,
		[g_TASK_TRANSFORM_STATE_SUPER]			= true,
		[g_TASK_TRANSFORM_STATE_METAMORPHOSIS]  = true,
		[g_TASK_TRANSFORM_STATE_CAR]			= true,
		[g_TASK_TRANSFORM_STATE_CHESS]			= true,
	}

	local condition = self._superMode.valid or (self._missionMode.valid and missionModeType[self._missionMode.type])
	
	if condition then
		self._cacheFashionData.valid = true;
		self._cacheFashionData.fashionID[fashionType] = fashionID;
		self._cacheFashionData.isShow[fashionType] = isshow;
	else
		if fashionType == g_FashionType_Weapon then
			self._fashionWeap = fashionID;
			self._fashionWeapShow = isshow;
		elseif fashionType == g_FashionType_Dress then
			self._fashionsID = fashionID;

		end
		self:DetachFashion(cfg.fashionType,isshow)
		local fashioninfo = {id = fashionID,dressInfo = {}}
		for k,v in pairs(cfg.fashionReflect) do
			local argsname = "skin"..self._id..self._gender
			local skincfg = i3k_db_fashion_dress_skin[v][argsname]
			local partID = i3k_db_fashion_dress_skin[v].partid
			if isshow then
				self:ChangeFashionPre(partID);
			end
			fashioninfo.dressInfo[partID] = {}
			for k1, v1 in ipairs(skincfg) do
				local scfg = i3k_db_skins[v1]
				local name = string.format("hero_Fashionskin_%s_%d_%d_%d_%d", self._guid,fashionID, cfg.fashionType,partID, k1);
				local info = {name = name,path = scfg.path,effectID = scfg.effectID}
				table.insert(fashioninfo.dressInfo[partID],info)
				if isshow then
					self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes);
					self:AttachSkinEffect(partID,scfg.effectID)
				end
			end
		end
		self._Usefashion[cfg.fashionType] = fashioninfo
	end
	-- 重新计算属性
	if self:IsPlayer() then
		self:UpdateFashionProps();
	end

end

function i3k_hero:DetachFashion(fashionType,isshow)
	local usefashion = self._Usefashion[fashionType]
	if usefashion then
		if isshow then
			for k,v in pairs(usefashion.dressInfo) do
				for k1,v1 in pairs(v) do
					self._entity:DetachHosterSkin(v1.name);
				end
				self:DetachSkinEffect(fashionType)
			end
		end
		self._Usefashion[fashionType] = nil;
		-- 重新计算属性
		if self:IsPlayer() and not NotUpdate then
			self:UpdateFashionProps();
		end
	end
end

function i3k_hero:SetTestFationID(id)
	local cfg = i3k_db_fashion_dress[id]
	if cfg then
		self._TestfashionID[cfg.fashionType] = id;
	end
end

function i3k_hero:ResetTestFashion()
	self._TestfashionID = {}
end

--卸掉某部位的装备蒙皮以及默认蒙皮,只卸掉蒙皮不改变装备的存储
function i3k_hero:ChangeFashionPre(PartID)
	if PartID == eEquipClothes then
		local flyingEquip = self._equips[eEquipFlyClothes]
		if flyingEquip then
			if flyingEquip._skin.valid then
				for k, v in ipairs(flyingEquip._skin.skins) do
					self._entity:DetachHosterSkin(v.name);
				end
				self:DetachSkinEffect(PartID);
			else
				self:ReleaseFashion(self._fashion, PartID);
			end
		else
			self:ReleaseFashion(self._fashion, PartID);
		end
	end
	local equip = self._equips[PartID];
	if equip then
		if equip._skin.valid then
			for k, v in ipairs(equip._skin.skins) do
				self._entity:DetachHosterSkin(v.name);
			end
			self:DetachSkinEffect(PartID);
		else
			self:ReleaseFashion(self._fashion, PartID);
		end
	else
		self:ReleaseFashion(self._fashion, PartID);
	end
end

--显示时装之前卸掉装备蒙皮，卸载时装蒙皮之后挂载装备蒙皮
function i3k_hero:showFashion(isshow, PartID, fashionType)
	--胸甲部位和飞升胸甲部位的蒙皮卸载
	if PartID == eEquipClothes or PartID == eEquipFlyClothes then
		self:DetachEquip(eEquipClothes)
		self:DetachEquip(eEquipFlyClothes)
					end
	if isshow then
		if self._Usefashion[fashionType].dressInfo[PartID] then
		for k,v in pairs(self._Usefashion[fashionType].dressInfo[PartID]) do
			self._entity:AttachHosterSkin(v.path, v.name, not self._syncCreateRes);
			self:AttachSkinEffect(PartID,v.effectID)
			end
		end
	else
		if self._Usefashion[fashionType].dressInfo[PartID] then
		for k,v in pairs(self._Usefashion[fashionType].dressInfo[PartID]) do
			self._entity:DetachHosterSkin(v.name);
			self:DetachSkinEffect(PartID);
			end
		end
	end
end

function i3k_hero:needShowHeirloom()
	if self:GetIsBeingHomeLandEquip() then
		return
	end
	self:changeWeaponShowType()
end

function i3k_hero:SetFashionVisiable(vis, fashionType, isForce)
		if not isForce then
			self._fashionWeapShow = vis;
	end
	local missionModeType = {
		[g_TASK_TRANSFORM_STATE_PEOPLE]			= true,
		[g_TASK_TRANSFORM_STATE_SUPER]			= true,
		[g_TASK_TRANSFORM_STATE_METAMORPHOSIS]  = true,
		[g_TASK_TRANSFORM_STATE_CAR]			= true,
		[g_TASK_TRANSFORM_STATE_CHESS]			= true,
	}
	local condition = self._superMode.valid or (self._missionMode.valid and missionModeType[self._missionMode.type])
	if condition then
		self._cacheFashionVis.valid = true;
		self._cacheFashionVis.isShow[fashionType] = vis;
		self._cacheFashionData.isShow[fashionType] = vis;
	else
		if self._Usefashion[g_FashionType_Weapon] and fashionType == g_FashionType_Weapon then
			if self._Usefashion[g_FashionType_Weapon].dressInfo[eEquipWeapon] then
				self:showFashion(vis, eEquipWeapon, g_FashionType_Weapon)
			end
		end
		if self._Usefashion[g_FashionType_Dress] and fashionType == g_FashionType_Dress then
				self:showFashion(vis, eEquipClothes, g_FashionType_Dress)
			if not vis then
			    self:setSkinDisplay()
			end
		end
	end
end

function i3k_hero:setSkinDisplay()
	self:ReleaseFashion(self._fashion, eEquipClothes)
	--胸甲部位的蒙皮挂载
	local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	local PartID = skinDisplay == g_WEAR_FLYING_SHOW_TYPE and eEquipFlyClothes or eEquipClothes
	self:DetachEquip(eEquipClothes)
	self:DetachEquip(eEquipFlyClothes)
	local equip = self._equips[PartID]
	if equip then
		if equip._skin.valid then
			for k1, v1 in ipairs(equip._skin.skins) do
				self._entity:AttachHosterSkin(v1.path, v1.name, not self._syncCreateRes);
				self:AttachSkinEffect(PartID, v1.effectID)
			end
		else
			self:CreateFashion(self._fashion, eEquipClothes);
		end
	else
		self:CreateFashion(self._fashion, eEquipClothes);
	end
end
function i3k_hero:IsFashionShow()
	local _, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	return skinDisplay == g_WEAR_FASHION_SHOW_TYPE 
end

function i3k_hero:IsFashionWeapShow()
	local weaponDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	return weaponDisplay == g_FASTION_SHOW_TYPE
end

function i3k_hero:RestoreEquipFacade(pid)
	local name = self._changeEName[pid];
	if name then
		if self._entity then
			self._entity:DetachHosterSkin(name);
		end
		self:DetachSkinEffect(pid);
		self._changeEName[pid] = nil;
	end

	if self._entity then
		local equip = self._equips[pid];
		if equip and equip._skin.valid then
			for k, v in ipairs(equip._skin.skins) do
				self._entity:AttachHosterSkin(v.path, v.name, not self._syncCreateRes)
				self:AttachSkinEffect(pid,v.effectID)
			end
		else
			self:CreateFashion(self._fashion, pid);
		end
	end
end

function i3k_hero:HasEquip(partID)
	local equip = self._equips[partID];
	if equip then
		return true;
	end

	return false;
end

function i3k_hero:DesEquipDurability(partID,Durability)
	local wequips = g_i3k_game_context:GetWearEquips()
	if wequips then
		local Equip =  wequips[partID];
		if Equip and Equip.equip then
			if Equip.equip.naijiu ~= -1 and Equip.equip.naijiu then
				Equip.equip.naijiu = Durability
				local Threshold = i3k_db_common["equip"]["durability"].Threshold
				local perdec = i3k_db_common["equip"]["durability"].perdec
				if Durability <= Threshold and Durability >= Threshold - perdec then
					g_i3k_game_context:SetPrePower()
					self:UpdateEquipProps();
					g_i3k_game_context:ShowPowerChange()
				end
			end
		end
	end
end

function i3k_hero:UpdateEquipProps(props)
	local _props = props or self._properties;
	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Equip,false,ePropChangeType_Base);
		v:Set(0, ePropType_Equip,false,ePropChangeType_Percent);
	end
	local wequips = g_i3k_game_context:GetWearEquips()
	if wequips then
		local Threshold = i3k_db_common["equip"]["durability"].Threshold
		for k, v in pairs(wequips) do
			if v.equip then
				local Finaladdrate = false;
				if v.equip.naijiu then
					if v.equip.naijiu > Threshold or v.equip.naijiu == -1 then
						if v.equip.naijiu > Threshold then
							Finaladdrate = true
						end
						local prop = g_i3k_db.i3k_db_get_equip_props(v.equip.equip_id, v.equip.attribute, v.eqGrowLvl, v.eqEvoLvl, v.equip.refine, v.equip.smeltingProps)
						for k1, v1 in ipairs(prop.base) do
							local prop1 = _props[v1.pid];
							local v1_value = v1.value
							if prop1 then
								if Finaladdrate and v.equip.legends[1] and v.equip.legends[1]~=0 then
									v1_value = v1.value * (1+i3k_db_equips_legends_1[v.equip.legends[1]].count/10000)
								end
								v1_value = math.floor(v1_value + v1.value_break)
								prop1:Set(prop1._valueP.Base + v1_value, ePropType_Equip,false,ePropChangeType_Base);
							end
						end
						for k2, v2 in ipairs(prop.attribute) do
							local prop2 = _props[v2.pid];
							if prop2 then
								if Finaladdrate and v.equip.legends[2] and v.equip.legends[2]~=0 then
									v2.value = math.floor(v2.value * (1+i3k_db_equips_legends_2[v.equip.legends[2]].count/10000))
								end
								prop2:Set(prop2._valueP.Base + v2.value, ePropType_Equip,false,ePropChangeType_Base);
							end
						end
						for k3, v3 in ipairs(prop.refine) do
							local prop3 = _props[v3.pid];
							if prop3 then
								prop3:Set(prop3._valueP.Base + v3.value, ePropType_Equip, false, ePropChangeType_Base);
							end
						end
						for k4, v4 in ipairs(prop.smeltingProps) do--锤炼属性
							local prop4 = _props[v4.pid]
							if prop4 then
								prop4:Set(prop4._valueP.Base + v4.value, ePropType_Equip, false, ePropChangeType_Base);
							end
						end
						local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(v.equip.equip_id)
						if v.equip.legends[3] and v.equip.legends[3] ~= 0 then
							local cfg = i3k_db_equips_legends_3[equip_t.partID][v.equip.legends[3]]
							if cfg and cfg.type == 2 then
								local prop4 = _props[cfg.args[1]]
								if cfg.args[2] == 1 then
									prop4:Set(prop4._valueP.Base + cfg.args[3], ePropType_Equip,false,ePropChangeType_Base)
								elseif cfg.args[2] == 2 then
									prop4:Set(prop4._valueP.Percent + cfg.args[3], ePropType_Equip,false,ePropChangeType_Percent)
								end
							end
						end
						for _,e in ipairs(i3k_db_upStar_attribute[equip_t.partID]) do
							if v.eqEvoLvl >= e.needStar then
								for _,z in ipairs(e.args) do
									if z[1] ~= 0 then
										local prop5 = _props[z[1]]
										if prop5 then
											prop5:Set(prop5._valueP.Base + tonumber(z[2]), ePropType_Equip,false,ePropChangeType_Base)
										end
									end
								end
							end
						end
					end
				end
			end

			local ratio = g_i3k_game_context:GetIncreaseRatioOfGemBlessOnEquip(k)--宝石属性提升系数 锤炼相关
			if v.slot then
				for k1,v1 in pairs(v.slot) do
					if v1 ~= 0 then
						local Bcfg = g_i3k_db.i3k_db_get_gem_item_cfg(v1);
						if Bcfg then
							local prop2 = _props[Bcfg.effect_id];
							if prop2 then
								prop2:Set(prop2._valueP.Base + Bcfg.effect_value * ( 1 + ratio), ePropType_Equip,false,ePropChangeType_Base);
							end
						end
					end
				end
			end

			if v.gemBless and v.slot then --宝石祝福
				for k1, v1 in pairs(v.gemBless) do
					local gemID = v.slot[k1]
					if gemID and gemID ~= 0 and v1 ~= 0 then
						local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(gemID)
						local blessCfg = g_i3k_db.i3k_db_get_diamond_bless_cfg(gemCfg.type)
						local prop = _props[gemCfg.effect_id];
						local addProVal = math.floor(gemCfg.effect_value * blessCfg[v1])
						if prop then
							prop:Set(prop._valueP.Base + addProVal, ePropType_Equip, false, ePropChangeType_Base);
						end
					end
				end
			end

		end
	end
	-- 神器属性
	local heirloomProps = g_i3k_game_context:getHeirloomProps()
	for k1,v1 in pairs(heirloomProps) do
		local prop = _props[k1];
		if prop then
			prop:Set(prop._valueP.Base + v1 , ePropType_Equip,false,ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
	self:UPdateEquipAi()
end

function i3k_hero:UPdateEquipAi()
	self:ClsEquipAi()
	local Threshold = i3k_db_common["equip"]["durability"].Threshold
	local wequips = g_i3k_game_context:GetWearEquips()
	for k,v in pairs(wequips) do
		if v.equip then
			if v.equip.naijiu > Threshold then
				if v.equip.legends[3] and v.equip.legends[3] ~= 0 then
					local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(v.equip.equip_id)
					local cfg = i3k_db_equips_legends_3[equip_t.partID][v.equip.legends[3]]
					if cfg and cfg.type == 1 then
						local effectID = cfg.args[1]
						local tgcfg =  i3k_db_ai_trigger[effectID]
						local mgr = self._triMgr
						if mgr then
							local TRI = require("logic/entity/ai/i3k_trigger");
							local tri = TRI.i3k_ai_trigger.new(self);
							if tri:Create(tgcfg,-1,effectID) then
								local tid = mgr:RegTrigger(tri, self);
								if tid >= 0 then
									table.insert(self._equiptids, tid);
								end
							end
						end
					end
				end
			end
		end
	end
end

function i3k_hero:ClsEquipAi()
	if self._equiptids then
		if self._triMgr then
			for k, v in ipairs(self._equiptids) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._equiptids = {};
	end
end

function i3k_hero:UpdateBaGuaProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_BaGua, false, ePropChangeType_Base);
		v:Set(0, ePropType_BaGua, false, ePropChangeType_Percent);
	end

	local baGuaprops = g_i3k_game_context:getBaGuaProps()
	for k, v in pairs(baGuaprops) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueBG.Base + v, ePropType_BaGua, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateXiuXinProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_XiuXin, false, ePropChangeType_Base);
		v:Set(0, ePropType_XiuXin, false, ePropChangeType_Percent);
	end

	local xiuxinProps = g_i3k_game_context:getXinjueProps()
	for k, v in pairs(xiuxinProps) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueXX.Base + v, ePropType_XiuXin, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateWuJueProp(props)
	if g_i3k_game_context:isWujueOpen() then
		local _props = props or self._properties;

		for k, v in pairs(_props) do
			v:Set(0, ePropType_Wujue, false, ePropChangeType_Base);
			v:Set(0, ePropType_Wujue, false, ePropChangeType_Percent);
		end

		for k, v in ipairs(g_i3k_db.i3k_db_get_wujue_level_prop() or {}) do
			local prop = _props[v.id];
			if prop then
				prop:Set(prop._valueWJ.Base + v.value, ePropType_Wujue, false, ePropChangeType_Base);
			end
		end
		for id, cfg in ipairs(i3k_db_wujue_skill) do
			local level = g_i3k_game_context:getWujueSkillLevel(id)
			if level > 0 then
				for i, v in ipairs(cfg[level].props) do
					local prop = _props[v.id];
					if prop then
						prop:Set(prop._valueWJ.Base + v.value, ePropType_Wujue, false, ePropChangeType_Base);
					end
				end
			end
		end
		for soulId, cfg in ipairs(i3k_db_wujue_soul) do
			local lvl = g_i3k_game_context:getWujueSoulLvl(soulId)
			local soulCfg = cfg[lvl]
			if soulCfg then
				for i, v in ipairs(soulCfg.props) do
					local prop = _props[v.id];
					if prop then
						prop:Set(prop._valueWJ.Base + v.value, ePropType_Wujue, false, ePropChangeType_Base);
					end
				end
				local soulBaseCfg = i3k_db_wujue.soulCfg[soulId]
				local specialProp = soulBaseCfg.propsIds
				local value = soulBaseCfg.propsValues[soulCfg.rank]
				for i,v in ipairs(specialProp) do
					local prop = _props[v];
					if prop then
						prop:Set(prop._valueWJ.Base + value, ePropType_Wujue, false, ePropChangeType_Base);
					end
				end
			end
		end
		self:OnMaxHpChangedCheck()
	end
end

function i3k_hero:UpdatePetGuardProp(props)
	if next(g_i3k_game_context:GetActivePetGuards()) then
		local _props = props or self._properties
		for k, v in pairs(_props) do
			v:Set(0, ePropType_PetGuard, false, ePropChangeType_Base)
			v:Set(0, ePropType_PetGuard, false, ePropChangeType_Percent);
		end
		for k, v in pairs(g_i3k_db.i3k_db_get_pet_guards_props()) do
			local prop = _props[k];
			if prop then
				prop:Set(prop._valuePG.Base + v, ePropType_PetGuard, false, ePropChangeType_Base);
			end
		end
		self:OnMaxHpChangedCheck()
	end
end
function i3k_hero:UpdateHorseEquipProp(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_HorseEquip, false, ePropChangeType_Base);
		v:Set(0, ePropType_HorseEquip, false, ePropChangeType_Percent);
	end
	local horseEquipProps = g_i3k_game_context:GetSteedEquipTotalProps()
	for k, v in pairs(horseEquipProps) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueHE.Base + v, ePropType_HorseEquip, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end
function i3k_hero:UpdateHideWeaponProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_HideWeapon, false, ePropChangeType_Base);
		v:Set(0, ePropType_HideWeapon, false, ePropChangeType_Percent);
	end

	local hideWeaponProps = g_i3k_game_context:getHideWeaponProps()
	for k, v in pairs(hideWeaponProps) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueHW.Base + v, ePropType_HideWeapon, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateXingHunProp(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_XingHun, false, ePropChangeType_Base);
		v:Set(0, ePropType_XingHun, false, ePropChangeType_Percent);
	end
	local xingHunProps = g_i3k_game_context:getXingHunProps()
	for k, v in pairs(xingHunProps) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueXH.Base + v, ePropType_XingHun, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateDestinyRollProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_DestinyRoll, false, ePropChangeType_Base);
		v:Set(0, ePropType_DestinyRoll, false, ePropChangeType_Percent);
	end

	local DestinyRollProps = g_i3k_game_context:getDestinyRollProps()
	for k, v in pairs(DestinyRollProps) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueDR.Base + v, ePropType_DestinyRoll, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateHeirloomStrength(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_HeirloomStrength, false, ePropChangeType_Base);
		v:Set(0, ePropType_HeirloomStrength, false, ePropChangeType_Percent);
	end

	local heirloomStrengthProps = g_i3k_game_context:getHeirloomStrengthProps()
	for k, v in pairs(heirloomStrengthProps) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueHA.Base + v, ePropType_HeirloomStrength, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateEpicTaskAttr(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_EpicTask, false, ePropChangeType_Base);
		v:Set(0, ePropType_EpicTask, false, ePropChangeType_Percent);
	end

	for k, v in pairs(g_i3k_game_context:getEpicTaskAttr()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueEPT.Base + v, ePropType_EpicTask, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateMartialSoulProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_MartialSoul, false, ePropChangeType_Base);
		v:Set(0, ePropType_MartialSoul, false, ePropChangeType_Percent);
	end

	for k, v in pairs(g_i3k_game_context:GetWeaponSoulPropData()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueMAS.Base + v, ePropType_MartialSoul, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateStarSoulProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_StarSoul, false, ePropChangeType_Base);
		v:Set(0, ePropType_StarSoul, false, ePropChangeType_Percent);
	end

	for k, v in pairs(g_i3k_game_context:GetStarPropData()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueSD.Base + v, ePropType_StarSoul, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateShenDouProp(props)
	local _props = props or self._properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_ShenDou, false, ePropChangeType_Base)
		v:Set(0, ePropType_ShenDou, false, ePropChangeType_Percent)
	end
	for k, v in pairs(g_i3k_db.i3k_db_get_shen_dou_prop()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueGS.Base + v, ePropType_ShenDou, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end
function i3k_hero:UpdateQilingProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_Qiling, false, ePropChangeType_Base);
		v:Set(0, ePropType_Qiling, false, ePropChangeType_Percent);
	end

	for k, v in pairs(g_i3k_game_context:getActiveForeverProp()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueQL.Base + v, ePropType_Qiling, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end
-- 器灵变身属性（变身结束移除）
function i3k_hero:UpdateQilingTransProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_QilingTrans, false, ePropChangeType_Base);
		v:Set(0, ePropType_QilingTrans, false, ePropChangeType_Percent);
	end

	for k, v in pairs(g_i3k_game_context:getActiveTransProp()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueQLT.Base + v, ePropType_QilingTrans, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end
-- 图鉴属性加成
function i3k_hero:UpdateCardPacketProp(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_CardPacket, false, ePropChangeType_Base);
		v:Set(0, ePropType_CardPacket, false, ePropChangeType_Percent);
	end
	for k, v in pairs(g_i3k_game_context:getCardPacketProps()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueCP.Base + v, ePropType_CardPacket, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end
-- 战区卡片属性加成
function i3k_hero:UpdateWarZoneCardProp(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_WardZoneCard, false, ePropChangeType_Base);
		v:Set(0, ePropType_WardZoneCard, false, ePropChangeType_Percent);
	end
	for k, v in ipairs(g_i3k_game_context:GetCurCardCanAddProp()) do
		local prop = _props[v.id];
		if prop then
			if v.type == 1 then
				prop:Set(prop._valueWZC.Base + v.value, ePropType_WardZoneCard, false, ePropChangeType_Base);
			else
				prop:Set(prop._valueWZC.Percent + v.value, ePropType_WardZoneCard, false, ePropChangeType_Percent);
			end
		end
	end
end

function i3k_hero:UpdateMeridianProp(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_Meridian, false, ePropChangeType_Base);
		v:Set(0, ePropType_Meridian, false, ePropChangeType_Percent);
	end

	for k, v in pairs(g_i3k_game_context:getMeridianPotentialAttr()) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueJM.Base + v, ePropType_Meridian, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
	self:UpdateMeridianAi()
end

function i3k_hero:UpdateMeridianAi()
	self:ClsMeridianAi()
	local Potential = g_i3k_game_context:getMeridianPotential()
	if Potential then
		local cfg = i3k_db_meridians.potentia
		for k,v in pairs(Potential) do
			if cfg[k][v].talentType == eMP_AiTriggerType then
				local tgcfg =  i3k_db_ai_trigger[cfg[k][v].aiList]
				local mgr = self._triMgr
				if mgr then
					local TRI = require("logic/entity/ai/i3k_trigger");
					local tri = TRI.i3k_ai_trigger.new(self);
					if tri:Create(tgcfg,-1,cfg[k][v].aiList) then
						local tid = mgr:RegTrigger(tri, self);
						if tid >= 0 then
							table.insert(self._meridiansAi, tid);
						end
					end
				end
			end
		end
	end
end

function i3k_hero:ClsMeridianAi()
	if self._meridiansAi then
		if self._triMgr then
			for k, v in ipairs(self._meridiansAi) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._meridiansAi = {};
	end
end

function i3k_hero:UpdateFashionProps(props)
	local _props = props or self._properties;
	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Fashion,false,ePropChangeType_Base);
		v:Set(0, ePropType_Fashion,false,ePropChangeType_Percent);
	end

	if self._Usefashion then
		for k, v in pairs(self._Usefashion) do
			local cfg = i3k_db_fashion_dress[v.id];
			if g_i3k_game_context:GetFashionIsSpinning(v.id) then
				local spinningProp = g_i3k_game_context:GetFashionSpinningProp(v.id)
				for k, v in pairs(spinningProp) do
					local prop1 = _props[k];
					if prop1 then
						prop1:Set(prop1._valueFD.Base + v, ePropType_Fashion, false, ePropChangeType_Base);
					end
				end
			else
				for k1 = 1,4 do
					local prop1 = _props[cfg["property"..k1.."Id"]];
					if prop1 then
						prop1:Set(prop1._valueFD.Base + cfg["property"..k1.."Value"], ePropType_Fashion,false,ePropChangeType_Base);
					end
				end
			end
		end
	end

	local wardrobeProp =  g_i3k_game_context:GetFashionPropInWardrobe()
	for k, v in pairs(wardrobeProp) do
		local prop1 = _props[k];
		if prop1 then
			prop1:Set(prop1._valueFD.Base + v, ePropType_Fashion, false, ePropChangeType_Base);
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateOneTimeItemProps(props)
	local _props = props or self._properties;
	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_OneTimeItem,false,ePropChangeType_Base);
		v:Set(0, ePropType_OneTimeItem,false,ePropChangeType_Percent);
	end
	local data = g_i3k_game_context:getOneTimesItemData()
	if next(data) then
		for k, v in pairs(data) do
			local prop = _props[k];
			if prop then
				prop:Set(prop._valueOI.Base + v, ePropType_OneTimeItem,false,ePropChangeType_Base);
			end
		end

	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateTalentProps(props, updateEffector)
	local _props = props or self._properties;

	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Talent,false,ePropChangeType_Base);
		v:Set(0, ePropType_Talent,false,ePropChangeType_Percent);
	end

	local talent = g_i3k_game_context:GetXinfa()
	if g_i3k_game_context then
		if talent then
			if talent._zhiye then
				for k, v in pairs(talent._zhiye) do
					local props = g_i3k_db.i3k_db_get_talent_props(k, v);
					for k1, v1 in pairs(props) do
						local prop = _props[k1];
						if prop then
							prop:Set(prop._valueT.Base + v1 , ePropType_Talent,false,ePropChangeType_Base);
						end
					end
				end
			end

			if talent._jianghua then
				for k, v in pairs(talent._jianghua) do
					local props = g_i3k_db.i3k_db_get_talent_props(k, v);
					for k1, v1 in pairs(props) do
						local prop = _props[k1];
						if prop then
							prop:Set(prop._valueT.Base + v1 , ePropType_Talent,false,ePropChangeType_Base);
						end
					end
				end
			end

			if talent._paibie then
				for k, v in pairs(talent._paibie) do
					local props = g_i3k_db.i3k_db_get_talent_props(k, v);
					for k1, v1 in pairs(props) do
						local prop = _props[k1];
						if prop then
							prop:Set(prop._valueT.Base + v1 , ePropType_Talent,false,ePropChangeType_Base);
						end
					end
				end
			end
		end
	end

	if updateEffector then
		self:UpdateTalentEffector(_props);
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateFightSPProps(props)
	local _props = props or self._properties;
	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_FightSP,false,ePropChangeType_Base);
		v:Set(0, ePropType_FightSP,false,ePropChangeType_Percent);
	end
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			local hero = player:GetHero();
			if hero._guid == self._guid then
				local overlays = hero:GetFightSp()
				local cfg = i3k_db_fightsp[hero._id]
				local LinkSkillID = cfg.LinkSkill
				local lvl = 1
				if hero._skills[LinkSkillID] then
					lvl = hero._skills[LinkSkillID]._lvl
				end
				if overlays > 0 and overlays <= cfg.overlays and cfg.affectType == 1 then
					local props = {}
					local attribute1 = cfg.affectID1
					if attribute1 ~= 0 then
						local value1 = cfg.value1[lvl]*overlays
						local attr = {attribute = attribute1 ,value = value1}
						table.insert(props,attr);
					end
					local attribute2 = cfg.affectID2
					if attribute2 ~= 0 then
						local value2 = cfg.value2[lvl]*overlays
						local attr = {attribute = attribute2 ,value = value2}
						table.insert(props,attr);
					end
					for m,n in pairs(props) do
						local prop = _props[n.attribute];
						if prop then
							prop:Set(prop._valueF.Base + n.value , ePropType_FightSP,false,ePropChangeType_Base);
						end
					end
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateWeaponProps(props)
	local _props = props or self._properties;

	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Weapon,false,ePropChangeType_Base);
		v:Set(0, ePropType_Weapon,false,ePropChangeType_Percent);
	end

	if g_i3k_game_context then
		local weapon = g_i3k_game_context:GetShenbingData();
		if weapon then
			for k, v in pairs(weapon) do
				if v.id then
					if v.qlvl >0 then
						local tlvl = {}
						local attribute1 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].attribute1
						local value1 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].value1
						if attribute1 ~= 0 then
							local attr = {attribute = attribute1 ,value = value1}
							table.insert(tlvl,attr);
						end
						local attribute2 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].attribute2
						local value2 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].value2
						if attribute2 ~= 0 then
							local attr = {attribute = attribute2 ,value = value2}
							table.insert(tlvl,attr);
						end
						local attribute3 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].attribute3
						local value3 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].value3
						if attribute3 ~= 0 then
							local attr = {attribute = attribute3 ,value = value3}
							table.insert(tlvl,attr);
						end
						local attribute4 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].attribute4
						local value4 = i3k_db_shen_bing_uplvl[v.id][v.qlvl].value4
						if attribute4 ~= 0 then
							local attr = {attribute = attribute4 ,value = value4}
							table.insert(tlvl,attr);
						end
						for m,n in pairs(tlvl) do
							local prop = _props[n.attribute];
							if prop then
								prop:Set(prop._valueS.Base + n.value , ePropType_Weapon,false,ePropChangeType_Base);
							end
						end
					end
					if v.slvl >=0 then
						local tlvl = {}
						local attribute1 = i3k_db_shen_bing_upstar[v.id][v.slvl].attribute1
						local value1 = i3k_db_shen_bing_upstar[v.id][v.slvl].value1
						if attribute1 ~= 0 then
							local attr = {attribute = attribute1 ,value = value1}
							table.insert(tlvl,attr);
						end
						local attribute2 = i3k_db_shen_bing_upstar[v.id][v.slvl].attribute2
						local value2 = i3k_db_shen_bing_upstar[v.id][v.slvl].value2
						if attribute2 ~= 0 then
							local attr = {attribute = attribute2 ,value = value2}
							table.insert(tlvl,attr);
						end
						local attribute3 = i3k_db_shen_bing_upstar[v.id][v.slvl].attribute3
						local value3 = i3k_db_shen_bing_upstar[v.id][v.slvl].value3
						if attribute3 ~= 0 then
							local attr = {attribute = attribute3 ,value = value3}
							table.insert(tlvl,attr);
						end
						local attribute4 = i3k_db_shen_bing_upstar[v.id][v.slvl].attribute4
						local value4 = i3k_db_shen_bing_upstar[v.id][v.slvl].value4
						if attribute4 ~= 0 then
							local attr = {attribute = attribute4 ,value = value4}
							table.insert(tlvl,attr);
						end
						for m,n in pairs(tlvl) do
							local prop = _props[n.attribute];
							if prop then
								prop:Set(prop._valueS.Base + n.value , ePropType_Weapon,false,ePropChangeType_Base);
							end
						end
					end
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateSuitProps(props)
	local _props = props or self._properties;
	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_SuitEquip,false,ePropChangeType_Base);
		v:Set(0, ePropType_SuitEquip,false,ePropChangeType_Percent);
	end

	local effectsuits = g_i3k_game_context:GetEffectSuits()

	for k,v in pairs (effectsuits.mysuit) do
		for k1,v1 in pairs(v) do
			local prop = _props[v1.attribute];
			if prop then
				prop:Set(prop._valueSE.Base + v1.value , ePropType_SuitEquip,false,ePropChangeType_Base);
			end
		end
	end
	for k,v in pairs (effectsuits.othersuit) do
		for k1,v1 in pairs(v) do
			local prop = _props[v1.attribute];
			if prop then
				prop:Set(prop._valueSE.Base + v1.value *0.2 , ePropType_SuitEquip,false,ePropChangeType_Base);
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateCollectionProps(props)
	local _props = props or self._properties;

	for k, v in pairs(_props) do
		v:Set(0, ePropType_Collection,false,ePropChangeType_Base);
		v:Set(0, ePropType_Collection,false,ePropChangeType_Percent);
	end

	local allCollection = g_i3k_game_context:getAllCollection()
	for k,v in pairs(allCollection) do
		local isMounted = g_i3k_game_context:testCollectionIsMounted(k)
		local odds = 1
		if isMounted then
			odds = 2
		end
		if v.isEdge then
			odds = 3
		end
		local cfg = i3k_db_collection[k]
		if cfg then
			for i = 1, 2 do
				local attribute = cfg["attrId"..i]
				local value = cfg["attrValue"..i]
				if attribute ~= -1 then
					local prop = _props[attribute];
					if prop then
						prop:Set(prop._valueC.Base + value * odds , ePropType_Collection,false,ePropChangeType_Base);
					end
				end
			end
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateRewardProps(props)
	local _props = props or self._properties;

	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Reward,false,ePropChangeType_Base);
		v:Set(0, ePropType_Reward,false,ePropChangeType_Percent);
	end

	local wequips = g_i3k_game_context:GetWearEquips()
	local lowestQLv = 9999;
	local lowestGLv = 9999;
	local lowestBLv = 9999;
	local Gnum = 0;
	local Qnum = 0;
	local Bnum = 0;
	local EquipCount = i3k_db_common.equip.EquipCount
	local GemCount = i3k_db_common.equip.GemCount
	if wequips then
		for k, v in pairs(wequips) do
			if v.eqGrowLvl ~= 0 and i3k_db_common.equip.equipPropPart[k] then
				if lowestQLv > v.eqGrowLvl  then
					lowestQLv = v.eqGrowLvl
				end
				Qnum = Qnum + 1;
			end
			if v.eqEvoLvl ~= 0 and i3k_db_common.equip.equipPropPart[k] then
				if lowestGLv > v.eqEvoLvl then
					lowestGLv = v.eqEvoLvl
				end
				Gnum = Gnum + 1;
			end
			for k1,v1 in pairs(v.slot) do
				if v1 ~= 0 and i3k_db_common.equip.equipPropPart[k] then
					local Bcfg = g_i3k_db.i3k_db_get_gem_item_cfg(v1);
					if Bcfg then
						local Blv = Bcfg.level
						if lowestBLv > Blv then
							lowestBLv = Blv
						end
						Bnum = Bnum + 1;
					end
				end
			end
		end
		if Qnum ~= EquipCount then
			lowestQLv = 0;
		end
		if Gnum ~= EquipCount then
			lowestGLv = 0;
		end
		if Bnum ~= EquipCount*GemCount then
			lowestBLv = 0;
		end
		if lowestQLv ~= 0 or lowestGLv ~= 0 or lowestBLv ~= 0 then
			for k,v in ipairs (i3k_db_common_award_property) do
					if v.type == 1 and v.args <= lowestQLv then
						local i = 1;
						while v["pro"..i.."ID"] do
							if v["pro"..i.."ID"] ~= 0 then
								local prop1 = _props[v["pro"..i.."ID"]];
								if prop1 then
									prop1:Set(prop1._valueR.Base + v["pro"..i.."Value"], ePropType_Reward,false,ePropChangeType_Base);
								end
							end
							i = i+1
						end
					end
					if v.type == 2 and v.args <= lowestGLv then
						local i = 1;
						while v["pro"..i.."ID"] do
							if v["pro"..i.."ID"] ~= 0 then
								local prop1 = _props[v["pro"..i.."ID"]];
								if prop1 then
									prop1:Set(prop1._valueR.Base + v["pro"..i.."Value"], ePropType_Reward,false,ePropChangeType_Base);
								end
							end
							i = i+1
						end
					end
					if v.type == 3 and v.args <= lowestBLv then
						local i = 1;
						while v["pro"..i.."ID"] do
							if v["pro"..i.."ID"] ~= 0 then
								local prop1 = _props[v["pro"..i.."ID"]];
								if prop1 then
									prop1:Set(prop1._valueR.Base + v["pro"..i.."Value"], ePropType_Reward,false,ePropChangeType_Base);
								end
							end
							i = i+1
						end
					end
			end
		end
	end
	self:OnMaxHpChangedCheck()

	return lowestQLv, lowestGLv, lowestBLv		--全身强化等级、全身升星等级、全身宝石等级
end

function i3k_hero:UpdateMercenaryAchievementProps(props)
	local _props = props or self._properties;

	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_MercenaryAchievement,false,ePropChangeType_Base);
		v:Set(0, ePropType_MercenaryAchievement,false,ePropChangeType_Percent);
	end

	local cfg = i3k_db_mercenaryAchievement
	for k,v in pairs(cfg) do
		if v.type == 1 then
			local count = g_i3k_game_context:GetPetCountByLvl(v.args1)
			if count >= v.mercenarycount then
				local i = 1;
				while v["attr"..i] do
					if v["attr"..i] ~= 0 then
						local prop1 = _props[v["attr"..i]];
						if prop1 then
							prop1:Set(prop1._valueMA.Base + v["value"..i], ePropType_MercenaryAchievement,false,ePropChangeType_Base);
						end
					end
					i = i+1
				end
			end
		elseif v.type == 2 then
			local count = g_i3k_game_context:GetPetCountByStar(v.args1)
			if count >= v.mercenarycount then
				local i = 1;
				while v["attr"..i] do
					if v["attr"..i] ~= 0 then
						local prop1 = _props[v["attr"..i]];
						if prop1 then
							prop1:Set(prop1._valueMA.Base + v["value"..i], ePropType_MercenaryAchievement,false,ePropChangeType_Base);
						end
					end
					i = i+1
				end
			end
		elseif v.type == 3 then
			local count = g_i3k_game_context:GetPetCountByBreakSkillLvl(v.args1)
			if count >= v.mercenarycount then
				local i = 1;
				while v["attr"..i] do
					if v["attr"..i] ~= 0 then
						local prop1 = _props[v["attr"..i]];
						if prop1 then
							prop1:Set(prop1._valueMA.Base + v["value"..i], ePropType_MercenaryAchievement,false,ePropChangeType_Base);
						end
					end
					i = i+1
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateMercenaryRelationProps(props)
	local _props = props or self._properties;

	-- reset all relation properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_MercenaryRelation,false,ePropChangeType_Base);
		v:Set(0, ePropType_MercenaryRelation,false,ePropChangeType_Percent);
	end

	local allData, playData, otherData = g_i3k_game_context:GetYongbingData()
	for k, v in pairs(otherData) do
		if g_i3k_game_context:getIsCompletePetLifeTaskFromID(k) then
			local cfg = i3k_db_suicong_relation[k][v.friendLvl]
			local i = 1;
			while cfg["propertyId"..i] do
				if cfg["propertyId"..i] ~= 0 then
					local prop1 = _props[cfg["propertyId"..i]];
					if prop1 then
						local count = cfg["propertyCount"..i]
						if g_i3k_game_context:getPetStarLvl(k) == #i3k_db_suicong_upstar[k] and not g_i3k_game_context:getPetIsWaken(k) then
							count = count * (i3k_db_common.petBackfit.upCount/10000 + 1)
						elseif g_i3k_game_context:getPetStarLvl(k) ~= #i3k_db_suicong_upstar[k] and g_i3k_game_context:getPetIsWaken(k) then
							count = count * (i3k_db_mercenariea_waken_property[k].upArg/10000 + 1)
						elseif g_i3k_game_context:getPetStarLvl(k) == #i3k_db_suicong_upstar[k] and g_i3k_game_context:getPetIsWaken(k) then
							count = count * (i3k_db_mercenariea_waken_property[k].upArg/10000 + i3k_db_common.petBackfit.upCount/10000 + 1)
						end
						prop1:Set(prop1._valueRL.Base + count, ePropType_MercenaryRelation,false,ePropChangeType_Base);
					end
				end
				i = i+1
			end
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateMercenarySpiritsProps(props)
	local _props = props or self._properties;

	-- reset all relation properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_MercenarySpirits,false,ePropChangeType_Base);
		v:Set(0, ePropType_MercenarySpirits,false,ePropChangeType_Percent);
	end

	local data = {}
	local mapType = g_i3k_game_context:GetWorldMapType()
	local fightPets = g_i3k_game_context:getRoleFightPets()
	for k, v in pairs(fightPets) do
		local spirits = g_i3k_game_context:getPetSpiritsData(k)
		data[k] = spirits
	end
	for k,v in pairs(data) do
		for i,e in pairs(v) do
			if e.id~=0 then
				local cfg = i3k_db_suicong_spirits[e.id][e.level]
				local proId, proCount, isTrue = g_i3k_game_context:GetMercenarySpirits(k, e.id, e.level, 3)
				if proId then
					local prop = _props[proId];
					if prop then
						if not isTrue then
							prop:Set(prop._valueMS.Base + proCount, ePropType_MercenarySpirits,false,ePropChangeType_Base);
						else
							prop:Set(prop._valueMS.Percent + proCount, ePropType_MercenarySpirits,false,ePropChangeType_Percent);
						end
					end
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateSpecialCardProps(props)
	if not g_i3k_db.i3k_is_can_update_property() then
		return 
	end

	local _props = props or self._properties;

	-- reset all specialcard properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_SpecialCard, false, ePropChangeType_Base);
		v:Set(0, ePropType_SpecialCard, false, ePropChangeType_Percent);
	end

	local specialCardProps = g_i3k_game_context:GetRoleSpecialCardsProps()
	for k, v in pairs(specialCardProps) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueSC.Base + v, ePropType_SpecialCard, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateWeaponUniqueSkillProps(props)
	local _props = props or self._properties;
	-- reset all weapon unique skill properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_UniqueSkill,false,ePropChangeType_Base);
		v:Set(0, ePropType_UniqueSkill,false,ePropChangeType_Percent);
	end
	local allShenbing, useShenbing = g_i3k_game_context:GetShenbingData()
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(useShenbing)
	if isOpen == 1 and i3k_db_shen_bing_unique_skill[useShenbing] then
		local info = i3k_db_shen_bing_unique_skill[useShenbing]
		for k,v in pairs(info) do
			local curparameters = v.parameters
			if g_i3k_game_context:isMaxWeaponStar(useShenbing) then
				curparameters = v.manparameters
			end
			if v.uniqueSkillType == 17 then
				self:initSoulEnergy(curparameters[2]);
			end
		end
	end
	for weaponId,weaponCfg in pairs(i3k_db_shen_bing) do
		if weaponCfg.canUse then
			local isUniqueSKillOpen = g_i3k_game_context:GetShenBingUniqueSkillData(weaponId)
			if isUniqueSKillOpen == 1 and i3k_db_shen_bing_unique_skill[weaponId] then
				local info = i3k_db_shen_bing_unique_skill[weaponId]
				for k,v in pairs(info) do
					if v.uniqueSkillType == 2 then
						local curparameters = v.parameters
						if g_i3k_game_context:isMaxWeaponStar(weaponId) then
							curparameters = v.manparameters
						end
						
						local fightData = g_i3k_game_context:getRoleFightPets()
						local numFlag = table.nums(fightData) ~= 0
						local isYongBingBattle = (curparameters[1] == -1 and numFlag) and true or fightData[curparameters[1]];
						local isShenBingBattle = curparameters[2] == -1 and true or useShenbing == weaponId;
						if isYongBingBattle and isShenBingBattle then
							local prop1 = _props[curparameters[3]]
							if prop1 then
								if curparameters[4] == 1 then
									prop1:Set(prop1._valueUS.Base + curparameters[5], ePropType_UniqueSkill, false, ePropChangeType_Base);
								else
									prop1:Set(prop1._valueUS.Percent + curparameters[5], ePropType_UniqueSkill, false,ePropChangeType_Percent);
								end
							end
						end
					end
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateFactionSkillProps(props)
	local _props = props or self._properties;
	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Faction,false,ePropChangeType_Base);
		v:Set(0, ePropType_Faction,false,ePropChangeType_Percent);
	end

	local skill_data = g_i3k_game_context:GetFactionSkillData()
	if skill_data then
		for k, v in pairs(skill_data) do
			local skill_level = v.level
			local _data = i3k_db_faction_skill[k][skill_level]

			local prop = _props[_data.attribute];
			if prop then
				prop:Set(prop._valueFS.Base + _data.value , ePropType_Faction,false,ePropChangeType_Base);
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateProfessionProps(props)
	local _props = props or self._properties;
	-- reset all Profession properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Profession,false,ePropChangeType_Base);
		v:Set(0, ePropType_Profession,false,ePropChangeType_Percent);
	end
	local roleType = g_i3k_game_context:GetCurrentRoleType()
	local transfromLvl = g_i3k_game_context:GetTransformLvl()
	if transfromLvl > 0 then
		for a=1, transfromLvl do
			local BWType = a == 1 and 0 or g_i3k_game_context:GetTransformBWtype()
			for b=1,3 do
				local temp_addAttr = "attribute"..b
				local temp_value = "value"..b
				local attr_data = i3k_db_zhuanzhi[roleType][a][BWType][temp_addAttr]
				local value_data = i3k_db_zhuanzhi[roleType][a][BWType][temp_value]
				local prop = _props[attr_data];
				if prop then
					prop:Set(prop._valuePF.Base + value_data , ePropType_Profession,false,ePropChangeType_Base);
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateTalentEffector(props)
	self:ClsTalents();

	if g_i3k_game_context then
		local all_talent = g_i3k_game_context._xinfa;
		local use_talent = g_i3k_game_context._use_xinfa;

		if not all_talent or not use_talent then
			return false;
		end

		self:ResetExtProperty(true);

		if use_talent._zhiye then
			for _, id in pairs(use_talent._zhiye) do
				self:AddTalent(id, all_talent._zhiye[id]);
			end
		end

		if use_talent._jianghua then
			for _, id in pairs(use_talent._jianghua) do
				self:AddTalent(id, all_talent._jianghua[id]);
			end
		end

		if use_talent._paibie then
			for _, id in pairs(use_talent._paibie) do
				self:AddTalent(id, all_talent._paibie[id]);
			end
		end

		--获得暗器的新法效果ID
		local xinfa = g_i3k_game_context:getHideWeaponXinfa()
		for _, id in ipairs(xinfa) do
			self:AddTalentByID(id)
		end

		--获得暗器皮肤心法id
		local xinfa = g_i3k_game_context:getHideWeaponSkinXinfaPermanent()
		for _, id in ipairs(xinfa) do
			self:AddTalentByID(id)
		end
		--神兵觉醒心法
		local weaponXinFa = g_i3k_game_context:GetWeaponXinFa()
		for i, v in ipairs(weaponXinFa) do
			self:AddTalentByID(v)
		end

		-- 更新被动属性
		self:UpdateExtProperty(props);

		return true;
	end

	return false;
end
--拳师姿态设置
function i3k_hero:SetCombatType(ctype)
	if self._combatType ~= ctype then
		self._combatType = ctype
		self:UpdateCombatTypeProp()
		self:UpdatePassiveProp()
		self:ChangeCombatEffect(self._combatType)		--播放特效
		if self:CanPlayCombatTypeAction(ctype) or ctype == g_BOXER_NORMAL then
			local isMoveing = self._behavior:Test(eEBMove)
			if not isMoveing then
				self:PlayCombatAction(self._combatType)			--播放动作
			end
		end	
	end
end
function i3k_hero:CanPlayCombatTypeAction(combatType)
	return self:GetCombatType() > 0
			and not self:IsInSuperMode() 
			and not self:IsOnRide()
			and not self._missionMode.valid
			and not g_i3k_game_context:GetIsSpringWorld() 
			and not g_i3k_game_context:GetIsInHomeLandZone()
			and not g_i3k_game_context:GetIsInHomeLandHouse()
end
function i3k_hero:PlayCombatAction(ctype)
	self:Play(boxerActionList[ctype], -1)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "UpdateCombatBtnImg")
end
function i3k_hero:ChangeCombatEffect(ctype)
	if self._combatTypeEffect > 0 then
		self:OnStopChild(self._combatTypeEffect)
		self._combatTypeEffect = 0
	end
	if g_i3k_game_context:GetIsSpringWorld() or self._missionMode.valid or self:IsInSuperMode() then
		return
	end
	local curMapType = i3k_game_get_map_type()
	local mapTypes = 
	{
		[g_HOME_LAND] = true,
		[g_HOMELAND_HOUSE] = true,
		[g_DESERT_BATTLE] = true,
		[g_DOOR_XIULIAN] = true,
	}
	if mapTypes[curMapType] then
		return
	end
	if ctype > 0 then
		self._combatTypeEffect = self:PlayHitEffectAlways(boxerEffectList[ctype])
	end
end
function i3k_hero:GetCombatType()
	return self._combatType
end

-- 被动
function i3k_hero:UpdatePassiveProp(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_SkillPassive, false, ePropChangeType_Base);
		v:Set(0, ePropType_SkillPassive, false, ePropChangeType_Percent);
	end

	self:ClsPassivesAi()
	local addPropTb = {}
	local all_skills = g_i3k_game_context:GetRoleSkills()
	for k, v in pairs(all_skills) do
		if g_i3k_db.i3k_db_get_skill_type(k) == eSE_PASSIVE then -- 被动技能
			local skills = g_i3k_game_context:GetLongYinSkills()
			local addLvl = skills[k] or 0
			local skillDataCfg = i3k_db_skill_datas[k][v.lvl + addLvl]
			local state = v.state
			for _, e in ipairs(skillDataCfg.additionalProp) do
				if e.propsCount[state+1] then
					addPropTb[e.propID] = e.propsCount[state+1]
				end
			end
			--拳师被动加成
			local qsAddData = i3k_db_skills[k].skillAddData
			if qsAddData then
				for _,id in ipairs(qsAddData) do
					local data = i3k_db_skill_AddData[id]
					if data.combatType == g_i3k_game_context:GetCombatType() then
						if data.type == g_BOXER_ADD_PASSIVE then 	--类型2 影响被动技能
							local prop = skillDataCfg.additionalProp[data.arg1]
							if prop and prop.propID then
								addPropTb[prop.propID] = addPropTb[prop.propID] + prop.propsCount[state+1] * data.arg2 / 10000
							end
						end  
					end
				end
			end
			--心法被动加成
			local talent = g_i3k_game_context:GetXinfa()
			local useTalent = g_i3k_game_context:GetUseXinfa()
			if useTalent then
				if useTalent._zhiye then
					for _,id in ipairs(useTalent._zhiye) do
						local level = talent._zhiye[id]
						local tDataList = g_i3k_db.i3k_db_get_talent_effector(id, level)
						for _,xiaoGuoData in ipairs(tDataList) do
							if xiaoGuoData.type == g_XINFA_BEIDONG and xiaoGuoData.args.combatTypeID ==  g_i3k_game_context:GetCombatType() and xiaoGuoData.args.passiveID == k then
								local prop = skillDataCfg.additionalProp[xiaoGuoData.args.passivePos]
								if prop and prop.propID then
									addPropTb[prop.propID] = addPropTb[prop.propID] + prop.propsCount[state+1] * xiaoGuoData.args.value / 10000
								end
							end
						end
					end
				elseif useTalent._jinghua then
				elseif useTalent._paibie then
				end
			end
			for _, n in ipairs(skillDataCfg.additionalAiID) do
				local tgcfgId = n[state+1]
				if tgcfgId then
					local tgcfg =  i3k_db_ai_trigger[tgcfgId]
					local mgr = self._triMgr
					if mgr then
						local TRI = require("logic/entity/ai/i3k_trigger");
						local tri = TRI.i3k_ai_trigger.new(self);
						if tri:Create(tgcfg,-1,tgcfgId) then
							local tid = mgr:RegTrigger(tri, self);
							if tid >= 0 then
								table.insert(self._passivesTids, tid);
							end
						end
					end
				end
			end
		end
	end

	for k, v in pairs(addPropTb) do
		local prop = _props[k];
		if prop then
			prop:Set(prop._valueSP.Base + v, ePropType_SkillPassive, false, ePropChangeType_Base);
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:ClsPassivesAi()
	if self._passivesTids then
		if self._triMgr then
			for k, v in ipairs(self._passivesTids) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._passivesTids = {};
	end
end

-- 光环类型的技能
function i3k_hero:UpdateAuraAddBuff(entity)
	local hero = i3k_game_get_player_hero()
	if hero then
		local all_skills = g_i3k_game_context:GetRoleSkills();
		for k, v in pairs(all_skills) do
			if g_i3k_db.i3k_db_get_skill_type(k) == eSE_AURA then
				local skillDataCfg = i3k_db_skill_datas[k][v.lvl]
				local state = v.state
				local isAdd = true
				local skillcfg = i3k_db_skills[k]
				local camp = skillcfg.auraCamp
				local alives = hero._all_alives
				if not ((camp == e_AURA_Type_O and alives[1][entity._guid]) or (camp == e_AURA_Type_E and alives[2][entity._guid])) then
					isAdd = false
				end
				if isAdd then
					local auraBuffs = {}	
					--根据战斗姿态做区分处理
					if self._combatType == g_BOXER_ATTACK then
						auraBuffs = skillDataCfg.attackAuraAddBuffs
					elseif self._combatType == g_BOXER_DEFENCE then
						auraBuffs = skillDataCfg.defenceAuraAddBuffs
					else
						auraBuffs = skillDataCfg.auraAddBuffs
					end
					for _, e in ipairs(auraBuffs) do
						local buffID = e[state+1]
						local bcfg = i3k_db_buff[buffID];
						BUFF = require("logic/battle/i3k_buff");
						local buff = BUFF.i3k_buff.new(nil, buffID, bcfg);
						if buff then
							entity:AddBuff(nil, buff);
						end
					end
				end
			end
		end
	end
end

-- 单机本玩家光环技能给己方，敌方添加buff
function i3k_hero:UpdateOthersAuraAddBuff(entity)
	if entity:IsNeedUpdateAlives() then
		entity:UpdateAuraAddBuff(entity)
	end
end

function i3k_hero:UpdateLongyinProps(props)
	local _props = props or self._properties;
	-- reset all longyin properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Longyin,false,ePropChangeType_Base);
		v:Set(0, ePropType_Longyin,false,ePropChangeType_Percent);
	end

	local longyin = g_i3k_game_context:GetLongYinInfo()
	if longyin then
		local cfg = i3k_db_LongYin_UpLvl[longyin.grade]
		if cfg then
			local i = 1;
			while cfg["propertyId"..i] do
				if cfg["propertyId"..i] ~= 0 then
					local prop1 = _props[cfg["propertyId"..i]];
					if prop1 then
						prop1:Set(prop1._valueLY.Base + cfg["propertyCount"..i], ePropType_Longyin,false,ePropChangeType_Base);
					end
				end
				i = i+1
			end
			if longyin.grade >= 3 then
				self:InitSkills(false);
			end
		end
	end
	local awakenPorp = g_i3k_game_context:getAwakenProp()
	for k, v in pairs(awakenPorp) do
		if v ~= 0 then
			local prop1 = _props[k];
			if prop1 then
				prop1:Set(prop1._valueLY.Base + v, ePropType_Longyin, false, ePropChangeType_Base);
			end
		end
	end
	local fulingProps = g_i3k_game_context:getAllFulingProps()
	for k, v in pairs(fulingProps) do
		if v ~= 0 then
			local prop1 = _props[k];
			if prop1 then
				prop1:Set(prop1._valueLY.Base + v, ePropType_Longyin, false, ePropChangeType_Base);
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateLiLianProps(props)
	local _props = props or self._properties;
	-- reset all longyin properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Lilian,false,ePropChangeType_Base);
		v:Set(0, ePropType_Lilian,false,ePropChangeType_Percent);
	end
	--local lvl = self:GetPropertyValue(ePropID_lvl)
	local lvl = self._lvl
	if lvl >= i3k_db_experience_args.args.openLevel then
		local canwuadd = 10000
		local canwuinfo = g_i3k_game_context:GetCanLevelWuInfo()
		if canwuinfo then
			for k,v in pairs(canwuinfo) do
				local cfg
				for i,j in ipairs(i3k_db_experience_canwu) do
					if k == j[v.lvl].canwuID then
						cfg = j[v.lvl]
					end
				end
				if cfg then
					if cfg["libraryPromote"] ~= 0 then
						canwuadd = canwuadd + cfg["libraryPromote"]
					end
					if cfg["propertyId"] ~= 0 then
						local prop1 = _props[cfg["propertyId"]];
						if prop1 then
							prop1:Set(prop1._valueLL.Base + cfg["propertyCount"], ePropType_Lilian,false,ePropChangeType_Base);
						end
					end
				end
			end
		end

		local cangshuinfo = g_i3k_game_context:GetCheatsInfo();
		if cangshuinfo then
			for k,v in pairs(cangshuinfo) do
				local cfg
				for i,j in ipairs(i3k_db_experience_library) do
					if k == j[v].libraryID then
						cfg = j[v]
					end
				end
				if cfg then
					local i = 1;
					while cfg["propertyId"..i] do
						if cfg["propertyId"..i] ~= 0 then
							local prop1 = _props[cfg["propertyId"..i]];
							if prop1 then
								prop1:Set(prop1._valueLL.Base + cfg["propertyCount"..i]*canwuadd/10000, ePropType_Lilian,false,ePropChangeType_Base);
							end
						end
						i = i+1
					end
				end
			end
		end
		-- 乾坤属性
		local qiankunProps = g_i3k_game_context:getQiankunProps()
		for k1,v1 in pairs(qiankunProps) do
			local prop = _props[v1.attribute];
			if prop then
				prop:Set(prop._valueLL.Base + v1.value , ePropType_Lilian,false,ePropChangeType_Base);
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateTitleProps(props)
	if not g_i3k_db.i3k_is_can_update_property() then
		return 
	end

	local _props = props or self._properties;
	-- reset all title properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_TitleIcon,false,ePropChangeType_Base);
		v:Set(0, ePropType_TitleIcon,false,ePropChangeType_Percent);
	end

	local validTitle = g_i3k_game_context:GetValidTitleInfo()
	for k, v in pairs(validTitle) do
		local cfg = i3k_db_title_base[v]
		if cfg then
			local i = 1;
			while cfg["attribute"..i] do
				if cfg["attribute"..i] ~= 0 then
					local prop1 = _props[cfg["attribute"..i]];
					if prop1 then
						prop1:Set(prop1._valueTI.Base + cfg["value"..i], ePropType_TitleIcon,false,ePropChangeType_Base);
					end
				end
				i = i+1
			end
		end
	end

	self:OnMaxHpChangedCheck()
end

function i3k_hero:UpdateHorseProps(props)
	if not g_i3k_db.i3k_is_can_update_property() then
		return 
	end

	local _props = props or self._properties;
	-- reset all equip properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Horse,false,ePropChangeType_Base);
		v:Set(0, ePropType_Horse,false,ePropChangeType_Percent);
		v:Set(0, ePropType_HorseSkill,false,ePropChangeType_Base);
		v:Set(0, ePropType_HorseSkill,false,ePropChangeType_Percent);
	end

	local rps = g_i3k_game_context:getAllSteedInfo()
	local rid = g_i3k_game_context:getUseSteed()
	local steedSkill = g_i3k_game_context:getSteedSkillLevelData()
	for k,v in pairs (rps) do
		local add = 1;
		if rid == v.id then
			add = i3k_db_steed_common.UseAdd/10000
			if v.star >= 2 then
				local steedcfgTable = {}
				-- local steedlvl = i3k_db_steed_lvl[v.id][v.enhanceLvl].rideLvl --当前坐骑等级
				local prosteed = i3k_db_steed_cfg[v.id].equitationId --先天骑术id
				if prosteed ~= 0 then
					local prosteedcfg = i3k_db_steed_effect[prosteed][steedSkill[prosteed]]
					steedcfgTable[prosteed] = prosteedcfg
				end
				for k1,v1 in pairs(v.curHorseSkills) do
					local steedcfg = i3k_db_steed_effect[v1][steedSkill[v1]]
					steedcfgTable[v1] = steedcfg
				end
				for k1,v1 in pairs(steedcfgTable) do
					for k2,v2 in pairs(v1.SteedeffectIDs) do
						local tcfg = i3k_db_skill_talent[v2]
						if tcfg then
							if tcfg.type == 1 then
								local prop = _props[tcfg.args.pid];
								if prop then
									if tcfg.args.vtype == 1 then
										prop:Set(prop._valueHS.Base + tcfg.args.value , ePropType_HorseSkill,false,ePropChangeType_Base);
									elseif tcfg.args.vtype == 2 then
										prop:Set(prop._valueHS.Percent + tcfg.args.value , ePropType_HorseSkill,false,ePropChangeType_Percent);
									end
								end
							end
						end
					end
				end
			end
		end
		local starCfg = i3k_db_steed_star[v.id][v.star]
		local breakCfg = i3k_db_steed_breakCfg[v.id][v.breakLvl]
		local breakAttrTable = {}
		local attrTable = {
			[starCfg.attrId1] = {attrId = starCfg.attrId1, attrValue = starCfg.attrValue1},
			[starCfg.attrId2] = {attrId = starCfg.attrId2, attrValue = starCfg.attrValue2},
			[starCfg.attrId3] = {attrId = starCfg.attrId3, attrValue = starCfg.attrValue3},
			[starCfg.attrId4] = {attrId = starCfg.attrId4, attrValue = starCfg.attrValue4},
			[starCfg.attrId5] = {attrId = starCfg.attrId5, attrValue = starCfg.attrValue5},
			[starCfg.attrId6] = {attrId = starCfg.attrId6, attrValue = starCfg.attrValue6},
			[starCfg.attrId7] = {attrId = starCfg.attrId7, attrValue = starCfg.attrValue7},
			[starCfg.attrId8] = {attrId = starCfg.attrId8, attrValue = starCfg.attrValue8},
			[starCfg.attrId9] = {attrId = starCfg.attrId9, attrValue = starCfg.attrValue9},
		}

		for k1,v1 in pairs(v.enhanceAttrs) do
			local prop = _props[v1.id];
			if prop then
				prop:Set(prop._valueH.Base + v1.value*add , ePropType_Horse,false,ePropChangeType_Base);
			end
		end
		for k1,v1 in pairs(attrTable) do
			local prop = _props[v1.attrId];
			if prop then
				prop:Set(prop._valueH.Base + v1.attrValue*add , ePropType_Horse,false,ePropChangeType_Base);
			end
		end
		if v.breakLvl > 0 then
			breakAttrTable = {
				[breakCfg.attrId1] = {attrId = breakCfg.attrId1, attrValue = breakCfg.attrValue1},
				[breakCfg.attrId2] = {attrId = breakCfg.attrId2, attrValue = breakCfg.attrValue2},
				[breakCfg.attrId3] = {attrId = breakCfg.attrId3, attrValue = breakCfg.attrValue3},
				[breakCfg.attrId4] = {attrId = breakCfg.attrId4, attrValue = breakCfg.attrValue4},
				[breakCfg.attrId5] = {attrId = breakCfg.attrId5, attrValue = breakCfg.attrValue5},
				[breakCfg.attrId6] = {attrId = breakCfg.attrId6, attrValue = breakCfg.attrValue6},
				[breakCfg.attrId7] = {attrId = breakCfg.attrId7, attrValue = breakCfg.attrValue7},
				[breakCfg.attrId8] = {attrId = breakCfg.attrId8, attrValue = breakCfg.attrValue8},
				[breakCfg.attrId9] = {attrId = breakCfg.attrId9, attrValue = breakCfg.attrValue9},
			}

			for k1,v1 in pairs(breakAttrTable) do
				local prop = _props[v1.attrId];
				if prop then
					prop:Set(prop._valueH.Base + v1.attrValue*add , ePropType_Horse,false,ePropChangeType_Base);
				end
			end
		end
	end

	self:setHorsePropsFromData(g_i3k_game_context:getAllSteedSkinProperty(), _props)
	self:setHorsePropsFromData(g_i3k_game_context:getSteedFightProperty(), _props)
	self:setHorsePropsFromData(g_i3k_game_context:getSteedFightActivateProp(), _props)
	self:setHorsePropsFromData(g_i3k_game_context:getSteedSpiritProperty(), _props)

	self:OnMaxHpChangedCheck()
	self:UpdateHorseAi()
end

function i3k_hero:setHorsePropsFromData(propertyTb, props)
	for k, v in pairs(propertyTb) do
		if v ~= 0 then
			local prop1 = props[k];
			if prop1 then
				prop1:Set(prop1._valueH.Base + v, ePropType_Horse, false, ePropChangeType_Base);
			end
		end
	end
end

function i3k_hero:UpdateHorseAi()
	self:ClsHorseAi()
	local rps = g_i3k_game_context:getAllSteedInfo()
	local rid = g_i3k_game_context:getUseSteed()
	local steedSkill = g_i3k_game_context:getSteedSkillLevelData()
	for k,v in pairs (rps) do
		if rid == v.id then
			if v.star >= 2 then
				-- local steedlvl = i3k_db_steed_lvl[v.id][v.enhanceLvl].rideLvl
				local prosteed = i3k_db_steed_cfg[v.id].equitationId
				local steedcfgTable = {}
				if prosteed ~= 0 then
					local prosteedcfg = i3k_db_steed_effect[prosteed][steedSkill[prosteed]]
					steedcfgTable[prosteed] = prosteedcfg
				end
				for k1,v1 in pairs(v.curHorseSkills) do
					local steedcfg = i3k_db_steed_effect[v1][steedSkill[v1]]
					steedcfgTable[v1] = steedcfg
				end
				for k1,v1 in pairs(steedcfgTable) do
					local world = i3k_game_get_world()
					if world and not world._syncRpc then
						for k2,v2 in pairs(v1.SteedeffectIDs) do
							local tcfg = i3k_db_skill_talent[v2]
							if tcfg then
								if tcfg.type == 2 then
									local mgr = self._triMgr;
									if mgr then
										for k3,v3 in pairs(tcfg.args.aid) do
											local tgcfg = i3k_db_ai_trigger[v3];
											if tgcfg then
												local TRI = require("logic/entity/ai/i3k_trigger");
												local tri = TRI.i3k_ai_trigger.new(self);
												if tri:Create(tgcfg, -1,v2) then
													local tid = mgr:RegTrigger(tri, self);
													if tid >= 0 then
														--i3k_log("add steed ai node id = " .. v2 .. ", trigger id = " .. tid);
														table.insert(self._steedtids, tid);
													end
												end
											end
										end
									end
								elseif tcfg.type == 5 then
									local args = tcfg.args;
									if not self._horseChangeSkill[args.skillID] then
										self._horseChangeSkill[args.skillID] = {}
									end
									info = {eventid = args.eventid,Eventchangetype = args.Eventchangetype,valuetype = args.valuetype,value = args.value}
									table.insert(self._horseChangeSkill[args.skillID],info)
								end
							end
						end
					end
				end
			end
		end
	end
end

function i3k_hero:ClsHorseAi()
	if self._steedtids then
		if self._triMgr then
			for k, v in ipairs(self._steedtids) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._steedtids = {};
	end
	if self._horseChangeSkill and #self._horseChangeSkill > 0 then
		while(#self._horseChangeSkill > 0) do
			table.remove(self._horseChangeSkill,1)
		end
		self._horseChangeSkill = {}
	end
end

function i3k_hero:AddTalent(id, lvl)
	local _T = require("logic/battle/i3k_skill_talent");

	local cfgs = g_i3k_db.i3k_db_get_talent_effector(id, lvl);
	if cfgs then
		for _, cfg in ipairs(cfgs) do
			local talent = _T.i3k_skill_talent.new(id, lvl, cfg);
			if talent:Bind(self) then
				self._talents[talent._guid] = talent;
			end
		end
	end
end

function i3k_hero:AddTalentByID(id)
	local _T = require("logic/battle/i3k_skill_talent");

	local cfg = i3k_db_skill_talent[id]
	if cfg then
		local talent = _T.i3k_skill_talent.new(id, nil, cfg);
		if talent:Bind(self) then
			self._talents[talent._guid] = talent;
		end
	end
end

function i3k_hero:RmvTalent(talent)
	if talent then
		talent:Unbind();

		self._talents[talent._guid] = nil;
	end
end

function i3k_hero:ClsTalents()
	if self._talents then
		for k, v in pairs(self._talents) do
			v:Unbind();
		end
	end

	self._talents = { };
end

function i3k_hero:AddEnmity(entity, force)
	if not entity then
		self:ClsEnmities();

		return false;
	end

	if not entity:IsAttackable(self) then
		return false;
	end
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			local hero = player:GetHero();
			if hero then
				if hero._guid == entity._guid then
					if not hero._enmities or #hero._enmities <= 0 then
						hero._enmities = { };
						hero._enmities[1] = self;

						if hero._onTargetChanged then
							hero._onTargetChanged(self);
						end

						logic:SwitchSelectEntity(self);
					end
				end
			end
		end
	end
	if not self._enmities or #self._enmities <= 0 or force then
		--i3k_log("add enmity " .. entity._guid);

		self._enmities = { };
		self._enmities[1] = entity;

		if self:IsPlayer() then
			if self._onTargetChanged then
				self._onTargetChanged(entity);
			end

			local logic = i3k_game_get_logic();
			if logic then
				logic:SwitchSelectEntity(entity);
			end
		end

		return true;
	end

	return false;
end

-- function i3k_hero:RmvEnmity(entity)
-- 	for k, v in ipairs(self._enmities) do
-- 		if v._guid == entity._guid then
-- 			if self:IsPlayer() then
-- 				local logic = i3k_game_get_logic();
-- 				if logic then
-- 					logic:SwitchSelectEntity(nil);
-- 				end
-- 			end

-- 			table.remove(self._enmities, k);

-- 			break;
-- 		end
-- 	end
-- end

function i3k_hero:ClsEnmities()
	self._enmities = { };
end

function i3k_hero:UpdateEnmities()
	local rmvs = { };
	for k, v in ipairs(self._enmities) do
		local dist = i3k_vec3_len(i3k_vec3_sub1(self._curPos, v._curPos));
		local filterdist = i3k_db_common.engine.unselectTargetDist
		if self:IsPlayer() and self._PVPStatus ~= g_PeaceMode then
			filterdist = i3k_db_common.engine.fightunselectTargetDist
		end
		if not v:IsAttackable(self) or v:IsDead() or dist > filterdist then
			--i3k_log("UpdateEnmities:"..dist)
			table.insert(rmvs, k);
		end
	end

	for k = #rmvs, 1, -1 do
		table.remove(self._enmities, rmvs[k]);
	end

	if #rmvs > 0 then
		if self:IsPlayer() then
			local entity = nil;
			if #self._enmities > 0 then
				entity = self._enmities[1];
			end

			if self._onTargetChanged then
				self._onTargetChanged(entity);
			end

			local logic = i3k_game_get_logic();
			if logic then
				logic:SwitchSelectEntity(entity);
			end
		end
	end
end

function i3k_hero:GetEnmities()
	return self._enmities;
end
function i3k_hero:UpdateEnmitiesTrap(trap)
	local enmities = self._enmities
	local entity = enmities[1]
	if enmities and entity then
		-- local roleID = g_i3k_game_context:GetRoleId()
		-- i3k_log(roleID.." UpdateEnmitiesTrap "..entity._guid)
		if entity:GetGUID() == trap:GetGUID() then
			-- i3k_log(roleID.." UpdateEnmitiesTrap changed "..entity._gid)
			self._enmities = { }
			self._enmities[1] = trap
		end
	end
end

function i3k_hero:OnDead(killerId)
	if self:IsDead() then
		return false;
	end

	local world = i3k_game_get_world();
	self._hp = 0;

	if not world._syncRpc then
		if self:GetEntityType() == eET_Player then
			if not self:CheckDead() then
				return;
			end
		end
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
			if killerId == heroGuid and not g_i3k_ui_mgr:GetUI(eUIID_MonsterPop) and num<=prop and self:IsResCreated() then
				local textIndex = math.random(#i3k_db_dialogue[self._pop.deathPopText])
				g_i3k_ui_mgr:OpenUI(eUIID_MonsterPop)
				g_i3k_ui_mgr:RefreshUI(eUIID_MonsterPop, i3k_db_dialogue[self._pop.deathPopText][textIndex].txt, self)
			end
		end
	end

	if self:GetEntityType() == eET_Player then
		self:CheckMissionRide(false);
		g_i3k_game_context:clearWeaponStatus()
	end
	self:SetDeadState(true)

	if self:IsPlayer() and not world._syncRpc then
		self._tmpSp = self._sp
		self:UpdateProperty(ePropID_sp, 1, self._sp *0.5, true, false,true);
		if self:IsInSuperMode() then
			self:SuperMode(false)
			self:UpdateProperty(ePropID_sp, 1, 0, true, false,true);
		end
	end
	if not self:IsPlayer() then
		self._sp = 0;
	else
		self._internalInjuryState.value = 0
		--self:SetDigStatus(0)
		g_i3k_game_context:SetMineInfo(nil)
		self._DigStatus = 0
		g_i3k_game_context:OnMineStatusChangedHandler(0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "stopWeaponFullAnis")
	end
	self._fightsp	= 0;
	self._killerId = killerId;

	if i3k_game_get_map_type() == g_BASE_DUNGEON then
		self:OnDeadClsBuffs();
	end
	self:ClsChilds();
	self:ClsAttackers();
	self:ClsEnmities();
	self:ClearFindwayStatus()
	self:StopMove()
	self:updateRoleLifeCount()
	if self._entityType == eET_Mercenary then
		local guid2 = string.split(self._guid, "|")
		g_i3k_game_context:OnFightMercenaryHpChangedHandler(tonumber(guid2[2]), self:GetPropertyValue(ePropID_hp), self:GetPropertyValue(ePropID_maxHP))
		if world and not world._syncRpc then
			i3k_sbean.privatemap_update_hp(self,self._hp,guid2[2])
		end
		self:UpdateProperty(ePropID_sp, 1, 0, true, false, true);
	end
	self:DetachPetGuard()--死亡清除守护灵兽
	return true;
end

function i3k_hero:clearWeaponSp()
	self:UpdateProperty(ePropID_sp, 1, 0, true, false,true);
end

function i3k_hero:OnRevive(pos, hp, sp)

	if not self:IsDead() then
		return false;
	end

	if self:GetEntityType() == eET_Mercenary and g_i3k_game_context:GetPetGuardIsShow() then
		self:AttachPetGuard(g_i3k_game_context:GetCurPetGuard()) --复活挂载守护灵兽模型
	end
	if self:GetEntityType() == eET_Player and self._inPetLife and g_i3k_game_context:GetPetGuardIsShow() then
		self:AttachPetGuard(g_i3k_game_context:GetCurPetGuard()) --复活挂载守护灵兽模型
	end

	if self._behavior:Test(eEBRevive) then
		return false;
	end

	self._revivePos	= pos;
	--self._reviveHP	= hp;
	self._reviveSP	= sp;

	if not (self:GetEntityType() == eET_Player or self:GetEntityType() == eET_Mercenary) then
		self:OnRevived();
	end

	return true;
end

function i3k_hero:OnRevived()
	if not self._behavior:Test(eEBRevive) then
		return false;
	end
	--self._behavior:Clear(eEBRevive);

	self:SetDeadState(false)
	if self:GetEntityType() == eET_Player then
		self:CheckMissionRide(true);
		self._killerId = 0;
	end
	self:ShowTitleNode(true);

	if self._revivePos then
		self:SetPos(self._revivePos)
		self:ClearMoveState();
	end

	if self._reviveHP then
		self:OnDamage(self,1, self:GetPropertyValue(ePropID_hp) - self._reviveHP , false, 1, false, true);
	end
	if not self:IsPlayer() then
		self:UpdateProperty(ePropID_hp, 1, self:GetPropertyValue(ePropID_maxHP), false, false);
	else
		self:onRevieArmorValue()
		if i3k_game_get_map_type() == g_BASE_DUNGEON then
			self:UpdateHeroBuffDrug()
		end
	end
	if self._reviveSP then
		self:UpdateProperty(ePropID_sp, 1, self._reviveSP, false, false);
	else
		self:UpdateProperty(ePropID_sp, 1, 0, false, false);
	end

	self._reviveHP = nil;
	self:UpdateHorseAi();
	g_i3k_game_context:UpdatePassiveAuraProp()
end

function i3k_hero:OnDodge(attacker, sourceType, skillID)
	local hero = i3k_game_get_player_hero()
	if self:IsPlayer() or attacker:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill or self:GetEntityType() == eET_Summoned) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or ((attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill or attacker:GetEntityType() == eET_Summoned)and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or g_i3k_game_context:IsTeamMember(attacker:GetGuidID()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
		local s = i3k_db_skills[skillID].specialArgs
 		if s.hitTarget then
 			self:ShowInfo(attacker, eEffectID_Dodge.style, i3k_get_string(17316), nil, sourceType);
 		else
 			self:ShowInfo(attacker, eEffectID_Dodge.style, eEffectID_Dodge.txt, nil, sourceType);
 		end
	end
end

function i3k_hero:OnRemit(attacker, sourceType)
	local hero = i3k_game_get_player_hero()
	if self:IsPlayer() or attacker:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill or self:GetEntityType() == eET_Summoned) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or ((attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill or attacker:GetEntityType() == eET_Summoned)and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or g_i3k_game_context:IsTeamMember(attacker:GetGuidID()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
		self:ShowInfo(attacker, eEffectID_Dodge.style, i3k_get_string(429), nil, sourceType);
	end
end

function i3k_hero:OnReduce(attacker, value, sourceType)
	-- local hero = i3k_game_get_player_hero()
	-- if self:IsPlayer() or attacker:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill or self:GetEntityType() == eET_Summoned) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or ((attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill or attacker:GetEntityType() == eET_Summoned)and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or g_i3k_game_context:IsTeamMember(attacker:GetGuidID()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
		self:ShowInfo(attacker, eEffectID_Reduce.style, eEffectID_Reduce.txt .. ' + ' .. value, nil, sourceType);
	-- end
end

function i3k_hero:OnImmune (attacker, sourceType)
	local hero = i3k_game_get_player_hero()
	if self:IsPlayer() or attacker:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill or self:GetEntityType() == eET_Summoned) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or ((attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill or attacker:GetEntityType() == eET_Summoned)and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or g_i3k_game_context:IsTeamMember(attacker:GetGuidID()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
		self:ShowInfo(attacker, eEffectID_Dodge.style, i3k_get_string(1057), nil, sourceType);
	end
end

function i3k_hero:OnDamage(attacker, atr, val, cri, stype, showInfo, update, SourceType, direct, buffid, armor, isCombo, godStarSplite, godStarDefend)
	if not self._hp then return; end
	local hero = i3k_game_get_player_hero()
	if self:GetEntityType()==eET_Monster and not self._isAttacked and attacker._guid and attacker._guid==hero._guid and not g_i3k_ui_mgr:GetUI(eUIID_MonsterPop) then
		self._isAttacked = true
		local prop = self._pop.startPopProp*10;
		local num = math.random(0, 10)
		num = num==0 and 1 or math.ceil(num)
		if num<=prop and self:IsResCreated() then
			--打开冒泡
			local textIndex = math.random(#i3k_db_dialogue[self._pop.startPopText])
			g_i3k_ui_mgr:OpenUI(eUIID_MonsterPop)
			g_i3k_ui_mgr:RefreshUI(eUIID_MonsterPop, i3k_db_dialogue[self._pop.startPopText][textIndex].txt, self)
			self._isPop = true
		end
	end
	if attacker and attacker._guid ~= self._guid and stype ~= eSE_Buff then
		self._lastAttacker = attacker;
		local mapType = i3k_game_get_map_type();
		local notAdd = false;
		if hero and attacker:GetEntityType() == eET_Pet and (not hero._enmities or #hero._enmities <= 0) then
			notAdd = true
		end
		if mapType and (mapType == g_ARENA_SOLO or mapType == g_TAOIST or mapType == g_QIECUO) then
			notAdd = true;
		end
		if not notAdd then
			self:AddEnmity(attacker);
		end
		if self:GetEntityType() == eET_Player and attacker:GetEntityType() == eET_Player and mapType == g_FIELD then
			self._updatePkTipTime = 0;
			self._isShowPkTip = true;
		end
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
		local maxHP = self:GetPropertyValue(ePropID_maxHP);
		local hp = self._hp;
		local hpchange = dv;
		local hero = i3k_game_get_player_hero()
		if stype == eSE_Damage then
			hp = hp - dv;
			if hp < 0 then
				hpchange = dv + hp;
			elseif hp > maxHP then
				hpchange = maxHP - hp - dv;
			end

			if self:IsPlayer() or (attacker and attacker:IsPlayer()) or (self._hoster and self._hoster:IsPlayer()) or (attacker and attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill or self:GetEntityType() == eET_Summoned) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or (attacker and (attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill or attacker:GetEntityType() == eET_Summoned)and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or (attacker and g_i3k_game_context:IsTeamMember(attacker:GetGuidID())) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
				local armorDamage = ""
				if armor then
					if armor.damage>0 then
						self:UpdateArmorValue(self._armorState.value - armor.damage)
						armorDamage = string.format("(%s)", armor.damage)
					end
					if armor.suck~=0 then
						self:PlayHitEffect(i3k_db_under_wear_alone.underWearAbsorbEffect)
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateNeijiaGet", armor.suck)
					end
					if armor.destroy~=0 then
						self:PlayHitEffect(i3k_db_under_wear_alone.underWearDamagedEffect)
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateNeijiaDamage", armor.destroy)
					end
				end
				if _info then
					if hpchange >= 0 then
						local godStarDesc = "" --神斗技能 冒字
						if godStarDefend then
							godStarDesc = godStarDesc .. " " .. i3k_get_string(1712)
						end
						if godStarSplite then
							godStarDesc = godStarDesc .. " " .. i3k_get_string(1713)
						end
						if cri then
							self:ShowInfo(attacker, eEffectID_DamageCri.style, eEffectID_DamageCri.txt .. ' - ' .. hpchange .. armorDamage .. godStarDesc, nil, SourceType);
						elseif atr == 2 then
							self:ShowInfo(attacker, eEffectID_DodgeEx.style, eEffectID_DodgeEx.txt .. ' - ' .. hpchange .. armorDamage .. godStarDesc, nil, SourceType);
						else
							self:ShowInfo(attacker, eEffectID_Damage.style, '- ' .. hpchange .. armorDamage .. godStarDesc, nil, SourceType);
						end
					elseif hpchange < 0 then
						self:ShowInfo(attacker, eEffectID_Heal.style, '+ ' .. math.abs(hpchange), nil, SourceType);
					end
				end
			end

			if not update and self._triMgr and attacker and not isCombo then
				self._triMgr:PostEvent(self, eTEventDamage, hpchange, _direct, buffid or -1, cri);
				self._triMgr:PostEvent(self, eTEventHit, attacker, _direct, buffid or -1,cri);
				if attacker:IsPlayer() then
					attacker._triMgr:PostEvent(attacker, eTEventToHit, attacker, _direct, buffid or -1,cri);
				end
			end
		elseif stype == eSE_Buff then
			hp = hp + dv;
			if hp < 0 then
				hpchange = dv - hp;
			elseif hp > maxHP then
				hpchange = maxHP -hp  +dv;
			end

			if hpchange > 0 then
				if _info then
					if self:IsPlayer() or (attacker and attacker:IsPlayer()) or (self._hoster and self._hoster:IsPlayer()) or (attacker and attacker._hoster and attacker._hoster:IsPlayer()) or ((self:GetEntityType() == eET_Pet or self:GetEntityType() == eET_Skill or self:GetEntityType() == eET_Summoned) and hero and self._hosterID and hero:GetGuidID() == self._hosterID) or (attacker and (attacker:GetEntityType() == eET_Pet or attacker:GetEntityType() == eET_Skill or attacker:GetEntityType() == eET_Summoned) and hero and attacker._hosterID and hero:GetGuidID() == attacker._hosterID) or (attacker and g_i3k_game_context:IsTeamMember(attacker:GetGuidID())) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
						if cri then
							self:ShowInfo(attacker, eEffectID_HealCri.style, eEffectID_HealCri.txt .. ' + ' .. hpchange, nil, SourceType);
						else
							self:ShowInfo(attacker, eEffectID_Heal.style, '+ ' .. hpchange, nil, SourceType);
						end
					end
				end
			end

			if not update and self._triMgr and not isCombo then
				self._triMgr:PostEvent(self, eTEventHeal, hpchange, direct, buffid or -1,cri);
			end
		end

		if self:IsPlayer() and self._behavior:Test(eEBUndead) then
			local item = self._behavior:GetValue(eEBUndead)
			if hp < item.value then
				hp = item.value
				--self._hp = hp;
			end
		end

		if hp < 0 then
			hp = 0;
		elseif hp > maxHP then
			hp = maxHP;
		end
		hp = i3k_integer(hp);
		--self:UpdateBloodBar(hp / maxHP);

		if self._hp ~= hp or hp == 0 then
			self._hp = hp;

			if self._hp == 0 then
				if self:IsPlayer() and g_i3k_game_context:isOnSprog() then --新手关血量为零时，血量回满
					self:UpdateHP(self:GetPropertyValue(ePropID_maxHP))
				else
					if not self:IsDead() then
						local world = i3k_game_get_world();
						if world and not world._syncRpc then
							if not self._behavior:Test(eEBGotodead) then
								self._triMgr:PostEvent(self, eTEventDead);
							end
						end
						if not world._syncRpc and self:CheckDead() then
							local guid = string.split(attacker._guid, "|")
							self:OnDead(tonumber(guid[2]));
						end
					end
				end
			end

			self:OnPropUpdated(ePropID_hp, self._hp);
			self:SyncDamageReward()
		end

		if self:GetEntityType()==eET_Monster then--and self._isBoss and self._cfg.boss==2 then
			local monsterCfg = i3k_db_monsters[self._id]
			if monsterCfg.changePercent>0 and monsterCfg.newMonsterId>0 then
				local maxHp = self:GetPropertyValue(ePropID_maxHP);
				if self._hp~=0 and (monsterCfg.changePercent>0 and self._hp/maxHp<=monsterCfg.changePercent) then
					if not self.changeModel then
						self:UpdateProperty(ePropID_maxHP, 1, self._hp, true, false, true);--播放动画，变身，
						i3k_game_play_scene_ani(monsterCfg.changeAnisId)
						i3k_game_pause()
						--换entity
						--之前的先死掉
						local world = i3k_game_get_world()
						local SEntity = require("logic/entity/i3k_monster");
						local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid_new(SEntity.i3k_monster.__cname,i3k_gen_entity_guid()));
						monster:Create(monsterCfg.newMonsterId, false);
						monster:AddAiComp(eAType_IDLE);
						monster:AddAiComp(eAType_AUTO_MOVE);
						monster:AddAiComp(eAType_ATTACK);
						monster:AddAiComp(eAType_AUTO_SKILL);
						monster:AddAiComp(eAType_FIND_TARGET);
						monster:AddAiComp(eAType_SPA);
						monster:AddAiComp(eAType_SHIFT);
						monster:AddAiComp(eAType_DEAD);
						monster:AddAiComp(eAType_GUARD);
						monster:AddAiComp(eAType_RETREAT);
						monster:AddAiComp(eAType_FEAR);
						monster:Birth(self._curPos);
						monster:Show(true, true, 100);
						monster:SetGroupType(eGroupType_E);
						monster:SetFaceDir(0, 0, 0);
						monster:Play(i3k_db_common.engine.defaultStandAction, -1);
						if monster and monster._cfg.birtheffect then
							monster:PlayHitEffect(monster._cfg.birtheffect)
						end
						world:AddEntity(monster);
						world:ReleaseEntity(self)
						monster.changeModel = true
						monster._spawnID = self._spawnID
					end
				end
			end
		end
	end
end

-- 单机本 怪物血量掉落
function i3k_hero:SyncDamageReward()
	local world = i3k_game_get_world()
	if not world._syncRpc and self:GetEntityType() == eET_Monster then
		if self._spawnID > 0 then
			local damageHpRatio = self._baseCfg.damageHpRatio
			local earlyDrop = world:GetEarLyDropInfo(self._spawnID)
			if damageHpRatio[1] ~= 0 and  table.nums(earlyDrop) > 0 then
				local ratioHp = self._hp / self:GetPropertyValue(ePropID_maxHP)
				local hpTb = {}
				for i, e in ipairs(damageHpRatio) do
					if e / 10000 >= ratioHp and not self._hpDrop[e] and earlyDrop[e] > 0 then
						table.insert(hpTb, e)
						self._hpDrop[e] = true
						world:SetEarLyDropInfo(self._spawnID, e)
					end
				end
				if #hpTb > 0 then
					local args = { spawnPointID = self._spawnID, pos = self._curPos, index = hpTb}
					i3k_sbean.sync_privatemap_damage_reward(args)
				end
			end
		end
	end
end

function i3k_hero:OnSpa()
	if not self._behavior:Test(eEBSpasticity) then
		self._behavior:Set(eEBSpasticity);
	end
end

function i3k_hero:OnShift(dir, info, sender)
	if not self._behavior:Test(eEBShiftResist) then
		if self._behavior:Set(eEBShift) then
			self._shiftInfo = { };
			self._shiftInfo.dir		= dir;
			self._shiftInfo.info	= info;
			self._shiftInfo.type	= info.type;
			self._shiftInfo.height	= info.height
			self._shiftInfo.sender	= sender;
			self._shiftInfo.target	= self;
			if info.endPos then
				self._shiftInfo.endPos
									= i3k_logic_pos_to_world_pos(info.endPos);
			end

			--if self:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
				local shift_str;
				if info.type == 3 then
					shift_str = i3k_get_string(169); -- 拖拽
				elseif info.height == 0 then
					shift_str = i3k_get_string(162); -- 击退
				else
					shift_str = i3k_get_string(568); -- 击飞
				end
				self:ShowInfo(sender, eEffectID_DeBuff.style, shift_str, i3k_db_common.engine.durNumberEffect[2] / 1000);
			--end

			return true;
		end
	end

	return false;
end

function i3k_hero:SyncShift(dir, info)
	self:OnShift(dir, info);
end

function i3k_hero:OnStopShift()
	self._shiftInfo = nil;

	self._behavior:Clear(eEBShift);
end

function i3k_hero:StopMove()
	BASE.StopMove(self);

	self._behavior:Clear(eEBRetreat);
end

function i3k_hero:OnBehavior(caller, bh, value)
	BASE.OnBehavior(self, caller, bh);

	if bh == eEBSleep or bh == eEBStun or bh == eEBFreeze or bh == eEBPetrifaction or bh == eEBSpasticity or bh == eEBScarecrow or bh == eEBShift or bh == eEBTaunt or bh == eEBFear then
		self:BreakAttack(-1);
	end

	if bh == eEBGuard then
		self:UpdateProperty(ePropID_speed, 1, self._cfg.guard.speed, true, false, true);

		self._entity:SetActionSpeed(i3k_db_common.engine.defaultRunAction, self._cfg.guard.speed / self._cfg.speed);
	end

	if bh == eEBRetreat then
		self:ClsEnmities();
		self:SetTarget(nil);
		if self:GetEntityType() ~= eET_Player then
			self:UpdateProperty(ePropID_hp, 1, self:GetPropertyValue(ePropID_maxHP), true, false, true);
		end
	end

	if bh == eEBTaunt then
		local logic = i3k_game_get_logic();
		if caller then
			self._forceAttackTarget = caller;

			self:AddEnmity(caller, true);
		end
		self:ClearMoveState()
	end

	if bh == eEBResetSkill then
		local world = i3k_game_get_world()
		if not world._syncRpc then
			self:OnRandomResetSkill();
		end
	end

	if bh == eEBQuickCool then
		local world = i3k_game_get_world()
		if not world._syncRpc then
			self:OnRandomDesSkillCoolTime(value.value);
		end
	end

	if bh == eEBSilent then
		self:BreakAttack(eSG_Skill);
	end

	if bh == eEBDisDodgeSkill then
		self:OnEnableDodgeSkill(false);
	end

	if bh == eEBProlongBuff then
		self:OnProlongBuff(true, value);
	elseif bh == eEBProlongDBuff then
		self:OnProlongBuff(false, value);
	end

	if bh == eEBInvisible then
		local world = i3k_game_get_world();
		if self:IsPlayer() then
			if self:IsAutoFight() then
				g_i3k_game_context:SetAutoFight(false)
			end
		end
		if self:IsPlayerOrTeam() then
			if world and not world._syncRpc then
				world:UpdatePKState(self);
			end
			self:SetColor(g_Translucence);
			if self._curWeaponSoul and g_i3k_game_context:GetWeaponSoulCurHide() then
				self:SetLinkChildColor(self._curWeaponSoul, g_Translucence)
			else
				self:DetachWeaponSoul()
			end
		elseif self:GetEntityType() == eET_Player or self:GetEntityType() == eET_Monster then
			self:SetTarget(nil);
			self:ChangeGroup(true)
			self:Show(false, true);
			self:ShowWeaponSoul(false);
			self:SetHittable(false)
		end
	end

	if self:GetEntityType() == eET_Player then
		if bh == eEBFloating then
			self:PlayFloatingAction()
		end
	end
end

function i3k_hero:OnBehaviorUpdate(caller, bh, value)
	BASE.OnBehaviorUpdate(self, caller, bh);

	if bh == eEBResetSkill then
		local world = i3k_game_get_world()
		if world and not world._syncRpc then
			self:OnRandomResetSkill();
		end
	end
end

function i3k_hero:OnClearAfterBehavior(bh)
	BASE.OnLeaveBehavior(self, bh);
	if bh == eEBInvisible then
		local world = i3k_game_get_world()
		if self:IsPlayer() then
			if world and not world._syncRpc then
				world:UpdatePKState(self);
			end
		end
	end
end

function i3k_hero:OnLeaveBehavior(bh)
	BASE.OnLeaveBehavior(self, bh);

	if bh == eEBRevive then
		self:OnRevived();
	elseif bh == eEBGuard then
		self:UpdateProperty(ePropID_speed, 1, self._cfg.speed, true, false, true);
		if self._entity then
			self._entity:SetActionSpeed(i3k_db_common.engine.defaultRunAction, 1);
		end
	elseif bh == eEBRetreat then
		self:ClsEnmities();
		self:SetTarget(nil);
		if self:GetEntityType() ~= eET_Player then
			self:UpdateProperty(ePropID_hp, 1, self:GetPropertyValue(ePropID_maxHP), true, false, true);
		end
	elseif bh == eEBTaunt then
		self._forceAttackTarget = nil;
	elseif bh == eEBDisDodgeSkill then
		self:OnEnableDodgeSkill(true);
	elseif bh == eEBInvisible then
		self:Show(true, true, 300);
		self:SetHittable(true)
		local isChage = true;
		if self:IsPlayerOrTeam() then
			if self:IsPlayer() and  g_i3k_game_context:GetWeaponSoulCurHide() then
				if g_i3k_game_context:GetWeaponSoulCurHide() then
					self:ShowWeaponSoul(true);
				end
			else
				if self._curWeaponSoulShow then
					self:ShowWeaponSoul(true);
				end
			end
			isChage = false;
		else
			if self._curWeaponSoulShow then
				self:ShowWeaponSoul(true);
			else
				self:ShowWeaponSoul(false);
			end
		end
		if isChage and (self:GetEntityType() == eET_Player or self:GetEntityType() == eET_Monster) then
			self:ChangeGroup();
		end
	end
end

function i3k_hero:IsPlayerOrTeam()
	local guid = string.split(self._guid, "|")
	local RoleID = tonumber(guid[2])
	local world = i3k_game_get_world();
	if world._mapType == g_BUDO then
		local hero = i3k_game_get_player_hero()
		if self._forceType == hero._forceType then
			return true;
		end
	end
	if self:IsPlayer() or g_i3k_game_context:IsTeamMember(RoleID) then
		return true;
	end
	return false;
end

function i3k_hero:ClsInvisible(target)
	if self:GetEntityType() == eET_Trap and target._behavior:Test(eEBInvisible) then
		local invisBreak = target:GetPropertyValue(ePropID_InvisBreak);
		if invisBreak then
			local rnd1 = i3k_engine_get_rnd_f(0, 1)
			if invisBreak <= rnd1 then
				target:ClsBuffByBehavior(eEBInvisible);
			end
		end
	end
end

function i3k_hero:ChangeGroup(isAdd)
	local world = i3k_game_get_world()
	if world then
		local groupType = self:GetEntityType() == eET_Player and eGroupType_O or eGroupType_E
		if isAdd then
			groupType = eGroupType_N
		end
		self:SetGroupType(groupType);
		world:UpdatePKState(self);
	end
end

function i3k_hero:TearWoundB(target, dam)
	if self._behavior:Test(eEBTearWoundB) then
		local maxHP = self:GetPropertyValue(ePropID_maxHP);
		local hp = self._hp;
		local valueA = self._behavior:GetValue(eEBTearWoundB)
		local arg1,arg2  = math.modf(tonumber(valueA.value) / 100);
		local dv = math.floor(arg2 * dam);
		self._TearWoundB = self._TearWoundB + dv;
		if self._TearWoundB > arg1 then
			self._TearWoundB = 0;
			self:ClsBuffByBehavior(eEBTearWoundB);
		end
		hp = hp - dv;
		local hpchange = dv;
		if hp < 0 then
			hpchange = dv + hp;
		elseif hp > maxHP then
			hpchange = maxHP - hp - dv;
		end
		self:ShowInfo(target, eEffectID_Damage.style, '- ' .. hpchange, nil, SourceType);
		self:OnPropUpdated(ePropID_hp, self._hp);
	end
end

function i3k_hero:ProcessDamage(skill, target, sdata, ticknum, isCombo)
	if not skill or not sdata or not target or target:IsDead() then
		return false, true;
	end

	if skill._cfg.type == eSE_Damage then
		if self:IsPlayer() and skill._gtype ~= eSG_TriSkill then
			if not self._autonormalattack then
				if self._preautonormalattack then
					self._autonormalattack = true;
				end
			end
		end
	end

	local _atr = skill:IsAtr(self, target, sdata);
	if _atr == 0 and target:GetEntityType() ~= eET_Trap then
		if target:GetGroupType() ~= eGroupType_N then
			target:OnDodge(self, nil, skill._cfg.id); -- 闪避
		end
		if target._triMgr  then
			target._triMgr:PostEvent(self, eTEventDodge, self);
			self._triMgr:PostEvent(self, eTEventMiss);
		end
		return false, true;
	end
	if skill._cfg.type == eSE_Damage then
		-- target:Checkunride()
	end
	local dam = 0;
	local sbv = 0;
	local cri = false;
	local red = false;
	local armor = {}

	local odds = (sdata.damage.odds + skill:TalentSkillChange(self,eSCType_Event,eSCEvent_odds,ticknum)) / 100;
	if i3k_engine_get_rnd_u(0, 100) < odds then
		local lastDead = true;

		if #self._alives[2] > 0 then
			for k, v in ipairs(self._alives[2]) do
				if not v.entity:IsDead() then
					lastDead = false;

					break;
				end
			end
		end

		if self:IsDead() and lastDead then
			return false, true;
		end

		dam, sbv, cri, red, remit, armor = skill:GetDamage(_atr, self, target, sdata, isCombo);
		if dam ~= 0 then
			if self._weaponBless.ID ~= 0 and not self._syncRpc and g_i3k_game_context:GetActiveWeaponBlessID() then
				self:onBlessSkillState() --武器祝福
			end
		end
		if remit then
			if remit == 1 then
				target:OnRemit(self);
			else
				target:OnImmune(self); -- 狼印
			end
			return false, true;
		end

		if cri then
			g_i3k_camera_shake_effect:Play();
		end

		-- 吸收
		if red.valid then
			target:OnReduce(self, red.value);
		end

		local beforeHp = target:GetPropertyValue(ePropID_hp)

		target:OnDamage(self, _atr, dam, cri, skill._cfg.type, true, false, nil, true, nil, armor);
		local afterHp = target:GetPropertyValue(ePropID_hp)
		self:TestFloationBehavior(target, beforeHp - afterHp)
		self:UpdateDamageRank(target, beforeHp - afterHp)

		local world = i3k_game_get_world()
		if world and not world._syncRpc then
			if target:IsPlayer() then
				self:ClsInvisible(target);
				if self:GetEntityType() == eET_Monster then
					self:TearWoundB(target, dam);
				end
				--战斗能量条件1触发
				target:OnFightTime(0.01)
				if skill._cfg.type == eSE_Damage then
					local talentadd = false
					local talentodds = 0
					local cfg = i3k_db_fightsp[target._id]
					if target._talents then
						for k,v in pairs(target._talents) do
							if v._id == cfg.TalentID then
								talentadd = true
								talentodds = cfg.TriProc2[math.floor(v._lvl/7)+1]
								break;
							end
						end
					end

					if target._behavior:Test(eEBFightSP) or talentadd then
						local add = 0
						if target._validSkills[tonumber(cfg.LinkSkill)] then
							add = tonumber(target._validSkills[tonumber(cfg.LinkSkill)].state)*tonumber(i3k_db_fightsp[target._id].SkillAdd)
						end

						for k,v in pairs(cfg.TriCond) do
							if tonumber(v) == 1 then
								local rollnum = i3k_engine_get_rnd_u(0, 10000);
								local odds = cfg.TriProc1+add+talentodds
								if rollnum < odds then
									local overlay = target:GetFightSp()
									if overlay >= 0 and overlay < cfg.overlays then
										overlay = overlay + 1;

										target:UpdateFightSp(overlay);
									end
								end
							end
						end
					end
				end
			end
		end

		if sdata.hitEffID > 0 then
			target:PlayHitEffect(sdata.hitEffID);
		end

		local sound = i3k_db_sound[sdata.hitSoundID];
		if sound then
			if target._entity then
				target._entity:PlaySFX(sound.path, false, 0.1, 1.0, 1.0);
			end
		end
	end

	--拳师姿态额外附加buff
	if self._combatType > 0 then
		for _,id in ipairs(skill._qs_skillAddData) do
			local data = i3k_db_skill_AddData[id]
			--根据姿态
			if data.type == g_BOXER_ADD_BUFF and data.combatType == self._combatType and data.arg1 == ticknum then
				sdata.status[data.arg2] = {}
				sdata.status[data.arg2].buffID = data.arg4
				sdata.status[data.arg2].odds = data.arg3
			end
		end
	end
	-- buff
	for k = 1, 2 do
		local bid = sdata.status[k].buffID;

		local bcfg = i3k_db_buff[bid];
		if bcfg then
			local odds = (sdata.status[k].odds + skill:TalentSkillChange(self,eSCType_Event,eSCEvent_sodds1,ticknum,k)) / 10000;
			if bcfg.resID > 0 then
				local res = self:GetPropertyValue(bcfg.resID);
				if bcfg.owner ~= 1 then
					res = target:GetPropertyValue(bcfg.resID);
				end

				odds = math.max(0, odds - res);
			end
			if bcfg.buffMasterID > 0 then
				local masterVal = self:GetPropertyValue(bcfg.buffMasterID);
				odds = math.max(0, odds + masterVal)
			end

			if bid > 900000 and bid < 999999 then
				bcfg.affectValue = sdata.status[k].affectValue
				bcfg.loopTime = sdata.status[k].loopTime
			end

			if i3k_engine_get_rnd_f(0, 1) < odds then
				if bcfg.affectType == 2 and (bcfg.affectID == eEBDispelBuff or bcfg.affectID == eEBDispelDBuff) then
					if bcfg.owner ~= 1 then
						target:DispelBuff(bcfg.affectID, bcfg.affectValue,bcfg.note);
					else
						self:DispelBuff(bcfg.affectID, bcfg.affectValue,bcfg.note);
					end
				elseif bcfg.affectType == 2 and bcfg.affectID == eEBSetFightSP then
					if bcfg.owner ~= 1 then
						target:ChangeFightSP(bcfg.affectValue);
					else
						self:ChangeFightSP(bcfg.affectValue);
					end
				else
					local BUFF = require("logic/battle/i3k_buff");

					local buff = BUFF.i3k_buff.new(skill, bid, bcfg);
					if buff._owner then
						self:AddBuff(self, buff);
					elseif target:GetGroupType() ~= eGroupType_N then
						if target._behavior:Test(eEBReboundDBuff) and (buff._type == eBuffType_DBuff) then
							if buff:CanRebound() then
								self:AddBuff(self, buff);
							end
						else
							target:AddBuff(self, buff);
						end
					end
				end
			end
		end
	end

	if self:IsDead() then
		return target:IsDead(), false;
	end

	if sbv > 0 and target:GetGroupType() ~= eGroupType_N then
		self:UpdateProperty(ePropID_hp, 1, sbv, true, true);
	end

	return target:IsDead(), false;
end

function i3k_hero:ProcessBuffDamage(attacker, buffid, eType, eCountType, eValue)
	if eType == ePropID_sp then
		local func = function()
			self:UpdateProperty(ePropID_sp, eCountType, eValue, true, false);
		end
		self:CheckUpdateSp(func)
	elseif eType == ePropID_hp then
		local val = 0;
		if eCountType == 1 then
			val = eValue;
		else
			val = i3k_integer(self._hp * (eValue / 100));
		end

		local affectType = eSE_Damage;
		if val >= 0 then
			affectType = eSE_Buff;
		end
		local add = 0
		if attacker then
			add = attacker:GetPropertyValue(ePropID_behealGain)
		end
		if val ~= 0 then
			val = val * (1 + add )
			if affectType == eSE_Damage then
				--local maxbuffdam = self:GetPropertyValue(ePropID_maxHP) * i3k_db_common.skill.maxbuffdam / 10000
				if self:GetEntityType() == eET_Monster then
					local maxbuffdam = i3k_db_common.skill.maxbuffdam
					if maxbuffdam < math.abs(val) then
						val = -maxbuffdam
					end
				end
			end
			if affectType == eSE_Damage and self._behavior:Test(eEBInvincible) then
			else
				self:OnDamage(attacker, 0, math.abs(val), false, affectType, true, false, nil, false, buffid);
				-- self:Checkunride()
			end
		end
	else
		self:UpdateProperty(eType, eCountType, eValue, false, true);
	end
end

function i3k_hero:ProcessBuffDamagefromNetwork(SourceType, eValue)
	local curHP = self:GetPropertyValue(ePropID_hp)
	local val = eValue - curHP

	local affectType = eSE_Damage;
	if val >= 0 then
		affectType = eSE_Buff;
	else
		self:updateWoodManDamage(math.abs(val))
	end

	if val ~= 0 then
		if affectType == eSE_Damage and self._behavior:Test(eEBInvincible) then
		else
			self:OnDamage(self, 0, math.abs(val), false, affectType, true, false, SourceType, false);
			if val < 0 then
				-- self:Checkunride()
			end
		end
	end
end

function i3k_hero:ProcessInternalInjuryDamagefromNetwork(injuryDamageType, eValue, injuryDamageValue)

	self._internalInjuryState.value = injuryDamageValue
	self._internalInjuryState.maxInjury = self:GetPropertyValue(ePropID_maxHP)
	local curHP = self:GetPropertyValue(ePropID_hp)
	local val = eValue - curHP

	local affectType = eSE_Damage;
	if val >= 0 then
	else
		if injuryDamageType == eIE_ContinueDamage then
			self:ShowInfo(self, eEffectID_NS.style,  eEffectID_NS.txt .. ' - ' .. math.abs(val) , nil, eET_Player);
		end
		if injuryDamageType == eIE_TriggerDamage then
			self:ShowInfo(self, eEffectID_YFNS.style, eEffectID_YFNS.txt .. ' - ' .. math.abs(val) , nil, eET_Player);
		end
		self:updateWoodManDamage(math.abs(val))
	end
	if injuryDamageType == eIE_IgnoreDamage then
		self:ShowInfo(self, eEffectID_Buff.style, i3k_get_string(17707), nil, eET_Player);
	end
	if val ~= 0 then
		if self._behavior:Test(eEBInvincible) then
		else
			self:OnDamage(self, 0, math.abs(val), false, affectType, false, false, nil, false);
		end
	end
	if self:IsPlayer() then
		g_i3k_game_context:OnInternalInjuryDamageValueChangedHandler(self._internalInjuryState.value, self._internalInjuryState.maxInjury)
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_GMEntrance,"showInternalInjury",injuryDamageValue)
end

function i3k_hero:SetCacheTargets(skillID, eventIdx, target, newHp, isatr, isdodge, cri, suckBlood, SourceType, remit, armor, batter, godStarSplite, godStarDefend)
	--[[
	local Targetinfo = {target = target,newHp = newHp,isatr = isatr,isdodge = isdodge, cri = cri ,suckBlood = suckBlood, SourceType = SourceType, remit = remit}
	table.insert(self._cacheTargets, Targetinfo);
	]]

	local scfg = i3k_db_skills[skillID];
	local s = scfg.specialArgs;
	local attacker = self:CheckAttacker(skillID, self._attacker);

	if s.triSkillOnDamage then
		if attacker then
			attacker._skill._initPos = target._curPos;
		end
	end

	--self:Checkunride();
	self:ProcessDamagefromNetwork(skillID, eventIdx, target, newHp, isatr, isdodge, cri, suckBlood, SourceType, remit, armor, batter, godStarSplite, godStarDefend)

	if attacker then
		attacker._skill:TriggerVFX(eVFXDamage, { target });
	end
end

function i3k_hero:CheckAttacker(skillID,attacker)
	for k,v in pairs(attacker) do
		if v._skill._id == skillID then
			return v;
		elseif v._parentSkill and v._parentSkill._id == skillID then
			return v;
		else
			if #v._childs > 0 then
				local HaveAttacker = self:CheckAttacker(skillID,v._childs)
				if HaveAttacker then
					return HaveAttacker;
				end
			end
		end
	end
	return nil;
end

function i3k_hero:SetTitleVisiable(vis)
end

function i3k_hero:SetAutonormalattack(skillID)
	if self:IsPlayer() then
		if not self._autonormalattack then
			if self._preautonormalattack then
				for k, v in pairs(self._bindSkills) do
					if skillID == v then
						self._autonormalattack = true;
						self._preautonormalattack = false;
						break;
					end
				end
			end
		end

		if not self._autonormalattack then
			if self._preautonormalattack then
				for k, v in pairs(self._attacks) do
					if skillID == v._id then
						self._autonormalattack = true;
						self._preautonormalattack = false;
						break;
					end
				end
			end
		end

		if not self._autonormalattack then
			if self._preautonormalattack then
				if self._uniqueSkill and self._uniqueSkill._id then
					if skillID == self._uniqueSkill._id then
						self._autonormalattack = true;
						self._preautonormalattack = false;
					end
				end
			end
		end

		if not self._autonormalattack then
			if self._preautonormalattack then
				if self._missionMode.attacks then
					for k, v in pairs(self._missionMode.attacks) do
						if skillID == v._id then
							self._autonormalattack = true;
							self._preautonormalattack = false;
							break;
						end
					end
				end
			end
		end

		if not self._autonormalattack then
			if self._preautonormalattack then
				if self._missionMode.skills then
					for k, v in pairs(self._missionMode.skills) do
						if skillID == v._id then
							self._autonormalattack = true;
							self._preautonormalattack = false;
							break;
						end
					end
				end
			end
		end

		if not self._autonormalattack then
			if self._preautonormalattack then
				if self._weapon.skills then
					for k, v in pairs(self._weapon.skills) do
						if skillID == v._id then
							self._autonormalattack = true;
							self._preautonormalattack = false;
							break;
						end
					end
				end
			end
		end

		if not self._autonormalattack then
			if self._preautonormalattack then
				self._autonormalattack = (skillID == SKILL_DIY);
				self._preautonormalattack = false;
			end
		end
	end
end

function i3k_hero:ProcessDamagefromNetwork(skillID,triggerNum, target,newHp, isatr,isdodge, cri,suckBlood,SourceType,isremit, armor, batter, godStarSplite, godStarDefend)
	if not target or target:IsDead() then
		return false, true;
	end

	if not target:GetPropertyValue(ePropID_hp) then
		return false, true;
	end

	local _atr = 0
	if isdodge == 1 then
		_atr = 1;
		if isatr == 0 then
			_atr = 2;
		end
	end

	if _atr == 1 then
		target:OnDodge(self,SourceType, skillID); -- 闪避

		return false, true;
	end

	if isremit and isremit == 1 then
		target:OnRemit(self,SourceType); -- 豁免

		return false, true;
	end

	if isremit and isremit == 2 then
		target:OnImmune(self,SourceType); -- 狼印

		return false, true;
	end

	if batter then
		if self:IsPlayer() or target:IsPlayer() then -- 连刺
			self:ShowInfo(self, eEffectID_DeBuff.style, i3k_get_string(1034), nil);
		end
	end

	local dam = 0;

	if cri then
		if self:IsPlayer() then
			g_i3k_camera_shake_effect:Play();
		end
	end

	local sdatacfg = i3k_db_skill_datas[skillID];
	local sdata = nil
	if sdatacfg[1] then
		sdata = sdatacfg[1].events[triggerNum + 1];
	end

	local scfg = i3k_db_skills[skillID];

	if scfg.type == eSE_Damage then

		dam = target:GetPropertyValue(ePropID_hp)- newHp;
		target:updateWoodManDamage(dam)

		--设置血条显示
		local hero = i3k_game_get_player_hero()
		if self:IsPlayer() or (self._hoster and self._hoster:IsPlayer()) or (self._hosterID and hero and self._hosterID == hero:GetGuidID()) and not hero:IsDead() then
			if g_i3k_game_context:GetWorldMapType() ~= g_SPIRIT_BOSS then
				target:SetTitleVisiable(true);
			end
		end

		if target:IsPlayer() or (target._hoster and target._hoster:IsPlayer()) and not hero:IsDead() then
			if g_i3k_game_context:GetWorldMapType() ~= g_SPIRIT_BOSS then
				self:SetTitleVisiable(true);
			end
		end
		self:SetAutonormalattack(skillID)
	else
		dam = newHp - target:GetPropertyValue(ePropID_hp);
	end

	if scfg then
		local dt, dv = target:OnDamage(self, _atr, dam, cri, scfg.type, true, false, SourceType, true, nil, armor, nil, godStarSplite, godStarDefend);
	end

	if suckBlood ~= 0 then
		self:UpdateProperty(ePropID_hp, 1, suckBlood, true, true);
	end
	if sdata == nil then
		local a = 0;
	end

	if sdata.hitEffID > 0 then
		target:PlayHitEffect(sdata.hitEffID);
	end

	local sound = i3k_db_sound[sdata.hitSoundID];
	if sound then
		if target._entity then
			--target._entity:StopSFX(false);
			target._entity:PlaySFX(sound.path, false, 0.1, 1.0, 1.0);
		else
			i3k_warn("ERROR:"..target._guid)
		end
	end

	local s = scfg.specialArgs;
	if not target:IsDead() then
		if target:IsPlayer() then
			target:OnFightTime(0.01);
			--target:Checkunride();
		end

		if s.shiftInfo then
			if s.shiftInfo.type == 1 or s.shiftInfo.type == 3 then
				if target.OnShift then
					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(target._curPos, self._curPos));
					local sender = nil
					if self:IsPlayer() then
						sender = self
						local sign = 1;
						if s.shiftInfo.distance < 0 then
							sign = -1;
						end

						local dist = 0;
						if s.shiftInfo.type == 1 then
							dist = math.abs(s.shiftInfo.distance);
						else
							local hero = i3k_game_get_player_hero()
							dist = math.min(math.abs(i3k_vec3_dist(hero._curPos, target._curPos) + (150 + i3k_engine_get_rnd_u(0, 50)) * sign), math.abs(s.shiftInfo.distance));
						end
						dist	= dist * sign;

						local pos = i3k_vec3_add1(target._curPosE, i3k_logic_pos_to_world_pos(i3k_vec3_mul2(dir, dist)));
						local moveInfo = i3k_engine_trace_line_ex(target._curPosE, pos);
						if moveInfo.valid then

							local toPos = nil;
							if s.shiftInfo.distance == 0 then
								toPos = target._curPos;
							else
								toPos = moveInfo.path;
							end

							local guid = string.split(target._guid, "|")
							if target:GetEntityType() == eET_Player or target:GetEntityType() == eET_Monster then
								i3k_sbean.map_shiftstart(self, toPos, tonumber(guid[2]), target:GetEntityType(), skillID)
							elseif target:GetEntityType() == eET_Mercenary then
								i3k_sbean.map_shiftstart(self, toPos, tonumber(guid[2]), eET_Mercenary, skillID, tonumber(guid[3]))
							end
						end
					elseif self:GetEntityType() == eET_Mercenary then
						local hoster = self:GetHoster();
						if hoster and hoster:IsPlayer() then
							sender = self
							local sign = 1;
							if s.shiftInfo.distance < 0 then
								sign = -1;
							end

							local dist = math.min(math.abs(i3k_vec3_dist(mercenary._curPos, target._curPos) + (150 + i3k_engine_get_rnd_u(0, 50)) * sign), math.abs(s.shiftInfo.distance));
							dist	= dist * sign;

							local pos = i3k_vec3_add1(target._curPosE, i3k_logic_pos_to_world_pos(i3k_vec3_mul2(dir, dist)));
							local moveInfo = i3k_engine_trace_line_ex(target._curPosE, pos);
							if moveInfo.valid then
								local toPos = nil;
								if s.shiftInfo.distance == 0 then
									toPos = target._curPos;
								else
									toPos = moveInfo.path;
								end

								local sguid = string.split(self._guid, "|")
								local guid = string.split(target._guid, "|")
								if target:GetEntityType() == eET_Player or target:GetEntityType() == eET_Monster then
									i3k_sbean.map_shiftstart(self, toPos, tonumber(guid[2]), target:GetEntityType(), skillID, nil, tonumber(sguid[2]))
								elseif target:GetEntityType() == eET_Mercenary then
									i3k_sbean.map_shiftstart(self, toPos, tonumber(guid[3]), target:GetEntityType(), skillID, tonumber(guid[2]), tonumber(sguid[2]))
								end
							end
						end
					end
				end
			end
		end
	end

	return target:IsDead(), false;
end

function i3k_hero:GetPropertyValue(id)
	if id == ePropID_hp then
		return math.min(self._hp, self:GetPropertyValue(ePropID_maxHP));
	end

	if id == ePropID_sp then
		return math.min(self._sp, self:GetPropertyValue(ePropID_maxSP));
	end

	if id == ePropID_armorCurValue then
		if self._armorState.value then
			return math.min(self._armorState.value, self:GetPropertyValue(ePropID_armorMaxValue));
		end
		return 0;
	end

	local mapType = g_i3k_game_context:GetWorldMapType()

	if mapType == g_DEFENCE_WAR and self._missionMode.valid and id == ePropID_maxHP and self:IsPlayer() then
		return g_i3k_game_context:getDefenceWarCarMaxHP()
	end

	if mapType == g_MAGIC_MACHINE and self:GetAreaType() == g_GODMACHINE_SLOW_AREA and id == ePropID_speed and self:IsPlayer() then
		return i3k_db_magic_machine.slowDownSpeed
	end
	return BASE.GetPropertyValue(self, id);
end

function i3k_hero:UpdateProperty(id, type, value, base, showInfo, force)
	local _info = false;
	if showInfo ~= nil then
		_info = showInfo;
	end

	if id == ePropID_hp then
		local val = 0;
		if type == 1 then
			val = value;
		else
			val = i3k_integer(self._hp * (value / 100));
		end

		local stype = eSE_Damage;
		if val >= 0 then
			stype = eSE_Buff;
		end

		if val ~= 0 then
			self:OnDamage(self, 1, val, false, stype, _info, true, nil, false);
		end
	elseif id == ePropID_sp then
		if self._sp then
			local val = 0;
			if type == 1 then
				val = value;
			else
				val = i3k_integer(self._sp * (value / 100));
			end

			if val ~= 0 or force then
				if force then
					self._sp = val;
				else
					self._sp = self._sp + val;
				end

				if self._sp > self:GetPropertyValue(ePropID_maxSP) then
					self._sp = self:GetPropertyValue(ePropID_maxSP);
				end

				if self._sp < 0 then
					self._sp = 0;
				end

				self:OnPropUpdated(ePropID_sp, self._sp);
			end
		end
	elseif id == ePropID_rapidly then
		if self:IsPlayer() and self._ReduceCd then
			if value ~= 0 or force then
				if force then
					self._ReduceCd = value;
				else
					self._ReduceCd = self._ReduceCd + value;
				end

				if self._ReduceCd < 0 then
					self._ReduceCd = 0;
				end
				self:OnPropUpdated(ePropID_rapidly, self._ReduceCd);
			end
		end
	else
		local _cb = function()
			BASE.UpdateProperty(self, id, type, value, base, showInfo, force);
		end

		if self._LockProperties then
			if not self._DelayProps then
				self._DelayProps = { };
			end

			table.insert(self._DelayProps, _cb);
		else
			_cb();
		end
	end
end

function i3k_hero:isCanReduceCd()
	if self:IsPlayer() and self._ReduceCd and self._ReduceCd > 0 then
		return self._ReduceCd / 10000;
	end
	return false;
end

function i3k_hero:SetTargetPos(Pos)
	self._targetPos = Pos;
end

function i3k_hero:GetTargetPos()
	return self._targetPos ;
end

function i3k_hero:ClearFightTime()
	self._fighttime = 0
	local world = i3k_game_get_world()
	if world then
		world:ResetTitleShow();
	end
	if self._PVPStatus == g_PeaceMode then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updatePKModeSkillUI")
	end
end

function i3k_hero:GetFightTime()
	return self._fighttime;
end

function i3k_hero:IsInFightTime()
	return self._fighttime ~= 0;
end

function i3k_hero:OnFightTime(dTime, add)
	if add then
		self._fighttime = self._fighttime +dTime;
	else
		local isRefresh = self._fighttime == 0
		self._fighttime = dTime;
		if self._PVPStatus == g_PeaceMode and isRefresh then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updatePKModeSkillUI")
		end
	end

end

function i3k_hero:Appraise()
	--[[local atkN	= self:GetPropertyValueWithoutSkill(ePropID_atkN);
	local atkH	= self:GetPropertyValueWithoutSkill(ePropID_atkH);
	local atkC	= self:GetPropertyValueWithoutSkill(ePropID_atkC);
	local atkW	= self:GetPropertyValueWithoutSkill(ePropID_atkW);
	local defN	= self:GetPropertyValueWithoutSkill(ePropID_defN);
	local defC	= self:GetPropertyValueWithoutSkill(ePropID_defC);
	local defW	= self:GetPropertyValueWithoutSkill(ePropID_defW);
	local maxHP	= self:GetPropertyValueWithoutSkill(ePropID_maxHP);
	local atr	= self:GetPropertyValueWithoutSkill(ePropID_atr);
	local ctr	= self:GetPropertyValueWithoutSkill(ePropID_ctr);
	local acrN	= self:GetPropertyValueWithoutSkill(ePropID_acrN);
	local tou	= self:GetPropertyValueWithoutSkill(ePropID_tou);
	local FIncrease	= self:GetPropertyValueWithoutSkill(ePropID_mercenarydmgTo);
	local TDecrease	= self:GetPropertyValueWithoutSkill(ePropID_mercenarydmgBy);
	local internalForces = self:GetPropertyValueWithoutSkill(ePropID_internalForces);
	local dex = self:GetPropertyValueWithoutSkill(ePropID_dex);--]]

	-- local hp = self._properties[1002]
	-- for k,v in pairs(hp) do
	-- 	if string.find(k,"_value") and k ~= "_value" and k ~= "_valueBase" and k ~= "_valuePercent" then
	-- 		i3k_log("chhy",k,v.Base,v.Percent);
	-- 	end
	-- end

	local power = 0
	for i,v in pairs(i3k_db_prop_id) do
		if v.plusRole~=0 then
			local value = self:GetPropertyValueWithoutSkill(i)
			if value then
				power = v.plusRole * value + power
			end
		end
	end
	local skillPower		= self:AppraiseSkill();
	local uniquePower		= self:AppraiseUniqueSkill();
	local longyinPower 		= self:AppraiseLongyin()
	local armorPower 		= self:AppraiseArmor()
	local housePower 		= self:AppraiseEquestrianSkill()
	local meridianPower 	= self:AppraiseMeridian()
	local hideWeaponPower 	= self:AppraiseHideWeapon()
	local weaponPower 		= self:AppraiseWeapon()--神兵假战力
	return math.floor(power + skillPower + uniquePower + longyinPower + armorPower + housePower + meridianPower + hideWeaponPower + weaponPower)
	--[[local res = math.floor(2*(atkN + defN) + maxHP * 0.223 + 0.9 * (atkH + atkC + defC + atkW + defW) + 4 * (atr + ctr + acrN + tou) + 138 * FIncrease*100 + 438 * TDecrease*100 + 3 * (internalForces + dex) + skill + unique+longyin)
	return res;--]]
end

function i3k_hero:AppraiseWeapon()
	return g_i3k_game_context:GetWeaponAddFightPower()
end

function i3k_hero:AppraiseHideWeapon()
	local power = g_i3k_game_context:getHideWeaponAddFightPower()
	return power
end

function i3k_hero:AppraiseMeridian()
	local power = 0
	local meridianPotential = g_i3k_game_context:getMeridianPotential();
	if meridianPotential  then
		local cfg = i3k_db_meridians.potentia
		for k,v in pairs(meridianPotential) do
			power = power + cfg[k][v].combatValue
		end
	end
	return power;
end

function i3k_hero:AppraiseLongyinKong()
	--龙印洗练提升的战力
	local power = 0
	local longyininfo = g_i3k_game_context:GetLongYinInfo();
	if longyininfo.skills then
		for k,v in pairs(longyininfo.skills) do
			local translvl = g_i3k_db.i3k_db_get_hero_skill_translevel(self._id,k)
			power = power + v * i3k_db_common.powerappraise.N1 * (i3k_db_common.powerappraise.N2 + translvl * i3k_db_common.powerappraise.N3)
		end
	end
	return power;
end

function i3k_hero:AppraiseLongyin()
	--龙印对技能加成后，技能所提升的战力，再加上龙印洗练提升的战力
	local power = 0
	local longyininfo = g_i3k_game_context:GetLongYinInfo();
	local heroAllSkills, heroUseSkills = g_i3k_game_context:GetRoleSkills();
	--local roleUniqueSkill,useUniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝
	if longyininfo.skills then
		for k,v in pairs(longyininfo.skills) do
			if heroAllSkills[k] then
				local cpower = 0;
				local cfg = i3k_db_skill_datas[k][heroAllSkills[k].lvl+v]
				if cfg then
					cpower = cpower + cfg.skillpower
					cpower = cpower + cfg.skillrealpower[heroAllSkills[k].state+1]
				end
				local bcfg = i3k_db_skill_datas[k][heroAllSkills[k].lvl]
				if bcfg then
					cpower = cpower - bcfg.skillpower
					cpower = cpower - bcfg.skillrealpower[heroAllSkills[k].state+1]
				end
				power = power + cpower;
			end
		end
	end
	power = power + self:AppraiseLongyinKong()
	return power;
end

function i3k_hero:AppraiseSkill()
	local heroAllSkills, heroUseSkills = g_i3k_game_context:GetRoleSkills()
	local power = 0
	for k,v in pairs(heroAllSkills) do
		if v then
			local cfg = i3k_db_skill_datas[v.id][v.lvl]
			if cfg then
				power = power + cfg.skillpower
				power = power + cfg.skillrealpower[v.state+1]
			end
		end
	end

	return power;
end

function i3k_hero:AppraiseUniqueSkill()

	local roleUniqueSkill,useUniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝
	local power = 0
	for k,v in pairs(roleUniqueSkill) do
		if v then
			local cfg = i3k_db_skill_datas[v.id][v.lvl]
			if cfg then
				power = power + cfg.skillpower
				power = power + cfg.skillrealpower[v.state+1]
			end
		end
	end
	return power;
end

function i3k_hero:AppraiseArmor()
	local armor = self._armor.id~=0 and self._armor
	local power = 0
	if armor then
		--天赋
		for k,v in pairs(self._armor.talent) do
			local talentCfg = i3k_db_under_wear_upTalent[armor.id][k]
			power = power + talentCfg.addPowerNums[v]
		end

		--符文的
		for _,v in ipairs(armor.rune) do
			for __,t in ipairs(v.solts) do
				if t~=0 then
					t = t >0 and t or -t
					local runeCfg = i3k_db_under_wear_rune[t]
					power = power + runeCfg.addPower
				end
			end
		end
	end
	return power;
end

function i3k_hero:AppraiseEquestrianSkill(id)
	local rps = g_i3k_game_context:getAllSteedInfo()
	local rid = id or g_i3k_game_context:getUseSteed()
	local steedSkill = g_i3k_game_context:getSteedSkillLevelData()
	local power = 0
	for k,v in pairs (rps) do
		if rid == v.id then
			local prosteed
			if v.star >= 2 then
				prosteed = i3k_db_steed_cfg[v.id].equitationId --先天骑术id
				if i3k_db_steed_skill_cfg[prosteed][steedSkill[prosteed]] then
					power = power + i3k_db_steed_skill_cfg[prosteed][steedSkill[prosteed]].power
				end
			end
			for k1,v1 in pairs(v.curHorseSkills) do
				if i3k_db_steed_skill_cfg[v1][steedSkill[v1]] then
					power = power + i3k_db_steed_skill_cfg[v1][steedSkill[v1]].power
				end
			end
		end
	end
	return power
end

function i3k_hero:GetDigStatus()
	return self._DigStatus
end

function i3k_hero:SetDigStatus(status)
	if status == 0 then
		local logic = i3k_game_get_logic()
		if logic then
			logic._selectEntity = nil
		end
		g_i3k_game_context:SetMineInfo(nil)
		-- if self._DigStatus == 2 then
		-- 	self:Play(i3k_db_common.engine.defaultStandAction, -1);
		-- end
	end
	self._DigStatus = status
	g_i3k_game_context:OnMineStatusChangedHandler(status)
end

function i3k_hero:CheckDigStatus()
	local distance = i3k_db_common.digmine.DigMineDistance

	if g_i3k_ui_mgr:GetUI(eUIID_BattleEquip) then

		local cfg = g_i3k_game_context:GetCurrTaskCfg( )

		if cfg and cfg.type == g_TASK_USE_ITEM_AT_POINT then
			pos = {x=cfg.arg3*100,y=cfg.arg4*100,z=cfg.arg5*100}
			local dist = i3k_vec3_sub1(pos,self._curPos)
			if distance < i3k_vec3_len(dist) then
				g_i3k_game_context:ResetCurrTaskType()
				g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
			end
		end
	end

	local MineInfo = g_i3k_game_context:GetMineInfo()

	if not MineInfo then
		if self:GetDigStatus() ~= 0 then
			self:SetDigStatus(0)
		end
		return;
	end

	if self:GetDigStatus() == 1 then
		local dist = i3k_vec3_sub1(MineInfo._curPos, self._curPos);
		if MineInfo and MineInfo._gcfg.nType == g_TYPE_MINE_JUBILEE then 
			distance = i3k_db_jubilee_base.stage3.digMineDistance
		end

		if distance < i3k_vec3_len(dist) or not self:CanUseSkill() then
			self:SetDigStatus(0)
		end
	end
end

function i3k_hero:initSoulEnergy(value)
	self._soulenergyMaxValue = value;
end

function i3k_hero:UpdateSoulenergyValue(value)
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(g_i3k_game_context:GetSelectWeapon())
	if isOpen and isOpen == 1 then
		self._soulenergy = value;
		g_i3k_game_context:OnSoulEnergyChangedHandler(value, self._soulenergyMaxValue)
	end
end

function i3k_hero:GetSoulEnergy()
	return self._soulenergy, self._soulenergyMaxValue;
end



function i3k_hero:GetFightSp()
	return self._fightsp;
end

function i3k_hero:DigMineCancel()
	if self:GetDigStatus() == 2 then
		i3k_sbean.send_mineral_quit()
	end
	self:SetDigStatus(0)
end

function i3k_hero:PlayerDigMineStart()
	local hero = i3k_game_get_player_hero();
	if hero then
		local MineInfo = g_i3k_game_context:GetMineInfo()
		if MineInfo then
			local guid = string.split(MineInfo._guid, "|")
			local args = {cfgID = MineInfo._gcfg.ID,RoleID = tonumber(guid[2]) }

			local pos = MineInfo._curPos
			local newpos = self._curPos
			local angle = i3k_vec3_angle2(i3k_vec3(pos.x-newpos.x, newpos.y, pos.z-newpos.z), i3k_vec3(1, 0, 0));
			self:SetFaceDir(0, angle, 0)

			local mineTaskInfo = g_i3k_game_context:getMineTaskInfo()

			local func = function()
				if mineTaskInfo then
					local action = MineInfo._gcfg.Action
					self:Play(action, -1)
					g_i3k_ui_mgr:OpenUI(eUIID_BattleProcessBar)
					g_i3k_ui_mgr:RefreshUI(eUIID_BattleProcessBar, 3, 0, true)
					g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
				else
					if MineInfo._gcfg.nType ~= g_TYPE_MINE_JUBILEE then
					i3k_sbean.role_mine(args.cfgID,args.RoleID)
					else
						i3k_log("22222222222222222222222222222222")
						i3k_sbean.jubilee_activity_step3_take()
					end
				end
			end
			g_i3k_game_context:UnRide(func, true) --采集必然下马
		end
	end
end

function i3k_hero:CreateSummoned(skills,level,RoleID,summonedId)
	local player = i3k_game_get_player()
	local world = i3k_game_get_world();
	local hero = i3k_game_get_player_hero()
	local lvl = 1;
	if lvl then
		lvl = level
	end

	local SEntity = require("logic/entity/i3k_summoneds");
	local summoned = nil
	if RoleID then
		summoned = SEntity.i3k_summoneds.new(i3k_gen_entity_guid_new(SEntity.i3k_summoneds.__cname,iRoleID));
	else
		summoned = SEntity.i3k_summoneds.new(i3k_gen_entity_guid_new(SEntity.i3k_summoneds.__cname,i3k_gen_entity_guid()));
	end
	summoned:Create(skills, lvl, { 1, 1, 1, 1 }, false,summonedId)
	summoned:AddAiComp(eAType_IDLE);
	summoned:AddAiComp(eAType_MOVE);
	summoned:AddAiComp(eAType_FOLLOW);
	summoned:AddAiComp(eAType_ATTACK);
	summoned:AddAiComp(eAType_AUTO_SKILL);
	summoned:AddAiComp(eAType_FIND_TARGET);
	summoned:AddAiComp(eAType_FORCE_FOLLOW);
	summoned:AddAiComp(eAType_SPA);
	summoned:AddAiComp(eAType_SHIFT);
	summoned:AddAiComp(eAType_DEAD);
	summoned:AddAiComp(eAType_RETREAT);
	summoned:AddAiComp(eAType_FEAR);

	local mapType = i3k_game_get_map_type()
	local mapTypes = 
	{
		[g_FORCE_WAR] = true,
		[g_FACTION_WAR] = true,
		[g_BUDO] = true,
		[g_DEFENCE_WAR] = true,
		[g_PRINCESS_MARRY] = true,
	}
	if hero and mapTypes[mapType] then
		summoned:SetForceType(hero:GetForceType())
	end

	summoned:UpdateHP(summoned:GetPropertyValue(ePropID_maxHP));
	summoned:UpdateBloodBar(summoned:GetPropertyValue(ePropID_hp) / summoned:GetPropertyValue(ePropID_maxHP));
	summoned:NeedUpdateAlives(true);
	summoned:Show(true, true, 1000);
	summoned:SetTitleShow(true)
	summoned:SetHittable(false);
	summoned:SetGroupType(eGroupType_O);
	summoned:SetFaceDir(0, 0, 0);
	summoned:SetPos(self._curPos);
	if summoned._subType == e_TYPE_FULINGWEI then
		player:AddSummoned(summoned)
	elseif summoned._subType == e_TYPE_WEAPON_CLONE then
		player:AddWeaponCloneBody(summoned)
	end
	world:AddEntity(summoned);
end

function i3k_hero:RemoveSummoned()
	local player = i3k_game_get_player()
	local world = i3k_game_get_world();
	local summoned = player:GetSummoned();
	if player  and summoned then
		player:RmvSummoned();
		world:RmvEntity(summoned);
	end
end

function i3k_hero:UpdateFightSp(curFightSP,byBuff)

	local cfg = i3k_db_fightsp[self._id]

	if curFightSP > self._fightsp then
		if self:IsPlayer() or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
			self:ShowInfo(attacker, eEffectID_Buff.style, cfg.showinfo, i3k_db_common.engine.durNumberEffect[2] / 1000);
		end
	elseif curFightSP < self._fightsp and byBuff then
		if self:IsPlayer() or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
			self:ShowInfo(attacker, eEffectID_DeBuff.style, cfg.showinfoDes, i3k_db_common.engine.durNumberEffect[2] / 1000);
		end
	end

	self._fightsp = curFightSP
	g_i3k_game_context:OnSpChangedHandler(curFightSP, g_i3k_db.i3k_db_get_max_fight_sp(self._id))
	if self._id ~= g_BASE_PROFESSION_GONGSHOU then
		self:UpdateFightSPProps()
	end

	if curFightSP == 0 then
		self._fightsptime = 0;
	else
		self._fightsptime = cfg.loopTime
	end
end

function i3k_hero:CreateFightSpCanYing(id,num,level,RoleID,Pos)
	local player = i3k_game_get_player()
	local world = i3k_game_get_world();
	local petId = id
	local hero = i3k_game_get_player_hero()
	local lvl = 1;
	if lvl then
		lvl = level
	end
	for i=1,num do
		local SEntity = require("logic/entity/i3k_pet");
		local pet = nil
		if RoleID then
			pet = SEntity.i3k_pet.new(i3k_gen_entity_guid_new(SEntity.i3k_pet.__cname,iRoleID));
		else
			pet = SEntity.i3k_pet.new(i3k_gen_entity_guid_new(SEntity.i3k_pet.__cname,i3k_gen_entity_guid()));
		end
		pet:Create(petId, lvl, { 1, 1, 1, 1 }, false)
		pet:AddAiComp(eAType_IDLE);
		pet:AddAiComp(eAType_MOVE);
		pet:AddAiComp(eAType_FOLLOW);
		pet:AddAiComp(eAType_ATTACK);
		pet:AddAiComp(eAType_AUTO_SKILL);
		pet:AddAiComp(eAType_FIND_TARGET);
		pet:AddAiComp(eAType_FORCE_FOLLOW);
		pet:AddAiComp(eAType_SPA);
		pet:AddAiComp(eAType_SHIFT);
		pet:AddAiComp(eAType_DEAD);
		pet:AddAiComp(eAType_RETREAT);
		pet:AddAiComp(eAType_FEAR);
		pet:AddAiComp(eAType_PET_CHECK_ALIVE)
		local cfg = i3k_db_fightpet[id];
		for k,v in pairs(self._talents) do
			if v._id == cfg.changeTalentID then
				local talentlvl = math.floor(v._lvl / 7) + 1
				local maxhp = pet:GetPropertyValue(ePropID_maxHP) + cfg.ChangeMaxHp[talentlvl]
				pet:UpdateProperty(ePropID_maxHP, 1, maxhp, true, false, true);
				pet:OnDamage(pet,1, pet:GetPropertyValue(ePropID_hp) - maxhp , false, 1, false, true);
				pet:UpdateBloodBar(pet:GetPropertyValue(ePropID_hp) / pet:GetPropertyValue(ePropID_maxHP));
				break;
			end
		end
		local mapType = i3k_game_get_map_type()
		local maptypes = 
		{
			[g_FORCE_WAR] = true,
			[g_FACTION_WAR] = true,
			[g_BUDO] = true,
			[g_DEFENCE_WAR] = true,
			[g_PRINCESS_MARRY] = true,
		}
		if hero and maptypes[mapType] then
			pet:SetForceType(hero:GetForceType())
		end
		pet:NeedUpdateAlives(true);
		pet:Show(true, true, 1000);
		pet:SetHittable(false);
		pet:SetGroupType(eGroupType_O);
		pet:SetFaceDir(0, 0, 0);
		if Pos then
			pet:SetPos(Pos);
		else
			pet:SetPos(self._curPos);
		end
		player:AddPet(pet)
		world:AddEntity(pet);
	end
end

function i3k_hero:RemoveFightSpCanYing(num)
	local player = i3k_game_get_player()
	local world = i3k_game_get_world();
	local petcount = player:GetPetCount()
	local remcount = math.abs(num)
	if remcount > petcount then
		remcount = petcount
	end
	for k = 1,remcount do
		local pet = player:GetPet(1);
		if pet then
			player:RmvPet(1,true);
			world:RmvEntity(pet);
		end
	end
end

function i3k_hero:CreateMissionNPC(id,Pos)
	local player = i3k_game_get_player()
	local world = i3k_game_get_world();
	local petId = id
	local lvl = 1;
	local effect = i3k_db_missionnpcs[id].effectId
	local SEntity = require("logic/entity/i3k_pet");
	local pet = SEntity.i3k_pet.new(i3k_gen_entity_guid_new(SEntity.i3k_pet.__cname,i3k_gen_entity_guid()));
	pet:Create(petId, lvl, { 1, 1, 1, 1 }, false)
	pet:AddAiComp(eAType_IDLE);
	--pet:AddAiComp(eAType_MOVE);
	pet:AddAiComp(eAType_FOLLOW);
	--pet:AddAiComp(eAType_FIND_TARGET);
	--pet:AddAiComp(eAType_FORCE_FOLLOW);
	--pet:AddAiComp(eAType_PET_CHECK_ALIVE)
	pet:Show(true, true, 1000);
	pet:SetHittable(false);
	pet:SetGroupType(eGroupType_O);
	pet:SetFaceDir(0, 0, 0);
	if Pos then
		pet:SetPos(Pos);
	else
		pet:SetPos(self._curPos);
	end
	if effect > 0 then
		pet:PlayMissionEffect(i3k_db_missionnpcs[id].effectId)
	end
	player:AddNPC(pet)
	world:AddEntity(pet);
end

function i3k_hero:ClearMissionNPC()
	local player = i3k_game_get_player()
	local world = i3k_game_get_world();
	local NPCcount = player:GetNPCCount()
	for i =1 ,NPCcount do
		local npc = player:GetNPC(1);
		world:RmvEntity(npc)
		player:RmvNPC(1,true)
	end
end

function i3k_hero:CreateMissionAdVentureNPC(cfg)
	local id = cfg.npcId

	local player = i3k_game_get_player()
	local world = i3k_game_get_world();
	local lvl = 1;

	local SEntity = require("logic/entity/i3k_pet");
	local pet = SEntity.i3k_pet.new(i3k_gen_entity_guid_new(SEntity.i3k_pet.__cname,i3k_gen_entity_guid()));
	pet:Create(id, lvl, { 1, 1, 1, 1 }, false)
	pet:AddAiComp(eAType_IDLE);
	--pet:AddAiComp(eAType_MOVE);
	pet:AddAiComp(eAType_FOLLOW);
	pet:Show(true, true, 1000);
	pet:SetHittable(false);
	pet:SetGroupType(eGroupType_O);
	pet:SetFaceDir(0, 0, 0);

	pet:SetPos(self._curPos);
	local effect = i3k_db_missionnpcs[id].effectId
	if effect > 0 then
		pet:PlayMissionEffect(effect)
	end

	player:AddNPC(pet)
	world:AddEntity(pet)
	pet:UpdateProperty(ePropID_speed, 1, 1000, true, false, true);
	if cfg.waiting > 0 then
		pet:BindTaskHoster(g_i3k_game_context:GetNPCbyID(cfg.destNpc))
	else
		pet:Bind(g_i3k_game_context:GetNPCbyID(cfg.destNpc))
	end
	if cfg.dialId then
		g_i3k_ui_mgr:OpenUI(eUIID_MonsterPop)
		g_i3k_ui_mgr:RefreshUI(eUIID_MonsterPop, cfg.dialId, pet)
	end

	local targetPos = g_i3k_db.i3k_db_get_npc_pos(cfg.destNpc)
	pet._onStopMove = function(pos)
		if i3k_vec3_dist(targetPos, pos) <= 5 then
			pet._onStopMove = nil
			local hero = i3k_game_get_player_hero()
			if hero then
				hero:ClearMissionNPC()
			end
		else
			if cfg.waitingDialId then
				g_i3k_ui_mgr:OpenUI(eUIID_MonsterPop)
				g_i3k_ui_mgr:RefreshUI(eUIID_MonsterPop, cfg.waitingDialId, pet)
			end
		end
	end

end

function i3k_hero:UpdateFightSpCanYing(curFightSP,byBuff)

	local cfg = i3k_db_fightsp[self._id]

	if curFightSP > self._fightsp then
		if self:IsPlayer() or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
			self:ShowInfo(attacker, eEffectID_Buff.style, cfg.showinfo, i3k_db_common.engine.durNumberEffect[2] / 1000);
		end
	elseif curFightSP < self._fightsp and byBuff then
		if self:IsPlayer() or g_i3k_game_context:IsTeamMember(self:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
			self:ShowInfo(attacker, eEffectID_DeBuff.style, cfg.showinfoDes, i3k_db_common.engine.durNumberEffect[2] / 1000);
		end
	end

	self._fightsp = curFightSP
	g_i3k_game_context:OnSpChangedHandler(curFightSP, g_i3k_db.i3k_db_get_max_fight_sp(self._id))
end

function i3k_hero:AddAutofightTriggerSkill()
	local entity = self._entity;
	local cfg = self._cfg.AutoaiNode
	local heroAllSkills, heroUseSkills = g_i3k_game_context:GetRoleSkills()
	local roleUniqueSkill,useUniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝

	self:ClearAutofightTriggerSkill();
	if not self._tids then
		self._tids = { };
	end

	for k1,v1 in pairs(cfg) do
			local tricfg = i3k_db_ai_trigger[v1]
			if tricfg then
				local eventcfg = i3k_db_trigger_event[tricfg.tid]
				local behcfg = i3k_db_trigger_behavior[tricfg.bid]
				if behcfg then
					for k, v in pairs(useUniqueSkill) do
						if v == behcfg.args[1] then
							if self._triMgr then
								local TRI = require("logic/entity/ai/i3k_trigger");
								local tri = TRI.i3k_ai_trigger.new(self);
								if tri:Create(tricfg,-1,v1) then
									local tid = self._triMgr:RegTrigger(tri, self);
									if tid >= 0 then
										table.insert(self._tids, tid);
									end
								end
							end
						end
					end
				end
			end
	end
	--self._tids = { };
	for k1,v1 in pairs(cfg) do
		local tricfg = i3k_db_ai_trigger[v1]
		if tricfg then
			local eventcfg = i3k_db_trigger_event[tricfg.tid]
			local behcfg = i3k_db_trigger_behavior[tricfg.bid]
			if behcfg then
				for k, v in pairs(heroUseSkills) do
					if v == behcfg.args[1] then
						--[[if eventcfg.tid == 8 then
							if entity._hp < entity:GetPropertyValue(ePropID_maxHP) * eventcfg.args[2]/100 then
								local skill = entity._skills[v];
								if skill and skill:CanUse() then
									return v
								end
							end
						end]]
						if self._triMgr then
							local TRI = require("logic/entity/ai/i3k_trigger");
							local tri = TRI.i3k_ai_trigger.new(self);
							if tri:Create(tricfg,-1,v1) then
								local tid = self._triMgr:RegTrigger(tri, self);
								if tid >= 0 then
									table.insert(self._tids, tid);
								end
							end
						end
					end
				end
			end
		end
	end
end

function i3k_hero:ClearAutofightTriggerSkill()
	local entity = self._entity;
	local cfg = self._cfg.AutoaiNode
	for k,v in pairs(cfg) do
		if self._tids then
			if self._triMgr then
				for k1, v1 in pairs(self._triMgr._triIds) do
					if k1 == v then
						while v1[1] do
							self._triMgr:UnregTrigger(v1[1]);
						end
						break;
					end
				end
			end
			--self._tids = nil;
		end
	end
end

function i3k_hero:PlayLevelup()
	local levelupeffect = i3k_db_common.engine.levelupEffect
	if levelupeffect then
		self:PlayHitEffect(levelupeffect)
	end
end

function i3k_hero:GetSkillIsCanUse(id)
	if self._missionMode.valid or self._missionMode.cache.valid then
		if self._missionMode.attacks then
			for k,v in pairs(self._missionMode.attacks) do
				if v._id == id then
					return v._canUse
				end
			end
		end
		if self._missionMode.skills then
			for k,v in pairs(self._missionMode.skills) do
				if v._id == id then
					return v._canUse
				end
			end
		end
		return true
	else
		if g_i3k_game_context:GetWorldMapType() == g_CATCH_SPIRIT then
			--[[for k, v in ipairs(self._catchSpiritSkills) do
				if v._id == id then
					return v._canUse
				end
			end--]]
			if self._gameInstanceSkills[id] then
				return self._gameInstanceSkills[id]._canUse
			end
		end
		if self._skills[id] then
			return self._skills[id]._canUse
		end
		return true
	end

	return true;
end

function i3k_hero:GetDodgeSkillIsCanUse()
	if self._dodgeSkill then
		return self._dodgeSkill._canUse
	end

	return true;
end

function i3k_hero:GetUniqueSkillIsCanUse()
	if self._uniqueSkill then
		return self._uniqueSkill._canUse
	end

	return true;
end

function i3k_hero:GetDIYSkillIsCanUse()
	if self._DIYSkill then
		return self._DIYSkill._canUse
	end

	return true;
end
function i3k_hero:GetSpiritSkillIsCanUse()
	if self._spiritSkill then
		return self._spiritSkill._canUse
	end

	return true;
end

function i3k_hero:GetAnqiSkillIsCanUse()
	if self._anqiSkill then
		return self:isAllanqiSkillCanUse()
	end

	return false;
end

function i3k_hero:isAllanqiSkillCanUse()
	--暗器所有技能为共用CD 切换后依然是原来CD
	local canUse = true

	for _, v in ipairs(self._anqiAllActiveSkills) do
		if not v._canUse then
			canUse = false
		end
	end

	return canUse
end

function i3k_hero:GetSkillCoolLeftTime(id)
	if self._missionMode.valid or self._missionMode.cache.valid then
		if self._missionMode.attacks then
			for k,v in pairs(self._missionMode.attacks) do
				if v._id == id then
					return v:GetCoolTime()
				end
			end
		end
		if self._missionMode.skills then
			for k,v in pairs(self._missionMode.skills) do
				if v._id == id then
					return  v:GetCoolTime()
				end
			end
		end
		return 0,0
	else
		if g_i3k_game_context:GetWorldMapType() == g_CATCH_SPIRIT then
			if self._gameInstanceSkills[id] then
				return self._gameInstanceSkills[id]:GetCoolTime()
			end
		end
		if self._skills[id] then
			return self._skills[id]:GetCoolTime()
		end
		return 0, 0
	end
end

function i3k_hero:GetDodgeSkillCoolLeftTime()
	if self._dodgeSkill then
		return self._dodgeSkill:GetCoolTime()
	end

	return 0, 0
end

function i3k_hero:GetUniqueSkillCoolLeftTime()
	if self._uniqueSkill then
		return self._uniqueSkill:GetCoolTime()
	end

	return 0, 0
end


function i3k_hero:GetDIYSkillCoolLeftTime()
	if self._DIYSkill then
		return self._DIYSkill:GetCoolTime()
	end

	return 0, 0
end

function i3k_hero:GetSpiritSkillCoolLeftTime()
	if self._spiritSkill then
		return self._spiritSkill:GetCoolTime()
	end

	return 0, 0
end

function i3k_hero:GetAnqiSkillCoolLeftTime()
	if self._anqiSkill then
		for _, v in ipairs(self._anqiAllActiveSkills) do
			if not v._canUse then
				return v:GetCoolTime()
			end
		end
	end

	return 0, 0
end

function i3k_hero:reduceAnqiPassiveSkillEffect(id, totalTime)
	if not self._anqiSkill or id == self._anqiSkill._id then
		return 0
	end

	local anqiID = g_i3k_db.i3k_db_get_anqi_id_by_skillID(id)
	local slot = g_i3k_game_context:GetSkillSlot(anqiID)
	local count = 0

	for _, skillID in ipairs(slot) do
		if skillID ~= 0 then
			local skillLvl = g_i3k_game_context:GetSkillLib(anqiID)[skillID]
			local skillData = g_i3k_db.i3k_db_get_one_anqi_skill(anqiID, skillID, skillLvl)
			local xinfaArray = skillData.xinfa
			for _, xinfaId in ipairs(xinfaArray) do
				local cfg = i3k_db_skill_talent[xinfaId]
				if cfg and cfg.args then
					local args = cfg.args
					local commonchangetype = args.Commonchangetype

					if commonchangetype == eSCCommon_cooltime then
						local value = args.value
						local valueType = args.valuetype

						for _, v in pairs(self._anqiAllActiveSkills) do
							if v._id == id then
								count = count + v:TalentSkillChangevalue(valueType, totalTime, value)
							end
						end
					end
				end
			end
		end
	end

	return count
end

function i3k_hero:IsAutoFight()
	return self._AutoFight
end
function i3k_hero:SetAutoFight(auto, pos)
	if not auto then
		self._AutoFight = false
		self:ResetMaunalAttack();
		self._target = nil
		self._curSkill = nil
		--self:StopMove()
		self._autonormalattack = false;
		self._preautonormalattack = false;
		self:ClearAutofightTriggerSkill()
		self:InitPlayerAttackList()
		self._PreCommand = -1
		self._AutoFight_Point = {x = self._curPos.x,y = self._curPos.y,z = self._curPos.z}
	else
		self._AutoFight = true
		self:ClearFindwayStatus()
		self:AddAutofightTriggerSkill()
		self:InitPlayerAttackList()
		self._AutoFight_Point = i3k_pos_to_vec3(pos or self._curPos)
		self._PreCommand = -1
	end
end

function i3k_hero:IsOnRide()
	return self._ride.valid or self._ride.onMulHorse
end

function i3k_hero:SetMulHorseState(state)
	self._ride.onMulHorse = state
	g_i3k_game_context:OnRideChangedHandler()
end

function i3k_hero:IsOnMulRide()
	return self._ride.onMulHorse
end

function i3k_hero:SetFindWayStatus()
	self._isfindway = true;
end

function i3k_hero:GetFindWayStatus()
	return self._isfindway,self._findWayTmpSpeed
end

function i3k_hero:ClearFindwayStatus(stop)
	if self._isfindway and self:IsPlayer() then
		self._isfindway = false;
		self._onStopMove = nil;
		if self._findWayTmpSpeed then
			self:UpdateProperty(ePropID_speed, 1, self:GetRealSpeed(), true, false, true);
			self._findWayTmpSpeed = nil;
		end
		g_i3k_ui_mgr:CloseUI(eUIID_FindwayStateTips)
		g_i3k_ui_mgr:CloseUI(eUIID_DesertBattleFindWayTips) -- 决战荒漠寻路
	end
end

function i3k_hero:SetFindWayTmpSpeed(speed)
	if speed and self._isfindway and self:IsPlayer() then
		self._findWayTmpSpeed = speed
		local nSpeed = self:GetPropertyValue(ePropID_speed)
		local cSpeed = speed - nSpeed
		self:UpdateProperty(ePropID_speed, 1, cSpeed, true, false, false);
	end
end

function i3k_hero:GetRealSpeed()
	if self._ride.valid then
		return i3k_db_steed_cfg[self._ride.id].speed
	elseif self._missionMode.valid then
		return self._missionMode.speedodds
	else
		return self._cfg.speed
	end
end

function i3k_hero:SetRide(enable, notips, callback)
	if not enable then
		i3k_sbean.horse_unride(self, enable, notips, callback)
	elseif self:CanRide(notips) then
		i3k_sbean.horse_ride(self, enable, callback)
	else
		if callback then
			callback()
		end
	end
end

function i3k_hero:Checkunride()
	if self:IsPlayer() and self:IsOnRide() then
		if self:IsMulMemberState() then
			i3k_sbean.mulhorse_leave_requst()
			return
		end
		self:SetRide(false)
	end
	self:CheckUnHug()
end

function i3k_hero:CanRide(notips)
	if self:IsPlayer() then
		if self._ride and self._ride.deform then
			if not self:IsOnRide() then
				--地图
				if not g_i3k_db.i3k_db_get_is_can_ride_frome_mapType() then
					if not notips then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(196))
					end
					return false
				end
				if self._ride.ticks ~= 0 then
					if not notips then
						local tick = math.ceil(self._ride.ticks / 1000)
						g_i3k_ui_mgr:PopupTipMessage(string.format("%s秒后才可以上马", tick))
					end
					return false
				end

				--神兵变身
				if g_i3k_game_context:IsInSuperMode() then
					if not notips then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(198))
					end
					return false;
				end
				if self._missionMode.valid then
					return false;
				end
				local testBehaviorTb = {
					[eEBStun]			= true,
					[eEBRoot]			= true,
					[eEBDisDodgeSkill]	= true,
					[eEBSleep]			= true,
					[eEBFear]			= true,
					[eEBSilent]			= true,
					[eEBTaunt]			= true,
					[eEBShift]			= true,
                    [eEBRevive]			= true,
				}
				--控制状态眩晕、定身、减速、沉睡、恐惧、沉默、嘲讽、击退
				if self:TestBehaviorStateMap(testBehaviorTb) then
					if not notips then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(199))
					end
					return false;
				end
				return true
			end
		end
	end
	return false;
end

function i3k_hero:SetHeadIcon(headiconID)
	if self._headiconID then
		self._headiconID = headiconID
	end
end

--设置运镖状态
function i3k_hero:SetTransportState(state)
	self._iscarOwner  = state
	self:ChangeTransportName()
end

function i3k_hero:GetTransportState()
	return self._iscarOwner
end
--设置劫镖状态
function i3k_hero:SetRobState(state)
	self._iscarRobber = state
	self:ChangeTransportName()
end

function i3k_hero:GetRobState()
	return self._iscarRobber
end

--设置正邪
function i3k_hero:SetBWType(bwType)
	self._bwType = bwType
end

--设置势力阵营
function i3k_hero:SetForceType(fType)
	self._forceType = fType
end

--设置兵种
function i3k_hero:SetForceArm(fArm)
	self._forceArm = fArm
end
--兵种
function i3k_hero:GetForceArm()
	return self._forceArm 
end
function i3k_hero:GetForceType()
	return self._forceType
end

--设置位置id（竞技场、正邪道场）
function i3k_hero:SetPosId(posId)
	self._posId = posId
end

function i3k_hero:CreateItemSkill(itemId)
	if not self._itemSkills[itemId] then
		local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
		if itemCfg then
			local skillCfg = i3k_db_skills[itemCfg.args1]
			local skillLvl = itemCfg.args2
			local skill = require("logic/battle/i3k_skill")
			if skillCfg and skill then
				self._itemSkills[itemId] = skill.i3k_skill_create(self, skillCfg, skillLvl, 0, skill.eSG_Skill)
				self._itemSkills[itemId]._itemSkillId = itemId;
			end
		end
	end
end

function i3k_hero:UseSkillWithItem(itemId)
	local res = false;
	local skill = self._itemSkills[itemId]
	if skill then
		if self:CanUseSkill(skill) then
			self:TestBreakAttack(skill);
			self._maunalSkill = skill
			res = true
		else
			if not self:TrySequentialSkill(skill) then
				self._PreCommand = ePreTypeItemSkill
				self._preSkillItemId = itemId
			else
				res = true
			end
		end
	end
	return res
end

function i3k_hero:GetItemSkillCoolLeftTime(itemId)
	if self._itemSkills[itemId] then
		return self._itemSkills[itemId]:GetCoolTime()
	end

	return 0, 0
end

-- 神器乱战技能 began
function i3k_hero:CreateTournamentSkill(skillID, level)
	if not self._tournamentSkills[skillID] then
		local skillCfg = i3k_db_skills[skillID]
		local skillLvl = level or 1
		local skill = require("logic/battle/i3k_skill")
		if skillCfg and skill then
			self._tournamentSkills[skillID] = skill.i3k_skill_create(self, skillCfg, skillLvl, 0, skill.eSG_Skill)
			self._tournamentSkills[skillID]._tournamentSkillID = skillID;
		end
	end
end

function i3k_hero:UseTournamentSkill(skillID)
	local res = false;
	local skill = self._tournamentSkills[skillID]
	if skill then
		if self:CanUseSkill(skill) then
			self:TestBreakAttack(skill);
			self._maunalSkill = skill
			res = true
		else
			if not self:TrySequentialSkill(skill) then
				self._PreCommand = ePreTypeTournamentSkill
				self._tournamentSkillID = skillID
			else
				res = true
			end
		end
	end
	return res
end

function i3k_hero:GetTournamentSkillCoolLeftTime(skillID)
	if self._tournamentSkills[skillID] then
		return self._tournamentSkills[skillID]:GetCoolTime()
	end

	return 0, 0
end

function i3k_hero:GetTournamentSkillIsCanUse(skillID)
	if self._tournamentSkills[skillID] then
		return self._tournamentSkills[skillID]._canUse
	end

	return true;
end
-- 神器乱战技能 end

---副本特殊技能（增加shareTotalCool公cd字段）
function i3k_hero:CreateGameInstanceSkill(skillId, level, coolTime, shareTotalCool)
	if not self._gameInstanceSkills[skillId] then
		local skillCfg = i3k_db_skills[skillId]
		local skillLvl = level or 1
		local skill = require("logic/battle/i3k_skill")
		if skillCfg and skill then
			self._gameInstanceSkills[skillId] = skill.i3k_skill_create(self, skillCfg, skillLvl, 0, skill.eSG_Skill)
			self._gameInstanceSkills[skillId]._gameInstanceSkillId = skillId;
			self._gameInstanceSkills[skillId]:SetSkillShareTotalCool(shareTotalCool) --设置公cd，没有则都为nil
		end
	end
	self._gameInstanceSkills[skillId]:CalculationCoolTime(coolTime, nil, shareTotalCool)
end

function i3k_hero:UseGameInstanceSkill(skillId)
	local res = false;
	local skill = self._gameInstanceSkills[skillId]
	if skill then
		self._gameInstanceSkillId = skillId
		if self:CanUseSkill(skill) then
			self:TestBreakAttack(skill);
			self._maunalSkill = skill
			res = true
		else
			if not self:TrySequentialSkill(skill) then
				self._PreCommand = ePreGameTypeInstanceSkill
			else
				res = true
			end
		end
	end
	return res
end

function i3k_hero:GetGameInstanceSkillCoolTime(skillId)
	if self._gameInstanceSkills[skillId] then
		return self._gameInstanceSkills[skillId]:GetCoolTime()
	end

	return 0, 0
end

function i3k_hero:ClearGameInstanceSkills()
	self._gameInstanceSkills = {}
	self._gameInstanceSkillId = -1
end

function i3k_hero:setDungeonSkillShareTime(skillId, shareTime)
	for i,v in pairs(self._gameInstanceSkills) do
		if i ~= skillId then
			v:CalculationCoolTime(0)
		end
	end
end

function i3k_hero:ResetDungeonSkillCoolTime(skillId, time)
	if self._gameInstanceSkills[skillId] then
		self._gameInstanceSkills[skillId]:CalculationCoolTime(time)
	end
end

function i3k_hero:GetSkillWithId(skillId)
	if not self._skills[skillId] then
		if self._ultraSkill and self._ultraSkill._id==skillId then
			return self._ultraSkill
		elseif self._uniqueSkill and self._uniqueSkill._id==skillId then
			return self._uniqueSkill
		elseif self._dodgeSkill and self._dodgeSkill._id==skillId then
			return self._dodgeSkill
		elseif self._DIYSkill and self._DIYSkill._id==skillId then
			return self._DIYSkill
		elseif self._anqiSkill and self._anqiSkill._id == skillId then
			return self._anqiSkill
		elseif self._spiritSkill and self._spiritSkill._id == skillID then
			return self._spiritSkill
		end
		if self._itemSkills then
			for i,v in pairs(self._itemSkills) do
				local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(i)
				if itemCfg and skillId==itemCfg.args1 then
					return self._itemSkills[i]
				end
			end
		end
		if self._tournamentSkills then
			return self._tournamentSkills[skillId]
		end
		if self._gameInstanceSkills[skillId] then
			return self._gameInstanceSkills[skillId]
		end
	else
		return self._skills[skillId]
	end
end

--设置技能cd
function i3k_hero:SetSkillCoolTick(skillId, coolTick)
	local skill = self:GetSkillWithId(skillId)
	if skill then
		skill:CalculationCoolTime(coolTick,true);
	end
end

--打断技能
function i3k_hero:TestBreakAttack(skill)
	if skill._isRunNow and self._useSkill and self._useSkill._id~=skill._id then
		self:ClearAttckState();
		i3k_sbean.break_old_skill()
	end
end

function i3k_hero:ClearAttckState()
	self:FinishAttack();
	self:ResetMaunalAttack();
	self._curSkill = nil;
	self._target = nil;
	self:ClsAttackers();
end

--切换目标
function i3k_hero:ChangeEnemy()
	if self._behavior and self._behavior:Test(eEBTaunt) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(618))
		return
	end
	self:UpdateAlives()
	local alives = self._alives[2]
	if alives and #alives>0 then
		local target = nil
		if self._iscarRobber==1 then
			local spareTarget = nil
			for i,v in ipairs(alives) do
				if v.entity:GetEntityType()==eET_Car then
					target = v.entity
					break
				elseif v.entity._iscarOwner==1 then
					spareTarget = v.entity
				end
			end
			if not target and spareTarget then
				target = spareTarget
			end
		else
			local logic = i3k_game_get_logic()
			target = self:FilterTargetInForceWar(logic._selectEntity) or self:FilterTarget(logic._selectEntity)
		end
		if target  then
			self:SetForceTarget(target);
		end
	end
end

function i3k_hero:FilterTarget(selectTarget)--0:和平、1:自由、2:善恶
	local target = selectTarget
	local alives = self._alives[2]
	local repeatIndex = 0
	local selectTable = {}
	while (not target or (selectTarget and target._guid==selectTarget._guid or target:GetEntityType()~=eET_Monster)) and repeatIndex<#alives do

		local index = math.ceil(math.random(0, #alives))
		index = index==0 and 1 or index
		while selectTable[index] do
			index = math.ceil(math.random(0, #alives))
			index = index==0 and 1 or index
		end
		target = alives[index].entity
		selectTable[index] = true
		repeatIndex = repeatIndex + 1
	end
	if selectTarget then
		local selectPlayer = function (target)
			for i,v in ipairs(alives) do
				if v.entity:GetEntityType()== eET_Player and v.entity._guid ~= target._guid and v.entity._guid ~= selectTarget._guid then
					local guid = string.split(v.entity._guid, "|")
					local RoleID = tonumber(guid[2])
					if not g_i3k_game_context:IsTeamMember(RoleID) then
						target = alives[i].entity
						break
					end
				end
			end
			return target
		end
		local isHavePlayer = function()
			for i,v in ipairs(alives) do
				if v.entity:GetEntityType()==eET_Player then
					return true
				end
			end
			return false
		end
		if self._PVPStatus ~= g_PeaceMode then
			if isHavePlayer() then
				local afterSelect = selectPlayer(target)
				if afterSelect._guid ~= selectTarget._guid then
					target = afterSelect
				else
					target = selectTarget
				end
			end
			--target = target:GetEntityType()==eET_Player and target o	r nil
		end
		if self._PVPStatus == g_GoodAvilMode then
			--优先红名
			if target and target._PVPColor < -1 then
				for i,v in ipairs(alives) do
					if v.entity:GetEntityType()==eET_Player and v.entity._PVPColor >= -1 then
						local guid = string.split(v.entity._guid, "|")
						local RoleID = tonumber(guid[2])
						if not g_i3k_game_context:IsTeamMember(RoleID) then
							target = alives[i].entity
							break
						end
					end
				end
			end
		elseif self._PVPStatus == g_FactionMode and target then
			local sectId = g_i3k_game_context:GetFactionSectId()
			local sectname = g_i3k_game_context:GetSectName()
			if sectId ~= 0 then
				if target and target._sectname and sectname == target._sectname then
					target = nil
					for i,v in ipairs(alives) do
						if v.entity:GetEntityType()==eET_Player and v.entity._sectname and v.entity._sectname~=sectname then
							local guid = string.split(v.entity._guid, "|")
							local RoleID = tonumber(guid[2])
							if not g_i3k_game_context:IsTeamMember(RoleID) then
								target = alives[i].entity
								break
							end
						end
					end
				end
			end
		end
	elseif target then
		local oldTargetGuid = target._guid
		local selectNoTargetPlayer = function (target)
			for i,v in ipairs(alives) do
				if v.entity:GetEntityType()==eET_Player then
					local guid = string.split(v.entity._guid, "|")
					local RoleID = tonumber(guid[2])
					if not g_i3k_game_context:IsTeamMember(RoleID) then
						target = alives[i].entity
						break
					end
				end
			end
			return target
		end
		if self._PVPStatus ~= g_PeaceMode then
			target = selectNoTargetPlayer(target)
		end
		if target and target:GetEntityType()==eET_Player then
			if self._PVPStatus == g_GoodAvilMode then
				if target and target._PVPColor < -1 then
					target = nil
					for i,v in ipairs(alives) do
						if v.entity:GetEntityType()==eET_Player and v.entity._PVPColor >= -1 then
							local guid = string.split(v.entity._guid, "|")
							local RoleID = tonumber(guid[2])
							if not g_i3k_game_context:IsTeamMember(RoleID) then
								target = alives[i].entity
								break
							end
						end
					end
				end
			elseif self._PVPStatus == g_FactionMode then
				local sectId = g_i3k_game_context:GetFactionSectId()
				local sectname = g_i3k_game_context:GetSectName()
				if sectId ~= 0 then
					if target and target._sectname and sectname == target._sectname then
						target = nil
						for i,v in ipairs(alives) do
							if v.entity:GetEntityType()==eET_Player and v.entity._sectname and v.entity._sectname~=sectname then
								local guid = string.split(v.entity._guid, "|")
								local RoleID = tonumber(guid[2])
								if not g_i3k_game_context:IsTeamMember(RoleID) then
									target = alives[i].entity
									break
								end
							end
						end
					end
				end
			end
			if not target then
				local world = i3k_game_get_world()
				target = world:GetEntity(eET_Monster, oldTargetGuid)
			end
		end
	end

	return target
end

function i3k_hero:FilterTargetInForceWar(selectTarget)
	local mapTb = {
		[g_FORCE_WAR]	= true,
		[g_BUDO] 		= true,
		[g_FACTION_WAR] = true,
		[g_DEFENCE_WAR] = true,
		[g_DESERT_BATTLE] = true,
		[g_SPY_STORY]	= true,
	}

	if mapTb[i3k_game_get_map_type()] then
		local alives = self._alives[2]
		local target = nil
		for i,v in ipairs(alives) do
			local condition;
			if selectTarget then
				condition = v.entity:GetEntityType() == eET_Player and v.entity._guid~=selectTarget._guid;
			else
				condition = v.entity:GetEntityType() == eET_Player
			end
			if condition then
				local guid = string.split(v.entity._guid, "|")
				local RoleID = tonumber(guid[2])
				if not g_i3k_game_context:IsTeamMember(RoleID) then
					target = alives[i].entity
					return target
				end
			end
		end
		return target
	end
	return nil
end

function i3k_hero:IsInSprog()
	return self._inSprog
end

--结婚属性
function i3k_hero:UpdateMarryProps(props)
	local _props = props or self._properties;

	-- reset all marry properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Marry, false, ePropChangeType_Base);
		v:Set(0, ePropType_Marry, false, ePropChangeType_Percent);
	end

	local marryLvl = g_i3k_game_context:GetMarryLevel()
	local cfg = i3k_db_marry_attribute[marryLvl]
	local i = 1;
	if cfg then
		while cfg["attributeRewardId"..i] do
			if cfg["attributeRewardId"..i] ~= 0 then
				local prop1 = _props[cfg["attributeRewardId"..i]];
				if prop1 then
					prop1:Set(prop1._valueMY.Base + cfg["attributeRewardCount"..i], ePropType_Marry, false, ePropChangeType_Base);
				end
			end
			i = i+1
		end
	end

	self:OnMaxHpChangedCheck()
end



--内甲相关
--装备内甲
function i3k_hero:AttachArmor(id, level, stage, rune, talent ,hideEffect)
	self._armor.id= id
	self._armor.level = level
	self._armor.stage = stage
	local cfg = i3k_db_under_wear_cfg[id]
	self._armor.restraintId = cfg.restrainId
	self._armor.restrainedId = cfg.beRestrainedId
	self._armor.rune = rune or {}
	self._armor.talent = talent
	self._armor.hideEffect = hideEffect or self._armor.hideEffect
	self:ChangeArmorEffect()
end

--内甲升级
function i3k_hero:ArmorLevelUp(id, level)
	if id==self._armor.id then
		local oldLevel = self._armor.level
		self._armor.level = level
		local cfg = i3k_db_under_wear_cfg[id]
		local oldCfg = i3k_db_under_wear_update[id][oldLevel]
		local nowCfg = i3k_db_under_wear_update[id][level]
	end
end

--内甲升阶
function i3k_hero:ArmorStageUp(id, stage)
	if id==self._armor.id then
		local oldStage = self._armor.stage
		self._armor.stage = stage
		self:ChangeArmorEffect()
	end
end

--内甲天赋投入
function i3k_hero:ArmorPutTalent(id, index, count)
	if id==self._armor.id then
		--local oldCount = self._armor.talent[index] or 0
		self._armor.talent[index] = count --+ oldCount --add by jxw 传过来的数据不要进行数据操作 直接用
	end
end

--内甲天赋重置
function i3k_hero:ResetArmorTalent()
	self._armor.talent = {}
end


--内甲符文
function i3k_hero:ArmorRune(id, rune)
	if id==self._armor.id then
		self._armor.rune = rune
	end
end

function i3k_hero:SetArmorEffectHide( hide )
	if type(hide) == 'number' then
		self._armor.hideEffect = hide
	else
		self._armor.hideEffect = hide and 1 or 0
	end
end

function i3k_hero:ChangeArmorEffect(isShowArmor)
	local world = i3k_game_get_world()
	if (world and world._mapType ~= g_FORCE_WAR and not self:isSpecial()) or isShowArmor then
		if self:GetEntityType()==eET_Player then
			if self._changemodelid then
				return;
			end
			if self._entity and #self._armor.effectId~=0 then
				for _,v in ipairs(self._armor.effectId) do
					self._entity:RmvHosterChild(v);
				end
				self._armor.effectId = {}
			end
			if g_i3k_game_context:GetUserCfg():GetIsHideAllArmorEffect() or isShowArmor == false then return; end    --如果屏蔽了所有人的特效或者设置isShow为false的时候 就return 不再挂特效
			if self._armor.hideEffect == 1 then return; end
			if self._entity and self._armor.id~=0 then
				local effectId = i3k_db_under_wear_upStage[self._armor.id][self._armor.stage].specialEffId
				for _,v in ipairs(effectId) do
					local cfg = i3k_db_effects[v]
					if cfg and self._entity then
						local effect = -1
						if cfg.hs == '' or cfg.hs == 'default' then
							effect = self._entity:LinkHosterChild(cfg.path, string.format("hero_%s_armor_%s_stage_%s_effect_%s", self._guid, self._armor.id, self._armor.stage, v), "", "", 0.0, cfg.radius)
						else
							effect = self._entity:LinkHosterChild(cfg.path, string.format("hero_%s_armor_%s_stage_%s_effect_%s", self._guid, self._armor.id, self._armor.stage, v), cfg.hs, "", 0.0, cfg.radius)
						end
						self._entity:LinkChildPlay(effect, -1, true);
						table.insert(self._armor.effectId, effect)
					end
				end
			end
		end
	end
end

function i3k_hero:AttachArmorWeakEffect()
	local world = i3k_game_get_world()
	if world and world._mapType ~= g_FORCE_WAR and not self:isSpecial() then
		if self._armorState.weakEffectId==0 then
			local effectId = i3k_db_under_wear_alone.underWearWeakEffect
			local cfg = i3k_db_effects[effectId]
			if cfg and self._entity then
				local effect = -1
				if cfg.hs == '' or cfg.hs == 'default' then
					effect = self._entity:LinkHosterChild(cfg.path, string.format("hero_%s_armor_weak_effect_%s", self._guid, effectId), "", "", 0.0, cfg.radius)
				else
					effect = self._entity:LinkHosterChild(cfg.path, string.format("hero_%s_armor_weak_effect_%s", self._guid, effectId), cfg.hs, "", 0.0, cfg.radius)
				end
				self._entity:LinkChildPlay(effect, -1, true);
				self._armorState.weakEffectId = effect
			end
		end
	end
end

function i3k_hero:DetachArmorWeakEffect()
	if self._entity and self._armorState.weakEffectId~=0 then
		self._entity:RmvHosterChild(self._armorState.weakEffectId);
		self._armorState.weakEffectId = 0
	end
end

function i3k_hero:DetachArmorEffect()
	if self._entity and #self._armor.effectId~=0 then
		for _,v in ipairs(self._armor.effectId) do
			self._entity:RmvHosterChild(v);
		end
		self._armor.effectId = {}
	end
end

function i3k_hero:UpdateArmorProps(props)
	local _props = props or self._properties
	for k,v in pairs(_props) do
		v:Set(0, ePropType_Armor, false, ePropChangeType_Base);
		v:Set(0, ePropType_Armor, false, ePropChangeType_Percent);
		v:Set(0, ePropType_ArmorRune, false, ePropChangeType_Base);
		v:Set(0, ePropType_ArmorRune, false, ePropChangeType_Percent);
		v:Set(0, ePropType_ArmorTalent, false, ePropChangeType_Base);
		v:Set(0, ePropType_ArmorTalent, false, ePropChangeType_Percent);
	end

	if self._armor.id~=0 then
		local id = self._armor.id
		local level = self._armor.level
		local stage = self._armor.stage
		local rune = self._armor.rune
		--内甲升阶属性
		local cfgStage = i3k_db_under_wear_upStage[id][stage]
		for i=1, 4 do
			local attrId = cfgStage["attrId"..i]
			if attrId~=0 then
				local attrValue = cfgStage["attrValue"..i]
				local prop = _props[attrId]
				if prop then
					prop:Set(prop._valueAM.Base + attrValue, ePropType_Armor, false, ePropChangeType_Base);
				end
			end
		end

		--内甲升级属性
		local cfgLevel = i3k_db_under_wear_update[id][level]
		for i=1, 10 do
			local attrId = cfgLevel["attrId"..i]
			if attrId~=0 then
				local plus = cfgStage.attrUpPro/10000 + 1
				local attrValue = cfgLevel["attrValue"..i] * plus
				local prop = _props[attrId]
				if prop then
					prop:Set(prop._valueAM.Base + attrValue, ePropType_Armor, false, ePropChangeType_Base);
				end
			end
		end

		--天赋属性
		for i,v in pairs(self._armor.talent) do
			local talentCfg = i3k_db_under_wear_upTalent[self._armor.id][i]
			if talentCfg.talentEffectType==1 then
				local prop = _props[talentCfg.promotedProperties]
				if prop then
					prop:Set(prop._valueAMT.Base + talentCfg.proPropertiesNums[v], ePropType_ArmorTalent, false, ePropChangeType_Base);
				end
			end
		end

		--符文
		for _,v in ipairs(self._armor.rune) do
			for __, t in ipairs(v.solts) do
				t = math.abs(t)
				if t~=0 then
					--self:UpdateProperty(propId, 1, i3k_db_under_wear_rune[t].addAttributeNum, true, false, false)
					local attrValue = i3k_db_under_wear_rune[t].addAttributeNum
					local prop = _props[i3k_db_under_wear_rune[t].addAttributeId]
					if prop then
						prop:Set(prop._valueAMR.Base + attrValue, ePropType_ArmorRune, false, ePropChangeType_Base);
					end
				end
			end
		end

		--内甲符文之语属性
		for _,v in ipairs(rune) do
			--判断符文之语的
			local rune_word_id = g_i3k_db.i3k_db_get_rune_word(v.solts)
			if rune_word_id~=0 then
				--符文之语基础属性
				local attr = g_i3k_db.i3k_db_get_rune_lang_attr(rune_word_id, g_i3k_game_context:getRuneLangLevel(rune_word_id))
				for i=1, #attr do
					local attrId = attr[i].id
					if attrId~=0 then
						local attrValue = attr[i].value
						local prop = _props[attrId]
						if prop then
							prop:Set(prop._valueAM.Base + attrValue, ePropType_Armor, false, ePropChangeType_Base);
						end
					end
				end
				--符文之语铸锭属性
				local level = g_i3k_game_context:getFuYuZhuDingLevel(rune_word_id)
				if level > 0 then
					local attr2 = i3k_db_rune_zhuDing[rune_word_id][level].attribute
					for i,v in ipairs(attr2) do
						local attrId = v.id
						if attrId ~= 0 then
							local attrValue = v.value
							local prop = _props[attrId]
							if prop then
								prop:Set(prop._valueAM.Base + attrValue, ePropType_Armor, false, ePropChangeType_Base);
							end
						end
					end
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

function i3k_hero:OnPowerChangeByArmor()
	g_i3k_game_context:SetPrePower()
	self:UpdateArmorProps();
	g_i3k_game_context:ShowPowerChange()
end

function i3k_hero:SyncArmorData(value, freeze, weak)
	if self._armor.id~=0 then
		self._armorState.value = value
		local maxValue = self:GetPropertyValue(ePropID_armorMaxValue)
		if self:GetEntityType() == eET_Player then
			g_i3k_game_context:OnArmorValueChangedHandler(value, maxValue)
		elseif self:GetEntityType() == eET_Monster and self._id then
			g_i3k_game_context:OnBossArmorValueChangedHandler(self._id, value, maxValue)
		end
		self._armorState.freeze = freeze
		if weak==1 then
			self:AttachArmorWeakEffect()
		else
			self:DetachArmorWeakEffect()
		end
	end
end

function i3k_hero:UpdateArmorValue(value)
	if self._armor.id ~= 0 then
		self._armorState.value = value
		local maxValue = self:GetPropertyValue(ePropID_armorMaxValue)
		if self:GetEntityType() == eET_Player then
			g_i3k_game_context:OnArmorValueChangedHandler(value, maxValue)
		elseif self:GetEntityType() == eET_Monster and self._id then
			g_i3k_game_context:OnBossArmorValueChangedHandler(self._id, value, maxValue)
		end
	end
end

function i3k_hero:GetArmorFreezeState()
	return self._armorState.freeze == 1
end

function i3k_hero:SetArmorFreeze(val)
	self._armorState.freeze = val
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateNeijiaFreeze", self:GetArmorFreezeState())
end

function i3k_hero:UpdateArmorRecovery(dTick)
	local world = i3k_game_get_world()
	if world and not world._syncRpc then --单机本内甲值回复
		self._armorState.recTicks = self._armorState.recTicks + dTick * i3k_engine_get_tick_step()
		local armorRec = self:GetPropertyValue(ePropID_armorRec)
		local armorVal = self:GetPropertyValue(ePropID_armorCurValue)
		local armorMaxVal = self:GetPropertyValue(ePropID_armorMaxValue)
		if self:GetArmorFreezeState() then --内甲冻结状态
			local armorFreeze = self:GetPropertyValue(ePropID_armorFrezze)
			self._armorState.recTicks = 0 --进入内甲冻结状态，内甲回复cd清零
			self._armorState.freezeTicks = self._armorState.freezeTicks + dTick * i3k_engine_get_tick_step()
			if self._armorState.freezeTicks > i3k_db_common.armor.frezzeSpace - armorFreeze then
				self:SetArmorFreeze(0)
				self._armorState.freezeTicks = 0
			end
		end
		if self._armorState.recTicks > i3k_db_common.armor.recSpace and armorVal ~= armorMaxVal and not self:GetArmorFreezeState() then
			armorVal = armorVal + armorRec
			armorVal = armorVal > armorMaxVal and armorMaxVal or armorVal
			self:UpdateArmorValue(armorVal)
			self._armorState.recTicks = 0
		end
	end
end

-- 单机本死亡复活回复内甲值比例
function i3k_hero:onRevieArmorValue()
	local world = i3k_game_get_world()
	if world and not world._syncRpc and self._armor.id ~= 0 then
		local recoveryPercent = self:GetPropertyValue(ePropID_ReviveArmorPercent) / 10000
		local armorMaxVal = self:GetPropertyValue(ePropID_armorMaxValue)
		local armorVal = self:GetPropertyValue(ePropID_armorCurValue)
		local value = armorVal < armorMaxVal * recoveryPercent and armorMaxVal * recoveryPercent or armorVal
		self:UpdateArmorValue(value)
	end
end

-- 自动离线
function i3k_hero:UpdateAutoOffline(dTick)
	local isdead = self:IsDead()
	if self:IsDead() then
		self._autoOfflineTime.deadTime = self._autoOfflineTime.deadTime + dTick * i3k_engine_get_tick_step();
		if self._autoOfflineTime.deadTime > 1000 * i3k_db_common.autoOffline.offlineDeadTime then
			i3k_sbean.role_logout()
			self._autoOfflineTime.deadTime = 0
		end
	else
		self._autoOfflineTime.deadTime = 0
	end

	if self:isDaZuo() then
		self._autoOfflineTime.dazuoTime = self._autoOfflineTime.dazuoTime + dTick * i3k_engine_get_tick_step();
		if self._autoOfflineTime.dazuoTime > 1000 * i3k_db_common.autoOffline.offlineDazuoTime then
			i3k_sbean.role_logout()
			self._autoOfflineTime.dazuoTime = 0
		end
	else
		self._autoOfflineTime.dazuoTime = 0
	end
end

function i3k_hero:ResetAutoOfflineTime()
	self._autoOfflineTime = {deadTime = 0, dazuoTime = 0}
end

function i3k_hero:ChildAttack(mainSkill, skillID)

end

-- 相依相偎
function i3k_hero:SyncHugMode(leaderId, member)
	local guid = string.split(self._guid, "|")
	local roleID = tonumber(guid[2])
	self._hugMode.valid = true
	self._hugMode.leaderId = leaderId
	self._hugMode.isLeader = roleID == leaderId
	if member then
		self._hugMode.member = member
		self._hugMode.memberId = member.overview.id
	end
	if self:IsPlayer() then
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandFishPrompt) -- 进入双人互动状态关闭钓鱼提示
		g_i3k_game_context:OnHugChangedHandler()
	end
end

function i3k_hero:LeaveHugMode() --离开相依相偎
	self._hugMode = {valid = false, leaderId = 0, isLeader = false, member = nil, memberId = 0, isStarKiss = false, isStarKissTime = 0}
	if self:GetEntityType() == eET_Player then
		if self:IsPlayer() then
			self:AddAiComp(eAType_MOVE)
			g_i3k_game_context:OnHugChangedHandler()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBattleTreasure")
		end
		self:ChangeCombatEffect(self._combatType)
		self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
	end
end

function i3k_hero:IsOnHugMode() --是否在相依相偎的状态
	return self._hugMode.valid
end

function i3k_hero:GetHugLeaderId()
	return self._hugMode.leaderId
end

function i3k_hero:IsHugLeader()
	return self._hugMode.isLeader
end

function i3k_hero:ClearHug()
	if self:IsPlayer() and self._hugMode.valid then
		local standAction = self:GetHeroStandAction(self)
		local logic = i3k_game_get_logic()
		local world = i3k_game_get_world()
		local pos = i3k_vec3_clone(self._curPos);
		pos.x = pos.x + 100;
		pos.z = pos.z + 100;
		if self:IsHugLeader() then
			if self._linkHugChild then
				self:PlayHugAction(self, i3k_db_common.hugMode.layDown, standAction);
				local childStandAction = self:GetHeroStandAction(self._linkHugChild)
				self:PlayHugAction(self._linkHugChild, i3k_db_common.hugMode.laiedDown, childStandAction);
				self._linkHugChild:RemoveHugLinkChild()
				self._linkHugChild:EnableOccluder(false)
				self._linkHugChild:SetPos(pos, true)
			end
			world:AddEntity(self._linkHugChild)
			self._linkHugChild = nil
		else
			self:AddAiComp(eAType_MOVE)
			local Entity = world:GetEntity(eET_Player, self._hugMode.leaderId)--主动者
			if Entity then
				Entity:DetachCamera()
				Entity._hugMode.valid = false
				self:PlayHugAction(self, i3k_db_common.hugMode.laiedDown, standAction)
				local childStandAction = self:GetHeroStandAction(Entity)
				Entity:PlayHugAction(Entity, i3k_db_common.hugMode.layDown, childStandAction);
				self:RemoveHugLinkChild()
				if Entity._linkHugChild then
					Entity._linkHugChild = nil
				end
			end
			self:SetPos(pos, true)
			self:DetachCamera()
			self:AttachCamera(logic:GetMainCamera())
		end
	end
end
function i3k_hero:GetHeroStandAction(entity)
	local combatType =  entity:GetCombatType()
	local standAction = combatType > 0 and boxerActionList[combatType] or i3k_db_common.engine.defaultStandAction
	return standAction
end

function i3k_hero:VerifyHugMember(roleID)
	return self._hugMode.memberId == roleID
end

function i3k_hero:IsHugMemberMode()
	return self._hugMode.valid and not self._hugMode.isLeader
end

function i3k_hero:IsHugLeaderMode()
	return self._hugMode.valid and self._hugMode.isLeader
end

function i3k_hero:CheckUnHug()
	if self:IsPlayer() and self:IsOnHugMode() then
		i3k_sbean.staywith_leave()
	end
end

function i3k_hero:isStarMemeda(value)
	self._hugMode.isStarKiss = value;
end

function i3k_hero:UpdateWeaponTalentProps(props)
	local _props = props or self._properties;
	for k, v in pairs(_props) do
		v:Set(0, ePropType_Weapon_Talent,false,ePropChangeType_Base);
		v:Set(0, ePropType_Weapon_Talent,false,ePropChangeType_Percent);
	end
	if self._superMode.valid then
		local weaponId = g_i3k_game_context:GetSelectWeapon()
		if weaponId then
			if weaponId ~= 0 then
				local weaponTalentData = g_i3k_game_context:GetShenBingTalentData()
				if weaponTalentData then
					for i = 1,#i3k_db_shen_bing_talent[weaponId] do
						local proId = i3k_db_shen_bing_talent[weaponId][i].promotedProperties
						if proId ~= 0 then
							local prop1 = _props[proId];
							local point =  weaponTalentData[weaponId][i]
							local promotedPropertiesCount = i3k_db_shen_bing_talent[weaponId][i].proPropertiesNums[point]
							local proType = i3k_db_shen_bing_talent[weaponId][i].proPropertiesType
							if prop1 then
								if promotedPropertiesCount then
									if proType == 1 then
										prop1:Set(prop1._valueTL.Base + promotedPropertiesCount, ePropType_Weapon_Talent, false, ePropChangeType_Base);
									else
										prop1:Set(prop1._valueTL.Percent + promotedPropertiesCount , ePropType_Weapon_Talent,false,ePropChangeType_Percent);
									end
								end
							end
						end
					end
				end
			end
		end
		self:OnMaxHpChangedCheck()
	end
	self:UpdateWeaponAi()
end

function i3k_hero:UpdateWeaponAi()
	self:ClsWeaponAi()
	if self._superMode.valid then
		local weaponId = g_i3k_game_context:GetSelectWeapon()
		if weaponId then
			if weaponId ~= 0 then
				local weaponTalentData = g_i3k_game_context:GetShenBingTalentData()
				if weaponTalentData then
					for i = 1,#i3k_db_shen_bing_talent[weaponId] do
						local proType = i3k_db_shen_bing_talent[weaponId][i].talentEffectType
						if proType == 2 then
							local inputPoint =  weaponTalentData[weaponId][i]
							local tgcfgId = i3k_db_shen_bing_talent[weaponId][i].addTriggerskillNums[inputPoint]
							local tgcfg =  i3k_db_ai_trigger[tgcfgId]
							local mgr = self._triMgr
							if mgr then
								local TRI = require("logic/entity/ai/i3k_trigger");
								local tri = TRI.i3k_ai_trigger.new(self);
								if tri:Create(tgcfg,-1,tgcfgId) then
									local tid = mgr:RegTrigger(tri, self);
									if tid >= 0 then
										table.insert(self._weapontids, tid);
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function i3k_hero:ClsWeaponAi()
	if self._weapontids then
		if self._triMgr then
			for k, v in ipairs(self._weapontids) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._weapontids = {};
	end
end

function i3k_hero:getPowerByProperty(syllable, isDesert)
	local props = {}
	for k,v in pairs(self._properties) do
		local value = v:GetPropertyPart(syllable)
		if value then
			props[k] = value.Base
		end
	end
	return g_i3k_db.i3k_db_get_battle_power(props, true, false, isDesert)
end

--玩家统一模型设置
function i3k_hero:OnUnifyMode(enable)
	local isCombat = i3k_get_is_combat()
	if not isCombat then
		self._unifyMode.cache.valid = enable
		if self:IsResCreated() then
			if enable then
				self:ClearEquipEffect()
				self._unifyMode.valid = true
				local showType = self._bwType
				local mapType = i3k_game_get_map_type()

				local mapeTypes = 
				{
					[g_FORCE_WAR] = true,
					[g_FACTION_WAR] = true,
					[g_DEFENCE_WAR] = true,
				}

				if mapeTypes[mapType] then
					showType = self._forceType
				end

				local modelID = g_i3k_db.i3k_db_get_unify_model_id(self._id, self._gender, showType)

				if self:IsPlayer() then -- 设置统一模型问题，先下马换模型，然后回调回来换模型
					if self:IsOnRide() then
						self:OnRideMode(false, true)
						self._isAgainRide = true
						self:ChangeModelFacade(modelID)
					else
						self:ChangeModelFacade(modelID)
					end
				else
					self:ChangeModelFacade(modelID)
				end
			else
				self:AttachEquipEffect()
				self._unifyMode.valid = false
				self:RestoreModelFacade()
			end
			self:PlayAction();
		end
	end
end

--带分身的神兵特技
function i3k_hero:OnWeaponWithCloneEffectChangedHandler(superMode)
	--如果是不在普通副本或者未激活 不创建分身
	local curWeapon = g_i3k_game_context:GetSelectWeapon()
	local world = i3k_game_get_world()
	if world._syncRpc or g_i3k_game_context:GetShenBingUniqueSkillData(curWeapon) ~= 1 then
		return;
	end
	local player = i3k_game_get_player()
	local hero = i3k_game_get_player_hero()
	if superMode then
		local cfg = i3k_db_shen_bing_unique_skill[curWeapon]
		for k,v in pairs(cfg) do
			local isMax = g_i3k_game_context:isMaxWeaponStar(curWeapon)--是否满星了
			local parameters = isMax and v.manparameters or v.parameters
			if v.uniqueSkillType == e_WEAPON_TYPE_CALL_CLONE then
				g_i3k_game_context:SetWeaponCloneBodyInheritRatio(parameters[3])
				local summonedId = parameters[g_i3k_game_context:GetRoleGender()]
				player:RmvWeaponCloneBody()
				hero:CreateSummoned(hero._skills, 1, nil, summonedId)
				local summoned = player:GetWeaponCloneBody()
				local tgcfg =  i3k_db_ai_trigger[parameters[4]]
				if summoned._triMgr then
					local TRI = require("logic/entity/ai/i3k_trigger");
					local tri = TRI.i3k_ai_trigger.new(summoned);
					if tri:Create(tgcfg,-1,parameters[4]) then
						local tid = summoned._triMgr:RegTrigger(tri, summoned);
						if tid >= 0 then
							summoned._tids = summoned._tids or {}
							table.insert(summoned._tids, tid);
						end
					end
				end
			end
		end
	else
		local cloneBody = player:GetWeaponCloneBody()
		cloneBody:OnDamage(cloneBody, nil, cloneBody:GetPropertyValue(ePropID_maxHP), nil, eSE_Damage)
	end
end
--单机本增加神兵熟练度
function i3k_hero:PrivateMapWeaponMaster()
	local world = i3k_game_get_world()
	if world and not world._syncRpc and self:IsInSuperMode() then
		local data = i3k_sbean.privatemap_weapon_master.new()
		i3k_game_send_str_cmd(data)
	end
end

function i3k_hero:CheckUpdateSp(func)
	if self:IsPlayer() then
		local world = i3k_game_get_world()
		if not world._syncRpc then
			if not self:IsInSuperMode() and self._sp < self:GetPropertyValue(ePropID_maxSP) then
				func()
			end
		else
			func()
		end
	else
		func()
	end
end

function i3k_hero:updateRoleLifeCount()
	if self:IsPlayer() and i3k_game_get_map_type() == g_TOURNAMENT then
		g_i3k_game_context:OnRoleLifeChangedHandler()
	end
end

function i3k_hero:UpdateDamageRank(target, value)
	if target:GetEntityType() == eET_Monster then
		local isMercenary = self:GetEntityType() == eET_Mercenary
		if (self:IsPlayer() or isMercenary ) and value > 0 then
			local damageRank = g_i3k_game_context:GetMapCopyDamageRank()
			local guid = self:GetGuidID()
			if isMercenary then
				guid = self._cfg.id
			end
			if damageRank[guid] then
				damageRank[guid].damage = damageRank[guid].damage + value
			else
				if self:IsPlayer() then
					local roleName = g_i3k_game_context:GetRoleName()
					damageRank[guid] = {attackName = roleName, damage = value}
				elseif isMercenary then
					damageRank[guid] = {attackName = "", damage = value}
				end
			end
			g_i3k_game_context:OnDamageChangedHandler(damageRank)
		end
	end
end

function i3k_hero:TestFloationBehavior(target, dmg)
	if target:GetEntityType() == eET_Player and dmg > 0 then --被击几率延长浮空状态
		if target._behavior:Test(eEBFloating) then
			local rnd1 = i3k_engine_get_rnd_f(0, 1);
			if i3k_db_common.skill.attackedExtendOdds / 10000 >= rnd1 then
				target:ProlongFloationgBuff(i3k_db_common.skill.attackedExtendTime)
			end
		end
	end
end

function i3k_hero:updateWoodManDamage(dam)
	local target_cfg = self._cfg
	if target_cfg.isRecordDamage and target_cfg.isRecordDamage > 0 then
		g_i3k_game_context:setWoodManDamage(self._guid, target_cfg.id, dam)
	end
end

-- 观战者状态,目前只有渠道对抗赛，武道会线下赛用到
function i3k_hero:SetGuardSatate(state)
	self._isGuard = state
end

function i3k_hero:GetIsGuard()
	return self._isGuard
end

function i3k_hero:PlayFloatingAction()
    local alist = {}
    table.insert(alist, {actionName = i3k_db_common.skill.floatFlyAction, actloopTimes = 1})
    table.insert(alist, {actionName = i3k_db_common.skill.floatSuspendStart, actloopTimes = 1})
    table.insert(alist, {actionName = i3k_db_common.skill.floatSuspendContinue, actloopTimes = -1})
	self:PlayActionList(alist, 1);
end

-- 播放玩家给赛跑宠物扔道具的动作
function i3k_hero:PlayPetRaceActions()
    local alist = {}
    table.insert(alist, {actionName = i3k_db_common.petRace.actionName, actloopTimes = 1})
    table.insert(alist, {actionName = i3k_db_common.engine.defaultStandAction, actloopTimes = -1})
	self:PlayActionList(alist, 1);
end

--水域状态
function i3k_hero:SpringReset(checked)
	if checked and self._isInWater == false and self._isInLand == false then
		return
	end

	if self._behavior:Test(eEBMove) then
		self:Play(i3k_db_spring.common.landWalk, -1);
	else
		self:Play(i3k_db_spring.common.landIdle, -1);
	end

    self._isInWater = false
    self._isInLand = false
end

function i3k_hero:InWater(checked)
	if self._isInWater then
		return
	end

    self._isInLand = false
    self._isInWater = true

	if not self:IsOnRide() then
		if self._behavior:Test(eEBMove) then
			self:Play(i3k_db_spring.common.waterWalk, -1);
		else
			self:Play(i3k_db_spring.common.waterIdle, -1);
		end
	end
	if not checked then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpringAct, "onDoubleStateChange")
	end
end

function i3k_hero:InLand(checked)
	if self._isInLand then
		return
	end
    self._isInLand = true
    self._isInWater = false
	if not self:IsOnRide() then
		if self._behavior:Test(eEBMove) then
			self:Play(i3k_db_spring.common.landWalk, -1);
		else
			self:Play(i3k_db_spring.common.landIdle, -1);
		end
	end
	if not checked then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpringAct, "onDoubleStateChange")
	end
end

function i3k_hero:IsInWater()
	return self._isInWater
end

function i3k_hero:IsInLand()
	return self._isInLand
end

function i3k_hero:InSpring()
	self:UpdateProperty(ePropID_speed, 1, i3k_db_spring.common.speed, true, false, true);
end

--温泉双人互动使用坐骑逻辑，邀请者先上马
function i3k_hero:SetSpringDoubleAct(actType)
	local horseID = actType == g_SPRING_WATER_TYPE and i3k_db_spring.common.waterCarModelId or i3k_db_spring.common.umbrellaModelId
	if self:IsPlayer() then
		self:UseRide(horseID)
	end
	self:setRideCurShowID(i3k_db_steed_cfg[horseID].huanhuaInitId)
	self:OnRideMode(true, self:IsPlayer())
end

function i3k_hero:PlaySpringIdleAct()
	if self:IsPlayer() then
		if self:IsInWater() then
			self:Play(i3k_db_spring.common.waterIdle, -1);
		else
			self:Play(i3k_db_spring.common.landIdle, -1);
		end
	else
		if g_i3k_game_context:getSpringPos(self._curPosE) == SPRING_TYPE_WATER then
			self:Play(i3k_db_spring.common.waterIdle, -1);
		else
			self:Play(i3k_db_spring.common.landIdle, -1);
		end
	end
end

function i3k_hero:SetSpringDoubleType(springType)
	self._springDoubleType = springType
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpringAct, "onDoubleStateChange")
end

function i3k_hero:GetSpringDoubleType()
	return self._springDoubleType
end

local areaTb = {
	[g_HOMELAND_FISH_AREA] 			= {enterHandler = "InFishArea", leaveHandler = "LeaveFishArea"},
	[g_GODMACHINE_SLOW_AREA] 		= {enterHandler = "InGodMachineSlowArea", leaveHandler = "LeaveGodMachineSlow"},
	[g_GODMACHINE_NPC_PATH_AREA] 	= {enterHandler = "InGodMachineAlleyway", leaveHandler = "LeaveGodMachineAlleyway"},
	[g_CATCH_SPIRIT_AREA] 			= {enterHandler = "InCatchSpiritArea", leaveHandler = "LeaveCatchSpiritArea"},
	[g_SPY_STORY_AREA]				= {enterHandler = "InSpyStoryArea", leaveHandler = "LeaveSpyStoryArea"},
}

function i3k_hero:LeaveFishArea()
    g_i3k_game_context:onUpdateFishPromptHandler(false)
end
function i3k_hero:InFishArea(_, facePos)
    g_i3k_game_context:SetHomeLandFishPos(facePos)
	g_i3k_game_context:onUpdateFishPromptHandler(true)
end
function i3k_hero:LeaveGodMachineSlow()
	self:changMovingSpeedHander()
end
function i3k_hero:InGodMachineSlowArea(oldAreaType)
	self:changMovingSpeedHander()
end
function i3k_hero:LeaveGodMachineAlleyway()
end
function i3k_hero:InGodMachineAlleyway(oldAreaType)
end
function i3k_hero:InCatchSpiritArea()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateCatchSpiritEffect")
end
function i3k_hero:LeaveCatchSpiritArea()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateCatchSpiritEffect")
end
function i3k_hero:InSpyStoryArea()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "spyStoryAreaTips")
end
function i3k_hero:LeaveSpyStoryArea()
end
function i3k_hero:GetIsInFishArea()
	return self:GetAreaType() == g_HOMELAND_FISH_AREA
end
function i3k_hero:GetAreaType()
	return self._areaType
end
function i3k_hero:SetAreaType(areaType)
	self._areaType = areaType
end
function i3k_hero:ResetAreaType()
	self._areaType = 0
end
function i3k_hero:InArea(areaType, facePos, area, oldAreaType)
	if self:GetAreaType() == areaType then
		return
	end
	self:SetAreaType(areaType)
	if self[area.enterHandler] then
		self[area.enterHandler](self, oldAreaType, facePos)
	end
end

function i3k_hero:LeaveArea(checked, areaType, originalType, area)
	if checked and self:GetAreaType() ~= originalType then
		return
	end

	self:ResetAreaType()
	if self[area.leaveHandler] then
		self[area.leaveHandler](self, originalType, area)
	end 		
end

function i3k_hero:onAreaType(checked, areaType, facePos)
	local oldAreaType = self:GetAreaType()
	if oldAreaType ~= areaType then
		local oldArea = areaTb[oldAreaType]
		if oldArea then
			self:LeaveArea(checked, areaType, oldAreaType, oldArea)
end
	end
	local area = areaTb[areaType]
	if area then
		self:InArea(areaType, facePos, area, oldAreaType)		
	end
end

function i3k_hero:UpdateHeroBuffDrug()
	local validBuffTb = {}
	for _, v in pairs(g_i3k_game_context:GetValidBuffDrugData()) do
		local bcfg = i3k_db_buff[v.id];
		if v.endTime > i3k_game_get_time() and bcfg.affectType ~= 3 then
			validBuffTb[v.id] = v.endTime
		end
	end

	for _, v in ipairs(g_i3k_game_context:GetBuffDrugData()) do
		local bcfg = i3k_db_buff[v.id];
		if bcfg.affectType ~= 3 then --不是经验类buff
			if not self._buffs[v.id] and validBuffTb[v.id] then
				local BUFF = require("logic/battle/i3k_buff");
				local buff = BUFF.i3k_buff.new(nil, v.id, bcfg);
				if buff then
					self:AddBuff(nil, buff);
				end
			elseif self._buffs[v.id] and not validBuffTb[v.id] then
				local buff = self._buffs[v.id];
				if buff then
					self:RmvBuff(buff);
				end
			end
		end
	end
end

function i3k_hero:isAttachWeaponSoul()
	local world = i3k_game_get_world()
	local mapType = i3k_game_get_map_type()
	if world and self:GetEntityType() == eET_Player then
		if self._isAttachedSoul then
			return false;
		end
		if self._superMode.valid or self._missionMode.valid then
			return false;
		end
		local mapTb = {
			[g_FORCE_WAR]	= true,
			[g_DEMON_HOLE] 	= true,
			[g_FACTION_WAR] = true,
			[g_Life]  		= true,
			[g_Pet_Waken]	= true,
			[g_DEFENCE_WAR]	= true,
			[g_PET_ACTIVITY_DUNGEON] = true,
			[g_DESERT_BATTLE] = true,
			[g_MAZE_BATTLE] = true,
			[g_SPY_STORY] = true,
			[g_BIOGIAPHY_CAREER] = true,
		}
		if self:isSpecial() or mapTb[mapType] or self:GetIsGuard() then
			return false;
		end
		return g_i3k_game_context:GetWeaponSoulCurHide();
	end
	return false;
end

--武魂相关
function i3k_hero:AttachWeaponSoul(isSelChar, arg)
	if self:isAttachWeaponSoul() or isSelChar then
		local curShow = nil;
		if isSelChar then
			curShow = arg.showId;
		else
			curShow = g_i3k_game_context:GetWeaponSoulCurShow();
		end
		local martialSoul = i3k_db_martial_soul_display[curShow];
		if martialSoul then
			local modelID = i3k_engine_check_is_use_stock_model(martialSoul.modelID);
			if modelID and self._entity then
				local cfg = i3k_db_models[modelID]
				if cfg then
					local Link = i3k_db_martial_soul_cfg;
					local hosterLink = nil;
					if isSelChar then
						hosterLink = Link.hosterLink[arg.type];
					else
						hosterLink = Link.hosterLink[g_i3k_game_context:GetRoleType()];
					end
					local effectID = 0;
					if cfg.path then
						effectID = self._entity:LinkHosterChild(cfg.path, string.format("hero_soul_%s_effect_%d", self._guid, martialSoul.diaplayType), hosterLink, Link.sprLink, 0.0, cfg.scale);
					end
					self._curWeaponSoul = effectID;
					self._isAttachedSoul = true;
					self._entity:LinkChildSelectAction(effectID, i3k_db_common.engine.defaultStandAction)
					self._entity:LinkChildPlay(effectID, -1, true);
					self._entity:LinkChildShow(effectID, true)
				end
			end
		end
	end
end

function i3k_hero:ShowWeaponSoul(isShow)
	if self._entity and self._curWeaponSoul then
		self._entity:LinkChildShow(self._curWeaponSoul, isShow)
	end
end

function i3k_hero:ChageWeaponSoulAction(action)
	if self._entity and self._curWeaponSoul then
		self._entity:LinkChildSelectAction(self._curWeaponSoul, action)
		self._entity:LinkChildPlay(self._curWeaponSoul, -1, true);
	end
end

function i3k_hero:DetachWeaponSoul()
	if self._entity and self._curWeaponSoul then
		self._entity:RmvHosterChild(self._curWeaponSoul);
		self._isAttachedSoul = false;
		self._curWeaponSoul = nil;
	end
end

function i3k_hero:setSpecialArg(value)
	self._specialArg = value
end

function i3k_hero:GetMonsterShowName()
	local name = self._name
	if self._cfg.monsterType == g_MONSTER_SPECIAL_NAME and self._specialArg ~= 0 and i3k_db_robber_monster_cfg[self._specialArg] then
		name = i3k_db_robber_monster_cfg[self._specialArg].name
	end
	return name
end

function i3k_hero:IsPlayerMove()
	if self:GetEntityType() == eET_Player then
		if self._behavior:Test(eEBMove) then
			return true
		else
			return false
		end
	end
	return false
end

function i3k_hero:IsPlayerAttack()
	if self:GetEntityType() == eET_Player then
		if self._behavior:Test(eEBAttack) then
			return true
		else
			return false
		end
	end
	return false
end

--------------------------------------武器祝福--------------------------

local BLESS_STATE_NULL = 0 --武器祝福空状态
local BLESS_STATE_UP = 1 --武器祝福积攒状态
local BLESS_STATE_MAX = 2 --武器祝福积满状态
local BLESS_STATE_DOWN = 3 --武器祝福衰退状态

function i3k_hero:InitWeaponBless()
	self._weaponBless = {
		ID = 0, --武器祝福技能ID
		level = 0, --武器祝福技能等级
		state = BLESS_STATE_NULL, --武器祝福状态
		curLevel = 0, --当前层数
		upTick = 0, --积攒计时器
		downTick = 0, --衰退计时器
		hitCount = 0, --衰退时伤害计数器
		resetUpTick = function()
			local args = g_i3k_game_context:GetWeaponBlessArgs()
			if args then
				self._weaponBless.upTick = args.upCD/1000
			end
		end,
		resetDownTick = function()
			local args = g_i3k_game_context:GetWeaponBlessArgs()
			if args then
				self._weaponBless.downTick = args.downCD/1000
			end
		end,
		resetHitCount = function()
			self._weaponBless.hitCount = 0
		end,
		setCurLevel = function(level)
			local args = g_i3k_game_context:GetWeaponBlessArgs()
			if args then
				local maxLevel = args.trigger_need_level
				self._weaponBless.curLevel = math.min(level, maxLevel)
				if self._weaponBless.curLevel == maxLevel and (self._weaponBless.state == BLESS_STATE_NULL or self._weaponBless.state == BLESS_STATE_UP) then
					self._weaponBless.changeState(BLESS_STATE_MAX)
				end
				if self._weaponBless.curLevel == 0 then
					self._weaponBless.changeState(BLESS_STATE_NULL)
				end
				self:onWeaponBlessLevelChange()
			end
		end,
		getCurLevel = function()
			return self._weaponBless.curLevel
		end,
		isCurLevelMax = function()
			return self._weaponBless.isLevelMax(self._weaponBless.curLevel)
		end,
		isLevelMax = function(level)
			local args = g_i3k_game_context:GetWeaponBlessArgs()
			if args then
				return level == args.trigger_need_level
			end
		end,
		isCurLevelZero = function()
			return self._weaponBless.curLevel == 0
		end,
		changeState = function(state)
			self._weaponBless.state = state
			if state == BLESS_STATE_NULL then
				self:onBlessSkillEnd()
			end
		end,
		clearState = function()
			self._weaponBless.setCurLevel(0)
		end,
		[BLESS_STATE_NULL] = function()
			if self._weaponBless.upTick == 0 then
				self._weaponBless.changeState(BLESS_STATE_UP)
				self._weaponBless.setCurLevel(1)
				self._weaponBless.resetUpTick()
			end
		end,
		[BLESS_STATE_UP] = function()
			if self._weaponBless.upTick == 0 and self._weaponBless.curLevel < g_i3k_game_context:GetWeaponBlessArgs().trigger_need_level then
				self._weaponBless.setCurLevel(self._weaponBless.getCurLevel() + 1)
				if self._weaponBless.isCurLevelMax() then
					self._weaponBless.changeState(BLESS_STATE_MAX)
				end
				self._weaponBless.resetUpTick()
			end
		end,
		[BLESS_STATE_MAX] = function()
		 end,
		[BLESS_STATE_DOWN] = function()
			local args = g_i3k_game_context:GetWeaponBlessArgs()
			if not args then return end
			if self._weaponBless.curLevel > 0 then
				self._weaponBless.hitCount = self._weaponBless.hitCount + 1
				if self._weaponBless.hitCount == args.downCount then
					local isLuckBless = false
					if not self._syncRpc then
						local skill = g_i3k_game_context:GetHammerSkillByTypeOnWearEquip(g_EQUIP_SKILL_TYPE_LUCKY_BLESS)
						if next(skill) then
							for k, v in pairs(skill) do
								local args = i3k_db_equip_temper_skill[k][v].args
								local curLvl = self._weaponBless.getCurLevel()
								if math.random(1,10000) <= args[1] then
									isLuckBless = true
									i3k_sbean.role_weaponbless_state.handler({state = 2})--冒字
								end
							end
						end
					end
					if not isLuckBless then
					self._weaponBless.setCurLevel(self._weaponBless.getCurLevel() - 1)
					end
					self._weaponBless.resetHitCount()
					if self._weaponBless.isCurLevelZero() then
						self._weaponBless.changeState(BLESS_STATE_NULL)
					end
				end
				if self._weaponBless.downTick == 0 and self._weaponBless.hitCount == g_i3k_game_context:GetWeaponBlessArgs().downCount then
					self._weaponBless.resetDownTick()
				end
			end
		end,
	};
end
--设置祝福技能
function i3k_hero:SetWeaponBless(id, level)
	self._weaponBless.ID = id
	self._weaponBless.level = level
end

--获取当前武器祝福能量层数
function i3k_hero:GetRoleWeaponBlessEnergy()
	return self._weaponBless.curLevel
end

--清空武器祝福状态
function i3k_hero:ClearWeaponBlessState()
	self._weaponBless.clearState()
end

--获取武器祝福是否可以激活
function i3k_hero:IsWeaponBlessCanActive()
	return self._weaponBless.state == BLESS_STATE_MAX
end

--获取武器祝福状态
function i3k_hero:GetWeaponBlessState()
	return self._weaponBless.state
end

--释放武器祝福技能
function i3k_hero:ReleaseBlessSkill()
	if self._syncRpc then
		if self._weaponBless.state == BLESS_STATE_MAX then
			local bean = i3k_sbean.role_active_weapon_bless.new()
			i3k_game_send_str_cmd(bean)
		end
	else
		if self._weaponBless.state == BLESS_STATE_MAX then
			self._weaponBless.changeState(BLESS_STATE_DOWN)
			self:UpdateWeaponBlessProp()
			self:onWeaponBlessLevelChange()
		end
	end
end

--同步武器祝福状态
function i3k_hero:SyncWeaponBlessState(isActive, level)
	if level == 0 then
		self._weaponBless.setCurLevel(level) --如果能达到最大值或者最小值 直接设置层数就行
		return
	end
	if self._weaponBless and self._weaponBless.ID ~= 0 then
		if isActive == 1 then
			self._weaponBless.changeState(BLESS_STATE_DOWN)
			self._weaponBless.setCurLevel(level)
		else
			if self._weaponBless.isLevelMax(level) then
				self._weaponBless.changeState(BLESS_STATE_MAX)
			else
				self._weaponBless.changeState(BLESS_STATE_UP)
			end
			self._weaponBless.setCurLevel(level)
		end
	end
end

--更新武器祝福技能的提升的属性
function i3k_hero:UpdateWeaponBlessProp(ratio)
	local args = g_i3k_game_context:GetWeaponBlessArgs()
	if not args then
		self._WeaponBlessAllPorpReduceValue = 0
		return
	end
	if self._weaponBless.state == BLESS_STATE_DOWN then
		--修改武器祝福参数的锤炼技能
		local reviseHammerSkill = g_i3k_game_context:GetHammerSkillByTypeOnWearEquip(g_EQUIP_SKILL_TYPE_REVISE_WEAPON_BLESS_ARGUMENT)
		local allPropChangeValue = 0 --修改增锤炼增加全属性的变值
		if next(reviseHammerSkill) then
			for i, v in pairs(reviseHammerSkill) do
				local cfg = i3k_db_equip_temper_skill[i][v]
				allPropChangeValue = allPropChangeValue + cfg.args[3]
			end
		end
		local ratio = ratio or -(g_i3k_game_context:GetWeaponBlessArgs().ratio_per_level + allPropChangeValue)*self._weaponBless.curLevel
		self._WeaponBlessAllPorpReduceValue = ratio
	else
		self._WeaponBlessAllPorpReduceValue = 0
	end
end

--武器祝福技能释放回调
function i3k_hero:onWeaponBlessRelease()
	self._weaponBless.changeState(BLESS_STATE_DOWN)
	self:onWeaponBlessLevelChange()
	self:UpdateWeaponBlessProp()
end

--武器祝福技能祝福Tick
function i3k_hero:onBlessSkillTick(dTick)
	if not self._syncRpc and self:IsPlayer() and self._weaponBless.ID ~= 0 then --只有在单机本才计算
		self._weaponBless.upTick = math.max(self._weaponBless.upTick - dTick, 0)
		self._weaponBless.downTick = math.max(self._weaponBless.downTick - dTick, 0)
	end
end

--武器祝福技能 状态转换 每造成一次伤害 调用一次
function i3k_hero:onBlessSkillState()
	self._weaponBless[self._weaponBless.state]()
end

--武器祝福层数改变了
function i3k_hero:onWeaponBlessLevelChange()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateRoleWeaponBlessEnergy", g_i3k_game_context:GetRoleWeaponBlessEnergy())
	self:UpdateWeaponBlessProp()
end

--武器祝福技能结束
function i3k_hero:onBlessSkillEnd()
	self:UpdateWeaponBlessProp(0)
end
-------------------------------------end-------------------------------

--进入和离开墙面区域
function i3k_hero:EnterHouseWallArea(wallType)
	g_i3k_game_context:setInWallType(wallType)
	if not g_i3k_ui_mgr:GetUI(eUIID_HouseFurniture) then
		local callback = function ()
			g_i3k_game_context:setIsInPlaceState(true)
			g_i3k_ui_mgr:OpenUI(eUIID_HouseFurniture)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurniture)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurniture, "onChangeType", nil, 4)
		end
		i3k_sbean.house_bag_furniture_sync(callback)
	end
end

function i3k_hero:LeaveHouseWallArea()
	if g_i3k_game_context:getInWallType() then
		g_i3k_game_context:setInWallType()
		local logic = i3k_game_get_logic()
		if logic then
			local world = logic:GetWorld()
			if world._curChooseFurniture.furnitureType == g_HOUSE_WALL_FURNITURE then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurnitureSet, "onLeaveBtn")
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
	end
end

function i3k_hero:changeScoreText(score)
	if self._title and self._title.node and i3k_game_get_map_type()== g_DESERT_BATTLE then
		local hero = i3k_game_get_player_hero();
		
		if hero and hero._guid == self._guid and g_i3k_game_context:getdesertBattleViewEntity() then
			self:SetTitleVisiable(false)
			return
		end		
				
		self._title.node:UpdateTextLable(self._title.name, i3k_get_string(17600, self._name, score), true, tonumber("0xff46bcff", 16), false);		
	end
end

function i3k_hero:updatePropertyOnEnterMap()--这几个属性是在变身副本里有可能刷新的。
	self:UpdateSpecialCardProps()
	self:UpdateTitleProps()
	self:UpdateHorseProps()
end

function i3k_hero:creatWeaponManualSkill(weaponId)
	local info = i3k_db_shen_bing_unique_skill[weaponId]
	if info then	
		for _, v in pairs(info) do
			if v.uniqueSkillType == 19 then --变身后拥有【兵主】技能
				local parameters = v.parameters
				
				if g_i3k_game_context:isMaxWeaponStar(weaponId) then
					parameters = v.manparameters
				end
				
				local cfg = i3k_db_skills[parameters[1]]
				local skill = require("logic/battle/i3k_skill");
				local flag = true
				
				if self._weaponManualSkill and self._weaponManualSkill._weaponManualId == parameters[1] then
					flag = false
				end

				if skill and cfg and flag then
					self._weaponManualSkill = skill.i3k_skill_create(self, cfg, 1, 0, skill.eSG_TriSkill);
					self._weaponManualSkill._weaponManualId = parameters[1]
				end
				
				if self._weaponManualSkill and self._weaponManualSkill:getCoolTime() ~= parameters[2] then
					self._weaponManualSkill:updateCoolTimeForce(parameters[2] * 1000)
				end
				
				local totalTime, hasCoolTime = g_i3k_game_context:getRoleWeaponManualSkillCoolLeftTime()--重新登录后skill里的cd清0
							
				if hasCoolTime == 0 and self._weaponManualSkill._canUse and not g_i3k_game_context:getWeaponManualSkillIsCanUse() then
					local endtime = g_i3k_game_context:getWeaponSpecialCollTime()
					local nowtime = i3k_game_get_time()
					self._weaponManualSkill:CalculationCoolTime((endtime - nowtime) * 1000, true);
				end
			end
		end
	end	
end

function i3k_hero:useWeaponManualSkill()
	if self._weaponManualSkill then
		return self:StartAttack(self._weaponManualSkill);
	end
end

function i3k_hero:GetWeaponManualSkillCoolLeftTime()
	if self._weaponManualSkill then
		return self._weaponManualSkill:GetCoolTime()
	end

	return 0, 0
end
--！！ 这个接口仅用于测试，正式功能误用
-- 策划截图用 隐藏头顶相关，血条，称号，帮派名字等
function i3k_hero:visTitleInfo(vis)
	if self._title and self._title.node then
		if self._title.name then
			self._title.node:SetElementVisiable(self._title.name, vis)
		end
		if self._title.typeName then
			self:SetTypeNameVisiable(vis)
		end
		self:SetBloodBarVisiable(vis)
		self:SetHeroSectNameVisiable(vis)
	end
end

function i3k_hero:setSoaringDisplay(soaringDisplay)
	self._soaringDisplay = soaringDisplay
end
--飞升武器外显和脚印相关
function i3k_hero:setWeaponShowType(showType)
	i3k_init_soaring_display_info(self._soaringDisplay)
	self._soaringDisplay.weaponDisplay = showType
end

function i3k_hero:setWearShowType(showType)
	i3k_init_soaring_display_info(self._soaringDisplay)
	self._soaringDisplay.skinDisplay = showType
end
function i3k_hero:getWeaponShowType()
	local weaponDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	return weaponDisplay
end

function i3k_hero:setFootEffectId(effect)
	self._soaringDisplay.footEffect = effect
end

function i3k_hero:getFootEffectId()
	return self._soaringDisplay.footEffect
end

function i3k_hero:UpdateRoleFlyingProp(props)
	local flyingData = g_i3k_game_context:getRoleFlyingData()
	if flyingData then
		local _props = props or self._properties
		for k, v in pairs(_props) do
			v:Set(0, ePropType_RoleFlying, false, ePropChangeType_Base)
			v:Set(0, ePropType_RoleFlying, false, ePropChangeType_Percent);
		end
		local t = 0
		for k, v in pairs(flyingData) do
			if v.isOpen == 1 then
				t = k
			end
		end
		if t > 0 then 
			for i, j in ipairs(i3k_db_role_flying[t].property) do
					local prop = _props[j.id];
					if prop then
						prop:Set(prop._valueRF.Base + j.value, ePropType_RoleFlying, false, ePropChangeType_Base);
					end
				end
				self:OnMaxHpChangedCheck()
		end
	end
end
function i3k_hero:UpdateArrayStoneProp(props)
	local _props = props or self._properties
	for k, v in pairs(_props) do
		v:Set(0, ePropType_ArrayStone, false, ePropChangeType_Base)
		v:Set(0, ePropType_ArrayStone, false, ePropChangeType_Percent);
	end
	local arrayStone = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(arrayStone.exp)
	local equipSuit = {}
	local suitAdditionAll = {}
	local suitAdditionSelf = {}
	for i, j in pairs(i3k_db_array_stone_suit_group) do
		for m, n in ipairs(j.includeSuit) do
			for k, v in ipairs(arrayStone.equips) do
				if v ~= 0 then
					if g_i3k_db.i3k_db_is_in_stone_suit_group(v, i) then
						if not equipSuit[n] then
							equipSuit[n] = {}
						end
						table.insert(equipSuit[n], v)
					end
				end
			end
		end
	end
	for k, v in pairs(equipSuit) do
		local suitCfg = i3k_db_array_stone_suit[k]
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(v, k) then
			local suitLevel = g_i3k_db.i3k_db_get_stone_suit_level(v, k)
			if suitCfg.additionType == g_STONE_SUIT_ADDITION_SELF then
				if not suitAdditionSelf[k] then
					suitAdditionSelf[k] = {}
				end
				for m, n in ipairs(suitCfg.additionProperty) do
					if n.id ~= 0 then
						if not suitAdditionSelf[k][n.id] then
							suitAdditionSelf[k][n.id] = 0
						end
						suitAdditionSelf[k][n.id] = suitAdditionSelf[k][n.id] + n.value[suitLevel]
					end
				end
			elseif suitCfg.additionType == g_STONE_SUIT_ADDITION_ALL then
				for m, n in ipairs(suitCfg.additionProperty) do
					if n.id ~= 0 then
						if not suitAdditionAll[n.id] then
							suitAdditionAll[n.id] = 0
						end
						suitAdditionAll[n.id] = suitAdditionAll[n.id] + n.value[suitLevel]
					end
				end
			end
			for m, n in ipairs(suitCfg.suitProperty) do
				if n.id ~= 0 then
					local prop = _props[n.id];
					if prop then
						prop:Set(prop._valueAS.Base + n.value[suitLevel], ePropType_ArrayStone, false, ePropChangeType_Base);
					end
				end
			end
		end
	end
	for i, j in ipairs(arrayStone.equips) do
		if j ~= 0 then
			for m, n in ipairs(i3k_db_array_stone_cfg[j].commonProperty) do
				local percent = 1
				for k, v in pairs(equipSuit) do
					if table.indexof(v, j) and suitAdditionSelf[k] and suitAdditionSelf[k][n.id] then
						percent = percent + suitAdditionSelf[k][n.id] / 10000
					end
				end
				if suitAdditionAll[n.id] then
					percent = percent + suitAdditionAll[n.id] / 10000
				end
				if i3k_db_array_stone_level[level].propertyRate ~= 0 then
					percent = percent + i3k_db_array_stone_level[level].propertyRate / 10000
				end
				local prop = _props[n.id];
				if prop then
					prop:Set(prop._valueAS.Base + percent * n.value, ePropType_ArrayStone, false, ePropChangeType_Base);
				end
			end
			for m, n in ipairs(i3k_db_array_stone_cfg[j].extraProperty) do
				if level >= n.needLvl then
					local percent = 1
					for k, v in pairs(equipSuit) do
						if table.indexof(v, j) and suitAdditionSelf[k] and suitAdditionSelf[k][n.id] then
							percent = percent + suitAdditionSelf[k][n.id] / 10000
						end
					end
					if suitAdditionAll[n.id] then
						percent = percent + suitAdditionAll[n.id] / 10000
					end
					if i3k_db_array_stone_level[level].propertyRate ~= 0 then
						percent = percent + i3k_db_array_stone_level[level].propertyRate / 10000
					end
					local prop = _props[n.id];
					if prop then
						prop:Set(prop._valueAS.Base + percent * n.value, ePropType_ArrayStone, false, ePropChangeType_Base);
					end
				end
			end
		end
	end
	self:OnMaxHpChangedCheck()
end

--拳师姿态属性影响
function i3k_hero:UpdateCombatTypeProp(props)
	local _props  = props or self._properties
	local combatType = g_i3k_game_context:GetCombatType()
	for k, v in pairs(_props) do
		v:Set(0, ePropType_CombatType, false, ePropChangeType_Base)
		v:Set(0, ePropType_CombatType, false, ePropChangeType_Percent);
	end
	if combatType > 0 then
		local data = i3k_db_skill_AddData[g_BOXER_ADDTYPE[combatType]]
		local xinfa1,xinfa2 = self:UpdateCombatTypeByXinfa(combatType, data)
		local prop1 = _props[data.arg1]
		prop1:Set(prop1._valueCBT.Percent + data.arg2 + xinfa1, ePropType_CombatType, false, ePropChangeType_Percent)
		local prop2 = _props[data.arg3]
		prop2:Set(prop2._valueCBT.Percent + data.arg4 + xinfa2, ePropType_CombatType, false, ePropChangeType_Percent)
	end
	self:OnMaxHpChangedCheck()
end
function i3k_hero:UpdateCombatTypeByXinfa(combatType, data)
	local addValue1, addValue2 = 0,0
	local talent = g_i3k_game_context:GetXinfa()
	local useTalent = g_i3k_game_context:GetUseXinfa()
	if useTalent then
		if useTalent._zhiye then
			for _,id in ipairs(useTalent._zhiye) do
				local level = talent._zhiye[id]
				local tDataList = g_i3k_db.i3k_db_get_talent_effector(id, level)
				for _,xiaoGuoData in ipairs(tDataList) do
					if xiaoGuoData.type == g_XINFA_COMBATTYPE and xiaoGuoData.args.combatTypeID == combatType then
						addValue1 = addValue1 + xiaoGuoData.args.addArg1
						addValue2 = addValue2 + xiaoGuoData.args.addArg2
					end
				end
			end
		elseif useTalent._jinghua then
		elseif useTalent._paibie then
		end
	end
	return addValue1, addValue2 
end
function i3k_hero:changeFootEffect(id)
	if self._soaringDisplay and self._soaringDisplay.footEffect and self._soaringDisplay.footEffect ~= 0 then
		self:OnStopChild(self._footEffect)
	end
	self._soaringDisplay.footEffect = id
	if g_i3k_game_context:GetIsSpringWorld() then
		return
	end
	local mapType = i3k_game_get_map_type()
	local mapeTypes = 
	{
		[g_FORCE_WAR] = true,
		[g_FACTION_WAR] = true,
		[g_DEFENCE_WAR] = true,
		[g_DESERT_BATTLE] = true,
		[g_SPY_STORY]	= true,
		[g_BIOGIAPHY_CAREER] = true,
	}
	if mapeTypes[mapType] then
		return
	end
	local effectID = 0
	if self._bwType == 1 then
		effectID = i3k_db_feet_effect[self._soaringDisplay.footEffect].justiceEffect
	else
		effectID = i3k_db_feet_effect[self._soaringDisplay.footEffect].evilEffect
	end
	self._footEffect = self:PlayHitEffectAlways(effectID)
end

function i3k_hero:AttachFlyingWeapon()
	if not self:GetIsBeingHomeLandEquip() and not self._missionMode.valid and not self:IsInSuperMode() then
		self:ReleaseFashion(self._fashion, eFashion_Weapon)
		local equip = self._equips[eEquipFlying]
		if equip and equip._model.valid then
			local models = equip._model.models
			for k, v in ipairs(models) do
				local modelID = i3k_engine_check_is_use_stock_model(v.id);
				if modelID then
					local cfg = i3k_db_models[modelID]
					if cfg and self._entity then
						local effectID = 0;
						if cfg.path then
							effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_net_flying_%s_effect_%d", self._guid, v.id), cfg.heroHangPoint, cfg.weaponHangPoint, 0.0, cfg.scale);
						end
						if not self._curFlyingWeapon then
							self._curFlyingWeapon = {}
						end
						table.insert(self._curFlyingWeapon, effectID)
						self._entity:LinkChildSelectAction(effectID, i3k_db_common.engine.defaultStandAction)
						self._entity:LinkChildPlay(effectID, -1, true)
						self._entity:LinkChildShow(effectID, true)
					end
				end
			end
		else
			self:CreateFashion(self._fashion, eFashion_Weapon)
		end
	end
end

function i3k_hero:DetachFlyingEquip()
	if self._curFlyingWeapon then
		for k, v in ipairs(self._curFlyingWeapon) do
			self._entity:RmvHosterChild(v);
		end
		self._curFlyingWeapon = nil;
	end
	if not self:GetIsBeingHomeLandEquip() and not self._changemodelid and not self._isInDungeonModel and not self._missionMode.valid and not self:IsInSuperMode() then
		local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
		if weaponDisplay == g_FLYING_SHOW_TYPE then
			self:CreateFashion(self._fashion, eFashion_Weapon)
		end
	end
end

function i3k_hero:changeWeaponShowType()
	self:HidePlayerEquipPos()
	if not self:GetIsBeingHomeLandEquip() and not self._changemodelid and not self._isInDungeonModel and not self._missionMode.valid and not self:IsInSuperMode() then
		local showType, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
		if showType == g_WEAPON_SHOW_TYPE then
			self:ReleaseFashion(self._fashion, eFashion_Weapon)
			if self._equips[eEquipWeapon] and self._equips[eEquipWeapon].equipId then
				self:AttachEquip(self._equips[eEquipWeapon].equipId)
			else
				self:CreateFashion(self._fashion, eFashion_Weapon)
			end
			self:AttachEquipEffect()
		elseif showType == g_HEIRHOOM_SHOW_TYPE then
			self:AttachHeirhoomEquip()
			self:AttachEquipEffect()
		elseif showType == g_FASTION_SHOW_TYPE then
			self:SetFashionVisiable(true, g_FashionType_Weapon)
			self:AttachEquipEffect()
		elseif showType == g_FLYING_SHOW_TYPE then
			self:AttachFlyingWeapon()
		end
		self:changeClothesShowType()
	end
end
function i3k_hero:changeClothesShowType()
	local showType, skinDisplay = i3k_get_soaring_display_info(self._soaringDisplay)
	self:DetachEquip(eEquipClothes)
	self:DetachEquip(eEquipFlyClothes)
	if skinDisplay == g_WEAR_FLYING_SHOW_TYPE  then
		self:SetFashionVisiable(false, g_FashionType_Dress)
		if (self._equips[eEquipFlyClothes] and self._equips[eEquipFlyClothes].equipId) then
			self:AttachEquip(self._equips[eEquipFlyClothes].equipId)
		else
			self:ReleaseFashion(self._fashion, eEquipClothes)
			self:CreateFashion(self._fashion, eEquipClothes)
		end
	elseif skinDisplay == g_WEAR_FASHION_SHOW_TYPE  then
		self:ReleaseFashion(self._fashion, eEquipClothes)
		if self._fashionsID then
			self:SetFashionVisiable(true, g_FashionType_Dress)
		else
			self:CreateFashion(self._fashion, eEquipClothes)
		end
	elseif skinDisplay == g_WEAR_NORMAL_SHOW_TYPE then
		self:SetFashionVisiable(false, g_FashionType_Dress)
		if self._equips and self._equips[eEquipClothes]  then
			self:AttachEquip(self._equips[eEquipClothes].equipId)
		else
			self:ReleaseFashion(self._fashion, eEquipClothes)
			self:CreateFashion(self._fashion, eEquipClothes)
		end
	end
end

function i3k_hero:AttachHeirhoomEquip()
	local scfg = i3k_db_skins[g_i3k_game_context:getHeirloomSkinID(self._cfg.id)]
	if scfg then
		local name = string.format("hero_skin_%s_%d", self._guid, 1)
		self._entity:AttachHosterSkin(scfg.path, name, not self._syncCreateRes)
		self:AttachSkinEffect(1, scfg.effectID)
	end
end

function i3k_hero:DttachHeirhoomEquip()
	local scfg = i3k_db_skins[g_i3k_game_context:getHeirloomSkinID(self._cfg.id)]
	if scfg then
		local name = string.format("hero_skin_%s_%d", self._guid, 1)
		self._entity:DetachHosterSkin(name)
	end
end

--飞升副本完成设置状态为1，即播飞升完成动作状态
function i3k_hero:setPlayActionState(state)
	self._playActState = state
end

function i3k_hero:setdynamicfindwayflag(value)
	self._dynamicfindwayflag = value
end

function i3k_hero:getdynamicfindwayflag()
	return self._dynamicfindwayflag
end
function i3k_hero:changMovingSpeedHander()
	self._moveChanged = true
	self:TryMove()
end
--添加驭灵技能
function i3k_hero:bindCatchSpiritSkills()
	self._catchSpiritIndex = 1
	local cooltimes = { };
	local uniqueTime = nil;
	if self._catchSpiritSkills then
		for k, v in pairs(self._catchSpiritSkills) do
			if not v:CanUse() then
				cooltimes[v._id] = v._coolTick
			end
		end
	end
	if self._catchSpiritTrigger then
		for k, v in pairs(self._catchSpiritTrigger) do
			if not v:CanUse() then
				cooltimes[v._id] = v._coolTick
			end
		end
	end
	self._catchSpiritSkills = {}
	self._catchSpiritTrigger = {}
	for k, v in ipairs(i3k_db_catch_spirit_skills[self._id].baseSkills) do
		local scfg = i3k_db_skills[v];
		if scfg then
			--self:CreateGameInstanceSkill(v, 1, cooltimes[v] or 0)
			local skill = require("logic/battle/i3k_skill");
			if skill then
				local _skill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
				if cooltimes[v] then
					_skill:CalculationCoolTime(cooltimes[v]);
				end
				if _skill then
					_skill._gameInstanceSkillId = v
					table.insert(self._catchSpiritSkills, _skill)
					self._gameInstanceSkills[v] = _skill
				end
			end
		end
	end
	for k, v in ipairs(i3k_db_catch_spirit_skills[self._id].triggerSkills) do
		local scfg = i3k_db_skills[v];
		if scfg then
			--self:CreateGameInstanceSkill(v, 1, cooltimes[v] or 0)
			local skill = require("logic/battle/i3k_skill");
			if skill then
				local _skill = skill.i3k_skill_create(self, scfg, 1, 0, skill.eSG_Skill);
				if cooltimes[v] then
					_skill:CalculationCoolTime(cooltimes[v]);
				end
				if _skill then
					_skill._gameInstanceSkillId = v
					table.insert(self._catchSpiritTrigger, _skill)
					self._gameInstanceSkills[v] = _skill
				end
			end
		end
	end
end

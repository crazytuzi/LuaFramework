------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_monster").i3k_monster_base;

------------------------------------------------------
i3k_mercenary = i3k_class("i3k_mercenary", BASE);
function i3k_mercenary:ctor(guid)
	self._entityType	= eET_Mercenary;
	self._hoster		= nil;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._deadTimeLine	= -1;
end

function i3k_mercenary:Create(id, level, slevel, agent)
	local cfgID = math.abs(id)
	local cfg = i3k_db_mercenaries[cfgID];
	if not cfg then
		return false;
	end
	local skills = { };
	if cfg.skills then
		for k, v in ipairs(cfg.skills) do
			skills[v] = { id = v, lvl = slevel[k] or 0 };
		end
	end
	local petName = g_i3k_game_context:getPetName(id)
	local name = petName ~= "" and petName or cfg.name
	return self:CreateFromCfg(id, name, cfg, level, skills, agent);
end

function i3k_mercenary:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("mercenary_title_node_" .. self._guid) then
		title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), self._name);
		title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
	else
		title.node = nil;
	end

	return title;
end

-- 宠物赛跑
function i3k_mercenary:CreatePetRaceRes(id, modelID)
	self._id = id
	self:EnableOccluder(true);
	self:CreateRes(modelID)
end
function i3k_mercenary:PlayPetRaceRoadStartActions()
    local alist = {}
    table.insert(alist, {actionName = "start", actloopTimes = 1})
    table.insert(alist, {actionName = i3k_db_common.engine.defaultStandAction, actloopTimes = -1})
	self:PlayActionList(alist, 1);
end
function i3k_mercenary:PlayPetRaceRoadEndActions()
    local alist = {}
    table.insert(alist, {actionName = "finish", actloopTimes = 1})
    table.insert(alist, {actionName = i3k_db_common.engine.defaultStandAction, actloopTimes = -1})
	self:PlayActionList(alist, 1);
end


function i3k_mercenary:OnInitBaseProperty(props)
	local properties = BASE.OnInitBaseProperty(self, props);
	if self._hoster then
		local _lvl = self._lvl - 1;
		local allData,PlayData,OtherData = g_i3k_game_context:GetYongbingData()
		local upstarCfg = i3k_db_suicong_upstar[self._id]
		local starlvl = allData[self._id].starlvl
		local xinfaIncrease = upstarCfg[starlvl].xinfaIncrease
		local weaponIncrease = upstarCfg[starlvl].weaponIncrease
		local Increase = upstarCfg[starlvl].hurtIncrease
		local Decrease = upstarCfg[starlvl].hurtAvoid
		for i,v in ipairs(allData[self._id].breakSkill) do
			local skilllvl = allData[self._id].breakSkill[i]
			if skilllvl >0 then
				local skill = i3k_db_suicong_breakdata[i][skilllvl]
				if skill.skillType == 1 then
					Increase = Increase + skill.increaseCount
				elseif skill.skillType == 2 then
					Decrease = Decrease + skill.increaseCount
				elseif skill.skillType == 3 then
					xinfaIncrease = xinfaIncrease + skill.increaseCount
				elseif skill.skillType == 4 then
					weaponIncrease = weaponIncrease + skill.increaseCount
				end
			end
		end

		local all_atkC = self._hoster:GetPropertyValue(ePropID_atkC) * (self._cfg.atkCOrg + xinfaIncrease);
		local all_defC = self._hoster:GetPropertyValue(ePropID_defC) * (self._cfg.atkCOrg + xinfaIncrease);
		local all_atkW = self._hoster:GetPropertyValue(ePropID_atkW) * (self._cfg.atkWOrg + weaponIncrease);
		local all_defW = self._hoster:GetPropertyValue(ePropID_defW) * (self._cfg.atkWOrg + weaponIncrease);

		properties[ePropID_atkC]:Set(all_atkC, ePropType_Base);
		properties[ePropID_defC]:Set(all_defC, ePropType_Base);
		properties[ePropID_atkW]:Set(all_atkW, ePropType_Base);
		properties[ePropID_defW]:Set(all_defW, ePropType_Base);
		properties[ePropID_mercenarydmgTo]:Set(Increase, ePropType_Base);
		properties[ePropID_mercenarydmgBy]:Set(Decrease, ePropType_Base);
	end

	return properties;
end

function i3k_mercenary:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	if not self._hoster or self._hoster:IsDead() then
		return false;
	end

	local dist = i3k_vec3_len(i3k_vec3_sub1(self._curPos, self._hoster._curPos));
	local maxdist = self._cfg.followdist1
	local mindist = self._cfg.followdist2
	if not maxdist then
		maxdist = 1600
	end
	if not mindist then
		mindist = 800
	end
	local mapType = i3k_game_get_map_type()
	if mapType==g_ARENA_SOLO or mapType==g_TAOIST or mapType == g_QIECUO then
		maxdist = 160000
	end
	if dist > maxdist then
		self:ClsEnmities();
		self:SetTarget(nil);
		self._forceFollow = self._hoster;
		local world = i3k_game_get_world()
		local mapId = world._cfg.id
		if dist > 2500 and i3k_db_new_dungeon[mapId] and i3k_db_new_dungeon[mapId].openType == 0 then
			local followdist3 = self._cfg.followdist3 and self._cfg.followdist3 or 400
			local pos = {x = 0, y = 0, z =0}
			pos.x = self._hoster._curPos.x + i3k_engine_get_rnd_f(1, followdist3)
			pos.y = self._hoster._curPos.y
			pos.z = self._hoster._curPos.z + i3k_engine_get_rnd_f(1, followdist3)
			pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_vec3(pos.x, pos.y, pos.z)));
			self:SetPos(pos)
		end
	else
		if self._forceFollow and dist < mindist then
			self._forceFollow = nil;
		end
	end


	return true;
end

function i3k_mercenary:Bind(hero)
	self._hoster = hero;
	if self._hoster and not self._hoster:IsDead() then
		if self._id > 0 then --大于0表示自己的佣兵，小于借的佣兵（主要是宗门）
			local _lvl = self._lvl - 1;
			local allData,PlayData,OtherData = g_i3k_game_context:GetYongbingData()
			local upstarCfg = i3k_db_suicong_upstar[self._id]
			local starlvl = allData[self._id] and allData[self._id].starlvl or 1
			local xinfaIncrease = upstarCfg[starlvl].xinfaIncrease
			local weaponIncrease = upstarCfg[starlvl].weaponIncrease
			local Increase = upstarCfg[starlvl].hurtIncrease
			local Decrease = upstarCfg[starlvl].hurtAvoid
			local spirits = g_i3k_game_context:getPetSpiritsData(self._id)
			local cfg = self._cfg;
			if g_i3k_game_context:getPetIsWaken(self._id) then
				cfg = i3k_db_mercenariea_waken_property[self._id];
				self._awaken = g_i3k_game_context:getPetWakenUse(self._id) and 1 or 0
			else
				self._awaken = 0
			end
			for _,v in ipairs(spirits) do
				if v.id ~= 0 then
					local proId, proValue = g_i3k_game_context:GetMercenarySpirits(self._id, v.id, v.level, 1)
					if proId then
						local propertyValue = self:GetPropertyValue(proId) + proValue;
						self._properties[proId]:Set(propertyValue, ePropType_Base);
					end
				end
			end
			if g_i3k_game_context:getIsCompletePetLifeTaskFromID(self._id) then
				local propertyID,propertyCount = g_i3k_game_context:getHexiuProperty(self._id)
				for i=1, #propertyID do
					if propertyID[i] ~= 0 then
						if self._properties[propertyID[i]] then
							if g_i3k_game_context:getPetStarLvl(self._id) == #i3k_db_suicong_upstar[self._id] then
								propertyCount[i] = propertyCount[i] * (i3k_db_common.petBackfit.upCount/10000 + 1)
							end
							if g_i3k_game_context:getPetIsWaken(self._id) then
								propertyCount[i] = propertyCount[i] * (i3k_db_mercenariea_waken_property[self._id].upArg/10000 + 1)
							end
							local propertyValue = self:GetPropertyValue(propertyID[i]) + propertyCount[i];
							self._properties[propertyID[i]]:Set(propertyValue, ePropType_Base);
						end
					end
				end
			end

			--计算宠物装备属性
			local petEquip = g_i3k_game_context:GetPetEquipProps(self._id)
			for proId, proValue in pairs(petEquip) do
				local propertyValue = self:GetPropertyValue(proId) + proValue;
				self._properties[proId]:Set(propertyValue, ePropType_Base);
			end

			for i=1,4 do
				local skilllvl = allData[self._id] and allData[self._id].breakSkill[i] or 0
				if skilllvl >0 then
					local skill = i3k_db_suicong_breakdata[i][skilllvl]
					if skill.skillType == 1 then
						Increase = Increase + skill.increaseCount
					elseif skill.skillType == 2 then
						Decrease = Decrease + skill.increaseCount
					elseif skill.skillType == 3 then
						xinfaIncrease = xinfaIncrease + skill.increaseCount
					elseif skill.skillType == 4 then
						weaponIncrease = weaponIncrease + skill.increaseCount
					end
				end
			end
			local all_atkC = 0;
			if self._hoster then
				all_atkC = self._hoster:GetPropertyValue(ePropID_atkC) * (cfg.atkCOrg + xinfaIncrease);
			end

			local all_defC = 0;
			if self._hoster then
				all_defC = self._hoster:GetPropertyValue(ePropID_defC) * (cfg.atkCOrg + xinfaIncrease);
			end

			local all_atkW = 0;
			if self._hoster then
				all_atkW = self._hoster:GetPropertyValue(ePropID_atkW) * (cfg.atkWOrg + weaponIncrease);
			end

			local all_defW = 0;
			if self._hoster then
				all_defW = self._hoster:GetPropertyValue(ePropID_defW) * (cfg.atkWOrg + weaponIncrease);
			end

			self._properties[ePropID_atkC]:Set(all_atkC, ePropType_Base);
			self._properties[ePropID_defC]:Set(all_defC, ePropType_Base);
			self._properties[ePropID_atkW]:Set(all_atkW, ePropType_Base);
			self._properties[ePropID_defW]:Set(all_defW, ePropType_Base);
			self._properties[ePropID_mercenarydmgTo]:Set(Increase, ePropType_Base);
			self._properties[ePropID_mercenarydmgBy]:Set(Decrease, ePropType_Base);
		else
			local id = math.abs(self._id)
			local _lvl = self._lvl - 1;
			local cfgData = g_i3k_game_context:GetFightMercenaryData()
			local upstarCfg = i3k_db_suicong_upstar[id]
			local starlvl = cfgData[self._id].star
			local xinfaIncrease = upstarCfg[starlvl].xinfaIncrease
			local weaponIncrease = upstarCfg[starlvl].weaponIncrease
			local Increase = upstarCfg[starlvl].hurtIncrease
			local Decrease = upstarCfg[starlvl].hurtAvoid
			for i=1,4 do
				local skilllvl = cfgData[self._id].breakSkills[i] or 0
				if skilllvl >0 then
					local skill = i3k_db_suicong_breakdata[i][skilllvl]
					if skill.skillType == 1 then
						Increase = Increase + skill.increaseCount
					elseif skill.skillType == 2 then
						Decrease = Decrease + skill.increaseCount
					elseif skill.skillType == 3 then
						xinfaIncrease = xinfaIncrease + skill.increaseCount
					elseif skill.skillType == 4 then
						weaponIncrease = weaponIncrease + skill.increaseCount
					end
				end
			end
			local hostercfgData = g_i3k_game_context:GetFightMercenaryHostData()
			local all_atkC = 0;
			if hostercfgData then
				all_atkC = hostercfgData.hostAtkc * (cfg.atkCOrg + xinfaIncrease);
			end

			local all_defC = 0;
			if hostercfgData then
				all_defC = hostercfgData.hostDefc * (cfg.atkCOrg + xinfaIncrease);
			end

			local all_atkW = 0;
			if hostercfgData then
				all_atkW = hostercfgData.hostAtkw * (cfg.atkWOrg + weaponIncrease);
			end

			local all_defW = 0;
			if hostercfgData then
				all_defW = hostercfgData.hostDefw * (cfg.atkWOrg + weaponIncrease);
			end
			
			self._properties[ePropID_atkC]:Set(all_atkC, ePropType_Base);
			self._properties[ePropID_defC]:Set(all_defC, ePropType_Base);
			self._properties[ePropID_atkW]:Set(all_atkW, ePropType_Base);
			self._properties[ePropID_defW]:Set(all_defW, ePropType_Base);
			self._properties[ePropID_mercenarydmgTo]:Set(Increase, ePropType_Base);
			self._properties[ePropID_mercenarydmgBy]:Set(Decrease, ePropType_Base);
		end
	else
		--self:OnDead();
	end
	self._hp = self:GetPropertyValue(ePropID_maxHP);
	self:addTriggerEffect()
	if g_i3k_game_context:GetPetGuardIsShow() then
		self:AttachPetGuard(g_i3k_game_context:GetCurPetGuard())
	end
end

function i3k_mercenary:GetHoster()
	return self._hoster;
end

function i3k_mercenary:GetFollowTarget()

	local target = BASE.GetFollowTarget(self);
	if target then
		return target;
	end

	if #self._enmities > 0 then
		--i3k_log("GetFollowTarget2")
		return nil;
	end

	if not self._hoster or self._hoster:IsDead() then
		return nil;
	end

	if self._forceFollow then
		return self._forceFollow;
	end

	local dist = i3k_vec3_len(i3k_vec3_sub1(self._curPos, self._hoster._curPos));
	local mindist = 500
	if self._cfg.followdist2 and self._cfg.followdist3 then
		mindist = (self._cfg.followdist2 + self._cfg.followdist3)/2
	end
	if not mindist then
		mindist = 500
	end

	if dist > mindist then
		return self._hoster;
	end

	return nil;
end

function i3k_mercenary:OnSelected(val)
	BASE.OnSelected(self, val);
	if self:GetEntityType() == eET_Mercenary then
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
		g_i3k_game_context:OnSelectMercenaryHandler(self._cfg.id, self._lvl, self._cfg.name, curhp, maxhp, buffs)
	end
end

function i3k_mercenary:UltraSkill()
	if self._ultraSkill and self._ultraSkill:CanUse() then
		self._skilldeny = 0;
		if not self:CanUseSkill() then
			self._behavior:Clear(eEBAttack);
			self._behavior:Clear(eEBDisAttack);
		end

		if self:CanUseSkill() then
			self._maunalSkill = self._ultraSkill;

			self:UpdateProperty(ePropID_sp, 1, self:GetPropertyValue(ePropID_maxSP) * -1, false, false);

			return true;
		end
	end

	return false;
end

function i3k_mercenary:Birth(pos)
	self._birthPos = pos;

	self:SetPos(pos);
end
function i3k_mercenary:Appraise()
	local atkN	= self:GetPropertyValue(ePropID_atkN);
	local atkH	= self:GetPropertyValue(ePropID_atkH);
	local atkC	= self:GetPropertyValue(ePropID_atkC);
	local atkW	= self:GetPropertyValue(ePropID_atkW);
	local defN	= self:GetPropertyValue(ePropID_defN);
	local defC	= self:GetPropertyValue(ePropID_defC);
	local defW	= self:GetPropertyValue(ePropID_defW);
	local maxHP	= self:GetPropertyValue(ePropID_maxHP);
	local atr	= self:GetPropertyValue(	);
	local ctr	= self:GetPropertyValue(ePropID_ctr);
	local acrN	= self:GetPropertyValue(ePropID_acrN);
	local tou	= self:GetPropertyValue(ePropID_tou);
	local FIncrease	= self:GetPropertyValue(ePropID_mercenarydmgTo);
	local TDecrease	= self:GetPropertyValue(ePropID_mercenarydmgBy);
	local skill = self:AppraiseSkill()
	--i3k_log("FIncrease:%f,TDecrease:%f",FIncrease,TDecrease);
	return atkN + defN + 0.45 * (maxHP + atkH + atkC + defC + atkW + defW) + 2 * (atr + ctr + acrN + tou) + 138 * FIncrease + 438 * TDecrease + skill;
end

function i3k_mercenary:AppraiseSkill()

	--[[local allData,PlayData,OtherData = g_i3k_game_context:GetYongbingData()
	local power = 0
	for k,v in pairs(allData) do
		if v then
			local cfg = i3k_db_skill_datas[v.id][v.lvl]
			if cfg then
				power = power + cfg.skillpower
				power = power + cfg.skillrealpower[v.state+1]
			end
		end
	end
	return power;]]
	return 0;
end

function i3k_mercenary:addTriggerEffect()
	if not self._hoster then
		return
	end
	if i3k_game_get_map_type() ~= g_BASE_DUNGEON then
		return
	end
	self:ClearTriggerEffect(self._cfg.id)
	local spirits = g_i3k_game_context:getPetSpiritsData(self._cfg.id)
	for _,v in ipairs(spirits) do
		if v.id ~= 0 then
			local effectID = g_i3k_game_context:GetMercenarySpirits(self._cfg.id, v.id, v.level, 4)
			if effectID then
				local tgcfg =  i3k_db_ai_trigger[effectID]
				local mgr = self._triMgr
				if mgr then
					local TRI = require("logic/entity/ai/i3k_trigger");
					local tri = TRI.i3k_ai_trigger.new(self);
					if tri:Create(tgcfg,-1,effectID) then
						local tid = mgr:RegTrigger(tri, self);
						if tid >= 0 then
							if not self._petTids[self._cfg.id] then
								self._petTids[self._cfg.id] = {}
							end
							table.insert(self._petTids[self._cfg.id], tid);
						end
					end
				end
			end
		end
	end
end

function i3k_mercenary:ClearTriggerEffect(petID)
	if self._petTids[petID] then
		if self._triMgr then
			for k, v in ipairs(self._petTids[petID]) do
				self._triMgr:UnregTrigger(v);
			end
		end
		self._petTids = {};
	end
end

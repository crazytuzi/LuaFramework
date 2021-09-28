----------------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_global");
require("logic/battle/i3k_skill_def");
require("logic/battle/i3k_skill_vfx");
require("logic/battle/i3k_skill_special_func");


-----------------------------------------------------------------
i3k_skill_base = i3k_class("i3k_skill_base");
function i3k_skill_base:ctor(entity, cfg, lvl, realm, gtype)
	self._entity		= entity;
	self._cfg			= cfg;
	self._lvl			= lvl;
	self._gtype			= gtype or eSG_Attack;
	self._etype			= cfg.type;
	-- self._ttype		= cfg.triType;
	self._auraCamp 		= cfg.auraCamp;
	self._realm			= realm;
	self._itemSkillId	= 0;
	self._gameInstanceSkillId = 0;
	self._tournamentSkillID = 0;
	self._anqiSkillID = 0;
	self._isRunNow		 = cfg.isRunNow == 1
	self._weaponManualId = 0 --神兵类型19手动特技
end


-----------------------------------------------------------------
i3k_passive_skill = i3k_class("i3k_passive_skill", i3k_skill_base);
function i3k_passive_skill:ctor(entity, cfg, lvl, realm, gtype)
end


-----------------------------------------------------------------
i3k_skill = i3k_class("i3k_skill", i3k_skill_base);
function i3k_skill:ctor(entity, cfg, lvl, realm, gtype)
	local realnvalue = realm
	local datas = i3k_db_skill_datas[cfg.id];
	if datas then
		self._data = datas[lvl];
		if not self._data then
			self._data = datas[1];
		end

		-- only for DIYSkill
		if cfg.id == SKILL_DIY and entity:GetEntityType() == eET_Player then
			self:CreDiySkill(entity, cfg);
		end
	end

	self._id		= cfg.id;
	self._level		= lvl;
	self._canUse	= true;
	self._cool		= self._data.cool;
	self._coolTick	= self._cool;
	self._coolWhenSpell
					= cfg.coolWhenSpell == 1;
	self._scope		= cfg.scope;
	self._range		= 0;
	self._specialArgs
					= cfg.specialArgs;
	self._ignoreAct	= false;
	self._changeTick = 0
	self._duration	= cfg.duration;
	self._canAttack	= cfg.canAttack == 1;
	self._canBreak	= cfg.forceBreak == 1;
	self._warnEff	= cfg.warnEffectID;
	self._warnTime	= cfg.warnTime;
	self._spA		= self._data.additionalDamage;

	--家园保卫战公cd字段
	self._shareTotalCool = nil

	local scope = cfg.scope;
	if scope.type == eSScopT_Owner then
	elseif scope.type == eSScopT_Single then
		self._range = scope.arg1;
	elseif scope.type == eSScopT_CricleO then
		self._range = scope.arg1;
	elseif scope.type == eSScopT_CricleT then
		self._range = scope.arg1 + scope.arg2;
	elseif scope.type == eSScopT_SectorO then
		self._range = scope.arg1;
	elseif scope.type == eSScopT_RectO then
		self._range = scope.arg1;
	elseif scope.type == eSScopT_MulC then
		self._range = i3k_integer((scope.arg1 + scope.arg2) * 0.5);
	elseif scope.type == eSScopT_Ellipse then
		self._range = scope.arg1;
	end
	self._range = math.max(50, self._range - cfg.maxDistance);

	-- skill vfx
	self._vfxStage = -1;
	self._vfx = { };
	for k = 1, #cfg.specialVFX do
		local vfxID = cfg.specialVFX[k];
		if vfxID > 0 then
			local vfx = i3k_skill_vfx.new();
			if not vfx:Create(vfxID) then
				vfx = nil;
			end

			if vfx then
				self._ignoreAct = vfx._ignoreAct;

				if not self._vfx[vfx._stage] then
					self._vfx[vfx._stage] = { };
				end
				table.insert(self._vfx[vfx._stage], vfx);
			end
		end
	end

	if cfg.linkrealmSkill > 0 then
		if entity._validSkills and entity._validSkills[cfg.linkrealmSkill] then
			self._realm = entity._validSkills[cfg.linkrealmSkill].state
			realnvalue = entity._validSkills[cfg.linkrealmSkill].state
		end
	end

	self._child_skill = { };
	for k, v in ipairs(cfg.childs) do
		local scfg = i3k_db_skills[v];
		if scfg then
			table.insert(self._child_skill, i3k_skill_create(entity, scfg, lvl, realnvalue, gtype));
		end
	end

	self._seq_skill = { valid = false, skills = { }, idx = 1 };
	for k, v in ipairs(cfg.sequences) do
		local scfg = i3k_db_skills[v];
		if scfg then
			local skill = i3k_skill_create(entity, scfg, lvl, realnvalue, gtype);
			if skill then
				self._seq_skill.valid = true;
				table.insert(self._seq_skill.skills, skill);
			end
		end
	end

	--拳师技能额外参数
	self._qs_skillAddData = {}
	if i3k_db_skills[cfg.id] and i3k_db_skills[cfg.id].skillAddData then
		for k, v in ipairs(i3k_db_skills[cfg.id].skillAddData) do
			table.insert(self._qs_skillAddData, v)
		end
	end
end

function i3k_skill:CreDiySkill(entity, cfg)
	if entity:IsPlayer() then
		local kfcfg = g_i3k_game_context:getCreateKungfuData()
		local Skillcfg = kfcfg[g_i3k_game_context:getCurrentSkillID()]
		local DIYSkillData = Skillcfg.diySkillData
		local DIYcfg = i3k_db_skills[9999999];
		local showcfg = i3k_db_create_kungfu_showargs_new[cfg.basecfg.id]
		--自己技能创建
		self._data.addSP = DIYSkillData.addSP
		self._data.cool = DIYSkillData.cd
		for i = 1 ,DIYSkillData.damageTimes do
			self._data.events[i].hitEffID = showcfg.hitEffect
			self._data.events[i].useEffID = 0
			self._data.events[i].triTime = showcfg.triTime[i]
			self._data.events[i].damage.atrType = 0
			self._data.events[i].damage.atrDes = DIYSkillData.atrDecrease
			self._data.events[i].damage.acrType = 0
			self._data.events[i].damage.acrDes = DIYSkillData.acrDecrease
			self._data.events[i].damage.odds = 10000
			self._data.events[i].damage.arg1 = DIYSkillData.damageArgs[1]  --------伤害乘数
			self._data.events[i].damage.arg2 = DIYSkillData.damageArgs[2]  --------伤害加数
			if i == DIYSkillData.damageTimes then
				if DIYSkillData.buffs then
					if DIYSkillData.buffs[1] then
						self._data.events[i].status[1].buffID = DIYSkillData.buffs[1].status.buffID
						self._data.events[i].status[1].odds = DIYSkillData.buffs[1].status.odds
						self._data.events[i].status[1].affectValue = DIYSkillData.buffs[1].affectValue
						self._data.events[i].status[1].loopTime = DIYSkillData.buffs[1].loopTime
					end
					if DIYSkillData.buffs[2] then
						self._data.events[i].status[2].buffID = DIYSkillData.buffs[2].status.buffID
						self._data.events[i].status[2].odds = DIYSkillData.buffs[2].status.odds
						self._data.events[i].status[2].affectValue = DIYSkillData.buffs[2].affectValue
						self._data.events[i].status[2].loopTime = DIYSkillData.buffs[2].loopTime
					end
				end
			end
		end
	else
		if entity._DIYSkillID ~= 0 then
			local DIYcfg = i3k_db_skills[9999999];
			local showcfg = i3k_db_create_kungfu_showargs_new[entity._DIYSkillID]
			--其他人技能创建
			self._data.addSP = 0
			self._data.cool = 0
			for i = 1 ,3 do
				self._data.events[i].hitEffID = showcfg.hitEffect
				self._data.events[i].useEffID = 0
				self._data.events[i].triTime = showcfg.triTime[i]
				self._data.events[i].damage.atrType = 0
				self._data.events[i].damage.atrDes = 0
				self._data.events[i].damage.acrType = 0
				self._data.events[i].damage.acrDes = 0
				self._data.events[i].damage.odds = 10000
				self._data.events[i].damage.arg1 = 0  --------伤害乘数
				self._data.events[i].damage.arg2 = 0  --------伤害加数
				self._data.events[i].status[1].buffID = 0
				self._data.events[i].status[1].odds = 0
				self._data.events[i].status[2].buffID = 0
				self._data.events[i].status[2].odds = 0
			end
		end
	end
end

function i3k_skill:TalentSkillChange(entity,tritype,changetype,event,status)
	local talentNum = 0
	---------心法改变
	local hero = i3k_game_get_player_hero()
	if hero and entity._guid == hero._guid  then
		if entity._talentChangeSkill[self._id] then
			for k1,v1 in pairs(entity._talentChangeSkill[self._id]) do
				for k,v in pairs(v1) do
					talentNum = talentNum + self:ChangeTalentType(v, tritype, changetype, event, status);
				end
			end
		end
		if entity._horseChangeSkill[self._id] then
			for k,v in pairs(entity._horseChangeSkill[self._id]) do
				talentNum = talentNum + self:ChangeTalentType(v, tritype, changetype, event, status);
			end
		end

		return talentNum;
	end
	return 0;
end

function i3k_skill:ChangeTalentType(talent, tritype, changetype, event, status)
	if talent.Commonchangetype and eSCType_Common == tritype then
		if talent.Commonchangetype == eSCCommon_time and changetype == eSCCommon_time then
			return self:TalentSkillChangevalue(talent.valuetype,self._duration,talent.value)
		elseif talent.Commonchangetype == eSCCommon_cooltime and changetype == eSCCommon_cooltime then
			return self:TalentSkillChangevalue(talent.valuetype,self._cool,talent.value)
		elseif talent.Commonchangetype == eSCCommon_rushdist and changetype == eSCCommon_rushdist then
			return self:TalentSkillChangevalue(talent.valuetype,self._specialArgs.rushInfo.distance,talent.value)
		elseif talent.Commonchangetype == eSCCommon_shiftodds and changetype == eSCCommon_shiftodds then
			return self:TalentSkillChangevalue(talent.valuetype,self._specialArgs.shiftInfo.odds,talent.value)
		elseif talent.Commonchangetype == eSCCommon_casttime and changetype == eSCCommon_casttime then
			return self:TalentSkillChangevalue(talent.valuetype,self._specialArgs.castInfo.duration,talent.value)
		elseif talent.Commonchangetype == eSCCommon_auratime and changetype == eSCCommon_auratime then
			return self:TalentSkillChangevalue(talent.valuetype,self._specialArgs.auraInfo.duration,talent.value)
		elseif talent.Commonchangetype == eSCCommon_movespeed and changetype == eSCCommon_movespeed then
			return self:TalentSkillChangevalue(talent.valuetype,self._specialArgs.summonInfo.movespeed,talent.value)
		end
	elseif talent.Eventchangetype and eSCType_Event == tritype then
		if event == talent.eventid then
			if status then
				if status == 1 then
					changetype = eSCEvent_sodds1
				elseif status == 2 then
					changetype = eSCEvent_sodds2
				end
			end
			if talent.Eventchangetype == eSCEvent_time and changetype == eSCEvent_time then
				return self:TalentSkillChangevalue(talent.valuetype,self._data.events[talent.eventid].triTime,talent.value)
			elseif talent.Eventchangetype == eSCEvent_odds and changetype == eSCEvent_odds then
				return self:TalentSkillChangevalue(talent.valuetype,self._data.events[talent.eventid].damage.odds,talent.value)
			elseif talent.Eventchangetype == eSCEvent_arg1 and changetype == eSCEvent_arg1 then
				return self:TalentSkillChangevalue(talent.valuetype,self._data.events[talent.eventid].damage.arg1,talent.value/10000)
			elseif talent.Eventchangetype == eSCEvent_arg2 and changetype == eSCEvent_arg2 then
				return self:TalentSkillChangevalue(talent.valuetype,self._data.events[talent.eventid].damage.arg2,talent.value)
			elseif talent.Eventchangetype == eSCEvent_sodds1 and changetype == eSCEvent_sodds1 then
				return self:TalentSkillChangevalue(talent.valuetype,self._data.events[talent.eventid].status[1].odds,talent.value)
			elseif talent.Eventchangetype == eSCEvent_sodds2 and changetype == eSCEvent_sodds2 then
				return self:TalentSkillChangevalue(talent.valuetype,self._data.events[talent.eventid].status[2].odds,talent.value)
			end
		end
	end

	return 0;
end

function i3k_skill:ChangeSkillTick(changeTick)
	self._changeTick = changeTick
end

function i3k_skill:GetTotalCool()
	--如果有公CD，直接返回公CD
	if self._shareTotalCool then
		return self._shareTotalCool
	end

	local totalTime = 0
	
 	if self._entity and self._entity:isCanReduceCd() then
		totalTime = (self._cool + self:TalentSkillChange(self._entity, eSCType_Common, eSCCommon_cooltime) - self._changeTick) * (1 - self._entity:isCanReduceCd());
	else
		totalTime = (self._cool + self:TalentSkillChange(self._entity, eSCType_Common, eSCCommon_cooltime) - self._changeTick);
	end
	
	if self._anqiSkillID ~= 0 then
		totalTime = totalTime + self._entity:reduceAnqiPassiveSkillEffect(self._id, totalTime)
	end
	
	return totalTime
end

function i3k_skill:GetCoolTime()
	return self:GetTotalCool(), self._coolTick
end

--shareTotalCool 为公CD的值
function i3k_skill:CalculationCoolTime(coolTick, reconnect, shareTotalCool)
	if coolTick and coolTick ~= nil  then
		local totalTime = shareTotalCool or self:GetTotalCool()
		self._canUse = false;
		if reconnect and reconnect ~= nil then
			self._coolTick = totalTime - coolTick
		else
			self._coolTick = math.max(0, coolTick)
		end
		if self._coolTick >= totalTime then
			self._canUse	= true;
			self._coolTick	= 0;
		end
	end
end

function i3k_skill:TalentSkillChangevalue(type,arg1,arg2)
	if type == eSCValueType_add then
		return arg2
	elseif type == eSCValueType_mul then
		return arg1*arg2/100 - arg1
	elseif type == eSCValueType_instead then
		return arg2 - arg1
	end
	return arg1
end

function i3k_skill:IsSequenceSkill()
	return self._seq_skill.valid;
end

function i3k_skill:GetSequenceSkill()
	if self._seq_skill.valid then
		return self._seq_skill.skills[self._seq_skill.idx];
	end

	return nil;
end

function i3k_skill:GetSequenceIdx()
	if self._seq_skill.valid then
		return self._seq_skill.idx;
	end

	return -1;
end

function i3k_skill:NextSequence()
	if self._seq_skill.valid then
		self._seq_skill.idx = self._seq_skill.idx + 1;
	end
end

function i3k_skill:GetBuffIDByIdx(idx)
	local eid = i3k_integer((idx - 1) / 2) + 1;
	local sid = idx - (eid - 1) * 2;

	if self._data then
		return self._data.events[eid].status[sid].buffID;
	end

	return -1;
end

function i3k_skill:OnUpdate(dTime)
	if not self._canUse then
		self._coolTick = self._coolTick + dTime * 1000;
	end
end

function i3k_skill:OnLogic(dTick)
	if not self._canUse then
		if self._coolTick >= self:GetTotalCool() then
			self._canUse	= true;
			self._coolTick	= 0;
		end
	end

	self:OnLogicVFX(self._entity, dTick);
end

function i3k_skill:Use(step)
	local _step = eSStep_Unknown;
	if step then
		_step = step;
	end

	local reset = (self._coolWhenSpell and _step == eSStep_Spell) or (not self._coolWhenSpell and _step == eSStep_End) or (_step == eSStep_Unknown);
	if reset then
		if self._entity:IsPlayer() then
			g_i3k_game_context:OnSkillCastedHandler(self._id, self:GetCoolTime())
		end
		if self._entity:GetEntityType() ~= eET_Mercenary then
			self._canUse = false;
		end
		self._coolTick	= 0;
		if self._seq_skill.valid then
			self._seq_skill.idx = 1;
		end
	end
end

function i3k_skill:DesCoolTime(cooltime)
	if not self._canUse then
		self._coolTick = self._coolTick + cooltime
	end
end

function i3k_skill:CanUse()
	return self._canUse;
end

function i3k_skill:OnReset()
	if self._trigger then
		self._trigger:Reset();
	end
	self:ResetVFX();
	self._coolTick = 0;
	self._canUse = true;
end

function i3k_skill:IsTriggerSkill()
	if self._trigger then
		return self._trigger:Valid();
	end

	return false;
end

function i3k_skill:IsTriggerSkillSpec(ttype)
	if self._trigger then
		return self._trigger:Valid(ttype);
	end

	return false;
end

function i3k_skill:TryTrigger(tick, entity)
	if self._trigger and self._trigger:Valid() then
		return self._trigger:Try(tick, entity);
	end

	return false;
end

function i3k_skill:Trigger(tick)
	self._trigger:Finish(tick);
end

function i3k_skill:OnLogicVFX(dTick)
	local vfx = self._vfx[self._vfxStage];
	if vfx then
		for k, v in ipairs(vfx) do
			v:OnLogic(self._entity, dTick);
		end
	end
end

function i3k_skill:TriggerVFX(stage, target)
	if self._vfxStage ~= stage then
		local vfx = self._vfx[self._vfxStage];
		if vfx then
			for k, v in ipairs(vfx) do
				v:TriggerOff(self._entity);
			end
		end
		self._vfxStage = stage;

		vfx = self._vfx[stage];
		if vfx then
			for k, v in ipairs(vfx) do
				v:TriggerOn(self._entity, target);
			end
		end
	end
end

function i3k_skill:ResetVFX()
	for _, vfx in pairs(self._vfx) do
		for k, v in ipairs(vfx) do
			v:Reset(self._entity);
		end
	end
end

function i3k_skill:GetBaseDamage(atr, cri, entity, target, sdata, isCombo)
	local scfg = self._cfg;

	local f_lvl	= entity:GetPropertyValue(ePropID_lvl);
	local atkN	= entity:GetPropertyValue(ePropID_atkN);
	local atkA	= entity:GetPropertyValue(ePropID_atkA);
	local atkH	= entity:GetPropertyValue(ePropID_atkH);
	local atkC	= entity:GetPropertyValue(ePropID_atkC);
	local atkW	= entity:GetPropertyValue(ePropID_atkW);
	local atkD	= entity:GetPropertyValue(ePropID_atkD);
	local sbd	= entity:GetPropertyValue(ePropID_sbd);
	local heg	= entity:GetPropertyValue(ePropID_healGain);
	local entityIF	= entity:GetPropertyValue(ePropID_internalForces);
	local atkUp		= entity:GetPropertyValue(ePropID_attackUp)
	local ig_def	= entity:GetPropertyValue(ePropID_ignoreDef)
	local sf_Dam = entity:GetPropertyValue(ePropID_SteedFightDamage)

	local t_lvl	= target:GetPropertyValue(ePropID_lvl);
	local defN	= target:GetPropertyValue(ePropID_defN);
	local defA	= target:GetPropertyValue(ePropID_defA);
	local defC	= target:GetPropertyValue(ePropID_defC);
	local defW	= target:GetPropertyValue(ePropID_defW);
	local shell	= target:GetPropertyValue(ePropID_shell);
	local TargetIF	= target:GetPropertyValue(ePropID_internalForces);
	local BWtype =  g_i3k_game_context:GetTransformBWtype();
	local sf_Df = entity:GetPropertyValue(ePropID_SteedFightDefend)

	local isRemit = false
	local armor = {damage = 0, suck = 0, destroy = 0, weak = 0} --内甲伤害，吸收，损毁，虚弱

	local dmg1 = function(atr, cri, entity, target, sdata)
		local F1 = 1; -- 心法档次系数
		local F2 = 1; -- 神兵档次系数
		local arg1 = i3k_db_common.skill.atk.arg1;
		local arg2 = i3k_db_common.skill.atk.arg2;
		local arg3 = i3k_db_common.skill.atk.arg3;
		local damage1 = sdata.damage.arg1 + self:TalentSkillChange(entity,eSCType_Event,eSCEvent_arg1,sdata.damage.arg1)
		local damage2 = sdata.damage.arg2 + self:TalentSkillChange(entity,eSCType_Event,eSCEvent_arg2,sdata.damage.arg2)
		local damage3 = entityIF
		local damage4 = self:elementDamage(entity,target)
		if entityIF > TargetIF then
			local IFMaster = math.max(entity:GetPropertyValue(ePropID_internalForceMaster),0);
			damage3 = damage3 * (2 + IFMaster);
		end

		if self._gtype == eSG_Attack then
			damage1 = damage1 + atkUp
		end

		local rnd1 = i3k_engine_get_rnd_f(0, 1)
		if ig_def >= rnd1 then
			defN = 0
		end
		local outATK = math.max(0, atkN - defN) * damage1 * (1 + sdata.damage.realmAddon * self._realm) + damage2 * (1 + sdata.damage.realmAddon * self._realm) + atkH +  math.max(0, atkW - defW) * F2;
		outATK = outATK * (1 - target:GetPropertyValue(ePropID_OutATK));
		local withinATK = math.max(0, atkC - defC) * F1 + damage3 + (sf_Dam - sf_Df);
 		withinATK = withinATK * (1 - target:GetPropertyValue(ePropID_WithinATK));
		local elementATK = damage4
		elementATK = elementATK * (1 - target:GetPropertyValue(ePropID_ElementATK));
		local val = outATK + withinATK + elementATK;
		if atr == 2 then
			val = val * atkD;
		elseif cri then
			val = val * math.max(arg1, atkA - defA) * entity:GetDamageRetrive();
		else
			val = val * entity:GetDamageRetrive();
		end

		local TDecrease = target:GetPropertyValue(ePropID_mercenarydmgBy);
		local FIncrease = entity:GetPropertyValue(ePropID_mercenarydmgTo);

		if entity:GetEntityType() == eET_Monster then
			local damagecfg = i3k_db_monsters_damageodds[entity._cfg.race]
			local value = target:GetPropertyValue(damagecfg.damageDesProp)
			if value then
				TDecrease = TDecrease + value
			end
		end
		if target:GetEntityType() == eET_Monster then
			local damagecfg = i3k_db_monsters_damageodds[target._cfg.race]
			local value = entity:GetPropertyValue(damagecfg.damageIncProp)
			if value then
				FIncrease = FIncrease + value + g_i3k_db.i3k_db_get_xinjue_monster_damage_percent(target._id)
			end
		end

		val = val * (1 + FIncrease) * (1 - TDecrease);

		val = val * i3k_ss_func_damage_factor(entity, self._specialArgs.damageFactor);

		-- 根据属性，增加/减少伤害 (ai;eTBehaviorDecDmg,eTBehaviorAddDmg)
		local damageDes = target:GetDamageDes();
		if damageDes then
			val = val - damageDes;
		end
		local damageAdd = entity:GetDamageAddition();
		if damageAdd then
			val = val + damageAdd
		end

		return math.max(val, f_lvl * i3k_engine_get_rnd_f(arg2, arg3));
	end

	-- 治疗
	local dmg2 = function(atr, cri, entity, target, sdata)
		local woodD	= entity:GetPropertyValue(ePropID_WoodDamage);
		local val = sdata.damage.arg2 * (1 + sdata.damage.realmAddon * self._realm) + heg + woodD * i3k_db_common.element.woodArgs1;
		if cri then
			val = val * 2 * entity:GetDamageRetrive();
		else
			val = val * entity:GetDamageRetrive();
		end
		targetheg = target:GetPropertyValue(ePropID_behealGain)
		return val*(1+targetheg);
	end

	local val = 0;

	if scfg.type == eSE_Buff then
		val = dmg2(atr, cri, entity, target, sdata);
	else
		val = dmg1(atr, cri, entity, target, sdata);
	end
	-- 根据属性id追加伤害
	local valdmg = 0;
	if self._specialArgs and self._specialArgs.maxhpdmg and self._specialArgs.maxhpdmg.ratio then
		valdmg = entity:GetPropertyValue(self._specialArgs.maxhpdmg.propID) * (self._specialArgs.maxhpdmg.ratio / 10000);
	end
	val = valdmg + val;

	-- 连刺额外伤害
	local valCombo = 0;
	if isCombo then
		valCombo = entity:GetPropertyValue(ePropID_comboA);
	end
	val = valCombo + val;

	--按战斗能量附加伤害
	local valSp = 0;
	if self._spA and self._spA ~= 0 then
		local sp = entity:GetFightSp();
		if sp then
			valSp =  sp * self._spA;
		end
	end
	val = valSp + val;

	--刺客撕裂伤口A
	local dmgA = 0;
	if target._behavior:Test(eEBTearWoundA) then
		local valueA = target._behavior:GetValue(eEBTearWoundA)
		local arg1,arg2  = math.modf(tonumber(valueA.value) / 100);
		dmgA = arg2 * val;
		target._TearWoundA = target._TearWoundA + dmgA;
		if target._TearWoundA > arg1 then
			target._TearWoundA = 0;
			target:ClsBuffByBehavior(eEBTearWoundA);
		end
	end
	val = dmgA + val;

	--医神绝技
	local sbv_ext = 0;
	if self._specialArgs and self._specialArgs.dmgaddhp and self._specialArgs.dmgaddhp.ratio then
		local targetVal = target:GetPropertyValue(ePropID_maxHP);
		if atr then
			sdata.damage.acrType = 1
		end
		if val > targetVal then
			sbv_ext = targetVal * (self._specialArgs.dmgaddhp.ratio / 10000);
		else
			sbv_ext = val * (self._specialArgs.dmgaddhp.ratio / 10000);
		end
	end

	--拳师技能额外参数回复气血
	local qs_addHp = 0
	local hero = i3k_game_get_player_hero()
	if hero._combatType > 0 then
		for _,id in ipairs(self._qs_skillAddData) do
			local data = i3k_db_skill_AddData[id]
			if data.type == g_BOXER_ADD_UP_HP and data.combatType == hero._combatType then
				qs_addHp = val * data.arg1 / 10000
			end
		end
	end

	-- 吸血
	local sbv = 0;
	if scfg.type == eSE_Damage and self._gtype ~= eSG_Attack then
		local arg1 = i3k_db_common.skill.sbd.arg1;
		local arg2 = i3k_db_common.skill.sbd.arg2;

		local F1 = arg1 * t_lvl + arg2;
		sbv = val * (sbd / F1);
		if BWtype == 2 and entity:GetEntityType() == eET_Player then
			sbv = sbv + entity:GetPropertyValue(ePropID_CampMaster);
		end
		if sbv > entity:GetPropertyValue(ePropID_maxHP) * 0.25 then
			sbv = entity:GetPropertyValue(ePropID_maxHP) * 0.25;
		end
		if target:GetEntityType() == eET_Trap or target:GetEntityType() == eET_Pet then
			sbv = 0
		end
	end
	 sbv = sbv + sbv_ext + qs_addHp;
	-- 护体
	if scfg.type == eSE_Damage and self._gtype ~= eSG_Attack then
		local arg1 = i3k_db_common.skill.shell.arg1;
		local arg2 = i3k_db_common.skill.shell.arg2;
		if BWtype == 1 and target:GetEntityType() == eET_Player then
			shell = shell + target:GetPropertyValue(ePropID_CampMaster);
		end
		local F1 = arg1 * f_lvl + arg2;
		local val1 = val * (shell / F1);
		if val1 > target:GetPropertyValue(ePropID_maxHP) * 0.25 then
			val1 = target:GetPropertyValue(ePropID_maxHP) * 0.25;
		end

		val = val - val1;
	end

	-- 吸收
	if scfg.type == eSE_Damage then
		if target:GetEntityType() == eET_Trap or target:GetEntityType() == eET_Pet then
			if cri then
				val = 2
			else
				val = 1
			end
		end
		local reduce, val1 = self:Reduction(target, val);
		if reduce then
			return { valid = true, value = i3k_integer(math.max(0, val - val1)) }, i3k_integer(math.max(0, val1)), i3k_integer(sbv);
		end
	end

	isRemit = self:IsRemit(entity, target, val)
	local isBoss = false;
	if target:GetEntityType() == eET_Monster then
		isBoss = g_i3k_db.i3k_db_get_monster_is_boss(target._id)
	end

	if isBoss and target._armor.id then
		val, armor = self:CalculateBossArmor(entity, target, val, isRemit, armor)
	else
		val, armor = self:CalculateArmor(entity, target, val, isRemit, armor)
	end

	return { valid = false, value = 0 }, i3k_integer(math.max(1, val)), i3k_integer(sbv), isRemit, armor
end

function i3k_skill:calculateElementDamage(v1, v2)
	return math.max((v1 - v2), 0)
end

function i3k_skill:elementDamage(entity,target)
	local wind		= self:calculateElementDamage(entity:GetPropertyValue(ePropID_WindDamage),target:GetPropertyValue(ePropID_WindDefence));-- 风系伤害
	local fire		= self:calculateElementDamage(entity:GetPropertyValue(ePropID_FireDamage),target:GetPropertyValue(ePropID_FireDefence));
	local soil		= self:calculateElementDamage(entity:GetPropertyValue(ePropID_SoilDamage),target:GetPropertyValue(ePropID_SoilDefence));
	local wond		= self:calculateElementDamage(entity:GetPropertyValue(ePropID_WoodDamage),target:GetPropertyValue(ePropID_WoodDefence));
	local arg1		= entity:GetPropertyValue(ePropID_WindDamage) / (entity:GetPropertyValue(ePropID_WindDamage) + i3k_db_common.element.windArgs1)
	local arg2		= target:GetPropertyValue(ePropID_WindDefence) / (target:GetPropertyValue(ePropID_WindDefence) + i3k_db_common.element.windArgs2)
	local damage 	= (wind + fire + soil + wond)*(1 + arg1 - arg2)

	return math.max(damage, 0);
end

-- 是否豁免
function i3k_skill:IsRemit(entity, target, dmg)
	local entitydex = entity:GetPropertyValue(ePropID_dex);
	local targetdex = target:GetPropertyValue(ePropID_dex);
	local targetmaxHP = target:GetPropertyValue(ePropID_maxHP);

	if entitydex < targetdex and dmg > targetmaxHP * i3k_db_common.skill.dex.arg1 then
		local rnd = i3k_engine_get_rnd_f(0, 1);
		if rnd < i3k_db_common.skill.dex.arg1 + target:GetPropertyValue(ePropID_DexMaster) then
			return true
		end
	end
	return false
end

-- Boss内甲伤害计算
function i3k_skill:CalculateBossArmor(entity, target, val, isRemit , armorData)
	local monster = i3k_db_monsters[target._id];
	local isForbear  = false;
	if entity._armor.id and entity._armor.id ~= 0 and target._armor.id and target._armor.id ~= 0 then
		isForbear = i3k_global_armor_forbear(entity._armor.id, target._armor.id)
	end
	local t_lvl	= target:GetPropertyValue(ePropID_lvl)
	local ArmorAbsorbRatio = monster.ArmorAbsorbRatio / 10000;
	local ArmorGainRatio = (monster.ArmorGainRatio + 10000) / 10000;
	local armorFit = monster.ArmorAbsorbProb;
	local armorValue = target:GetPropertyValue(ePropID_armorCurValue)
	local fArg1 = i3k_db_common.armor.fitArgs1
	local fArg2 = i3k_db_common.armor.fitArgs2
	local F1 = fArg1 * t_lvl + fArg2; --契合系数
	local odds = armorFit / F1
	if not isRemit then
		local rnd = i3k_engine_get_rnd_f(0, 1)
		if odds >= rnd and armorValue > 0 then
			if isForbear then
				armorData.damage = i3k_integer(val * ArmorGainRatio) --内甲加成伤害
			else
				armorData.damage = i3k_integer(val * ArmorAbsorbRatio) --内甲伤害
			end

			if armorValue <= armorData.damage then
				armorData.damage =  armorValue
			end

			val = val * (1 - ArmorAbsorbRatio) --气血伤害
		end
	end
	return val, armorData
end

-- 内甲伤害计算
function i3k_skill:CalculateArmor(entity, target, val, isRemit , armorData)
	local t_lvl	= target:GetPropertyValue(ePropID_lvl)
	local armorFit = target:GetPropertyValue(ePropID_armorFit)
	local armorDef = target:GetPropertyValue(ePropID_armorDef)
	local armorValue = target:GetPropertyValue(ePropID_armorCurValue)
	local armorRec = target:GetPropertyValue(ePropID_armorRec)
	local armorFrezze = target:GetPropertyValue(ePropID_armorFrezze)
	if not isRemit then --没有身法豁免，再计算内甲伤害
		-- 内甲转移
		local fArg1 = i3k_db_common.armor.fitArgs1
		local fArg2 = i3k_db_common.armor.fitArgs2
		local fitMin = i3k_db_common.armor.fitFinalMin / 10000
		local fitMax = i3k_db_common.armor.fitFinalMax / 10000

		local F1 = fArg1 * t_lvl + fArg2; --契合系数
		local odds = armorFit / F1
		if odds < fitMin then
			odds = fitMin
		elseif odds > fitMax then
			odds = fitMax
		end
		local rnd = i3k_engine_get_rnd_f(0, 1)
		if odds >= rnd and armorValue > 0 then -- 触发转移且当前内甲值不为零
			local transferAdd = target:GetPropertyValue(ePropID_ArmorDamageAdd)
			local fitTransfer = (i3k_db_common.armor.damageTransfer + transferAdd) / 10000
			local dArg1 = i3k_db_common.armor.defArgs1
			local dArg2 = i3k_db_common.armor.defArgs2
			local daReMin = i3k_db_common.armor.damageReviseMin / 10000
			local daReMax = i3k_db_common.armor.damageReviseMax / 10000
			local D1 = dArg1 * t_lvl + dArg2 -- 内甲防御系数
			local damageRevise = (1 - (armorDef / (armorDef + D1))) -- 内甲伤害修正
			if damageRevise < daReMin then
				damageRevise = daReMin
			elseif damageRevise > daReMax then
				damageRevise = daReMax
			end
			armorData.damage = i3k_integer(val * fitTransfer * damageRevise) --内甲伤害
			if armorValue <= armorData.damage then
				armorData.damage =  armorValue
				target:SetArmorFreeze(1)
			end
			if self._cfg.type == eSE_Damage then
				val = val * (1 - fitTransfer) --气血伤害
			end
		end
	end
	return val, armorData
end

-- 伤害减免
function i3k_skill:Recharge(target, arg, val)
	local v = val;
	local b = false;

	if arg == eATypeATN or arg == eATypeHolyATN then
		--if arg == eATypeATN then
			if self._cfg.affectType == eAffectDBuff then
				b = true;
				v = v * math.max(0, (1 - target._properties[ePropID_atnRecharge]._value));
			end
		--end
	elseif arg == eATypeINT or arg == eATypeHolyINT then
		--if arg == eATypeINT then
			if self._cfg.affectType == eAffectDBuff then
				b = true;
				v = v * math.max(0, (1 - target._properties[ePropID_magRecharge]._value));
			end
		--end
	end

	-- 神圣伤害减免
	if self._cfg.affectType == eAffectDBuff then
		b = true;
		v = v * math.max(0, (1 - target._properties[ePropID_holyRecharge]._value));
	end

	return b, i3k_integer(v);
end

-- 伤害吸收
function i3k_skill:Reduction(target, value)
	local v = value;
	local b = false;

	if v > 0 then
		if target._behavior:Test(eEBDamageReduce) then
			b = true;
			v = target._behavior:Consume(eEBDamageReduce, v);
		end
	end

	return b, v;
end

-- 伤害反弹
function i3k_skill:IronMaiden(entity, target, arg, value)
	local v = 0;
	local b = false;

	if self._cfg.affectType == eAffectDBuff then
		local _v = target:GetPropertyValue(ePropID_IronMaiden);
		if _v ~= 0 then
			v = value * _v; -- TODO
		end

		v = i3k_integer(v);
		if v > 0 then
			local castDamage = false;

			if arg == eATypeATN or arg == eATypeHolyATN then
				if not (entity._behavior:Test(eFBAtnImmune) or entity._behavior:Test(eFBAllImmune) or entity._behavior:Test(eEBInvincible)) then
					castDamage = true;
				end
			elseif arg == eATypeINT or arg == eATypeHolyINT then
				if not (entity._behavior:Test(eFBMagImmune) or entity._behavior:Test(eFBAllImmune) or entity._behavior:Test(eEBInvincible)) then
					castDamage = true;
				end
			elseif arg == eATypeNone or arg == eATypeSelfMaxHP or arg == eATypeTargMaxHP or arg == eATypeTargLostHP or arg == eATypeSelfCurHP or arg == eATypeTargCurHP or arg == eATypeSelfMaxSP or arg == eATypeTargMaxSP or arg == eATypeSelfCurSP or arg == eATypeTargCurSP then
				if not (target._behavior:Test(eFBAllImmune) or target._behavior:Test(eEBInvincible)) then
					castDamage = true;
				end
			end

			if castDamage then
				b = true;

				_, v = self:Recharge(entity, arg, v);

				_, v = self:Reduction(entity, arg, v);
			end
		end
	end

	return b, i3k_trunc(v);
end

--是否命中
function i3k_skill:IsAtr(entity, target, sdata)
	if sdata.damage.atrType == 1 then -- 必定命中
		return 1;
	end

	if self._cfg.type == eSE_Buff then
		return 1;
	end

	local arg1 = i3k_db_common.skill.atr.arg1;
	local arg2 = i3k_db_common.skill.atr.arg2;
	local arg3 = i3k_db_common.skill.atr.arg3;

	local a_atr = entity:GetPropertyValue(ePropID_atr) + entity:GetPropertyValue(ePropID_SoilDamage) * i3k_db_common.element.soilArgs1;
	local i_dg  = entity:GetPropertyValue(ePropID_ignoreDodge);
	local t_ctr = target:GetPropertyValue(ePropID_ctr) + target:GetPropertyValue(ePropID_SoilDefence) * i3k_db_common.element.soilArgs2;
	local t_lvl = target:GetPropertyValue(ePropID_lvl);

	local rnd1 = i3k_engine_get_rnd_f(0, 1);
	if i_dg >= rnd1 then
		t_ctr = 0
	end


	local odds = arg1 + (a_atr - t_ctr) / (arg2 * t_lvl + arg3);
	if sdata.damage.atrDes then
		odds = odds + sdata.damage.atrDes
	end
	if entity:GetCtrlType() == eCtrlType_Player and target:GetCtrlType() == eCtrlType_Player then
		if odds < 0.33 then odds = 0.33; end
		if odds > 1.00 then odds = 1.00; end
	else
		if odds < 0.66 then odds = 0.66; end
		if odds > 1.00 then odds = 1.00; end
	end

	if self._specialArgs and self._specialArgs.enhanceOdds and self._specialArgs.enhanceOdds.targetType then
		local targetType = self._specialArgs.enhanceOdds.targetType;
		local ismonster = target:GetEntityType() == eET_Monster
		if (ismonster and (targetType == 1 or targetType == 3)) or (not ismonster and targetType == 4) then
			odds = odds + self._specialArgs.enhanceOdds.hitUp / 10000;
		end
	end

	--拳师技能命中调整
	local hero = i3k_game_get_player_hero()
	if hero._combatType > g_BOXER_NORMAL then
		for _,id in ipairs(self._qs_skillAddData) do
			local data = i3k_db_skill_AddData[id]
			if data.type == g_BOXER_ADD_ATR_CRI and data.combatType == hero._combatType then
				odds = odds + data.arg1 / 10000
			end
		end
	end

	local rnd = i3k_engine_get_rnd_f(0, 1);

	if rnd <= odds then
		return 1;
	end

	-- 偏斜
	rnd = i3k_engine_get_rnd_f(0, 1);
	local deflect = entity:GetPropertyValue(ePropID_deflect);
	if rnd <= deflect then
		return 2;
	end

	return 0;
end

--是否暴击
function i3k_skill:IsCri(entity, target, sdata)
	if sdata.damage.acrType == 1 then -- 必定暴击
		return true;
	end

	local lvl	= entity:GetPropertyValue(ePropID_lvl);
	local healA	= entity:GetPropertyValue(ePropID_healA);
	local ig_tou = entity:GetPropertyValue(ePropID_ignoretou);
	local woodF	= entity:GetPropertyValue(ePropID_WoodDefence);

	local odds = 0;

	if self._cfg.type == eSE_Buff then
		local arg1 = i3k_db_common.skill.hel.arg1;
		local arg2 = i3k_db_common.skill.hel.arg2;
		local arg3 = i3k_db_common.skill.hel.arg3;
		local wood  = woodF/(woodF + i3k_db_common.element.woodArgs2);

		local F1 = arg1 * lvl + arg2;

		odds = healA / F1 + wood;
	else
		local arg1 = i3k_db_common.skill.cri.arg1;
		local arg2 = i3k_db_common.skill.cri.arg2;
		local arg3 = i3k_db_common.skill.cri.arg3;

		local a_acrN	= entity:GetPropertyValue(ePropID_acrN) + entity:GetPropertyValue(ePropID_FireDamage) * i3k_db_common.element.fireArgs1;
		local t_tou		= target:GetPropertyValue(ePropID_tou) + target:GetPropertyValue(ePropID_FireDefence) * i3k_db_common.element.fireArgs2;
		local t_lvl		= target:GetPropertyValue(ePropID_lvl);

		local rnd1 = i3k_engine_get_rnd_f(0, 1);
		if ig_tou >= rnd1 then
			t_tou = 0
		end

		odds = arg1 + (a_acrN - t_tou) / (arg2 * t_lvl + arg3);
		if sdata.damage.acrDes then
			odds = odds + sdata.damage.acrDes
		end

		if entity:GetCtrlType() == eCtrlType_Player and target:GetCtrlType() == eCtrlType_Player then
			if odds < 0.01 then odds = 0.01; end
			if odds > 0.33 then odds = 0.33; end
		else
			if odds < 0.01 then odds = 0.01; end
			if odds > 0.50 then odds = 0.50; end
		end
	end
	if self._specialArgs and self._specialArgs.enhanceOdds and self._specialArgs.enhanceOdds.targetType then
		local targetType = self._specialArgs.enhanceOdds.targetType;
		local ismonster = target:GetEntityType() == eET_Monster
		if (ismonster and (targetType == 1 or targetType == 3)) or (not ismonster and targetType == 4) then
			odds = odds + self._specialArgs.enhanceOdds.critUp / 10000;
		end
	end

	--拳师技能命中调整
	local hero = i3k_game_get_player_hero()
	if hero._combatType > g_BOXER_NORMAL then
		for _,id in ipairs(self._qs_skillAddData) do
			local data = i3k_db_skill_AddData[id]
			if data.type == g_BOXER_ADD_ATR_CRI and data.combatType == hero._combatType then
				odds = odds + data.arg2 / 10000
			end
		end
	end

	local rnd = i3k_engine_get_rnd_f(0, 1);

	return rnd <= odds;
end

--return 伤害 吸血 暴击 豁免
function i3k_skill:GetDamage(atr, entity, target, sdata, isCombo)
	local cri = self:IsCri(entity, target, sdata);
	if atr == 2 then
		cri = false;
	end
	-- 重置伤害修正
	entity:ResetDamageRetrive();
	target:ResetDamageDes();
	entity:ResetDamageAddition();
	entity._triMgr:PostEvent(entity, eTEventAttack, true, self._cfg.type ~= eSE_Buff, cri,target);
	target._triMgr:PostEvent(entity, eTEventAttack, true, self._cfg.type ~= eSE_Buff, cri, target);

	local reduce, dmg, sbv, isRemit, armor = self:GetBaseDamage(atr, cri, entity, target, sdata, isCombo); -- 伤害
	if isRemit then
		return 0,0,0,0,true;
	end

	entity._triMgr:PostEvent(entity, eTEventAttack, false, self._cfg.type ~= eSE_Buff, cri,target);
	return dmg, sbv, cri, reduce , false, armor
end

function i3k_skill:updateCoolTimeForce(time)--毫秒
	self._cool = time
end

function i3k_skill:SetSkillShareTotalCool(shareTotalCool)
	self._shareTotalCool = shareTotalCool
end

function i3k_skill:getCoolTime()
	return _cool
end

function i3k_skill_create(entity, cfg, lvl, realm, gtype)
	if not cfg then
		return nil;
	end

	-- local skill = nil;
	-- if cfg.triType == eST_Attack then
	-- 	skill = i3k_skill.new(entity, cfg, lvl, realm, gtype);
	-- elseif cfg.triType == eST_Tri then
	-- 	skill = i3k_skill.new(entity, cfg, lvl, realm, gtype);
	-- elseif cfg.triType == eST_Passive then
	-- 	skill = i3k_passive_skill.new(entity, cfg, lvl, realm, gtype);
	-- end

	return i3k_skill.new(entity, cfg, lvl, realm, gtype);
end

------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/battle/i3k_buff_def");


-----------------------------------------------------------------
i3k_buff = i3k_class("i3k_buff");
function i3k_buff:ctor(skill, id, cfg, attackerRealmLvl)
	self._id		= id;
	self._guid		= i3k_gen_buff_guid();
	self._cfg		= cfg;
	self._skill		= skill;
	self._hoster	= nil;
	self._timeLine	= 0;
	self._timeTick	= 0;
	self._endTime	= 0;
	self._effectID	= -1;
	self._overlays	= 1;
	self._attackerRealmLvl = 0;
	self._removeZero
					= cfg.removeOnZero == 1;
	self._owner		= cfg.owner == 1;
	self._type		= cfg.type;
	self._canRebound= true;
	if cfg.affectType == eBuffAType_Stat then
		self._acfg	= i3k_db_state_affect[cfg.affectID];
		if self._acfg then
			self._canRebound = self._acfg.canRebound == 1;
		end
	else
		self._acfg = nil;
	end
	self._passive	= false;
	self._valueOdds	= 1.0;
	self._realmOdds	= 1.0;
	self._value		= 0;
	self._values	= { };

	if skill and skill._realm then
		self._attackerRealmLvl = skill._realm
	end

	if attackerRealmLvl then
		self._attackerRealmLvl = attackerRealmLvl
	end

	-- childs
	self._childs = { };
	if cfg.childs then
		for k = 1, #cfg.childs do
			local cid = cfg.childs[k];
			if cid > 0 then
				local cb = i3k_db_buff[cid];
				if cb then
					table.insert(self._childs, i3k_buff.new(skill, cid, cb, attackerRealmLvl));
				end
			end
		end
	end
	self._floatingProlCount = 0 -- 延长浮空被击次数
end

function i3k_buff:SetPassive(enable)
	self._passive = enable;
end

function i3k_buff:IsPassive()
	return self._passive;
end

function i3k_buff:SetValueOdds(odds)
	self._valueOdds = odds / 10000;
end

function i3k_buff:SetRealmOdds(odds)
	self._realmOdds = odds / 10000;
end

function i3k_buff:Bind(attacker, hoster)
	self._timeLine	= 0;
	self._hoster	= hoster;
	self._attacker	= attacker;
	self._effectID	= -1;

	if not hoster or hoster:IsDead() then
		return false, false;
	end

	local s = self._skill;
	local c = self._cfg;
	local realm = 0;
	if c.valueType == 1 then -- now only fixed value is valid by realm
		value = c.affectValue * (1 + self._attackerRealmLvl * c.realmAddon * self._realmOdds);
	else
		--value = hoster:GetPropertyValue(c.affectID) * c.affectValue / 100;
		value = c.affectValue;
	end

	local res = true;

	local _b = hoster._buffs[self._id];
	if _b then
		if c.overlays > 1 and _b._overlays < c.overlays then
			if c.overlayType == 1 then
				_b._value = _b._value + value;
			elseif c.overlayType == 2 then
				if attacker then
					if attacker:GetEntityType() == eET_Player and  attacker:GetFightSp() > 0 and  attacker:GetFightSp() <= 5 then
						_b._endTime = _b._endTime + c.loopTime + c.fightspadd * attacker:GetFightSp();
					else
						_b._endTime = _b._endTime + c.loopTime + c.fightspadd;
					end
				else
					_b._endTime = _b._endTime + c.loopTime + c.fightspadd;
				end
			elseif c.overlayType == 3 then
				if value > _b._value then
					_b._value = value
				end
			elseif c.overlayType == 4 then
				if value > _b._value then
					_b._value = value
					_b._timeLine = 0;
				end
			elseif c.overlayType == 5 then
				_b._value = _b._value + value;
				_b._timeLine = 0;
			end
			_b._overlays = _b._overlays + 1;
			_b._values[self._overlays] = value

			if _b._passive then
				_b._endTime = -1;
			end
			return false, true;
		else
			if self._passive then
				hoster:ClsBuff(self._id);
			else
				res = false;
			end
		end
	end

	if res then
		self._value = value;
		if attacker then
			local addsp = attacker:GetFightSp();

			if attacker:GetEntityType() == eET_Player and addsp and addsp > 0 and addsp <= 5 then
				self._endTime = c.loopTime + c.fightspadd * addsp;
			else
				self._endTime = c.loopTime + c.fightspadd;
			end
		else
			self._endTime = c.loopTime + c.fightspadd;
		end

		if self._passive then
			self._endTime = -1;
		end

		res = self:OnBinded(hoster);

	end

	return res, false;
end

function i3k_buff:Unbind()
	local c = self._cfg;
	local h = self._hoster;

	if h then
		if c.overlayType ~= 5 or self._overlays == 1 then
			h._triMgr:PostEvent(h, eTEventBuff, self._id, eBStep_Remove, 0);

			if self._tids then
				local mgr = h._triMgr;
				if mgr then
					for k, v in ipairs(self._tids) do
						mgr:UnregTrigger(v);
					end
				end
				self._tids = nil;
			end

			if h._entity and not self._passive then
				h._entity:RmvHosterChild(self._effectID);
			end
			
			if i3k_get_is_floating_buff(c) then
				h:Play(i3k_db_common.engine.defaultStandAction, -1)
			end

			if c.affectType == eBuffAType_Stat then
				h._behavior:Clear(c.affectID, c.id);
			end

			for _, child in pairs(self._childs) do
				if child._removeByParent then
					h:RmvBuff(child);
				end
			end
		else
			local _b = h._buffs[self._id];
			if _b then
				local value = _b._values[self._overlays];
				_b._values[self._overlays] = nil;

				_b._value		= _b._value - value;
				_b._timeLine	= 0;
				_b._overlays	= _b._overlays - 1;
			end
		end

		return true;
	end

	return false;
end

function i3k_buff:OnBinded(hoster)
	local c = self._cfg;

	local suc = true;

	if c.affectType == eBuffAType_Stat then
		local vt = 1;
		local va = 0;
		if self._acfg and self._acfg.needVal == 1 then
			vt = c.valueType;
			va = c.affectValue;
		end

		suc = hoster._behavior:Set(c.affectID, self._id, vt, va, self._attacker);
	end

	-- trigger
	self._tids = { };
	local logic		= i3k_game_get_logic();
	local world = logic:GetWorld();
	if world then
		if world._mapType == g_BASE_DUNGEON and world._openType == g_FIELD then
			for k, v in ipairs(c.trigger) do
				local mgr = hoster._triMgr;
				if mgr then
					local tcfg = i3k_db_ai_trigger[v];
					if tcfg then
						local TRI = require("logic/entity/ai/i3k_trigger");
						local tri = TRI.i3k_ai_trigger.new(hoster);
						if tri:Create(tcfg, c.id, v) then
							local tid = mgr:RegTrigger(tri, self);
							if tid >= 0 then
								table.insert(self._tids, tid);
							end
						end
					end
				end
			end
		end
	end

	if suc then
		for _, child in pairs(self._childs) do
			local ret, overlay = hoster:AddBuff(self._attacker, child);
			if ret then
				child._removeByParent = true;
			end
		end
	end

	if suc then
		if c.affectType == eBuffAType_Stat then
			--hoster:UpdateBuffBar(self, true);
		end
		if not self._passive then
			local cfg = i3k_db_effects[c.effectID];
			if cfg and hoster._entity then
				if cfg.hs == '' or cfg.hs == 'default' then
					self._effectID = hoster._entity:LinkHosterChild(cfg.path, string.format("entity_buff_%s_effect_%d", hoster._guid, self._id), "", "", 0.0, cfg.radius, false, true);
				else
					self._effectID = hoster._entity:LinkHosterChild(cfg.path, string.format("entity_buff_%s_effect_%d", hoster._guid, self._id), cfg.hs, "", 0.0, cfg.radius, false, true);
				end

				if self._effectID > 0 then
					hoster._entity:LinkChildPlay(self._effectID, -1, true);
				end
			end
			if c.type == eBuffType_DBuff then
				--local hero = i3k_game_get_player_hero()
				--if hoster:IsPlayer() or (hoster._hoster and hoster._hoster:IsPlayer())  or ((hoster:GetEntityType() == eET_Pet or hoster:GetEntityType() == eET_Skill) and hero and hoster._hosterID and hero:GetGuidID() == hoster._hosterID) or g_i3k_game_context:IsTeamMember(hoster:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
					hoster:ShowInfo(attacker, eEffectID_DeBuff.style, self._cfg.note, i3k_db_common.engine.durNumberEffect[2] / 1000);
				--end
			elseif c.type == eBuffType_Unknown or c.type == eBuffType_Buff then
				--local hero = i3k_game_get_player_hero()
				--if hoster:IsPlayer() or (hoster._hoster and hoster._hoster:IsPlayer())  or ((hoster:GetEntityType() == eET_Pet or hoster:GetEntityType() == eET_Skill) and hero and hoster._hosterID and hero:GetGuidID() == hoster._hosterID) or g_i3k_game_context:IsTeamMember(hoster:GetGuidID()) or g_i3k_game_context:GetWorldMapType() ~= 0 then
					hoster:ShowInfo(attacker, eEffectID_Buff.style, self._cfg.note, i3k_db_common.engine.durNumberEffect[2] / 1000);
				--end
			end
		end
	end

	if suc then
		hoster._triMgr:PostEvent(hoster, eTEventBuff, self._id, eBStep_Add, 0);
	end

	return suc;
end

function i3k_buff:OnUpdate(dTime)
end

function i3k_buff:OnLogic(dTick)
	local c = self._cfg;
	local h = self._hoster;

	if (h and not h:IsDead()) or self._passive then
		self._timeLine = self._timeLine + dTick * i3k_engine_get_tick_step();

		local logic = i3k_game_get_logic();
		local world = logic:GetWorld();
		local removed = false;
		local singleP = false;
		if not world or (world._mapType == g_BASE_DUNGEON and world._openType == g_FIELD) or (world._mapType == g_PLAYER_LEAD) then
			singleP = true;
		end
	
		if singleP and self._endTime > 0 then
			removed = self._timeLine >= self._endTime;
		end

		if c.affectType == eBuffAType_Stat then
			if self._acfg and self._acfg.needVal == 1 then
				local v = h._behavior:Get(c.affectID, c.id);
				if v.value <= 0 then
					if singleP then
						h._behavior:Clear(c.affectID, c.id);
					end

					return false;
				end
			end
		else
			if c.affectTick > 0 and not removed then
				self._timeTick = self._timeTick + dTick * i3k_engine_get_tick_step();
				if self._timeTick > c.affectTick then
					self._timeTick = 0;
					
					if singleP then
						if c.valueType ~= 1 then
							local value = i3k_integer(h:GetPropertyValue(c.affectID)*self._value* self._valueOdds/10000)
							h:ProcessBuffDamage(self._attacker, c.id, ePropID_hp, 1, value);
						else
							h:ProcessBuffDamage(self._attacker, c.id, c.affectID, c.valueType, self._value * self._valueOdds);
						end
					end
					
					if self._removeZero then
						local _val = h:GetPropertyValue(c.affectID);
						if _val <= 0 then
							return false;
						end
					end
				end
			end
		end

		if removed or (h:IsDead() and not self._passive) then
			if c.affectType == eBuffAType_Stat then
				if singleP and not h:IsDead() then
					h._behavior:Clear(c.affectID, c.id);
				end
			end
			
			return false;
		end
	else
		local mapType = i3k_game_get_map_type()
		local mapCondition = mapType == g_FORCE_WAR or mapType == g_TOURNAMENT or mapType == g_FACTION_WAR or mapType == g_BUDO or mapType == g_DEFENCE_WAR or mapType == g_DESERT_BATTLE
		if h:IsPlayer() and h:IsDead() and self._cfg.isShowAbove and mapCondition then
			return true
		end
		if mapType == g_BASE_DUNGEON then
			return false;
		end
	end

	return true;
end

function i3k_buff:AddOverlays()
	local c = self._cfg;
	local h = self._hoster;

	if self._overlays < self._cfg.overlays then
		self._overlays = self._overlays + 1;
	end

	if c.affectType == eBuffAType_Stat then
		local va = 0;
		local vt = 1;
		if self._acfg and self._acfg.needVal == 1 then
			vt = c.valueType;
			va = c.affectValue * self._overlays;
		end

		h._behavior:Update(c.affectID, va);
	else
		self._timeLine = 0;
	end

	return true;
end

function i3k_buff:GetAffectValue()
	return self._value * self._valueOdds;
end

function i3k_buff:CanRebound()
	return self._canRebound;
end

function i3k_buff:SetBuffEffectVis(Vis)
	local c = self._cfg;
	if self._hoster and not self._hoster:IsDead() then
		if Vis then
			if not self._passive then
				local cfg = i3k_db_effects[c.effectID];
				if cfg then
					if cfg.hs == '' or cfg.hs == 'default' then
						self._effectID = self._hoster._entity:LinkHosterChild(cfg.path, string.format("entity_buff_%s_effect_%d", self._hoster._guid, self._id), "", "", 0.0, cfg.radius, false, true);
					else
						self._effectID = self._hoster._entity:LinkHosterChild(cfg.path, string.format("entity_buff_%s_effect_%d", self._hoster._guid, self._id), cfg.hs, "", 0.0, cfg.radius, false, true);
					end

					if self._effectID > 0 then
						self._hoster._entity:LinkChildPlay(self._effectID, -1, true);
					end
				end
			end
		else
			if not self._passive then
				self._hoster._entity:RmvHosterChild(self._effectID);
			end
		end
	end
end

-- 浮空被击延长次数
function i3k_buff:AddFloatingProlTimes()
	self._floatingProlCount = self._floatingProlCount + 1
end

function i3k_buff:GetFloatingProlTimes()
	return self._floatingProlCount
end

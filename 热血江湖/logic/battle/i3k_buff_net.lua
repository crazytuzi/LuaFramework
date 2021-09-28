------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/battle/i3k_buff_def");


-----------------------------------------------------------------
i3k_buff_net = i3k_class("i3k_buff_net");
function i3k_buff_net:ctor(skill, id, cfg, attackerRealmLvl)
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
					table.insert(self._childs, i3k_buff_net.new(skill, cid, cb, attackerRealmLvl));
				end
			end
		end
	end
end

function i3k_buff_net:SetPassive(enable)
	self._passive = enable;
end

function i3k_buff_net:IsPassive()
	return self._passive;
end

function i3k_buff_net:SetValueOdds(odds)
	self._valueOdds = odds / 10000;
end

function i3k_buff_net:SetRealmOdds(odds)
	self._realmOdds = odds / 10000;
end

function i3k_buff_net:Bind(attacker, hoster)
	self._timeLine	= 0;
	self._hoster	= hoster;
	self._attacker	= attacker;
	self._effectID	= -1;

	local c = self._cfg;
	if c.valueType == 1 then -- now only fixed value is valid by realm
		value = c.affectValue * (1 + self._attackerRealmLvl * c.realmAddon * self._realmOdds);
	else
		value = c.affectValue;
	end
	self._value = value;
	self._endTime = c.loopTime + c.fightspadd;
	
	if self._passive then
		self._endTime = -1;
	end	
	
	res = self:OnBinded(hoster);
	return res, false;
end

function i3k_buff_net:Unbind()
	local c = self._cfg;
	local h = self._hoster;

	if h then
		if c.overlayType ~= 5 or self._overlays == 1 then
			if h._entity and self._effectID > 0 then
				h._entity:RmvHosterChild(self._effectID);
			end

			if c.affectType == eBuffAType_Stat then
				h._behavior:Clear(c.affectID, c.id);
			end
			
			if i3k_get_is_floating_buff(c) then
				h:Play(i3k_db_common.engine.defaultStandAction, -1)
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

function i3k_buff_net:OnBinded(hoster)
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
	
	if suc then
		for _, child in pairs(self._childs) do
			local ret, overlay = hoster:AddBuff(self._attacker, child);
			if ret then
				child._removeByParent = true;
			end
		end
	end

	if suc then
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
				hoster:ShowInfo(attacker, eEffectID_DeBuff.style, self._cfg.note, i3k_db_common.engine.durNumberEffect[2] / 1000);
			elseif c.type == eBuffType_Unknown or c.type == eBuffType_Buff then
				hoster:ShowInfo(attacker, eEffectID_Buff.style, self._cfg.note, i3k_db_common.engine.durNumberEffect[2] / 1000);
			end
		end
	end

	return suc;
end

function i3k_buff_net:OnUpdate(dTime)
end

function i3k_buff_net:OnLogic(dTick)
	
	return true;
end

function i3k_buff_net:GetAffectValue()
	return self._value * self._valueOdds;
end

function i3k_buff_net:CanRebound()
	return self._canRebound;
end

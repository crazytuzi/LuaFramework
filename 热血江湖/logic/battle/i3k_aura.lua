------------------------------------------------------
module(..., package.seeall)

local require = require

-- 目标类型
eAuraTarget_Owner = 1;
eAuraTarget_Enemy = 2;

-----------------------------------------------------------------
i3k_aura = i3k_class("i3k_aura");
function i3k_aura:ctor(skill, cfg)
	--{ type = 1, radius = 500, targetType = 1, duration = 10000, buffID = 165,  }
	self._id			= skill._id;
	self._skill			= skill;
	self._type			= cfg.type;
	self._radius		= cfg.radius;
	self._targetType	= cfg.targetType;
	self._duration		= cfg.duration;
	self._buffID		= cfg.buffID;
	self._timeLine		= 0;
	self._release		= true;
	self._hoster		= nil;
	self._affects		= { };
end

function i3k_aura:Release()
	if not self._release then
		for k, v in pairs(self._affects) do
			self:RmvAffect(v);
		end
		self._affects = { };

		self._release = true;
	end
end

function i3k_aura:Bind(hoster)
	if hoster and not hoster:IsDead() then
		self._release	= false;
		self._hoster	= hoster;
		local userentity = nil
		if self._hoster then
			userentity = self._hoster
			if self._hoster._hoster then
				userentity = self._hoster._hoster
			end
		end
		self._duration	= self._duration + self._skill:TalentSkillChange(userentity,eSCType_Common,eSCCommon_auratime)
		return true;
	end

	return false;
end

function i3k_aura:Unbind()
end

function i3k_aura:OnUpdate(dTime)
end

function i3k_aura:OnLogic(dTick)
	local h = self._hoster;

	self._timeLine = self._timeLine + dTick * i3k_engine_get_tick_step();
	if h:IsDead() or (self._timeLine > self._duration) then
		self:Release();
	else
		local offset = 30; -- 30厘米

		for k, v in pairs(self._affects) do
			local entity = v.target;
			if not entity:HaveSpecialBuff(v.buff._guid) or entity:IsDead() or i3k_vec3_dist(entity._curPos, h._curPos) > (self._radius + offset) then
				self:RmvAffect(v);
			end
		end

		local targets = { };
		if self._targetType == eAuraTarget_Enemy then
			targets = h._alives[2];
		else
			targets = h._alives[1];
		end

		if targets then
			for k, v in ipairs(targets) do
				local target = v.entity;

				if v.dist <= self._radius then
					self:AddAffect(target);
				end
			end
		end
	end

	return not self._release;
end

function i3k_aura:AddAffect(target)
	if not self._affects[target._guid] then
		local BUFF = require("logic/battle/i3k_buff");

		local bcfg = i3k_db_buff[self._buffID];
		if bcfg then
			local buff = BUFF.i3k_buff.new(self._skill, self._buffID, bcfg);

			local h = self._hoster;
			if h:GetEntityType() == eET_Skill then
				h = h:GetHoster();
			end

			if target:AddBuff(h, buff) then
				self._affects[target._guid] = { target = target, buff = buff };
			end
		end
	end
end

function i3k_aura:RmvAffect(affect)
	if affect then
		local target = affect.target;
		if target then
			if self._affects[target._guid] then
				target:RmvBuff(affect.buff);

				self._affects[target._guid] = nil;
			end
		end
	end
end


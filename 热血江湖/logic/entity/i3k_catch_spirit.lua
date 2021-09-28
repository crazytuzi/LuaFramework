------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity


------------------------------------------------------
i3k_catch_spirit = i3k_class("i3k_catch_spirit", BASE);

function i3k_catch_spirit:ctor(guid)
	self._entityType	= eET_CatchSpirit;
	self._lastCall = 0
	self._countdown = 0
	self._isCalled = true --冷却中为true
	self._playEffectDelay = 0
	self._isPlayLoopEffect = false
	self._effect1 = -1
	self._effect2 = -1
	self:CreateActor()
end

function i3k_catch_spirit:Create(modelId, gid)
	self._gid = gid
	local mcfg = i3k_db_models[modelId];
	if mcfg then
		self._resCreated = 0
		self._name		= mcfg.desc;
		if self._entity:CreateHosterModel(mcfg.path, string.format("catch_spirit_%s", self._gid)) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);
			self._entity:EnterWorld(false);
		end
	end
end

function i3k_catch_spirit:OnSelected(val)
	
end

function i3k_catch_spirit:CanRelease()
	return true;
end

function i3k_catch_spirit:ValidInWorld()
	return true;
end

function i3k_catch_spirit:updateCallTime(time)
	self._lastCall = time
	self:updateEffectShow()
end

function i3k_catch_spirit:updateEffectShow()
	local isCalled = i3k_game_get_time() - self._lastCall < i3k_db_catch_spirit_base.dungeon.callCold
	if self._isCalled ~= isCalled then
		self._isCalled = isCalled
		if isCalled then
			if self._effect1 ~= -1 then
				self:OnStopChild(self._effect1)
			end
			if self._effect2 ~= -1 then
				self:OnStopChild(self._effect2)
			end
			self._isPlayLoopEffect = true
			self._playEffectDelay = 0
		else
			self._isPlayLoopEffect = false
			self._playEffectDelay = 0
			self._effect1 = self:PlayHitEffectAlways(i3k_db_catch_spirit_base.dungeon.actionWithEffect)
		end
	end
end

function i3k_catch_spirit:OnUpdate(dTime)
	BASE.OnUpdate(self, dTime)
	if self._isCalled then
		self._countdown = self._countdown + dTime
		if self._countdown >= 1 then
			self._countdown = 0
			self:updateEffectShow()
		end
	else
		if not self._isPlayLoopEffect then
			self._playEffectDelay = self._playEffectDelay + dTime
			if self._playEffectDelay >= i3k_db_catch_spirit_base.dungeon.effectLast/1000 then
				if self._effect1 ~= -1 then
					self:OnStopChild(self._effect1)
				end
				self._effect2 = self:PlayHitEffectAlways(i3k_db_catch_spirit_base.dungeon.actionWithoutEffect)
				self._isPlayLoopEffect = true
			end
		end
	end
end



Require("CommonScript/AsyncBattle/BossFightBattle.lua");

local tbParent_Base = AsyncBattle:GetClass("BasePvp")
local tbParent_ = AsyncBattle:GetClass("BossFightBattle")
local tbBase = AsyncBattle:CreateClass("BossFight_Client", "BossFightBattle");

function tbBase:OnEnterMap()
	tbParent_.OnEnterMap(self);
end

function tbBase:OnLeaveMap()
	tbParent_.OnLeaveMap(self);
end

function tbBase:Client_OnMapLoaded()
	if not AsyncBattle.tbBattle then
		return
	end
	tbParent_Base.OnPlayerReady(AsyncBattle.tbBattle)
	tbParent_.Client_OnMapLoaded(self)
end


function tbBase:BindCameraToNpc(pPlayer, nNpcId, nCrossTime)
	tbParent_Base:LookNpc(nNpcId, nCrossTime)
end

function tbBase:GetResultParams()
	return {nBattleKey = self.nBattleKey, nDamage = self.nDamage}
end

function tbBase:Start()
	tbParent_.Start(self);
	self.nStartTime = GetTime();
	self.nSampleTime = self.nStartTime
	self.nSampleDamage = 1
	Timer:Register(5 * Env.GAME_FPS, function ()
		if self.nState == AsyncBattle.ASYNC_BATTLE_END or me.nMapId ~= self.nMapId then
			return;
		end
		local nCurTime = GetTime();
		if nCurTime - self.nSampleTime > 10 then
			self:End()
			return;
		end
		local pBoss = KNpc.GetById(self.nBossId);
		if pBoss then
			local tbInfo = pBoss.GetDamageCounter();
			self.nSampleDamage = tbInfo.nReceiveDamage;
			self.nSampleTime = nCurTime
		else
			return;
		end

		return true
	end);
end

function tbBase:End()
	if self.nSampleTime and GetTime() - self.nSampleTime > 10 then
		self.nDamage = self.nSampleDamage
		tbParent_Base.End(self)
	else
		tbParent_.End(self);
	end
end

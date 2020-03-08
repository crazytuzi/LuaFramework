Require("CommonScript/AsyncBattle/AloneAsyncBattle.lua");

local tbParent = AsyncBattle:GetClass("AloneAsyncBattle");
local tbBase = AsyncBattle:CreateClass("BossRobBattle", "AloneAsyncBattle");

tbBase.tbCenterPoint = {2188, 1981}

tbBase.tbEnemyPos =
{
	{2234, 1150,},

	{1582, 1150,},
	{2770, 1150,},
}

tbBase.tbSelfPos =
{
	{2221, 2643,},

	{2752, 2643,},
	{1599, 2643,},
}

local tbDir = {32, 0}

function tbBase:GetNpcDir(nCustomMode)
	return tbDir[nCustomMode]
end

function tbBase:Init(...)
	tbParent.Init(self, ...);
	self.nBattleTime = Boss.Def.nRobBattleTime;
	self.nEnemyBeated = 0;
	self.tbBeatedNpc = {};
end

function tbBase:OnNpcDeath(nCustomMode, nPosIdx)
	if nCustomMode == 2 then
		if him.nKind == Npc.KIND.player then
			self.bEnemyMainBeated = true;
		else
			self.tbBeatedNpc[him.nTemplateId] = true;
		end
		self.nEnemyBeated = self.nEnemyBeated + 1;
	end

	tbParent.OnNpcDeath(self, nCustomMode, nPosIdx);
end


function tbBase:CalcResult()
	return self.nEnemyBeated > 0 and 1 or 0;
end

function tbBase:CloseBossBattle()
	self:Close();
	local pPlayer = self:GetSelfPlayer()
	if pPlayer then
		pPlayer.CallClientScript("AsyncBattle:DoFun", self.szClassType, "Client_InterruptBattle")
	end
end

function tbBase:OnEnterMap()
	tbParent.OnEnterMap(self);

	me.CallClientScript("Boss:EnterBossBattle");
end

function tbBase:OnLeaveMap()
	tbParent.OnLeaveMap(self);

	me.CallClientScript("Boss:LeaveRobBattle");
end

function tbBase:Client_InterruptBattle()
	me.MsgBox("挑战武林盟主已结束",
		{
			{"确定", function ()
					AsyncBattle:LeaveBattle();
			end}
		}, nil, Boss.Def.nFinishWaitTime, AsyncBattle.LeaveBattle);
end


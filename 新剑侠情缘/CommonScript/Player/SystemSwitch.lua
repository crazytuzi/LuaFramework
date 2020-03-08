Env.tbSystemSwitch = {};
function Env:SetSystemSwitchOff(pPlayer, nType)
	if not MODULE_GAMESERVER then
		return;
	end

	pPlayer.tbSystemSwitch = pPlayer.tbSystemSwitch or {};
	pPlayer.tbSystemSwitch[nType] = true;
end

function Env:SetSystemSwitchOn(pPlayer, nType)
	if not MODULE_GAMESERVER then
		return;
	end

	pPlayer.tbSystemSwitch = pPlayer.tbSystemSwitch or {};
	pPlayer.tbSystemSwitch[nType] = nil;
end

function Env:SetAllPlayerSystemSwitchOff(nType)
	if not MODULE_GAMESERVER then
		return;
	end

	Env.tbSystemSwitch = Env.tbSystemSwitch or {};
	Env.tbSystemSwitch[nType] = true;
end

function Env:SetAllPlayerSystemSwitchOn(nType)
	if not MODULE_GAMESERVER then
		return;
	end

	Env.tbSystemSwitch = Env.tbSystemSwitch or {};
	Env.tbSystemSwitch[nType] = nil;
end

function Env:CheckSystemSwitch(pPlayer, nType)
	if Env.tbSystemSwitch[self.SW_All] or Env.tbSystemSwitch[nType] then
		return false;
	end

	pPlayer.tbSystemSwitch = pPlayer.tbSystemSwitch or {};
	if pPlayer.tbSystemSwitch[self.SW_All] or pPlayer.tbSystemSwitch[nType] then
		return false;
	end

	return true;
end

Env.SW_All 					= 0;
Env.SW_TeamFuben 			= 1;
Env.SW_RandomFuben			= 2;
Env.SW_TeamBattle			= 3;
Env.SW_PersonalFuben		= 4;
Env.SW_SwitchMap			= 5;
Env.SW_KinBattle			= 6;
Env.SW_CangBaoTu			= 7;
Env.SW_GiftSystem			= 8;
Env.SW_PunishTask			= 9;
Env.SW_AdventureFuben = 10;
Env.SW_WhiteTigerFuben = 11;
Env.SW_KinTrain = 12;
Env.SW_ChuangGong	        = 13;
Env.SW_KinNest = 14;
Env.SW_UseDecoration = 15;
Env.SW_House 				= 16;
Env.SW_HousePlant	 		= 17;
Env.SW_Muse			 		= 18;
Env.SW_SellFurniture		= 19;
Env.SW_SampleHouse			= 20;
Env.SW_HouseDefend			= 21;
Env.SW_Toy = 22;


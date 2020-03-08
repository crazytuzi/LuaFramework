--[[
	【目前除了家族排行之外】
	【在玩家上线的时候都会将过期数据清0】
	【如果排行榜选择清数据的话，必须在玩家数值变化之后，进行排行才生效】

	local  tbForbidData = pPlayer.GetScriptTable("Forbid");
	pPlayer.tbForbidData = tbForbidData
	local tbBanData = pPlayer.tbForbidData.BanData;
	tbBanData[nType] = {}
	tbBanData[nType].nBanTime = 0
	tbBanData[nType].szBanTips = ""

	-- 目前家族的记在家族那边
	所以tbBanData[3]没记数据

	【1】家族
	local kinData = Kin:GetKinById(dwKinId)
	kinData:SetBanRankTime(nEndTime,szTips)
	local nBanTime = kinData:GetBanRankTime();
	local szTips = kinData:GetBanRankTips();

	【2】默认
	local tbBanData = pPlayer.tbForbidData.BanData;
	tbBanData[nType] = {}
	tbBanData[nType].nBanTime = 0
	tbBanData[nType].szBanTips = ""
]]

Forbid.BanType = 													-- 所有的禁止类型
{
	LevelRank 			= 1,										-- 1.时间过期后数值变化或者玩家上线会把排行榜的值更新，等到下一次排行的时候可参与  (等级排行榜)
	FightPowerRank 		= 2,										-- 同1（先把值更新后进行排行才生效） （战力排行榜）
	KinRank 			= 3,										-- 时间过期后家族数值变化会把排行榜的值更新，等到下一次排行的时候可参与 （家族排行榜）
	WuShenRank 			= 4,										-- 2.时间过期后玩家排名变动则更新排行 （武神殿排名）
	WuLinMengZhu 		= 5,										-- 同2 （武林盟主排名）
	
	FightPower_Faction  = 6,										-- 同1 （门派排行榜）

	FightPower_Equip    = 7,										-- 同1 （洗练排行榜）
	FightPower_Strengthen    = 8,									-- 同1 （强化排行榜）
	FightPower_Stone    = 9,										-- 同1 （镶嵌排行榜）
	FightPower_Partner  = 10,										-- 同1 （同伴排行榜）

	CardCollection_1 	= 11,										-- 同1  （凌绝峰收集榜） 
	HouseRank			= 12,										-- 同1	（家园排行榜）
}

-- 禁止提示中显示活动名字
Forbid.szBanName = 
{
	[Forbid.BanType.LevelRank] 					= "等级排行榜",
	[Forbid.BanType.FightPowerRank] 			= "战力排行榜",
	[Forbid.BanType.KinRank] 					= "家族排行榜",
	[Forbid.BanType.WuShenRank] 				= "武神殿",
	[Forbid.BanType.WuLinMengZhu] 				= "武林盟主",
	[Forbid.BanType.FightPower_Faction] 		= "门派排行榜",
	[Forbid.BanType.FightPower_Equip] 			= "洗练排行榜",
	[Forbid.BanType.FightPower_Strengthen] 		= "强化排行榜",
	[Forbid.BanType.FightPower_Stone] 			= "镶嵌排行榜",
	[Forbid.BanType.FightPower_Partner] 		= "同伴排行榜",
	[Forbid.BanType.CardCollection_1] 			= "凌绝峰收集榜",
	[Forbid.BanType.HouseRank]					= "家园排行榜",
}

Forbid.szRankKey = 													-- 纯排行榜相关对应排行榜类型（决定是否控制排行榜的更新）
{
	["FightPower"] 		= Forbid.BanType.FightPowerRank,			
	["Level"]			= Forbid.BanType.LevelRank,					
	["kin"] 			= Forbid.BanType.KinRank,
	["FightPower_Faction"]   	 = Forbid.BanType.FightPower_Faction,
	["FightPower_Equip"]		 = Forbid.BanType.FightPower_Equip,
	["FightPower_Strengthen"] 	 = Forbid.BanType.FightPower_Strengthen,
	["FightPower_Stone"] 		 = Forbid.BanType.FightPower_Stone,
	["FightPower_Partner"]		 = Forbid.BanType.FightPower_Partner,
	["CardCollection_1"]		 = Forbid.BanType.CardCollection_1,
	["House"]					 = Forbid.BanType.HouseRank,
}

-----------------------------------------------------------------
--在要求清除玩家数据的时候用到（排行榜上清除数据）
Forbid.RankType =													
{
	[Forbid.BanType.LevelRank]			= "Level",					-- 纯排行榜类型（排行榜相同接口[pRank.RemoveByID(nPlayerId)]处理）
	[Forbid.BanType.FightPowerRank]		= "FightPower",
	[Forbid.BanType.KinRank]			= "kin",
	[Forbid.BanType.FightPower_Faction]	= "FightPower_Faction",
	[Forbid.BanType.FightPower_Equip]	= "FightPower_Equip",
	[Forbid.BanType.FightPower_Strengthen]	= "FightPower_Strengthen",
	[Forbid.BanType.FightPower_Stone]	= "FightPower_Stone",
	[Forbid.BanType.FightPower_Partner]	= "FightPower_Partner",
	[Forbid.BanType.CardCollection_1]	= "CardCollection_1",
	[Forbid.BanType.HouseRank]			= "House";
}

-- 手动为玩家更新排行榜数值的key(自然过期和手动解禁的情况下玩家登陆时（家族榜是每天0点会检查）会为玩家刷新数值，以便下次刷榜时进榜)
-- 服务器可用，客户端不可用
Forbid.RankUpdateVal = 
{
	[Forbid.BanType.LevelRank] = function (pPlayer)
		return "Level",pPlayer
	end,
	[Forbid.BanType.FightPowerRank] = function (pPlayer)
		return "FightPower",pPlayer
	end,
	[Forbid.BanType.FightPower_Faction] = function (pPlayer)
		return "FightPower",pPlayer
	end,
	[Forbid.BanType.FightPower_Equip] = function (pPlayer)
		local nCurFightPower = FightPower:CalcEquipFightPower(pPlayer);
		return "FightPower",pPlayer,"Equip",nCurFightPower
	end,
	[Forbid.BanType.FightPower_Strengthen] = function (pPlayer)
		local nCurFightPower = FightPower:CalcStrengthenFightPower(pPlayer);
		return "FightPower",pPlayer,"Strengthen",nCurFightPower
	end,
	[Forbid.BanType.FightPower_Stone] = function (pPlayer)
		local nCurFightPower = FightPower:CalcStoneFightPower(pPlayer);
		return "FightPower",pPlayer,"Stone",nCurFightPower
	end,
	[Forbid.BanType.FightPower_Partner] = function (pPlayer)
		local nCurFightPower = FightPower:CalcPartnerFightPower(pPlayer);
		return "FightPower",pPlayer,"Partner",nCurFightPower
	end,
	[Forbid.BanType.CardCollection_1] = function (pPlayer)
		local tbPosData = {}
		local nSaveGroup = CollectionSystem:GetSaveInfo(CollectionSystem.RANDOMFUBEN_ID)
		for i = 1, CollectionSystem.SAVE_LEN do
		    local nFlag = pPlayer.GetUserValue(nSaveGroup, i + CollectionSystem.DATA_SESSION)
		    table.insert(tbPosData, nFlag)
		end
		local nRare = CollectionSystem:GetAllRare(CollectionSystem.RANDOMFUBEN_ID, tbPosData)
		local nCompletion = CollectionSystem:GetCompletion(CollectionSystem.RANDOMFUBEN_ID)
		return "CardCollection_1",pPlayer.dwID,nCompletion + nRare, nRare
	end,
	[Forbid.BanType.HouseRank] = function (pPlayer)
		return "House", pPlayer, House:GetComfortValue(pPlayer);
	end
}


Forbid.ActRankType = 												-- 活动排行榜类型（特殊处理清除操作的类型）
{
	[Forbid.BanType.WuShenRank]			 = true,
	[Forbid.BanType.WuLinMengZhu] 		 = true,
}
-----------------------------------------------------------------

Forbid.IsClear = 
{
	NOCLEAR = 0,
	CLEAR 	= 1,
}
if not MODULE_GAMESERVER then
    Activity.DumplingBanquetAct = Activity.DumplingBanquetAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("DumplingBanquetAct") or Activity.DumplingBanquetAct

--活动npc信息
tbAct.tbNpcSetting = {
    nNpcTID = 3416; --摆放的npcid class可不填
    tbPos = { 5061, 4969, 63 }; --坐标
    nMapTID = 1004;
}

--提交给家族总管的通用材料
tbAct.tbMaterial =
{
	{nItemId = 10186; nScore = 1};
	{nItemId = 10187; nScore = 2};
	{nItemId = 10188; nScore = 3};
}

--活跃奖励
tbAct.tbActiveIndex = 
{
	[3] = {{"item", 10186, 1}},
	[4] = {{"item", 10187, 1}},
	[5] = {{"item", 10188, 1}},
}

--排名奖励
tbAct.tbRankInfo = 
{

}

--家族地图
tbAct.KinMapTemplateId = 1004

--叹号提醒过期时间
tbAct.nNotifyTime = 5 * 60;

--包饺子共4轮
tbAct.nRoundNum = 4;
--每轮时间

tbAct.nRoundTime = 60 * 2;

--每轮间隔等候时间
tbAct.nRoundWaitingTime = 10;
--倒计时5分钟后开启活动
tbAct.nWaitingTime = 60 * 5;

--npc喊话持续时间
tbAct.nNpcBubbleTalkTime = 20;

--吃饺子时间
tbAct.nEatDumplingTime = 60 * 5;

--食材图片atlas
tbAct.szIngredientAtlas = "UI/Atlas/Common/icon.prefab"
--食材图片sprite
tbAct.szIngredientName = {
	[3417] = "韭菜",
	[3418] = "鸡蛋",
	[3419] = "牛肉",
	[3420] = "芹菜",
	[3421] = "冬笋",
	[3422] = "香菇",
}	

tbAct.szIngredientSprite = {
	[3417] = "Ingredients_Leek",
	[3418] = "Ingredients_Egg",
	[3419] = "Ingredients_Beef",
	[3420] = "Ingredients_Celery",
	[3421] = "Ingredients_BambooShoot",
	[3422] = "Ingredients_Mushrooms",
}

--每人每日能获得奖励数量
tbAct.nMaxGetRewardTimes = 4;
--饺子NpcId
tbAct.nDumplingNpcId = 3423;

-- 当日饺子宴正确提交数量奖励
tbAct.tbEveryDayRankAward = 
{
	{8, {{"BasicExp", 120}, {"Coin", 100000}}},
	{5, {{"BasicExp", 90}, {"Coin", 60000}}},
	{1, {{"BasicExp", 60}, {"Coin", 30000}}},
}

-- 职位对应奖励序号
tbAct.tbCareerRewardIdx = {
	[Kin.Def.Career_Leader] = 1; -- 领袖
	[Kin.Def.Career_Master] = 1; -- 族长
	[Kin.Def.Career_ViceMaster] = 2; -- 副族长
	[Kin.Def.Career_Elder] = 2; -- 长老
	[Kin.Def.Career_Mascot] = 2; -- 家族宝贝
	[Kin.Def.Career_Commander] = 2; -- 指挥
	[Kin.Def.Career_Elite] = 3; -- 精英


	default = 3,	--默认
}

--家族排名奖励
tbAct.tbKinRewards = {
	[1] = {	--排名
		[1] = {	--序号
			{"Contrib", 100000},
		},
		[2] = {
			{"Contrib", 50000},
		},
		[3] = {
			{"Contrib", 30000},
		},

		tbRedBag = {	--红包
			209, 210,	--领袖，族长红包nEventId
		},
	},
	[2] = {
		[1] = {	--序号
			{"Contrib", 80000},
		},
		[2] = {
			{"Contrib", 30000},
		},
		[3] = {
			{"Contrib", 20000},
		},

		tbRedBag = {	--红包
			211, 212,	--领袖，族长红包nEventId
		},
	},
	[3] = {
		[1] = {	--序号
			{"Contrib", 50000},
		},
		[2] = {
			{"Contrib", 20000},
		},
		[3] = {
			{"Contrib", 10000},
		},

		tbRedBag = {	--红包
			213, 214,	--领袖，族长红包nEventId
		},
	},
}

--检查背包是否有可以提交的原料
function tbAct:CheckCanSubmit(pPlayer)
	for _, v in pairs(self.tbMaterial) do
		local nHave = pPlayer.GetItemCountInAllPos(v.nItemId);
		if nHave > 0 then
			return true
		end
	end
	return false, "大侠背包中并无原料！"
end

function tbAct:FormatAward(tbAward, nEndTime)
	local tbFormatAward = Lib:CopyTB(tbAward)
	for _, v in ipairs(tbFormatAward) do
		if v[1] and (v[1] == "item" or v[1] == "Item") then
			 v[4] = nEndTime
		end
	end
	return tbFormatAward
end

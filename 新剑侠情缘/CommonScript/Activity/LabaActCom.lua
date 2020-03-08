if not MODULE_GAMESERVER then
    Activity.LabaAct = Activity.LabaAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("LabaAct") or Activity.LabaAct
tbAct.Type_Fuben = 1
tbAct.Type_EveryTarge = 2
tbAct.Type_Gift = 3
tbAct.tbMaterial = 
{
	{szName = "薏米仁"};
	{szName = "桂圆"};
	{szName = "莲子"};
	{szName = "葡萄干"};
	{szName = "栗子"};
	{szName = "红枣"};
	{szName = "粳米"};
	{szName = "核桃仁"};
}
tbAct.tbFubenAward = {{"item", 7396, 12}}; 					-- 侠客岛副本奖励
tbAct.tbActiveAward = { 									-- 活跃奖励
	[3] = {{"item", 7395, 1}},
	[4] = {{"item", 7395, 1}},
	[5] = {{"item", 7395, 2}},
}
tbAct.tbAssistAward = {{"Contrib", 50}} 					-- 协助奖励
tbAct.tbCommitAward = {{"item", 7402, 1}, {"item", 7401, 1}} -- 提交奖励
tbAct.tbCommitCountAward = {								-- 提交次数奖励
	[5] = {{"item", 7403, 1}};
	[10] = {{"item", 7404, 1}};
}
tbAct.nMaxComposeCount = 2 									-- 每天可合成几份腊八粥
tbAct.nComposeReset = 4*60*60 								-- 合成次数每天0点重置(4*60*60则4点重置)
tbAct.nComposeNeed = 1 										-- 合成每种材料需要数量
tbAct.nCommitPer = 1 										-- 每次提交材料数量
tbAct.nLabaZhouItemId = 7399 								-- 腊八粥道具ID
tbAct.nMaxExchangeCount = 3 								-- 每天可交换的次数
tbAct.nExchangeReset = 4*60*60 								-- 交换次数每天0点重置(4*60*60则4点重置)
tbAct.nExchangeCost = 60 									-- 每次交换消耗元宝
tbAct.nJoinLevel = 20 										-- 参与等级
tbAct.nAssistImityLevel = 10 								-- 协助亲密度
tbAct.nMaxAssistCount = 3 									-- 每天可协助次数
tbAct.nAssistReset = 4*60*60 								-- 协助次数每天0点重置(4*60*60则4点重置)
tbAct.nLabaMenuItemId = 7398 								-- 腊八粥食材谱
tbAct.tbDailyGiftAward = 
{
	{{"item", 7397, 1}}, 													-- 1元礼包
	{{"item", 7397, 2}}, 													-- 3元礼包
	{{"item", 7397, 3}}, 													-- 6元礼包
}

function tbAct:FormatAward(tbAward, nEndTime)
	if not MODULE_GAMESERVER or not Activity:__IsActInProcessByType("LabaAct") or not nEndTime then
		return tbAward
	end
	local tbFormatAward = Lib:CopyTB(tbAward or {})
    for _, v in ipairs(tbFormatAward) do
        if v[1] == "item" or v[1] == "Item" then
            v[4] = nEndTime
        end
    end
    return tbFormatAward
end

function tbAct:FormatCommitAward(nCount, tbCountAward)
	local tbAward = Lib:CopyTB(tbCountAward or self.tbCommitAward)
	for _, v in pairs(tbAward) do
		 if v[1] == "item" or v[1] == "Item" then
       		v[3] = v[3] * nCount
        end
	end
	return tbAward
end

function tbAct:CheckPlayer(pPlayer)
	if pPlayer.nLevel < self.nJoinLevel then
        return false, string.format("请先将等级提升至%d", self.nJoinLevel)
	end
	return true
end
if not MODULE_GAMESERVER then
    Activity.MaterialCollectAct = Activity.MaterialCollectAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("MaterialCollectAct") or Activity.MaterialCollectAct

tbAct.nJoinLevel = 20
-- 酿酒材料
tbAct.tbMaterial = 
{
	{nItemId = 9836; nScore = 2};
	{nItemId = 9837; nScore = 3};
	{nItemId = 9838; nScore = 5};
}
tbAct.nEnterNpcTId = 3287
tbAct.nEnterNpcMapTID = 8011
tbAct.nEnterNpcPosX = 4412
tbAct.nEnterNpcPosY = 17661
-- 阶段奖励
tbAct.tbProcessAward = 
{
	{nScore = 10000; nAwardCount = 5; tbAward = {{"item", 9856, 1}}, nNpcTID = 3288, nShowItemId = 9856};
	{nScore = 18000; nAwardCount = 5; tbAward = {{"item", 7670, 1}}, nNpcTID = 3289, nShowItemId = 7670};
}
tbAct.nChangeScore = 5 					-- 自动兑换道具积分
tbAct.nChangeItemId = 9839 				-- 自动兑换的道具ID
-- 活跃奖励
tbAct.tbActiveIndex = 
{
	[3] = {{"item", 9836, 1}},
	[4] = {{"item", 9837, 1}},
	[5] = {{"item", 9838, 1}};
}
-- 购买礼包奖励
tbAct.tbDailyGiftVote = 
{
	[Recharge.DAILY_GIFT_TYPE.YUAN_1] = {{"item", 9836, 1}},
	[Recharge.DAILY_GIFT_TYPE.YUAN_3] = {{"item", 9837, 1}},
	[Recharge.DAILY_GIFT_TYPE.YUAN_6] = {{"item", 9838, 1}},
}
 
tbAct.nCollectBoxItemId = 9840 				-- 酒箱id

-- 酒
tbAct.tbCollect = 
{
	{nId = 1, szName = "踏歌行", nRandom = 1, nLevel = 3, nScore = 6, nIconId = 9841, nShowItemId = 9841, szKinMsg = "[FFFE0D]%s[-]打开泥封，顿时满室生香，发现这坛看似平平无奇的酒竟是大名鼎鼎的[FFFE0D]%s[-]！"};
	{nId = 2, szName = "一心人", nRandom = 1, nLevel = 3, nScore = 6, nIconId = 9842, nShowItemId = 9842, szKinMsg = "[FFFE0D]%s[-]打开泥封，顿时满室生香，发现这坛看似平平无奇的酒竟是大名鼎鼎的[FFFE0D]%s[-]！"};
	{nId = 3, szName = "相思门", nRandom = 1, nLevel = 3, nScore = 6, nIconId = 9843, nShowItemId = 9843, szKinMsg = "[FFFE0D]%s[-]打开泥封，顿时满室生香，发现这坛看似平平无奇的酒竟是大名鼎鼎的[FFFE0D]%s[-]！"};
	{nId = 4, szName = "梦言欢", nRandom = 3, nLevel = 2, nScore = 3, nIconId = 9844, nShowItemId = 9844 };
	{nId = 5, szName = "伤心泪", nRandom = 3, nLevel = 2, nScore = 3, nIconId = 9845, nShowItemId = 9845 };
	{nId = 6, szName = "同心饮", nRandom = 3, nLevel = 2, nScore = 3, nIconId = 9846, nShowItemId = 9846 };
	{nId = 7, szName = "初见青", nRandom = 6, nLevel = 1, nScore = 1, nIconId = 9847, nShowItemId = 9847 };
	{nId = 8, szName = "醉春风", nRandom = 6, nLevel = 1, nScore = 1, nIconId = 9848, nShowItemId = 9848 };
	{nId = 9, szName = "陌上花", nRandom = 6, nLevel = 1, nScore = 1, nIconId = 9849, nShowItemId = 9849 };
}

tbAct.tbCollectFullAward = {{"item", 9857, 1}} 			-- 集满奖励
tbAct.nCollectFullShowItem = 9857 						-- 未集满状态点击展示用的id

-- 排名奖励
tbAct.tbRankInfo = 
{
	{1, {{"Item", 9858, 1}}},
	{5, {{"Item", 9859, 1}}},
	{10, {{"Item", 9860, 1}}},
	{20, {{"Item", 9861, 1}}},
	{50, {{"Item", 9862, 1}}},
	{200, {{"Item", 9863, 1}}},
	{500, {{"Item", 9864, 1}}},
}
-- 展示排名
tbAct.nShowRank = 10
tbAct.nServerMaxScore = 20000
tbAct.tbRankAward = {}

tbAct.szMsgTitle = "佳酿收集"

tbAct.szIntroMsg = [[
[FFFE0D]佳酿收集活动开始了！[-]
[FFFE0D]活动时间[-]：[c8ff00]2018年11月9日4点-2018年11月26日4点[-]
[FFFE0D]参与等级：[-]20级
值此江湖盛典即将来临之际，武林中众侠士同为盛典筹备美酒，岂不美哉？
[FFFE0D]每日活跃 获得原料[-]
活动期间大侠活跃度达到[FFFE0D]60[-]、[FFFE0D]80[-]、[FFFE0D]100[-]，打开对应的[FFFE0D]活跃宝箱[-]，或者领取[FFFE0D]每日礼包[-]都会获得指定的[11adf6][url=openwnd:泉水, ItemTips, "Item", nil, 9836][-]、[11adf6][url=openwnd:五谷, ItemTips, "Item", nil, 9837][-]或者[11adf6][url=openwnd:酒曲, ItemTips, "Item", nil, 9838][-]。
[FFFE0D]捐献原料 全服齐力[-]
活动期间忘忧酒馆庭院会摆放[FFFE0D][url=pos:盛典酒坛, 8011, 4412, 17661][-]，玩家可将自己的背包中的[11adf6][url=openwnd:泉水, ItemTips, "Item", nil, 9836][-]、[11adf6][url=openwnd:五谷, ItemTips, "Item", nil, 9837][-]和[11adf6][url=openwnd:酒曲, ItemTips, "Item", nil, 9838][-]投放捐献到酒坛中，可使全服的总积分分别增加[FFFE0D]2、3、5[-]点，当本服总积分达到[FFFE0D]10000[-]时，会在之前捐献过原料的玩家中随机抽取[FFFE0D]5名[-]玩家每人发放一个[ff8f06][url=openwnd:黄金图谱·防具任选宝箱, ItemTips, "Item", nil, 9856][-]；当本服总积分达到[FFFE0D]18000[-]时，还会在之前捐献过材料的玩家中抽取[FFFE0D]5名[-]玩家每人发放一个[ff578c][url=openwnd:5级初级魂石任选箱, ItemTips, "Item", nil, 7670][-]！
[FFFE0D]收集满箱 领取奖励[-]
大侠捐献原料每获得[FFFE0D]5积分[-]，相应的也会获得个人积分[FFFE0D]5积分[-]，每拥有[FFFE0D]5积分[-]会自动帮大侠兑换为一坛[aa62fc][url=openwnd:未启封的酒, ItemTips, "Item", nil, 9839][-]，启封后可从[FFFE0D]踏歌行、一心人、相思门、梦言欢、伤心泪、同心饮、初见青、醉春风、陌上花[-]以上[FFFE0D]9种酒[-]中随机产生1种，并自动放入[ff8f06][url=openwnd:盛典酒箱, ItemTips, "Item", nil, 9840][-]中，当大侠收集满所有[FFFE0D]9种酒[-]之后，可以打开隐藏在酒箱中的奖励，获得6个[aa62fc][url=openwnd:紫水晶, ItemTips, "Item", nil, 224][-]！
[FFFE0D]价值排行 排名领奖[-]
大侠收集的每种酒均会有对应的[FFFE0D]价值[-]，最终活动结束时（[ff578c]2018年11月26日3:59[-]）按照大侠们收集到的美酒的总价值的排行发放奖励，奖励如下：
第1名----------------------------------100个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第2至第5名-----------------------------58个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第6至第10名----------------------------38个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第11至第20名---------------------------28个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第21至第50名---------------------------18个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第51至第200名--------------------------8个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第201至第500名-------------------------3个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
此外第1名还会获得[ff8f06][url=openwnd:称号·酒剑仙, ItemTips, "Item", nil, 9865][-]
第2至第5名会获得[ff578c][url=openwnd:称号·酒中君子, ItemTips, "Item", nil, 9866][-]
]]
tbAct.szIntroNewMsgKey = "MaterialCollectIntro"
tbAct.szRankAwardNewMsgKey = "MaterialCollectRankAward"
tbAct.szRankAwardMsgTitle = "佳酿收集排行"
tbAct.szRankAwardMsgTime = 60 * 60 * 24 			-- 过期时间

tbAct.nMaterialCollextItemId = 9839 				-- 未启封道具id

for _, v in ipairs(tbAct.tbRankInfo) do
	for nRank = v[1], #tbAct.tbRankAward + 1, -1 do
		tbAct.tbRankAward[nRank] = v[2]
	end
end

for _, v in ipairs(tbAct.tbCollect) do
	tbAct.nCollectRandom = (tbAct.nCollectRandom or 0) + v.nRandom
end

tbAct.tbLeaveMapCloseUi = {"MaterialBoxPanel", "MaterialCollectPanel"}

function tbAct:CheckJoin(pPlayer)
	if pPlayer.nLevel < self.nJoinLevel then
       return false, "参与等级不足"
	end
	return true
end

function tbAct:GetMaterialData(pPlayer)
	local tbPlayerData = self.tbMaterialData
	if MODULE_GAMESERVER then
		tbPlayerData = self:GetDataFromPlayer(pPlayer.dwID)
	end
	return tbPlayerData or {}
end

function tbAct:GetMaterialCollect(pPlayer)
	local tbPlayerData = self:GetMaterialData(pPlayer)
	return tbPlayerData.tbCollect or {}
end

function tbAct:GetMaterialCount(pPlayer)
	local nCount = 0
	local tbCollect = self:GetMaterialCollect(pPlayer)
	for _, nC in pairs(tbCollect) do
		nCount = nCount + nC
	end
	return nCount
end

function tbAct:GetMaterialValueKind(pPlayer)
	local tbCollect = self:GetMaterialCollect(pPlayer)
	return Lib:CountTB(tbCollect)
end

function tbAct:GetMaterialValue(pPlayer)
	local tbCollect = self:GetMaterialCollect(pPlayer)
	local nValue = 0
	for _, v in ipairs(self.tbCollect) do
		nValue = nValue + (tbCollect[v.nId] or 0) * v.nScore
	end
	return nValue
end

function tbAct:CheckCanDonate(pPlayer)
	local bRet, szMsg = self:CheckJoin(pPlayer)
	if not bRet then
		return false, szMsg
	end
	for _, v in ipairs(self.tbMaterial) do
		local nHave = pPlayer.GetItemCountInAllPos(v.nItemId);
		if nHave > 0 then
			return true
		end
	end
	return false, "大侠背包中并无酿酒原料！"
end

function tbAct:CheckCollectAward(pPlayer)
	local bRet, szMsg = self:CheckJoin(pPlayer)
	if not bRet then
		return false, szMsg
	end
	local tbCollect = self:GetMaterialCollect(pPlayer)
	for _, v in ipairs(self.tbCollect) do
		if not tbCollect[v.nId] or tbCollect[v.nId] < 1 then
			return false, "未集满"
		end
	end
	local tbPlayerData = self:GetMaterialData(pPlayer)
	if tbPlayerData.bCollectAward then
		return false, "奖励已经领取过了！"
	end
	return true
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

function tbAct:GetRankAward(nRank)
	return self.tbRankAward[nRank]
end
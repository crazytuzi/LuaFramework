if not MODULE_GAMESERVER then
	Activity.AnniversaryJiYuAct = Activity.AnniversaryJiYuAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("AnniversaryJiYuAct") or Activity.AnniversaryJiYuAct

tbAct.LEVEL_LIMIT = 20		--参与等级限制
tbAct.JIYU_MAX_LEN = 12		--寄语长度限制
tbAct.SCORE_ADD = 1		--点赞加的愿力值
tbAct.MSG_TIME_OUT 	= 180	--感叹号的有效时长

tbAct.CHANGE_TIMES_PER = 2 	--每天允许修改的次数

tbAct.NEW_DAY_OFFSET = 4 * 60 * 60	--新一天的开始时间

tbAct.THUMBSUP_ITEM_ID = 10836	--点赞消耗的道具TID
tbAct.tbMaterialItems = {		--酿酒材料的道具TID
	[1] = 10832,
	[2] = 10833,
	[3] = 10834,
}

tbAct.tbDrinkItem = { 			--美酒道具TID
	[1] = 10835,
	[2] = 10884,
	[3] = 10885,
}
tbAct.tbDrinkAward = {			--喝酒的奖励（不包含孔明灯）
	[10835] = {{"Contrib", 200}, {"BasicExp", 30}},
	[10884] = {{"Contrib", 500}, {"BasicExp", 45}},
	[10885] = {{"Contrib", 1000}, {"BasicExp", 60}},
}

tbAct.tbSubmitMaterialAward = {
	[10835] = 10837,	--提交一个获得的孔明灯ID
	[10884] = 10838,	--提交两个获得的孔明灯ID
	[10885] = 10839,	--提交三个（及以上）获得的孔明灯ID
}
--放飞孔明灯获得彩笺的概率(和tbSubmitMaterialAward的道具TID相对应)
tbAct.tbFlyKongmingLanternAward = {
	--{大号概率, 小号概率}
	[10837] = {0.4, 0.02},
	[10838] = {0.7, 0.03},
	[10839] = {1, 0.05},
}
--孔明灯道具对应的NPC模板ID
tbAct.tbKongmingLanternNpc = {
	[10837] = 3701,
	[10838] = 3702,
	[10839] = 3703,
}
--放飞孔明灯加的愿力值
tbAct.tbFlyScoreAdd = {
	[10837] = 2,
	[10838] = 3,
	[10839] = 5,
}

tbAct.MODIFY_COST = 200				--修改内容花费的元宝

tbAct.WRITE_JIYU_NPC_ID = 1666		--填写寄语的NPC的模板ID
tbAct.tbWriteJiYuPos = { 15, 13342, 7447}	--NPC位置
tbAct.DRINK_ALTAR_NPC_ID = 3704 	--酒坛NPC的模板ID
tbAct.tbAltarPos = { 15, 8482, 16623}	--酒坛NPC的位置{nMapId, nX, nY}

tbAct.DISTANCE_RANGE = 1000				--距离NPC的范围限制

tbAct.tbActiveTime = {
	[1] = "19:00",	--开始时间
	[2] = "19:15",	--结束时间
}

tbAct.THUMBSUP_PER = 100000	--每天给同一个人点赞的最大次数
tbAct.THUMBSUP_EVERYDAY = 1000000 --每天一共点赞的最大次数

--活跃度奖励
tbAct.tbEverydayTargetAward = {
	[2] = tbAct.tbMaterialItems[1],
	[3] = tbAct.tbMaterialItems[2],
	[4] = tbAct.THUMBSUP_ITEM_ID,
	[5] = tbAct.THUMBSUP_ITEM_ID,
}
--活跃度奖励是否有小号限制
tbAct.tbEverydayTargetLimit = {
	[4] = true,
	[5] = true,
}

tbAct.tbEverydayTargetAwardProbility = {
	--[nIdx] = {大号概率, 小号概率}
	[4] = {1, 0.05},
	[5] = {1, 0.05},
}

tbAct.tbDailyGiftAward = {
	[1] = tbAct.tbMaterialItems[3],
	[2] = tbAct.THUMBSUP_ITEM_ID,
	[3] = tbAct.THUMBSUP_ITEM_ID,
}
--寄语模板
tbAct.tbJiYuTemplate = {
	--三句话用中文逗号隔开
	[1] = "遇到一个可爱的家族，一群可爱的人，谢谢你们的一路陪伴",
	[2] = "剑侠三载，一路有你，往后也有你",
	[3] = "我收获了兄弟情，收获了家族情谊，也收获了爱情",
}

--最终排名奖励
tbAct.tbRankAward = {
	{1,		{{"item", 10886, 1}}},				--第一名
	{5,		{{"item", 10887, 1}}},				--二三名
	{10,	{{"item", 10888, 1}}},				--四到十名
	{20,	{{"item", 10889, 1}}},
	{50,	{{"item", 10890, 1}}},
	{100,	{{"item", 10891, 1}}},
}

function tbAct:CheckData(tbData)
	if tbData.nDataDay and tbData.nDataDay >= Lib:GetLocalDay() then
		return
	end
	tbData.nDataDay = Lib:GetLocalDay()
	tbData.nThumbsUpCount = 0
	tbData.tbThumbsUpList = {}
end

function tbAct:CheckJiYuLimit(szJiYu)
	local tbJiYu = Lib:SplitStr(szJiYu, "，")
	for i = 1, 3 do
		local szJiYu = tbJiYu[i] or ""
		--长度限制检查
		local nLen = Lib:Utf8Len(szJiYu)
		if nLen > self.JIYU_MAX_LEN then
			return false, string.format("寄语太长啦，每句话不能超过[FFFE0D]%d[-]个字符，请重新输入！", self.JIYU_MAX_LEN)
		elseif nLen == 0 then
			return false, "寄语内容不能为空！"
		end
		--违禁词检查
		if ReplaceLimitWords(szJiYu) then
			return false, "寄语中包含违禁词，请重新输入！"
		end
	end
	return true
end
--随机模板寄语
function tbAct:RandomTemplateJiYu()
	local nTemplateNum = #self.tbJiYuTemplate
	local nRandomIdx = MathRandom(1, nTemplateNum)
	if self.nJiYuTemplateIdx then
		while self.nJiYuTemplateIdx == nRandomIdx do
			nRandomIdx = MathRandom(1, nTemplateNum)
		end
	end
	self.nJiYuTemplateIdx = nRandomIdx
	return self.tbJiYuTemplate[nRandomIdx]
end

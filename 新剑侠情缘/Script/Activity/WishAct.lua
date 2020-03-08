-- local tbWishAct = Activity:GetUiSetting("WishAct")


-- tbWishAct.nShowLevel = 1
-- tbWishAct.szTitle    = "腊八节活动";
-- tbWishAct.nBottomAnchor = -50;

-- tbWishAct.FuncContent = function (tbData)
--         local tbTime1 = os.date("*t", tbData.nStartTime)
--         local tbTime2 = os.date("*t", tbData.nEndTime)
--         local szContent = "\n    诸位侠士，如今江湖百家争鸣，武林鼎盛，实在令人欣喜，时值腊八佳节，理应普天同庆！只是近日不仅有些宵小之徒出没武林，更有传闻侠客岛重现江湖，还请诸位小心。"
--         return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
-- end

-- tbWishAct.tbSubInfo1 = 
-- {
-- 	{szType = "Item2", szInfo = "活动一     腊八佳节，树下许愿\n     2017年[FFFE0D]1月3日-5日[-]，家族中的侠士[FFFE0D]可许下自己精心编织的愿望[-]，许愿后获得奖励，还可以为其他侠士的愿望点赞，活动结束时点赞数最多的侠士还将获得限时称号哦。[FFFE0D]许愿仅限一次[-]，不可更改，要仔细想好自己的愿望哦！", szBtnText = "前去许愿",  szBtnTrap = "[url=openwnd:test, WishingPanel]" },
-- }

-- tbWishAct.tbSubInfo2 = 
-- {
-- 	{szType = "Item2", szInfo = "活动二     腊八佳节，家族恶贼\n     2017年[FFFE0D]1月3日-5日[-]，腊八将至，家族中[FFFE0D]每日特定时间[-]却忽现宵小之徒，盗取宝物，需组成[FFFE0D]2人以上[-]队伍将之剿灭。传闻赏善罚恶使将于烤火时登门拜访，相邀前往侠客岛，神秘事件接连不断，江湖一时风起云涌，令人不安。"},
-- 	{szType = "Item2", szInfo = "活动三     腊八佳节，赏善罚恶\n     活动期间，击败族中盗贼有概率获得侠客岛线索，每日最多一条，[FFFE0D]2017年1月5日19点30-23点30[-]，族长、副族长可于期间找[FFFE0D]家族总管[-]开启侠客岛，[FFFE0D]家族成员均可参与[-]，一探究竟！[FFFE0D]线索越多，奖励越丰厚哦！[-]", szBtnText = "去找总管",  szBtnTrap = "[url=npc:家族总管, 266, 1004]"},
-- 	{szType = "Item2", szInfo = "活动四     腊八佳节，喝粥烤火\n     2017年[FFFE0D]1月5日[-]，急如风将于凌晨的邮信给诸位侠士捎来腊八粥，服用后获得[FFFE0D]家族烤火额外经验加成[-]的状态，状态[FFFE0D]持续23小时[-]，要注意的是，腊八粥保质期有限，[FFFE0D]当天[-]必须领取，否则也是会过期的哦。"},
	
-- }
-- tbWishAct.FuncSubInfo = function (tbData)
-- 	local tbSubInfo = {}
-- 	for _, tbInfo in ipairs(tbWishAct.tbSubInfo1) do
-- 		table.insert(tbSubInfo, tbInfo)
-- 	end
-- 	if GetTime() < Activity.WishAct.nTrueEndTime then
-- 		for _, tbInfo in ipairs(tbWishAct.tbSubInfo2) do
-- 			table.insert(tbSubInfo, tbInfo)
-- 		end
-- 	end 
-- 	return tbSubInfo
-- end
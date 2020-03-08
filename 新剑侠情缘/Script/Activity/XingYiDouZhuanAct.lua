
local tbAct      = Activity:GetUiSetting("XingYiDouZhuanAct")
tbAct.nShowLevel = 40
tbAct.szTitle    = "星移斗转"
tbAct.szUiName   = "Normal"
tbAct.szContent  = [[
[FFFE0D]星移斗转活动开始了！[-]
[FFFE0D]活动时间：[-][c8ff00]%s~%s[-]
[FFFE0D]参与等级：[-]40级
山河破碎，国事艰难。方今生死存亡，非常之时当行非常之事。武林盟主独孤剑特颁[ff8f06][url=openwnd:钧天七曜令, ItemTips, "Item", nil, 10445][-]，望诸位大侠抛除门户之见，谋求武学更快发展，壮大抗金力量。
活动期间玩家均可凭此令牌[FFFE0D]无任何消耗[-]、[FFFE0D]无须等待冷却时间[-]在[FFFE0D]主城[-]以及[FFFE0D]野外地图安全区[-]转为[FFFE0D]任一门派[-]。
活动开始后，将[FFFE0D]重置武神殿[-]。重置后，诸位大侠需重新挑战，初次达到某些排名会获取额外奖励。
[FFFE0D]3月4日晚上20:30-21:00[-]和[FFFE0D]3月6日下午16：30-17：00[-]开启的战场，在后营可打开背包使用[ff8f06][url=openwnd:钧天七曜令, ItemTips, "Item", nil, 10445][-]，届时会有[ff8f06]星移[-]标记，望诸位大侠尽情体验各门武功，在实战中提升自己。
注：活动结束时将保留玩家最终的门派状态。
]]
tbAct.FnCustomData = function (szKey, tbData)
    local szStart = Lib:TimeDesc7(tbData.nStartTime)
    local szEnd   = Lib:TimeDesc7(tbData.nEndTime)
    return {string.format(tbAct.szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
end
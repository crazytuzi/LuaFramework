
local tbAct      = Activity:GetUiSetting("YuanXiaoDengMiAct")
tbAct.nShowLevel = 20
tbAct.szTitle    = "元宵节活动"
tbAct.szUiName   = "Normal"
tbAct.szContent  = [[
[FFFE0D]元宵节活动开始了！[-]
[FFFE0D]活动时间：[-][c8ff00]%s~%s[-]
[FFFE0D]参与等级：[-]20级
[FFFE0D]看花灯 猜灯谜[-]
活动期间每天晚上[FFFE0D]19:00、20:15、21:30[-]在[FFFE0D]临安城、襄阳城[-]中均会亮起大量花灯，各位大侠可以点击花灯进行答题，答对问题会获得一份奖励。
[FFFE0D]团圆夜 吃元宵[-]
活动期间每晚每轮花灯结束后家族总管会根据本家族成员的答题情况在家族属地内准备元宵，诸位大侠请届时回家享用暖心元宵！
]]
tbAct.FnCustomData = function (szKey, tbData)
    local szStart = Lib:TimeDesc7(tbData.nStartTime)
    local szEnd   = Lib:TimeDesc7(tbData.nEndTime)
    return {string.format(tbAct.szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
end
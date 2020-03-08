local tbAct    = Activity:GetUiSetting("DongZhiAct")
tbAct.nShowLevel = 20
tbAct.szTitle    = "冬至温暖盛典"
tbAct.FuncContent = function (tbData)
    local szStart   = Lib:TimeDesc11(tbData.nStartTime)
    local szContent = [[
        冬至活动即将开启，诸位鏖战武林已有不少时日，劳苦功高，万老板与少当家商议过后，希望让诸位能够稍事休息，小小心意，还望诸位侠士能够享受一个轻松写意、温暖安逸的冬至佳节！

[FFFE0D]活动一      冬日烤火，盛典将至[-]
        [FFFE0D]%s[-]家族烤火时，将增开[FFFE0D]家族盛典[-]，侠士在当天开启的盛典宝箱中，不仅可以获得常规的盛典奖励，还将有一定机会获得额外的[FFFE0D]饺子[-]，每份[FFFE0D]饺子[-]可用于领取8小时2.5倍离线经验，减轻负担，离线也能轻松得经验哦！

[FFFE0D]活动二     冬日南瓜糕，轻松将至[-]
        [FFFE0D]%s[-]，少侠每在商会任务中缴纳一件物品，即可获得一份南瓜糕，使用南瓜糕后，可 [FFFE0D]增加当日活跃度10点[-]，南瓜糕保质期仅有三日，要注意尽快食用哦！

[FFFE0D]活动三     冬日汤圆，甜蜜将至[-]
        [FFFE0D]%s[-]，少侠每在商会任务中缴纳一件物品，即可获得一枚汤圆，可用于[FFFE0D]完美奖励完美找回[-]，每次完美找回仅需消耗一颗汤圆，无需元宝，香糯可口的汤圆保质期仅有一日，要注意前往福利界面进行[FFFE0D]完美找回[-]哦！
注意：可找回所有完美找回奖励，但银两找回不可使用汤圆。
]]
    return string.format(szContent, szStart, szStart, szStart)
end
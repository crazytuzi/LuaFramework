local tbUi = Ui:CreateClass("NewInfo_Qixi")

tbUi.szContent = [[
[FFFE0D]七夕节日活动开始了！[-]
    七夕，原名为乞巧节。七夕乞巧，这个节日起源于汉代，东晋葛洪的《西京杂记》有“汉彩女常以七月七日穿七孔针于开襟楼，人俱习之”的记载，这便是我们于古代文献中所见到的最早的关于乞巧的记载。后被赋予“牛郎织女”的传说使其成为极具浪漫色彩的关于爱情的节日之一。

[FFFE0D]活动时间[-]：%s~%s
[FFFE0D]参加条件[-]：等级达到[FFFE0D]%d级[-]

[FFFE0D]活动介绍[-]：
1、花酒诗剑
    通过领取[FFFE0D]每日目标[-]奖励，或进行[FFFE0D]家族贡献[-]，能获得道具“七菱花”、“七味酒”、“七言古诗”及“七寸小剑”，分别合成能获得道具“花与酒”及“诗与剑”。
亲密度[FFFE0D]%d级[-]以上的[FFFE0D]男女[-]好友组队，可当面使用将礼物赠送给对方，对方相应获得道具“[FFFE0D]「礼物」花与酒[-]”或“[FFFE0D]「礼物」诗与剑[-]”，过程中能获得[FFFE0D]亲密度[-]奖励。

    [FFFE0D]注意[-]：
    每日通过家族贡献最多获得[FFFE0D]5个[-]活动道具。
    送礼和收礼次数没有限制。
    活动结束后，道具还可以合成与赠送，但无法获得亲密度奖励。

2、玄香拜星
    当拥有“[FFFE0D]花与酒[-]”及“[FFFE0D]诗与剑[-]”（赠送的[FFFE0D]礼物[-]也可）后，可到[FFFE0D]襄阳[-]找[FFFE0D]纳兰真[-]换取“[FFFE0D]七色玄香[-]”。亲密度[FFFE0D]%d级[-]以上的男女好友[FFFE0D]单独组队[-]，使用七色玄香，一起到随机的地点燃起玄香拜星，完成后能获得大量经验及道具奖励。

    每天可以进行[FFFE0D]%d次[-]玄香拜星，活动期间次数可以一直[FFFE0D]累计[-]。
    每天可以[FFFE0D]协助[-]他人完成[FFFE0D]%d次[-]玄香拜星，活动期间次数可以一直[FFFE0D]累计[-]。
    活动结束后，七色玄香将失效，无法使用。
]]

function tbUi:OnOpen(tbData)
    local szActKey     = Activity:GetActKeyName(tbData[1])
    local _, tbActData = Activity:GetActUiSetting(szActKey)
    local szStartTime  = Lib:TimeDesc10(tbActData.nStartTime)
    local szEndTime    = Lib:TimeDesc10(tbActData.nEndTime)
    local tbDef        = Activity.Qixi.Def
    local szContent    = string.format(self.szContent, szStartTime, szEndTime, tbDef.OPEN_LEVEL, tbDef.IMITYLEVEL, tbDef.IMITYLEVEL, tbDef.CHANGE_ITEM_TIMES, tbDef.HELP_AWARD_TIMES)
    self.Content2:SetLinkText(szContent)

    local tbTextSize = self.pPanel:Label_GetPrintSize("Content2")
    local tbSize = self.pPanel:Widget_GetSize("datagroup2");
    self.pPanel:Widget_SetSize("datagroup2", tbSize.x, 50 + tbTextSize.y);
    self.pPanel:DragScrollViewGoTop("datagroup2");
    self.pPanel:UpdateDragScrollView("datagroup2");

    self.nLastOpenTime = self.nLastOpenTime or 1
    if (GetTime() - self.nLastOpenTime > 60) or (Lib:GetLocalDay() ~= Lib:GetLocalDay(self.nLastOpenTime)) then
        RemoteServer.TryUpdateQixiData()
        self.nLastOpenTime = GetTime()
    end
end

function tbUi:GetMsgContent()
    local szMsg = "还可玄香拜星次数：%d/%d\n还可[FFFE0D]协助[-]拜星次数：%d/%d"
    local Def = Activity.Qixi.Def
    local nOpenDay = Lib:GetLocalDay() - Lib:GetLocalDay(Def.ACTIVITY_TIME_BEGIN) + 1
    local nGroup = Def.SAVE_GROUP
    local nBaixing = me.GetUserValue(nGroup, Def.CHANGE_ITEM_TIMES_KEY)
    local nHelp = me.GetUserValue(nGroup, Def.HELP_AWARD_TIMES_KEY)
    szMsg = string.format(szMsg, nBaixing, nOpenDay*Def.CHANGE_ITEM_TIMES, nHelp, nOpenDay*Def.HELP_AWARD_TIMES)
    return szMsg
end

tbUi.tbOnClick = {
    BtnNormal = function (self)
        local szMsg = self:GetMsgContent()
        Ui:OpenWindow("MessageBox", szMsg, {{function() end}}, {"确定"}, nil, nil, true)
    end,
}
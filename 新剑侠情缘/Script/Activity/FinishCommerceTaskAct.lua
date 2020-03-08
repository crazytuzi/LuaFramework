local tbAct    = Activity:GetUiSetting("FinishCommerceTaskAct")
tbAct.nShowLevel = 0
tbAct.szTitle    = "残损的票券"
tbAct.szUiName   = "Normal"
tbAct.szContent  = [[
[FFFE0D]神秘的残损票券陡现江湖，疑云丛生！[-]

[FFFE0D]活动时间：[-]%s~%s
	近日诸位大侠可曾发现，[FFFE0D]全部完成[-]万金财委托的[FFFE0D]商会任务[-]时会获得一个额外的[aa62fc][url=openwnd:残损的票券, ItemTips, "Item", nil, 8396][-]，但却无准确消息说明这物品到底有何用处，可谓疑点重重！
	仔细分析，疑点有三：
[FFFE0D]疑点一：字样[-]
    [aa62fc][url=openwnd:残损的票券, ItemTips, "Item", nil, 8396][-]虽然残破，但是细细辨认不难发现其上所书乃一个[FFFE0D]礼[-]字，收集多份莫非可以得到礼品？还是多多收集为上！
[FFFE0D]疑点二：来源[-]
	此券发放自万金财之手，众所周知万金财乃当世陶朱、猗顿，善经商者必长目飞耳消息灵通，想必此物最后能兑换的礼物并非凡品，定是大为新奇之物。
[FFFE0D]疑点三：时机[-]	
	此券来的时间也甚为蹊跷，近日江湖波云诡谲暗流涌动，盛传将有新资料片入世，这票券估计与资料片大有关联，说不准其中藏有不为人知的秘密！
	综上所述，真相只有一个，那就是此[aa62fc][url=openwnd:残损的票券, ItemTips, "Item", nil, 8396][-]收集多份之后，新资料片来临之时，能够换得新奇礼物，诸位大侠速去收集吧！
]]
tbAct.FnCustomData = function (szKey, tbData)
        local szStart = Lib:TimeDesc10(tbData.nStartTime)
        local szEnd   = Lib:TimeDesc10(tbData.nEndTime)
        return {string.format(tbAct.szContent, szStart, szEnd, tbAct.nShowLevel)}
end

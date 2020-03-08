-- local tbAct    = Activity:GetUiSetting("ChouJiang")
-- tbAct.nShowLevel = 20
-- tbAct.szTitle    = "迎国庆幸运抽奖"
-- tbAct.szUiName   = "Normal"
-- tbAct.szContent  = [[
-- [FFFE0D]迎国庆幸运大抽奖活动[-]

-- [FFFE0D]活动时间：[-]%s~%s
-- [FFFE0D]参与等级：[-]等级达到%d级
--     为了迎接国庆佳节，特开启幸运大抽奖活动，重磅奖励回馈广大玩家。
-- [FFFE0D]1、幸运奖券[-]
--     活动期间每日活跃达到[FFFE0D]60[-]以后，可以找[FFFE0D]襄阳的纳兰真[-]领取一张“[FFFE0D]迎国庆幸运奖券[-]”，使用后可以获得参与当日抽奖的机会。
--     奖券有效期截止时间为每日[FFFE0D]22:00[-]抽奖时，请玩家尽快使用。
--     每日22:00抽奖以后不能领取奖券。
--     领取奖券的重置时间为每日4:00。

-- [FFFE0D]2、每日抽奖[-]
--     活动期间，每日22:00会从所有使用奖券的玩家中产生各种奖项，奖励丰厚不可错过。

-- [FFFE0D]3、抽奖奖励[-]
--     [FFFE0D]一等奖：[-]共1名，获得[11adf6][url=openwnd:随机5级同伴技能书, ItemTips, "Item", nil, 2161][-]
--     [FFFE0D]二等奖：[-]共10名，可能获得[11adf6][url=openwnd:随机4级同伴技能书, ItemTips, "Item", nil, 2160][-]或者[11adf6][url=openwnd:随机4级魂石, ItemTips, "Item", nil, 2169][-]
--     [FFFE0D]三等奖：[-]共80名，可能获得[11adf6][url=openwnd:随机3级魂石, ItemTips, "Item", nil, 2168][-]、[11adf6][url=openwnd:紫水晶, ItemTips, "Item", nil, 224][-]或者[11adf6][url=openwnd:月满西楼, ItemTips, "Item", nil, 2876][-]
--     [FFFE0D]纪念奖：[-]参与抽奖必得。可能获得[11adf6][url=openwnd:蓝水晶, ItemTips, "Item", nil, 223][-]、[11adf6][url=openwnd:彩云追月, ItemTips, "Item", nil, 2877][-]或者[11adf6]1000贡献[-]。
-- ]]

-- tbAct.FnCustomData = function (szKey, tbData)
--         local szStart = Lib:TimeDesc10(tbData.nStartTime)
--         local szEnd   = Lib:TimeDesc10(tbData.nEndTime)
--         return {string.format(tbAct.szContent, szStart, szEnd, tbAct.nShowLevel)}
-- end

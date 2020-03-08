--
--local tbAct      = Activity:GetUiSetting("NewYearQAAct")
--tbAct.nShowLevel = 20
--tbAct.szTitle    = "新年礼盒的考验"
--tbAct.szUiName   = "Normal"
--tbAct.szContent  = [[
--[FFFE0D]新年礼盒的考验活动开始了！[-]
--[FFFE0D]活动时间：[-]%s~%s
--[FFFE0D]参与等级：[-]20级
--        过年期间我们为大侠准备了一些礼盒，大侠可以借此机会检验一下过去的一年里收获了多少挚友！
--		[FFFE0D]收到题板 做好准备[-]
--        活动开始时，各位大侠会收到附有[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 7443][-]的邮件，别忘记拿到之后研究一下怎么用哦！
--		[FFFE0D]量身定做 出好题目[-]
--        大侠收到[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 7443][-]后，按照说明出题，您的好友就能看到你的题目啦！
--        活动共[FFFE0D]10[-]天，每[FFFE0D]2[-]天为一轮，每轮每个玩家在该轮任何时间都可以出[FFFE0D]3[-]道题目让你的好友解答。
--        出题时大侠可以选择[FFFE0D]普通提问[-]或者是[FFFE0D]高级提问[-]，如果好友回答对了[FFFE0D]高级提问[-]的问题还会返还大侠[FFFE0D]1000贡献[-]呢，每个玩家每天只能拿%d次！
--		[FFFE0D]直答为主 问猜相辅[-]
--        大侠可以通过[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 7443][-]答题界面回答好友问题，每天可以获得免费的[FFFE0D]10[-]道题来回答，当成功答完全套题后会拿到对应每道题的奖励，答对更能获得与相应好友的[FFFE0D]亲密度[-]呢！如果回答的是高级提问的问题，能拿到更精美的新年礼盒和更高的[FFFE0D]亲密度[-]！
--        如果大侠意犹未尽，还可以花费一些元宝来回答更多的题目，每天限多答[FFFE0D]2[-]套。
--		[FFFE0D]结束统计 找出挚友[-]
--		        活动结束时会在所有回答过大侠问题的好友里面找到最了解你的，授予其您的挚友限时称号，至于对大侠毫不了解的好友，嘿嘿嘿！
--]]
--tbAct.FnCustomData = function (szKey, tbData)
--    local szStart = Lib:TimeDesc10(tbData.nStartTime)
--    local szEnd   = Lib:TimeDesc10(tbData.nEndTime)
--    return {string.format(tbAct.szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
--end

local tbNewYearQAAct = Activity:GetUiSetting("NewYearQAAct");
tbNewYearQAAct.NewYearQAAct = {
    nShowLevel = 20;
    szUiName = "Normal";
    szTitle = "新年礼盒的考验";
    FnCustomData = function (szKey, tbData)
        local szStart   = Lib:TimeDesc7(tbData.nStartTime)
        local szEnd     = Lib:TimeDesc7(tbData.nEndTime + 1)
        local szContent = [[
		[FFFE0D]新年礼盒的考验活动开始了！[-]
		[FFFE0D]活动时间：[-][c8ff00]%s-%s[-]
		[FFFE0D]参与等级：[-]20级
		        过年期间我们为大侠准备了一些礼盒，大侠可以借此机会检验一下过去的一年里收获了多少挚友！
				[FFFE0D]收到题板 做好准备[-]
		        活动开始时，各位大侠会收到附有[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 7443][-]的邮件，别忘记拿到之后研究一下怎么用哦！
				[FFFE0D]量身定做 出好题目[-]
		        大侠收到[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 7443][-]后，按照说明出题，您的好友就能看到你的题目啦！
		        活动共[FFFE0D]10[-]天，每[FFFE0D]2[-]天为一轮，每轮每个玩家在该轮任何时间都可以出[FFFE0D]3[-]道题目让你的好友解答。
		        出题时大侠可以选择[FFFE0D]普通提问[-]或者是[FFFE0D]高级提问[-]，如果好友回答对了[FFFE0D]高级提问[-]的问题还会返还大侠[FFFE0D]1000贡献[-]呢，每个玩家每天只能拿%d次！
				[FFFE0D]直答为主 问猜相辅[-]
		        大侠可以通过[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 7443][-]答题界面回答好友问题，每天可以获得免费的[FFFE0D]10[-]道题来回答，当成功答完全套题后会拿到对应每道题的奖励，答对更能获得与相应好友的[FFFE0D]亲密度[-]呢！如果回答的是高级提问的问题，能拿到更精美的新年礼盒和更高的[FFFE0D]亲密度[-]！
		        如果大侠意犹未尽，还可以花费一些元宝来回答更多的题目，每天限多答[FFFE0D]2[-]套。
				[FFFE0D]结束统计 找出挚友[-]
				    活动结束时会在所有回答过大侠问题的好友里面找到最了解你的，授予其您的挚友限时称号，至于对大侠毫不了解的好友，嘿嘿嘿！
		]]
        return {string.format(szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
    end;
}
tbNewYearQAAct.CeremonyQAAct = {
    nShowLevel = 20;
    szUiName = "Normal";
    szTitle = "盛典礼盒的考验";
    FnCustomData = function (szKey, tbData)
        local szStart   = Lib:TimeDesc7(tbData.nStartTime)
        local szEnd     = Lib:TimeDesc7(tbData.nEndTime + 1)
        local szContent = [[
		[FFFE0D]盛典礼盒的考验活动开始了！[-]
		[FFFE0D]活动时间：[-][c8ff00]%s-%s[-]
		[FFFE0D]参与等级：[-]20级
		        江湖盛典开始前我们为大侠准备了一些礼盒，大侠可以借此机会检验一下过去的一年里收获了多少挚友！
				[FFFE0D]收到题板 做好准备[-]
		        活动开始时，各位大侠会收到附有[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 9891][-]的邮件，别忘记拿到之后研究一下怎么用哦！
				[FFFE0D]量身定做 出好题目[-]
		        大侠收到[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 9891][-]后，按照说明出题，您的好友就能看到你的题目啦！
		        活动共[FFFE0D]10[-]天，每[FFFE0D]2[-]天为一轮，每轮每个玩家在该轮任何时间都可以出[FFFE0D]3[-]道题目让你的好友解答。
		        出题时大侠可以选择[FFFE0D]普通提问[-]或者是[FFFE0D]高级提问[-]，如果好友回答对了[FFFE0D]高级提问[-]的问题还会返还大侠[FFFE0D]1000贡献[-]呢，每个玩家每天只能拿%d次！
				[FFFE0D]直答为主 问猜相辅[-]
		        大侠可以通过[11adf6][url=openwnd:题板, ItemTips, "Item", nil, 9891][-]答题界面回答好友问题，每天可以获得免费的[FFFE0D]10[-]道题来回答，当成功答完全套题后会拿到对应每道题的奖励，答对更能获得与相应好友的[FFFE0D]亲密度[-]呢！如果回答的是高级提问的问题，能拿到更精美的盛典礼盒和更高的[FFFE0D]亲密度[-]！
		        如果大侠意犹未尽，还可以花费一些元宝来回答更多的题目，每天限多答[FFFE0D]2[-]套。
				[FFFE0D]结束统计 找出挚友[-]
				活动结束时会在所有回答过大侠问题的好友里面找到最了解你的，授予其您的挚友限时称号，至于对大侠毫不了解的好友，嘿嘿嘿！
		]]
        return {string.format(szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
    end;
}


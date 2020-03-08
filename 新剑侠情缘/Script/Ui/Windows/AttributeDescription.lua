local tbUi = Ui:CreateClass("AttributeDescription");

local DESC_LOTTERY = [[[FF69B4][url=openwnd:盟主的馈赠, ItemTips, "Item", nil, 6144][-]获得途径[FFFE0D][-]

[C8FF00]每次购买/领取 1元礼包[-]    [92D2FF]附赠：[-] 1张
[C8FF00]每次购买/领取 3元礼包[-]    [92D2FF]附赠：[-] 1张
[C8FF00]每次购买/领取 6元礼包[-]    [92D2FF]附赠：[-] 2张
[C8FF00]每天领取7日元宝大礼[-]       [92D2FF]附赠：[-] 1张
[C8FF00]每天领取30日元宝大礼[-]     [92D2FF]附赠：[-] 1张

提示：
·每个途径可重复获得
·每周平均最多可获得[C8FF00]42[-]张]];


--有的是服务端控制连接打开的，就以配置形式了
tbUi.tbSpecilKeys = {
	["InDifferBattleScoreHelp"] = [[
[92D2FF]积分：[-]0~5           [92D2FF]评价：[-][FFFFFF]普通[-]
[92D2FF]积分：[-]6~15         [92D2FF]评价：[-][64db00]一般[-]
[92D2FF]积分：[-]16~31       [92D2FF]评价：[-][11adf6]良好[-]
[92D2FF]积分：[-]32~47       [92D2FF]评价：[-][aa62fc]优秀[-]
[92D2FF]积分：[-]48~95       [92D2FF]评价：[-][ff578c]卓越[-]
[92D2FF]积分：[-]96+           [92D2FF]评价：[-][ff8f06]最佳[-]

[C8FF00]常规赛奖励：[-]
[92D2FF]积分：[-]0~5           [92D2FF]奖励：[-]1200荣誉
[92D2FF]积分：[-]6~15         [92D2FF]奖励：[-]1500荣誉
[92D2FF]积分：[-]16~31       [92D2FF]奖励：[-]2000荣誉
[92D2FF]积分：[-]32~47       [92D2FF]奖励：[-]2500荣誉
[92D2FF]积分：[-]48~95       [92D2FF]奖励：[-]3000荣誉
[92D2FF]积分：[-]96+           [92D2FF]奖励：[-]4000荣誉

小提示：幻境荣誉将自动兑换幻境宝箱 ]];

	["InDifferBattleScoreHelpMonth"] = [[
[92D2FF]积分：[-]0~5           [92D2FF]评价：[-][FFFFFF]普通[-]
[92D2FF]积分：[-]6~15         [92D2FF]评价：[-][64db00]一般[-]
[92D2FF]积分：[-]16~31       [92D2FF]评价：[-][11adf6]良好[-]
[92D2FF]积分：[-]32~47       [92D2FF]评价：[-][aa62fc]优秀[-]
[92D2FF]积分：[-]48~95       [92D2FF]评价：[-][ff578c]卓越[-]
[92D2FF]积分：[-]96+           [92D2FF]评价：[-][ff8f06]最佳[-]

[C8FF00]月度赛奖励：[-]
[92D2FF]积分：[-]0~5           [92D2FF]奖励：[-]4000荣誉
[92D2FF]积分：[-]6~15         [92D2FF]奖励：[-]6000荣誉
[92D2FF]积分：[-]16~31       [92D2FF]奖励：[-]8000荣誉
[92D2FF]积分：[-]32~47       [92D2FF]奖励：[-]10000荣誉
[92D2FF]积分：[-]48~95       [92D2FF]奖励：[-]12000荣誉
[92D2FF]积分：[-]96+           [92D2FF]奖励：[-]16000荣誉

小提示：幻境荣誉将自动兑换幻境宝箱 ]];
	["InDifferBattleScoreHelpSeason"] = [[
[92D2FF]积分：[-]0~5           [92D2FF]评价：[-][FFFFFF]普通[-]
[92D2FF]积分：[-]6~15         [92D2FF]评价：[-][64db00]一般[-]
[92D2FF]积分：[-]16~31       [92D2FF]评价：[-][11adf6]良好[-]
[92D2FF]积分：[-]32~47       [92D2FF]评价：[-][aa62fc]优秀[-]
[92D2FF]积分：[-]48~95       [92D2FF]评价：[-][ff578c]卓越[-]
[92D2FF]积分：[-]96+           [92D2FF]评价：[-][ff8f06]最佳[-]

[C8FF00]季度赛奖励：[-]
[92D2FF]积分：[-]0~5           [92D2FF]奖励：[-]8000荣誉
[92D2FF]积分：[-]6~15         [92D2FF]奖励：[-]12000荣誉
[92D2FF]积分：[-]16~31       [92D2FF]奖励：[-]16000荣誉
[92D2FF]积分：[-]32~47       [92D2FF]奖励：[-]20000荣誉
[92D2FF]积分：[-]48~95       [92D2FF]奖励：[-]24000荣誉
[92D2FF]积分：[-]96+           [92D2FF]奖励：[-]32000荣誉

小提示：幻境荣誉将自动兑换幻境宝箱 ]];

	["BeautyPageantVoteItem"] = [[[FF69B4][url=openwnd:红粉佳人, ItemTips, "Item", nil, 4692][-]获得途径[FFFE0D]（只限活动期间）[-]

[C8FF00]每日目标100活跃[-]        [92D2FF]附赠：[-]    1朵
[C8FF00]购买1元礼包[-]               [92D2FF]附赠：[-]    1朵
[C8FF00]购买3元礼包[-]               [92D2FF]附赠：[-]    2朵
[C8FF00]购买6元礼包[-]               [92D2FF]附赠：[-]    3朵
[C8FF00]购买7日元宝大礼[-]         [92D2FF]附赠：[-]  18朵
[C8FF00]购买30日元宝大礼[-]       [92D2FF]附赠：[-]  30朵
[C8FF00]兑换黎饰[-]                    [92D2FF]附赠：[-]  34朵
[C8FF00]充值6元[-]                     [92D2FF]附赠：[-]    2朵
[C8FF00]充值30元[-]                   [92D2FF]附赠：[-]  10朵
[C8FF00]充值98元[-]                   [92D2FF]附赠：[-]  33朵
[C8FF00]充值198元[-]                 [92D2FF]附赠：[-]  66朵
[C8FF00]充值328元[-]                 [92D2FF]附赠：[-]110朵
[C8FF00]充值648元[-]                 [92D2FF]附赠：[-]216朵]];
	["GoodVoiceVote"] = [[[FF69B4][url=openwnd:诗音券, ItemTips, "Item", nil, 10651][-]获得途径[FFFE0D]（只限比赛期间）[-]

[C8FF00]每日目标80活跃[-]    	[92D2FF]附赠：[-]1张（概率）
[C8FF00]每日目标100活跃[-]  [92D2FF]附赠：[-]1张（概率）
[C8FF00]购买3元礼包[-]      	    [92D2FF]附赠：[-]1张
[C8FF00]购买6元礼包[-]          [92D2FF]附赠：[-]1张
[C8FF00]购买18元礼包[-]        [92D2FF]附赠：[-]2张
[C8FF00]购买98元档黎饰[-]     [92D2FF]附赠：[-]3张
[C8FF00]购买298元档黎饰[-]   [92D2FF]附赠：[-]10张
[C8FF00]购买648元档黎饰[-]   [92D2FF]附赠：[-]22张
[C8FF00]玩家回归第1天[-]       [92D2FF]附赠：[-]1张（概率）
[C8FF00]玩家回归第2天[-]       [92D2FF]附赠：[-]1张（概率）
[C8FF00]玩家回归第3天[-]       [92D2FF]附赠：[-]1张（概率）
[C8FF00]玩家回归第4天[-]       [92D2FF]附赠：[-]1张（概率）

提示：每个途径可重复获得[FF69B4][url=openwnd:诗音券, ItemTips, "Item", nil, 10651][-] ]];

	["KinElectVoteItem1"] = [[[FF69B4][url=openwnd:风云徽, ItemTips, "Item", nil, 11120][-]获得途径[FFFE0D]（只限活动期间）[-]
[C8FF00]购买3元礼包[-]               [92D2FF]附赠：[-]1枚
[C8FF00]购买6元礼包[-]               [92D2FF]附赠：[-]2枚
[C8FF00]购买18元礼包[-]             [92D2FF]附赠：[-]6枚
[C8FF00]购买7日元宝大礼[-]         [92D2FF]附赠：[-]6枚
[C8FF00]购买30日元宝大礼[-]       [92D2FF]附赠：[-]10枚
[C8FF00]购买至尊7日元宝大礼[-]   [92D2FF]附赠：[-]13枚
[C8FF00]购买6元档元宝[-]            [92D2FF]附赠：[-]3枚
[C8FF00]购买30元档元宝[-]	          [92D2FF]附赠：[-]18枚
[C8FF00]购买98元档元宝[-]	          [92D2FF]附赠：[-]68枚
[C8FF00]购买198元档元宝[-]        [92D2FF]附赠：[-]148枚
[C8FF00]购买328元档元宝[-]        [92D2FF]附赠：[-]268枚
[C8FF00]购买648元档元宝[-]        [92D2FF]附赠：[-]648枚
[C8FF00]购买98元档黎饰[-]          [92D2FF]附赠：[-]68枚
[C8FF00]购买298元档黎饰[-]        [92D2FF]附赠：[-]238枚
[C8FF00]购买648元档黎饰[-]        [92D2FF]附赠：[-]648枚

提示：每个途径可重复获得[FF69B4][url=openwnd:风云徽, ItemTips, "Item", nil, 11120][-] ]];

	["KinElectVoteItem2"] = [[[FF69B4][url=openwnd:水月徽, ItemTips, "Item", nil, 11235][-]获得途径[FFFE0D]（只限初赛期间）[-]

[C8FF00]武林盟主[-]   [92D2FF]根据排名，族长附赠不同数量[-]
[C8FF00]白虎堂[-]      [92D2FF]打死各层BOSS获得不同数量[-]
[C8FF00]每日目标100活跃[-]   [92D2FF]附赠：[-]2枚（概率）

提示：每个途径可重复获得[FF69B4][url=openwnd:水月徽, ItemTips, "Item", nil, 11235][-] ]];

["Lottery"] = DESC_LOTTERY;

--迎宾
["WeddingWelcome"] = [[
婚礼正式开始前迎接宾客，新郎和新娘可以向好友、家族成员派发请柬

[FFFE0D]建议婚礼举办前提前通知亲朋好友哦[-] ]];

--山盟海誓
["WeddingPromise"] = [[
爱是包容、关怀、今生，爱他/她就大声说出来，向世界宣誓你们的爱

[FFFE0D]你们的爱情誓言将永久记录在婚书上[-] ]];

--拜堂
["WeddingCeremony"] = [[
成婚：一拜天地，二拜高祖，夫妻对拜

[FFFE0D]完成拜堂后获得夫妻称号、婚书、婚戒[-] ]];

--开心爆竹
["WeddingFirecracker"] = [[
开心婚礼大爆竹，新人、宾客齐跳舞、观礼花、祝福新人新婚快乐]];

--同食同心果
["WeddingConcentricFurit"] = [[
夫妻心心相印，1秒内同食同心果，宾客呐喊加油，其乐融融]];

--宴席
["WeddingTableFood"] = [[
婚宴酒席，喝喜酒，贺新人，其乐融融]];

--派喜糖
["WeddingCandy"] = [[
新郎、新娘派发喜糖，分享新婚喜悦]];

--游城
["WeddingTourMap"] = [[
新娘、新娘的花轿队伍游襄阳城，江湖人士齐齐来贺，跟随花轿还有机会获得喜糖

[FFFE0D]襄阳城还会换上婚礼装饰，并且奏响欢快的婚礼音乐[-] ]];

--结婚纪念日奖励(MarriageMDRewards_月份)
["MarriageMDRewards_0"] = [[
已领完全部纪念日奖励
]];

["MarriageMDRewards_1"] = [[
[92D2FF]以下是你们[FFFE0D]成婚1个月[-]纪念日的奖励：[-]

[ff8f06][url=openwnd:金童, ItemTips, "Item", nil, 5239]、[url=openwnd:玉女, ItemTips, "Item", nil, 5240][-] ]];

["MarriageMDRewards_6"] = [[
[92D2FF]以下是你们[FFFE0D]成婚6个月[-]纪念日的奖励：[-]

[ff8f06][url=openwnd:红木地板, ItemTips, "Item", nil, 6825][-]、[ff8f06][url=openwnd:寿纹鎏金墙壁, ItemTips, "Item", nil, 6826][-]、[aa62fc][url=openwnd:家族红包, ItemTips, "Item", nil, 6824][-] ]];

["MarriageMDRewards_12"] = [[
[92D2FF]以下是你们[FFFE0D]成婚1周年[-]纪念日的奖励：[-]

[ff8f06][url=openwnd:青石地板, ItemTips, "Item", nil, 7074][-]、[ff8f06][url=openwnd:万福雕纹墙壁, ItemTips, "Item", nil, 7077][-]、[ff578c][url=openwnd:家族红包, ItemTips, "Item", nil, 9696][-] ]];

}

tbUi.tbSpecilFuncs = {
	TS_CustomTaskRewards = function(self, tbArgs)
		local nTeacherRewards = tbArgs.nTeacherRewards or 0
		local nStudentRewards = tbArgs.nStudentRewards or 0
		local nCurTeacherRewards = tbArgs.nCurTeacherRewards or 0
		local nCurStudentRewards = tbArgs.nCurStudentRewards or 0
		local nCurFinished = tbArgs.nCurFinished or 0
		local szDesc = [[
完成师父布置的%d个任务后双方可得奖励
[92D2FF]师父奖励：[-][FFFE0D]%d名望[-]
[92D2FF]徒弟奖励：[-][ff4cfd]%d经验[-]

当前徒弟已完成%d个任务，预计可得奖励
[92D2FF]师父奖励：[-][FFFE0D]%d名望[-]
[92D2FF]徒弟奖励：[-][ff4cfd]%d经验[-]

小提示：
·徒弟经验奖励随等级的提升而增加
·师父奖励每周以完成任务数最多的2个徒弟计算 ]]
		return string.format(szDesc, TeacherStudent.Def.nCustomTaskCount, nTeacherRewards, nStudentRewards, nCurFinished, nCurTeacherRewards, nCurStudentRewards)
	end,

	TS_CustomTaskRewardsNone = function(self, tbArgs)
		local nTeacherRewards = tbArgs.nTeacherRewards or 0
		local nStudentRewards = tbArgs.nStudentRewards or 0
		local szDesc = [[
完成师父布置的%d个任务后双方可得奖励
[92D2FF]师父奖励：[-][FFFE0D]%d名望[-]
[92D2FF]徒弟奖励：[-][ff4cfd]%d经验[-]

小提示：
·徒弟经验奖励随等级的提升而增加
·师父奖励每周以完成任务数最多的2个徒弟计算 ]]
		return string.format(szDesc, TeacherStudent.Def.nCustomTaskCount, nTeacherRewards, nStudentRewards)
	end,
}

function tbUi:GetText(szKey, tbArgs)
	if self.tbSpecilFuncs[szKey] then
		return self.tbSpecilFuncs[szKey](self, tbArgs)
	end
	return self.tbSpecilKeys[szKey]
end

function tbUi:OnOpen(szDesc, bShowArrow, szKey, tbArgs)
	local szDescTemp = self:GetText(szKey or "", tbArgs)
	if szDescTemp then
		szDesc = szDescTemp
	end
	self.pPanel:SetActive("Arrow", bShowArrow and true or false)
	self.Description:SetLinkText(szDesc)
end

function tbUi:OnScreenClick(szClickUi)
    Ui:CloseWindow(self.UI_NAME);
end
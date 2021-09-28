WelfareConst = {}

WelfareConst.WelfareType = {
	None = 0,
	OnlineReward = 1,
	Sign = 2,
	LevelingMadman = 3,
	WildRage = 4,
	BindPhone = 5,
	RewardCode = 6,
	Identify = 7,
}

WelfareConst.OnlineRewardState = {
	None = -1, --默认状态
	CannotGet = 0, --不可领取
	CanGet = 1, --可领取
	HasGet = 2, --已经领取
}

-- 实名认证状态
WelfareConst.IdentifyState = {
	None = -1,
	NoID = 0,
	HasID = 1,
}

-- 实名认证领取状态
WelfareConst.IdentifyRewardState = {
	None = 0,
	CanGet = 1,
	HasGet = 2,
}

-- 在线提示时间
WelfareConst.OnlineAlart = {
	[1] = 0,
	[2] = 3,
	[3] = 5,
	[4] = 8,
}
WelfareConst.ThreeHourTxt = "账号未做实名认证，累计在线时间超过[color=#ff3b3b]3小时[/color]，已进入疲劳时间，[color=#ff3b3b]游戏收益减半！[/color]超过5小时则收益为0。\n若你已满18岁，完成[color=#ff3b3b]实名认证[/color]后可解除防沉迷状态。"
WelfareConst.FiveHourTxt = "账号未做实名认证，累计在线时间超过[color=#ff3b3b]5小时[/color]，已进入疲劳时间，游戏[color=#ff3b3b]收益为0[/color]。\n若你已满18岁，完成[color=#ff3b3b]实名认证[/color]后可解除账号的防沉迷状态。"
WelfareConst.EightHourTxt = "您今日累计游戏时间已经超过8个小时，根据游戏疲劳系统规则，您的游戏收益将减半，请合理安排游戏时间，劳逸结合。"
WelfareConst.ChangeRewardState = "WelfareConst.ChangeRewardState"
WelfareConst.ChangeIDState = "WelfareConst.ChangeIDState"
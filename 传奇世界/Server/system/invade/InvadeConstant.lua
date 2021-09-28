INVADE_EMAIL_ID = 62			--奖励发送邮箱ID
INVADE_MONSTER_TYPE = {
	MONSTER1 = 1,				--纵火贼
	MONSTER2 = 2,				--响马贼
	MONSTER3 = 3,				--路霸
	MONSTER4 = 4,				--盗贼头目
}
INVADE_REFRESH_MONSTER3 = 10	--刷新路霸触发条件(纵火贼、响马贼击杀差值)
INVADE_REFRESH_MONSTER4 = 50	--刷新盗贼头目触发条件(纵火贼、响马贼击杀总值)
--奖励积分对应的掉落ID
INVADE_INTEGRAL = {
	[1000] = 2235,
	[5000] = 2236,
	[10000] = 2237,
	[40000] = 2238,
	[80000] = 2239,
}
INVADE_BUFF_ID = 326			--活动期间增加的属性对应的buffID

INVADE_ERR_ACTIVITY_OPEN = 1	--行会山贼入侵活动开启
INVADE_ERR_ACTIVITY_CLOSE = 2	--行会山贼入侵活动结束,奖励已发送邮箱
INVADE_ERR_REWARD_SUCCESS = 3	--行会山贼入侵活动奖励已发放
INVADE_ERR_REFRESH_MONSTER3 = 4	--击杀纵火贼和响马贼数量差距过大,刷出了路霸,请注意控制击杀顺序
INVADE_ERR_REFRESH_MONSTER4 = 5	--盗贼头目前来增援，请速速击杀

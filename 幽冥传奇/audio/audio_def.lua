
-- 背景音乐
AudioBg = {
	Default = 0,									-- 默认背景音乐
	LoginView = 1002,								-- 登录背景音乐
	OpeningAnimation = 1006,						-- 开头动画背景音乐

	-- 根据场景类型配置默认背景音乐
	-- [1] = 1005,										-- 军团驻地
	-- [2] = 1002,										-- 诛邪战场
	-- [3] = 1002,										-- 单人装备本
	-- [4] = 1002,										-- 经验副本
	-- [5] = 1003,										-- 三界战场
	-- [6] = 1002,										-- 塔防 
	-- [7] = 1002,										-- 阶段副本
	-- [8] = 1003,										-- 攻城战
	-- [9] = 1003,										-- 仙盟战
	-- [10] = 1001,									-- 阵营驻地
	-- [11] = 1001,									-- 婚宴副本
	-- [12] = 1002,									-- 神兽禁地(全民boss)
	-- [13] = 1002,									-- 挑战副本(爬塔)
	-- [14] = 1002,									-- 仙盟神兽
}

AudioEffect = {
	ClickBtn = 1,									-- 按钮
	DrinkHP = 2,									-- 喝HP
	PickCoin = 3,									-- 捡金币
	UpLevel = 4,									-- 升级
	BeHitMale = 5,									-- 受击男
	BeHitFemale = 6,								-- 受击女
	DeadMale = 7,									-- 死亡男
	DeadFemale = 8,									-- 死亡女
	Move = 9,										-- 走
	Run = 10,										-- 跑
	AtkWuqi = 11,									-- 武器攻击
	Atk = 12,										-- 空手攻击
	NPCBtn = 21,									-- NPC按钮
	Transmit = 22,									-- 传送
	ShopOpen = 27,									-- 商城开
	ShopClose = 28,									-- 商城关
	PutOnWuqi = 61,									-- 带上武器
	WearEquip = 62,									-- 穿上装备
	OpenTip = 63,									-- 打开tip
}

-- 音效最小播放间隔
AudioInterval = {
	Common = 0.6,
	Attack = 0,
	FindTarget = 3,
	RoleBeHit = 2,
	MonsterBeHit = 2,
}

RecordState = {
	Free = 0,										-- 空闲
	Recording = 1,									-- 录音中
	Uploading = 2,									-- 上传中
}

local chaProp = {
	{
		stateOrProp = "状态",
		name = "防御",
		idx = 1,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "防御：被攻击时，可以抵消物理伤害"
	},
	{
		stateOrProp = "状态",
		name = "魔御",
		idx = 2,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "魔御：被攻击时，可以抵消魔法伤害"
	},
	{
		stateOrProp = "状态",
		name = "攻击",
		idx = 3,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "攻击：主要增加物理攻击伤害的属性"
	},
	{
		stateOrProp = "状态",
		name = "魔法",
		idx = 4,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "魔法：主要增加法师技能效果的属性"
	},
	{
		stateOrProp = "状态",
		name = "道术",
		idx = 5,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "道术：主要增加道士技能效果的属性"
	},
	{
		stateOrProp = "状态",
		name = "生命值",
		idx = 6,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "生命值：生命数值"
	},
	{
		stateOrProp = "状态",
		name = "魔法值",
		idx = 7,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "魔法值：魔法数值"
	},
	{
		stateOrProp = "状态",
		name = "幸运",
		idx = 8,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "幸运：每1点幸运可以增加2-2的主属性"
	},
	{
		stateOrProp = "状态",
		name = "准确",
		idx = 9,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "准确：攻击时，增加物理攻击的命中"
	},
	{
		stateOrProp = "状态",
		name = "敏捷",
		idx = 10,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "敏捷：被攻击时，增加对物理攻击的闪避"
	},
	{
		stateOrProp = "状态",
		name = "魔法命中",
		idx = 11,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "魔法命中：攻击时，增加单体和线性魔法的命中"
	},
	{
		stateOrProp = "状态",
		name = "魔法躲避",
		idx = 12,
		openConditionNotUse = "无",
		kind = "基础",
		source = "不提示",
		reqServerState = 0,
		functionDes = "魔法躲避：被攻击时，增加对单体和线性魔法的闪避"
	},
	{
		stateOrProp = "状态",
		name = "强攻概率",
		idx = 13,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石",
		reqServerState = 0,
		functionDes = "强攻概率：攻击时，增加出现强攻效果的几率"
	},
	{
		stateOrProp = "状态",
		name = "强攻伤害",
		idx = 14,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石，军鼓",
		reqServerState = 0,
		functionDes = "强攻伤害：强攻后，增加强攻造成的伤害"
	},
	{
		stateOrProp = "状态",
		name = "暴击概率",
		idx = 15,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石，羽翼",
		reqServerState = 0,
		functionDes = "暴击概率：攻击时，增加出现暴击效果的几率"
	},
	{
		stateOrProp = "状态",
		name = "暴击系数",
		idx = 16,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石，军鼓，羽翼",
		reqServerState = 0,
		functionDes = "暴击系数：暴击后，增加暴击造成的伤害"
	},
	{
		stateOrProp = "状态",
		name = "回血速度",
		idx = 17,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石",
		reqServerState = 0,
		functionDes = "回血速度：使用回复药品时，增加生命值的回复速度"
	},
	{
		stateOrProp = "状态",
		name = "回魔速度",
		idx = 18,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石",
		reqServerState = 0,
		functionDes = "回魔速度：使用回复药品时，增加魔法值的回复速度"
	},
	{
		stateOrProp = "状态",
		name = "回血上限",
		idx = 19,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石",
		reqServerState = 0,
		functionDes = "回血上限：使用回复药品时，增加回复生命值的总量"
	},
	{
		stateOrProp = "状态",
		name = "回魔上限",
		idx = 20,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石",
		reqServerState = 0,
		functionDes = "回魔上限：使用回复药品时，增加回复魔法值的总量"
	},
	{
		stateOrProp = "状态",
		name = "麻痹",
		idx = 21,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石",
		reqServerState = 1,
		functionDes = "麻痹：攻击时，增加麻痹敌方的几率和时间"
	},
	{
		stateOrProp = "状态",
		name = "冰冻",
		idx = 22,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：冰冻戒指",
		reqServerState = 3,
		functionDes = "冰冻：攻击时，增加冰冻敌方的几率和时间"
	},
	{
		stateOrProp = "状态",
		name = "守护概率",
		idx = 23,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石，羽翼",
		reqServerState = 1,
		functionDes = "守护概率：被攻击时，增加守护效果被触发的几率"
	},
	{
		stateOrProp = "状态",
		name = "守护减免",
		idx = 24,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：宝石，羽翼",
		reqServerState = 1,
		functionDes = "守护减免：守护触发时，增加守护效果减免伤害的比例"
	},
	{
		stateOrProp = "状态",
		name = "打怪回复",
		idx = 25,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：军衔装备",
		reqServerState = 1,
		functionDes = "打怪回复：攻击怪物时，回复一定的生命值"
	},
	{
		stateOrProp = "状态",
		name = "神圣伤害",
		idx = 26,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：军鼓",
		reqServerState = 2,
		functionDes = "神圣伤害：攻击时，造成同等数值的伤害（忽视防御、魔御、伤害加深、减免等效果）"
	},
	{
		stateOrProp = "状态",
		name = "伤害加深",
		idx = 27,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：羽翼",
		reqServerState = 2,
		functionDes = "伤害加深：攻击时，按照百分比提升一定的伤害"
	},
	{
		stateOrProp = "状态",
		name = "伤害减免",
		idx = 28,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：羽翼",
		reqServerState = 2,
		functionDes = "伤害减免：被攻击时，按照百分比减免一定的伤害"
	},
	{
		stateOrProp = "属性",
		name = "职业",
		idx = 29,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "等级",
		idx = 30,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "元宝",
		idx = 31,
		openConditionNotUse = "无",
		kind = "角色",
		source = "主要来源：元宝充值和交易获得",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "银锭",
		idx = 32,
		openConditionNotUse = "无",
		kind = "角色",
		source = "主要来源：元宝充值时附赠",
		reqServerState = 0,
		functionDes = "银锭：可用于抵扣元宝交易税和购买部分绑定道具"
	},
	{
		stateOrProp = "属性",
		name = "灵符",
		idx = 33,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "奖券",
		idx = 34,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "当前经验",
		idx = 35,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "升级经验",
		idx = 36,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "精力值",
		idx = 37,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "活力值",
		idx = 38,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "存储经验",
		idx = 39,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "不提示"
	},
	{
		stateOrProp = "属性",
		name = "信用分",
		idx = 40,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "信用分：用于角色验证，成为验证用户"
	},
	{
		stateOrProp = "属性",
		name = "角色验证",
		idx = 41,
		openConditionNotUse = "无",
		kind = "角色",
		source = "不提示",
		reqServerState = 0,
		functionDes = "角色验证：验证后，可成为验证用户"
	},
	{
		stateOrProp = "属性",
		name = "飞鞋",
		idx = 42,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：新手任务",
		reqServerState = 0,
		functionDes = "飞鞋：可以快速传送"
	},
	{
		stateOrProp = "属性",
		name = "声望",
		idx = 43,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：膜拜",
		reqServerState = 0,
		functionDes = "声望：用于勋章升级"
	},
	{
		stateOrProp = "属性",
		name = "贡献度",
		idx = 44,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：提交书页或绑定书页",
		reqServerState = 0,
		functionDes = "贡献度：在比奇皇宫皇家大学士处兑换技能书"
	},
	{
		stateOrProp = "属性",
		name = "阅历值",
		idx = 45,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：提交相应技能书",
		reqServerState = 0,
		functionDes = "阅历值：在比奇皇宫皇家大学士处兑换技能书"
	},
	{
		stateOrProp = "属性",
		name = "捐献度",
		idx = 46,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：回收物品获得",
		reqServerState = 0,
		functionDes = "捐献度：在回收商人处兑换物品"
	},
	{
		stateOrProp = "属性",
		name = "功勋",
		idx = 47,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：提交泉水兑换功勋",
		reqServerState = 2,
		functionDes = "功勋：在盟重土城大将军处兑换和升级军鼓"
	},
	{
		stateOrProp = "属性",
		name = "泉水",
		idx = 48,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：参与玛法接水活动获得泉水",
		reqServerState = 2,
		functionDes = "泉水：在盟重土城大将军处换取功勋"
	},
	{
		stateOrProp = "属性",
		name = "残卷点",
		idx = 49,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：提交技能残卷或绑定技能残卷",
		reqServerState = 2,
		functionDes = "残卷点：在比奇皇宫皇家大学士处兑换神龙技能"
	},
	{
		stateOrProp = "属性",
		name = "军功",
		idx = 50,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：跨服沙巴克，跨服大乱斗",
		reqServerState = 1,
		functionDes = "军功：用于角色升级军衔"
	},
	{
		stateOrProp = "状态",
		name = "神圣防御",
		idx = 51,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：兽魂石",
		reqServerState = 2,
		functionDes = "神圣防御：被攻击时，可以抵消神圣伤害"
	},
	{
		stateOrProp = "状态",
		name = "命中",
		idx = 52,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：兽魂石",
		reqServerState = 2,
		functionDes = "命中：攻击时，按照百分比增加物理攻击和魔法攻击的命中"
	},
	{
		stateOrProp = "状态",
		name = "物理闪避",
		idx = 53,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：兽魂石",
		reqServerState = 2,
		functionDes = "物理闪避：被攻击时，按照百分比对物理攻击进行闪避"
	},
	{
		stateOrProp = "状态",
		name = "魔法闪避",
		idx = 54,
		openConditionNotUse = "无",
		kind = "特殊",
		source = "主要来源：兽魂石",
		reqServerState = 2,
		functionDes = "魔法闪避：被攻击时，按照百分比对魔法攻击进行闪避"
	},
	{
		stateOrProp = "属性",
		name = "羽灵",
		idx = 55,
		openConditionNotUse = "无",
		kind = "其他",
		source = "主要来源：夺宝活动和精英怪掉落。",
		reqServerState = 4,
		functionDes = "羽灵：用于羽装升级。"
	}
}

return chaProp


YOKE_Thunder = { --雷系，产生眩晕Buffer
	id = 1, --ID对应字典表
	chance = 0.05, --触发几率
	bufStrength = 0, --buffer强度
	bufTimes = 1, --buffer次数
}

YOKE_Wind = { --风系，增加伤害
	id = 2, --ID对应字典表
	chance = 0.1, --触发几率
	damageIncrease = 0.3, --增加伤害百分比
}

YOKE_Light = { --光系，产生护盾
	id = 3, --ID对应字典表
	chance = 0.1, --触发几率
	bufStrength = 0, --减伤buffer强度
	bufTimes = 1, --减伤buffer次数
	bufPercent = 0.3, --减伤buffer减伤百分比
	bufNumber = 0, --减伤buffer减伤值
}

YOKE_Dark = { --暗系，吸血
	id =4, --ID对应字典表
	chance = 0.1, --触发几率
	lifeSteal = 0.3, --吸血百分比
}

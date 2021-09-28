--坐骑属性配置
local Arg = 
{
	--属性展示顺序
	vAttrVector = 
	{
		"Hp",--["生命值 : "],
		"Mp",--["魔法值 : "],
		"Att",-- ["物理攻击 : "],
		"Magic",-- ["魔法攻击 : "],
		"Sc",--["道术攻击 : "],
		"Defence",-- ["物理防御 : "],
		"MagDefence",-- ["魔法防御 : "],
		"Hit",--["命中值 : "],
		"Dodage",--["闪避值 : " ],
		"AttSpeed",--["攻击速度 : "],
		"Luck",--["幸运 : "],
		"Crit",--["暴击 : "],
		"Tenacity",--["韧性 : "],
		"Project",--["护身 : "],
		"ProjectDef",--["穿透 : "],
		"Benumb",--["冰冻等级 : "],
		"BenumbDef",--["冰冻抵抗等级 : "],
		"Speed",--["移动速度 : "],
	},

	--属性配对
	stAttrPair = 
	{
		Hp = {"q_max_hp"},
		Mp = {"q_max_mp"},
		Att = {"q_attack_min", "q_attack_max"},
		Magic = {"q_magic_attack_min", "q_magic_attack_max"},
		Sc = {"q_sc_attack_min", "q_sc_attack_max"},
		Defence = {"q_defence_min", "q_defence_max"},
		MagDefence = {"q_magic_defence_min", "q_magic_defence_max"},
		Hit = {"q_hit"},
		Dodage= {"q_dodge"},
		AttSpeed = {"q_attack_speed"},
		Luck = {"q_luck"},
		Crit = {"q_crit"},
		Tenacity = {"q_tenacity"},
		Project = {"q_project"},
		ProjectDef = {"q_projectDef"},
		Benumb = {"q_benumb"},
		BenumbDef = {"q_benumbDef"},
		Speed = {"q_addSpeed"},
	},

	--属性对名字
	stAttrPairName = 
	{
		Hp = "生命值 : ",
		Mp = "魔法值 : ",
		Att = "物理攻击 : ",
		Magic = "魔法攻击 : ",
		Sc = "道术攻击 : ",
		Defence = "物理防御 : ",
		MagDefence = "魔法防御 : ",
		Hit = "命中 : ",
		Dodage = "闪避 : " ,
		AttSpeed = "攻击速度 : ",
		Luck = "幸运 : ",
		Crit = "暴击 : ",
		Tenacity = "韧性 : ",
		Project = "护身 : ",
		ProjectDef = "穿透 : ",
		Benumb = "冰冻等级 : ",
		BenumbDef = "冰冻抵抗等级 : ",
		Speed = "移动速度 : ",
	},

	--全属性包含的所有属性
	stPropper = 
	{
	"^c(purple)生命值加成 : ^",
	"^c(purple)魔法值加成 : ^",
	"^c(purple)物理攻击加成 : ^",
	"^c(purple)魔法攻击加成 : ^",
	"^c(purple)道术攻击加成 : ^",
	"^c(purple)物理防御加成 : ^",
	"^c(purple)魔法防御加成 : ^",
	}
}

function Arg.getPairName( sKey )
	-- body
	return Arg.stAttrPairName[sKey]
end

function Arg.getPair( sKey )
	-- body
	return Arg.stAttrPair[sKey]
end

function Arg.getPropper( ... )
	-- body
	return Arg.stPropper
end

return Arg
--[[
	un32SkillModelID:int#技能模块id
	name:string#名字
	desc:string#描述
	eBuffType:int#类型
0 = 其他类型
1 = 增益
2 = 减益
	n32EffectLastTick:int#持续时间启动模块到结束模块的间隔时间
	n32EffectInterval:int#间隔时间持续时间内，间隔多久触发一次间隔模块ID
	bufKeepingPartical:string[]#Buff保持特效
	n32Delay:int#调用等待时间
	bufficonID:int#BuffIcon
	eftAttr:string#影响属性
	EftValue:int#影响值
]]

local cfg={
	[999112040]={
		un32SkillModelID=999112040,
		name="持续伤害[扩展 回血buff]",
		desc="每隔固定时间闪烁一下并飘伤害数据",
		eBuffType=1,
		n32EffectLastTick=10000,
		n32EffectInterval=200,
		bufKeepingPartical={"10023_run"},
		n32Delay=0,
		bufficonID=1120,
		eftAttr="hp",
		EftValue=2
	},
	[999112041]={
		un32SkillModelID=999112041,
		name="增加光效",
		desc="对于一些buff，添加一定的效果，如中毒，流血，指定武器或身体模型添加光效",
		eBuffType=1,
		n32EffectLastTick=10000,
		n32EffectInterval=200,
		bufKeepingPartical={"10023_run"},
		n32Delay=0,
		bufficonID=1120,
		eftAttr="hp",
		EftValue=100
	},
	[999112042]={
		un32SkillModelID=999112042,
		name="改变大小",
		desc="模型及受击体积变大小",
		eBuffType=1,
		n32EffectLastTick=10000,
		n32EffectInterval=200,
		bufKeepingPartical={"10023_run"},
		n32Delay=0,
		bufficonID=1120,
		eftAttr="scale",
		EftValue=0.5
	},
	[999112043]={
		un32SkillModelID=999112043,
		name="定身[扩展 冰冻]",
		desc="角色不能移动，可释放技能，可回城(非PK状态)，可使用物品（药）",
		eBuffType=2,
		n32EffectLastTick=10000,
		n32EffectInterval=200,
		bufKeepingPartical={"10023_run"},
		n32Delay=0,
		bufficonID=1120,
		eftAttr="moveSpeed",
		EftValue=0
	},
	[999112044]={
		un32SkillModelID=999112044,
		name="晕眩",
		desc="角色不能移动，不能释放技能，不能回城(无论PK状态)，不可使用物品（药）",
		eBuffType=2,
		n32EffectLastTick=10000,
		n32EffectInterval=200,
		bufKeepingPartical={"10023_run"},
		n32Delay=0,
		bufficonID=1120,
		eftAttr="moveSpeed",
		EftValue=0
	},
	[999112045]={
		un32SkillModelID=999112045,
		name="隐身",
		desc="看不见对方，或对方看不到自己，攻击时不会自动瞄准到对方",
		eBuffType=1,
		n32EffectLastTick=10000,
		n32EffectInterval=200,
		bufKeepingPartical={"10023_run"},
		n32Delay=0,
		bufficonID=1120,
		eftAttr="visiable",
		EftValue=1
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
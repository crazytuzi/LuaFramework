--[[
	day:int#签到天数
	reward:int[][]#签到奖励
{类型，物品编号，数量，是否绑定}
装备和物品外的奖励不需填“物品编号”
类型：1=装备
2=物品
3=金币
4=钻石
5=代金卷
6=贡献值
7=荣誉值
8=经验
]]

local cfg={
	[3]={
		day=3,
		reward={{2,35010,2,1}}
	},
	[6]={
		day=6,
		reward={{2,35010,5,1}}
	},
	[9]={
		day=9,
		reward={{2,35011,2,1}}
	},
	[12]={
		day=12,
		reward={{2,35011,5,1}}
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
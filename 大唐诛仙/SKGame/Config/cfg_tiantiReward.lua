--[[
	minRank:int#最小排名
	maxRank:int#最大排名
	reward:int[][]#排名奖励
{组编号，类型，物品编号，数量，是否绑定,权重}
装备和物品外的奖励不需填“物品编号”
类型：
1=装备
2=物品
3=金币
4=钻石
5=代金卷
6=贡献值
7=荣誉值
8=经验
9=宝玉
]]

local cfg={
	[1]={
		minRank=1,
		maxRank=1,
		reward={{2,61503,1,0},{2,35015,20,0}}
	},
	[2]={
		minRank=2,
		maxRank=2,
		reward={{2,61403,1,0},{2,35014,50,0}}
	},
	[3]={
		minRank=3,
		maxRank=3,
		reward={{2,61403,1,0},{2,35014,30,0}}
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
--[[
	id:int#序号
	moneyType:int#捐献类型
1=装备
2=物品
3=金币
4=元宝
	value:int#捐献值
	contribution:int#个人获得声望
	money:int#帮派获得资金
	buildNum:int#帮派获得建设
	limitTimes:int#每天限制次数
-1:无限次
	des:string#描述
]]

local cfg={
	[1]={
		id=1,
		moneyType=3,
		value=10000,
		contribution=10,
		money=10,
		buildNum=10,
		limitTimes=5,
		des="金币捐献10000"
	},
	[2]={
		id=2,
		moneyType=3,
		value=50000,
		contribution=50,
		money=50,
		buildNum=50,
		limitTimes=5,
		des="金币捐献50000"
	},
	[3]={
		id=3,
		moneyType=4,
		value=50,
		contribution=100,
		money=100,
		buildNum=100,
		limitTimes=5,
		des="元宝捐献50"
	},
	[4]={
		id=4,
		moneyType=4,
		value=100,
		contribution=200,
		money=200,
		buildNum=200,
		limitTimes=5,
		des="元宝捐献100"
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
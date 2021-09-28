--[[
	weekTaskNum:int#特殊环数
	itemId:int#特殊奖励
]]

local cfg={
	[10]={
		weekTaskNum=10,
		itemId=36106
	},
	[20]={
		weekTaskNum=20,
		itemId=36106
	},
	[30]={
		weekTaskNum=30,
		itemId=36106
	},
	[40]={
		weekTaskNum=40,
		itemId=36106
	},
	[50]={
		weekTaskNum=50,
		itemId=36301
	},
	[60]={
		weekTaskNum=60,
		itemId=36106
	},
	[70]={
		weekTaskNum=70,
		itemId=36106
	},
	[80]={
		weekTaskNum=80,
		itemId=36106
	},
	[90]={
		weekTaskNum=90,
		itemId=36106
	},
	[100]={
		weekTaskNum=100,
		itemId=36302
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
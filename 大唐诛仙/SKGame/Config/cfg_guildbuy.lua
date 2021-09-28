--[[
	itemId:int#物品ID（物品表ID）
	curPrice:int#现价（原价在item表的buyPrice）
	limitNum:int#每日限购数量（0为不限制数量）
]]

local cfg={
	[21101]={
		itemId=21101,
		curPrice=150,
		limitNum=99999
	},
	[21102]={
		itemId=21102,
		curPrice=500,
		limitNum=99999
	},
	[21103]={
		itemId=21103,
		curPrice=1500,
		limitNum=99999
	},
	[21104]={
		itemId=21104,
		curPrice=5000,
		limitNum=99999
	},
	[21201]={
		itemId=21201,
		curPrice=150,
		limitNum=99999
	},
	[21202]={
		itemId=21202,
		curPrice=500,
		limitNum=99999
	},
	[21203]={
		itemId=21203,
		curPrice=1500,
		limitNum=99999
	},
	[21204]={
		itemId=21204,
		curPrice=5000,
		limitNum=99999
	},
	[35008]={
		itemId=35008,
		curPrice=1000,
		limitNum=999
	},
	[35009]={
		itemId=35009,
		curPrice=5000,
		limitNum=999
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
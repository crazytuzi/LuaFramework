--[[
	id:int#物品ID
	goodsType:int#物品类1=装备
2=药品
3=凭证
4=资源
	name:string#物品名称
	value:string#value
	des:string#描述
	rare:int#品级
	maxNumber:int#拥有上限0=无限
	dropsIcon:int#掉落图标
	tinyType:int#物品小类1=金币
2=点券
3=工匠之心
]]

local cfg={
	[41001]={
		id=41001,
		goodsType=4,
		name="金币",
		value="gold",
		des="游戏金币，可购买药品",
		rare=1,
		maxNumber=0,
		dropsIcon=41001,
		tinyType=1
	},
	[42001]={
		id=42001,
		goodsType=4,
		name="点券",
		value="dianjuan",
		des="点券，可购买特殊道具",
		rare=4,
		maxNumber=0,
		dropsIcon=42001,
		tinyType=2
	},
	[43001]={
		id=43001,
		goodsType=4,
		name="工匠之心",
		value="gongjiang",
		des="资源，可打造装备",
		rare=4,
		maxNumber=999999999,
		dropsIcon=43001,
		tinyType=3
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
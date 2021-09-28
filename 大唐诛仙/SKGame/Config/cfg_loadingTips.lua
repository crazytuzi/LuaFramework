--[[
	id:int#id
	information:string#信息
]]

local cfg={
	[1]={
		id=1,
		information="每天登陆可以领取丰厚奖励！"
	},
	[2]={
		id=2,
		information="加入氏族，跟氏族的朋友一起组队进行副本，会更轻松哦。"
	},
	[3]={
		id=3,
		information="失败了不要紧，掌握BOSS的特点，打造强化装备，再次挑战吧。"
	},
	[4]={
		id=4,
		information="引导时若是被卡住，快速点击屏幕五次，即可跳过该引导！"
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
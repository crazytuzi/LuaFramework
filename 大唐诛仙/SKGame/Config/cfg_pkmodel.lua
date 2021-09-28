--[[
	id:int#编号
	name:string#名字
	des:string#描述
	color:string#模式颜色
]]

local cfg={
	[1]={
		id=1,
		name="和平",
		des="不对任何玩家造成伤害",
		color="93e69c"
	},
	[2]={
		id=2,
		name="善恶",
		des="对红名和灰名玩家造成伤害",
		color="fc5757"
	},
	[3]={
		id=3,
		name="阵营",
		des="对都护府外的玩家造成伤害",
		color="cc66ff"
	},
	[4]={
		id=4,
		name="家族",
		des="对家族外的玩家造成伤害",
		color="e6b693"
	},
	[5]={
		id=5,
		name="全体",
		des="对任何玩家造成伤害",
		color="fdfdfd"
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
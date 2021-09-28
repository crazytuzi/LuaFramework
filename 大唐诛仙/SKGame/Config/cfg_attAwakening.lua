--[[
	id:int#编号
	needLevel:int#需求等级
	segmentDes:string#段数描述
	interfaceDes:string#界面描述
	attDescribe:string#属性描述
	attValue:string#属性数值
	attAwaken:int[][]#觉醒属性
]]

local cfg={
	[1]={
		id=1,
		needLevel=5,
		segmentDes="1段",
		interfaceDes="1段觉醒",
		attDescribe="幸运50",
		attValue="5%",
		attAwaken={{35,50}}
	},
	[2]={
		id=2,
		needLevel=10,
		segmentDes="2段",
		interfaceDes="2段觉醒",
		attDescribe="力量90•智慧90",
		attValue="10%",
		attAwaken={{31,90},{32,90}}
	},
	[3]={
		id=3,
		needLevel=15,
		segmentDes="3段",
		interfaceDes="3段觉醒",
		attDescribe="耐力50•灵力50•幸运50",
		attValue="15%",
		attAwaken={{33,50},{34,50},{35,50}}
	},
	[4]={
		id=4,
		needLevel=20,
		segmentDes="4段",
		interfaceDes="4段觉醒",
		attDescribe="力量160•智慧160•耐力100•灵力100",
		attValue="20%",
		attAwaken={{31,160},{32,160},{33,100},{34,100}}
	},
	[5]={
		id=5,
		needLevel=25,
		segmentDes="5段",
		interfaceDes="5段觉醒",
		attDescribe="力量250•智慧250•耐力150•灵力150•幸运100",
		attValue="25%",
		attAwaken={{31,250},{32,250},{33,150},{34,150},{35,100}}
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
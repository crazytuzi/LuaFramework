--[[
	id:int#编号
	vipLevel:int#等级
	validTime:int#有效时间（天）
	activateReward:int[][]#首次激活奖励
{类型，物品编号，数量，是否绑定}
装备和物品外的奖励不需填“物品编号”类型：
1=装备
2=物品
3=金币
4=钻石
5=代金卷
6=贡献值
7=荣誉值
8=经验
	icon:string#图标
	des:string[]#特权描述
]]

local cfg={
	[301]={
		id=301,
		vipLevel=1,
		validTime=7,
		activateReward={{2,35014,5,0},{2,35010,5,0},{2,33002,5,0},{2,23001,5,0}},
		icon="VIP1",
		des={"激活或续期[COLOR=#0a861c]7[/COLOR]天当前特权","每天领取[COLOR=#0a861c]10[/COLOR]元宝","杀怪经验增加[COLOR=#0a861c]20%[/COLOR]","赠送青铜vip礼包，内含攻击药水[COLOR=#0a861c]2[/COLOR]个","悬赏任务刷新次数[COLOR=#0a861c]+1[/COLOR]","悬赏任务次数[COLOR=#0a861c]+1[/COLOR]","猎妖任务次数[COLOR=#0a861c]+1[/COLOR]","组队副本总次数[COLOR=#0a861c]+1[/COLOR]","侍魂殿战斗奖励次数[COLOR=#0a861c]+1[/COLOR]","特定日期签到，奖励双倍","VIP每日福利，奖励双倍","VIP专属商店","青铜VIP皇冠"}
	},
	[302]={
		id=302,
		vipLevel=2,
		validTime=15,
		activateReward={{2,35014,10,0},{2,35010,10,0},{2,33002,10,0},{2,23001,10,0}},
		icon="VIP2",
		des={"激活或续期[COLOR=#0a861c]15[/COLOR]天当前特权","每天领取[COLOR=#0a861c]20[/COLOR]元宝","杀怪经验增加[COLOR=#0a861c]40%[/COLOR]","赠送白银vip礼包，内含高级防御药水[COLOR=#0a861c]4[/COLOR]个","悬赏任务刷新次数[COLOR=#0a861c]+2[/COLOR]","悬赏任务次数[COLOR=#0a861c]+3[/COLOR]","猎妖任务次数[COLOR=#0a861c]+2[/COLOR]","组队副本总次数[COLOR=#0a861c]+2[/COLOR]","侍魂殿战斗奖励次数[COLOR=#0a861c]+3[/COLOR]","特定日期签到，奖励双倍","VIP每日福利，奖励双倍","VIP专属商店","白银VIP皇冠"}
	},
	[303]={
		id=303,
		vipLevel=3,
		validTime=30,
		activateReward={{2,35015,5,0},{2,35011,5,0},{2,33003,5,0},{2,23001,20,0}},
		icon="VIP3",
		des={"激活或续期[COLOR=#0a861c]30[/COLOR]天当前特权","每天领取[COLOR=#0a861c]30[/COLOR]元宝","杀怪经验增加[COLOR=#0a861c]60%[/COLOR]","赠送黄金vip礼包，内含高级攻击药水[COLOR=#0a861c]7[/COLOR]个","悬赏任务刷新次数[COLOR=#0a861c]+3[/COLOR]","悬赏任务次数[COLOR=#0a861c]+5[/COLOR]","猎妖任务次数[COLOR=#0a861c]+3[/COLOR]","组队副本总次数[COLOR=#0a861c]+3[/COLOR]","侍魂殿战斗奖励次数[COLOR=#0a861c]+5[/COLOR]","特定日期签到，奖励双倍","VIP每日福利，奖励双倍","VIP专属商店","黄金VIP皇冠"}
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
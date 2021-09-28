--[[
	Id:int#ID
	name:string#系统名称
	data:string[]#配置数据
]]

local cfg={
	[1]={
		Id=1,
		name="商城",
		data={"1_药品", "2_强化材料", "3_杂货", "4_外观", "5_VIP商店", "6_限时抢购", "7_装备行"}
	},
	[2]={
		Id=2,
		name="排行榜",
		data={"1_战力榜_1_2_3_4_5", "2_装备榜_1_2_3_4_6", "3_财富榜_1_2_3_4_7"}
	},
	[3]={
		Id=3,
		name="福利",
		data={"1_在线奖励", "2_签到", "3_等级冲刺", "4_战力冲刺", "5_手机绑定", "6_激活码"}
	},
	[4]={
		Id=4,
		name="排行榜列对应",
		data={"1_排名_RankColRank_rank", "2_玩家_RankColNormal_playerName", "3_职业_RankColCareer_career", "4_帮会_RankColNormal_guildName", "5_战斗力_RankColNormal_value", "6_装备评分_RankColNormal_value", "7_金币_RankColNormal_value"}
	},
	[5]={
		Id=5,
		name="公告",
		data={"1_测试公告"}
	},
	[6]={
		Id=6,
		name="充值活动",
		data={"1_每日充值", "2_成长基金" , "3_七天累计充值", "4_累计充值", "5_累计消费", "6_幸运大转盘", "7_陵墓探宝"}
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
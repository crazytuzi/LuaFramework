--[[
	strengID:int#id
	standName:string#分页名
	type:int#类型
1：注灵
2：技能
3：羽翼
4：斗神印
5：装备
6：金钱
	tips:int[][]#提示条件
为空则不提示
1:{{角色等级,注灵等级}}
玩家有任一注灵低于配置等级，则提示
2:{{角色等级,技能等级}}
玩家有任一技能低于配置等级，则提示
3:{{角色等级,装备品质}}
玩家有任一装备低于配置品质，则提示
	moduleId1:string[][]#连接1
模块id
为空则没有
{{图标id，描述1，描述2}}
lv为特定参数的平均数，依据类型lv读取不同数据

注灵：注灵平均等级，技能：技能平均等级、斗神印：斗神印平均等级、装备：装备平均品质
1：秘境  2：限时活动  3：侍魂殿  4：灵石矿洞  5：神印矿洞  6：背包分解  7：猎妖任务  8：商店斗神印  9：商店装备  10：大荒塔  11：副本  12:悬赏
13： 注灵界面  14：技能界面  15：斗神印界面  16：装备界面
	perfectTips:int[][]#满级提示标签出现条件
1:{{角色等级,技能等级}}
玩家有任一技能低于配置等级，则不提示
]]

local cfg={
	[3010]={
		strengID=3010,
		standName="注灵",
		type=1,
		tips={{18,3},{19,4},{23,5},{27,6},{31,7},{35,8},{40,9},{44,10},{48,11},{53,12},{57,13}},
		moduleId1={{2013,"注灵",1,13},{2004,"灵石矿洞","途径：采集",4},{2005,"背包","途径：装备分解",6},{2009,"收集灵石","途径：副本（困难、地狱）",11}},
		perfectTips={}
	},
	[3020]={
		strengID=3020,
		standName="技能",
		type=2,
		tips={{18,3},{20,4},{27,5},{33,6},{40,7},{53,9},{59,10}},
		moduleId1={{2011,"技能",2,14},{2001,"秘境","途径：秘境任务",1},{2002,"限时活动","途径：斗兽场",2},{2003,"侍魂殿","途径：pk",3}},
		perfectTips={{15,4},{20,5},{25,6},{30,7},{35,8},{40,9},{45,10},{50,11},{55,12},{60,13},{65,14},{70,15},{75,16},{80,17},{85,18},{90,19},{95,20}}
	},
	[3030]={
		strengID=3030,
		standName="羽翼",
		type=3,
		tips={},
		moduleId1={{2001,"秘境","途径：秘境任务",1},{2006,"猎妖","途径：猎妖任务",7},{2002,"限时副本","途径：风后踪影",2}},
		perfectTips={}
	},
	[3040]={
		strengID=3040,
		standName="斗神印",
		type=4,
		tips={},
		moduleId1={{2010,"斗神印","技能/属性强化",15},{2007,"购买斗神印","途径：商店",8},{2004,"神印矿洞","途径：采集",5}},
		perfectTips={}
	},
	[3050]={
		strengID=3050,
		standName="装备",
		type=5,
		tips={{18,1},{26,1},{36,2},{46,3},{56,3}},
		moduleId1={{2014,"装备",3,16},{2009,"收集装备","途径：副本",11},{2007,"装备开箱","途径：交易",9}},
		perfectTips={}
	},
	[3060]={
		strengID=3060,
		standName="金钱",
		type=6,
		tips={},
		moduleId1={{2012,"悬赏","途径：悬赏任务",12},{2002,"限时活动","途径：神秘洞穴",2}},
		perfectTips={}
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg
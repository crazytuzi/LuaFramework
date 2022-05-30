----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--zs_war_data.xml
--------------------------------------

Config = Config or {} 
Config.ZsWarData = Config.ZsWarData or {}



-- -------------------pos_start-------------------
Config.ZsWarData.data_pos_length = 15
Config.ZsWarData.data_pos = {
	[1] = {
		[1] = {206,608},
		[2] = {206,660},
		[3] = {206,700},
	},
	[2] = {
		[1] = {406,500},
		[2] = {406,600},
		[3] = {406,700},
	},
	[3] = {
		[1] = {551,500},
		[2] = {551,600},
		[3] = {551,700},
	},
	[4] = {
		[1] = {696,500},
		[2] = {696,600},
		[3] = {696,700},
	},
	[5] = {
		[1] = {841,500},
		[2] = {841,600},
		[3] = {841,700},
	},
	[6] = {
		[1] = {986,500},
		[2] = {986,600},
		[3] = {986,700},
	},
	[7] = {
		[1] = {1131,500},
		[2] = {1131,600},
		[3] = {1131,700},
	},
	[8] = {
		[1] = {1276,500},
		[2] = {1276,600},
		[3] = {1276,700},
	},
	[9] = {
		[1] = {1421,500},
		[2] = {1421,600},
		[3] = {1421,700},
	},
	[10] = {
		[1] = {1566,500},
		[2] = {1566,600},
		[3] = {1566,700},
	},
	[11] = {
		[1] = {1711,500},
		[2] = {1711,600},
		[3] = {1711,700},
	},
	[12] = {
		[1] = {1856,500},
		[2] = {1856,600},
		[3] = {1856,700},
	},
	[13] = {
		[1] = {2001,500},
		[2] = {2001,600},
		[3] = {2001,700},
	},
	[14] = {
		[1] = {2146,500},
		[2] = {2146,600},
		[3] = {2146,700},
	},
	[15] = {
		[1] = {2366,608},
		[2] = {2366,660},
		[3] = {2366,700},
	},
}
-- -------------------pos_end---------------------


-- -------------------const_start-------------------
Config.ZsWarData.data_const_length = 35
Config.ZsWarData.data_const = {
	["limit_lev"] = {key="limit_lev", val=30, desc="玩法参与等级"},
	["limit_day"] = {key="limit_day", val=4, desc="开服天数限制"},
	["reward_times"] = {key="reward_times", val=15, desc="战斗前X次可获得积分"},
	["move_reward_times"] = {key="move_reward_times", val=20, desc="达阵前Y次可获得积分"},
	["week_days"] = {key="week_days", val={1,2,3,4,5,6,7}, desc="周几开战"},
	["start_time"] = {key="start_time", val={{12,30,0},{20,0,0}}, desc="每天12:30开启"},
	["pre_time"] = {key="pre_time", val=300, desc="报名时间"},
	["match_time"] = {key="match_time", val=1500, desc="正式时间"},
	["zone_max"] = {key="zone_max", val=32, desc="战场最大人数"},
	["zone_real"] = {key="zone_real", val=20, desc="准备阶段战场上限"},
	["robot_limit"] = {key="robot_limit", val=10, desc="机器人填充上限"},
	["god_born"] = {key="god_born", val=[[H30058]], desc="宙斯初始模型雅典娜"},
	["god_change"] = {key="god_change", val=[[H30052]], desc="宙斯连胜变身盖亚"},
	["god_god"] = {key="god_god", val=[[H30031]], desc="宙斯阵营变身宙斯"},
	["imp_born"] = {key="imp_born", val=[[H30062]], desc="炎魔初始模型炽天使"},
	["imp_change"] = {key="imp_change", val=[[H30060]], desc="炎魔连胜变身吸血伯爵"},
	["imp_god"] = {key="imp_god", val=[[H30061]], desc="炎魔阵营变身炎魔"},
	["god_guard"] = {key="god_guard", val=[[H30031]], desc="宙斯阵营建筑模型"},
	["imp_guard"] = {key="imp_guard", val=[[H30061]], desc="炎魔阵营建筑模型"},
	["god_defeat"] = {key="god_defeat", val=[[E50079]], desc="宙斯阵营连败buff光环"},
	["imp_defeat"] = {key="imp_defeat", val=[[E50079]], desc="炎魔阵营连败buff光环"},
	["god_name"] = {key="god_name", val=1, desc="宙斯阵营"},
	["imp_name"] = {key="imp_name", val=2, desc="炎魔之王阵营"},
	["like_reward"] = {key="like_reward", val={{2,3000}}, desc="点赞奖励"},
	["liked_reward"] = {key="liked_reward", val={{2,3000}}, desc="被点赞奖励"},
	["like_times"] = {key="like_times", val=5, desc="最大点赞数量"},
	["reward_type"] = {key="reward_type", val=8, desc="个人积分转化资产ID"},
	["reward_firstblood"] = {key="reward_firstblood", val=10, desc="战场首杀积分奖励"},
	["attack_god"] = {key="attack_god", val=[[E21000]], desc="宙斯-眩晕释放"},
	["attack_imp"] = {key="attack_imp", val=[[E53254]], desc="炎魔-眩晕释放"},
	["speed_up"] = {key="speed_up", val=[[E21003]], desc="技能-加速"},
	["shield"] = {key="shield", val=[[E52033]], desc="技能-护盾"},
	["attack_effect"] = {key="attack_effect", val=[[E52000]], desc="被眩晕特效"},
	["attack_kill"] = {key="attack_kill", val=[[E21004]], desc="击杀特效"},
	["news_kill"] = {key="news_kill", val=6, desc="全服击杀传闻条件（连续击杀数）"}
}
-- -------------------const_end---------------------


-- -------------------explain_start-------------------
Config.ZsWarData.data_explain_length = 5
Config.ZsWarData.data_explain = {
	[1] = {id=1, title="基础规则", desc="1.众神战场为多人实时PVP玩法\n2.参与的玩家被分为<div fontcolor=#d95014>宙斯</div>和<div fontcolor=#d95014>炎魔</div>两个阵营\n3.参与战斗和抵达对方阵营可为己方增加荣誉积分\n4.比赛结束后荣誉积分多的一方获胜"},
	[2] = {id=2, title="参与规则", desc="1.玩法<div fontcolor=#d95014>30级</div>可参与\n2.每日<div fontcolor=#d95014>12:30-13:00</div>和<div fontcolor=#d95014>20:00-20:30</div>开启活动，前5分钟为报名阶段\n3.活动开始后仍可报名继续参与\n4.每到达30/40/50/60/70/80级时，将被分配至对应等级段的战场"},
	[3] = {id=3, title="比赛规则", desc="1.玩法开始后从各自出生点向敌方出生点发起进攻\n2.途中若遇到敌方玩家将触发战斗\n3.<div fontcolor=#d95014>参与战斗</div>或<div fontcolor=#d95014>抵达敌方阵营</div>都能获得荣誉积分"},
	[4] = {id=4, title="奖励发放", desc="1.参与战斗可获得<div fontcolor=#d95014>竞技声望</div>与<div fontcolor=#d95014>银币</div>奖励\n2.玩法结束后将根据积分排名和阵营胜负发放奖励"},
	[5] = {id=5, title="其他规则", desc="1.当交战失败后，会获得阵营庇护效果：\n奋勇一击：生命+10%，攻击+5%，防御+5%，速度+5%\n孤注一掷：生命+20%，攻击+10%，防御+10%，速度+10%\n破釜沉舟：生命+30%，攻击+15%，防御+15%，速度+15%\n背水一战：生命+40%，攻击+20%，防御+20%，速度+20%\n2.当首领血量差达到一定程度时，弱势方将触发宙斯/炎魔之力，随机一名玩家获得强力效果加持，同时全通阵营获得buff加成，持续一段时间后消失\n3.使用战场技能会带来意想不到的效果\n雷罚/炎爆：使用后有50%几率击晕前方目标，使其无法移动\n冲锋：加速场景跑动，同时跑动过程中不触发战斗\n神佑/炎盾：3秒内免疫受到敌方眩晕伤害"}
}
-- -------------------explain_end---------------------


-- -------------------skill_start-------------------
Config.ZsWarData.data_skill_length = 6
Config.ZsWarData.data_skill = {
	[1] = {id=1, name="雷罚", icon=15210, desc="使用后有50%几率击晕前方目标（被击晕期间无法正常移动），冷却150秒", free=10, loss={{15,20}}},
	[2] = {id=2, name="冲锋", icon=70007, desc="加速25%场景跑动，同时跑动过程中不触发战斗，持续4秒，冷却时间150秒", free=10, loss={{15,20}}},
	[3] = {id=3, name="神佑", icon=20210, desc="3秒内免疫受到敌方眩晕伤害，冷却时间150秒", free=5, loss={{15,20}}},
	[4] = {id=4, name="炎爆", icon=21010, desc="使用后有50%几率击晕前方目标（被击晕期间无法正常移动），冷却150秒", free=10, loss={{15,20}}},
	[5] = {id=5, name="冲锋", icon=70007, desc="加速25%场景跑动，同时跑动过程中不触发战斗，持续4秒，冷却时间150秒", free=10, loss={{15,20}}},
	[6] = {id=6, name="炎盾", icon=72021, desc="3秒内免疫受到敌方眩晕伤害，冷却时间150秒", free=5, loss={{15,20}}}
}
-- -------------------skill_end---------------------


-- -------------------num_rewards_start-------------------
Config.ZsWarData.data_num_rewards_length = 6
Config.ZsWarData.data_num_rewards = {
	[6] = {{type=2, num=1, items={{8,30}}},
		{type=2, num=3, items={{8,50}}},
		{type=1, num=3, items={{8,50}}},
		{type=2, num=5, items={{8,80}}},
		{type=1, num=5, items={{8,100}}},
		{type=2, num=8, items={{8,100}}},
		{type=1, num=8, items={{8,150}}},
		{type=1, num=10, items={{8,200}}}
	},
	[5] = {{type=2, num=1, items={{8,30}}},
		{type=2, num=3, items={{8,50}}},
		{type=1, num=3, items={{8,50}}},
		{type=2, num=5, items={{8,80}}},
		{type=1, num=5, items={{8,100}}},
		{type=2, num=8, items={{8,100}}},
		{type=1, num=8, items={{8,150}}},
		{type=1, num=10, items={{8,200}}}
	},
	[4] = {{type=2, num=1, items={{8,30}}},
		{type=2, num=3, items={{8,50}}},
		{type=1, num=3, items={{8,50}}},
		{type=2, num=5, items={{8,80}}},
		{type=1, num=5, items={{8,100}}},
		{type=2, num=8, items={{8,100}}},
		{type=1, num=8, items={{8,150}}},
		{type=1, num=10, items={{8,200}}}
	},
	[3] = {{type=2, num=1, items={{8,30}}},
		{type=2, num=3, items={{8,50}}},
		{type=1, num=3, items={{8,50}}},
		{type=2, num=5, items={{8,80}}},
		{type=1, num=5, items={{8,100}}},
		{type=2, num=8, items={{8,100}}},
		{type=1, num=8, items={{8,150}}},
		{type=1, num=10, items={{8,200}}}
	},
	[2] = {{type=2, num=1, items={{8,30}}},
		{type=2, num=3, items={{8,50}}},
		{type=1, num=3, items={{8,50}}},
		{type=2, num=5, items={{8,80}}},
		{type=1, num=5, items={{8,100}}},
		{type=2, num=8, items={{8,100}}},
		{type=1, num=8, items={{8,150}}},
		{type=1, num=10, items={{8,200}}}
	},
	[1] = {{type=2, num=1, items={{8,30}}},
		{type=2, num=3, items={{8,50}}},
		{type=1, num=3, items={{8,50}}},
		{type=2, num=5, items={{8,80}}},
		{type=1, num=5, items={{8,100}}},
		{type=2, num=8, items={{8,100}}},
		{type=1, num=8, items={{8,150}}},
		{type=1, num=10, items={{8,200}}}
	},
}
-- -------------------num_rewards_end---------------------


-- -------------------rank_rewards_start-------------------
Config.ZsWarData.data_rank_rewards_length = 6
Config.ZsWarData.data_rank_rewards = {
	[6] = {{group=6, desc="胜方奖励", items={{8,400}}},
		{group=6, desc="败方奖励", items={{8,280}}},
		{group=6, desc="平局奖励", items={{8,340}}},
		{group=6, desc="第1名", items={{50603,1},{8,800},{2,66666}}},
		{group=6, desc="第2名", items={{50602,1},{8,600},{2,50000}}},
		{group=6, desc="第3名", items={{50601,1},{8,500},{2,40000}}},
		{group=6, desc="4~10名", items={{8,400},{2,30000}}},
		{group=6, desc="11~20名", items={{8,350},{2,20000}}},
		{group=6, desc="21~32名", items={{8,300},{2,10000}}}
	},
	[5] = {{group=5, desc="胜方奖励", items={{8,380}}},
		{group=5, desc="败方奖励", items={{8,260}}},
		{group=5, desc="平局奖励", items={{8,320}}},
		{group=5, desc="第1名", items={{50603,1},{8,800},{2,66666}}},
		{group=5, desc="第2名", items={{50602,1},{8,600},{2,50000}}},
		{group=5, desc="第3名", items={{50601,1},{8,500},{2,40000}}},
		{group=5, desc="4~10名", items={{8,400},{2,30000}}},
		{group=5, desc="11~20名", items={{8,350},{2,20000}}},
		{group=5, desc="21~32名", items={{8,300},{2,10000}}}
	},
	[4] = {{group=4, desc="胜方奖励", items={{8,360}}},
		{group=4, desc="败方奖励", items={{8,240}}},
		{group=4, desc="平局奖励", items={{8,300}}},
		{group=4, desc="第1名", items={{50603,1},{8,800},{2,66666}}},
		{group=4, desc="第2名", items={{50602,1},{8,600},{2,50000}}},
		{group=4, desc="第3名", items={{50601,1},{8,500},{2,40000}}},
		{group=4, desc="4~10名", items={{8,400},{2,30000}}},
		{group=4, desc="11~20名", items={{8,350},{2,20000}}},
		{group=4, desc="21~32名", items={{8,300},{2,10000}}}
	},
	[3] = {{group=3, desc="胜方奖励", items={{8,340}}},
		{group=3, desc="败方奖励", items={{8,220}}},
		{group=3, desc="平局奖励", items={{8,280}}},
		{group=3, desc="第1名", items={{50603,1},{8,800},{2,66666}}},
		{group=3, desc="第2名", items={{50602,1},{8,600},{2,50000}}},
		{group=3, desc="第3名", items={{50601,1},{8,500},{2,40000}}},
		{group=3, desc="4~10名", items={{8,400},{2,30000}}},
		{group=3, desc="11~20名", items={{8,350},{2,20000}}},
		{group=3, desc="21~32名", items={{8,300},{2,10000}}}
	},
	[2] = {{group=2, desc="胜方奖励", items={{8,320}}},
		{group=2, desc="败方奖励", items={{8,200}}},
		{group=2, desc="平局奖励", items={{8,260}}},
		{group=2, desc="第1名", items={{50603,1},{8,800},{2,66666}}},
		{group=2, desc="第2名", items={{50602,1},{8,600},{2,50000}}},
		{group=2, desc="第3名", items={{50601,1},{8,500},{2,40000}}},
		{group=2, desc="4~10名", items={{8,400},{2,30000}}},
		{group=2, desc="11~20名", items={{8,350},{2,20000}}},
		{group=2, desc="21~32名", items={{8,300},{2,10000}}}
	},
	[1] = {{group=1, desc="胜方奖励", items={{8,300}}},
		{group=1, desc="败方奖励", items={{8,180}}},
		{group=1, desc="平局奖励", items={{8,240}}},
		{group=1, desc="第1名", items={{50603,1},{8,800},{2,66666}}},
		{group=1, desc="第2名", items={{50602,1},{8,600},{2,50000}}},
		{group=1, desc="第3名", items={{50601,1},{8,500},{2,40000}}},
		{group=1, desc="4~10名", items={{8,400},{2,30000}}},
		{group=1, desc="11~20名", items={{8,350},{2,20000}}},
		{group=1, desc="21~32名", items={{8,300},{2,10000}}}
	},
}
-- -------------------rank_rewards_end---------------------


-- -------------------group_start-------------------
Config.ZsWarData.data_group_length = 6
Config.ZsWarData.data_group = {
	[1] = {name="星灵"},
	[2] = {name="月曜"},
	[3] = {name="神圣"},
	[4] = {name="天辉"},
	[5] = {name="夜魇"},
	[6] = {name="混沌"}
}
-- -------------------group_end---------------------

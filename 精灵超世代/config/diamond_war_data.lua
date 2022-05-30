----------------------------------------------------
-- 此文件由数据工具生成
-- 钻石争霸配置数据--diamond_war_data.xml
--------------------------------------

Config = Config or {} 
Config.DiamondWarData = Config.DiamondWarData or {}

-- -------------------const_start-------------------
Config.DiamondWarData.data_const_length = 21
Config.DiamondWarData.data_const = {
	["limit_lev"] = {key="limit_lev", val=25, desc="参与等级"},
	["week_days"] = {key="week_days", val={6}, desc="周几开战"},
	["start_time"] = {key="start_time", val={{19,0,0}}, desc="周日19:00开放"},
	["match_time"] = {key="match_time", val=3600, desc="正式时间（秒）"},
	["pre_time"] = {key="pre_time", val={{18,55,0}}, desc="预开放报名时间"},
	["ready_time"] = {key="ready_time", val=300, desc="预报名时间（秒）"},
	["open_min"] = {key="open_min", val=16, desc="正式赛最少人数"},
	["unopen_tips"] = {key="unopen_tips", val="每周周六19:00-20:00开启", desc="未开放点卡牌提示"},
	["special_look"] = {key="special_look", val="H40005", desc="特殊形象"},
	["born_xy"] = {key="born_xy", val={{1230,810},{1470,1020},{1860,900},{1560,600},{1530,330},{1890,510},{2190,570},{2460,390},{2340,840},{2610,930},{2250,1080},{2340,1260},{2520,1410},{1590,1380},{1890,1170},{1410,1140},{960,1170},{1260,1020},{720,1350},{390,1380},{480,960},{780,810},{810,510},{570,420}}, desc="进入地图初始点"},
	["cost_buff"] = {key="cost_buff", val={{2,5}}, desc="钻石"},
	["pre_map"] = {key="pre_map", val=40000, desc="准备区地图"},
	["each_pre_time"] = {key="each_pre_time", val=60, desc="每轮准备时间（秒）"},
	["each_battle_time"] = {key="each_battle_time", val=270, desc="战斗时间（秒）"},
	["knockout_min_limit"] = {key="knockout_min_limit", val=2, desc="淘汰赛最少人数"},
	["knockout_max_limit"] = {key="knockout_max_limit", val=128, desc="淘汰赛最多人数"},
	["obsoleted_limit"] = {key="obsoleted_limit", val=16, desc="正式赛最少人数"},
	["arena_limit"] = {key="arena_limit", val=1024, desc="竞技场最低限制"},
	["end_stay_time"] = {key="end_stay_time", val=1800, desc="活动结束后停留时间（秒）"},
	["pre_rule"] = {key="pre_rule", val=1, desc="1.领主竞技场排名需要<div fontcolor=289b14>大于1024名</div>，提前<div fontcolor=289b14>5</div>分钟入场\n2.参与人数越多，能进行的比赛轮数越多；比赛进行轮数越多，奖励越丰厚\n3.赛制将分为<div fontcolor=#ffb400>准备期—淘汰赛—正式赛</div>，前3轮为淘汰赛，后续正式赛中将产生16强及霸主；\n4.活动准备期报名时总人数少于<div fontcolor=289b14>2</div>人时不开放淘汰赛；\n5.淘汰赛后剩余人数不足<div fontcolor=289b14>16</div>人时，不开放正式赛。"},
	["sixteen_rule"] = {key="sixteen_rule", val=1, desc="1.每轮比赛能投注一次（16进8、8进4、4进2、2进1共四轮），每轮仅能押注一名玩家；\n2.投注金额固定，仅能从<div fontcolor=#ffb400>10W、20W、50W</div>内进行选择；\n3.押注成功时1.5倍返还，押注的玩家战败时，投注金额将扣除；\n4.押注的玩家弃权不战斗时，押注金额将原数返还；\n5.玩家可通过16强界面查看录像或者进入观战。"}
}
-- -------------------const_end---------------------


-- -------------------combat_reward_start-------------------
Config.DiamondWarData.data_combat_reward_length = 10
Config.DiamondWarData.data_combat_reward = {
	[1] = {count=1, win_reward={{2,30}}, lose_reward={}, total_reward={{2,30}}},
	[2] = {count=2, win_reward={{2,50}}, lose_reward={}, total_reward={{2,80}}},
	[3] = {count=3, win_reward={{2,80}}, lose_reward={}, total_reward={{2,160}}},
	[4] = {count=4, win_reward={{2,100}}, lose_reward={}, total_reward={{2,260}}},
	[5] = {count=5, win_reward={{2,140}}, lose_reward={}, total_reward={{2,400}}},
	[6] = {count=6, win_reward={{2,200}}, lose_reward={}, total_reward={{2,600}}},
	[7] = {count=7, win_reward={{2,300}}, lose_reward={}, total_reward={{2,900}}},
	[8] = {count=8, win_reward={{2,600}}, lose_reward={}, total_reward={{2,1500}}},
	[9] = {count=9, win_reward={{2,900}}, lose_reward={}, total_reward={{2,2400}}},
	[10] = {count=10, win_reward={{2,1200}}, lose_reward={}, total_reward={{2,3600}}}
}
-- -------------------combat_reward_end---------------------


-- -------------------rules_start-------------------
Config.DiamondWarData.data_rules_length = 5
Config.DiamondWarData.data_rules = {
	[1] = {id=1, title="一、开放条件", desc="1、每周周六19:00-20:00为常规活动时间，<div fontcolor=289b14>务必提前5分钟进场</div>，开服期间活动开服参照开放特殊规则；\n2、开放特殊规则：开服第一天不开放此活动，开服第二天必定开，一周内最多只开放1次活动；\n3、玩家需要达到<div fontcolor=289b14>25</div>级，且竞技场排名需要达到<div fontcolor=289b14>前1024名</div>才有资格进入比赛；\n4、活动开始后，超出时间未进入的玩家，在活动过程中无法进入，敬请玩家提前准备好。"},
	[2] = {id=2, title="二、玩法说明", desc="1、玩法开放当天，<div fontcolor=289b14>0：00-18:55</div>为预告时间，<div fontcolor=289b14>18:55-19:00</div>为比赛准备时间，<div fontcolor=289b14>19:00-19:18</div>分为淘汰选拔赛阶段，19:18之后产生正式赛玩家进行比赛，正式比赛用时将视进入玩家数量而定，玩家越多，持续时间越长\n2、玩法赛程为：<div fontcolor=289b14>预告期间—活动准备期—积分淘汰赛—正式赛</div>；\n3、战斗为实时手动PVP玩法，战斗过程中，在限定时间能将对方全部击败并且己方有剩余英雄在场时则为战斗胜利，反之为战斗失败；\n4、在限定时间内，双方比赛均没能将对方英雄全部击败时，时间倒计时结束后，将根据双方英雄<div fontcolor=289b14>输出总伤害</div>进行计算，总输出伤害较高一方玩家判定为胜利，否则为失败\n5、<div fontcolor=289b14>战斗胜利的玩家将会继续停留在准备区，等待下一场战斗；战斗失败的玩家在结算后将被传送出准备区，本场活动结束</div>。"},
	[3] = {id=3, title="三、淘汰赛规则", desc="1、<div fontcolor=289b14>20:00-20:18</div>为积分淘汰赛阶段，淘汰赛中总共进行两两对战<div fontcolor=289b14>3</div>场，胜利积3分，失败积1分\n2、积分淘汰赛结束后，会根据玩家积分从高到低进行排名，从积分赛中获得淘汰比赛人数（<div fontcolor=289b14>128-64-32-16</div>中一种），最多产生128名玩家进入淘汰赛；\n3、每场比赛最大用时6分钟，包括准备期、布阵期、战斗期三阶段（双方战斗用时3分钟）；\n4、积分淘汰赛过程中，允许玩家中途进入，但参与场数将会同步当前进入时间所剩余轮数。"},
	[4] = {id=4, title="四、正式赛规则", desc="1、20:18后淘汰赛产生正式比赛人数，数量需要为128-64-32-16中的一个规格人数，人数少于<div fontcolor=289b14>16</div>人时，不开放正式赛；\n2、每次战斗胜利后，会继续停留在比赛准备区，等待其余玩家比赛后进入下一轮比赛；战斗失败的玩家将被传送出战斗准备场景，无法参与下一场比赛；\n3、每场比赛最大用时6分钟，比赛过程中退出活动将视为弃权，无法参与下次晋级；\n4、16强名单产生后，玩家可在<div fontcolor=289b14>16进8、8进4、4进2、2进1</div>共四场比赛中各对喜爱的领主进行投注支持。"},
	[5] = {id=5, title="五、其他说明", desc="1、在准备期间时，报名参与人数少于<div fontcolor=289b14>2</div>人时不开放淘汰赛，同时也不开放正式比赛；\n2、淘汰赛结束后，场数剩余人数不足<div fontcolor=289b14>16</div>人时，本次活动将不开放正式赛；\n3、每场战斗结束结算时根据玩家胜利场数进行发放奖励，胜利场数越多，下次胜利时，奖励越丰厚；\n4、每场比赛中需要等待活动中全部玩家进行完比赛后方可进入下一轮比赛，请领主耐心等候；\n5、每轮比赛中可消耗少量钻石购买buff加成，仅生效一次，在当前轮比赛有效。"}
}
-- -------------------rules_end---------------------


-- -------------------buff_start-------------------
Config.DiamondWarData.data_buff_length = 1
Config.DiamondWarData.data_buff = {
	[100] = {buff_bid=100, effect={{'dam',100}}, probability=100, desc="伤害+10%"}
}
-- -------------------buff_end---------------------


-- -------------------bet_info_start-------------------
Config.DiamondWarData.data_bet_info_length = 3
Config.DiamondWarData.data_bet_info = {
	[1] = {id=1, value={{1,100000}}, win_reward={{1,150000}}, lose_reward={}},
	[2] = {id=2, value={{1,200000}}, win_reward={{1,300000}}, lose_reward={}},
	[3] = {id=3, value={{1,500000}}, win_reward={{1,750000}}, lose_reward={}}
}
-- -------------------bet_info_end---------------------

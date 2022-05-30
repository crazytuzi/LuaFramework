----------------------------------------------------
-- 此文件由数据工具生成
-- 跨服进程配置--group_control_data.xml
--------------------------------------

Config = Config or {} 
Config.GroupControlData = Config.GroupControlData or {}

-- -------------------step_start-------------------
Config.GroupControlData.data_step_length = 4
Config.GroupControlData.data_step = {
	[1] = {step=1, name="跨服社交", need_value=7000, timeout_day=4, step_quest={104}, step_function={1000,1001,1004}, step_reward={{2,30},{1,30000}}, desc="领主参与<div fontcolor=#14ff32>众神战场</div>可增加本阶段进程值！"},
	[2] = {step=2, name="跨服战场", need_value=14000, timeout_day=4, step_quest={103}, step_function={1003,1005}, step_reward={{2,40},{1,50000}}, desc="领主参与<div fontcolor=#14ff32>段位赛</div>可增加本阶段进程值！"},
	[3] = {step=3, name="跨服段位赛", need_value=21000, timeout_day=4, step_quest={101,102}, step_function={1002,1006}, step_reward={{2,50},{1,80000}}, desc="领主参与<div fontcolor=#14ff32>剧情/地下城副本</div>可增加进程值！"},
	[4] = {step=4, name="时空融合", need_value=0, timeout_day=0, step_quest={}, step_function={}, step_reward={}, desc=""}
}
-- -------------------step_end---------------------


-- -------------------mission_start-------------------
Config.GroupControlData.data_mission_length = 4
Config.GroupControlData.data_mission = {
	[101] = {quest_id=101, desc="参与一次地下城副本", add_value=2},
	[102] = {quest_id=102, desc="参与一次剧情副本", add_value=2},
	[103] = {quest_id=103, desc="参与一次段位赛", add_value=20},
	[104] = {quest_id=104, desc="参与一次众神战场", add_value=200}
}
-- -------------------mission_end---------------------


-- -------------------function_start-------------------
Config.GroupControlData.data_function_length = 7
Config.GroupControlData.data_function = {
	[1000] = {id=1000, desc="跨服聊天", icon="txt_cn_group_1", icon="txt_cn_group_1"},
	[1001] = {id=1001, desc="跨服好友", icon="txt_cn_group_2", icon="txt_cn_group_2"},
	[1002] = {id=1002, desc="跨服段位赛", icon="txt_cn_group_3", icon="txt_cn_group_3"},
	[1003] = {id=1003, desc="跨服战场", icon="txt_cn_group_4", icon="txt_cn_group_4"},
	[1004] = {id=1004, desc="跨服切磋", icon="txt_cn_group_5", icon="txt_cn_group_5"},
	[1005] = {id=1005, desc="跨服首席争霸", icon="txt_cn_group_6", icon="txt_cn_group_6"},
	[1006] = {id=1006, desc="跨服钻石争霸", icon="txt_cn_group_7", icon="txt_cn_group_7"}
}
-- -------------------function_end---------------------


-- -------------------const_start-------------------
Config.GroupControlData.data_const_length = 3
Config.GroupControlData.data_const = {
	["rule_desc"] = {key="rule_desc", val=1, desc="1.跨服时空开放时，每次进入一个阶段时，将开放当前阶段对应的跨服功能；同时领主完成本阶段指定任务来提升进程值，推进服务器进入下一阶段；\n2.各个阶段中，本服进程值达到任务上限后，领主可领取阶段宝箱奖励；\n3.各个阶段中需要全部服务器都达到进程值上限才可进入下一阶段，缺一不可，领主们努力推进吧；\n4.时空融合阶段已开放全部跨服功能，请期待下次惊喜到来！"},
	["max_level"] = {key="max_level", val=4, desc="最大阶段"},
	["original_value"] = {key="original_value", val=7000, desc="初始进程值"}
}
-- -------------------const_end---------------------

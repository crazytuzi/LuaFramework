-- this file is generated by program!
-- don't change it manaully.
-- source file: arena_cluster_champion_data.xls

Config = Config or {} 
Config.ArenaClusterChampionData = Config.ArenaClusterChampionData or {}
Config.ArenaClusterChampionData.data_const_key_depth = 1
Config.ArenaClusterChampionData.data_const_length = 31
Config.ArenaClusterChampionData.data_const_lan = "zh"
Config.ArenaClusterChampionData.data_const = {
	["base_lev"] = {val=60,desc="机器人基本等级（没有一个真实玩家时使用）"},
	["base_power"] = {val=100000,desc="机器人基本战力（没有真实玩家时使用)"},
	["base_score"] = {val=400,desc="机器人初始积分"},
	["battel_guess"] = {val={{0,50},{51,80},{81,100}},desc="竞猜筛选战力差范围（三轮筛选）"},
	["battel_score"] = {val=80,desc="循环赛积分加成系数"},
	["battle_members"] = {val=256,desc="选拔赛参赛资格数量"},
	["face_list"] = {val={10101,10201,10202,10301,10302,10303,10304,10305,10401,10402,10403,10404,10405,10501,10502,10503,10504,10505,10506,10507,10508,10509,20101,20201,20202,20301,20302,20303,20304,20305,20401,20402,20403,20404,20405,20501,20502,20503,20504,20505,20506,20507,20508,30101,30201,30202,30301,30302,30303,30304,30305,30401,30402,30403,30404,30405,30501,30502,30503,30504,30505,30506,30507,30508,40301,40401,40402,40403,40404,40501,40502,40503,40504,40505,40506,40507,50301,50401,50402,50403,50404,50501,50502,50503,50504,50505,50506,50507},desc="机器人头像信息"},
	["guess_coin"] = {val=10,desc="竞猜币每次加减数量"},
	["guess_lev_limit"] = {val=55,desc="55级可参与竞猜玩法"},
	["guess_limit"] = {val=1000,desc="竞猜单次押注上限"},
	["guess_number1"] = {val=60,desc="积分赛每轮给予的筹码数量"},
	["guess_number2"] = {val=60,desc="64强赛每轮给予的筹码数量"},
	["guess_times"] = {val=2000,desc="竞猜成功获得的竞猜币倍数"},
	["hallowskin_reward_rank"] = {val=3,desc="能获得训练师外观白露的前x名"},
	["like_max"] = {val=3,desc="每日点赞最大次数"},
	["like_redpoint_limit"] = {val=55,desc="红点显示等级"},
	["like_reward"] = {val={{34,50}},desc="点赞奖励"},
	["look_list"] = {val={110401,110402,110403,110404,110405,120401,120402,120403,120404,120405,130401,130402,130403,130404,130405,140401,140402,140403,140404,150401,150402,150403,150404},desc="机器人外观信息"},
	["open_number_limit"] = {val=64,desc="周冠军赛开启所需人数"},
	["robot_win_score"] = {val=100,desc="机器人胜利积分系数"},
	["score_arg"] = {val=1000,desc="机器人初始积分系数"},
	["season_end"] = {val={13,0,0},desc="赛季结束时间"},
	["season_start"] = {val={12,0,0},desc="赛季开启时间"},
	["time_champion_end"] = {val={1,23,59,59},desc="冠军赛结束时间"},
	["time_champion_fight"] = {val=180,desc="64强冠军赛战斗时间"},
	["time_champion_guess"] = {val=90,desc="64强冠军赛下注时间"},
	["time_champion_ready"] = {val=30,desc="64强冠军赛准备时间"},
	["time_score_fight"] = {val=180,desc="积分赛战斗时间"},
	["time_score_guess"] = {val=90,desc="积分赛下注时间"},
	["time_score_ready"] = {val=30,desc="积分赛准备时间"},
	["time_score_start"] = {val={12,0,0},desc="积分赛开始时间"},
}

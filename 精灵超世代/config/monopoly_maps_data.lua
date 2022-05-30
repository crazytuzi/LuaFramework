----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--monopoly_maps_data.xml
--------------------------------------

Config = Config or {} 
Config.MonopolyMapsData = Config.MonopolyMapsData or {}

-- -------------------const_start-------------------
Config.MonopolyMapsData.data_const_length = 14
Config.MonopolyMapsData.data_const = {
	["monopoly_dice_id"] = {val=80246, desc="骰子id"},
	["monopoly_secret_id"] = {val=80247, desc="秘籍id"},
	["monopoly_gold_id"] = {val=80245, desc="南瓜币iD"},
	["monopoly_dice_rand"] = {val={1,4}, desc="骰子点数随机范围"},
	["monopoly_secret_rand"] = {val={1,4}, desc="秘籍可选择范围"},
	["open_lv_limit"] = {val=18, desc="角色等级达到30级开放圣夜奇境"},
	["open_day_limit"] = {val=8, desc="开服时间达到8天开放圣夜奇境"},
	["monopoly_event_trap_power"] = {val={500,800}, desc="陷阱事件战力区间"},
	["monopoly_event_boss_power"] = {val={1100,1300}, desc="boss事件战力区间"},
	["monopoly_gift"] = {val={{50022,1},{29905,200},{14001,4},{10603,4},{200511,1},{200505,1},{35,20}}, desc="奖励展示"},
	["monopoly_rule_1"] = {val=1, desc="1、圣夜奇境可以使用<div fontcolor=#fca000>南瓜机</div>或<div fontcolor=#fca000>魔法秘籍</div>进行探索，每次探索会获取<div fontcolor=#fca000>1点</div>探索值，达成条件可解锁下一张地图\n2、移动到格子上时会触发对应事件，胜利或正确的选择可以获得<div fontcolor=#fca000>大量奖励</div>！\n3、每张地图探索值独立，达到一定值会解锁该地图的奇境BOSS，挑战BOSS可以获得丰厚的道具奖励！\n4、奇境中掉落的<div fontcolor=#fca000>万圣节糖果</div>，可以在圣夜商店中兑换你喜欢的道具，活动结束后兑换商店就会消失，<div fontcolor=#fca000>请及时兑换</div>\n5、<div fontcolor=#fca000>探索值与伤害buff均为公会所有</div>，没有公会将无法正常获取探索值与buff加成，请尽快加入公会哦"},
	["monopoly_rule_2"] = {val=1, desc="1、每个地图有独立的探索值，达到一定探索值即可解锁boss\n2、每次移动可获取<div fontcolor=#fca000>探索值+1</div>，移动道具可从活动任务中获取\n3、使用该地图指定的<div fontcolor=#fca000>主题英雄</div>进行BOSS挑战可以大幅增加伤害\n4、每次挑战boss有<div fontcolor=#fca000>挑战奖励</div>，击杀boss会获得<div fontcolor=#fca000>击杀奖励</div>，奖励会通过邮件发放，更换公会后重复击杀不会获取到任何奖励\n5、探索值与buff同公会捆绑，离开公会后，个人所有的探索值与buff都会清零\n6、各章节公会排行互相独立，奖励在活动结束时进行结算，结算后会进入<div fontcolor=#fca000>公会宝库</div>\n7、boss全部击杀后，怪物会进入追击模式，追击模式只能获得掉落奖励，但不能增加排行榜伤害值"},
	["monopoly_event_trap_rewardshow"] = {val={80244,80245,80252,80253}, desc="陷阱事件奖励预览（客户端用）"},
	["monopoly_event_boss_rewardshow"] = {val={80244,80245,80252,80253}, desc="Boss事件奖励预览（客户端用）"}
}
Config.MonopolyMapsData.data_const_fun = function(key)
	local data=Config.MonopolyMapsData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyMapsData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------customs_start-------------------
Config.MonopolyMapsData.data_customs_length = 4
Config.MonopolyMapsData.data_customs = {
	[1] = {id=1, name="魔女之森", start_unixtime=0, develop=0, res_id="build_1", max_develop=1600},
	[2] = {id=2, name="蔷薇庭院", start_unixtime=1573056000, develop=1600, res_id="build_2", max_develop=1600},
	[3] = {id=3, name="魔王之城", start_unixtime=1573660800, develop=1600, res_id="build_3", max_develop=1600},
	[4] = {id=4, name="时之隙间", start_unixtime=1574265600, develop=1600, res_id="build_4", max_develop=1600}
}
Config.MonopolyMapsData.data_customs_fun = function(key)
	local data=Config.MonopolyMapsData.data_customs[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyMapsData.data_customs['..key..'])not found') return
	end
	return data
end
-- -------------------customs_end---------------------


-- -------------------map_info_start-------------------
Config.MonopolyMapsData.data_map_info_length = 12
Config.MonopolyMapsData.data_map_info = {
	[1] = {id=1, max_grid=50, res_id=1, grid_pos_list={23017,22020,20023,19026,20029,22032,20035,19038,17035,16038,14041,13044,14047,16050,17053,19056,17059,16062,17065,16068,17071,19074,20077,22074,23071,25068,26071,28074,29071,31068,29065,31062,29059,31056,32053,34050,35047,34044,32041,34038,32035,31032,29035,28032,26035,25038,23041,22044,23047,25050}, decorate_list={}},
	[2] = {id=2, max_grid=50, res_id=1, grid_pos_list={40050,38053,37056,35059,34062,32065,31062,29059,28062,26065,28068,26071,25074,23071,22068,20065,19068,17071,16068,14065,13062,11059,13056,14053,16050,17047,16044,14041,16038,17035,19032,20029,19026,20023,22020,23023,25026,26029,28032,29035,31032,32035,34038,32041,31044,29047,28050,26047,25044,23047}, decorate_list={}},
	[3] = {id=3, max_grid=50, res_id=1, grid_pos_list={35059,34056,35053,37050,35047,34044,32041,34038,32035,31032,29029,28026,26023,25026,23029,22032,23035,25038,23041,22044,20047,19044,17041,16038,14041,13044,11047,13050,14053,16056,14059,16062,17065,19068,20065,22068,23071,25074,26071,28068,29065,28062,26059,28056,29053,28050,26047,25050,23053,22056}, decorate_list={}},
	[4] = {id=4, max_grid=50, res_id=2, grid_pos_list={23083,25080,23077,25074,26071,28068,29065,31062,32059,31056,32053,34050,35047,37044,35041,34038,32041,31044,29047,28044,26041,28038,26035,25032,23029,22026,20029,19032,17035,19038,20041,19044,20047,22050,23053,25056,23059,22062,20065,19062,17059,16062,14065,13062,11059,13056,14053,13050,11047,10044}, decorate_list={}},
	[5] = {id=5, max_grid=50, res_id=2, grid_pos_list={23017,25020,26023,25026,23029,22032,20035,19038,17035,16038,14041,16044,17047,19050,20053,22050,23047,25044,26041,28038,29035,31032,32035,34038,35041,34044,32047,31050,32053,34056,35059,34062,32065,31068,29065,28062,26059,25062,23065,22068,20071,19068,17065,16062,14059,13056,11053,10050,8047,7050}, decorate_list={}},
	[6] = {id=6, max_grid=50, res_id=2, grid_pos_list={10056,11053,13050,14053,16056,17059,19056,20053,22050,20047,19044,17041,16038,14035,16032,17029,19026,20023,22020,23023,25026,23029,22032,23035,25038,26035,28038,29041,28044,29047,31050,32047,34050,35053,34056,32059,34062,32065,31068,29071,28074,26071,25068,23071,22068,20065,22062,23059,25056,26053}, decorate_list={}},
	[7] = {id=7, max_grid=50, res_id=3, grid_pos_list={23017,22020,20023,19026,20029,22032,20035,19038,17035,16038,14041,13044,14047,16050,17053,19056,17059,16062,17065,16068,17071,19074,20077,22074,23071,25068,26071,28074,29071,31068,29065,31062,29059,31056,32053,34050,35047,34044,32041,34038,32035,31032,29035,28032,26035,25038,23041,22044,23047,25050}, decorate_list={}},
	[8] = {id=8, max_grid=50, res_id=3, grid_pos_list={40050,38053,37056,35059,34062,32065,31062,29059,28062,26065,28068,26071,25074,23071,22068,20065,19068,17071,16068,14065,13062,11059,13056,14053,16050,17047,16044,14041,16038,17035,19032,20029,19026,20023,22020,23023,25026,26029,28032,29035,31032,32035,34038,32041,31044,29047,28050,26047,25044,23047}, decorate_list={}},
	[9] = {id=9, max_grid=50, res_id=3, grid_pos_list={35059,34056,35053,37050,35047,34044,32041,34038,32035,31032,29029,28026,26023,25026,23029,22032,23035,25038,23041,22044,20047,19044,17041,16038,14041,13044,11047,13050,14053,16056,14059,16062,17065,19068,20065,22068,23071,25074,26071,28068,29065,28062,26059,28056,29053,28050,26047,25050,23053,22056}, decorate_list={}},
	[10] = {id=10, max_grid=50, res_id=4, grid_pos_list={23083,25080,23077,25074,26071,28068,29065,31062,32059,31056,32053,34050,35047,37044,35041,34038,32041,31044,29047,28044,26041,28038,26035,25032,23029,22026,20029,19032,17035,19038,20041,19044,20047,22050,23053,25056,23059,22062,20065,19062,17059,16062,14065,13062,11059,13056,14053,13050,11047,10044}, decorate_list={}},
	[11] = {id=11, max_grid=50, res_id=4, grid_pos_list={23017,25020,26023,25026,23029,22032,20035,19038,17035,16038,14041,16044,17047,19050,20053,22050,23047,25044,26041,28038,29035,31032,32035,34038,35041,34044,32047,31050,32053,34056,35059,34062,32065,31068,29065,28062,26059,25062,23065,22068,20071,19068,17065,16062,14059,13056,11053,10050,8047,7050}, decorate_list={}},
	[12] = {id=12, max_grid=50, res_id=4, grid_pos_list={10056,11053,13050,14053,16056,17059,19056,20053,22050,20047,19044,17041,16038,14035,16032,17029,19026,20023,22020,23023,25026,23029,22032,23035,25038,26035,28038,29041,28044,29047,31050,32047,34050,35053,34056,32059,34062,32065,31068,29071,28074,26071,25068,23071,22068,20065,22062,23059,25056,26053}, decorate_list={}}
}
Config.MonopolyMapsData.data_map_info_fun = function(key)
	local data=Config.MonopolyMapsData.data_map_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyMapsData.data_map_info['..key..'])not found') return
	end
	return data
end
-- -------------------map_info_end---------------------


-- -------------------event_info_start-------------------
Config.MonopolyMapsData.data_event_info_length = 12
Config.MonopolyMapsData.data_event_info = {
	[1] = {
		[2] = {id=1, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[3] = {id=1, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_2", offset={6,-10}, show_ani=0},
		[4] = {id=1, type=4, res_id={1,'evt_10'}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[5] = {id=1, type=5, res_id={1,'evt_11'}, grid_res_id="grid_2", offset={0,0}, show_ani=0},
		[6] = {id=1, type=6, res_id={1,'evt_7'}, grid_res_id="grid_2", offset={0,-10}, show_ani=1},
		[7] = {id=1, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_2", offset={-5,-10}, show_ani=0},
		[8] = {id=1, type=8, res_id={1,'evt_3'}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[9] = {id=1, type=9, res_id={1,'evt_5'}, grid_res_id="grid_3", offset={0,-10}, show_ani=1},
		[10] = {id=1, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_3", offset={-8,0}, show_ani=0},
		[11] = {id=1, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[13] = {id=1, type=13, res_id={1,'evt_1'}, grid_res_id="grid_3", offset={27,0}, show_ani=0},
		[12] = {id=1, type=12, res_id={1,'evt_13'}, grid_res_id="grid_1", offset={0,-10}, show_ani=0},
		[14] = {id=1, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_1", offset={0,3}, show_ani=0},
		[1] = {id=1, type=1, res_id={}, grid_res_id="grid_1", offset={0,0}, show_ani=0},
	},
	[2] = {
		[2] = {id=2, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[3] = {id=2, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_2", offset={6,-10}, show_ani=0},
		[4] = {id=2, type=4, res_id={1,'evt_10'}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[5] = {id=2, type=5, res_id={1,'evt_11'}, grid_res_id="grid_2", offset={0,0}, show_ani=0},
		[6] = {id=2, type=6, res_id={1,'evt_7'}, grid_res_id="grid_2", offset={0,-10}, show_ani=1},
		[7] = {id=2, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_2", offset={-5,-10}, show_ani=0},
		[8] = {id=2, type=8, res_id={1,'evt_3'}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[9] = {id=2, type=9, res_id={1,'evt_5'}, grid_res_id="grid_3", offset={0,-10}, show_ani=1},
		[10] = {id=2, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_3", offset={-8,0}, show_ani=0},
		[11] = {id=2, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[13] = {id=2, type=13, res_id={1,'evt_1'}, grid_res_id="grid_3", offset={27,0}, show_ani=0},
		[12] = {id=2, type=12, res_id={1,'evt_13'}, grid_res_id="grid_1", offset={0,-10}, show_ani=0},
		[14] = {id=2, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_1", offset={0,3}, show_ani=0},
		[1] = {id=2, type=1, res_id={}, grid_res_id="grid_1", offset={0,0}, show_ani=0},
	},
	[3] = {
		[2] = {id=3, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[3] = {id=3, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_2", offset={6,-10}, show_ani=0},
		[4] = {id=3, type=4, res_id={1,'evt_10'}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[5] = {id=3, type=5, res_id={1,'evt_11'}, grid_res_id="grid_2", offset={0,0}, show_ani=0},
		[6] = {id=3, type=6, res_id={1,'evt_7'}, grid_res_id="grid_2", offset={0,-10}, show_ani=1},
		[7] = {id=3, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_2", offset={-5,-10}, show_ani=0},
		[8] = {id=3, type=8, res_id={1,'evt_3'}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[9] = {id=3, type=9, res_id={1,'evt_5'}, grid_res_id="grid_3", offset={0,-10}, show_ani=1},
		[10] = {id=3, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_3", offset={-8,0}, show_ani=0},
		[11] = {id=3, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_3", offset={0,-10}, show_ani=0},
		[13] = {id=3, type=13, res_id={1,'evt_1'}, grid_res_id="grid_3", offset={27,0}, show_ani=0},
		[12] = {id=3, type=12, res_id={1,'evt_13'}, grid_res_id="grid_1", offset={0,-10}, show_ani=0},
		[14] = {id=3, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_1", offset={0,3}, show_ani=0},
		[1] = {id=3, type=1, res_id={}, grid_res_id="grid_1", offset={0,0}, show_ani=0},
	},
	[4] = {
		[2] = {id=4, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[3] = {id=4, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_5", offset={6,-10}, show_ani=0},
		[4] = {id=4, type=4, res_id={1,'evt_10'}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[5] = {id=4, type=5, res_id={1,'evt_11'}, grid_res_id="grid_5", offset={0,0}, show_ani=0},
		[6] = {id=4, type=6, res_id={1,'evt_7'}, grid_res_id="grid_5", offset={0,-10}, show_ani=1},
		[7] = {id=4, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_5", offset={-5,-10}, show_ani=0},
		[8] = {id=4, type=8, res_id={1,'evt_3'}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[9] = {id=4, type=9, res_id={1,'evt_5'}, grid_res_id="grid_6", offset={0,-10}, show_ani=1},
		[10] = {id=4, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_6", offset={-8,0}, show_ani=0},
		[11] = {id=4, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[13] = {id=4, type=13, res_id={1,'evt_1'}, grid_res_id="grid_6", offset={27,0}, show_ani=0},
		[12] = {id=4, type=12, res_id={1,'evt_13'}, grid_res_id="grid_4", offset={0,-10}, show_ani=0},
		[14] = {id=4, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_4", offset={0,3}, show_ani=0},
		[1] = {id=4, type=1, res_id={}, grid_res_id="grid_4", offset={0,0}, show_ani=0},
	},
	[5] = {
		[2] = {id=5, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[3] = {id=5, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_5", offset={6,-10}, show_ani=0},
		[4] = {id=5, type=4, res_id={1,'evt_10'}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[5] = {id=5, type=5, res_id={1,'evt_11'}, grid_res_id="grid_5", offset={0,0}, show_ani=0},
		[6] = {id=5, type=6, res_id={1,'evt_7'}, grid_res_id="grid_5", offset={0,-10}, show_ani=1},
		[7] = {id=5, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_5", offset={-5,-10}, show_ani=0},
		[8] = {id=5, type=8, res_id={1,'evt_3'}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[9] = {id=5, type=9, res_id={1,'evt_5'}, grid_res_id="grid_6", offset={0,-10}, show_ani=1},
		[10] = {id=5, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_6", offset={-8,0}, show_ani=0},
		[11] = {id=5, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[13] = {id=5, type=13, res_id={1,'evt_1'}, grid_res_id="grid_6", offset={27,0}, show_ani=0},
		[12] = {id=5, type=12, res_id={1,'evt_13'}, grid_res_id="grid_4", offset={0,-10}, show_ani=0},
		[14] = {id=5, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_4", offset={0,3}, show_ani=0},
		[1] = {id=5, type=1, res_id={}, grid_res_id="grid_4", offset={0,0}, show_ani=0},
	},
	[6] = {
		[2] = {id=6, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[3] = {id=6, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_5", offset={6,-10}, show_ani=0},
		[4] = {id=6, type=4, res_id={1,'evt_10'}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[5] = {id=6, type=5, res_id={1,'evt_11'}, grid_res_id="grid_5", offset={0,0}, show_ani=0},
		[6] = {id=6, type=6, res_id={1,'evt_7'}, grid_res_id="grid_5", offset={0,-10}, show_ani=1},
		[7] = {id=6, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_5", offset={-5,-10}, show_ani=0},
		[8] = {id=6, type=8, res_id={1,'evt_3'}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[9] = {id=6, type=9, res_id={1,'evt_5'}, grid_res_id="grid_6", offset={0,-10}, show_ani=1},
		[10] = {id=6, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_6", offset={-8,0}, show_ani=0},
		[11] = {id=6, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_6", offset={0,-10}, show_ani=0},
		[13] = {id=6, type=13, res_id={1,'evt_1'}, grid_res_id="grid_6", offset={27,0}, show_ani=0},
		[12] = {id=6, type=12, res_id={1,'evt_13'}, grid_res_id="grid_4", offset={0,-10}, show_ani=0},
		[14] = {id=6, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_4", offset={0,3}, show_ani=0},
		[1] = {id=6, type=1, res_id={}, grid_res_id="grid_4", offset={0,0}, show_ani=0},
	},
	[7] = {
		[2] = {id=7, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[3] = {id=7, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_7", offset={6,-10}, show_ani=0},
		[4] = {id=7, type=4, res_id={1,'evt_10'}, grid_res_id="grid_8", offset={0,-10}, show_ani=0},
		[5] = {id=7, type=5, res_id={1,'evt_11'}, grid_res_id="grid_8", offset={0,0}, show_ani=0},
		[6] = {id=7, type=6, res_id={1,'evt_7'}, grid_res_id="grid_8", offset={0,-10}, show_ani=1},
		[7] = {id=7, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_8", offset={-5,-10}, show_ani=0},
		[8] = {id=7, type=8, res_id={1,'evt_3'}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[9] = {id=7, type=9, res_id={1,'evt_5'}, grid_res_id="grid_9", offset={0,-10}, show_ani=1},
		[10] = {id=7, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_9", offset={-8,0}, show_ani=0},
		[11] = {id=7, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[13] = {id=7, type=13, res_id={1,'evt_1'}, grid_res_id="grid_9", offset={27,0}, show_ani=0},
		[12] = {id=7, type=12, res_id={1,'evt_13'}, grid_res_id="grid_7", offset={0,-10}, show_ani=0},
		[14] = {id=7, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_7", offset={0,3}, show_ani=0},
		[1] = {id=7, type=1, res_id={}, grid_res_id="grid_7", offset={0,0}, show_ani=0},
	},
	[8] = {
		[2] = {id=8, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[3] = {id=8, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_7", offset={6,-10}, show_ani=0},
		[4] = {id=8, type=4, res_id={1,'evt_10'}, grid_res_id="grid_8", offset={0,-10}, show_ani=0},
		[5] = {id=8, type=5, res_id={1,'evt_11'}, grid_res_id="grid_8", offset={0,0}, show_ani=0},
		[6] = {id=8, type=6, res_id={1,'evt_7'}, grid_res_id="grid_8", offset={0,-10}, show_ani=1},
		[7] = {id=8, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_8", offset={-5,-10}, show_ani=0},
		[8] = {id=8, type=8, res_id={1,'evt_3'}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[9] = {id=8, type=9, res_id={1,'evt_5'}, grid_res_id="grid_9", offset={0,-10}, show_ani=1},
		[10] = {id=8, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_9", offset={-8,0}, show_ani=0},
		[11] = {id=8, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[13] = {id=8, type=13, res_id={1,'evt_1'}, grid_res_id="grid_9", offset={27,0}, show_ani=0},
		[12] = {id=8, type=12, res_id={1,'evt_13'}, grid_res_id="grid_7", offset={0,-10}, show_ani=0},
		[14] = {id=8, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_7", offset={0,3}, show_ani=0},
		[1] = {id=8, type=1, res_id={}, grid_res_id="grid_7", offset={0,0}, show_ani=0},
	},
	[9] = {
		[2] = {id=9, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[3] = {id=9, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_7", offset={6,-10}, show_ani=0},
		[4] = {id=9, type=4, res_id={1,'evt_10'}, grid_res_id="grid_8", offset={0,-10}, show_ani=0},
		[5] = {id=9, type=5, res_id={1,'evt_11'}, grid_res_id="grid_8", offset={0,0}, show_ani=0},
		[6] = {id=9, type=6, res_id={1,'evt_7'}, grid_res_id="grid_8", offset={0,-10}, show_ani=1},
		[7] = {id=9, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_8", offset={-5,-10}, show_ani=0},
		[8] = {id=9, type=8, res_id={1,'evt_3'}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[9] = {id=9, type=9, res_id={1,'evt_5'}, grid_res_id="grid_9", offset={0,-10}, show_ani=1},
		[10] = {id=9, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_9", offset={-8,0}, show_ani=0},
		[11] = {id=9, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_9", offset={0,-10}, show_ani=0},
		[13] = {id=9, type=13, res_id={1,'evt_1'}, grid_res_id="grid_9", offset={27,0}, show_ani=0},
		[12] = {id=9, type=12, res_id={1,'evt_13'}, grid_res_id="grid_7", offset={0,-10}, show_ani=0},
		[14] = {id=9, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_7", offset={0,3}, show_ani=0},
		[1] = {id=9, type=1, res_id={}, grid_res_id="grid_7", offset={0,0}, show_ani=0},
	},
	[10] = {
		[2] = {id=10, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[3] = {id=10, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_10", offset={6,-10}, show_ani=0},
		[4] = {id=10, type=4, res_id={1,'evt_10'}, grid_res_id="grid_11", offset={0,-10}, show_ani=0},
		[5] = {id=10, type=5, res_id={1,'evt_11'}, grid_res_id="grid_11", offset={0,0}, show_ani=0},
		[6] = {id=10, type=6, res_id={1,'evt_7'}, grid_res_id="grid_11", offset={0,-10}, show_ani=1},
		[7] = {id=10, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_11", offset={-5,-10}, show_ani=0},
		[8] = {id=10, type=8, res_id={1,'evt_3'}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[9] = {id=10, type=9, res_id={1,'evt_5'}, grid_res_id="grid_12", offset={0,-10}, show_ani=1},
		[10] = {id=10, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_12", offset={-8,0}, show_ani=0},
		[11] = {id=10, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[13] = {id=10, type=13, res_id={1,'evt_1'}, grid_res_id="grid_12", offset={27,0}, show_ani=0},
		[12] = {id=10, type=12, res_id={1,'evt_13'}, grid_res_id="grid_10", offset={0,-10}, show_ani=0},
		[14] = {id=10, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_10", offset={0,3}, show_ani=0},
		[1] = {id=10, type=1, res_id={}, grid_res_id="grid_10", offset={0,0}, show_ani=0},
	},
	[11] = {
		[2] = {id=11, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[3] = {id=11, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_10", offset={6,-10}, show_ani=0},
		[4] = {id=11, type=4, res_id={1,'evt_10'}, grid_res_id="grid_11", offset={0,-10}, show_ani=0},
		[5] = {id=11, type=5, res_id={1,'evt_11'}, grid_res_id="grid_11", offset={0,0}, show_ani=0},
		[6] = {id=11, type=6, res_id={1,'evt_7'}, grid_res_id="grid_11", offset={0,-10}, show_ani=1},
		[7] = {id=11, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_11", offset={-5,-10}, show_ani=0},
		[8] = {id=11, type=8, res_id={1,'evt_3'}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[9] = {id=11, type=9, res_id={1,'evt_5'}, grid_res_id="grid_12", offset={0,-10}, show_ani=1},
		[10] = {id=11, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_12", offset={-8,0}, show_ani=0},
		[11] = {id=11, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[13] = {id=11, type=13, res_id={1,'evt_1'}, grid_res_id="grid_12", offset={27,0}, show_ani=0},
		[12] = {id=11, type=12, res_id={1,'evt_13'}, grid_res_id="grid_10", offset={0,-10}, show_ani=0},
		[14] = {id=11, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_10", offset={0,3}, show_ani=0},
		[1] = {id=11, type=1, res_id={}, grid_res_id="grid_10", offset={0,0}, show_ani=0},
	},
	[12] = {
		[2] = {id=12, type=2, res_id={2,[[E27110]]}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[3] = {id=12, type=3, res_id={2,[[E27108]]}, grid_res_id="grid_10", offset={6,-10}, show_ani=0},
		[4] = {id=12, type=4, res_id={1,'evt_10'}, grid_res_id="grid_11", offset={0,-10}, show_ani=0},
		[5] = {id=12, type=5, res_id={1,'evt_11'}, grid_res_id="grid_11", offset={0,0}, show_ani=0},
		[6] = {id=12, type=6, res_id={1,'evt_7'}, grid_res_id="grid_11", offset={0,-10}, show_ani=1},
		[7] = {id=12, type=7, res_id={2,[[E27106]]}, grid_res_id="grid_11", offset={-5,-10}, show_ani=0},
		[8] = {id=12, type=8, res_id={1,'evt_3'}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[9] = {id=12, type=9, res_id={1,'evt_5'}, grid_res_id="grid_12", offset={0,-10}, show_ani=1},
		[10] = {id=12, type=10, res_id={2,[[E27109]]}, grid_res_id="grid_12", offset={-8,0}, show_ani=0},
		[11] = {id=12, type=11, res_id={2,[[E27107]]}, grid_res_id="grid_12", offset={0,-10}, show_ani=0},
		[13] = {id=12, type=13, res_id={1,'evt_1'}, grid_res_id="grid_12", offset={27,0}, show_ani=0},
		[12] = {id=12, type=12, res_id={1,'evt_13'}, grid_res_id="grid_10", offset={0,-10}, show_ani=0},
		[14] = {id=12, type=14, res_id={2,[[E27111]]}, grid_res_id="grid_10", offset={0,3}, show_ani=0},
		[1] = {id=12, type=1, res_id={}, grid_res_id="grid_10", offset={0,0}, show_ani=0},
	},
}
-- -------------------event_info_end---------------------


-- -------------------dialog_start-------------------
Config.MonopolyMapsData.data_dialog_length = 2
Config.MonopolyMapsData.data_dialog = {
	[1] = {
		[100] = {id=100, type=1, step_id=1, dialogue={{[[毒咒魔女]],0,0,[[duzhounvwu]],[[当当当，魔女的考验来了！]],80,120,85},{[[毒咒魔女]],1,0,[[duzhounvwu]],[[我的身上有毒药和解药，一瓶是绿色的，一瓶是紫色的。请问哪一瓶是解药呢？]],80,120,85}}, answer={{1,[[绿色的]]},{2,[[紫色的]]},{3,[[魔女从不带解药]]}}},
		[101] = {id=101, type=1, step_id=1, dialogue={{[[骑士亡灵]],0,0,[[siwangqishi]],[[不得不说人类真是一种有趣的生物，明知不敌却还是要一试。最后把性命丢了还要称之为勇气。]],250,120,70},{[[骑士亡灵]],0,0,[[siwangqishi]],[[真是愚蠢至极！这个世界世界唯有信仰之物值得用生命去守护！我为我曾经身为人类而感到羞耻。]],250,120,70},{[[骑士亡灵]],1,0,[[siwangqishi]],[[独角兽一族的公主真的值得你以生命为赌注去挽救么？]],250,120,70}}, answer={{1,[[公主和生命，我全都要！]]},{2,[[愚忠才是最愚蠢的行为！]]}}},
		[110] = {id=110, type=1, step_id=2, dialogue={{[[黑暗精灵]],0,0,[[heijinglingmiyan]],[[人类冒险者，你似乎受了一点伤，这样子的你怎么去和强大的魔王决斗呢？]],100,100,90},{[[黑暗精灵]],1,0,[[heijinglingmiyan]],[[我巫医一族的秘药包治百病，药到病除！让我来免费为你治疗吧，这样你才能以最完美的状态去和魔王决斗！]],100,100,90}}, answer={{1,[[你是魔王派来的精灵吧？]]},{2,[[那就有劳了。]]}}},
		[111] = {id=111, type=1, step_id=2, dialogue={{[[蛇女]],0,0,[[shenvmosha]],[[你看这蔷薇是多么的美丽，但是我们的造物主——侧滑狗总是公平的，赋予你美貌的同时就会给你一个悲惨的蛇生]],100,100,85},{[[蛇女]],1,0,[[shenvmosha]],[[我的美貌，大概是造物主都感到嫉妒了吧，我拥有了一双诅咒之眼，看到我眼睛的人都会为之石化。]],100,100,85}}, answer={{1,[[睁开眼看看是不是真的]]},{2,[[赶紧躲开，不想变成石头]]}}},
		[120] = {id=120, type=1, step_id=3, dialogue={{[[死神之影]],0,0,[[haila]],[[这个奇境，真是有意思……（死神喃喃自语）]],350,100,85},{[[死神之影]],0,0,[[haila]],[[这里还隐藏着一个更大的秘密，或者说“巴格”。]],350,100,85},{[[死神之影]],1,0,[[haila]],[[人类，如果你能够成功营救公主的话，不妨试着继续在奇境之中探索吧。]],350,100,85}}, answer={{1,[[巴格？听着像是英语？]]},{2,[[跑路都来不及，哪有空找巴格？]]}}},
		[121] = {id=121, type=1, step_id=3, dialogue={{[[魔王]],0,0,[[heianzhizhu]],[[欢迎来到死亡的城堡，这个寂寞的城堡终于有了冒险者的身影，我也终于可以活动活动我的筋骨了。]],600,100,70},{[[魔王]],1,0,[[heianzhizhu]],[[来魔王之城中寻找我吧，来到这里的人有资格让我亲自接待！]],600,100,70}}, answer={{1,[[等我探索值满了就来找你]]},{2,[[肝不动了，告辞]]}}},
		[122] = {id=122, type=1, step_id=3, dialogue={{[[艾蕾莉亚]],0,0,[[bingxueyuanwuqu]],[[啊，救命啊！]],250,150,70},{[[魔王]],0,0,[[heianzhizhu]],[[我的耐心可是有限的，再不过来的话我可不敢保证公主的性命~]],600,100,70},{[[魔王]],1,0,[[heianzhizhu]],[[对，快来送死吧。我已经迫不及待了渴望一场战斗了！]],600,100,70}}, answer={{1,[[我现在就来！]]},{2,[[哇这魔王也太可怕了吧~]]}}},
		[130] = {id=130, type=1, step_id=4, dialogue={{[[巴格魔龙]],0,0,[[nidehuoge]],[[程序猿真是太粗心了，把本不该属于这里的我创造了出来，还试图在代马中找出一条龙！]],50,150,75},{[[巴格魔龙]],0,0,[[nidehuoge]],[[在这个空间里，我无处不在，这个精心创造的节日空间，就由我来亲爪毁灭！]],50,150,75},{[[死神]],1,0,[[haila]],[[作为奇境的守护者，我可不允许破坏这个世界的巴格存在，粉碎在我的巨镰之下吧！]],50,150,75}}, answer={{1,[[协助死神消灭巴格！]]},{2,[[让巴格自生自灭。]]}}},
		[131] = {id=131, type=1, step_id=4, dialogue={{[[死神]],0,0,[[haila]],[[其实，这是一个由程序猿和侧滑狗创造，用以节日庆祝的异世界空间。]],350,100,85},{[[死神]],0,0,[[haila]],[[打败魔王拯救公主也只是侧滑狗想出来的老套剧情，真正的目的是为了让冒险者们帮忙找出这个空间的巴格。]],350,100,85},{[[死神]],0,0,[[haila]],[[但是由于巴格魔龙太过强大，只有经过魔王考验的冒险者才有资格进入时之隙间，寻找巴格。]],350,100,85},{[[死神]],1,0,[[haila]],[[通过了魔王考验的冒险者，你愿意和我一起消灭巴格么？]],350,100,85}}, answer={{1,[[乐意效劳，我的女神！]]},{2,[[找巴格太难了，我拒绝！]]}}},
		[132] = {id=132, type=1, step_id=4, dialogue={{[[艾蕾莉亚]],0,0,[[bingxueyuanwuqu]],[[对……对不起，我也不是故意骗你的~]],250,150,70},{[[艾蕾莉亚]],0,0,[[bingxueyuanwuqu]],[[这个空间需要冒险者来拯救，我也只好配合造物主大人的计划，假装被抓了……]],250,150,70},{[[艾蕾莉亚]],1,0,[[bingxueyuanwuqu]],[[但是，你果然成功把我救下来了~对了，造物主大人还送了我一件衣服，好看么？]],250,150,70}}, answer={{1,[[我就勉为其难原谅你了！]]},{2,[[哼……（偷瞄]]},{3,[[小公主果然是最好看的~]]}}},
		[133] = {id=133, type=1, step_id=4, dialogue={{[[侧滑]],0,0,[[zhuyunqingfeng]],[[遇事不决，量子力学，解释不通，穿越时空，篇幅不够，平行宇宙（自言自语）]],150,180,70},{[[侧滑]],1,0,[[zhuyunqingfeng]],[[写剧情好难啊...！啊~你就是被召唤而来的勇者么？啊啊怎么办怎么解释这次的穿越]],150,180,70},{[[侧滑]],0,0,[[zhuyunqingfeng]],[[唔姆~有点子了！感谢你的指点！这是给你的礼物~]],150,180,70}}, answer={{1,[[要不就量子力学吧]]},{2,[[通过卡车穿越时空？]]},{3,[[平行宇宙也不错]]}}},
		[134] = {id=134, type=1, step_id=4, dialogue={{[[巴格魔龙]],0,0,[[nidehuoge]],[[我获得了更强大的力量，我是不会被击败的！来吧勇者！]],50,150,75},{[[程序猿]],0,0,[[zhousi]],[[终于找到你了，看我一分种内解决掉你（一分钟之后）...好，巴格被击败了，下班了~下班了~]],200,200,80},{[[自己]],1,0,[[]],[[此人举手投足间的瞬息之间，巴格就灰飞烟灭，实力居然恐怖如斯...难道他就是程...]],0,0,100},{[[程序猿]],0,0,[[zhousi]],[[唔姆...唔姆......你这情况有点特殊，可能要等到巴格完全修复才能解决问题了，我先走了再见啊]],200,200,80}}, answer={{1,[[那个...我什么时候才能出去啊]]},{2,[[ 一分种内能帮我出去么]]},{3,[[ 大佬~能帮我回家么~]]}}},
		[135] = {id=135, type=1, step_id=4, dialogue={{[[运银喵]],0,0,[[tianxinnvpu]],[[艾蕾小公主为何神秘失踪？神秘古堡隐藏着怎样的秘密？巴格究竟意味着什么？这一切究竟是侧滑的阴谋，还是程序猿的沦丧...让我们采访一下事件的亲历者吧喵~]],150,100,80},{[[运银喵]],0,0,[[tianxinnvpu]],[[勇者大人，对于先莫名其妙的穿越进入了一个莫名其妙的副本，并且又双叒叕被程序猿的巴格困在此地，你现在有什么感想呢喵~]],150,100,80},{[[自己]],0,0,[[]],[[曾经我也是一名普普通通的冒险者，可惜我没有选择...时代变了]],0,0,100},{[[运银喵]],1,0,[[tianxinnvpu]],[[感谢大人您的回答~运银喵也给您透露一些绝密消息，千万不要告诉别人哦~被发现是会被按在键盘上了脸衮键盘了喵]],150,100,80},{[[运银喵]],0,0,[[tianxinnvpu]],[[其实12月下旬会个更大的秘境，就叫dyuicbqwbojkjdlasnio...救命啊喵！....bcvjsdikdcqhpq]],150,100,80}}, answer={{1,[[说说说~我最喜欢八卦了]]},{2,[[GKD...GKD]]}}},
	},
	[2] = {
		[201] = {id=201, type=2, step_id=0, dialogue={{[[我]],0,0,[[]],[[...仿佛有种被注视的感觉，是错觉么？]]},{[[神秘精灵]],0,0,[[panduola]],[[（突然出现）迷途的勇者哟，我这里有写着1的flag和写着2,3,4的flag，哪一个是你立的flag呢？]],370,130,85},{[[我]],1,1,[[]],[[这熟悉的套路，那当然是选择！（立下flag，若下次行走步数与立下的flag相同，可以获得大量奖励)]]},{[[神秘精灵]],0,0,[[panduola]],[[那这面旗帜你就为我保管吧，我会在你选择的地方等着你...]],370,130,85}}, answer={{1,[[1]]},{2,[[2]]},{3,[[3]]},{4,[[4]]}}},
	},
}
-- -------------------dialog_end---------------------


-- -------------------item_show_start-------------------
Config.MonopolyMapsData.data_item_show_length = 12
Config.MonopolyMapsData.data_item_show = {
	[1] = {id=1, item_bid=80254, title="啊，是陷阱！", desc="怪物来袭，走到此处时会<div fontcolor=#9e501b>遭遇一般强度的小怪物</div>，击败可以获得大量奖励及<div fontcolor=#9e501b>奇境挑战劵</div>"},
	[2] = {id=2, item_bid=80255, title="南瓜大礼包", desc="一个<div fontcolor=#9e501b>神秘的大礼包</div>，走到此处会获得大量奖励及<div fontcolor=#9e501b>奇境挑战劵</div>"},
	[3] = {id=3, item_bid=80256, title="强者的对决", desc="强者的对决，<div fontcolor=#9e501b>用刀剪锤一决胜负</div>吧！获胜可以获得大量奖励"},
	[4] = {id=4, item_bid=80257, title="神秘事件", desc="与神明发生奇妙的邂逅，<div fontcolor=#9e501b>做出你的选择吧</div>！有机会获得大量奖励哦"},
	[5] = {id=5, item_bid=80258, title="天降红包", desc="<div fontcolor=#9e501b>拾取到一个公会红包</div>，请不要忘记发给你的小伙伴"},
	[6] = {id=6, item_bid=80259, title="大boss出现了", desc="大boss来袭，<div fontcolor=#9e501b>触发一场高难度的boss战</div>，击败可以获得大量奖励及<div fontcolor=#9e501b>奇境挑战劵</div>"},
	[7] = {id=7, item_bid=80248, title="冲鸭！", desc="一只会冲锋的鸭子，触发后，<div fontcolor=#9e501b>额外进行一次与上次步数相同的行动"},
	[8] = {id=8, item_bid=80249, title="吨吨吨伏特加", desc="秘境限定生命之水！ \n<div fontcolor=#9e501b>奇境活动下次战斗伤害5倍（奇境挑战除外）</div>"},
	[9] = {id=9, item_bid=80250, title="这就是希望么", desc="来自大祭司的祝福！ \n<div fontcolor=#9e501b>下次行动掉落增加100%</div>"},
	[10] = {id=10, item_bid=80251, title="魔女的药锅", desc="这个料理，居然是绿色的！ \n<div fontcolor=#9e501b>奇境活动下次战斗直接获得胜利（奇境挑战除外）</div>"},
	[11] = {id=11, item_bid=80260, title="弗拉格", desc="立下一个FLAG，<div fontcolor=#9e501b>如果下次行走步数与选择的步数相同</div>，则可以获得大量奖励"},
	[12] = {id=12, item_bid=80261, title="终点", desc="这并不是终点，<div fontcolor=#9e501b>但是你可以领到大量奖励</div>（可获钻石*150，血量buff*3，攻击buff*3，挑战劵*1）"}
}
Config.MonopolyMapsData.data_item_show_fun = function(key)
	local data=Config.MonopolyMapsData.data_item_show[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyMapsData.data_item_show['..key..'])not found') return
	end
	return data
end
-- -------------------item_show_end---------------------


-- -------------------drama_start-------------------
Config.MonopolyMapsData.data_drama_length = 5
Config.MonopolyMapsData.data_drama = {
	[1] = {type=1, reward={{1,{{80246,3}}}}, dialogue={{[[魔王]],0,0,[[heianzhizhu]],[[欢迎来到圣夜奇境——我的地盘。]],600,100,70},{[[魔王]],0,0,[[heianzhizhu]],[[我知道你是为了营救艾蕾莉亚小公主而来，已经有太多的冒险者说过要消灭我，但我还站在这里就足以说明一切。]],600,100,70},{[[魔王]],0,0,[[heianzhizhu]],[[公主就在我手上，造物主大人还给她换了一身好看的新衣服，想救她的话尽管来魔王之城挑战我吧！渺小的人类~]],600,100,70}}, answer={{1}}},
	[2] = {type=2, reward={{1,{{80246,3}}}}, dialogue={{[[胡狼魔之影]],0,0,[[anubisi]],[[最近路过的人类实在太多了，我都有点消化不良了。]],650,150,60},{[[胡狼魔之影]],0,0,[[anubisi]],[[不过来者不拒，既然猎物送上门来，我不接受也不太好。]],650,150,60},{[[胡狼魔之影]],0,0,[[anubisi]],[[幼小的人类，你如果自认为有能力击败我的话，尽管来到魔女之森的深处来找我吧，这样子我又可以美餐一顿了。]],650,150,60}}, answer={{1}}},
	[3] = {type=3, reward={{1,{{80246,3}}}}, dialogue={{[[堕天使之影]],0,0,[[luxifa]],[[人类，我这庭院好看么？我觉得这可比那肮脏的神界好看多了。]],450,150,80},{[[堕天使之影]],0,0,[[luxifa]],[[小心你的脚下，所有为了一己私利的争斗都不应该波及无辜，可爱的蔷薇也不应该被伤害。]],450,150,80},{[[堕天使之影]],0,0,[[luxifa]],[[沿着这条小道走来，我在庭院中央恭候大驾。]],450,150,80}}, answer={{1}}},
	[4] = {type=4, reward={{1,{{80246,3}}}}, dialogue={{[[魔王之影]],0,0,[[heianzhizhu]],[[有意思的人类，看来造物主大人让我来坐镇这座城也没想象中的那么无聊嘛。]],600,100,70},{[[魔王之影]],0,0,[[heianzhizhu]],[[打败我，去寻找时之隙间，你就会明白伟大的造物主大人到底是谁。]],600,100,70}}, answer={{1}}},
	[5] = {type=5, reward={{1,{{80246,3}}}}, dialogue={{[[死神]],0,0,[[haila]],[[欢迎来到时之隙间——造物主们创造出来的特异空间。]],350,100,85},{[[死神]],0,0,[[haila]],[[这里面存在着无数的巴格——我们的敌人，也正因此，我们需要冒险者的力量来帮我们消灭巴格。]],350,100,85}}, answer={{1}}}
}
Config.MonopolyMapsData.data_drama_fun = function(key)
	local data=Config.MonopolyMapsData.data_drama[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyMapsData.data_drama['..key..'])not found') return
	end
	return data
end
-- -------------------drama_end---------------------


-- -------------------buff_tips_start-------------------
Config.MonopolyMapsData.data_buff_tips_length = 3
Config.MonopolyMapsData.data_buff_tips = {
	[2] = {id=2, desc="魔女的药锅"},
	[3] = {id=3, desc="这就是希望么"},
	[4] = {id=4, desc="弗拉格"}
}
Config.MonopolyMapsData.data_buff_tips_fun = function(key)
	local data=Config.MonopolyMapsData.data_buff_tips[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyMapsData.data_buff_tips['..key..'])not found') return
	end
	return data
end
-- -------------------buff_tips_end---------------------

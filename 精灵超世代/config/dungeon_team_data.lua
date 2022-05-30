----------------------------------------------------
-- 此文件由数据工具生成
-- 副本配置数据--dungeon_team_data.xml
--------------------------------------

Config = Config or {} 
Config.DungeonTeamData = Config.DungeonTeamData or {}

-- -------------------team_const_start-------------------
Config.DungeonTeamData.data_team_const_length = 2
Config.DungeonTeamData.data_team_const = {
	["max_hero_num"] = {label='max_hero_num', val=6, desc="最大上阵单位数"},
	["join_lev"] = {label='join_lev', val=50, desc="参与等级"}
}
-- -------------------team_const_end---------------------


-- -------------------team_data_start-------------------
Config.DungeonTeamData.data_team_data_length = 4
Config.DungeonTeamData.data_team_data = {
	[1] = {diff=1, limit_lev=50, name="普通", unit={32600,32601,32602}, drop_id=42000, expend=15, expend2=8, award_list={{51133,51134,51135,10214,10201}}, skill_list={900601,900611,900621,900631,900641}, msg1="神圣巨龙三位一体，需要3人组队共同击杀掉3个BOSS才能获取最终胜利", msg2="神界试炼需要由3名领主各带6位英雄出战分别挑战3个BOSS。全队击杀完3个BOSS则获取胜利，全部出战队伍阵亡则失败，先战胜BOSS的领主将进入观战模式，观看队友战斗，并给予士气鼓舞，提升队友全队英雄攻击力和防御力，反之，BOSS击杀玩家后，会将剩余血量传输给存活的BOSS，并给BOSS增加攻击力。BOSS会越战越勇，需尽快解决战斗哦！"},
	[2] = {diff=2, limit_lev=55, name="困难", unit={32605,32606,32607}, drop_id=42001, expend=20, expend2=10, award_list={{51136,51137,51138,10214,10201}}, skill_list={900601,900611,900621,900631,900641}, msg1="神圣巨龙三位一体，需要3人组队共同击杀掉3个BOSS才能获取最终胜利", msg2="神界试炼需要由3名领主各带6位英雄出战分别挑战3个BOSS。全队击杀完3个BOSS则获取胜利，全部出战队伍阵亡则失败，先战胜BOSS的领主将进入观战模式，观看队友战斗，并给予士气鼓舞，提升队友全队英雄攻击力和防御力，反之，BOSS击杀玩家后，会将剩余血量传输给存活的BOSS，并给BOSS增加攻击力。BOSS会越战越勇，需尽快解决战斗哦！"},
	[3] = {diff=3, limit_lev=60, name="噩梦", unit={32610,32611,32612}, drop_id=42002, expend=25, expend2=12, award_list={{51139,51140,51141,10214,10201}}, skill_list={900601,900611,900621,900631,900641}, msg1="神圣巨龙三位一体，需要3人组队共同击杀掉3个BOSS才能获取最终胜利", msg2="神界试炼需要由3名领主各带6位英雄出战分别挑战3个BOSS。全队击杀完3个BOSS则获取胜利，全部出战队伍阵亡则失败，先战胜BOSS的领主将进入观战模式，观看队友战斗，并给予士气鼓舞，提升队友全队英雄攻击力和防御力，反之，BOSS击杀玩家后，会将剩余血量传输给存活的BOSS，并给BOSS增加攻击力。BOSS会越战越勇，需尽快解决战斗哦！"},
	[4] = {diff=4, limit_lev=65, name="地狱", unit={32615,32616,32617}, drop_id=42003, expend=30, expend2=15, award_list={{51142,51143,51144,10214,10201}}, skill_list={900601,900611,900621,900631,900641}, msg1="神圣巨龙三位一体，需要3人组队共同击杀掉3个BOSS才能获取最终胜利", msg2="神界试炼需要由3名领主各带6位英雄出战分别挑战3个BOSS。全队击杀完3个BOSS则获取胜利，全部出战队伍阵亡则失败，先战胜BOSS的领主将进入观战模式，观看队友战斗，并给予士气鼓舞，提升队友全队英雄攻击力和防御力，反之，BOSS击杀玩家后，会将剩余血量传输给存活的BOSS，并给BOSS增加攻击力。BOSS会越战越勇，需尽快解决战斗哦！"}
}
-- -------------------team_data_end---------------------


-- -------------------team_power_start-------------------
Config.DungeonTeamData.data_team_power_length = 7
Config.DungeonTeamData.data_team_power = {
	[1] = {id=1, need_power=0},
	[2] = {id=2, need_power=300000},
	[3] = {id=3, need_power=350000},
	[4] = {id=4, need_power=400000},
	[5] = {id=5, need_power=500000},
	[6] = {id=6, need_power=600000},
	[7] = {id=7, need_power=700000}
}
-- -------------------team_power_end---------------------

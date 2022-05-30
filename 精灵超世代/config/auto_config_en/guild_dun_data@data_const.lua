-- this file is generated by program!
-- don't change it manaully.
-- source file: guild_dun_data.xls

Config = Config or {} 
Config.GuildDunData = Config.GuildDunData or {}
Config.GuildDunData.data_const_key_depth = 1
Config.GuildDunData.data_const_length = 28
Config.GuildDunData.data_const_lan = "en"
Config.GuildDunData.data_const = {
	["action_time"] = {key="action_time",val=15,desc="The number of actions per challenge"},
	["bosstype_1"] = {key="bosstype_1",val={},desc="The Boss special defense is low, and special attack output is recommended"},
	["bosstype_2"] = {key="bosstype_2",val={},desc="The Boss has low physical defense, and physical attack output is recommended"},
	["box_max_num"] = {key="box_max_num",val=40,desc="Total number of treasure chests"},
	["buff_cost"] = {key="buff_cost",val=20,desc="Activate & Strengthen Buff consumption of red and blue diamonds"},
	["buff_item"] = {key="buff_item",val=10020,desc="Activate & strengthen Buff consumption item ID"},
	["coin_box"] = {key="coin_box",val=21,desc="Number of Treasure Box 4 (Gold Coins)"},
	["concentrate_cd"] = {key="concentrate_cd",val=3600,desc="Gathering cooling time (unit: second)"},
	["des_nobuff"] = {key="des_nobuff",val={},desc="All Guild members\' attack power +0%"},
	["double_time"] = {key="double_time",val={},desc="Double reward time period"},
	["free_time"] = {key="free_time",val=2,desc="Daily initial free times"},
	["game_rule"] = {key="game_rule",val=1,desc="1. Every time you challenge the Boss in the dungeon, you will get <div fontcolor=289b14>Guild Contributions</div>, <div fontcolor=289b14>Gold Coins</div>\n2. After killing the Boss, it will be based on the damage caused by the Guild members The ranking will issue settlement rewards, and the killer will get an extra <div fontcolor=289b14>kill reward</div>, and the Guild will get a certain amount of <div fontcolor=289b14>Guild XP</div>\n3. Players have 2 per day The number of free challenges is reset at 0 o\'clock every day. In addition, players can consume diamonds to purchase additional challenges\n4. The sweep will inherit the damage of the previous challenge for settlement, and the sweep will also consume 1 point of challenge\n5. Consumption< div fontcolor=289b14>The Guild Increase Order</div> or <div fontcolor=289b14>Diamond</div> can activate or increase the <div fontcolor=289b14>All Guild members increase the Attack Buff</div> effect, and the maximum can be increased to 20% Attack Power Bonus. Each Boss kill reward can only be obtained once per character, and only the guaranteed bonus will be obtained when changing Guilds and repeating kills."},
	["gold_box"] = {key="gold_box",val=1,desc="Number of Treasure Box 1 (Summoning Book)"},
	["guild_box"] = {key="guild_box",val=10,desc="Number of Treasure Box 3 (contribution)"},
	["guild_lev"] = {key="guild_lev",val=1,desc="Guild reaches level 1 to open"},
	["hero_soul_box"] = {key="hero_soul_box",val=8,desc="Number of Treasure Box 2 (God)"},
	["join_lev"] = {key="join_lev",val=10,desc="Minimum participation level of members"},
	["praise_reward"] = {key="praise_reward",val={{2,3000}},desc="Like reward"},
	["praise_time"] = {key="praise_time",val=3,desc="Likes limit"},
	["rank_dam"] = {key="rank_dam",val=2000,desc="Minimum damage required to be on the list"},
	["recover_time"] = {key="recover_time",val={},desc="Resume 1 challenge every X minutes"},
	["reset_desc_0"] = {key="reset_desc_0",val="正常重置",desc="Tomorrow\'s Guild copy reset to the highest chapter in history"},
	["reset_desc_1"] = {key="reset_desc_1",val="章节回退",desc="The copy of the Guild of Tomorrow is reset to the previous chapter of the highest chapter in history"},
	["resetting_time"] = {key="resetting_time",val={0,0,0},desc="What time do you reset the copy every day"},
	["reward_desc01"] = {key="reward_desc01",val={},desc="The higher the number of clearances, the greater the reward!"},
	["reward_desc02"] = {key="reward_desc02",val={},desc="Every Monday <div fontcolor=289b14>00:00</div> the reward will be settled according to the highest number of clearances, and will be distributed to all members of the Guild via email"},
	["rumour_items"] = {key="rumour_items",val={10201},desc="Rumored props"},
	["time_quantum"] = {key="time_quantum",val={},desc="Time period of recovery times per day"},
}

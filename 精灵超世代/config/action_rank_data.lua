----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--action_rank_data.xml
--------------------------------------

Config = Config or {} 
Config.ActionRankData = Config.ActionRankData or {}

-- -------------------get_start-------------------
Config.ActionRankData.data_get_length = 2
Config.ActionRankData.data_get = {
	[199002] = {{tab_name="", sort_val=1, title_list={{"排名",145},{"名称",200},{"次数",315}}, first_desc="最高名次", item_type=3}
	},
	[199001] = {{tab_name="星阶", sort_val=1, title_list={{"排名",145},{"名称",200},{"英雄",152},{"星阶",163}}, first_desc="最高星阶", item_type=1},
		{tab_name="等级", sort_val=2, title_list={{"排名",145},{"名称",200},{"英雄",152},{"等级",163}}, first_desc="最高等级", item_type=2}
	},
}
-- -------------------get_end---------------------
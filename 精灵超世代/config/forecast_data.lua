----------------------------------------------------
-- 此文件由数据工具生成
-- 预告配置--forecast_data.xml
--------------------------------------

Config = Config or {} 
Config.ForecastData = Config.ForecastData or {}

-- -------------------forecast_level_start-------------------
Config.ForecastData.data_forecast_level_length = 13
Config.ForecastData.data_forecast_level = {
	[1] = {id=1, next_id=2, title="上阵4人", content="强力英雄上阵，助领主一臂之力", sub_content="上阵第4位英雄，大幅提高领主战力！", icon_res="forecast_icon_set", show_level={{99,99}}, open_lev=9, title_res="txt_cn_forecast_form"},
	[2] = {id=2, next_id=3, title="竞技场", content="攻防兼备，争夺竞技王座", sub_content="冲排名，海量钻石等你来拿！", icon_res="forecast_icon_arena", show_level={{99,99}}, open_lev=10, title_res="txt_cn_forecast_jjc"},
	[3] = {id=3, next_id=4, title="日常任务", content="每日完成日常任务，快速提升！", sub_content="这可是快速升级的好途径哦！", icon_res="forecast_icon_daily", show_level={{99,99}}, open_lev=11, title_res="txt_cn_forecast_rcrw"},
	[4] = {id=4, next_id=5, title="试炼塔", content="试炼之塔，只有勇者才能抵达塔顶", sub_content="首通送钻石，前往挑战吧!", icon_res="forecast_icon_trial", show_level={{99,99}}, open_lev=15, title_res="txt_cn_forecast_slt"},
	[5] = {id=5, next_id=6, title="联盟", content="齐心协力，共同进退", sub_content="快来加入联盟，和小伙伴打招呼!", icon_res="forecast_icon_guild", show_level={{99,99}}, open_lev=17, title_res="txt_cn_forecast_lm"},
	[6] = {id=6, next_id=7, title="凤凰神殿", content="不灭的凤凰，你能否征服它？", sub_content="凤凰神殿，产出大量英雄经验~", icon_res="forecast_icon_titan", show_level={{99,99}}, open_lev=18, title_res="txt_cn_forecast_fhsd"},
	[7] = {id=7, next_id=8, title="巨龙巢穴", content="远古巨龙到底在守护什么秘密呢？", sub_content="巨龙巢穴，产出大量金币~", icon_res="forecast_icon_dragon", show_level={{99,99}}, open_lev=20, title_res="txt_cn_forecast_jlsd"},
	[8] = {id=8, next_id=9, title="装备副本", content="千锤百炼，珍稀装备任你搭配", sub_content="穿戴装备，快速提升英雄战斗力！", icon_res="forecast_icon_eqm", show_level={{99,99}}, open_lev=22, title_res="txt_cn_forecast_zbfb"},
	[9] = {id=9, next_id=10, title="段位赛", content="高手对决，赛季王者等你挑战！", sub_content="海量钻石、万能碎片等你来拿！", icon_res="forecast_icon_darance", show_level={{99,99}}, open_lev=25, title_res="txt_cn_forecast_dws"},
	[10] = {id=10, next_id=11, title="英雄远征", content="远方的宝藏正在等待您的探索", sub_content="培养更多英雄，才能持久战斗！", icon_res="forecast_icon_exp", show_level={{99,99}}, open_lev=26, title_res="txt_cn_forecast_yxyz"},
	[11] = {id=11, next_id=12, title="大陆争霸", content="挑战世界BOSS，角逐大陆霸主！", sub_content="培养多队伍英雄，多路出征！", icon_res="forecast_icon_world", show_level={{99,99}}, open_lev=28, title_res="txt_cn_forecast_world"},
	[12] = {id=12, next_id=13, title="异界裂缝", content="洗炼石改变装备指定属性！", sub_content="极品属性洗一洗就出来了！", icon_res="forecast_icon_liefeng", show_level={{99,99}}, open_lev=32, title_res="txt_cn_forecast_liefeng"},
	[13] = {id=13, next_id=0, title="星宫助阵", content="合理放置，大幅提升英雄属性！", sub_content="英雄数量越多越好哦！", icon_res="forecast_icon_starpalace", show_level={{99,99}}, open_lev=40, title_res="txt_cn_forecast_starpalace"}
}
-- -------------------forecast_level_end---------------------


-- -------------------forecast_const_start-------------------
Config.ForecastData.data_forecast_const_length = 2
Config.ForecastData.data_forecast_const = {
	["min_level"] = {label='min_level', val=99, desc="最小需要显示预告栏的等级"},
	["max_level"] = {label='max_level', val=99, desc="最大需要显示预告栏的等级"}
}
-- -------------------forecast_const_end---------------------

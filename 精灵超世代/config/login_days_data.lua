----------------------------------------------------
-- 此文件由数据工具生成
-- 七日登录配置数据--login_days_data.xml
--------------------------------------

Config = Config or {} 
Config.LoginDaysData = Config.LoginDaysData or {}

-- -------------------day_start-------------------
Config.LoginDaysData.data_day_length = 7
Config.LoginDaysData.data_day = {
	[1] = {day=1, name="第一天", desc="钻石200", rewards={{3,200},{10001,100},{1,20000},{22,20000}}, reward_desc="这是一个很厉害的描述这是一个很厉害的描述", action=5, pos={{281,104}}, is_spe_day=0, icon=505, spec_reward={4}, day_desc="领大量钻石", next_desc="明日领奥丁"},
	[2] = {day=2, name="第二天", desc="五星奥丁", rewards={{26900,50},{10001,150},{1,30000},{22,30000}}, reward_desc="这是一个很厉害的描述这是一个很厉害的描述", action=4, pos={{318,102}}, is_spe_day=1, icon=5051, spec_reward={26016}, day_desc="领五星奥丁", next_desc="明日美杜莎"},
	[3] = {day=3, name="第三天", desc="五星美杜莎", rewards={{26904,50},{10001,200},{1,50000},{22,50000}}, reward_desc="这是一个很厉害的描述这是一个很厉害的描述", action=6, pos={{294,102}}, is_spe_day=1, icon=505, spec_reward={10402}, day_desc="领美杜莎", next_desc="明日领橙武"},
	[4] = {day=4, name="第四天", desc="全套橙武", rewards={{40108,1},{40308,1},{40208,1},{22,50000}}, reward_desc="这是一个很厉害的描述这是一个很厉害的描述", action=7, pos={{301,104}}, is_spe_day=0, icon=505, spec_reward={44105}, day_desc="领橙武", next_desc="明日高级券"},
	[5] = {day=5, name="第五天", desc="高级寻宝", rewards={{37002,1},{10002,5},{1,100000},{22,80000}}, reward_desc="这是一个很厉害的描述这是一个很厉害的描述", action=2, pos={{257,103}}, is_spe_day=0, icon=505, spec_reward={60033}, day_desc="领寻宝券", next_desc="明日刻印石"},
	[6] = {day=6, name="第六天", desc="神器刻印石", rewards={{72003,1},{72001,10},{1,120000},{22,100000}}, reward_desc="这是一个很厉害的描述这是一个很厉害的描述", action=3, pos={{293,104}}, is_spe_day=0, icon=505, spec_reward={35113}, day_desc="领刻印石", next_desc="明日先知水晶"},
	[7] = {day=7, name="第七天", desc="先知水晶", rewards={{14001,1},{10001,300},{1,150000},{22,150000}}, reward_desc="这是一个很厉害的描述这是一个很厉害的描述", action=9, pos={{275,71}}, is_spe_day=0, icon=5052, spec_reward={26055}, day_desc="领先知水晶", next_desc="领先知水晶"}
}
Config.LoginDaysData.data_day_fun = function(key)
	local data=Config.LoginDaysData.data_day[key]
	if DATA_DEBUG and data == nil then
		print('(Config.LoginDaysData.data_day['..key..'])not found') return
	end
	return data
end
-- -------------------day_end---------------------

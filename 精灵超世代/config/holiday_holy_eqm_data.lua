----------------------------------------------------
-- 此文件由数据工具生成
-- 神装常驻运营礼包配置数据--holiday_holy_eqm_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayHolyEqmData = Config.HolidayHolyEqmData or {}

-- -------------------constant_start-------------------
Config.HolidayHolyEqmData.data_constant_length = 0
Config.HolidayHolyEqmData.data_constant = {

}
Config.HolidayHolyEqmData.data_constant_fun = function(key)
	local data=Config.HolidayHolyEqmData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayHolyEqmData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------reward_list_start-------------------
Config.HolidayHolyEqmData.data_reward_list_length = 5
Config.HolidayHolyEqmData.data_reward_list = {
	[1] = {
		[1] = {f_id=1, id=1, min_dun_id=10001, max_dun_id=10049, award={{3,1280},{39497,1},{17201,20},{10030,80}}, price=128, charge_id=725, limit_day=0, limit_week=0, limit_month=0, limit_all=1, limit_type=4},
		[2] = {f_id=1, id=2, min_dun_id=10001, max_dun_id=10049, award={{3,1280},{17201,32},{28,120},{1,2000000}}, price=128, charge_id=721, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
		[3] = {f_id=1, id=3, min_dun_id=10001, max_dun_id=10049, award={{3,3280},{17201,68},{28,300},{1,5000000}}, price=328, charge_id=722, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
	},
	[2] = {
		[1] = {f_id=2, id=1, min_dun_id=10050, max_dun_id=10089, award={{3,1980},{39501,1},{17202,26},{10030,120}}, price=198, charge_id=726, limit_day=0, limit_week=0, limit_month=0, limit_all=1, limit_type=4},
		[2] = {f_id=2, id=2, min_dun_id=10050, max_dun_id=10089, award={{3,1280},{17202,32},{28,120},{1,2000000}}, price=128, charge_id=721, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
		[3] = {f_id=2, id=3, min_dun_id=10050, max_dun_id=10089, award={{3,3280},{17202,68},{28,300},{1,5000000}}, price=328, charge_id=722, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
	},
	[3] = {
		[1] = {f_id=3, id=1, min_dun_id=10090, max_dun_id=10159, award={{3,3280},{39505,1},{17203,36},{10030,220}}, price=328, charge_id=727, limit_day=0, limit_week=0, limit_month=0, limit_all=1, limit_type=4},
		[2] = {f_id=3, id=2, min_dun_id=10090, max_dun_id=10159, award={{3,1280},{17203,32},{28,120},{1,2000000}}, price=128, charge_id=721, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
		[3] = {f_id=3, id=3, min_dun_id=10090, max_dun_id=10159, award={{3,3280},{17203,68},{28,300},{1,5000000}}, price=328, charge_id=722, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
	},
	[4] = {
		[1] = {f_id=4, id=1, min_dun_id=10160, max_dun_id=10249, award={{3,4480},{39509,1},{17204,42},{10030,300}}, price=448, charge_id=728, limit_day=0, limit_week=0, limit_month=0, limit_all=1, limit_type=4},
		[2] = {f_id=4, id=2, min_dun_id=10160, max_dun_id=10249, award={{3,1280},{17204,32},{28,120},{1,2000000}}, price=128, charge_id=721, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
		[3] = {f_id=4, id=3, min_dun_id=10160, max_dun_id=10249, award={{3,3280},{17204,68},{28,300},{1,5000000}}, price=328, charge_id=722, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
	},
	[5] = {
		[1] = {f_id=5, id=1, min_dun_id=10250, max_dun_id=10350, award={{3,4480},{39509,1},{17205,42},{10030,300}}, price=448, charge_id=728, limit_day=0, limit_week=0, limit_month=0, limit_all=1, limit_type=4},
		[2] = {f_id=5, id=2, min_dun_id=10250, max_dun_id=10350, award={{3,1280},{17205,32},{28,120},{1,2000000}}, price=128, charge_id=721, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
		[3] = {f_id=5, id=3, min_dun_id=10250, max_dun_id=10350, award={{3,3280},{17205,68},{28,300},{1,5000000}}, price=328, charge_id=722, limit_day=0, limit_week=3, limit_month=0, limit_all=0, limit_type=2},
	},
}
-- -------------------reward_list_end---------------------

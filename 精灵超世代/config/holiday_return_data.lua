----------------------------------------------------
-- 此文件由数据工具生成
-- 回归活动配置数据--holiday_return_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayReturnData = Config.HolidayReturnData or {}

-- -------------------constant_start-------------------
Config.HolidayReturnData.data_constant_length = 4
Config.HolidayReturnData.data_constant = {
	["privilege_rule"] = {label='privilege_rule', val=1, desc="1.回归特权共持续14天，包含加成，礼包以及币章获得\n2.荣耀臂章可在回归商店兑换超值奖励\n3.活动结束后商店会额外开启2日，但不能获得荣耀臂章\n4.活动商店关闭后荣耀臂章将无法使用！"},
	["privilege_desc"] = {label='privilege_desc', val=1, desc="1.7天未登录且等级达到10级，即可领取回归特权\n2.推图3倍加速，挂机奖励加成20%，升级升星材料减半（金币，英雄经验，进阶石）\n3.活动期间完成任务和挂机战斗，可获得荣耀臂章（含快速战斗）"},
	["store_rule"] = {label='store_rule', val=1, desc="1.消耗荣耀臂章兑换超值奖励\n2.活动结束后商店会额外开启2日，但不能获得荣耀臂章\n3.活动商店关闭后荣耀臂章将无法使用！"},
	["item_id"] = {label='item_id', val=80120, desc="活动道具"}
}
Config.HolidayReturnData.data_constant_fun = function(key)
	local data=Config.HolidayReturnData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------action_holiday_start-------------------
Config.HolidayReturnData.data_action_holiday_length = 1
Config.HolidayReturnData.data_action_holiday = {
	[1] = {
		[101] = {camp_id=101, period=1, min_day=1, max_day=14, title="回归特权", ico="125", panel_type=121, panel_res="txt_cn_returnaction1"},
		[102] = {camp_id=102, period=1, min_day=1, max_day=14, title="回归签到", ico="126", panel_type=122, panel_res="txt_cn_returnaction2"},
		[103] = {camp_id=103, period=1, min_day=1, max_day=14, title="回归任务", ico="127", panel_type=123, panel_res="txt_cn_welfare_return1"},
		[104] = {camp_id=104, period=1, min_day=1, max_day=16, title="回归商店", ico="128", panel_type=124, panel_res="txt_cn_welfare_return2"},
		[105] = {camp_id=105, period=1, min_day=1, max_day=14, title="超值特惠", ico="129", panel_type=125, panel_res="txt_cn_welfare_return3"},
	},
}
-- -------------------action_holiday_end---------------------


-- -------------------privilege_start-------------------
Config.HolidayReturnData.data_privilege_length = 1
Config.HolidayReturnData.data_privilege = {
	[1] = {rewards={{10403,10},{37001,2},{10002,3},{1,1000000}}, change_id=1101, new_price=6, old_price=198}
}
Config.HolidayReturnData.data_privilege_fun = function(key)
	local data=Config.HolidayReturnData.data_privilege[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnData.data_privilege['..key..'])not found') return
	end
	return data
end
-- -------------------privilege_end---------------------


-- -------------------shop_start-------------------
Config.HolidayReturnData.data_shop_length = 10
Config.HolidayReturnData.data_shop = {
	[1] = {id=1, expend={{80120,1}}, award={{3,100}}, r_limit_day=1, r_limit_all=14, title="活动限兑", sub_type=1},
	[2] = {id=2, expend={{80120,5}}, award={{10450,250}}, r_limit_day=3, r_limit_all=42, title="活动限兑", sub_type=1},
	[3] = {id=3, expend={{80120,5}}, award={{37001,5}}, r_limit_day=3, r_limit_all=42, title="活动限兑", sub_type=1},
	[4] = {id=4, expend={{80120,5}}, award={{10403,1}}, r_limit_day=3, r_limit_all=42, title="活动限兑", sub_type=1},
	[5] = {id=5, expend={{80120,10}}, award={{38092,1}}, r_limit_day=0, r_limit_all=10, title="活动限兑", sub_type=2},
	[6] = {id=6, expend={{80120,10}}, award={{37002,2}}, r_limit_day=0, r_limit_all=20, title="活动限兑", sub_type=2},
	[7] = {id=7, expend={{80120,10}}, award={{14001,1}}, r_limit_day=0, r_limit_all=10, title="活动限兑", sub_type=2},
	[8] = {id=8, expend={{80120,20}}, award={{10453,1}}, r_limit_day=0, r_limit_all=5, title="活动限兑", sub_type=2},
	[9] = {id=9, expend={{80120,20}}, award={{29905,50}}, r_limit_day=0, r_limit_all=1, title="活动限兑", sub_type=2},
	[10] = {id=10, expend={{80120,30}}, award={{27905,50}}, r_limit_day=0, r_limit_all=1, title="活动限兑", sub_type=2}
}
Config.HolidayReturnData.data_shop_fun = function(key)
	local data=Config.HolidayReturnData.data_shop[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnData.data_shop['..key..'])not found') return
	end
	return data
end
-- -------------------shop_end---------------------


-- -------------------signin_start-------------------
Config.HolidayReturnData.data_signin_length = 7
Config.HolidayReturnData.data_signin = {
	[1] = {day=1, name="第一天", rewards={{10403,1},{29905,5}}},
	[2] = {day=2, name="第二天", rewards={{3,200},{29905,5}}},
	[3] = {day=3, name="第三天", rewards={{37001,5},{29905,5}}},
	[4] = {day=4, name="第四天", rewards={{10403,1},{29905,5}}},
	[5] = {day=5, name="第五天", rewards={{10450,200},{29905,10}}},
	[6] = {day=6, name="第六天", rewards={{72001,20},{29905,10}}},
	[7] = {day=7, name="第七天", rewards={{50908,1},{29905,10}}}
}
Config.HolidayReturnData.data_signin_fun = function(key)
	local data=Config.HolidayReturnData.data_signin[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnData.data_signin['..key..'])not found') return
	end
	return data
end
-- -------------------signin_end---------------------


-- -------------------recharge_start-------------------
Config.HolidayReturnData.data_recharge_length = 1
Config.HolidayReturnData.data_recharge = {
	[1] = {
		[0] = {charge_id=0, period=1, val=0, name="0元特惠礼包", limit_count=1, reward={{37001,2},{10002,3},{10001,100},{80120,1}}},
		[1102] = {charge_id=1102, period=1, val=30, name="30元特惠礼包", limit_count=3, reward={{10403,3},{72001,30},{37001,2},{80120,5}}},
		[1103] = {charge_id=1103, period=1, val=68, name="68元特惠礼包", limit_count=3, reward={{10403,7},{10450,500},{10001,300},{80120,12}}},
		[1104] = {charge_id=1104, period=1, val=128, name="128元特惠礼包", limit_count=3, reward={{14001,2},{37002,1},{1,1000000},{80120,24}}},
		[1105] = {charge_id=1105, period=1, val=328, name="328元特惠礼包", limit_count=3, reward={{29905,50},{14001,2},{38081,1},{80120,65}}},
		[1106] = {charge_id=1106, period=1, val=448, name="448元特惠礼包", limit_count=2, reward={{14001,5},{37002,5},{1,5000000},{80120,88}}},
		[1107] = {charge_id=1107, period=1, val=648, name="648元特惠礼包", limit_count=1, reward={{29906,50},{14001,5},{38061,1},{80120,128}}},
	},
}
-- -------------------recharge_end---------------------


-- -------------------task_start-------------------
Config.HolidayReturnData.data_task_length = 1
Config.HolidayReturnData.data_task = {
	[1] = {
		[1001] = {id=1001, title="日常登录", desc="日常登录1次", award={{80120,1}}, source_id=0},
		[1002] = {id=1002, title="好友赠送", desc="每天赠送好友友情点5次", award={{80120,1}}, source_id=402},
		[1003] = {id=1003, title="召唤", desc="进行3次召唤", award={{80120,2}}, source_id=120},
		[1004] = {id=1004, title="竞技场", desc="参与3次竞技场挑战", award={{80120,2}}, source_id=158},
		[1005] = {id=1005, title="快速作战", desc="快速作战5次", award={{80120,2}}, source_id=132},
		[1006] = {id=1006, title="试炼塔挑战", desc="挑战或扫荡试炼塔任意层3次", award={{80120,2}}, source_id=160},
		[1007] = {id=1007, title="无尽试炼", desc="参与1次无尽试炼", award={{80120,2}}, source_id=153},
		[1008] = {id=1008, title="悬赏任务", desc="接取3次远航订单", award={{80120,5}}, source_id=126},
		[1009] = {id=1009, title="神器副本", desc="参与2次日常副本", award={{80120,5}}, source_id=152},
		[1010] = {id=1010, title="英雄远征", desc="英雄远征胜利3次", award={{80120,5}}, source_id=151},
	},
}
-- -------------------task_end---------------------

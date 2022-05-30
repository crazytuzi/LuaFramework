----------------------------------------------------
-- 此文件由数据工具生成
-- 元旦充值返利配置数据--holiday_charge_rebate_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayChargeRebateData = Config.HolidayChargeRebateData or {}

-- -------------------constant_start-------------------
Config.HolidayChargeRebateData.data_constant_length = 4
Config.HolidayChargeRebateData.data_constant = {
	["rebate_gold_sum"] = {key='rebate_gold_sum', val=10000, desc="返利钻石总数"},
	["rebate_pro"] = {key='rebate_pro', val=400, desc="返利比例（扩大1000倍）"},
	["rebate_pro_res"] = {key='rebate_pro_res', val='txt_cn_welfare_10', desc="面板百分比资源（百分之30：txt_cn_welfare_9；百分之40：txt_cn_welfare_10；百分之50：txt_cn_welfare_11）"},
	["rebate_effect"] = {key='rebate_effect', val={528,360,325}, desc="活动面板招财猫特效（参数1:对应EffectData表；参数2：招财猫坐标X；参数3:招财猫坐标Y）"}
}
Config.HolidayChargeRebateData.data_constant_fun = function(key)
	local data=Config.HolidayChargeRebateData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayChargeRebateData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------

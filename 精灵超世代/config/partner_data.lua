----------------------------------------------------
-- 此文件由数据工具生成
-- 伙伴配置数据--partner_data.xml
--------------------------------------


Config = Config or {} 
Config.PartnerData = Config.PartnerData or {}

LocalizedConfigRequire("config.auto_config.partner_data@data_get_compound_info")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_attr")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_base")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_brach")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_buy")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_const")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_form")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_fuse_star")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_lev")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_library")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_max_lev")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_max_star")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_name2bid")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_pokedex")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_return")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_show")
LocalizedConfigRequire("config.auto_config.partner_data@data_partner_star")
--模型缩放文件也在这里包含
LocalizedConfigRequire("config.auto_config.partner_scale_data@data_scale_const")



-- -------------------partner_const_start-------------------
Config.PartnerData.data_partner_const_fun = function(key)
	local data=Config.PartnerData.data_partner_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_const['..key..'])not found') return
	end
	return data
end
-- -------------------partner_const_end---------------------


-- -------------------partner_base_start-------------------
--[[ Config.PartnerData.data_partner_base字段含义
bid 唯一id
name 名字
type 英雄职业类型 = {
    eNone     = 0 , --无
    eMagician     = 2 , --法师
    eWarrior      = 3 , --战士
    eTank         = 4 , --坦克
    eSsistant     = 5 , --辅助
}
pos_type 位置123代表123排
camp_type 英雄阵营类型 = { 
    eNone          = 0 , --无
    eWater         = 1 , --水
    eFire          = 2 , --火
    eWind          = 3 , --风
    eLight         = 4 , --光
    eDark          = 5 , --暗
    eLingtDark     = 6 , --光暗
}
break_id 升阶，对应配置 data_partner_brach
show_order 排序用
init_star 初始星级
hero_pos 定位的描述
voice 音效
voice_time 音效播放时长，为0时则为默认的4秒
show_effect 抽卡抽中时是否展示特效和音效
bustid 半身像资源，在resource/partner/下
item_id 物品 与配置表 Config.ItemData1(或者23).data_unit 对应
draw_res 全身像 在resource/herodraw/herodrawres/下
draw_offset 全身像在UI面板中的位置偏移X,Y
draw_scale 全身像缩放，召唤界面有使用
rare_flag 超稀有标识，召唤界面有使用
introduce_str 简介
cystal_lev_limit 客户端未使用
]] 
Config.PartnerData.data_partner_base_fun = function(key)
	local data=Config.PartnerData.data_partner_base[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_base['..key..'])not found') return
	end
	return data
end
-- -------------------partner_base_end---------------------


-- -------------------partner_attr_start-------------------
Config.PartnerData.data_partner_attr_fun = function(key)
	local data=Config.PartnerData.data_partner_attr[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_attr['..key..'])not found') return
	end
	return data
end
-- -------------------partner_attr_end---------------------


-- -------------------partner_lev_start-------------------
Config.PartnerData.data_partner_lev_fun = function(key)
	local data=Config.PartnerData.data_partner_lev[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_lev['..key..'])not found') return
	end
	return data
end
-- -------------------partner_lev_end---------------------


-- -------------------partner_brach_start-------------------
Config.PartnerData.data_partner_brach_fun = function(key)
	local data=Config.PartnerData.data_partner_brach[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_brach['..key..'])not found') return
	end
	return data
end
-- -------------------partner_brach_end---------------------


-- -------------------partner_star_start-------------------
-- -------------------partner_star_end---------------------


-- -------------------partner_fuse_star_start-------------------
-- -------------------partner_fuse_star_end---------------------


-- -------------------partner_pokedex_start-------------------
-- -------------------partner_pokedex_end---------------------


-- -------------------get_compound_info_start-------------------
Config.PartnerData.data_get_compound_info_fun = function(key)
	local data=Config.PartnerData.data_get_compound_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_get_compound_info['..key..'])not found') return
	end
	return data
end
-- -------------------get_compound_info_end---------------------


-- -------------------partner_buy_start-------------------
Config.PartnerData.data_partner_buy_fun = function(key)
	local data=Config.PartnerData.data_partner_buy[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_buy['..key..'])not found') return
	end
	return data
end
-- -------------------partner_buy_end---------------------


-- -------------------partner_show_start-------------------
-- -------------------partner_show_end---------------------


-- -------------------partner_max_star_start-------------------
-- -------------------partner_max_star_end---------------------


-- -------------------partner_max_lev_start-------------------
-- -------------------partner_max_lev_end---------------------


-- -------------------partner_library_start-------------------
-- -------------------partner_library_end---------------------


-- -------------------partner_form_start-------------------
Config.PartnerData.data_partner_form_fun = function(key)
	local data=Config.PartnerData.data_partner_form[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_form['..key..'])not found') return
	end
	return data
end
-- -------------------partner_form_end---------------------


-- -------------------partner_return_start-------------------
Config.PartnerData.data_partner_return_fun = function(key)
	local data=Config.PartnerData.data_partner_return[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerData.data_partner_return['..key..'])not found') return
	end
	return data
end
-- -------------------partner_return_end---------------------


-- -------------------partner_name2bid_start-------------------
-- -------------------partner_name2bid_end---------------------

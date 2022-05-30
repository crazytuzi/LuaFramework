----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_skin_draw_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidaySkinDrawData = Config.HolidaySkinDrawData or {}

-- -------------------const_start-------------------
Config.HolidaySkinDrawData.data_const_length = 4
Config.HolidaySkinDrawData.data_const = {
	["item"] = {val=37009, desc="祈愿星石"},
	["rule"] = {val=0, desc="1、活动期间，进行N次【皮肤活动XX字】祈愿，必定可以获得包括【XX皮肤】皮肤在内的全部祈愿池物品！"},
	["change_diamo"] = {val={3,10}, desc="1星等额钻石"},
	["change_gold"] = {val={1,100000}, desc="1星转换金币"}
}
Config.HolidaySkinDrawData.data_const_fun = function(key)
	local data=Config.HolidaySkinDrawData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidaySkinDrawData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------consum_count_start-------------------
Config.HolidaySkinDrawData.data_consum_count_length = 1
Config.HolidaySkinDrawData.data_consum_count = {
	[1001] = {
		[1] = {loss_id=37009, num=0},
		[2] = {loss_id=37009, num=16},
		[3] = {loss_id=37009, num=24},
		[4] = {loss_id=37009, num=40},
		[5] = {loss_id=37009, num=65},
		[6] = {loss_id=37009, num=90},
		[7] = {loss_id=37009, num=125},
		[8] = {loss_id=37009, num=160},
		[9] = {loss_id=37009, num=200},
		[10] = {loss_id=37009, num=240},
	},
}
-- -------------------consum_count_end---------------------


-- -------------------lottery_stock_start-------------------
Config.HolidaySkinDrawData.data_lottery_stock_length = 1
Config.HolidaySkinDrawData.data_lottery_stock = {
	[1001] = {
		[10] = {reward_id=10450, num=500, sort=10},
		[9] = {reward_id=10002, num=10, sort=9},
		[8] = {reward_id=37001, num=10, sort=8},
		[7] = {reward_id=10403, num=1, sort=7},
		[6] = {reward_id=37002, num=1, sort=6},
		[5] = {reward_id=29905, num=25, sort=5},
		[4] = {reward_id=10403, num=5, sort=4},
		[3] = {reward_id=35, num=8, sort=3},
		[2] = {reward_id=14001, num=1, sort=2},
		[1] = {reward_id=23019, num=1, sort=1},
	},
}
-- -------------------lottery_stock_end---------------------


-- -------------------lottery_msg_start-------------------
Config.HolidaySkinDrawData.data_lottery_msg_length = 1
Config.HolidaySkinDrawData.data_lottery_msg = {
	[1001] = {lottery_id=1001, lottery_item=37009, star_diammond={{3,10}}, star_coin={{1,100000}}, desc="1、活动期间，进行10次【暗影暴君】祈愿，必定可以获得包括【暗影暴君】皮肤在内的<div fontcolor=#65df74>全部</div>祈愿池物品！\n2、<div fontcolor=#65df74>首次祈愿免费</div>，后续祈愿需要消耗【暗影之石】进行，且消耗数量依次提高。\n3、【暗影之石】可在祈愿按钮直接购买下次祈愿所需的数量，10次祈愿需求的数量分别是<div fontcolor=#65df74>0个，16个，24个，40个，65个，90个，125个，160个，200个，240个</div>\n4、【暗黑祈愿星】每个价值10钻石，<div fontcolor=#65df74>活动结束后将无法使用并会1：1回收为10万金币(以邮件形式发放)</div>，请冒险者大人不要在可祈愿次数为零后额外购买。\n5、当冒险者大人未拥有英雄【黑暗之主】但已拥有皮肤【暗影暴君】时，需要先拥有黑暗之主英雄方可激活皮肤。\n6、<div fontcolor=#65df74>第5次祈愿开始</div>，即有机率可以获得【暗影暴君】服装，参与祈愿的<div fontcolor=#65df74>次数越多</div>，获得【暗影暴君】的概率越大。<div fontcolor=#65df74>10次补给必定可以获得【暗影暴君】！</div>"}
}
Config.HolidaySkinDrawData.data_lottery_msg_fun = function(key)
	local data=Config.HolidaySkinDrawData.data_lottery_msg[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidaySkinDrawData.data_lottery_msg['..key..'])not found') return
	end
	return data
end
-- -------------------lottery_msg_end---------------------

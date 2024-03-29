-- this file is generated by program!
-- don't change it manaully.
-- source file: adventure_data.xls

Config = Config or {} 
Config.AdventureData = Config.AdventureData or {}
Config.AdventureData.data_adventure_const_key_depth = 1
Config.AdventureData.data_adventure_const_length = 11
Config.AdventureData.data_adventure_const_lan = "zh"
Config.AdventureData.data_adventure_const = {
	["adventure_combat_round"] = {key="adventure_combat_round",desc="最大连续挑战场次",val=5},
	["botton_appear"] = {key="botton_appear",desc="宝可梦剩余血量在此值以上显示再次挑战按钮",val=60},
	["businessman_description"] = {key="businessman_description",desc="看来你的运气不错，居然遇上了我。我包里可都是好东西，过了这个镇就只能去我的冒险商店里买啦！",val=1},
	["describe_mora"] = {key="describe_mora",desc="猜拳奖励描述",val="胜、负、平分别获得1.3、1、1.1倍奖励（包括下注奖励）"},
	["guessing_reward"] = {key="guessing_reward",desc="猜拳结果概率（1胜0平2负）",val={{1,100},{0,100},{2,100}}},
	["next_floor_evt_id"] = {key="next_floor_evt_id",desc="时之门ID",val=99999},
	["notice_msg"] = {key="notice_msg",desc="事件发送对话到世界的概率（千分比）",val=50},
	["open_lev"] = {key="open_lev",desc="限制等级",val=35},
	["partner_hp_pro"] = {key="partner_hp_pro",desc="连续挑战宝可梦血量下限（扩大100倍）",val=60},
	["poison_price"] = {key="poison_price",desc="驱魂药剂购买单价",val={{3,30}}},
	["reverse_layer"] = {key="reverse_layer",desc="刷新回退层数",val=7},
}

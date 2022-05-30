----------------------------------------------------
-- 此文件由数据工具生成
-- 时装配置数据--clothes_data.xml
--------------------------------------

Config = Config or {} 
Config.ClothesData = Config.ClothesData or {}

-- -------------------clothes_data_start-------------------
Config.ClothesData.data_clothes_data_length = 5
Config.ClothesData.data_clothes_data = {
	[30008] = {
		[0] = {id=0, clothes_name="经典", partner_name="冰雪女王", partner_bid=30008, item_id=0, model="H30072", icon_id=0, icon="30008", attr={}, day=0, desc="原始拥有", attr_desc="无属性加成", is_classics=1},
		[1000] = {id=1000, clothes_name="圣诞恋歌", partner_name="冰雪女王", partner_bid=30008, item_id=90000, model="H31072", icon_id=1, icon="31008", attr={{'atk_per',50},{'hp_max_per',50}}, day=0, desc="圣诞活动获得", attr_desc="攻击力+5%，生命值+5%", is_classics=0},
	},
	[30004] = {
		[1] = {id=1, clothes_name="经典", partner_name="雅典娜", partner_bid=30004, item_id=0, model="H30058", icon_id=0, icon="30004", attr={}, day=0, desc="原始拥有", attr_desc="无属性加成", is_classics=1},
		[1003] = {id=1003, clothes_name="双马尾萝莉", partner_name="雅典娜", partner_bid=30004, item_id=90001, model="H31058", icon_id=1, icon="31004", attr={{'atk_per',50},{'hp_max_per',50}}, day=0, desc="商城兑换", attr_desc="攻击力+5%，生命值+5%", is_classics=0},
	},
	[30022] = {
		[2] = {id=2, clothes_name="经典", partner_name="吸血伯爵", partner_bid=30022, item_id=0, model="H30060", icon_id=0, icon="30022", attr={}, day=0, desc="原始拥有", attr_desc="无属性加成", is_classics=1},
		[1004] = {id=1004, clothes_name="纯白绅士", partner_name="吸血伯爵", partner_bid=30022, item_id=90002, model="H31060", icon_id=1, icon="31022", attr={{'atk_per',50},{'hp_max_per',50}}, day=0, desc="商城兑换", attr_desc="攻击力+5%，生命值+5%", is_classics=0},
	},
	[30024] = {
		[3] = {id=3, clothes_name="经典", partner_name="影刹", partner_bid=30024, item_id=0, model="H30056", icon_id=0, icon="30024", attr={}, day=0, desc="原始拥有", attr_desc="无属性加成", is_classics=1},
		[1005] = {id=1005, clothes_name="大侠之道", partner_name="影刹", partner_bid=30024, item_id=90003, model="H31056", icon_id=1, icon="31024", attr={{'atk_per',50},{'hp_max_per',50}}, day=0, desc="春节活动获得", attr_desc="攻击力+5%，生命值+5%", is_classics=0},
	},
	[10001] = {
		[4] = {id=4, clothes_name="经典", partner_name="亚瑟", partner_bid=10001, item_id=0, model="H30009", icon_id=0, icon="10001", attr={}, day=0, desc="原始拥有", attr_desc="无属性加成", is_classics=1},
		[1006] = {id=1006, clothes_name="胜利之剑", partner_name="亚瑟", partner_bid=10001, item_id=90004, model="H31009", icon_id=1, icon="11001", attr={{'atk_per',50},{'hp_max_per',50}}, day=0, desc="商城兑换", attr_desc="攻击力+5%，生命值+5%", is_classics=0},
	},
}
-- -------------------clothes_data_end---------------------


-- -------------------fashion_to_partner_start-------------------
Config.ClothesData.data_fashion_to_partner_length = 10
Config.ClothesData.data_fashion_to_partner = {
	[1006] = {{partner_bid=10001}
	},
	[4] = {{partner_bid=10001}
	},
	[1005] = {{partner_bid=30024}
	},
	[3] = {{partner_bid=30024}
	},
	[1004] = {{partner_bid=30022}
	},
	[2] = {{partner_bid=30022}
	},
	[1003] = {{partner_bid=30004}
	},
	[1] = {{partner_bid=30004}
	},
	[1000] = {{partner_bid=30008}
	},
	[0] = {{partner_bid=30008}
	},
}
-- -------------------fashion_to_partner_end---------------------


-- -------------------head_to_partner_start-------------------
Config.ClothesData.data_head_to_partner_length = 6
Config.ClothesData.data_head_to_partner = {
	[11001] = {{clothes_name="胜利之剑", partner_name="亚瑟"}
	},
	[0] = {{clothes_name="经典", partner_name="冰雪女王"},
		{clothes_name="经典", partner_name="雅典娜"},
		{clothes_name="经典", partner_name="吸血伯爵"},
		{clothes_name="经典", partner_name="影刹"},
		{clothes_name="经典", partner_name="亚瑟"}
	},
	[31024] = {{clothes_name="大侠之道", partner_name="影刹"}
	},
	[31022] = {{clothes_name="纯白绅士", partner_name="吸血伯爵"}
	},
	[31004] = {{clothes_name="双马尾萝莉", partner_name="雅典娜"}
	},
	[31008] = {{clothes_name="圣诞恋歌", partner_name="冰雪女王"}
	},
}
-- -------------------head_to_partner_end---------------------

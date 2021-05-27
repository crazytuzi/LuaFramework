ClientQuickyBuyType = { --快捷购买类型
	zhuangsheng = 1, --转生
	wuxianshoutao = 2, --无限手套
	jianding = 3, --锻造-鉴定
	baoshi = 4, --锻造-宝石
	fengshen = 5,--封神
	lunhui = 6,--轮回
}
--[[--商品类型
 SHOP_CFG_NAME = {
"1ReXiaoDaoJu", 
"2BuJiYaoPin", 
"3JingYanDaoJu", 		--钻石商城
"4QiZhenYiBao", 		--元宝商城
"5ShiZhuangShenQi",		--背包商店
"6LijinShangCheng",
"7JiFenShangCheng",		--积分商城
"8BangJinShangCheng"
--]]
ClientQuickyBuylistCfg = {

--[[{--照商店的配置考过来就可以 ,--是否购买使用
--item_id = 24,			--商品ID
--shop_index = 3,		--商品类型
--is_auto_use = true,	--是否自动使用 [true=购买并使用]、[false=购买]
--},]]

	[1] = {      --zhuangsheng = 1, --转生
		{item_id = 24, shop_index = 3, is_auto_use = true }, --高级转生丹
		{item_id = 25, shop_index = 3, is_auto_use = true }, --超级转生丹
	},
	[2] = {      --wuxianshoutao = 2, --无限手套
		{item_id = 306, shop_index = 3, is_auto_use = false }, --黑檀木
		{item_id = 307, shop_index = 3, is_auto_use = false }, --黑铁矿
		{item_id = 308, shop_index = 3, is_auto_use = false }, --黄铜矿

	},
	[3] = {      --jianding = 3, --锻造-鉴定
		--{item_id = 2278, shop_index = 3, is_auto_use = false }, --照商店的配置考过来就可以 ,--是否购买使用

		
	},
	[4] = {      --baoshi = 4, --锻造-宝石
		{item_id = 352, shop_index = 3, is_auto_use = false }, --1级生命宝石
		{item_id = 367, shop_index = 3, is_auto_use = false }, --1级防御宝石
		{item_id = 382, shop_index = 3, is_auto_use = false }, --1级攻击宝石
		{item_id = 397, shop_index = 3, is_auto_use = false }, --1级切割宝石
		{item_id = 412, shop_index = 3, is_auto_use = false }, --1级暴击宝石
		{item_id = 427, shop_index = 3, is_auto_use = false }, --1级韧性宝石


		
	},
	[5] = {		--fengshen = 5,--封神
		{item_id = 1662, shop_index = 3, is_auto_use = true }, --500神灵精魄
		{item_id = 1661, shop_index = 7, is_auto_use = true }, --200神灵精魄

	},

	[6] = {		--lunhui = 6,--轮回
		{item_id = 2880, shop_index = 3, is_auto_use = true }, --500神灵精魄
		{item_id = 2881, shop_index = 3, is_auto_use = true }, --200神灵精魄

	},

}
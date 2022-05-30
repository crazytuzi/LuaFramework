----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--item_product_data.xml
--------------------------------------

Config = Config or {} 
Config.ItemProductData = Config.ItemProductData or {}

-- -------------------product_const_start-------------------
Config.ItemProductData.data_product_const_length = 0
Config.ItemProductData.data_product_const = {

}
Config.ItemProductData.data_product_const_fun = function(key)
	local data=Config.ItemProductData.data_product_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ItemProductData.data_product_const['..key..'])not found') return
	end
	return data
end
-- -------------------product_const_end---------------------


-- -------------------product_data_start-------------------
Config.ItemProductData.data_product_data_length = 2
Config.ItemProductData.data_product_data = {
	[10421] = {bid=10421, name="符文·神之耀", lev=0, need_items={{10428,50}}, loss={}, order=1},
	[10441] = {bid=10441, name="符文·神之辉", lev=0, need_items={{10429,30}}, loss={}, order=1}
}
Config.ItemProductData.data_product_data_fun = function(key)
	local data=Config.ItemProductData.data_product_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ItemProductData.data_product_data['..key..'])not found') return
	end
	return data
end
-- -------------------product_data_end---------------------

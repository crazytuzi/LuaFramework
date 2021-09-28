local Drops={}
require("app.cfg.drop_info")

function Drops.convert(_id)
	local drop = drop_info.get(_id)
	-- {name = goods.name,icon = _ico,info=goods,quality=_quality,desc=_desc,size=size}
	local _icon = G_Path.getDropIcon(drop.res_id)
	if drop.big_type == 1 then
		local _goodsArray = Drops._getGoodsArray(_id)
		local goods = {name=drop.name,icon=_icon,desc=drop.directions,quality=drop.quality,goodsArray=_goodsArray}
		return goods
	else
		local goods = {name=drop.name,icon=_icon,desc=drop.directions,quality=drop.quality, goodsArray = {}}
		return goods
	end 
end

function Drops.convertType(_type)
	if _type == 1 then   --银两
	elseif _type == 2 then --元宝
	elseif _type == 3 then --道具
	elseif _type == 4 then -- 武将
	elseif _type == 5 then -- 装备
	elseif _type == 6 then -- 碎片
	elseif _type == 7 then -- 宝物
	elseif _type == 8 then -- 宝物碎片
	elseif _type == 9 then -- 关联其他掉落库
		_type = 18
	elseif _type == 10 then -- 武将（按照星级）
		_type = 4
	elseif _type == 11 then -- 武将（按照阵营）
		_type = 4
	elseif _type == 12 then -- -武将（按照潜力
		_type = 4
	elseif _type == 13 then -- 阵营为1的武将（按照星级）
		_type = 4
	elseif _type == 14 then -- 阵营为2的武将（按照星级）
		_type = 4
	elseif _type == 15 then -- 15-阵营为3的武将  （按照星级）
		_type = 4
	elseif _type == 16 then -- 16-阵营为4的武将  （按照星级）
		_type = 4
	elseif _type == 17 then -- 17-装备（按照部位）
		_type = 5
	elseif _type == 18 then -- 18-装备（按照星级）
		_type = 5
	elseif _type == 19 then -- 19-装备（按照潜力）
		_type = 5
	elseif _type == 20 then -- 20-部位=1的装备（按照星级）
		_type = 5
	elseif _type == 21 then -- 21-部位=2的装备（按照星级）
		_type = 5
	elseif _type == 22 then -- 22-部位=3的装备（按照星级）
		_type = 5
	elseif _type == 23 then -- 23-部位=4的装备（按照星级）
		_type = 5
	elseif _type == 24 then -- 24-宝物（按照部位）
		_type = 7
	elseif _type == 25 then -- 25-宝物（按照星级）
		_type = 7
	elseif _type == 26 then -- 26-宝物（按照潜力）
		_type = 7
	elseif _type == 27 then -- 27-类型=1的宝物（按照星级）
		_type = 7
	elseif _type == 28 then -- 28-类型=2的宝物（按照星级）
		_type = 7
	elseif _type == 29 then -- 29-类型=3的宝物（按照星级）
		_type = 7
	elseif _type == 30 then -- 30-类型=1的碎片（按照星级）
		_type = 6
	elseif _type == 31 then -- 31-类型=2的碎片（按照星级）
		_type = 6
	elseif _type == 32 then -- 32-道具（按照类型）
		_type = 3
	elseif _type == 33 then -- 33-随机掉落一个道具（从ITEM中随便挑出一个可掉落的道具）
		_type = 3
	elseif _type == 34 then -- 34-碎片（按照类型）
		_type = 6
	elseif _type == 35 then -- 35-宝物碎片（按照星级）
		_type = 8
	elseif _type == 36 then -- 36 武魂
		_type = 13
	elseif _type == 37 then --觉醒道具
		_type = G_Goods.TYPE_AWAKEN_ITEM
	elseif _type == 38 then	--觉醒道具
		_type = G_Goods.TYPE_AWAKEN_ITEM
	elseif _type == 39 then  --时装
		_type = G_Goods.TYPE_SHI_ZHUANG
	elseif _type == 40 then  --神魂
		_type = G_Goods.TYPE_SHENHUN
	elseif _type == 41 then  --声望
		_type = G_Goods.TYPE_SHENGWANG
	elseif _type == 42 then  --战功
		_type = G_Goods.TYPE_MOSHEN
	elseif _type == 43 then  --演武勋章
		_type = G_Goods.TYPE_CROSSWAR_MEDAL
	elseif _type == 44 then  --军团贡献
		_type = G_Goods.TYPE_CORP_DISTRIBUTION
	elseif _type == 45 then  --团购券
		_type = G_Goods.TYPE_COUPON
	elseif _type == 46 then  --战宠
		_type = G_Goods.TYPE_PET
	elseif _type == 47 then  --战宠积分
		_type = G_Goods.TYPE_PET_SCORE 
	elseif _type == 48 then  --充值额度
		_type = G_Goods.TYPE_RECHARGE 
	elseif _type == 49 then  --vip经验
		_type = G_Goods.TYPE_VIP_EXP 
	end
	return _type
end

function Drops._getGoodsArray(_id)
	local drop = drop_info.get(_id)
	local index = 1
	local goodsArr = {}
	local type_key = string.format("type_%s",index)
	local value_key = string.format("value_%s",index)
	local size_key = string.format("min_num_%s",index)
	local max_key = string.format("max_num_%s",index)
	while drop_info.hasKey(type_key) do
		local goods = G_Goods.convert(Drops.convertType(drop[type_key]),drop[value_key],drop[size_key],drop[max_key])
		print(Drops.convertType(drop[type_key]),drop[value_key],drop[size_key],drop[max_key])
		if goods then
			if drop[type_key] == 9 then
				--关联掉落库
				local arr = goods and goods.goodsArray or {}
				for k , v in pairs(arr) do 
					goodsArr[#goodsArr+1] = v
				end
			else
				goodsArr[#goodsArr+1] = goods
			end
		end
		-- if goods ~= nil then
		-- 	goodsArr[#goodsArr+1] = goods
		-- end
		index = index + 1
		type_key = string.format("type_%s",index)
		value_key = string.format("value_%s",index)
		size_key = string.format("min_num_%s",index)
		max_key = string.format("max_num_%s",index)
	end
	return goodsArr
end

return Drops
local ActivityLimit = class("ActivityLimit")

--[[
	Goods.TYPE_MONEY  = 1
	Goods.TYPE_GOLD  = 2
	Goods.TYPE_ITEM  = 3
	Goods.TYPE_KNIGHT  = 4
	Goods.TYPE_EQUIPMENT  = 5
	Goods.TYPE_FRAGMENT  = 6
	Goods.TYPE_TREASURE  = 7
	Goods.TYPE_TREASURE_FRAGMENT  = 8
	Goods.TYPE_SHENGWANG = 9
	Goods.TYPE_EXP  = 10
	Goods.TYPE_TILI  = 11
	Goods.TYPE_JINGLI  = 12
	Goods.TYPE_WUHUN  = 13
	Goods.TYPE_JINENGDIAN  = 14
	Goods.TYPE_MOSHEN = 15
	Goods.TYPE_CHUANGUAN  = 16
	Goods.TYPE_CHUZHENGLING  = 17
	Goods.TYPE_DROP  = 18
	Goods.TYPE_VIP_EXP = 19
	Goods.TYPE_CORP_DISTRIBUTION = 20  --军团贡献
	Goods.TYPE_SHI_ZHUANG = 21   --时装
]]

function ActivityLimit.checkByQuest(quest)
	if not quest then
		return false
	end
	local typeValueList = {}
	for i=1,4 do
		local _type = quest["award_type"..i]
		if _type > 0 then
			local _value = quest["award_value"..i]
			local _size = quest["award_size"..i]
			local key = string.format("%d_%d",_type,_value)
			if quest["award_select"] == 0 then
				if typeValueList[key] == nil then
					typeValueList[key] = 0
				end
				typeValueList[key] = typeValueList[key] + _size
			else
				typeValueList[key] = _size
			end
			if not ActivityLimit.check(_type,_value,typeValueList[key]) then
				G_MovingTip:showMovingTip("该奖励暂时无法领取")
				return false
			end
		end
	end

	--没问题了
	return true
end

function ActivityLimit.check(_type,_value,_size)
	
	return true

end

return ActivityLimit
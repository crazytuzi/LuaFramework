RollingBarrageData = RollingBarrageData or BaseClass()

local TOTAL_DES_NUM = 50

-- CHEST_SHOP_TYPE ={
-- 	CHEST_SHOP_TYPE_INVALID = 0,
-- 	CHEST_SHOP_TYPE_EQUIP = 1,							-- 装备
-- 	CHEST_SHOP_TYPE_JINGLING = 2,						-- 精灵
-- }

function RollingBarrageData:__init()
	if nil ~= RollingBarrageData.Instance then
		return
	end

	RollingBarrageData.Instance = self
end

function RollingBarrageData:__delete()
	RollingBarrageData.Instance = nil
end
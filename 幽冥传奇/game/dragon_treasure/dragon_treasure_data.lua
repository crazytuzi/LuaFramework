--------------------------------------------------------
-- 龙魂秘宝
--------------------------------------------------------

DragonTreasureData = DragonTreasureData or BaseClass()

function DragonTreasureData:__init()
	if DragonTreasureData.Instance then
		ErrorLog("[DragonTreasureData]:Attempt to create singleton twice!")
	end
	DragonTreasureData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.ship_is_vis = false
	self.ship_force = false
end

function DragonTreasureData:__delete()
	DragonTreasureData.Instance = nil
end

----------设置----------

-- 设置秘宝索引 用于打开秘宝面板
function DragonTreasureData:SetTreasureIndex(index)
	self.treasure_index = index
end

-- 获取秘宝索引
function DragonTreasureData:GetTreasureIndex()
	return self.treasure_index
end

-- 设置次数宝箱索引 用于打开次数宝箱面板
function DragonTreasureData:SetTimesTreasureIndex(index)
	self.times_treasure_index = index
end

-- 获取次数宝箱索引
function DragonTreasureData:GetTimesTreasureIndex()
	return self.times_treasure_index
end

-- 设置跳过动作是否勾取 用于跳过动作
function DragonTreasureData:SetShipIsVis(boor)
	self.ship_is_vis = boor
end

-- 设置是否强制跳过动作 用于跳过动作
function DragonTreasureData:SetShipForce(boor)
	self.ship_force = boor
end

-- 获取是否跳过动作
function DragonTreasureData:GetShipIsVis()
	return self.ship_is_vis or self.ship_force
end

--------------------

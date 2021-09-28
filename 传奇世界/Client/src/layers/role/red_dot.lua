local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local MObserver = require "src/young/observer"
---------------------------------------------------------
local dress = MPackManager:getPack(MPackStruct.eDress)
local bag = MPackManager:getPack(MPackStruct.eBag)
---------------------------------------------------------
local tStates = {}

query = function(m, pos)
	if pos then
		return tStates[pos]
	else
		return table.size(tStates) > 0
	end
end
---------------------------------------------------------
local observable = MObserver.new()

register = function(m, observer)
	observable:register(observer)
end

unregister = function(m, observer)
	observable:unregister(observer)
end

broadcast = function(m, ...)
	observable:broadcast(m, ...)
end
---------------------------------------------------------
local check_on_dress_change = function(dress, pos, grid)
	if not G_ROLE_MAIN then return end
	local grid = grid or dress:getGirdByGirdId(pos)
	if not grid then return end
	local MRoleStruct = require "src/layers/role/RoleStruct"
	local MpropOp = require "src/config/propOp"
	local coin = MRoleStruct:getAttr(PLAYER_MONEY) + MRoleStruct:getAttr(PLAYER_BINDMONEY)
	local MequipOp = require "src/config/equipOp"
	local grid = grid or dress:getGirdByGirdId(pos)
	local protoId = MPackStruct.protoIdFromGird(grid)
	local quality = MPackStruct.attrFromGird(grid, MPackStruct.eAttrQuality)
	local star = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStarLevel)
	--local strength = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	local level = MPackStruct.attrFromGird(grid, MPackStruct.eAttrLevel)
	
	-- 判断升品条件
	local canUpQuality = false
	repeat
		if MequipOp.isQualityRUL(quality) then break end
		if level < MequipOp.upQualityLevelNeed(protoId, quality) then break end
		if coin < MequipOp.upQualityCoinNeed(protoId, quality) then break end
		
		-- 消耗材料
		local cost = MequipOp.upQualityMaterialNeed(protoId, quality)
		
		canUpQuality = true
		for i = 1, #cost do
			local material = cost[i]
			local protoId = material.protoId
			local bag = MPackManager:getPack(MPackStruct.eBag)
			local num = bag:countByProtoId(protoId)
			if num < material.num then
				canUpQuality = false
				break
			end
		end
	until true
	
	-- 判断升星条件
	local canUpStar = false
	repeat
		if star >= 5 then break end
		if level < MequipOp.upStarLevelNeed(protoId, star) then break end
		if coin < MequipOp.upStarCoinNeed(protoId, star) then break end
		
		-- 消耗材料
		local cost = MequipOp.upStarMaterialNeed(protoId, star)
		
		canUpStar = true
		for i = 1, #cost do
			local material = cost[i]
			local protoId = material.protoId
			local bag = MPackManager:getPack(MPackStruct.eBag)
			local num = bag:countByProtoId(protoId)
			if num < material.num then
				canUpStar = false
				break
			end
		end
	until true
	
	-- 判断升级条件
	local canUpLevel = false
	repeat
		if MequipOp.isLevelRUL(protoId) then break end
		local evolveId = MequipOp.evolve(protoId)
		local evolveIdLv =  MpropOp.levelLimits(evolveId)
		if MRoleStruct:getAttr(ROLE_LEVEL) < evolveIdLv then break end
		if coin < MequipOp.upLevelCoinNeed(protoId) then break end
		
		--if strength < MequipOp.upLevelStrengthNeed(protoId) then break end
		local upLevelMaterialNeed = MequipOp.upLevelMaterialNeed(protoId)[1]
		local bag = MPackManager:getPack(MPackStruct.eBag)
		if bag:countByProtoId(upLevelMaterialNeed.protoId) < upLevelMaterialNeed.num then break end
		
		if quality < MequipOp.upLevelQualityNeed(protoId) then break end
		canUpLevel = true
	until true
	
	local nothing = not canUpQuality and not canUpStar and not canUpLevel
	if nothing then
		tStates[pos] = nil
	else
		tStates[pos] = {
			canUpQuality = canUpQuality,
			canUpStar = canUpStar,
			canUpLevel = canUpLevel,
		}
	end
	
	M:broadcast(dress, pos, tStates[pos])
end

local check_on_bag_change = function(bag)
	for i = MPackStruct.eWeapon, MPackStruct.eMedal do
		local grid = dress:getGirdByGirdId(i)
		if grid then
			local pos = MPackStruct.girdIdFromGird(grid)
			check_on_dress_change(dress, pos, grid)
		end
	end
end
---------------------------------------------------------
-- 着装包裹发生了变化
local on_dress_change = function(dress, event, pos, grid)
	check_on_dress_change(dress, pos, grid)
end

dress:register(on_dress_change)

-- 背包物品发生了变化
local on_bag_change = function(bag, event, pos, pos1, grid)
	check_on_bag_change(bag)
end

bag:register(on_bag_change)

------------------------------------------------------------------------------------
-- 货币数值发生了变化
local on_coin_change = function(observable, attrId, objId, isMe, attrValue, old)
	if isMe and (attrId == PLAYER_MONEY or attrId == PLAYER_BINDMONEY) then
		check_on_bag_change(bag)
	end
end

local MRoleStruct = require "src/layers/role/RoleStruct"
MRoleStruct:register(on_coin_change)

-- 主界面监听
M:register(function(m, dress, pos, info)
	if info or m:query() then
		if G_MAINSCENE and G_MAINSCENE.red_points then
			G_MAINSCENE.red_points:insertRedPoint(1, 2)
		end
	else
		if G_MAINSCENE and G_MAINSCENE.red_points then
			G_MAINSCENE.red_points:removeRedPoint(1, 2)
		end
	end
end)




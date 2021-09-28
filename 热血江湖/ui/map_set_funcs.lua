--[[
	注：重构地图相关内容，包括场景地图和势力战小地图，保持了功能跟原有功能相同。但并不保证修复了原有存在的bug
	@2016.12.02   by menglei
	目前主要使用到地图的有如下几个文件：scene_map, forcewar_miniMap, forcewar_map
	修改了之前使用cocos2d的schedule相关方法，而是改用通过UI中的onUpdate()方法来刷新一些内容。
		例：
		function wnd_forcewar_map:onUpdate(dTime)
			local mapInstance = GetBaseMap()
			mapInstance:onUpdate(dTime)
		end
	全局函数的定义未修改，故不用修改调用这些函数的地方，而只需要关注具体的实现细节就好。
]]
----------------------------------
require("ui/mapBase")
local g_mapBase = nil

-- 获取mapBase类的一个单例
function GetBaseMap()
	if not g_mapBase then
		g_mapBase = mapBase.new()
	end
	return g_mapBase
end


--------------创建小地图（非主界面显示的miniMap)
function createMap(...)
	GetBaseMap():createMap(...)
end

-- 创建势力战小地图
function createForceWarMiniMap(scroll, nodeSize, mapId)
	GetBaseMap():createForceWarMiniMap(scroll, nodeSize, mapId)
end

function updateTeamMate(roleId, mapId, pos)
	GetBaseMap():updateTeamMate(roleId, mapId, pos)
end

function updateEscortCar()
	GetBaseMap():updateEscortCar()
end

function updateDoubleSideMateStatues(roleId, mapId, pos, tfbwtype)
	GetBaseMap():updateDoubleSideMateTowers(roleId, mapId, pos, tfbwtype)
end

function updateDoubleSideInfo(roleId, mapId, pos)
	-- useless function
end

function updateDoubleSideMate(roleId, mapId, pos, tfbwtype)
	GetBaseMap():updateDoubleSideMate(roleId, mapId, pos, tfbwtype)
end

-- 注释之后，临时的空函数，防止调用不到
function releaseSchedule()
	 GetBaseMap():onRelease()
end

function createTargetPos(needPos, mapId)
	GetBaseMap():createTargetPos(needPos, mapId)
end
function clearTargetImg()
	GetBaseMap():clearTargetImg()
end

-- function createPath(posTable, nodeSize,mapId)
-- 	local spriteTable = {}
-- 	for i,v in ipairs(posTable) do
-- 		if i%10==0 then
-- 			local needPos = i3k_engine_world_pos_to_minmap_pos(teamMate, v, nodeSize.width, nodeSize.height,mapId,isForcewar,g_i3k_ui_mgr:JudgeIsPad())--
-- 			local pathSprite = createSprite(f_roadImgId)
-- 			if pathSprite then
-- 				parent:addChild(pathSprite)
-- 				pathSprite:setPosition(needPos)
-- 			end
-- 			table.insert(spriteTable, pathSprite)
-- 		end
-- 	end
-- 	return spriteTable
-- end
function createPath()
	return {}
end

function updateTeammatePos(data, iconId)
	GetBaseMap():updateTeammatePos(data, iconId)
end
function updateSpiritBossPos(data, iconId)
	GetBaseMap():updateSpiritBossPos(data, iconId)
end

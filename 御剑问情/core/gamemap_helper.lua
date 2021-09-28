local origin_x, origin_y = 0, 0

GameMapHelper = GameMapHelper or BaseClass()
function GameMapHelper:__init(render_unit)
	if GameMapHelper.Instance then
		print_error("[GameMapHelper] Attempt to create singleton twice!")
		return
	end
	GameMapHelper.Instance = self
end

function GameMapHelper:__delete()
	GameMapHelper.Instance = nil
end

function GameMapHelper.SetOrigin(x, y)
	origin_x = x or 0
	origin_y = y or 0
end

-- 逻辑坐标转世界坐标（世界坐标为格子中点）
function GameMapHelper.LogicToWorld(x, y)
	return origin_x + math.floor(x) * Config.SCENE_TILE_WIDTH + Config.SCENE_TILE_WIDTH / 2,
		origin_y + math.floor(y) * Config.SCENE_TILE_HEIGHT + Config.SCENE_TILE_HEIGHT / 2
end

-- 逻辑坐标转世界坐标
function GameMapHelper.LogicToWorldEx(x, y)
	return origin_x + x * Config.SCENE_TILE_WIDTH,
		origin_y + y * Config.SCENE_TILE_HEIGHT
end

-- 世界坐标转逻辑坐标（逻辑坐标为整数）
function GameMapHelper.WorldToLogic(x, y)
	return math.floor((x - origin_x) / Config.SCENE_TILE_WIDTH),
		math.floor((y - origin_y) / Config.SCENE_TILE_HEIGHT)
end

-- 世界坐标转逻辑坐标
function GameMapHelper.WorldToLogicEx(x, y)
	return (x - origin_x) / Config.SCENE_TILE_WIDTH,
		(y - origin_y) / Config.SCENE_TILE_HEIGHT
end

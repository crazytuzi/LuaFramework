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

function GameMapHelper.GetRealChongFengLogicPos(start_pos, end_pos, distance)
	local delta_pos = u3d.v2Sub(end_pos, start_pos)
	local total_distance = u3d.v2Length(delta_pos)
	local state_move_dir = u3d.v2Normalize(delta_pos)

	local pass_distance = total_distance - distance
	if pass_distance < 0 then
		pass_distance = 0
	end

	local scene_logic_width = UnityEngine.Screen.width
	local scene_logic_height = UnityEngine.Screen.height

	while pass_distance < total_distance do
		pass_distance = pass_distance + math.min(total_distance - pass_distance, 1)
		local real_pos = u3d.v2Add(start_pos, u3d.v2Mul(state_move_dir, pass_distance))
		local logic_x, logic_y = GameMapHelper.WorldToLogic(real_pos.x, real_pos.y)
		if not AStarFindWay:IsBlock(logic_x, logic_y) 
			and logic_x > 0 and logic_y > 0 
			and logic_x < scene_logic_width and logic_y < scene_logic_height then

			return {x = logic_x, y = logic_y}
		end
	end
	return nil
end
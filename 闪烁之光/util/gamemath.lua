GameMath = GameMath or {}

GameMath.DirRight 	 = 6
GameMath.DirLeft	 = 4

GameMath.DirLeftTop  = 2
GameMath.DirRightTop = 8
--只有2个方向的判断
function GameMath.GetDirectionNumberHV(dir)
	local vec = cc.p(1,0)
	local target = cc.p(dir.x, dir.y)
	local radians = cc.pGetAngle(vec,target)
	local degrees = radianToDegree(radians)

	if degrees < 0 then
		degrees = 360 + degrees
	end
	if degrees >= 90 and degrees <= 270 then
		dir = 6
	else
		dir = 4
	end
	return dir
end

--有4个方向的判断
function GameMath.GetDirectionNumberHVII(dir)
	local vec = cc.p(1,0)
	local target = cc.p(dir.x, dir.y)
	local radians = cc.pGetAngle(vec,target)
	local degrees = radianToDegree(radians)

	if degrees < 0 then
		degrees = 360 + degrees
	end
	if degrees > 10 and degrees < 90 then
		dir = 2
	elseif degrees >= 90 and degrees < 170 then
		dir = 6
	elseif degrees >= 170 and degrees <= 270 then	
		dir = 8
	else
		dir = 4
	end
	return dir
end

function GameMath.IsPointNear(p1x, p1y, p2x, p2y, near_val)
	near_val = near_val or 1.0

	local x_step = p1x - p2x
	local y_step = p1y - p2y
	local val = x_step*x_step + y_step*y_step
	return val <= near_val*near_val
end

function GameMath.Round(x)
	local val, pt = math.modf(x)
	if pt > 0.5 then
		val = val + 1
	end

	return val
end

function GameMath.RoundWithPercentCeil(x, percent)
    local val, pt = math.modf(x)
    if math.abs(pt) > percent then
        val = val + 1
    end
    return val
end

function GameMath.RoundWithPercentFloor(x, percent)
    local val, pt = math.modf(x)
    if math.abs(pt) < percent then
        return val
    end

    return val + 1
end

-- 取整数部分
function GameMath.GetIntPart(x)
    local temp = math.ceil(x)
    if temp == x then
        return temp
    else
        return temp - 1
    end
end

-- 获取小数部分
function GameMath.GetFloatPart(x)
	return x - GameMath.GetIntPart(x)
end

function GameMath.NormalizeDegree(degree)
	local ret_degree = degree
	local two_pi_degree = 360
	if ret_degree > 0 then
		while ret_degree > two_pi_degree  do
			ret_degree = ret_degree - two_pi_degree
		end
	elseif ret_degree < 0 then
		while ret_degree < 0.0 do
			ret_degree = ret_degree + two_pi_degree
		end
	end

	return ret_degree
end
--根据需要播放的动作,获取对应真实资源动作,关联朝向
function GameMath.GetRealActionName(action_name, dir)
	if action_name == PlayerAction.battle_stand then
		if dir == GameMath.DirRightTop or dir == GameMath.DirLeft then
			return PlayerAction.battle_stand
		else
			return PlayerAction.stand_1
		end
	elseif action_name == PlayerAction.run then
		if dir == GameMath.DirRightTop or dir == GameMath.DirLeft then
			return PlayerAction.run
		else
			return PlayerAction.run_1
		end
	end

	return action_name
end
--检测某点是否处于矩形内
function GameMath.HitRectTest(px, py, rect_x, rect_y, rect_width, rect_height)
	if px < rect_x or px >= rect_x + rect_width 
		or py < rect_y or py >= rect_y + rect_height then
		return false
	end
	return true
end

--[[
	求距离公式
	@param need_sqrt 是否需要开方运算（不开方可以减少不必要的运算）
]]--
function GameMath.GetDistance(p1x, p1y, p2x, p2y, need_sqrt)

	local x_step = p1x - p2x
	local y_step = p1y - p2y
	local val = x_step*x_step + y_step*y_step
	
	if need_sqrt then
		return math.pow(val,0.5)
	end
	
	return val
end

--[[
	取最近的点
	@param point_list 坐标数组
	@param px 参照点x坐标
	@param py 参照点y坐标
	@param get_point_func 从数组中的一个对象取出坐标，return x,y
]]--
function GameMath.GetNearestPoint(point_list,px,py,get_point_func)

	local result
	local prev_distance = -1
	
	for _, point in pairs(point_list) do
		local curr_distance
		if get_point_handler == nil then 			
			curr_distance = GameMath.GetDistance(px, py, point.x, point.y)
		else
			curr_distance = GameMath.GetDistance(px, py, get_point_func(point))			
		end

		if prev_distance == -1 or prev_distance > curr_distance then
			result = point
			prev_distance = curr_distance
		end
	end 

	return result
end

-- 模糊等价？感觉应该是绝对值接近precision数值的意思
function GameMath.FuzzyEqual(val1, val2, precision)
    precision = precision or 0.01
    if math.abs(val1 - val2) < (precision / 2) then
        return true
    end
    return false
end

-- 判断点是否在距离为distance的正方形形内
function GameMath.IsPointNearRect(x, y, center_x, center_y, distance)
    if x >= center_x - distance and x <= center_x + distance 
        and y >= center_y - distance and y <= center_y + distance then
        return true
    end
    return false
end

-- 四舍五入
function GameMath.round(x)
    local x1, x2 = math.modf(x)
    if x2 >= 0.5 then 
        return x1 + 1
    else
        return x1 
    end
end

-- 计算下一个位置
function GameMath.nextPos(sPos, tPos, speed)
	local state_move_dir = cc.pSub(tPos, sPos)
	local move_dir = cc.pNormalize(state_move_dir)
    local dir = cc.pMul(move_dir, speed) 
    return cc.pAdd(sPos, dir), dir
end

-- 计算下一个位置移动向量
function GameMath.moveDir(sPos, tPos, speed)
	local state_move_dir = cc.pSub(tPos, sPos)
	local move_dir = cc.pNormalize(state_move_dir)
    return cc.pMul(move_dir, speed) 
end

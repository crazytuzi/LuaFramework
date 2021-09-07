
local math = math

u3d = u3d or {}

function u3d.vec2(_x, _y)
	return {x = _x, y = _y}
end

-- 加
function u3d.v2Add(v2a, v2b)
	return {x = v2a.x + v2b.x , y = v2a.y + v2b.y}
end

-- 减
function u3d.v2Sub(v2a, v2b)
	return {x = v2a.x - v2b.x , y = v2a.y - v2b.y}
end

-- 乘一个数
function u3d.v2Mul(v2a, factor)
	return {x = v2a.x * factor , y = v2a.y * factor}
end

-- 中点
function u3d.v2Mid(v2a, v2b)
	return {x = (v2a.x + v2b.x) / 2.0 , y = ( v2a.y + v2b.y) / 2.0}
end

-- 角度转向量
function u3d.v2ForAngle(a)
	return {x = math.cos(a), y = math.sin(a)}
end

-- 向量转角度
function u3d.v2Angle(v2)
	return math.atan2(v2.y, v2.x)
end

-- 长度
function u3d.v2Length(v2, is_sqrt)
	if is_sqrt ~= false then
		return math.sqrt(v2.x * v2.x + v2.y * v2.y)
	end
	return v2.x * v2.x + v2.y * v2.y
end

-- 单位化
function u3d.v2Normalize(v2)
	local length = u3d.v2Length(v2)
	if 0 == length then
		return {x = 1.0, y = 0.0}
	end

	return {x = v2.x / length, y = v2.y / length}
end

-- 二维向量旋转a度（-1向左旋转，1向右旋转）
function u3d.v2Rotate(v2, a, dir)
	dir = dir or 1
	if dir ^ 2 == 1 then
		return {x = v2.x * math.cos(math.rad(a * dir)) + v2.y * math.sin(math.rad(a * dir)), 
		y = -v2.x * math.sin(math.rad(a * dir)) + v2.y * math.cos(math.rad(a * dir))}
	else
		return{x = v2.x, y = v2.y}
	end
end

function u3d.vec3(_x, _y, _z)
	return {x = _x, y = _y, z = _z}
end

function u3d.vec4(_x, _y, _z, _w)
	return {x = _x, y = _y, z = _z, w = _w}
end

function u3d.v3Add(v3a, v3b)
	return {x = v3a.x + v3b.x, y = v3a.y + v3b.y, z = v3a.z + v3b.z}
end

function u3d.v3Sub(v3a, v3b)
	return {x = v3a.x - v3b.x, y = v3a.y - v3b.y, z = v3a.z - v3b.z}
end

function u3d.v3Length(v3, is_sqrt)
	if is_sqrt ~= false then
		return math.sqrt(v3.x * v3.x + v3.y * v3.y + v3.z * v3.z)
	end
	return v3.x * v3.x + v3.y * v3.y + v3.z * v3.z
end

function u3d.v3Normalize(v3)
	local length = u3d.v3Length(v3)
	if 0 == length then
		return {x = 0, y = 0, z = 1}
	end

	return {x = v3.x / length, y = v3.y / length, z = v3.z / length}
end

function u3d.v3Mul(v3, factor)
	return {x = v3.x * factor , y = v3.y * factor, z = v3.z * factor}
end

-- 文本对齐定义
TextAnchor = {
	UpperLeft = 0,
	UpperCenter = 1,
	UpperRight = 2,
	MiddleLeft = 3,
	MiddleCenter = 4,
	MiddleRight = 5,
	LowerLeft = 6,
	LowerCenter = 7,
	LowerRight = 8
}

------------------------------------------------------
if jit then
	jit.off(true, true)
end
function i3k_vec2(x, y)
	return { x = x, y = y };
end

------------------------------------------------------
function i3k_vec3(x, y, z)
	return { x = x, y = y, z = z };
end

function i3k_pos_to_vec3(pos)
	return i3k_vec3(pos.x, pos.y, pos.z)
end
function i3k_vec3_to_engine(v)
	return Engine.SVector3(v.x, v.y, v.z);
end

function i3k_round(x)
	local i, f = math.modf(x);
	if x < 0 then
		if f > 0.5 then
			i = i - 1;
		end
	else
		if f > 0.5 then
			i = i + 1;
		end
	end

	return i;
end

function i3k_trunc(x)
	return i3k_integer(x);
	--[[
	local i, f = math.modf(x);
	if x < 0 then
		if f > 0.0 then
			i = i - 1;
		end
	else
		if f > 0.0 then
			i = i + 1;
		end
	end

	return i;
	]]
end

function i3k_integer(x)
	local i, f = math.modf(x);

	return i;
end

function i3k_vec3_add1(v1, v2)
	local v = i3k_vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);

	return v;
end

function i3k_vec3_add2(v1, v2)
	local v = i3k_vec3(v1.x + v2, v1.y + v2, v1.z + v2);

	return v;
end

function i3k_vec3_sub1(v1, v2)
	local v = i3k_vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);

	return v;
end

function i3k_vec3_sub2(v1, v2)
	local v = i3k_vec3(v1.x - v2, v1.y - v2, v1.z - v2);

	return v;
end

function i3k_vec3_mul1(v1, v2)
	local v = i3k_vec3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);

	return v;
end

function i3k_vec3_mul2(v1, v2)
	local v = i3k_vec3(v1.x * v2, v1.y * v2, v1.z * v2);

	return v;
end

function i3k_vec3_div1(v1, v2)
	local v = i3k_vec3(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z);

	return v;
end

function i3k_vec3_div2(v1, v2)
	local v = i3k_vec3(v1.x / v2, v1.y / v2, v1.z / v2);

	return v;
end

function i3k_vec3_neg(v)
	local _x = -v.x;
	local _y = -v.y;
	local _z = -v.z;

	return i3k_vec3(_x, _y, _z);
end

-- dot
function i3k_vec3_dot(v1, v2)
	local _v1 = i3k_vec3_normalize1(v1);
	local _v2 = i3k_vec3_normalize1(v2);

	return _v1.x * _v2.x + _v1.y * _v2.y + _v1.z * _v2.z;
end

function i3k_vec3_dot_xz(v1, v2)
	local _v1 = i3k_vec3_normalize1(v1);
	local _v2 = i3k_vec3_normalize1(v2);

	return _v1.x * _v2.x + _v1.z * _v2.z;
end

-- cross product
function i3k_vec3_cp(v1, v2)
	local _x = v1.y * v2.z - v2.y * v1.z;
	local _y = v1.z * v2.x - v2.z * v1.x;
	local _z = v1.x * v2.y - v2.x * v1.y;

	return i3k_vec3(_x, _y, _z);
end

function i3k_vec3_dist(v1, v2)
	return i3k_vec3_len(i3k_vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z));
end

function i3k_vec3_dist_2d(v1, v2)
	local _v1 = i3k_vec3(v1.x, 0, v1.z);
	local _v2 = i3k_vec3(v2.x, 0, v2.z);

	return i3k_vec3_dist(_v1, _v2);
end

function i3k_vec3_len(v)
 	return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
end

-- only x, z
function i3k_vec3_angle1(p1, p2, p3)
	return i3k_vec3_angle2(i3k_vec3(p1.x - p2.x, 0, p1.z - p2.z), p3);
end

function i3k_vec3_angle2(p1, p2)
	local _v1 = i3k_vec3_normalize1(p1);
	local _v2 = i3k_vec3_normalize1(p2);

	local epsilon = 0.000001;

	local dot = _v1.x * _v2.x + _v1.z * _v2.z;

	local angle = 0;

	if math.abs(dot - 1) <= epsilon then
		angle = 0;
	elseif math.abs(dot + 1) <= epsilon then
		angle = math.pi;
	else
		angle = math.acos(dot);

		local cross = _v1.x * _v2.z - _v2.x * _v1.z;
		if cross < 0 then
			angle = 2 * math.pi - angle;
		end
	end

	return angle;
end

function i3k_vec3_normalize1(v)
	return i3k_vec3_normalize2(v.x, v.y, v.z);
end

function i3k_vec3_normalize2(x, y, z)
	local _x = x;
	local _y = y;
	local _z = z;

	local d = math.sqrt(_x * _x + _y * _y + _z * _z);
	if d ~= 0 then
		_x = _x / d;
		_y = _y / d;
		_z = _z / d;
	end

	return i3k_vec3(_x, _y, _z);
end

function i3k_vec3_clone(v)
	return i3k_vec3(v.x, v.y, v.z);
end

function i3k_vec3_equal(v1, v2, epslon)
	local _epslon = epslon or 0.0001;

	return math.abs(v1.x - v2.x) < _epslon and math.abs(v1.y - v2.y) < _epslon and math.abs(v1.z - v2.z) < _epslon;
end

function i3k_vec3_lerp(v1, v2, perc)
	local _x = v1.x * (1 - perc) + v2.x * perc;
	local _y = v1.y * (1 - perc) + v2.y * perc;
	local _z = v1.z * (1 - perc) + v2.z * perc;

	return i3k_vec3(_x, _y, _z);
end

function i3k_vec3_slerp(v1, v2, perc)
	local t = i3k_vec3_lerp(v1, v2, perc);

	local _v1 = math.sqrt(i3k_vec3_len(v1));
	local _t1 = math.sqrt(i3k_vec3_len(t));
    local k =  _v1 / _t1;

    local _x = k * (v1.x + perc * (v2.x - v1.x));
    local _y = k * (v1.y + perc * (v2.y - v1.y));
    local _z = k * (v1.z + perc * (v2.z - v1.z));

    return i3k_vec3(_x, _y, _z); 
end

function i3k_vec3_avg(v_list)
	local v = i3k_vec3(0, 0, 0);

	local cnt = table.getn(v_list);
	for k = 1, cnt do
		local _v = v_list[k];

		v = i3k_vec3_add(v, _v);
	end

	return i3k_vec3_div2(v, cnt);
end

function i3k_vec3_2_int(v)
	local _v = { };
		_v.x = i3k_integer(v.x);
		_v.y = i3k_integer(v.y);
		_v.z = i3k_integer(v.z);

	return _v;
end

-- only calc x, z
function i3k_vec3_from_angle(a)
	return { x = math.cos(a), y = 0, z = math.sin(a) };
end

function i3k_vec3_angle_self(v)
	return math.atan2(v.z, v.x);
end

function i3k_vec3_rotate(p1, p2)
	return { x = p1.x * p2.x - p1.z * p2.z, y = 0, z = p1.x * p2.z + p1.z * p2.x };
end

function i3k_rotate_by_angle(p1, p2, angle)
	local _p1 = i3k_vec3_clone(p1);
	_p1.y = 0;

	local _p2 = i3k_vec3_clone(p2);
	_p2.y = 0;

	return i3k_vec3_add1(p2, i3k_vec3_rotate(i3k_vec3_sub1(p1, p2), i3k_vec3_from_angle(angle)));
end

function i3k_getRandomPos(pos,radius)
	local angle = math.random(360)
	local x = math.cos(angle)*radius
	local z = math.sin(angle)*radius
	pos.x = pos.x+x
	pos.y = pos.y
	pos.z = pos.z+z
	return pos;
end

function i3k_math_is_NaN(v)
	return v == (v + 1) or (v ~= v)
end

-- 计算 |p1 p2| X |p1 p|
function i3k_math_is_cross(p1, p2, p)
	return (p2.x - p1.x) * (p.z - p1.z) -(p.x - p1.x) * (p2.z - p1.z)
end
-- 判断点是否在矩形内 p1 p2 p3 p4 矩形的顺序四个顶点，p为检测点
function i3k_math_is_in_rect(p1, p2, p3, p4, p)
	return i3k_math_is_cross(p1, p2, p) * i3k_math_is_cross(p3, p4, p) >= 0 and i3k_math_is_cross(p2, p3, p) * i3k_math_is_cross(p4 ,p1, p) >= 0
end
-- 判断两个线段是否相交
-- p1, p2为一条线段两端点 p3, p4为另一条线段的两端点   
function i3k_math_is_intersect(p1, p2, p3, p4)
	local mathMax = math.max
	local mathMin = math.min
	if mathMax(p1.x, p2.x) < mathMin(p3.x, p4.x) then  
		return false
	end
	if mathMax(p3.x, p4.x) < mathMin(p1.x, p2.x) then
	   return false;  
	end
	if mathMax(p1.z, p2.z) < mathMin(p3.z, p4.z)  then
	   return false
	end
	if mathMax(p3.z, p4.z) < mathMin(p1.z, p2.z) then
	   return false;  
	end
	if (i3k_math_is_cross(p3, p2, p1) * i3k_math_is_cross(p4, p2, p1) <= 0  and 
		i3k_math_is_cross(p1, p4, p3) * i3k_math_is_cross(p2, p4, p3) <= 0) then
		return true
	end  
    return false;  
end
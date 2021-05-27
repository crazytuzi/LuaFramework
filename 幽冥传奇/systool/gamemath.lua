
-- 函数名		描述				示例						结果
-- pi			圆周率				math.pi						3.1415926535898
-- abs			取绝对值			math.abs(-2012)				2012
-- ceil			向上取整			math.ceil(9.1)				10
-- floor		向下取整			math.floor(9.9)				9
-- max			取参数最大值		math.max(2, 4, 6, 8)		8
-- min			取参数最小值		math.min(2, 4, 6, 8)		2
-- pow			计算x的y次幂		math.pow(2, 16)				65536
-- sqrt			开平方				math.sqrt(65536)			256
-- mod			取模				math.mod(65535, 2)			1
-- modf			取整数和小数部分	math.modf(20.12)	 		20   0.12
-- randomseed	设随机数种子		math.randomseed(os.time())	　
-- random		取随机数			math.random(5, 90)			5~90
-- rad			角度转弧度			math.rad(180)				3.1415926535898
-- deg			弧度转角度			math.deg(math.pi)			180
-- exp			e的x次方			math.exp(4)					54.598150033144
-- log			计算x的自然对数		math.log(54.598150033144)	4
-- log10		计算10为底，x的对数	math.log10(1000)			3
-- frexp		将参数拆成x * (2 ^ y)的形式	math.frexp(160)		0.625	8
-- ldexp		计算x * (2 ^ y)	 	math.ldexp(0.625, 8)		160
-- sin			正弦				math.sin(math.rad(30))		0.5
-- cos			余弦				math.cos(math.rad(60))		0.5
-- tan			正切				math.tan(math.rad(45))		1
-- asin			反正弦				math.deg(math.asin(0.5))	30
-- acos			反余弦				math.deg(math.acos(0.5))	60
-- atan			反正切				math.deg(math.atan(1))		45
-- atan2		反正切				math.deg(math.atan2(45,45))	45

GameMath = GameMath or {}

GameMath.DirUp	 		= 0		-- 上
GameMath.DirUpRight 	= 1		-- 右上
GameMath.DirRight 		= 2		-- 右
GameMath.DirDownRight	= 3		-- 右下
GameMath.DirDown		= 4		-- 下
GameMath.DirDownLeft	= 5		-- 左下
GameMath.DirLeft		= 6		-- 左
GameMath.DirUpLeft		= 7		-- 左上

GameMath.MDirUp			= 0		-- 上
GameMath.MDirRight		= 2		-- 右
GameMath.MDirDown		= 4		-- 下
GameMath.MDirLeft		= 3		-- 左

GameMath.DirOffset = {
	[0] = cc.p(0, 1),			-- 上
	[1] = cc.p(1, 1),			-- 右上
	[2] = cc.p(1, 0),			-- 右
	[3] = cc.p(1, -1),			-- 右下
	[4] = cc.p(0, -1),			-- 下
	[5] = cc.p(-1, -1),			-- 左下
	[6] = cc.p(-1, 0),			-- 左
	[7] = cc.p(-1, 1),			-- 左上
}

-- 向量转数字方向
function GameMath.GetDirectionNumber(x, y)
	return GameMath.Angle2DirNumber(math.deg(math.atan2(y, x)))
end

-- 弧度转数字方向
function GameMath.Radian2DirNumber(radian)
	return GameMath.Angle2DirNumber(math.deg(radian))
end

-- 角度转数字方向
function GameMath.Angle2DirNumber(angle)
	angle = GameMath.NormalizeAngle(angle)

	if 22.5 <= angle and angle < 67.5 then
		return GameMath.DirUpRight
	elseif 67.5 <= angle and angle < 112.5 then
		return GameMath.DirUp
	elseif 112.5 <= angle and angle < 157.5 then
		return GameMath.DirUpLeft
	elseif 157.5 <= angle and angle < 202.5 then
		return GameMath.DirLeft
	elseif 202.5 <= angle and angle < 247.5 then
		return GameMath.DirDownLeft
	elseif 247.5 <= angle and angle < 292.5 then
		return GameMath.DirDown
	elseif 292.5 <= angle and angle < 337.5 then
		return GameMath.DirDownRight
	end

	return GameMath.DirRight
end

-- 资源是否需要翻转
function GameMath.GetResDirNumAndFlipFlag(dir_number)
	if dir_number == GameMath.DirLeft then
		return GameMath.DirRight, true
	elseif dir_number == GameMath.DirUpLeft then
		return GameMath.DirUpRight, true
	elseif dir_number == GameMath.DirDownLeft then
		return GameMath.DirDownRight, true
	end

	return dir_number, false
end

-- 标准化角度 0 ~ 360
function GameMath.NormalizeAngle(angle)
	if angle > 0 then
		while angle > 360  do
			angle = angle - 360
		end
	elseif angle < 0 then
		while angle < 0.0 do
			angle = angle + 360
		end
	end
	
	return angle
end

-- 四舍五入
function GameMath.Round(x)
	return math.floor(x + 0.5)
end

-- 取随机数
function GameMath.Rand(n1, n2)
	if n1 < n2 then
		return math.random(n1, n2)
	end
	return math.random(n2, n1)
end

--检测某点是否处于矩形内
function GameMath.IsInRect(p_x, p_y, r_x, r_y, r_w, r_h)
	if p_x < r_x or p_x > r_x + r_w or p_y < r_y or p_y > r_y + r_h then
		return false
	end
	return true
end

-- 求距离公式
-- @param need_sqrt 是否需要开方运算（不开方可以减少不必要的运算）
local x_step, y_step, val = 0, 0, 0
function GameMath.GetDistance(p1x, p1y, p2x, p2y, need_sqrt)
	x_step = p1x - p2x
	y_step = p1y - p2y
	val = x_step * x_step + y_step * y_step

	if need_sqrt then
		return math.sqrt(val)
	end
	
	return val
end

-- 求矩形交集
local min_x, min_y, max_x, max_y, w, h = 0, 0, 0, 0, 0, 0
function GameMath.GetRectMerge(rect1, rect2)
	min_x = math.min(rect1.x, rect2.x)
	min_y = math.min(rect1.y, rect2.y)
	max_x = math.max(rect1.x, rect2.x)
	max_y = math.max(rect1.y, rect2.y)

	w = max_x == rect1.x and rect1.width or rect2.width
	h = max_y == rect1.y and rect1.height or rect2.height

	return {x = min_x, y = min_y, width = max_x + w - min_x, height = max_y + h - min_y}
end

--水平方向裁减距形
--@rect1 被裁对象
function GameMath.TrimRectInHorizontal(rect1, rect2)
	local trim_rect = {}
	trim_rect.y = rect1.y
	trim_rect.height = rect1.height
	if rect2.x > rect1.x then
		trim_rect.x = rect1.x
		trim_rect.width = rect2.x - rect1.x
		trim_rect.width = math.min(trim_rect.width, rect1.width)
	elseif rect2.x < rect1.x then
		trim_rect.x = rect2.x + rect2.width
		trim_rect.x = math.max(trim_rect.x, rect1.x)
		trim_rect.width = rect1.x + rect1.width - trim_rect.x
		trim_rect.width = math.min(trim_rect.width, rect1.width)
	else
		trim_rect = TableCopy(rect1)
	end
	return trim_rect
end

--垂直方向裁减距形
--@rect1 被裁对象
function GameMath.TrimRectInVertical(rect1, rect2)
	local trim_rect = {}
	trim_rect.x = rect1.x
	trim_rect.width = rect1.width
	if rect2.y > rect1.y then
		trim_rect.y = rect1.y
		trim_rect.height = rect2.y - rect1.y
		trim_rect.height = math.min(trim_rect.height, rect1.height)
	elseif rect2.y < rect1.y then
		trim_rect.y = rect2.y + rect2.height
		trim_rect.y = math.max(trim_rect.y, rect1.y)
		trim_rect.height = rect1.y + rect1.height - trim_rect.y
		trim_rect.height = math.min(trim_rect.height, rect1.height)
	else
		trim_rect = TableCopy(rect1)
	end
	return trim_rect
end

function GameMath.GetPointIsInRect(x, y, rect)
	if x < rect.x or x > rect.x + rect.width or y < rect.y or y > rect.y + rect.height then
		return false
	end
	return true
end

--表达式优先级
GameMath.exp_level_list = {
[","] = 0,
["+"] = 1,
["-"] = 1,
["*"] = 2 ,
["/"] = 2,
["abs"] = 5,
["cos"] = 10,
["sin"] = 10,
["tan"] = 10,
["atan2"] = 10,
["rad"] = 20,
["deg"] = 20,
}

function GameMath.CalcExpression(str)
	return GameMath.CalcHouzuiExpression(GameMath.ConvertToHouzuiExpression(str))
end

--转换为后缀表达式
function GameMath.ConvertToHouzuiExpression(str)
	local temp_exp_stack = {}
	local houzui_stack = {}
	local str_len = string.len(str)
	local exp_level_list = GameMath.exp_level_list
	
	local prve_char = nil
	local is_use_minus_calc = false		 --是否使用负号运算
	local char_v = ""
	local char_index = 1

	while char_index <= str_len do

		local temp_char_v = string.sub(str, char_index, char_index)
		local is_calc_symbol = true	 --是否是运算号

		if temp_char_v == "-" and (prve_char == nil or 
			prve_char == "(" or exp_level_list[prve_char] ~= nil )  then -- "-"号特殊，有可能是负号或减号，需提前识别
			is_calc_symbol = false
			is_use_minus_calc = true
		end

		prve_char = temp_char_v

		if exp_level_list[temp_char_v] == nil and 
			temp_char_v ~= "(" and temp_char_v ~= ")" then 

			char_v = char_v .. temp_char_v
			is_calc_symbol = false 
		end

		if char_v == "rad" or char_v == "deg" or char_v == "abs" or char_v == "cos" or char_v == "sin" or char_v == "tan" or char_v == "atan2" then
			temp_char_v = char_v
			char_v = ""
			is_calc_symbol = true
		end

		if not is_calc_symbol and char_index == str_len then --最后一个字符，或是数字则直接进栈
			is_calc_symbol = false
			local number_value = tonumber(char_v)
			if number_value ~= nil then
				number_value = is_use_minus_calc and -1 * number_value or number_value
				is_use_minus_calc = false
				table.insert(houzui_stack, number_value) --把数字进压栈
			end
		end

		if is_calc_symbol then
			local number_value = tonumber(char_v)
			char_v = ""
			if number_value ~= nil then
				number_value = is_use_minus_calc and -1 * number_value or number_value
				is_use_minus_calc = false
				table.insert(houzui_stack, number_value) --把数字进压栈
			end
			
			local expression = temp_char_v
			if #temp_exp_stack == 0 or expression == "("then
				table.insert(temp_exp_stack, expression)
		
			else
				local top_exp = nil

				if expression == ")" then 
					local exp_stack_len = #temp_exp_stack
					while exp_stack_len > 0 do  --匹配此前的"("，栈顶依次出栈
						top_exp = temp_exp_stack[exp_stack_len]
						table.remove(temp_exp_stack, exp_stack_len)
						if top_exp == "(" then
							break
						else
							table.insert(houzui_stack, top_exp)
						end
						exp_stack_len = exp_stack_len - 1
					end

				else
				
					if exp_level_list[expression] then  --必须是有定义的算术符
						top_exp = temp_exp_stack[#temp_exp_stack]
						if exp_level_list[top_exp] == nil or exp_level_list[expression] >= exp_level_list[top_exp] then
							table.insert(temp_exp_stack, expression)
						else
							local exp_stack_len = #temp_exp_stack
							while exp_stack_len > 0 do  --栈顶优先级大于当前，则弹出
								top_exp = temp_exp_stack[exp_stack_len]
								if exp_level_list[top_exp] and exp_level_list[top_exp] >= exp_level_list[expression] then
									table.remove(temp_exp_stack, exp_stack_len)
									table.insert(houzui_stack, top_exp)
								else
									break
								end
								exp_stack_len = exp_stack_len - 1
							end
							table.insert(temp_exp_stack, expression)
						end
					end

				end
			end
		end
		char_index = char_index + 1
	end

	--全部出栈
	local exp_stack_len = #temp_exp_stack
	while exp_stack_len > 0 do
		table.insert(houzui_stack, temp_exp_stack[exp_stack_len])
		exp_stack_len = exp_stack_len - 1
	end

	return houzui_stack
end

--计算后缀表达式
function GameMath.CalcHouzuiExpression(houzui_stack)
	local value_stack = {}
	local exp_level_list = GameMath.exp_level_list

	local index = 1
	while index <= #houzui_stack do
		local value = houzui_stack[index]
		if exp_level_list[value] == nil then --数字
			table.insert(value_stack, value)
		else
			local new_value = nil
			
			if value == "-" or value == "+" or value == "*" or value == "/"
				or value == "atan2" then

				local top1 = table.remove(value_stack, #value_stack)
				local top2 = table.remove(value_stack, #value_stack)
				if value == "-" then
					new_value = top2 - top1
				end
				if value == "+" then
					new_value = top2 + top1
				end
				if value == "*" then
					new_value = top2 * top1
				end
				if value == "/" and top1 ~= 0 then
					new_value = top2 / top1
				end

				if value == "atan2" then
					new_value = math.atan2(top2, top1)
					table.remove(value_stack, #value_stack) --移除掉逗号运算符
				end
			end

			if value == "rad" or value == "deg" or value == "abs" or value == "sin" or
				 value == "cos" or value == "tan" then
				
				local top1 = table.remove(value_stack, #value_stack)
				if value == "sin" then
					new_value = math.sin(top1)
				end
				if value == "cos" then
					new_value = math.cos(top1)
				end
				if value == "tan" then
					new_value = math.tan(top1)
				end
				if value == "rad" then
					new_value = math.rad(top1)
				end
				if value == "deg" then
					new_value = math.deg(top1)
				end
				if value == "abs" then
					new_value = math.abs(top1)
				end
				if value == "," then
					new_value = top1
				end
			end

			if new_value ~= nil then
				new_value = new_value - new_value % 0.01
				table.insert(value_stack, new_value)
			end
		end
		index = index + 1
	end
	return value_stack[1] or 0
end

-- 点是否在凸多边形内
function GameMath.IsInPolygon(points, point)
	if #points < 3 then return false end
	local function mj(p1, p2, p3)
		local x1, y1 = p1.x, p1.y
		local x2, y2 = p2.x, p2.y
		local x3, y3 = p3.x, p3.y
		return 0.5 * math.abs(x2 * y1 - x3 * y1 - x1 * y2 + x3 * y2 + x1 * y3 - x2 * y3)
	end
	local all_s = 0
	for i = 2, #points do
		if points[i + 1] then
			all_s = all_s + mj(points[1], points[i], points[i + 1])
		end
	end
	local all_s_2 = 0
	for i = 1, #points do
		local p1 = points[i]
		local p2 = points[i + 1] or points[1]
		all_s_2 = all_s_2 + mj(point, p1, p2)
	end
	return all_s_2 <= all_s
end

function GameMath.DirAngle(pos_start, pos_end)
    local r_y = pos_end.y - pos_start.y
    local r_x = pos_end.x - pos_start.x
    return math.atan2(r_y, r_x) * - 180 / math.pi
end

function GameMath.FormatNum(str)   
    local new_str = ""  
    local count = 0  
	for i = string.len(str), 1, -1 do
		local a = string.sub(str, i, i)
		if a then
			if count % 3 == 0 and count ~= 0 then
				new_str = "," .. new_str
			end
			new_str = a .. new_str
			count = count + 1
		end
	end
	return new_str
end

function GameMath.GetStringShowMoneynum(num)
	local text = ""
	if num < 10000 then
		text = tostring(num)
	else
		text = string.format("%.1f%s", num/10000,Language.Common.Wan)
	end
	return text 
end


function GameMath.GetStringShowMoneynum2(num)
	local text = ""
	if num < 10000 then
		text = tostring(num)
	elseif num < 100000000 then
		text = string.format("%.2f%s", num/10000,Language.Common.Wan)
	elseif num >= 100000000 then
		text = string.format("%.2f%s", num/100000000,Language.Common.Yi)
	end
	return text 
end
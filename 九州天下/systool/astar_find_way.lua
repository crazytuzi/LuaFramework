
--[[local string = string

AStarFindWay = AStarFindWay or {
	w = 0,											-- 宽
	h = 0,											-- 高
	mask_table = {},								-- 阻挡信息，二维数组
	start_pos = {x = 0, y = 0},						-- 起点
	end_pos = {x = 0, y = 0},						-- 终点
	open_list = {},									-- 开放列表
	map = {},										-- 寻路信息缓存
}

AStarFindWay.BLOCK = string.byte("0")				-- 阻挡
AStarFindWay.WAY = string.byte("1")					-- 可通行
AStarFindWay.SAFE_AREA = string.byte("2")				-- 安全区

function AStarFindWay.PointInfo()
	return {
		x = 0,
		y = 0,
		block = false,
		g = 0,
		h = 0,
		parent = nil,
		dir = 0,
	}
end]]

GridCellType = {
    Obstacle = 0,
    Way = 1,
    Safe = 2,
    ObstacleWay = 3,
    Water = 4,
    Road = 5,
	Fishing = 6,
}

AStarFindWay = AStarFindWay or {}
GridFindWay = GridFindWay.New(512, 512)

function AStarFindWay:Init(mask_str, w, h)
	GridFindWay:LoadData(w, h, mask_str)

	--[[if string.len(mask_str) ~= w * h then
		print_log("AStarFindWay:Init error", w, h)
		return
	end

	self.mask_table = {}
	for x = 0, w - 1 do
		self.mask_table[x] = self.mask_table[x] or {}
		for y = 0, h - 1 do
			self.mask_table[x][y] = string.byte(mask_str, x + y * w + 1)
		end
	end
	self.w = w
	self.h = h
	self.map = {}]]
end

--local offset_list = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}, {-1, 1}, {1, 1}, {1, -1}, {-1, -1}}	-- 寻八个方向
function AStarFindWay:FindWay(start_pos, end_pos)
	return GridFindWay:FindWay(start_pos.x, start_pos.y, end_pos.x, end_pos.y)
	--[[if start_pos.x < 0 or start_pos.x >= self.w or start_pos.y < 0 or start_pos.y >= self.h then
		return false
	end
	if end_pos.x <= 0 or end_pos.x > self.w or end_pos.y <= 0 or end_pos.y > self.h then
		return false
	end

	self:Reset()

	self.start_pos = start_pos
	self.end_pos = end_pos

	if self:IsBlock(start_pos.x, start_pos.y) or self:IsBlock(end_pos.x, end_pos.y) then
		return false
	end

	-- 起点 终点 相同，直接返回
	if start_pos.x == end_pos.x and start_pos.y == end_pos.y then
		return false
	end

	local cur_pos = u3d.vec2(start_pos.x, start_pos.y)
	local x, y = 0, 0
	local cant_find = true
	local next_open = nil

	local m = nil
	local cur_p = nil
	for loops1 = 1, 1000000 do
		-- 将当前点置为已经检查过
		cur_p = self:GetPointInfo(cur_pos.x, cur_pos.y)
		cur_p.block = true
		cur_p.x = cur_pos.x
		cur_p.y = cur_pos.y

		for k, v in pairs(offset_list) do
			x, y = cur_pos.x + v[1], cur_pos.y + v[2]
			m = self:GetPointInfo(x, y)
			if x > 0 and x <= self.w and y > 0 and y <= self.h and not m.block and not self:IsBlock(x, y) then
				if x == end_pos.x and y == end_pos.y then
					m.parent = cur_p
					m.x = x
					m.y = y
					m.dir = k
					return true
				end

				self:CalcWeight(x, y, cur_pos, k)
			end
		end

		cant_find = true
		next_open = nil

		for loops2 = 1, 10000 do
			next_open = table.remove(self.open_list, 1)
			if nil == next_open then break end

			m = self:GetPointInfo(next_open.x, next_open.y)
			if not m.block then
				cur_pos.x = next_open.x
				cur_pos.y = next_open.y
				cant_find = false
				break
			end
		end
		if cant_find then return false end			-- 说明开放列表为空，那么就没有找到路径
	end

	return false]]
end

function AStarFindWay:GenerateInflexPoint(range)
	--[[local cur_p = self:GetPointInfo(self.end_pos.x, self.end_pos.y)
	local pos_list = {}

	if nil ~= range and range > 0 then
		local last_p = cur_p
		local temp_x, temp_y = 0, 0

		for loops = 1, 10000 do
			if nil == cur_p then break end

			temp_x = cur_p.x - self.end_pos.x
			temp_y = cur_p.y - self.end_pos.y
			if range * range < temp_x * temp_x + temp_y * temp_y then
				break
			end

			last_p = cur_p
			cur_p = cur_p.parent
		end

		cur_p = last_p
	end

	local cur_dir = -1
	for loops = 1, 10000 do
		if nil == cur_p then break end

		if cur_p.dir ~= cur_dir then
			table.insert(pos_list, 1, u3d.vec2(cur_p.x, cur_p.y))
			cur_dir = cur_p.dir
		end
		cur_p = cur_p.parent
	end

	return pos_list]]
	GridFindWay:GenerateInflexPoints(range)
	local pos_len = GridFindWay:GetPathLenth()
	local pos_list = {}
	for i=0,pos_len-1 do
		local x, y = GridFindWay:GetPathPoint(i, nil, nil)
		table.insert(pos_list, {x = x, y = y})
	end

	return pos_list
end

--[[local next_p, cur_p, g = nil, nil, 0
function AStarFindWay:CalcWeight(next_x, next_y, cur_pos, next_dir)
	next_p = self:GetPointInfo(next_x, next_y)
	cur_p = self:GetPointInfo(cur_pos.x, cur_pos.y)
	g = cur_p.g + 10000

	-- 方向改变的时候加权，可以让寻出来的路径尽量走直线
	if cur_p.dir ~= next_dir then
		g = g + 15000
	end

	if next_p.g == 0 or next_p.g > g then
		next_p.g = g
		next_p.parent = cur_p
		next_p.dir = next_dir						-- 记录当前与parant的dir

		if next_p.h == 0 then
			next_p.h = 10000 * (math.abs(next_x - self.end_pos.x) + math.abs(next_y - self.end_pos.y))
		end

		table.insert(self.open_list, {x = next_x, y = next_y})
	end
end

function AStarFindWay:Reset()
	self.open_list = {}

	local m = nil
	for x = 1, self.w do
		for y = 1, self.h do
			m = self.map[x * self.h + y]
			if m ~= nil then
				m.x = 0
				m.y = 0
				m.block = false
				m.g = 0
				m.h = 0
				m.parent = nil
				m.dir = 0
			end
		end
	end
end

local astar_i = nil
local astar_m = nil
function AStarFindWay:GetPointInfo(x, y)
	astar_i = x * self.h + y
	astar_m = self.map[astar_i]
	if astar_m ~= nil then
		return astar_m
	end

	astar_m = AStarFindWay.PointInfo()
	self.map[astar_i] = astar_m
	return astar_m
end]]

--是否水区
function AStarFindWay:IsWaterWay(x, y)
	return GridFindWay:IsWaterWay(x, y)
end


-- 是否阻挡区域
function AStarFindWay:IsBlock(x, y)
	return GridFindWay:IsBlock(x, y)
	--[[if x < 0 or x >= self.w or y < 0 or y >= self.h then
		return true
	end

	return AStarFindWay.BLOCK == self.mask_table[x][y]]
end

-- 是否安全区域
function AStarFindWay:IsInSafeArea(x, y)
	return GridFindWay:IsInSafeArea(x, y)
	--[[if x < 0 or x >= self.w or y < 0 or y >= self.h then
		return true
	end

	return AStarFindWay.SAFE_AREA == self.mask_table[x][y]]
end

function AStarFindWay:GetLineEndXY(x, y, end_x, end_y, cell_type)
	cell_type = cell_type or -1
	return GridFindWay:GetLineEndXY(x, y, end_x, end_y, cell_type, nil, nil)
	--[[local delta_pos = u3d.vec2(end_x - x, end_y - y)
	local distance = math.floor(u3d.v2Length(delta_pos))
	if distance <= 0 then return x, y end

	local target_x, target_y = x, y
	local normalize = u3d.v2Normalize(delta_pos)
	local temp_x, temp_y = 0, 0

	for i = 1, distance do
		temp_x, temp_y = math.floor(x + normalize.x * i), math.floor(y + normalize.y * i)
		if self:IsBlock(temp_x, temp_y) then
			break
		end
		target_x = temp_x
		target_y = temp_y
	end

	return target_x, target_y]]
end

function AStarFindWay:GetLineEndXY2(x, y, end_x, end_y)
	return GridFindWay:GetLineEndXY2(x, y, end_x, end_y, nil, nil)
	--[[local delta_pos = u3d.vec2(x - end_x, y - end_y)
	local distance = math.floor(u3d.v2Length(delta_pos))
	if distance <= 0 then return end_x, end_y end

	local target_x, target_y = x, y
	local normalize = u3d.v2Normalize(delta_pos)
	local temp_x, temp_y = 0, 0

	for i = 0, distance do
		temp_x, temp_y = math.floor(end_x + normalize.x * i), math.floor(end_y + normalize.y * i)
		if not self:IsBlock(temp_x, temp_y) then
			target_x = temp_x
			target_y = temp_y
			break
		end
	end

	return target_x, target_y]]
end

-- 寻找目标range范围内最近的可站立点
function AStarFindWay:GetTargetXY(x, y, end_x, end_y, range)
	return GridFindWay:GetTargetXY(x, y, end_x, end_y, range, nil, nil, nil)
	--[[local delta_pos = u3d.vec2(x - end_x, y - end_y)
	local distance = math.floor(u3d.v2Length(delta_pos))
	if distance <= range then return x, y, 0 end

	local target_x, target_y, target_range = end_x, end_y, range
	local normalize = u3d.v2Normalize(delta_pos)
	local temp_x, temp_y = 0, 0

	for i = 1, range do
		temp_x, temp_y = math.floor(end_x + normalize.x * i), math.floor(end_y + normalize.y * i)
		if self:IsBlock(temp_x, temp_y) then
			break
		end
		target_x = temp_x
		target_y = temp_y
		target_range = range - i
	end

	return target_x, target_y, target_range]]
end

-- 是否可直线通行
function AStarFindWay:IsWayLine(x, y, end_x, end_y)
	return GridFindWay:IsWayLine(x, y, end_x, end_y)
	--[[if self:IsBlock(end_x, end_y) then
		return false
	end

	local delta_pos = u3d.vec2(end_x - x, end_y - y)

	local distance = math.floor(u3d.v2Length(delta_pos))
	if distance <= 0 then return true end

	local normalize = u3d.v2Normalize(delta_pos)
	local temp_x, temp_y = 0, 0

	for i = 1, distance do
		temp_x, temp_y = math.floor(x + normalize.x * i), math.floor(y + normalize.y * i)
		if self:IsBlock(temp_x, temp_y) then
			return false
		end
	end

	return true]]
end

--是否可钓鱼区域
function AStarFindWay:IsFishing(x, y)
	return GridFindWay:IsFishing(x, y)
end

function AStarFindWay:SetBlockInfo(x, y)
	GridFindWay:SetBlock(x, y)
end

function AStarFindWay:RevertBlockInfo(x, y)
	GridFindWay:RevertBlock(x, y)
end

function AStarFindWay:GetAroundVaildXY(x, y, range)
	if not AStarFindWay:IsBlock(x, y) then
		return x, y
	end

	for _x = x - range, x + range do
		for _y = y - range, y + range do
			if not AStarFindWay:IsBlock(_x, _y) then
				return _x, _y
			end
		end
	end

	return x, y
end
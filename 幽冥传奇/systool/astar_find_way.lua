
AStarFindWay = AStarFindWay or BaseClass()

AStarFindWay.BLOCK = 0								-- 阻挡
AStarFindWay.WAY = 1								-- 可通行

function AStarFindWay:__init()
	self.w = 0										-- 宽
	self.h = 0										-- 高
	self.mask_table = {}							-- 阻挡信息，二维数组
	self.start_pos = cc.p(0, 0)						-- 起点
	self.end_pos = cc.p(0, 0)						-- 终点
	self.open_list = {}								-- 开放列表
	self.map = {}									-- 寻路信息缓存
end

function AStarFindWay:__delete()
end

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
end

function AStarFindWay.OpenItem(_x, _y, _f)
	return {x = _x or 0, y = _y or 0, f = _f or 0,}
end

function AStarFindWay:Init(mask_table, w, h)
	self.mask_table = mask_table
	self.w = w
	self.h = h
end

function AStarFindWay:FindWay(start_pos, end_pos)
	if start_pos.x <= 0 or start_pos.x > self.w or start_pos.y <= 0 or start_pos.y > self.h then
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

	local cur_pos = cc.p(start_pos.x, start_pos.y)
	for loops1 = 1, 1000000 do
		-- 将当前点置为已经检查过
		self.map[cur_pos.x][cur_pos.y].block = true
		self.map[cur_pos.x][cur_pos.y].x = cur_pos.x
		self.map[cur_pos.x][cur_pos.y].y = cur_pos.y

		local offset_list = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}	-- 只寻四个方向
		for k, v in pairs(offset_list) do
			local x, y = cur_pos.x + v[1], cur_pos.y + v[2]
			if x > 0 and x <= self.w and y > 0 and y <= self.h and not self.map[x][y].block and not self:IsBlock(x, y) then
				if x == end_pos.x and y == end_pos.y then
					self.map[x][y].parent = self.map[cur_pos.x][cur_pos.y]
					self.map[x][y].x = x
					self.map[x][y].y = y
					self.map[x][y].dir = k
					return true
				end

				self:CalcWeight(x, y, cur_pos, false, k)
			end
		end

		local cant_find = true
		for loops2 = 1, 10000 do
			local next_open = table.remove(self.open_list, 1)
			if nil == next_open then break end

			if not self.map[next_open.x][next_open.y].block then
				cur_pos.x = next_open.x
				cur_pos.y = next_open.y
				cant_find = false
				break
			end
		end
		if cant_find then return false end			-- 说明开放列表为空，那么就没有找到路径
	end

	return false
end

function AStarFindWay:GenerateInflexPoint()
 	local cur_p = self.map[self.end_pos.x][self.end_pos.y]
	local pos_list = {}
	local cur_dir = -1

	for loops = 1, 10000 do
		if nil == cur_p then break end

		-- if cur_p.dir ~= cur_dir then
			table.insert(pos_list, 1, cc.p(cur_p.x, cur_p.y))
			cur_dir = cur_p.dir
		-- end
		cur_p = cur_p.parent
 	end

 	return pos_list
end

function AStarFindWay:CalcWeight(next_x, next_y, cur_pos, is_slash, next_dir)
	local next_p = self.map[next_x][next_y]
	local cur_p = self.map[cur_pos.x][cur_pos.y]

	local g = cur_p.g + (is_slash and 14142 or 10000)

	-- 方向改变的时候加权，可以让寻出来的路径尽量走直线
	if cur_p.dir ~= next_dir then
		g = g + 15000
	end

	if is_slash then
		if self:IsBlock(next_x, cur_pos.y) or self:IsBlock(cur_pos.x, next_y) then
			return
		end
	end

	if next_p.g == 0 or next_p.g > g then
		next_p.g = g
		next_p.parent = cur_p
		next_p.dir = next_dir						-- 记录当前与parant的dir

		if next_p.h == 0 then
			next_p.h = 10000 * self:CalH(next_x, next_y)
		end

		local f = next_p.h + next_p.g
		table.insert(self.open_list, AStarFindWay.OpenItem(next_x, next_y, f))
	end
end

function AStarFindWay:Reset()
	self.open_list = {}

	self.map = {}
	for x = 1, self.w do
		self.map[x] = {}
		for y = 1, self.h do
			self.map[x][y] = AStarFindWay.PointInfo()
		end
	end
end

function AStarFindWay:CalH(pos_x, pos_y)
	local x_dis = math.abs(pos_x - self.end_pos.x)
	local y_dis = math.abs(pos_y - self.end_pos.y)

	return x_dis + y_dis;
end

function AStarFindWay:IsBlock(x, y)
	if nil == self.mask_table[x] or nil == self.mask_table[x][y] then
		return true
	end

	return AStarFindWay.BLOCK == self.mask_table[x][y]
end
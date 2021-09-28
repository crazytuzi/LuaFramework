-- a星寻路 优化 
-- 优先选择简单路径尝试能否通过，可以就不用a*

-- a星获取路径
Astar =BaseClass()
Astar.block={}
-- 初始化
function Astar:__init(startPoint, endPoint)
	if startPoint[1] == endPoint[1] and startPoint[2] == endPoint[2] then 
			else
		if Astar.isBlock(endPoint[1], endPoint[2]) then 
					else
			local sx,sy = startPoint[1], startPoint[2]
			local ex,ey = endPoint[1], endPoint[2]

			self.allPoint = {}
			self:addPoint(sx,sy)
			self:addPoint(ex,ey)
			self.startPoint = self.allPoint[sx][sy]
			self.endPoint = self.allPoint[ex][ey]
			self.openList = {}
			self.closeList = {}
			table.insert(self.openList, self.startPoint)
			local findEnd = self:findPath()
			if findEnd then 
				self.path = self:getPath()
			end
		end
	end
end

function Astar:getAPath()
	return self.path
end

function Astar:getPath()

	local path = {{x=self.endPoint.x, y=self.endPoint.y}}
	local findEnd = self.endPoint
	repeat
		local point = findEnd.parent
		if nil ~= point then 
			table.insert(path, {x=point.x, y=point.y})
		end  
		findEnd = point
	until findEnd.parent == nil
	path = self:Optimization( path )
	return path
end

-- 优化获得拐点
function Astar:Optimization( path )
	if path then 
		if #path>2 then
			local a = path[1]
			local b = nil
			local c = nil
			local opt = {a}
			for i=1, #path do
				b = path[i+1]
				c = path[i+2]
				if b and c then
					if (b.y-a.y)/(b.x-a.x) ~= (c.y-a.y)/(c.x-a.x) then -- 三点共线
						table.insert(opt, b)
						a = b
					end
				end
			end
			path = opt
		else
			path = table.remove(path, #path)
		end
	end
	return path
end

-- 获取最小f的点，并且处理开闭列表
function Astar:getMinPoint()
	local point = self.openList[1] 
	local index = 1
	if #self.openList > 1 then
		for i = 2, #self.openList do 
			if self.openList[i].f < point.f then 
				point = self.openList[i]
				index = i
			end
		end
	end
	table.remove(self.openList, index)
	table.insert(self.closeList, point)
	return point
end

-- 获取一个点
function Astar:getPoint(point)
	for i, p in pairs(self.openList) do 
		if p.x == point.x and p.y == point.y then 
			return p
		end
	end 
	return nil
end

-- 寻找路径
function Astar:findPath()
	while #self.openList ~= 0 do 
		local tmpStart = self:getMinPoint()
				local surroundPoints = self:getSurroundPoints(tmpStart)
		for i, point in pairs(surroundPoints) do 
			if self:existsPoint(self.openList, point.x, point.y) then 
				self:foundPoint(tmpStart, point)
			else 
				self:notFoundPoint(tmpStart, point)
			end
		end
		local pointEnd = self:getPoint(self.endPoint)
		if nil ~= pointEnd then
			return pointEnd
		end
	end
	return nil
end

-- 是否存在点
function Astar:existsPoint(list, x, y)
	for _, p in pairs(list) do 
		if p.x == x and p.y == y then 
			return true
		end
	end
	return false
end

-- 找到点在开列表，对比之前的g
function Astar:foundPoint(tmpStart, point)
	local g = self.calcG(tmpStart, point)
	if g < point.g then
		point.parent = tmpStart
		point.g = g
		self.calcF(point)
	end
end

-- 没找到点，直接加入开列表
function Astar:notFoundPoint(tmpStart, point)
	point.parent = tmpStart
	point.g = self.calcG(tmpStart, point)
	self:calcH(point)
	self.calcF(point)
	table.insert(self.openList, point)
end

function Astar:calcH(point)
	point.h = math.abs(point.x - self.endPoint.x) + math.abs(point.y - self.endPoint.y)
end

function Astar.calcF(point)
	point.f = point.g + point.h
end

function Astar.calcG(tmpStart, point)
	local g 
	if math.abs(point.x - tmpStart.x) + math.abs(point.y - tmpStart.y) == 2 then g = 1.4 else g = 1 end
	local parent_g = tmpStart.g
	return g + parent_g
end

-- 添加一点
function Astar:addPoint(x, y)
	if nil == self.allPoint[x] then 
		self.allPoint[x] = {}
	end
	if nil == self.allPoint[x][y] then 
		local point = {}
		point.parent = nil
		point.f = 0 
		point.h = 0
		point.g = 0
		point.x = x
		point.y = y
		self.allPoint[x][y] = point
	end
end

function Astar.isBlock(yy, xx) -- (x, y)
	if not Astar.block then return true end
	if (yy > #Astar.block[1]) or (xx > #Astar.block) or (yy < 1) or (xx < 1) then 
		return true 
	end
	if Astar.block[xx] and Astar.block[xx][yy] ~= 1 then
		return false
	else
		return true
	end
end

function Astar.isAlpha( xx, yy )
	if Astar.block[xx] and Astar.block[xx][yy] == 2 then
		return true
	else
		return false
	end
end

-- 判断障碍
function Astar:canReach(point, x, y) -- 加点测试障碍
	if Astar.isBlock(x, y) then return false end
	if self:existsPoint(self.closeList, x, y) then 
		return false
	else 
		return true
	end
end

-- 获得周围八格的点
function Astar:getSurroundPoints(point)
	local surroundPoints = {}
	for i = point.x - 1, point.x + 1 do 
		for j = point.y -1, point.y + 1 do
			if self:canReach(point, i, j) then 
				self:addPoint(i, j)
				table.insert(surroundPoints, self.allPoint[i][j])
			end
		end
	end
	return surroundPoints
end
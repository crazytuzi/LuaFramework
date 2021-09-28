--*************************************************
-- how to use:
-- TweenNano.to(TweenTarget:new(self.m_pDownView, TweenTarget.Window),
--                    1.5, {ease = {type=TweenCirc.type, fun = TweenBack.easeInOut},
--                    plugin = BezierPlugin.type, value={{x=-800, y=-80}, {x=-900, y=-680}, {x=-1000, y=-80}}})
--**************************************************
BezierPlugin = {}

BezierPlugin.__index = BezierPlugin
BezierPlugin.type = "bezierPlugin"
local _RAD2DEG = 180 / 3.1415926
function BezierPlugin:new()
	local self = {}
	setmetatable(self, BezierPlugin)
	self.__index = self
	self.m_pFuture = {}
	self.orient = false
	self.round = false
	return self
end

function BezierPlugin:initTween(target, value, tween)
	self:init(tween, value, false)
end

function BezierPlugin:init(tween, beziers, through)
	self.target = tween.target
	if beziers.orientToBezier == true then
		self.orientData = {{"x", "y", "rotation", 0, 0.01}}
		self.orient = true
	end
	-- else
	-- 	self.orientData = self
	local props = {}
	for k, v in pairs(beziers) do
		
		for m,n in pairs(v) do
			if not props[m] then
				props[m] = {}
				local count = 0
				if m == "x" then
					props[m][count] =  tween.target:getX()
				elseif m == "y" then
					props[m][count] =  tween.target:getY()
				end
				count = count + 1
				props[m][count] = n
			else
				table.insert(props[m], n)
			end
		end
	end

	self.m_pBeziers = self:parseBeziers(props, through)
end

function BezierPlugin:parseBeziers(props, through)
	local a = {}
	local b = {}
	local p
	local all = {}
	if through then
		for p, a in pairs(props) do
			b = {}
			all[p] = b
			local len = TableUtil.tablelength(a)
			if len > 2 then
				b[TableUtil.tablelength(b)] = {a[0], a[1] - ((a[2] - a[0]) / 4), a[1]}
				for i = 1, TableUtil.tablelength(a) - 2 do
					b[TableUtil.tablelength(b)] = {a[i], a[i] + (a[i] - b[i-1][2]), a[i+1]}
				end
			else
				b[TableUtil.tablelength(b)] = {a[0], (a[0] + a[1]) / 2, a[1]}
			end
		end
	else
		for p,a in pairs(props) do
			b = {}
			all[p] = b
			local len = TableUtil.tablelength(a)
			if len > 3 then
				b[TableUtil.tablelength(b)] = {a[0], a[1], (a[1] + a[2])/ 2}
				for i=2,TableUtil.tablelength(a)-3 do
					b[TableUtil.tablelength(b)] = {b[i-2][3], a[i], (a[i] + a[i+1])/2}
				end
				local l3 = TableUtil.tablelength(b)
				b[l3] = {b[l3-1][3], a[TableUtil.tablelength(a)-2], a[TableUtil.tablelength(a)-1]}
			elseif len == 3 then
				b[TableUtil.tablelength(b)] = {a[0], a[1], a[2]}
			elseif len == 2 then
				b[TableUtil.tablelength(b)] = {a[0], (a[0] + a[1]) / 2, a[1]}
			end
		end
	end
	return all
end

function BezierPlugin:SetChangeFactor(n)
	local segments
	local i = 0
	local t = 0
	self.m_pChangeFctor = n
	if n == 1 then
		for k, v in pairs(self.m_pBeziers) do
			if k == "x" then
				local len = TableUtil.tablelength(self.m_pBeziers.x) - 1
				self.target:setX(self.m_pBeziers.x[len][3])
			end
			if k == "y" then
				local len = TableUtil.tablelength(self.m_pBeziers.y) - 1
				self.target:setY(self.m_pBeziers.y[len][3])
			end
		end
	else
		for k, v in pairs(self.m_pBeziers) do
			segments = TableUtil.tablelength(v)
			if n < 0 then
				i = 0
			elseif n >= 1 then
				i = segments -1
			else 
				i = math.floor(segments * n) 
			end
			t = (n - (i * (1/segments))) * segments
			b = self.m_pBeziers[k][i]

			local num = b[1] + t * (2 * (1 - t) * (b[2] - b[1]) + t * (b[3] - b[1]))
			if k == "x" then
				self.target:setX(num)
			end
			if k == "y" then
				self.target:setY(num)
			end
		end
	end

	if self.orient then
		i = TableUtil.tablelength(self.orientData)
		local curVals = {}, dx, dy, cotb, toAdd
		while i > 0 do
			cotb = self.orientData[i]--current orientToBezier Array
			curVals.x = self.target:getX()
			curVals.y = self.target:getY()
			i = i - 1
		end
		
		local oldTarget = self.target
		local oldRound = self.round
		self.target = self.m_pFuture
		self.round = false
		self.orient = false
		i = TableUtil.tablelength(self.orientData)
		while i > 0 do
			cotb = self.orientData[i] --current orientToBezier Array
			self:SetChangeFactor(n + (cotb[5] or 0.01))
			toAdd = cotb[4] or 0
			dx = self.m_pFuture:getX() - curVals[cotb[1]]
			dy = self.m_pFuture:getY() - curVals[cotb[2]]
			oldTarget:setRotation(math.atan2(dy, dx) * _RAD2DEG + toAdd)
		end
		self.target = oldTarget
		self.round = oldRound
		self.orient = true
	end
end

function BezierPlugin:GetChangeFactor()
	return self.m_pChangeFctor
end
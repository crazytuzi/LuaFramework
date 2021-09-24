--让一个目标精灵做圆周运动
CircleBy={}

local M_PI=3.14159265358979323846264338327950288

function CircleBy:new(target,duration,circelCenter,radius,times,callback)
	local nc={}

	setmetatable(nc,self)
	self.__index=self

	return nc
end

--times：圆周运动的圈数
function CircleBy:create(target,duration,circelCenter,radius,times)
	local nc=CircleBy:new()
	nc:init(target,duration,circelCenter,radius,times)
	return nc
end

function CircleBy:init(target,duration,circelCenter,radius,times)
	self.target=target --执行动作的target
	self.duration=duration --动作持续时间
	self.circelCenter=circelCenter --目标的圆心坐标
	self.radius=radius --圆周半径
	self.deltaRadian=2*M_PI*times --需要移动的总弧度
	self.running=true
	base:addNeedRefreshObject(self)
end

function CircleBy:fastTick(dt)
	if self.target==nil then
		do return end
	end
	if tolua.cast(self.target,"CCNode")==nil then --如果目标已经不存在了则移除圆周运动
		self:dipose()
		do return end
	end
	if self.running==false then
		do return end
	end
	self.elapsed=(self.elapsed or 0)+dt --动作已过去的时间
	local ratio=math.max(0,math.min(1,self.elapsed/self.duration))
	local radian=ratio*self.deltaRadian --当前移动的弧度
	local x=self.radius*math.sin(radian)
	local y=self.radius*math.cos(radian)

	local newPos=ccp(x+self.circelCenter.x,y+self.circelCenter.y)
	self.target:setPosition(newPos)
	
	if self:isDone() then --动作完成后移除动作
		self:stop()
	end
end

function CircleBy:stop()
	self:dipose()
end

function CircleBy:pause()
	self.running=false
end

function CircleBy:resume()
	self.running=true
end

function CircleBy:isDone()
	if self.elapsed>=self.duration then
		return true
	end
	return false
end

function CircleBy:dipose()
	self.target=nil
	self.duration=nil
	self.circelCenter=nil
	self.radius=nil
	self.running=nil
	self.elapsed=nil
	base:removeNeedRefreshObject(self)
end
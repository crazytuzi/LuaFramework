Starts = BaseClass(LuaUI)

function Starts:__init(...)
	self.ui = UIPackage.CreateObject("Common" , "CustomLayerV")

	self.starts = {}
	local x = 0
	for i = 1, 5 do
		local star = Start.New()
		star:SetXY(x, 0)
		self.ui:AddChild(star.ui)
		table.insert(self.starts, star)
		x = x + 46 + 5
	end
	self.ui:SetSize(x + 46, 50)
end

function Starts:SetLevel(level)
	for i = 1, 5 do
		if i <= level then
			self.starts[i]:Light()
		else
			self.starts[i]:UnLight()
		end
	end
end

function Starts:SetStarState(index, lightOrNot, bomp)
	if not self.starts[index] then return end
	if lightOrNot then
		self.starts[index]:Light(bomp)
	else
		self.starts[index]:UnLight()
	end
end

function Starts:SetFly(index, targetPos, duration, endCallBack)
	if not self.starts[index] then return end
	self.starts[index]:FlyTo(targetPos, duration, endCallBack)
end

function Starts:__delete()
	destroyUIList(self.starts)
	self.starts = nil
end
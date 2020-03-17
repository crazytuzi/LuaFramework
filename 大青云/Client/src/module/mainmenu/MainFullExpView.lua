--[[
经验满格特效

]]
_G.UIFullExp = BaseUI:new("UIFullExp")
function UIFullExp:Create()
	self:AddSWF("mainFullExp.swf", true, "bottom")
end

function UIFullExp:OnLoaded( objSwf )
	for i = 1, 10 do 
		objSwf["FKEffect"..i]._visible = false
		objSwf["LZEffect"..i]._visible = false
	end
	objSwf.bgEffect._visible = false
end

function UIFullExp:GetWidth()
	return 1004
end

function UIFullExp:GetHeight()
	return 161
end
UIFullExp.timerKey = nil;
UIFullExp.timerKey2 = nil;
UIFullExp.timerKey3 = nil;
function UIFullExp:OnShow()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	if self.timerKey2 then
		TimerManager:UnRegisterTimer(self.timerKey2)
		self.timerKey2 = nil;
	end
	if self.timerKey3 then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey3 = nil;
	end
	self:ShowFullExpEffect()
end
--经验条满格时特效
function UIFullExp:ShowFullExpEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1, 10 do
		local timeFk = math.random(0,16)
		self.timerKey = TimerManager:RegisterTimer(function()
			self:fkEffect(i)
		end,timeFk*100,1);
	end
	self.timerKey3 = TimerManager:RegisterTimer(function()
		local objSwf = self.objSwf ;
		if not objSwf then return end
		objSwf.bgEffect._visible = false
		UIMainSkill:ShowSiExp()
	end,1975,1);
	
end
function UIFullExp:fkEffect(i)
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf["FKEffect"..i]._visible = true
	objSwf.bgEffect._visible = true
	self:lzEffect(i)
end
local pos3d = _Vector3.new()
local ret2d = _Vector2.new()
function UIFullExp:lzEffect(i)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local lz = objSwf["LZEffect"..i]
	lz._visible = true
	local posX = lz._x;
	local posY = lz._y;

	local rdG = self:getMyPos()
	
	lz._rotation = GetAngleTwoPoint(_Vector2.new(posX,posY), _Vector2.new(rdG.x,rdG.y-25)) - 90;
	
	Tween:To( lz, 1, {_alpha = 100,_y = rdG.y-25,_x = rdG.x}, { onComplete = function() self:recyle(i) end ,onUpdate = function() end})
	self.timerKey2 = TimerManager:RegisterTimer(function()
		local objSwf = self.objSwf ;
		if not objSwf then return end
		objSwf["FKEffect"..i]._visible = false
	end,375,1);
end
function UIFullExp:getMyPos()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local mePos = MainPlayerController:GetPos();
	local posX,posY,posZ = mePos.x, mePos.y, mePos.z
	pos3d.x = posX
	pos3d.y = posY
	pos3d.z = posZ
	-- 3D映射到屏幕坐标
	_rd:projectPoint(pos3d.x, pos3d.y, pos3d.z, ret2d)
	local rdG = UIManager:PosGtoL( objSwf, ret2d.x,ret2d.y)
	return rdG
end
function UIFullExp: recyle(i)
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf["LZEffect"..i]._visible = false
	local lz = objSwf["LZEffect"..i]
	Tween:To( lz, 1, {_y = 199,_x = 63+90*(i-1), ease = Cubic.easeOut})
end

function UIFullExp:OnHide( )
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	if self.timerKey2 then
		TimerManager:UnRegisterTimer(self.timerKey2)
		self.timerKey2 = nil;
	end
	if self.timerKey3 then
		TimerManager:UnRegisterTimer(self.timerKey3)
		self.timerKey3 = nil;
	end
end


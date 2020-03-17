--[[
摄像机画圆
liyuan
2014年10月15日21:33:06
]]

_G.C_CameraCircle = { }
setmetatable(C_CameraCircle,{__index = C_CameraBase});
function C_CameraCircle:new()
	local obj = C_CameraBase:new()
	setmetatable(obj, {__index = C_CameraCircle})
	obj.isPlay = false
	obj.loop = false
	obj.ocircle = nil
	obj.eyeOrbit = nil
	obj.lookOrbit = nil
	obj.callback = nil
	obj.cam0 = _Camera.new( )
	obj.look0 = _Vector3.new( )
	return obj
end

function C_CameraCircle:getCamera() 
	return self.cam0 
end

function C_CameraCircle:SetFov(fov)
	self.cam0.fov = fov
end

function C_CameraCircle:SetLook( x, y, z )
	self.look0 = _Vector3.new( x, y, z )
	self.cam0.look = _Vector3.new( x, y, z ) 
end

local circle = { }
function C_CameraCircle:SetCircle(cir, isPlay,loop,callback)
	self.ocircle = _Orbit.new( )
	circle = { }
	for i, v in ipairs( cir ) do
		circle[i] = { }
		circle[i].time = v.time
		circle[i].pos = _Vector3.new( v.x, v.y, v.z )
	end
	
	self.ocircle:create( circle )
	self.isPlay = isPlay
	self.loop = loop
	self.callback = callback
end

local lookCircle = nil;
function C_CameraCircle:SetLookCircle(cir)
	self.lookOrbit = _Orbit.new( )
	lookCircle = { }
	for i, v in ipairs( cir ) do
		lookCircle[i] = { }
		lookCircle[i].time = v.time
		lookCircle[i].pos = _Vector3.new( v.x, v.y, v.z )
	end
	
	self.lookOrbit:create( lookCircle )
end

local eyeCircle = nil;
function C_CameraCircle:SetEyeCircle(cir)
	self.eyeOrbit = _Orbit.new( )
	eyeCircle = { }
	for i, v in ipairs( cir ) do
		eyeCircle[i] = { }
		eyeCircle[i].time = v.time
		eyeCircle[i].pos = _Vector3.new( v.x, v.y, v.z )
	end
	
	self.eyeOrbit:create( eyeCircle )
end

function C_CameraCircle:StopAllAction()
	self.isPlay = false
end

function C_CameraCircle:PlayCamera(isPlay,loop,callback)
	self.isPlay = isPlay
	self.loop = loop
	self.callback = callback
end

function C_CameraCircle:Update(e)
	if not self.isPlay then
		return;
	end
	
	if self.ocircle then
		self.ocircle:update( e )
		self.cam0.eye.x = self.ocircle.pos.x
		self.cam0.eye.y = self.ocircle.pos.y
		self.cam0.eye.z = self.ocircle.pos.z
		
		self.cam0.look.x = self.look0.x
		self.cam0.look.y = self.look0.y
		self.cam0.look.z = self.look0.z
		
		if self.ocircle.over and circle then 
			if self.loop then
				self.ocircle:create( circle ) 
			else
				self.isPlay = false
				if self.callback then
					self.callback();
				end				
			end
		end
	end
	
	if self.lookOrbit and self.eyeOrbit then
		self.lookOrbit:update( e )
		self.eyeOrbit:update( e )
		
		self.cam0.look.x = self.lookOrbit.pos.x
		self.cam0.look.y = self.lookOrbit.pos.y
		self.cam0.look.z = self.lookOrbit.pos.z
		
		self.cam0.eye.x = self.eyeOrbit.pos.x
		self.cam0.eye.y = self.eyeOrbit.pos.y
		self.cam0.eye.z = self.eyeOrbit.pos.z
		
		if self.lookOrbit.over or self.eyeOrbit.over then 
			if self.loop then
				self.lookOrbit:create( lookCircle ) 
				self.eyeOrbit:create( eyeCircle ) 
			else
				self.isPlay = false
				if self.callback then
					self.callback();
				end				
			end
		end
		
	end
	
end

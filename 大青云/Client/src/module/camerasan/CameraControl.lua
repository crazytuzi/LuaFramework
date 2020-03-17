-- 摄像机轨迹
_G.CameraControl = { }
CameraControl.tempCamera = nil
CameraControl.state = 0
-- 摄像机骨骼动画
CameraControl.sanCamera = nil
-- 摄像机画圆
CameraControl.circleCamera = nil

-- update
function CameraControl:onUpdate(e)
	if self.state == CameraConsts.State_San then	
		self.sanCamera:Update()
		_rd.camera:set(self.sanCamera:getCamera())
	elseif self.state == CameraConsts.State_Circle then	
		self.circleCamera:Update(e)
		_rd.camera:set(self.circleCamera:getCamera())
	end
end

-- 保存原始摄像机
function CameraControl:RecordCamera()
	if not self.sanCamera then
		self.sanCamera = C_CameraSan:new()
	end
	if not self.circleCamera then
		self.circleCamera = C_CameraCircle:new()
	end
	if not self.tempCamera then
		self.tempCamera = _Camera:new()
	end
	self.tempCamera:set(_rd.camera)--保留当前相机
end

-- 得到当前摄像机
function CameraControl:getCamera() 
	if self.state == CameraConsts.State_San then
		return self.sanCamera 
	elseif self.state == CameraConsts.State_Circle then
		return self.circleCamera
	else
		return nil
	end
end

-- 重置轨迹
function CameraControl:StopAll()
-- FPrint("重置轨迹")
	-- print(debug.traceback())
	self.state = CameraConsts.State_nil
	if self.sanCamera then
		self.sanCamera:StopAllAction()
	end
	if self.circleCamera then
		self.circleCamera:StopAllAction()
	end
end

-- 清空轨迹
function CameraControl:Clear()
-- FPrint("清空轨迹")
-- print(debug.traceback())
	self.state = CameraConsts.State_nil
	if self.sanCamera then
		self.sanCamera:StopAllAction()
	end
	if self.circleCamera then
		self.circleCamera:StopAllAction()
	end
	if self.tempCamera then
		_rd.camera:set(self.tempCamera)--还原摄像机
	end
end

----------------------------------------------
-- 摄像机骨骼动画
----------------------------------------------
-- 播放轨迹动画
function CameraControl:PlayAnimation(name, tar, loop, callback)
	self.state = CameraConsts.State_San
	self.sanCamera:ExecAction(name, tar, loop, function() 
		-- FPrint("播放轨迹动画")
		-- print(debug.traceback())
		self.state = CameraConsts.State_nil
		if callback then
			callback()
		end
	end) 
end

----------------------------------------------
-- 摄像机画圆
----------------------------------------------
function CameraControl:PlayCircle(cir, isPlay,loop,callback)
	self.state = CameraConsts.State_Circle
	self.circleCamera:SetCircle(cir, isPlay,loop,callback)
end

function CameraControl:SetLookCircle(cir)
	self.circleCamera:SetLookCircle(cir);
end

function CameraControl:SetEyeCircle(cir)
	self.circleCamera:SetEyeCircle(cir);
end

function CameraControl:PlayCamera(isPlay,loop,callback)
	self.state = CameraConsts.State_Circle
	self.circleCamera:PlayCamera(isPlay,loop,callback)
end

function CameraControl:IsPlaying()
	local camera = CameraControl:getCamera();
	if not camera then
		return
	end
	
	return camera.isPlay;
end










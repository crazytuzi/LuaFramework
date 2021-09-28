


local _M = {}
_M.__index = _M
local bit = require "bit"
local dramaGameObject
local V3 = UnityEngine.Vector3
local customOffset = V3.New(0,0,0)
local defaultOffset = V3.New(-0.1, 9, -9.5)

local cameraActionNode = '/MapNode/CameraMove'

function _M.HideSceneCamera(parent, var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	print('HideSceneCamera-------------------------------',var)
	if not r:HasAttribute('HideSceneCamera') and var then	
		env.HideSceneCamera(true)
		r:SetAttribute('HideSceneCamera',true)
	elseif not var then
		env.HideSceneCamera(false)
		r:SetAttribute('HideSceneCamera',nil)
	end
end

function _M.CameraRotate180(parent,var)
	GameSceneMgr.Instance.SceneCameraNode:Rotate180(var)
end

function _M.CameraRotate(parent,var)
	GameSceneMgr.Instance.SceneCameraNode:Rotate(var)
end

function _M.SetTelescope(parent, var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	if not r:HasAttribute('SetTelescope') and var then	
		env.SetTelescope(true)
		r:SetAttribute('SetTelescope',true)
	elseif not var then
		env.SetTelescope(false)
		r:SetAttribute('SetTelescope',nil)
	end
end


local function GetCameraPostion(x,y)
	local u3dPos = DramaHelper.GetU3DPosition(x,y)
	return (u3dPos + customOffset)
end

function _M.SetOffset(parent,x,y,h)
	customOffset = V3.New(x,h,y)
end

function _M.SetPosition(parent, x, y)
	if not dramaGameObject then return end
	local u3dPos = DramaHelper.GetU3DPosition(x,y)
	dramaGameObject.transform.position = u3dPos + customOffset
end

function _M.GetEulerAngles(parent)
	if not dramaGameObject then return end
	local angles = dramaGameObject.transform.localEulerAngles
	return angles.x,angles.y,angles.z
end

function _M.SetEulerAngles(parent, x,y,z)
	if not dramaGameObject then return end
	dramaGameObject.transform.localEulerAngles = Vector3.New(x,y,z)
end

function _M._asyncMoveToEulerAngles(self,x,y,z,speed)
	if not dramaGameObject then return end
	local v3 = Vector3.New(x,y,z)
	self:AddTimer(function (delta)
		local distance = speed * delta
		local nextPos = V3.MoveTowards(dramaGameObject.transform.localEulerAngles,v3,distance)
		if nextPos:Equals(dramaGameObject.transform.localEulerAngles) then
			self:Done()
		else
			dramaGameObject.transform.localEulerAngles = nextPos
		end
	end)
	self:Await()	
end

function _M.GetHeight(parent)
	if not dramaGameObject then return end
	return dramaGameObject.transform.position.y
end

function _M._asyncShakePosition(self,xyz,sec)
	if not dramaGameObject then return end
	DramaHelper.ShakeGameObjectPosition(dramaGameObject,{quakeXYZ=xyz,sec=sec})
	self:AddTimer(function (delta)
		self:Done()
	end,sec,true)
	self:Await()
end

function _M.SetHeight(parent, height)
	if not dramaGameObject then return end
	dramaGameObject.transform.position = V3.New(
		dramaGameObject.transform.position.x,
		height,dramaGameObject.transform.position.z)
end

function _M.SetDramaCamera(parent, enable)
	local mainCamera = GameSceneMgr.Instance.SceneCamera
	if not dramaGameObject then
		dramaGameObject = UnityEngine.GameObject.New()
		dramaGameObject.transform.rotation =  mainCamera.transform.rotation
		
		dramaGameObject:AddComponent(typeof(UnityEngine.AudioListener))
		local camera = dramaGameObject:AddComponent(typeof(Camera))
		
		camera.cullingMask = mainCamera.cullingMask
		camera.fieldOfView = mainCamera.fieldOfView
		camera.nearClipPlane = mainCamera.nearClipPlane
		camera.farClipPlane = mainCamera.farClipPlane
		camera.tag = 'MainCamera'
	end
	if enable then
		
		local pt = DataMgr.Instance.UserData.Position
		local u3dPos = DramaHelper.GetU3DPosition(pt.x,pt.y)
		local mainU3dPos = mainCamera.gameObject.transform.position
		defaultOffset = mainU3dPos - u3dPos
	end

	_M.HideSceneCamera(parent, enable)
	dramaGameObject:SetActive(enable)

	local r = parent:GetRootEvent()
	r:SetAttribute('DramaCamera',enable)
	DramaHelper.ResetSceneUICamera()
end

function _M.SetFOV(parent, fov)
	local camera = dramaGameObject:GetComponent(typeof(Camera))
	camera.fieldOfView = fov
	end


function _M._asyncMoveTo(self,x,y,speed)
	local target = GetCameraPostion(x,y)
	_M._asyncMoveToV3(self,target,speed)
end

function _M._asyncMoveToHeight(self,height,speed)
	local target = V3.New(dramaGameObject.transform.position.x,
												height,
												dramaGameObject.transform.position.z)
	_M._asyncMoveToV3(self,target,speed)
end

function _M._asyncMoveToV3(self,target,speed)
	if not dramaGameObject then return end
	self:AddTimer(function (delta)
		local distance = speed * delta
		local nextPos = V3.MoveTowards(dramaGameObject.transform.position,target,distance)
		if nextPos:Equals(dramaGameObject.transform.position) then
			self:Done()
		else
			dramaGameObject.transform.position = nextPos
		end
	end)
	self:Await()
end

function _M._asyncPlayAnimation(self, name, holdcamera)
	local obj = GameObject.Find(cameraActionNode)
	if not obj then
		return
	end
	local trans = obj.transform:Find(name)
	if not trans then
		return
	end

	local drama_enable = (dramaGameObject and dramaGameObject.activeSelf) or false

	
	_M.HideSceneCamera(self, true)
	
	if dramaGameObject then
		dramaGameObject:SetActive(false)
	end
	trans.gameObject:SetActive(true)

	local al = trans:GetComponentInChildren(typeof(UnityEngine.AudioListener))
	if al then
		al.enabled = false
	end
	local camera = trans.gameObject:GetComponent(typeof(Camera))
	if camera then
		camera.cullingMask = GameSceneMgr.Instance.SceneCamera.cullingMask
	end
	
	local r = self:GetRootEvent()

	local lastAnim = r:GetAttribute('PlayAnimation') or {}
	local needAdd = true
	for _,v in ipairs(lastAnim) do
		if v ~= trans.gameObject then
			v:SetActive(false)
		else
			needAdd = false
		end
	end
	if needAdd then
		table.insert(lastAnim,trans.gameObject)
	end
	r:SetAttribute('PlayAnimation',lastAnim)

	local animation = trans.gameObject:GetComponent(typeof(Animation))
	local t = DramaHelper.GetAnimationTime(animation,name)
	
	self:AddTimer(function (delta)	
		if not animation.isPlaying then
			trans.gameObject:SetActive(false)
			if not holdcamera then
				_M.HideSceneCamera(self, false)
			end
			if dramaGameObject then
				dramaGameObject:SetActive(drama_enable)
			end
			self:Done()
		end
	end)

	self:Await()
end

function _M.Clear(parent)
	local r = parent:GetRootEvent()
	local active = r:GetAttribute('DramaCamera')
	if active then
		UnityEngine.Object.DestroyObject(dramaGameObject)
		dramaGameObject = nil
	end
	
	local env = r:GetAttribute('__env')
	
	if r:HasAttribute('HideSceneCamera') then
		env.HideSceneCamera(false)
		DramaHelper.ResetSceneUICamera()
	end

	if r:HasAttribute('SetTelescope') then
		env.SetTelescope(false)
	end

	local lastAnim = r:GetAttribute('PlayAnimation')
	for _,v in ipairs(lastAnim or {}) do
		v:SetActive(false)
	end
	lastAnim = nil
end

return _M

Camera = Camera or BaseClass()

function Camera:__init()
	if Camera.Instance then
		print_error("[Camera] Attempt to create singleton twice!")
		return
	end
	Camera.Instance = self

	self.is_scene_change = false
	self.field_of_view_value = 0
	self.add_speed = 0

	self.old_transform_index = 0
end

function Camera:__delete()
	Camera.Instance = nil

	self:RemoveSceneCameraChange()
end

function Camera:GetCamerFollow()
	return MainCameraFollow
	-- if IsNil(MainCamera) then
	-- 	return nil
	-- end

	--return MainCamera:GetComponentInParent(typeof(CameraFollow))
end

function Camera:SetCameraTransformByName(name, speed)
	if CAMERA_TYPE == CameraType.Free then
		return
	end
	local camera_follow = self:GetCamerFollow()
	if nil ~= camera_follow then
		self.old_transform_index = camera_follow:GetCameraTransformIndex()
		if nil ~= speed then
			camera_follow:SetOverrideLerpSpeed(speed)
		end

		camera_follow:SetCameraTransformByName(name)
	end
end

function Camera:SetCameraTransform(transform_index, speed)
	if CAMERA_TYPE == CameraType.Free then
		return
	end
	local camera_follow = self:GetCamerFollow()
	if nil ~= camera_follow then
		self.old_transform_index = camera_follow:GetCameraTransformIndex()
		if nil ~= speed then
			camera_follow:SetOverrideLerpSpeed(speed)
		end

		camera_follow:SetCameraTransform(transform_index)
	end
end

function Camera:Reset(speed)
	if CAMERA_TYPE == CameraType.Free then
		return
	end
	local camera_follow = self:GetCamerFollow()
	if nil ~= camera_follow then
		if nil ~= speed then
			camera_follow:SetOverrideLerpSpeed(speed)
		end
		camera_follow:SetCameraTransform(self.old_transform_index)
	end
end

function Camera:Update(now_time, elapse_time)
	if self.is_scene_change then
		local camera_follow = self:GetCamerFollow()
		if nil ~= camera_follow then
			local temp_field_of_view = camera_follow.FieldOfView
			if temp_field_of_view <= self.field_of_view_value then
				camera_follow.FieldOfView = self.field_of_view_value
				self:RemoveSceneCameraChange()
			else
				camera_follow.FieldOfView = temp_field_of_view - (1 + self.add_speed)
				self.add_speed = self.add_speed + 0.2
			end
		else
			self:RemoveSceneCameraChange()
		end
	end
end

-- 场景摄像机切换的时候俯视效果
function Camera:SceneCameraChange()
	if not self.is_scene_change then
		local camera_follow = self:GetCamerFollow()
		if nil ~= camera_follow then
			Runner.Instance:AddRunObj(self, 6)

			self.field_of_view_value = camera_follow.FieldOfView
			-- camera_follow.FieldOfView = self.field_of_view_value + 50
			local mian_view = MainUICtrl.Instance:GetView()
			if mian_view then
				mian_view:SetSceneCameraEffect(true)
			end
			self.is_scene_change = true
		end
	end
end

function Camera:RemoveSceneCameraChange()
	Runner.Instance:RemoveRunObj(self)
	if MainUICtrl.Instance then
		local mian_view = MainUICtrl.Instance:GetView()
		if mian_view then
			mian_view:SetSceneCameraEffect(false)
		end
	end
	self.add_speed = 0
	self.is_scene_change = false
end
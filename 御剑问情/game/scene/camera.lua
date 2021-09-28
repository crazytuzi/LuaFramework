Camera = Camera or BaseClass()

function Camera:__init()
	if Camera.Instance then
		print_error("[Camera] Attempt to create singleton twice!")
		return
	end
	Camera.Instance = self

	self.old_transform_index = 0
end

function Camera:__delete()
	Camera.Instance = nil
end

function Camera:GetCamerFollow()
	return MainCameraFollow
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
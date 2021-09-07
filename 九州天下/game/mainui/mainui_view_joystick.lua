MainUIViewJoystick = MainUIViewJoystick or BaseClass(BaseRender)

function MainUIViewJoystick:__init()
	self.joystick_angle = 0
	self.joystick_last_target_pos = u3d.vec2(0, 0)
	self.is_touched = false

	self.touch_times = 0
	self.max_touch_interval = 0.1
	self.show_fight_mount_flag = false
	self.show_fight_mount = self:FindVariable("ShowFightMount")
	self.fight_mount_state = self:FindVariable("MountState")

	self.guide_mati = self:FindObj("GuideMaTi")
	self.mount_bg = self:FindObj("MountBg")
	self.mount_img = self:FindObj("MountImg")
	self.mount_bg.canvas_group.alpha = 0.5
	self.mount_img.canvas_group.alpha = 0.5

	self.joystick_finger_index = -1
	self.swipe_finger_index = -1
	self.is_drag = false
	self.can_drag_time = 0

	self.root_node.joystick:AddDragBeginListener(
		BindTool.Bind(self.OnJoystickBegin, self))
	self.root_node.joystick:AddDragUpdateListener(
		BindTool.Bind(self.OnJoystickUpdate, self))
	self.root_node.joystick:AddDragEndListener(
		BindTool.Bind(self.OnJoystickEnd, self))
	self.root_node.joystick:AddIsTouchedListener(
		BindTool.Bind(self.OnJoystickTouched, self))

	self.swipe_start_handle = BindTool.Bind(self.OnFingerSwipeStart, self)
	EasyTouch.On_SwipeStart = EasyTouch.On_SwipeStart + self.swipe_start_handle

	self.swipe_end_handle = BindTool.Bind(self.OnFingerSwipeEnd, self)
	EasyTouch.On_SwipeEnd = EasyTouch.On_SwipeEnd + self.swipe_end_handle

	self.swipe_handle = BindTool.Bind(self.OnFingerSwipe, self)
	EasyTouch.On_Swipe = EasyTouch.On_Swipe + self.swipe_handle

	self.pinch_handle = BindTool.Bind(self.OnFingerPinch, self)
	EasyTouch.On_Pinch = EasyTouch.On_Pinch + self.pinch_handle

	--功能引导监听
	self.getui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, self.getui_callback)
end
function MainUIViewJoystick:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.Main, self.getui_callback)
	end
	self.getui_callback = nil

	if self.swipe_start_handle ~= nil then
		EasyTouch.On_SwipeStart = EasyTouch.On_SwipeStart - self.swipe_start_handle
		self.swipe_start_handle = nil
	end

	if self.swipe_end_handle ~= nil then
		EasyTouch.On_SwipeEnd = EasyTouch.On_SwipeEnd - self.swipe_end_handle
		self.swipe_end_handle = nil
	end

	if self.swipe_handle ~= nil then
		EasyTouch.On_Swipe = EasyTouch.On_Swipe - self.swipe_handle
		self.swipe_handle = nil
	end

	if self.pinch_handle ~= nil then
		EasyTouch.On_Pinch = EasyTouch.On_Pinch - self.pinch_handle
		self.pinch_handle = nil
	end

	self:CancelQuest()
end
function MainUIViewJoystick:CheckShowMount()
	local value = self.show_fight_mount:GetBoolean()
	if value then
		return
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local used_imageid = MountData.Instance:GetUsedImageId()
	local is_open = OpenFunData.Instance:CheckIsHide("mount")
	self.show_fight_mount_flag = is_open or (nil ~= used_imageid and used_imageid > 0) or (nil ~= main_role_vo and nil ~= main_role_vo.mount_appeid and main_role_vo.mount_appeid > 0)
	self.show_fight_mount:SetValue(is_open or (nil ~= used_imageid and used_imageid > 0) or (nil ~= main_role_vo and nil ~= main_role_vo.mount_appeid and main_role_vo.mount_appeid > 0))
end
function MainUIViewJoystick:FlushMountState()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local mount_appeid = main_role_vo.mount_appeid
	self.fight_mount_state:SetValue(mount_appeid <= 0)
end

function MainUIViewJoystick:ClickMount()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local mount_appeid = main_role_vo.mount_appeid
	local multi_appeid = main_role_vo.multi_mount_res_id
	--local fight_mount_appeid = main_role_vo.fight_mount_appeid

	-- if mount_appeid > 0 then
	-- 	--先下坐骑
	-- 	MountCtrl.Instance:SendGoonMountReq(0)
	-- end
	local use_multi_mount = MultiMountData.Instance:GetCurUseMountId()
	if use_multi_mount > -1 then
		if multi_appeid and multi_appeid >= 0 then
			MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UNRIDE)
		else
			MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_RIDE)
		end
	else
		if mount_appeid > 0 then
			MountCtrl.Instance:SendGoonMountReq(0)
		else
			MountCtrl.Instance:SendGoonMountReq(1)
		end
	end
end
function MainUIViewJoystick:OnJoystickBegin()
	self.touch_times = Status.NowTime
end

-- 摇杆回调
function MainUIViewJoystick:OnJoystickUpdate(fx, fy)
	if nil == MainCamera or IsNil(MainCamera) then
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	if main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		main_role.move_oper_cache2 = nil
		return
	end

	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, true)

	if math.abs(fx) < 0.1 and math.abs(fy) < 0.1 then
		return
	end

	fx, fy = self:ActuallyMoveDir(fx, fy)
	local angle = math.atan2(fy, fx)
	main_role = Scene.Instance:GetMainRole()

	if main_role:GetMoveRemainDistance() <= 2 or math.abs(angle - self.joystick_angle) >= 0.26 then
		self.joystick_angle = angle
		local dir = u3d.v2Normalize(u3d.vec2(fx, fy))
		local x, y =  main_role:GetLogicPos()
		local target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + dir.x * 8, y + dir.y * 8)

		if target_x == x and target_y == y then
			local x_offset = fx >= 0 and 3 or -3
			local y_offset = fy >= 0 and 3 or -3

			if math.abs(fx) > math.abs(fy) then
				target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y)
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y + y_offset)
				end
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x, y + y_offset)
				end
			else
				target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x, y + y_offset)
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y + y_offset)
				end
				if target_x == x and target_y == y then
					target_x, target_y = AStarFindWay:GetLineEndXY(x, y, x + x_offset, y)
				end
			end
		end

		-- if self.joystick_last_target_pos.x ~= target_x or self.joystick_last_target_pos.y ~= target_y then
		-- 	if not main_role:IsJump() then
		-- 		local function func()
		-- 			GuajiCtrl.Instance:ClearAllOperate()
		-- 		end
		-- 		if main_role:DoMoveByClick(target_x, target_y, 0, func, false) ~= false then

		-- 			self.joystick_last_target_pos = u3d.vec2(target_x, target_y)
		-- 		end
		-- 	end
		-- end

		if self.joystick_last_target_pos.x ~= target_x or self.joystick_last_target_pos.y ~= target_y then
			if not main_role:IsJump() then
				if main_role:DoMoveByClick(target_x, target_y, 0) ~= false then
					self.joystick_last_target_pos = u3d.vec2(target_x, target_y)
				end
			end
		end

	end
end

function MainUIViewJoystick:OnJoystickEnd(fx, fy)
	if nil == MainCamera then
		return
	end
	if self.show_fight_mount_flag and Status.NowTime - self.touch_times <= self.max_touch_interval then
		self:ClickMount()
	end

	self.joystick_angle = -720
	self.joystick_last_target_pos = u3d.vec2(0, 0)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if not main_role:IsAtk() and not main_role:IsAtkPlaying() and not main_role:IsJump() then
		main_role:ChangeToCommonState()
	end
end

function MainUIViewJoystick:ActuallyMoveDir(fx, fy)
	if nil == MainCamera then
		return 0, 0
	end

	-- local quat = Quaternion()
	-- local screen_forward = Vector3(0, 0, 1)
	-- local screen_input = Vector3(fx, 0, fy)
	-- quat:SetFromToRotation(screen_forward, screen_input)
	-- quat.eulerAngles = Vector3(quat.eulerAngles.x, quat.eulerAngles.y, 0)
	-- local camera_forward = MainCamera.transform.forward
	-- camera_forward.y = 0

	-- local move_dir = quat * camera_forward
	-- return move_dir.x, move_dir.z

	if nil == self.quat then
		self.quat = Quaternion()
		self.screen_forward = Vector3(0, 0, 0)
		self.screen_input = Vector3(0, 0, 0)
		self.euler_angles = Vector3(0, 0, 0)
	end

	self.screen_forward.z = 1

	self.screen_input.x = fx
	self.screen_input.z = fy

	self.quat:SetFromToRotation(self.screen_forward, self.screen_input)

	self.euler_angles.x = self.quat.eulerAngles.x
	self.euler_angles.y = self.quat.eulerAngles.y
	self.quat.eulerAngles = self.euler_angles
	local camera_forward = MainCamera.transform.forward
	camera_forward.y = 0

	local move_dir = self.quat * camera_forward
	return move_dir.x, move_dir.z
end
function MainUIViewJoystick:OnFingerSwipeStart(gesture)
	if gesture.fingerIndex ~= self.joystick_finger_index and not self.is_drag then
		self.is_drag = true
		self.swipe_finger_index = gesture.fingerIndex
		self.can_drag_time = Status.NowTime + 0.1
	end
end
function MainUIViewJoystick:OnFingerSwipeEnd(gesture)
	if gesture.fingerIndex == self.swipe_finger_index then
		self.is_drag = false
		self.swipe_finger_index = -1
	end
end
function MainUIViewJoystick:OnFingerSwipe(gesture)
	if not self.is_drag or (self.is_touched and gesture.fingerIndex == self.joystick_finger_index) then
		return
	end
	if Status.NowTime >= self.can_drag_time and CAMERA_TYPE == CameraType.Free and not IsNil(MainCameraFollow) then
		MainCameraFollow:Swipe(gesture.swipeVector.x / 2, gesture.swipeVector.y / 2)
		self:CancelQuest()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function ()
			self:UpdateCameraSetting()
		end, 0.5)
	end
end
function MainUIViewJoystick:OnFingerPinch(gesture)
	if CAMERA_TYPE == CameraType.Free and not self.is_touched and not IsNil(MainCameraFollow) then
		self.can_drag_time = Status.NowTime + 0.1
		MainCameraFollow:Pinch(gesture.deltaPinch)
		self:CancelQuest()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function ()
			self:UpdateCameraSetting()
		end, 0.5)
	end
end
function MainUIViewJoystick:OnJoystickTouched(is_touched, finger_index)
	self.mount_bg.canvas_group.alpha = self.is_touched and 0.5 or 1
	self.mount_img.canvas_group.alpha = self.is_touched and 0.5 or 1

	self.joystick_finger_index = finger_index or -1
	self.is_touched = is_touched
end

function MainUIViewJoystick:CancelQuest()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end
-- 上传镜头参数
function MainUIViewJoystick:UpdateCameraSetting()
	if CAMERA_TYPE == CameraType.Free then
		if not IsNil(MainCameraFollow) and not IsNil(MainCamera) then
			local angle = MainCamera.transform.parent.transform.localEulerAngles
			SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_ROTATION_X, angle.x)
			SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_X, angle.x)
			SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_ROTATION_Y, angle.y)
			SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_Y, angle.y)

			local distance = MainCameraFollow.Distance
			SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_DISTANCE, distance)
			SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_DISTANCE, distance)
		end
	end
end
function MainUIViewJoystick:GetUiCallBack(ui_name, ui_param)
	if ui_name == GuideUIName.MainUIGuideMati then
		if self[ui_name] and self[ui_name].gameObject.activeInHierarchy then
			local function callback()
				self:ClickMount()
			end
			return self[ui_name], callback
		end
	end
end
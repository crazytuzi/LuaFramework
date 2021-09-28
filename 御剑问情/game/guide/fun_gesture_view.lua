
--------------------------------------------------
--功能手势引导视图
--------------------------------------------------
FunGestureView = FunGestureView or BaseClass(BaseView)
function FunGestureView:__init()
	self.ui_config = {"uis/views/guideview_prefab","GestureGuideView"}

	self.view_layer = UiLayer.Guide
	self.begin_pos = nil
	self.begin_time = 0
	self.gesture_dir = 0
	self.gesture_callback = nil
end

function FunGestureView:__delete()

end

function FunGestureView:ReleaseCallBack()
	self.gesture_area = nil
	if self.finger_handle ~= nil then
		EasyTouch.On_SwipeEnd = EasyTouch.On_SwipeEnd - self.finger_handle
		self.finger_handle = nil
	end
	self.begin_pos = false
	self.begin_time = false
	self.gesture_callback = nil
end

function FunGestureView:LoadCallBack()
	self:ListenEvent("TouchBegin",BindTool.Bind(self.TouchBegin, self))
	self:ListenEvent("TouchEnd",BindTool.Bind(self.TouchEnd, self))
end

function FunGestureView:SetGestureCallBack(gesture_dir, gesture_callback)
	self.gesture_dir = gesture_dir
	self.gesture_callback = gesture_callback
end

function FunGestureView:ShowIndexCallBack()

end

function FunGestureView:TouchBegin()
	self.begin_pos = UnityEngine.Input.mousePosition
	self.begin_time = Status.NowTime
end

function FunGestureView:TouchEnd()
	if self.begin_pos then
		local end_pos = UnityEngine.Input.mousePosition
		self:OnFingerSwipe(end_pos.x - self.begin_pos.x, end_pos.y - self.begin_pos.y, Status.NowTime - self.begin_time)
	end
	self.begin_pos = nil
end

function FunGestureView:OnFingerSwipe(off_x, off_y, time)
	local dir_number = GameMath.GetDirectionNumber(off_x, off_y)
	-- if self.gesture_dir ~= dir_number then
	-- 	return
	-- end
	if dir_number == GameMath.DirUp then
		if off_y > 50 and off_y / time > 500 then
			MountCtrl.Instance:SendGoonMountReq(1)
			self:Close()
			if self.gesture_callback ~= nil then
				self.gesture_callback()
			end
		end
	end
end

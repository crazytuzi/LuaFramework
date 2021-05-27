----------------------------------------------------
-- 摇杆
----------------------------------------------------
MainuiJoystick = MainuiJoystick or BaseClass()

function MainuiJoystick:__init()
	self.mt_layout_root = nil
	self.joystick = nil
end

function MainuiJoystick:__delete()
end

function MainuiJoystick:Init(mt_layout_root)
	self.mt_layout_root = mt_layout_root

	-- 摇杆
	self.joystick = AnyJoystick.New()
	self.joystick:Create(ResPath.GetMainui("joystick_bg"), ResPath.GetMainui("joystick_ball"))
	self.joystick:GetView():setPosition(150, 125)
	self.joystick:SetCallback(BindTool.Bind(self.OnJoystickCallback, self))
	self.mt_layout_root:TextureLayout():addChild(self.joystick:GetView(), 1)
end

----------------------------------------------------
--摇扛控制
----------------------------------------------------
-- 摇杆回调，event_type：0开始，1按住，2结束
function MainuiJoystick:OnJoystickCallback(event_type, fx, fy)
	local main_role = Scene.Instance:GetMainRole()
	if 2 == event_type then
		GuajiCtrl.Instance:SetPlayerOptState(false)
		main_role:StopMove()
		return
	end

	if math.abs(fx) < 0.1 and math.abs(fy) < 0.1 then
		GuajiCtrl.Instance:SetPlayerOptState(false)
		return
	end

	if nil ~= MapLoading.Instance and MapLoading.Instance:IsOpen() then
		GuajiCtrl.Instance:SetPlayerOptState(false)
		return
	end

	local dir = GameMath.GetDirectionNumber(fx, fy)
	if math.abs(fx) <= 40 and math.abs(fy) <= 40 then
		main_role:DoMoveByDir(dir, 1)
	else
		main_role:DoMoveByDir(dir, 2)
	end

	GuajiCtrl.Instance:SetPlayerOptState(true)
end

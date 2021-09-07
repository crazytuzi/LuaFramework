-- 锁屏
UnlockView = UnlockView or BaseClass(BaseView)

local UnityApplication = UnityEngine.Application
local UnityRuntimePlatform = UnityEngine.RuntimePlatform

function UnlockView:__init()
	self.view_layer = UiLayer.Standby
	self.ui_config = {"uis/views/settingview","LuckScreenView"}
	self:SetMaskBg()
end

function UnlockView:LoadCallBack()
	self.slider = self:FindObj("Slider"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.show_imge = self:FindObj("ShowImage")
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnSliderChange",
		BindTool.Bind(self.OnSliderChange, self))
	self:ListenEvent("TouchUpEvent",
		BindTool.Bind(self.TouchUpEvent, self))
	self:ListenEvent("TouchDownEvent",
		BindTool.Bind(self.TouchDownEvent, self))
	self.slider_value = 0
	self.slider.value = 0
end

function UnlockView:ReleaseCallBack()
	-- 清理变量和对象
	self.slider = nil
	self.show_imge = nil
end

function UnlockView:OpenCallBack()
	self.slider_value = 0
	SettingCtrl.Instance:RemoveTimer()
	local main_fight_state = MainUICtrl.Instance:GetFightToggleState()
	SettingData.Instance:SetFightToggleState(not main_fight_state)
	if not main_fight_state then
		GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
	end

	-- 打开锁屏的时候手机帧频降到15
	local platform = UnityApplication.platform
	if platform == UnityRuntimePlatform.IPhonePlayer or platform == UnityRuntimePlatform.Android then
		UnityApplication.targetFrameRate = 15
	end

	-- 貌似有问题 会报错，暂时不用
	-- if platform == UnityRuntimePlatform.Android then
	-- 	-- Brightness的有效范围是0~1，-1。 若设置为-1则跟随系统亮度。本段代码没有设置有效范围检测。
	-- 	ApplicationBrightness.SetApplicationBrightnessTo(0.2)
	-- end
end

function UnlockView:CloseCallBack()
	self.slider_value = 0
	if self.slider ~= nil then
		self.slider.value = 0
	end
	if SettingData.Instance:GetNeedLuckView() then
		SettingCtrl.Instance:AddTimer()
	end

	-- 取消锁屏的时候手机帧频恢复到30
	local platform = UnityApplication.platform
	if platform == UnityRuntimePlatform.IPhonePlayer or platform == UnityRuntimePlatform.Android then
		UnityApplication.targetFrameRate = 30
	end

	-- 貌似有问题 会报错，暂时不用
	-- if platform == UnityRuntimePlatform.Android then
	-- 	-- 设置为-1则跟随系统亮度
	-- 	ApplicationBrightness.SetApplicationBrightnessTo(-1)
	-- end
end

function UnlockView:CloseWindow()
	self:Close()
end

function UnlockView:TouchUpEvent()
	self.slider:DOValue(0, 0.1, false)
end

function UnlockView:TouchDownEvent()
end

function UnlockView:OnSliderChange(value)
	self.slider_value = value
	self.show_imge.image.color = Color.New(1, 1, 1, 1 - value)
	if value == 1 then
		local screen_bright = SettingData.Instance:GetScreenBright()
		if screen_bright > 0 then
			DeviceTool.SetScreenBrightness(screen_bright)
		end
		local fight_toggle_state = SettingData.Instance:GetFightToggleState()
		if fight_toggle_state then
			GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
		end
		self:Close()
	end
end

function UnlockView:OnFlush()
end
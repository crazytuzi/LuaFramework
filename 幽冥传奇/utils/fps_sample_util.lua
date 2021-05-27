------------------------------------------------------
--帧频采样工具,在处于低频时将对发警告级别
--@author bzw
------------------------------------------------------

FpsSampleUtil = FpsSampleUtil or BaseClass()
function FpsSampleUtil:__init()
	if FpsSampleUtil.Instance ~= nil then
		Error("FpsSampleUtil has been created.")
	end
	FpsSampleUtil.Instance = self

	self.frames = 0									-- 帧数
	self.elapse_time = 0							-- 时间
	self.fps = 0									-- 帧率

	self.long_frames = 0							-- 帧数
	self.long_elapse_time = 0						-- 时间
	self.long_fps = 0								-- 帧率(采样时间长)
	self.fps_smaple_time = 5 						-- 采样总时间

	self.is_open_fps_sample = true 					-- 是否开启帧频采样功能(通过此值开启或关闭采样功能)
	self.sample_invalid = false 					-- 采样是否有效
	self.fps_callback = nil

	self.test_fps = 0

	Runner.Instance:AddRunObj(self, 1)
end

function FpsSampleUtil:__delete()
	FpsSampleUtil.Instance = nil
	Runner.Instance:RemoveRunObj(self)
end

function FpsSampleUtil:SetFpsCallback(fps_callback)
	self.fps_callback = fps_callback
end

function FpsSampleUtil:Update(now_time, elapse_time)
	self.frames = self.frames + 1
	self.elapse_time = self.elapse_time + elapse_time
	if self.elapse_time > 0.1 then
		self.fps = self.frames / self.elapse_time
		self.frames = 0
		self.elapse_time = 0
	end

	if self.is_open_fps_sample then
		self.long_frames = self.long_frames + 1
		self.long_elapse_time = self.long_elapse_time + elapse_time
		if self.long_elapse_time > self.fps_smaple_time then
			self.long_fps = self.long_frames / self.long_elapse_time
			self.long_frames = 0
			self.long_elapse_time = 0

			if self.sample_invalid then
				self:FpsNotify()
			end
		end
	end
end

--获得当前帧频
function FpsSampleUtil:GetFps()
	return self.fps
end

--获得当前帧频
function FpsSampleUtil:GetLongFps()
	return self.long_fps
end

--设置帧频采样开放
function FpsSampleUtil:SetFpsSampleInvalid(invalid)
	self.sample_invalid = invalid
end

function FpsSampleUtil:FpsNotify()
	if self.fps_callback ~= nil then
		if 0 ~= self.test_fps then
			self.fps_callback(self.test_fps)
		else
			self.fps_callback(self.long_fps)
		end
	end
end

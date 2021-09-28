TimeScaleService = TimeScaleService or BaseClass()

function TimeScaleService:__init()
	if TimeScaleService.Instance ~= nil then
		print_error("TimeScaleService to create singleton twice!")
	end
	TimeScaleService.Instance = self
end

function TimeScaleService:__delete()
	TimeScaleService.Instance = nil
end

function TimeScaleService:SetTimeScale(time_scale, duration, complete_call_back, ease)
	if complete_call_back then
		complete_call_back()
	end
	-- TimeScaleManager.Instance:SetTimeScale(time_scale, duration, complete_call_back, ease)
end

function TimeScaleService:StopTimeScale()
	TimeScaleManager.Instance:StopTimeScale()
end

function TimeScaleService:GetTimeScale()
	return TimeScaleManager.Instance.TimeScale
end

function TimeScaleService.StartTimeScale(call_back, time_scale, duration, ease)
	-- time_scale = time_scale or COMMON_CONSTS.TIME_SCALE
	-- duration = duration or COMMON_CONSTS.TIME_SCALE_DURATION
	-- ease = ease or DG.Tweening.Ease.InCirc
	-- local cfg = Scene.Instance:GetCurFbSceneCfg()
	-- if cfg then
	-- 	if cfg.slow_camera and cfg.slow_camera == 1 then
	-- 		TimeScaleService.Instance:SetTimeScale(COMMON_CONSTS.TIME_SCALE, COMMON_CONSTS.TIME_SCALE_DURATION, call_back, ease)
	-- 		return
	-- 	end
	-- end
	if call_back then
		call_back()
	end
end
-- （程序）全局 事件 [单例]
AppEvent = BaseClass(InnerEvent)
function AppEvent:__init()
	AppEvent.inst = self
end

-- 单例唯一接口
function AppEvent:GetInstance()
	if AppEvent.inst == nil then
		AppEvent.New()
	end
	return AppEvent.inst
end
function AppEvent:__delete()
	AppEvent.inst = nil
end

--[[渲染器（帧频/定时器）
	作用：将注册添加进来的接口进行 定时或帧频执行， 执行可以设定指定存活时间与间隔时间
	@param interval 为时间间隔
	@param livingTime 为存在时间
	@param exec 渲染接口
	@param key 为标识，注：在Add之前如果不指定key（nil）则会默认创建一个key并返回

	注：所有 注入接口都会返回相应的标识符用来获取或移除相关渲染的执行器
]]
RenderMgr = {}
local this = RenderMgr

function RenderMgr.Init()
	this.map = {}
	this.timeMap = {}
	
	this.intervalMap = {}
	this.cacheTimeMap = {}
	this.endTimeCallbackMap = {}
	this.isPause = false -- 只控制当前线程的更新
	this.isStop = true -- 只控制当前线程的更新

	this.frameMap = {} -- 帧频定时器
	this.coTimerMap = {} -- 协程定时器

end

function RenderMgr.Start()
	if this.isStop then
		this.isStop = false
		UpdateBeat:Add(this.Update, this)

	end
	if this.isPause then
		this.isPause = false
	end
	
end
-- endTimeCallback 必需在livingtime有设置时，就是定时结束后才回调
function RenderMgr.Add(exec, key, livingTime, endTimeCallback, param)
	if this.timeMap[key] then
		this.Realse(key)
	end
	if key == nil then
		key = exec
	end
	if livingTime and livingTime > 0 then
		this.timeMap[key] = livingTime
		if endTimeCallback then
			this.endTimeCallbackMap[key] = {endTimeCallback, param}
		end
	end
	this.map[key] = exec
	return key
end
function RenderMgr.AddInterval(exec, key, intervalTime, livingTime, endTimeCallback, param)
	key = this.Add(exec, key, livingTime, endTimeCallback, param)
	if intervalTime and intervalTime > 0 then
		if intervalTime < 0.1 then intervalTime = 0.1 end
		this.intervalMap[key] = intervalTime
		this.cacheTimeMap[key] = 0
	else
		key = RenderMgr.DoNextFrame(exec)
	end
	return key
end
function RenderMgr.SetInterval( key, v )
	if this.intervalMap[key] then
		this.intervalMap[key] = math.max(0.1, v)
	end
end

function RenderMgr.DoNextFrame(exec, id)
	return RenderMgr.AddInterval(exec, id, 0.00001, 0.00001)
end

function RenderMgr.Delay(callback, delay, key)
	return RenderMgr.AddInterval(function () callback() end, key, delay, delay)
end


function RenderMgr.Remove(key)
	if key then
		if this.map[key] ~= nil then
			if this.intervalMap[key] then
				if this.cacheTimeMap[key] ~= 0 and this.map[key] then
					this.map[key]()
				end
				this.intervalMap[key] = nil
				this.cacheTimeMap[key] = nil
			end
			if this.timeMap[key] then
				if this.endTimeCallbackMap[key] then
					this.endTimeCallbackMap[key][1](this.endTimeCallbackMap[key][2])
					this.endTimeCallbackMap[key] = nil
				end
				this.timeMap[key] = nil
			end
			this.map[key] = nil
		elseif this.frameMap[key] ~= nil then
			this.frameMap[key]:Stop()
			this.frameMap[key]=nil
		elseif this.coTimerMap[key] ~= nil then
			this.coTimerMap[key]:Stop()
			this.coTimerMap[key]=nil
		end
	end
end
function RenderMgr.Realse(key)
	if key then
		if this.map[key] ~= nil then
			this.intervalMap[key] = nil
			this.cacheTimeMap[key] = nil
			this.endTimeCallbackMap[key] = nil
			this.timeMap[key] = nil
			this.map[key] = nil
		elseif this.frameMap[key] ~= nil then
			this.frameMap[key]:Stop()
			this.frameMap[key]=nil
		elseif this.coTimerMap[key] ~= nil then
			this.coTimerMap[key]:Stop()
			this.coTimerMap[key]=nil
		end
	end
end

function RenderMgr.Update()
	if this.isPause or this.isStop then return end
	for key, exec in pairs(this.map) do
		if exec then
			local t = this.cacheTimeMap[key]
			if t then
				if t >= this.intervalMap[key] then
					this.cacheTimeMap[key] = t - this.intervalMap[key]
					exec()
				else
					this.cacheTimeMap[key] = t + Time.deltaTime
				end
			else
				exec()
			end
			t = this.timeMap[key]
			if t and t > 0 then
				t = t - Time.deltaTime
				this.timeMap[key] = t
				if t <= 0 then
					this.Remove(key)
				end
			end
		end
	end
end

function RenderMgr.Pause()
	this.isPause = true
end

function RenderMgr.Stop()
	this.isStop = true
	UpdateBeat:Remove(this.Update, this)
end

function RenderMgr.Reset()
	if not this.isStop then
		UpdateBeat:Remove(this.Update, this)
	end
	for key, _ in pairs(this.map) do
		this.Remove(key)
	end
	this.Init()
end

-- loop <0 循环, >=0 不循环; count 每调用一次所用帧数
function RenderMgr.CreateFrameRender(func, count, loop, key)
	if not func then return end
	if this.frameMap[key] then
		this.frameMap[key]:Stop()
	end
	local f = FrameTimer.New(func, count or 1, loop or -1)
	f:Start()
	key = key or func
	this.frameMap[key]=f
end
-- loop <0 循环, >=0 不循环; interval 时间间隔
function RenderMgr.CreateCoTimer(func, interval, loop, key)
	if not func then return end
	if this.coTimerMap[key] ~= nil then
		this.coTimerMap[key]:Stop()
	end
	local t = CoTimer.New(func, interval or 0.0001, loop or -1)
	t:Start()
	key = key or func
	this.coTimerMap[key]=t
end
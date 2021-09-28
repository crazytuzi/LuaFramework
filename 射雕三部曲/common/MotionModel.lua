--[[
-- 文件名：MotionModel.lua
-- 描述：运动模型
-- 创建人：杨科
-- 创建时间：2015.05.28
--]]

local MotionModel = class("MotionModel", {})

local math_pow = math.pow
local math_sqrt = math.sqrt
local function pow2(x)
    return math_pow(x, 2)
end

--[[
params:
{
    [start_speed] = 0,  -- 初速度
    [speed] = 0,        -- 期望速度
    [distance] = 0,     -- 位移
    [acceleration] = 0, -- 加速度
}
--]]
function MotionModel:ctor(params)
    self._config = self:loadConfig(params)
end

function MotionModel:loadConfig(input)
    input = input or {}

    self._cur_speed    = input.start_speed or 0
    self._ajust_speed  = input.speed or 0
    self._acceleration = input.acceleration or 0

    self._distance = 0          -- 距离
    self._ajust_speed_time = 0  -- 调速需要时间
    self._ajust_speed_done_callback = nil
end

-- get distance
function MotionModel:get_distance()
    return self._distance
end

-- set distance
function MotionModel:set_distance(s)
    self._distance = s
end

-- get speed
function MotionModel:get_speed()
    return self._cur_speed
end

-- set speed
function MotionModel:set_speed(v)
    self._cur_speed    = v
    self._ajust_speed  = v
    self._acceleration = 0

    self._ajust_speed_time = 0  -- 调速需要时间
    self._ajust_speed_done_callback = nil
end

-- 调整速度到V, a:加速度
function MotionModel:ajust_speed(V, a, callback)
    local cur_speed = self._cur_speed
    if V == cur_speed then
        return
    elseif V > cur_speed then
        acceleration = math.abs(a)
    else--if V < cur_speed then
        acceleration = -math.abs(a)
    end
    self._acceleration = acceleration
    self._ajust_speed_done_callback = callback
    -- 期望速度
    self._ajust_speed = V
    -- 调速需要消耗时间
    self._ajust_speed_time = (V - cur_speed) / a
end

-- 计算以a为加速度调整速度到V产生的位移
function MotionModel:try_ajust_speed(V, a)
    local cur_speed = self._cur_speed
    if V == cur_speed then
        return 0
    elseif V > cur_speed then
        acceleration = math.abs(a)
    else--if V < cur_speed then
        acceleration = -math.abs(a)
    end

    return (pow2(V) - pow2(cur_speed)) / (2*acceleration)
end

-- 计算位移为S,调整到速度V需要的加速度
function MotionModel:try_stop_at(S, V)
    return (pow2(V) - pow2(self._cur_speed)) / (2*S)
end

-- 通过delta时间 计算:运行距离、当前速度
function MotionModel:time_passed(delta)
    local cur_speed        = self._cur_speed
    local acceleration     = self._acceleration
    local ajust_speed_time = self._ajust_speed_time

    local uniform_motion_time = 0
    if ajust_speed_time >= 0 and ajust_speed_time < delta then
        -- 匀速运动时间
        uniform_motion_time = delta - ajust_speed_time
        -- 加速运动时间
        delta = ajust_speed_time
    end

    -- 匀加速运动
    if delta > 0 then
        local _s = (cur_speed * delta) + (0.5 * acceleration * delta * delta)
        self._distance = self._distance + _s

        self._cur_speed = cur_speed + (acceleration * delta)
    end

    -- 匀速运动
    if uniform_motion_time > 0 then
        local _s = self._ajust_speed * uniform_motion_time
        self._distance = self._distance + _s
    end

    if ajust_speed_time == 0 then
        return
    else
        ajust_speed_time = ajust_speed_time - delta
        self._ajust_speed_time = ajust_speed_time
        if ajust_speed_time <= 0 then
            self:ajust_speed_done()
        end
    end
end

-- 调整速度结束
function MotionModel:ajust_speed_done()
    self._cur_speed = self._ajust_speed
    self._acceleration = 0
    self._ajust_speed_time = 0

    if self._ajust_speed_done_callback then
        local func = self._ajust_speed_done_callback
        self._ajust_speed_done_callback = nil
        func(self._cur_speed)
    end
end

return MotionModel

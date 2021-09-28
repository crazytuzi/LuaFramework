--[[
    文件名：MqMath.lua
	描述：摩奇卡卡数学扩展函数
	创建人：liaoyuangang
	创建时间：2016.4.29
-- ]]


MqMath = {}

-- 四舍五入到小数点后n位
function MqMath.showDecimal(value, n)
    local pow = math.pow(10, n)
    local powValue = value * pow
    local floor = math.floor(powValue)
    local decimal = powValue - floor
    if (decimal >= 0.5) then
        floor = floor + 1
    end

    return floor/pow
end

-- 定义随机数产生的范围
_RANDOM_RANGE_  = 100000000
math.randomseed(tostring(os.time()):reverse():sub(1, 6))

-- 随机生成
function MqMath.random(param)
    local rang = _RANDOM_RANGE_
    if param then
        rang = param
    end
    return math.random(1, rang)
end

-- mod扩展，需要用在特殊环境
--[[
    举例：地图有10个格子循环，那玩家走到第10、20、30这些整数步的时候需要取得第10个格子的位置，单纯取模会得到0不符合结果
    (1, 10)     返回 1
    (10, 10)    返回 10
    (15, 10)    返回 5
    (20, 10)    返回 10
--]]
function MqMath.modEx(a, b)
    -- local ret = math.mod(a, b)
    -- if (ret == 0) then
    --     ret = b
    -- end
    -- return ret
    return math.mod(a-1, b) + 1
end
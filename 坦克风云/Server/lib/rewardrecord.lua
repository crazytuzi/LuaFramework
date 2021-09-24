--
-- 记录和获取抽奖记录
-- User: luoning
-- Date: 15-1-19
-- Time: 上午11:02
--

--
--记录抽奖记录
--
--param string or table reward
--param string recordName
--param int expiretime 记录过期时间
--param int limitNum 记录的保留条数 nil 不限制记录条数
--param boolean flag 是否需要分解为单条数据
--
--return boolean
function setSrewardRecord(reward, recordName, expiretime, limitNum, flag)

    if type(reward) ~= "table" then
        return false
    end
    recordName = "recordreward-"..recordName
    local redisKey = getActiveCacheKey(recordName, "def", expiretime)
    local redis = getRedis()
    redis:multi()
    if not flag then
        redis:lpush(redisKey, json.encode(reward))
    else
        for _,areward in pairs(reward) do
            redis:lpush(redisKey, json.encode(areward))
        end
    end
    if type(limitNum) == "number" then
        redis:ltrim(redisKey,0, limitNum - 1)
    end
    redis:expireat(redisKey, expiretime)
    redis:exec()
    return true
end

--获取抽奖记录
function getSrewardRecord(recordName, expiretime, num)

    recordName = "recordreward-"..recordName
    local redisKey = getActiveCacheKey(recordName, "def", expiretime)
    local redis = getRedis()
    if not num then
        num = 10
    end
    local res = redis:lrange(redisKey, 0, num - 1)
    if type(res) == "table" and next(res) then
        for i,v in pairs(res) do
            res[i] = json.decode(v) or v
        end
    end

    return type(res) == 'table' and res or {}
end


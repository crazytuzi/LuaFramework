--
-- 存放user的每日活动信息
-- User: luoning
-- Date: 15-1-23
-- Time: 上午10:54
--

--param int uid 用户uid
--param string name 功能名称
--
--return boolean or table

function model_userextinfo(uid, name, username)

    local sha1 = require "lib.sha1"
    local dbName = "userextinfo"

    if not username then
        username = ""
    end

    local self = {
        --初始数据
        initAtt = {
            id = sha1(name..uid),
            uid = uid,
            name = name,
            username = username,
            info = {},
            weelts = 0,
            score = 0,
            st = 0,
            et = 0,
            rank = 0, --名次
            type = 1, --1--每日活动，2--时限活动
            updated_at = 0
        },
        --新数据
        orginAtt= {},
        --修改后的数据
        newAtt={},
    }
    self.redisKey = dbName.."-"..self.initAtt.id.."-"..uid.."-"..name
    self.r_expireTime = 600

    --获取数据库数据
    self.getRow = function()

        local db = getDbo()
        local result = db:getRow("select * from "..dbName.." where id = :id",{id=self.initAtt.id})
        if type(result) ~= "table" then
            result = {}
        end
        for i,v in pairs(result) do
            result[i] = tonumber(v) or v
            result[i] = json.decode(v) or v
        end
        if not result.id then
            local flag = true
            local jishu = 1
            while flag do
                local rt = db:insert(dbName, self.initAtt)
                if rt then
                    flag = true
                end
                if jishu >= 4 then
                    return false
                end
                jishu = jishu + 1
            end
        end
        return result
    end

    --缓存数据
    self.cacheData = function()

        local redis = getRedis()
        redis:hset(self.redisKey, self.initAtt.name, json.encode(self.newAtt))
        local expireTime = redis:ttl(self.redisKey)
        --写入失败
        if expireTime == -2 then
            local flag = true
            local jishu = 1
            while flag do
                redis:hset(self.redisKey, self.initAtt.name, json.encode(self.newAtt))
                local expireTime = redis:ttl(self.redisKey)
                if expireTime ~= -2 then
                    flag = false
                end
                if jishu >= 4 then
                    return false
                end
                jishu = jishu + 1
            end
        end
        --设置过期时间
        if expireTime <= 0 then
            redis:expire(self.redisKey, self.r_expireTime)
        end
    end

    --取缓存
    self.getCacheData = function()

        local redis = getRedis()
        local info = redis:hget(self.redisKey, name)
        info = json.decode(info) or {}
        return info
    end

    --初始化数据
    self.init = function()

        local result = self.getCacheData()
        if not next(result) then
            result = self.getRow()
        end
        if not result then
            return false
        end
        for k,v in pairs(self.initAtt) do
            if result[k] then
                v = result[k]
            end
            self.orginAtt[k] = v
        end
        self.newAtt = copyTable(self.orginAtt)
        self.cacheData()
        return true
    end

    self.diff = function(t1, t2)
        local type = type
        local pairs = pairs

        if t1 == t2 then return false; end
        if type(t1) ~= 'table' or type(t2) ~= 'table' then return true; end

        for k, v in pairs(t1) do
            if type(v) == 'table' then
                if self.diff(v,t2[k]) then return true; end
            else
                if v ~= t2[k] then return true; end
            end
        end

        for k, v in pairs(t2) do
            if type(v) == 'table' then
                if self.diff(v,t1[k]) then return true; end
            else
                if v ~= t1[k] then return true; end
            end
        end

        return false
    end

    self.update = function()

        local db = getDbo()
        if not self.diff(self.newAtt, self.orginAtt) then
            return true
        end
        self.newAtt.updated_at = os.time()
        local ret = db:update(dbName, self.newAtt, "id='"..self.initAtt.id.."' and updated_at<="..self.newAtt.updated_at)
        if ret==nil or ret < 1 then
            writeLog('****userextinfo save to db failed\n' .. (ret or 0) .. (db:getError() or '') .. (db:getQueryString() or ''))
            return false
        end
        self.cacheData()
        return true
    end

    self.save = function()
        return self.update()
    end

    if not self.init() then
        return false
    end

    return self
end


--
-- 军团异星科技赠送
-- User: luoning
-- Date: 15-2-9
-- Time: 上午10:18
--
function model_alliancememgift(uid,data)
    local self = {
        uid=uid,
        give={},
        receive={},
        reftime=0,
        updated_at=0,
    }



    local meta = {
        __index = function(tb, key)
            return rawget(tb,tostring(key)) or rawget(tb,'f'..key) or 0
        end
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end

    --礼物数据三点刷新
    function self.refresh()

        local reTime = getConfig("alienTechCfg.giftRefreshTime")
        local refreshTime = getWeeTs() + reTime * 3600
        if self.reftime < refreshTime then
            self.reftime = refreshTime
            self.give = {}
            self.receive = {}
        end
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then
                if format then
                    -- if type(v) == 'table'  then
                    --     if next(v) then data[k] = v end
                    -- elseif v ~= 0 and v~= '0' and v~='' then
                    data[k] = v
                    --end
                else
                    data[k] = v
                end
            end
        end

        return data
    end

    --礼包缓存key
    function self.generalGiftKeys(tmpUid)
        local reTime = getConfig("alienTechCfg.giftRefreshTime")
        local diffTime = reTime * 3600
        local weelTs = getWeeTs()
        local clientTs = getClientTs()
        local tmpTimeKey = getWeeTs() + diffTime
        if clientTs - weelTs < diffTime then
            tmpTimeKey = getWeeTs(clientTs - 86400) + diffTime
        end
        return getActiveCacheKey("alliancemember.gift", tmpUid, tmpTimeKey)
    end

    --检查是否可以赠送礼物
    function self.canGiveGift(gUids)
        for _,v in pairs(gUids) do
            if table.contains(self.give, v) then
                return false
            end
        end
        return true
    end

    --检查是否可以领取礼包
    function self.canGetGift(gUids, giftList, limit)

        if not next(giftList) or #self.receive >= limit then
            return false
        end

        for _,v in pairs(gUids) do
            if table.contains(self.receive, v) then
                return false
            end
        end

        local tmpUids = {}
        for _,v in pairs(giftList) do
            if table.contains(gUids, v[1]) then
                table.insert(tmpUids, v[1])
            end
        end

        for _,v in pairs(gUids) do
            if not table.contains(tmpUids, v) then
                return false
            end
        end

        return true
    end

    --赠送礼物
    function self.giveGift(gUids)

        for _,v in pairs(gUids) do
            table.insert(self.give, v)
        end
        return self.cacheGiftData(gUids)
    end

    --缓存礼包数据
    function self.cacheGiftData(gUids)

        local redis = getRedis()
        local ts = getClientTs()
        local expireTime = getWeeTs() + 10800 + 86400 - ts
        redis:multi()
        for _,v in pairs(gUids) do
            local tmpKeys = self.generalGiftKeys(v)
            redis:lpush(tmpKeys, json.encode({self.uid, ts}))
            redis:expire(tmpKeys, expireTime)
        end
        redis:exec()

        local uobjs = getUserObjs( tonumber(self.uid ) )
        local mUserinfo = uobjs.getModel('userinfo')

        for _,v in pairs(gUids) do
            regSendMsg(v,'alient.givegift.push',{self.uid, mUserinfo.nickname, mUserinfo.level})
        end
    end

    --记录接收的礼物uid
    function self.recordGift(gUids)

        for _,v in pairs(gUids) do
            table.insert(self.receive, v)
        end
    end

    --礼物列表
    function self.getGiftList()

        local redis = getRedis()
        local redisKey = self.generalGiftKeys(self.uid)
        local res = redis:lrange(redisKey, 0, -1)
        if type(res) == "table"  then
            for i,v in pairs(res) do
                res[i] = json.decode(v)

                -- 返回名字和等级
                if res[i] and tonumber(res[i][1]) then
                    local uobjs = getUserObjs( tonumber(res[i][1]) )
                    local mUserinfo = uobjs.getModel('userinfo')
                    res[i][3] = mUserinfo.nickname
                    res[i][4] = mUserinfo.level
                end

            end
        end
        return type(res) == "table" and res or {}
    end

    --礼包id
    function self.getValidReceiveUids(validUids, limit)

        local tmpUids = {}
        local tmpNum = #self.receive
        for _,v in pairs(validUids) do
            tmpNum = tmpNum + 1
            if table.contains(self.receive, v[1]) and tmpNum <= limit then
                table.insert(tmpUids, v[1])
            end
        end
        return tmpUids
    end

    --可以赠送的uids列表
    function self.getValidGiveUids()

        local tmpUids = {}
        for _,v in pairs(self.info) do
            if not table.contains(self.give, v) then
                table.insert(tmpUids, v)
            end
        end

        return tmpUids
    end

    return self
end



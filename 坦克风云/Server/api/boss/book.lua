-- 海神来袭参战预定
-- chenyunhe

local function api_boss_book(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.before()
        if moduleIsEnabled('boss') == 0 or moduleIsEnabled('bossBook') == 0 then
            self.response.ret = -180
            return self.response
        end
    end

    -- 预定
    function self.action_set(request)
        local response = self.response
        local uid = request.uid
        local act = request.params.flag or false
      
        if not uid then
            response.ret = -102
            return response
        end

        local weeTs = getWeeTs()
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "worldboss"})    
        local mUserinfo = uobjs.getModel("userinfo") 
        local mWorldboss = uobjs.getModel('worldboss')        
        local cfg = getConfig("bossCfg")  


        local time=cfg.opentime[2][1]*3600+cfg.opentime[2][2]*60
        local sttime=cfg.opentime[1][1]*3600+cfg.opentime[1][2]*60

        -- 需要判断vip等级 或者玩家等级  当前时间是不是在开启时间内
        if mUserinfo.level<cfg.altLevel and mUserinfo.vip<cfg.vipLimit then
            response.ret = -15010
            return response
        end
        
        -- 重置预定状态
        if weeTs>mWorldboss.attack_at then
            mWorldboss.bookAutoAttack(0)
        end

        if act then
            if ts >= weeTs+sttime and ts <= weeTs+86400  then
                response.ret = -15006
                return response
            end

            mWorldboss.bookAutoAttack(1)
            mWorldboss.addBookQueue()
        else
            mWorldboss.bookAutoAttack(0)
        end
   
        if uobjs.save()  then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end

    -- 获取预定队列
    function self.action_getQueue(request)
        local response = self.response
        local zid = getZoneId()
        local redis = getRedis()
        local cfg = getConfig("bossCfg")  

        local ts = getClientTs()
        local autoAtKey = "zid.".. zid ..".worldboss.autoAttackAt"
        local autoAttackAt = redis:getset(autoAtKey,ts)

        autoAttackAt = tonumber(autoAttackAt) or 0
        if ts - autoAttackAt >= (cfg.autoRBTime-2) then
            local key = "zid.".. zid ..".worldboss.bookqueue." .. getWeeTs()
            response.data.queue = redis:hgetall(key)
        else
            -- 如果定时配重并发情况(battle API中还有复活时间验证)
            -- 1、放入60得到45
            -- 2、放入60得到60
            -- 所以取出来的值一定比当前时间小15秒(定时是每15秒触发一次)
            if ts - autoAttackAt > 10 then
                redis:set(autoAtKey,autoAttackAt)
            end
        end

        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 预定队列排行榜奖励处理
    function self.action_rankingList(request)
        local response = self.response
        local list=getActiveRanking("worldboss.rank",getWeeTs())
        local ranklist={}
        if type(list)=='table' and next(list) then
            for k,v in pairs(list) do
                local mid =tonumber(v[1])
                table.insert(ranklist,{mid,v[2]})
            end
        end

        response.data.ranklist=ranklist
        response.ret = 0
        response.msg = 'success'
        return response
    end

    return self
end

return api_boss_book

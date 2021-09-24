-- desc: 重金打造
-- user: liming
local function api_active_zjdz(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'zjdz',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'zjdz'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end
    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        if not uid then
            response.ret = -102
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if mUseractive.info[self.aname].nums == nil then
            mUseractive.info[self.aname].nums = 0--可抽奖次数
        end
        if mUseractive.info[self.aname].sign == nil then
            mUseractive.info[self.aname].sign = 0--单次
        end
        if mUseractive.info[self.aname].more == nil then
            mUseractive.info[self.aname].more = 0--多次
        end
        if mUseractive.info[self.aname].gems == nil then
            mUseractive.info[self.aname].gems = 0--钻石数
        end
        if mUseractive.info[self.aname].s == nil then
            mUseractive.info[self.aname].s = 0--积分
        end
        if mUseractive.info[self.aname].r == nil then
            mUseractive.info[self.aname].r = 0--排行榜奖励
        end
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end
    -- 领取抽奖卷
    function self.action_welgift(request)
        local uid = request.uid
        local response = self.response
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local id = request.params.id 
        if not uid or not id then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        local acet = mUseractive.getAcet(self.aname,true)
        if ts > acet then
            response.ret=-1978    
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if id == 1 then
            if mUseractive.info[self.aname].sign <= 0 then
                response.ret=-102
                return response
            end
            mUseractive.info[self.aname].nums = mUseractive.info[self.aname].nums + mUseractive.info[self.aname].sign
            mUseractive.info[self.aname].sign = 0
        end
        if id == 2 then
            if mUseractive.info[self.aname].more <= 0 then
                response.ret=-102
                return response
            end
            mUseractive.info[self.aname].nums = mUseractive.info[self.aname].nums + mUseractive.info[self.aname].more
            mUseractive.info[self.aname].more = 0
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end
    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local zoneid = request.zoneid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local nickname = mUserinfo.nickname
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local acet = mUseractive.getAcet(self.aname,true)
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if ts > acet then
            response.ret=-2038    
            return response
        end
        if mUseractive.info[self.aname].nums <= 0 then
            response.ret=-1973    
            return response
        end
        local reward = {}
        local report = {}
        for i=1,mUseractive.info[self.aname].nums do
            local result,rkey= getRewardByPool(activeCfg.serverreward.pool,1)
            for k,v in pairs(result[1]) do
                reward[k] = (reward[k] or 0) + v
            end
        end
    
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
       
        mUseractive.info[self.aname].nums = 0
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
    
    -- 获取跨服排行榜数据
    function self.action_ranklist(request)
        local uid = request.uid
        local response = self.response 
        if not uid  then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local acname = self.aname..'_'..mUseractive.info[self.aname].cfg
        local ranklist = crossserverranklist(mUseractive.info[self.aname].st,acname)   
        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].ranklist = ranklist
        return response
    end

    -- 排行榜大奖
    function self.action_bigreward(request)
        local response = self.response
        local uid=request.uid
        if not uid  then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive',"props","bag"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local acet = mUseractive.getAcet(self.aname,true)
        local r=mUseractive.info[self.aname].r or 0
        if r==1 then
            response.ret=-1976
            return response
        end
        if ts <= acet then
            response.ret=-1978    
            return response
        end
        local rank=request.params.rank or 0
        local myrank=0
        local acname = self.aname..'_'..mUseractive.info[self.aname].cfg
        local ranklist = crossserverranklist(mUseractive.info[self.aname].st,acname) 
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v.uid)
                if mid==uid then
                    myrank=k
                end
            end
        end  
        if myrank~=rank then
            response.ret=-1975
            return response
        end
        if myrank<=0 then
            response.ret=-1980
            return response
        end

        local rankreward = {}
        local rankreward1 = {}
        for k,v in pairs(activeCfg.section) do
            if myrank<=v[2] then
                rankreward1=activeCfg.serverreward["rank"..k]
                break
            end
        end
        for k,v in pairs(rankreward1) do
            rankreward[k] = (rankreward[k] or 0) + v
        end
        mUseractive.info[self.aname].r =1
        if not takeReward(uid,rankreward) then
            response.ret=-102
            return response
        end
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(rankreward)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end
        return response        
    end

    return self
end



return api_active_zjdz

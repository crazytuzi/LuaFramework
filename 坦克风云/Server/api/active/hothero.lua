--desc:热点将领活动
--user:chenyunhe

local function api_active_hothero(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'hothero',
    }
    -- 抽取奖励
    function self.action_hothero(request)
        local response = self.response
        local uid = request.uid
        local free = request.params.free or nil -- 1:免费
        local num = request.params.num or 1     -- 抽取次数 1 或10
        local itemid = tonumber(request.params.itemid) or 1  -- 选择抽取的哪个将领
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local hotType = 1  -- 抽取类型 1单抽 2十连抽

        if not table.contains({0,1},free)  or not table.contains({1,2},itemid) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','hero'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mHero         = uobjs.getModel('hero')


        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end


        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
        end

        if mUseractive.info[self.aname].v==1 and free==1 then
            response.ret = -102
            return response
        end

        -- 判断是否有免费次数
        if mUseractive.info[self.aname].v == 0 and free ~=1 then
            response.ret = -102
            return response
        end


        local hotPoints = 0
        local reward,report
         -- 免费
        if free==1 then
             reward,hotPoints,report = self.randAward(activeCfg,1,itemid)
             mUseractive.info[self.aname].v=1
        else
            -- 消耗钻石
            local gems = 0
            if num ==1 then
                gems = activeCfg.cost1
                reward,hotPoints,report = self.randAward(activeCfg,1,itemid)
            else
                num = 10
                gems = activeCfg.cost2
                reward,hotPoints,report = self.randAward(activeCfg,10,itemid)
                hotType = 2
            end

            if not gems or gems <= 0 then 
                response.ret = -102
                return response
            end

            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=162,item="",value=gems,params={num=num}})
        end

        -- 奖励积分
        mUseractive.info[self.aname].hotPoints = (mUseractive.info[self.aname].hotPoints or 0)+hotPoints
        if not takeReward(uid,reward) then
            return response
        end

       local boxNum = #activeCfg.scorelimit
       -- 更新宝箱状态
        if type(mUseractive.info[self.aname].box) ~= 'table' then
            mUseractive.info[self.aname].box = {}
            for i=1,boxNum do
                table.insert(mUseractive.info[self.aname].box,1)
            end
        end

        for i=1,boxNum do
            if mUseractive.info[self.aname].box[i]<3 then
                if mUseractive.info[self.aname].hotPoints>=activeCfg.scorelimit[i] then
                    mUseractive.info[self.aname].box[i] = 2
                end
            end
        end

        local clientReport= copyTable(report)
    
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','hothero',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
            for k,v in pairs(hReward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
        

        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={}  end
            table.insert(data,1,{ts,report,hotType})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end

            response.data.hero = mHero.toArray(true)
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end           
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=clientReport
            response.data.freegifts= freeClient
        else
            response.ret=-106
        end

        return response
    end

    -- 随机奖励 actCfg活动配置 num 随机次数 pool使用奖池
    function self.randAward(actCfg,num,pool)
        local reward={}
        local report = {}
        local hotPoints = 0 --热点积分

        for i=1,num do
            local result,rewardkey = getRewardByPool(actCfg.serverreward['pool'..pool],1)
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end

            for i=1,#rewardkey do
                hotPoints = hotPoints+actCfg.serverreward['pool'..pool]['score'][rewardkey[i]]
            end
        end

        -- 相同的奖励在记录时需要合并
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        return reward,hotPoints,report
    end


    -- 热点积分开宝箱
    function self.action_openBox(request)
        local response = self.response
        local uid = request.uid
        local boxid = tonumber(request.params.boxid) or 0

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local boxinfo = activeCfg.boxinfo[boxid]
        local boxNum = #activeCfg.scorelimit

            -- 判断当前兑换配置数据
        if  type(boxinfo)~='table' then
            response.ret = -102
            return response
        end

        if boxid>boxNum or boxid==0 then
            response.ret = -102
            return response
        end

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].box) ~= 'table' then
            mUseractive.info[self.aname].box = {}
            for i=1,boxNum do
                table.insert(mUseractive.info[self.aname].box,1)
            end
        end

        local costPoint = activeCfg.scorelimit[boxid]
        if mUseractive.info[self.aname].hotPoints==nil then
            mUseractive.info[self.aname].hotPoints=0
        end

        -- 能否领取
        if costPoint> mUseractive.info[self.aname].hotPoints then
            response.ret = -107
            return response
        end

        -- 判断是否领取过 1未领取，2可领取，3已领取
        if mUseractive.info[self.aname]['box'][boxid]>=3  then
            response.ret = -1976
            return response
        end

        -- 领取记录
        mUseractive.info[self.aname]['box'][boxid]=3
        local reward = boxinfo['serverreward']

        local awards = {}
        local clientReward = {}
        for i=1,#reward do
            awards[reward[i][1]]=(awards[reward[i][1]] or 0)+reward[i][2]
            table.insert(clientReward,formatReward({[reward[i][1]]=reward[i][2]}))
        end
        if not takeReward(uid,awards) then
            return response
        end

        if uobjs.save() then
            response.data.reward=clientReward
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response

    end

   -- 获取记录
    function self.action_getReportLog(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')

        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data

        return response
    end
    return self
end

return api_active_hothero
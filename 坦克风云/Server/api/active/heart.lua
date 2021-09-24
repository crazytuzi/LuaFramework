-- desc: 将心补心
-- user: liming
local function api_active_heart(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'heart',
    }

    -- 随机奖励
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
       
        if not table.contains({0,1},free) or not table.contains({1,5},num) or not uid then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        -- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
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

        -- 消耗钻石
        local gems = 0
        if free==1 then
             mUseractive.info[self.aname].v=1
        else
            if num ==1 then
                gems = activeCfg.cost1
            else
                num = 5
                gems = activeCfg.cost2
            end
        end
       
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        
        if gems>0 then
            regActionLogs(uid,1,{action = 200, item = "", value = gems, params = {num = num}})
        end

        local reward = {}
        local report = {}
        local cellCount = activeCfg.cellCount
        local normal = tonumber(activeCfg.normal)
        local critExtra = tonumber(activeCfg.critExtra)
        local critRate = activeCfg.critRate*100
        local tmppost = mUseractive.info[self.aname].tmppost
        local cellnum = 0
        for i=1,num do
            local totalnum = 0
            local basereward = getRewardByPool(activeCfg.serverreward.pool1)
            for k,v in pairs(basereward) do
                reward[k] = (reward[k] or 0) + v
            end
            local rd = rand(1,100)
            if rd < critRate then
               totalnum = normal + critExtra
            else
               totalnum = normal
            end
            cellnum = cellnum + totalnum
            for i=1,totalnum do
                if #tmppost < 1 then
                    for i=1,cellCount do
                        table.insert(mUseractive.info[self.aname].tmppost,i)
                    end
                end
                local rd1 = rand(1,#tmppost)
                mUseractive.info[self.aname].post[tmppost[rd1]] = (mUseractive.info[self.aname].post[tmppost[rd1]] or 0) + 1
                table.remove(tmppost,rd1)
            end
        end
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','heart',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end
        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            table.insert(data,1,{ts,report,num,harCReward,cellnum})
            if next(data) then
                if #data >10 then
                    for i=#data,11 do
                        table.remove(data)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward  -- 和谐版奖励
            end
            response.data[self.aname].reward = report -- 奖励
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

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false
        local cellCount = activeCfg.cellCount
        --格子状态
        if type(mUseractive.info[self.aname].post)~='table' then
            flag = true
            mUseractive.info[self.aname].post = {}
            for i=1,cellCount do
                table.insert(mUseractive.info[self.aname].post,0)
            end
        end
        if type(mUseractive.info[self.aname].tmppost)~='table' then
            flag = true
            mUseractive.info[self.aname].tmppost = {}
            for i=1,cellCount do
                table.insert(mUseractive.info[self.aname].tmppost,i)
            end
        end

        --大奖领取次数
        if mUseractive.info[self.aname].count==nil  then
            flag = true
            mUseractive.info[self.aname].count = 0
        end
       

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end

        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领奖
    function self.action_gift(request)
        local response = self.response
        local uid=request.uid
        local num= 1 --领取次数
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local rewardLimit = activeCfg.rewardLimit
        -- 领奖次数限制
        if mUseractive.info[self.aname].count + num >rewardLimit then
            response.ret=-23305
            return response
        end
        --牌子不足
        for k,v in pairs(mUseractive.info[self.aname].post) do
            if v < 1 then
               response.ret = -20014
               return response
           end
        end
        -- 增加领取次数
        mUseractive.info[self.aname].count=mUseractive.info[self.aname].count + num
        for k,v in pairs(mUseractive.info[self.aname].post) do
            mUseractive.info[self.aname].post[k] = mUseractive.info[self.aname].post[k] - 1
        end
        local reward = {}
        reward = getRewardByPool(activeCfg.serverreward.pool2)
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end


    return self
end

return api_active_heart

-- desc: 宝石加工厂
-- user: liming
local function api_active_jewelfactory(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jewelfactory',
    }
    -- 抽奖 随机奖励
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
        local mAweapon = uobjs.getModel('alienweapon')
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
        local jewelcfg = getConfig('alienjewel')
        local acet = mUseractive.getAcet(self.aname,true)
        if ts>=acet then
            response.ret=-102
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
            regActionLogs(uid,1,{action = 208, item = "", value = gems, params = {num = num}})
        end
        local lreward = {}
        local reward = {}
        local report = {}
        local isact = 0
        for i=1,num do
            local flag = true
            for k,v in pairs(mUseractive.info[self.aname].color) do
                if v < activeCfg.colorNum[k] then
                    flag = false
                    break
                end
            end
            if flag == true then
                isact = 1
                local bresult,brewardkey
                bresult,brewardkey = getRewardByPool(activeCfg.serverreward.pool2,1)
                for idx=1,#brewardkey do
                    local bscore=0
                    bscore = activeCfg.serverreward['pool2'].score[brewardkey[idx]]
                    mUseractive.info[self.aname].s=(mUseractive.info[self.aname].s or 0)+bscore
                end
                for k,v in pairs (bresult) do
                    table.insert(lreward,v)
                    for rk,rv in pairs(v) do
                        reward[rk]=(reward[rk] or 0)+rv
                    end
                end
                for k,v in pairs(mUseractive.info[self.aname].color) do
                    mUseractive.info[self.aname].color[k] = 0
                end
            end
            local result,rewardkey,getjewel
            result,rewardkey = getRewardByPool(activeCfg.serverreward.pool1,1)
            for idx=1,#rewardkey do
                local score=0
                score = activeCfg.serverreward['pool1'].score[rewardkey[idx]]
                mUseractive.info[self.aname].s=(mUseractive.info[self.aname].s or 0)+score
            end
            for k,v in pairs (result) do
                table.insert(lreward,v)
                for rk,rv in pairs(v) do
                    getjewel = rk
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end
            
            getjewel = string.split(getjewel,"_")
            getjewel = getjewel[2]
            local color = jewelcfg.main[getjewel].color
            local rd = rand(1,100)
            if rd < activeCfg.colorRate[color]*100 then
               mUseractive.info[self.aname].color[color] = mUseractive.info[self.aname].color[color] + 1
            end
            
        end
        for key,val in pairs(lreward) do
            for k,v in pairs(val) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','jewelfactory',num)
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
            table.insert(data,1,{ts,report,num,harCReward})
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
            if mUseractive.info[self.aname].s>=activeCfg.rLimit then
                if not setActiveRanking(uid,mUseractive.info[self.aname].s,self.aname,10,mUseractive.info[self.aname].st,mUseractive.info[self.aname].et) then
                    setActiveRanking(uid,mUseractive.info[self.aname].s,self.aname,10,mUseractive.info[self.aname].st,mUseractive.info[self.aname].et)
                end
            end 
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward  -- 和谐版奖励
            end
            response.data[self.aname].reward = report -- 奖励
            response.data[self.aname].isact = isact --1表示激活
            response.data.alienjewel = mAweapon.formjeweldata()-- 宝石
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
        --宝石颜色
        if type(mUseractive.info[self.aname].color)~='table' then
            flag = true
            mUseractive.info[self.aname].color = {}
            for i=1,#activeCfg.colorNeed do
                table.insert(mUseractive.info[self.aname].color,0)
            end
        end

        -- 排行榜积分
        if not mUseractive.info[self.aname].s then
            flag =  true
            mUseractive.info[self.aname].s = 0
        end
        -- 领取状态
        if not mUseractive.info[self.aname].r then
            flag =  true
            mUseractive.info[self.aname].r = 0 -- 0未领取 1已领取
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
    
    -- 获取排行榜数据
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
        local ranklist = getActiveRanking(self.aname,mUseractive.info[self.aname].st)        
        local list={}
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
                local muobjs = getUserObjs(mid,true)
                muobjs.load({"userinfo"})
                local tmUserinfo = muobjs.getModel('userinfo')
                table.insert(list,{mid,tmUserinfo.nickname,v[2]})
            end
        end
        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].ranklist = list
        return response
    end

    -- 排行榜奖励
    function self.action_rankreward(request)
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
        local ranklist = getActiveRanking(self.aname,mUseractive.info[self.aname].st)
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
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
        for k,v in pairs(activeCfg.section) do
            if myrank<=v[2] then
                rankreward=activeCfg.serverreward["rank"..k]
                break
            end
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

return api_active_jewelfactory

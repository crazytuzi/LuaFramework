--
-- desc: 宝石精研
-- user: chenyunhe
--
local function api_active_bsjy(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'bsjy',
    }

    function self.before(request)
        local response = self.response    
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

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
    end

    -- 刷新 初始化
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false

        if not mUseractive.info[self.aname].l then
            flag = true
            mUseractive.info[self.aname].l = 1
        end
        --重置抽奖次数
        if not mUseractive.info[self.aname].f then
            flag = true
            mUseractive.info[self.aname].f = 0
        end
       
        if mUseractive.info[self.aname].t ~= weeTs then
            flag = true
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
            mUseractive.info[self.aname].f = 0
        end

        -- 商店
        if type(mUseractive.info[self.aname].s)~='table' then
            flag = true
            mUseractive.info[self.aname].s = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                mUseractive.info[self.aname].s[k]={}
                for rk,rv in pairs(v) do
                    mUseractive.info[self.aname].s[k][rk]=0
                end
            end
        end

        if not mUseractive.info[self.aname].gem then
            flag = true
            mUseractive.info[self.aname].gem = 0
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

    -- 抽奖 vip=0不能使用特权 ?
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 1单抽 10十连抽
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local act = request.params.act -- 抽奖类型 1：单次,2：10次,3：vip
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not table.contains({0,1},free) or not table.contains({1,10},num) and not table.contains({1,2,3},act)  then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"troops"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mAweapon = uobjs.getModel('alienweapon')

        if not mUseractive.info[self.aname].l then
            mUseractive.info[self.aname].l = 1
        end
        --重置抽奖次数
        if not mUseractive.info[self.aname].f then
            mUseractive.info[self.aname].f = 0
        end
       
        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
            mUseractive.info[self.aname].f = 0
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local randFlag = true
        local gems = 0
        local rewardType = mUseractive.info[self.aname].l
        -- 单次是有免费的
        if act == 1 then 
            -- 免费时 单抽
            if free ==1 and num~=1 then
                response.ret = -102
                return response
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

            if free==1 then
                 mUseractive.info[self.aname].v=1
            else   
                gems = activeCfg.cost
            end
        elseif act==2 then
            if num~=10 then
                response.ret = -102
                return response
            end
            gems = activeCfg.mulc
        else
            randFlag = false
            if num~=1 then
                response.ret = -102
                return response
            end
            local vip = mUserinfo.vip
            local vipTimes = 0
            if vip <= 0 then
                return response
            end
            local flag = false
            for _,v in pairs(activeCfg.vipCost) do
                if v[1][1] <= vip and vip <= v[1][2] then
                    rewardType = v[3]
                    gems = v[2]
                    vipTimes = v[4]
                    flag = true
                    break
                end
            end

            if not flag then
                response.ret = -102
                return response
            end
            if mUseractive.info[self.aname].f >= vipTimes then
                response.ret = -1981
                return response
            end
            mUseractive.info[self.aname].f = mUseractive.info[self.aname].f + 1
        end

        local reward={}
        local report={}
        local pool = activeCfg.serverreward.pool[rewardType]
        for i=1, num do
            local result,rewardkey = getRewardByPool(pool,1)      
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end  
           
            if randFlag then
                local vate = activeCfg.serverreward.vate[mUseractive.info[self.aname].l]
                setRandSeed()
                local randNum = rand(1,100)
                if randNum <= vate then
                    mUseractive.info[self.aname].l = mUseractive.info[self.aname].l + 1
                    if #(activeCfg.serverreward.pool) < mUseractive.info[self.aname].l then
                        mUseractive.info[self.aname].l = #(activeCfg.serverreward.pool)
                    end
                else
                    mUseractive.info[self.aname].l = 1
                end
                pool = activeCfg.serverreward.pool[mUseractive.info[self.aname].l]
            end
        end

        if not next(reward) then
            response.ret = -120
            return response
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        if gems>0 then
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=250,item="",value=gems,params={num=num}})

            mUseractive.info[self.aname].gem = (mUseractive.info[self.aname].gem or 0) + gems
            
        end
     
        local clientReport= copyTable(report)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward
            if act==3 then
                hReward,hClientReward = harVerGifts('active','bsjy',num,true)
            else
                hReward,hClientReward = harVerGifts('active','bsjy',num)
            end
      
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
            if type (data)~="table" then data={}  end
            
            table.insert(data,1,{ts,report,num,harCReward,act})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end         
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end
            response.data[self.aname].reward=clientReport
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

    -- 商店兑换
    function self.action_shop(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 购买次数
        local sid = tonumber(request.params.sid) -- 哪个商店
        local gid = request.params.gid -- 商品id
        
        if not gid or num<=0  then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"troops"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mAweapon = uobjs.getModel('alienweapon')
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].s[sid])~='table' then
            response.ret = -102
            return response
        end
     
        if mUseractive.info[self.aname].gem < activeCfg.costNum[sid] then
            response.ret = -102
            return response
        end

        local itemCfg = activeCfg.serverreward['shopList'][sid][gid]
        if type(itemCfg)~='table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].s[sid][gid]+num>itemCfg.limit then
            response.ret = -121
            return response
        end

        local gems = itemCfg.value*num
        if gems<=0 then
            response.ret = -102
            return response
        end
        local reward = {}
        for k,v in pairs(itemCfg.serverreward) do
            reward[k] = v*num 
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=251,item="",value=gems,params={num=num}})
        mUseractive.info[self.aname].s[sid][gid] = mUseractive.info[self.aname].s[sid][gid] + num
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    return self
end

return api_active_bsjy

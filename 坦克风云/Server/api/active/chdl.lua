--
-- desc: 残骸打捞
-- user: chenyunhe
--
local function api_active_chdl(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'chdl',
    }


    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'chdl'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end


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
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        local flag = false
        -- 兑换券
        if not mUseractive.info[self.aname].q then
            flag = true
            mUseractive.info[self.aname].q = 0 
        end
        

        if not mUseractive.info[self.aname].A then
            mUseractive.info[self.aname].A = 0
            flag = true
        end

        if not mUseractive.info[self.aname].B then
            mUseractive.info[self.aname].B = 0
            flag = true
        end

        if not mUseractive.info[self.aname].C then
            mUseractive.info[self.aname].C = 0
            flag = true
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

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 1单抽 10十连抽
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local lv = request.params.t -- 抽奖类型 1：低级,2：中级,3：高级
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not table.contains({0,1},free) or not table.contains({1,10},num) and not table.contains({1,2,3},lv)  then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"troops"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 消耗钻石
        local gems = 0
        -- 中级打捞是有免费的
        if lv ==2 then 
            -- 免费时 单抽
            if free ==1 and num>1 then
                response.ret = -102
                return response
            end

            if mUseractive.info[self.aname].t ~= weeTs then
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

            if free==1 then
                 mUseractive.info[self.aname].v=1
            else
                if num ==1 then
                    gems = activeCfg.cost1[lv]
                else
                    num = 10
                    gems = activeCfg.cost2[lv]
                end
            end
        else
            if free ==1 then
                response.ret = -102
                return response
            end
            if num ==1 then
                gems = activeCfg.cost1[lv]
            else
                gems = activeCfg.cost2[lv]
            end
        end
       
        local reward={}
        local report={}
        for i=1,num do 
            local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool'..lv],1)      
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end           
        end

        if not next(reward) then
            response.ret = -120
            return response
        end

        local quan = activeCfg.ticketGet[lv] * num
        mUseractive.info[self.aname].q = (mUseractive.info[self.aname].q or 0) + quan
        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end
        
        reward[activeCfg.exItem] = quan
        for k,v in pairs(reward) do
            if k=='chdl_a1' then
                table.insert(report,self.formatreward({[k]=v}))
            else
                table.insert(report, formatReward({[k]=v}))
            end
        end

        if gems>0 then
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=248,item="",value=gems,params={num=num}})
        end
     
        local clientReport= copyTable(report)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hnum = activeCfg.lotteryNum[lv]*num
            local giftCfg = getConfig('harmonyVersion')
            local gifts = giftCfg.default.serverreward

            if type(giftCfg.active.chdl)=='table' and next(giftCfg.active.chdl) then
                if lv==1 then
                    gifts = giftCfg.active.chdl.serverreward
                elseif lv ==2 then
                    gifts = giftCfg.active.chdl.spserverreward
                else
                    gifts = giftCfg.active.chdl.spserverreward2
                end
            end

            local hReward = {}
            local hClientReward = {}
            for k,v in pairs(gifts) do
                hReward[v[1]] = (hReward[v[1]] or 0)+v[2]*hnum
            end

            for k,v in pairs(hReward) do
                table.insert(hClientReward, formatReward({[k]=v}))
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
            
            table.insert(data,1,{ts,report,num,harCReward,lv,quan})
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
            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 兑换船
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local ex = request.params.ex  -- A、B、C组
        local act = request.params.act -- 1单次 大于1快速兑换
        local aid1 = tostring(request.params.aid1) --aid1兑换aid2
        local aid2 = tostring(request.params.aid2) 
        local weeTs = getWeeTs()

        if not table.contains({"A","B","C"},ex) or act<=0 then
            response.ret = -102
            return response
        end

        -- 不能兑换本身
        if not aid1 or not aid2 or aid1==aid2 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        local mTroop = uobjs.getModel('troops')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if not table.contains(activeCfg['group'..ex],aid1) or not table.contains(activeCfg['group'..ex],aid2) then
            response.ret= -102
            return response
        end
        
        aid1 = 'a'..aid1
        aid2 = 'a'..aid2
        
        local idtab = {A=1,B=2,C=3}
        local id = idtab[ex]

        local cur = mTroop.troops[aid1] or 0
        if cur<=0 then
            response.ret = -115
            return response
        end
        local tickets = activeCfg.ticketNeed[id]
        local ext = math.floor(cur/activeCfg['exchangeNum'..id])-- 当前可兑换的次数
        if ext<act then
            response.ret = -102
            return response
        end      

        local costgems = 0 --可能消耗的钻石
        local gems = 0 -- 消耗的钻石
        local cq = 0 -- 消耗的兑换券
        local curetimes = mUseractive.info[self.aname][ex] or 0
        for i=1,act do
            local etimes = curetimes + i
            local price=math.max(math.floor((etimes-1)/activeCfg.exUpNum[id]),0)*activeCfg.upValue[id]+activeCfg.exCost[id]
            if price>activeCfg.upLimit[id] then
                price = activeCfg.upLimit[id]
            end
            
            costgems = costgems + price
            if mUserinfo.gems >= costgems and mUseractive.info[self.aname].q >= i*tickets  then
                gems = gems + price
            else
                response.ret = -102
                return response
            end
        end
        local reward = {} 
        reward['troops_'..aid2] = act
        local costnum = act*activeCfg['exchangeNum'..id]
        if not mTroop.consumeTanks(aid1,costnum) then
            response.ret = -115
            return response
        end

        if not mTroop.incrTanks(aid2,act) then
            response.ret = -106
            return response
        end

        if gems<=0 then
            response.ret = -102
            return response
        end       
 
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
      
        cq = tickets*act
        if cq>mUseractive.info[self.aname].q then
            response.ret = -1996
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action=249,item="",value=gems,params={num=act}})
        end  
 
        mUseractive.info[self.aname].q = mUseractive.info[self.aname].q  - cq
        mUseractive.info[self.aname][ex] = (mUseractive.info[self.aname][ex] or 0) + act  
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data.troops = mTroop.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end

    return self
end

return api_active_chdl

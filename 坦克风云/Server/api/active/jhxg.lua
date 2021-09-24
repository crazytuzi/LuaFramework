--
-- desc: 军火限购
-- user: chenyunhe
--
local function api_active_jhxg(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jhxg',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'jhxg'
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

    -- 刷新商店数据  flag 首次要特殊处理
    function self.refreshshop(cfg,flag,luck)
        local items = {}
        local result,rewardkey = getRewardByPool(cfg.serverreward.pool2)  
        local f,fkey 

        if flag then
            f,fkey = getRewardByPool(cfg.serverreward.pool1)
        end

        local len = table.length(result)
        setRandSeed()
        local rd = rand(1,len)
        for k,v in pairs(result) do
            if flag and k==rd then
                v = f[1]
            end
            local scfg = cfg.serverreward.shopList[v]
            local dis = rand(scfg.discount[1]*10,scfg.discount[2]*10)
            if dis>=scfg.lucky*10 then
                luck = luck + 1
            else
                luck = 0
            end
            table.insert(items,{v,dis/10,0}) -- id  折扣 是否购买
        end
        return items,luck
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

        -- 体力
        if not mUseractive.info[self.aname].en then
            mUseractive.info[self.aname].en = {0,0}--总的值,已领取次数
            flag = true
        end

        --充值
        if not mUseractive.info[self.aname].ch then
            mUseractive.info[self.aname].ch = {0,0}-- 总的值,已领取次数
            flag = true
        end

        -- 刷新券
        if not mUseractive.info[self.aname].q then
            flag = true
            mUseractive.info[self.aname].q = 0
        end

        -- 钻石刷新次数
        if not mUseractive.info[self.aname].gt then
            flag = true
            mUseractive.info[self.aname].gt = 0
        end

        -- 幸运值 用来刷新商店  前端用不到
        if not mUseractive.info[self.aname].luck then
            flag = true
            mUseractive.info[self.aname].luck = 0
        end

        -- 商店
        if type(mUseractive.info[self.aname].s)~='table' then
            flag = true
            mUseractive.info[self.aname].s,mUseractive.info[self.aname].luck = self.refreshshop(activeCfg,true,0) 
        end

        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].t = weeTs
            mUseractive.info[self.aname].en = {0,0}--总的值,已领取次数
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

    -- 商店
    function self.action_shop(request)
        local uid = request.uid
        local response = self.response
        local gid = request.params.gid -- 下标
        local id = request.params.id -- 商品的配置id
        
        if not gid then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"troops"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].s[gid])~='table' then
            response.ret = -102
            return response
        end
      
        if mUseractive.info[self.aname].s[gid][3] ==1 then
            response.ret = -1976
            return response
        end


        local checkid = mUseractive.info[self.aname].s[gid][1]
        if checkid~=id then
            response.ret = -102
            return response
        end

        local itemCfg = activeCfg.serverreward.shopList[checkid]
        if type(itemCfg)~='table' then
            response.ret = -102
            return response
        end

        local gems = math.floor(itemCfg.price*mUseractive.info[self.aname].s[gid][2])
        if gems<=0 then
            response.ret = -102
            return response
        end
       
        if not takeReward(uid,itemCfg.serverreward) then    
            response.ret=-403
            return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=253,item="",value=gems,params={num=1}})
        mUseractive.info[self.aname].s[gid][3] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(itemCfg.serverreward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 刷新商店
    function self.action_refshop(request)
        local uid = request.uid
        local response = self.response
        local act = request.params.r
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        
        if act then
            -- 钻石刷新不用了
            response.ret = -180
            return response

            -- local maxid = #activeCfg.useGem
            -- local times = (mUseractive.info[self.aname].gt or 0) + 1
            -- local gems = activeCfg.useGem[times] or activeCfg.useGem[maxid]

            -- if not mUserinfo.useGem(gems) then
            --     response.ret = -109
            --     return response
            -- end
     
            -- mUseractive.info[self.aname].gt = times
            -- regActionLogs(uid,1,{action=254,item="",value=gems,params={num=1}})
        else
            local useq = activeCfg.useNum
            if mUseractive.info[self.aname].q<useq then
                response.ret = -1996
                return response
            end
            mUseractive.info[self.aname].q =  mUseractive.info[self.aname].q - useq
        end     

        local rflag = false
        if mUseractive.info[self.aname].luck>= activeCfg.luckyLimit then
            rflag = true
        end

        mUseractive.info[self.aname].s,mUseractive.info[self.aname].luck = self.refreshshop(activeCfg,rflag,mUseractive.info[self.aname].luck)
        
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 领取充值奖励、体力奖励
    function self.action_reward(request)
        local uid = request.uid
        local response = self.response
        local num = request.params.num -- 领取几个
        local act = request.params.act  --1 体力 2充值
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if num<=0 or not table.contains({1,2},act) then
            response.ret = -102
            return response
        end

        local reward = {}
        local getq = 0
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if act==1 then
            local enable1 = math.floor(mUseractive.info[self.aname].en[1]/activeCfg.energyBack[1])-mUseractive.info[self.aname].en[2]
            if activeCfg.energyBack[3]>0 then
                if mUseractive.info[self.aname].en[2]>= activeCfg.energyBack[3] then
                    response.ret = -121
                    return response
                end
             
                local enable2 = activeCfg.energyBack[3]-mUseractive.info[self.aname].en[2]   
                if enable1>enable2 then
                    if num>enable2 then
                        response.ret = -121
                        return response
                    end
                else
                    if num>enable1 then
                        response.ret = -121
                        return response
                    end
                end 
            else
                if num>enable1 then
                    response.ret = -121
                    return response
                end  
            end

            mUseractive.info[self.aname].en[2] = (mUseractive.info[self.aname].en[2] or 0) + num
            getq = num * activeCfg.energyBack[2]
            reward[activeCfg.refreshItem] = getq   
        else
            
            local enable1 = math.floor(mUseractive.info[self.aname].ch[1]/activeCfg.rechargeNum[1])-mUseractive.info[self.aname].ch[2]
            if activeCfg.rechargeNum[3]>0 then
                if mUseractive.info[self.aname].ch[2]>= activeCfg.rechargeNum[3] then
                    response.ret = -121
                    return response
                end

                local enable1 = math.floor(mUseractive.info[self.aname].ch[1]/activeCfg.rechargeNum[1])-mUseractive.info[self.aname].ch[2]
                local enable2 = activeCfg.rechargeNum[3]-mUseractive.info[self.aname].ch[2]   
                if enable1>enable2 then
                    if num>enable2 then
                        response.ret = -102
                        return response
                    end
                else
                    if num>enable1 then
                        response.ret = -102
                        return response
                    end
                end 
            else
                if num>enable1 then
                    response.ret = -121
                    return response
                end
            end
            mUseractive.info[self.aname].ch[2] = (mUseractive.info[self.aname].ch[2] or 0) + num
            getq = num * activeCfg.rechargeNum[2]
            reward[activeCfg.refreshItem] = getq
        end  

        mUseractive.info[self.aname].q = mUseractive.info[self.aname].q + getq         
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = self.formatreward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end


    return self
end

return api_active_jhxg

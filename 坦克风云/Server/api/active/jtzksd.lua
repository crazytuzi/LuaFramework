--
-- desc: 军团折扣商店
-- user: guohaojie
--

local function api_active_jtzksd(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jtzksd',
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
        
        -- 原价商店 限购次数
        if type(mUseractive.info[self.aname].bnum1) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].bnum1 = {}  
            for key,val in pairs(activeCfg.serverreward.shopList1) do
                table.insert(mUseractive.info[self.aname].bnum1,val['limit'])
            end
        end
        --折扣限购次数
        if type(mUseractive.info[self.aname].bnum2) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].bnum2 = {}  
            for key,val in pairs(activeCfg.serverreward.shopList2) do
                table.insert(mUseractive.info[self.aname].bnum2,val['limit'])
            end
        end

          --奖励剩余数量
        if type(mUseractive.info[self.aname].rlimit) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].rlimit = {}  
            for key,val in pairs(activeCfg.shopRecharge) do
                table.insert(mUseractive.info[self.aname].rlimit,activeCfg.rGetLimit)
            end
        end

        -- 领取状态
        if type(mUseractive.info[self.aname].task) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].task = {}  
            for key,val in pairs(activeCfg.shopRecharge) do
                table.insert(mUseractive.info[self.aname].task,0)--0未领取,1以领取
            end
        end
     
        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].legion = 0
        response.data[self.aname].rebate = 0

        local aid = mUserinfo.alliance
        if aid>0 then
            local aAllianceActive = getModelObjs("allianceactive",aid)
            local activeObj = aAllianceActive.getActiveObj(self.aname)  
            response.data[self.aname].legion = activeObj.activeInfo.legion or 0
            response.data[self.aname].rlimit= activeObj.activeInfo.rlimit or mUseractive.info[self.aname].rlimit
            for key,val in pairs(activeCfg.shopRecharge) do                
                if activeObj.activeInfo.legion ~=nil and activeObj.activeInfo.legion >= val  then
                    response.data[self.aname].rebate=activeCfg.discount[key]
                end
            end
        end

        response.ret = 0
        response.msg = 'Success'
        return response
       
    end

    -- 领取奖励
    function self.action_reward(request)
        local response = self.response
        local id = request.params.id
        local uid=request.uid
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        --判断是否还在军团
        local aid = mUserinfo.alliance
        if aid <=0 then
            response.ret = -102
            return response
        end
        
        if not activeCfg.serverreward.giftList[id]  then
            response.ret = -102
            return response
        end
        --判断是否达到领取条件
        local aAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = aAllianceActive.getActiveObj(self.aname) 
        if activeObj.activeInfo.legion < activeCfg.shopRecharge[id] then
            response.ret = -102
            return response
        end

        --判断是否领取
        if mUseractive.info[self.aname].task[id] == 1 then
            response.ret = -102
            return response
        end

        local reward = activeCfg.serverreward['giftList'][id]["r"]
        mUseractive.info[self.aname].task[id]=1

        local result = {}
        local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
        if mAllianceActive then
           result=mAllianceActive.getActiveObj(self.aname):delnum(activeCfg.rGetLimit,id)
            if tonumber(result.rlimit[id])< 0 then
                response.ret = -102
                return response
            end
        end
        

        if not next(reward) then
            response.ret = -120
            return response
        end
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname]=mUseractive.info[self.aname]
            response.data[self.aname].r=formatReward(reward)
            response.data[self.aname].rlimit=result.rlimit
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response
    end

    --购买
    function self.action_shop(request)
        local response = self.response
        local bid = request.params.bid     --购买的商品id
        local sid = request.params.sid     -- 商店id
        local dst = request.params.dst     --折扣
        local uid=request.uid
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        

        if not table.contains({1,2},sid)  then
            response.ret=-102
            return response
        end
        --判断bid
        local shopList = "shopList"..sid
        local bnum = "bnum"..sid
        if not activeCfg.serverreward[shopList][bid]  then
            response.ret = -102
            return response
        end

        --判断是否还有购买次数
        if mUseractive.info[self.aname][bnum][bid] <=0 then
            response.ret = -102
            return response
        end 

        local tid = 0    --记录配置discout对应的key
        local rebate = 0  --记录折扣
        local aid = mUserinfo.alliance

        if sid==2 then
            --判断是否还在军团
            if aid <=0 then
                response.ret = -102
                return response
            end

            --判断折扣是否正确
            local aAllianceActive = getModelObjs("allianceactive",aid)
            local activeObj = aAllianceActive.getActiveObj(self.aname) 
            for key,val in pairs(activeCfg.shopRecharge) do                
                if activeObj.activeInfo.legion ~=nil and activeObj.activeInfo.legion >= val  then
                    rebate=activeCfg.discount[key]
                    tid=key
                end
            end
            if rebate ~= dst then
                response.ret = -102
                return response
            end

        end

      
        mUseractive.info[self.aname][bnum][bid]=mUseractive.info[self.aname][bnum][bid]-1

        local reward = activeCfg.serverreward[shopList][bid]["r"]
        if not next(reward) then
            response.ret = -120
            return response
        end
        
        local gems = 0
        if sid==1 then
            gems = activeCfg.serverreward[shopList][bid]["price"]
        else
            gems = activeCfg.serverreward[shopList][bid]["value"][tid+1]
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=278,item="",value=gems,params={}})

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        
        if uobjs.save() then

            response.data[self.aname]=mUseractive.info[self.aname]
            response.data[self.aname].r=formatReward(reward)
            response.data[self.aname].legion = 0
            response.data[self.aname].rebate = 0

         
            if aid>0  then
                local aAllianceActive = getModelObjs("allianceactive",aid)
                local activeObj = aAllianceActive.getActiveObj(self.aname)

                for key,val in pairs(activeCfg.shopRecharge) do                
                    if activeObj.activeInfo.legion ~=nil and activeObj.activeInfo.legion >= val  then
                        rebate=activeCfg.discount[key]
                    end
                end
                response.data[self.aname].rebate=rebate
                response.data[self.aname].legion = activeObj.activeInfo.legion or 0

            end

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response
    end

       return self
end

return api_active_jtzksd
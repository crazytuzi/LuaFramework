--
-- desc: 军团之光
-- user: chenyunhe
--
local function api_active_jtzg(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jtzg',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'jtzg'
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

    -- 领取充值奖励
    function self.action_reward(request)
 		local uid = request.uid
        local response = self.response
        local item =  request.params.item -- 下标
        local act = request.params.act --是普通档1还是额外2
        local num = request.params.num -- 领取数量
        local ts = getClientTs()
        
        if not item or not table.contains({1,2},act) then
       	   response.ret=-102
       	   return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local reward = {}
        local jtzg_a1 = 0
        local jtzg_a2 = 0
        if act == 1 then
            if type(mUseractive.info[self.aname].charge) ~= 'table' then
                response.ret = -102
                return response
            end

            local cur = mUseractive.info[self.aname].charge[item][1]
            if cur<=0 then
                response.ret = -102
                return response
            end

            if num>cur then
                response.ret = -102
                return response
            end

            local giftcfg = activeCfg.serverreward['gift'..item]
            if type(giftcfg)~='table' then
                response.ret = -102
                return response
            end

            for k,v in pairs(giftcfg) do
                local tnum = v*num    
                if k=='jtzg_a1' then
                    jtzg_a1 = tnum
                elseif k== 'jtzg_a2' then
                    jtzg_a2 = tnum
                else
                    reward[k] = tnum
                end
            end

            mUseractive.info[self.aname].charge[item][1] = mUseractive.info[self.aname].charge[item][1]-num
            mUseractive.info[self.aname].charge[item][2] = mUseractive.info[self.aname].charge[item][2]+num
        else
            if not mUseractive.info[self.aname].ex or not next(mUseractive.info[self.aname].ex) then
                response.ret = -102
                return response
            end

            local cur = mUseractive.info[self.aname].ex[item][1]
            if cur<=0 then
                response.ret = -102
                return response
            end

            if num>cur then
                response.ret = -102
                return response
            end

            local giftcfg = activeCfg.serverreward['extraGift'..item]
            if type(giftcfg)~='table' then
                response.ret = -102
                return response
            end

            for k,v in pairs(giftcfg) do
                local tnum = v*num    
                if k=='jtzg_a1' then
                    jtzg_a1 = tnum
                elseif k=='jtzg_a2' then
                    jtzg_a2 = tnum
                else
                    reward[k] = tnum
                end
            end

            mUseractive.info[self.aname].ex[item][1] = mUseractive.info[self.aname].ex[item][1]-num
            mUseractive.info[self.aname].ex[item][2] = mUseractive.info[self.aname].ex[item][2]+num
        end

        if not next(reward) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end
        local report = {}
        for k,v in pairs(reward) do
            table.insert(report,formatReward({[k]=v}))
        end
        
        if jtzg_a1>0 then
            table.insert(report,self.formatreward({jtzg_a1=jtzg_a1}))
        end

        if jtzg_a2>0 then
            table.insert(report,self.formatreward({jtzg_a2=jtzg_a2}))
        end
        local aid = mUserinfo.alliance
        mUseractive.info[self.aname].jtzg_a1 =  mUseractive.info[self.aname].jtzg_a1 + jtzg_a1

        if aid>0 and jtzg_a2>0 and ts < tonumber(mUseractive.getAcet(self.aname, true)) then
            mUseractive.info[self.aname].jtzg_a2 = mUseractive.info[self.aname].jtzg_a2 + jtzg_a2
            
            local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
            if mAllianceActive then
                local params = {}
                local setRet,code=M_alliance.getalliance{aid=mUserinfo.alliance}
                if type(setRet['data'])=='table' and next(setRet['data']) then
                     params.anum = setRet['data']['alliance']['num']
                end
                
                params.allianceName=mUserinfo.alliancename
                params.score = jtzg_a2
                mAllianceActive.getActiveObj(self.aname):addPoint(params)
            else
                writeLog({msg="jtzg addPoint error",aid=aid,point=jtzg_a2})
            end
        end
     
        if uobjs.save() then
            processEventsAfterSave()
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

    -- 排行榜列表
    function self.action_rankingList(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid or 0
        local mAllianceActive = getModelObjs("allianceactive",0,true)
        response.data[self.aname] = {rankingList = mAllianceActive.getActiveObj(self.aname):getRankingList()}
        response.data[self.aname].rt1 = 0 -- 军团已领取奖励次数
        response.data[self.aname].rt2 = 0 -- 军团长领取奖励次数
        response.data[self.aname].score = 0 -- 军团总积分
        if aid>0 then
            local aAllianceActive = getModelObjs("allianceactive",aid)
            local activeObj = aAllianceActive.getActiveObj(self.aname) 
            response.data[self.aname].rt1 = activeObj.activeInfo.r1 or 0
            response.data[self.aname].rt2 = activeObj.activeInfo.r2 or 0  
            response.data[self.aname].score = activeObj.activeInfo.score or 0
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 排行榜奖励(跨服军团排行榜)
    function self.action_rankingReward(request)
        local response = self.response
        local uid = request.uid
        local ranking = request.params.ranking
        local zoneId = getZoneId()
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if ts < tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local aid = uobjs.getModel('userinfo').alliance
        if aid < 1 then
            response.ret = -8012
            return response
        end

        if mUseractive.info[self.aname].r ==  1 then
            response.ret = -1976
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = mAllianceActive.getActiveObj(self.aname)

        local myRanking = nil
        local rankingList = activeObj:getRankingList()
        if type(rankingList) == "table" then
            for k,v in pairs(rankingList) do
                if v[1] == zoneId and v[2] == aid and k == ranking and v[3] >= activeCfg.rLimit then
                    myRanking = k
                    break
                end
            end
        end

        if not myRanking then
            response.ret = -1981
            return response
        end

        --返回值role 2是军团长，1是副团长，0是普通成员
        local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        local flag = false
        -- 如果是军团长 需要给额外的奖励 如果是军团长 需要给额外的奖励
        if tonumber(ret.data.role)==2 then
            flag =  true
        end

        local matchid = 0
        for k,v in pairs(activeCfg.section) do
            if myRanking >= v[1] and myRanking <= v[2] then
                matchid = k
                break
            end
        end

        if matchid==0 then
            response.ret = -102
            return response
        end

        -- 军团领取次数+1
        activeObj.activeInfo.r1 = (activeObj.activeInfo.r1 or 0) + 1
        if not activeObj.activeInfo.r2 then
            activeObj.activeInfo.r2 = 0
        end
        local reward
        -- 领取次数达到上限
        if activeObj.activeInfo.r1 > activeCfg.rGetLimit then
            if tonumber(ret.data.role)==2 then
                local r2 = activeObj.activeInfo.r2 or 0
                if r2 == 0 then
                    reward = copyTable(activeCfg.serverreward['trank'..matchid])
                    activeObj.activeInfo.r2 = 1
                else
                    response.ret = -1976
                    return response
                end
            else
                response.ret = -1993
                return response
            end
        else
           reward = copyTable(activeCfg.serverreward['rank'..matchid])
           if flag and activeObj.activeInfo.r2==0 then
                for k,v in pairs(activeCfg.serverreward['trank'..matchid]) do
                    reward[k] = (reward[k] or 0) + v
                end
                activeObj.activeInfo.r2 = 1
           end
        end
        
        if not reward then
            response.ret = -102
            response.err = "reward is nil"
            return response
        end

        -- 领奖
        if not takeReward(uid, reward) then
            response.ret = -1989
            return response
        end

        mUseractive.info[self.aname].r =  1
        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 刷新 初始化
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)


        local flag = false
        -- 可领取次数和已领取次数记录
        if type(mUseractive.info[self.aname].charge) ~='table' then
        	flag = true
        	mUseractive.info[self.aname].charge = {}    	
            for k,v in pairs(activeCfg.serverreward.rechargeNum) do
        		table.insert(mUseractive.info[self.aname].charge,{0,0})
        	end
        end

        if type(mUseractive.info[self.aname].ex)~='table' then
            flag = true
            mUseractive.info[self.aname].ex = {}
            for k,v in pairs(activeCfg.serverreward.extraRechargeNum) do
                table.insert(mUseractive.info[self.aname].ex,{0,0})
            end      
        end
        -- 手电筒
        if not mUseractive.info[self.aname].jtzg_a1 then
            mUseractive.info[self.aname].jtzg_a1 = 0
        end

        -- 探照灯
        if not mUseractive.info[self.aname].jtzg_a2 then
            mUseractive.info[self.aname].jtzg_a2 = 0
        end

        -- 商店
        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)--兑换次数
            end
        end
        -- 有没有领取排行榜奖励
        if not mUseractive.info[self.aname].r then
            flag = true
            mUseractive.info[self.aname].r = 0
        end

    
        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]

        local aid = mUserinfo.alliance
        response.data[self.aname].score = 0
        if aid>0 then
            local aAllianceActive = getModelObjs("allianceactive",aid)
            local activeObj = aAllianceActive.getActiveObj(self.aname)   
            response.data[self.aname].score = activeObj.activeInfo.score or 0
        end
        response.ret = 0
        response.msg = 'Success'

        return response
    end

     -- 兑换
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local num=request.params.num or 1 --兑换个数
        local item = request.params.item -- 物品下标

        if num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if not mUseractive.info[self.aname].jtzg_a1 then
            mUseractive.info[self.aname].jtzg_a1=0
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemCfg = activeCfg.serverreward.shopList[item]
        if type(itemCfg)~='table' then
            response.ret = -102
            return response
        end

        local left = itemCfg.limit - mUseractive.info[self.aname].shop[item]
        if left<=0 or num>left then
            response.ret = -1987
            return response
        end
    
        local costp  = num * itemCfg.price
        if mUseractive.info[self.aname].jtzg_a1<costp then
            response.ret = -1996
            return response
        end


        local reward ={}
        for k,v in pairs(itemCfg.serverreward) do
            reward[k] = v*num
        end
      
        if not takeReward(uid,reward) then
            response.ret =-403
            return response
        end

        mUseractive.info[self.aname].jtzg_a1 =   mUseractive.info[self.aname].jtzg_a1 - costp
        mUseractive.info[self.aname].shop[item] = mUseractive.info[self.aname].shop[item] + num
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
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

return api_active_jtzg

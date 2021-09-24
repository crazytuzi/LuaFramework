--
-- desc: 战机补给点
-- user: chenyunhe
--
local function api_active_zjbjd(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'zjbjd',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'zjbjd'
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

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        
        local flag = false
        -- 初始化活动道具
        for k,v in pairs(activeCfg.actpropS) do
            if not mUseractive.info[self.aname][v] then
                mUseractive.info[self.aname][v] = 0
                flag = true
            end
        end

        -- 活动任务
        if type(mUseractive.info[self.aname].tk)~='table' then
            flag = true
            mUseractive.info[self.aname].tk = {}
            for k,v in pairs(activeCfg.task) do
                table.insert(mUseractive.info[self.aname].tk,{0,0}) -- 进度 领取状态
            end
        end

        -- 兑换进程箱 领取状态
        if type(mUseractive.info[self.aname].exlog)~='table' then
            flag = true
            mUseractive.info[self.aname].exlog = {}
            for k,v in pairs(activeCfg.severReward.serverGift) do
                table.insert(mUseractive.info[self.aname].exlog,0) -- 是否领取
            end
        end

        -- 兑换次数
        if not mUseractive.info[self.aname].cn then
            flag = true
            mUseractive.info[self.aname].cn = 0
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

    -- 领取任务奖励
    function self.action_treward(request)
        local uid = request.uid
        local response = self.response
        local i = request.params.i --任务下标

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local tkcfg = activeCfg.task[i]
        if type(tkcfg)~='table' then
            response.ret = -120
            return response
        end

        if mUseractive.info[self.aname].tk[i][2] == 1 then
            response.ret = -1976
            return response
        end

        if mUseractive.info[self.aname].tk[i][1]<tkcfg.needNum then
            response.ret = -102
            return response
        end
        
        if not next(tkcfg.serverReward) then
            response.ret = -120
            return response
        end

        local reward = {}
        local report = {}
        for k,v in pairs(tkcfg.serverReward) do
            if table.contains(activeCfg.actpropS,k) then
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                table.insert(report,self.formatreward({[k]=v}))
            else
                reward[k] = v
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].tk[i][2] = 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 兑换进度箱奖励
    function self.action_gift(request)
        local uid = request.uid
        local response = self.response
        local i = request.params.i --任务下标

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local gcfg = activeCfg.severReward.serverGift[i]
        if type(gcfg)~='table' then
            response.ret = -120
            return response
        end

        if (mUseractive.info[self.aname].cn or 0)<gcfg.needPz then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].exlog[i] == 1 then
            response.ret = -1976
            return response
        end
        
        if not next(gcfg.serverReward) then
            response.ret = -120
            return response
        end

        local reward = {}
        local report = {}
        for k,v in pairs(gcfg.serverReward) do
            if table.contains(activeCfg.actpropS,k) then
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                table.insert(report,self.formatreward({[k]=v}))
            else
                reward[k] = v
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].exlog[i] = 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 碎片合成令牌 消耗钻石
    function self.action_compose(request)
        local uid = request.uid
        local response = self.response
        local num = request.params.num --合成令牌的数量

        if num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local cost = num*activeCfg.tokenPro
    
        if mUseractive.info[self.aname][activeCfg.actpropS[2]]<cost then
            response.ret = -102
            return response
        end    

        local report = {}
        table.insert(report,self.formatreward({[activeCfg.actpropS[1]]=num}))
        local gems = activeCfg.cost*num
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        else
            regActionLogs(uid,1,{action = 271, item = "", value = gems, params = {num = num}})
        end

        mUseractive.info[self.aname][activeCfg.actpropS[2]] = mUseractive.info[self.aname][activeCfg.actpropS[2]] - cost
        mUseractive.info[self.aname][activeCfg.actpropS[1]] = (mUseractive.info[self.aname][activeCfg.actpropS[1]] or 0) + num
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 兑换（抽奖）
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if num<=0 or mUseractive.info[self.aname][activeCfg.actpropS[1]]<num then
            response.ret = -102
            return response
        end
      
        local reward = {}
        local report = {}
        local actprops = {}
        for i=1,num do 	
            local rd,rk = getRewardByPool(activeCfg.severReward.pool,1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    if table.contains(activeCfg.actpropS,rkey) then
                       actprops[rkey] = (actprops[rkey] or 0) + rval
                    else
                        reward[rkey]=(reward[rkey] or 0)+rval
                    end               
                end
            end
        end

        if next(reward) then    
            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end

            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        -- 每兑换一次返还令牌碎片
        actprops[activeCfg.actpropS[2]] = (actprops[activeCfg.actpropS[2]] or 0) + num
        if next(actprops) then
            for k,v in pairs(actprops) do
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                table.insert(report,self.formatreward({[k]=v}))
            end
        end

        mUseractive.info[self.aname][activeCfg.actpropS[1]] = mUseractive.info[self.aname][activeCfg.actpropS[1]] - num
        mUseractive.info[self.aname].cn  = (mUseractive.info[self.aname].cn or 0) + num
        if uobjs.save() then
 			local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end   
            table.insert(data,1,{ts,report,num})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end        	
            response.data[self.aname] =mUseractive.info[self.aname]
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

    return self
end

return api_active_zjbjd

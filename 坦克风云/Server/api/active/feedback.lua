-- desc: 岁末回馈
-- user: liming
local function api_active_feedback(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'feedback',
    }

    -- 初始化数据
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        if not uid then
            response.ret = -102
            return response
        end

        local ts= getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级检测
        if mUserinfo.level <= activeCfg.level then
            response.ret = -301
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 初始化签到
        local flag = false

        if not mUseractive.info[self.aname].task then 
            flag = true
            mUseractive.info[self.aname].task = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                 mUseractive.info[self.aname].task[k] = {}
                for key,val in pairs(v) do
                    local k1 = val.type
                    if k1 ~= 'gb' then
                        mUseractive.info[self.aname].task[k][k1] = {0,0}
                    else
                        table.insert(mUseractive.info[self.aname].task[k],{0,0})
                    end 
                end
            end 
        end
        if flag then
            if not uobjs.save() then
                response.ret = -102
                return response
            end
        end        
        
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取任务奖励
    function self.action_gift(request)
        local response = self.response
        local uid = request.uid
        -- activity_setopt(uid,'dresstree',{act='charge',num=230})
        local id = request.params.id -- 哪页
        local tid = request.params.tid -- 哪个任务
        
        if not uid or not id then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')   
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        --  等级检测
        if mUserinfo.level <= activeCfg.level then
            response.ret = -301
            return response
        end 
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if not mUseractive.info[self.aname].task then
            response.ret = -102
            return response
        end
        
        local taskList = copyTable(activeCfg.serverreward.taskList)
        if type(taskList[id])~='table' then
            response.ret = -102
            return response
        end
        local taskcfg = {}
        if id == 2 then
            tid = tonumber(tid)
            taskcfg = copyTable(taskList[id][tid])
        else
            for k,v in pairs(taskList[id]) do
                if tid == v.type then
                    taskcfg = copyTable(v)
                    break
                end
            end
        end
        if type(taskcfg) ~= 'table' then
            response.ret = -102
            return response
        end

        if not next(taskcfg) then
            response.ret = -102
            return response
        end
        if not table.contains(table.keys(mUseractive.info[self.aname].task[id]),tid) then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].task[id][tid][2] == 1 then
            response.ret = -1976
            return response
        end
        local cfgNum = taskcfg.num
        if mUseractive.info[self.aname].task[id][tid][1]<cfgNum then
            response.ret = -1981
            return response
        end
        local vip = mUserinfo.vip
        local minVip = activeCfg.vip[1]
        local maxVip = activeCfg.vip[2]
        local minRate = tonumber(activeCfg.plus[1])
        local maxRate = tonumber(activeCfg.plus[2])
        if vip >= minVip and vip < maxVip then
            for k,v in pairs(taskcfg.serverreward) do
               taskcfg.serverreward[k][2] = math.floor(taskcfg.serverreward[k][2]*(1+minRate))
            end
            taskcfg.vippoint = math.floor(taskcfg.vippoint*(1+minRate))
        end

        if vip >= maxVip then
            for k,v in pairs(taskcfg.serverreward) do
               taskcfg.serverreward[k][2] = math.floor(taskcfg.serverreward[k][2]*(1+maxRate))
            end
            taskcfg.vippoint = math.floor(taskcfg.vippoint*(1+maxRate))
        end

        local reward = {}
        local report = {}
        for k,v in pairs(taskcfg.serverreward) do
            reward[v[1]] = (reward[v[1]] or 0) + v[2]
            table.insert(report, formatReward({[v[1]]=v[2]}))
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        local vippoint = (taskcfg.vippoint) or 0
        if vippoint > 0 then
            if not mUserinfo.addResource({vippoint=vippoint}) then
                response.ret = -1991
                return response
            end
            mUserinfo.vip=mUserinfo.updateVipLevel()
        end
        mUseractive.info[self.aname].task[id][tid][2] = 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = report
            response.data.vippoint = vippoint
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    return self
end

return api_active_feedback

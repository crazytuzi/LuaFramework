--
-- desc: 德国七日狂欢
-- user: chenyunhe
--
local function api_active_sevendays(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'sevendays',
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

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        -- 当前是第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        -- 初始化签到
        local flag = false

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if not mUseractive.info[self.aname].task then 
            flag = true
            mUseractive.info[self.aname].task = {}--领取状态
            mUseractive.info[self.aname].cur = {} -- 当前值
            for k,v in pairs(activeCfg.serverreward.taskList) do
                 mUseractive.info[self.aname].task[k] = {}
                for key,val in pairs(v) do
                    table.insert(mUseractive.info[self.aname].task[k],0) --参数:0不能领取 1可领取 2已领取 
                end
            end
            
            for k,v in pairs(activeCfg.serverreward.tasktype) do
                mUseractive.info[self.aname].cur[v] = 0 -- 任务对应当前完成值
            end   
        end

        if getWeeTs(mUserinfo.logindate)~=weeTs then
            flag = true
            activity_setopt(uid,'sevendays',{act='sd1',v=0,n=0})
        end

        if flag then
            if not uobjs.save() then
                response.ret = -102
                return response
            end
        end        

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data.curday =  curday
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取任务奖励
    function self.action_taskreward(request)
        local response = self.response
        local uid = request.uid
        local day = request.params.d -- 第几天
        local tid = request.params.tid -- 哪个任务

        if not uid or not day then
            response.ret = -102
            return response
        end
        local daykey = 'day'..day
      
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if not mUseractive.info[self.aname].task or not mUseractive.info[self.aname].cur then
            response.ret = -102
            return response
        end

        local ts= getClientTs()
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        if day > currDay then
            response.ret = -102
            return response
        end

        local taskList = activeCfg.serverreward.taskList
        if type(taskList[daykey])~='table' then
            response.ret = -102
            return response
        end

        local taskcfg = taskList[daykey][tid]
        if type(taskcfg) ~= 'table' then
            response.ret = -102
            return response
        end

        if not table.contains(table.keys(mUseractive.info[self.aname].task[daykey]),tid) then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].task[daykey][tid] == 1 then
            response.ret = -1976
            return response
        end

        if taskcfg.type =='sd24' then--这是个排名 需要反过来判断
            if mUseractive.info[self.aname].cur[taskcfg.type]==0 or mUseractive.info[self.aname].cur[taskcfg.type] > taskcfg.num then
                response.ret = -1981
                return response
            end
        else
            if mUseractive.info[self.aname].cur[taskcfg.type] < taskcfg.num then
                response.ret = -1981
                return response
            end
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

        mUseractive.info[self.aname].task[daykey][tid] = 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end



    return self
end

return api_active_sevendays

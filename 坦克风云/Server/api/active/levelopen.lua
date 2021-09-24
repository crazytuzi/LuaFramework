-- desc: 百级开启
-- user: liming
local function api_active_levelopen(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'levelopen',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'levelopen'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end
    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
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
        if mUseractive.info[self.aname].nighttime == nil then
            mUseractive.info[self.aname].nighttime = 0
        end
        if mUseractive.info[self.aname].sign == nil then
            mUseractive.info[self.aname].sign = 0 --签到次数
        end
        if mUseractive.info[self.aname].sign < activeCfg.signDays then
            if ts > mUseractive.info[self.aname].nighttime then
                mUseractive.info[self.aname].remark = 0 --未领取
                mUseractive.info[self.aname].nighttime = currTs
            end
        else
            mUseractive.info[self.aname].remark = 2 --已领满7天
        end
        if type(mUseractive.info[self.aname].task) ~= 'table' then
            mUseractive.info[self.aname].task = {}--任务
            for k,v in pairs(activeCfg.serverreward.taskList) do
                local id =math.ceil((mUserinfo.level-activeCfg.levelLimit+1)/10)
                local tmpid = #v
                if id > tmpid then
                    id = tmpid
                end
                mUseractive.info[self.aname].task[k] = {}
                mUseractive.info[self.aname].task[k].index = id--任务下标
                mUseractive.info[self.aname].task[k].cur = 0 --当前数量
                mUseractive.info[self.aname].task[k].cron = v[id][1] --完成条件
                mUseractive.info[self.aname].task[k].r = 0 --是否领奖
            end
            mUseractive.info[self.aname].levelopen_a1 = 0 --福利劵
            mUseractive.info[self.aname].welnum = 0 --福利领取次数
            mUseractive.info[self.aname].levelopen_a2 = 0 --积分
            mUseractive.info[self.aname].r = 0 --排行榜奖励
        end
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取签到奖励
    function self.action_signgift(request)
        local uid = request.uid
        local response = self.response
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        local acet = mUseractive.getAcet(self.aname,true)
        if mUseractive.info[self.aname].sign < activeCfg.signDays then
            if ts > mUseractive.info[self.aname].nighttime then
                mUseractive.info[self.aname].remark = 0 --未领取
                mUseractive.info[self.aname].nighttime = currTs
            end
        else
            mUseractive.info[self.aname].remark = 2 --已领满7天
        end
        if mUseractive.info[self.aname].remark==1 or mUseractive.info[self.aname].remark==2 then
            response.ret=-1976
            return response
        end
        if ts > acet then
            response.ret=-1978    
            return response
        end
        
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        
        mUseractive.info[self.aname].sign = mUseractive.info[self.aname].sign + 1 
        local id = mUseractive.info[self.aname].sign
        local reward = activeCfg.serverreward['career'..id]
        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
        mUseractive.info[self.aname].remark = 1
        if mUseractive.info[self.aname].sign == activeCfg.signDays then
            mUseractive.info[self.aname].remark = 2
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 福利劵领奖
    function self.action_welgift(request)
        local uid = request.uid
        local response = self.response
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local num = request.params.num or 1
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        local acet = mUseractive.getAcet(self.aname,true)
        if mUseractive.info[self.aname].welnum+num > activeCfg.welfareLimit then
            response.ret=-1987
            return response
        end
        if ts > acet then
            response.ret=-1978    
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local needprice = activeCfg.serverreward.welfareCost[2]*num
        if mUseractive.info[self.aname].levelopen_a1 < needprice then
            response.ret = -102
            return response
        end
        local reward = activeCfg.serverreward.welfare
        for k,v in pairs(reward) do
            reward[k] = v*num
        end
        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
        mUseractive.info[self.aname].welnum = mUseractive.info[self.aname].welnum + num
        mUseractive.info[self.aname].levelopen_a1 = mUseractive.info[self.aname].levelopen_a1 - needprice
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end
    
    -- 升级任务
    function self.action_uptask(request)
        local response = self.response
        local uid=request.uid
        local taskid = request.params.type
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local acet = mUseractive.getAcet(self.aname,true)
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        if not uid then
            response.ret = -102
            return response
        end
        if ts > acet then
            response.ret=-1978    
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local id =math.ceil((mUserinfo.level-activeCfg.levelLimit+1)/10)
        if id > #activeCfg.serverreward.taskList[taskid] then
            id = #activeCfg.serverreward.taskList[taskid]
        end
        local taskinfo = mUseractive.info[self.aname].task[taskid]
        if type(taskinfo) ~= 'table' then
            response.ret = -102
            return response
        end
        if id <= mUseractive.info[self.aname].task[taskid].index then
            response.ret = -102
            return response
        end
        if taskid=='f2' then
            if mUseractive.info[self.aname].task[taskid].r == 0 and mUseractive.info[self.aname].task[taskid].cur >= mUseractive.info[self.aname].task[taskid].cron then
                response.ret = -102
                return response
            end
        else
            if mUseractive.info[self.aname].task[taskid].r == 0 and mUseractive.info[self.aname].task[taskid].cur > 0 then
                response.ret = -102
                return response
            end
        end
        mUseractive.info[self.aname].task[taskid].cron = activeCfg.serverreward.taskList[taskid][id][1]
        mUseractive.info[self.aname].task[taskid].index = activeCfg.serverreward.taskList[taskid][id].index
        mUseractive.info[self.aname].task[taskid].cur = 0
        mUseractive.info[self.aname].task[taskid].r = 0
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取任务奖励
    function self.action_taskreward(request)
        local response = self.response
        local uid=request.uid
        local zoneid = request.zoneid
        local id = request.params.type
        local num = request.params.num or 1
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local nickname = mUserinfo.nickname
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
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
        local ts= getClientTs()
        local acet = mUseractive.getAcet(self.aname,true)
        if id == "f2" then
            if num*mUseractive.info[self.aname].task[id].cron > mUseractive.info[self.aname].task[id].cur then
                response.ret = -1981
                return response
            end
        else
            if num > mUseractive.info[self.aname].task[id].cur then
                response.ret = -1981
                return response
            end
        end
        local key = mUseractive.info[self.aname].task[id].index
        local rewardinfo = activeCfg.serverreward.taskList[id][key]
        local reward = {} -- 常规奖励
        local spprop = {} -- 属于本活动的道具
        for k,v in pairs(rewardinfo.serverreward) do
            if string.find(k,'levelopen') then
                spprop[k]=(spprop[k] or 0)+v*num
            else
                reward[k]=(reward[k] or 0)+v*num
            end
        end
        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
        local params = {}
        if next(spprop) then
            for k,v in pairs(spprop) do
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                table.insert(report,self.formatreward({[k]=v}))
                if string.find(k,'levelopen_a2') then
                    if mUseractive.info[self.aname].levelopen_a2>activeCfg.rLimit
                        then
                        params = {
                              zoneid     = tonumber(zoneid),
                              uid        = tonumber(uid),
                              nickname   = nickname,
                              st = tonumber(mUseractive.info[self.aname].st),
                              score = tonumber(mUseractive.info[self.aname].levelopen_a2),
                              updated_at = ts,
                              acname = self.aname
                        }
                        local ret = crossserverrank(params)
                        if not ret then
                           writeLog(json.encode(params),'crossrank_log')
                        end
                    end
                end 
            end
        end
        if id == "f2" then
           mUseractive.info[self.aname].task[id].cur = mUseractive.info[self.aname].task[id].cur - num*mUseractive.info[self.aname].task[id].cron
        else
           mUseractive.info[self.aname].task[id].cur = mUseractive.info[self.aname].task[id].cur - num
        end
        if mUseractive.info[self.aname].task[id].r==nil then
            mUseractive.info[self.aname].task[id].r = 0
        end
        mUseractive.info[self.aname].task[id].r = 1
        local levelid =math.ceil((mUserinfo.level-activeCfg.levelLimit+1)/10)
        if levelid > #activeCfg.serverreward.taskList[id] then
            levelid = #activeCfg.serverreward.taskList[id]
        end
        local taskinfo = mUseractive.info[self.aname].task[id]
        if ts <= acet then
            if levelid > mUseractive.info[self.aname].task[id].index then
                if type(taskinfo) ~= 'table' then
                    response.ret = -102
                    return response
                end
                if id=='f2' then
                    if mUseractive.info[self.aname].task[id].r == 0 and mUseractive.info[self.aname].task[id].cur >= mUseractive.info[self.aname].task[id].cron then
                        response.ret = -102
                        return response
                    end
                else
                    if mUseractive.info[self.aname].task[id].r == 0 and mUseractive.info[self.aname].task[id].cur > 0 then
                        response.ret = -102
                        return response
                    end
                end
                mUseractive.info[self.aname].task[id].cron = activeCfg.serverreward.taskList[id][levelid][1]
                mUseractive.info[self.aname].task[id].index = activeCfg.serverreward.taskList[id][levelid].index
                mUseractive.info[self.aname].task[id].cur = 0
                mUseractive.info[self.aname].task[id].r = 0
            end
        end
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].reward = report
        response.ret = 0
        response.msg = 'Success'
        return response
    end
    
    -- 获取跨服排行榜数据
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
        local ranklist = crossserverranklist(mUseractive.info[self.aname].st,self.aname)   
        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].ranklist = ranklist
        return response
    end

    -- 排行榜大奖
    function self.action_bigreward(request)
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
        local ranklist = crossserverranklist(mUseractive.info[self.aname].st,self.aname) 
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v.uid)
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
        local rankreward1 = {}
        for k,v in pairs(activeCfg.section) do
            if myrank<=v[2] then
                rankreward1=activeCfg.serverreward["rank"..k]
                break
            end
        end
        for k,v in pairs(rankreward1) do
            rankreward[k] = (rankreward[k] or 0) + v
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



return api_active_levelopen

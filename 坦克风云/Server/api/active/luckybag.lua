--
-- desc: 跨年福袋
-- user: chenyunhe
--
local function api_active_luckybag(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'luckybag',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'luckybag'
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
        local flag = mUseractive.initAct(self.aname)

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

    -- 抽奖 每次消耗一个道具
    function self.action_lottery(request)
        local response = self.response
        local uid=request.uid
        local pid = request.params.pid -- 使用的道具编号
        local ts= getClientTs()
        if not pid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if  mUseractive.info[self.aname][pid] <=0 then
            response.ret = -102
            return response
        end

        -- 更新奖池等级
        local function uppoollv(luckval)
            mUseractive.info[self.aname].luck = mUseractive.info[self.aname].luck + luckval
            local maxlv = #activeCfg.supportNeed
            for i=maxlv,1,-1 do
                if mUseractive.info[self.aname].luck >= activeCfg.supportNeed[i] then
                    mUseractive.info[self.aname].lv = i
                    break
                end
            end

            if mUseractive.info[self.aname].lv >= maxlv then
                 mUseractive.info[self.aname].luck = activeCfg.supportNeed[maxlv]
            end
        end
        
        local poollv = mUseractive.info[self.aname].lv or 1-- 奖池等级
        local reward = {} 
        setRandSeed()
        local luck = rand(activeCfg.score[pid][1],activeCfg.score[pid][2])
        local result,rekey = getRewardByPool(activeCfg.serverreward[pid]['pool'..poollv],1)
        for k,v in pairs(result) do
            for vk,val in pairs(v) do
                reward[vk]=(reward[vk] or 0)+val
            end
        end
        -- 根据获得幸运值 更新奖池等级
        if mUseractive.info[self.aname].lv < #activeCfg.supportNeed then
            uppoollv(luck)
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

        mUseractive.info[self.aname][pid] = mUseractive.info[self.aname][pid] - 1
        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            
            table.insert(data,1,{ts,report,luck})
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
            response.data[self.aname].getluck = luck --本次获福运值
            
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

    -- 领取任务奖励 id 任务下标
    function self.action_task(request)
        local response = self.response
        local uid=request.uid
        local itemid = request.params.id 

        if not itemid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname) 
        local taskcfg = activeCfg.serverreward.taskList[itemid]
        if type(taskcfg)~='table' then
            response.ret = -102
            return response
        end
        local num = mUseractive.info[self.aname].task[itemid][2] - mUseractive.info[self.aname].task[itemid][3]
        if num <=0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local spprop = {}
        for  k,v in pairs(taskcfg.serverreward) do
            if string.find(v[1],'luckybag') then
                spprop[v[1]]=(spprop[v[1]] or 0)+v[2]*num
            else
                reward[v[1]]=(reward[v[1]] or 0)+v[2]*num
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

        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end

        -- 更新每日领取记录
        mUseractive.info[self.aname].task[itemid][3] = mUseractive.info[self.aname].task[itemid][2]
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

    return self
end

return api_active_luckybag

--desc:猎杀潜航活动
--user:chenyunhe
--活动内容包含 充值钻石领取奖励、限购、猎杀任务
local function api_active_silenthunter(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'silentHunter',
    }
    
    -- 累计充值钻石领奖
    function self.action_accuGems(request)
        local response = self.response
        local uid = request.uid
        local rnum = request.params.rnum or 0 --可领取次数
        if uid<=0 or uid ==nil or rnum==0 then
           response.ret = -102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].charge)~='table' then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local accChargeCfg = activeCfg.accCharge
        if accChargeCfg.limit<= mUseractive.info[self.aname].charge.t then
            response.ret = -1993
            return response
        end

        local diff = mUseractive.info[self.aname].charge.g-mUseractive.info[self.aname].charge.t*accChargeCfg.recharge
        if diff<accChargeCfg.recharge then
            response.ret = -102
            return response
        end
        local leftTime = accChargeCfg.limit-mUseractive.info[self.aname].charge.t -- 剩余领取次数
        local num=1
        local diffTimes = math.floor(diff/accChargeCfg.recharge)

        if diffTimes>leftTime then
            num=leftTime
        else
            num=diffTimes
        end
        -- 跟客户端校验领取次数
        if rnum~=num then
            response.ret=-102
            return response
        end

        mUseractive.info[self.aname].charge.t = mUseractive.info[self.aname].charge.t+num
        local reward = {}
        local report = {}
        for k,v in pairs (activeCfg.serverreward.accCharge) do
            reward[v[1]]=(reward[v[1]] or 0)+v[2]*num
            table.insert(report, formatReward({[v[1]]=v[2]*num}))
        end

        if not takeReward(uid,reward) then
            return response
        end

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=report
        else
            response.ret=-106
        end
        return response
    end

    -- 限购
    function self.action_limitSell(request)
        local response = self.response
        local uid = request.uid

        if uid<=0 or uid ==nil then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local limitSellCfg = activeCfg.limitSell

        local buyTimes = mUseractive.info[self.aname].sell or 0
        if(buyTimes>=limitSellCfg.buylimit) then
            response.ret = -1993
            return response
        end
        local cost = limitSellCfg.cost
        if not mUserinfo.useGem(cost) then
            response.ret = -109
            return response
        end

        local reward = {}
        local report = {}
        for k,v in pairs (activeCfg.serverreward.limitSell) do
            reward[v[1]]=(reward[v[1]] or 0)+v[2]
            table.insert(report, formatReward({[v[1]]=v[2]}))
        end

        if not takeReward(uid,reward) then
            return response
        end
        mUseractive.info[self.aname].sell = buyTimes+1
        regActionLogs(uid,1,{action=164,item="",value=cost,params={reward=reward}})

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=report
        else
            response.ret=-106
        end
        return response
    end

    -- 猎杀任务领取奖励
    function self.action_huntertask(request)
        local response = self.response
        local uid = request.uid
        local task = request.params.tk

        if not uid or task==nil then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].tk)~='table' then
            mUseractive.info[self.aname].tk = {}
            mUseractive.info[self.aname].tk[task] = {}
            mUseractive.info[self.aname].tk[task].n = 0
            mUseractive.info[self.aname].tk[task].r = 0 -- 未完成 1 可领取 2 已领取
        end
        if type(mUseractive.info[self.aname].tk[task])~='table' then
            mUseractive.info[self.aname].tk[task] = {}
            mUseractive.info[self.aname].tk[task].n = 0
            mUseractive.info[self.aname].tk[task].r = 0
        end

        if mUseractive.info[self.aname].tk[task].r==2 then
            response.ret = -1976
            return response
        end

        local report ={}
        local reward ={}
        -- 判断条件是否满足
        if mUseractive.info[self.aname].tk[task].n<activeCfg.taskList[task].num then
            response.ret = -1981
            return response
        end

        for k,v in pairs (activeCfg.serverreward.taskList[task]) do
            reward[v[1]]=(reward[v[1]] or 0)+v[2]
            table.insert(report, formatReward({[v[1]]=v[2]}))
        end

        if not takeReward(uid,reward) then
            return response
        end
        -- 修改状态 0 未完成,1可领取 2已完成
        mUseractive.info[self.aname].tk[task].r=2

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=report
        else
            response.ret=-106
        end
        return response
    end

    -- 获取活动记录数据
    function self.action_silentHinfo(request)
        local response = self.response
        local uid = request.uid

        if uid<=0 or uid ==nil then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive","troops"})
        local mUseractive = uobjs.getModel('useractive')
        local mTroops = uobjs.getModel('troops')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        --猎杀潜航任务
        -- 拥有的某潜艇数量任务 特殊判断
        local feiyuNum= mTroops.troops['a10014'] or 0
        activity_setopt(uid,'silentHunter',{action='du',num=feiyuNum})
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    return self
end

return api_active_silenthunter
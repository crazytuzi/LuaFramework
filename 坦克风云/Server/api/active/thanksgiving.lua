--desc: 感恩节2017
--user: liming
local function api_active_thanksgiving(request)
	local self={
	    response={
	       ret=-1,
	       msg='error',
           data={},
		},
		aname="thanksgiving",
    }
    --初始化数据
    function self.action_init(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        --积分
        if mUseractive.info[self.aname].grade == nil then 
           mUseractive.info[self.aname].grade = 0
        end
        if mUseractive.info[self.aname].single == nil then 
           mUseractive.info[self.aname].single = 0
        end
        if mUseractive.info[self.aname].more == nil then 
           mUseractive.info[self.aname].more = 0
        end
        if mUseractive.info[self.aname].cost == nil then 
           mUseractive.info[self.aname].cost = 0
        end
        if mUseractive.info[self.aname].thank_a1 == nil then 
           mUseractive.info[self.aname].thank_a1 = 0
        end
        if mUseractive.info[self.aname].thank_a2 == nil then 
           mUseractive.info[self.aname].thank_a2 = 0
        end
        if mUseractive.info[self.aname].thank_a2 == nil then 
           mUseractive.info[self.aname].thank_a2 = 0
        end
        if type(mUseractive.info[self.aname].support)~='table' then
            mUseractive.info[self.aname].support={}
            for k,v in pairs(activeCfg.supportNeed) do
                table.insert(mUseractive.info[self.aname].support,0)
            end
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end
     -- 领取奖励
    function self.action_gift(request)
        local uid = request.uid
        local index= request.params.index   
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if index == nil then
            response.ret = -102
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        --积分
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local tmpgrade = activeCfg.supportNeed[index]
        if mUseractive.info[self.aname].grade == nil then 
           mUseractive.info[self.aname].grade = 0
        end
        local report = {}
        local reward = {} --普通道具
        local spprop = {} --特殊道具
        if mUseractive.info[self.aname].grade<tmpgrade then
            response.ret = -108
            return response
        else
            local flag = mUseractive.info[self.aname].support[tonumber(index)]
            if flag == 1 then
                response.ret = -1976 --已领取过此宝箱
                return response
            else
                local rewardCfg = activeCfg.serverreward['gift'..index]
                local et = mUseractive.info[self.aname].et+86400
                for k,v in pairs(rewardCfg) do
                    if string.find(v[1],'ank') then
                        spprop[v[1]] = (spprop[v[1]] or 0) + v[2]
                    else
                        reward[v[1]] = (reward[v[1]] or 0) + v[2]
                    end
                end
 
                if next(reward) then
                    for k,v in pairs(reward) do
                        table.insert(report, formatReward({[k]=v}))
                    end
                    if not takeReward(uid,reward) then
                        response.ret = -403
                        return response
                    end
                end
                if next(spprop) then
                    for k,v in pairs(spprop) do
                         mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                         table.insert(report,self.formatreward({[k]=v}))
                    end
                end
                mUseractive.info[self.aname].support[tonumber(index)] = 1
            end
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end
    -- 积分兑换
    function self.action_exchange(request)
		local uid = request.uid
        -- activity_setopt(uid,'thanksgiving',{act=2,num=1,w=1})
        local item=request.params.item --兑换标识
        local num=tonumber(request.params.num or 1)
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
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
        --积分
		local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].grade == nil then 
           mUseractive.info[self.aname].grade = 0
        end
        if mUseractive.info[self.aname].thank_a1 == nil then
            mUseractive.info[self.aname].thank_a1 = 0
        end
        if mUseractive.info[self.aname].thank_a2 == nil then
            mUseractive.info[self.aname].thank_a2 = 0
        end
        if mUseractive.info[self.aname].thank_a3 == nil then
            mUseractive.info[self.aname].thank_a3 = 0
        end
        local exchange = 'exchange'..item
        local flag = true
        for k,v in pairs(activeCfg.serverreward[exchange]) do
            if (mUseractive.info[self.aname][k]-v*num) < 0 then
               flag = false
            end
        end
        local report = {}
        local reward = {} --普通道具
        local spprop = {} --特殊道具
        if flag == false then
            response.ret = -108
            return response
        else
            for k,v in pairs(activeCfg.serverreward[exchange]) do
             mUseractive.info[self.aname][k] = mUseractive.info[self.aname][k]-v*num
            end
            local pool = 'pool'..item
            local rewardCfg = {}
            local rewardtmpCfg = {}
            for i=1,num do
                rewardtmpCfg = getRewardByPool(activeCfg.serverreward[pool])
                for k, v in pairs(rewardtmpCfg or {}) do
                    rewardCfg[k] = (rewardCfg[k] or 0) + v
                end
            end
            
            for k,v in pairs(rewardCfg) do
                if string.find(k,'ank') then
                    spprop[k] = (spprop[k] or 0) + v
                else
                    reward[k] = (reward[k] or 0) + v
                end
            end
            if next(reward) then
                for k,v in pairs(reward) do
                    table.insert(report, formatReward({[k]=v}))
                end
                if not takeReward(uid,reward) then
                    response.ret = -403
                    return response
                end
            end
            if next(spprop) then
                for k,v in pairs(spprop) do
                     mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                     table.insert(report,self.formatreward({[k]=v}))
                end
            end
           mUseractive.info[self.aname].grade = mUseractive.info[self.aname].grade + num
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        

    end
    -- 充值领奖
    function self.action_chargegift(request)
        local uid = request.uid
        local recharge = request.params.recharge --领奖标志  
        local num = tonumber(request.params.num or 1)    
        local response = self.response
        local ts = getClientTs()
        local weeTs = getWeeTs()
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
        local report = {}
        local reward = {} --普通道具
        local spprop = {} --特殊道具
        if recharge == 1 then
            if (mUseractive.info[self.aname].single-num) >= 0 then 
                rewardCfg = activeCfg.serverreward['recharge'..recharge]
                for k,v in pairs(rewardCfg) do
                  rewardCfg[k][2] = v[2]*num
                end
                mUseractive.info[self.aname].single = mUseractive.info[self.aname].single - num
            else
                response.ret = -108 --单次充值额度不够
                return response
            end
        else
            if (mUseractive.info[self.aname].more-num) >= 0 then
                rewardCfg = activeCfg.serverreward['recharge'..recharge]
                for k,v in pairs(rewardCfg) do
                  rewardCfg[k][2] = v[2]*num
                end
                mUseractive.info[self.aname].cost = mUseractive.info[self.aname].cost - (activeCfg.rechargeNum[2]*num)
                mUseractive.info[self.aname].more = mUseractive.info[self.aname].more - num 
            else
                response.ret = -108 --累计充值额度不够
                return response
            end     
        end
        for k,v in pairs(rewardCfg) do
            if string.find(v[1],'ank') then
                spprop[v[1]] = (spprop[v[1]] or 0) + v[2]
            else
                reward[v[1]] = (reward[v[1]] or 0) + v[2]
            end
        end
        if next(reward) then
            for k,v in pairs(reward) do
                table.insert(report, formatReward({[k]=v}))
            end
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
        end
        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        

    end

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'thank'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end
        end
        return formatreward
    end


    return self
end

return api_active_thanksgiving

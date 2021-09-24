--
-- desc: 堆金积玉
-- user: chenyunhe
--
local function api_active_djjy(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'djjy',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'djjy'
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

        -- 充值
        if type(mUseractive.info[self.aname].ch)~='table' then
            mUseractive.info[self.aname].ch = {}--充值 
            mUseractive.info[self.aname].r = {} --领取记录
           

            for k,v in pairs(activeCfg.serverreward.taskList) do
                mUseractive.info[self.aname].ch[k] = 0
                mUseractive.info[self.aname].r[k] = {}
                for dk,dv in pairs(v) do
                    table.insert(mUseractive.info[self.aname].r[k],0)--0未领取 1已领取
                end
            end
            flag = true
        end

        -- 积分
        if not mUseractive.info[self.aname].score then
            mUseractive.info[self.aname].score = 0
            flag = true
        end

        -- 积分领奖
        if not mUseractive.info[self.aname].sr then
            mUseractive.info[self.aname].sr = {}
            for k,v in pairs(activeCfg.scoreNeed) do
                table.insert(mUseractive.info[self.aname].sr,0)
            end
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

    -- 领取积分奖励
    function self.action_sreward(request)
        local uid = request.uid
        local response = self.response
        local index = request.params.i --奖励下标
        
        if not index then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].sr[index] ==1 then
            response.ret = -1976
            return response
        end

        local giftCfg = activeCfg.serverreward.gift[index]
        if type(giftCfg)~='table' then
            response.ret = -102
            return response
        end
        
        if mUseractive.info[self.aname].score<activeCfg.scoreNeed[index] then
            response.ret = -102
            return response
        end
    
        if not takeReward(uid,giftCfg) then    
            response.ret=-403
            return response
        end

    
        mUseractive.info[self.aname].sr[index] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(giftCfg)
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
        local index = request.params.i -- 领取第几个
        local day = request.params.d  --1 第几天
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUseractive.info[self.aname].r[day][index]==1 then
            response.ret = -1976
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local daycfg = activeCfg.serverreward.taskList[day][index]
        if type(daycfg)~='table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].ch[day]<daycfg.num then
            response.ret = -102
            return response
        end

        local report = {}
        local reward = {}
        local djjy_a1 = 0
        for k,v in pairs(daycfg.r) do
            if string.find(k,"djjy_a1") then
                djjy_a1 = djjy_a1 + v
            else
                reward[k] = v
            end
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
        end
    
        for k,v in pairs(reward) do
            table.insert(report,formatReward({[k]=v}))
        end

        if djjy_a1>0 then
            table.insert(report,self.formatreward({djjy_a1=djjy_a1}))
            mUseractive.info[self.aname].score = (mUseractive.info[self.aname].score or 0) + djjy_a1
        end

        mUseractive.info[self.aname].r[day][index] = 1        
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


    return self
end

return api_active_djjy

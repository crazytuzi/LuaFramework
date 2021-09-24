--
-- desc: 战机商店
-- user: chenyunhe
--
local function api_active_zjsd(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'zjsd',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'zjsd'
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
        if not mUseractive.info[self.aname][activeCfg.itemNeed] then
            flag = true
            mUseractive.info[self.aname][activeCfg.itemNeed] = 0
        end

        -- 活动任务
        if type(mUseractive.info[self.aname].tk)~='table' then
            flag = true
            mUseractive.info[self.aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(mUseractive.info[self.aname].tk,{0,0}) -- 进度 领取状态
            end
        end

        -- 商店兑换
        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0) -- 兑换次数
            end
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
        local tkcfg = activeCfg.serverreward.taskList[i]
        if type(tkcfg)~='table' then
            response.ret = -120
            return response
        end

        if mUseractive.info[self.aname].tk[i][2] == 1 then
            response.ret = -1976
            return response
        end

        if mUseractive.info[self.aname].tk[i][1]<tkcfg.num then
            response.ret = -102
            return response
        end
        
        if not next(tkcfg.r) then
            response.ret = -120
            return response
        end

        local reward = {}
        local report = {}
        for k,v in pairs(tkcfg.r) do
            if string.find(k,activeCfg.itemNeed) then
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

    -- 商店兑换
    function self.action_shop(request)
        local uid = request.uid
        local response = self.response
        local i = request.params.i --下标
        local num = request.params.num or 0 -- 兑换次数

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local scfg = activeCfg.serverreward.shopList[i]
        if type(scfg)~='table' then
            response.ret = -120
            return response
        end
    
        if num<=0 or mUserinfo.vip<scfg.vip then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].shop[i]+num>scfg.limit then
            response.ret = -102
            return response
        end

        local cost = scfg.num * num
        if mUseractive.info[self.aname][activeCfg.itemNeed]<cost then
            response.ret = -102
            return response
        end
        
        if not next(scfg.r) then
            response.ret = -120
            return response
        end

        local reward = {}
        local report = {}
        for k,v in pairs(scfg.r) do
            if string.find(k,activeCfg.itemNeed) then
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v * num
                table.insert(report,self.formatreward({[k]=v}))
            else
                reward[k] = v*num
                table.insert(report,formatReward({[k]=v*num}))
            end
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname][activeCfg.itemNeed] = mUseractive.info[self.aname][activeCfg.itemNeed] - cost
        mUseractive.info[self.aname].shop[i] = mUseractive.info[self.aname].shop[i] + num
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

    return self
end

return api_active_zjsd
